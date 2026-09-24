-- 424 — Security: the lock-up is confirmed by a PHOTO of the locked gate
-- (owner 2026-09-24): "it needs to call phone if no upload of picture of
-- locked gate is uploaded to footballhome within 45 minutes of end time
-- of event at a lighthouse site like sports complex or community center.
-- so you need a security button at top level of admin for fh. and an
-- upload button to accept a pic."
--
-- Policy now: 45 min after the night's last event, the phone rings every
-- 5 minutes (up to 3 hours) until a photo is up.  Email / text carry the
-- upload link with the first alert only.  Two facilities: the Sport
-- Complex and the Community Center on Somerset.
ALTER TABLE facility_lockups DROP CONSTRAINT IF EXISTS facility_lockups_confirmed_via_check;
ALTER TABLE facility_lockups ADD CONSTRAINT facility_lockups_confirmed_via_check
  CHECK (confirmed_via IS NULL OR confirmed_via IN ('tap', 'board', 'photo'));

CREATE TABLE IF NOT EXISTS facility_lockup_photos (
  id          BIGSERIAL PRIMARY KEY,
  lockup_id   BIGINT NOT NULL REFERENCES facility_lockups(id) ON DELETE CASCADE,
  person_id   INT REFERENCES persons(id) ON DELETE SET NULL,
  file_path   TEXT NOT NULL,          -- /images/security/<file> as nginx serves it
  mime        TEXT NOT NULL,
  byte_size   INT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE facility_lockup_photos IS 'Photos of the locked gate that confirmed a night (mig 424)';
CREATE INDEX IF NOT EXISTS facility_lockup_photos_lockup_idx ON facility_lockup_photos (lockup_id);

UPDATE facilities
   SET lockup_grace_minutes = 45, lockup_repeat_minutes = 5, lockup_max_alerts = 36, updated_at = now()
 WHERE name = 'Lighthouse Sport Complex';

INSERT INTO facilities (name, short_name, lockup_required, lockup_grace_minutes, lockup_repeat_minutes,
                        lockup_max_alerts, lockup_prompt_last_event_coaches)
VALUES ('Lighthouse Community Center', 'Somerset', true, 45, 5, 36, false)
ON CONFLICT (name) DO NOTHING;

INSERT INTO facility_location_aliases (facility_id, gcal_location)
SELECT f.id, a.loc FROM facilities f, (VALUES
  ('The Lighthouse Community Center, 141 W Somerset St, Philadelphia, PA 19133, USA'),
  ('141 W Somerset St, Philadelphia, PA 19133, USA'),
  ('Lighthouse Community Center')
) AS a(loc)
WHERE f.name = 'Lighthouse Community Center'
ON CONFLICT (gcal_location) DO NOTHING;

INSERT INTO facility_lockup_people (facility_id, person_id, role, channels)
SELECT f.id, 1, r.role, r.channels
  FROM facilities f, (VALUES
    ('closer',     ARRAY['email','sms']),
    ('escalation', ARRAY['email','sms','call'])
  ) AS r(role, channels)
 WHERE f.name = 'Lighthouse Community Center'
ON CONFLICT (facility_id, person_id, role) DO NOTHING;

UPDATE fh_events fe
   SET facility_id = fh_facility_for_location(g.location)
  FROM gcal_events g
 WHERE g.id = fe.gcal_event_id AND fe.facility_id IS NULL
   AND fh_facility_for_location(g.location) IS NOT NULL;

-- ── Wording: the photo is the confirmation (extra token {repeat_minutes}) ──
CREATE OR REPLACE FUNCTION pg_temp.set_lockup_tpl(p_tier text, p_label text, p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  UPDATE message_templates SET label = p_label, subject = p_subject, body = p_body, sort_order = p_sort,
         is_active = true, updated_at = now()
   WHERE kind = 'lockup' AND tier = p_tier;
  IF NOT FOUND THEN
    INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
    VALUES ('System', p_label, 'lockup', p_tier, p_subject, p_body, p_sort, true, false, false);
  END IF;
END $$;

SELECT pg_temp.set_lockup_tpl('prompt_email', 'Security — prompt at the end of the last event (email)',
  '{facility} lock-up tonight — upload a photo of the locked gate',
  E'Hi {name},\n\nTonight''s last event at {facility} is {last_event}, ending {ends_at}.\n\nWhen the gate is locked, take a photo of it and upload it here (no login):\n{link}\n\nIf no photo is up by {deadline}, Football Home starts calling.\n\n— Football Home', 600);

SELECT pg_temp.set_lockup_tpl('prompt_sms', 'Security — prompt at the end of the last event (text)', NULL,
  'Football Home (Lighthouse 1893 SC): {facility} lock-up tonight. {last_event} ends {ends_at}. Upload a photo of the locked gate: {link} Reply STOP to opt out.', 601);

SELECT pg_temp.set_lockup_tpl('alert_email', 'Security — no photo by the deadline (email, first alert only)',
  '⚠️ {facility}: no photo of the locked gate ({date})',
  E'No photo of the locked gate at {facility} has been uploaded after tonight''s last event ({last_event}, ended {ends_at}). Football Home will keep calling every {repeat_minutes} minutes until one is up.\n\nUpload it here:\n{link}\n\nOr open Football Home → Security.\n\n— Football Home', 602);

SELECT pg_temp.set_lockup_tpl('alert_sms', 'Security — no photo by the deadline (text, first alert only)', NULL,
  'Football Home (Lighthouse 1893 SC): no photo of the locked gate at {facility} after {last_event} (ended {ends_at}). Upload it: {link} Reply STOP to opt out.', 603);

SELECT pg_temp.set_lockup_tpl('alert_call', 'Security — no photo by the deadline (phone call, every repeat)', NULL,
  'This is Football Home. No photo of the locked gate at {facility} has been uploaded after tonight''s last event, which ended at {ends_at}. Please upload the photo at football home dot org, Security. I will call again in {repeat_minutes} minutes. Goodbye.', 604);

SELECT pg_temp.set_lockup_tpl('confirmed_email', 'Security — all clear after alerts (email)',
  '✅ {facility} locked ({date})',
  E'A photo of the locked gate at {facility} was uploaded by {confirmed_by} at {confirmed_at}. The calls have stopped.\n\n— Football Home', 605);

SELECT pg_temp.set_lockup_tpl('confirmed_sms', 'Security — all clear after alerts (text)', NULL,
  'Football Home (Lighthouse 1893 SC): {facility} locked — photo uploaded by {confirmed_by} at {confirmed_at}. Calls stopped.', 606);

SELECT pg_temp.set_lockup_tpl('page_upload', 'Security — link landing: upload the photo',
  'Lock the gate, take the photo',
  E'{facility} · {date}\nTonight''s last event: {last_event}, ended {ends_at}.\nUpload a photo of the locked gate. That is the confirmation — nothing else to do.', 607);

SELECT pg_temp.set_lockup_tpl('page_uploaded', 'Security — link landing: photo received',
  'Thanks, {name}',
  E'{facility} is marked locked for {date} ({confirmed_at}).\nThe photo is on the Security page. You can close this page.', 608);

SELECT pg_temp.set_lockup_tpl('page_already', 'Security — link landing: already confirmed',
  'Already confirmed',
  E'{facility} was already marked locked for {date} by {confirmed_by} at {confirmed_at}.\nNothing more to do.', 609);

SELECT pg_temp.set_lockup_tpl('page_invalid', 'Security — link landing: link expired',
  'This link has expired',
  E'Links work for 24 hours.\nOpen Football Home → Security to upload the photo, or ask an admin for a new link.', 610);

UPDATE message_templates SET is_active = false, updated_at = now() WHERE kind = 'lockup' AND tier = 'page_confirmed';
DROP FUNCTION pg_temp.set_lockup_tpl(text, text, text, text, int);

-- Button words on the public upload page (read by LockupController::handleTap).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', l, 'lockup', t, NULL, b, s, true, false, false
  FROM (VALUES
    ('ui_upload_button', 'Security — upload page: button',          '📷 Take / upload photo of the locked gate', 620),
    ('ui_uploading',     'Security — upload page: while uploading', 'Uploading…', 621),
    ('ui_upload_failed', 'Security — upload page: failure prefix',  'Upload failed: ', 622)
  ) AS v(t, l, b, s)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'lockup' AND m.tier = v.t);
