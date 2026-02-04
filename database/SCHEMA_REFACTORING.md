# Schema Refactoring - Competition-Centric Team Model

## Status: IN PROGRESS

## Overview
Refactored database schema to make teams competition-specific entities bound to divisions, eliminating the division_teams junction table.

## Philosophy Change
**Before**: Teams were persistent entities that registered in multiple divisions over time  
**After**: Teams ARE competition entries - same club in different competitions = different team records

### Real-world Example:
```
OLD MODEL:
- Team: "Lighthouse Boys Club" (persistent, id=42)
- Division Registrations: CASA Liga 1 (division_teams entry), PA State Cup (division_teams entry)
- Same roster for all competitions

NEW MODEL:
- Team 1: "Lighthouse Boys Club", division_id=55 (CASA Liga 1)
- Team 2: "Lighthouse Boys Club", division_id=89 (PA State Cup)
- Different rosters, different jersey numbers, independent standings
```

## Schema Changes Completed ✅

### 1. teams table
- **Added**: `division_id INTEGER NOT NULL REFERENCES divisions(id)`
- **Changed**: UNIQUE constraint from `(source_system_id, name)` to `(division_id, name)`
- **Removed**: Partial unique index `idx_teams_club_name_source_unique`
- **Added**: Index on `division_id`
- **Rationale**: Team identity is now bound to competition context

### 2. Removed Tables
- ❌ `division_teams` - No longer needed (division_id now in teams table)
- ❌ `division_team_external_ids` - No longer needed
- ❌ `division_team_players` - Replaced by `rosters`
- ❌ `division_team_player_external_ids` - Not needed in new model
- ❌ `division_team_player_positions` - Replaced by `roster_positions`
- ❌ `division_team_coaches` - Replaced by `team_coaches`

### 3. New Tables

#### rosters
```sql
CREATE TABLE rosters (
    id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL REFERENCES teams(id),
    player_id INTEGER NOT NULL REFERENCES players(id),
    jersey_number VARCHAR(10),
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,  -- NULL = currently on roster
    UNIQUE (team_id, player_id, joined_at)
);
```
- Simpler than division_team_players
- Direct team → player relationship
- Temporal tracking for transfers

#### roster_positions
```sql
CREATE TABLE roster_positions (
    id SERIAL PRIMARY KEY,
    roster_id INTEGER NOT NULL REFERENCES rosters(id),
    position_id INTEGER NOT NULL REFERENCES positions(id),
    is_primary BOOLEAN DEFAULT false,
    ...
);
```
- Replaces division_team_player_positions
- Tracks what position player plays for THIS team

#### team_coaches
```sql
CREATE TABLE team_coaches (
    team_id INTEGER NOT NULL REFERENCES teams(id),
    coach_id INTEGER NOT NULL REFERENCES coaches(id),
    coach_role_id INTEGER REFERENCES coach_roles(id),
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    ...
);
```
- Replaces division_team_coaches
- Simpler direct relationship

### 4. Simplified Tables

#### standings
- **Removed**: `competition_id`, `season_id` columns
- **Changed**: UNIQUE constraint from `(competition_id, season_id, team_id)` to `(team_id)`
- **Rationale**: Division/season implied via `team.division_id → division.season_id`

#### standings_snapshots
- **Removed**: `competition_id`, `season_id` columns
- **Rationale**: Same as standings - hierarchy implied via FK chain

## Data Migration Required ⚠️

### Bootstrap Data Files (database/data/)

#### ❌ DELETE (will be regenerated):
- `042a-teams-apsl-csl.sql` - Teams without division_id
- `042b-teams-casa.sql` - Teams without division_id
- `045-division-teams.sql` - Junction table no longer exists
- `046-division-team-players.sql` - Replaced by rosters

#### ✏️ UPDATE:
- `050-standings.sql` - Change to new simplified structure
- `051-matches.sql` - No changes needed (uses team_id)
- Any views/functions referencing old tables

### Generated SQL Files (database/scripts/leagues/*/sql/)

#### Files to Regenerate:
- `10x-teams-*.sql` - Must include division_id lookups
- `103-division-teams-*.sql` - DELETE (table no longer exists)
- `104-standings-*.sql` - Use new simplified structure
- `105-players-*.sql` - May need updates for rosters table

## Code Changes Required 🚧

### 1. SQL Generators (HIGH PRIORITY)

#### usa-casa/generate-sql.js
- ✏️ **writeTeamsSql()**: Add division_id lookup by divisionName
- ❌ **writeDivisionTeamsSql()**: DELETE (table removed)
- ✏️ **writeStandingsSql()**: Use new simplified structure (team_id only)
- ✏️ **writePlayersSql()**: Update to use rosters table

#### usa-apsl/generate-sql.js
- Same changes as CASA

#### usa-csl/generate-sql.js  
- Same changes as CASA

#### BaseGenerator.js (if common methods exist)
- ✏️ Update writeStandingsSql() - remove hardcoded team IDs, use dynamic lookups
- ❌ Remove writeDivisionTeamsSql()

### 2. SQL Curators

#### usa-casa/curate-sql.js
- ✏️ Update team INSERT statements to include division_id
- ❌ Remove division_teams handling
- ✏️ Update roster handling for new rosters table

#### usa-apsl/curate-sql.js
- Same changes as CASA

