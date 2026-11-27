#include "WeatherSync.h"

#include <cmath>
#include <ctime>
#include <iostream>
#include <map>
#include <mutex>
#include <string>

#include "../core/HttpClient.h"
#include "../database/Database.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {

std::mutex gWeatherMutex;
const char* kAgent = "FootballHome/1.0 (footballhome.org)";

// "2026-11-24T03:00:00+00:00" → epoch seconds (the grid's times are UTC).
bool parseStart(const std::string& s, std::time_t& out) {
    std::tm tm{};
    if (s.size() < 19 || sscanf(s.c_str(), "%d-%d-%dT%d:%d:%d", &tm.tm_year, &tm.tm_mon, &tm.tm_mday, &tm.tm_hour, &tm.tm_min, &tm.tm_sec) != 6) return false;
    tm.tm_year -= 1900; tm.tm_mon -= 1;
    out = timegm(&tm);
    // An offset other than +00:00 is folded in.
    if (s.size() >= 25 && (s[19] == '+' || s[19] == '-')) {
        int oh = 0, om = 0;
        if (sscanf(s.c_str() + 20, "%d:%d", &oh, &om) == 2) out -= (s[19] == '+' ? 1 : -1) * (oh * 3600 + om * 60);
    }
    return true;
}

// "P2DT12H" / "PT3H" / "P7D" → hours (at least 1).
int parseHours(const std::string& d) {
    int hours = 0, n = 0;
    bool time = false;
    for (char c : d) {
        if (c >= '0' && c <= '9') { n = n * 10 + (c - '0'); continue; }
        if (c == 'T') time = true;
        else if (c == 'D') hours += n * 24;
        else if (c == 'H' && time) hours += n;
        n = 0;
    }
    return hours > 0 ? hours : 1;
}

using Series = std::map<std::time_t, double>;

// One grid element spread over its hours.  `share`: an amount over the span
// (rain, snow) is divided between its hours; a level (temperature) is not.
Series spread(const json& props, const char* key, bool share = false) {
    Series out;
    if (!props.contains(key) || !props[key].contains("values")) return out;
    for (const auto& v : props[key]["values"]) {
        if (!v.contains("value") || !v["value"].is_number()) continue;
        const std::string vt = v.value("validTime", "");
        const auto slash = vt.find('/');
        std::time_t t0;
        if (slash == std::string::npos || !parseStart(vt.substr(0, slash), t0)) continue;
        const int h = parseHours(vt.substr(slash + 1));
        const double val = v["value"].get<double>() / (share ? h : 1);
        for (int i = 0; i < h; ++i) out[t0 + i * 3600] = val;
    }
    return out;
}

// The grid's own weather words per hour: "chance rain_showers; slight_chance thunderstorms".
std::map<std::time_t, std::string> spreadWeather(const json& props) {
    std::map<std::time_t, std::string> out;
    if (!props.contains("weather") || !props["weather"].contains("values")) return out;
    for (const auto& v : props["weather"]["values"]) {
        const std::string vt = v.value("validTime", "");
        const auto slash = vt.find('/');
        std::time_t t0;
        if (slash == std::string::npos || !parseStart(vt.substr(0, slash), t0) || !v.contains("value") || !v["value"].is_array()) continue;
        std::string words;
        for (const auto& w : v["value"]) {
            if (!w.contains("weather") || !w["weather"].is_string()) continue;
            if (!words.empty()) words += "; ";
            if (w.contains("coverage") && w["coverage"].is_string()) words += w["coverage"].get<std::string>() + " ";
            if (w.contains("intensity") && w["intensity"].is_string()) words += w["intensity"].get<std::string>() + " ";
            words += w["weather"].get<std::string>();
        }
        const int h = parseHours(vt.substr(slash + 1));
        for (int i = 0; i < h; ++i) out[t0 + i * 3600] = words;
    }
    return out;
}

double cToF(double c) { return c * 9.0 / 5.0 + 32.0; }
double r1(double x) { return std::round(x * 10.0) / 10.0; }

void stampFailure(const std::string& facility, const std::string& note) {
    try {
        Database::getInstance()->query("UPDATE facility_weather SET last_fetched_at = now(), last_fetch_note = $2 WHERE facility_id = $1::int", {facility, note});
    } catch (const std::exception&) { /* logged by the caller */ }
}

