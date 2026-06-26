-- Migration 060: Pool teams (Practice / Pickup)
-- ============================================================================
-- "Pool" teams (Practice, Pickup) include every FH mens member by default,
-- in contrast to assignment-based teams (APSL, LIGA 1, LIGA 2, PR, U23) where
-- only explicitly-assigned players appear.  Both are still teams in the
-- normal sense — the only difference is the default membership rule.
--
-- Membership of a FH mens member is determined by:
--   (a) an LA mens assignment (external_person_aliases JOIN
--       mens_team_assignments) — the canonical paid-member signal, OR
--   (b) persons.pickup_opt_in_at IS NOT NULL — a FH self-registration that
--       admin will later promote into LA.
--
-- After this migration, querying "who's on Training Lighthouse" via the usual
-- rosters table just works, because we backfill rosters rows + install
-- triggers that keep pool team rosters auto-populated going forward.

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. is_pool flag
-- ---------------------------------------------------------------------------
ALTER TABLE teams
  ADD COLUMN IF NOT EXISTS is_pool BOOLEAN NOT NULL DEFAULT false;

COMMENT ON COLUMN teams.is_pool IS
  'When true, every FH mens member is implicitly on this team''s roster '
  '(Practice/Pickup model).  When false (default), membership requires an '
  'explicit rosters row driven by mens_team_assignments.';

-- Training Lighthouse is the practice pool today.  Future Pickup team(s) get
-- is_pool=true at creation time.
UPDATE teams SET is_pool = true WHERE id = 908;

-- ---------------------------------------------------------------------------
-- 2. Backfill players for LA-mens persons missing a player row
-- ---------------------------------------------------------------------------
-- A few LA-mens persons exist only as identities (external_person_aliases)
-- with no players row.  They need one to be roster-able.
INSERT INTO players (person_id, source_system_id)
SELECT DISTINCT epa.person_id, 1  -- source_system 1 = apsl
  FROM external_person_aliases epa
  JOIN mens_team_assignments mta
    ON mta.leagueapps_user_id::text = epa.external_user_id
 WHERE epa.provider = 'leagueapps'
   AND NOT EXISTS (SELECT 1 FROM players p WHERE p.person_id = epa.person_id);

-- ---------------------------------------------------------------------------
-- 3. Backfill rosters for every pool team with every FH mens member
-- ---------------------------------------------------------------------------
INSERT INTO rosters (player_id, team_id, joined_at)
SELECT pls.player_id, t.id, NOW()
  FROM teams t
 CROSS JOIN (
   SELECT DISTINCT p.id AS player_id
     FROM players p
    WHERE EXISTS (
      SELECT 1 FROM external_person_aliases epa
        JOIN mens_team_assignments mta
          ON mta.leagueapps_user_id::text = epa.external_user_id
       WHERE epa.person_id = p.person_id
         AND epa.provider = 'leagueapps'
    )
       OR EXISTS (
      SELECT 1 FROM persons pe
       WHERE pe.id = p.person_id
         AND pe.pickup_opt_in_at IS NOT NULL
    )
 ) pls
 WHERE t.is_pool
   AND NOT EXISTS (
     SELECT 1 FROM rosters r
      WHERE r.player_id = pls.player_id
        AND r.team_id = t.id
        AND r.left_at IS NULL
   );

-- ---------------------------------------------------------------------------
-- 4. Trigger — when a new mens_team_assignments row lands, mirror the person
--    onto every pool team's roster (if they aren't already).
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_pool_team_membership_on_mens_assign()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_person_id INT;
  v_player_id INT;
  v_team_id   INT;
BEGIN
  -- LA user id -> person via external_person_aliases.
  SELECT person_id INTO v_person_id
    FROM external_person_aliases
   WHERE provider = 'leagueapps'
     AND external_user_id = NEW.leagueapps_user_id::text
   LIMIT 1;
  IF v_person_id IS NULL THEN RETURN NEW; END IF;

  -- Ensure a player row exists for this person.
  SELECT id INTO v_player_id FROM players WHERE person_id = v_person_id LIMIT 1;
  IF v_player_id IS NULL THEN
    INSERT INTO players (person_id, source_system_id)
    VALUES (v_person_id, 1)
    RETURNING id INTO v_player_id;
  END IF;

  -- Insert into every pool team's roster (current open membership only).
  FOR v_team_id IN SELECT id FROM teams WHERE is_pool LOOP
    IF NOT EXISTS (
      SELECT 1 FROM rosters
       WHERE player_id = v_player_id
         AND team_id   = v_team_id
         AND left_at IS NULL
    ) THEN
      INSERT INTO rosters (player_id, team_id, joined_at)
      VALUES (v_player_id, v_team_id, NOW());
    END IF;
  END LOOP;

  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_pool_team_membership_on_mens_assign ON mens_team_assignments;
CREATE TRIGGER trg_pool_team_membership_on_mens_assign
AFTER INSERT ON mens_team_assignments
FOR EACH ROW EXECUTE FUNCTION fn_pool_team_membership_on_mens_assign();

-- ---------------------------------------------------------------------------
-- 5. Trigger — when a person flips pickup_opt_in_at NULL -> set (FH self
--    registration), mirror onto every pool team's roster.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_pool_team_membership_on_pickup_optin()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_player_id INT;
  v_team_id   INT;
BEGIN
  -- Only fire when transitioning from "not opted in" -> "opted in".
  IF NEW.pickup_opt_in_at IS NULL THEN RETURN NEW; END IF;
  IF TG_OP = 'UPDATE' AND OLD.pickup_opt_in_at IS NOT NULL THEN RETURN NEW; END IF;

  SELECT id INTO v_player_id FROM players WHERE person_id = NEW.id LIMIT 1;
  IF v_player_id IS NULL THEN
    INSERT INTO players (person_id) VALUES (NEW.id) RETURNING id INTO v_player_id;
  END IF;

  FOR v_team_id IN SELECT id FROM teams WHERE is_pool LOOP
    IF NOT EXISTS (
      SELECT 1 FROM rosters
       WHERE player_id = v_player_id
         AND team_id   = v_team_id
         AND left_at IS NULL
    ) THEN
      INSERT INTO rosters (player_id, team_id, joined_at)
      VALUES (v_player_id, v_team_id, NOW());
    END IF;
  END LOOP;

  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_pool_team_membership_on_pickup_optin ON persons;
CREATE TRIGGER trg_pool_team_membership_on_pickup_optin
AFTER INSERT OR UPDATE OF pickup_opt_in_at ON persons
FOR EACH ROW EXECUTE FUNCTION fn_pool_team_membership_on_pickup_optin();

COMMIT;
