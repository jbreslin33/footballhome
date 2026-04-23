// GameDayRosterScreen - Coach manages game day roster with enriched player overlay
// Features: player selection, RSVP override (auto-saves), match card, share
class GameDayRosterScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.players = [];
    this.matchDetails = null;
    this.selectedPlayerIds = new Set();
    this._listenersAttached = false;
    this.overlayOpen = false;
    this.filterText = '';
    this.filterRsvp = 'all';
    this.listFilter = 'all';
  }

  render() {
    this._listenersAttached = false;
    
    const div = document.createElement('div');
    div.className = 'screen screen-game-day-roster';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">\u2190 Back</button>
        <h1>\ud83d\udccb Game Day Roster</h1>
      </div>
      
      <div class="gdr-container">
        <div id="roster-loading" class="gdr-loading">
          <div class="spinner"></div>
          <p>Loading...</p>
        </div>
        
        <div id="roster-content" style="display: none;">
          <!-- Match Card (Instagram-style, shareable) -->
          <div id="match-card-share" class="gdr-match-card">
            <div class="gdr-card-inner" id="gdr-card-inner">
              <div class="gdr-card-accent"></div>
              <div class="gdr-card-header">MATCH DAY</div>
              <div class="gdr-card-logos">
                <div class="gdr-team gdr-team-home">
                  <div class="gdr-logo-wrap" id="gdr-home-logo"></div>
                  <div class="gdr-team-name" id="gdr-home-name">Home</div>
                </div>
                <div class="gdr-vs-block">
                  <div class="gdr-vs">VS</div>
                </div>
                <div class="gdr-team gdr-team-away">
                  <div class="gdr-logo-wrap" id="gdr-away-logo"></div>
                  <div class="gdr-team-name" id="gdr-away-name">Away</div>
                </div>
              </div>
              <div class="gdr-card-divider"></div>
              <div class="gdr-card-details">
                <div class="gdr-detail" id="gdr-date">\ud83d\udcc5 \u2014</div>
                <div class="gdr-detail" id="gdr-time">\ud83d\udd50 \u2014</div>
                <div class="gdr-detail" id="gdr-venue">\ud83d\udccd \u2014</div>
              </div>
              <div class="gdr-card-roster" id="gdr-card-roster" style="display:none;">
                <div class="gdr-card-divider"></div>
                <div class="gdr-roster-title">SQUAD</div>
                <div class="gdr-roster-grid" id="gdr-roster-names"></div>
              </div>
              <div class="gdr-card-footer">
                <span class="gdr-card-brand" id="gdr-card-brand">\u26bd Philadelphia</span>
              </div>
            </div>
            <div class="gdr-share-actions">
              <button id="share-card-btn" class="btn btn-secondary btn-sm">\ud83d\udcf8 Share Image</button>
              <button id="copy-text-btn" class="btn btn-secondary btn-sm">\ud83d\udccb Copy Text</button>
            </div>

            <!-- Social post buttons -->
            <div class="gdr-social-row">
              <div class="gdr-social-buttons">
                <button class="gdr-social-btn" data-post-type="game_day" style="--btn-accent:#f59e0b;">⚽ Game<br>Announcement</button>
                <button class="gdr-social-btn" data-post-type="lineup" style="--btn-accent:#8b5cf6;">📋 20-Man<br>Squad</button>
                <button class="gdr-social-btn" data-post-type="pre_match_announcement" style="--btn-accent:#3b82f6;">⚔️ Starters<br>& Bench</button>
                <button class="gdr-social-btn" data-post-type="post_game" style="--btn-accent:#22c55e;">🏆 Match<br>Result</button>
              </div>
              <div class="gdr-lineup-links">
                <span style="font-size:0.75em;opacity:0.5;">Set lineups:</span>
                <button id="set-20man-btn" class="btn btn-secondary btn-sm" style="font-size:0.75em;padding:2px 8px;">20-Man Roster</button>
                <button id="set-starters-btn" class="btn btn-secondary btn-sm" style="font-size:0.75em;padding:2px 8px;">Starters & Bench</button>
              </div>
            </div>

            <!-- Inline social post preview (shown when a social button is clicked) -->
            <div id="social-preview-container"></div>

          </div>

          <!-- Selection header with add button -->
          <div class="gdr-selection-header">
            <div id="selected-count" class="gdr-count-badge">0 / 20 selected</div>
            <button id="open-overlay-btn" class="btn btn-primary btn-sm">+ Add / Edit Players</button>
          </div>

          <!-- Selected players (game day roster) -->
          <div id="selected-player-list" class="gdr-player-list"></div>
        </div>
      </div>

      <!-- Player Overlay -->
      <div id="player-overlay" class="gdr-overlay" style="display:none;">
        <div class="gdr-overlay-content">
          <div class="gdr-overlay-header">
            <h2>Select Players</h2>
            <button id="close-overlay-btn" class="btn btn-secondary btn-sm">\u2715 Close</button>
          </div>
          <div class="gdr-overlay-filters">
            <input type="text" id="player-search" class="gdr-search-input" placeholder="Search players...">
            <select id="rsvp-filter" class="gdr-filter-select">
              <option value="all">All RSVP</option>
              <option value="yes">Attending</option>
              <option value="maybe">Maybe</option>
              <option value="none">No Response</option>
              <option value="no">Not Attending</option>
            </select>
            <select id="list-filter" class="gdr-filter-select">
              <option value="all">All Players</option>
              <optgroup label="GroupMe Chats">
                <option value="chat_apsl">APSL Lighthouse</option>
                <option value="chat_casa">Casa Liga 1 &amp; 2</option>
                <option value="chat_u23">U23</option>
              </optgroup>
              <optgroup label="Official Rosters">
                <option value="roster_lighthouse">APSL Lighthouse 1893</option>
                <option value="roster_casa">Lighthouse Boys Club</option>
                <option value="roster_u23">Lighthouse Boys Club U23</option>
              </optgroup>
            </select>
          </div>
          <div class="gdr-overlay-actions-bar">
            <button id="select-all-attending-btn" class="btn btn-secondary btn-sm">\u2713 Select All Attending</button>
          </div>
          <div id="overlay-player-list" class="gdr-overlay-list"></div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    if (this._listenersAttached) return;
    this._listenersAttached = true;
    
    this.loadData();
    
    this.element.addEventListener('click', (e) => {
      const target = e.target;
      const id = target.id || target.closest('[id]')?.id;
      
      if (id === 'back-btn') { this.navigation.goBack(); return; }
      if (id === 'open-overlay-btn') { this.openOverlay(); return; }
      if (id === 'close-overlay-btn') { this.closeOverlay(); return; }
      if (id === 'select-all-attending-btn') { this.selectAllAttending(); return; }
      if (id === 'share-card-btn') { this.shareAsImage(); return; }
      if (id === 'copy-text-btn') { this.copyAsText(); return; }
      if (id === 'set-20man-btn') {
        // Already on this page — scroll to roster
        this.find('#open-overlay-btn')?.scrollIntoView({ behavior: 'smooth' });
        return;
      }
      if (id === 'set-starters-btn') {
        this.navigation.context.match = this.matchDetails;
        this.navigation.goTo('game-day-lineup');
        return;
      }

      // Social post type buttons
      const socialBtn = target.closest('.gdr-social-btn');
      if (socialBtn) {
        const postType = socialBtn.dataset.postType;
        this.showSocialPreview(postType);
        // Update active button styling
        this.element.querySelectorAll('.gdr-social-btn').forEach(b => b.classList.remove('active'));
        socialBtn.classList.add('active');
        return;
      }
      
      // Toggle player selection in overlay
      // Only toggle selection when clicking the checkbox itself or its label area
      const checkbox = target.closest('.gdr-select-cb');
      if (checkbox) {
        const playerRow = target.closest('.gdr-overlay-row');
        if (playerRow) {
          const pid = parseInt(playerRow.dataset.playerId);
          if (this.selectedPlayerIds.has(pid)) {
            this.selectedPlayerIds.delete(pid);
            this.toggleLineup(pid, false);
          } else {
            this.selectedPlayerIds.add(pid);
            this.toggleLineup(pid, true);
          }
          this.renderOverlayList();
          this.renderSelectedPlayers();
          this.updateSelectedCount();
          this.updateCardRoster();
        }
      }

      // Remove from selected list
      const removeBtn = target.closest('.gdr-remove-btn');
      if (removeBtn) {
        const pid = parseInt(removeBtn.dataset.playerId);
        this.selectedPlayerIds.delete(pid);
        this.toggleLineup(pid, false);
        this.renderSelectedPlayers();
        this.renderOverlayList();
        this.updateSelectedCount();
        this.updateCardRoster();
      }
    });

    // RSVP tri-state button click
    this.element.addEventListener('click', (e) => {
      const rsvpBtn = e.target.closest('.gdr-rsvp-btn');
      if (rsvpBtn) {
        const playerId = rsvpBtn.dataset.playerId;
        const newStatus = rsvpBtn.dataset.rsvp;
        this.setPlayerRSVP(playerId, newStatus);
        this.renderOverlayList();
        return;
      }

      // Practice cell click — cycle through yes → no → maybe → release
      const pracCell = e.target.closest('.gdr-prac-cell');
      if (pracCell) {
        e.stopPropagation();
        const personId = pracCell.dataset.personId;
        const eventId = pracCell.dataset.eventId;
        const eventIdx = parseInt(pracCell.dataset.eventIdx);
        const current = pracCell.dataset.current;
        const isOverride = pracCell.classList.contains('gdr-prac-override');

        if (isOverride) {
          // Override cell: yes → no → maybe → release
          const cycle = { 'yes': 'no', 'no': 'maybe', 'maybe': null };
          const next = current in cycle ? cycle[current] : 'no';
          if (next === null) {
            this.releasePracticeRSVP(personId, eventId, eventIdx);
          } else {
            this.setPracticeRSVP(personId, eventId, eventIdx, next);
          }
        } else {
          // Non-override cell: empty → yes (sets override), or cycle yes → no → maybe → yes
          const cycle = { '': 'yes', 'yes': 'no', 'no': 'maybe', 'maybe': 'yes' };
          const next = cycle[current] || 'yes';
          this.setPracticeRSVP(personId, eventId, eventIdx, next);
        }
        this.renderOverlayList();
      }
    });

    // Jersey number inline edit
    let jerseyDebounce = null;
    this.element.addEventListener('input', (e) => {
      if (e.target.classList.contains('gdr-jersey-input')) {
        const playerId = e.target.dataset.playerId;
        const val = e.target.value;
        const player = this.players.find(p => String(p.playerId) === String(playerId));
        if (player) player.jerseyNumber = val;
        clearTimeout(jerseyDebounce);
        jerseyDebounce = setTimeout(() => this.saveJerseyNumber(playerId, val), 600);
      }
    });

    // Search filter
    this.element.addEventListener('input', (e) => {
      if (e.target.id === 'player-search') {
        this.filterText = e.target.value.toLowerCase();
        this.renderOverlayList();
      }
    });

    // RSVP filter & list filter
    this.element.addEventListener('change', (e) => {
      if (e.target.id === 'rsvp-filter') {
        this.filterRsvp = e.target.value;
        this.renderOverlayList();
      }
      if (e.target.id === 'list-filter') {
        this.listFilter = e.target.value;
        this.renderOverlayList();
      }
    });
  }

  async loadData() {
    const matchId = this.navigation.context.match?.id;
    if (!matchId) {
      this.find('#roster-loading').innerHTML = '<p style="color:red;">No match selected</p>';
      return;
    }

    try {
      // Sync GroupMe RSVPs first (fresh data on every page load)
      const teamId = this.resolveActiveTeamId();
      try {
        await this.auth.fetch(`/api/groupme/sync-for-match/${matchId}${teamId ? '?teamId=' + teamId : ''}`, { method: 'POST' });
      } catch (e) {
        console.warn('GroupMe sync skipped:', e.message);
      }

      const [matchRes, playersRes] = await Promise.all([
        this.auth.fetch(`/api/matches/${matchId}`),
        this.auth.fetch(`/api/matches/${matchId}/roster-players?teamId=${teamId}`)
      ]);
      const [matchData, playersData] = await Promise.all([matchRes.json(), playersRes.json()]);

      if (matchData.success) {
        this.matchDetails = matchData.data;
        this.renderMatchCard();
      }

      if (playersData.success) {
        this.players = playersData.data || [];
        this.trainingEvents = playersData.trainingEvents || [];
        // Pre-select players already on game roster
        this.selectedPlayerIds = new Set(
          this.players.filter(p => p.onGameRoster).map(p => p.playerId)
        );
      }

      this.find('#roster-loading').style.display = 'none';
      this.find('#roster-content').style.display = 'block';
      this.renderSelectedPlayers();
      this.updateSelectedCount();
      this.updateCardRoster();
      

    } catch (error) {
      console.error('Error loading:', error);
      this.find('#roster-loading').innerHTML = `<p style="color:red;">\u274c ${error.message}</p>`;
    }
  }

  renderMatchCard() {
    const m = this.matchDetails;
    if (!m) return;

    const homeLogo = this.find('#gdr-home-logo');
    const awayLogo = this.find('#gdr-away-logo');
    homeLogo.innerHTML = this.buildTeamLogoMarkup(m.home_team_logo, {
      className: '',
      alt: 'Home',
      placeholder: '🏠',
      placeholderClass: 'gdr-logo-placeholder'
    });
    awayLogo.innerHTML = this.buildTeamLogoMarkup(m.away_team_logo, {
      className: '',
      alt: 'Away',
      placeholder: '🏟️',
      placeholderClass: 'gdr-logo-placeholder'
    });

    this.find('#gdr-home-name').textContent = m.home_team_name || 'Home';
    this.find('#gdr-away-name').textContent = m.away_team_name || 'Away';

    if (m.event_date) {
      const d = this.parseMatchDisplayDate(m.event_date);
      if (d) {
        this.find('#gdr-date').textContent = '\ud83d\udcc5 ' + d.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' });
        this.find('#gdr-time').textContent = '\ud83d\udd50 ' + d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      }
    }
    if (m.venue_name) {
      this.find('#gdr-venue').textContent = '\ud83d\udccd ' + this.titleCase(m.venue_name);
    }

    // Dynamic league brand in footer
    const brandEl = this.find('#gdr-card-brand');
    if (brandEl) {
      const comp = `${m.competition_name || ''} ${m.division_name || ''}`;
      const isCasa = m.source_name === 'casa' || /casa|liga\s*[12]/i.test(comp);
      if (isCasa) {
        const liga = /liga\s*2/i.test(comp) ? '2' : '1';
        brandEl.textContent = `\u26bd Philadelphia CASA Select Liga ${liga}`;
      } else if (m.source_name) {
        const leagueMap = { apsl: 'APSL', csl: 'CSL' };
        const league = leagueMap[m.source_name] || m.source_name.toUpperCase();
        brandEl.textContent = '\u26bd ' + league + ' \u2022 Philadelphia';
      }
    }
  }

  // --- Selected players list (main view) ---
  renderSelectedPlayers() {
    const container = this.find('#selected-player-list');
    const selected = this.players.filter(p => this.selectedPlayerIds.has(p.playerId));
    
    if (selected.length === 0) {
      container.innerHTML = '<div class="gdr-empty">No players selected. Tap "+ Add / Edit Players" to build the roster.</div>';
      return;
    }

    // Practice header
    const pracHeaders = (this.trainingEvents || []).map(te => {
      const d = new Date(te.date + 'T12:00:00');
      return `<span class="gdr-sel-prac-hdr">${d.toLocaleDateString('en-US', { weekday: 'short' })}</span>`;
    }).join('');
    const pracHeaderRow = (this.trainingEvents || []).length > 0
      ? `<div class="gdr-sel-header-row"><span class="gdr-sel-header-spacer"></span><div class="gdr-sel-prac-headers">${pracHeaders}</div><span class="gdr-sel-header-x"></span></div>`
      : '';

    container.innerHTML = pracHeaderRow + selected.map(p => {
      const badges = [];
      if (p.isKeeper) badges.push('<span class="gdr-badge gdr-badge-keeper">GK</span>');
      if (p.hasFamilyDiscount) badges.push('<span class="gdr-badge gdr-badge-family">FAM</span>');
      const rsvpClass = p.rsvpStatus === 'yes' ? 'gdr-rsvp-yes' : p.rsvpStatus === 'no' ? 'gdr-rsvp-no' : p.rsvpStatus === 'maybe' ? 'gdr-rsvp-maybe' : 'gdr-rsvp-none';
      const rsvpLabel = p.rsvpStatus || 'none';

      // Mini practice dots
      const pracDots = (this.trainingEvents || []).map((te, i) => {
        const entry = p.practice ? p.practice[i] : null;
        const v = entry ? (typeof entry === 'object' ? entry.v : entry) : null;
        const cls = v === 'yes' ? 'gdr-dot-yes' : v === 'no' ? 'gdr-dot-no' : v === 'maybe' ? 'gdr-dot-maybe' : 'gdr-dot-none';
        return `<span class="gdr-prac-dot ${cls}"></span>`;
      }).join('');

      return `
        <div class="gdr-selected-card">
          <div class="gdr-selected-info">
            <span class="gdr-selected-name">${p.firstName} ${p.lastName}</span>
            <span class="gdr-selected-meta">${[p.jerseyNumber ? '#' + p.jerseyNumber : '', p.position].filter(Boolean).join(' \u00b7 ')}</span>
            ${badges.join('')}
          </div>
          <div class="gdr-sel-practice">${pracDots}</div>
          <span class="gdr-rsvp-dot ${rsvpClass}" title="RSVP: ${rsvpLabel}"></span>
          <button class="gdr-remove-btn" data-player-id="${p.playerId}">\u2715</button>
        </div>`;
    }).join('');
  }
  
  // --- Overlay ---
  openOverlay() {
    this.overlayOpen = true;
    this.find('#player-overlay').style.display = 'flex';
    this.renderOverlayList();
    // Focus search
    setTimeout(() => this.find('#player-search')?.focus(), 100);
  }

  closeOverlay() {
    this.overlayOpen = false;
    this.find('#player-overlay').style.display = 'none';
    this.renderSelectedPlayers();
    this.updateCardRoster();
  }

  getFilteredPlayers() {
    return this.players.filter(p => {
      // Text filter
      if (this.filterText) {
        const name = (p.firstName + ' ' + p.lastName).toLowerCase();
        if (!name.includes(this.filterText)) return false;
      }
      // RSVP filter
      if (this.filterRsvp !== 'all') {
        if (this.filterRsvp === 'none') {
          if (p.rsvpStatus) return false;
        } else {
          if (p.rsvpStatus !== this.filterRsvp) return false;
        }
      }
      // List filter (GroupMe chats or official rosters)
      if (this.listFilter !== 'all') {
        const map = {
          chat_apsl: 'inChatApsl', chat_casa: 'inChatCasa', chat_u23: 'inChatU23',
          roster_lighthouse: 'onRosterLighthouse', roster_casa: 'onRosterCasa', roster_u23: 'onRosterU23'
        };
        const key = map[this.listFilter];
        if (key && !p[key]) return false;
      }
      return true;
    });
  }

  renderOverlayList() {
    const container = this.find('#overlay-player-list');
    const filtered = this.getFilteredPlayers();

    if (filtered.length === 0) {
      container.innerHTML = '<div class="gdr-empty">No players match filters</div>';
      return;
    }

    // Practice column headers with day names and dates
    const practiceHeaders = (this.trainingEvents || []).map((te, i) => {
      const d = new Date(te.date + 'T12:00:00');
      const day = d.toLocaleDateString('en-US', { weekday: 'short' });
      const dateStr = d.toLocaleDateString('en-US', { month: 'numeric', day: 'numeric' });
      return `<th class="gdr-th-practice" title="${te.title} - ${day} ${dateStr}">${day}<br><span class="gdr-th-date">${dateStr}</span></th>`;
    }).join('');

    container.innerHTML = `
      <table class="gdr-overlay-table">
        <thead>
          <tr>
            <th class="gdr-th-cb" title="Game Day Roster">GDR</th>
            <th>Player</th>
            <th>#</th>
            <th>Pos</th>
            <th>RSVP</th>
            <th>GK</th>
            <th>Fam</th>
            <th class="gdr-section-divider" colspan="${(this.trainingEvents || []).length || 1}">Practice</th>
            <th class="gdr-section-divider" colspan="3">GroupMe</th>
            <th class="gdr-section-divider" colspan="3">Roster</th>
          </tr>
          <tr class="gdr-subheader">
            <th></th><th></th><th></th><th></th><th></th><th></th><th></th>
            ${practiceHeaders}
            <th class="gdr-th-chat" title="APSL Lighthouse">A</th>
            <th class="gdr-th-chat" title="Lighthouse Boys Club Liga 1 &amp; 2">Casa</th>
            <th class="gdr-th-chat" title="Lighthouse Boys Club U23">U23</th>
            <th class="gdr-th-roster" title="APSL Lighthouse 1893 SC">APSL</th>
            <th class="gdr-th-roster" title="Lighthouse Boys Club">Casa</th>
            <th class="gdr-th-roster" title="Lighthouse Boys Club U23">U23</th>
          </tr>
        </thead>
        <tbody>
          ${filtered.map(p => this.renderOverlayRow(p)).join('')}
        </tbody>
      </table>`;
  }

  renderOverlayRow(p) {
    const selected = this.selectedPlayerIds.has(p.playerId);
    const rsvpValue = p.rsvpStatus || '';
    const rsvpSource = p.rsvpSource || '';
    const practice = p.practice || [];

    // Practice cells — clickable tri-state
    const practiceCells = (this.trainingEvents || []).map((te, i) => {
      const entry = practice[i];
      const v = entry ? (typeof entry === 'object' ? entry.v : entry) : null;
      const isOverride = entry && typeof entry === 'object' ? entry.o : false;
      const cls = v === 'yes' ? 'gdr-prac-yes' : v === 'no' ? 'gdr-prac-no' : v === 'maybe' ? 'gdr-prac-maybe' : 'gdr-prac-none';
      const ovrCls = isOverride ? ' gdr-prac-override' : '';
      const sym = v === 'yes' ? '&check;' : v === 'no' ? '&cross;' : v === 'maybe' ? '?' : '&mdash;';
      return `<td class="gdr-cell-center gdr-prac-cell ${cls}${ovrCls}" data-person-id="${p.personId}" data-event-id="${te.id}" data-event-idx="${i}" data-current="${v || ''}" title="${isOverride ? 'Admin override' : 'GroupMe'}">${sym}</td>`;
    }).join('');

    // Chat membership cells
    const chatCell = (val) => val ? '<td class="gdr-cell-center gdr-in">&check;</td>' : '<td class="gdr-cell-center gdr-out"></td>';
    // Roster membership cells
    const rosterCell = (val) => val ? '<td class="gdr-cell-center gdr-in">&check;</td>' : '<td class="gdr-cell-center gdr-out"></td>';
    
    return `
      <tr class="gdr-overlay-row ${selected ? 'gdr-row-selected' : ''}" data-player-id="${p.playerId}">
        <td><input type="checkbox" class="gdr-select-cb" ${selected ? 'checked' : ''}></td>
        <td class="gdr-cell-name">
          <strong>${p.firstName} ${p.lastName}</strong>
        </td>
        <td class="gdr-cell-jersey">
          <input type="text" class="gdr-jersey-input" data-player-id="${p.playerId}" value="${p.jerseyNumber || ''}" maxlength="4" placeholder="#">
        </td>
        <td>${p.position || '\u2014'}</td>
        <td class="gdr-rsvp-cell">
          <div class="gdr-rsvp-group">
            <button class="gdr-rsvp-btn ${rsvpValue === 'yes' ? 'gdr-rsvp-active-yes' : ''}" data-player-id="${p.playerId}" data-rsvp="yes" title="Going">Y</button>
            <button class="gdr-rsvp-btn ${rsvpValue === 'maybe' ? 'gdr-rsvp-active-maybe' : ''}" data-player-id="${p.playerId}" data-rsvp="maybe" title="Maybe">M</button>
            <button class="gdr-rsvp-btn ${rsvpValue === 'no' ? 'gdr-rsvp-active-no' : ''}" data-player-id="${p.playerId}" data-rsvp="no" title="Not going">N</button>
          </div>
          ${rsvpSource === 'groupme' ? '<span class="gdr-rsvp-src" title="From GroupMe">GM</span>' : rsvpSource === 'admin' ? '<span class="gdr-rsvp-src gdr-src-admin" title="Admin override">\u270e</span>' : ''}
        </td>
        <td class="gdr-cell-center">${p.isKeeper ? '\ud83e\udde4' : ''}</td>
        <td class="gdr-cell-center">${p.hasFamilyDiscount ? '\ud83d\udc6a' : ''}</td>
        ${practiceCells}
        ${chatCell(p.inChatApsl)}
        ${chatCell(p.inChatCasa)}
        ${chatCell(p.inChatU23)}
        ${rosterCell(p.onRosterLighthouse)}
        ${rosterCell(p.onRosterCasa)}
        ${rosterCell(p.onRosterU23)}
      </tr>`;
  }

  async setPracticeRSVP(personId, chatEventId, eventIdx, newStatus) {
    // Update local data immediately
    const player = this.players.find(p => String(p.personId) === String(personId));
    if (player && player.practice) {
      player.practice[eventIdx] = newStatus ? { v: newStatus, o: true } : null;
    }

    try {
      const body = newStatus
        ? { person_id: String(personId), rsvp_status: newStatus }
        : { person_id: String(personId), clear: 'true' };
      await this.auth.fetch(`/api/events/chat-events/${chatEventId}/person-rsvp`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });
    } catch (err) {
      console.error('Failed to save practice RSVP:', err);
    }
  }

  async releasePracticeRSVP(personId, chatEventId, eventIdx) {
    const player = this.players.find(p => String(p.personId) === String(personId));
    // Optimistic: show as null while loading
    if (player && player.practice) player.practice[eventIdx] = null;

    try {
      const resp = await this.auth.fetch(`/api/events/chat-events/${chatEventId}/person-rsvp`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ person_id: String(personId), clear: 'true' })
      });
      const data = await resp.json();
      // Restore underlying GroupMe value if one exists
      if (player && player.practice && data.rsvpStatus) {
        player.practice[eventIdx] = { v: data.rsvpStatus, o: false };
      }
      this.renderOverlayList();
    } catch (err) {
      console.error('Failed to release practice RSVP:', err);
    }
  }

  async setPlayerRSVP(playerId, newStatus) {
    const matchId = this.navigation.context.match?.id;
    if (!matchId) return;

    const player = this.players.find(p => String(p.playerId) === String(playerId));
    if (player) {
      // Toggle off if same button clicked again
      if (player.rsvpStatus === newStatus) {
        player.rsvpStatus = null;
        player.rsvpSource = null;
        return;
      }
      player.rsvpStatus = newStatus;
      player.rsvpSource = 'admin';
    }

    try {
      await this.auth.fetch(`/api/matches/${matchId}/player-rsvp`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ player_id: String(playerId), rsvp_status: newStatus })
      });
    } catch (err) {
      console.error('Failed to save RSVP:', err);
    }
  }

  async saveJerseyNumber(playerId, number) {
    const player = this.players.find(p => String(p.playerId) === String(playerId));
    if (!player || !player.rosterTeamId) return;
    try {
      await this.auth.fetch(`/api/teams/${player.rosterTeamId}/roster/${playerId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ jerseyNumber: number ? parseInt(number) : null })
      });
    } catch (err) {
      console.error('Failed to save jersey number:', err);
    }
  }

  selectAllAttending() {
    const matchId = this.navigation.context.match?.id;
    this.players.filter(p => p.rsvpStatus === 'yes').forEach(p => {
      if (!this.selectedPlayerIds.has(p.playerId)) {
        this.selectedPlayerIds.add(p.playerId);
        this.toggleLineup(p.playerId, true);
      }
    });
    this.renderOverlayList();
    this.renderSelectedPlayers();
    this.updateSelectedCount();
    this.updateCardRoster();
  }

  updateSelectedCount() {
    const countEl = this.find('#selected-count');
    const selected = this.players.filter(p => this.selectedPlayerIds.has(p.playerId));
    const count = selected.length;
    const gk = selected.filter(p => p.isKeeper).length;
    const field = count - gk;
    countEl.textContent = `${count} selected (${field} field, ${gk} GK)`;
    countEl.className = 'gdr-count-badge' + (count > 20 ? ' gdr-count-over' : count >= 16 ? ' gdr-count-good' : '');
  }

  updateCardRoster() {
    const rosterSection = this.find('#gdr-card-roster');
    const namesEl = this.find('#gdr-roster-names');
    if (!rosterSection || !namesEl) return;

    if (this.selectedPlayerIds.size === 0) {
      rosterSection.style.display = 'none';
      return;
    }

    rosterSection.style.display = 'block';
    const selected = this.players.filter(p => this.selectedPlayerIds.has(p.playerId));
    // Two-column numbered roster
    namesEl.innerHTML = selected.map((p, i) => {
      const jersey = p.jerseyNumber ? `<span class="gdr-roster-num">#${p.jerseyNumber}</span>` : '';
      const gk = p.isKeeper ? ' <span class="gdr-roster-gk">GK</span>' : '';
      return `<div class="gdr-roster-entry">${jersey}<span class="gdr-roster-pname">${p.firstName} ${p.lastName}</span>${gk}</div>`;
    }).join('');
  }

  async shareAsImage() {
    const card = this.find('#gdr-card-inner');
    if (!card || typeof html2canvas === 'undefined') {
      alert('Image sharing not available');
      return;
    }
    try {
      this.updateCardRoster();
      const canvas = await html2canvas(card, { backgroundColor: null, scale: 2 });
      const link = document.createElement('a');
      link.download = 'game-day-roster.png';
      link.href = canvas.toDataURL('image/png');
      link.click();
    } catch (err) {
      console.error('Share error:', err);
      alert('Failed to generate image');
    }
  }

  copyAsText() {
    const m = this.matchDetails || {};
    const selected = this.players.filter(p => this.selectedPlayerIds.has(p.playerId));
    const d = m.event_date ? this.parseMatchDisplayDate(m.event_date) : null;

    let text = `\u26bd GAME DAY\n`;
    text += `${m.home_team_name || 'Home'} vs ${m.away_team_name || 'Away'}\n`;
    if (d) text += `\ud83d\udcc5 ${d.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}\n`;
    if (d) text += `\ud83d\udd50 ${d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}\n`;
    if (m.venue_name) text += `\ud83d\udccd ${m.venue_name}\n`;
    text += `\n\ud83d\udccb Game Day Roster (${selected.length}):\n`;
    selected.forEach((p, i) => {
      const jersey = p.jerseyNumber ? `#${p.jerseyNumber} ` : '';
      text += `${i + 1}. ${jersey}${p.firstName} ${p.lastName}\n`;
    });

    navigator.clipboard.writeText(text).then(() => {
      alert('\u2713 Copied to clipboard!');
    }).catch(() => {
      const ta = document.createElement('textarea');
      ta.value = text;
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      document.body.removeChild(ta);
      alert('\u2713 Copied to clipboard!');
    });
  }

  async toggleLineup(playerId, add) {
    const matchId = this.navigation.context.match?.id;
    if (!matchId) return;
    try {
      if (add) {
        await this.auth.fetch(`/api/matches/${matchId}/lineup/${playerId}`, { method: 'POST' });
      } else {
        await this.auth.fetch(`/api/matches/${matchId}/lineup/${playerId}`, { method: 'DELETE' });
      }
    } catch (err) {
      console.error('Failed to toggle lineup:', err);
    }
  }

  titleCase(str) {
    return str.replace(/\b\w+/g, w => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase());
  }

  parseMatchDisplayDate(rawDate) {
    if (!rawDate) return null;
    const s = String(rawDate).trim();

    // Feed timestamps are sometimes sent with +00 even though they are intended as local kickoff times.
    // For display, treat UTC-tagged values as local wall-clock time.
    if (/(?:Z|\+00(?::?00)?)$/i.test(s)) {
      const m = s.match(/^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})(?::(\d{2}))?/);
      if (m) {
        const d = new Date(
          Number(m[1]),
          Number(m[2]) - 1,
          Number(m[3]),
          Number(m[4]),
          Number(m[5]),
          Number(m[6] || 0)
        );
        if (!isNaN(d)) return d;
      }
    }

    const d = new Date(s);
    return isNaN(d) ? null : d;
  }

  resolveActiveTeamId() {
    if (this.navigation.context.lineupTeamId) {
      return String(this.navigation.context.lineupTeamId);
    }

    if (this.navigation.context.team?.id) {
      return String(this.navigation.context.team.id);
    }

    const rosterTeamIds = [...new Set((this.players || []).map(player => player.rosterTeamId).filter(Boolean))];
    if (rosterTeamIds.length === 1) {
      return String(rosterTeamIds[0]);
    }

    return this.matchDetails?.home_team_id ? String(this.matchDetails.home_team_id) : '';
  }

  resolveActiveTeamContext() {
    if (this.navigation.context.team?.id) {
      return this.navigation.context.team;
    }

    const teamId = this.resolveActiveTeamId();
    if (!teamId || !this.matchDetails) {
      return null;
    }

    if (String(this.matchDetails.home_team_id) === String(teamId)) {
      return { id: teamId, name: this.matchDetails.home_team_name || 'Home' };
    }

    if (String(this.matchDetails.away_team_id) === String(teamId)) {
      return { id: teamId, name: this.matchDetails.away_team_name || 'Away' };
    }

    return { id: teamId, name: this.matchDetails.home_team_name || this.matchDetails.away_team_name || 'Team' };
  }

  showSocialPreview(postType) {
    const container = this.find('#social-preview-container');
    if (!container) return;

    const matchId = this.matchDetails?.id;
    const team = this.resolveActiveTeamContext();
    if (!matchId || !team) return;

    this.navigation.context.lineupTeamId = String(team.id);
    if (!this.navigation.context.team) {
      this.navigation.context.team = team;
    }

    // Create fresh card in the container
    container.innerHTML = '';
    const card = new SocialPostCard(this.auth);
    const rosterData = {
      players: this.players,
      selectedIds: this.selectedPlayerIds
    };
    card.init(container, matchId, team.id, postType, this.matchDetails, rosterData);
    this.activeSocialCard = card;
  }
}
