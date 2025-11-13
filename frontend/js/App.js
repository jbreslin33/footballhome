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
    
    // TODO: Implement proper TeamSelection component
    showTeamSelection(roleSelection) {
        console.log('App: Team selection requested but not implemented yet:', roleSelection);
        console.log('App: Staying on RoleSwitchboard for now...');
        // For now, do nothing - stay on the RoleSwitchboard
    }
    
    // TODO: Implement proper role-specific dashboard components
    showRoleDashboard(roleSelection) {
        console.log('App: Role dashboard requested but not implemented yet:', roleSelection);
        console.log('App: Staying on RoleSwitchboard for now...');
        // For now, do nothing - stay on the RoleSwitchboard
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