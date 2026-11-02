-- Mig 941 (G5.4, game/DESIGN.md §8.102): how long a real player keeps it before
-- a pass, cumulative share. StatsBomb Open Data, Premier League 2015/16, Ball
-- Receipt to Pass, as benchmarked in game_benchmarks: 46.2 / 27.6 / 18.8 / 7.4%.
-- A man with time keeps the ball for his draw; pressed within press_m he may go.
-- The three [FH] rows are fits to pro numbers, not measured rates: replace them
-- when the model explains why (a carry and a cut pass are still rules).
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'tempo', 'hold_under1', 0.462, 'share', 'Passes played inside 1 s of receiving.'),
 ('physics', 'tempo', 'hold_under2', 0.738, 'share', 'Passes played inside 2 s of receiving.'),
 ('physics', 'tempo', 'hold_under4', 0.926, 'share', 'Passes played inside 4 s of receiving.'),
 ('physics', 'tempo', 'press_m', 1, 'm', 'A presser this close ends the hold. [FH] 1 m: at 2.5 m the hold barely held.'),
 ('physics', 'tempo', 'carry_share', 0.15, 'share', 'Share of his run while holding it. [FH] fitted: a real carry is ~5 m, gaining 2-3 m.'),
 ('physics', 'tempo', 'cut_share', 0.1, 'share', 'Share of their moving passes a man in reach takes. [FH] fitted to 7.2 interceptions a team.')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, note = EXCLUDED.note;
