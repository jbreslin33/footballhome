#include "ClubRostersController.h"

#include <cctype>
#include <iostream>
#include <sstream>
#include <unordered_map>
#include <vector>

#include "../database/Database.h"
#include "../models/BoysRoster.h"
#include "../models/MensRoster.h"
#include "../models/MensTeamAssignments.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

std::string jsonEscape(const std::string& s) {
    return json(s).dump();
}

Response jsonErr(HttpStatus status, const std::string& msg) {
    std::ostringstream body;
    body << "{\"error\":" << jsonEscape(msg) << "}";
    return Response(status, body.str());
}

Response badRequest(const std::string& msg)  { return jsonErr(HttpStatus::BAD_REQUEST, msg); }
Response notFound  (const std::string& msg)  { return jsonErr(HttpStatus::NOT_FOUND,   msg); }
Response internalErr(const std::string& msg) { return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR, msg); }

// Tolerant int extractor: accepts number or numeric string from JSON body.
// Mirrors readInt in MensRosterController.cpp so the chip-toggle POST
// contract is identical across the master + per-domain boards.
bool readInt(const json& j, const char* key, long long& out) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null()) return false;
    if (it->is_number_integer())  { out = it->get<long long>(); return true; }
    if (it->is_number_unsigned()) { out = static_cast<long long>(it->get<unsigned long long>()); return true; }
    if (it->is_number_float())    { out = static_cast<long long>(it->get<double>()); return true; }
    if (it->is_string()) {
        try { out = std::stoll(it->get<std::string>()); return true; }
        catch (const std::exception&) { return false; }
    }
    return false;
}

std::string readStr(const json& j, const char* key) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null() || !it->is_string()) return {};
    return it->get<std::string>();
}

// Tolerant bool extractor: accepts boolean, number, or string form
// ("true"/"1").  Mirrors readBool in MensRosterController.cpp.
bool readBool(const json& j, const char* key, bool fallback) {
    auto it = j.find(key);
    if (it == j.end() || it->is_null()) return fallback;
    if (it->is_boolean()) return it->get<bool>();
    if (it->is_number())  return it->get<double>() != 0.0;
    if (it->is_string()) {
        const std::string s = it->get<std::string>();
        return s == "true" || s == "1";
    }
    return fallback;
}

// Resolves the domain (mens|boys|girls|womens) for a target team by
// looking up its roster_columns row.  Returns empty string when no
// column exists — caller should 404 the request in that case (pool
// teams and archived columns fall in here).
std::string resolveDomainForTeam(Database* db, int teamId) {
    auto rows = db->query(
        "SELECT domain FROM roster_columns "
        " WHERE team_id = $1 AND archived_at IS NULL LIMIT 1",
        {std::to_string(teamId)}
    );
    if (rows.empty() || rows[0]["domain"].is_null()) return {};
    return rows[0]["domain"].as<std::string>();
}

// The set of keys that MensRoster injects onto each mens player and
// which the frontend expects in "column" view for the mens board.
// Kept as a data list so it's cheap to add / remove fields as the
// mens board evolves — the merge step below is a straight loop.
const std::vector<std::string> kMensBillingKeys = {
    "daysOverdue",
    "delinquencyState",
    "nextBillDate",
    "nextBillAmount",
    "isDefault",
    "lastPayReminder",
    "lastPaidAmount",
    "lastPaidAt",
    "lastPaidType",
    "lastPayments",
    "paymentsWindow",
    "paymentsWindowStart",
    "paymentsWindowTotal",
    "outstandingBalance",   // LA balance may lag payments; useful for UI cross-check
    "paymentStatus",
    "laRegisteredAt",
    "fhLastActivityAt",
    "email",
    "phone",
    "registrationId",
};

