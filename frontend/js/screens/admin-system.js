// AdminSystemScreen - Super Admin Dashboard
class AdminSystemScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.currentView = 'dashboard';
    this.dashboardData = null;
    this.users = [];
    this.admins = [];
    this.settings = [];
    this.features = [];
    this.auditLogs = [];
    this.apiUsage = [];
    this.importJobs = [];
    this.scraperLogs = [];
    this.notifications = [];
    this.lookupTables = [];
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-admin-system';
    
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🛡️ Super Admin Dashboard</h1>
        <p class="subtitle">System-level administration</p>
      </div>
      
      <div class="admin-container">
        <!-- Navigation Tabs -->
        <div class="admin-tabs">
          <button class="admin-tab active" data-view="dashboard">📊 Dashboard</button>
          <button class="admin-tab" data-view="users">👥 Users</button>
          <button class="admin-tab" data-view="identities">🔗 Identities</button>
          <button class="admin-tab" data-view="admins">🛡️ Admins</button>
          <button class="admin-tab" data-view="settings">⚙️ Settings</button>
          <button class="admin-tab" data-view="features">🎛️ Features</button>
          <button class="admin-tab" data-view="audit">📋 Audit Logs</button>
          <button class="admin-tab" data-view="api-usage">📡 API Usage</button>
          <button class="admin-tab" data-view="imports">📥 Import Jobs</button>
          <button class="admin-tab" data-view="scrapers">🕷️ Scrapers</button>
          <button class="admin-tab" data-view="notifications">🔔 Notifications</button>
          <button class="admin-tab" data-view="lookups">📚 Lookups</button>
        </div>
        
        <!-- Content Area -->
        <div class="admin-content">
          <div class="loading-indicator">Loading...</div>
        </div>
      </div>
    `;
    
    this.element = div;
    return div;
  }
  
  async onEnter(params) {
    this.setupEventListeners();
    await this.loadView(this.currentView);
  }
  
  setupEventListeners() {
    this.element.addEventListener('click', async (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
      }
      
      if (e.target.classList.contains('admin-tab')) {
        const view = e.target.dataset.view;
        this.switchView(view);
      }
      
      if (e.target.closest('.refresh-btn')) {
        await this.loadView(this.currentView);
      }
      
      if (e.target.closest('.toggle-feature')) {
        const key = e.target.closest('.toggle-feature').dataset.key;
        await this.toggleFeature(key);
      }
    });
  }
  
  switchView(view) {
    this.currentView = view;
    
    // Update active tab
    this.element.querySelectorAll('.admin-tab').forEach(tab => {
      tab.classList.toggle('active', tab.dataset.view === view);
    });
    
    this.loadView(view);
  }
  
  async loadView(view) {
    const content = this.element.querySelector('.admin-content');
    content.innerHTML = '<div class="loading-indicator">Loading...</div>';
    
    try {
      switch(view) {
        case 'dashboard':
          await this.loadDashboard();
          break;
        case 'users':
          await this.loadUsers();
          break;
        case 'identities':
          await this.loadIdentities();
          break;
        case 'admins':
          await this.loadAdmins();
          break;
        case 'settings':
          await this.loadSettings();
          break;
        case 'features':
          await this.loadFeatures();
          break;
        case 'audit':
          await this.loadAuditLogs();
          break;
        case 'api-usage':
          await this.loadApiUsage();
          break;
        case 'imports':
          await this.loadImportJobs();
          break;
        case 'scrapers':
          await this.loadScraperLogs();
          break;
        case 'notifications':
          await this.loadNotifications();
          break;
        case 'lookups':
          await this.loadLookupTables();
          break;
      }
    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading ${view}: ${error.message}</div>`;
    }
  }
  
  async loadDashboard() {
    const response = await fetch('/api/system-admin/dashboard');
    this.dashboardData = await response.json();
    
    const content = this.element.querySelector('.admin-content');
    content.innerHTML = `
      <div class="dashboard-view">
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-icon">👥</div>
            <div class="stat-value">${this.dashboardData.stats.active_users}</div>
            <div class="stat-label">Active Users</div>
          </div>
          <div class="stat-card">
            <div class="stat-icon">⚽</div>
            <div class="stat-value">${this.dashboardData.stats.active_teams}</div>
            <div class="stat-label">Active Teams</div>
          </div>
          <div class="stat-card">
            <div class="stat-icon">🏟️</div>
            <div class="stat-value">${this.dashboardData.stats.active_clubs}</div>
            <div class="stat-label">Active Clubs</div>
          </div>
          <div class="stat-card">
            <div class="stat-icon">📅</div>
            <div class="stat-value">${this.dashboardData.stats.upcoming_events}</div>
            <div class="stat-label">Upcoming Events</div>
          </div>
        </div>
      </div>
    `;
  }
  
  async loadUsers(offset = 0, limit = 100) {
    const response = await fetch(`/api/system-admin/users?limit=${limit}&offset=${offset}`);
    this.users = await response.json();
    this.usersOffset = offset;
    this.usersLimit = limit;
    
    const content = this.element.querySelector('.admin-content');
    content.innerHTML = `
      <div class="users-view">
        <div class="view-header">
          <h2>User Management</h2>
          <div class="view-actions">
            <button class="btn btn-secondary refresh-btn">🔄 Refresh</button>
          </div>
        </div>
        
        <div class="table-container">
          <table class="admin-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Status</th>
                <th>Created</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              ${this.users.map(user => `
                <tr>
                  <td>${user.first_name || ''} ${user.last_name || ''}</td>
                  <td>${user.email || '<em>No email</em>'}</td>
                  <td>${user.phone || '-'}</td>
                  <td>
                    <span class="badge ${user.is_active ? 'badge-success' : 'badge-danger'}">
                      ${user.is_active ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td><small>${new Date(user.created_at).toLocaleDateString()}</small></td>
                  <td>
                    <button class="btn btn-sm btn-primary edit-user" data-user-id="${user.id}">Edit</button>
                    <button class="btn btn-sm btn-secondary toggle-user-status" data-user-id="${user.id}" data-current-status="${user.is_active}">
                      ${user.is_active ? 'Deactivate' : 'Activate'}
                    </button>
                  </td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
        
        <div class="pagination-controls">
          <button class="btn btn-secondary prev-page" ${offset === 0 ? 'disabled' : ''}>← Previous</button>
          <span class="pagination-info">Showing ${offset + 1}-${offset + this.users.length} users</span>
          <button class="btn btn-secondary next-page" ${this.users.length < limit ? 'disabled' : ''}>Next →</button>
        </div>
      </div>
    `;
    
    // Event listeners
    this.element.querySelector('.refresh-btn')?.addEventListener('click', () => this.loadUsers(offset, limit));
    this.element.querySelector('.prev-page')?.addEventListener('click', () => this.loadUsers(Math.max(0, offset - limit), limit));
    this.element.querySelector('.next-page')?.addEventListener('click', () => this.loadUsers(offset + limit, limit));
    
    this.element.querySelectorAll('.toggle-user-status').forEach(btn => {
      btn.addEventListener('click', async (e) => {
        const userId = e.target.dataset.userId;
        const currentStatus = e.target.dataset.currentStatus === 'true';
        await this.toggleUserStatus(userId, currentStatus);
      });
    });
    
    this.element.querySelectorAll('.edit-user').forEach(btn => {
      btn.addEventListener('click', async (e) => {
        const userId = e.target.dataset.userId;
        await this.showEditUserModal(userId);
      });
    });
  }
  
  async toggleUserStatus(userId, currentStatus) {
    if (!confirm(`Are you sure you want to ${currentStatus ? 'deactivate' : 'activate'} this user?`)) {
      return;
    }
    
    try {
      const response = await fetch(`/api/system-admin/users/${userId}/status`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' }
      });
      
      if (response.ok) {
        await this.loadUsers(this.usersOffset, this.usersLimit);
      } else {
        alert('Failed to update user status');
      }
    } catch (error) {
      console.error('Error toggling user status:', error);
      alert('Error toggling user status');
    }
  }
  
  async loadIdentities() {
    // Initialize filters if not exists
    if (!this.identityFilters) {
      this.identityFilters = {
        team_id: '',
        club_id: '',
        provider_id: '',
        linked: 'false' // Default to unlinked
      };
    }

    const content = this.element.querySelector('.admin-content');
    content.innerHTML = `
      <div class="identities-view">
        <div class="view-header">
          <h2>🔗 Identity Management</h2>
          <p>Connect external accounts (GroupMe, etc.) to system users.</p>
        </div>
        
        <!-- Filters -->
        <div class="filters-bar" style="display: flex; gap: 10px; margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-radius: 8px;">
          <select id="filter-team" class="form-control">
            <option value="">All Teams</option>
          </select>
          <select id="filter-club" class="form-control">
            <option value="">All Clubs</option>
          </select>
          <select id="filter-provider" class="form-control">
            <option value="">All Providers</option>
            <option value="1">GroupMe</option>
          </select>
          <select id="filter-linked" class="form-control">
            <option value="">All Status</option>
            <option value="false" selected>Unlinked Only</option>
            <option value="true">Linked Only</option>
          </select>
          <button id="apply-filters" class="btn btn-primary">Apply Filters</button>
        </div>

        <!-- Split View -->
        <div class="split-view-container" style="display: flex; gap: 20px; height: 600px;">
          <!-- Left Pane: Identities -->
          <div class="split-pane left-pane" style="flex: 1; display: flex; flex-direction: column; border: 1px solid #ddd; border-radius: 8px; overflow: hidden;">
            <div class="pane-header" style="padding: 10px; background: #eee; border-bottom: 1px solid #ddd;">
              <div style="display:flex; justify-content:space-between; align-items:center;">
                <div>
                  <h3 style="margin: 0; font-size: 1.1em;">1. Select Source</h3>
                  <small class="text-muted">External accounts</small>
                </div>
                <select id="sort-identities" class="form-control form-control-sm" style="width:auto; font-size: 0.8em;">
                  <option value="name_asc">Name A-Z</option>
                  <option value="name_desc">Name Z-A</option>
                  <option value="team">Team</option>
                </select>
              </div>
            </div>
            <div id="identities-list" class="list-group" style="flex: 1; overflow-y: auto; padding: 10px;">
              <div class="loading-indicator">Loading...</div>
            </div>
          </div>
          
          <!-- Center Action Area (Visual Only) -->
          <div style="display: flex; align-items: center; justify-content: center; width: 40px;">
            <div style="font-size: 24px; color: #999;">➔</div>
          </div>
          
          <!-- Right Pane: Users -->
          <div class="split-pane right-pane" style="flex: 1; display: flex; flex-direction: column; border: 1px solid #ddd; border-radius: 8px; overflow: hidden;">
            <div class="pane-header" style="padding: 10px; background: #eee; border-bottom: 1px solid #ddd; display: flex; justify-content: space-between; align-items: center;">
              <div>
                <h3 style="margin: 0; font-size: 1.1em;">2. Select Target</h3>
                <small class="text-muted">System User</small>
              </div>
              <button id="btn-create-user" class="btn btn-sm btn-success">+ New</button>
            </div>
            <div style="padding: 10px; background: #f8f9fa; border-bottom: 1px solid #ddd; display: flex; flex-direction: column; gap: 8px;">
               <div style="display: flex; gap: 5px;">
                 <select id="user-target-team-filter" class="form-control form-control-sm">
                   <option value="">All Teams (Target)</option>
                 </select>
                 <select id="user-target-sort" class="form-control form-control-sm" style="width: 120px;">
                   <option value="last_name_asc">Name A-Z</option>
                   <option value="last_name_desc">Name Z-A</option>
                   <option value="email">Email</option>
                   <option value="created_at">Newest</option>
                 </select>
               </div>
               <input type="text" id="user-target-search" placeholder="Search users..." class="form-control" style="width: 100%;">
            </div>
            <div id="users-list" class="list-group" style="flex: 1; overflow-y: auto; padding: 10px;">
              <div class="loading-indicator">Loading...</div>
            </div>
          </div>
        </div>
      </div>
    `;
    
    // Load initial data
    await this.fetchFilterOptions();
    await this.fetchIdentities();
    await this.fetchUsersForLinking();
    
    this.setupIdentityEventListeners();
  }

  async fetchFilterOptions() {
    try {
      // Fetch teams
      const teamsRes = await fetch('/api/teams');
      const response = await teamsRes.json();
      const teams = response.data || []; // Handle { data: [...] } format
      
      const teamSelect = this.element.querySelector('#filter-team');
      const targetTeamSelect = this.element.querySelector('#user-target-team-filter');
      
      // Clear existing options except first
      while (teamSelect.options.length > 1) teamSelect.remove(1);
      while (targetTeamSelect.options.length > 1) targetTeamSelect.remove(1);
      
      teams.forEach(t => {
        // Main filter
        const opt = document.createElement('option');
        opt.value = t.id;
        opt.textContent = t.name;
        teamSelect.appendChild(opt);
        
        // Target filter
        const opt2 = document.createElement('option');
        opt2.value = t.id;
        opt2.textContent = t.name;
        targetTeamSelect.appendChild(opt2);
      });

      // Fetch clubs (mock for now or fetch if endpoint exists)
      // const clubsRes = await fetch('/api/clubs');
      // ...
    } catch (e) {
      console.error('Error loading filter options:', e);
    }
  }

  async fetchIdentities() {
    const list = this.element.querySelector('#identities-list');
    list.innerHTML = '<div class="loading-indicator">Loading...</div>';
    
    try {
      const params = new URLSearchParams(this.identityFilters);
      const response = await fetch(`/api/system-admin/identities?${params}`);
      let identities = await response.json();
      
      // Client-side sorting
      const sortMode = this.element.querySelector('#sort-identities')?.value || 'name_asc';
      identities.sort((a, b) => {
          const nameA = (a.external_username || a.external_id).toLowerCase();
          const nameB = (b.external_username || b.external_id).toLowerCase();
          
          if (sortMode === 'name_asc') return nameA.localeCompare(nameB);
          if (sortMode === 'name_desc') return nameB.localeCompare(nameA);
          if (sortMode === 'team') {
              const teamA = (a.team_name || '').toLowerCase();
              const teamB = (b.team_name || '').toLowerCase();
              return teamA.localeCompare(teamB) || nameA.localeCompare(nameB);
          }
          return 0;
      });

      if (identities.length === 0) {
        list.innerHTML = '<div class="empty-state">No identities found</div>';
        return;
      }
      
      list.innerHTML = identities.map(id => `
        <div class="identity-item" data-id="${id.id}" style="padding: 10px; border-bottom: 1px solid #eee; cursor: pointer;">
          <div style="font-weight: bold;">${id.external_username || id.external_id}</div>
          <div style="font-size: 0.9em; color: #666;">
            ${id.provider_name} • ${id.team_name || 'No Team'}
          </div>
          ${id.user_id ? `<div style="font-size: 0.8em; color: green;">Linked to: ${id.user_first} ${id.user_last}</div>` : ''}
        </div>
      `).join('');
      
      // Add click selection
      list.querySelectorAll('.identity-item').forEach(item => {
        item.addEventListener('click', () => {
          list.querySelectorAll('.identity-item').forEach(i => i.style.background = 'none');
          item.style.background = '#e3f2fd';
          this.selectedIdentityId = item.dataset.id;
        });
      });
      
    } catch (e) {
      list.innerHTML = `<div class="error">Error: ${e.message}</div>`;
    }
  }

  async fetchUsersForLinking() {
    const list = this.element.querySelector('#users-list');
    list.innerHTML = '<div class="loading-indicator">Loading users...</div>';
    
    try {
      // Build query params
      const params = new URLSearchParams();
      params.append('limit', '50');
      
      // Use Right Pane specific filters if available
      const targetTeamFilter = this.element.querySelector('#user-target-team-filter');
      const targetSort = this.element.querySelector('#user-target-sort');
      
      if (targetTeamFilter && targetTeamFilter.value) {
          params.append('team_id', targetTeamFilter.value);
      } else if (this.identityFilters.team_id) {
          // Fallback to main filter if right filter is "All" (or maybe we shouldn't? 
          // If user explicitly selects "All" on right, they want all. 
          // But initially it's empty. Let's rely on the sync logic in Apply Filters)
          // Actually, let's NOT fallback. If the right filter is empty, it means "All Teams".
          // The "Apply Filters" button will sync them.
      }

      if (this.identityFilters.club_id) {
        params.append('club_id', this.identityFilters.club_id);
      }
      
      // Sorting
      if (targetSort) {
          const [field, order] = targetSort.value.split('_'); // e.g. "last_name_asc" -> "last", "name", "asc" oops.
          // Fix split logic
          let sortBy = 'last_name';
          let sortOrder = 'asc';
          
          if (targetSort.value === 'email') { sortBy = 'email'; sortOrder = 'asc'; }
          else if (targetSort.value === 'created_at') { sortBy = 'created_at'; sortOrder = 'desc'; }
          else if (targetSort.value.includes('_desc')) { 
              sortBy = targetSort.value.replace('_desc', ''); 
              sortOrder = 'desc'; 
          } else if (targetSort.value.includes('_asc')) {
              sortBy = targetSort.value.replace('_asc', '');
              sortOrder = 'asc';
          }
          
          params.append('sort_by', sortBy);
          params.append('sort_order', sortOrder);
      }
      
      // Check for search term
      const searchInput = this.element.querySelector('#user-target-search');
      if (searchInput && searchInput.value) {
          params.append('q', searchInput.value);
      }
      
      const response = await fetch(`/api/system-admin/users?${params.toString()}`);
      const data = await response.json();
      const users = data.users || [];
      
      this.renderUsersList(users);
    } catch (e) {
      list.innerHTML = `<div class="error">Error: ${e.message}</div>`;
    }
  }

  renderUsersList(users) {
    const list = this.element.querySelector('#users-list');
    list.innerHTML = users.map(u => `
      <div class="user-item" data-id="${u.id}" style="padding: 10px; border-bottom: 1px solid #eee; cursor: pointer; display: flex; justify-content: space-between; align-items: center;">
        <div>
          <div style="font-weight: bold;">${u.first_name || ''} ${u.last_name || ''}</div>
          <div style="font-size: 0.9em; color: #666;">${u.email || 'No email'}</div>
          <div style="font-size: 0.8em; color: #999;">Created: ${new Date(u.created_at).toLocaleDateString()}</div>
        </div>
        <button class="btn btn-sm btn-outline-primary link-btn">Link</button>
      </div>
    `).join('');
    
    list.querySelectorAll('.link-btn').forEach(btn => {
      btn.addEventListener('click', async (e) => {
        e.stopPropagation();
        const userId = e.target.closest('.user-item').dataset.id;
        if (this.selectedIdentityId) {
            if (confirm('Link selected identity to this user?')) {
                await this.linkIdentity(this.selectedIdentityId, userId);
            }
        } else {
            alert('Please select an identity from the left list first.');
        }
      });
    });
  }

  setupIdentityEventListeners() {
    this.element.querySelector('#apply-filters').addEventListener('click', () => {
      this.identityFilters.team_id = this.element.querySelector('#filter-team').value;
      this.identityFilters.club_id = this.element.querySelector('#filter-club').value;
      this.identityFilters.provider_id = this.element.querySelector('#filter-provider').value;
      this.identityFilters.linked = this.element.querySelector('#filter-linked').value;
      
      // Sync Right Filter to match Left Filter initially
      const targetTeamFilter = this.element.querySelector('#user-target-team-filter');
      if (targetTeamFilter) {
          targetTeamFilter.value = this.identityFilters.team_id;
      }
      
      // Refresh both lists
      this.fetchIdentities();
      this.fetchUsersForLinking();
    });

    // Debounce search
    let searchTimeout;
    this.element.querySelector('#user-target-search').addEventListener('input', (e) => {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            this.fetchUsersForLinking();
        }, 300);
    });
    
    // New Listeners for Right Pane controls
    this.element.querySelector('#user-target-team-filter')?.addEventListener('change', () => {
        this.fetchUsersForLinking();
    });
    
    this.element.querySelector('#user-target-sort')?.addEventListener('change', () => {
        this.fetchUsersForLinking();
    });
    
    // New Listener for Left Pane sort
    this.element.querySelector('#sort-identities')?.addEventListener('change', () => {
        this.fetchIdentities(); // Re-fetches and sorts client-side
    });

    this.element.querySelector('#btn-create-user').addEventListener('click', () => {
        this.showCreateUserModal();
    });
  }

  async showCreateUserModal() {
      // Pre-fill if identity selected
      let prefill = {};
      if (this.selectedIdentityId) {
          const item = this.element.querySelector(`.identity-item[data-id="${this.selectedIdentityId}"]`);
          if (item) {
              // Try to parse name "First Last"
              const name = item.querySelector('div').innerText.trim();
              const parts = name.split(' ');
              if (parts.length > 1) {
                  prefill.first_name = parts[0];
                  prefill.last_name = parts.slice(1).join(' ');
              } else {
                  prefill.first_name = name;
              }
          }
      }

      const modal = document.createElement('div');
      modal.className = 'modal-overlay';
      modal.innerHTML = `
        <div class="modal-content">
          <div class="modal-header">
            <h2>Create New User</h2>
            <button class="modal-close">&times;</button>
          </div>
          <form class="create-user-form">
            <div class="form-group">
              <label>First Name</label>
              <input type="text" name="first_name" value="${prefill.first_name || ''}" required>
            </div>
            <div class="form-group">
              <label>Last Name</label>
              <input type="text" name="last_name" value="${prefill.last_name || ''}" required>
            </div>
            <div class="form-group">
              <label>Email (Optional)</label>
              <input type="email" name="email" placeholder="user@example.com">
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary modal-cancel">Cancel</button>
              <button type="submit" class="btn btn-primary">Create User</button>
            </div>
          </form>
        </div>
      `;
      document.body.appendChild(modal);

      const closeModal = () => modal.remove();
      modal.querySelector('.modal-close').addEventListener('click', closeModal);
      modal.querySelector('.modal-cancel').addEventListener('click', closeModal);

      modal.querySelector('form').addEventListener('submit', async (e) => {
          e.preventDefault();
          const formData = new FormData(e.target);
          const data = {
              first_name: formData.get('first_name'),
              last_name: formData.get('last_name'),
              email: formData.get('email')
          };

          try {
              // TODO: Implement POST /api/system-admin/users
              // For now, alert
              alert('Create User API not yet implemented. This is a UI demo.');
              closeModal();
          } catch (err) {
              alert('Error: ' + err.message);
          }
      });
  }



  async linkIdentity(identityId, userId) {
    try {
      const response = await fetch('/api/system-admin/identities/link', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ identityId, userId })
      });
      
      if (response.ok) {
        alert('Identity linked successfully! SQL file updated.');
        this.loadIdentities();
      } else {
        const err = await response.json();
        alert('Failed to link: ' + err.error);
      }
    } catch (error) {
      alert('Error linking identity: ' + error.message);
    }
  }

  async showEditUserModal(userId) {
    try {
      // Fetch user details
      const response = await fetch(`/api/system-admin/users/${userId}`);
      if (!response.ok) {
        alert('Failed to load user details');
        return;
      }
      
      const user = await response.json();
      
      // Create modal
      const modal = document.createElement('div');
      modal.className = 'modal-overlay';
      modal.innerHTML = `
        <div class="modal-content">
          <div class="modal-header">
            <h2>Edit User</h2>
            <button class="modal-close">&times;</button>
          </div>
          <form class="edit-user-form">
            <div class="form-group">
              <label for="edit-first-name">First Name</label>
              <input type="text" id="edit-first-name" name="first_name" value="${user.first_name || ''}" required>
            </div>
            <div class="form-group">
              <label for="edit-last-name">Last Name</label>
              <input type="text" id="edit-last-name" name="last_name" value="${user.last_name || ''}" required>
            </div>
            <div class="form-group">
              <label for="edit-email">Email</label>
              <input type="email" id="edit-email" name="email" value="${user.email || ''}" required>
            </div>
            <div class="form-group">
              <label for="edit-phone">Phone</label>
              <input type="tel" id="edit-phone" name="phone" value="${user.phone || ''}">
            </div>
            <div class="form-group">
              <label for="edit-dob">Date of Birth</label>
              <input type="date" id="edit-dob" name="date_of_birth" value="${user.date_of_birth || ''}">
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary modal-cancel">Cancel</button>
              <button type="submit" class="btn btn-primary">Save Changes</button>
            </div>
          </form>
        </div>
      `;
      
      document.body.appendChild(modal);
      
      // Event listeners
      const closeModal = () => {
        modal.remove();
      };
      
      modal.querySelector('.modal-close').addEventListener('click', closeModal);
      modal.querySelector('.modal-cancel').addEventListener('click', closeModal);
      modal.addEventListener('click', (e) => {
        if (e.target === modal) closeModal();
      });
      
      modal.querySelector('.edit-user-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const formData = new FormData(e.target);
        const userData = {
          first_name: formData.get('first_name'),
          last_name: formData.get('last_name'),
          email: formData.get('email'),
          phone: formData.get('phone'),
          date_of_birth: formData.get('date_of_birth')
        };
        
        try {
          const updateResponse = await fetch(`/api/system-admin/users/${userId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(userData)
          });
          
          if (updateResponse.ok) {
            alert('User updated successfully');
            closeModal();
            await this.loadUsers(this.usersOffset, this.usersLimit);
          } else {
            alert('Failed to update user');
          }
        } catch (error) {
          console.error('Error updating user:', error);
          alert('Error updating user');
        }
      });
      
    } catch (error) {
      console.error('Error showing edit modal:', error);
      alert('Error loading user details');
    }
  }
  
  async loadAdmins() {
    const response = await fetch('/api/system-admin/admins');
    this.admins = await response.json();
    
    const content = this.element.querySelector('.admin-content');
    content.innerHTML = `
      <div class="admins-view">
        <div class="view-header">
          <h2>System Administrators</h2>
          <button class="btn btn-secondary refresh-btn">🔄 Refresh</button>
        </div>
        
        <div class="table-container">
          <table class="admin-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Appointed By</th>
                <th>Status</th>
                <th>Notes</th>
              </tr>
            </thead>
            <tbody>
              ${this.admins.map(admin => `
                <tr>
                  <td>${admin.first_name || ''} ${admin.last_name || ''}</td>
                  <td>${admin.email || '<em>No email</em>'}</td>
                  <td>${admin.appointer_first_name && admin.appointer_last_name ? 
                       `${admin.appointer_first_name} ${admin.appointer_last_name}` : 
                       '<em>System</em>'}</td>
                  <td>
                    <span class="badge ${admin.is_active ? 'badge-success' : 'badge-danger'}">
                      ${admin.is_active ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td><small>${admin.notes || ''}</small></td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
        
        <div class="pagination-info">
          ${this.admins.length} system administrator(s)
        </div>
      </div>
    `;
  }
  
  async loadSettings() {
    const response = await fetch('/api/system-admin/settings');
    this.settings = await response.json();
    
    // Group settings by category
    const categories = {};
    this.settings.forEach(setting => {
      if (!categories[setting.category]) {
        categories[setting.category] = [];
      }
      categories[setting.category].push(setting);
    });
    
    const content = this.element.querySelector('.admin-content');
    content.innerHTML = `
      <div class="settings-view">
        <div class="view-header">
          <h2>System Settings</h2>
          <button class="btn btn-secondary refresh-btn">🔄 Refresh</button>
        </div>
        
        ${Object.entries(categories).map(([category, settings]) => `
          <div class="settings-category">
            <h3>${category.replace('_', ' ').toUpperCase()}</h3>
            <div class="settings-list">
              ${settings.map(setting => `
                <div class="setting-item">
                  <div class="setting-info">
                    <strong>${setting.display_name}</strong>
                    <small>${setting.description}</small>
                  </div>
                  <div class="setting-value">
                    ${setting.is_sensitive ? 
                      '<span class="sensitive-value">********</span>' : 
                      `<code>${setting.value}</code>`}
                  </div>
                </div>
              `).join('')}
            </div>
          </div>
        `).join('')}
      </div>
    `;
  }
  
  async loadFeatures() {
    const response = await fetch('/api/system-admin/features');
    this.features = await response.json();
    
    // Group features by category
    const categories = {};
    this.features.forEach(feature => {
      if (!categories[feature.category]) {
        categories[feature.category] = [];
      }
      categories[feature.category].push(feature);
    });
    
    const content = this.element.querySelector('.admin-content');
    content.innerHTML = `
      <div class="features-view">
        <div class="view-header">
          <h2>Feature Flags</h2>
          <button class="btn btn-secondary refresh-btn">🔄 Refresh</button>
        </div>
        
        ${Object.entries(categories).map(([category, features]) => `
          <div class="features-category">
            <h3>${category.replace(/_/g, ' ').toUpperCase()}</h3>
            <div class="features-list">
              ${features.map(feature => `
                <div class="feature-item">
                  <div class="feature-info">
                    <div class="feature-header">
                      <strong>${feature.name}</strong>
                      ${feature.requires_restart ? '<span class="badge badge-warning">Requires Restart</span>' : ''}
                    </div>
                    <small>${feature.description}</small>
                  </div>
                  <label class="toggle-switch">
                    <input type="checkbox" 
                           class="toggle-feature" 
                           data-key="${feature.key}"
                           ${feature.is_enabled ? 'checked' : ''}>
                    <span class="toggle-slider"></span>
                  </label>
                </div>
              `).join('')}
            </div>
          </div>
        `).join('')}
      </div>
    `;
  }
  
  async loadAuditLogs() {
    const response = await fetch('/api/system-admin/audit-logs?limit=50');
    this.auditLogs = await response.json();
    
    const content = this.element.querySelector('.admin-content');
    content.innerHTML = `
      <div class="audit-view">
        <div class="view-header">
          <h2>Audit Logs</h2>
          <button class="btn btn-secondary refresh-btn">🔄 Refresh</button>
        </div>
        
        ${this.auditLogs.length === 0 ? 
          '<div class="empty-state">No audit logs yet</div>' :
          `<div class="table-container">
            <table class="admin-table">
              <thead>
                <tr>
                  <th>Timestamp</th>
                  <th>Admin</th>
                  <th>Action</th>
                  <th>Entity</th>
                  <th>Details</th>
                </tr>
              </thead>
              <tbody>
                ${this.auditLogs.map(log => `
                  <tr>
                    <td>${new Date(log.created_at).toLocaleString()}</td>
                    <td>${log.admin_name || log.admin_email || 'System'}</td>
                    <td><span class="badge badge-info">${log.action_type}</span></td>
                    <td>${log.entity_type || 'N/A'}</td>
                    <td><small>${log.entity_id || ''}</small></td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>`
        }
        
        <div class="pagination-info">
          ${this.auditLogs.length} log entries
        </div>
      </div>
    `;
  }
  
  async loadApiUsage() {
    const response = await fetch('/api/system-admin/api-usage?limit=50');
    this.apiUsage = await response.json();
    
    const content = this.element.querySelector('.admin-content');
    content.innerHTML = `
      <div class="admin-section">
        <div class="section-header">
          <h2>📡 API Usage Log</h2>
          <button class="btn btn-secondary refresh-btn">🔄 Refresh</button>
        </div>
        
        ${this.apiUsage.length === 0 ? '<p class="empty-state">No API usage logs yet</p>' : `
          <div class="table-container">
            <table class="admin-table">
              <thead>
                <tr>
                  <th>Timestamp</th>
                  <th>User</th>
                  <th>Endpoint</th>
                  <th>Method</th>
                  <th>Status</th>
                  <th>Duration</th>
                </tr>
              </thead>
              <tbody>
                ${this.apiUsage.map(log => `
                  <tr>
                    <td><small>${new Date(log.created_at).toLocaleString()}</small></td>
                    <td>${log.user_id ? log.user_id.substring(0, 8) + '...' : 'Anonymous'}</td>
                    <td><code>${log.endpoint}</code></td>
                    <td><span class="badge badge-info">${log.http_method}</span></td>
                    <td><span class="badge ${log.status_code < 400 ? 'badge-success' : 'badge-danger'}">${log.status_code}</span></td>
                    <td>${log.duration_ms}ms</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>`
        }
      </div>
    `;
    
    this.element.querySelector('.refresh-btn')?.addEventListener('click', () => this.loadApiUsage());
  }
  
  async loadImportJobs() {
    const response = await fetch('/api/system-admin/imports?limit=50');
    this.importJobs = await response.json();
    
    const content = this.element.querySelector('.admin-content');
    content.innerHTML = `
      <div class="admin-section">
        <div class="section-header">
          <h2>📥 Data Import Jobs</h2>
          <button class="btn btn-secondary refresh-btn">🔄 Refresh</button>
        </div>
        
        ${this.importJobs.length === 0 ? '<p class="empty-state">No import jobs yet</p>' : `
          <div class="table-container">
            <table class="admin-table">
              <thead>
                <tr>
                  <th>Started</th>
                  <th>Job Type</th>
                  <th>Entity</th>
                  <th>Status</th>
                  <th>Progress</th>
                  <th>Duration</th>
                </tr>
              </thead>
              <tbody>
                ${this.importJobs.map(job => {
                  const duration = job.completed_at ? 
                    Math.round((new Date(job.completed_at) - new Date(job.started_at)) / 1000) : '...';
                  return `
                    <tr>
                      <td><small>${new Date(job.started_at).toLocaleString()}</small></td>
                      <td>${job.job_type}</td>
                      <td>${job.entity_type}</td>
                      <td><span class="badge badge-${job.status === 'completed' ? 'success' : job.status === 'failed' ? 'danger' : 'warning'}">${job.status}</span></td>
                      <td>${job.processed_records}/${job.total_records} (${job.successful_records} ✓, ${job.failed_records} ✗)</td>
                      <td>${duration}s</td>
                    </tr>
                  `;
                }).join('')}
              </tbody>
            </table>
          </div>`
        }
      </div>
    `;
    
    this.element.querySelector('.refresh-btn')?.addEventListener('click', () => this.loadImportJobs());
  }
  
  async loadScraperLogs() {
    const response = await fetch('/api/system-admin/scrapers?limit=50');
    this.scraperLogs = await response.json();
    
    const content = this.element.querySelector('.admin-content');
    content.innerHTML = `
      <div class="admin-section">
        <div class="section-header">
          <h2>🕷️ Scraper Execution Logs</h2>
          <button class="btn btn-secondary refresh-btn">🔄 Refresh</button>
        </div>
        
        ${this.scraperLogs.length === 0 ? '<p class="empty-state">No scraper logs yet</p>' : `
          <div class="table-container">
            <table class="admin-table">
              <thead>
                <tr>
                  <th>Started</th>
                  <th>Scraper</th>
                  <th>Mode</th>
                  <th>Status</th>
                  <th>Results</th>
                  <th>Errors</th>
                  <th>Duration</th>
                </tr>
              </thead>
              <tbody>
                ${this.scraperLogs.map(log => `
                  <tr>
                    <td><small>${new Date(log.started_at).toLocaleString()}</small></td>
                    <td><strong>${log.scraper_name}</strong></td>
                    <td>${log.execution_mode || 'full'}</td>
                    <td><span class="badge badge-${log.status === 'completed' ? 'success' : log.status === 'failed' ? 'danger' : 'warning'}">${log.status}</span></td>
                    <td>T:${log.teams_scraped} P:${log.players_scraped} M:${log.matches_scraped}</td>
                    <td>${log.errors_count > 0 ? '<span class="badge badge-danger">' + log.errors_count + '</span>' : '0'}</td>
                    <td>${log.duration_seconds || '...'}s</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>`
        }
      </div>
    `;
    
    this.element.querySelector('.refresh-btn')?.addEventListener('click', () => this.loadScraperLogs());
  }
  
  async loadNotifications() {
    const response = await fetch('/api/system-admin/notifications');
    this.notifications = await response.json();
    
    const content = this.element.querySelector('.admin-content');
    content.innerHTML = `
      <div class="admin-section">
        <div class="section-header">
          <h2>🔔 System Notifications</h2>
          <button class="btn btn-secondary refresh-btn">🔄 Refresh</button>
        </div>
        
        ${this.notifications.length === 0 ? '<p class="empty-state">No notifications configured</p>' : `
          <div class="table-container">
            <table class="admin-table">
              <thead>
                <tr>
                  <th>Type</th>
                  <th>Title</th>
                  <th>Message</th>
                  <th>Audience</th>
                  <th>Priority</th>
                  <th>Status</th>
                  <th>Schedule</th>
                </tr>
              </thead>
              <tbody>
                ${this.notifications.map(notif => `
                  <tr>
                    <td>${notif.notification_type}</td>
                    <td><strong>${notif.title}</strong></td>
                    <td><small>${notif.message.substring(0, 50)}${notif.message.length > 50 ? '...' : ''}</small></td>
                    <td>${notif.target_audience}</td>
                    <td><span class="badge badge-${notif.priority === 'high' ? 'danger' : notif.priority === 'medium' ? 'warning' : 'info'}">${notif.priority}</span></td>
                    <td><span class="badge badge-${notif.is_active ? 'success' : 'secondary'}">${notif.is_active ? 'Active' : 'Inactive'}</span></td>
                    <td><small>${notif.starts_at ? new Date(notif.starts_at).toLocaleDateString() : 'Now'} - ${notif.ends_at ? new Date(notif.ends_at).toLocaleDateString() : 'Ongoing'}</small></td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>`
        }
      </div>
    `;
    
    this.element.querySelector('.refresh-btn')?.addEventListener('click', () => this.loadNotifications());
  }
  
  async loadLookupTables() {
    const response = await fetch('/api/system-admin/lookups');
    this.lookupTables = await response.json();
    
    const content = this.element.querySelector('.admin-content');
    content.innerHTML = `
      <div class="admin-section">
        <div class="section-header">
          <h2>📚 Lookup Tables</h2>
          <button class="btn btn-secondary refresh-btn">🔄 Refresh</button>
        </div>
        
        <div class="lookup-tables-grid">
          ${this.lookupTables.map(table => `
            <div class="lookup-table-card" data-table="${table.table_name}">
              <h3>${table.table_name}</h3>
              <button class="btn btn-sm btn-primary view-lookup-btn" data-table="${table.table_name}">View Entries</button>
            </div>
          `).join('')}
        </div>
        
        <div id="lookup-entries-container" style="margin-top: 2rem;"></div>
      </div>
    `;
    
    this.element.querySelector('.refresh-btn')?.addEventListener('click', () => this.loadLookupTables());
    
    this.element.querySelectorAll('.view-lookup-btn').forEach(btn => {
      btn.addEventListener('click', async (e) => {
        const tableName = e.target.dataset.table;
        await this.viewLookupEntries(tableName);
      });
    });
  }
  
  async viewLookupEntries(tableName) {
    const response = await fetch(`/api/system-admin/lookups/${tableName}`);
    const entries = await response.json();
    
    const container = this.element.querySelector('#lookup-entries-container');
    container.innerHTML = `
      <h3>Entries in: ${tableName}</h3>
      <div class="table-container">
        <table class="admin-table">
          <thead>
            <tr>
              ${Object.keys(entries[0] || {}).map(key => `<th>${key}</th>`).join('')}
            </tr>
          </thead>
          <tbody>
            ${entries.map(entry => `
              <tr>
                ${Object.values(entry).map(val => `
                  <td>${typeof val === 'boolean' ? (val ? '✓' : '✗') : (val || 'N/A')}</td>
                `).join('')}
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    `;
  }
  
  async toggleFeature(key) {
    try {
      const response = await fetch(`/api/system-admin/features/${key}/toggle`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' }
      });
      
      if (response.ok) {
        await this.loadFeatures();
      } else {
        alert('Failed to toggle feature flag');
      }
    } catch (error) {
      console.error('Error toggling feature:', error);
      alert('Error toggling feature flag');
    }
  }
  
  async showEditUserModal(userId) {
    try {
      // Fetch user details
      const response = await fetch(`/api/system-admin/users/${userId}`);
      if (!response.ok) {
        alert('Failed to fetch user details');
        return;
      }
      
      const user = await response.json();
      
      // Create modal overlay
      const modal = document.createElement('div');
      modal.className = 'modal-overlay';
      modal.innerHTML = `
        <div class="modal-content">
          <div class="modal-header">
            <h2>Edit User</h2>
            <button class="modal-close">&times;</button>
          </div>
          
          <form class="edit-user-form">
            <div class="form-group">
              <label for="edit-first-name">First Name</label>
              <input type="text" id="edit-first-name" name="first_name" value="${user.first_name || ''}" required>
            </div>
            
            <div class="form-group">
              <label for="edit-last-name">Last Name</label>
              <input type="text" id="edit-last-name" name="last_name" value="${user.last_name || ''}" required>
            </div>
            
            <div class="form-group">
              <label for="edit-email">Email</label>
              <input type="email" id="edit-email" name="email" value="${user.email || ''}">
            </div>
            
            <div class="form-group">
              <label for="edit-phone">Phone</label>
              <input type="tel" id="edit-phone" name="phone" value="${user.phone || ''}">
            </div>
            
            <div class="form-group">
              <label for="edit-dob">Date of Birth</label>
              <input type="date" id="edit-dob" name="date_of_birth" value="${user.date_of_birth || ''}">
            </div>
            
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary cancel-btn">Cancel</button>
              <button type="submit" class="btn btn-primary">Save Changes</button>
            </div>
          </form>
        </div>
      `;
      
      document.body.appendChild(modal);
      
      // Close modal handlers
      const closeModal = () => {
        modal.remove();
      };
      
      modal.querySelector('.modal-close').addEventListener('click', closeModal);
      modal.querySelector('.cancel-btn').addEventListener('click', closeModal);
      modal.addEventListener('click', (e) => {
        if (e.target === modal) closeModal();
      });
      
      // Form submit handler
      modal.querySelector('.edit-user-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const formData = {
          first_name: document.getElementById('edit-first-name').value,
          last_name: document.getElementById('edit-last-name').value,
          email: document.getElementById('edit-email').value,
          phone: document.getElementById('edit-phone').value,
          date_of_birth: document.getElementById('edit-dob').value
        };
        
        try {
          const updateResponse = await fetch(`/api/system-admin/users/${userId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(formData)
          });
          
          if (updateResponse.ok) {
            closeModal();
            await this.loadUsers(this.usersOffset, this.usersLimit);
            alert('User updated successfully!');
          } else {
            const error = await updateResponse.json();
            alert('Failed to update user: ' + (error.error || 'Unknown error'));
          }
        } catch (error) {
          console.error('Error updating user:', error);
          alert('Error updating user');
        }
      });
      
    } catch (error) {
      console.error('Error showing edit modal:', error);
      alert('Error loading user details');
    }
  }
}
