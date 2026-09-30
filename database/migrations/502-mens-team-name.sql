-- 502 (2026-09-30) — The men's first team carries the club name, not the league's.
--
-- Owner, on tonight's APSL Instagram post: "it should say Lighthouse Mens
-- Club 1893".  teams.name is what the Instagram graphics, their captions
-- and the #game-center header print, and it read "Lighthouse Mens Club
-- APSL" — the league, which the card already shows on its own line.  Same
-- move as the women's team in mig 387; 1893 is the men's section's own
-- founding year (club_sections.founded_year).  The roster-board label
-- ("🏆 APSL") and the slug stay: the label is the short board heading, the
-- slug is in links.  The Reserves team (938) keeps its name.
UPDATE teams
   SET name = 'Lighthouse Mens Club 1893'
 WHERE id = 35
   AND name = 'Lighthouse Mens Club APSL';

-- Captions already saved on posts that have not gone out, for games still
-- to come, say the same.  Posted ones are history and stay as published.
UPDATE social_posts sp
   SET caption = regexp_replace(sp.caption, 'Lighthouse Mens Club APSL(?! Reserves)', 'Lighthouse Mens Club 1893', 'g'),
       updated_at = now()
  FROM matches m
 WHERE m.id = sp.match_id
   AND m.match_date >= CURRENT_DATE
   AND sp.status IN ('draft', 'scheduled')
   AND sp.caption ~ 'Lighthouse Mens Club APSL(?! Reserves)';
