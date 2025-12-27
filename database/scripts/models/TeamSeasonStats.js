const SqlGenerator = require('../services/SqlGenerator');

/**
 * Team Season Statistics Model
 * Represents a team's record/standings for a season
 */
class TeamSeasonStats {
  constructor(data) {
    this.id = data.id;
    this.team_id = data.team_id;
    this.league_id = data.league_id || null;
    this.league_division_id = data.league_division_id || null;
    this.season = data.season;
    this.games_played = data.games_played || 0;
    this.wins = data.wins || 0;
    this.losses = data.losses || 0;
    this.ties = data.ties || 0;
    this.goals_for = data.goals_for || 0;
    this.goals_against = data.goals_against || 0;
    this.goal_differential = data.goal_differential || 0;
    this.points = data.points || 0;
    this.win_percentage = data.win_percentage || null;
    this.updated_at = data.updated_at || new Date().toISOString();
  }

  toSQL() {
    return `  (${SqlGenerator.escape(this.id)}, ${SqlGenerator.escape(this.team_id)}, ${SqlGenerator.escape(this.league_id)}, ${SqlGenerator.escape(this.league_division_id)}, ${SqlGenerator.escape(this.season)}, ${SqlGenerator.escape(this.games_played)}, ${SqlGenerator.escape(this.wins)}, ${SqlGenerator.escape(this.losses)}, ${SqlGenerator.escape(this.ties)}, ${SqlGenerator.escape(this.goals_for)}, ${SqlGenerator.escape(this.goals_against)}, ${SqlGenerator.escape(this.goal_differential)}, ${SqlGenerator.escape(this.points)}, ${SqlGenerator.escape(this.win_percentage)}, ${SqlGenerator.escape(this.updated_at)})`;
  }
}

module.exports = TeamSeasonStats;
