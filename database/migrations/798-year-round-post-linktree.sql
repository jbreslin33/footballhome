-- 798 (2026-10-28) — the free club post names where the links are (owner:
-- "it needs to say registration links in Link tree in bio").
UPDATE promotional_posts
   SET caption = replace(caption, '🔗 Registration links in our bio.', '🔗 Registration links in the Linktree in our bio.'),
       updated_at = now()
 WHERE image_url LIKE '%club-year-round-post%' AND status = 'draft';
