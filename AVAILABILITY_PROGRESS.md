# Player Availability System - Progress Note
## December 8, 2025

### ✅ COMPLETED: Full Player Availability Tracking System

#### Database Layer (DONE)
1. **Schema Tables**
   - `player_medical_status` - Track injuries, illness, concussion protocol
   - `player_academic_status` - Track GPA, eligibility, probation  
   - Both support granular flags: `available_for_practices`, `available_for_games`
   - Team scope: `affects_all_teams` (club-wide) or specific `team_id`
   - History tables: `player_medical_status_history`, `player_academic_status_history`
   - File: `database/data/02-schema-player-availability.sql`

2. **Views**
   - `v_active_medical_issues` - All unresolved medical issues
   - `v_active_academic_issues` - All unresolved academic issues
   - `v_player_availability` - Division-level summary (can_practice, can_play_games)
   - `v_team_player_availability` - Team-specific availability
   - File: `database/data/03-views-player-availability.sql`

3. **Sample Data** 
   - 3 medical issues created (ankle sprain, concussion, knee recovery)
   - 1 academic issue (probation: can practice, not play)
   - File: `database/data/51-sample-availability-data.sql`

#### Backend API (DONE)
Created `AvailabilityController` with 7 working endpoints:

**Medical Status:**
- `GET /api/players/:playerId/medical-status` - List all active medical issues
- `POST /api/players/:playerId/medical-status` - Create new medical status
- `POST /api/medical-status/:statusId/resolve` - Mark resolved

**Academic Status:**
- `GET /api/players/:playerId/academic-status` - List all active academic issues
- `POST /api/players/:playerId/academic-status` - Create new academic status
- `POST /api/academic-status/:statusId/resolve` - Mark resolved

**Combined:**
- `GET /api/players/:playerId/availability` - Overall summary

Files: `backend/src/controllers/AvailabilityController.{h,cpp}`

#### Testing (DONE)
- Backend rebuilt successfully ✅
- All 7 routes registered (total: 41 backend routes) ✅
- Tested availability endpoint - returns correct data ✅
- Sample player query working:
  ```json
  {
    "player_id": "30ce494f-868f-0006-f5a6-bb7294f48b55",
    "first_name": "Hassane",
    "last_name": "Abdellaoui", 
    "can_practice": true,
    "can_play_games": false,
    "medical_issues_count": 1,
    "academic_issues_count": 0
  }
  ```

#### Documentation (DONE)
- `PLAYER_AVAILABILITY_SYSTEM.md` - Complete system documentation

---

### 🔜 NEXT STEPS: Frontend UI Integration

#### Priority 1: Update Division Roster Screen
Location: `frontend/js/screens/DivisionRosterScreen.js`

**Add Availability Indicators:**
- Show icon next to each player name:
  - 🟢 Available for everything
  - 🟡 Practice only (can't play games)
  - 🔴 No activity allowed
  - 📚 Academic issue
  - 🏥 Medical issue

**Implementation:**
1. Modify player fetch to include availability data
2. Update player card HTML to show status icons
3. Add availability filter dropdown (All, Available for Games, Practice Only, Has Issues)
4. Color-code player cards based on status

#### Priority 2: Create Player Availability Modal
New file: `frontend/js/components/PlayerAvailabilityModal.js`

**Shows:**
- Player name and basic info
- All active medical issues (status, injury type, dates, notes)
- All active academic issues (GPA, status, dates, notes)
- Overall availability summary
- "Update Status" button (coaches only)

**Triggered by:** Clicking on player card in Division Roster

#### Priority 3: Create Update Availability Form  
New file: `frontend/js/components/UpdateAvailabilityForm.js`

**Medical Form Fields:**
- Status dropdown (injured, recovering, ill, concussion_protocol)
- Injury type (free text or dropdown)
- Severity (minor, moderate, severe)
- Available for practices? (checkbox)
- Available for games? (checkbox)
- Injury date, expected return date
- Affects all teams? (checkbox) - if no, show team selector
- Notes (textarea)

**Academic Form Fields:**
- Status (eligible, ineligible, probation, restricted)
- GPA, Required GPA
- Available for practices? (checkbox)
- Available for games? (checkbox)
- Review date, Academic term
- Affects all teams? (checkbox)
- Notes (textarea)

**Submit:** POST to API endpoint, refresh player data

---

### 🎯 User Flow
1. Coach logs in → Division Menu → Division Management → Division Roster
2. Sees list of 115 players with availability icons
3. Clicks player with 🟡 icon → Modal opens showing ankle sprain details
4. Clicks "Update Status" → Form appears
5. Updates expected return date → Submits
6. Modal refreshes → Shows updated info
7. Can also mark issue as "Resolved" → Removes from active list

---

### 📊 Current System State
- **Database:** Running with all availability tables/views/sample data
- **Backend:** 41 routes total (7 new availability routes working)
- **Frontend:** Division Roster showing 115 players (no availability UI yet)
- **Sample Data:** 3 medical + 1 academic issue for testing
- **Git Commits:** 
  - `34c6573` - Documentation
  - `5f5872b` - Schema and views
  - `(pending)` - Backend controller

### 🔧 Files Ready for Next Session
- `frontend/js/screens/DivisionRosterScreen.js` - Add availability icons
- `frontend/js/components/PlayerAvailabilityModal.js` - CREATE NEW
- `frontend/js/components/UpdateAvailabilityForm.js` - CREATE NEW
- `frontend/js/services/AvailabilityService.js` - CREATE NEW (API calls)
- `frontend/index.html` - Add new script imports

### 💡 Design Notes
- **Colors:** Green=available, Yellow=practice only, Red=no activity
- **Icons:** 🟢🟡🔴 for medical, 📚 for academic
- **Permissions:** For now, any coach can update any player (refine later)
- **Mobile:** Keep forms simple, single column layout
- **Error Handling:** Show user-friendly messages if API calls fail

---

### 📝 Additional Context
- Players can have MULTIPLE concurrent issues (e.g., ankle sprain + academic probation)
- Each issue evaluated independently: player unavailable if ANY issue blocks them
- Team scope allows injury to affect one team but not another
- History tables capture all changes for audit/compliance
- Medical clearance tracking for return-to-play protocols

### ⚠️ Known Issues / Future Work
- Need proper authentication/session management (currently uses first user as placeholder)
- Need coach permission checks (verify coach has access to player's team)
- Need notification system (alert when player cleared, deadline approaching)
- Need reporting (injury trends, academic monitoring)
- Need mobile responsiveness testing
- Data cleanup still pending (70-range SQL files for duplicates)
