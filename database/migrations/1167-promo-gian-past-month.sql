-- 1167: Gian Maldonado promo (#17) — owner 2026-11-07: "Make it clear its
-- recent. Its all been in last month."  Card re-rendered with "In the past
-- month" over the three trials; caption says so too.  Draft only.
UPDATE promotional_posts
   SET caption = replace(replace(caption,
         E'— and now one of our Men''s 1893 players is taking his game around the world:',
         E'— and in the past month alone, the Men''s 1893 player has been invited to three trials:'),
         E'From the neighborhood to trials at home and abroad.',
         E'From the neighborhood to three trials at home and abroad in one month.'),
       updated_at = now()
 WHERE image_url LIKE '%gian-maldonado-trials-2026-11%' AND status = 'draft';
