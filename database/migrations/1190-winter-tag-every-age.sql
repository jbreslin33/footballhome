-- 1190 (2026-11-09): winter calendar tags can name every age (owner: "for
-- 430 we just put u5,u6,u7 and for 530 u8 … u16").  Each "uN winter" tag
-- maps to the board's age team (mig 1189): u5–u7 → ❄️ U7, u8–u10 → ❄️ U10,
-- u11–u12 → ❄️ U12, u13–u19 → ❄️ U13+.  Travel is NOT a separate team:
-- On Roster on the age team = travel (sees games); Practice Squad = practices.

BEGIN;

WITH want(alias, team_id) AS (VALUES
  ('u5 winter',  (SELECT id FROM teams WHERE label = '❄️ U7' AND is_active)),
  ('u6 winter',  (SELECT id FROM teams WHERE label = '❄️ U7' AND is_active)),
  ('u7 winter',  (SELECT id FROM teams WHERE label = '❄️ U7' AND is_active)),
  ('u8 winter', 942), ('u9 winter', 942), ('u10 winter', 942),
  ('u11 winter', 940), ('u12 winter', 940),
  ('u13 winter', 947), ('u13+ winter', 947), ('u14 winter', 947), ('u15 winter', 947),
  ('u16 winter', 947), ('u17 winter', 947), ('u18 winter', 947), ('u19 winter', 947))
, upd AS (
  UPDATE gcal_team_aliases g SET team_id = w.team_id, notes = COALESCE(g.notes, '') || ' · mig 1190'
    FROM want w WHERE g.club_alias = 'boys' AND g.team_alias = w.alias AND g.team_id <> w.team_id
  RETURNING g.team_alias)
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'boys', w.alias, w.team_id, 'mig 1190' FROM want w
 WHERE NOT EXISTS (SELECT 1 FROM gcal_team_aliases g WHERE g.club_alias = 'boys' AND g.team_alias = w.alias);

COMMIT;
