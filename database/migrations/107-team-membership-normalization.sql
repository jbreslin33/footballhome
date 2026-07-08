-- ─────────────────────────────────────────────────────────────────────
-- 107-team-membership-normalization.sql (2026-07-07)
--
-- Normalizes team roster composition and per-player RSVP eligibility.
--
-- Two questions the app asks constantly:
--   Q1: "Who is on this team?"       →  view v_team_members
--   Q2: "What can this player RSVP?" →  table player_rsvp_eligibility
--
-- Roster composition (Q1):
--   Every team has a `roster_source`.  A team may have BOTH direct rows
--   in roster_assignments AND unioned members from other teams' rows
--   (hybrid — needed for team 909 Pickup which also carries pickup-only
--   members from LA program 5070075).  The view aggregates both.
--
--     teams.roster_source        - 'direct' (default) or 'union'
--     team_roster_sources        - which teams' members compose a target
--                                  team's roster (used by union teams)
--     v_team_members             - the answer: (team_id, la_user_id, …)
--
-- RSVP eligibility (Q2):
--   Explicit per-player rows in player_rsvp_eligibility.  Defaults are
--   auto-inserted by a trigger when a player is assigned to a mens home
--   team ({35 APSL, 120 Liga 1, 121 Liga 2, 122 Adult}).  Admin toggles
--   extras via the player-card popup.
--
-- Retires:
--   - Trigger `trg_pool_team_membership_on_roster_assign` and its
--     function `fn_pool_team_membership_on_mens_assign()` (wrote to the
--     legacy `rosters` table).
--   - Redundant `roster_assignments` rows on 908/909 for players who
--     ARE on a home team (their pool membership is now derived).
--   - All `rosters` rows for 908/909 (also derived now).
--
-- Callers still touched by hardcoded team lists (to be cleaned up in
-- follow-up code commit):
--   - backend/src/controllers/MyController.cpp (callerRosteredForMatch)
--   - backend/src/services/RsvpMaterialization.cpp
--   - backend/src/controllers/EventReminderController.cpp
--   - backend/src/models/MensRoster.cpp (Practice/Pickup backfill)
--   - backend/src/controllers/ClubRostersController.cpp
--   - backend/src/models/LaPool.cpp (pool auto-assign block — to remove)
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

-- ═══ 1. teams.roster_source ═════════════════════════════════════════
ALTER TABLE teams
  ADD COLUMN IF NOT EXISTS roster_source TEXT NOT NULL DEFAULT 'direct'
    CHECK (roster_source IN ('direct','union'));

-- ═══ 2. team_roster_sources ═════════════════════════════════════════
CREATE TABLE IF NOT EXISTS team_roster_sources (
    team_id        INT NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    source_team_id INT NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    PRIMARY KEY (team_id, source_team_id),
    CHECK (team_id <> source_team_id)
);
CREATE INDEX IF NOT EXISTS idx_team_roster_sources_source
  ON team_roster_sources (source_team_id);

-- ═══ 3. player_rsvp_eligibility ═════════════════════════════════════
CREATE TABLE IF NOT EXISTS player_rsvp_eligibility (
    leagueapps_user_id BIGINT      NOT NULL,
    team_id            INT         NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    granted_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    granted_by_user_id INT REFERENCES users(id),
    PRIMARY KEY (leagueapps_user_id, team_id)
);
CREATE INDEX IF NOT EXISTS idx_player_rsvp_eligibility_team
  ON player_rsvp_eligibility (team_id);

-- ═══ 4. Configure Practice + Pickup as union teams ══════════════════
UPDATE teams SET roster_source = 'union' WHERE id IN (908, 909);

INSERT INTO team_roster_sources (team_id, source_team_id) VALUES
  (908,  35), (908, 120), (908, 121), (908, 122),   -- Practice
  (909,  35), (909, 120), (909, 121), (909, 122)    -- Pickup
ON CONFLICT DO NOTHING;

-- ═══ 5. v_team_members (hybrid direct + union) ══════════════════════
CREATE OR REPLACE VIEW v_team_members AS
SELECT team_id,
       leagueapps_user_id,
       MIN(assigned_at)      AS assigned_at,
       bool_or(on_roster)    AS on_roster
  FROM (
    -- Direct rows: every active row in roster_assignments applies to its team.
    SELECT ra.team_id,
           ra.leagueapps_user_id,
           ra.assigned_at,
           COALESCE(ra.on_roster, false) AS on_roster
      FROM roster_assignments ra
     WHERE ra.removed_at IS NULL
    UNION ALL
    -- Union rows: for each (target, source) in team_roster_sources,
    -- source_team's direct rows also count as members of the target.
    SELECT trs.team_id,
           ra.leagueapps_user_id,
           ra.assigned_at,
           COALESCE(ra.on_roster, false) AS on_roster
      FROM team_roster_sources trs
      JOIN roster_assignments  ra
        ON ra.team_id    = trs.source_team_id
       AND ra.removed_at IS NULL
  ) sub
 GROUP BY team_id, leagueapps_user_id;

COMMENT ON VIEW v_team_members IS
  'Q1: who is on this team? Aggregates direct roster_assignments rows '
  'plus any teams listed in team_roster_sources for union teams. '
  'A player counted once per team (earliest assigned_at, OR''d on_roster).';

-- ═══ 6. Retire legacy pool-membership trigger ═══════════════════════
DROP TRIGGER  IF EXISTS trg_pool_team_membership_on_roster_assign
  ON roster_assignments;
