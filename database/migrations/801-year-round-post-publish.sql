-- 801 (2026-10-28; renumbered from 800 — another session took it) — publish the free year-round club post (owner: "post
-- it").  Scheduled for now; SocialController's scheduler publishes it to
-- Instagram on its next minute tick (publishPromoById).
UPDATE promotional_posts
   SET status = 'scheduled', scheduled_at = now(), updated_at = now()
 WHERE id = 14 AND status = 'draft' AND image_url LIKE '%club-year-round-post%';
