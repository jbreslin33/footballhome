-- 056-person-merges.sql
--
-- Audit + restore log for person record merges (Phase B of LA↔GM
-- reconciliation).  When two `persons` rows are determined to describe
-- the same human (one LA-only, one GM-only), the GM-only row's children
-- are reparented to the LA row and the GM-only `persons` row is deleted.
-- This table captures everything needed to undo that operation later.
--
-- `dropped_snapshot` shape:
--   {
--     "persons":  { full row of the deleted persons record },
--     "children": {
--        "users":            [ { row }, ... ],
--        "person_emails":    [ ... ],
--        "person_phones":    [ ... ],
--        "external_identities":     [ ... ],
--        "players":          [ ... ],
--        "coaches":          [ ... ],
--        "chat_non_players": [ ... ],
--        "chat_external_members":   [ ... ],
--        "chat_event_rsvps":        [ ... ],
--        "external_person_aliases": [ ... ],
--        "person_field_overrides":  [ ... ]
--     }
--   }
--
-- Foreign keys to `persons` are intentionally OMITTED here: after a merge
-- the dropped persons row no longer exists, and after an unmerge the kept
-- row might be re-dropped — we need this audit trail to survive both.
CREATE TABLE IF NOT EXISTS person_merges (
  id                  SERIAL PRIMARY KEY,
  kept_person_id      INTEGER NOT NULL,
  dropped_person_id   INTEGER NOT NULL,
  dropped_snapshot    JSONB   NOT NULL,
  merged_by_user_id   INTEGER REFERENCES users(id) ON DELETE SET NULL,
  merged_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  reversed_at         TIMESTAMPTZ,
  reversed_by_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

-- Look up active (un-reversed) merges that landed on a given person —
-- this is what powers the per-person "merge history" tooltip in the UI.
CREATE INDEX IF NOT EXISTS idx_person_merges_kept_active
  ON person_merges (kept_person_id)
  WHERE reversed_at IS NULL;

-- Look up by the dropped id so we can guard against re-merging an already
-- merged-away id (and find the audit row to unmerge).
CREATE INDEX IF NOT EXISTS idx_person_merges_dropped
  ON person_merges (dropped_person_id);
