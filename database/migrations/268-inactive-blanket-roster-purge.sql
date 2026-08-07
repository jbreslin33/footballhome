-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 268: blanket team_persons/roster_assignments purge for
-- inactive-variant members
--
-- Migration 267 made fn_sweep_invalid_rosters() sweep team_persons the
-- same way it already swept roster_assignments — but BOTH sweeps only
-- act on teams that have a row in team_membership_requirements. Teams
-- with none are treated as "unrestricted" (that's deliberate for
-- legacy/admin teams — see migration comments), but it also means
-- Trialists (924/925/926/927/928/929) and Liga 1 U23 (461), which have
-- no requirement rows configured, never got swept. Verified: 5 of the 8
-- men on the LA inactive program (migration 266) were still sitting on
-- APSL Trialists (925); Oumar Barry was still on U23 Liga 1 (461) via a
-- team_persons row untouched by 267's team_membership_requirements-gated
-- logic.
--
-- Being on the "inactive" LA sub-program is a deliberate, unambiguous
-- signal — unlike a plain membership lapse (which the requirements-gated
-- sweep already handles, and which SHOULD leave someone eligible for,
-- say, a Trialist tryout with no membership yet). Owner directive
-- 2026-08-07: inactive members get pulled from EVERYTHING except the
-- payments screen. So this is a separate, blanket rule — not gated by
-- team_membership_requirements at all — fired by the same trigger.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

CREATE OR REPLACE FUNCTION public.fn_sweep_invalid_rosters()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
    swept INTEGER := 0;
    swept_tp INTEGER := 0;
    swept_inactive_ra INTEGER := 0;
    swept_inactive_tp INTEGER := 0;
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
    DELETE FROM player_rsvp_eligibility ple
     USING upd_tp
     JOIN persons p ON p.id = upd_tp.person_id
     WHERE ple.leagueapps_user_id = p.la_user_id::bigint
       AND ple.team_id            = upd_tp.team_id;

    GET DIAGNOSTICS swept_tp = ROW_COUNT;

    -- Blanket rule (NOT gated by team_membership_requirements): anyone
    -- with an OPEN membership on an 'inactive'-variant LA program comes
    -- off every team — Trialists, Reserves, Liga 1 U23, anything —
    -- because "inactive" is a deliberate demotion, not a plain
    -- membership lapse (which the requirements-gated sweeps above
    -- already handle, and which should NOT block e.g. a genuine
    -- never-registered trialist from staying on a tryout team).
    WITH inactive_persons AS (
        SELECT DISTINCT plm.person_id
          FROM person_la_memberships plm
          JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id
         WHERE plm.ended_at IS NULL AND lp.variant = 'inactive'
    ),
    upd_ra_inactive AS (
        UPDATE roster_assignments ra
           SET removed_at      = NOW(),
               removed_reason  = 'moved_to_inactive_membership',
               removed_details = jsonb_build_object(
                   'note',      'Auto-swept by fn_sweep_invalid_rosters (inactive LA membership)',
                   'swept_at',  to_char(NOW() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SSZ')
               )
          FROM persons p
         WHERE p.id IN (SELECT person_id FROM inactive_persons)
           AND ra.leagueapps_user_id::text = p.la_user_id
           AND ra.removed_at IS NULL
        RETURNING ra.leagueapps_user_id, ra.team_id
    )
    DELETE FROM player_rsvp_eligibility ple
     USING upd_ra_inactive
     WHERE ple.leagueapps_user_id = upd_ra_inactive.leagueapps_user_id
       AND ple.team_id            = upd_ra_inactive.team_id;

    GET DIAGNOSTICS swept_inactive_ra = ROW_COUNT;

    WITH inactive_persons AS (
        SELECT DISTINCT plm.person_id
          FROM person_la_memberships plm
          JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id
         WHERE plm.ended_at IS NULL AND lp.variant = 'inactive'
    ),
    upd_tp_inactive AS (
        UPDATE team_persons tp
           SET removed_at      = NOW(),
               removed_reason  = 'moved_to_inactive_membership',
               removed_details = jsonb_build_object(
                   'note',      'Auto-swept by fn_sweep_invalid_rosters (inactive LA membership)',
                   'swept_at',  to_char(NOW() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SSZ')
               )
         WHERE tp.person_id IN (SELECT person_id FROM inactive_persons)
           AND tp.removed_at IS NULL
        RETURNING tp.person_id, tp.team_id
    )
    DELETE FROM player_rsvp_eligibility ple
     USING upd_tp_inactive
     JOIN persons p ON p.id = upd_tp_inactive.person_id
     WHERE ple.leagueapps_user_id = p.la_user_id::bigint
       AND ple.team_id            = upd_tp_inactive.team_id;

    GET DIAGNOSTICS swept_inactive_tp = ROW_COUNT;

    RETURN swept + swept_tp + swept_inactive_ra + swept_inactive_tp;
END;
$function$;

-- One-time catch-up.
SELECT fn_sweep_invalid_rosters();

COMMIT;
