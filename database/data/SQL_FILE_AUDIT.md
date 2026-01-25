# SQL Files Audit - January 25, 2026

## Current File Organization

### ✅ Core Schema & Lookups (00-014)
- **00-schema.sql** (78K) - Complete database schema with all tables
- **001-load-data.sh** - Shell script for data loading
- **013d-scrape-targets.sql** (2.6K) - APSL (IDs 1-4) + CSL (IDs 5-8) + static targets (50, 100)
- **013e-scrape-actions.sql** (702B) - Scrape action lookup data
- **013f-scrape-statuses.sql** (667B) - Scrape status lookup data  
- **013g-scrape-targets-state-machine.sql** (1.1K) - State machine logic
- **013h-scrape-target-junctions.sql** (4.1K) - Junction table definitions
- **013i-casa-scrape-targets.sql** (6.4K) - CASA Select scrape targets (Philadelphia, Boston, Lancaster)
- **013j-casa-league-structure.sql** (3.7K) - CASA Select structure (season 100, conferences 100-103, divisions 100-104)
- **013k-casa-traditional-league-structure.sql** (2.3K) - CASA Traditional structure
- **014-continents.sql** (492B) - Continent lookup data

### ✅ Identity System (020-024)
- **020-persons.sql** (259K) - All persons (players, coaches, admins)
- **021-players-complete.sql** (477K) - Complete player data with positions
- **021-users.sql** (445B) - User authentication records
- **022-user-emails.sql** (455B) - Email addresses
- **023-user-phones.sql** (463B) - Phone numbers
- **024-admins.sql** (629B) - Admin role assignments

### ✅ Organizations & League Structure (030-035)
- **030-organizations.sql** (603B) - Static organizations (APSL, CASA, CSL)
- **030a-organizations-scraped.sql** (5.9K) - Scraped governing bodies
- **031-leagues.sql** (577B) - League definitions
- **032-seasons.sql** (682B) - Season records
- **033-conferences.sql** (1.7K) - Conference groupings
- **034-divisions.sql** (4.1K) - Division/tier definitions
- **035-clubs.sql** (5.3K) - Club entities (Lighthouse, etc.)

### ✅ Teams & Rosters (042-045)
- **042-teams-complete.sql** (15K) - All team entities
- **045-division-teams.sql** (13K) - Team registrations in divisions

### ✅ Match Data (050-052)
- **050-standings.sql** (32K) - League standings
- **051-matches.sql** (45K) - Match records
- **052-match-events.sql** (270K) - Goals, cards, subs, etc.
- **052b-match-divisions.sql** (4.6K) - Match-division associations

### ⚠️ Deprecated Files
- **053-players.sql.old** - Old player data (kept for reference)

---

## ✅ Data Coverage Analysis

### APSL (Source System 1)
**Scrape Targets:**
- ✅ League structure (4 seasons: 2022-2026)
- ✅ Standings (via structure scrape)
- ✅ Matches (via structure scrape)
- ✅ Match events (via structure scrape)

**Generated Data Files:**
- ✅ 020-persons.sql (players from APSL)
- ✅ 021-players-complete.sql
- ✅ 042-teams-complete.sql (APSL teams)
- ✅ 045-division-teams.sql
- ✅ 050-standings.sql
- ✅ 051-matches.sql
- ✅ 052-match-events.sql

### CSL (Source System 3)
**Scrape Targets:**
- ✅ League structure (4 seasons: 2022-2026)
- ✅ Standings (via structure scrape)
- ✅ Matches (via structure scrape)

**Generated Data Files:**
- ✅ Teams, divisions, matches (in same files as APSL)

### CASA Select (Source System 2)
**Scrape Targets - Philadelphia:**
- ✅ Liga 1 Standings (page_node_id: 9090889)
- ✅ Liga 1 Schedule (page_node_id: 9090889)
- ✅ Liga 1 Rosters (Google Sheets)
- ✅ Liga 2 Standings (page_node_id: 9096430)
- ✅ Liga 2 Schedule (page_node_id: 9096430)
- ✅ Liga 2 Rosters (Google Sheets)

**Scrape Targets - Boston:**
- ✅ Liga 1 Standings (page_node_id: 9090891)
- ✅ Liga 1 Schedule (page_node_id: 9090891)
- ❌ Liga 1 Rosters (Google Sheets URL needed)

**Scrape Targets - Lancaster:**
- ✅ Liga 1 Standings (page_node_id: 9090893)
- ✅ Liga 1 Schedule (page_node_id: 9090893)
- ❌ Liga 1 Rosters (Google Sheets URL needed)

**Generated Data Files:**
- ❓ No CASA data files yet (013j/013k only define structure, waiting for scrapers to run)

---

## 🔍 Issues & Missing Data

