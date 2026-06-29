-- 073 — manual "signed up" flag on leads.
--
-- Marks the point a lead actually converted (registered in LeagueApps,
-- paid, joined a roster, etc.).  Phase 1 is a manual flip from the
-- Leads admin screen — Phase 3 (separate commit) will auto-fill from
-- a LeagueApps registrations-export sync sidecar.
--
-- Columns:
--   converted_at      — when the conversion happened (NULL = open lead)
--   converted_source  — how we learned about it ('manual', 'leagueapps',
--                       eventually 'webhook' / 'admin' / etc.).  Kept
--                       free-form VARCHAR(16) so we don't have to ALTER
--                       on every new source.
--   converted_note    — optional free-text the coach types when marking
--                       manually (e.g. "boys u12 + paid 6/22").  NULL
--                       is fine.
--
-- The frontend tabs (Open / Follow-up due / Converted) are derived on
-- the read path from (converted_at, last_email_at, NOW()) — no
-- additional flag column required.

ALTER TABLE leads
  ADD COLUMN IF NOT EXISTS converted_at     TIMESTAMPTZ NULL,
  ADD COLUMN IF NOT EXISTS converted_source VARCHAR(16) NULL,
  ADD COLUMN IF NOT EXISTS converted_note   TEXT        NULL;

COMMENT ON COLUMN leads.converted_at IS
  'When this lead converted (registered / paid / joined roster).  NULL = still open.';
COMMENT ON COLUMN leads.converted_source IS
  'How we learned about the conversion: manual | leagueapps | webhook.';
COMMENT ON COLUMN leads.converted_note IS
  'Optional free-text the coach typed when marking the lead converted manually.';

-- Partial index for the Converted tab (small subset, scan-friendly).
CREATE INDEX IF NOT EXISTS idx_leads_converted_at
  ON leads(converted_at DESC)
  WHERE converted_at IS NOT NULL;
