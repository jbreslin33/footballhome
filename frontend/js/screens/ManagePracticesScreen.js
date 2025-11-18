/**
 * Manage Practices Screen
 * Handles creating, editing, and deleting practice events
 */

class ManagePracticesScreen extends Screen {
    constructor(container, props = {}) {
        super(container, props, {
            screenName: 'managePractices'
        });
        
        this.authService = props.authService || new AuthService();
        this.user = null;
        this.teamContext = null;
        this.roleType = null;
        this.venues = []; // Store venues list
        this.practices = []; // Store future practices
        this.editingPracticeId = null; // Track which practice is being edited
        this.formSetup = false; // Track if form listeners are already set up
        
        // Create state machine after initialization
        this.stateMachine = new StateMachine({
            initial: 'initializing',
            states: {
                initializing: {
                    on: {
                        LOAD: 'loading',
                        ERROR: 'error'
                    },
                    onEntry: () => console.log('📱 ManagePracticesScreen: Waiting for context'),
                    onExit: () => console.log('📱 ManagePracticesScreen: Context received')
                },
                loading: {
                    on: {
                        READY: 'editing',
                        ERROR: 'error'
                    },
                    onEntry: async () => {
                        await this.loadVenues();
                        await this.loadPractices();
                    },
                    onExit: () => console.log('📱 ManagePracticesScreen: Ready')
                },
                editing: {
                    on: {
                        SAVE: 'saving',
                        CANCEL: 'navigating'
                    },
                    onEntry: () => this.setupForm(),
                    onExit: () => console.log('📱 ManagePracticesScreen: Exiting edit mode')
                },
                saving: {
                    on: {
                        SUCCESS: 'editing',
                        ERROR: 'editing'
                    },
                    onEntry: () => this.savePractice(),
                    onExit: () => console.log('📱 ManagePracticesScreen: Save complete')
                },
                error: {
                    on: {
                        RETRY: 'loading'
                    },
                    onEntry: () => console.log('📱 ManagePracticesScreen: Error loading venues')
                },
                navigating: {
                    onEntry: () => {
                        console.log('📱 ManagePracticesScreen: Navigating back');
                        this.navigateBack();
                    }
                }
            }
        });
    }
    
    async onEnter(data) {
        console.log('📱 ManagePracticesScreen: 🏈🏈🏈 COACH MANAGE SCREEN ENTERED 🏈🏈🏈');
        console.log('📱 ManagePracticesScreen: Entering with data:', data);
        console.log('📱 ManagePracticesScreen: Container:', this.container);
        console.log('📱 ManagePracticesScreen: Container display before:', this.container ? this.container.style.display : 'no container');
        
        // Call parent onEnter
        await super.onEnter(data);
        
        console.log('📱 ManagePracticesScreen: Container display after super:', this.container ? this.container.style.display : 'no container');
        console.log('📱 ManagePracticesScreen: Element:', this.element);
        
        // Store context from navigation
        this.user = data.user;
        this.teamContext = data.teamContext;
        this.roleType = data.roleType;
        
        // Now that we have context, start loading
        this.send('LOAD');
    }
    
    async loadVenues() {
        console.log('📱 ManagePracticesScreen: Loading venues...');
        
        try {
            const response = await this.authService.request('/api/venues', {
                method: 'GET'
            });
            
            if (response.success) {
                this.venues = response.data || [];
                console.log('📱 ManagePracticesScreen: Loaded', this.venues.length, 'venues');
                
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
                console.error('📱 ManagePracticesScreen: Failed to load venues:', response.message);
                this.venues = [];
                this.send('READY'); // Continue anyway with empty venues
            }
        } catch (error) {
            console.error('📱 ManagePracticesScreen: Error loading venues:', error);
            this.venues = [];
            this.send('READY'); // Continue anyway with empty venues
        }
    }
    
