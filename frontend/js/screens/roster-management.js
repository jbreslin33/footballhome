// RosterManagementScreen - view and edit team roster
class RosterManagementScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.roster = [];
    this.editMode = false;
  }

  render() {
    const teamName = this.navigation.context.team?.name || 'Unknown Team';
    const teamId = this.navigation.context.team?.id;
    
    const div = document.createElement('div');
    div.className = 'screen screen-roster-management';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1>👥 ${teamName} Roster</h1>
        <p class="subtitle">View and manage your team roster</p>
      </div>
      
      <div style="padding: var(--space-4); max-width: 1000px; margin: 0 auto;">
        <div style="margin-bottom: var(--space-3); display: flex; justify-content: space-between; align-items: center;">
          <button id="toggle-edit-btn" class="btn btn-secondary">
            ✏️ Edit Roster
          </button>
          <button id="add-player-btn" class="btn btn-primary" style="display: none;">
            ➕ Add Player
          </button>
        </div>
        
        <div id="roster-loading" style="text-align: center; padding: var(--space-4);">
          <div class="spinner"></div>
          <p>Loading roster...</p>
        </div>
        
        <div id="roster-container" style="display: none;">
          <!-- Roster will be loaded here -->
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  async onEnter(params) {
    const teamId = this.navigation.context.team?.id;
    
    // Load roster data
    await this.loadRoster(teamId);
    
    // Event listeners
    this.element.addEventListener('click', async (e) => {
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      if (e.target.id === 'toggle-edit-btn' || e.target.closest('#toggle-edit-btn')) {
        this.toggleEditMode();
        return;
      }
      
      if (e.target.id === 'add-player-btn' || e.target.closest('#add-player-btn')) {
        this.addPlayer();
        return;
      }
      
      // Handle edit/remove buttons for individual players
      const editBtn = e.target.closest('[data-action="edit"]');
      if (editBtn) {
        const playerId = editBtn.getAttribute('data-player-id');
        this.editPlayer(playerId);
        return;
      }
      
      const removeBtn = e.target.closest('[data-action="remove"]');
      if (removeBtn) {
        const playerId = removeBtn.getAttribute('data-player-id');
        this.removePlayer(playerId);
        return;
      }
    });
  }
  
  async loadRoster(teamId) {
    try {
      const response = await fetch(`/api/teams/${teamId}/roster`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      if (!response.ok) {
        throw new Error('Failed to load roster');
      }
      
      const result = await response.json();
      this.roster = result.data || [];
      
      // Hide loading, show roster
      this.element.querySelector('#roster-loading').style.display = 'none';
      this.element.querySelector('#roster-container').style.display = 'block';
      
      this.renderRoster();
      
    } catch (error) {
      console.error('Error loading roster:', error);
      this.element.querySelector('#roster-loading').innerHTML = `
        <p style="color: var(--color-danger);">❌ Failed to load roster</p>
      `;
    }
  }
  
  renderRoster() {
    const container = this.element.querySelector('#roster-container');
    
    // Separate players and coaches
    const players = this.roster.filter(member => member.roleType === 'PLAYER');
    const coaches = this.roster.filter(member => member.roleType === 'COACH');
    
    let html = '';
    
    // Coaches section
    if (coaches.length > 0) {
      html += `
        <div style="margin-bottom: var(--space-4);">
          <h2 style="font-size: 1.5rem; margin-bottom: var(--space-3); border-bottom: 2px solid var(--color-primary); padding-bottom: var(--space-2);">
            👨‍🏫 Coaching Staff (${coaches.length})
          </h2>
          <div class="roster-table">
            ${this.renderTable(coaches, true)}
          </div>
        </div>
      `;
    }
    
    // Players section
    html += `
      <div>
        <h2 style="font-size: 1.5rem; margin-bottom: var(--space-3); border-bottom: 2px solid var(--color-primary); padding-bottom: var(--space-2);">
          ⚽ Players (${players.length})
        </h2>
        <div class="roster-table">
          ${this.renderTable(players, false)}
        </div>
      </div>
    `;
    
    container.innerHTML = html;
  }
  
  renderTable(members, isCoach) {
    if (members.length === 0) {
      return '<p style="text-align: center; padding: var(--space-3); color: var(--color-text-secondary);">No members found</p>';
    }
    
    let html = `
      <table style="width: 100%; border-collapse: collapse;">
        <thead>
          <tr style="background: var(--color-background-secondary); border-bottom: 2px solid var(--color-border);">
            <th style="padding: var(--space-2); text-align: left; width: 60px;"></th>
            ${!isCoach ? '<th style="padding: var(--space-2); text-align: left; width: 50px;">#</th>' : ''}
            <th style="padding: var(--space-2); text-align: left;">Name</th>
            <th style="padding: var(--space-2); text-align: left;">Position/Role</th>
            <th style="padding: var(--space-2); text-align: left;">Email</th>
            ${!isCoach ? '<th style="padding: var(--space-2); text-align: center;">Captain</th>' : ''}
            ${this.editMode ? '<th style="padding: var(--space-2); text-align: center;">Actions</th>' : ''}
          </tr>
        </thead>
        <tbody>
    `;
    
    members.forEach(member => {
      const captainBadge = member.isCaptain ? '🏅 C' : (member.isViceCaptain ? '🎖️ VC' : '');
      const photoUrl = member.photoUrl || null;
      const initial = member.name ? member.name[0].toUpperCase() : '?';
      const avatarHtml = photoUrl
        ? `<img src="${photoUrl}" style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover; border: 2px solid var(--color-border);" alt="${member.name}">`
        : `<div style="width: 40px; height: 40px; border-radius: 50%; background: var(--color-primary); color: white; display: flex; align-items: center; justify-content: center; font-weight: bold;">${initial}</div>`;
      
      html += `
        <tr style="border-bottom: 1px solid var(--color-border);">
          <td style="padding: var(--space-2);">${avatarHtml}</td>
          ${!isCoach ? `<td style="padding: var(--space-2); font-weight: bold;">${member.jerseyNumber || '-'}</td>` : ''}
          <td style="padding: var(--space-2);">
            ${member.name}
          </td>
          <td style="padding: var(--space-2);">${member.position || '-'}</td>
          <td style="padding: var(--space-2); color: var(--color-text-secondary); font-size: 0.9em;">${member.email}</td>
          ${!isCoach ? `<td style="padding: var(--space-2); text-align: center;">${captainBadge}</td>` : ''}
          ${this.editMode ? `
            <td style="padding: var(--space-2); text-align: center;">
              <button class="btn btn-sm btn-secondary" data-action="edit" data-player-id="${member.id}" style="margin-right: var(--space-1);">
                ✏️ Edit
              </button>
              <button class="btn btn-sm btn-danger" data-action="remove" data-player-id="${member.id}">
                🗑️ Remove
              </button>
            </td>
          ` : ''}
        </tr>
      `;
    });
    
    html += `
        </tbody>
      </table>
    `;
    
    return html;
  }
  
  toggleEditMode() {
    this.editMode = !this.editMode;
    
    const toggleBtn = this.element.querySelector('#toggle-edit-btn');
    const addBtn = this.element.querySelector('#add-player-btn');
    
    if (this.editMode) {
      toggleBtn.innerHTML = '✅ Done Editing';
      toggleBtn.classList.remove('btn-secondary');
      toggleBtn.classList.add('btn-success');
      addBtn.style.display = 'inline-block';
    } else {
      toggleBtn.innerHTML = '✏️ Edit Roster';
      toggleBtn.classList.remove('btn-success');
      toggleBtn.classList.add('btn-secondary');
      addBtn.style.display = 'none';
    }
    
    this.renderRoster();
  }
  
  addPlayer() {
    alert('Add Player functionality coming soon!\n\nThis will allow you to:\n- Search for existing users\n- Invite new players via email\n- Set jersey number and position\n- Assign captain/vice-captain roles');
  }
  
  editPlayer(playerId) {
    const player = this.roster.find(p => p.id === playerId);
    if (!player) return;
    
    // Create edit modal
    const modal = document.createElement('div');
    modal.className = 'modal-overlay';
    modal.innerHTML = `
      <div class="modal-content" style="max-width: 450px;">
        <h2 style="margin-bottom: var(--space-3);">✏️ Edit Player</h2>
        <p style="margin-bottom: var(--space-4); color: var(--color-text-secondary);">${player.name}</p>
        
        <div style="margin-bottom: var(--space-3);">
          <label style="display: block; margin-bottom: var(--space-1); font-weight: bold;">First Name</label>
          <input type="text" id="edit-first-name" value="${player.name.split(' ')[0] || ''}" 
                 style="width: 100%; padding: var(--space-2); border: 1px solid var(--color-border); border-radius: 4px; font-size: 1rem;">
        </div>

        <div style="margin-bottom: var(--space-3);">
          <label style="display: block; margin-bottom: var(--space-1); font-weight: bold;">Last Name</label>
          <input type="text" id="edit-last-name" value="${player.name.split(' ').slice(1).join(' ') || ''}" 
                 style="width: 100%; padding: var(--space-2); border: 1px solid var(--color-border); border-radius: 4px; font-size: 1rem;">
        </div>

        <div style="margin-bottom: var(--space-3);">
          <label style="display: block; margin-bottom: var(--space-1); font-weight: bold;">Jersey Number</label>
          <input type="number" id="edit-jersey" value="${player.jerseyNumber || ''}" min="1" max="99" 
                 style="width: 100%; padding: var(--space-2); border: 1px solid var(--color-border); border-radius: 4px; font-size: 1rem;">
        </div>
        
        <div style="margin-bottom: var(--space-3);">
          <label style="display: block; margin-bottom: var(--space-1); font-weight: bold;">Status</label>
          <select id="edit-status" style="width: 100%; padding: var(--space-2); border: 1px solid var(--color-border); border-radius: 4px; font-size: 1rem;">
            <option value="1" ${player.rosterStatusId === 1 ? 'selected' : ''}>Active Player</option>
            <option value="2" ${player.rosterStatusId === 2 ? 'selected' : ''}>Inactive</option>
            <option value="3" ${player.rosterStatusId === 3 ? 'selected' : ''}>Injured</option>
            <option value="4" ${player.rosterStatusId === 4 ? 'selected' : ''}>Away</option>
          </select>
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
    
    // Focus first name input
    modal.querySelector('#edit-first-name').focus();
    
    // Event handlers
    modal.querySelector('#edit-cancel').addEventListener('click', () => {
      modal.remove();
    });
    
    modal.querySelector('#edit-save').addEventListener('click', async () => {
      const firstName = modal.querySelector('#edit-first-name').value;
      const lastName = modal.querySelector('#edit-last-name').value;
      const jerseyNumber = modal.querySelector('#edit-jersey').value;
      const rosterStatusId = modal.querySelector('#edit-status').value;
      const isCaptain = modal.querySelector('#edit-captain').checked;
      const isViceCaptain = modal.querySelector('#edit-vice-captain').checked;
      
      // Can't be both captain and vice captain
      if (isCaptain && isViceCaptain) {
        alert('A player cannot be both Captain and Vice Captain');
        return;
      }
      
      const teamId = this.navigation.context.team?.id;
      
      try {
        const response = await fetch(`/api/teams/${teamId}/roster/${playerId}`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          },
          body: JSON.stringify({
            firstName: firstName,
            lastName: lastName,
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
  
  async removePlayer(playerId) {
    const player = this.roster.find(p => p.id === playerId);
    if (!player) return;
    
    if (confirm(`Remove ${player.name} from the roster?\n\nThis will mark them as inactive but preserve their history.`)) {
      const teamId = this.navigation.context.team?.id;
      
      try {
        const response = await fetch(`/api/teams/${teamId}/roster/${playerId}`, {
          method: 'DELETE',
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        
        const result = await response.json();
        
        if (result.success) {
          // Reload roster to show changes
          await this.loadRoster(teamId);
        } else {
          alert('Failed to remove player: ' + result.message);
        }
      } catch (error) {
        console.error('Error removing player:', error);
        alert('Failed to remove player. Please try again.');
      }
    }
  }
}
