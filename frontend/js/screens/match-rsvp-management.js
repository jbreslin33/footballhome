// MatchRSVPManagementScreen - Coach manages player RSVPs for matches
class MatchRSVPManagementScreen extends Screen {
  render() {
    const teamName = this.navigation.context.team?.name || 'Unknown Team';
    
    const div = document.createElement('div');
    div.className = 'screen screen-match-rsvp-management';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1>📋 Player RSVPs</h1>
        <p class="subtitle">${teamName} - Select a match to manage RSVPs</p>
      </div>
      
      <div style="padding: var(--space-4);">
        <div id="match-list" class="match-cards"></div>
      </div>
      
      <!-- RSVP Management Modal -->
      <div id="rsvp-modal" class="modal" style="display: none;">
        <div class="modal-content" style="max-width: 600px;">
          <div class="modal-header">
            <h2 id="modal-title">Player RSVPs</h2>
            <button id="modal-close" class="btn btn-secondary">✕</button>
          </div>
          <div id="rsvp-list" class="rsvp-list"></div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.teamPlayers = [];
    this.loadMatches();
    
    this.element.addEventListener('click', (e) => {
      // Match card clicked - open RSVP modal
      const matchCard = e.target.closest('[data-match-id]');
      if (matchCard && !e.target.closest('.rsvp-btn')) {
        const matchId = matchCard.getAttribute('data-match-id');
        const matchTitle = matchCard.getAttribute('data-match-title');
        this.openRSVPModal(matchId, matchTitle);
        return;
      }
      
      // RSVP button clicked
      const rsvpBtn = e.target.closest('.rsvp-btn');
      if (rsvpBtn) {
        const playerId = rsvpBtn.getAttribute('data-player-id');
        const status = rsvpBtn.getAttribute('data-status');
        this.updatePlayerRSVP(playerId, status, rsvpBtn);
        return;
      }
      
      // Modal close
      if (e.target.id === 'modal-close' || e.target.id === 'rsvp-modal') {
        this.closeRSVPModal();
        return;
      }
      
      // Back button
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
      }
    });
  }
  
  loadMatches() {
    const teamId = this.navigation.context.team?.id;
    if (!teamId) {
      console.error('No team selected');
      return;
    }
    
    const listContainer = this.find('#match-list');
    listContainer.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading matches...</p></div>';
    
    this.safeFetch(`/api/matches/team/${teamId}`, response => {
      const matches = response.data || [];
      this.renderMatches(matches);
    });
  }
  
  renderMatches(matches) {
    const now = new Date();
    
    // Transform for display
    const transformedMatches = matches.map(m => {
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
    
    this.renderList('#match-list', transformedMatches,
      m => `
        <div class="card match-card" data-match-id="${m.id}" data-match-title="${m.title}" style="cursor: pointer; ${m.isPast ? 'opacity: 0.7;' : ''}">
          <div class="match-card-header" style="display: flex; justify-content: space-between; align-items: center;">
            <h3>${m.title}</h3>
            <span class="badge ${m.isPast ? 'badge-secondary' : 'badge-primary'}">${m.isPast ? 'Past' : 'Upcoming'}</span>
          </div>
          
          <div class="match-card-meta">
            <div class="meta-item">
              <span class="meta-icon">📅</span>
              <span>${m.dateDisplay}</span>
            </div>
            <div class="meta-item">
              <span class="meta-icon">🕐</span>
              <span>${m.time}</span>
            </div>
            ${m.venue_name ? `
            <div class="meta-item">
              <span class="meta-icon">📍</span>
              <span>${m.venue_name}</span>
            </div>
            ` : ''}
          </div>
          
          <p style="margin-top: var(--space-3); color: var(--text-muted); font-size: 0.9em;">
            Tap to manage player RSVPs →
          </p>
        </div>
      `,
      '<div class="empty-state"><p>🏆 No matches found</p><p class="text-muted">Create matches first to manage RSVPs</p></div>'
    );
  }
  
  openRSVPModal(matchId, matchTitle) {
    const modal = this.find('#rsvp-modal');
    const modalTitle = this.find('#modal-title');
    const rsvpList = this.find('#rsvp-list');
    
    modalTitle.textContent = `${matchTitle} - Player RSVPs`;
    rsvpList.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading players...</p></div>';
    modal.style.display = 'flex';
    
    this.currentMatchId = matchId;
    this.loadPlayersWithRSVP(matchId);
  }
  
  closeRSVPModal() {
    const modal = this.find('#rsvp-modal');
    modal.style.display = 'none';
    this.currentMatchId = null;
  }
  
  async loadPlayersWithRSVP(matchId) {
    const teamId = this.navigation.context.team?.id;
    const rsvpList = this.find('#rsvp-list');
    
    try {
      // Load team roster and match RSVPs in parallel
      const [rosterResponse, rsvpResponse] = await Promise.all([
        this.auth.fetch(`/api/teams/${teamId}/roster`).then(r => r.json()),
        this.auth.fetch(`/api/events/${matchId}/rsvps?role_type=player`).then(r => r.json())
      ]);
      
      console.log('Roster:', rosterResponse);
      console.log('RSVPs:', rsvpResponse);
      
      const players = rosterResponse.data || [];
      const rsvps = rsvpResponse.data || [];
      
      // Create a map of player RSVPs (keyed by user_id from RSVP response)
      const rsvpMap = {};
      rsvps.forEach(rsvp => {
        rsvpMap[rsvp.user_id] = rsvp.status;
      });
      
      // Merge roster with RSVP status
      // Roster uses 'id' for player ID, RSVPs use 'user_id'
      const playersWithRSVP = players.map(player => ({
        ...player,
        rsvpStatus: rsvpMap[player.id] || null
      }));
      
      this.teamPlayers = playersWithRSVP;
      this.renderPlayerRSVPs(playersWithRSVP);
      
    } catch (err) {
      console.error('Failed to load players/RSVPs:', err);
      rsvpList.innerHTML = `
        <div class="error-state">
          <p>Failed to load data: ${err.message}</p>
        </div>
      `;
    }
  }
  
  renderPlayerRSVPs(players) {
    const rsvpList = this.find('#rsvp-list');
    
    if (!players || players.length === 0) {
      rsvpList.innerHTML = `
        <div class="empty-state">
          <p>No players on roster</p>
          <p class="text-muted">Add players to the team roster first</p>
        </div>
      `;
      return;
    }
    
    // Sort: no response first, then by name
    const sorted = [...players].sort((a, b) => {
      if (!a.rsvpStatus && b.rsvpStatus) return -1;
      if (a.rsvpStatus && !b.rsvpStatus) return 1;
      const nameA = (a.name || '').toLowerCase();
      const nameB = (b.name || '').toLowerCase();
      return nameA.localeCompare(nameB);
    });
    
    rsvpList.innerHTML = sorted.map(player => {
      const name = player.name || 'Unknown';
      const jersey = player.jerseyNumber ? `#${player.jerseyNumber}` : '';
      const status = player.rsvpStatus;
      
      // Button classes based on current status
      const yesClass = status === 'attending' ? 'btn-success' : 'btn-outline';
      const noClass = status === 'not_attending' ? 'btn-danger' : 'btn-outline';
      const maybeClass = status === 'maybe' ? 'btn-warning' : 'btn-outline';
      
      return `
        <div class="rsvp-row" style="display: flex; justify-content: space-between; align-items: center; padding: var(--space-3); border-bottom: 1px solid var(--border-color);">
          <div class="player-info" style="flex: 1;">
            <strong>${name}</strong>
            ${jersey ? `<span class="badge badge-secondary" style="margin-left: 8px;">${jersey}</span>` : ''}
            ${!status ? '<span class="badge badge-muted" style="margin-left: 8px;">No response</span>' : ''}
          </div>
          <div class="rsvp-buttons" style="display: flex; gap: 8px;">
            <button class="rsvp-btn btn btn-sm ${yesClass}" 
                    data-player-id="${player.id}" 
                    data-status="attending"
                    title="Attending">
              ✓
            </button>
            <button class="rsvp-btn btn btn-sm ${maybeClass}" 
                    data-player-id="${player.id}" 
                    data-status="maybe"
                    title="Maybe">
              ?
            </button>
            <button class="rsvp-btn btn btn-sm ${noClass}" 
                    data-player-id="${player.id}" 
                    data-status="not_attending"
                    title="Not Attending">
              ✗
            </button>
          </div>
        </div>
      `;
    }).join('');
  }
  
  updatePlayerRSVP(playerId, status, buttonEl) {
    const matchId = this.currentMatchId;
    const coachId = this.auth.getUser()?.id;
    
    if (!matchId || !playerId || !coachId) {
      console.error('Missing data for RSVP update');
      return;
    }
    
    console.log('Coach updating player RSVP:', { matchId, playerId, status, coachId });
    
    // Disable buttons during update
    const row = buttonEl.closest('.rsvp-row');
    const buttons = row.querySelectorAll('.rsvp-btn');
    buttons.forEach(btn => btn.disabled = true);
    
    this.auth.fetch(`/api/events/${matchId}/rsvp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        user_id: playerId,        // The player's ID
        role_type: 'player',
        status: status,
        notes: `Set by coach`
      })
    })
    .then(r => {
      if (!r.ok) throw new Error('RSVP update failed');
      return r.json();
    })
    .then(response => {
      console.log('RSVP updated:', response);
      
      // Update local state (roster uses 'id' not 'user_id')
      const player = this.teamPlayers.find(p => p.id === playerId);
      if (player) {
        player.rsvpStatus = status;
      }
      
      // Re-render the list to show updated state
      this.renderPlayerRSVPs(this.teamPlayers);
    })
    .catch(err => {
      console.error('RSVP update error:', err);
      alert('Failed to update RSVP: ' + err.message);
      buttons.forEach(btn => btn.disabled = false);
    });
  }
}
