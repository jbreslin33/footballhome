-- 241-game-model-principle-definitions.sql (2026-07-21)
-- Definitions belong to the specific principle/sub-principle they define.

BEGIN;

CREATE TABLE IF NOT EXISTS club_game_model_principle_definitions (
    id bigserial PRIMARY KEY,
    principle_id bigint NOT NULL REFERENCES club_game_model_principles(id) ON DELETE CASCADE,
    slug text NOT NULL,
    title text NOT NULL,
    definition text NOT NULL,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (principle_id, slug)
);

CREATE INDEX IF NOT EXISTS idx_club_game_model_principle_definitions_principle_id
    ON club_game_model_principle_definitions (principle_id, sort_order, id);

-- Player actions already exist (phase-scoped, flat list). Add an optional link
-- to a specific principle/sub-principle, only populated when the source
-- document explicitly ties an action to one. NULL means "applies to the
-- phase generally", matching how the source lists actions per-phase.
ALTER TABLE club_game_model_player_actions
    ADD COLUMN IF NOT EXISTS principle_id bigint REFERENCES club_game_model_principles(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_club_game_model_player_actions_principle_id
    ON club_game_model_player_actions (principle_id);

COMMIT;