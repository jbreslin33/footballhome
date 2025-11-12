/**
 * Finite State Machine for managing application state
 * 
 * Usage:
 * const fsm = new StateMachine({
 *   initial: 'idle',
 *   states: {
 *     idle: { on: { SUBMIT: 'loading' } },
 *     loading: { on: { SUCCESS: 'success', ERROR: 'error' } },
 *     success: { on: { RESET: 'idle' } },
 *     error: { on: { RETRY: 'loading', RESET: 'idle' } }
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
        
        console.log(`FSM initialized with state: ${this.currentState}`);
    }
    
    /**
     * Get current state
     */
    getState() {
        return this.currentState;
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
        
        console.log(`FSM: ${previousState} --[${event}]--> ${nextState}`);
        
        // Execute exit action for previous state
        const prevStateConfig = this.states[previousState];
        if (prevStateConfig && prevStateConfig.onExit) {
            prevStateConfig.onExit(payload);
        }
        
        // Execute entry action for new state
        const newStateConfig = this.states[nextState];
        if (newStateConfig && newStateConfig.onEntry) {
            newStateConfig.onEntry(payload);
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
                callback({ from, to, event, payload, machine: this });
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
