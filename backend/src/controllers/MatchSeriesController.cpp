#include "MatchSeriesController.h"

#include "../database/Database.h"
#include "../services/RsvpMaterialization.h"
#include "../third_party/json.hpp"

#include <exception>
#include <iostream>
#include <optional>
#include <regex>
#include <sstream>
#include <string>
#include <vector>

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

// Extract the numeric id from a path like "/api/match-series/42".
// Returns 0 on parse failure.
long long extractSeriesIdFromPath(const std::string& path) {
    static const std::regex re(R"(/api/match-series/([0-9]+)(?:/|$))");
    std::smatch m;
    if (std::regex_search(path, m, re)) {
        try { return std::stoll(m[1].str()); } catch (...) { return 0; }
    }
    return 0;
}

// Pull the Authorization bearer user id (userId string claim).  Same
// pattern used in EventReminderController.  requireBearer() has
// already verified the signature so we skip re-checking.
std::string bearerUserIdString(const Request& request) {
    const std::string h = request.getHeader("Authorization");
    if (h.size() < 8 || h.compare(0, 7, "Bearer ") != 0) return {};
    const std::string token = h.substr(7);
    const auto d1 = token.find('.');
    if (d1 == std::string::npos) return {};
    const auto d2 = token.find('.', d1 + 1);
    if (d2 == std::string::npos) return {};
    // Cheap userId extraction — payload is base64url JSON, we just
    // regex-scan the decoded string.  Good enough for an audit field.
    // If the payload isn't valid base64url this returns "".
    std::string payload;
    {
        std::string b = token.substr(d1 + 1, d2 - d1 - 1);
        // Convert base64url → base64 and pad.
        for (auto& c : b) { if (c == '-') c = '+'; else if (c == '_') c = '/'; }
        while (b.size() % 4) b.push_back('=');
        // Use pqxx-style decode via a tiny inline routine.
        static const std::string A =
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        std::vector<int> t(256, -1);
        for (int i = 0; i < 64; ++i) t[(unsigned char)A[i]] = i;
        int val = 0, bits = 0;
        for (unsigned char c : b) {
            if (c == '=') break;
            int v = t[c];
            if (v < 0) continue;
            val = (val << 6) | v;
            bits += 6;
            if (bits >= 8) {
                bits -= 8;
                payload.push_back(char((val >> bits) & 0xFF));
            }
        }
    }
    const std::string needle = "\"userId\":\"";
    auto pos = payload.find(needle);
    if (pos == std::string::npos) return {};
    pos += needle.size();
    auto end = payload.find('"', pos);
    if (end == std::string::npos) return {};
    return payload.substr(pos, end - pos);
}

// ---- JSON field helpers -------------------------------------------

std::optional<std::string> jsonStr(const json& j, const char* k) {
    if (!j.contains(k) || j[k].is_null()) return std::nullopt;
    if (j[k].is_string()) return j[k].get<std::string>();
    return std::nullopt;
}

std::optional<long long> jsonInt(const json& j, const char* k) {
    if (!j.contains(k) || j[k].is_null()) return std::nullopt;
    if (j[k].is_number_integer())  return j[k].get<long long>();
    if (j[k].is_number_unsigned()) return static_cast<long long>(j[k].get<unsigned long long>());
    if (j[k].is_string()) {
        try { return std::stoll(j[k].get<std::string>()); } catch (...) { return std::nullopt; }
    }
    return std::nullopt;
}

std::optional<bool> jsonBool(const json& j, const char* k) {
    if (!j.contains(k) || j[k].is_null()) return std::nullopt;
    if (j[k].is_boolean()) return j[k].get<bool>();
    if (j[k].is_number())  return j[k].get<double>() != 0.0;
    if (j[k].is_string()) {
        const auto s = j[k].get<std::string>();
        return (s == "true" || s == "1" || s == "yes");
    }
    return std::nullopt;
}

