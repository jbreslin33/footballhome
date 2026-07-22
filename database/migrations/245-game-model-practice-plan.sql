-- 245-game-model-practice-plan.sql (2026-07-22)
-- Rebuild the practice/session/exercise side of the game model from
-- scratch, correctly normalized:
--
--   club_game_model_days
--       Weekly recurring templates only (Tuesday, Thursday, ...). Never
--       tied to a specific date/occurrence. Owned via club_game_model_id,
--       matching the phases/action_catalogs ownership pattern from
--       migration 244.
--
--   club_game_model_practices
--       One row per REAL practice occurrence. Per CONVENTIONS.md, Google
--       Calendar owns event timing — this table never stores start/end
--       time itself. It links 1:1 to fh_events (kind='practice'), which
--       is already 1:1 with the real gcal_events row (migration 119).
--       day_id tags which weekly template this occurrence follows.
--
--   club_game_model_exercises
--       The reusable drill/exercise library (e.g. "4v2 Rondo"). Lives
--       independently of any scheduled use — defined once, referenced
--       many times.
--
--   club_game_model_sessions
--       A scheduled block of time within one practice (start_time /
--       end_time are practice-relative clock times, not tied to gcal).
--       Every session must contain at least one exercise (enforced at
--       the application layer — even "Warmup" or "Water break" is
--       modeled as an exercise in the library, never a bare freeform
--       session).
--
--   club_game_model_session_exercises
--       Join table: which exercise(s) run during a session. sequence_order
--       lets a session model either a single drill (one row), stacked/
--       sequential blocks (increasing sequence_order), or concurrent
--       stations (same sequence_order, multiple rows — e.g. Station A /
--       Station B running at once while groups rotate).
--
--   club_game_model_exercise_principles / _sub_principles / _action_items
--       Many-to-many tags: which principles, sub-principles, and player
--       actions each exercise trains. This is what lets us answer "what's
--       covered this week / this practice / this day / this session /
--       this exercise" and, just as importantly, "what's NOT covered yet"
--       by diffing against the full principle/sub-principle/action-item
--       sets in club_game_model_principles / _sub_principles / _action_items.
--
-- The old placeholder tables (days/practices/sessions/exercises/
-- session_exercises/number_patterns from migration 234) only ever held
-- generic seed rows blanket-inserted for every club — no real content —
-- so they are dropped outright rather than migrated.

BEGIN;

DROP TABLE IF EXISTS club_game_model_session_exercises;
DROP TABLE IF EXISTS club_game_model_sessions;
DROP TABLE IF EXISTS club_game_model_practices;
DROP TABLE IF EXISTS club_game_model_exercises;
DROP TABLE IF EXISTS club_game_model_days;
DROP TABLE IF EXISTS club_game_model_number_patterns;

-- ─── Weekly templates ───────────────────────────────────────────────
CREATE TABLE club_game_model_days (
    id bigserial PRIMARY KEY,
    club_game_model_id bigint NOT NULL REFERENCES club_game_model(id) ON DELETE CASCADE,
    slug text NOT NULL,
    label text NOT NULL,
    day_of_week smallint NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0=Sunday .. 6=Saturday (matches Postgres EXTRACT(DOW))
    description text,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (club_game_model_id, slug)
);
CREATE INDEX idx_club_game_model_days_model_id
    ON club_game_model_days (club_game_model_id, sort_order, id);

-- ─── Exercise library ───────────────────────────────────────────────
CREATE TABLE club_game_model_exercises (
    id bigserial PRIMARY KEY,
    club_game_model_id bigint NOT NULL REFERENCES club_game_model(id) ON DELETE CASCADE,
    slug text NOT NULL,
    title text NOT NULL,
    summary text,
    setup text,
    coaching_points text,
    min_players integer,
    max_players integer,
    default_duration_minutes integer,
    simulator_slug text,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (club_game_model_id, slug)
);
CREATE INDEX idx_club_game_model_exercises_model_id
    ON club_game_model_exercises (club_game_model_id, sort_order, id);

