# League Games Scraper System

## Overview

The Football Home League Games Scraper system automatically imports match data from external football leagues (APSL, CASA) into the application database. The system provides:

- **Automated data collection** from league websites
- **Duplicate prevention** to avoid importing the same matches multiple times
- **Team management** with automatic team creation and fuzzy name matching
- **Comprehensive match data** including scores, events, and player statistics
- **Rate limiting** to respect external websites
- **Complete API integration** for accessing imported data

## System Architecture

### Core Components

1. **BaseScraper.js** - Abstract base class providing common functionality
2. **APSLScraper.js** - APSL (Adelaide Premier Soccer League) specific implementation  
3. **CASAScraper.js** - CASA (Community Amateur Soccer Association) specific implementation
4. **ScraperManager.js** - Coordinates and manages multiple scrapers
5. **test-scrapers.js** - Testing and execution script

### Database Schema

The system uses three main tables:

- `league_games` - Match information (teams, scores, dates, venue)
- `league_match_events` - Match events (goals, cards, substitutions)
- `league_match_player_stats` - Individual player performance data

## Features

### Data Collection

✅ **Match Fixtures** - Automatically detects and imports upcoming matches
✅ **Match Results** - Imports final scores and match statistics
✅ **Match Events** - Records goals, cards, substitutions with timestamps
✅ **Player Statistics** - Tracks individual player performance
✅ **Team Management** - Auto-creates teams from external leagues
✅ **Duplicate Detection** - Prevents importing the same match twice

### Technical Features

✅ **Rate Limiting** - Respectful scraping with configurable delays
✅ **Error Handling** - Robust error recovery and logging
✅ **Mock Data** - Uses mock data for testing (ready for real implementation)
✅ **API Integration** - Full REST API for accessing imported data
✅ **Team Matching** - Fuzzy matching to link external teams to existing ones

## Installation & Setup

### 1. Dependencies

The scraper system requires these npm packages (already included in package.json):

```json
{
  "axios": "^1.6.0",
  "cheerio": "^1.0.0-rc.12",
  "pg": "^8.11.3"
}
```

### 2. Database Preparation

Run the migration to create the required tables:

```bash
docker exec footballhome_db psql -U footballhome_user -d footballhome -f /tmp/migration_003_league_games.sql
```

### 3. Copy Scrapers to Container

```bash
cd /path/to/footballhome
docker cp backend/scrapers/. footballhome_backend:/usr/src/app/scrapers/
```

## Usage

### Running Scrapers

**Test individual scraper:**
```bash
docker exec footballhome_backend node scrapers/test-scrapers.js apsl
docker exec footballhome_backend node scrapers/test-scrapers.js casa
```

**Run all scrapers:**
```bash
docker exec footballhome_backend node scrapers/test-scrapers.js all
```

**View statistics:**
```bash
docker exec footballhome_backend node scrapers/test-scrapers.js stats
```

### Expected Output

```
🏈 Football League Scraper Test
================================
Command: all
Season: 2024

Initialized 2 scrapers: apsl, casa
Starting full scraping session...

--- Starting APSL ---
Starting APSL scrape for 2024 season
Scraping APSL fixtures...
Creating new team: Adelaide City FC
Creating new team: West Adelaide SC
Found 3 fixtures
Created league game: APSL Premier Division - Adelaide City FC vs West Adelaide SC
✅ APSL completed

--- Starting CASA ---
Starting CASA scrape for 2024 season  
Scraping CASA fixtures...
Found existing team: Northern Demons FC -> Northern Demons FC
Found 3 fixtures
Skipping duplicate game: Northern Demons FC vs Southern United SC (already exists)
✅ CASA completed

📊 Scraping Statistics:
By Data Source:
  scraped_apsl:
    Total Games: 4
    Completed: 3
    Scheduled: 1
  scraped_casa:
    Total Games: 3
    Completed: 2
    Scheduled: 1
```

## API Access

### List All League Games

```bash
curl "http://localhost:3001/api/league-games"
```

### Get Game Details with Events & Stats

```bash
curl "http://localhost:3001/api/league-games/{game-id}"
```

### Filter by Competition

```bash
curl "http://localhost:3001/api/league-games?competition=APSL Premier Division"
```

### Example Response

