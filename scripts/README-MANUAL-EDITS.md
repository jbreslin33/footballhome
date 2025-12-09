# Manual Edits Preservation System

## Overview

This system preserves manual data changes (made via the frontend) across database rebuilds by exporting them to SQL files that get replayed during initialization.

## How It Works

### 1. File Structure (Numbered Ranges)

```
database/data/
├── 00-09: Foundation (schema, core lookups, venues)
├── 10-39: Scraped data (APSL, CASA leagues/teams/players)
├── 40-49: Fix files (merges, corrections)
├── 50-69: Manual seed data (admins, coaches)
├── 70-89: Application-managed (user edits, practices)
│   ├── 70-APP-users.sql        [Created by save script]
│   ├── 71-APP-rosters.sql      [Created by save script]
│   ├── 72-APP-practices.sql    [Manual/GroupMe]
│   └── 99-manual-roster-edits.sql  [Full snapshot]
└── ZZ-*: Post-init scripts (pg_cron setup)
```

### 2. What Gets Preserved

**User Names** (`70-APP-users.sql`):
- First name / Last name corrections
- Applied to all users who are on rosters

**Team Rosters** (`71-APP-rosters.sql`):
- Jersey numbers
- Position assignments
- Captain/Vice-captain flags
- Roster status (active, practice player, injured, etc.)

**Division Rosters** (in `71-APP-rosters.sql`):
- Registration numbers
- Division status

**Practices** (`72-APP-practices.sql`):
- Manual practice entries
- GroupMe synced events
- RSVP data

### 3. Workflow

#### Option A: Manual Save (Recommended)

```bash
# Before making changes that could be lost
node scripts/save-manual-edits.js

# This creates/updates:
# - database/data/99-manual-roster-edits.sql (complete snapshot)
```

#### Option B: Automatic Save on Rebuild

```bash
# Save current edits, then rebuild with fresh scraped data
./dev.sh --save --apsl --casa --groupme

# This will:
# 1. Connect to running database
# 2. Export all manual edits to 99-manual-roster-edits.sql
# 3. Scrape fresh data from APSL/CASA
# 4. Destroy and rebuild database
# 5. Load: scraped data → then your manual edits
```

#### Option C: Just Save (No Rebuild)

```bash
# Save current state without rebuilding
./dev.sh --save
```

### 4. When to Use

**Use `--save` when:**
- You've fixed player name typos in the frontend
- You've assigned jersey numbers
- You've set captains/vice-captains
- You've updated roster status (active/injured/etc.)
- You've added registration numbers
- You want to preserve all manual work before scraping new data

**Skip `--save` when:**
- Database is freshly built (no edits to save)
- You haven't made any manual changes
- You want to test scraped data without overlays

### 5. Save Script Details

**What it captures:**
```javascript
// From live database → SQL file
UPDATE users SET first_name = 'John', last_name = 'Smith' WHERE id = '...';

INSERT INTO team_players (...) VALUES (...)
ON CONFLICT (team_id, player_id) DO UPDATE SET
    jersey_number = EXCLUDED.jersey_number,
    is_captain = EXCLUDED.is_captain,
    ...;

INSERT INTO division_players (...) VALUES (...)
ON CONFLICT (division_id, player_id) DO UPDATE SET
    registration_number = EXCLUDED.registration_number,
    ...;
```

**Output file:** `database/data/99-manual-roster-edits.sql`

- Uses prefix `99-` to load last (after all scraped data)
- Contains ON CONFLICT clauses to overlay changes
- Idempotent (safe to run multiple times)
- Human-readable for review/manual edits

### 6. Database Triggers (Future Enhancement)

For real-time change tracking, you could add triggers:

```sql
-- Audit table for all changes
CREATE TABLE change_log (
    id SERIAL PRIMARY KEY,
    table_name TEXT,
    record_id UUID,
    operation TEXT,
    old_values JSONB,
    new_values JSONB,
    changed_by UUID,
    changed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    sql_replay TEXT  -- Generated UPDATE/INSERT statement
);

-- Example trigger on users table
CREATE TRIGGER users_audit_trigger
AFTER UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION log_change_with_replay_sql();
```

This would automatically generate replay SQL as you make changes via the app.

## Best Practices

1. **Commit 99-manual-roster-edits.sql to Git**
   - This is your "state" file
   - Tracks history of manual changes
   - Allows team collaboration

2. **Run `--save` before major scraping**
   ```bash
   ./dev.sh --save --apsl --casa --groupme
   ```

3. **Review the generated SQL**
   - Open `database/data/99-manual-roster-edits.sql`
   - Verify changes look correct
   - Add comments if needed

4. **Keep separate manual files for different concerns**
   - `70-APP-users.sql` - Permanent name corrections
   - `71-APP-rosters.sql` - Roster assignments
   - `99-manual-roster-edits.sql` - Full snapshot/backup

5. **Test after rebuild**
   ```bash
   # Verify your manual edits persisted
   docker exec footballhome_db psql -U footballhome_user -d footballhome \
     -c "SELECT first_name, last_name, jersey_number 
         FROM users u 
         JOIN team_players tp ON u.id = tp.player_id 
         WHERE u.last_name = 'Smith';"
   ```

## Troubleshooting

**Q: My changes disappeared after rebuild!**
- Did you run with `--save` flag?
- Check if `99-manual-roster-edits.sql` exists and has recent timestamp
- Look at git diff to see if file changed

**Q: Should I edit the SQL files manually?**
- Yes! That's the benefit of SQL format
- You can review, edit, and commit specific changes
- Just maintain the ON CONFLICT structure for idempotency

**Q: What about data created in the app (practices, RSVPs)?**
- Practices are in `72-APP-practices.sql`
- This file is managed by GroupMe import or manual creation
- Save script captures them in the snapshot

**Q: Can I have both manual files and snapshot?**
- Yes! Load order: `70-APP-*.sql` then `99-manual-*.sql`
- The `99-` file is the complete state
- The `70-` files are curated permanent edits
- Snapshot will overlay any duplicates (last write wins)

## Example Workflow

```bash
# Day 1: Initial setup
./dev.sh --apsl --casa --groupme

# Day 2-7: Make manual edits via frontend
# - Fix player names
# - Assign jersey numbers
# - Set captains

# Day 8: APSL posts new standings
./dev.sh --save --apsl --groupme
# Your manual edits preserved!
# Fresh scraped data loaded
# Manual edits applied on top

# Day 9: Review what changed
git diff database/data/99-manual-roster-edits.sql

# Commit if you want to keep
git add database/data/99-manual-roster-edits.sql
git commit -m "Updated roster: jersey #10 reassigned to Smith"
```

## Future Enhancements

1. **Selective save** - Only save specific teams/divisions
2. **Diff viewer** - Show what changed since last save
3. **Conflict detection** - Warn if scraped data conflicts with manual edits
4. **Web UI** - Button in admin panel to trigger save
5. **Automatic scheduling** - Cron job to save nightly
6. **Restore from backup** - `./dev.sh --restore 2025-12-07-snapshot.sql`
