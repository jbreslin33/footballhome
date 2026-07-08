#include "LaPool.h"

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cstdlib>
#include <ctime>
#include <iostream>
#include <set>
#include <sstream>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "../core/TeamLabel.h"
#include "../database/Database.h"
#include "../services/LaProgramSync.h"

using nlohmann::json;

namespace {

// Lowercase ASCII copy used for case-insensitive last-/first-name sort.
std::string toLowerAscii(const std::string& s) {
    std::string out;
    out.reserve(s.size());
    for (char c : s) out.push_back(static_cast<char>(std::tolower(static_cast<unsigned char>(c))));
    return out;
}

// Trim ASCII whitespace at both ends.
std::string trim(const std::string& s) {
    size_t a = 0;
    while (a < s.size() && std::isspace(static_cast<unsigned char>(s[a]))) ++a;
    size_t b = s.size();
    while (b > a && std::isspace(static_cast<unsigned char>(s[b - 1]))) --b;
    return s.substr(a, b - a);
}

// Optional string from a JSON object, or empty if missing / null / wrong type.
std::string optStr(const json& j, const char* key) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null() || !it->is_string()) return {};
    return it->get<std::string>();
}

// Optional number → JSON value (preserves int vs float; returns null when
// missing / not a number).
json optNum(const json& j, const char* key) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null()) return nullptr;
    if (it->is_number()) return *it;
    return nullptr;
}

// Parse LA birthDate (epoch ms number OR ISO string) → "YYYY-MM-DD".
// Returns empty string when neither form is present.
std::string birthDateIso(const json& rec) {
    auto it = rec.find("birthDate");
    if (it == rec.end() || it->is_null()) return {};

    if (it->is_number()) {
        const long long ms = static_cast<long long>(it->get<double>());
        const std::time_t secs = static_cast<std::time_t>(ms / 1000);
        std::tm tm_utc{};
        if (gmtime_r(&secs, &tm_utc) == nullptr) return {};
        char buf[16];
        std::snprintf(buf, sizeof(buf), "%04d-%02d-%02d",
                      tm_utc.tm_year + 1900, tm_utc.tm_mon + 1, tm_utc.tm_mday);
        return std::string(buf);
    }
    if (it->is_string()) {
        const std::string s = it->get<std::string>();
        if (s.size() >= 10) return s.substr(0, 10);
    }
    return {};
}

// Build a Postgres `int[]` literal from a vector of ints.
std::string intArrayLiteral(const std::vector<int>& ids) {
    std::ostringstream os;
    os << '{';
    for (size_t i = 0; i < ids.size(); ++i) {
        if (i) os << ',';
        os << ids[i];
    }
    os << '}';
    return os.str();
}

// Build a Postgres `text[]` literal from a vector of strings.  Each element
// is double-quoted; embedded " or \ are backslash-escaped.  Used to bind the
// LA userId list for the external_person_aliases lookup.
std::string textArrayLiteral(const std::vector<std::string>& items) {
    std::ostringstream os;
    os << '{';
    bool first = true;
    for (const auto& s : items) {
        if (!first) os << ',';
        first = false;
        os << '"';
        for (char c : s) {
            if (c == '"' || c == '\\') os << '\\';
            os << c;
        }
        os << '"';
    }
    os << '}';
    return os.str();
}

// Current UTC time formatted as "YYYY-MM-DDTHH:MM:SS.mmmZ" — matches
// `new Date().toISOString()` in JS so the wire `fetchedAt` is identical.
std::string nowIsoMs() {
    using namespace std::chrono;
    const auto now = system_clock::now();
    const auto t   = system_clock::to_time_t(now);
    const auto ms  = duration_cast<milliseconds>(now.time_since_epoch()) % 1000;
    std::tm tm_utc{};
    gmtime_r(&t, &tm_utc);
    char buf[40];
    std::snprintf(buf, sizeof(buf), "%04d-%02d-%02dT%02d:%02d:%02d.%03lldZ",
                  tm_utc.tm_year + 1900, tm_utc.tm_mon + 1, tm_utc.tm_mday,
                  tm_utc.tm_hour, tm_utc.tm_min, tm_utc.tm_sec,
                  static_cast<long long>(ms.count()));
    return std::string(buf);
}

} // namespace

