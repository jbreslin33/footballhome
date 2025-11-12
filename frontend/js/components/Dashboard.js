/**
 * Dashboard Component
 * Main dashboard that orchestrates all dashboard cards
 */
class Dashboard extends Component {
    constructor(container, user = {}) {
        super(container, { user });
        this.user = user;
        this.cardComponents = [];
    }

    render() {
        return `
            <div class="dashboard">
                <!-- Navigation Header -->
                <nav class="navbar">
                    <div class="navbar-brand">
                        <span class="brand-text">Football Home</span>
                    </div>
                    <div class="navbar-menu">
                        <span class="navbar-user">Welcome, ${this.user.name || 'User'}</span>
                        <button id="logoutBtn" class="btn btn-secondary btn-sm">Logout</button>
                    </div>
                </nav>
                
                <!-- Main Dashboard Content -->
                <main class="dashboard-main">
                    <div class="dashboard-header">
                        <h2 class="dashboard-title">Dashboard</h2>
                        <p class="dashboard-subtitle">
                            Welcome to your Football Home dashboard! Now with component-based architecture.
                        </p>
                    </div>
                    
                    <!-- Dashboard Cards Grid -->
                    <div class="dashboard-grid">
                        <div class="dashboard-card team-section" data-card="team"></div>
                        <div class="dashboard-card events-section" data-card="events"></div>
                        <div class="dashboard-card stats-section" data-card="stats"></div>
                        <div class="dashboard-card league-section" data-card="league"></div>
                    </div>
                    
                    <!-- Features Info -->
                    <div class="dashboard-info">
                        <h4 class="info-title">🎯 OOP Features Demonstrated:</h4>
                        <ul class="info-list">
                            <li>✅ Component-based dashboard architecture</li>
                            <li>✅ Individual card components with focused responsibilities</li>
                            <li>✅ Event-driven component communication</li>
                            <li>✅ Reusable component base class</li>
                            <li>✅ Clean separation of concerns</li>
                        </ul>
                    </div>
                </main>
            </div>
        `;
    }

    setupEventListeners() {
        // Setup logout functionality
        const logoutBtn = this.querySelector('#logoutBtn');
        if (logoutBtn) {
            this.addEventListener(logoutBtn, 'click', this.handleLogout);
        }
    }

    onMounted() {
        // Initialize card components after the dashboard is mounted
        this.initializeCardComponents();
        this.setupCardEventListeners();
    }

    initializeCardComponents() {
        // Sample data - in a real app, this would come from services
        const sampleData = this.generateSampleData();

        // Create and mount card components
        const teamSection = this.querySelector('.team-section');
        const teamCard = new TeamCard(teamSection, sampleData.teams);
        teamCard.mount();
        this.cardComponents.push(teamCard);

        const eventsSection = this.querySelector('.events-section');
        const eventCard = new EventCard(eventsSection, sampleData.events);
        eventCard.mount();
        this.cardComponents.push(eventCard);

        const statsSection = this.querySelector('.stats-section');
        const statsCard = new StatsCard(statsSection, sampleData.stats);
        statsCard.mount();
        this.cardComponents.push(statsCard);

        const leagueSection = this.querySelector('.league-section');
        const leagueCard = new LeagueGamesCard(leagueSection, sampleData.leagues);
        leagueCard.mount();
        this.cardComponents.push(leagueCard);

        console.log('Dashboard: All card components initialized');
    }

