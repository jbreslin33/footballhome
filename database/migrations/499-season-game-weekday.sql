-- 499 (2026-09-29) — Which weekday a season's games fall on.  Owner, on
-- Jamie's Tri County games: "games are sundays".  With a weekday set, the
-- games a season still expects project one per that weekday still ahead
-- in the window (so a five-Sunday month carries five), instead of being
-- dealt evenly round the months.  NULL = no fixed weekday (dealt evenly,
-- as before).
ALTER TABLE ref_fee_seasons ADD COLUMN IF NOT EXISTS game_weekday SMALLINT CHECK (game_weekday BETWEEN 0 AND 6);   -- 0 = Sunday, as EXTRACT(DOW)
COMMENT ON COLUMN ref_fee_seasons.game_weekday IS 'Weekday the season''s games fall on (0 = Sunday); expected games not yet on a schedule project one per such day still ahead (mig 499). NULL = spread evenly.';
UPDATE ref_fee_seasons s SET game_weekday = 0
  FROM ref_fee_policies p
 WHERE p.id = s.policy_id AND p.club_id = 134 AND p.kind = 'coaching' AND p.label = 'Tri County';

-- Spring window: owner "you can do march to june" (mig 498 had April–June).
UPDATE ref_fee_seasons s SET starts_on = DATE '2027-03-01', ends_on = DATE '2027-06-30'
  FROM ref_fee_policies p
 WHERE p.id = s.policy_id AND p.club_id = 134 AND p.kind = 'coaching' AND p.label = 'Tri County' AND s.label = 'Spring 2027';
UPDATE ref_fee_policies SET note = 'Owner 2026-09-29: coach paid 2 h per game at the $15 coaching rate, home and away; 11 Sunday games Sep–Nov + 11 Sunday games Mar–Jun'
 WHERE club_id = 134 AND kind = 'coaching' AND label = 'Tri County';
