// GameDayLineupScreen - Drag-and-drop lineup management with eligibility tracking
// Zones: Starting XI (pitch), Roster list (single sortable list)
class GameDayLineupScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.players = [];
    this.unmatchedRsvps = [];
    this.policy = {};
    this.matchInfo = {};
    this.formations = [];
    this.selectedFormation = null;
    this.zones = {
      starting: [],    // Player IDs in starting XI (sparse array with nulls for empty slots)
      roster: []       // All other player IDs in one list
    };
    this.sortField = 'rsvp';  // Default sort
    this.sortAsc = true;
    this.dragState = null;
    this.selectingSlot = null; // When non-null, clicking a player card assigns to this slot
    this._listenersAttached = false;
  }

  render() {
    this._listenersAttached = false;
    
    const div = document.createElement('div');
    div.className = 'screen screen-game-day-lineup';
    div.innerHTML = `
      <div class="screen-header">
        <button id="lineup-back-btn" class="btn btn-secondary">← Back</button>
        <h1>⚽ Game Day Lineup</h1>
        <p id="lineup-subtitle" class="subtitle">Loading...</p>
      </div>

      <div class="lineup-container">
        <!-- Loading state -->
        <div id="lineup-loading" class="loading-state">
          <div class="spinner"></div>
          <p>Computing eligibility...</p>
        </div>

        <!-- Main content (hidden until loaded) -->
        <div id="lineup-content" style="display: none;">
          
          <!-- GroupMe sync warning (hidden by default) -->
          <div id="groupme-warning" class="groupme-warning" style="display: none;"></div>

          <!-- Policy summary bar -->
          <div id="policy-bar" class="policy-bar"></div>

          <!-- Formation selector -->
          <div class="formation-selector">
            <label>Formation:</label>
            <select id="formation-select">
              <option value="">Select formation...</option>
            </select>
          </div>

          <!-- Selection mode banner (hidden by default) -->
          <div id="select-mode-banner" class="select-mode-banner" style="display: none;">
            <span>👆 Click a player to assign to <strong id="select-slot-label"></strong></span>
            <button id="cancel-select-btn" class="btn btn-sm btn-secondary">Cancel</button>
          </div>

          <!-- Pitch + Roster layout -->
          <div class="lineup-layout">
            
            <!-- Starting XI - Pitch visualization -->
            <div class="lineup-zone zone-starting" id="zone-starting">
              <div class="zone-header">
                <h3>⚽ Starting XI</h3>
                <span id="starting-count" class="zone-count">0/11</span>
              </div>
              <div class="pitch" id="pitch-canvas">
                <div class="pitch-markings">
                  <div class="pitch-center-circle"></div>
                  <div class="pitch-center-line"></div>
                  <div class="pitch-box pitch-box-top"></div>
                  <div class="pitch-box pitch-box-bottom"></div>
                </div>
                <div id="pitch-players" class="pitch-players"></div>
              </div>
            </div>

            <!-- Single roster list -->
            <div class="roster-panel lineup-zone" id="roster-panel">
              <div class="roster-header">
                <h3>📋 Roster</h3>
                <span id="roster-count" class="zone-count">0</span>
              </div>
              <div class="roster-sort-controls">
                <label>Sort:</label>
                <select id="roster-sort">
                  <option value="rsvp">RSVP Status</option>
                  <option value="practices">Practices</option>
                  <option value="lastName">Last Name</option>
                  <option value="eligibility">Eligibility</option>
                </select>
                <button id="sort-direction-btn" class="btn-sort-dir" title="Toggle sort direction">↓</button>
              </div>
              <div class="roster-players" id="roster-players"></div>
            </div>
          </div>

          <!-- Action buttons -->
          <div class="lineup-actions">
            <button id="auto-fill-btn" class="btn btn-secondary">🤖 Auto-Fill from Eligibility</button>
            <button id="save-lineup-btn" class="btn btn-primary btn-lg">💾 Save Lineup</button>
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

    this.attachEventListeners();
    this.syncThenLoad();
    this.loadFormations();
  }

  /**
   * Sync GroupMe RSVPs from the live API, then load eligibility data.
   * If sync fails or no event is linked, we still load eligibility (with stale/no data).
   */
  async syncThenLoad() {
    const matchId = this.navigation.context.match?.id;
    const teamId = this.navigation.context.lineupTeamId || this.navigation.context.team?.id || '';
    
    if (matchId && teamId) {
      try {
        const syncResponse = await this.auth.fetch(`/api/groupme/sync-match/${matchId}?teamId=${teamId}`, {
          method: 'POST'
        });
        const syncData = await syncResponse.json();
        if (syncData.success && syncData.data?.synced) {
          console.log(`✅ GroupMe sync: ${syncData.data.totalRsvps} RSVPs (${syncData.data.going} going)`);
        } else {
          console.log('ℹ️ GroupMe sync skipped:', syncData.data?.reason || syncData.message);
        }
      } catch (err) {
        console.warn('⚠️ GroupMe sync failed:', err.message);
      }
    }

    this.loadEligibilityData();
  }

  // ============================================================================
  // Event Listeners
  // ============================================================================
  attachEventListeners() {
    this.element.addEventListener('click', (e) => {
      if (e.target.id === 'lineup-back-btn' || e.target.closest('#lineup-back-btn')) {
        this.navigation.goBack();
        return;
      }
      if (e.target.id === 'save-lineup-btn' || e.target.closest('#save-lineup-btn')) {
        this.saveLineup();
        return;
      }
      if (e.target.id === 'auto-fill-btn' || e.target.closest('#auto-fill-btn')) {
        this.autoFillFromEligibility();
        return;
      }
      if (e.target.id === 'groupme-refresh-btn' || e.target.closest('#groupme-refresh-btn')) {
        this.refreshGroupMe();
        return;
      }
      if (e.target.id === 'cancel-select-btn' || e.target.closest('#cancel-select-btn')) {
        this.cancelSlotSelection();
        return;
      }
      if (e.target.id === 'sort-direction-btn' || e.target.closest('#sort-direction-btn')) {
        this.sortAsc = !this.sortAsc;
        const btn = this.find('#sort-direction-btn');
        if (btn) btn.textContent = this.sortAsc ? '↓' : '↑';
        this.renderRoster();
        return;
      }

      // Click-to-assign: if we're in slot selection mode and user clicks a player card
      if (this.selectingSlot !== null) {
        const card = e.target.closest('[data-player-id]');
        if (card && card.closest('#roster-players')) {
          const playerId = parseInt(card.getAttribute('data-player-id'));
          this.assignPlayerToSlot(playerId, this.selectingSlot);
          this.cancelSlotSelection();
          return;
        }
      }

      // Click on empty pitch slot to enter selection mode
      const slot = e.target.closest('.pitch-slot');
      if (slot) {
        const slotIndex = parseInt(slot.getAttribute('data-slot'));
        const occupant = this.zones.starting[slotIndex];
        if (!occupant) {
          // Empty slot — enter selection mode
          this.enterSlotSelection(slotIndex);
        }
        return;
      }
    });

    // Sort selector
    this.element.addEventListener('change', (e) => {
      if (e.target.id === 'formation-select') {
        this.onFormationChange(e.target.value);
      }
      if (e.target.id === 'roster-sort') {
        this.sortField = e.target.value;
        this.renderRoster();
      }
    });

    // Drag and drop
    this.element.addEventListener('dragstart', (e) => this.onDragStart(e));
    this.element.addEventListener('dragover', (e) => this.onDragOver(e));
    this.element.addEventListener('drop', (e) => this.onDrop(e));
    this.element.addEventListener('dragend', (e) => this.onDragEnd(e));

    // Touch support for mobile
    this.element.addEventListener('touchstart', (e) => this.onTouchStart(e), { passive: false });
    this.element.addEventListener('touchmove', (e) => this.onTouchMove(e), { passive: false });
    this.element.addEventListener('touchend', (e) => this.onTouchEnd(e));

    // Double-click to open attendance editor
    this.element.addEventListener('dblclick', (e) => {
      const card = e.target.closest('[data-player-id]');
      if (card) {
        e.preventDefault();
        const playerId = parseInt(card.getAttribute('data-player-id'));
        this.openAttendancePopup(playerId);
      }
    });
  }

  // ============================================================================
  // Data Loading
  // ============================================================================
  async loadEligibilityData() {
    const matchId = this.navigation.context.match?.id;
    if (!matchId) {
      this.find('#lineup-loading').innerHTML = '<p style="color:var(--color-danger);">No match selected</p>';
      return;
    }

    try {
      const teamId = this.navigation.context.lineupTeamId || this.navigation.context.team?.id || '';
      const teamParam = teamId ? `?teamId=${teamId}` : '';

      // Fetch eligibility AND GroupMe members in parallel
      const [eligResponse, membersResponse] = await Promise.all([
        this.auth.fetch(`/api/eligibility/match/${matchId}${teamParam}`),
        teamId ? this.auth.fetch(`/api/groupme/members/${teamId}?matchId=${matchId}`) : Promise.resolve(null)
      ]);

      const data = await eligResponse.json();
      if (!data.success) throw new Error(data.message || 'Failed to load eligibility');

      this.matchInfo = data.data.match;
      this.policy = data.data.policy;
      this.players = data.data.players || [];
      this.unmatchedRsvps = data.data.unmatchedRsvps || [];
      this.groupmeSync = data.data.groupmeSync || {};

      // Load GroupMe members and merge
      this.groupmeMembers = [];
      if (membersResponse) {
        const membersData = await membersResponse.json();
        if (membersData.success && membersData.data?.members) {
          this.groupmeMembers = membersData.data.members;
          this.mergeGroupMeMembers();
        }
      }

      // Update subtitle
      const subtitle = this.find('#lineup-subtitle');
      subtitle.textContent = `${this.matchInfo.homeTeam} vs ${this.matchInfo.awayTeam} — ${this.matchInfo.date}`;

      // Show GroupMe sync warning if needed
      this.renderGroupmeWarning();

      // Render policy bar
      this.renderPolicyBar();

      // Auto-classify players into zones based on eligibility + RSVP + existing lineup
      this.classifyPlayersIntoZones();

      // Show content
      this.find('#lineup-loading').style.display = 'none';
      this.find('#lineup-content').style.display = 'block';

      this.renderAllZones();

    } catch (error) {
      console.error('Error loading eligibility:', error);
      this.find('#lineup-loading').innerHTML = `
        <p style="color:var(--color-danger);">❌ ${error.message}</p>
      `;
    }
  }

  /**
   * Merge GroupMe members into the players array.
   * - Members linked to persons already in this.players → enrich with GroupMe data
   * - Members linked to persons NOT in this.players → add as new entries
   * - Members NOT linked → add to unmatchedRsvps (or a new groupmeOnly array)
   */
  mergeGroupMeMembers() {
    if (!this.groupmeMembers?.length) return;

    // Index existing players by personId for fast lookup
    const playerByPersonId = new Map();
    for (const p of this.players) {
      if (p.personId) playerByPersonId.set(p.personId, p);
    }

    // Index unmatched RSVPs by external user ID
    const unmatchedByExtId = new Map();
    for (const u of this.unmatchedRsvps) {
      if (u.externalUserId) unmatchedByExtId.set(u.externalUserId, u);
    }

    for (const gm of this.groupmeMembers) {
      if (gm.linked && gm.personId) {
        // Linked member — enrich or add
        const existing = playerByPersonId.get(gm.personId);
        if (existing) {
          // Already in players array — add GroupMe metadata
          existing.gmNickname = gm.nickname;
          existing.gmImageUrl = gm.imageUrl;
          existing.gmUserId = gm.externalUserId;
          if (!existing.matchRsvp && gm.matchRsvp) {
            existing.matchRsvp = gm.matchRsvp;
          }
        } else {
          // Linked person not in players (not on roster but in GroupMe)
          this.players.push({
            personId: gm.personId,
            playerId: null,
            firstName: gm.firstName,
            lastName: gm.lastName,
            jerseyNumber: null,
            matchRsvp: gm.matchRsvp,
            practiceCount: gm.practiceCount || 0,
            eligibilityStatus: 'not_on_roster',
            isGuest: true,
            gmNickname: gm.nickname,
            gmImageUrl: gm.imageUrl,
            gmUserId: gm.externalUserId,
            onRoster: gm.onRoster,
            gmLinked: true
          });
        }
      } else {
        // Unlinked GroupMe member
        if (!unmatchedByExtId.has(gm.externalUserId)) {
          this.unmatchedRsvps.push({
            externalUserId: gm.externalUserId,
            externalUsername: gm.nickname,
            matchRsvp: gm.matchRsvp,
            gmImageUrl: gm.imageUrl,
            gmLinked: false
          });
        } else {
          // Already in unmatched — enrich with image
          const existing = unmatchedByExtId.get(gm.externalUserId);
          existing.gmImageUrl = gm.imageUrl;
        }
      }
    }
  }

  async loadFormations() {
    try {
      const response = await this.auth.fetch('/api/tactical-boards/types');
      // Also try to get formations from the database
      // For now use hardcoded common formations
      this.formations = [
        { id: 1, code: '4-3-3', name: '4-3-3' },
        { id: 2, code: '4-4-2', name: '4-4-2' },
        { id: 3, code: '3-5-2', name: '3-5-2' },
        { id: 4, code: '4-2-3-1', name: '4-2-3-1' }
      ];

      const select = this.find('#formation-select');
      this.formations.forEach(f => {
        const opt = document.createElement('option');
        opt.value = f.id;
        opt.textContent = f.name;
        select.appendChild(opt);
      });

      // Default to 4-3-3
      select.value = '1';
      this.onFormationChange('1');

    } catch (e) {
      console.warn('Could not load formations:', e);
    }
  }

  // ============================================================================
  // GroupMe Sync Warning
  // ============================================================================
  renderGroupmeWarning() {
    const banner = this.find('#groupme-warning');
    if (!banner) return;
    
    const sync = this.groupmeSync || {};
    const status = sync.status;
    const minutes = sync.minutesAgo;
    
    if (status === 'fresh') {
      banner.style.display = 'none';
      return;
    }
    
    let icon, message, level;
    const refreshBtn = '<button id="groupme-refresh-btn" class="btn-groupme-refresh">🔄 Refresh</button>';
    
    if (status === 'no_data') {
      icon = '🚫';
      message = `No GroupMe event linked for this match — RSVPs unavailable. ${refreshBtn}`;
      level = 'error';
    } else if (status === 'very_stale') {
      const days = Math.floor(minutes / 1440);
      icon = '⚠️';
      message = `RSVP data is ${days} day${days !== 1 ? 's' : ''} old. ${refreshBtn}`;
      level = 'error';
    } else if (status === 'stale') {
      const hours = Math.floor(minutes / 60);
      const mins = minutes % 60;
      icon = '⏳';
      message = `RSVPs synced ${hours}h ${mins}m ago. ${refreshBtn}`;
      level = 'warning';
    }
    
    if (!message) {
      banner.style.display = 'none';
      return;
    }

    banner.className = `groupme-warning groupme-warning-${level}`;
    banner.innerHTML = `<span class="groupme-warning-icon">${icon}</span> <span class="groupme-warning-text">${message}</span>`;
    banner.style.display = 'flex';
  }

  /**
   * Refresh GroupMe RSVPs and reload eligibility data.
   */
  async refreshGroupMe() {
    const btn = this.find('#groupme-refresh-btn');
    if (btn) {
      btn.disabled = true;
      btn.textContent = '⏳ Syncing...';
    }

    const matchId = this.navigation.context.match?.id;
    const teamId = this.navigation.context.lineupTeamId || this.navigation.context.team?.id || '';

    try {
      const syncResponse = await this.auth.fetch(`/api/groupme/sync-match/${matchId}?teamId=${teamId}`, {
        method: 'POST'
      });
      const syncData = await syncResponse.json();
      
      if (syncData.success && syncData.data?.synced) {
        console.log(`✅ Refresh: ${syncData.data.totalRsvps} RSVPs synced`);
      } else {
        console.log('ℹ️ Refresh:', syncData.data?.reason || syncData.message);
      }
    } catch (err) {
      console.warn('⚠️ Refresh failed:', err.message);
    }

    // Reload eligibility with fresh data
    await this.loadEligibilityData();
  }

  // ============================================================================
  // Policy Bar
  // ============================================================================
  renderPolicyBar() {
    const bar = this.find('#policy-bar');
    const p = this.policy;
    bar.innerHTML = `
      <div class="policy-item">
        <span class="policy-label">Lookback</span>
        <span class="policy-value">${p.lookbackCount} sessions</span>
      </div>
      <div class="policy-item">
        <span class="policy-label">Min to Start</span>
        <span class="policy-value">${p.minSessionsToStart}/${p.lookbackCount}</span>
      </div>
      <div class="policy-item">
        <span class="policy-label">Priority Starter</span>
        <span class="policy-value">${p.priorityStarterSessions}/${p.lookbackCount} (${p.priorityStarterSlots} slots)</span>
      </div>
      <div class="policy-item">
        <span class="policy-label">Family Discount</span>
        <span class="policy-value">−${p.familyDiscount}</span>
      </div>
    `;
  }

  // ============================================================================
  // Player Classification
  // ============================================================================
  classifyPlayersIntoZones() {
    this.zones = { starting: [], roster: [] };

    for (const player of this.players) {
      // If player already has lineup assignment, respect it
      if (player.onLineup && player.isStarter) {
        this.zones.starting.push(player.playerId);
        continue;
      }
      // Everyone else goes to roster (single list)
      this.zones.roster.push(player.playerId);
    }
  }

  // Sort roster by the active sort field
  sortRoster() {
    const statusRank = { 'priority_starter': 0, 'eligible_starter': 1, 'bench_only': 2, 'ineligible': 3 };
    const rsvpRank = { 'yes': 0, 'maybe': 1, 'no': 2 };
    const dir = this.sortAsc ? 1 : -1;

    this.zones.roster.sort((idA, idB) => {
      const a = this.getPlayerById(idA);
      const b = this.getPlayerById(idB);
      if (!a || !b) return 0;

      let cmp = 0;
      switch (this.sortField) {
        case 'rsvp':
          cmp = (rsvpRank[a.matchRsvp] ?? 3) - (rsvpRank[b.matchRsvp] ?? 3);
          if (cmp === 0) cmp = b.sessionsAttended - a.sessionsAttended;
          break;
        case 'practices':
          cmp = b.sessionsAttended - a.sessionsAttended;
          break;
        case 'lastName':
          cmp = (a.lastName + a.firstName).localeCompare(b.lastName + b.firstName);
          break;
        case 'eligibility':
          cmp = (statusRank[a.eligibilityStatus] ?? 4) - (statusRank[b.eligibilityStatus] ?? 4);
          if (cmp === 0) cmp = b.sessionsAttended - a.sessionsAttended;
          break;
      }
      return cmp * dir;
    });
  }

  autoFillFromEligibility() {
    // Reset all zones
    this.zones = { starting: [], roster: [] };

    // Sort eligible players by attendance (highest first)
    const sorted = [...this.players].sort((a, b) => {
      const statusOrder = { 'priority_starter': 0, 'eligible_starter': 1, 'bench_only': 2, 'ineligible': 3 };
      const orderA = statusOrder[a.eligibilityStatus] ?? 4;
      const orderB = statusOrder[b.eligibilityStatus] ?? 4;
      if (orderA !== orderB) return orderA - orderB;
      return b.sessionsAttended - a.sessionsAttended;
    });

    let starterCount = 0;
    for (const player of sorted) {
      if (player.matchRsvp === 'no') {
        this.zones.roster.push(player.playerId);
      } else if (starterCount < 11 && player.eligibilityStatus !== 'ineligible') {
        this.zones.starting.push(player.playerId);
        starterCount++;
      } else {
        this.zones.roster.push(player.playerId);
      }
    }

    this.renderAllZones();
  }

  // ============================================================================
  // Rendering
  // ============================================================================
  getPlayerById(playerId) {
    return this.players.find(p => p.playerId === playerId);
  }

  renderAllZones() {
    this.renderPitchPlayers();
    this.renderRoster();
    this.updateCounts();
  }

  renderRoster() {
    this.sortRoster();
    const container = this.find('#roster-players');
    if (!container) return;
    container.innerHTML = '';

    // Render matched players
    for (const playerId of this.zones.roster) {
      const player = this.getPlayerById(playerId);
      if (!player) continue;
      const card = this.createPlayerCard(player);
      card.setAttribute('data-zone', 'roster');
      container.appendChild(card);
    }

    // Render unmatched RSVP users at the bottom
    for (const u of this.unmatchedRsvps) {
      const card = this.createUnmatchedCard(u);
      container.appendChild(card);
    }

    if (this.zones.roster.length === 0 && this.unmatchedRsvps.length === 0) {
      container.innerHTML = '<div class="zone-empty">No players found</div>';
    }
  }

  updateCounts() {
    const sc = this.find('#starting-count');
    const rc = this.find('#roster-count');
    const starterCount = this.zones.starting.filter(id => id !== null).length;
    if (sc) sc.textContent = `${starterCount}/11`;
    if (rc) rc.textContent = this.zones.roster.length + this.unmatchedRsvps.length;
  }

  renderPitchPlayers() {
    const container = this.find('#pitch-players');
    if (!container) return;
    container.innerHTML = '';

    // Formation positions (default 4-3-3 positions if no formation data)
    const positions = this.getFormationPositions();

    // Render all 11 slots — empty ones are drop targets, filled ones show player chip
    positions.forEach((pos, slotIndex) => {
      const slot = document.createElement('div');
      slot.className = 'pitch-slot';
      slot.setAttribute('data-slot', slotIndex);
      slot.style.left = `${pos.x}%`;
      slot.style.top = `${pos.y}%`;

      const playerId = this.zones.starting[slotIndex];
      const player = playerId ? this.getPlayerById(playerId) : null;

      if (player) {
        const chip = this.createPitchPlayerChip(player, pos, slotIndex);
        slot.appendChild(chip);
      } else {
        // Empty slot — show position label as a drop target
        slot.innerHTML = `
          <div class="chip-circle chip-empty">${pos.label || ''}</div>
          <div class="chip-name">${pos.label || 'Empty'}</div>
        `;
      }

      container.appendChild(slot);
    });
  }

  getFormationPositions() {
    // Default 4-3-3 positions (x: 0-100 left-right, y: 0-100 own-goal to opp-goal)
    const defaultPositions = [
      { x: 50, y: 5, label: 'GK' },
      { x: 85, y: 22, label: 'RB' },
      { x: 60, y: 18, label: 'CB' },
      { x: 40, y: 18, label: 'CB' },
      { x: 15, y: 22, label: 'LB' },
      { x: 65, y: 42, label: 'CM' },
      { x: 50, y: 38, label: 'CM' },
      { x: 35, y: 42, label: 'CM' },
      { x: 80, y: 65, label: 'RW' },
      { x: 50, y: 70, label: 'ST' },
      { x: 20, y: 65, label: 'LW' }
    ];

    if (this.selectedFormation && this.selectedFormation.positions_json) {
      try {
        const parsed = typeof this.selectedFormation.positions_json === 'string'
          ? JSON.parse(this.selectedFormation.positions_json)
          : this.selectedFormation.positions_json;
        return parsed.map(p => ({ x: p.x, y: p.y, label: p.label }));
      } catch (e) {
        console.warn('Invalid formation JSON, using default');
      }
    }

    return defaultPositions;
  }

  createPitchPlayerChip(player, pos, slotIndex) {
    const chip = document.createElement('div');
    chip.className = `pitch-player-chip ${this.getEligibilityClass(player)}`;
    chip.setAttribute('draggable', 'true');
    chip.setAttribute('data-player-id', player.playerId);
    chip.setAttribute('data-zone', 'starting');
    chip.setAttribute('data-slot', slotIndex);

    const initial = player.firstName ? player.firstName[0] : '?';
    const jerseyDisplay = player.jerseyNumber ? `#${player.jerseyNumber}` : '';

    chip.innerHTML = `
      <div class="chip-circle">${jerseyDisplay || initial}</div>
      <div class="chip-name">${player.firstName} ${player.lastName}</div>
      <div class="chip-badge">${player.sessionsAttended}/${this.policy.lookbackCount}</div>
    `;

    return chip;
  }

  createPlayerCard(player) {
    const card = document.createElement('div');
    card.className = `player-card ${this.getEligibilityClass(player)}`;
    card.setAttribute('draggable', 'true');
    card.setAttribute('data-player-id', player.playerId);

    const jerseyDisplay = player.jerseyNumber ? `#${player.jerseyNumber}` : '';
    const posDisplay = player.position || '';

    // Avatar: use GroupMe image if available, otherwise initial
    const hasGmImage = player.gmImageUrl && player.gmImageUrl.length > 0;
    const initial = player.firstName ? player.firstName[0] : '?';
    const avatarHtml = hasGmImage
      ? `<img class="player-avatar player-avatar-img" src="${player.gmImageUrl}.avatar" alt="${initial}" onerror="this.outerHTML='<div class=\\'player-avatar\\'>${initial}</div>'">`
      : `<div class="player-avatar">${initial}</div>`;

    // RSVP pill
    const rsvpClass = this.getRsvpClass(player.matchRsvp);
    const rsvpLabel = this.getRsvpLabel(player.matchRsvp);

    // Practices badge
    const sessions = player.sessionsAttended ?? player.practiceCount ?? 0;
    const lookback = this.policy?.lookbackCount || 0;
    const practicesBadge = `${sessions}/${lookback}`;

    // Eligibility indicator
    const statusIcon = this.getStatusIcon(player.eligibilityStatus);
    
    // Badges
    const badges = [];
    if (!player.onOfficialRoster && player.eligibilityStatus !== 'not_on_roster') {
      badges.push('<span class="badge-guest" title="Not on official roster">guest</span>');
    }
    if (player.eligibilityStatus === 'not_on_roster') {
      badges.push('<span class="badge-guest" title="In GroupMe but not on team roster">GM only</span>');
    }

    // GroupMe nickname (show if different from person name)
    const gmNickLine = player.gmNickname && player.gmNickname !== `${player.firstName} ${player.lastName}`
      ? `<span class="player-gm-nick" title="GroupMe nickname">📱 ${player.gmNickname}</span>`
      : '';

    // Meta line
    const metaParts = [jerseyDisplay, posDisplay].filter(Boolean);
    const metaText = metaParts.length ? metaParts.join(' · ') : '';

    card.innerHTML = `
      <div class="player-card-left">
        ${avatarHtml}
        <div class="player-info">
          <div class="player-name">${player.firstName} ${player.lastName} ${badges.join(' ')}</div>
          <div class="player-meta">${metaText}${gmNickLine ? (metaText ? ' · ' : '') + gmNickLine : ''}</div>
        </div>
      </div>
      <div class="player-card-right">
        <span class="rsvp-pill ${rsvpClass}">${rsvpLabel}</span>
        <span class="practices-badge" title="Practices attended">${statusIcon} ${practicesBadge}</span>
      </div>
    `;

    return card;
  }

  createUnmatchedCard(user) {
    const card = document.createElement('div');
    card.className = 'player-card player-card-unmatched';
    card.setAttribute('data-external-id', user.externalUserId);

    // Avatar: use GroupMe image if available
    const hasGmImage = user.gmImageUrl && user.gmImageUrl.length > 0;
    const initial = user.externalUsername ? user.externalUsername[0].toUpperCase() : '?';
    const avatarHtml = hasGmImage
      ? `<img class="player-avatar player-avatar-img" src="${user.gmImageUrl}.avatar" alt="${initial}" onerror="this.outerHTML='<div class=\\'player-avatar avatar-unknown\\'>?</div>'">`
      : `<div class="player-avatar avatar-unknown">?</div>`;

    const rsvpClass = this.getRsvpClass(user.matchRsvp);
    const rsvpLabel = this.getRsvpLabel(user.matchRsvp);

    // Status text
    const statusText = user.matchRsvp ? 'GroupMe member · not linked to player' : 'GroupMe member · no RSVP';

    card.innerHTML = `
      <div class="player-card-left">
        ${avatarHtml}
        <div class="player-info">
          <div class="player-name">${user.externalUsername} <span class="badge-unmatched">unlinked</span></div>
          <div class="player-meta">${statusText}</div>
        </div>
      </div>
      <div class="player-card-right">
        <span class="rsvp-pill ${rsvpClass}">${rsvpLabel}</span>
      </div>
    `;

    return card;
  }

  getRsvpClass(rsvp) {
    switch (rsvp) {
      case 'yes': return 'rsvp-yes';
      case 'no': return 'rsvp-no';
      case 'maybe': return 'rsvp-maybe';
      default: return 'rsvp-pending';
    }
  }

  getRsvpLabel(rsvp) {
    switch (rsvp) {
      case 'yes': return '✓ Going';
      case 'no': return '✗ Not Going';
      case 'maybe': return '? Maybe';
      default: return '… Pending';
    }
  }

  // ============================================================================
  // Click-to-Assign (slot selection mode)
  // ============================================================================
  enterSlotSelection(slotIndex) {
    this.selectingSlot = slotIndex;
    const positions = this.getFormationPositions();
    const label = positions[slotIndex]?.label || `Slot ${slotIndex + 1}`;
    
    const banner = this.find('#select-mode-banner');
    const labelEl = this.find('#select-slot-label');
    if (banner) banner.style.display = 'flex';
    if (labelEl) labelEl.textContent = label;
    
    // Highlight the selected slot
    this.element.querySelectorAll('.pitch-slot').forEach(s => s.classList.remove('slot-selecting'));
    const slot = this.element.querySelector(`.pitch-slot[data-slot="${slotIndex}"]`);
    if (slot) slot.classList.add('slot-selecting');
    
    // Add selection mode class to roster for visual feedback
    const panel = this.find('#roster-panel');
    if (panel) panel.classList.add('roster-selecting');
  }

  cancelSlotSelection() {
    this.selectingSlot = null;
    const banner = this.find('#select-mode-banner');
    if (banner) banner.style.display = 'none';
    
    this.element.querySelectorAll('.pitch-slot').forEach(s => s.classList.remove('slot-selecting'));
    const panel = this.find('#roster-panel');
    if (panel) panel.classList.remove('roster-selecting');
  }

  assignPlayerToSlot(playerId, slotIndex) {
    // Remove from roster
    this.zones.roster = this.zones.roster.filter(id => id !== playerId);
    
    // Pad starting array
    const positions = this.getFormationPositions();
    while (this.zones.starting.length < positions.length) {
      this.zones.starting.push(null);
    }
    
    // If slot is occupied, move occupant to roster
    const occupant = this.zones.starting[slotIndex];
    if (occupant && occupant !== playerId) {
      this.zones.roster.unshift(occupant);
    }
    
    this.zones.starting[slotIndex] = playerId;
    this.renderAllZones();
  }

  getEligibilityClass(player) {
    switch (player.eligibilityStatus) {
      case 'priority_starter': return 'eligibility-priority';
      case 'eligible_starter': return 'eligibility-eligible';
      case 'bench_only': return 'eligibility-bench';
      case 'ineligible': return 'eligibility-ineligible';
      default: return '';
    }
  }

  getStatusIcon(status) {
    switch (status) {
      case 'priority_starter': return '⭐';
      case 'eligible_starter': return '✅';
      case 'bench_only': return '🔶';
      case 'ineligible': return '🚫';
      default: return '❓';
    }
  }

  // ============================================================================
  // Formation Change
  // ============================================================================
  onFormationChange(formationId) {
    if (!formationId) return;

    const formation = this.formations.find(f => f.id === parseInt(formationId));
    this.selectedFormation = formation || null;

    // Re-render pitch with new positions
    this.renderPitchPlayers();
  }

  // ============================================================================
  // Drag & Drop
  // ============================================================================
  onDragStart(e) {
    const card = e.target.closest('[data-player-id]');
    if (!card) return;

    const slot = card.closest('[data-slot]');
    this.dragState = {
      playerId: parseInt(card.getAttribute('data-player-id')),
      sourceZone: card.getAttribute('data-zone') || this.findPlayerZone(parseInt(card.getAttribute('data-player-id'))),
      sourceSlot: slot ? parseInt(slot.getAttribute('data-slot')) : null
    };

    card.classList.add('dragging');
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', card.getAttribute('data-player-id'));
  }

  onDragOver(e) {
    const slot = e.target.closest('.pitch-slot');
    const zone = e.target.closest('.lineup-zone');
    if (!zone && !slot) return;

    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';

    // Visual feedback
    document.querySelectorAll('.lineup-zone').forEach(z => z.classList.remove('drag-over'));
    document.querySelectorAll('.pitch-slot').forEach(s => s.classList.remove('slot-drag-over'));
    if (slot) {
      slot.classList.add('slot-drag-over');
    } else if (zone) {
      zone.classList.add('drag-over');
    }
  }

  onDrop(e) {
    e.preventDefault();
    document.querySelectorAll('.lineup-zone').forEach(z => z.classList.remove('drag-over'));
    document.querySelectorAll('.pitch-slot').forEach(s => s.classList.remove('slot-drag-over'));

    if (!this.dragState) return;

    // Check if dropped on a specific pitch slot
    const slot = e.target.closest('.pitch-slot');
    if (slot) {
      const targetSlot = parseInt(slot.getAttribute('data-slot'));
      this.movePlayerToSlot(this.dragState.playerId, this.dragState.sourceZone, this.dragState.sourceSlot, targetSlot);
      this.dragState = null;
      return;
    }

    const zone = e.target.closest('.lineup-zone');
    if (!zone) { this.dragState = null; return; }

    const targetZone = this.getZoneKey(zone.id);
    if (!targetZone) { this.dragState = null; return; }

    // If dropping on the starting zone (but not a specific slot), append to first empty slot
    if (targetZone === 'starting') {
      this.movePlayerToNextEmptySlot(this.dragState.playerId, this.dragState.sourceZone, this.dragState.sourceSlot);
      this.dragState = null;
      return;
    }

    this.movePlayer(this.dragState.playerId, this.dragState.sourceZone, targetZone);
    this.dragState = null;
  }

  onDragEnd(e) {
    document.querySelectorAll('.dragging').forEach(el => el.classList.remove('dragging'));
    document.querySelectorAll('.drag-over').forEach(el => el.classList.remove('drag-over'));
    this.dragState = null;
  }

  // ============================================================================
  // Touch Drag Support (mobile)
  // ============================================================================
  onTouchStart(e) {
    const card = e.target.closest('[data-player-id]');
    if (!card) return;

    const slot = card.closest('[data-slot]');
    this.dragState = {
      playerId: parseInt(card.getAttribute('data-player-id')),
      sourceZone: card.getAttribute('data-zone') || this.findPlayerZone(parseInt(card.getAttribute('data-player-id'))),
      sourceSlot: slot ? parseInt(slot.getAttribute('data-slot')) : null,
      touchElement: card,
      startX: e.touches[0].clientX,
      startY: e.touches[0].clientY
    };

    card.classList.add('touch-dragging');
  }

  onTouchMove(e) {
    if (!this.dragState || !this.dragState.touchElement) return;
    e.preventDefault();

    // Highlight drop zone or slot under finger
    const touch = e.touches[0];
    const elementBelow = document.elementFromPoint(touch.clientX, touch.clientY);
    const slot = elementBelow?.closest('.pitch-slot');
    const zone = elementBelow?.closest('.lineup-zone');

    document.querySelectorAll('.lineup-zone').forEach(z => z.classList.remove('drag-over'));
    document.querySelectorAll('.pitch-slot').forEach(s => s.classList.remove('slot-drag-over'));
    if (slot) {
      slot.classList.add('slot-drag-over');
    } else if (zone) {
      zone.classList.add('drag-over');
    }
  }

  onTouchEnd(e) {
    if (!this.dragState || !this.dragState.touchElement) return;

    const touch = e.changedTouches[0];
    const elementBelow = document.elementFromPoint(touch.clientX, touch.clientY);
    const slot = elementBelow?.closest('.pitch-slot');
    const zone = elementBelow?.closest('.lineup-zone');

    if (slot) {
      const targetSlot = parseInt(slot.getAttribute('data-slot'));
      this.movePlayerToSlot(this.dragState.playerId, this.dragState.sourceZone, this.dragState.sourceSlot, targetSlot);
    } else if (zone) {
      const targetZone = this.getZoneKey(zone.id);
      if (targetZone === 'starting') {
        this.movePlayerToNextEmptySlot(this.dragState.playerId, this.dragState.sourceZone, this.dragState.sourceSlot);
      } else if (targetZone) {
        this.movePlayer(this.dragState.playerId, this.dragState.sourceZone, targetZone);
      }
    }

    document.querySelectorAll('.touch-dragging').forEach(el => el.classList.remove('touch-dragging'));
    document.querySelectorAll('.drag-over').forEach(el => el.classList.remove('drag-over'));
    document.querySelectorAll('.slot-drag-over').forEach(el => el.classList.remove('slot-drag-over'));
    this.dragState = null;
  }

  // ============================================================================
  // Zone Management
  // ============================================================================
  getZoneKey(zoneElementId) {
    const map = {
      'zone-starting': 'starting',
      'roster-panel': 'roster'
    };
    return map[zoneElementId] || null;
  }

  findPlayerZone(playerId) {
    for (const [zone, ids] of Object.entries(this.zones)) {
      if (ids.includes(playerId)) return zone;
    }
    return null;
  }

  // Move a player to a specific pitch slot (with swap if occupied)
  movePlayerToSlot(playerId, fromZone, fromSlot, targetSlot) {
    const positions = this.getFormationPositions();
    if (targetSlot < 0 || targetSlot >= positions.length) return;

    // Pad starting array to 11 slots with null
    while (this.zones.starting.length < positions.length) {
      this.zones.starting.push(null);
    }

    const occupant = this.zones.starting[targetSlot];

    // Remove player from current location
    if (fromZone === 'starting' && fromSlot !== null && fromSlot !== undefined) {
      this.zones.starting[fromSlot] = null;
    } else if (fromZone && this.zones[fromZone]) {
      this.zones[fromZone] = this.zones[fromZone].filter(id => id !== playerId);
    }

    // If target slot had a player, move them to source slot or roster
    if (occupant && occupant !== playerId) {
      if (fromZone === 'starting' && fromSlot !== null && fromSlot !== undefined) {
        // Pitch-to-pitch swap
        this.zones.starting[fromSlot] = occupant;
      } else {
        // Displaced player goes to roster
        this.zones.roster.unshift(occupant);
      }
    }

    // Place player in target slot
    this.zones.starting[targetSlot] = playerId;

    this.compactStarting();
    this.renderAllZones();
  }

  // Move a player to the next empty pitch slot
  movePlayerToNextEmptySlot(playerId, fromZone, fromSlot) {
    const positions = this.getFormationPositions();
    while (this.zones.starting.length < positions.length) {
      this.zones.starting.push(null);
    }

    // Find first empty slot
    let targetSlot = this.zones.starting.indexOf(null);
    if (targetSlot === -1) {
      // All full — bump last slot to roster
      const bumped = this.zones.starting[positions.length - 1];
      this.zones.starting[positions.length - 1] = null;
      if (bumped) this.zones.roster.unshift(bumped);
      targetSlot = positions.length - 1;
    }

    this.movePlayerToSlot(playerId, fromZone, fromSlot, targetSlot);
  }

  // Remove null gaps but preserve slot-based ordering
  compactStarting() {
    // Remove trailing nulls only, keep sparse slots intact
    while (this.zones.starting.length > 0 && this.zones.starting[this.zones.starting.length - 1] === null) {
      this.zones.starting.pop();
    }
  }

  movePlayer(playerId, fromZone, toZone) {
    if (fromZone === toZone) return;

    // Remove from source
    if (fromZone === 'starting') {
      const idx = this.zones.starting.indexOf(playerId);
      if (idx !== -1) this.zones.starting[idx] = null;
      this.compactStarting();
    } else if (fromZone && this.zones[fromZone]) {
      this.zones[fromZone] = this.zones[fromZone].filter(id => id !== playerId);
    }

    // Add to target
    if (toZone === 'starting') {
      this.movePlayerToNextEmptySlot(playerId, null, null);
      return; // renderAllZones called inside
    } else if (this.zones[toZone]) {
      this.zones[toZone].push(playerId);
    }

    this.renderAllZones();
  }

  // ============================================================================
  // Attendance Popup (double-click a player)
  // ============================================================================
  async openAttendancePopup(playerId) {
    const player = this.getPlayerById(playerId);
    if (!player) return;

    const matchId = this.navigation.context.match?.id;
    const teamId = this.navigation.context.lineupTeamId || this.navigation.context.team?.id || '';
    if (!matchId) return;

    // Create overlay
    const overlay = document.createElement('div');
    overlay.className = 'attendance-overlay';
    overlay.innerHTML = `
      <div class="attendance-popup">
        <div class="attendance-popup-header">
          <h3>${player.firstName} ${player.lastName}</h3>
          <button class="attendance-close-btn">✕</button>
        </div>
        <div class="attendance-popup-body">
          <p class="attendance-loading">Loading attendance...</p>
        </div>
      </div>
    `;

    document.body.appendChild(overlay);

    // Close handlers
    overlay.querySelector('.attendance-close-btn').addEventListener('click', () => overlay.remove());
    overlay.addEventListener('click', (e) => { if (e.target === overlay) overlay.remove(); });

    // Fetch attendance data
    try {
      const response = await this.auth.fetch(
        `/api/eligibility/player/${playerId}/attendance?teamId=${teamId}&matchId=${matchId}`
      );
      const data = await response.json();
      if (!data.success) throw new Error(data.message || 'Failed to load');

      this.renderAttendanceList(overlay, player, data.data.sessions);
    } catch (err) {
      console.error('Error loading attendance:', err);
      overlay.querySelector('.attendance-popup-body').innerHTML =
        `<p style="color:red;">Failed to load attendance: ${err.message}</p>`;
    }
  }

  renderAttendanceList(overlay, player, sessions) {
    const body = overlay.querySelector('.attendance-popup-body');
    if (!sessions || sessions.length === 0) {
      body.innerHTML = '<p>No sessions found in lookback window.</p>';
      return;
    }

    const statusIcon = this.getStatusIcon(player.eligibilityStatus);
    const attended = sessions.filter(s => s.attended).length;

    body.innerHTML = `
      <div class="attendance-summary">
        ${statusIcon} ${attended}/${sessions.length} sessions attended
      </div>
      <div class="attendance-list">
        ${sessions.map(s => `
          <div class="attendance-row" data-session-id="${s.sessionId}">
            <label class="attendance-toggle">
              <input type="checkbox" ${s.attended ? 'checked' : ''}
                     data-session-id="${s.sessionId}" data-player-id="${player.playerId}">
              <span class="attendance-check"></span>
            </label>
            <div class="attendance-session-info">
              <div class="attendance-session-title">${s.title}</div>
              <div class="attendance-session-date">${s.date}${s.rsvp ? ' · RSVP: ' + s.rsvp : ''}</div>
            </div>
          </div>
        `).join('')}
      </div>
    `;

    // Toggle attendance on checkbox change
    body.querySelectorAll('input[type="checkbox"]').forEach(cb => {
      cb.addEventListener('change', (e) => {
        this.toggleAttendance(
          parseInt(e.target.dataset.playerId),
          parseInt(e.target.dataset.sessionId),
          e.target.checked,
          overlay,
          player,
          sessions
        );
      });
    });
  }

  async toggleAttendance(playerId, sessionId, attended, overlay, player, sessions) {
    try {
      const response = await this.auth.fetch(`/api/eligibility/player/${playerId}/attendance`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ sessionId, attended })
      });
      const data = await response.json();
      if (!data.success) throw new Error(data.message || 'Failed to update');

      // Update local session data
      const session = sessions.find(s => s.sessionId === sessionId);
      if (session) session.attended = attended;

      // Update player's sessions count in memory
      const newCount = sessions.filter(s => s.attended).length;
      player.sessionsAttended = newCount;

      // Re-classify this player's eligibility status
      const effectiveMin = player.hasFamilyDiscount
        ? Math.max(0, this.policy.minSessionsToStart - this.policy.familyDiscount)
        : this.policy.minSessionsToStart;
      player.effectiveMinSessions = effectiveMin;

      if (newCount >= this.policy.priorityStarterSessions) {
        player.eligibilityStatus = 'priority_starter';
      } else if (newCount >= effectiveMin) {
        player.eligibilityStatus = 'eligible_starter';
      } else if (newCount > 0) {
        player.eligibilityStatus = 'bench_only';
      } else {
        player.eligibilityStatus = 'ineligible';
      }

      // Refresh the summary line in popup
      this.renderAttendanceList(overlay, player, sessions);

      // Refresh the lineup display
      this.renderAllZones();

    } catch (err) {
      console.error('Error toggling attendance:', err);
      alert('Failed to update attendance: ' + err.message);
    }
  }

  // ============================================================================
  // Save Lineup
  // ============================================================================
  async saveLineup() {
    const matchId = this.navigation.context.match?.id;
    if (!matchId) {
      alert('No match selected');
      return;
    }

    const starters = this.zones.starting.filter(id => id !== null).map(playerId => ({ playerId }));
    const bench = this.zones.roster.map(playerId => ({ playerId }));

    try {
      const response = await this.auth.fetch(`/api/eligibility/lineup/${matchId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ starters, bench })
      });

      const data = await response.json();
      if (data.success) {
        alert(`✓ Lineup saved! ${data.data?.count || 0} players on lineup.`);
      } else {
        throw new Error(data.message || 'Failed to save');
      }
    } catch (error) {
      console.error('Error saving lineup:', error);
      alert('Failed to save lineup: ' + error.message);
    }
  }
}
