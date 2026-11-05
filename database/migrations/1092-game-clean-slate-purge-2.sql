-- 1092 — Game G5.23 (game/DESIGN.md §8.121): the rest of the old game's data.
--
-- James 11/5: "again all old parts need to go". With the old brain (mig 1080)
-- go: the phases-of-play drills and their hand-placed shapes, the character
-- sheets' tables and numbers, the attribute → physics bending (skill.*), the
-- techniques' numbers, and the direct-opponent pairs. Kept: the concept and
-- technique catalogues (knowledge), the attribute list, the officials, the
-- physics.* and official.* numbers, the real benchmarks.
--
-- Game tables only. fh_game_scratch first; the live game DB with the ship
-- (game/ship/README.md).

BEGIN;

DELETE FROM game_phase_positions;
DELETE FROM game_phases;
DELETE FROM game_direct_opponents;
DELETE FROM game_sheet_position_profile;
DELETE FROM game_sheet_tables;
DELETE FROM game_demo_player_rolls;
DELETE FROM game_demo_player_history;
DELETE FROM game_demo_player_techniques;
DELETE FROM game_model_params WHERE owner IN ('skill', 'sheet', 'technique');

COMMIT;
