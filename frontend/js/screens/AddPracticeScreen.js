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
        this.venues = []; // Store venues list
        this.practices = []; // Store future practices
        
        // Create state machine after initialization
        this.stateMachine = new StateMachine({
            initial: 'loading',
            states: {
                loading: {
                    on: {
                        READY: 'editing',
                        ERROR: 'error'
                    },
                    onEntry: async () => {
                        await this.loadVenues();
                        await this.loadPractices();
                    },
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
                        SUCCESS: 'editing',
                        ERROR: 'editing'
                    },
                    onEntry: () => this.savePractice(),
                    onExit: () => console.log('📱 AddPracticeScreen: Save complete')
                },
                error: {
                    on: {
                        RETRY: 'loading'
                    },
                    onEntry: () => console.log('📱 AddPracticeScreen: Error loading venues')
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
        console.log('📱 AddPracticeScreen: Container:', this.container);
        console.log('📱 AddPracticeScreen: Container display before:', this.container ? this.container.style.display : 'no container');
        
        // Call parent onEnter
        await super.onEnter(data);
        
        console.log('📱 AddPracticeScreen: Container display after super:', this.container ? this.container.style.display : 'no container');
        console.log('📱 AddPracticeScreen: Element:', this.element);
        
        // Store context from navigation
        this.user = data.user;
        this.teamContext = data.teamContext;
        this.roleType = data.roleType;
        
        // Start loading (will load venues)
        // Don't send READY yet - will be sent after venues load
    }
    
    async loadVenues() {
        console.log('📱 AddPracticeScreen: Loading venues...');
        
        try {
            const response = await this.authService.request('/api/venues', {
                method: 'GET'
            });
            
            if (response.success) {
                this.venues = response.data || [];
                console.log('📱 AddPracticeScreen: Loaded', this.venues.length, 'venues');
                
                // Re-render to update the dropdown with venues
                const venueSelect = this.element.querySelector('#venueId');
                if (venueSelect && this.venues.length > 0) {
                    // Add venue options
                    const optionsHTML = this.venues.map(venue => `
                        <option value="${venue.id}">
                            ${venue.name}${venue.city ? ` - ${venue.city}, ${venue.state}` : ''}
                        </option>
                    `).join('');
                    
                    // Insert before the "Add custom location" option
                    const customOption = venueSelect.querySelector('option[value="__custom__"]');
                    if (customOption) {
                        customOption.insertAdjacentHTML('beforebegin', optionsHTML);
                    }
                }
                
                this.send('READY');
            } else {
                console.error('📱 AddPracticeScreen: Failed to load venues:', response.message);
                this.venues = [];
                this.send('READY'); // Continue anyway with empty venues
            }
        } catch (error) {
            console.error('📱 AddPracticeScreen: Error loading venues:', error);
            this.venues = [];
            this.send('READY'); // Continue anyway with empty venues
        }
    }
    
    async loadPractices() {
        console.log('📱 AddPracticeScreen: Loading practices...');
        
        try {
            const response = await this.authService.request(`/api/events/${this.teamContext.id}`, {
                method: 'GET'
            });
            
            if (response.success && response.data) {
                // Filter for future practices only
                const now = new Date();
                this.practices = response.data.filter(event => {
                    const eventDate = new Date(event.date);
                    return event.event_type === 'practice' && eventDate >= now;
                }).sort((a, b) => new Date(a.date) - new Date(b.date)); // Sort by date ascending
                
                console.log('📱 AddPracticeScreen: Loaded', this.practices.length, 'future practices');
                
                // Update the practices list in the UI
                this.updatePracticesList();
            } else {
                console.error('📱 AddPracticeScreen: Failed to load practices:', response.message);
            }
            
        } catch (error) {
            console.error('📱 AddPracticeScreen: Error loading practices:', error);
            // Don't fail - practices list is optional
            this.practices = [];
        }
    }
    
    updatePracticesList() {
        const practicesListContainer = this.element.querySelector('#practicesList');
        if (!practicesListContainer) return;
        
        if (this.practices.length === 0) {
            practicesListContainer.innerHTML = '<p style="color: #6b7280; text-align: center; padding: 2rem;">No upcoming practices scheduled</p>';
            return;
        }
        
        const practicesHtml = this.practices.map(practice => {
            const date = new Date(practice.date);
            const dateStr = date.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric', year: 'numeric' });
            
            return `
                <div class="practice-item" style="background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 8px; padding: 1rem; margin-bottom: 1rem;">
                    <div style="display: flex; justify-content: space-between; align-items: start;">
                        <div>
                            <div style="font-weight: 600; font-size: 1rem; color: #111827; margin-bottom: 0.25rem;">
                                ${dateStr}
                            </div>
                            <div style="color: #6b7280; font-size: 0.875rem; margin-bottom: 0.5rem;">
                                ${practice.start_time} - ${practice.end_time}
                            </div>
                            ${practice.location ? `
                                <div style="color: #374151; font-size: 0.875rem;">
                                    📍 ${practice.location}
                                </div>
                            ` : ''}
                            ${practice.notes ? `
                                <div style="color: #6b7280; font-size: 0.875rem; margin-top: 0.5rem;">
                                    ${practice.notes}
                                </div>
                            ` : ''}
                        </div>
                    </div>
                </div>
            `;
        }).join('');
        
        practicesListContainer.innerHTML = practicesHtml;
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
                
                <div class="screen-content" style="max-width: 1200px; margin: 2rem auto; padding: 0 2rem;">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem;">
                        <!-- Add Practice Form -->
                        <div>
                            <h2 style="font-size: 1.5rem; margin-bottom: 1rem;">New Practice</h2>
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
                                <label for="venueId" style="display: block; font-weight: 500; margin-bottom: 0.5rem;">Venue</label>
                                <select 
                                    id="venueId" 
                                    name="venueId" 
                                    style="width: 100%; padding: 0.5rem; border: 1px solid #ccc; border-radius: 4px; font-size: 1rem;"
                                >
                                    <option value="">Select a venue...</option>
                                    ${(this.venues || []).map(venue => `
                                        <option value="${venue.id}">
                                            ${venue.name}${venue.city ? ` - ${venue.city}, ${venue.state}` : ''}
                                        </option>
                                    `).join('')}
                                    <option value="__custom__">➕ Add custom location</option>
                                </select>
                            </div>
                            
                            <div class="form-group" id="customLocationGroup" style="margin-bottom: 1.5rem; display: none;">
                                <label for="customLocation" style="display: block; font-weight: 500; margin-bottom: 0.5rem;">Custom Location</label>
                                <input 
                                    type="text" 
                                    id="customLocation" 
                                    name="customLocation" 
                                    placeholder="Enter custom location"
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
                
                <!-- Upcoming Practices List -->
                <div>
                    <h2 style="font-size: 1.5rem; margin-bottom: 1rem;">Upcoming Practices</h2>
                    <div id="practicesList" style="background: white; border: 1px solid #ccc; border-radius: 8px; padding: 1.5rem; max-height: 600px; overflow-y: auto;">
                        <p style="color: #6b7280; text-align: center; padding: 2rem;">Loading practices...</p>
                    </div>
                </div>
            </div>
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
        const venueSelect = this.element.querySelector('#venueId');
        const customLocationGroup = this.element.querySelector('#customLocationGroup');
        
        // Handle venue selection change
        if (venueSelect && customLocationGroup) {
            venueSelect.addEventListener('change', (e) => {
                if (e.target.value === '__custom__') {
                    customLocationGroup.style.display = 'block';
                } else {
                    customLocationGroup.style.display = 'none';
                }
            });
        }
        
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
            
            // Get venue - either from dropdown or custom location
            const venueId = formData.get('venueId');
            let location = null;
            
            if (venueId === '__custom__') {
                location = formData.get('customLocation');
            } else if (venueId) {
                const venue = this.venues.find(v => v.id === venueId);
                location = venue ? venue.name : null;
            }
            
            const practiceData = {
                team_id: this.teamContext.id,
                event_type: 'practice',
                date: formData.get('practiceDate'),
                start_time: formData.get('startTime'),
                end_time: formData.get('endTime'),
                location: location,
                notes: formData.get('notes') || null
            };
            
            console.log('📱 AddPracticeScreen: Practice data:', practiceData);
            
            // Call API to save practice
            const result = await this.authService.request('/api/events', {
                method: 'POST',
                body: JSON.stringify(practiceData)
            });
            
            if (result.success) {
                console.log('📱 AddPracticeScreen: Practice saved successfully');
                
                // Clear the form
                const form = this.element.querySelector('#practiceForm');
                if (form) {
                    form.reset();
                }
                
                // Reload practices list to show the new practice
                await this.loadPractices();
                
                // Show success message (brief alert)
                const successMsg = document.createElement('div');
                successMsg.style.cssText = 'position: fixed; top: 20px; right: 20px; background: #10b981; color: white; padding: 1rem 1.5rem; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); z-index: 1000; font-weight: 500;';
                successMsg.textContent = '✓ Practice created successfully!';
                document.body.appendChild(successMsg);
                
                // Remove message after 3 seconds
                setTimeout(() => {
                    successMsg.remove();
                }, 3000);
                
                this.send('SUCCESS');
            } else {
                console.error('📱 AddPracticeScreen: Failed to save practice:', result.message);
                alert('Error saving practice: ' + result.message);
                this.send('ERROR');
            }
            
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
