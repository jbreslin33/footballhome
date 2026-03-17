// GameDayLineupScreen - Drag-and-drop lineup management with eligibility tracking
// Zones: Starting XI (pitch), Game Day Bench, Not Selected (full roster)
class GameDayLineupScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.players = [];
    this.unmatchedRsvps = [];
    this.policy = {};
    this.matchInfo = {};
    this.formations = [];
    this.selectedFormation = null;
    this.rosterSize = 20;  // 18 or 20 man game day roster
    this.zones = {
      starting: [],    // Player IDs in starting XI (sparse array with nulls for empty slots)
      bench: [],       // Player IDs on game day bench
      roster: []       // Not selected (everyone else)
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

          <!-- Controls row: Formation + Roster Size + Actions -->
          <div class="lineup-controls-row">
            <div class="formation-selector">
              <label>Formation:</label>
              <select id="formation-select">
                <option value="">Select formation...</option>
              </select>
            </div>
            <div class="roster-size-selector">
              <label>Roster:</label>
              <div class="roster-size-toggle">
                <button id="roster-size-18" class="btn-roster-size" data-size="18">18</button>
                <button id="roster-size-20" class="btn-roster-size active" data-size="20">20</button>
              </div>
            </div>
            <div class="lineup-actions-inline">
              <button id="auto-fill-btn" class="btn btn-secondary btn-sm">🤖 Auto-Fill</button>
              <button id="save-lineup-btn" class="btn btn-primary btn-sm">💾 Save</button>
            </div>
          </div>

          <!-- Selection mode banner (hidden by default) -->
          <div id="select-mode-banner" class="select-mode-banner" style="display: none;">
            <span>👆 Click a player to assign to <strong id="select-slot-label"></strong></span>
            <button id="cancel-select-btn" class="btn btn-sm btn-secondary">Cancel</button>
          </div>

          <!-- Compact Pitch -->
          <div class="pitch-compact-wrapper lineup-zone zone-starting" id="zone-starting">
            <div class="pitch-compact-header">
              <span>⚽ Starting XI</span>
              <span id="starting-count" class="zone-count">0/11</span>
            </div>
            <div class="pitch pitch-compact" id="pitch-canvas">
              <div class="pitch-markings">
                <div class="pitch-center-circle"></div>
                <div class="pitch-center-line"></div>
                <div class="pitch-box pitch-box-top"></div>
                <div class="pitch-box pitch-box-bottom"></div>
              </div>
              <div id="pitch-players" class="pitch-players"></div>
            </div>
          </div>

          <!-- Policy summary bar (compact) -->
          <div id="policy-bar" class="policy-bar"></div>

          <!-- Full roster table — ALL players, grouped by zone -->
          <div class="roster-table-wrapper">
            <div class="roster-table-header">
              <span class="rt-counts">
                <span id="bench-count-display">Bench: 0/<span id="bench-max">9</span></span>
                <span class="rt-sep">·</span>
                <span id="roster-count-display">Not Selected: 0</span>
                <span class="rt-sep">·</span>
                <span id="total-count-display">Total: 0</span>
              </span>
              <div class="roster-sort-controls">
                <label>Sort:</label>
                <select id="roster-sort">
                  <option value="rsvp">RSVP</option>
                  <option value="practices">Practices</option>
                  <option value="lastName">Name</option>
                  <option value="eligibility">Eligibility</option>
                </select>
                <button id="sort-direction-btn" class="btn-sort-dir" title="Toggle sort direction">↓</button>
              </div>
            </div>
            <table class="roster-table" id="roster-table">
              <thead>
                <tr>
                  <th class="rt-col-zone">Zone</th>
                  <th class="rt-col-name">Player</th>
                  <th class="rt-col-rsvp">RSVP</th>
                  <th class="rt-col-elig">Elig</th>
                  <th class="rt-col-prac">Prac</th>
                  <th class="rt-col-roster">Roster</th>
                  <th class="rt-col-actions">Actions</th>
                </tr>
              </thead>
              <tbody id="roster-table-body"></tbody>
            </table>
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
    this.loadSavedMetadata();
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

      // Roster size toggle
      const rosterSizeBtn = e.target.closest('.btn-roster-size');
      if (rosterSizeBtn) {
        const size = parseInt(rosterSizeBtn.dataset.size);
        this.setRosterSize(size);
        return;
      }

      // Link button on unmatched cards
      const linkBtn = e.target.closest('.btn-link-player');
      if (linkBtn) {
        e.stopPropagation();
        const gmUserId = linkBtn.dataset.gmUserId;
        const gmNickname = linkBtn.dataset.gmNickname;
        const gmImage = linkBtn.dataset.gmImage;
        this.openLinkPopup(gmUserId, gmNickname, gmImage);
        return;
      }

      // Click-to-assign: if we're in slot selection mode and user clicks a player row
      if (this.selectingSlot !== null) {
        const row = e.target.closest('[data-player-id]');
        if (row && row.closest('#roster-table')) {
          const playerId = parseInt(row.getAttribute('data-player-id'));
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
      this.clubTeams = [];
      if (membersResponse) {
        const membersData = await membersResponse.json();
        if (membersData.success && membersData.data?.members) {
          this.groupmeMembers = membersData.data.members;
          this.clubTeams = membersData.data.teams || [];
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
   * Merge GroupMe members + roster-only players into a unified list.
   * The backend now returns:
   *   - "both": linked GM member who is also on a roster
   *   - "groupme_only": GM member (linked or not) who isn't on any roster
   *   - "roster_only": roster player not in GroupMe
   * Each entry has: teams[] array, source, linked flag, etc.
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
      // Always merge team roster info
      const teams = gm.teams || [];

      if (gm.linked && gm.personId) {
        // Linked member — enrich existing or add new
        const existing = playerByPersonId.get(gm.personId);
        if (existing) {
          // Already in players array from eligibility — add GroupMe + team metadata
          existing.gmNickname = gm.nickname;
          existing.gmImageUrl = gm.imageUrl;
          existing.gmUserId = gm.externalUserId;
          existing.gmLinked = true;
          existing.source = gm.source || 'both';
          existing.teams = teams;
          if (!existing.matchRsvp && gm.matchRsvp) {
            existing.matchRsvp = gm.matchRsvp;
          }
        } else {
          // Linked person not in eligibility list (on a sibling roster or GM only)
          const newPlayer = {
            personId: gm.personId,
            playerId: teams.length > 0 ? teams[0].playerId : null,
            firstName: gm.firstName,
            lastName: gm.lastName,
            jerseyNumber: null,
            matchRsvp: gm.matchRsvp,
            practiceCount: gm.practiceCount || 0,
            sessionsAttended: gm.practiceCount || 0,
            eligibilityStatus: teams.length > 0 ? 'not_computed' : 'not_on_roster',
            isGuest: true,
            gmNickname: gm.nickname,
            gmImageUrl: gm.imageUrl,
            gmUserId: gm.externalUserId,
            gmLinked: true,
            source: gm.source || 'both',
            teams: teams
          };
          this.players.push(newPlayer);
          playerByPersonId.set(gm.personId, newPlayer);
        }
      } else if (!gm.linked && gm.source === 'roster_only') {
        // Roster-only player not linked to GroupMe — may already be in players
        // (this shouldn't normally happen since roster_only means no GM, but be safe)
        if (gm.personId && !playerByPersonId.has(gm.personId)) {
          this.players.push({
            personId: gm.personId,
            playerId: teams.length > 0 ? teams[0].playerId : null,
            firstName: gm.firstName,
            lastName: gm.lastName,
            jerseyNumber: null,
            matchRsvp: gm.matchRsvp,
            practiceCount: gm.practiceCount || 0,
            sessionsAttended: gm.practiceCount || 0,
            eligibilityStatus: 'not_computed',
            isGuest: true,
            gmLinked: false,
            source: 'roster_only',
            teams: teams
          });
        }
      } else {
        // Unlinked GroupMe member
        if (gm.externalUserId && !unmatchedByExtId.has(gm.externalUserId)) {
          this.unmatchedRsvps.push({
            externalUserId: gm.externalUserId,
            externalUsername: gm.nickname,
            matchRsvp: gm.matchRsvp,
            gmImageUrl: gm.imageUrl,
            gmLinked: false,
            source: 'groupme_only'
          });
          unmatchedByExtId.set(gm.externalUserId, true);
        } else if (gm.externalUserId && unmatchedByExtId.has(gm.externalUserId)) {
          // Already in unmatched — enrich with image
          const existing = unmatchedByExtId.get(gm.externalUserId);
          if (existing && typeof existing === 'object') {
            existing.gmImageUrl = gm.imageUrl;
          }
        }
      }
    }

    // Enrich existing players that came from eligibility but weren't in GM members
    // (they may still have team data from roster)
    for (const p of this.players) {
      if (!p.teams) p.teams = [];
      if (p.source === undefined) p.source = 'eligibility';
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

  /**
   * Load saved lineup metadata (formation, roster size) from database.
   * This ensures edits survive rebuilds.
   */
  async loadSavedMetadata() {
    const matchId = this.navigation.context.match?.id;
    if (!matchId) return;

    try {
      const response = await this.auth.fetch(`/api/eligibility/lineup-meta/${matchId}`);
      const data = await response.json();
      if (!data.success || !data.data) return;

      const meta = data.data;

      // Restore formation
      if (meta.formationId) {
        const select = this.find('#formation-select');
        if (select) {
          select.value = meta.formationId;
          this.onFormationChange(String(meta.formationId));
        }
        // If we have positions JSON from DB, use it
        if (meta.formationPositions && this.selectedFormation) {
          this.selectedFormation.positions_json = meta.formationPositions;
        }
      }

      // Restore roster size
      if (meta.rosterSize) {
        this.setRosterSize(meta.rosterSize, true); // silent = don't re-save
      }
    } catch (e) {
      console.warn('Could not load saved metadata:', e);
    }
  }

  /**
   * Set game day roster size (18 or 20) and update UI + bench limit.
   */
  setRosterSize(size, silent = false) {
    this.rosterSize = size;

    // Update toggle buttons
    this.element.querySelectorAll('.btn-roster-size').forEach(btn => {
      btn.classList.toggle('active', parseInt(btn.dataset.size) === size);
    });

    // Update bench max display
    const benchMax = this.find('#bench-max');
    if (benchMax) benchMax.textContent = size - 11;

    // If bench has too many players, move extras to roster
    const maxBench = size - 11;
    while (this.zones.bench.length > maxBench) {
      const overflow = this.zones.bench.pop();
      this.zones.roster.unshift(overflow);
    }

    this.renderAllZones();

    // Auto-save metadata (don't block UI)
    if (!silent) {
      this.saveMetadata();
    }
  }

  /**
   * Save lineup metadata (formation, roster size) to database.
   */
  async saveMetadata() {
    const matchId = this.navigation.context.match?.id;
    if (!matchId) return;

    try {
      await this.auth.fetch(`/api/eligibility/lineup-meta/${matchId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          formationId: this.selectedFormation?.id || 0,
          rosterSize: this.rosterSize
        })
      });
    } catch (e) {
      console.warn('Failed to save metadata:', e);
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
    this.zones = { starting: [], bench: [], roster: [] };

    for (const player of this.players) {
      // If player already has lineup assignment from DB, respect it
      if (player.onLineup && player.isStarter) {
        this.zones.starting.push(player.playerId);
        continue;
      }
      if (player.onLineup && !player.isStarter) {
        this.zones.bench.push(player.playerId);
        continue;
      }
      // Everyone else goes to not-selected roster
      this.zones.roster.push(player.playerId);
    }

    // Enforce bench max based on roster size
    const maxBench = this.rosterSize - 11;
    while (this.zones.bench.length > maxBench) {
      const overflow = this.zones.bench.pop();
      this.zones.roster.unshift(overflow);
    }
  }

  // Sort roster by the active sort field
  sortRoster() {
    const statusRank = { 'priority_starter': 0, 'eligible_starter': 1, 'bench_only': 2, 'ineligible': 3, 'not_computed': 4, 'not_on_roster': 5 };
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
          if (cmp === 0) cmp = (b.sessionsAttended || 0) - (a.sessionsAttended || 0);
          break;
        case 'completeness': {
          // Sort by number of missing items (fewer missing = more complete = first)
          const missingA = this.countMissing(a);
          const missingB = this.countMissing(b);
          cmp = missingB - missingA; // More missing items first (needs attention)
          if (cmp === 0) cmp = ((a.lastName || '') + (a.firstName || '')).localeCompare((b.lastName || '') + (b.firstName || ''));
          break;
        }
        case 'practices':
          cmp = (b.sessionsAttended || 0) - (a.sessionsAttended || 0);
          break;
        case 'lastName':
          cmp = ((a.lastName || '') + (a.firstName || '')).localeCompare((b.lastName || '') + (b.firstName || ''));
          break;
        case 'eligibility':
          cmp = (statusRank[a.eligibilityStatus] ?? 6) - (statusRank[b.eligibilityStatus] ?? 6);
          if (cmp === 0) cmp = (b.sessionsAttended || 0) - (a.sessionsAttended || 0);
          break;
      }
      return cmp * dir;
    });
  }

  autoFillFromEligibility() {
    // Reset all zones
    this.zones = { starting: [], bench: [], roster: [] };

    // Sort eligible players by attendance (highest first)
    const sorted = [...this.players].sort((a, b) => {
      const statusOrder = { 'priority_starter': 0, 'eligible_starter': 1, 'bench_only': 2, 'ineligible': 3 };
      const orderA = statusOrder[a.eligibilityStatus] ?? 4;
      const orderB = statusOrder[b.eligibilityStatus] ?? 4;
      if (orderA !== orderB) return orderA - orderB;
      return b.sessionsAttended - a.sessionsAttended;
    });

    const maxBench = this.rosterSize - 11;
    let starterCount = 0;
    let benchCount = 0;

    for (const player of sorted) {
      if (player.matchRsvp === 'no') {
        this.zones.roster.push(player.playerId);
      } else if (starterCount < 11 && player.eligibilityStatus !== 'ineligible') {
        this.zones.starting.push(player.playerId);
        starterCount++;
      } else if (benchCount < maxBench && player.eligibilityStatus !== 'ineligible') {
        this.zones.bench.push(player.playerId);
        benchCount++;
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
    this.renderPlayerTable();
    this.updateCounts();
  }

  renderPlayerTable() {
    this.sortRoster();
    const tbody = this.find('#roster-table-body');
    if (!tbody) return;
    tbody.innerHTML = '';

    // Build ordered list: starters first, then bench, then not selected
    const sections = [
      { zone: 'starting', label: '⚽ Starting XI', ids: this.zones.starting.filter(id => id !== null) },
      { zone: 'bench', label: '🪑 Bench', ids: this.zones.bench },
      { zone: 'roster', label: '📋 Not Selected', ids: this.zones.roster }
    ];

    for (const section of sections) {
      // Section header row
      const headerRow = document.createElement('tr');
      headerRow.className = 'rt-section-header';
      headerRow.innerHTML = `<td colspan="7" class="rt-section-label rt-section-${section.zone}">${section.label} (${section.ids.length})</td>`;
      tbody.appendChild(headerRow);

      if (section.ids.length === 0 && section.zone !== 'roster') {
        const emptyRow = document.createElement('tr');
        emptyRow.className = 'rt-empty-row';
        emptyRow.innerHTML = `<td colspan="7" class="rt-empty">—</td>`;
        tbody.appendChild(emptyRow);
        continue;
      }

      for (const playerId of section.ids) {
        const player = this.getPlayerById(playerId);
        if (!player) continue;
        const row = this.createPlayerRow(player, section.zone);
        tbody.appendChild(row);
      }

      // Unmatched GroupMe users at the end of not-selected
      if (section.zone === 'roster') {
        for (const u of this.unmatchedRsvps) {
          const row = this.createUnmatchedRow(u);
          tbody.appendChild(row);
        }
      }
    }
  }

  updateCounts() {
    const sc = this.find('#starting-count');
    const starterCount = this.zones.starting.filter(id => id !== null).length;
    const maxBench = this.rosterSize - 11;
    if (sc) sc.textContent = `${starterCount}/11`;

    const bc = this.find('#bench-count-display');
    if (bc) bc.textContent = `Bench: ${this.zones.bench.length}/${maxBench}`;

    const rc = this.find('#roster-count-display');
    const rosterTotal = this.zones.roster.length + this.unmatchedRsvps.length;
    if (rc) rc.textContent = `Not Selected: ${rosterTotal}`;

    const tc = this.find('#total-count-display');
    if (tc) tc.textContent = `Total: ${starterCount + this.zones.bench.length + rosterTotal}`;
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

  createPlayerRow(player, zone) {
    const row = document.createElement('tr');
    row.className = `rt-player-row ${this.getEligibilityClass(player)}`;
    row.setAttribute('draggable', 'true');
    row.setAttribute('data-player-id', player.playerId);
    row.setAttribute('data-zone', zone);

    // Zone badge
    const zoneBadge = zone === 'starting' ? '⚽' : zone === 'bench' ? '🪑' : '—';
    const zoneClass = `rt-zone-${zone}`;

    // Name
    const name = `${player.firstName || ''} ${player.lastName || ''}`.trim();
    const jersey = player.jerseyNumber ? `#${player.jerseyNumber}` : '';

    // Source indicator
    const sourceTag = player.source === 'roster_only'
      ? '<span class="rt-tag rt-tag-roster">roster</span>'
      : player.source === 'groupme_only' || player.eligibilityStatus === 'not_on_roster'
        ? '<span class="rt-tag rt-tag-gm">GM</span>'
        : '';

    // RSVP
    const rsvpClass = this.getRsvpClass(player.matchRsvp);
    const rsvpShort = this.getRsvpShort(player.matchRsvp);

    // Eligibility
    const statusIcon = this.getStatusIcon(player.eligibilityStatus);

    // Practices
    const sessions = player.sessionsAttended ?? player.practiceCount ?? 0;
    const lookback = this.policy?.lookbackCount || 0;

    // Roster info
    const teams = player.teams || [];
    const rosterBadge = player.onOfficialRoster
      ? '<span class="rt-tag rt-tag-official">official</span>'
      : teams.length > 0
        ? '<span class="rt-tag rt-tag-team">team</span>'
        : '<span class="rt-tag rt-tag-none">none</span>';

    // Action buttons based on zone
    let actions = '';
    if (zone === 'roster') {
      actions = `<button class="rt-btn rt-btn-start" data-action="to-starting" title="Add to Starting XI">⚽</button>
                 <button class="rt-btn rt-btn-bench" data-action="to-bench" title="Add to Bench">🪑</button>`;
    } else if (zone === 'bench') {
      actions = `<button class="rt-btn rt-btn-start" data-action="to-starting" title="Move to Starting XI">⚽</button>
                 <button class="rt-btn rt-btn-remove" data-action="to-roster" title="Remove from lineup">✕</button>`;
    } else if (zone === 'starting') {
      actions = `<button class="rt-btn rt-btn-bench" data-action="to-bench" title="Move to Bench">🪑</button>
                 <button class="rt-btn rt-btn-remove" data-action="to-roster" title="Remove from lineup">✕</button>`;
    }

    row.innerHTML = `
      <td class="rt-col-zone"><span class="rt-zone-badge ${zoneClass}">${zoneBadge}</span></td>
      <td class="rt-col-name"><span class="rt-name">${name}</span> <span class="rt-jersey">${jersey}</span> ${sourceTag}</td>
      <td class="rt-col-rsvp"><span class="rsvp-dot ${rsvpClass}">${rsvpShort}</span></td>
      <td class="rt-col-elig">${statusIcon}</td>
      <td class="rt-col-prac">${sessions}/${lookback}</td>
      <td class="rt-col-roster">${rosterBadge}</td>
      <td class="rt-col-actions">${actions}</td>
    `;

    // Action button clicks
    row.querySelectorAll('.rt-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const action = btn.dataset.action;
        if (action === 'to-starting') {
          this.movePlayer(player.playerId, zone, 'starting');
        } else if (action === 'to-bench') {
          this.movePlayer(player.playerId, zone, 'bench');
        } else if (action === 'to-roster') {
          this.movePlayer(player.playerId, zone, 'roster');
        }
      });
    });

    return row;
  }

  createUnmatchedRow(user) {
    const row = document.createElement('tr');
    row.className = 'rt-player-row rt-unmatched';
    row.setAttribute('data-external-id', user.externalUserId);

    const rsvpClass = this.getRsvpClass(user.matchRsvp);
    const rsvpShort = this.getRsvpShort(user.matchRsvp);

    row.innerHTML = `
      <td class="rt-col-zone"><span class="rt-zone-badge rt-zone-roster">—</span></td>
      <td class="rt-col-name">
        <span class="rt-name">${user.externalUsername || '?'}</span>
        <span class="rt-tag rt-tag-unlinked">unlinked</span>
      </td>
      <td class="rt-col-rsvp"><span class="rsvp-dot ${rsvpClass}">${rsvpShort}</span></td>
      <td class="rt-col-elig">❓</td>
      <td class="rt-col-prac">—</td>
      <td class="rt-col-roster"><span class="rt-tag rt-tag-none">none</span></td>
      <td class="rt-col-actions">
        <button class="rt-btn rt-btn-link btn-link-player"
                data-gm-user-id="${user.externalUserId}"
                data-gm-nickname="${(user.externalUsername || '').replace(/"/g, '&quot;')}"
                data-gm-image="${(user.gmImageUrl || '').replace(/"/g, '&quot;')}"
                title="Link to person">🔗</button>
      </td>
    `;

    return row;
  }

  getRsvpShort(rsvp) {
    switch (rsvp) {
      case 'yes': return '✓';
      case 'no': return '✗';
      case 'maybe': return '?';
      default: return '…';
    }
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
    const panel = this.find('.roster-table-wrapper');
    if (panel) panel.classList.add('roster-selecting');
  }

  cancelSlotSelection() {
    this.selectingSlot = null;
    const banner = this.find('#select-mode-banner');
    if (banner) banner.style.display = 'none';
    
    this.element.querySelectorAll('.pitch-slot').forEach(s => s.classList.remove('slot-selecting'));
    const panel = this.find('.roster-table-wrapper');
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
      case 'not_computed': return '➖';
      case 'not_on_roster': return '👤';
      default: return '❓';
    }
  }

  // Count missing data items for a player (used for completeness sort)
  countMissing(player) {
    let missing = 0;
    if (!player.gmLinked && !player.gmUserId) missing++;       // No GroupMe link
    if (!(player.teams?.length > 0) && player.source !== 'eligibility') missing++;  // Not on roster
    if (!player.matchRsvp) missing++;                           // No RSVP
    return missing;
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

    // Auto-save metadata
    this.saveMetadata();
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
    const table = e.target.closest('.roster-table-wrapper');
    if (!zone && !slot && !table) return;

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

    // Dropped on pitch zone (but not a specific slot)
    const zone = e.target.closest('.lineup-zone');
    if (zone) {
      const targetZone = this.getZoneKey(zone.id);
      if (targetZone === 'starting') {
        this.movePlayerToNextEmptySlot(this.dragState.playerId, this.dragState.sourceZone, this.dragState.sourceSlot);
        this.dragState = null;
        return;
      }
    }

    // Dropped on the table — move to roster (not selected)
    const table = e.target.closest('.roster-table-wrapper');
    if (table) {
      this.movePlayer(this.dragState.playerId, this.dragState.sourceZone, 'roster');
      this.dragState = null;
      return;
    }

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
    } else if (toZone === 'bench') {
      // Enforce bench capacity
      const maxBench = this.rosterSize - 11;
      if (this.zones.bench.length >= maxBench) {
        // Bench full — move last bench player to roster
        const bumped = this.zones.bench.pop();
        this.zones.roster.unshift(bumped);
      }
      this.zones.bench.push(playerId);
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
  // Link Popup: Link a GroupMe user to an existing person
  // ============================================================================
  openLinkPopup(gmUserId, gmNickname, gmImageUrl) {
    // Build list of unlinked roster players (persons not yet connected to GM)
    const linkedPersonIds = new Set();
    for (const p of this.players) {
      if (p.gmLinked && p.personId) linkedPersonIds.add(p.personId);
    }

    // Candidates: all players who have a personId but no GM link
    const candidates = this.players
      .filter(p => p.personId && !linkedPersonIds.has(p.personId))
      .sort((a, b) => (a.lastName + a.firstName).localeCompare(b.lastName + b.firstName));

    // Also include roster-only players from groupmeMembers
    const candidatePersonIds = new Set(candidates.map(c => c.personId));
    for (const gm of this.groupmeMembers) {
      if (gm.personId && gm.source === 'roster_only' && !linkedPersonIds.has(gm.personId) && !candidatePersonIds.has(gm.personId)) {
        candidates.push({
          personId: gm.personId,
          firstName: gm.firstName,
          lastName: gm.lastName,
          teams: gm.teams || []
        });
        candidatePersonIds.add(gm.personId);
      }
    }

    candidates.sort((a, b) => ((a.lastName || '') + (a.firstName || '')).localeCompare((b.lastName || '') + (b.firstName || '')));

    const overlay = document.createElement('div');
    overlay.className = 'attendance-overlay';

    const hasImg = gmImageUrl && gmImageUrl.length > 0;
    const avatarHtml = hasImg
      ? `<img class="link-popup-avatar" src="${gmImageUrl}.avatar" alt="${gmNickname}">`
      : '';

    overlay.innerHTML = `
      <div class="link-popup">
        <div class="link-popup-header">
          ${avatarHtml}
          <div>
            <h3>Link "${gmNickname}"</h3>
            <p class="link-popup-subtitle">Select an existing player to link this GroupMe user to:</p>
          </div>
          <button class="attendance-close-btn">✕</button>
        </div>
        <div class="link-popup-search">
          <input type="text" id="link-search-input" placeholder="Search by name..." class="link-search-input">
        </div>
        <div class="link-popup-list" id="link-candidate-list">
          ${candidates.map(c => {
            const teamLabels = (c.teams || []).map(t => t.divisionName || t.teamName || '').join(', ');
            return `
              <div class="link-candidate" data-person-id="${c.personId}">
                <div class="link-candidate-name">${c.firstName} ${c.lastName}</div>
                ${teamLabels ? `<div class="link-candidate-teams">${teamLabels}</div>` : '<div class="link-candidate-teams" style="color:var(--color-warning);">No roster</div>'}
              </div>`;
          }).join('')}
          ${candidates.length === 0 ? '<p class="link-empty">No unlinked players found</p>' : ''}
        </div>
      </div>
    `;

    document.body.appendChild(overlay);

    // Close handlers
    overlay.querySelector('.attendance-close-btn').addEventListener('click', () => overlay.remove());
    overlay.addEventListener('click', (e) => { if (e.target === overlay) overlay.remove(); });

    // Search filter
    const searchInput = overlay.querySelector('#link-search-input');
    searchInput.focus();
    searchInput.addEventListener('input', () => {
      const query = searchInput.value.toLowerCase();
      overlay.querySelectorAll('.link-candidate').forEach(el => {
        const name = el.querySelector('.link-candidate-name').textContent.toLowerCase();
        el.style.display = name.includes(query) ? '' : 'none';
      });
    });

    // Click to link
    overlay.querySelector('#link-candidate-list').addEventListener('click', async (e) => {
      const candidate = e.target.closest('.link-candidate');
      if (!candidate) return;

      const personId = parseInt(candidate.dataset.personId);
      candidate.classList.add('link-candidate-loading');

      try {
        const response = await this.auth.fetch('/api/groupme/link', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            externalUserId: gmUserId,
            personId: personId,
            nickname: gmNickname,
            imageUrl: gmImageUrl
          })
        });
        const data = await response.json();
        if (!data.success) throw new Error(data.message);

        overlay.remove();
        // Reload to reflect the new link
        await this.loadEligibilityData();
      } catch (err) {
        console.error('Link failed:', err);
        candidate.classList.remove('link-candidate-loading');
        alert('Failed to link: ' + err.message);
      }
    });
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

    const starters = this.zones.starting
      .map((playerId, slotIndex) => playerId ? { playerId, slotNumber: slotIndex } : null)
      .filter(Boolean);
    const bench = this.zones.bench.map(playerId => ({ playerId }));

    try {
      const response = await this.auth.fetch(`/api/eligibility/lineup/${matchId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          starters,
          bench,
          formationId: this.selectedFormation?.id || 0,
          rosterSize: this.rosterSize
        })
      });

      const data = await response.json();
      if (data.success) {
        const total = starters.length + bench.length;
        alert(`✓ Lineup saved! ${starters.length} starters + ${bench.length} bench = ${total} game day roster.`);
      } else {
        throw new Error(data.message || 'Failed to save');
      }
    } catch (error) {
      console.error('Error saving lineup:', error);
      alert('Failed to save lineup: ' + error.message);
    }
  }
}
