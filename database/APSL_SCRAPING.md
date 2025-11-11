# APSL Data Scraping

This directory contains scripts to automatically scrape player rosters from the American Premier Soccer League (APSL) website.

## Files

- **scrape-apsl.js** - Node.js scraper that extracts conferences, teams, and players
- **scrape-apsl.sh** - Bash wrapper with conditional execution logic
- **apsl-data.sql** - Generated SQL file (auto-loaded by init.sql)

## Usage

### Automatic Scraping (Recommended)

Use the `start.sh` script in the root directory:

```bash
# Auto-scrape if data is stale (>24 hours)
./start.sh

# Force fresh scrape
APSL_SCRAPE=true ./start.sh

# Skip scraping entirely
APSL_SCRAPE=false ./start.sh
```

### Manual Scraping

```bash
cd database

# Run scraper with auto-staleness check
./scrape-apsl.sh

# Force scrape regardless of file age
APSL_SCRAPE=true ./scrape-apsl.sh

# Skip scraping
APSL_SCRAPE=false ./scrape-apsl.sh
```

## Environment Variables

| Variable | Values | Behavior |
|----------|--------|----------|
| `APSL_SCRAPE` | `true` | Force fresh scrape on every rebuild |
| `APSL_SCRAPE` | `false` | Skip scraping, use existing `apsl-data.sql` |
| `APSL_SCRAPE` | *(not set)* | Auto-scrape if file is >24 hours old |

## How It Works

### 1. Scraping Process

The scraper (`scrape-apsl.js`):
- Fetches standings from `https://apslsoccer.com/standings/`
- Parses conferences and divisions
- Extracts team names and URLs
- Visits each team page to scrape player rosters
- Generates SQL INSERT statements with ON CONFLICT clauses

### 2. Data Structure

Scraped data includes:

```
League (APSL)
  └─ Conferences (e.g., Philadelphia, Lancaster, New Jersey)
      └─ Divisions (e.g., Premier, Division 1, Over 30)
          └─ Teams (e.g., Lighthouse 1893 SC)
              └─ Players (with jersey numbers and positions)
```

### 3. Database Loading

On rebuild with `docker compose down -v && docker compose up -d`:
1. `start.sh` runs `scrape-apsl.sh` (if needed)
2. PostgreSQL loads `/docker-entrypoint-initdb.d/01-init.sql` (schema)
3. PostgreSQL loads `/docker-entrypoint-initdb.d/02-apsl-data.sql` (data)

## Generated Data

### Player Accounts

- **Email format**: `firstname.lastname@apsl.player`
- **Password format**: `Player[random]!` (e.g., `Playerx7k2m9!`)
- **Type**: Regular users extended as players
- **Status**: Active, should reset password on first login

Example:
```sql
INSERT INTO users (id, email, name, password_hash, is_active)
VALUES (
  '00000000-0000-0000-0006-abc123...',
  'john.doe@apsl.player',
  'John Doe',
  crypt('Playerx7k2m9!', gen_salt('bf')),
  true
);
```

### UUIDs

All IDs are deterministically generated from names:
- `0001-...` = Leagues
- `0002-...` = Conferences/Divisions
- `0003-...` = Clubs
- `0004-...` = Sport Divisions
- `0005-...` = Teams
- `0006-...` = Users
- `0007-...` = Team Players

This ensures consistent IDs across scrapes (idempotent).

## Duplicate Detection

The scraper uses `ON CONFLICT DO UPDATE` clauses:

```sql
INSERT INTO teams (id, name, division_id, ...)
VALUES (...)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  updated_at = CURRENT_TIMESTAMP;
```

This means:
- ✅ Safe to run multiple times
- ✅ Updates existing records
- ✅ Preserves relationships (FKs)
- ✅ No duplicate teams/players

## Dependencies

Requires Node.js and jsdom:

```bash
npm install jsdom
```

The scraper automatically installs jsdom if missing.

## Customization

### Scrape Specific Conferences

Edit `scrape-apsl.js` and filter conferences:

```javascript
for (const confElement of conferenceElements) {
  const confName = confElement.querySelector('h2, h3')?.textContent.trim();
  
  // Only scrape Philadelphia conference
  if (!confName.includes('Philadelphia')) continue;
  
  // ... rest of scraping logic
}
```

### Adjust Staleness Threshold

Edit `scrape-apsl.sh`:

```bash
STALE_HOURS=48  # Change from 24 to 48 hours
```

### Change Output Location

Edit `scrape-apsl.sh`:

```bash
OUTPUT_FILE="$SCRIPT_DIR/custom-apsl-data.sql"
```

Then update `docker-compose.yml` volumes accordingly.

## Troubleshooting

### Scraper fails with "jsdom not found"

```bash
cd database
npm install jsdom
```

### apsl-data.sql not loading

Check file is mounted in `docker-compose.yml`:

```yaml
volumes:
  - ./database/init.sql:/docker-entrypoint-initdb.d/01-init.sql:ro
  - ./database/apsl-data.sql:/docker-entrypoint-initdb.d/02-apsl-data.sql:ro
```

### Database has no players after rebuild

1. Check if scraper ran: `ls -lh database/apsl-data.sql`
2. Force scrape: `APSL_SCRAPE=true ./start.sh`
3. Check logs: `docker logs footballhome_db`

### Scraper times out

APSL website may be slow. Increase timeout in `scrape-apsl.js` or run during off-peak hours.

## Performance

- **Scrape time**: ~5-15 minutes (depends on number of teams/players)
- **Generated SQL size**: ~500KB-2MB
- **Database load time**: ~5-10 seconds

## Future Enhancements

- [ ] Scrape match schedules and results
- [ ] Extract player photos/avatars
- [ ] Parse player statistics (goals, assists, cards)
- [ ] Scrape coach information
- [ ] Add team logos and colors
- [ ] Historical roster tracking (transfers)

## License

Same as parent project.