// pqxx field → json helpers.  Keep nulls as null (not empty string)
// so the frontend can distinguish "not set" from "empty".
json colStr(const pqxx::row& r, const char* c) {
    return r[c].is_null() ? json(nullptr) : json(r[c].as<std::string>());
}
json colInt(const pqxx::row& r, const char* c) {
    return r[c].is_null() ? json(nullptr) : json(r[c].as<long long>());
}
json colBool(const pqxx::row& r, const char* c) {
    return r[c].is_null() ? json(nullptr) : json(r[c].as<bool>());
}

json rowToSeries(const pqxx::row& r) {
    return {
        {"id",                 r["id"].as<long long>()},
        {"name",               colStr(r, "name")},
        {"match_type_id",      colInt(r, "match_type_id")},
        {"home_team_id",       colInt(r, "home_team_id")},
        {"away_team_id",       colInt(r, "away_team_id")},
        {"venue_id",           colInt(r, "venue_id")},
        {"day_of_week",        colInt(r, "day_of_week")},
        {"start_time",         colStr(r, "start_time")},
        {"end_time",           colStr(r, "end_time")},
        {"duration_min",       colInt(r, "duration_min")},
        {"title",              colStr(r, "title")},
        {"description",        colStr(r, "description")},
        {"starts_on",          colStr(r, "starts_on")},
        {"ends_on",            colStr(r, "ends_on")},
        {"active",             colBool(r, "active")},
        {"created_by_user_id", colInt(r, "created_by_user_id")},
        {"created_at",         colStr(r, "created_at")},
        {"updated_at",         colStr(r, "updated_at")},
    };
}

// Standard SELECT list so every read path returns identical shape.
constexpr const char* kSelectCols =
    "id, name, match_type_id, home_team_id, away_team_id, venue_id, "
    "day_of_week, start_time::text AS start_time, "
    "end_time::text   AS end_time, "
    "duration_min, title, description, "
    "starts_on::text  AS starts_on, "
    "ends_on::text    AS ends_on, "
    "active, created_by_user_id, "
    "created_at::text AS created_at, "
    "updated_at::text AS updated_at";

}  // namespace

MatchSeriesController::MatchSeriesController()  = default;
MatchSeriesController::~MatchSeriesController() = default;

void MatchSeriesController::registerRoutes(Router& router, const std::string& prefix) {
    // prefix is "/api/match-series".
    router.post  (prefix + "/rollover",
                  [this](const Request& r) { return handleRollover(r); });
    router.get   (prefix,
                  [this](const Request& r) { return handleList(r); });
    router.post  (prefix,
                  [this](const Request& r) { return handleCreate(r); });
    router.get   (prefix + "/:id",
                  [this](const Request& r) { return handleGet(r); });
    router.put   (prefix + "/:id",
                  [this](const Request& r) { return handleUpdate(r); });
    router.del   (prefix + "/:id",
                  [this](const Request& r) { return handleDelete(r); });
}

