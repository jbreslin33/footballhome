const SqlGenerator = require('../services/SqlGenerator');

/**
 * Match/Event Model
 * Represents a game/match event
 */
class Match {
  constructor(data) {
    // Event data (matching events table schema)
    this.event_id = data.event_id || data.id;
    this.title = data.title || data.name;  // Schema uses 'title' not 'name'
    this.event_type_id = data.event_type_id;
    this.event_date = data.event_date || data.start_time;  // Schema uses 'event_date' not 'start_time'
    this.duration_minutes = data.duration_minutes || null;  // Schema uses duration not end_time
    this.venue_id = data.venue_id || null;
    this.description = data.description || null;
    this.created_by = data.created_by;
    this.external_event_id = data.external_event_id || null;
    this.cancelled = data.cancelled || false;
    this.cancellation_reason = data.cancellation_reason || null;
    this.created_at = data.created_at || '2025-01-01 00:00:00';
    this.updated_at = data.updated_at || '2025-01-01 00:00:00';
    
    // Match-specific data (matching matches table schema)
    this.home_team_id = data.home_team_id;
    this.away_team_id = data.away_team_id;
    this.home_away_status_id = data.home_away_status_id || '550e8400-e29b-41d4-a716-446655440801';  // Default to 'home'
    this.home_team_score = data.home_team_score || data.home_score || null;  // Schema uses 'home_team_score'
    this.away_team_score = data.away_team_score || data.away_score || null;  // Schema uses 'away_team_score'
    this.match_status = data.match_status || data.status || 'scheduled';  // Schema uses 'match_status'
    this.competition_name = data.competition_name || null;
    this.competition_round = data.competition_round || null;
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

  toMatchSQL() {
    return `INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, home_team_score, away_team_score, match_status, competition_name, competition_round)
VALUES (
  ${SqlGenerator.escape(this.event_id)},
  ${SqlGenerator.escape(this.home_team_id)},
  ${SqlGenerator.escape(this.away_team_id)},
  ${SqlGenerator.escape(this.home_away_status_id)},
  ${SqlGenerator.escape(this.home_team_score)},
  ${SqlGenerator.escape(this.away_team_score)},
  ${SqlGenerator.escape(this.match_status)},
  ${SqlGenerator.escape(this.competition_name)},
  ${SqlGenerator.escape(this.competition_round)}
)
ON CONFLICT (id) DO UPDATE SET
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score,
  match_status = EXCLUDED.match_status;`;
  }

  toEventParticipantsSQL() {
    // Only create event_participants entries for teams that have been matched
    // Skip entries where team_id is null (unmatched teams can be linked later)
    const participants = [];
    
    if (this.home_team_id) {
      const homeParticipantId = require('crypto').randomUUID();
      participants.push(
        `  (${SqlGenerator.escape(homeParticipantId)}, ${SqlGenerator.escape(this.event_id)}, ${SqlGenerator.escape(this.home_team_id)}, '550e8400-e29b-41d4-a716-446655440701')`
      );
    }
    
    if (this.away_team_id) {
      const awayParticipantId = require('crypto').randomUUID();
      participants.push(
        `  (${SqlGenerator.escape(awayParticipantId)}, ${SqlGenerator.escape(this.event_id)}, ${SqlGenerator.escape(this.away_team_id)}, '550e8400-e29b-41d4-a716-446655440701')`
      );
    }
    
    // If no teams matched, return empty string (no SQL to execute)
    if (participants.length === 0) {
      return '';
    }
    
    return `INSERT INTO event_participants (id, event_id, team_id, participation_status_id)
VALUES 
${participants.join(',\n')}
ON CONFLICT (id) DO NOTHING;`;
  }

  toSQL() {
    const parts = [this.toEventSQL(), this.toMatchSQL()];
    const participants = this.toEventParticipantsSQL();
    if (participants) {
      parts.push(participants);
    }
    return parts.join('\n\n');
  }
}

module.exports = Match;
