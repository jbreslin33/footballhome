-- G5.193 (game/DESIGN.md §8.299): a carrier never runs the ball over his own goal line. G5.141's edge turned a carry back
-- off the touchline and their goal line only; with G5.190's free hold (a free man in his own end keeps it up to 3 s
-- more) defenders unpressed (nearest of theirs 9-16 m) carried it over their own line at 5-8 m/s after 4-8 s on it:
-- corners "carried out" 0.5 → ~2.0 a team-match, and goals off them.
--   carry_edge_own 1 — within carry_edge_m (3 m) of his own goal line his carry line turns back in, as the others do
-- Rows, not code defaults: goldens unchanged.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'onball', 'carry_edge_own', 1, 'switch', 'G5.193 §8.299: the carry edge also turns him back off his own goal line (0 = G5.141: touchline and their line only)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
