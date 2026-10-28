-- 799 (2026-10-28) — how to register is its own line, near the top, so it
-- survives the "… more" cut (owner: "Needs to be clear!").  The card
-- carries the same words in a yellow bar.
UPDATE promotional_posts
   SET caption = replace(
         replace(caption, ' 🔗 Registration links in the Linktree in our bio.', ''),
         E'💵 $35/month membership — uniform included\n',
         E'👉 To register: tap the Linktree in our bio.\n💵 $35/month membership — uniform included\n'),
       updated_at = now()
 WHERE image_url LIKE '%club-year-round-post%' AND status = 'draft';
