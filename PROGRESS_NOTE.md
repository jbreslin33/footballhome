# Football Home - Object-Oriented Architecture Progress

## 🎯 Current Status (Nov 18, 2025 - Evening Session)
**Player RSVP Feature - Navigation Flow Implementation**: Implemented full decision tree for all roles. Players now go through PracticeOptions screen before reaching RSVP screen. State machine transitions fixed but RSVP screen may still need debugging.

**CURRENT ISSUE**: Player flow through to RSVP screen - need to verify practices load correctly and buttons work.

## 🎯 Today's Session Progress (Nov 18, 2025)

### Morning/Afternoon Session ✅

1. **Fixed Player Events Button Navigation**:
   - Problem: State machine changed state but didn't trigger navigation
   - Solution: Added `navigateToScreen()` call in BaseRoleStateMachine.selectingEventType.enter()
   - Added self-transition for NAVIGATE_TO_EVENTS to allow re-clicking
   - **Commit**: 78590a5

2. **Fixed Button Event Listeners**:
   - Problem: PracticeRSVPScreen buttons not working (setupForm never called)
   - Solution: Added `this.setupForm()` call in onEnter()
   - Added `goBack()` method to BaseRoleStateMachine
   - **Commit**: 78590a5

3. **Fixed Team Context Propagation**:
   - Problem: teamContext was null when navigating to screens
   - Solution: DashboardScreen now extracts teamContext from data.teamContext OR data.roleSelection.roleData
   - Updates role state machine immediately in onEnter()
   - **Commits**: 92db4a8

### Evening Session ✅

4. **Implemented Full Decision Tree for All Roles**:
   - Changed architecture: ALL roles see decision screens (not just coaches)
   - Players now see PracticeOptions screen with RSVP button only
   - Coaches see PracticeOptions with both Manage and RSVP buttons
   - Makes entire flow visible and testable during development
   - **Commit**: 92db4a8

5. **Updated Player Navigation Flow**:
   - **Before**: Dashboard → Events → Practices → ~~skip~~ → PracticeRSVP
   - **After**: Dashboard → Events → Practices → **PracticeOptions** → PracticeRSVP
   - PlayerStateMachine now routes to practiceOptions (not direct to RSVP)
   - PracticeOptionsScreen dynamically shows cards based on roleType
   - **Commit**: 92db4a8

6. **Fixed State Machine Transitions**:
   - Problem: PlayerStateMachine didn't have practiceOptions state
   - Solution: Added practiceOptions state with RSVP_SELECTED transition
   - Matches CoachStateMachine pattern for consistency
   - Fixed "No transition for event RSVP_SELECTED in state navigating" error
   - **Commit**: eb15f6e

### Files Modified Today 📝
- `frontend/js/core/BaseRoleStateMachine.js` - Navigation, goBack(), teamContext updates
- `frontend/js/roles/PlayerStateMachine.js` - practiceOptions state, routing changes
- `frontend/js/screens/DashboardScreen.js` - Team context extraction and propagation
- `frontend/js/screens/PracticeOptionsScreen.js` - Dynamic rendering for all roles
- `frontend/js/screens/PracticeRSVPScreen.js` - setupForm() call, error handling

## ✅ Major Accomplishments

### 1. Complete Architecture Overhaul
- **Object-oriented screen-based system** with ScreenManager
- **Multiple state machines** for app, screens, and components
- **Fixed original navigation issue**: "when you click back to roles or back browser button it logs you out"

### 2. Core Components Built
- **ScreenManager.js**: Global navigation controller with state machine
- **Screen.js**: Base class for all screens with lifecycle management
- **StateMachine.js**: Enhanced with enter/execute/exit pattern
- **LoginScreen.js**: Full OOP implementation with state machine
- **RoleSwitchboardScreen.js**: Role selection with navigation
- **DashboardScreen.js**: User dashboard implementation

### 3. Enhanced StateMachine Pattern
- **New pattern**: enter/execute/exit functions for each state
- **Backward compatibility**: Still supports legacy onEntry/onExit
- **Proper state transitions**: Fixed undefined logging issues
- **Error handling**: Added proper ERROR transitions

