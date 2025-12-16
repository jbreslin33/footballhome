const SqlGenerator = require('../services/SqlGenerator');

/**
 * Team Model
 * Represents a sports team
 * Schema: id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active
 */
class Team {
  constructor(data) {
    this.id = data.id;
    this.name = data.name;
    this.division_id = data.division_id || data.sport_division_id; // Accept both names
    this.league_division_id = data.league_division_id || null;
    this.season = data.season || null;
    this.age_group = data.age_group || null;
    this.skill_level = data.skill_level || null;
    this.description = data.description || null;
    this.logo_url = data.logo_url || null;
    this.primary_color = data.primary_color || null;
    this.secondary_color = data.secondary_color || null;
    this.is_active = data.is_active !== false;
    this.created_at = data.created_at || new Date().toISOString();
    this.updated_at = data.updated_at || new Date().toISOString();
    
    // External identifiers (for reference only, not stored in DB)
    this.apsl_team_id = data.apsl_team_id || null;
    this.casa_team_id = data.casa_team_id || null;
    this.team_url = data.team_url || null;
  }

  toSQL() {
    return `INSERT INTO teams (id, name, division_id, league_division_id, season, age_group, skill_level, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  ${SqlGenerator.escape(this.id)},
  ${SqlGenerator.escape(this.name)},
  ${SqlGenerator.escape(this.division_id)},
  ${SqlGenerator.escape(this.league_division_id)},
  ${SqlGenerator.escape(this.season)},
  ${SqlGenerator.escape(this.age_group)},
  ${SqlGenerator.escape(this.skill_level)},
  ${SqlGenerator.escape(this.description)},
  ${SqlGenerator.escape(this.logo_url)},
  ${SqlGenerator.escape(this.primary_color)},
  ${SqlGenerator.escape(this.secondary_color)},
  ${SqlGenerator.escape(this.is_active)},
  ${SqlGenerator.escape(this.created_at)},
  ${SqlGenerator.escape(this.updated_at)}
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = EXCLUDED.updated_at;`;
  }
}

module.exports = Team;
