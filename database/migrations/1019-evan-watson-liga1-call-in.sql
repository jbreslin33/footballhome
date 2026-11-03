-- 1019: Evan Watson (person 22589) is a ↔ Call-in on Liga 1 (owner
-- 2026-11-03: "evan watson for liga 1 needs a cat that he can be called
-- in … he does not need to see liga 1 rsvp stuff unless we call him in").
-- invite_only + call_in on his Liga 1 row: no Liga 1 game grants, only an
-- invite (CALL UP in Game Center) shows him a game.  APSL (35) unchanged —
-- he's ACTIVE there and asked every APSL game.

UPDATE team_persons SET invite_only = true, call_in = true
 WHERE team_id = 120 AND person_id = 22589 AND removed_at IS NULL;
