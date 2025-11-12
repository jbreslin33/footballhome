/**
 * TeamCard Component
 * Displays team information and management options
 */
class TeamCard extends Component {
    constructor(container, teams = []) {
        super(container, { teams });
        this.teams = teams;
    }

    render() {
        return `
            <div class="card team-card">
                <h3 class="font-medium mb-2">
                    <span class="card-icon">⚽</span>
                    Teams
                </h3>
                <p class="text-sm text-gray-600 mb-3">
                    Manage your teams and rosters
                </p>
                
                <div class="team-list">
                    ${this.renderTeamList()}
                </div>
                
                <div class="card-actions mt-4">
                    <button class="btn btn-primary btn-sm" data-action="create-team">
                        + Add Team
                    </button>
                    <button class="btn btn-secondary btn-sm" data-action="view-all-teams">
                        View All
                    </button>
                </div>
            </div>
        `;
    }

    renderTeamList() {
        if (!this.teams || this.teams.length === 0) {
            return `
                <div class="empty-state">
                    <p class="text-sm text-gray-500">No teams yet</p>
                </div>
            `;
        }

        return this.teams.slice(0, 3).map(team => `
            <div class="team-item">
                <div class="team-info">
                    <span class="team-name">${team.name || 'Unknown Team'}</span>
                    <span class="team-members">${team.memberCount || 0} members</span>
                </div>
                <div class="team-status ${team.status || 'active'}">
                    ${team.status || 'active'}
                </div>
            </div>
        `).join('');
    }

    setupEventListeners() {
        // Create team button
        const createBtn = this.querySelector('[data-action="create-team"]');
        if (createBtn) {
            this.addEventListener(createBtn, 'click', this.handleCreateTeam);
        }

        // View all teams button
        const viewAllBtn = this.querySelector('[data-action="view-all-teams"]');
        if (viewAllBtn) {
            this.addEventListener(viewAllBtn, 'click', this.handleViewAllTeams);
        }

        // Team item clicks
        const teamItems = this.querySelectorAll('.team-item');
        teamItems.forEach(item => {
            this.addEventListener(item, 'click', (e) => {
                const teamName = item.querySelector('.team-name')?.textContent;
                this.handleTeamClick(teamName);
            });
        });
    }

    handleCreateTeam() {
        console.log('TeamCard: Create team clicked');
        this.emit('team:create');
    }

    handleViewAllTeams() {
        console.log('TeamCard: View all teams clicked');
        this.emit('team:viewAll');
    }

    handleTeamClick(teamName) {
        console.log('TeamCard: Team clicked:', teamName);
        this.emit('team:select', { teamName });
    }

    // Update teams data
    updateTeams(teams) {
        this.teams = teams;
        this.update();
    }
}