// enrichWithMensBilling — merges billing + LA fields from MensRoster
// into the ClubRosters payload for people who have a mens assignment.
//
// Why we call the whole mens model instead of duplicating the SQL:
//   The mens billing rules are intricate ($99 covers 3 months, same-
//   month $35 covers the current month, hold days env override, etc)
//   and evolve regularly.  Refactoring them into a shared helper
//   would require touching a stable file for zero net functionality
//   gain; instead we treat MensRoster as the source of truth and
//   consume it here.  Cost: one extra json parse + dictionary
//   traversal per GET.  The MensRoster instance caches the LA fetch
//   internally, so we don't pay a 15-second sync fee per request.
//
// Failure handling:
//   If MensRoster returns an error (LA outage with cold cache, DB
//   blip), we log and return early.  The base payload is still
//   emitted — the mens billing chips just won't render.  Better than
//   failing the whole club-rosters GET on a transient LA hiccup.
void enrichWithMensBilling(json& payload, MensRoster* mens) {
    if (!mens) return;
    if (!payload.contains("people") || !payload["people"].is_array()) return;

    MensRoster::Result mensRes;
    try {
        mensRes = mens->run(/*includeAll=*/true, /*refreshLa=*/false);
    } catch (const std::exception& e) {
        std::cerr << "ClubRosters: mens billing enrichment threw: "
                  << e.what() << std::endl;
        return;
    }
    if (!mensRes.error.empty()) {
        std::cerr << "ClubRosters: mens billing enrichment error: "
                  << mensRes.error << " (skipping merge)" << std::endl;
        return;
    }

    // Build a flat index of leagueAppsUserId -> shaped mens player.
    // The mens payload lists players in two places: `unassigned` (flat
    // array) and `buckets` (object keyed by teamId -> array).  We walk
    // both so any mens registrant with a valid LA user id shows up.
    std::unordered_map<std::string, const json*> byUid;
    auto indexArr = [&](const json& arr) {
        if (!arr.is_array()) return;
        for (const auto& p : arr) {
            auto it = p.find("leagueAppsUserId");
            if (it == p.end() || it->is_null()) continue;
            std::string uid;
            if (it->is_number_integer())  uid = std::to_string(it->get<long long>());
            else if (it->is_string())     uid = it->get<std::string>();
            else continue;
            if (uid.empty()) continue;
            byUid[uid] = &p;
        }
    };
    if (mensRes.body.contains("unassigned")) indexArr(mensRes.body["unassigned"]);
    if (mensRes.body.contains("buckets")) {
        for (auto it = mensRes.body["buckets"].begin();
             it != mensRes.body["buckets"].end(); ++it) {
            indexArr(it.value());
        }
    }

    // Merge billing keys onto each person in the base payload whose
    // leagueAppsUserId is present in the index AND who has at least
    // one assignment in the mens domain.  The domain check keeps a
    // youth player with a legacy LA mens registration from getting
    // mens billing chips on their boys-domain card.
    for (auto& person : payload["people"]) {
        auto laIt = person.find("leagueAppsUserId");
        if (laIt == person.end() || laIt->is_null()) continue;
        std::string uid;
        if (laIt->is_number_integer())  uid = std::to_string(laIt->get<long long>());
        else if (laIt->is_string())     uid = laIt->get<std::string>();
        else continue;
        if (uid.empty()) continue;

        bool inMens = false;
        if (person.contains("assignments") && person["assignments"].is_array()) {
            for (const auto& a : person["assignments"]) {
                auto d = a.find("domain");
                if (d != a.end() && d->is_string() && d->get<std::string>() == "mens") {
                    inMens = true;
                    break;
                }
            }
        }
        if (!inMens) continue;

        auto found = byUid.find(uid);
        if (found == byUid.end()) continue;

        const json& mensP = *found->second;
        for (const auto& key : kMensBillingKeys) {
            auto k = mensP.find(key);
            if (k != mensP.end() && !k->is_null()) {
                person[key] = *k;
            }
        }
    }

    // Also expose top-level delinquency summary so the frontend can
    // render an aggregate ⚠ N OVERDUE badge in the mens filter pill.
    if (mensRes.body.contains("delinquency")) {
        payload["mensDelinquency"] = mensRes.body["delinquency"];
    }
    if (mensRes.body.contains("sourceProgram")) {
        payload["mensProgramId"]   = mensRes.body["sourceProgram"];
    }
}

