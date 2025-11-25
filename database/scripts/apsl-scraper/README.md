# APSL Data Scraper

Scrapes the American Premier Soccer League (APSL) website for teams, rosters, and player data.

## What It Scrapes

- **Conferences**: Philadelphia, Lancaster, New Jersey, etc.
- **Teams**: All teams in each conference
- **Players**: Full rosters with jersey numbers
- **Clubs**: Organization data
- **Sport Divisions**: League divisions and standings

## Usage

```bash
cd database/scripts/apsl-scraper
node scrape-apsl.js
```

## What It Generates

Updates multiple SQL files in `database/data/`:

- `data/teams/01-teams.sql` - All APSL teams
- `data/rosters/02-rosters.sql` - Player rosters
- `data/players/02-apsl-players.sql` - Player accounts
- `data/clubs/01-clubs.sql` - Club data
- And others...

## Workflow

1. **Run the scraper**:
   ```bash
   cd database/scripts/apsl-scraper
   node scrape-apsl.js
   ```

2. **Review changes**:
   ```bash
   git diff database/data/
   ```

3. **Test locally**:
   ```bash
   ./start.sh
   # Test the app with new data
   ```

4. **Commit if happy**:
   ```bash
   git add database/data/
   git commit -m "Update APSL teams for 2025 season"
   git push
   ```

## Generated Data

### Player Accounts

- **Email**: `firstname.lastname@apsl.player`
- **Password**: `Player[random]!` (e.g., `Playerx7k2m9!`)
- **Status**: Active, must reset password on first login

### UUIDs

IDs are deterministically generated from names for consistency:
- `0001-...` = Leagues
- `0002-...` = Conferences/Divisions
- `0003-...` = Clubs
- `0004-...` = Sport Divisions
- `0005-...` = Teams
- `0006-...` = Users
- `0007-...` = Team Players

## Dependencies

Requires Node.js and jsdom:

```bash
npm install jsdom
```

## Important Notes

- Uses `ON CONFLICT DO UPDATE` - safe to run multiple times
- Website requires User-Agent header (mimics browser)
- Takes ~5-15 minutes to complete full scrape
- Generates ~500KB-2MB of SQL

## Troubleshooting

**"jsdom not found"**
```bash
npm install jsdom
```

**Scraper times out**
- APSL website may be slow
- Run during off-peak hours
- Check your internet connection
