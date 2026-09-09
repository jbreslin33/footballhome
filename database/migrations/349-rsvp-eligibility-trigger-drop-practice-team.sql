-- 349 — fn_grant_default_rsvp_eligibility still grants the deleted
-- Practice team (908), which breaks membership recording for anyone
-- with a swept men's roster row.
--
-- Migration 309 deleted team 908 but left this trigger (from 107/116)
-- hardcoding it. Chain on 2026-09-09, Oumar Barry (person 3487, new Men's
-- Club registration 107349440):
--   LaProgramSync INSERT person_la_memberships
--     → fn_restore_rosters_on_new_membership un-sweeps his old Liga 1
--       roster_assignments row (removed_reason = no_valid_membership)
--     → trg_grant_default_rsvp_eligibility fires on that UPDATE
--     → INSERT player_rsvp_eligibility (uid, 908)
--     → FK violation: team 908 is not present in teams
--   → the whole membership insert rolls back, 58 times in 24h.
-- With no open membership, fn_sweep_invalid_rosters ends every board
-- move to Liga 1 within a second — "the dropdown does nothing".
--
-- Fix: grant only teams that actually exist. Per 309, practice/pickup
-- eligibility comes from gcal team tags now, so the 908 grant has no
-- replacement; 909 (Pickup) is kept as-is but guarded the same way so a
-- future team deletion cannot break membership recording again.
CREATE OR REPLACE FUNCTION public.fn_grant_default_rsvp_eligibility()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.domain = 'mens'
     AND NEW.team_id IN (35, 120, 121, 122)
     AND NEW.removed_at IS NULL THEN
    INSERT INTO player_rsvp_eligibility (leagueapps_user_id, team_id)
    SELECT NEW.leagueapps_user_id, t.id
      FROM teams t
     WHERE t.id IN (NEW.team_id, 909)
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END $function$;
