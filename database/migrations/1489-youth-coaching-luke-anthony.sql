-- 1489 (2026-11-18) — Luke and Anthony's coaching for 2026-27 (owner: "yes they
-- are at every one … use winter schedule as THE schedule for year for
-- practice. for games split them anthony with u10 and luke with u12. lets do
-- 10 games fall, 8 winter, 10 spring. u10 at 1.5 hours each and u12 at 2").
--
-- Practice = this winter's calendar, all year, BOTH coaches at every session:
-- Mon / Wed / Fri  U5–U8 ¾ h + U9–U10 1 h + U11–U15 1¼ h = 3 h a day × 3 =
-- 9 h a week × $15 = $135 a week each (2 holiday weeks off, as before).
-- No 4th December practice (winter has three practice days).
-- Games: U10 → Anthony, 1.5 h; U12 → Luke, 2 h; 10 fall + 8 winter (indoor)
-- + 10 spring each.  U8 game coaching off.
BEGIN;
UPDATE budget_lines SET label = 'Coaching — youth practices, Luke',
       note = 'Winter schedule all year: Mon/Wed/Fri U5–U8 ¾ h + U9–U10 1 h + U11–U15 1¼ h = 9 h × $15, both coaches at every session, 2 holiday weeks off (owner 2026-11-18)'
 WHERE id = 37;
UPDATE budget_lines SET label = 'Coaching — youth practices, Anthony',
       note = 'Winter schedule all year: Mon/Wed/Fri U5–U8 ¾ h + U9–U10 1 h + U11–U15 1¼ h = 9 h × $15, both coaches at every session, 2 holiday weeks off (owner 2026-11-18)'
 WHERE id = 38;
UPDATE budget_lines SET is_active = false,
       note = COALESCE(note, '') || ' — off: the winter schedule (3 days) is the year''s schedule (owner 2026-11-18)'
 WHERE id = 39;

UPDATE ref_fee_policies SET is_active = false WHERE id = 10 AND kind = 'coaching';              -- U8 games
UPDATE ref_fee_policies SET coach_issuer_id = 4 WHERE id = 11 AND kind = 'coaching';            -- U10 → Anthony
UPDATE ref_fee_policies SET coach_issuer_id = 2 WHERE id = 12 AND kind = 'coaching';            -- U12 → Luke
UPDATE ref_fee_seasons SET home_games_expected = 8  WHERE id IN (49, 52);                      -- indoor (winter)
UPDATE ref_fee_seasons SET home_games_expected = 10 WHERE id IN (50, 53);                      -- spring

-- paid for this winter's per-age youth practices (the calendar's teams)
INSERT INTO coach_pay_rules (issuer_id, event_kind, team_id)
SELECT i, 'practice', t
  FROM (VALUES (2), (4)) AS c(i)
 CROSS JOIN (VALUES (954), (952), (949), (953), (945), (942), (946), (940), (947), (955), (941)) AS tm(t)
ON CONFLICT DO NOTHING;
COMMIT;
