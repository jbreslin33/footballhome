# Migration Plan: Static Structure + Dynamic Data Scraping

## Overview

Migrate from **dynamic team creation** to **static structure + dynamic data enrichment** model.

### Current Problem:
- Scrapers auto-create teams/clubs/sport_divisions
- Results in duplicates (Philadelphia SC II appearing 2x)
- No way to handle team aliases
- Team IDs change between scrapes

### Solution:
- **Phase 1 (Discovery)**: Run scrapers in discovery mode to output structure
- **Manual Review**: Create static SQL files with curated structure
- **Phase 2 (Enrichment)**: Scrapers only fetch dynamic data (matches, players, rosters)

---

## Implementation Steps

### Step 1: Create Shared Services ✅

**Files Created:**
- `/database/scripts/services/TeamMatcher.js` - Matches scraped names to known teams
- `/database/scripts/modes/DiscoveryMode.js` - Phase 1 discovery scraping

**What They Do:**
- `TeamMatcher`: Loads teams from registry, matches using exact/alias/normalized names
- `DiscoveryMode`: Scrapes structure only, outputs for manual review

### Step 2: Run Discovery Mode for APSL

```bash
node database/scripts/scrapers/run-apsl.js --discover
```

**Expected Output:**
```
=================================================================
DISCOVERY RESULTS: APSL
=================================================================

📍 CONFERENCES:
  • Southeast (Southeast)
  • Mid-Atlantic (Mid-Atlant)

🏆 DIVISIONS:
  • Southeast - Division 1
  • Southeast - Division 2
  • Mid-Atlantic - Division 1
  
⚽ TEAMS:
  • Lighthouse 1893 SC
    External ID: 114844
    Suggested Aliases: Lighthouse, 1893 SC, Lighthouse 1893
  • Philadelphia Soccer Club
    External ID: 118063
    Suggested Aliases: Philly SC, Philadelphia
  ...
```

**Action:** Review output, note duplicates, manually curate team list

### Step 3: Run Discovery Mode for CASA

```bash
node database/scripts/scrapers/run-casa.js --discover
```

**Action:** Same as Step 2 for CASA teams

### Step 4: Create Static SQL Files

Manually create/update these files based on discovery output:

**`database/data/020-clubs.sql`**
```sql
-- All clubs (APSL + CASA + custom)
-- Manually maintained

INSERT INTO clubs (id, display_name, slug, is_active, notes) VALUES
  (1, 'Lighthouse 1893 SC', 'lighthouse-1893-sc', true, 'APSL team'),
  (2, 'Philadelphia Soccer Club', 'philadelphia-sc', true, 'CASA team'),
  (3, 'Oaklyn Soccer Club', 'oaklyn-sc', true, 'CASA team'),
  ...
ON CONFLICT (id) DO NOTHING;
```

**`database/data/021-sport-divisions.sql`**
```sql
-- All sport divisions
-- Links clubs to sports/age groups

INSERT INTO sport_divisions (id, club_id, name, sex, age_label, is_active, source_system_id) VALUES
  (1, 1, 'Lighthouse 1893 SC Soccer', 'men', 'Open', true, 1),  -- APSL
  (2, 2, 'Philadelphia SC Liga 1', 'men', 'Open', true, 2),      -- CASA Liga 1
  (3, 2, 'Philadelphia SC Liga 2', 'men', 'Open', true, 2),      -- CASA Liga 2
  ...
ON CONFLICT (id) DO NOTHING;
```

**`database/data/022-teams.sql`**
```sql
-- All teams
-- Now includes BOTH first and second teams

INSERT INTO teams (id, sport_division_id, name, city, source_system_id, external_id) VALUES
  (1, 1, 'Lighthouse 1893 SC', 'Philadelphia', 1, '114844'),
  (2, 2, 'Philadelphia Soccer Club', 'Philadelphia', 2, 'casa-team-1'),
  (3, 3, 'Philadelphia SC II', 'Philadelphia', 2, 'casa-team-11'),  -- Correctly in Liga 2!
  ...
ON CONFLICT (id) DO NOTHING;
```

**`database/data/023-team-aliases.sql`**
```sql
-- Team name variations for matching

INSERT INTO team_aliases (team_id, alias_name, alias_type_id, source_system_id) VALUES
  -- Lighthouse aliases
  (1, 'Lighthouse', 1, 1),
  (1, '1893 SC', 1, 1),
  (1, 'Lighthouse 1893', 1, 1),
  (1, 'Lighthouse Old Timers Club', 1, 1),  -- Roster sheet name
  
  -- Philadelphia SC aliases
  (2, 'Philadelphia SC', 1, 2),
  (2, 'Philly SC', 1, 2),
  (2, 'Philadelphia', 1, 2),
  
  -- Philadelphia SC II aliases
  (3, 'Philadelphia SC II', 1, 2),
  (3, 'Philly SC II', 1, 2),
  (3, 'Philadelphia SC 2', 1, 2),
  (3, 'Philadelphia II', 1, 2),
  ...
ON CONFLICT (team_id, alias_name) DO NOTHING;
```

### Step 5: Update Scrapers to Use TeamMatcher

**Modify `CasaScraper.js` and `ApslScraper.js`:**

