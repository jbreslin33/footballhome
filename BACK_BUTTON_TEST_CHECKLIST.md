# Back Button Test Checklist

## 🎯 Purpose
Verify that browser back/forward buttons work correctly without logging users out or breaking navigation flow.

## ✅ Test Scenarios

### Scenario 1: Login → Role Selection → Dashboard → Back
1. **Start**: Open app at https://localhost
2. **Action**: Login with valid credentials
3. **Expected**: Navigate to Role Switchboard screen
4. **Action**: Click back button
5. **Expected**: Should NOT go back to login (user should stay authenticated)
6. **Expected**: Should stay on Role Switchboard OR navigate appropriately without logout

### Scenario 2: Role Selection → Dashboard → Back
1. **Start**: At Role Switchboard screen (after login)
2. **Action**: Select a role (e.g., "Player")
3. **Expected**: Navigate to Dashboard
4. **Action**: Click back button
5. **Expected**: Return to Role Switchboard
6. **Expected**: User remains logged in

### Scenario 3: Multiple Forward/Back Navigation
1. **Start**: At Dashboard
2. **Action**: Click back button twice
3. **Expected**: Navigate back through history without logout
4. **Action**: Click forward button
5. **Expected**: Navigate forward through history
6. **Expected**: User remains logged in throughout

### Scenario 4: Direct URL Access After Login
1. **Start**: Logged in and at Dashboard
2. **Action**: Manually type `https://localhost#roleSwitchboard` in address bar
3. **Expected**: Navigate to Role Switchboard
4. **Action**: Click back button
5. **Expected**: Return to Dashboard
6. **Expected**: User remains logged in

### Scenario 5: Refresh Page
1. **Start**: At any authenticated screen
2. **Action**: Click browser refresh
3. **Expected**: Should check authentication and navigate appropriately
4. **Expected**: Should NOT log user out if token is valid

### Scenario 6: Back Button at Login Screen
1. **Start**: At Login screen (not logged in)
2. **Action**: Click back button
3. **Expected**: Should prevent navigation outside app OR handle gracefully
4. **Expected**: Should NOT crash or show error

## 🔍 What to Check

### Console Output
- ✅ Should see: `🔙 ScreenManager: Browser back/forward detected:`
- ✅ Should see: `🔙 ScreenManager: Navigating to valid screen:`
- ❌ Should NOT see: Errors or undefined states
- ❌ Should NOT see: Logout messages when navigating back

### Visual Behavior
- ✅ Screen transitions are smooth
- ✅ No flash of wrong screen
- ✅ User data persists across navigation
- ✅ No broken layouts or missing content

### Authentication State
- ✅ Token remains in localStorage
- ✅ User object remains in ScreenManager
- ✅ No unexpected logout
- ✅ Auth header sent with API calls

### Browser History
- ✅ URL hash updates correctly (#login, #roleSwitchboard, #dashboard)
- ✅ Browser back button is enabled when appropriate
- ✅ Browser forward button works after going back

## 🐛 Known Issues to Watch For

### Issue 1: Logout on Back Button (FIXED)
- **Problem**: Original issue where back button would log user out
- **Fix**: ScreenManager now handles popstate events properly
- **Test**: Verify user stays logged in when using back button

### Issue 2: Invalid State Navigation
- **Problem**: Back button might try to navigate to undefined state
- **Fix**: ScreenManager checks if screen exists before navigating
- **Test**: Try clicking back button multiple times rapidly

### Issue 3: Race Conditions
- **Problem**: Rapid navigation could cause state machine conflicts
- **Fix**: State machine queues transitions
- **Test**: Click back/forward buttons rapidly

## 📊 Test Results

### Test Run 1: [Date/Time]
- [ ] Scenario 1: PASS / FAIL - Notes: _______________
- [ ] Scenario 2: PASS / FAIL - Notes: _______________
- [ ] Scenario 3: PASS / FAIL - Notes: _______________
- [ ] Scenario 4: PASS / FAIL - Notes: _______________
- [ ] Scenario 5: PASS / FAIL - Notes: _______________
- [ ] Scenario 6: PASS / FAIL - Notes: _______________

### Issues Found:
1. _______________
2. _______________
3. _______________

### Actions Needed:
1. _______________
2. _______________
3. _______________

## 🔧 Code Locations for Reference

### ScreenManager History Handling
- **File**: `frontend/js/core/ScreenManager.js`
- **Line**: 196-226
- **Function**: `setupHistoryHandling()`

### Browser History Update
- **File**: `frontend/js/core/ScreenManager.js`
- **Line**: 188-190
- **Function**: Inside `navigateTo()`

### State Machine Transitions
- **File**: `frontend/js/core/StateMachine.js`
- **Line**: 66-120
- **Function**: `send()`

## 💡 Testing Tips

1. **Open Browser Console**: Press F12 to see all log messages
2. **Watch Network Tab**: Verify API calls happen correctly
3. **Check Application Tab**: Verify localStorage token persists
4. **Use Slow Network**: Test with throttled network to catch race conditions
5. **Test Multiple Browsers**: Chrome, Firefox, Safari may behave differently

## ✨ Success Criteria

All scenarios pass with:
- ✅ No console errors
- ✅ User never logged out unexpectedly
- ✅ Smooth navigation experience
- ✅ Proper URL hash updates
- ✅ Authentication persists correctly

---
**Status**: Ready for testing
**Last Updated**: November 15, 2025