void refreshOne(const std::string& facility, double lat, double lon, std::string gridUrl) {
    auto* db = Database::getInstance();
    HttpClient http;
    http.setTotalTimeoutSec(20);
    const std::vector<std::pair<std::string, std::string>> headers = {{"User-Agent", kAgent}, {"Accept", "application/geo+json"}};
    if (gridUrl.empty()) {
        char pt[64];
        snprintf(pt, sizeof pt, "%.4f,%.4f", lat, lon);
        auto resp = http.get(std::string("https://api.weather.gov/points/") + pt, headers);
        json body = resp.ok() ? json::parse(resp.body, nullptr, false) : json(json::value_t::discarded);
        if (body.is_object() && body.contains("properties") && body["properties"].contains("forecastGridData") && body["properties"]["forecastGridData"].is_string())
            gridUrl = body["properties"]["forecastGridData"].get<std::string>();
        if (gridUrl.rfind("https://api.weather.gov/gridpoints/", 0) != 0) { stampFailure(facility, "no grid for this point (HTTP " + std::to_string(resp.status) + ")"); return; }
    }
    auto resp = http.get(gridUrl, headers);
    json body = resp.ok() ? json::parse(resp.body, nullptr, false) : json(json::value_t::discarded);
    if (!body.is_object() || !body.contains("properties")) { stampFailure(facility, "no forecast (HTTP " + std::to_string(resp.status) + ")"); return; }
    const json& p = body["properties"];

    const Series temp = spread(p, "temperature"), feels = spread(p, "apparentTemperature"), chill = spread(p, "windChill"),
                 wbgt = spread(p, "wetBulbGlobeTemperature"), hum = spread(p, "relativeHumidity"), wind = spread(p, "windSpeed"),
                 gust = spread(p, "windGust"), dir = spread(p, "windDirection"), sky = spread(p, "skyCover"),
                 pop = spread(p, "probabilityOfPrecipitation"), thunder = spread(p, "probabilityOfThunder"),
                 rain = spread(p, "quantitativePrecipitation", true), snow = spread(p, "snowfallAmount", true), ice = spread(p, "iceAccumulation", true);
    const auto words = spreadWeather(p);

    const std::time_t now = std::time(nullptr), from = now - now % 3600, until = from + 8 * 24 * 3600;
    json hours = json::array();
    for (const auto& [t, c] : temp) {
        if (t < from || t > until) continue;
        char at[32];
        std::tm tm{};
        gmtime_r(&t, &tm);
        strftime(at, sizeof at, "%Y-%m-%dT%H:00:00Z", &tm);
        json h = {{"at", at}, {"temp_f", r1(cToF(c))}};
        auto put = [&](const char* key, const Series& s, double (*conv)(double)) {
            auto it = s.find(t);
            if (it != s.end()) h[key] = r1(conv(it->second));
        };
        auto same = [](double x) { return x; };
        auto mph = [](double kmh) { return kmh * 0.621371; };
        auto inch = [](double mm) { return std::round(mm / 25.4 * 100.0) / 100.0; };
        put("feels_f", feels, cToF); put("wind_chill_f", chill, cToF); put("wbgt_f", wbgt, cToF);
        put("humidity", hum, same); put("wind_mph", wind, mph); put("gust_mph", gust, mph); put("wind_deg", dir, same);
        put("sky_pct", sky, same); put("precip_pct", pop, same); put("thunder_pct", thunder, same);
        put("rain_in", rain, inch); put("snow_in", snow, inch); put("ice_in", ice, inch);
        auto w = words.find(t);
        if (w != words.end()) h["weather"] = w->second;
        hours.push_back(h);
    }
    if (hours.empty()) { stampFailure(facility, "the forecast held no hours"); return; }
    auto n = db->query("SELECT fh_weather_load($1::int, $2, $3::jsonb)", {facility, gridUrl, hours.dump()});
    std::cerr << "[weather] facility " << facility << ": " << (n.empty() ? 0 : n[0][0].as<int>()) << " hours" << std::endl;
}

} // namespace

void WeatherSync::refreshIfStale(bool force) {
    std::unique_lock<std::mutex> lock(gWeatherMutex, std::try_to_lock);
    if (!lock.owns_lock()) return;
    try {
        auto due = Database::getInstance()->query(
            "SELECT fw.facility_id, f.latitude, f.longitude, COALESCE(fw.grid_url, '') AS grid_url "
            "  FROM facility_weather fw JOIN facilities f ON f.id = fw.facility_id "
            " WHERE f.latitude IS NOT NULL AND f.longitude IS NOT NULL AND ($1::boolean OR fh_weather_due(fw.facility_id)) ORDER BY fw.facility_id",
            {force ? "true" : "false"});
        for (const auto& r : due) {
            const std::string id = std::to_string(r["facility_id"].as<int>());
            try { refreshOne(id, r["latitude"].as<double>(), r["longitude"].as<double>(), r["grid_url"].c_str()); }
            catch (const std::exception& e) { std::cerr << "[weather] facility " << id << ": " << e.what() << std::endl; stampFailure(id, e.what()); }
        }
    } catch (const std::exception& e) {
        std::cerr << "[weather] " << e.what() << std::endl;
    }
}
