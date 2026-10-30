-- The unsent cancellation drafts from mig 910 lose their closing ask to the
-- league.  U8 says "them", the other three say "it".
UPDATE contact_email_drafts
   SET body = replace(replace(body,
         ' Let us know how the league would like to handle them from here.', ''),
         ' Let us know how the league would like to handle it from here.', ''),
       updated_at = now()
 WHERE id IN (2, 3, 4, 5) AND sent_at IS NULL;
