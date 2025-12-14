# Data Architecture Refactoring Plan

## Current Issues

### 1. **APSL vs CASA Asymmetry**

**Files with "-apsl" or "-casa" suffix:**
```
03-leagues.sql          ← APSL only (generic name)
03-leagues-casa.sql     ← CASA specific

04-conferences.sql      ← APSL only (generic name)  
04-conferences-casa.sql ← CASA specific

05-league-divisions.sql      ← APSL only (generic name)
05-league-divisions-casa.sql ← CASA specific

06-clubs.sql            ← APSL only (generic name)
06-clubs-casa.sql       ← CASA specific

07-sport-divisions.sql       ← APSL only (generic name)
07-sport-divisions-casa.sql  ← CASA specific

22-teams-apsl.sql       ← APSL specific
22-teams-casa.sql       ← CASA specific
21-teams-casa.sql       ← CASA specific (duplicate?)

24-players-apsl.sql     ← APSL only
(no casa players file)

30-rosters-apsl.sql     ← APSL only (no casa rosters)
```

**Problem:** The base files (without suffix) assume APSL, making CASA a "second-class citizen"

### 2. **Lighthouse-Only Division Players**

**Current behavior (50-populate-division-players.sql):**
```sql
WHERE c.slug = 'lighthouse-1893-sc'  -- APSL club only!
```

**Problem:** 
- Only populates APSL Lighthouse division
- No equivalent for CASA clubs
- Players from CASA clubs never get added to division rosters
- Duplicates across leagues aren't handled

### 3. **Manual User Assignment**

**Current files:**
- `08b-users-apsl.sql` - Creates APSL-specific users
- `08c-external-identities-apsl.sql` - Links external IDs
- No casa equivalent

**Problem:** No consistent pattern for associating users to multiple divisions/teams

---

## Proposed Solution

### **Rename Files for Equality**

Change the naming to be explicitly multi-league:

**Before:**
```
03-leagues.sql         (APSL)
03-leagues-casa.sql    (CASA)
```

**After:**
```
03-leagues-apsl.sql    (APSL)
03-leagues-casa.sql    (CASA)
```

Apply to all affected files:
- 04-conferences-[league].sql
- 05-league-divisions-[league].sql  
- 06-clubs-[league].sql
- 07-sport-divisions-[league].sql

### **Consolidate Player Population Logic**

Replace the hardcoded Lighthouse script with a generic one:

**Before (50-populate-division-players.sql):**
```sql
WHERE c.slug = 'lighthouse-1893-sc'
```

**After (50-populate-division-players.sql):**
```sql
-- Populate division_players from all clubs (APSL, CASA, etc)
INSERT INTO division_players (division_id, player_id, status, ...)
SELECT DISTINCT
    t.division_id,
    tp.player_id,
    ...
FROM team_players tp
JOIN teams t ON tp.team_id = t.id
JOIN sport_divisions sd ON t.division_id = sd.id
-- No WHERE clause - gets ALL clubs from ALL leagues
ON CONFLICT (division_id, player_id) DO UPDATE SET ...
```

**Handles:**
- ✅ APSL Lighthouse players
- ✅ CASA Lighthouse players (once scraped)
- ✅ Any other clubs/divisions
- ✅ Duplicates automatically via ON CONFLICT

### **Handle Duplicate Players**

For users who play in multiple leagues:

**Option A: Player Deduplication** (if same person appears twice)
```sql
-- In users table, add league_id NULL to allow cross-league lookups
-- Link via external_identities using GroupMe ID or manual entry
```

**Option B: Division-scoped Players** (current model)
```sql
-- Each division_player is independent
-- User can have multiple player records across divisions
-- external_identities link them to the same user
```

**Current recommendation:** Keep Option B (division-scoped), just ensure all leagues populate correctly

---

## Implementation Checklist

### Phase 1: Rename Files (Safe, Additive) ✅ COMPLETE
- [x] Rename `03-leagues.sql` → `03-leagues-apsl.sql`
- [x] Rename `04-conferences.sql` → `04-conferences-apsl.sql`
- [x] Rename `05-league-divisions.sql` → `05-league-divisions-apsl.sql`
- [x] Rename `06-clubs.sql` → `06-clubs-apsl.sql`
- [x] Rename `07-sport-divisions.sql` → `07-sport-divisions-apsl.sql`
- [x] Update dev.sh/scraper references to new names

### Phase 2: Fix Division Player Population
- [ ] Update `50-populate-division-players.sql` to be generic
- [ ] Test with current APSL Lighthouse
- [ ] Test with CASA data once available

### Phase 3: Add CASA Players When Available
- [ ] Create `24-players-casa.sql` (mirror of `-apsl.sql`)
- [ ] Create `30-rosters-casa.sql` (mirror of `-apsl.sql`)
- [ ] Update dev.sh to scrape/load CASA players

### Phase 4: User Association Improvement
- [ ] Document how to link same user across leagues
- [ ] Add migration helper if needed
- [ ] Create GroupMe sync script for CASA teams

---

## Benefits

✅ **Equal treatment** - APSL and CASA are peers, not APSL + addon
✅ **Extensible** - Easy to add new leagues (TCWL, etc)
✅ **Scalable** - Division population works for all clubs automatically
✅ **Maintainable** - Clearer naming removes confusion
✅ **Deduplication** - ON CONFLICT handles multiple entries naturally

---

## Migration Notes

- This is a **non-breaking change** - just renames and logic fixes
- Database schema doesn't change
- Can be done incrementally
- Good time to do since you're setting up locally for first time

