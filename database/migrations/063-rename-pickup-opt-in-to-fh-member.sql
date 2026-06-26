-- Migration 063: Rename persons.pickup_opt_in_at -> persons.fh_member_at
-- ============================================================================
-- The column was originally added as "pickup_opt_in_at" because the first use
-- case was a pickup-only signup form.  In practice it represents something
-- broader: the timestamp at which the person became a FootballHome member
-- (filled out the FH member form).  Rename to reflect that.
--
-- This also drops and re-creates the pool-team membership trigger so its
-- body references the new column name.

BEGIN;

ALTER TABLE persons RENAME COLUMN pickup_opt_in_at TO fh_member_at;

COMMENT ON COLUMN persons.fh_member_at IS
  'Timestamp at which this person filled out the FH member form.  An FH '
  'member is either an LA mens registrant (via external_person_aliases -> '
  'mens_team_assignments) or someone with fh_member_at IS NOT NULL.  Pool '
  'teams (teams.is_pool=true) include every FH member on their roster.';

-- Replace the trigger with new names and the new column reference.
DROP TRIGGER IF EXISTS trg_pool_team_membership_on_pickup_optin ON persons;
DROP FUNCTION IF EXISTS fn_pool_team_membership_on_pickup_optin();

CREATE OR REPLACE FUNCTION fn_pool_team_membership_on_fh_register()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_player_id INT;
  v_team_id   INT;
BEGIN
  -- Only fire when transitioning from "not registered" -> "registered".
  IF NEW.fh_member_at IS NULL THEN RETURN NEW; END IF;
  IF TG_OP = 'UPDATE' AND OLD.fh_member_at IS NOT NULL THEN RETURN NEW; END IF;

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

CREATE TRIGGER trg_pool_team_membership_on_fh_register
AFTER INSERT OR UPDATE OF fh_member_at ON persons
FOR EACH ROW EXECUTE FUNCTION fn_pool_team_membership_on_fh_register();

COMMIT;
