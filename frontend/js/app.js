// Football Home - Main Application
class FootballApp {
    constructor() {
        this.currentView = 'events';
        this.currentUser = null;
        this.currentTeamId = null;
        this.init();
    }

    async init() {
        this.setupNavigation();
        this.setupEventForm();
        
        // Check authentication first
        const isLoggedIn = await this.checkAuthentication();
        if (isLoggedIn) {
            this.loadEvents();
        } else {
            this.showLoginPrompt();
        }
        
        this.setupPWA();
    }

    async checkAuthentication() {
        try {
            const response = await API.getCurrentUser();
            if (response && response.success && response.user && response.user.id) {
                this.currentUser = response.user;
                this.currentTeamId = '550e8400-e29b-41d4-a716-446655440001'; // TODO: Get from user's team
                this.updateUIForLoggedInUser(response.user);
                return true;
            }
        } catch (error) {
            console.log('User not authenticated:', error.message);
        }
        
        this.updateUIForLoggedOutUser();
        return false;
    }

    updateUIForLoggedInUser(user) {
        // Show welcome message
        this.showWelcomeMessage(user);
        
        // Update profile info
        const userRole = document.getElementById('user-role');
        const userEmail = document.getElementById('user-email');
        if (userRole) userRole.textContent = user.role || 'Player';
        if (userEmail) userEmail.textContent = user.email || 'user@example.com';

        // Show coach-only features if user is a coach
        const coachElements = document.querySelectorAll('.coach-only');
        coachElements.forEach(el => {
            el.style.display = user.role === 'coach' ? 'block' : 'none';
        });

        // Show logout button
        const logoutBtn = document.getElementById('nav-logout');
        if (logoutBtn) {
            logoutBtn.style.display = 'block';
        }
    }

    updateUIForLoggedOutUser() {
        // Hide coach-only features
        const coachElements = document.querySelectorAll('.coach-only');
        coachElements.forEach(el => {
            el.style.display = 'none';
        });

        // Hide logout button
        const logoutBtn = document.getElementById('nav-logout');
        if (logoutBtn) {
            logoutBtn.style.display = 'none';
        }
        
        // Hide welcome message
        this.hideWelcomeMessage();
    }

    showWelcomeMessage(user) {
        const mainContent = document.querySelector('.main-content');
        let welcomeDiv = document.getElementById('welcome-message');
        
        if (!welcomeDiv) {
            welcomeDiv = document.createElement('div');
            welcomeDiv.id = 'welcome-message';
            welcomeDiv.style.cssText = `
                position: fixed;
                top: 90px;
                right: 20px;
                background: linear-gradient(135deg, #10b981, #059669);
                color: white;
                padding: 10px 20px;
                border-radius: 25px;
                font-size: 0.9em;
                font-weight: 600;
                box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
                z-index: 1000;
                backdrop-filter: blur(10px);
            `;
            document.body.appendChild(welcomeDiv);
        }
        
        const roleTitle = user.role === 'coach' ? 'Coach' : 'Player';
        welcomeDiv.textContent = `Welcome ${roleTitle} ${user.name || user.email.split('@')[0]}!`;
    }

    hideWelcomeMessage() {
        const welcomeDiv = document.getElementById('welcome-message');
        if (welcomeDiv) {
            welcomeDiv.remove();
        }
    }

