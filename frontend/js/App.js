/**
 * Main Application
 * Initializes and manages the vanilla JS Football Home app
 */
class App {
    constructor() {
        this.container = document.getElementById('app');
        this.authService = new AuthService();
        this.currentComponent = null;
        
        console.log('🏈 Football Home Vanilla JS App initialized');
        
        this.init();
    }
    
    async init() {
        // Check if user is already logged in
        if (this.authService.isAuthenticated()) {
            const userResult = await this.authService.getCurrentUser();
            
            if (userResult.success) {
                console.log('User already authenticated:', userResult.user);
                this.showRoleSwitchboard(userResult.user);
                return;
            }
        }
        
        // Show login form
        this.showLogin();
    }
    
    showLogin() {
        console.log('Showing login form...');
        
        // Clear container
        this.container.innerHTML = '';
        
        // Add page wrapper with centering
        const pageWrapper = document.createElement('div');
        pageWrapper.className = 'min-h-screen flex items-center justify-center';
        this.container.appendChild(pageWrapper);
        
        // Create login component
        this.currentComponent = new LoginForm(pageWrapper);
        
        // Listen for successful login
        this.currentComponent.on('loginSuccess', (event) => {
            console.log('App received login success:', event.detail);
            console.log('User object:', event.detail?.user);
            console.log('Full result keys:', Object.keys(event.detail || {}));
            
            if (event.detail && event.detail.user) {
                this.showRoleSwitchboard(event.detail.user);
            } else {
                console.error('No user data received in login success event');
            }
        });
    }
    
    showRoleSwitchboard(user) {
        console.log('App: showRoleSwitchboard called with user:', user);
        
        const appContainer = document.getElementById('app');
        appContainer.innerHTML = ''; // Clear container
        
        try {
            // Create and mount the RoleSwitchboard component
            console.log('App: Creating RoleSwitchboard component...');
            this.currentComponent = new RoleSwitchboard(appContainer, user);
            this.currentComponent.mount();
            console.log('App: RoleSwitchboard mounted successfully');
            
            // Listen for role selection events
            if (this.currentComponent.element) {
                this.currentComponent.element.addEventListener('role:selected', (event) => {
                    console.log('App: Role selected:', event.detail);
                    this.handleRoleSelection(event.detail);
                });
                
                this.currentComponent.element.addEventListener('user:logout', () => {
                    console.log('App: Logout event received');
                    this.logout();
                });
                
                console.log('App: RoleSwitchboard event listeners added');
            }
            
        } catch (error) {
            console.error('App: Error setting up role switchboard:', error);
            
            // Fallback: show error message
            appContainer.innerHTML = `
                <div style="padding: 2rem; text-align: center;">
                    <h2>Role Switchboard Loading Error</h2>
                    <p>There was an error loading the role selection. Check the console for details.</p>
                    <p>Error: ${error.message}</p>
                    <button onclick="location.reload()">Reload Page</button>
                </div>
            `;
        }
    }
    
    handleRoleSelection(roleSelection) {
        console.log('App: Handling role selection:', roleSelection);
        
        if (roleSelection.navigateTo === 'teamSelection') {
            // Show team selection (multiple teams for one role)
            this.showTeamSelection(roleSelection);
        } else if (roleSelection.navigateTo === 'dashboard') {
            // Go directly to role dashboard (single team)
            this.showRoleDashboard(roleSelection);
        }
    }
    
