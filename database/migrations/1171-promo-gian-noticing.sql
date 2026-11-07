-- 1171: Gian Maldonado promo (#17) — owner 2026-11-07: "The invitations
-- means others are noticing what we already know."  Opens the closing
-- paragraph.  Draft only.
UPDATE promotional_posts
   SET caption = replace(caption,
         E'Gian embodies the Lighthouse ethos:',
         E'The invitations mean others are noticing what we already know. Gian embodies the Lighthouse ethos:'),
       updated_at = now()
 WHERE image_url LIKE '%gian-maldonado-trials-2026-11%' AND status = 'draft'
   AND caption NOT LIKE '%noticing what we already know%';
