-- 422 — James's footballhome.org mailbox as his primary contact email.
--
-- 2026-09-24: the lock-up alert emails to soccer@lighthouse1893.org were
-- accepted by Postmark and then bounced (error 412): while the Postmark
-- account is pending approval, recipients must share the From domain
-- (footballhome.org).  Every FH email to another domain since 9/15 went
-- the same way.  Until Postmark approves the account, James is reached at
-- jbreslin@footballhome.org (the Workspace mailbox FH already uses as
-- MAIL_REPLY_TO).  Primary so the lock-up recipient query picks it first;
-- the lighthouse1893.org address stays on the record.
INSERT INTO person_emails (person_id, email, email_type_id, is_primary, is_verified)
SELECT 1, 'jbreslin@footballhome.org',
       (SELECT id FROM email_types ORDER BY id LIMIT 1), true, true
 WHERE NOT EXISTS (SELECT 1 FROM person_emails WHERE person_id = 1 AND lower(email) = 'jbreslin@footballhome.org');
UPDATE person_emails SET is_primary = (lower(email) = 'jbreslin@footballhome.org') WHERE person_id = 1;
