# Database Data File Organization

## File Naming Convention

All SQL files use a numeric prefix to control load order. Files are loaded alphabetically by PostgreSQL's `docker-entrypoint-initdb.d`.

### Numbering Scheme

```
00-09   Foundation (schema, lookups, venues)
10-39   Scraped Data (APSL, CASA)
40-49   Fixes (deduplication, data corrections)
50-69   Manual/Static (admins, coaches)
70-89   App-Managed (runtime user data)
```

## Complete File List

### Foundation (00-09)
```
00-schema.sql                 # Tables, constraints, indexes, triggers
01-core-lookups.sql           # Sports, attendance types, static lookups
02-venues.sql                 # Venue/field data
```

### Scraped Data (10-39)

**APSL League Structure (10-14)**
```
10-leagues.sql                # APSL leagues (scraped)
10-leagues.copy.sql           # Backup when --apsl not used
11-conferences.sql            # APSL conferences (scraped)
11-conferences.copy.sql
12-league-divisions.sql       # APSL divisions (scraped)
12-league-divisions.copy.sql
13-clubs.sql                  # APSL clubs (scraped)
13-clubs.copy.sql
14-sport-divisions.sql        # APSL sport divisions (scraped)
14-sport-divisions.copy.sql
```

**APSL Users & Teams (20-24)**
```
20-users-apsl.sql             # APSL users/players (scraped)
20-users-apsl.copy.sql
22-teams-apsl.sql             # APSL teams (scraped)
22-teams-apsl.copy.sql
24-players-apsl.sql           # APSL player records (scraped)
24-players-apsl.copy.sql
```

**CASA Users & Teams (21, 23)**
```
21-users-casa.sql             # CASA users from Google Sheets (scraped)
23-teams-casa.sql             # CASA teams (static - references Lighthouse club)
```

**Rosters (30-31)**
```
30-rosters-apsl.sql           # APSL team rosters (scraped)
30-rosters-apsl.copy.sql
31-rosters-casa.sql           # CASA team rosters (scraped)
```

### Fixes (40-49)
```
40-FIX-user-merges.sql        # Deduplicate users from different sources
41-FIX-data-corrections.sql   # Fix bad data from scrapes
```

**Purpose**: Clean up scraped data before manual/app data loads. Protects your curated data from being accidentally modified.

### Manual/Static (50-69)
```
50-users-manual.sql           # Hand-created users
51-admins.sql                 # Admin role assignments
52-coaches.sql                # Coach records
53-team-coaches.sql           # Coach-team assignments
```

**Purpose**: Data you manually maintain that should never be touched by scrapers or fixes.

### App-Managed (70-89)
```
70-APP-users.sql              # Users created via web app
71-APP-rosters.sql            # Roster changes made via app
72-APP-practices.sql          # Practices created via app
```

**Purpose**: Persist app-created data across rebuilds. Edit these files to add data created during app usage.

## Load Order Example

```bash
./dev.sh --apsl --casa --groupme
```

1. **00-02**: Schema, lookups, venues
2. **10-14**: APSL league structure (scraped)
3. **20-24**: APSL users, teams, players (scraped)
4. **21**: CASA users (scraped)
5. **23**: CASA teams (static)
6. **30-31**: Rosters (scraped)
7. **40-41**: Fixes run (clean scraped data)
8. **50-53**: Manual data loads (protected)
9. **70-72**: App data loads (protected)
10. **GroupMe scripts**: Import practices/RSVPs

## Scraper Flags

### `--apsl`
Generates:
- `10-leagues.sql`
- `11-conferences.sql`
- `12-league-divisions.sql`
- `13-clubs.sql`
- `14-sport-divisions.sql`
- `20-users-apsl.sql`
- `22-teams-apsl.sql`
- `24-players-apsl.sql`
- `30-rosters-apsl.sql`

Creates `.copy.sql` backups for each file.

### `--casa`
Generates:
- `21-users-casa.sql`
- `31-rosters-casa.sql`

Note: `23-teams-casa.sql` is static (not scraped).

### No scraper flags
Uses `.copy.sql` files from previous scrape.

## Workflow

### Normal Development
```bash
./dev.sh --apsl --casa --groupme
# All data loads, fixes run, app ready to use
```

### Adding App-Created Data
1. Use app to create user/roster/practice
2. Edit corresponding `70-APP-*.sql` file
3. Add INSERT statement
4. Rebuild to test
5. Commit when working

Example:
```sql
-- 70-APP-users.sql
INSERT INTO users (id, first_name, last_name, email, is_active)
VALUES (
  'uuid-here',
  'John',
  'Doe',
  'john@example.com',
  true
) ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name;
```

### Finding Data Issues
```bash
./dev.sh --apsl --casa --groupme --find-issues
# Generates: database/reports/duplicates-[date].txt
```

### Fixing Data Issues
1. Review issues report
2. Edit `40-FIX-user-merges.sql` or `41-FIX-data-corrections.sql`
3. Add fix SQL
4. Rebuild to test
5. Commit when working

## Key Principles

1. **Scraped data is ephemeral** - regenerated on each scrape
2. **Fixes run after scrapes** - clean up scraped data only
3. **Manual data is protected** - loads after fixes
4. **App data is protected** - loads last, survives rebuilds
5. **Version control everything** - all files committed to git

## File Naming Rules

- Use numeric prefix for load order
- Use descriptive suffix: `-apsl`, `-casa`, `-manual`
- Use `.copy.sql` for scraper backups
- Use `APP-` prefix for app-managed files (70-89)
- Use `FIX-` prefix for fix files (40-49)
