const SqlGenerator = require('../services/SqlGenerator');

/**
 * SportDivision Model
 * Represents a sport division within a club (e.g., "Soccer Division", "Youth Soccer")
 * Schema: id, club_id, sport_id, name, display_name, slug, description, logo_url, 
 *         primary_color, secondary_color, is_active, created_at, updated_at
 */
class SportDivision {
  constructor(data) {
    this.id = data.id;
    this.club_id = data.club_id;
    this.sport_id = data.sport_id;
    this.name = data.name;
    this.display_name = data.display_name || data.name;
    this.slug = data.slug;
    this.description = data.description || null;
    this.logo_url = data.logo_url || null;
    this.primary_color = data.primary_color || null;
    this.secondary_color = data.secondary_color || null;
    this.is_active = data.is_active !== false;
  }

  toSQL() {
    return `INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, description, logo_url, primary_color, secondary_color, is_active, created_at, updated_at)
VALUES (
  ${SqlGenerator.escape(this.id)},
  ${SqlGenerator.escape(this.club_id)},
  ${SqlGenerator.escape(this.sport_id)},
  ${SqlGenerator.escape(this.name)},
  ${SqlGenerator.escape(this.display_name)},
  ${SqlGenerator.escape(this.slug)},
  ${SqlGenerator.escape(this.description)},
  ${SqlGenerator.escape(this.logo_url)},
  ${SqlGenerator.escape(this.primary_color)},
  ${SqlGenerator.escape(this.secondary_color)},
  ${SqlGenerator.escape(this.is_active)},
  ${SqlGenerator.escape(this.created_at)},
  ${SqlGenerator.escape(this.updated_at)}
)
ON CONFLICT (club_id, sport_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;`;
  }
}

module.exports = SportDivision;
