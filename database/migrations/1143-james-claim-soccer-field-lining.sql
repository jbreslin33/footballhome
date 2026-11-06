-- Owner 2026-11-06: "add the gcal items that say Soccer Field Lining. as
-- hours for me".  Same as CASA Soccer (mig 577): a calendar event with this
-- title is James's work, billed at its calendar length on the sheet whose
-- window it falls in (✓ by default, ✗ to leave one off).
INSERT INTO invoice_issuer_event_claims (issuer_id, summary_pattern, note, is_active, label, scope)
SELECT 1, '\msoccer\s+field\s+lining', 'Owner 2026-11-06: "Soccer Field Lining" calendar events are James''s hours', true, 'Field lining', 'club'
 WHERE NOT EXISTS (SELECT 1 FROM invoice_issuer_event_claims WHERE issuer_id = 1 AND summary_pattern = '\msoccer\s+field\s+lining');
