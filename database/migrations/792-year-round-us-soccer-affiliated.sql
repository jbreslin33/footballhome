-- 792 (2026-10-28) — captions say what the US Soccer badge on the cards
-- shows (owner: "add 'US Soccer affiliated' to the captions too" — to
-- separate the club from unaffiliated rec leagues).  True through EPSA /
-- EPYSA, US Soccer's state associations.  A line of its own after the
-- "Join anytime" line, on the three year-round ads and the free post.
UPDATE message_templates
   SET body = regexp_replace(body, E'(\nJoin anytime — [^\n]*)', E'\\1\n🇺🇸 US Soccer affiliated.'),
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier IN ('youth-year-round', 'mens-year-round', 'womens-year-round')
   AND body NOT LIKE '%US Soccer affiliated%';

UPDATE promotional_posts
   SET caption = regexp_replace(caption, E'(\nJoin anytime — [^\n]*)', E'\\1\n🇺🇸 US Soccer affiliated.'),
       updated_at = now()
 WHERE image_url LIKE '%club-year-round-post%' AND status = 'draft'
   AND caption NOT LIKE '%US Soccer affiliated%';
