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
        
        return `
            <div class="coach-dashboard-content">
                <!-- Dashboard Header -->
                <div class="dashboard-header">
                    <h2>Coach Dashboard</h2>
                    <p class="text-muted">Managing: ${teamName}</p>
                </div>
                
                <!-- Main Action -->
                <div class="main-action-container">
                    <button id="eventsBtn" class="btn btn-primary btn-xl">
                        <span class="icon">📅</span>
                        <span class="btn-text">Events</span>
                    </button>
                    <p class="action-description">Manage practices, games, and meetings</p>
                </div>
            </div>
        `;
    }
    
    /**
     * Setup coach-specific action handlers
     */
    setupActions() {
        // Events button
        const eventsBtn = this.element.querySelector('#eventsBtn');
        if (eventsBtn) {
            eventsBtn.addEventListener('click', () => {
                console.log('📊 CoachDashboard: Events button clicked');
                this.handleEventsClick();
            });
        }
    }
    
    /**
     * Handle Events button click
     */
    handleEventsClick() {
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
}
