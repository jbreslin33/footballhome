-- 072 — add `template` column to lead_contacts so the multi-touch
-- follow-up sequence can record which touch each contact was
-- (touch1 = day 0, touch2 = day 3 nudge, touch3 = day 10 social-proof).
--
-- Nullable + no default so legacy rows (everything pre-multitouch)
-- stay as NULL and the backend treats NULL as "untemplated / touch1"
-- when computing what's-next-due.
--
-- Index supports the per-lead "what was the last touch" lookup that
-- GET /api/leads needs to populate `last_email_template` on each row.

ALTER TABLE lead_contacts
  ADD COLUMN IF NOT EXISTS template VARCHAR(32);

COMMENT ON COLUMN lead_contacts.template IS
  'Touch identifier (touch1 / touch2 / touch3 / ...) for the multi-touch lead-email sequence.  NULL = legacy / pre-multitouch row, treated as touch1 by the frontend next-due logic.';

CREATE INDEX IF NOT EXISTS idx_lead_contacts_lead_email_template
  ON lead_contacts(lead_id, sent_at DESC)
  WHERE channel = 'email';
