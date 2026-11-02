-- 924 (2026-11-01) — Instagram announcement, draft for review on
-- #promotional-posts (owner: "make a post for review that practice is
-- indoor at normal time tomorrow for youth players").  Times are the
-- calendar's own for Mon 11/2.  Image is
-- footballhome.org/images/posts/youth-practices-indoors-2026-11-02.jpg.
INSERT INTO promotional_posts (title, caption, image_url, status, heading)
SELECT 'Youth ⚽ practices are moving INDOORS — Mon 11/2',
       E'⚠️ Youth ⚽ practices are moving INDOORS\n\nBoys & Girls practice is indoors on Mon 11/2, same time as usual:\n\n⚽ Grades K-2: 4:30–5:30 PM\n⚽ Grades 3-10: 5:30–7:00 PM\n\n#Lighthouse1893 #PhillySoccer #LighthouseSportsComplex',
       'https://footballhome.org/images/posts/youth-practices-indoors-2026-11-02.jpg', 'draft',
       'Youth ⚽ practices are moving INDOORS'
 WHERE NOT EXISTS (SELECT 1 FROM promotional_posts WHERE image_url LIKE '%youth-practices-indoors-2026-11-02%');
