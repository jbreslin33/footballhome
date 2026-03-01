// AdminSystemScreen - Super Admin Dashboard
class AdminSystemScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.currentView = 'matches';
    this.matchesSort = { column: 'match_date', dir: 'DESC' };
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
          <button class="admin-tab active" data-view="matches">⚽ Matches</button>
          <button class="admin-tab" data-view="teams">👥 Teams</button>
          <button class="admin-tab" data-view="players">🏃 Players</button>
          <button class="admin-tab" data-view="standings">📊 Standings</button>
          <button class="admin-tab" data-view="coverage">📈 Match Event Coverage</button>
          <button class="admin-tab" data-view="data-quality">🔍 Data Quality</button>
          <button class="admin-tab" data-view="league-stats">🏆 League Statistics</button>
          <button class="admin-tab" data-view="groupme">📱 GroupMe</button>
          <button class="admin-tab" data-view="schema">🗂️ Schema</button>
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
        case 'matches':
          await this.loadMatches();
          break;
        case 'teams':
          await this.loadTeams();
          break;
        case 'players':
          await this.loadPlayers();
          break;
        case 'standings':
          await this.loadStandings();
          break;
        case 'coverage':
          await this.loadCoverageReport();
          break;
        case 'data-quality':
          await this.loadDataQuality();
          break;
        case 'league-stats':
          await this.loadLeagueStats();
          break;
        case 'groupme':
          await this.loadGroupMeEvents();
          break;
        case 'schema':
          await this.loadDatabaseSchema();
          break;
        default:
          content.innerHTML = '<div class="error-message">View not found</div>';
      }
    } catch (error) {
      console.error('Error loading view:', error);
      content.innerHTML = `<div class="error-message">Error loading ${view}: ${error.message}</div>`;
    }
  }

  async loadMatches() {
    const content = this.element.querySelector('.admin-content');
    
    try {
      const { column, dir } = this.matchesSort;
      const response = await fetch(`/api/system-admin/matches?sort=${column}&dir=${dir}`);
      
      if (!response.ok) throw new Error('Failed to load matches');
      const matches = await response.json();
      
      const sortIcon = (col) => {
        if (col !== column) return '';
        return dir === 'ASC' ? ' ▲' : ' ▼';
      };
      
      content.innerHTML = `
        <div class="matches-view">
          <h2>⚽ All Matches (${matches.length})</h2>
          <div class="table-container">
            <table class="admin-table">
              <thead>
                <tr>
                  <th class="sortable" data-col="match_date">Date${sortIcon('match_date')}</th>
                  <th class="sortable" data-col="home_team_name">Home Team${sortIcon('home_team_name')}</th>
                  <th>Score</th>
                  <th class="sortable" data-col="away_team_name">Away Team${sortIcon('away_team_name')}</th>
                  <th class="sortable" data-col="league_name">League${sortIcon('league_name')}</th>
                  <th class="sortable" data-col="source_system">Source${sortIcon('source_system')}</th>
                  <th>Events</th>
                </tr>
              </thead>
              <tbody>
                ${matches.map(m => `
                  <tr class="clickable-match" data-match-id="${m.id}" style="cursor: pointer;">
                    <td>${m.match_date ? new Date(m.match_date).toLocaleDateString() : '-'}</td>
                    <td>${m.home_team_name || 'TBD'}</td>
                    <td><strong>${m.home_score !== null ? m.home_score : '-'} - ${m.away_score !== null ? m.away_score : '-'}</strong></td>
                    <td>${m.away_team_name || 'TBD'}</td>
                    <td>${m.league_name || '-'}</td>
                    <td>${m.source_system || '-'}</td>
                    <td>${m.event_count || 0}</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </div>
      `;
      
      // Add click handlers for sorting
      content.querySelectorAll('.sortable').forEach(th => {
        th.style.cursor = 'pointer';
        th.addEventListener('click', () => {
          const col = th.dataset.col;
          this.matchesSort = {
            column: col,
            dir: (this.matchesSort.column === col && this.matchesSort.dir === 'ASC') ? 'DESC' : 'ASC'
          };
          this.loadMatches();
        });
      });
      
      // Add click handlers for match rows
      content.querySelectorAll('.clickable-match').forEach(row => {
        row.addEventListener('click', () => {
          const matchId = row.dataset.matchId;
          this.viewMatchStats(matchId);
        });
      });
      
    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading matches: ${error.message}</div>`;
    }
  }
  
  async viewMatchStats(matchId) {
    try {
      // Fetch match events
      const response = await fetch(`/api/stats/matches/${matchId}/events`);
      if (!response.ok) throw new Error('Failed to load match events');
      
      const result = await response.json();
      const events = result.data || [];
      
      // Create modal
      const modal = document.createElement('div');
      modal.className = 'modal-overlay';
      modal.innerHTML = `
        <div class="modal-content" style="max-width: 800px;">
          <div class="modal-header">
            <h3>⚽ Match Events (${events.length})</h3>
            <button class="modal-close">&times;</button>
          </div>
          <div class="modal-body">
            ${events.length === 0 ? '<p>No events recorded for this match.</p>' : `
              <table class="admin-table">
                <thead>
                  <tr>
                    <th>Minute</th>
                    <th>Event</th>
                    <th>Player</th>
                    <th>Team</th>
                    <th>Assist</th>
                  </tr>
                </thead>
                <tbody>
                  ${events.map(e => `
                    <tr>
                      <td><strong>${e.minute}'</strong></td>
                      <td>${e.event_type}</td>
                      <td>${e.player_name}</td>
                      <td>${e.team_name}</td>
                      <td>${e.assisted_by || '-'}</td>
                    </tr>
                  `).join('')}
                </tbody>
              </table>
            `}
          </div>
        </div>
      `;
      
      document.body.appendChild(modal);
      
      // Close modal handlers
      modal.querySelector('.modal-close').addEventListener('click', () => modal.remove());
      modal.addEventListener('click', (e) => {
        if (e.target === modal) modal.remove();
      });
      
    } catch (error) {
      alert(`Error loading match stats: ${error.message}`);
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
            gravitationalConstant: -30000,
            centralGravity: 0.2,
            springLength: 220,
            springConstant: 0.01,
            damping: 0.2,
            avoidOverlap: 1
          },
          stabilization: {
            enabled: true,
            iterations: 800,
            updateInterval: 50
          },
          minVelocity: 0.75
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
          margin: 10,
          heightConstraint: { minimum: 60 }
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
      
    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading schema: ${error.message}</div>`;
    }
  }

  async loadTeams() {
    const content = this.element.querySelector('.admin-content');
    
    try {
      // Fetch available leagues
      const leaguesResponse = await fetch('/api/system-admin/leagues');
      if (!leaguesResponse.ok) throw new Error('Failed to load leagues');
      const leagues = await leaguesResponse.json();
      
      content.innerHTML = `
        <div class="teams-view">
          <h2>👥 Teams Report</h2>
          <p class="subtitle">View all teams by league and season</p>
          
          <div class="filter-controls" style="margin: var(--space-4) 0; display: flex; gap: var(--space-3); align-items: center;">
            <div>
              <label for="teams-league-select" style="display: block; margin-bottom: var(--space-1); font-weight: 600;">League:</label>
              <select id="teams-league-select" class="form-control" style="min-width: 250px;">
                <option value="">-- Select League --</option>
                ${leagues.map(l => `<option value="${l.id}">${l.name}</option>`).join('')}
              </select>
            </div>
            
            <div>
              <label for="teams-season-select" style="display: block; margin-bottom: var(--space-1); font-weight: 600;">Season (Optional):</label>
              <select id="teams-season-select" class="form-control" style="min-width: 150px;" disabled>
                <option value="">All Seasons</option>
              </select>
            </div>
            
            <div style="margin-top: 24px;">
              <button id="load-teams-btn" class="btn btn-primary" disabled>Load Teams</button>
            </div>
          </div>
          
          <div id="teams-results" style="margin-top: var(--space-4);">
            <p style="color: var(--text-secondary); text-align: center; padding: var(--space-6);">
              👆 Select a league above to view teams
            </p>
          </div>
        </div>
      `;
      
      // Event handlers
      const leagueSelect = document.getElementById('teams-league-select');
      const seasonSelect = document.getElementById('teams-season-select');
      const loadBtn = document.getElementById('load-teams-btn');
      
      leagueSelect.addEventListener('change', async () => {
        const leagueId = leagueSelect.value;
        
        if (!leagueId) {
          seasonSelect.disabled = true;
          seasonSelect.innerHTML = '<option value="">All Seasons</option>';
          loadBtn.disabled = true;
          return;
        }
        
        try {
          // Fetch seasons for this league
          const seasonsResponse = await fetch(`/api/system-admin/standings/seasons?league_id=${leagueId}`);
          if (!seasonsResponse.ok) {
            console.error('Failed to load seasons');
            seasonSelect.innerHTML = '<option value="">All Seasons</option>';
            seasonSelect.disabled = false;
            loadBtn.disabled = false;
            return;
          }
          
          const seasons = await seasonsResponse.json();
          
          seasonSelect.innerHTML = '<option value="">All Seasons</option>' + 
            seasons.map(s => `<option value="${s.season}">${s.season}</option>`).join('');
          seasonSelect.disabled = false;
          loadBtn.disabled = false;
        } catch (error) {
          console.error('Error fetching seasons:', error);
          seasonSelect.innerHTML = '<option value="">All Seasons</option>';
          seasonSelect.disabled = false;
          loadBtn.disabled = false;
        }
      });
      
      loadBtn.addEventListener('click', async () => {
        const leagueId = leagueSelect.value;
        const season = seasonSelect.value;
        
        if (!leagueId) return;
        
        const resultsDiv = document.getElementById('teams-results');
        resultsDiv.innerHTML = '<div class="loading-indicator">Loading teams...</div>';
        
        try {
          let url = `/api/system-admin/teams?league_id=${leagueId}`;
          if (season) {
            url += `&season=${season}`;
          }
          
          const response = await fetch(url);
          if (!response.ok) throw new Error('Failed to load teams');
          
          const teams = await response.json();
          
          if (teams.length === 0) {
            resultsDiv.innerHTML = `
              <div style="text-align: center; padding: var(--space-6); color: var(--text-secondary);">
                <p>No teams found for selected league${season ? ' and season' : ''}.</p>
              </div>
            `;
            return;
          }
          
          // Group teams by division
          const teamsByDivision = {};
          teams.forEach(team => {
            const divKey = team.division_name || 'No Division';
            if (!teamsByDivision[divKey]) {
              teamsByDivision[divKey] = [];
            }
            teamsByDivision[divKey].push(team);
          });
          
          const divisionKeys = Object.keys(teamsByDivision).sort();
          
          resultsDiv.innerHTML = `
            <div class="teams-results">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--space-3);">
                <h3>${teams.length} Teams ${season ? 'in ' + season : 'Across All Seasons'}</h3>
              </div>
              
              ${divisionKeys.map(divKey => {
                const divTeams = teamsByDivision[divKey];
                return `
                  <div class="division-section" style="margin-bottom: var(--space-5);">
                    <h4 style="background: var(--bg-secondary); padding: var(--space-2); border-radius: var(--radius-md); margin-bottom: var(--space-2);">
                      ${divKey} (${divTeams.length} teams)
                    </h4>
                    
                    <table class="admin-table">
                      <thead>
                        <tr>
                          <th>Team Name</th>
                          <th>Club</th>
                          ${!season ? '<th>Seasons</th>' : '<th>External ID</th>'}
                          <th>Source</th>
                        </tr>
                      </thead>
                      <tbody>
                        ${divTeams.map(team => `
                          <tr>
                            <td><strong>${team.team_name}</strong></td>
                            <td>${team.club_name || '-'}</td>
                            ${!season ? 
                              `<td>${team.seasons || '-'}</td>` : 
                              `<td>${team.external_id || '-'}</td>`
                            }
                            <td>${team.source_system || '-'}</td>
                          </tr>
                        `).join('')}
                      </tbody>
                    </table>
                  </div>
                `;
              }).join('')}
            </div>
          `;
          
        } catch (error) {
          resultsDiv.innerHTML = `<div class="error-message">Error loading teams: ${error.message}</div>`;
        }
      });
      
    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading teams view: ${error.message}</div>`;
    }
  }

  async loadPlayers() {
    const content = this.element.querySelector('.admin-content');
    
    try {
      // Fetch available leagues
      const leaguesResponse = await fetch('/api/system-admin/leagues');
      if (!leaguesResponse.ok) throw new Error('Failed to load leagues');
      const leagues = await leaguesResponse.json();
      
      content.innerHTML = `
        <div class="players-view">
          <h2>🏃 Players Report</h2>
          <p class="subtitle">View all players by league, season, and team</p>
          
          <div class="filter-controls" style="margin: var(--space-4) 0; display: flex; gap: var(--space-3); align-items: center; flex-wrap: wrap;">
            <div>
              <label for="players-league-select" style="display: block; margin-bottom: var(--space-1); font-weight: 600;">League:</label>
              <select id="players-league-select" class="form-control" style="min-width: 250px;">
                <option value="">-- Select League --</option>
                ${leagues.map(l => `<option value="${l.id}">${l.name}</option>`).join('')}
              </select>
            </div>
            
            <div>
              <label for="players-season-select" style="display: block; margin-bottom: var(--space-1); font-weight: 600;">Season:</label>
              <select id="players-season-select" class="form-control" style="min-width: 150px;" disabled>
                <option value="">-- Select Season --</option>
              </select>
            </div>
            
            <div>
              <label for="players-team-select" style="display: block; margin-bottom: var(--space-1); font-weight: 600;">Team:</label>
              <select id="players-team-select" class="form-control" style="min-width: 250px;" disabled>
                <option value="">-- Select Team --</option>
              </select>
            </div>
            
            <div style="margin-top: 24px;">
              <button id="load-players-btn" class="btn btn-primary" disabled>Load Players</button>
            </div>
          </div>
          
          <div id="players-results" style="margin-top: var(--space-4);">
            <p style="color: var(--text-secondary); text-align: center; padding: var(--space-6);">
              👆 Select a league, season, and team above to view players
            </p>
          </div>
        </div>
      `;
      
      // Event handlers
      const leagueSelect = document.getElementById('players-league-select');
      const seasonSelect = document.getElementById('players-season-select');
      const teamSelect = document.getElementById('players-team-select');
      const loadBtn = document.getElementById('load-players-btn');
      
      leagueSelect.addEventListener('change', async () => {
        const leagueId = leagueSelect.value;
        
        seasonSelect.disabled = true;
        seasonSelect.innerHTML = '<option value="">-- Select Season --</option>';
        teamSelect.disabled = true;
        teamSelect.innerHTML = '<option value="">-- Select Team --</option>';
        loadBtn.disabled = true;
        
        if (!leagueId) return;
        
        try {
          const seasonsResponse = await fetch(`/api/system-admin/standings/seasons?league_id=${leagueId}`);
          if (!seasonsResponse.ok) {
            console.error('Failed to load seasons');
            return;
          }
          
          const seasons = await seasonsResponse.json();
          
          seasonSelect.innerHTML = '<option value="">-- Select Season --</option>' + 
            seasons.map(s => `<option value="${s.season}">${s.season}</option>`).join('');
          seasonSelect.disabled = false;
        } catch (error) {
          console.error('Error fetching seasons:', error);
        }
      });
      
      seasonSelect.addEventListener('change', async () => {
        const leagueId = leagueSelect.value;
        const season = seasonSelect.value;
        
        teamSelect.disabled = true;
        teamSelect.innerHTML = '<option value="">-- Select Team --</option>';
        loadBtn.disabled = true;
        
        if (!leagueId || !season) return;
        
        try {
          const teamsResponse = await fetch(`/api/system-admin/teams?league_id=${leagueId}&season=${season}`);
          if (!teamsResponse.ok) {
            console.error('Failed to load teams');
            return;
          }
          
          const teams = await teamsResponse.json();
          
          // Get unique teams
          const uniqueTeams = [];
          const seenIds = new Set();
          teams.forEach(team => {
            if (!seenIds.has(team.team_id)) {
              seenIds.add(team.team_id);
              uniqueTeams.push(team);
            }
          });
          
          uniqueTeams.sort((a, b) => a.team_name.localeCompare(b.team_name));
          
          teamSelect.innerHTML = '<option value="">-- Select Team --</option>' + 
            uniqueTeams.map(t => `<option value="${t.team_id}">${t.team_name}</option>`).join('');
          teamSelect.disabled = false;
        } catch (error) {
          console.error('Error fetching teams:', error);
        }
      });
      
      teamSelect.addEventListener('change', () => {
        loadBtn.disabled = !teamSelect.value;
      });
      
      loadBtn.addEventListener('click', async () => {
        const leagueId = leagueSelect.value;
        const season = seasonSelect.value;
        const teamId = teamSelect.value;
        
        if (!leagueId || !season || !teamId) return;
        
        const resultsDiv = document.getElementById('players-results');
        resultsDiv.innerHTML = '<div class="loading-indicator">Loading players...</div>';
        
        try {
          const response = await fetch(`/api/system-admin/players?league_id=${leagueId}&season=${season}&team_id=${teamId}`);
          if (!response.ok) throw new Error('Failed to load players');
          
          const result = await response.json();
          const players = result.players || [];
          const teamName = result.team_name || '';
          
          if (players.length === 0) {
            resultsDiv.innerHTML = `
              <div style="text-align: center; padding: var(--space-6); color: var(--text-secondary);">
                <p>No players found for ${teamName} in ${season}.</p>
              </div>
            `;
            return;
          }
          
          resultsDiv.innerHTML = `
            <div class="players-results">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--space-3);">
                <h3>${players.length} Players - ${teamName} (${season})</h3>
              </div>
              
              <table class="admin-table">
                <thead>
                  <tr>
                    <th>Jersey #</th>
                    <th>Player Name</th>
                    <th>Position</th>
                    <th>Date of Birth</th>
                    <th>External ID</th>
                  </tr>
                </thead>
                <tbody>
                  ${players.map(player => `
                    <tr>
                      <td><strong>${player.jersey_number || '-'}</strong></td>
                      <td>${player.first_name || ''} ${player.last_name || ''}</td>
                      <td>${player.position_name || '-'}</td>
                      <td>${player.date_of_birth ? new Date(player.date_of_birth).toLocaleDateString() : '-'}</td>
                      <td>${player.external_id || '-'}</td>
                    </tr>
                  `).join('')}
                </tbody>
              </table>
            </div>
          `;
          
        } catch (error) {
          resultsDiv.innerHTML = `<div class="error-message">Error loading players: ${error.message}</div>`;
        }
      });
      
    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading players view: ${error.message}</div>`;
    }
  }

  async loadStandings() {
    const content = this.element.querySelector('.admin-content');
    
    try {
      // Fetch available leagues and seasons
      const leaguesResponse = await fetch('/api/system-admin/leagues');
      if (!leaguesResponse.ok) throw new Error('Failed to load leagues');
      const leagues = await leaguesResponse.json();
      
      content.innerHTML = `
        <div class="standings-view">
          <h2>📊 League Standings</h2>
          <p class="subtitle">Select a league and season to view standings</p>
          
          <div class="filter-controls" style="margin: var(--space-4) 0; display: flex; gap: var(--space-3); align-items: center;">
            <div>
              <label for="league-select" style="display: block; margin-bottom: var(--space-1); font-weight: 600;">League:</label>
              <select id="league-select" class="form-control" style="min-width: 250px;">
                <option value="">-- Select League --</option>
                ${leagues.map(l => `<option value="${l.id}">${l.name}</option>`).join('')}
              </select>
            </div>
            
            <div>
              <label for="season-select" style="display: block; margin-bottom: var(--space-1); font-weight: 600;">Season:</label>
              <select id="season-select" class="form-control" style="min-width: 150px;" disabled>
                <option value="">-- Select Season --</option>
              </select>
            </div>
            
            <div style="margin-top: 24px;">
              <button id="load-standings-btn" class="btn btn-primary" disabled>Load Standings</button>
            </div>
          </div>
          
          <div id="standings-results" style="margin-top: var(--space-4);">
            <p style="color: var(--text-secondary); text-align: center; padding: var(--space-6);">
              👆 Select a league and season above to view standings
            </p>
          </div>
        </div>
      `;
      
      // Event handlers
      const leagueSelect = document.getElementById('league-select');
      const seasonSelect = document.getElementById('season-select');
      const loadBtn = document.getElementById('load-standings-btn');
      
      leagueSelect.addEventListener('change', async () => {
        const leagueId = leagueSelect.value;
        
        if (!leagueId) {
          seasonSelect.disabled = true;
          seasonSelect.innerHTML = '<option value="">-- Select Season --</option>';
          loadBtn.disabled = true;
          return;
        }
        
        try {
          // Fetch seasons for this league
          const seasonsResponse = await fetch(`/api/system-admin/standings/seasons?league_id=${leagueId}`);
          if (!seasonsResponse.ok) {
            const errorText = await seasonsResponse.text();
            console.error('Failed to load seasons:', errorText);
            seasonSelect.innerHTML = '<option value="">Error loading seasons</option>';
            seasonSelect.disabled = true;
            return;
          }
          
          const seasons = await seasonsResponse.json();
          
          if (seasons.length === 0) {
            seasonSelect.innerHTML = '<option value="">No seasons available</option>';
            seasonSelect.disabled = true;
            loadBtn.disabled = true;
            return;
          }
          
          seasonSelect.innerHTML = '<option value="">-- Select Season --</option>' + 
            seasons.map(s => `<option value="${s.season}">${s.season} (${s.match_count} matches)</option>`).join('');
          seasonSelect.disabled = false;
          loadBtn.disabled = true;
        } catch (error) {
          console.error('Error fetching seasons:', error);
          seasonSelect.innerHTML = '<option value="">Error loading seasons</option>';
          seasonSelect.disabled = true;
        }
      });
      
      seasonSelect.addEventListener('change', () => {
        loadBtn.disabled = !seasonSelect.value;
      });
      
      loadBtn.addEventListener('click', async () => {
        const leagueId = leagueSelect.value;
        const season = seasonSelect.value;
        
        if (!leagueId || !season) return;
        
        const resultsDiv = document.getElementById('standings-results');
        resultsDiv.innerHTML = '<div class="loading-indicator">Loading standings...</div>';
        
        try {
          const response = await fetch(`/api/system-admin/standings?league_id=${leagueId}&season=${season}`);
          if (!response.ok) throw new Error('Failed to load standings');
          const standings = await response.json();
          
          if (standings.length === 0) {
            resultsDiv.innerHTML = '<p class="info-message">No matches found for this league and season.</p>';
            return;
          }
          
          // Get league name for display
          const leagueName = leagueSelect.options[leagueSelect.selectedIndex].text;
          
          // Group standings by division
          const divisionGroups = {};
          standings.forEach(team => {
            const divName = team.division_name || 'Unknown Division';
            if (!divisionGroups[divName]) {
              divisionGroups[divName] = [];
            }
            divisionGroups[divName].push(team);
          });
          
          // Generate HTML for each division
          let tablesHtml = '';
          Object.keys(divisionGroups).sort().forEach(divisionName => {
            const teams = divisionGroups[divisionName];
            tablesHtml += `
              <h3 style="margin-top: var(--space-5); margin-bottom: var(--space-2);">${divisionName}</h3>
              <div class="table-container">
                <table class="admin-table">
                  <thead>
                    <tr>
                      <th>Pos</th>
                      <th>Team</th>
                      <th>GP</th>
                      <th>W</th>
                      <th>D</th>
                      <th>L</th>
                      <th>GF</th>
                      <th>GA</th>
                      <th>GD</th>
                      <th>Pts</th>
                    </tr>
                  </thead>
                  <tbody>
                    ${teams.map((team, idx) => `
                      <tr>
                        <td><strong>${idx + 1}</strong></td>
                        <td style="text-align: left;"><strong>${team.team_name}</strong></td>
                        <td>${team.games_played}</td>
                        <td>${team.wins}</td>
                        <td>${team.draws}</td>
                        <td>${team.losses}</td>
                        <td>${team.goals_for}</td>
                        <td>${team.goals_against}</td>
                        <td style="color: ${team.goal_difference > 0 ? 'green' : team.goal_difference < 0 ? 'red' : 'inherit'};">
                          ${team.goal_difference > 0 ? '+' : ''}${team.goal_difference}
                        </td>
                        <td><strong>${team.points}</strong></td>
                      </tr>
                    `).join('')}
                  </tbody>
                </table>
              </div>
            `;
          });
          
          resultsDiv.innerHTML = `
            <h2>${leagueName} - ${season} Season</h2>
            ${tablesHtml}
          `;
        } catch (error) {
          resultsDiv.innerHTML = `<div class="error-message">Error: ${error.message}</div>`;
        }
      });
      
    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading standings: ${error.message}</div>`;
    }
  }

  async loadCoverageReport() {
    const content = this.element.querySelector('.admin-content');
    
    try {
      const response = await fetch('/api/system-admin/coverage');
      if (!response.ok) throw new Error('Failed to load coverage data');
      
      const data = await response.json();
      
      content.innerHTML = `
        <div class="coverage-view">
          <h2>📊 Match Event Coverage Report</h2>
          <p class="subtitle">Coverage by league and source system</p>
          
          <div class="coverage-summary">
            ${data.leagues.map(league => {
              const coveragePct = ((league.matches_with_events / league.total_matches) * 100).toFixed(1);
              const barColor = coveragePct >= 80 ? '#22c55e' : coveragePct >= 50 ? '#f59e0b' : '#ef4444';
              
              return `
                <div class="coverage-card">
                  <h3>${league.league_name || 'Unknown League'}</h3>
                  <div class="coverage-stats">
                    <div class="stat-item">
                      <span class="stat-label">Total Matches</span>
                      <span class="stat-value">${league.total_matches}</span>
                    </div>
                    <div class="stat-item">
                      <span class="stat-label">With Events</span>
                      <span class="stat-value">${league.matches_with_events}</span>
                    </div>
                    <div class="stat-item">
                      <span class="stat-label">Coverage</span>
                      <span class="stat-value" style="color: ${barColor}">${coveragePct}%</span>
                    </div>
                  </div>
                  <div class="progress-bar">
                    <div class="progress-fill" style="width: ${coveragePct}%; background: ${barColor}"></div>
                  </div>
                  <div class="event-breakdown">
                    <div class="event-stat">⚽ ${league.total_goals || 0} Goals</div>
                    <div class="event-stat">🅰️ ${league.total_assists || 0} Assists</div>
                    <div class="event-stat">🔄 ${league.total_subs || 0} Subs</div>
                  </div>
                  <div class="data-gap">
                    <strong>${league.matches_with_score_no_events || 0}</strong> matches have scores but no events
                  </div>
                </div>
              `;
            }).join('')}
          </div>
        </div>
      `;
    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading coverage: ${error.message}</div>`;
    }
  }

  async loadDataQuality() {
    const content = this.element.querySelector('.admin-content');
    
    try {
      const response = await fetch('/api/system-admin/data-quality');
      if (!response.ok) throw new Error('Failed to load data quality');
      
      const data = await response.json();
      
      content.innerHTML = `
        <div class="data-quality-view">
          <h2>🔍 Data Quality Dashboard</h2>
          <p class="subtitle">Identify missing data and scraping issues</p>
          
          <div class="quality-grid">
            <div class="quality-card">
              <h3>⚠️ Missing Match Events</h3>
              <div class="quality-stats">
                <div class="stat-large">${data.missing_events?.total || 0}</div>
                <div class="stat-label">Matches with scores but no goal events</div>
              </div>
              ${data.missing_events?.by_league ? `
                <div class="breakdown">
                  ${data.missing_events.by_league.map(l => `
                    <div class="breakdown-item">
                      <span>${l.league_name}</span>
                      <span class="badge">${l.count}</span>
                    </div>
                  `).join('')}
                </div>
              ` : ''}
            </div>
            
            <div class="quality-card">
              <h3>🚫 Failed Downloads</h3>
              <div class="quality-stats">
                <div class="stat-large">${data.failed_downloads?.total || 0}</div>
                <div class="stat-label">.skip marker files (404s, timeouts)</div>
              </div>
              ${data.failed_downloads?.by_source ? `
                <div class="breakdown">
                  ${data.failed_downloads.by_source.map(s => `
                    <div class="breakdown-item">
                      <span>${s.source}</span>
                      <span class="badge">${s.count}</span>
                    </div>
                  `).join('')}
                </div>
              ` : ''}
            </div>
            
            <div class="quality-card">
              <h3>📦 HTML Cache Status</h3>
              <div class="quality-stats">
                <div class="stat-large">${data.cache_stats?.total_files || 0}</div>
                <div class="stat-label">Cached HTML files</div>
              </div>
              ${data.cache_stats?.by_source ? `
                <div class="breakdown">
                  ${data.cache_stats.by_source.map(s => `
                    <div class="breakdown-item">
                      <span>${s.source}</span>
                      <span class="badge">${s.count} files (${(s.size_mb || 0).toFixed(1)} MB)</span>
                    </div>
                  `).join('')}
                </div>
              ` : ''}
            </div>
            
            <div class="quality-card">
              <h3>👤 Missing Player Data</h3>
              <div class="quality-stats">
                <div class="stat-large">${data.missing_players?.unmatched_count || 0}</div>
                <div class="stat-label">Player references not found in roster</div>
              </div>
              <p class="info-text">This is expected - external rosters may not match 100%</p>
            </div>
          </div>
        </div>
      `;
    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading data quality: ${error.message}</div>`;
    }
  }

  async loadLeagueStats() {
    const content = this.element.querySelector('.admin-content');
    
    try {
      const response = await fetch('/api/system-admin/league-stats');
      if (!response.ok) throw new Error('Failed to load league stats');
      
      const data = await response.json();
      
      content.innerHTML = `
        <div class="league-stats-view">
          <h2>🏆 League Statistics</h2>
          <p class="subtitle">Top performers and league insights</p>
          
          <div class="stats-grid">
            ${data.leagues.map(league => `
              <div class="league-stat-card">
                <h3>${league.league_name}</h3>
                
                <div class="stat-section">
                  <h4>⚽ Top Scorers</h4>
                  <ol class="top-list">
                    ${(league.top_scorers || []).slice(0, 5).map(p => `
                      <li>
                        <span class="player-name">${p.player_name}</span>
                        <span class="badge">${p.goals} goals</span>
                      </li>
                    `).join('')}
                  </ol>
                  ${!league.top_scorers || league.top_scorers.length === 0 ? '<p class="info-text">No goal data available</p>' : ''}
                </div>
                
                <div class="stat-section">
                  <h4>🅰️ Top Assists</h4>
                  <ol class="top-list">
                    ${(league.top_assists || []).slice(0, 5).map(p => `
                      <li>
                        <span class="player-name">${p.player_name}</span>
                        <span class="badge">${p.assists} assists</span>
                      </li>
                    `).join('')}
                  </ol>
                  ${!league.top_assists || league.top_assists.length === 0 ? '<p class="info-text">No assist data available</p>' : ''}
                </div>
                
                <div class="stat-section">
                  <h4>📊 Most Active Teams</h4>
                  <ol class="top-list">
                    ${(league.most_active_teams || []).slice(0, 5).map(t => `
                      <li>
                        <span class="team-name">${t.team_name}</span>
                        <span class="badge">${t.match_count} matches</span>
                      </li>
                    `).join('')}
                  </ol>
                </div>
              </div>
            `).join('')}
          </div>
        </div>
      `;
    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading league stats: ${error.message}</div>`;
    }
  }

  async loadGroupMeEvents() {
    const content = this.element.querySelector('.admin-content');
    try {
      const response = await this.auth.fetch('/api/system-admin/groupme/calendar-events');
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const data = await response.json();
      
      const s = data.summary || {};
      const events = data.events || [];
      const rsvps = data.rsvps || [];
      
      // Index RSVPs by event_id
      const rsvpsByEvent = {};
      rsvps.forEach(r => {
        if (!rsvpsByEvent[r.event_id]) rsvpsByEvent[r.event_id] = [];
        rsvpsByEvent[r.event_id].push(r);
      });
      
      content.innerHTML = `
        <div style="padding: var(--space-4);">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--space-4);">
            <h2>📱 GroupMe Calendar Events</h2>
            <button class="btn btn-secondary refresh-btn">🔄 Refresh</button>
          </div>
          
          <!-- Summary Cards -->
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: var(--space-3); margin-bottom: var(--space-4);">
            <div class="card" style="text-align: center; padding: var(--space-3);">
              <div style="font-size: 2em; font-weight: bold; color: var(--primary);">${s.total_chats || 0}</div>
              <div style="color: var(--text-secondary);">Chats</div>
            </div>
            <div class="card" style="text-align: center; padding: var(--space-3);">
              <div style="font-size: 2em; font-weight: bold; color: var(--primary);">${s.total_events || 0}</div>
              <div style="color: var(--text-secondary);">Events</div>
            </div>
            <div class="card" style="text-align: center; padding: var(--space-3);">
              <div style="font-size: 2em; font-weight: bold; color: var(--primary);">${s.total_rsvps || 0}</div>
              <div style="color: var(--text-secondary);">RSVPs</div>
            </div>
            <div class="card" style="text-align: center; padding: var(--space-3);">
              <div style="font-size: 2em; font-weight: bold; color: var(--success);">${s.linked_rsvps || 0}</div>
              <div style="color: var(--text-secondary);">Linked RSVPs</div>
            </div>
            <div class="card" style="text-align: center; padding: var(--space-3);">
              <div style="font-size: 2em; font-weight: bold; color: var(--info);">${s.total_linked_persons || 0}</div>
              <div style="color: var(--text-secondary);">Linked Persons</div>
            </div>
          </div>
          
          <!-- Events List -->
          ${events.length === 0 ? '<div class="card" style="padding: var(--space-4); text-align: center;"><p>No events synced yet. Run <code>node scripts/sync-groupme-events.js</code> to sync.</p></div>' : events.map(evt => {
            const eventRsvps = rsvpsByEvent[evt.id] || [];
            const going = eventRsvps.filter(r => r.status_id === 1);
            const notGoing = eventRsvps.filter(r => r.status_id === 2);
            const maybe = eventRsvps.filter(r => r.status_id === 3);
            
            const startDate = evt.start_at ? new Date(evt.start_at) : null;
            const dateStr = startDate ? startDate.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' }) : (evt.event_date || 'No date');
            const timeStr = startDate ? startDate.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' }) : '';
            
            // Determine event type badge
            let typeBadge = '';
            if (evt.match_id && evt.match_type) {
              typeBadge = `<span style="background: var(--primary); color: white; padding: 2px 8px; border-radius: 12px; font-size: 0.75em; margin-left: 8px;">${evt.match_type}</span>`;
            }
            
            const renderRsvpList = (list, color) => list.map(r => 
              `<span style="display: inline-block; padding: 2px 8px; margin: 2px; border-radius: 12px; font-size: 0.8em; background: ${r.linked ? color : '#e9ecef'}; color: ${r.linked ? 'white' : '#666'};" title="${r.linked ? 'Linked to person' : 'Not linked'}">${r.name}</span>`
            ).join('');
            
            return `
              <div class="card" style="padding: var(--space-3); margin-bottom: var(--space-3);">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: var(--space-2);">
                  <div>
                    <h3 style="margin: 0;">${evt.title}${typeBadge}</h3>
                    <div style="color: var(--text-secondary); font-size: 0.9em; margin-top: 4px;">
                      📅 ${dateStr} ${timeStr ? '&bull; 🕐 ' + timeStr : ''}
                      ${evt.location ? '&bull; 📍 ' + evt.location : ''}
                    </div>
                    <div style="color: var(--text-secondary); font-size: 0.85em; margin-top: 2px;">💬 ${evt.chat_name}</div>
                    ${evt.match_id && evt.home_team ? `<div style="font-size: 0.85em; margin-top: 4px;">⚽ ${evt.home_team} ${evt.home_score !== null ? evt.home_score : ''} vs ${evt.away_score !== null ? evt.away_score : ''} ${evt.away_team}</div>` : ''}
                  </div>
                  <div style="text-align: right; white-space: nowrap;">
                    <span style="color: var(--success); font-weight: bold;">✓${evt.going}</span>
                    <span style="color: var(--danger); margin-left: 8px;">✗${evt.not_going}</span>
                    <span style="color: var(--warning); margin-left: 8px;">?${evt.maybe}</span>
                  </div>
                </div>
                
                <details style="margin-top: var(--space-2);">
                  <summary style="cursor: pointer; color: var(--primary); font-size: 0.9em;">Show RSVPs (${eventRsvps.length})</summary>
                  <div style="margin-top: var(--space-2);">
                    ${going.length > 0 ? `<div style="margin-bottom: var(--space-2);"><strong style="color: var(--success);">Going (${going.length}):</strong><div>${renderRsvpList(going, '#28a745')}</div></div>` : ''}
                    ${notGoing.length > 0 ? `<div style="margin-bottom: var(--space-2);"><strong style="color: var(--danger);">Not Going (${notGoing.length}):</strong><div>${renderRsvpList(notGoing, '#dc3545')}</div></div>` : ''}
                    ${maybe.length > 0 ? `<div style="margin-bottom: var(--space-2);"><strong style="color: var(--warning);">Maybe (${maybe.length}):</strong><div>${renderRsvpList(maybe, '#ffc107')}</div></div>` : ''}
                    ${eventRsvps.length === 0 ? '<p style="color: var(--text-secondary);">No RSVPs recorded</p>' : ''}
                  </div>
                </details>
              </div>
            `;
          }).join('')}
        </div>
      `;
    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading GroupMe events: ${error.message}</div>`;
    }
  }
}
