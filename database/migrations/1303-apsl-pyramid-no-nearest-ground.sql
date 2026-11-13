-- 1303 (2026-11-12) — #apsl-pyramid: the last two "nearest APSL club
-- ground" rules go; both now follow the official centre model's drive-time
-- map, like every other border on the page.
--
-- Owner 2026-11-11 (Feelsgood pulling Bulldogs into Delaware River): "never
-- use the feels good measure again".  Two views still did:
--
--   pyramid_county_conference (mig 852) — a county → the conference of the
--     NEAREST APSL team ground within reach_km.  It tints the picked
--     conference's counties on the map and sums its population
--     (GET /api/pyramid/territory).  Now: a county override, else the
--     county's conference on the OFFICIAL model's Current plan
--     (pyramid_model_counties, written by fh_pyramid_model_snapshot) — the
--     same drive-time map the borders are drawn from.  nearest_km = that
--     snapshot's km.
--
--   pyramid_feeder_conference_votes (mig 864) — each feeder team voted for
--     its nearest APSL ground's conference.  Now each team votes for
--     pyramid_team_nearest_conference (mig 1302: weighted drive from its
--     ground to the official model's centre points).  Columns unchanged.
--     Nothing reads it at runtime; it is the record a hand fix checks.
--     Re-run 11/12: every feeder's parent holds (CASA Select regions stay
--     owner-named); Cosmo and LISFL lose their stray Constitution votes
--     (were 3 and 2); Central Jersey Delaware River 13 / Metropolitan 6
--     (was 15 / 4) — its Metropolitan link already exists.  So no parent or
--     link changes here.
--
-- pyramid_team_conference is untouched: that is an APSL team's own
-- conference (membership), not a nearest-ground guess.

CREATE OR REPLACE VIEW pyramid_county_conference AS
SELECT k.fips, k.population,
       CASE WHEN o.fips IS NOT NULL THEN o.competition_id ELSE mc.conference_id END AS conference_id,
       mc.km AS nearest_km
  FROM pyramid_counties k
  LEFT JOIN pyramid_county_overrides o ON o.fips = k.fips
  LEFT JOIN pyramid_model_counties mc
         ON mc.fips = k.fips AND mc.plan = 'current'
        AND mc.model = (SELECT code FROM pyramid_centre_models WHERE is_official);
COMMENT ON VIEW pyramid_county_conference IS
    'mig 1303: county → conference = override, else the OFFICIAL centre model''s Current-plan snapshot (drive time from the conference centre). Never nearest club ground.';

CREATE OR REPLACE VIEW pyramid_feeder_conference_votes AS
WITH ft AS (
    SELECT fc.id AS competition_id, t.id AS team_id, v.lat
      FROM pyramid_competitions fc
      JOIN pyramid_divisions d ON d.competition_id = fc.id AND d.removed_at IS NULL
      JOIN pyramid_teams t ON t.division_id = d.id AND t.removed_at IS NULL
      LEFT JOIN pyramid_venues v ON v.id = t.venue_id AND v.lat IS NOT NULL
     WHERE fc.kind = 'affiliate'),
totals AS (
    SELECT competition_id, count(*) AS total, count(lat) AS located FROM ft GROUP BY 1)
SELECT ft.competition_id, n.conference_id, count(*) AS teams,
       round(count(*)::numeric / tt.located, 3) AS share,
       tt.located, tt.total, tt.located * 2 >= tt.total AS votes
  FROM ft
  JOIN totals tt ON tt.competition_id = ft.competition_id
  JOIN pyramid_team_nearest_conference n ON n.team_id = ft.team_id
 GROUP BY ft.competition_id, n.conference_id, tt.located, tt.total;
COMMENT ON VIEW pyramid_feeder_conference_votes IS
    'mig 1303: each located feeder team votes for its conference by drive time to the official centre model (pyramid_team_nearest_conference). Never nearest club ground.';
