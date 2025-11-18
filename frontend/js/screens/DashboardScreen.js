/**
 * DashboardScreen - Role-specific dashboard interface
 * 
 * This screen manages role-specific dashboards with its own state machine:
 * loading -> ready -> action -> ready
 * Also handles different role types (admin, coach, player) with sub-states
 */
class DashboardScreen extends Screen {
    constructor(container, props = {}) {
        super(container, props, {
            screenName: 'dashboard'
        });
        
        this.roleSelection = null;
        this.roleType = null;
        this.dashboardComponents = {};
        this.actionFeedback = null;
        
        // Create state machine after this is fully initialized
        this.stateMachine = new StateMachine({
            initial: 'loading',
            states: {
                loading: {
                    on: { 
                        ROLE_LOADED: 'ready',
                        ERROR: 'error'
                    },
                    onEntry: () => this.showLoading(),
                    onExit: () => this.hideLoading()
                },
                ready: {
                    on: { 
                        ACTION_START: 'action',
                        BACK_TO_ROLES: 'navigating',
                        LOGOUT: 'logout'
                    },
                    onEntry: () => this.showDashboard(),
                    onExit: () => this.hideDashboard()
                },
                action: {
                    on: { 
                        ACTION_COMPLETE: 'ready',
                        ACTION_ERROR: 'ready'
                    },
                    onEntry: (actionData) => this.handleAction(actionData),
                    onExit: () => this.cleanupAction()
                },
                navigating: {
                    on: { 
                        COMPLETE: 'ready'
                    },
                    onEntry: (navigationData) => this.navigate(navigationData)
                },
                error: {
                    on: { 
                        RETRY: 'loading',
                        BACK_TO_ROLES: 'navigating',
                        LOGOUT: 'logout'
                    },
                    onEntry: (error) => this.showError(error),
                    onExit: () => this.hideError()
                },
                logout: {
                    onEntry: () => this.handleLogout()
                }
            }
        });
        
        // Listen for state changes for debugging
        this.stateMachine.onStateChange((prevState, newState, event, payload) => {
            console.log(`📱 DashboardScreen: ${prevState} --[${event}]--> ${newState}`);
        });
    }
    
