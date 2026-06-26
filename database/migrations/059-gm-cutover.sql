-- 059 — GroupMe cutover.  Stop using GroupMe as RSVP / calendar source of
-- truth; flip everything to FH-native.  GM remains as a plain chat we can
-- still post messages into (containing magic-link RSVP URLs) but no data
-- flows back from it.
--
-- After this migration:
--   - event_rsvps holds every historical and future RSVP.
--   - chat_event_rsvps becomes effectively read-only / historical; any
--     remaining writes (admin "pulse" buttons in the C++ controller that
--     still target chat_event_rsvps) are mirrored into event_rsvps by a
--     trigger so nothing is lost while the C++ paths are migrated.
--   - v_event_rsvps_merged is dropped — event_rsvps is the only truth.
--   - chat_events gets `source` (owner: FH vs imported-from-GM) and
--     `max_capacity` (pickup waitlist support).
--   - persons gets `parent_person_id` (youth parent linkage) and
--     `pickup_opt_in_at` (drop-in pickup pool membership).
--
-- The GM polling container (footballhome_groupme_sync, sync-groupme-events.js)
-- should be stopped immediately after this migration runs.

BEGIN;

-- ───────────────────────────────────────────────────────────────────────
-- 1. New columns on chat_events
-- ───────────────────────────────────────────────────────────────────────
ALTER TABLE chat_events
  ADD COLUMN IF NOT EXISTS source TEXT NOT NULL DEFAULT 'footballhome',
  ADD COLUMN IF NOT EXISTS max_capacity INT NULL;

-- Every existing chat_events row was originally ingested from GroupMe, but
-- going forward FH owns the calendar.  Default 'footballhome' applies to
-- new rows; we leave existing rows on the same default for simplicity
-- (the column is informational; queries don't filter on it yet).

-- ───────────────────────────────────────────────────────────────────────
-- 2. New columns on persons
-- ───────────────────────────────────────────────────────────────────────
ALTER TABLE persons
  ADD COLUMN IF NOT EXISTS parent_person_id INT NULL REFERENCES persons(id),
  ADD COLUMN IF NOT EXISTS pickup_opt_in_at TIMESTAMPTZ NULL;

CREATE INDEX IF NOT EXISTS idx_persons_parent
  ON persons(parent_person_id) WHERE parent_person_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_persons_pickup_opt_in
  ON persons(pickup_opt_in_at) WHERE pickup_opt_in_at IS NOT NULL;

-- ───────────────────────────────────────────────────────────────────────
-- 3. Backfill — copy historical GM RSVPs into event_rsvps.
--    Two passes: (a) rows already keyed on person_id; (b) rows keyed only
--    on external_user_id whose external user has since been linked to a
--    person via chat_external_members.
--
--    Within each pass we pick the most-meaningful row per (event, person):
--    override wins, then most-recent timestamp.  ON CONFLICT preserves
--    any FH-native row that already exists (migration is idempotent).
-- ───────────────────────────────────────────────────────────────────────

INSERT INTO event_rsvps (chat_event_id, person_id, rsvp_status_id,
                         response_note, source_id, recorded_at, updated_at)
SELECT DISTINCT ON (cer.chat_event_id, cer.person_id)
       cer.chat_event_id,
       cer.person_id,
       COALESCE(cer.override_rsvp_status_id, cer.rsvp_status_id),
       COALESCE(cer.override_note,           cer.response_note),
       CASE WHEN cer.override_rsvp_status_id IS NOT NULL THEN 3   -- admin
            ELSE 2 END,                                           -- groupme
       COALESCE(cer.overridden_at, cer.responded_at, NOW()),
       COALESCE(cer.overridden_at, cer.responded_at, NOW())
  FROM chat_event_rsvps cer
 WHERE cer.person_id IS NOT NULL
 ORDER BY cer.chat_event_id,
          cer.person_id,
          COALESCE(cer.overridden_at, cer.responded_at) DESC NULLS LAST
ON CONFLICT (chat_event_id, person_id) DO NOTHING;

INSERT INTO event_rsvps (chat_event_id, person_id, rsvp_status_id,
                         response_note, source_id, recorded_at, updated_at)
SELECT DISTINCT ON (cer.chat_event_id, cem.person_id)
       cer.chat_event_id,
       cem.person_id,
       COALESCE(cer.override_rsvp_status_id, cer.rsvp_status_id),
       COALESCE(cer.override_note,           cer.response_note),
       CASE WHEN cer.override_rsvp_status_id IS NOT NULL THEN 3
            ELSE 2 END,
       COALESCE(cer.overridden_at, cer.responded_at, NOW()),
       COALESCE(cer.overridden_at, cer.responded_at, NOW())
  FROM chat_event_rsvps cer
  JOIN chat_events ce
    ON ce.id = cer.chat_event_id
  JOIN chat_external_members cem
    ON cem.external_user_id = cer.external_user_id
   AND cem.chat_id          = ce.chat_id
   AND cem.person_id IS NOT NULL
 WHERE cer.person_id IS NULL
 ORDER BY cer.chat_event_id,
          cem.person_id,
          COALESCE(cer.overridden_at, cer.responded_at) DESC NULLS LAST
ON CONFLICT (chat_event_id, person_id) DO NOTHING;

-- ───────────────────────────────────────────────────────────────────────
-- 4. Mirror trigger — keep working while C++ admin paths still write to
--    chat_event_rsvps.  When the EventController is refactored to write
--    event_rsvps directly, this trigger can be dropped.
-- ───────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_mirror_chat_event_rsvp_to_event_rsvp()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.person_id IS NULL THEN RETURN NEW; END IF;

  INSERT INTO event_rsvps (chat_event_id, person_id, rsvp_status_id,
                           response_note, source_id, recorded_at, updated_at)
  VALUES (
    NEW.chat_event_id,
    NEW.person_id,
    COALESCE(NEW.override_rsvp_status_id, NEW.rsvp_status_id),
    COALESCE(NEW.override_note,           NEW.response_note),
    CASE WHEN NEW.override_rsvp_status_id IS NOT NULL THEN 3 ELSE 2 END,
    COALESCE(NEW.overridden_at, NEW.responded_at, NOW()),
    COALESCE(NEW.overridden_at, NEW.responded_at, NOW())
  )
  ON CONFLICT (chat_event_id, person_id) DO UPDATE SET
    rsvp_status_id = EXCLUDED.rsvp_status_id,
    response_note  = EXCLUDED.response_note,
    source_id      = EXCLUDED.source_id,
    updated_at     = EXCLUDED.updated_at;

  RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS trg_mirror_chat_event_rsvp ON chat_event_rsvps;
CREATE TRIGGER trg_mirror_chat_event_rsvp
AFTER INSERT OR UPDATE ON chat_event_rsvps
FOR EACH ROW EXECUTE FUNCTION fn_mirror_chat_event_rsvp_to_event_rsvp();

-- ───────────────────────────────────────────────────────────────────────
-- 5. Drop the merged view — event_rsvps is now the single source of
--    truth.  Verified (2026-06-25) only its defining migration (057)
--    references it; no app code reads it.
-- ───────────────────────────────────────────────────────────────────────
DROP VIEW IF EXISTS v_event_rsvps_merged;

COMMIT;
