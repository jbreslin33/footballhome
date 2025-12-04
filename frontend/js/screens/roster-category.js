// RosterCategoryScreen - view and edit players in a specific roster status category
class RosterCategoryScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.roster = [];
    this.rosterStatuses = [];
    this.category = 'active';
  }

  getCategoryInfo(category) {
    const categories = {
      active: { title: 'Active Players', icon: '✅', description: 'Players currently participating with the team' },
      official_inactive: { title: 'Registered (Inactive)', icon: '📝', description: 'On official roster but not currently participating' },
      trial: { title: 'On Trial', icon: '🔄', description: 'Trialing with team, not yet on official roster' },
      injured_reserve: { title: 'Injured Reserve', icon: '🏥', description: 'Injured players not on official roster' },
      suspended: { title: 'Suspended', icon: '⚠️', description: 'Temporarily suspended from team activities' },
      departed: { title: 'Departed', icon: '👋', description: 'Players who have left the team' }
    };
    return categories[category] || { title: 'Players', icon: '👥', description: '' };
  }

  render() {
    // Reset listener flag since we're creating a new element
    this._listenersAttached = false;
    
    const teamName = this.navigation.context.team?.name || 'Unknown Team';
    
    const div = document.createElement('div');
    div.className = 'screen screen-roster-category';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1 id="category-title">Loading...</h1>
        <p class="subtitle" id="category-description"></p>
      </div>
      
      <div style="padding: var(--space-4); max-width: 1000px; margin: 0 auto;">
        <div id="roster-loading" style="text-align: center; padding: var(--space-4);">
          <div class="spinner"></div>
          <p>Loading players...</p>
        </div>
        
        <div id="roster-container" style="display: none;">
          <!-- Players table will be rendered here -->
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  async onEnter(params) {
    this.category = params?.category || 'active';
    const categoryInfo = this.getCategoryInfo(this.category);
    
    // Update header
    this.element.querySelector('#category-title').textContent = `${categoryInfo.icon} ${categoryInfo.title}`;
    this.element.querySelector('#category-description').textContent = categoryInfo.description;
    
    const teamId = this.navigation.context.team?.id;
    
    // Load roster data and statuses
    await Promise.all([
      this.loadRoster(teamId),
      this.loadRosterStatuses()
    ]);
    
    this.renderPlayers();
    
    // Only attach event listener once
    // Only attach event listener once
    if (!this._listenersAttached) {
      this._listenersAttached = true;
      this.element.addEventListener('click', async (e) => {
        e.stopPropagation();
        
        if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
          this.navigation.goBack();
          return;
        }
        
        // Handle edit button
        const editBtn = e.target.closest('[data-action="edit"]');
        if (editBtn) {
          e.preventDefault();
          const playerId = editBtn.getAttribute('data-player-id');
          this.editPlayer(playerId);
          return;
        }
      });
    }
  }
  
  async loadRoster(teamId) {
    try {
      const response = await this.auth.fetch(`/api/teams/${teamId}/roster`);
      const result = await response.json();
      this.roster = result.data || [];
    } catch (error) {
      console.error('Error loading roster:', error);
      this.roster = [];
    }
  }
  
  async loadRosterStatuses() {
    try {
      const response = await this.auth.fetch('/api/teams/roster-statuses');
      const result = await response.json();
      this.rosterStatuses = result.data || [];
    } catch (error) {
      console.error('Error loading roster statuses:', error);
      this.rosterStatuses = [];
    }
  }
  
  getPlayersForCategory() {
    const players = this.roster.filter(m => m.roleType === 'PLAYER');
    
    switch (this.category) {
      case 'active':
        return players.filter(p => p.rosterStatusCode === 'active');
      case 'official_inactive':
        return players.filter(p => p.rosterStatusCode === 'official_inactive');
      case 'trial':
        return players.filter(p => p.rosterStatusCode === 'trial');
      case 'injured_reserve':
        return players.filter(p => p.rosterStatusCode === 'injured_reserve');
      case 'suspended':
        return players.filter(p => p.rosterStatusCode === 'suspended');
      case 'departed':
        return players.filter(p => p.rosterStatusCode === 'departed' || !p.isActive);
      default:
        return players;
    }
  }
  
  renderPlayers() {
    // Hide loading, show container
    this.element.querySelector('#roster-loading').style.display = 'none';
    this.element.querySelector('#roster-container').style.display = 'block';
    
    const container = this.element.querySelector('#roster-container');
    const players = this.getPlayersForCategory();
    
    if (players.length === 0) {
      container.innerHTML = `
        <div style="text-align: center; padding: var(--space-6); color: var(--color-text-secondary);">
          <p style="font-size: 3rem; margin-bottom: var(--space-3);">📭</p>
          <p>No players in this category</p>
        </div>
      `;
      return;
    }
    
    let html = `
      <table style="width: 100%; border-collapse: collapse;">
        <thead>
          <tr style="background: var(--color-background-secondary); border-bottom: 2px solid var(--color-border);">
            <th style="padding: var(--space-2); text-align: left; width: 60px;"></th>
            <th style="padding: var(--space-2); text-align: left; width: 50px;">#</th>
            <th style="padding: var(--space-2); text-align: left;">Name</th>
            <th style="padding: var(--space-2); text-align: left;">Position</th>
            <th style="padding: var(--space-2); text-align: center; width: 80px;">Captain</th>
            <th style="padding: var(--space-2); text-align: center; width: 100px;">Actions</th>
          </tr>
        </thead>
        <tbody>
    `;
    
    players.forEach(player => {
      const captainBadge = player.isCaptain ? '🏅 C' : (player.isViceCaptain ? '🎖️ VC' : '');
      const photoUrl = player.photoUrl || null;
      const initial = player.name ? player.name[0].toUpperCase() : '?';
      const avatarHtml = photoUrl
        ? `<img src="${photoUrl}" style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover; border: 2px solid var(--color-border);" alt="${player.name}">`
        : `<div style="width: 40px; height: 40px; border-radius: 50%; background: var(--color-primary); color: white; display: flex; align-items: center; justify-content: center; font-weight: bold;">${initial}</div>`;
      
      html += `
        <tr style="border-bottom: 1px solid var(--color-border);">
          <td style="padding: var(--space-2);">${avatarHtml}</td>
          <td style="padding: var(--space-2); font-weight: bold; color: var(--color-primary);">
            ${player.jerseyNumber || '-'}
          </td>
          <td style="padding: var(--space-2);">
            <div style="font-weight: 500;">${player.name}</div>
            <div style="font-size: 0.85em; color: var(--color-text-secondary);">${player.email}</div>
          </td>
          <td style="padding: var(--space-2); color: var(--color-text-secondary);">
            ${player.position || 'Not set'}
          </td>
          <td style="padding: var(--space-2); text-align: center;">
            ${captainBadge}
          </td>
          <td style="padding: var(--space-2); text-align: center;">
            <button class="btn btn-sm btn-secondary" data-action="edit" data-player-id="${player.id}">
              ✏️ Edit
            </button>
          </td>
        </tr>
      `;
    });
    
    html += `
        </tbody>
      </table>
      <p style="margin-top: var(--space-3); color: var(--color-text-secondary); font-size: 0.9em;">
        ${players.length} player${players.length !== 1 ? 's' : ''} in this category
      </p>
    `;
    
    container.innerHTML = html;
  }
  
  editPlayer(playerId) {
    const player = this.roster.find(p => p.id === playerId);
    if (!player) return;
    
    // Remove any existing modals first
    document.querySelectorAll('.modal-overlay').forEach(m => m.remove());
    
    // Create edit modal
    const modal = document.createElement('div');
    modal.className = 'modal-overlay';
    modal.innerHTML = `
      <div class="modal-content" style="max-width: 500px;">
        <h2 style="margin-bottom: var(--space-3);">✏️ Edit Player</h2>
        <p style="margin-bottom: var(--space-4); color: var(--color-text-secondary); font-size: 1.1em;">${player.name}</p>
        
        <div style="margin-bottom: var(--space-3);">
          <label style="display: block; margin-bottom: var(--space-1); font-weight: bold;">Jersey Number</label>
          <input type="number" id="edit-jersey" value="${player.jerseyNumber || ''}" min="1" max="99" 
                 style="width: 100%; padding: var(--space-2); border: 1px solid var(--color-border); border-radius: 4px; font-size: 1rem;">
        </div>
        
        <div style="margin-bottom: var(--space-3);">
          <label style="display: block; margin-bottom: var(--space-1); font-weight: bold;">Roster Status</label>
          <select id="edit-status" style="width: 100%; padding: var(--space-2); border: 1px solid var(--color-border); border-radius: 4px; font-size: 1rem;">
            ${this.rosterStatuses.map(status => `
              <option value="${status.id}" ${player.rosterStatusId === status.id ? 'selected' : ''}>
                ${status.displayName}
              </option>
            `).join('')}
          </select>
          <p id="status-description" style="margin-top: var(--space-1); font-size: 0.85em; color: var(--color-text-secondary);">
            ${this.rosterStatuses.find(s => s.id === player.rosterStatusId)?.description || ''}
          </p>
        </div>
        
        <div style="margin-bottom: var(--space-3);">
          <label style="display: flex; align-items: center; gap: var(--space-2); cursor: pointer;">
            <input type="checkbox" id="edit-captain" ${player.isCaptain ? 'checked' : ''}>
            <span>🏅 Team Captain</span>
          </label>
        </div>
        
        <div style="margin-bottom: var(--space-4);">
          <label style="display: flex; align-items: center; gap: var(--space-2); cursor: pointer;">
            <input type="checkbox" id="edit-vice-captain" ${player.isViceCaptain ? 'checked' : ''}>
            <span>🎖️ Vice Captain</span>
          </label>
        </div>
        
        <div style="display: flex; gap: var(--space-2); justify-content: flex-end;">
          <button id="edit-cancel" class="btn btn-secondary">Cancel</button>
          <button id="edit-save" class="btn btn-primary">💾 Save Changes</button>
        </div>
      </div>
    `;
    
    document.body.appendChild(modal);
    
    // Update description when status changes
    modal.querySelector('#edit-status').addEventListener('change', (e) => {
      const statusId = parseInt(e.target.value);
      const status = this.rosterStatuses.find(s => s.id === statusId);
      modal.querySelector('#status-description').textContent = status?.description || '';
    });
    
    // Focus jersey input
    modal.querySelector('#edit-jersey').focus();
    
    // Event handlers
    modal.querySelector('#edit-cancel').addEventListener('click', () => {
      modal.remove();
    });
    
    modal.querySelector('#edit-save').addEventListener('click', async () => {
      const jerseyNumber = modal.querySelector('#edit-jersey').value;
      const rosterStatusId = parseInt(modal.querySelector('#edit-status').value);
      const isCaptain = modal.querySelector('#edit-captain').checked;
      const isViceCaptain = modal.querySelector('#edit-vice-captain').checked;
      
      // Can't be both captain and vice captain
      if (isCaptain && isViceCaptain) {
        alert('A player cannot be both Captain and Vice Captain');
        return;
      }
      
      const teamId = this.navigation.context.team?.id;
      
      try {
        const response = await this.auth.fetch(`/api/teams/${teamId}/roster/${playerId}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            jerseyNumber: jerseyNumber ? parseInt(jerseyNumber) : null,
            rosterStatusId: rosterStatusId,
            isCaptain: isCaptain,
            isViceCaptain: isViceCaptain
          })
        });
        
        const result = await response.json();
        
        if (result.success) {
          modal.remove();
          // Reload roster to show changes
          await this.loadRoster(teamId);
          this.renderPlayers();
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
