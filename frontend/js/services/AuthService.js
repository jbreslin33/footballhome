/**
 * Authentication Service
 * Handles login, logout, and token management
 */
class AuthService {
    constructor(baseUrl = null) {
        // Auto-detect API URL based on current hostname  
        if (!baseUrl) {
            const hostname = window.location.hostname;
            const protocol = window.location.protocol;
            
            if (hostname === 'localhost' || hostname === '127.0.0.1') {
                // Local development - direct to backend
                this.baseUrl = 'http://localhost:3001';
            } else {
                // Production/remote - use relative URLs (nginx proxy handles routing)
                this.baseUrl = '';
            }
        } else {
            this.baseUrl = baseUrl;
        }
        
        console.log(`AuthService initialized with API URL: ${this.baseUrl} (host: ${window.location.hostname})`);
        this.token = localStorage.getItem('auth_token');
    }
    
    /**
     * Login with email and password
     */
    async login(email, password) {
        const loginUrl = `${this.baseUrl}/api/auth/login`;
        console.log(`Attempting login to: ${loginUrl}`);
        
        try {
            const response = await fetch(loginUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ email, password })
            });
            
            const data = await response.json();
            console.log('Raw backend response:', data);
            
            // Check both HTTP status and JSON success field
            if (!response.ok || !data.success) {
                // Authentication specific error (401) vs other errors
                if (response.status === 401) {
                    throw new Error(data.message || 'Invalid email or password');
                } else {
                    throw new Error(data.message || `Server error (${response.status})`);
                }
            }
            
            // Store token
            if (data.token) {
                this.token = data.token;
                localStorage.setItem('auth_token', this.token);
            }
            
            return {
                success: true,
                user: data.user,
                token: data.token
            };
            
        } catch (error) {
            console.error('Login error details:', {
                message: error.message,
                name: error.name,
                stack: error.stack,
                apiUrl: this.baseUrl
            });
            
            // Distinguish between network errors and authentication errors
            if (error.message.includes('Invalid email or password')) {
                return {
                    success: false,
                    error: error.message
                };
            } else if (error.name === 'TypeError' && error.message.includes('fetch')) {
                return {
                    success: false,
                    error: `Connection failed: Unable to reach server at ${this.baseUrl}`
                };
            } else {
                return {
                    success: false,
                    error: error.message
                };
            }
        }
    }
    
    /**
     * Logout user
     */
    logout() {
        this.token = null;
        localStorage.removeItem('auth_token');
        
        // Could call logout endpoint if needed
        // await fetch(`${this.baseUrl}/auth/logout`, { ... });
        
        return { success: true };
    }
    
    /**
     * Check if user is authenticated
     */
    isAuthenticated() {
        return !!this.token;
    }
    
    /**
     * Get current auth token
     */
    getToken() {
        return this.token;
    }
    
    /**
     * Get authenticated user info
     */
    async getCurrentUser() {
        if (!this.token) {
            return { success: false, error: 'No auth token' };
        }
        
        try {
            const response = await fetch(`${this.baseUrl}/api/auth/me`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`
                }
            });
            
            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.message || 'Failed to get user');
            }
            
            return {
                success: true,
                user: data.user
            };
            
        } catch (error) {
            console.error('Get user error:', error);
            
            // If token is invalid, clear it
            if (error.message.includes('token') || error.message.includes('auth')) {
                this.logout();
            }
            
            return {
                success: false,
                error: error.message
            };
        }
    }
    
    /**
     * Validate email format
     */
    validateEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }
    
    /**
     * Validate password requirements
     */
    validatePassword(password) {
        if (!password || password.length < 6) {
            return { valid: false, message: 'Password must be at least 6 characters' };
        }
        
        return { valid: true };
    }
    
    /**
     * Validate login form
     */
    validateLoginForm(email, password) {
        const errors = {};
        
        if (!email) {
            errors.email = 'Email is required';
        } else if (!this.validateEmail(email)) {
            errors.email = 'Please enter a valid email';
        }
        
        if (!password) {
            errors.password = 'Password is required';
        } else {
            const passwordValidation = this.validatePassword(password);
            if (!passwordValidation.valid) {
                errors.password = passwordValidation.message;
            }
        }
        
        return {
            isValid: Object.keys(errors).length === 0,
            errors
        };
    }
}