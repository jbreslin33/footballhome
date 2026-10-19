#include "CarpoolController.h"

#include <cmath>
#include <iostream>
#include <optional>

#include "../database/Database.h"
#include "../services/CarpoolRouting.h"
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

// ── Pickup plans (migs 608/609) ──────────────────────────────────────────
// All drive estimates ride CarpoolRouting (Nominatim + OSRM, both cached in
// the DB) and are padded by schedule_conflict_policies' traffic factor and
// buffer — the same knobs the #my conflict checker trusts.

struct TimingPolicy { double factor = 1.3; double bufferMin = 10; };

TimingPolicy timingPolicy(Database* db) {
    TimingPolicy out;
    try {
        auto r = db->query("SELECT traffic_factor, buffer_minutes FROM schedule_conflict_policies ORDER BY club_id LIMIT 1");
        if (!r.empty()) {
            out.factor    = r[0]["traffic_factor"].as<double>();
            out.bufferMin = r[0]["buffer_minutes"].as<double>();
        }
    } catch (const std::exception&) { /* defaults hold */ }
    return out;
}

// Be-there time for the event, as a UTC epoch: arrival_at (league matchday
// offsets, mig 395) when set, else kickoff/start from gcal.
std::optional<double> eventDeadlineEpoch(Database* db, long long fhEventId) {
    auto r = db->query(
        "SELECT extract(epoch FROM COALESCE(fe.arrival_at, fe.start_at, ge.starts_at)) AS t "
        "  FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
        " WHERE fe.id = $1::bigint", {std::to_string(fhEventId)});
    if (r.empty() || r[0]["t"].is_null()) return std::nullopt;
    return r[0]["t"].as<double>();
}

// "7:05 PM" in club time for a UTC epoch — the DB owns the timezone math.
std::string clockLabel(Database* db, double epoch) {
    try {
        auto r = db->query(
            "SELECT to_char(to_timestamp($1::double precision) AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS s",
            {std::to_string(epoch)});
        if (!r.empty() && !r[0]["s"].is_null()) return r[0]["s"].c_str();
    } catch (const std::exception&) {}
    return "";
}

struct PlanOption {
    std::string kind;              // driver_home | rider_home | spot
    long long   spotId = 0;
    std::string spotName;
    double leaveEpoch  = 0;        // driver leaves home
    double pickupEpoch = 0;        // rider collected / everyone meets
    double extraMin    = 0;        // vs the driver's straight run
};

// The three pickup options for THIS driver and THIS request.  Empty when a
// coordinate is missing; `missing` says which one, for the no_geo copy.
std::vector<PlanOption> computePlans(Database* db, long long requestId,
                                     long long fhEventId, long long driverPersonId,
                                     std::string* missing) {
    std::vector<PlanOption> out;
    auto deadline = eventDeadlineEpoch(db, fhEventId);
    if (!deadline) { if (missing) *missing = "event_time"; return out; }
    auto venue = CarpoolRouting::eventVenue(fhEventId);
    if (!venue) { if (missing) *missing = "venue"; return out; }
    auto driver = CarpoolRouting::personHome(driverPersonId);
    if (!driver) { if (missing) *missing = "driver_address"; return out; }
    auto pickup = CarpoolRouting::requestPickup(requestId);
    if (!pickup) { if (missing) *missing = "pickup_address"; return out; }

    const TimingPolicy pol = timingPolicy(db);
    auto pad = [&](double rawMin) { return rawMin * pol.factor; };

    auto dv = CarpoolRouting::minutes(*driver, *venue);
    auto dr = CarpoolRouting::minutes(*driver, *pickup);
    auto rv = CarpoolRouting::minutes(*pickup, *venue);
    auto rd = CarpoolRouting::minutes(*pickup, *driver);
    if (!dv || !dr || !rv || !rd) { if (missing) *missing = "route"; return out; }
    const double base = pad(*dv) + pol.bufferMin;

    // 1. Rider comes to the driver's place; everyone leaves together.
    {
        PlanOption o; o.kind = "driver_home";
        o.leaveEpoch  = *deadline - base * 60.0;
        o.pickupEpoch = o.leaveEpoch;                 // be there by departure
        o.extraMin    = 0;
        out.push_back(o);
    }
    // 2. Driver detours via the rider's pickup address.
    {
        PlanOption o; o.kind = "rider_home";
        const double total = pad(*dr) + pad(*rv) + pol.bufferMin;
        o.leaveEpoch  = *deadline - total * 60.0;
        o.pickupEpoch = o.leaveEpoch + pad(*dr) * 60.0;
        o.extraMin    = std::max(0.0, std::round(total - base));
        out.push_back(o);
    }
    // 3. Meet at a neutral spot (carpool_spots rows; Lighthouse seeded).
    try {
        auto spots = db->query("SELECT id, name, latitude, longitude FROM carpool_spots WHERE is_active ORDER BY id");
        for (const auto& s : spots) {
            LatLon sp{s["latitude"].as<double>(), s["longitude"].as<double>()};
            auto ds = CarpoolRouting::minutes(*driver, sp);
            auto sv = CarpoolRouting::minutes(sp, *venue);
            if (!ds || !sv) continue;
            PlanOption o; o.kind = "spot";
            o.spotId = s["id"].as<long long>(); o.spotName = str(s, "name");
            const double total = pad(*ds) + pad(*sv) + pol.bufferMin;
            o.pickupEpoch = *deadline - (pad(*sv) + pol.bufferMin) * 60.0;   // meet time
            o.leaveEpoch  = o.pickupEpoch - pad(*ds) * 60.0;
            o.extraMin    = std::max(0.0, std::round(total - base));
            out.push_back(o);
        }
    } catch (const std::exception& e) {
        std::cerr << "[carpool computePlans spots] " << e.what() << std::endl;
    }
    return out;
}

