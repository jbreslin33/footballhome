# Football Home Data Audit
**Date**: December 26, 2025  
**Purpose**: Comprehensive audit of data availability from APSL and CASA leagues

## Executive Summary

### Data Availability Matrix

| Data Type | APSL | CASA | Status |
|-----------|------|------|--------|
| **Team Structure** | ✅ Full | ✅ Full | Working |
| **Rosters** | ✅ HTML scraping | ✅ Google Sheets CSV | Working |
| **Schedule/Fixtures** | ✅ Team pages | ⚠️ Needs parser | Partial |
| **Team Season Stats** | ✅ SportsEngine JSON | ❌ Not found | APSL only |
| **Individual Match Scores** | ❌ Not found | ❌ Not found | **MISSING** |
| **Match Status** | ⚠️ Date-based only | ⚠️ Date-based only | Limited |

### Key Findings

🔴 **Critical Gap**: Neither league provides individual match scores through their public data sources
🟡 **Limited**: Match status must be inferred from dates (past = completed, future = scheduled)
🟢 **Available**: Team season aggregates (W/L/T, GF/GA) available for APSL via SportsEngine API

---

## APSL League (apslsoccer.com)

### ✅ Available Data

#### 1. Team Structure
- **Source**: HTML pages (team listings, conferences, divisions)
- **Quality**: Excellent
- **Scraper**: `ApslScraper.js` - Working
- **Output**: `21a-teams-apsl.sql`

#### 2. Rosters
- **Source**: HTML pages (TeamPass team roster pages)
- **Quality**: Excellent
- **Scraper**: `ApslScraper.js` - Working
- **Output**: `24a-players-apsl.sql`, `27a-team-players-apsl.sql`
- **Fields**: Player name, jersey number, team association

#### 3. Schedule/Fixtures
- **Source**: HTML tables on team pages
- **URL Pattern**: `https://apslsoccer.com/APSL/Team/{team_id}`
- **Quality**: Good
- **Scraper**: `ApslScraper.js` - Working
- **Output**: `30a-schedule-apsl.sql`
- **Fields**:
  - Date & Time
  - Opponent team
  - Home/Away status
  - Location/Venue
  - Match event ID
- **Limitations**: 
  - ❌ No scores
  - ❌ No match status indicators
  - ✅ Only shows upcoming matches on team pages

#### 4. Team Season Statistics
- **Source**: SportsEngine API (JSON)
- **URL**: Unknown (sourced from local `standings.json` file)
- **Quality**: Excellent
- **Scraper**: `ApslScraper.fetchStandings()` - Implemented
- **Output**: `31a-team-season-stats-apsl.sql`
- **Fields**:
  ```json
  {
    "team_name": "Lighthouse 1893 SC",
    "values": {
      "w": 3,      // Wins
      "l": 6,      // Losses
      "t": 2,      // Ties
      "pf": 16,    // Goals For
      "pa": 25,    // Goals Against
      "pts": 11    // Points
    }
  }
  ```
- **Known Issue**: Team name mismatch between standings JSON and roster pages

### ❌ Missing Data

#### 1. Individual Match Scores
- **Investigated Sources**:
  - ✗ Team pages - Only show fixtures, no scores
  - ✗ Match event pages (`/APSL/Event/{id}`) - No scores displayed
  - ✗ Fixtures page (`/APSL/Fixtures/`) - No scores shown
  - ✗ SportsEngine API - Only aggregate season stats
- **Status**: **NOT AVAILABLE** through public data sources
- **Implication**: Cannot populate `matches.home_team_score` or `matches.away_team_score`

#### 2. Match Status (Completed/Cancelled/Postponed)
- **Investigated Sources**:
  - ✗ Match event pages - No status indicators
  - ✗ Schedule tables - No completion markers
- **Workaround**: Infer from date (past = completed, future = scheduled)
- **Limitation**: Cannot distinguish cancelled/postponed matches from scheduled

#### 3. Match Details (Cards, Substitutions, etc.)
- **Status**: Not found in any data source

### 🔄 Current Database State

```sql
-- Matches table has score fields but they're NULL
INSERT INTO matches (
  id,
  home_team_id,
  away_team_id,
  home_team_score,    -- Always NULL
  away_team_score,    -- Always NULL
  match_status        -- Always 'scheduled'
)
```

---

## CASA League (casasoccerleagues.com)

### ✅ Available Data

#### 1. Team Structure
- **Source**: SportsEngine iframes (Puppeteer scraping)
- **Quality**: Good
- **Scraper**: `CasaScraper.js` - Working
- **Output**: `21b-teams-casa.sql`
- **Known Teams**:
  - Liga 1: 8 teams
  - Liga 2: 5 teams

#### 2. Rosters
- **Source**: Google Sheets CSV exports
- **Quality**: Excellent
- **Scraper**: `CasaScraper.js` - Partially working
- **Output**: `24b-players-casa.sql`, `27b-team-players-casa.sql`
- **URL Pattern**: 
  ```
  https://docs.google.com/spreadsheets/d/e/{sheet_id}/pub?gid={gid}&output=csv
  ```
- **Fields**:
  - First Name, Last Name
  - Date of Birth
  - Jersey Number
  - Date Added
  - Headshot URL
- **Example Data**:
  ```csv
  First Name,Last Name,Date of Birth,Jersey #
  Omar,Alzubair,05/20/2000,
  Erwa,Babiker,01/01/1996,
  ```