    render() {
        return `
            <div class="dashboard-screen">
                <!-- Loading State -->
                <div id="loadingContainer" class="loading-container" style="display: none;">
                    <div class="min-h-screen flex items-center justify-center">
                        <div class="text-center">
                            <div class="loading-spinner"></div>
                            <p class="mt-4">Loading dashboard...</p>
                        </div>
                    </div>
                </div>
                
                <!-- Dashboard Content -->
                <div id="dashboardContainer" class="dashboard-container" style="display: none;">
                    <!-- Dynamic dashboard content will be inserted here -->
                </div>
                
                <!-- Error State -->
                <div id="errorContainer" class="error-container" style="display: none;">
                    <div class="min-h-screen flex items-center justify-center">
                        <div class="text-center">
                            <h2>Dashboard Error</h2>
                            <p id="errorText" class="mt-4">Unable to load dashboard.</p>
                            <div class="mt-6">
                                <button id="retryBtn" class="btn btn-primary mr-4">Try Again</button>
                                <button id="backBtn" class="btn btn-secondary mr-4">Back</button>
                                <button id="logoutBtn" class="btn btn-secondary">Logout</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }
    
    async onEnter(data = null) {
        console.log('📱 DashboardScreen: onEnter called with data:', data);
        await super.onEnter(data);
        
        // Clear any previous state
        this.cleanupDashboardComponents();
        this.roleSelection = null;
        this.roleType = null;
        this.teamContext = null;
        
        this.roleSelection = data?.roleSelection;
        
        if (!this.roleSelection) {
            console.error('📱 DashboardScreen: No role selection provided');
            this.send('ERROR', { message: 'No role selection data available' });
            return;
        }
        
        this.roleType = this.roleSelection.roleType;
        
        // Extract team context - check both direct teamContext and from roleData
        if (data?.teamContext) {
            this.teamContext = data.teamContext;
        } else if (this.roleSelection.roleData) {
            this.teamContext = {
                id: this.roleSelection.roleData.teamId,
                name: this.roleSelection.roleData.teamName,
                club: this.roleSelection.roleData.clubName
            };
        }
        
        console.log('📱 DashboardScreen: ✅ ROLE SET TO:', this.roleType, '| roleSelection:', this.roleSelection);
        console.log('📱 DashboardScreen: ✅ TEAM CONTEXT:', this.teamContext);
        
        // Update role state machine with team context immediately
        if (window.roleStateMachine && this.teamContext) {
            window.roleStateMachine.updateTeamContext(this.teamContext);
            console.log('📱 DashboardScreen: ✅ Updated role state machine with team context:', this.teamContext);
        }
        
        // Simulate loading time for better UX
        setTimeout(() => {
            this.send('ROLE_LOADED');
        }, 300);
    }
    
    showLoading() {
        this.showContainer('loadingContainer');
    }
    
    hideLoading() {
        this.hideContainer('loadingContainer');
    }
    
    showDashboard() {
        this.showContainer('dashboardContainer');
        this.renderDashboardContent();
        this.setupDashboardEvents();
    }
    
    hideDashboard() {
        this.hideContainer('dashboardContainer');
        this.cleanupDashboardComponents();
    }
    
    renderDashboardContent() {
        const container = this.element.querySelector('#dashboardContainer');
        if (!container) return;
        
        // For coach role, use the CoachDashboard component
        if (this.roleType === 'coach') {
            this.renderCoachDashboardComponent(container);
            return;
        }
        
        // For other roles, use inline HTML rendering (for now)
        let dashboardHTML = '';
        
        switch (this.roleType) {
            case 'admin':
                dashboardHTML = this.renderAdminDashboard();
                break;
            case 'player':
                dashboardHTML = this.renderPlayerDashboard();
                break;
            default:
                dashboardHTML = this.renderGenericDashboard();
        }
        
        container.innerHTML = dashboardHTML;
    }
    
    renderCoachDashboardComponent(container) {
        // Clean up existing coach dashboard if any
        if (this.dashboardComponents.coachDashboard) {
            this.dashboardComponents.coachDashboard.unmount();
        }
        
        // Use stored team context
        const teamContext = this.teamContext;
        
        if (!teamContext) {
            console.error('📱 DashboardScreen: No team context available for coach dashboard');
            return;
        }
        
        // Store team context for role state machine (redundant but safe)
        if (window.roleStateMachine && teamContext) {
            window.roleStateMachine.updateTeamContext(teamContext);
            console.log('📱 DashboardScreen: Confirmed role state machine has team context:', teamContext);
        }
        
        // Create CoachDashboard component
        const coachDashboard = new CoachDashboard(container, {
            user: this.roleSelection.user,
            roleType: 'coach',
            roleData: this.roleSelection.roleData,
            teamContext: teamContext
        });
        
        // Listen for navigation events from dashboard
        container.addEventListener('navigate', (event) => {
            console.log('📱 DashboardScreen: Navigation event from CoachDashboard:', event.detail);
            
            // Use role state machine if available
            if (window.roleStateMachine && event.detail.screen === 'eventTypeSelection') {
                console.log('📱 DashboardScreen: Using role state machine for navigation to events');
                window.roleStateMachine.send('NAVIGATE_TO_EVENTS');
            } else if (event.detail.screen) {
                // Fallback for other navigation
                this.navigateTo(event.detail.screen, event.detail.data);
            }
        });
        
        // Listen for logout events
        container.addEventListener('logout', () => {
            console.log('📱 DashboardScreen: Logout event from CoachDashboard');
            this.send('LOGOUT');
        });
        
        // Mount the dashboard
        coachDashboard.mount();
        
        // Store reference
        this.dashboardComponents.coachDashboard = coachDashboard;
    }
    
    renderAdminDashboard() {
        return `
            <div class="admin-dashboard">
                <nav class="navbar">
                    <div class="navbar-brand">
                        <span class="brand-text">Football Home - Administrator</span>
                    </div>
                    <div class="navbar-menu">
                        <button id="backToRolesBtn" class="btn btn-secondary btn-sm">Back</button>
                        <button id="logoutBtn" class="btn btn-secondary btn-sm">Logout</button>
                    </div>
                </nav>
                
                <main class="admin-main">
                    <div class="admin-header">
                        <h2>System Administration</h2>
                        <p>Manage the Football Home system</p>
                    </div>
                    
                    <div class="admin-grid">
                        <div class="admin-card" data-action="user-management">
                            <div class="admin-card-icon">👥</div>
                            <h3>User Management</h3>
                            <p>Manage users, roles, and permissions</p>
                            <button class="btn btn-primary">Manage Users</button>
                        </div>
                        
                        <div class="admin-card" data-action="team-management">
                            <div class="admin-card-icon">🏈</div>
                            <h3>Team Management</h3>
                            <p>Manage teams, players, and coaches</p>
                            <button class="btn btn-primary">Manage Teams</button>
                        </div>
                        
                        <div class="admin-card" data-action="league-management">
                            <div class="admin-card-icon">🏆</div>
                            <h3>League Management</h3>
                            <p>Manage leagues, divisions, and seasons</p>
                            <button class="btn btn-primary">Manage Leagues</button>
                        </div>
                        
                        <div class="admin-card" data-action="system-stats">
                            <div class="admin-card-icon">📊</div>
                            <h3>System Stats</h3>
                            <p>View system statistics and reports</p>
                            <button class="btn btn-primary">View Stats</button>
                        </div>
                    </div>
                </main>
            </div>
        `;
    }
    
    renderCoachDashboard() {
        const teamName = this.roleSelection.roleData?.teamName || 'Your Team';
        
        return `
            <div class="coach-dashboard">
                <nav class="navbar">
                    <div class="navbar-brand">
                        <span class="brand-text">Football Home - Coach</span>
                    </div>
                    <div class="navbar-menu">
                        <span class="navbar-team">${teamName}</span>
                        <button id="backToRolesBtn" class="btn btn-secondary btn-sm">Back</button>
                        <button id="logoutBtn" class="btn btn-secondary btn-sm">Logout</button>
                    </div>
                </nav>
                
                <main class="coach-main">
                    <div class="coach-header">
                        <h2>Coach Dashboard</h2>
                        <p>Manage your team: ${teamName}</p>
                    </div>
                    
                    <div class="coach-grid">
                        <div class="coach-card" data-action="team-roster">
                            <div class="coach-card-icon">👥</div>
                            <h3>Team Roster</h3>
                            <p>View and manage team players</p>
                            <button class="btn btn-primary">View Roster</button>
                        </div>
                        
                        <div class="coach-card" data-action="practice-schedule">
                            <div class="coach-card-icon">📅</div>
                            <h3>Practice Schedule</h3>
                            <p>Schedule and manage team practices</p>
                            <button class="btn btn-primary">Manage Schedule</button>
                        </div>
                        
                        <div class="coach-card" data-action="game-planning">
                            <div class="coach-card-icon">🎯</div>
                            <h3>Game Planning</h3>
                            <p>Create game plans and strategies</p>
                            <button class="btn btn-primary">Plan Games</button>
                        </div>
                        
                        <div class="coach-card" data-action="player-stats">
                            <div class="coach-card-icon">📊</div>
                            <h3>Player Statistics</h3>
                            <p>View player performance stats</p>
                            <button class="btn btn-primary">View Stats</button>
                        </div>
                    </div>
                </main>
            </div>
        `;
    }
    
    renderPlayerDashboard() {
        const teamName = this.roleSelection.roleData?.teamName || 'Your Team';
        const jerseyNumber = this.roleSelection.roleData?.jerseyNumber || '';
        
        return `
            <div class="player-dashboard">
                <nav class="navbar">
                    <div class="navbar-brand">
                        <span class="brand-text">Football Home - Player</span>
                    </div>
                    <div class="navbar-menu">
                        <span class="navbar-team">${teamName} ${jerseyNumber ? `#${jerseyNumber}` : ''}</span>
                        <button id="backToRolesBtn" class="btn btn-secondary btn-sm">Back</button>
                        <button id="logoutBtn" class="btn btn-secondary btn-sm">Logout</button>
                    </div>
                </nav>
                
                <main class="player-main">
                    <div class="player-header">
                        <h2>Player Dashboard</h2>
                        <p>Your team: ${teamName} ${jerseyNumber ? `(Jersey #${jerseyNumber})` : ''}</p>
                    </div>
                    
                    <!-- Main Action -->
                    <div class="main-action-container">
                        <button id="eventsBtn" class="btn btn-primary btn-xl">
                            <span class="icon">📅</span>
                            <span class="btn-text">Events</span>
                        </button>
                        <p class="action-description">View and RSVP to practices, games, and meetings</p>
                    </div>
                    
                    <div class="player-grid">
                        <div class="player-card" data-action="my-stats">
                            <div class="player-card-icon">�</div>
                            <h3>My Statistics</h3>
                            <p>View your performance stats</p>
                            <button class="btn btn-primary">View Stats</button>
                        </div>
                        
                        <div class="player-card" data-action="team-info">
                            <div class="player-card-icon">🏈</div>
                            <h3>Team Information</h3>
                            <p>View team roster and information</p>
                            <button class="btn btn-primary">Team Info</button>
                        </div>
                        
                        <div class="player-card" data-action="achievements">
                            <div class="player-card-icon">🏆</div>
                            <h3>Achievements</h3>
                            <p>View your awards and milestones</p>
                            <button class="btn btn-primary">View Achievements</button>
                        </div>
                    </div>
                </main>
            </div>
        `;
    }
    
    renderGenericDashboard() {
        return `
            <div class="generic-dashboard">
                <nav class="navbar">
                    <div class="navbar-brand">
                        <span class="brand-text">Football Home - ${this.roleType}</span>
                    </div>
                    <div class="navbar-menu">
                        <button id="backToRolesBtn" class="btn btn-secondary btn-sm">Back</button>
                        <button id="logoutBtn" class="btn btn-secondary btn-sm">Logout</button>
                    </div>
                </nav>
                
                <main class="dashboard-main">
                    <h2>${this.roleType.charAt(0).toUpperCase() + this.roleType.slice(1)} Dashboard</h2>
                    <p>Dashboard for ${this.roleSelection.roleData?.teamName || 'your role'}</p>
                    <p>This dashboard is under development.</p>
                </main>
            </div>
        `;
    }
    
    setupDashboardEvents() {
        // Navigation buttons
        const backBtn = this.element.querySelector('#backToRolesBtn');
        const logoutBtn = this.element.querySelector('#logoutBtn');
        
        if (backBtn) {
            backBtn.addEventListener('click', () => {
                console.log('📱 DashboardScreen: Back to roles clicked');
                this.send('BACK_TO_ROLES');
            });
        }
        
        if (logoutBtn) {
            logoutBtn.addEventListener('click', () => {
                console.log('📱 DashboardScreen: Logout clicked');
                this.send('LOGOUT');
            });
        }
        
        // Events button (for both coach and player)
        const eventsBtn = this.element.querySelector('#eventsBtn');
        if (eventsBtn) {
            eventsBtn.addEventListener('click', () => {
                console.log('📱 DashboardScreen: Events button clicked for', this.roleType);
                
                // Extract team context from role selection
                const teamContext = this.roleSelection.roleData ? {
                    id: this.roleSelection.roleData.teamId,
                    name: this.roleSelection.roleData.teamName,
                    club: this.roleSelection.roleData.clubName
                } : null;
                
                // Use role state machine for navigation if available
                if (window.roleStateMachine) {
                    console.log('📱 DashboardScreen: Using role state machine to navigate to events');
                    window.roleStateMachine.send('NAVIGATE_TO_EVENTS');
                } else {
                    // Fallback: Navigate to EventTypeSelection screen directly
                    this.navigateTo('eventTypeSelection', {
                        user: this.roleSelection.user,
                        teamContext: teamContext,
                        roleType: this.roleType
                    });
                }
            });
        }
        
        // Action cards
        const actionCards = this.element.querySelectorAll('[data-action]');
        actionCards.forEach(card => {
            const button = card.querySelector('button');
            if (button) {
                button.addEventListener('click', () => {
                    const action = card.getAttribute('data-action');
                    console.log('📱 DashboardScreen: Action clicked:', action);
                    this.send('ACTION_START', { action, roleType: this.roleType });
                });
            }
        });
    }
    
    handleAction(actionData) {
        console.log('📱 DashboardScreen: Handling action:', actionData);
        
        // For now, just show a placeholder message
        const message = `Action "${actionData.action}" for ${actionData.roleType} - Coming Soon!`;
        
        // Show temporary feedback
        this.showActionFeedback(message);
        
        // Complete the action after a short delay
        setTimeout(() => {
            this.send('ACTION_COMPLETE');
        }, 2000);
    }
    
    showActionFeedback(message) {
        // Create temporary feedback overlay
        const feedback = document.createElement('div');
        feedback.className = 'action-feedback';
        feedback.innerHTML = `
            <div class="feedback-content">
                <p>${message}</p>
                <div class="loading-spinner"></div>
            </div>
        `;
        feedback.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1000;
        `;
        
        document.body.appendChild(feedback);
        
        // Store reference for cleanup
        this.actionFeedback = feedback;
    }
    
