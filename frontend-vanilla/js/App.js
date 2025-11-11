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
            this.showDashboard(event.detail.user);
        });
    }
    
    showDashboard(user) {
        console.log('Showing dashboard for user:', user);
        
        // Clear container
        this.container.innerHTML = '';
        
        // Simple dashboard for now
        this.container.innerHTML = `
            <div class="min-h-screen">
                <nav class="bg-white shadow-sm border-b">
                    <div class="container">
                        <div class="flex items-center justify-between py-4">
                            <div class="flex items-center">
                                <h1 class="text-lg font-bold">Football Home</h1>
                            </div>
                            <div class="flex items-center space-x-4">
                                <span class="text-sm text-gray-600">Welcome, ${user.firstName || user.email}!</span>
                                <button id="logoutBtn" class="btn btn-secondary">Logout</button>
                            </div>
                        </div>
                    </div>
                </nav>
                
                <main class="container py-8">
                    <div class="card">
                        <h2 class="text-2xl font-bold mb-4">Dashboard</h2>
                        <p class="text-gray-600 mb-4">
                            Welcome to your Football Home dashboard! This is the vanilla JS version of the app.
                        </p>
                        
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div class="card">
                                <h3 class="font-medium mb-2">Teams</h3>
                                <p class="text-sm text-gray-600">Manage your teams</p>
                            </div>
                            
                            <div class="card">
                                <h3 class="font-medium mb-2">Events</h3>
                                <p class="text-sm text-gray-600">Upcoming matches and events</p>
                            </div>
                            
                            <div class="card">
                                <h3 class="font-medium mb-2">League Games</h3>
                                <p class="text-sm text-gray-600">External league data</p>
                            </div>
                        </div>
                        
                        <div class="mt-6 p-4 bg-gray-50 rounded">
                            <h4 class="font-medium mb-2">🎯 Vanilla JS Features Demonstrated:</h4>
                            <ul class="text-sm text-gray-600 space-y-1">
                                <li>✅ Finite State Machine for login flow</li>
                                <li>✅ Class inheritance for reusable components</li>
                                <li>✅ Custom CSS without frameworks</li>
                                <li>✅ Event-driven architecture</li>
                                <li>✅ API integration with existing backend</li>
                            </ul>
                        </div>
                    </div>
                </main>
            </div>
        `;
        
        // Add grid CSS since we don't have it in our basic styles
        const style = document.createElement('style');
        style.textContent = `
            .grid { display: grid; }
            .grid-cols-1 { grid-template-columns: repeat(1, minmax(0, 1fr)); }
            .gap-4 > * { margin-bottom: var(--space-4); }
            .space-x-4 > * + * { margin-left: var(--space-4); }
            .space-y-1 > * + * { margin-top: var(--space-1); }
            .bg-gray-50 { background-color: var(--gray-50); }
            .rounded { border-radius: var(--radius); }
            
            @media (min-width: 768px) {
                .md\\:grid-cols-3 { grid-template-columns: repeat(3, minmax(0, 1fr)); }
                .gap-4 { gap: var(--space-4); }
                .gap-4 > * { margin-bottom: 0; }
            }
        `;
        document.head.appendChild(style);
        
        // Setup logout
        const logoutBtn = document.getElementById('logoutBtn');
        if (logoutBtn) {
            logoutBtn.addEventListener('click', () => {
                this.logout();
            });
        }
    }
    
    logout() {
        console.log('Logging out...');
        
        this.authService.logout();
        this.showLogin();
    }
}

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new App();
});