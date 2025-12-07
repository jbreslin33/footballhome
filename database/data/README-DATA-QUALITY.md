# Data Quality Management

This directory contains tools for maintaining data quality across multiple data sources (APSL, CASA, GroupMe).

## Files

### SQL Fix Files (Auto-Applied)
- **ZZ-01-user-merges.sql** - Merge duplicate users from different sources
- **ZZ-02-data-corrections.sql** - Manual corrections for bad data

These files run automatically at the end of every rebuild.

### Analysis Scripts
- **find-duplicates.js** - Detect data quality issues in the database
- Run with: `./dev.sh --find-issues` or `node database/scripts/find-duplicates.js`

### Reports
- **reports/** - Generated reports from find-duplicates.js
- Format: `duplicates-YYYY-MM-DD.txt`

## Workflow

### 1. Normal Rebuild (Fixes Applied Automatically)
```bash
./dev.sh --apsl --casa --groupme
# ZZ-01 and ZZ-02 run automatically at the end
```

### 2. Find New Issues
```bash
./dev.sh --apsl --casa --groupme --find-issues
# Runs full rebuild + generates quality report
# Check: database/reports/duplicates-[date].txt
```

### 3. Add Fixes
Edit `ZZ-01-user-merges.sql` or `ZZ-02-data-corrections.sql`:
```sql
-- Example: Merge duplicate user
WITH 
  correct_user AS (SELECT id FROM users WHERE first_name = 'Mohamed' AND last_name = 'Bility'),
  duplicate_user AS (SELECT id FROM users WHERE last_name LIKE 'Bility%ffe2%')
UPDATE user_external_identities 
SET user_id = (SELECT id FROM correct_user)
WHERE user_id = (SELECT id FROM duplicate_user);

-- Transfer rosters
UPDATE team_players 
SET player_id = (SELECT id FROM correct_user)
WHERE player_id = (SELECT id FROM duplicate_user);

-- Delete duplicate
DELETE FROM users WHERE id = (SELECT id FROM duplicate_user);
```

### 4. Test Fixes
```bash
./dev.sh --apsl --casa --groupme
# Your fixes are applied automatically
# Check the app to verify
```

## Common Issues

### Duplicate Users
- **Cause**: Same person in APSL, CASA, and GroupMe with different names
- **Fix**: Add merge SQL to ZZ-01-user-merges.sql
- **Pattern**: Keep best source (usually APSL), merge external identities

### Corrupted Names
- **Cause**: Encoding issues from GroupMe or web scraping
- **Fix**: Use find-duplicates.js to identify, merge to correct version

### Duplicate Rosters
- **Cause**: Player added to same team multiple times
- **Fix**: Delete duplicates in ZZ-02-data-corrections.sql

### Wrong Data
- **Cause**: Bad scrape data, typos
- **Fix**: UPDATE statements in ZZ-02-data-corrections.sql

## Tips

1. **Run --find-issues after major scrapes** to catch new issues early
2. **Keep ZZ files commented** - document why each fix exists
3. **Test fixes with full rebuilds** - ensure idempotency
4. **Version control ZZ files** - track fixes over time
