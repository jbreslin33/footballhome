# Database Normalization - Football Home v2.0

## Overview
The Football Home database has been completely normalized to eliminate hardcoded constraint values and provide multi-sport flexibility. This document outlines all the changes made to transform the database from a soccer-specific system to a flexible multi-sport team management platform.

## Migration Summary

### What Changed
- **From**: Hardcoded CHECK constraints and VARCHAR fields with default values
- **To**: Normalized lookup tables with foreign key relationships
- **Result**: Multi-sport support, data integrity, and flexible system architecture

## New Lookup Tables

### 1. Sports Table
```sql
CREATE TABLE sports (
    id UUID PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,          -- 'soccer', 'basketball', 'hockey'
    display_name VARCHAR(100) NOT NULL,        -- 'Soccer', 'Basketball', 'Ice Hockey'
    default_event_duration INTEGER DEFAULT 90, -- Default minutes for this sport
    typical_team_size INTEGER,                 -- 11 for soccer, 5 for basketball
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Pre-populated with**: Soccer, Basketball, Ice Hockey, Baseball, Volleyball

### 2. User Roles Table
```sql
CREATE TABLE user_roles (
    id UUID PRIMARY KEY,
    name VARCHAR(20) UNIQUE NOT NULL,          -- 'coach', 'player', 'admin'
    display_name VARCHAR(50) NOT NULL,         -- 'Coach', 'Player', 'Administrator'
    permissions TEXT[],                        -- Array of permissions
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Replaces**: `users.role CHECK (role IN ('coach', 'player', 'admin'))`

### 3. Event Types Table
```sql
CREATE TABLE event_types (
    id UUID PRIMARY KEY,
    sport_id UUID REFERENCES sports(id),       -- Different types per sport
    name VARCHAR(50) NOT NULL,                 -- 'training', 'match', 'meeting'
    display_name VARCHAR(100) NOT NULL,        -- 'Training Session', 'Match', 'Team Meeting'
    default_duration INTEGER DEFAULT 90,       -- Default duration for this type
    requires_opponent BOOLEAN DEFAULT false,   -- Does this event type need an opponent?
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sport_id, name)
);
```

**Replaces**: `events.event_type CHECK (event_type IN ('training', 'match', 'meeting'))`

### 4. RSVP Statuses Table
```sql
CREATE TABLE rsvp_statuses (
    id UUID PRIMARY KEY,
    name VARCHAR(20) UNIQUE NOT NULL,          -- 'yes', 'no', 'maybe'
    display_name VARCHAR(50) NOT NULL,         -- 'Attending', 'Not Attending', 'Maybe'
    sort_order INTEGER DEFAULT 0,             -- For display ordering
    color VARCHAR(7),                         -- Hex color for UI (#27ae60)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Replaces**: `rsvps.status CHECK (status IN ('yes', 'no', 'maybe'))`
**Enhancement**: Adds UI colors and display ordering

### 5. Positions Table
```sql
CREATE TABLE positions (
    id UUID PRIMARY KEY,
    sport_id UUID NOT NULL REFERENCES sports(id),
    name VARCHAR(50) NOT NULL,                 -- 'goalkeeper', 'striker', 'point_guard'
    display_name VARCHAR(100) NOT NULL,        -- 'Goalkeeper', 'Striker', 'Point Guard'
    abbreviation VARCHAR(5),                   -- 'GK', 'ST', 'PG'
    sort_order INTEGER DEFAULT 0,             -- For display ordering
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sport_id, name)
);
```

**New Feature**: Sport-specific player positions with abbreviations

## Updated Existing Tables

### Teams Table Changes
**Before**:
```sql
sport VARCHAR(50) DEFAULT 'soccer'  -- Hardcoded default
```

**After**:
```sql
sport_id UUID NOT NULL REFERENCES sports(id)  -- Foreign key relationship
primary_color VARCHAR(7)                       -- Team colors
secondary_color VARCHAR(7)
```

### Users Table Changes
**Before**:
```sql
role VARCHAR(20) CHECK (role IN ('coach', 'player', 'admin')) DEFAULT 'player'
```

**After**:
```sql
user_role_id UUID NOT NULL REFERENCES user_roles(id)  -- Foreign key
avatar_url VARCHAR(500)                                -- Profile pictures
date_of_birth DATE                                     -- Player info
emergency_contact VARCHAR(100)                         -- Safety info
emergency_phone VARCHAR(20)
```

### Team Members Table Changes
**Before**:
```sql
role VARCHAR(20) CHECK (role IN ('coach', 'player')) DEFAULT 'player'
```

**After**:
```sql
position_id UUID REFERENCES positions(id)  -- Player position (nullable for coaches)
jersey_number INTEGER                       -- Player jersey numbers
is_captain BOOLEAN DEFAULT false            -- Team captain flag
is_active BOOLEAN DEFAULT true              -- Active membership status
left_at TIMESTAMP                          -- When member left team
UNIQUE(team_id, jersey_number)             -- Jersey numbers unique per team
```

### Events Table Changes
**Before**:
```sql
event_type VARCHAR(20) CHECK (event_type IN ('training', 'match', 'meeting')) DEFAULT 'training'
opponent_team VARCHAR(100)  -- Text field
```

**After**:
```sql
event_type_id UUID NOT NULL REFERENCES event_types(id)  -- Foreign key
opponent_team_id UUID REFERENCES teams(id)               -- Proper team reference
home_away VARCHAR(10) CHECK (home_away IN ('home', 'away'))
cancelled BOOLEAN DEFAULT false
cancellation_reason TEXT
```

### RSVPs Table Changes
**Before**:
```sql
status VARCHAR(20) CHECK (status IN ('yes', 'no', 'maybe')) NOT NULL
```

**After**:
```sql
rsvp_status_id UUID NOT NULL REFERENCES rsvp_statuses(id)  -- Foreign key
dietary_requirements TEXT                                   -- Player dietary needs
transport_needed BOOLEAN DEFAULT false                      -- Transportation assistance
```

## API Endpoints Updated

### New Endpoints
- `GET /api/sports` - List all available sports
- `GET /api/sports/:sportId/positions` - Get positions for a sport
- `GET /api/sports/:sportId/event-types` - Get event types for a sport
- `GET /api/rsvp-statuses` - Get all RSVP status options

### Modified Endpoints
All existing endpoints updated to use normalized relationships:
- Login now includes position and team information
- Events API uses event type display names
- RSVP API includes status colors and display names
- Profile updates handle position assignments

## Benefits of Normalization

### 1. Multi-Sport Flexibility
- **Before**: Hardcoded for soccer only
- **After**: Supports any sport with sport-specific positions and event types

### 2. Data Integrity
- **Before**: String-based constraints could be violated
- **After**: Foreign key constraints ensure referential integrity

### 3. Extensibility
- **Before**: Adding new roles/statuses required code changes
- **After**: New values can be added via database inserts

### 4. User Experience
- **Before**: Generic constraint violation messages
- **After**: Meaningful display names and colors for UI

### 5. Reporting & Analytics
- **Before**: Text-based fields difficult to aggregate
- **After**: Proper relationships enable complex queries and reporting

## Migration Process

### Automated Migration
Run the provided migration script:
```bash
./scripts/migrate-to-normalized.sh
```

### Manual Migration Steps
1. **Backup existing data** (if needed)
2. **Stop all services**: `podman-compose down`
3. **Clear database volume**: `podman volume rm footballhome_db_data`
4. **Start database**: `podman-compose up -d db`
5. **Apply schema**: `psql -f database/init.sql`
6. **Start all services**: `podman-compose up -d`

## Sample Data Included

### Sports
- Soccer (Football) - 90min events, 11 players
- Basketball - 60min events, 5 players  
- Ice Hockey - 60min events, 6 players
- Baseball - 180min events, 9 players
- Volleyball - 90min events, 6 players

### Positions (Soccer)
- Goalkeeper (GK)
- Defender (DEF)
- Midfielder (MID)
- Forward (FWD)

### Event Types (Soccer)
- Training Session (90min)
- Match (120min, requires opponent)
- Team Meeting (60min)
- Scrimmage (90min)

### RSVP Statuses
- Attending (Green #27ae60)
- Maybe (Orange #f39c12)
- Not Attending (Red #e74c3c)

## Compatibility Notes

### Frontend Changes Required
- Forms now use dropdowns populated from API endpoints
- RSVP displays use colors from status definitions
- Position selection is sport-specific

### API Client Updates
- Event creation requires `event_type_name` instead of hardcoded values
- RSVP submission uses `status_name` instead of direct status values
- User profiles include normalized position and role information

## Performance Improvements

### New Indexes
```sql
CREATE INDEX idx_events_type ON events(event_type_id);
CREATE INDEX idx_rsvps_status ON rsvps(rsvp_status_id);
CREATE INDEX idx_team_members_position ON team_members(position_id);
CREATE INDEX idx_users_role ON users(user_role_id);
CREATE INDEX idx_teams_sport ON teams(sport_id);
CREATE INDEX idx_positions_sport ON positions(sport_id);
CREATE INDEX idx_event_types_sport ON event_types(sport_id);
```

### Query Optimization
- JOIN operations replace string comparisons
- Indexed foreign keys improve query performance
- Normalized structure enables better query planning

## Future Enhancements Enabled

### Multi-Sport Support
- Easy addition of new sports with their specific rules
- Sport-specific event types and positions
- Cross-sport tournament support

### Advanced Features
- Position-based team formation tools
- Sport-specific statistics tracking
- Automated team selection based on positions
- Multi-language support via display_name fields

### Administrative Tools
- Role-based permission management
- Sport and position administration
- Custom event type creation
- Team color and branding management

---

**Migration completed successfully!** 🎉

The Football Home platform is now a flexible, normalized multi-sport team management system ready for expansion and enhanced functionality.