# Data Loading Strategy (REVISED January 2026)

## Core Principle: Historical vs. Current Season

**STATIC DATA (SQL Files)**:
- All data from **completed seasons** (2022-2025) → SQL files committed to git
- **One-time scrape** to populate SQL files, then scrapers focus on current season only
- Reproducible, version-controlled, no re-scraping of old data

**DYNAMIC DATA (Scrapers)**:
- Only **current season** (2025/2026) data scraped dynamically
- New matches, rosters, standings updated as season progresses
- Once season ends → export to SQL files, commit to git, stop scraping

## Data Categories

### 1. Static Reference Data (SQL Files)
**Location**: `database/data/*.sql`  
**When Loaded**: Every rebuild via `docker-entrypoint-initdb.d`  
**Source**: Manually created by developers

**Files**:
- `00-schema.sql` - Schema + lookup tables
- `013d-h` - Scrape target state machine
- `014-continents.sql` - Continents reference data
- `020-024` - Users, admins, persons (manual)

### 2. League Structure (SQL Files - ✅ COMPLETE)
**Location**: `database/data/030-034-*.sql`  
**When Loaded**: Every rebuild  
**Source**: One-time scrape → exported to SQL → committed to git

**Files**:
- `030-organizations.sql` - APSL, CSL, CASA, Lighthouse organizations (4 orgs)
- `031-leagues.sql` - APSL, CSL, CASA leagues (4 leagues)
- `032-seasons.sql` - All seasons 2022-2026 (8 seasons)
- `033-conferences.sql` - APSL Metropolitan/National/etc (27 conferences)
- `034-divisions.sql` - All divisions across all seasons (36 divisions)

**✅ COMPLETE**: Divisions exist in SQL files. Scrapers should **NEVER** create divisions.

### 3. Teams (SQL Files - ✅ COMPLETE)
**Location**: `database/data/040-041-*.sql`  
**When Loaded**: Every rebuild  
**Source**: One-time scrape → exported to SQL → committed to git

**Files**:
- `040-apsl-teams.sql` - 99 APSL teams (static, persist across seasons)
- `041-csl-teams.sql` - 167 CSL teams (static, persist across seasons)

**Philosophy**: Teams are organizations/clubs that persist across seasons. While their rosters change, the team entity itself is stable.

### 4. Historical Data (SQL Files - 🔄 TO BE CREATED)
**Location**: `database/data/050-0XX-*.sql`  
**When Loaded**: Every rebuild  
**Source**: One-time scrape of past seasons → export to SQL → commit to git

**Files to Create**:
- `050-standings.sql` - All standings from 2022-2024 seasons (current season stays dynamic)
- `051-historical-matches.sql` - All matches from 2022-2024 seasons (current season stays dynamic)
- `052-historical-match-events.sql` - Goals, cards, subs from 2022-2024 (current season stays dynamic)
- `053-historical-players.sql` - Player records from past seasons
- `054-historical-rosters.sql` - Team rosters from past seasons (division_team_players)

**Why**:
- Prevents re-scraping old games every time database rebuilds
- Version-controlled historical data (reproducible)
- Scrapers only process new/current season data (faster, more efficient)
- Once current season ends (June 2026), export to SQL and stop scraping

### 5. Dynamic Current Season Data (Scrapers Only)
**Location**: Database only (NOT in SQL files)  
**When Loaded**: Via `update.sh` (scraper runs)  
**Source**: External websites (APSL, CSL for 2025/2026 season)  
**Persistence**: Survives rebuilds via Docker volumes

**Data Types**:
- **2025/2026 Season Only**:
  - Division assignments (division_teams) - which teams are playing this season
  - Standings (current rankings)
  - Matches (scheduled and played)
  - Match events (goals, cards, subs)
  - Rosters (division_team_players) - current jersey numbers, active players

**Roster History Tracking (Fully Normalized)**:
- Composite PRIMARY KEY (division_team_id, player_id, joined_at) - allows transfer history
- Each row represents one period of team membership (joined_at → left_at)
- NO `is_active` column - derived from `left_at IS NULL` (fully normalized)
- Player transfers tracked automatically:
  - Player found on new team → Close old period (set left_at=NOW)
  - Create new period for new team (new row with joined_at=NOW)
  - Example: John Doe played for Hoboken (Sept-Jan), then Lighthouse (Jan-June)
- Query current roster: `WHERE left_at IS NULL`
- Query player history: `WHERE player_id = X ORDER BY joined_at DESC`

**Same Pattern Applied To**:
- `division_team_coaches` - coaching tenure history (ended_at IS NULL = current)
- `division_teams` - promotion/relegation history (unregistered_at IS NULL = current)
- `club_admins`, `league_admins`, `team_admins` - admin tenure history (ended_at IS NULL = current)

