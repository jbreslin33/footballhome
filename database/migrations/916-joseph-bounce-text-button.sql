-- Contact 167's email bounced (U10 at Parkwood, match 9312), so his game gets
-- a 💬 button: a text with the email he missed, word for word from draft 4,
-- who else it went to, and a request for his correct email.  A draft with no
-- subject is a text; its button opens the texts app.  Names come from
-- club_contacts.
BEGIN;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Opponents', 'Contact drafts — under the big Open in texts button', 'contact_draft', 'big_button_note_text', NULL,
       'Opens your texts with the message filled in: {to}', 5, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'contact_draft' AND t.tier = 'big_button_note_text');

WITH him AS (
  SELECT id, split_part(name, ' ', 1) AS first FROM club_contacts WHERE id = 167
), others AS (
  SELECT string_agg(c.name || ' (' || c.role || ')', ' and ' ORDER BY c.id) AS names
    FROM contact_email_draft_recipients r JOIN club_contacts c ON c.id = r.contact_id
   WHERE r.draft_id = 4 AND c.id <> 167
), new_draft AS (
  INSERT INTO contact_email_drafts (contact_id, match_id, label, subject, body, created_by_user_id)
  SELECT him.id, 9312, 'Text ' || him.first || ': game cancelled, need correct email', '',
         'Hi ' || him.first || ', it''s James Breslin from Lighthouse. My email to you bounced, so here is what we sent:'
         || E'\n\n' || d.body || E'\n\n'
         || 'That email also went to ' || others.names || '.'
         || E'\n\n' || 'What is your correct email? Please text back so I know you got this.',
         1
    FROM him, others, contact_email_drafts d
   WHERE d.id = 4
  RETURNING id, contact_id
)
INSERT INTO contact_email_draft_recipients (draft_id, contact_id)
SELECT id, contact_id FROM new_draft;

COMMIT;
