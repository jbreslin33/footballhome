-- 968 (2026-11-03) — APSL referee projection: 11 home games in 2026/27.
-- Owner 2026-11-03: "apsl will have 11 home games for refs".  The fall
-- schedule (TeamPass feed) has 6 home games, so spring is 5, no longer a guess.
UPDATE ref_fee_seasons
   SET home_games_expected = 11 - (SELECT home_games_expected FROM ref_fee_seasons WHERE policy_id = 1 AND label = 'Fall 2026'),
       is_assumed = false
 WHERE policy_id = 1 AND label = 'Spring 2027';
UPDATE ref_fee_policies SET note = 'Home games only; 11 home games in 2026/27 (owner 2026-11-03)' WHERE id = 1 AND kind = 'referee';
