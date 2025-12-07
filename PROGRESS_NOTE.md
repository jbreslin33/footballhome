# Football Home - Object-Oriented Architecture Progress

## 🎯 Current Status (Dec 6, 2025 - Latest)
**APSL Scraper + Multi-Team Roster Design** ✅

### 🚀 APSL Scraper Now Working!
Successfully fixed the APSL scraper to handle network errors and generate proper bulk INSERT statements:

**Fixes Completed:**
1. **Network Error Handling:**
   - Added `uncaughtException` handler for transient ECONNRESET errors
   - Proper error handlers attached to request/response streams BEFORE operations
   - 3-attempt retry logic with exponential backoff
   - Scraper completes successfully despite intermittent network issues

2. **Bulk INSERT Generation:**
   - Changed from individual INSERT per row to multi-row VALUES statements
   - Example: `INSERT INTO users (...) VALUES (row1), (row2), (row3) ON CONFLICT ...`
   - Significantly faster than individual INSERTs
   - Better for database performance

3. **COPY Format Issues:**
   - Identified converter bug with special characters (parentheses in names)
   - Decision: Use bulk INSERTs instead of COPY for now (still fast)
   - Removed broken COPY files to prevent database load failures

4. **Data Quality:**
   - Fixed invalid UUID for Old Timers team (`01d71me5...` → `01d71ee5...`)
   - All 3 Lighthouse teams now load correctly
   - APSL scraper generates: 53 teams, 1842 players, 246 matches

**Current State:**
- ✅ All 3 teams visible in UI (Lighthouse 1893 SC, Boys Club, Old Timers)
- ✅ Lighthouse 1893 SC has 122 players from APSL scraper
- ⚠️  Boys Club and Old Timers have 0 players (need GroupMe roster import)

### 📋 ROADMAP: Multi-Team Practice Management

**Problem Identified:**
- GroupMe "Training Lighthouse" group has ALL club members (~100+ people)
- GroupMe "Boys Club" and "Old Timers" groups have team-specific rosters
- Players can be on multiple teams (e.g., plays for both Boys Club AND Old Timers)
- Current DB: Each practice linked to ONE team only

**Solution Plan (in priority order):**

**1. Fix GroupMe Team Mapping (5 min) - DO THIS FIRST**
   - Update GroupMe import team IDs in scripts
   - APSL Lighthouse group → `d37eb44b-8e47-0005-9060-f0cbe96fe089` ✓ (already correct)
   - Boys Club group → `b0c1abb0-c1ab-0001-b0c1-ab0c1abb0c1a`
   - Old Timers group → `01d71ee5-01d7-0002-1ee5-01d71ee501d7`
   - Run `dev.sh --groupme` to populate rosters
   - **Result:** All 3 teams will have players

**2. Add practice_teams Junction Table (30 min)**
   - Create migration: `practice_teams` table
     - Columns: `practice_id`, `team_id`, `is_primary`
     - PKs and FKs to practices and teams
   - Keep `practices.team_id` as primary/owning team (backward compatible)
   - **Result:** Database ready for multi-team practices

**3. Update Practice Creation UI/API (45 min)**
   - Add "Additional Teams" checkboxes when creating practice
   - Insert rows into `practice_teams` for each selected team
   - Always include primary team with `is_primary=true`
   - **Result:** Can create practices applying to multiple teams

**4. Update RSVP Logic (30 min)**
   - Query: JOIN through `practice_teams` instead of just `practices.team_id`
   - Show player's RSVP once, even if on multiple teams for that practice
   - Display which teams the practice applies to
   - **Result:** RSVPs work correctly across all player's teams

**Design Benefits:**
- Players on multiple teams see practice once, RSVP once
- RSVP automatically applies to all their teams for that practice
- Normalized database structure
- Backward compatible (existing single-team practices work)

**Next Steps:**
- Start with #1 to get immediate value (all teams have rosters)
- Then build #2-4 incrementally

---

## 🎯 Current Status (Dec 6, 2025 - Previous)
**GroupMe API Strategy - FINALIZED** ✅

### 🚫 NO MORE WEB SCRAPING
We have officially abandoned all Puppeteer/Selenium web scraping attempts for GroupMe.
- **Reason:** GroupMe uses Arkose Labs bot detection (Captcha/Enforcement) which blocks automated browsers.
- **Decision:** All future GroupMe interactions must use the **Official GroupMe API v3**.

### 🔑 The "Hidden" Event Data Strategy
We discovered that while the GroupMe API doesn't have a simple `GET /events` endpoint that lists everything nicely, the data **is** available in the message history.

