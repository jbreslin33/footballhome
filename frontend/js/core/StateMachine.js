/**
 * Finite State Machine for managing application state
 * 
 * Enhanced with enter/execute/exit pattern for each state.
 * Each state can have:
 * - enter(payload): Called when entering the state
 * - execute(payload): Called to perform the state's main action  
 * - exit(payload): Called when leaving the state
 * - on: Transitions to other states
 * 
 * Usage:
 * const fsm = new StateMachine({
 *   initial: 'idle',
 *   states: {
 *     idle: { 
 *       enter: () => console.log('Entering idle'),
 *       execute: () => console.log('Executing idle actions'),
 *       exit: () => console.log('Exiting idle'),
 *       on: { SUBMIT: 'loading' } 
 *     },
 *     loading: { 
 *       enter: () => showSpinner(),
 *       execute: (data) => performAsyncOperation(data),
 *       exit: () => hideSpinner(),
 *       on: { SUCCESS: 'success', ERROR: 'error' } 
 *     }
 *   }
 * });
 */
class StateMachine {
    constructor(config) {
        this.states = config.states;
        this.currentState = config.initial;
        this.listeners = [];
        
        // Validate initial state exists
        if (!this.states[this.currentState]) {
            throw new Error(`Initial state "${this.currentState}" not defined in states`);
        }
        
        // Execute enter action for initial state (new pattern)
        const initialStateConfig = this.states[this.currentState];
        if (initialStateConfig) {
            if (initialStateConfig.enter) {
                initialStateConfig.enter();
            }
            // Also support legacy onEntry for backward compatibility
            if (initialStateConfig.onEntry) {
                initialStateConfig.onEntry();
            }
        }
    }
    
    /**
     * Get current state
     */
    getState() {
        return this.currentState;
    }
    
    /**
     * Execute the current state's main action
     */
    execute(payload = null) {
        const currentStateConfig = this.states[this.currentState];
        if (currentStateConfig && currentStateConfig.execute) {
            return currentStateConfig.execute(payload);
        }
        return null;
    }
    
    /**
     * Send an event to the state machine
     */
    send(event, payload = null) {
        const currentStateConfig = this.states[this.currentState];
        
        if (!currentStateConfig) {
            console.error(`State "${this.currentState}" not found`);
            return false;
        }
        
        const transitions = currentStateConfig.on || {};
        const nextState = transitions[event];
        
        if (!nextState) {
            console.warn(`No transition for event "${event}" in state "${this.currentState}"`);
            return false;
        }
        
        const previousState = this.currentState;
        this.currentState = nextState;
        
        // Execute exit action for previous state (new pattern)
        const prevStateConfig = this.states[previousState];
        if (prevStateConfig) {
            if (prevStateConfig.exit) {
                prevStateConfig.exit(payload);
            }
            // Also support legacy onExit for backward compatibility
            if (prevStateConfig.onExit) {
                prevStateConfig.onExit(payload);
            }
        }
        
        // Execute enter action for new state (new pattern)
        const newStateConfig = this.states[nextState];
        if (newStateConfig) {
            if (newStateConfig.enter) {
                newStateConfig.enter(payload);
            }
            // Also support legacy onEntry for backward compatibility
            if (newStateConfig.onEntry) {
                newStateConfig.onEntry(payload);
            }
        }
        
        // Notify all listeners
        this.notifyListeners(previousState, nextState, event, payload);
        
        return true;
    }
    
    /**
     * Check if we can transition from current state with given event
     */
    can(event) {
        const currentStateConfig = this.states[this.currentState];
        if (!currentStateConfig || !currentStateConfig.on) {
            return false;
        }
        return currentStateConfig.on[event] !== undefined;
    }
    
    /**
     * Add a listener for state changes
     */
    onStateChange(callback) {
        this.listeners.push(callback);
        
        // Return unsubscribe function
        return () => {
            this.listeners = this.listeners.filter(listener => listener !== callback);
        };
    }
    
    /**
     * Notify all listeners of state change
     */
    notifyListeners(from, to, event, payload) {
        this.listeners.forEach(callback => {
            try {
                // Call with individual parameters to match expected signature
                callback(from, to, event, payload);
            } catch (error) {
                console.error('Error in state change listener:', error);
            }
        });
    }
    
    /**
     * Reset to initial state
     */
    reset() {
        const initialState = Object.keys(this.states)[0]; // Simple reset to first state
        if (this.currentState !== initialState) {
            this.send('RESET');
        }
    }
    
    /**
     * Get available events from current state
     */
    getAvailableEvents() {
        const currentStateConfig = this.states[this.currentState];
        if (!currentStateConfig || !currentStateConfig.on) {
            return [];
        }
        return Object.keys(currentStateConfig.on);
    }
}