### 4. Navigation System
- **Event-driven navigation**: Screens emit events to ScreenManager
- **Browser history integration**: Proper back/forward button support
- **Authentication aware**: Prevents logout on navigation
- **State preservation**: Maintains user context across navigation

### 5. Production Ready
- **Clean logging**: Removed verbose debug output
- **Error handling**: Preserved essential error reporting
- **Performance**: Optimized event dispatching and state management
- **Docker integration**: Enhanced build process with cache-busting

## 🔧 Technical Architecture

### State Machine Hierarchy
```
App StateMachine (top-level)
├── initializing → running → error
└── ScreenManager StateMachine
    ├── login → roleSwitchboard → dashboard
    └── Individual Screen StateMachines
        ├── LoginScreen: idle → validating → success/error
        ├── RoleSwitchboardScreen: loading → ready → selecting → navigating
        └── DashboardScreen: loading → ready → error
```

### Event Flow
```
Screen Action → Screen StateMachine → Screen.navigateTo() 
→ Custom Event → ScreenManager Listener → ScreenManager.navigateTo() 
→ ScreenManager StateMachine → Screen Lifecycle (exit/enter)
```

### Browser History Integration
- **History API**: Uses pushState/replaceState for navigation
- **Back button handling**: Prevents logout, maintains app state
- **Deep linking**: Supports direct navigation to screens
- **Authentication preservation**: User stays logged in during navigation

## 🏗️ Current Status

### ✅ Completed Tasks
1. **Fix AuthService.getUserRoles method** - Added missing API method
2. **Add ERROR transition to RoleSwitchboard state machine** - Proper error handling
3. **Fix undefined state transition logging** - Clean state machine callbacks
4. **Test back button functionality** - Enhanced browser history integration
5. **Production cleanup** - Removed debug logging, kept essential errors

### 📋 Remaining Tasks
1. **Demo enter/execute/exit state pattern** - Show examples of new StateMachine features

## 🧪 Testing Status

### ✅ Working Features
- **Login flow**: Email/password → role selection → dashboard
- **Role switching**: Multiple roles supported with proper navigation
- **Screen transitions**: Smooth navigation with proper lifecycle
- **Error handling**: API failures handled gracefully
- **Authentication**: Token-based auth with user context preservation

### 🧪 Needs Testing
- **Back button comprehensive testing**: Verify all navigation scenarios
- **Deep linking**: Test direct URL access to screens
- **Error scenarios**: Test network failures and edge cases

## 🔧 Files Modified/Created

### New Architecture Files
- `frontend/js/core/ScreenManager.js` - Navigation controller
- `frontend/js/core/Screen.js` - Base screen class
- `frontend/js/screens/LoginScreen.js` - Login implementation
- `frontend/js/screens/RoleSwitchboardScreen.js` - Role selection
- `frontend/js/screens/DashboardScreen.js` - Dashboard implementation

### Enhanced Files
- `frontend/js/core/StateMachine.js` - Added enter/execute/exit pattern
- `frontend/js/services/AuthService.js` - Added getUserRoles method
- `frontend/js/App.js` - Complete rewrite with state machine
- `start.sh` - Enhanced with --no-cache for development

### Backup Files
- `frontend/js/App_old.js` - Original implementation preserved

## 🚀 Next Session Action Items

### Immediate Next Steps
1. **Test back button thoroughly**:
   ```bash
   # Open browser, login, navigate through screens
   # Test browser back button at each step
   # Verify no logout occurs, proper navigation maintained
   ```

2. **Demo enhanced StateMachine pattern**:
   ```javascript
   // Show examples of new enter/execute/exit functions
   // Convert existing screens to use new pattern
   // Document best practices
   ```

### Future Enhancements
- **Add more screens** (Profile, Settings, etc.)
- **Implement PWA features** (offline support, notifications)
- **Add testing framework** (Jest/Cypress)
- **Performance optimization** (lazy loading, code splitting)

## 🔍 Key Code Locations

### Entry Point
- `frontend/index.html` - App initialization
- `frontend/js/App.js` - Main application class

