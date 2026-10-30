-- Contact 168's email bounced (U10 at Academy Sabres, match 9311), so his game
-- gets the same 💬 button as mig 916: the email he missed, word for word from
-- draft 3, who else it went to, and a request for his correct email.
WITH him AS (
  SELECT id, split_part(name, ' ', 1) AS first FROM club_contacts WHERE id = 168
), others AS (
  SELECT string_agg(c.name || ' (' || c.role || ')', ' and ' ORDER BY c.id) AS names
    FROM contact_email_draft_recipients r JOIN club_contacts c ON c.id = r.contact_id
   WHERE r.draft_id = 3 AND c.id <> 168
), new_draft AS (
  INSERT INTO contact_email_drafts (contact_id, match_id, label, subject, body, created_by_user_id)
  SELECT him.id, 9311, 'Text ' || him.first || ': game cancelled, need correct email', '',
         'Hi ' || him.first || ', it''s James Breslin from Lighthouse. My email to you bounced, so here is what we sent:'
         || E'\n\n' || d.body || E'\n\n'
         || 'That email also went to ' || others.names || '.'
         || E'\n\n' || 'What is your correct email? Please text back so I know you got this.',
         1
    FROM him, others, contact_email_drafts d
   WHERE d.id = 3
  RETURNING id, contact_id
)
INSERT INTO contact_email_draft_recipients (draft_id, contact_id)
SELECT id, contact_id FROM new_draft;
