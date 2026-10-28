-- 791 (2026-10-28) — "Open enrollment" reads like a window that closes;
-- the program runs all year, so the call to action is "Join anytime"
-- (owner: "yes join anytime").  Ads' captions + the free club post.
UPDATE message_templates
   SET body = replace(body, 'Open enrollment — all skill levels welcome.', 'Join anytime — all skill levels welcome.'),
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier IN ('youth-year-round', 'mens-year-round', 'womens-year-round');

UPDATE promotional_posts
   SET caption = replace(replace(caption,
         '— OPEN ENROLLMENT', '— JOIN ANYTIME'),
         'Open enrollment — all skill levels welcome.', 'Join anytime — all skill levels welcome.'),
       updated_at = now()
 WHERE image_url LIKE '%club-year-round-post%' AND status = 'draft';
