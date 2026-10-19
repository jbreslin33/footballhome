-- 601 (2026-10-19) — Carpool on every game.  Owner: "would be great to
-- have a carpool feature on each game. request ride. then they could auto
-- have address for pickup of child on there. then someone could click to
-- acccpet carpool to drive?"
--
-- A parent (or an adult player) posts a ride request for one player on
-- one game; the pickup address is pre-filled from person_addresses
-- (mig 589) and SNAPSHOTTED onto the row, so "pick up at grandma's" is a
-- one-off edit, not a change to the person's address.  Anyone on the game
-- — rostered, invited call-up, their parents, a coach — sees the request
-- on #game-center's 🚗 Carpool panel and can tap "I can drive", which
-- stamps them as the driver and shows both sides each other's phone.
--
-- Rows are cancelled, never deleted, and a driver can step back
-- (accepted_by cleared) without killing the request.  One OPEN request
-- per player per game.
BEGIN;

CREATE TABLE IF NOT EXISTS fh_carpool_requests (
  id                      serial PRIMARY KEY,
  fh_event_id             bigint NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
  person_id               int    NOT NULL REFERENCES persons(id),  -- the PLAYER riding
  requested_by_person_id  int    NOT NULL REFERENCES persons(id),  -- who asked (parent for youth)
  -- Pickup address, snapshotted from person_addresses at request time and
  -- editable per request; the person's own row is never written from here.
  address1                text   NOT NULL DEFAULT '',
  address2                text   NOT NULL DEFAULT '',
  city                    text   NOT NULL DEFAULT '',
  state                   text   NOT NULL DEFAULT '',
  zip                     text   NOT NULL DEFAULT '',
  note                    text   NOT NULL DEFAULT '',
  created_at              timestamptz NOT NULL DEFAULT now(),
  accepted_by_person_id   int    REFERENCES persons(id),           -- the driver
  accepted_at             timestamptz,
  cancelled_at            timestamptz,
  cancelled_by_person_id  int    REFERENCES persons(id),
  CHECK ((accepted_by_person_id IS NULL) = (accepted_at IS NULL))
);
CREATE UNIQUE INDEX IF NOT EXISTS fh_carpool_requests_open_uq
  ON fh_carpool_requests (fh_event_id, person_id) WHERE cancelled_at IS NULL;
CREATE INDEX IF NOT EXISTS fh_carpool_requests_event_idx
  ON fh_carpool_requests (fh_event_id) WHERE cancelled_at IS NULL;
COMMENT ON TABLE fh_carpool_requests IS
  'One ride request per player per game (🚗 Carpool on #game-center, mig 601). Pickup address snapshotted from person_addresses; accepted_by = the driver. Cancel, never delete.';

-- The 🚗 panel's words (client_side rows, MessageCopy.block('carpool', tier)).
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_client_tpl('carpool', 'title', 'Carpool — panel title',
  '🚗 Carpool', 1);
SELECT pg_temp.add_client_tpl('carpool', 'hint', 'Carpool — what the panel does',
  'Need a ride for your player, or have a seat free? Post a request — the pickup address fills in automatically — and anyone on this game can tap I can drive.', 2);
SELECT pg_temp.add_client_tpl('carpool', 'empty', 'Carpool — no requests yet',
  'No ride requests for this game yet.', 3);
SELECT pg_temp.add_client_tpl('carpool', 'request_for', 'Carpool — request button, one player',
  '🚗 Request a ride for {name}', 4);
SELECT pg_temp.add_client_tpl('carpool', 'needs_driver', 'Carpool — open request status',
  'Needs a driver', 5);
SELECT pg_temp.add_client_tpl('carpool', 'accepted_by', 'Carpool — accepted status',
  '🚗 {driver} is driving', 6);
SELECT pg_temp.add_client_tpl('carpool', 'accept', 'Carpool — accept button',
  'I can drive', 7);
SELECT pg_temp.add_client_tpl('carpool', 'unaccept', 'Carpool — driver steps back',
  'Can''t drive anymore', 8);
SELECT pg_temp.add_client_tpl('carpool', 'cancel', 'Carpool — requester cancels',
  'Cancel request', 9);
SELECT pg_temp.add_client_tpl('carpool', 'save', 'Carpool — post the request',
  'Post request', 10);
SELECT pg_temp.add_client_tpl('carpool', 'pickup_label', 'Carpool — address line label',
  'Pickup', 11);
SELECT pg_temp.add_client_tpl('carpool', 'asked_by', 'Carpool — who posted it',
  'Asked by {name}', 12);
SELECT pg_temp.add_client_tpl('carpool', 'note_ph', 'Carpool — note placeholder',
  'Anything the driver should know — car seat, sibling riding along, …', 13);
SELECT pg_temp.add_client_tpl('carpool', 'no_address', 'Carpool — no address on file',
  'No address on file — type the pickup address.', 14);

COMMIT;
