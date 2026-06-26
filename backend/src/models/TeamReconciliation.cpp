#include "TeamReconciliation.h"
#include "PersonLinker.h"
#include "../database/Database.h"
#include "../services/GroupMeService.h"
#include "../services/LeagueAppsService.h"
#include <algorithm>
#include <cctype>
#include <cstdlib>
#include <iostream>
#include <set>

using nlohmann::json;

namespace {

constexpr int kProviderGroupMe = 1;

int envInt(const char* name, int fallback) {
    const char* v = std::getenv(name);
    if (!v || !*v) return fallback;
    try { return std::stoi(v); } catch (...) { return fallback; }
}

// Build a Postgres TEXT[] literal from a vector of strings.  We need a
// literal (not a parameterised array) because Database::query() only
// accepts string params; the existing Node SQL passes the array via $2.
// Format: {"a","b","c"} with internal " and \ properly escaped.
std::string toPgTextArray(const std::vector<std::string>& items) {
    std::string out = "{";
    bool first = true;
    for (const auto& s : items) {
        if (!first) out += ',';
        first = false;
        out += '"';
        for (char c : s) {
            if (c == '\\' || c == '"') out += '\\';
            out += c;
        }
        out += '"';
    }
    out += '}';
    return out;
}

std::string jsonStringOrEmpty(const json& v) {
    if (v.is_string()) return v.get<std::string>();
    if (v.is_number()) return std::to_string(v.get<long long>());
    return {};
}

std::string upperAscii(std::string s) {
    for (auto& c : s) c = static_cast<char>(std::toupper(static_cast<unsigned char>(c)));
    return s;
}

} // namespace

TeamReconciliation::TeamReconciliation()
    : db_(Database::getInstance())
    , linker_(std::make_unique<PersonLinker>())
    , mensClubId_(envInt("LEAGUEAPPS_MENS_CLUB_ID", 134))
    , mensProgramId_(envInt("LEAGUEAPPS_MENS_PROGRAM_ID", 5039300)) {}

// Out-of-line so the unique_ptr<PersonLinker> sees the full type when it
// destructs.
TeamReconciliation::~TeamReconciliation() = default;

// ────────────────────────────────────────────────────────────────────────────
// PUBLIC ENTRY POINT
// ────────────────────────────────────────────────────────────────────────────
TeamReconciliation::Result TeamReconciliation::run(int teamId) {
    Result out;
    out.body = json::object();

    // Step 1: GroupMe live refresh.
    auto gmReports = refreshGroupMeChats(teamId);

    // Step 2: LA live refresh (mens only).
    std::optional<LaSnapshot> la;
    json laTelemetry;
    if (teamIsMens(teamId)) {
        try {
            la = syncMensLa();
            laTelemetry = json{
                {"ok", true},
                {"activeCount", la ? la->activeUserIds.size() : 0},
            };
        } catch (const std::exception& e) {
            std::cerr << "[reconciliation team=" << teamId
                      << "] LA fetch failed: " << e.what()
                      << " — proceeding with empty LA set" << std::endl;
            la = LaSnapshot{}; // empty, supported=true (we tried)
            laTelemetry = json{
                {"ok", false},
                {"error", e.what()},
                {"activeCount", 0},
            };
        }
    } else {
        laTelemetry = json{
            {"skipped", true},
            {"reason", "team not classified as mens"},
        };
    }

    // Step 3: auto-marry unlinked GM chat members by name.
    const int autoMarried = autoMarryGmChatMembers(teamId);
    if (autoMarried > 0) {
        std::cerr << "[gm-auto-marry] team " << teamId
                  << ": linked " << autoMarried << " chat member(s) by name"
                  << std::endl;
    }

    // Step 4: bucketing — populates players/coaches/laOnly/gmOnly.
    bucketTeamPersons(teamId, la, out.body);

    // Step 5: unlinked chat members surfaced as their own array.
    out.body["unlinkedChatMembers"] = unlinkedChatMembers(teamId);

    // Final assembly.
    out.body["teamId"]    = teamId;
    out.body["supported"] = la.has_value();

    json gmTelemetry = json::array();
    for (const auto& r : gmReports) {
        json e = {
            {"chatId",      r.chatId},
            {"externalId",  r.externalId},
            {"ok",          r.ok},
        };
        if (r.ok) {
            e["nameChanged"] = r.nameChanged;
            e["added"]       = r.added;
            e["kept"]        = r.kept;
            e["removed"]     = r.removed;
        } else {
            e["error"] = r.error;
        }
        gmTelemetry.push_back(std::move(e));
    }
    out.body["refresh"] = {
        {"groupme",       gmTelemetry},
        {"leagueapps",    laTelemetry},
        {"gmAutoMarried", autoMarried},
    };

    return out;
}

