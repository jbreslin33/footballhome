-- 1532 (2026-11-19) — Evan Watson: 🪑 Reserves on Liga 1 (owner: "make him
-- reserve" "on liga 1").  APSL is his main team; he stays ✅ Regular on
-- APSL / APSL Reserves (so still chased for practices, tagged to both).
-- Sees Liga 1 games, never chased for them; On Roster for CASA, so not a
-- call-down.
UPDATE team_persons
   SET squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'standby')
 WHERE team_id = 120 AND person_id = 22589 AND removed_at IS NULL;