json planOptionJson(Database* db, const PlanOption& o) {
    return {{"kind", o.kind},
            {"spotId", o.spotId ? json(o.spotId) : json(nullptr)},
            {"spotName", o.spotName.empty() ? json(nullptr) : json(o.spotName)},
            {"leaveAt", clockLabel(db, o.leaveEpoch)},
            {"pickupAt", clockLabel(db, o.pickupEpoch)},
            {"extraMinutes", static_cast<long long>(o.extraMin)}};
}

// The owner's nudge ("Carly is requesting ride. it would take you an
// addditional x minutes to pick her up"): detour-vs-straight minutes for
// THIS viewer, never the address.  nullopt = an estimate isn't possible.
std::optional<long long> nudgeExtraMinutes(Database* db, long long requestId,
                                           long long fhEventId, long long viewerPersonId) {
    auto venue = CarpoolRouting::eventVenue(fhEventId);
    if (!venue) return std::nullopt;
    auto driver = CarpoolRouting::personHome(viewerPersonId);
    if (!driver) return std::nullopt;
    auto pickup = CarpoolRouting::requestPickup(requestId);
    if (!pickup) return std::nullopt;
    auto dv = CarpoolRouting::minutes(*driver, *venue);
    auto dr = CarpoolRouting::minutes(*driver, *pickup);
    auto rv = CarpoolRouting::minutes(*pickup, *venue);
    if (!dv || !dr || !rv) return std::nullopt;
    const double factor = timingPolicy(db).factor;
    return static_cast<long long>(std::max(0.0, std::round((*dr + *rv - *dv) * factor)));
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
    router.get (prefix + "/requests/:id/options", [this](const Request& r) { return handleOptions(r); });
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
                   acp.phone_number AS ac_phone,
                   r.meet_kind, sp.name AS meet_spot, r.meet_extra_minutes,
                   to_char(r.meet_leave_at  AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS meet_leave,
                   to_char(r.meet_pickup_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS meet_pickup
              FROM fh_carpool_requests r
              LEFT JOIN carpool_spots sp ON sp.id = r.meet_spot_id
              JOIN persons p  ON p.id  = r.person_id
              JOIN persons rq ON rq.id = r.requested_by_person_id
              LEFT JOIN persons ac ON ac.id = r.accepted_by_person_id
              LEFT JOIN LATERAL (SELECT x.phone_number FROM person_phones x WHERE x.person_id = rq.id
                                  ORDER BY x.is_primary DESC NULLS LAST, x.id LIMIT 1) rqp ON true
              LEFT JOIN LATERAL (SELECT x.phone_number FROM person_phones x WHERE x.person_id = ac.id
                                  ORDER BY x.is_primary DESC NULLS LAST, x.id LIMIT 1) acp ON true
             WHERE r.fh_event_id = $1::bigint AND r.cancelled_at IS NULL
             ORDER BY (r.accepted_by_person_id IS NOT NULL), r.created_at)SQL", {eid});

        const bool staff = staffOnEvent(db, fhEventId, me);

        json requests = json::array();
        for (const auto& r : rows) {
            const long long requesterId = r["requested_by_person_id"].as<long long>();
            const long long driverId    = r["accepted_by_person_id"].is_null() ? 0 : r["accepted_by_person_id"].as<long long>();
            // Addresses are not public knowledge (owner 2026-10-19): only
            // the requester, the accepted driver, and the game's staff see
            // the pickup address — everyone else gets derived minutes only.
            const bool seeAddress = staff || requesterId == me.personId || driverId == me.personId;
            json acceptedBy = nullptr;
            if (driverId)
                acceptedBy = {{"personId", driverId},
                              {"name", str(r, "ac_name")},
                              {"phone", r["ac_phone"].is_null() ? json(nullptr) : json(str(r, "ac_phone"))}};
            // The personalized detour nudge, for a would-be driver on an
            // open request that isn't their own ask.
            json extra = nullptr;
            if (!driverId && requesterId != me.personId && r["person_id"].as<long long>() != me.personId) {
                auto n = nudgeExtraMinutes(db, r["id"].as<long long>(), fhEventId, me.personId);
                if (n) extra = *n;
            }
            json meetPlan = nullptr;
            if (!r["meet_kind"].is_null())
                meetPlan = {{"kind", str(r, "meet_kind")},
                            {"spot", r["meet_spot"].is_null() ? json(nullptr) : json(str(r, "meet_spot"))},
                            {"leaveAt", r["meet_leave"].is_null() ? json(nullptr) : json(str(r, "meet_leave"))},
                            {"pickupAt", r["meet_pickup"].is_null() ? json(nullptr) : json(str(r, "meet_pickup"))},
                            {"extraMinutes", r["meet_extra_minutes"].is_null() ? json(nullptr) : json(r["meet_extra_minutes"].as<long long>())}};
            requests.push_back({{"id", r["id"].as<long long>()},
                                {"personId", r["person_id"].as<long long>()},
                                {"name", str(r, "name")},
                                {"address1", seeAddress ? str(r, "address1") : ""},
                                {"address2", seeAddress ? str(r, "address2") : ""},
                                {"city",     seeAddress ? str(r, "city")     : ""},
                                {"state",    seeAddress ? str(r, "state")    : ""},
                                {"zip",      seeAddress ? str(r, "zip")      : ""},
                                {"note", str(r, "note")},
                                {"createdAt", str(r, "created_at")},
                                {"extraMinutes", extra},
                                {"meetPlan", meetPlan},
                                {"requestedBy", {{"personId", requesterId},
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

        long long newId = 0;
        try {
            auto ins = db->query(R"SQL(
                INSERT INTO fh_carpool_requests
                       (fh_event_id, person_id, requested_by_person_id,
                        address1, address2, city, state, zip, note)
                VALUES ($1::bigint, $2::int, $3::int, $4, $5, $6, $7, $8, $9)
                RETURNING id)SQL",
                {eid, rid, pid, field("address1"), field("address2"),
                 field("city"), field("state"), field("zip"), field("note")});
            if (!ins.empty()) newId = ins[0]["id"].as<long long>();
        } catch (const std::exception&) {
            return jsonError(HttpStatus::CONFLICT, "This player already has an open ride request for this game.");
        }
        // Warm the pickup geocode now (cached on the row, mig 609) so the
        // first driver's options and nudges answer from the DB.
        if (newId > 0) CarpoolRouting::requestPickup(newId);
        return jsonOut(HttpStatus::OK, {{"success", true}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/carpool/requests] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

// GET /api/carpool/requests/:id/options — the three timed pickup plans for
// THE VIEWER as prospective (or current) driver.  Owner 2026-10-19: option
// 1 ride to the driver's, option 2 driver detours to the rider, option 3 a
// neutral spot, each with when to leave to be there by the event's arrival
// time.  Works for games and practices alike (an fh_event is an fh_event).
Response CarpoolController::handleOptions(const Request& request) {
    const long long reqId = idAfter(request.getPath(), "/requests/");
    if (reqId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "request id");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    try {
        auto* db = Database::getInstance();
        Viewer me;
        if (!loadViewer(db, userId, &me)) return jsonError(HttpStatus::FORBIDDEN, "No person on this account.");
        auto rows = db->query(
            "SELECT fh_event_id, cancelled_at FROM fh_carpool_requests WHERE id = $1::int",
            {std::to_string(reqId)});
        if (rows.empty()) return jsonError(HttpStatus::NOT_FOUND, "No such request.");
        if (!rows[0]["cancelled_at"].is_null()) return jsonError(HttpStatus::CONFLICT, "This request was cancelled.");
        const long long fhEventId = rows[0]["fh_event_id"].as<long long>();
        if (!allowedOnEvent(db, fhEventId, me)) return jsonError(HttpStatus::FORBIDDEN, "Carpool is for people on this game.");

        std::string missing;
        auto plans = computePlans(db, reqId, fhEventId, me.personId, &missing);
        json options = json::array();
        for (const auto& o : plans) options.push_back(planOptionJson(db, o));
        return jsonOut(HttpStatus::OK, {{"success", true}, {"options", options},
                                        {"missing", missing.empty() ? json(nullptr) : json(missing)}});
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/carpool/options] " << e.what() << std::endl;
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
            // The driver may name the pickup plan (migs 608/609).  Times are
            // recomputed server-side from the chosen option — a stale or
            // hand-rolled body can't store made-up times.  No plan (or no
            // estimate possible) still accepts; the card just has no times.
            std::string meetKind, meetSpot;
            try {
                auto body = json::parse(request.getBody().empty() ? "{}" : request.getBody());
                meetKind = body.value("meet_kind", std::string(""));
                if (body.contains("meet_spot_id") && body["meet_spot_id"].is_number())
                    meetSpot = std::to_string(body["meet_spot_id"].get<long long>());
            } catch (...) { /* plain accept */ }
            std::string leaveEpoch, pickupEpoch, extraMin;
            if (meetKind == "driver_home" || meetKind == "rider_home" || meetKind == "spot") {
                std::string missing;
                for (const auto& o : computePlans(db, reqId, fhEventId, me.personId, &missing)) {
                    if (o.kind != meetKind) continue;
                    if (meetKind == "spot" && std::to_string(o.spotId) != meetSpot) continue;
                    leaveEpoch  = std::to_string(o.leaveEpoch);
                    pickupEpoch = std::to_string(o.pickupEpoch);
                    extraMin    = std::to_string(static_cast<long long>(o.extraMin));
                    break;
                }
            } else {
                meetKind.clear(); meetSpot.clear();
            }
            db->query(
                "UPDATE fh_carpool_requests SET accepted_by_person_id = $2::int, accepted_at = now(), "
                "       meet_kind = NULLIF($3, ''), meet_spot_id = NULLIF($4, '')::int, "
                "       meet_leave_at  = CASE WHEN $5 = '' THEN NULL ELSE to_timestamp($5::double precision) END, "
                "       meet_pickup_at = CASE WHEN $6 = '' THEN NULL ELSE to_timestamp($6::double precision) END, "
                "       meet_extra_minutes = NULLIF($7, '')::int "
                "WHERE id = $1::int AND cancelled_at IS NULL AND accepted_by_person_id IS NULL",
                {id, pid, meetKind, meetSpot, leaveEpoch, pickupEpoch, extraMin});
        } else if (action == "unaccept") {
            if (driverId != me.personId && !me.isAdmin)
                return jsonError(HttpStatus::FORBIDDEN, "Only the driver can step back.");
            db->query("UPDATE fh_carpool_requests SET accepted_by_person_id = NULL, accepted_at = NULL, "
                      "       meet_kind = NULL, meet_spot_id = NULL, meet_leave_at = NULL, meet_pickup_at = NULL "
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
