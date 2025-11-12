/**
 * LoginForm Component
 * Handles user authentication with FSM state management
 */
class LoginForm extends Component {
    constructor(container, props = {}) {
        super(container, props);
        
        // Initialize auth service
        this.authService = new AuthService();
        
        // Create FSM for login flow
        this.loginFSM = new StateMachine({
            initial: 'idle',
            states: {
                idle: {
                    on: {
                        SUBMIT: 'validating',
                        RESET: 'idle'
                    }
                },
                validating: {
                    on: {
                        VALIDATION_SUCCESS: 'submitting',
                        VALIDATION_ERROR: 'error'
                    },
                    onEntry: (payload) => {
                        this.validateForm(payload);
                    }
                },
                submitting: {
                    on: {
                        LOGIN_SUCCESS: 'success',
                        LOGIN_ERROR: 'error'
                    },
                    onEntry: (payload) => {
                        this.submitLogin(payload);
                    }
                },
                success: {
                    on: {
                        RESET: 'idle'
                    },
                    onEntry: (payload) => {
                        this.handleLoginSuccess(payload);
                    }
                },
                error: {
                    on: {
                        RETRY: 'idle',
                        SUBMIT: 'validating'
                    }
                }
            }
        });
        
        // Attach FSM to component
        this.attachStateMachine(this.loginFSM);
        
        // Form data
        this.formData = {
            email: '',
            password: ''
        };
        
        this.errors = {};
    }
    
    render() {
        return `
            <div class="login-container" data-state="idle">
                <div class="card">
                    <div class="login-header text-center">
                        <h1 class="text-2xl font-bold mb-2">Welcome Back</h1>
                        <p class="text-gray-600">Sign in to your Football Home account</p>
                    </div>
                    
                    <form class="login-form" id="loginForm">
                        <div class="form-group">
                            <label for="email" class="form-label">Email</label>
                            <input 
                                type="email" 
                                id="email" 
                                name="email"
                                class="form-input" 
                                placeholder="your@email.com"
                                autocomplete="email"
                            />
                            <div class="form-error" id="emailError"></div>
                        </div>
                        
                        <div class="form-group">
                            <label for="password" class="form-label">Password</label>
                            <input 
                                type="password" 
                                id="password" 
                                name="password"
                                class="form-input" 
                                placeholder="••••••••"
                                autocomplete="current-password"
                            />
                            <div class="form-error" id="passwordError"></div>
                        </div>
                        
                        <div class="login-actions">
                            <button type="submit" class="btn btn-primary btn-lg w-full" id="submitBtn">
                                <span class="btn-text">Sign In</span>
                                <span class="spinner" style="display: none;"></span>
                            </button>
                        </div>
                        
                        <div class="form-error mt-4 text-center" id="generalError"></div>
                        
                        <div class="text-center mt-4" id="successMessage" style="display: none;">
                            <p class="text-success font-medium">Login successful! Redirecting...</p>
                        </div>
                    </form>
                </div>
            </div>
        `;
    }
    
    setupEventListeners() {
        const form = this.querySelector('#loginForm');
        const emailInput = this.querySelector('#email');
        const passwordInput = this.querySelector('#password');
        
        // Form submission
        this.addEventListener(form, 'submit', this.handleSubmit);
        
        // Input changes - clear errors and update form data
        this.addEventListener(emailInput, 'input', (e) => {
            this.formData.email = e.target.value;
            this.clearFieldError('email');
        });
        
        this.addEventListener(passwordInput, 'input', (e) => {
            this.formData.password = e.target.value;
            this.clearFieldError('password');
        });
        
        // Clear general error on any input
        this.addEventListener(emailInput, 'focus', () => this.clearGeneralError());
        this.addEventListener(passwordInput, 'focus', () => this.clearGeneralError());
    }
    
    handleSubmit(e) {
        e.preventDefault();
        
        // Update form data from inputs
        this.formData.email = this.querySelector('#email').value.trim();
        this.formData.password = this.querySelector('#password').value;
        
        // Send to FSM
        this.loginFSM.send('SUBMIT', this.formData);
    }
    
