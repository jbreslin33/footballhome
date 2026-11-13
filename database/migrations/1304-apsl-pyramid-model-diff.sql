-- 1304 (2026-11-12) — #apsl-pyramid map ☰: where the centre models
-- disagree.
--
-- Mig 1298 gave three ways to measure a conference (City centre · Metro
-- average · Most people, official).  The ghost lines show the borders
-- moving; this says WHO moves: the counties (and people) that change
-- conference between models on each plan, and every feeder club whose
-- conference depends on the model — with how close the call is.
--
-- pyramid_model_team_scores  per feeder team (located ground) × computed
--   model × Current-plan conference: the weighted drive from the team's
--   ground to that model's saved points (pyramid_model_region_points) —
--   minutes, and score = minutes × traffic factor, the number that decides
--   (same formula as pyramid_team_nearest_conference, mig 1302, which is
--   this view's official-model winner).  rank 1 = its conference.
--   Drive minutes from pyramid_venue_drive_times, else km × 1.1.
--
-- GET /api/pyramid/model-diff reads it (lazy, ☰ only; ~1-2 s).  First run
-- 11/12: 6 of 257 feeder teams change — all central/shore New Jersey
-- (Bulldogs SC, Empire United, Jersey Shore Hounds, South River FC: Metro
-- on City + Average, Delaware River on Most people, Bulldogs by 0.3 min;
-- MFC United, Monmouth Light: Metro only on Average).  Counties: Current
-- 30 (3.1 M people), Proposed 206 (17.5 M).

CREATE OR REPLACE VIEW pyramid_model_team_scores AS
SELECT t.id AS team_id, t.pyramid_club_id AS club_id, t.name AS team, fc.id AS feeder_id,
       v.lat, v.lon, m.code AS model, s.conference_id, s.minutes, s.score,
       rank() OVER (PARTITION BY t.id, m.code ORDER BY s.score) AS rank
  FROM pyramid_teams t
  JOIN pyramid_divisions d ON d.id = t.division_id AND d.removed_at IS NULL
  JOIN pyramid_competitions fc ON fc.id = d.competition_id AND fc.kind = 'affiliate'
  JOIN pyramid_venues v ON v.id = t.venue_id AND v.lat IS NOT NULL
  CROSS JOIN pyramid_centre_models m
  CROSS JOIN LATERAL (
        SELECT p.conference_id,
               sum(p.weight::double precision * COALESCE(dt.minutes::double precision, fh_km(v.lat, v.lon, p.lat, p.lon) * 1.1))
                 / sum(p.weight)::double precision AS minutes,
               sum(p.weight::double precision * COALESCE(dt.minutes::double precision, fh_km(v.lat, v.lon, p.lat, p.lon) * 1.1) * p.factor::double precision)
                 / sum(p.weight)::double precision AS score
          FROM pyramid_model_region_points p
          LEFT JOIN pyramid_venue_drive_times dt
                 ON dt.venue_id = v.id AND dt.from_lat = round(v.lat::numeric, 4) AND dt.from_lon = round(v.lon::numeric, 4)
                AND dt.to_lat = round(p.lat::numeric, 4) AND dt.to_lon = round(p.lon::numeric, 4)
         WHERE p.plan = 'current' AND p.model = m.code
         GROUP BY p.conference_id) s
 WHERE t.removed_at IS NULL AND m.computed_at IS NOT NULL;
COMMENT ON VIEW pyramid_model_team_scores IS
    'mig 1304: each feeder team''s weighted drive score to every Current conference under every computed centre model; rank 1 = its conference on that model.';

-- Counties whose region differs between computed models, per plan.
CREATE OR REPLACE VIEW pyramid_model_county_diff AS
SELECT mc.plan, mc.fips, k.population
  FROM pyramid_model_counties mc
  JOIN pyramid_counties k ON k.fips = mc.fips
  JOIN pyramid_centre_models m ON m.code = mc.model AND m.computed_at IS NOT NULL
 GROUP BY mc.plan, mc.fips, k.population
HAVING count(DISTINCT COALESCE('c' || mc.conference_id, 'p' || mc.proposed_id, '-')) > 1
    OR count(*) < (SELECT count(*) FROM pyramid_centre_models WHERE computed_at IS NOT NULL);
COMMENT ON VIEW pyramid_model_county_diff IS
    'mig 1304: counties that change region (or drop out) between computed centre models, per plan.';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.t, NULL, v.body, v.s, true, true, true
  FROM (VALUES
    ('model_diff_heading', 'APSL pyramid — menu: where the models disagree (heading)', 'Where the models disagree', 208),
    ('model_diff_counties', 'APSL pyramid — menu: counties that change between models', '{counties} counties ({people} people) change conference between models on this plan.', 209),
    ('model_diff_clubs', 'APSL pyramid — menu: clubs that change between models', '{clubs} of {total} feeder clubs land in a different conference depending on the model:', 210),
    ('model_diff_none', 'APSL pyramid — menu: no club changes between models', 'Every feeder club lands in the same conference whichever model is used.', 211),
    ('model_diff_margin', 'APSL pyramid — menu: how close a club''s call is', 'On {model}: {won} by {margin} min', 212),
    ('model_diff_loading', 'APSL pyramid — menu: model comparison loading', 'Comparing the models…', 213)
  ) AS v(t, label, body, s)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
