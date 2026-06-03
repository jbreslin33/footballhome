-- ============================================================================
-- Training & Pickup as Teams
-- Make Training Lighthouse and Pickup Lighthouse first-class teams so they
-- appear in team-selection with schedule / roster / lineup / RSVPs.
--
-- Also adds:
--   - players.primary_jersey_number (default jersey across teams)
--   - match_lineup_metadata.is_intra_squad (toggle for white/blue scrimmage)
--   - match_lineups.squad_color ('white' | 'blue' | NULL)
--
-- Idempotent — safe to re-run.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Jersey numbers: primary + per-team override (already exists in rosters)
-- ----------------------------------------------------------------------------
ALTER TABLE players
    ADD COLUMN IF NOT EXISTS primary_jersey_number VARCHAR(10);

COMMENT ON COLUMN players.primary_jersey_number IS
    'Default jersey number for this player. Per-team override lives in rosters.jersey_number.';

-- ----------------------------------------------------------------------------
-- 2. Intra-squad lineup support (white vs blue scrimmage on one event)
-- ----------------------------------------------------------------------------
ALTER TABLE match_lineup_metadata
    ADD COLUMN IF NOT EXISTS is_intra_squad BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE match_lineups
    ADD COLUMN IF NOT EXISTS squad_color VARCHAR(10);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.check_constraints
        WHERE constraint_name = 'match_lineups_squad_color_check'
    ) THEN
        ALTER TABLE match_lineups
            ADD CONSTRAINT match_lineups_squad_color_check
            CHECK (squad_color IS NULL OR squad_color IN ('white','blue'));
    END IF;
END $$;

COMMENT ON COLUMN match_lineup_metadata.is_intra_squad IS
    'When true the lineup is split into two color squads (White XI + Blue XI).';
COMMENT ON COLUMN match_lineups.squad_color IS
    'Intra-squad mode: ''white'' or ''blue''. NULL for normal single-team lineups.';

-- ----------------------------------------------------------------------------
-- 3. Create Training Lighthouse and Pickup Lighthouse teams
--    (Internal division 73 / club 134 = Lighthouse 1893 SC)
-- ----------------------------------------------------------------------------
INSERT INTO teams (name, club_id, division_id, source_system_id)
VALUES
    ('Training Lighthouse', 134, 73, 5),
    ('Pickup Lighthouse',   134, 73, 5)
ON CONFLICT (division_id, name) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 4. Link the existing chats to the new teams
-- ----------------------------------------------------------------------------
UPDATE chats SET team_id = (SELECT id FROM teams WHERE name='Training Lighthouse' AND division_id=73)
    WHERE id = 4 AND team_id IS NULL;

UPDATE chats SET team_id = (SELECT id FROM teams WHERE name='Pickup Lighthouse' AND division_id=73)
    WHERE id = 5 AND team_id IS NULL;

-- ----------------------------------------------------------------------------
-- 5. Add the founding user (coach id 1 = James Breslin) as coach of both
-- ----------------------------------------------------------------------------
INSERT INTO team_coaches (team_id, coach_id)
SELECT t.id, 1
FROM teams t
WHERE t.name IN ('Training Lighthouse','Pickup Lighthouse')
  AND t.division_id = 73
  AND NOT EXISTS (
      SELECT 1 FROM team_coaches tc
      WHERE tc.team_id = t.id AND tc.coach_id = 1 AND tc.ended_at IS NULL
  );

-- ----------------------------------------------------------------------------
-- 6. Backfill roster: union of every active player on any Lighthouse 1893 SC
--    team. Players come and go from the pool; this can be re-run safely.
-- ----------------------------------------------------------------------------
INSERT INTO rosters (team_id, player_id)
SELECT t_new.id, src.player_id
FROM teams t_new
CROSS JOIN LATERAL (
    SELECT DISTINCT r.player_id
    FROM rosters r
    JOIN teams t_src ON t_src.id = r.team_id
    WHERE t_src.club_id = 134
      AND t_src.id <> t_new.id
      AND r.left_at IS NULL
) src
WHERE t_new.name IN ('Training Lighthouse','Pickup Lighthouse')
  AND t_new.division_id = 73
  AND NOT EXISTS (
      SELECT 1 FROM rosters r2
      WHERE r2.team_id = t_new.id
        AND r2.player_id = src.player_id
        AND r2.left_at IS NULL
  );
