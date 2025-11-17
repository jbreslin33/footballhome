/**
 * RoleSwitchboard Component
 * Main landing page after login that shows role cards for user to select
 */
class RoleSwitchboard extends Component {
    constructor(container, user = {}) {
        console.log('RoleSwitchboard: Constructor called with user:', user);
        
        try {
            super(container, { user });
            this.user = user || {};
            this.userRoles = [];
            console.log('RoleSwitchboard: Constructor completed successfully');
        } catch (error) {
            console.error('RoleSwitchboard: Constructor error:', error);
            throw error;
        }
    }

    render() {
        return `
            <div class="role-switchboard">
                <!-- Navigation Header -->
                <nav class="navbar">
                    <div class="navbar-brand">
                        <span class="brand-text">Football Home</span>
                    </div>
                    <div class="navbar-menu">
                        <span class="navbar-user">Welcome, ${this.user && this.user.name ? this.user.name : 'User'}</span>
                        <button id="logoutBtn" class="btn btn-secondary btn-sm">Logout</button>
                    </div>
                </nav>
                
                <!-- Main Content -->
                <main class="switchboard-main">
                    <div class="switchboard-header">
                        <h2 class="switchboard-title">Select Your Role</h2>
                        <p class="switchboard-subtitle">
                            Choose the role you want to access. Each role provides a different set of tools and information.
                        </p>
                    </div>
                    
                    <!-- Loading State -->
                    <div id="rolesLoading" class="loading-state">
                        <div class="loading-spinner"></div>
                        <p>Loading your roles...</p>
                    </div>
                    
                    <!-- Error State -->
                    <div id="rolesError" class="error-state" style="display: none;">
                        <div class="error-icon">⚠️</div>
                        <p class="error-message">Unable to load your roles. Please try again.</p>
                        <button id="retryBtn" class="btn btn-primary">Retry</button>
                    </div>
                    
                    <!-- Role Cards Grid -->
                    <div id="rolesGrid" class="roles-grid" style="display: none;">
                        <!-- Role cards will be populated dynamically -->
                    </div>
                </main>
            </div>
        `;
    }

    setupEventListeners() {
        // Setup logout functionality
        const logoutBtn = this.querySelector('#logoutBtn');
        if (logoutBtn) {
            this.addEventListener(logoutBtn, 'click', this.handleLogout);
        }

        // Setup retry functionality
        const retryBtn = this.querySelector('#retryBtn');
        if (retryBtn) {
            this.addEventListener(retryBtn, 'click', this.loadUserRoles);
        }
    }

    async onMounted() {
        console.log('RoleSwitchboard: onMounted called');
        
        try {
            // Load user roles from API
            await this.loadUserRoles();
            console.log('RoleSwitchboard: onMounted completed successfully');
        } catch (error) {
            console.error('RoleSwitchboard: onMounted error:', error);
            this.showErrorState('Failed to initialize role switchboard');
        }
    }

    async loadUserRoles() {
        console.log('RoleSwitchboard: Loading user roles...');
        
        try {
            this.showLoadingState();
            
            // Get user token from AuthService
            const authService = window.authService || new AuthService();
            const token = authService.getToken();
            
            if (!token) {
                throw new Error('No authentication token found');
            }

            // Fetch user roles from API
            const response = await fetch('/api/auth/me/roles', {
                method: 'GET',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            });

            if (!response.ok) {
                throw new Error(`API error: ${response.status} ${response.statusText}`);
            }

            const result = await response.json();
            console.log('RoleSwitchboard: API response:', result);

            if (!result.success || !result.data || !result.data.roles) {
                throw new Error('Invalid API response format');
            }

            this.userRoles = result.data.roles;
            this.renderRoleCards();
            this.showRolesGrid();
            
        } catch (error) {
            console.error('RoleSwitchboard: Error loading user roles:', error);
            this.showErrorState('Unable to load your roles. Please check your connection and try again.');
        }
    }

    renderRoleCards() {
        console.log('RoleSwitchboard: Rendering role cards for', this.userRoles.length, 'roles');
        
        const rolesGrid = this.querySelector('#rolesGrid');
        if (!rolesGrid) {
            console.error('RoleSwitchboard: Roles grid element not found');
            return;
        }

        // Group roles by type for better organization
        const rolesByType = this.groupRolesByType(this.userRoles);
        
        let cardsHTML = '';
        
        // Create cards for each role type
        Object.entries(rolesByType).forEach(([roleType, roles]) => {
            const roleInfo = this.getRoleTypeInfo(roleType);
            const teamCount = roles.length;
            
            cardsHTML += `
                <div class="role-card" data-role-type="${roleType}" data-roles='${JSON.stringify(roles)}'>
                    <div class="role-card-icon">
                        ${roleInfo.icon}
                    </div>
                    <div class="role-card-content">
                        <h3 class="role-card-title">${roleInfo.title}</h3>
                        <p class="role-card-description">${roleInfo.description}</p>
                        <div class="role-card-stats">
                            ${teamCount === 1 ? '1 Team' : `${teamCount} Teams`}
                        </div>
                    </div>
                    <div class="role-card-action">
                        <span class="role-card-arrow">→</span>
                    </div>
                </div>
            `;
        });
        
        rolesGrid.innerHTML = cardsHTML;
        
        // Setup click handlers for role cards
        this.setupRoleCardListeners();
    }

