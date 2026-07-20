-- 234-club-game-model-plan.sql (2026-07-20)
-- Normalize club game model content into practices, sessions, exercises,
-- number patterns, and preparation days so the admin view can render a
-- reusable weekly plan from the database.

BEGIN;

CREATE TABLE IF NOT EXISTS club_game_model_days (
    id bigserial PRIMARY KEY,
    club_id integer NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    slug text NOT NULL,
    label text NOT NULL,
    description text,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (club_id, slug)
);

CREATE INDEX IF NOT EXISTS idx_club_game_model_days_club_id
    ON club_game_model_days (club_id, sort_order, id);

CREATE TABLE IF NOT EXISTS club_game_model_practices (
    id bigserial PRIMARY KEY,
    day_id bigint NOT NULL REFERENCES club_game_model_days(id) ON DELETE CASCADE,
    title text NOT NULL,
    summary text,
    start_time time,
    end_time time,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (day_id, title)
);

CREATE INDEX IF NOT EXISTS idx_club_game_model_practices_day_id
    ON club_game_model_practices (day_id, sort_order, id);

CREATE TABLE IF NOT EXISTS club_game_model_sessions (
    id bigserial PRIMARY KEY,
    practice_id bigint NOT NULL REFERENCES club_game_model_practices(id) ON DELETE CASCADE,
    title text NOT NULL,
    summary text,
    start_time time,
    end_time time,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (practice_id, title)
);

CREATE INDEX IF NOT EXISTS idx_club_game_model_sessions_practice_id
    ON club_game_model_sessions (practice_id, sort_order, id);

CREATE TABLE IF NOT EXISTS club_game_model_exercises (
    id bigserial PRIMARY KEY,
    club_id integer NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    slug text NOT NULL,
    title text NOT NULL,
    summary text,
    setup text,
    coaching_points text,
    simulator_slug text,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (club_id, slug)
);

CREATE INDEX IF NOT EXISTS idx_club_game_model_exercises_club_id
    ON club_game_model_exercises (club_id, sort_order, id);

CREATE TABLE IF NOT EXISTS club_game_model_session_exercises (
    id bigserial PRIMARY KEY,
    session_id bigint NOT NULL REFERENCES club_game_model_sessions(id) ON DELETE CASCADE,
    exercise_id bigint NOT NULL REFERENCES club_game_model_exercises(id) ON DELETE CASCADE,
    player_count integer,
    duration_minutes integer,
    notes text,
    sort_order integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (session_id, exercise_id)
);

CREATE INDEX IF NOT EXISTS idx_club_game_model_session_exercises_session_id
    ON club_game_model_session_exercises (session_id, sort_order, id);

CREATE TABLE IF NOT EXISTS club_game_model_number_patterns (
    id bigserial PRIMARY KEY,
    club_id integer NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    slug text NOT NULL,
    name text NOT NULL,
    description text,
    min_players integer NOT NULL DEFAULT 0,
    max_players integer NOT NULL DEFAULT 0,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (club_id, slug)
);

CREATE INDEX IF NOT EXISTS idx_club_game_model_number_patterns_club_id
    ON club_game_model_number_patterns (club_id, sort_order, id);

INSERT INTO club_game_model_days (club_id, slug, label, description, sort_order)
SELECT c.id, 'tuesday', 'Tuesday', 'Prep day: build from the back and create rhythm through the middle.', 1
FROM clubs c
ON CONFLICT (club_id, slug) DO NOTHING;

INSERT INTO club_game_model_days (club_id, slug, label, description, sort_order)
SELECT c.id, 'thursday', 'Thursday', 'Game day prep: stretch the attack, finish in the final third, and recover as a unit.', 2
FROM clubs c
ON CONFLICT (club_id, slug) DO NOTHING;

INSERT INTO club_game_model_practices (day_id, title, summary, start_time, end_time, sort_order)
SELECT d.id, 'Base build', 'Calm circulation and clean support angles before the vertical attack.', '19:15:00'::time, '19:55:00'::time, 1
FROM club_game_model_days d
WHERE d.slug = 'tuesday'
ON CONFLICT (day_id, title) DO NOTHING;

