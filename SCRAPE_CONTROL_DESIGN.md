# Scrape Control System - Enhanced Design

## Current State (What We Have)
```sql
scrape_targets:
  - is_active (boolean) - simple on/off switch
  - is_initialized (boolean) - has it ever run?
  - last_synced_at - when last scraped
  
scrape_executions:
  - Records each scrape run
  - Tracks success/failure
  - But doesn't influence next run
```

## Problem
1. **No state machine** - Just active/inactive, no "completed and skip"
2. **No action control** - Can't say "use cached HTML only" vs "fetch fresh"
3. **Always re-scrapes** - Historical data keeps re-scraping on every ./update.sh
4. **No completion tracking** - No way to mark "this is done, skip it"

## Proposed Enhancement

### Add scrape_actions Table (What To Do)
```sql
CREATE TABLE scrape_actions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO scrape_actions (id, name, description, sort_order) VALUES
    (1, 'download_and_parse', 'Fetch fresh HTML/API data and parse it', 1),
    (2, 'use_cache_only', 'Parse existing cached HTML without fetching', 2),
    (3, 'skip', 'Do not process this target (completed/archived)', 3),
    (4, 'force_refresh', 'Force fresh download even if recently scraped', 4),
    (5, 'verify_only', 'Check if data exists, report discrepancies', 5);
```

### Add scrape_statuses Table (Current State)
```sql
CREATE TABLE scrape_statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO scrape_statuses (id, name, description, sort_order) VALUES
    (1, 'not_started', 'Never been scraped', 1),
    (2, 'in_progress', 'Currently being scraped', 2),
    (3, 'completed', 'Successfully scraped and up-to-date', 3),
    (4, 'needs_refresh', 'Data exists but may be stale', 4),
    (5, 'failed', 'Last scrape failed', 5),
    (6, 'archived', 'Historical data, will not update', 6);
```

## Complete Normalized Table Definitions

### scrape_actions (Lookup Table)
```sql
CREATE TABLE scrape_actions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO scrape_actions (id, name, description, sort_order) VALUES
    (1, 'download_and_parse', 'Fetch fresh HTML/API data and parse it', 1),
    (2, 'use_cache_only', 'Parse existing cached HTML without fetching', 2),
    (3, 'skip', 'Do not process this target (completed/archived)', 3),
    (4, 'force_refresh', 'Force fresh download even if recently scraped', 4),
    (5, 'verify_only', 'Check if data exists, report discrepancies', 5)
ON CONFLICT (id) DO NOTHING;
```

### scrape_statuses (Lookup Table)
```sql
CREATE TABLE scrape_statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER DEFAULT 0
);

INSERT INTO scrape_statuses (id, name, description, sort_order) VALUES
    (1, 'not_started', 'Never been scraped', 1),
    (2, 'in_progress', 'Currently being scraped', 2),
    (3, 'completed', 'Successfully scraped and up-to-date', 3),
    (4, 'needs_refresh', 'Data exists but may be stale', 4),
    (5, 'failed', 'Last scrape failed', 5),
    (6, 'archived', 'Historical data, will not update', 6)
ON CONFLICT (id) DO NOTHING;
```

### scrape_targets (Enhanced)
```sql
-- Existing columns (already in schema):
--   id SERIAL PRIMARY KEY
--   source_system_id INTEGER NOT NULL REFERENCES source_systems(id)
--   scraper_type_id INTEGER NOT NULL REFERENCES scraper_types(id)
--   target_type_id INTEGER NOT NULL REFERENCES scrape_target_types(id)
--   url TEXT NOT NULL
--   label VARCHAR(255)
--   is_active BOOLEAN DEFAULT true
--   is_initialized BOOLEAN DEFAULT false
--   last_synced_at TIMESTAMP
--   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
--   updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

-- Add these columns:
ALTER TABLE scrape_targets 
    ADD COLUMN scrape_action_id INTEGER REFERENCES scrape_actions(id) DEFAULT 1,
    ADD COLUMN scrape_status_id INTEGER REFERENCES scrape_statuses(id) DEFAULT 1;

CREATE INDEX idx_scrape_targets_action ON scrape_targets(scrape_action_id);
CREATE INDEX idx_scrape_targets_status ON scrape_targets(scrape_status_id);

-- Final structure:
-- scrape_targets (
--     id SERIAL PRIMARY KEY,
--     source_system_id INTEGER NOT NULL REFERENCES source_systems(id),
--     scraper_type_id INTEGER NOT NULL REFERENCES scraper_types(id),
--     target_type_id INTEGER NOT NULL REFERENCES scrape_target_types(id),
--     scrape_action_id INTEGER REFERENCES scrape_actions(id) DEFAULT 1,
--     scrape_status_id INTEGER REFERENCES scrape_statuses(id) DEFAULT 1,
--     url TEXT NOT NULL,
--     label VARCHAR(255),
--     is_active BOOLEAN DEFAULT true,
--     is_initialized BOOLEAN DEFAULT false,
--     last_synced_at TIMESTAMP,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- )
```

