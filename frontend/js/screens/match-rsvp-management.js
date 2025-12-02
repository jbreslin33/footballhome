// MatchRSVPManagementScreen - Coach manages player RSVPs for matches (inline accordion style)
class MatchRSVPManagementScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.matches = [];
    this.expandedMatchId = null;
    this.teamPlayers = [];
    this.rsvpCache = {}; // Cache RSVPs per match
    this.selectedPlayer = null; // For bottom sheet
  }

  render() {
    const teamName = this.navigation.context.team?.name || 'Unknown Team';
    
    const div = document.createElement('div');
    div.className = 'screen screen-match-rsvp-management';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1>📋 Manage Player RSVPs</h1>
        <p class="subtitle">${teamName}</p>
      </div>
      
      <div style="padding: var(--space-4); max-width: 1000px; margin: 0 auto;">
        <div id="roster-loading" style="text-align: center; padding: var(--space-4);">
          <div class="spinner"></div>
          <p>Loading matches...</p>
        </div>
        
        <div id="match-container" style="display: none;">
          <!-- Matches will be loaded here -->
        </div>
      </div>
      
      <!-- Bottom Sheet for RSVP Selection -->
      <div id="rsvp-bottom-sheet" style="display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; z-index: 1000;">
        <div id="sheet-backdrop" style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5);"></div>
        <div id="sheet-content" style="position: absolute; bottom: 0; left: 0; right: 0; background: white; border-radius: 16px 16px 0 0; padding: var(--space-4); transform: translateY(100%); transition: transform 0.3s ease;">
          <div id="sheet-player-name" style="font-size: 1.2em; font-weight: bold; margin-bottom: var(--space-3); text-align: center;"></div>
          <div style="display: flex; flex-direction: column; gap: var(--space-2);">
            <button id="sheet-yes" class="btn btn-lg btn-success" style="width: 100%; justify-content: center;">✓ Attending</button>
            <button id="sheet-maybe" class="btn btn-lg btn-warning" style="width: 100%; justify-content: center;">? Maybe</button>
            <button id="sheet-no" class="btn btn-lg btn-danger" style="width: 100%; justify-content: center;">✗ Not Attending</button>
            <button id="sheet-cancel" class="btn btn-lg btn-secondary" style="width: 100%; justify-content: center; margin-top: var(--space-2);">Cancel</button>
          </div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.loadData();
    
    this.element.addEventListener('click', (e) => {
      // Back button
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      // Match header clicked - toggle expansion
      const matchHeader = e.target.closest('.match-header');
      if (matchHeader && !e.target.closest('.rsvp-btn')) {
        const matchId = matchHeader.getAttribute('data-match-id');
        this.toggleMatch(matchId);
        return;
      }
      
      // Player card clicked - show bottom sheet
      const playerCard = e.target.closest('.player-card');
      if (playerCard) {
        const matchId = playerCard.getAttribute('data-match-id');
        const playerId = playerCard.getAttribute('data-player-id');
        const playerName = playerCard.getAttribute('data-player-name');
        this.showBottomSheet(matchId, playerId, playerName);
        return;
      }
      
      // Bottom sheet backdrop clicked - close sheet
      if (e.target.id === 'sheet-backdrop') {
        this.hideBottomSheet();
        return;
      }
      
      // Bottom sheet button clicked
      const sheetBtn = e.target.closest('#sheet-yes, #sheet-maybe, #sheet-no, #sheet-cancel');
      if (sheetBtn) {
        if (sheetBtn.id === 'sheet-cancel') {
          this.hideBottomSheet();
        } else {
          const status = {
            'sheet-yes': 'attending',
            'sheet-maybe': 'maybe',
            'sheet-no': 'not_attending'
          }[sheetBtn.id];
          
          if (this.selectedPlayer && status) {
            this.updatePlayerRSVP(this.selectedPlayer.matchId, this.selectedPlayer.playerId, status);
            this.hideBottomSheet();
          }
        }
        return;
      }
    });
  }
  
  showBottomSheet(matchId, playerId, playerName) {
    this.selectedPlayer = { matchId, playerId };
    
    const sheet = this.find('#rsvp-bottom-sheet');
    const content = this.find('#sheet-content');
    const nameEl = this.find('#sheet-player-name');
    
    nameEl.textContent = playerName;
    sheet.style.display = 'block';
    
    // Animate in
    setTimeout(() => {
      content.style.transform = 'translateY(0)';
    }, 10);
  }
  
  hideBottomSheet() {
    const sheet = this.find('#rsvp-bottom-sheet');
    const content = this.find('#sheet-content');
    
    content.style.transform = 'translateY(100%)';
    setTimeout(() => {
      sheet.style.display = 'none';
      this.selectedPlayer = null;
    }, 300);
  }
  
  async loadData() {
    const teamId = this.navigation.context.team?.id;
    if (!teamId) {
      console.error('No team selected');
      return;
    }
    
    try {
      // Load matches and roster in parallel
      const [matchesResponse, rosterResponse] = await Promise.all([
        this.auth.fetch(`/api/matches/team/${teamId}`).then(r => r.json()),
        this.auth.fetch(`/api/teams/${teamId}/roster`).then(r => r.json())
      ]);
      
      this.matches = matchesResponse.data || [];
      this.teamPlayers = (rosterResponse.data || []).filter(p => p.roleType === 'PLAYER');
      
      // Hide loading, show content
      this.find('#roster-loading').style.display = 'none';
      this.find('#match-container').style.display = 'block';
      
      this.renderMatches();
      
    } catch (error) {
      console.error('Error loading data:', error);
      this.find('#roster-loading').innerHTML = `
        <p style="color: var(--color-danger);">❌ Failed to load data</p>
      `;
    }
  }
  
  renderMatches() {
    const container = this.find('#match-container');
    const now = new Date();
    
    if (this.matches.length === 0) {
      container.innerHTML = `
        <div class="empty-state" style="text-align: center; padding: var(--space-4);">
          <p>🏆 No matches found</p>
          <p class="text-muted">Create matches first to manage RSVPs</p>
        </div>
      `;
      return;
    }
    
    // Transform matches for display
    const transformedMatches = this.matches.map(m => {
      const eventDate = new Date(m.event_date);
      const isPast = eventDate < now;
      
      const today = new Date();
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);
      
      let dateDisplay;
      if (eventDate.toDateString() === today.toDateString()) {
        dateDisplay = 'Today';
      } else if (eventDate.toDateString() === tomorrow.toDateString()) {
        dateDisplay = 'Tomorrow';
      } else {
        dateDisplay = eventDate.toLocaleDateString('en-US', { 
          weekday: 'short', 
          month: 'short', 
          day: 'numeric' 
        });
      }
      
      return {
        ...m,
        dateDisplay,
        time: eventDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        isPast
      };
    });
    
    container.innerHTML = transformedMatches.map(m => {
      const isExpanded = this.expandedMatchId === m.id;
      
      return `
        <div class="match-accordion" style="margin-bottom: var(--space-3); border: 1px solid var(--color-border); border-radius: 8px; overflow: hidden; ${m.isPast ? 'opacity: 0.7;' : ''}">
          <div class="match-header" data-match-id="${m.id}" style="display: flex; justify-content: space-between; align-items: center; padding: var(--space-3); background: var(--color-background-secondary); cursor: pointer;">
            <div>
              <strong style="font-size: 1.1em;">${m.title}</strong>
              <div style="font-size: 0.9em; color: var(--color-text-secondary); margin-top: 4px;">
                📅 ${m.dateDisplay} &nbsp; 🕐 ${m.time}
                ${m.venue_name ? ` &nbsp; 📍 ${m.venue_name}` : ''}
              </div>
            </div>
            <div style="display: flex; align-items: center; gap: 12px;">
              <span class="badge ${m.isPast ? 'badge-secondary' : 'badge-primary'}">${m.isPast ? 'Past' : 'Upcoming'}</span>
              <span style="font-size: 1.2em;">${isExpanded ? '▼' : '▶'}</span>
            </div>
          </div>
          <div class="match-players" id="players-${m.id}" style="display: ${isExpanded ? 'block' : 'none'}; padding: 0;">
            ${isExpanded ? this.renderPlayerTable(m.id) : '<div style="padding: var(--space-3); text-align: center;"><div class="spinner"></div></div>'}
          </div>
        </div>
      `;
    }).join('');
  }
  
  async toggleMatch(matchId) {
    if (this.expandedMatchId === matchId) {
      // Collapse
      this.expandedMatchId = null;
      this.renderMatches();
    } else {
      // Expand new match
      this.expandedMatchId = matchId;
      this.renderMatches();
      
      // Load RSVPs if not cached
      if (!this.rsvpCache[matchId]) {
        await this.loadMatchRSVPs(matchId);
      } else {
        // Re-render with cached data
        const playersDiv = this.find(`#players-${matchId}`);
        if (playersDiv) {
          playersDiv.innerHTML = this.renderPlayerTable(matchId);
        }
      }
    }
  }
  
  async loadMatchRSVPs(matchId) {
    try {
      const response = await this.auth.fetch(`/api/events/${matchId}/rsvps?role_type=player`);
      const data = await response.json();
      
      const rsvps = data.data || [];
      
      // Create map of player RSVPs
      const rsvpMap = {};
      rsvps.forEach(rsvp => {
        rsvpMap[rsvp.user_id] = rsvp.status;
      });
      
      this.rsvpCache[matchId] = rsvpMap;
      
      // Re-render the player table
      const playersDiv = this.find(`#players-${matchId}`);
      if (playersDiv) {
        playersDiv.innerHTML = this.renderPlayerTable(matchId);
      }
      
    } catch (err) {
      console.error('Failed to load RSVPs:', err);
      const playersDiv = this.find(`#players-${matchId}`);
      if (playersDiv) {
        playersDiv.innerHTML = `<div style="padding: var(--space-3); color: var(--color-danger);">Failed to load RSVPs</div>`;
      }
    }
  }
  
  renderPlayerTable(matchId) {
    const rsvpMap = this.rsvpCache[matchId] || {};
    
    if (this.teamPlayers.length === 0) {
      return `<div style="padding: var(--space-3); text-align: center; color: var(--color-text-secondary);">No players on roster</div>`;
    }
    
    // Categorize players by status
    const attending = [];
    const notAttending = [];
    const maybe = [];
    const pending = [];
    
    this.teamPlayers.forEach(p => {
      const status = rsvpMap[p.id];
      if (status === 'attending') attending.push(p);
      else if (status === 'not_attending') notAttending.push(p);
      else if (status === 'maybe') maybe.push(p);
      else pending.push(p);
    });
    
    // Sort each category alphabetically
    const sortByName = (a, b) => (a.name || '').localeCompare(b.name || '');
    attending.sort(sortByName);
    maybe.sort(sortByName);
    notAttending.sort(sortByName);
    pending.sort(sortByName);
    
    // Render three-column layout
    const renderColumn = (players, status, title, icon, color) => {
      return `
        <div style="flex: 1; min-width: 250px;">
          <div style="background: ${color}; color: white; padding: var(--space-2); text-align: center; font-weight: bold; border-radius: 8px 8px 0 0;">
            ${icon} ${title} (${players.length})
          </div>
          <div style="border: 2px solid ${color}; border-top: none; border-radius: 0 0 8px 8px; min-height: 200px; background: white;">
            ${players.map(p => this.renderPlayerCard(p, status, matchId)).join('')}
            ${players.length === 0 ? `<div style="padding: var(--space-3); text-align: center; color: var(--color-text-secondary); font-style: italic;">No players</div>` : ''}
          </div>
        </div>
      `;
    };
    
    return `
      <div style="padding: var(--space-3); background: var(--color-background);">
        <div style="display: flex; gap: var(--space-3); flex-wrap: wrap;">
          ${renderColumn(attending, 'attending', 'Yes', '✓', '#16a34a')}
          ${renderColumn(maybe, 'maybe', 'Maybe', '?', '#d97706')}
          ${renderColumn(notAttending, 'not_attending', 'No', '✗', '#dc2626')}
        </div>
        ${pending.length > 0 ? `
          <div style="margin-top: var(--space-3); padding: var(--space-3); background: #fef08a; border: 2px solid #d97706; border-radius: 8px;">
            <div style="font-weight: bold; margin-bottom: var(--space-2); color: #92400e;">⚠️ Pending Responses (${pending.length})</div>
            <div style="display: flex; flex-wrap: wrap; gap: var(--space-2);">
              ${pending.map(p => this.renderPlayerCard(p, null, matchId)).join('')}
            </div>
          </div>
        ` : ''}
      </div>
    `;
  }
  
  renderPlayerCard(player, currentStatus, matchId) {
    const jersey = player.jerseyNumber || '-';
    const name = player.name || 'Unknown';
    
    return `
      <div class="player-card" 
           data-match-id="${matchId}" 
           data-player-id="${player.id}" 
           data-player-name="${name}"
           style="padding: var(--space-3); border-bottom: 1px solid var(--color-border); display: flex; justify-content: space-between; align-items: center; cursor: pointer; transition: background 0.2s;"
           onmouseover="this.style.background='var(--color-background)'" 
           onmouseout="this.style.background='white'">
        <div style="display: flex; align-items: center; gap: var(--space-2);">
          <span style="font-weight: bold; color: var(--color-primary); min-width: 28px; font-size: 1.1em;">#${jersey}</span>
          <span style="font-size: 1.05em;">${name}</span>
        </div>
        <span style="color: var(--color-text-secondary); font-size: 1.2em;">›</span>
      </div>
    `;
  }
  
  updatePlayerRSVP(matchId, playerId, status) {
    const coachId = this.auth.getUser()?.id;
    
    if (!matchId || !playerId || !coachId) {
      console.error('Missing data for RSVP update');
      return;
    }
    
    console.log('Coach updating player RSVP:', { matchId, playerId, status, coachId });
    
    this.auth.fetch(`/api/events/${matchId}/rsvp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        user_id: playerId,
        role_type: 'player',
        status: status,
        notes: 'Set by coach'
      })
    })
    .then(r => {
      if (!r.ok) throw new Error('RSVP update failed');
      return r.json();
    })
    .then(result => {
      console.log('RSVP updated successfully:', result);
      
      // Update cache
      if (!this.rsvpCache[matchId]) {
        this.rsvpCache[matchId] = {};
      }
      this.rsvpCache[matchId][playerId] = status;
      
      // Re-render the player table with new column layout
      const playersDiv = this.find(`#players-${matchId}`);
      if (playersDiv) {
        playersDiv.innerHTML = this.renderPlayerTable(matchId);
      }
    })
    .catch(err => {
      console.error('RSVP update failed:', err);
      alert('Failed to update RSVP. Please try again.');
    });
  }
  
  find(selector) {
    return this.element.querySelector(selector);
  }
}
