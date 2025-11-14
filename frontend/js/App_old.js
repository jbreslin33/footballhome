/**
 * Main Application
 * Orchestrates the screen-based architecture with ScreenManager
 */
class App {
    constructor() {
        this.container = document.getElementById('app');
        this.authService = new AuthService();
        this.currentUser = null;
        
        // Initialize application state machine for high-level app states
        this.appStateMachine = new StateMachine({
            initial: 'initializing',
            states: {
                initializing: {
                    on: { 
                        READY: 'running',
                        ERROR: 'error'
                    },
                    onEntry: () => this.initializeApp(),
                    onExit: () => console.log('🚀 App: Initialization complete')
                },
                running: {
                    on: { 
                        MAINTENANCE: 'maintenance',
                        ERROR: 'error',
                        SHUTDOWN: 'shutdown'
                    },
                    onEntry: () => this.startApplication(),
                    onExit: () => console.log('🚀 App: Stopping application')
                },
                maintenance: {
                    on: { 
                        RESUME: 'running',
                        SHUTDOWN: 'shutdown'
                    },
                    onEntry: () => this.showMaintenance(),
                    onExit: () => this.hideMaintenance()
                },
                error: {
                    on: { 
                        RETRY: 'initializing',
                        SHUTDOWN: 'shutdown'
                    },
                    onEntry: (error) => this.showError(error),
                    onExit: () => this.hideError()
                },
                shutdown: {
                    onEntry: () => this.cleanup()
                }
            }
        });
        
        // Listen for app state changes
        this.appStateMachine.onStateChange((prevState, newState, event, payload) => {
            console.log(`🚀 App: ${prevState} --[${event}]--> ${newState}`);
        });
        
        console.log('🚀 Football Home OOP App with ScreenManager initialized');
        
        // Start the application
        this.appStateMachine.send('READY');
    }
    
    async init() {
        // Check if user is already logged in
        if (this.authService.isAuthenticated()) {
            const userResult = await this.authService.getCurrentUser();
            
            if (userResult.success) {
                console.log('User already authenticated:', userResult.user);
                this.currentUser = userResult.user;
                this.stateMachine.send('USER_AUTHENTICATED', userResult.user);
                this.replaceHistory('roleSwitchboard', { user: userResult.user });
                return;
            }
        }
        
        // Show login form
        this.stateMachine.send('LOGIN_REQUIRED');
        this.replaceHistory('login');
    }
    
    replaceHistory(page, data = {}) {
        const state = { page, data, timestamp: Date.now() };
        console.log('🔄 Replacing history:', state);
        history.replaceState(state, `Football Home - ${page}`, `#${page}`);
    }
    
    setupNavigationProtection() {
        // Prevent form submissions from navigating away
        document.addEventListener('submit', (e) => {
            if (e.target.method === 'get') {
                e.preventDefault();
                console.log('🛡️ Prevented form navigation');
            }
        });
        
        // Handle beforeunload for protection
        window.addEventListener('beforeunload', (e) => {
            if (this.authService.isAuthenticated()) {
                console.log('🛡️ User attempting to leave while authenticated');
                // Could add confirmation dialog here if needed
            }
        });
    }
    
    ensureInitialHistoryState() {
        // If there's no history state, create one to prevent going off-site
        if (!history.state) {
            console.log('🛡️ Creating initial history state to prevent off-site navigation');
            const initialState = { 
                page: 'app-entry', 
                data: {}, 
                timestamp: Date.now(),
                isInitial: true 
            };
            history.replaceState(initialState, 'Football Home', location.href);
        }
    }
    
