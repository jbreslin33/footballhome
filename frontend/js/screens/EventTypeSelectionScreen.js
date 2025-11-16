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
                        <span class="brand-text">Football Home - Add Event</span>
                    </div>
                    <div class="navbar-menu">
                        ${this.teamContext ? `<span class="navbar-context">${this.teamContext.name}</span>` : ''}
                        <button id="backBtn" class="btn btn-secondary btn-sm">Back to Dashboard</button>
                    </div>
                </nav>
                
                <!-- Main Content -->
                <main class="event-type-main">
                    <div class="event-type-header">
                        <h2>What type of event?</h2>
                        <p>Choose the type of event you want to create</p>
                    </div>
                    
                    <div class="event-type-grid">
                        <!-- Practice Card -->
                        <div class="event-type-card" data-event-type="practice">
                            <div class="event-card-icon">📋</div>
                            <h3>Practice</h3>
                            <p>Schedule a team practice session</p>
                            <ul class="event-features">
                                <li>Set date and time</li>
                                <li>Choose location</li>
                                <li>Add practice plan</li>
                                <li>Notify players</li>
                            </ul>
                            <button class="btn btn-primary btn-lg">Create Practice</button>
                        </div>
                        
                        <!-- Game Card -->
                        <div class="event-type-card" data-event-type="game">
                            <div class="event-card-icon">⚽</div>
                            <h3>Game</h3>
                            <p>Schedule a competitive match</p>
                            <ul class="event-features">
                                <li>Set date and time</li>
                                <li>Select opponent</li>
                                <li>Choose venue</li>
                                <li>Game details</li>
                            </ul>
                            <button class="btn btn-primary btn-lg" disabled>Coming Soon</button>
                        </div>
                        
                        <!-- Meeting Card -->
                        <div class="event-type-card" data-event-type="meeting">
                            <div class="event-card-icon">💬</div>
                            <h3>Meeting</h3>
                            <p>Schedule a team meeting</p>
                            <ul class="event-features">
                                <li>Set date and time</li>
                                <li>Choose location</li>
                                <li>Add agenda</li>
                                <li>Invite attendees</li>
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
        
        // Route to appropriate screen based on event type
        let targetScreen = null;
        
        switch (eventType) {
            case 'practice':
                targetScreen = 'addPractice';
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
            setTimeout(() => {
                this.navigateTo(navData.screen, navData.data);
            }, 100);
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
