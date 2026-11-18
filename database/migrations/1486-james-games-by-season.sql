-- 1486 (2026-11-18) — James's game coaching by season, 2026-27 (owner: "for me
-- practice is consistent all year and games are half in fall and half in
-- spring. then i forgot in summer its u23 6 games and grass roots cup 3 games.
-- practices for them are same and rolled in so just games need account").
--   APSL, Liga 1: 22 each → 11 fall + 11 spring (was 12 + 10).
--   U23: 6 games in summer (Jun–Jul 2027), was spread over the whole year.
--   Cups: Grassroots 3 group games in summer; the Amateur Cup game (played,
--         lost 10/18) and the State Open Cup game stay in fall — 5 in all.
-- Practice is untouched: budget line 34, 7½ h a week all 52 weeks.
BEGIN;
UPDATE ref_fee_seasons SET home_games_expected = 11 WHERE id IN (14, 15, 16, 17);
UPDATE ref_fee_seasons SET label = 'Summer 2027', starts_on = '2027-06-01', ends_on = '2027-07-31',
       note = '6 games, no playoffs (owner 2026-11-13); summer (owner 2026-11-18)'
 WHERE id = 42 AND policy_id = 26;
UPDATE ref_fee_seasons SET label = 'Fall 2026', starts_on = '2026-08-01', ends_on = '2026-12-31', home_games_expected = 2,
       note = 'Amateur Cup 1 (lost 10/18), State Open Cup 1'
 WHERE id = 41 AND policy_id = 25;
INSERT INTO ref_fee_seasons (policy_id, label, starts_on, ends_on, home_games_expected, is_assumed, note)
SELECT 25, 'Summer 2027', '2027-06-01', '2027-07-31', 3, true, 'Grassroots Cup — 3 group games (owner 2026-11-18)'
 WHERE NOT EXISTS (SELECT 1 FROM ref_fee_seasons WHERE policy_id = 25 AND label = 'Summer 2027');
COMMIT;
