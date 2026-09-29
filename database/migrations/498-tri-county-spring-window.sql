-- 498 (2026-09-29) — Jamie's game hours: 11 games in the fall, September
-- through November, and 11 in the spring, April through June, 2 h each.
-- Owner: "jamie should get 11 games in fall from september through
-- november and 11 games in spring from april to june. 2 hours each game".
-- Fall 2026 already runs 9/1–11/30 (mig 494); Spring 2027 moves from
-- 3/1–6/15 to 4/1–6/30.
UPDATE ref_fee_seasons s SET starts_on = DATE '2027-04-01', ends_on = DATE '2027-06-30', home_games_expected = 11
  FROM ref_fee_policies p
 WHERE p.id = s.policy_id AND p.club_id = 134 AND p.kind = 'coaching' AND p.label = 'Tri County' AND s.label = 'Spring 2027';
UPDATE ref_fee_seasons s SET starts_on = DATE '2026-09-01', ends_on = DATE '2026-11-30', home_games_expected = 11
  FROM ref_fee_policies p
 WHERE p.id = s.policy_id AND p.club_id = 134 AND p.kind = 'coaching' AND p.label = 'Tri County' AND s.label = 'Fall 2026';
UPDATE ref_fee_policies SET hours_per_game = 2.00, per_game_usd = ROUND(2.00 * rate_per_hour, 2),
       note = 'Owner 2026-09-29: coach paid 2 h per game at the $15 coaching rate, home and away; 11 games Sep–Nov + 11 games Apr–Jun'
 WHERE club_id = 134 AND kind = 'coaching' AND label = 'Tri County';
