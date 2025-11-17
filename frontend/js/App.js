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
                    onEntry: () => {
                        console.log('🚀 App: State machine onEntry called');
                        // Call async initialization without awaiting in the state machine
                        this.performAsyncInitialization();
                    },
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
            // App state changes logged in development only
        });
        
        // The state machine will start automatically and call performAsyncInitialization()
        // Don't send READY here - let the initializing state handle it after async init completes
    }
    
    async performAsyncInitialization() {
        try {
            await this.initializeApp();
            this.appStateMachine.send('READY');
        } catch (error) {
            console.error('App: Initialization failed:', error);
            this.appStateMachine.send('ERROR', error);
        }
    }
    
    async initializeApp() {
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
                    teamSelection: TeamSelectionScreen,
                    eventTypeSelection: EventTypeSelectionScreen,
                    addPractice: AddPracticeScreen,
                    dashboard: DashboardScreen
                },
                initial: initialScreen,
                authService: this.authService
            });
            
            // Setup screen manager event listeners
            this.setupScreenManagerEvents();
            
            // Initialize the first screen with data
            if (initialData) {
                await this.screenManager.navigateTo(initialScreen, initialData);
            }
            
        } catch (error) {
            console.error('App: Initialization failed:', error);
            throw error; // Re-throw to be caught by state machine
        }
    }
    
    startApplication() {
        // Application is now fully running with ScreenManager handling all navigation
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
}

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.footballApp = new App();
    
    // Expose debug functions globally for development
    window.debugApp = () => {
        console.log('🔍 App Debug Info:', window.footballApp.getDebugInfo());
    };
    
    window.debugScreenManager = () => {
        if (window.footballApp && window.footballApp.screenManager) {
            console.log('🔍 ScreenManager Debug Info:', window.footballApp.screenManager.getDebugInfo());
        } else {
            console.log('🔍 ScreenManager not available');
        }
    };
    
    window.debugCurrentScreen = () => {
        if (window.footballApp && window.footballApp.screenManager) {
            const currentScreen = window.footballApp.screenManager.getCurrentScreen();
            if (currentScreen) {
                console.log('🔍 Current Screen Debug Info:', currentScreen.getDebugInfo());
            } else {
                console.log('🔍 No current screen');
            }
        } else {
            console.log('🔍 ScreenManager not available');
        }
    };
});