    setupHistoryHandling() {
        // Handle browser back/forward buttons
        window.addEventListener('popstate', (event) => {
            console.log('🔙 Browser back/forward detected:', event.state);
            console.log('🔙 Current state machine state:', this.stateMachine.getState());
            console.log('🔙 Is authenticated:', this.authService.isAuthenticated());
            
            if (event.state) {
                // Check if this is the initial app entry state
                if (event.state.isInitial) {
                    console.log('🔙 Reached initial app state - redirecting appropriately');
                    // Instead of going off-site, redirect to appropriate page
                    if (this.authService.isAuthenticated()) {
                        this.stateMachine.send('USER_AUTHENTICATED', this.currentUser);
                        this.replaceHistory('roleSwitchboard', { user: this.currentUser });
                    } else {
                        this.stateMachine.send('LOGIN_REQUIRED');
                        this.replaceHistory('login');
                    }
                    return;
                }
                
                this.handleHistoryNavigation(event.state);
            } else {
                console.log('🔙 No state in history - staying on current page');
                // Don't navigate away - just stay where we are
                return;
            }
        });
    }
    
    updateHistory(page, data = {}) {
        const state = { page, data, timestamp: Date.now() };
        console.log('📝 Updating history:', state);
        history.pushState(state, `Football Home - ${page}`, `#${page}`);
    }
    
    async handleHistoryNavigation(state) {
        console.log('🔙 Handling history navigation to:', state.page);
        console.log('🔙 Current machine state:', this.stateMachine.getState());
        console.log('🔙 Target state:', state.page);
        
        switch (state.page) {
            case 'login':
                console.log('🔙 Going to login page');
                this.stateMachine.send('LOGOUT');
                break;
                
            case 'roleSwitchboard':
                console.log('🔙 Going to role switchboard');
                if (this.authService.isAuthenticated()) {
                    if (!this.currentUser) {
                        const userResult = await this.authService.getCurrentUser();
                        if (userResult.success) {
                            this.currentUser = userResult.user;
                        }
                    }
                    
                    if (this.stateMachine.getState() === 'dashboard') {
                        console.log('🔙 From dashboard to roles');
                        this.stateMachine.send('BACK_TO_ROLES');
                    } else {
                        console.log('🔙 Direct to roles');
                        this.stateMachine.send('USER_AUTHENTICATED', this.currentUser);
                    }
                } else {
                    console.log('🔙 Not authenticated, going to login');
                    this.stateMachine.send('LOGIN_REQUIRED');
                }
                break;
                
            case 'dashboard':
                console.log('🔙 Going to dashboard');
                if (this.authService.isAuthenticated() && state.data.roleSelection) {
                    this.stateMachine.send('ROLE_SELECTED', state.data.roleSelection);
                } else {
                    console.log('🔙 Dashboard fallback to init');
                    this.init(); // Fallback to init
                }
                break;
                
            default:
                console.log('🔙 Unknown state, falling back to appropriate page');
                // Don't call init() which might cause loops - instead go to appropriate page
                if (this.authService.isAuthenticated()) {
                    this.stateMachine.send('USER_AUTHENTICATED', this.currentUser);
                    this.replaceHistory('roleSwitchboard', { user: this.currentUser });
                } else {
                    this.stateMachine.send('LOGIN_REQUIRED');
                    this.replaceHistory('login');
                }
        }
    }
    
    showLoading() {
        this.container.innerHTML = `
            <div class="min-h-screen flex items-center justify-center">
                <div class="text-center">
                    <div class="loading-spinner"></div>
                    <p class="mt-4">Loading Football Home...</p>
                </div>
            </div>
        `;
    }
    
    hideLoading() {
        // Loading cleanup handled by next screen's onEntry
    }
    
    cleanupCurrentComponent() {
        if (this.currentComponent) {
            if (this.currentComponent.cleanup) {
                this.currentComponent.cleanup();
            }
            this.currentComponent = null;
        }
    }
    
