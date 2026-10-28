-- 797 (2026-10-28) — the price names what it buys: a membership (owner:
-- "yes membership", matching the LeagueApps "Membership" programme people
-- register for).  Ad captions + the free club post.  The lead-form intro
-- (meta_context_card) keeps "$35/month — uniform included": Meta forms are
-- immutable and the live forms already say it.
UPDATE message_templates
   SET body = replace(body, '💵 $35/month — uniform included', '💵 $35/month membership — uniform included'),
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier IN ('youth-year-round', 'mens-year-round', 'womens-year-round');

UPDATE promotional_posts
   SET caption = replace(caption, '💵 $35/month — uniform included', '💵 $35/month membership — uniform included'),
       updated_at = now()
 WHERE image_url LIKE '%club-year-round-post%' AND status = 'draft';
