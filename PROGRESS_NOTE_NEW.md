# Football Home - Progress Note

## 🎯 Current Status (Nov 24, 2025)

**Database Schema & Data Loading Issue**

**CURRENT ISSUE**: Teams not showing up in team-selection screen because team data is not being loaded into database.

### Problem Identified
- Backend logs show: "Found 0 teams" when querying user teams
- User `77d77471-1250-47e0-81ab-d4626595d63c` exists but has no team associations
- Root cause: `init.sql` only creates tables (schema), doesn't insert any data

### Work Completed This Session
1. ✅ Added context header displaying User/Role/Team across all screens
2. ✅ Implemented consistent back button strategy with context clearing
3. ✅ Changed login from "Coach Login" to generic "Football Home Login"
4. ✅ Updated practice form to use venue dropdown (instead of text input)
5. ✅ Fixed backend to accept `venue_id` instead of `location` string
6. ✅ Fixed navigation context clearing logic
7. ✅ Fixed venue dropdown data extraction (`response.data`)
8. ✅ Reorganized database files:
   - Created `database/teams/teams.sql` (full dataset)
   - Created `database/teams/teams-minimum.sql` (empty = use full)
9. ✅ Fixed init.sql directory issue (was created as directory by Docker)
10. ✅ Copied schema to `database/schema/init.sql`
11. ✅ Appended teams.sql to init.sql

### Next Steps (CRITICAL)
1. **Restart containers with fresh database**:
   ```bash
   docker compose down -v
   docker compose up -d
   # Wait for containers to start and database to initialize
   ```

2. **Verify teams loaded**:
   ```bash
   docker compose exec db psql -U lighthouse -d lighthouse -c "SELECT id, name FROM teams LIMIT 5;"
   ```

3. **Verify user-team associations**:
   ```bash
   docker compose exec db psql -U lighthouse -d lighthouse -c "SELECT * FROM team_coaches WHERE coach_id = '77d77471-1250-47e0-81ab-d4626595d63c';"
   docker compose exec db psql -U lighthouse -d lighthouse -c "SELECT * FROM team_players WHERE player_id = '77d77471-1250-47e0-81ab-d4626595d63c';"
   ```

4. **Test login flow**: Should now show teams in team-selection screen

### Database Loading Strategy (NEW STANDARD)
**Apply this pattern to ALL entity folders**:
- Each folder has 2 files: `{entity}.sql` (full) and `{entity}-minimum.sql` (minimal/test)
- If `-minimum.sql` is empty → load full `{entity}.sql`
- If `-minimum.sql` has data → load that instead
- `init.sql` = schema only (CREATE TABLE statements)
- Data loading handled by appending appropriate files to init.sql

### Files Modified
- `database/schema/init.sql` - Fixed (was directory), now contains schema + teams data
- `database/teams/teams.sql` - Created (combined 01-lighthouse + 02-apsl)
- `database/teams/teams-minimum.sql` - Empty (triggers full load)
- `backend/src/controllers/EventController.cpp` - venue_id support
- `frontend/js/screens/practice-form.js` - venue dropdown, response.data extraction
- `frontend/js/screens/team-selection.js` - back button
- `frontend/js/navigation.js` - context clearing, header updates
- `frontend/index.html` - context header HTML
- `frontend/css/main.css` - context header styles, back button styles
- `frontend/js/screens/role-selection.js` - context passing
- `frontend/js/screens/login.js` - generic title

### Commits
- 603823a - "Add context header, fix back button navigation, update practice form to use venue dropdown"

---

**Last Updated**: November 24, 2025
**Next Computer**: Continue from "Restart containers with fresh database"
**Status**: Database schema ready, need to load and verify data
