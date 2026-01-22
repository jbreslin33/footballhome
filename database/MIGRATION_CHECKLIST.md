# Database Migration Checklist

## Goal
Move league structure from scrapers to SQL files to prevent duplicates and ensure reproducible builds.

## Status Legend
- ⏸️ Not Started
- 🔄 In Progress
- ✅ Complete
- ❌ Blocked

---

## Phase 1: Extract Current Data to SQL Files

### 1.1 Organizations (⏸️)
**File**: `database/data/030-organizations.sql`

**Query to Extract Current Data**:
```sql
SELECT 
  id,
  name,
  slug,
  description,
  external_id,
  source_system_id,
  is_active
FROM organizations
ORDER BY id;
```

**Expected Records**:
- APSL (American Premier Soccer League)
- CSL (Cosmopolitan Soccer League)
- CASA (CASA Soccer Leagues)
- Lighthouse 1893 SC (our club)

---

### 1.2 Leagues (⏸️)
**File**: `database/data/031-leagues.sql`

**Query to Extract Current Data**:
```sql
SELECT 
  id,
  organization_id,
  name,
  slug,
  description,
  external_id,
  source_system_id,
  is_active
FROM leagues
ORDER BY id;
```

**Expected Records**:
- APSL
- CSL  
- CASA
- Lighthouse 1893 SC (internal league)

---

### 1.3 Seasons (⏸️)
**File**: `database/data/032-seasons.sql`

**Query to Extract Current Data**:
```sql
SELECT 
  id,
  league_id,
  name,
  start_date,
  end_date,
  is_active,
  source_system_id,
  external_id
FROM seasons
ORDER BY league_id, name;
```

**Expected Records**:
- APSL: 2025/2026
- CSL: 2022/2023, 2023/2024, 2024/2025, 2025/2026
- CASA: TBD
- Lighthouse: TBD

---

### 1.4 Conferences (⏸️)
**File**: `database/data/033-conferences.sql`

**Query to Extract Current Data**:
```sql
SELECT 
  id,
  season_id,
  name,
  external_id,
  source_system_id,
  is_active
FROM conferences
ORDER BY season_id, name;
```

**Expected Records**:
- APSL 2025/2026: Metropolitan Conference, National Conference
- CSL seasons: Main Conference (single conference)
- CASA: TBD

---

### 1.5 Divisions (⏸️)
**File**: `database/data/034-divisions.sql`

**Query to Extract Current Data**:
```sql
SELECT 
  d.id,
  s.name as season_name,
  c.name as conference_name,
  d.name as division_name,
  d.division_type_id,
  d.skill_level,
  d.skill_label,
  d.source_system_id,
  d.external_id,
  d.sort_order,
  d.is_active
FROM divisions d
JOIN seasons s ON s.id = d.season_id
JOIN conferences c ON c.id = d.conference_id
ORDER BY s.name, c.name, d.sort_order, d.name;
```

**Expected Records**:
- APSL Metropolitan: First Division, Second Division, Third Division, Fourth Division
- APSL National: First Division, Second Division, Third Division
- CSL (per season): Division 1, Division 1 Reserve, Division 2, Division 2 Reserve, Division 3, Division 4, Over-40 Division, Spring Division
- CASA: TBD

---

### 1.6 Clubs (⏸️)
**File**: `database/data/035-clubs.sql`

**Query to Extract Current Data**:
```sql
SELECT 
  id,
  organization_id,
  name,
  slug,
  founded_year,
  home_venue_id,
  website_url,
  logo_url,
  primary_color,
  secondary_color,
  is_active
FROM clubs
WHERE organization_id = (SELECT id FROM organizations WHERE name = 'Lighthouse 1893 SC')
ORDER BY id;
```

**Expected Records**:
- Lighthouse 1893 SC (our club only - others are scraped teams)

---

### 1.7 Venues (⏸️)
**File**: `database/data/036-venues.sql`

**Action**: Run venue scraper once to generate SQL, then commit

**Steps**:
1. Enable venue scraper in scrape_targets
2. Run `./update.sh`
3. Export venues to SQL INSERT statements
4. Commit `036-venues.sql`
5. Set venue scraper to `scrape_action_id = 2` (skip)

**Query to Export**:
```sql
SELECT 
  id,
  name,
  street_address,
  city,
  state_province,
  postal_code,
  country_code,
  latitude,
  longitude,
  google_place_id,
  field_type,
  surface_type,
  has_lights,
  capacity
FROM venues
ORDER BY id;
```

---

## Phase 2: Update Scrapers

### 2.1 APSL Structure Scraper (⏸️)
**File**: `database/scripts/scrapers/ApslStructureScraper.js`

**Changes Needed**:
- Remove organization/league/season/conference/division creation
- Look up existing divisions by season_id + name
- Only create teams and division_teams assignments
- Add warnings when structure not found

**Test**:
1. Delete existing APSL teams and division_teams
2. Run scraper
3. Verify no new divisions created
4. Verify teams assigned to existing divisions

---

### 2.2 CSL Structure Scraper (✅)
**File**: `database/scripts/scrapers/CslStructureScraper.js`

**Status**: Already refactored to look up divisions instead of creating them

