-- 519 (2026-10-03) — The Liga 1 team is "Lighthouse Mens Club Liga 1".
--
-- Owner, on the Liga 1 Instagram post: "insta says lighthouse boys club
-- liga 1. should say lightouse mens club liga 1 … same with all names for
-- liga 1 for us".  teams.name is what the Instagram graphics, their
-- captions and the #game-center header print; team 120 is in the Men's
-- section and still carried the old club name.  Same move as the first
-- team in mig 502: the roster-board label ("⚽ Liga 1") and the slug stay —
-- the label is the short board heading, the slug is in links — and so does
-- external_id, which is CASA's own key for the team.
UPDATE teams
   SET name = 'Lighthouse Mens Club Liga 1'
 WHERE id = 120
   AND name = 'Lighthouse Boys Club Liga 1';

-- Captions already saved on posts that have not gone out, for games still
-- to come, say the same.  Posted ones are history and stay as published.
UPDATE social_posts sp
   SET caption = replace(sp.caption, 'Lighthouse Boys Club Liga 1', 'Lighthouse Mens Club Liga 1'),
       updated_at = now()
  FROM matches m
 WHERE m.id = sp.match_id
   AND m.match_date >= CURRENT_DATE
   AND sp.status IN ('draft', 'scheduled')
   AND sp.caption LIKE '%Lighthouse Boys Club Liga 1%';