```json
{
  "success": true,
  "game": {
    "id": "a48e06f7-9e6e-4a6e-8371-69c0001ef891",
    "home_team_name": "Adelaide City FC",
    "away_team_name": "West Adelaide SC", 
    "home_team_score": 2,
    "away_team_score": 1,
    "competition_name": "APSL Premier Division",
    "game_status": "completed"
  },
  "events": [
    {
      "event_type": "goal",
      "event_minute": 23,
      "player_name": "John Smith",
      "event_description": "Header from corner kick"
    }
  ],
  "player_stats": [
    {
      "player_name": "John Smith",
      "goals": 1,
      "assists": 0,
      "minutes_played": 90
    }
  ]
}
```

## Current Implementation Status

### ✅ Completed Features

- **Database Schema**: Complete with all tables, indexes, and functions
- **API Endpoints**: Full REST API with authentication
- **Scraper Framework**: BaseScraper with rate limiting and error handling
- **League Scrapers**: APSL and CASA implementations with mock data
- **Team Management**: Auto-creation and fuzzy matching
- **Duplicate Prevention**: Robust checking to prevent data duplication
- **Testing Framework**: Complete test suite with statistics reporting

### 📋 Mock Data Implementation

The scrapers currently use mock data to demonstrate functionality:

**APSL Mock Data:**
- 3 fixtures from Adelaide Premier Soccer League
- Complete match details with goals, cards, substitutions
- Player statistics including goals, assists, minutes played

**CASA Mock Data:**
- 3 fixtures from Community Amateur Soccer Association
- Match results with basic statistics
- Community-focused team names and divisions

### 🚧 Real Implementation Requirements

To connect to real league websites:

1. **Replace Mock URLs** - Update fixture and match detail URLs to real endpoints
2. **HTML Parsing** - Adapt cheerio selectors to actual website structure
3. **Data Mapping** - Map website data fields to database schema
4. **Error Handling** - Handle website-specific errors and rate limits
5. **Authentication** - Add any required login or API keys

## Technical Details

### Rate Limiting

The system implements respectful scraping:
- 1 second delay between requests
- Configurable timeout (10 seconds default)
- Exponential backoff on failures

### Team Matching

Teams are matched using:
1. **Exact name match** (case-insensitive)
2. **Fuzzy matching** for variations
3. **Auto-creation** for new teams in "External League Teams" division

### Error Recovery

The system handles:
- Network timeouts and connection errors
- Invalid HTML or missing data
- Database constraint violations
- Duplicate data attempts

### Data Integrity

- **Unique constraints** prevent duplicate matches
- **Foreign key relationships** ensure data consistency
- **Transaction safety** for atomic operations
- **Input validation** for all imported data

## Monitoring & Maintenance

### Regular Tasks

1. **Check scraper logs** for errors or failures
2. **Monitor API performance** and response times
3. **Validate imported data** for accuracy
4. **Update team mappings** as new teams are discovered
5. **Archive old season data** to maintain performance

### Troubleshooting

**Common Issues:**
- **"Module not found" errors**: Run `docker exec footballhome_backend npm install`
- **Database connection fails**: Check container health and credentials  
- **Duplicate key violations**: Normal - indicates duplicate prevention working
- **No fixtures found**: Website structure may have changed

**Debugging Commands:**
```bash
# Check scraper logs
docker logs footballhome_backend | grep scraper

# Verify database connection
docker exec footballhome_db psql -U footballhome_user -d footballhome -c "SELECT COUNT(*) FROM league_games;"

# Test individual components
docker exec footballhome_backend node -e "const BaseScraper = require('./scrapers/BaseScraper'); console.log('OK');"
```

## Future Enhancements

### Planned Features

- **Scheduled Scraping**: Cron jobs for automated daily/weekly runs
- **Real Website Integration**: Replace mock data with actual league websites
- **Advanced Analytics**: League tables, top scorers, team form
- **Notification System**: Alerts for new matches or score updates
- **Frontend Integration**: UI components to display league data
- **Multi-League Support**: Additional leagues beyond APSL/CASA

### Extension Points

- **Custom Scrapers**: Easy to add new leagues by extending BaseScraper
- **Data Enrichment**: Player profiles, team histories, venue details
- **Export Features**: CSV/Excel exports of league data
- **Statistics Engine**: Advanced match and player analytics

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review scraper logs for specific errors
3. Test individual components to isolate problems
4. Verify database schema is up to date
5. Ensure all dependencies are installed

The scraper system is designed to be robust and maintainable. With the current mock implementation, it demonstrates the complete workflow from data collection to API access, ready for production deployment with real league websites.