-- 1114 (2026-11-06) — More asymmetric 3-5-2s: R and L of every shape
-- with a front two.
--
-- Owner: "make more asymetric formations" (after mig 1113's code rule:
-- an R/L before a row in the bracket = that row sits right/left of
-- center).  One rule for all of them: the 9 stays the central striker,
-- the wide number on the named side (7 for R, 11 for L) plays inside
-- forward beside him, and the other wide number drops into the row
-- below.  Bowl unchanged (mig 1109: 3, 5, 6, 4, 2).
--
--   3-5-2 (3-L2)    10 8 7 / 11 9 .
--   3-5-2 (1-2-R2)  8 / 11 10 / . 9 7
--   3-5-2 (1-2-L2)  8 / 10 7 / 11 9 .
--   3-5-2 (2-1-R2)  10 8 / 11 / . 9 7
--   3-5-2 (2-1-L2)  10 8 / 7 / 11 9 .
--
-- (3-5-2 (3-R2) is mig 1112/1113.)  The 3-4-3s have a front three or a
-- lone 9, so nothing to set off-center.  `code` must match a FIELD_SIZES
-- key in frontend/js/screens/game-center.js ('.' = a 0 / GAP_POS empty
-- column there).  positions_json: mig-296 shirt-number scheme.

SELECT setval('formations_id_seq', (SELECT COALESCE(MAX(id), 1) FROM formations));

INSERT INTO formations (code, name, num_outfield, positions_json, sort_order) VALUES
('3-5-2 (3-L2)', 'Asymmetric 3-5-2 (3-L2)', 10, '[{"x": 50, "y": 5, "slot": 1, "label": "GK", "position_id": 1}, {"x": 30, "y": 18, "slot": 2, "label": "CB", "position_id": 5}, {"x": 50, "y": 15, "slot": 3, "label": "CB", "position_id": 6}, {"x": 70, "y": 18, "slot": 4, "label": "CB", "position_id": 4}, {"x": 6, "y": 42, "slot": 5, "label": "LWB", "position_id": 3}, {"x": 30, "y": 42, "slot": 6, "label": "LCM", "position_id": 10}, {"x": 50, "y": 42, "slot": 7, "label": "CM", "position_id": 8}, {"x": 70, "y": 42, "slot": 8, "label": "RCM", "position_id": 7}, {"x": 94, "y": 42, "slot": 9, "label": "RWB", "position_id": 2}, {"x": 32, "y": 64, "slot": 10, "label": "LIW", "position_id": 11}, {"x": 50, "y": 72, "slot": 11, "label": "ST", "position_id": 9}]', 17),
('3-5-2 (1-2-R2)', 'Asymmetric 3-5-2 (1-2-R2)', 10, '[{"x": 50, "y": 5, "slot": 1, "label": "GK", "position_id": 1}, {"x": 30, "y": 18, "slot": 2, "label": "CB", "position_id": 5}, {"x": 50, "y": 15, "slot": 3, "label": "CB", "position_id": 6}, {"x": 70, "y": 18, "slot": 4, "label": "CB", "position_id": 4}, {"x": 50, "y": 34, "slot": 5, "label": "CDM", "position_id": 8}, {"x": 6, "y": 50, "slot": 6, "label": "LWB", "position_id": 3}, {"x": 38, "y": 50, "slot": 7, "label": "CM", "position_id": 11}, {"x": 62, "y": 50, "slot": 8, "label": "CM", "position_id": 10}, {"x": 94, "y": 50, "slot": 9, "label": "RWB", "position_id": 2}, {"x": 50, "y": 72, "slot": 10, "label": "ST", "position_id": 9}, {"x": 68, "y": 64, "slot": 11, "label": "RIW", "position_id": 7}]', 18),
('3-5-2 (1-2-L2)', 'Asymmetric 3-5-2 (1-2-L2)', 10, '[{"x": 50, "y": 5, "slot": 1, "label": "GK", "position_id": 1}, {"x": 30, "y": 18, "slot": 2, "label": "CB", "position_id": 5}, {"x": 50, "y": 15, "slot": 3, "label": "CB", "position_id": 6}, {"x": 70, "y": 18, "slot": 4, "label": "CB", "position_id": 4}, {"x": 50, "y": 34, "slot": 5, "label": "CDM", "position_id": 8}, {"x": 6, "y": 50, "slot": 6, "label": "LWB", "position_id": 3}, {"x": 38, "y": 50, "slot": 7, "label": "CM", "position_id": 10}, {"x": 62, "y": 50, "slot": 8, "label": "CM", "position_id": 7}, {"x": 94, "y": 50, "slot": 9, "label": "RWB", "position_id": 2}, {"x": 32, "y": 64, "slot": 10, "label": "LIW", "position_id": 11}, {"x": 50, "y": 72, "slot": 11, "label": "ST", "position_id": 9}]', 19),
('3-5-2 (2-1-R2)', 'Asymmetric 3-5-2 (2-1-R2)', 10, '[{"x": 50, "y": 5, "slot": 1, "label": "GK", "position_id": 1}, {"x": 30, "y": 18, "slot": 2, "label": "CB", "position_id": 5}, {"x": 50, "y": 15, "slot": 3, "label": "CB", "position_id": 6}, {"x": 70, "y": 18, "slot": 4, "label": "CB", "position_id": 4}, {"x": 6, "y": 38, "slot": 5, "label": "LWB", "position_id": 3}, {"x": 40, "y": 38, "slot": 6, "label": "CM", "position_id": 10}, {"x": 60, "y": 38, "slot": 7, "label": "CM", "position_id": 8}, {"x": 94, "y": 38, "slot": 8, "label": "RWB", "position_id": 2}, {"x": 50, "y": 54, "slot": 9, "label": "CAM", "position_id": 11}, {"x": 50, "y": 72, "slot": 10, "label": "ST", "position_id": 9}, {"x": 68, "y": 64, "slot": 11, "label": "RIW", "position_id": 7}]', 20),
('3-5-2 (2-1-L2)', 'Asymmetric 3-5-2 (2-1-L2)', 10, '[{"x": 50, "y": 5, "slot": 1, "label": "GK", "position_id": 1}, {"x": 30, "y": 18, "slot": 2, "label": "CB", "position_id": 5}, {"x": 50, "y": 15, "slot": 3, "label": "CB", "position_id": 6}, {"x": 70, "y": 18, "slot": 4, "label": "CB", "position_id": 4}, {"x": 6, "y": 38, "slot": 5, "label": "LWB", "position_id": 3}, {"x": 40, "y": 38, "slot": 6, "label": "CM", "position_id": 10}, {"x": 60, "y": 38, "slot": 7, "label": "CM", "position_id": 8}, {"x": 94, "y": 38, "slot": 8, "label": "RWB", "position_id": 2}, {"x": 50, "y": 54, "slot": 9, "label": "CAM", "position_id": 7}, {"x": 32, "y": 64, "slot": 10, "label": "LIW", "position_id": 11}, {"x": 50, "y": 72, "slot": 11, "label": "ST", "position_id": 9}]', 21)
ON CONFLICT (code) DO NOTHING;
