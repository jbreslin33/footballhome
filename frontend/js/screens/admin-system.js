// AdminSystemScreen - Super Admin Dashboard
class AdminSystemScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.currentView = 'schema';
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
          <button class="admin-tab active" data-view="schema">🗂️ Schema</button>
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
      
      // Initial fit after network stabilizes
      network.once('stabilizationIterationsDone', () => {
        network.fit({ animation: false });
      });
      
    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading schema: ${error.message}</div>`;
    }
  }
}