**Scraper Behavior**:
- Check if match already exists in DB before scraping (avoid re-scraping old games)
- Only scrape matches not yet in database
- Upsert rosters: if player on different team, close old period and create new (transfer)
- Update standings as matches are played

**End of Season Workflow**:
1. Season ends (June 2026)
2. Export all 2025/2026 data to SQL files (standings, matches, events, rosters)
3. Commit SQL files to git
4. Update scrape targets to 2026/2027 season URLs
5. Future scrapers only process 2026/2027 data
3. Disable venue scraper

## Scraper Configuration

### Scrape Actions
Set `scrape_action_id` in `scrape_targets` table:
- `1` (download_and_parse) - Active scraping
- `2` (skip) - Don't run (data in SQL files)
- `3` (download_only) - Cache HTML only
- `4` (parse_only) - Parse cached HTML

### Scrape Status State Machine
- `1` (not_started) - Ready to run
- `2` (in_progress) - Currently running
- `3` (completed) - Successfully completed
- `4` (needs_refresh) - Needs re-scraping
- `5` (failed) - Error occurred
- `6` (archived) - Old/deprecated target

### Example: Disable a Scraper After One-Time Run
```sql
-- Mark venue scraper as skip (data now in SQL file)
UPDATE scrape_targets 
SET scrape_action_id = 2  -- skip
WHERE scraper_type_id = 6 AND label LIKE '%Venue%';
```

## Best Practices

### When to Use SQL Files
✅ Data is known in advance (league structures)  
✅ Data rarely changes (organizations, divisions)  
✅ Data created manually (users, admins)  
✅ One-time imports (venues, historical data)  
✅ Reference/lookup tables (positions, match types)

### When to Use Scrapers
✅ Data changes frequently (matches, standings)  
✅ Large volume of data (players, match events)  
✅ External source of truth (league websites)  
✅ Data updates weekly/daily (rosters, schedules)

### When to Use One-Time Scrape → SQL
✅ Data doesn't change often (venues)  
✅ Need reproducible builds (same venues every time)  
✅ Want to version control data (git commits)  
✅ External API has rate limits (Google Places)

## File Naming Convention

SQL files in `database/data/` are loaded **alphabetically**:
- `000-099`: Schema and core lookups
- `013-019`: Scrape system tables
- `020-029`: User/person/admin data
- `030-039`: League structure (organizations, leagues, seasons, divisions)
- `040-049`: Clubs and teams (manual/static)
- `050-089`: Application features (standings, events, etc.)
- `090-099`: Views and functions

Use letter suffixes (a/b/c) when order matters within same number:
- `032a-apsl-seasons.sql`
- `032b-csl-seasons.sql`
- `032c-casa-seasons.sql`

## Scraper Configuration Strategy

### Rule 1: Divisions NEVER Created by Scrapers
**FIXED**: `ApslStructureScraper.js` now looks up divisions instead of creating them.

```javascript
// ❌ OLD (WRONG):
const divResult = await this.divisionRepo.upsertMany(divisions);

// ✅ NEW (CORRECT):
const savedDivisions = await this.divisionRepo.findBySeason(seasonResult.id);
if (savedDivisions.length === 0) {
  throw new Error(`No divisions found! Must exist in 034-divisions.sql`);
}
```

All division creation must happen in `034-divisions.sql`.

### Rule 2: Only Scrape What Doesn't Exist
**TO BE IMPLEMENTED**: Match and standings scrapers should check database first.

```javascript
// Check if match already exists before scraping
const existing = await this.matchRepo.findByExternalId(sourceSystemId, externalId);
if (existing) {
  console.log(`   ⏭️  Skipping match ${externalId} (already in database)`);
  continue; // Skip to next match
}
// Only scrape if not found
await scrapeMatch(matchUrl);
```

Benefits:
- Faster scrapes (skip old games)
- Less network traffic
- Idempotent (safe to run multiple times)
- Historical data preserved in SQL files

### Rule 3: Season-Based Scraping
Configure scrape targets to only process current season:

**scrape-targets.json**:
```json
{
  "id": 3,
  "label": "APSL 2025/2026 Season",
  "url": "https://www.apslsoccer.com/APSL/Standings/2025-26",
  "is_active": true,
  "config": {
    "season_filter": "2025/2026"  // Only scrape this season
  }
}
```

**End of season workflow**:
1. June 2026: Season ends
2. Export all 2025/2026 data to SQL files
3. Update scrape target URL to 2026/2027
4. Historical 2025/2026 data now loads from SQL

## Implementation Checklist

### ✅ Completed
- [x] Divisions exported to `034-divisions.sql`
- [x] Teams exported to `040-apsl-teams.sql`, `041-csl-teams.sql`
- [x] ApslStructureScraper refactored to lookup divisions (not create)
- [x] Documentation updated with historical vs. current season strategy