// ---------------------------------------------------------------------
// POST /api/match-series/rollover
// ---------------------------------------------------------------------
Response MatchSeriesController::handleRollover(const Request& request) {
    if (!requireBearer(request)) {
        return jsonError(HttpStatus::UNAUTHORIZED, "auth required");
    }
    try {
        auto result = RsvpMaterialization::rollover();
        return jsonOk({
            {"success",           true},
            {"windowStart",       result.windowStartIso},
            {"windowEnd",         result.windowEndIso},
            {"matchesInserted",   result.matchesInserted},
            {"rsvpsInserted",     result.rsvpsInserted},
        });
    } catch (const std::exception& e) {
        std::cerr << "[MatchSeriesController::handleRollover] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ---------------------------------------------------------------------
// GET /api/match-series
// ---------------------------------------------------------------------
Response MatchSeriesController::handleList(const Request& request) {
    if (!requireBearer(request)) {
        return jsonError(HttpStatus::UNAUTHORIZED, "auth required");
    }
    auto* db = Database::getInstance();
    try {
        // Include a lightweight per-series stats block: count of
        // upcoming vs past materialised matches, and whether any
        // overrides exist.  Cheap because idx_matches_series covers it.
        const std::string sql =
            std::string("SELECT ") + kSelectCols + ", "
            "  (SELECT COUNT(*) FROM matches "
            "    WHERE series_id = ms.id "
            "      AND match_date >= CURRENT_DATE) AS upcoming_count, "
            "  (SELECT COUNT(*) FROM matches "
            "    WHERE series_id = ms.id "
            "      AND match_date < CURRENT_DATE) AS past_count, "
            "  (SELECT COUNT(*) FROM matches "
            "    WHERE series_id = ms.id "
            "      AND is_override = true) AS override_count "
            "  FROM match_series ms "
            " ORDER BY active DESC, day_of_week, start_time";
        auto rows = db->query(sql);
        json arr = json::array();
        for (const auto& r : rows) {
            json entry = rowToSeries(r);
            entry["upcoming_count"] = r["upcoming_count"].as<long long>();
            entry["past_count"]     = r["past_count"].as<long long>();
            entry["override_count"] = r["override_count"].as<long long>();
            arr.push_back(entry);
        }
        return jsonOk({{"data", arr}});
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/match-series] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ---------------------------------------------------------------------
// POST /api/match-series
// ---------------------------------------------------------------------
Response MatchSeriesController::handleCreate(const Request& request) {
    if (!requireBearer(request)) {
        return jsonError(HttpStatus::UNAUTHORIZED, "auth required");
    }
    json body;
    try { body = json::parse(request.getBody().empty() ? "{}" : request.getBody()); }
    catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("invalid JSON: ") + e.what());
    }

    auto name         = jsonStr(body, "name");
    auto matchTypeId  = jsonInt(body, "match_type_id");
    auto dayOfWeek    = jsonInt(body, "day_of_week");
    auto startTime    = jsonStr(body, "start_time");
    auto startsOn     = jsonStr(body, "starts_on");
    if (!name || name->empty()) return jsonError(HttpStatus::BAD_REQUEST, "name required");
    if (!matchTypeId)           return jsonError(HttpStatus::BAD_REQUEST, "match_type_id required");
    if (!dayOfWeek || *dayOfWeek < 0 || *dayOfWeek > 6)
        return jsonError(HttpStatus::BAD_REQUEST, "day_of_week 0-6 required");
    if (!startTime || startTime->empty())
        return jsonError(HttpStatus::BAD_REQUEST, "start_time required");
    if (!startsOn || startsOn->empty())
        return jsonError(HttpStatus::BAD_REQUEST, "starts_on (YYYY-MM-DD) required");

    auto homeTeam   = jsonInt (body, "home_team_id");
    auto awayTeam   = jsonInt (body, "away_team_id");
    auto venue      = jsonInt (body, "venue_id");
    auto endTime    = jsonStr (body, "end_time");
    auto duration   = jsonInt (body, "duration_min");
    auto title      = jsonStr (body, "title");
    auto description= jsonStr (body, "description");
    auto endsOn     = jsonStr (body, "ends_on");
    auto active     = jsonBool(body, "active");
    const std::string createdBy = bearerUserIdString(request);

    auto emptyIfNo = [](const std::optional<std::string>& v) {
        return v.value_or("");
    };
    auto strIfNo = [](const std::optional<long long>& v) {
        return v.has_value() ? std::to_string(*v) : std::string{};
    };

    auto* db = Database::getInstance();
    try {
        // NULLIF trick lets us pass "" for optional-string columns and
        // let Postgres coerce them to NULL.  For integer columns we
        // wrap NULLIF($X,'')::int.
        const std::string sql =
            std::string("INSERT INTO match_series ")
            + "(name, match_type_id, home_team_id, away_team_id, venue_id, "
              " day_of_week, start_time, end_time, duration_min, "
              " title, description, starts_on, ends_on, active, created_by_user_id) "
            + "VALUES ($1, $2::int, "
              " NULLIF($3,'')::int, NULLIF($4,'')::int, NULLIF($5,'')::int, "
              " $6::smallint, $7::time, "
              " NULLIF($8,'')::time, NULLIF($9,'')::int, "
              " NULLIF($10,''), NULLIF($11,''), "
              " $12::date, NULLIF($13,'')::date, "
              " COALESCE(NULLIF($14,'')::boolean, true), "
              " NULLIF($15,'')::int) "
              "RETURNING id";
        auto r = db->query(sql, {
            *name,
            std::to_string(*matchTypeId),
            strIfNo(homeTeam),
            strIfNo(awayTeam),
            strIfNo(venue),
            std::to_string(*dayOfWeek),
            *startTime,
            emptyIfNo(endTime),
            strIfNo(duration),
            emptyIfNo(title),
            emptyIfNo(description),
            *startsOn,
            emptyIfNo(endsOn),
            active.has_value() ? (*active ? "true" : "false") : "",
            createdBy,
        });
        if (r.empty()) return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "insert returned no id");
        const long long id = r[0]["id"].as<long long>();

        auto rows = db->query(
            std::string("SELECT ") + kSelectCols + " FROM match_series WHERE id = $1::int",
            {std::to_string(id)});
        return jsonOk({{"data", rowToSeries(rows[0])}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/match-series] " << e.what() << std::endl;
        return jsonError(HttpStatus::BAD_REQUEST, e.what());
    }
}

// ---------------------------------------------------------------------
// GET /api/match-series/:id
// ---------------------------------------------------------------------
Response MatchSeriesController::handleGet(const Request& request) {
    if (!requireBearer(request)) {
        return jsonError(HttpStatus::UNAUTHORIZED, "auth required");
    }
    const long long id = extractSeriesIdFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "invalid id");

    auto* db = Database::getInstance();
    try {
        auto rows = db->query(
            std::string("SELECT ") + kSelectCols + " FROM match_series WHERE id = $1::int",
            {std::to_string(id)});
        if (rows.empty()) return jsonError(HttpStatus::NOT_FOUND, "series not found");
        json out = rowToSeries(rows[0]);

        // Also include the next handful of upcoming materialised
        // matches so the editor can show "next occurrences".
        auto ms = db->query(
            "SELECT id, match_date::text AS match_date, "
            "       match_time::text AS match_time, "
            "       title, is_override, "
            "       (cancelled_at IS NOT NULL) AS cancelled "
            "  FROM matches "
            " WHERE series_id = $1::int "
            "   AND match_date >= CURRENT_DATE "
            " ORDER BY match_date, match_time "
            " LIMIT 8",
            {std::to_string(id)});
        json upcoming = json::array();
        for (const auto& r : ms) {
            upcoming.push_back({
                {"id",          r["id"].as<long long>()},
                {"match_date",  colStr(r, "match_date")},
                {"match_time",  colStr(r, "match_time")},
                {"title",       colStr(r, "title")},
                {"is_override", r["is_override"].as<bool>()},
                {"cancelled",   r["cancelled"].as<bool>()},
            });
        }
        out["upcoming"] = upcoming;
        return jsonOk({{"data", out}});
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/match-series/:id] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ---------------------------------------------------------------------
// PUT /api/match-series/:id
// ---------------------------------------------------------------------
Response MatchSeriesController::handleUpdate(const Request& request) {
    if (!requireBearer(request)) {
        return jsonError(HttpStatus::UNAUTHORIZED, "auth required");
    }
    const long long id = extractSeriesIdFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "invalid id");

    json body;
    try { body = json::parse(request.getBody().empty() ? "{}" : request.getBody()); }
    catch (const std::exception& e) {
        return jsonError(HttpStatus::BAD_REQUEST, std::string("invalid JSON: ") + e.what());
    }

    auto* db = Database::getInstance();
    try {
        auto existing = db->query(
            std::string("SELECT ") + kSelectCols + " FROM match_series WHERE id = $1::int",
            {std::to_string(id)});
        if (existing.empty()) return jsonError(HttpStatus::NOT_FOUND, "series not found");

        // Assemble a dynamic UPDATE.  We only touch columns present in
        // the request body; unset keys keep their existing values.
        std::vector<std::string> setClauses;
        std::vector<std::string> params;
        int p = 0;
        auto addStr = [&](const char* col, const std::optional<std::string>& v) {
            if (!v.has_value()) return;
            setClauses.emplace_back(std::string(col) + " = $" + std::to_string(++p));
            params.push_back(*v);
        };
        auto addInt = [&](const char* col, const std::optional<long long>& v, const char* cast) {
            if (!v.has_value()) return;
            setClauses.emplace_back(std::string(col) + " = $" + std::to_string(++p) + "::" + cast);
            params.push_back(std::to_string(*v));
        };
        auto addNullableInt = [&](const char* col, const json& j, const char* key, const char* cast) {
            if (!j.contains(key)) return;
            if (j[key].is_null()) {
                setClauses.emplace_back(std::string(col) + " = NULL");
                return;
            }
            auto v = jsonInt(j, key);
            if (!v.has_value()) return;
            setClauses.emplace_back(std::string(col) + " = $" + std::to_string(++p) + "::" + cast);
            params.push_back(std::to_string(*v));
        };
        auto addNullableStr = [&](const char* col, const json& j, const char* key, const char* cast) {
            if (!j.contains(key)) return;
            if (j[key].is_null()) {
                setClauses.emplace_back(std::string(col) + " = NULL");
                return;
            }
            auto v = jsonStr(j, key);
            if (!v.has_value()) return;
            if (v->empty()) {
                setClauses.emplace_back(std::string(col) + " = NULL");
                return;
            }
            setClauses.emplace_back(std::string(col) + " = $" + std::to_string(++p) + "::" + cast);
            params.push_back(*v);
        };
        auto addBool = [&](const char* col, const std::optional<bool>& v) {
            if (!v.has_value()) return;
            setClauses.emplace_back(std::string(col) + " = $" + std::to_string(++p) + "::boolean");
            params.push_back(*v ? "true" : "false");
        };

        // Required-ish scalars — updatable, but never NULL.
        addStr("name",              jsonStr (body, "name"));
        addInt("match_type_id",     jsonInt (body, "match_type_id"), "int");
        addInt("day_of_week",       jsonInt (body, "day_of_week"),   "smallint");
        addStr("start_time",        jsonStr (body, "start_time"));
        addStr("starts_on",         jsonStr (body, "starts_on"));
        addBool("active",           jsonBool(body, "active"));
        // Nullable columns — explicit null in body clears them.
        addNullableInt("home_team_id",  body, "home_team_id",  "int");
        addNullableInt("away_team_id",  body, "away_team_id",  "int");
        addNullableInt("venue_id",      body, "venue_id",      "int");
        addNullableInt("duration_min",  body, "duration_min",  "int");
        addNullableStr("end_time",      body, "end_time",      "time");
        addNullableStr("title",         body, "title",         "varchar");
        addNullableStr("description",   body, "description",   "text");
        addNullableStr("ends_on",       body, "ends_on",       "date");

        if (setClauses.empty()) {
            return jsonError(HttpStatus::BAD_REQUEST, "no updatable fields provided");
        }

        std::string sql = "UPDATE match_series SET ";
        for (std::size_t i = 0; i < setClauses.size(); ++i) {
            if (i) sql += ", ";
            sql += setClauses[i];
        }
        sql += " WHERE id = $" + std::to_string(++p) + "::int";
        params.push_back(std::to_string(id));

        db->query(sql, params);

        // Optional "also apply to future materialised matches" flag.
        // We deliberately mirror only the fields that make sense to
        // propagate: match_type_id, home/away/venue, match_time,
        // end_time, title, description.  Not: day_of_week (that
        // would move matches to a different date).
        const bool applyFuture = jsonBool(body, "apply_to_future").value_or(false);
        int propagated = 0;
        if (applyFuture) {
            if (body.contains("day_of_week")) {
                return jsonError(HttpStatus::BAD_REQUEST,
                    "cannot change day_of_week with apply_to_future=true; "
                    "delete future matches then create fresh series");
            }
            std::vector<std::string> mSet;
            std::vector<std::string> mParams;
            int mp = 0;
            auto add = [&](const char* col, const std::optional<std::string>& v, const char* cast, bool nullable) {
                if (!v.has_value()) return;
                if (nullable && v->empty()) {
                    mSet.emplace_back(std::string(col) + " = NULL");
                    return;
                }
                mSet.emplace_back(std::string(col) + " = $" + std::to_string(++mp) + "::" + cast);
                mParams.push_back(*v);
            };
            auto addI = [&](const char* col, const std::optional<long long>& v, const char* cast, bool nullable, const json& j, const char* key) {
                if (!j.contains(key)) return;
                if (j[key].is_null()) {
                    if (nullable) mSet.emplace_back(std::string(col) + " = NULL");
                    return;
                }
                if (!v.has_value()) return;
                mSet.emplace_back(std::string(col) + " = $" + std::to_string(++mp) + "::" + cast);
                mParams.push_back(std::to_string(*v));
            };

            add("match_time",  jsonStr(body, "start_time"),  "time",    false);
            add("end_time",    jsonStr(body, "end_time"),    "time",    true);
            add("title",       jsonStr(body, "title"),       "varchar", true);
            add("description", jsonStr(body, "description"), "text",    true);
            addI("match_type_id", jsonInt(body, "match_type_id"), "int", false, body, "match_type_id");
            addI("home_team_id",  jsonInt(body, "home_team_id"),  "int", true,  body, "home_team_id");
            addI("away_team_id",  jsonInt(body, "away_team_id"),  "int", true,  body, "away_team_id");
            addI("venue_id",      jsonInt(body, "venue_id"),      "int", true,  body, "venue_id");

            if (!mSet.empty()) {
                std::string msql = "UPDATE matches SET ";
                for (std::size_t i = 0; i < mSet.size(); ++i) {
                    if (i) msql += ", ";
                    msql += mSet[i];
                }
                msql += " WHERE series_id = $" + std::to_string(++mp) + "::int"
                        " AND is_override = false"
                        " AND match_date >= CURRENT_DATE";
                mParams.push_back(std::to_string(id));
                auto upd = db->query(msql, mParams);
                propagated = static_cast<int>(upd.affected_rows());
            }
        }

        auto rows = db->query(
            std::string("SELECT ") + kSelectCols + " FROM match_series WHERE id = $1::int",
            {std::to_string(id)});
        json out = rowToSeries(rows[0]);
        out["propagated_matches"] = propagated;
        return jsonOk({{"data", out}});
    } catch (const std::exception& e) {
        std::cerr << "[PUT /api/match-series/:id] " << e.what() << std::endl;
        return jsonError(HttpStatus::BAD_REQUEST, e.what());
    }
}

