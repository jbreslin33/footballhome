-- The unsent cancellation drafts from mig 910: the ref assignor is asked for
-- any fees, not told to pull the referees.  A draft already sent stays as sent.
UPDATE contact_email_drafts
   SET body = replace(body, 'Gordon, please take the referees off this game.',
                            'Gordon, please let us know any fees and where to send them.'),
       updated_at = now()
 WHERE id IN (3, 4, 5) AND sent_at IS NULL;
