-- 1166: Gian Maldonado promo (#17) — owner 2026-11-07: "Tampa Bay Rowdies
-- list as Trials too ... not friendly."  Card line re-rendered (Invited to
-- trial · Tampa Bay Rowdies); caption line likewise.  Draft only.
UPDATE promotional_posts
   SET caption = replace(caption,
         E'🇺🇸 Invited to play a friendly against the Tampa Bay Rowdies of the USL Championship',
         E'🇺🇸 Invited to trial with the Tampa Bay Rowdies of the USL Championship'),
       updated_at = now()
 WHERE image_url LIKE '%gian-maldonado-trials-2026-11%' AND status = 'draft';
