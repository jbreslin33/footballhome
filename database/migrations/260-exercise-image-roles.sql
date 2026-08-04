-- 260-exercise-image-roles.sql (2026-08-04)
-- Splits the flat exercise-photo list (migration 253) into named
-- roles so a specific photo can stand in for the "what does this
-- drill look like" cue and/or the text summary, instead of every
-- upload dumping into one undifferentiated Photos gallery:
--   'diagram' — the at-a-glance photo shown wherever an exercise is
--               listed (admin table, practice-plan cards, session
--               thumbnails). Exactly one per exercise.
--   'summary' — a photo that stands in for (or supplements) the
--               `club_game_model_exercises.summary` text. Exactly
--               one per exercise.
--   NULL      — everything else: the existing free-for-all gallery,
--               unlimited photos, no special placement.
--
-- The partial unique index enforces "at most one diagram / one
-- summary photo per exercise" without touching NULL-role rows, so
-- the existing multi-photo gallery behavior is untouched.

BEGIN;

ALTER TABLE club_game_model_exercise_images
    ADD COLUMN role TEXT
        CHECK (role IN ('diagram', 'summary'));

CREATE UNIQUE INDEX idx_club_game_model_exercise_images_role
    ON club_game_model_exercise_images (exercise_id, role)
    WHERE role IS NOT NULL;

COMMIT;
