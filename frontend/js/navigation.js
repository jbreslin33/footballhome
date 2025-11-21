// NavigationStateMachine - single source of truth for navigation
class NavigationStateMachine {
  constructor(screenManager, auth) {
    this.screenManager = screenManager;
    this.auth = auth;
    this.currentState = null;
    this.history = [];
    
    // Global context - persists across navigation
    this.context = {
      user: null,   // Set on login
      role: null,   // Set on role selection
      team: null    // Set on team selection
    };
  }
  
  // Update the context header display
  updateContextHeader() {
    const header = document.getElementById('context-header');
    const userEl = document.getElementById('context-user');
    const roleEl = document.getElementById('context-role');
    const teamEl = document.getElementById('context-team');
    
    // Show header if we have any context
    const hasContext = this.context.user || this.context.role || this.context.team;
    header.style.display = hasContext ? 'block' : 'none';
    
    // Update each field
    userEl.textContent = this.context.user?.email || '';
    roleEl.textContent = this.context.role ? this.context.role.charAt(0).toUpperCase() + this.context.role.slice(1) : '';
    teamEl.textContent = this.context.team?.name || '';
  }
  
  goTo(state, params = {}) {
    // Store current state in history
    if (this.currentState && this.currentState !== state) {
      this.history.push(this.currentState);
    }
    
    // Update context with any params
    if (params.team) {
      this.context.team = params.team;
    }
    if (params.user) {
      this.context.user = params.user;
    }
    if (params.role) {
      this.context.role = params.role;
    }
    
    // Update context header display
    this.updateContextHeader();
    
    // Update current state
    this.currentState = state;
    
    // Tell screen manager to show the screen
    this.screenManager.show(state, params);
    
    console.log(`Navigation: ${state}`, { context: this.context, history: this.history });
  }
  
  goBack() {
    if (this.history.length === 0) {
      console.log('No history, going to login');
      this.goTo('login');
      return;
    }
    
    // Clear context based on current screen before going back
    this.clearContextForScreen(this.currentState);
    
    // Pop previous state from history
    const previousState = this.history.pop();
    this.currentState = previousState;
    
    console.log(`Navigation: back to ${previousState}`, { context: this.context, history: this.history });
    
    // Update context header
    this.updateContextHeader();
    
    // Show previous screen with current context
    this.screenManager.show(previousState, this.context);
  }
  
  // Clear context set by specific screens when navigating back
  clearContextForScreen(screenName) {
    switch(screenName) {
      case 'team-selection':
        // Going back from team selection clears role (set by role-selection)
        this.context.role = null;
        break;
      case 'practice-options':
        // Going back from practice options clears team (set by team-selection)
        this.context.team = null;
        break;
      case 'practice-management':
      case 'practice-form':
      case 'practice-list':
        // Going back from these screens - nothing to clear (team stays)
        break;
      case 'role-selection':
        // Going back from role selection clears user (would go to login)
        this.context.user = null;
        break;
    }
  }
  
  // Clear history (useful after logout)
  clearHistory() {
    this.history = [];
    this.currentState = null;
  }
}