### Navigation System
- `frontend/js/core/ScreenManager.js:82` - navigateTo method
- `frontend/js/core/ScreenManager.js:175` - Browser history handling
- `frontend/js/core/Screen.js:140` - Event emission to parent

### State Machines
- `frontend/js/core/StateMachine.js:66` - Enhanced send method with enter/exit
- `frontend/js/core/StateMachine.js:52` - New execute method

### Authentication Integration
- `frontend/js/services/AuthService.js:166` - getUserRoles method
- `frontend/js/core/ScreenManager.js` - AuthService integration for history

## 🐛 Known Issues/Considerations
- **None currently** - all major issues resolved
- **Performance**: Consider lazy loading for large screen count
- **SEO**: May need server-side rendering for public pages

## � Development Notes
- **Docker builds**: Use `--no-cache` flag is now default in start.sh
- **Console output**: Much cleaner in production, errors still logged
- **State debugging**: Can be re-enabled by changing logging levels
- **Event timing**: Uses setTimeout(0) for proper event listener setup

---
**Last Updated**: November 18, 2025 (Evening)
**Current Work**: Player RSVP Feature - Navigation flow complete, need to verify RSVP screen loads practices
**Status**: Full decision tree implemented ✅, State transitions fixed ✅, Need to test end-to-end 🔴
**Next Action**: Test player flow all the way through and verify PracticeRSVP screen works

## 🎯 Session Handoff (Nov 18, 2025 - Evening)

### What's Working ✅
1. **Player Events Button**: Navigates to EventTypeSelection ✅
2. **EventTypeSelection → PracticeOptions**: Players see options screen ✅  
3. **PracticeOptions Rendering**: Dynamically shows RSVP only for players, both options for coaches ✅
4. **State Machine Transitions**: practiceOptions state with RSVP_SELECTED handling ✅
5. **Team Context**: Properly captured and propagated through navigation ✅
6. **Back Buttons**: Event listeners attached via setupForm() ✅

### What Needs Testing 🔴
1. **PracticeRSVP Screen**: Does it load practices correctly?
   - teamContext should now be passed properly
   - API call: GET /api/events/:teamId
   - Filtering logic for future practices
   - RSVP button functionality
2. **End-to-End Player Flow**: Complete journey from login to RSVP
3. **Error Handling**: What happens if no practices exist?

### Current Architecture 🏗️

**Player Flow**:
```
Login → Role Selection → Team Selection → Dashboard
  ↓
Events Button (roleStateMachine.send('NAVIGATE_TO_EVENTS'))
  ↓
EventTypeSelection Screen (shows Practices card)
  ↓
Click Practices (roleStateMachine.send('EVENT_TYPE_SELECTED', 'practice'))
  ↓
PlayerStateMachine.handleEventType → send('NAVIGATE_TO_OPTIONS')
  ↓
PlayerStateMachine.practiceOptions state → navigateToScreen('practiceOptions')
  ↓
PracticeOptions Screen (renders RSVP card only for players)
  ↓
Click "View & RSVP" → send('OPTION_SELECTED', 'rsvp')
  ↓
PracticeOptionsScreen.navigate() → roleStateMachine.send('RSVP_SELECTED')
  ↓
PlayerStateMachine.viewingPractices state → navigateToScreen('practiceRSVP')
  ↓
PracticeRSVP Screen (should load practices and show RSVP buttons)
```

**Coach Flow** (for comparison):
```
Same as player until PracticeOptions screen
  ↓
PracticeOptions Screen (renders both Manage and RSVP cards)
  ↓
Click "Manage" → CoachStateMachine.managingPractices → ManagePractices Screen
  OR
Click "View & RSVP" → CoachStateMachine.rsvpingToPractices → PracticeRSVP Screen
```

### Debug Steps for Next Session 🔍

1. **Open browser console** and hard refresh (Ctrl+Shift+R)
2. **Login as player** (jbreslin@footballhome.org / password)
3. **Follow the flow**:
   - Select Player role
   - Select Lighthouse 1893 SC team
   - Click Events button on dashboard
   - Click Practices card on EventTypeSelection
   - Click "View & RSVP" button on PracticeOptions
