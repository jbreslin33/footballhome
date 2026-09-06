#include "ReportsController.h"

#include "../core/Crypto.h"
#include "../services/SessionService.h"

#include <iostream>
#include <map>
#include <regex>
#include <sstream>
#include <utility>

using nlohmann::json;

namespace {

Response jsonError(HttpStatus s, const std::string& msg) {
    json body = {{"error", msg}};
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}

Response jsonOk(const json& body) {
    Response r(HttpStatus::OK, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}

json textOrNull(const pqxx::row& row, const char* col) {
    const auto& f = row[col];
    if (f.is_null()) return nullptr;
    return f.c_str();
}

long long llOrZero(const pqxx::row& row, const char* col) {
    const auto& f = row[col];
    if (f.is_null()) return 0;
    return f.as<long long>();
}

// Session resolution — same dual path as CalendarController (Bearer JWT
// first, then the fh_sess cookie), returning 0 when neither resolves.
long long personIdFromJwtPayload(const std::string& payloadJson) {
    const std::string needle = "\"userId\":\"";
    auto pos = payloadJson.find(needle);
    if (pos == std::string::npos) return 0;
    pos += needle.size();
    auto end = payloadJson.find('"', pos);
    if (end == std::string::npos) return 0;
    const std::string userIdStr = payloadJson.substr(pos, end - pos);
    if (userIdStr.empty()) return 0;
    try {
        auto r = Database::getInstance()->query(
            "SELECT person_id FROM users WHERE id = $1::int LIMIT 1", {userIdStr});
        if (r.empty() || r[0]["person_id"].is_null()) return 0;
        return r[0]["person_id"].as<long long>();
    } catch (...) {
        return 0;
    }
}

long long resolvePersonId(const Request& request) {
    const std::string authHeader = request.getHeader("Authorization");
    if (authHeader.size() > 7 && authHeader.substr(0, 7) == "Bearer ") {
        std::string payloadJson;
        if (fh::crypto::verifyJwtHS256(authHeader.substr(7), &payloadJson)) {
            const long long personId = personIdFromJwtPayload(payloadJson);
            if (personId > 0) return personId;
        }
    }
    const std::string sessVal = SessionService::parseCookieValue(
        request.getHeader("Cookie"), SessionService::kCookieName);
    if (sessVal.empty()) return 0;
    auto resolved = SessionService::getInstance().requireSession(sessVal);
    return resolved ? resolved->personId : 0;
}

// Live, team-tagged, past events of the reportable kinds inside the
// window.  Shared by both handlers; $1 = from, $2 = to, $3 = int[] teams.
// `bucket` folds the eight fh_events.kind values into the three the
// report shows — meeting / camp / barn night / other are excluded up
// front by the kind list.
const char* kEventsCte =
    "ev AS ( "
    "  SELECT fe.id AS fh_event_id, fe.kind, fe.opponent, "
    "         CASE WHEN fe.kind IN ('match','intrasquad') THEN 'game' "
    "              WHEN fe.kind = 'practice' THEN 'practice' "
    "              ELSE 'pickup' END AS bucket, "
    "         COALESCE(fe.start_at, ge.starts_at) AS start_at, "
    "         fet.team_id, "
    "         EXISTS (SELECT 1 FROM fh_event_attendance a "
    "                  WHERE a.fh_event_id = fe.id) AS checked "
    "    FROM fh_events fe "
    "    JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
    "    JOIN fh_event_teams fet ON fet.fh_event_id = fe.id "
    "   WHERE ge.deleted_at IS NULL "
    "     AND ge.status IS DISTINCT FROM 'cancelled' "
    "     AND fe.kind IN ('match','intrasquad','practice','pickup') "
    "     AND COALESCE(fe.start_at, ge.starts_at) < "
    "         LEAST(now(), $2::date::timestamptz + interval '1 day') "
    "     AND COALESCE(fe.start_at, ge.starts_at) >= $1::date::timestamptz "
    "     AND fet.team_id = ANY($3::int[]) "
    ")";

// Expected (player, event) pairs — see the header for the rule.
const char* kExpectedCte =
    "expected AS ( "
    "  SELECT ev.*, tp.person_id, r.response, r.responded_at, a.status AS att "
    "    FROM ev "
    "    JOIN team_persons tp ON tp.team_id = ev.team_id AND tp.removed_at IS NULL "
    "    LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id "
    "    LEFT JOIN fh_event_rsvps r "
    "           ON r.fh_event_id = ev.fh_event_id AND r.person_id = tp.person_id "
    "    LEFT JOIN fh_event_attendance a "
    "           ON a.fh_event_id = ev.fh_event_id AND a.person_id = tp.person_id "
    "   WHERE COALESCE(rs.show_in_rsvp, true) "
    "     AND NOT EXISTS (SELECT 1 FROM rsvp_suspensions s "
    "                      WHERE s.person_id = tp.person_id "
    "                        AND (s.team_id IS NULL OR s.team_id = tp.team_id) "
    "                        AND s.starts_at <= ev.start_at "
    "                        AND (s.ends_at IS NULL OR s.ends_at > ev.start_at)) "
    ")";

// One bucket's counters.  `all` is the sum of the three real buckets.
struct BucketStats {
    long long expected = 0, responded = 0, yes = 0, no = 0, maybe = 0;
    long long checked = 0, present = 0, late = 0, absent = 0, excused = 0, unmarked = 0;
    long long yesChecked = 0, yesShowed = 0, walkOns = 0;

    void add(const BucketStats& o) {
        expected += o.expected; responded += o.responded; yes += o.yes; no += o.no; maybe += o.maybe;
        checked += o.checked; present += o.present; late += o.late; absent += o.absent;
        excused += o.excused; unmarked += o.unmarked;
        yesChecked += o.yesChecked; yesShowed += o.yesShowed; walkOns += o.walkOns;
    }

    static json pct(long long num, long long den) {
        if (den <= 0) return nullptr;
        return static_cast<int>((num * 1000 + den / 2) / den) / 10.0;
    }

    json toJson() const {
        const long long attended = present + late;
        return {
            {"expected",        expected},
            {"responded",       responded},
            {"no_response",     expected - responded},
            {"yes",             yes},
            {"no",              no},
            {"maybe",           maybe},
            {"rsvp_pct",        pct(responded, expected)},
            {"yes_pct",         pct(yes, expected)},
            {"checked",         checked},
            {"present",         present},
            {"late",            late},
            {"absent",          absent},
            {"excused",         excused},
            {"unmarked",        unmarked},
            {"attended",        attended},
            {"attend_pct",      pct(attended, checked)},
            {"yes_checked",     yesChecked},
            {"yes_showed",      yesShowed},
            {"no_shows",        yesChecked - yesShowed},
            {"reliability_pct", pct(yesShowed, yesChecked)},
            {"walk_ons",        walkOns},
        };
    }
};

}  // namespace

ReportsController::ReportsController() : db_(Database::getInstance()) {}

void ReportsController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix + "/attendance", [this](const Request& request) {
        return this->handleGetAttendance(request);
    });
    router.get(prefix + "/attendance/events", [this](const Request& request) {
        return this->handleGetAttendanceEvents(request);
    });
}

