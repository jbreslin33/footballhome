-- 583 (2026-10-13) — Nicholson Pennant (person 22450) comes off the USASA
-- Amateur Cup squad.  Owner: "lets remove Nicholas Pennant from cup roster
-- … you can edit the slots and drop everyone down."
--
-- Three moves, all idempotent:
--   1. his cup_roster_players row (roster 2, slot 19) goes;
--   2. everyone below him drops down a slot so the sheet stays 1..N;
--   3. his open invite to the 2026-10-18 cup tie (materialized by mig 568)
--      is revoked — the roster row alone would have left the game on his
--      #my.  He never RSVPed, so nothing else to unwind.
--
-- Re-running mig 568 cannot re-invite him: it cross-joins the roster he is
-- no longer on.

WITH removed AS (
    DELETE FROM cup_roster_players
     WHERE cup_roster_id = 2 AND person_id = 22450
    RETURNING sort_order
)
UPDATE cup_roster_players crp
   SET sort_order = crp.sort_order - 1
  FROM removed r
 WHERE crp.cup_roster_id = 2
   AND crp.sort_order > r.sort_order;

UPDATE fh_event_invites
   SET revoked_at = now()
 WHERE person_id = 22450
   AND revoked_at IS NULL
   AND note LIKE 'USASA Amateur Cup squad%';
