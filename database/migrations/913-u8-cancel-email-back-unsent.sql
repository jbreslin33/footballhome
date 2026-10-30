-- The U8 cancellation draft (mig 910) was marked sent by opening Gmail, but
-- James never sent it.  Back to unsent with the fees line of mig 911, and the
-- three "sent" log rows of that click removed.
BEGIN;

UPDATE contact_email_drafts
   SET body = replace(body, 'Gordon, please take the referees off both games.',
                            'Gordon, please let us know any fees and where to send them.'),
       sent_at = NULL,
       updated_at = now()
 WHERE id = 2;

DELETE FROM club_contact_messages WHERE id IN (17, 18, 19) AND tier = 'draft' AND match_id = 9360;

COMMIT;
