// GameDayLineupScreen - Lineup management with eligibility tracking
// Zones: Starting XI, Bench, Alternates, Not Responded, Not Going
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
      alternates: []   // Extra players available but not on 18/20 roster
    };
    this.playerPositions = {};
    this.sortField = 'rsvp';
    this.sortAsc = true;
    this.dragState = null;
    this.selectingSlot = null;
    this.activeOverlay = null;
    this.trainingEvents = [];
    this.trainingData = new Map();
    this._listenersAttached = false;
    this.viewMode = 'pitch';
    this._activePitchPopover = null;
    this._pitchRafId = null;
    this._pitchHitZones = [];
    // Auto-orient based on screen: landscape if wider than tall
    this.pitchOrientation = window.innerWidth > window.innerHeight ? 'landscape' : 'portrait';
    this.pitchFit = true; // always full screen
    this.formationLocked = false; // locked = formation positions enforced; unlocked = custom/free
    this.customPositions = null; // null = not set; array of {x,y,label} in canonical 0-100 space
    this.customDragMode = 'slots'; // 'slots' = move holder; 'players' = swap players between slots
    this._saveMetaTimer = null;  // debounce handle for auto-save
    this._saveLineupTimer = null; // debounce handle for lineup auto-save
    this._stopPitchLoop = this._stopPitchLoop || (() => {}); // forward-declare for early calls
  }

  render() {
    this._listenersAttached = false;

    const div = document.createElement('div');
    div.className = 'screen screen-game-day-lineup';
    div.innerHTML = `
      <div class="screen-header" style="display:flex;align-items:center;justify-content:space-between;gap:8px;flex-wrap:wrap;padding:12px 16px;">
        <button id="lineup-back-btn" class="btn btn-secondary">← Back</button>
        <div style="flex:1;min-width:0;">
          <h1 style="margin:0;font-size:1.1rem;">⚽ Game Day Lineup</h1>
          <p id="lineup-subtitle" class="subtitle" style="margin:0;font-size:0.8rem;opacity:0.7;">Loading...</p>
        </div>
        <button id="save-lineup-btn" class="btn btn-primary">💾 Save</button>
      </div>

      <div class="lineup-container" style="padding:0 12px 80px;">
        <!-- Data sync panel -->
        <div id="sync-panel" style="display:none;margin:8px 0 4px;"></div>

        <div id="lineup-loading" class="loading-state">
          <div class="spinner"></div>
          <p>Computing eligibility...</p>
        </div>

        <div id="lineup-content" style="display:none;">

          <!-- GroupMe sync warning -->
          <div id="groupme-warning" class="groupme-warning" style="display:none;"></div>

          <!-- Controls bar -->
          <div style="display:flex;align-items:center;gap:10px;margin-bottom:12px;flex-wrap:wrap;">
            <div style="display:flex;align-items:center;gap:6px;">
              <span style="font-size:0.85rem;opacity:0.7;">Roster:</span>
              <button id="roster-size-18" class="btn-roster-size" data-size="18" style="padding:4px 12px;border-radius:6px;border:1px solid var(--border-color);cursor:pointer;font-size:0.85rem;">18</button>
              <button id="roster-size-20" class="btn-roster-size active" data-size="20" style="padding:4px 12px;border-radius:6px;border:1px solid var(--border-color);cursor:pointer;font-size:0.85rem;">20</button>
            </div>
            <div style="display:flex;gap:0;border:1px solid var(--border-color);border-radius:6px;overflow:hidden;">
              <button class="btn-view-toggle active" data-view="list" style="padding:4px 10px;font-size:0.82rem;border:none;cursor:pointer;background:var(--bg-secondary);color:inherit;">📋 List</button>
              <button class="btn-view-toggle" data-view="pitch" style="padding:4px 10px;font-size:0.82rem;border:none;border-left:1px solid var(--border-color);cursor:pointer;background:transparent;color:inherit;">⚽ Pitch</button>
            </div>
            <div id="lineup-counts" style="font-size:0.85rem;opacity:0.7;flex:1;text-align:right;">
              ⚽ <span id="starting-count">0/11</span> · 🪑 <span id="bench-count-display">0/9</span> · 🔄 <span id="alt-count">0</span>
            </div>
            <button id="auto-fill-btn" class="btn btn-secondary btn-sm" style="font-size:0.8rem;">🔄 Re-fill</button>
          </div>

          <!-- Policy summary bar -->
          <div id="policy-bar" class="policy-bar"></div>

          <!-- Zone sections -->
          <div id="zone-sections"></div>

          <!-- Lineup toast -->
          <div id="lineup-toast" class="lineup-toast" style="display:none;position:fixed;bottom:80px;left:50%;transform:translateX(-50%);background:#333;color:#fff;padding:8px 20px;border-radius:20px;z-index:1000;font-size:0.9rem;"></div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    if (!this._listenersAttached) {
      this._listenersAttached = true;
      this.attachEventListeners();
      this.loadFormations();
    }
    this.syncThenLoad();
    this.loadSavedMetadata();
    this.loadLeaguesSyncStatus();
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
          this.syncFailed = false;
          console.log(`✅ GroupMe sync: ${syncData.data.totalRsvps} RSVPs (${syncData.data.going} going)`);
        } else {
          this.syncFailed = false; // skipped is not a failure
          console.log('ℹ️ GroupMe sync skipped:', syncData.data?.reason || syncData.message);
        }
      } catch (err) {
        this.syncFailed = true;
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

      // Sync panel buttons
      const syncBtn = e.target.closest('[data-sync-action]');
      if (syncBtn) {
        const action = syncBtn.dataset.syncAction;
        if (action === 'groupme') this.syncGroupMeCalendar();
        else if (action === 'scrape-apsl') this.requestScrape('apsl-teams');
        else if (action === 'scrape-casa') this.requestScrape('casa-schedule');
        return;
      }

      // View toggle
      const viewToggle = e.target.closest('.btn-view-toggle');
      if (viewToggle) {
        this.switchView(viewToggle.dataset.view);
        return;
      }

      // Pitch orientation toggle
      if (e.target.id === 'pitch-orient-btn' || e.target.closest('#pitch-orient-btn')) {
        this.pitchOrientation = this.pitchOrientation === 'portrait' ? 'landscape' : 'portrait';
        this.renderPitchView();
        return;
      }

      // Pitch fit-to-screen toggle (exit)
      if (e.target.id === 'pitch-fit-btn' || e.target.closest('#pitch-fit-btn')) {
        this.togglePitchFit();
        return;
      }

      // Groups panel
      if (e.target.id === 'pitch-groups-btn' || e.target.closest('#pitch-groups-btn')) {
        this.openGroupsPanel();
        return;
      }

      // Formation lock/custom toggle
      if (e.target.id === 'pitch-lock-btn' || e.target.closest('#pitch-lock-btn')) {        this.formationLocked = !this.formationLocked;
        if (!this.formationLocked && !this.customPositions) {
          // Seed from current formation on first switch to custom mode
          this.customPositions = this.getPositionsForFormation(
            this.selectedFormation?.code || '4-3-3'
          ).map(p => ({ x: p.x, y: p.y, label: p.label }));
        }
        this.renderPitchView();
        return;
      }

      // Pitch chip tap (filled slot)
      const pitchChip = e.target.closest('.pitch-chip');
      if (pitchChip && !e.target.closest('.pitch-popover')) {
        e.stopPropagation();
        this._dismissPitchPopover();
        this.openEditPlayerModal(parseInt(pitchChip.dataset.playerId), parseInt(pitchChip.dataset.slotIndex));
        return;
      }

      // Pitch empty slot tap
      const pitchSlot = e.target.closest('.pitch-empty-slot');
      if (pitchSlot && !e.target.closest('.pitch-popover')) {
        e.stopPropagation();
        this._dismissPitchPopover();
        this.openSlotPicker(parseInt(pitchSlot.dataset.slot), e);
        return;
      }

      // Dismiss popover on outside click
      if (!e.target.closest('.pitch-popover')) {
        this._dismissPitchPopover();
      }

      // Roster size toggle
      const rosterSizeBtn = e.target.closest('.btn-roster-size');
      if (rosterSizeBtn) {
        const size = parseInt(rosterSizeBtn.dataset.size);
        this.setRosterSize(size);
        return;
      }

      // Link button
      const linkBtn = e.target.closest('.btn-link-player');
      if (linkBtn) {
        e.stopPropagation();
        this.openLinkPopup(linkBtn.dataset.gmUserId, linkBtn.dataset.gmNickname, linkBtn.dataset.gmImage);
        return;
      }

      // RSVP buttons
      const rsvpBtn = e.target.closest('.rsvp-btn');
      if (rsvpBtn) {
        e.stopPropagation();
        this.updatePlayerRsvp(parseInt(rsvpBtn.dataset.playerId), rsvpBtn.dataset.rsvp);
        return;
      }

      // Zone move buttons: data-action="move" data-player-id data-to-zone
      const moveBtn = e.target.closest('.zone-move-btn');
      if (moveBtn) {
        e.stopPropagation();
        const playerId = parseInt(moveBtn.dataset.playerId);
        const toZone = moveBtn.dataset.toZone;
        this.movePlayerToZone(playerId, toZone);
        return;
      }

      // Full edit modal on player card tap (not on buttons)
      const card = e.target.closest('.lineup-player-card');
      if (card && !e.target.closest('button')) {
        const playerId = parseInt(card.dataset.playerId);
        this.openEditPlayerModal(playerId);
        return;
      }

      // Section toggle (collapse/expand)
      const sectionHdr = e.target.closest('.lineup-section-header');
      if (sectionHdr) {
        const sectionId = sectionHdr.dataset.section;
        const body = this.find(`#section-body-${sectionId}`);
        const arrow = sectionHdr.querySelector('.section-arrow');
        if (body) {
          const collapsed = body.style.display === 'none';
          body.style.display = collapsed ? '' : 'none';
          if (arrow) arrow.textContent = collapsed ? '▾' : '▸';
        }
        return;
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

      // Restore custom positions (if saved)
      if (meta.customPositions && Array.isArray(meta.customPositions)) {
        this.customPositions = meta.customPositions;
      }

      // Restore formation lock state
      if (meta.formationLocked === false) {
        this.formationLocked = false;
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

    // If bench has too many players, move extras to alternates
    const maxBench = size - 11;
    while (this.zones.bench.length > maxBench) {
      const overflow = this.zones.bench.pop();
      this.zones.alternates.unshift(overflow);
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
          rosterSize: this.rosterSize,
          customPositions: this.customPositions || null,
          formationLocked: this.formationLocked
        })
      });
    } catch (e) {
      console.warn('Failed to save metadata:', e);
    }
  }

  // Debounced auto-save of metadata (e.g. after dragging a chip)
  _scheduleSaveMeta() {
    if (this._saveMetaTimer) clearTimeout(this._saveMetaTimer);
    this._saveMetaTimer = setTimeout(() => { this.saveMetadata(); }, 800);
  }

  // Debounced silent auto-save of the lineup (zones) after any zone change
  _scheduleAutoSaveLineup() {
    if (this._saveLineupTimer) clearTimeout(this._saveLineupTimer);
    this._saveLineupTimer = setTimeout(() => { this.saveLineup(true); }, 1200);
  }

  // ============================================================================
  // League Sync Panel
  // ============================================================================

  async loadLeaguesSyncStatus() {
    const teamId = this.navigation.context.lineupTeamId || this.navigation.context.team?.id;
    if (!teamId) return;
    const panel = this.find('#sync-panel');
    if (!panel) return;
    try {
      const res = await this.auth.fetch(`/api/groupme/leagues-sync-status/${teamId}`);
      const result = await res.json();
      if (!result.success || !result.data) return;
      this._leaguesSyncData = result.data;
      this._leaguesSyncTeamId = teamId;
      this.renderSyncPanel();
    } catch (err) {
      console.warn('Failed to load leagues sync status:', err.message);
    }
  }

  renderSyncPanel() {
    const panel = this.find('#sync-panel');
    if (!panel || !this._leaguesSyncData) return;

    const { groupme, scrape } = this._leaguesSyncData;
    const now = Date.now();
    const staleMs = 7 * 24 * 60 * 60 * 1000; // 7 days
    const rows = [];
    let allGreen = true;

    const fmtTime = iso => new Date(iso).toLocaleString([], { month:'short', day:'numeric', hour:'2-digit', minute:'2-digit' });
    const fmtDay  = iso => new Date(iso).toLocaleString([], { month:'short', day:'numeric' });
    const statusOf = (iso, thresholdMs) => {
      if (!iso) return 'missing';
      const age = now - new Date(iso).getTime();
      return age < thresholdMs ? 'ok' : age < thresholdMs * 2 ? 'warn' : 'old';
    };
    const dot = s => s === 'ok' ? '🟢' : s === 'warn' ? '🟡' : '🔴';
    const syncBtn = (action, label) =>
      `<button data-sync-action="${action}" style="font-size:0.72rem;padding:2px 8px;border:1px solid currentColor;border-radius:4px;cursor:pointer;background:transparent;color:inherit;margin-left:6px;">${label}</button>`;

    // ── Determine league from scrape keys ──────────────────────────────────
    const hasApsl = !!(scrape['apsl-teams'] || scrape['apsl-standings']);
    const hasCasa = !!(scrape['casa-schedule'] || scrape['casa-rosters']);

    // ── APSL row ──────────────────────────────────────────────────────────
    if (hasApsl) {
      const scrapeTs = [scrape['apsl-teams']?.updatedAt, scrape['apsl-standings']?.updatedAt]
        .filter(Boolean).sort().pop();
      const scrapeFail = scrape['apsl-teams']?.status === 'error' || scrape['apsl-standings']?.status === 'error';
      const gmChat = groupme.find(c => c.chatType === 1 && c.chatName?.toLowerCase().includes('apsl'));
      const scrapeStatus = scrapeFail ? 'old' : statusOf(scrapeTs, staleMs);
      const gmStatus = statusOf(gmChat?.lastSyncedAt, 24 * 60 * 60 * 1000);
      const rowStatus = (scrapeStatus === 'ok' && gmStatus === 'ok') ? 'ok' : (scrapeStatus === 'old' || gmStatus === 'old') ? 'old' : 'warn';
      if (rowStatus !== 'ok') allGreen = false;
      rows.push(`
        <div style="display:flex;align-items:center;gap:6px;padding:5px 10px;border-radius:6px;background:var(--bg-secondary);font-size:0.78rem;">
          <span style="font-weight:700;min-width:38px;">APSL</span>
          <span title="Schedule last scraped">${dot(scrapeStatus)} ${scrapeTs ? fmtDay(scrapeTs) : 'never'}${scrapeFail ? ' ⚠️' : ''}</span>
          <span style="color:var(--text-muted)">·</span>
          <span title="GroupMe last synced">💬 ${gmChat?.lastSyncedAt ? fmtTime(gmChat.lastSyncedAt) : 'never'}</span>
          <span style="flex:1;"></span>
          ${syncBtn('scrape-apsl', '🌐')}
          ${syncBtn('groupme', '💬')}
        </div>`);
    }

    // ── CASA row ──────────────────────────────────────────────────────────
    if (hasCasa) {
      const scrapeTs = [scrape['casa-schedule']?.updatedAt, scrape['casa-rosters']?.updatedAt]
        .filter(Boolean).sort().pop();
      const scrapeFail = scrape['casa-schedule']?.status === 'error' || scrape['casa-rosters']?.status === 'error';
      const gmChat = groupme.find(c => c.chatType === 1 && (c.chatName?.toLowerCase().includes('liga') || c.chatName?.toLowerCase().includes('casa')));
      const scrapeStatus = scrapeFail ? 'old' : statusOf(scrapeTs, staleMs);
      const gmStatus = statusOf(gmChat?.lastSyncedAt, 24 * 60 * 60 * 1000);
      const rowStatus = (scrapeStatus === 'ok' && gmStatus === 'ok') ? 'ok' : (scrapeStatus === 'old' || gmStatus === 'old') ? 'old' : 'warn';
      if (rowStatus !== 'ok') allGreen = false;
      rows.push(`
        <div style="display:flex;align-items:center;gap:6px;padding:5px 10px;border-radius:6px;background:var(--bg-secondary);font-size:0.78rem;">
          <span style="font-weight:700;min-width:38px;">CASA</span>
          <span title="Schedule last scraped">${dot(scrapeStatus)} ${scrapeTs ? fmtDay(scrapeTs) : 'never'}${scrapeFail ? ' ⚠️' : ''}</span>
          <span style="color:var(--text-muted)">·</span>
          <span title="GroupMe last synced">💬 ${gmChat?.lastSyncedAt ? fmtTime(gmChat.lastSyncedAt) : 'never'}</span>
          <span style="flex:1;"></span>
          ${syncBtn('scrape-casa', '🌐')}
          ${syncBtn('groupme', '💬')}
        </div>`);
    }

    // ── Training row ──────────────────────────────────────────────────────
    const trainingChat = groupme.find(c => c.chatType === 5);
    const pickupChat   = groupme.find(c => c.chatType === 3);
    const trainTs = trainingChat?.lastSyncedAt || pickupChat?.lastSyncedAt;
    const trainStatus = statusOf(trainTs, 24 * 60 * 60 * 1000);
    if (trainStatus !== 'ok') allGreen = false;
    rows.push(`
      <div style="display:flex;align-items:center;gap:6px;padding:5px 10px;border-radius:6px;background:var(--bg-secondary);font-size:0.78rem;">
        <span style="font-weight:700;min-width:38px;">Train</span>
        <span>💬 ${trainTs ? fmtTime(trainTs) : 'never'}</span>
        <span style="flex:1;"></span>
        ${syncBtn('groupme', '💬 Sync')}
      </div>`);

    const headerIcon = allGreen ? '🟢' : '🔴';
    this._syncAllGreen = allGreen;
    panel.innerHTML = `
      <details open style="border:1px solid var(--border-color);border-radius:8px;overflow:hidden;">
        <summary style="padding:6px 10px;cursor:pointer;font-size:0.8rem;font-weight:600;list-style:none;display:flex;align-items:center;gap:6px;">
          ${headerIcon} Data Sync
        </summary>
        <div style="padding:6px 4px;display:flex;flex-direction:column;gap:4px;">
          ${rows.join('')}
        </div>
      </details>`;
    panel.style.display = 'block';
  }

  _openPitchSyncModal() {
    // Remove any existing modal
    document.getElementById('pitch-sync-modal')?.remove();

    const { groupme, scrape } = this._leaguesSyncData || { groupme: [], scrape: {} };
    const now = Date.now();
    const staleMs = 7 * 24 * 60 * 60 * 1000;
    const statusOf = (iso, ms) => !iso ? 'old' : (now - new Date(iso).getTime()) < ms ? 'ok' : 'warn';
    const dot = s => s === 'ok' ? '🟢' : s === 'warn' ? '🟡' : '🔴';
    const fmtTime = iso => new Date(iso).toLocaleString([], { month:'short', day:'numeric', hour:'2-digit', minute:'2-digit' });
    const fmtDay  = iso => new Date(iso).toLocaleString([], { month:'short', day:'numeric' });

    const rows = [];
    const addRow = (label, items, syncAction) => {
      rows.push(`<div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-bottom:1px solid rgba(255,255,255,0.08);">
        <span style="font-weight:700;min-width:52px;color:#fff;">${label}</span>
        <div style="flex:1;font-size:0.78rem;color:rgba(255,255,255,0.75);">${items}</div>
        <button data-sync-action="${syncAction}" onclick="this.closest('#pitch-sync-modal').dispatchEvent(new CustomEvent('sync-action',{detail:'${syncAction}',bubbles:true}))" style="padding:4px 10px;border-radius:6px;border:1px solid rgba(255,255,255,0.3);background:rgba(255,255,255,0.1);color:#fff;font-size:0.75rem;cursor:pointer;">Sync</button>
      </div>`);
    };

    const hasApsl = !!(scrape['apsl-teams'] || scrape['apsl-standings']);
    const hasCasa = !!(scrape['casa-schedule'] || scrape['casa-rosters']);

    if (hasApsl) {
      const scrapeTs = [scrape['apsl-teams']?.updatedAt, scrape['apsl-standings']?.updatedAt].filter(Boolean).sort().pop();
      const scrapeFail = scrape['apsl-teams']?.status === 'error';
      const gmChat = groupme.find(c => c.chatType === 1 && c.chatName?.toLowerCase().includes('apsl'));
      const scrSt = scrapeFail ? 'old' : statusOf(scrapeTs, staleMs);
      const gmSt  = statusOf(gmChat?.lastSyncedAt, 24*60*60*1000);
      addRow('APSL',
        `${dot(scrSt)} Schedule: ${scrapeTs ? fmtDay(scrapeTs) : 'never'}${scrapeFail?' ⚠️':''} &nbsp; ${dot(gmSt)} GroupMe: ${gmChat?.lastSyncedAt ? fmtTime(gmChat.lastSyncedAt) : 'never'}`,
        'groupme');
    }

    if (hasCasa) {
      const scrapeTs = [scrape['casa-schedule']?.updatedAt, scrape['casa-rosters']?.updatedAt].filter(Boolean).sort().pop();
      const scrapeFail = scrape['casa-schedule']?.status === 'error';
      const gmChat = groupme.find(c => c.chatType === 1 && (c.chatName?.toLowerCase().includes('liga') || c.chatName?.toLowerCase().includes('casa')));
      const scrSt = scrapeFail ? 'old' : statusOf(scrapeTs, staleMs);
      const gmSt  = statusOf(gmChat?.lastSyncedAt, 24*60*60*1000);
      addRow('CASA',
        `${dot(scrSt)} Schedule: ${scrapeTs ? fmtDay(scrapeTs) : 'never'}${scrapeFail?' ⚠️':''} &nbsp; ${dot(gmSt)} GroupMe: ${gmChat?.lastSyncedAt ? fmtTime(gmChat.lastSyncedAt) : 'never'}`,
        'groupme');
    }

    const trainingChat = groupme.find(c => c.chatType === 5) || groupme.find(c => c.chatType === 3);
    const trainSt = statusOf(trainingChat?.lastSyncedAt, 24*60*60*1000);
    addRow('Training',
      `${dot(trainSt)} GroupMe: ${trainingChat?.lastSyncedAt ? fmtTime(trainingChat.lastSyncedAt) : 'never'}`,
      'groupme');

    const modal = document.createElement('div');
    modal.id = 'pitch-sync-modal';
    modal.style.cssText = 'position:fixed;inset:0;z-index:1100;display:flex;align-items:flex-end;';
    modal.innerHTML = `
      <div style="position:absolute;inset:0;background:rgba(0,0,0,0.6);" id="pitch-sync-backdrop"></div>
      <div style="position:relative;width:100%;background:#1a1a2e;border-radius:16px 16px 0 0;padding-bottom:env(safe-area-inset-bottom,12px);z-index:1;">
        <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 16px 10px;border-bottom:1px solid rgba(255,255,255,0.1);">
          <span style="font-size:0.95rem;font-weight:700;color:#fff;">📡 Data Sync</span>
          <button id="pitch-sync-close" style="background:none;border:none;color:rgba(255,255,255,0.6);font-size:1.2rem;cursor:pointer;padding:2px 6px;">✕</button>
        </div>
        ${rows.join('')}
        <div style="padding:10px 12px;">
          <button data-sync-action="groupme" onclick="this.closest('#pitch-sync-modal').dispatchEvent(new CustomEvent('sync-action',{detail:'groupme',bubbles:true}))" style="width:100%;padding:10px;border-radius:8px;border:none;background:rgba(99,102,241,0.8);color:#fff;font-size:0.9rem;font-weight:600;cursor:pointer;">🔄 Sync All GroupMe</button>
        </div>
      </div>`;

    modal.querySelector('#pitch-sync-backdrop').addEventListener('click', () => modal.remove());
    modal.querySelector('#pitch-sync-close').addEventListener('click', () => modal.remove());
    modal.addEventListener('sync-action', async (e) => {
      const action = e.detail;
      modal.remove();
      if (action === 'groupme') await this.syncGroupMeCalendar();
      else if (action === 'scrape-apsl') await this.requestScrape('apsl-teams');
      else if (action === 'scrape-casa') await this.requestScrape('casa-schedule');
    });

    document.body.appendChild(modal);
  }

  async syncGroupMeCalendar() {
    const teamId = this._leaguesSyncTeamId;
    if (!teamId) return;
    this.showLineupToast('⏳ Syncing GroupMe...');
    try {
      const res = await this.auth.fetch(`/api/groupme/sync-calendar/${teamId}`, { method: 'POST' });
      const result = await res.json();
      if (result.success) {
        this.showLineupToast('✅ GroupMe synced');
        await this.loadLeaguesSyncStatus();
        await this.loadEligibilityData();
      } else {
        this.showLineupToast('❌ Sync failed: ' + (result.message || 'unknown error'));
      }
    } catch (err) {
      this.showLineupToast('❌ ' + err.message);
    }
  }

  async requestScrape(scraperType) {
    this.showLineupToast(`⏳ Requesting ${scraperType} scrape...`);
    try {
      const res = await this.auth.fetch(`/api/system-admin/scrapers/trigger?scraper_type=${scraperType}`, { method: 'POST' });
      const result = await res.json();
      if (result.success) {
        this.showLineupToast(`✅ Scrape queued — check back in a few minutes`);
      } else {
        this.showLineupToast('❌ ' + (result.error || 'Request failed'));
      }
    } catch (err) {
      this.showLineupToast('❌ ' + err.message);
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
    const hasLinkedEvent = sync.hasLinkedEvent;
    
    const timeStr = sync.lastSync ? new Date(sync.lastSync).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '';
    const refreshBtn = '<button id="groupme-refresh-btn" class="btn-groupme-refresh" style="margin-left:8px;padding:2px 10px;font-size:0.8rem;border:1px solid currentColor;border-radius:4px;cursor:pointer;background:transparent;color:inherit;">🔄 Sync</button>';
    
    let icon, message, level;

    if (!hasLinkedEvent) {
      icon = '🔗';
      message = `No GroupMe event linked to this match — RSVPs unavailable. ${refreshBtn}`;
      level = 'error';
    } else if (status === 'not_synced') {
      icon = '⚠️';
      message = `GroupMe event linked but RSVPs not yet synced. ${refreshBtn}`;
      level = 'warning';
    } else if (status === 'fresh') {
      icon = '✅';
      message = `RSVPs synced${timeStr ? ' at ' + timeStr : ''}. ${refreshBtn}`;
      level = 'success';
    } else if (status === 'stale') {
      const hours = Math.floor(minutes / 60);
      const mins = minutes % 60;
      icon = '⏳';
      message = `RSVPs synced ${hours}h ${mins}m ago${timeStr ? ' (' + timeStr + ')' : ''}. ${refreshBtn}`;
      level = 'warning';
    } else if (status === 'very_stale') {
      const days = Math.floor(minutes / 1440);
      icon = '⚠️';
      message = `RSVP data is ${days} day${days !== 1 ? 's' : ''} old. ${refreshBtn}`;
      level = 'error';
    }
    
    if (!message) {
      banner.style.display = 'none';
      return;
    }

    banner.className = `groupme-warning groupme-warning-${level}`;
    banner.innerHTML = `<span>${icon}</span> <span>${message}</span>`;
    banner.style.cssText = 'display:flex;align-items:center;gap:6px;padding:8px 12px;border-radius:8px;margin-bottom:10px;font-size:0.85rem;';
    if (level === 'error') banner.style.background = 'rgba(239,68,68,0.12)';
    else if (level === 'warning') banner.style.background = 'rgba(245,158,11,0.12)';
    else banner.style.background = 'rgba(34,197,94,0.12)';
  }

  /**
   * Refresh GroupMe RSVPs and reload eligibility data.
   */
  async refreshGroupMe() {
    const btn = this.find('#groupme-refresh-btn');
    if (btn) {
      btn.disabled = true;
      btn.textContent = '⏳';
    }

    const matchId = this.navigation.context.match?.id;
    const teamId = this.navigation.context.lineupTeamId || this.navigation.context.team?.id || '';

    try {
      const syncResponse = await this.auth.fetch(`/api/groupme/sync-match/${matchId}?teamId=${teamId}`, {
        method: 'POST'
      });
      const syncData = await syncResponse.json();

      if (syncData.success && syncData.data?.synced) {
        this.showLineupToast(`✅ Synced: ${syncData.data.going || 0} going, ${syncData.data.notGoing || 0} not going`);
      } else if (syncData.data?.reason === 'no_linked_event') {
        this.showLineupToast('⚠️ No GroupMe event linked to this match');
      } else {
        this.showLineupToast('ℹ️ ' + (syncData.data?.reason || syncData.message || 'Sync complete'));
      }
    } catch (err) {
      console.warn('⚠️ Refresh failed:', err.message);
      this.showLineupToast('❌ Sync failed: ' + err.message);
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
    this.zones = { starting: [], bench: [], alternates: [] };

    const maxBench = this.rosterSize - 11;

    // If saved lineup exists (onLineup flag set by API), restore it
    const hasSavedLineup = this.players.some(p => p.onLineup);
    if (hasSavedLineup) {
      for (const player of this.players) {
        if (!player.onLineup) continue;
        const zone = player.lineupZone || (player.isStarter ? 'starter' : 'bench');
        if (zone === 'starter') {
          this.zones.starting.push(player.playerId);
        } else if (zone === 'alternate') {
          this.zones.alternates.push(player.playerId);
        } else {
          // bench (or legacy rows without zone)
          if (this.zones.bench.length < maxBench) {
            this.zones.bench.push(player.playerId);
          } else {
            this.zones.alternates.push(player.playerId);
          }
        }
      }
      this._enforceApslFilter();
      return;
    }

    // No saved lineup — auto-distribute from RSVP
    this._autoDistribute();
  }

  _isApslEligible(player) {
    return !!(player.eligApslStarter || player.eligApslBench);
  }

  // Remove any player from starting/bench/alternates who is not APSL-eligible.
  // Called after zone population and after eligibility saves.
  _enforceApslFilter() {
    const strip = (arr) => arr.filter(id => {
      const p = this.getPlayerById(id);
      return p && this._isApslEligible(p);
    });
    this.zones.starting   = strip(this.zones.starting);
    this.zones.bench      = strip(this.zones.bench);
    this.zones.alternates = strip(this.zones.alternates);
  }

  _autoDistribute() {
    this.zones = { starting: [], bench: [], alternates: [] };
    const maxBench = this.rosterSize - 11;

    // Sort going players: eligible first, then by practices
    const statusOrder = { priority_starter: 0, eligible_starter: 1, bench_only: 2, ineligible: 3, not_computed: 4, not_on_roster: 5 };
    const going = this.players
      .filter(p => p.matchRsvp === 'yes' && this._isApslEligible(p))
      .sort((a, b) => {
        const sa = statusOrder[a.eligibilityStatus] ?? 4;
        const sb = statusOrder[b.eligibilityStatus] ?? 4;
        if (sa !== sb) return sa - sb;
        return (b.sessionsAttended || 0) - (a.sessionsAttended || 0);
      });

    for (const player of going) {
      if (this.zones.starting.length < 11) {
        this.zones.starting.push(player.playerId);
      } else if (this.zones.bench.length < maxBench) {
        this.zones.bench.push(player.playerId);
      } else {
        this.zones.alternates.push(player.playerId);
      }
    }

    // Maybe/pending also go to alternates (available but not confirmed)
    const maybe = this.players
      .filter(p => p.matchRsvp !== 'yes' && p.matchRsvp !== 'no' && this._isApslEligible(p))
      .sort((a, b) => (b.sessionsAttended || 0) - (a.sessionsAttended || 0));

    for (const player of maybe) {
      this.zones.alternates.push(player.playerId);
    }
    // Not going stays out of all zones
  }

  autoFillFromEligibility() {
    this._autoDistribute();
    this.renderAllZones();
  }

  // ============================================================================
  // Rendering
  // ============================================================================
  getPlayerById(playerId) {
    return this.players.find(p => p.playerId === playerId);
  }

  renderAllZones() {
    if (this.viewMode === 'pitch') {
      this.renderPitchView();
    } else {
      this.renderZoneSections();
    }
    this.updateCounts();
  }

  updateCounts() {
    const maxBench = this.rosterSize - 11;
    const sc = this.find('#starting-count');
    if (sc) sc.textContent = `${this.zones.starting.length}/11`;
    const bc = this.find('#bench-count-display');
    if (bc) bc.textContent = `${this.zones.bench.length}/${maxBench}`;
    const ac = this.find('#alt-count');
    if (ac) ac.textContent = `${this.zones.alternates.length}`;
  }

  renderPlayerTable() {
    // no-op (overlay system removed)
  }

  // ============================================================================
  // Zone Section Rendering
  // ============================================================================
  renderZoneSections() {
    const container = this.find('#zone-sections');
    if (!container) return;
    container.innerHTML = '';

    const maxBench = this.rosterSize - 11;

    // Derive pool players (not in any active zone)
    const allZoned = new Set([...this.zones.starting, ...this.zones.bench, ...this.zones.alternates]);
    const notResponded = this._rankPlayers(this.players.filter(p => !allZoned.has(p.playerId) && p.matchRsvp !== 'no'));
    const notGoing = this._rankPlayers(this.players.filter(p => !allZoned.has(p.playerId) && p.matchRsvp === 'no'));

    // Helper: build move buttons for a card in a given zone
    const moveBtns = (playerId, currentZone) => {
      const btnStyle = 'padding:3px 8px;font-size:0.75rem;border:1px solid var(--border-color);border-radius:4px;cursor:pointer;background:var(--bg-secondary);';
      const parts = [];
      if (currentZone !== 'starting') {
        const full = this.zones.starting.length >= 11;
        parts.push(`<button class="zone-move-btn" data-player-id="${playerId}" data-to-zone="starting" style="${btnStyle}${full ? 'opacity:0.5;' : ''}">⚽ Start</button>`);
      }
      if (currentZone !== 'bench') {
        const full = this.zones.bench.length >= maxBench;
        parts.push(`<button class="zone-move-btn" data-player-id="${playerId}" data-to-zone="bench" style="${btnStyle}${full ? 'opacity:0.5;' : ''}">🪑 Bench</button>`);
      }
      if (currentZone !== 'alternates') {
        parts.push(`<button class="zone-move-btn" data-player-id="${playerId}" data-to-zone="alternates" style="${btnStyle}">🔄 Alt</button>`);
      }
      if (currentZone !== 'pool') {
        parts.push(`<button class="zone-move-btn" data-player-id="${playerId}" data-to-zone="pool" style="${btnStyle}color:#ef4444;">✕</button>`);
      }
      return parts.join('');
    };

    const sections = [
      {
        id: 'starting',
        label: `⚽ Starting XI`,
        countLabel: () => `${this.zones.starting.length}/11`,
        players: this.zones.starting.map(id => this.getPlayerById(id)).filter(Boolean),
        zone: 'starting',
        color: '#22c55e',
        collapsible: false
      },
      {
        id: 'bench',
        label: `🪑 Bench`,
        countLabel: () => `${this.zones.bench.length}/${maxBench}`,
        players: this.zones.bench.map(id => this.getPlayerById(id)).filter(Boolean),
        zone: 'bench',
        color: '#3b82f6',
        collapsible: false
      },
      {
        id: 'alternates',
        label: `🔄 Alternates`,
        countLabel: () => `${this.zones.alternates.length}`,
        players: this.zones.alternates.map(id => this.getPlayerById(id)).filter(Boolean),
        zone: 'alternates',
        color: '#f59e0b',
        collapsible: false
      },
      {
        id: 'notresponded',
        label: `❔ Not Responded`,
        countLabel: () => `${notResponded.length}`,
        players: notResponded,
        zone: 'pool',
        color: '#6b7280',
        collapsible: true,
        startCollapsed: false
      },
      {
        id: 'notgoing',
        label: `✗ Not Going`,
        countLabel: () => `${notGoing.length}`,
        players: notGoing,
        zone: 'pool',
        color: '#ef4444',
        collapsible: true,
        startCollapsed: true
      }
    ];

    for (const section of sections) {
      const sectionEl = document.createElement('div');
      sectionEl.style.cssText = 'margin-bottom:12px;border:1px solid var(--border-color);border-radius:10px;overflow:hidden;';

      const collapsed = section.startCollapsed;
      const arrowChar = collapsed ? '▸' : '▾';

      sectionEl.innerHTML = `
        <div class="lineup-section-header" data-section="${section.id}"
          style="display:flex;align-items:center;gap:8px;padding:10px 14px;background:var(--bg-secondary);cursor:${section.collapsible ? 'pointer' : 'default'};">
          <span style="font-weight:600;flex:1;">${section.label}</span>
          <span style="font-size:0.8rem;opacity:0.6;" id="section-count-${section.id}">${section.countLabel()}</span>
          ${section.collapsible ? `<span class="section-arrow" style="font-size:0.85rem;opacity:0.6;">${arrowChar}</span>` : ''}
        </div>
        <div id="section-body-${section.id}" style="${collapsed ? 'display:none;' : ''}padding:6px 8px;">
        </div>
      `;
      container.appendChild(sectionEl);

      const body = sectionEl.querySelector(`#section-body-${section.id}`);

      if (section.players.length === 0) {
        body.innerHTML = `<div style="padding:8px 6px;font-size:0.85rem;opacity:0.5;text-align:center;">— empty —</div>`;
      } else {
        for (const player of section.players) {
          body.appendChild(this.createLineupCard(player, section.zone, moveBtns(player.playerId, section.zone)));
        }
      }

      // Unlinked GroupMe RSVPs in "not responded" section
      if (section.id === 'notresponded' && this.unmatchedRsvps?.length) {
        for (const u of this.unmatchedRsvps) {
          body.appendChild(this.createUnlinkedCard(u));
        }
      }
    }
  }

  createLineupCard(player, zone, moveBtnsHtml) {
    const card = document.createElement('div');
    card.className = 'lineup-player-card';
    card.dataset.playerId = player.playerId;
    card.style.cssText = 'display:flex;align-items:center;gap:8px;padding:8px 10px;margin-bottom:4px;background:var(--bg-primary);border-radius:8px;border:1px solid var(--border-color);';

    const jersey = player.jerseyNumber ? `#${player.jerseyNumber}` : '—';
    const name = `${player.firstName || ''} ${player.lastName || ''}`.trim();
    const eligIcon = this.getStatusIcon(player.eligibilityStatus);
    const rsvpDot = player.matchRsvp === 'yes' ? '🟢' : player.matchRsvp === 'no' ? '🔴' : '🟡';
    const prac = player.sessionsAttended || 0;
    const pracMax = this.policy?.lookbackCount || '';
    const pracStr = pracMax ? `${prac}/${pracMax}` : `${prac}`;

    card.innerHTML = `
      <span style="font-size:0.8rem;opacity:0.5;min-width:28px;text-align:right;">${jersey}</span>
      <span style="flex:1;font-size:0.9rem;font-weight:500;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${name}</span>
      <span title="${player.eligibilityStatus || ''}" style="font-size:0.85rem;">${eligIcon}</span>
      <span style="font-size:0.75rem;opacity:0.6;">${pracStr}</span>
      <span style="font-size:0.75rem;">${rsvpDot}</span>
      <div style="display:flex;gap:4px;flex-shrink:0;">${moveBtnsHtml}</div>
    `;
    return card;
  }

  createUnlinkedCard(user) {
    const card = document.createElement('div');
    card.style.cssText = 'display:flex;align-items:center;gap:8px;padding:8px 10px;margin-bottom:4px;background:var(--bg-primary);border-radius:8px;border:1px dashed var(--border-color);opacity:0.8;';
    const rsvp = user.matchRsvp === 'yes' ? '🟢' : user.matchRsvp === 'no' ? '🔴' : '🟡';
    card.innerHTML = `
      <span style="font-size:0.8rem;opacity:0.5;min-width:28px;">—</span>
      <span style="flex:1;font-size:0.9rem;opacity:0.7;">${user.externalUsername || 'Unknown'}</span>
      <span style="font-size:0.75rem;">🔗 unlinked</span>
      <span style="font-size:0.75rem;">${rsvp}</span>
      <button class="btn-link-player"
        style="padding:3px 8px;font-size:0.75rem;border:1px solid var(--border-color);border-radius:4px;cursor:pointer;background:var(--bg-secondary);"
        data-gm-user-id="${user.externalUserId || ''}"
        data-gm-nickname="${(user.externalUsername || '').replace(/"/g, '&quot;')}"
        data-gm-image="${(user.gmImageUrl || '').replace(/"/g, '&quot;')}">🔗 Link</button>
    `;
    return card;
  }

  /**
   * Move a player to a zone.
   * toZone: 'starting' | 'bench' | 'alternates' | 'pool' (removes from all zones)
   */
  movePlayerToZone(playerId, toZone) {
    const maxBench = this.rosterSize - 11;
    if (toZone === 'starting' && this.zones.starting.length >= 11) {
      this.showLineupToast('Starting XI is full (11/11)');
      return;
    }
    if (toZone === 'bench' && this.zones.bench.length >= maxBench) {
      this.showLineupToast(`Bench is full (${maxBench}/${maxBench})`);
      return;
    }
    this.removePlayerFromAllZones(playerId);
    if (toZone !== 'pool') {
      this.zones[toZone].push(playerId);
    }
    this.renderAllZones();
    this._scheduleAutoSaveLineup();
  }

  createUnmatchedPoolRow(user) {
    // Legacy — replaced by createUnlinkedCard
    return this.createUnlinkedCard(user);
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

      // Re-render zones (RSVP change may move player between sections)
      this.renderAllZones();
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

  // Combined RSVP + practice state → one of: green, yellow, blue, orange, red
  _eligState(player) {
    const rsvpYes   = player.matchRsvp === 'yes';
    const status    = player.eligibilityStatus;
    const metPrac   = status === 'priority_starter' || status === 'eligible_starter';
    const partPrac  = status === 'bench_only';
    if (rsvpYes && metPrac)   return 'green';
    if (rsvpYes && partPrac)  return 'yellow';
    if (rsvpYes)              return 'blue';
    if (metPrac)              return 'orange';
    return 'red';
  }

  getEligibilityClass(player) {
    switch (this._eligState(player)) {
      case 'green':  return 'elig-green';
      case 'yellow': return 'elig-yellow';
      case 'blue':   return 'elig-blue';
      case 'orange': return 'elig-orange';
      default:       return 'elig-red';
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
    this.zones.starting = this.zones.starting.filter(id => id !== playerId);
    this.zones.bench = this.zones.bench.filter(id => id !== playerId);
    this.zones.alternates = this.zones.alternates.filter(id => id !== playerId);
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
    this._scheduleAutoSaveLineup();
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
    this._scheduleAutoSaveLineup();
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
  async saveLineup(silent = false) {
    const matchId = this.navigation.context.match?.id;
    if (!matchId) {
      if (!silent) this.showLineupToast('No match selected');
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
          alternates: this.zones.alternates.map(playerId => ({ playerId })),
          formationId: this.selectedFormation?.id || 0,
          rosterSize: this.rosterSize
        })
      });

      const data = await response.json();
      if (data.success) {
        if (!silent) {
          const total = starters.length + bench.length;
          this.showLineupToast(`✓ Saved: ${starters.length}+${bench.length} (${total} players)`);
        }
      } else {
        throw new Error(data.message || 'Failed to save');
      }
    } catch (error) {
      console.error('Error saving lineup:', error);
      this.showLineupToast('❌ Save failed: ' + error.message);
    }
  }

  // ============================================================================
  // View Switching
  // ============================================================================
  switchView(mode) {
    this.viewMode = mode;
    this._dismissPitchPopover();
    if (mode !== 'pitch') this._stopPitchLoop();
    this.element.querySelectorAll('.btn-view-toggle').forEach(btn => {
      const active = btn.dataset.view === mode;
      btn.classList.toggle('active', active);
      btn.style.background = active ? 'var(--bg-secondary)' : 'transparent';
    });
    this.renderAllZones();
  }

  // ============================================================================
  // Pitch View — Canvas game-loop renderer
  // ============================================================================

  // Stop the running RAF loop (if any)
  _stopPitchLoop() {
    if (this._pitchRafId) {
      cancelAnimationFrame(this._pitchRafId);
      this._pitchRafId = null;
    }
  }

  // Draw the full pitch + players onto a canvas using a RAF game loop.
  // Returns the wrapper element (already appended to `container`).
  _startPitchCanvas(container) {
    this._stopPitchLoop();

    // ── wrapper ──────────────────────────────────────────────────────────────
    const landscape = this.pitchOrientation === 'landscape';
    const wrapper = document.createElement('div');
    wrapper.id = 'pitch-canvas-wrapper';

    if (this.pitchFit) {
      wrapper.style.cssText = 'position:fixed;inset:0;z-index:900;background:#0a1a0a;display:flex;flex-direction:column;';
      document.body.classList.add('pitch-fit-active');
    } else {
      wrapper.style.cssText = 'display:flex;flex-direction:column;background:#0a1a0a;border-radius:14px;overflow:hidden;margin-bottom:14px;';
      document.body.classList.remove('pitch-fit-active');
    }

    // ── canvas container (gives the canvas its size) ──────────────────────────
    const canvasPart = document.createElement('div');
    canvasPart.style.cssText = this.pitchFit
      ? 'flex:1;position:relative;overflow:hidden;'
      : `position:relative;width:100%;${landscape ? 'aspect-ratio:16/9;' : 'aspect-ratio:9/16;max-height:60vh;'}`;

    // ── canvas ───────────────────────────────────────────────────────────────
    const canvas = document.createElement('canvas');
    canvas.id = 'pitch-canvas';
    canvas.style.cssText = `position:absolute;inset:0;width:100%;height:100%;cursor:grab;touch-action:none;`;
    canvasPart.appendChild(canvas);

    // ── top strip: bench-only (1 session / partial) ────────────────────────
    const topStrip = this._buildTopStrip();
    wrapper.appendChild(topStrip);

    // ── middle row: qualified panel | pitch canvas | zero-session panel ──────
    const middleRow = document.createElement('div');
    middleRow.id = 'pitch-middle-row';
    middleRow.style.cssText = 'display:flex;flex-direction:row;flex:1;min-height:0;overflow:hidden;';

    const qualPanel = this._buildQualifiedPanel();
    qualPanel.style.borderRight = '1px solid rgba(255,255,255,0.08)';

    const zeroPanel = this._buildZeroSessionPanel();
    zeroPanel.style.borderLeft = '1px solid rgba(255,255,255,0.08)';

    middleRow.appendChild(qualPanel);
    middleRow.appendChild(canvasPart);
    middleRow.appendChild(zeroPanel);
    wrapper.appendChild(middleRow);

    // ── bottom bar ────────────────────────────────────────────────────────────
    const bar = document.createElement('div');
    bar.id = 'pitch-bottom-bar';
    bar.style.cssText = 'flex-shrink:0;background:#000;border-top:1px solid rgba(255,255,255,0.1);';

    // Single scrollable row: bench chips + controls
    const ctrlRow = document.createElement('div');
    ctrlRow.style.cssText = 'display:flex;align-items:center;gap:5px;padding:4px 6px;overflow-x:auto;scrollbar-width:none;min-height:46px;border-top:2px solid rgba(59,130,246,0.35);';

    // ── Bench chips ─────────────────────────────────────────────
    Array.from(this._buildBenchStrip().childNodes).forEach(n => ctrlRow.appendChild(n));

    const mkDiv = () => { const d = document.createElement('div'); d.style.cssText = 'width:1px;align-self:stretch;background:rgba(59,130,246,0.3);margin:0 1px;flex-shrink:0;'; return d; };
    ctrlRow.appendChild(mkDiv());

    // ── Controls ─────────────────────────────────────────────────

    // Mode toggle (🔒 Formation / ✏️ Custom)
    const lockBtn = document.createElement('button');
    lockBtn.id = 'pitch-lock-btn';
    lockBtn.title = this.formationLocked ? 'Switch to custom placement' : 'Lock to formation';
    lockBtn.style.cssText = `padding:4px 9px;border-radius:7px;border:1px solid rgba(255,255,255,0.3);cursor:pointer;font-size:0.75rem;background:${this.formationLocked ? 'rgba(59,130,246,0.8)' : 'rgba(168,85,247,0.7)'};color:#fff;white-space:nowrap;`;
    lockBtn.textContent = this.formationLocked ? '🔒' : '✏️';
    ctrlRow.appendChild(lockBtn);

    // Formation dropdown (inline, compact)
    const formSelect = document.createElement('select');
    formSelect.id = 'pitch-formation-select';
    formSelect.style.cssText = 'width:90px;flex-shrink:0;padding:4px 6px;border-radius:7px;border:1px solid rgba(255,255,255,0.2);background:rgba(255,255,255,0.07);color:#fff;font-size:0.78rem;cursor:pointer;';
    for (const f of this.formations) {
      const opt = document.createElement('option');
      opt.value = f.id;
      opt.textContent = f.name;
      if (this.selectedFormation?.id === f.id) opt.selected = true;
      formSelect.appendChild(opt);
    }
    formSelect.addEventListener('change', () => {
      const id = parseInt(formSelect.value);
      this.selectedFormation = this.formations.find(f => f.id === id) || this.formations[0];
      if (!this.formationLocked) this.formationLocked = true;
      this.customPositions = null;
      this.renderPitchView();
    });
    ctrlRow.appendChild(formSelect);

    // No drag-mode toggle needed — empty slots auto-move the slot, filled chips auto-move the player

    // Orientation toggle (icon only)
    const orientBtn2 = document.createElement('button');
    orientBtn2.id = 'pitch-orient-btn';
    orientBtn2.title = landscape ? 'Switch to portrait' : 'Switch to landscape';
    orientBtn2.style.cssText = 'padding:4px 9px;border-radius:7px;border:1px solid rgba(255,255,255,0.3);background:transparent;color:#fff;font-size:0.78rem;cursor:pointer;';
    orientBtn2.textContent = landscape ? '↕' : '↔';
    ctrlRow.appendChild(orientBtn2);

    // Groups (icon only)
    const groupsBtn = document.createElement('button');
    groupsBtn.id = 'pitch-groups-btn';
    groupsBtn.title = 'Groups';
    groupsBtn.style.cssText = 'padding:4px 9px;border-radius:7px;border:1px solid rgba(255,255,255,0.3);background:rgba(255,255,255,0.07);color:#fff;font-size:0.78rem;cursor:pointer;';
    groupsBtn.textContent = '👥';
    ctrlRow.appendChild(groupsBtn);

    // Exit fullscreen (icon only)
    const exitBtn = document.createElement('button');
    exitBtn.id = 'pitch-fit-btn';
    exitBtn.title = 'Exit fullscreen';
    exitBtn.style.cssText = 'padding:4px 9px;border-radius:7px;border:1px solid rgba(255,255,255,0.3);background:transparent;color:#fff;font-size:0.78rem;cursor:pointer;';
    exitBtn.textContent = '⊠';
    ctrlRow.appendChild(exitBtn);

    // Count indicator
    const countInfo = document.createElement('span');
    countInfo.style.cssText = 'color:rgba(255,255,255,0.4);font-size:0.75rem;white-space:nowrap;';
    countInfo.textContent = `${this.zones.starting.filter(Boolean).length}/11`;
    ctrlRow.appendChild(countInfo);

    // GroupMe sync status pill
    const syncStatus = this.groupmeSync || {};
    const syncBad = this.syncFailed ||
      syncStatus.status === 'very_stale' ||
      syncStatus.status === 'not_synced' ||
      !syncStatus.hasLinkedEvent;
    const syncWarn = !syncBad && syncStatus.status === 'stale';
    if (syncBad || syncWarn) {
      const syncPill = document.createElement('button');
      syncPill.title = this.syncFailed ? 'GroupMe sync failed — tap to retry'
        : !syncStatus.hasLinkedEvent ? 'No GroupMe event linked'
        : syncStatus.status === 'not_synced' ? 'RSVPs not synced yet — tap to sync'
        : 'RSVP data is stale — tap to sync';
      syncPill.style.cssText = `padding:2px 7px;border-radius:10px;border:none;cursor:pointer;font-size:0.72rem;font-weight:600;white-space:nowrap;background:${syncBad ? 'rgba(239,68,68,0.85)' : 'rgba(245,158,11,0.75)'};color:#fff;`;
      syncPill.textContent = syncBad ? '⚠ No Sync' : '⏳ Stale';
      syncPill.addEventListener('click', async () => {
        syncPill.textContent = '⟳';
        syncPill.disabled = true;
        await this.syncThenLoad();
      });
      ctrlRow.appendChild(syncPill);
    }

    // Data sync button (always shown)
    const dataSyncBtn = document.createElement('button');
    dataSyncBtn.id = 'pitch-data-sync-btn';
    dataSyncBtn.title = 'Data sync status';
    dataSyncBtn.style.cssText = 'padding:4px 9px;border-radius:7px;border:1px solid rgba(255,255,255,0.3);background:rgba(255,255,255,0.07);color:#fff;font-size:0.78rem;cursor:pointer;margin-left:auto;';
    dataSyncBtn.textContent = this._leaguesSyncData ? (this._syncAllGreen ? '🟢' : '🔴') : '📡';
    dataSyncBtn.addEventListener('click', () => this._openPitchSyncModal());
    ctrlRow.appendChild(dataSyncBtn);

    bar.appendChild(ctrlRow);
    bar.appendChild(this._buildSyncRow());
    wrapper.appendChild(bar);

    container.appendChild(wrapper);

    // ── hit-test registry (rebuilt each frame when state changes) ────────────
    this._pitchHitZones = []; // [{ x,y,r, type:'chip'|'slot', payload }]

    // ── animation state ───────────────────────────────────────────────────────
    let lastW = 0, lastH = 0;
    const chipAnim = new Map(); // playerId/slotKey → { scale, targetScale, pulse, t }

    const getAnim = (key) => {
      if (!chipAnim.has(key)) chipAnim.set(key, { scale: 1, targetScale: 1, pulse: 0, t: 0 });
      return chipAnim.get(key);
    };

    // ── game loop ─────────────────────────────────────────────────────────────
    const GRID_SNAP = 5; // snap to 5-unit grid in canonical 0-100 space
    const snapGrid = (v) => Math.round(v / GRID_SNAP) * GRID_SNAP;

    let dragState = null; // { slotIndex, x, y (canonical), startCanvasX, startCanvasY, moved }

    const loop = () => {
      this._pitchRafId = requestAnimationFrame(loop);

      const W = canvas.offsetWidth;
      const H = canvas.offsetHeight;
      if (W < 10 || H < 10) return;

      // Resize backing buffer if needed
      if (canvas.width !== W || canvas.height !== H) {
        canvas.width  = W;
        canvas.height = H;
        lastW = W; lastH = H;
      }

      const ctx = canvas.getContext('2d');
      ctx.clearRect(0, 0, W, H);

      // ── draw pitch background ─────────────────────────────────────────────
      this._drawPitchField(ctx, W, H, landscape);

      // ── resolve positions & draw chips ────────────────────────────────────
      // In formation-locked mode: use formation positions.
      // In custom mode: use this.customPositions (initialised from formation if not set).
      const formPositions = this.getPositionsForFormation(this.selectedFormation?.code || '4-3-3');

      // Seed customPositions from formation the first time we enter custom mode
      if (!this.formationLocked && !this.customPositions) {
        this.customPositions = formPositions.map(p => ({ x: p.x, y: p.y, label: p.label }));
      }

      const positions = this.formationLocked
        ? formPositions
        : (this.customPositions || formPositions).map((cp, i) => ({
            x: cp.x, y: cp.y,
            label: cp.label || (formPositions[i]?.label ?? '')
          }));

      const hitZones = [];

      // Coordinate mapping: canonical (x=0-100 across, y=5 GK bottom .. 72 fwd top)
      // Portrait  → px = x*W/100,  py = (100-y)*H/100
      // Landscape → px = (100-y)*W/100, py = x*H/100
      const toCanvas = (cx, cy) => landscape
        ? [(100 - cy) / 100 * W, cx / 100 * H]
        : [cx / 100 * W, (100 - cy) / 100 * H];

      // Inverse: canvas px,py → canonical cx,cy
      const toCanonical = (px, py) => landscape
        ? [py / H * 100, 100 - px / W * 100]
        : [px / W * 100, 100 - py / H * 100];

      // Chip radius scales with smaller dimension
      const baseR = Math.min(W, H) * 0.024;

      // ── drag feedback overlay ─────────────────────────────────────────────
      if (dragState && dragState.moved) {
        const isDraggingEmpty = !this.zones.starting[dragState.slotIndex];
        if (isDraggingEmpty) {
          // Slot-move mode: show grid dots + snap ring
          ctx.fillStyle = 'rgba(255,255,255,0.08)';
          for (let gx = 0; gx <= 100; gx += GRID_SNAP) {
            for (let gy = GRID_SNAP; gy <= 90; gy += GRID_SNAP) {
              const [gpx, gpy] = toCanvas(gx, gy);
              ctx.beginPath(); ctx.arc(gpx, gpy, 1.5, 0, Math.PI * 2); ctx.fill();
            }
          }
          const sx = snapGrid(dragState.x), sy = snapGrid(dragState.y);
          const [spx, spy] = toCanvas(sx, sy);
          ctx.beginPath(); ctx.arc(spx, spy, baseR * 0.85, 0, Math.PI * 2);
          ctx.strokeStyle = 'rgba(255,255,255,0.5)'; ctx.lineWidth = 2;
          ctx.setLineDash([4, 3]); ctx.stroke(); ctx.setLineDash([]);
        } else {
          // Player-move mode: highlight nearest empty slot as snap target
          let nearestIdx = -1, nearestDist = Infinity;
          positions.forEach((p, idx) => {
            if (idx === dragState.slotIndex) return;
            const d = Math.hypot(p.x - dragState.x, p.y - dragState.y);
            if (d < nearestDist) { nearestDist = d; nearestIdx = idx; }
          });
          if (nearestIdx >= 0 && nearestDist < 20) {
            const [tx, ty] = toCanvas(positions[nearestIdx].x, positions[nearestIdx].y);
            ctx.beginPath(); ctx.arc(tx, ty, baseR * 1.5, 0, Math.PI * 2);
            ctx.strokeStyle = 'rgba(59,130,246,0.75)'; ctx.lineWidth = 3; ctx.stroke();
          }
        }
      }

      positions.forEach((pos, i) => {
        // If this slot is being dragged, use drag position instead
        const isDragging = dragState && dragState.slotIndex === i;
        const drawPos = isDragging ? dragState : pos;

        const playerId = this.zones.starting[i];
        const player   = playerId ? this.getPlayerById(playerId) : null;
        const key      = player ? `p${player.playerId}` : `s${i}`;
        const anim     = getAnim(key);
        const [px, py] = toCanvas(drawPos.x, drawPos.y);

        // Ease scale toward target
        anim.scale += (anim.targetScale - anim.scale) * 0.18;
        anim.t     += 0.04;

        const r = baseR * anim.scale * (isDragging ? 1.2 : 1);

        // Dragging chip: draw a ghost circle at original position
        if (isDragging) {
          const [opx, opy] = toCanvas(pos.x, pos.y);
          ctx.beginPath();
          ctx.arc(opx, opy, baseR * 0.8, 0, Math.PI * 2);
          ctx.strokeStyle = 'rgba(255,255,255,0.15)';
          ctx.lineWidth = 2;
          ctx.setLineDash([4, 4]);
          ctx.stroke();
          ctx.setLineDash([]);
        }

        if (player) {
          this._drawPlayerChip(ctx, px, py, r, player, pos.label, anim);
        } else {
          this._drawEmptySlot(ctx, px, py, r, pos.label, anim);
        }

        hitZones.push({ cx: px, cy: py, r: r + 6, type: player ? 'chip' : 'slot',
          playerId: player?.playerId, slotIndex: i, canonX: pos.x, canonY: pos.y });
      });

      this._pitchHitZones = hitZones;
      this._toCanonical = toCanonical;
    };

    // ── input handling ────────────────────────────────────────────────────────
    const getXY = (e) => {
      const rect = canvas.getBoundingClientRect();
      // pointer events have clientX/clientY directly
      return [e.clientX - rect.left, e.clientY - rect.top];
    };

    const DRAG_THRESHOLD = 8; // pixels before we consider it a drag

    // Track the last pointerdown hit zone + client coords for reliable tap detection
    let lastDownClient = { clientX: 0, clientY: 0 };
    let pendingHitZone = null; // hit zone saved on pointerDown, used on pointerUp

    const onPointerDown = (e) => {
      pendingHitZone = null;
      if (!this._toCanonical) return;
      const [cx, cy] = getXY(e);
      // Record client coords for popover anchor (works for both mouse and touch)
      const src = (e.touches && e.touches.length > 0) ? e.touches[0] : e;
      lastDownClient = { clientX: src.clientX, clientY: src.clientY };

      for (const hz of (this._pitchHitZones || [])) {
        const dx = cx - hz.cx, dy = cy - hz.cy;
        if (dx*dx + dy*dy <= hz.r * hz.r) {
          e.preventDefault(); // always prevent to stop ghost click on touch
          pendingHitZone = hz; // save for pointerUp tap detection
          // Always allow drag (formation mode = player swap; custom mode = slot move or player swap)
          dragState = {
            slotIndex: hz.slotIndex,
            x: hz.canonX, y: hz.canonY,
            startCanvasX: cx, startCanvasY: cy,
            moved: false
          };
          return;
        }
      }
    };

    const onPointerMove = (e) => {
      if (!dragState || !this._toCanonical) return;
      const [cx, cy] = getXY(e);
      const dx = cx - dragState.startCanvasX, dy = cy - dragState.startCanvasY;
      if (!dragState.moved && (dx*dx + dy*dy) > DRAG_THRESHOLD*DRAG_THRESHOLD) {
        dragState.moved = true;
        this._dismissPitchPopover();
      }
      if (dragState.moved) {
        const [canonX, canonY] = this._toCanonical(cx, cy);
        // Clamp to field area (leave a margin of ~5%)
        dragState.x = Math.max(3, Math.min(97, canonX));
        dragState.y = Math.max(2, Math.min(85, canonY));
        e.preventDefault();
      }
    };

    const onPointerUp = (e) => {
      if (dragState && dragState.moved) {
        if (!this._toCanonical) { dragState = null; return; }
        const i = dragState.slotIndex;
        const isDraggingEmpty = !this.zones.starting[i];

        if (isDraggingEmpty) {
          // Empty slot drag → move the slot position, snap to grid
          if (!this.customPositions) {
            this.customPositions = this.getPositionsForFormation(
              this.selectedFormation?.code || '4-3-3'
            ).map(p => ({ x: p.x, y: p.y, label: p.label }));
          }
          this.customPositions[i] = {
            x: snapGrid(dragState.x),
            y: snapGrid(dragState.y),
            label: this.customPositions[i]?.label || ''
          };
          this._scheduleSaveMeta();
        } else {
          // Filled chip drag → move the player freely; snap to nearest other slot if close
          let nearestIdx = -1, nearestDist = Infinity;
          positions.forEach((p, idx) => {
            if (idx === i) return;
            const d = Math.hypot(p.x - dragState.x, p.y - dragState.y);
            if (d < nearestDist) { nearestDist = d; nearestIdx = idx; }
          });
          if (nearestIdx >= 0 && nearestDist < 15) {
            // Snap: swap players between slots
            const tmp = this.zones.starting[i];
            this.zones.starting[i] = this.zones.starting[nearestIdx];
            this.zones.starting[nearestIdx] = tmp;
          } else {
            // Free move: update the player's canonical position AND the slot position
            const playerId = this.zones.starting[i];
            if (playerId) this.playerPositions[playerId] = { x: dragState.x, y: dragState.y };
            if (!this.customPositions) {
              this.customPositions = this.getPositionsForFormation(
                this.selectedFormation?.code || '4-3-3'
              ).map(p => ({ x: p.x, y: p.y, label: p.label }));
            }
            this.customPositions[i] = { x: dragState.x, y: dragState.y, label: this.customPositions[i]?.label || '' };
          }
          this._scheduleAutoSaveLineup();
          this._scheduleSaveMeta();
        }
        dragState = null;
        e.preventDefault();
        return;
      }

      // No drag (or locked): treat as tap — use saved hit zone from pointerDown
      dragState = null;
      const hz = pendingHitZone;
      pendingHitZone = null;
      if (!hz) { this._dismissPitchPopover(); return; }

      // Animate bounce
      const key = hz.type === 'chip' ? `p${hz.playerId}` : `s${hz.slotIndex}`;
      const anim = chipAnim.get(key);
      if (anim) { anim.targetScale = 1.35; setTimeout(() => { anim.targetScale = 1; }, 180); }

      this._dismissPitchPopover();
      const anchor = lastDownClient;
      if (hz.type === 'chip') {
        // Go directly to full edit modal — remove-from-pitch is inside
        this.openEditPlayerModal(hz.playerId, hz.slotIndex);
      } else {
        this.openSlotPicker(hz.slotIndex, anchor);
      }
      e.preventDefault();
    };

    // Use pointer events with capture so drags are tracked even outside the canvas
    canvas.addEventListener('pointerdown', (e) => {
      onPointerDown(e);
      if (dragState) canvas.setPointerCapture(e.pointerId);
    });
    canvas.addEventListener('pointermove', onPointerMove);
    canvas.addEventListener('pointerup', (e) => {
      if (dragState && dragState.moved) {
        const rect = canvas.getBoundingClientRect();
        const outside = e.clientX < rect.left || e.clientX > rect.right ||
                        e.clientY < rect.top  || e.clientY > rect.bottom;
        if (outside) {
          // Player dragged off canvas — remove from pitch back to pool
          const slotIdx = dragState.slotIndex;
          const playerId = this.zones.starting[slotIdx];
          if (playerId != null) {
            dragState = null;
            this.removePlayerFromAllZones(playerId);
            this.renderAllZones();
            this._scheduleAutoSaveLineup();
            e.preventDefault();
            return;
          }
        }
      }
      onPointerUp(e);
    });
    canvas.addEventListener('pointercancel', () => { dragState = null; });

    // Accept HTML5 drags from side-panel chips onto the canvas
    canvas.addEventListener('dragover', (e) => {
      if (e.dataTransfer.types.includes('text/player-id')) {
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
      }
    });
    canvas.addEventListener('drop', (e) => {
      const pid = parseInt(e.dataTransfer.getData('text/player-id'));
      if (!pid || !this._toCanonical) return;
      e.preventDefault();
      const rect = canvas.getBoundingClientRect();
      const rawX = (e.clientX - rect.left) / rect.width * 100;
      const rawY = (e.clientY - rect.top)  / rect.height * 100;
      const [canonX, canonY] = this._toCanonical(rawX, rawY);
      const dropX = Math.max(3, Math.min(97, canonX));
      const dropY = Math.max(2, Math.min(85, canonY));

      // Snap to nearest empty slot within 18 canonical units
      const positions = this._pitchHitZones || [];
      let snapIdx = -1, snapDist = 18;
      positions.forEach(hz => {
        if (hz.type !== 'slot') return; // only empty slots
        const d = Math.hypot(hz.canonX - dropX, hz.canonY - dropY);
        if (d < snapDist) { snapDist = d; snapIdx = hz.slotIndex; }
      });

      if (snapIdx >= 0) {
        // Place player directly into the snapped slot position
        const snapPos = this._pitchHitZones.find(hz => hz.slotIndex === snapIdx);
        this.movePlayerToPitch(pid, 'pool', snapPos.canonX, snapPos.canonY);
      } else {
        this.movePlayerToPitch(pid, 'pool', dropX, dropY);
      }
    });

    // Dismiss popover when tapping outside it
    const onOutsideTap = (e) => {
      if (this._activePitchPopover && !this._activePitchPopover.contains(e.target)) {
        this._dismissPitchPopover();
      }
    };
    document.addEventListener('pointerdown', onOutsideTap);

    loop();
    return wrapper;
  }

  // ── Draw grass field markings ─────────────────────────────────────────────
  _drawPitchField(ctx, W, H, landscape) {
    // Alternating grass stripes
    const stripes = landscape ? 10 : 8;
    for (let i = 0; i < stripes; i++) {
      const even = i % 2 === 0;
      ctx.fillStyle = even ? 'rgba(255,255,255,0.025)' : 'transparent';
      if (landscape) {
        ctx.fillRect(i * W / stripes, 0, W / stripes, H);
      } else {
        ctx.fillRect(0, i * H / stripes, W, H / stripes);
      }
    }

    // All markings in a normalised 0-1 space, then map to canvas
    // Field markings: top→bottom of pitch = y 0..1, left-right = x 0..1
    const M = (fx, fy) => landscape
      ? [fx * W, fy * H]
      : [fx * W, fy * H];

    // We define everything in pitch-space (top=0, bottom=1 along the play-direction)
    // then rotate if landscape: swap axes, mirror
    const pt = (fx, fy) => landscape ? [(1 - fy) * W, fx * H] : [fx * W, fy * H];
    const sc = (v) => landscape ? v * H : v * W; // scale across pitch
    const sl = (v) => landscape ? v * W : v * H; // scale along pitch

    const lw = Math.min(W, H) * 0.004;
    ctx.strokeStyle = 'rgba(255,255,255,0.55)';
    ctx.lineWidth = lw;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';

    // Outer boundary — flush to canvas edges (1% pad so stroke isn't clipped)
    this._pitchRect(ctx, pt, 0.01, 0.01, 0.98, 0.98, lw);

    // Halfway line
    const [hlx1, hly1] = pt(0.01, 0.5);
    const [hlx2, hly2] = pt(0.99, 0.5);
    ctx.beginPath(); ctx.moveTo(hlx1, hly1); ctx.lineTo(hlx2, hly2); ctx.stroke();

    // Centre circle
    const [ccx, ccy] = pt(0.5, 0.5);
    const ccr = sc(0.12);
    ctx.beginPath(); ctx.arc(ccx, ccy, ccr, 0, Math.PI * 2); ctx.stroke();
    // Centre dot
    ctx.fillStyle = 'rgba(255,255,255,0.5)';
    ctx.beginPath(); ctx.arc(ccx, ccy, lw * 2, 0, Math.PI * 2); ctx.fill();

    // Penalty areas — top/bottom edges share boundary goal line
    this._pitchRect(ctx, pt, 0.22, 0.01, 0.56, 0.18, lw); // top 18-yard box
    this._pitchRect(ctx, pt, 0.22, 0.81, 0.56, 0.18, lw); // bottom 18-yard box

    // Goal areas (six-yard boxes)
    this._pitchRect(ctx, pt, 0.34, 0.01, 0.32, 0.07, lw); // top
    this._pitchRect(ctx, pt, 0.34, 0.92, 0.32, 0.07, lw); // bottom

    // Goals — extra-thick white segment on the goal line only
    ctx.strokeStyle = 'rgba(255,255,255,0.95)';
    ctx.lineWidth = lw * 4;
    const [g1a, g1b] = pt(0.37, 0.01);
    const [g1c, g1d] = pt(0.63, 0.01);
    ctx.beginPath(); ctx.moveTo(g1a, g1b); ctx.lineTo(g1c, g1d); ctx.stroke();
    const [g2a, g2b] = pt(0.37, 0.99);
    const [g2c, g2d] = pt(0.63, 0.99);
    ctx.beginPath(); ctx.moveTo(g2a, g2b); ctx.lineTo(g2c, g2d); ctx.stroke();
    ctx.strokeStyle = 'rgba(255,255,255,0.55)';
    ctx.lineWidth = lw;

    // Penalty spots
    const spotR = lw * 2;
    const [ts1x, ts1y] = pt(0.5, 0.14);
    const [ts2x, ts2y] = pt(0.5, 0.86);
    ctx.fillStyle = 'rgba(255,255,255,0.55)';
    ctx.beginPath(); ctx.arc(ts1x, ts1y, spotR, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.arc(ts2x, ts2y, spotR, 0, Math.PI * 2); ctx.fill();

    // Corner arcs
    const cr = sc(0.04);
    [[0.01, 0.01], [0.99, 0.01], [0.01, 0.99], [0.99, 0.99]].forEach(([fx, fy]) => {
      const [cx2, cy2] = pt(fx, fy);
      const left  = cx2 < W / 2;
      const top   = cy2 < H / 2;
      const a1 = left ? (top ? 0          : Math.PI * 1.5) : (top ? Math.PI / 2  : Math.PI);
      const a2 = left ? (top ? Math.PI/2  : Math.PI * 2  ) : (top ? Math.PI      : Math.PI * 1.5);
      ctx.beginPath(); ctx.arc(cx2, cy2, cr, a1, a2); ctx.stroke();
    });
  }

  _pitchRect(ctx, pt, fx, fy, fw, fh, lw) {
    const [x1, y1] = pt(fx, fy);
    const [x2, y2] = pt(fx + fw, fy);
    const [x3, y3] = pt(fx + fw, fy + fh);
    const [x4, y4] = pt(fx, fy + fh);
    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    ctx.lineTo(x3, y3);
    ctx.lineTo(x4, y4);
    ctx.closePath();
    ctx.stroke();
  }

  // ── Draw a player chip ────────────────────────────────────────────────────
  _drawPlayerChip(ctx, px, py, r, player, posLabel, anim) {
    const color     = this._eligColor(player);
    const firstName = player.firstName || '';
    const lastName  = player.lastName  || '';
    const initials  = (firstName[0] || '') + (lastName[0] || '') || '?';
    const prac      = `${player.sessionsAttended || 0}/${player.requiredSessions ?? this.policy?.lookbackCount ?? '?'}`;

    // Subtle pulse glow for priority starters
    if (player.eligibilityStatus === 'priority_starter') {
      const glow = Math.sin(anim.t) * 0.25 + 0.35;
      ctx.shadowColor  = '#ffffff';
      ctx.shadowBlur   = r * 0.9 * glow;
    }

    // Drop shadow
    ctx.shadowColor = 'rgba(0,0,0,0.6)';
    ctx.shadowBlur  = 8;

    // Circle body — royal blue fill
    ctx.beginPath();
    ctx.arc(px, py, r, 0, Math.PI * 2);
    ctx.fillStyle = '#1a3dbd';
    ctx.fill();

    // White border (Lighthouse colours)
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth   = r * 0.14;
    ctx.stroke();

    ctx.shadowBlur = 0;
    ctx.shadowColor = 'transparent';

    // Initials inside chip
    ctx.fillStyle    = '#ffd700';
    ctx.font         = `bold ${r * 0.72}px system-ui,sans-serif`;
    ctx.textAlign    = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(initials, px, py);

    // Designated badge (gold star top-right)
    if (player.isDesignated) {
      ctx.fillStyle = '#fbbf24';
      ctx.font      = `${r * 0.45}px system-ui,sans-serif`;
      ctx.fillText('★', px + r * 0.62, py - r * 0.62);
    }

    // 2-club badge (orange dot top-left)
    if ((player.numClubs || 1) > 1) {
      ctx.beginPath();
      ctx.arc(px - r * 0.65, py - r * 0.65, r * 0.22, 0, Math.PI * 2);
      ctx.fillStyle = '#f97316';
      ctx.fill();
      ctx.fillStyle = '#fff';
      ctx.font = `bold ${r * 0.28}px system-ui,sans-serif`;
      ctx.textBaseline = 'middle';
      ctx.fillText('2', px - r * 0.65, py - r * 0.65);
    }

    // Injured badge: red cross bottom-left
    if (player.isInjured) {
      ctx.beginPath();
      ctx.arc(px - r * 0.65, py + r * 0.65, r * 0.26, 0, Math.PI * 2);
      ctx.fillStyle = '#ef4444';
      ctx.fill();
      ctx.fillStyle = '#fff';
      ctx.font = `bold ${r * 0.34}px system-ui,sans-serif`;
      ctx.textBaseline = 'middle';
      ctx.textAlign = 'center';
      ctx.fillText('+', px - r * 0.65, py + r * 0.65);
    }

    // Suspended badge: orange exclamation bottom-right
    if (player.isSuspendedLeague || player.isSuspendedInhouse) {
      ctx.beginPath();
      ctx.arc(px + r * 0.65, py + r * 0.65, r * 0.26, 0, Math.PI * 2);
      ctx.fillStyle = player.isSuspendedLeague ? '#dc2626' : '#f59e0b';
      ctx.fill();
      ctx.fillStyle = '#fff';
      ctx.font = `bold ${r * 0.32}px system-ui,sans-serif`;
      ctx.textBaseline = 'middle';
      ctx.textAlign = 'center';
      ctx.fillText('!', px + r * 0.65, py + r * 0.65);
    }

    // First name ABOVE chip
    ctx.font         = `${r * 0.56}px system-ui,sans-serif`;
    ctx.fillStyle    = 'rgba(255,255,255,0.92)';
    ctx.shadowColor  = 'rgba(0,0,0,0.9)';
    ctx.shadowBlur   = 4;
    ctx.textBaseline = 'middle';
    ctx.fillText(firstName, px, py - r - r * 0.58);

    // Last name BELOW chip
    ctx.font         = `${r * 0.56}px system-ui,sans-serif`;
    ctx.fillStyle    = 'rgba(255,255,255,0.92)';
    ctx.fillText(lastName, px, py + r + r * 0.58);

    // Position + sessions (smaller, dimmer, further below)
    ctx.font         = `${r * 0.42}px system-ui,sans-serif`;
    ctx.fillStyle    = 'rgba(255,255,255,0.45)';
    ctx.fillText(`${posLabel} · ${prac}`, px, py + r + r * 1.22);
    ctx.shadowBlur   = 0;
  }

  // ── Draw an empty slot ────────────────────────────────────────────────────
  _drawEmptySlot(ctx, px, py, r, posLabel, anim) {
    // Dashed circle
    ctx.save();
    ctx.setLineDash([r * 0.28, r * 0.18]);
    ctx.strokeStyle = 'rgba(255,255,255,0.35)';
    ctx.lineWidth   = r * 0.1;
    ctx.beginPath();
    ctx.arc(px, py, r, 0, Math.PI * 2);
    ctx.stroke();
    ctx.restore();

    // + symbol
    ctx.fillStyle    = 'rgba(255,255,255,0.3)';
    ctx.font         = `${r * 0.9}px system-ui,sans-serif`;
    ctx.textAlign    = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText('+', px, py);

    // Position label
    ctx.font      = `${r * 0.38}px system-ui,sans-serif`;
    ctx.fillStyle = 'rgba(255,255,255,0.35)';
    ctx.shadowColor = 'rgba(0,0,0,0.8)';
    ctx.shadowBlur  = 3;
    ctx.fillText(posLabel, px, py + r + r * 0.55);
    ctx.shadowBlur  = 0;
  }

  renderPitchView() {
    const container = this.find('#zone-sections');
    if (!container) return;
    container.innerHTML = '';
    this._stopPitchLoop();
    // Always full-screen
    this.pitchFit = true;
    document.body.classList.add('pitch-fit-active');
    this._startPitchCanvas(container);
  }

  togglePitchFit() {
    // Exit to the list view
    this.switchView('list');
  }

  _eligColor(player) {
    switch (this._eligState(player)) {
      case 'green':  return '#22c55e';
      case 'yellow': return '#eab308';
      case 'blue':   return '#60a5fa';
      case 'orange': return '#f97316';
      default:       return '#ef4444';
    }
  }

  // ── Build a single chip element for side/top panels ──────────────────────
  _buildPanelChipEl(player, zone) {
    const eligColor = this._eligColor(player);
    const firstName = player.firstName || '';
    const lastName  = player.lastName  || '';
    const initials  = (firstName[0] || '') + (lastName[0] || '') || '?';
    const starBadge = player.isDesignated
      ? '<span style="color:#fbbf24;font-size:0.4rem;position:absolute;top:-1px;right:-1px;">★</span>' : '';
    const chip = document.createElement('div');
    chip.className = 'shelf-chip';
    chip.dataset.playerId = player.playerId;
    chip.dataset.zone = zone;
    chip.draggable = true;
    chip.style.cssText = 'display:flex;flex-direction:column;align-items:center;justify-content:center;flex-shrink:0;cursor:grab;padding:3px 2px;border-radius:6px;gap:1px;background:rgba(255,255,255,0.04);min-width:52px;touch-action:manipulation;user-select:none;';
    chip.innerHTML = `
      <div style="font-size:0.58rem;color:rgba(255,255,255,0.9);white-space:nowrap;max-width:50px;overflow:hidden;text-overflow:ellipsis;text-align:center;">${firstName}</div>
      <div style="position:relative;width:28px;height:28px;border-radius:50%;background:${eligColor};display:flex;align-items:center;justify-content:center;font-size:0.65rem;font-weight:700;color:#fff;border:1.5px solid rgba(255,255,255,0.65);">${initials}${starBadge}</div>
      <div style="font-size:0.58rem;color:rgba(255,255,255,0.9);white-space:nowrap;max-width:50px;overflow:hidden;text-overflow:ellipsis;text-align:center;">${lastName}</div>
    `;
    chip.addEventListener('dragstart', (e) => {
      e.dataTransfer.effectAllowed = 'move';
      e.dataTransfer.setData('text/player-id', String(player.playerId));
      chip.style.opacity = '0.4';
    });
    chip.addEventListener('dragend', () => {
      chip.style.opacity = '';
    });
    chip.addEventListener('click', (e) => {
      e.stopPropagation();
      this._dismissPitchPopover();
      this.openEditPlayerModal(player.playerId);
    });
    return chip;
  }

  // ── Build a vertical side panel (bench or alternates) ────────────────────
  _buildSidePlayerPanel(playerIds, color, zone, label) {
    const panel = document.createElement('div');
    panel.style.cssText = `width:52px;flex-shrink:0;display:flex;flex-direction:column;align-items:center;overflow-y:auto;overflow-x:hidden;background:rgba(0,0,0,0.25);padding:4px 2px;gap:3px;scrollbar-width:none;`;
    const lbl = document.createElement('div');
    lbl.style.cssText = `font-size:0.6rem;color:${color};text-align:center;padding:3px 0;text-transform:uppercase;letter-spacing:0.05em;font-weight:700;flex-shrink:0;`;
    lbl.textContent = label;
    panel.appendChild(lbl);
    const players = playerIds.map(id => this.getPlayerById(id)).filter(Boolean);
    for (const p of players) {
      panel.appendChild(this._buildPanelChipEl(p, zone));
    }
    if (players.length === 0) {
      const empty = document.createElement('div');
      empty.style.cssText = 'font-size:0.42rem;color:rgba(255,255,255,0.18);text-align:center;padding:6px 2px;';
      empty.textContent = '—';
      panel.appendChild(empty);
    }
    return panel;
  }

  // ── Build the top strip: APSL-eligible unassigned players ────────────────
  _buildAvailableStrip(players, label, borderSide) {
    const strip = document.createElement('div');
    const border = borderSide === 'top'
      ? 'border-bottom:1px solid rgba(255,255,255,0.07);'
      : 'border-top:1px solid rgba(255,255,255,0.07);';
    strip.style.cssText = `display:flex;flex-direction:row;align-items:center;overflow-x:auto;overflow-y:hidden;background:rgba(0,0,0,0.28);${border}padding:4px 6px;gap:4px;flex-shrink:0;min-height:60px;scrollbar-width:none;`;
    const lbl = document.createElement('span');
    lbl.style.cssText = 'font-size:0.65rem;color:rgba(255,255,255,0.35);text-transform:uppercase;letter-spacing:0.06em;white-space:nowrap;flex-shrink:0;padding-right:4px;';
    lbl.textContent = label;
    strip.appendChild(lbl);
    if (players.length === 0) {
      const empty = document.createElement('span');
      empty.style.cssText = 'color:rgba(255,255,255,0.15);font-size:0.7rem;padding:0 4px;align-self:center;';
      empty.textContent = '—';
      strip.appendChild(empty);
    } else {
      for (const p of players) {
        strip.appendChild(this._buildPanelChipEl(p, 'pool'));
      }
    }
    return strip;
  }

  // Top strip: 4 labelled segments (left→right):
  //   1. blue   – RSVP yes, 0 sessions
  //   2. yellow – RSVP yes + partial (bench_only)
  //   3. orange – met threshold, no RSVP
  //   4. dim    – partial practice, no RSVP
  _buildTopStrip() {
    const allZoned = new Set([...this.zones.starting, ...this.zones.bench, ...this.zones.alternates]);
    const pool = this.players.filter(p => !allZoned.has(p.playerId));

    const metPrac   = (p) => p.eligibilityStatus === 'priority_starter' || p.eligibilityStatus === 'eligible_starter';
    const partPrac  = (p) => p.eligibilityStatus === 'bench_only';

    const segments = [
      { color: '#60a5fa', label: 'RSVP only',          players: this._rankPlayers(pool.filter(p =>  p.matchRsvp === 'yes' && !metPrac(p) && !partPrac(p))) },
      { color: '#eab308', label: 'RSVP + partial',     players: this._rankPlayers(pool.filter(p =>  p.matchRsvp === 'yes' && partPrac(p))) },
      { color: '#f97316', label: 'Full prac, no RSVP', players: this._rankPlayers(pool.filter(p =>  p.matchRsvp !== 'yes' && metPrac(p))) },
      { color: '#9ca3af', label: 'Partial, no RSVP',   players: this._rankPlayers(pool.filter(p =>  p.matchRsvp !== 'yes' && partPrac(p))) },
    ];

    const strip = document.createElement('div');
    strip.style.cssText = 'display:flex;flex-direction:row;align-items:stretch;overflow-x:auto;overflow-y:hidden;background:rgba(0,0,0,0.28);border-bottom:1px solid rgba(255,255,255,0.07);flex-shrink:0;min-height:62px;scrollbar-width:none;';

    let anyContent = false;
    for (const seg of segments) {
      if (seg.players.length === 0) continue;
      anyContent = true;

      const group = document.createElement('div');
      group.style.cssText = `display:flex;flex-direction:row;align-items:center;gap:3px;padding:4px 6px;border-right:1px solid rgba(255,255,255,0.06);flex-shrink:0;`;

      const lbl = document.createElement('span');
      lbl.style.cssText = `font-size:0.55rem;color:${seg.color};text-transform:uppercase;letter-spacing:0.05em;white-space:nowrap;flex-shrink:0;writing-mode:vertical-rl;transform:rotate(180deg);padding:0 2px;opacity:0.8;`;
      lbl.textContent = seg.label;
      group.appendChild(lbl);

      for (const p of seg.players) {
        group.appendChild(this._buildPanelChipEl(p, 'pool'));
      }
      strip.appendChild(group);
    }

    if (!anyContent) {
      strip.style.minHeight = '0';
      strip.style.display = 'none';
    }

    return strip;
  }

  // Left panel: green only — RSVP yes + met practice threshold
  _buildQualifiedPanel() {
    const allZoned = new Set([...this.zones.starting, ...this.zones.bench, ...this.zones.alternates]);
    const qualified = this._rankPlayers(
      this.players.filter(p =>
        !allZoned.has(p.playerId) &&
        p.matchRsvp === 'yes' &&
        (p.eligibilityStatus === 'priority_starter' || p.eligibilityStatus === 'eligible_starter')
      )
    );
    return this._buildSidePlayerPanel(qualified.map(p => p.playerId), '#22c55e', 'pool', '✓');
  }

  // Right panel: 0 sessions AND no game RSVP
  _buildZeroSessionPanel() {
    const allZoned = new Set([...this.zones.starting, ...this.zones.bench, ...this.zones.alternates]);
    const zero = this._rankPlayers(
      this.players.filter(p =>
        !allZoned.has(p.playerId) &&
        (p.sessionsAttended || 0) === 0 &&
        p.matchRsvp !== 'yes'
      )
    );
    return this._buildSidePlayerPanel(zero.map(p => p.playerId), '#6b7280', 'pool', '0');
  }

  // Bottom strip: assigned bench players
  _buildBenchStrip() {
    const maxBench = this.rosterSize - 11; // 9 for 20-man, 7 for 18-man
    const bench = this.zones.bench.slice(0, maxBench).map(id => this.getPlayerById(id)).filter(Boolean);

    // ── outer wrapper: bench + sync info row ─────────────────────────────────
    const wrapper = document.createElement('div');
    wrapper.style.cssText = 'flex-shrink:0;border-top:2px solid rgba(59,130,246,0.4);background:rgba(0,0,0,0.35);';

    // ── single row: bench chips + sync cards ─────────────────────────────────
    const row = document.createElement('div');
    row.style.cssText = 'display:flex;flex-direction:row;align-items:center;overflow-x:auto;overflow-y:hidden;padding:4px 6px;gap:4px;min-height:62px;scrollbar-width:none;';
    const lbl = document.createElement('span');
    lbl.style.cssText = 'font-size:0.65rem;color:rgba(59,130,246,0.7);text-transform:uppercase;letter-spacing:0.06em;white-space:nowrap;flex-shrink:0;padding-right:2px;';
    lbl.textContent = `🪑 ${bench.length}/${maxBench}`;
    row.appendChild(lbl);
    if (bench.length === 0) {
      const empty = document.createElement('span');
      empty.style.cssText = 'color:rgba(255,255,255,0.15);font-size:0.7rem;padding:0 4px;';
      empty.textContent = '—';
      row.appendChild(empty);
    } else {
      for (const p of bench) row.appendChild(this._buildPanelChipEl(p, 'bench'));
    }
    wrapper.appendChild(row);
    return wrapper;
  }

  _buildSyncRow() {
    const syncRow = document.createElement('div');
    syncRow.style.cssText = 'display:flex;flex-direction:row;align-items:center;overflow-x:auto;overflow-y:hidden;padding:3px 6px 4px;gap:4px;scrollbar-width:none;border-top:1px solid rgba(59,130,246,0.2);flex-shrink:0;';

    const fmtTs = (s) => {
      if (!s) return '';
      const d = new Date(s.replace(' ', 'T'));
      if (isNaN(d)) return '';
      const h = d.getHours(), min = d.getMinutes(), ap = h >= 12 ? 'pm' : 'am';
      return `${d.getMonth()+1}/${d.getDate()} ${h%12||12}${min ? ':'+String(min).padStart(2,'0') : ''}${ap}`;
    };
    const fmtTime = (t) => {
      if (!t) return '';
      const [hh, mm] = t.split(':').map(Number);
      return `${hh%12||12}${mm ? ':'+String(mm).padStart(2,'0') : ''}${hh >= 12 ? 'pm' : 'am'}`;
    };
    const mkCard = (label, eventDt, dot, syncTs, onSync) => {
      const card = document.createElement('div');
      card.style.cssText = 'flex-shrink:0;display:flex;flex-direction:row;align-items:center;gap:5px;background:rgba(30,80,160,0.25);border:1px solid rgba(80,140,255,0.35);border-radius:6px;padding:3px 8px;cursor:pointer;white-space:nowrap;';
      card.innerHTML =
        `<span style="font-size:1rem;line-height:1;">${dot}</span>` +
        `<span style="font-size:0.72rem;color:#7ec8ff;font-weight:700;">${label}${eventDt ? ' <span style="color:#c8e0ff;font-weight:400;">' + eventDt + '</span>' : ''}</span>` +
        (syncTs ? `<span style="font-size:0.65rem;color:#ffe066;">${syncTs}</span>` : '');
      card.addEventListener('click', onSync);
      return card;
    };

    const teamId = this.navigation.context.lineupTeamId || this.navigation.context.team?.id;
    const matchId = this.navigation.context.match?.id;
    const dayAbbrev = { sunday:'Su', monday:'Mo', tuesday:'Tu', wednesday:'We', thursday:'Th', friday:'Fr', saturday:'Sa' };
    const now = Date.now();

    const leagueData = this._leaguesSyncData;
    const trainingChat = leagueData?.groupme?.find(c => c.chatType === 5) || leagueData?.groupme?.find(c => c.chatType === 3);
    const trainSyncAge = trainingChat?.lastSyncedAt ? now - new Date(trainingChat.lastSyncedAt).getTime() : Infinity;
    const trainSyncDot = trainSyncAge < 24*60*60*1000 ? '🟢' : trainSyncAge < 48*60*60*1000 ? '🟡' : '🔴';
    const trainSyncTime = fmtTs(trainingChat?.lastSyncedAt || '');

    for (const evt of (this.trainingEvents || [])) {
      const t = evt.title.toLowerCase();
      const day = Object.entries(dayAbbrev).find(([d]) => t.includes(d))?.[1] || evt.eventDate.slice(5, 10);
      const isPickup = t.includes('pickup');
      const label = isPickup ? '⚽P' : day;
      const going = evt.goingCount ?? 0;
      const evtDt = fmtTs(evt.startAt || '') || evt.eventDate.slice(5, 10);
      const trainSyncTs = (going > 0 ? going + '✓ ' : '') + (trainSyncTime || 'not synced');
      syncRow.appendChild(mkCard(label, evtDt, trainSyncDot, trainSyncTs, () => {
        this._openEventRsvpModal({ type: 'training', chatEventId: evt.id, title: evt.title, startAt: evt.startAt, eventDate: evt.eventDate, teamId });
      }));
    }

    const gs = this.groupmeSync || {};
    const rsvpOk = gs.hasLinkedEvent && gs.status === 'fresh';
    const rsvpWarn = gs.hasLinkedEvent && gs.status === 'stale';
    const gameDot = rsvpOk ? '🟢' : rsvpWarn ? '🟡' : '🔴';
    const gameTime = fmtTs(gs.lastSync || '');
    const matchDate = this.matchInfo?.date ? this.matchInfo.date.slice(5, 10) : 'Game';
    const gameEvtDt = fmtTime(this.matchInfo?.time || '');
    const gameGoing = gs.goingCount ?? 0;
    const gameSyncTs = !gs.hasLinkedEvent ? 'no event' : (gameGoing > 0 ? gameGoing + '✓ ' : '') + (gameTime || '?');
    syncRow.appendChild(mkCard(matchDate, gameEvtDt, gameDot, gameSyncTs, () => {
      this._openEventRsvpModal({ type: 'game', matchId, title: matchDate, teamId });
    }));

    return syncRow;
  }

  async _openEventRsvpModal({ type, chatEventId, matchId, title, startAt, eventDate, teamId }) {
    document.getElementById('event-rsvp-modal')?.remove();

    const modal = document.createElement('div');
    modal.id = 'event-rsvp-modal';
    modal.style.cssText = 'position:fixed;inset:0;z-index:1200;display:flex;align-items:flex-end;';
    modal.innerHTML = `
      <div style="position:absolute;inset:0;background:rgba(0,0,0,0.65);" id="erm-backdrop"></div>
      <div id="erm-sheet" style="position:relative;width:100%;max-height:85vh;background:#111827;border-radius:16px 16px 0 0;display:flex;flex-direction:column;z-index:1;">
        <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 16px 10px;border-bottom:1px solid rgba(255,255,255,0.1);flex-shrink:0;">
          <span id="erm-title" style="font-size:0.9rem;font-weight:700;color:#fff;">Loading...</span>
          <button id="erm-close" style="background:none;border:none;color:rgba(255,255,255,0.6);font-size:1.2rem;cursor:pointer;padding:2px 8px;">✕</button>
        </div>
        <div id="erm-actions" style="display:flex;gap:8px;padding:10px 16px;border-bottom:1px solid rgba(255,255,255,0.08);flex-shrink:0;"></div>
        <div id="erm-body" style="overflow-y:auto;padding:0 0 24px;"><div style="padding:24px;color:rgba(255,255,255,0.5);text-align:center;">Loading RSVPs...</div></div>
      </div>`;

    modal.querySelector('#erm-backdrop').addEventListener('click', () => modal.remove());
    modal.querySelector('#erm-close').addEventListener('click', () => modal.remove());
    document.body.appendChild(modal);

    const fmtSAt = (s) => {
      if (!s) return '';
      const d = new Date(s.includes('T') ? s : s.replace(' ', 'T'));
      if (isNaN(d)) return '';
      const mo = d.getMonth()+1, dy = d.getDate(), h = d.getHours(), m = d.getMinutes(), ap = h >= 12 ? 'pm' : 'am';
      return `${mo}/${dy} ${h%12||12}${m ? ':'+String(m).padStart(2,'0') : ''}${ap}`;
    };
    const dotFor = s => s==='yes' ? '🟢' : s==='no' ? '🔴' : s==='maybe' ? '🟡' : '❔';

    // Sync button
    const actionsDiv = modal.querySelector('#erm-actions');
    const syncBtn = document.createElement('button');
    syncBtn.style.cssText = 'flex:1;padding:8px;border-radius:8px;border:none;background:rgba(99,102,241,0.7);color:#fff;font-size:0.85rem;font-weight:600;cursor:pointer;';
    syncBtn.textContent = type === 'game' ? '🔄 Sync Game RSVPs' : '🔄 Sync Training RSVPs';
    syncBtn.addEventListener('click', async () => {
      syncBtn.disabled = true; syncBtn.textContent = '⏳ Syncing...';
      try {
        const url = type === 'game'
          ? `/api/groupme/sync-match/${matchId}?teamId=${teamId}`
          : `/api/groupme/sync-calendar/${teamId}`;
        const r = await this.auth.fetch(url, { method: 'POST' });
        const rd = await r.json();
        if (rd.success) {
          this.showLineupToast('✅ Synced');
          modal.remove();
          await this.loadLeaguesSyncStatus();
          await this.loadEligibilityData();
        } else { syncBtn.disabled = false; syncBtn.textContent = '🔄 Sync'; this.showLineupToast('❌ ' + (rd.message||'failed')); }
      } catch (e) { syncBtn.disabled = false; syncBtn.textContent = '🔄 Sync'; this.showLineupToast('❌ ' + e.message); }
    });
    actionsDiv.appendChild(syncBtn);

    // Load RSVP data
    try {
      let resolvedChatEventId = chatEventId;

      if (type === 'game') {
        resolvedChatEventId = this.groupmeSync?.chatEventId || null;
      }

      if (!resolvedChatEventId) {
        modal.querySelector('#erm-body').innerHTML = `<div style="padding:24px;color:rgba(255,255,255,0.5);text-align:center;">No GroupMe event linked to this ${type === 'game' ? 'match' : 'training session'}</div>`;
        return;
      }

      const r = await this.auth.fetch(`/api/groupme/event-rsvps/${resolvedChatEventId}`);
      const data = await r.json();
      if (!data.success) throw new Error(data.message);

      const { rsvps, noResponse, title: evtTitle, startAt: evtStartAt } = data.data;
      const dispTitle = evtTitle || title || 'Event';
      modal.querySelector('#erm-title').textContent =
        `${dispTitle.length > 32 ? dispTitle.slice(0,32)+'…' : dispTitle} · ${fmtSAt(evtStartAt) || eventDate || ''}`;

      const isPast = evtStartAt
        ? new Date(evtStartAt.includes('T') ? evtStartAt : evtStartAt.replace(' ','T')) < new Date()
        : true;

      const mkOverrideBtn = (icon, status, personId, active) => {
        const b = document.createElement('button');
        b.textContent = icon;
        b.title = status === 'clear' ? 'Clear override' : `Override: ${status}`;
        b.style.cssText = `padding:3px 7px;border-radius:4px;font-size:0.75rem;cursor:pointer;border:1px solid ${active ? 'rgba(99,102,241,0.8)' : 'rgba(255,255,255,0.15)'};background:${active ? 'rgba(99,102,241,0.5)' : 'rgba(255,255,255,0.06)'};color:#fff;`;
        b.addEventListener('click', async () => {
          try {
            const res = await this.auth.fetch('/api/groupme/event-rsvp-override', {
              method: 'PUT',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ chatEventId: Number(resolvedChatEventId), personId, status })
            });
            const rd = await res.json();
            if (rd.success) {
              modal.remove();
              this._openEventRsvpModal({ type, chatEventId, matchId, title, startAt, eventDate, teamId });
              await this.loadEligibilityData();
            } else this.showLineupToast('❌ ' + (rd.message || 'failed'));
          } catch (e) { this.showLineupToast('❌ ' + e.message); }
        });
        return b;
      };

      const mkRow = (person) => {
        const row = document.createElement('div');
        row.style.cssText = 'display:flex;align-items:center;gap:8px;padding:8px 16px;border-bottom:1px solid rgba(255,255,255,0.06);';

        const nameSpan = document.createElement('span');
        nameSpan.style.cssText = `flex:1;font-size:0.82rem;color:${person.linked ? '#7ec8ff' : 'rgba(255,255,255,0.55)'};overflow:hidden;text-overflow:ellipsis;white-space:nowrap;`;
        nameSpan.textContent = (person.linked && person.gmName) ? `${person.name} (${person.gmName})` : person.name;
        if (person.isOverride) {
          const orig = document.createElement('span');
          orig.style.cssText = 'font-size:0.65rem;color:rgba(255,255,255,0.35);margin-left:4px;';
          orig.textContent = `(GM:${dotFor(person.rsvpStatus)})`;
          nameSpan.appendChild(orig);
        }
        row.appendChild(nameSpan);

        const btns = document.createElement('div');
        btns.style.cssText = 'display:flex;gap:3px;align-items:center;flex-shrink:0;';

        if (person.personId && isPast && type !== 'game') {
          const cb = document.createElement('input');
          cb.type = 'checkbox'; cb.checked = person.attended || false;
          cb.style.cssText = 'width:16px;height:16px;cursor:pointer;accent-color:#6366f1;margin-right:2px;';
          cb.title = 'Attended';
          cb.addEventListener('change', async () => {
            try {
              const res = await this.auth.fetch('/api/groupme/training-attendance', {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ personId: person.personId, chatEventId: Number(resolvedChatEventId), attended: cb.checked })
              });
              const rd = await res.json();
              if (!rd.success) { cb.checked = !cb.checked; this.showLineupToast('❌ ' + (rd.message||'failed')); }
              else await this.loadEligibilityData();
            } catch (e) { cb.checked = !cb.checked; this.showLineupToast('❌ ' + e.message); }
          });
          btns.appendChild(cb);
        }

        if (person.personId) {
          [['✓','yes'],['✗','no'],['?','maybe'],['×','clear']].forEach(([icon, status]) => {
            const active = status !== 'clear' && person.isOverride && person.overrideStatus === status;
            btns.appendChild(mkOverrideBtn(icon, status, person.personId, active));
          });
        }
        row.appendChild(btns);
        return row;
      };

      const body = modal.querySelector('#erm-body');
      body.innerHTML = '';

      const sections = [
        { label: '🟢 Going',       items: rsvps.filter(r => r.effStatus === 'yes') },
        { label: '🔴 Not Going',   items: rsvps.filter(r => r.effStatus === 'no') },
        { label: '🟡 Maybe',       items: rsvps.filter(r => r.effStatus === 'maybe') },
        { label: '❔ No Response', items: noResponse },
      ];
      for (const sec of sections) {
        if (!sec.items.length) continue;
        const hdr = document.createElement('div');
        hdr.style.cssText = 'padding:8px 16px 4px;font-size:0.72rem;font-weight:700;color:rgba(255,255,255,0.45);letter-spacing:0.05em;background:rgba(255,255,255,0.03);';
        hdr.textContent = `${sec.label} (${sec.items.length})`;
        body.appendChild(hdr);
        for (const p of sec.items) body.appendChild(mkRow(p));
      }
      if (!rsvps.length && !noResponse.length) {
        body.innerHTML = '<div style="padding:24px;color:rgba(255,255,255,0.4);text-align:center;">No RSVP data yet — tap Sync to load</div>';
      }

    } catch (err) {
      modal.querySelector('#erm-body').innerHTML = `<div style="padding:24px;color:#ef4444;text-align:center;">❌ ${err.message}</div>`;
    }
  }

  _renderBelowPitchZones(container) {
    const maxBench = this.rosterSize - 11;
    const allZoned = new Set([...this.zones.starting, ...this.zones.bench, ...this.zones.alternates]);
    const notResponded = this.players.filter(p => !allZoned.has(p.playerId) && p.matchRsvp !== 'no');
    const notGoing = this.players.filter(p => !allZoned.has(p.playerId) && p.matchRsvp === 'no');

    const moveBtns = (playerId, currentZone) => {
      const s = 'padding:3px 8px;font-size:0.75rem;border:1px solid var(--border-color);border-radius:4px;cursor:pointer;background:var(--bg-secondary);';
      const parts = [];
      if (currentZone !== 'starting') {
        const full = this.zones.starting.length >= 11;
        parts.push(`<button class="zone-move-btn" data-player-id="${playerId}" data-to-zone="starting" style="${s}${full ? 'opacity:0.5;' : ''}">⚽ Start</button>`);
      }
      if (currentZone !== 'bench') {
        const full = this.zones.bench.length >= maxBench;
        parts.push(`<button class="zone-move-btn" data-player-id="${playerId}" data-to-zone="bench" style="${s}${full ? 'opacity:0.5;' : ''}">🪑 Bench</button>`);
      }
      if (currentZone !== 'alternates') {
        parts.push(`<button class="zone-move-btn" data-player-id="${playerId}" data-to-zone="alternates" style="${s}">🔄 Alt</button>`);
      }
      if (currentZone !== 'pool') {
        parts.push(`<button class="zone-move-btn" data-player-id="${playerId}" data-to-zone="pool" style="${s}color:#ef4444;">✕</button>`);
      }
      return parts.join('');
    };

    const sections = [
      { id: 'bench', label: `🪑 Bench`, countLabel: () => `${this.zones.bench.length}/${maxBench}`,
        players: this.zones.bench.map(id => this.getPlayerById(id)).filter(Boolean), zone: 'bench', collapsible: false },
      { id: 'alternates', label: `🔄 Alternates`, countLabel: () => `${this.zones.alternates.length}`,
        players: this.zones.alternates.map(id => this.getPlayerById(id)).filter(Boolean), zone: 'alternates', collapsible: false },
      { id: 'notresponded', label: `❔ Not Responded`, countLabel: () => `${notResponded.length}`,
        players: notResponded, zone: 'pool', collapsible: true, startCollapsed: false },
      { id: 'notgoing', label: `✗ Not Going`, countLabel: () => `${notGoing.length}`,
        players: notGoing, zone: 'pool', collapsible: true, startCollapsed: true }
    ];

    for (const section of sections) {
      const sectionEl = document.createElement('div');
      sectionEl.style.cssText = 'margin-bottom:12px;border:1px solid var(--border-color);border-radius:10px;overflow:hidden;';
      const collapsed = section.startCollapsed;
      sectionEl.innerHTML = `
        <div class="lineup-section-header" data-section="${section.id}"
          style="display:flex;align-items:center;gap:8px;padding:10px 14px;background:var(--bg-secondary);cursor:${section.collapsible ? 'pointer' : 'default'};">
          <span style="font-weight:600;flex:1;">${section.label}</span>
          <span style="font-size:0.8rem;opacity:0.6;">${section.countLabel()}</span>
          ${section.collapsible ? `<span class="section-arrow" style="font-size:0.85rem;opacity:0.6;">${collapsed ? '▸' : '▾'}</span>` : ''}
        </div>
        <div id="section-body-${section.id}" style="${collapsed ? 'display:none;' : ''}padding:6px 8px;"></div>
      `;
      container.appendChild(sectionEl);
      const body = sectionEl.querySelector(`#section-body-${section.id}`);
      if (section.players.length === 0) {
        body.innerHTML = `<div style="padding:8px 6px;font-size:0.85rem;opacity:0.5;text-align:center;">— empty —</div>`;
      } else {
        for (const player of section.players) {
          body.appendChild(this.createLineupCard(player, section.zone, moveBtns(player.playerId, section.zone)));
        }
      }
      if (section.id === 'notresponded' && this.unmatchedRsvps?.length) {
        for (const u of this.unmatchedRsvps) body.appendChild(this.createUnlinkedCard(u));
      }
    }
  }

  // ============================================================================
  // Pitch Popovers
  // ============================================================================
  _buildPitchPopover(anchorEvent, html) {
    this._dismissPitchPopover();
    const pop = document.createElement('div');
    pop.className = 'pitch-popover';
    pop.style.cssText = 'position:fixed;z-index:1100;background:var(--bg-secondary);border:1px solid var(--border-color);border-radius:10px;padding:8px;min-width:160px;box-shadow:0 4px 20px rgba(0,0,0,0.35);';
    pop.innerHTML = html;
    document.body.appendChild(pop);
    this._activePitchPopover = pop;
    const x = Math.max(8, Math.min(anchorEvent.clientX, window.innerWidth - 175));
    const y = Math.max(8, Math.min(anchorEvent.clientY + 12, window.innerHeight - 220));
    pop.style.left = `${x}px`;
    pop.style.top = `${y}px`;
    return pop;
  }

  _dismissPitchPopover() {
    if (this._activePitchPopover) {
      this._activePitchPopover.remove();
      this._activePitchPopover = null;
    }
  }

  openChipActions(playerId, slotIndex, e) {
    const player = this.getPlayerById(playerId);
    if (!player) return;
    const name = `${player.firstName || ''} ${player.lastName || ''}`.trim();
    const maxBench = this.rosterSize - 11;
    const benchFull = this.zones.bench.length >= maxBench;
    const eligIcon = this.getStatusIcon(player.eligibilityStatus);
    const prac = `${player.sessionsAttended || 0}/${player.requiredSessions ?? this.policy?.lookbackCount ?? '?'}`;
    const jersey = player.jerseyNumber || '';

    const rsvpOptions = ['yes','no','maybe'].map(v => {
      const label = v === 'yes' ? '🟢 Going' : v === 'no' ? '🔴 Not Going' : '🟡 Maybe';
      const sel = player.matchRsvp === v ? 'font-weight:700;' : '';
      return `<button class="pitch-popover-item" data-action="rsvp" data-rsvp="${v}" data-player-id="${playerId}"
        style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;${sel}">${label}</button>`;
    }).join('');

    const pop = this._buildPitchPopover(e, `
      <div style="font-size:0.85rem;font-weight:600;padding:2px 4px 6px;border-bottom:1px solid var(--border-color);margin-bottom:6px;display:flex;align-items:center;gap:6px;">
        ${eligIcon} <span>${name}</span> <span style="opacity:0.45;font-size:0.72rem;">${prac}</span>
      </div>

      <div style="padding:0 4px 8px;border-bottom:1px solid var(--border-color);margin-bottom:6px;">
        <div style="font-size:0.72rem;opacity:0.55;margin-bottom:4px;">JERSEY</div>
        <input id="chip-jersey-input" type="text" inputmode="numeric" value="${jersey}"
          placeholder="—"
          style="width:60px;padding:4px 8px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-primary);color:inherit;font-size:0.9rem;text-align:center;">
        <button class="pitch-popover-item" data-action="set-jersey" data-player-id="${playerId}"
          style="margin-left:6px;padding:4px 10px;border:1px solid var(--border-color);border-radius:6px;background:var(--bg-secondary);cursor:pointer;font-size:0.8rem;">Set</button>
      </div>

      <div style="padding:0 4px 8px;border-bottom:1px solid var(--border-color);margin-bottom:6px;">
        <div style="font-size:0.72rem;opacity:0.55;margin-bottom:4px;">RSVP OVERRIDE</div>
        ${rsvpOptions}
      </div>

      <div style="padding:0 4px;">
        <div style="font-size:0.72rem;opacity:0.55;margin-bottom:4px;">MOVE</div>
        <button class="pitch-popover-item" data-action="to-bench" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;${benchFull ? 'opacity:0.4;' : ''}">
          🪑 Move to Bench
        </button>
        <button class="pitch-popover-item" data-action="to-alternates" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;">
          🔄 Move to Alternates
        </button>
        <button class="pitch-popover-item" data-action="to-pool" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;color:#ef4444;">
          ✕ Remove from lineup
        </button>
        <button class="pitch-popover-item" data-action="swap" data-player-id="${playerId}" data-slot="${slotIndex}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;">
          🔁 Swap Player
        </button>
        <button class="pitch-popover-item" data-action="attendance" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;">
          📋 Edit Attendance
        </button>
        <button class="pitch-popover-item" data-action="edit-player" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;">
          ✏️ Edit Player
        </button>
      </div>
    `);

    pop.addEventListener('click', async (ev) => {
      const item = ev.target.closest('.pitch-popover-item');
      if (!item) return;
      const pid = parseInt(item.dataset.playerId);
      const action = item.dataset.action;

      if (action === 'to-bench') { this.movePlayerToZone(pid, 'bench'); this._dismissPitchPopover(); }
      else if (action === 'to-alternates') { this.movePlayerToZone(pid, 'alternates'); this._dismissPitchPopover(); }
      else if (action === 'to-pool') { this.movePlayerToZone(pid, 'pool'); this._dismissPitchPopover(); }
      else if (action === 'swap') {
        this._dismissPitchPopover();
        // Remove from starting, open slot picker for that slot
        const slot = parseInt(item.dataset.slot);
        this.movePlayerToZone(pid, 'bench');
        // Reopen the slot picker at the same position
        this.openSlotPicker(slot, ev);
      } else if (action === 'rsvp') {
        await this.updatePlayerRsvp(pid, item.dataset.rsvp);
        this._dismissPitchPopover();
      } else if (action === 'set-jersey') {
        const input = pop.querySelector('#chip-jersey-input');
        const val = input ? input.value.trim() : '';
        const p = this.getPlayerById(pid);
        if (p) { p.jerseyNumber = val || null; }
        this._dismissPitchPopover();
        this.renderAllZones();
      } else if (action === 'attendance') {
        this._dismissPitchPopover();
        this.openAttendancePopup(pid);
      } else if (action === 'edit-player') {
        this._dismissPitchPopover();
        this.openEditPlayerModal(pid);
      }
    });
  }

  // Build the horizontal shelf showing bench/alternates/pool players
  _buildPlayerShelf() {
    const shelf = document.createElement('div');
    shelf.id = 'pitch-shelf';
    shelf.style.cssText = 'display:flex;align-items:stretch;overflow-x:auto;background:#0d1f0d;border-top:1px solid rgba(255,255,255,0.1);flex-shrink:0;min-height:70px;padding:6px 8px;gap:5px;';
    // webkit scrollbar hide
    shelf.style.cssText += 'scrollbar-width:none;';

    const allZoned = new Set([...this.zones.starting, ...this.zones.bench, ...this.zones.alternates]);
    const sections = [
      { label: '🪑', title: 'Bench',      color: '#3b82f6', players: this._rankPlayers(this.zones.bench.map(id => this.getPlayerById(id)).filter(Boolean)).map(p => ({ id: p.playerId, zone: 'bench' })) },
      { label: '🔄', title: 'Alt',        color: '#a855f7', players: this._rankPlayers(this.zones.alternates.map(id => this.getPlayerById(id)).filter(Boolean)).map(p => ({ id: p.playerId, zone: 'alternates' })) },
      { label: '❔', title: 'Available',  color: '#6b7280', players: this._rankPlayers(this.players.filter(p => !allZoned.has(p.playerId) && p.matchRsvp !== 'no')).map(p => ({ id: p.playerId, zone: 'pool' })) },
      { label: '✗',  title: 'Not Going', color: '#ef4444', players: this._rankPlayers(this.players.filter(p => !allZoned.has(p.playerId) && p.matchRsvp === 'no')).map(p => ({ id: p.playerId, zone: 'pool' })) },
    ];

    for (const section of sections) {
      if (section.players.length === 0) continue;

      // Section divider label
      const lbl = document.createElement('div');
      lbl.style.cssText = `display:flex;flex-direction:column;align-items:center;justify-content:center;padding:0 4px;flex-shrink:0;gap:2px;opacity:0.55;`;
      lbl.innerHTML = `<span style="font-size:0.9rem;">${section.label}</span><span style="font-size:0.5rem;color:${section.color};font-weight:600;text-transform:uppercase;letter-spacing:0.03em;">${section.title}</span>`;
      shelf.appendChild(lbl);

      for (const { id, zone } of section.players) {
        const player = this.getPlayerById(id);
        if (!player) continue;
        const eligColor = this._eligColor(player);
        const rsvpIcon = player.matchRsvp === 'yes' ? '🟢' : player.matchRsvp === 'no' ? '🔴' : '🟡';
        const jersey = player.jerseyNumber || (player.firstName?.[0] ?? '?');
        const name = (player.firstName || '').slice(0, 8);
        const prac = `${player.sessionsAttended || 0}/${player.requiredSessions ?? this.policy?.lookbackCount ?? '?'}`;

        const chip = document.createElement('div');
        chip.className = 'shelf-chip';
        chip.dataset.playerId = id;
        chip.dataset.zone = zone;
        chip.style.cssText = `display:flex;flex-direction:column;align-items:center;justify-content:center;flex-shrink:0;cursor:pointer;padding:4px 5px;border-radius:8px;gap:2px;border-left:2px solid ${section.color};background:rgba(255,255,255,0.04);min-width:46px;touch-action:manipulation;user-select:none;`;
        const starBadge = player.isDesignated ? '<span style="color:#fbbf24;font-size:0.5rem;">★</span>' : '';
        const clubBadge = (player.numClubs || 1) > 1 ? '<span style="background:#f97316;color:#000;border-radius:2px;padding:0 2px;font-size:0.45rem;font-weight:700;">2C</span>' : '';
        chip.innerHTML = `
          <div style="position:relative;width:28px;height:28px;border-radius:50%;background:${eligColor};display:flex;align-items:center;justify-content:center;font-size:0.62rem;font-weight:700;color:#fff;border:1.5px solid rgba(255,255,255,0.7);">${jersey}${starBadge}</div>
          <div style="font-size:0.52rem;color:rgba(255,255,255,0.85);white-space:nowrap;">${name}</div>
          <div style="font-size:0.48rem;color:rgba(255,255,255,0.4);display:flex;align-items:center;gap:2px;">${rsvpIcon} ${prac} ${clubBadge}</div>
        `;
        shelf.appendChild(chip);
      }
    }

    if (shelf.children.length === 0) {
      shelf.innerHTML = '<span style="color:rgba(255,255,255,0.25);font-size:0.75rem;padding:0 10px;align-self:center;">All players in lineup</span>';
    }

    shelf.addEventListener('click', (e) => {
      const chip = e.target.closest('.shelf-chip');
      if (chip) {
        e.stopPropagation();
        // Go directly to full edit modal — same as pitch chip tap
        this.openEditPlayerModal(parseInt(chip.dataset.playerId));
      } else {
        this._dismissPitchPopover();
      }
    });

    return shelf;
  }

  openShelfChipActions(playerId, currentZone, e) {
    const player = this.getPlayerById(playerId);
    if (!player) return;
    const name    = `${player.firstName || ''} ${player.lastName || ''}`.trim();
    const eligIcon = this.getStatusIcon(player.eligibilityStatus);
    const prac    = `${player.sessionsAttended || 0}/${player.requiredSessions ?? this.policy?.lookbackCount ?? '?'}`;
    const maxBench = this.rosterSize - 11;
    const startFull = this.zones.starting.length >= 11;
    const benchFull = this.zones.bench.length >= maxBench;

    const rsvpOptions = ['yes', 'no', 'maybe'].map(v => {
      const label = v === 'yes' ? '🟢 Going' : v === 'no' ? '🔴 Not Going' : '🟡 Maybe';
      const sel   = player.matchRsvp === v ? 'font-weight:700;' : '';
      return `<button class="pitch-popover-item" data-action="rsvp" data-rsvp="${v}" data-player-id="${playerId}"
        style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;${sel}">${label}</button>`;
    }).join('');

    const pop = this._buildPitchPopover(e, `
      <div style="font-size:0.85rem;font-weight:600;padding:2px 4px 6px;border-bottom:1px solid var(--border-color);margin-bottom:6px;display:flex;align-items:center;gap:6px;">
        ${eligIcon} <span>${name}</span> <span style="opacity:0.45;font-size:0.72rem;">${prac}</span>
      </div>

      <div style="padding:0 4px 8px;border-bottom:1px solid var(--border-color);margin-bottom:6px;">
        <div style="font-size:0.72rem;opacity:0.55;margin-bottom:4px;">ADD TO LINEUP</div>
        <button class="pitch-popover-item" data-action="to-starting" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;${startFull ? 'opacity:0.4;' : 'color:#22c55e;font-weight:600;'}">
          ⚽ Add to Starting XI
        </button>
        ${currentZone !== 'bench' ? `<button class="pitch-popover-item" data-action="to-bench" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;${benchFull ? 'opacity:0.4;' : ''}">
          🪑 Move to Bench
        </button>` : ''}
        ${currentZone !== 'alternates' ? `<button class="pitch-popover-item" data-action="to-alternates" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;">
          🔄 Move to Alternates
        </button>` : ''}
        ${currentZone !== 'pool' ? `<button class="pitch-popover-item" data-action="to-pool" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;color:#ef4444;">
          ✕ Remove from roster
        </button>` : ''}
      </div>

      <div style="padding:0 4px 8px;border-bottom:1px solid var(--border-color);margin-bottom:6px;">
        <div style="font-size:0.72rem;opacity:0.55;margin-bottom:4px;">RSVP OVERRIDE</div>
        ${rsvpOptions}
      </div>

      <div style="padding:0 4px;">
        <button class="pitch-popover-item" data-action="attendance" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;">
          📋 Edit Attendance
        </button>
        <button class="pitch-popover-item" data-action="edit-player" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;">
          ✏️ Edit Player
        </button>
      </div>
    `);

    pop.addEventListener('click', async (ev) => {
      const item = ev.target.closest('.pitch-popover-item');
      if (!item) return;
      const pid    = parseInt(item.dataset.playerId);
      const action = item.dataset.action;

      if (action === 'to-starting') {
        if (!startFull) { this.movePlayerToZone(pid, 'starting'); }
        else { this.showLineupToast('Starting XI is full (11/11)'); }
        this._dismissPitchPopover();
      } else if (action === 'to-bench') {
        this.movePlayerToZone(pid, 'bench'); this._dismissPitchPopover();
      } else if (action === 'to-alternates') {
        this.movePlayerToZone(pid, 'alternates'); this._dismissPitchPopover();
      } else if (action === 'to-pool') {
        this.movePlayerToZone(pid, 'pool'); this._dismissPitchPopover();
      } else if (action === 'rsvp') {
        await this.updatePlayerRsvp(pid, item.dataset.rsvp);
        this._dismissPitchPopover();
      } else if (action === 'attendance') {
        this._dismissPitchPopover();
        this.openAttendancePopup(pid);
      } else if (action === 'edit-player') {
        this._dismissPitchPopover();
        this.openEditPlayerModal(pid);
      }
    });
  }

  // ── Rank players for slot picker ───────────────────────────────────────────
  // Tier 1: designated players
  // Tier 2: 2+ sessions AND 1 club
  // Tier 3: 2+ sessions, 2 clubs
  // Tier 4: <2 sessions, 1 club
  // Tier 5: <2 sessions, 2 clubs
  // Within tier: sort by sessions desc, then name asc
  // Primary sort for all player lists:
  //   1. APSL starters (eligApslStarter) first — league-registered
  //   2. Met practice threshold (priority_starter / eligible_starter)
  //   3. Chip-color priority (green → yellow → blue → orange → red)
  //   4. Sessions attended descending
  //   5. Alphabetical
  _rankPlayers(players) {
    const COLOR_ORDER = ['green', 'yellow', 'blue', 'orange', 'red'];
    const metPrac = (p) => p.eligibilityStatus === 'priority_starter' || p.eligibilityStatus === 'eligible_starter';
    return [...players].sort((a, b) => {
      const apslDiff = (b.eligApslStarter ? 1 : 0) - (a.eligApslStarter ? 1 : 0);
      if (apslDiff !== 0) return apslDiff;
      const pracDiff = (metPrac(b) ? 1 : 0) - (metPrac(a) ? 1 : 0);
      if (pracDiff !== 0) return pracDiff;
      const colorDiff = COLOR_ORDER.indexOf(this._eligState(a)) - COLOR_ORDER.indexOf(this._eligState(b));
      if (colorDiff !== 0) return colorDiff;
      const sd = (b.sessionsAttended || 0) - (a.sessionsAttended || 0);
      if (sd !== 0) return sd;
      return ((a.firstName || '') + (a.lastName || '')).localeCompare((b.firstName || '') + (b.lastName || ''));
    });
  }

  // ── Edit Player Modal ──────────────────────────────────────────────────────
  // ── Groups panel ─────────────────────────────────────────────────────────
  openGroupsPanel() {
    const GROUPS = [
      { key: 'all',             label: '👥 All Players' },
      { key: 'apsl_starter',    label: 'APSL Starter' },
      { key: 'apsl_bench',      label: 'APSL Bench' },
      { key: 'liga1_starter',   label: 'Liga 1 Starter' },
      { key: 'liga1_bench',     label: 'Liga 1 Bench' },
      { key: 'liga2_starter',   label: 'Liga 2 Starter' },
      { key: 'liga2_bench',     label: 'Liga 2 Bench' },
      { key: 'unassigned',      label: '— Unassigned' },
      { key: 'injured',         label: '🤕 Injured' },
      { key: 'susp_league',     label: '🚫 Susp (League)' },
      { key: 'susp_inhouse',    label: '🚫 Susp (In-House)' },
    ];

    const ROLE_LABELS = {
      apsl_starter: 'APSL Starter', apsl_bench: 'APSL Bench',
      liga1_starter: 'Liga 1 Starter', liga1_bench: 'Liga 1 Bench',
      liga2_starter: 'Liga 2 Starter', liga2_bench: 'Liga 2 Bench',
    };

    const overlay = document.createElement('div');
    overlay.style.cssText = 'position:fixed;inset:0;z-index:1200;background:rgba(0,0,0,0.65);display:flex;flex-direction:column;';

    const panel = document.createElement('div');
    panel.style.cssText = 'background:var(--bg-primary,#111);border-top:1px solid var(--border-color,#333);display:flex;flex-direction:column;max-height:85vh;margin-top:auto;border-radius:14px 14px 0 0;overflow:hidden;';

    // Header
    panel.innerHTML = `
      <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 16px 8px;border-bottom:1px solid var(--border-color,#333);flex-shrink:0;">
        <span style="font-weight:700;font-size:1rem;">👥 Player Groups</span>
        <button id="groups-close-btn" style="background:transparent;border:none;color:inherit;font-size:1.1rem;cursor:pointer;opacity:0.6;">✕</button>
      </div>
    `;

    // Group filter pills
    const pillRow = document.createElement('div');
    pillRow.style.cssText = 'display:flex;gap:6px;padding:10px 12px;overflow-x:auto;scrollbar-width:none;flex-shrink:0;border-bottom:1px solid var(--border-color,#333);';

    let activeGroup = 'all';

    const renderList = () => {
      list.innerHTML = '';
      const filtered = this.players.filter(p => {
        if (activeGroup === 'all')         return true;
        if (activeGroup === 'injured')     return p.isInjured;
        if (activeGroup === 'susp_league') return p.isSuspendedLeague;
        if (activeGroup === 'susp_inhouse')return p.isSuspendedInhouse;
        if (activeGroup === 'unassigned')  return !p.internalRole;
        return p.internalRole === activeGroup;
      });

      if (filtered.length === 0) {
        list.innerHTML = '<div style="padding:24px;text-align:center;opacity:0.45;font-size:0.9rem;">— No players in this group —</div>';
        return;
      }

      for (const p of filtered) {
        const name = `${p.firstName || ''} ${p.lastName || ''}`.trim();
        const roleBadge = p.internalRole
          ? `<span style="background:rgba(59,130,246,0.2);color:#60a5fa;border-radius:4px;padding:1px 6px;font-size:0.72rem;">${ROLE_LABELS[p.internalRole] || p.internalRole}</span>`
          : '<span style="opacity:0.35;font-size:0.72rem;">unassigned</span>';
        const injBadge   = p.isInjured           ? '<span style="background:#ef4444;color:#fff;border-radius:4px;padding:1px 5px;font-size:0.68rem;font-weight:700;">INJ</span>' : '';
        const suspLBadge = p.isSuspendedLeague    ? '<span style="background:#dc2626;color:#fff;border-radius:4px;padding:1px 5px;font-size:0.68rem;font-weight:700;">SUSP-L</span>' : '';
        const suspHBadge = p.isSuspendedInhouse   ? '<span style="background:#f59e0b;color:#000;border-radius:4px;padding:1px 5px;font-size:0.68rem;font-weight:700;">SUSP-H</span>' : '';
        const eligColor  = this._eligColor(p);
        const jersey     = p.jerseyNumber || (p.firstName?.[0] ?? '?');

        const row = document.createElement('div');
        row.className = 'groups-player-row';
        row.dataset.playerId = p.playerId;
        row.style.cssText = 'display:flex;align-items:center;gap:10px;padding:10px 14px;cursor:pointer;border-bottom:1px solid rgba(255,255,255,0.05);';
        row.innerHTML = `
          <div style="width:32px;height:32px;border-radius:50%;background:${eligColor};display:flex;align-items:center;justify-content:center;font-size:0.7rem;font-weight:700;color:#fff;flex-shrink:0;">${jersey}</div>
          <div style="flex:1;min-width:0;">
            <div style="font-size:0.9rem;font-weight:600;">${name}</div>
            <div style="display:flex;flex-wrap:wrap;gap:4px;margin-top:3px;">${roleBadge}${injBadge}${suspLBadge}${suspHBadge}</div>
          </div>
          <span style="opacity:0.35;font-size:1rem;">›</span>
        `;
        list.appendChild(row);
      }
    };

    const rebuildPills = () => {
      pillRow.innerHTML = '';
      for (const g of GROUPS) {
        const active = g.key === activeGroup;
        const pill = document.createElement('button');
        pill.dataset.groupKey = g.key;
        pill.style.cssText = `padding:4px 12px;border-radius:20px;border:1px solid ${active ? 'rgba(255,255,255,0.6)' : 'rgba(255,255,255,0.2)'};cursor:pointer;font-size:0.75rem;font-weight:${active ? '700' : '400'};background:${active ? 'rgba(59,130,246,0.85)' : 'rgba(255,255,255,0.05)'};color:${active ? '#fff' : 'rgba(255,255,255,0.6)'};flex-shrink:0;white-space:nowrap;`;
        pill.textContent = g.label;
        pillRow.appendChild(pill);
      }
    };

    // Player list
    const list = document.createElement('div');
    list.style.cssText = 'overflow-y:auto;flex:1;';

    rebuildPills();
    renderList();

    pillRow.addEventListener('click', (e) => {
      const pill = e.target.closest('[data-group-key]');
      if (!pill) return;
      activeGroup = pill.dataset.groupKey;
      rebuildPills();
      renderList();
    });

    list.addEventListener('click', (e) => {
      const row = e.target.closest('.groups-player-row');
      if (!row) return;
      const pid = parseInt(row.dataset.playerId);
      overlay.remove();
      // After closing panel, open edit modal — give DOM a tick to settle
      setTimeout(() => this.openEditPlayerModal(pid), 30);
    });

    panel.querySelector('#groups-close-btn').addEventListener('click', () => overlay.remove());
    overlay.addEventListener('click', (e) => { if (e.target === overlay) overlay.remove(); });

    panel.appendChild(pillRow);
    panel.appendChild(list);
    overlay.appendChild(panel);
    document.body.appendChild(overlay);
  }

  openEditPlayerModal(playerId, slotIndex) {
    this._dismissPitchPopover(); // clear any stale popover before opening modal
    const player = this.getPlayerById(playerId);
    if (!player) return;

    const eligIcon = this.getStatusIcon(player.eligibilityStatus);
    const prac     = `${player.sessionsAttended || 0}/${player.requiredSessions ?? this.policy?.lookbackCount ?? '?'}`;
    const pos      = player.position || '—';
    const isOnPitch = slotIndex !== undefined && this.zones.starting[slotIndex] === playerId;
    const currentZone = isOnPitch ? 'starting'
      : this.zones.bench.includes(playerId) ? 'bench'
      : this.zones.alternates.includes(playerId) ? 'alternates'
      : 'pool';

    // Remove / move buttons depend on current zone
    const removeBtnHtml = (currentZone === 'starting') ? `
      <button id="ep-remove-btn" style="width:100%;padding:8px;border-radius:8px;border:1px solid #ef4444;background:transparent;color:#ef4444;cursor:pointer;font-size:0.85rem;font-weight:600;">
        ✕ Remove from Lineup
      </button>` : '';

    const moveBtnsFor = {
      starting:   ['to-bench:🪑 Bench', 'to-alternates:🔄 Alt'],
      bench:      ['to-starting:⚽ Add to Pitch', 'to-alternates:🔄 Alt', 'to-pool:✕ Remove from Bench'],
      alternates: ['to-starting:⚽ Add to Pitch', 'to-bench:🪑 Bench',    'to-pool:✕ Remove from Alt'],
      pool:       ['to-bench:🪑 Add to Bench',   'to-alternates:🔄 Add to Alt', 'to-starting:⚽ Add to Pitch'],
    }[currentZone] || [];
    const moveBtnHtml = moveBtnsFor.length ? `
      <div style="display:flex;gap:6px;flex-wrap:wrap;">
        ${moveBtnsFor.map(s => {
          const [action, label] = s.split(':');
          return `<button data-action="${action}" style="flex:1;min-width:0;padding:6px;border-radius:8px;border:1px solid var(--border-color);background:var(--bg-surface);color:inherit;cursor:pointer;font-size:0.78rem;white-space:nowrap;">${label}</button>`;
        }).join('')}
      </div>` : '';

    // Eligibility checkboxes
    const eligRows = [
      { id: 'elig-apsl-starter',  label: 'APSL Starter',  field: 'eligApslStarter'  },
      { id: 'elig-apsl-bench',    label: 'APSL Bench',    field: 'eligApslBench'    },
      { id: 'elig-liga1-starter', label: 'Liga 1 Starter',field: 'eligLiga1Starter' },
      { id: 'elig-liga1-bench',   label: 'Liga 1 Bench',  field: 'eligLiga1Bench'   },
      { id: 'elig-liga2-starter', label: 'Liga 2 Starter',field: 'eligLiga2Starter' },
      { id: 'elig-liga2-bench',   label: 'Liga 2 Bench',  field: 'eligLiga2Bench'   },
    ].map(r => `
      <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;padding:4px 0;">
        <span style="font-size:0.88rem;">${r.label}</span>
        <input type="checkbox" id="${r.id}" style="width:18px;height:18px;cursor:pointer;accent-color:var(--accent);" ${player[r.field] ? 'checked' : ''}>
      </label>`).join('');

    const overlay = document.createElement('div');
    overlay.className = 'attendance-overlay';
    overlay.innerHTML = `
      <div class="attendance-popup" style="max-width:360px;max-height:90vh;overflow-y:auto;">
        <div class="attendance-popup-header" style="position:sticky;top:0;z-index:1;background:var(--bg-secondary);">
          <div style="display:flex;flex-direction:column;gap:2px;flex:1;min-width:0;">
            <h3 style="margin:0;font-size:1rem;">${eligIcon} ${player.firstName || ''} ${player.lastName || ''}</h3>
            <div style="font-size:0.75rem;color:var(--text-muted);">${pos} · #${player.jerseyNumber || '—'} · ${prac} sessions</div>
          </div>
          <button class="attendance-close-btn">✕</button>
        </div>
        <div class="attendance-popup-body" style="padding:16px;display:flex;flex-direction:column;gap:0;">

          ${removeBtnHtml ? `<div style="margin-bottom:12px;">${removeBtnHtml}</div>` : ''}
          ${moveBtnHtml   ? `<div style="margin-bottom:12px;">${moveBtnHtml}</div>`   : ''}

          <!-- RSVP -->
          <div style="border-top:1px solid var(--border-color);padding:12px 0;">
            <div style="font-size:0.7rem;color:var(--text-muted);font-weight:700;letter-spacing:0.06em;margin-bottom:8px;">MATCH RSVP</div>
            <div style="display:flex;gap:6px;">
              ${['yes','maybe','no'].map(v => {
                const icons = {yes:'🟢 Going', maybe:'🟡 Maybe', no:'🔴 No'};
                const sel = player.matchRsvp === v;
                return `<button data-rsvp="${v}" style="flex:1;padding:6px 4px;border-radius:8px;border:2px solid ${sel ? '#2563eb' : 'var(--border-color)'};background:${sel ? 'rgba(37,99,235,0.2)' : 'var(--bg-surface)'};color:inherit;cursor:pointer;font-size:0.8rem;font-weight:${sel?'700':'400'};">${icons[v]}</button>`;
              }).join('')}
            </div>
          </div>

          <!-- Core identity -->
          <div style="border-top:1px solid var(--border-color);padding:12px 0;display:flex;flex-direction:column;gap:10px;">
            <div style="font-size:0.7rem;color:var(--text-muted);font-weight:700;letter-spacing:0.06em;">PLAYER INFO</div>

            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <span style="font-size:0.88rem;"># Jersey</span>
              <input type="text" id="ep-jersey" inputmode="numeric" value="${player.jerseyNumber || ''}" placeholder="—"
                style="width:64px;padding:5px 8px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-primary);color:inherit;font-size:0.9rem;text-align:center;">
            </label>

            <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div>
                <div style="font-size:0.88rem;">🎂 Date of Birth</div>
                <div style="font-size:0.72rem;color:var(--text-muted);">U19 (born after 2007) = 3 req · U23 (born after 2003) = 2 req · Senior = 1 req</div>
              </div>
              <input type="date" id="ep-dob" value="${player.dateOfBirth || ''}" placeholder="YYYY-MM-DD"
                style="padding:5px 6px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-primary);color:inherit;font-size:0.82rem;">
            </div>

            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div>
                <div style="font-size:0.88rem;">🏃 Required Sessions</div>
                <div style="font-size:0.72rem;color:var(--text-muted);">Auto-set from DOB · override if needed</div>
              </div>
              <div style="display:flex;align-items:center;gap:6px;">
                <span id="ep-req-auto" style="font-size:0.78rem;color:var(--text-muted);">(auto: ${player.requiredSessions ?? '?'})</span>
                <input type="number" id="ep-req-override" min="0" max="10"
                  value="${player.requiredSessionsOverride != null ? player.requiredSessionsOverride : ''}"
                  placeholder="—"
                  style="width:52px;padding:5px 6px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-primary);color:inherit;font-size:0.9rem;text-align:center;">
              </div>
            </label>

            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <span style="font-size:0.88rem;">⭐ Designated Player</span>
              <input type="checkbox" id="ep-designated" style="width:20px;height:20px;cursor:pointer;accent-color:var(--accent);" ${player.isDesignated ? 'checked' : ''}>
            </label>

            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div>
                <div style="font-size:0.88rem;">🏟️ Number of Clubs</div>
                <div style="font-size:0.72rem;color:var(--text-muted);">2 clubs = ranked lower</div>
              </div>
              <select id="ep-numclubs" style="padding:4px 8px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-secondary);color:inherit;font-size:0.88rem;">
                <option value="1" ${(player.numClubs||1)===1?'selected':''}>1 club</option>
                <option value="2" ${(player.numClubs||1)===2?'selected':''}>2 clubs</option>
              </select>
            </label>

            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div>
                <div style="font-size:0.88rem;">👨‍👩‍👦 Family Discount</div>
                <div style="font-size:0.72rem;color:var(--text-muted);">−${this.policy?.familyDiscount||1} min sessions</div>
              </div>
              <input type="checkbox" id="ep-family" style="width:20px;height:20px;cursor:pointer;accent-color:var(--accent);" ${player.hasFamilyDiscount ? 'checked' : ''}>
            </label>

            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div>
                <div style="font-size:0.88rem;">🧤 Goalkeeper</div>
                <div style="font-size:0.72rem;color:var(--text-muted);">0 practices required</div>
              </div>
              <input type="checkbox" id="ep-keeper" style="width:20px;height:20px;cursor:pointer;accent-color:var(--accent);" ${player.isKeeper ? 'checked' : ''}>
            </label>
          </div>

          <!-- Status -->
          <div style="border-top:1px solid var(--border-color);padding:12px 0;display:flex;flex-direction:column;gap:10px;">
            <div style="font-size:0.7rem;color:var(--text-muted);font-weight:700;letter-spacing:0.06em;">STATUS</div>
            <label style="display:flex;align-items:center;justify-content:space-between;">
              <span style="font-size:0.88rem;">🤕 Injured</span>
              <input type="checkbox" id="ep-injured" style="width:20px;height:20px;cursor:pointer;" ${player.isInjured ? 'checked' : ''}>
            </label>
            <label style="display:flex;align-items:center;justify-content:space-between;">
              <span style="font-size:0.88rem;">🚫 Suspended (League)</span>
              <input type="checkbox" id="ep-susp-league" style="width:20px;height:20px;cursor:pointer;" ${player.isSuspendedLeague ? 'checked' : ''}>
            </label>
            <label style="display:flex;align-items:center;justify-content:space-between;">
              <span style="font-size:0.88rem;">🚫 Suspended (In-House)</span>
              <input type="checkbox" id="ep-susp-inhouse" style="width:20px;height:20px;cursor:pointer;" ${player.isSuspendedInhouse ? 'checked' : ''}>
            </label>
          </div>

          <!-- Eligibility Groups (multi-select) -->
          <div style="border-top:1px solid var(--border-color);padding:12px 0;display:flex;flex-direction:column;gap:4px;">
            <div style="font-size:0.7rem;color:var(--text-muted);font-weight:700;letter-spacing:0.06em;margin-bottom:4px;">ELIGIBLE FOR (select all that apply)</div>
            ${eligRows}
          </div>

          <!-- Last 5 Practices -->
          <div style="border-top:1px solid var(--border-color);padding:12px 0;">
            <div style="font-size:0.7rem;color:var(--text-muted);font-weight:700;letter-spacing:0.06em;margin-bottom:8px;">LAST 5 PRACTICES</div>
            <div id="ep-practices-body" style="font-size:0.78rem;color:var(--text-muted);">Loading...</div>
          </div>

          <div id="ep-save-status" style="margin-top:8px;font-size:0.75rem;color:var(--text-muted);text-align:center;min-height:1.2em;"></div>
        </div>
      </div>
    `;
    document.body.appendChild(overlay);

    // Load last 5 practices async
    const matchId = this.navigation?.context?.match?.id;
    const teamId  = this.navigation?.context?.lineupTeamId || this.navigation?.context?.team?.id || '';
    const practicesBody = overlay.querySelector('#ep-practices-body');
    if (matchId && practicesBody) {
      this.auth.fetch(`/api/eligibility/player/${playerId}/attendance?teamId=${teamId}&matchId=${matchId}`)
        .then(r => r.json())
        .then(data => {
          const sessions = (data.success && data.data?.sessions) ? data.data.sessions.slice(0, 5) : [];
          if (sessions.length === 0) {
            practicesBody.textContent = 'No recent sessions found.';
            return;
          }
          // Header row
          practicesBody.innerHTML = `
            <table style="width:100%;border-collapse:collapse;">
              <thead>
                <tr>
                  <th style="text-align:left;font-size:0.65rem;color:var(--text-muted);padding-bottom:4px;font-weight:600;">SESSION</th>
                  <th style="text-align:center;font-size:0.65rem;color:var(--text-muted);padding-bottom:4px;font-weight:600;">RSVP</th>
                  <th style="text-align:center;font-size:0.65rem;color:var(--text-muted);padding-bottom:4px;font-weight:600;">ATTENDED</th>
                </tr>
              </thead>
              <tbody id="ep-sessions-tbody"></tbody>
            </table>
          `;
          const tbody = practicesBody.querySelector('#ep-sessions-tbody');
          const renderSessions = (sessions) => {
            tbody.innerHTML = sessions.map(s => {
              const d = s.date ? s.date.slice(5) : '';
              const title = s.title.length > 18 ? s.title.slice(0,17)+'…' : s.title;
              // RSVP
              const rsvpVal = s.rsvp || '';
              const rsvpBtns = [
                { v:'yes',   icon:'🟢', tip:'Going' },
                { v:'maybe', icon:'🟡', tip:'Maybe' },
                { v:'no',    icon:'🔴', tip:'No' },
              ].map(b => `<button data-sid="${s.sessionId}" data-type="rsvp" data-val="${b.v}"
                style="border:none;background:none;cursor:pointer;font-size:0.85rem;opacity:${rsvpVal===b.v?'1':'0.28'};padding:0 1px;"
                title="${b.tip}">${b.icon}</button>`).join('');
              // Attendance
              const attVal = s.source === 'excused' ? 'excused' : (s.attended ? 'present' : 'absent');
              const attBtns = [
                { v:'present', icon:'✅', tip:'Present' },
                { v:'absent',  icon:'❌', tip:'Absent'  },
                { v:'excused', icon:'🟦', tip:'Excused' },
              ].map(b => `<button data-sid="${s.sessionId}" data-type="att" data-val="${b.v}"
                style="border:none;background:none;cursor:pointer;font-size:0.85rem;opacity:${attVal===b.v?'1':'0.28'};padding:0 1px;"
                title="${b.tip}">${b.icon}</button>`).join('');
              return `<tr style="border-top:1px solid var(--border-color);">
                <td style="padding:5px 0;">
                  <div style="font-size:0.72rem;color:var(--text-primary);">${title}</div>
                  <div style="font-size:0.62rem;color:var(--text-muted);">${d}</div>
                </td>
                <td style="text-align:center;white-space:nowrap;">${rsvpBtns}</td>
                <td style="text-align:center;white-space:nowrap;">${attBtns}</td>
              </tr>`;
            }).join('');

            // Wire buttons
            tbody.querySelectorAll('button[data-type]').forEach(btn => {
              btn.addEventListener('click', async () => {
                const sid = parseInt(btn.dataset.sid);
                const type = btn.dataset.type;
                const val  = btn.dataset.val;
                const session = sessions.find(s => s.sessionId === sid);
                if (!session) return;

                if (type === 'att') {
                  const attended = val === 'present';
                  const source   = val === 'excused' ? 'excused' : 'manual';
                  await this.auth.fetch(`/api/eligibility/player/${playerId}/attendance`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ sessionId: sid, attended, source })
                  }).catch(() => {});
                  session.attended = attended;
                  session.source   = source;
                  // Recompute player session count
                  player.sessionsAttended = sessions.filter(s => s.attended).length;
                  this.renderAllZones();
                } else {
                  // RSVP update — use existing match RSVP endpoint isn't per-session
                  // Just update visually for now (no per-session RSVP API)
                  session.rsvp = val;
                }
                renderSessions(sessions);
              });
            });
          };
          renderSessions(sessions);
        })
        .catch(() => { practicesBody.textContent = 'Could not load sessions.'; });
    } else {
      if (practicesBody) practicesBody.textContent = 'Open from a match to see sessions.';
    }

    overlay.querySelector('.attendance-close-btn').addEventListener('click', () => overlay.remove());
    overlay.addEventListener('click', (e) => { if (e.target === overlay) overlay.remove(); });

    // ── Shared save logic (called on any field change) ────────────────────────
    const saveStatus = overlay.querySelector('#ep-save-status');
    let saveTimer = null;
    const scheduleSave = () => {
      if (saveStatus) saveStatus.textContent = 'Saving...';
      if (saveTimer) clearTimeout(saveTimer);
      saveTimer = setTimeout(async () => {
        const designated       = overlay.querySelector('#ep-designated').checked;
        const numClubs         = parseInt(overlay.querySelector('#ep-numclubs').value);
        const family           = overlay.querySelector('#ep-family').checked;
        const isKeeper         = overlay.querySelector('#ep-keeper').checked;
        const jersey           = overlay.querySelector('#ep-jersey').value.trim() || null;
        const isInjured        = overlay.querySelector('#ep-injured').checked;
        const isSuspLeague     = overlay.querySelector('#ep-susp-league').checked;
        const isSuspInhouse    = overlay.querySelector('#ep-susp-inhouse').checked;
        const eligApslStarter  = overlay.querySelector('#elig-apsl-starter').checked;
        const eligApslBench    = overlay.querySelector('#elig-apsl-bench').checked;
        const eligLiga1Starter = overlay.querySelector('#elig-liga1-starter').checked;
        const eligLiga1Bench   = overlay.querySelector('#elig-liga1-bench').checked;
        const eligLiga2Starter = overlay.querySelector('#elig-liga2-starter').checked;
        const eligLiga2Bench   = overlay.querySelector('#elig-liga2-bench').checked;
        const dobVal           = overlay.querySelector('#ep-dob')?.value.trim() || '';
        const reqOverrideStr   = overlay.querySelector('#ep-req-override')?.value.trim();
        const reqOverride      = reqOverrideStr !== '' ? parseInt(reqOverrideStr) : null;

        player.isDesignated       = designated;
        player.numClubs           = numClubs;
        player.hasFamilyDiscount  = family;
        player.isKeeper           = isKeeper;
        player.jerseyNumber       = jersey;
        player.isInjured          = isInjured;
        player.isSuspendedLeague  = isSuspLeague;
        player.isSuspendedInhouse = isSuspInhouse;
        player.eligApslStarter    = eligApslStarter;
        player.eligApslBench      = eligApslBench;
        player.eligLiga1Starter   = eligLiga1Starter;
        player.eligLiga1Bench     = eligLiga1Bench;
        player.eligLiga2Starter   = eligLiga2Starter;
        player.eligLiga2Bench     = eligLiga2Bench;
        if (dobVal) player.dateOfBirth = dobVal;
        player.requiredSessionsOverride = reqOverride;

        if (this.policy?.minSessionsToStart !== undefined) {
          const effectiveMin = family
            ? Math.max(0, this.policy.minSessionsToStart - (this.policy.familyDiscount || 1))
            : this.policy.minSessionsToStart;
          const s = player.sessionsAttended || 0;
          if (s >= (this.policy.priorityStarterSessions || 999)) player.eligibilityStatus = 'priority_starter';
          else if (s >= effectiveMin) player.eligibilityStatus = designated ? 'priority_starter' : 'eligible_starter';
          else if (s > 0) player.eligibilityStatus = designated ? 'eligible_starter' : 'bench_only';
          else player.eligibilityStatus = designated ? 'bench_only' : 'ineligible';
        }

        try {
          const flagsPayload = {
            isDesignated: designated, numClubs, hasFamilyDiscount: family, isKeeper,
            jerseyNumber: jersey, internalRole: player.internalRole || '',
            isInjured, isSuspendedLeague: isSuspLeague, isSuspendedInhouse: isSuspInhouse,
            eligApslStarter, eligApslBench, eligLiga1Starter, eligLiga1Bench,
            eligLiga2Starter, eligLiga2Bench,
            requiredSessionsOverride: reqOverride
          };
          const saves = [
            this.auth.fetch(`/api/eligibility/player/${player.playerId}/flags`, {
              method: 'PUT',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify(flagsPayload)
            })
          ];
          // Save DOB to persons table if changed
          if (dobVal && dobVal !== (player.dateOfBirth || '')) {
            saves.push(this.auth.fetch(`/api/eligibility/person/${player.personId}/dob`, {
              method: 'PUT',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ dateOfBirth: dobVal })
            }));
          }
          await Promise.all(saves);
          if (saveStatus) { saveStatus.textContent = '✓ Saved'; setTimeout(() => { if (saveStatus) saveStatus.textContent = ''; }, 2000); }
        } catch (err) {
          if (saveStatus) saveStatus.textContent = '⚠ Save failed';
          console.warn('Could not persist player flags:', err.message);
        }
        this._enforceApslFilter();
        this.renderAllZones();
      }, 600);
    };

    overlay.querySelectorAll('input[type=checkbox], input[type=text], select').forEach(el => {
      el.addEventListener('change', scheduleSave);
    });
    const jerseyInput = overlay.querySelector('#ep-jersey');
    if (jerseyInput) jerseyInput.addEventListener('blur', scheduleSave);

    // Remove from lineup button
    const removeBtn = overlay.querySelector('#ep-remove-btn');
    if (removeBtn) {
      removeBtn.addEventListener('click', () => {
        this.movePlayerToZone(playerId, 'pool');
        overlay.remove();
        this.renderAllZones();
      });
    }

    // Move to zone buttons
    overlay.querySelectorAll('[data-action]').forEach(btn => {
      btn.addEventListener('click', () => {
        const actionMap = {
          'to-bench':       'bench',
          'to-alternates':  'alternates',
          'to-starting':    'starting',
          'to-pool':        'pool',
        };
        const zone = actionMap[btn.dataset.action];
        if (!zone) return;
        this.movePlayerToZone(playerId, zone);
        overlay.remove();
        this.renderAllZones();
      });
    });

    // RSVP buttons
    overlay.querySelectorAll('[data-rsvp]').forEach(btn => {
      btn.addEventListener('click', async () => {
        const v = btn.dataset.rsvp;
        await this.updatePlayerRsvp(playerId, v);
        // Update button highlight
        overlay.querySelectorAll('[data-rsvp]').forEach(b => {
          const sel = b.dataset.rsvp === v;
          b.style.borderColor = sel ? '#2563eb' : 'var(--border-color)';
          b.style.background  = sel ? 'rgba(37,99,235,0.2)' : 'var(--bg-surface)';
          b.style.fontWeight  = sel ? '700' : '400';
        });
      });
    });

  }

  openSlotPicker(slotIndex, e) {
    const allZoned = new Set([...this.zones.starting, ...this.zones.bench, ...this.zones.alternates]);
    const available = this._rankPlayers([
      ...this.zones.bench.map(id => this.getPlayerById(id)),
      ...this.zones.alternates.map(id => this.getPlayerById(id)),
      ...this.players.filter(p => !allZoned.has(p.playerId))
    ].filter(Boolean));

    if (available.length === 0) {
      this.showLineupToast('No players available to assign');
      return;
    }

    const positions = this.getPositionsForFormation(this.selectedFormation?.code || '4-3-3');
    const label = positions[slotIndex]?.label || `Slot ${slotIndex + 1}`;

    const itemsHtml = available.map(p => {
      const name = `${p.firstName || ''} ${p.lastName || ''}`.trim();
      const eligIcon = this.getStatusIcon(p.eligibilityStatus);
      const rsvp = p.matchRsvp === 'yes' ? '🟢' : p.matchRsvp === 'no' ? '🔴' : '🟡';
      const badges = [];
      if (p.isDesignated) badges.push('<span style="background:#f59e0b;color:#000;border-radius:3px;padding:0 3px;font-size:0.6rem;font-weight:700;">D</span>');
      if ((p.sessionsAttended || 0) >= 2) badges.push('<span style="background:#22c55e;color:#000;border-radius:3px;padding:0 3px;font-size:0.6rem;font-weight:700;">✓</span>');
      if ((p.numClubs || 1) > 1) badges.push('<span style="background:#f97316;color:#000;border-radius:3px;padding:0 3px;font-size:0.6rem;font-weight:700;">2C</span>');
      const zone = this.zones.bench.includes(p.playerId) ? '<span style="font-size:0.7rem;opacity:0.45;">bench</span>' : '';
      return `<button class="pitch-popover-item" data-action="assign" data-player-id="${p.playerId}" data-slot="${slotIndex}"
        style="display:flex;align-items:center;gap:5px;width:100%;text-align:left;padding:6px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;">
        ${rsvp} <span style="flex:1;">${name}</span> ${badges.join('')} ${zone} ${eligIcon} <span style="opacity:0.45;font-size:0.72rem;">${p.sessionsAttended || 0}</span>
      </button>`;
    }).join('');

    const pop = this._buildPitchPopover(e, `
      <div style="font-size:0.8rem;font-weight:600;padding:2px 4px 6px;border-bottom:1px solid var(--border-color);margin-bottom:4px;">Assign to ${label}</div>
      <div style="max-height:220px;overflow-y:auto;">${itemsHtml}</div>
    `);

    pop.addEventListener('click', (ev) => {
      const item = ev.target.closest('.pitch-popover-item');
      if (!item || item.dataset.action !== 'assign') return;
      const pid = parseInt(item.dataset.playerId);
      const slot = parseInt(item.dataset.slot);
      this.removePlayerFromAllZones(pid);
      this.zones.starting.splice(slot, 0, pid);
      if (this.zones.starting.length > 11) {
        const overflow = this.zones.starting.splice(11);
        this.zones.alternates.push(...overflow);
      }
      this._dismissPitchPopover();
      this.renderAllZones();
    });
  }

  onExit() {
    document.body.style.overflow = '';
    document.body.classList.remove('pitch-fit-active');
    this.pitchFit = false;
    if (this.element) {
      this.element.classList.remove('lineup-fit-screen');
    }
  }
}