std::string ReportsController::pgIntArray(const std::vector<long long>& ids) {
    std::ostringstream out;
    out << '{';
    for (size_t i = 0; i < ids.size(); ++i) {
        if (i) out << ',';
        out << ids[i];
    }
    out << '}';
    return out.str();
}

bool ReportsController::resolveScope(const Request& request, Scope* scope, Response* error) {
    const long long personId = resolvePersonId(request);
    if (personId <= 0) {
        const bool present = request.getHeader("Authorization").size() > 7 ||
            !SessionService::parseCookieValue(request.getHeader("Cookie"),
                                              SessionService::kCookieName).empty();
        *error = jsonError(HttpStatus::UNAUTHORIZED, present ? "Session expired" : "Not signed in");
        return false;
    }
    scope->personId = personId;

    auto adminRows = db_->query(
        "SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id "
        " WHERE u.person_id = $1::int LIMIT 1",
        {std::to_string(personId)});
    scope->isAdmin = !adminRows.empty();

    pqxx::result teamRows;
    if (scope->isAdmin) {
        // Every team with somebody on it — covers the real squads and
        // the Pickup pool (909), skips the scraped opponent teams.
        teamRows = db_->query(
            "SELECT t.id FROM teams t "
            " WHERE EXISTS (SELECT 1 FROM team_persons tp "
            "                WHERE tp.team_id = t.id AND tp.removed_at IS NULL) "
            " ORDER BY t.id");
    } else {
        teamRows = db_->query(
            "SELECT DISTINCT tc.team_id AS id FROM team_coaches tc "
            "  JOIN coaches c ON c.id = tc.coach_id "
            " WHERE c.person_id = $1::int AND tc.ended_at IS NULL "
            " ORDER BY tc.team_id",
            {std::to_string(personId)});
    }
    for (const auto& row : teamRows) scope->teamIds.push_back(row["id"].as<long long>());

    if (!scope->isAdmin && scope->teamIds.empty()) {
        *error = jsonError(HttpStatus::FORBIDDEN,
                           "Reports are for club admins and coaches of a team.");
        return false;
    }

    // Optional ?teamId narrows to one team, which must be in scope.
    const std::string teamParam = request.getQueryParam("teamId");
    if (!teamParam.empty()) {
        long long teamId = 0;
        try { teamId = std::stoll(teamParam); } catch (...) { teamId = 0; }
        bool inScope = false;
        for (long long id : scope->teamIds) inScope = inScope || id == teamId;
        if (!inScope) {
            *error = jsonError(HttpStatus::FORBIDDEN, "That team is not in your scope.");
            return false;
        }
        scope->teamIds.assign(1, teamId);
    }
    return true;
}

