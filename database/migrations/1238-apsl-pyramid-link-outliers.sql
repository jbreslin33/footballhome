-- 1238 (2026-11-11) — #apsl-pyramid: a table that feeds two conferences
-- draws its minority link from the teams that are the outliers.
--
-- Owner 2026-11-11: "for central jersey and any like it have a connection
-- line coming from the teams that are outliers and then merge their line
-- to metro … always do this for the lower amount of teams that are the
-- outliers.  this is for non map displays."
--
-- Each located feeder team belongs to the conference of the NEAREST APSL
-- ground (the same rule as the territories, mig 852/855, and the feeder
-- votes, mig 864).  For a table linked into two or more conferences, the
-- conference most of its teams are nearest keeps the table-wide arrow; each
-- other linked conference is an OUTLIER link: its arrow starts at the rows
-- of the teams nearest it and merges into one line (flow chart +
-- presentation; pyramid-flow-view.js).  A tie, or a linked conference no
-- team in the table is nearest, keeps the table-wide arrow.
--
-- First run: CASA Select Central Jersey Liga 1 — 8 teams nearest Delaware
-- River, 2 nearest Metropolitan (Portuguese Sporting Club FC, Five Rivers SC).

CREATE OR REPLACE VIEW pyramid_team_nearest_conference AS
SELECT t.id AS team_id, t.division_id, n.conference_id, n.km
  FROM pyramid_teams t
  JOIN pyramid_divisions d ON d.id = t.division_id AND d.removed_at IS NULL
  JOIN pyramid_competitions fc ON fc.id = d.competition_id AND fc.kind = 'affiliate'
  JOIN pyramid_venues v ON v.id = t.venue_id AND v.lat IS NOT NULL
  CROSS JOIN LATERAL (
        SELECT tc.conference_id, fh_km(v.lat, v.lon, tc.lat, tc.lon) AS km
          FROM pyramid_team_conference tc
         ORDER BY fh_km(v.lat, v.lon, tc.lat, tc.lon)
         LIMIT 1) n
 WHERE t.removed_at IS NULL;

COMMENT ON VIEW pyramid_team_nearest_conference IS
    'mig 1238: each located feeder team → the conference of the nearest APSL ground (km).';

CREATE OR REPLACE VIEW pyramid_link_outliers AS
WITH cl AS (            -- table → conference links, live tables only
    SELECT l.id AS link_id, d.id AS division_id, l.upper_competition_id AS conference_id
      FROM pyramid_links l
      JOIN pyramid_divisions d ON d.source_id = l.lower_source_id AND d.name = l.lower_division AND d.removed_at IS NULL
     WHERE l.upper_competition_id IS NOT NULL
), multi AS (
    SELECT division_id FROM cl GROUP BY division_id HAVING count(DISTINCT conference_id) > 1
), votes AS (
    SELECT cl.link_id, cl.division_id, cl.conference_id,
           array_agg(n.team_id ORDER BY n.team_id) FILTER (WHERE n.team_id IS NOT NULL) AS team_ids,
           count(n.team_id) AS teams
      FROM cl
      JOIN multi USING (division_id)
      LEFT JOIN pyramid_team_nearest_conference n
             ON n.division_id = cl.division_id AND n.conference_id = cl.conference_id
     GROUP BY cl.link_id, cl.division_id, cl.conference_id
)
SELECT v.link_id, v.division_id, v.conference_id, v.team_ids
  FROM votes v
 WHERE v.teams > 0
   AND v.teams < (SELECT max(w.teams) FROM votes w WHERE w.division_id = v.division_id);

COMMENT ON VIEW pyramid_link_outliers IS
    'mig 1238: a conference link of a multi-conference table that fewer of its teams are nearest — drawn from those teams'' rows (team_ids), not the table.';

-- The switch in ☰ Show on screen (chart + presentation views; on by default).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — menu: outlier team lines', 'apsl_pyramid', 'feature_outliers', NULL,
       'Lines from outlier teams (a table that feeds two conferences)', 198, true, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = 'feature_outliers');
