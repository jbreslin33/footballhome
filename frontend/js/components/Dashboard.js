/**
 * Dashboard Component
 * Main dashboard that orchestrates all dashboard cards
 */
class Dashboard extends Component {
    constructor(container, user = {}) {
        console.log('Dashboard: Constructor called with user:', user);
        console.log('Dashboard: Container:', container);
        console.log('Dashboard: user type:', typeof user);
        
        try {
            super(container, { user });
            this.user = user || {};
            this.cardComponents = [];
            console.log('Dashboard: this.user after assignment:', this.user);
            console.log('Dashboard: Constructor completed successfully');
        } catch (error) {
            console.error('Dashboard: Constructor error:', error);
            throw error;
        }
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
                        <span class="navbar-user">Welcome, ${this.user && this.user.name ? this.user.name : 'User'}</span>
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
        console.log('Dashboard: onMounted called');
        
        try {
            // Initialize card components after the dashboard is mounted
            console.log('Dashboard: Initializing card components...');
            this.initializeCardComponents();
            
            console.log('Dashboard: Setting up card event listeners...');
            this.setupCardEventListeners();
            
            console.log('Dashboard: onMounted completed successfully');
        } catch (error) {
            console.error('Dashboard: onMounted error:', error);
            console.error('Dashboard: onMounted error stack:', error.stack);
        }
    }

    initializeCardComponents() {
        console.log('Dashboard: initializeCardComponents called');
        
        try {
            // Sample data - in a real app, this would come from services
            console.log('Dashboard: Generating sample data...');
            const sampleData = this.generateSampleData();
            console.log('Dashboard: Sample data generated:', sampleData);

            // Create and mount all card components
            console.log('Dashboard: Finding team section...');
            const teamSection = this.querySelector('.team-section');
            if (teamSection) {
                console.log('Dashboard: Creating TeamCard...');
                const teamCard = new TeamCard(teamSection, sampleData.teams);
                teamCard.mount();
                this.cardComponents.push(teamCard);
                console.log('Dashboard: TeamCard created and mounted successfully');
            }

            console.log('Dashboard: Finding events section...');
            const eventsSection = this.querySelector('.events-section');
            if (eventsSection) {
                console.log('Dashboard: Creating EventCard...');
                const eventCard = new EventCard(eventsSection, sampleData.events);
                eventCard.mount();
                this.cardComponents.push(eventCard);
                console.log('Dashboard: EventCard created and mounted successfully');
            }

            console.log('Dashboard: Finding stats section...');
            const statsSection = this.querySelector('.stats-section');
            if (statsSection) {
                console.log('Dashboard: Creating StatsCard...');
                const statsCard = new StatsCard(statsSection, sampleData.stats);
                statsCard.mount();
                this.cardComponents.push(statsCard);
                console.log('Dashboard: StatsCard created and mounted successfully');
            }

            console.log('Dashboard: Finding league section...');
            const leagueSection = this.querySelector('.league-section');
            if (leagueSection) {
                console.log('Dashboard: Creating LeagueGamesCard...');
                const leagueCard = new LeagueGamesCard(leagueSection, sampleData.leagues);
                leagueCard.mount();
                this.cardComponents.push(leagueCard);
                console.log('Dashboard: LeagueGamesCard created and mounted successfully');
            }

            console.log('Dashboard: All card components initialized, total:', this.cardComponents.length);
        } catch (error) {
            console.error('Dashboard: Error in initializeCardComponents:', error);
            console.error('Dashboard: Error stack:', error.stack);
            throw error;
        }
    }

    setupCardEventListeners() {
        console.log('Dashboard: setupCardEventListeners called with', this.cardComponents.length, 'components');
        
        // Listen to events from card components by listening on their DOM elements
        this.cardComponents.forEach((card, index) => {
            console.log('Dashboard: Setting up listeners for card', index, card);
            
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
            } else {
                console.warn('Dashboard: Card has no element:', card);
            }
        });
        
        console.log('Dashboard: Event listeners setup complete');
    }

    // Team event handlers
    handleTeamCreate() {
        console.log('Dashboard: Creating new team...');
        // TODO: Open team creation form
        alert('🏗️ Team Creation\n\nThis would open a form to create a new team with:\n• Team name\n• League selection\n• Member invitations');
    }

    handleTeamViewAll() {
        console.log('Dashboard: Viewing all teams...');
        // TODO: Navigate to teams page
        alert('👥 All Teams View\n\nThis would show a full list of your teams with:\n• Team roster management\n• Performance stats\n• Schedule overview');
    }

    handleTeamSelect(data) {
        console.log('Dashboard: Team selected:', data.teamName);
        // TODO: Navigate to team details
        alert(`⚽ Team: ${data.teamName}\n\nThis would open detailed team management with:\n• Player roster\n• Upcoming games\n• Team statistics\n• Practice schedule`);
    }

    // Event event handlers
    handleEventCreate() {
        console.log('Dashboard: Creating new event...');
        alert('📅 Schedule Event\n\nThis would open an event creation form with:\n• Event type (match, practice, meeting)\n• Date and time selection\n• Venue selection\n• Team/player invitations');
    }

    handleEventViewCalendar() {
        console.log('Dashboard: Viewing calendar...');
        alert('🗓️ Calendar View\n\nThis would show a full calendar with:\n• Monthly/weekly views\n• All team events\n• Personal schedule\n• RSVP management');
    }

    handleEventSelect(data) {
        console.log('Dashboard: Event selected:', data.eventTitle);
        alert(`🎯 Event: ${data.eventTitle}\n\nThis would show event details with:\n• Event information\n• Attendee list\n• Location details\n• RSVP options`);
    }

    // Stats event handlers
    handleStatsViewDetails(data) {
        console.log('Dashboard: Viewing detailed stats:', data);
        alert('📊 Detailed Statistics\n\nThis would show comprehensive stats with:\n• Performance trends\n• Comparison charts\n• Season summaries\n• Goal/assist breakdowns');
    }

    handleStatsExport(data) {
        console.log('Dashboard: Exporting stats:', data);
        alert('📁 Export Statistics\n\nThis would allow you to:\n• Download as CSV/PDF\n• Email to coach\n• Share with team\n• Print reports');
    }

    // League event handlers
    handleLeagueViewStandings() {
        console.log('Dashboard: Viewing league standings...');
        alert('🏆 League Standings\n\nThis would show:\n• Current league table\n• Team rankings\n• Points and goal difference\n• Promotion/relegation zones');
    }

    handleLeagueSync() {
        console.log('Dashboard: Syncing league data...');
        alert('🔄 Syncing League Data\n\nThis would:\n• Update standings from APSL\n• Refresh game schedules\n• Update player statistics\n• Sync venue information');
        // This could trigger actual API calls in a real implementation
    }

    handleLeagueSelect(data) {
        console.log('Dashboard: League selected:', data.leagueName);
        alert(`🏆 League: ${data.leagueName}\n\nThis would show:\n• League information\n• Your team's position\n• Upcoming fixtures\n• League news and updates`);
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