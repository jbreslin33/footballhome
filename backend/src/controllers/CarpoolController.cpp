#include "CarpoolController.h"

#include <iostream>

#include "../database/Database.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json; charset=utf-8"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"success", false}, {"error", message}}); }

// /api/carpool/<fhEventId>[/requests]  or  /api/carpool/requests/<id>/<action>
long long idAfter(const std::string& path, const std::string& key) {
    auto p = path.find(key); if (p == std::string::npos) return 0;
    p += key.size(); auto e = path.find('/', p);
    try { return std::stoll(path.substr(p, e == std::string::npos ? std::string::npos : e - p)); } catch (...) { return 0; }
}

std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }

// Everyone ON the game: rostered on a tagged team, or an open invite
// (fh_event_invites, mig 355) — the same people the game is visible to.
constexpr const char* kParty = R"SQL(
    party AS (
        SELECT tp.person_id FROM fh_event_teams fet
          JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.removed_at IS NULL
                              -- Call-up-gated team (mig 605): only the
                              -- invited (next branch) are on its games.
                              AND NOT fh_team_callup_only(tp.team_id)
         WHERE fet.fh_event_id = $1::bigint
        UNION
        SELECT i.person_id FROM fh_event_invites i
         WHERE i.fh_event_id = $1::bigint AND i.revoked_at IS NULL
    ))SQL";

// May this person see / act on the game's carpool?  On it themselves, a
// parent of someone on it, a coach of a tagged team, or club staff.
// ($1 = fh_event_id, $2 = person_id)
const std::string kAllowedSql = std::string("WITH ") + kParty + R"SQL(
    SELECT EXISTS (SELECT 1 FROM party WHERE person_id = $2::int)
        OR EXISTS (SELECT 1 FROM party pa JOIN persons c ON c.id = pa.person_id
                    WHERE c.parent_person_id = $2::int)
        OR EXISTS (SELECT 1 FROM fh_event_teams fet
                     JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
                     JOIN coaches co ON co.id = tc.coach_id
                    WHERE fet.fh_event_id = $1::bigint AND co.person_id = $2::int)
        OR fh_event_staff($1::bigint, $2::int) AS allowed)SQL";

struct Viewer { long long personId = 0; bool isAdmin = false; };

// The signed-in account's person and whether they hold a club/super level.
bool loadViewer(Database* db, long long userId, Viewer* out) {
    auto rows = db->query(R"SQL(
        SELECT u.person_id,
               EXISTS (SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id
                        WHERE a.user_id = u.id AND al.name IN ('club','super')) AS is_admin
          FROM users u WHERE u.id = $1::int)SQL", {std::to_string(userId)});
    if (rows.empty() || rows[0]["person_id"].is_null()) return false;
    out->personId = rows[0]["person_id"].as<long long>();
    out->isAdmin  = rows[0]["is_admin"].as<bool>();
    return true;
}

bool allowedOnEvent(Database* db, long long fhEventId, const Viewer& v) {
    if (v.isAdmin) return true;
    auto rows = db->query(kAllowedSql, {std::to_string(fhEventId), std::to_string(v.personId)});
    return !rows.empty() && rows[0]["allowed"].as<bool>();
}

// Staff of THIS game: club/super admin, or a coach of a tagged team.  They
// get a request button for EVERY player on the game, not just their own
// kids (owner 2026-10-19: "carpool does not have button … that i can see
// in game center" — an admin with no child on the game had nothing to
// tap), and may post on any family's behalf.
bool staffOnEvent(Database* db, long long fhEventId, const Viewer& v) {
    if (v.isAdmin) return true;
    auto rows = db->query(R"SQL(
        SELECT EXISTS (SELECT 1 FROM fh_event_teams fet
                         JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
                         JOIN coaches co ON co.id = tc.coach_id
                        WHERE fet.fh_event_id = $1::bigint AND co.person_id = $2::int) AS ok)SQL",
        {std::to_string(fhEventId), std::to_string(v.personId)});
    return !rows.empty() && rows[0]["ok"].as<bool>();
}

} // namespace

