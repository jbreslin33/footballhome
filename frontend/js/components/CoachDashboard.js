/**
 * CoachDashboard - Dashboard for coaches
 * 
 * Shows:
 * - Team context (which team the coach is managing)
 * - Quick actions (Add Event button)
 * - Upcoming practices for the team
 * - Team roster summary
 * - Recent activity
 */
class CoachDashboard extends Dashboard {
    constructor(container, props = {}) {
        super(container, {
            ...props,
            roleType: 'coach'
        });
        
        this.practices = [];
        this.teamStats = null;
    }
    
    /**
     * Fetch data for coach dashboard
     */
    async getData() {
        if (!this.teamContext || !this.teamContext.id) {
            throw new Error('No team context provided');
        }
        
        try {
            // TODO: Replace with actual API calls
            // For now, return empty data structure
            return {
                practices: [],
                teamStats: {
                    playerCount: 0,
                    upcomingEvents: 0,
                    completedPractices: 0
                },
                recentActivity: []
            };
            
            // Future implementation:
            // const response = await fetch(`/api/events/practices/${this.teamContext.id}`, {
            //     headers: {
            //         'Authorization': `Bearer ${localStorage.getItem('token')}`
            //     }
            // });
            // const result = await response.json();
            // return result.data;
            
        } catch (error) {
            console.error('📊 CoachDashboard: Error fetching data:', error);
            throw error;
        }
    }
    
    /**
     * Render coach dashboard content
     */
    renderContent() {
        if (!this.data) {
            return '<div class="loading">Loading dashboard...</div>';
        }
        
        const teamName = this.teamContext?.name || 'Your Team';
        const practices = this.data.practices || [];
        const stats = this.data.teamStats || {};
        
        return `
            <div class="coach-dashboard-content">
                <!-- Dashboard Header -->
                <div class="dashboard-header">
                    <h2>Coach Dashboard</h2>
                    <p class="text-muted">Managing: ${teamName}</p>
                </div>
                
                <!-- Quick Actions -->
                <div class="quick-actions">
                    <button id="addEventBtn" class="btn btn-primary btn-lg">
                        <span class="icon">➕</span>
                        Add Event
                    </button>
                </div>
                
                <!-- Stats Overview -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon">👥</div>
                        <div class="stat-value">${stats.playerCount || 0}</div>
                        <div class="stat-label">Players</div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-icon">📅</div>
                        <div class="stat-value">${stats.upcomingEvents || 0}</div>
                        <div class="stat-label">Upcoming Events</div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-icon">✅</div>
                        <div class="stat-value">${stats.completedPractices || 0}</div>
                        <div class="stat-label">Completed Practices</div>
                    </div>
                </div>
                
                <!-- Upcoming Practices -->
                <div class="practices-section">
                    <div class="section-header">
                        <h3>Upcoming Practices</h3>
                    </div>
                    
                    <div class="practices-list">
                        ${this.renderPracticesList(practices)}
                    </div>
                </div>
            </div>
        `;
    }
    
    /**
     * Render list of practices
     */
    renderPracticesList(practices) {
        if (!practices || practices.length === 0) {
            return `
                <div class="empty-state">
                    <p>No upcoming practices scheduled</p>
                    <button id="addFirstPracticeBtn" class="btn btn-primary mt-3">
                        Schedule Your First Practice
                    </button>
                </div>
            `;
        }
        
        return practices.map(practice => this.renderPracticeCard(practice)).join('');
    }
    
    /**
     * Render a single practice card
     */
    renderPracticeCard(practice) {
        const date = new Date(practice.event_date);
        const dateStr = date.toLocaleDateString('en-US', { 
            weekday: 'short', 
            month: 'short', 
            day: 'numeric' 
        });
        const timeStr = date.toLocaleTimeString('en-US', { 
            hour: 'numeric', 
            minute: '2-digit' 
        });
        
        return `
            <div class="practice-card" data-practice-id="${practice.id}">
                <div class="practice-date">
                    <div class="date-day">${dateStr}</div>
                    <div class="date-time">${timeStr}</div>
                </div>
                <div class="practice-info">
                    <h4>${practice.title || 'Team Practice'}</h4>
                    <p class="practice-location">${practice.venue?.name || 'Location TBD'}</p>
                    <p class="practice-duration">${practice.duration_minutes || 90} minutes</p>
                </div>
                <div class="practice-actions">
                    <button class="btn btn-sm btn-secondary" data-action="edit">Edit</button>
                    <button class="btn btn-sm btn-primary" data-action="view">View</button>
                </div>
            </div>
        `;
    }
    
    /**
     * Setup coach-specific action handlers
     */
    setupActions() {
        // Add Event button
        const addEventBtn = this.element.querySelector('#addEventBtn');
        if (addEventBtn) {
            addEventBtn.addEventListener('click', () => {
                console.log('📊 CoachDashboard: Add Event clicked');
                this.handleAddEvent();
            });
        }
        
        // Add First Practice button (if no practices exist)
        const addFirstPracticeBtn = this.element.querySelector('#addFirstPracticeBtn');
        if (addFirstPracticeBtn) {
            addFirstPracticeBtn.addEventListener('click', () => {
                console.log('📊 CoachDashboard: Add First Practice clicked');
                this.handleAddEvent();
            });
        }
        
        // Practice card actions
        const practiceActions = this.element.querySelectorAll('.practice-card button');
        practiceActions.forEach(button => {
            button.addEventListener('click', (e) => {
                const action = e.target.getAttribute('data-action');
                const card = e.target.closest('.practice-card');
                const practiceId = card?.getAttribute('data-practice-id');
                
                if (action && practiceId) {
                    console.log(`📊 CoachDashboard: Practice ${action} clicked for ${practiceId}`);
                    this.handlePracticeAction(action, practiceId);
                }
            });
        });
    }
    
    /**
     * Handle Add Event button click
     */
    handleAddEvent() {
        // Navigate to EventTypeSelection screen
        this.emit('navigate', {
            screen: 'eventTypeSelection',
            data: {
                user: this.user,
                teamContext: this.teamContext,
                roleType: this.roleType
            }
        });
    }
    
    /**
     * Handle practice card actions
     */
    handlePracticeAction(action, practiceId) {
        if (action === 'edit') {
            this.emit('navigate', {
                screen: 'editPractice',
                data: {
                    practiceId,
                    teamContext: this.teamContext
                }
            });
        } else if (action === 'view') {
            this.emit('navigate', {
                screen: 'viewPractice',
                data: {
                    practiceId,
                    teamContext: this.teamContext
                }
            });
        }
    }
}
