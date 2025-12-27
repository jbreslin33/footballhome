const SqlGenerator = require('../services/SqlGenerator');

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
    return `  (${SqlGenerator.escape(this.id)}, ${SqlGenerator.escape(this.player_id)}, ${SqlGenerator.escape(this.team_id)}, ${SqlGenerator.escape(this.league_id)}, ${SqlGenerator.escape(this.league_division_id)}, ${SqlGenerator.escape(this.season)}, ${SqlGenerator.escape(this.games_played)}, ${SqlGenerator.escape(this.goals)}, ${SqlGenerator.escape(this.assists)}, ${SqlGenerator.escape(this.yellow_cards)}, ${SqlGenerator.escape(this.red_cards)}, ${SqlGenerator.escape(this.minutes_played)})`;
  }
}

module.exports = PlayerSeasonStats;
