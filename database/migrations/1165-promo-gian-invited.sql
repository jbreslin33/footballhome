-- 1165: Gian Maldonado promo (#17) — owner 2026-11-07: "Lets make it clear
-- he was invited on these trials."  Card lines re-rendered (Invited to trial
-- / Invited to play / Invited · on trial now); the caption's Bremer SV line
-- now says invited too (the other two already did).  Draft only.
UPDATE promotional_posts
   SET caption = replace(caption,
         E'🇩🇪 Trial in Germany with Bremer SV',
         E'🇩🇪 Invited to trial in Germany with Bremer SV'),
       updated_at = now()
 WHERE image_url LIKE '%gian-maldonado-trials-2026-11%' AND status = 'draft'
   AND caption NOT LIKE '%Invited to trial in Germany%';
