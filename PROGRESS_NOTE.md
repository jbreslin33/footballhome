# Football Home - Object-Oriented Architecture Progress

## 🎯 Current Status (Dec 6, 2025 - Latest)
**GroupMe Integration - FULLY AUTOMATED** ✅

### 🚀 Major Milestone: Full GroupMe Sync in `dev.sh`
We have successfully integrated a robust, API-based GroupMe synchronization workflow into the main development script.

**Key Achievements:**
1. **Multi-Group User Import:**
   - Created `scripts/import-all-groupme-users.js`.
   - Imports members from 3 key groups: "APSL Lighthouse", "Lighthouse Boys Club", and "Lighthouse Old Timers".
   - **Normalization:** All users are assigned to a single "Club Team" (Lighthouse 1893 SC) to ensure unified practice management.
   - **Fuzzy Matching:** Matches GroupMe members to existing DB users by ID first, then Name.

2. **Practice & RSVP Sync:**
   - Created `scripts/import-groupme-practices.js`.
   - Fetches calendar events directly from the GroupMe API.
   - **Smart Deduplication:** Checks for existing events by Title + Date (+/- 1 minute) to prevent duplicates.
   - **RSVP Processing:** Automatically inserts `player_rsvp_history` records for "Going" and "Not Going" responses, linked to the correct players.

3. **Database Structure:**
   - Added `database/data/11-casa-teams.sql` to persist the CASA League, Conferences, and Lighthouse teams structure.
   - This ensures the "Club Team" ID (`d37eb44b...`) always exists for the import scripts to target.

4. **Workflow Integration:**
   - Updated `dev.sh` to include the `--groupme` flag.
   - Running `./dev.sh --apsl --test-data --groupme` now performs a full system rebuild, scrapes external data, loads test schedules, AND syncs all GroupMe data in one go.

**Next Steps:**
- **Frontend:** Verify that the imported practices and RSVPs display correctly on the Coach Dashboard.
- **Automation:** Consider setting up a cron job or scheduled task to run the sync scripts periodically in production.

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