INSERT INTO club_game_model_practices (day_id, title, summary, start_time, end_time, sort_order)
SELECT d.id, 'Final-third finish', 'Create overloads in the central zone and finish with purpose.', '19:15:00'::time, '19:55:00'::time, 1
FROM club_game_model_days d
WHERE d.slug = 'thursday'
ON CONFLICT (day_id, title) DO NOTHING;

INSERT INTO club_game_model_sessions (practice_id, title, summary, start_time, end_time, sort_order)
SELECT p.id, 'Build from the back', 'Three-player rotations from the defensive line into the midfield.', '19:15:00'::time, '19:35:00'::time, 1
FROM club_game_model_practices p
JOIN club_game_model_days d ON d.id = p.day_id
WHERE d.slug = 'tuesday'
ON CONFLICT (practice_id, title) DO NOTHING;

INSERT INTO club_game_model_sessions (practice_id, title, summary, start_time, end_time, sort_order)
SELECT p.id, 'Final-third combinations', 'Use the extra player to break lines and create a finish.', '19:15:00'::time, '19:35:00'::time, 1
FROM club_game_model_practices p
JOIN club_game_model_days d ON d.id = p.day_id
WHERE d.slug = 'thursday'
ON CONFLICT (practice_id, title) DO NOTHING;

INSERT INTO club_game_model_exercises (club_id, slug, title, summary, setup, coaching_points, simulator_slug, sort_order)
SELECT c.id, '4v2-rondo', '4v2 rondo', 'Two defenders press while the rest of the group connect around them.', 'Create a 12x8 area with a neutral support player and an overload on the outside.', 'Play with immediate support, third-man angles, and a fast reset after the ball is won.', '4v2-rondo', 1
FROM clubs c
ON CONFLICT (club_id, slug) DO NOTHING;

INSERT INTO club_game_model_exercises (club_id, slug, title, summary, setup, coaching_points, simulator_slug, sort_order)
SELECT c.id, '5v2-overload', '5v2 overload', 'Use a central overload to create a free player in the final third.', 'Set up a 20x15 area with a wide channel for the extra player to attack.', 'Rotate quickly, create a passing lane, and finish by breaking the line.', '5v2-overload', 2
FROM clubs c
ON CONFLICT (club_id, slug) DO NOTHING;

INSERT INTO club_game_model_session_exercises (session_id, exercise_id, player_count, duration_minutes, notes, sort_order)
SELECT s.id, e.id, 6, 12, 'Use the first 8 minutes to coach the pattern and the final 4 to play under fatigue.', 1
FROM club_game_model_sessions s
JOIN club_game_model_practices p ON p.id = s.practice_id
JOIN club_game_model_days d ON d.id = p.day_id
JOIN club_game_model_exercises e ON e.slug = '4v2-rondo' AND e.club_id = d.club_id
WHERE s.title = 'Build from the back'
ON CONFLICT (session_id, exercise_id) DO NOTHING;

INSERT INTO club_game_model_session_exercises (session_id, exercise_id, player_count, duration_minutes, notes, sort_order)
SELECT s.id, e.id, 8, 10, 'Keep the overload on the outside and challenge the group to create the line-breaking pass.', 1
FROM club_game_model_sessions s
JOIN club_game_model_practices p ON p.id = s.practice_id
JOIN club_game_model_days d ON d.id = p.day_id
JOIN club_game_model_exercises e ON e.slug = '5v2-overload' AND e.club_id = d.club_id
WHERE s.title = 'Final-third combinations'
ON CONFLICT (session_id, exercise_id) DO NOTHING;

INSERT INTO club_game_model_number_patterns (club_id, slug, name, description, min_players, max_players, sort_order)
SELECT c.id, '6', '6', 'A compact game with quick support angles and immediate circulation.', 6, 6, 1
FROM clubs c
ON CONFLICT (club_id, slug) DO NOTHING;

INSERT INTO club_game_model_number_patterns (club_id, slug, name, description, min_players, max_players, sort_order)
SELECT c.id, '8', '8', 'Use the extra player as a connector between the back line and the front line.', 8, 8, 2
FROM clubs c
ON CONFLICT (club_id, slug) DO NOTHING;

COMMIT;
