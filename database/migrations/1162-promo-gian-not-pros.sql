-- 1162: Gian Maldonado promo (#17) — owner 2026-11-07: "We should not say
-- to the pros as it looks like he made a pro team."  Subheading (and the
-- re-rendered card) now read "North Philly's own".  Draft only.
UPDATE promotional_posts
   SET subheading = 'North Philly''s own', updated_at = now()
 WHERE image_url LIKE '%gian-maldonado-trials-2026-11%' AND status = 'draft';
