-- 235-game-model-phases-and-principles.sql (2026-07-20)
-- Normalize the club game model around phases and principles so the UI can render a lookup-based coaching framework.

BEGIN;

CREATE TABLE IF NOT EXISTS club_game_model (
    id bigserial PRIMARY KEY,
    club_id integer NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    title text NOT NULL DEFAULT 'Game Model',
    summary text,
    base_shape text,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (club_id)
);

CREATE TABLE IF NOT EXISTS club_game_model_phases (
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

CREATE TABLE IF NOT EXISTS club_game_model_principles (
    id bigserial PRIMARY KEY,
    phase_id bigint NOT NULL REFERENCES club_game_model_phases(id) ON DELETE CASCADE,
    slug text NOT NULL,
    level text NOT NULL CHECK (level IN ('main', 'sub', 'sub_sub', 'sub_sub_sub')),
    title text NOT NULL,
    description text,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (phase_id, slug)
);

CREATE TABLE IF NOT EXISTS club_game_model_phase_principles (
    id bigserial PRIMARY KEY,
    game_model_id bigint NOT NULL REFERENCES club_game_model(id) ON DELETE CASCADE,
    phase_id bigint NOT NULL REFERENCES club_game_model_phases(id) ON DELETE CASCADE,
    principle_id bigint NOT NULL REFERENCES club_game_model_principles(id) ON DELETE CASCADE,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (game_model_id, phase_id, principle_id)
);

CREATE INDEX IF NOT EXISTS idx_club_game_model_phases_club_id
    ON club_game_model_phases (club_id, sort_order, id);

CREATE INDEX IF NOT EXISTS idx_club_game_model_principles_phase_id
    ON club_game_model_principles (phase_id, sort_order, id);

CREATE INDEX IF NOT EXISTS idx_club_game_model_phase_principles_game_model_id
    ON club_game_model_phase_principles (game_model_id, phase_id, sort_order, id);

INSERT INTO club_game_model (club_id, title, summary, base_shape)
SELECT c.id, '4-4-2 Game Model', 'A compact and positional game model built around control, rhythm, and quick decision-making.', 'Compact 4-4-2'
FROM clubs c
ON CONFLICT (club_id) DO NOTHING;

INSERT INTO club_game_model_phases (club_id, slug, label, description, sort_order)
SELECT c.id, 'offense', 'Offense', 'Create overloads, break lines, and finish with purpose.', 1
FROM clubs c
ON CONFLICT (club_id, slug) DO NOTHING;

INSERT INTO club_game_model_phases (club_id, slug, label, description, sort_order)
SELECT c.id, 'defense', 'Defense', 'Defend compactly, force play wide, and recover as a unit.', 2
FROM clubs c
ON CONFLICT (club_id, slug) DO NOTHING;

INSERT INTO club_game_model_phases (club_id, slug, label, description, sort_order)
SELECT c.id, 'offensive-transition', 'Offensive Transition', 'Attack immediately after regaining possession and create the next action.', 3
FROM clubs c
ON CONFLICT (club_id, slug) DO NOTHING;

INSERT INTO club_game_model_phases (club_id, slug, label, description, sort_order)
SELECT c.id, 'defensive-transition', 'Defensive Transition', 'Recover shape quickly and protect the middle after losing the ball.', 4
FROM clubs c
ON CONFLICT (club_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'build-from-back', 'main', 'Build from the back with clear support angles', 'The team should circulate calmly and create a free player before the attack becomes vertical.', 1
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'offense'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'create-overloads', 'sub', 'Create overloads in the middle', 'The midfielders connect the build to the attack and free a player in the attacking third.', 2
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'offense'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'third-man-run', 'sub_sub', 'Use the third-man run as the trigger', 'The third-man run should open the line and create the next pass or finish.', 3
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'offense'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'finish-with-purpose', 'sub_sub_sub', 'Finish with purpose', 'The attack should create a chance, a cross, or a line-breaking action rather than playing for possession alone.', 4
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'offense'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'defend-compact', 'main', 'Defend compact and aggressive as a unit', 'The team should stay together and deny central penetrations before the opponent can progress.', 1
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'defense'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'force-wide', 'sub', 'Force play wide and protect the middle', 'The nearest player presses, the second covers, and the third balances the space.', 2
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'defense'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'counter-press', 'sub_sub', 'Counter-press immediately', 'The team should recover the ball and shift the pressure to the opponent as soon as possible.', 3
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'defense'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'protect-central', 'sub_sub_sub', 'Protect the central lane', 'The midfielders and back line must stay connected to prevent a direct line through the middle.', 4
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'defense'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'counter-attack-quickly', 'main', 'Counter-attack quickly after the turnover', 'The first pass should be vertical or line-breaking so the team can attack with numbers.', 1
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'offensive-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'support-the-break', 'sub', 'Support the break with a fast second action', 'The second and third players should join the attack immediately after the first pass.', 2
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'offensive-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'attack-the-space', 'sub_sub', 'Attack the space behind the defensive line', 'The front line should make the attack unpredictable and force the back line to react.', 3
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'offensive-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'protect-the-break', 'sub_sub_sub', 'Protect the break and reset shape', 'The team should keep enough balance to defend if the transition fails.', 4
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'offensive-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'recover-shape', 'main', 'Recover shape immediately after losing the ball', 'The first recovery action should restore the compact block and protect the middle.', 1
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'defensive-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'first-two-recover', 'sub', 'The first two players recover the shape', 'The first two players should balance the space and make the team compact again.', 2
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'defensive-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'press-on-the-ball', 'sub_sub', 'Press the ball but stay organized', 'The pressure should be immediate without breaking the unit structure.', 3
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'defensive-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_principles (phase_id, slug, level, title, description, sort_order)
SELECT p.id, 'balance-the-channel', 'sub_sub_sub', 'Balance the channel and protect the line', 'The team should not allow the ball to play straight through the middle after the turnover.', 4
FROM club_game_model_phases p
JOIN clubs c ON c.id = p.club_id
WHERE p.slug = 'defensive-transition'
ON CONFLICT (phase_id, slug) DO NOTHING;

INSERT INTO club_game_model_phase_principles (game_model_id, phase_id, principle_id, sort_order)
SELECT gm.id, p.id, pr.id, pr.sort_order
FROM club_game_model gm
JOIN club_game_model_phases p ON p.club_id = gm.club_id
JOIN club_game_model_principles pr ON pr.phase_id = p.id
ON CONFLICT (game_model_id, phase_id, principle_id) DO NOTHING;

COMMIT;
