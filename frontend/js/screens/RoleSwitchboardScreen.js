/**
 * RoleSwitchboardScreen - Role selection interface
 * 
 * This screen manages role selection with its own state machine:
 * loading -> ready -> selecting -> navigating
 */
class RoleSwitchboardScreen extends Screen {
    constructor(container, props = {}) {
        super(container, props, {
            screenName: 'roleSwitchboard'
        });
        
        this.authService = new AuthService();
        this.roleSwitchboard = null;
        
        // Create state machine after this is fully initialized
        this.stateMachine = new StateMachine({
            initial: 'loading',
            states: {
                loading: {
                    on: { 
                        ROLES_LOADED: 'ready',
                        ERROR: 'error'
                    },
                    onEntry: () => this.showLoading(),
                    onExit: () => this.hideLoading()
                },
                ready: {
                    on: { 
                        ROLE_SELECTED: 'selecting',
                        ERROR: 'error',
                        LOGOUT: 'logout'
                    },
                    onEntry: () => this.showRoleCards(),
                    onExit: () => this.hideRoleCards()
                },
                selecting: {
                    on: { 
                        NAVIGATE: 'navigating',
                        CANCEL: 'ready'
                    },
                    onEntry: (roleSelection) => this.handleRoleSelection(roleSelection)
                },
                navigating: {
                    on: { 
                        COMPLETE: 'ready',
                        ERROR: 'ready'
                    },
                    onEntry: (navigationData) => this.navigate(navigationData)
                },
                error: {
                    on: { 
                        RETRY: 'loading',
                        LOGOUT: 'logout'
                    },
                    onEntry: (error) => this.showError(error),
                    onExit: () => this.hideError()
                },
                logout: {
                    onEntry: () => this.handleLogout()
                }
            }
        });
        
        this.user = null;
        this.userRoles = [];
        
        // Listen for state changes for debugging
        this.stateMachine.onStateChange((prevState, newState, event, payload) => {
            console.log(`📱 RoleSwitchboardScreen: ${prevState} --[${event}]--> ${newState}`);
        });
    }
    
