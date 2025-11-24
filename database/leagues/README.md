## League Data Organization

This directory contains league data separated by league and data type.

### Structure

```
leagues/
  apsl/
    01-league-structure.sql  - APSL leagues, conferences, divisions, clubs, teams (NO players)
    02-player-rosters.sql    - All APSL player rosters
    scrape-apsl.js          - Scraper to generate above files
    scrape-apsl.sh          - Shell script to run scraper
  
  casa/
    01-league-structure.sql  - CASA Select league structure
    02-player-rosters.sql    - CASA Select player rosters
```

### Loading Order

Files are loaded by PostgreSQL in alphabetical/numerical order via docker-entrypoint-initdb.d/:

1. **01-create-tables.sql** - Database schema
2. **02-core-lookups.sql** - Sports, positions, statuses
3. **03-venues.sql** - Venue data
4. **04-lighthouse-club.sql** - Lighthouse club entity
5. **10-apsl-league.sql** - APSL league structure
6. **11-casa-league.sql** - CASA league structure  
7. **20-apsl-players.sql** - APSL player rosters
8. **21-casa-players.sql** - CASA player rosters
9. **30-lighthouse-teams.sql** - Additional Lighthouse teams
10. **31-lighthouse-users.sql** - User assignments

### Philosophy

**Separation of Concerns:**
- **League structure** = Organizational hierarchy (leagues → conferences → divisions → clubs → teams)
- **Player rosters** = Individual players and their team assignments

**Benefits:**
1. **Maintainability** - Easy to update structure without touching player data
2. **Performance** - Can skip player loading for testing
3. **Clarity** - Clear what data comes from where
4. **Scalability** - Easy to add new leagues (e.g., CASA, NPSL, etc.)

### Adding a New League

1. Create directory: `leagues/your-league/`
2. Create `01-league-structure.sql` with league hierarchy
3. Create `02-player-rosters.sql` with player data
4. Add to `docker-compose.override.yml` volumes
5. Rebuild: `./start.sh`

### APSL Scraper

The APSL scraper needs to be updated to generate TWO separate files:
- `01-league-structure.sql` - Structure only
- `02-player-rosters.sql` - Players only

Currently, `apsl-data.sql` contains both mixed together.

**TODO**: Update `scrape-apsl.js` to separate output into structure vs players.
