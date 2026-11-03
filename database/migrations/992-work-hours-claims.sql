-- 992 (2026-11-03) — James's non-coaching hours (lining fields, hosting CASA …)
-- off the calendar, each kind on its own #finances pill.
-- Owner 2026-11-03: "i also have other hours for lining fields etc, hosting
-- casa. etc. i can start putting that in gcal so that you can grab it."
--   invoice_issuer_event_claims (mig 577) already turns a calendar title into
--   an issuer's hours; a claim now also says what the work is (label) and
--   where it lands (scope, default club-wide).
--   New claim: any calendar event titled "Work: …" (e.g. "Work: line fields",
--   "Work: lights") is James's, club-wide.
BEGIN;
ALTER TABLE invoice_issuer_event_claims ADD COLUMN IF NOT EXISTS label TEXT;
ALTER TABLE invoice_issuer_event_claims ADD COLUMN IF NOT EXISTS scope TEXT NOT NULL DEFAULT 'club' REFERENCES cash_flow_scopes(code);
UPDATE invoice_issuer_event_claims SET label = 'CASA hosting' WHERE issuer_id = 1 AND summary_pattern = '\mCASA\s+soccer' AND label IS NULL;
INSERT INTO invoice_issuer_event_claims (issuer_id, summary_pattern, note, label, scope)
SELECT 1, '^\s*work\s*:', 'Owner 2026-11-03: field lining, lights and other club work — title the calendar event "Work: …"', 'Club work', 'club'
 WHERE NOT EXISTS (SELECT 1 FROM invoice_issuer_event_claims WHERE issuer_id = 1 AND summary_pattern = '^\s*work\s*:');

-- The claim a calendar title falls under for an issuer (first match).
CREATE OR REPLACE FUNCTION fh_issuer_claim(p_issuer int, p_summary text) RETURNS invoice_issuer_event_claims LANGUAGE sql STABLE AS $$
  SELECT * FROM invoice_issuer_event_claims WHERE issuer_id = p_issuer AND is_active AND p_summary ~* summary_pattern ORDER BY id LIMIT 1 $$;
COMMIT;
