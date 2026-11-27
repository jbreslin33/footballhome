#pragma once
#include <string>
#include "../core/Controller.h"

// ⛅ Weather (mig 1837) — the forecast for every facility and every event.
//
//   GET /api/weather → { read_at, levels[], heat_zones[], cold_zones[],
//                        day_slots[{dow, facility_id, local_hour}],
//                        facilities[{id, name, heat_category, hours[]}],
//                        events[{fh_event_id, facility_id, at, kind, …}] }
//
// Public, like /api/pyramid: it is a forecast and event start times, and a
// player's page must never be logged out by a weather chip.  Hours come
// from facility_weather_zoned (each with its U.S. Soccer heat / cold level);
// an event carries its start hour plus the worst of its whole span.
class WeatherController : public Controller {
public:
    WeatherController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    Response handleGet(const Request& request);
};
