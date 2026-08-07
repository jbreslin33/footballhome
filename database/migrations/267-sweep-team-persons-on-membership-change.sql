-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 267: fn_sweep_invalid_rosters() also sweeps team_persons
--
-- Owner directive 2026-08-07: moving a member to the "inactive" LA
-- sub-program (migration 266) should pull them off EVERYTHING except
-- the payments screen (which queries the inactive LA program directly
-- so ops can monitor for reactivation).
--
-- fn_sweep_invalid_rosters() already runs on every membership close
-- (trg_sweep_on_membership_change) and correctly clears stale
-- `roster_assignments` rows. But it never touched `team_persons` — the
-- table MensRoster.cpp's "FH-only squad cards" backdoor (2026-08-02)
-- reads from directly (team_persons.removed_at IS NULL on teams
-- 35/120/121/122/924/925). That backdoor exists so a coach can keep
-- someone on a real squad column despite an LA registration *gap*
-- (e.g. Sheldon Rhoden's stuck renewal) — it was never meant to survive
-- someone being moved to a whole separate "inactive" program because
-- they're 2 months unpaid. Verified case: Oumar Barry (person 3487)
-- still rendered on the mens roster's team 120 column via this exact
-- path after being moved to LA inactive.
--
-- Fix: extend the sweep to also clear team_persons rows the same way —
-- using the existing team_membership_requirements table (already covers
-- teams 35/120/121/122 with the active+pickup program ids; 924/925 have
-- no requirement rows so stay unrestricted, unchanged from today). No
-- new config needed. Cascades to player_rsvp_eligibility same as the
-- roster_assignments sweep (joined via persons.la_user_id since
-- team_persons keys by person_id, not leagueapps_user_id).
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

CREATE OR REPLACE FUNCTION public.fn_sweep_invalid_rosters()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
    swept INTEGER := 0;
    swept_tp INTEGER := 0;
BEGIN
    -- Only teams that have a requirement listed get enforced.  Teams
    -- with NO row in team_membership_requirements are treated as
    -- unrestricted (admin/legacy teams like Dues Owed, Youth Admin).
    WITH invalid AS (
        SELECT ra.id
          FROM roster_assignments ra
         WHERE ra.removed_at IS NULL
           AND EXISTS (SELECT 1 FROM team_membership_requirements tmr WHERE tmr.team_id = ra.team_id)
           AND NOT EXISTS (
               SELECT 1
                 FROM team_membership_requirements tmr
                 JOIN persons p
                   ON p.la_user_id = ra.leagueapps_user_id::text
                 JOIN person_la_memberships plm
                   ON plm.person_id = p.id
                  AND plm.la_program_id = tmr.la_program_id
                  AND plm.ended_at IS NULL
                WHERE tmr.team_id = ra.team_id
           )
    ),
    upd AS (
        UPDATE roster_assignments
           SET removed_at      = NOW(),
               removed_reason  = 'no_valid_membership',
               removed_details = jsonb_build_object(
                   'note',      'Auto-swept by fn_sweep_invalid_rosters',
                   'swept_at',  to_char(NOW() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SSZ')
               )
         WHERE id IN (SELECT id FROM invalid)
        RETURNING leagueapps_user_id, team_id
    )
    -- Cascade: revoke matching RSVP eligibility rows.
    DELETE FROM player_rsvp_eligibility ple
     USING upd
     WHERE ple.leagueapps_user_id = upd.leagueapps_user_id
       AND ple.team_id            = upd.team_id;

    GET DIAGNOSTICS swept = ROW_COUNT;

    -- Same enforcement, same team_membership_requirements source of
    -- truth, over team_persons (keyed by person_id, not
    -- leagueapps_user_id — no join to persons needed for the match).
    WITH invalid_tp AS (
        SELECT tp.id
          FROM team_persons tp
         WHERE tp.removed_at IS NULL
           AND EXISTS (SELECT 1 FROM team_membership_requirements tmr WHERE tmr.team_id = tp.team_id)
           AND NOT EXISTS (
               SELECT 1
                 FROM team_membership_requirements tmr
                 JOIN person_la_memberships plm
                   ON plm.person_id = tp.person_id
                  AND plm.la_program_id = tmr.la_program_id
                  AND plm.ended_at IS NULL
                WHERE tmr.team_id = tp.team_id
           )
    ),
    upd_tp AS (
        UPDATE team_persons
           SET removed_at      = NOW(),
               removed_reason  = 'no_valid_membership',
               removed_details = jsonb_build_object(
                   'note',      'Auto-swept by fn_sweep_invalid_rosters',
                   'swept_at',  to_char(NOW() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SSZ')
               )
         WHERE id IN (SELECT id FROM invalid_tp)
        RETURNING person_id, team_id
    )
    -- Cascade: revoke matching RSVP eligibility rows (join to persons
    -- for la_user_id since player_rsvp_eligibility keys off that, not
    -- person_id).
    DELETE FROM player_rsvp_eligibility ple
     USING upd_tp
     JOIN persons p ON p.id = upd_tp.person_id
     WHERE ple.leagueapps_user_id = p.la_user_id::bigint
       AND ple.team_id            = upd_tp.team_id;

    GET DIAGNOSTICS swept_tp = ROW_COUNT;

    RETURN swept + swept_tp;
END;
$function$;

-- One-time catch-up: apply the newly-widened sweep immediately so
-- Oumar Barry (and anyone else already moved to inactive before this
-- migration) drops off squads right now instead of waiting for the
-- next membership-change event.
SELECT fn_sweep_invalid_rosters();

COMMIT;
