-- 1490 (2026-11-18) — Luke and Anthony: early arrival before the FIRST session
-- of each practice day (owner: "they have to show up 15 minutes early in
-- winter and 30 minutes early for 1st practice in other 3 seasons" + "only
-- early for 1st event of day").  Mon/Wed/Fri = 3 practice days a week:
--   winter (Dec–Feb)              3 × ¼ h = ¾ h  × $15 = $11.25 a week
--   fall, spring, summer          3 × ½ h = 1½ h × $15 = $22.50 a week
-- The 2 holiday weeks off (budget lines 37/38) are taken in winter.
-- Also: U15 off their practice rules (mig 1489) — it pulled in the Tuesday
-- 9 PM u15+ session, a men's session (James); U11–U15 still matches via U11–U14.
BEGIN;
INSERT INTO budget_lines (club_id, club_section_id, category, label, amount_usd, amount_per, period_start, period_end,
                          spread, is_assumed, is_active, sort_order, budget_year_id, weeks_off, note)
SELECT 134, 3, 'labor', 'Coaching — early arrival, ' || c.who || ' (' || s.lbl || ')', s.amt, 'week', s.ps::date, s.pe::date,
       'even', false, true, c.ord, 1, s.off,
       s.why || ' — before the first session of each practice day, Mon/Wed/Fri (owner 2026-11-18)'
  FROM (VALUES ('Luke', 5), ('Anthony', 6)) AS c(who, ord)
 CROSS JOIN (VALUES
   ('fall',          22.50, '2026-08-01', '2026-11-30', 0, '3 × ½ h × $15'),
   ('winter',        11.25, '2026-12-01', '2027-02-28', 2, '3 × ¼ h × $15, 2 holiday weeks off'),
   ('spring–summer', 22.50, '2027-03-01', '2027-07-31', 0, '3 × ½ h × $15')
 ) AS s(lbl, amt, ps, pe, off, why)
 WHERE NOT EXISTS (SELECT 1 FROM budget_lines b WHERE b.label = 'Coaching — early arrival, ' || c.who || ' (' || s.lbl || ')' AND b.budget_year_id = 1);

DELETE FROM coach_pay_rules WHERE issuer_id IN (2, 4) AND event_kind = 'practice' AND team_id = 941;   -- U15
COMMIT;
