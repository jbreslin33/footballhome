/**
 * Simple Dashboard Test Component
 * Minimal version to test basic functionality
 */
class SimpleDashboard extends Component {
    constructor(container, user = {}) {
        console.log('SimpleDashboard: Constructor called');
        console.log('SimpleDashboard: user parameter:', user);
        console.log('SimpleDashboard: user type:', typeof user);
        
        super(container, { user });
        this.user = user || {};
        
        console.log('SimpleDashboard: this.user after assignment:', this.user);
    }

    render() {
        console.log('SimpleDashboard: render() called');
        console.log('SimpleDashboard: this.user is:', this.user);
        console.log('SimpleDashboard: typeof this.user:', typeof this.user);
        
        // Safe access to user properties
        const userName = this.user && this.user.name ? this.user.name : 'User';
        const userEmail = this.user && this.user.email ? this.user.email : 'Unknown';
        
        return `
            <div class="simple-dashboard">
                <nav class="navbar">
                    <div class="navbar-brand">
                        <span class="brand-text">Football Home - Simple Test</span>
                    </div>
                    <div class="navbar-menu">
                        <span class="navbar-user">Welcome, ${userName}</span>
                        <button id="logoutBtn" class="btn btn-secondary btn-sm">Logout</button>
                    </div>
                </nav>
                
                <main class="dashboard-main">
                    <div class="dashboard-header">
                        <h2 class="dashboard-title">Simple Dashboard Test</h2>
                        <p class="dashboard-subtitle">
                            This is a simplified dashboard to test component loading.
                        </p>
                    </div>
                    
                    <div class="test-cards">
                        <div class="card">
                            <h3>✅ Dashboard Component Loaded</h3>
                            <p>The Dashboard component is working correctly.</p>
                            <p><strong>User:</strong> ${userName}</p>
                            <p><strong>Email:</strong> ${userEmail}</p>
                        </div>
                        
                        <div class="card">
                            <h3>🎯 Next Steps</h3>
                            <p>If you see this, the component system is working.</p>
                            <ul>
                                <li>✅ Component inheritance working</li>
                                <li>✅ Template rendering working</li>
                                <li>✅ Props passing working</li>
                            </ul>
                        </div>
                    </div>
                </main>
            </div>
        `;
    }

    setupEventListeners() {
        console.log('SimpleDashboard: setupEventListeners called');
        
        // Setup logout functionality
        const logoutBtn = this.querySelector('#logoutBtn');
        if (logoutBtn) {
            this.addEventListener(logoutBtn, 'click', this.handleLogout);
            console.log('SimpleDashboard: Logout button listener added');
        } else {
            console.warn('SimpleDashboard: Logout button not found');
        }
    }

    handleLogout() {
        console.log('SimpleDashboard: Logout clicked');
        this.emit('user:logout');
    }

    onMounted() {
        console.log('SimpleDashboard: onMounted called');
        console.log('SimpleDashboard: Component successfully mounted!');
    }
}