-- ─── Exercise -> game-model coverage tags ──────────────────────────
CREATE TABLE club_game_model_exercise_principles (
    id bigserial PRIMARY KEY,
    exercise_id bigint NOT NULL REFERENCES club_game_model_exercises(id) ON DELETE CASCADE,
    principle_id bigint NOT NULL REFERENCES club_game_model_principles(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (exercise_id, principle_id)
);
CREATE INDEX idx_club_game_model_exercise_principles_principle_id
    ON club_game_model_exercise_principles (principle_id);

CREATE TABLE club_game_model_exercise_sub_principles (
    id bigserial PRIMARY KEY,
    exercise_id bigint NOT NULL REFERENCES club_game_model_exercises(id) ON DELETE CASCADE,
    sub_principle_id bigint NOT NULL REFERENCES club_game_model_sub_principles(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (exercise_id, sub_principle_id)
);
CREATE INDEX idx_club_game_model_exercise_sub_principles_sub_principle_id
    ON club_game_model_exercise_sub_principles (sub_principle_id);

CREATE TABLE club_game_model_exercise_action_items (
    id bigserial PRIMARY KEY,
    exercise_id bigint NOT NULL REFERENCES club_game_model_exercises(id) ON DELETE CASCADE,
    action_item_id bigint NOT NULL REFERENCES club_game_model_action_items(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (exercise_id, action_item_id)
);
CREATE INDEX idx_club_game_model_exercise_action_items_action_item_id
    ON club_game_model_exercise_action_items (action_item_id);

-- ─── Real practice occurrences ──────────────────────────────────────
-- No start_time/end_time here — Calendar owns timing. See fh_events /
-- gcal_events (migration 119) for the real scheduled time.
CREATE TABLE club_game_model_practices (
    id bigserial PRIMARY KEY,
    club_game_model_id bigint NOT NULL REFERENCES club_game_model(id) ON DELETE CASCADE,
    fh_event_id bigint NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    day_id bigint REFERENCES club_game_model_days(id) ON DELETE SET NULL,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (fh_event_id)
);
CREATE INDEX idx_club_game_model_practices_model_id
    ON club_game_model_practices (club_game_model_id, id);
CREATE INDEX idx_club_game_model_practices_day_id
    ON club_game_model_practices (day_id, id);

-- ─── Scheduled blocks within a practice ─────────────────────────────
-- start_time/end_time here ARE practice-relative clock times (e.g.
-- "6:05pm-6:20pm warmup") — a different concept from the practice's
-- overall calendar start/end, and fine to own directly.
CREATE TABLE club_game_model_sessions (
    id bigserial PRIMARY KEY,
    practice_id bigint NOT NULL REFERENCES club_game_model_practices(id) ON DELETE CASCADE,
    title text,
    notes text,
    start_time time NOT NULL,
    end_time time NOT NULL,
    sort_order integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CHECK (end_time > start_time)
);
CREATE INDEX idx_club_game_model_sessions_practice_id
    ON club_game_model_sessions (practice_id, sort_order, id);

-- ─── Which exercise(s) run during a session ─────────────────────────
-- sequence_order groups concurrent stations (same value = running at
-- the same time, e.g. Station A / Station B while groups rotate) and
-- orders stacked/sequential blocks (increasing value = run one after
-- another within the session's time window).
CREATE TABLE club_game_model_session_exercises (
    id bigserial PRIMARY KEY,
    session_id bigint NOT NULL REFERENCES club_game_model_sessions(id) ON DELETE CASCADE,
    exercise_id bigint NOT NULL REFERENCES club_game_model_exercises(id) ON DELETE CASCADE,
    sequence_order integer NOT NULL DEFAULT 0,
    player_count integer,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (session_id, exercise_id)
);
CREATE INDEX idx_club_game_model_session_exercises_session_id
    ON club_game_model_session_exercises (session_id, sequence_order, id);
CREATE INDEX idx_club_game_model_session_exercises_exercise_id
    ON club_game_model_session_exercises (exercise_id);

COMMIT;
