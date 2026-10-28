-- 790 (2026-10-28) — one call to action on every year-round ad and the
-- free club post (owner: "can we just say 'Open Enrollment' and 'All Skill
-- Levels welcome'" … "for all ads and post").  Replaces "Join now — …"
-- and "Registration open".
UPDATE message_templates
   SET body = regexp_replace(body, E'\nJoin now — [^\n]*', E'\nOpen enrollment — all skill levels welcome.'),
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier IN ('youth-year-round', 'mens-year-round', 'womens-year-round');

UPDATE promotional_posts
   SET caption = replace(replace(caption,
         '— REGISTRATION OPEN', '— OPEN ENROLLMENT'),
         'All skill levels welcome. 🔗', 'Open enrollment — all skill levels welcome. 🔗'),
       updated_at = now()
 WHERE image_url LIKE '%club-year-round-post%' AND status = 'draft';
