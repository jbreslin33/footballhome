-- 1549 (2026-11-19) — the volunteer's checklist checks itself off on upload
-- (owner 11/19 "why do they have check boxes? should fh check it off when
-- uploaded?"): no ⬜ box on a step still to do; uploaded = ✅ Uploaded and
-- counts in their progress; the club's check reads ✅ Checked by the club.
-- #onboarding keeps 🟡 for uploaded-but-not-checked (the admin's queue).
UPDATE message_templates SET body = v.body, updated_at = now()
  FROM (VALUES ('state_todo', 'To do'), ('state_sent', '✅ Uploaded'), ('state_done', '✅ Checked by the club'),
               ('how_it_works', 'For each step: do it, then tap 📎 Upload to add a photo or PDF. Once it''s uploaded it''s checked off ✅.'))
       AS v(tier, body)
 WHERE message_templates.kind = 'onboarding' AND message_templates.tier = v.tier;
