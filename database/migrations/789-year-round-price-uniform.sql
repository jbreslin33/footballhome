-- 789 (2026-10-28) — the year-round ads put the cost up front (owner:
-- "yes do it, $35/month uniform included").  $35 is the club-wide
-- dues_policies rate, the same for every section.  The price is the
-- caption's second line so it survives Instagram's "… more" cut; the
-- lead form intro says it too (the year-round forms are rebuilt — Meta
-- forms are immutable), and the free club post follows.
UPDATE message_templates
   SET body = regexp_replace(body, '^([^\n]*)\n\n', E'\\1\n\n💵 $35/month — uniform included\n\n'),
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier IN ('youth-year-round', 'mens-year-round', 'womens-year-round')
   AND body NOT LIKE '%$35/month%';

UPDATE message_templates
   SET body = E'$35/month — uniform included\n'
              || replace(replace(body,
                   'training times, fees, and next steps', 'training times and next steps'),
                   'season dates, fees, and next steps', 'season dates and next steps'),
       updated_at = now()
 WHERE kind = 'meta_context_card' AND tier IN ('youth-year-round', 'mens-year-round', 'womens-year-round')
   AND body NOT LIKE '%$35/month%';

UPDATE promotional_posts
   SET caption = regexp_replace(caption, '^([^\n]*)\n\n', E'\\1\n\n💵 $35/month — uniform included\n\n'),
       updated_at = now()
 WHERE image_url LIKE '%club-year-round-post%' AND status = 'draft'
   AND caption NOT LIKE '%$35/month%';