    async loadPractices() {
        console.log('📱 ManagePracticesScreen: Loading practices...');
        
        try {
            const response = await this.authService.request(`/api/events/${this.teamContext.id}`, {
                method: 'GET'
            });
            
            console.log('📱 ManagePracticesScreen: API response:', response);
            
            if (response.success && response.data) {
                console.log('📱 ManagePracticesScreen: Raw events:', response.data);
                
                // Filter for future practices only
                const now = new Date();
                console.log('📱 ManagePracticesScreen: Current time:', now);
                
                this.practices = response.data.filter(event => {
                    const eventDate = new Date(event.event_date);
                    console.log('📱 ManagePracticesScreen: Event:', event.title, 'date:', event.event_date, 'parsed:', eventDate, 'type:', event.type, 'future?', eventDate >= now);
                    // API returns type as "training" for practices
                    return event.type === 'training' && eventDate >= now;
                }).sort((a, b) => new Date(a.event_date) - new Date(b.event_date)); // Sort by date ascending
                
                console.log('📱 ManagePracticesScreen: Loaded', this.practices.length, 'future practices from', response.data.length, 'total events');
                
                // Update the practices list in the UI
                this.updatePracticesList();
            } else {
                console.error('📱 ManagePracticesScreen: Failed to load practices:', response.message);
            }
            
        } catch (error) {
            console.error('📱 ManagePracticesScreen: Error loading practices:', error);
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
            // Parse the datetime from API (format: "2025-11-19 18:00:00")
            const datetime = new Date(practice.event_date);
            const dateStr = datetime.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric', year: 'numeric' });
            const timeStr = datetime.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });
            const duration = practice.duration_minutes ? `${practice.duration_minutes} min` : '';
            
