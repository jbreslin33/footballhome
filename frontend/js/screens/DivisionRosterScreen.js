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
      
      // Handle edit player button
      const editBtn = e.target.closest('.view-player-btn');
      if (editBtn) {
        const playerId = editBtn.getAttribute('data-player-id');
        this.editPlayer(playerId);
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
      this.players = response.data || [];
      
      this.renderList('#player-list', this.players,
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
              <button class="btn btn-sm btn-secondary view-player-btn" data-player-id="${p.player_id}">Edit</button>
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

  editPlayer(playerId) {
    const player = this.players.find(p => p.player_id === playerId);
    if (!player) return;
    
    const modal = document.createElement('div');
    modal.className = 'modal-overlay';
    modal.innerHTML = `
      <div class="modal-content">
        <h2>Edit Player</h2>
        <p class="subtitle">${player.first_name} ${player.last_name}</p>
        
        <div style="margin-bottom: var(--space-3);">
          <label style="display: block; margin-bottom: var(--space-1); font-weight: bold;">First Name</label>
          <input type="text" id="edit-first-name" value="${player.first_name || ''}" 
                 style="width: 100%; padding: var(--space-2); border: 1px solid var(--color-border); border-radius: 4px; font-size: 1rem;">
        </div>

        <div style="margin-bottom: var(--space-3);">
          <label style="display: block; margin-bottom: var(--space-1); font-weight: bold;">Last Name</label>
          <input type="text" id="edit-last-name" value="${player.last_name || ''}" 
                 style="width: 100%; padding: var(--space-2); border: 1px solid var(--color-border); border-radius: 4px; font-size: 1rem;">
        </div>
        
        <div style="margin-bottom: var(--space-3);">
          <label style="display: block; margin-bottom: var(--space-1); font-weight: bold;">Status</label>
          <select id="edit-status" style="width: 100%; padding: var(--space-2); border: 1px solid var(--color-border); border-radius: 4px; font-size: 1rem;">
            <option value="active" ${player.status === 'active' ? 'selected' : ''}>Active</option>
            <option value="inactive" ${player.status === 'inactive' ? 'selected' : ''}>Inactive</option>
            <option value="suspended" ${player.status === 'suspended' ? 'selected' : ''}>Suspended</option>
            <option value="waitlist" ${player.status === 'waitlist' ? 'selected' : ''}>Waitlist</option>
          </select>
        </div>
        
        <div style="margin-bottom: var(--space-3);">
          <label style="display: block; margin-bottom: var(--space-1); font-weight: bold;">Registration Number</label>
          <input type="text" id="edit-reg-number" value="${player.registration_number || ''}" 
                 style="width: 100%; padding: var(--space-2); border: 1px solid var(--color-border); border-radius: 4px; font-size: 1rem;">
        </div>
        
        <div style="display: flex; gap: var(--space-2); justify-content: flex-end;">
          <button id="edit-cancel" class="btn btn-secondary">Cancel</button>
          <button id="edit-save" class="btn btn-primary">💾 Save Changes</button>
        </div>
      </div>
    `;
    
    document.body.appendChild(modal);
    
    // Focus first name input
    modal.querySelector('#edit-first-name').focus();
    
    // Event handlers
    modal.querySelector('#edit-cancel').addEventListener('click', () => {
      modal.remove();
    });
    
    modal.querySelector('#edit-save').addEventListener('click', async () => {
      const firstName = modal.querySelector('#edit-first-name').value;
      const lastName = modal.querySelector('#edit-last-name').value;
      const status = modal.querySelector('#edit-status').value;
      const regNumber = modal.querySelector('#edit-reg-number').value;
      
      try {
        const response = await fetch(`/api/divisions/${this.division.id}/players/${playerId}`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          },
          body: JSON.stringify({
            firstName: firstName,
            lastName: lastName,
            status: status,
            registrationNumber: regNumber
          })
        });
        
        const result = await response.json();
        
        if (result.success) {
          modal.remove();
          // Reload roster to show changes
          this.loadPlayers();
        } else {
          alert('Failed to update player: ' + result.message);
        }
      } catch (error) {
        console.error('Error updating player:', error);
        alert('Failed to update player. Please try again.');
      }
    });
    
    // Close on overlay click
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        modal.remove();
      }
    });
  }
}
