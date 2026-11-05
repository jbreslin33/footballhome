-- 1106 (2026-11-05) — Two 4-2-3-1 variants: wide and narrow.
--
-- Owner: "make a 4231 wide and a 4231 narrow. the diff is the width of
-- the 7,11 and 2,3. a wide one will have the 7 and 11 wider. a narrow
-- will have the 2 and 3 wider and the 7 and 11 narrow."
--
--   4-2-3-1 wide   — 7 and 11 out on the touchlines (FIELD_SIZES
--                    wideIds [11, 7]); full backs as the plain 4-2-3-1.
--   4-2-3-1 narrow — 2 and 3 out on the touchlines (wideIds [3, 2]),
--                    7 and 11 tucked in beside the 10 (narrowIds
--                    [11, 7]).
--
-- Same numbers as the 4-2-3-1 (mig 296 shirt-number scheme, positions.id
-- = shirt number): 3 LB, 5 LCB, 4 RCB, 2 RB, 8 + 6 the CDMs left to
-- right, 11 / 10 / 7 the attacking three, 9 up top.  `code` must match
-- a FIELD_SIZES key in frontend/js/screens/game-center.js (the picker
-- lists those keys and saves by looking the code up here).
-- positions_json has no frontend consumer; x mirrors the drawn width.

SELECT setval('formations_id_seq', (SELECT COALESCE(MAX(id), 1) FROM formations));

INSERT INTO formations (code, name, num_outfield, positions_json, sort_order) VALUES
(
  '4-2-3-1 wide', 'Wide 4-2-3-1', 10,
  '[{"x": 50, "y": 5,  "slot": 1,  "label": "GK",  "position_id": 1},
    {"x": 15, "y": 22, "slot": 2,  "label": "LB",  "position_id": 3},
    {"x": 40, "y": 18, "slot": 3,  "label": "CB",  "position_id": 5},
    {"x": 60, "y": 18, "slot": 4,  "label": "CB",  "position_id": 4},
    {"x": 85, "y": 22, "slot": 5,  "label": "RB",  "position_id": 2},
    {"x": 40, "y": 35, "slot": 6,  "label": "CDM", "position_id": 8},
    {"x": 60, "y": 35, "slot": 7,  "label": "CDM", "position_id": 6},
    {"x": 6,  "y": 55, "slot": 8,  "label": "LW",  "position_id": 11},
    {"x": 50, "y": 55, "slot": 9,  "label": "CAM", "position_id": 10},
    {"x": 94, "y": 55, "slot": 10, "label": "RW",  "position_id": 7},
    {"x": 50, "y": 72, "slot": 11, "label": "ST",  "position_id": 9}]',
  11
),
(
  '4-2-3-1 narrow', 'Narrow 4-2-3-1', 10,
  '[{"x": 50, "y": 5,  "slot": 1,  "label": "GK",  "position_id": 1},
    {"x": 6,  "y": 22, "slot": 2,  "label": "LB",  "position_id": 3},
    {"x": 40, "y": 18, "slot": 3,  "label": "CB",  "position_id": 5},
    {"x": 60, "y": 18, "slot": 4,  "label": "CB",  "position_id": 4},
    {"x": 94, "y": 22, "slot": 5,  "label": "RB",  "position_id": 2},
    {"x": 40, "y": 35, "slot": 6,  "label": "CDM", "position_id": 8},
    {"x": 60, "y": 35, "slot": 7,  "label": "CDM", "position_id": 6},
    {"x": 32, "y": 55, "slot": 8,  "label": "LAM", "position_id": 11},
    {"x": 50, "y": 55, "slot": 9,  "label": "CAM", "position_id": 10},
    {"x": 68, "y": 55, "slot": 10, "label": "RAM", "position_id": 7},
    {"x": 50, "y": 72, "slot": 11, "label": "ST",  "position_id": 9}]',
  12
)
ON CONFLICT (code) DO NOTHING;
