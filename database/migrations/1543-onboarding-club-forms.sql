-- 1543 (2026-11-19) — 🎓 the W-9 and direct-deposit steps link the club's
-- own blank forms (owner 11/19 "w9 uploaded in files", "paychex direct
-- deposit uploaded to files", "lets make this all easy and make sense for
-- volunteers!"): #files 56 "W9 Blank" and 57 "Paychex Direct Deposit Blank".
-- A /api/files/dl/… link opens through the volunteer's own sign-in
-- (OnboardingChecklist), so it works once the file is shared with Members
-- on #files — the owner's call, not changed here.
UPDATE onboarding_steps
   SET link_url = '/api/files/dl/56', link_label = 'Get the form ›',
       how = 'Get the form, fill it in, then upload a photo or scan of it here.'
 WHERE code = 'w9';
UPDATE onboarding_steps
   SET link_url = '/api/files/dl/57', link_label = 'Get the form ›',
       how = 'Get the Paychex form, fill it in, then upload a photo or scan of it here.'
 WHERE code = 'direct_deposit';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Onboarding', v.label, 'onboarding', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Popup — form not shared', 'form_unshared', 'This form isn''t shared yet — ask the club for it.', 60),
    ('Popup — progress',        'my_progress',   '{done} of {total} done', 61),
    ('Popup — how it works',    'how_it_works',  'For each step: do it, then tap 📎 Upload to add a photo or PDF. The club checks it and it turns ✅.', 62)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'onboarding' AND m.tier = v.tier);
