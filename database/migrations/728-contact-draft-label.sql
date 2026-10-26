-- 728 (2026-10-26) — A draft can carry a short button label.  Owner: "dude
-- need a clear button to click. that just opens my gmail with message and
-- contacts all in one" → "reschedule proposal button".  Game Center's 📇
-- panel shows every unsent draft going to one of its contacts as a big
-- ✉️ <label> button (subject when no label); one click = Gmail compose to
-- everyone on it, logged as sent (mig 724/726).
ALTER TABLE contact_email_drafts ADD COLUMN IF NOT EXISTS label TEXT;
COMMENT ON COLUMN contact_email_drafts.label IS 'mig 728: the big button''s words in Game Center (e.g. Reschedule proposal); NULL = the subject.';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Opponents', 'Contact drafts — under the big Open in Gmail button', 'contact_draft', 'big_button_note', NULL,
       'Opens your Gmail with the message and everyone filled in: {to}', 4, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'contact_draft' AND t.tier = 'big_button_note');