#### 3. Schedule/Fixtures
- **Source**: SportsEngine iframes (microsites/events API)
- **URL Pattern**: `https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id={id}`
- **Quality**: Unknown
- **Scraper**: `CasaScraper.fetchSchedule()` - **Needs implementation**
- **Status**: ⚠️ Iframe detected but 0 matches extracted
- **Implementation**: Puppeteer listens for JSON API responses containing match data

### ❌ Missing Data

#### 1. Team Season Statistics
- **Investigated Sources**:
  - ✗ Public pages - Require login
  - ✗ Google Sheets - Only contain roster data
  - ✗ Iframes - May exist behind login
- **Status**: **NOT AVAILABLE** without authentication
- **Implication**: No W/L/T, GF/GA, Points data for CASA teams

#### 2. Individual Match Scores
- **Investigated Sources**:
  - ✗ Public pages - Require login
  - ✗ Schedule iframes - Parser not implemented yet
- **Status**: **NOT AVAILABLE** through current scraper
- **Potential**: May exist in schedule iframe JSON responses if parser is implemented

#### 3. Match Status
- **Status**: Same as APSL - would need to infer from dates

### 🔄 Current Database State

```sql
-- CASA matches exist but with same limitations as APSL
-- No scores, status inferred from dates only
```

---

## Match Status Determination Strategy

### Current Implementation
```javascript
// In Match model
match_status: 'scheduled'  // Always defaulted
```

### Recommended Enhancement
```javascript
function determineMatchStatus(matchDate) {
  const now = new Date();
  const match = new Date(matchDate);
  
  if (match < now) {
    // Match date has passed
    return 'completed';  // Assume completed if in past
  } else if (match.toDateString() === now.toDateString()) {
    // Match is today
    return 'scheduled';  // Could be in_progress but can't tell
  } else {
    // Match is in future
    return 'scheduled';
  }
}
```

### Limitations
- ❌ Cannot detect cancelled matches
- ❌ Cannot detect postponed matches
- ❌ Cannot distinguish scheduled from in_progress for same-day matches
- ✅ Can distinguish past from future matches

---

## Recommendations

### Short-term: Phase 2 (Dual System)

1. **Use What We Have**
   - ✅ Keep team season stats for APSL (W/L/T, GF/GA)
   - ✅ Show schedule with dates and opponents
   - ✅ Use date-based match status (past = completed)
   - ✅ Display "Score unavailable" for completed matches

2. **Implement CASA Schedule Parser**
   - Fix `CasaScraper.fetchSchedule()` to parse iframe JSON
   - Extract match dates, times, teams, venues
   - Same limitations as APSL (no scores)

3. **Update UI Expectations**
   - Show team records from season stats (e.g., "3-2-6, 11 pts")
   - Don't promise individual match scores (not available)
   - Focus on schedule visibility, not results tracking

### Long-term: Phase 3 (FootballHome Native)

1. **Manual Score Entry System**
   - Build admin UI to enter match scores after games
   - Store in database with persistence to SQL files
   - Display in FootballHome even though not in league sites

2. **Consider Alternative Data Sources**
   - League admins may have internal systems
   - Could potentially get data dumps
   - May require partnerships with leagues

3. **Build Match Management**
   - Allow marking matches as cancelled/postponed
   - Enable score corrections
   - Track match officials, weather, notes

---

## Data Quality Issues

### APSL
1. **Team Name Inconsistency**
   - Standings JSON: "Lighthouse Boys Club"
   - Roster pages: "Lighthouse 1893 SC"
   - **Impact**: Stats import fails due to name mismatch
   - **Solution**: Implement fuzzy name matching or maintain mapping table

### CASA
1. **Authentication Required**
   - Standings/results pages require login
   - **Impact**: Cannot scrape public data
   - **Solution**: Use Google Sheets where available, implement login if possible

2. **Google Sheets Reliability**
   - URLs may change
   - Sheets may be empty or outdated
   - **Impact**: Roster data may be stale
   - **Solution**: Monitor for 404s, implement fallback strategies

---

## Conclusion

### What We Can Do
✅ Team structure and organization  
✅ Player rosters with jersey numbers  
✅ Match schedules with dates and opponents  
✅ Team season records (APSL only): W/L/T, GF/GA, Points  
✅ Date-based match status (past = completed)  

### What We Cannot Do (Without Manual Entry)
❌ Individual match scores for completed games  
❌ Accurate match status (cancelled, postponed, in_progress)  
❌ Match details (goals, cards, substitutions)  
❌ CASA team season statistics  
❌ Real-time score updates  

### Migration Strategy Impact

**Phase 1 (GroupMe Only)**: Blocked - GroupMe API doesn't support RSVP writes

**Phase 2 (Dual System)**:  
- GroupMe for RSVPs ✅
- FootballHome for:
  - Team rosters ✅
  - Schedule viewing ✅
  - Season standings (APSL) ✅
  - ❌ Cannot replace GroupMe for match results discussion
  
**Phase 3 (FootballHome Only)**:  
- Requires building manual score entry system
- Admins must input match results after games
- Not a full replacement for league website match tracking

### Recommendation

**Focus Phase 2 on schedule/roster richness, NOT match results.**  
Users should still visit league sites for scores until Phase 3 manual entry system is built.
