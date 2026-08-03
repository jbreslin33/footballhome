-- 257-fix-alias-drop-fallout.sql (2026-08-03)
--
-- Migration 256 dropped external_person_aliases, but four PL/pgSQL
-- functions (living in the database, not grep-able from the app source
-- tree) still joined through it: fn_sweep_invalid_rosters(),
-- fn_check_roster_membership() (migration 108), fn_restore_rosters_on_
-- new_membership() (migration 109), and fn_backfill_team_persons()
-- (migration 250).  The first three are wired to active triggers on
-- roster_assignments / person_la_memberships, so as soon as 256 landed
-- every LA-sync membership close/open started throwing
-- "relation external_person_aliases does not exist" and aborting the
-- triggering statement.  Same fix as 256's application code: replace the
-- alias-table join with persons.la_user_id.  Pure CREATE OR REPLACE —
-- no data changes, no new columns, safe to run with the app live.

BEGIN;

CREATE OR REPLACE FUNCTION fn_sweep_invalid_rosters() RETURNS INTEGER AS $$
DECLARE
    swept INTEGER := 0;
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
    RETURN swept;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_check_roster_membership() RETURNS TRIGGER AS $$
BEGIN
    -- Only enforce on rows that are (or would become) active.
    IF NEW.removed_at IS NOT NULL THEN
        RETURN NEW;
    END IF;

    -- On UPDATE, only check when the row is transitioning to active OR
    -- when team_id / leagueapps_user_id are being changed.
    IF TG_OP = 'UPDATE'
       AND OLD.removed_at IS NULL
       AND OLD.team_id            = NEW.team_id
       AND OLD.leagueapps_user_id = NEW.leagueapps_user_id THEN
        RETURN NEW;
    END IF;

    -- Only enforce for teams with a listed requirement.
    IF NOT EXISTS (SELECT 1 FROM team_membership_requirements tmr WHERE tmr.team_id = NEW.team_id) THEN
        RETURN NEW;
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM team_membership_requirements tmr
          JOIN persons p
            ON p.la_user_id = NEW.leagueapps_user_id::text
          JOIN person_la_memberships plm
            ON plm.person_id = p.id
           AND plm.la_program_id = tmr.la_program_id
           AND plm.ended_at IS NULL
         WHERE tmr.team_id = NEW.team_id
    ) THEN
        RAISE EXCEPTION 'roster_assignments: leagueapps_user_id % lacks a required active LA membership for team_id % (see team_membership_requirements)',
            NEW.leagueapps_user_id, NEW.team_id
            USING ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_restore_rosters_on_new_membership() RETURNS TRIGGER AS $$
DECLARE
    la_uid TEXT;