### scrape_executions (Already Exists - Normalized)
```sql
-- This table already exists and is properly normalized
-- Records every scrape execution with full details

CREATE TABLE scrape_executions (
    id SERIAL PRIMARY KEY,
    scrape_target_id INTEGER NOT NULL REFERENCES scrape_targets(id),
    status_id INTEGER NOT NULL REFERENCES scrape_execution_statuses(id),
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    duration_ms INTEGER,
    entities_created INTEGER DEFAULT 0,
    entities_updated INTEGER DEFAULT 0,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_scrape_executions_target ON scrape_executions(scrape_target_id);
CREATE INDEX idx_scrape_executions_status ON scrape_executions(status_id);
CREATE INDEX idx_scrape_executions_started ON scrape_executions(started_at DESC);

-- Query latest status (normalized - no denormalization needed):
SELECT st.*, 
       sa.name as action_name,
       ss.name as status_name,
       se.started_at as last_run_at,
       se.error_message as last_error
FROM scrape_targets st
LEFT JOIN scrape_actions sa ON st.scrape_action_id = sa.id
LEFT JOIN scrape_statuses ss ON st.scrape_status_id = ss.id
LEFT JOIN LATERAL (
    SELECT * FROM scrape_executions 
    WHERE scrape_target_id = st.id 
    ORDER BY started_at DESC 
    LIMIT 1
) se ON true;
```

### Entity-Specific Scrape Target Junction Tables (Many-to-Many)
```sql
-- Match scrape targets (a match can have multiple scrape targets)
-- Example: match lineups, match events, match stats all for same match
CREATE TABLE match_scrape_targets (
    scrape_target_id INTEGER NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    PRIMARY KEY (scrape_target_id, match_id)
);
CREATE INDEX idx_match_scrape_targets_match ON match_scrape_targets(match_id);

-- Team scrape targets (a team can have multiple scrape targets)
-- Example: team roster, team stats, team schedule
CREATE TABLE team_scrape_targets (
    scrape_target_id INTEGER NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    PRIMARY KEY (scrape_target_id, team_id)
);
CREATE INDEX idx_team_scrape_targets_team ON team_scrape_targets(team_id);

-- Player scrape targets (a player can have multiple scrape targets)
-- Example: player profile, player stats, player history
CREATE TABLE player_scrape_targets (
    scrape_target_id INTEGER NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    PRIMARY KEY (scrape_target_id, player_id)
);
CREATE INDEX idx_player_scrape_targets_player ON player_scrape_targets(player_id);

-- Season scrape targets (a season can have multiple scrape targets)
-- Example: season structure, season schedule, season standings
CREATE TABLE season_scrape_targets (
    scrape_target_id INTEGER NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    season_id INTEGER NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    PRIMARY KEY (scrape_target_id, season_id)
);
CREATE INDEX idx_season_scrape_targets_season ON season_scrape_targets(season_id);

-- Division scrape targets (a division can have multiple scrape targets)
-- Example: division standings, division schedule, division stats
CREATE TABLE division_scrape_targets (
    scrape_target_id INTEGER NOT NULL REFERENCES scrape_targets(id) ON DELETE CASCADE,
    division_id INTEGER NOT NULL REFERENCES divisions(id) ON DELETE CASCADE,
    PRIMARY KEY (scrape_target_id, division_id)
);
CREATE INDEX idx_division_scrape_targets_division ON division_scrape_targets(division_id);
```

## State Machine Transitions

### Automatic Transitions (by update.sh)
```
not_started + download_and_parse → scrape → success → completed
not_started + download_and_parse → scrape → fail → failed
completed + skip → SKIP (don't process)
archived + * → SKIP (never process)
failed + retry_count < 3 → try again
failed + retry_count >= 3 → skip for this run
```

### Manual Transitions (via SQL or admin UI)
```sql
-- Mark historical season as complete (never scrape again)
UPDATE scrape_targets 
SET scrape_action_id = 3, -- skip
    scrape_status_id = 6  -- archived
WHERE id = 2;

-- Force refresh of current season structure
UPDATE scrape_targets 
SET scrape_action_id = 4, -- force_refresh
    scrape_status_id = 4  -- needs_refresh
WHERE id = 1;

-- Use cached HTML for testing (don't hit live site)
UPDATE scrape_targets 
SET scrape_action_id = 2  -- use_cache_only
WHERE source_system_id = 1;
```

## update.js Query Logic

### OLD (Current - Just is_active)
```javascript
const targets = await client.query(`
    SELECT * FROM scrape_targets 
    WHERE is_active = true
`);
```

