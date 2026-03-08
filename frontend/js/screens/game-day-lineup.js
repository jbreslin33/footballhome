// GameDayLineupScreen - Drag-and-drop lineup management with eligibility tracking
// Zones: Starting XI (pitch), Bench, Not Invited, Unavailable, Ineligible
class GameDayLineupScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.players = [];
    this.policy = {};
    this.matchInfo = {};
    this.formations = [];
    this.selectedFormation = null;
    this.zones = {
      starting: [],    // Player IDs in starting XI
      bench: [],       // Player IDs on bench
      notInvited: [],  // Explicitly not invited
      unavailable: [], // RSVP'd no
      ineligible: []   // Didn't meet training req
    };
    this.dragState = null;
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

          <!-- Pitch + Zones layout -->
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

            <!-- Side zones -->
            <div class="lineup-side-zones">
              
              <!-- Bench -->
              <div class="lineup-zone zone-bench" id="zone-bench">
                <div class="zone-header">
                  <h3>🪑 Bench</h3>
                  <span id="bench-count" class="zone-count">0</span>
                </div>
                <div class="zone-players" id="bench-players"></div>
              </div>

              <!-- Ineligible -->
              <div class="lineup-zone zone-ineligible" id="zone-ineligible">
                <div class="zone-header">
                  <h3>🚫 Didn't Meet Criteria</h3>
                  <span id="ineligible-count" class="zone-count">0</span>
                </div>
                <div class="zone-players" id="ineligible-players"></div>
              </div>

              <!-- Unavailable -->
              <div class="lineup-zone zone-unavailable" id="zone-unavailable">
                <div class="zone-header">
                  <h3>❌ Unavailable</h3>
                  <span id="unavailable-count" class="zone-count">0</span>
                </div>
                <div class="zone-players" id="unavailable-players"></div>
              </div>

              <!-- Not Invited -->
              <div class="lineup-zone zone-not-invited" id="zone-notInvited">
                <div class="zone-header">
                  <h3>📋 Not Invited</h3>
                  <span id="not-invited-count" class="zone-count">0</span>
                </div>
                <div class="zone-players" id="not-invited-players"></div>
              </div>
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
    });

    // Formation selector
    this.element.addEventListener('change', (e) => {
      if (e.target.id === 'formation-select') {
        this.onFormationChange(e.target.value);
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
      const response = await this.auth.fetch(`/api/eligibility/match/${matchId}${teamParam}`);
      const data = await response.json();

      if (!data.success) throw new Error(data.message || 'Failed to load eligibility');

      this.matchInfo = data.data.match;
      this.policy = data.data.policy;
      this.players = data.data.players || [];
      this.groupmeSync = data.data.groupmeSync || {};

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
    this.zones = { starting: [], bench: [], notInvited: [], unavailable: [], ineligible: [] };

    for (const player of this.players) {
      // If player already has lineup assignment, respect it
      if (player.onLineup) {
        if (player.isStarter) {
          this.zones.starting.push(player.playerId);
        } else {
          this.zones.bench.push(player.playerId);
        }
        continue;
      }

      // Otherwise, classify by eligibility + RSVP
      if (player.matchRsvp === 'no') {
        this.zones.unavailable.push(player.playerId);
      } else if (player.eligibilityStatus === 'ineligible') {
        this.zones.ineligible.push(player.playerId);
      } else if (player.eligibilityStatus === 'priority_starter' || player.eligibilityStatus === 'eligible_starter') {
        // Available and eligible — put on bench by default (coach drags to starting)
        this.zones.bench.push(player.playerId);
      } else if (player.eligibilityStatus === 'bench_only') {
        this.zones.bench.push(player.playerId);
      } else {
        this.zones.notInvited.push(player.playerId);
      }
    }

    // Sort bench by criteria met (best candidates at top)
    this.sortBenchByCriteria();
  }

  // Sort bench player IDs by eligibility ranking:
  //   1. Eligibility tier: priority_starter > eligible_starter > bench_only > ineligible
  //   2. Sessions attended (descending)
  //   3. RSVP status: yes > maybe > none/other
  //   4. On official roster first
  sortBenchByCriteria() {
    const statusRank = { 'priority_starter': 0, 'eligible_starter': 1, 'bench_only': 2, 'ineligible': 3 };
    const rsvpRank = { 'yes': 0, 'maybe': 1 };

    this.zones.bench.sort((idA, idB) => {
      const a = this.getPlayerById(idA);
      const b = this.getPlayerById(idB);
      if (!a || !b) return 0;

      // 1. Eligibility tier
      const tierA = statusRank[a.eligibilityStatus] ?? 4;
      const tierB = statusRank[b.eligibilityStatus] ?? 4;
      if (tierA !== tierB) return tierA - tierB;

      // 2. Sessions attended (more = better)
      if (a.sessionsAttended !== b.sessionsAttended) return b.sessionsAttended - a.sessionsAttended;

      // 3. RSVP — yes before maybe before none
      const rsvpA = rsvpRank[a.matchRsvp] ?? 2;
      const rsvpB = rsvpRank[b.matchRsvp] ?? 2;
      if (rsvpA !== rsvpB) return rsvpA - rsvpB;

      // 4. On official roster first
      if (a.onOfficialRoster !== b.onOfficialRoster) return a.onOfficialRoster ? -1 : 1;

      // 5. Alphabetical tiebreak
      return (a.lastName + a.firstName).localeCompare(b.lastName + b.firstName);
    });
  }

  autoFillFromEligibility() {
    // Reset all zones
    this.zones = { starting: [], bench: [], notInvited: [], unavailable: [], ineligible: [] };

    // Sort eligible players by attendance (highest first)
    const eligible = this.players
      .filter(p => p.matchRsvp !== 'no')
      .sort((a, b) => {
        // Priority starters first, then by sessions attended
        const statusOrder = { 'priority_starter': 0, 'eligible_starter': 1, 'bench_only': 2, 'ineligible': 3 };
        const orderA = statusOrder[a.eligibilityStatus] ?? 4;
        const orderB = statusOrder[b.eligibilityStatus] ?? 4;
        if (orderA !== orderB) return orderA - orderB;
        return b.sessionsAttended - a.sessionsAttended;
      });

    let starterCount = 0;
    for (const player of eligible) {
      if (player.eligibilityStatus === 'ineligible') {
        this.zones.ineligible.push(player.playerId);
      } else if (starterCount < 11 && (player.eligibilityStatus === 'priority_starter' || player.eligibilityStatus === 'eligible_starter')) {
        this.zones.starting.push(player.playerId);
        starterCount++;
      } else {
        this.zones.bench.push(player.playerId);
      }
    }

    // Unavailable (RSVP'd no)
    this.players
      .filter(p => p.matchRsvp === 'no')
      .forEach(p => this.zones.unavailable.push(p.playerId));

    // Sort bench by criteria met
    this.sortBenchByCriteria();
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
    this.sortBenchByCriteria();
    this.renderZonePlayers('bench-players', this.zones.bench);
    this.renderZonePlayers('ineligible-players', this.zones.ineligible);
    this.renderZonePlayers('unavailable-players', this.zones.unavailable);
    this.renderZonePlayers('not-invited-players', this.zones.notInvited);
    this.updateCounts();
  }

  updateCounts() {
    const sc = this.find('#starting-count');
    const bc = this.find('#bench-count');
    const ic = this.find('#ineligible-count');
    const uc = this.find('#unavailable-count');
    const nc = this.find('#not-invited-count');
    const starterCount = this.zones.starting.filter(id => id !== null).length;
    if (sc) sc.textContent = `${starterCount}/11`;
    if (bc) bc.textContent = this.zones.bench.length;
    if (ic) ic.textContent = this.zones.ineligible.length;
    if (uc) uc.textContent = this.zones.unavailable.length;
    if (nc) nc.textContent = this.zones.notInvited.length;
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
    const initial = player.firstName ? player.firstName[0] : '?';

    // Eligibility indicator
    const statusIcon = this.getStatusIcon(player.eligibilityStatus);
    const rsvpIcon = this.getRsvpIcon(player.matchRsvp);
    const familyIcon = player.hasFamilyDiscount ? '👨‍👩‍👧' : '';

    card.innerHTML = `
      <div class="player-card-left">
        <div class="player-avatar">${initial}</div>
        <div class="player-info">
          <div class="player-name">${player.firstName} ${player.lastName}</div>
          <div class="player-meta">
            ${[jerseyDisplay, posDisplay].filter(Boolean).join(' · ')}
          </div>
        </div>
      </div>
      <div class="player-card-right">
        <div class="eligibility-badge" title="Training: ${player.sessionsAttended}/${this.policy.lookbackCount} (need ${player.effectiveMinSessions})">
          ${statusIcon} ${player.sessionsAttended}/${this.policy.lookbackCount}
        </div>
        <div class="player-icons">
          ${rsvpIcon} ${familyIcon}
        </div>
      </div>
    `;

    return card;
  }

  renderZonePlayers(containerId, playerIds) {
    const container = this.find(`#${containerId}`);
    if (!container) return;
    container.innerHTML = '';

    if (playerIds.length === 0) {
      container.innerHTML = '<div class="zone-empty">Drag players here</div>';
      return;
    }

    playerIds.forEach(playerId => {
      const player = this.getPlayerById(playerId);
      if (!player) return;
      const card = this.createPlayerCard(player);
      const zone = containerId.replace('-players', '').replace('not-invited', 'notInvited');
      card.setAttribute('data-zone', zone);
      container.appendChild(card);
    });
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

  getRsvpIcon(rsvp) {
    switch (rsvp) {
      case 'yes': return '✓';
      case 'no': return '✗';
      case 'maybe': return '?';
      default: return '';
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
      'zone-bench': 'bench',
      'zone-ineligible': 'ineligible',
      'zone-unavailable': 'unavailable',
      'zone-notInvited': 'notInvited'
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

    // If target slot had a player, move them to source slot or bench
    if (occupant && occupant !== playerId) {
      if (fromZone === 'starting' && fromSlot !== null && fromSlot !== undefined) {
        // Pitch-to-pitch swap
        this.zones.starting[fromSlot] = occupant;
      } else {
        // Displaced player goes to bench
        this.zones.bench.unshift(occupant);
      }
    }

    // Place player in target slot
    this.zones.starting[targetSlot] = playerId;

    this.compactStarting();
    this.sortBenchByCriteria();
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
      // All full — bump last slot to bench
      const bumped = this.zones.starting[positions.length - 1];
      this.zones.starting[positions.length - 1] = null;
      if (bumped) this.zones.bench.unshift(bumped);
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
      // Clear the slot (set to null, don't filter)
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

    // Re-sort bench whenever players move into it
    if (toZone === 'bench' || fromZone === 'starting') {
      this.sortBenchByCriteria();
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
    const bench = this.zones.bench.map(playerId => ({ playerId }));

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
