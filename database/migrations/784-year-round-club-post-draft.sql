-- 784 (2026-10-28) — free Instagram post, DRAFT only (owner: "make
-- identical post that says registration links in bio … all men, women,
-- boys and girls … Men 16+, Women 18+, Boys & Girls grades K-9").  Same
-- card as the year-round ads (scripts/generate-year-round-cards.js);
-- the owner reviews and posts it from #promotional-posts.
INSERT INTO promotional_posts (title, caption, image_url, status, heading)
SELECT 'Soccer all year round — every program, registration links in bio',
       E'⚽ SOCCER ALL YEAR ROUND — REGISTRATION OPEN\n\n👨 Men 16+\n👩 Women 18+\n👦👧 Boys & Girls · Grades K–9\n\nA full-year program:\n🍂 Fall — league games\n❄️ Winter — indoor\n🌸 Spring — league games\n☀️ Summer — training\n\nAll skill levels welcome. 🔗 Registration links in our bio.\n\nAmerica''s oldest active ⚽ club — a neighborhood club since 1893.\n\n📍 Lighthouse Sports Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer #MensSoccer #WomensSoccer',
       'https://footballhome.org/images/posts/club-year-round-post.png', 'draft',
       'Soccer all year round'
 WHERE NOT EXISTS (SELECT 1 FROM promotional_posts WHERE image_url LIKE '%club-year-round-post%');
