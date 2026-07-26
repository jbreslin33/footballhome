-- 247 — optimize lead list aggregation for the Leads screen
-- The GET /api/leads query was doing a full grouped aggregate over
-- lead_contacts for every lead row. These indexes make the per-lead
-- summary lookups cheaper, especially as the lead/contact tables grow.

CREATE INDEX IF NOT EXISTS idx_lead_contacts_lead_email_sent
  ON lead_contacts (lead_id, sent_at DESC)
  WHERE channel = 'email';

CREATE INDEX IF NOT EXISTS idx_lead_contacts_lead_text_sent
  ON lead_contacts (lead_id, sent_at DESC)
  WHERE channel = 'text';

CREATE INDEX IF NOT EXISTS idx_lead_contacts_lead_call_sent
  ON lead_contacts (lead_id, sent_at DESC)
  WHERE channel = 'call';

CREATE INDEX IF NOT EXISTS idx_leads_created_at_desc
  ON leads (created_at DESC);
