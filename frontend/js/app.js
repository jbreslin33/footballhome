// App - bootstrap and wire everything together
class App {
  constructor() {
    // Create core services
    this.auth = new Auth(); // Empty apiBase = nginx proxies /api
    this.screenManager = new ScreenManager('app');
    this.navigation = new NavigationStateMachine(this.screenManager, this.auth);

    // Install the delegated click handler that routes every
    // `.person-action` button (rendered by any card, on any screen,
    // via the shared PersonActions component) through
    // `navigation.goTo('person', …)`.  Idempotent — safe if this
    // constructor ever runs twice.
    if (window.PersonActions && typeof window.PersonActions.installGlobalHandler === 'function') {
      window.PersonActions.installGlobalHandler(this.navigation);
    }
    
    // Create all screen instances
    this.screens = {
      login: new LoginScreen(this.navigation, this.auth),
      oauthSuccess: new OAuthSuccessScreen(this.navigation, this.auth),
      roleSelection: new RoleSelectionScreen(this.navigation, this.auth),
      tactical: new TacticalScreen(this.navigation, this.auth),
      marketingHome: new MarketingHomeScreen(this.navigation, this.auth),
      clubSelection: new ClubSelectionScreen(this.navigation, this.auth),
      teamDashboard: new TeamDashboardScreen(this.navigation, this.auth),
      practiceOptions: new PracticeOptionsScreen(this.navigation, this.auth),
      practiceManagement: new PracticeManagementScreen(this.navigation, this.auth),
      practiceForm: new PracticeFormScreen(this.navigation, this.auth),
      practiceList: new PracticeListScreen(this.navigation, this.auth),
      practiceDetail: new PracticeDetailScreen(this.navigation, this.auth),
      practicePlan: new PracticePlanScreen(this.navigation, this.auth),
      matchForm: new MatchFormScreen(this.navigation, this.auth),
      matchList: new MatchListScreen(this.navigation, this.auth),
      matchDetail: new MatchDetailScreen(this.navigation, this.auth),
      adminLevelSelection: new AdminLevelSelectionScreen(this.navigation, this.auth),
      adminEntityList: new AdminEntityListScreen(this.navigation, this.auth),
      adminSystem: new AdminSystemScreen(this.navigation, this.auth),
      adminClub: new AdminClubScreen(this.navigation, this.auth),
      gameModelAdmin: new GameModelAdminScreen(this.navigation, this.auth),
      gameModel: new GameModelScreen(this.navigation, this.auth),
      playerActions: new PlayerActionsScreen(this.navigation, this.auth),
      adminClubTeams: new AdminClubTeamsScreen(this.navigation, this.auth),
      tacticalBoard: new TacticalBoardScreen(this.navigation, this.auth),
      clubDirectory: new ClubDirectoryScreen(this.navigation, this.auth),
      clubDetail: new ClubDetailScreen(this.navigation, this.auth),
      gameCenter: new GameCenterScreen(this.navigation, this.auth),
      teamHub: new TeamHubScreen(this.navigation, this.auth),
      matchSocial: new MatchSocialScreen(this.navigation, this.auth),
      socialSchedule: new SocialScheduleScreen(this.navigation, this.auth),
      holidayPosts: new HolidayPostsScreen(this.navigation, this.auth),
      promoPosts: new PromotionalPostsScreen(this.navigation, this.auth),
      contentPosts: new ContentPostsScreen(this.navigation, this.auth),
      flyers: new FlyersScreen(this.navigation, this.auth),
      leads: new LeadsScreen(this.navigation, this.auth),
      leadsAnalytics: new LeadsAnalyticsScreen(this.navigation, this.auth),
      members: new MembersScreen(this.navigation, this.auth),
      peopleWorkbench: new PeopleWorkbenchScreen(this.navigation, this.auth),
      rosters: new RostersScreen(this.navigation, this.auth),
      person: new PersonScreen(this.navigation, this.auth),
      youthRoster: new YouthRosterScreen(this.navigation, this.auth),
      payments: new PaymentsScreen(this.navigation, this.auth),
      reports: new ReportsScreen(this.navigation, this.auth),
      rsvps: new RsvpBoardScreen(this.navigation, this.auth),
      kit: new KitBoardScreen(this.navigation, this.auth),
      security: new SecurityScreen(this.navigation, this.auth),
      clubLogos: new ClubLogosScreen(this.navigation, this.auth),
      files: new FilesScreen(this.navigation, this.auth),
      eventCenter: new EventCenterScreen(this.navigation, this.auth),
      messages: new MessagesScreen(this.navigation, this.auth),
      rsvpEligibility: new RsvpEligibilityScreen(this.navigation, this.auth),
      lineups: new LineupsScreen(this.navigation, this.auth),
      adPreview: new AdPreviewScreen(this.navigation, this.auth),
      publicGameday: new PublicGamedayScreen(this.navigation, this.auth),
      publicLineup: new PublicLineupScreen(this.navigation, this.auth),
      publicSchedule: new PublicScheduleScreen(this.navigation, this.auth),
      publicTeamsList: new PublicTeamsListScreen(this.navigation, this.auth),
      publicProgramInfo: new PublicProgramInfoScreen(this.navigation, this.auth),
      my: new MyScreen(this.navigation, this.auth),
      calendar: new CalendarScreen(this.navigation, this.auth),
      playerCalendar: new PlayerCalendarScreen(this.navigation, this.auth),
      playerRoster: new PlayerRosterScreen(this.navigation, this.auth),
      playerTeamRules: new PlayerTeamRulesScreen(this.navigation, this.auth)
    };
    // Expose certain screens globally for legacy inline onclick handlers
    window.adminSystemScreen = this.screens.adminSystem;
    
    // Register all screens with the manager
    this.screenManager.register('login', this.screens.login);
    this.screenManager.register('oauth-success', this.screens.oauthSuccess);
    this.screenManager.register('role-selection', this.screens.roleSelection);
    // Tactical (#tactical) — game model, practice plans, days, exercises, board. See screens/tactical.js.
    this.screenManager.register('tactical', this.screens.tactical);
    this.screenManager.register('marketing-home', this.screens.marketingHome);
    this.screenManager.register('club-selection', this.screens.clubSelection);
    this.screenManager.register('team-dashboard', this.screens.teamDashboard);
    this.screenManager.register('practice-options', this.screens.practiceOptions);
    this.screenManager.register('practice-management', this.screens.practiceManagement);
    this.screenManager.register('practice-form', this.screens.practiceForm);
    this.screenManager.register('practice-list', this.screens.practiceList);
    this.screenManager.register('practice-detail', this.screens.practiceDetail);
    this.screenManager.register('practice-plan', this.screens.practicePlan);
    this.screenManager.register('match-form', this.screens.matchForm);
    this.screenManager.register('match-list', this.screens.matchList);
    this.screenManager.register('match-detail', this.screens.matchDetail);
    this.screenManager.register('admin-level-selection', this.screens.adminLevelSelection);
    this.screenManager.register('admin-entity-list', this.screens.adminEntityList);
    this.screenManager.register('admin-system', this.screens.adminSystem);
    this.screenManager.register('admin-club', this.screens.adminClub);
    this.screenManager.register('game-model-admin', this.screens.gameModelAdmin);
    this.screenManager.register('game-model', this.screens.gameModel);
    this.screenManager.register('player-actions', this.screens.playerActions);
    this.screenManager.register('admin-club-teams', this.screens.adminClubTeams);
    this.screenManager.register('tactical-board', this.screens.tacticalBoard);
    this.screenManager.register('club-directory', this.screens.clubDirectory);
    this.screenManager.register('club-detail', this.screens.clubDetail);
    // Game Center (#game-center) — the one page for a single game:
    // pills for Game Announcement / 20-Man Squad / Starters & Bench /
    // Match Result over one match load. 'game-lineup' stays registered
    // as a backward-compat alias for existing links and bookmarks,
    // same pattern as 'teams'/'rosters' above.
    this.screenManager.register('game-center', this.screens.gameCenter);
    this.screenManager.register('game-lineup', this.screens.gameCenter);
    this.screenManager.register('game-day-roster', this.screens.gameCenter);
    this.screenManager.register('team-hub', this.screens.teamHub);
    this.screenManager.register('match-social', this.screens.matchSocial);
    this.screenManager.register('social-schedule', this.screens.socialSchedule);
    this.screenManager.register('holiday-posts', this.screens.holidayPosts);
    this.screenManager.register('promo-posts', this.screens.promoPosts);
    this.screenManager.register('content-posts', this.screens.contentPosts);
    this.screenManager.register('flyers', this.screens.flyers);
    this.screenManager.register('leads', this.screens.leads);
    this.screenManager.register('leads-analytics', this.screens.leadsAnalytics);
    // Unified Members board (URL: `#members`).
    this.screenManager.register('members', this.screens.members);
    this.screenManager.register('people-workbench', this.screens.peopleWorkbench);
    this.screenManager.register('rosters', this.screens.rosters);
    // 'teams' is the canonical name going forward (absorbs the old
    // #context-selection role=coach picker and #admin-club-teams — see
    // admin-club.js). 'rosters' kept as a backward-compat
    // alias for old bookmarks/links, same pattern as 'lineups' below.
    this.screenManager.register('teams', this.screens.rosters);
    // Universal person profile — reachable from any card that shows a
    // person (Members, Payments, Rosters, …).  See screens/person.js.
    this.screenManager.register('person', this.screens.person);
    this.screenManager.register('youth-roster', this.screens.youthRoster);
    this.screenManager.register('payments', this.screens.payments);
    // Reports hub (#reports) — Attendance & RSVP report; Payments chip
    // hands off to #payments. See screens/reports.js.
    this.screenManager.register('reports', this.screens.reports);
    // RSVP follow-up board (#rsvps) — who owes an answer + tracked reminders.
    // See screens/rsvps.js.
    this.screenManager.register('rsvps', this.screens.rsvps);
    // Uniforms & Kit (#kit) — uniform numbers + kit handed out. See screens/kit.js.
    this.screenManager.register('kit', this.screens.kit);
    // Security (#security) — nightly gate photo check-in + alert log (mig 421/424). See screens/security.js.
    this.screenManager.register('security', this.screens.security);
    // Club Logos (#logos) — crests stored per club + opponent text -> club (mig 428). See screens/club-logos.js.
    this.screenManager.register('logos', this.screens.clubLogos);
    // Files (#files) — uploads kept, shared with members or published by link (mig 455).
    this.screenManager.register('files', this.screens.files);
    // Attendance (#attendance) — the staff page for one calendar event of
    // any kind: who's coming, attendance, 🎟 invites.  See
    // screens/event-center.js.  Was #event-center until 2026-09-24; the old
    // name stays registered so saved history / links still open it.
    this.screenManager.register('attendance', this.screens.eventCenter);
    this.screenManager.register('event-center', this.screens.eventCenter);
    this.screenManager.register('messages', this.screens.messages);
    this.screenManager.register('rsvp-eligibility', this.screens.rsvpEligibility);
    // Mens is the default; womens is the same screen with a gender param.
    // 'mens-lineups'/'womens-lineups' aliases removed 2026-08-15 — dead,
    // nothing ever linked to them; 'lineups' is the one actually in use.
    this.screenManager.register('lineups', this.screens.lineups);
    this.screenManager.register('ad-preview', this.screens.adPreview);
    this.screenManager.register('public-gameday', this.screens.publicGameday);
    this.screenManager.register('public-lineup', this.screens.publicLineup);
    this.screenManager.register('public-schedule', this.screens.publicSchedule);
    this.screenManager.register('public-program-info', this.screens.publicProgramInfo);
    this.screenManager.register('teams-directory', this.screens.publicTeamsList);
    this.screenManager.register('my', this.screens.my);
    // Google Calendar mirror view — CalendarScreen renders the
    // agenda list backed by GET /api/calendar/upcoming (Slice 4).
    // Reached from the Schedule section of admin-club (§10.1).
    this.screenManager.register('calendar', this.screens.calendar);
    this.screenManager.register('player-calendar', this.screens.playerCalendar);
    this.screenManager.register('player-roster', this.screens.playerRoster);
    this.screenManager.register('player-team-rules', this.screens.playerTeamRules);
    
    console.log('App initialized with screens:', Object.keys(this.screens));
  }
  
