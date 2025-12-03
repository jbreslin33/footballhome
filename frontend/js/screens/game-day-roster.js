// GameDayRosterScreen - Coach selects players for game day roster
class GameDayRosterScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.players = [];
    this.selectedPlayerIds = new Set();
    this._listenersAttached = false;
  }

  render() {
    // Reset listener flag since we're creating a new element
    this._listenersAttached = false;
    
    const match = this.navigation.context.match || {};
    const teamName = this.navigation.context.team?.name || 'Unknown Team';
    
    const div = document.createElement('div');
    div.className = 'screen screen-game-day-roster';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1>📋 Game Day Roster</h1>
        <p class="subtitle">${match.title || 'Match'} - ${teamName}</p>
      </div>
      
      <div style="padding: var(--space-4); max-width: 600px; margin: 0 auto;">
        <div id="roster-loading" style="text-align: center; padding: var(--space-4);">
          <div class="spinner"></div>
          <p>Loading players...</p>
        </div>
        
        <div id="roster-content" style="display: none;">
          <div style="background: var(--color-surface); padding: var(--space-3); border-radius: var(--radius-md); margin-bottom: var(--space-4);">
            <p style="margin: 0; font-size: 0.9em; color: var(--color-text-muted);">
              ✓ Select players who will be on the game day roster. Players who RSVP'd "Attending" are shown first.
            </p>
          </div>
          
          <div id="selected-count" style="text-align: center; font-weight: bold; margin-bottom: var(--space-3); padding: var(--space-2); background: var(--color-primary); color: white; border-radius: var(--radius-sm);">
            0 players selected
          </div>
          
          <div id="player-list" style="display: flex; flex-direction: column; gap: var(--space-2);">
            <!-- Players will be loaded here -->
          </div>
          
          <div style="margin-top: var(--space-4); display: flex; gap: var(--space-2);">
            <button id="save-roster-btn" class="btn btn-primary btn-lg" style="flex: 1;">
              💾 Save Roster
            </button>
            <button id="select-all-attending-btn" class="btn btn-secondary" style="flex: 0;">
              Select All Attending
            </button>
          </div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    if (this._listenersAttached) return;
    this._listenersAttached = true;
    
    this.loadPlayers();
    
    this.element.addEventListener('click', (e) => {
      // Back button
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      // Player card clicked - toggle selection
      const playerCard = e.target.closest('.player-select-card');
      if (playerCard) {
        const playerId = playerCard.getAttribute('data-player-id');
        this.togglePlayer(playerId);
        return;
      }
      
      // Save button
      if (e.target.id === 'save-roster-btn' || e.target.closest('#save-roster-btn')) {
        this.saveRoster();
        return;
      }
      
      // Select all attending
      if (e.target.id === 'select-all-attending-btn' || e.target.closest('#select-all-attending-btn')) {
        this.selectAllAttending();
        return;
      }
    });
  }
  
  async loadPlayers() {
    const matchId = this.navigation.context.match?.id;
    console.log('GameDayRoster loadPlayers, context:', this.navigation.context);
    console.log('GameDayRoster matchId:', matchId);
    
    if (!matchId) {
      console.error('No match selected');
      this.find('#roster-loading').innerHTML = '<p style="color: var(--color-danger);">No match selected</p>';
      return;
    }
    
    try {
      const response = await this.auth.fetch(`/api/matches/${matchId}/eligible-players`);
      const data = await response.json();
      
      if (data.success) {
        this.players = data.data || [];
        
        // Pre-select players already on the game roster
        this.selectedPlayerIds = new Set(
          this.players.filter(p => p.onGameRoster).map(p => p.playerId)
        );
        
        this.find('#roster-loading').style.display = 'none';
        this.find('#roster-content').style.display = 'block';
        
        this.renderPlayers();
        this.updateSelectedCount();
      } else {
        throw new Error(data.message || 'Failed to load players');
      }
    } catch (error) {
      console.error('Error loading players:', error);
      this.find('#roster-loading').innerHTML = `
        <p style="color: var(--color-danger);">❌ Failed to load players</p>
        <p class="text-muted">${error.message}</p>
      `;
    }
  }
  
  renderPlayers() {
    const container = this.find('#player-list');
    
    if (this.players.length === 0) {
      container.innerHTML = `
        <div class="empty-state" style="text-align: center; padding: var(--space-4);">
          <p>No eligible players found</p>
          <p class="text-muted">Players need to be on the team roster with RSVP enabled</p>
        </div>
      `;
      return;
    }
    
    // Group by RSVP status
    const attending = this.players.filter(p => p.rsvpStatus === 'yes');
    const maybe = this.players.filter(p => p.rsvpStatus === 'maybe');
    const notResponded = this.players.filter(p => !p.rsvpStatus);
    const notAttending = this.players.filter(p => p.rsvpStatus === 'no');
    
    let html = '';
    
    if (attending.length > 0) {
      html += `<div class="player-group-header" style="font-weight: bold; color: var(--color-success); margin-top: var(--space-2);">✓ Attending (${attending.length})</div>`;
      html += attending.map(p => this.renderPlayerCard(p)).join('');
    }
    
    if (maybe.length > 0) {
      html += `<div class="player-group-header" style="font-weight: bold; color: var(--color-warning); margin-top: var(--space-3);">? Maybe (${maybe.length})</div>`;
      html += maybe.map(p => this.renderPlayerCard(p)).join('');
    }
    
    if (notResponded.length > 0) {
      html += `<div class="player-group-header" style="font-weight: bold; color: var(--color-text-muted); margin-top: var(--space-3);">— No Response (${notResponded.length})</div>`;
      html += notResponded.map(p => this.renderPlayerCard(p)).join('');
    }
    
    if (notAttending.length > 0) {
      html += `<div class="player-group-header" style="font-weight: bold; color: var(--color-danger); margin-top: var(--space-3);">✗ Not Attending (${notAttending.length})</div>`;
      html += notAttending.map(p => this.renderPlayerCard(p)).join('');
    }
    
    container.innerHTML = html;
  }
  
  renderPlayerCard(player) {
    const isSelected = this.selectedPlayerIds.has(player.playerId);
    const jerseyDisplay = player.jerseyNumber ? `#${player.jerseyNumber}` : '';
    const positionDisplay = player.position || '';
    
    return `
      <div class="player-select-card ${isSelected ? 'selected' : ''}" 
           data-player-id="${player.playerId}"
           style="
             display: flex;
             align-items: center;
             padding: var(--space-3);
             background: ${isSelected ? 'var(--color-primary)' : 'var(--color-surface)'};
             color: ${isSelected ? 'white' : 'inherit'};
             border-radius: var(--radius-md);
             cursor: pointer;
             transition: all 0.2s ease;
             border: 2px solid ${isSelected ? 'var(--color-primary)' : 'transparent'};
           ">
        <div style="
          width: 32px;
          height: 32px;
          border-radius: 50%;
          background: ${isSelected ? 'white' : 'var(--color-primary)'};
          color: ${isSelected ? 'var(--color-primary)' : 'white'};
          display: flex;
          align-items: center;
          justify-content: center;
          font-weight: bold;
          margin-right: var(--space-3);
          font-size: 0.8em;
        ">
          ${isSelected ? '✓' : (player.firstName ? player.firstName[0] : '?')}
        </div>
        <div style="flex: 1;">
          <div style="font-weight: 500;">
            ${player.firstName} ${player.lastName}
          </div>
          <div style="font-size: 0.85em; opacity: 0.8;">
            ${[jerseyDisplay, positionDisplay].filter(Boolean).join(' · ') || 'No position'}
          </div>
        </div>
        <div style="font-size: 1.2em;">
          ${isSelected ? '☑️' : '☐'}
        </div>
      </div>
    `;
  }
  
  togglePlayer(playerId) {
    if (this.selectedPlayerIds.has(playerId)) {
      this.selectedPlayerIds.delete(playerId);
    } else {
      this.selectedPlayerIds.add(playerId);
    }
    
    this.renderPlayers();
    this.updateSelectedCount();
  }
  
  selectAllAttending() {
    const attending = this.players.filter(p => p.rsvpStatus === 'yes');
    attending.forEach(p => this.selectedPlayerIds.add(p.playerId));
    
    this.renderPlayers();
    this.updateSelectedCount();
  }
  
  updateSelectedCount() {
    const countEl = this.find('#selected-count');
    const count = this.selectedPlayerIds.size;
    countEl.textContent = `${count} player${count !== 1 ? 's' : ''} selected`;
  }
  
  async saveRoster() {
    const matchId = this.navigation.context.match?.id;
    const userId = this.auth.getUser()?.id;
    
    if (!matchId) {
      alert('No match selected');
      return;
    }
    
    const playerIds = Array.from(this.selectedPlayerIds);
    
    console.log('Saving game roster:', { matchId, playerIds });
    
    try {
      const response = await this.auth.fetch(`/api/matches/${matchId}/game-roster`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          player_ids: playerIds,
          added_by: userId
        })
      });
      
      const data = await response.json();
      
      if (data.success) {
        alert(`✓ Game roster saved! ${data.count} players on roster.`);
        this.navigation.goBack();
      } else {
        throw new Error(data.message || 'Failed to save roster');
      }
    } catch (error) {
      console.error('Error saving roster:', error);
      alert('Failed to save roster: ' + error.message);
    }
  }
}
