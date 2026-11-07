-- 1169: Gian Maldonado promo (#17) — owner 2026-11-07: "the Lighthouse
-- Mens 1893 Player".  Draft only.
UPDATE promotional_posts
   SET caption = replace(caption,
         E'the Men''s 1893 player has been invited',
         E'the Lighthouse Men''s 1893 player has been invited'),
       updated_at = now()
 WHERE image_url LIKE '%gian-maldonado-trials-2026-11%' AND status = 'draft';
