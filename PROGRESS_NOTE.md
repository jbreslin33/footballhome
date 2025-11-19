# Football Home - Frontend Rebuild Progress# Football Home - Object-Oriented Architecture Progress



## 🎯 Current Status (Nov 19, 2025)## 🎯 Current Status (Nov 18, 2025 - Evening Session)

**Complete Frontend Rebuild - Clean Architecture Implementation**: Rebuilt entire frontend from scratch with production-ready OOP architecture. Login working, role selection implemented with Coach-only button.**Player RSVP Feature - Navigation Flow Implementation**: Implemented full decision tree for all roles. Players now go through PracticeOptions screen before reaching RSVP screen. State machine transitions fixed but RSVP screen may still need debugging.



**WHAT'S WORKING**: **CURRENT ISSUE**: Player flow through to RSVP screen - need to verify practices load correctly and buttons work.

- ✅ Login with real backend authentication

- ✅ Role selection screen (Coach button only for now)## 🎯 Today's Session Progress (Nov 18, 2025)

- ✅ Login history tracking in database

- ✅ Frontend-backend integration working### Morning/Afternoon Session ✅



**NEXT STEPS**: 1. **Fixed Player Events Button Navigation**:

- Implement backend `/api/user/teams` endpoint (currently returns 404)   - Problem: State machine changed state but didn't trigger navigation

- Build practice management endpoints   - Solution: Added `navigateToScreen()` call in BaseRoleStateMachine.selectingEventType.enter()

- Test full coach flow end-to-end   - Added self-transition for NAVIGATE_TO_EVENTS to allow re-clicking

   - **Commit**: 78590a5

---

2. **Fixed Button Event Listeners**:

## 🏗️ Architecture Overview   - Problem: PracticeRSVPScreen buttons not working (setupForm never called)

   - Solution: Added `this.setupForm()` call in onEnter()

### Core Design Principles   - Added `goBack()` method to BaseRoleStateMachine

1. **DOM Replacement Pattern**: Complete tear-down/rebuild on each screen transition to prevent duplicate event listeners   - **Commit**: 78590a5

2. **Class-Based OOP**: All screens extend base `Screen` class with lifecycle methods

3. **State Machines**: `NavigationStateMachine` manages all navigation and global context3. **Fixed Team Context Propagation**:

4. **No Caching**: Always fetch fresh data from backend   - Problem: teamContext was null when navigating to screens

5. **Production-Ready**: No dev shortcuts, no mock data, real backend integration from day one   - Solution: DashboardScreen now extracts teamContext from data.teamContext OR data.roleSelection.roleData

   - Updates role state machine immediately in onEnter()

### Screen Lifecycle   - **Commits**: 92db4a8

```

ScreenManager.show(name, params)### Evening Session ✅

  ↓

1. Call currentScreen.onExit() - cleanup old screen4. **Implemented Full Decision Tree for All Roles**:

2. Clear container: container.innerHTML = ''   - Changed architecture: ALL roles see decision screens (not just coaches)

3. Call newScreen.render() - create new DOM   - Players now see PracticeOptions screen with RSVP button only

4. Append to container   - Coaches see PracticeOptions with both Manage and RSVP buttons

5. Call newScreen.onEnter(params) - initialize new screen   - Makes entire flow visible and testable during development

```   - **Commit**: 92db4a8



### Navigation Flow (Coach)5. **Updated Player Navigation Flow**:

```   - **Before**: Dashboard → Events → Practices → ~~skip~~ → PracticeRSVP

Login → Role Selection → Team Selection → Practice Options → Management/RSVP   - **After**: Dashboard → Events → Practices → **PracticeOptions** → PracticeRSVP

```   - PlayerStateMachine now routes to practiceOptions (not direct to RSVP)

   - PracticeOptionsScreen dynamically shows cards based on roleType

### Event Handling Strategy   - **Commit**: 92db4a8

- **Event Delegation**: Attach listeners to screen root element (`this.element.addEventListener`)

- **Cleanup**: DOM replacement ensures all listeners automatically removed6. **Fixed State Machine Transitions**:

- **Guards**: `isMounted` flag prevents stale async results   - Problem: PlayerStateMachine didn't have practiceOptions state

