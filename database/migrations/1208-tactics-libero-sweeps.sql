-- 1208 (2026-11-09): 🎯 Tactics — the libero sweeps instead of standing on
-- our keeper.  Every match-up plan (migs 1196/1197/1205: plans 15, 16, 17,
-- 23, 24) has one man on 'libero' (concept 26, "The free man at the back").
-- His rule was 'home' and the match shapes draw him at y 15–18, so behind a
-- high press he stood 30 m back, on top of the keeper.  Owner 11/9: fix it.
--
-- New rule 'sweep' (SweepRule, shared/tactics/TacticGeometry.hpp): dist_m
-- goal-side of their deepest outfielder (behind the man-markers, who stand
-- 2 m goal-side of their men), across lane_t of the way from the middle
-- toward the ball.  8 m / 0.33 = [FH] numbers, not measured.

INSERT INTO tactic_job_rules (code, label, sort_order)
VALUES ('sweep', 'Behind their deepest man, leaning to the ball side', 9)
ON CONFLICT (code) DO NOTHING;

UPDATE tactic_job_kinds SET rule = 'sweep', dist_m = 8.0, lane_t = 0.33
 WHERE code = 'libero';
