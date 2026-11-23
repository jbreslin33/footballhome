-- 1750 (2026-11-23): APSL budget — reserves list 50 × $5, Game in Frame 4 × $100.
--
-- Owner 2026-11-23: "apsl budget. League fee 1750. refs 310 x 11, player add
-- fees 35x40 to prepare for adds up to 35 for main. liga 1 50x5 to allow for
-- extra add/drop on liga1 to reserves apsl. physio budget 100 per home game
-- 11 home games. game in frame filming 4x100".
--
-- Already so: club fee $1,750, refs 11 × $310, main 35 × $40, physio 11 × $100.
-- Changed here: reserves list 35 → 50 players at $5 (Liga 1 men added to and
-- dropped from the APSL reserves list), filming 3 × $75 → 4 × $100.
-- 2027/28 was rolled forward from 2026/27, so it follows.
-- Not named by the owner and left as they were: 2 rented-field home games
-- ($250 each) and the $250 feeder credit.

BEGIN;

-- Game in Frame: $100 a game (was $75), 4 games (was 3).
UPDATE league_fees SET amount_usd = 100.00, checked_on = '2026-11-23',
       note = 'Game in Frame: films and announces the game (owner 2026-11-23: $100 a game)'
 WHERE id = 52 AND fee_kind = 'game_film';
UPDATE league_fees SET amount_usd = 100.00, checked_on = '2026-11-23'
 WHERE id = 86 AND fee_kind = 'game_film';
UPDATE team_fee_plans SET quantity = 4, note = '4 games filmed by Game in Frame (owner 2026-11-23)'
 WHERE id IN (16, 34);

-- Reserves list: 50 players so Liga 1 men can be added and dropped all year.
UPDATE team_fee_plans SET quantity = 50,
       note = '50 planned so Liga 1 men can be added to and dropped from the reserves list: 26 registered + 24 adds (owner 2026-11-23)'
 WHERE id IN (5, 42);

-- The adds still to pay this year: 24 × $5 (was 9 × $5).
UPDATE team_season_installments SET amount = 120.00, note = 'Future reserves adds, 24 × $5'
 WHERE id = 40 AND entry_id = 16;

INSERT INTO schema_migrations (filename) VALUES ('1750-apsl-budget-reserves-50-film-4x100.sql') ON CONFLICT DO NOTHING;
COMMIT;
