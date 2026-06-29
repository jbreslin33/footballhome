-- 074 — explicit "dead" flag on leads.
--
-- Marks a lead as closed-lost so the kanban-style status filter on the
-- Leads admin screen can show / hide / count them as a distinct
-- lifecycle state.  Lifecycle is now an exclusive 4-state machine:
--   new       — never emailed, not converted, not dead
--   responded — emailed at least once, not converted, not dead
--   signedup  — converted_at IS NOT NULL (migration 073) and not dead
--   dead      — dead_at IS NOT NULL  ← this migration
--
-- Coach toggles the flag from the Leads UI (no confirm prompt — the
-- "All" tab still lists dead leads so a misclick is one click to
-- undo).  No reason / source column for v1; the action is a pure
-- boolean lifecycle flip.  If the conversation later resumes, the
-- coach can clear the flag and the lead reverts to its previous
-- state (new / responded / signedup, derived from the other columns).
--
-- Mutual exclusion with converted_at is enforced read-side, not as a
-- DB constraint: the server-computed `needs_followup` excludes dead
-- leads, and the computed `status` column always returns 'dead' first
-- when dead_at is set (overriding converted_at).  Allowing both flags
-- to be set in the row keeps the audit trail intact if a coach toggles
-- back and forth.

ALTER TABLE leads
  ADD COLUMN IF NOT EXISTS dead_at TIMESTAMPTZ NULL;

COMMENT ON COLUMN leads.dead_at IS
  'When this lead was marked closed-lost.  NULL = still in the active funnel.';

-- Partial index for the Dead tab (small subset, scan-friendly).
CREATE INDEX IF NOT EXISTS idx_leads_dead_at
  ON leads(dead_at DESC)
  WHERE dead_at IS NOT NULL;
