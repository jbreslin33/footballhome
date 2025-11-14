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
            console.log(`🎬 ScreenManager: ${prevState} --[${event}]--> ${newState}`);
            this.updateHistory(newState, payload);
        });
        
        // Setup browser history handling
        this.setupHistoryHandling();
        
        console.log('🎬 ScreenManager initialized with screens:', screenNames);
        console.log('🎬 ScreenManager initial screen:', config.initial || screenNames[0]);
        console.log('🎬 ScreenManager screen classes:', Object.keys(this.screenClasses));
        
        // Verify all screen classes are defined
        for (const [screenName, ScreenClass] of Object.entries(this.screenClasses)) {
            if (typeof ScreenClass !== 'function') {
                console.error(`❌ ScreenManager: ${screenName} class is not defined:`, ScreenClass);
            } else {
                console.log(`✅ ScreenManager: ${screenName} class is properly defined`);
            }
        }
        
        // Initialize the first screen
        this.initializeScreen(config.initial || screenNames[0]);
    }
    
    /**
     * Navigate to a specific screen
     */
    async navigateTo(screenName, data = null) {
        console.log(`🎬 ScreenManager: navigateTo called for "${screenName}" with data:`, data);
        
        if (!this.screenClasses[screenName]) {
            console.error(`🎬 ScreenManager: Unknown screen "${screenName}"`);
            return false;
        }
        
        const event = `GO_TO_${screenName.toUpperCase()}`;
        console.log(`🎬 ScreenManager: Sending ${event} event to state machine`);
        return this.stateMachine.send(event, data);
    }
    
    /**
     * Go back to the previous screen
     */
    async goBack() {
        if (this.history.length > 1) {
            const previousEntry = this.history[this.history.length - 2];
            await this.navigateTo(previousEntry.screenName, previousEntry.data);
            return true;
        }
        return false;
    }
    
    /**
     * Initialize a screen for the first time
     */
    initializeScreen(screenName) {
        if (!this.screens[screenName]) {
            console.log(`🎬 ScreenManager: Initializing screen "${screenName}"`);
            
            // Check if screen class exists
            const ScreenClass = this.screenClasses[screenName];
            if (!ScreenClass) {
                console.error(`❌ ScreenManager: No class found for screen "${screenName}"`);
                return;
            }
            
            console.log(`🎬 ScreenManager: Creating container for "${screenName}"`);
            
            // Create container for this screen
            const screenContainer = document.createElement('div');
            screenContainer.className = `screen screen-${screenName}`;
            screenContainer.style.display = 'none';
            this.container.appendChild(screenContainer);
            
            console.log(`🎬 ScreenManager: Instantiating ${screenName} class`);
            
            // Instantiate the screen
            this.screens[screenName] = new ScreenClass(screenContainer, { screenManager: this });
            
            // Listen for navigation events from screens
            console.log(`🎬 ScreenManager: Setting up screen:navigate listener for "${screenName}" on container:`, screenContainer);
            console.log(`🎬 ScreenManager: Container ID:`, screenContainer.id, 'Class:', screenContainer.className);
            
            const eventHandler = (event) => {
                console.log(`🎬 ScreenManager: Received screen:navigate event from "${screenName}":`, event.detail);
                console.log(`🎬 ScreenManager: Event target:`, event.target);
                console.log(`🎬 ScreenManager: Event currentTarget:`, event.currentTarget);
                const { targetScreen, data } = event.detail.data;
                console.log(`🎬 ScreenManager: Navigating to "${targetScreen}" with data:`, data);
                this.navigateTo(targetScreen, data);
            };
            
            screenContainer.addEventListener('screen:navigate', eventHandler);
            console.log(`🎬 ScreenManager: Event listener added for "${screenName}"`);
        }
    }
    
    /**
     * Enter a screen (called by state machine onEntry)
     */
    async enterScreen(screenName, data = null) {
        console.log(`🎬 ScreenManager: Entering screen "${screenName}"`);
        
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
            console.log(`🎬 ScreenManager: Exiting screen "${this.currentScreen.screenName}"`);
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
            console.log('🔙 ScreenManager: Browser navigation detected:', event.state);
            
            if (event.state && event.state.screen) {
                // Navigate to the screen from history
                this.navigateTo(event.state.screen, event.state.data);
            } else {
                // No valid state - stay on current screen
                console.log('🔙 ScreenManager: No valid history state - staying on current screen');
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