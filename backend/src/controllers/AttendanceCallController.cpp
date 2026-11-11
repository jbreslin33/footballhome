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
}

Response AttendanceCallController::handleEvent(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    auto* db = Database::getInstance();
    const std::string uid = std::to_string(bearerUserId(request));
    const bool staff =
        !db->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1", {uid}).empty() ||
        !db->query("SELECT 1 FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id "
                   "  JOIN users u ON u.person_id = c.person_id "
                   " WHERE u.id = $1::int AND tc.ended_at IS NULL LIMIT 1", {uid}).empty();
    // 403, not 401 — a signed-in non-staff is not a dead session.
    if (!staff) return jsonError(HttpStatus::FORBIDDEN, "Attendance calls are for coaches and club admins.");

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
