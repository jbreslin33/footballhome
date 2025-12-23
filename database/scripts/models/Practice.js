const SqlGenerator = require('../services/SqlGenerator');

/**
 * Practice/Event Model
 * Represents a training/practice event
 */
class Practice {
  constructor(data) {
    // Event data (matching events table schema)
    this.event_id = data.event_id || data.id;
    this.title = data.title || data.name;
    this.event_type_id = data.event_type_id;
    this.event_date = data.event_date || data.start_time;
    this.duration_minutes = data.duration_minutes || 90;
    this.venue_id = data.venue_id || null;
    this.description = data.description || null;
    this.created_by = data.created_by;
    this.external_event_id = data.external_event_id || null;
    this.cancelled = data.cancelled || false;
    this.cancellation_reason = data.cancellation_reason || null;
    this.created_at = data.created_at || '2025-01-01 00:00:00';
    this.updated_at = data.updated_at || '2025-01-01 00:00:00';
    
    // Practice-specific data
    this.team_id = data.team_id;
    this.max_players = data.max_players || null;
    this.focus_areas = data.focus_areas || null;
    this.drill_plan = data.drill_plan || null;
    this.equipment_needed = data.equipment_needed || null;
    this.fitness_focus = data.fitness_focus || null;
    this.skill_level = data.skill_level || null;
    this.weather_dependent = data.weather_dependent !== false; // Default true
    this.indoor_alternative_location = data.indoor_alternative_location || null;
    this.notes = data.notes || null;
  }

  toEventSQL() {
    return `INSERT INTO events (id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, cancelled, cancellation_reason, external_event_id)
VALUES (
  ${SqlGenerator.escape(this.event_id)},
  ${SqlGenerator.escape(this.created_by)},
  ${SqlGenerator.escape(this.event_type_id)},
  ${SqlGenerator.escape(this.title)},
  ${SqlGenerator.escape(this.description)},
  ${SqlGenerator.escape(this.event_date)},
  ${SqlGenerator.escape(this.venue_id)},
  ${SqlGenerator.escape(this.duration_minutes)},
  ${SqlGenerator.escape(this.cancelled)},
  ${SqlGenerator.escape(this.cancellation_reason)},
  ${SqlGenerator.escape(this.external_event_id)}
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  updated_at = EXCLUDED.updated_at;`;
  }

  toPracticeSQL() {
    return `INSERT INTO practices (id, team_id, max_players, focus_areas, drill_plan, equipment_needed, fitness_focus, skill_level, weather_dependent, indoor_alternative_location, notes)
VALUES (
  ${SqlGenerator.escape(this.event_id)},
  ${SqlGenerator.escape(this.team_id)},
  ${SqlGenerator.escape(this.max_players)},
  ${SqlGenerator.escape(this.focus_areas)},
  ${SqlGenerator.escape(this.drill_plan)},
  ${SqlGenerator.escape(this.equipment_needed)},
  ${SqlGenerator.escape(this.fitness_focus)},
  ${SqlGenerator.escape(this.skill_level)},
  ${SqlGenerator.escape(this.weather_dependent)},
  ${SqlGenerator.escape(this.indoor_alternative_location)},
  ${SqlGenerator.escape(this.notes)}
)
ON CONFLICT (id) DO UPDATE SET
  team_id = EXCLUDED.team_id,
  notes = EXCLUDED.notes;`;
  }

  toSQL() {
    return [this.toEventSQL(), this.toPracticeSQL()].join('\n\n');
  }
}

module.exports = Practice;
