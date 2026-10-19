#include "CarpoolRouting.h"

#include <cmath>
#include <iomanip>
#include <iostream>
#include <mutex>
#include <sstream>

#include "../core/HttpClient.h"
#include "../database/Database.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

// Nominatim asks for a descriptive UA and no hammering; OSRM's public
// router is equally polite-use.  One outbound call at a time keeps us
// honest without a scheduler — carpool traffic is a handful of legs per
// screen, nearly always answered from the DB caches.
std::mutex g_outboundMutex;

constexpr const char* kUA =
    "footballhome.org carpool (jbreslin@footballhome.org)";

std::string fmt4(double v) {
    std::ostringstream o; o << std::fixed << std::setprecision(4) << v; return o.str();
}
std::string fmt7(double v) {
    std::ostringstream o; o << std::fixed << std::setprecision(7) << v; return o.str();
}

} // namespace

std::optional<LatLon> CarpoolRouting::geocode(const std::string& address) {
    if (address.size() < 6) return std::nullopt;
    std::lock_guard<std::mutex> lock(g_outboundMutex);
    try {
        HttpClient http;
        http.setTotalTimeoutSec(10);
        const std::string url =
            "https://nominatim.openstreetmap.org/search?format=json&limit=1&countrycodes=us&q="
            + HttpClient::urlEncode(address);
        auto res = http.get(url, {{"User-Agent", kUA}, {"Accept", "application/json"}});
        if (!res.ok()) return std::nullopt;
        auto j = json::parse(res.body, nullptr, false);
        if (!j.is_array() || j.empty()) return std::nullopt;
        LatLon out;
        out.lat = std::stod(j[0]["lat"].get<std::string>());
        out.lon = std::stod(j[0]["lon"].get<std::string>());
        return out;
    } catch (const std::exception& e) {
        std::cerr << "[CarpoolRouting::geocode] " << e.what() << std::endl;
        return std::nullopt;
    }
}

std::optional<LatLon> CarpoolRouting::personHome(long long personId) {
    auto* db = Database::getInstance();
    try {
        auto rows = db->query(
            "SELECT id, latitude, longitude, geocoded_at, "
            "       BTRIM(address1 || ', ' || city || ', ' || state || ' ' || zip) AS addr "
            "  FROM person_addresses WHERE person_id = $1::int AND is_primary LIMIT 1",
            {std::to_string(personId)});
        if (rows.empty()) return std::nullopt;
        const auto& r = rows[0];
        if (!r["latitude"].is_null() && !r["longitude"].is_null())
            return LatLon{r["latitude"].as<double>(), r["longitude"].as<double>()};
        if (!r["geocoded_at"].is_null()) return std::nullopt;   // tried before, failed — don't re-ask
        const std::string addr = r["addr"].is_null() ? "" : r["addr"].c_str();
        auto geo = geocode(addr);
        db->query(
            "UPDATE person_addresses SET latitude = NULLIF($2,'')::numeric, longitude = NULLIF($3,'')::numeric, "
            "       geocoded_at = now(), geocode_note = $4 WHERE id = $1::int",
            {std::string(r["id"].c_str()),
             geo ? fmt7(geo->lat) : "", geo ? fmt7(geo->lon) : "",
             geo ? std::string("nominatim") : std::string("no match: ") + addr.substr(0, 80)});
        return geo;
    } catch (const std::exception& e) {
        std::cerr << "[CarpoolRouting::personHome] " << e.what() << std::endl;
        return std::nullopt;
    }
}