    setupCardEventListeners() {
        // Listen to events from card components by listening on their DOM elements
        this.cardComponents.forEach(card => {
            if (card.element) {
                // Team events
                this.addEventListener(card.element, 'team:create', () => this.handleTeamCreate());
                this.addEventListener(card.element, 'team:viewAll', () => this.handleTeamViewAll());
                this.addEventListener(card.element, 'team:select', (e) => this.handleTeamSelect(e.detail));

                // Event events
                this.addEventListener(card.element, 'event:create', () => this.handleEventCreate());
                this.addEventListener(card.element, 'event:viewCalendar', () => this.handleEventViewCalendar());
                this.addEventListener(card.element, 'event:select', (e) => this.handleEventSelect(e.detail));

                // Stats events
                this.addEventListener(card.element, 'stats:viewDetails', (e) => this.handleStatsViewDetails(e.detail));
                this.addEventListener(card.element, 'stats:export', (e) => this.handleStatsExport(e.detail));

                // League events
                this.addEventListener(card.element, 'league:viewStandings', () => this.handleLeagueViewStandings());
                this.addEventListener(card.element, 'league:sync', () => this.handleLeagueSync());
                this.addEventListener(card.element, 'league:select', (e) => this.handleLeagueSelect(e.detail));
            }
        });
    }

    // Team event handlers
    handleTeamCreate() {
        console.log('Dashboard: Creating new team...');
        // TODO: Open team creation form
        alert('Team creation form would open here');
    }

    handleTeamViewAll() {
        console.log('Dashboard: Viewing all teams...');
        // TODO: Navigate to teams page
        alert('Teams page would open here');
    }

    handleTeamSelect(data) {
        console.log('Dashboard: Team selected:', data.teamName);
        // TODO: Navigate to team details
        alert(`Team details for "${data.teamName}" would open here`);
    }

    // Event event handlers
    handleEventCreate() {
        console.log('Dashboard: Creating new event...');
        alert('Event creation form would open here');
    }

    handleEventViewCalendar() {
        console.log('Dashboard: Viewing calendar...');
        alert('Calendar view would open here');
    }

    handleEventSelect(data) {
        console.log('Dashboard: Event selected:', data.eventTitle);
        alert(`Event details for "${data.eventTitle}" would open here`);
    }

    // Stats event handlers
    handleStatsViewDetails(data) {
        console.log('Dashboard: Viewing detailed stats:', data);
        alert('Detailed stats view would open here');
    }

    handleStatsExport(data) {
        console.log('Dashboard: Exporting stats:', data);
        alert('Stats export would start here');
    }

    // League event handlers
    handleLeagueViewStandings() {
        console.log('Dashboard: Viewing league standings...');
        alert('League standings would open here');
    }

    handleLeagueSync() {
        console.log('Dashboard: Syncing league data...');
        // This could trigger actual API calls in a real implementation
    }

    handleLeagueSelect(data) {
        console.log('Dashboard: League selected:', data.leagueName);
        alert(`League details for "${data.leagueName}" would open here`);
    }

    // Logout handler
    handleLogout() {
        console.log('Dashboard: Logout clicked');
        this.emit('user:logout');
    }

    // Generate sample data for demonstration
    generateSampleData() {
        return {
            teams: [
                { name: 'Thunder FC', memberCount: 18, status: 'active' },
                { name: 'Lightning United', memberCount: 22, status: 'active' },
                { name: 'Storm Warriors', memberCount: 15, status: 'inactive' }
            ],
            events: [
                { 
                    title: 'vs Lightning FC', 
                    date: new Date(Date.now() + 86400000 * 3).toISOString(), 
                    status: 'confirmed' 
                },
                { 
                    title: 'Team Practice', 
                    date: new Date(Date.now() + 86400000 * 7).toISOString(), 
                    status: 'scheduled' 
                },
                { 
                    title: 'League Tournament', 
                    date: new Date(Date.now() + 86400000 * 14).toISOString(), 
                    status: 'scheduled' 
                }
            ],
            stats: {
                gamesPlayed: 15,
                wins: 10,
                goals: 8,
                assists: 12
            },
            leagues: [
                { name: 'Metro Division A', position: 3 },
                { name: 'City Cup League', position: 7 },
                { name: 'Regional Championship', position: 12 }
            ]
        };
    }

    // Update user data
    updateUser(userData) {
        this.user = { ...this.user, ...userData };
        this.update();
    }

    // Cleanup method
    onUnmounted() {
        // Clean up card components
        this.cardComponents.forEach(card => {
            if (card.cleanup) {
                card.cleanup();
            }
        });
        this.cardComponents = [];
    }
}