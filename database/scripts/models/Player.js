const SqlGenerator = require('../services/SqlGenerator');

/**
 * Player Model
 * Represents a player (extends User)
 * Schema: players table has: id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes
 * Note: jersey_number is in team_players table (players can have different numbers on different teams)
 */
class Player {
  constructor(data) {
    this.id = data.id; // Same as user_id
    
    // Player-specific fields (match actual schema)
    this.preferred_position_id = data.preferred_position_id || null;
    this.photo_url = data.photo_url || data.headshot_url || null; // Accept both names
    this.height_cm = data.height_cm || data.height || null;
    this.weight_kg = data.weight_kg || data.weight || null;
    this.dominant_foot = data.dominant_foot || null;
    this.player_rating = data.player_rating || null;
    this.notes = data.notes || null;
    this.created_at = data.created_at || new Date().toISOString();
    this.updated_at = data.updated_at || new Date().toISOString();
    
    // User data (for creating user record)
    this.first_name = data.first_name;
    this.last_name = data.last_name;
    this.email = data.email || null;
    this.phone = data.phone || null;
    this.date_of_birth = data.date_of_birth || data.birth_date || null;
    this.is_active = data.is_active !== false;
    
    // External identifiers (not stored in players table, used for reference)
    this.apsl_player_id = data.apsl_player_id || null;
    this.casa_player_id = data.casa_player_id || null;
  }

  get fullName() {
    return `${this.first_name} ${this.last_name}`.trim();
  }

  toUserSQL() {
    return `INSERT INTO users (id, first_name, last_name, email, phone, date_of_birth, is_active, created_at, updated_at)
VALUES (
  ${SqlGenerator.escape(this.id)},
  ${SqlGenerator.escape(this.first_name)},
  ${SqlGenerator.escape(this.last_name)},
  ${SqlGenerator.escape(this.email)},
  ${SqlGenerator.escape(this.phone)},
  ${SqlGenerator.escape(this.date_of_birth)},
  ${SqlGenerator.escape(this.is_active)},
  ${SqlGenerator.escape(this.created_at)},
  ${SqlGenerator.escape(this.updated_at)}
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  email = COALESCE(EXCLUDED.email, users.email),
  phone = COALESCE(EXCLUDED.phone, users.phone),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = EXCLUDED.updated_at;`;
  }

  toPlayerSQL() {
    return `INSERT INTO players (id, preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating, notes, created_at, updated_at)
VALUES (
  ${SqlGenerator.escape(this.id)},
  ${SqlGenerator.escape(this.preferred_position_id)},
  ${SqlGenerator.escape(this.photo_url)},
  ${SqlGenerator.escape(this.height_cm)},
  ${SqlGenerator.escape(this.weight_kg)},
  ${SqlGenerator.escape(this.dominant_foot)},
  ${SqlGenerator.escape(this.player_rating)},
  ${SqlGenerator.escape(this.notes)},
  ${SqlGenerator.escape(this.created_at)},
  ${SqlGenerator.escape(this.updated_at)}
)
ON CONFLICT (id) DO UPDATE SET
  preferred_position_id = COALESCE(EXCLUDED.preferred_position_id, players.preferred_position_id),
  photo_url = COALESCE(EXCLUDED.photo_url, players.photo_url),
  height_cm = COALESCE(EXCLUDED.height_cm, players.height_cm),
  weight_kg = COALESCE(EXCLUDED.weight_kg, players.weight_kg),
  dominant_foot = COALESCE(EXCLUDED.dominant_foot, players.dominant_foot),
  player_rating = COALESCE(EXCLUDED.player_rating, players.player_rating),
  notes = COALESCE(EXCLUDED.notes, players.notes),
  updated_at = EXCLUDED.updated_at;`;
  }

  toSQL() {
    // Generate both user and player SQL
    return [this.toUserSQL(), this.toPlayerSQL()].join('\n\n');
  }
}

module.exports = Player;