    render() {
        return `
            <div class="role-switchboard-screen">
                <div id="loadingContainer" class="loading-container" style="display: none;">
                    <div class="min-h-screen flex items-center justify-center">
                        <div class="text-center">
                            <div class="loading-spinner"></div>
                            <p class="mt-4">Loading your roles...</p>
                        </div>
                    </div>
                </div>
                
                <div id="roleCardsContainer" class="role-cards-container" style="display: none;">
                    <!-- Role switchboard will be inserted here -->
                </div>
                
                <div id="errorContainer" class="error-container" style="display: none;">
                    <div class="min-h-screen flex items-center justify-center">
                        <div class="text-center">
                            <h2>Unable to Load Roles</h2>
                            <p id="errorText" class="mt-4">There was an error loading your roles.</p>
                            <div class="mt-6">
                                <button id="retryBtn" class="btn btn-primary mr-4">Try Again</button>
                                <button id="logoutBtn" class="btn btn-secondary">Logout</button>
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
        
        if (!this.user) {
            console.error('📱 RoleSwitchboardScreen: No user data provided');
            this.send('ERROR', { message: 'No user data available' });
            return;
        }
        
        console.log('📱 RoleSwitchboardScreen: Loading roles for user:', this.user);
        
        // Start loading roles
        this.send('ROLES_LOADED'); // For now, we'll load roles immediately
        this.loadUserRoles();
    }
    
    async loadUserRoles() {
        try {
            const rolesResult = await this.authService.getUserRoles();
            
            if (rolesResult.success) {
                this.userRoles = rolesResult.data.roles || [];
                console.log('📱 RoleSwitchboardScreen: Loaded roles:', this.userRoles);
                this.send('ROLES_LOADED');
            } else {
                console.error('📱 RoleSwitchboardScreen: Failed to load roles:', rolesResult.error);
                this.send('ERROR', { message: rolesResult.error });
            }
        } catch (error) {
            console.error('📱 RoleSwitchboardScreen: Error loading roles:', error);
            this.send('ERROR', { message: 'Failed to load user roles' });
        }
    }
    
    showLoading() {
        const loading = this.element.querySelector('#loadingContainer');
        const roleCards = this.element.querySelector('#roleCardsContainer');
        const error = this.element.querySelector('#errorContainer');
        
        if (loading) loading.style.display = 'block';
        if (roleCards) roleCards.style.display = 'none';
        if (error) error.style.display = 'none';
    }
    
    hideLoading() {
        const loading = this.element.querySelector('#loadingContainer');
        if (loading) loading.style.display = 'none';
    }
    
    showRoleCards() {
        const roleCards = this.element.querySelector('#roleCardsContainer');
        const loading = this.element.querySelector('#loadingContainer');
        const error = this.element.querySelector('#errorContainer');
        
        if (roleCards) roleCards.style.display = 'block';
        if (loading) loading.style.display = 'none';
        if (error) error.style.display = 'none';
        
        // Create RoleSwitchboard component
        if (!this.roleSwitchboard) {
            this.roleSwitchboard = new RoleSwitchboard(roleCards, this.user);
            
            // Listen for role selection
            roleCards.addEventListener('role:selected', (event) => {
                console.log('📱 RoleSwitchboardScreen: Role selection event:', event.detail);
                this.send('ROLE_SELECTED', event.detail);
            });
            
            // Listen for logout
            roleCards.addEventListener('user:logout', () => {
                console.log('📱 RoleSwitchboardScreen: Logout event');
                this.send('LOGOUT');
            });
        }
    }
    
    hideRoleCards() {
        const roleCards = this.element.querySelector('#roleCardsContainer');
        if (roleCards) roleCards.style.display = 'none';
    }
    
    handleRoleSelection(roleSelection) {
        console.log('📱 RoleSwitchboardScreen: Handling role selection:', roleSelection);
        
        if (roleSelection.navigateTo === 'dashboard') {
            this.send('NAVIGATE', {
                screen: 'dashboard',
                data: { roleSelection }
            });
        } else if (roleSelection.navigateTo === 'teamSelection') {
            // Future: handle team selection screen
            console.log('📱 RoleSwitchboardScreen: Team selection not implemented yet');
            this.send('CANCEL');
        }
    }
    
    navigate(navigationData) {
        console.log('📱 RoleSwitchboardScreen: Navigating to:', navigationData);
        
        setTimeout(() => {
            this.navigateTo(navigationData.screen, navigationData.data);
            this.send('COMPLETE');
        }, 100);
    }
    
    showError(error) {
        const errorContainer = this.element.querySelector('#errorContainer');
        const errorText = this.element.querySelector('#errorText');
        const loading = this.element.querySelector('#loadingContainer');
        const roleCards = this.element.querySelector('#roleCardsContainer');
        
        if (errorText) {
            errorText.textContent = error.message || 'An error occurred';
        }
        
        if (errorContainer) errorContainer.style.display = 'block';
        if (loading) loading.style.display = 'none';
        if (roleCards) roleCards.style.display = 'none';
        
        // Setup buttons
        const retryBtn = this.element.querySelector('#retryBtn');
        const logoutBtn = this.element.querySelector('#logoutBtn');
        
        if (retryBtn) {
            retryBtn.onclick = () => this.send('RETRY');
        }
        
        if (logoutBtn) {
            logoutBtn.onclick = () => this.send('LOGOUT');
        }
    }
    
    hideError() {
        const errorContainer = this.element.querySelector('#errorContainer');
        if (errorContainer) errorContainer.style.display = 'none';
    }
    
    handleLogout() {
        console.log('📱 RoleSwitchboardScreen: Handling logout');
        
        // Navigate to login screen
        setTimeout(() => {
            this.navigateTo('login');
        }, 100);
    }
    
    async onExit() {
        console.log('📱 RoleSwitchboardScreen: Exiting');
        
        // Clean up role switchboard component
        if (this.roleSwitchboard) {
            this.roleSwitchboard.cleanup();
            this.roleSwitchboard = null;
        }
        
        await super.onExit();
    }
}