bool ReportsController::parseWindow(const Request& request, Window* window, Response* error) {
    static const std::regex ymd(R"(^\d{4}-\d{2}-\d{2}$)");
    window->from = request.getQueryParam("from");
    window->to   = request.getQueryParam("to");
    if (!window->from.empty() && !std::regex_match(window->from, ymd)) {
        *error = jsonError(HttpStatus::BAD_REQUEST, "from must be YYYY-MM-DD");
        return false;
    }
    if (!window->to.empty() && !std::regex_match(window->to, ymd)) {
        *error = jsonError(HttpStatus::BAD_REQUEST, "to must be YYYY-MM-DD");
        return false;
    }
    // Defaults resolved in SQL so the club's timezone rule stays in one
    // place: from = 90 days ago, to = today (America/New_York).
    auto row = db_->query(
        "SELECT to_char(COALESCE(NULLIF($1,'')::date, "
        "                        (now() AT TIME ZONE 'America/New_York')::date - 90), 'YYYY-MM-DD') AS f, "
        "       to_char(COALESCE(NULLIF($2,'')::date, "
        "                        (now() AT TIME ZONE 'America/New_York')::date), 'YYYY-MM-DD') AS t",
        {window->from, window->to});
    window->from = row[0]["f"].c_str();
    window->to   = row[0]["t"].c_str();
    if (window->to < window->from) {
        *error = jsonError(HttpStatus::BAD_REQUEST, "to must not be before from");
        return false;
    }
    return true;
}

