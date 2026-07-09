-- ─────────────────────────────────────────────────────────────────────
-- 110-players-row-on-la-membership.sql (2026-07-09)
--
-- Ensure every LA member has a `players` row.  The roster / squad
-- planner endpoints join on `players.person_id`, so a person without a
-- players row is invisible on those pages even if their LA membership
-- is active.  Before this migration, a `players` row was only created
-- when the LA sync happened to also assign the person to a team roster,
-- so brand-new signups who hadn't yet been placed on a team were missing
-- from the mens roster page (e.g. Mars Milligan, joined 2026-07-09).
--
-- Applies to ANY LA membership (not just mens) so future boys / girls /
-- womens signups are covered by the same guarantee.
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

-- ── Trigger function ──────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_ensure_players_row_on_la_membership()
RETURNS TRIGGER AS $$
BEGIN
    -- Only meaningful for active memberships; end-dated inserts (historical
    -- backfill) don't need a players row.
    IF NEW.ended_at IS NOT NULL THEN
        RETURN NEW;
    END IF;

    INSERT INTO players (person_id)
    VALUES (NEW.person_id)
    ON CONFLICT (person_id) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_ensure_players_row_on_la_membership
    ON person_la_memberships;

CREATE TRIGGER trg_ensure_players_row_on_la_membership
    AFTER INSERT ON person_la_memberships
    FOR EACH ROW
    EXECUTE FUNCTION fn_ensure_players_row_on_la_membership();

-- ── One-time backfill ─────────────────────────────────────────────────
-- Cover anyone who currently holds an active LA membership but has no
-- `players` row yet.  Idempotent via the unique constraint on
-- players.person_id.
INSERT INTO players (person_id)
SELECT DISTINCT plm.person_id
FROM person_la_memberships plm
WHERE plm.ended_at IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM players pl WHERE pl.person_id = plm.person_id
  )
ON CONFLICT (person_id) DO NOTHING;

COMMIT;
