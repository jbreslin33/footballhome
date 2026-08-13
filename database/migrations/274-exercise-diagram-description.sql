-- 274-exercise-diagram-description.sql (2026-08-11)
--
-- Exercises had one text field ("summary") paired with an optional
-- "summary"-role photo, plus a separate "diagram"-role photo with no
-- text counterpart. Restructures this into two parallel photo+text
-- pairs:
--
--   diagram      — the at-a-glance visual (cone setup, formation).
--                   club_game_model_exercises.diagram_text (new) +
--                   club_game_model_exercise_images.role = 'diagram'
--                   (already existed, photo-only until now).
--   description  — what the drill is / how it plays out.
--                   club_game_model_exercises.description (renamed
--                   from `summary`) +
--                   club_game_model_exercise_images.role = 'description'
--                   (renamed from 'summary').
--
-- setup and coaching_points are untouched — still separate plain-text
-- fields alongside this pair.

BEGIN;

ALTER TABLE club_game_model_exercises RENAME COLUMN summary TO description;
ALTER TABLE club_game_model_exercises ADD COLUMN diagram_text text;

ALTER TABLE club_game_model_exercise_images
    DROP CONSTRAINT club_game_model_exercise_images_role_check;

UPDATE club_game_model_exercise_images SET role = 'description' WHERE role = 'summary';

ALTER TABLE club_game_model_exercise_images
    ADD CONSTRAINT club_game_model_exercise_images_role_check
        CHECK (role IN ('diagram', 'description'));

COMMIT;
