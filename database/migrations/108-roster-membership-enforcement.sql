-- ─────────────────────────────────────────────────────────────────────
-- 108-roster-membership-enforcement.sql (2026-07-08)
--
-- PERMANENT rule: LA membership is the source of truth for who can be
-- on a roster.
--
--   • Selection teams (APSL, Liga 1, Liga 2, Adult League, U23 Men,
--     Puerto Rico, Dominican Republic, Old Timers): require an active
--     "active-variant" LA membership.  Boys 1897 counts too, so kids
--     who play up (Nelson Cruz) don't get bounced.
--
--   • Pool teams (Practice 908, Pickup 909): require any active LA
--     membership including the pickup variants (so casual pickup
--     members can play pickup but NOT selection).
--
-- Enforcement:
--   1. `team_membership_requirements` — team_id → allowed LA program_id
--      (many-to-many).  Seed data is populated here; further teams can
--      be added via INSERT.
--   2. `fn_sweep_invalid_rosters()` — soft-deletes any `roster_assignments`
--      row whose user lacks a matching active membership; also revokes
--      the derived `player_rsvp_eligibility` rows.
--   3. BEFORE INSERT/UPDATE trigger on `roster_assignments` —
--      rejects new writes that violate the rule.
--   4. AFTER UPDATE/DELETE trigger on `person_la_memberships` —
--      re-runs the sweep when a membership ends.
--   5. Backend callers invoke `SELECT fn_sweep_invalid_rosters()` at the
--      top of every roster-read endpoint so a page load NEVER surfaces
--      an out-of-compliance member.
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

-- ── 1. Team → allowed programs mapping ────────────────────────────────
CREATE TABLE IF NOT EXISTS team_membership_requirements (
    team_id        INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    la_program_id  BIGINT  NOT NULL REFERENCES leagueapps_programs(program_id) ON DELETE CASCADE,
    PRIMARY KEY (team_id, la_program_id)
);

COMMENT ON TABLE team_membership_requirements IS
  'Which LA programs qualify a user for a team roster. A user needs at least one active person_la_membership row matching one of the team''s allowed program_ids.';

-- Program IDs (per leagueapps_programs):
--   5039300  Men''s 1893 Soccer Membership       (men,   active)
--   5070075  Men''s 1893 Pickup Soccer Membership (men,  pickup)
--   5039252  Boys 1897 Soccer Membership         (boys,  active)  — Nelson Cruz case
--   5064618  Boys 1897 Pickup Soccer Membership  (boys,  pickup)
--   5039340  Women's 1895 Soccer Membership      (women, active)
--   5064686  Women's 1895 Pickup Soccer Membership (women, pickup)
--   5039357  Girls 1898 Soccer Membership        (girls, active)
--   5064662  Girls 1898 Pickup Soccer Membership (girls, pickup)

-- Selection teams (mens domain): active Men''s 1893 OR active Boys 1897
INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT t.id, p.program_id
  FROM teams t
  CROSS JOIN (VALUES (5039300::bigint), (5039252::bigint)) AS p(program_id)
 WHERE t.id IN (35, 120, 121, 122, 903, 904, 905, 456)  -- APSL, Liga1, Liga2, Adult, U23, DR, PR, Old Timers
ON CONFLICT DO NOTHING;

-- Pool teams (Practice + Pickup): active Men''s 1893 OR pickup Men''s
INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT t.id, p.program_id
  FROM teams t
  CROSS JOIN (VALUES (5039300::bigint), (5070075::bigint)) AS p(program_id)
 WHERE t.id IN (908, 909)  -- Practice, Pickup
ON CONFLICT DO NOTHING;

-- Women's Club
INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT t.id, p.program_id
  FROM teams t
  CROSS JOIN (VALUES (5039340::bigint)) AS p(program_id)
 WHERE t.id IN (583, 901, 902)  -- Women's Club, Tri County Women, U23 Women
ON CONFLICT DO NOTHING;

-- ── 2. Sweep function: soft-delete out-of-compliance rows ─────────────
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
                 JOIN external_person_aliases epa
                   ON epa.provider = 'leagueapps'
                  AND epa.external_user_id = ra.leagueapps_user_id::text
                 JOIN person_la_memberships plm
                   ON plm.person_id = epa.person_id
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

-- ── 3. Trigger: reject new INSERT/UPDATE that would violate ───────────
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
          JOIN external_person_aliases epa
            ON epa.provider = 'leagueapps'
           AND epa.external_user_id = NEW.leagueapps_user_id::text
          JOIN person_la_memberships plm
            ON plm.person_id = epa.person_id
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

DROP TRIGGER IF EXISTS trg_check_roster_membership ON roster_assignments;
CREATE TRIGGER trg_check_roster_membership
    BEFORE INSERT OR UPDATE ON roster_assignments
    FOR EACH ROW EXECUTE FUNCTION fn_check_roster_membership();

-- ── 4. Trigger: sweep whenever a membership ends ──────────────────────
CREATE OR REPLACE FUNCTION fn_sweep_on_membership_change() RETURNS TRIGGER AS $$
BEGIN
    -- Fire when an open membership closes, or one is deleted.
    IF TG_OP = 'DELETE' THEN
        IF OLD.ended_at IS NULL THEN
            PERFORM fn_sweep_invalid_rosters();
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.ended_at IS NULL AND NEW.ended_at IS NOT NULL THEN
            PERFORM fn_sweep_invalid_rosters();
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sweep_on_membership_change ON person_la_memberships;
CREATE TRIGGER trg_sweep_on_membership_change
    AFTER UPDATE OR DELETE ON person_la_memberships
    FOR EACH ROW EXECUTE FUNCTION fn_sweep_on_membership_change();

-- ── 5. Initial sweep of existing data ─────────────────────────────────
-- Now that the machinery is in place, clean up existing violations.
SELECT fn_sweep_invalid_rosters() AS initial_sweep_count;

COMMIT;
