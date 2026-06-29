-- 075 — manual status override on leads.
--
-- Leads admin screen color-codes each card by lifecycle state
-- (lead.status — migration 074).  When the auto-derived state is
-- wrong (lead replied via phone instead of email; coach knows
-- something the system doesn't; etc.) the coach needs a way to
-- force the card to display a specific color regardless of the
-- underlying data.
--
-- This column is a pure display override.  It does NOT touch
-- converted_at / dead_at / last_email_at — those remain the
-- audit-trail / sync-sidecar source of truth.  At read time the
-- server computes:
--
--   status = COALESCE(status_override, derived_status)
--
-- where derived_status is the old CASE expression from migration
-- 074.  Valid values mirror the lifecycle states:
--
--   'new' | 'responded' | 'signedup' | 'dead' | NULL
--
-- NULL (default) means "auto" — the derived state wins.

ALTER TABLE leads
  ADD COLUMN IF NOT EXISTS status_override VARCHAR(16) NULL;

COMMENT ON COLUMN leads.status_override IS
  'Manual lifecycle color override set from the Leads admin UI.  '
  'When non-NULL, overrides the derived status for display + tab '
  'filtering.  Valid values: new | responded | signedup | dead.';
