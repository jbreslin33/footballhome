-- 681 (2026-10-24) — pitch planner: start the saves fresh.
-- James: "get rid of all old saves. lets start fresh". Named whole-layout
-- saves (mig 680, field_plan_saves) are the only kind now, so the old ones
-- go: the per-pitch spots (mig 635 field_plan_spots — farFromTrees, option
-- 1, final36-25, final-slanted, finalGOOD) and the 📌 SET DEFAULT layout.
-- The live 'current' layout (what's on screen) stays.

DROP TABLE IF EXISTS field_plan_spots;
DELETE FROM field_plan_layouts WHERE kind = 'default';
