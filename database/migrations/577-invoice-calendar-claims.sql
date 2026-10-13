-- 577: calendar name claims — a raw gcal event can be an issuer's work.
--
-- Owner 2026-10-13: "anytime it says CASA soccer that is me. we need to add
-- that to my invoice."  "CASA soccer" Saturdays live on the ops calendar and
-- never classify into fh_events, so the events-only sheet (mig 576) lost
-- them with the usual-week rows.  A claim row says: any calendar event whose
-- title matches this pattern is this issuer's work — it rides the sheet like
-- a practice (✓ by default, hours = the calendar length, ✗ to take it off).
--
-- Day rows and ✗s for claimed events key on the gcal event itself (they have
-- no fh_event), so both tables grow a parallel gcal_event_id key.

BEGIN;

CREATE TABLE invoice_issuer_event_claims (
    id              serial PRIMARY KEY,
    issuer_id       integer NOT NULL REFERENCES invoice_issuers(id) ON DELETE CASCADE,
    summary_pattern text    NOT NULL,   -- case-insensitive regex over gcal_events.summary
    note            text,
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now()
);

-- Day rows for claimed events point at the calendar row itself.
ALTER TABLE invoice_work_shifts
    ADD COLUMN gcal_event_id bigint REFERENCES gcal_events(id) ON DELETE SET NULL;
CREATE UNIQUE INDEX invoice_work_shifts_gcal_uq
    ON invoice_work_shifts (invoice_id, gcal_event_id) WHERE gcal_event_id IS NOT NULL;

-- Same for a stored ✗ (mig 573): one key or the other, never both.
ALTER TABLE invoice_event_declines DROP CONSTRAINT invoice_event_declines_pkey;
ALTER TABLE invoice_event_declines ALTER COLUMN fh_event_id DROP NOT NULL;
ALTER TABLE invoice_event_declines
    ADD COLUMN gcal_event_id bigint REFERENCES gcal_events(id) ON DELETE CASCADE,
    ADD CONSTRAINT invoice_event_declines_one_key
        CHECK ((fh_event_id IS NULL) <> (gcal_event_id IS NULL));
CREATE UNIQUE INDEX invoice_event_declines_fh_uq
    ON invoice_event_declines (invoice_id, fh_event_id) WHERE fh_event_id IS NOT NULL;
CREATE UNIQUE INDEX invoice_event_declines_gcal_uq
    ON invoice_event_declines (invoice_id, gcal_event_id) WHERE gcal_event_id IS NOT NULL;

-- James's claim: every "CASA soccer" calendar entry is his shift.
INSERT INTO invoice_issuer_event_claims (issuer_id, summary_pattern, note)
SELECT i.id, '\mCASA\s+soccer', 'CASA Saturday shifts are James''s work hours'
  FROM invoice_issuers i
 WHERE i.person_id = 1;

COMMIT;
