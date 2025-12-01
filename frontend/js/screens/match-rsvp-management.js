// MatchRSVPManagementScreen - Coach manages player RSVPs for matches (inline accordion style)
class MatchRSVPManagementScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.matches = [];
    this.expandedMatchId = null;
    this.teamPlayers = [];
    this.rsvpCache = {}; // Cache RSVPs per match
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
      
      // RSVP button clicked
      const rsvpBtn = e.target.closest('.rsvp-btn');
      if (rsvpBtn) {
        const matchId = rsvpBtn.getAttribute('data-match-id');
        const playerId = rsvpBtn.getAttribute('data-player-id');
        const status = rsvpBtn.getAttribute('data-status');
        this.updatePlayerRSVP(matchId, playerId, status, rsvpBtn);
        return;
      }
    });
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
    
    // Count RSVPs
    let yesCount = 0, noCount = 0, maybeCount = 0, pendingCount = 0;
    this.teamPlayers.forEach(p => {
      const status = rsvpMap[p.id];
      if (status === 'attending') yesCount++;
      else if (status === 'not_attending') noCount++;
      else if (status === 'maybe') maybeCount++;
      else pendingCount++;
    });
    
    // Summary row
    const summary = `
      <div style="padding: var(--space-2) var(--space-3); background: var(--color-background); border-bottom: 2px solid var(--color-border); display: flex; gap: var(--space-3); flex-wrap: wrap;">
        <span style="color: var(--color-success);">✓ ${yesCount} Yes</span>
        <span style="color: var(--color-warning);">? ${maybeCount} Maybe</span>
        <span style="color: var(--color-danger);">✗ ${noCount} No</span>
        <span style="color: var(--color-text-secondary);">⏳ ${pendingCount} Pending</span>
      </div>
    `;
    
    // Sort: pending first, then by name
    const sorted = [...this.teamPlayers].sort((a, b) => {
      const statusA = rsvpMap[a.id];
      const statusB = rsvpMap[b.id];
      if (!statusA && statusB) return -1;
      if (statusA && !statusB) return 1;
      return (a.name || '').localeCompare(b.name || '');
    });
    
    const tableRows = sorted.map(player => {
      const status = rsvpMap[player.id];
      const jersey = player.jerseyNumber || '-';
      const name = player.name || 'Unknown';
      
      // Button styles
      const yesClass = status === 'attending' ? 'btn-success' : 'btn-outline';
      const maybeClass = status === 'maybe' ? 'btn-warning' : 'btn-outline';
      const noClass = status === 'not_attending' ? 'btn-danger' : 'btn-outline';
      
      return `
        <tr style="border-bottom: 1px solid var(--color-border);">
          <td style="padding: var(--space-2); font-weight: bold; width: 50px; text-align: center;">${jersey}</td>
          <td style="padding: var(--space-2);">${name}</td>
          <td style="padding: var(--space-2); text-align: right; white-space: nowrap;">
            <button class="rsvp-btn btn btn-sm ${yesClass}" 
                    data-match-id="${matchId}"
                    data-player-id="${player.id}" 
                    data-status="attending"
                    style="min-width: 36px;">✓</button>
            <button class="rsvp-btn btn btn-sm ${maybeClass}" 
                    data-match-id="${matchId}"
                    data-player-id="${player.id}" 
                    data-status="maybe"
                    style="min-width: 36px;">?</button>
            <button class="rsvp-btn btn btn-sm ${noClass}" 
                    data-match-id="${matchId}"
                    data-player-id="${player.id}" 
                    data-status="not_attending"
                    style="min-width: 36px;">✗</button>
          </td>
        </tr>
      `;
    }).join('');
    
    return `
      ${summary}
      <table style="width: 100%; border-collapse: collapse;">
        <thead>
          <tr style="background: var(--color-background-secondary); border-bottom: 2px solid var(--color-border);">
            <th style="padding: var(--space-2); text-align: center;">#</th>
            <th style="padding: var(--space-2); text-align: left;">Player</th>
            <th style="padding: var(--space-2); text-align: right;">RSVP</th>
          </tr>
        </thead>
        <tbody>
          ${tableRows}
        </tbody>
      </table>
    `;
  }
  
  updatePlayerRSVP(matchId, playerId, status, buttonEl) {
    const coachId = this.auth.getUser()?.id;
    
    if (!matchId || !playerId || !coachId) {
      console.error('Missing data for RSVP update');
      return;
    }
    
    console.log('Coach updating player RSVP:', { matchId, playerId, status, coachId });
    
    // Disable buttons during update
    const row = buttonEl.closest('tr');
    const buttons = row.querySelectorAll('.rsvp-btn');
    buttons.forEach(btn => btn.disabled = true);
    
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
    .then(response => {
      console.log('RSVP updated:', response);
      
      // Update cache
      if (!this.rsvpCache[matchId]) this.rsvpCache[matchId] = {};
      this.rsvpCache[matchId][playerId] = status;
      
      // Re-render the player table
      const playersDiv = this.find(`#players-${matchId}`);
      if (playersDiv) {
        playersDiv.innerHTML = this.renderPlayerTable(matchId);
      }
    })
    .catch(err => {
      console.error('RSVP update error:', err);
      alert('Failed to update RSVP: ' + err.message);
      buttons.forEach(btn => btn.disabled = false);
    });
  }
}
