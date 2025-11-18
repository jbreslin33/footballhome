/**
 * Practice RSVP Screen
 * Allows players to view upcoming practices and RSVP
 */

class PracticeRSVPScreen extends Screen {
    constructor(container, props = {}) {
        super(container, props, {
            screenName: 'practiceRSVP'
        });
        
        this.authService = props.authService || new AuthService();
        this.user = null;
        this.teamContext = null;
        this.roleType = null;
        this.practices = [];
        
        // Create state machine
        this.stateMachine = new StateMachine({
            initial: 'loading',
            states: {
                loading: {
                    on: {
                        READY: 'viewing',
                        ERROR: 'error'
                    },
                    onEntry: async () => {
                        await this.loadPractices();
                    },
                    onExit: () => console.log('📱 PracticeRSVPScreen: Ready')
                },
                viewing: {
                    on: {
                        RSVP: 'updating',
                        CANCEL: 'navigating'
                    },
                    onEntry: () => this.updatePracticesList(),
                    onExit: () => console.log('📱 PracticeRSVPScreen: Exiting view mode')
                },
                updating: {
                    on: {
                        SUCCESS: 'viewing',
                        ERROR: 'viewing'
                    },
                    onEntry: (data) => this.saveRSVP(data),
                    onExit: () => console.log('📱 PracticeRSVPScreen: RSVP update complete')
                },
                error: {
                    on: {
                        RETRY: 'loading'
                    },
                    onEntry: () => console.log('📱 PracticeRSVPScreen: Error loading practices')
                },
                navigating: {
                    onEntry: () => {
                        console.log('📱 PracticeRSVPScreen: Navigating back');
                        this.navigateBack();
                    }
                }
            }
        });
    }
    
    async onEnter(data) {
        console.log('📱 PracticeRSVPScreen: ✅✅✅ PLAYER RSVP SCREEN ENTERED ✅✅✅');
        console.log('📱 PracticeRSVPScreen: Entering with data:', data);
        await super.onEnter(data);
        
        // Store context from navigation
        this.user = data.user;
        this.teamContext = data.teamContext;
        this.roleType = data.roleType;
    }
    
    async loadPractices() {
        console.log('📱 PracticeRSVPScreen: Loading practices...');
        
        try {
            const response = await this.authService.request(`/api/events/${this.teamContext.id}`, {
                method: 'GET'
            });
            
            console.log('📱 PracticeRSVPScreen: API response:', response);
            
            if (response.success) {
                console.log('📱 PracticeRSVPScreen: Raw events:', response.data);
                
                // Filter for future practices only
                const now = new Date();
                console.log('📱 PracticeRSVPScreen: Current time:', now);
                
                this.practices = (response.data || []).filter(event => {
                    const eventDateTime = new Date(event.event_date);
                    console.log('📱 PracticeRSVPScreen: Event:', event.title, 'date:', event.event_date, 'parsed:', eventDateTime, 'type:', event.type, 'future?', eventDateTime > now);
                    if (event.type !== 'training') return false;
                    
                    // Parse the combined datetime field
                    return eventDateTime > now;
                }).sort((a, b) => new Date(a.event_date) - new Date(b.event_date));
                
                console.log('📱 PracticeRSVPScreen: Loaded', this.practices.length, 'future practices');
                this.send('READY');
            } else {
                console.error('📱 PracticeRSVPScreen: Failed to load practices:', response.message);
                this.send('ERROR');
            }
        } catch (error) {
            console.error('📱 PracticeRSVPScreen: Error loading practices:', error);
            this.send('ERROR');
        }
    }
    
