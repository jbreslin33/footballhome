-- 387 — The women's team carries the club name, not the league's.
--
-- Owner 2026-09-19: "our team name for women should be Lighthouse
-- Womens Club 1895" — teams.name is what the Instagram graphics and the
-- #game-center header print, and it read "Tri County Women", which is
-- the league.  1895 is the women's section's own founding year (mens
-- 1893, boys 1897, girls 1895).  The roster-board label and the slug
-- stay: the label is the short board heading, the slug is in links.
UPDATE teams
   SET name = 'Lighthouse Womens Club 1895'
 WHERE id = 901
   AND name = 'Tri County Women';
