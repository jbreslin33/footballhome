-- 1260 (2026-11-11) — #apsl-pyramid flow chart: a table that feeds two
-- conferences draws BOTH links from its teams' rows.
--
-- Owner 2026-11-11: "use same approach for both confs. just have the arrows
-- come out right side for metro and left side for del".  pyramid_link_outliers
-- (mig 1238) listed only the minority link's teams; it now lists every
-- conference link of such a table with the teams that belong to that
-- conference (city-centre rule, mig 1255) and whether it is the majority —
-- the majority still decides which column the table sits under.  The chart
-- branches each conference's rows out of the table side facing it and merges
-- them into one line.

DROP VIEW IF EXISTS pyramid_link_outliers;
CREATE VIEW pyramid_link_outliers AS
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
SELECT v.link_id, v.division_id, v.conference_id, v.team_ids,
       v.teams = (SELECT max(w.teams) FROM votes w WHERE w.division_id = v.division_id) AS majority
  FROM votes v
 WHERE v.teams > 0;

COMMENT ON VIEW pyramid_link_outliers IS
    'mig 1260: every conference link of a multi-conference table with the teams that belong to that conference (team_ids) and whether they are the majority — the chart draws each from those rows.';
