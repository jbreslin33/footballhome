-- 046-leads-preferred-channel.sql
-- Add the lead's self-reported preferred contact channel, captured by the
-- "What's the easiest way to reach you?" radio question on the Meta lead
-- forms (Text / Email / WhatsApp).
--
-- Stored as the lowercase key the form returns ('text' | 'email' |
-- 'whatsapp') for stability — the friendly capitalized label lives in
-- the UI only.  NULL for any lead captured before the question was added
-- (those leads keep working with the default button order).
ALTER TABLE leads
  ADD COLUMN IF NOT EXISTS preferred_channel TEXT
    CHECK (preferred_channel IN ('text', 'email', 'whatsapp'));

-- lead_contacts.channel CHECK previously only allowed (text|email|call).
-- The leads page now ships a WhatsApp button (visible only when the lead
-- self-selected WhatsApp), and clicking it POSTs to /api/leads/:id/contact
-- with channel='whatsapp' for touch-tracking parity with text/email.
-- Replace the constraint to allow it.  Keep 'call' for legacy logs.
ALTER TABLE lead_contacts
  DROP CONSTRAINT IF EXISTS lead_contacts_channel_check;
ALTER TABLE lead_contacts
  ADD CONSTRAINT lead_contacts_channel_check
    CHECK (channel IN ('text', 'email', 'whatsapp', 'call'));
