-- 611 (2026-10-19) — Two new 11v11 formations: 3-4-3 and 3-3-1-3.
--
-- Owner: both drop the 6 into the back line (back three reads 5-6-4
-- left to right).  The flat 3-4-3 keeps the 8 and 10 balanced in the
-- middle of the midfield four (10 left, same rule as the 4-3-3), with
-- the 3 and 2 as the wide men.  The 3-3-1-3 ("its really a 3313") is
-- the I-formation look: 8 where a 6 would normally be, 10 behind the
-- 9 and in front of the 8 — the 8-10-9 spine stacks like an
-- American-football I.  In both, the 2 and 3 sit at the same height
-- as the 8, directly in front of the 4-5-6 back line.
--
-- `code` must match a FIELD_SIZES key in frontend/js/screens/
-- game-center.js — the picker lists the map's keys and saves by
-- looking the code up in this table (EligibilityController ships
-- id+code).  positions_json position_id values use the mig-296
-- shirt-number scheme (positions.id = shirt number), which is why the
-- central CB here is position_id 6 (Defensive Midfielder): that IS
-- the 6 playing in the back line.

-- The seed rows were inserted with explicit ids, so the sequence still
-- points at 1 — sync it before relying on the default.
SELECT setval('formations_id_seq', (SELECT COALESCE(MAX(id), 1) FROM formations));

INSERT INTO formations (code, name, num_outfield, positions_json, sort_order) VALUES
(
  '3-4-3', 'Classic 3-4-3', 10,
  '[{"x": 50, "y": 5,  "slot": 1,  "label": "GK", "position_id": 1},
    {"x": 30, "y": 18, "slot": 2,  "label": "CB", "position_id": 5},
    {"x": 50, "y": 15, "slot": 3,  "label": "CB", "position_id": 6},
    {"x": 70, "y": 18, "slot": 4,  "label": "CB", "position_id": 4},
    {"x": 12, "y": 42, "slot": 5,  "label": "LM", "position_id": 3},
    {"x": 40, "y": 42, "slot": 6,  "label": "CM", "position_id": 10},
    {"x": 60, "y": 42, "slot": 7,  "label": "CM", "position_id": 8},
    {"x": 88, "y": 42, "slot": 8,  "label": "RM", "position_id": 2},
    {"x": 20, "y": 65, "slot": 9,  "label": "LW", "position_id": 11},
    {"x": 50, "y": 70, "slot": 10, "label": "ST", "position_id": 9},
    {"x": 80, "y": 65, "slot": 11, "label": "RW", "position_id": 7}]',
  5
),
(
  '3-3-1-3', 'I-Formation 3-3-1-3', 10,
  '[{"x": 50, "y": 5,  "slot": 1,  "label": "GK",  "position_id": 1},
    {"x": 30, "y": 18, "slot": 2,  "label": "CB",  "position_id": 5},
    {"x": 50, "y": 15, "slot": 3,  "label": "CB",  "position_id": 6},
    {"x": 70, "y": 18, "slot": 4,  "label": "CB",  "position_id": 4},
    {"x": 12, "y": 36, "slot": 5,  "label": "LWB", "position_id": 3},
    {"x": 50, "y": 36, "slot": 6,  "label": "CDM", "position_id": 8},
    {"x": 88, "y": 36, "slot": 7,  "label": "RWB", "position_id": 2},
    {"x": 50, "y": 54, "slot": 8,  "label": "CAM", "position_id": 10},
    {"x": 20, "y": 68, "slot": 9,  "label": "LW",  "position_id": 11},
    {"x": 50, "y": 72, "slot": 10, "label": "ST",  "position_id": 9},
    {"x": 80, "y": 68, "slot": 11, "label": "RW",  "position_id": 7}]',
  6
)
ON CONFLICT (code) DO NOTHING;
