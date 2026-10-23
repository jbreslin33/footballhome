-- 664 (2026-10-23) — game: release timing parked (game/DESIGN.md §8.39).
--
-- Measured on the real matchup (fh-game-match, 60 matches per cell; LH margin):
-- neither side −0.55 ± 0.29; Lighthouse only −0.47; Ukies only +0.13; both
-- +0.02. Holding for the runner is neutral for Lighthouse and costs the
-- Ukies ~0.6 a match — the ball in behind still rarely reaches the runner
-- behind the line. The class and the walking hold stay (overlay: "wait for
-- the runner"); nobody knows it by default until the receiving end works.
UPDATE game_concepts SET status = 'queued', taught_from = NULL WHERE name = 'release-timing';
