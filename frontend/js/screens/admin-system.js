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
        
        <div class="quick-actions">
          <h3>Quick Actions</h3>
          <div class="action-buttons">
            <button class="btn btn-primary admin-tab" data-view="users">View All Users</button>
            <button class="btn btn-primary admin-tab" data-view="admins">Manage Admins</button>
            <button class="btn btn-primary admin-tab" data-view="settings">System Settings</button>
            <button class="btn btn-primary admin-tab" data-view="features">Feature Flags</button>
          </div>
        </div>
      </div>
    `;
  }
  
  async loadUsers() {
    const response = await fetch('/api/system-admin/users?limit=50');
    this.users = await response.json();
    
    const content = this.element.querySelector('.admin-content');
    content.innerHTML = `
      <div class="users-view">
        <div class="view-header">
          <h2>User Management</h2>
          <button class="btn btn-secondary refresh-btn">🔄 Refresh</button>
        </div>
        
        <div class="table-container">
          <table class="admin-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Status</th>
                <th>Created</th>
              </tr>
            </thead>
            <tbody>
              ${this.users.map(user => `
                <tr>
                  <td>${user.first_name || ''} ${user.last_name || ''}</td>
                  <td>${user.email || '<em>No email</em>'}</td>
                  <td>
                    <span class="badge ${user.is_active ? 'badge-success' : 'badge-danger'}">
                      ${user.is_active ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td>${new Date(user.created_at).toLocaleDateString()}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
        
        <div class="pagination-info">
          Showing ${this.users.length} users
        </div>
      </div>
    `;
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
}
