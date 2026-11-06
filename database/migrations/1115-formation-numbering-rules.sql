-- 1115 (2026-11-06) — Owner numbering rules for every formation:
--
--   "always 11 and 7 if 2 man front" ... "then 9 goes into 'mid field'"
--   "9 is always middle of 10 and 8 but 9 would be the 1 in a 122"
--   "always put striker a little higher up then 'wingers' or inside
--    wingers" (drawn: FIELD_SIZES chipLifts in game-center.js)
--   "this is for all games/formations"
--
-- In the three-back family (mig 1109) that changes:
--   3-5-2 (1-2-2)  8 / 10 9 / 11 7   →  9 / 10 8 / 11 7
--   the asymmetric R2/L2 shapes (migs 1112–1114) were "9 central + one
--   wide man, the other drops"; now each is its symmetric shape with the
--   11-7 pair shifted: R2 = . 11 7 (11 the central striker, 7 inside
--   right), L2 = 11 7 . (7 central, 11 inside left).
--     3-R2 / 3-L2      10 9 8 / pair
--     1-2-R2 / 1-2-L2  9 / 10 8 / pair
--     2-1-R2 / 2-1-L2  10 8 / 9 / pair
--
-- Sunday's APSL lineup (match 9356) is on 3-R2 and placed: Andy Hizdri
-- 11 (left of the three), Luke Breslin 10 (center), Tolu Asekun-Masha 9
-- (central striker).  Same spots on the new numbers: Andy → 10, Luke →
-- 9, Tolu → 11 — nobody moves on the pitch.  No bench shares, set-piece
-- picks or drafts point at those slots.

