#include "CoachScheduleController.h"

#include <iostream>
#include <regex>

#include "../database/Database.h"
#include "../models/MessageCopy.h"
#include "../services/MagicLinkService.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

long long idOf(const std::string& s) {
    try { return std::stoll(s); } catch (...) { return 0; }
}

// /api/coach-schedule/cover/<id>/<action> → id, action.
bool coverPath(const std::string& path, long long* id, std::string* action) {
    static const std::regex re(R"(/cover/(\d+)/([a-z]+)/?(?:\?.*)?$)");
    std::smatch m;
    if (!std::regex_search(path, m, re)) return false;
    *id = idOf(m[1].str());
    *action = m[2].str();
    return *id > 0;
}

json parseBody(const Request& request) {
    const std::string& b = request.getBody();
    return b.empty() ? json::object() : json::parse(b);
}

std::string str(long long v) { return std::to_string(v); }

// The coach's session list, as the GET sends it.
json sessionsOf(long long coachId) {
    auto r = Database::getInstance()->query(R"SQL(
        SELECT COALESCE(json_agg(json_build_object('isodow', x.isodow, 'starts_at', to_char(x.starts_at, 'HH24:MI'))
                                 ORDER BY x.isodow, x.starts_at), '[]')::text AS s,
               EXISTS (SELECT 1 FROM coach_session_plans WHERE coach_id = $1::int) AS has_plan
          FROM coach_sessions x WHERE x.coach_id = $1::int)SQL", {str(coachId)});
    return {{"sessions", json::parse(r[0]["s"].c_str())}, {"has_plan", r[0]["has_plan"].as<bool>()}};
}

}  // namespace

void CoachScheduleController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix,                        [this](const Request& r) { return handleGet(r); });
    router.get (prefix + "/event/:id",         [this](const Request& r) { return handleEventCovers(r); });
    router.post(prefix + "/session",           [this](const Request& r) { return handleSession(r); });
    router.post(prefix + "/plan",              [this](const Request& r) { return handlePlan(r); });
    router.post(prefix + "/cover",             [this](const Request& r) { return handleCoverCreate(r); });
    router.post(prefix + "/cover/:id/take",    [this](const Request& r) { return handleCoverAction(r); });
    router.post(prefix + "/cover/:id/withdraw",[this](const Request& r) { return handleCoverAction(r); });
    router.post(prefix + "/cover/:id/text",    [this](const Request& r) { return handleCoverAction(r); });
}

// Club admins and active coaches; 403 (not 401) keeps a signed-in player's session.
bool CoachScheduleController::gate(const Request& request, Caller* caller, Response* error) {
    if (!requireBearer(request)) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return false;
    }
    caller->userId = bearerUserId(request);
    auto r = Database::getInstance()->query(R"SQL(
        SELECT EXISTS (SELECT 1 FROM admins WHERE user_id = $1::int) AS admin,
               (SELECT co.id FROM users u
                  JOIN coaches co ON co.person_id = u.person_id
                 WHERE u.id = $1::int
                   AND EXISTS (SELECT 1 FROM team_coaches tc JOIN teams t ON t.id = tc.team_id AND t.is_active
                                WHERE tc.coach_id = co.id AND tc.ended_at IS NULL)
                 ORDER BY co.id LIMIT 1) AS coach_id)SQL", {str(caller->userId)});
    caller->admin = r[0]["admin"].as<bool>();
    caller->coachId = r[0]["coach_id"].is_null() ? 0 : r[0]["coach_id"].as<long long>();
    if (caller->admin || caller->coachId > 0) return true;
    *error = jsonError(HttpStatus::FORBIDDEN, "The coach schedule is for coaches and club admins.");
    return false;
}

