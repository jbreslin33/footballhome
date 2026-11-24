-- 1778 (2026-11-23): #dual-rostering by league, then by its conferences.
-- Owner: "lets show it by delaware river conferences and by apsl feeder
-- league conferences" → "so apsl pill then apsl confs. casa pill then casa
-- confs. cosmo pill then its divisions or all just like all for all pills".
--
-- Every roster row now carries league_group (the first pill row: APSL, CASA,
-- Cosmo, ADASL, UPSL) and league_sub (the second: an APSL conference, a CASA
-- league, a Cosmo division).  Pyramid teams get them from the pyramid; sheet
-- and paste sources carry them by hand (roster_sheet_sources).

BEGIN;

ALTER TABLE roster_sheet_sources ADD COLUMN IF NOT EXISTS league_group text;
ALTER TABLE roster_sheet_sources ADD COLUMN IF NOT EXISTS league_sub text;

UPDATE roster_sheet_sources s SET league_group = v.grp, league_sub = v.sub
  FROM (VALUES ('CASA Select Philadelphia · Liga 1', 'CASA', 'Select Philadelphia · Liga 1'),
               ('CASA Select Philadelphia · Liga 2', 'CASA', 'Select Philadelphia · Liga 2'),
               ('CASA Select Lancaster · Liga 1',    'CASA', 'Select Lancaster · Liga 1'),
               ('CASA Philadelphia 11v11',           'CASA', 'Philadelphia 11v11'),
               ('CASA Boston 11v11',                 'CASA', 'Boston 11v11'),
               ('UPSL Premier',                      'UPSL', 'Premier')) v(label, grp, sub)
 WHERE s.league_label = v.label;
UPDATE roster_sheet_sources SET league_group = league_label WHERE league_group IS NULL;
UPDATE roster_sheet_sources SET league_sub = league_label WHERE league_sub IS NULL;
ALTER TABLE roster_sheet_sources ALTER COLUMN league_group SET NOT NULL;
ALTER TABLE roster_sheet_sources ALTER COLUMN league_sub SET NOT NULL;

DROP VIEW IF EXISTS roster_watch_entries;
CREATE VIEW roster_watch_entries AS
SELECT 'p' || t.id AS team_ref,
       CASE WHEN cm.kind = 'conference' THEN 'APSL · ' || cm.name ELSE coalesce(cm.short_name, cm.name) END AS league,
       t.name AS team, d.name AS division,
       coalesce('f' || pc.club_id, 'c' || pc.id) AS club_key, pc.name AS club,
       p.name AS full_name, fh_name_key(p.name) AS name_key,
       NULL::date AS dob, p.added_on, t.people_fetched_at AS read_at,
       -- A conference sits under the league (APSL); a cup hangs straight off it.
       CASE WHEN cm.kind = 'conference' THEN coalesce(root.short_name, root.name) ELSE coalesce(cm.short_name, cm.name) END AS league_group,
       CASE WHEN cm.kind = 'conference' THEN coalesce(cm.short_name, cm.name) ELSE d.name END AS league_sub,
       CASE WHEN cm.kind = 'affiliate' THEN 10 + cm.id ELSE 0 END AS group_order,
       CASE WHEN cm.kind = 'conference' THEN cm.sort_order WHEN cm.kind = 'league' THEN 1000 + d.sort_order ELSE d.sort_order END AS sub_order
  FROM pyramid_team_people p
  JOIN pyramid_teams t ON t.id = p.team_id AND t.removed_at IS NULL
  JOIN pyramid_divisions d ON d.id = t.division_id AND d.removed_at IS NULL
  JOIN pyramid_competitions cm ON cm.id = d.competition_id
  LEFT JOIN pyramid_competitions root ON root.id = cm.parent_id
  JOIN pyramid_clubs pc ON pc.id = t.pyramid_club_id
 WHERE p.kind = 'player'
UNION ALL
SELECT 's' || st.id, s.league_label, st.name, st.division,
       coalesce('f' || pc.club_id, 'c' || pc.id, 'n' || fh_pyramid_name_key(st.name)), coalesce(pc.name, st.name),
       sp.full_name, fh_name_key(sp.full_name), sp.dob, sp.added_on, s.last_fetched_at,
       s.league_group, s.league_sub,
       1000 + (SELECT min(x.sort_order) FROM roster_sheet_sources x WHERE x.league_group = s.league_group), s.sort_order
  FROM roster_sheet_players sp
  JOIN roster_sheet_teams st ON st.id = sp.team_id
  JOIN roster_sheet_sources s ON s.id = st.source_id AND s.is_active
  LEFT JOIN pyramid_clubs pc ON pc.id = st.pyramid_club_id;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Dual rostering', l, 'roster_watch', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('league_all', 'League pill: every league',                    'All leagues', 50),
    ('sub_all',    'Conference pill: all of the league ({league})', 'All {league}', 51)
  ) v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_watch' AND m.tier = v.t);

INSERT INTO schema_migrations (filename) VALUES ('1778-dual-rostering-by-conference.sql') ON CONFLICT DO NOTHING;

COMMIT;
