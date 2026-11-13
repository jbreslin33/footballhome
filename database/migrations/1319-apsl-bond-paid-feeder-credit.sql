-- 1319 (2026-11-13): APSL double-check wrap-up.
-- Owner: "bond is paid." — the $1,000 one-time club bond (manual §7.1.2,
-- forfeited unless the club stays three seasons) was paid in an earlier
-- season, so it is not in the 2026-27 plan.  The $250 credit is for a 2nd
-- team in the feeder league (Liga 1), credited at year end — notes say so.

BEGIN;

UPDATE league_fees SET note = 'Manual §7.1.2: forfeited unless the club stays at least three seasons. Paid in an earlier season (owner 2026-11-13) — not in the 2026-27 plan'
 WHERE id = 4 AND fee_kind = 'bond';

UPDATE team_fee_plans SET note = 'Feeder-team credit (Liga 1 plays in the feeder league), credited at the end of the year (owner 2026-11-13)'
 WHERE entry_id = 1 AND league_fee_id = 2;
UPDATE team_season_installments SET note = 'Feeder-team credit, applied at the end of the year'
 WHERE entry_id = 1 AND amount = -250.00;
UPDATE cash_flow_planned SET label = 'APSL feeder-team credit'
 WHERE scope = 'apsl' AND label = 'APSL reserve-team credit';

INSERT INTO schema_migrations (filename) VALUES ('1319-apsl-bond-paid-feeder-credit.sql') ON CONFLICT DO NOTHING;
COMMIT;
