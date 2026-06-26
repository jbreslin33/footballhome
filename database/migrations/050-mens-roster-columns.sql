-- Mens roster dashboard:
--   Pull live registrations from the LeagueApps Mens Club Soccer Membership
--   (program 5039300) and bucket each player by the football-home teams
--   they've been assigned to (Brazil, Puerto Rico, U23, APSL, Liga 1/2, …).
--
-- Players can hold multiple team assignments (e.g. U23 + Brazil) so this is
-- a many-to-many keyed on the LeagueApps user id (which is the stable
-- identifier we already get from the Membership export).
--
-- `mens_team_columns` declares which teams render as columns on the
-- dashboard, in what order, with what color/label, and which teams are
-- *mutually exclusive*: any rows sharing a non-NULL `mutex_group` enforce
-- "at most one of these per player".  Brazil and Puerto Rico share group
-- 'grassroots-country' (Grassroots Cup country pick); U23 is independent.

CREATE TABLE IF NOT EXISTS mens_team_columns (
    id            SERIAL PRIMARY KEY,
    team_id       INTEGER     NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    label         TEXT        NULL,            -- display override; falls back to teams.name
    sort_order    INTEGER     NOT NULL,
    color         TEXT        NULL,            -- hex
    mutex_group   TEXT        NULL,            -- shared group => at-most-one rule
    max_roster    INTEGER     NULL,            -- NULL = unlimited
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT mens_team_columns_team_unique UNIQUE (team_id)
);

CREATE INDEX IF NOT EXISTS idx_mens_team_columns_sort
    ON mens_team_columns (sort_order);

CREATE TABLE IF NOT EXISTS mens_team_assignments (
    id                   SERIAL PRIMARY KEY,
    leagueapps_user_id   BIGINT      NOT NULL,
    team_id              INTEGER     NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    assigned_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    assigned_by_user_id  INTEGER     NULL,
    CONSTRAINT mens_team_assignments_unique
        UNIQUE (leagueapps_user_id, team_id)
);

CREATE INDEX IF NOT EXISTS idx_mens_team_assignments_user
    ON mens_team_assignments (leagueapps_user_id);
CREATE INDEX IF NOT EXISTS idx_mens_team_assignments_team
    ON mens_team_assignments (team_id);

-- ── Seed: initial columns ───────────────────────────────────────────────
-- 904 Brazil       — Grassroots Cup country pick (mutex with PR)
-- 905 Puerto Rico  — Grassroots Cup country pick (mutex with Brazil)
-- 903 U23 Men      — CASA U23 Premier (independent)
-- Add APSL / Liga 1 / Liga 2 later with the right mutex_group as those
-- teams are spun up.
INSERT INTO mens_team_columns (team_id, label, sort_order, color, mutex_group, max_roster)
VALUES
    (904, '🇧🇷 Brazil',      1, '#16a34a', 'grassroots-country', NULL),
    (905, '🇵🇷 Puerto Rico', 2, '#dc2626', 'grassroots-country', NULL),
    (903, '⭐ U23 Men',       3, '#7c3aed', NULL,                 NULL)
ON CONFLICT (team_id) DO NOTHING;