4. **Check console for**:
   - TeamContext values at each step
   - API call to /api/events/:teamId
   - Practice filtering logic output
   - Any errors or null values
5. **Verify PracticeRSVP screen**:
   - Does it show "Loading practices..." initially?
   - Does it call the API with correct teamId?
   - Does it show practices or "No upcoming practices"?
   - Do RSVP buttons work?

### Known Issues / Technical Debt 📋
- PracticeRSVP filtering may need adjustment (date parsing, type matching)
- Error messages need to be more user-friendly
- Back button navigation through all screens needs comprehensive testing
- Consider adding loading spinners for better UX

### Key Code Locations 📍

**Player State Machine**:
- `frontend/js/roles/PlayerStateMachine.js:26-48` - practiceOptions and viewingPractices states
- `frontend/js/roles/PlayerStateMachine.js:93-105` - handleEventType with NAVIGATE_TO_OPTIONS

**Navigation & Context**:
- `frontend/js/screens/DashboardScreen.js:111-150` - Team context extraction and role state machine update
- `frontend/js/core/BaseRoleStateMachine.js:130-139` - buildContext() method
- `frontend/js/core/BaseRoleStateMachine.js:176-194` - navigateToScreen() method

**Practice Screens**:
- `frontend/js/screens/PracticeOptionsScreen.js:38-97` - Dynamic rendering based on roleType
- `frontend/js/screens/PracticeRSVPScreen.js:73-94` - onEnter with teamContext validation
- `frontend/js/screens/PracticeRSVPScreen.js:96-123` - loadPractices() method

### Environment Info 💻
- **Docker**: `./start.sh` or `docker compose restart frontend`
- **Database**: PostgreSQL, 2 test practices should exist
- **Test Account**: jbreslin@footballhome.org / password (admin + player roles)
- **Test Team**: Lighthouse 1893 SC (id: d37eb44b-8e47-0005-9060-f0cbe96fe089)
- **Backend**: GET /api/events/:teamId returns {id, title, event_date, duration_minutes, location, type}

---

## 🎯 Session Handoff (Nov 18, 2025)

### What's Working ✅
1. **Practice Creation**: Coaches can create practices via ManagePracticesScreen
2. **Practice Display (Coach)**: Practices show correctly in ManagePracticesScreen sidebar
3. **Screen Visibility**: Only one screen visible at a time (fixed bug)
4. **Data Contract**: Backend returns `event_date`, `duration_minutes`, `type` consistently
5. **Database**: 2 test practices exist and are queryable
6. **Navigation**: Player routing goes to PracticeRSVP (not ManagePractices) ✅

### What's Broken 🔴
1. **PracticeRSVPScreen**: Shows "No upcoming practices" for both player and coach
   - Same API endpoint as ManagePracticesScreen (which works)
   - Debug logging added but not yet tested
   - Likely issue: Date parsing or filtering logic in loadPractices()

### Immediate Next Steps 🚀
1. **Rebuild and Test**:
   ```bash
   ./start.sh  # Rebuild frontend with new debug logs
   # Hard refresh browser (Ctrl+Shift+R)
   # Login as player → Events → Practices
   # Check console for debug output
   ```

2. **Compare Working vs Broken**:
   - ManagePracticesScreen.loadPractices() (lines 132-180) ← WORKS
   - PracticeRSVPScreen.loadPractices() (lines 75-105) ← BROKEN
   - Look for differences in:
     - Date parsing: `new Date(event.event_date)`
     - Type filtering: `event.type === 'training'`
     - Time comparison: `eventDateTime > now`

3. **Fix and Verify**:
   - Once practices display in PracticeRSVPScreen
   - Test RSVP button clicks
   - Verify POST /api/events/:eventId/rsvp endpoint
   - Check RSVP saves to event_rsvps table

### Debug Checklist 📋
- [x] Coach can create practice
- [x] Practice appears in ManagePracticesScreen (coach)
- [x] Player routing goes to PracticeRSVP screen
- [x] Screen visibility bug fixed
- [ ] PracticeRSVPScreen shows practices ← **CURRENT BLOCKER**
- [ ] RSVP buttons functional
- [ ] RSVP saves correctly
- [ ] RSVP status displays

