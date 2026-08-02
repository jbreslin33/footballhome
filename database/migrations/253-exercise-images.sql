-- 253-exercise-images.sql (2026-08-01)
-- Lets a coach attach one or more photos to a game-model exercise
-- (e.g. a cone-setup diagram or a phone photo of the drill in action).
-- One row per photo so an exercise can have any number, ordered by
-- sort_order — mirrors the exercise_principles / exercise_action_items
-- child-table pattern already used under club_game_model_exercises.
--
-- image_path is the bare filename on disk (/app/images/exercises/<path>,
-- served by nginx at /images/exercises/<path>); image_url is the public
-- path the frontend renders directly into <img src>.

BEGIN;

CREATE TABLE club_game_model_exercise_images (
    id BIGSERIAL PRIMARY KEY,
    exercise_id BIGINT NOT NULL REFERENCES club_game_model_exercises(id) ON DELETE CASCADE,
    image_path TEXT NOT NULL,
    image_url TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_club_game_model_exercise_images_exercise
    ON club_game_model_exercise_images (exercise_id, sort_order, id);

COMMIT;