    async initializeApp() {
        console.log('🚀 App: Initializing application...');
        
        try {
            // Setup global error handlers
            this.setupErrorHandlers();
            
            // Setup navigation protection
            this.setupNavigationProtection();
            
            // Check if user is already authenticated
            let initialScreen = 'login';
            let initialData = null;
            
            if (this.authService.isAuthenticated()) {
                const userResult = await this.authService.getCurrentUser();
                
                if (userResult.success) {
                    console.log('🚀 App: User already authenticated:', userResult.user);
                    this.currentUser = userResult.user;
                    initialScreen = 'roleSwitchboard';
                    initialData = { user: userResult.user };
                }
            }
            
            // Initialize ScreenManager with available screens
            this.screenManager = new ScreenManager(this.container, {
                screens: {
                    login: LoginScreen,
                    roleSwitchboard: RoleSwitchboardScreen,
                    dashboard: DashboardScreen
                },
                initial: initialScreen
            });
            
            // Setup screen manager event listeners
            this.setupScreenManagerEvents();
            
            // Initialize the first screen with data
            if (initialData) {
                await this.screenManager.navigateTo(initialScreen, initialData);
            }
            
            console.log('🚀 App: Application initialized successfully');
            
        } catch (error) {
            console.error('🚀 App: Initialization failed:', error);
            this.appStateMachine.send('ERROR', error);
        }
    }
    
    startApplication() {
        console.log('🚀 App: Application is running');
        
        // Application is now fully running with ScreenManager handling all navigation
        // The ScreenManager will handle all screen transitions from here
    }
    
    setupScreenManagerEvents() {
        // Listen for global app events that might come from screens
        window.addEventListener('app:logout', () => {
            console.log('🚀 App: Global logout event received');
            this.logout();
        });
        
        window.addEventListener('app:error', (event) => {
            console.error('🚀 App: Global error event received:', event.detail);
            this.appStateMachine.send('ERROR', event.detail);
        });
        
        window.addEventListener('app:maintenance', () => {
            console.log('🚀 App: Maintenance mode requested');
            this.appStateMachine.send('MAINTENANCE');
        });
    }
    
    setupErrorHandlers() {
        // Global error handler
        window.addEventListener('error', (event) => {
            console.error('🚀 App: Global JavaScript error:', event.error);
            // Could send to error reporting service here
        });
        
        // Promise rejection handler
        window.addEventListener('unhandledrejection', (event) => {
            console.error('🚀 App: Unhandled promise rejection:', event.reason);
            // Could send to error reporting service here
        });
    }
    
    setupNavigationProtection() {
        // Prevent form submissions from navigating away
        document.addEventListener('submit', (e) => {
            if (e.target.method === 'get') {
                e.preventDefault();
                console.log('🛡️ App: Prevented form navigation');
            }
        });
        
        // Handle beforeunload for protection
        window.addEventListener('beforeunload', (e) => {
            if (this.authService.isAuthenticated()) {
                console.log('🛡️ App: User attempting to leave while authenticated');
                // Could add confirmation dialog here if needed
            }
        });
    }
    
    showMaintenance() {
        this.container.innerHTML = `
            <div class="min-h-screen flex items-center justify-center">
                <div class="text-center">
                    <h2>System Maintenance</h2>
                    <p class="mt-4">The system is currently under maintenance. Please try again later.</p>
                    <button id="resumeBtn" class="btn btn-primary mt-6">Try Again</button>
                </div>
            </div>
        `;
        
        const resumeBtn = document.getElementById('resumeBtn');
        if (resumeBtn) {
            resumeBtn.onclick = () => this.appStateMachine.send('RESUME');
        }
    }
    
    hideMaintenance() {
        // Cleanup handled by next state
    }
    
    showError(error) {
        this.container.innerHTML = `
            <div class="min-h-screen flex items-center justify-center">
                <div class="text-center">
                    <h2>Application Error</h2>
                    <p class="mt-4">${error.message || 'An unexpected error occurred'}</p>
                    <div class="mt-6">
                        <button id="retryBtn" class="btn btn-primary mr-4">Retry</button>
                        <button id="reloadBtn" class="btn btn-secondary">Reload Page</button>
                    </div>
                </div>
            </div>
        `;
        
        const retryBtn = document.getElementById('retryBtn');
        const reloadBtn = document.getElementById('reloadBtn');
        
        if (retryBtn) {
            retryBtn.onclick = () => this.appStateMachine.send('RETRY');
        }
        
        if (reloadBtn) {
            reloadBtn.onclick = () => window.location.reload();
        }
    }
    