**Verification**:
```bash
./update.sh
# Check no duplicate divisions created
podman exec footballhome_db psql -U footballhome_user -d footballhome -c \
  "SELECT season_id, name, COUNT(*) FROM divisions 
   WHERE season_id IN (SELECT id FROM seasons WHERE league_id = 4) 
   GROUP BY season_id, name HAVING COUNT(*) > 1;"
```

---

### 2.3 CASA Structure Scraper (⏸️)
**File**: `database/scripts/scrapers/CasaScraper.js`

**Status**: Parser not yet implemented

**Changes Needed**:
- Follow CSL pattern: lookup divisions, create teams only
- Handle CASA's Google Sheets data source
- Document CASA league structure first

---

### 2.4 Venue Scraper (⏸️)
**File**: `database/scripts/scrapers/VenueScraper.js`

**Changes Needed**:
- Add SQL export functionality
- Generate INSERT statements with proper formatting
- Handle duplicate detection (Google Place ID)
- Set scraper to skip mode after first successful run

---

## Phase 3: Database Scripts

### 3.1 Export Current Data Script (⏸️)
**File**: `database/scripts/export-structure-to-sql.js`

**Purpose**: Export current database structure to SQL files

**Output Files**:
- `030-organizations.sql`
- `031-leagues.sql`
- `032-seasons.sql`
- `033-conferences.sql`
- `034-divisions.sql`
- `035-clubs.sql`

**Features**:
- Generate properly formatted INSERT statements
- Include comments with metadata
- Handle NULL values correctly
- Maintain ID sequences

---

### 3.2 Validation Script (⏸️)
**File**: `database/scripts/validate-structure.js`

**Purpose**: Verify all required structure exists before scraping

**Checks**:
- All leagues have organizations
- All seasons have leagues
- All conferences have seasons
- All divisions have conferences and seasons
- All scrape targets reference valid structures

---

## Phase 4: Testing

### 4.1 Fresh Rebuild Test (⏸️)
**Steps**:
1. Run `./build.sh` (full rebuild)
2. Verify organizations/leagues/seasons/divisions loaded from SQL
3. Verify no duplicate structures
4. Run `./update.sh`
5. Verify teams created successfully
6. Verify no new divisions created

**Success Criteria**:
- Rebuild loads all structure from SQL files
- Scrapers create teams only
- No duplicates after multiple scraper runs
- Super Admin dashboard shows correct data

---

### 4.2 Update Test (⏸️)
**Steps**:
1. Set all CSL scrape targets to `scrape_status_id = 1` (not_started)
2. Run `./update.sh`
3. Check for duplicate divisions
4. Check team counts match expectations

**Success Criteria**:
- No duplicate divisions created
- Teams assigned to correct divisions
- All expected teams present

---

### 4.3 Scrape Target Configuration Test (⏸️)
**Steps**:
1. Verify all structure scrape targets have `scrape_action_id = 2` (skip)
2. Verify team/roster/match targets have `scrape_action_id = 1` (download_and_parse)
3. Run `./update.sh` with various target configurations

**Success Criteria**:
- Skipped targets don't execute
- Active targets execute correctly
- State machine transitions properly

---

## Phase 5: Documentation

### 5.1 Update README (⏸️)
**File**: `database/README.md`

**Add Sections**:
- Data loading strategy overview
- SQL file organization
- Scraper configuration
- How to add new seasons/divisions

---

### 5.2 Update Copilot Instructions (⏸️)
**File**: `.github/copilot-instructions.md`

**Update Sections**:
- Data persistence strategy
- SQL file organization rules
- Scraper responsibilities
- One-time scrape workflow

---

## Completion Checklist

### Files to Create
- [ ] `database/data/030-organizations.sql`
- [ ] `database/data/031-leagues.sql`
- [ ] `database/data/032-seasons.sql`
- [ ] `database/data/033-conferences.sql`
- [ ] `database/data/034-divisions.sql`
- [ ] `database/data/035-clubs.sql`
- [ ] `database/data/036-venues.sql`
- [ ] `database/scripts/export-structure-to-sql.js`
- [ ] `database/scripts/validate-structure.js`

### Files to Update
- [x] `database/scripts/scrapers/CslStructureScraper.js` (already done)
- [ ] `database/scripts/scrapers/ApslStructureScraper.js`
- [ ] `database/scripts/scrapers/CasaScraper.js`
- [ ] `database/scripts/scrapers/VenueScraper.js`
- [ ] `database/README.md`
- [ ] `.github/copilot-instructions.md`

### Testing
- [ ] Fresh rebuild loads structure from SQL
- [ ] Update.sh doesn't create duplicate structures
- [ ] All scrapers work with new pattern
- [ ] Super Admin dashboard shows correct data

---

## Next Steps

1. **Export Current Data**: Run queries to extract current organizations/leagues/seasons/divisions
2. **Create SQL Files**: Format as INSERT statements in numbered files
3. **Test Rebuild**: Verify data loads correctly
4. **Update Scrapers**: Modify remaining scrapers to lookup instead of create
5. **Full Integration Test**: Clean rebuild + scrape to verify everything works

**Estimated Effort**: 4-6 hours
**Risk Level**: Medium (requires careful testing to avoid data loss)
**Benefit**: High (eliminates duplicates, improves reliability)