// Keys that BoysRoster::shapePlayer injects onto each youth player.
// Same pattern as kMensBillingKeys but the field set is different —
// youth cards care about age/gender/parent-contact, mens cards care
// about billing/dues.  Only keys emitted here are overlaid onto the
// base club-rosters `people[]` array for boys-domain assignments.
const std::vector<std::string> kYouthFields = {
    // Identity + age
    "birthYear",
    "gender",
    "club",
    "ageGroup",
    // Player contact (fallback if no parent contact)
    "email",
    "phone",
    "playerEmail",
    // Parent contact — the primary route for youth SMS/email/call
    "parentFirstName",
    "parentLastName",
    "parentName",
    "parentEmail",
    "parentPhone",
    // Registration + billing (subset of mens billing — no
    // delinquency-state helper for youth yet, but LA balance and
    // 3-month payment window are useful for the coach).
    "programName",
    "paymentStatus",
    "outstandingBalance",
    "registrationStatus",
    "registrationId",
    "paymentsWindow",
    "paymentsWindowSum",
    "laRegisteredAt",
    "lastPayReminder",
};

// enrichWithYouthFields — mirrors enrichWithMensBilling but for the
// boys / girls domains.  BoysRoster covers both boys and girls
// programs (5039252 + 5039357) so a single run() call is enough.
//
// Merge scope: only overlay youth keys onto persons who have at least
// one assignment in the "boys" OR "girls" domain.  That prevents a
// mens player who happens to have a youth LA registration (rare but
// possible) from getting age/parent chips on their mens card.
void enrichWithYouthFields(json& payload, BoysRoster* boys) {
    if (!boys) return;
    if (!payload.contains("people") || !payload["people"].is_array()) return;

    BoysRoster::Result boysRes;
    try {
        // includeAll=true so we get every youth registrant (including
        // those on trial or pending), refreshLa=false so we reuse the
        // in-memory cache MensRoster / BoysRoster keep across GETs.
        boysRes = boys->run(/*includeAll=*/true, /*refreshLa=*/false);
    } catch (const std::exception& e) {
        std::cerr << "ClubRosters: youth enrichment threw: "
                  << e.what() << std::endl;
        return;
    }
    if (!boysRes.error.empty()) {
        std::cerr << "ClubRosters: youth enrichment error: "
                  << boysRes.error << " (skipping merge)" << std::endl;
        return;
    }

    // Same index strategy as the mens merge: walk buckets + unassigned
    // and key by stringified leagueAppsUserId.
    std::unordered_map<std::string, const json*> byUid;
    auto indexArr = [&](const json& arr) {
        if (!arr.is_array()) return;
        for (const auto& p : arr) {
            auto it = p.find("leagueAppsUserId");
            if (it == p.end() || it->is_null()) {
                // BoysRoster also emits `userId` as an alias — check both.
                it = p.find("userId");
                if (it == p.end() || it->is_null()) continue;
            }
            std::string uid;
            if (it->is_number_integer())  uid = std::to_string(it->get<long long>());
            else if (it->is_string())     uid = it->get<std::string>();
            else continue;
            if (uid.empty()) continue;
            byUid[uid] = &p;
        }
    };
    if (boysRes.body.contains("unassigned")) indexArr(boysRes.body["unassigned"]);
    if (boysRes.body.contains("buckets")) {
        for (auto it = boysRes.body["buckets"].begin();
             it != boysRes.body["buckets"].end(); ++it) {
            indexArr(it.value());
        }
    }

    // Merge youth keys onto each person with a boys OR girls
    // assignment in the base payload.
    for (auto& person : payload["people"]) {
        auto laIt = person.find("leagueAppsUserId");
        if (laIt == person.end() || laIt->is_null()) continue;
        std::string uid;
        if (laIt->is_number_integer())  uid = std::to_string(laIt->get<long long>());
        else if (laIt->is_string())     uid = laIt->get<std::string>();
        else continue;
        if (uid.empty()) continue;

        bool inYouth = false;
        if (person.contains("assignments") && person["assignments"].is_array()) {
            for (const auto& a : person["assignments"]) {
                auto d = a.find("domain");
                if (d != a.end() && d->is_string()) {
                    const std::string& dom = d->get<std::string>();
                    if (dom == "boys" || dom == "girls") {
                        inYouth = true;
                        break;
                    }
                }
            }
        }
        if (!inYouth) continue;

        auto found = byUid.find(uid);
        if (found == byUid.end()) continue;

        const json& youthP = *found->second;
        for (const auto& key : kYouthFields) {
            auto k = youthP.find(key);
            if (k != youthP.end() && !k->is_null()) {
                person[key] = *k;
            }
        }
    }

    // Expose top-level program ids so the frontend can build LA links.
    if (boysRes.body.contains("boysProgramId")) {
        payload["boysProgramId"] = boysRes.body["boysProgramId"];
    }
    if (boysRes.body.contains("girlsProgramId")) {
        payload["girlsProgramId"] = boysRes.body["girlsProgramId"];
    }
    if (boysRes.body.contains("seasonEndYear")) {
        payload["seasonEndYear"] = boysRes.body["seasonEndYear"];
    }
}

} // namespace

