#include "AttendanceCallController.h"

#include <iostream>

#include "../database/Database.h"
#include "../third_party/json.hpp"

namespace {
Response jsonOut(HttpStatus s, const std::string& body) {
    Response r(s, body);
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}
Response jsonError(HttpStatus s, const std::string& message) {
    return jsonOut(s, nlohmann::json{{"error", message}}.dump());
}
}  // namespace

void AttendanceCallController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix + "/event", [this](const Request& r) { return handleEvent(r); });
    router.get(prefix + "/log",   [this](const Request& r) { return handleLog(r); });
}

bool AttendanceCallController::isStaff(const Request& request) {
    auto* db = Database::getInstance();
    const std::string uid = std::to_string(bearerUserId(request));
    return !db->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1", {uid}).empty() ||
           !db->query("SELECT 1 FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id "
                      "  JOIN users u ON u.person_id = c.person_id "
                      " WHERE u.id = $1::int AND tc.ended_at IS NULL LIMIT 1", {uid}).empty();
}

Response AttendanceCallController::handleEvent(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    // 403, not 401 — a signed-in non-staff is not a dead session.
    if (!isStaff(request)) return jsonError(HttpStatus::FORBIDDEN, "Attendance calls are for coaches and club admins.");
    auto* db = Database::getInstance();

    std::string id = request.hasQueryParam("id") ? request.getQueryParam("id") : "";
    if (id.empty() || id.find_first_not_of("0123456789") != std::string::npos)
        return jsonError(HttpStatus::BAD_REQUEST, "id is required");
    try {
        auto rows = db->query(R"SQL(
          WITH ev AS (
            SELECT e.id, e.kind, e.category, g.starts_at, g.ends_at, p.is_on, p.live, p.repeat_minutes,
                   g.starts_at + (g.ends_at - g.starts_at) * p.start_fraction AS calls_from,
                   g.ends_at + make_interval(mins => p.stop_after_end_minutes) AS calls_until,
                   (SELECT BTRIM(COALESCE(tp.first_name, '') || ' ' || COALESCE(tp.last_name, ''))
                      FROM persons tp WHERE tp.id = p.test_person_id) AS test_name
              FROM fh_events e
              JOIN gcal_events g ON g.id = e.gcal_event_id
              LEFT JOIN attendance_call_policies p ON p.category = e.category
             WHERE e.id = $1::bigint
          ), going AS (
            SELECT x.*, BTRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')) AS name,
                   EXISTS (SELECT 1 FROM person_phones ph WHERE ph.person_id = x.person_id) AS has_phone
              FROM fh_attendance_call_going($1::bigint) x JOIN persons p ON p.id = x.person_id
          )
          SELECT json_build_object(
            'kind', ev.kind, 'on', COALESCE(ev.is_on, false), 'live', COALESCE(ev.live, false),
            'test_name', ev.test_name, 'repeat_minutes', ev.repeat_minutes,
            'calls_from',  to_char(ev.calls_from  AT TIME ZONE 'America/New_York', 'FMHH12:MI AM'),
            'calls_until', to_char(ev.calls_until AT TIME ZONE 'America/New_York', 'FMHH12:MI AM'),
            'started', now() >= ev.calls_from, 'over', now() >= ev.calls_until,
            'coaches', COALESCE((SELECT json_agg(json_build_object('name', name, 'phone', has_phone) ORDER BY name)
                                   FROM going WHERE is_coach), '[]'),
            'unmarked', COALESCE((SELECT json_agg(name ORDER BY name) FROM going WHERE is_player AND NOT marked), '[]'),
            'going_players', (SELECT count(*) FROM going WHERE is_player),
            'rounds', COALESCE((SELECT json_agg(json_build_object(
                         'round', r.round, 'unmarked', r.unmarked, 'live', r.live,
                         'at', to_char(r.called_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM'),
                         'tried', (SELECT count(*) FROM attendance_call_log l WHERE l.fh_event_id = r.fh_event_id AND l.round = r.round AND l.channel = 'call'),
                         'ok',    (SELECT count(*) FROM attendance_call_log l WHERE l.fh_event_id = r.fh_event_id AND l.round = r.round AND l.channel = 'call' AND l.ok))
                         ORDER BY r.round DESC)
                       FROM attendance_call_rounds r WHERE r.fh_event_id = ev.id), '[]')
          )::text AS body
          FROM ev)SQL", {id});
        if (rows.empty()) return jsonError(HttpStatus::NOT_FOUND, "No such event");
        return jsonOut(HttpStatus::OK, rows[0]["body"].c_str());
    } catch (const std::exception& e) {
        std::cerr << "AttendanceCallController::handleEvent: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load attendance calls");
    }
}

