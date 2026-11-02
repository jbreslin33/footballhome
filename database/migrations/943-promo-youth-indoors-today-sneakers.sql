-- Draft #15 on #promo-posts (owner 11/2): say today, wear sneakers, no spikes,
-- and set availability on footballhome.org so coaches can plan the session.
UPDATE promotional_posts
   SET title = 'Youth ⚽ practices TODAY are moving INDOORS — Mon 11/2',
       heading = 'Youth ⚽ practices TODAY are moving INDOORS',
       caption = E'⚠️ TODAY: Youth ⚽ practices are moving INDOORS\n\nBoys & Girls practice is indoors today, Mon 11/2, same time as usual:\n\n⚽ Grades K-2: 4:30–5:30 PM\n⚽ Grades 3-10: 5:30–7:00 PM\n\n👟 Wear sneakers — no spikes.\n\nPlease set your availability on footballhome.org so coaches can plan the session.\n\n#Lighthouse1893 #PhillySoccer #LighthouseSportsComplex',
       image_url = 'https://footballhome.org/images/posts/youth-practices-indoors-today-2026-11-02.jpg',
       updated_at = now()
 WHERE id = 15 AND status = 'draft';
