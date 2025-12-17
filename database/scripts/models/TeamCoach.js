const SqlGenerator = require('../services/SqlGenerator');

/**
 * TeamCoach Model - Junction table linking teams to coaches
 * Database: team_coaches table
 */
class TeamCoach {
  constructor(data) {
    this.team_id = data.team_id;
    this.coach_id = data.coach_id;
    this.coach_role = data.coach_role || 'head_coach'; // 'head_coach', 'assistant_coach', 'goalkeeper_coach', 'fitness_coach'
    this.is_primary = data.is_primary !== false;
    this.is_active = data.is_active !== false;
    this.joined_at = data.joined_at || null;
    this.left_at = data.left_at || null;
    this.notes = data.notes || null;
  }

  /**
   * Generate SQL INSERT for team_coaches table
   */
  toSQL() {
    return `(${SqlGenerator.escape(this.team_id)}, ${SqlGenerator.escape(this.coach_id)}, ${SqlGenerator.escape(this.coach_role)}, ${SqlGenerator.escape(this.is_primary)}, ${SqlGenerator.escape(this.is_active)}, ${SqlGenerator.escape(this.joined_at)}, ${SqlGenerator.escape(this.left_at)}, ${SqlGenerator.escape(this.notes)})`;
  }

  /**
   * Validate required fields
   */
  static validate(data) {
    if (!data.team_id) {
      throw new Error('TeamCoach requires team_id');
    }
    if (!data.coach_id) {
      throw new Error('TeamCoach requires coach_id');
    }
    if (!data.coach_role) {
      throw new Error('TeamCoach requires coach_role');
    }
    return true;
  }
}

module.exports = TeamCoach;