### 🔄 In Progress
- [ ] Export historical standings to `050-standings.sql`
- [ ] Export historical matches to `051-historical-matches.sql`
- [ ] Export historical match events to `052-historical-match-events.sql`
- [ ] Export historical players/rosters to `053-historical-players.sql`, `054-historical-rosters.sql`

### ⏳ Todo
- [ ] Add "skip if exists" logic to ApslMatchScraper
- [ ] Add "skip if exists" logic to CslMatchScraper
- [ ] Configure scrape targets to only scrape 2025/2026 season
- [ ] Test full rebuild with historical SQL files
- [ ] Document end-of-season export workflow

## Complete Development Workflow

### 1. Full Rebuild (Fresh Start)
```bash
# Destroy everything, rebuild from SQL files
./build.sh

# Check what loaded from SQL files (should show structure, no dynamic data)
node database/scripts/audit-database.js
# Expected: Teams/divisions/seasons present, 0 matches/standings/players

# Populate dynamic data via scrapers
./update.sh

# Verify what was scraped
node database/scripts/audit-database.js
# Expected: Matches, standings, players now populated
```

### 2. Regular Updates (During Season)
```bash
# Before scraping: see what's missing
node database/scripts/audit-database.js
# Shows: "16 matches need results"

# Run scrapers to get new data
./update.sh

# After scraping: verify changes
node database/scripts/audit-database.js
# Shows: "0 matches need results" (if successful)
```

### 3. Quick Check (Anytime)
```bash
# See current database state
node database/scripts/audit-database.js

# Output shows:
# - Structure counts (teams, divisions, seasons)
# - Current season data (matches, standings, rosters)
# - What's missing (matches without results)
# - Scrape target status
```

### 4. Debugging Workflow
```bash
# Something wrong? Check state
node database/scripts/audit-database.js

# Rebuild from clean slate
./build.sh

# Verify SQL files loaded
node database/scripts/audit-database.js

# Re-populate
./update.sh

# Verify again
node database/scripts/audit-database.js
```

## How to Know What You Have vs What You Need

### Quick Audit Script
```bash
# Run comprehensive database audit
node database/scripts/audit-database.js
```

**Shows**:
- ✅ What structure exists (orgs, leagues, divisions, teams)
- 📅 Current season data (matches, standings, rosters)
- 📚 Historical data (past seasons)
- 🔍 What's missing (matches needing results)
- 🎯 Scrape target status

### Manual SQL Queries

```bash
# What structure exists (from SQL files)?
podman exec footballhome_db psql -U footballhome_user -d footballhome -c \
  "SELECT 'organizations', COUNT(*) FROM organizations UNION ALL 
   SELECT 'leagues', COUNT(*) FROM leagues UNION ALL 
   SELECT 'seasons', COUNT(*) FROM seasons UNION ALL 
   SELECT 'divisions', COUNT(*) FROM divisions UNION ALL
   SELECT 'teams', COUNT(*) FROM teams;"

# Current season: what matches need results?
podman exec footballhome_db psql -U footballhome_user -d footballhome -c \
  "SELECT COUNT(*) as matches_needing_results
   FROM matches m
   JOIN divisions d ON m.division_id = d.id
   JOIN seasons s ON d.season_id = s.id
   WHERE s.name LIKE '%2025/2026%'
     AND m.match_date < NOW()
     AND m.home_score IS NULL;"

# What teams don't have rosters?
podman exec footballhome_db psql -U footballhome_user -d footballhome -c \
  "SELECT t.display_name, COUNT(dtp.player_id) as roster_size
   FROM division_teams dt
   JOIN teams t ON dt.team_id = t.id
   JOIN divisions d ON dt.division_id = d.id
   JOIN seasons s ON d.season_id = s.id
   LEFT JOIN division_team_players dtp ON dtp.division_team_id = dt.id
   WHERE s.name LIKE '%2025/2026%'
   GROUP BY t.id, t.display_name
   HAVING COUNT(dtp.player_id) = 0
   ORDER BY t.display_name;"

# Check scrape target status
podman exec footballhome_db psql -U footballhome_user -d footballhome -c \
  "SELECT id, label, sa.name as action, ss.name as status 
   FROM scrape_targets st 
   LEFT JOIN scrape_actions sa ON st.scrape_action_id = sa.id 
   LEFT JOIN scrape_statuses ss ON st.scrape_status_id = ss.id 
   ORDER BY id;"

# Test full rebuild (destroys data, recreates from SQL files)
./build.sh
```

## Summary

**Core Strategy**: Historical seasons in SQL files (committed to git), current season scraped dynamically.

**Key Benefits**: 
- No re-scraping of old games (faster, more efficient)
- Reproducible builds (historical data version-controlled)
- No duplicate divisions (scrapers lookup, never create)
- Clear data lifecycle (scrape → export → commit → stop scraping)
- Easier debugging (historical data doesn't change)

**Next Steps**: Export historical standings/matches/rosters to SQL files, configure scrapers for current season only.