ClubRostersController::ClubRostersController()
    : mensRoster_(std::make_unique<MensRoster>()),
      boysRoster_(std::make_unique<BoysRoster>()) {}
ClubRostersController::~ClubRostersController() = default;

void ClubRostersController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix,                     [this](const Request& req) { return handleGet         (req); });
    router.post(prefix + "/assign",         [this](const Request& req) { return handleAssign      (req); });
    router.post(prefix + "/roster-status",  [this](const Request& req) { return handleRosterStatus(req); });
    router.post(prefix + "/reorder",        [this](const Request& req) { return handleReorder     (req); });
}

// GET /api/club-rosters
//
// Returns a single payload with two arrays:
//
//   {
//     "people": [
//       { "personId": 123, "firstName": "…", "lastName": "…",
//         "birthDate": "YYYY-MM-DD"|null, "fhMemberAt": "…",
//         "leagueAppsUserId": "12345"|null,
//         "phone": "…"|null, "email": "…"|null,
//         "assignments": [
//           { "domain": "mens", "teamId": 122, "teamName": "Lighthouse League (Mens)",
//             "genderCategory": "mens", "label": "🏰 Lighthouse League",
//             "shortLabel": "LL", "color": "#2563eb", "sortOrder": 4,
//             "assignedAt": "…" },
//           …
//         ]
//       }, …
//     ],
//     "columns": [
//       { "domain": "boys", "teamId": 5, "teamName": "Boys U15",
//         "genderCategory": "boys", "label": "U15", "shortLabel": "U15",
//         "color": "#…", "sortOrder": 5 }, …
//     ]
//   }
//
// Everything is built inside a single SQL statement using json_agg so the
// C++ side is a straight pass-through of one text column.  This keeps the
// controller ~50 lines and puts the join+shape logic where it belongs —
// next to the data.
//
// Scope of "people": every persons row that has a LeagueApps alias
// (external_person_aliases.provider='leagueapps').  This is the club-
// known population — same as what the per-domain boards render before
// filtering, minus the "LA-only registrants who have no persons row yet"
// case that the boys/mens LA fetch adds on top.  Not filtering by
// fh_member_at because that flag is currently unset for the entire
// persons table (2026-07-07); it marks explicit FH sign-up, not just
// "club membership".  Adding LA-only registrants can layer on later.
Response ClubRostersController::handleGet(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    auto* db = Database::getInstance();

    static constexpr const char* kSql = R"SQL(
WITH
-- One row per person: their primary phone (is_primary DESC keeps the
-- flagged one; deterministic tie-break by id).
primary_phone AS (
    SELECT DISTINCT ON (person_id)
           person_id, phone_number
      FROM person_phones
     ORDER BY person_id, is_primary DESC, id
),
primary_email AS (
    SELECT DISTINCT ON (person_id)
           person_id, email
      FROM person_emails
     ORDER BY person_id, is_primary DESC, id
),
-- One LA user id per person.  A person can have multiple aliases
-- (e.g. renamed on LA); we pick the lowest id deterministically.
primary_la AS (
    SELECT DISTINCT ON (person_id)
           person_id, external_user_id AS la_user_id
      FROM external_person_aliases
     WHERE provider = 'leagueapps'
       AND external_user_id IS NOT NULL
     ORDER BY person_id, id
),
-- Aggregated cross-domain assignments per person.  Only rows that
-- map to a visible roster_columns entry appear as chips — pool-team
-- membership (Practice 908 / Pickup 909, auto-inserted by triggers)
-- is implementation detail and would clutter the card view.  Use a
-- filter subquery so people with only pool-team rows still show up in
-- the outer people list (just with an empty chip strip).
--
-- `coachSortOrder` (drag reorder) and `onRoster` (match-day toggle)
-- are per-assignment (i.e. per user × team), so they belong on the
-- assignment JSON object, not the person or the column.  Emitted here
-- so the column-layout render mode can sort within a team and toggle
-- the on-roster pill without any extra round-trip.
per_assignments AS (
    SELECT epa.person_id,
           json_agg(
             json_build_object(
               'domain',         ra.domain,
               'teamId',         ra.team_id,
               'teamName',       t.name,
               'genderCategory', t.gender_category,
               'label',          rc.label,
               'shortLabel',     rc.short_label,
               'color',          rc.color,
               'sortOrder',      rc.sort_order,
               'coachSortOrder', ra.coach_sort_order,
               'onRoster',       COALESCE(ra.on_roster, false),
               'assignedAt',     ra.assigned_at
             )
             ORDER BY ra.domain, rc.sort_order NULLS LAST, t.name
           ) AS assignments
      FROM roster_assignments ra
      JOIN external_person_aliases epa
        ON epa.provider = 'leagueapps'
       AND epa.external_user_id = ra.leagueapps_user_id::text
      JOIN teams t ON t.id = ra.team_id
      JOIN roster_columns rc
        ON rc.domain = ra.domain
       AND rc.team_id = ra.team_id
       AND rc.archived_at IS NULL
     WHERE ra.removed_at IS NULL
  GROUP BY epa.person_id
),
-- Per-column counts.  Same shape the per-domain boards compute in
-- application code; doing it in SQL keeps the payload self-consistent
-- and avoids the frontend having to derive counts by iterating all
-- people (fine for 200 people, slow at 2000).
column_counts AS (
    SELECT rc.domain, rc.team_id,
           COUNT(*) FILTER (WHERE ra.removed_at IS NULL)                                 AS total_count,
           COUNT(*) FILTER (WHERE ra.removed_at IS NULL AND COALESCE(ra.on_roster, false)) AS on_roster_count
      FROM roster_columns rc
 LEFT JOIN roster_assignments ra
        ON ra.domain  = rc.domain
       AND ra.team_id = rc.team_id
       AND ra.removed_at IS NULL
     WHERE rc.archived_at IS NULL
  GROUP BY rc.domain, rc.team_id
)
SELECT json_build_object(
         'people', COALESCE(
           (SELECT json_agg(
                     json_build_object(
                       'personId',         p.id,
                       'firstName',        p.first_name,
                       'lastName',         p.last_name,
                       'birthDate',        p.birth_date,
                       'fhMemberAt',       p.fh_member_at,
                       'leagueAppsUserId', pl.la_user_id,
                       'phone',            pp.phone_number,
                       'email',            pe.email,
                       'assignments',      COALESCE(pa.assignments, '[]'::json)
                     )
                     ORDER BY p.last_name, p.first_name, p.id
                   )
              FROM persons p
         LEFT JOIN primary_phone   pp ON pp.person_id = p.id
         LEFT JOIN primary_email   pe ON pe.person_id = p.id
         LEFT JOIN primary_la      pl ON pl.person_id = p.id
         LEFT JOIN per_assignments pa ON pa.person_id = p.id
             WHERE pl.la_user_id IS NOT NULL),
           '[]'::json
         ),
         'columns', COALESCE(
           (SELECT json_agg(
                     json_build_object(
                       'domain',         rc.domain,
                       'teamId',         rc.team_id,
                       'teamName',       t.name,
                       'genderCategory', t.gender_category,
                       'label',          rc.label,
                       'shortLabel',     rc.short_label,
                       'color',          rc.color,
                       'sortOrder',      rc.sort_order,
                       'mutexGroup',     rc.mutex_group,
                       'maxRoster',      rc.max_roster,
                       'count',          COALESCE(cc.total_count, 0),
                       'onRosterCount',  COALESCE(cc.on_roster_count, 0)
                     )
                     ORDER BY rc.domain, rc.sort_order NULLS LAST, t.name
                   )
              FROM roster_columns rc
              JOIN teams t ON t.id = rc.team_id
         LEFT JOIN column_counts cc
                ON cc.domain = rc.domain
               AND cc.team_id = rc.team_id
             WHERE rc.archived_at IS NULL),
           '[]'::json
         )
       ) AS payload
    )SQL";

    try {
        auto r = db->query(kSql, {});
        if (r.empty() || r[0]["payload"].is_null()) {
            return Response(HttpStatus::OK, "{\"people\":[],\"columns\":[]}");
        }
        // pqxx returns the aggregate json as text.  Parse it once so
        // we can layer in mens billing + (later) youth age/gender +
        // parent contact before shipping back to the client.
        json payload = json::parse(r[0]["payload"].as<std::string>());
        enrichWithMensBilling(payload, mensRoster_.get());
        enrichWithYouthFields (payload, boysRoster_.get());
        return Response(HttpStatus::OK, payload.dump());
    } catch (const std::exception& e) {
        std::cerr << "ClubRostersController::handleGet error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to load club rosters: ") + e.what());
    }
}

