-- 843 (2026-10-29) — game: a dropping ball taken on the thigh or chest
-- (G4.94, game/DESIGN.md §8.92).
--
-- James 10/29: "1 then move to all" (after the churn: control of a dropping
-- ball). Until now an outfielder could touch a ball only below 0.5 m, at his
-- ground control speed: a loft (landing 9-16 m/s since G4.87's drag) could be
-- taken only once it had dropped to his knees, and mostly bobbled. Now up to
-- chest height (core::kOutfieldReachZ 1.5 m), a cushion above the feet holding
-- 1.2 × his control speed (core::controlSpeedAt) — [FH] anatomy and scale;
-- the World's capture and the Brain's race share the rule. Headers stay
-- unplayed.

BEGIN;

UPDATE game_techniques SET status = 'wired' WHERE code IN ('recv-thigh', 'recv-chest');

INSERT INTO game_technique_sources (technique_id, source_id, citation, verified)
SELECT t.id, s.id, 'core::kOutfieldReachZ / controlSpeedAt (G4.94): to the chest, a cushion holds 1.2 × his control speed [FH]', true
  FROM game_techniques t JOIN game_sources s ON s.code = 'fh'
 WHERE t.code IN ('recv-thigh', 'recv-chest')
ON CONFLICT DO NOTHING;

COMMIT;
