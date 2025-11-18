/**
 * EventTypeSelectionScreen - Select type of event to create
 * 
 * Presents 3 options:
 * - Add Practice
 * - Add Game
 * - Add Meeting
 * 
 * State machine flow:
 * ready -> selecting -> navigating
 */
class EventTypeSelectionScreen extends Screen {
    constructor(container, props = {}) {
        super(container, props, {
            screenName: 'eventTypeSelection'
        });
        
        this.user = null;
        this.teamContext = null;
        this.roleType = null;
        
        // Create state machine
        this.stateMachine = new StateMachine({
            initial: 'ready',
            states: {
                ready: {
                    on: { 
                        EVENT_TYPE_SELECTED: 'selecting',
                        BACK: 'navigating'
                    },
                    onEntry: () => this.showEventTypes()
                },
                selecting: {
                    on: { 
                        NAVIGATE: 'navigating',
                        CANCEL: 'ready'
                    },
                    onEntry: (eventType) => this.handleEventTypeSelection(eventType)
                },
                navigating: {
                    onEntry: (navData) => this.navigate(navData)
                }
            }
        });
    }
    
    render() {
        return `
            <div class="event-type-selection-screen">
                <!-- Navigation Bar -->
                <nav class="navbar">
                    <div class="navbar-brand">
                        <span class="brand-text">Football Home - Events</span>
                    </div>
                    <div class="navbar-menu">
                        ${this.teamContext ? `<span class="navbar-context">${this.teamContext.name}</span>` : ''}
                        <button id="backBtn" class="btn btn-secondary btn-sm">Back</button>
                    </div>
                </nav>
                
                <!-- Main Content -->
                <main class="event-type-main">
                    <div class="event-type-header">
                        <h2>Events</h2>
                        <p>Choose the type of event</p>
                    </div>
                    
                    <div class="event-type-grid">
                        <!-- Practice Card -->
                        <div class="event-type-card" data-event-type="practice">
                            <div class="event-card-icon">📋</div>
                            <h3>Practices</h3>
                            <p>${this.roleType === 'player' ? 'View and RSVP to team practices' : 'View, add, edit, or delete team practices'}</p>
                            <ul class="event-features">
                                ${this.roleType === 'player' 
                                    ? '<li>View upcoming practices</li><li>RSVP to practices</li><li>See practice details</li><li>Track your attendance</li>'
                                    : '<li>View upcoming practices</li><li>Schedule new practices</li><li>Edit existing practices</li><li>Manage practice details</li>'
                                }
                            </ul>
                            <button class="btn btn-primary btn-lg">${this.roleType === 'player' ? 'View Practices' : 'Manage Practices'}</button>
                        </div>
                        
                        <!-- Game Card -->
                        <div class="event-type-card" data-event-type="game">
                            <div class="event-card-icon">⚽</div>
                            <h3>Games</h3>
                            <p>${this.roleType === 'player' ? 'View game schedule and RSVP' : 'View, add, edit, or delete games'}</p>
                            <ul class="event-features">
                                ${this.roleType === 'player'
                                    ? '<li>View game schedule</li><li>RSVP to games</li><li>See opponent info</li><li>Track game results</li>'
                                    : '<li>View game schedule</li><li>Schedule new games</li><li>Edit game details</li><li>Manage opponents</li>'
                                }
                            </ul>
                            <button class="btn btn-primary btn-lg" disabled>Coming Soon</button>
                        </div>
                        
                        <!-- Meeting Card -->
                        <div class="event-type-card" data-event-type="meeting">
                            <div class="event-card-icon">💬</div>
                            <h3>Meetings</h3>
                            <p>${this.roleType === 'player' ? 'View and RSVP to team meetings' : 'View, add, edit, or delete team meetings'}</p>
                            <ul class="event-features">
                                ${this.roleType === 'player'
                                    ? '<li>View meeting schedule</li><li>RSVP to meetings</li><li>See meeting agenda</li><li>Track attendance</li>'
                                    : '<li>View meeting schedule</li><li>Schedule new meetings</li><li>Edit meeting details</li><li>Manage attendees</li>'
                                }
                            </ul>
                            <button class="btn btn-primary btn-lg" disabled>Coming Soon</button>
                        </div>
                    </div>
                </main>
            </div>
        `;
    }
    
