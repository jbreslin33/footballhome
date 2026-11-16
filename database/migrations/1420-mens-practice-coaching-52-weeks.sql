-- 1420 (2026-11-16): Men's practice coaching = 5 a week × 1½ h, all 52 weeks.
--
-- Owner: "for games i guess you can put coach at the 'team' games but practice
-- is shared with all mens teams. its the same coach same practice. 5 days a
-- week 52 weeks lol. 1.5 hours per."
--
-- Game coaching stays per team (ref_fee_policies kind coaching — unchanged).
-- The one shared "Coaching — practices" line under Men's general (both budget
-- years): 5 × 1½ h = 7½ h × $20 = $150 a week (was 8¼ h = $165), no weeks off
-- (was 2) → 52 weeks = $7,800 a year (was $8,250).

BEGIN;

UPDATE budget_lines b
   SET amount_usd = 150.00, weeks_off = 0, is_assumed = false,
       note = 'James: same coach, same practice for every men''s team — 5 practices a week × 1½ h = 7½ h × $20, all 52 weeks (owner 2026-11-16)'
  FROM club_sections s
 WHERE s.id = b.club_section_id AND s.code = 'M'
   AND b.label = 'Coaching — practices' AND b.amount_per = 'week';

INSERT INTO schema_migrations (filename) VALUES ('1420-mens-practice-coaching-52-weeks.sql') ON CONFLICT DO NOTHING;
COMMIT;