LaPool::LaPool()
    : db_(Database::getInstance()),
      sync_(std::make_unique<LaProgramSync>()),
      mensProgramId_      (envInt("LEAGUEAPPS_MENS_PROGRAM_ID",        5039300)),
      womensProgramId_    (envInt("LEAGUEAPPS_WOMENS_PROGRAM_ID",      5039340)),
      mensPickupProgramId_(envInt("LEAGUEAPPS_MENS_PICKUP_PROGRAM_ID", 5070075)) {}

LaPool::~LaPool() = default;

int LaPool::envInt(const char* name, int fallback) {
    const char* raw = std::getenv(name);
    if (!raw || !*raw) return fallback;
    try { return std::stoi(raw); }
    catch (const std::exception&) { return fallback; }
}

LaPool::Gender LaPool::parseGender(const std::string& raw) {
    return (raw == "womens") ? Gender::Womens : Gender::Mens;
}

LaPool::Result LaPool::run(int clubId, Gender gender) {
    Result out;

    const int  programId   = (gender == Gender::Womens) ? womensProgramId_ : mensProgramId_;
    const char* genderStr  = (gender == Gender::Womens) ? "womens"         : "mens";

    // 1. Club teams in the requested gender bucket.
    //
    // Every mens/womens team the club owns is eligible for pill toggles,
    // including pool teams (Practice / Pickup) — those are legitimate
    // "internal-roster only" columns on the Lineups screen.  The old
    // name-based exclusion (`^(pickup|training|pool)`) was dropped when
    // Practice / Pickup became first-class mens_team_columns.
    json teamsJson = json::array();
    std::unordered_set<int> clubTeamIds;
    std::unordered_map<int, std::string> teamNameById;
    {
        // Eligibility is driven by team_eligible_genders (migration 105).
        // A team is in the mens (or womens) pool iff it has a matching
        // row in that lookup — coed teams have multiple rows and appear
        // in every gender bucket they accept.
        const std::string sql =
            "SELECT t.id, t.name "
            "  FROM teams t "
            "  JOIN team_eligible_genders teg "
            "    ON teg.team_id = t.id "
            "   AND teg.gender  = $2 "
            " WHERE t.club_id = $1 "
            " ORDER BY t.name";
        const std::vector<std::string> params = {std::to_string(clubId), genderStr};
        const auto rows = db_->query(sql, params);
        for (const auto& row : rows) {
            const int    id   = row["id"].as<int>();
            const std::string name = row["name"].is_null() ? std::string{} : row["name"].c_str();
            json t;
            t["id"]         = id;
            t["name"]       = name;
            t["shortLabel"] = TeamLabel::shortLabel(name);
            teamsJson.push_back(std::move(t));
            clubTeamIds.insert(id);
            teamNameById[id] = name;
        }
    }

    // 2. Sync LA program → local DB.  Returns active userIds + raw recs.
    auto syncResult = sync_->run(programId);

    // Filter active recs while preserving the LA order.  We keep the rec
    // pointer to avoid copying every record again on shaping.
    std::vector<const json*> activeRecs;
    activeRecs.reserve(syncResult.activeUserIds.size());
    {
        // Build a quick lookup of userId → status once; only active ones make
        // it into the shaped output.
        for (const auto& rec : syncResult.recs) {
            std::string uid;
            if (auto it = rec.find("userId"); it != rec.end() && !it->is_null()) {
                if (it->is_string())      uid = it->get<std::string>();
                else if (it->is_number()) uid = std::to_string(static_cast<long long>(it->get<double>()));
            }
            if (uid.empty()) continue;
            if (syncResult.activeUserIds.count(uid) == 0) continue;
            activeRecs.push_back(&rec);
        }
    }

    // 3. Resolve LA userIds → local personId via external_person_aliases.
    std::unordered_map<std::string, int> personIdByLaId;
    std::vector<std::string> laUserIdList(syncResult.activeUserIds.begin(),
                                          syncResult.activeUserIds.end());
    if (!laUserIdList.empty()) {
        const std::string sql =
            "SELECT external_user_id, person_id "
            "  FROM external_person_aliases "
            " WHERE provider = 'leagueapps' "
            "   AND external_user_id = ANY($1::text[])";
        const std::vector<std::string> params = {textArrayLiteral(laUserIdList)};
        const auto rows = db_->query(sql, params);
        for (const auto& row : rows) {
            if (row["external_user_id"].is_null() || row["person_id"].is_null()) continue;
            personIdByLaId.emplace(row["external_user_id"].c_str(), row["person_id"].as<int>());
        }
    }

    // 3a. Filter out anyone currently on a paused-variant LA sub-program.
    // A person is "paused" iff there's an open row in
    // person_la_memberships (`ended_at IS NULL`) pointing at a program
    // whose `leagueapps_programs.variant = 'paused'`.  Paused members
    // are still club members (they show up in the Paused Membership
    // admin screen) but are not eligible for the pool / team rosters.
    std::unordered_set<int> pausedPersonIds;
    if (!personIdByLaId.empty()) {
        std::vector<std::string> personIdStrs;
        personIdStrs.reserve(personIdByLaId.size());
        for (const auto& kv : personIdByLaId) personIdStrs.push_back(std::to_string(kv.second));
        try {
            const std::string sql =
                "SELECT DISTINCT plm.person_id "
                "  FROM person_la_memberships plm "
                "  JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id "
                " WHERE plm.ended_at IS NULL "
                "   AND lp.variant = 'paused' "
                "   AND plm.person_id = ANY($1::int[])";
            const std::vector<std::string> params = { textArrayLiteral(personIdStrs) };
            const auto rows = db_->query(sql, params);
            for (const auto& row : rows) {
                if (row["person_id"].is_null()) continue;
                pausedPersonIds.insert(row["person_id"].as<int>());
            }
        } catch (const std::exception& e) {
            std::cerr << "la-pool paused-filter query failed: " << e.what() << std::endl;
        }
    }

    // 3b. Pool-team auto-assign RETIRED (2026-07-07, migration 107).
    //
    // Practice (908) + Pickup (909) are now UNION teams — their
    // membership is derived from APSL + Liga 1 + Liga 2 + Adult League
    // via team_roster_sources + the v_team_members view.  Writing rows
    // into roster_assignments here would create duplicates the view
    // aggregates against (harmless but wasteful).
    //
    // 3c below still runs, because pickup-only members (LA 5070075) do
    // NOT have a mens home-team assignment — they exist only as direct
    // rows on team 909, which the view surfaces alongside union
    // members.

    if (gender == Gender::Mens && mensPickupProgramId_ > 0) {
        try {
            auto pickupSync = sync_->run(mensPickupProgramId_);
            std::vector<std::string> pickupUids(pickupSync.activeUserIds.begin(),
                                                pickupSync.activeUserIds.end());
            if (!pickupUids.empty()) {
                const std::string sql =
                    "INSERT INTO roster_assignments (domain, leagueapps_user_id, team_id) "
                    "SELECT 'mens', ua.uid::bigint, t.id "
                    "  FROM UNNEST($1::text[]) AS ua(uid) "
                    "  CROSS JOIN teams t "
                    "  JOIN team_eligible_genders teg "
                    "    ON teg.team_id = t.id AND teg.gender = 'mens' "
                    " WHERE t.club_id = $2 "
                    "   AND t.is_pool = true "
                    "   AND t.name = 'Pickup' "
                    "ON CONFLICT (domain, leagueapps_user_id, team_id) WHERE removed_at IS NULL DO NOTHING";
                const std::vector<std::string> params = {
                    textArrayLiteral(pickupUids),
                    std::to_string(clubId),
                };
                db_->query(sql, params);
                // Grant them Pickup-only RSVP eligibility (migration 107).
                // ON CONFLICT DO NOTHING keeps admin overrides intact.
                const std::string elig =
                    "INSERT INTO player_rsvp_eligibility (leagueapps_user_id, team_id) "
                    "SELECT ua.uid::bigint, 909 "
                    "  FROM UNNEST($1::text[]) AS ua(uid) "
                    "ON CONFLICT DO NOTHING";
                db_->query(elig, { textArrayLiteral(pickupUids) });
            }
        } catch (const std::exception& e) {
            std::cerr << "la-pool pickup-tier sync failed (programId="
                      << mensPickupProgramId_ << "): " << e.what() << std::endl;
        }
    }

    // 4. Team-pill state.  `onRosterOn` is the INTERNAL roster (what
    // Lighthouse considers on the team, managed via mens_team_assignments
    // pill toggles).  It is intentionally NOT read from public.rosters —
    // that table now represents the OFFICIAL roster (scraped from league
    // websites or manually entered), which can be empty between seasons
    // even while the internal roster is populated.  Keeping the two
    // separate is what lets a coach build a Practice / Pickup roster
    // without touching the official league listing.
    std::unordered_map<int, std::vector<int>> teamsByPersonId;
    if (!personIdByLaId.empty()) {
        // Build a lookup of LA userId → personId so we can map assignment
        // rows (keyed by leagueapps_user_id) back to a personId.
        std::unordered_map<std::string, int> personIdByLaIdCopy = personIdByLaId;
        std::vector<std::string> laIds;
        laIds.reserve(personIdByLaIdCopy.size());
        for (const auto& kv : personIdByLaIdCopy) laIds.push_back(kv.first);

        const std::string sql =
            "SELECT mta.leagueapps_user_id::text AS lauid, mta.team_id "
            "  FROM roster_assignments mta "
            " WHERE mta.domain = 'mens' "
            "   AND mta.leagueapps_user_id::text = ANY($1::text[])";
        const std::vector<std::string> params = { textArrayLiteral(laIds) };
        const auto rows = db_->query(sql, params);
        for (const auto& row : rows) {
            if (row["team_id"].is_null() || row["lauid"].is_null()) continue;
            const std::string lauid = row["lauid"].c_str();
            const int teamId        = row["team_id"].as<int>();
            if (clubTeamIds.count(teamId) == 0) continue;
            auto it = personIdByLaIdCopy.find(lauid);
            if (it == personIdByLaIdCopy.end()) continue;
            teamsByPersonId[it->second].push_back(teamId);
        }
    }

    // 5. Shape one row per active registrant; sort lastName,firstName CI.
    struct Shaped {
        json   row;
        std::string lastKey;
        std::string firstKey;
    };
    std::vector<Shaped> shaped;
    shaped.reserve(activeRecs.size());

    for (const json* recPtr : activeRecs) {
        const json& rec = *recPtr;

        std::string uid;
        if (auto it = rec.find("userId"); it != rec.end() && !it->is_null()) {
            if (it->is_string())      uid = it->get<std::string>();
            else if (it->is_number()) uid = std::to_string(static_cast<long long>(it->get<double>()));
        }

        json personIdJson = nullptr;
        if (auto pit = personIdByLaId.find(uid); pit != personIdByLaId.end()) {
            personIdJson = pit->second;
        }

        // Skip anyone currently on a paused-variant sub-program (see 3a).
        // Paused members are still club members (visible in the Paused
        // Membership screen) but are excluded from the LA pool.
        if (!personIdJson.is_null() &&
            pausedPersonIds.count(personIdJson.get<int>())) {
            continue;
        }

        const std::string first = trim(optStr(rec, "firstName"));
        const std::string last  = trim(optStr(rec, "lastName"));
        const std::string bd    = birthDateIso(rec);

        json onRoster = json::array();
        if (!personIdJson.is_null()) {
            if (auto tit = teamsByPersonId.find(personIdJson.get<int>()); tit != teamsByPersonId.end()) {
                for (int tid : tit->second) onRoster.push_back(tid);
            }
        }

        // registrationId falls back to top-level `id` (LA exports use both).
        json regId = nullptr;
        if (auto it = rec.find("registrationId"); it != rec.end() && !it->is_null()) regId = *it;
        else if (auto it = rec.find("id");        it != rec.end() && !it->is_null()) regId = *it;

        json row;
        row["personId"]            = personIdJson;
        row["firstName"]           = first;
        row["lastName"]            = last;
        row["birthDate"]           = bd.empty() ? json(nullptr) : json(bd);
        row["leagueAppsUserId"]    = uid;
        row["unmatched"]           = personIdJson.is_null();
        row["onRosterOn"]          = std::move(onRoster);
        row["registrationId"]      = regId;
        row["registrationStatus"]  = optStr(rec, "registrationStatus").empty() ? json(nullptr) : json(optStr(rec, "registrationStatus"));
        row["programName"]         = optStr(rec, "programName").empty()        ? json(nullptr) : json(optStr(rec, "programName"));
        row["role"]                = optStr(rec, "role").empty()               ? json(nullptr) : json(optStr(rec, "role"));
        row["season"]              = optStr(rec, "season").empty()             ? json(nullptr) : json(optStr(rec, "season"));
        row["gender"]              = optStr(rec, "gender").empty()             ? json(nullptr) : json(optStr(rec, "gender"));
        row["email"]               = optStr(rec, "email").empty()              ? json(nullptr) : json(optStr(rec, "email"));
        row["phone"]               = optStr(rec, "phone").empty()              ? json(nullptr) : json(optStr(rec, "phone"));
        row["paymentStatus"]       = optStr(rec, "paymentStatus").empty()      ? json(nullptr) : json(optStr(rec, "paymentStatus"));
        row["outstandingBalance"]  = optNum(rec, "outstandingBalance");

        shaped.push_back({std::move(row), toLowerAscii(last), toLowerAscii(first)});
    }

    std::sort(shaped.begin(), shaped.end(), [](const Shaped& a, const Shaped& b) {
        if (a.lastKey != b.lastKey)   return a.lastKey  < b.lastKey;
        return a.firstKey < b.firstKey;
    });

    json personsJson = json::array();
    personsJson.get_ptr<json::array_t*>()->reserve(shaped.size());
    for (auto& s : shaped) personsJson.push_back(std::move(s.row));

    // 6. Best-effort DOB backfill — UPDATE only NULL local DOBs from LA.
    //    Single statement, runs synchronously (the connection pool handles
    //    concurrency); failures are logged but do not fail the request.
    try {
        std::vector<std::pair<int, std::string>> backfillRows;
        backfillRows.reserve(personsJson.size());
        for (const auto& p : personsJson) {
            if (p.at("personId").is_null()) continue;
            if (p.at("birthDate").is_null()) continue;
            backfillRows.emplace_back(p.at("personId").get<int>(),
                                      p.at("birthDate").get<std::string>());
        }
        if (!backfillRows.empty()) {
            std::ostringstream sql;
            sql << "UPDATE persons SET birth_date = data.bd::date, updated_at = NOW() "
                << "  FROM (VALUES ";
            std::vector<std::string> params;
            params.reserve(backfillRows.size() * 2);
            for (size_t i = 0; i < backfillRows.size(); ++i) {
                if (i) sql << ',';
                sql << "($" << (i * 2 + 1) << "::int, $" << (i * 2 + 2) << "::text)";
                params.push_back(std::to_string(backfillRows[i].first));
                params.push_back(backfillRows[i].second);
            }
            sql << ") AS data(pid, bd) "
                << " WHERE persons.id = data.pid AND persons.birth_date IS NULL";
            db_->query(sql.str(), params);
        }
    } catch (const std::exception& e) {
        std::cerr << "la-pool DOB backfill failed: " << e.what() << std::endl;
    }

    out.body["teams"]         = std::move(teamsJson);
    out.body["persons"]       = std::move(personsJson);
    out.body["sourceProgram"] = programId;
    out.body["fetchedAt"]     = nowIsoMs();
    return out;
}
