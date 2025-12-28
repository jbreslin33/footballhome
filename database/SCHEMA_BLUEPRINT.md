# FootballHome Database Schema Blueprint
**Date**: December 27, 2025
**Status**: Architecture Design - Ready for Implementation

## Core Principles
1. **League systems own their data** (APSL, CASA, Custom) - source of truth
2. **No duplication** - teams/players exist in exactly one league system
3. **Proper normalization** - separate junction tables, no nullable FKs with discriminators
4. **Historical data preserved** - never delete, only soft-delete via status flags
5. **Clubs link to league data** - don't own it, reference it

---

## Layer 1: League Systems (Self-Contained, Equal Peers)

### APSL League System
```sql
CREATE TABLE apsl_leagues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR NOT NULL,
    apsl_league_id VARCHAR,
    season VARCHAR,
    website VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE apsl_divisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apsl_league_id UUID REFERENCES apsl_leagues(id),
    name VARCHAR NOT NULL,
    apsl_division_id VARCHAR,
    level INTEGER,
    season VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE apsl_teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apsl_division_id UUID REFERENCES apsl_divisions(id),
    name VARCHAR NOT NULL,
    apsl_team_id VARCHAR,
    season VARCHAR,
    logo_url VARCHAR,
    website VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE apsl_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR NOT NULL,
    apsl_player_id VARCHAR,
    position VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE apsl_team_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apsl_team_id UUID REFERENCES apsl_teams(id) ON DELETE CASCADE,
    apsl_player_id UUID REFERENCES apsl_players(id) ON DELETE CASCADE,
    jersey_number INTEGER,
    season VARCHAR,
    position VARCHAR,
    is_starter BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(apsl_team_id, apsl_player_id, season)
);

CREATE TABLE apsl_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apsl_division_id UUID REFERENCES apsl_divisions(id),
    home_team_id UUID REFERENCES apsl_teams(id),
    away_team_id UUID REFERENCES apsl_teams(id),
    match_date TIMESTAMP,
    venue VARCHAR,
    home_score INTEGER,
    away_score INTEGER,
    status VARCHAR,
    apsl_match_id VARCHAR,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE apsl_player_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apsl_player_id UUID REFERENCES apsl_players(id),
    apsl_team_id UUID REFERENCES apsl_teams(id),
    apsl_division_id UUID REFERENCES apsl_divisions(id),
    season VARCHAR,
    games_played INTEGER DEFAULT 0,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(apsl_player_id, apsl_team_id, season)
);

CREATE TABLE apsl_team_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apsl_team_id UUID REFERENCES apsl_teams(id),
    apsl_division_id UUID REFERENCES apsl_divisions(id),
    season VARCHAR,
    games_played INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    draws INTEGER DEFAULT 0,
    goals_for INTEGER DEFAULT 0,
    goals_against INTEGER DEFAULT 0,
    points INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(apsl_team_id, season)
);
```

### CASA League System (Mirror of APSL)
```sql
CREATE TABLE casa_leagues (...); -- Same structure as apsl_leagues
CREATE TABLE casa_divisions (...); -- Same structure as apsl_divisions
CREATE TABLE casa_teams (...); -- Same structure as apsl_teams
CREATE TABLE casa_players (...); -- Same structure as apsl_players
CREATE TABLE casa_team_players (...); -- Same structure as apsl_team_players
CREATE TABLE casa_matches (...); -- Same structure as apsl_matches
CREATE TABLE casa_player_stats (...); -- Same structure as apsl_player_stats
CREATE TABLE casa_team_stats (...); -- Same structure as apsl_team_stats
```

### Custom League System (Club-Created)
```sql
CREATE TABLE custom_leagues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    club_id UUID REFERENCES clubs(id),
    name VARCHAR NOT NULL,
    season VARCHAR,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE custom_divisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    custom_league_id UUID REFERENCES custom_leagues(id),
    name VARCHAR NOT NULL,
    level INTEGER,
    season VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE custom_teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    custom_division_id UUID REFERENCES custom_divisions(id),
    name VARCHAR NOT NULL,
    season VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE custom_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR NOT NULL,
    position VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE custom_team_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    custom_team_id UUID REFERENCES custom_teams(id) ON DELETE CASCADE,
    custom_player_id UUID REFERENCES custom_players(id) ON DELETE CASCADE,
    jersey_number INTEGER,
    season VARCHAR,
    position VARCHAR,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(custom_team_id, custom_player_id, season)
);

CREATE TABLE custom_matches (...); -- Same structure as apsl_matches
CREATE TABLE custom_player_stats (...); -- Same structure as apsl_player_stats
CREATE TABLE custom_team_stats (...); -- Same structure as apsl_team_stats
```

