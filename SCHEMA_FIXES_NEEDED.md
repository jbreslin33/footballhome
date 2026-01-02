# Schema & Data Fixes Required

## Summary
The database initialization is partially working but has critical schema mismatches between the SQL insert files and the actual schema definitions.

## Current Status
✅ **Working:**
- Database containers start successfully
- Schema creates 59 tables
- User authentication works (James Breslin can log in)
- 5 governing bodies loaded successfully
- File organization cleaned up (39 files → 28 files)
- 3-digit file numbering system implemented

❌ **Broken:**
- Organizations table: 0 rows (should be 2: APSL, CASA)
- Leagues table: 0 rows (should be 3)
- Conferences table: 0 rows (should be 16)
- Divisions table: 0 rows (should be 32)
- All scraped data tables: 0 rows (expected - scrapers not run yet)

## Root Cause
**Schema column names don't match INSERT statement column names**

The INSERT files were created manually but the schema was generated differently, causing mismatches.

## Issues by File

### 1. `015-organizations.sql` ✅ **LIKELY WORKS**
- Uses: `governing_body_id`
- Schema has: `governing_body_id` (foreign key)
- **Status:** Should work, but showing 0 rows - needs investigation

### 2. `016-leagues.sql` ❌ **BROKEN**
**Problem:** Uses `short_name` column that doesn't exist

```sql
-- Current (WRONG):
INSERT INTO leagues (id, organization_id, name, short_name, season_year, age_calculation_method_id)

-- Schema has these columns:
- name (✅ exists)
- season (❌ not season_year)
- NO short_name column
```

**Fix needed:**
```sql
INSERT INTO leagues (id, organization_id, name, season, age_calculation_method_id)
VALUES
  (1, 1, 'APSL 2025 Season', '2025', 1),
  (2, 2, 'CASA Traditional 2024-2025 Season', '2024-2025', 1),
  (3, 2, 'CASA Select 2024-2025 Season', '2024-2025', 1)
```

### 3. `017-conferences.sql` ❌ **BROKEN**
**Problem:** Uses `short_name` column that doesn't exist

```sql
-- Current (WRONG):
INSERT INTO conferences (id, league_id, name, short_name)

-- Schema has:
- name (✅ exists)
- abbreviation (❌ not short_name)
```

**Fix needed:**
```sql
INSERT INTO conferences (id, league_id, name, abbreviation)
-- OR just omit abbreviation if not needed:
INSERT INTO conferences (id, league_id, name)
```

### 4. `018-divisions.sql` ❌ **BROKEN**
**Problem:** Uses `tier_level` column that doesn't exist

```sql
-- Current (WRONG):
INSERT INTO divisions (id, conference_id, name, tier_level)

-- Schema has:
- name (✅ exists)
- conference_id (✅ exists)
- league_id (❌ MISSING from INSERT but REQUIRED in schema!)
- skill_level (❌ not tier_level)
- division_type_id (optional)
```

**Fix needed:**
```sql
INSERT INTO divisions (id, league_id, conference_id, name, skill_level)
VALUES
  -- APSL: Must include league_id=1
  (1, 1, 1, 'Division 1', 1),
  (2, 1, 2, 'Division 1', 1),
  ...
  -- CASA Traditional
  (9, 2, 9, 'Primera', 1),
  (10, 2, 9, 'Segunda', 2),
  ...
```

### 5. `010-governing-bodies.sql` ⚠️ **PARTIALLY WORKING**
**Status:** 5 of 5 rows loaded successfully (minimal version)

**Original file issues (010-governing-bodies-full.sql.broken):**
- 668 bodies attempted, only 82 loaded
- Multiple INSERT statements with duplicate names
- ON CONFLICT fails when duplicates exist within same INSERT
- Special character escaping issues (`\'`, accented characters)
- Duplicate names need to be made unique:
  - "Asociación del Fútbol Argentino - CABA"
  - "Fédération Congolaise de Football"
  - "Nunavut Soccer Association"
  - "Schleswig-Holsteinischer Fußball-Verband"
  - "US Virgin Islands Soccer Association"

**Current solution:** Using minimal file with 5 essential bodies
**Future work:** Fix full file (668 bodies) by:
1. Converting to one INSERT per row
2. Making duplicate names unique (add state/region qualifiers)
3. Fixing special character escaping
4. Using ON CONFLICT (id) instead of ON CONFLICT (name)

## Schema Reference

### leagues table columns:
```
id, organization_id, name, season, website_url, affiliation,
age_calculation_method_id, age_min, age_max, age_cutoff_month_day,
age_display_label, sex_restriction, source_system_id, external_id,
is_active, created_at
```

### conferences table columns:
```
id, league_id, name, abbreviation, source_system_id, external_id,
sort_order, created_at
```

### divisions table columns:
```
id, league_id, conference_id, name, division_type_id, skill_level,
skill_label, source_system_id, external_id, sort_order, created_at
```

## Action Plan

### Immediate (Critical Path):
1. ✅ Fix `016-leagues.sql` - replace `short_name` with `season`
2. ✅ Fix `017-conferences.sql` - replace `short_name` with `abbreviation` or omit
3. ✅ Fix `018-divisions.sql` - add `league_id`, replace `tier_level` with `skill_level`
4. ✅ Test rebuild

### After Basic Structure Works:
5. Run scrapers to populate teams/players/matches
6. Test login and schema viewer
7. Verify coach assignments work (James → all Lighthouse teams)

### Future Enhancements:
8. Fix full governing bodies file (668 bodies)
9. Add more manual users/admins as needed
10. Implement CASA scraper with team name normalization

## Files to Edit

```
database/data/016-leagues.sql       - Fix column names
database/data/017-conferences.sql   - Fix column names
database/data/018-divisions.sql     - Add league_id, fix column names
```

## Testing Command
```bash
cd /home/jbreslin/sandbox/github/footballhome
podman-compose down
podman volume rm footballhome_db_data
podman-compose up -d
sleep 40
podman exec footballhome_db psql -U footballhome_user -d footballhome -c \
  "SELECT 'Governing Bodies' as table, COUNT(*) FROM governing_bodies
   UNION ALL SELECT 'Organizations', COUNT(*) FROM organizations
   UNION ALL SELECT 'Leagues', COUNT(*) FROM leagues
   UNION ALL SELECT 'Conferences', COUNT(*) FROM conferences
   UNION ALL SELECT 'Divisions', COUNT(*) FROM divisions
   UNION ALL SELECT 'Users', COUNT(*) FROM users;"
```

Expected results after fixes:
- Governing Bodies: 5
- Organizations: 2
- Leagues: 3
- Conferences: 16
- Divisions: 32
- Users: 1
