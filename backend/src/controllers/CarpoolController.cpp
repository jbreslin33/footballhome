#include "CarpoolController.h"

#include <cmath>
#include <iomanip>
#include <iostream>
#include <optional>
#include <sstream>

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
                              AND NOT fh_team_callup_only(tp.team_id) AND NOT tp.invite_only
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
                    WHERE fh_is_guardian($2::int, c.id))
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

// View-as (2026-10-20): `?asPersonId=N` on the two GETs renders the
// carpool exactly as that person sees it — same read-only, admin-gated
// contract as MyController::applyImpersonation.  The admin bit is dropped
// too, so the impersonated view is the person's real one (no staff
// dropdown, their own family's buttons).  Writes never honour it.
void applyViewAs(const Request& request, Viewer* v) {
    if (!v->isAdmin) return;
    const std::string q = request.getQueryParam("asPersonId");
    if (q.empty()) return;
    long long target = 0;
    try { target = std::stoll(q); } catch (...) { return; }
    if (target <= 0 || target == v->personId) return;
    v->personId = target;
    v->isAdmin  = false;
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
    std::string kind;              // driver_home | rider_home | spot | midpoint
    long long   spotId = 0;
    std::string spotName;          // spot row's name, or the midpoint's address
    double leaveEpoch  = 0;        // driver leaves home
    double pickupEpoch = 0;        // rider collected / everyone meets
    double extraMin    = 0;        // vs the driver's straight run
    double midLat = 0, midLon = 0; // midpoint only — pinned at accept
};

// The rider's multi-select (mig 610): which plan kinds the driver may pick.
struct Willing { bool riderHome = true, driverHome = true, spot = true, midpoint = true; };

Willing requestWilling(Database* db, long long requestId) {
    Willing w;
    try {
        auto r = db->query(
            "SELECT willing_rider_home, willing_driver_home, willing_spot, willing_midpoint "
            "  FROM fh_carpool_requests WHERE id = $1::int", {std::to_string(requestId)});
        if (!r.empty()) {
            w.riderHome  = r[0]["willing_rider_home"].as<bool>();
            w.driverHome = r[0]["willing_driver_home"].as<bool>();
            w.spot       = r[0]["willing_spot"].as<bool>();
            w.midpoint   = r[0]["willing_midpoint"].as<bool>();
        }
    } catch (const std::exception& e) {
        std::cerr << "[carpool requestWilling] " << e.what() << std::endl;
    }
    return w;
}

