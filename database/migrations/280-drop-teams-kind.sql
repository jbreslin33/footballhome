-- ═══════════════════════════════════════════════════════════════════════
-- 280-drop-teams-kind.sql
-- ═══════════════════════════════════════════════════════════════════════
--
-- Drops teams.kind (official/internal/admin_bucket), added by migration
-- 250 (2026-07-31) as part of the group-model design. Survey 2026-08-14
-- found it's never read by any live backend query or frontend screen —
-- every reference across the codebase is either a one-time migration
-- backfill/UPDATE that already ran (250, 251, 265) or an INSERT column
-- list on a since-applied migration (252, 254, 273, 276). The value is
-- also stale where it does exist: 912/913/914 (U8/U10/U12) were tagged
-- 'internal' on 2026-07-31 while still placeholder "boys staging
-- buckets"; they're now real active travel teams same as 931/932
-- (U6/U19, tagged 'official') but were never relabeled. Rather than fix
-- the label, drop the column — nothing depends on it.
--
-- Dropping the column also drops teams_kind_check (CHECK constraint
-- lives on the column) automatically.
-- ═══════════════════════════════════════════════════════════════════════

BEGIN;

ALTER TABLE teams DROP COLUMN kind;

COMMIT;