    async validateForm(formData) {
        const validation = this.authService.validateLoginForm(formData.email, formData.password);
        
        if (validation.isValid) {
            this.errors = {};
            this.clearAllErrors();
            this.loginFSM.send('VALIDATION_SUCCESS', formData);
        } else {
            this.errors = validation.errors;
            this.displayErrors();
            this.loginFSM.send('VALIDATION_ERROR', validation.errors);
        }
    }
    
    async submitLogin(formData) {
        try {
            const result = await this.authService.login(formData.email, formData.password);
            console.log('AuthService result:', result);
            console.log('User in result:', result?.user);
            
            if (result.success) {
                this.loginFSM.send('LOGIN_SUCCESS', result);
            } else {
                this.loginFSM.send('LOGIN_ERROR', { message: result.error });
            }
        } catch (error) {
            this.loginFSM.send('LOGIN_ERROR', { message: error.message });
        }
    }
    
    handleLoginSuccess(result) {
        // Show success message
        const successMessage = this.querySelector('#successMessage');
        if (successMessage) {
            successMessage.style.display = 'block';
        }
        
        // Emit success event for parent components to handle
        this.emit('loginSuccess', result);
        
        // Could redirect here or let parent handle it
        setTimeout(() => {
            console.log('Login successful, user:', result.user);
            // window.location.href = '/dashboard';
        }, 1500);
    }
    
    onStateChange(transition) {
        console.log(`LoginForm: ${transition.from} -> ${transition.to}`);
        
        const submitBtn = this.querySelector('#submitBtn');
        const btnText = this.querySelector('.btn-text');
        const spinner = this.querySelector('.spinner');
        
        switch (transition.to) {
            case 'idle':
                this.clearAllErrors();
                if (submitBtn) submitBtn.disabled = false;
                if (btnText) btnText.textContent = 'Sign In';
                if (spinner) spinner.style.display = 'none';
                break;
                
            case 'validating':
            case 'submitting':
                if (submitBtn) submitBtn.disabled = true;
                if (btnText) btnText.textContent = 'Signing In...';
                if (spinner) spinner.style.display = 'inline-block';
                break;
                
            case 'error':
                if (submitBtn) submitBtn.disabled = false;
                if (btnText) btnText.textContent = 'Sign In';
                if (spinner) spinner.style.display = 'none';
                
                // Show error if it's a general login error
                if (transition.payload && transition.payload.message && !this.errors.email && !this.errors.password) {
                    this.showGeneralError(transition.payload.message);
                }
                break;
                
            case 'success':
                if (btnText) btnText.textContent = 'Success!';
                if (spinner) spinner.style.display = 'none';
                break;
        }
    }
    
    displayErrors() {
        Object.keys(this.errors).forEach(field => {
            this.showFieldError(field, this.errors[field]);
        });
    }
    
    showFieldError(field, message) {
        const input = this.querySelector(`#${field}`);
        const errorDiv = this.querySelector(`#${field}Error`);
        
        if (input) {
            input.classList.add('error');
        }
        
        if (errorDiv) {
            errorDiv.textContent = message;
        }
    }
    
    clearFieldError(field) {
        const input = this.querySelector(`#${field}`);
        const errorDiv = this.querySelector(`#${field}Error`);
        
        if (input) {
            input.classList.remove('error');
        }
        
        if (errorDiv) {
            errorDiv.textContent = '';
        }
        
        // Remove from errors object
        delete this.errors[field];
    }
    
    clearAllErrors() {
        this.errors = {};
        ['email', 'password'].forEach(field => {
            this.clearFieldError(field);
        });
        this.clearGeneralError();
    }
    
    showGeneralError(message) {
        const errorDiv = this.querySelector('#generalError');
        if (errorDiv) {
            errorDiv.textContent = message;
        }
    }
    
    clearGeneralError() {
        const errorDiv = this.querySelector('#generalError');
        if (errorDiv) {
            errorDiv.textContent = '';
        }
    }
    
    // Method to reset form
    reset() {
        this.formData = { email: '', password: '' };
        this.errors = {};
        
        const emailInput = this.querySelector('#email');
        const passwordInput = this.querySelector('#password');
        
        if (emailInput) emailInput.value = '';
        if (passwordInput) passwordInput.value = '';
        
        this.clearAllErrors();
        this.loginFSM.send('RESET');
    }
}