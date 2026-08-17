-- ─────────────────────────────────────────────────────────────────────
-- 287-add-barn-night-kind.sql (2026-08-17)
--
-- `Kind: Barn Night` in a gcal description was silently rejected by
-- gcal-classify.js's parseDsl whitelist (not one of practice|pickup|
-- match|meeting|camp|other) and fell back to kind inference — showing
-- as "Pickup" on #my instead of Barn Night. Owner wants Barn Night to
-- be a real, explicit kind rather than an inferred one.
--
-- Value is 'barn night' (lowercase, space) — jsNormAlias() in
-- gcal-classify.js normalizes "Barn Night" to that exact string before
-- checking it against the kind whitelist, so the stored value has to
-- match it verbatim.
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

ALTER TABLE fh_events DROP CONSTRAINT fh_events_kind_check;
ALTER TABLE fh_events ADD CONSTRAINT fh_events_kind_check
    CHECK (kind IN ('practice','pickup','match','meeting','camp','other','barn night'));

COMMIT;