Response CoachScheduleController::handleGet(const Request& request) {
    Caller me;
    Response denied(HttpStatus::FORBIDDEN, "");
    if (!gate(request, &me, &denied)) return denied;
    std::string week = request.getQueryParam("week");
    if (!std::regex_match(week, std::regex(R"(\d{4}-\d{2}-\d{2})"))) week.clear();
    // ?cover=<id> (the cover text's link) opens the week of that ask's event.
    std::string cover = request.getQueryParam("cover");
    if (!std::regex_match(cover, std::regex(R"(\d{1,18})"))) cover = "0";
    try {
        // One document: the standing week, every coach, and one real week.
        auto r = Database::getInstance()->query(R"SQL(
            WITH wk AS (
                SELECT date_trunc('week', COALESCE(NULLIF($1, '')::date,
                       (SELECT (ge.starts_at AT TIME ZONE 'America/New_York')::date
                          FROM coach_covers cc JOIN fh_events fe ON fe.id = cc.fh_event_id
                          JOIN gcal_events ge ON ge.id = fe.gcal_event_id WHERE cc.id = $2::bigint),
                       (now() AT TIME ZONE 'America/New_York')::date))::date AS d
            ), staff AS (
                SELECT c.id AS coach_id, p.id AS person_id, p.first_name,
                       BTRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')) AS name
                  FROM coaches c JOIN persons p ON p.id = c.person_id
                 WHERE EXISTS (SELECT 1 FROM team_coaches tc JOIN teams t ON t.id = tc.team_id AND t.is_active
                                WHERE tc.coach_id = c.id AND tc.ended_at IS NULL)
            ), ev AS (
                SELECT fe.id, fe.kind, ge.status = 'cancelled' AS cancelled,
                       ge.starts_at, ge.ends_at,
                       regexp_replace(COALESCE(ge.summary, ''), '^\s*Soccer\s+', '', 'i') AS label
                  FROM wk
                  JOIN gcal_events ge ON ge.starts_at >= wk.d::timestamp AT TIME ZONE 'America/New_York'
                                     AND ge.starts_at <  (wk.d + 7)::timestamp AT TIME ZONE 'America/New_York'
                                     AND ge.deleted_at IS NULL
                  JOIN fh_events fe ON fe.gcal_event_id = ge.id AND fe.kind IN ('practice', 'match')
            )
            SELECT json_build_object(
              'sessions', (SELECT COALESCE(json_agg(json_build_object(
                                'isodow', s.isodow, 'starts_at', to_char(s.starts_at, 'HH24:MI'),
                                'ends_at', to_char(s.ends_at, 'HH24:MI'), 'label', s.label,
                                'teams', s.teams, 'team_ids', COALESCE(s.team_ids, '{}'))
                                ORDER BY s.isodow, s.starts_at), '[]')
                             FROM fh_practice_sessions() s),
              'coaches', (SELECT COALESCE(json_agg(json_build_object(
                                'coach_id', st.coach_id, 'person_id', st.person_id, 'name', st.name,
                                'first', st.first_name, 'phone', fh_recipient_phone(st.person_id, st.person_id),
                                'has_plan', EXISTS (SELECT 1 FROM coach_session_plans pl WHERE pl.coach_id = st.coach_id),
                                'sessions', (SELECT COALESCE(json_agg(json_build_object('isodow', x.isodow, 'starts_at', to_char(x.starts_at, 'HH24:MI'))
                                                             ORDER BY x.isodow, x.starts_at), '[]')
                                               FROM coach_sessions x WHERE x.coach_id = st.coach_id),
                                'team_ids', (SELECT COALESCE(json_agg(DISTINCT tc.team_id), '[]')
                                               FROM team_coaches tc JOIN teams t ON t.id = tc.team_id AND t.is_active
                                              WHERE tc.coach_id = st.coach_id AND tc.ended_at IS NULL),
                                -- weekend duty: their teams with a game in the next 8 weeks
                                'game_teams', (SELECT string_agg(DISTINCT t.name, ', ')
                                                 FROM team_coaches tc JOIN teams t ON t.id = tc.team_id AND t.is_active
                                                WHERE tc.coach_id = st.coach_id AND tc.ended_at IS NULL
                                                  AND EXISTS (SELECT 1 FROM fh_event_teams fet
                                                                JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'match'
                                                                JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                                                               WHERE fet.team_id = t.id AND ge.deleted_at IS NULL
                                                                 AND ge.starts_at >= now() AND ge.starts_at < now() + interval '56 days')))
                                ORDER BY st.name), '[]')
                            FROM staff st),
              'week', json_build_object(
                'start', (SELECT to_char(d, 'YYYY-MM-DD') FROM wk),
                'events', (SELECT COALESCE(json_agg(json_build_object(
                    'fh_event_id', ev.id, 'kind', ev.kind, 'cancelled', ev.cancelled, 'label', ev.label,
                    'day', to_char(ev.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD'),
                    'isodow', extract(isodow FROM ev.starts_at AT TIME ZONE 'America/New_York')::int,
                    'starts_at', to_char(ev.starts_at AT TIME ZONE 'America/New_York', 'HH24:MI'),
                    'ends_at', to_char(ev.ends_at AT TIME ZONE 'America/New_York', 'HH24:MI'),
                    'past', ev.starts_at < now(),
                    'teams', (SELECT string_agg(t.name, ', ' ORDER BY t.name)
                                FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id WHERE fet.fh_event_id = ev.id),
                    -- who is on it: their teams' coaches the rule keeps, and whoever covers
                    'coach_ids', (SELECT COALESCE(json_agg(DISTINCT x.cid), '[]') FROM (
                        SELECT tc.coach_id AS cid
                          FROM fh_event_teams fet
                          JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
                          JOIN coaches c ON c.id = tc.coach_id
                         WHERE fet.fh_event_id = ev.id
                           AND NOT fh_coach_off_schedule(c.person_id, tc.team_id, ev.id)
                        UNION
                        -- covering it / its slot is their session (migs 1640, 1643)
                        SELECT xc.coach_id FROM fh_event_extra_coaches(ev.id) xc) x),
                    'covers', (SELECT COALESCE(json_agg(json_build_object(
                                   'id', cc.id, 'coach_id', cc.coach_id, 'status', cc.status,
                                   'cover_coach_id', cc.cover_coach_id, 'note', cc.note,
                                   'asked', (SELECT COALESCE(json_agg(a.coach_id), '[]') FROM coach_cover_asks a WHERE a.cover_id = cc.id))
                                   ORDER BY cc.id), '[]')
                                 FROM coach_covers cc WHERE cc.fh_event_id = ev.id AND cc.status <> 'withdrawn'))
                    ORDER BY ev.starts_at, ev.id), '[]') FROM ev))
            )::text AS doc)SQL", {week, cover});
        json out = json::parse(r[0]["doc"].c_str());
        out["me"] = {{"coach_id", me.coachId > 0 ? json(me.coachId) : json(nullptr)}, {"is_admin", me.admin}};
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "CoachScheduleController::handleGet: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the coach schedule");
    }
}

