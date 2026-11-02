-- 909 (2026-10-30) — person 22765 joins APSL Reserves (team 938).
--
-- Owner: "add fathy to apsl adds. and update the message to aaron", Reserves.
-- A live 938 row with no status is what fh_league_moves() reads as needs_add,
-- so the add lands on #apsl's roster moves email by itself.  He is on the Liga 1
-- list, which Reserves requires.

INSERT INTO team_persons (team_id, person_id)
SELECT 938, 22765
 WHERE NOT EXISTS (SELECT 1 FROM team_persons WHERE team_id = 938 AND person_id = 22765 AND removed_at IS NULL);
