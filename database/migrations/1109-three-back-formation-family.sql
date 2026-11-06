-- 1109 (2026-11-06) — The three-at-the-back family: one fixed "bowl",
-- the inside five name the shape.
--
-- Owner: "the 5 outer players are always the same in 3 in the back
-- formations. back line of 5,6,4 then wing backs of 3,2 ... the 'bowl'
-- in order from left to right is 3,5,6,4,2 then 'inside the bowl' are
-- the 10,8,11,7,9."  The bracket in the name is the inside five read
-- from the bottom of the bowl up (wing backs count as midfield):
--
--   3-4-3 (2-3)    10 8 / 11 9 7       "a pure 343 is basically 343(23)"
--   3-4-3 (2-2-1)  10 8 / 11 7 / 9     "bottom 10,8 then 11,7 then 9 at top"
--   3-5-2 (2-1-2)  10 8 / 9 / 11 7     "bottom of bowl 10,8 then 9 in middle
--                                       then up top 11,7"
--   3-5-2 (1-2-2)  8 / 10 9 / 11 7     "8 at bottom. then 10,9, then 11,7"
--   3-5-2 (3-2)    10 9 8 / 11 7       flat three (10 left of 8, 9 between)
--
-- "352(221) ... don't list that, list it as 343(221)" — same shape.
--
-- Rename, not new rows, for the two that exist (formation_id stays, so
-- saved games, drafts and formation_matchups keep pointing at them; no
-- game/ table carries either code).  The old 3-5-2 had 11 and 7 in
-- midfield and 10, 9 up top; the bowl rule makes 11 and 7 the front two,
-- so its numbers change.  The one lineup on it (match 9356) has no
-- player placed yet, so nobody moves.
--
-- `code` must match a FIELD_SIZES key in frontend/js/screens/
-- game-center.js — the picker shows the code.  positions_json uses the
-- mig-296 shirt-number scheme (positions.id = shirt number).

SELECT setval('formations_id_seq', (SELECT COALESCE(MAX(id), 1) FROM formations));

UPDATE formations SET code = '3-4-3 (2-3)', name = 'Classic 3-4-3 (2-3)'
 WHERE code = '3-4-3';

UPDATE formations SET code = '3-5-2 (3-2)', name = 'Classic 3-5-2 (3-2)',
  positions_json =
  '[{"x": 50, "y": 5,  "slot": 1,  "label": "GK",  "position_id": 1},
    {"x": 30, "y": 18, "slot": 2,  "label": "CB",  "position_id": 5},
    {"x": 50, "y": 15, "slot": 3,  "label": "CB",  "position_id": 6},
    {"x": 70, "y": 18, "slot": 4,  "label": "CB",  "position_id": 4},
    {"x": 6,  "y": 42, "slot": 5,  "label": "LWB", "position_id": 3},
    {"x": 30, "y": 42, "slot": 6,  "label": "CM",  "position_id": 10},
    {"x": 50, "y": 42, "slot": 7,  "label": "CM",  "position_id": 9},
    {"x": 70, "y": 42, "slot": 8,  "label": "CM",  "position_id": 8},
    {"x": 94, "y": 42, "slot": 9,  "label": "RWB", "position_id": 2},
    {"x": 35, "y": 70, "slot": 10, "label": "ST",  "position_id": 11},
    {"x": 65, "y": 70, "slot": 11, "label": "ST",  "position_id": 7}]'
 WHERE code = '3-5-2';

INSERT INTO formations (code, name, num_outfield, positions_json, sort_order) VALUES
(
  '3-4-3 (2-2-1)', 'Classic 3-4-3 (2-2-1)', 10,
  '[{"x": 50, "y": 5,  "slot": 1,  "label": "GK",  "position_id": 1},
    {"x": 30, "y": 18, "slot": 2,  "label": "CB",  "position_id": 5},
    {"x": 50, "y": 15, "slot": 3,  "label": "CB",  "position_id": 6},
    {"x": 70, "y": 18, "slot": 4,  "label": "CB",  "position_id": 4},
    {"x": 6,  "y": 38, "slot": 5,  "label": "LWB", "position_id": 3},
    {"x": 40, "y": 38, "slot": 6,  "label": "CM",  "position_id": 10},
    {"x": 60, "y": 38, "slot": 7,  "label": "CM",  "position_id": 8},
    {"x": 94, "y": 38, "slot": 8,  "label": "RWB", "position_id": 2},
    {"x": 35, "y": 56, "slot": 9,  "label": "AM",  "position_id": 11},
    {"x": 65, "y": 56, "slot": 10, "label": "AM",  "position_id": 7},
    {"x": 50, "y": 72, "slot": 11, "label": "ST",  "position_id": 9}]',
  13
),
(
  '3-5-2 (2-1-2)', 'Classic 3-5-2 (2-1-2)', 10,
  '[{"x": 50, "y": 5,  "slot": 1,  "label": "GK",  "position_id": 1},
    {"x": 30, "y": 18, "slot": 2,  "label": "CB",  "position_id": 5},
    {"x": 50, "y": 15, "slot": 3,  "label": "CB",  "position_id": 6},
    {"x": 70, "y": 18, "slot": 4,  "label": "CB",  "position_id": 4},
    {"x": 6,  "y": 38, "slot": 5,  "label": "LWB", "position_id": 3},
    {"x": 40, "y": 38, "slot": 6,  "label": "CM",  "position_id": 10},
    {"x": 60, "y": 38, "slot": 7,  "label": "CM",  "position_id": 8},
    {"x": 94, "y": 38, "slot": 8,  "label": "RWB", "position_id": 2},
    {"x": 50, "y": 56, "slot": 9,  "label": "CAM", "position_id": 9},
    {"x": 35, "y": 72, "slot": 10, "label": "ST",  "position_id": 11},
    {"x": 65, "y": 72, "slot": 11, "label": "ST",  "position_id": 7}]',
  14
),
(
  '3-5-2 (1-2-2)', 'Classic 3-5-2 (1-2-2)', 10,
  '[{"x": 50, "y": 5,  "slot": 1,  "label": "GK",  "position_id": 1},
    {"x": 30, "y": 18, "slot": 2,  "label": "CB",  "position_id": 5},
    {"x": 50, "y": 15, "slot": 3,  "label": "CB",  "position_id": 6},
    {"x": 70, "y": 18, "slot": 4,  "label": "CB",  "position_id": 4},
    {"x": 50, "y": 34, "slot": 5,  "label": "CDM", "position_id": 8},
    {"x": 6,  "y": 50, "slot": 6,  "label": "LWB", "position_id": 3},
    {"x": 38, "y": 50, "slot": 7,  "label": "CM",  "position_id": 10},
    {"x": 62, "y": 50, "slot": 8,  "label": "CM",  "position_id": 9},
    {"x": 94, "y": 50, "slot": 9,  "label": "RWB", "position_id": 2},
    {"x": 35, "y": 72, "slot": 10, "label": "ST",  "position_id": 11},
    {"x": 65, "y": 72, "slot": 11, "label": "ST",  "position_id": 7}]',
  15
)
ON CONFLICT (code) DO NOTHING;

-- Their 3-5-2 → our 3-5-2 (3-2) (mig 912): the note named the old numbers.
UPDATE formation_matchups
   SET note = '6 is the libero. 5, 4 take their two strikers. 3, 10, 9, 8, 2 take their five mids, 3 and 2 on the wing backs. 11, 7 press their back three, one is left free.'
 WHERE opponent_code = '3-5-2'
   AND formation_id = (SELECT id FROM formations WHERE code = '3-5-2 (3-2)');
