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
            // Create the RoleSwitchboard component (auto-mounts via base class)
            console.log('App: Creating RoleSwitchboard component...');
            this.currentComponent = new RoleSwitchboard(appContainer, user);
            console.log('App: RoleSwitchboard created and mounted successfully');
            
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
    
    // TODO: Implement proper TeamSelection component
    showTeamSelection(roleSelection) {
        console.log('App: Team selection requested but not implemented yet:', roleSelection);
        console.log('App: Staying on RoleSwitchboard for now...');
        // For now, do nothing - stay on the RoleSwitchboard
    }
    
    showRoleDashboard(roleSelection) {
        console.log('App: Showing role dashboard for:', roleSelection);
        
        const appContainer = document.getElementById('app');
        appContainer.innerHTML = ''; // Clear container
        
        // Create a basic dashboard based on role type
        if (roleSelection.roleType === 'admin') {
            this.showAdminDashboard(roleSelection);
        } else {
            // Fallback for other roles
            appContainer.innerHTML = `
                <div class="dashboard">
                    <nav class="navbar">
                        <div class="navbar-brand">
                            <span class="brand-text">Football Home - ${roleSelection.roleType}</span>
                        </div>
                        <div class="navbar-menu">
                            <button id="backBtn" class="btn btn-secondary btn-sm">Back to Roles</button>
                            <button id="logoutBtn" class="btn btn-secondary btn-sm">Logout</button>
                        </div>
                    </nav>
                    <main class="dashboard-main">
                        <h2>${roleSelection.roleType.charAt(0).toUpperCase() + roleSelection.roleType.slice(1)} Dashboard</h2>
                        <p>Dashboard for ${roleSelection.roleData?.teamName || 'your team'}</p>
                        <p>This dashboard is under development.</p>
                    </main>
                </div>
            `;
            
            // Setup navigation
            this.setupDashboardNavigation();
        }
    }
    
    showAdminDashboard(roleSelection) {
        console.log('App: Showing admin dashboard');
        
        const appContainer = document.getElementById('app');
        appContainer.innerHTML = `
            <div class="admin-dashboard">
                <nav class="navbar">
                    <div class="navbar-brand">
                        <span class="brand-text">Football Home - Administrator</span>
                    </div>
                    <div class="navbar-menu">
                        <button id="backBtn" class="btn btn-secondary btn-sm">Back to Roles</button>
                        <button id="logoutBtn" class="btn btn-secondary btn-sm">Logout</button>
                    </div>
                </nav>
                <main class="admin-main">
                    <div class="admin-header">
                        <h2>System Administration</h2>
                        <p>Manage the Football Home system</p>
                    </div>
                    
                    <div class="admin-grid">
                        <div class="admin-card">
                            <div class="admin-card-icon">👥</div>
                            <h3>User Management</h3>
                            <p>Manage users, roles, and permissions</p>
                            <button class="btn btn-primary" disabled>Coming Soon</button>
                        </div>
                        
                        <div class="admin-card">
                            <div class="admin-card-icon">🏈</div>
                            <h3>Team Management</h3>
                            <p>Manage teams, players, and coaches</p>
                            <button class="btn btn-primary" disabled>Coming Soon</button>
                        </div>
                        
                        <div class="admin-card">
                            <div class="admin-card-icon">🏆</div>
                            <h3>League Management</h3>
                            <p>Manage leagues, divisions, and seasons</p>
                            <button class="btn btn-primary" disabled>Coming Soon</button>
                        </div>
                        
                        <div class="admin-card">
                            <div class="admin-card-icon">📊</div>
                            <h3>System Stats</h3>
                            <p>View system statistics and reports</p>
                            <button class="btn btn-primary" disabled>Coming Soon</button>
                        </div>
                    </div>
                </main>
            </div>
        `;
        
        // Setup navigation
        this.setupDashboardNavigation();
    }
    
    setupDashboardNavigation() {
        const backBtn = document.getElementById('backBtn');
        const logoutBtn = document.getElementById('logoutBtn');
        
        if (backBtn) {
            backBtn.addEventListener('click', async () => {
                // Go back to role switchboard
                const userResult = await this.authService.getCurrentUser();
                if (userResult.success) {
                    this.showRoleSwitchboard(userResult.user);
                } else {
                    this.showLogin();
                }
            });
        }
        
        if (logoutBtn) {
            logoutBtn.addEventListener('click', () => {
                this.logout();
            });
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