UPDATE formations SET positions_json = '[{"x": 50, "y": 5, "slot": 1, "label": "GK", "position_id": 1}, {"x": 30, "y": 18, "slot": 2, "label": "CB", "position_id": 5}, {"x": 50, "y": 15, "slot": 3, "label": "CB", "position_id": 6}, {"x": 70, "y": 18, "slot": 4, "label": "CB", "position_id": 4}, {"x": 50, "y": 34, "slot": 5, "label": "CDM", "position_id": 9}, {"x": 6, "y": 50, "slot": 6, "label": "LWB", "position_id": 3}, {"x": 38, "y": 50, "slot": 7, "label": "CM", "position_id": 10}, {"x": 62, "y": 50, "slot": 8, "label": "CM", "position_id": 8}, {"x": 94, "y": 50, "slot": 9, "label": "RWB", "position_id": 2}, {"x": 35, "y": 72, "slot": 10, "label": "ST", "position_id": 11}, {"x": 65, "y": 72, "slot": 11, "label": "ST", "position_id": 7}]' WHERE code = '3-5-2 (1-2-2)';
UPDATE formations SET positions_json = '[{"x": 50, "y": 5, "slot": 1, "label": "GK", "position_id": 1}, {"x": 30, "y": 18, "slot": 2, "label": "CB", "position_id": 5}, {"x": 50, "y": 15, "slot": 3, "label": "CB", "position_id": 6}, {"x": 70, "y": 18, "slot": 4, "label": "CB", "position_id": 4}, {"x": 6, "y": 42, "slot": 5, "label": "LWB", "position_id": 3}, {"x": 30, "y": 42, "slot": 6, "label": "CM", "position_id": 10}, {"x": 50, "y": 42, "slot": 7, "label": "CM", "position_id": 9}, {"x": 70, "y": 42, "slot": 8, "label": "CM", "position_id": 8}, {"x": 94, "y": 42, "slot": 9, "label": "RWB", "position_id": 2}, {"x": 50, "y": 74, "slot": 10, "label": "ST", "position_id": 11}, {"x": 68, "y": 68, "slot": 11, "label": "RIW", "position_id": 7}]' WHERE code = '3-5-2 (3-R2)';
UPDATE formations SET positions_json = '[{"x": 50, "y": 5, "slot": 1, "label": "GK", "position_id": 1}, {"x": 30, "y": 18, "slot": 2, "label": "CB", "position_id": 5}, {"x": 50, "y": 15, "slot": 3, "label": "CB", "position_id": 6}, {"x": 70, "y": 18, "slot": 4, "label": "CB", "position_id": 4}, {"x": 6, "y": 42, "slot": 5, "label": "LWB", "position_id": 3}, {"x": 30, "y": 42, "slot": 6, "label": "CM", "position_id": 10}, {"x": 50, "y": 42, "slot": 7, "label": "CM", "position_id": 9}, {"x": 70, "y": 42, "slot": 8, "label": "CM", "position_id": 8}, {"x": 94, "y": 42, "slot": 9, "label": "RWB", "position_id": 2}, {"x": 32, "y": 68, "slot": 10, "label": "LIW", "position_id": 11}, {"x": 50, "y": 74, "slot": 11, "label": "ST", "position_id": 7}]' WHERE code = '3-5-2 (3-L2)';
UPDATE formations SET positions_json = '[{"x": 50, "y": 5, "slot": 1, "label": "GK", "position_id": 1}, {"x": 30, "y": 18, "slot": 2, "label": "CB", "position_id": 5}, {"x": 50, "y": 15, "slot": 3, "label": "CB", "position_id": 6}, {"x": 70, "y": 18, "slot": 4, "label": "CB", "position_id": 4}, {"x": 50, "y": 34, "slot": 5, "label": "CDM", "position_id": 9}, {"x": 6, "y": 50, "slot": 6, "label": "LWB", "position_id": 3}, {"x": 38, "y": 50, "slot": 7, "label": "CM", "position_id": 10}, {"x": 62, "y": 50, "slot": 8, "label": "CM", "position_id": 8}, {"x": 94, "y": 50, "slot": 9, "label": "RWB", "position_id": 2}, {"x": 50, "y": 74, "slot": 10, "label": "ST", "position_id": 11}, {"x": 68, "y": 68, "slot": 11, "label": "RIW", "position_id": 7}]' WHERE code = '3-5-2 (1-2-R2)';
UPDATE formations SET positions_json = '[{"x": 50, "y": 5, "slot": 1, "label": "GK", "position_id": 1}, {"x": 30, "y": 18, "slot": 2, "label": "CB", "position_id": 5}, {"x": 50, "y": 15, "slot": 3, "label": "CB", "position_id": 6}, {"x": 70, "y": 18, "slot": 4, "label": "CB", "position_id": 4}, {"x": 50, "y": 34, "slot": 5, "label": "CDM", "position_id": 9}, {"x": 6, "y": 50, "slot": 6, "label": "LWB", "position_id": 3}, {"x": 38, "y": 50, "slot": 7, "label": "CM", "position_id": 10}, {"x": 62, "y": 50, "slot": 8, "label": "CM", "position_id": 8}, {"x": 94, "y": 50, "slot": 9, "label": "RWB", "position_id": 2}, {"x": 32, "y": 68, "slot": 10, "label": "LIW", "position_id": 11}, {"x": 50, "y": 74, "slot": 11, "label": "ST", "position_id": 7}]' WHERE code = '3-5-2 (1-2-L2)';
UPDATE formations SET positions_json = '[{"x": 50, "y": 5, "slot": 1, "label": "GK", "position_id": 1}, {"x": 30, "y": 18, "slot": 2, "label": "CB", "position_id": 5}, {"x": 50, "y": 15, "slot": 3, "label": "CB", "position_id": 6}, {"x": 70, "y": 18, "slot": 4, "label": "CB", "position_id": 4}, {"x": 6, "y": 38, "slot": 5, "label": "LWB", "position_id": 3}, {"x": 40, "y": 38, "slot": 6, "label": "CM", "position_id": 10}, {"x": 60, "y": 38, "slot": 7, "label": "CM", "position_id": 8}, {"x": 94, "y": 38, "slot": 8, "label": "RWB", "position_id": 2}, {"x": 50, "y": 54, "slot": 9, "label": "CAM", "position_id": 9}, {"x": 50, "y": 74, "slot": 10, "label": "ST", "position_id": 11}, {"x": 68, "y": 68, "slot": 11, "label": "RIW", "position_id": 7}]' WHERE code = '3-5-2 (2-1-R2)';
UPDATE formations SET positions_json = '[{"x": 50, "y": 5, "slot": 1, "label": "GK", "position_id": 1}, {"x": 30, "y": 18, "slot": 2, "label": "CB", "position_id": 5}, {"x": 50, "y": 15, "slot": 3, "label": "CB", "position_id": 6}, {"x": 70, "y": 18, "slot": 4, "label": "CB", "position_id": 4}, {"x": 6, "y": 38, "slot": 5, "label": "LWB", "position_id": 3}, {"x": 40, "y": 38, "slot": 6, "label": "CM", "position_id": 10}, {"x": 60, "y": 38, "slot": 7, "label": "CM", "position_id": 8}, {"x": 94, "y": 38, "slot": 8, "label": "RWB", "position_id": 2}, {"x": 50, "y": 54, "slot": 9, "label": "CAM", "position_id": 9}, {"x": 32, "y": 68, "slot": 10, "label": "LIW", "position_id": 11}, {"x": 50, "y": 74, "slot": 11, "label": "ST", "position_id": 7}]' WHERE code = '3-5-2 (2-1-L2)';

UPDATE match_lineups
   SET position_id = CASE position_id WHEN 9 THEN 11 WHEN 11 THEN 10 WHEN 10 THEN 9 END,
       slot_number = CASE slot_number WHEN 9 THEN 11 WHEN 11 THEN 10 WHEN 10 THEN 9 ELSE slot_number END
 WHERE match_id = 9356
   AND position_id IN (9, 10, 11)
   AND (SELECT formation_id FROM match_lineup_metadata WHERE match_id = 9356 LIMIT 1)
       = (SELECT id FROM formations WHERE code = '3-5-2 (3-R2)');