// POST /api/club-rosters/assign
//
// Body: { "leagueAppsUserId": <int|string>,
//         "teamId":           <int>,
//         "action":           "add"|"remove" }
//
// Cross-domain chip toggle.  We look up the target team's domain and
// mutex_group from roster_columns, then delegate to a per-domain
// MensTeamAssignments instance so the mutex-sibling eviction,
// delinquent-restore, and audit history are IDENTICAL to what the
// per-domain boards already do.  This is what lets us collapse the
// per-domain boards to filter presets over the master board later
// without losing any behaviour.
//
// Pool teams (Practice 908 / Pickup 909) intentionally do NOT have a
// roster_columns entry (LaPool.cpp owns their membership), so a POST
// targeting a pool team returns 404.  If a coach wants Nelson to
// practice, they add him to a real column (LL 122) — the eligibility
// query in EventReminderController then picks him up.
//
// Response: { "leagueAppsUserId": …, "teamIds": [...] } — same shape as
// MensRosterController::handleAssign so the frontend can reuse the same
// optimistic-update code path.
Response ClubRostersController::handleAssign(const Request& request) {
    if (!requireBearer(request)) {
        return jsonErr(HttpStatus::UNAUTHORIZED, "auth required");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) {
        return badRequest("Invalid JSON body");
    }

    long long userId   = 0;
    long long teamIdLL = 0;
    if (!readInt(body, "leagueAppsUserId", userId) ||
        !readInt(body, "teamId",            teamIdLL) ||
        userId <= 0 || teamIdLL <= 0) {
        return badRequest("leagueAppsUserId, teamId, action(add|remove) required");
    }
    const int teamId = static_cast<int>(teamIdLL);

    std::string action = readStr(body, "action");
    for (auto& c : action) c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
    if (action != "add" && action != "remove") {
        return badRequest("leagueAppsUserId, teamId, action(add|remove) required");
    }

    auto* db = Database::getInstance();
    try {
        // Resolve domain + mutex_group by team_id.  This is the crux of
        // the cross-domain routing — the per-domain boards hardcode
        // domain via MensTeamColumns("mens") / ("boys"), but here we
        // derive it from the target team so a single endpoint can
        // toggle chips in ANY domain.
        auto rows = db->query(
            "SELECT domain, COALESCE(mutex_group, '') AS mutex_group "
            "  FROM roster_columns "
            " WHERE team_id = $1 "
            "   AND archived_at IS NULL "
            " LIMIT 1",
            {std::to_string(teamId)}
        );
        if (rows.empty()) {
            return notFound("Team is not configured as a roster column "
                            "(pool teams are managed automatically)");
        }
        const std::string domain     = rows[0]["domain"].as<std::string>();
        const std::string mutexGroup = rows[0]["mutex_group"].as<std::string>();

        MensTeamAssignments assignments(domain);
        std::vector<int> teamIds;
        if (action == "remove") {
            teamIds = assignments.removeAssignment(userId, teamId);
        } else {
            teamIds = assignments.addAssignment(userId, teamId, mutexGroup);
        }

        json out;
        out["leagueAppsUserId"] = userId;
        out["domain"]           = domain;
        out["teamIds"]          = teamIds;
        return Response(HttpStatus::OK, out.dump());
    } catch (const std::exception& e) {
        std::cerr << "ClubRostersController::handleAssign error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to update assignment: ") + e.what());
    }
}

