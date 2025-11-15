/**
 * LoginScreen - Handles user authentication
 * 
 * This screen has its own state machine for managing the login process:
 * idle -> validating -> success/error -> idle
 */
class LoginScreen extends Screen {
    constructor(container, props = {}) {
        // First call super with just the screen name, no state machine yet
        super(container, props, {
            screenName: 'login'
        });
        
        this.authService = new AuthService();
        this.loginForm = null;
        
        // Now create the state machine after this is fully initialized
        this.stateMachine = new StateMachine({
            initial: 'idle',
            states: {
                idle: {
                    on: { 
                        SUBMIT: 'validating',
                        AUTO_LOGIN: 'validating',
                        SUCCESS: 'success',  // Allow direct success from idle (for auto-login)
                        RESET: 'idle'  // Allow reset to stay in idle
                    },
                    onEntry: () => this.showForm(),
                    onExit: () => this.hideForm()
                },
                validating: {
                    on: { 
                        SUCCESS: 'success',
                        ERROR: 'error'
                    },
                    onEntry: () => this.showValidating(),
                    onExit: () => this.hideValidating()
                },
                success: {
                    on: { 
                        RESET: 'idle'
                    },
                    onEntry: (userData) => this.handleSuccess(userData)
                },
                error: {
                    on: { 
                        RETRY: 'validating',
                        RESET: 'idle'
                    },
                    onEntry: (error) => this.showError(error),
                    onExit: () => this.hideError()
                }
            }
        });
        
        // Listen for state changes
        this.stateMachine.onStateChange((prevState, newState, event, payload) => {
            // State changes for debugging if needed
        });
    }
    
    render() {
        return `
            <div class="login-screen min-h-screen flex items-center justify-center">
                <div class="login-container">
                    <div id="loginFormContainer" class="login-form-container">
                        <!-- Login form will be inserted here -->
                    </div>
                    
                    <div id="validatingContainer" class="validating-container" style="display: none;">
                        <div class="text-center">
                            <div class="loading-spinner"></div>
                            <p class="mt-4">Logging you in...</p>
                        </div>
                    </div>
                    
                    <div id="errorContainer" class="error-container" style="display: none;">
                        <div class="error-message">
                            <p id="errorText">Login failed. Please try again.</p>
                            <button id="retryBtn" class="btn btn-primary mt-4">Try Again</button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }
    
    async onEnter(data = null) {
        await super.onEnter(data);
        
        // Check if user is already authenticated
        if (this.authService.isAuthenticated()) {
            this.send('AUTO_LOGIN');
            
            const userResult = await this.authService.getCurrentUser();
            if (userResult.success) {
                this.send('SUCCESS', userResult.user);
                return;
            }
        }
        
        // Show login form
        this.send('RESET'); // Ensure we're in idle state
    }
    
    showForm() {
        const container = this.element.querySelector('#loginFormContainer');
        if (container) {
            // Create LoginForm component
            this.loginForm = new LoginForm(container);
            
            // Listen for login events
            this.loginForm.on('loginStart', (event) => {
                console.log('📱 LoginScreen: Login started, transitioning to validating');
                this.send('SUBMIT');
            });
            
            this.loginForm.on('loginSuccess', (event) => {
                console.log('📱 LoginScreen: Received loginSuccess event:', event.detail);
                this.send('SUCCESS', event.detail.user);
            });
            
            this.loginForm.on('loginError', (event) => {
                console.log('📱 LoginScreen: Received loginError event:', event.detail);
                this.send('ERROR', event.detail.error);
            });
        }
    }
    
    hideForm() {
        if (this.loginForm) {
            this.loginForm.cleanup();
            this.loginForm = null;
        }
    }
    
    showValidating() {
        const validating = this.element.querySelector('#validatingContainer');
        const form = this.element.querySelector('#loginFormContainer');
        const error = this.element.querySelector('#errorContainer');
        
        if (validating) validating.style.display = 'block';
        if (form) form.style.display = 'none';
        if (error) error.style.display = 'none';
    }
    
    hideValidating() {
        const validating = this.element.querySelector('#validatingContainer');
        if (validating) validating.style.display = 'none';
    }
    
    handleSuccess(userData) {
        // Navigate to role switchboard
        setTimeout(() => {
            this.navigateTo('roleSwitchboard', { user: userData });
        }, 500); // Small delay for UX
    }
    
    showError(error) {
        const errorContainer = this.element.querySelector('#errorContainer');
        const errorText = this.element.querySelector('#errorText');
        const form = this.element.querySelector('#loginFormContainer');
        const validating = this.element.querySelector('#validatingContainer');
        
        if (errorText) {
            errorText.textContent = error.message || 'Login failed. Please try again.';
        }
        
        if (errorContainer) errorContainer.style.display = 'block';
        if (form) form.style.display = 'none';
        if (validating) validating.style.display = 'none';
        
        // Setup retry button
        const retryBtn = this.element.querySelector('#retryBtn');
        if (retryBtn) {
            retryBtn.onclick = () => {
                this.send('RESET');
            };
        }
    }
    
    hideError() {
        const errorContainer = this.element.querySelector('#errorContainer');
        if (errorContainer) errorContainer.style.display = 'none';
        
        const form = this.element.querySelector('#loginFormContainer');
        if (form) form.style.display = 'block';
    }
    
    async onExit() {
        // Clean up login form
        this.hideForm();
        
        await super.onExit();
    }
}