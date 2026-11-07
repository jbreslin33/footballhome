-- 1164: Gian Maldonado promo (#17) — owner 2026-11-07: "North Philly and
-- Lighthouse's own?"  Subheading (and the re-rendered card).  Draft only.
UPDATE promotional_posts
   SET subheading = 'North Philly and Lighthouse''s own', updated_at = now()
 WHERE image_url LIKE '%gian-maldonado-trials-2026-11%' AND status = 'draft';
