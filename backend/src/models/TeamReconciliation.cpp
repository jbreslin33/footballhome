#include "TeamReconciliation.h"
#include "PersonLinker.h"
#include "../database/Database.h"
#include "../services/LeagueAppsService.h"
#include <algorithm>
#include <cctype>
#include <cstdlib>
#include <iostream>

using nlohmann::json;

namespace {

int envInt(const char* name, int fallback) {
    const char* v = std::getenv(name);
    if (!v || !*v) return fallback;
    try { return std::stoi(v); } catch (...) { return fallback; }
}

// Build a Postgres TEXT[] literal from a vector of strings.
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

TeamReconciliation::~TeamReconciliation() = default;

// ────────────────────────────────────────────────────────────────────────────
// PUBLIC ENTRY POINT
// ────────────────────────────────────────────────────────────────────────────
TeamReconciliation::Result TeamReconciliation::run(int teamId) {
    Result out;
    out.body = json::object();

    // Step 1: LA live refresh (mens only).
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
            la = LaSnapshot{};
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

    // Step 2: bucketing — populates players/coaches/laOnly.
    bucketTeamPersons(teamId, la, out.body);

    out.body["teamId"]    = teamId;
    out.body["supported"] = la.has_value();
    out.body["refresh"] = {
        {"leagueapps",    laTelemetry},
    };

    return out;
}

// ────────────────────────────────────────────────────────────────────────────
// LA REFRESH
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

    std::sort(snap.activeUserIds.begin(), snap.activeUserIds.end());
    snap.activeUserIds.erase(std::unique(snap.activeUserIds.begin(),
                                         snap.activeUserIds.end()),
                             snap.activeUserIds.end());
    return snap;
}

// ────────────────────────────────────────────────────────────────────────────
// BUCKETING
// ────────────────────────────────────────────────────────────────────────────
void TeamReconciliation::bucketTeamPersons(int teamId,
                                           const std::optional<LaSnapshot>& la,
                                           json& out) {
    out["players"] = json::array();
    out["coaches"] = json::array();
    out["laOnly"]  = json::array();

    const std::string laArrLit = la ? toPgTextArray(la->activeUserIds)
                                    : toPgTextArray({});

    auto rs = db_->query(
        "WITH la_persons AS ("
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
        "coach_persons AS ("
        "  SELECT DISTINCT c.person_id "
        "    FROM team_coaches tc "
        "    JOIN coaches c ON c.id = tc.coach_id "
        "   WHERE tc.team_id = $1 AND tc.ended_at IS NULL "
        "), "
        "all_persons AS ("
        "  SELECT person_id FROM la_persons UNION "
        "  SELECT person_id FROM coach_persons "
        ") "
        "SELECT p.id AS person_id, p.first_name, p.last_name, "
        "       p.birth_date::text AS birth_date, "
        "       la.leagueapps_user_id::text AS leagueapps_user_id, "
        "       la.on_roster AS la_on_roster, "
        "       (cp.person_id IS NOT NULL) AS is_coach, "
        "       CASE "
        "         WHEN cp.person_id IS NOT NULL THEN 'coach' "
        "         WHEN la.person_id IS NOT NULL THEN 'laOnly' "
        "       END AS bucket "
        "  FROM all_persons ap "
        "  JOIN persons p ON p.id = ap.person_id "
        "  LEFT JOIN la_persons la ON la.person_id = p.id "
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

        entry["isCoach"] = row["is_coach"].as<bool>();

        const std::string bucket = row["bucket"].is_null() ? "" : row["bucket"].as<std::string>();
        if      (bucket == "coach")  out["coaches"].push_back(std::move(entry));
        else if (bucket == "laOnly") out["laOnly" ].push_back(std::move(entry));
    }
}
