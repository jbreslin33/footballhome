-- The U8 cancellation draft was marked sent again by opening Gmail, and James
-- has not sent it.  Back to unsent without the league line (mig 914), and that
-- click's three "sent" log rows removed.  Buttons no longer mark sent.
BEGIN;

UPDATE contact_email_drafts
   SET body = replace(body, ' Let us know how the league would like to handle them from here.', ''),
       sent_at = NULL,
       updated_at = now()
 WHERE id = 2;

DELETE FROM club_contact_messages WHERE id IN (20, 21, 22) AND tier = 'draft' AND match_id = 9360;

COMMIT;
