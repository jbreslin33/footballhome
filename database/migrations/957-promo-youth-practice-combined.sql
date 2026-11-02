-- Draft on #promo-posts replacing #15, which the owner deleted (owner 11/2):
-- all youth soccer combined 5:30-7 PM today, indoors, no spikes.  Image is
-- footballhome.org/images/posts/youth-practice-combined-2026-11-02.jpg.
INSERT INTO promotional_posts (title, caption, image_url, status, heading)
SELECT 'All youth ⚽ practice combined INDOORS — Mon 11/2',
       E'⚠️ TODAY: All youth ⚽ practice is combined and INDOORS\n\nBoys & Girls, Grades K-10, all practice together today, Mon 11/2:\n\n⚽ 5:30–7:00 PM\n\n👟 Wear sneakers — no spikes.\n\nPlease set your availability on footballhome.org so coaches can plan the session.\n\n#Lighthouse1893 #PhillySoccer #LighthouseSportsComplex',
       'https://footballhome.org/images/posts/youth-practice-combined-2026-11-02.jpg', 'draft',
       'All youth ⚽ practice combined INDOORS'
 WHERE NOT EXISTS (SELECT 1 FROM promotional_posts WHERE image_url LIKE '%youth-practice-combined-2026-11-02%');
