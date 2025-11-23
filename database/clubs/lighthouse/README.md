# Lighthouse 1893 SC

This directory contains database initialization files for Lighthouse 1893 SC, the first club to use Football Home.

## Structure

1. **01-club-setup.sql** - Creates the Lighthouse club, sport divisions, and main APSL team
2. **02-additional-teams.sql** - Creates additional recreational teams (Boys Club, Old Timers)
3. **03-users.sql** - Creates admin user and assigns roles across all teams

## Teams

- **Lighthouse 1893 SC** (APSL Division 1) - Competitive adult team
- **Lighthouse Boys Club** (Youth recreational)
- **Lighthouse Old Timers Club** (Adult recreational)

## Admin User

- **Email**: jbreslin@footballhome.org
- **Password**: 1893Soccer!
- **Roles**: System Admin, Coach (all teams), Player (all teams)

## Adding to New Installation

These files are loaded automatically in order by the database initialization system:

```bash
# Load order (after schema and seed-data):
database/clubs/lighthouse/01-club-setup.sql
database/clubs/lighthouse/02-additional-teams.sql
database/clubs/lighthouse/03-users.sql
```

## Future Clubs

To add a new club, create a similar directory structure:
```
database/clubs/your-club-name/
├── 01-club-setup.sql       # Club, divisions, primary team
├── 02-additional-teams.sql  # Optional additional teams
├── 03-users.sql            # Admin/coach/player users
└── README.md               # Club-specific documentation
```