    cleanupAction() {
        if (this.actionFeedback) {
            document.body.removeChild(this.actionFeedback);
            this.actionFeedback = null;
        }
    }
    
    navigate(navigationData) {
        console.log('📱 DashboardScreen: Navigating back to roles');
        
        setTimeout(() => {
            this.navigateTo('roleSwitchboard', { user: this.roleSelection.user });
            this.send('COMPLETE');
        }, 100);
    }
    
    showError(error) {
        this.showContainer('errorContainer');
        
        const errorText = this.element.querySelector('#errorText');
        if (errorText) {
            errorText.textContent = error.message || 'An error occurred';
        }
        
        // Setup error buttons
        const retryBtn = this.element.querySelector('#retryBtn');
        const backBtn = this.element.querySelector('#backBtn');
        const logoutBtn = this.element.querySelector('#logoutBtn');
        
        if (retryBtn) {
            retryBtn.onclick = () => this.send('RETRY');
        }
        
        if (backBtn) {
            backBtn.onclick = () => this.send('BACK_TO_ROLES');
        }
        
        if (logoutBtn) {
            logoutBtn.onclick = () => this.send('LOGOUT');
        }
    }
    
    hideError() {
        this.hideContainer('errorContainer');
    }
    
    handleLogout() {
        console.log('📱 DashboardScreen: Handling logout');
        
        setTimeout(() => {
            this.navigateTo('login');
        }, 100);
    }
    
    showContainer(containerId) {
        // Hide all containers
        ['loadingContainer', 'dashboardContainer', 'errorContainer'].forEach(id => {
            const container = this.element.querySelector(`#${id}`);
            if (container) container.style.display = 'none';
        });
        
        // Show target container
        const targetContainer = this.element.querySelector(`#${containerId}`);
        if (targetContainer) targetContainer.style.display = 'block';
    }
    
    hideContainer(containerId) {
        const container = this.element.querySelector(`#${containerId}`);
        if (container) container.style.display = 'none';
    }
    
    cleanupDashboardComponents() {
        // Clean up any dashboard-specific components
        Object.values(this.dashboardComponents).forEach(component => {
            if (component.cleanup) {
                component.cleanup();
            }
        });
        this.dashboardComponents = {};
        
        // Clean up action feedback
        this.cleanupAction();
    }
    
    async onExit() {
        console.log('📱 DashboardScreen: Exiting');
        
        this.cleanupDashboardComponents();
        this.roleSelection = null;
        this.roleType = null;
        
        await super.onExit();
    }
}