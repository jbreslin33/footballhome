-- 1182 (2026-11-07) — Weekend slideshow slides move: the lighthouse beam
-- sweeps on every slide, as it does on the single posts.  Owner: "the light
-- of the lighthouse don't move on them in slide show".
--
-- The browser records one full beam sweep per slide (WebM); the backend
-- converts it to an MP4 padded to 1080×1350 and the carousel posts it as a
-- VIDEO item.  image_* stays: the still is the thumbnail and the fallback
-- when Instagram won't take a slide's video.
ALTER TABLE social_carousel_slides
  ADD COLUMN IF NOT EXISTS video_path TEXT,
  ADD COLUMN IF NOT EXISTS video_url  TEXT;

UPDATE message_templates SET body = '⏳ Recording the lighthouse on {count} slides (15 s)…'
 WHERE kind = 'weekend_slides' AND tier = 'building';
