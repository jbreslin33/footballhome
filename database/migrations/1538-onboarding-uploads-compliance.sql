-- 1538 (2026-11-19) — 🎓 Onboarding collects the documents and sends them
-- to compliance (owner 11/19 "i would like us to collect it all and then
-- there should be a button for me to send it all to
-- compliance.director@lighthouse1893.org like we do for julian and
-- invoices" → "and we would include the volunteer on the email").
--
--   person_onboarding_files   each upload: a photo or PDF per step (more than
--                             one allowed — NSOR copy + letter).  Uploading
--                             marks the step sent.  emailed_at = went to
--                             compliance; the bytes are deleted
--                             onboarding_policy.purge_days after that (the
--                             W-9 / NSOR carry SSNs — compliance keeps them,
--                             FootballHome keeps only the ticks).
--   onboarding_policy         one row: where the button sends, the size cap,
--                             the purge window.
--   person_onboarding.emailed_at / emailed_by   the last send.
--
-- The button (#onboarding, per person) emails compliance from the club's
-- address with every file attached, cc the person and the admin who
-- pressed it, Reply-To that admin.  Words: message_templates kind onboarding.

CREATE TABLE IF NOT EXISTS onboarding_policy (
    id                int PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    compliance_email  text NOT NULL,
    compliance_name   text NOT NULL DEFAULT '',
    max_file_mb       int  NOT NULL DEFAULT 10 CHECK (max_file_mb BETWEEN 1 AND 25),
    purge_days        int  NOT NULL DEFAULT 30 CHECK (purge_days > 0)
);
INSERT INTO onboarding_policy (id, compliance_email, compliance_name)
VALUES (1, 'compliance.director@lighthouse1893.org', 'Compliance Director')
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS person_onboarding_files (
    id           bigserial PRIMARY KEY,
    person_id    integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    step_code    text    NOT NULL REFERENCES onboarding_steps(code) ON DELETE CASCADE,
    filename     text    NOT NULL,
    mime         text    NOT NULL,
    byte_size    integer NOT NULL,
    bytes        bytea   NOT NULL,
    uploaded_at  timestamptz NOT NULL DEFAULT now(),
    uploaded_by  integer REFERENCES users(id) ON DELETE SET NULL,
    emailed_at   timestamptz
);
CREATE INDEX IF NOT EXISTS idx_person_onboarding_files_person ON person_onboarding_files (person_id, step_code);

ALTER TABLE person_onboarding ADD COLUMN IF NOT EXISTS emailed_at timestamptz;
ALTER TABLE person_onboarding ADD COLUMN IF NOT EXISTS emailed_by integer REFERENCES users(id) ON DELETE SET NULL;

-- "send the club" → upload it here.
UPDATE onboarding_steps SET how = v.how FROM (VALUES
  ('pa_criminal', 'Request it online from the PA State Police, then upload the certificate here.'),
  ('child_abuse', 'Apply online with PA DHS, then upload the certificate here when it comes.'),
  ('fbi_receipt', 'Pre-enroll on IdentoGO, go to the appointment with ID and payment, then upload the receipt here.'),
  ('fbi_result',  'No link — when your results come (a few weeks after the appointment), upload them here.'),
  ('nsor',        'Fill in the form (tick "Volunteer"), then email a scan to RA-PWNSOR@pa.gov with the subject "NSOR Verification" and your last name. Upload your copy here now, and the letter when it comes (about 14 days).'),
  ('photo_id',    'No link — take a photo of your driver''s license or other photo ID and upload it here.'),
  ('w9',          'Fill in the W-9, then upload a photo or scan of it here.'),
  ('direct_deposit', 'No link — the club gives you this form. Fill it in, then upload a photo or scan of it here.')
) AS v(code, how) WHERE onboarding_steps.code = v.code;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Onboarding', v.label, 'onboarding', v.tier, v.subject, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Popup — upload button',   'upload',        NULL, '📎 Upload', 40),
    ('Popup — upload another',  'upload_more',   NULL, '📎 Add another', 41),
    ('Popup — uploading',       'uploading',     NULL, 'Uploading…', 42),
    ('Popup — remove file',     'remove_file',   NULL, '✕', 43),
    ('Popup — sent another way', 'sent_other',   NULL, 'I gave it to the club another way', 44),
    ('Page — view file',        'view_file',     NULL, '👁', 45),
    ('Page — send to compliance', 'act_send',    NULL, '✉️ Send all to compliance', 46),
    ('Page — sending',          'sending',       NULL, 'Sending…', 47),
    ('Page — sent line',        'sent_line',     NULL, '✉️ Sent to compliance {when}', 48),
    ('Page — send confirm',     'send_confirm',  NULL, 'Email {n} file(s) for {name} to {to}, cc {name} and you?', 49),
    ('Page — files kept',       'files_purge',   NULL, 'Files are deleted {days} days after they go to compliance — only the ticks stay.', 50),
    ('Page — no files',         'no_files',      NULL, 'No files uploaded yet.', 51),
    ('Email to compliance', 'email_compliance', 'Onboarding documents — {name}',
     'Hi,

Onboarding documents for {name} ({track}), who is copied on this email.

{list}

Thanks!', 52),
    ('Email to compliance — part', 'email_part', NULL, ' (part {i} of {n})', 53)
  ) AS v(label, tier, subject, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'onboarding' AND m.tier = v.tier);
