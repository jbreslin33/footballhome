-- 1168: Gian Maldonado promo (#17) — owner 2026-11-07: "say that this is
-- part of the journey getting invited and to stay focused".  Sign-off
-- rewritten.  Draft only.
UPDATE promotional_posts
   SET caption = replace(caption,
         E'North Philly and the whole club are behind you, Gian! 💙',
         E'Every invite is a step on the journey. Stay focused and keep working, Gian. North Philly and the whole club are behind you! 💙'),
       updated_at = now()
 WHERE image_url LIKE '%gian-maldonado-trials-2026-11%' AND status = 'draft'
   AND caption NOT LIKE '%step on the journey%';
