// MatchRSVPManagementScreen - Coach manages player RSVPs for matches (inline accordion style)
class MatchRSVPManagementScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.matches = [];
    this.expandedMatchId = null;
    this.teamPlayers = [];
    this.rsvpCache = {}; // Cache RSVPs per match
    this.selectedPlayer = null; // For bottom sheet
    this.attendanceStatuses = [];
    this.attendanceCache = {}; // matchId -> [ {id, player_name, status_id}, ... ]
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
    this._pendingMatchId = params && params.matchId ? String(params.matchId) : null;
    this.loadData();

    // Live search box: filter the RSVP columns as the coach types. Delegated at
    // the screen root so it survives every re-render of the accordion contents.
    this.element.addEventListener('input', (e) => {
      const searchEl = e.target.closest && e.target.closest('.rsvp-search');
      if (!searchEl) return;
      const matchId = searchEl.getAttribute('data-match-id');
      this._rsvpFilter = this._rsvpFilter || {};
      this._rsvpFilter[matchId] = searchEl.value;
      const cursor = searchEl.selectionStart;
      const playersDiv = this.find(`#players-${matchId}`);
      if (playersDiv) {
        playersDiv.innerHTML = this.renderPlayerTable(matchId);
        requestAnimationFrame(() => {
          const el = playersDiv.querySelector('.rsvp-search');
          if (el) { el.focus(); try { el.setSelectionRange(cursor, cursor); } catch(_){} }
        });
      }
    });

    this.element.addEventListener('click', (e) => {
      // Back button
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      // Game Day Roster button clicked
      const gameRosterBtn = e.target.closest('.game-roster-btn');
      if (gameRosterBtn) {
        const matchId = gameRosterBtn.getAttribute('data-match-id');
        console.log('Game Day Roster clicked, matchId:', matchId);
        console.log('Available matches:', this.matches);
        const match = this.matches.find(m => m.id === matchId);
        console.log('Found match:', match);
        if (match) {
          this.navigation.context.match = match;
          this.navigation.context.lineupTeamId = this.navigation.context.team?.id || '';
          this.navigation.goTo('game-day-roster');
        } else {
          console.error('Match not found in this.matches for id:', matchId);
        }
        return;
      }

      // Game Day Lineup button clicked
      const gameLineupBtn = e.target.closest('.game-lineup-btn');
      if (gameLineupBtn) {
        const matchId = gameLineupBtn.getAttribute('data-match-id');
        const match = this.matches.find(m => m.id === matchId);
        if (match) {
          this.navigation.context.match = match;
          this.navigation.context.lineupTeamId = this.navigation.context.team?.id || '';
          this.navigation.goTo('game-day-lineup');
        }
        return;
      }

      // Take / Edit Attendance toggle (practice + pickup only)
      const attToggleBtn = e.target.closest('.attendance-toggle-btn');
      if (attToggleBtn) {
        const matchId = attToggleBtn.getAttribute('data-match-id');
        this.toggleAttendance(matchId);
        return;
      }

      // Attendance status button clicked (per-player)
      const attStatusBtn = e.target.closest('.attendance-status-btn');
      if (attStatusBtn) {
        const attendanceId = attStatusBtn.getAttribute('data-attendance-id');
        const statusId = attStatusBtn.getAttribute('data-status-id');
        this.updateAttendance(attendanceId, statusId, attStatusBtn);
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
      // Load matches, roster, and attendance statuses in parallel
      const [matchesResponse, rosterResponse, statusesResponse] = await Promise.all([
        this.auth.fetch(`/api/matches/team/${teamId}`).then(r => r.json()),
        this.auth.fetch(`/api/teams/${teamId}/roster`).then(r => r.json()),
        this.auth.fetch('/api/attendance/statuses').then(r => r.json()).catch(() => ({ data: [] }))
      ]);
      
      this.matches = matchesResponse.data || [];
      this.teamPlayers = (rosterResponse.data || []).filter(p => p.roleType === 'PLAYER');
      this.attendanceStatuses = statusesResponse.data || [];
      
      // Hide loading, show content
      this.find('#roster-loading').style.display = 'none';
      this.find('#match-container').style.display = 'block';
      
      this.renderMatches();

      // If team-hub deep-linked us to a specific match, auto-expand it.
      // toggleMatch stores the id + re-renders + fetches RSVPs.
      if (this._pendingMatchId) {
        const wanted = String(this._pendingMatchId);
        this._pendingMatchId = null;
        const found = this.matches.find(m => String(m.id) === wanted);
        if (found) {
          this.toggleMatch(wanted);
          // Scroll the expanded row into view after render.
          setTimeout(() => {
            const el = this.element.querySelector(`[data-match-id="${wanted}"]`);
            if (el && typeof el.scrollIntoView === 'function') {
              el.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
          }, 50);
        }
      }
      
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
        <div class="match-accordion" style="margin-bottom: var(--space-3); border: 1px solid rgba(245,200,66,0.35); border-radius: 8px; overflow: hidden; ${m.isPast ? 'opacity: 0.7;' : ''}">
          <div class="match-header" data-match-id="${m.id}" style="display: flex; justify-content: space-between; align-items: center; padding: var(--space-3); background: #1e3a6e; color: #ffffff; cursor: pointer;">
            <div>
              <strong style="font-size: 1.1em; color: #ffffff;">${m.title}</strong>
              <div style="font-size: 0.9em; color: #f5c842; margin-top: 4px;">
                📅 ${m.dateDisplay} &nbsp; 🕐 ${m.time}
                ${m.venue_name ? ` &nbsp; 📍 ${m.venue_name}` : ''}
              </div>
            </div>
            <div style="display: flex; align-items: center; gap: 12px;">
              <span class="badge ${m.isPast ? 'badge-secondary' : 'badge-primary'}">${m.isPast ? 'Past' : 'Upcoming'}</span>
              <span style="font-size: 1.2em; color: #f5c842;">${isExpanded ? '▼' : '▶'}</span>
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
      return `<div style="padding: var(--space-3); text-align: center; color: #4b5563;">No players on roster</div>`;
    }

    // Live search filter — kept per-match so switching accordions preserves it.
    this._rsvpFilter = this._rsvpFilter || {};
    const filterRaw = this._rsvpFilter[matchId] || '';
    const filter = filterRaw.trim().toLowerCase();
    const players = filter
      ? this.teamPlayers.filter(p => (p.name || '').toLowerCase().includes(filter))
      : this.teamPlayers;

    // Categorize players by status
    const attending = [];
    const notAttending = [];
    const maybe = [];
    const pending = [];

    players.forEach(p => {
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
    
    // Lighthouse palette
    const LH_NAVY   = '#0f1f3d';
    const LH_YELLOW = '#f5c842';
    const LH_MUTED  = '#4b5563'; // gray for the "No" column

    // Render three-column layout
    const renderColumn = (players, status, title, icon, bgColor, textColor) => {
      return `
        <div style="min-width: 0;">
          <div style="background: ${bgColor}; color: ${textColor}; padding: var(--space-2); text-align: center; font-weight: bold; border-radius: 8px 8px 0 0;">
            ${icon} ${title} (${players.length})
          </div>
          <div style="border: 2px solid ${bgColor}; border-top: none; border-radius: 0 0 8px 8px; min-height: 160px; background: white;">
            ${players.map(p => this.renderPlayerCard(p, status, matchId)).join('')}
            ${players.length === 0 ? `<div style="padding: var(--space-3); text-align: center; color: ${LH_MUTED}; font-style: italic;">No players</div>` : ''}
          </div>
        </div>
      `;
    };
    
    // Practice (3) and Pickup (7) skip the game-day roster/lineup and show inline attendance instead.
    const match = this.matches.find(m => m.id === matchId);
    const mt = Number(match?.match_type_id);
    const isPractice = mt === 3 || mt === 7;

    const actionRow = isPractice
      ? `<div style="margin-bottom: var(--space-3);">
           <button class="btn btn-primary attendance-toggle-btn" data-match-id="${matchId}" style="width: 100%;">
             📋 Take / Edit Attendance
           </button>
           <div id="attendance-panel-${matchId}" style="display: none; margin-top: var(--space-3);"></div>
         </div>`
      : `<div style="margin-bottom: var(--space-3); display: flex; gap: var(--space-2);">
           <button class="btn btn-primary game-roster-btn" data-match-id="${matchId}" style="flex: 1;">
             📋 Set Game Day Roster
           </button>
           <button class="btn btn-secondary game-lineup-btn" data-match-id="${matchId}" style="flex: 1;">
             ⚽ Game Day Lineup
           </button>
         </div>`;

    // Escape once for the search value attribute.
    const filterAttr = filterRaw.replace(/"/g, '&quot;');
    const totalMatched = attending.length + maybe.length + notAttending.length + pending.length;

    return `
      <div style="padding: var(--space-3); background: transparent;">
        ${actionRow}
        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: var(--space-3); padding: 8px 12px; background: ${LH_NAVY}; border: 1px solid ${LH_YELLOW}; border-radius: 8px; color: ${LH_YELLOW}; flex-wrap: wrap;">
          <span style="font-weight: 700;">🔍 Find player</span>
          <input class="rsvp-search"
                 data-match-id="${matchId}"
                 type="search"
                 placeholder="Type a name…"
                 value="${filterAttr}"
                 style="flex: 1; min-width: 160px; padding: 6px 10px; border-radius: 6px; border: 1px solid ${LH_YELLOW}; background: white; color: ${LH_NAVY}; font-size: 0.95em;" />
          <span style="opacity: 0.85; font-size: 0.9em;">${totalMatched} / ${this.teamPlayers.length}</span>
        </div>
        <div style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: var(--space-3);">
          ${renderColumn(attending, 'attending',    'Yes',   '✓', LH_NAVY,   'white')}
          ${renderColumn(maybe,     'maybe',        'Maybe', '?', LH_YELLOW, LH_NAVY)}
          ${renderColumn(notAttending,'not_attending','No',  '✗', LH_MUTED,  'white')}
        </div>
        ${pending.length > 0 ? `
          <div style="margin-top: var(--space-3); padding: var(--space-3); background: ${LH_NAVY}; border: 2px solid ${LH_YELLOW}; border-radius: 8px;">
            <div style="font-weight: bold; margin-bottom: var(--space-2); color: ${LH_YELLOW};">⚠️ Pending Responses (${pending.length})</div>
            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: var(--space-2);">
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
    const photoUrl = player.photoUrl || null;
    const LH_NAVY = '#0f1f3d';

    // Player avatar - navy circle with white initial (uniform for every player).
    // Photos also get a navy border so cards look identical.
    const initial = name ? name[0].toUpperCase() : '?';
    const avatarHtml = photoUrl
      ? `<img src="${photoUrl}" style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover; border: 2px solid ${LH_NAVY};" alt="${name}">`
      : `<div style="width: 40px; height: 40px; border-radius: 50%; background: ${LH_NAVY}; color: white; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 1.2em;">${initial}</div>`;

    return `
      <div class="player-card"
           data-match-id="${matchId}"
           data-player-id="${player.id}"
           data-player-name="${name}"
           style="padding: var(--space-3); border-bottom: 1px solid rgba(15,31,61,0.12); display: flex; justify-content: space-between; align-items: center; cursor: pointer; background: white; color: ${LH_NAVY};">
        <div style="display: flex; align-items: center; gap: var(--space-2);">
          ${avatarHtml}
          <span style="font-weight: 700; color: ${LH_NAVY}; min-width: 28px; font-size: 1.1em;">#${jersey}</span>
          <span style="font-size: 1.05em; color: ${LH_NAVY}; font-weight: 500;">${name}</span>
        </div>
        <span style="color: ${LH_NAVY}; font-size: 1.2em; opacity: 0.6;">›</span>
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
  
  // ---------- Attendance (practice + pickup) ----------

  async toggleAttendance(matchId) {
    const panel = this.find(`#attendance-panel-${matchId}`);
    if (!panel) return;
    if (panel.style.display === 'block') {
      panel.style.display = 'none';
      return;
    }
    panel.style.display = 'block';
    panel.innerHTML = '<div style="padding: var(--space-3); text-align: center;"><div class="spinner"></div></div>';
    await this.loadAttendance(matchId);
  }

  async loadAttendance(matchId) {
    try {
      const resp = await this.auth.fetch(`/api/events/${matchId}/attendance`);
      const data = await resp.json();
      this.attendanceCache[matchId] = data.data || [];
      this.renderAttendance(matchId);
    } catch (err) {
      console.error('Failed to load attendance:', err);
      const panel = this.find(`#attendance-panel-${matchId}`);
      if (panel) {
        panel.innerHTML = `<div style="padding: var(--space-3); color: var(--color-danger);">Failed to load attendance</div>`;
      }
    }
  }

  renderAttendance(matchId) {
    const panel = this.find(`#attendance-panel-${matchId}`);
    if (!panel) return;
    const records = this.attendanceCache[matchId] || [];
    const statuses = this.attendanceStatuses || [];

    if (records.length === 0) {
      panel.innerHTML = `
        <div style="padding: var(--space-3); border: 1px solid rgba(245,200,66,0.35); border-radius: 8px; background: white; color: #0f1f3d;">
          <p style="margin: 0;">No attendance records yet.</p>
          <p style="margin: var(--space-2) 0 0; font-size: 0.85em; opacity: 0.75;">Attendance rows are auto-created from RSVPs when the event starts.</p>
        </div>`;
      return;
    }

    // Fixed 5-column grid so every row lines up perfectly.
    // Column 1: player name (flex), columns 2-5: one per status (fixed 56px).
    const gridCols = `minmax(0, 1fr) repeat(${statuses.length}, 56px)`;

    const filter = (this._attendanceFilter && this._attendanceFilter[matchId]) || '';
    const q = filter.trim().toLowerCase();
    const filtered = q
      ? records.filter(r => (r.player_name || '').toLowerCase().includes(q))
      : records;

    const headerCells = `
      <div style="padding: 10px 12px; font-weight: 700; color: #f5c842;">Player</div>
      ${statuses.map(s => `
        <div style="padding: 10px 4px; font-weight: 700; color: #f5c842; text-align: center; font-size: 0.85em;" title="${s.display_name || s.name}">
          ${this.getStatusIcon(s.name)}
        </div>
      `).join('')}
    `;

    const rowCells = (r) => `
      <div class="attendance-row"
           style="display: contents;"
           data-row-id="${r.id}">
        <div style="padding: 10px 12px; font-weight: 600; color: #0f1f3d; border-top: 1px solid rgba(15,31,61,0.10); background: white; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
          ${r.player_name || 'Unknown Player'}
        </div>
        ${statuses.map(s => {
          const isActive = String(r.status_id) === String(s.id);
          return `
            <div style="padding: 6px 4px; border-top: 1px solid rgba(15,31,61,0.10); background: white; display: flex; align-items: center; justify-content: center;">
              <button class="attendance-status-btn"
                      data-attendance-id="${r.id}"
                      data-status-id="${s.id}"
                      title="${s.display_name || s.name}"
                      style="width: 44px; height: 34px; border-radius: 6px; cursor: pointer; font-size: 1.05em; font-weight: 700;
                             background: ${isActive ? s.color : 'transparent'};
                             color: ${isActive ? 'white' : s.color};
                             border: 2px solid ${s.color};">
                ${this.getStatusIcon(s.name)}
              </button>
            </div>
          `;
        }).join('')}
      </div>
    `;

    panel.innerHTML = `
      <div style="border: 1px solid rgba(245,200,66,0.35); border-radius: 8px; overflow: hidden; background: white;">
        <div style="padding: var(--space-2) var(--space-3); background: #0f1f3d; color: #f5c842; font-weight: bold; display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap;">
          <span>Attendance (${filtered.length}/${records.length})</span>
          <input class="attendance-search"
                 data-match-id="${matchId}"
                 type="search"
                 placeholder="Search player…"
                 value="${this.escapeHtml ? this.escapeHtml(filter) : filter.replace(/"/g,'&quot;')}"
                 style="flex: 1; min-width: 160px; max-width: 260px; padding: 6px 10px; border-radius: 6px; border: 1px solid #f5c842; background: white; color: #0f1f3d; font-size: 0.95em;" />
        </div>
        <div style="display: grid; grid-template-columns: ${gridCols}; background: #0f1f3d;">
          ${headerCells}
        </div>
        <div style="display: grid; grid-template-columns: ${gridCols};">
          ${filtered.map(rowCells).join('') || `<div style="grid-column: 1 / -1; padding: var(--space-3); text-align: center; color: #4b5563;">No players match your search.</div>`}
        </div>
      </div>`;

    // Wire the search box (kept focused across re-renders via requestAnimationFrame).
    const searchInput = panel.querySelector('.attendance-search');
    if (searchInput) {
      searchInput.addEventListener('input', (e) => {
        this._attendanceFilter = this._attendanceFilter || {};
        this._attendanceFilter[matchId] = e.target.value;
        const cursor = e.target.selectionStart;
        this.renderAttendance(matchId);
        requestAnimationFrame(() => {
          const el = panel.querySelector('.attendance-search');
          if (el) { el.focus(); el.setSelectionRange(cursor, cursor); }
        });
      });
    }
  }

  getStatusIcon(statusName) {
    return ({ present: '✓', absent: '✗', late: '⏰', excused: '📝', unknown: '?' })[statusName] || '?';
  }

  updateAttendance(attendanceId, statusId, buttonEl) {
    // Optimistic UI swap within the row
    const row = buttonEl.closest('.attendance-row');
    if (row) {
      row.querySelectorAll('.attendance-status-btn').forEach(btn => {
        const color = btn.style.borderColor;
        btn.style.background = 'transparent';
        btn.style.color = color;
      });
    }
    const status = this.attendanceStatuses.find(s => String(s.id) === String(statusId));
    if (status) {
      buttonEl.style.background = status.color;
      buttonEl.style.color = 'white';
    }

    this.auth.fetch(`/api/attendance/${attendanceId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status_id: Number(statusId) })
    })
    .then(r => { if (!r.ok) throw new Error('Update failed'); })
    .catch(err => {
      console.error('Attendance update failed:', err);
      alert('Failed to update attendance. Please try again.');
    });
  }

  find(selector) {
    return this.element.querySelector(selector);
  }
}
