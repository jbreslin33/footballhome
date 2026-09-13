-- 352 — Per-team config for APSL Reserves (team 938, migration 351), so
-- the column behaves like its APSL sibling (35): eligible gender, the
-- same coaches, the same LeagueApps membership requirement, gcal tags,
-- and the default-RSVP trigger's men's squad list.
BEGIN;

-- Board / LA pool gender gate (team_eligible_genders).
INSERT INTO team_eligible_genders (team_id, gender)
SELECT 938, gender FROM team_eligible_genders WHERE team_id = 35
ON CONFLICT DO NOTHING;

-- Same coaching staff as the APSL first team.
INSERT INTO team_coaches (team_id, coach_id, coach_role_id, started_at)
SELECT 938, coach_id, coach_role_id, now()
  FROM team_coaches
 WHERE team_id = 35 AND ended_at IS NULL
   AND NOT EXISTS (SELECT 1 FROM team_coaches x
                    WHERE x.team_id = 938 AND x.coach_id = team_coaches.coach_id AND x.ended_at IS NULL);

-- A Reserves player needs the same active Men's Club LA program as APSL.
INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT 938, la_program_id FROM team_membership_requirements WHERE team_id = 35
ON CONFLICT DO NOTHING;

-- gcal description DSL: "Team: APSL Reserves" (Club: Mens / Men) → 938.
-- APPEND-ONLY table; these are new pairs.
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes) VALUES
    ('mens', 'apsl reserves', 938, 'Mens APSL Reserves (migration 352)'),
    ('men',  'apsl reserves', 938, 'Spelling variant of club_alias=mens (migration 352)'),
    ('mens', 'reserves',      938, 'Short form of apsl reserves (migration 352)'),
    ('men',  'reserves',      938, 'Short form of apsl reserves (migration 352)')
ON CONFLICT DO NOTHING;

-- Default RSVP eligibility on a roster_assignments row: add 938 to the
-- men's squad list (349 left it at the 2026-08-25 set).
CREATE OR REPLACE FUNCTION public.fn_grant_default_rsvp_eligibility()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.domain = 'mens'
     AND NEW.team_id IN (35, 120, 121, 122, 938)
     AND NEW.removed_at IS NULL THEN
    INSERT INTO player_rsvp_eligibility (leagueapps_user_id, team_id)
    SELECT NEW.leagueapps_user_id, t.id
      FROM teams t
     WHERE t.id IN (NEW.team_id, 909)
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END $function$;

DO $$
DECLARE n INT;
BEGIN
    SELECT count(*) INTO n FROM team_eligible_genders WHERE team_id = 938;
    IF n = 0 THEN RAISE EXCEPTION 'APSL Reserves: no eligible gender'; END IF;
    SELECT count(*) INTO n FROM team_coaches WHERE team_id = 938 AND ended_at IS NULL;
    IF n <> (SELECT count(*) FROM team_coaches WHERE team_id = 35 AND ended_at IS NULL) THEN
        RAISE EXCEPTION 'APSL Reserves: coach list differs from APSL (%)', n;
    END IF;
    SELECT count(*) INTO n FROM team_membership_requirements WHERE team_id = 938;
    IF n = 0 THEN RAISE EXCEPTION 'APSL Reserves: no LA membership requirement'; END IF;
    SELECT count(*) INTO n FROM gcal_team_aliases WHERE team_id = 938;
    IF n <> 4 THEN RAISE EXCEPTION 'APSL Reserves: expected 4 gcal aliases, got %', n; END IF;
END $$;

COMMIT;
