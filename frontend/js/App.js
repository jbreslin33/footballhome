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
                this.showDashboard(userResult.user);
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
                this.showDashboard(event.detail.user);
            } else {
                console.error('No user data received in login success event');
            }
        });
    }
    
    showDashboard(user) {
        console.log('App: showDashboard called with user:', user);
        console.log('App: user type:', typeof user);
        console.log('App: user keys:', user ? Object.keys(user) : 'user is falsy');
        
        const appContainer = document.getElementById('app');
        console.log('App: appContainer found:', appContainer);
        
        try {
            // Create and mount the Dashboard component
            console.log('App: Creating Dashboard component...');
            this.dashboard = new Dashboard(appContainer, user);
            console.log('App: Dashboard created, now mounting...');
            
            this.dashboard.mount();
            console.log('App: Dashboard mounted successfully');
            
            // Listen for logout events from the dashboard element
            if (this.dashboard.element) {
                this.dashboard.element.addEventListener('user:logout', () => {
                    console.log('App: Logout event received');
                    this.logout();
                });
                console.log('App: Logout event listener added');
            } else {
                console.error('App: Dashboard element not found!');
            }
            
            console.log('App: Dashboard component setup complete');
        } catch (error) {
            console.error('App: Error setting up dashboard:', error);
            console.error('App: Error stack:', error.stack);
            
            // Fallback: show a simple message
            appContainer.innerHTML = `
                <div style="padding: 2rem; text-align: center;">
                    <h2>Dashboard Loading Error</h2>
                    <p>There was an error loading the dashboard. Check the console for details.</p>
                    <p>Error: ${error.message}</p>
                    <button onclick="location.reload()">Reload Page</button>
                </div>
            `;
        }
    }
    
    logout() {
        console.log('Logging out...');
        
        // Clean up dashboard component if it exists
        if (this.dashboard) {
            this.dashboard.cleanup();
            this.dashboard = null;
        }
        
        this.authService.logout();
        this.showLogin();
    }
}

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new App();
});