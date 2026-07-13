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
      adminClubTeams: new AdminClubTeamsScreen(this.navigation, this.auth),
      clubEvents: new ClubEventsScreen(this.navigation, this.auth),
      adminSportDivision: new AdminSportDivisionScreen(this.navigation, this.auth),
      adminTeam: new AdminTeamScreen(this.navigation, this.auth),
      tacticalBoard: new TacticalBoardScreen(this.navigation, this.auth),
      clubDirectory: new ClubDirectoryScreen(this.navigation, this.auth),
      clubDetail: new ClubDetailScreen(this.navigation, this.auth),
      gameDayLineup: new GameDayLineupScreen(this.navigation, this.auth),
      teamHub: new TeamHubScreen(this.navigation, this.auth),
      matchSocial: new MatchSocialScreen(this.navigation, this.auth),
      socialSchedule: new SocialScheduleScreen(this.navigation, this.auth),
      holidayPosts: new HolidayPostsScreen(this.navigation, this.auth),
      promoPosts: new PromotionalPostsScreen(this.navigation, this.auth),
      contentPosts: new ContentPostsScreen(this.navigation, this.auth),
      flyers: new FlyersScreen(this.navigation, this.auth),
      internalRoster: new InternalRosterScreen(this.navigation, this.auth),
      leads: new LeadsScreen(this.navigation, this.auth),
      leadsAnalytics: new LeadsAnalyticsScreen(this.navigation, this.auth),
      members: new MembersScreen(this.navigation, this.auth),
      mensGameEligibility: new MensGameEligibilityScreen(this.navigation, this.auth),
      mensRoster: new MensRosterScreen(this.navigation, this.auth),
      boysRoster: new BoysRosterScreen(this.navigation, this.auth),
      girlsRoster: new GirlsRosterScreen(this.navigation, this.auth),
      rosters: new RostersScreen(this.navigation, this.auth),
      person: new PersonScreen(this.navigation, this.auth),
      mensEventsReminders: new MensEventsRemindersScreen(this.navigation, this.auth),
      youthRoster: new YouthRosterScreen(this.navigation, this.auth),
      payments: new PaymentsScreen(this.navigation, this.auth),
      messages: new MessagesScreen(this.navigation, this.auth),
      rsvpEligibility: new RsvpEligibilityScreen(this.navigation, this.auth),
      lineups: new LineupsScreen(this.navigation, this.auth),
      practiceDashboard: new PracticeDashboardScreen(this.navigation, this.auth),
      rsvp: new RsvpScreen(this.navigation, this.auth),
      adPreview: new AdPreviewScreen(this.navigation, this.auth),
      publicGameday: new PublicGamedayScreen(this.navigation, this.auth),
      publicLineup: new PublicLineupScreen(this.navigation, this.auth),
      publicSchedule: new PublicScheduleScreen(this.navigation, this.auth),
      my: new MyScreen(this.navigation, this.auth),
      adminSeriesEditor: new AdminSeriesEditorScreen(this.navigation, this.auth)
    };
    // Expose certain screens globally for legacy inline onclick handlers
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
    this.screenManager.register('admin-club-teams', this.screens.adminClubTeams);
    this.screenManager.register('club-events', this.screens.clubEvents);    this.screenManager.register('admin-sport-division', this.screens.adminSportDivision);
    this.screenManager.register('admin-team', this.screens.adminTeam);
    this.screenManager.register('tactical-board', this.screens.tacticalBoard);
    this.screenManager.register('club-directory', this.screens.clubDirectory);
    this.screenManager.register('club-detail', this.screens.clubDetail);
    this.screenManager.register('game-day-lineup', this.screens.gameDayLineup);
    this.screenManager.register('team-hub', this.screens.teamHub);
    this.screenManager.register('match-social', this.screens.matchSocial);
    this.screenManager.register('social-schedule', this.screens.socialSchedule);
    this.screenManager.register('holiday-posts', this.screens.holidayPosts);
    this.screenManager.register('promo-posts', this.screens.promoPosts);
    this.screenManager.register('content-posts', this.screens.contentPosts);
    this.screenManager.register('flyers', this.screens.flyers);
    this.screenManager.register('internal-roster', this.screens.internalRoster);
    this.screenManager.register('leads', this.screens.leads);
    this.screenManager.register('leads-analytics', this.screens.leadsAnalytics);
    // Unified Members board (URL: `#members`).
    this.screenManager.register('members', this.screens.members);
    this.screenManager.register('mens-game-eligibility', this.screens.mensGameEligibility);
    this.screenManager.register('mens-roster', this.screens.mensRoster);
    this.screenManager.register('boys-roster', this.screens.boysRoster);
    this.screenManager.register('girls-roster', this.screens.girlsRoster);
    this.screenManager.register('rosters', this.screens.rosters);
    // Universal person profile — reachable from any card that shows a
    // person (Members, Payments, Rosters, …).  See screens/person.js.
    this.screenManager.register('person', this.screens.person);
    this.screenManager.register('mens-events-reminders', this.screens.mensEventsReminders);
    this.screenManager.register('youth-roster', this.screens.youthRoster);
    this.screenManager.register('payments', this.screens.payments);
    this.screenManager.register('messages', this.screens.messages);
    this.screenManager.register('rsvp-eligibility', this.screens.rsvpEligibility);
    // Mens is the default; womens is the same screen with a gender param.
    // 'lineups' kept as a backward-compat alias for any old bookmarks / links.
    this.screenManager.register('mens-lineups', this.screens.lineups);
    this.screenManager.register('womens-lineups', this.screens.lineups);
    this.screenManager.register('lineups', this.screens.lineups);
    // Practice / Pickup dashboards — same screen instance, params drive
    // gender (mens/womens/youth) and kind (practice/pickup).
    this.screenManager.register('mens-practice-dash',   this.screens.practiceDashboard);
    this.screenManager.register('womens-practice-dash', this.screens.practiceDashboard);
    this.screenManager.register('youth-practice-dash',  this.screens.practiceDashboard);
    this.screenManager.register('mens-pickup-dash',     this.screens.practiceDashboard);
    this.screenManager.register('womens-pickup-dash',   this.screens.practiceDashboard);
    this.screenManager.register('youth-pickup-dash',    this.screens.practiceDashboard);
    this.screenManager.register('rsvp', this.screens.rsvp);
    this.screenManager.register('ad-preview', this.screens.adPreview);
    this.screenManager.register('public-gameday', this.screens.publicGameday);
    this.screenManager.register('public-lineup', this.screens.publicLineup);
    this.screenManager.register('public-schedule', this.screens.publicSchedule);
    this.screenManager.register('my', this.screens.my);
    this.screenManager.register('admin-series-editor', this.screens.adminSeriesEditor);
    
    console.log('App initialized with screens:', Object.keys(this.screens));
  }
  
  start() {
    console.log('Starting app...');

    // Public team views: #t/<slug>/(gameday|lineup|schedule)
    // Anyone can hit these without logging in. We bypass the login redirect
    // and re-route on hashchange so navigating between the 3 sub-views
    // does NOT require a full reload.
    const routePublic = () => {
      const m = (window.location.hash || '').match(/^#t\/([^\/]+)\/(gameday|lineup|schedule)$/);
      if (!m) return false;
      const slug = decodeURIComponent(m[1]);
      const view = m[2];
      const screenName = 'public-' + view;
      // Show directly via screenManager so we don't overwrite the pretty hash
      // that the user pinned/shared.
      this.screenManager.show(screenName, { slug });
      return true;
    };

    // FH-native magic-link landing — #rsvp/<chatEventId>.  Cookie session
    // was set by /api/auth/magic-link/verify before this redirect, so the
    // screen self-bootstraps with credentials-included fetches.
    const routeRsvp = () => {
      const m = (window.location.hash || '').match(/^#rsvp\/(\d+)$/);
      if (!m) return false;
      this.screenManager.show('rsvp', { chatEventId: m[1] });
      return true;
    };

    window.addEventListener('hashchange', () => {
      if (routePublic()) return;
      if (routeRsvp())   return;
    });

    if (routePublic()) {
      console.log('Routed to public team view');
      return;
    }
    if (routeRsvp()) {
      console.log('Routed to RSVP screen');
      return;
    }

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
