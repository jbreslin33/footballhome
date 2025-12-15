const SqlGenerator = require('../services/SqlGenerator');

/**
 * Player Model
 * Represents a player (extends User)
 */
class Player {
  constructor(data) {
    this.id = data.id; // Same as user_id
    this.jersey_number = data.jersey_number || null;
    this.position = data.position || null;
    this.height = data.height || null;
    this.weight = data.weight || null;
    this.birth_date = data.birth_date || null;
    this.headshot_url = data.headshot_url || null;
    this.is_active = data.is_active !== false;
    this.created_at = data.created_at || new Date().toISOString();
    this.updated_at = data.updated_at || new Date().toISOString();
    
    // User data (for creating user record)
    this.first_name = data.first_name;
    this.last_name = data.last_name;
    this.email = data.email || null;
    this.phone = data.phone || null;
    
    // External identifiers
    this.apsl_player_id = data.apsl_player_id || null;
    this.casa_player_id = data.casa_player_id || null;
  }

  get fullName() {
    return `${this.first_name} ${this.last_name}`.trim();
  }

  toUserSQL() {
    return `INSERT INTO users (id, first_name, last_name, email, phone, is_active, created_at, updated_at)
VALUES (
  ${SqlGenerator.escape(this.id)},
  ${SqlGenerator.escape(this.first_name)},
  ${SqlGenerator.escape(this.last_name)},
  ${SqlGenerator.escape(this.email)},
  ${SqlGenerator.escape(this.phone)},
  ${SqlGenerator.escape(this.is_active)},
  ${SqlGenerator.escape(this.created_at)},
  ${SqlGenerator.escape(this.updated_at)}
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  updated_at = EXCLUDED.updated_at;`;
  }

  toPlayerSQL() {
    return `INSERT INTO players (id, jersey_number, position, height, weight, birth_date, headshot_url, is_active, created_at, updated_at)
VALUES (
  ${SqlGenerator.escape(this.id)},
  ${SqlGenerator.escape(this.jersey_number)},
  ${SqlGenerator.escape(this.position)},
  ${SqlGenerator.escape(this.height)},
  ${SqlGenerator.escape(this.weight)},
  ${SqlGenerator.escape(this.birth_date)},
  ${SqlGenerator.escape(this.headshot_url)},
  ${SqlGenerator.escape(this.is_active)},
  ${SqlGenerator.escape(this.created_at)},
  ${SqlGenerator.escape(this.updated_at)}
)
ON CONFLICT (id) DO UPDATE SET
  jersey_number = COALESCE(EXCLUDED.jersey_number, players.jersey_number),
  position = COALESCE(EXCLUDED.position, players.position),
  updated_at = EXCLUDED.updated_at;`;
  }

  toSQL() {
    // Generate both user and player SQL
    return [this.toUserSQL(), this.toPlayerSQL()].join('\n\n');
  }
}

module.exports = Player;
