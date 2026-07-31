-- ─────────────────────────────────────────────────────────────────────
-- 251-group-model-phase2.sql (2026-07-31)
--
-- Phase 2 DB companion to the backend cutover
-- (docs/adr/2026-07-30-roster-membership-rsvp-normalization.md).
-- Ships in the same deploy window as the team_persons backend:
--   1. Re-runs the idempotent backfill (closes the drift window since
--      migration 250 ran).
--   2. Repoints roster_positions from rosters → team_persons via the
--      provenance map.
--   3. Ports lineup-change notifications to team_persons.
--   4. Clears mutex_group on official teams — league rules allow
--      multi-team players; staging/admin buckets keep their mutex.
--
-- The old tables (rosters/roster_assignments/player_rsvp_eligibility)
-- and their triggers stay in place, unwritten, until Phase 3 drops
-- them — that is the rollback story.
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

-- ═══ 1. Drift close ══════════════════════════════════════════════════
SELECT fn_backfill_team_persons();

-- ═══ 2. roster_positions repoint ═════════════════════════════════════
-- Every rosters row was mapped by fn_backfill_team_persons(), so this
-- is a mechanical join.  Belt-and-braces: delete any position row
-- whose roster row somehow never mapped (0 expected).
DELETE FROM roster_positions rp
 WHERE NOT EXISTS (SELECT 1 FROM team_persons_backfill_map m
                    WHERE m.source = 'rosters' AND m.source_id = rp.roster_id);

UPDATE roster_positions rp
   SET roster_id = m.team_person_id
  FROM team_persons_backfill_map m
 WHERE m.source = 'rosters'
   AND m.source_id = rp.roster_id;

ALTER TABLE roster_positions
    DROP CONSTRAINT roster_positions_roster_id_fkey,
    ADD CONSTRAINT roster_positions_roster_id_fkey
        FOREIGN KEY (roster_id) REFERENCES team_persons(id) ON DELETE CASCADE;

COMMENT ON COLUMN roster_positions.roster_id IS
    'team_persons.id since migration 251 (was rosters.id)';

-- ═══ 3. Lineup-change notifications ══════════════════════════════════
-- fn_notify_lineup_change branches on TG_TABLE_NAME with a safe
-- refresh-all fallback; give team_persons an explicit branch mirroring
-- the old rosters one and attach the trigger.
CREATE OR REPLACE FUNCTION fn_notify_team_persons_change()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  -- Same payload the 'rosters' branch of fn_notify_lineup_change
  -- emitted: roster changes affect the R badge across multiple teams,
  -- cheapest + safest is to refresh everything visible.
  PERFORM pg_notify('fh_lineups',
                    '{"kind":"roster","affected_team_ids":"all"}');
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_notify_team_persons ON team_persons;
CREATE TRIGGER trg_notify_team_persons
    AFTER INSERT OR UPDATE OR DELETE ON team_persons
    FOR EACH ROW EXECUTE FUNCTION fn_notify_team_persons_change();

-- ═══ 4. Multi-team placement (league rules allow it) ═════════════════
-- Official teams leave their mutex group; a player placed on APSL
-- stays on Liga 1.  Staging buckets (U8/U10/U12 Admin) and Dues
-- buckets keep mutex — a kid can't be in two age buckets.
UPDATE teams SET mutex_group = NULL WHERE kind = 'official';

COMMIT;