    hideError() {
        // Cleanup handled by next state
    }
    
    logout() {
        console.log('🚀 App: Logging out user');
        
        this.authService.logout();
        this.currentUser = null;
        
        // Navigate to login screen
        if (this.screenManager) {
            this.screenManager.navigateTo('login');
        }
    }
    
    cleanup() {
        console.log('🚀 App: Cleaning up application');
        
        if (this.screenManager) {
            this.screenManager.cleanup();
            this.screenManager = null;
        }
        
        this.currentUser = null;
    }
    
    /**
     * Get debug information about the entire application
     */
    getDebugInfo() {
        return {
            appState: this.appStateMachine.getState(),
            isAuthenticated: this.authService.isAuthenticated(),
            currentUser: this.currentUser ? this.currentUser.email : null,
            screenManager: this.screenManager ? this.screenManager.getDebugInfo() : null,
            timestamp: new Date().toISOString()
        };
    }
        
        // Clear container
        this.container.innerHTML = '';
        
        // Add page wrapper with centering
        const pageWrapper = document.createElement('div');
        pageWrapper.className = 'min-h-screen flex items-center justify-center';
        this.container.appendChild(pageWrapper);
        
        // Create login component
        this.currentComponent = new LoginForm(pageWrapper);
        
        // Listen for successful login
        this.currentComponent.on('loginSuccess', (event) => {
            console.log('App received login success:', event.detail);
            
            const user = event.detail?.user;
            if (user) {
                this.currentUser = user;
                this.stateMachine.send('LOGIN_SUCCESS', user);
                this.updateHistory('roleSwitchboard', { user });
            } else {
                console.error('No user object in login success event');
            }
        });
    }
    
    showRoleSwitchboard(user) {
        console.log('App: showRoleSwitchboard called with user:', user);
        
        const appContainer = document.getElementById('app');
        appContainer.innerHTML = ''; // Clear container
        
        try {
            // Create the RoleSwitchboard component (auto-mounts via base class)
            console.log('App: Creating RoleSwitchboard component...');
            this.currentComponent = new RoleSwitchboard(appContainer, user);
            console.log('App: RoleSwitchboard created and mounted successfully');
            
            // Listen for role selection events
            if (this.currentComponent.element) {
                this.currentComponent.element.addEventListener('role:selected', (event) => {
                    console.log('App: Role selected:', event.detail);
                    this.handleRoleSelection(event.detail);
                });
                
                this.currentComponent.element.addEventListener('user:logout', () => {
                    console.log('App: Logout event received');
                    this.logout();
                });
                
                console.log('App: RoleSwitchboard event listeners added');
            }
            
        } catch (error) {
            console.error('App: Error setting up role switchboard:', error);
            
            // Fallback: show error message
            appContainer.innerHTML = `
                <div style="padding: 2rem; text-align: center;">
                    <h2>Role Switchboard Loading Error</h2>
                    <p>There was an error loading the role selection. Check the console for details.</p>
                    <p>Error: ${error.message}</p>
                    <button onclick="location.reload()">Reload Page</button>
                </div>
            `;
        }
    }
    
    handleRoleSelection(roleSelection) {
        console.log('App: Handling role selection:', roleSelection);
        
        if (roleSelection.navigateTo === 'teamSelection') {
            // Show team selection (multiple teams for one role)
            this.showTeamSelection(roleSelection);
        } else if (roleSelection.navigateTo === 'dashboard') {
            // Go directly to role dashboard (single team)
            this.stateMachine.send('ROLE_SELECTED', roleSelection);
            this.updateHistory('dashboard', { roleSelection });
        }
    }
    
    // TODO: Implement proper TeamSelection component
    showTeamSelection(roleSelection) {
        console.log('App: Team selection requested but not implemented yet:', roleSelection);
        console.log('App: Staying on RoleSwitchboard for now...');
        // For now, do nothing - stay on the RoleSwitchboard
    }
    
    showRoleDashboard(roleSelection) {
        console.log('App: Showing role dashboard for:', roleSelection);
        
        const appContainer = document.getElementById('app');
        appContainer.innerHTML = ''; // Clear container
        
        // Create a basic dashboard based on role type
        if (roleSelection.roleType === 'admin') {
            this.showAdminDashboard(roleSelection);
        } else {
            // Fallback for other roles
            appContainer.innerHTML = `
                <div class="dashboard">
                    <nav class="navbar">
                        <div class="navbar-brand">
                            <span class="brand-text">Football Home - ${roleSelection.roleType}</span>
                        </div>
                        <div class="navbar-menu">
                            <button id="backBtn" class="btn btn-secondary btn-sm">Back to Roles</button>
                            <button id="logoutBtn" class="btn btn-secondary btn-sm">Logout</button>
                        </div>
                    </nav>
                    <main class="dashboard-main">
                        <h2>${roleSelection.roleType.charAt(0).toUpperCase() + roleSelection.roleType.slice(1)} Dashboard</h2>
                        <p>Dashboard for ${roleSelection.roleData?.teamName || 'your team'}</p>
                        <p>This dashboard is under development.</p>
                    </main>
                </div>
            `;
            
            // Setup navigation
            this.setupDashboardNavigation();
        }
    }
    
    showAdminDashboard(roleSelection) {
        console.log('App: Showing admin dashboard');
        
        const appContainer = document.getElementById('app');
        appContainer.innerHTML = `
            <div class="admin-dashboard">
                <nav class="navbar">
                    <div class="navbar-brand">
                        <span class="brand-text">Football Home - Administrator</span>
                    </div>
                    <div class="navbar-menu">
                        <button id="backBtn" class="btn btn-secondary btn-sm">Back to Roles</button>
                        <button id="logoutBtn" class="btn btn-secondary btn-sm">Logout</button>
                    </div>
                </nav>
                <main class="admin-main">
                    <div class="admin-header">
                        <h2>System Administration</h2>
                        <p>Manage the Football Home system</p>
                    </div>
                    
                    <div class="admin-grid">
                        <div class="admin-card">
                            <div class="admin-card-icon">👥</div>
                            <h3>User Management</h3>
                            <p>Manage users, roles, and permissions</p>
                            <button class="btn btn-primary" disabled>Coming Soon</button>
                        </div>
                        
                        <div class="admin-card">
                            <div class="admin-card-icon">🏈</div>
                            <h3>Team Management</h3>
                            <p>Manage teams, players, and coaches</p>
                            <button class="btn btn-primary" disabled>Coming Soon</button>
                        </div>
                        
                        <div class="admin-card">
                            <div class="admin-card-icon">🏆</div>
                            <h3>League Management</h3>
                            <p>Manage leagues, divisions, and seasons</p>
                            <button class="btn btn-primary" disabled>Coming Soon</button>
                        </div>
                        
                        <div class="admin-card">
                            <div class="admin-card-icon">📊</div>
                            <h3>System Stats</h3>
                            <p>View system statistics and reports</p>
                            <button class="btn btn-primary" disabled>Coming Soon</button>
                        </div>
                    </div>
                </main>
            </div>
        `;
        
        // Setup navigation
        this.setupDashboardNavigation();
    }
    
    setupDashboardNavigation() {
        const backBtn = document.getElementById('backBtn');
        const logoutBtn = document.getElementById('logoutBtn');
        
        if (backBtn) {
            backBtn.addEventListener('click', () => {
                // Use state machine to go back to role switchboard
                this.stateMachine.send('BACK_TO_ROLES');
                this.updateHistory('roleSwitchboard', { user: this.currentUser });
            });
        }
        
        if (logoutBtn) {
            logoutBtn.addEventListener('click', () => {
                this.logout();
            });
        }
    }
    
    logout() {
        console.log('Logging out...');
        
        this.authService.logout();
        this.currentUser = null;
        this.stateMachine.send('LOGOUT');
        this.updateHistory('login');
    }
}

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new App();
});