// The cover asks on one event, for its page's banner (mig 1640): who asked,
// who covers, and whether the caller was asked / may take it.
Response CoachScheduleController::handleEventCovers(const Request& request) {
    Caller me;
    Response denied(HttpStatus::FORBIDDEN, "");
    if (!gate(request, &me, &denied)) return denied;
    const std::string path = request.getPath().substr(0, request.getPath().find('?'));
    const long long eventId = idOf(path.substr(path.rfind('/') + 1));
    if (eventId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "Which event?");
    try {
        auto r = Database::getInstance()->query(R"SQL(
            SELECT COALESCE(json_agg(json_build_object(
                     'id', cc.id, 'status', cc.status, 'coach_id', cc.coach_id,
                     'coach', COALESCE(ap.first_name, ''), 'cover_coach_id', cc.cover_coach_id,
                     'cover', COALESCE(cp.first_name, ''),
                     'asked_me', EXISTS (SELECT 1 FROM coach_cover_asks a WHERE a.cover_id = cc.id AND a.coach_id = $2::int),
                     'asked', (SELECT COALESCE(json_agg(json_build_object('coach_id', a.coach_id, 'first', qp.first_name,
                                                   'texted', a.texted_at IS NOT NULL) ORDER BY qp.first_name), '[]')
                                 FROM coach_cover_asks a JOIN coaches q ON q.id = a.coach_id JOIN persons qp ON qp.id = q.person_id
                                WHERE a.cover_id = cc.id))
                     ORDER BY cc.id), '[]')::text AS covers,
                   bool_or(ge.ends_at < now()) AS past
              FROM coach_covers cc
              JOIN coaches ac ON ac.id = cc.coach_id JOIN persons ap ON ap.id = ac.person_id
              LEFT JOIN coaches cv ON cv.id = cc.cover_coach_id LEFT JOIN persons cp ON cp.id = cv.person_id
              JOIN fh_events fe ON fe.id = cc.fh_event_id JOIN gcal_events ge ON ge.id = fe.gcal_event_id
             WHERE cc.fh_event_id = $1::bigint AND cc.status <> 'withdrawn')SQL",
            {str(eventId), str(me.coachId)});
        // Asking from the event page (owner 11/20 "the coaches can request
        // sub from their cal"): is the caller a coach on it, and who to ask.
        auto ctx = Database::getInstance()->query(R"SQL(
            SELECT (SELECT ge.ends_at < now() FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                     WHERE fe.id = $1::bigint) AS past,
                   EXISTS (SELECT 1 FROM coaches c
                            WHERE c.id = $2::int
                              AND (EXISTS (SELECT 1 FROM fh_event_teams fet
                                             JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
                                            WHERE fet.fh_event_id = $1::bigint AND tc.coach_id = c.id
                                              AND NOT fh_coach_off_schedule(c.person_id, tc.team_id, $1::bigint))
                                   OR fh_event_covering($1::bigint, c.person_id))) AS me_on,
                   (SELECT COALESCE(json_agg(json_build_object('coach_id', c.id, 'first', p.first_name,
                                     'name', BTRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')),
                                     'has_phone', fh_recipient_phone(p.id, p.id) IS NOT NULL)
                                     ORDER BY p.first_name, p.last_name), '[]')
                      FROM coaches c JOIN persons p ON p.id = c.person_id
                     WHERE c.id <> $2::int
                       AND EXISTS (SELECT 1 FROM team_coaches tc JOIN teams t ON t.id = tc.team_id AND t.is_active
                                    WHERE tc.coach_id = c.id AND tc.ended_at IS NULL))::text AS coaches)SQL",
            {str(eventId), str(me.coachId)});
        return jsonOut(HttpStatus::OK, {
            {"covers", json::parse(r[0]["covers"].c_str())},
            {"past", !ctx[0]["past"].is_null() && ctx[0]["past"].as<bool>()},
            {"me_on", ctx[0]["me_on"].as<bool>()},
            {"coaches", json::parse(ctx[0]["coaches"].c_str())},
            {"me", {{"coach_id", me.coachId > 0 ? json(me.coachId) : json(nullptr)}, {"is_admin", me.admin}}}});
    } catch (const std::exception& e) {
        std::cerr << "CoachScheduleController::handleEventCovers: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the cover asks");
    }
}

