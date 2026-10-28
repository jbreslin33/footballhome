-- 796 (2026-10-28) — the activities line loses its icons (owner: "don't
-- like target for training. do we need logos like ball and trophy for
-- these?").  Cards are text only; the captions follow.
UPDATE message_templates
   SET body = replace(body, '⚽ League games · 🎯 Training · 🏆 Tournaments', 'League games · Training · Tournaments'),
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier IN ('youth-year-round', 'mens-year-round', 'womens-year-round');

UPDATE promotional_posts
   SET caption = replace(caption, '⚽ League games · 🎯 Training · 🏆 Tournaments', 'League games · Training · Tournaments'),
       updated_at = now()
 WHERE image_url LIKE '%club-year-round-post%' AND status = 'draft';
