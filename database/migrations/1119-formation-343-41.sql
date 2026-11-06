-- 1119 (2026-11-06) — 3-4-3 (4-1).
--
-- Owner: "we need a 343(41)".  Same bowl (mig 1109: 3, 5 6 4, 2; wing
-- backs ON the halfway line on the graphic).  Inside five bottom-up: a
-- flat four 11 10 8 7 (11 left, 10 left of 8, 7 right), then the 9 alone
-- up top — the 2-2-1 with the 11 and 7 dropped level with the 10 and 8;
-- they push on to make the front three.  `code` must match a FIELD_SIZES
-- key in frontend/js/screens/game-center.js.  positions_json: mig-296
-- shirt-number scheme.

SELECT setval('formations_id_seq', (SELECT COALESCE(MAX(id), 1) FROM formations));

INSERT INTO formations (code, name, num_outfield, positions_json, sort_order) VALUES
('3-4-3 (4-1)', 'Classic 3-4-3 (4-1)', 10, '[{"x": 50, "y": 5, "slot": 1, "label": "GK", "position_id": 1}, {"x": 30, "y": 18, "slot": 2, "label": "CB", "position_id": 5}, {"x": 50, "y": 15, "slot": 3, "label": "CB", "position_id": 6}, {"x": 70, "y": 18, "slot": 4, "label": "CB", "position_id": 4}, {"x": 6, "y": 46, "slot": 5, "label": "LWB", "position_id": 3}, {"x": 94, "y": 46, "slot": 6, "label": "RWB", "position_id": 2}, {"x": 20, "y": 58, "slot": 7, "label": "LM", "position_id": 11}, {"x": 40, "y": 58, "slot": 8, "label": "CM", "position_id": 10}, {"x": 60, "y": 58, "slot": 9, "label": "CM", "position_id": 8}, {"x": 80, "y": 58, "slot": 10, "label": "RM", "position_id": 7}, {"x": 50, "y": 76, "slot": 11, "label": "ST", "position_id": 9}]', 22)
ON CONFLICT (code) DO NOTHING;
