-- 1598 (2026-11-20) — Women get 🪑 Reserves the same as men.
--
-- Owner: "why are there 4 inactive women lol" → "women have no liga 1.
-- they are tri county. all of them. all active" → "all regulars" →
-- "women have no reserves yet but keep it there same as men etc".
--
-- The women's #teams board now offers the men's Team-pill choices
-- (✅ Regular / 🪑 Reserves / injuries — WomensRosterScreen._hasReserves),
-- so the standby status needs the women's section rule men have
-- (mig 1530): sees every game, owes no practice RSVPs.  Nobody is moved —
-- all 18 Tri County women stay Regulars; never answering an RSVP doesn't
-- park a woman anywhere (WomensRosterScreen._neverAnsweredParks = false).

BEGIN;

INSERT INTO squad_status_section_rules (club_section_id, squad_status_id, owes_practice_rsvps, sees_games)
SELECT cs.id, ss.id, false, true FROM club_sections cs, squad_statuses ss
 WHERE cs.code = 'W' AND ss.code = 'standby'
ON CONFLICT (club_section_id, squad_status_id) DO UPDATE SET owes_practice_rsvps = false, sees_games = true;

COMMIT;
