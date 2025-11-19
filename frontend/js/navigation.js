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
      team: null    // Set on team selection
      // No role (always coach for Phase 1)
      // No eventType (always practice for Phase 1)
    };
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
    
    // Pop previous state from history
    const previousState = this.history.pop();
    this.currentState = previousState;
    
    console.log(`Navigation: back to ${previousState}`, { history: this.history });
    
    // Show previous screen with current context
    this.screenManager.show(previousState, this.context);
  }
  
  // Clear history (useful after logout)
  clearHistory() {
    this.history = [];
    this.currentState = null;
  }
}