    async onEnter(data = null) {
        await super.onEnter(data);
        
        this.user = data?.user || this.user;
        this.teamContext = data?.teamContext || this.teamContext;
        this.roleType = data?.roleType || 'coach';
        
        console.log('📱 EventTypeSelectionScreen: onEnter - roleType set to:', this.roleType);
        console.log('📱 EventTypeSelectionScreen: onEnter - full data:', data);
        
        if (!this.user) {
            console.error('📱 EventTypeSelectionScreen: No user data provided');
            return;
        }
        
        if (!this.teamContext) {
            console.error('📱 EventTypeSelectionScreen: No team context provided');
            return;
        }
        
        console.log('📱 EventTypeSelectionScreen: Initialized with team:', this.teamContext);
        this.send('READY');
    }
    
    showEventTypes() {
        this.setupEvents();
    }
    
    setupEvents() {
        // Event type card buttons
        const eventTypeCards = this.element.querySelectorAll('.event-type-card button:not([disabled])');
        eventTypeCards.forEach(button => {
            button.addEventListener('click', (e) => {
                const card = e.target.closest('.event-type-card');
                const eventType = card?.getAttribute('data-event-type');
                
                if (eventType) {
                    console.log('📱 EventTypeSelectionScreen: Event type selected:', eventType);
                    this.send('EVENT_TYPE_SELECTED', eventType);
                }
            });
        });
        
        // Back button
        const backBtn = this.element.querySelector('#backBtn');
        if (backBtn) {
            backBtn.addEventListener('click', () => {
                console.log('📱 EventTypeSelectionScreen: Back button clicked');
                this.send('BACK', { target: 'dashboard' });
            });
        }
    }
    
    handleEventTypeSelection(eventType) {
        console.log('📱 EventTypeSelectionScreen: Handling selection:', eventType);
        console.log('📱 EventTypeSelectionScreen: Current roleType:', this.roleType);
        
        // Use role state machine if available
        if (window.roleStateMachine) {
            console.log('📱 EventTypeSelectionScreen: Using role state machine for event type:', eventType);
            window.roleStateMachine.send('EVENT_TYPE_SELECTED', eventType);
            return; // Let role state machine handle navigation
        }
        
        // Fallback: Route to appropriate screen based on event type and role
        let targetScreen = null;
        
        switch (eventType) {
            case 'practice':
                // Players go directly to RSVP
                // Coaches need to choose between Manage and RSVP
                if (this.roleType === 'player') {
                    targetScreen = 'practiceRSVP';
                } else {
                    // Show coach practice options (Manage vs RSVP)
                    targetScreen = 'practiceOptions';
                }
                console.log('📱 EventTypeSelectionScreen: Practice routing ->', targetScreen, '(roleType:', this.roleType, ')');
                break;
            case 'game':
                targetScreen = 'addGame';
                break;
            case 'meeting':
                targetScreen = 'addMeeting';
                break;
            default:
                console.error('📱 EventTypeSelectionScreen: Unknown event type:', eventType);
                this.send('CANCEL');
                return;
        }
        
        // Navigate to the appropriate screen
        console.log('📱 EventTypeSelectionScreen: Navigating to:', targetScreen, 'with roleType:', this.roleType);
        this.send('NAVIGATE', {
            screen: targetScreen,
            data: {
                user: this.user,
                teamContext: this.teamContext,
                roleType: this.roleType,
                eventType: eventType
            }
        });
    }
    
    navigate(navData) {
        if (navData.screen) {
            // Use role state machine if available
            if (window.roleStateMachine) {
                console.log('📱 EventTypeSelectionScreen: Using role state machine for navigation');
                // Don't navigate directly - role state machine will handle it
                // The state machine's enter() callback will call navigateToScreen()
            } else {
                // Fallback
                setTimeout(() => {
                    this.navigateTo(navData.screen, navData.data);
                }, 100);
            }
        } else if (navData.target === 'dashboard') {
            setTimeout(() => {
                this.navigateTo('dashboard', {
                    user: this.user,
                    roleSelection: {
                        roleType: this.roleType,
                        user: this.user,
                        roleData: {
                            teamId: this.teamContext.id,
                            teamName: this.teamContext.name,
                            clubName: this.teamContext.club
                        }
                    },
                    teamContext: this.teamContext
                });
            }, 100);
        }
    }
    
    async onExit() {
        console.log('📱 EventTypeSelectionScreen: Exiting');
        await super.onExit();
    }
}
