/**
 * Add Practice Screen
 * Handles creating new practice events
 */

class AddPracticeScreen extends Screen {
    constructor(screenManager, authService) {
        super(
            screenManager,
            authService,
            {
                initial: 'loading',
                states: {
                    loading: {
                        on: {
                            READY: 'editing'
                        },
                        onEntry: () => console.log('📱 AddPracticeScreen: Loading...'),
                        onExit: () => console.log('📱 AddPracticeScreen: Ready')
                    },
                    editing: {
                        on: {
                            SAVE: 'saving',
                            CANCEL: 'navigating'
                        },
                        onEntry: () => this.setupForm(),
                        onExit: () => console.log('📱 AddPracticeScreen: Exiting edit mode')
                    },
                    saving: {
                        on: {
                            SUCCESS: 'navigating',
                            ERROR: 'editing'
                        },
                        onEntry: () => this.savePractice(),
                        onExit: () => console.log('📱 AddPracticeScreen: Save complete')
                    },
                    navigating: {
                        on: {
                            COMPLETE: 'loading'
                        },
                        onEntry: () => {
                            console.log('📱 AddPracticeScreen: Navigating back');
                            this.navigateBack();
                        }
                    }
                }
            }
        );
        
        this.user = null;
        this.teamContext = null;
        this.roleType = null;
    }
    
    async onEnter(data) {
        console.log('📱 AddPracticeScreen: Entering with data:', data);
        
        // Store context from navigation
        this.user = data.user;
        this.teamContext = data.teamContext;
        this.roleType = data.roleType;
        
        // Start loading
        this.send('READY');
    }
    
    render() {
        console.log('📱 AddPracticeScreen: Rendering');
        
        return `
            <div class="screen add-practice-screen">
                <header class="screen-header">
                    <button id="backBtn" class="back-button">
                        <span class="icon">←</span> Back
                    </button>
                    <h1>Add Practice</h1>
                </header>
                
                <div class="screen-content">
                    <form id="practiceForm" class="practice-form">
                        <div class="form-section">
                            <h2>Practice Details</h2>
                            
                            <div class="form-group">
                                <label for="practiceDate">Date *</label>
                                <input 
                                    type="date" 
                                    id="practiceDate" 
                                    name="practiceDate" 
                                    required
                                    min="${new Date().toISOString().split('T')[0]}"
                                />
                            </div>
                            
                            <div class="form-group">
                                <label for="startTime">Start Time *</label>
                                <input 
                                    type="time" 
                                    id="startTime" 
                                    name="startTime" 
                                    required
                                />
                            </div>
                            
                            <div class="form-group">
                                <label for="endTime">End Time *</label>
                                <input 
                                    type="time" 
                                    id="endTime" 
                                    name="endTime" 
                                    required
                                />
                            </div>
                            
                            <div class="form-group">
                                <label for="location">Location</label>
                                <input 
                                    type="text" 
                                    id="location" 
                                    name="location" 
                                    placeholder="Enter practice location"
                                />
                            </div>
                            
                            <div class="form-group">
                                <label for="notes">Notes</label>
                                <textarea 
                                    id="notes" 
                                    name="notes" 
                                    rows="4"
                                    placeholder="Add any notes or special instructions..."
                                ></textarea>
                            </div>
                        </div>
                        
                        <div class="form-actions">
                            <button type="button" id="cancelBtn" class="btn btn-secondary">
                                Cancel
                            </button>
                            <button type="submit" id="saveBtn" class="btn btn-primary">
                                Save Practice
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        `;
    }
    
    setupForm() {
        console.log('📱 AddPracticeScreen: Setting up form');
        
        const form = this.element.querySelector('#practiceForm');
        const cancelBtn = this.element.querySelector('#cancelBtn');
        const backBtn = this.element.querySelector('#backBtn');
        
        // Form submission
        if (form) {
            form.addEventListener('submit', (e) => {
                e.preventDefault();
                console.log('📱 AddPracticeScreen: Form submitted');
                this.send('SAVE');
            });
        }
        
        // Cancel button
        if (cancelBtn) {
            cancelBtn.addEventListener('click', () => {
                console.log('📱 AddPracticeScreen: Cancel clicked');
                this.send('CANCEL');
            });
        }
        
        // Back button
        if (backBtn) {
            backBtn.addEventListener('click', () => {
                console.log('📱 AddPracticeScreen: Back clicked');
                this.send('CANCEL');
            });
        }
    }
    
    async savePractice() {
        console.log('📱 AddPracticeScreen: Saving practice...');
        
        try {
            const form = this.element.querySelector('#practiceForm');
            const formData = new FormData(form);
            
            const practiceData = {
                team_id: this.teamContext.id,
                event_type: 'practice',
                date: formData.get('practiceDate'),
                start_time: formData.get('startTime'),
                end_time: formData.get('endTime'),
                location: formData.get('location') || null,
                notes: formData.get('notes') || null
            };
            
            console.log('📱 AddPracticeScreen: Practice data:', practiceData);
            
            // TODO: Call API to save practice
            // const result = await this.authService.request('/api/events', {
            //     method: 'POST',
            //     body: JSON.stringify(practiceData)
            // });
            
            // For now, simulate success
            await new Promise(resolve => setTimeout(resolve, 500));
            
            console.log('📱 AddPracticeScreen: Practice saved successfully');
            this.send('SUCCESS');
            
        } catch (error) {
            console.error('📱 AddPracticeScreen: Error saving practice:', error);
            alert('Error saving practice: ' + error.message);
            this.send('ERROR');
        }
    }
    
    navigateBack() {
        console.log('📱 AddPracticeScreen: Navigating back to dashboard');
        
        this.emit('navigate', {
            screen: 'dashboard',
            data: {
                user: this.user,
                teamContext: this.teamContext,
                roleType: this.roleType
            }
        });
        
        this.send('COMPLETE');
    }
    
    onExit() {
        console.log('📱 AddPracticeScreen: Exiting');
    }
}