// ---------------------------------------------------------------------
// DELETE /api/match-series/:id
// ---------------------------------------------------------------------
Response MatchSeriesController::handleDelete(const Request& request) {
    if (!requireBearer(request)) {
        return jsonError(HttpStatus::UNAUTHORIZED, "auth required");
    }
    const long long id = extractSeriesIdFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::BAD_REQUEST, "invalid id");

    // Optional ?cancel_future=true → also soft-cancel upcoming
    // materialised matches from this series (non-overrides only).
    const std::string cancelFutureRaw = request.getQueryParam("cancel_future");
    const bool cancelFuture =
        (cancelFutureRaw == "true" || cancelFutureRaw == "1" || cancelFutureRaw == "yes");

    auto* db = Database::getInstance();
    try {
        auto existing = db->query(
            "SELECT id FROM match_series WHERE id = $1::int",
            {std::to_string(id)});
        if (existing.empty()) return jsonError(HttpStatus::NOT_FOUND, "series not found");

        db->query(
            "UPDATE match_series SET active = false WHERE id = $1::int",
            {std::to_string(id)});

        int cancelled = 0;
        if (cancelFuture) {
            auto upd = db->query(
                "UPDATE matches "
                "   SET cancelled_at = NOW() "
                " WHERE series_id   = $1::int "
                "   AND is_override = false "
                "   AND cancelled_at IS NULL "
                "   AND match_date >= CURRENT_DATE",
                {std::to_string(id)});
            cancelled = static_cast<int>(upd.affected_rows());
        }

        return jsonOk({
            {"success",           true},
            {"id",                id},
            {"cancelled_matches", cancelled},
        });
    } catch (const std::exception& e) {
        std::cerr << "[DELETE /api/match-series/:id] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
