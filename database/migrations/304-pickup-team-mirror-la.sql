-- 304 — Make team 909 "Pickup" mean what its name says.
--
-- Why (2026-08-25, owner: "nobody should be in both", then "yes fix it").
-- Team 909 held 82 open rows against 44 real pickup registrations, with
-- only 26 in common. Two writers fill it and neither ever drains it:
--
--   * LaPool 3c INSERTs a row for every current LA pickup member
--     (program 5070075) — additive, ON CONFLICT DO NOTHING, and no
--     matching close when a membership ends. So people who stopped
--     paying for pickup stayed on it.
--   * MensRosterController auto-adds Practice AND Pickup rows on every
--     APSL / Liga 1 assignment (2026-07-04, extended 07-07). So squad
--     players who never registered for pickup were written onto it —
--     56 of the 82.
--
-- The result is that the one FH object named "Pickup" was the least
-- reliable answer to "is this person a pickup member". This closes the
-- rows with no backing registration, leaving 909 a faithful mirror of
-- the LA pickup program, which is what LaPool already treats it as.
--
-- Safe to run now: no future calendar event tags team 908 or 909, so no
-- upcoming RSVP invitation changes. The accompanying code change stops
-- the squad-assignment writer and gives LaPool the closing sweep it was
-- missing, so 909 stays converged instead of drifting again.
--
-- Rows are closed, not deleted, with a distinct reason so this pass can
-- be identified later. Practice (908) is deliberately untouched: it has
-- no LA program behind it, so there is no truth to reconcile it against
-- — it is a genuine internal group a coach curates by hand.
UPDATE team_persons tp
   SET removed_at     = NOW(),
       removed_reason = 'pickup_team_no_la_registration'
 WHERE tp.team_id = 909
   AND tp.removed_at IS NULL
   AND NOT EXISTS (
         SELECT 1
           FROM person_la_memberships plm
           JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id
          WHERE plm.person_id = tp.person_id
            AND plm.ended_at IS NULL
            AND lp.variant = 'pickup'
       );
