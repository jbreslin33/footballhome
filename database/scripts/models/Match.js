const SqlGenerator = require('../services/SqlGenerator');

/**
 * Match/Event Model
 * Represents a game/match event
 */
class Match {
  constructor(data) {
    // Event data
    this.event_id = data.event_id || data.id;
    this.name = data.name;
    this.event_type_id = data.event_type_id;
    this.start_time = data.start_time;
    this.end_time = data.end_time;
    this.venue_id = data.venue_id || null;
    this.location_name = data.location_name || null;
    this.created_by = data.created_by;
    this.source_app_id = data.source_app_id;
    this.external_source = data.external_source || null;
    this.external_event_id = data.external_event_id || null;
    this.is_active = data.is_active !== false;
    this.created_at = data.created_at || new Date().toISOString();
    this.updated_at = data.updated_at || new Date().toISOString();
    
    // Match-specific data
    this.home_team_id = data.home_team_id;
    this.away_team_id = data.away_team_id;
    this.home_score = data.home_score || null;
    this.away_score = data.away_score || null;
    this.status = data.status || 'scheduled';
    this.match_notes = data.match_notes || null;
  }

  toEventSQL() {
    return `INSERT INTO events (id, name, event_type_id, start_time, end_time, venue_id, location_name, created_by, source_app_id, external_source, external_event_id, is_active, created_at, updated_at)
VALUES (
  ${SqlGenerator.escape(this.event_id)},
  ${SqlGenerator.escape(this.name)},
  ${SqlGenerator.escape(this.event_type_id)},
  ${SqlGenerator.escape(this.start_time)},
  ${SqlGenerator.escape(this.end_time)},
  ${SqlGenerator.escape(this.venue_id)},
  ${SqlGenerator.escape(this.location_name)},
  ${SqlGenerator.escape(this.created_by)},
  ${SqlGenerator.escape(this.source_app_id)},
  ${SqlGenerator.escape(this.external_source)},
  ${SqlGenerator.escape(this.external_event_id)},
  ${SqlGenerator.escape(this.is_active)},
  ${SqlGenerator.escape(this.created_at)},
  ${SqlGenerator.escape(this.updated_at)}
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  updated_at = EXCLUDED.updated_at;`;
  }

  toMatchSQL() {
    return `INSERT INTO matches (event_id, home_team_id, away_team_id, home_score, away_score, status, notes)
VALUES (
  ${SqlGenerator.escape(this.event_id)},
  ${SqlGenerator.escape(this.home_team_id)},
  ${SqlGenerator.escape(this.away_team_id)},
  ${SqlGenerator.escape(this.home_score)},
  ${SqlGenerator.escape(this.away_score)},
  ${SqlGenerator.escape(this.status)},
  ${SqlGenerator.escape(this.match_notes)}
)
ON CONFLICT (event_id) DO UPDATE SET
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  status = EXCLUDED.status;`;
  }

  toSQL() {
    return [this.toEventSQL(), this.toMatchSQL()].join('\n\n');
  }
}

module.exports = Match;
