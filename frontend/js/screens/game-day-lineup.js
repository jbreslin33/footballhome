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
    this.formationLocked = false; // legacy compat — now means movement locked (no drag)
    this.pitchMoveLocked = false;  // keep dragging enabled by default in fluid pitch mode
    this.customPositions = null; // null = not set; array of {x,y,label} in canonical 0-100 space
    this.customDragMode = 'slots'; // 'slots' = move holder; 'players' = swap players between slots
    this._saveMetaTimer = null;  // debounce handle for auto-save
    this._saveLineupTimer = null; // debounce handle for lineup auto-save
    this._stopPitchLoop = this._stopPitchLoop || (() => {}); // forward-declare for early calls
    this.teamMatches = [];        // cached list for the match picker
    this._matchResolveInFlight = null;
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
          <div id="lineup-match-picker-wrap" style="display:none;margin-top:4px;">
            <label for="lineup-match-picker" style="font-size:0.72rem;opacity:0.7;margin-right:4px;">Match:</label>
            <select id="lineup-match-picker" style="font-size:0.78rem;padding:2px 6px;border-radius:4px;border:1px solid var(--border-color);background:var(--bg-secondary,#0b1220);color:inherit;max-width:100%;"></select>
          </div>
        </div>
        <button id="save-lineup-btn" class="btn btn-primary">💾 Save</button>
      </div>

      <div class="lineup-container" style="padding:0 12px 80px;">
        <!-- Data sync panel -->
        <div id="sync-panel" style="display:none;margin:8px 0 4px;"></div>

        <div id="lineup-loading" class="loading-state">
          <div class="spinner"></div>
          <p id="lineup-loading-text">Computing eligibility...</p>
          <div id="loading-sync-activity" style="display:none;margin:8px auto 6px;max-width:760px;text-align:left;font-size:0.75rem;line-height:1.35;color:#cbd5e1;padding:8px 10px;border-radius:8px;background:rgba(2,6,23,0.8);border:1px solid rgba(100,116,139,0.3);"></div>
          <div id="loading-progress-log" style="display:none;margin:0 auto;max-width:760px;text-align:left;font-size:0.74rem;line-height:1.35;color:#cbd5e1;padding:8px 10px;border-radius:8px;background:rgba(2,6,23,0.7);border:1px solid rgba(100,116,139,0.25);"></div>
          <div id="loading-continue-panel" style="display:none;margin:10px auto 0;max-width:760px;text-align:left;padding:10px;border-radius:8px;background:rgba(15,23,42,0.85);border:1px solid rgba(148,163,184,0.35);">
            <div id="loading-continue-message" style="font-size:0.8rem;color:#e2e8f0;margin-bottom:8px;"></div>
            <div style="display:flex;gap:8px;flex-wrap:wrap;">
              <button id="loading-continue-btn" class="btn btn-primary" style="font-size:0.8rem;padding:6px 12px;">Continue to lineup</button>
              <button id="loading-retry-btn" class="btn btn-secondary" style="font-size:0.8rem;padding:6px 12px;">Retry load</button>
            </div>
          </div>
        </div>

        <div id="lineup-content" style="display:none;">

          <div id="gm-last-sync" style="display:none;"></div>
          <div id="sync-activity" style="display:none;"></div>

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

          <!-- Coach: Share & Visibility panel -->
          <div id="share-panel" style="display:none;margin:8px 0 12px;padding:10px 12px;background:rgba(2,6,23,0.6);border:1px solid rgba(148,163,184,0.3);border-radius:8px;font-size:0.85rem;">
            <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;margin-bottom:8px;">
              <strong>🔗 Share / Visibility</strong>
              <button id="share-pin-btn" class="btn btn-secondary btn-sm" style="font-size:0.78rem;">📌 Pin as live match</button>
              <label style="display:flex;align-items:center;gap:4px;cursor:pointer;"><input type="checkbox" id="share-hide-gameday"> Hide game-day roster</label>
              <label style="display:flex;align-items:center;gap:4px;cursor:pointer;"><input type="checkbox" id="share-hide-lineup" checked> Hide lineup (starters/bench)</label>
            </div>
            <div style="display:grid;grid-template-columns:auto 1fr auto;gap:6px 8px;align-items:center;">
              <span style="opacity:0.7;">Game day:</span>
              <code id="share-url-gameday" style="padding:4px 6px;background:rgba(255,255,255,0.05);border-radius:4px;font-size:0.78rem;overflow-x:auto;white-space:nowrap;"></code>
              <button class="btn btn-sm share-copy-btn" data-target="share-url-gameday" style="font-size:0.75rem;">Copy</button>
              <span style="opacity:0.7;">Lineup:</span>
              <code id="share-url-lineup" style="padding:4px 6px;background:rgba(255,255,255,0.05);border-radius:4px;font-size:0.78rem;overflow-x:auto;white-space:nowrap;"></code>
              <button class="btn btn-sm share-copy-btn" data-target="share-url-lineup" style="font-size:0.75rem;">Copy</button>
            </div>
          </div>

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
    // Defensive: clear any leftover body scroll lock from a previous pitch
    // view (the fullscreen pitch overlay adds `pitch-fit-active` to <body>
    // which sets `overflow: hidden`). Without this, the loading panel and
    // any async-loaded buttons can be stuck below the viewport.
    document.body.classList.remove('pitch-fit-active');
    if (this.element) this.element.classList.remove('lineup-fit-screen');
    this.pitchFit = false;

    if (!this._listenersAttached) {
      this._listenersAttached = true;
      this.attachEventListeners();
      this.loadFormations();
    }
    this._bootstrap();
  }

  /**
   * Bootstrap order: make sure a match is selected (auto-resolve to the
   * team's next/live match if the caller did not pre-select one), populate
   * the match-picker dropdown, then run the normal sync + load flow.
   */
  async _bootstrap() {
    try {
      await this.ensureMatchSelected();
    } catch (err) {
      console.warn('[lineup] match auto-resolve failed:', err);
    }
    this.renderMatchPicker();
    this.syncThenLoad();
    this.loadSavedMetadata();
    this.loadLeaguesSyncStatus();
    this.loadShareInfo();
  }

  /**
   * If navigation context has no match.id, look up the team's matches and
   * pick a sensible default:
   *   1. The earliest upcoming (or currently-live) match that has not ended.
   *   2. Failing that, the most recent past match.
   */
  async ensureMatchSelected() {
    const ctx = this.navigation.context;
    const teamId = ctx.lineupTeamId || ctx.team?.id;
    if (!teamId) return;

    // Refresh the cached match list so the picker reflects current schedule.
    if (!this._matchResolveInFlight) {
      this._matchResolveInFlight = this._fetchTeamMatches(teamId)
        .finally(() => { this._matchResolveInFlight = null; });
    }
    const matches = await this._matchResolveInFlight;
    this.teamMatches = Array.isArray(matches) ? matches : [];

    if (ctx.match?.id) return; // caller already chose one — respect override

    const def = this._pickDefaultMatch(this.teamMatches);
    if (def) {
      ctx.match = { id: def.id, title: def.title, event_date: def.event_date };
    }
  }

  // Chat-provider calendar sync was removed. Kept as a no-op so any
  // remaining callers stay happy.
  async _syncTeamCalendar(_teamId) {
    this.calendarSyncFailure = null;
  }

  async _fetchTeamMatches(teamId) {
    try {
      const res = await this.auth.fetch(`/api/matches/team/${teamId}`);
      const data = await res.json();
      return data?.data || [];
    } catch (err) {
      console.warn('[lineup] fetch team matches failed:', err);
      return [];
    }
  }

  _pickDefaultMatch(matches) {
    if (!matches?.length) return null;
    // Matches arrive DESC; clone + sort ASC by event_date for "next" logic.
    const asc = [...matches].sort((a, b) => {
      const ta = new Date(a.event_date).getTime();
      const tb = new Date(b.event_date).getTime();
      return ta - tb;
    });
    const now = Date.now();
    // Live-window cutoff: a match started within the last 3h still counts as
    // "current" so coaches landing on the page mid-game don't skip to next week.
    const liveCutoff = now - 3 * 60 * 60 * 1000;
    const upcoming = asc.find(m => !m.has_ended && new Date(m.event_date).getTime() >= liveCutoff);
    if (upcoming) return upcoming;
    // Otherwise fall back to most recent past match.
    return asc[asc.length - 1] || null;
  }

  renderMatchPicker() {
    const wrap = this.find('#lineup-match-picker-wrap');
    const select = this.find('#lineup-match-picker');
    if (!wrap || !select) return;
    if (!this.teamMatches?.length) {
      wrap.style.display = 'none';
      return;
    }
    const currentId = String(this.navigation.context.match?.id || '');
    // Show upcoming/live first, then recent past (limit to a reasonable window).
    const asc = [...this.teamMatches].sort(
      (a, b) => new Date(a.event_date).getTime() - new Date(b.event_date).getTime()
    );
    const now = Date.now();
    const upcoming = asc.filter(m => new Date(m.event_date).getTime() >= now - 3 * 60 * 60 * 1000);
    const past = asc.filter(m => new Date(m.event_date).getTime() < now - 3 * 60 * 60 * 1000).slice(-5).reverse();
    const fmt = (m) => {
      const d = new Date(m.event_date);
      const dateStr = isNaN(d) ? '' : d.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
      return `${dateStr} — ${m.title || 'Match'}`;
    };
    const opts = [];
    if (upcoming.length) {
      opts.push('<optgroup label="Upcoming / live">');
      upcoming.forEach(m => opts.push(
        `<option value="${m.id}"${String(m.id) === currentId ? ' selected' : ''}>${this.escapeHTML(fmt(m))}</option>`
      ));
      opts.push('</optgroup>');
    }
    if (past.length) {
      opts.push('<optgroup label="Recent past">');
      past.forEach(m => opts.push(
        `<option value="${m.id}"${String(m.id) === currentId ? ' selected' : ''}>${this.escapeHTML(fmt(m))}</option>`
      ));
      opts.push('</optgroup>');
    }
    select.innerHTML = opts.join('');
    wrap.style.display = '';
  }

  escapeHTML(str) {
    return String(str ?? '').replace(/[&<>"']/g, (c) => (
      { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]
    ));
  }

  _onMatchPickerChange(newId) {
    if (!newId) return;
    const picked = this.teamMatches.find(m => String(m.id) === String(newId));
    if (!picked) return;
    this.navigation.context.match = {
      id: picked.id,
      title: picked.title,
      event_date: picked.event_date,
    };
    // Reset per-match transient state and reload.
    this.zones = { starting: [], bench: [], alternates: [] };
    this.playerPositions = {};
    this.customPositions = null;
    this.syncThenLoad();
    this.loadSavedMetadata();
    this.loadShareInfo();
  }

  /**
   * Load eligibility data. Older versions ran a chat-provider RSVP sync first;
   * the provider was removed so this is now a thin wrapper around the
   * eligibility load.
   */
  async syncThenLoad() {
    const failures = [];

    this.find('#lineup-content').style.display = 'none';
    this.find('#lineup-loading').style.display = 'block';
    this.hideLoadingContinuePanel();
    this.clearLoadingProgressLog();
    this.setLoadingStatus('Computing eligibility...');

    this.lastSyncedAt = null;
    this.syncFailed = false;

    const loaded = await this.loadEligibilityData();
    if (!loaded) failures.push('Eligibility load failed.');
    this.showLoadingContinuePanel(failures);
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
      if (e.target.id === 'share-pin-btn' || e.target.closest('#share-pin-btn')) {
        this.toggleLiveMatchPin();
        return;
      }
      const copyBtn = e.target.closest('.share-copy-btn');
      if (copyBtn) {
        const targetId = copyBtn.getAttribute('data-target');
        const el = this.find('#' + targetId);
        if (el) {
          navigator.clipboard.writeText(el.textContent).then(() => {
            const orig = copyBtn.textContent;
            copyBtn.textContent = '✓ Copied';
            setTimeout(() => { copyBtn.textContent = orig; }, 1500);
          }).catch(() => {});
        }
        return;
      }
      if (e.target.id === 'loading-continue-btn' || e.target.closest('#loading-continue-btn')) {
        this.continueToLineupContent();
        return;
      }
      if (e.target.id === 'loading-retry-btn' || e.target.closest('#loading-retry-btn')) {
        this.syncThenLoad();
        return;
      }

      // Sync panel buttons
      const syncBtn = e.target.closest('[data-sync-action]');
      if (syncBtn) {
        const action = syncBtn.dataset.syncAction;
        if (action === 'scrape-apsl') this.requestScrape('apsl-teams');
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
      if (e.target.id === 'pitch-lock-btn' || e.target.closest('#pitch-lock-btn')) {
        this.pitchMoveLocked = !this.pitchMoveLocked;
        this.formationLocked = this.pitchMoveLocked; // keep in sync for save compat
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

      // (link-player button removed along with chat-provider integration)

      // (link-roster-to-gm pill removed along with chat-provider integration)

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

    // Training attendance checkbox toggle + match picker
    this.element.addEventListener('change', (e) => {
      const cb = e.target.closest('.train-cb');
      if (cb) {
        e.stopPropagation();
        this.toggleTrainingAttendance(cb);
        return;
      }
      if (e.target && e.target.id === 'lineup-match-picker') {
        this._onMatchPickerChange(e.target.value);
        return;
      }
    });
  }

  // ============================================================================
  // Data Loading
  // ============================================================================
  async loadEligibilityData() {
    const matchId = this.navigation.context.match?.id;
    if (!matchId) {
      const hint = this.teamMatches?.length
        ? 'Pick a match from the dropdown above.'
        : 'No upcoming match found for this team.';
      this.find('#lineup-loading').innerHTML =
        `<p style="color:var(--color-danger);">No match selected.</p><p class="text-muted" style="font-size:0.85rem;">${hint}</p>`;
      return false;
    }

    try {
      const teamId = this.navigation.context.lineupTeamId || this.navigation.context.team?.id || '';
      const teamParam = teamId ? `?teamId=${teamId}` : '';
      this.setLoadingStatus('Computing eligibility and lineup data...');
      this.appendLoadingProgress('Fetching eligibility, training week, and game roster...');

      // Fetch eligibility, training week, and game roster in parallel.
      // (Chat-provider members fetch removed along with the provider integration.)
      const [eligResponse, trainingResponse, rosterResponse] = await Promise.all([
        this.auth.fetch(`/api/eligibility/match/${matchId}${teamParam}`),
        teamId ? this.auth.fetch(`/api/events/training-week/${teamId}?matchId=${matchId}`).catch(() => null) : Promise.resolve(null),
        this.auth.fetch(`/api/matches/${matchId}/game-roster`)
      ]);
      this.appendLoadingProgress('Responses received. Parsing eligibility and sync metadata...');

      const data = await eligResponse.json();
      if (!data.success) throw new Error(data.message || 'Failed to load eligibility');

      this.matchInfo = data.data.match;
      this.policy = data.data.policy;
      this.players = data.data.players || [];
      this.unmatchedRsvps = data.data.unmatchedRsvps || [];
      this.appendLoadingProgress('Eligibility loaded.');

      // Chat-provider member merge removed; no per-team members fetch anymore.
      this.clubTeams = [];
      this.allChats = [];

      // Load training week data
      this.trainingEvents = [];
      this.trainingData = new Map();
      if (trainingResponse) {
        const trainingResult = await trainingResponse.json().catch(() => null);
        if (trainingResult && trainingResult.success && trainingResult.data) {
          this.trainingEvents = (trainingResult.data.events || []).map(evt => ({
            ...evt,
            syncMinutesAgo: Number.isFinite(evt?.syncMinutesAgo) ? evt.syncMinutesAgo : null,
            lastSync: evt?.lastSync || null,
          }));
          this.mergeTrainingData(trainingResult.data.players || []);
          this.recomputeSessionsFromTrainingWeek();
          this.appendLoadingProgress(`Training/pickup events loaded: ${this.trainingEvents.length}.`);
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
          this.appendLoadingProgress(`Game roster loaded: ${this.gameDayRosterIds.size} players.`);
        }
      }

      // Update training day column headers
      this.updateTrainingHeaders();

      // Update subtitle
      const subtitle = this.find('#lineup-subtitle');
      subtitle.textContent = `${this.matchInfo.homeTeam} vs ${this.matchInfo.awayTeam} — ${this.matchInfo.date}`;

      // (chat-provider sync warning removed)

      // Render policy bar
      this.renderPolicyBar();

      // Auto-classify players into zones based on eligibility + RSVP + existing lineup
      this.classifyPlayersIntoZones();
      this.appendLoadingProgress('Lineup zones classified. Rendering screen...');

      this.renderAllZones();

      return true;



    } catch (error) {
      console.error('Error loading eligibility:', error);
      this.appendLoadingProgress(`Eligibility load failed: ${error.message}`);
      return false;
    }
  }

  _playerIdentityKey(player) {
    if (!player) return '';
    if (player.personId) return `person:${player.personId}`;
    if (player.gmUserId) return `gm:${player.gmUserId}`;
    if (player.playerId) return `player:${player.playerId}`;
    const name = `${player.firstName || ''} ${player.lastName || ''}`.trim().toLowerCase();
    return name ? `name:${name}` : '';
  }

  _playerMergeScore(player) {
    if (!player) return 0;
    let score = 0;
    if (player.personId) score += 8;
    if (player.playerId) score += 5;
    if (player.gmUserId) score += 4;
    if (player.onLineup) score += 3;
    if (player.matchRsvp) score += 2;
    if ((player.sessionsAttended || 0) > 0) score += 1;
    if ((player.teams || []).length > 0) score += 1;
    return score;
  }

  _mergePlayerRecords(a, b) {
    const scoreA = this._playerMergeScore(a);
    const scoreB = this._playerMergeScore(b);
    const primary = scoreB > scoreA ? b : a;
    const secondary = primary === a ? b : a;
    const merged = { ...secondary, ...primary };

    const mergedTeams = [];
    const seenTeams = new Set();
    for (const t of [...(a.teams || []), ...(b.teams || [])]) {
      const teamKey = `${t.teamId || ''}-${t.playerId || ''}`;
      if (seenTeams.has(teamKey)) continue;
      seenTeams.add(teamKey);
      mergedTeams.push(t);
    }

    merged.teams = mergedTeams;
    merged.sessionsAttended = Math.max(a.sessionsAttended || 0, b.sessionsAttended || 0);
    merged.practiceCount = Math.max(a.practiceCount || 0, b.practiceCount || 0);
    merged.onLineup = !!(a.onLineup || b.onLineup);
    merged.isStarter = !!(a.isStarter || b.isStarter);
    merged.gmLinked = !!(a.gmLinked || b.gmLinked);

    // Preserve stable identity fields from either side (never drop to null).
    merged.playerId = primary.playerId ?? secondary.playerId ?? null;
    merged.personId = primary.personId ?? secondary.personId ?? null;
    merged.gmUserId = primary.gmUserId ?? secondary.gmUserId ?? null;

    const nonEmpty = (...values) => {
      for (const value of values) {
        if (value == null) continue;
        if (typeof value === 'string' && !value.trim()) continue;
        return value;
      }
      return null;
    };

    // Keep enriched fields from whichever source has real data.
    merged.jerseyNumber = nonEmpty(primary.jerseyNumber, secondary.jerseyNumber);
    merged.position = nonEmpty(primary.position, secondary.position);
    merged.dateOfBirth = nonEmpty(primary.dateOfBirth, secondary.dateOfBirth, primary.dob, secondary.dob, primary.date_of_birth, secondary.date_of_birth);
    merged.paymentStatus = nonEmpty(primary.paymentStatus, secondary.paymentStatus, primary.payment_status, secondary.payment_status);
    merged.registrationStatus = nonEmpty(primary.registrationStatus, secondary.registrationStatus, primary.registration_status, secondary.registration_status);
    merged.onOfficialRoster = !!(a.onOfficialRoster || b.onOfficialRoster);
    merged.isRegistered = (() => {
      const val = nonEmpty(primary.isRegistered, secondary.isRegistered, primary.registered, secondary.registered);
      return val == null ? null : this._boolish(val);
    })();
    merged.isPaid = (() => {
      const val = nonEmpty(primary.isPaid, secondary.isPaid, primary.paid, secondary.paid);
      return val == null ? null : this._boolish(val);
    })();

    // Keep most informative name if one side is blank.
    merged.firstName = (primary.firstName && String(primary.firstName).trim())
      ? primary.firstName
      : secondary.firstName;
    merged.lastName = (primary.lastName && String(primary.lastName).trim())
      ? primary.lastName
      : secondary.lastName;

    return merged;
  }

  _dedupePlayers(players) {
    const byKey = new Map();
    const passthrough = [];

    for (const player of players || []) {
      const key = this._playerIdentityKey(player);
      if (!key) {
        passthrough.push(player);
        continue;
      }
      if (!byKey.has(key)) {
        byKey.set(key, player);
      } else {
        byKey.set(key, this._mergePlayerRecords(byKey.get(key), player));
      }
    }

    return [...byKey.values(), ...passthrough];
  }

  _practiceLookbackCount() {
    return 5;
  }

  _ageFromDob(dob, asOf = new Date()) {
    if (!dob) return null;
    const born = new Date(dob);
    if (!Number.isFinite(born.getTime())) return null;

    let age = asOf.getFullYear() - born.getFullYear();
    const monthDelta = asOf.getMonth() - born.getMonth();
    if (monthDelta < 0 || (monthDelta === 0 && asOf.getDate() < born.getDate())) {
      age -= 1;
    }
    return age >= 0 ? age : null;
  }

  _ageBasedRequiredSessions(player) {
    if (!player) return 1;
    if (player.isKeeper || player.isChild) return 0;

    const age = this._ageFromDob(player.dateOfBirth, new Date());
    if (age == null) return 1;
    if (age <= 17) return 3;
    if (age <= 22) return 2;
    return 1;
  }

  _hasKnownAge(player) {
    return this._ageFromDob(player?.dateOfBirth, new Date()) != null;
  }

  _formatDobForCard(player) {
    const raw = player?.dateOfBirth || player?.dob || player?.date_of_birth || '';
    if (!raw) return '\u2014';

    const dt = new Date(raw);
    if (!Number.isFinite(dt.getTime())) return '\u2014';

    const y = dt.getFullYear();
    const m = String(dt.getMonth() + 1).padStart(2, '0');
    const d = String(dt.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  _boolish(value) {
    if (value == null) return null;
    if (typeof value === 'boolean') return value;
    if (typeof value === 'number') return value !== 0;
    if (typeof value !== 'string') return null;

    const normalized = value.trim().toLowerCase();
    if (!normalized) return null;

    if (['true', 'yes', 'y', '1', 'paid', 'complete', 'completed', 'confirmed', 'registered', 'active'].includes(normalized)) {
      return true;
    }
    if (['false', 'no', 'n', '0', 'unpaid', 'cancelled', 'canceled', 'withdrawn', 'refunded', 'inactive'].includes(normalized)) {
      return false;
    }
    return null;
  }

  _registeredLabel(player) {
    const direct = [
      player?.registered,
      player?.isRegistered,
      player?.registrationComplete,
    ];
    for (const val of direct) {
      const b = this._boolish(val);
      if (b === true) return 'Yes';
      if (b === false) return 'No';
    }

    const statusRaw = String(player?.registrationStatus || player?.registration_status || '').trim();
    if (!statusRaw) return 'No';

    const s = statusRaw.toLowerCase();
    if (s.includes('reserved') || s.includes('registered') || s.includes('confirmed') || s.includes('complete') || s.includes('active')) {
      return 'Yes';
    }
    if (s.includes('pending') || s.includes('wait')) {
      return 'Pending';
    }
    if (s.includes('cancel') || s.includes('withdrawn') || s.includes('declin') || s.includes('expired')) {
      return 'No';
    }
    return statusRaw;
  }

  _paidLabel(player) {
    const direct = [
      player?.paid,
      player?.isPaid,
      player?.paymentComplete,
    ];
    for (const val of direct) {
      const b = this._boolish(val);
      if (b === true) return 'Yes';
      if (b === false) return 'No';
    }

    const statusRaw = String(player?.paymentStatus || player?.payment_status || '').trim();
    if (!statusRaw) return 'No';

    const s = statusRaw.toLowerCase();
    if (s.includes('partial')) return 'Partial';
    if (s.includes('paid') || s.includes('complete') || s.includes('free') || s.includes('complimentary')) {
      return 'Yes';
    }
    if (s.includes('unpaid') || s.includes('past_due') || s.includes('past due') || s.includes('due') || s.includes('outstanding')) {
      return 'No';
    }
    return statusRaw;
  }

  _requiredSessionsFor(player) {
    if (!player) return 1;
    if (player.isKeeper || player.isChild) return 0;
    if (player.requiredSessionsOverride != null) return player.requiredSessionsOverride;
    return this._ageBasedRequiredSessions(player);
  }

  _matchTimeMs() {
    const raw = this.matchInfo?.eventDate
      || this.matchInfo?.matchDate
      || this.matchInfo?.date
      || this.navigation?.context?.match?.event_date
      || this.navigation?.context?.match?.date
      || '';
    const ts = new Date(raw).getTime();
    return Number.isFinite(ts) ? ts : null;
  }

  _canMeetPracticeByMatch(player) {
    const required = this._requiredSessionsFor(player);
    const lookback = this._practiceLookbackCount();
    const attended = Math.min(lookback, player.sessionsAttended || 0);
    if (attended >= required) return true;

    // Only count UPCOMING practices the player has actually RSVP'd "yes" to.
    // The backend gives us projectedSessions = sessionsAttended + future_rsvp_yes
    // (where future_rsvp_yes counts the player's "yes" RSVPs on training/pickup
    //  chat_events between now and the match). Future calendar slots they
    // haven't responded to do not count.
    const projected = Math.min(lookback, player.projectedSessions || 0);
    return projected >= required;
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

  recomputeSessionsFromTrainingWeek() {
    if (!this.trainingEvents?.length || !this.players?.length) return;

    const eventById = new Map();
    for (const evt of this.trainingEvents) {
      eventById.set(String(evt.id), evt);
    }

    for (const player of this.players) {
      if (!player?.personId) continue;
      const personAttendance = this.trainingData.get(player.personId) || {};
      const attendedDates = new Set();

      for (const [eventId, val] of Object.entries(personAttendance)) {
        const attended = (val === true) || (val && val.attended === true);
        if (!attended) continue;

        const evt = eventById.get(String(eventId));
        if (!evt) continue;
        if (evt.eventDate) attendedDates.add(evt.eventDate);
      }

      // Use the same computed value for both fields the UI reads.
      player.sessionsAttended = attendedDates.size;
      player.practiceCount = attendedDates.size;
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
   * Handle training attendance checkbox toggle.
   * Backend endpoint removed with chat-provider rip — checkbox is now read-only.
   */
  async toggleTrainingAttendance(cb) {
    cb.checked = !cb.checked; // revert; persistence not wired
    console.warn('training-attendance toggle is read-only after chat-provider removal');
  }

  async loadFormations() {
    try {
      this.formations = [
        { id: 0, code: 'custom', name: 'Custom' },
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

      // Default formation for ghost positions (Custom)
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
   * Load share info (slug + visibility flags) and populate the share panel.
   */
  async loadShareInfo() {
    const teamId = this.navigation.context.lineupTeamId || this.navigation.context.team?.id;
    if (!teamId) return;
    const matchId = this.navigation.context.match?.id;
    const url = matchId
      ? `/api/teams/${teamId}/share-info?matchId=${matchId}`
      : `/api/teams/${teamId}/share-info`;
    try {
      const response = await this.auth.fetch(url);
      const json = await response.json();
      if (!json.success || !json.data) return;
      this._shareInfo = json.data;
      this.renderSharePanel();
    } catch (e) {
      console.warn('Failed to load share info:', e);
    }
  }

  renderSharePanel() {
    const panel = this.find('#share-panel');
    if (!panel || !this._shareInfo) return;
    const info = this._shareInfo;
    const slug = info.slug || `team-${info.team_id}`;
    const base = `${window.location.origin}/#t/${encodeURIComponent(slug)}`;
    const gameDayUrl = this.find('#share-url-gameday');
    const lineupUrl = this.find('#share-url-lineup');
    if (gameDayUrl) gameDayUrl.textContent = `${base}/gameday`;
    if (lineupUrl) lineupUrl.textContent = `${base}/lineup`;

    const matchId = this.navigation.context.match?.id;
    const pinBtn = this.find('#share-pin-btn');
    if (pinBtn) {
      const isPinnedHere = info.live_match_pinned && info.live_match_id == matchId;
      pinBtn.textContent = isPinnedHere ? '📌 Unpin this match' : '📌 Pin as live match';
    }

    const m = info.match || {};
    const ghBox = this.find('#share-hide-gameday');
    const lhBox = this.find('#share-hide-lineup');
    if (ghBox) {
      ghBox.checked = !!m.gameday_hidden;
      ghBox.onchange = () => this.setVisibility({ gameday_hidden: ghBox.checked });
    }
    if (lhBox) {
      lhBox.checked = m.lineup_hidden !== false;
      lhBox.onchange = () => this.setVisibility({ lineup_hidden: lhBox.checked });
    }
    panel.style.display = 'block';
  }

  async toggleLiveMatchPin() {
    const teamId = this.navigation.context.lineupTeamId || this.navigation.context.team?.id;
    const matchId = this.navigation.context.match?.id;
    if (!teamId || !matchId) return;
    const info = this._shareInfo || {};
    const currentlyPinnedHere = info.live_match_pinned && info.live_match_id == matchId;
    const body = currentlyPinnedHere
      ? { pinned: false }
      : { match_id: Number(matchId), pinned: true };
    try {
      const r = await this.auth.fetch(`/api/teams/${teamId}/live-match`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });
      if (r.ok) {
        this.showToast(currentlyPinnedHere ? 'Unpinned' : 'Pinned as live');
        this.loadShareInfo();
      } else {
        this.showToast('Failed to update pin');
      }
    } catch (e) {
      this.showToast('Failed to update pin');
    }
  }

  async setVisibility(patch) {
    const matchId = this.navigation.context.match?.id;
    if (!matchId) return;
    try {
      const r = await this.auth.fetch(`/api/matches/${matchId}/visibility`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(patch)
      });
      if (r.ok) {
        this.showToast('Visibility updated');
        if (this._shareInfo) {
          this._shareInfo.match = { ...(this._shareInfo.match || {}), ...patch };
        }
      } else {
        this.showToast('Failed to update visibility');
      }
    } catch (e) {
      this.showToast('Failed to update visibility');
    }
  }

  showToast(msg) {
    const toast = this.find('#lineup-toast');
    if (!toast) return;
    toast.textContent = msg;
    toast.style.display = 'block';
    clearTimeout(this._toastTimer);
    this._toastTimer = setTimeout(() => { toast.style.display = 'none'; }, 1800);
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

      // Restore movement lock state
      if (meta.formationLocked === false) {
        this.formationLocked = false;
        this.pitchMoveLocked = false;
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
    this._writeLineupDraft();

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
    this._writeLineupDraft();
    if (this._saveLineupTimer) clearTimeout(this._saveLineupTimer);
    this._saveLineupTimer = setTimeout(() => { this.saveLineup(true); }, 1200);
  }

  _lineupDraftStorageKey() {
    const matchId = this.navigation?.context?.match?.id;
    if (!matchId) return null;
    const teamId = this.navigation?.context?.lineupTeamId || this.navigation?.context?.team?.id || 'default';
    return `footballhome:lineup-draft:${teamId}:${matchId}`;
  }

  _writeLineupDraft() {
    try {
      if (typeof window === 'undefined' || !window.localStorage) return;
      const key = this._lineupDraftStorageKey();
      if (!key) return;
      const payload = {
        updatedAt: Date.now(),
        rosterSize: this.rosterSize,
        zones: {
          starting: Array.from(this.zones.starting || []),
          bench: Array.from(this.zones.bench || []),
          alternates: Array.from(this.zones.alternates || []),
        },
      };
      window.localStorage.setItem(key, JSON.stringify(payload));
    } catch (e) {
      console.warn('Failed to persist lineup draft:', e);
    }
  }

  _readLineupDraft() {
    try {
      if (typeof window === 'undefined' || !window.localStorage) return null;
      const key = this._lineupDraftStorageKey();
      if (!key) return null;
      const raw = window.localStorage.getItem(key);
      if (!raw) return null;
      const parsed = JSON.parse(raw);
      if (!parsed || typeof parsed !== 'object' || !parsed.zones) return null;
      return parsed;
    } catch (e) {
      console.warn('Failed to read lineup draft:', e);
      return null;
    }
  }

  _normalizeZonesFromSource(sourceZones) {
    const maxBench = this.rosterSize - 11;
    const validIds = new Set(this.players.map(p => p.playerId));
    const seen = new Set();

    const normalize = (arr, max) => {
      const out = [];
      for (const rawId of (Array.isArray(arr) ? arr : [])) {
        const id = typeof rawId === 'number' ? rawId : parseInt(rawId, 10);
        if (!Number.isFinite(id) || !validIds.has(id) || seen.has(id)) continue;
        out.push(id);
        seen.add(id);
        if (typeof max === 'number' && out.length >= max) break;
      }
      return out;
    };

    return {
      starting: normalize(sourceZones?.starting, 11),
      bench: normalize(sourceZones?.bench, maxBench),
      alternates: normalize(sourceZones?.alternates),
    };
  }

  // ============================================================================
  // League Sync Panel
  // ============================================================================

  async loadLeaguesSyncStatus() {
    // Chat-provider sync-status endpoint removed; panel stays hidden unless
    // scrape data is populated by other means.
    return;
  }


  getPlayerByPersonId(personId) {
    if (!personId) return null;
    return this.players.find(p => String(p.personId) === String(personId)) || null;
  }

  _mk9Widget({ appRsvp, overrideRsvp, attendanceStatus, isPast, onOverride, onAttendance }) {
    const wrap = document.createElement('div');
    wrap.style.cssText = 'display:flex;flex-direction:column;gap:3px;padding-left:2px;';
    const rOpts = [
      { v:'yes',   label:'Going',     dot:'🟢' },
      { v:'no',    label:'Not Going', dot:'🔴' },
    ];
    const aOpts = [
      { v:'yes',        label:'Yes',        dot:'✅' },
      { v:'late',       label:'Late',       dot:'🕐' },
      { v:'left_early', label:'Left Early', dot:'↩️' },
      { v:'no',         label:'No',         dot:'❌' },
    ];
    const mkBtnRow = (label, opts, activeVal, onSelect, readonly) => {
      const row = document.createElement('div');
      row.style.cssText = 'display:flex;align-items:center;gap:5px;';
      const lbl = document.createElement('span');
      lbl.style.cssText = 'font-size:0.58rem;color:rgba(255,255,255,0.32);font-weight:700;letter-spacing:0.04em;width:54px;flex-shrink:0;text-align:right;';
      lbl.textContent = label;
      row.appendChild(lbl);
      const btnGroup = document.createElement('div');
      btnGroup.style.cssText = 'display:flex;gap:3px;flex-wrap:wrap;';
      opts.forEach(opt => {
        const isActive = activeVal === opt.v;
        const btn = document.createElement('button');
        btn.style.cssText = `display:flex;align-items:center;gap:2px;padding:2px 7px;border-radius:5px;font-size:0.7rem;border:1px solid ${isActive ? 'rgba(99,102,241,0.7)' : 'rgba(255,255,255,0.10)'};background:${isActive ? 'rgba(99,102,241,0.22)' : 'rgba(255,255,255,0.03)'};color:${isActive ? '#c7d2fe' : 'rgba(255,255,255,0.3)'};font-weight:${isActive ? '700' : '400'};cursor:${readonly || !onSelect ? 'default' : 'pointer'};`;
        btn.textContent = `${opt.dot} ${opt.label}`;
        if (!readonly && onSelect) btn.addEventListener('click', () => onSelect(isActive && label === 'OVERRIDE' ? 'clear' : opt.v));
        btnGroup.appendChild(btn);
      });
      if (label === 'OVERRIDE' && onSelect && !readonly) {
        const clr = document.createElement('button');
        clr.style.cssText = 'padding:2px 6px;border-radius:5px;font-size:0.7rem;cursor:pointer;border:1px solid rgba(255,255,255,0.08);background:rgba(255,255,255,0.03);color:rgba(255,255,255,0.3);';
        clr.textContent = '× CLR';
        clr.addEventListener('click', () => onSelect('clear'));
        btnGroup.appendChild(clr);
      }
      row.appendChild(btnGroup);
      return row;
    };
    wrap.appendChild(mkBtnRow('APP RSVP', rOpts, appRsvp || '', null, true));
    wrap.appendChild(mkBtnRow('OVERRIDE', rOpts, overrideRsvp || '', onOverride || null, !onOverride));
    wrap.appendChild(mkBtnRow('ATTENDED', aOpts, attendanceStatus || '', (isPast && onAttendance) ? onAttendance : null, !isPast || !onAttendance));
    return wrap;
  }

  async _openEventRsvpModal({ type, chatEventId, matchId, title, startAt, eventDate, teamId }) {
    document.getElementById('event-rsvp-modal')?.remove();

    const modal = document.createElement('div');
    modal.id = 'event-rsvp-modal';
    modal.style.cssText = 'position:fixed;inset:0;z-index:1200;display:flex;align-items:flex-end;justify-content:center;';
    modal.innerHTML = `
      <div style="position:absolute;inset:0;background:rgba(0,0,0,0.65);" id="erm-backdrop"></div>
      <div id="erm-sheet" style="position:relative;width:min(100%,480px);max-height:80vh;background:#111827;border-radius:16px 16px 0 0;display:flex;flex-direction:column;z-index:1;">
        <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 16px 10px;border-bottom:1px solid rgba(255,255,255,0.1);flex-shrink:0;">
          <span id="erm-title" style="font-size:0.9rem;font-weight:700;color:#fff;">Event RSVPs</span>
          <button id="erm-close" style="background:none;border:none;color:rgba(255,255,255,0.6);font-size:1.2rem;cursor:pointer;padding:2px 8px;">✕</button>
        </div>
        <div id="erm-body" style="overflow-y:auto;padding:24px;color:rgba(255,255,255,0.6);text-align:center;">
          The per-event RSVP picker relied on the chat-provider integration that was removed.
          Use the lineup screen to manage RSVPs directly.
        </div>
      </div>`;

    modal.querySelector('#erm-backdrop').addEventListener('click', () => modal.remove());
    modal.querySelector('#erm-close').addEventListener('click', () => modal.remove());
    document.body.appendChild(modal);
    // Suppress unused-arg lint
    void type; void chatEventId; void matchId; void title; void startAt; void eventDate; void teamId;
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

    const rsvpOptions = ['yes','no'].map(v => {
      const label = v === 'yes' ? '🟢 Going' : '🔴 Not Going';
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
        <button class="pitch-popover-item" data-action="view-person" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;">
          View Person
        </button>
        <button class="pitch-popover-item" data-action="edit-person" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;">
          Edit Person
        </button>
        <button class="pitch-popover-item" data-action="edit-player" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;">
          Lineup details…
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
      } else if (action === 'view-person') {
        this._dismissPitchPopover();
        this._openPersonProfile(pid, false);
      } else if (action === 'edit-person') {
        this._dismissPitchPopover();
        this._openPersonProfile(pid, true);
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

    const rsvpOptions = ['yes', 'no'].map(v => {
      const label = v === 'yes' ? '🟢 Going' : '🔴 Not Going';
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
        <button class="pitch-popover-item" data-action="view-person" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;">
          View Person
        </button>
        <button class="pitch-popover-item" data-action="edit-person" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;">
          Edit Person
        </button>
        <button class="pitch-popover-item" data-action="edit-player" data-player-id="${playerId}"
          style="display:block;width:100%;text-align:left;padding:5px 8px;border:none;background:transparent;cursor:pointer;border-radius:6px;font-size:0.82rem;">
          Lineup details…
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
      } else if (action === 'view-person') {
        this._dismissPitchPopover();
        this._openPersonProfile(pid, false);
      } else if (action === 'edit-person') {
        this._dismissPitchPopover();
        this._openPersonProfile(pid, true);
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
    return [...players].sort((a, b) => {
      const last = (a.lastName || '').localeCompare(b.lastName || '');
      if (last !== 0) return last;
      return (a.firstName || '').localeCompare(b.firstName || '');
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

  // Open the shared Person View/Edit hub for a lineup player.
  _openPersonProfile(playerId, edit) {
    const player = this.getPlayerById(playerId);
    if (!player) return;
    const params = { returnTo: 'game-day-lineup' };
    if (player.leagueAppsUserId) params.leagueAppsUserId = player.leagueAppsUserId;
    if (player.personId) params.personId = player.personId;
    if (edit) params.edit = '1';
    if (!params.leagueAppsUserId && !params.personId) {
      this.showLineupToast('No person record linked to this player yet');
      return;
    }
    this.navigation.goTo('person', params);
  }

  openEditPlayerModal(playerId, slotIndex) {
    this._dismissPitchPopover(); // clear any stale popover before opening modal
    const player = this.getPlayerById(playerId);
    if (!player) return;

    const eligIcon = this.getStatusIcon(player.eligibilityStatus);
    const requiredForPlayer = this._requiredSessionsFor(player);
    const prac     = `${player.sessionsAttended || 0}/${this._practiceLookbackCount()} · req ${requiredForPlayer}`;
    const pos      = player.position || '—';
    const isOnPitch = slotIndex !== undefined && this.zones.starting[slotIndex] === playerId;
    const currentZone = isOnPitch ? 'starting'
      : this.zones.bench.includes(playerId) ? 'bench'
      : this.zones.alternates.includes(playerId) ? 'alternates'
      : 'pool';
    const registeredStr = this._registeredLabel(player);
    const paidStr = this._paidLabel(player);
    const dobStr = this._formatDobForCard(player);
    const onOfficialRosterChecked = !!player.onOfficialRoster;
    const isRegisteredChecked = (() => {
      const direct = this._boolish(player?.isRegistered ?? player?.registered ?? player?.registrationComplete);
      if (direct != null) return direct;
      return String(registeredStr).toLowerCase() === 'yes';
    })();
    const isPaidChecked = (() => {
      const direct = this._boolish(player?.isPaid ?? player?.paid ?? player?.paymentComplete);
      if (direct != null) return direct;
      return String(paidStr).toLowerCase() === 'yes';
    })();

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
            <div style="font-size:0.72rem;color:var(--text-muted);">Reg: ${registeredStr} · Paid: ${paidStr} · DOB: ${dobStr}</div>
            <div id="ep-person-actions" style="display:flex;gap:6px;flex-wrap:wrap;margin-top:6px;"></div>
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
              ${['yes','no'].map(v => {
                const icons = {yes:'🟢 Going', no:'🔴 No'};
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
                <div style="font-size:0.72rem;color:var(--text-muted);">Age now: 17 and under = 3 · 18-22 = 2 · 23+ = 1 (within last 5)</div>
              </div>
              <input type="date" id="ep-dob" value="${player.dateOfBirth || ''}" placeholder="YYYY-MM-DD"
                style="padding:5px 6px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-primary);color:inherit;font-size:0.82rem;">
            </div>

            <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div style="font-size:0.88rem;">🧾 Registration</div>
              <div style="font-size:0.84rem;font-weight:600;">${registeredStr}</div>
            </div>

            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div>
                <div style="font-size:0.88rem;">📋 On Official Roster</div>
                <div style="font-size:0.72rem;color:var(--text-muted);">Manual override for all teams</div>
              </div>
              <input type="checkbox" id="ep-on-roster" style="width:20px;height:20px;cursor:pointer;accent-color:var(--accent);" ${onOfficialRosterChecked ? 'checked' : ''}>
            </label>

            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div>
                <div style="font-size:0.88rem;">🧾 Lighthouse Registration</div>
                <div style="font-size:0.72rem;color:var(--text-muted);">Manual registration status</div>
              </div>
              <input type="checkbox" id="ep-registered" style="width:20px;height:20px;cursor:pointer;accent-color:var(--accent);" ${isRegisteredChecked ? 'checked' : ''}>
            </label>

            <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div style="font-size:0.88rem;">💳 Payment</div>
              <div style="font-size:0.84rem;font-weight:600;">${paidStr}</div>
            </div>

            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div>
                <div style="font-size:0.88rem;">💵 Paid Up To Date</div>
                <div style="font-size:0.72rem;color:var(--text-muted);">Manual payment status</div>
              </div>
              <input type="checkbox" id="ep-paid-up" style="width:20px;height:20px;cursor:pointer;accent-color:var(--accent);" ${isPaidChecked ? 'checked' : ''}>
            </label>

            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div>
                <div style="font-size:0.88rem;">🏃 Required Sessions</div>
                <div style="font-size:0.72rem;color:var(--text-muted);">Auto from DOB (no DOB = 1) · override if needed</div>
              </div>
              <div style="display:flex;align-items:center;gap:6px;">
                <span id="ep-req-auto" style="font-size:0.78rem;color:var(--text-muted);">(auto: ${this._ageBasedRequiredSessions(player)}${this._hasKnownAge(player) ? '' : ' · NO AGE'})</span>
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
                <div style="font-size:0.88rem;">🧤 Goalkeeper</div>
                <div style="font-size:0.72rem;color:var(--text-muted);">0 practices required</div>
              </div>
              <input type="checkbox" id="ep-keeper" style="width:20px;height:20px;cursor:pointer;accent-color:var(--accent);" ${player.isKeeper ? 'checked' : ''}>
            </label>

            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div>
                <div style="font-size:0.88rem;">👶 Child</div>
                <div style="font-size:0.72rem;color:var(--text-muted);">0 practices required</div>
              </div>
              <input type="checkbox" id="ep-child" style="width:20px;height:20px;cursor:pointer;accent-color:var(--accent);" ${player.isChild ? 'checked' : ''}>
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

          <!-- Sessions -->
          <div style="border-top:1px solid var(--border-color);padding:12px 0;">
            <div style="font-size:0.7rem;color:var(--text-muted);font-weight:700;letter-spacing:0.06em;margin-bottom:8px;">SESSIONS</div>
            <div id="ep-practices-body" style="font-size:0.78rem;color:var(--text-muted);">Loading...</div>
          </div>

          <div id="ep-save-status" style="margin-top:8px;font-size:0.75rem;color:var(--text-muted);text-align:center;min-height:1.2em;"></div>
        </div>
      </div>
    `;
    document.body.appendChild(overlay);

    // Shared View/Edit → PersonScreen (identity / contact / memberships).
    // Lineup-specific controls stay in this modal.
    const actionsHost = overlay.querySelector('#ep-person-actions');
    if (actionsHost && window.PersonActions && (player.personId || player.leagueAppsUserId)) {
      actionsHost.innerHTML = window.PersonActions.buttonsHtml(
        {
          leagueAppsUserId: player.leagueAppsUserId,
          personId: player.personId,
          firstName: player.firstName,
          fullName: `${player.firstName || ''} ${player.lastName || ''}`.trim(),
        },
        { returnTo: 'game-day-lineup', size: 'md' }
      );
    }

    // Load sessions async
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
          const renderSessions = (sessions) => {
            practicesBody.innerHTML = '';
            sessions.forEach(s => {
              const card = document.createElement('div');
              card.style.cssText = 'background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.08);border-radius:8px;padding:8px 10px;margin-bottom:8px;';
              // Session title (clickable → opens event modal)
              const titleBtn = document.createElement('button');
              titleBtn.style.cssText = 'display:flex;align-items:baseline;gap:6px;width:100%;background:none;border:none;padding:0 0 6px;cursor:pointer;text-align:left;';
              const titleSpan = document.createElement('span');
              titleSpan.style.cssText = 'font-size:0.82rem;font-weight:600;color:var(--text-primary,#e2e8f0);';
              titleSpan.textContent = s.title.length > 26 ? s.title.slice(0,25)+'\u2026' : s.title;
              const dateSpan = document.createElement('span');
              dateSpan.style.cssText = 'font-size:0.65rem;color:var(--text-muted);';
              dateSpan.textContent = s.date ? s.date.slice(5) : '';
              titleBtn.appendChild(titleSpan);
              titleBtn.appendChild(dateSpan);
              titleBtn.addEventListener('click', () => {
                overlay.remove();
                this._openEventRsvpModal({
                  type: s.matchId ? 'game' : 'training',
                  chatEventId: s.sessionId,
                  matchId: s.matchId,
                  title: s.title,
                  startAt: s.startAt,
                  eventDate: s.date,
                  teamId
                });
              });
              card.appendChild(titleBtn);
              // 9-widget
              const isPastSession = s.startAt
                ? new Date(s.startAt.includes('T') ? s.startAt : s.startAt.replace(' ','T')) < new Date()
                : (s.date ? new Date(s.date) < new Date() : true);
              card.appendChild(this._mk9Widget({
                appRsvp: s.rawRsvp || null,
                overrideRsvp: s.overrideRsvp || null,
                attendanceStatus: s.attendanceStatus || null,
                isPast: isPastSession,
                onOverride: async (_status) => {
                  this.showLineupToast('Per-event RSVP override unavailable after chat-provider rip');
                },
                onAttendance: async (status) => {
                  try {
                    const res = await this.auth.fetch(`/api/eligibility/player/${playerId}/attendance`, {
                      method: 'PUT', headers: { 'Content-Type': 'application/json' },
                      body: JSON.stringify({ sessionId: s.sessionId, attendanceStatus: status, source: 'manual' })
                    });
                    const rd = await res.json();
                    if (rd.success) {
                      s.attendanceStatus = status;
                      player.sessionsAttended = sessions.filter(x => x.attendanceStatus === 'yes' || x.attendanceStatus === 'partial').length;
                      renderSessions(sessions);
                      this.renderAllZones();
                    } else this.showLineupToast('\u274c ' + (rd.message || 'failed'));
                  } catch (e) { this.showLineupToast('\u274c ' + e.message); }
                }
              }));
              practicesBody.appendChild(card);
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
        const prevDob          = player.dateOfBirth || '';
        const designated       = overlay.querySelector('#ep-designated').checked;
        const numClubs         = parseInt(overlay.querySelector('#ep-numclubs').value);
        const isKeeper         = overlay.querySelector('#ep-keeper').checked;
        const isChild          = overlay.querySelector('#ep-child').checked;
        const jersey           = overlay.querySelector('#ep-jersey').value.trim() || null;
        const isInjured        = overlay.querySelector('#ep-injured').checked;
        const isSuspLeague     = overlay.querySelector('#ep-susp-league').checked;
        const isSuspInhouse    = overlay.querySelector('#ep-susp-inhouse').checked;
        const onOfficialRoster = overlay.querySelector('#ep-on-roster').checked;
        const isRegistered     = overlay.querySelector('#ep-registered').checked;
        const isPaidUpToDate   = overlay.querySelector('#ep-paid-up').checked;
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
        player.isKeeper           = isKeeper;
        player.isChild            = isChild;
        player.jerseyNumber       = jersey;
        player.isInjured          = isInjured;
        player.isSuspendedLeague  = isSuspLeague;
        player.isSuspendedInhouse = isSuspInhouse;
        player.onOfficialRoster   = onOfficialRoster;
        player.isRegistered       = isRegistered;
        player.registered         = isRegistered;
        player.isPaid             = isPaidUpToDate;
        player.paid               = isPaidUpToDate;
        player.eligApslStarter    = eligApslStarter;
        player.eligApslBench      = eligApslBench;
        player.eligLiga1Starter   = eligLiga1Starter;
        player.eligLiga1Bench     = eligLiga1Bench;
        player.eligLiga2Starter   = eligLiga2Starter;
        player.eligLiga2Bench     = eligLiga2Bench;
        player.dateOfBirth = dobVal || null;
        player.requiredSessionsOverride = reqOverride;

        if (this.policy?.minSessionsToStart !== undefined) {
          const effectiveMin = (isKeeper || isChild) ? 0
            : reqOverride != null ? reqOverride
            : this._ageBasedRequiredSessions(player);
          player.effectiveMinSessions = effectiveMin;
          const s = player.sessionsAttended || 0;
          if (s >= (this.policy.priorityStarterSessions || 999)) player.eligibilityStatus = 'priority_starter';
          else if (s >= effectiveMin) player.eligibilityStatus = designated ? 'priority_starter' : 'eligible_starter';
          else if (s > 0) player.eligibilityStatus = designated ? 'eligible_starter' : 'bench_only';
          else player.eligibilityStatus = designated ? 'bench_only' : 'ineligible';
        }

        try {
          const flagsPayload = {
            isDesignated: designated, numClubs, isKeeper, isChild,
            jerseyNumber: jersey, internalRole: player.internalRole || '',
            isInjured, isSuspendedLeague: isSuspLeague, isSuspendedInhouse: isSuspInhouse,
            onOfficialRoster, isRegistered, isPaidUpToDate,
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
          if (player.personId && dobVal && dobVal !== prevDob) {
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
