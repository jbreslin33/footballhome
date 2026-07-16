#include "CalendarController.h"

#include "../database/Database.h"
#include "../third_party/json.hpp"

#include <algorithm>
#include <exception>
#include <iostream>
#include <string>

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

// Small helper for pqxx::field → json.  pqxx exposes is_null() +
// c_str() for text; we let nlohmann::json infer types from the
// SELECT projection.
json textOrNull(const pqxx::row& row, const char* col) {
    const auto& f = row[col];
    if (f.is_null()) return nullptr;
    return f.c_str();
}

json boolOrNull(const pqxx::row& row, const char* col) {
    const auto& f = row[col];
    if (f.is_null()) return nullptr;
    return f.as<bool>();
}

json longOrNull(const pqxx::row& row, const char* col) {
    const auto& f = row[col];
    if (f.is_null()) return nullptr;
    return f.as<long long>();
}

}  // namespace

CalendarController::CalendarController() = default;

void CalendarController::registerRoutes(Router& router, const std::string& prefix) {
    std::cout << "Registering calendar routes with prefix: " << prefix << std::endl;

    router.get(prefix + "/calendar/upcoming", [this](const Request& req) {
        return this->handleGetUpcoming(req);
    });
}

Response CalendarController::handleGetUpcoming(const Request& request) {
    // Parse ?days= with defensible bounds.  A stray days=1000 would drag
    // the response into "next year's practices" territory and blow past
    // the LIMIT — cap at 90 days which covers the longest reasonable
    // planning horizon (a full academic quarter).
    int days = 14;
    if (request.hasQueryParam("days")) {
        try {
            days = std::stoi(request.getQueryParam("days"));
        } catch (...) {
            return jsonError(HttpStatus::BAD_REQUEST,
                             "days must be an integer");
        }
        if (days < 1)  days = 1;
        if (days > 90) days = 90;
    }

    try {
        auto* db = Database::getInstance();

        // The query joins the FH classification (fh_events) to its
        // Google mirror row (gcal_events) and the calendar metadata
        // (gcal_calendars).  Filters:
        //   * deleted_at IS NULL     — respects the tombstone contract
        //   * status <> 'cancelled'  — belt-and-suspenders; the sync
        //                              worker sets deleted_at when
        //                              status flips to 'cancelled' but
        //                              guarding both makes the query
        //                              correct regardless of order.
        //   * starts_at >= now() - 1h — include events that are
        //                               currently underway so the
        //                               live day view isn't empty
        //                               right after kickoff.
        //   * starts_at <= now() + N days
        //
        // rsvps_open_now is computed here so the frontend doesn't
        // have to re-implement §6.5.2's window check just to decide
        // whether to show the RSVP button vs a countdown.
        const std::string sql = R"SQL(
            SELECT
                fe.id                  AS fh_event_id,
                ge.id                  AS gcal_event_id,
                gc.role                AS calendar_role,
                gc.time_zone           AS calendar_time_zone,
                ge.google_event_id,
                ge.recurring_event_id,
                ge.summary,
                ge.description,
                ge.location,
                to_char(ge.starts_at AT TIME ZONE 'UTC',
                        'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS starts_at,
                to_char(ge.ends_at   AT TIME ZONE 'UTC',
                        'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS ends_at,
                ge.all_day,
                ge.status,
                ge.html_link,
                fe.kind,
                fe.category,
                fe.team_id,
                fe.is_home,
                fe.fh_notes,
                CASE
                    WHEN fe.rsvps_open_at IS NULL THEN NULL
                    ELSE to_char(fe.rsvps_open_at AT TIME ZONE 'UTC',
                                 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                END AS rsvps_open_at,
                (fe.rsvps_open_at IS NULL
                 OR fe.rsvps_open_at <= now()) AS rsvps_open_now
            FROM fh_events   fe
            JOIN gcal_events ge ON ge.id = fe.gcal_event_id
            JOIN gcal_calendars gc ON gc.id = ge.calendar_id
            WHERE ge.deleted_at IS NULL
              AND ge.status <> 'cancelled'
              AND ge.starts_at >= now() - INTERVAL '1 hour'
              AND ge.starts_at <= now() + ($1::int * INTERVAL '1 day')
            ORDER BY ge.starts_at ASC, ge.id ASC
            LIMIT 500
        )SQL";

        pqxx::result rows = db->query(sql, {std::to_string(days)});

        json events = json::array();
        events.get_ref<json::array_t&>().reserve(rows.size());

        for (const auto& row : rows) {
            json ev;
            ev["fh_event_id"]       = row["fh_event_id"].as<long long>();
            ev["gcal_event_id"]     = row["gcal_event_id"].as<long long>();
            ev["calendar_role"]     = row["calendar_role"].c_str();
            ev["calendar_time_zone"]= row["calendar_time_zone"].c_str();
            ev["google_event_id"]   = row["google_event_id"].c_str();
            ev["recurring_event_id"]= textOrNull(row, "recurring_event_id");
            ev["summary"]           = textOrNull(row, "summary");
            ev["description"]       = textOrNull(row, "description");
            ev["location"]          = textOrNull(row, "location");
            ev["starts_at"]         = row["starts_at"].c_str();
            ev["ends_at"]           = row["ends_at"].c_str();
            ev["all_day"]           = row["all_day"].as<bool>();
            ev["status"]            = row["status"].c_str();
            ev["html_link"]         = textOrNull(row, "html_link");
            ev["kind"]              = row["kind"].c_str();
            ev["category"]          = textOrNull(row, "category");
            ev["team_id"]           = longOrNull(row, "team_id");
            ev["is_home"]           = boolOrNull(row, "is_home");
            ev["fh_notes"]          = textOrNull(row, "fh_notes");
            ev["rsvps_open_at"]     = textOrNull(row, "rsvps_open_at");
            ev["rsvps_open_now"]    = row["rsvps_open_now"].as<bool>();
            events.push_back(std::move(ev));
        }

        json body = {
            {"days",   days},
            {"count",  events.size()},
            {"events", std::move(events)},
        };
        return jsonOk(body);

    } catch (const std::exception& e) {
        std::cerr << "CalendarController::handleGetUpcoming: "
                  << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