// ────────────────────────────────────────────────────────────────────────────
// STEP 1 — GROUPME REFRESH
// ────────────────────────────────────────────────────────────────────────────
std::vector<TeamReconciliation::ChatRefreshReport>
TeamReconciliation::refreshGroupMeChats(int teamId) {
    std::vector<ChatRefreshReport> out;

    auto rs = db_->query(
        "SELECT c.id AS chat_id, c.name AS current_name, ci.external_id "
        "  FROM chats c "
        "  JOIN chat_integrations ci ON ci.chat_id = c.id "
        " WHERE c.team_id = $1 "
        "   AND COALESCE(c.is_active, true) "
        "   AND ci.provider_id = $2 "
        " ORDER BY ci.is_primary DESC NULLS LAST, c.id",
        {std::to_string(teamId), std::to_string(kProviderGroupMe)});

    for (const auto& row : rs) {
        const int         chatId      = row["chat_id"].as<int>();
        const std::string externalId  = row["external_id"].is_null() ? "" : row["external_id"].as<std::string>();
        const std::string currentName = row["current_name"].is_null() ? "" : row["current_name"].as<std::string>();
        out.push_back(refreshOneChat(chatId, externalId, currentName));
    }
    return out;
}

TeamReconciliation::ChatRefreshReport
TeamReconciliation::refreshOneChat(int chatId,
                                   const std::string& externalId,
                                   const std::string& currentName) {
    ChatRefreshReport rep;
    rep.chatId      = chatId;
    rep.externalId  = externalId;

    if (externalId.empty()) {
        rep.ok = false;
        rep.error = "missing external_id";
        return rep;
    }

    try {
        const auto group = GroupMeService::getInstance().fetchGroup(externalId);

        // 1. Update chat display name if drifted.
        if (!group.name.empty() && group.name != currentName) {
            db_->query("UPDATE chats SET name = $1 WHERE id = $2",
                       {group.name, std::to_string(chatId)});
            rep.nameChanged = true;
        }

        // 2. Build lookup maps for person_id resolution.
        std::vector<std::string> liveIds;
        liveIds.reserve(group.members.size());
        for (const auto& m : group.members) liveIds.push_back(m.userId);

        std::map<std::string, int> existingThisChat;
        std::map<std::string, int> otherChat;
        std::map<std::string, int> aliasMap;

        if (!liveIds.empty()) {
            const std::string arrLit = toPgTextArray(liveIds);

            auto r1 = db_->query(
                "SELECT external_user_id, person_id FROM chat_external_members "
                "WHERE chat_id = $1 AND provider_id = $2 "
                "  AND external_user_id = ANY($3::text[])",
                {std::to_string(chatId), std::to_string(kProviderGroupMe), arrLit});
            for (const auto& row : r1) {
                if (row["person_id"].is_null()) continue;
                existingThisChat[row["external_user_id"].as<std::string>()]
                    = row["person_id"].as<int>();
            }

            auto r2 = db_->query(
                "SELECT DISTINCT ON (external_user_id) external_user_id, person_id "
                "  FROM chat_external_members "
                " WHERE provider_id = $1 "
                "   AND person_id IS NOT NULL "
                "   AND external_user_id = ANY($2::text[]) "
                " ORDER BY external_user_id, chat_id",
                {std::to_string(kProviderGroupMe), arrLit});
            for (const auto& row : r2) {
                otherChat[row["external_user_id"].as<std::string>()]
                    = row["person_id"].as<int>();
            }

            auto r3 = db_->query(
                "SELECT external_user_id, person_id FROM external_person_aliases "
                "WHERE provider = 'groupme' AND external_user_id = ANY($1::text[])",
                {arrLit});
            for (const auto& row : r3) {
                aliasMap[row["external_user_id"].as<std::string>()]
                    = row["person_id"].as<int>();
            }
        }

        // 3. Upsert every live member.
        for (const auto& m : group.members) {
            int personId = 0;
            auto it = existingThisChat.find(m.userId);
            if (it != existingThisChat.end()) personId = it->second;
            else if ((it = otherChat.find(m.userId)) != otherChat.end()) personId = it->second;
            else if ((it = aliasMap.find(m.userId)) != aliasMap.end())   personId = it->second;

            // NULLIF on the person_id param so it goes in as NULL when unset.
            auto r = db_->query(
                "INSERT INTO chat_external_members "
                "  (chat_id, provider_id, external_user_id, external_username, image_url, person_id, synced_at) "
                "VALUES ($1, $2, $3, NULLIF($4, ''), NULLIF($5, ''), NULLIF($6, '')::int, NOW()) "
                "ON CONFLICT (chat_id, provider_id, external_user_id) "
                "DO UPDATE SET external_username = EXCLUDED.external_username, "
                "              image_url = COALESCE(EXCLUDED.image_url, chat_external_members.image_url), "
                "              person_id = COALESCE(chat_external_members.person_id, EXCLUDED.person_id), "
                "              synced_at = NOW() "
                "RETURNING (xmax = 0) AS is_insert",
                {std::to_string(chatId),
                 std::to_string(kProviderGroupMe),
                 m.userId,
                 m.nickname,
                 m.imageUrl,
                 personId > 0 ? std::to_string(personId) : std::string{}});
            if (!r.empty() && !r[0]["is_insert"].is_null() && r[0]["is_insert"].as<bool>()) {
                rep.added++;
            } else {
                rep.kept++;
            }
        }

        // 4. Delete rows for users no longer in the chat.
        if (!liveIds.empty()) {
            const std::string arrLit = toPgTextArray(liveIds);
            auto d = db_->query(
                "DELETE FROM chat_external_members "
                "WHERE chat_id = $1 AND provider_id = $2 "
                "  AND NOT (external_user_id = ANY($3::text[]))",
                {std::to_string(chatId), std::to_string(kProviderGroupMe), arrLit});
            rep.removed = static_cast<int>(d.affected_rows());
        }

        // 5. Stamp last_synced_at on chat_integrations.
        db_->query(
            "UPDATE chat_integrations SET last_synced_at = NOW(), external_name = $1 "
            "WHERE chat_id = $2 AND provider_id = $3",
            {group.name, std::to_string(chatId), std::to_string(kProviderGroupMe)});

        rep.ok = true;
        return rep;

    } catch (const std::exception& e) {
        std::cerr << "[gm-refresh] chat " << chatId << " (gm=" << externalId << ") failed: "
                  << e.what() << " — falling back to cached members" << std::endl;
        rep.ok = false;
        rep.error = e.what();
        return rep;
    }
}

