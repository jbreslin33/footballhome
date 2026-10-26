-- 727 (2026-10-26) — Instagram announcement, ready to post from
-- #promotional-posts (owner: "All Lighthouse Soccer Practices moving
-- indoor today due to field Seeding and Watering" … "post it").  Image is
-- footballhome.org/images/posts/practices-indoors-2026-10-26.jpg.
INSERT INTO promotional_posts (title, caption, image_url, status, heading)
SELECT 'All ⚽ practices today are moving INDOORS — Mon 10/26',
       E'⚠️ All ⚽ practices today are moving INDOORS\n\nEvery Lighthouse practice — Men, Women, Boys & Girls — is indoors today, Mon 10/26.\n\n🌱 The fields are being seeded and watered, so we''re giving the grass a chance to grow in. 💧\n\n#Lighthouse1893 #PhillySoccer #LighthouseSportsComplex',
       'https://footballhome.org/images/posts/practices-indoors-2026-10-26.jpg', 'draft',
       'All ⚽ practices today are moving INDOORS'
 WHERE NOT EXISTS (SELECT 1 FROM promotional_posts WHERE image_url LIKE '%practices-indoors-2026-10-26%');
