/**
 * TeamSelectionScreen - Select which team to manage (for coaches with multiple teams)
 * 
 * State machine flow:
 * loading -> ready -> selecting -> navigating
 */
class TeamSelectionScreen extends Screen {
    constructor(container, props = {}) {
        super(container, props, {
            screenName: 'teamSelection'
        });
        
        this.user = null;
        this.roleType = null;
        this.teams = [];
        this.selectedTeam = null;
        
        // Create state machine
        this.stateMachine = new StateMachine({
            initial: 'loading',
            states: {
                loading: {
                    on: { 
                        TEAMS_LOADED: 'ready',
                        ERROR: 'error'
                    },
                    onEntry: () => this.showLoading()
                },
                ready: {
                    on: { 
                        TEAM_SELECTED: 'selecting',
                        BACK: 'navigating'
                    },
                    onEntry: () => this.showTeamCards()
                },
                selecting: {
                    on: { 
                        NAVIGATE: 'navigating',
                        CANCEL: 'ready'
                    },
                    onEntry: (team) => this.handleTeamSelection(team)
                },
                navigating: {
                    onEntry: (navData) => this.navigate(navData)
                },
                error: {
                    on: { 
                        RETRY: 'loading',
                        BACK: 'navigating'
                    },
                    onEntry: (error) => this.showError(error)
                }
            }
        });
    }
    
    render() {
        return `
            <div class="team-selection-screen">
                <!-- Loading State -->
                <div id="loadingContainer" class="loading-container" style="display: none;">
                    <div class="min-h-screen flex items-center justify-center">
                        <div class="text-center">
                            <div class="loading-spinner"></div>
                            <p class="mt-4">Loading your teams...</p>
                        </div>
                    </div>
                </div>
                
                <!-- Team Selection -->
                <div id="teamCardsContainer" class="team-cards-container" style="display: none;">
                    <div class="team-selection-header">
                        <h2>Select a Team</h2>
                        <p>Choose which team you want to manage</p>
                    </div>
                    <div id="teamCards" class="team-cards-grid">
                        <!-- Team cards will be inserted here -->
                    </div>
                    <div class="team-selection-footer">
                        <button id="backBtn" class="btn btn-secondary">Back to Roles</button>
                    </div>
                </div>
                
                <!-- Error State -->
                <div id="errorContainer" class="error-container" style="display: none;">
                    <div class="min-h-screen flex items-center justify-center">
                        <div class="text-center">
                            <h2>Error</h2>
                            <p id="errorText" class="mt-4">Unable to load teams.</p>
                            <div class="mt-6">
                                <button id="retryBtn" class="btn btn-primary mr-4">Try Again</button>
                                <button id="backToRolesBtn" class="btn btn-secondary">Back to Roles</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }
    
    async onEnter(data = null) {
        await super.onEnter(data);
        
        this.user = data?.user || this.user;
        this.roleType = data?.roleType || 'coach';
        this.teams = data?.teams || [];
        
        if (!this.user) {
            console.error('📱 TeamSelectionScreen: No user data provided');
            this.send('ERROR', { message: 'No user data available' });
            return;
        }
        
        if (this.teams.length === 0) {
            console.error('📱 TeamSelectionScreen: No teams provided');
            this.send('ERROR', { message: 'No teams available' });
            return;
        }
        
        console.log('📱 TeamSelectionScreen: Loading teams:', this.teams);
        this.send('TEAMS_LOADED');
    }
    
    showLoading() {
        this.showContainer('loadingContainer');
    }
    
    showTeamCards() {
        this.showContainer('teamCardsContainer');
        this.renderTeamCards();
        this.setupEvents();
    }
    
    renderTeamCards() {
        const teamCardsContainer = this.element.querySelector('#teamCards');
        if (!teamCardsContainer) return;
        
        const cardsHTML = this.teams.map(team => this.renderTeamCard(team)).join('');
        teamCardsContainer.innerHTML = cardsHTML;
    }
    
    renderTeamCard(team) {
        return `
            <div class="team-card" data-team-id="${team.teamId}">
                <div class="team-card-icon">🏈</div>
                <h3>${team.teamName}</h3>
                <p class="team-club">${team.clubName || ''}</p>
                ${team.coachRole ? `<p class="team-role">${team.coachRole}</p>` : ''}
                ${team.isPrimary ? '<span class="team-badge">Primary</span>' : ''}
                <button class="btn btn-primary">Select Team</button>
            </div>
        `;
    }
    
    setupEvents() {
        // Team card selection
        const teamCards = this.element.querySelectorAll('.team-card button');
        teamCards.forEach(button => {
            button.addEventListener('click', (e) => {
                const card = e.target.closest('.team-card');
                const teamId = card?.getAttribute('data-team-id');
                
                if (teamId) {
                    const team = this.teams.find(t => t.teamId === teamId);
                    if (team) {
                        console.log('📱 TeamSelectionScreen: Team selected:', team);
                        this.send('TEAM_SELECTED', team);
                    }
                }
            });
        });
        
        // Back button
        const backBtn = this.element.querySelector('#backBtn');
        if (backBtn) {
            backBtn.addEventListener('click', () => {
                console.log('📱 TeamSelectionScreen: Back button clicked');
                this.send('BACK', { target: 'roleSwitchboard' });
            });
        }
        
        // Error state buttons
        const retryBtn = this.element.querySelector('#retryBtn');
        const backToRolesBtn = this.element.querySelector('#backToRolesBtn');
        
        if (retryBtn) {
            retryBtn.addEventListener('click', () => this.send('RETRY'));
        }
        
        if (backToRolesBtn) {
            backToRolesBtn.addEventListener('click', () => {
                this.send('BACK', { target: 'roleSwitchboard' });
            });
        }
    }
    
    handleTeamSelection(team) {
        this.selectedTeam = team;
        
        console.log('📱 TeamSelectionScreen: Navigating to dashboard with team:', team);
        
        // Navigate to dashboard with team context
        this.send('NAVIGATE', {
            screen: 'dashboard',
            data: {
                user: this.user,
                roleType: this.roleType,
                roleSelection: {
                    roleType: this.roleType,
                    user: this.user,
                    roleData: {
                        teamId: team.teamId,
                        teamName: team.teamName,
                        clubName: team.clubName,
                        coachRole: team.coachRole,
                        isPrimary: team.isPrimary
                    }
                },
                teamContext: {
                    id: team.teamId,
                    name: team.teamName,
                    club: team.clubName
                }
            }
        });
    }
    
    navigate(navData) {
        if (navData.screen) {
            setTimeout(() => {
                this.navigateTo(navData.screen, navData.data);
            }, 100);
        } else if (navData.target === 'roleSwitchboard') {
            setTimeout(() => {
                this.navigateTo('roleSwitchboard', { user: this.user });
            }, 100);
        }
    }
    
    showError(error) {
        this.showContainer('errorContainer');
        
        const errorText = this.element.querySelector('#errorText');
        if (errorText) {
            errorText.textContent = error.message || 'An error occurred';
        }
    }
    
    showContainer(containerId) {
        ['loadingContainer', 'teamCardsContainer', 'errorContainer'].forEach(id => {
            const container = this.element.querySelector(`#${id}`);
            if (container) {
                container.style.display = id === containerId ? 'block' : 'none';
            }
        });
    }
    
    async onExit() {
        console.log('📱 TeamSelectionScreen: Exiting');
        this.teams = [];
        this.selectedTeam = null;
        await super.onExit();
    }
}
