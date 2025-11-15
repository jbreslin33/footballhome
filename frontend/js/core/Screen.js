/**
 * Base Screen class for managing full-screen application states
 * 
 * Each screen has its own lifecycle with enter/exit methods and can have
 * its own state machine for internal state management.
 * 
 * Usage:
 * class LoginScreen extends Screen {
 *   constructor(container, props) {
 *     super(container, props, {
 *       screenName: 'login',
 *       states: {
 *         idle: { on: { SUBMIT: 'validating' } },
 *         validating: { on: { SUCCESS: 'success', ERROR: 'error' } },
 *         success: { on: { RESET: 'idle' } },
 *         error: { on: { RETRY: 'validating', RESET: 'idle' } }
 *       }
 *     });
 *   }
 *   
 *   render() {
 *     return '<div class="login-screen">...</div>';
 *   }
 *   
 *   onEnter(data) {
 *     console.log('Entering login screen with:', data);
 *   }
 *   
 *   onExit() {
 *     console.log('Exiting login screen');
 *   }
 * }
 */
class Screen extends Component {
    constructor(container, props = {}, screenConfig = {}) {
        super(container, props);
        
        this.screenName = screenConfig.screenName || 'unnamed-screen';
        this.isActive = false;
        this.entryData = null;
        
        // Create internal state machine if states are provided
        if (screenConfig.states) {
            this.stateMachine = new StateMachine({
                initial: screenConfig.initial || Object.keys(screenConfig.states)[0],
                states: screenConfig.states
            });
            
            // Listen for state changes
            this.stateMachine.onStateChange((prevState, newState, event, payload) => {
                this.onStateChange(prevState, newState, event, payload);
            });
        }
    }
    
    /**
     * Enter the screen - called when screen becomes active
     * Override this method to handle screen entry
     */
    async onEnter(data = null) {
        this.isActive = true;
        this.entryData = data;
        
        // Show the screen
        if (this.container) {
            this.container.style.display = 'block';
        }
        
        // Reset internal state machine to initial state if it exists
        if (this.stateMachine) {
            // Don't reset if already in initial state to avoid unnecessary transitions
            const initialState = Object.keys(this.stateMachine.states)[0];
            if (this.stateMachine.getState() !== initialState) {
                console.log(`📱 Screen[${this.screenName}] resetting to initial state`);
                this.stateMachine.currentState = initialState;
            }
        }
    }
    
    /**
     * Exit the screen - called when screen becomes inactive
     * Override this method to handle screen exit
     */
    async onExit() {
        this.isActive = false;
        this.entryData = null;
        
        // Hide the screen
        if (this.container) {
            this.container.style.display = 'none';
        }
        
        // Clean up any active processes
        this.cleanup();
    }
    
    /**
     * Called when the screen's internal state machine changes state
     * Override this method to handle internal state changes
     */
    onStateChange(prevState, newState, event, payload) {
        // Override in subclasses for custom state change handling
    }
    
    /**
     * Send an event to the screen's internal state machine
     */
    send(event, payload = null) {
        if (this.stateMachine) {
            return this.stateMachine.send(event, payload);
        } else {
            console.warn(`📱 Screen[${this.screenName}] has no state machine - cannot send event:`, event);
            return false;
        }
    }
    
    /**
     * Get the current internal state
     */
    getState() {
        return this.stateMachine ? this.stateMachine.getState() : null;
    }
    
    /**
     * Check if the screen can handle a given event
     */
    can(event) {
        return this.stateMachine ? this.stateMachine.can(event) : false;
    }
    
    /**
     * Emit an event to parent (usually the ScreenManager)
     */
    emitToParent(eventName, data = null) {
        const customEvent = new CustomEvent(eventName, { 
            detail: { 
                screen: this.screenName, 
                data,
                timestamp: Date.now()
            } 
        });
        
        // Always dispatch on the container (where ScreenManager listens) not the inner element
        const targetElement = this.container || this.element;
        
        if (targetElement) {
            // Use setTimeout to ensure event is dispatched after current execution cycle
            // This allows event listeners to be fully set up
            setTimeout(() => {
                targetElement.dispatchEvent(customEvent);
            }, 10);
        } else {
            console.warn(`Screen[${this.screenName}] cannot emit event - no container or element found`);
        }
    }
    
    /**
     * Navigate to another screen
     */
    navigateTo(screenName, data = null) {
        this.emitToParent('screen:navigate', { 
            targetScreen: screenName, 
            data 
        });
    }
    
    /**
     * Enhanced cleanup that also handles screen-specific cleanup
     */
    cleanup() {
        // Call parent cleanup
        super.cleanup();
        
        // Screen-specific cleanup
        this.isActive = false;
        this.entryData = null;
    }
    
    /**
     * Get debug information about the screen
     */
    getDebugInfo() {
        return {
            screenName: this.screenName,
            isActive: this.isActive,
            hasStateMachine: !!this.stateMachine,
            currentState: this.getState(),
            entryData: this.entryData,
            hasMountedElement: !!this.element
        };
    }
}