// The pickup options for THIS driver and THIS request — only the kinds the
// rider said they're willing to do (mig 610); the driver single-selects one.
// Empty when a coordinate is missing; `missing` says which, for no_geo copy.
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

    const Willing will = requestWilling(db, requestId);
    const TimingPolicy pol = timingPolicy(db);
    auto pad = [&](double rawMin) { return rawMin * pol.factor; };

    auto dv = CarpoolRouting::minutes(*driver, *venue);
    auto dr = CarpoolRouting::minutes(*driver, *pickup);
    auto rv = CarpoolRouting::minutes(*pickup, *venue);
    auto rd = CarpoolRouting::minutes(*pickup, *driver);
    if (!dv || !dr || !rv || !rd) { if (missing) *missing = "route"; return out; }
    const double base = pad(*dv) + pol.bufferMin;

    // 1. Rider comes to the driver's place; everyone leaves together.
    if (will.driverHome) {
        PlanOption o; o.kind = "driver_home";
        o.leaveEpoch  = *deadline - base * 60.0;
        o.pickupEpoch = o.leaveEpoch;                 // be there by departure
        o.extraMin    = 0;
        out.push_back(o);
    }
    // 2. Driver detours via the rider's pickup address.
    if (will.riderHome) {
        PlanOption o; o.kind = "rider_home";
        const double total = pad(*dr) + pad(*rv) + pol.bufferMin;
        o.leaveEpoch  = *deadline - total * 60.0;
        o.pickupEpoch = o.leaveEpoch + pad(*dr) * 60.0;
        o.extraMin    = std::max(0.0, std::round(total - base));
        out.push_back(o);
    }
    // 3. Meet at a neutral spot (carpool_spots rows; Lighthouse seeded).
    if (will.spot) try {
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
    // 4. A neutral point computed between the two homes (owner 2026-10-19:
    //    "get picked up at an agreed upon neutral site (which you should
    //    help calculate and give address)") — halfway, reverse-geocoded to
    //    a street address.  Times must let BOTH parties get there.
    if (will.midpoint) {
        LatLon mid{(driver->lat + pickup->lat) / 2.0, (driver->lon + pickup->lon) / 2.0};
        auto dm = CarpoolRouting::minutes(*driver, mid);
        auto rm = CarpoolRouting::minutes(*pickup, mid);
        auto mv = CarpoolRouting::minutes(mid, *venue);
        if (dm && rm && mv) {
            PlanOption o; o.kind = "midpoint";
            o.midLat = mid.lat; o.midLon = mid.lon;
            auto addr = CarpoolRouting::reverseGeocode(mid);
            o.spotName = addr ? *addr : "";
            o.pickupEpoch = *deadline - (pad(*mv) + pol.bufferMin) * 60.0;   // meet time, for both
            o.leaveEpoch  = o.pickupEpoch - pad(*dm) * 60.0;                 // the driver's own departure
            const double total = pad(*dm) + pad(*mv) + pol.bufferMin;
            o.extraMin    = std::max(0.0, std::round(total - base));
            out.push_back(o);
        }
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
    router.post(prefix + "/:fhEventId/departures", [this](const Request& r) { return handleDepartureAdd(r); });
    router.post(prefix + "/departures/:id/join",   [this](const Request& r) { return handleDepartureAction(r, "join"); });
    router.post(prefix + "/departures/:id/leave",  [this](const Request& r) { return handleDepartureAction(r, "leave"); });
    router.post(prefix + "/departures/:id/remove", [this](const Request& r) { return handleDepartureAction(r, "remove"); });
    router.post(prefix + "/departures/:id/edit",   [this](const Request& r) { return handleDepartureAction(r, "edit"); });
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
        applyViewAs(request, &me);
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
                   r.meet_kind, sp.name AS meet_spot, r.meet_extra_minutes, r.meet_address,
                   r.willing_rider_home, r.willing_driver_home, r.willing_spot, r.willing_midpoint,
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
            if (!r["meet_kind"].is_null()) {
                // The midpoint's address is derived from two homes, so it
                // follows the same privacy rule as the pickup address.
                const std::string meetAddr = (seeAddress && !r["meet_address"].is_null()) ? str(r, "meet_address") : "";
                json spotName = r["meet_spot"].is_null() ? json(nullptr) : json(str(r, "meet_spot"));
                if (str(r, "meet_kind") == "midpoint") spotName = meetAddr.empty() ? json(nullptr) : json(meetAddr);
                meetPlan = {{"kind", str(r, "meet_kind")},
                            {"spot", spotName},
                            {"leaveAt", r["meet_leave"].is_null() ? json(nullptr) : json(str(r, "meet_leave"))},
                            {"pickupAt", r["meet_pickup"].is_null() ? json(nullptr) : json(str(r, "meet_pickup"))},
                            {"extraMinutes", r["meet_extra_minutes"].is_null() ? json(nullptr) : json(r["meet_extra_minutes"].as<long long>())}};
            }
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
                                {"willing", {{"riderHome", r["willing_rider_home"].as<bool>()},
                                             {"driverHome", r["willing_driver_home"].as<bool>()},
                                             {"spot", r["willing_spot"].as<bool>()},
                                             {"midpoint", r["willing_midpoint"].as<bool>()}}},
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
                   -- Me or one of my kids (any parent, mig 682).
                   mk.mine,
                   COALESCE(a.address1, CASE WHEN mk.mine THEN va.address1 END, '') AS address1,
                   COALESCE(a.address2, CASE WHEN mk.mine THEN va.address2 END, '') AS address2,
                   COALESCE(a.city,     CASE WHEN mk.mine THEN va.city     END, '') AS city,
                   COALESCE(a.state,    CASE WHEN mk.mine THEN va.state    END, '') AS state,
                   COALESCE(a.zip,      CASE WHEN mk.mine THEN va.zip      END, '') AS zip
              FROM persons m
              CROSS JOIN LATERAL (SELECT (m.id = $2::int OR fh_is_guardian($2::int, m.id)) AS mine) mk
              LEFT JOIN LATERAL (SELECT * FROM person_addresses x
                                  WHERE x.person_id = m.id AND x.is_primary LIMIT 1) a ON true
              LEFT JOIN LATERAL (SELECT * FROM person_addresses x
                                  WHERE x.person_id = $2::int AND x.is_primary LIMIT 1) va ON true
             WHERE (mk.mine OR $3::bool)
               AND m.id IN (SELECT person_id FROM party)
             ORDER BY mk.mine DESC, m.first_name, m.last_name)SQL",
            {eid, pid, staff ? "true" : "false"});

        json riders = json::array();
        for (const auto& r : kids) {
            riders.push_back({{"personId", r["person_id"].as<long long>()},
                              {"name", str(r, "name")}, {"open", r["open"].as<bool>()},
                              {"mine", r["mine"].as<bool>()},
                              {"address1", str(r, "address1")}, {"address2", str(r, "address2")},
                              {"city", str(r, "city")}, {"state", str(r, "state")}, {"zip", str(r, "zip")}});
        }
        // 🚗 Carpools (migs 1101/1102/1104): one car each — driver, seats
        // (whole car), and its pickup stops (place + time) with who is
        // picked up where.
        json departures = json::array();
        auto paxAt = [&](const std::string& stopId) {
            json people = json::array();
            for (const auto& s : db->query(R"SQL(
                SELECT s.person_id,
                       NULLIF(trim(COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,'')), '') AS name,
                       COALESCE(s.person_id = $2::int OR fh_is_guardian($2::int, s.person_id), false) AS mine
                  FROM fh_event_departure_signups s JOIN persons p ON p.id = s.person_id
                 WHERE s.departure_id = $1::bigint AND s.left_at IS NULL AND s.role = 'rider'
                 ORDER BY s.created_at)SQL", {stopId, pid}))
                people.push_back({{"personId", s["person_id"].as<long long>()}, {"name", str(s, "name")},
                                  {"mine", s["mine"].as<bool>()}});
            return people;
        };
        for (const auto& d : db->query(R"SQL(
            SELECT d.id, d.seats, d.driver_person_id,
                   NULLIF(trim(COALESCE(dp.first_name,'') || ' ' || COALESCE(dp.last_name,'')), '') AS driver_name,
                   dp.first_name AS driver_first,
                   (SELECT x.phone_number FROM person_phones x WHERE x.person_id = dp.id
                     ORDER BY x.is_primary DESC NULLS LAST, x.id LIMIT 1) AS driver_phone
              FROM fh_event_departures d
              LEFT JOIN persons dp ON dp.id = d.driver_person_id
             WHERE d.fh_event_id = $1::bigint AND d.cancelled_at IS NULL AND d.stop_of IS NULL
             ORDER BY d.depart_at, d.id)SQL", {eid})) {
            json stops = json::array();
            for (const auto& st : db->query(R"SQL(
                SELECT d.id, d.place, COALESCE(d.address, '') AS address,
                       to_char(d.depart_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS depart_label,
                       to_char(d.depart_at AT TIME ZONE 'America/New_York', 'HH24:MI') AS depart_hhmm
                  FROM fh_event_departures d
                 WHERE (d.id = $1::bigint OR d.stop_of = $1::bigint) AND d.cancelled_at IS NULL
                 ORDER BY d.depart_at, d.id)SQL", {std::string(d["id"].c_str())}))
                stops.push_back({{"id", st["id"].as<long long>()}, {"place", str(st, "place")},
                                 {"address", str(st, "address")}, {"departLabel", str(st, "depart_label")},
                                 {"departHhmm", str(st, "depart_hhmm")}, {"passengers", paxAt(st["id"].c_str())}});
            const long long driverId = d["driver_person_id"].is_null() ? 0 : d["driver_person_id"].as<long long>();
            departures.push_back({{"id", d["id"].as<long long>()},
                                  {"seats", d["seats"].is_null() ? json(nullptr) : json(d["seats"].as<int>())},
                                  {"driver", {{"personId", driverId}, {"name", str(d, "driver_name")},
                                              {"firstName", str(d, "driver_first")},
                                              {"phone", d["driver_phone"].is_null() ? json(nullptr) : json(str(d, "driver_phone"))}}},
                                  {"canEdit", driverId == me.personId || me.isAdmin},
                                  {"stops", stops}});
        }
        // Anyone on the game (or its staff) may offer their car.
        const bool canCreate = staff || allowedOnEvent(db, fhEventId, me);
        return jsonOut(HttpStatus::OK, {{"success", true}, {"viewerPersonId", me.personId},
                                        {"requests", requests}, {"riders", riders},
                                        {"carpools", departures}, {"staff", staff}, {"canCreate", canCreate}});
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
                              AND ($4::bool OR m.id = $2::int OR fh_is_guardian($2::int, m.id))
                              AND m.id IN (SELECT person_id FROM party)) AS ok)SQL",
            {eid, pid, rid, staffOnEvent(db, fhEventId, me) ? "true" : "false"});
        if (ok.empty() || !ok[0]["ok"].as<bool>())
            return jsonError(HttpStatus::FORBIDDEN, "You can only request a ride for your own player on this game.");

        // The rider's multi-select (mig 610).  At least one way to meet must
        // survive, or no driver could ever accept.
        auto willing = [&](const char* k, bool dflt) { return body.contains(k) && body[k].is_boolean() ? body[k].get<bool>() : dflt; };
        const bool wRider  = willing("willing_rider_home", true);
        const bool wDriver = willing("willing_driver_home", false);
        const bool wSpot   = willing("willing_spot", false);
        const bool wMid    = willing("willing_midpoint", false);
        if (!wRider && !wDriver && !wSpot && !wMid)
            return jsonError(HttpStatus::BAD_REQUEST, "Pick at least one way the pickup could work.");

        long long newId = 0;
        try {
            auto ins = db->query(R"SQL(
                INSERT INTO fh_carpool_requests
                       (fh_event_id, person_id, requested_by_person_id,
                        address1, address2, city, state, zip, note,
                        willing_rider_home, willing_driver_home, willing_spot, willing_midpoint)
                VALUES ($1::bigint, $2::int, $3::int, $4, $5, $6, $7, $8, $9,
                        $10::bool, $11::bool, $12::bool, $13::bool)
                RETURNING id)SQL",
                {eid, rid, pid, field("address1"), field("address2"),
                 field("city"), field("state"), field("zip"), field("note"),
                 wRider ? "true" : "false", wDriver ? "true" : "false",
                 wSpot ? "true" : "false", wMid ? "true" : "false"});
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
        applyViewAs(request, &me);
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
            std::string leaveEpoch, pickupEpoch, extraMin, meetLat, meetLon, meetAddr;
            if (meetKind == "driver_home" || meetKind == "rider_home" || meetKind == "spot"
                || meetKind == "midpoint") {
                // computePlans only emits what the rider is willing to do
                // (mig 610), so a kind that matches nothing is either not
                // on offer or no longer estimable — the driver re-picks.
                bool matched = false;
                std::string missing;
                for (const auto& o : computePlans(db, reqId, fhEventId, me.personId, &missing)) {
                    if (o.kind != meetKind) continue;
                    if (meetKind == "spot" && std::to_string(o.spotId) != meetSpot) continue;
                    leaveEpoch  = std::to_string(o.leaveEpoch);
                    pickupEpoch = std::to_string(o.pickupEpoch);
                    extraMin    = std::to_string(static_cast<long long>(o.extraMin));
                    if (meetKind == "midpoint") {
                        std::ostringstream la, lo;
                        la << std::fixed << std::setprecision(7) << o.midLat;
                        lo << std::fixed << std::setprecision(7) << o.midLon;
                        meetLat = la.str(); meetLon = lo.str(); meetAddr = o.spotName;
                    }
                    matched = true;
                    break;
                }
                if (!matched)
                    return jsonError(HttpStatus::CONFLICT, "That option isn't available for this request — reopen the picker.");
            } else {
                meetKind.clear(); meetSpot.clear();
            }
            db->query(
                "UPDATE fh_carpool_requests SET accepted_by_person_id = $2::int, accepted_at = now(), "
                "       meet_kind = NULLIF($3, ''), meet_spot_id = NULLIF($4, '')::int, "
                "       meet_leave_at  = CASE WHEN $5 = '' THEN NULL ELSE to_timestamp($5::double precision) END, "
                "       meet_pickup_at = CASE WHEN $6 = '' THEN NULL ELSE to_timestamp($6::double precision) END, "
                "       meet_extra_minutes = NULLIF($7, '')::int, "
                "       meet_lat = NULLIF($8, '')::numeric, meet_lon = NULLIF($9, '')::numeric, "
                "       meet_address = NULLIF($10, '') "
                "WHERE id = $1::int AND cancelled_at IS NULL AND accepted_by_person_id IS NULL",
                {id, pid, meetKind, meetSpot, leaveEpoch, pickupEpoch, extraMin,
                 meetLat, meetLon, meetAddr});
        } else if (action == "unaccept") {
            if (driverId != me.personId && !me.isAdmin)
                return jsonError(HttpStatus::FORBIDDEN, "Only the driver can step back.");
            db->query("UPDATE fh_carpool_requests SET accepted_by_person_id = NULL, accepted_at = NULL, "
                      "       meet_kind = NULL, meet_spot_id = NULL, meet_leave_at = NULL, meet_pickup_at = NULL, "
                      "       meet_extra_minutes = NULL, meet_lat = NULL, meet_lon = NULL, meet_address = NULL "
                      "WHERE id = $1::int AND cancelled_at IS NULL", {id});
        } else if (action == "cancel") {
            // Whoever asked, the rider themselves or their parent (owner
            // 11/5: "gian should be able to delete his request").
            auto rider = db->query("SELECT r.person_id, fh_is_guardian($2::int, r.person_id) AS parent "
                                   "  FROM fh_carpool_requests r WHERE r.id = $1::int", {id, pid});
            const bool riderOrParent = !rider.empty() && (rider[0]["person_id"].as<long long>() == me.personId
                                       || (!rider[0]["parent"].is_null() && rider[0]["parent"].as<bool>()));
            if (requesterId != me.personId && !riderOrParent && !me.isAdmin)
                return jsonError(HttpStatus::FORBIDDEN, "Only the rider, their parent or whoever asked can cancel it.");
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

// ─── 🚗 Carpools (migs 1101/1102) ─────────────────────────────────────────
// One car each.  Creator = driver.  Only the driver or a club admin edits,
// adds/removes passengers or deletes; everyone else joins or leaves.

namespace {
// The time a carpool leaves: "HH:MM" on the event's own day (NY), or ISO.
const char* kDepartAtSql =
    "CASE WHEN $2 <> '' THEN $2::timestamptz "
    "     ELSE (((SELECT g.starts_at FROM fh_events f JOIN gcal_events g ON g.id = f.gcal_event_id WHERE f.id = $1::bigint) "
    "             AT TIME ZONE 'America/New_York')::date + $3::time) AT TIME ZONE 'America/New_York' END";
int seatsOf(const json& b) {
    if (b.contains("seats") && b["seats"].is_number_integer()) { const int n = b["seats"].get<int>(); if (n >= 2 && n <= 12) return n; }
    if (b.contains("seats") && b["seats"].is_string()) { try { const int n = std::stoi(b["seats"].get<std::string>()); if (n >= 2 && n <= 12) return n; } catch (...) {} }
    return 0;
}
}  // namespace

// POST /:fhEventId/departures {place, address?, time "HH:MM" | depart_at ISO, seats} — anyone on the game; they drive.
Response CarpoolController::handleDepartureAdd(const Request& request) {
    const long long fhEventId = idAfter(request.getPath(), "/carpool/");
    if (fhEventId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "event id");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    json b;
    try { b = json::parse(request.getBody().empty() ? "{}" : request.getBody()); } catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "bad JSON"); }
    const std::string place = b.value("place", ""), address = b.value("address", ""), note = b.value("note", "");
    const std::string hhmm = b.value("time", ""), iso = b.value("depart_at", "");
    const int seats = seatsOf(b);
    long long stopOf = 0;   // mig 1104: another pickup stop of this carpool
    if (b.contains("stop_of") && b["stop_of"].is_number_integer()) stopOf = b["stop_of"].get<long long>();
    if (place.find_first_not_of(" \t") == std::string::npos) return jsonError(HttpStatus::BAD_REQUEST, "Say where passengers meet you.");
    if (hhmm.empty() && iso.empty()) return jsonError(HttpStatus::BAD_REQUEST, "Pick the time you leave.");
    if (!seats && !stopOf) return jsonError(HttpStatus::BAD_REQUEST, "How many seats in the car, counting the driver? (2–12)");
    try {
        auto* db = Database::getInstance();
        Viewer me;
        if (!loadViewer(db, userId, &me)) return jsonError(HttpStatus::FORBIDDEN, "No person on this account.");
        if (!allowedOnEvent(db, fhEventId, me) && !staffOnEvent(db, fhEventId, me))
            return jsonError(HttpStatus::FORBIDDEN, "Carpools are for people on this game.");
        if (stopOf) {
            auto head = db->query("SELECT COALESCE(driver_person_id, 0) AS driver FROM fh_event_departures "
                                  " WHERE id = $1::bigint AND fh_event_id = $2::bigint AND stop_of IS NULL AND cancelled_at IS NULL",
                                  {std::to_string(stopOf), std::to_string(fhEventId)});
            if (head.empty()) return jsonError(HttpStatus::NOT_FOUND, "That carpool is gone.");
            if (head[0]["driver"].as<long long>() != me.personId && !me.isAdmin)
                return jsonError(HttpStatus::FORBIDDEN, "Only the driver adds stops.");
            auto r = db->query(std::string("INSERT INTO fh_event_departures (fh_event_id, place, address, depart_at, created_by_person_id, stop_of) "
                                           "SELECT $1::bigint, btrim($4), NULLIF(btrim($5), ''), ") + kDepartAtSql +
                               ", $6::int, $7::bigint RETURNING id",
                               {std::to_string(fhEventId), iso, hhmm.empty() ? "00:00" : hhmm, place, address,
                                std::to_string(me.personId), std::to_string(stopOf)});
            return jsonOut(HttpStatus::CREATED, {{"success", true}, {"id", r[0]["id"].as<long long>()}});
        }
        auto r = db->query(std::string("INSERT INTO fh_event_departures (fh_event_id, place, address, depart_at, note, created_by_person_id, driver_person_id, seats) "
                                       "SELECT $1::bigint, btrim($4), NULLIF(btrim($5), ''), ") + kDepartAtSql +
                           ", NULLIF(btrim($6), ''), $7::int, $7::int, $8::int RETURNING id",
                           {std::to_string(fhEventId), iso, hhmm.empty() ? "00:00" : hhmm, place, address, note,
                            std::to_string(me.personId), std::to_string(seats)});
        // The driver isn't anyone's passenger any more.
        db->query("UPDATE fh_event_departure_signups SET left_at = now() WHERE fh_event_id = $1::bigint AND person_id = $2::int AND left_at IS NULL",
                  {std::to_string(fhEventId), std::to_string(me.personId)});
        return jsonOut(HttpStatus::CREATED, {{"success", true}, {"id", r[0]["id"].as<long long>()}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/carpool/departures] " << e.what() << std::endl;
        return jsonError(HttpStatus::BAD_REQUEST, "Could not create that carpool — check the time.");
    }
}

