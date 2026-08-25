-- 311 — Give the four coach-less boys teams a coaching staff.
--
-- Why (2026-08-25, owner: "i am not seeing for boys u10 intramural, u12
-- intramural, u16 intramural … its alos missing u6 intramural").
--
-- Not a rendering bug. The Teams board picks its card class from
-- navigation.context.role, so entering through the coach path makes every
-- card a CoachTeamCard, whose move dropdown offers only teams in
-- coachedTeamIds (roster-screen-base.js `_coachedTeamIds`, filtered in
-- TeamCard.js `renderMoveControl`). A team with no team_coaches row can
-- therefore never appear as a move target for a coach — and cannot be
-- managed by one at all.
--
-- U8 / U10 / U12 Intramural were created by migration 306 and U16
-- Intramural was renamed from a team that never had coaches, so all four
-- have zero rows while the other five boys teams carry three to five
-- each. That is exactly the set missing from the dropdown.
--
-- Staff copied from the five existing boys teams rather than invented:
-- coaches 1 (James Breslin), 40 (Anthony Acevedo) and 41 (Luke Breslin)
-- are on every one of them, so extending them to the new teams restores
-- the board to a consistent state rather than granting anyone rights they
-- did not already hold across the whole boys programme.
--
-- Deliberately NOT copied: coach 43 (Marcelo Osorio-Soto), on four of the
-- five, and 42 (Walter Juarez de Leon), on two. Their pattern looks like a
-- per-team choice rather than programme-wide cover, so it is the owner's
-- call, not an inference from data.
--
-- coach_role_id left NULL, matching how every existing boys row except
-- the three head-coach designations (912/913/914, role 2) is stored.
INSERT INTO team_coaches (team_id, coach_id)
SELECT t.id, v.coach_id
  FROM teams t
  CROSS JOIN (VALUES (1), (40), (41)) AS v(coach_id)
 WHERE t.gender_category = 'boys'
   AND t.is_active
   AND t.name IN ('U8 Intramural', 'U10 Intramural', 'U12 Intramural', 'U16 Intramural')
   AND NOT EXISTS (
         SELECT 1 FROM team_coaches tc
          WHERE tc.team_id = t.id AND tc.coach_id = v.coach_id AND tc.ended_at IS NULL
       );

-- Guard: every active boys team must now have a coach, or the dropdown
-- gap this migration exists to close is still open somewhere.
DO $$
DECLARE bad TEXT;
BEGIN
    SELECT string_agg(t.name, ', ') INTO bad
      FROM teams t
     WHERE t.gender_category = 'boys' AND t.is_active
       AND NOT EXISTS (SELECT 1 FROM team_coaches tc
                        WHERE tc.team_id = t.id AND tc.ended_at IS NULL);
    IF bad IS NOT NULL THEN
        RAISE EXCEPTION 'boys teams still without a coach: %', bad;
    END IF;
END $$;