    updatePracticesList() {
        const practicesList = this.element.querySelector('#practicesList');
        if (!practicesList) return;
        
        if (this.practices.length === 0) {
            practicesList.innerHTML = '<p style="text-align: center; color: #6b7280; padding: 2rem;">No upcoming practices scheduled</p>';
            return;
        }
        
        practicesList.innerHTML = this.practices.map(practice => {
            const eventDate = new Date(practice.event_date);
            const dateStr = eventDate.toLocaleDateString('en-US', { 
                weekday: 'short', 
                month: 'short', 
                day: 'numeric' 
            });
            const timeStr = eventDate.toLocaleTimeString('en-US', { 
                hour: 'numeric', 
                minute: '2-digit' 
            });
            
            // Get player's current RSVP status (will be loaded separately)
            const rsvpStatus = practice.player_rsvp_status || 'none';
            
            return `
                <div class="practice-card" style="background: white; border: 2px solid #e5e7eb; border-radius: 8px; padding: 1.5rem; margin-bottom: 1rem;">
                    <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 1rem;">
                        <div>
                            <h3 style="font-size: 1.125rem; font-weight: 600; margin-bottom: 0.5rem;">${dateStr} at ${timeStr}</h3>
                            <p style="color: #6b7280; font-size: 0.875rem;">
                                <strong>Location:</strong> ${practice.location || 'TBD'}<br>
                                <strong>Duration:</strong> ${practice.duration_minutes} minutes
                            </p>
                            ${practice.notes ? `<p style="color: #374151; margin-top: 0.5rem; font-size: 0.875rem;">${practice.notes}</p>` : ''}
                        </div>
                        <div style="text-align: right;">
                            ${this.getRSVPStatusBadge(rsvpStatus)}
                        </div>
                    </div>
                    
                    <div style="border-top: 1px solid #e5e7eb; padding-top: 1rem; margin-top: 1rem;">
                        <p style="font-weight: 500; margin-bottom: 0.75rem; font-size: 0.875rem;">Your Response:</p>
                        <div style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
                            <button 
                                class="rsvp-btn" 
                                data-practice-id="${practice.id}" 
                                data-status="attending"
                                style="flex: 1; min-width: 100px; padding: 0.625rem 1rem; background: ${rsvpStatus === 'attending' ? '#10b981' : '#f3f4f6'}; color: ${rsvpStatus === 'attending' ? 'white' : '#374151'}; border: 1px solid ${rsvpStatus === 'attending' ? '#10b981' : '#d1d5db'}; border-radius: 4px; cursor: pointer; font-size: 0.875rem; font-weight: 500;">
                                ✓ Attending
                            </button>
                            <button 
                                class="rsvp-btn" 
                                data-practice-id="${practice.id}" 
                                data-status="maybe"
                                style="flex: 1; min-width: 100px; padding: 0.625rem 1rem; background: ${rsvpStatus === 'maybe' ? '#f59e0b' : '#f3f4f6'}; color: ${rsvpStatus === 'maybe' ? 'white' : '#374151'}; border: 1px solid ${rsvpStatus === 'maybe' ? '#f59e0b' : '#d1d5db'}; border-radius: 4px; cursor: pointer; font-size: 0.875rem; font-weight: 500;">
                                ? Maybe
                            </button>
                            <button 
                                class="rsvp-btn" 
                                data-practice-id="${practice.id}" 
                                data-status="not_attending"
                                style="flex: 1; min-width: 100px; padding: 0.625rem 1rem; background: ${rsvpStatus === 'not_attending' ? '#ef4444' : '#f3f4f6'}; color: ${rsvpStatus === 'not_attending' ? 'white' : '#374151'}; border: 1px solid ${rsvpStatus === 'not_attending' ? '#ef4444' : '#d1d5db'}; border-radius: 4px; cursor: pointer; font-size: 0.875rem; font-weight: 500;">
                                ✗ Can't Attend
                            </button>
                        </div>
                    </div>
                </div>
            `;
        }).join('');
        
        // Set up event listeners
        this.setupRSVPButtons();
    }
    
    getRSVPStatusBadge(status) {
        const badges = {
            'attending': '<span style="background: #10b981; color: white; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600;">ATTENDING</span>',
            'maybe': '<span style="background: #f59e0b; color: white; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600;">MAYBE</span>',
            'not_attending': '<span style="background: #ef4444; color: white; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600;">NOT ATTENDING</span>',
            'none': '<span style="background: #9ca3af; color: white; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600;">NO RESPONSE</span>'
        };
        return badges[status] || badges['none'];
    }
    