### Key File Locations 📍
**Problem Area**:
- `frontend/js/screens/PracticeRSVPScreen.js:75-105` - loadPractices() method with debug logs
- `frontend/js/screens/ManagePracticesScreen.js:132-180` - Working reference implementation

**Backend**:
- `backend/src/controllers/EventController.cpp:157-210` - GET /api/events/:teamId endpoint
- Returns: `{id, title, event_date, duration_minutes, location, type}`

**Database**:
- Table: `events` (has 2 test practices)
- Query to verify data:
  ```sql
  SELECT id, title, event_date, duration_minutes, event_type_id 
  FROM events 
  WHERE event_type_id = (SELECT id FROM event_types WHERE name = 'training')
  ORDER BY event_date;
  ```

### Environment Info 💻
- **Docker**: Use `./start.sh` to rebuild (includes --no-cache)
- **Database**: PostgreSQL via docker-compose, pgAdmin on localhost:5050
- **Frontend**: Nginx serving on localhost:80
- **Backend**: C++ service on localhost:8080
- **Test Account**: jbreslin@footballhome.org / password (admin + player roles)
- **Test Team**: Lighthouse 1893 SC

---

## 🎯 Evening Session Progress (Nov 17, 2025)

### Fixed Major Issues ✅

1. **Screen Visibility Bug**:
   - **Problem**: Multiple screens visible simultaneously (managePractices AND practiceRSVP both had display:block)
   - **Root Cause**: ScreenManager.enterScreen() wasn't hiding previous screens
   - **Fix**: Added loop to hide all other screens before showing new one
   - **File**: `frontend/js/core/ScreenManager.js:147-166`

2. **Backend/Frontend Data Contract Mismatch**:
   - **Problem**: Backend returned `date`/`duration` but frontend expected `event_date`/`duration_minutes`
   - **Fix**: Updated EventController.cpp to return correct field names
   - **Impact**: Practices now load and display correctly
   - **Files**: 
     - `backend/src/controllers/EventController.cpp` (lines 189, 192, 198)
     - `frontend/js/screens/ManagePracticesScreen.js` (lines 144, 147, 175)

3. **Practice Creation Failing**:
   - **Problem**: Database error - `location` column doesn't exist in practices table
   - **Root Cause**: practices table schema has no location column (events table has venue_id instead)
   - **Fix**: Removed location column from INSERT queries
   - **File**: `backend/src/controllers/EventController.cpp:123-134`

4. **Practices Display in ManagePracticesScreen**:
   - **Status**: ✅ Working! Practices now show in right sidebar
   - **Verified**: Coach can create practice and see it in "Upcoming Practices" list

### Current Status 🔴

**RSVP Screen Issue**:
- PracticeRSVPScreen shows "No upcoming practices" for both player and coach
- ManagePracticesScreen successfully shows practices (same API call)
- Added debug logging to PracticeRSVPScreen.loadPractices() but not yet deployed/tested
- **Next Step**: Rebuild frontend and check console logs to see filtering logic

### Files Modified Tonight

**Backend**:
- `backend/src/controllers/EventController.cpp`:
  - Fixed field names: event_date, duration_minutes (not date/duration)
  - Removed location column from practices INSERT
  - Added debug logging for JSON responses

**Frontend**:
- `frontend/js/core/ScreenManager.js`:
  - Fixed enterScreen() to hide all other screens first
- `frontend/js/screens/ManagePracticesScreen.js`:
  - Updated to use event_date and duration_minutes
  - Added debug logging for practice filtering
- `frontend/js/screens/PracticeRSVPScreen.js`:
  - Added debug logging (not yet tested)

### Database State 📊
```sql
SELECT e.id, e.title, e.event_date, et.name as event_type 
FROM events e 
JOIN event_types et ON e.event_type_id = et.id 
ORDER BY e.created_at DESC LIMIT 5;

-- Results: 2 practices exist
-- Practice Session | 2025-11-18 08:00:00 | training
-- Practice Session | 2025-11-21 08:08:00 | training
```

