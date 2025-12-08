// DivisionRosterScreen - view and manage division-level player roster
class DivisionRosterScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-division-roster';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>⚽ Division Roster</h1>
        <p class="subtitle" id="division-name-subtitle"></p>
      </div>
      
      <div style="padding: var(--space-4);">
        <div style="margin-bottom: var(--space-3); display: flex; gap: var(--space-2); align-items: center;">
          <select id="status-filter" class="form-control" style="max-width: 200px;">
            <option value="all">All Players</option>
            <option value="active" selected>Active</option>
            <option value="inactive">Inactive</option>
            <option value="suspended">Suspended</option>
            <option value="waitlist">Waitlist</option>
          </select>
          <button class="btn btn-primary" id="add-player-btn">+ Add Player</button>
        </div>
        
        <div id="player-list"></div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    // Expect params like {division: {id, name}}
    this.division = params?.division || this.navigation.context.division;
    
    if (this.division?.name) {
      const subtitle = this.find('#division-name-subtitle');
      if (subtitle) {
        subtitle.textContent = this.division.name;
      }
    }
    
    this.loadPlayers();
    
    // Handle navigation
    this.element.addEventListener('click', (e) => {
      // Handle back button
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      // Handle add player button
      if (e.target.closest('#add-player-btn')) {
        // TODO: Implement add player modal/screen
        alert('Add player functionality coming soon');
        return;
      }
    });
    
    // Handle filter change
    const statusFilter = this.find('#status-filter');
    if (statusFilter) {
      statusFilter.addEventListener('change', () => {
        this.loadPlayers();
      });
    }
  }
  
  loadPlayers() {
    const listContainer = this.find('#player-list');
    listContainer.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading players...</p></div>';
    
    const statusFilter = this.find('#status-filter')?.value || 'active';
    const endpoint = `/api/divisions/${this.division?.id}/players?status=${statusFilter}`;
    
    // Fetch division players
    this.safeFetch(endpoint, response => {
      // Backend returns {success, message, data: [...players...]}
      const players = response.data || [];
      
      this.renderList('#player-list', players,
        p => `
          <div class="card" style="padding: var(--space-3); margin-bottom: var(--space-2);">
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <div>
                <h3 style="margin: 0;">${p.first_name} ${p.last_name}</h3>
                <p style="margin: var(--space-1) 0 0 0; opacity: 0.7;">
                  Status: <span class="badge badge-${p.status}">${p.status}</span>
                  ${p.registration_number ? ` | Reg #: ${p.registration_number}` : ''}
                </p>
              </div>
              <button class="btn btn-sm btn-secondary view-player-btn" data-player-id="${p.player_id}">View</button>
            </div>
          </div>
        `,
        '<div class="empty-state"><p>No players found</p><p class="text-muted">Add players to this division to get started</p></div>'
      );
    }, error => {
      // Show error message if API not implemented yet
      listContainer.innerHTML = `
        <div class="empty-state">
          <p>⚠️ Division roster API not yet implemented</p>
          <p class="text-muted">Backend endpoint ${endpoint} needs to be created</p>
        </div>
      `;
    });
  }
}