- **Throttling**: `isTransitioning` flag prevents rapid navigation clicks   - Solution: Added practiceOptions state with RSVP_SELECTED transition

   - Matches CoachStateMachine pattern for consistency

---   - Fixed "No transition for event RSVP_SELECTED in state navigating" error

   - **Commit**: eb15f6e

## 📂 Current File Structure

### Files Modified Today 📝

### Frontend (12 clean files)- `frontend/js/core/BaseRoleStateMachine.js` - Navigation, goBack(), teamContext updates

```- `frontend/js/roles/PlayerStateMachine.js` - practiceOptions state, routing changes

frontend/- `frontend/js/screens/DashboardScreen.js` - Team context extraction and propagation

├── index.html                           # HTML shell loading all scripts- `frontend/js/screens/PracticeOptionsScreen.js` - Dynamic rendering for all roles

├── css/- `frontend/js/screens/PracticeRSVPScreen.js` - setupForm() call, error handling

│   ├── main.css                         # Global styles

│   └── dashboard.css                    # Dashboard-specific styles## ✅ Major Accomplishments

└── js/

    ├── auth.js                          # Auth service with login/logout### 1. Complete Architecture Overhaul

    ├── screen-base.js                   # Base Screen class- **Object-oriented screen-based system** with ScreenManager

    ├── screen-manager.js                # Screen orchestration- **Multiple state machines** for app, screens, and components

    ├── navigation.js                    # NavigationStateMachine- **Fixed original navigation issue**: "when you click back to roles or back browser button it logs you out"

    ├── app.js                           # Bootstrap

    └── screens/### 2. Core Components Built

        ├── login.js                     # Email/password form- **ScreenManager.js**: Global navigation controller with state machine

        ├── role-selection.js            # Role choice (Coach button only) ← NEW- **Screen.js**: Base class for all screens with lifecycle management

        ├── team-selection.js            # Team picker- **StateMachine.js**: Enhanced with enter/execute/exit pattern

        ├── practice-options.js          # Manage vs RSVP choice- **LoginScreen.js**: Full OOP implementation with state machine

        ├── practice-management.js       # List practices, Add/Edit/Delete- **RoleSwitchboardScreen.js**: Role selection with navigation

        ├── practice-form.js             # Create/edit practice form- **DashboardScreen.js**: User dashboard implementation

        └── practice-list.js             # RSVP view

```### 3. Enhanced StateMachine Pattern

- **New pattern**: enter/execute/exit functions for each state

### Backend- **Backward compatibility**: Still supports legacy onEntry/onExit

```- **Proper state transitions**: Fixed undefined logging issues

backend/src/- **Error handling**: Added proper ERROR transitions

├── controllers/

│   ├── AuthController.cpp/h             # Login, logout, /me endpoints### 4. Navigation System

│   ├── EventController.cpp/h            # Practice CRUD (needs work)- **Event-driven navigation**: Screens emit events to ScreenManager

│   └── TeamController.cpp/h             # Team management (needs /api/user/teams)- **Browser history integration**: Proper back/forward button support

└── models/- **Authentication aware**: Prevents logout on navigation

    ├── User.cpp/h                       # User authentication- **State preservation**: Maintains user context across navigation

    └── Team.cpp/h                       # Team data

```### 5. Production Ready

- **Clean logging**: Removed verbose debug output

### Database- **Error handling**: Preserved essential error reporting

```- **Performance**: Optimized event dispatching and state management

database/- **Docker integration**: Enhanced build process with cache-busting

├── schema/

│   ├── init.sql                         # Main schema## 🔧 Technical Architecture

│   └── login_history.sql                # Login tracking table ← NEW

└── apsl/### State Machine Hierarchy

    └── apsl-data.sql                    # Test data```

```App StateMachine (top-level)

├── initializing → running → error

---└── ScreenManager StateMachine

    ├── login → roleSwitchboard → dashboard

## 🔧 Implementation Details    └── Individual Screen StateMachines

        ├── LoginScreen: idle → validating → success/error

### 1. Authentication System        ├── RoleSwitchboardScreen: loading → ready → selecting → navigating

**Frontend: `auth.js`**        └── DashboardScreen: loading → ready → error

- `login(username, password)` - POST /api/auth/login with {email, password}```