### Next Session Action Plan 🚀

1. **Debug PracticeRSVPScreen** (PRIORITY):
   ```bash
   # Rebuild if needed: ./start.sh
   # Hard refresh browser (Ctrl+Shift+R)
   # Login as PLAYER → Events → Practices
   # Check console for new debug logs:
   #   - Raw API response
   #   - Each event's filtering decision
   #   - Date comparisons (eventDateTime > now?)
   #   - Type matching (type === 'training'?)
   ```

2. **Verify Data Contract Consistency**:
   - Check if PracticeRSVPScreen and ManagePracticesScreen use same field names
   - Confirm both use `event_date`, `duration_minutes`, `type`
   - Ensure date parsing logic identical

3. **Implement RSVP Functionality**:
   - Once practices display, wire up RSVP buttons
   - Test POST /api/events/:eventId/rsvp endpoint
   - Add toast notifications for success/error
   - Update button states based on current RSVP status

4. **Location Field Decision**:
   - Frontend sends location string but backend doesn't store it
   - Options:
     a) Map location string to venue_id (requires venue lookup/creation)
     b) Add location TEXT column to practices table
     c) Ignore location for now (current approach)
   - **Recommendation**: Add location column to practices table for simplicity

### Testing Checklist 📋
- [x] Coach can create practice
- [x] Practice saves to database
- [x] Practice appears in ManagePracticesScreen upcoming list (coach)
- [x] Player routing goes to PracticeRSVP screen (not ManagePractices)
- [x] Screen visibility bug fixed (only one screen visible at a time)
- [ ] PracticeRSVPScreen shows practices for player ← **NEXT**
- [ ] PracticeRSVPScreen shows practices for coach (via RSVP option)
- [ ] RSVP buttons functional
- [ ] RSVP saves to database
- [ ] RSVP status displays correctly

### Code Locations 📍

**Screen Management**:
- `frontend/js/core/ScreenManager.js:147-166` - Screen visibility fix
- `frontend/js/core/Screen.js` - Base screen class

**Practice Screens**:
- `frontend/js/screens/ManagePracticesScreen.js:132-180` - Practice loading/display (coach)
- `frontend/js/screens/PracticeRSVPScreen.js:75-105` - Practice loading/display (player/coach RSVP)
- `frontend/js/screens/PracticeOptionsScreen.js` - Coach choice: Manage vs RSVP

**Backend**:
- `backend/src/controllers/EventController.cpp:40-155` - POST /api/events (create practice)
- `backend/src/controllers/EventController.cpp:157-210` - GET /api/events/:teamId (list practices)

**Database**:
- `database/schema/init.sql:665-680` - events table (has venue_id)
- `database/schema/init.sql:681-693` - practices table (no location column)
- `database/schema/init.sql:957-965` - event_types table (training = practices)

---

## 🏁 Previous Session Summary (Nov 17, 2025 - Afternoon)

### Player RSVP Feature Implementation

#### ✅ Completed
1. **Database Schema**: Created `event_rsvps` table with proper constraints
   - Columns: id, event_id, player_id, status (attending/not_attending/maybe), notes, timestamps
   - Unique constraint on (event_id, player_id)
   - Indexes for performance

2. **Backend API Endpoints**: 
   - `POST /api/events/:eventId/rsvp` - Create/update RSVP (upsert logic)
   - `GET /api/events/:eventId/rsvps` - Get RSVPs with player names (JOIN with users)
   - Fixed compilation errors (HttpStatus enum, Database API usage)

