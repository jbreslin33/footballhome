-- 1526 (2026-11-19) — 🎓 Onboarding: the volunteer → paid path.
--
-- Owner 11/19, pasting the club's new-coach email (PA criminal history $22,
-- NSOR form, child abuse $13, FBI fingerprints $22.95 via IdentoGO, photo
-- ID, W-9, direct deposit): "how can we incorporate this into footballhome
-- for the volunteers … as a check list or a way to remind them" → "shows on
-- their calendar as outstanding items like missing rsvps … but has
-- actionable links" → "we should have a volunteer page and a paid page …
-- we should try to get all the volunteers onboarded" → "this way they feel
-- like they have path to get paid and thus are motivated to volunteer".
--
--   onboarding_steps          the checklist, in order.  stage 'volunteer' =
--                             step 1 (clearances, ID — everyone working
--                             with the club's kids); stage 'paid' = step 2
--                             (W-9, direct deposit) — shown to a volunteer
--                             as what comes next, required once paid.
--   person_onboarding         who is on the path, and on which track.
--   person_onboarding_steps   per person per step: sent_at (the person says
--                             "sent it to the club"), verified_at (a club
--                             admin checked it).  Redo = sent_at cleared
--                             with a note.  A step with renew_months comes
--                             due again that long after verified_at.
--
-- Every clearance comes back to the person, who forwards it (nothing reaches
-- the club from the state directly); W-9 / direct deposit are handed to the
-- club — FootballHome only keeps the ticks, never SSNs or bank numbers.
-- The 🚦 band shows "⛔ Onboarding — N of M left" (status_items 'onboarding').

CREATE TABLE IF NOT EXISTS onboarding_steps (
    code          text PRIMARY KEY,
    stage         text NOT NULL CHECK (stage IN ('volunteer', 'paid')),
    label         text NOT NULL,
    how           text NOT NULL DEFAULT '',
    cost_usd      numeric(6,2),
    link_url      text,
    link_label    text,
    renew_months  integer CHECK (renew_months IS NULL OR renew_months > 0),
    sort_order    integer NOT NULL DEFAULT 0,
    is_active     boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS person_onboarding (
    person_id   integer PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    track       text NOT NULL CHECK (track IN ('volunteer', 'paid')),
    started_at  timestamptz NOT NULL DEFAULT now(),
    started_by  integer REFERENCES users(id) ON DELETE SET NULL,
    note        text
);

CREATE TABLE IF NOT EXISTS person_onboarding_steps (
    person_id    integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    step_code    text    NOT NULL REFERENCES onboarding_steps(code) ON DELETE CASCADE,
    sent_at      timestamptz,
    verified_at  timestamptz,
    verified_by  integer REFERENCES users(id) ON DELETE SET NULL,
    note         text,
    updated_at   timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (person_id, step_code)
);

INSERT INTO onboarding_steps (code, stage, label, how, cost_usd, link_url, link_label, renew_months, sort_order) VALUES
  ('pa_criminal', 'volunteer', 'PA Criminal History Check',
   'Request it online from the PA State Police, then send the club the certificate.', 22.00,
   'https://www.pa.gov/services/psp/request-a-criminal-history-background-check.html', 'Apply ›', 60, 1),
  ('child_abuse', 'volunteer', 'PA Child Abuse Clearance',
   'Apply online with PA DHS, then send the club the certificate when it comes.', 13.00,
   'https://www.pa.gov/agencies/dhs/resources/keep-kids-safe/child-abuse-clearances/pa-child-abuse-history-clearance.html', 'Apply ›', 60, 2),
  ('fbi_receipt', 'volunteer', 'FBI Fingerprints — appointment',
   'Pre-enroll on IdentoGO, go to the appointment with ID and payment, then send the club the receipt.', 22.95,
   'https://uenroll.identogo.com/workflows/1kg738', 'Pre-enroll ›', NULL, 3),
  ('fbi_result', 'volunteer', 'FBI Fingerprints — results',
   'When the results come (a few weeks after the appointment), send the club a copy.', NULL,
   NULL, NULL, 60, 4),
  ('nsor', 'volunteer', 'National Sex Offender Registry (NSOR) form',
   'Fill in the NSOR form the club sends you and submit it as the form says.', 0.00,
   NULL, NULL, NULL, 5),
  ('photo_id', 'volunteer', 'Copy of your photo ID',
   'Send the club a photo of your driver''s license or other photo ID.', NULL,
   NULL, NULL, NULL, 6),
  ('w9', 'paid', 'W-9',
   'Fill in the W-9 and hand or email it to the club.', NULL,
   'https://www.irs.gov/pub/irs-pdf/fw9.pdf', 'Get the form ›', NULL, 7),
  ('direct_deposit', 'paid', 'Direct deposit form',
   'Fill in the club''s direct deposit form and hand or email it to the club.', NULL,
   NULL, NULL, NULL, 8)
ON CONFLICT (code) DO NOTHING;

-- Everyone on the volunteer list starts on the path; Anthony Acevedo
-- (22397) and Luke Breslin (3463) are paid and were onboarded before
-- FootballHome (owner 11/19 "Luke and Acevedo are already onboarding so we
-- can show them as complete") — every step verified.
INSERT INTO person_onboarding (person_id, track, note)
SELECT v.person_id, CASE WHEN v.person_id = 22397 THEN 'paid' ELSE 'volunteer' END, NULL
  FROM club_volunteers v
ON CONFLICT (person_id) DO NOTHING;

INSERT INTO person_onboarding (person_id, track, note)
SELECT p.id, 'paid', 'Onboarded before FootballHome'
  FROM persons p WHERE p.id IN (22397, 3463)
ON CONFLICT (person_id) DO UPDATE SET track = 'paid', note = EXCLUDED.note;

INSERT INTO person_onboarding_steps (person_id, step_code, sent_at, verified_at, note)
SELECT p.person_id, s.code, now(), now(), 'Onboarded before FootballHome'
  FROM person_onboarding p CROSS JOIN onboarding_steps s
 WHERE p.person_id IN (22397, 3463)
ON CONFLICT (person_id, step_code) DO NOTHING;

-- 🚦 the band item: red while a step is still to do.
INSERT INTO status_items (code, severity, window_hours, sort_order)
VALUES ('onboarding', 'action', NULL, 6)
ON CONFLICT (code) DO NOTHING;

-- The page in the top menu (People).
INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens)
SELECT 'onboarding', 'people', 'Onboarding', '🎓', 'admin', 6, '{onboarding}'
 WHERE NOT EXISTS (SELECT 1 FROM menu_pages WHERE code = 'onboarding');

-- Words.  The band box + its sheet (event_center, where the band's words
-- live) and the #onboarding page (kind onboarding).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT v.category, v.label, v.kind, v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Event Center', 'Status band — onboarding box',      'event_center', 'seg_onboarding',   '⛔ Onboarding — {left} of {total} left', 1440),
    ('Event Center', 'Status band — onboarding button',   'event_center', 'act_onboarding',   'Finish ›', 1441),
    ('Event Center', 'Status band — onboarding sheet',    'event_center', 'sheet_onboarding', '🎓 Your path at Lighthouse', 1442),
    ('Onboarding', 'Sheet — intro (volunteer)', 'onboarding', 'intro_volunteer',
     'Step 1 clears you to coach and volunteer with our kids. Step 2 is the paperwork for a paid role — finish step 1 and you''re ready when one opens.', 1),
    ('Onboarding', 'Sheet — intro (paid)', 'onboarding', 'intro_paid',
     'Finish every step so the club can pay you.', 2),
    ('Onboarding', 'Stage — volunteer', 'onboarding', 'stage_volunteer', '🙋 Step 1 · Cleared to volunteer', 3),
    ('Onboarding', 'Stage — paid',      'onboarding', 'stage_paid',      '💵 Step 2 · Ready to be paid', 4),
    ('Onboarding', 'Stage — paid locked (volunteer)', 'onboarding', 'stage_paid_next', 'Next, when the club offers you a paid role', 5),
    ('Onboarding', 'Step — mark sent',    'onboarding', 'mark_sent',   '✅ I sent it', 6),
    ('Onboarding', 'Step — undo sent',    'onboarding', 'undo_sent',   'Undo', 7),
    ('Onboarding', 'Step state — to do',  'onboarding', 'state_todo',  '⬜ To do', 8),
    ('Onboarding', 'Step state — sent',   'onboarding', 'state_sent',  '🟡 Sent — club checking', 9),
    ('Onboarding', 'Step state — done',   'onboarding', 'state_done',  '✅ Done', 10),
    ('Onboarding', 'Step state — renew',  'onboarding', 'state_renew', '⛔ Renew — expired', 11),
    ('Onboarding', 'Step — cost',         'onboarding', 'cost',        '{amount}', 12),
    ('Onboarding', 'Step — free',         'onboarding', 'cost_free',   'Free', 13),
    ('Onboarding', 'Questions line',      'onboarding', 'questions',   'Questions or need help with a clearance? Message the club.', 14),
    ('Onboarding', 'Page — title',        'onboarding', 'title',       '🎓 Onboarding', 20),
    ('Onboarding', 'Page — sub',          'onboarding', 'sub',         'Volunteer → paid: clearances, ID, then pay paperwork. Tap a step to check it.', 21),
    ('Onboarding', 'Page — pill volunteers', 'onboarding', 'pill_volunteer', '🙋 Volunteers ({n})', 22),
    ('Onboarding', 'Page — pill paid',    'onboarding', 'pill_paid',   '💵 Paid ({n})', 23),
    ('Onboarding', 'Page — progress',     'onboarding', 'progress',    '{done} of {total} done', 24),
    ('Onboarding', 'Page — complete',     'onboarding', 'complete',    '✅ Complete', 25),
    ('Onboarding', 'Page — verify',       'onboarding', 'act_verify',  '✅ Checked', 26),
    ('Onboarding', 'Page — redo',         'onboarding', 'act_redo',    '↩ Redo', 27),
    ('Onboarding', 'Page — clear',        'onboarding', 'act_clear',   '⬜ Clear', 28),
    ('Onboarding', 'Page — make paid',    'onboarding', 'act_make_paid', '💵 Make paid', 29),
    ('Onboarding', 'Page — back to volunteer', 'onboarding', 'act_make_volunteer', '🙋 Back to volunteer', 30),
    ('Onboarding', 'Page — remove',       'onboarding', 'act_remove',  'Remove from onboarding', 31),
    ('Onboarding', 'Page — add',          'onboarding', 'add_title',   '➕ Start someone on the path', 32),
    ('Onboarding', 'Page — add hint',     'onboarding', 'add_hint',    'Volunteers and coaches not on the path yet', 33),
    ('Onboarding', 'Page — empty',        'onboarding', 'empty',       'Nobody here yet.', 34)
  ) AS v(category, label, kind, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.kind AND m.tier = v.tier);
