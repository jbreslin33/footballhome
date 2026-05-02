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
      starting: [],    // Player IDs in starting XI (max 11)
      bench: [],       // Player IDs on game day bench (rosterSize - 11)
      unavailable: []  // Not selected / unavailable / no response
    };
    this.playerPositions = {}; // {playerId: {x, y}} free-form pitch positions (canonical: x=across, y=goal-to-goal)
    this.sortField = 'rsvp';  // Default sort
    this.sortAsc = true;
    this.poolSort = 'practices'; // Pool sort: practices | eligibility | name
    this.dragState = null;
    this.selectingSlot = null; // When non-null, clicking a player card assigns to this slot
    this.activeOverlay = null;  // 'match' | teamId string | null
    this.trainingEvents = [];     // Training events for this week
    this.trainingData = new Map(); // personId → { eventId → {attended, source} }
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

          <!-- Controls row: Formation + Roster Size + Overlay Toggles + Actions -->
          <div class="lineup-controls-row">
            <div class="formation-info">
              <span class="formation-label">Us: <strong id="detected-formation">—</strong></span>
              <span class="formation-vs">vs</span>
              <span class="formation-label">Opp:</span>
              <select id="opponent-formation-select">
                <option value="">—</option>
              </select>
            </div>
            <div class="roster-size-selector">
              <label>Roster:</label>
              <div class="roster-size-toggle">
                <button id="roster-size-18" class="btn-roster-size" data-size="18">18</button>
                <button id="roster-size-20" class="btn-roster-size active" data-size="20">20</button>
              </div>
            </div>
            <div class="overlay-toggles" id="overlay-toggles">
              <select id="overlay-select" class="overlay-select">
                <option value="">⚽ Show Pitch</option>
              </select>
            </div>
            <div class="lineup-actions-inline">
              <button id="fit-screen-btn" class="btn btn-secondary btn-sm" title="Fit pitch to screen">🖥️ Fit</button>
              <button id="auto-fill-btn" class="btn btn-secondary btn-sm">🤖 Auto-Fill</button>
              <button id="save-lineup-btn" class="btn btn-primary btn-sm">💾 Save</button>
            </div>
          </div>

          <!-- Selection mode banner (hidden by default) -->
          <div id="select-mode-banner" class="select-mode-banner" style="display: none;">
            <span>👆 Click a player to assign to <strong id="select-slot-label"></strong></span>
            <button id="cancel-select-btn" class="btn btn-sm btn-secondary">Cancel</button>
          </div>

          <!-- Pitch + Overlay Container -->
          <div class="pitch-overlay-container">
            <!-- Counts header -->
            <div class="pitch-fullsize-header">
              <span>📋 Roster: <span id="roster-count-display">0/20</span></span>
              <span class="header-sep">·</span>
              <span>⚽ <span id="starting-count">0/11</span></span>
              <span class="header-sep">·</span>
              <span>🪑 <span id="bench-count-display">0/9</span></span>
            </div>

            <!-- Pitch row: Pitch | Bench -->
            <div class="pitch-and-bench">
              <!-- Full-size Pitch -->
              <div class="pitch-fullsize-wrapper lineup-zone zone-starting" id="zone-starting">
                <div class="pitch pitch-fullsize" id="pitch-canvas">
                  <div class="pitch-markings">
                    <div class="pitch-goal pitch-goal-top"></div>
                    <div class="pitch-box pitch-box-top"></div>
                    <div class="pitch-six-yard pitch-six-yard-top"></div>
                    <div class="pitch-center-circle"></div>
                    <div class="pitch-center-line"></div>
                    <div class="pitch-six-yard pitch-six-yard-bottom"></div>
                    <div class="pitch-box pitch-box-bottom"></div>
                    <div class="pitch-goal pitch-goal-bottom"></div>
                  </div>
                  <div id="pitch-players" class="pitch-players"></div>
                </div>
              </div>

              <!-- Bench Area (right strip) -->
              <div class="pitch-bench-area lineup-zone" id="zone-bench">
                <div class="bench-label">🪑 Bench</div>
                <div class="bench-seats" id="bench-players"></div>
              </div>
            </div>

            <!-- Lineup Full Toast -->
            <div id="lineup-toast" class="lineup-toast" style="display:none;"></div>

            <!-- Roster Overlay Panel (floats over pitch) -->
            <div class="roster-overlay-panel" id="roster-overlay-panel" style="display: none;">
              <div class="overlay-panel-header">
                <div class="overlay-tabs" id="overlay-tabs"></div>
                <div class="overlay-zone-counts" id="overlay-zone-counts"></div>
                <button id="overlay-close-btn" class="overlay-close-btn">✕</button>
              </div>
              <div class="overlay-panel-body">
                <table class="overlay-table" id="roster-table">
                  <thead>
                    <tr>
                      <th class="ot-col-name sortable-col" data-sort="lastName">Player ↕</th>
                      <th class="ot-col-zone sortable-col" data-sort="zone">Zone ↕</th>
                      <th class="ot-col-rsvp sortable-col" data-sort="rsvp">RSVP ↕</th>
                      <th class="ot-col-elig sortable-col" data-sort="eligibility">Elig ↕</th>
                      <th class="ot-col-prac sortable-col" data-sort="practices">Total ↕</th>
                      <th class="ot-col-actions">Actions</th>
                    </tr>
                  </thead>
                  <tbody id="roster-table-body"></tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Policy summary bar -->
          <div id="policy-bar" class="policy-bar"></div>

          <!-- ── Player Pool ─────────────────────────────────────── -->
          <div class="player-pool-section">
            <div class="player-pool-header">
              <span class="player-pool-title">👥 Players</span>
              <span class="player-pool-hint">Drag to pitch · click RSVP to update</span>
              <button id="pool-add-btn" class="btn btn-secondary btn-sm">+ Add Player</button>
            </div>

            <!-- Going -->
            <div class="pool-group" id="pool-group-yes">
              <div class="pool-group-label pool-group-going">✓ Going <span id="pool-count-yes" class="pool-count"></span></div>
              <div class="pool-rows" id="pool-rows-yes"></div>
            </div>

            <!-- Maybe / Pending -->
            <div class="pool-group" id="pool-group-maybe">
              <div class="pool-group-label pool-group-maybe">? Maybe / Pending <span id="pool-count-maybe" class="pool-count"></span></div>
              <div class="pool-rows" id="pool-rows-maybe"></div>
            </div>

            <!-- Not Going -->
            <div class="pool-group" id="pool-group-no">
              <div class="pool-group-label pool-group-no">✗ Not Going <span id="pool-count-no" class="pool-count"></span></div>
              <div class="pool-rows" id="pool-rows-no"></div>
            </div>

            <!-- Unlinked GroupMe RSVPs -->
            <div class="pool-group" id="pool-group-unlinked" style="display:none;">
              <div class="pool-group-label pool-group-unlinked">🔗 Unlinked GroupMe RSVPs</div>
              <div class="pool-rows" id="pool-rows-unlinked"></div>
            </div>
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
          this.lastSyncedAt = syncData.data.syncedAt || new Date().toISOString();
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
      // Overlay toggle buttons
      const toggleBtn = e.target.closest('.overlay-toggle-btn');
      if (toggleBtn) {
        this.toggleOverlay(toggleBtn.dataset.overlay);
        return;
      }
      // Overlay close button
      if (e.target.id === 'overlay-close-btn' || e.target.closest('#overlay-close-btn')) {
        this.activeOverlay = null;
        this.find('#roster-overlay-panel').style.display = 'none';
        const sel = this.find('#overlay-select');
        if (sel) sel.value = '';
        return;
      }
      // Sortable column headers
      const sortCol = e.target.closest('.sortable-col');
      if (sortCol) {
        const field = sortCol.dataset.sort;
        if (this.sortField === field) {
          this.sortAsc = !this.sortAsc;
        } else {
          this.sortField = field;
          this.sortAsc = true;
        }
        this.renderOverlayTable();
        return;
      }

      // Roster size toggle
      const rosterSizeBtn = e.target.closest('.btn-roster-size');
      if (rosterSizeBtn) {
        const size = parseInt(rosterSizeBtn.dataset.size);
        this.setRosterSize(size);
        return;
      }

      // Fit to screen toggle
      if (e.target.id === 'fit-screen-btn' || e.target.closest('#fit-screen-btn')) {
        this.toggleFitToScreen();
        return;
      }

      // Link button on unmatched cards (overlay or pool)
      const linkBtn = e.target.closest('.btn-link-player');
      if (linkBtn) {
        e.stopPropagation();
        const gmUserId = linkBtn.dataset.gmUserId;
        const gmNickname = linkBtn.dataset.gmNickname;
        const gmImage = linkBtn.dataset.gmImage;
        this.openLinkPopup(gmUserId, gmNickname, gmImage);
        return;
      }

      // RSVP toggle buttons in player pool
      const rsvpBtn = e.target.closest('.rsvp-btn');
      if (rsvpBtn) {
        e.stopPropagation();
        const playerId = parseInt(rsvpBtn.dataset.playerId);
        const rsvpStatus = rsvpBtn.dataset.rsvp;
        this.updatePlayerRsvp(playerId, rsvpStatus);
        return;
      }

      // Add to bench button in player pool
      const addBenchBtn = e.target.closest('.pool-add-bench-btn');
      if (addBenchBtn) {
        e.stopPropagation();
        const playerId = parseInt(addBenchBtn.dataset.playerId);
        const maxBench = this.rosterSize - 11;
        if (this.zones.bench.length >= maxBench) {
          this.showLineupToast(`Bench is full (${maxBench}/${maxBench})`);
          return;
        }
        this.removePlayerFromAllZones(playerId);
        this.zones.bench.push(playerId);
        this.renderAllZones();
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

      // Click on empty pitch area — no-op (drag to place players)
    });

    // Opponent formation selector + Overlay roster selector
    this.element.addEventListener('change', (e) => {
      if (e.target.id === 'pool-sort-select') {
        this.poolSort = e.target.value;
        this.renderUnavailablePlayers();
        return;
      }
      if (e.target.id === 'opponent-formation-select') {
        this.opponentFormation = e.target.value ? this.formations.find(f => f.id === parseInt(e.target.value))?.code || '' : '';
        this.renderPitchPlayers();
        this.saveMetadata();
      }
      if (e.target.id === 'overlay-select') {
        const val = e.target.value;
        if (val) {
          this.toggleOverlay(val);
        } else {
          this.activeOverlay = null;
          this.find('#roster-overlay-panel').style.display = 'none';
        }
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
    this.element.addEventListener('click', (e) => {
      const card = e.target.closest('[data-player-id]');
      if (card && (card.classList.contains('pool-row') || card.classList.contains('zone-chip') || card.classList.contains('pitch-player-chip'))) {
        e.preventDefault();
        const playerId = parseInt(card.getAttribute('data-player-id'));
        this.openAttendancePopup(playerId);
      }
    });

    // Training attendance checkbox toggle
    this.element.addEventListener('change', (e) => {
      const cb = e.target.closest('.train-cb');
      if (cb) {
        e.stopPropagation();
        this.toggleTrainingAttendance(cb);
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

      // Fetch eligibility, GroupMe members, training week, AND game roster in parallel
      const [eligResponse, membersResponse, trainingResponse, rosterResponse] = await Promise.all([
        this.auth.fetch(`/api/eligibility/match/${matchId}${teamParam}`),
        teamId ? this.auth.fetch(`/api/groupme/members/${teamId}?matchId=${matchId}`) : Promise.resolve(null),
        teamId ? this.auth.fetch(`/api/groupme/training-week/${teamId}?matchId=${matchId}`) : Promise.resolve(null),
        this.auth.fetch(`/api/matches/${matchId}/game-roster`)
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
      this.allChats = [];
      if (membersResponse) {
        const membersData = await membersResponse.json();
        if (membersData.success && membersData.data?.members) {
          this.groupmeMembers = membersData.data.members;
          this.clubTeams = membersData.data.teams || [];
          this.allChats = membersData.data.chats || [];
          this.mergeGroupMeMembers();
        }
      }

      // Load training week data
      this.trainingEvents = [];
      this.trainingData = new Map();
      if (trainingResponse) {
        const trainingResult = await trainingResponse.json();
        if (trainingResult.success && trainingResult.data) {
          this.trainingEvents = trainingResult.data.events || [];
          this.mergeTrainingData(trainingResult.data.players || []);
        }
      }

      // Load game day roster — mark players on the game roster
      this.gameDayRosterIds = new Set();
      if (rosterResponse) {
        const rosterResult = await rosterResponse.json();
        if (rosterResult.success && rosterResult.data) {
          for (const rp of rosterResult.data) {
            this.gameDayRosterIds.add(rp.playerId);
          }
        }
      }

      // Update training day column headers
      this.updateTrainingHeaders();

      // Update subtitle
      const subtitle = this.find('#lineup-subtitle');
      subtitle.textContent = `${this.matchInfo.homeTeam} vs ${this.matchInfo.awayTeam} — ${this.matchInfo.date}`;

      // Show GroupMe sync warning if needed
      this.renderGroupmeWarning();

      // Render policy bar
      this.renderPolicyBar();

      // Auto-classify players into zones based on eligibility + RSVP + existing lineup
      this.classifyPlayersIntoZones();

      // Render overlay toggle buttons
      this.renderOverlayToggles();

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
        // Unlinked GroupMe member — only add to pool if they have an RSVP for this match
        if (gm.externalUserId && gm.matchRsvp && !unmatchedByExtId.has(gm.externalUserId)) {
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

  /**
   * Merge training attendance data from training-week API onto players.
   * Maps personId → { eventId → {attended, source} }
   * NOTE: Does NOT overwrite sessionsAttended — the eligibility API's value
   * is the source of truth (it deduplicates by date correctly).
   */
  mergeTrainingData(trainingPlayers) {
    this.trainingData = new Map();
    for (const tp of trainingPlayers) {
      if (!tp.personId) continue;
      const att = {};
      for (const [eventId, val] of Object.entries(tp.attendance || {})) {
        if (val) {
          att[eventId] = val;
        }
      }
      this.trainingData.set(tp.personId, att);
    }
  }

  /**
   * Insert per-day training column headers into the overlay table.
   */
  updateTrainingHeaders() {
    const headerRow = this.element?.querySelector('#roster-table thead tr');
    if (!headerRow) return;

    // Remove old training-day headers (if re-rendering)
    headerRow.querySelectorAll('.ot-col-train').forEach(th => th.remove());

    // Insert before the "Total" (practices) column
    const pracTh = headerRow.querySelector('[data-sort="practices"]');
    if (!pracTh) return;

    const dayAbbrev = { sunday:'Sun', monday:'Mon', tuesday:'Tue', wednesday:'Wed', thursday:'Thu', friday:'Fri', saturday:'Sat' };
    for (const evt of this.trainingEvents) {
      const titleLower = evt.title.toLowerCase();
      const shortTitle = titleLower.includes('pickup') ? '⚽P'
        : Object.entries(dayAbbrev).find(([full]) => titleLower.includes(full))?.[1] || evt.eventDate.slice(5);
      const th = document.createElement('th');
      th.className = 'ot-col-train';
      th.title = `${evt.title} (${evt.eventDate})`;
      th.textContent = shortTitle;
      headerRow.insertBefore(th, pracTh);
    }
  }

  /**
   * Handle training attendance checkbox toggle — POST to backend.
   */
  async toggleTrainingAttendance(cb) {
    const personId = parseInt(cb.dataset.personId);
    const eventId = parseInt(cb.dataset.eventId);
    const attended = cb.checked;

    try {
      const response = await this.auth.fetch('/api/groupme/training-attendance', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ personId, chatEventId: eventId, attended })
      });
      const result = await response.json();
      if (!result.success) {
        console.error('Toggle failed:', result.message);
        cb.checked = !attended; // revert
        return;
      }

      // Update local training data
      if (!this.trainingData.has(personId)) {
        this.trainingData.set(personId, {});
      }
      this.trainingData.get(personId)[eventId] = { attended, source: 'manual' };

      // Update sessionsAttended count on player (dedup by event date)
      const player = this.players.find(p => p.personId === personId);
      if (player) {
        const pData = this.trainingData.get(personId) || {};
        const attendedDates = new Set();
        for (const [evtId, val] of Object.entries(pData)) {
          if (val && val.attended) {
            const evt = this.trainingEvents.find(e => String(e.id) === String(evtId));
            if (evt) attendedDates.add(evt.eventDate);
          }
        }
        player.sessionsAttended = attendedDates.size;

        // Update the Total cell in same row
        const row = cb.closest('tr');
        if (row) {
          const pracCell = row.querySelector('.ot-col-prac');
          if (pracCell) pracCell.textContent = player.sessionsAttended;
        }

        // Update pitch chip badge if on pitch
        const chip = this.find(`[data-player-id="${player.playerId}"][data-zone="starting"] .chip-badge`);
        if (chip) chip.textContent = `${player.sessionsAttended}/${this.policy?.lookbackCount || 0}`;
      }
    } catch (err) {
      console.error('Toggle error:', err);
      cb.checked = !attended;
    }
  }

  async loadFormations() {
    try {
      this.formations = [
        { id: 1, code: '4-3-3', name: '4-3-3' },
        { id: 2, code: '4-4-2', name: '4-4-2' },
        { id: 3, code: '3-5-2', name: '3-5-2' },
        { id: 4, code: '4-2-3-1', name: '4-2-3-1' },
        { id: 5, code: '3-4-3', name: '3-4-3' },
        { id: 6, code: '5-3-2', name: '5-3-2' },
        { id: 7, code: '5-4-1', name: '5-4-1' },
        { id: 8, code: '4-1-4-1', name: '4-1-4-1' },
        { id: 9, code: '4-5-1', name: '4-5-1' }
      ];

      // Default formation for ghost positions (4-3-3)
      this.selectedFormation = this.formations[0];

      // Populate opponent formation dropdown
      const select = this.find('#opponent-formation-select');
      this.formations.forEach(f => {
        const opt = document.createElement('option');
        opt.value = f.id;
        opt.textContent = f.name;
        select.appendChild(opt);
      });

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

      // Restore opponent formation
      if (meta.opponentFormationId) {
        const select = this.find('#opponent-formation-select');
        if (select) {
          select.value = meta.opponentFormationId;
          this.opponentFormation = this.formations.find(f => f.id === parseInt(meta.opponentFormationId))?.code || '';
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

    // If bench has too many players, move extras to unavailable
    const maxBench = size - 11;
    while (this.zones.bench.length > maxBench) {
      const overflow = this.zones.bench.pop();
      this.zones.unavailable.unshift(overflow);
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
      const oppSelect = this.find('#opponent-formation-select');
      await this.auth.fetch(`/api/eligibility/lineup-meta/${matchId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          formationId: this.selectedFormation?.id || 0,
          opponentFormationId: oppSelect ? parseInt(oppSelect.value) || 0 : 0,
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
    
    // Format the last sync timestamp
    const lastSyncTime = this.lastSyncedAt || sync.lastSync;
    const timeStr = lastSyncTime ? new Date(lastSyncTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '';
    
    let icon, message, level;
    const refreshBtn = '<button id="groupme-refresh-btn" class="btn-groupme-refresh">🔄 Refresh</button>';
    
    if (status === 'fresh') {
      icon = '✅';
      message = `GroupMe synced${timeStr ? ' at ' + timeStr : ''}. ${refreshBtn}`;
      level = 'success';
    } else if (status === 'no_data') {
      icon = '🚫';
      message = `No GroupMe event linked for this match — RSVPs unavailable. ${refreshBtn}`;
      level = 'error';
    } else if (status === 'very_stale') {
      const days = Math.floor(minutes / 1440);
      icon = '⚠️';
      message = `RSVP data is ${days} day${days !== 1 ? 's' : ''} old${timeStr ? ' (last: ' + timeStr + ')' : ''}. ${refreshBtn}`;
      level = 'error';
    } else if (status === 'stale') {
      const hours = Math.floor(minutes / 60);
      const mins = minutes % 60;
      icon = '⏳';
      message = `RSVPs synced ${hours}h ${mins}m ago${timeStr ? ' (' + timeStr + ')' : ''}. ${refreshBtn}`;
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
    this.zones = { starting: [], bench: [], unavailable: [] };
    this.playerPositions = {};

    const positions = this.getFormationPositions();
    const maxBench = this.rosterSize - 11;
    const hasGameRoster = this.gameDayRosterIds && this.gameDayRosterIds.size > 0;

    for (const player of this.players) {
      // If game day roster is set, non-roster players go straight to unavailable
      if (hasGameRoster && !this.gameDayRosterIds.has(player.playerId)) {
        this.zones.unavailable.push(player.playerId);
        continue;
      }

      if (player.onLineup && player.isStarter) {
        this.zones.starting.push(player.playerId);
        const posIdx = this.zones.starting.length - 1;
        if (posIdx < positions.length) {
          this.playerPositions[player.playerId] = { x: positions[posIdx].x, y: positions[posIdx].y };
        } else {
          this.playerPositions[player.playerId] = { x: 50, y: 50 };
        }
        continue;
      }
      if (player.onLineup && !player.isStarter) {
        if (this.zones.bench.length < maxBench) {
          this.zones.bench.push(player.playerId);
        } else {
          this.zones.unavailable.push(player.playerId);
        }
        continue;
      }
      this.zones.unavailable.push(player.playerId);
    }
  }

  // Sort roster by the active sort field
  sortRoster() {
    const statusRank = { 'priority_starter': 0, 'eligible_starter': 1, 'bench_only': 2, 'ineligible': 3, 'not_computed': 4, 'not_on_roster': 5 };
    const rsvpRank = { 'yes': 0, 'maybe': 1, 'no': 2 };
    const dir = this.sortAsc ? 1 : -1;

    this.zones.unavailable.sort((idA, idB) => {
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
    this.zones = { starting: [], bench: [], unavailable: [] };
    this.playerPositions = {};

    const hasGameRoster = this.gameDayRosterIds && this.gameDayRosterIds.size > 0;

    const sorted = [...this.players].sort((a, b) => {
      const statusOrder = { 'priority_starter': 0, 'eligible_starter': 1, 'bench_only': 2, 'ineligible': 3 };
      const orderA = statusOrder[a.eligibilityStatus] ?? 4;
      const orderB = statusOrder[b.eligibilityStatus] ?? 4;
      if (orderA !== orderB) return orderA - orderB;
      return b.sessionsAttended - a.sessionsAttended;
    });

    const positions = this.getFormationPositions();
    const maxBench = this.rosterSize - 11;
    let starterCount = 0;
    let benchCount = 0;

    for (const player of sorted) {
      // If game day roster is set, non-roster players go straight to unavailable
      if (hasGameRoster && !this.gameDayRosterIds.has(player.playerId)) {
        this.zones.unavailable.push(player.playerId);
        continue;
      }

      if (player.matchRsvp === 'no') {
        this.zones.unavailable.push(player.playerId);
      } else if (starterCount < 11 && player.eligibilityStatus !== 'ineligible') {
        this.zones.starting.push(player.playerId);
        if (starterCount < positions.length) {
          this.playerPositions[player.playerId] = { x: positions[starterCount].x, y: positions[starterCount].y };
        } else {
          this.playerPositions[player.playerId] = { x: 50, y: 50 };
        }
        starterCount++;
      } else if (benchCount < maxBench) {
        this.zones.bench.push(player.playerId);
        benchCount++;
      } else {
        this.zones.unavailable.push(player.playerId);
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
    this.renderBenchPlayers();
    this.renderUnavailablePlayers();
    if (this.activeOverlay) this.renderOverlayTable();
    this.updateCounts();
  }

  renderPlayerTable() {
    // Replaced by overlay system — called by renderOverlayTable
    if (this.activeOverlay) this.renderOverlayTable();
  }

  // ============================================================================
  // Overlay Management
  // ============================================================================
  renderOverlayToggles() {
    const select = this.find('#overlay-select');
    if (!select) return;

    let html = '<option value="">⚽ Show Pitch</option>';
    html += '<option value="match"' + (this.activeOverlay === 'match' ? ' selected' : '') + '>📋 Match Roster</option>';

    // Team-linked chats
    for (const t of (this.clubTeams || [])) {
      const label = t.divisionName || t.teamName || `Team ${t.teamId}`;
      const key = String(t.teamId);
      html += `<option value="${key}"${this.activeOverlay === key ? ' selected' : ''}>${label}</option>`;
    }

    // All chats (GroupMe views)
    for (const c of (this.allChats || [])) {
      const key = 'chat-' + c.chatId;
      const label = c.teamId ? `💬 ${c.chatName}` : c.chatName;
      html += `<option value="${key}"${this.activeOverlay === key ? ' selected' : ''}>${label}</option>`;
    }

    select.innerHTML = html;
  }

  toggleOverlay(key) {
    if (this.activeOverlay === key) {
      this.activeOverlay = null;
      this.find('#roster-overlay-panel').style.display = 'none';
      const sel = this.find('#overlay-select');
      if (sel) sel.value = '';
    } else {
      this.activeOverlay = key;
      this.find('#roster-overlay-panel').style.display = 'flex';
      this.renderOverlayTable();
    }
  }

  getOverlayPlayers() {
    if (this.activeOverlay === 'match') {
      return this.players.map(p => ({
        ...p,
        zone: this.findPlayerZone(p.playerId) || 'unavailable'
      }));
    }

    // For chat-X views, filter by chat membership
    // For team-specific views (numeric key), filter by team roster
    const isChatView = this.activeOverlay?.startsWith('chat-');
    const chatId = isChatView ? parseInt(this.activeOverlay.replace('chat-', '')) : null;
    const teamId = isChatView ? null : parseInt(this.activeOverlay);

    const players = [];
    const seenPersons = new Set();

    for (const gm of (this.groupmeMembers || [])) {
      if (isChatView) {
        // Filter to members of this specific chat
        if (!(gm.chatIds || []).includes(chatId)) continue;
      } else {
        const onTeam = (gm.teams || []).some(t => t.teamId === teamId);
        if (!onTeam) continue;
      }
      if (gm.personId && seenPersons.has(gm.personId)) continue;
      if (gm.personId) seenPersons.add(gm.personId);

      // Try to find this person in the main players array for eligibility data
      const ep = gm.personId ? this.players.find(p => p.personId === gm.personId) : null;

      players.push({
        playerId: ep?.playerId || (gm.teams || []).find(t => t.teamId === teamId)?.playerId || null,
        personId: gm.personId,
        firstName: gm.firstName || '',
        lastName: gm.lastName || '',
        jerseyNumber: ep?.jerseyNumber || null,
        matchRsvp: gm.matchRsvp || ep?.matchRsvp || null,
        sessionsAttended: ep?.sessionsAttended || 0,
        sessionsInWindow: ep?.sessionsInWindow || this.policy?.lookbackCount || 0,
        projectedSessions: ep?.projectedSessions || 0,
        eligibilityStatus: ep?.eligibilityStatus || 'not_computed',
        gmLinked: gm.linked,
        gmNickname: gm.nickname,
        onOfficialRoster: ep?.onOfficialRoster || false,
        source: gm.source,
        zone: ep ? (this.findPlayerZone(ep.playerId) || 'unavailable') : 'unavailable'
      });
    }

    return players;
  }

  renderOverlayTable() {
    if (!this.activeOverlay) return;

    const tbody = this.find('#roster-table-body');
    if (!tbody) return;
    tbody.innerHTML = '';

    let players = this.getOverlayPlayers();

    // Sort
    const statusRank = { 'priority_starter': 0, 'eligible_starter': 1, 'bench_only': 2, 'ineligible': 3, 'not_computed': 4, 'not_on_roster': 5 };
    const rsvpRank = { 'yes': 0, 'maybe': 1, 'no': 2 };
    const zoneRank = { 'starting': 0, 'bench': 1, 'unavailable': 2 };
    const dir = this.sortAsc ? 1 : -1;

    players.sort((a, b) => {
      let cmp = 0;
      switch (this.sortField) {
        case 'lastName':
          cmp = ((a.lastName || '') + (a.firstName || '')).localeCompare((b.lastName || '') + (b.firstName || ''));
          break;
        case 'zone':
          cmp = (zoneRank[a.zone] ?? 3) - (zoneRank[b.zone] ?? 3);
          if (cmp === 0) cmp = (b.sessionsAttended || 0) - (a.sessionsAttended || 0);
          break;
        case 'rsvp':
          cmp = (rsvpRank[a.matchRsvp] ?? 3) - (rsvpRank[b.matchRsvp] ?? 3);
          if (cmp === 0) cmp = (b.sessionsAttended || 0) - (a.sessionsAttended || 0);
          break;
        case 'eligibility':
          cmp = (statusRank[a.eligibilityStatus] ?? 6) - (statusRank[b.eligibilityStatus] ?? 6);
          if (cmp === 0) cmp = (b.sessionsAttended || 0) - (a.sessionsAttended || 0);
          break;
        case 'practices':
          cmp = (b.sessionsAttended || 0) - (a.sessionsAttended || 0);
          break;
        case 'projected':
          cmp = (b.projectedSessions || 0) - (a.projectedSessions || 0);
          break;
      }
      return cmp * dir;
    });

    for (const player of players) {
      if (!player.playerId) continue;
      const row = this.createPlayerRow(player, player.zone);
      tbody.appendChild(row);
    }

    // Unmatched at the end (only for match overlay)
    if (this.activeOverlay === 'match') {
      for (const u of this.unmatchedRsvps) {
        const row = this.createUnmatchedRow(u);
        tbody.appendChild(row);
      }
    }

    // Update sort indicators in headers
    const table = this.find('#roster-table');
    if (table) {
      table.querySelectorAll('.sortable-col').forEach(th => {
        const base = th.textContent.replace(/ [↕↑↓]$/, '');
        th.textContent = base + (th.dataset.sort === this.sortField ? (this.sortAsc ? ' ↑' : ' ↓') : ' ↕');
      });
    }
  }

  updateCounts() {
    const starterCount = this.zones.starting.length;
    const benchCount = this.zones.bench.length;
    const maxBench = this.rosterSize - 11;
    const rosterCount = starterCount + benchCount;

    const sc = this.find('#starting-count');
    if (sc) sc.textContent = `${starterCount}/11`;

    const bc = this.find('#bench-count-display');
    if (bc) bc.textContent = `${benchCount}/${maxBench}`;

    const rc = this.find('#roster-count-display');
    if (rc) rc.textContent = `${rosterCount}/${this.rosterSize}`;

    // Update overlay zone counts
    const ozc = this.find('#overlay-zone-counts');
    if (ozc) {
      ozc.innerHTML = `
        <span class="ozc-item ozc-roster">📋 ${rosterCount}/${this.rosterSize}</span>
        <span class="ozc-item ozc-starting">⚽ ${starterCount}/11</span>
        <span class="ozc-item ozc-bench">🪑 ${benchCount}/${maxBench}</span>
      `;
    }
  }

  renderPitchPlayers() {
    const container = this.find('#pitch-players');
    if (!container) return;
    container.innerHTML = '';

    const landscape = this.isLandscape();

    // Show opponent formation ghost positions as guides (mirrored to opponent half)
    if (this.opponentFormation) {
      const oppPositions = this.getPositionsForFormation(this.opponentFormation);
      oppPositions.forEach((pos) => {
        const ghost = document.createElement('div');
        ghost.className = 'pitch-ghost-pos';
        // Mirror: opponent's GK is at y=100, their strikers near y=50 (midfield)
        const mirroredY = 100 - pos.y;
        const css = this.toCSS(pos.x, mirroredY);
        ghost.style.left = `${css.left}%`;
        ghost.style.top = `${css.top}%`;
        ghost.textContent = pos.label || '';
        container.appendChild(ghost);
      });
    }

    // Render each starter at their free-form position
    for (const playerId of this.zones.starting) {
      const player = this.getPlayerById(playerId);
      if (!player) continue;

      const pos = this.playerPositions[playerId] || { x: 50, y: 50 };
      const chip = this.createPitchPlayerChip(player, pos);
      container.appendChild(chip);
    }

    // Update detected formation label
    this.updateDetectedFormation();
  }

  renderBenchPlayers() {
    const container = this.find('#bench-players');
    if (!container) return;
    container.innerHTML = '';

    const maxBench = this.rosterSize - 11;

    // Render bench seat slots
    for (let i = 0; i < maxBench; i++) {
      const seat = document.createElement('div');
      seat.className = 'bench-seat';
      seat.setAttribute('data-bench-slot', i);

      const playerId = this.zones.bench[i];
      const player = playerId ? this.getPlayerById(playerId) : null;

      if (player) {
        seat.classList.add('bench-seat-filled');
        const chip = this.createZoneChip(player, 'bench');
        seat.appendChild(chip);
      } else {
        seat.innerHTML = '<div class="bench-seat-empty">&nbsp;</div>';
      }

      container.appendChild(seat);
    }
  }

  renderUnavailablePlayers() {
    // Delegated to renderPlayerPool — pool is always shown below the pitch
    this.renderPlayerPool();
  }

  renderPlayerPool() {
    const groups = { yes: [], maybe: [], no: [] };

    for (const playerId of this.players.map(p => p.playerId)) {
      const player = this.getPlayerById(playerId);
      if (!player) continue;
      const rsvp = player.matchRsvp;
      if (rsvp === 'yes') groups.yes.push(player);
      else if (rsvp === 'no') groups.no.push(player);
      else groups.maybe.push(player);
    }

    // Sort each group by sessions attended desc
    const byPrac = (a, b) => (b.sessionsAttended || 0) - (a.sessionsAttended || 0);
    groups.yes.sort(byPrac);
    groups.maybe.sort(byPrac);
    groups.no.sort(byPrac);

    const renderGroup = (groupId, countId, players) => {
      const container = this.find(`#pool-rows-${groupId}`);
      const countEl = this.find(`#pool-count-${groupId}`);
      if (!container) return;
      container.innerHTML = '';
      if (countEl) countEl.textContent = `(${players.length})`;
      for (const player of players) {
        container.appendChild(this.createPoolRow(player));
      }
    };

    renderGroup('yes', 'yes', groups.yes);
    renderGroup('maybe', 'maybe', groups.maybe);
    renderGroup('no', 'no', groups.no);

    // Unlinked GroupMe RSVPs — sorted yes → maybe → no
    const unlinkedContainer = this.find('#pool-rows-unlinked');
    const unlinkedGroup = this.find('#pool-group-unlinked');
    if (unlinkedContainer && this.unmatchedRsvps?.length) {
      const rsvpOrder = { yes: 0, maybe: 1, no: 2 };
      const sorted = [...this.unmatchedRsvps].sort((a, b) =>
        (rsvpOrder[a.matchRsvp] ?? 1) - (rsvpOrder[b.matchRsvp] ?? 1)
      );
      unlinkedContainer.innerHTML = '';
      for (const u of sorted) {
        unlinkedContainer.appendChild(this.createUnmatchedPoolRow(u));
      }
      if (unlinkedGroup) unlinkedGroup.style.display = '';
    } else if (unlinkedGroup) {
      unlinkedGroup.style.display = 'none';
    }
  }

  createPoolRow(player) {
    const row = document.createElement('div');
    const eligClass = this.getEligibilityClass(player);
    const zone = this.findPlayerZone(player.playerId) || 'unavailable';
    row.className = `pool-row ${eligClass} pool-zone-${zone}`;
    row.setAttribute('draggable', 'true');
    row.setAttribute('data-player-id', player.playerId);
    row.setAttribute('data-zone', zone);

    const jersey = player.jerseyNumber ? `#${player.jerseyNumber}` : '—';
    const name = `${player.firstName || ''} ${player.lastName || ''}`.trim();
    const prac = player.sessionsAttended || 0;
    const eligIcon = this.getStatusIcon(player.eligibilityStatus);
    const zoneLabel = zone === 'starting' ? '⚽' : zone === 'bench' ? '🪑' : '';
    const rsvp = player.matchRsvp || null;

    row.innerHTML = `
      <span class="pool-jersey">${jersey}</span>
      <span class="pool-name">${name}</span>
      <span class="pool-elig" title="${player.eligibilityStatus || ''}">${eligIcon}</span>
      <span class="pool-prac">${prac}${this.policy?.lookbackCount ? '/' + this.policy.lookbackCount : ''}</span>
      <span class="pool-zone-badge">${zoneLabel}</span>
      <span class="pool-rsvp-btns">
        <button class="rsvp-btn rsvp-btn-yes${rsvp === 'yes' ? ' active' : ''}" data-player-id="${player.playerId}" data-rsvp="yes" title="Going">✓</button>
        <button class="rsvp-btn rsvp-btn-maybe${(!rsvp || rsvp === 'maybe') && rsvp !== 'yes' && rsvp !== 'no' ? ' active' : ''}" data-player-id="${player.playerId}" data-rsvp="maybe" title="Maybe">?</button>
        <button class="rsvp-btn rsvp-btn-no${rsvp === 'no' ? ' active' : ''}" data-player-id="${player.playerId}" data-rsvp="no" title="Not Going">✗</button>
      </span>
      <button class="pool-add-bench-btn btn btn-sm" data-player-id="${player.playerId}" title="Add to bench">+🪑</button>
    `;
    return row;
  }

  createUnmatchedPoolRow(user) {
    const row = document.createElement('div');
    row.className = 'pool-row pool-unlinked';
    const rsvp = user.matchRsvp === 'yes' ? '✓' : user.matchRsvp === 'no' ? '✗' : '?';
    const rsvpClass = user.matchRsvp === 'yes' ? 'rsvp-yes' : user.matchRsvp === 'no' ? 'rsvp-no' : 'rsvp-unknown';
    row.innerHTML = `
      <span class="pool-jersey">—</span>
      <span class="pool-name">${user.externalUsername || 'Unknown'}</span>
      <span class="pool-elig"></span>
      <span class="pool-prac"></span>
      <span class="pool-zone-badge"></span>
      <span class="pool-rsvp-btns"><span class="pool-rsvp ${rsvpClass}">${rsvp}</span></span>
      <button class="rt-btn btn-link-player"
        data-gm-user-id="${user.externalUserId || ''}"
        data-gm-nickname="${(user.externalUsername || '').replace(/"/g, '&quot;')}"
        data-gm-image="${(user.gmImageUrl || '').replace(/"/g, '&quot;')}"
        title="Link to player">🔗 Link</button>
    `;
    return row;
  }

  async updatePlayerRsvp(playerId, rsvpStatus) {
    const matchId = this.navigation.context.match?.id;
    if (!matchId || !playerId) return;
    try {
      const res = await this.auth.fetch(`/api/matches/${matchId}/player-rsvp`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ player_id: String(playerId), rsvp_status: rsvpStatus })
      });
      const data = await res.json();
      if (!data.success) throw new Error(data.message);

      // Update local player state
      const player = this.getPlayerById(parseInt(playerId));
      if (player) player.matchRsvp = rsvpStatus;

      // Re-render pool (and re-classify if auto-fill was applied)
      this.renderPlayerPool();
    } catch (err) {
      console.error('RSVP update failed:', err);
      this.showLineupToast('Failed to update RSVP');
    }
  }

  createZoneChip(player, zone) {
    const chip = document.createElement('div');
    chip.className = `zone-chip ${this.getEligibilityClass(player)}`;
    chip.setAttribute('draggable', 'true');
    chip.setAttribute('data-player-id', player.playerId);
    chip.setAttribute('data-zone', zone);

    const initial = player.firstName ? player.firstName[0] : '?';
    const jerseyDisplay = player.jerseyNumber ? `#${player.jerseyNumber}` : '';
    const rsvpDot = player.matchRsvp === 'no' ? ' rsvp-no' : player.matchRsvp === 'yes' ? ' rsvp-yes' : '';

    chip.innerHTML = `
      <div class="chip-circle">${jerseyDisplay || initial}</div>
      <div class="chip-name">${player.firstName} ${player.lastName || ''}</div>
    `;
    if (zone === 'unavailable') chip.classList.add('chip-dimmed');

    return chip;
  }

  getPositionsForFormation(code) {
    const formations = {
      '4-3-3': [
        { x: 50, y: 5, label: 'GK' },
        { x: 85, y: 22, label: 'RB' }, { x: 60, y: 18, label: 'CB' },
        { x: 40, y: 18, label: 'CB' }, { x: 15, y: 22, label: 'LB' },
        { x: 65, y: 42, label: 'CM' }, { x: 50, y: 38, label: 'CM' }, { x: 35, y: 42, label: 'CM' },
        { x: 80, y: 65, label: 'RW' }, { x: 50, y: 70, label: 'ST' }, { x: 20, y: 65, label: 'LW' }
      ],
      '4-4-2': [
        { x: 50, y: 5, label: 'GK' },
        { x: 85, y: 22, label: 'RB' }, { x: 60, y: 18, label: 'CB' },
        { x: 40, y: 18, label: 'CB' }, { x: 15, y: 22, label: 'LB' },
        { x: 80, y: 45, label: 'RM' }, { x: 60, y: 40, label: 'CM' },
        { x: 40, y: 40, label: 'CM' }, { x: 20, y: 45, label: 'LM' },
        { x: 62, y: 68, label: 'ST' }, { x: 38, y: 68, label: 'ST' }
      ],
      '3-5-2': [
        { x: 50, y: 5, label: 'GK' },
        { x: 70, y: 18, label: 'CB' }, { x: 50, y: 15, label: 'CB' }, { x: 30, y: 18, label: 'CB' },
        { x: 88, y: 40, label: 'RWB' }, { x: 65, y: 38, label: 'CM' }, { x: 50, y: 35, label: 'CM' },
        { x: 35, y: 38, label: 'CM' }, { x: 12, y: 40, label: 'LWB' },
        { x: 62, y: 68, label: 'ST' }, { x: 38, y: 68, label: 'ST' }
      ],
      '4-2-3-1': [
        { x: 50, y: 5, label: 'GK' },
        { x: 85, y: 22, label: 'RB' }, { x: 60, y: 18, label: 'CB' },
        { x: 40, y: 18, label: 'CB' }, { x: 15, y: 22, label: 'LB' },
        { x: 62, y: 35, label: 'CDM' }, { x: 38, y: 35, label: 'CDM' },
        { x: 78, y: 55, label: 'RAM' }, { x: 50, y: 52, label: 'CAM' }, { x: 22, y: 55, label: 'LAM' },
        { x: 50, y: 72, label: 'ST' }
      ],
      '3-4-3': [
        { x: 50, y: 5, label: 'GK' },
        { x: 70, y: 18, label: 'CB' }, { x: 50, y: 15, label: 'CB' }, { x: 30, y: 18, label: 'CB' },
        { x: 80, y: 40, label: 'RM' }, { x: 60, y: 38, label: 'CM' },
        { x: 40, y: 38, label: 'CM' }, { x: 20, y: 40, label: 'LM' },
        { x: 78, y: 65, label: 'RW' }, { x: 50, y: 70, label: 'ST' }, { x: 22, y: 65, label: 'LW' }
      ],
      '5-3-2': [
        { x: 50, y: 5, label: 'GK' },
        { x: 88, y: 22, label: 'RWB' }, { x: 68, y: 16, label: 'CB' }, { x: 50, y: 14, label: 'CB' },
        { x: 32, y: 16, label: 'CB' }, { x: 12, y: 22, label: 'LWB' },
        { x: 65, y: 42, label: 'CM' }, { x: 50, y: 38, label: 'CM' }, { x: 35, y: 42, label: 'CM' },
        { x: 62, y: 68, label: 'ST' }, { x: 38, y: 68, label: 'ST' }
      ],
      '5-4-1': [
        { x: 50, y: 5, label: 'GK' },
        { x: 88, y: 22, label: 'RWB' }, { x: 68, y: 16, label: 'CB' }, { x: 50, y: 14, label: 'CB' },
        { x: 32, y: 16, label: 'CB' }, { x: 12, y: 22, label: 'LWB' },
        { x: 80, y: 45, label: 'RM' }, { x: 60, y: 40, label: 'CM' },
        { x: 40, y: 40, label: 'CM' }, { x: 20, y: 45, label: 'LM' },
        { x: 50, y: 70, label: 'ST' }
      ],
      '4-1-4-1': [
        { x: 50, y: 5, label: 'GK' },
        { x: 85, y: 22, label: 'RB' }, { x: 60, y: 18, label: 'CB' },
        { x: 40, y: 18, label: 'CB' }, { x: 15, y: 22, label: 'LB' },
        { x: 50, y: 35, label: 'CDM' },
        { x: 80, y: 52, label: 'RM' }, { x: 60, y: 48, label: 'CM' },
        { x: 40, y: 48, label: 'CM' }, { x: 20, y: 52, label: 'LM' },
        { x: 50, y: 70, label: 'ST' }
      ],
      '4-5-1': [
        { x: 50, y: 5, label: 'GK' },
        { x: 85, y: 22, label: 'RB' }, { x: 60, y: 18, label: 'CB' },
        { x: 40, y: 18, label: 'CB' }, { x: 15, y: 22, label: 'LB' },
        { x: 80, y: 42, label: 'RM' }, { x: 65, y: 38, label: 'CM' }, { x: 50, y: 35, label: 'CM' },
        { x: 35, y: 38, label: 'CM' }, { x: 20, y: 42, label: 'LM' },
        { x: 50, y: 70, label: 'ST' }
      ]
    };
    return formations[code] || formations['4-3-3'];
  }

  getFormationPositions() {
    const code = this.selectedFormation?.code || '4-3-3';
    return this.getPositionsForFormation(code);
  }

  // Orientation helpers: canonical coords (x=across, y=goal-to-goal) ↔ CSS coords
  isLandscape() {
    return window.innerWidth >= 768;
  }

  toggleFitToScreen() {
    const screen = this.element;
    const btn = this.find('#fit-screen-btn');
    if (!screen) return;
    screen.classList.toggle('lineup-fit-screen');
    const isFit = screen.classList.contains('lineup-fit-screen');
    if (btn) btn.textContent = isFit ? '↩️ Exit' : '🖥️ Fit';
    // Prevent body scroll in fit mode
    document.body.style.overflow = isFit ? 'hidden' : '';
  }

  // Canonical → CSS for rendering
  toCSS(fx, fy) {
    if (this.isLandscape()) {
      return { left: fy, top: fx };  // goals on left/right
    }
    return { left: fx, top: fy };    // goals on top/bottom
  }

  // CSS (mouse drop) → canonical for storage
  fromCSS(cssX, cssY) {
    if (this.isLandscape()) {
      return { x: cssY, y: cssX };   // reverse the swap
    }
    return { x: cssX, y: cssY };
  }

  createPitchPlayerChip(player, pos) {
    const chip = document.createElement('div');
    chip.className = `pitch-player-chip ${this.getEligibilityClass(player)}`;
    chip.setAttribute('draggable', 'true');
    chip.setAttribute('data-player-id', player.playerId);
    chip.setAttribute('data-zone', 'starting');
    chip.style.position = 'absolute';
    const css = this.toCSS(pos.x, pos.y);
    chip.style.left = `${css.left}%`;
    chip.style.top = `${css.top}%`;
    chip.style.transform = 'translate(-50%, -50%)';

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
    const zoneBadges = { starting: '⚽', bench: '🪑', unavailable: '⛔' };
    const zoneBadge = zoneBadges[zone] || '—';
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

    // Practices — count from training data
    const sessions = player.sessionsAttended ?? player.practiceCount ?? 0;

    // Build per-day training cells
    let trainingCells = '';
    const playerTraining = player.personId ? this.trainingData.get(player.personId) || {} : {};
    for (const evt of this.trainingEvents) {
      const att = playerTraining[evt.id];
      if (!player.personId) {
        trainingCells += '<td class="ot-col-train">—</td>';
      } else if (att && att.attended) {
        const cls = att.source === 'rsvp' ? 'train-rsvp' : 'train-yes';
        trainingCells += `<td class="ot-col-train ${cls}"><input type="checkbox" class="train-cb" data-person-id="${player.personId}" data-event-id="${evt.id}" checked></td>`;
      } else {
        trainingCells += `<td class="ot-col-train"><input type="checkbox" class="train-cb" data-person-id="${player.personId}" data-event-id="${evt.id}"></td>`;
      }
    }

    // Action buttons: Stage 1 = add/remove from game day roster
    // Players on roster (starting/bench) can be removed; unavailable can be added
    let actions = '';
    if (zone === 'unavailable') {
      actions = `<button class="rt-btn rt-btn-roster-add" data-action="to-bench" title="Add to Game Day Roster">✅ Add</button>`;
    } else {
      // starting or bench — can remove from roster
      actions = `<button class="rt-btn rt-btn-remove" data-action="to-unavailable" title="Remove from Roster">✕ Remove</button>`;
    }

    row.innerHTML = `
      <td class="ot-col-name"><span class="rt-name">${name}</span> <span class="rt-jersey">${jersey}</span> ${sourceTag}</td>
      <td class="ot-col-zone"><span class="rt-zone-badge ${zoneClass}">${zoneBadge}</span></td>
      <td class="ot-col-rsvp"><span class="rsvp-dot ${rsvpClass}">${rsvpShort}</span></td>
      <td class="ot-col-elig">${statusIcon}</td>
      ${trainingCells}
      <td class="ot-col-prac">${sessions}</td>
      <td class="ot-col-actions">${actions}</td>
    `;

    // Action button clicks
    row.querySelectorAll('.rt-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const action = btn.dataset.action;
        if (action === 'to-bench') {
          this.movePlayer(player.playerId, zone, 'bench');
        } else if (action === 'to-unavailable') {
          this.movePlayer(player.playerId, zone, 'unavailable');
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
      <td class="ot-col-name">
        <span class="rt-name">${user.externalUsername || '?'}</span>
        <span class="rt-tag rt-tag-unlinked">unlinked</span>
      </td>
      <td class="ot-col-zone"><span class="rt-zone-badge rt-zone-roster">—</span></td>
      <td class="ot-col-rsvp"><span class="rsvp-dot ${rsvpClass}">${rsvpShort}</span></td>
      <td class="ot-col-elig">❓</td>
      <td class="ot-col-prac">—</td>
      <td class="ot-col-proj">—</td>
      <td class="ot-col-actions">
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
    const panel = this.find('.roster-overlay-panel');
    if (panel) panel.classList.add('roster-selecting');
  }

  cancelSlotSelection() {
    this.selectingSlot = null;
    const banner = this.find('#select-mode-banner');
    if (banner) banner.style.display = 'none';
    
    const panel = this.find('.roster-overlay-panel');
    if (panel) panel.classList.remove('roster-selecting');
  }

  assignPlayerToSlot(playerId, slotIndex) {
    // Check max 11
    if (this.zones.starting.length >= 11) {
      this.showLineupToast('Starting XI is full (11/11). Remove a player first.');
      return;
    }
    // Remove from current zone
    this.removePlayerFromAllZones(playerId);
    // Add to starting with formation position
    const positions = this.getFormationPositions();
    const pos = positions[this.zones.starting.length] || { x: 50, y: 50 };
    this.playerPositions[playerId] = { x: pos.x, y: pos.y };
    this.zones.starting.push(playerId);
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
  // Formation Detection
  // ============================================================================
  detectFormation() {
    const starters = this.zones.starting;
    if (starters.length < 2) return '—';

    // Get Y positions (goal-to-goal) sorted ascending (own goal → opponent goal)
    const yPositions = starters.map(pid => {
      const pos = this.playerPositions[pid];
      return pos ? pos.y : 50;
    }).sort((a, b) => a - b);

    // Skip the GK (lowest Y = closest to own goal)
    const outfield = yPositions.slice(1);
    if (outfield.length === 0) return '—';

    // Cluster into lines by Y-gap (threshold: 12 units on 0-100 scale)
    const lines = [[outfield[0]]];
    for (let i = 1; i < outfield.length; i++) {
      const lastLine = lines[lines.length - 1];
      const avgY = lastLine.reduce((s, v) => s + v, 0) / lastLine.length;
      if (Math.abs(outfield[i] - avgY) <= 12) {
        lastLine.push(outfield[i]);
      } else {
        lines.push([outfield[i]]);
      }
    }

    return lines.map(l => l.length).join('-');
  }

  updateDetectedFormation() {
    const label = this.find('#detected-formation');
    if (label) label.textContent = this.detectFormation();
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
    const pitch = e.target.closest('.pitch');
    const table = e.target.closest('.roster-overlay-panel');
    if (!zone && !pitch && !table) return;

    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';

    // Visual feedback
    document.querySelectorAll('.lineup-zone').forEach(z => z.classList.remove('drag-over'));
    if (zone) zone.classList.add('drag-over');
  }

  onDrop(e) {
    e.preventDefault();
    document.querySelectorAll('.lineup-zone').forEach(z => z.classList.remove('drag-over'));
    if (!this.dragState) return;

    // Dropped on the pitch — free-form position
    const pitch = e.target.closest('.pitch');
    if (pitch) {
      const rect = pitch.getBoundingClientRect();
      const cssX = Math.max(3, Math.min(97, ((e.clientX - rect.left) / rect.width) * 100));
      const cssY = Math.max(3, Math.min(97, ((e.clientY - rect.top) / rect.height) * 100));
      const canonical = this.fromCSS(cssX, cssY);
      this.movePlayerToPitch(this.dragState.playerId, this.dragState.sourceZone, canonical.x, canonical.y);
      this.dragState = null;
      return;
    }

    // Dropped on a zone section
    const zone = e.target.closest('.lineup-zone');
    if (zone) {
      const targetZone = this.getZoneKey(zone.id);
      if (targetZone && targetZone !== 'starting') {
        this.movePlayer(this.dragState.playerId, this.dragState.sourceZone, targetZone);
      }
      this.dragState = null;
      return;
    }

    // Dropped on the overlay table — move to unavailable
    const table = e.target.closest('.roster-overlay-panel');
    if (table) {
      this.movePlayer(this.dragState.playerId, this.dragState.sourceZone, 'unavailable');
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
    const pitch = elementBelow?.closest('.pitch');
    const zone = elementBelow?.closest('.lineup-zone');

    if (pitch) {
      const rect = pitch.getBoundingClientRect();
      const cssX = Math.max(3, Math.min(97, ((touch.clientX - rect.left) / rect.width) * 100));
      const cssY = Math.max(3, Math.min(97, ((touch.clientY - rect.top) / rect.height) * 100));
      const canonical = this.fromCSS(cssX, cssY);
      this.movePlayerToPitch(this.dragState.playerId, this.dragState.sourceZone, canonical.x, canonical.y);
    } else if (zone) {
      const targetZone = this.getZoneKey(zone.id);
      if (targetZone === 'starting') {
        this.movePlayerToPitch(this.dragState.playerId, this.dragState.sourceZone);
      } else if (targetZone) {
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
      'zone-unavailable': 'unavailable',
      'roster-panel': 'unavailable'
    };
    return map[zoneElementId] || null;
  }

  findPlayerZone(playerId) {
    for (const [zone, ids] of Object.entries(this.zones)) {
      if (ids.includes(playerId)) return zone;
    }
    return null;
  }

  removePlayerFromAllZones(playerId) {
    for (const zone of Object.keys(this.zones)) {
      this.zones[zone] = this.zones[zone].filter(id => id !== playerId);
    }
    delete this.playerPositions[playerId];
  }

  showLineupToast(message) {
    const toast = this.find('#lineup-toast');
    if (!toast) return;
    toast.textContent = message;
    toast.style.display = 'block';
    setTimeout(() => { toast.style.display = 'none'; }, 3000);
  }

  // Move a player onto the pitch at a specific x,y (or default formation position)
  movePlayerToPitch(playerId, fromZone, x, y) {
    // If already on pitch, just update position
    if (fromZone === 'starting' && this.zones.starting.includes(playerId)) {
      if (x !== undefined && y !== undefined) {
        this.playerPositions[playerId] = { x, y };
        this.renderAllZones();
      }
      return;
    }

    // Check max 11
    if (this.zones.starting.length >= 11) {
      this.showLineupToast('Starting XI is full (11/11). Remove a player first.');
      return;
    }

    // Remove from current zone
    this.removePlayerFromAllZones(playerId);

    // Assign position
    if (x !== undefined && y !== undefined) {
      this.playerPositions[playerId] = { x, y };
    } else {
      // Use next formation position
      const positions = this.getFormationPositions();
      const posIdx = this.zones.starting.length;
      const pos = posIdx < positions.length ? positions[posIdx] : { x: 50, y: 50 };
      this.playerPositions[playerId] = { x: pos.x, y: pos.y };
    }

    this.zones.starting.push(playerId);
    this.renderAllZones();
  }

  movePlayer(playerId, fromZone, toZone) {
    if (fromZone === toZone) return;

    const maxBench = this.rosterSize - 11;

    // Enforce limits
    if (toZone === 'starting' && this.zones.starting.length >= 11 && fromZone !== 'starting') {
      this.showLineupToast('Starting XI is full (11/11). Remove a player first.');
      return;
    }
    if (toZone === 'bench' && this.zones.bench.length >= maxBench) {
      this.showLineupToast(`Bench is full (${maxBench}/${maxBench}).`);
      return;
    }

    // Remove from source
    this.removePlayerFromAllZones(playerId);

    // Add to target
    if (toZone === 'starting') {
      this.movePlayerToPitch(playerId, null);
      return;
    }
    this.zones[toZone].push(playerId);
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
  // Roster Reference Popup: View official rosters for all club sibling teams
  // ============================================================================
  openRosterPopup() {
    const teams = this.clubTeams || [];
    if (teams.length === 0) {
      alert('No team rosters available');
      return;
    }

    // Group members by team
    const rostersByTeam = new Map(); // teamId → [{firstName, lastName, linked, gmNickname, ...}]
    for (const t of teams) {
      rostersByTeam.set(t.teamId, { name: t.teamName, division: t.divisionName, players: [] });
    }

    // Collect all persons on rosters from groupmeMembers
    const seenByTeam = new Map(); // "teamId-personId" → true
    for (const gm of this.groupmeMembers) {
      for (const t of (gm.teams || [])) {
        const key = `${t.teamId}-${gm.personId || gm.externalUserId}`;
        if (seenByTeam.has(key)) continue;
        seenByTeam.set(key, true);

        const team = rostersByTeam.get(t.teamId);
        if (!team) continue;

        team.players.push({
          firstName: gm.firstName || '',
          lastName: gm.lastName || '',
          nickname: gm.nickname || '',
          linked: gm.linked,
          source: gm.source,
          matchRsvp: gm.matchRsvp
        });
      }
    }

    // Sort players within each team
    for (const [, team] of rostersByTeam) {
      team.players.sort((a, b) => ((a.lastName || '') + (a.firstName || '')).localeCompare((b.lastName || '') + (b.firstName || '')));
    }

    // Build popup HTML
    const overlay = document.createElement('div');
    overlay.className = 'attendance-overlay';

    let tabsHtml = '';
    let panelsHtml = '';
    let first = true;
    for (const [teamId, team] of rostersByTeam) {
      if (team.players.length === 0) continue;
      const label = team.division || team.name;
      tabsHtml += `<button class="roster-popup-tab ${first ? 'active' : ''}" data-team-id="${teamId}">${label} (${team.players.length})</button>`;

      panelsHtml += `<div class="roster-popup-panel ${first ? '' : 'hidden'}" data-team-id="${teamId}">
        <table class="roster-popup-table">
          <thead><tr><th>Player</th><th>GM</th><th>RSVP</th></tr></thead>
          <tbody>
            ${team.players.map(p => {
              const name = `${p.firstName} ${p.lastName}`.trim();
              const gmBadge = p.linked ? `<span class="rt-tag rt-tag-gm" title="${p.nickname}">✓</span>` : '<span class="rt-tag rt-tag-none">—</span>';
              const rsvpDot = this.getRsvpShort(p.matchRsvp);
              const rsvpClass = this.getRsvpClass(p.matchRsvp);
              return `<tr><td>${name}</td><td>${gmBadge}</td><td><span class="rsvp-dot ${rsvpClass}">${rsvpDot}</span></td></tr>`;
            }).join('')}
          </tbody>
        </table>
      </div>`;
      first = false;
    }

    overlay.innerHTML = `
      <div class="link-popup roster-popup">
        <div class="link-popup-header">
          <h3>📋 Official Rosters</h3>
          <button class="attendance-close-btn">✕</button>
        </div>
        <div class="roster-popup-tabs">${tabsHtml}</div>
        <div class="roster-popup-panels">${panelsHtml}</div>
      </div>
    `;

    document.body.appendChild(overlay);

    // Close handlers
    overlay.querySelector('.attendance-close-btn').addEventListener('click', () => overlay.remove());
    overlay.addEventListener('click', (e) => { if (e.target === overlay) overlay.remove(); });

    // Tab switching
    overlay.querySelectorAll('.roster-popup-tab').forEach(tab => {
      tab.addEventListener('click', () => {
        overlay.querySelectorAll('.roster-popup-tab').forEach(t => t.classList.remove('active'));
        overlay.querySelectorAll('.roster-popup-panel').forEach(p => p.classList.add('hidden'));
        tab.classList.add('active');
        overlay.querySelector(`.roster-popup-panel[data-team-id="${tab.dataset.teamId}"]`).classList.remove('hidden');
      });
    });
  }

  // ============================================================================
  // Link Popup: Link a GroupMe user to an existing person
  // ============================================================================
  openLinkPopup(gmUserId, gmNickname, gmImageUrl) {
    // Build set of person IDs already linked to a GroupMe account
    const linkedPersonIds = new Set();
    for (const p of this.players) {
      if (p.gmLinked && p.personId) linkedPersonIds.add(p.personId);
    }
    for (const gm of this.groupmeMembers) {
      if (gm.linked && gm.personId) linkedPersonIds.add(gm.personId);
    }

    // Candidates: all persons NOT already linked to GroupMe, from any source
    const candidatePersonIds = new Set();
    const candidates = [];

    const addCandidate = (personId, firstName, lastName, teams) => {
      if (!personId || linkedPersonIds.has(personId) || candidatePersonIds.has(personId)) return;
      candidatePersonIds.add(personId);
      candidates.push({ personId, firstName, lastName, teams: teams || [] });
    };

    // From eligibility player pool
    for (const p of this.players) {
      addCandidate(p.personId, p.firstName, p.lastName, p.teams);
    }

    // From all groupme members (includes roster-only from ALL sibling teams)
    for (const gm of this.groupmeMembers) {
      addCandidate(gm.personId, gm.firstName, gm.lastName, gm.teams);
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
            const teamBadges = (c.teams || []).map(t => {
              const label = t.divisionName || t.teamName || '';
              return `<span class="link-team-badge">${label}</span>`;
            }).join(' ');
            return `
              <div class="link-candidate" data-person-id="${c.personId}">
                <div class="link-candidate-name">${c.firstName} ${c.lastName}</div>
                <div class="link-candidate-teams">${teamBadges || '<span style="color:var(--color-warning);">No roster</span>'}</div>
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
      .map((playerId, idx) => ({ playerId, slotNumber: idx }));
    const bench = this.zones.bench.map(playerId => ({ playerId }));

    try {
      const response = await this.auth.fetch(`/api/eligibility/lineup/${matchId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          starters,
          bench,
          alternates: [],
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

  onExit() {
    // Clean up body overflow in case fit-to-screen was active
    document.body.style.overflow = '';
    if (this.element) {
      this.element.classList.remove('lineup-fit-screen');
    }
  }
}
