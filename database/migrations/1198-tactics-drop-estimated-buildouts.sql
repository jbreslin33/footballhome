-- 1198 (2026-11-09): 🎯 Tactics — tactic_buildout_shapes stays measured.
--
-- Owner: focus the trainer on the Premier League sides first, Lighthouse
-- plans later, "this way the premier league stuff is not contaminated".
-- Migs 1196/1197 put [FH] ESTIMATED goal-kick shapes for 4-2-3-1 and
-- 4-4-2 into tactic_buildout_shapes, the table the engine is meant to read
-- (§8.137).  Removed; the plans built on them (2-3-2-3 v 4-2-3-1, 3-4-3
-- (2-3) v 4-4-2) keep their own copies in tactic_state_opponents, so the
-- board is unchanged.  4-3-3 (James + DFL) stays.

DELETE FROM tactic_buildout_shapes b
 USING formations f
 WHERE f.id = b.formation_id AND f.code IN ('4-2-3-1', '4-4-2');
