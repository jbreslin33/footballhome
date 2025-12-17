const SqlGenerator = require('../services/SqlGenerator');

/**
 * TeamPlayer Model
 * Represents the junction table between teams and players
 * Schema: team_id, player_id, jersey_number, is_active, joined_date, left_date, notes
 */
class TeamPlayer {
  constructor(data) {
    this.team_id = data.team_id;
    this.player_id = data.player_id;
    this.jersey_number = data.jersey_number || null;
    this.is_active = data.is_active !== false;
    this.joined_date = data.joined_date || null;
    this.left_date = data.left_date || null;
    this.notes = data.notes || null;
  }

  toSQL() {
    return `(${SqlGenerator.escape(this.team_id)}, ${SqlGenerator.escape(this.player_id)}, ${SqlGenerator.escape(this.jersey_number)}, ${SqlGenerator.escape(this.is_active)}, ${SqlGenerator.escape(this.joined_date)}, ${SqlGenerator.escape(this.left_date)}, ${SqlGenerator.escape(this.notes)})`;
  }
}

module.exports = TeamPlayer;