- `logout()` - Clears localStorage

- `fetch(path, opts)` - Wrapper that adds Bearer token### Event Flow

- `isLoggedIn()` - Checks for token in localStorage```

Screen Action → Screen StateMachine → Screen.navigateTo() 

**Backend: `AuthController.cpp`**→ Custom Event → ScreenManager Listener → ScreenManager.navigateTo() 

- `handleLogin()` - Validates credentials, returns JWT token + user data→ ScreenManager StateMachine → Screen Lifecycle (exit/enter)

- Expects: `{email: "...", password: "..."}````

- Returns: `{success: true, token: "jwt_...", user: {...}}`

- **NEW**: Logs every login to `login_history` table (user_id, ip_address, user_agent, timestamp)### Browser History Integration

- **History API**: Uses pushState/replaceState for navigation

**Database: `login_history` table**- **Back button handling**: Prevents logout, maintains app state

```sql- **Deep linking**: Supports direct navigation to screens

CREATE TABLE login_history (- **Authentication preservation**: User stays logged in during navigation

    id SERIAL PRIMARY KEY,

    user_id UUID REFERENCES users(id),## 🏗️ Current Status

    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    ip_address VARCHAR(45),### ✅ Completed Tasks

    user_agent TEXT,1. **Fix AuthService.getUserRoles method** - Added missing API method

    success BOOLEAN DEFAULT true2. **Add ERROR transition to RoleSwitchboard state machine** - Proper error handling

);3. **Fix undefined state transition logging** - Clean state machine callbacks

```4. **Test back button functionality** - Enhanced browser history integration

5. **Production cleanup** - Removed debug logging, kept essential errors

### 2. Screen Base Class

**`screen-base.js`**### 📋 Remaining Tasks

```javascript1. **Demo enter/execute/exit state pattern** - Show examples of new StateMachine features

class Screen {

  constructor(navigation, auth) { ... }## 🧪 Testing Status

  

  // Abstract - must implement### ✅ Working Features

  render() { throw new Error('Must implement render()'); }- **Login flow**: Email/password → role selection → dashboard

  - **Role switching**: Multiple roles supported with proper navigation

  // Lifecycle hooks- **Screen transitions**: Smooth navigation with proper lifecycle

  onEnter(params) { } // Initialize screen- **Error handling**: API failures handled gracefully

  onExit() { this.isMounted = false; } // Cleanup- **Authentication**: Token-based auth with user context preservation

  

  // Helper methods### 🧪 Needs Testing

  safeFetch(url, onSuccess) { } // Ignores if !isMounted- **Back button comprehensive testing**: Verify all navigation scenarios

  renderList(containerId, items, renderItem, emptyMsg) { }- **Deep linking**: Test direct URL access to screens

  handleError(error, context) { } // Overridable error handling- **Error scenarios**: Test network failures a

  find(selector) { } // Shorthand for querySelectorChristian -  Criminal, FBI, Child abuse, NSOR

}

```Luke-  Criminal, FBI, Child abuse, NSOR



### 3. Screen ManagerVictor-  Criminal, FBI, Child abuse, NSOR

**`screen-manager.js`**nd edge cases

- Manages screen registry and transitions

- **Key feature**: DOM replacement (not hiding/showing)## 🔧 Files Modified/Created

- Safety: `isTransitioning` flag prevents race conditions

- Error handling: Central try/catch with `showFatalError()`### New Architecture Files

- `frontend/js/core/ScreenManager.js` - Navigation controller

### 4. Navigation State Machine- `frontend/js/core/Screen.js` - Base screen class

**`navigation.js`**- `frontend/js/screens/LoginScreen.js` - Login implementation

```javascript- `frontend/js/screens/RoleSwitchboardScreen.js` - Role selection

class NavigationStateMachine {- `frontend/js/screens/DashboardScreen.js` - Dashboard implementation

  constructor(screenManager, auth) {

    this.currentState = null;### Enhanced Files

    this.history = [];- `frontend/js/core/StateMachine.js` - Added enter/execute/exit pattern

    this.context = {}; // Global: {user, team, role}- `frontend/js/services/AuthService.js` - Added getUserRoles method

  }- `frontend/js/App.js` - Complete rewrite with state machine

  - `start.sh` - Enhanced with --no-cache for development

  goTo(state, params) { }  // Push to history, navigate

  goBack() { }             // Pop history, navigate back### Backup Files

}- `frontend/js/App_old.js` - Original implementation preserved

```

