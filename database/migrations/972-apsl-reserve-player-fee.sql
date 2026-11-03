-- 972 (2026-11-03) — APSL player fees: $40 per main-roster player, $5 per
-- reserve.  Owner 2026-11-03: "$40 per player on main roster, $5 per reserve".
-- The Reserves team (938) gets its own entry in the APSL 2026/2027 season.
INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, division, source_url, source_quote, note)
SELECT 39, 'player_fee', 'per_player', 5.00, 'Reserves', NULL, NULL, 'Owner 2026-11-03: "$5 per reserve"'
 WHERE NOT EXISTS (SELECT 1 FROM league_fees WHERE season_id = 39 AND fee_kind = 'player_fee' AND division = 'Reserves');
UPDATE league_fees SET note = 'Main roster (owner 2026-11-03: "$40 per player on main roster")'
 WHERE season_id = 39 AND fee_kind = 'player_fee' AND amount_usd = 40.00;
INSERT INTO team_season_entries (team_id, season_id, division, status, note)
VALUES (938, 39, 'Reserves', 'entered', 'TeamPass Reserve Roster')
ON CONFLICT (team_id, season_id) DO NOTHING;
