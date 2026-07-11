-- Migration 113: reorder the boys-domain roster_columns so the three
-- Lighthouse Youth League age tiers sit immediately to the right of
-- the (client-rendered) Unassigned column, in ascending age order.
--
-- Frontend renders Unassigned at index 0 always (see boys-roster.js
-- `_renderColumns`); every other column is DB-driven, sorted by
-- roster_columns.sort_order ASC.  So this migration only touches
-- sort_order — no rows are added, removed, or relabeled.
--
-- Target order (post-migration):
--   0 · 📦 Unassigned                          (virtual, client-only)
--   1 · 🏰 Lighthouse Youth League U8          (was sort_order=5)
--   2 · 🏰 Lighthouse Youth League U12         (was sort_order=6)
--   3 · 🏰 Lighthouse Youth League U16         (was sort_order=1)
--   4 · 👦 U8 Boys                             (was sort_order=2)
--   5 · 👦 U10 Boys                            (was sort_order=3)
--   6 · 👦 U12 Boys                            (was sort_order=4)
-- 999 · 🚨 Dues Owed                           (unchanged)
--
-- Uses a two-phase shuffle (add 1000, then subtract to final) to
-- avoid needing per-row transient values and to keep the migration
-- readable.  There is no UNIQUE constraint on (domain, sort_order),
-- so we could theoretically overwrite in place, but the two-phase
-- approach is safe under any future constraint and makes the intent
-- explicit.
--
-- Idempotent: each UPDATE targets a specific team_id, so re-running
-- the migration after it's applied simply rewrites the same values.

BEGIN;

-- Phase 1 — park every boys-domain column (except the Dues sentinel)
-- in a temporary 1000-range so the final assignments below can't
-- collide with the existing values mid-migration.
UPDATE roster_columns
   SET sort_order = sort_order + 1000,
       updated_at = NOW()
 WHERE domain = 'boys'
   AND sort_order < 999;

-- Phase 2 — assign each column its final sort_order.
UPDATE roster_columns SET sort_order = 1, updated_at = NOW() WHERE domain = 'boys' AND team_id = 916;  -- LLY U8
UPDATE roster_columns SET sort_order = 2, updated_at = NOW() WHERE domain = 'boys' AND team_id = 917;  -- LLY U12
UPDATE roster_columns SET sort_order = 3, updated_at = NOW() WHERE domain = 'boys' AND team_id = 911;  -- LLY U16
UPDATE roster_columns SET sort_order = 4, updated_at = NOW() WHERE domain = 'boys' AND team_id = 912;  -- U8 Boys admin
UPDATE roster_columns SET sort_order = 5, updated_at = NOW() WHERE domain = 'boys' AND team_id = 913;  -- U10 Boys admin
UPDATE roster_columns SET sort_order = 6, updated_at = NOW() WHERE domain = 'boys' AND team_id = 914;  -- U12 Boys admin
-- team 915 (Dues Owed) stays at sort_order=999 — untouched by phase 1.

COMMIT;
