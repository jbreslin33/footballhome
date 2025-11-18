/**
 * CoachStateMachine - State machine for coach role
 * 
 * Handles coach-specific navigation flows and permissions:
 * - Can create, edit, delete events
 * - Can manage roster
 * - Can RSVP to events as coach
 * - Has access to practice management tools
 * 
 * Navigation Flow:
 * Dashboard → Events → Practice Options → [Manage | RSVP]
 */
class CoachStateMachine extends BaseRoleStateMachine {
    constructor(user, teamContext) {
        super('coach', user, teamContext);
        
        // Add coach-specific states to the base states
        this.addCoachStates();
        
        // Signal that we're ready
        this.send('READY');
    }
    
    /**
     * Add coach-specific states to the state machine
     */
    addCoachStates() {
        // Add coach-specific states for managing events
        this.states.practiceOptions = {
            enter: () => {
                console.log('🏈 CoachStateMachine: Showing practice options');
            },
            on: {
                MANAGE_SELECTED: 'managingPractices',
                RSVP_SELECTED: 'rsvpingToPractices',
                BACK: 'selectingEventType'
            }
        };
        
        this.states.managingPractices = {
            enter: () => {
                console.log('🏈 CoachStateMachine: Managing practices');
            },
            on: {
                CREATE: 'creatingPractice',
                EDIT: 'editingPractice',
                DELETE: 'deletingPractice',
                BACK: 'practiceOptions'
            }
        };
        
        this.states.creatingPractice = {
            enter: () => {
                console.log('🏈 CoachStateMachine: Creating practice');
            },
            on: {
                SAVE: 'savingPractice',
                CANCEL: 'managingPractices'
            }
        };
        
        this.states.editingPractice = {
            enter: (practiceId) => {
                console.log('🏈 CoachStateMachine: Editing practice:', practiceId);
            },
            on: {
                SAVE: 'savingPractice',
                CANCEL: 'managingPractices'
            }
        };
        
        this.states.savingPractice = {
            enter: () => {
                console.log('🏈 CoachStateMachine: Saving practice...');
            },
            on: {
                SUCCESS: 'managingPractices',
                ERROR: 'creatingPractice'
            }
        };
        
        this.states.deletingPractice = {
            enter: (practiceId) => {
                console.log('🏈 CoachStateMachine: Deleting practice:', practiceId);
            },
            on: {
                CONFIRM: 'confirmingDelete',
                CANCEL: 'managingPractices'
            }
        };
        
        this.states.confirmingDelete = {
            enter: () => {
                console.log('🏈 CoachStateMachine: Confirming delete...');
            },
            on: {
                SUCCESS: 'managingPractices',
                ERROR: 'managingPractices'
            }
        };
        
        this.states.rsvpingToPractices = {
            enter: () => {
                console.log('🏈 CoachStateMachine: RSVPing to practices (as coach)');
            },
            on: {
                SUBMIT_RSVP: 'submittingRSVP',
                BACK: 'practiceOptions'
            }
        };
        
        this.states.submittingRSVP = {
            enter: () => {
                console.log('🏈 CoachStateMachine: Submitting RSVP...');
            },
            on: {
                SUCCESS: 'rsvpingToPractices',
                ERROR: 'rsvpingToPractices'
            }
        };
        
        // Update handleEventType state for coach-specific routing
        this.states.handleEventType = {
            enter: (eventType) => {
                console.log('🏈 CoachStateMachine: Handling event type:', eventType);
                // Coach goes to options screen for practices
                if (eventType === 'practice') {
                    this.send('NAVIGATE', {
                        targetScreen: 'practiceOptions',
                        eventType,
                        callback: (navData) => {
                            this.navigateToScreen('practiceOptions', { eventType });
                        }
                    });
                }
            },
            on: {
                NAVIGATE: 'navigating',
                BACK: 'selectingEventType'
            }
        };
    }
    
    /**
     * Define coach permissions
     */
    definePermissions() {
        return {
            canCreateEvents: true,
            canEditEvents: true,
            canDeleteEvents: true,
            canManageRoster: true,
            canViewRoster: true,
            canRSVP: true,
            canViewSchedule: true,
            canManagePractices: true,
            canSeePracticeOptions: true
        };
    }
    
    /**
     * Check if coach can access a specific screen
     */
    canAccessScreen(screenName) {
        const coachScreens = [
            'managePractices',
            'practiceOptions',
            'practiceRSVP',
            'roster',
            'manageRoster',
            'createEvent',
            'editEvent'
        ];
        
        return super.canAccessScreen(screenName) || coachScreens.includes(screenName);
    }
    
    /**
     * Get the appropriate screen for an event type (coach version)
     */
    getScreenForEventType(eventType) {
        const screenMap = {
            'practice': 'practiceOptions',  // Coach sees options: Manage or RSVP
            'match': 'manageMatches',        // Future: manage matches
            'meeting': 'manageMeetings'      // Future: manage meetings
        };
        
        return screenMap[eventType] || null;
    }
    
    /**
     * Navigate to practice management screen
     */
    goToManagePractices() {
        this.send('MANAGE_SELECTED');
        this.navigateToScreen('managePractices');
    }
    
    /**
     * Navigate to coach RSVP screen
     */
    goToCoachRSVP() {
        this.send('RSVP_SELECTED');
        this.navigateToScreen('practiceRSVP');
    }
    
    /**
     * Handle practice creation
     */
    createPractice() {
        this.send('CREATE');
    }
    
    /**
     * Handle practice edit
     */
    editPractice(practiceId) {
        this.send('EDIT', practiceId);
    }
    
    /**
     * Handle practice deletion
     */
    deletePractice(practiceId) {
        this.send('DELETE', practiceId);
    }
    
    /**
     * Handle RSVP submission
     */
    submitRSVP(practiceId, status) {
        this.send('SUBMIT_RSVP', { practiceId, status });
    }
}
