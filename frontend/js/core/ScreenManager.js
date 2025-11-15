/**
 * ScreenManager - Manages screen transitions and global app navigation
 * 
 * The ScreenManager has its own state machine for tracking which screen is active
 * and handles transitions between screens with proper enter/exit lifecycle.
 * 
 * Usage:
 * const screenManager = new ScreenManager(document.getElementById('app'), {
 *   screens: {
 *     login: LoginScreen,
 *     dashboard: DashboardScreen,
 *     profile: ProfileScreen
 *   },
 *   initial: 'login'
 * });
 * 
 * screenManager.navigateTo('dashboard', { user: userData });
 */
class ScreenManager {
    constructor(container, config = {}) {
        this.container = container;
        this.screens = {}; // Instantiated screen objects
        this.screenClasses = config.screens || {};
        this.currentScreen = null;
        this.history = [];
        this.authService = config.authService; // Optional auth service for navigation protection
        
        // Create state machine for screen navigation
        const screenStates = {};
        const screenNames = Object.keys(this.screenClasses);
        
        // Build state machine transitions - each screen can go to any other screen
        screenNames.forEach(screenName => {
            const transitions = {};
            screenNames.forEach(targetScreen => {
                if (targetScreen !== screenName) {
                    transitions[`GO_TO_${targetScreen.toUpperCase()}`] = targetScreen;
                }
            });
            
            screenStates[screenName] = {
                on: transitions,
                onEntry: (data) => this.enterScreen(screenName, data),
                onExit: () => this.exitCurrentScreen()
            };
        });
        
        this.stateMachine = new StateMachine({
            initial: config.initial || screenNames[0],
            states: screenStates
        });
        
        // Listen for state changes
        this.stateMachine.onStateChange((prevState, newState, event, payload) => {
            this.updateHistory(newState, payload);
        });
        
        // Setup browser history handling
        this.setupHistoryHandling();
        
        // Verify all screen classes are defined
        for (const [screenName, ScreenClass] of Object.entries(this.screenClasses)) {
            if (typeof ScreenClass !== 'function') {
                console.error(`ScreenManager: ${screenName} class is not defined:`, ScreenClass);
            }
        }
        
        // Initialize the first screen
        this.initializeScreen(config.initial || screenNames[0]);
        
        // Set initial browser history state
        const initialScreen = config.initial || screenNames[0];
        const initialState = {
            screen: initialScreen,
            data: null,
            timestamp: Date.now()
        };
        history.replaceState(initialState, `Football Home - ${initialScreen}`, `#${initialScreen}`);
    }
    
    /**
     * Navigate to a specific screen
     */
    async navigateTo(screenName, data = null) {
        if (!this.screenClasses[screenName]) {
            console.error(`ScreenManager: Unknown screen "${screenName}"`);
            return false;
        }
        
        const event = `GO_TO_${screenName.toUpperCase()}`;
        return this.stateMachine.send(event, data);
    }
    
    /**
     * Go back to the previous screen
     */
    async goBack() {
        if (this.history.length > 1) {
            // Use browser's back functionality for proper history management
            history.back();
            return true;
        } else {
            // No history - prevent going outside app
            console.log('🔙 ScreenManager: No previous screen - staying on current screen');
            return false;
        }
    }
    
    /**
     * Initialize a screen for the first time
     */
    initializeScreen(screenName) {
        if (!this.screens[screenName]) {
            // Check if screen class exists
            const ScreenClass = this.screenClasses[screenName];
            if (!ScreenClass) {
                console.error(`ScreenManager: No class found for screen "${screenName}"`);
                return;
            }
            
            // Create container for this screen
            const screenContainer = document.createElement('div');
            screenContainer.className = `screen screen-${screenName}`;
            screenContainer.style.display = 'none';
            this.container.appendChild(screenContainer);
            
            // Instantiate the screen
            this.screens[screenName] = new ScreenClass(screenContainer, { screenManager: this });
            
            // Listen for navigation events from screens
            const eventHandler = (event) => {
                const { targetScreen, data } = event.detail.data;
                this.navigateTo(targetScreen, data);
            };
            
            screenContainer.addEventListener('screen:navigate', eventHandler);
        }
    }
    