### NEW (State Machine)
```javascript
const targets = await client.query(`
    SELECT st.*, 
           sa.name as action_name,
           ss.name as status_name
    FROM scrape_targets st
    JOIN scrape_actions sa ON st.scrape_action_id = sa.id
    JOIN scrape_statuses ss ON st.scrape_status_id = ss.id
    WHERE st.is_active = true
      AND sa.name != 'skip'                    -- Don't process 'skip' targets
      AND ss.name NOT IN ('archived')          -- Don't process archived
      AND (ss.name != 'failed' OR st.retry_count < 3)  -- Retry failed up to 3 times
    ORDER BY st.id
`);

// Process each target based on action
for (const target of targets.rows) {
    if (target.action_name === 'download_and_parse' || target.action_name === 'force_refresh') {
        // Fetch fresh HTML/API data
        const html = await fetcher.fetch(target.url, useCache=false);
        await parser.parse(html);
    } else if (target.action_name === 'use_cache_only') {
        // Use cached HTML (for testing/replay)
        const html = await fetcher.fetch(target.url, useCache=true);
        await parser.parse(html);
    }
    
    // Update status after success/failure
    await updateTargetStatus(target.id, success ? 'completed' : 'failed');
}
```

## Use Cases

### 1. Historical Seasons (Scrape Once, Archive)
```sql
-- Initial state: Ready to scrape
INSERT INTO scrape_targets (id, scrape_action_id, scrape_status_id, ...) VALUES
    (2, 1, 1, ...);  -- download_and_parse, not_started

-- After successful scrape: Archive it
UPDATE scrape_targets 
SET scrape_action_id = 3,   -- skip
    scrape_status_id = 6,   -- archived
    last_success_at = NOW()
WHERE id = 2;

-- Result: ./update.sh will skip this target forever
```

### 2. Current Season Structure (Re-scrape Weekly)
```sql
-- Always active, re-scrapes periodically
UPDATE scrape_targets 
SET scrape_action_id = 1,   -- download_and_parse
    scrape_status_id = 4    -- needs_refresh (every week)
WHERE id = 1;

-- Could add: next_refresh_at to control frequency
```

### 3. Match Results (Scrape Once Per Match)
```sql
-- New match discovered: Create scrape target for it
INSERT INTO scrape_targets (scrape_action_id, scrape_status_id, source_system_id, scraper_type_id, target_type_id, url, label) 
VALUES (1, 1, 1, 1, 10, 'https://apslsoccer.com/match/12345', 'APSL Match 12345');

-- Link to match entity
INSERT INTO match_scrape_targets (scrape_target_id, match_id) 
VALUES (CURRVAL('scrape_targets_id_seq'), 12345);

-- After successful scrape: Mark complete
UPDATE scrape_targets st
SET scrape_action_id = 3,   -- skip
    scrape_status_id = 3,   -- completed
    last_success_at = NOW()
FROM match_scrape_targets mst
WHERE st.id = mst.scrape_target_id 
  AND mst.match_id = 12345;

-- Query all unscraped matches
SELECT m.*, st.url, st.label
FROM matches m
LEFT JOIN match_scrape_targets mst ON m.id = mst.match_id
LEFT JOIN scrape_targets st ON mst.scrape_target_id = st.id
WHERE st.scrape_status_id != 3  -- not completed
   OR st.id IS NULL;  -- no scrape target yet
```

### 4. Testing With Cached HTML
```sql
-- Switch all APSL targets to use cached HTML (don't hit live site)
UPDATE scrape_targets 
SET scrape_action_id = 2  -- use_cache_only
WHERE source_system_id = 1;

-- Switch back to live scraping
UPDATE scrape_targets 
SET scrape_action_id = 1  -- download_and_parse
WHERE source_system_id = 1;
```

## Migration Path

1. **Add lookup tables** (scrape_actions, scrape_statuses)
2. **Add columns to scrape_targets** (scrape_action_id, scrape_status_id, etc.)
3. **Create entity-specific junction tables** (match_scrape_targets, team_scrape_targets, etc.)
4. **Set defaults for existing data**:
   ```sql
   UPDATE scrape_targets SET 
       scrape_action_id = 1,  -- download_and_parse
       scrape_status_id = CASE 
           WHEN is_initialized = true THEN 3  -- completed
           ELSE 1  -- not_started
       END;
   ```
5. **Update update.js** to respect state machine
6. **Update scrapers** to report success/failure and update status
7. **(Eventually) Deprecate is_active** - use scrape_action_id + scrape_status_id instead

## Benefits

✅ **Prevents unnecessary scraping** - Historical data marked 'archived' never re-scrapes
✅ **Controlled refresh** - Can force refresh or use cache for testing
✅ **Better error handling** - Retry failed scrapes, track error counts
✅ **Proper relational design** - No JSON, proper foreign keys to entities
✅ **Audit trail** - scrape_executions table tracks every run
✅ **Admin UI ready** - Can build UI to manage scrape targets with clear states
✅ **Type-safe queries** - Join to entity tables, no JSON parsing
