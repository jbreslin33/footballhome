# Automatic Change Tracking System

## Overview

This system **automatically tracks ALL database changes** using database triggers. Every INSERT/UPDATE/DELETE is logged with replay SQL that can be re-applied on rebuild.

**Zero manual effort required** - just make changes in the frontend and they're automatically preserved!

## How It Works

### Automatic Tracking with Database Triggers

1. **Database triggers** installed on all user-editable tables:
   - `users` - Name corrections
   - `team_players` - Roster assignments
   - `division_players` - Registration numbers
   - `practices` - Manual practice entries
   - `practice_attendances` - RSVPs
   - `team_coaches` - Coach assignments
   - `events`, `matches` - Score updates
   - `user_external_identities` - GroupMe linking

2. **Every change automatically creates a log entry**:
   ```sql
   -- Trigger fires on UPDATE
   UPDATE users SET first_name = 'John' WHERE id = '...';
   
   -- Automatically logged to change_log table:
   {
     table_name: 'users',
     operation: 'UPDATE',
     old_values: {"first_name": "Jon", "last_name": "Smith"},
     new_values: {"first_name": "John", "last_name": "Smith"},
     replay_sql: "UPDATE users SET first_name = 'John' WHERE id = '...';"
   }
   ```

3. **Export to SQL file**:
   ```bash
   node scripts/export-audit-log.js
   # Creates database/data/98-audit-replay.sql
   ```

4. **Replay on rebuild**:
   - File loads after scraped data (98-prefix)
   - All your changes automatically re-applied
   - Idempotent (safe to run multiple times)

## File Structure

```
database/data/
├── 00-09: Foundation (schema, core lookups, venues)
│   └── 01-audit-system.sql        [Installs triggers]
├── 10-39: Scraped data (APSL, CASA leagues/teams/players)
├── 40-49: Fix files (merges, corrections)
├── 50-69: Manual seed data (admins, coaches)
├── 70-89: Application-managed (practices from GroupMe)
│   └── 72-APP-practices.sql
└── 98-**:  Audit replay (AUTO-GENERATED)
    └── 98-audit-replay.sql         [Your tracked changes]
```

## What Gets Tracked

All user-editable tables have automatic tracking:

**User Data**:
- First name / last name corrections
- Date of birth updates

**Team Rosters**:
- Jersey numbers
- Position assignments
- Captain/Vice-captain flags
- Roster status (active, practice player, injured, etc.)

**Division Rosters**:
- Registration numbers
- Division status

**Practices & Events**:
- Manual practice entries
- Event details
- RSVP data

**Matches**:
- Score updates
- Match status changes

**Coaches**:
- Team coach assignments
- Coach status

**External Identities**:
- GroupMe user linking

### 3. Workflow

#### ✅ Standard Usage: Export before rebuild

```bash
# Make changes in the frontend throughout the week...

# Before rebuilding, export tracked changes:
./dev.sh --save --apsl --casa --groupme

# This will:
# 1. Export audit log → 98-audit-replay.sql
# 2. Scrape fresh data from APSL/CASA
# 3. Destroy and rebuild database  
# 4. Load: scraped data → then your tracked changes
```

#### Manual Export (without rebuild)

```bash
# Export audit log
node scripts/export-audit-log.js

# Export last 7 days only
node scripts/export-audit-log.js --last 7

# Export since specific date
node scripts/export-audit-log.js --since 2025-12-01
```

#### View What Changed

```bash
# See recent changes in database
docker exec footballhome_db psql -U footballhome_user -d footballhome \\
  -c "SELECT * FROM recent_changes LIMIT 20;"

# See changes by table
docker exec footballhome_db psql -U footballhome_user -d footballhome \\
  -c "SELECT * FROM changes_by_table;"

# Export last 7 days only
node scripts/export-audit-log.js --last 7

# Export since specific date
node scripts/export-audit-log.js --since 2025-12-01
```

### 4. When to Use

**Use `--save` when:**
- You've made ANY changes via the frontend
- You want to scrape fresh data without losing your edits
- You're about to rebuild from scratch

**No need for `--save` when:**
- Database is freshly built (no edits to save)
- You're just viewing data
- You want to test scraped data clean (without your edits)

### 5. Database Triggers

The audit system uses PostgreSQL triggers that fire automatically:

```sql
-- Example: When you update a user
UPDATE users SET first_name = 'John' WHERE id = '...';

-- Trigger automatically logs:
INSERT INTO change_log (
  table_name: 'users',
  operation: 'UPDATE',
  replay_sql: "UPDATE users SET first_name = 'John' WHERE id = '...';"
);
```

**Installed on these tables:**
- `users` - Name corrections
- `team_players` - Roster assignments
- `division_players` - Registration numbers  
- `practices` - Manual practices
- `practice_attendances` - RSVPs
- `team_coaches` - Coach assignments
- `events` - Manual events
- `matches` - Score updates
- `user_external_identities` - GroupMe linking

