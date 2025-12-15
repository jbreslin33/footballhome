const SqlGenerator = require('../services/SqlGenerator');

/**
 * Team Model
 * Represents a sports team
 */
class Team {
  constructor(data) {
    this.id = data.id;
    this.sport_division_id = data.sport_division_id;
    this.league_division_id = data.league_division_id || null;
    this.name = data.name;
    this.display_name = data.display_name || data.name;
    this.short_name = data.short_name || null;
    this.slug = data.slug || this.generateSlug(data.name);
    this.logo_url = data.logo_url || null;
    this.home_venue_id = data.home_venue_id || null;
    this.primary_color = data.primary_color || null;
    this.secondary_color = data.secondary_color || null;
    this.founded_year = data.founded_year || null;
    this.is_active = data.is_active !== false;
    this.created_at = data.created_at || new Date().toISOString();
    this.updated_at = data.updated_at || new Date().toISOString();
    
    // External identifiers
    this.apsl_team_id = data.apsl_team_id || null;
    this.casa_team_id = data.casa_team_id || null;
    
    // Metadata
    this.team_url = data.team_url || null;
  }

  generateSlug(name) {
    return name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '');
  }

  toSQL() {
    return `INSERT INTO teams (id, sport_division_id, league_division_id, name, display_name, short_name, slug, logo_url, home_venue_id, primary_color, secondary_color, founded_year, is_active, created_at, updated_at)
VALUES (
  ${SqlGenerator.escape(this.id)},
  ${SqlGenerator.escape(this.sport_division_id)},
  ${SqlGenerator.escape(this.league_division_id)},
  ${SqlGenerator.escape(this.name)},
  ${SqlGenerator.escape(this.display_name)},
  ${SqlGenerator.escape(this.short_name)},
  ${SqlGenerator.escape(this.slug)},
  ${SqlGenerator.escape(this.logo_url)},
  ${SqlGenerator.escape(this.home_venue_id)},
  ${SqlGenerator.escape(this.primary_color)},
  ${SqlGenerator.escape(this.secondary_color)},
  ${SqlGenerator.escape(this.founded_year)},
  ${SqlGenerator.escape(this.is_active)},
  ${SqlGenerator.escape(this.created_at)},
  ${SqlGenerator.escape(this.updated_at)}
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = EXCLUDED.updated_at;`;
  }
}

module.exports = Team;
