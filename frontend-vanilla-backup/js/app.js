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
            console.log('Checking authentication...');
            const response = await API.getCurrentUser();
            console.log('Auth response:', response);
            if (response && response.success && response.user && (response.user.id || response.user.email)) {
                console.log('User authenticated:', response.user.email);
                this.currentUser = response.user;
                this.currentTeamId = '550e8400-e29b-41d4-a716-446655440001'; // TODO: Get from user's team
                this.updateUIForLoggedInUser(response.user);
                return true;
            } else {
                console.log('Authentication failed - response:', response);
                console.log('User object:', response?.user);
            }
        } catch (error) {
            console.log('User not authenticated - error:', error.message);
        }
        
        console.log('Updating UI for logged out user');
        this.updateUIForLoggedOutUser();
        return false;
    }

    showUserLoggedIn(user) {
        console.log('showUserLoggedIn called with user:', user);
        
        // Store current user
        this.currentUser = user;
        this.currentTeamId = user.team_id || '550e8400-e29b-41d4-a716-446655440001';

        // Update profile info
        const userRole = document.getElementById('user-role');
        const userEmail = document.getElementById('user-email');
        const userName = document.getElementById('user-name');
        const userPhone = document.getElementById('user-phone');
        const userTeam = document.getElementById('user-team');
        
        console.log('Profile elements found:', { userRole, userEmail, userName, userPhone, userTeam });
        
        if (userRole) userRole.textContent = user.primary_role || 'Player';
        if (userEmail) userEmail.textContent = user.email;
        if (userName) userName.textContent = user.name || 'Not set';
        if (userPhone) userPhone.textContent = user.phone || 'Not set';
        if (userTeam) userTeam.textContent = 'Thunder FC'; // Static for now

        // Show coach-only features if user is a coach
        const coachElements = document.querySelectorAll('.coach-only');
        console.log('Coach elements found:', coachElements.length, 'User primary_role:', user.primary_role);
        coachElements.forEach(el => {
            el.style.display = user.primary_role === 'coach' ? 'block' : 'none';
        });

        // Show nav logout button
        const logoutBtn = document.getElementById('nav-logout');
        console.log('Nav logout button found:', logoutBtn);
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
        
        // Clear profile information
        const userRole = document.getElementById('user-role');
        const userEmail = document.getElementById('user-email');
        const userTeam = document.getElementById('user-team');
        const userName = document.getElementById('user-name');
        const userPhone = document.getElementById('user-phone');
        
        if (userRole) userRole.textContent = 'Not logged in';
        if (userEmail) userEmail.textContent = 'Not logged in';
        if (userTeam) userTeam.textContent = 'No team';
        if (userName) userName.textContent = 'Not logged in';
        if (userPhone) userPhone.textContent = 'Not set';
        
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
        
        const roleTitle = user.primary_role === 'coach' ? 'Coach' : 'Player';
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
                            <div class="form-checkbox" style="margin-top: 8px;">
                                <input type="checkbox" id="show-password" onchange="app.togglePasswordVisibility()">
                                <label for="show-password" style="font-size: 0.9em; margin-left: 8px;">Show password</label>
                            </div>
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
            // Skip logout button - it has its own event listener
            if (btn.id === 'nav-logout') {
                return;
            }
            
            btn.addEventListener('click', (event) => {
                event.preventDefault(); // Prevent any default button behavior
                const viewName = btn.id.replace('nav-', '');
                
                // Special handling for coach dashboard
                if (viewName === 'coach') {
                    window.location.href = '/coach';
                    return;
                }
                
                // Special handling for profile - show profile view
                if (viewName === 'profile') {
                    this.switchView('profile');
                    return;
                }
                
                this.switchView(viewName);
            });
        });

        // Setup nav logout button
        const navLogoutBtn = document.getElementById('nav-logout');
        if (navLogoutBtn) {
            console.log('Setting up nav logout button event listener');
            navLogoutBtn.addEventListener('click', (event) => {
                console.log('Nav logout button clicked');
                event.preventDefault();
                event.stopPropagation();
                this.logout();
            });
        }

        // Setup profile logout button
        const profileLogoutBtn = document.getElementById('profile-logout');
        if (profileLogoutBtn) {
            console.log('Setting up profile logout button event listener');
            profileLogoutBtn.addEventListener('click', (event) => {
                console.log('Profile logout button clicked');
                event.preventDefault();
                this.logout();
            });
        }

        // Profile event listeners are set up in setupProfileEventListeners() when profile view is shown
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

        // Setup profile event listeners when profile view is shown
        if (viewName === 'profile') {
            this.setupProfileEventListeners();
        }
    }

    setupProfileEventListeners() {
        console.log('Setting up profile event listeners...');
        
        // Use a slight delay to ensure DOM is ready
        setTimeout(() => {
            // Setup profile edit button
            const editProfileBtn = document.getElementById('edit-profile-btn');
            console.log('Edit profile button found:', editProfileBtn);
            
            if (editProfileBtn) {
                // Remove any existing event listeners
                const newBtn = editProfileBtn.cloneNode(true);
                editProfileBtn.parentNode.replaceChild(newBtn, editProfileBtn);
                console.log('New button replaced in DOM');
                
                newBtn.addEventListener('click', (event) => {
                    console.log('Edit profile button clicked!');
                    event.preventDefault();
                    event.stopPropagation();
                    this.showEditProfile();
                });
                
                // Also add onclick as backup
                newBtn.onclick = (event) => {
                    console.log('Edit profile onclick triggered!');
                    event.preventDefault();
                    this.showEditProfile();
                };
            }

            // Setup profile edit form
            const editForm = document.getElementById('edit-profile-form');
            if (editForm) {
                editForm.addEventListener('submit', (event) => {
                    event.preventDefault();
                    this.handleProfileUpdate();
                });
            }

            // Setup cancel edit button
            const cancelEditBtn = document.getElementById('cancel-edit');
            if (cancelEditBtn) {
                cancelEditBtn.addEventListener('click', (event) => {
                    event.preventDefault();
                    this.hideEditProfile();
                });
            }
        }, 100);
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
        console.log('logout() method called');
        try {
            console.log('Calling API.logout()...');
            await API.logout();
            console.log('API logout successful');
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

    showEditProfile() {
        console.log('showEditProfile called, currentUser:', this.currentUser);
        
        if (!this.currentUser) {
            this.showNotification('Please log in to edit your profile', 'error');
            return;
        }

        // Populate form with current user data
        document.getElementById('edit-name').value = this.currentUser.name || '';
        document.getElementById('edit-phone').value = this.currentUser.phone || '';
        document.getElementById('edit-emergency-contact').value = this.currentUser.emergency_contact || '';
        document.getElementById('edit-emergency-phone').value = this.currentUser.emergency_phone || '';

        // Show edit form, hide display
        const profileDisplay = document.getElementById('profile-display');
        const profileEdit = document.getElementById('profile-edit');
        const editBtn = document.getElementById('edit-profile-btn');
        
        console.log('Profile elements:', { profileDisplay, profileEdit, editBtn });
        
        if (profileDisplay) profileDisplay.style.display = 'none';
        if (profileEdit) profileEdit.style.display = 'block';
        if (editBtn) editBtn.style.display = 'none';
        
        console.log('Profile edit form should now be visible');
    }

    hideEditProfile() {
        // Show display, hide edit form
        document.getElementById('profile-display').style.display = 'block';
        document.getElementById('profile-edit').style.display = 'none';
        document.getElementById('edit-profile-btn').style.display = 'inline-block';
    }

    async handleProfileUpdate() {
        const name = document.getElementById('edit-name').value.trim();
        const phone = document.getElementById('edit-phone').value.trim();
        const emergencyContact = document.getElementById('edit-emergency-contact').value.trim();
        const emergencyPhone = document.getElementById('edit-emergency-phone').value.trim();
        const password = document.getElementById('edit-password').value.trim();

        if (!name) {
            this.showNotification('Name is required', 'error');
            return;
        }

        try {
            const profileData = {
                name: name,
                phone: phone,
                emergency_contact: emergencyContact,
                emergency_phone: emergencyPhone
            };

            // Only include password if it's provided
            if (password) {
                profileData.password = password;
            }

            const result = await API.updateProfile(profileData);

            if (result.success) {
                // Update current user data
                this.currentUser.name = name;
                this.currentUser.phone = phone;
                this.currentUser.emergency_contact = emergencyContact;
                this.currentUser.emergency_phone = emergencyPhone;

                // Refresh the profile display
                this.updateUIForLoggedInUser(this.currentUser);
                this.hideEditProfile();
                this.showNotification('Profile updated successfully', 'success');
            } else {
                throw new Error(result.message || 'Failed to update profile');
            }
        } catch (error) {
            console.error('Profile update error:', error);
            this.showNotification('Failed to update profile: ' + error.message, 'error');
        }
    }

    togglePasswordVisibility() {
        // Handle login password field
        const loginPasswordInput = document.getElementById('login-password');
        const showPasswordCheckbox = document.getElementById('show-password');
        
        if (showPasswordCheckbox && loginPasswordInput) {
            loginPasswordInput.type = showPasswordCheckbox.checked ? 'text' : 'password';
        }
    }

    toggleEditPasswordVisibility() {
        // Handle edit profile password field
        const editPasswordInput = document.getElementById('edit-password');
        const showEditPasswordCheckbox = document.getElementById('show-edit-password');
        
        if (showEditPasswordCheckbox && editPasswordInput) {
            editPasswordInput.type = showEditPasswordCheckbox.checked ? 'text' : 'password';
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