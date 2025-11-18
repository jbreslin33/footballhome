/**
 * BaseRoleStateMachine - Base class for role-specific state machines
 * 
 * Each role (coach, player, parent, admin) extends this to define:
 * - Role-specific navigation flows
 * - Role-specific context and permissions
 * - Role-specific screen access rules
 * 
 * This creates a hierarchical state machine architecture:
 * App → Role State Machine → Screen Manager → Individual Screens
 * 
 * Usage:
 * class CoachStateMachine extends BaseRoleStateMachine {
 *   constructor(user, teamContext) {
 *     super('coach', user, teamContext);
 *     this.defineStates();
 *   }
 * }
 */
class BaseRoleStateMachine extends StateMachine {
    constructor(roleType, user, teamContext) {
        // Initialize with base states that all roles share
        super({
            initial: 'initializing',
            states: {
                initializing: {
                    enter: () => {
                        console.log(`🎭 ${roleType}StateMachine: Initializing`);
                    },
                    on: {
                        READY: 'dashboard'
                    }
                },
                dashboard: {
                    enter: () => {
                        console.log(`🎭 ${roleType}StateMachine: Dashboard ready`);
                    },
                    on: {
                        NAVIGATE_TO_TEAM_SELECTION: 'selectingTeam',
                        NAVIGATE_TO_EVENTS: 'selectingEventType',
                        LOGOUT: 'loggingOut'
                    }
                },
                selectingTeam: {
                    enter: () => {
                        console.log(`🎭 ${roleType}StateMachine: Selecting team`);
                    },
                    on: {
                        TEAM_SELECTED: 'dashboard',
                        BACK: 'dashboard'
                    }
                },
                selectingEventType: {
                    enter: () => {
                        console.log(`🎭 ${roleType}StateMachine: Selecting event type`);
                    },
                    on: {
                        EVENT_TYPE_SELECTED: 'handleEventType',
                        BACK: 'dashboard'
                    }
                },
                handleEventType: {
                    // This will be overridden by subclasses to route to role-specific screens
                    enter: (eventType) => {
                        console.log(`🎭 ${roleType}StateMachine: Handling event type:`, eventType);
                    },
                    on: {
                        NAVIGATE: 'navigating',
                        BACK: 'selectingEventType'
                    }
                },
                navigating: {
                    enter: (navigationData) => {
                        console.log(`🎭 ${roleType}StateMachine: Navigating to:`, navigationData?.targetScreen);
                        if (navigationData?.callback) {
                            navigationData.callback(navigationData);
                        }
                    },
                    on: {
                        COMPLETE: 'dashboard',
                        BACK: 'dashboard'
                    }
                },
                loggingOut: {
                    enter: () => {
                        console.log(`🎭 ${roleType}StateMachine: Logging out`);
                    },
                    on: {
                        COMPLETE: 'initializing'
                    }
                }
            }
        });
        
        this.roleType = roleType;
        this.user = user;
        this.teamContext = teamContext;
        this.screenManager = null; // Will be set by App
        
        // Role-specific permissions and context
        this.permissions = this.definePermissions();
        this.context = this.buildContext();
    }
    
    /**
     * Define permissions for this role
     * Override in subclasses to customize
     */
    definePermissions() {
        return {
            canCreateEvents: false,
            canEditEvents: false,
            canDeleteEvents: false,
            canManageRoster: false,
            canViewRoster: true,
            canRSVP: true,
            canViewSchedule: true
        };
    }
    
    /**
     * Build context object that gets passed to screens
     */
    buildContext() {
        return {
            user: this.user,
            teamContext: this.teamContext,
            roleType: this.roleType,
            permissions: this.permissions
        };
    }
    
    /**
     * Check if this role can access a specific screen
     * Override in subclasses to customize
     */
    canAccessScreen(screenName) {
        // Base screens all roles can access
        const baseScreens = [
            'dashboard',
            'teamSelection',
            'eventTypeSelection'
        ];
        
        return baseScreens.includes(screenName);
    }
    
    /**
     * Get the default screen to show for a given event type
     * Override in subclasses to customize per role
     */
    getScreenForEventType(eventType) {
        // Default behavior - override in subclasses
        return null;
    }
    
    /**
     * Set the screen manager reference
     * Called by App during initialization
     */
    setScreenManager(screenManager) {
        this.screenManager = screenManager;
    }
    
    /**
     * Navigate to a screen through the screen manager
     */
    navigateToScreen(screenName, additionalData = {}) {
        if (!this.screenManager) {
            console.error(`🎭 ${this.roleType}StateMachine: No screen manager available`);
            return;
        }
        
        if (!this.canAccessScreen(screenName)) {
            console.warn(`🎭 ${this.roleType}StateMachine: Access denied to screen: ${screenName}`);
            return;
        }
        
        const navigationData = {
            ...this.context,
            ...additionalData
        };
        
        console.log(`🎭 ${this.roleType}StateMachine: Navigating to ${screenName} with context:`, navigationData);
        
        this.screenManager.navigateTo(screenName, navigationData);
    }
    
    /**
     * Handle event type selection - routes to appropriate screen based on role
     */
    handleEventTypeSelection(eventType) {
        const targetScreen = this.getScreenForEventType(eventType);
        
        if (!targetScreen) {
            console.error(`🎭 ${this.roleType}StateMachine: No screen defined for event type: ${eventType}`);
            return;
        }
        
        this.send('NAVIGATE', {
            targetScreen,
            eventType,
            callback: (navData) => {
                this.navigateToScreen(targetScreen, { eventType });
            }
        });
    }
    
    /**
     * Update team context (when switching teams)
     */
    updateTeamContext(teamContext) {
        this.teamContext = teamContext;
        this.context = this.buildContext();
        console.log(`🎭 ${this.roleType}StateMachine: Team context updated:`, teamContext.name);
    }
    
    /**
     * Get debug information
     */
    getDebugInfo() {
        return {
            roleType: this.roleType,
            currentState: this.getState(),
            permissions: this.permissions,
            user: this.user?.email,
            team: this.teamContext?.name,
            hasScreenManager: !!this.screenManager
        };
    }
}