### 1. ❌ CASA Select Missing Roster URLs
**Boston Liga 1 and Lancaster Liga 1 need Google Sheets roster URLs**

Current pattern from Philadelphia:
```sql
-- Liga 1 Rosters: spreadsheet ID: 2PACX-1vSmsWzjTsLR81d-eQTLDM4EnaqzqUOy5OcWLy1Lna1NYVFY7gOj0nZAQdIk99e99g
-- Liga 2 Rosters: spreadsheet ID: 2PACX-1vQsDtR6AQPgThg1105AinjkLqHMaWgQfCFJuWqfEtadH41k5OSKYZ2Hqb0N-CnO2Q
```

**Action Required:** Get Google Sheets URLs for Boston and Lancaster rosters

### 2. ⚠️ CASA Traditional Not Configured
**013k-casa-traditional-league-structure.sql** defines 12 divisions but:
- ❌ No scrape targets defined
- ❌ No page_node_id values in divisions table
- ⏳ Waiting for spring season visibility

**Action:** Add CASA Traditional scrape targets when spring season pages become visible

### 3. ⚠️ CASA Central NJ Not Configured
**Division 104 exists but:**
- ❌ No external_id (NULL)
- ❌ No scrape targets
- ⏳ Has separate fall/spring seasons (not continuous like Philadelphia)

**Action:** Add Central NJ targets when appropriate season is visible

---

## 📋 Recommended File Organization Changes

### Current Issues:
1. **021-players-complete.sql** (477K) - Should this be **020a-players-complete.sql**?
   - Currently loads AFTER users (021) but should load with persons (020)
   - Fix: Rename to match the persons numbering

2. **File naming inconsistency:**
   - Mix of numbered prefixes (013d, 013e) and alphabetic suffixes (030a, 020a)
   - Current system works but could be more consistent

### Suggested Structure (No Changes Needed - Current is Good):

```
00-019: Schema & Lookups
  00-schema.sql ✅
  001-load-data.sh ✅
  013d-013k: Scrape system configuration ✅
  014: Reference data (continents) ✅

020-029: Identity & Users
  020-persons.sql ✅
  020a-players-complete.sql (rename from 021) 
  021-users.sql ✅
  022-user-emails.sql ✅
  023-user-phones.sql ✅
  024-admins.sql ✅

030-039: Organizations & Structure
  030-organizations.sql ✅
  030a-organizations-scraped.sql ✅
  031-leagues.sql ✅
  032-seasons.sql ✅
  033-conferences.sql ✅
  034-divisions.sql ✅
  035-clubs.sql ✅

040-049: Teams & Rosters
  042-teams-complete.sql ✅
  045-division-teams.sql ✅

050-059: Match Data
  050-standings.sql ✅
  051-matches.sql ✅
  052-match-events.sql ✅
  052b-match-divisions.sql ✅

999: Maintenance
  999-pg-cron-setup.sh ✅
```

---

## ✅ What's Working Well

1. **Clear separation** between:
   - Configuration (013x files)
   - Identity (020s)
   - Structure (030s)
   - Teams (040s)
   - Matches (050s)

2. **Proper use of external_id** in divisions table for scrape target linking

3. **Comprehensive match event data** (270K file = detailed tracking)

4. **State machine approach** for scrape target management

5. **Alphabetical loading** ensures dependencies are met

---

## 🎯 Next Steps

### Immediate (Required for CASA scraping):
1. **Get Boston and Lancaster roster Google Sheets URLs**
   - Add to 013i-casa-scrape-targets.sql
   - Follow same pattern as Philadelphia

2. **Run ./update.sh** to scrape CASA Select data
   - Will generate teams, matches, standings for Boston and Lancaster
   - Should create data files similar to APSL/CSL

### Future (When Visible):
3. **Add CASA Traditional scrape targets** (spring season)
   - 12 divisions need page_node_id values
   - Create scrape targets for standings/schedule/rosters

4. **Add Central NJ** (when appropriate season is visible)
   - Update division 104 with external_id
   - Create scrape targets

### Optional Cleanup:
5. **Rename 021-players-complete.sql → 020a-players-complete.sql**
   - Better aligns with persons (020) numbering
   - Maintains alphabetical loading order

---

## Summary

**Overall Assessment: 🟢 GOOD**

The SQL file organization is **well-structured and logical**. The main issues are:
1. Missing roster URLs for Boston and Lancaster (data gathering needed)
2. CASA Traditional waiting for spring season visibility (timing issue, not a problem)

**No major reorganization needed.** The current structure follows best practices:
- Schema first (00)
- Configuration (013x)
- Identity data (020s)
- Organizational structure (030s)
- Teams and matches (040s, 050s)
- Proper dependency ordering via alphabetical loading

**Action Required:** Just need the Boston and Lancaster roster Google Sheets URLs to complete CASA Select configuration.
