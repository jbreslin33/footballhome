-- 421 — Facility lock-up check-in (owner 2026-09-24).
--
-- "so we didn't lock up Lighthouse after practice.  we take a picture and
-- then we send it to a text chat of the locked gate.  can we have a
-- system where if we don't tell fh that lighthouse is secure that it
-- sends a text and email to me?"
--
-- One lock-up per facility per night, keyed on the night's LAST event
-- there (several practices overlap; the gate is locked once).  The
-- backend scheduler (services/LockupScheduler) does the rest:
--   due_at       = the last event's end        → closers get a tap link
--   deadline_at  = due_at + grace              → escalation people get
--                                                 email / text / call,
--                                                 repeated every
--                                                 lockup_repeat_minutes,
--                                                 at most lockup_max_alerts
-- Confirming = one tap on the link (no login), or the button on #lockups.
--
-- Facilities: fh_events.facility_id has been "future: facilities table"
-- since migration 119.  Lighthouse shows up under two gcal location
-- strings, so the aliases table maps strings → facility and a trigger
-- fills fh_events.facility_id as the classifier promotes events.
--
-- All wording is message_templates kind='lockup'; policy (grace, cadence,
-- who is told) is rows here.  Change either by migration.

-- ── Facilities ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS facilities (
  id                      SERIAL PRIMARY KEY,
  name                    TEXT NOT NULL UNIQUE,
  short_name              TEXT NOT NULL,
  timezone                TEXT NOT NULL DEFAULT 'America/New_York',
  is_active               BOOLEAN NOT NULL DEFAULT true,
  lockup_required         BOOLEAN NOT NULL DEFAULT false,
  lockup_grace_minutes    INT NOT NULL DEFAULT 30,   -- deadline = last end + grace
  lockup_repeat_minutes   INT NOT NULL DEFAULT 30,   -- re-alert cadence after the deadline
  lockup_max_alerts       INT NOT NULL DEFAULT 6,    -- then it gives up for the night
  -- the coaches of the night's last event are asked to confirm too
  lockup_prompt_last_event_coaches BOOLEAN NOT NULL DEFAULT true,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE facilities IS 'Places the club plays; lock-up policy per facility (mig 421)';

CREATE TABLE IF NOT EXISTS facility_location_aliases (
  id            SERIAL PRIMARY KEY,
  facility_id   INT NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
  gcal_location TEXT NOT NULL UNIQUE
);
COMMENT ON TABLE facility_location_aliases IS 'gcal_events.location strings that mean this facility (mig 421)';

INSERT INTO facilities (name, short_name, lockup_required)
VALUES ('Lighthouse Sport Complex', 'Lighthouse', true)
ON CONFLICT (name) DO NOTHING;

INSERT INTO facility_location_aliases (facility_id, gcal_location)
SELECT f.id, a.loc FROM facilities f, (VALUES
  ('Lighthouse Sport Complex Field, 101-199 E Erie Ave, Philadelphia, PA 19140, USA'),
  ('199 E Erie Ave, Philadelphia, PA 19140, USA'),
  ('Lighthouse Sports Complex'),
  ('Lighthouse Sport Complex')
) AS a(loc)
WHERE f.name = 'Lighthouse Sport Complex'
ON CONFLICT (gcal_location) DO NOTHING;

-- fh_events.facility_id → facilities
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fh_events_facility_id_fkey') THEN
    ALTER TABLE fh_events ADD CONSTRAINT fh_events_facility_id_fkey
      FOREIGN KEY (facility_id) REFERENCES facilities(id) ON DELETE SET NULL;
  END IF;
END $$;
CREATE INDEX IF NOT EXISTS fh_events_facility_idx ON fh_events (facility_id);

CREATE OR REPLACE FUNCTION fh_facility_for_location(loc text) RETURNS int
LANGUAGE sql STABLE AS $$
  SELECT a.facility_id FROM facility_location_aliases a
   WHERE lower(btrim(a.gcal_location)) = lower(btrim(coalesce(loc, '')))
   LIMIT 1
$$;

-- Fill facility_id as the classifier promotes gcal rows to fh_events.
CREATE OR REPLACE FUNCTION fh_events_fill_facility() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.facility_id IS NULL THEN
    SELECT fh_facility_for_location(g.location) INTO NEW.facility_id
      FROM gcal_events g WHERE g.id = NEW.gcal_event_id;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS fh_events_fill_facility ON fh_events;
CREATE TRIGGER fh_events_fill_facility
  BEFORE INSERT OR UPDATE OF gcal_event_id ON fh_events
  FOR EACH ROW EXECUTE FUNCTION fh_events_fill_facility();

-- ...and follow the location when Google edits it.
CREATE OR REPLACE FUNCTION gcal_events_refresh_facility() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE fh_events SET facility_id = fh_facility_for_location(NEW.location), updated_at = now()
   WHERE gcal_event_id = NEW.id
     AND facility_id IS DISTINCT FROM fh_facility_for_location(NEW.location);
  RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS gcal_events_refresh_facility ON gcal_events;
CREATE TRIGGER gcal_events_refresh_facility
  AFTER UPDATE OF location ON gcal_events
  FOR EACH ROW EXECUTE FUNCTION gcal_events_refresh_facility();

-- Backfill every event already promoted.
UPDATE fh_events fe
   SET facility_id = fh_facility_for_location(g.location)
  FROM gcal_events g
 WHERE g.id = fe.gcal_event_id AND fe.facility_id IS NULL
   AND fh_facility_for_location(g.location) IS NOT NULL;

-- ── Who is asked, who is alerted ───────────────────────────────────────
-- role 'closer'     — gets the "tap when the gate is locked" prompt at due_at
-- role 'escalation' — gets the alerts after the deadline (and the all-clear)
-- channels ⊂ {email, sms, call}; 'call' only makes sense for escalation.
CREATE TABLE IF NOT EXISTS facility_lockup_people (
  id           SERIAL PRIMARY KEY,
  facility_id  INT NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
  person_id    INT NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  role         TEXT NOT NULL CHECK (role IN ('closer', 'escalation')),
  channels     TEXT[] NOT NULL DEFAULT ARRAY['email'],
  is_active    BOOLEAN NOT NULL DEFAULT true,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (facility_id, person_id, role)
);
COMMENT ON TABLE facility_lockup_people IS 'Lock-up closers (prompted) and escalation contacts (alerted) per facility (mig 421)';

-- James (person 1): asked to confirm, and the one who is chased.
INSERT INTO facility_lockup_people (facility_id, person_id, role, channels)
SELECT f.id, 1, r.role, r.channels
  FROM facilities f, (VALUES
    ('closer',     ARRAY['email','sms']),
    ('escalation', ARRAY['email','sms','call'])
  ) AS r(role, channels)
 WHERE f.name = 'Lighthouse Sport Complex'
ON CONFLICT (facility_id, person_id, role) DO NOTHING;

-- ── One row per facility per night ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS facility_lockups (
  id                     BIGSERIAL PRIMARY KEY,
  facility_id            INT NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
  local_date             DATE NOT NULL,
  last_fh_event_id       BIGINT REFERENCES fh_events(id) ON DELETE SET NULL,
  due_at                 TIMESTAMPTZ NOT NULL,      -- last event's end
  deadline_at            TIMESTAMPTZ NOT NULL,      -- due_at + grace
  prompted_at            TIMESTAMPTZ,               -- closers were sent the tap link
  confirmed_at           TIMESTAMPTZ,
  confirmed_by_person_id INT REFERENCES persons(id) ON DELETE SET NULL,
  confirmed_via          TEXT CHECK (confirmed_via IS NULL OR confirmed_via IN ('tap', 'board')),
  note                   TEXT,
  alert_count            INT NOT NULL DEFAULT 0,
  last_alert_at          TIMESTAMPTZ,
  announced_at           TIMESTAMPTZ,               -- all-clear sent after alerts had started
  created_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (facility_id, local_date)
);
COMMENT ON TABLE facility_lockups IS 'Nightly lock-up check-in per facility: due, deadline, who confirmed, alerts sent (mig 421)';
CREATE INDEX IF NOT EXISTS facility_lockups_open_idx ON facility_lockups (deadline_at) WHERE confirmed_at IS NULL;

-- One-tap confirm links: a per-person token, hashed, 24h, single use.
-- Confirms one lock-up and nothing else — it is not a sign-in.
CREATE TABLE IF NOT EXISTS facility_lockup_tokens (
  id          BIGSERIAL PRIMARY KEY,
  lockup_id   BIGINT NOT NULL REFERENCES facility_lockups(id) ON DELETE CASCADE,
  person_id   INT NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  token_hash  TEXT NOT NULL UNIQUE,
  expires_at  TIMESTAMPTZ NOT NULL,
  used_at     TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Every prompt / alert / all-clear / test that went out, and how it went.
CREATE TABLE IF NOT EXISTS facility_lockup_alerts (
  id           BIGSERIAL PRIMARY KEY,
  lockup_id    BIGINT NOT NULL REFERENCES facility_lockups(id) ON DELETE CASCADE,
  stage        TEXT NOT NULL CHECK (stage IN ('prompt', 'alert', 'confirmed', 'test')),
  channel      TEXT NOT NULL CHECK (channel IN ('email', 'sms', 'call')),
  person_id    INT REFERENCES persons(id) ON DELETE SET NULL,
  contact      TEXT NOT NULL,
  ok           BOOLEAN NOT NULL,
  provider_sid TEXT,
  error        TEXT,
  sent_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS facility_lockup_alerts_lockup_idx ON facility_lockup_alerts (lockup_id, sent_at);

-- ── Wording (kind='lockup') ────────────────────────────────────────────
-- Tokens: {name} {facility} {date} {last_event} {ends_at} {deadline}
--         {link} {alert_n} {confirmed_by} {confirmed_at}
CREATE OR REPLACE FUNCTION pg_temp.add_lockup_tpl(p_tier text, p_label text, p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
  SELECT 'System', p_label, 'lockup', p_tier, p_subject, p_body, p_sort, true, false, false
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'lockup' AND tier = p_tier);
$$;

SELECT pg_temp.add_lockup_tpl('prompt_email', 'Lock-up — prompt to closers (email)',
  '{facility} lock-up tonight — tap when the gate is locked',
  E'Hi {name},\n\nTonight''s last event at {facility} is {last_event}, ending {ends_at}.\n\nWhen the gate is locked, tap this link (one tap, no login):\n{link}\n\nIf nobody confirms by {deadline}, Football Home starts texting and calling the club.\n\n— Football Home', 600);

SELECT pg_temp.add_lockup_tpl('prompt_sms', 'Lock-up — prompt to closers (text)', NULL,
  'Football Home (Lighthouse 1893 SC): {facility} lock-up tonight. {last_event} ends {ends_at}. Tap when the gate is locked: {link} Reply STOP to opt out.', 601);

SELECT pg_temp.add_lockup_tpl('alert_email', 'Lock-up — not confirmed (email)',
  '⚠️ {facility} not confirmed locked ({date})',
  E'Nobody has confirmed {facility} was locked after tonight''s last event ({last_event}, ended {ends_at}). This is alert {alert_n}.\n\nIf it is locked, tap:\n{link}\n\nOr open Football Home → Lock-up and press "I locked it".\n\n— Football Home', 602);

SELECT pg_temp.add_lockup_tpl('alert_sms', 'Lock-up — not confirmed (text)', NULL,
  'Football Home (Lighthouse 1893 SC): {facility} has NOT been confirmed locked after {last_event} (ended {ends_at}). Alert {alert_n}. Tap if it is locked: {link} Reply STOP to opt out.', 603);

SELECT pg_temp.add_lockup_tpl('alert_call', 'Lock-up — not confirmed (phone call, spoken)', NULL,
  'This is Football Home. {facility} has not been confirmed locked after tonight''s last event, which ended at {ends_at}. Please check the gate. If it is locked, tap the link in your text or email. Goodbye.', 604);

SELECT pg_temp.add_lockup_tpl('confirmed_email', 'Lock-up — all clear after alerts (email)',
  '✅ {facility} locked ({date})',
  E'{facility} was confirmed locked by {confirmed_by} at {confirmed_at}.\n\n— Football Home', 605);

SELECT pg_temp.add_lockup_tpl('confirmed_sms', 'Lock-up — all clear after alerts (text)', NULL,
  'Football Home (Lighthouse 1893 SC): {facility} confirmed locked by {confirmed_by} at {confirmed_at}.', 606);

SELECT pg_temp.add_lockup_tpl('page_confirmed', 'Lock-up — tap landing: confirmed',
  'Thanks, {name}',
  E'{facility} is marked locked for {date} ({confirmed_at}).\nThe club has been told. You can close this page.', 607);

SELECT pg_temp.add_lockup_tpl('page_already', 'Lock-up — tap landing: already confirmed',
  'Already confirmed',
  E'{facility} was already marked locked for {date} by {confirmed_by} at {confirmed_at}.\nNothing more to do.', 608);

SELECT pg_temp.add_lockup_tpl('page_invalid', 'Lock-up — tap landing: link expired',
  'This link has expired',
  E'Lock-up links work for 24 hours and once.\nOpen Football Home → Lock-up instead, or ask an admin to send a new link.', 609);

DROP FUNCTION pg_temp.add_lockup_tpl(text, text, text, text, int);