    /**
     * Enter a screen (called by state machine onEntry)
     */
    async enterScreen(screenName, data = null) {
        // Initialize screen if not already done
        this.initializeScreen(screenName);
        
        // Set as current screen
        this.currentScreen = this.screens[screenName];
        
        // Call screen's onEnter method
        if (this.currentScreen && this.currentScreen.onEnter) {
            await this.currentScreen.onEnter(data);
        }
    }
    
    /**
     * Exit the current screen (called by state machine onExit)
     */
    async exitCurrentScreen() {
        if (this.currentScreen && this.currentScreen.onExit) {
            await this.currentScreen.onExit();
        }
    }
    
    /**
     * Update browser history
     */
    updateHistory(screenName, data = null) {
        const historyEntry = {
            screenName,
            data,
            timestamp: Date.now()
        };
        
        this.history.push(historyEntry);
        
        // Keep history reasonable size
        if (this.history.length > 50) {
            this.history = this.history.slice(-25); // Keep last 25 entries
        }
        
        // Update browser history
        const state = { 
            screen: screenName, 
            data,
            timestamp: Date.now()
        };
        history.pushState(state, `Football Home - ${screenName}`, `#${screenName}`);
    }
    
    /**
     * Handle browser back/forward buttons
     */
    setupHistoryHandling() {
        window.addEventListener('popstate', (event) => {
            console.log('🔙 ScreenManager: Browser back/forward detected:', event.state);
            console.log('🔙 ScreenManager: Current screen:', this.stateMachine.getState());
            
            if (event.state && event.state.screen && this.screenClasses[event.state.screen]) {
                console.log('🔙 ScreenManager: Navigating to valid screen:', event.state.screen);
                // Navigate to the screen from history
                this.navigateTo(event.state.screen, event.state.data);
            } else {
                console.log('🔙 ScreenManager: Invalid history state - staying on current screen');
                // Prevent going outside the app by replacing with current state
                const currentState = {
                    screen: this.stateMachine.getState(),
                    data: null,
                    timestamp: Date.now()
                };
                history.replaceState(currentState, `Football Home - ${currentState.screen}`, `#${currentState.screen}`);
            }
        });
        
        // Prevent navigation away from the app
        window.addEventListener('beforeunload', (event) => {
            // Only show warning if user is authenticated (to prevent losing session)
            if (this.authService && this.authService.isAuthenticated && this.authService.isAuthenticated()) {
                event.preventDefault();
                event.returnValue = 'Are you sure you want to leave? You will be logged out.';
                return event.returnValue;
            }
        });
    }
    
    /**
     * Get the current screen
     */
    getCurrentScreen() {
        return this.currentScreen;
    }
    
    /**
     * Get current screen name
     */
    getCurrentScreenName() {
        return this.stateMachine.getState();
    }
    
    /**
     * Get debug information
     */
    getDebugInfo() {
        return {
            currentScreen: this.getCurrentScreenName(),
            screenCount: Object.keys(this.screens).length,
            historyLength: this.history.length,
            availableScreens: Object.keys(this.screenClasses),
            screenStates: this.screens ? Object.keys(this.screens).reduce((acc, screenName) => {
                acc[screenName] = this.screens[screenName].getDebugInfo();
                return acc;
            }, {}) : {}
        };
    }
    
    /**
     * Cleanup all screens
     */
    cleanup() {
        console.log('🎬 ScreenManager: Cleaning up all screens');
        
        Object.values(this.screens).forEach(screen => {
            if (screen.cleanup) {
                screen.cleanup();
            }
        });
        
        this.screens = {};
        this.currentScreen = null;
        this.history = [];
    }
}