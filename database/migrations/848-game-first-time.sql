-- 848 (2026-10-29) — game: first-time kicks — the clearance, and one touch
-- when pressed (G4.95, game/DESIGN.md §8.93).
--
-- James 10/29: "yes" (shots next). Shots came from cheap own-third losses
-- (34 a team a match, pro 2.1); 44% of those were dispossessions, 74% of
-- them inside the receiver's control touch (G4.92), the taker
-- counter-pressing 69%. A real defender clears first time, and a pressed
-- receiver plays it first time (lay-off, wall pass): Orders::first_time ->
-- the World lets that kick go inside the touch at 1.5x the strike error
-- [FH]. 10 matches: own-third dispossessions 17 -> 5.4, spells 564 -> 441,
-- shots 64/60 -> 46/47 a team.

BEGIN;

UPDATE game_techniques SET status = 'wired' WHERE code IN ('def-clear-foot', 'pass-one-touch', 'recv-first-time');

INSERT INTO game_technique_sources (technique_id, source_id, citation, verified)
SELECT t.id, s.id, x.citation, true
  FROM (VALUES
    ('def-clear-foot', 'Orders::first_time on Why::Clear: no control touch, 1.5x the strike error (G4.95a) [FH]'),
    ('pass-one-touch', 'A ground pass inside his control touch with a man within 2.5 m goes first time (G4.95b) [FH]'),
    ('recv-first-time', 'As pass-one-touch: he plays it as it arrives instead of setting it (G4.95b) [FH]')
  ) AS x(code, citation)
  JOIN game_techniques t ON t.code = x.code
  JOIN game_sources s ON s.code = 'fh'
ON CONFLICT DO NOTHING;

COMMIT;