// GET /api/reports/attendance
Response ReportsController::handleGetAttendance(const Request& request) {
    try {
        Scope scope;
        Window window;
        Response err(HttpStatus::OK, "");
        if (!resolveScope(request, &scope, &err)) return err;
        if (!parseWindow(request, &window, &err)) return err;

        const std::string teams = pgIntArray(scope.teamIds);
        const std::vector<std::string> params = {window.from, window.to, teams};

        // 1. Teams in scope (for the filter chips) with their event
        //    counts in the window per bucket, so a chip can say how
        //    many games/practices the team actually had.
        auto teamRows = db_->query(
            std::string("WITH ") + kEventsCte +
            " SELECT t.id, t.name, t.gender_category, t.is_pool, t.is_active, "
            "        cs.name AS section, "
            "        (SELECT count(*) FROM ev WHERE ev.team_id = t.id AND ev.bucket = 'game')     AS games, "
            "        (SELECT count(*) FROM ev WHERE ev.team_id = t.id AND ev.bucket = 'practice') AS practices, "
            "        (SELECT count(*) FROM ev WHERE ev.team_id = t.id AND ev.bucket = 'pickup')   AS pickups, "
            "        (SELECT count(*) FROM ev WHERE ev.team_id = t.id AND ev.checked)             AS checked_events, "
            "        (SELECT count(*) FROM team_persons tp "
            "          WHERE tp.team_id = t.id AND tp.removed_at IS NULL)                         AS roster_size "
            "   FROM teams t LEFT JOIN club_sections cs ON cs.id = t.club_section_id "
            "  WHERE t.id = ANY($3::int[]) "
            "  ORDER BY cs.sort_order NULLS LAST, t.board_sort_order NULLS LAST, t.name",
            params);

        // 2. Per (player, team, bucket) counters.
        auto statRows = db_->query(
            std::string("WITH ") + kEventsCte + ", " + kExpectedCte +
            " SELECT person_id, team_id, bucket, "
            "        count(*)                                             AS expected, "
            "        count(response)                                      AS responded, "
            "        count(*) FILTER (WHERE response = 'yes')             AS yes, "
            "        count(*) FILTER (WHERE response = 'no')              AS no, "
            "        count(*) FILTER (WHERE response = 'maybe')           AS maybe, "
            "        count(*) FILTER (WHERE checked)                      AS checked, "
            "        count(*) FILTER (WHERE att = 'present')              AS present, "
            "        count(*) FILTER (WHERE att = 'late')                 AS late, "
            "        count(*) FILTER (WHERE att = 'absent')               AS absent, "
            "        count(*) FILTER (WHERE att = 'excused')              AS excused, "
            "        count(*) FILTER (WHERE checked AND att IS NULL)      AS unmarked, "
            "        count(*) FILTER (WHERE checked AND response = 'yes') AS yes_checked, "
            "        count(*) FILTER (WHERE checked AND response = 'yes' "
            "                           AND att IN ('present','late'))    AS yes_showed, "
            "        count(*) FILTER (WHERE att IN ('present','late') "
            "                           AND response IS DISTINCT FROM 'yes') AS walk_ons "
            "   FROM expected "
            "  GROUP BY person_id, team_id, bucket",
            params);

        // 3. Silent streak per (player, team): how many of the most
        //    recent expected events in a row went unanswered.
        auto streakRows = db_->query(
            std::string("WITH ") + kEventsCte + ", " + kExpectedCte +
            ", ranked AS ( "
            "  SELECT person_id, team_id, (response IS NOT NULL) AS responded, "
            "         row_number() OVER (PARTITION BY person_id, team_id ORDER BY start_at DESC) AS rn "
            "    FROM expected) "
            " SELECT person_id, team_id, "
            "        COALESCE(MIN(rn) FILTER (WHERE responded), count(*) + 1) - 1 AS silent_streak "
            "   FROM ranked GROUP BY person_id, team_id",
            params);

        // 4. The row set: everyone currently on a roster in scope, with
        //    activity timestamps (not window-limited — "last seen" is
        //    about now, not about the report window).
        auto rosterRows = db_->query(
            "SELECT tp.person_id, tp.team_id, p.first_name, p.last_name, "
            "       t.name AS team_name, t.gender_category, cs.name AS section, "
            "       rs.code AS roster_status, rs.display_name AS roster_status_label, "
            "       COALESCE(rs.show_in_rsvp, true) AS rsvp_eligible, "
            "       (p.parent_person_id IS NOT NULL) AS is_youth, "
            "       p.la_user_id, "
            "       EXISTS (SELECT 1 FROM rsvp_suspensions s "
            "                WHERE s.person_id = tp.person_id "
            "                  AND (s.team_id IS NULL OR s.team_id = tp.team_id) "
            "                  AND s.starts_at <= now() "
            "                  AND (s.ends_at IS NULL OR s.ends_at > now())) AS suspended_now, "
            "       to_char((SELECT max(r.responded_at) FROM fh_event_rsvps r "
            "                 WHERE r.person_id = tp.person_id) AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS last_rsvp_at, "
            "       to_char((SELECT max(COALESCE(fe.start_at, ge.starts_at)) "
            "                  FROM fh_event_attendance a "
            "                  JOIN fh_events fe ON fe.id = a.fh_event_id "
            "                  JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
            "                 WHERE a.person_id = tp.person_id "
            "                   AND a.status IN ('present','late')) AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS last_attended_at, "
            // users.last_login_at / last_seen_at are timestamp WITHOUT
            // time zone, stored as UTC; sessions.last_used_at is
            // timestamptz.  Normalise both to UTC before GREATEST.
            "       to_char(GREATEST( "
            "                 (SELECT max(GREATEST(u.last_login_at, u.last_seen_at)) "
            "                    FROM users u WHERE u.person_id = tp.person_id), "
            "                 (SELECT max(s.last_used_at) AT TIME ZONE 'UTC' "
            "                    FROM sessions s WHERE s.person_id = tp.person_id)), "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS last_login_at "
            "  FROM team_persons tp "
            "  JOIN persons p ON p.id = tp.person_id "
            "  JOIN teams t ON t.id = tp.team_id "
            "  LEFT JOIN club_sections cs ON cs.id = t.club_section_id "
            "  LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id "
            " WHERE tp.removed_at IS NULL AND tp.team_id = ANY($1::int[]) "
            " ORDER BY cs.sort_order NULLS LAST, t.board_sort_order NULLS LAST, t.name, "
            "          p.last_name, p.first_name, p.id",
            {teams});

        using Key = std::pair<long long, long long>;   // person_id, team_id
        std::map<Key, std::map<std::string, BucketStats>> stats;
        for (const auto& row : statRows) {
            BucketStats b;
            b.expected   = llOrZero(row, "expected");
            b.responded  = llOrZero(row, "responded");
            b.yes        = llOrZero(row, "yes");
            b.no         = llOrZero(row, "no");
            b.maybe      = llOrZero(row, "maybe");
            b.checked    = llOrZero(row, "checked");
            b.present    = llOrZero(row, "present");
            b.late       = llOrZero(row, "late");
            b.absent     = llOrZero(row, "absent");
            b.excused    = llOrZero(row, "excused");
            b.unmarked   = llOrZero(row, "unmarked");
            b.yesChecked = llOrZero(row, "yes_checked");
            b.yesShowed  = llOrZero(row, "yes_showed");
            b.walkOns    = llOrZero(row, "walk_ons");
            stats[{row["person_id"].as<long long>(), row["team_id"].as<long long>()}]
                 [row["bucket"].c_str()] = b;
        }
        std::map<Key, long long> streaks;
        for (const auto& row : streakRows) {
            streaks[{row["person_id"].as<long long>(), row["team_id"].as<long long>()}] =
                llOrZero(row, "silent_streak");
        }

        json rows = json::array();
        for (const auto& row : rosterRows) {
            const Key key{row["person_id"].as<long long>(), row["team_id"].as<long long>()};
            const auto& perBucket = stats[key];
            BucketStats all;
            json buckets = json::object();
            for (const char* name : {"game", "practice", "pickup"}) {
                auto it = perBucket.find(name);
                const BucketStats b = it == perBucket.end() ? BucketStats{} : it->second;
                all.add(b);
                buckets[name] = b.toJson();
            }
            buckets["all"] = all.toJson();

            rows.push_back({
                {"person_id",           key.first},
                {"team_id",             key.second},
                {"first_name",          textOrNull(row, "first_name")},
                {"last_name",           textOrNull(row, "last_name")},
                {"team_name",           textOrNull(row, "team_name")},
                {"category",            textOrNull(row, "gender_category")},
                {"section",             textOrNull(row, "section")},
                {"roster_status",       textOrNull(row, "roster_status")},
                {"roster_status_label", textOrNull(row, "roster_status_label")},
                {"rsvp_eligible",       row["rsvp_eligible"].as<bool>()},
                {"suspended_now",       row["suspended_now"].as<bool>()},
                {"is_youth",            row["is_youth"].as<bool>()},
                {"la_user_id",          row["la_user_id"].is_null()
                                            ? json(nullptr)
                                            : json(row["la_user_id"].as<long long>())},
                {"buckets",             std::move(buckets)},
                {"activity", {
                    {"last_rsvp_at",     textOrNull(row, "last_rsvp_at")},
                    {"last_attended_at", textOrNull(row, "last_attended_at")},
                    {"last_login_at",    textOrNull(row, "last_login_at")},
                    {"silent_streak",    streaks.count(key) ? streaks[key] : 0},
                }},
            });
        }

        json teamsJson = json::array();
        for (const auto& row : teamRows) {
            teamsJson.push_back({
                {"id",             row["id"].as<long long>()},
                {"name",           textOrNull(row, "name")},
                {"category",       textOrNull(row, "gender_category")},
                {"section",        textOrNull(row, "section")},
                {"is_pool",        row["is_pool"].is_null() ? false : row["is_pool"].as<bool>()},
                {"is_active",      row["is_active"].is_null() ? true : row["is_active"].as<bool>()},
                {"games",          llOrZero(row, "games")},
                {"practices",      llOrZero(row, "practices")},
                {"pickups",        llOrZero(row, "pickups")},
                {"checked_events", llOrZero(row, "checked_events")},
                {"roster_size",    llOrZero(row, "roster_size")},
            });
        }

        return jsonOk({
            {"from",     window.from},
            {"to",       window.to},
            {"scope",    scope.isAdmin ? "club" : "coach"},
            {"teams",    std::move(teamsJson)},
            {"rows",     std::move(rows)},
        });
    } catch (const std::exception& e) {
        std::cerr << "ReportsController::handleGetAttendance: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// GET /api/reports/attendance/events?personId=&teamId=
Response ReportsController::handleGetAttendanceEvents(const Request& request) {
    try {
        Scope scope;
        Window window;
        Response err(HttpStatus::OK, "");
        if (!resolveScope(request, &scope, &err)) return err;
        if (!parseWindow(request, &window, &err)) return err;

        long long personId = 0;
        try { personId = std::stoll(request.getQueryParam("personId")); } catch (...) { personId = 0; }
        if (personId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "personId required");
        if (request.getQueryParam("teamId").empty()) {
            return jsonError(HttpStatus::BAD_REQUEST, "teamId required");
        }
        // resolveScope already narrowed teamIds to the one requested team.
        const std::vector<std::string> params = {
            window.from, window.to, pgIntArray(scope.teamIds), std::to_string(personId)};

        auto rows = db_->query(
            std::string("WITH ") + kEventsCte + ", " + kExpectedCte +
            " SELECT e.fh_event_id, e.kind, e.bucket, e.opponent, e.checked, "
            "        to_char(e.start_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS start_at, "
            "        e.response, "
            "        to_char(e.responded_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS responded_at, "
            "        e.att "
            "   FROM expected e "
            "  WHERE e.person_id = $4::int "
            "  ORDER BY e.start_at DESC",
            params);

        json events = json::array();
        for (const auto& row : rows) {
            events.push_back({
                {"fh_event_id",  row["fh_event_id"].as<long long>()},
                {"kind",         textOrNull(row, "kind")},
                {"bucket",       textOrNull(row, "bucket")},
                {"opponent",     textOrNull(row, "opponent")},
                {"start_at",     textOrNull(row, "start_at")},
                {"checked",      row["checked"].as<bool>()},
                {"response",     textOrNull(row, "response")},
                {"responded_at", textOrNull(row, "responded_at")},
                {"attendance",   textOrNull(row, "att")},
            });
        }
        return jsonOk({
            {"person_id", personId},
            {"team_id",   scope.teamIds.front()},
            {"from",      window.from},
            {"to",        window.to},
            {"events",    std::move(events)},
        });
    } catch (const std::exception& e) {
        std::cerr << "ReportsController::handleGetAttendanceEvents: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