// Add or drop one session for a coach.  A coach on every practice who loses
// one first gets a plan holding every session of their teams.
Response CoachScheduleController::handleSession(const Request& request) {
    Caller me;
    Response denied(HttpStatus::FORBIDDEN, "");
    if (!gate(request, &me, &denied)) return denied;
    if (!me.admin) return jsonError(HttpStatus::FORBIDDEN, "Only club admins change who covers which session.");
    long long coachId = 0; int isodow = 0; std::string startsAt; bool on = false;
    try {
        const json b = parseBody(request);
        coachId  = b.value("coach_id", 0LL);
        isodow   = b.value("isodow", 0);
        startsAt = b.value("starts_at", std::string{});
        on       = b.value("on", false);
    } catch (const std::exception&) {
        return jsonError(HttpStatus::BAD_REQUEST, "coach_id, isodow, starts_at and on are required");
    }
    if (coachId <= 0 || isodow < 1 || isodow > 7 || !std::regex_match(startsAt, std::regex(R"(\d{2}:\d{2})")))
        return jsonError(HttpStatus::BAD_REQUEST, "coach_id, isodow (1-7) and starts_at (HH:MM) are required");
    try {
        auto* db = Database::getInstance();
        const auto plan = db->query("SELECT 1 FROM coach_session_plans WHERE coach_id = $1::int", {str(coachId)});
        if (plan.empty()) {
            // Their plan starts as what they have now (every session of their
            // teams), then this tap changes one: on adds a session of other
            // teams (mig 1643), off drops one.
            db->query(R"SQL(
                WITH p AS (INSERT INTO coach_session_plans (coach_id) VALUES ($1::int)
                           ON CONFLICT (coach_id) DO NOTHING RETURNING coach_id)
                INSERT INTO coach_sessions (coach_id, isodow, starts_at)
                SELECT DISTINCT p.coach_id, s.isodow, s.starts_at
                  FROM p
                  JOIN team_coaches tc ON tc.coach_id = p.coach_id AND tc.ended_at IS NULL
                  JOIN fh_practice_sessions() s ON tc.team_id = ANY (s.team_ids)
                ON CONFLICT DO NOTHING)SQL", {str(coachId)});
        }
        if (on)
            db->query("INSERT INTO coach_sessions (coach_id, isodow, starts_at) VALUES ($1::int, $2::smallint, $3::time) ON CONFLICT DO NOTHING",
                      {str(coachId), std::to_string(isodow), startsAt});
        else
            db->query("DELETE FROM coach_sessions WHERE coach_id = $1::int AND isodow = $2::smallint AND starts_at = $3::time",
                      {str(coachId), std::to_string(isodow), startsAt});
        return jsonOut(HttpStatus::OK, sessionsOf(coachId));
    } catch (const std::exception& e) {
        std::cerr << "CoachScheduleController::handleSession: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not save the session");
    }
}

