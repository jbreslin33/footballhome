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

### Enhanced scrape_targets Table
```sql
ALTER TABLE scrape_targets 
    ADD COLUMN scrape_action_id INTEGER REFERENCES scrape_actions(id) DEFAULT 1,
    ADD COLUMN scrape_status_id INTEGER REFERENCES scrape_statuses(id) DEFAULT 1,
    ADD COLUMN last_success_at TIMESTAMP,
    ADD COLUMN last_error_at TIMESTAMP,
    ADD COLUMN last_error_message TEXT,
    ADD COLUMN retry_count INTEGER DEFAULT 0;

CREATE INDEX idx_scrape_targets_action ON scrape_targets(scrape_action_id);
CREATE INDEX idx_scrape_targets_status ON scrape_targets(scrape_status_id);
```

### Entity-Specific Scrape Target Tables (Relational, Not JSON!)
```sql
-- When a scrape target is for a specific match
CREATE TABLE match_scrape_targets (
    scrape_target_id INTEGER PRIMARY KEY REFERENCES scrape_targets(id) ON DELETE CASCADE,
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    UNIQUE(match_id, scrape_target_id)
);

-- When a scrape target is for a specific team
CREATE TABLE team_scrape_targets (
    scrape_target_id INTEGER PRIMARY KEY REFERENCES scrape_targets(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    UNIQUE(team_id, scrape_target_id)
);

-- When a scrape target is for a specific player
CREATE TABLE player_scrape_targets (
    scrape_target_id INTEGER PRIMARY KEY REFERENCES scrape_targets(id) ON DELETE CASCADE,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    UNIQUE(player_id, scrape_target_id)
);

-- When a scrape target is for a specific season
CREATE TABLE season_scrape_targets (
    scrape_target_id INTEGER PRIMARY KEY REFERENCES scrape_targets(id) ON DELETE CASCADE,
    season_id INTEGER NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    UNIQUE(season_id, scrape_target_id)
);
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
