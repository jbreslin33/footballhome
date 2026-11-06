-- 1112 (2026-11-06) — First asymmetric shape: 3-5-2 (3-2) asym.
--
-- Owner: "we could play asymetrical. with him [Amir] as right sided
-- '10'/inside winger. and tolu at 9 and then the others behind them. can
-- we put asysmetrical formations in? so a 32 inside could be asymeticral
-- like described?"
--
-- Same bowl as the family (mig 1109: 3, 5, 6, 4, 2).  Inside five, bottom
-- up: 11 10 8 (the 11 drops into the midfield three, left side) / 9 dead
-- center + 7 in the right half-space.  The 7 is the inside winger / right
-- "10"; nobody stands in the left half-space up top.
--
-- FIELD_SIZES draws the front row as [0, 9, 7] — 0 = an empty column
-- (GAP_POS) so the 9 stays central.  `code` must match that key.
-- positions_json uses the mig-296 shirt-number scheme.

SELECT setval('formations_id_seq', (SELECT COALESCE(MAX(id), 1) FROM formations));

INSERT INTO formations (code, name, num_outfield, positions_json, sort_order) VALUES
(
  '3-5-2 (3-2) asym', 'Asymmetric 3-5-2 (3-2), 7 inside right', 10,
  '[{"x": 50, "y": 5,  "slot": 1,  "label": "GK",  "position_id": 1},
    {"x": 30, "y": 18, "slot": 2,  "label": "CB",  "position_id": 5},
    {"x": 50, "y": 15, "slot": 3,  "label": "CB",  "position_id": 6},
    {"x": 70, "y": 18, "slot": 4,  "label": "CB",  "position_id": 4},
    {"x": 6,  "y": 42, "slot": 5,  "label": "LWB", "position_id": 3},
    {"x": 30, "y": 42, "slot": 6,  "label": "LCM", "position_id": 11},
    {"x": 50, "y": 42, "slot": 7,  "label": "CM",  "position_id": 10},
    {"x": 70, "y": 42, "slot": 8,  "label": "RCM", "position_id": 8},
    {"x": 94, "y": 42, "slot": 9,  "label": "RWB", "position_id": 2},
    {"x": 50, "y": 72, "slot": 10, "label": "ST",  "position_id": 9},
    {"x": 68, "y": 64, "slot": 11, "label": "RIW", "position_id": 7}]',
  16
)
ON CONFLICT (code) DO NOTHING;
