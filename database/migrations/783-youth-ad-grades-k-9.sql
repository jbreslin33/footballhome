-- 783 (2026-10-28) — youth is Grades K–9 (owner: "yes K-9, winter(indoor)").
-- PPR indoor runs U8–U15 (≈ 1st–9th grade) and U6 intramural takes
-- kindergartners, so the year-round youth ad and every youth lead's
-- follow-up say K–9 instead of 1–6.  The ad is rebuilt from these rows
-- (a Meta form/creative cannot be edited).  lead_program tiers keep their
-- historical funnel labels — only the wording a parent reads changes.
UPDATE message_templates SET body =
E'⚽ LIGHTHOUSE YOUTH SOCCER — ALL YEAR ROUND\n\nBoys & Girls · Grades K–9 · a full-year program:\n🍂 Fall — outdoor league\n❄️ Winter — indoor\n🌸 Spring — outdoor league\n☀️ Summer — training\n\nJoin now — all skill levels welcome.\n\nPhiladelphia''s oldest non-profit ⚽ club.\n\n📍 Lighthouse Sports Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer',
       updated_at = now()
 WHERE kind = 'meta_ad_caption' AND tier = 'youth-year-round';
UPDATE message_templates SET subject = 'Lighthouse Youth Soccer — Boys & Girls, Grades K–9',
       updated_at = now()
 WHERE kind = 'meta_context_card' AND tier = 'youth-year-round';
UPDATE message_templates SET body = replace(body, '(grades 1–6)', '(grades K–9)'), updated_at = now()
 WHERE kind = 'lead_program'
   AND tier IN ('Youth (Grades 1–6)', 'Boys Club (Grades 1–6)', 'Girls Club (Grades 1–6)');
