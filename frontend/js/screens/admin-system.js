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
          <button class="admin-tab" data-view="organizations">🏢 Organizations</button>
          <button class="admin-tab" data-view="leagues">🏆 Leagues</button>
          <button class="admin-tab" data-view="casa">⚽ CASA</button>
          <button class="admin-tab" data-view="apsl">🦅 APSL</button>
          <button class="admin-tab" data-view="groupme">💬 GroupMe</button>
          <button class="admin-tab" data-view="schema">🗂️ Schema</button>
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
    // Store global reference for onclick handlers
    window.adminSystemScreen = this;
    
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
        case 'organizations':
          await this.loadOrganizations();
          break;
        case 'leagues':
          await this.loadLeagues();
          break;
        case 'casa':
          await this.loadCasaDashboard();
          break;
        case 'apsl':
          await this.loadApslDashboard();
          break;
        case 'groupme':
          await this.loadGroupMeDashboard();
          break;
        case 'schema':
          await this.loadDatabaseSchema();
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
    try {
      const response = await fetch('/api/system-admin/dashboard');
      if (response.ok) {
        this.dashboardData = await response.json();
      } else {
        // API not implemented yet, use default values
        this.dashboardData = {
          stats: {
            active_users: 0,
            active_teams: 0,
            active_clubs: 0,
            upcoming_events: 0
          }
        };
      }
    } catch (error) {
      // API not available, use default values
      this.dashboardData = {
        stats: {
          active_users: 0,
          active_teams: 0,
          active_clubs: 0,
          upcoming_events: 0
        }
      };
    }
    
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

  async loadApslStats(container) {
    // Create stats tabs
    container.innerHTML = `
      <div class="stats-view">
        <h2>📈 APSL Statistics</h2>
        <div class="stats-tabs">
          <button class="stats-tab active" data-tab="standings">🏆 Standings</button>
          <button class="stats-tab" data-tab="players">⚽ Player Stats</button>
          <button class="stats-tab" data-tab="matches">📅 Match Results</button>
        </div>
        <div class="stats-content">
          <div class="loading-indicator">Loading...</div>
        </div>
      </div>
    `;
    
    // Setup tab listeners
    container.querySelectorAll('.stats-tab').forEach(tab => {
      tab.addEventListener('click', async () => {
        container.querySelectorAll('.stats-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        await this.loadStatsTab(tab.dataset.tab);
      });
    });
    
    // Load initial tab
    await this.loadStatsTab('standings');
  }

  async loadStatsTab(tab) {
    const statsContent = this.element.querySelector('.stats-content');
    statsContent.innerHTML = '<div class="loading-indicator">Loading...</div>';
    
    try {
      if (tab === 'standings') {
        const response = await fetch('/api/stats/standings');
        const data = await response.json();
        
        if (!data.success) {
          throw new Error(data.message);
        }
        
        // Group by league and division
        const grouped = {};
        data.data.forEach(team => {
          const key = `${team.league_name || 'Unknown'} - ${team.division_name || 'Unknown'}`;
          if (!grouped[key]) grouped[key] = [];
          grouped[key].push(team);
        });
        
        let html = '<div class="standings-container">';
        Object.entries(grouped).forEach(([divisionName, teams]) => {
          html += `
            <div class="standings-table">
              <h3>${divisionName}</h3>
              <table class="admin-table">
                <thead>
                  <tr>
                    <th>Team</th>
                    <th>GP</th>
                    <th>W</th>
                    <th>L</th>
                    <th>T</th>
                    <th>GF</th>
                    <th>GA</th>
                    <th>GD</th>
                    <th>Pts</th>
                  </tr>
                </thead>
                <tbody>
                  ${teams.map(team => `
                    <tr>
                      <td><strong>${team.team_name}</strong></td>
                      <td>${team.games_played}</td>
                      <td>${team.wins}</td>
                      <td>${team.losses}</td>
                      <td>${team.ties}</td>
                      <td>${team.goals_for}</td>
                      <td>${team.goals_against}</td>
                      <td class="${team.goal_differential >= 0 ? 'positive' : 'negative'}">${team.goal_differential > 0 ? '+' : ''}${team.goal_differential}</td>
                      <td><strong>${team.points}</strong></td>
                    </tr>
                  `).join('')}
                </tbody>
              </table>
            </div>
          `;
        });
        html += '</div>';
        
        statsContent.innerHTML = html;
        
      } else if (tab === 'players') {
        const response = await fetch('/api/stats/players');
        const data = await response.json();
        
        if (!data.success) {
          throw new Error(data.message);
        }
        
        const allPlayers = data.data;
        let displayCount = 50; // Default show 50
        
        const renderPlayers = () => {
          const playersToShow = allPlayers.slice(0, displayCount);
          const showMoreButton = displayCount < allPlayers.length 
            ? `<button class="btn-primary" onclick="window.showMorePlayers()" style="margin: 20px auto; display: block;">Show More (${allPlayers.length - displayCount} remaining)</button>`
            : '';
          
          statsContent.innerHTML = `
            <div class="player-stats-container">
              <h3>Top Scorers (2025-2026 Season) - Showing ${playersToShow.length} of ${allPlayers.length}</h3>
              <table class="admin-table">
                <thead>
                  <tr>
                    <th>Rank</th>
                    <th>Player</th>
                    <th>Team</th>
                    <th>Conference</th>
                    <th>GP</th>
                    <th>Goals</th>
                    <th>Assists</th>
                    <th>Yellow</th>
                    <th>Red</th>
                  </tr>
                </thead>
                <tbody>
                  ${playersToShow.map((player, idx) => `
                    <tr>
                      <td><strong>${idx + 1}</strong></td>
                      <td>${player.player_name}</td>
                      <td>${player.team_name}</td>
                      <td>${player.conference_name || 'N/A'}</td>
                      <td>${player.games_played}</td>
                      <td><strong>${player.goals}</strong></td>
                      <td>${player.assists}</td>
                      <td>${player.yellow_cards}</td>
                      <td>${player.red_cards}</td>
                    </tr>
                  `).join('')}
                </tbody>
              </table>
              ${showMoreButton}
            </div>
          `;
        };
        
        // Make function accessible globally for onclick
        window.showMorePlayers = () => {
          displayCount += 50;
          renderPlayers();
        };
        
        renderPlayers();
        
      } else if (tab === 'matches') {
        const response = await fetch('/api/stats/matches');
        const data = await response.json();
        
        if (!data.success) {
          throw new Error(data.message);
        }
        
        const allMatches = data.data;
        let displayCount = 50; // Default show 50
        
        const renderMatches = () => {
          const matchesToShow = allMatches.slice(0, displayCount);
          const showMoreButton = displayCount < allMatches.length 
            ? `<button class="btn-primary" onclick="window.showMoreMatches()" style="margin: 20px auto; display: block;">Show More (${allMatches.length - displayCount} remaining)</button>`
            : '';
          
          statsContent.innerHTML = `
            <div class="matches-container">
              <h3>Match Results (Since Sept 1, 2025) - Showing ${matchesToShow.length} of ${allMatches.length}</h3>
              <table class="admin-table">
                <thead>
                  <tr>
                    <th>Date</th>
                    <th>Home Team</th>
                    <th>Score</th>
                    <th>Away Team</th>
                    <th>Venue</th>
                    <th>Events</th>
                  </tr>
                </thead>
                <tbody>
                  ${matchesToShow.map(match => `
                  <tr>
                    <td>${match.match_date ? new Date(match.match_date).toLocaleDateString() : 'TBD'}</td>
                    <td><strong>${match.home_team}</strong></td>
                    <td class="match-score">${match.home_score} - ${match.away_score}</td>
                    <td><strong>${match.away_team}</strong></td>
                    <td>
                      ${match.google_maps_url ? 
                        `<a href="${match.google_maps_url}" target="_blank">${match.venue_name || 'View Map'}</a>` :
                        (match.venue_name || 'N/A')
                      }
                    </td>
                    <td>
                      ${match.event_count > 0 ? 
                        `<button class="btn btn-sm btn-secondary" onclick="window.app.navigation.goTo('match-detail', {matchId: '${match.id}', matchTitle: '${match.home_team} vs ${match.away_team}'})">📊 View ${match.event_count} Events</button>` :
                        '<span class="text-muted">No events</span>'
                      }
                    </td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
            ${showMoreButton}
          </div>
        `;
        };
        
        // Make function accessible globally for onclick
        window.showMoreMatches = () => {
          displayCount += 50;
          renderMatches();
        };
        
        renderMatches();
      }
    } catch (error) {
      statsContent.innerHTML = `<div class="error-message">Error loading ${tab}: ${error.message}</div>`;
    }
  }

  async loadOrganizations() {
    const content = this.element.querySelector('.admin-content');
    
    try {
      const response = await fetch('/api/system-admin/organizations');
      if (!response.ok) throw new Error('Failed to fetch organizations');
      
      const orgs = await response.json();
      
      content.innerHTML = `
        <div class="stats-view">
          <h2>🏢 Organizations</h2>
          <p class="subtitle">All sports organizations in the system</p>
          
          <table class="admin-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Short Name</th>
                <th>Affiliation</th>
                <th>Website</th>
                <th>Active</th>
              </tr>
            </thead>
            <tbody>
              ${orgs.map(org => `
                <tr>
                  <td>${org.id}</td>
                  <td><strong>${org.name}</strong></td>
                  <td>${org.short_name || '-'}</td>
                  <td>${org.affiliation || '-'}</td>
                  <td>${org.website_url ? `<a href="${org.website_url}" target="_blank">🔗 View</a>` : '-'}</td>
                  <td>${org.is_active ? '✅ Active' : '❌ Inactive'}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      `;
    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading organizations: ${error.message}</div>`;
    }
  }

  async loadLeagues() {
    const content = this.element.querySelector('.admin-content');
    
    try {
      const response = await fetch('/api/system-admin/leagues');
      if (!response.ok) throw new Error('Failed to fetch leagues');
      
      const leagues = await response.json();
      
      // Group by league type
      const apslLeagues = leagues.filter(l => l.league_type === 'APSL');
      const casaLeagues = leagues.filter(l => l.league_type === 'CASA');
      
      content.innerHTML = `
        <div class="stats-view">
          <h2>🏆 Leagues</h2>
          <p class="subtitle">All leagues across all organizations</p>
          
          <h3>🦅 APSL Leagues (${apslLeagues.length})</h3>
          <table class="admin-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Season</th>
                <th>Org ID</th>
                <th>Organization</th>
              </tr>
            </thead>
            <tbody>
              ${apslLeagues.map(league => `
                <tr>
                  <td>${league.id}</td>
                  <td><strong>${league.name}</strong></td>
                  <td>${league.season || '-'}</td>
                  <td>${league.organization_id || '-'}</td>
                  <td>${league.organization_name || '-'}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
          
          <h3 style="margin-top: 2rem;">⚽ CASA Leagues (${casaLeagues.length})</h3>
          <table class="admin-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Season</th>
                <th>Org ID</th>
                <th>Organization</th>
              </tr>
            </thead>
            <tbody>
              ${casaLeagues.map(league => `
                <tr>
                  <td>${league.id}</td>
                  <td><strong>${league.name}</strong></td>
                  <td>${league.season || '-'}</td>
                  <td>${league.organization_id || '-'}</td>
                  <td>${league.organization_name || '-'}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      `;
    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading leagues: ${error.message}</div>`;
    }
  }

  async viewTableData(tableName, limit = 100, sortColumn = '', sortDir = 'ASC') {
    try {
      // Remove any existing modals first
      document.querySelectorAll('.modal-overlay').forEach(m => m.remove());
      
      console.log('Fetching data for:', tableName, 'limit:', limit, 'sort:', sortColumn, sortDir);
      let url = `/api/system-admin/schema/${tableName}/data?limit=${limit}`;
      if (sortColumn) {
        url += `&sort=${sortColumn}&dir=${sortDir}`;
      }
      
      console.log('Fetching URL:', url);
      const response = await fetch(url);
      console.log('Response status:', response.status);
      if (!response.ok) throw new Error('Failed to load table data');
      const data = await response.json();
      console.log('Data received:', data.count, 'rows');
      
      // Create modal
      const modal = document.createElement('div');
      modal.className = 'modal-overlay';
      modal.style.cssText = 'position: fixed !important; top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important; background: rgba(0,0,0,0.8) !important; z-index: 999999 !important; display: flex !important; align-items: center !important; justify-content: center !important;';
      modal.innerHTML = `
        <div class="modal-content table-data-modal" style="background: white !important; padding: 20px !important; border-radius: 8px !important; max-width: 90vw !important; max-height: 90vh !important; overflow: auto !important;">
          <div class="modal-header" style="background: #2196F3 !important; color: white !important; padding: 15px !important; margin: -20px -20px 15px -20px !important;">
            <h2 style="margin: 0 !important; color: white !important;">📊 ${tableName}</h2>
            <button class="modal-close" style="background: white !important; color: #2196F3 !important; border: none !important; padding: 5px 10px !important; cursor: pointer !important; font-size: 20px !important;">✕</button>
          </div>
          <div class="modal-controls">
            <label>
              Rows: 
              <select class="limit-selector">
                <option value="100" ${limit === 100 ? 'selected' : ''}>100</option>
                <option value="500" ${limit === 500 ? 'selected' : ''}>500</option>
                <option value="1000" ${limit === 1000 ? 'selected' : ''}>1000</option>
                <option value="0" ${limit === 0 ? 'selected' : ''}>All</option>
              </select>
            </label>
            <span class="row-count">${data.count} rows ${limit > 0 ? '(limited)' : ''}</span>
          </div>
          <div class="modal-body">
            <div class="table-data-container">
              ${(() => {
                try {
                  console.log('Calling renderTableData...');
                  const result = this.renderTableData(data, sortColumn, sortDir);
                  console.log('renderTableData returned:', result.substring(0, 100) + '...');
                  return result;
                } catch (err) {
                  console.error('Error in renderTableData:', err);
                  return '<p style="color: red;">Error rendering table: ' + err.message + '</p>';
                }
              })()}
            </div>
          </div>
        </div>
      `;
      
      console.log('About to append modal...');
      console.log('Modal HTML length:', modal.innerHTML.length);
      
      // Append to fullscreen element if in fullscreen, otherwise to body
      const targetElement = document.fullscreenElement || document.body;
      console.log('Appending to:', targetElement === document.body ? 'body' : 'fullscreen element');
      targetElement.appendChild(modal);
      
      console.log('Modal appended to body');
      console.log('Modal visible in DOM?', targetElement.contains(modal));
      
      // Close handlers
      modal.querySelector('.modal-close').onclick = () => modal.remove();
      modal.onclick = (e) => {
        if (e.target === modal) modal.remove();
      };
      
      // Limit selector handler
      modal.querySelector('.limit-selector').onchange = (e) => {
        const newLimit = parseInt(e.target.value);
        modal.remove();
        this.viewTableData(tableName, newLimit, sortColumn, sortDir);
      };
      
      // Column header click handlers for sorting
      modal.querySelectorAll('.sortable-header').forEach(th => {
        th.onclick = () => {
          const column = th.dataset.column;
          const newDir = (sortColumn === column && sortDir === 'ASC') ? 'DESC' : 'ASC';
          modal.remove();
          this.viewTableData(tableName, limit, column, newDir);
        };
      });
      
    } catch (error) {
      alert(`Error loading table data: ${error.message}`);
    }
  }
  
  renderTableData(data, sortColumn = '', sortDir = 'ASC') {
    if (data.rows.length === 0) {
      return '<p class="no-data">No data in this table</p>';
    }
    
    const columns = Object.keys(data.rows[0]);
    
    let html = '<table class="data-table"><thead><tr>';
    columns.forEach(col => {
      const isSorted = col === sortColumn;
      const sortIcon = isSorted ? (sortDir === 'ASC' ? ' ▲' : ' ▼') : '';
      html += `<th class="sortable-header" data-column="${col}" title="Click to sort">${col}${sortIcon}</th>`;
    });
    html += '</tr></thead><tbody>';
    
    data.rows.forEach(row => {
      html += '<tr>';
      columns.forEach(col => {
        const value = row[col];
        const displayValue = value === null ? '<em>null</em>' : this.formatValue(value);
        html += `<td>${displayValue}</td>`;
      });
      html += '</tr>';
    });
    
    html += '</tbody></table>';
    return html;
  }
  
  formatValue(value) {
    if (typeof value === 'string') {
      // Truncate long strings
      if (value.length > 100) {
        return value.substring(0, 97) + '...';
      }
      // Escape HTML
      return value.replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }
    return String(value);
  }
  
  async loadDatabaseSchema() {
    const content = this.element.querySelector('.admin-content');
    
    try {
      const response = await fetch('/api/system-admin/schema', {
        headers: { 'Content-Type': 'application/json' }
      });
      
      if (!response.ok) throw new Error('Failed to load schema');
      const data = await response.json();
      
      // Create container with instructions
      content.innerHTML = `
        <div class="schema-view">
          <h2>🗂️ Database Schema Viewer</h2>
          <div class="schema-controls">
            <button id="schema-fit" class="btn btn-secondary">📐 Fit to Screen</button>
            <button id="schema-zoom-in" class="btn btn-secondary">🔍+ Zoom In</button>
            <button id="schema-zoom-out" class="btn btn-secondary">🔍- Zoom Out</button>
            <button id="schema-reset" class="btn btn-secondary">🔄 Reset</button>
            <button id="schema-fullscreen" class="btn btn-primary">⛶ Fullscreen</button>
            <button id="schema-new-window" class="btn btn-primary">🗗 New Window</button>
            <span class="schema-info">
              💡 <strong>Drag</strong> to pan, <strong>Scroll</strong> to zoom, <strong>Click</strong> table to highlight relationships
            </span>
          </div>
          <div id="schema-network" class="schema-network"></div>
          <div id="schema-details" class="schema-details">
            <p style="color: var(--text-secondary); text-align: center; padding: var(--space-4);">
              👆 Click on any table above to view its columns and data
            </p>
          </div>
        </div>
      `;
      
      // Prepare nodes (tables) and edges (foreign keys)
      const nodes = [];
      const edges = [];
      const tableMap = {};
      
      data.tables.forEach((table, index) => {
        // Build label with table name and all columns
        const columnLines = table.columns.map(col => {
          const pk = col.primary_key ? '🔑 ' : '  ';
          const fk = table.foreign_keys.some(f => f.column === col.name) ? ' →' : '';
          const type = col.type.length > 15 ? col.type.substring(0, 12) + '...' : col.type;
          return `${pk}${col.name}: ${type}${fk}`;
        });
        
        const fullLabel = `${table.name}\n${'─'.repeat(table.name.length)}\n${columnLines.join('\n')}`;
        
        // Tooltip with more details
        const columnDetails = table.columns.map(col => {
          const pk = col.primary_key ? '🔑 ' : '';
          const nullable = col.nullable === 'NO' ? ' NOT NULL' : '';
          const def = col.default ? ` DEFAULT ${col.default}` : '';
          return `${pk}${col.name}: ${col.type}${nullable}${def}`;
        }).join('\\n');
        
        nodes.push({
          id: table.name,
          label: fullLabel,
          title: `<b>${table.name}</b>\\n\\n${columnDetails}`,
          shape: 'box',
          color: {
            background: '#ffffff',
            border: '#2196F3',
            highlight: { background: '#e3f2fd', border: '#1976d2' }
          },
          font: { size: 11, face: 'Monaco, Consolas, "Courier New", monospace', align: 'left' },
          margin: 10,
          widthConstraint: { minimum: 200, maximum: 350 }
        });
        
        tableMap[table.name] = table;
        
        // Add foreign key relationships as edges
        table.foreign_keys.forEach(fk => {
          edges.push({
            from: table.name,
            to: fk.foreign_table,
            label: fk.column,
            arrows: 'to',
            color: { color: '#2196F3', highlight: '#ff5722' },
            font: { size: 10, align: 'middle' },
            title: `${table.name}.${fk.column} → ${fk.foreign_table}.${fk.foreign_column}`
          });
        });
      });
      
      // Create vis.js network
      const container = document.getElementById('schema-network');
      const networkData = { nodes: new vis.DataSet(nodes), edges: new vis.DataSet(edges) };
      
      const options = {
        physics: {
          enabled: true,
          barnesHut: {
            gravitationalConstant: -120000,
            centralGravity: 0.1,
            springLength: 400,
            springConstant: 0.001,
            damping: 0.5,
            avoidOverlap: 3
          },
          stabilization: {
            enabled: true,
            iterations: 2000,
            updateInterval: 50
          },
          minVelocity: 1.0
        },
        interaction: {
          hover: true,
          tooltipDelay: 100,
          navigationButtons: true,
          keyboard: true
        },
        nodes: {
          borderWidth: 2,
          borderWidthSelected: 4,
          shapeProperties: {
            borderRadius: 4
          },
          margin: 15,
          heightConstraint: { minimum: 80 }
        },
        edges: {
          width: 2,
          smooth: {
            type: 'curvedCW',
            roundness: 0.2
          },
          arrows: {
            to: {
              enabled: true,
              scaleFactor: 0.5
            }
          },
          color: {
            inherit: false
          }
        },
        layout: {
          improvedLayout: true
        }
      };
      
      const network = new vis.Network(container, networkData, options);
      
      // Event handlers
      document.getElementById('schema-fit').addEventListener('click', () => {
        network.fit({ animation: true });
      });
      
      document.getElementById('schema-zoom-in').addEventListener('click', () => {
        const scale = network.getScale();
        network.moveTo({ scale: scale * 1.2, animation: true });
      });
      
      document.getElementById('schema-zoom-out').addEventListener('click', () => {
        const scale = network.getScale();
        network.moveTo({ scale: scale * 0.8, animation: true });
      });
      
      document.getElementById('schema-reset').addEventListener('click', () => {
        network.fit({ animation: true });
      });
      
      // Fullscreen toggle
      document.getElementById('schema-fullscreen').addEventListener('click', () => {
        const schemaView = document.querySelector('.schema-view');
        if (!document.fullscreenElement) {
          schemaView.requestFullscreen().catch(err => {
            console.error('Error attempting to enable fullscreen:', err);
          });
        } else {
          document.exitFullscreen();
        }
      });
      
      // Open in new window
      document.getElementById('schema-new-window').addEventListener('click', () => {
        window.open('/schema-viewer.html', 'SchemaViewer', 'width=1400,height=900,menubar=no,toolbar=no,location=no');
      });
      
      // Show table details on single click
      network.on('click', (params) => {
        const detailsDiv = document.getElementById('schema-details');
        
        if (params.nodes.length > 0) {
          const tableName = params.nodes[0];
          const table = tableMap[tableName];
          
          let detailsHTML = `
            <h3>📋 ${tableName}</h3>
            <p style="color: var(--text-secondary); margin: var(--space-2) 0;">💡 Double-click this table to view its data</p>
            <h4>Columns (${table.columns.length})</h4>
            <table class="data-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Type</th>
                  <th>Nullable</th>
                  <th>Default</th>
                  <th>Primary Key</th>
                </tr>
              </thead>
              <tbody>
          `;
          
          table.columns.forEach(col => {
            detailsHTML += `
              <tr>
                <td><strong>${col.name}</strong></td>
                <td>${col.type}</td>
                <td>${col.nullable}</td>
                <td>${col.default || '-'}</td>
                <td>${col.primary_key ? '🔑 Yes' : 'No'}</td>
              </tr>
            `;
          });
          
          detailsHTML += `
              </tbody>
            </table>
          `;
          
          if (table.foreign_keys.length > 0) {
            detailsHTML += `
              <h4>Foreign Keys (${table.foreign_keys.length})</h4>
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Column</th>
                    <th>References</th>
                  </tr>
                </thead>
                <tbody>
            `;
            
            table.foreign_keys.forEach(fk => {
              detailsHTML += `
                <tr>
                  <td><strong>${fk.column}</strong></td>
                  <td>→ ${fk.foreign_table}.${fk.foreign_column}</td>
                </tr>
              `;
            });
            
            detailsHTML += `
                </tbody>
              </table>
            `;
          }
          
          detailsDiv.innerHTML = detailsHTML;
        } else {
          detailsDiv.innerHTML = '<p class="info-message">Click on a table to see details</p>';
        }
      });
      
      // Double-click to view table data
      network.on('doubleClick', (params) => {
        console.log('Double-click detected:', params);
        if (params.nodes.length > 0) {
          const tableName = params.nodes[0];
          console.log('Opening table:', tableName);
          this.viewTableData(tableName);
        } else {
          console.log('No node selected');
        }
      });
      
      // Initial fit after network stabilizes
      network.once('stabilizationIterationsDone', () => {
        network.fit({ animation: false });
      });
      
    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading schema: ${error.message}</div>`;
    }
  }


  async loadCasaDashboard() {
    const content = this.element.querySelector('.admin-content');
    
    // Create stats tabs like APSL
    content.innerHTML = `
      <div class="stats-view">
        <h2>📈 CASA Statistics</h2>
        <div class="stats-tabs">
          <button class="stats-tab active" data-tab="standings">🏆 Standings</button>
          <button class="stats-tab" data-tab="teams">👕 Teams</button>
          <button class="stats-tab" data-tab="players">⚽ Players</button>
          <button class="stats-tab" data-tab="divisions">📊 Divisions</button>
        </div>
        <div class="stats-content">
          <div class="loading-indicator">Loading...</div>
        </div>
      </div>
    `;
    
    // Setup tab listeners
    content.querySelectorAll('.stats-tab').forEach(tab => {
      tab.addEventListener('click', async () => {
        content.querySelectorAll('.stats-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        await this.loadCasaStatsTab(tab.dataset.tab);
      });
    });
    
    // Load initial tab
    await this.loadCasaStatsTab('standings');
  }

  async loadCasaStatsTab(tab) {
    const statsContent = this.element.querySelector('.stats-content');
    statsContent.innerHTML = '<div class="loading-indicator">Loading...</div>';
    
    try {
      if (tab === 'standings') {
        // Fetch team stats which includes standings data
        const response = await fetch('/api/system-admin/casa/teams');
        const teams = await response.json();
        
        if (!teams || teams.length === 0) {
          statsContent.innerHTML = '<div class="info-box">No standings data available yet.</div>';
          return;
        }
        
        // Group by division
        const grouped = {};
        teams.forEach(team => {
          const divisionName = team.division_name || 'Unknown Division';
          if (!grouped[divisionName]) grouped[divisionName] = [];
          grouped[divisionName].push(team);
        });
        
        let html = '<div class="standings-container">';
        Object.entries(grouped).forEach(([divisionName, divisionTeams]) => {
          html += `
            <div class="standings-table">
              <h3>${divisionName}</h3>
              <table class="admin-table">
                <thead>
                  <tr>
                    <th>Team</th>
                    <th>CASA Team ID</th>
                  </tr>
                </thead>
                <tbody>
                  ${divisionTeams.map(team => `
                    <tr>
                      <td><strong>${team.name}</strong></td>
                      <td>${team.casa_team_id || ''}</td>
                    </tr>
                  `).join('')}
                </tbody>
              </table>
            </div>
          `;
        });
        html += '</div>';
        statsContent.innerHTML = html;
        
      } else if (tab === 'teams') {
        const res = await fetch('/api/system-admin/casa/teams');
        const items = await res.json();
        statsContent.innerHTML = `
          <h3>All Teams</h3>
          <table class="admin-table">
            <thead><tr><th>Name</th><th>Division</th><th>CASA Team ID</th></tr></thead>
            <tbody>
              ${items.map(i => `<tr><td>${i.name}</td><td>${i.division_name}</td><td>${i.casa_team_id || ''}</td></tr>`).join('')}
            </tbody>
          </table>
        `;
        
      } else if (tab === 'players') {
        const res = await fetch('/api/system-admin/casa/players');
        const items = await res.json();
        statsContent.innerHTML = `
          <h3>All Players (${items.length} total)</h3>
          <table class="admin-table">
            <thead><tr><th>Name</th><th>Team</th><th>Jersey #</th><th>Position</th></tr></thead>
            <tbody>
              ${items.map(i => `<tr><td>${i.name}</td><td>${i.team_name || 'No Team'}</td><td>${i.jersey_number || ''}</td><td>${i.position || ''}</td></tr>`).join('')}
            </tbody>
          </table>
        `;
        
      } else if (tab === 'divisions') {
        const res = await fetch('/api/system-admin/casa/divisions');
        const items = await res.json();
        statsContent.innerHTML = `
          <h3>All Divisions</h3>
          <table class="admin-table">
            <thead><tr><th>Name</th><th>Age Group</th><th>Skill Level</th><th>Gender</th></tr></thead>
            <tbody>
              ${items.map(i => `<tr><td>${i.name}</td><td>${i.age_group || ''}</td><td>${i.skill_level || ''}</td><td>${i.gender || ''}</td></tr>`).join('')}
            </tbody>
          </table>
        `;
      }
    } catch (error) {
      statsContent.innerHTML = `<div class="error-message">Error loading ${tab}: ${error.message}</div>`;
    }
  }
  async loadApslDashboard() {
    try {
      console.log('Loading APSL dashboard...');
      const response = await fetch('/api/system-admin/apsl');
      console.log('Response status:', response.status);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      const data = await response.json();
      console.log('APSL data:', data);
      
      const content = this.element.querySelector('.admin-content');
      console.log('Content element:', content);
      content.innerHTML = `
        <div class="dashboard-view">
          <h2>🦅 APSL Dashboard</h2>
          <div class="stats-grid">
            <div class="stat-card clickable" data-target="apsl-stats">
              <div class="stat-icon">📈</div>
              <div class="stat-value">View</div>
              <div class="stat-label">Stats & Standings</div>
            </div>
            <div class="stat-card clickable" data-target="apsl-divisions">
              <div class="stat-icon">🏆</div>
              <div class="stat-value">${data.divisions || 0}</div>
              <div class="stat-label">Divisions</div>
            </div>
            <div class="stat-card clickable" data-target="apsl-teams">
              <div class="stat-icon">👕</div>
              <div class="stat-value">${data.teams || 0}</div>
              <div class="stat-label">Teams</div>
            </div>
            <div class="stat-card clickable" data-target="apsl-players">
              <div class="stat-icon">🏃</div>
              <div class="stat-value">${data.players || 0}</div>
              <div class="stat-label">Players</div>
            </div>
            <div class="stat-card clickable" data-target="apsl-matches">
              <div class="stat-icon">📅</div>
              <div class="stat-value">${data.matches || 0}</div>
              <div class="stat-label">Matches</div>
            </div>
          </div>
          
          <div id="apsl-details-container" style="margin-top: 20px;">
            <div class="info-box">Select a card above to view details</div>
          </div>
        </div>
      `;
      console.log('Content rendered');
      
      // Add click listeners for cards
      content.querySelectorAll('.stat-card.clickable').forEach(card => {
        card.addEventListener('click', async () => {
          const target = card.dataset.target;
          await this.loadApslDetails(target);
        });
      });
    } catch (error) {
      console.error('Error loading APSL dashboard:', error);
      const content = this.element.querySelector('.admin-content');
      content.innerHTML = `<div class="error-message">Error loading APSL dashboard: ${error.message}</div>`;
    }
  }
  
  async loadApslDetails(target) {
    const container = this.element.querySelector('#apsl-details-container');
    container.innerHTML = '<div class="loading-indicator">Loading details...</div>';
    
    try {
      let html = '';
      if (target === 'apsl-stats') {
        await this.loadApslStats(container);
        return;
      } else if (target === 'apsl-divisions') {
        const res = await fetch('/api/system-admin/apsl/divisions');
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}: ${await res.text()}`);
        }
        const items = await res.json();
        if (!Array.isArray(items)) {
          throw new Error(`Expected array but got: ${typeof items}`);
        }
        html = `
          <h3>Divisions</h3>
          <table class="admin-table">
            <thead><tr><th>Name</th><th>Season</th><th>APSL ID</th></tr></thead>
            <tbody>
              ${items.map(i => `<tr><td>${i.name}</td><td>${i.season}</td><td>${i.apsl_id}</td></tr>`).join('')}
            </tbody>
          </table>
        `;
      } else if (target === 'apsl-teams') {
        const res = await fetch('/api/system-admin/apsl/teams');
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}: ${await res.text()}`);
        }
        const items = await res.json();
        if (!Array.isArray(items)) {
          throw new Error(`Expected array but got: ${typeof items}`);
        }
        html = `
          <h3>Teams</h3>
          <table class="admin-table">
            <thead><tr><th>Name</th><th>Division</th><th>APSL ID</th></tr></thead>
            <tbody>
              ${items.map(i => `<tr><td>${i.name}</td><td>${i.division || ''}</td><td>${i.apsl_id}</td></tr>`).join('')}
            </tbody>
          </table>
        `;
      } else if (target === 'apsl-players') {
        const res = await fetch('/api/system-admin/apsl/players');
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}: ${await res.text()}`);
        }
        const items = await res.json();
        if (!Array.isArray(items)) {
          throw new Error(`Expected array but got: ${typeof items}`);
        }
        html = `
          <h3>Players (Top 100)</h3>
          <table class="admin-table">
            <thead><tr><th>Name</th><th>Team</th><th>APSL ID</th></tr></thead>
            <tbody>
              ${items.map(i => `<tr><td>${i.name}</td><td>${i.team || ''}</td><td>${i.apsl_id}</td></tr>`).join('')}
            </tbody>
          </table>
        `;
      } else if (target === 'apsl-matches') {
        const res = await fetch('/api/system-admin/apsl/matches');
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}: ${await res.text()}`);
        }
        const items = await res.json();
        if (!Array.isArray(items)) {
          throw new Error(`Expected array but got: ${typeof items}`);
        }
        html = `
          <h3>Matches (Last 100)</h3>
          <table class="admin-table">
            <thead><tr><th>Date</th><th>Home</th><th>Score</th><th>Away</th><th>Status</th></tr></thead>
            <tbody>
              ${items.map(i => `<tr><td>${i.event_date}</td><td>${i.home_team}</td><td>${i.home_score} - ${i.away_score}</td><td>${i.away_team}</td><td>${i.status}</td></tr>`).join('')}
            </tbody>
          </table>
        `;
      }
      container.innerHTML = html;
    } catch (err) {
      container.innerHTML = `<div class="error-message">Error loading details: ${err.message}</div>`;
      console.error('Error loading APSL details:', err);
    }
  }

  async loadGroupMeDashboard() {
    const content = this.element.querySelector('.admin-content');
    content.innerHTML = `
      <div class="dashboard-view">
        <h2>💬 GroupMe Dashboard</h2>
        <div class="view-actions">
          <button class="btn btn-secondary refresh-btn" id="refresh-groupme">🔄 Refresh Live Data</button>
        </div>
        <div id="groupme-live-container" style="margin-top: 20px;">
          <div class="loading-indicator">Loading live GroupMe data...</div>
        </div>
      </div>
    `;
    
    // Add refresh button listener
    content.querySelector('#refresh-groupme').addEventListener('click', () => {
      this.loadGroupMeLiveData();
    });
    
    // Load live data
    this.loadGroupMeLiveData();
  }
  
  async loadGroupMeLiveData() {
    const container = this.element.querySelector('#groupme-live-container');
    container.innerHTML = '<div class="loading-indicator">Loading live GroupMe data...</div>';
    
    try {
      // First, fetch configured groups from the database so we always display all configured groups
      const dbRes = await fetch('/api/system-admin/groupme/groups');
      const dbGroups = dbRes.ok ? await dbRes.json() : [];

      // Try to get live data from GroupMe API and map by group id
      let liveMap = {};
      try {
        const liveRes = await fetch('/api/system-admin/groupme/live/groups');
        if (liveRes.ok) {
          const liveArr = await liveRes.json();
          if (Array.isArray(liveArr)) {
            for (const item of liveArr) {
              const g = item.response || item;
              const gid = g.id || g.groupme_id || g.groupme_group_id || '';
              if (gid) liveMap[gid] = g;
            }
          }
        }
      } catch (e) {
        // Ignore live errors; we'll fall back to DB-only view
        console.warn('Live GroupMe fetch failed, falling back to DB groups:', e);
      }

      let html = '<div class="groupme-groups">';

      for (const dbGroup of dbGroups) {
        const gid = dbGroup.groupme_id || dbGroup.groupme_group_id || '';
        const live = gid ? liveMap[gid] : null;
        const memberCount = live?.members ? live.members.length : (live?.member_count || 0);
        const messageCount = live?.messages ? (live.messages.count || 0) : 0;

        html += `
          <div class="groupme-group-card" style="margin-bottom: 20px; padding: 15px; border: 1px solid #ddd; border-radius: 8px;">
            <h3 style="margin: 0 0 10px 0;">📱 ${this.escapeHtml(dbGroup.name || live?.name || 'Unknown Group')}</h3>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px; margin-bottom: 15px;">
              <div class="stat-mini">
                <div style="font-size: 24px; font-weight: bold;">${memberCount}</div>
                <div style="color: #666; font-size: 12px;">Members</div>
              </div>
              <div class="stat-mini">
                <div style="font-size: 24px; font-weight: bold;">${messageCount}</div>
                <div style="color: #666; font-size: 12px;">Total Messages</div>
              </div>
            </div>
            <button class="btn btn-primary" onclick="adminSystemScreen.loadGroupMeMessages('${gid}', '${this.escapeHtml(dbGroup.name || live?.name || '')}')">
              💬 View Recent Messages
            </button>
            <button class="btn btn-secondary" onclick="adminSystemScreen.loadGroupMeMembers('${gid}', '${this.escapeHtml(dbGroup.name || live?.name || '')}')">
              👥 View Members
            </button>
            <button class="btn btn-secondary" onclick="adminSystemScreen.loadGroupMeCalendar('${gid}', '${this.escapeHtml(dbGroup.name || live?.name || '')}')">
              📅 View Calendar
            </button>
          </div>
        `;
      }

      html += '</div>';
      container.innerHTML = html;
      
    } catch (e) {
      container.innerHTML = `<div class="error-message">Error loading GroupMe data: ${e.message}</div>`;
    }
  }
  
  async loadGroupMeMessages(groupId, groupName) {
    const container = this.element.querySelector('#groupme-live-container');
    container.innerHTML = '<div class="loading-indicator">Loading messages...</div>';
    
    try {
      const res = await fetch(`/api/system-admin/groupme/live/group/${groupId}/messages`);
      if (!res.ok) {
        throw new Error('Failed to fetch messages');
      }
      
      const data = await res.json();
      const messages = data.response?.messages || [];
      
      let html = `
        <div class="groupme-messages">
          <h3>💬 Recent Messages from ${this.escapeHtml(groupName)}</h3>
          <button class="btn btn-secondary" onclick="adminSystemScreen.loadGroupMeLiveData()" style="margin-bottom: 15px;">
            ← Back to Groups
          </button>
          <div class="messages-list" style="max-height: 600px; overflow-y: auto;">
      `;
      
      if (messages.length === 0) {
        html += '<div class="info-box">No messages found</div>';
      } else {
        for (const msg of messages) {
          const date = new Date(msg.created_at * 1000).toLocaleString();
          const text = msg.text || '[No text]';
          const attachments = msg.attachments?.length || 0;
          
          html += `
            <div class="message-card" style="padding: 10px; margin-bottom: 10px; border: 1px solid #eee; border-radius: 4px; background: #f9f9f9;">
              <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                <strong>${this.escapeHtml(msg.name || 'Unknown')}</strong>
                <span style="color: #666; font-size: 12px;">${date}</span>
              </div>
              <div style="margin-bottom: 5px;">${this.escapeHtml(text)}</div>
              ${attachments > 0 ? `<div style="color: #666; font-size: 12px;">📎 ${attachments} attachment(s)</div>` : ''}
              ${msg.favorited_by?.length > 0 ? `<div style="color: #666; font-size: 12px;">❤️ ${msg.favorited_by.length} like(s)</div>` : ''}
            </div>
          `;
        }
      }
      
      html += '</div></div>';
      container.innerHTML = html;
      
    } catch (e) {
      container.innerHTML = `<div class="error-message">Error loading messages: ${e.message}</div>`;
    }
  }
  
  async loadGroupMeMembers(groupId, groupName) {
    const container = this.element.querySelector('#groupme-live-container');
    container.innerHTML = '<div class="loading-indicator">Loading members...</div>';
    
    try {
      const res = await fetch(`/api/system-admin/groupme/live/group/${groupId}/members`);
      if (!res.ok) {
        throw new Error('Failed to fetch members');
      }
      
      const data = await res.json();
      const group = data.response || data;
      const members = group.members || [];
      
      let html = `
        <div class="groupme-members">
          <h3>👥 Members of ${this.escapeHtml(groupName)}</h3>
          <button class="btn btn-secondary" onclick="adminSystemScreen.loadGroupMeLiveData()" style="margin-bottom: 15px;">
            ← Back to Groups
          </button>
          <table class="admin-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Nickname</th>
                <th>User ID</th>
                <th>Role</th>
              </tr>
            </thead>
            <tbody>
      `;
      
      if (members.length === 0) {
        html += '<tr><td colspan="4" style="text-align: center;">No members found</td></tr>';
      } else {
        for (const member of members) {
          html += `
            <tr>
              <td>${this.escapeHtml(member.name || 'Unknown')}</td>
              <td>${this.escapeHtml(member.nickname || 'N/A')}</td>
              <td>${this.escapeHtml(member.user_id || 'N/A')}</td>
              <td>${member.roles?.includes('admin') ? '👑 Admin' : 'Member'}</td>
            </tr>
          `;
        }
      }
      
      html += `
            </tbody>
          </table>
        </div>
      `;
      container.innerHTML = html;
      
    } catch (e) {
      container.innerHTML = `<div class="error-message">Error loading members: ${e.message}</div>`;
    }
  }
  
  async loadGroupMeCalendar(groupId, groupName) {
    const container = this.element.querySelector('#groupme-live-container');
    container.innerHTML = '<div class="loading-indicator">Loading calendar events...</div>';
    
    try {
      const res = await fetch(`/api/system-admin/groupme/live/group/${groupId}/events`);
      if (!res.ok) {
        throw new Error('Failed to fetch calendar events');
      }
      
      const data = await res.json();
      const events = data.response?.events || [];
      
      let html = `
        <div class="groupme-calendar">
          <h3>📅 Calendar Events for ${this.escapeHtml(groupName)}</h3>
          <button class="btn btn-secondary" onclick="adminSystemScreen.loadGroupMeLiveData()" style="margin-bottom: 15px;">
            ← Back to Groups
          </button>
      `;
      
      if (events.length === 0) {
        html += '<div class="info-box">No calendar events found</div>';
      } else {
        for (const event of events) {
          const startDate = event.start_at ? new Date(event.start_at).toLocaleString() : 'N/A';
          const endDate = event.end_at ? new Date(event.end_at).toLocaleString() : 'N/A';
          const goingCount = event.going?.length || 0;
          const notGoingCount = event.not_going?.length || 0;
          
          html += `
            <div class="event-card" style="padding: 15px; margin-bottom: 15px; border: 1px solid #ddd; border-radius: 8px; background: #f9f9f9;">
              <h4 style="margin: 0 0 10px 0;">${this.escapeHtml(event.name || 'Untitled Event')}</h4>
              ${event.description ? `<p style="margin: 0 0 10px 0;">${this.escapeHtml(event.description)}</p>` : ''}
              <div style="display: grid; grid-template-columns: auto 1fr; gap: 5px 15px; font-size: 14px;">
                <strong>📅 Start:</strong> <span>${startDate}</span>
                <strong>⏰ End:</strong> <span>${endDate}</span>
                ${event.location ? `<strong>📍 Location:</strong> <span>${this.escapeHtml(event.location)}</span>` : ''}
              </div>
              <div style="margin-top: 10px; display: flex; gap: 15px; font-size: 14px;">
                <span>✅ Going: ${goingCount}</span>
                <span>❌ Not Going: ${notGoingCount}</span>
              </div>
              <button class="btn btn-primary" onclick="adminSystemScreen.loadGroupMeEventRsvps('${groupId}', '${event.event_id}', '${this.escapeHtml(event.name || 'Event')}', '${this.escapeHtml(groupName)}')" style="margin-top: 10px;">
                View RSVPs
              </button>
            </div>
          `;
        }
      }
      
      html += '</div>';
      container.innerHTML = html;
      
    } catch (e) {
      container.innerHTML = `<div class="error-message">Error loading calendar: ${e.message}</div>`;
    }
  }
  
  async loadGroupMeEventRsvps(groupId, eventId, eventName, groupName) {
    const container = this.element.querySelector('#groupme-live-container');
    container.innerHTML = '<div class="loading-indicator">Loading RSVPs...</div>';
    
    try {
      // Fetch both events and group members to map user IDs to names
      const [eventsRes, membersRes] = await Promise.all([
        fetch(`/api/system-admin/groupme/live/group/${groupId}/events`),
        fetch(`/api/system-admin/groupme/live/group/${groupId}/members`)
      ]);
      
      if (!eventsRes.ok || !membersRes.ok) {
        throw new Error('Failed to fetch RSVPs');
      }
      
      const eventsData = await eventsRes.json();
      const membersData = await membersRes.json();
      const events = eventsData.response?.events || [];
      const members = membersData.response?.members || [];
      const event = events.find(e => e.event_id === eventId);
      
      // Create a map of user IDs to names
      const memberMap = {};
      for (const member of members) {
        memberMap[member.user_id] = member.name || member.nickname || 'Unknown';
      }
      
      // Build RSVP lists
      const going = [];
      const notGoing = [];
      const respondedUserIds = new Set();
      
      if (event?.going) {
        for (const userId of event.going) {
          going.push(memberMap[userId] || userId);
          respondedUserIds.add(userId);
        }
      }
      if (event?.not_going) {
        for (const userId of event.not_going) {
          notGoing.push(memberMap[userId] || userId);
          respondedUserIds.add(userId);
        }
      }
      
      // Find members who haven't responded
      const noResponse = [];
      for (const member of members) {
        if (!respondedUserIds.has(member.user_id)) {
          noResponse.push(member.name || member.nickname || 'Unknown');
        }
      }
      
      // Sort all lists alphabetically
      going.sort();
      notGoing.sort();
      noResponse.sort();
      
      let html = `
        <div class="groupme-event-rsvps">
          <h3>📋 RSVPs for "${this.escapeHtml(eventName)}"</h3>
          <button class="btn btn-secondary" onclick="adminSystemScreen.loadGroupMeCalendar('${groupId}', '${this.escapeHtml(groupName)}')" style="margin-bottom: 15px;">
            ← Back to Calendar
          </button>
          <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-top: 20px;">
            <!-- Going Column -->
            <div style="border: 1px solid #ddd; border-radius: 8px; padding: 15px; background: #f0fff0;">
              <h4 style="margin: 0 0 15px 0; color: #2d5016;">✅ Going (${going.length})</h4>
              <ul style="list-style: none; padding: 0; margin: 0;">
                ${going.length === 0 ? '<li style="color: #666; font-style: italic;">None yet</li>' : going.map(name => `<li style="padding: 5px 0; border-bottom: 1px solid #e0e0e0;">${this.escapeHtml(name)}</li>`).join('')}
              </ul>
            </div>
            
            <!-- Not Going Column -->
            <div style="border: 1px solid #ddd; border-radius: 8px; padding: 15px; background: #fff5f5;">
              <h4 style="margin: 0 0 15px 0; color: #8b0000;">❌ Not Going (${notGoing.length})</h4>
              <ul style="list-style: none; padding: 0; margin: 0;">
                ${notGoing.length === 0 ? '<li style="color: #666; font-style: italic;">None yet</li>' : notGoing.map(name => `<li style="padding: 5px 0; border-bottom: 1px solid #e0e0e0;">${this.escapeHtml(name)}</li>`).join('')}
              </ul>
            </div>
            
            <!-- No Response Column -->
            <div style="border: 1px solid #ddd; border-radius: 8px; padding: 15px; background: #f9f9f9;">
              <h4 style="margin: 0 0 15px 0; color: #666;">⏳ No Response (${noResponse.length})</h4>
              <ul style="list-style: none; padding: 0; margin: 0;">
                ${noResponse.length === 0 ? '<li style="color: #666; font-style: italic;">Everyone responded</li>' : noResponse.map(name => `<li style="padding: 5px 0; border-bottom: 1px solid #e0e0e0;">${this.escapeHtml(name)}</li>`).join('')}
              </ul>
            </div>
          </div>
        </div>
      `;
      container.innerHTML = html;
      
    } catch (e) {
      container.innerHTML = `<div class="error-message">Error loading RSVPs: ${e.message}</div>`;
    }
  }
  
  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
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
          <select id="filter-source" class="form-control">
            <option value="">All Sources</option>
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
      // Remove source from server params as we filter client-side for now
      params.delete('source'); 
      
      const response = await fetch(`/api/system-admin/identities?${params}`);
      let identities = await response.json();
      
      // Populate Source Dropdown (if not already filtered by it)
      const sourceSelect = this.element.querySelector('#filter-source');
      const currentSource = this.identityFilters.source || '';
      
      // Extract unique sources
      const sources = [...new Set(identities.map(i => i.source).filter(s => s))].sort();
      
      // Only rebuild options if we have more sources than currently shown (or if it's empty)
      // But simpler to just rebuild and restore selection
      if (sourceSelect.options.length <= 1 || !currentSource) {
          // Save current selection if any
          const oldVal = sourceSelect.value;
          
          // Clear (keep first)
          while (sourceSelect.options.length > 1) sourceSelect.remove(1);
          
          sources.forEach(s => {
              const opt = document.createElement('option');
              opt.value = s;
              opt.textContent = s;
              sourceSelect.appendChild(opt);
          });
          
          if (oldVal && sources.includes(oldVal)) sourceSelect.value = oldVal;
      }
      
      // Client-side Source Filtering
      if (currentSource) {
          identities = identities.filter(i => i.source === currentSource);
      }
      
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
        <div class="identity-item" data-id="${id.id}" data-linked-user-id="${id.user_id || ''}" style="padding: 10px; border-bottom: 1px solid #eee; cursor: pointer;">
          <div style="font-weight: bold;">${id.external_username || id.external_id}</div>
          <div style="font-size: 0.9em; color: #666;">
            ${id.provider_name} • ${id.team_name || 'No Team'}
            ${id.source ? `<br><span style="font-size:0.85em; color:#888;">Source: ${id.source}</span>` : ''}
          </div>
          ${id.user_id ? `<div style="font-size: 0.8em; color: green;">Linked to: ${id.user_first} ${id.user_last}</div>` : ''}
        </div>
      `).join('');
      
      // Add click selection
      list.querySelectorAll('.identity-item').forEach(item => {
        item.addEventListener('click', () => {
          list.querySelectorAll('.identity-item').forEach(i => i.classList.remove('selected'));
          item.classList.add('selected');
          this.selectedIdentityId = item.dataset.id;
          
          // Highlight linked user on the right
          const linkedUserId = item.dataset.linkedUserId;
          this.highlightLinkedUser(linkedUserId);
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
    
    // Row selection handler
    list.querySelectorAll('.user-item').forEach(item => {
        item.addEventListener('click', (e) => {
            // Ignore if clicked on button
            if (e.target.closest('.link-btn')) return;

            // Visual selection (Blue)
            list.querySelectorAll('.user-item').forEach(i => i.classList.remove('selected'));
            item.classList.add('selected');
            
            // Cross-highlighting (Green)
            const userId = item.dataset.id;
            this.highlightLinkedIdentities(userId);
        });
    });

    // Link button handler
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

  highlightLinkedUser(userId) {
    // Clear previous highlights
    this.element.querySelectorAll('.user-item').forEach(el => el.classList.remove('highlight-linked'));
    
    if (!userId) return;
    
    const userItem = this.element.querySelector(`.user-item[data-id="${userId}"]`);
    if (userItem) {
      userItem.classList.add('highlight-linked');
      userItem.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  }

  highlightLinkedIdentities(userId) {
    // Clear previous highlights
    this.element.querySelectorAll('.identity-item').forEach(el => el.classList.remove('highlight-linked'));
    
    if (!userId) return;
    
    const identityItems = this.element.querySelectorAll(`.identity-item[data-linked-user-id="${userId}"]`);
    identityItems.forEach(item => {
      item.classList.add('highlight-linked');
    });
    
    if (identityItems.length > 0) {
        identityItems[0].scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  }

  setupIdentityEventListeners() {
    this.element.querySelector('#apply-filters').addEventListener('click', () => {
      this.identityFilters.team_id = this.element.querySelector('#filter-team').value;
      this.identityFilters.club_id = this.element.querySelector('#filter-club').value;
      this.identityFilters.provider_id = this.element.querySelector('#filter-provider').value;
      this.identityFilters.source = this.element.querySelector('#filter-source').value;
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
