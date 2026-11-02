-- G5.4 (game/DESIGN.md §8.102): how often a pressed outfielder near his own goal
-- clears it, as a share of his open-play releases. StatsBomb Open Data, Premier
-- League 2015/16, all 380 matches. Box = under 18 m from his goal line, out =
-- 18-35 m; central = inside the six-yard box width plus 5 m a side.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('concept', 'pass-ladder', 'clear_box_central', 0.926, 'share', 'Pressed, under 18 m, central.'),
 ('concept', 'pass-ladder', 'clear_box_wide',    0.455, 'share', 'Pressed, under 18 m, wide.'),
 ('concept', 'pass-ladder', 'clear_out_central', 0.400, 'share', 'Pressed, 18-35 m, central.'),
 ('concept', 'pass-ladder', 'clear_out_wide',    0.305, 'share', 'Pressed, 18-35 m, wide.')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, note = EXCLUDED.note;