    setupRSVPButtons() {
        const rsvpButtons = this.element.querySelectorAll('.rsvp-btn');
        rsvpButtons.forEach(button => {
            button.addEventListener('click', () => {
                const practiceId = button.getAttribute('data-practice-id');
                const status = button.getAttribute('data-status');
                console.log('📱 PracticeRSVPScreen: RSVP clicked:', practiceId, status);
                this.send('RSVP', { practiceId, status });
            });
        });
    }
    
    async saveRSVP(data) {
        const { practiceId, status } = data;
        console.log('📱 PracticeRSVPScreen: Saving RSVP:', practiceId, status);
        
        try {
            const response = await this.authService.request(`/api/events/${practiceId}/rsvp`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    player_id: this.user.id,
                    status: status,
                    notes: ''
                })
            });
            
            if (response.success) {
                console.log('📱 PracticeRSVPScreen: RSVP saved successfully');
                
                // Update local practice data
                const practice = this.practices.find(p => p.id === practiceId);
                if (practice) {
                    practice.player_rsvp_status = status;
                }
                
                // Show success message
                this.showSuccessToast('RSVP updated successfully!');
                
                this.send('SUCCESS');
            } else {
                console.error('📱 PracticeRSVPScreen: Failed to save RSVP:', response.message);
                this.showErrorToast('Failed to save RSVP');
                this.send('ERROR');
            }
        } catch (error) {
            console.error('📱 PracticeRSVPScreen: Error saving RSVP:', error);
            this.showErrorToast('Error saving RSVP');
            this.send('ERROR');
        }
    }
    
    showSuccessToast(message) {
        const toast = document.createElement('div');
        toast.textContent = message;
        toast.style.cssText = 'position: fixed; top: 20px; right: 20px; background: #10b981; color: white; padding: 1rem 1.5rem; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); z-index: 1000; font-weight: 500;';
        document.body.appendChild(toast);
        setTimeout(() => document.body.removeChild(toast), 3000);
    }
    
    showErrorToast(message) {
        const toast = document.createElement('div');
        toast.textContent = message;
        toast.style.cssText = 'position: fixed; top: 20px; right: 20px; background: #ef4444; color: white; padding: 1rem 1.5rem; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); z-index: 1000; font-weight: 500;';
        document.body.appendChild(toast);
        setTimeout(() => document.body.removeChild(toast), 3000);
    }
    
    render() {
        console.log('📱 PracticeRSVPScreen: Rendering');
        
        return `
            <div class="screen practice-rsvp-screen" style="background: white; min-height: 100vh;">
                <header class="screen-header" style="background: #f3f4f6; padding: 1rem; border-bottom: 2px solid #ccc;">
                    <button id="backBtn" class="back-button" style="padding: 0.5rem 1rem; cursor: pointer;">
                        <span class="icon">←</span> Back
                    </button>
                    <h1 style="margin: 1rem 0; font-size: 1.5rem;">Upcoming Practices</h1>
                    <p style="color: #6b7280;">RSVP to let your coach know if you'll be attending</p>
                </header>
                
                <main style="padding: 2rem; max-width: 800px; margin: 0 auto;">
                    <div id="practicesList">
                        <p style="text-align: center; color: #6b7280;">Loading practices...</p>
                    </div>
                </main>
            </div>
        `;
    }
    
    setupForm() {
        console.log('📱 PracticeRSVPScreen: Setting up form');
        
        const backBtn = this.element.querySelector('#backBtn');
        
        // Back button
        if (backBtn) {
            backBtn.addEventListener('click', () => {
                console.log('📱 PracticeRSVPScreen: Back clicked');
                this.send('CANCEL');
            });
        }
    }
    
    navigateBack() {
        console.log('📱 PracticeRSVPScreen: Navigating back to event type selection');
        
        setTimeout(() => {
            this.navigateTo('eventTypeSelection', {
                user: this.user,
                teamContext: this.teamContext,
                roleType: this.roleType
            });
        }, 100);
    }
    
    onExit() {
        console.log('📱 PracticeRSVPScreen: Exiting');
    }
}
