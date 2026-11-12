-- 1302 (2026-11-12) — #apsl-pyramid: club assignments read the OFFICIAL
-- centre model's saved points, never the live pipeline tables.
--
-- Mig 1298 added centre-model pills; scripts/pyramid-pipeline.sh computes
-- City centre / Metro average through the live pyramid_region_points, so
-- while one ran, pyramid_team_nearest_conference (and the flow chart's
-- outlier lines, pyramid_link_outliers, built on it) followed that model.
-- Now it reads pyramid_model_region_points for the official model (Most
-- people, mig 1297) — the pills stay a map comparison only.

CREATE OR REPLACE VIEW pyramid_team_nearest_conference AS
 SELECT t.id AS team_id,
    t.division_id,
    n.conference_id,
    n.km,
    n.minutes
   FROM pyramid_teams t
     JOIN pyramid_divisions d ON d.id = t.division_id AND d.removed_at IS NULL
     JOIN pyramid_competitions fc ON fc.id = d.competition_id AND fc.kind = 'affiliate'::text
     JOIN pyramid_venues v ON v.id = t.venue_id AND v.lat IS NOT NULL
     CROSS JOIN LATERAL ( SELECT p.conference_id,
            min(fh_km(v.lat, v.lon, p.lat, p.lon)) AS km,
            sum(p.weight::double precision * COALESCE(dt.minutes::double precision, fh_km(v.lat, v.lon, p.lat, p.lon) * 1.1::double precision)) / sum(p.weight)::double precision AS minutes,
            sum(p.weight::double precision * COALESCE(dt.minutes::double precision, fh_km(v.lat, v.lon, p.lat, p.lon) * 1.1::double precision) * p.factor::double precision) / sum(p.weight)::double precision AS score
           FROM pyramid_model_region_points p
             LEFT JOIN pyramid_venue_drive_times dt ON dt.venue_id = v.id AND dt.from_lat = round(v.lat::numeric, 4) AND dt.from_lon = round(v.lon::numeric, 4) AND dt.to_lat = round(p.lat::numeric, 4) AND dt.to_lon = round(p.lon::numeric, 4)
          WHERE p.plan = 'current'::text AND p.model = (SELECT code FROM pyramid_centre_models WHERE is_official)
          GROUP BY p.conference_id
          ORDER BY (sum(p.weight::double precision * COALESCE(dt.minutes::double precision, fh_km(v.lat, v.lon, p.lat, p.lon) * 1.1::double precision) * p.factor::double precision) / sum(p.weight)::double precision)
         LIMIT 1) n
  WHERE t.removed_at IS NULL;
COMMENT ON VIEW pyramid_team_nearest_conference IS
    'mig 1302: each feeder club''s conference by weighted drive from its ground over the OFFICIAL centre model''s saved points (pyramid_model_region_points).';
