-- 1837 (2026-11-24) — ⛅ Weather: the forecast on every event and a Weather
-- page (owner: "i need a weather page at top level. and the weather should
-- show on each practice" · "needs to be on all events" · "projected
-- weather" · "temp, wind chill, rain or snow etc, lightning thunder etc if
-- any are predicted and percent chances of all things. also it needs to
-- have us soccer badge and zone the temp etc would be in").
--
-- Source: the National Weather Service grid forecast (api.weather.gov —
-- free, no key, public domain), hourly, 7 days out, per facility.
-- WeatherSync (C++) reads it when fh_weather_due() says so and
-- fh_weather_load() does every write.
--
-- Zones: U.S. Soccer's Recognize to Recover guidelines, as rows —
--   heat  Wet Bulb Globe Temperature (°F) by regional category (Heat
--         Guidelines, step 3 table)
--   cold  Wind Chill Temperature (°F) (Cold Weather Guidelines, step 2)
-- A facility's regional category is facility_weather.heat_category.
BEGIN;

CREATE TABLE weather_alert_levels (
  code  text PRIMARY KEY,
  rank  smallint NOT NULL UNIQUE,      -- 0 = good … 4 = extreme
  label text NOT NULL,
  color text NOT NULL,
  ink   text NOT NULL
);
INSERT INTO weather_alert_levels VALUES
  ('green', 0, 'Green', '#16a34a', '#ffffff'), ('yellow', 1, 'Yellow', '#facc15', '#111827'),
  ('orange', 2, 'Orange', '#f97316', '#111827'), ('red', 3, 'Red', '#dc2626', '#ffffff'),
  ('black', 4, 'Black', '#000000', '#ffffff');

-- lo/hi are inclusive bounds in °F; NULL = open.  The guideline prints
-- one-decimal ranges with 0.1° gaps; hi is stored as the next level's lo
-- (exclusive) so no reading falls between two levels.
CREATE TABLE weather_heat_zones (
  category   smallint NOT NULL CHECK (category IN (1, 2, 3)),
  level      text NOT NULL REFERENCES weather_alert_levels(code),
  wbgt_from  numeric,           -- >= this
  wbgt_below numeric,           -- <  this
  conditions text NOT NULL,
  action     text NOT NULL,
  PRIMARY KEY (category, level)
);
INSERT INTO weather_heat_zones (category, level, wbgt_from, wbgt_below, conditions, action)
SELECT c.category, z.level, CASE z.level WHEN 'green' THEN NULL WHEN 'yellow' THEN c.y WHEN 'orange' THEN c.o WHEN 'red' THEN c.r ELSE c.b END,
       CASE z.level WHEN 'green' THEN c.y WHEN 'yellow' THEN c.o WHEN 'orange' THEN c.r WHEN 'red' THEN c.b ELSE NULL END,
       z.conditions, z.action
FROM (VALUES (1, 76.2, 81.1, 84.2, 86.2), (2, 79.9, 84.7, 87.8, 89.8), (3, 82.2, 87.1, 90.1, 92.0)) AS c(category, y, o, r, b)
CROSS JOIN (VALUES
  ('green',  'Good Conditions', 'Normal Activities. 3 Separate 3 minute breaks each hour of training, OR a 10 minute break every 40 minutes'),
  ('yellow', 'Less than Ideal Conditions', '3 Separate 4 minute breaks each hour, OR a 12 minute break every 40 minutes of training'),
  ('orange', 'Moderate Risk for Heat Related Illness', 'Maximum of 2 hours of training with 4 by 4 minute breaks each hour, OR a 10 minute break every 30 minutes of training.'),
  ('red',    'High Risk for Heat Related Illness', 'Maximum of 1 hour of training with 4 by 4 minute breaks within the hour. No additional conditioning allowed.'),
  ('black',  'Extreme Conditions', 'No Outdoor Training, delay training until cooler, or Cancel Training.')
) AS z(level, conditions, action);

CREATE TABLE weather_cold_zones (
  level      text PRIMARY KEY REFERENCES weather_alert_levels(code),
  wct_from   numeric,           -- >= this
  wct_below  numeric,           -- <  this
  conditions text NOT NULL,
  action     text NOT NULL
);
INSERT INTO weather_cold_zones VALUES
  ('green',  30.5, NULL, 'Good Conditions', 'Normal activities'),
  ('yellow', 24.5, 30.5, 'Less than Ideal Conditions', 'Be aware of the potential for cold injury and notify appropriate personnel of the potential'),
  ('orange', 15.5, 24.5, 'Moderate Risk for Cold Related Illness', 'Provide additional protective clothing, cover as much exposed skin as practical, and provide opportunities and facilities for rewarming'),
  ('red',    0.5,  15.5, 'High Risk for Cold Related Illness', 'Consider modifying activity to limit exposure and allow for more frequent chances to rewarm'),
  ('black',  NULL, 0.5,  'Extreme Conditions', 'Cancel or attempt to move activities indoors. Frostbite could occur');

CREATE TABLE facility_weather (
  facility_id     integer PRIMARY KEY REFERENCES facilities(id) ON DELETE CASCADE,
  heat_category   smallint NOT NULL DEFAULT 2 CHECK (heat_category IN (1, 2, 3)),
  grid_url        text,                      -- api.weather.gov/gridpoints/<office>/<x>,<y>, found once
  refresh_minutes integer NOT NULL DEFAULT 60,
  last_fetched_at timestamptz,
  last_ok_at      timestamptz,
  last_fetch_note text
);
INSERT INTO facility_weather (facility_id)
SELECT id FROM facilities WHERE is_active AND latitude IS NOT NULL AND longitude IS NOT NULL;

CREATE TABLE facility_weather_hours (
  facility_id  integer NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
  hour_at      timestamptz NOT NULL,
  temp_f       numeric(5,1),
  feels_f      numeric(5,1),     -- apparent temperature
  wind_chill_f numeric(5,1),     -- NULL when the service gives none (too warm for it)
  wbgt_f       numeric(5,1),
  humidity     smallint,
  wind_mph     smallint,
  gust_mph     smallint,
  wind_deg     smallint,
  sky_pct      smallint,
  precip_pct   smallint,
  thunder_pct  smallint,
  rain_in      numeric(5,2),
  snow_in      numeric(5,2),
  ice_in       numeric(5,2),
  weather      text,             -- the service's own words, 'coverage weather; …'
  PRIMARY KEY (facility_id, hour_at)
);

CREATE FUNCTION fh_weather_due(p_facility integer) RETURNS boolean
LANGUAGE sql STABLE AS $$
  SELECT last_fetched_at IS NULL OR last_fetched_at < now() - make_interval(mins => refresh_minutes)
    FROM facility_weather WHERE facility_id = p_facility
$$;

-- p_hours = [{at, temp_f, feels_f, …}] (the columns above).  Replaces the
-- facility's forecast from the first hour given; drops hours over 2 days old.
CREATE FUNCTION fh_weather_load(p_facility integer, p_grid_url text, p_hours jsonb) RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE n integer;
BEGIN
  DELETE FROM facility_weather_hours
   WHERE facility_id = p_facility
     AND (hour_at >= (SELECT min((x->>'at')::timestamptz) FROM jsonb_array_elements(p_hours) x) OR hour_at < now() - interval '2 days');
  INSERT INTO facility_weather_hours
  SELECT p_facility, (x->>'at')::timestamptz, (x->>'temp_f')::numeric, (x->>'feels_f')::numeric, (x->>'wind_chill_f')::numeric,
         (x->>'wbgt_f')::numeric, round((x->>'humidity')::numeric), round((x->>'wind_mph')::numeric), round((x->>'gust_mph')::numeric),
         round((x->>'wind_deg')::numeric), round((x->>'sky_pct')::numeric), round((x->>'precip_pct')::numeric), round((x->>'thunder_pct')::numeric),
         (x->>'rain_in')::numeric, (x->>'snow_in')::numeric, (x->>'ice_in')::numeric, NULLIF(x->>'weather', '')
    FROM jsonb_array_elements(p_hours) x
  ON CONFLICT (facility_id, hour_at) DO NOTHING;
  GET DIAGNOSTICS n = ROW_COUNT;
  UPDATE facility_weather SET grid_url = p_grid_url, last_fetched_at = now(), last_ok_at = now(), last_fetch_note = NULL WHERE facility_id = p_facility;
  RETURN n;
END $$;

CREATE FUNCTION fh_weather_heat_level(p_category smallint, p_wbgt numeric) RETURNS text
LANGUAGE sql STABLE AS $$
  SELECT level FROM weather_heat_zones
   WHERE category = p_category AND p_wbgt IS NOT NULL
     AND (wbgt_from IS NULL OR p_wbgt >= wbgt_from) AND (wbgt_below IS NULL OR p_wbgt < wbgt_below)
$$;
CREATE FUNCTION fh_weather_cold_level(p_wct numeric) RETURNS text
LANGUAGE sql STABLE AS $$
  SELECT level FROM weather_cold_zones
   WHERE p_wct IS NOT NULL AND (wct_from IS NULL OR p_wct >= wct_from) AND (wct_below IS NULL OR p_wct < wct_below)
$$;

-- Every forecast hour with its two U.S. Soccer levels and the worse of them.
-- Cold is read off the wind chill, or the air temperature when none is given.
CREATE VIEW facility_weather_zoned AS
SELECT h.*, z.heat_level, z.cold_level,
       (SELECT l.code FROM weather_alert_levels l WHERE l.code IN (z.heat_level, z.cold_level) ORDER BY l.rank DESC LIMIT 1) AS level,
       CASE WHEN (SELECT rank FROM weather_alert_levels WHERE code = z.cold_level) > COALESCE((SELECT rank FROM weather_alert_levels WHERE code = z.heat_level), 0)
            THEN 'cold' ELSE 'heat' END AS level_for
  FROM facility_weather_hours h
  JOIN facility_weather fw ON fw.facility_id = h.facility_id
  CROSS JOIN LATERAL (SELECT fh_weather_heat_level(fw.heat_category, h.wbgt_f) AS heat_level,
                             fh_weather_cold_level(COALESCE(h.wind_chill_f, h.temp_f)) AS cold_level) z;

-- Top level, after Calendar; players get it too (viewer.js menuBarPages).
UPDATE menu_groups SET sort_order = sort_order + 1 WHERE sort_order >= 2;
INSERT INTO menu_groups (code, label, icon, sort_order) VALUES ('weather', 'Weather', '⛅', 2);
INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens, new_tab, download, is_active)
VALUES ('weather', 'weather', 'Weather', '⛅', 'everyone', 1, '{weather}', false, false, true);

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Weather', v.label, 'weather', v.tier, v.body, v.so, true, true
FROM (VALUES
  ('Weather — page title', 'title', 'Weather', 1),
  ('Weather — where the forecast comes from', 'source', 'Forecast: National Weather Service · read {when}', 2),
  ('Weather — nothing read yet', 'none', 'No forecast yet — check back in a minute.', 3),
  ('Weather — events heading', 'events', 'Our next events here', 4),
  ('Weather — no events in the forecast window', 'events_none', 'Nothing scheduled here in the next 7 days.', 5),
  ('Weather — the U.S. Soccer zone badge', 'badge', 'U.S. Soccer {level}', 6),
  ('Weather — badge hint, heat', 'badge_heat', 'Heat: {conditions} — {action}', 7),
  ('Weather — badge hint, cold', 'badge_cold', 'Cold: {conditions} — {action}', 8),
  ('Weather — zones heading', 'zones', 'U.S. Soccer alert levels', 9),
  ('Weather — heat table heading', 'zones_heat', 'Heat — Wet Bulb Globe Temperature, regional category {category}', 10),
  ('Weather — cold table heading', 'zones_cold', 'Cold — wind chill temperature', 11),
  ('Weather — lightning rule (U.S. Soccer Recognize to Recover)', 'lightning', '⚡ Lightning: all activity stops. Outdoor activity may resume 30 minutes after the last sound of thunder or flash of lightning; the 30-minute clock restarts every time lightning flashes or thunder sounds.', 12),
  ('Weather — link to U.S. Soccer''s guidance (label|url)', 'guide_link', 'U.S. Soccer: managing extreme weather conditions ↗|https://www.ussoccer.com/soccer-forward/resource-hub/managing-extreme-weather-conditions', 13),
  ('Weather — hourly table head', 'hours_head', 'Time|Sky|Temp|Feels|Rain|Thunder|Snow|Wind|Zone', 14),
  ('Weather — feels like, on an event chip', 'feels', 'feels {t}°', 15)
) AS v(label, tier, body, so);

COMMIT;
