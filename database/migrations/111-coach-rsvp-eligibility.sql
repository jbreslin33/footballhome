-- ─────────────────────────────────────────────────────────────────────
-- 111-coach-rsvp-eligibility.sql (2026-07-10)
--
-- Create `coach_rsvp_eligibility` — the coach-side parallel of
-- `player_rsvp_eligibility`.  Two purposes:
--
--   1. Single-lookup replacement for the 3-table join
--      (team_coaches → coaches → users) that MyController currently
--      does on every /my/week, /my/rsvp, and /my/event-rsvps call.
--
--   2. First-class support for `manual_grant` rows — one-off "cover
--      shift" grants that let a coach RSVP on a team they don't
--      officially coach.  Adding/removing a manual grant no longer
--      pollutes the `team_coaches` audit trail.
--
-- Rows come from two sources, tracked via the `source` column:
--   • 'team_coach'   — auto-mirrored from team_coaches by the trigger
--                      below.  Represents official team assignments.
--   • 'manual_grant' — inserted by admins for cover shifts / temp
--                      coaching.  Standalone, may have expires_at.
--
-- Optional expires_at gate lets manual grants auto-lapse without a
-- cleanup job (queries filter WHERE expires_at IS NULL OR > NOW()).
--
-- coach_id references users.id (NOT coaches.id) to match
-- coach_rsvp_history.coach_id, so callers can do a single-table join
-- between eligibility and RSVP history.
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

-- ── Table ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS coach_rsvp_eligibility (
    coach_id            integer     NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    team_id             integer     NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    source              text        NOT NULL CHECK (source IN ('team_coach', 'manual_grant')),
    granted_at          timestamptz NOT NULL DEFAULT NOW(),
    granted_by_user_id  integer              REFERENCES users(id),
    expires_at          timestamptz,
    notes               text,
    PRIMARY KEY (coach_id, team_id, source)
);

CREATE INDEX IF NOT EXISTS idx_coach_rsvp_eligibility_team
    ON coach_rsvp_eligibility (team_id);
CREATE INDEX IF NOT EXISTS idx_coach_rsvp_eligibility_team_coach
    ON coach_rsvp_eligibility (team_id, coach_id);
-- Partial index skipping already-expired grants.  Filters on a static
-- NULL check only (NOW() can't appear here because it's not IMMUTABLE);
-- query-time filter `expires_at IS NULL OR expires_at > NOW()` still
-- benefits from the (team_id, coach_id) index above and from the
-- selective NULL filter here for the common "no expiry" case.
CREATE INDEX IF NOT EXISTS idx_coach_rsvp_eligibility_no_expiry
    ON coach_rsvp_eligibility (team_id, coach_id)
 WHERE expires_at IS NULL;

-- ── Trigger: mirror team_coaches → coach_rsvp_eligibility ────────────
-- Handles the users.id resolution (team_coaches.coach_id FKs
-- coaches.id; we need users.id).  If the coach has no user account,
-- silently skip — mirrors the current runtime behaviour where such
-- coaches can't RSVP anyway.
CREATE OR REPLACE FUNCTION fn_sync_coach_rsvp_eligibility_from_team_coaches()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id     integer;
    v_old_user_id integer;
BEGIN
    IF TG_OP = 'DELETE' THEN
        SELECT u.id INTO v_old_user_id
          FROM coaches c
          JOIN users u ON u.person_id = c.person_id
         WHERE c.id = OLD.coach_id
         LIMIT 1;

        IF v_old_user_id IS NOT NULL THEN
            DELETE FROM coach_rsvp_eligibility
             WHERE coach_id = v_old_user_id
               AND team_id  = OLD.team_id
               AND source   = 'team_coach';
        END IF;
        RETURN OLD;
    END IF;

    -- INSERT or UPDATE: resolve NEW coach's users.id
    SELECT u.id INTO v_user_id
      FROM coaches c
      JOIN users u ON u.person_id = c.person_id
     WHERE c.id = NEW.coach_id
     LIMIT 1;

    -- No user account → nothing to mirror (coach can't RSVP anyway)
    IF v_user_id IS NULL THEN
        RETURN NEW;
    END IF;

    IF NEW.ended_at IS NULL THEN
        -- Active assignment → ensure mirror row exists
        INSERT INTO coach_rsvp_eligibility (coach_id, team_id, source)
        VALUES (v_user_id, NEW.team_id, 'team_coach')
        ON CONFLICT (coach_id, team_id, source) DO NOTHING;
    ELSE
        -- Assignment ended → remove mirror row
        DELETE FROM coach_rsvp_eligibility
         WHERE coach_id = v_user_id
           AND team_id  = NEW.team_id
           AND source   = 'team_coach';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_coach_rsvp_eligibility
    ON team_coaches;

CREATE TRIGGER trg_sync_coach_rsvp_eligibility
    AFTER INSERT OR UPDATE OR DELETE ON team_coaches
    FOR EACH ROW
    EXECUTE FUNCTION fn_sync_coach_rsvp_eligibility_from_team_coaches();

-- ── One-time backfill ─────────────────────────────────────────────────
-- Every currently-active team_coaches row whose coach has a user account.
INSERT INTO coach_rsvp_eligibility (coach_id, team_id, source)
SELECT u.id, tc.team_id, 'team_coach'
  FROM team_coaches tc
  JOIN coaches c ON c.id        = tc.coach_id
  JOIN users   u ON u.person_id = c.person_id
 WHERE tc.ended_at IS NULL
ON CONFLICT (coach_id, team_id, source) DO NOTHING;

COMMIT;
