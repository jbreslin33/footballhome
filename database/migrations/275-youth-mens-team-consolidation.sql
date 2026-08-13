-- ═══════════════════════════════════════════════════════════════════════
-- 275-youth-mens-team-consolidation.sql
-- ═══════════════════════════════════════════════════════════════════════
--
-- Consolidates down to the 6 real outside-league teams: U8 Boys, U10
-- Boys, U12 Boys, APSL, Liga 1, Tri County Women. Every other
-- boys/mens board team (Lighthouse Youth/Adult League, Trialists,
-- Reserves) is retired — dropped from the roster board and
-- deactivated. Any real member on a retired team is unassigned
-- (team_persons.removed_at set) rather than deleted, so they
-- reappear in the 📦 Unassigned column for manual re-sort. No player
-- data is destroyed; retired teams keep their row/history for gcal
-- and match records already pointing at them (teams FK is
-- ON DELETE CASCADE elsewhere, so we deactivate, never delete).
--
-- gcal_team_aliases is append-only (see migration 121/122) — plain
-- `u8`/`u12`/`u16` are already claimed by the Lighthouse League teams
-- being retired here, so the real U8/U12 Boys teams get distinct
-- `u8 boys` / `u12 boys` aliases. U10 had no prior alias so both
-- `u10` and `u10 boys` are seeded for it.

BEGIN;

-- ─── Unassign real members from retired boys teams ──────────────────
UPDATE team_persons
   SET removed_at = now(),
       removed_reason = 'team retired - consolidated to core 6-team structure'
 WHERE team_id IN (911, 916, 917, 927, 928, 929)
   AND removed_at IS NULL;

-- ─── Unassign real members from retired mens teams ──────────────────
UPDATE team_persons
   SET removed_at = now(),
       removed_reason = 'team retired - consolidated to core 6-team structure'
 WHERE team_id IN (122, 924, 925, 926)
   AND removed_at IS NULL;

-- ─── Retire the boards: deactivate + drop from roster board ─────────
UPDATE teams
   SET is_active = false,
       board_sort_order = NULL
 WHERE id IN (911, 916, 917, 927, 928, 929, 122, 924, 925, 926);

-- ─── Gcal Team: tags for the 3 real boys teams ───────────────────────
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes) VALUES
    ('boys', 'u8 boys',  912, 'U8 Boys — real active team'),
    ('boys', 'u10',      913, 'U10 Boys — real active team'),
    ('boys', 'u10 boys', 913, 'Alt spelling for U10 Boys'),
    ('boys', 'u12 boys', 914, 'U12 Boys — real active team')
ON CONFLICT (club_alias, team_alias) DO NOTHING;

COMMIT;
