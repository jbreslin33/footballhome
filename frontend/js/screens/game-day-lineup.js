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
    this.loadEligibilityData();
    this.loadFormations();
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

      // Update subtitle
      const subtitle = this.find('#lineup-subtitle');
      subtitle.textContent = `${this.matchInfo.homeTeam} vs ${this.matchInfo.awayTeam} — ${this.matchInfo.date}`;

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
    if (sc) sc.textContent = `${this.zones.starting.length}/11`;
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

    this.zones.starting.forEach((playerId, index) => {
      const player = this.getPlayerById(playerId);
      if (!player) return;

      const pos = positions[index] || { x: 50, y: 50 };
      const chip = this.createPitchPlayerChip(player, pos, index);
      container.appendChild(chip);
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
    chip.style.left = `${pos.x}%`;
    chip.style.top = `${pos.y}%`;

    const initial = player.firstName ? player.firstName[0] : '?';
    const jerseyDisplay = player.jerseyNumber ? `#${player.jerseyNumber}` : '';

    chip.innerHTML = `
      <div class="chip-circle">${jerseyDisplay || initial}</div>
      <div class="chip-name">${player.lastName}</div>
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

    this.dragState = {
      playerId: parseInt(card.getAttribute('data-player-id')),
      sourceZone: card.getAttribute('data-zone') || this.findPlayerZone(parseInt(card.getAttribute('data-player-id')))
    };

    card.classList.add('dragging');
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', card.getAttribute('data-player-id'));
  }

  onDragOver(e) {
    const zone = e.target.closest('.lineup-zone');
    if (!zone) return;

    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';

    // Visual feedback
    document.querySelectorAll('.lineup-zone').forEach(z => z.classList.remove('drag-over'));
    zone.classList.add('drag-over');
  }

  onDrop(e) {
    e.preventDefault();
    document.querySelectorAll('.lineup-zone').forEach(z => z.classList.remove('drag-over'));

    if (!this.dragState) return;

    const zone = e.target.closest('.lineup-zone');
    if (!zone) return;

    const targetZone = this.getZoneKey(zone.id);
    if (!targetZone) return;

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

    this.dragState = {
      playerId: parseInt(card.getAttribute('data-player-id')),
      sourceZone: card.getAttribute('data-zone') || this.findPlayerZone(parseInt(card.getAttribute('data-player-id'))),
      touchElement: card,
      startX: e.touches[0].clientX,
      startY: e.touches[0].clientY
    };

    card.classList.add('touch-dragging');
  }

  onTouchMove(e) {
    if (!this.dragState || !this.dragState.touchElement) return;
    e.preventDefault();

    // Highlight drop zone under finger
    const touch = e.touches[0];
    const elementBelow = document.elementFromPoint(touch.clientX, touch.clientY);
    const zone = elementBelow?.closest('.lineup-zone');

    document.querySelectorAll('.lineup-zone').forEach(z => z.classList.remove('drag-over'));
    if (zone) zone.classList.add('drag-over');
  }

  onTouchEnd(e) {
    if (!this.dragState || !this.dragState.touchElement) return;

    const touch = e.changedTouches[0];
    const elementBelow = document.elementFromPoint(touch.clientX, touch.clientY);
    const zone = elementBelow?.closest('.lineup-zone');

    if (zone) {
      const targetZone = this.getZoneKey(zone.id);
      if (targetZone) {
        this.movePlayer(this.dragState.playerId, this.dragState.sourceZone, targetZone);
      }
    }

    document.querySelectorAll('.touch-dragging').forEach(el => el.classList.remove('touch-dragging'));
    document.querySelectorAll('.drag-over').forEach(el => el.classList.remove('drag-over'));
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

  movePlayer(playerId, fromZone, toZone) {
    if (fromZone === toZone) return;

    // Enforce starting XI limit
    if (toZone === 'starting' && this.zones.starting.length >= 11) {
      // Swap: move the last starter to bench
      const bumped = this.zones.starting.pop();
      this.zones.bench.unshift(bumped);
    }

    // Remove from source
    if (fromZone && this.zones[fromZone]) {
      this.zones[fromZone] = this.zones[fromZone].filter(id => id !== playerId);
    }

    // Add to target
    if (this.zones[toZone]) {
      this.zones[toZone].push(playerId);
    }

    this.renderAllZones();
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

    const starters = this.zones.starting.map(playerId => ({ playerId }));
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
