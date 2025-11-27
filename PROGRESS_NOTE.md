# Football Home - Object-Oriented Architecture Progress

## 🎯 Current Status (Nov 27, 2025)
**Database Performance Optimization** - Completed comprehensive verbose logging system and identified major bottleneck: venues table (68 venues with large JSON) using slow INSERT instead of COPY format. Created Python conversion script to migrate to COPY format for 80-100x performance improvement.

### Recent Session Summary (Nov 27, 2025)
1. **Verbose Logging System** ✅
   - Added `--progress=plain` to Docker builds for continuous output
   - Enhanced PostgreSQL logging: `log_min_duration_statement=0`, `log_line_prefix`
   - Fixed log pattern matching to capture actual PostgreSQL format
   - Added heartbeat mechanism showing elapsed time during initialization
   - Created comprehensive PERFORMANCE.md documentation

2. **Performance Bottleneck Identified** 🔍
   - Database declares "ready" but continues INSERT operations in background
   - Venues table: 11,586 lines, 68 records with massive JSON fields (photos, hours, etc)
   - Using slow INSERT instead of COPY format (80-100x slower)
   - Login works early because jbreslin user inserted first, but thousands of venue rows still loading

3. **Files Missing COPY Format** ❌
   - `02-venues.sql` - **MAJOR bottleneck** (11,586 lines, complex JSON)
   - `08a-users-manual.sql` - Manual user accounts
   - `09-admins.sql` - Admin records
   - `10-coaches.sql` - Coach records
   - `12-team-coaches.sql` - Team-coach relationships
   - `13a-players-manual.sql` - Manual player records

4. **Solution Created** 📝
   - Python script: `database/scripts/convert-venues.py`
   - Handles complex nested JSON, escaped quotes, JSONB casting
   - Generates both INSERT (with ON CONFLICT) and COPY formats
   - Ready to test and deploy

### Next Steps
1. Run `python3 database/scripts/convert-venues.py` to convert venues
2. Backup and replace `02-venues.sql` with new version
3. Test with `./dev.sh` - should see ~100x faster venue loading
4. Consider creating COPY versions for other manual files if needed

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
**Last Updated**: November 17, 2025 (Evening Session)
**Current Work**: Player RSVP Feature - Practice creation/display working, RSVP screen needs debugging
**Status**: Practices create and display for coaches, need to verify RSVP screen shows practices

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