// every = no plan (every practice of their teams); call_in = a plan, no sessions.
Response CoachScheduleController::handlePlan(const Request& request) {
    Caller me;
    Response denied(HttpStatus::FORBIDDEN, "");
    if (!gate(request, &me, &denied)) return denied;
    if (!me.admin) return jsonError(HttpStatus::FORBIDDEN, "Only club admins change who covers which session.");
    long long coachId = 0; std::string mode;
    try {
        const json b = parseBody(request);
        coachId = b.value("coach_id", 0LL);
        mode    = b.value("mode", std::string{});
    } catch (const std::exception&) {
        return jsonError(HttpStatus::BAD_REQUEST, "coach_id and mode are required");
    }
    if (coachId <= 0 || (mode != "every" && mode != "call_in"))
        return jsonError(HttpStatus::BAD_REQUEST, "mode must be every or call_in");
    try {
        auto* db = Database::getInstance();
        if (mode == "every") {
            db->query("DELETE FROM coach_session_plans WHERE coach_id = $1::int", {str(coachId)});
        } else {
            db->query("INSERT INTO coach_session_plans (coach_id) VALUES ($1::int) ON CONFLICT (coach_id) DO NOTHING", {str(coachId)});
            db->query("DELETE FROM coach_sessions WHERE coach_id = $1::int", {str(coachId)});
        }
        return jsonOut(HttpStatus::OK, sessionsOf(coachId));
    } catch (const std::exception& e) {
        std::cerr << "CoachScheduleController::handlePlan: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not save the plan");
    }
}

