-- 239-us-soccer-game-model-doc-source.sql (2026-07-21)
-- Seed the club game model from the U.S. Soccer U17+ document in docs/game-model.
-- This keeps the public page aligned to the document while preserving normalized tables.

BEGIN;

CREATE TABLE IF NOT EXISTS club_game_model_phase_definitions (
    id bigserial PRIMARY KEY,
    phase_id bigint NOT NULL REFERENCES club_game_model_phases(id) ON DELETE CASCADE,
    slug text NOT NULL,
    title text NOT NULL,
    definition text NOT NULL,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (phase_id, slug)
);

CREATE TABLE IF NOT EXISTS club_game_model_player_actions (
    id bigserial PRIMARY KEY,
    phase_id bigint NOT NULL REFERENCES club_game_model_phases(id) ON DELETE CASCADE,
    slug text NOT NULL,
    title text NOT NULL,
    description text,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (phase_id, slug)
);

CREATE INDEX IF NOT EXISTS idx_club_game_model_phase_definitions_phase_id
    ON club_game_model_phase_definitions (phase_id, sort_order, id);

CREATE INDEX IF NOT EXISTS idx_club_game_model_player_actions_phase_id
    ON club_game_model_player_actions (phase_id, sort_order, id);

INSERT INTO club_game_model_phase_definitions (phase_id, slug, title, definition, sort_order)
SELECT p.id, 'attacking-game-idea', 'Game Idea', 'When in possession, we want to dominate by advancing the ball quickly in the attacking half with high energy and high tempo.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'attacking'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_phase_definitions (phase_id, slug, title, definition, sort_order)
SELECT p.id, 'defending-game-idea', 'Game Idea', 'When out of possession, the team protects the goal and delays the opponent''s progress by creating a compact and organized defensive shape.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'defending'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_phase_definitions (phase_id, slug, title, definition, sort_order)
SELECT p.id, 'attacking-to-defending-transition-game-idea', 'Game Idea', 'After losing possession, the team must immediately recover shape, protect the central space, and delay the opponent''s counterattack.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'attacking-to-defending-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_phase_definitions (phase_id, slug, title, definition, sort_order)
SELECT p.id, 'defending-to-attacking-transition-game-idea', 'Game Idea', 'When the team regains possession, it should attack quickly with numbers and create the next action before the opponent can recover.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'defending-to-attacking-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'drive-with-the-ball-to-exploit-space', 'Drive with the ball to exploit space', 'Drive with the ball to exploit space.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'attacking'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'engage-opponent-create-1v1-or-2v1', 'Engage the opponent to create a 1v1 or 2v1', 'Engage the opponent and create a favorable attacking situation.', 2
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'attacking'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'find-a-free-player-between-or-behind-the-lines', 'Find a free player between or behind the lines', 'Find a free player between or behind the lines to create the next action.', 3
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'attacking'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'cross-into-space-or-player', 'Cross into space or to a player', 'Cross into space or to a player to create a finish.', 4
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'attacking'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'press-the-ball-carrier', 'Press the ball carrier', 'Press the ball carrier immediately and make the play predictable.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'defending'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'cover-the-nearest-supporting-player', 'Cover the nearest supporting player', 'Cover the nearest supporting player to maintain balance.', 2
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'defending'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'balance-and-protect-the-middle', 'Balance and protect the middle', 'Balance and protect the middle to deny through balls.', 3
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'defending'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'press-closest-opponent-immediately', 'Press the closest opponent immediately', 'Press the closest opponent immediately to delay the transition.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'attacking-to-defending-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'recover-into-defensive-shape', 'Recover into defensive shape', 'Recover into defensive shape and protect the middle.', 2
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'attacking-to-defending-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'protect-the-width-of-the-goal', 'Protect the width of the goal', 'Protect the width of the goal and deny central penetration.', 3
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'attacking-to-defending-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'play-the-first-pass-forward', 'Play the first pass forward', 'Play the first pass forward and attack the space behind the defensive line.', 1
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'defending-to-attacking-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'support-the-break-with-speed', 'Support the break with speed', 'Support the break with speed and create a numerical advantage.', 2
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'defending-to-attacking-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_player_actions (phase_id, slug, title, description, sort_order)
SELECT p.id, 'finish-the-counterattack-with-purpose', 'Finish the counterattack with purpose', 'Finish the counterattack with purpose and create a chance.', 3
FROM club_game_model_phases p
WHERE p.club_id = 100 AND p.slug = 'defending-to-attacking-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

COMMIT;
