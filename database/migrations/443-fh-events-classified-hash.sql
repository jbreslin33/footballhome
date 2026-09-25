-- 443 (2026-09-25) — gcal-classify only re-walks what changed.
--
-- Owner: "we need to always refresh db from gcal."  The DSL pass in
-- scripts/gcal-classify.js re-processed every tagged calendar row
-- (5,894 today) on every 5-minute tick — a transaction and six queries
-- each — taking 110–165 s and, this afternoon, hitting the unit's 3-minute
-- timeout so the run was killed.  This column remembers what a row was
-- last classified from: gcal_events.hash (Google content) + a fingerprint
-- of the alias/offset tables the pass reads.  Unchanged rows are skipped;
-- FH_CLASSIFY_FULL=1 (or --full) re-walks everything.
ALTER TABLE fh_events ADD COLUMN IF NOT EXISTS classified_hash TEXT;
COMMENT ON COLUMN fh_events.classified_hash IS 'gcal_events.hash + alias-table fingerprint at the last DSL classification (mig 443). NULL = classify on the next run.';
