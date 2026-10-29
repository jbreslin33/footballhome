-- 852 (2026-10-29) — #apsl-pyramid map: conference territories from
-- counties (population + distance), and Sunday drive times.
--
-- Owner 2026-10-29: "its really based on metro size where we put a
-- conference … like pretend your making the conferences from scratch based
-- off population and distance. actually add a stat and put population
-- inside border on hud. also put travel time on a sunday (no traffic)
-- between the 2 furthest clubs and the average travel time if all played
-- all."
--
-- pyramid_counties          every US county: name, state, 2023 population
--                           estimate, its centre and its shape (Census data,
--                           loaded by scripts/pyramid-counties-load.py — not
--                           in git).
-- pyramid_county_overrides  a hand-set conference for a county (or NULL =
--                           nobody's), beating the rule below.
-- pyramid_county_conference the rule: a county belongs to the conference of
--                           its NEAREST located club, if that club is within
--                           pyramid_territory_policy.reach_km of the county's
--                           centre (~an hour's drive) — so where conferences
--                           meet the border runs along county lines halfway
--                           between their clubs, and a county no club reaches
--                           is open ground where a new conference would form.
--                           Only the conferences' own (APSL) clubs count.
-- pyramid_conference_travel Sunday (free-flow, no traffic) drive times among
--                           a conference's APSL clubs: the furthest pair and
--                           the average over every pair (all play all) —
--                           OSRM's table service, cached per club set.

CREATE TABLE IF NOT EXISTS pyramid_counties (
    fips       char(5) PRIMARY KEY,
    name       text NOT NULL,
    state      char(2) NOT NULL,
    population integer NOT NULL DEFAULT 0,
    lat        numeric(10,7) NOT NULL,
    lon        numeric(10,7) NOT NULL,
    geometry   jsonb NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_pyramid_counties_state ON pyramid_counties(state);

CREATE TABLE IF NOT EXISTS pyramid_county_overrides (
    fips           char(5) PRIMARY KEY REFERENCES pyramid_counties(fips) ON DELETE CASCADE,
    competition_id integer REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    note           text
);

-- One row: the reach of a club (km) when claiming counties.
CREATE TABLE IF NOT EXISTS pyramid_territory_policy (
    id       boolean PRIMARY KEY DEFAULT true CHECK (id),
    reach_km numeric NOT NULL DEFAULT 100
);
INSERT INTO pyramid_territory_policy (id, reach_km) VALUES (true, 100) ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION fh_km(lat1 numeric, lon1 numeric, lat2 numeric, lon2 numeric) RETURNS double precision
LANGUAGE sql IMMUTABLE AS $$
  SELECT 6371.0 * 2 * asin(sqrt(
           power(sin(radians((lat2 - lat1)::double precision) / 2), 2)
         + cos(radians(lat1::double precision)) * cos(radians(lat2::double precision))
           * power(sin(radians((lon2 - lon1)::double precision) / 2), 2)))
$$;

-- Each located club with a team in an APSL conference table → that
-- conference.  Only the conferences' own clubs draw the borders (owner:
-- "base it off teams in other conferences"): a feeder club — North Jersey's
-- feed two conferences — never moves a border.
CREATE OR REPLACE VIEW pyramid_club_conference AS
SELECT DISTINCT ON (pc.id) pc.id AS club_id, d.competition_id AS conference_id, pc.lat, pc.lon
  FROM pyramid_clubs pc
  JOIN pyramid_teams t ON t.pyramid_club_id = pc.id AND t.removed_at IS NULL
  JOIN pyramid_divisions d ON d.id = t.division_id AND d.removed_at IS NULL
  JOIN pyramid_competitions c ON c.id = d.competition_id AND c.kind = 'conference' AND c.is_active
 WHERE pc.lat IS NOT NULL
 ORDER BY pc.id, c.sort_order;

-- Each county → its conference (override, else nearest club within reach).
CREATE OR REPLACE VIEW pyramid_county_conference AS
SELECT k.fips, k.population,
       CASE WHEN o.fips IS NOT NULL THEN o.competition_id ELSE n.conference_id END AS conference_id,
       n.km AS nearest_km
  FROM pyramid_counties k
  LEFT JOIN pyramid_county_overrides o ON o.fips = k.fips
  LEFT JOIN LATERAL (
        SELECT cc.conference_id, fh_km(k.lat, k.lon, cc.lat, cc.lon) AS km
          FROM pyramid_club_conference cc
         ORDER BY fh_km(k.lat, k.lon, cc.lat, cc.lon)
         LIMIT 1) n0 ON true
  LEFT JOIN LATERAL (
        SELECT n0.conference_id, n0.km
         WHERE n0.km <= (SELECT reach_km FROM pyramid_territory_policy)) n ON true;

CREATE TABLE IF NOT EXISTS pyramid_conference_travel (
    competition_id integer PRIMARY KEY REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    club_set       text NOT NULL,          -- sorted club ids the numbers are for
    max_minutes    numeric,
    from_club_id   integer REFERENCES pyramid_clubs(id) ON DELETE SET NULL,
    to_club_id     integer REFERENCES pyramid_clubs(id) ON DELETE SET NULL,
    avg_minutes    numeric,
    pairs          integer,
    computed_at    timestamptz NOT NULL DEFAULT now()
);

-- ── Copy ───────────────────────────────────────────────────────────────
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('map_pop',       'APSL pyramid — map HUD: population',   'Population inside the border: {pop}', 150),
    ('map_far',       'APSL pyramid — map HUD: furthest pair', 'Furthest apart: {a} ↔ {b} — {time} Sunday drive', 151),
    ('map_avg',       'APSL pyramid — map HUD: average drive', 'Average drive if all play all: {time} ({pairs} trips)', 152),
    ('map_counties',  'APSL pyramid — map HUD: counties',      '{counties} counties', 153),
    ('map_no_travel', 'APSL pyramid — map HUD: no drive times','Drive times unavailable right now', 154)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