// ────────────────────────────────────────────────────────────────────────────
// STEP 2 — LA REFRESH
// ────────────────────────────────────────────────────────────────────────────
bool TeamReconciliation::teamIsMens(int teamId) {
    auto rs = db_->query(
        "SELECT EXISTS ( "
        "  SELECT 1 FROM teams "
        "   WHERE id = $1 AND club_id = $2 "
        "     AND name !~* '(women|pickup|training|pool)' "
        ") AS is_mens",
        {std::to_string(teamId), std::to_string(mensClubId_)});
    return !rs.empty() && rs[0]["is_mens"].as<bool>();
}

std::optional<TeamReconciliation::LaSnapshot>
TeamReconciliation::syncMensLa() {
    const auto recs = LeagueAppsService::getInstance()
                          .fetchProgramRegistrations(mensProgramId_);

    LaSnapshot snap;
    for (const auto& rec : recs) {
        std::string status;
        if (rec.contains("registrationStatus") && rec["registrationStatus"].is_string()) {
            status = upperAscii(rec["registrationStatus"].get<std::string>());
        }
        std::string uid = rec.contains("userId") ? jsonStringOrEmpty(rec["userId"]) : "";
        if (uid.empty() && rec.contains("memberId")) uid = jsonStringOrEmpty(rec["memberId"]);
        if (uid.empty()) continue;

        snap.statusByUser[uid] = status;
        if (status != "SPOT_RESERVED" && status != "SPOT_PENDING") continue;
        snap.activeUserIds.push_back(uid);

        // Self-heal persons + alias for every active record (idempotent).
        try {
            auto r = linker_->linkLa(rec);
            if (!r.skipReason.empty()) {
                std::cerr << "[la-sync program=" << mensProgramId_
                          << "] linkLa skipped userId=" << uid
                          << ": " << r.skipReason << std::endl;
            }
        } catch (const std::exception& e) {
            std::cerr << "[la-sync program=" << mensProgramId_
                      << "] linkLa failed userId=" << uid << ": "
                      << e.what() << std::endl;
        }
    }

    // De-dupe activeUserIds (a user can be in recs multiple times across pages
    // pre-dedupe; service already de-dupes by registrationId but the same user
    // can hold two registrations).
    std::sort(snap.activeUserIds.begin(), snap.activeUserIds.end());
    snap.activeUserIds.erase(std::unique(snap.activeUserIds.begin(),
                                         snap.activeUserIds.end()),
                             snap.activeUserIds.end());
    return snap;
}