std::optional<LatLon> CarpoolRouting::requestPickup(long long requestId) {
    auto* db = Database::getInstance();
    try {
        auto rows = db->query(
            "SELECT pickup_lat, pickup_lon, pickup_geocoded_at, "
            "       BTRIM(address1 || ', ' || city || ', ' || state || ' ' || zip) AS addr "
            "  FROM fh_carpool_requests WHERE id = $1::int",
            {std::to_string(requestId)});
        if (rows.empty()) return std::nullopt;
        const auto& r = rows[0];
        if (!r["pickup_lat"].is_null() && !r["pickup_lon"].is_null())
            return LatLon{r["pickup_lat"].as<double>(), r["pickup_lon"].as<double>()};
        if (!r["pickup_geocoded_at"].is_null()) return std::nullopt;
        const std::string addr = r["addr"].is_null() ? "" : r["addr"].c_str();
        auto geo = geocode(addr);
        db->query(
            "UPDATE fh_carpool_requests SET pickup_lat = NULLIF($2,'')::numeric, pickup_lon = NULLIF($3,'')::numeric, "
            "       pickup_geocoded_at = now(), pickup_geocode_note = $4 WHERE id = $1::int",
            {std::to_string(requestId),
             geo ? fmt7(geo->lat) : "", geo ? fmt7(geo->lon) : "",
             geo ? std::string("nominatim") : std::string("no match")});
        return geo;
    } catch (const std::exception& e) {
        std::cerr << "[CarpoolRouting::requestPickup] " << e.what() << std::endl;
        return std::nullopt;
    }
}

std::optional<LatLon> CarpoolRouting::eventVenue(long long fhEventId) {
    auto* db = Database::getInstance();
    try {
        // The calendar's location text is event_places' key (mig 526).
        auto rows = db->query(
            "SELECT ep.latitude, ep.longitude "
            "  FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
            "  JOIN event_places ep ON ep.location = ge.location "
            " WHERE fe.id = $1::bigint AND ep.latitude IS NOT NULL LIMIT 1",
            {std::to_string(fhEventId)});
        if (rows.empty()) return std::nullopt;
        return LatLon{rows[0]["latitude"].as<double>(), rows[0]["longitude"].as<double>()};
    } catch (const std::exception& e) {
        std::cerr << "[CarpoolRouting::eventVenue] " << e.what() << std::endl;
        return std::nullopt;
    }
}

std::optional<double> CarpoolRouting::minutes(const LatLon& from, const LatLon& to) {
    auto* db = Database::getInstance();
    const std::string fla = fmt4(from.lat), flo = fmt4(from.lon),
                      tla = fmt4(to.lat),   tlo = fmt4(to.lon);
    try {
        auto hit = db->query(
            "SELECT minutes FROM carpool_drive_cache "
            " WHERE from_lat = $1::numeric AND from_lon = $2::numeric "
            "   AND to_lat = $3::numeric AND to_lon = $4::numeric",
            {fla, flo, tla, tlo});
        if (!hit.empty()) return hit[0]["minutes"].as<double>();
    } catch (const std::exception& e) {
        std::cerr << "[CarpoolRouting::minutes cache] " << e.what() << std::endl;
    }

    std::lock_guard<std::mutex> lock(g_outboundMutex);
    try {
        HttpClient http;
        http.setTotalTimeoutSec(10);
        std::ostringstream url;
        url << "https://router.project-osrm.org/route/v1/driving/"
            << fmt7(from.lon) << ',' << fmt7(from.lat) << ';'
            << fmt7(to.lon)   << ',' << fmt7(to.lat)
            << "?overview=false";
        auto res = http.get(url.str(), {{"User-Agent", kUA}});
        if (!res.ok()) return std::nullopt;
        auto j = json::parse(res.body, nullptr, false);
        if (!j.is_object() || !j.contains("routes") || !j["routes"].is_array() || j["routes"].empty())
            return std::nullopt;
        const double secs   = j["routes"][0].value("duration", -1.0);
        const double meters = j["routes"][0].value("distance", 0.0);
        if (secs < 0) return std::nullopt;
        const double mins = secs / 60.0;
        db->query(
            "INSERT INTO carpool_drive_cache (from_lat, from_lon, to_lat, to_lon, minutes, meters) "
            "VALUES ($1::numeric, $2::numeric, $3::numeric, $4::numeric, $5::numeric, $6::int) "
            "ON CONFLICT (from_lat, from_lon, to_lat, to_lon) "
            "DO UPDATE SET minutes = EXCLUDED.minutes, meters = EXCLUDED.meters, fetched_at = now()",
            {fla, flo, tla, tlo,
             std::to_string(mins), std::to_string(static_cast<long long>(meters))});
        return mins;
    } catch (const std::exception& e) {
        std::cerr << "[CarpoolRouting::minutes osrm] " << e.what() << std::endl;
        return std::nullopt;
    }
}