void CarpoolController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/:fhEventId",           [this](const Request& r) { return handleList(r); });
    router.post(prefix + "/:fhEventId/requests",  [this](const Request& r) { return handleCreate(r); });
    router.post(prefix + "/requests/:id/accept",  [this](const Request& r) { return handleAction(r, "accept"); });
    router.post(prefix + "/requests/:id/unaccept",[this](const Request& r) { return handleAction(r, "unaccept"); });
    router.post(prefix + "/requests/:id/cancel",  [this](const Request& r) { return handleAction(r, "cancel"); });
}

Response CarpoolController::handleList(const Request& request) {
    const long long fhEventId = idAfter(request.getPath(), "/carpool/");
    if (fhEventId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "event id");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    try {
        auto* db = Database::getInstance();
        Viewer me;
        if (!loadViewer(db, userId, &me)) return jsonError(HttpStatus::FORBIDDEN, "No person on this account.");
        if (!allowedOnEvent(db, fhEventId, me)) return jsonError(HttpStatus::FORBIDDEN, "Carpool is for people on this game.");
        const std::string eid = std::to_string(fhEventId), pid = std::to_string(me.personId);

        auto rows = db->query(R"SQL(
            SELECT r.id, r.person_id,
                   NULLIF(trim(COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,'')), '')  AS name,
                   r.address1, r.address2, r.city, r.state, r.zip, r.note,
                   to_char(r.created_at AT TIME ZONE 'America/New_York', 'Mon FMDD, FMHH12:MI am') AS created_at,
                   r.requested_by_person_id,
                   NULLIF(trim(COALESCE(rq.first_name,'') || ' ' || COALESCE(rq.last_name,'')), '') AS rq_name,
                   rqp.phone_number AS rq_phone,
                   r.accepted_by_person_id,
                   NULLIF(trim(COALESCE(ac.first_name,'') || ' ' || COALESCE(ac.last_name,'')), '') AS ac_name,
                   acp.phone_number AS ac_phone
              FROM fh_carpool_requests r
              JOIN persons p  ON p.id  = r.person_id
              JOIN persons rq ON rq.id = r.requested_by_person_id
              LEFT JOIN persons ac ON ac.id = r.accepted_by_person_id
              LEFT JOIN LATERAL (SELECT x.phone_number FROM person_phones x WHERE x.person_id = rq.id
                                  ORDER BY x.is_primary DESC NULLS LAST, x.id LIMIT 1) rqp ON true
              LEFT JOIN LATERAL (SELECT x.phone_number FROM person_phones x WHERE x.person_id = ac.id
                                  ORDER BY x.is_primary DESC NULLS LAST, x.id LIMIT 1) acp ON true
             WHERE r.fh_event_id = $1::bigint AND r.cancelled_at IS NULL
             ORDER BY (r.accepted_by_person_id IS NOT NULL), r.created_at)SQL", {eid});

        json requests = json::array();
        for (const auto& r : rows) {
            json acceptedBy = nullptr;
            if (!r["accepted_by_person_id"].is_null())
                acceptedBy = {{"personId", r["accepted_by_person_id"].as<long long>()},
                              {"name", str(r, "ac_name")},
                              {"phone", r["ac_phone"].is_null() ? json(nullptr) : json(str(r, "ac_phone"))}};
            requests.push_back({{"id", r["id"].as<long long>()},
                                {"personId", r["person_id"].as<long long>()},
                                {"name", str(r, "name")},
                                {"address1", str(r, "address1")}, {"address2", str(r, "address2")},
                                {"city", str(r, "city")}, {"state", str(r, "state")}, {"zip", str(r, "zip")},
                                {"note", str(r, "note")},
                                {"createdAt", str(r, "created_at")},
                                {"requestedBy", {{"personId", r["requested_by_person_id"].as<long long>()},
                                                 {"name", str(r, "rq_name")},
                                                 {"phone", r["rq_phone"].is_null() ? json(nullptr) : json(str(r, "rq_phone"))}}},
                                {"acceptedBy", acceptedBy}});
        }

        // Who the viewer may post a request for: themselves if they are on
        // the game, plus their own children on it — or, for the game's
        // staff (admin / tagged-team coach), every player on it.  Address
        // pre-fill: the player's primary, else the viewer's own ONLY when
        // the viewer is that family (staff don't leak their home address
        // into someone else's form).
        const bool staff = staffOnEvent(db, fhEventId, me);
        auto kids = db->query(std::string("WITH ") + kParty + R"SQL(
            SELECT m.id AS person_id,
                   NULLIF(trim(COALESCE(m.first_name,'') || ' ' || COALESCE(m.last_name,'')), '') AS name,
                   EXISTS (SELECT 1 FROM fh_carpool_requests r
                            WHERE r.fh_event_id = $1::bigint AND r.person_id = m.id
                              AND r.cancelled_at IS NULL) AS open,
                   (m.id = $2::int OR m.parent_person_id = $2::int) AS mine,
                   COALESCE(a.address1, CASE WHEN m.id = $2::int OR m.parent_person_id = $2::int THEN va.address1 END, '') AS address1,
                   COALESCE(a.address2, CASE WHEN m.id = $2::int OR m.parent_person_id = $2::int THEN va.address2 END, '') AS address2,
                   COALESCE(a.city,     CASE WHEN m.id = $2::int OR m.parent_person_id = $2::int THEN va.city     END, '') AS city,
                   COALESCE(a.state,    CASE WHEN m.id = $2::int OR m.parent_person_id = $2::int THEN va.state    END, '') AS state,
                   COALESCE(a.zip,      CASE WHEN m.id = $2::int OR m.parent_person_id = $2::int THEN va.zip      END, '') AS zip
              FROM persons m
              LEFT JOIN LATERAL (SELECT * FROM person_addresses x
                                  WHERE x.person_id = m.id AND x.is_primary LIMIT 1) a ON true
              LEFT JOIN LATERAL (SELECT * FROM person_addresses x
                                  WHERE x.person_id = $2::int AND x.is_primary LIMIT 1) va ON true
             WHERE (m.id = $2::int OR m.parent_person_id = $2::int OR $3::bool)
               AND m.id IN (SELECT person_id FROM party)
             ORDER BY (m.id = $2::int OR m.parent_person_id = $2::int) DESC, m.first_name, m.last_name)SQL",
            {eid, pid, staff ? "true" : "false"});

        json riders = json::array();
        for (const auto& r : kids) {
            riders.push_back({{"personId", r["person_id"].as<long long>()},
                              {"name", str(r, "name")}, {"open", r["open"].as<bool>()},
                              {"address1", str(r, "address1")}, {"address2", str(r, "address2")},
                              {"city", str(r, "city")}, {"state", str(r, "state")}, {"zip", str(r, "zip")}});
        }
        return jsonOut(HttpStatus::OK, {{"success", true}, {"viewerPersonId", me.personId},
                                        {"requests", requests}, {"riders", riders}});
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/carpool] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response CarpoolController::handleCreate(const Request& request) {
    const long long fhEventId = idAfter(request.getPath(), "/carpool/");
    if (fhEventId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "event id");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    json body;
    try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "bad json"); }
    const long long personId = body.value("person_id", 0LL);
    if (personId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "person_id");
    auto field = [&](const char* k) { return body.contains(k) && body[k].is_string() ? body[k].get<std::string>() : std::string{}; };
    try {
        auto* db = Database::getInstance();
        Viewer me;
        if (!loadViewer(db, userId, &me)) return jsonError(HttpStatus::FORBIDDEN, "No person on this account.");
        if (!allowedOnEvent(db, fhEventId, me)) return jsonError(HttpStatus::FORBIDDEN, "Carpool is for people on this game.");
        const std::string eid = std::to_string(fhEventId), pid = std::to_string(me.personId), rid = std::to_string(personId);

        // The rider must be yourself or your own child (the game's staff —
        // admin or tagged-team coach — may post for any player on it), and
        // must actually be on this game.
        auto ok = db->query(std::string("WITH ") + kParty + R"SQL(
            SELECT EXISTS (SELECT 1 FROM persons m
                            WHERE m.id = $3::int
                              AND ($4::bool OR m.id = $2::int OR m.parent_person_id = $2::int)
                              AND m.id IN (SELECT person_id FROM party)) AS ok)SQL",
            {eid, pid, rid, staffOnEvent(db, fhEventId, me) ? "true" : "false"});
        if (ok.empty() || !ok[0]["ok"].as<bool>())
            return jsonError(HttpStatus::FORBIDDEN, "You can only request a ride for your own player on this game.");

        try {
            db->query(R"SQL(
                INSERT INTO fh_carpool_requests
                       (fh_event_id, person_id, requested_by_person_id,
                        address1, address2, city, state, zip, note)
                VALUES ($1::bigint, $2::int, $3::int, $4, $5, $6, $7, $8, $9))SQL",
                {eid, rid, pid, field("address1"), field("address2"),
                 field("city"), field("state"), field("zip"), field("note")});
        } catch (const std::exception&) {
            return jsonError(HttpStatus::CONFLICT, "This player already has an open ride request for this game.");
        }
        return jsonOut(HttpStatus::OK, {{"success", true}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/carpool/requests] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response CarpoolController::handleAction(const Request& request, const std::string& action) {
    const long long reqId = idAfter(request.getPath(), "/requests/");
    if (reqId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "request id");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    try {
        auto* db = Database::getInstance();
        Viewer me;
        if (!loadViewer(db, userId, &me)) return jsonError(HttpStatus::FORBIDDEN, "No person on this account.");
        auto rows = db->query(R"SQL(
            SELECT fh_event_id, requested_by_person_id, accepted_by_person_id, cancelled_at
              FROM fh_carpool_requests WHERE id = $1::int)SQL", {std::to_string(reqId)});
        if (rows.empty()) return jsonError(HttpStatus::NOT_FOUND, "No such request.");
        const auto& r = rows[0];
        if (!r["cancelled_at"].is_null()) return jsonError(HttpStatus::CONFLICT, "This request was cancelled.");
        const long long fhEventId   = r["fh_event_id"].as<long long>();
        const long long requesterId = r["requested_by_person_id"].as<long long>();
        const long long driverId    = r["accepted_by_person_id"].is_null() ? 0 : r["accepted_by_person_id"].as<long long>();
        if (!allowedOnEvent(db, fhEventId, me)) return jsonError(HttpStatus::FORBIDDEN, "Carpool is for people on this game.");
        const std::string id = std::to_string(reqId), pid = std::to_string(me.personId);

        if (action == "accept") {
            if (driverId) return jsonError(HttpStatus::CONFLICT, "Someone already took this one.");
            if (me.personId == requesterId && !me.isAdmin)
                return jsonError(HttpStatus::BAD_REQUEST, "That's your own request.");
            db->query("UPDATE fh_carpool_requests SET accepted_by_person_id = $2::int, accepted_at = now() "
                      "WHERE id = $1::int AND cancelled_at IS NULL AND accepted_by_person_id IS NULL", {id, pid});
        } else if (action == "unaccept") {
            if (driverId != me.personId && !me.isAdmin)
                return jsonError(HttpStatus::FORBIDDEN, "Only the driver can step back.");
            db->query("UPDATE fh_carpool_requests SET accepted_by_person_id = NULL, accepted_at = NULL "
                      "WHERE id = $1::int AND cancelled_at IS NULL", {id});
        } else if (action == "cancel") {
            if (requesterId != me.personId && !me.isAdmin)
                return jsonError(HttpStatus::FORBIDDEN, "Only whoever asked can cancel it.");
            db->query("UPDATE fh_carpool_requests SET cancelled_at = now(), cancelled_by_person_id = $2::int "
                      "WHERE id = $1::int AND cancelled_at IS NULL", {id, pid});
        } else {
            return jsonError(HttpStatus::BAD_REQUEST, "action");
        }
        return jsonOut(HttpStatus::OK, {{"success", true}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/carpool/" << action << "] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