## 🚀 Next Session Action Items

### 5. Role Selection Screen (NEW)

**`role-selection.js`**### Immediate Next Steps

- Shows user's name from context1. **Test back button thoroughly**:

- Coach button only (Player commented out for now)   ```bash

- Logout button   # Open browser, login, navigate through screens

- On Coach click: `navigation.goTo('team-selection')`   # Test browser back button at each step

- Stores selected role in `navigation.context.role`   # Verify no logout occurs, proper navigation maintained

   ```

---

2. **Demo enhanced StateMachine pattern**:

## 📋 Recent Changes (Nov 19, 2025)   ```javascript

   // Show examples of new enter/execute/exit functions

### 1. Fixed Login Issue   // Convert existing screens to use new pattern

**Problem**: Frontend sent `{username, password}` but backend expected `{email, password}`   // Document best practices

**Fix**: Changed `auth.js` line 33 to send `email: username` instead of `username`   ```

**Result**: Login now works with jbreslin@footballhome.org / 1893Soccer!

### Future Enhancements

### 2. Added Role Selection Screen- **Add more screens** (Profile, Settings, etc.)

**Why**: Original plan had role selection before team selection (not direct to teams)- **Implement PWA features** (offline support, notifications)

**Implementation**:- **Add testing framework** (Jest/Cypress)

- Created `role-selection.js` with Coach button only- **Performance optimization** (lazy loading, code splitting)

- Added to `app.js` screens and registered with ScreenManager

- Updated `login.js` to navigate to `'role-selection'` after successful login## 🔍 Key Code Locations

- Added `<script src="js/screens/role-selection.js"></script>` to `index.html`

### Entry Point

### 3. Added Login History Tracking- `frontend/index.html` - App initialization

**Database**:- `frontend/js/App.js` - Main application class

- Created `login_history` table with UUID user_id (not INTEGER)

- Indexed on user_id and login_time for performance### Navigation System

- Applied schema: `docker compose exec db psql ...`- `frontend/js/core/ScreenManager.js:82` - navigateTo method

- `frontend/js/core/ScreenManager.js:175` - Browser history handling

**Backend**:- `frontend/js/core/Screen.js:140` - Event emission to parent

- Added `logLoginAttempt()` method to `AuthController`

- Extracts IP from X-Forwarded-For or X-Real-IP headers### State Machines

- Extracts User-Agent from request headers- `frontend/js/core/StateMachine.js:66` - Enhanced send method with enter/exit

- Inserts into login_history on successful login- `frontend/js/core/StateMachine.js:52` - New execute method

- Errors don't break login flow (logged but not thrown)

### Authentication Integration

**Files Modified**:- `frontend/js/services/AuthService.js:166` - getUserRoles method

- `AuthController.h` - Added method declaration- `frontend/js/core/ScreenManager.js` - AuthService integration for history

- `AuthController.cpp` - Implemented logging method

- `AuthController.cpp:48` - Call `logLoginAttempt()` after successful authentication## 🐛 Known Issues/Considerations

- **None currently** - all major issues resolved

### 4. Fixed docker-compose.yml Path- **Performance**: Consider lazy loading for large screen count

**Problem**: `./start.sh` failed because `docker-compose.yml` line 69 had `context: ./frontend-new`- **SEO**: May need server-side rendering for public pages

**Fix**: Used sed command to replace with `context: ./frontend`

**Result**: Containers now build and start successfully## � Development Notes

- **Docker builds**: Use `--no-cache` flag is now default in start.sh

---- **Console output**: Much cleaner in production, errors still logged

- **State debugging**: Can be re-enabled by changing logging levels

## 🚧 Known Issues / TODO- **Event timing**: Uses setTimeout(0) for proper event listener setup



### Backend Endpoints Needed---

1. **GET /api/user/teams** - Returns user's teams with roles**Last Updated**: November 18, 2025 (Evening)

   - Currently returns 404**Current Work**: Player RSVP Feature - Navigation flow complete, need to verify RSVP screen loads practices

   - Expected: `[{id, name, role}]`**Status**: Full decision tree implemented ✅, State transitions fixed ✅, Need to test end-to-end 🔴

   - Needed by: `team-selection.js`**Next Action**: Test player flow all the way through and verify PracticeRSVP screen works



2. **GET /api/teams/{id}/practices** - List practices for team## 🎯 Session Handoff (Nov 18, 2025 - Evening)

   - Needed by: `practice-management.js`

   ### What's Working ✅

3. **POST /api/practices** - Create practice1. **Player Events Button**: Navigates to EventTypeSelection ✅

   - Needed by: `practice-form.js`2. **EventTypeSelection → PracticeOptions**: Players see options screen ✅  

   3. **PracticeOptions Rendering**: Dynamically shows RSVP only for players, both options for coaches ✅

4. **PUT /api/practices/{id}** - Update practice4. **State Machine Transitions**: practiceOptions state with RSVP_SELECTED handling ✅

   - Needed by: `practice-form.js`5. **Team Context**: Properly captured and propagated through navigation ✅

   6. **Back Buttons**: Event listeners attached via setupForm() ✅

5. **DELETE /api/practices/{id}** - Delete practice

   - Needed by: `practice-management.js`### What Needs Testing 🔴

   1. **PracticeRSVP Screen**: Does it load practices correctly?

6. **POST /api/practices/{id}/rsvp** - RSVP to practice   - teamContext should now be passed properly

   - Needed by: `practice-list.js`   - API call: GET /api/events/:teamId

   - Filtering logic for future practices

### Frontend Enhancements   - RSVP button functionality

- Add loading spinners during API calls2. **End-to-End Player Flow**: Complete journey from login to RSVP

- Better error messages (distinguish network/auth/validation errors)3. **Error Handling**: What happens if no practices exist?

- Form validation before submission

- Logout button in navigation/header### Current Architecture 🏗️

- Player role screens (when ready)

- Other event types beyond practices (when ready)**Player Flow**:

```