    showTeamSelection(roleSelection) {
        console.log('App: Showing team selection for:', roleSelection);
        
        // For now, just show a simple team selection
        // Later we'll create a proper TeamSelection component
        const appContainer = document.getElementById('app');
        appContainer.innerHTML = `
            <div class="role-switchboard">
                <nav class="navbar">
                    <div class="navbar-brand">
                        <span class="brand-text">Football Home</span>
                    </div>
                    <div class="navbar-menu">
                        <button onclick="location.reload()" class="btn btn-secondary btn-sm">← Back to Roles</button>
                    </div>
                </nav>
                <main class="switchboard-main">
                    <div class="switchboard-header">
                        <h2 class="switchboard-title">Select Team - ${roleSelection.roleType.charAt(0).toUpperCase() + roleSelection.roleType.slice(1)} Role</h2>
                        <p class="switchboard-subtitle">Choose the team you want to manage</p>
                    </div>
                    <div class="roles-grid">
                        ${roleSelection.roles.map(role => `
                            <div class="role-card" onclick="window.showRoleDashboardForRole(${JSON.stringify(role).replace(/"/g, '&quot;')})">
                                <div class="role-card-icon">🏟️</div>
                                <div class="role-card-content">
                                    <h3 class="role-card-title">${role.teamName}</h3>
                                    <p class="role-card-description">${role.clubName}</p>
                                    <div class="role-card-stats">
                                        ${roleSelection.roleType === 'player' && role.jerseyNumber ? `Jersey #${role.jerseyNumber}` : ''}
                                        ${roleSelection.roleType === 'coach' ? role.coachRole?.replace('_', ' ') || 'Coach' : ''}
                                    </div>
                                </div>
                                <div class="role-card-action">→</div>
                            </div>
                        `).join('')}
                    </div>
                </main>
            </div>
        `;
        
        // Add global function for team selection
        window.showRoleDashboardForRole = (role) => {
            this.showRoleDashboard({ roleType: roleSelection.roleType, roleData: role });
        };
    }
    
    showRoleDashboard(roleSelection) {
        console.log('App: Showing role dashboard for:', roleSelection);
        
        // For now, show a simple dashboard with "View Roster" card
        // Later we'll create proper role-specific dashboard components
        const role = roleSelection.roleData;
        const appContainer = document.getElementById('app');
        appContainer.innerHTML = `
            <div class="role-switchboard">
                <nav class="navbar">
                    <div class="navbar-brand">
                        <span class="brand-text">Football Home</span>
                    </div>
                    <div class="navbar-menu">
                        <button onclick="location.reload()" class="btn btn-secondary btn-sm">← Back to Roles</button>
                    </div>
                </nav>
                <main class="switchboard-main">
                    <div class="switchboard-header">
                        <h2 class="switchboard-title">${role.teamName} - ${roleSelection.roleType.charAt(0).toUpperCase() + roleSelection.roleType.slice(1)} Dashboard</h2>
                        <p class="switchboard-subtitle">Manage your ${roleSelection.roleType} responsibilities</p>
                    </div>
                    <div class="roles-grid">
                        <div class="role-card" onclick="window.showRoster('${role.teamId}', '${roleSelection.roleType}')">
                            <div class="role-card-icon">📋</div>
                            <div class="role-card-content">
                                <h3 class="role-card-title">View Roster</h3>
                                <p class="role-card-description">See team players and their information</p>
                                <div class="role-card-stats">Team Management</div>
                            </div>
                            <div class="role-card-action">→</div>
                        </div>
                    </div>
                </main>
            </div>
        `;
        
        // Add global function for roster viewing
        window.showRoster = (teamId, roleType) => {
            this.showRoster(teamId, roleType);
        };
    }
    
    async showRoster(teamId, roleType) {
        console.log('App: Showing roster for team:', teamId, 'role:', roleType);
        
        const appContainer = document.getElementById('app');
        
        try {
            // Fetch roster data from API
            const response = await fetch(`/api/teams/${teamId}/roster`);
            let rosterData = [];
            
            if (response.ok) {
                const result = await response.json();
                rosterData = result.data || [];
            } else {
                console.warn('Could not fetch roster data, using placeholder');
            }
            
            // Show roster view
            appContainer.innerHTML = `
                <div class="role-switchboard">
                    <nav class="navbar">
                        <div class="navbar-brand">
                            <span class="brand-text">Football Home</span>
                        </div>
                        <div class="navbar-menu">
                            <button onclick="location.reload()" class="btn btn-secondary btn-sm">← Back to Dashboard</button>
                        </div>
                    </nav>
                    <main class="switchboard-main">
                        <div class="switchboard-header">
                            <h2 class="switchboard-title">Team Roster - ${roleType.charAt(0).toUpperCase() + roleType.slice(1)} View</h2>
                            <p class="switchboard-subtitle">Team members and their information</p>
                        </div>
                        <div class="roster-container">
                            ${rosterData.length > 0 
                                ? rosterData.map(player => `
                                    <div class="roster-card">
                                        <div class="player-info">
                                            <h4>${player.name}</h4>
                                            <p>${player.position || 'Position not assigned'}</p>
                                            ${player.jerseyNumber ? `<span class="jersey-number">#${player.jerseyNumber}</span>` : ''}
                                        </div>
                                    </div>
                                `).join('')
                                : '<p>Roster data will be loaded from the database. This is a placeholder for the roster functionality.</p>'
                            }
                        </div>
                    </main>
                </div>
            `;
            
        } catch (error) {
            console.error('Error loading roster:', error);
            appContainer.innerHTML = `
                <div style="padding: 2rem; text-align: center;">
                    <h2>Error Loading Roster</h2>
                    <p>Could not load roster data: ${error.message}</p>
                    <button onclick="location.reload()">Back to Roles</button>
                </div>
            `;
        }
    }
    
    logout() {
        console.log('Logging out...');
        
        // Clean up current component if it exists
        if (this.currentComponent) {
            if (this.currentComponent.cleanup) {
                this.currentComponent.cleanup();
            }
            this.currentComponent = null;
        }
        
        this.authService.logout();
        this.showLogin();
    }
}

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new App();
});