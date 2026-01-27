# CASA Scraper Status (December 15, 2025)

## Working Features ✅

### Teams/Standings
- Successfully scraping Liga 1: 8 teams
  - Adé United FC
  - Oaklyn United FC II
  - Philadelphia Sierra Stars
  - Persepolis FC
  - Phoenix SCM
  - Philly BlackStars
  - Illyrians FC
  - Lighthouse Boys Club

- Successfully scraping Liga 2: 5 teams
  - Persepolis United FC II
  - Phoenix SCR
  - Philadelphia SC II
  - Lighthouse Old Timers Club
  - Club de Futbol Armada

### Implementation
- Using Puppeteer to navigate to CASA pages
- Detecting SportsEngine iframes containing standings data
- Parsing team names from iframe innerText

## Known Issues ⚠️

### Schedules
- **Status**: Iframe detected but 0 matches extracted
- **Issue**: Schedule data parsing needs to be implemented
- **URLs**: 
  - Liga 1: https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9090889
  - Liga 2: https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9096430

### Rosters
- **Status**: No data in Google Sheets CSVs
- **Issue**: Sheets may be empty or URLs need updating
- **Source**: CASA publishes roster links at https://www.casasoccerleagues.com/captainscorner
  - Captain's Corner contains Google Sheets links for both CASA Select and CASA Traditional
- **URLs**:
  - Liga 1: https://docs.google.com/spreadsheets/d/e/2PACX-1vSmsWzjTsLR81d-eQTLDM4EnaqzqUOy5OcWLy1Lna1NYVFY7gOj0nZAQdIk99e99g/pub?gid=480494399&output=csv
  - Liga 2: https://docs.google.com/spreadsheets/d/e/2PACX-1vQsDtR6AQPgThg1105AinjkLqHMaWgQfCFJuWqfEtadH41k5OSKYZ2Hqb0N-CnO2Q/pub?gid=310279135&output=csv

## Usage

Run with: `./dev.sh --casa`

This will execute:
- Team scraping (structure) ✅
- Schedule scraping (with --schedules flag) ⚠️
- Roster scraping from Google Sheets (full mode) ⚠️

## Next Steps

1. Fix schedule iframe parsing to extract match data
2. Verify Google Sheets URLs and roster data availability
3. Test full scraping pipeline on Linux to confirm cross-platform compatibility
