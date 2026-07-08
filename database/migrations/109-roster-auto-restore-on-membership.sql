-- ─────────────────────────────────────────────────────────────────────
-- 109-roster-auto-restore-on-membership.sql (2026-07-08)
--
-- Companion to migration 108.  When a person GAINS an active LA
-- membership (typically via the LA-sync backfill inserting a new
-- `person_la_memberships` row, or admin re-registering them), any
-- previously-swept `roster_assignments` rows on teams that now match
-- the new membership are auto-restored.
--
-- Restore rules:
--   • Only rows soft-deleted with removed_reason='no_valid_membership'
--     are candidates (never touch admin_cleanup / delinquent / etc).
--   • The newly-inserted membership must satisfy at least one
--     team_membership_requirements row for that team.
--   • RSVP eligibility is NOT auto-recreated here — the migration-107
--     trigger `fn_grant_default_rsvp_eligibility` fires when a new
--     roster_assignment row is INSERTED, not when one is un-soft-deleted.
--     Callers who need eligibility must re-INSERT, or we can add a
--     helper later if the reversal case matters in practice.
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

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

    -- Resolve the LA user id for this person; skip if there's no alias
    -- (nothing to match against roster_assignments.leagueapps_user_id).
    SELECT epa.external_user_id
      INTO la_uid
      FROM external_person_aliases epa
     WHERE epa.person_id = NEW.person_id
       AND epa.provider = 'leagueapps'
     LIMIT 1;
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

DROP TRIGGER IF EXISTS trg_restore_rosters_on_new_membership ON person_la_memberships;
CREATE TRIGGER trg_restore_rosters_on_new_membership
    AFTER INSERT ON person_la_memberships
    FOR EACH ROW EXECUTE FUNCTION fn_restore_rosters_on_new_membership();

COMMIT;