DROP FUNCTION IF EXISTS fn_pool_team_membership_on_mens_assign();

-- ═══ 7. Wipe redundant stored pool rows ═════════════════════════════
-- Roster_assignments rows on 908/909 for players who are ALSO on a
-- mens home team are now derived by the view — delete them.  Rows on
-- 909 for pickup-only members (no home team) are preserved.
DELETE FROM roster_assignments
 WHERE team_id IN (908, 909)
   AND leagueapps_user_id IN (
       SELECT DISTINCT leagueapps_user_id
         FROM roster_assignments
        WHERE domain = 'mens'
          AND team_id IN (35, 120, 121, 122)
          AND removed_at IS NULL
   );

-- Legacy `rosters` (player_id/team_id) rows for 908/909 are entirely
-- superseded by v_team_members; the old trigger that wrote them is gone.
DELETE FROM rosters WHERE team_id IN (908, 909);

-- ═══ 8. Seed player_rsvp_eligibility from current state ═════════════
-- Every current mens home-team member gets defaults: own team + 908 + 909.
INSERT INTO player_rsvp_eligibility (leagueapps_user_id, team_id)
SELECT ra.leagueapps_user_id, ra.team_id
  FROM roster_assignments ra
 WHERE ra.domain = 'mens'
   AND ra.team_id IN (35, 120, 121, 122)
   AND ra.removed_at IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO player_rsvp_eligibility (leagueapps_user_id, team_id)
SELECT ra.leagueapps_user_id, 908
  FROM roster_assignments ra
 WHERE ra.domain = 'mens'
   AND ra.team_id IN (35, 120, 121, 122)
   AND ra.removed_at IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO player_rsvp_eligibility (leagueapps_user_id, team_id)
SELECT ra.leagueapps_user_id, 909
  FROM roster_assignments ra
 WHERE ra.domain = 'mens'
   AND ra.team_id IN (35, 120, 121, 122)
   AND ra.removed_at IS NULL
ON CONFLICT DO NOTHING;

-- Pickup-only members (direct rows on 909, no home team): grant 909 only.
INSERT INTO player_rsvp_eligibility (leagueapps_user_id, team_id)
SELECT DISTINCT ra.leagueapps_user_id, 909
  FROM roster_assignments ra
 WHERE ra.team_id = 909
   AND ra.removed_at IS NULL
ON CONFLICT DO NOTHING;

-- Preseason APSL policy: anyone in mens can RSVP to APSL events until
-- the season starts.  When the season starts, tighten to APSL + Liga 1
-- (reserve pool) by running:
--   DELETE FROM player_rsvp_eligibility ple
--    USING roster_assignments ra
--    WHERE ple.team_id = 35
--      AND ple.leagueapps_user_id = ra.leagueapps_user_id
--      AND ra.domain = 'mens'
--      AND ra.team_id IN (121, 122)          -- L2 + Adult lose APSL access
--      AND ra.removed_at IS NULL;
INSERT INTO player_rsvp_eligibility (leagueapps_user_id, team_id)
SELECT ra.leagueapps_user_id, 35
  FROM roster_assignments ra
 WHERE ra.domain = 'mens'
   AND ra.team_id IN (120, 121, 122)
   AND ra.removed_at IS NULL
ON CONFLICT DO NOTHING;

-- ═══ 9. Default-eligibility trigger ═════════════════════════════════
-- On any INSERT/UPDATE where a mens home-team assignment becomes
-- active, grant defaults: home team + Practice + Pickup.
-- Idempotent (ON CONFLICT DO NOTHING) so re-INSERTs don't error.
-- Admin manages non-default grants via player-card popup.
CREATE OR REPLACE FUNCTION fn_grant_default_rsvp_eligibility()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.domain = 'mens'
     AND NEW.team_id IN (35, 120, 121, 122)
     AND NEW.removed_at IS NULL THEN
    INSERT INTO player_rsvp_eligibility (leagueapps_user_id, team_id) VALUES
      (NEW.leagueapps_user_id, NEW.team_id),
      (NEW.leagueapps_user_id, 908),
      (NEW.leagueapps_user_id, 909)
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_grant_default_rsvp_eligibility ON roster_assignments;
CREATE TRIGGER trg_grant_default_rsvp_eligibility
  AFTER INSERT OR UPDATE ON roster_assignments
  FOR EACH ROW EXECUTE FUNCTION fn_grant_default_rsvp_eligibility();

COMMIT;

-- ═══ Verification (run manually after apply) ════════════════════════
-- Everyone on APSL/Liga1/Liga2/Adult should now appear in v_team_members
-- for 908 and 909 (derived), plus the ~15 pickup-only direct members on 909.
--
-- SELECT team_id, COUNT(*) FROM v_team_members
--  WHERE team_id IN (35,120,121,122,908,909)
--  GROUP BY team_id ORDER BY team_id;
--
-- Everyone on a home team should have {home, 908, 909, 35} rows in
-- player_rsvp_eligibility (35 is preseason APSL).
--
-- SELECT team_id, COUNT(*) FROM player_rsvp_eligibility
--  GROUP BY team_id ORDER BY team_id;
--
-- Nelson Cruz (la_user_id=56272007) sanity check:
-- SELECT * FROM v_team_members WHERE leagueapps_user_id = 56272007;
-- SELECT * FROM player_rsvp_eligibility WHERE leagueapps_user_id = 56272007;