---

## Layer 2: FootballHome Identity Layer

### Users & Players
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR UNIQUE NOT NULL,
    password_hash VARCHAR NOT NULL,
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),  -- Optional: players can exist without users
    first_name VARCHAR NOT NULL,
    last_name VARCHAR NOT NULL,
    display_name VARCHAR,
    date_of_birth DATE,
    phone VARCHAR,
    email VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Junction: Link players to league-specific profiles
CREATE TABLE players_apsl_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    apsl_player_id UUID REFERENCES apsl_players(id) ON DELETE CASCADE,
    verified BOOLEAN DEFAULT false,
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(player_id, apsl_player_id)
);

CREATE TABLE players_casa_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    casa_player_id UUID REFERENCES casa_players(id) ON DELETE CASCADE,
    verified BOOLEAN DEFAULT false,
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(player_id, casa_player_id)
);

CREATE TABLE players_custom_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    custom_player_id UUID REFERENCES custom_players(id) ON DELETE CASCADE,
    verified BOOLEAN DEFAULT false,
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(player_id, custom_player_id)
);
```

---

## Layer 3: Club Management Layer

### Clubs & Sport Divisions
```sql
CREATE TABLE clubs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    display_name VARCHAR NOT NULL,
    slug VARCHAR UNIQUE NOT NULL,
    description TEXT,
    logo_url VARCHAR,
    website VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE sports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR UNIQUE NOT NULL,
    display_name VARCHAR NOT NULL,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE sport_divisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    sport_id UUID REFERENCES sports(id),
    display_name VARCHAR NOT NULL,  -- "1893 SC Soccer", "Boys Club", "Old Timers"
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Junction: Link sport divisions to teams in league systems
CREATE TABLE sport_division_apsl_teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sport_division_id UUID REFERENCES sport_divisions(id) ON DELETE CASCADE,
    apsl_team_id UUID REFERENCES apsl_teams(id) ON DELETE CASCADE,
    season VARCHAR,
    is_active BOOLEAN DEFAULT true,
    claimed_by UUID REFERENCES users(id),
    claimed_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(sport_division_id, apsl_team_id, season)
);

CREATE TABLE sport_division_casa_teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sport_division_id UUID REFERENCES sport_divisions(id) ON DELETE CASCADE,
    casa_team_id UUID REFERENCES casa_teams(id) ON DELETE CASCADE,
    season VARCHAR,
    is_active BOOLEAN DEFAULT true,
    claimed_by UUID REFERENCES users(id),
    claimed_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(sport_division_id, casa_team_id, season)
);

CREATE TABLE sport_division_custom_teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sport_division_id UUID REFERENCES sport_divisions(id) ON DELETE CASCADE,
    custom_team_id UUID REFERENCES custom_teams(id) ON DELETE CASCADE,
    season VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(sport_division_id, custom_team_id, season)
);
```

---

## Layer 4: Club Events & RSVP

```sql
CREATE TABLE club_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    sport_division_id UUID REFERENCES sport_divisions(id),
    event_type VARCHAR CHECK (event_type IN ('match', 'practice', 'social', 'other')),
    title VARCHAR NOT NULL,
    description TEXT,
    event_date TIMESTAMP,
    location VARCHAR,
    
    -- Links to league system matches (source of truth for match data)
    source_system VARCHAR CHECK (source_system IN ('apsl', 'casa', 'custom', 'none')),
    apsl_match_id UUID REFERENCES apsl_matches(id),
    casa_match_id UUID REFERENCES casa_matches(id),
    custom_match_id UUID REFERENCES custom_matches(id),
    
    rsvp_deadline TIMESTAMP,
    max_attendees INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    CHECK (
        (source_system = 'apsl' AND apsl_match_id IS NOT NULL)
        OR (source_system = 'casa' AND casa_match_id IS NOT NULL)
        OR (source_system = 'custom' AND custom_match_id IS NOT NULL)
        OR (source_system = 'none')
    )
);

