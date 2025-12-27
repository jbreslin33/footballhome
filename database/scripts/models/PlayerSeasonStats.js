/**
 * Player Season Statistics Model
 * Represents individual player performance stats for a season
 */
class PlayerSeasonStats {
  constructor(data) {
    this.id = data.id || null;
    this.player_id = data.player_id;
    this.team_id = data.team_id;
    this.league_id = data.league_id || null;
    this.league_division_id = data.league_division_id || null;
    this.season = data.season;
    this.games_played = data.games_played || 0;
    this.goals = data.goals || 0;
    this.assists = data.assists || 0;
    this.yellow_cards = data.yellow_cards || 0;
    this.red_cards = data.red_cards || 0;
    this.minutes_played = data.minutes_played || 0;
  }

  toSQL() {
    const { SqlGenerator } = require('../services/SqlGenerator');
    
    return `INSERT INTO player_season_stats (id, player_id, team_id, league_id, league_division_id, season, games_played, goals, assists, yellow_cards, red_cards, minutes_played)
VALUES (
  ${SqlGenerator.uuid(this.id)},
  ${SqlGenerator.uuid(this.player_id)},
  ${SqlGenerator.uuid(this.team_id)},
  ${SqlGenerator.uuid(this.league_id)},
  ${SqlGenerator.uuid(this.league_division_id)},
  ${SqlGenerator.string(this.season)},
  ${this.games_played},
  ${this.goals},
  ${this.assists},
  ${this.yellow_cards},
  ${this.red_cards},
  ${this.minutes_played}
)
ON CONFLICT (player_id, team_id, league_id, league_division_id, season) 
DO UPDATE SET
  games_played = EXCLUDED.games_played,
  goals = EXCLUDED.goals,
  assists = EXCLUDED.assists,
  yellow_cards = EXCLUDED.yellow_cards,
  red_cards = EXCLUDED.red_cards,
  minutes_played = EXCLUDED.minutes_played,
  updated_at = CURRENT_TIMESTAMP;`;
  }
}

module.exports = PlayerSeasonStats;
