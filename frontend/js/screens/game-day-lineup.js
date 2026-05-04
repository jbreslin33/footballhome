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

      // Attendance popup on player card tap (not on buttons)
      const card = e.target.closest('.lineup-player-card');
      if (card && !e.target.closest('button')) {
        const playerId = parseInt(card.dataset.playerId);
        this.openAttendancePopup(playerId);
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
        if (player.onLineup && player.isStarter) {
          this.zones.starting.push(player.playerId);
        } else if (player.onLineup && !player.isStarter) {
          if (this.zones.bench.length < maxBench) {
            this.zones.bench.push(player.playerId);
          } else {
            this.zones.alternates.push(player.playerId);
          }
        }
        // players not onLineup are implicitly in not-responded/not-going (derived from RSVP)
      }
      return;
    }

    // No saved lineup — auto-distribute from RSVP
    this._autoDistribute();
  }

  _autoDistribute() {
    this.zones = { starting: [], bench: [], alternates: [] };
    const maxBench = this.rosterSize - 11;

    // Sort going players: eligible first, then by practices
    const statusOrder = { priority_starter: 0, eligible_starter: 1, bench_only: 2, ineligible: 3, not_computed: 4, not_on_roster: 5 };
    const going = this.players
      .filter(p => p.matchRsvp === 'yes')
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
      .filter(p => p.matchRsvp !== 'yes' && p.matchRsvp !== 'no')
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
    this.renderZoneSections();
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
    const notResponded = this.players.filter(p => !allZoned.has(p.playerId) && p.matchRsvp !== 'no');
    const notGoing = this.players.filter(p => !allZoned.has(p.playerId) && p.matchRsvp === 'no');

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
          alternates: this.zones.alternates.map(playerId => ({ playerId })),
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