    groupRolesByType(roles) {
        return roles.reduce((groups, role) => {
            if (!groups[role.type]) {
                groups[role.type] = [];
            }
            groups[role.type].push(role);
            return groups;
        }, {});
    }

    getRoleTypeInfo(roleType) {
        const roleTypes = {
            player: {
                title: 'Player',
                description: 'View your team roster, upcoming games, and player statistics',
                icon: '⚽'
            },
            coach: {
                title: 'Coach', 
                description: 'Manage your team, schedule practices, and track player progress',
                icon: '📋'
            },
            admin: {
                title: 'Administrator',
                description: 'System administration and user management tools',
                icon: '⚙️'
            },
            parent: {
                title: 'Parent',
                description: 'View your child\'s team information and activities', 
                icon: '👨‍👩‍👧‍👦'
            },
            referee: {
                title: 'Referee',
                description: 'Manage match assignments and officiating schedule',
                icon: '🟨'
            }
        };
        
        return roleTypes[roleType] || {
            title: roleType.charAt(0).toUpperCase() + roleType.slice(1),
            description: `Manage your ${roleType} responsibilities`,
            icon: '👤'
        };
    }

    setupRoleCardListeners() {
        const roleCards = this.querySelectorAll('.role-card');
        roleCards.forEach(card => {
            this.addEventListener(card, 'click', () => {
                const roleType = card.dataset.roleType;
                const roles = JSON.parse(card.dataset.roles);
                this.handleRoleCardClick(roleType, roles);
            });
        });
    }

    handleRoleCardClick(roleType, roles) {
        console.log('RoleSwitchboard: Role card clicked:', roleType, roles);
        
        // Always show team selection screen (even with 1 team)
        // This allows users to see their team context and provides consistent UX
        this.navigateToTeamSelection(roleType, roles);
    }

    navigateToRoleDashboard(roleType, roleData) {
        console.log('RoleSwitchboard: Navigating to role dashboard:', roleType, roleData);
        
        // Emit event to parent to handle navigation
        this.emit('role:selected', {
            roleType: roleType,
            roleData: roleData,
            navigateTo: 'dashboard'
        });
    }

    navigateToTeamSelection(roleType, roles) {
        console.log('RoleSwitchboard: Navigating to team selection:', roleType, roles);
        
        // Emit event to parent to handle navigation
        this.emit('role:selected', {
            roleType: roleType,
            roles: roles,
            navigateTo: 'teamSelection'
        });
    }

    showLoadingState() {
        const loading = this.querySelector('#rolesLoading');
        const error = this.querySelector('#rolesError');
        const grid = this.querySelector('#rolesGrid');
        
        if (loading) loading.style.display = 'block';
        if (error) error.style.display = 'none';
        if (grid) grid.style.display = 'none';
    }

    showErrorState(message) {
        const loading = this.querySelector('#rolesLoading');
        const error = this.querySelector('#rolesError');
        const grid = this.querySelector('#rolesGrid');
        
        if (loading) loading.style.display = 'none';
        if (error) {
            error.style.display = 'block';
            const errorMessage = error.querySelector('.error-message');
            if (errorMessage && message) {
                errorMessage.textContent = message;
            }
        }
        if (grid) grid.style.display = 'none';
    }

    showRolesGrid() {
        const loading = this.querySelector('#rolesLoading');
        const error = this.querySelector('#rolesError');
        const grid = this.querySelector('#rolesGrid');
        
        if (loading) loading.style.display = 'none';
        if (error) error.style.display = 'none';
        if (grid) grid.style.display = 'block';
    }

    // Logout handler
    handleLogout() {
        console.log('RoleSwitchboard: Logout clicked');
        this.emit('user:logout');
    }

    // Update user data
    updateUser(userData) {
        this.user = { ...this.user, ...userData };
        // Reload roles if user data changed
        this.loadUserRoles();
    }

    // Cleanup method
    onUnmounted() {
        console.log('RoleSwitchboard: Component unmounted');
    }
}