            return `
                <div class="practice-item" style="background: ${this.editingPracticeId === practice.id ? '#eff6ff' : '#f9fafb'}; border: 2px solid ${this.editingPracticeId === practice.id ? '#3b82f6' : '#e5e7eb'}; border-radius: 8px; padding: 1rem; margin-bottom: 1rem; position: relative;">
                    <div style="display: flex; justify-content: space-between; align-items: start;">
                        <div style="flex: 1;">
                            <div style="font-weight: 600; font-size: 1rem; color: #111827; margin-bottom: 0.25rem;">
                                ${dateStr}
                            </div>
                            <div style="color: #6b7280; font-size: 0.875rem; margin-bottom: 0.5rem;">
                                ${timeStr}${duration ? ` (${duration})` : ''}
                            </div>
                            ${practice.title ? `
                                <div style="color: #374151; font-size: 0.875rem; font-weight: 500;">
                                    ${practice.title}
                                </div>
                            ` : ''}
                            ${practice.notes ? `
                                <div style="color: #6b7280; font-size: 0.875rem; margin-top: 0.5rem;">
                                    ${practice.notes}
                                </div>
                            ` : ''}
                        </div>
                        <div style="display: flex; gap: 0.5rem; margin-left: 1rem;">
                            <button 
                                class="edit-practice-btn" 
                                data-practice-id="${practice.id}"
                                style="padding: 0.4rem 0.75rem; background: #3b82f6; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 0.875rem; font-weight: 500;"
                                title="Edit practice"
                            >
                                ✏️ Edit
                            </button>
                            <button 
                                class="delete-practice-btn" 
                                data-practice-id="${practice.id}"
                                style="padding: 0.4rem 0.75rem; background: #ef4444; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 0.875rem; font-weight: 500;"
                                title="Delete practice"
                            >
                                🗑️ Delete
                            </button>
                        </div>
                    </div>
                </div>
            `;
        }).join('');
        
        practicesListContainer.innerHTML = practicesHtml;
        
        // Add event listeners for Edit and Delete buttons
        this.setupPracticeActions();
    }
    
    setupPracticeActions() {
        // Edit buttons
        const editButtons = this.element.querySelectorAll('.edit-practice-btn');
        editButtons.forEach(btn => {
            btn.addEventListener('click', (e) => {
                const practiceId = e.currentTarget.dataset.practiceId;
                this.editPractice(practiceId);
            });
        });
        
        // Delete buttons
        const deleteButtons = this.element.querySelectorAll('.delete-practice-btn');
        deleteButtons.forEach(btn => {
            btn.addEventListener('click', (e) => {
                const practiceId = e.currentTarget.dataset.practiceId;
                this.deletePractice(practiceId);
            });
        });
    }
    
    editPractice(practiceId) {
        console.log('📱 ManagePracticesScreen: Editing practice:', practiceId);
        
        // Find the practice in the list
        const practice = this.practices.find(p => p.id === practiceId);
        if (!practice) {
            console.error('Practice not found:', practiceId);
            return;
        }
        
        // Set editing mode
        this.editingPracticeId = practiceId;
        
        // Parse datetime
        const datetime = new Date(practice.date);
        const dateStr = datetime.toISOString().split('T')[0]; // YYYY-MM-DD
        const hours = datetime.getHours().toString().padStart(2, '0');
        const minutes = datetime.getMinutes().toString().padStart(2, '0');
        const timeStr = `${hours}:${minutes}`; // HH:MM
        
        // Calculate end time from duration
        const endDateTime = new Date(datetime.getTime() + (practice.duration * 60000));
        const endHours = endDateTime.getHours().toString().padStart(2, '0');
        const endMinutes = endDateTime.getMinutes().toString().padStart(2, '0');
        const endTimeStr = `${endHours}:${endMinutes}`;
        
        // Populate form
        const form = this.element.querySelector('#practiceForm');
        if (form) {
            form.querySelector('#practiceDate').value = dateStr;
            form.querySelector('#startTime').value = timeStr;
            form.querySelector('#endTime').value = endTimeStr;
            form.querySelector('#notes').value = practice.notes || '';
            
            // Update button text
            const saveBtn = form.querySelector('#saveBtn');
            if (saveBtn) {
                saveBtn.textContent = 'Update Practice';
                saveBtn.style.background = '#f59e0b'; // Orange for update
            }
        }
        
        // Highlight the practice being edited
        this.updatePracticesList();
        
        // Scroll form into view
        form?.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
    
    async deletePractice(practiceId) {
        console.log('📱 ManagePracticesScreen: Deleting practice:', practiceId);
        
        // Confirm deletion
        if (!confirm('Are you sure you want to delete this practice?')) {
            return;
        }
        
        try {
            const result = await this.authService.request(`/api/events/${practiceId}`, {
                method: 'DELETE'
            });
            
            if (result.success) {
                console.log('📱 ManagePracticesScreen: Practice deleted successfully');
                
                // Remove from local list
                this.practices = this.practices.filter(p => p.id !== practiceId);
                
                // Update UI
                this.updatePracticesList();
                
                // Show success message
                const successMsg = document.createElement('div');
                successMsg.style.cssText = 'position: fixed; top: 20px; right: 20px; background: #10b981; color: white; padding: 1rem 1.5rem; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); z-index: 1000; font-weight: 500;';
                successMsg.textContent = '✓ Practice deleted successfully!';
                document.body.appendChild(successMsg);
                
                setTimeout(() => successMsg.remove(), 3000);
            } else {
                alert('Error deleting practice: ' + result.message);
            }
            
        } catch (error) {
            console.error('📱 ManagePracticesScreen: Error deleting practice:', error);
            alert('Error deleting practice: ' + error.message);
        }
    }
    
    render() {
        console.log('📱 ManagePracticesScreen: Rendering');
        
        const html = `
            <div class="screen add-practice-screen" style="background: white; min-height: 100vh;">
                <header class="screen-header" style="background: #f3f4f6; padding: 1rem; border-bottom: 2px solid #ccc;">
                    <button id="backBtn" class="back-button" style="padding: 0.5rem 1rem; cursor: pointer;">
                        <span class="icon">←</span> Back
                    </button>
                    <h1 style="display: inline-block; margin-left: 1rem;">Manage Practices</h1>
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
        
        console.log('📱 ManagePracticesScreen: HTML length:', html.length);
        console.log('📱 ManagePracticesScreen: HTML preview:', html.substring(0, 200));
        
        return html;
    }
    
    setupForm() {
        console.log('📱 ManagePracticesScreen: Setting up form');
        
        // Only set up event listeners once
        if (this.formSetup) {
            console.log('📱 ManagePracticesScreen: Form already set up, skipping');
            return;
        }
        
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
                console.log('📱 ManagePracticesScreen: Form submitted');
                this.send('SAVE');
            });
        }
        
        // Cancel button
        if (cancelBtn) {
            cancelBtn.addEventListener('click', () => {
                console.log('📱 ManagePracticesScreen: Cancel clicked');
                this.send('CANCEL');
            });
        }
        
        // Back button
        if (backBtn) {
            backBtn.addEventListener('click', () => {
                console.log('📱 ManagePracticesScreen: Back clicked, current state:', this.stateMachine?.currentState);
                // Only allow navigation if we're not already navigating
                if (this.stateMachine?.currentState !== 'navigating') {
                    this.send('CANCEL');
                }
            });
        }
        
        // Mark form as set up to prevent duplicate listeners
        this.formSetup = true;
        console.log('📱 ManagePracticesScreen: Form setup complete');
    }
    
    async savePractice() {
        console.log('📱 ManagePracticesScreen: Saving practice...');
        
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
            
            console.log('📱 ManagePracticesScreen: Practice data:', practiceData);
            
            // Determine if we're creating or updating
            const isUpdate = this.editingPracticeId !== null;
            const url = isUpdate ? `/api/events/${this.editingPracticeId}` : '/api/events';
            const method = isUpdate ? 'PUT' : 'POST';
            
            // Call API to save practice
            const result = await this.authService.request(url, {
                method: method,
                body: JSON.stringify(practiceData)
            });
            
            if (result.success) {
                console.log('📱 ManagePracticesScreen: Practice saved successfully');
                
                // Clear editing state
                this.editingPracticeId = null;
                
                // Clear the form
                if (form) {
                    form.reset();
                    
                    // Reset button text and color
                    const saveBtn = form.querySelector('#saveBtn');
                    if (saveBtn) {
                        saveBtn.textContent = 'Save Practice';
                        saveBtn.style.background = '#2563eb';
                    }
                }
                
                // Reload practices list to show the updated practice
                await this.loadPractices();
                
                // Show success message
                const successMsg = document.createElement('div');
                successMsg.style.cssText = 'position: fixed; top: 20px; right: 20px; background: #10b981; color: white; padding: 1rem 1.5rem; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); z-index: 1000; font-weight: 500;';
                successMsg.textContent = isUpdate ? '✓ Practice updated successfully!' : '✓ Practice created successfully!';
                document.body.appendChild(successMsg);
                
                setTimeout(() => successMsg.remove(), 3000);
                
                this.send('SUCCESS');
            } else {
                console.error('📱 ManagePracticesScreen: Failed to save practice:', result.message);
                alert('Error saving practice: ' + result.message);
                this.send('ERROR');
            }
            
        } catch (error) {
            console.error('📱 ManagePracticesScreen: Error saving practice:', error);
            alert('Error saving practice: ' + error.message);
            this.send('ERROR');
        }
    }
    
    navigateBack() {
        console.log('📱 ManagePracticesScreen: Navigating back to event type selection');
        
        setTimeout(() => {
            console.log('📱 ManagePracticesScreen: Calling navigateTo');
            this.navigateTo('eventTypeSelection', {
                user: this.user,
                teamContext: this.teamContext,
                roleType: this.roleType
            });
            console.log('📱 ManagePracticesScreen: navigateTo called');
        }, 100);
    }
    
    onExit() {
        console.log('📱 ManagePracticesScreen: Exiting');
    }
}
