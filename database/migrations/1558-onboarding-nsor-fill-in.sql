-- 1558 (2026-11-19) — 🎓 NSOR filled in on FootballHome and emailed to the
-- state for the volunteer (owner 11/19 "i thought for nsor we let them fill
-- out on fh and do email for them? like for invoices . so read form and look
-- at email format and where to send" → "where can we get blank one online
-- and get it to fh").
--
-- The blank is the official DHS form CY 1001 (5/24) from pa.gov
-- (…/keepkidssafe/resources/documents/2024-06-14-cy-1001-national-sex-
-- offender-registry-nsor-application-english.pdf), served as
-- /forms/nsor-cy1001-blank.pdf.  The volunteer types the fields and signs
-- with a finger; the browser fills the PDF (pdf-lib); the server stores it on
-- the step and emails it to RA-PWNSOR@pa.gov, subject "NSOR Verification
-- <last name>" (the form's own instructions), cc the volunteer, Reply-To
-- them.  Free; ~14 days; the letter comes to the volunteer by encrypted
-- email — they upload it here.  SSN / date of birth are never stored as
-- fields: only inside the PDF, which is purged with the other files.

ALTER TABLE onboarding_steps ADD COLUMN IF NOT EXISTS fill_form text;               -- 'nsor' = ✍️ Fill it in here
ALTER TABLE person_onboarding_steps ADD COLUMN IF NOT EXISTS submitted_at timestamptz; -- sent to the state

UPDATE onboarding_steps
   SET fill_form = 'nsor',
       link_url = 'https://www.pa.gov/content/dam/copapwp-pagov/en/dhs/documents/keepkidssafe/resources/documents/2024-06-14-cy-1001-national-sex-offender-registry-nsor-application-english.pdf',
       link_label = 'Paper form ›',
       how = 'Tap ✍️ Fill it in here, type your details and sign with your finger — we email it to the state for you (free). The state emails you your letter in about 14 days: upload it here when it comes.'
 WHERE code = 'nsor';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Onboarding', v.label, 'onboarding', v.tier, v.subject, v.body, v.sort_order, true, v.client_side, false
  FROM (VALUES
    ('NSOR — send to (state address)', 'nsor_to',      NULL, 'RA-PWNSOR@pa.gov', 90, false),
    ('NSOR — email to the state', 'nsor_email', 'NSOR Verification {last_name}',
     'Hello,

Attached is the completed National Sex Offender Registry verification application for {full_name}. Please send the verification letter to {email}.

Thank you.', 91, false),
    ('NSOR form — open',        'nsor_fill',        NULL, '✍️ Fill it in here', 92, true),
    ('NSOR form — title',       'nsor_title',       NULL, '✍️ NSOR form', 93, true),
    ('NSOR form — intro',       'nsor_intro',       NULL, 'Type your details exactly as on your ID, then sign. We fill in the official state form and email it to the state for you. Your SSN is only on the form — FootballHome doesn''t keep it.', 94, true),
    ('NSOR form — last',        'nsor_f_last',      NULL, 'Last name', 95, true),
    ('NSOR form — first',       'nsor_f_first',     NULL, 'First name', 96, true),
    ('NSOR form — middle',      'nsor_f_mi',        NULL, 'Middle initial', 97, true),
    ('NSOR form — ssn',         'nsor_f_ssn',       NULL, 'Social Security number', 98, true),
    ('NSOR form — dob',         'nsor_f_dob',       NULL, 'Date of birth', 99, true),
    ('NSOR form — phone',       'nsor_f_phone',     NULL, 'Daytime phone', 100, true),
    ('NSOR form — street',      'nsor_f_street',    NULL, 'Street address (apt #)', 101, true),
    ('NSOR form — city',        'nsor_f_city',      NULL, 'City', 102, true),
    ('NSOR form — state',       'nsor_f_state',     NULL, 'State', 103, true),
    ('NSOR form — zip',         'nsor_f_zip',       NULL, 'ZIP', 104, true),
    ('NSOR form — email',       'nsor_f_email',     NULL, 'Email (the state sends your letter here)', 105, true),
    ('NSOR form — sign',        'nsor_f_sign',      NULL, 'Sign here with your finger', 106, true),
    ('NSOR form — clear sign',  'nsor_clear_sign',  NULL, 'Clear', 107, true),
    ('NSOR form — affirm',      'nsor_affirm',      NULL, 'I affirm the above information is accurate and complete to the best of my knowledge and belief, and submitted as true and correct under penalty of law per Section 4904 of the Pennsylvania Crimes Code.', 108, true),
    ('NSOR form — send',        'nsor_send',        NULL, '✉️ Sign & send to the state', 109, true),
    ('NSOR form — sending',     'nsor_sending',     NULL, 'Sending…', 110, true),
    ('NSOR form — cancel',      'nsor_cancel',      NULL, 'Back', 111, true),
    ('NSOR form — missing',     'nsor_missing',     NULL, 'Still needed: {list}', 112, true),
    ('NSOR — sent line',        'nsor_sent_line',   NULL, '✉️ Sent to the state {when} — your letter comes by email in about 14 days. Upload it here.', 113, true)
  ) AS v(label, tier, subject, body, sort_order, client_side)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'onboarding' AND m.tier = v.tier);