  start() {
    console.log('Starting app...');

    // Public team views: #t/<slug>/(gameday|lineup|schedule)
    // Anyone can hit these without logging in. We bypass the login redirect
    // and re-route on hashchange so navigating between the 3 sub-views
    // does NOT require a full reload.
    const routePublic = () => {
      const hash = window.location.hash || '';

      // Public flyer/QR-code landing pages: #info/youth, #info/adult.
      // Static content (no team slug, no API fetch) — see
      // frontend/js/screens/public-program-info.js.
      const infoMatch = hash.match(/^#info\/(youth|adult)$/);
      if (infoMatch) {
        this.screenManager.show('public-program-info', { audience: infoMatch[1] });
        return true;
      }

      // Public schedule directory: #schedules — lists every active team
      // with a link to its own #t/<slug>/schedule page (see
      // public-teams-list.js). NOT #teams: that hash is the logged-in
      // rosters board (registered as 'teams' above), and matching it here
      // hijacked the board for coaches/admins (2026-09-03 → 09-05).
      if (hash === '#schedules') {
        this.screenManager.show('teams-directory', {});
        return true;
      }

      const m = hash.match(/^#t\/([^\/]+)\/(gameday|lineup|schedule)$/);
      if (!m) return false;
      const slug = decodeURIComponent(m[1]);
      const view = m[2];
      const screenName = 'public-' + view;
      // Show directly via screenManager so we don't overwrite the pretty hash
      // that the user pinned/shared.
      this.screenManager.show(screenName, { slug });
      return true;
    };

    // FH-native magic-link landing — the legacy /#rsvp/<chatEventId>
    // route was removed 2026-07-17 with the pickup-RSVP rip.  Magic-link
    // verify now unconditionally redirects to /#calendar, so no explicit
    // hash routing is needed on the client side.

    window.addEventListener('hashchange', () => {
      if (routePublic()) return;
    });

    if (routePublic()) {
      console.log('Routed to public team view');
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
      // A link to one game — the squad game reminder (mig 383/384) sends
      // #game-center/<matchId>/<pill>, and a magic link lands on the same
      // hash — opens that game in the player view, like the #my door.
      // Everything else resumes at role selection.
      const game = (window.location.hash || '').match(/^#game-center\/(\d+)(?:\/([a-z_]+))?$/);
      if (game) {
        this.navigation.context.role = this.navigation.context.role || 'player';
        this.navigation.goTo('game-center', { matchId: Number(game[1]), postType: game[2] || null });
        return;
      }
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
