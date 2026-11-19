-- 1533 (2026-11-19) — Mars Milligan: ✅ Regular on APSL (owner: "mars is
-- regular apsl but should be flagged not on roser").  Mig 1530 had moved
-- her APSL row (Practice Squad) into Reserves.  Not On Roster for APSL yet
-- (Needs Docs), so the ⛔ flag shows on her box until the TeamPass sync
-- has her (fh_team_game_eligible).
UPDATE team_persons
   SET squad_status_id = NULL, invite_only = false
 WHERE team_id = 35 AND person_id = 22445 AND removed_at IS NULL;
