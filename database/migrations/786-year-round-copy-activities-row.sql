-- 786 (2026-10-28) — the year-round cards drop the per-season activity
-- ("take out league games / training in the fall, winter, spring, summer.
-- Just put League Games, Training, Tournaments in its own cube").  The
-- captions follow: seasons on one line, the three activities on the next.
-- Winter keeps "indoor" (owner: "winter(indoor)").
UPDATE message_templates
   SET body = regexp_replace(body,
         '🍂 Fall[^\n]*\n❄️ Winter[^\n]*\n🌸 Spring[^\n]*\n☀️ Summer[^\n]*',
         E'🍂 Fall · ❄️ Winter (indoor) · 🌸 Spring · ☀️ Summer\n⚽ League games · 🎯 Training · 🏆 Tournaments'),
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier IN ('youth-year-round', 'mens-year-round', 'womens-year-round');
UPDATE promotional_posts
   SET caption = regexp_replace(caption,
         '🍂 Fall[^\n]*\n❄️ Winter[^\n]*\n🌸 Spring[^\n]*\n☀️ Summer[^\n]*',
         E'🍂 Fall · ❄️ Winter (indoor) · 🌸 Spring · ☀️ Summer\n⚽ League games · 🎯 Training · 🏆 Tournaments'),
       updated_at = now()
 WHERE image_url LIKE '%club-year-round-post%' AND status = 'draft';