// #attendance-calls (owner 2026-11-11: "build a page to see all attendance
// calls"): every practice that had a round in the window, newest first,
// each round with who was rung / texted and whether Twilio took it.
Response AttendanceCallController::handleLog(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    if (!isStaff(request)) return jsonError(HttpStatus::FORBIDDEN, "Attendance calls are for coaches and club admins.");
    int days = 14;
    if (request.hasQueryParam("days")) {
        const std::string d = request.getQueryParam("days");
        if (!d.empty() && d.size() < 4 && d.find_first_not_of("0123456789") == std::string::npos) days = std::stoi(d);
    }
    if (days < 1) days = 1;
    if (days > 120) days = 120;
    try {
        auto rows = Database::getInstance()->query(R"SQL(
          WITH ev AS MATERIALIZED (
            SELECT DISTINCT r.fh_event_id AS id
              FROM attendance_call_rounds r
             WHERE r.called_at > now() - make_interval(days => $1::int)
          ), e AS (
            SELECT e.id, e.category, g.summary, g.starts_at, g.ends_at,
                   to_char(g.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD') AS day,
                   to_char(g.starts_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') || ' – ' ||
                   to_char(g.ends_at   AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS time
              FROM ev JOIN fh_events e ON e.id = ev.id JOIN gcal_events g ON g.id = e.gcal_event_id
          )
          SELECT json_build_object(
            'days', $1::int,
            'policies', COALESCE((SELECT json_agg(json_build_object('category', p.category, 'is_on', p.is_on, 'live', p.live,
                                      'test_name', BTRIM(COALESCE(tp.first_name, '') || ' ' || COALESCE(tp.last_name, ''))) ORDER BY p.category)
                                    FROM attendance_call_policies p LEFT JOIN persons tp ON tp.id = p.test_person_id), '[]'),
            'events', COALESCE((SELECT json_agg(json_build_object(
                'id', e.id, 'category', e.category, 'title', e.summary, 'day', e.day, 'time', e.time,
                'rounds_n', (SELECT count(*) FROM attendance_call_rounds r WHERE r.fh_event_id = e.id),
                'last_unmarked', (SELECT r.unmarked FROM attendance_call_rounds r WHERE r.fh_event_id = e.id ORDER BY r.round DESC LIMIT 1),
                'unmarked_now', (SELECT count(*) FROM fh_attendance_call_going(e.id) x WHERE x.is_player AND NOT x.marked),
                'live', EXISTS (SELECT 1 FROM attendance_call_rounds r WHERE r.fh_event_id = e.id AND r.live),
                'calls_tried', (SELECT count(*) FROM attendance_call_log l WHERE l.fh_event_id = e.id AND l.channel = 'call'),
                'calls_ok',    (SELECT count(*) FROM attendance_call_log l WHERE l.fh_event_id = e.id AND l.channel = 'call' AND l.ok),
                'texts',       (SELECT count(*) FROM attendance_call_log l WHERE l.fh_event_id = e.id AND l.channel = 'sms'),
                'rounds', COALESCE((SELECT json_agg(json_build_object(
                    'round', r.round, 'unmarked', r.unmarked, 'live', r.live,
                    'at', to_char(r.called_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM'),
                    'people', COALESCE((SELECT json_agg(json_build_object(
                        'name', BTRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')),
                        'channel', l.channel, 'ok', l.ok, 'error', l.error) ORDER BY p.first_name, p.last_name, l.channel)
                      FROM attendance_call_log l JOIN persons p ON p.id = l.person_id
                     WHERE l.fh_event_id = r.fh_event_id AND l.round = r.round), '[]'))
                    ORDER BY r.round DESC)
                  FROM attendance_call_rounds r WHERE r.fh_event_id = e.id), '[]'))
              ORDER BY e.starts_at DESC) FROM e), '[]')
          )::text AS body)SQL", {std::to_string(days)});
        return jsonOut(HttpStatus::OK, rows[0]["body"].c_str());
    } catch (const std::exception& ex) {
        std::cerr << "AttendanceCallController::handleLog: " << ex.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load attendance calls");
    }
}
