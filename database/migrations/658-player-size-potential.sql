-- 658 (2026-10-23) — height and weight on the club's player record; the
-- game's player potential.
--
-- James: "add height and weight to db for full app and game to use" /
-- "you know the dob of our players so factor in room for improvement and
-- that younger players are gonna be talented but dumb and will be more
-- skilled later".
-- players.height_cm already existed; weight joins it so the club app and
-- the game read one physical profile per person.
ALTER TABLE players ADD COLUMN IF NOT EXISTS weight_kg SMALLINT CHECK (weight_kg BETWEEN 30 AND 200);
COMMENT ON COLUMN players.height_cm IS 'Height in cm — the club app and the game (aerial duels, mig 658).';
COMMENT ON COLUMN players.weight_kg IS 'Weight in kg — the club app and the game (strength in duels) (mig 658).';
ALTER TABLE game_demo_players ADD COLUMN IF NOT EXISTS potential SMALLINT CHECK (potential BETWEEN 0 AND 100);
COMMENT ON COLUMN game_demo_players.potential IS 'Where his ability can grow to (0-100): young players have room to improve (game/scripts/load_squads.py, mig 658).';
