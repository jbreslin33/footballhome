-- 641 (2026-10-22) — game: lineups you can change, and "set lineup from
-- Game Center" (game/DESIGN.md §8.28).
--
-- James: "allow for lineup change and for set lineup from game center …
-- set lineup from game center for game".
--
-- lineup_slot = the formation slot a player STARTS in (1 = GK … 11), NULL
-- = bench. Starters are no longer "the first 11 shirts": shirts stay the
-- squad numbers, the lineup moves. The daemon and /api/game/roster both
-- order players by lineup_slot then shirt (index = slot).
-- game_demo_teams.club_team_id links a game team to the club team whose
-- Game Center lineups it can import (Lighthouse APSL → team 35).

ALTER TABLE game_demo_players ADD COLUMN IF NOT EXISTS lineup_slot SMALLINT
    CHECK (lineup_slot BETWEEN 1 AND 11);
CREATE UNIQUE INDEX IF NOT EXISTS game_demo_players_lineup_slot
    ON game_demo_players (team_id, lineup_slot) WHERE lineup_slot IS NOT NULL;
COMMENT ON COLUMN game_demo_players.lineup_slot IS 'Starting formation slot 1-11 (1 = GK), NULL = bench (mig 641).';

-- Today's starters = shirts 1-11 (migs 636/640 seated them that way).
UPDATE game_demo_players SET lineup_slot = shirt WHERE shirt BETWEEN 1 AND 11 AND lineup_slot IS NULL;

ALTER TABLE game_demo_teams ADD COLUMN IF NOT EXISTS club_team_id INT REFERENCES teams(id) ON DELETE SET NULL;
UPDATE game_demo_teams SET club_team_id = 35 WHERE name = 'Lighthouse APSL';
