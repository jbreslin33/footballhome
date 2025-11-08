# League Games Scraping System

## Overview

The League Games system provides comprehensive support for importing and managing official league match data from external sources (APSL, CASA, etc.) while maintaining integration with the team's internal event management system.

## Database Architecture

### Core Tables

#### `league_games`
The main table for storing official league matches with comprehensive match data:

```sql
-- Basic game information
id, season, home_team_id, away_team_id, scheduled_date, venue_id
competition_name, competition_round, league_division_id

-- External system integration
league_game_id, external_url, data_source, scraped_at

-- Match timing and status
game_status, kickoff_time, match_start_time, match_end_time, current_minute

-- Results and statistics
home_team_score, away_team_score, home_team_ht_score, away_team_ht_score
home_possession_percent, away_possession_percent
home_shots, away_shots, home_shots_on_target, away_shots_on_target
home_corners, away_corners, home_fouls, away_fouls
home_yellow_cards, away_yellow_cards, home_red_cards, away_red_cards

-- Match conditions
weather_conditions, temperature, attendance

-- Flexible data storage
raw_match_data (JSONB), match_events (JSONB)
```

#### `league_match_events`
Detailed event tracking for goals, cards, substitutions, etc:

```sql
-- Event details
event_type ('goal', 'yellow_card', 'red_card', 'substitution', etc.)
team_id, player_name, player_id (optional link to internal players)
minute, stoppage_minute, description

-- Flexible event data
additional_data (JSONB) -- assists, card reasons, substitution details
```

#### `league_match_player_stats`  
Individual player performance data:

```sql
-- Player identification
player_name, player_id (optional), team_id, starting_position

-- Basic statistics
minutes_played, goals, assists, yellow_cards, red_cards
shots, shots_on_target

-- Advanced statistics (when available)
passes_completed, passes_attempted, tackles_won, tackles_attempted
aerial_duels_won, aerial_duels_attempted

-- Match participation
is_starter, is_captain, substituted_on_minute, substituted_off_minute

-- Raw data preservation
raw_stats_data (JSONB)
```

### Key Features

#### Duplicate Prevention
- **Function**: `check_duplicate_league_game()` prevents importing the same match multiple times
- **Logic**: Same teams + same date = duplicate (supports home/away reversal)
- **Venue checking**: Optional stricter duplicate detection including venue

#### Team-Specific Views
- **View**: `team_league_games` shows games from each team's perspective
- **Features**: Automatic home/away detection, opponent identification, score perspective

#### Helper Functions
- `update_league_game_stats()` - Safely update match results and statistics
- `add_league_match_event()` - Add individual match events with validation

## Data Sources

### Supported Sources
- `scraped_apsl` - Adelaide Premier Soccer League
- `scraped_casa` - Community Amateur Soccer Association  
- `manual` - Manually entered data
- `imported` - Bulk imported data

### External ID Tracking
- Each game can have an external `league_game_id` for API synchronization
- URLs to original match pages preserved in `external_url`
- Source tracking prevents cross-contamination between leagues

## API Endpoints

### Core Operations

#### List Games
```
GET /api/league-games?team_id={id}&season=2024&status=completed
```
Filters: team_id, season, competition, status, data_source, limit, offset

#### Get Game Details
```  
GET /api/league-games/{id}
```
Returns: game info, events, player statistics

#### Create Game
```
POST /api/league-games
{
  "season": "2024",
  "home_team_id": "uuid",
  "away_team_id": "uuid", 
  "scheduled_date": "2024-12-15T14:00:00Z",
  "competition_name": "APSL Premier Division",
  "league_game_id": "APSL_12345",
  "data_source": "scraped_apsl"
}
```
Includes automatic duplicate checking.

#### Update Results
```
PUT /api/league-games/{id}/result
{
  "home_score": 2,
  "away_score": 1,
  "attendance": 150,
  "game_status": "completed"
}
```

#### Add Events
```
POST /api/league-games/{id}/events
{
  "event_type": "goal",
  "team_id": "uuid",
  "player_name": "Sarah Johnson",
  "minute": 23,
  "additional_data": {"assist": "Emma Williams"}
}
```

## Integration Patterns

### Team Events Integration
- Optional `league_game_id` column on `events` table links team events to league games
- Supports mixed scheduling: team practices/events + official league matches
- Team-specific view shows both perspectives seamlessly

### Player Matching
- `player_name` field stores scraped player names as-is
- Optional `player_id` links to internal player records when available
- Flexible matching allows gradual player database building

### Data Preservation
- `raw_match_data` and `raw_stats_data` JSON fields preserve complete scraped data
- Enables future data mining and analysis
- Supports incremental parsing improvements

## Scraper Implementation Guide

### Basic Scraper Structure
```javascript
class APSLScraper {
  async scrapeMatches(season, division) {
    // 1. Fetch match list from APSL website
    // 2. For each match, check if already exists
    // 3. Create league_games record if new
    // 4. If match is completed, scrape detailed stats
    // 5. Add events and player statistics
  }
  
  async checkDuplicate(homeTeam, awayTeam, matchDate) {
    return pool.query('SELECT check_duplicate_league_game($1, $2, $3)', 
      [homeTeam, awayTeam, matchDate]);
  }
}
```

### Recommended Workflow
1. **Team Mapping**: Establish team name → team_id mappings
2. **Match Discovery**: Scrape fixture lists, create basic game records
3. **Result Updates**: Scrape completed matches for scores and statistics  
4. **Event Details**: Parse match reports for goals, cards, substitutions
5. **Player Stats**: Extract individual performance data when available

## Performance Considerations

### Indexing Strategy
- Primary indexes on common filters: teams, dates, seasons, status
- Partial indexes for external IDs (only when not NULL)
- Composite indexes for duplicate checking and team-specific queries

### Query Optimization
- Team-specific view pre-computes common team perspective logic
- JSON data preserved but structured data extracted for frequent queries
- Limit/offset pagination for large result sets

## Future Enhancements

### Planned Features
- Automatic player name matching with fuzzy string matching
- League table calculations based on imported results
- Match prediction system using historical data
- Photo/video attachment support for key match events
- Live score updates via websockets during match scraping

### Scraper Extensions  
- FFSA (Football Federation SA) integration
- NPL (National Premier League) support
- Social media match updates integration
- Referee and match official tracking

## Migration Usage

To apply this schema to your database:

```bash
# Apply the migration
docker compose exec db psql -U footballhome_user -d footballhome -f /path/to/migration_003_league_games.sql

# Verify tables created
docker compose exec db psql -U footballhome_user -d footballhome -c "\dt league*"
```

## Testing

Sample data creation and verification:
```sql
-- Create test league game
INSERT INTO league_games (season, home_team_id, away_team_id, scheduled_date, competition_name, home_team_score, away_team_score, data_source) 
VALUES ('2024', 'home_uuid', 'away_uuid', '2024-12-15 14:00:00', 'Test League', 2, 1, 'manual');

-- Verify team perspective view
SELECT * FROM team_league_games WHERE competition_name = 'Test League';

-- Test duplicate detection
SELECT check_duplicate_league_game('home_uuid', 'away_uuid', '2024-12-15 15:00:00');
```