// POST /departures/:id/join|leave {person_id}; /edit {place,address,time,seats,driver_person_id}; /remove.
Response CarpoolController::handleDepartureAction(const Request& request, const std::string& action) {
    const long long depId = idAfter(request.getPath(), "/departures/");
    if (depId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "carpool id");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    json b;
    try { b = json::parse(request.getBody().empty() ? "{}" : request.getBody()); } catch (...) { b = json::object(); }
    try {
        auto* db = Database::getInstance();
        Viewer me;
        if (!loadViewer(db, userId, &me)) return jsonError(HttpStatus::FORBIDDEN, "No person on this account.");
        // The stop and its carpool (mig 1104): driver + seats live on the carpool row.
        auto dep = db->query("SELECT d.fh_event_id, COALESCE(h.driver_person_id, 0) AS driver, h.seats, h.id AS head, "
                             "       (d.stop_of IS NULL) AS is_head "
                             "  FROM fh_event_departures d JOIN fh_event_departures h ON h.id = COALESCE(d.stop_of, d.id) "
                             " WHERE d.id = $1::bigint AND d.cancelled_at IS NULL AND h.cancelled_at IS NULL", {std::to_string(depId)});
        if (dep.empty()) return jsonError(HttpStatus::NOT_FOUND, "That carpool is gone.");
        const long long fhEventId = dep[0]["fh_event_id"].as<long long>();
        const long long driverId = dep[0]["driver"].as<long long>();
        const std::string eid = std::to_string(fhEventId), did = std::to_string(depId);
        const bool owner = driverId == me.personId || me.isAdmin;   // "others can't change the one created"
        const std::string headId = dep[0]["head"].c_str();
        const bool isHead = dep[0]["is_head"].as<bool>();
        if (action == "remove") {
            if (!owner) return jsonError(HttpStatus::FORBIDDEN, "Only the driver can delete this carpool.");
            // The carpool row takes its stops with it; a stop goes alone.
            const char* which = isHead ? "(id = $1::bigint OR stop_of = $1::bigint)" : "id = $1::bigint";
            db->query(std::string("UPDATE fh_event_departure_signups SET left_at = now() WHERE left_at IS NULL "
                                  " AND departure_id IN (SELECT id FROM fh_event_departures WHERE ") + which + ")", {did});
            db->query(std::string("UPDATE fh_event_departures SET cancelled_at = now() WHERE cancelled_at IS NULL AND ") + which, {did});
            return jsonOut(HttpStatus::OK, {{"success", true}});
        }
        if (action == "edit") {
            if (!owner) return jsonError(HttpStatus::FORBIDDEN, "Only the driver can change this carpool.");
            const std::string place = b.value("place", ""), address = b.value("address", ""), hhmm = b.value("time", "");
            const int seats = seatsOf(b);
            long long newDriver = 0;
            if (b.contains("driver_person_id") && b["driver_person_id"].is_number_integer()) newDriver = b["driver_person_id"].get<long long>();
            if (newDriver > 0 && newDriver != driverId) {
                Viewer nd; nd.personId = newDriver;
                if (!allowedOnEvent(db, fhEventId, nd) && !staffOnEvent(db, fhEventId, nd))
                    return jsonError(HttpStatus::BAD_REQUEST, "The new driver has to be on this game.");
            }
            db->query(std::string("UPDATE fh_event_departures SET "
                      " place = COALESCE(NULLIF(btrim($4), ''), place), "
                      " address = CASE WHEN $9 = '1' THEN NULLIF(btrim($5), '') ELSE address END, "
                      " depart_at = CASE WHEN $10 = '1' THEN ") + kDepartAtSql + " ELSE depart_at END, "
                      " seats = CASE WHEN stop_of IS NULL THEN COALESCE(NULLIF($6, '0')::int, seats) ELSE seats END, "
                      " driver_person_id = CASE WHEN stop_of IS NULL THEN COALESCE(NULLIF($7, '0')::int, driver_person_id) ELSE driver_person_id END "
                      " WHERE id = $8::bigint",
                      {eid, std::string(""), hhmm.empty() ? std::string("00:00") : hhmm, place, address, std::to_string(seats),
                       std::to_string(newDriver), did, b.contains("address") ? "1" : "0", hhmm.empty() ? "0" : "1"});
            if (newDriver > 0)
                db->query("UPDATE fh_event_departure_signups SET left_at = now() WHERE fh_event_id = $1::bigint AND person_id = $2::int AND left_at IS NULL",
                          {eid, std::to_string(newDriver)});
            return jsonOut(HttpStatus::OK, {{"success", true}});
        }
        long long personId = 0;
        if (b.contains("person_id") && b["person_id"].is_number_integer()) personId = b["person_id"].get<long long>();
        if (personId <= 0) personId = me.personId;
        const std::string pid = std::to_string(personId);
        // Yourself or your own kid — the driver / an admin for anyone.
        auto mine = db->query("SELECT COALESCE($1::int = $2::int OR fh_is_guardian($2::int, $1::int), false) AS ok",
                              {pid, std::to_string(me.personId)});
        if (!owner && !mine[0]["ok"].as<bool>())
            return jsonError(HttpStatus::FORBIDDEN, "You can sign up yourself or your own kids.");
        if (action == "leave") {
            db->query("UPDATE fh_event_departure_signups SET left_at = now() "
                      " WHERE departure_id = $1::bigint AND person_id = $2::int AND left_at IS NULL", {did, pid});
            return jsonOut(HttpStatus::OK, {{"success", true}});
        }
        // join as a passenger
        if (personId == driverId) return jsonError(HttpStatus::BAD_REQUEST, "That's the driver.");
        Viewer who; who.personId = personId;
        if (!allowedOnEvent(db, fhEventId, who) && !staffOnEvent(db, fhEventId, who))
            return jsonError(HttpStatus::FORBIDDEN, "Only people on this game can ride.");
        auto tx = db->beginTransaction();
        tx->exec_params("SELECT 1 FROM fh_event_departures WHERE id = $1::bigint FOR UPDATE", headId);
        // Seats are shared by every stop of the carpool (mig 1104).
        auto taken = tx->exec_params("SELECT count(*) AS n FROM fh_event_departure_signups s "
                                     "  JOIN fh_event_departures d ON d.id = s.departure_id "
                                     " WHERE (d.id = $1::bigint OR d.stop_of = $1::bigint) AND s.left_at IS NULL "
                                     "   AND s.role = 'rider' AND s.person_id <> $2::int", headId, pid);
        // seats = the whole car, driver included (owner 11/5: "1 seat is taken by
        // driver but include it") → passengers fit in seats − 1.
        if (!dep[0]["seats"].is_null() && taken[0]["n"].as<long long>() >= dep[0]["seats"].as<long long>() - 1)
            return jsonError(HttpStatus::CONFLICT, "That carpool is full.");
        tx->exec_params("UPDATE fh_event_departure_signups SET left_at = now() "
                        " WHERE fh_event_id = $1::bigint AND person_id = $2::int AND left_at IS NULL", eid, pid);
        tx->exec_params("INSERT INTO fh_event_departure_signups (departure_id, fh_event_id, person_id, role, signed_by_person_id) "
                        "VALUES ($1::bigint, $2::bigint, $3::int, 'rider', $4::int)", did, eid, pid, std::to_string(me.personId));
        // A passenger no longer needs their own ride request (owner 11/5).
        tx->exec_params("UPDATE fh_carpool_requests SET cancelled_at = now(), cancelled_by_person_id = $3::int "
                        " WHERE fh_event_id = $1::bigint AND person_id = $2::int AND cancelled_at IS NULL",
                        eid, pid, std::to_string(me.personId));
        tx->commit();
        return jsonOut(HttpStatus::OK, {{"success", true}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/carpool/departures/" << action << "] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not save — try again.");
    }
}