### 6. Audit Log Queries

1. **Commit 99-manual-roster-edits.sql to Git**
   - This is your "state" file
   - Tracks history of manual changes

**View recent changes:**
```sql
SELECT * FROM recent_changes LIMIT 20;
```

**See statistics by table:**
```sql
SELECT * FROM changes_by_table;
```

**Export specific date range:**
```sql
SELECT * FROM export_changes_sql('2025-12-01'::TIMESTAMPTZ, '2025-12-08'::TIMESTAMPTZ);
```

**See what changed for a specific user:**
```sql
SELECT 
  operation,
  changed_at,
  old_values->>'first_name' as old_name,
  new_values->>'first_name' as new_name,
  replay_sql
FROM change_log
WHERE table_name = 'users' 
  AND record_id = 'user-uuid-here'
ORDER BY changed_at;
```

## Best Practices

1. **Commit the audit replay file to Git**
   - Track history of changes over time
   - Collaborate across computers
   - Review what changed when

2. **Run `--save` before major scraping**
   ```bash
   ./dev.sh --save --apsl --casa --groupme
   ```

3. **Review the generated SQL periodically**
   - Open `database/data/98-audit-replay.sql`
   - Verify changes look correct
   - Remove unwanted changes if needed (just delete those lines)

4. **Clean old audit logs occasionally**
   ```sql
   -- Keep last 90 days (configurable)
   SELECT cleanup_old_audit_logs(90);
   ```

5. **Export filtered ranges for debugging**
   ```bash
   # Just this week's changes
   node scripts/export-audit-log.js --last 7
   ```

## Troubleshooting

**Q: My changes disappeared after rebuild!**
- Did you run with `--save` flag?
- Check if `98-audit-replay.sql` exists and has recent timestamp
- Look at database logs to verify file loaded

**Q: Can I edit the SQL file manually?**
- Yes! That's the benefit of SQL format
- You can review, edit, and commit specific changes
- Just maintain valid SQL syntax

**Q: What about data created in the app (practices, RSVPs)?**
- All tracked automatically by triggers
- No special handling needed
- Just use `--save` before rebuild

**Q: How do I see what will be replayed?**
```bash
# View the audit replay file
cat database/data/98-audit-replay.sql

# Or query the database directly
docker exec footballhome_db psql -U footballhome_user -d footballhome \
  -c "SELECT * FROM recent_changes;"
```

## Example Workflow

```bash
# Day 1: Initial setup
./dev.sh --apsl --casa --groupme

# Days 2-7: Make changes via frontend
# - Fix player names
# - Assign jersey numbers
# - Set captains
# (All automatically tracked!)

# Day 8: APSL posts new standings
./dev.sh --save --apsl --groupme
# ✓ Your changes exported automatically
# ✓ Fresh scraped data loaded
# ✓ Your changes replayed on top

# Day 9: Review what changed
git diff database/data/98-audit-replay.sql

# Commit if you want to keep
git add database/data/98-audit-replay.sql
git commit -m "Updated roster: jersey #10 reassigned to Smith"
git push

# On another computer
git pull
./dev.sh  # Your changes from other computer are applied!
```

## How It's Different from Manual Methods

**Old way (manual snapshot):**
- ❌ Required running script to export
- ❌ Could forget to save before rebuild
- ❌ Captured everything, even temp data
- ❌ No history of when changes happened

**New way (automatic audit log):**
- ✅ Automatic - triggers track everything
- ✅ Timestamped - know when each change happened
- ✅ Selective - can filter by date/table
- ✅ Complete history - see progression of changes
- ✅ Git-friendly - clear diffs of what changed
- ✅ Debuggable - query what changed when

## System Architecture

```
┌─────────────────┐
│   Frontend      │
│  (Make changes) │
└────────┬────────┘
         │ UPDATE/INSERT/DELETE
         ▼
┌─────────────────┐
│   PostgreSQL    │
│   Table Update  │
└────────┬────────┘
         │ Trigger fires
         ▼
┌─────────────────┐
│  change_log     │
│  (Automatic     │
│   logging)      │
└────────┬────────┘
         │
         │ Export with:
         │ node scripts/export-audit-log.js
         ▼
┌─────────────────┐
│ 98-audit-       │
│ replay.sql      │
│ (Commit to git) │
└────────┬────────┘
         │
         │ On rebuild:
         │ ./dev.sh --save --apsl
         ▼
┌─────────────────┐
│ Fresh Database  │
│ + Your Changes  │
│   Preserved!    │
└─────────────────┘
```

## Advanced: Custom Filtering

You can manually filter the audit log before export:

```sql
-- Export only user name changes from last week
COPY (
  SELECT replay_sql 
  FROM change_log 
  WHERE table_name = 'users'
    AND changed_at >= NOW() - INTERVAL '7 days'
  ORDER BY changed_at
) TO '/tmp/user-changes.sql';
```

Or modify the export script for your specific needs (see `scripts/export-audit-log.js`).
