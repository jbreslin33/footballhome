-- 2251 ⚽ Men's U23 and Puerto Rico teams, all year.
--
-- Owner 11/27: men are "basically 4 teams" — APSL and Liga 1 run all year,
-- U23 and grassroots Puerto Rico play June into July and are made up of
-- APSL / Liga 1 guys, so show all four at all times to prepare all year.
-- "dump all current u23 age players to u23 team and all non u23 players to
-- pr. for now" · U23 = under 23 on the current season-year chart (same FH
-- age as youth, fh_youth_us_age; doesn't flip until the new season) ·
-- roster members see the games (not call-up only).
--
-- • U23 (957) re-activated and un-archived; Puerto Rico created beside it.
--   Neither gets team_terms, so both show under every season pill like
--   APSL / Liga 1 (mig 1232). Youth keep their fall / winter / spring tags.
-- • Every active APSL (35), Liga 1 (120) and APSL Reserves (938) player gets
--   a SECOND team row — nobody leaves his league team: U23 when
--   fh_youth_us_age(birth_date) <= 23, else Puerto Rico. No birth date on
--   file → Puerto Rico (move him on the player sheet if he is U23).
-- Re-runnable.
BEGIN;

UPDATE teams SET is_active = true, board_archived_at = NULL, updated_at = now()
 WHERE id = 957;

INSERT INTO teams (club_id, name, slug, gender_category, roster_source, label, short_label,
                   color, is_active, club_section_id, field_size)
SELECT 134, 'Lighthouse Mens Club Puerto Rico', 'lighthouse-mens-club-puerto-rico', 'mens', 'direct',
       '🇵🇷 Puerto Rico', 'Puerto Rico', '#dc2626', true, 1, 11
 WHERE NOT EXISTS (SELECT 1 FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico');

-- Men's board columns need board_sort_order (MensTeamColumns): after Liga 1 (8).
-- No league roster list for either (internal squads).
UPDATE teams SET board_sort_order = 9,  league_roster = false WHERE id = 957;
UPDATE teams SET board_sort_order = 10, league_roster = false WHERE slug = 'lighthouse-mens-club-puerto-rico';

WITH men AS (
  SELECT DISTINCT tp.person_id
    FROM team_persons tp
   WHERE tp.team_id IN (35, 120, 938) AND tp.removed_at IS NULL
), dest AS (
  SELECT m.person_id,
         CASE WHEN p.birth_date IS NOT NULL AND fh_youth_us_age(p.birth_date) <= 23
              THEN 957
              ELSE (SELECT id FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico') END AS team_id
    FROM men m JOIN persons p ON p.id = m.person_id
)
INSERT INTO team_persons (team_id, person_id, roster_status_id)
SELECT d.team_id, d.person_id, 1          -- 1 = Not on Roster (internal club roster)
  FROM dest d
 WHERE NOT EXISTS (SELECT 1 FROM team_persons x
                    WHERE x.team_id = d.team_id AND x.person_id = d.person_id AND x.removed_at IS NULL);

INSERT INTO schema_migrations (filename) VALUES ('2251-mens-u23-and-puerto-rico-all-year.sql') ON CONFLICT DO NOTHING;
COMMIT;