3. **Frontend Screens Created**:
   - `PracticeRSVPScreen.js` - Player view with RSVP buttons (Attending/Maybe/Can't Attend)
   - `PracticeOptionsScreen.js` - Coach choice between Manage vs RSVP
   - Updated `EventTypeSelectionScreen.js` - Role-based text and routing

4. **Navigation Flow Redesigned**:
   - **Players**: Dashboard → Events → Practices → RSVP Screen (direct)
   - **Coaches**: Dashboard → Events → Practices → Options (Manage or RSVP) → Selected Screen
   - Added Events button to player dashboard (previously coach-only)

5. **Test Data Setup**:
   - James Breslin configured as both admin and player on Lighthouse 1893 SC
   - Practices table cleared for clean testing
   - Coach can create practices, player can RSVP to them

#### 🔧 Current Work - Debugging Navigation
**Issue**: Players being routed to coach ManagePracticesScreen instead of PracticeRSVPScreen

**Debugging Added**:
- Enhanced logging in `EventTypeSelectionScreen.onEnter()` - logs roleType on entry
- Enhanced logging in `EventTypeSelectionScreen.handleEventTypeSelection()` - logs routing decision
- Added visual console markers:
  - `✅✅✅ PLAYER RSVP SCREEN ENTERED ✅✅✅` in PracticeRSVPScreen.onEnter()
  - `🏈🏈🏈 COACH MANAGE SCREEN ENTERED 🏈🏈🏈` in ManagePracticesScreen.onEnter()
- Enhanced DashboardScreen.onEnter() to clear previous state and log role setting

**Root Cause Investigation**:
- Checking if roleType is preserved through navigation chain
- Verifying DashboardScreen → EventTypeSelectionScreen data passing
- Ensuring screen registration in App.js is correct

#### 📝 Files Modified This Session
**Backend**:
- `/database/schema/init.sql` - Added event_rsvps table
- `/backend/src/controllers/EventController.h` - Added RSVP method declarations
- `/backend/src/controllers/EventController.cpp` - Implemented RSVP endpoints with proper API usage

**Frontend Screens**:
- `/frontend/js/screens/PracticeRSVPScreen.js` - NEW: Player RSVP interface
- `/frontend/js/screens/PracticeOptionsScreen.js` - NEW: Coach choose Manage vs RSVP
- `/frontend/js/screens/EventTypeSelectionScreen.js` - Updated with role-based content and routing
- `/frontend/js/screens/DashboardScreen.js` - Added player Events button, enhanced onEnter debugging
- `/frontend/js/screens/ManagePracticesScreen.js` - Added console marker for debugging

**Frontend Core**:
- `/frontend/js/App.js` - Registered practiceOptions and practiceRSVP screens
- `/frontend/index.html` - Added script tags for new screens

#### 🎯 Next Steps
1. **Debug roleType propagation**: Use console logs to trace where roleType gets lost/changed
2. **Test complete flow**:
   - Coach: Login → Coach → Lighthouse → Events → Practices → Options → Manage → Create practice
   - Coach: Back → RSVP → See practice and RSVP as coach
   - Player: Login → Player → Lighthouse → Events → Practices → See RSVP screen directly
   - Player: RSVP to practice → Verify toast notification and button state change
3. **Verify backend**: Confirm RSVP data saves to database correctly
4. **Clean up debug logging**: Remove excessive console.log statements once working

#### 🗂️ New File Structure
```
frontend/js/screens/
├── LoginScreen.js
├── RoleSwitchboardScreen.js
├── TeamSelectionScreen.js
├── DashboardScreen.js
├── EventTypeSelectionScreen.js
├── PracticeOptionsScreen.js ← NEW (coach choice screen)
├── ManagePracticesScreen.js (coach CRUD)
└── PracticeRSVPScreen.js ← NEW (player/coach RSVP)
```

#### 💡 Architecture Notes
- **Role-based routing**: EventTypeSelectionScreen checks roleType and routes accordingly
- **Screen reuse**: Both coaches and players can use PracticeRSVPScreen for attendance
- **Separation of concerns**: Manage (CRUD) separate from RSVP (attendance)
- **State preservation**: Critical that roleType flows through entire navigation chain

#### 🧪 Test Accounts
- **Admin/Player**: jbreslin@footballhome.org / password
- **Team**: Lighthouse 1893 SC (id: d37eb44b-8e47-0005-9060-f0cbe96fe089)
- **Database**: PostgreSQL, accessible via pgAdmin on localhost:5050

---

## 🏁 Previous Session Summary (Nov 15, 2025)
[Previous content remains unchanged...]