    showLoginPrompt() {
        const eventsList = document.getElementById('events-list');
        eventsList.innerHTML = `
            <div class="login-prompt">
                <div class="login-card">
                    <h2>⚽ Welcome to Football Home</h2>
                    <p>Please log in to view your team's events and manage your RSVP responses.</p>
                    
                    <div class="login-form">
                        <div class="form-group">
                            <label for="login-email">Email</label>
                            <input type="email" id="login-email" placeholder="Enter your email" required>
                        </div>
                        <div class="form-group">
                            <label for="login-password">Password</label>
                            <input type="password" id="login-password" placeholder="Enter your password" required>
                        </div>
                        <button onclick="app.handleLogin()" class="btn btn-primary full-width" style="transition: all 0.2s ease;">
                            🔑 Log In
                        </button>
                        
                        <div class="login-divider">
                            <span>or</span>
                        </div>
                        
                        <button onclick="app.showDemoMode()" class="btn btn-outline full-width">
                            👁️ View Demo
                        </button>
                    </div>
                    
                    <div class="login-footer">
                        <p>Don't have an account? Contact your team coach.</p>
                    </div>
                </div>
            </div>
        `;

        // Add Enter key functionality after DOM is updated
        setTimeout(() => {
            const emailInput = document.getElementById('login-email');
            const passwordInput = document.getElementById('login-password');
            
            const handleEnterKey = (event) => {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    this.handleLogin();
                }
            };

            if (emailInput) {
                emailInput.addEventListener('keypress', handleEnterKey);
            }
            if (passwordInput) {
                passwordInput.addEventListener('keypress', handleEnterKey);
            }
        }, 0);
    }

    setupNavigation() {
        const navButtons = document.querySelectorAll('.nav-btn');
        const views = document.querySelectorAll('.view');

        navButtons.forEach(btn => {
            btn.addEventListener('click', (event) => {
                event.preventDefault(); // Prevent any default button behavior
                const viewName = btn.id.replace('nav-', '');
                
                // Special handling for coach dashboard
                if (viewName === 'coach') {
                    window.location.href = '/coach';
                    return;
                }
                
                // Special handling for profile - redirect based on user role
                if (viewName === 'profile') {
                    console.log('Profile clicked, current user:', this.currentUser);
                    console.log('Current location:', window.location.href);
                    // Always redirect for profile - don't fall through to switchView
                    if (this.currentUser && this.currentUser.role === 'coach') {
                        console.log('Redirecting coach to /coach');
                        const coachUrl = window.location.origin + '/coach';
                        console.log('Coach URL:', coachUrl);
                        window.location.href = coachUrl;
                    } else {
                        console.log('Redirecting to player profile (default for any non-coach user)');
                        const playerUrl = window.location.origin + '/player';
                        console.log('Player URL:', playerUrl);
                        window.location.href = playerUrl;
                    }
                    return; // Ensure we never fall through
                }
                
                // Special handling for logout
                if (viewName === 'logout') {
                    this.logout();
                    return;
                }
                
                this.switchView(viewName);
            });
        });
    }

    switchView(viewName) {
        // Update active nav button
        document.querySelectorAll('.nav-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.getElementById(`nav-${viewName}`).classList.add('active');

        // Update active view
        document.querySelectorAll('.view').forEach(view => {
            view.classList.remove('active');
        });
        document.getElementById(`${viewName}-view`).classList.add('active');

        this.currentView = viewName;
    }

    setupEventForm() {
        const form = document.getElementById('create-event-form');
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const formData = new FormData(form);
            const eventData = {
                team_id: this.currentTeamId,
                title: formData.get('title'),
                event_type: formData.get('event_type'),
                event_date: formData.get('event_date'),
                location: formData.get('location'),
                duration_minutes: parseInt(formData.get('duration_minutes')),
                description: formData.get('description')
            };

            try {
                const response = await API.createEvent(eventData);
                if (response.status === 'created') {
                    this.showNotification('Event created successfully!', 'success');
                    form.reset();
                    this.switchView('events');
                    this.loadEvents(); // Refresh events list
                }
            } catch (error) {
                this.showNotification('Error creating event', 'error');
                console.error('Create event error:', error);
            }
        });
    }

    async loadEvents() {
        const eventsList = document.getElementById('events-list');
        eventsList.innerHTML = '<div class="loading">Loading events...</div>';

        try {
            const response = await API.getTeamEvents(this.currentTeamId);
            this.renderEvents(response.events);
        } catch (error) {
            eventsList.innerHTML = '<div class="loading">Error loading events</div>';
            console.error('Load events error:', error);
        }
    }

    renderEvents(events) {
        const eventsList = document.getElementById('events-list');
        
        if (events.length === 0) {
            eventsList.innerHTML = `
                <div class="loading">
                    <p>No events scheduled yet.</p>
                    <button class="btn btn-primary" onclick="app.switchView('create')">Create First Event</button>
                </div>
            `;
            return;
        }

        eventsList.innerHTML = events.map(event => this.createEventCard(event)).join('');
    }

    createEventCard(event) {
        const date = new Date(event.event_date);
        const formattedDate = date.toLocaleDateString();
        const formattedTime = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        
        return `
            <div class="event-card" data-event-id="${event.id}">
                <div class="event-card-header">
                    <h3 class="event-title">${event.title}</h3>
                    <span class="event-type ${event.event_type}">${event.event_type}</span>
                </div>
                
                <div class="event-details">
                    <div class="event-detail">
                        <span class="event-detail-icon">📅</span>
                        <span>${formattedDate} at ${formattedTime}</span>
                    </div>
                    ${event.location ? `
                        <div class="event-detail">
                            <span class="event-detail-icon">📍</span>
                            <span>${event.location}</span>
                        </div>
                    ` : ''}
                    <div class="event-detail">
                        <span class="event-detail-icon">⏱️</span>
                        <span>${event.duration_minutes} minutes</span>
                    </div>
                </div>
                
                ${event.description ? `
                    <div class="event-description">${event.description}</div>
                ` : ''}
                
                <div class="rsvp-status">
                    <span class="rsvp-count">3 attending • 1 maybe • 0 can't make it</span>
                </div>
                
                <div class="rsvp-buttons">
                    <button class="rsvp-btn" data-status="yes" onclick="app.handleRSVP('${event.id}', 'yes')">✓ Yes</button>
                    <button class="rsvp-btn" data-status="maybe" onclick="app.handleRSVP('${event.id}', 'maybe')">? Maybe</button>
                    <button class="rsvp-btn" data-status="no" onclick="app.handleRSVP('${event.id}', 'no')">✗ No</button>
                </div>
            </div>
        `;
    }

    async handleRSVP(eventId, status) {
        try {
            const response = await API.rsvpToEvent(eventId, {
                user_id: '550e8400-e29b-41d4-a716-446655440011', // TODO: Get from auth
                status: status
            });
            
            if (response.status === 'rsvp_updated') {
                this.showNotification('RSVP updated!', 'success');
                
                // Update button states
                const eventCard = document.querySelector(`[data-event-id="${eventId}"]`);
                const rsvpButtons = eventCard.querySelectorAll('.rsvp-btn');
                rsvpButtons.forEach(btn => btn.classList.remove('active'));
                eventCard.querySelector(`[data-status="${status}"]`).classList.add('active');
            }
        } catch (error) {
            this.showNotification('Error updating RSVP', 'error');
            console.error('RSVP error:', error);
        }
    }

    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;
        
        // Style the notification
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 20px;
            border-radius: 8px;
            color: white;
            font-weight: 500;
            z-index: 1000;
            transform: translateX(100%);
            transition: transform 0.3s ease;
        `;
        
        if (type === 'success') {
            notification.style.background = '#10b981';
        } else if (type === 'error') {
            notification.style.background = '#ef4444';
        } else {
            notification.style.background = '#3b82f6';
        }
        
        document.body.appendChild(notification);
        
        // Animate in
        setTimeout(() => {
            notification.style.transform = 'translateX(0)';
        }, 100);
        
        // Remove after delay
        setTimeout(() => {
            notification.style.transform = 'translateX(100%)';
            setTimeout(() => {
                document.body.removeChild(notification);
            }, 300);
        }, 3000);
    }

    async handleLogin() {
        const emailInput = document.getElementById('login-email');
        const passwordInput = document.getElementById('login-password');
        const loginButton = document.querySelector('button[onclick="app.handleLogin()"]');
        
        const email = emailInput.value.trim();
        const password = passwordInput.value.trim();

        if (!email || !password) {
            this.showNotification('Please enter both email and password', 'error');
            emailInput.focus();
            return;
        }

        // Disable button and show loading state
        const originalButtonText = loginButton.textContent;
        loginButton.disabled = true;
        loginButton.textContent = '🔄 Logging in...';
        loginButton.style.opacity = '0.6';

        try {
            const result = await API.login({ email, password });
            
            if (result.success && result.user) {
                this.currentUser = result.user;
                this.currentTeamId = '550e8400-e29b-41d4-a716-446655440001'; // TODO: Get from user's team
                this.updateUIForLoggedInUser(result.user);
                this.loadEvents();
                this.showNotification(`Welcome back, ${result.user.name || result.user.email}!`, 'success');
            } else {
                this.showNotification('Login failed. Please check your email and password.', 'error');
                passwordInput.focus();
                passwordInput.select();
            }
        } catch (error) {
            console.error('Login error:', error);
            if (error.message.includes('500')) {
                this.showNotification('Server error. Please try again in a moment.', 'error');
            } else if (error.message.includes('network') || error.message.includes('fetch')) {
                this.showNotification('Connection error. Please check your internet connection.', 'error');
            } else {
                this.showNotification('Login failed. Please try again.', 'error');
            }
            passwordInput.focus();
            passwordInput.select();
        } finally {
            // Re-enable button
            loginButton.disabled = false;
            loginButton.textContent = originalButtonText;
            loginButton.style.opacity = '1';
        }
    }

    showDemoMode() {
        // Set demo user
        this.currentUser = {
            id: 'demo-user',
            name: 'Demo User',
            email: 'demo@footballhome.org',
            role: 'player'
        };
        this.currentTeamId = '550e8400-e29b-41d4-a716-446655440001';
        this.updateUIForLoggedInUser(this.currentUser);
        this.loadEvents();
        this.showNotification('Viewing in demo mode', 'info');
    }

    async logout() {
        try {
            await API.logout();
            this.currentUser = null;
            this.currentTeamId = null;
            this.updateUIForLoggedOutUser();
            this.showLoginPrompt();
            this.showNotification('Logged out successfully', 'success');
        } catch (error) {
            console.error('Logout error:', error);
            // Still log out locally even if API call fails
            this.currentUser = null;
            this.currentTeamId = null;
            this.updateUIForLoggedOutUser();
            this.showLoginPrompt();
        }
    }

    setupPWA() {
        // Register service worker
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('/sw.js')
                .then(registration => {
                    console.log('Service Worker registered:', registration);
                })
                .catch(error => {
                    console.log('Service Worker registration failed:', error);
                });
        }

        // Handle install prompt
        let deferredPrompt;
        window.addEventListener('beforeinstallprompt', (e) => {
            e.preventDefault();
            deferredPrompt = e;
            
            const installPrompt = document.getElementById('install-prompt');
            installPrompt.classList.remove('hidden');
            
            document.getElementById('install-btn').addEventListener('click', () => {
                deferredPrompt.prompt();
                deferredPrompt.userChoice.then((choiceResult) => {
                    if (choiceResult.outcome === 'accepted') {
                        console.log('PWA installed');
                    }
                    deferredPrompt = null;
                    installPrompt.classList.add('hidden');
                });
            });
            
            document.getElementById('dismiss-install').addEventListener('click', () => {
                installPrompt.classList.add('hidden');
            });
        });
    }
}

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.app = new FootballApp();
});