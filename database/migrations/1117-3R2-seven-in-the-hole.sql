-- 1117 (2026-11-06) — 3-5-2 (3-R2): the 7 drops into the hole.
--
-- Owner: "move 7 down further in the 352(3R2) put him where a 10 would
-- be in a 433", then "push the 3 in 32 higher lol. the apsl logo is in
-- way i get it. but just put the midfield line in graphic for pitch
-- lower."  The 7 leaves the front pair for his own band right of center,
-- at the height of the 4-3-3's attacking mids (10 / 8); the 11 stands
-- alone up top, centered; the midfield three (10 9 8) stand clear above
-- the halfway line.  Drawn in FIELD_SIZES (game-center.js): rows ...
-- [3, 10, 9, 8, 2], [0, 0, 7, 0], [11] with halfwayBelow: 2 (line + crest
-- under the midfield row).  Numbers unchanged, so Sunday's lineup (match
-- 9356) keeps everyone in his slot.  (Numbered 1117: a game session
-- claimed 1116 first.)

UPDATE formations SET positions_json = '[{"x": 50, "y": 5, "slot": 1, "label": "GK", "position_id": 1}, {"x": 30, "y": 18, "slot": 2, "label": "CB", "position_id": 5}, {"x": 50, "y": 15, "slot": 3, "label": "CB", "position_id": 6}, {"x": 70, "y": 18, "slot": 4, "label": "CB", "position_id": 4}, {"x": 6, "y": 40, "slot": 5, "label": "LWB", "position_id": 3}, {"x": 30, "y": 44, "slot": 6, "label": "CM", "position_id": 10}, {"x": 50, "y": 44, "slot": 7, "label": "CM", "position_id": 9}, {"x": 70, "y": 44, "slot": 8, "label": "CM", "position_id": 8}, {"x": 94, "y": 40, "slot": 9, "label": "RWB", "position_id": 2}, {"x": 60, "y": 58, "slot": 10, "label": "RAM", "position_id": 7}, {"x": 50, "y": 74, "slot": 11, "label": "ST", "position_id": 11}]' WHERE code = '3-5-2 (3-R2)';