// POST /api/club-rosters/roster-status
//
// Body: { "leagueAppsUserId": <int|string>,
//         "teamId":           <int>,
//         "onRoster":         <bool> }
//
// Match-day roster toggle.  A chip's "on-roster" state is independent
// of its "assigned" state — a player can be on the assignment sheet
// (chip present) but marked off-roster for the upcoming match (pill
// toggled off).  The per-domain boards render this as a filled vs
// hollow pill.
//
// Response: { "leagueAppsUserId", "teamId", "onRoster", "domain" }.
// Returns 404 when there is no active assignment for the pair — the
// UI must fall back to POSTing /assign first.
Response ClubRostersController::handleRosterStatus(const Request& request) {
    if (!requireBearer(request)) {
        return jsonErr(HttpStatus::UNAUTHORIZED, "auth required");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) {
        return badRequest("Invalid JSON body");
    }

    long long userId   = 0;
    long long teamIdLL = 0;
    if (!readInt(body, "leagueAppsUserId", userId) ||
        !readInt(body, "teamId",            teamIdLL) ||
        userId <= 0 || teamIdLL <= 0) {
        return badRequest("leagueAppsUserId and teamId required");
    }
    const int  teamId   = static_cast<int>(teamIdLL);
    const bool onRoster = readBool(body, "onRoster", false);

    auto* db = Database::getInstance();
    try {
        const std::string domain = resolveDomainForTeam(db, teamId);
        if (domain.empty()) {
            return notFound("Team is not configured as a roster column");
        }
        MensTeamAssignments assignments(domain);
        auto result = assignments.setRosterStatus(userId, teamId, onRoster);
        if (!result) {
            return notFound("No assignment exists for that player on that team");
        }
        std::ostringstream out;
        out << "{\"leagueAppsUserId\":" << userId
            << ",\"teamId\":"           << teamId
            << ",\"onRoster\":"         << (*result ? "true" : "false")
            << ",\"domain\":"           << jsonEscape(domain)
            << "}";
        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "ClubRostersController::handleRosterStatus error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to update roster status: ") + e.what());
    }
}

