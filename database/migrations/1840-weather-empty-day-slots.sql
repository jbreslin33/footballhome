-- 1840 (2026-11-24) — ⛅ A calendar day with no event shows the forecast
-- as its placeholder (owner: "if no event on a day show weather as place
-- holder if during week show it at standard mens time 7pm").
--
-- weather_day_slots: per weekday (0 = Sunday), the facility and local hour
-- whose forecast stands in.  Monday–Friday 7 PM (the standard men's time)
-- at the Lighthouse Sport Complex; Saturday and Sunday at noon.
BEGIN;
CREATE TABLE weather_day_slots (
  dow         smallint PRIMARY KEY CHECK (dow BETWEEN 0 AND 6),
  facility_id integer NOT NULL REFERENCES facility_weather(facility_id) ON DELETE CASCADE,
  local_hour  smallint NOT NULL CHECK (local_hour BETWEEN 0 AND 23)
);
INSERT INTO weather_day_slots (dow, facility_id, local_hour)
SELECT d, 1, CASE WHEN d BETWEEN 1 AND 5 THEN 19 ELSE 12 END FROM generate_series(0, 6) d;
COMMIT;
