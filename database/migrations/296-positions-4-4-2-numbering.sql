-- 296 — Renumbers positions 3-11 to match the real 4-4-2 shirt-number
-- convention the owner specified (2026-08-22): "1 keeper, 2 rb, 3 lb,
-- 4 cb, 5 cb, 6 cdm, 8 cdm, 9 str, 10 str, 7 right mid, 11 left mid."
--
-- Only ids 1, 2, and 9 already matched (GK/RB/Striker) — everything
-- else needs renaming. Two center backs (4,5), two defensive
-- midfielders (6,8), and two strikers (9,10) need distinct `name`
-- values (positions_name_key is UNIQUE) even though they share an
-- `abbreviation`. This is the id/sortOrder scheme the game-lineup.js
-- 1-11 position pills and formation pitch graphic read directly, and
-- match_lineups.position_id/slot_number both reference these same ids
-- — safe to rename in place since no id values change, only
-- name/abbreviation, and nothing else in the app hardcodes the old
-- position names (verified via grep before writing this).

BEGIN;

-- Pass 1: temp placeholders so the UNIQUE(name) constraint never sees a
-- transient collision between old and new names. Includes id 12 — its
-- existing name "Left Midfielder" is exactly where id 11 needs to land.
UPDATE positions SET name = 'tmp_' || id WHERE id IN (3,4,5,6,7,8,9,10,11,12);

-- Pass 2: final 4-4-2 shirt-number scheme.
UPDATE positions SET name = 'Left Back',              abbreviation = 'LB'  WHERE id = 3;
UPDATE positions SET name = 'Center Back',             abbreviation = 'CB'  WHERE id = 4;
UPDATE positions SET name = 'Center Back B',           abbreviation = 'CB'  WHERE id = 5;
UPDATE positions SET name = 'Defensive Midfielder',    abbreviation = 'CDM' WHERE id = 6;
UPDATE positions SET name = 'Right Midfielder',        abbreviation = 'RM'  WHERE id = 7;
UPDATE positions SET name = 'Defensive Midfielder B',  abbreviation = 'CDM' WHERE id = 8;
UPDATE positions SET name = 'Striker',                 abbreviation = 'ST'  WHERE id = 9;
UPDATE positions SET name = 'Striker B',               abbreviation = 'ST'  WHERE id = 10;
UPDATE positions SET name = 'Left Midfielder',         abbreviation = 'LM'  WHERE id = 11;
-- id 12 is now displaced (its old name moved to id 11) — outside the
-- pills' sortOrder<=11 range, so it's unused by the app; give it a
-- distinct, still-meaningful name rather than leaving the tmp_ value.
UPDATE positions SET name = 'Left Midfielder (Extra)', abbreviation = 'LM'  WHERE id = 12;

COMMIT;