BEGIN
    -- Only fire when a fresh row is inserted with an OPEN end (i.e. the
    -- member is actually active).  End-dated inserts (historical backfill
    -- of a previously-ended registration) don't restore anything.
    IF NEW.ended_at IS NOT NULL THEN
        RETURN NEW;
    END IF;

    -- Resolve the LA user id for this person; skip if they have none
    -- (nothing to match against roster_assignments.leagueapps_user_id).
    SELECT p.la_user_id
      INTO la_uid
      FROM persons p
     WHERE p.id = NEW.person_id;
    IF la_uid IS NULL OR la_uid = '' THEN
        RETURN NEW;
    END IF;

    -- Un-soft-delete any auto-swept roster row where this membership
    -- now satisfies the team's requirement.  ON CONFLICT is impossible
    -- here — the partial unique index on (domain, leagueapps_user_id,
    -- team_id) WHERE removed_at IS NULL only tracks active rows, and
    -- we only match rows where removed_at IS NOT NULL.
    UPDATE roster_assignments ra
       SET removed_at      = NULL,
           removed_reason  = NULL,
           removed_details = NULL
     WHERE ra.leagueapps_user_id::text = la_uid
       AND ra.removed_at IS NOT NULL
       AND ra.removed_reason = 'no_valid_membership'
       AND EXISTS (
             SELECT 1 FROM team_membership_requirements tmr
              WHERE tmr.team_id = ra.team_id
                AND tmr.la_program_id = NEW.la_program_id
           )
       -- Only restore where no live active row already exists on the
       -- same (uid, team) — avoids partial-index collisions.
       AND NOT EXISTS (
             SELECT 1 FROM roster_assignments ra2
              WHERE ra2.leagueapps_user_id = ra.leagueapps_user_id
                AND ra2.team_id            = ra.team_id
                AND ra2.removed_at IS NULL
           );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- fn_backfill_team_persons() is not a trigger (invoked manually, and
-- already ran to completion under migrations 250/251), but it's
-- idempotent-and-rerunnable by design (see 250's own comment), so fix
-- it too rather than leave a landmine for the next re-run.
CREATE OR REPLACE FUNCTION fn_backfill_team_persons()
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
  r         record;
  v_tp_id   integer;
  v_joined  timestamptz;
BEGIN
  -- ── A. roster_assignments (via persons.la_user_id) ──
  FOR r IN
    SELECT DISTINCT ON (ra.id)
           ra.id, ra.team_id, p.id AS person_id, ra.assigned_at,
           ra.removed_at, ra.removed_reason, ra.removed_details,
           ra.on_roster, ra.coach_sort_order, ra.assigned_by_user_id
      FROM roster_assignments ra
      JOIN persons p
        ON p.la_user_id = ra.leagueapps_user_id::text
     WHERE NOT EXISTS (SELECT 1 FROM team_persons_backfill_map m
                        WHERE m.source = 'roster_assignments'
                          AND m.source_id = ra.id)
     ORDER BY ra.id, p.id
  LOOP
    -- guard the removed_at > joined_at CHECK
    v_joined := r.assigned_at;
    IF r.removed_at IS NOT NULL AND r.removed_at <= v_joined THEN
      v_joined := r.removed_at - interval '1 second';
    END IF;

    IF r.removed_at IS NULL THEN
      SELECT id INTO v_tp_id FROM team_persons
       WHERE team_id = r.team_id AND person_id = r.person_id
         AND removed_at IS NULL;
      IF FOUND THEN
        -- second source for the same live membership: merge, don't duplicate
        UPDATE team_persons
           SET on_roster        = team_persons.on_roster OR r.on_roster,
               coach_sort_order = COALESCE(team_persons.coach_sort_order, r.coach_sort_order),
               joined_at        = LEAST(team_persons.joined_at, v_joined)
         WHERE id = v_tp_id;
      ELSE
        INSERT INTO team_persons (team_id, person_id, joined_at,
                                  on_roster, coach_sort_order,
                                  assigned_by_user_id)
        VALUES (r.team_id, r.person_id, v_joined,
                r.on_roster, r.coach_sort_order, r.assigned_by_user_id)
        RETURNING id INTO v_tp_id;
      END IF;
    ELSE
      INSERT INTO team_persons (team_id, person_id, joined_at,
                                removed_at, removed_reason, removed_details,
                                on_roster, coach_sort_order,
                                assigned_by_user_id)
      VALUES (r.team_id, r.person_id, v_joined,
              r.removed_at, r.removed_reason, r.removed_details,
              r.on_roster, r.coach_sort_order, r.assigned_by_user_id)
      RETURNING id INTO v_tp_id;
    END IF;

    INSERT INTO team_persons_backfill_map VALUES ('roster_assignments', r.id, v_tp_id);
  END LOOP;

  -- ── B. rosters (players.person_id is unique, 100% resolvable) ──
  -- Simultaneous active memberships across teams are LEGAL (league
  -- allows multi-team players) and import as-is.  Same-team duplicate
  -- actives merge via the existence check below.  Epoch-1970 sentinel
  -- joined_at values are kept on fresh inserts (faithful to source)
  -- but never allowed to pollute merged rows.
  FOR r IN
    SELECT ro.id, ro.team_id, pl.person_id, ro.jersey_number,
           ro.joined_at AT TIME ZONE 'UTC' AS joined_at,
           ro.left_at   AT TIME ZONE 'UTC' AS left_at
      FROM rosters ro
      JOIN players pl ON pl.id = ro.player_id
     WHERE NOT EXISTS (SELECT 1 FROM team_persons_backfill_map m
                        WHERE m.source = 'rosters'
                          AND m.source_id = ro.id)
     ORDER BY ro.joined_at DESC, ro.id DESC
  LOOP
    v_joined := r.joined_at;
    IF r.left_at IS NOT NULL AND r.left_at <= v_joined THEN
      v_joined := r.left_at - interval '1 second';
    END IF;

    IF r.left_at IS NULL THEN
      SELECT id INTO v_tp_id FROM team_persons
       WHERE team_id = r.team_id AND person_id = r.person_id
         AND removed_at IS NULL;
      IF FOUND THEN
        UPDATE team_persons
           SET jersey_number = COALESCE(team_persons.jersey_number, r.jersey_number),
               -- don't let epoch-1970 sentinels pollute real dates
               joined_at     = CASE WHEN v_joined >= '2000-01-01'
                                    THEN LEAST(team_persons.joined_at, v_joined)
                                    ELSE team_persons.joined_at END
         WHERE id = v_tp_id;
      ELSE
        INSERT INTO team_persons (team_id, person_id, joined_at, jersey_number)
        VALUES (r.team_id, r.person_id, v_joined, r.jersey_number)
        RETURNING id INTO v_tp_id;
      END IF;
    ELSE
      INSERT INTO team_persons (team_id, person_id, joined_at, removed_at, jersey_number)
      VALUES (r.team_id, r.person_id, v_joined, r.left_at, r.jersey_number)
      RETURNING id INTO v_tp_id;
    END IF;

    INSERT INTO team_persons_backfill_map VALUES ('rosters', r.id, v_tp_id);
  END LOOP;

  -- ── C. Pool teams 908/909: snapshot EFFECTIVE membership ──
  INSERT INTO team_persons (team_id, person_id, joined_at, on_roster)
  SELECT vtm.team_id, p.id, vtm.assigned_at, vtm.on_roster
    FROM v_team_members vtm
    JOIN persons p
      ON p.la_user_id = vtm.leagueapps_user_id::text
   WHERE vtm.team_id IN (908, 909)
  ON CONFLICT (team_id, person_id) WHERE removed_at IS NULL DO NOTHING;

  -- ── D. Cross-team RSVP grants → direct membership ──
  INSERT INTO team_persons (team_id, person_id, joined_at, on_roster)
  SELECT ple.team_id, p.id, ple.granted_at, false
    FROM player_rsvp_eligibility ple
    JOIN persons p
      ON p.la_user_id = ple.leagueapps_user_id::text
   WHERE EXISTS (SELECT 1 FROM team_persons tp
                  WHERE tp.person_id = p.id
                    AND tp.removed_at IS NULL)
  ON CONFLICT (team_id, person_id) WHERE removed_at IS NULL DO NOTHING;
END $$;

COMMIT;
