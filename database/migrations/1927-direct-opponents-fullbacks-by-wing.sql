-- 1927 (2026-11-26): direct opponents — full-backs on the winger on THEIR side.
-- Owner 11/26: "left back is 3. cb 5, 4 then right back 2. direct oppondnet of 3 is 7 the right wing and direct opp
-- of 2 is 11 the left wing. 6v10, 8v8, 9v4/5". The table had 2v7 / 3v11 (same-number sides = opposite touchlines);
-- the engine's touchline twin rule hid it in play, but the rows were wrong. Board numbers in 4-3-3 / 4-4-2 / 4-2-3-1
-- already match (LB 3, CB 5 left, CB 4 right, RB 2, RW 7, LW 11).
DELETE FROM game_direct_opponents WHERE (number, opponent_number) IN ((2, 7), (7, 2), (3, 11), (11, 3));
INSERT INTO game_direct_opponents (number, opponent_number, note) VALUES
  (3, 7, 'left back on their right wing (owner 11/26)'),
  (7, 3, ''),
  (2, 11, 'right back on their left wing (owner 11/26)'),
  (11, 2, '')
ON CONFLICT DO NOTHING;
