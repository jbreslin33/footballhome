#include "WeatherController.h"

#include <iostream>

#include "../database/Database.h"
#include "../services/WeatherSync.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }

// One row → one JSON value the database built (json_agg … ::text).
json built(const std::string& sql) {
    auto r = Database::getInstance()->query(sql);
    if (r.empty() || r[0][0].is_null()) return json::array();
    json j = json::parse(r[0][0].c_str(), nullptr, false);
    return j.is_discarded() ? json::array() : j;
}

const char* kHourCols =
    "'at', to_char(h.hour_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"'), 'temp_f', h.temp_f, 'feels_f', h.feels_f, "
    "'wind_chill_f', h.wind_chill_f, 'wbgt_f', h.wbgt_f, 'humidity', h.humidity, 'wind_mph', h.wind_mph, 'gust_mph', h.gust_mph, "
    "'wind_deg', h.wind_deg, 'sky_pct', h.sky_pct, 'precip_pct', h.precip_pct, 'thunder_pct', h.thunder_pct, 'rain_in', h.rain_in, "
    "'snow_in', h.snow_in, 'ice_in', h.ice_in, 'weather', h.weather, 'heat_level', h.heat_level, 'cold_level', h.cold_level, "
    "'level', h.level, 'level_for', h.level_for";
} // namespace

WeatherController::WeatherController() {}

void WeatherController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& r) { return handleGet(r); });
}

Response WeatherController::handleGet(const Request&) {
    try {
        WeatherSync::refreshIfStale();
        const std::string cols = kHourCols;
        json out;
        out["levels"] = built("SELECT COALESCE(json_agg(json_build_object('code', code, 'rank', rank, 'label', label, 'color', color, 'ink', ink) ORDER BY rank), '[]'::json)::text FROM weather_alert_levels");
        out["heat_zones"] = built("SELECT COALESCE(json_agg(json_build_object('category', z.category, 'level', z.level, 'from', z.wbgt_from, 'below', z.wbgt_below, "
                                  "'conditions', z.conditions, 'action', z.action) ORDER BY z.category, l.rank), '[]'::json)::text "
                                  "FROM weather_heat_zones z JOIN weather_alert_levels l ON l.code = z.level");
        out["cold_zones"] = built("SELECT COALESCE(json_agg(json_build_object('level', z.level, 'from', z.wct_from, 'below', z.wct_below, "
                                  "'conditions', z.conditions, 'action', z.action) ORDER BY l.rank), '[]'::json)::text "
                                  "FROM weather_cold_zones z JOIN weather_alert_levels l ON l.code = z.level");
        // A day with no event: whose forecast, at what local hour (mig 1840).
        out["day_slots"] = built("SELECT COALESCE(json_agg(json_build_object('dow', dow, 'facility_id', facility_id, 'local_hour', local_hour) ORDER BY dow), '[]'::json)::text FROM weather_day_slots");
        out["facilities"] = built(
            "SELECT COALESCE(json_agg(json_build_object('id', f.id, 'name', f.name, 'timezone', f.timezone, 'heat_category', fw.heat_category, "
            "  'read_at', to_char(fw.last_ok_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"'), "
            "  'hours', (SELECT COALESCE(json_agg(json_build_object(" + cols + ") ORDER BY h.hour_at), '[]'::json) "
            "              FROM facility_weather_zoned h WHERE h.facility_id = f.id AND h.hour_at >= date_trunc('hour', now()))) ORDER BY f.id), '[]'::json)::text "
            "  FROM facility_weather fw JOIN facilities f ON f.id = fw.facility_id");
        // Every event in the forecast window that is at a facility: its start
        // hour, and over its whole span the highest chances, the coldest
        // wind chill, the hottest WBGT and the worst U.S. Soccer level.
        out["events"] = built(
            "SELECT COALESCE(json_agg(json_build_object('fh_event_id', x.id, 'facility_id', x.facility_id, 'kind', x.kind, "
            "  'at', to_char(x.s AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"'), " + cols + ", "
            "  'max_precip_pct', x.max_pop, 'max_thunder_pct', x.max_thunder, 'snow_in_total', x.snow, 'span_level', x.span_level) ORDER BY x.s), '[]'::json)::text "
            "  FROM (SELECT e.id, e.facility_id, e.kind, t.s, sp.* "
            "          FROM fh_events e JOIN gcal_events g ON g.id = e.gcal_event_id AND g.deleted_at IS NULL AND g.status IS DISTINCT FROM 'cancelled' "
            "         CROSS JOIN LATERAL (SELECT COALESCE(e.start_at, g.starts_at) AS s, COALESCE(e.end_at, g.ends_at, COALESCE(e.start_at, g.starts_at) + interval '90 minutes') AS en) t "
            "         CROSS JOIN LATERAL (SELECT max(z.precip_pct) AS max_pop, max(z.thunder_pct) AS max_thunder, sum(z.snow_in) AS snow, "
            "                                    (SELECT l.code FROM weather_alert_levels l WHERE l.code = ANY(array_agg(z.level)) ORDER BY l.rank DESC LIMIT 1) AS span_level "
            "                               FROM facility_weather_zoned z "
            "                              WHERE z.facility_id = e.facility_id AND z.hour_at >= date_trunc('hour', t.s) AND z.hour_at < t.en) sp "
            "         WHERE e.facility_id IS NOT NULL AND t.s >= now() - interval '3 hours' AND t.s < now() + interval '8 days') x "
            "  JOIN facility_weather_zoned h ON h.facility_id = x.facility_id AND h.hour_at = date_trunc('hour', x.s)");
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "[weather] " << e.what() << std::endl;
        return jsonOut(HttpStatus::INTERNAL_SERVER_ERROR, {{"error", e.what()}});
    }
}