#### usa-csl/curate-sql.js
- Same changes as CASA

### 3. Parser Code

#### parse-casa-standings.js
- ✅ Already outputs division context in standings-data.json
- May need minor updates for new team structure

#### Other parsers
- Review all parsers that reference division_teams

### 4. Application Code (Backend)

#### C++ Controllers/Models
- ✏️ Update queries joining division_teams → use teams.division_id instead
- ✏️ Update roster queries to use new rosters table
- ✏️ Update standings queries (simplified - no more season_id/competition_id joins)

### 5. Frontend Code

#### JavaScript Screens
- ✏️ Update any UI code displaying team/division relationships
- ✏️ Update roster displays
- ✏️ Update standings displays

## Implementation Steps

### Phase 1: Schema (✅ COMPLETED)
1. ✅ Update 00-schema.sql with all table changes
2. ✅ Test schema loads without errors

### Phase 2: Generator Updates (🚧 IN PROGRESS)
3. ⏳ Update BaseGenerator.writeStandingsSql() - remove hardcoded IDs
4. ⏳ Update usa-casa/generate-sql.js - teams with division_id
5. ⏳ Update usa-apsl/generate-sql.js - teams with division_id
6. ⏳ Update usa-csl/generate-sql.js - teams with division_id
7. ⏳ Update all curate-sql.js files

### Phase 3: Data Regeneration (⏳ PENDING)
8. ⏳ Delete old bootstrap files (042a, 042b, 045, 046)
9. ⏳ Run APSL parser/generator
10. ⏳ Run CSL parser/generator
11. ⏳ Run CASA parser/generator
12. ⏳ Curate all league data

### Phase 4: Database Rebuild (⏳ PENDING)
13. ⏳ Run `./build.sh` - fresh database with new schema
14. ⏳ Verify all data loads correctly
15. ⏳ Check standings populate correctly (fix zero-records issue)

### Phase 5: Application Updates (⏳ PENDING)
16. ⏳ Update backend C++ queries
17. ⏳ Update frontend JavaScript
18. ⏳ Test full app functionality

## Benefits of New Design

### 1. Simpler Queries
```sql
-- OLD: Get team's division
SELECT d.* FROM divisions d
JOIN division_teams dt ON dt.division_id = d.id
WHERE dt.team_id = 42 AND dt.unregistered_at IS NULL;

-- NEW: Get team's division
SELECT d.* FROM divisions d
JOIN teams t ON t.division_id = d.id
WHERE t.id = 42;
```

### 2. Simpler Standings
```sql
-- OLD: Insert standing
INSERT INTO standings (competition_id, season_id, team_id, ...)
SELECT d.id, s.id, 42, ...
FROM divisions d JOIN seasons s ...;

-- NEW: Insert standing
INSERT INTO standings (team_id, ...)
VALUES (42, ...);
```

### 3. Correct Competition Semantics
- Each team record = one competition registration
- Different rosters per competition (realistic!)
- Independent jersey numbers per competition
- Clearer data model matches real-world usage

### 4. Eliminates Confusion
- No more "is this team a duplicate?"
- No more temporal gymnastics with division_teams
- Team identity is explicit and bound to competition

## Risks & Mitigations

### Risk 1: Data Loss
- **Mitigation**: Keep old SQL files in git history
- **Recovery**: `git checkout 4e50246^ -- database/data/042*.sql` if needed

### Risk 2: Missing Team Associations
- **Mitigation**: Thorough testing after regeneration
- **Recovery**: Re-run parsers/generators with fixes

### Risk 3: Application Breakage
- **Mitigation**: Update all query code before deploying
- **Recovery**: Rollback to previous commit, fix issues incrementally

## Testing Checklist

- [ ] Schema loads without errors (`./build.sh`)
- [ ] APSL teams load with division_id
- [ ] CSL teams load with division_id
- [ ] CASA teams load with division_id
- [ ] Standings populate (fix zero-records bug)
- [ ] Rosters populate correctly
- [ ] Team coaches populate correctly
- [ ] Queries return expected results
- [ ] Frontend displays correct data
- [ ] No foreign key violations

## Rollback Plan

If major issues arise:
```bash
git revert HEAD  # Revert schema changes
./build.sh       # Rebuild with old schema
```

## Questions & Decisions

### Q: What about promotion/relegation history?
**A**: If needed, create a separate `team_division_history` table. But initially, each competition entry is independent.

### Q: Can same club have identically-named teams in same division?
**A**: No - UNIQUE constraint `(division_id, name)` prevents this.

### Q: How to query all teams for a club across divisions?
**A**: `SELECT * FROM teams WHERE club_id = X;` - works same as before!

### Q: What if team transfers mid-season?
**A**: Use `rosters.left_at` and create new roster entry - roster table handles transfers.

## Completion Criteria

Refactoring complete when:
1. ✅ Schema updated and loads cleanly
2. ⏳ All generators produce new SQL format
3. ⏳ All bootstrap data regenerated
4. ⏳ Database builds and populates fully
5. ⏳ Standings show > 0 records for all leagues
6. ⏳ Application queries work correctly
7. ⏳ No errors in application logs
8. ⏳ Frontend displays all data correctly

---

**Last Updated**: 2026-02-02  
**Status**: Phase 1 complete, Phase 2 in progress
