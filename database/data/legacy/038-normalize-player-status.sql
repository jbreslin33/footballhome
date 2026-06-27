-- Migration 038: Normalize player status, eligibility, and working rosters
--
-- Replaces flat boolean flags on players with proper normalized tables:
--   players.is_injured / is_suspended_*     → player_availability
--   players.elig_apsl_* / elig_liga*_*      → player_eligibilities
--   players.internal_role                   → coach_assessments
--
-- Adds:
--   working_rosters   — pre-season projected squad (coach's planning layer)
--   coach_assessments — per-team ability/readiness rating
--
-- Also bootstraps Lighthouse internal season + 5 summer squads + Pool team.
--
-- NOTE: The old columns on players are kept (nulled out) until EligibilityController
--       is updated to read from the new tables.  Drop them in migration 039.

-- ============================================================================
-- 1. SOURCE SYSTEM: internal
-- ============================================================================

INSERT INTO source_systems (id, name, description, is_active)
VALUES (5, 'internal', 'Lighthouse 1893 internal squad management', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 2. PLAYER AVAILABILITY  (player-level — no team_id)
-- ============================================================================
-- Tracks why a player cannot participate right now (injury, suspension, travel).
-- Applies across ALL teams simultaneously.
-- Active record: until_date IS NULL  OR  until_date >= CURRENT_DATE

CREATE TABLE IF NOT EXISTS player_availability (
    id           SERIAL PRIMARY KEY,
    player_id    INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    status       VARCHAR(20) NOT NULL
                     CHECK (status IN ('available', 'injured', 'vacation', 'suspended_league', 'suspended_inhouse')),
    from_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    until_date   DATE,   -- NULL = indefinite / until manually resolved
    notes        TEXT,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (until_date IS NULL OR until_date >= from_date)
);

CREATE INDEX IF NOT EXISTS idx_player_availability_player
    ON player_availability(player_id);

-- NOTE: CURRENT_DATE is not immutable so can't be used in partial index predicate.
-- Filter until_date at query time (WHERE until_date IS NULL OR until_date >= CURRENT_DATE).
CREATE INDEX IF NOT EXISTS idx_player_availability_active
    ON player_availability(player_id, until_date);

COMMENT ON TABLE player_availability IS
    'Player-level unavailability (injury, suspension, vacation). Applies to ALL teams simultaneously.';

-- Migrate existing boolean flags → player_availability rows
INSERT INTO player_availability (player_id, status, from_date, notes)
SELECT id, 'injured', CURRENT_DATE, 'Migrated from players.is_injured'
FROM   players
WHERE  is_injured = true
ON CONFLICT DO NOTHING;

INSERT INTO player_availability (player_id, status, from_date, notes)
SELECT id, 'suspended_league', CURRENT_DATE, 'Migrated from players.is_suspended_league'
FROM   players
WHERE  is_suspended_league = true
ON CONFLICT DO NOTHING;

INSERT INTO player_availability (player_id, status, from_date, notes)
SELECT id, 'suspended_inhouse', CURRENT_DATE, 'Migrated from players.is_suspended_inhouse'
FROM   players
WHERE  is_suspended_inhouse = true
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 3. PLAYER ELIGIBILITIES  (player × league — no team_id)
-- ============================================================================
-- Tracks whether a player is cleared to play in a given source_system/league.
-- category: 'general' (cleared to play), 'starter' (can start), 'bench' (sub-only).
-- APSL and CASA differentiate starter vs bench eligibility.

CREATE TABLE IF NOT EXISTS player_eligibilities (
    id               SERIAL PRIMARY KEY,
    player_id        INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    source_system_id INTEGER NOT NULL REFERENCES source_systems(id),
    category         VARCHAR(20) NOT NULL DEFAULT 'general'
                         CHECK (category IN ('general', 'starter', 'bench')),
    -- subdivision: empty string = Liga 1 / top division; 'liga2' = CASA Liga 2; etc.
    subdivision      VARCHAR(50) NOT NULL DEFAULT '',
    status           VARCHAR(20) NOT NULL DEFAULT 'eligible'
                         CHECK (status IN ('eligible', 'ineligible', 'pending', 'suspended')),
    eligible_from    DATE,
    eligible_until   DATE,
    notes            TEXT,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT player_eligibilities_unique UNIQUE (player_id, source_system_id, category, subdivision)
);

CREATE INDEX IF NOT EXISTS idx_player_eligibilities_player
    ON player_eligibilities(player_id);

CREATE INDEX IF NOT EXISTS idx_player_eligibilities_source
    ON player_eligibilities(source_system_id);

COMMENT ON TABLE player_eligibilities IS
    'Regulatory clearance per player per league. Independent of team assignment and coach assessment.';

-- Migrate existing elig_* booleans → player_eligibilities rows
INSERT INTO player_eligibilities (player_id, source_system_id, category, subdivision, status)
SELECT id, 1, 'starter', '', 'eligible'
FROM   players WHERE elig_apsl_starter = true
ON CONFLICT ON CONSTRAINT player_eligibilities_unique DO NOTHING;

INSERT INTO player_eligibilities (player_id, source_system_id, category, subdivision, status)
SELECT id, 1, 'bench', '', 'eligible'
FROM   players WHERE elig_apsl_bench = true
ON CONFLICT ON CONSTRAINT player_eligibilities_unique DO NOTHING;

INSERT INTO player_eligibilities (player_id, source_system_id, category, subdivision, status)
SELECT id, 2, 'starter', '', 'eligible'
FROM   players WHERE elig_liga1_starter = true
ON CONFLICT ON CONSTRAINT player_eligibilities_unique DO NOTHING;

INSERT INTO player_eligibilities (player_id, source_system_id, category, subdivision, status)
SELECT id, 2, 'bench', '', 'eligible'
FROM   players WHERE elig_liga1_bench = true
ON CONFLICT ON CONSTRAINT player_eligibilities_unique DO NOTHING;

INSERT INTO player_eligibilities (player_id, source_system_id, category, subdivision, status)
SELECT id, 2, 'starter', 'liga2', 'eligible'
FROM   players WHERE elig_liga2_starter = true
ON CONFLICT ON CONSTRAINT player_eligibilities_unique DO NOTHING;

INSERT INTO player_eligibilities (player_id, source_system_id, category, subdivision, status)
SELECT id, 2, 'bench', 'liga2', 'eligible'
FROM   players WHERE elig_liga2_bench = true
ON CONFLICT ON CONSTRAINT player_eligibilities_unique DO NOTHING;

-- ============================================================================
-- 4. WORKING ROSTERS  (team-level — coach's pre-season planning layer)
-- ============================================================================
-- Coach's projected squad before official roster is submitted.
-- Distinct from official rosters (synced from APSL/CASA) and coach_assessments.
-- Active record: removed_at IS NULL

CREATE TABLE IF NOT EXISTS working_rosters (
    id          SERIAL PRIMARY KEY,
    team_id     INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    player_id   INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    added_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    removed_at  TIMESTAMP,
    notes       TEXT,
    CHECK (removed_at IS NULL OR removed_at > added_at),
    UNIQUE (team_id, player_id, added_at)
);

CREATE INDEX IF NOT EXISTS idx_working_rosters_team
    ON working_rosters(team_id);

CREATE INDEX IF NOT EXISTS idx_working_rosters_player
    ON working_rosters(player_id);

CREATE INDEX IF NOT EXISTS idx_working_rosters_current
    ON working_rosters(team_id, player_id)
    WHERE removed_at IS NULL;

COMMENT ON TABLE working_rosters IS
    'Coach pre-season projected squad. Editable planning layer separate from official rosters. Current: removed_at IS NULL.';

-- ============================================================================
-- 5. COACH ASSESSMENTS  (team × player — ability/readiness rating)
-- ============================================================================
-- Per-team coach judgment on whether a player is ready to play.
-- A player can be on the official roster but still rated not_ready here.
-- Only one active assessment per team × player (upsert on update).

CREATE TABLE IF NOT EXISTS coach_assessments (
    id           SERIAL PRIMARY KEY,
    team_id      INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    player_id    INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    status       VARCHAR(20) NOT NULL DEFAULT 'trialing'
                     CHECK (status IN ('eligible', 'not_ready', 'trialing')),
    notes        TEXT,
    assessed_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assessed_by  INTEGER REFERENCES coaches(id) ON DELETE SET NULL,
    UNIQUE (team_id, player_id)
);

CREATE INDEX IF NOT EXISTS idx_coach_assessments_team
    ON coach_assessments(team_id);

CREATE INDEX IF NOT EXISTS idx_coach_assessments_player
    ON coach_assessments(player_id);

COMMENT ON TABLE coach_assessments IS
    'Per-team coach ability/readiness assessment. Independent of official roster and regulatory eligibility.';

-- ============================================================================
-- 6. LIGHTHOUSE INTERNAL SEASON + 5 SQUADS + POOL
-- ============================================================================
-- Creates the internal league structure under Lighthouse 1893 SC (org_id = 134)
-- for summer pre-season squad management.

-- Internal league under Lighthouse org
INSERT INTO leagues (organization_id, name, sex_restriction, source_system_id, is_active)
VALUES (134, 'Lighthouse Internal', 'open', 5, true)
ON CONFLICT (organization_id, name) DO NOTHING;

-- Summer 2026 season
INSERT INTO seasons (league_id, name, start_date, end_date, is_active, source_system_id)
SELECT id, 'Summer 2026', '2026-05-01', '2026-09-30', true, 5
FROM   leagues
WHERE  organization_id = 134 AND name = 'Lighthouse Internal'
ON CONFLICT (league_id, name) DO NOTHING;

-- Conference
INSERT INTO conferences (season_id, name, source_system_id)
SELECT s.id, 'Lighthouse Squads', 5
FROM   seasons s
JOIN   leagues l ON l.id = s.league_id
WHERE  l.organization_id = 134
  AND  l.name = 'Lighthouse Internal'
  AND  s.name = 'Summer 2026'
ON CONFLICT (season_id, name) DO NOTHING;

-- Division
INSERT INTO divisions (season_id, conference_id, name, source_system_id)
SELECT s.id, c.id, 'Summer 2026', 5
FROM   seasons s
JOIN   leagues l  ON l.id  = s.league_id AND l.organization_id = 134 AND l.name = 'Lighthouse Internal'
JOIN   conferences c ON c.season_id = s.id AND c.name = 'Lighthouse Squads'
WHERE  s.name = 'Summer 2026'
ON CONFLICT DO NOTHING;

-- 5 squads + 1 pool team
INSERT INTO teams (division_id, club_id, name, source_system_id)
SELECT d.id, 134, t.name, 5
FROM   divisions d
JOIN   conferences c ON c.id = d.conference_id AND c.name = 'Lighthouse Squads'
CROSS JOIN (VALUES
    ('Tri County Women'),
    ('U23 Women'),
    ('U23 Men'),
    ('Brazil'),
    ('Puerto Rico'),
    ('Pool')
) AS t(name)
ON CONFLICT (division_id, name) DO NOTHING;
