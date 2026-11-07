-- 1163: Gian Maldonado promo (#17) — owner 2026-11-07: "Gian embodies the
-- Lighthouse ethos of opportunity through hard work and practice."  Added
-- before the sign-off.  Draft only.
UPDATE promotional_posts
   SET caption = replace(caption,
         E'From the neighborhood to trials at home and abroad.',
         E'Gian embodies the Lighthouse ethos: opportunity through hard work and practice. From the neighborhood to trials at home and abroad.'),
       updated_at = now()
 WHERE image_url LIKE '%gian-maldonado-trials-2026-11%' AND status = 'draft'
   AND caption NOT LIKE '%Lighthouse ethos%';
