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
      oauthSuccess: new OAuthSuccessScreen(this.navigation, this.auth),
      roleSelection: new RoleSelectionScreen(this.navigation, this.auth),
      contextSelection: new ContextSelectionScreen(this.navigation, this.auth),
      divisionSelection: new DivisionSelectionScreen(this.navigation, this.auth),
      divisionMenu: new DivisionMenuScreen(this.navigation, this.auth),
      divisionManagement: new DivisionManagementScreen(this.navigation, this.auth),
      divisionRoster: new DivisionRosterScreen(this.navigation, this.auth),
      teamSelection: new TeamSelectionScreen(this.navigation, this.auth),
      teamDashboard: new TeamDashboardScreen(this.navigation, this.auth),
      rosterManagement: new RosterManagementScreen(this.navigation, this.auth),
      rosterDashboard: new RosterDashboardScreen(this.navigation, this.auth),
      rosterCategory: new RosterCategoryScreen(this.navigation, this.auth),
      practiceOptions: new PracticeOptionsScreen(this.navigation, this.auth),
      practiceManagement: new PracticeManagementScreen(this.navigation, this.auth),
      practiceForm: new PracticeFormScreen(this.navigation, this.auth),
      practiceList: new PracticeListScreen(this.navigation, this.auth),
      practiceRSVPManagement: new PracticeRSVPManagementScreen(this.navigation, this.auth),
      practiceAttendance: new PracticeAttendanceScreen(this.navigation, this.auth),
      matchOptions: new MatchOptionsScreen(this.navigation, this.auth),
      matchManagement: new MatchManagementScreen(this.navigation, this.auth),
      matchForm: new MatchFormScreen(this.navigation, this.auth),
      matchList: new MatchListScreen(this.navigation, this.auth),
      matchRSVPManagement: new MatchRSVPManagementScreen(this.navigation, this.auth),
      matchDetail: new MatchDetailScreen(this.navigation, this.auth),
      gameDayRoster: new GameDayRosterScreen(this.navigation, this.auth),
      matchShare: new MatchShareScreen(this.navigation, this.auth),
      adminLevelSelection: new AdminLevelSelectionScreen(this.navigation, this.auth),
      adminEntityList: new AdminEntityListScreen(this.navigation, this.auth),
      adminSystem: new AdminSystemScreen(this.navigation, this.auth),
      adminClub: new AdminClubScreen(this.navigation, this.auth),
      clubEvents: new ClubEventsScreen(this.navigation, this.auth),
      adminSportDivision: new AdminSportDivisionScreen(this.navigation, this.auth),
      adminTeam: new AdminTeamScreen(this.navigation, this.auth),
      tacticalBoard: new TacticalBoardScreen(this.navigation, this.auth)
    };
    // Expose certain screens globally for legacy inline onclick handlers
    // (e.g., admin-system uses `adminSystemScreen.loadGroupMeMessages(...)`)
    window.adminSystemScreen = this.screens.adminSystem;
    
    // Register all screens with the manager
    this.screenManager.register('login', this.screens.login);
    this.screenManager.register('oauth-success', this.screens.oauthSuccess);
    this.screenManager.register('role-selection', this.screens.roleSelection);
    this.screenManager.register('context-selection', this.screens.contextSelection);
    this.screenManager.register('division-selection', this.screens.divisionSelection);
    this.screenManager.register('division-menu', this.screens.divisionMenu);
    this.screenManager.register('division-management', this.screens.divisionManagement);
    this.screenManager.register('division-roster', this.screens.divisionRoster);
    this.screenManager.register('team-selection', this.screens.teamSelection);
    this.screenManager.register('team-dashboard', this.screens.teamDashboard);
    this.screenManager.register('roster-management', this.screens.rosterManagement);
    this.screenManager.register('roster-dashboard', this.screens.rosterDashboard);
    this.screenManager.register('roster-category', this.screens.rosterCategory);
    this.screenManager.register('practice-options', this.screens.practiceOptions);
    this.screenManager.register('practice-management', this.screens.practiceManagement);
    this.screenManager.register('practice-form', this.screens.practiceForm);
    this.screenManager.register('practice-list', this.screens.practiceList);
    this.screenManager.register('practice-rsvp-management', this.screens.practiceRSVPManagement);
    this.screenManager.register('practice-attendance', this.screens.practiceAttendance);
    this.screenManager.register('match-options', this.screens.matchOptions);
    this.screenManager.register('match-management', this.screens.matchManagement);
    this.screenManager.register('match-form', this.screens.matchForm);
    this.screenManager.register('match-list', this.screens.matchList);
    this.screenManager.register('match-rsvp-management', this.screens.matchRSVPManagement);
    this.screenManager.register('match-detail', this.screens.matchDetail);
    this.screenManager.register('game-day-roster', this.screens.gameDayRoster);
    this.screenManager.register('match-share', this.screens.matchShare);
    this.screenManager.register('admin-level-selection', this.screens.adminLevelSelection);
    this.screenManager.register('admin-entity-list', this.screens.adminEntityList);
    this.screenManager.register('admin-system', this.screens.adminSystem);
    this.screenManager.register('admin-club', this.screens.adminClub);
    this.screenManager.register('club-events', this.screens.clubEvents);
    this.screenManager.register('admin-sport-division', this.screens.adminSportDivision);
    this.screenManager.register('admin-team', this.screens.adminTeam);
    this.screenManager.register('tactical-board', this.screens.tacticalBoard);
    
    console.log('App initialized with screens:', Object.keys(this.screens));
  }
  
  start() {
    console.log('Starting app...');
    
    // Check if this is an OAuth callback redirect (has token in query string)
    const urlParams = new URLSearchParams(window.location.search);
    const hasOAuthToken = urlParams.has('token');
    
    if (hasOAuthToken) {
      console.log('OAuth callback detected, showing oauth-success screen');
      this.navigation.goTo('oauth-success');
      return;
    }
    
    // Check if user is already logged in
    if (this.auth.isLoggedIn()) {
      console.log('User already logged in:', this.auth.getUser());
      this.navigation.context.user = this.auth.getUser();
      // Resume session - go to role selection
      this.navigation.goTo('role-selection');
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
