-- 1339 (2026-11-13): PPR Indoor — $100 a team for teams that played PPR fall.
-- Owner: "indoor for u10 and u12 is 100 because they give discount if you
-- were in ppr fall."  Bylaws: "League Fee - $200 per Team ($100 PPR Teams)".
-- U10 + U12 = $100 + $30 assignor = $130 each (was $230).
BEGIN;
INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, is_assumed, source_quote, checked_on, note)
SELECT 14, 'team_entry', 'per_team_season', 100.00, false, 'League Fee - $200 per Team ($100 PPR Teams)', '2026-11-13',
       'PPR teams'' price — U10 and U12 played PPR fall (owner 2026-11-13)'
 WHERE NOT EXISTS (SELECT 1 FROM league_fees WHERE season_id = 14 AND fee_kind = 'team_entry' AND amount_usd = 100.00);
UPDATE league_fees SET note = 'Teams that did not play PPR fall' WHERE season_id = 14 AND fee_kind = 'team_entry' AND amount_usd = 200.00;
UPDATE league_fees SET is_assumed = false WHERE season_id = 14 AND fee_kind = 'assignor';
UPDATE budget_lines SET amount_usd = 130.00, is_assumed = false,
       note = '$100 PPR teams'' price + $30 assignor (owner 2026-11-13)'
 WHERE id IN (8, 11);
INSERT INTO schema_migrations (filename) VALUES ('1339-ppr-indoor-fall-team-price.sql') ON CONFLICT DO NOTHING;
COMMIT;
