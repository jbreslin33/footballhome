-- Migration 112: split "Lighthouse Youth League" into three age-tiered
-- teams — U8, U12, U16.
--
-- Before this migration the youth side of the club had a single
-- catch-all "Lighthouse Youth League" team (id=911) covering every kid
-- (roughly 1st–6th grade / ages 6–13).  Per user directive 2026-07-10:
-- we now field three separate age-tier teams so scheduling, rosters
-- and travel selections are tracked per bracket.
--
-- Action:
--   1) Rename team 911 "Lighthouse Youth League" → "Lighthouse Youth
--      League U16" (this is the "generic" catch-all — the user will
--      manually move any U8/U12-aged players onto the new tier teams
--      once they exist).
--   2) Update the boys-domain roster_column label to match.
--   3) Create two new teams: "Lighthouse Youth League U8" and
--      "Lighthouse Youth League U12".  Mirror team 911's setup:
--        - division_id=73, club_id=134
--        - gender_category='boys' (coarse primary tag)
--        - team_eligible_genders (boys, girls) so the coed roster
--          rules from migration 105 apply the same way.
--   4) Add matching roster_columns for the boys board at sort_order
--      5 and 6 (placed AFTER the existing U8/U10/U12 Boys admin
--      buckets per user directive "don't touch u8 boys, u10 boys,
--      u12 boys").  Existing sort_orders 1..4 stay untouched.
--
-- Notes:
--   * The pre-existing "U8 Boys (Admin)" / "U10 Boys (Admin)" /
--     "U12 Boys (Admin)" columns (team ids 912/913/914, sort 2/3/4)
--     are administrative sorting buckets and are LEFT ENTIRELY
--     UNCHANGED by this migration.
--   * Team ids 916 and 917 are chosen explicitly to keep the youth
--     block contiguous (911, 912, 913, 914, 915 already used).
--   * Idempotent: rename UPDATEs are safe to re-run; team INSERT uses
--     ON CONFLICT (id) DO NOTHING; roster_columns INSERT uses
--     ON CONFLICT (domain, team_id) DO NOTHING.

BEGIN;

-- ── 1) Rename the generic team to U16 ────────────────────────────────────
UPDATE teams
   SET name = 'Lighthouse Youth League U16'
 WHERE id = 911;

-- ── 2) Relabel its boys-board roster column ──────────────────────────────
UPDATE roster_columns
   SET label       = '🏰 Lighthouse Youth League U16',
       short_label = 'LLY U16',
       updated_at  = NOW()
 WHERE team_id = 911
   AND domain  = 'boys';

-- ── 3) New teams for U8 and U12 ──────────────────────────────────────────
-- Mirror the 911 seeding pattern from migration 093.
INSERT INTO teams (id, division_id, club_id, name, gender_category, is_pool)
VALUES
    (916, 73, 134, 'Lighthouse Youth League U8',  'boys', false),
    (917, 73, 134, 'Lighthouse Youth League U12', 'boys', false)
ON CONFLICT (id) DO NOTHING;

-- Keep the teams sequence ahead of manually-assigned ids so future
-- auto-generated inserts don't collide.
SELECT setval('teams_id_seq', GREATEST((SELECT MAX(id) FROM teams), 917));

-- Coed eligibility: same shape as team 911 (boys + girls) so the
-- roster rules from migration 105 treat these teams the same way.
INSERT INTO team_eligible_genders (team_id, gender) VALUES
    (916, 'boys'), (916, 'girls'),
    (917, 'boys'), (917, 'girls')
ON CONFLICT DO NOTHING;

-- ── 4) roster_columns entries for the boys board ─────────────────────────
-- Placed at sort_order 5 and 6 — AFTER the existing U8/U10/U12 Boys
-- admin buckets (sort 2/3/4) which we're deliberately not touching,
-- and BEFORE the "Dues Owed" sentinel at sort 999.
--
-- mutex_group='boys-selection' matches every other selection column
-- on the boys board so moving a player between tiers is atomic
-- (drop-then-insert inside one txn — see MensTeamAssignments).
--
-- Colors: darker blues, distinct from the existing LL Youth blue
-- (#2563eb) so the board still visually distinguishes tiers even
-- though they share the 🏰 icon.
INSERT INTO roster_columns
    (domain, team_id, label,                            short_label, sort_order, color,     mutex_group,      max_roster)
VALUES
    ('boys',    916,  '🏰 Lighthouse Youth League U8',  'LLY U8',    5,          '#0ea5e9', 'boys-selection', NULL),
    ('boys',    917,  '🏰 Lighthouse Youth League U12', 'LLY U12',   6,          '#1d4ed8', 'boys-selection', NULL)
ON CONFLICT (domain, team_id) DO NOTHING;

COMMIT;