// ────────────────────────────────────────────────────────────────────────────
// STEP 3 — AUTO-MARRY UNLINKED GM CHAT MEMBERS
// ────────────────────────────────────────────────────────────────────────────
int TeamReconciliation::autoMarryGmChatMembers(int teamId) {
    auto rs = db_->query(
        "WITH cand AS ("
        "  SELECT cem.chat_id, cem.provider_id, cem.external_user_id, "
        "         BTRIM(cem.external_username) AS uname "
        "    FROM chat_external_members cem "
        "    JOIN chats c ON c.id = cem.chat_id AND c.team_id = $1 "
        "   WHERE cem.provider_id = 1 "
        "     AND cem.person_id IS NULL "
        "     AND cem.external_username IS NOT NULL "
        "     AND array_length(string_to_array(BTRIM(cem.external_username), ' '), 1) = 2 "
        "), "
        "matched AS ("
        "  SELECT cand.chat_id, cand.provider_id, cand.external_user_id, p.id AS person_id "
        "    FROM cand "
        "    JOIN persons p "
        "      ON LOWER(p.first_name) = LOWER(SPLIT_PART(cand.uname, ' ', 1)) "
        "     AND LOWER(p.last_name)  = LOWER(SPLIT_PART(cand.uname, ' ', 2)) "
        ") "
        "UPDATE chat_external_members cem "
        "   SET person_id = m.person_id "
        "  FROM matched m "
        " WHERE cem.chat_id          = m.chat_id "
        "   AND cem.provider_id      = m.provider_id "
        "   AND cem.external_user_id = m.external_user_id "
        " RETURNING cem.external_user_id",
        {std::to_string(teamId)});
    return static_cast<int>(rs.size());
}