CREATE TABLE event_rsvps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES club_events(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    player_id UUID REFERENCES players(id),
    rsvp_status VARCHAR CHECK (rsvp_status IN ('yes', 'no', 'maybe')),
    comment TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(event_id, user_id)
);
```

---

## Key Relationships Summary

### Teams
- `apsl_teams` → linked to clubs via `sport_division_apsl_teams`
- `casa_teams` → linked to clubs via `sport_division_casa_teams`
- `custom_teams` → linked to clubs via `sport_division_custom_teams`

### Players
- `apsl_players` → linked to FootballHome via `players_apsl_players`
- `casa_players` → linked to FootballHome via `players_casa_players`
- `custom_players` → linked to FootballHome via `players_custom_players`

### Users
- Authenticate via `users` table
- Have unified profile via `players` table
- Claim league-specific profiles via `players_*_players` tables

### Matches
- `apsl_matches`, `casa_matches`, `custom_matches` → source of truth
- Linked to club events via `club_events.{source}_match_id`
- Club adds RSVPs, comments, carpool info without duplicating match data

---

## Migration Strategy

1. **Phase 1**: Create APSL structure (apsl_leagues, apsl_divisions, refactor existing tables)
2. **Phase 2**: Create CASA structure (mirror APSL)
3. **Phase 3**: Create Custom structure (similar to APSL/CASA)
4. **Phase 4**: Create Players identity layer
5. **Phase 5**: Create junction tables (sport_division_*_teams, players_*_players)
6. **Phase 6**: Migrate existing data to new structure
7. **Phase 7**: Update scrapers to populate new tables
8. **Phase 8**: Update API controllers to query new structure

---

## Example Queries

### Get all teams for Lighthouse club across all leagues
```sql
SELECT 
    'apsl' as league_system,
    at.name as team_name,
    ad.name as division_name,
    sdat.season
FROM sport_divisions sd
JOIN sport_division_apsl_teams sdat ON sd.id = sdat.sport_division_id
JOIN apsl_teams at ON sdat.apsl_team_id = at.id
JOIN apsl_divisions ad ON at.apsl_division_id = ad.id
WHERE sd.club_id = <lighthouse_id>

UNION ALL

SELECT 
    'casa' as league_system,
    ct.name,
    cd.name,
    sdct.season
FROM sport_divisions sd
JOIN sport_division_casa_teams sdct ON sd.id = sdct.sport_division_id
JOIN casa_teams ct ON sdct.casa_team_id = ct.id
JOIN casa_divisions cd ON ct.casa_division_id = cd.id
WHERE sd.club_id = <lighthouse_id>;
```

### Get all stats for Ridge Robinson across all leagues
```sql
-- APSL stats
SELECT aps.* 
FROM players p
JOIN players_apsl_players pap ON p.id = pap.player_id
JOIN apsl_player_stats aps ON pap.apsl_player_id = aps.apsl_player_id
WHERE p.first_name = 'Ridge' AND p.last_name = 'Robinson'

UNION ALL

-- CASA stats
SELECT cps.*
FROM players p
JOIN players_casa_players pcp ON p.id = pcp.player_id
JOIN casa_player_stats cps ON pcp.casa_player_id = cps.casa_player_id
WHERE p.first_name = 'Ridge' AND p.last_name = 'Robinson';
```

### Get RSVP event with APSL match data
```sql
SELECT 
    ce.title,
    ce.event_date,
    ce.rsvp_deadline,
    am.home_team_id,
    am.away_team_id,
    am.match_date,
    am.venue,
    COUNT(er.id) as rsvp_count
FROM club_events ce
JOIN apsl_matches am ON ce.apsl_match_id = am.id
LEFT JOIN event_rsvps er ON er.event_id = ce.id
WHERE ce.id = <event_id>
GROUP BY ce.id, am.id;
```