---Login → Role Selection → Team Selection → Dashboard

  ↓

## 🧪 Testing GuideEvents Button (roleStateMachine.send('NAVIGATE_TO_EVENTS'))

  ↓

### Test Login FlowEventTypeSelection Screen (shows Practices card)

```bash  ↓

# 1. Start containersClick Practices (roleStateMachine.send('EVENT_TYPE_SELECTED', 'practice'))

./start.sh  ↓

PlayerStateMachine.handleEventType → send('NAVIGATE_TO_OPTIONS')

# 2. Open browser to https://footballhome.org  ↓

# 3. Login with: jbreslin@footballhome.org / 1893Soccer!PlayerStateMachine.practiceOptions state → navigateToScreen('practiceOptions')

# 4. Should see role selection screen with Coach button  ↓

# 5. Click Coach → Should attempt to load teams (will 404 for now)PracticeOptions Screen (renders RSVP card only for players)

```  ↓

Click "View & RSVP" → send('OPTION_SELECTED', 'rsvp')

### Check Login History  ↓

```sqlPracticeOptionsScreen.navigate() → roleStateMachine.send('RSVP_SELECTED')

-- Connect to database  ↓

docker compose exec db psql -U footballhome_user -d footballhomePlayerStateMachine.viewingPractices state → navigateToScreen('practiceRSVP')

  ↓

-- Query login historyPracticeRSVP Screen (should load practices and show RSVP buttons)

SELECT ```

  lh.id,

  u.email,**Coach Flow** (for comparison):

  lh.login_time,```

  lh.ip_address,Same as player until PracticeOptions screen

  lh.success  ↓

FROM login_history lhPracticeOptions Screen (renders both Manage and RSVP cards)

JOIN users u ON lh.user_id = u.id  ↓

ORDER BY lh.login_time DESCClick "Manage" → CoachStateMachine.managingPractices → ManagePractices Screen

LIMIT 10;  OR

```Click "View & RSVP" → CoachStateMachine.rsvpingToPractices → PracticeRSVP Screen

```

### Check Backend Logs

```bash### Debug Steps for Next Session 🔍

docker compose logs backend --tail=50

