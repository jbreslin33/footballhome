const SqlGenerator = require('../services/SqlGenerator');

/**
 * League Model
 * Represents a sports league (e.g., APSL, CASA)
 * Schema: id, name, display_name, sport_id, season, description, logo_url, website, contact_email, contact_phone, is_active, created_at, updated_at
 */
class League {
  constructor(data) {
    this.id = data.id;
    this.name = data.name;
    this.display_name = data.display_name || data.name;
    this.sport_id = data.sport_id;
    this.season = data.season || null;
    this.description = data.description || null;
    this.logo_url = data.logo_url || null;
    this.website = data.website || null;
    this.contact_email = data.contact_email || null;
    this.contact_phone = data.contact_phone || null;
    this.is_active = data.is_active !== false;
  }

  toSQL() {
    return `INSERT INTO leagues (id, name, display_name, sport_id, season, description, logo_url, website, contact_email, contact_phone, is_active, created_at, updated_at)
VALUES (
  ${SqlGenerator.escape(this.id)},
  ${SqlGenerator.escape(this.name)},
  ${SqlGenerator.escape(this.display_name)},
  ${SqlGenerator.escape(this.sport_id)},
  ${SqlGenerator.escape(this.season)},
  ${SqlGenerator.escape(this.description)},
  ${SqlGenerator.escape(this.logo_url)},
  ${SqlGenerator.escape(this.website)},
  ${SqlGenerator.escape(this.contact_email)},
  ${SqlGenerator.escape(this.contact_phone)},
  ${SqlGenerator.escape(this.is_active)},
  ${SqlGenerator.escape(this.created_at)},
  ${SqlGenerator.escape(this.updated_at)}
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  season = EXCLUDED.season,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  website = EXCLUDED.website,
  contact_email = EXCLUDED.contact_email,
  contact_phone = EXCLUDED.contact_phone,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;`;
  }
}

module.exports = League;
