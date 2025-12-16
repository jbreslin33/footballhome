const SqlGenerator = require('../services/SqlGenerator');

/**
 * Club Model
 * Represents a sports club organization
 * Schema: id, name, display_name, slug, parent_club_id, description, logo_url, website, founded_year, 
 *         contact_email, contact_phone, address, city, state, postal_code, country, is_active, created_at, updated_at
 */
class Club {
  constructor(data) {
    this.id = data.id;
    this.name = data.name;
    this.display_name = data.display_name || data.name;
    this.slug = data.slug;
    this.parent_club_id = data.parent_club_id || null;
    this.description = data.description || null;
    this.logo_url = data.logo_url || null;
    this.website = data.website || null;
    this.founded_year = data.founded_year || null;
    this.contact_email = data.contact_email || null;
    this.contact_phone = data.contact_phone || null;
    this.address = data.address || null;
    this.city = data.city || null;
    this.state = data.state || null;
    this.postal_code = data.postal_code || null;
    this.country = data.country || 'USA';
    this.is_active = data.is_active !== false;
    this.created_at = data.created_at || new Date().toISOString();
    this.updated_at = data.updated_at || new Date().toISOString();
  }

  toSQL() {
    return `INSERT INTO clubs (id, name, display_name, slug, parent_club_id, description, logo_url, website, founded_year, contact_email, contact_phone, address, city, state, postal_code, country, is_active, created_at, updated_at)
VALUES (
  ${SqlGenerator.escape(this.id)},
  ${SqlGenerator.escape(this.name)},
  ${SqlGenerator.escape(this.display_name)},
  ${SqlGenerator.escape(this.slug)},
  ${SqlGenerator.escape(this.parent_club_id)},
  ${SqlGenerator.escape(this.description)},
  ${SqlGenerator.escape(this.logo_url)},
  ${SqlGenerator.escape(this.website)},
  ${SqlGenerator.escape(this.founded_year)},
  ${SqlGenerator.escape(this.contact_email)},
  ${SqlGenerator.escape(this.contact_phone)},
  ${SqlGenerator.escape(this.address)},
  ${SqlGenerator.escape(this.city)},
  ${SqlGenerator.escape(this.state)},
  ${SqlGenerator.escape(this.postal_code)},
  ${SqlGenerator.escape(this.country)},
  ${SqlGenerator.escape(this.is_active)},
  ${SqlGenerator.escape(this.created_at)},
  ${SqlGenerator.escape(this.updated_at)}
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  slug = EXCLUDED.slug,
  parent_club_id = EXCLUDED.parent_club_id,
  description = EXCLUDED.description,
  logo_url = EXCLUDED.logo_url,
  website = EXCLUDED.website,
  founded_year = EXCLUDED.founded_year,
  contact_email = EXCLUDED.contact_email,
  contact_phone = EXCLUDED.contact_phone,
  address = EXCLUDED.address,
  city = EXCLUDED.city,
  state = EXCLUDED.state,
  postal_code = EXCLUDED.postal_code,
  country = EXCLUDED.country,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at;`;
  }
}

module.exports = Club;