// ────────────────────────────────────────────────────────────────────────────
// STEP 4 — BUCKETING
// ────────────────────────────────────────────────────────────────────────────
void TeamReconciliation::bucketTeamPersons(int teamId,
                                           const std::optional<LaSnapshot>& la,
                                           json& out) {
    // Out shape preallocated even on the empty path so the response is stable.
    out["players"] = json::array();
    out["coaches"] = json::array();
    out["laOnly"]  = json::array();
    out["gmOnly"]  = json::array();

    const std::string laArrLit = la ? toPgTextArray(la->activeUserIds)
                                    : toPgTextArray({});

    auto rs = db_->query(
        "WITH chat_for_team AS ("
        "  SELECT id AS chat_id FROM chats "
        "   WHERE team_id = $1 AND COALESCE(is_active, true) "
        "   ORDER BY id DESC LIMIT 1 "
        "), "
        "la_persons AS ("
        "  SELECT epa.person_id, "
        "         epa.external_user_id AS leagueapps_user_id, "
        "         COALESCE(BOOL_OR(mta.on_roster), false) AS on_roster "
        "    FROM external_person_aliases epa "
        "    LEFT JOIN mens_team_assignments mta "
        "      ON mta.leagueapps_user_id::text = epa.external_user_id "
        "     AND mta.team_id = $1 "
        "   WHERE epa.provider = 'leagueapps' "
        "     AND epa.external_user_id = ANY($2::text[]) "
        "     AND epa.person_id IS NOT NULL "
        "   GROUP BY epa.person_id, epa.external_user_id "
        "), "
        "gm_persons AS ("
        "  SELECT DISTINCT ON (cem.person_id) "
        "         cem.person_id, "
        "         cem.external_user_id  AS chat_user_id, "
        "         cem.external_username AS chat_display_name "
        "    FROM chat_external_members cem "
        "    JOIN chat_for_team cft ON cem.chat_id = cft.chat_id "
        "   WHERE cem.person_id IS NOT NULL AND cem.provider_id = 1 "
        "), "
        "coach_persons AS ("
        "  SELECT DISTINCT c.person_id "
        "    FROM team_coaches tc "
        "    JOIN coaches c ON c.id = tc.coach_id "
        "   WHERE tc.team_id = $1 AND tc.ended_at IS NULL "
        "), "
        "all_persons AS ("
        "  SELECT person_id FROM la_persons UNION "
        "  SELECT person_id FROM gm_persons UNION "
        "  SELECT person_id FROM coach_persons "
        ") "
        "SELECT p.id AS person_id, p.first_name, p.last_name, "
        "       p.birth_date::text AS birth_date, "
        "       la.leagueapps_user_id::text AS leagueapps_user_id, "
        "       la.on_roster AS la_on_roster, "
        "       gm.chat_user_id, gm.chat_display_name, "
        "       (cp.person_id IS NOT NULL) AS is_coach, "
        "       CASE "
        "         WHEN cp.person_id IS NOT NULL THEN 'coach' "
        "         WHEN la.person_id IS NOT NULL AND gm.person_id IS NOT NULL THEN 'player' "
        "         WHEN la.person_id IS NOT NULL THEN 'laOnly' "
        "         WHEN gm.person_id IS NOT NULL THEN 'gmOnly' "
        "       END AS bucket "
        "  FROM all_persons ap "
        "  JOIN persons p ON p.id = ap.person_id "
        "  LEFT JOIN la_persons la ON la.person_id = p.id "
        "  LEFT JOIN gm_persons gm ON gm.person_id = p.id "
        "  LEFT JOIN coach_persons cp ON cp.person_id = p.id "
        " ORDER BY p.last_name NULLS LAST, p.first_name NULLS LAST",
        {std::to_string(teamId), laArrLit});

    for (const auto& row : rs) {
        json entry = json::object();
        entry["personId"]  = row["person_id"].as<int>();
        entry["firstName"] = row["first_name"].is_null() ? json(nullptr) : json(row["first_name"].as<std::string>());
        entry["lastName"]  = row["last_name"].is_null()  ? json(nullptr) : json(row["last_name"].as<std::string>());
        entry["birthDate"] = row["birth_date"].is_null() ? json(nullptr) : json(row["birth_date"].as<std::string>());

        std::string laUid;
        if (!row["leagueapps_user_id"].is_null()) laUid = row["leagueapps_user_id"].as<std::string>();
        entry["leagueAppsUserId"] = laUid.empty() ? json(nullptr) : json(laUid);

        entry["laOnRoster"] = row["la_on_roster"].is_null() ? false : row["la_on_roster"].as<bool>();

        if (la && !laUid.empty()) {
            auto it = la->statusByUser.find(laUid);
            entry["laStatus"] = (it != la->statusByUser.end()) ? json(it->second) : json(nullptr);
        } else {
            entry["laStatus"] = nullptr;
        }

        entry["chatUserId"]      = row["chat_user_id"].is_null()      ? json(nullptr) : json(row["chat_user_id"].as<std::string>());
        entry["chatDisplayName"] = row["chat_display_name"].is_null() ? json(nullptr) : json(row["chat_display_name"].as<std::string>());
        entry["isCoach"]         = row["is_coach"].as<bool>();

        const std::string bucket = row["bucket"].is_null() ? "" : row["bucket"].as<std::string>();
        if      (bucket == "coach")  out["coaches"].push_back(std::move(entry));
        else if (bucket == "player") out["players"].push_back(std::move(entry));
        else if (bucket == "laOnly") out["laOnly" ].push_back(std::move(entry));
        else if (bucket == "gmOnly") out["gmOnly" ].push_back(std::move(entry));
    }
}

// ────────────────────────────────────────────────────────────────────────────
// STEP 5 — UNLINKED CHAT MEMBERS
// ────────────────────────────────────────────────────────────────────────────
nlohmann::json TeamReconciliation::unlinkedChatMembers(int teamId) {
    auto rs = db_->query(
        "SELECT cem.chat_id, cem.external_user_id, cem.external_username, cem.image_url "
        "  FROM chat_external_members cem "
        "  JOIN chats c ON c.id = cem.chat_id "
        " WHERE c.team_id = $1 "
        "   AND COALESCE(c.is_active, true) "
        "   AND cem.provider_id = 1 "
        "   AND cem.person_id IS NULL "
        " ORDER BY cem.external_username NULLS LAST, cem.external_user_id",
        {std::to_string(teamId)});

    json out = json::array();
    for (const auto& row : rs) {
        json e = json::object();
        e["chatId"]          = row["chat_id"].as<int>();
        e["externalUserId"]  = row["external_user_id"].is_null() ? json(nullptr) : json(row["external_user_id"].as<std::string>());
        e["chatDisplayName"] = row["external_username"].is_null() ? json(nullptr) : json(row["external_username"].as<std::string>());
        e["imageUrl"]        = row["image_url"].is_null()         ? json(nullptr) : json(row["image_url"].as<std::string>());
        out.push_back(std::move(e));
    }
    return out;
}
