#pragma once

// WeatherSync — the forecast behind ⛅ Weather and every event's weather
// chip (mig 1837).
//
// Source: the National Weather Service grid forecast (api.weather.gov, free,
// no key).  A facility's point (latitude / longitude) names its grid once
// (/points/<lat>,<lon> → properties.forecastGridData, kept in
// facility_weather.grid_url); the grid gives each element as a time series
// of {validTime: "<start>/<ISO-8601 duration>", value}.  Every series is
// spread over its hours, converted (°C→°F, km/h→mph, mm→in) and handed to
// fh_weather_load(), which does every write.
//
// refreshIfStale() runs from WeatherController on a page load — the same
// on-open pattern as the pyramid tables; a failed read keeps the previous
// forecast and stamps facility_weather.last_fetch_note.
class WeatherSync {
public:
    static void refreshIfStale(bool force = false);
};