```javascript
// In constructor
this.teamMatcher = new TeamMatcher(this.registry, this);

// In transformData()
async transformData() {
    // Load existing teams from SQL files FIRST
    const dataLoader = new DataLoader(this.registry, this);
    dataLoader.loadAllExistingData();
    
    // Initialize TeamMatcher
    this.teamMatcher.initialize();
    
    // NO MORE TEAM CREATION - only match existing teams
    // Process matches, players, rosters using matched teams
}

// In roster processing
async fetchRostersFromPublishedSheet(url, sheetName, divisionId) {
    // ... parse roster sheet ...
    
    for (const row of rows) {
        const scrapedTeamName = row.teamName;
        
        // Match to known team (no longer creating)
        const team = this.teamMatcher.findTeamByName(scrapedTeamName, this.SOURCE_SYSTEM_ID);
        
        if (!team) {
            this.logWarning(`Unknown team "${scrapedTeamName}" - add to static SQL files and re-run`);
            continue;
        }
        
        // Create player and link to team
        const player = this.createPlayer(row);
        this.createTeamPlayer(team.id, player.id, row.jerseyNumber);
    }
}
```

### Step 6: Update SQL File Naming Convention

**OLD (dynamic creation):**
```
028-casa-teams.sql          # Generated by scraper
030-casa-schedule.sql       # Generated by scraper
024-casa-players.sql        # Generated by scraper
```

**NEW (static structure + dynamic data):**
```
020-clubs.sql               # Static, manually maintained
021-sport-divisions.sql     # Static, manually maintained
022-teams.sql               # Static, manually maintained
023-team-aliases.sql        # Static, manually maintained

030a-matches-apsl.sql       # Dynamic, scraper-generated
030b-matches-casa.sql       # Dynamic, scraper-generated
040a-players-apsl.sql       # Dynamic, scraper-generated
040b-players-casa.sql       # Dynamic, scraper-generated
050a-team-players-apsl.sql  # Dynamic, scraper-generated
050b-team-players-casa.sql  # Dynamic, scraper-generated
```

### Step 7: Test Migration

1. **Run discovery mode** for both leagues
2. **Create static SQL files** based on discovery output
3. **Clear old scraper-generated files**:
   ```bash
   rm database/data/025-casa-clubs.sql
   rm database/data/027-casa-sport-divisions.sql
   rm database/data/028-casa-teams.sql
   rm database/data/021-apsl-teams.sql
   # etc.
   ```
4. **Rebuild database** with static files:
   ```bash
   ./dev.sh
   ```
5. **Run enrichment scraper**:
   ```bash
   ./dev.sh --casa --apsl
   ```
6. **Verify**:
   - Teams exist with correct IDs
   - No duplicates
   - Matches linked to correct teams
   - Players linked to correct teams

---

## Benefits of New Approach

### ✅ Solves Duplicate Team Problem
- Philadelphia SC II only appears once (correctly in Liga 2)
- No need for duplicate detection logic

### ✅ Stable Team IDs
- Team IDs don't change between scrapes
- Can reference teams in other tables safely

### ✅ Aliases Work
- "Lighthouse Old Timers Club" → matches → Lighthouse 1893 SC (team_id: 1)
- "Philly SC II" → matches → Philadelphia SC II (team_id: 3)

### ✅ Better Data Quality
- Manual review catches errors (misspellings, wrong divisions)
- Clear separation: structure (static) vs data (dynamic)

### ✅ Easier Maintenance
- Adding a new team: edit SQL file, rebuild
- No need to re-scrape entire league structure

### ✅ Shared Logic
- TeamMatcher works for APSL and CASA
- DiscoveryMode works for all scrapers
- Less code duplication

---

## Rollout Plan

### Phase 1: Proof of Concept (CASA only)
1. Run CASA discovery mode
2. Create static SQL files for CASA
3. Modify CasaScraper to use TeamMatcher
4. Test and verify

### Phase 2: Full Migration (APSL + CASA)
1. Run APSL discovery mode
2. Merge APSL + CASA into shared static files
3. Modify ApslScraper to use TeamMatcher
4. Test both leagues together

### Phase 3: Cleanup
1. Remove old team creation logic from scrapers
2. Remove duplicate detection logic (no longer needed)
3. Update documentation
4. Archive old scraper-generated files

---

## Open Questions

1. **How to handle teams that change divisions mid-season?**
   - Use `team_divisions` junction table with `is_active` flag
   - Keep historical records

2. **What if a new team appears mid-season?**
   - Run discovery mode again
   - Add team to static SQL file
   - Rebuild database
   - Or: Add via UI (if we build team management)

3. **How to version control static SQL files?**
   - Commit to git
   - Use migrations for changes
   - Track in audit log

4. **Should we auto-generate team_aliases from discovery?**
   - Yes, as suggestions
   - But require manual review before committing

---

## Success Criteria

- [ ] No duplicate teams in database
- [ ] Philadelphia SC II appears once, correctly in Liga 2
- [ ] All scraped matches link to correct teams
- [ ] All scraped players link to correct teams
- [ ] Team aliases work for all known variations
- [ ] Scrapers run faster (no team creation overhead)
- [ ] Team IDs stable between scrapes
