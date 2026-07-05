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
      
      // "Remind All" button in the pending section header — bulk generates
      // magic-links for every non-responder, then opens a queue modal so
      // the coach can tap Send once per player.  Handled BEFORE .remind-btn
      // so the more-specific bulk class doesn't fall through to the per-
      // player handler.
      const remindAllBtn = e.target.closest('.remind-all-btn');
      if (remindAllBtn) {
        e.stopPropagation();
        const matchId = remindAllBtn.getAttribute('data-match-id');
        this.remindAllPending(matchId, remindAllBtn);
        return;
      }

      // "Remind" button on a pending player card — opens native SMS/email
      // composer prefilled with a per-player magic-link.  Handled BEFORE the
      // playerCard branch so the outer card click doesn't also open the
      // RSVP bottom sheet.
      const remindBtn = e.target.closest('.remind-btn');
      if (remindBtn) {
        e.stopPropagation();
        const matchId    = remindBtn.getAttribute('data-match-id');
        const playerId   = remindBtn.getAttribute('data-player-id');
        const playerName = remindBtn.getAttribute('data-player-name');
        const channel    = remindBtn.getAttribute('data-channel') || 'sms';
        this.sendReminder(matchId, playerId, playerName, channel, remindBtn);
        return;
      }

      // Bulk-remind modal — "Send" per row hands off to the OS composer.
      const bulkSendBtn = e.target.closest('.bulk-send-btn');
      if (bulkSendBtn) {
        e.stopPropagation();
        const href = bulkSendBtn.getAttribute('data-href');
        if (href) {
          bulkSendBtn.classList.add('bulk-sent');
          bulkSendBtn.textContent = '✓ Sent';
          bulkSendBtn.style.background = 'rgba(34,139,34,0.85)';
          bulkSendBtn.style.color = 'white';
          this._updateBulkProgress();
          // Slight delay so the visual change registers before the app
          // context-switches to Messages/Mail.
          setTimeout(() => { window.location.href = href; }, 60);
        }
        return;
      }

      // Bulk-remind modal — close.
      if (e.target.id === 'bulk-remind-close' || e.target.id === 'bulk-remind-backdrop') {
        e.stopPropagation();
        this.hideBulkRemindModal();
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
            <div style="display: flex; justify-content: space-between; align-items: center; gap: var(--space-2); margin-bottom: var(--space-2); flex-wrap: wrap;">
              <div style="font-weight: bold; color: ${LH_YELLOW};">⚠️ Pending Responses (${pending.length})</div>
              <button class="btn btn-sm btn-warning remind-all-btn"
                      data-match-id="${matchId}"
                      style="padding: 6px 12px; font-size: 0.9em;"
                      title="Send an SMS magic-link reminder to every pending player">
                📱 Remind All (${pending.length})
              </button>
            </div>
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

    // "Remind" button appears only for pending players (no RSVP yet).
    // Tapping it POSTs to /api/matches/:id/remind, which returns an
    // sms_href — the browser then hands off to the coach's native
    // Messages/Mail app with the magic-link prefilled.
    const nameEscaped = String(name).replace(/"/g, '&quot;');
    const remindBtn = (!currentStatus)
      ? `<button class="btn btn-sm btn-warning remind-btn"
                 data-match-id="${matchId}"
                 data-player-id="${player.id}"
                 data-player-name="${nameEscaped}"
                 data-channel="sms"
                 style="margin-right: 8px; padding: 4px 10px; font-size: 0.85em;"
                 title="Text ${nameEscaped} a magic-link RSVP reminder">
           📱 Remind
         </button>`
      : '';

    return `
      <div class="player-card"
           data-match-id="${matchId}"
           data-player-id="${player.id}"
           data-player-name="${nameEscaped}"
           style="padding: var(--space-3); border-bottom: 1px solid rgba(15,31,61,0.12); display: flex; justify-content: space-between; align-items: center; cursor: pointer; background: white; color: ${LH_NAVY};">
        <div style="display: flex; align-items: center; gap: var(--space-2);">
          ${avatarHtml}
          <span style="font-weight: 700; color: ${LH_NAVY}; min-width: 28px; font-size: 1.1em;">#${jersey}</span>
          <span style="font-size: 1.05em; color: ${LH_NAVY}; font-weight: 500;">${name}</span>
        </div>
        <div style="display: flex; align-items: center; gap: 4px;">
          ${remindBtn}
          <span style="color: ${LH_NAVY}; font-size: 1.2em; opacity: 0.6;">›</span>
        </div>
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

  // ---------- Reminder magic-link (per player, coach-driven) ----------
  //
  // Calls POST /api/matches/:id/remind with player_ids: [playerId].  The
  // backend generates a one-time magic-link and returns a `sms_href` (or
  // `mailto_href`).  We set window.location.href to it, which on mobile
  // hands off to the native Messages/Mail app with the number/email and
  // body prefilled — the coach reviews and hits Send from their own phone.
  async sendReminder(matchId, playerId, playerName, channel, btnEl) {
    if (!matchId || !playerId) return;
    channel = channel === 'email' ? 'email' : 'sms';

    const original = btnEl ? btnEl.innerHTML : '';
    if (btnEl) {
      btnEl.disabled = true;
      btnEl.innerHTML = '⏳';
    }

    try {
      const resp = await this.auth.fetch(`/api/matches/${matchId}/remind`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ channel, player_ids: [Number(playerId)] })
      });
      const data = await resp.json();
      if (!resp.ok) {
        throw new Error(data.error || `HTTP ${resp.status}`);
      }

      const rec = (data.recipients || [])[0];
      if (!rec) {
        if ((data.skipped_rate_limited || 0) > 0) {
          alert(`A reminder link for ${playerName} was already generated in the last 5 minutes — check your Messages app.`);
        } else if ((data.skipped_no_contact || 0) > 0) {
          alert(`${playerName} has no ${channel === 'sms' ? 'SMS-capable phone' : 'email'} on file.`);
        } else {
          alert(`${playerName} isn't on the non-responder list for this match (they may have already RSVP'd, or aren't rostered).`);
        }
        return;
      }

      const href = channel === 'sms' ? rec.sms_href : rec.mailto_href;
      if (href) {
        // Hand off to the OS.  On mobile this pops the SMS / Mail app;
        // on desktop it opens the default handler (or prompts to pick).
        window.location.href = href;
      } else {
        alert(`Link generated but no ${channel} handler available. URL: ${rec.url}`);
      }
    } catch (err) {
      console.error('sendReminder failed:', err);
      alert(`Failed to send reminder: ${err.message}`);
    } finally {
      if (btnEl) {
        btnEl.disabled = false;
        btnEl.innerHTML = original;
      }
    }
  }

  // ---------- Bulk reminder queue (coach → "Remind All Pending") ----------
  //
  // Calls POST /api/matches/:id/remind with NO player_ids filter, so the
  // backend targets every non-responder on the home team roster.  The
  // response includes one recipient row per generated link (with an
  // sms_href we can hand off to the OS Messages app).  We render those
  // rows in a modal queue and let the coach fire them one at a time.
  //
  // Rate-limit note: the backend rate-limits per-person within a 5-minute
  // window.  So retapping "Remind All" within that window returns only
  // recipients who weren't already reminded — which is exactly the
  // behaviour we want.
  async remindAllPending(matchId, btnEl) {
    if (!matchId) return;

    // Count pending on client side for the confirmation prompt.
    const rsvpMap = this.rsvpCache[matchId] || {};
    const pending = (this.teamPlayers || []).filter(p => {
      const s = rsvpMap[p.id];
      return !s;
    });

    if (pending.length === 0) {
      alert('No pending players — everyone has already RSVP\'d.');
      return;
    }

    if (!confirm(`Generate SMS reminders for all ${pending.length} pending player(s)?\n\n` +
                 `You'll get a list with one "Send" button per player. Tap each one to open ` +
                 `Messages with the RSVP link prefilled.`)) {
      return;
    }

    const original = btnEl ? btnEl.innerHTML : '';
    if (btnEl) {
      btnEl.disabled = true;
      btnEl.innerHTML = '⏳ Generating…';
    }

    try {
      const resp = await this.auth.fetch(`/api/matches/${matchId}/remind`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ channel: 'sms' })  // no player_ids = all non-responders
      });
      const data = await resp.json();
      if (!resp.ok) throw new Error(data.error || `HTTP ${resp.status}`);

      const recipients = data.recipients || [];
      if (recipients.length === 0) {
        const parts = [];
        if (data.skipped_rate_limited) parts.push(`${data.skipped_rate_limited} already reminded in the last 5 min`);
        if (data.skipped_no_contact)   parts.push(`${data.skipped_no_contact} with no SMS phone on file`);
        alert(parts.length
          ? `No new reminders generated. Skipped: ${parts.join('; ')}.`
          : 'No non-responders found to remind.');
        return;
      }

      this.showBulkRemindModal(recipients, data);
    } catch (err) {
      console.error('remindAllPending failed:', err);
      alert(`Failed to generate reminders: ${err.message}`);
    } finally {
      if (btnEl) {
        btnEl.disabled = false;
        btnEl.innerHTML = original;
      }
    }
  }

  showBulkRemindModal(recipients, meta) {
    // Remove any leftover instance first.
    this.hideBulkRemindModal();

    const LH_NAVY   = '#0f1f3d';
    const LH_YELLOW = '#f5c842';

    const rowsHtml = recipients.map((r, i) => {
      const name    = (r.name || 'Unknown').replace(/"/g, '&quot;');
      const contact = (r.contact || '').replace(/"/g, '&quot;');
      const href    = (r.sms_href || r.mailto_href || '').replace(/"/g, '&quot;');
      return `
        <div style="display: flex; align-items: center; gap: 10px; padding: 10px 12px; border-bottom: 1px solid rgba(15,31,61,0.12); background: white;">
          <div style="width: 24px; text-align: right; color: ${LH_NAVY}; opacity: 0.55; font-size: 0.85em;">${i + 1}.</div>
          <div style="flex: 1; min-width: 0;">
            <div style="font-weight: 700; color: ${LH_NAVY};">${name}</div>
            <div style="font-size: 0.85em; color: #4b5563; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${contact}</div>
          </div>
          <button class="bulk-send-btn"
                  data-href="${href}"
                  style="padding: 8px 14px; background: ${LH_YELLOW}; color: ${LH_NAVY}; border: none; border-radius: 6px; font-weight: 700; cursor: pointer; font-size: 0.95em; white-space: nowrap;"
                  title="Open Messages with the reminder prefilled">
            📱 Send
          </button>
        </div>
      `;
    }).join('');

    const skippedParts = [];
    if (meta && meta.skipped_rate_limited) skippedParts.push(`${meta.skipped_rate_limited} skipped (already reminded in last 5 min)`);
    if (meta && meta.skipped_no_contact)   skippedParts.push(`${meta.skipped_no_contact} skipped (no SMS phone)`);
    const skippedNote = skippedParts.length
      ? `<div style="padding: 8px 12px; background: rgba(245,200,66,0.15); color: ${LH_NAVY}; font-size: 0.85em; border-top: 1px solid rgba(15,31,61,0.12);">${skippedParts.join(' · ')}</div>`
      : '';

    const overlay = document.createElement('div');
    overlay.id = 'bulk-remind-overlay';
    overlay.style.cssText = 'position: fixed; inset: 0; z-index: 1100; display: flex; align-items: flex-end; justify-content: center;';
    overlay.innerHTML = `
      <div id="bulk-remind-backdrop" style="position: absolute; inset: 0; background: rgba(0,0,0,0.55);"></div>
      <div style="position: relative; width: 100%; max-width: 560px; max-height: 90vh; background: white; border-radius: 16px 16px 0 0; display: flex; flex-direction: column; overflow: hidden; box-shadow: 0 -8px 24px rgba(0,0,0,0.25);">
        <div style="padding: 14px 16px; background: ${LH_NAVY}; color: ${LH_YELLOW}; display: flex; align-items: center; justify-content: space-between; gap: 10px;">
          <div style="min-width: 0;">
            <div style="font-weight: 700; font-size: 1.05em;">📱 Bulk RSVP Reminders</div>
            <div id="bulk-remind-progress" style="font-size: 0.8em; opacity: 0.9; margin-top: 2px;">0 of ${recipients.length} sent</div>
          </div>
          <button id="bulk-remind-close" style="background: transparent; color: ${LH_YELLOW}; border: 1px solid ${LH_YELLOW}; border-radius: 6px; padding: 6px 12px; cursor: pointer; font-weight: 700;">Done</button>
        </div>
        <div style="padding: 10px 12px; background: rgba(245,200,66,0.12); color: ${LH_NAVY}; font-size: 0.85em; border-bottom: 1px solid rgba(15,31,61,0.12);">
          Tap <b>📱 Send</b> next to each player to open Messages. Each link is one-tap RSVP and expires in 48 hours.
        </div>
        <div style="flex: 1; overflow-y: auto; -webkit-overflow-scrolling: touch;">
          ${rowsHtml}
        </div>
        ${skippedNote}
      </div>
    `;
    document.body.appendChild(overlay);
    this._bulkTotal = recipients.length;
  }

  hideBulkRemindModal() {
    const overlay = document.getElementById('bulk-remind-overlay');
    if (overlay && overlay.parentNode) overlay.parentNode.removeChild(overlay);
    this._bulkTotal = 0;
  }

  _updateBulkProgress() {
    const overlay = document.getElementById('bulk-remind-overlay');
    if (!overlay) return;
    const sent = overlay.querySelectorAll('.bulk-send-btn.bulk-sent').length;
    const total = this._bulkTotal || overlay.querySelectorAll('.bulk-send-btn').length;
    const label = overlay.querySelector('#bulk-remind-progress');
    if (label) label.textContent = `${sent} of ${total} sent`;
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
