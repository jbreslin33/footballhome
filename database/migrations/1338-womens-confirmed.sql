-- 1338 (2026-11-13): Women's confirmed.
-- Owner: "refs every game, jamie is 15, roster is 35."
BEGIN;
UPDATE team_fee_plans p SET quantity = 35, is_assumed = false, note = 'Roster of 35 (owner 2026-11-13)'
  FROM league_fees f WHERE f.id = p.league_fee_id AND p.entry_id = 3 AND f.fee_kind = 'player_fee';
UPDATE team_fee_plans p SET is_assumed = false, note = '11 fall + 11 spring Sunday games, refs every game (owner 2026-11-13)'
  FROM league_fees f WHERE f.id = p.league_fee_id AND p.entry_id = 3 AND f.fee_kind = 'referee';
UPDATE ref_fee_seasons SET is_assumed = false WHERE policy_id = 6;
UPDATE teams SET max_roster = 35 WHERE id = 901;
UPDATE ref_fee_policies SET note = 'Jamie: 2 h per game × $15 (owner 2026-11-13), home and away; 11 Sunday games Sep–Nov + 11 Mar–Jun' WHERE id = 9;
INSERT INTO schema_migrations (filename) VALUES ('1338-womens-confirmed.sql') ON CONFLICT DO NOTHING;
COMMIT;
