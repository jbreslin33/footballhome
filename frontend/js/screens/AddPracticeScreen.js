/**
 * Add Practice Screen
 * Handles creating new practice events
 */

class AddPracticeScreen extends Screen {
    constructor(container, props = {}) {
        super(container, props, {
            screenName: 'addPractice'
        });
        
        this.authService = props.authService || new AuthService();
        this.user = null;
        this.teamContext = null;
        this.roleType = null;
        
        // Create state machine after initialization
        this.stateMachine = new StateMachine({
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
        });
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
        
        const html = `
            <div class="screen add-practice-screen" style="background: white; min-height: 100vh;">
                <header class="screen-header" style="background: #f3f4f6; padding: 1rem; border-bottom: 2px solid #ccc;">
                    <button id="backBtn" class="back-button" style="padding: 0.5rem 1rem; cursor: pointer;">
                        <span class="icon">←</span> Back
                    </button>
                    <h1 style="display: inline-block; margin-left: 1rem;">Add Practice</h1>
                </header>
                
                <div class="screen-content" style="max-width: 800px; margin: 2rem auto; padding: 2rem;">
                    <form id="practiceForm" class="practice-form" style="background: white; border: 1px solid #ccc; border-radius: 8px; padding: 2rem;">
                        <div class="form-section" style="margin-bottom: 2rem;">
                            <h2 style="font-size: 1.25rem; margin-bottom: 1rem; padding-bottom: 0.5rem; border-bottom: 2px solid #e5e7eb;">Practice Details</h2>
                            
                            <div class="form-group" style="margin-bottom: 1.5rem;">
                                <label for="practiceDate" style="display: block; font-weight: 500; margin-bottom: 0.5rem;">Date *</label>
                                <input 
                                    type="date" 
                                    id="practiceDate" 
                                    name="practiceDate" 
                                    required
                                    min="${new Date().toISOString().split('T')[0]}"
                                    style="width: 100%; padding: 0.5rem; border: 1px solid #ccc; border-radius: 4px; font-size: 1rem;"
                                />
                            </div>
                            
                            <div class="form-group" style="margin-bottom: 1.5rem;">
                                <label for="startTime" style="display: block; font-weight: 500; margin-bottom: 0.5rem;">Start Time *</label>
                                <input 
                                    type="time" 
                                    id="startTime" 
                                    name="startTime" 
                                    required
                                    style="width: 100%; padding: 0.5rem; border: 1px solid #ccc; border-radius: 4px; font-size: 1rem;"
                                />
                            </div>
                            
                            <div class="form-group" style="margin-bottom: 1.5rem;">
                                <label for="endTime" style="display: block; font-weight: 500; margin-bottom: 0.5rem;">End Time *</label>
                                <input 
                                    type="time" 
                                    id="endTime" 
                                    name="endTime" 
                                    required
                                    style="width: 100%; padding: 0.5rem; border: 1px solid #ccc; border-radius: 4px; font-size: 1rem;"
                                />
                            </div>
                            
                            <div class="form-group" style="margin-bottom: 1.5rem;">
                                <label for="location" style="display: block; font-weight: 500; margin-bottom: 0.5rem;">Location</label>
                                <input 
                                    type="text" 
                                    id="location" 
                                    name="location" 
                                    placeholder="Enter practice location"
                                    style="width: 100%; padding: 0.5rem; border: 1px solid #ccc; border-radius: 4px; font-size: 1rem;"
                                />
                            </div>
                            
                            <div class="form-group" style="margin-bottom: 1.5rem;">
                                <label for="notes" style="display: block; font-weight: 500; margin-bottom: 0.5rem;">Notes</label>
                                <textarea 
                                    id="notes" 
                                    name="notes" 
                                    rows="4"
                                    placeholder="Add any notes or special instructions..."
                                    style="width: 100%; padding: 0.5rem; border: 1px solid #ccc; border-radius: 4px; font-size: 1rem; resize: vertical;"
                                ></textarea>
                            </div>
                        </div>
                        
                        <div class="form-actions" style="display: flex; gap: 1rem; justify-content: flex-end; padding-top: 1.5rem; border-top: 1px solid #e5e7eb;">
                            <button type="button" id="cancelBtn" class="btn btn-secondary" style="padding: 0.75rem 1.5rem; background: white; color: #374151; border: 1px solid #d1d5db; border-radius: 4px; cursor: pointer; font-size: 1rem; font-weight: 500;">
                                Cancel
                            </button>
                            <button type="submit" id="saveBtn" class="btn btn-primary" style="padding: 0.75rem 1.5rem; background: #2563eb; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 1rem; font-weight: 500;">
                                Save Practice
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        `;
        
        console.log('📱 AddPracticeScreen: HTML length:', html.length);
        console.log('📱 AddPracticeScreen: HTML preview:', html.substring(0, 200));
        
        return html;
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
