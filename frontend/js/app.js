// App - bootstrap and wire everything together
class App {
  constructor() {
    // Create core services
    this.auth = new Auth(); // Empty apiBase = nginx proxies /api
    this.screenManager = new ScreenManager('app');
    this.navigation = new NavigationStateMachine(this.screenManager, this.auth);
    
    // Create all screen instances
    this.screens = {
      login: new LoginScreen(this.navigation, this.auth),
      roleSelection: new RoleSelectionScreen(this.navigation, this.auth),
      teamSelection: new TeamSelectionScreen(this.navigation, this.auth),
      teamDashboard: new TeamDashboardScreen(this.navigation, this.auth),
      rosterManagement: new RosterManagementScreen(this.navigation, this.auth),
      practiceOptions: new PracticeOptionsScreen(this.navigation, this.auth),
      practiceManagement: new PracticeManagementScreen(this.navigation, this.auth),
      practiceForm: new PracticeFormScreen(this.navigation, this.auth),
      practiceList: new PracticeListScreen(this.navigation, this.auth),
      practiceAttendance: new PracticeAttendanceScreen(this.navigation, this.auth),
      matchOptions: new MatchOptionsScreen(this.navigation, this.auth),
      matchList: new MatchListScreen(this.navigation, this.auth)
    };
    
    // Register all screens with the manager
    this.screenManager.register('login', this.screens.login);
    this.screenManager.register('role-selection', this.screens.roleSelection);
    this.screenManager.register('team-selection', this.screens.teamSelection);
    this.screenManager.register('team-dashboard', this.screens.teamDashboard);
    this.screenManager.register('roster-management', this.screens.rosterManagement);
    this.screenManager.register('practice-options', this.screens.practiceOptions);
    this.screenManager.register('practice-management', this.screens.practiceManagement);
    this.screenManager.register('practice-form', this.screens.practiceForm);
    this.screenManager.register('practice-list', this.screens.practiceList);
    this.screenManager.register('practice-attendance', this.screens.practiceAttendance);
    this.screenManager.register('match-options', this.screens.matchOptions);
    this.screenManager.register('match-list', this.screens.matchList);
    
    console.log('App initialized with screens:', Object.keys(this.screens));
  }
  
  start() {
    console.log('Starting app...');
    
    // Check if user is already logged in
    if (this.auth.isLoggedIn()) {
      console.log('User already logged in:', this.auth.getUser());
      this.navigation.context.user = this.auth.getUser();
      // Resume session - go to team selection
      this.navigation.goTo('team-selection');
    } else {
      console.log('No active session, showing login');
      this.navigation.goTo('login');
    }
  }
}

// Initialize and start app when DOM is ready
window.addEventListener('DOMContentLoaded', () => {
  console.log('DOM loaded, initializing app...');
  
  try {
    window.app = new App();
    window.app.start();
  } catch (error) {
    console.error('Failed to start app:', error);
    document.getElementById('app').innerHTML = `
      <div class="screen screen-error">
        <div class="card">
          <h2>Failed to Start</h2>
          <p>Something went wrong: ${error.message}</p>
          <button onclick="location.reload()">Reload Page</button>
        </div>
      </div>
    `;
  }
});
