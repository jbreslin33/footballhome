-- 1232: Men's and Women's teams carry no season (team_terms) rows, so the
-- #teams board shows them under every season pill, like USASA Cup.
-- Owner 2026-11-10: "for women and men its a continues fall, winter spring
-- really … reality is none have seasons its really league based but having
-- a season lets us move teams for next 'season' like winter and spring for
-- youth" — season pills are the youth planning tool; adults run straight
-- through.  Before this, the ❄️ Winter pill (current term) showed Mens and
-- Womens with 0 players.
--
-- team_terms only drives #teams columns (/api/teams/terms), the awards
-- board and the youth welcome team pick — not schedules or RSVPs.
-- Re-tag an adult team here later if its next season is ever planned ahead.
DELETE FROM team_terms
 WHERE team_id IN (
   35,    -- Lighthouse Mens Club 1893 (APSL)
   938,   -- Lighthouse Mens Club APSL Reserves
   120,   -- Lighthouse Mens Club Liga 1
   901    -- Lighthouse Womens Club 1895
 );
