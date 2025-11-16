/**
 * Dashboard - Abstract base class for role-specific dashboards
 * 
 * Provides common dashboard functionality:
 * - Navigation bar with role context
 * - Back to roles / Logout buttons
 * - Common event handling
 * - Loading/Error states
 * 
 * Subclasses must implement:
 * - renderContent() - Returns HTML for dashboard main content
 * - getData() - Fetches data for the dashboard
 * - setupActions() - Sets up role-specific action handlers
 */
class Dashboard extends Component {
    constructor(container, props = {}) {
        super(container, props);
        
        this.user = props.user || null;
        this.roleType = props.roleType || 'unknown';
        this.roleData = props.roleData || {};
        this.teamContext = props.teamContext || null;
        
        this.isLoading = false;
        this.error = null;
        this.data = null;
    }
    
    /**
     * Render the complete dashboard structure
     * Subclasses should not override this - override renderContent() instead
     */
    render() {
        const brandText = this.getBrandText();
        const contextInfo = this.getContextInfo();
        
        return `
            <div class="dashboard ${this.roleType}-dashboard">
                <!-- Navigation Bar -->
                <nav class="navbar">
                    <div class="navbar-brand">
                        <span class="brand-text">${brandText}</span>
                    </div>
                    <div class="navbar-menu">
                        ${contextInfo ? `<span class="navbar-context">${contextInfo}</span>` : ''}
                        <button id="backToRolesBtn" class="btn btn-secondary btn-sm">Back to Roles</button>
                        <button id="logoutBtn" class="btn btn-secondary btn-sm">Logout</button>
                    </div>
                </nav>
                
                <!-- Main Content -->
                <main id="dashboardMain" class="dashboard-main">
                    ${this.renderContent()}
                </main>
                
                <!-- Loading Overlay -->
                <div id="loadingOverlay" class="loading-overlay" style="display: none;">
                    <div class="loading-spinner"></div>
                    <p class="mt-4">Loading...</p>
                </div>
                
                <!-- Error Overlay -->
                <div id="errorOverlay" class="error-overlay" style="display: none;">
                    <div class="error-content">
                        <h3>Error</h3>
                        <p id="errorMessage">An error occurred</p>
                        <button id="retryBtn" class="btn btn-primary">Try Again</button>
                    </div>
                </div>
            </div>
        `;
    }
    
    /**
     * Get brand text for navbar
     * Subclasses can override to customize
     */
    getBrandText() {
        const roleTitle = this.roleType.charAt(0).toUpperCase() + this.roleType.slice(1);
        return `Football Home - ${roleTitle}`;
    }
    
    /**
     * Get context info for navbar (e.g., team name, jersey number)
     * Subclasses can override to customize
     */
    getContextInfo() {
        if (this.teamContext) {
            return this.teamContext.name || 'Team';
        }
        return null;
    }
    
    /**
     * Render the main dashboard content
     * MUST be implemented by subclasses
     */
    renderContent() {
        throw new Error('Dashboard subclass must implement renderContent()');
    }
    
    /**
     * Fetch data for the dashboard
     * SHOULD be implemented by subclasses
     */
    async getData() {
        // Default implementation - subclasses should override
        return {};
    }
    
    /**
     * Setup role-specific action handlers
     * SHOULD be implemented by subclasses
     */
    setupActions() {
        // Default implementation - subclasses should override
    }
    
    /**
     * Mount the dashboard
     */
    async mount() {
        await super.mount();
        
        // Setup common event handlers
        this.setupCommonEvents();
        
        // Load data
        await this.loadData();
        
        // Setup role-specific actions
        this.setupActions();
    }
    
    /**
     * Setup common event handlers (back, logout, etc.)
     */
    setupCommonEvents() {
        const backBtn = this.element.querySelector('#backToRolesBtn');
        const logoutBtn = this.element.querySelector('#logoutBtn');
        const retryBtn = this.element.querySelector('#retryBtn');
        
        if (backBtn) {
            backBtn.addEventListener('click', () => {
                console.log(`📊 ${this.roleType}Dashboard: Back to roles clicked`);
                this.emit('navigate', { screen: 'roleSwitchboard', data: { user: this.user } });
            });
        }
        
        if (logoutBtn) {
            logoutBtn.addEventListener('click', () => {
                console.log(`📊 ${this.roleType}Dashboard: Logout clicked`);
                this.emit('logout');
            });
        }
        
        if (retryBtn) {
            retryBtn.addEventListener('click', () => {
                console.log(`📊 ${this.roleType}Dashboard: Retry clicked`);
                this.hideError();
                this.loadData();
            });
        }
    }
    
    /**
     * Load dashboard data
     */
    async loadData() {
        try {
            this.showLoading();
            
            this.data = await this.getData();
            
            this.hideLoading();
            this.updateContent();
            
        } catch (error) {
            console.error(`📊 ${this.roleType}Dashboard: Error loading data:`, error);
            this.hideLoading();
            this.showError(error.message || 'Failed to load dashboard data');
        }
    }
    
    /**
     * Update content after data is loaded
     * Subclasses can override to refresh UI with new data
     */
    updateContent() {
        // Re-render main content with new data
        const main = this.element.querySelector('#dashboardMain');
        if (main) {
            main.innerHTML = this.renderContent();
            this.setupActions(); // Re-setup actions for new content
        }
    }
    
    /**
     * Show loading state
     */
    showLoading() {
        this.isLoading = true;
        const overlay = this.element.querySelector('#loadingOverlay');
        if (overlay) {
            overlay.style.display = 'flex';
        }
    }
    
    /**
     * Hide loading state
     */
    hideLoading() {
        this.isLoading = false;
        const overlay = this.element.querySelector('#loadingOverlay');
        if (overlay) {
            overlay.style.display = 'none';
        }
    }
    
    /**
     * Show error state
     */
    showError(message) {
        this.error = message;
        const overlay = this.element.querySelector('#errorOverlay');
        const errorMsg = this.element.querySelector('#errorMessage');
        
        if (errorMsg) {
            errorMsg.textContent = message;
        }
        
        if (overlay) {
            overlay.style.display = 'flex';
        }
    }
    
    /**
     * Hide error state
     */
    hideError() {
        this.error = null;
        const overlay = this.element.querySelector('#errorOverlay');
        if (overlay) {
            overlay.style.display = 'none';
        }
    }
    
    /**
     * Refresh dashboard data
     */
    async refresh() {
        await this.loadData();
    }
    
    /**
     * Cleanup when unmounting
     */
    unmount() {
        this.data = null;
        this.error = null;
        super.unmount();
    }
}
