# Football Home - Multi-Tenant Club & League Architecture

## Current State ✅
- Normalized multi-sport schema (25+ tables)
- Google Places venue integration  
- Team/user management
- Event/RSVP system

## Evolution Path: Club-First → League Integration

### Phase 1: Enhanced Club Management (Current Focus)
```sql
-- Current entities we have:
users → team_members → teams → events
sports, event_types, positions, user_roles

-- Add club layer:
clubs
├── id (UUID)
├── name ("Thunder FC", "Manchester Youth Soccer")
├── short_name ("TFC", "MYS") 
├── location (city, state, country)
├── timezone 
├── settings (JSON - club preferences)
├── subscription_tier (free, premium)
└── created_at

-- Connect teams to clubs:
ALTER TABLE teams ADD COLUMN club_id UUID REFERENCES clubs(id);
```

### Phase 2: League Optional Layer  
```sql
leagues
├── id (UUID)
├── name ("Metro Youth Soccer League")
├── season_start, season_end
├── league_type (recreational, competitive, tournament)
├── sport_id (references sports)
├── location (geographic scope)
└── settings (JSON - league rules)

league_clubs (many-to-many)
├── league_id REFERENCES leagues(id)
├── club_id REFERENCES clubs(id) 
├── joined_date
├── status (active, pending, suspended)
└── division_level (if applicable)
```

### Phase 3: API Integration & Interoperability
```sql
external_integrations
├── club_id REFERENCES clubs(id)
├── platform_name (TeamSnap, SportsEngine, etc.)
├── api_credentials (encrypted)
├── sync_settings (what data to sync)
└── last_sync

api_keys
├── club_id REFERENCES clubs(id)
├── key_hash (for clubs to expose their own APIs)
├── permissions (read_only, full_access)
└── rate_limits
```

## Global Considerations

### Multi-Timezone Support
```sql
-- Add to clubs table:
timezone VARCHAR(50) DEFAULT 'UTC'

-- Events already have timestamp, but need timezone-aware display
-- Example: Store UTC, display in club's timezone
```

### Multi-Sport Flexibility  
```sql
-- Already handled via sports table:
sports (soccer, basketball, cricket, rugby, etc.)
├── season_structure (JSON - when seasons typically run)
├── typical_game_duration  
├── field_requirements
└── regional_variations
```

### Multi-Currency (Future)
```sql
currencies
├── code (USD, EUR, GBP, etc.)
├── symbol
└── exchange_rate_to_usd

-- Add to clubs:
ALTER TABLE clubs ADD COLUMN currency_code VARCHAR(3) DEFAULT 'USD';
```

## Implementation Strategy

### MVP: Enhanced Single Club
1. ✅ Current venue system (Google Places)
2. ✅ Current team/event management  
3. 🔄 Add club entity above teams
4. 🔄 Club-level settings and branding
5. 🔄 Club admin permissions

### Phase 2: Multi-Club Support
1. League creation (optional)
2. Inter-club scheduling
3. Cross-club venue sharing
4. League standings/tournaments

### Phase 3: Platform Integration
1. RESTful API for external systems
2. Webhook system for real-time updates
3. Data import/export tools
4. Third-party authentication (Google, Facebook, club systems)

## API Strategy Examples

### Club API Endpoints (for integration)
```
GET /api/v1/clubs/{id}/teams
GET /api/v1/clubs/{id}/events
POST /api/v1/clubs/{id}/events
GET /api/v1/clubs/{id}/venues
POST /api/v1/clubs/{id}/teams/{id}/players
```

### League API Endpoints
```
GET /api/v1/leagues/{id}/standings
GET /api/v1/leagues/{id}/schedule
POST /api/v1/leagues/{id}/match-results
GET /api/v1/leagues/{id}/clubs
```

### External Integration Examples
```javascript
// Example: Import players from TeamSnap
POST /api/v1/integrations/teamsnap/sync
{
  "club_id": "uuid",
  "teamsnap_team_id": "12345",
  "sync_type": "players_only"
}

// Example: Export schedule to Google Calendar
POST /api/v1/integrations/google-calendar/export
{
  "team_id": "uuid", 
  "calendar_id": "team@club.com"
}
```

## Revenue Model Implications

### Freemium Club Model
- **Free**: Basic club management (1-3 teams)
- **Premium**: Unlimited teams, advanced scheduling, integrations
- **Enterprise**: League management, API access, custom branding

### API Monetization
- Free tier: 1000 API calls/month
- Paid tiers: Higher limits + premium endpoints
- Enterprise: Custom integrations, dedicated support

## Next Steps Discussion

1. **Should we add the `clubs` table now** to prepare for this vision?
2. **Multi-tenancy**: Each club gets subdomain (thunderfc.footballhome.org) or path (/clubs/thunderfc)?
3. **Global rollout**: Start with English-speaking markets (US, UK, Australia) then expand?
4. **Partnership strategy**: Integrate with existing platforms or compete directly?

This architecture gives you a clear path from where you are now to a global multi-sport platform while maintaining the club-first approach. What aspects would you like to dive deeper into?