// A coach asks for cover on one event (an admin may ask for any coach).
Response CoachScheduleController::handleCoverCreate(const Request& request) {
    Caller me;
    Response denied(HttpStatus::FORBIDDEN, "");
    if (!gate(request, &me, &denied)) return denied;
    long long eventId = 0, coachId = 0; std::string note; std::string asks = "{";
    try {
        const json b = parseBody(request);
        eventId = b.value("fh_event_id", 0LL);
        coachId = b.value("coach_id", me.coachId);
        if (b.contains("note") && b["note"].is_string()) note = b["note"].get<std::string>();
        if (b.contains("ask") && b["ask"].is_array())
            for (const auto& v : b["ask"]) if (v.is_number_integer() && v.get<long long>() > 0)
                asks += (asks.size() > 1 ? "," : "") + std::to_string(v.get<long long>());
    } catch (const std::exception&) {
        return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id and ask are required");
    }
    asks += "}";
    if (eventId <= 0 || coachId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "fh_event_id and coach_id are required");
    if (!me.admin && coachId != me.coachId) return jsonError(HttpStatus::FORBIDDEN, "You can ask cover for your own sessions and games.");
    if (note.size() > 500) note.resize(500);
    try {
        auto* db = Database::getInstance();
        auto ev = db->query(R"SQL(
            SELECT 1 FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
             WHERE fe.id = $1::bigint AND ge.deleted_at IS NULL AND ge.ends_at > now())SQL", {str(eventId)});
        if (ev.empty()) return jsonError(HttpStatus::NOT_FOUND, "That event is over or not on the calendar.");
        auto cover = db->query(R"SQL(
            INSERT INTO coach_covers (fh_event_id, coach_id, note, created_by_user_id)
            VALUES ($1::bigint, $2::int, NULLIF($3, ''), $4::int)
            ON CONFLICT (fh_event_id, coach_id) WHERE status <> 'withdrawn'
            DO UPDATE SET note = COALESCE(EXCLUDED.note, coach_covers.note)
            RETURNING id, status)SQL", {str(eventId), str(coachId), note, str(me.userId)});
        const long long coverId = cover[0]["id"].as<long long>();
        db->query(R"SQL(
            INSERT INTO coach_cover_asks (cover_id, coach_id)
            SELECT $1::bigint, c.id FROM coaches c
             WHERE c.id = ANY ($2::int[]) AND c.id <> $3::int
            ON CONFLICT DO NOTHING)SQL", {str(coverId), asks, str(coachId)});
        return jsonOut(HttpStatus::OK, {{"id", coverId}, {"status", cover[0]["status"].c_str()}});
    } catch (const std::exception& e) {
        std::cerr << "CoachScheduleController::handleCoverCreate: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not ask for cover");
    }
}

