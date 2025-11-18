/**
 * PracticeOptionsScreen - Choose between managing or RSVPing to practices
 * Shows different options based on role:
 * - Coaches: Can see both Manage and RSVP options
 * - Players: Only see RSVP option (but still get to click through)
 */
class PracticeOptionsScreen extends Screen {
    constructor(container, props = {}) {
        super(container, props, {
            screenName: 'practiceOptions'
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
                        OPTION_SELECTED: 'selecting',
                        BACK: 'navigating'
                    },
                    onEntry: () => this.showOptions()
                },
                selecting: {
                    on: { 
                        NAVIGATE: 'navigating',
                        CANCEL: 'ready'
                    },
                    onEntry: (option) => this.handleOptionSelection(option)
                },
                navigating: {
                    onEntry: (navData) => this.navigate(navData)
                }
            }
        });
    }
    
    render() {
        const canManage = this.roleType === 'coach' || this.roleType === 'admin';
        
        return `
            <div class="practice-options-screen">
                <!-- Navigation Bar -->
                <nav class="navbar">
                    <div class="navbar-brand">
                        <span class="brand-text">Football Home - Practices</span>
                    </div>
                    <div class="navbar-menu">
                        ${this.teamContext ? `<span class="navbar-context">${this.teamContext.name}</span>` : ''}
                        <button id="backBtn" class="btn btn-secondary btn-sm">Back</button>
                    </div>
                </nav>
                
                <!-- Main Content -->
                <main class="practice-options-main">
                    <div class="practice-options-header">
                        <h2>Practices</h2>
                        <p>${canManage ? 'What would you like to do?' : 'View and RSVP to practices'}</p>
                    </div>
                    
                    <div class="practice-options-grid ${!canManage ? 'single-option' : ''}">
                        ${canManage ? `
                        <!-- Manage Practices Card (Coach/Admin only) -->
                        <div class="practice-option-card" data-option="manage">
                            <div class="practice-option-icon">⚙️</div>
                            <h3>Manage Practices</h3>
                            <p>Create, edit, and delete team practices</p>
                            <ul class="practice-option-features">
                                <li>Schedule new practices</li>
                                <li>Edit existing practices</li>
                                <li>Delete practices</li>
                                <li>Manage practice details</li>
                            </ul>
                            <button class="btn btn-primary btn-lg">Manage Practices</button>
                        </div>
                        ` : ''}
                        
                        <!-- RSVP to Practices Card (All roles) -->
                        <div class="practice-option-card" data-option="rsvp">
                            <div class="practice-option-icon">✓</div>
                            <h3>RSVP to Practices</h3>
                            <p>View and RSVP to upcoming practices</p>
                            <ul class="practice-option-features">
                                <li>View upcoming practices</li>
                                <li>Confirm your attendance</li>
                                <li>See practice details</li>
                                <li>Track your RSVPs</li>
                            </ul>
                            <button class="btn btn-primary btn-lg">View & RSVP</button>
                        </div>
                    </div>
                </main>
            </div>
        `;
    }
    
    async onEnter(data = null) {
        console.log('📱 PracticeOptionsScreen: onEnter called with:', data);
        await super.onEnter(data);
        
        this.user = data?.user || this.user;
        this.teamContext = data?.teamContext || this.teamContext;
        this.roleType = data?.roleType || 'coach';
        
        if (!this.user) {
            console.error('📱 PracticeOptionsScreen: No user data provided');
            return;
        }
        
        if (!this.teamContext) {
            console.error('📱 PracticeOptionsScreen: No team context provided');
            return;
        }
        
        console.log('📱 PracticeOptionsScreen: Initialized for:', this.roleType);
        this.send('READY');
    }
    
    showOptions() {
        this.setupEvents();
    }
    
    setupEvents() {
        // Option card buttons
        const optionCards = this.element.querySelectorAll('.practice-option-card button');
        optionCards.forEach(button => {
            button.addEventListener('click', (e) => {
                const card = e.target.closest('.practice-option-card');
                const option = card?.getAttribute('data-option');
                
                if (option) {
                    console.log('📱 PracticeOptionsScreen: Option selected:', option);
                    this.send('OPTION_SELECTED', option);
                }
            });
        });
        
        // Back button
        const backBtn = this.element.querySelector('#backBtn');
        if (backBtn) {
            backBtn.addEventListener('click', () => {
                console.log('📱 PracticeOptionsScreen: Back button clicked');
                this.send('BACK', { target: 'eventTypeSelection' });
            });
        }
    }
    
    handleOptionSelection(option) {
        console.log('📱 PracticeOptionsScreen: Handling option:', option);
        
        // Route to appropriate screen
        let targetScreen = null;
        
        switch (option) {
            case 'manage':
                targetScreen = 'managePractices';
                break;
            case 'rsvp':
                targetScreen = 'practiceRSVP';
                break;
            default:
                console.error('📱 PracticeOptionsScreen: Unknown option:', option);
                this.send('CANCEL');
                return;
        }
        
        // Navigate to the selected screen
        this.send('NAVIGATE', {
            screen: targetScreen,
            data: {
                user: this.user,
                teamContext: this.teamContext,
                roleType: this.roleType
            }
        });
    }
    
    navigate(navData) {
        if (navData.screen) {
            // Use role state machine if available
            if (window.roleStateMachine && navData.screen === 'managePractices') {
                console.log('📱 PracticeOptionsScreen: Using role state machine - MANAGE_SELECTED');
                window.roleStateMachine.send('MANAGE_SELECTED');
            } else if (window.roleStateMachine && navData.screen === 'practiceRSVP') {
                console.log('📱 PracticeOptionsScreen: Using role state machine - RSVP_SELECTED');
                window.roleStateMachine.send('RSVP_SELECTED');
            } else {
                // Fallback
                setTimeout(() => {
                    this.navigateTo(navData.screen, navData.data);
                }, 100);
            }
        } else if (navData.target === 'eventTypeSelection') {
            // Use role state machine for back navigation
            if (window.roleStateMachine) {
                console.log('📱 PracticeOptionsScreen: Using role state machine for back navigation');
                window.roleStateMachine.goBack();
            } else {
                // Fallback
                setTimeout(() => {
                    this.navigateTo('eventTypeSelection', {
                        user: this.user,
                        teamContext: this.teamContext,
                        roleType: this.roleType
                    });
                }, 100);
            }
        }
    }
    
    async onExit() {
        console.log('📱 PracticeOptionsScreen: Exiting');
        await super.onExit();
    }
}
