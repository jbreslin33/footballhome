/**
 * PlayerStateMachine - State machine for player role
 * 
 * Handles player-specific navigation flows and permissions:
 * - Cannot create, edit, or delete events
 * - Can view schedule
 * - Can RSVP to events as player
 * - Direct navigation to RSVP screen (no options screen needed)
 * 
 * Navigation Flow:
 * Dashboard → Events → Practice RSVP (direct)
 */
class PlayerStateMachine extends BaseRoleStateMachine {
    constructor(user, teamContext) {
        super('player', user, teamContext);
        
        // Add player-specific states to the base states
        this.addPlayerStates();
        
        // Signal that we're ready
        this.send('READY');
    }
    
    /**
     * Add player-specific states to the state machine
     */
    addPlayerStates() {
        // Add player-specific states for viewing and RSVPing to events
        this.states.viewingPractices = {
            enter: () => {
                console.log('⚽ PlayerStateMachine: Viewing practices for RSVP');
            },
            on: {
                SUBMIT_RSVP: 'submittingRSVP',
                VIEW_DETAILS: 'viewingPracticeDetails',
                BACK: 'selectingEventType'
            }
        };
        
        this.states.viewingPracticeDetails = {
            enter: (practiceId) => {
                console.log('⚽ PlayerStateMachine: Viewing practice details:', practiceId);
            },
            on: {
                SUBMIT_RSVP: 'submittingRSVP',
                BACK: 'viewingPractices'
            }
        };
        
        this.states.submittingRSVP = {
            enter: (rsvpData) => {
                console.log('⚽ PlayerStateMachine: Submitting player RSVP:', rsvpData);
            },
            on: {
                SUCCESS: 'viewingPractices',
                ERROR: 'viewingPractices'
            }
        };
        
        this.states.viewingSchedule = {
            enter: () => {
                console.log('⚽ PlayerStateMachine: Viewing my schedule');
            },
            on: {
                VIEW_EVENT: 'viewingEventDetails',
                BACK: 'dashboard'
            }
        };
        
        this.states.viewingEventDetails = {
            enter: (eventId) => {
                console.log('⚽ PlayerStateMachine: Viewing event details:', eventId);
            },
            on: {
                SUBMIT_RSVP: 'submittingRSVP',
                BACK: 'viewingSchedule'
            }
        };
        
        // Update handleEventType state for player-specific routing
        this.states.handleEventType = {
            enter: (eventType) => {
                console.log('⚽ PlayerStateMachine: Handling event type:', eventType);
                // Player goes directly to RSVP screen for practices
                if (eventType === 'practice') {
                    this.send('NAVIGATE', {
                        targetScreen: 'practiceRSVP',
                        eventType,
                        callback: (navData) => {
                            this.navigateToScreen('practiceRSVP', { eventType });
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
     * Define player permissions
     */
    definePermissions() {
        return {
            canCreateEvents: false,
            canEditEvents: false,
            canDeleteEvents: false,
            canManageRoster: false,
            canViewRoster: true,
            canRSVP: true,
            canViewSchedule: true,
            canManagePractices: false,
            canSeePracticeOptions: false
        };
    }
    
    /**
     * Check if player can access a specific screen
     */
    canAccessScreen(screenName) {
        const playerScreens = [
            'practiceRSVP',
            'mySchedule',
            'eventDetails',
            'roster'  // Can view but not edit
        ];
        
        return super.canAccessScreen(screenName) || playerScreens.includes(screenName);
    }
    
    /**
     * Get the appropriate screen for an event type (player version)
     */
    getScreenForEventType(eventType) {
        const screenMap = {
            'practice': 'practiceRSVP',   // Player goes directly to RSVP
            'match': 'matchRSVP',          // Future: RSVP to matches
            'meeting': 'meetingRSVP'       // Future: RSVP to meetings
        };
        
        return screenMap[eventType] || null;
    }
    
    /**
     * Navigate to practice RSVP screen
     */
    goToPracticeRSVP() {
        this.send('EVENT_TYPE_SELECTED', 'practice');
    }
    
    /**
     * Navigate to my schedule
     */
    goToMySchedule() {
        this.navigateToScreen('mySchedule');
    }
    
    /**
     * Handle RSVP submission
     */
    submitRSVP(practiceId, status, notes = '') {
        this.send('SUBMIT_RSVP', { 
            practiceId, 
            status, 
            notes,
            roleType: 'player'  // Explicitly set role type for player RSVP
        });
    }
    
    /**
     * View practice details
     */
    viewPracticeDetails(practiceId) {
        this.send('VIEW_DETAILS', practiceId);
    }
    
    /**
     * View event details
     */
    viewEventDetails(eventId) {
        this.send('VIEW_EVENT', eventId);
    }
}