**How it works:**
1. **System Messages:** When a user RSVPs in the app, GroupMe posts a hidden "system message" to the chat.
2. **Message Scanning:** We scan the last ~2000 messages in the group via `GET /groups/:id/messages`.
3. **Data Extraction:** We look for messages with `event.type` equal to:
   - `calendar.event.user.going`
   - `calendar.event.user.not_going`
   - `calendar.event.user.undecided`
4. **Aggregation:** We aggregate these messages to build the final RSVP list. Since messages are chronological, we only keep the *latest* status for each user ID.

**Key Scripts:**
- `scripts/dump-events-json.js`: Scans history and outputs a full JSON dump of all active events and their RSVP lists.
- `scripts/find-latest-event.js`: Quickly finds the most recent event and prints a summary.

**Next Steps:**
- Integrate this logic into the main database import pipeline (`scripts/import-groupme-practices-simple.js`).
- Ensure we use the API token from `.env` (`GROUPME_ACCESS_TOKEN`).

### 👥 User Import & Normalization Strategy
**Problem:** Players are often on multiple teams. If we create separate practice events for each team, a player on both teams would see duplicate events and have to RSVP twice.
**Solution:**
1. **Club-Wide Team:** We will use (or create) a single "Club" team (e.g., "Lighthouse Club") that represents the entire organization.
2. **Universal Roster:** All players imported from GroupMe will be assigned to this Club Team in `team_players`.
3. **Unified Events:** Practices will be created for this Club Team.
   - **Result:** Only 1 Event record exists in the DB.
   - **Result:** Each player has exactly 1 RSVP record for that event.
   - **Result:** No duplicates in the UI or DB.

**Implementation:**
- `scripts/import-groupme-users.js`: New script to fetch all GroupMe members, upsert them into `users` (matching by ID or Name), and assign them to the target Club Team.

---

## 🎯 Current Status (Dec 5, 2025 - Latest)
**GroupMe Integration - COMPLETED** ✅

### GroupMe RSVP Import - Fully Working!
Successfully integrated GroupMe calendar events and RSVPs into Football Home:

**What Was Built:**
1. **Practice Import** (`scripts/import-groupme-practices-simple.js`)
   - Fetches calendar events from GroupMe API
   - Creates event + practice records in database
   - Stores ALL GroupMe data (going/not_going arrays, timestamps) as JSON in practice notes
   - No RSVP processing in this script - keeps it simple and focused

2. **GroupMe ID Sync** (`scripts/sync-groupme-ids.js`)
   - Matches GroupMe users to Football Home users via fuzzy name matching
   - Populates `users.groupme_id` field for direct ID linking
   - 80% match threshold (increased from 60% for accuracy)
   - Duplicate prevention: tracks used GroupMe IDs from DB + within run
   - Fixed to use correct tables: `team_players` not `rosters`

3. **RSVP Import** (`scripts/import-groupme-rsvps.js`)
   - Reads practice notes JSON containing GroupMe RSVP data
   - Matches users by `groupme_id` field
   - Inserts into `player_rsvp_history` table
   - Uses correct FK IDs: 'yes'/'no' rsvp_statuses, 'bulk_import' change_source
   - Skips unmatched users (no groupme_id or not a player)

**Results:**
- ✅ 4 practices imported from GroupMe
- ✅ 29 users matched with GroupMe IDs (80% threshold)
- ✅ 54 RSVPs successfully imported
- ✅ RSVPs display correctly in frontend practice management

**Dev Workflow:**
- `./dev.sh --groupme` runs all 3 scripts automatically:
  1. Sync GroupMe IDs (match names)
  2. Import practices (with JSON RSVP data)
  3. Import RSVPs (using synced IDs)

**Schema Changes:**
- Added `users.groupme_id VARCHAR(50)` field with unique partial index
- Cleaned up: removed unused `database/schema/` folder (only `database/data/` is loaded)

### 📝 Future Enhancement: GroupMe Alias Field
**TODO:** Add `groupme_alias` field to users table to help with name matching

**Problem:** GroupMe nicknames don't always match official names from APSL/CASA/Lighthouse
- Example: GroupMe shows "MoMo" but real name is "Mohamed Bility"
- Current fuzzy matching (80% threshold) misses some users

**Proposed Solution:**
- Add `users.groupme_alias VARCHAR(100)` field
- Manual entry: coaches can set aliases for players
- Sync script checks alias FIRST, then falls back to fuzzy matching
- Benefits future data imports from CASA, Lighthouse websites
