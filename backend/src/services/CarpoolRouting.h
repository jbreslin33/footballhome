#pragma once
#include <optional>
#include <string>

// CarpoolRouting — geocoding + driving minutes for the carpool pickup
// plans (migs 608/609).  Owner 2026-10-19: "show 3 options and the
// estimated time … to leave and be on time with pickups".
//
// Same stack as the #my schedule-conflict checker (mig 526,
// scripts/drive-times.js): OpenStreetMap Nominatim for geocoding (one
// polite request at a time, cached forever on the row that owns the
// address) and the public OSRM router for leg minutes (cached in
// carpool_drive_cache keyed by coordinates rounded to 4 decimals).  No
// Google key; estimates are door-to-door driving without live traffic —
// schedule_conflict_policies.traffic_factor pads them.
//
// Every function is best-effort: std::nullopt means "no estimate", and
// the carpool UI says so (copy tier 'no_geo') instead of guessing.
struct LatLon { double lat = 0, lon = 0; };

class CarpoolRouting {
public:
    // The viewer's primary home, geocoded (cached on person_addresses).
    static std::optional<LatLon> personHome(long long personId);

    // A request's snapshot pickup address, geocoded (cached on the row).
    static std::optional<LatLon> requestPickup(long long requestId);

    // The event's venue via its calendar location → event_places.
    static std::optional<LatLon> eventVenue(long long fhEventId);

    // Driving minutes for one leg, cache-first.
    static std::optional<double> minutes(const LatLon& from, const LatLon& to);

private:
    static std::optional<LatLon> geocode(const std::string& address);
};
