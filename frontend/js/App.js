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
        const appContainer = document.getElementById('app');
        
        // Create and mount the Dashboard component
        this.dashboard = new Dashboard(appContainer, user);
        this.dashboard.mount();
        
        // Listen for logout events from the dashboard
        this.dashboard.on('user:logout', () => {
            this.logout();
        });
        
        console.log('App: Dashboard component mounted with user:', user);
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