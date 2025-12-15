const SqlGenerator = require('../services/SqlGenerator');

/**
 * League Model
 * Represents a sports league (e.g., APSL, CASA)
 */
class League {
  constructor(data) {
    this.id = data.id;
    this.name = data.name;
    this.display_name = data.display_name || data.name;
    this.slug = data.slug || this.generateSlug(data.name);
    this.sport_id = data.sport_id;
    this.country = data.country || 'United States';
    this.region = data.region || null;
    this.level = data.level || null;
    this.is_active = data.is_active !== false;
    this.created_at = data.created_at || new Date().toISOString();
    this.updated_at = data.updated_at || new Date().toISOString();
  }

  generateSlug(name) {
    return name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '');
  }

  toSQL() {
    return `INSERT INTO leagues (id, name, display_name, slug, sport_id, country, region, level, is_active, created_at, updated_at)
VALUES (
  ${SqlGenerator.escape(this.id)},
  ${SqlGenerator.escape(this.name)},
  ${SqlGenerator.escape(this.display_name)},
  ${SqlGenerator.escape(this.slug)},
  ${SqlGenerator.escape(this.sport_id)},
  ${SqlGenerator.escape(this.country)},
  ${SqlGenerator.escape(this.region)},
  ${SqlGenerator.escape(this.level)},
  ${SqlGenerator.escape(this.is_active)},
  ${SqlGenerator.escape(this.created_at)},
  ${SqlGenerator.escape(this.updated_at)}
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  slug = EXCLUDED.slug,
  updated_at = EXCLUDED.updated_at;`;
  }
}

module.exports = League;
