-- G5.261 (game/DESIGN.md §8.367): TACKLE ENDS. Where a real won tackle sends the ball (StatsBomb PL 15/16,
-- benchmarks_statsbomb_tackle_ends.py): next ball the tackler's side 57.3%, the carrier's in play 21.4%, the carrier's
-- restart 20.9% (knocked out). Out of play by m off the touchline: <5 m 50.5%, 5-12 26.0%, 12-20 12.2%, 20+ 4.2%.
-- Ours on G5.260 (fh-game-match TACKLE ENDS, seeds 1000-4000 x 8): 80.9 / 17.1 / 2.0%, and 0-9% out in every band —
-- the carrier and the tackler took the squirt back the next tick, 0.2-1.5 m from the tackle.
--   tackle_squirt_share: physics.tackle.clean of won tackles he comes away with (0.70 -> 0.25; real "Won" 23-27%).
--   tackle_recover_no_touch: the two men in the tackle are off balance and can't take the loose ball until up.
--   tackle_poke_away: the squirt leaves on the far side from the tackler (away from the foot that plays it).
--   physics.tackle.poke_mps 6 -> 15 (no tracking source for the squirt's pace: fitted to the out-of-play bands).
-- Read (seeds 1000-4000 x 8): next ball 80.9 / 17.1 / 2.0 -> 57.3 / 26.4 / 16.4%; out by band 52 / 30 / 18 / 3.8%;
-- take-ons tried 16.2 -> 13.0 (18.05), completed 9.35 -> 9.73 (10.59); fouls 13.5 -> 13.1 (12.5); passes 424 -> 418
-- (434); goals 2.13 -> 2.11 (1.35); throw-ins 20.7 -> 21.7 (19.9).
INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
VALUES
 ('tackle_squirt_share', 'game/src/core/World.cpp', 1, 'tackle ends 11/25', 'individual',
  'A won tackle knocks the ball loose more often than the tackler comes away with it: physics.tackle.clean of won tackles are his at once, the rest squirt off the tackle.',
  'unnamed', NULL, 'engage-or-contain', NULL, 'high', false, true),
 ('tackle_recover_no_touch', 'game/src/core/World.cpp', 1, 'tackle ends 11/25', 'individual',
  'The two men in a tackle are off balance — the dispossessed carrier, the tackler down in it, a tackler beaten — and neither gets a foot to the loose ball until he is up.',
  'unnamed', NULL, 'engage-or-contain', NULL, 'high', false, true),
 ('tackle_poke_away', 'game/src/core/World.cpp', 1, 'tackle ends 11/25', 'individual',
  'The ball off a tackle goes away from the foot that plays it: the squirt leaves on the far side from the tackler, so a tackle made from inside a man by the touchline knocks it out.',
  'unnamed', NULL, 'engage-or-contain', NULL, 'high', false, true)
ON CONFLICT (code) DO NOTHING;
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'tackle', 'clean', 0.25, 'share', 'G5.261 §8.367: won tackles the tackler comes away with (no row = 0.70, G4.24); the rest squirt'),
 ('physics', 'tackle', 'recover_no_touch', 1, 'on', 'G5.261 §8.367: men recovering from a tackle cannot take the loose ball (no row = 0, they can)'),
 ('physics', 'tackle', 'poke_away', 1, 'share', 'G5.261 §8.367: share of squirts sent away from the tackler''s side (no row = 0, side by noise)'),
 ('physics', 'tackle', 'poke_mps', 15, 'm/s', 'G5.261 §8.367: the squirt''s pace (no row = 6, kTacklePokeSpeed), fitted to out of play by m off the touchline')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