Response CoachScheduleController::handleCoverAction(const Request& request) {
    Caller me;
    Response denied(HttpStatus::FORBIDDEN, "");
    if (!gate(request, &me, &denied)) return denied;
    long long coverId = 0; std::string action;
    if (!coverPath(request.getPath(), &coverId, &action)) return jsonError(HttpStatus::BAD_REQUEST, "Which cover?");
    long long bodyCoach = 0;
    try { bodyCoach = parseBody(request).value("coach_id", 0LL); } catch (...) {}
    try {
        auto* db = Database::getInstance();
        auto row = db->query("SELECT fh_event_id, coach_id, status FROM coach_covers WHERE id = $1::bigint", {str(coverId)});
        if (row.empty()) return jsonError(HttpStatus::NOT_FOUND, "That cover ask is gone.");
        const long long eventId = row[0]["fh_event_id"].as<long long>(), askerId = row[0]["coach_id"].as<long long>();
        const std::string status = row[0]["status"].c_str();

        // The ask's text for one asked coach: their own sign-in link (minted
        // like every player / parent reminder), landing on the event; the
        // words are message_templates coach_schedule/cover_sms (mig 1640).
        if (action == "text") {
            if (!me.admin && me.coachId != askerId) return jsonError(HttpStatus::FORBIDDEN, "Not your ask.");
            if (status != "open") return jsonError(HttpStatus::CONFLICT, "That ask is no longer open.");
            auto who = db->query(R"SQL(
                SELECT c.person_id, COALESCE(p.first_name, '') AS first,
                       fh_recipient_phone(c.person_id, c.person_id) AS phone,
                       (SELECT COALESCE(ap.first_name, '') FROM coaches ac JOIN persons ap ON ap.id = ac.person_id WHERE ac.id = $3::int) AS asker,
                       regexp_replace(COALESCE(ge.summary, ''), '^\s*Soccer\s+', '', 'i') AS event,
                       to_char(ge.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD FMHH12:MI AM') AS at
                  FROM coach_cover_asks a
                  JOIN coaches c ON c.id = a.coach_id
                  JOIN persons p ON p.id = c.person_id
                  JOIN fh_events fe ON fe.id = $4::bigint
                  JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                 WHERE a.cover_id = $1::bigint AND a.coach_id = $2::int)SQL",
                {str(coverId), str(bodyCoach), str(askerId), str(eventId)});
            if (who.empty()) return jsonError(HttpStatus::NOT_FOUND, "That coach was not asked.");
            if (who[0]["phone"].is_null()) return jsonError(HttpStatus::BAD_REQUEST, "No phone on file for that coach.");
            const std::string phone = who[0]["phone"].c_str();
            const auto minted = MagicLinkService::mint(who[0]["person_id"].as<long long>(), "sms", phone, me.userId,
                                                       0, 0, "event/" + str(eventId));
            MessageCopy copy;
            const auto sms = copy.render("coach_schedule", "cover_sms", {
                {"first", who[0]["first"].c_str()}, {"event", who[0]["event"].c_str()},
                {"when", who[0]["at"].c_str()}, {"coach", who[0]["asker"].c_str()}, {"link", minted.url}});
            if (!sms.ok()) return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "cover_sms words missing (mig 1634)");
            db->query("UPDATE coach_cover_asks SET texted_at = now() WHERE cover_id = $1::bigint AND coach_id = $2::int",
                      {str(coverId), str(bodyCoach)});
            json out = {{"ok", true}};
            copy.addComposeHrefs(out, "sms", phone, "", "", sms.body);
            return jsonOut(HttpStatus::OK, out);
        }
        if (action == "take") {
            const long long taker = (me.admin && bodyCoach > 0) ? bodyCoach : me.coachId;
            if (taker <= 0) return jsonError(HttpStatus::FORBIDDEN, "Only a coach can take a cover.");
            if (taker == askerId) return jsonError(HttpStatus::BAD_REQUEST, "That is your own ask.");
            if (status != "open") return jsonError(HttpStatus::CONFLICT, status == "covered" ? "Someone already took it." : "That ask was cancelled.");
            auto up = db->query(R"SQL(
                UPDATE coach_covers SET status = 'covered', cover_coach_id = $2::int, covered_at = now(), covered_by_user_id = $3::int
                 WHERE id = $1::bigint AND status = 'open' RETURNING id)SQL", {str(coverId), str(taker), str(me.userId)});
            if (up.empty()) return jsonError(HttpStatus::CONFLICT, "Someone already took it.");
            // A coach on that event now (fh_event_covering, mig 1640) — no invite row.
            return jsonOut(HttpStatus::OK, {{"ok", true}});
        }
        if (action == "withdraw") {
            if (!me.admin && me.coachId != askerId) return jsonError(HttpStatus::FORBIDDEN, "Only the coach who asked, or an admin, can cancel it.");
            db->query("DELETE FROM event_person_sees WHERE fh_event_id = $1::bigint AND note = 'coach cover #' || $2",
                      {str(eventId), str(coverId)});
            db->query(R"SQL(
                UPDATE coach_covers SET status = 'withdrawn', cover_coach_id = NULL, withdrawn_at = now()
                 WHERE id = $1::bigint AND status <> 'withdrawn')SQL", {str(coverId)});
            return jsonOut(HttpStatus::OK, {{"ok", true}});
        }
        return jsonError(HttpStatus::NOT_FOUND, "Unknown action");
    } catch (const std::exception& e) {
        std::cerr << "CoachScheduleController::handleCoverAction: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not update the cover");
    }
}