```1. **Open browser console** and hard refresh (Ctrl+Shift+R)

2. **Login as player** (jbreslin@footballhome.org / password)

### Rebuild Frontend3. **Follow the flow**:

```bash   - Select Player role

docker compose restart frontend   - Select Lighthouse 1893 SC team

```   - Click Events button on dashboard

   - Click Practices card on EventTypeSelection

### Rebuild Backend (after C++ changes)   - Click "View & RSVP" button on PracticeOptions

```bash4. **Check console for**:

docker compose restart backend   - TeamContext values at each step

# Backend rebuilds automatically in container   - API call to /api/events/:teamId

```   - Practice filtering logic output

   - Any errors or null values

---5. **Verify PracticeRSVP screen**:

   - Does it show "Loading practices..." initially?

## 💡 Design Decisions   - Does it call the API with correct teamId?

   - Does it show practices or "No upcoming practices"?

### Why DOM Replacement?   - Do RSVP buttons work?

- **Problem**: Event listeners accumulating, causing duplicate actions

- **Solution**: Completely replace DOM on each transition### Known Issues / Technical Debt 📋

- **Trade-off**: Lose component state, but prevents memory leaks- PracticeRSVP filtering may need adjustment (date parsing, type matching)

- **Result**: Clean slate every time, no stale listeners- Error messages need to be more user-friendly

- Back button navigation through all screens needs comprehensive testing

### Why No Caching?- Consider adding loading spinners for better UX

- **Simplicity**: Always fetch fresh = no cache invalidation logic

- **Consistency**: Users always see latest data### Key Code Locations 📍

- **Trade-off**: More API calls, but acceptable for small user base

- **Future**: Can add caching layer if performance becomes issue**Player State Machine**:

- `frontend/js/roles/PlayerStateMachine.js:26-48` - practiceOptions and viewingPractices states

### Why State Machine for Navigation?- `frontend/js/roles/PlayerStateMachine.js:93-105` - handleEventType with NAVIGATE_TO_OPTIONS

- **Single source of truth**: All navigation logic in one place

- **History management**: Built-in back button support**Navigation & Context**:

- **Context preservation**: Global state ({user, team, role}) flows through navigation- `frontend/js/screens/DashboardScreen.js:111-150` - Team context extraction and role state machine update

- **Testability**: Easy to test navigation logic independently- `frontend/js/core/BaseRoleStateMachine.js:130-139` - buildContext() method

- `frontend/js/core/BaseRoleStateMachine.js:176-194` - navigateToScreen() method

### Why No Framework?

- **Learning**: Pure JavaScript teaches fundamentals**Practice Screens**:

- **Control**: No black box, understand every line- `frontend/js/screens/PracticeOptionsScreen.js:38-97` - Dynamic rendering based on roleType

- **Size**: Minimal bundle size, fast load times- `frontend/js/screens/PracticeRSVPScreen.js:73-94` - onEnter with teamContext validation

- **Trade-off**: More boilerplate, but full control- `frontend/js/screens/PracticeRSVPScreen.js:96-123` - loadPractices() method



---### Environment Info 💻

- **Docker**: `./start.sh` or `docker compose restart frontend`

## 📚 Code Examples- **Database**: PostgreSQL, 2 test practices should exist

- **Test Account**: jbreslin@footballhome.org / password (admin + player roles)

### Creating a New Screen- **Test Team**: Lighthouse 1893 SC (id: d37eb44b-8e47-0005-9060-f0cbe96fe089)

```javascript- **Backend**: GET /api/events/:teamId returns {id, title, event_date, duration_minutes, location, type}

// 1. Create file: frontend/js/screens/my-screen.js

class MyScreen extends Screen {---

  render() {

    const div = document.createElement('div');## 🎯 Session Handoff (Nov 18, 2025)

    div.className = 'screen screen-my-screen';

    div.innerHTML = `### What's Working ✅

      <div class="card">1. **Practice Creation**: Coaches can create practices via ManagePracticesScreen

        <h2>My Screen</h2>2. **Practice Display (Coach)**: Practices show correctly in ManagePracticesScreen sidebar

        <button class="btn" data-action="next">Next</button>3. **Screen Visibility**: Only one screen visible at a time (fixed bug)

      </div>4. **Data Contract**: Backend returns `event_date`, `duration_minutes`, `type` consistently

    `;5. **Database**: 2 test practices exist and are queryable

    this.element = div;6. **Navigation**: Player routing goes to PracticeRSVP (not ManagePractices) ✅

    return div;

  }### What's Broken 🔴

