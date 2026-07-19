-- Migration 105: team_eligible_genders lookup table
--
-- Introduces a normalized many-to-many between teams and the gender
-- buckets they accept.  This replaces the ad-hoc `gender_category`
-- scalar (which forced coed teams into a fake "coed" enum value) with
-- a proper join table.
--
-- Backfill rules:
--   * Every team with a non-NULL teams.gender_category gets exactly one
--     row: (team_id, gender_category).
--   * NULL gender_category teams (all external/opposing clubs) get no
--     rows — they never appear in the internal roster pipelines.
--
-- Coed seeding:
--   * team 122 "Lighthouse Adult League" → (mens, womens)
--   * team 911 "Lighthouse Youth League" → (boys, girls)
--
-- teams.gender_category is intentionally KEPT for now.  It still
-- serves as the coarse "primary bucket" tag used by other subsystems
-- (Event reminders, Leads classifier, roster_columns.domain mirror).
-- Migrating those callers to team_eligible_genders is a separate,
-- incremental pass.

BEGIN;

CREATE TABLE IF NOT EXISTS team_eligible_genders (
    team_id  INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    gender   TEXT    NOT NULL CHECK (gender IN ('mens','womens','boys','girls')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (team_id, gender)
);

COMMENT ON TABLE team_eligible_genders IS
  'Which gender buckets each team accepts for roster and lineup assignment.  '
  'Replaces the scalar teams.gender_category for eligibility checks; the '
  'scalar column is kept as a coarse primary tag consumed by legacy '
  'callers (event reminders, leads classifier).';

COMMENT ON COLUMN team_eligible_genders.gender IS
  'One of mens|womens|boys|girls.  A team may have multiple rows to '
  'indicate coed eligibility (e.g. Lighthouse Adult League = mens+womens).';

CREATE INDEX IF NOT EXISTS idx_team_eligible_genders_gender
  ON team_eligible_genders(gender);

-- Backfill: one row per team from existing gender_category.
INSERT INTO team_eligible_genders (team_id, gender)
SELECT id, gender_category
  FROM teams
 WHERE gender_category IN ('mens','womens','boys','girls')
ON CONFLICT DO NOTHING;

-- Coed seeding.  Idempotent so re-running the migration is safe.
INSERT INTO team_eligible_genders (team_id, gender) VALUES
    (122, 'mens'), (122, 'womens'),
    (911, 'boys'), (911, 'girls')
ON CONFLICT DO NOTHING;

COMMIT;