// POST /api/club-rosters/reorder
//
// Body: { "teamId":  <int>,
//         "userIds": [<int|string>, ...] }
//
// Drag-reorder within a team column.  `userIds` is the full ordered
// list of active players in the column, top-to-bottom.  Server writes
// coach_sort_order = 1..N in that order on the matching
// roster_assignments rows.  Users on the team but missing from the
// list keep their existing rank (or NULL == alpha fallback).
//
// Response: { "teamId", "touched", "domain" }.
Response ClubRostersController::handleReorder(const Request& request) {
    if (!requireBearer(request)) {
        return jsonErr(HttpStatus::UNAUTHORIZED, "auth required");
    }

    json body;
    try { body = json::parse(request.getBody()); }
    catch (const std::exception&) {
        return badRequest("Invalid JSON body");
    }

    long long teamIdLL = 0;
    if (!readInt(body, "teamId", teamIdLL) || teamIdLL <= 0) {
        return badRequest("teamId (positive int) required");
    }
    const int teamId = static_cast<int>(teamIdLL);

    auto it = body.find("userIds");
    if (it == body.end() || !it->is_array()) {
        return badRequest("userIds (array of ints) required");
    }
    std::vector<long long> ordered;
    ordered.reserve(it->size());
    for (const auto& e : *it) {
        long long v = 0;
        if (e.is_number_integer())          v = e.get<long long>();
        else if (e.is_number_unsigned())    v = static_cast<long long>(e.get<unsigned long long>());
        else if (e.is_number_float())       v = static_cast<long long>(e.get<double>());
        else if (e.is_string()) {
            try { v = std::stoll(e.get<std::string>()); }
            catch (const std::exception&) { return badRequest("userIds contains a non-numeric entry"); }
        } else {
            return badRequest("userIds entries must be integers");
        }
        if (v <= 0) return badRequest("userIds entries must be positive");
        ordered.push_back(v);
    }

    auto* db = Database::getInstance();
    try {
        const std::string domain = resolveDomainForTeam(db, teamId);
        if (domain.empty()) {
            return notFound("Team is not configured as a roster column");
        }
        MensTeamAssignments assignments(domain);
        const long long touched = assignments.reorderTeam(teamId, ordered);
        std::ostringstream out;
        out << "{\"teamId\":"  << teamId
            << ",\"touched\":" << touched
            << ",\"domain\":"  << jsonEscape(domain)
            << "}";
        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "ClubRostersController::handleReorder error: " << e.what() << std::endl;
        return internalErr(std::string("Failed to reorder team: ") + e.what());
    }
}
