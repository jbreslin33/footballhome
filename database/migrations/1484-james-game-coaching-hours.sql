-- 1484 (2026-11-18) — James's game coaching hours for 2026-27 (owner: "for me
-- … 22 apsl games at 3.5 hours each. 22 liga 1 games at 2.75 hours each").
-- Game counts were already 22 each (ref_fee_seasons: APSL 12 fall + 10 spring,
-- Liga 1 12 + 10); only the hours per game change.  Training stays as it is:
-- budget line 34 "Coaching — practices" = 5 × 1½ h × $20 = $150 a week, all
-- 52 weeks (owner 2026-11-16 — same as "1.5 hours 5 days a week all year").
-- Every report reads these rows (Cash Flow, Operating Budget, 💵 Men's, Programs).
BEGIN;
UPDATE ref_fee_policies SET hours_per_game = 3.50 WHERE id = 7 AND kind = 'coaching' AND label = 'APSL';
UPDATE ref_fee_policies SET hours_per_game = 2.75 WHERE id = 8 AND kind = 'coaching' AND label = 'Liga 1';
COMMIT;