  1. **PracticeRSVPScreen**: Shows "No upcoming practices" for both player and coach

  onEnter(params) {   - Same API endpoint as ManagePracticesScreen (which works)

    // Event delegation on root element   - Debug logging added but not yet tested

    this.element.addEventListener('click', (e) => {   - Likely issue: Date parsing or filtering logic in loadPractices()

      const btn = e.target.closest('[data-action]');

      if (btn?.dataset.action === 'next') {### Immediate Next Steps 🚀

        this.navigation.goTo('next-screen');1. **Rebuild and Test**:

      }   ```bash

    });   ./start.sh  # Rebuild frontend with new debug logs

  }   # Hard refresh browser (Ctrl+Shift+R)

}   # Login as player → Events → Practices

   # Check console for debug output

// 2. Add to app.js   ```

this.screens = {

  // ...2. **Compare Working vs Broken**:

  myScreen: new MyScreen(this.navigation, this.auth)   - ManagePracticesScreen.loadPractices() (lines 132-180) ← WORKS

};   - PracticeRSVPScreen.loadPractices() (lines 75-105) ← BROKEN

this.screenManager.register('my-screen', this.screens.myScreen);   - Look for differences in:

     - Date parsing: `new Date(event.event_date)`

// 3. Add to index.html     - Type filtering: `event.type === 'training'`

<script src="js/screens/my-screen.js"></script>     - Time comparison: `eventDateTime > now`

```

3. **Fix and Verify**:

### Making API Calls in Screens   - Once practices display in PracticeRSVPScreen

```javascript   - Test RSVP button clicks

onEnter(params) {   - Verify POST /api/events/:eventId/rsvp endpoint

  // Option 1: Using safeFetch (ignores if screen unmounted)   - Check RSVP saves to event_rsvps table

  this.safeFetch('/api/teams', (data) => {

    this.renderList('teams-container', data, ### Debug Checklist 📋

      team => `<div>${team.name}</div>`,- [x] Coach can create practice

      'No teams found'- [x] Practice appears in ManagePracticesScreen (coach)

    );- [x] Player routing goes to PracticeRSVP screen

  });- [x] Screen visibility bug fixed

  - [ ] PracticeRSVPScreen shows practices ← **CURRENT BLOCKER**

  // Option 2: Manual fetch with isMounted check- [ ] RSVP buttons functional

  this.auth.fetch('/api/teams')- [ ] RSVP saves correctly

    .then(r => r.json())- [ ] RSVP status displays

    .then(data => {

      if (!this.isMounted) return; // Ignore if navigated away### Key File Locations 📍

      // Render data**Problem Area**:

    })- `frontend/js/screens/PracticeRSVPScreen.js:75-105` - loadPractices() method with debug logs

    .catch(err => this.handleError(err, 'loading teams'));- `frontend/js/screens/ManagePracticesScreen.js:132-180` - Working reference implementation

}

```**Backend**:

- `backend/src/controllers/EventController.cpp:157-210` - GET /api/events/:teamId endpoint

---- Returns: `{id, title, event_date, duration_minutes, location, type}`



## 🔧 Development Workflow**Database**:

- Table: `events` (has 2 test practices)

### Making Changes- Query to verify data:

```bash  ```sql

# 1. Edit files in frontend/js/  SELECT id, title, event_date, duration_minutes, event_type_id 

# 2. Restart frontend container  FROM events 

docker compose restart frontend  WHERE event_type_id = (SELECT id FROM event_types WHERE name = 'training')

  ORDER BY event_date;

# 3. Hard refresh browser (Ctrl+Shift+R)  ```

# 4. Check console for errors

```### Environment Info 💻

- **Docker**: Use `./start.sh` to rebuild (includes --no-cache)

### Adding New Database Tables- **Database**: PostgreSQL via docker-compose, pgAdmin on localhost:5050

```bash- **Frontend**: Nginx serving on localhost:80

# 1. Create SQL file in database/schema/- **Backend**: C++ service on localhost:8080

# 2. Apply to running database- **Test Account**: jbreslin@footballhome.org / password (admin + player roles)

docker compose exec db psql -U footballhome_user -d footballhome -f /docker-entrypoint-initdb.d/schema/your-file.sql- **Test Team**: Lighthouse 1893 SC



# OR rebuild database from scratch---

docker compose down -v  # WARNING: Deletes all data!

./start.sh## 🎯 Evening Session Progress (Nov 17, 2025)

```

### Fixed Major Issues ✅

### Backend Changes

```bash1. **Screen Visibility Bug**:

# 1. Edit .cpp/.h files in backend/src/   - **Problem**: Multiple screens visible simultaneously (managePractices AND practiceRSVP both had display:block)

# 2. Restart backend (rebuilds automatically)   - **Root Cause**: ScreenManager.enterScreen() wasn't hiding previous screens

docker compose restart backend   - **Fix**: Added loop to hide all other screens before showing new one

   - **File**: `frontend/js/core/ScreenManager.js:147-166`

# 3. Check logs

docker compose logs backend --tail=502. **Backend/Frontend Data Contract Mismatch**:

```   - **Problem**: Backend returned `date`/`duration` but frontend expected `event_date`/`duration_minutes`

   - **Fix**: Updated EventController.cpp to return correct field names

---   - **Impact**: Practices now load and display correctly

   - **Files**: 

## 👥 Test Accounts     - `backend/src/controllers/EventController.cpp` (lines 189, 192, 198)

     - `frontend/js/screens/ManagePracticesScreen.js` (lines 144, 147, 175)

- **Email**: jbreslin@footballhome.org

- **Password**: 1893Soccer!3. **Practice Creation Failing**:

- **Roles**: Admin, Coach (maybe Player too)   - **Problem**: Database error - `location` column doesn't exist in practices table

- **Team**: Lighthouse 1893 SC   - **Root Cause**: practices table schema has no location column (events table has venue_id instead)

   - **Fix**: Removed location column from INSERT queries

---   - **File**: `backend/src/controllers/EventController.cpp:123-134`



## 🎯 Next Session Priorities4. **Practices Display in ManagePracticesScreen**:

   - **Status**: ✅ Working! Practices now show in right sidebar

1. **Implement /api/user/teams endpoint** (TeamController)   - **Verified**: Coach can create practice and see it in "Upcoming Practices" list

   - Query database for user's teams with roles

   - Return: `[{id, name, role}]`### Current Status 🔴

   

2. **Test team selection flow****RSVP Screen Issue**:

   - Login → Role → Teams → Select team- PracticeRSVPScreen shows "No upcoming practices" for both player and coach

   - Verify team stored in navigation.context.team- ManagePracticesScreen successfully shows practices (same API call)

   - Added debug logging to PracticeRSVPScreen.loadPractices() but not yet deployed/tested

3. **Implement practice endpoints** (EventController)- **Next Step**: Rebuild frontend and check console logs to see filtering logic

   - GET /api/teams/{id}/practices

   - POST /api/practices### Files Modified Tonight

   - PUT /api/practices/{id}

   - DELETE /api/practices/{id}**Backend**:

   - `backend/src/controllers/EventController.cpp`:

4. **Test full coach flow end-to-end**  - Fixed field names: event_date, duration_minutes (not date/duration)

   - Login → Coach → Team → Options → Manage  - Removed location column from practices INSERT

   - Create practice  - Added debug logging for JSON responses

   - Edit practice

   - Delete practice**Frontend**:

   - Back to RSVP view- `frontend/js/core/ScreenManager.js`:

  - Fixed enterScreen() to hide all other screens first

---- `frontend/js/screens/ManagePracticesScreen.js`:

  - Updated to use event_date and duration_minutes

**Last Updated**: November 19, 2025  - Added debug logging for practice filtering

**Status**: Login ✅ | Role Selection ✅ | Team Selection 🔴 (needs backend) | Practices 🔴 (needs backend)- `frontend/js/screens/PracticeRSVPScreen.js`:

**Next Action**: Implement /api/user/teams endpoint in backend  - Added debug logging (not yet tested)


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