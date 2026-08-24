// GameDayRosterScreen - Coach manages game day roster with enriched player overlay
// Features: player selection, RSVP override (auto-saves), match card, share
class GameDayRosterScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.players = [];
    this.matchDetails = null;
    this.selectedPlayerIds = new Set();
    // playerId -> 'starter' | 'bench'. selectedPlayerIds deliberately
    // stays a flat set (every consumer on this screen wants "is this
    // player on the game-day roster at all"); this keeps the zone that
    // set throws away, for the one consumer that needs it — the
    // Starters & Bench post graphic. See loadData's lineup merge.
    this.selectedZones = new Map();
    this._listenersAttached = false;
    this.overlayOpen = false;
    this.filterText = '';
    this.filterRsvp = 'all';
    this.listFilter = 'all';
    this._pendingPostType = null;
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
          <!-- Post-type pills + the ONE preview image, which changes per
               pill (owner, 2026-08-22: "the image on insta post screen
               should be at top and not under 1 image should change at
               top depending on pill selection... don't need multiple
               images on that screen its confusing" -- replaces the old
               static "MATCH DAY" card that always showed a live SQUAD
               list regardless of which post type was selected, which is
               also what looked like players showing up on the Game
               Announcement post even though that post type itself never
               included a roster). -->
          <div class="gdr-social-row">
            <div class="gdr-social-buttons">
              <button class="gdr-social-btn" data-post-type="game_day" style="--btn-accent:#f59e0b;">⚽ Game<br>Announcement</button>
              <button class="gdr-social-btn" data-post-type="lineup" style="--btn-accent:#8b5cf6;">📋 20-Man<br>Squad</button>
              <button class="gdr-social-btn" data-post-type="pre_match_announcement" style="--btn-accent:#3b82f6;">⚔️ Starters<br>& Bench</button>
              <button class="gdr-social-btn" data-post-type="post_game" style="--btn-accent:#22c55e;">🏆 Match<br>Result</button>
            </div>
            <div class="gdr-lineup-links">
              <button id="set-starters-btn" class="btn btn-secondary btn-sm" style="font-size:0.75em;padding:2px 8px;">✏️ Edit Lineup</button>
            </div>
          </div>

          <!-- Inline social post preview (shown when a social button is clicked) -->
          <div id="social-preview-container"></div>

          <!-- Old static match card kept in the DOM (hidden) -- several
               call sites still populate it (renderMatchCard(),
               updateCardRoster()) and shareAsImage()/copyAsText() still
               read it. Hiding instead of deleting avoids guarding every
               one of those against a missing element. -->
          <div id="match-card-share" class="gdr-match-card" style="display:none;">
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
                <div class="gdr-detail" id="gdr-date">📅 —</div>
                <div class="gdr-detail" id="gdr-time">🕐 —</div>
                <div class="gdr-detail" id="gdr-venue">📍 —</div>
              </div>
              <div class="gdr-card-roster" id="gdr-card-roster" style="display:none;">
                <div class="gdr-card-divider"></div>
                <div class="gdr-roster-title">SQUAD</div>
                <div class="gdr-roster-grid" id="gdr-roster-names"></div>
              </div>
              <div class="gdr-card-footer">
                <span class="gdr-card-brand" id="gdr-card-brand">⚽ Philadelphia</span>
              </div>
            </div>
            <div class="gdr-share-actions">
              <button id="share-card-btn" class="btn btn-secondary btn-sm">📸 Share Image</button>
              <button id="copy-text-btn" class="btn btn-secondary btn-sm">📋 Copy Text</button>
            </div>
          </div>

          <!-- Read-only view of whoever the Lineup screen currently has as
               starter/bench (owner: "the 20 man is a view") — RSVP status,
               jersey numbers, and practice attendance stay editable here,
               but who's actually on the game roster is set on the Lineup
               screen only. -->
          <div class="gdr-selection-header">
            <div id="selected-count" class="gdr-count-badge">0 on lineup</div>
            <button id="open-overlay-btn" class="btn btn-primary btn-sm">👥 RSVP & Player Details</button>
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
              <option value="none">No Response</option>
              <option value="no">Not Attending</option>
            </select>
            <select id="list-filter" class="gdr-filter-select">
              <option value="all">All Players</option>
              <optgroup label="Official Rosters">
                <option value="roster_lighthouse">APSL Lighthouse 1893</option>
                <option value="roster_casa">Lighthouse Boys Club</option>
                <option value="roster_u23">Lighthouse Boys Club U23</option>
              </optgroup>
            </select>
          </div>
          <div id="overlay-player-list" class="gdr-overlay-list"></div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    // Deep-link from game-lineup.js's "📸 Post to Instagram" button — auto-
    // opens the matching social-post tab once loadData() below resolves,
    // instead of making the admin click a tab that's already implied by
    // which lineup sub-view they were just looking at.
    this._pendingPostType = (params && params.postType) || null;
    if (this._listenersAttached) return;
    this._listenersAttached = true;

    this.loadData();
    
    this.element.addEventListener('click', (e) => {
      const target = e.target;
      const id = target.id || target.closest('[id]')?.id;
      
      if (id === 'back-btn') { this.navigation.goBack(); return; }
      if (id === 'open-overlay-btn') { this.openOverlay(); return; }
      if (id === 'close-overlay-btn') { this.closeOverlay(); return; }
      if (id === 'share-card-btn') { this.shareAsImage(); return; }
      if (id === 'copy-text-btn') { this.copyAsText(); return; }
      if (id === 'set-starters-btn') {
        const matchId = this.navigation.context.match?.id;
        if (matchId) this.navigation.goTo('game-lineup', { matchId });
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

      // Practice cell click — toggle yes → no → release ("maybe" removed 2026-07-10)
      const pracCell = e.target.closest('.gdr-prac-cell');
      if (pracCell) {
        e.stopPropagation();
        const personId = pracCell.dataset.personId;
        const eventId = pracCell.dataset.eventId;
        const eventIdx = parseInt(pracCell.dataset.eventIdx);
        const current = pracCell.dataset.current;
        const isOverride = pracCell.classList.contains('gdr-prac-override');

        if (isOverride) {
          // Override cell: yes → no → release
          const cycle = { 'yes': 'no', 'no': null };
          const next = current in cycle ? cycle[current] : 'no';
          if (next === null) {
            this.releasePracticeRSVP(personId, eventId, eventIdx);
          } else {
            this.setPracticeRSVP(personId, eventId, eventIdx, next);
          }
        } else {
          // Non-override cell: empty → yes (sets override), or cycle yes → no → yes
          const cycle = { '': 'yes', 'yes': 'no', 'no': 'yes' };
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
      // (chat sync removed — RSVP data comes straight from event_rsvps)
      const teamId = this.resolveActiveTeamId();

      const [matchRes, playersRes, lineupRes] = await Promise.all([
        this.auth.fetch(`/api/matches/${matchId}`),
        this.auth.fetch(`/api/matches/${matchId}/roster-players?teamId=${teamId}`),
        this.auth.fetch(`/api/eligibility/lineup/${matchId}`)
      ]);
      const [matchData, playersData, lineupData] = await Promise.all([matchRes.json(), playersRes.json(), lineupRes.json()]);

      if (matchData.success) {
        this.matchDetails = matchData.data;
        this.renderMatchCard();
      }

      if (playersData.success) {
        this.players = playersData.data || [];
        this.trainingEvents = playersData.trainingEvents || [];
      }

      // Who's "on the roster" here is a VIEW of game-lineup.js's own
      // starter/bench zones (owner, 2026-08-22: "it does not need set
      // lineup for 20 man and starters and bench. just one unified set
      // lineup then you glean the post from that... the 20 man is a
      // view. right?") — NOT a separately toggleable flag on this screen.
      // The old flat p.onGameRoster check (any match_lineups row at all,
      // regardless of zone) came from this same screen's own
      // "+Add/Edit Players" checkbox, which wrote zone-less rows via
      // POST /api/matches/:matchId/lineup/:playerId — orphaned from
      // whatever the coach actually set as starters/bench/alt, which is
      // exactly what showed up here as extra/wrong players on the post.
      this.selectedPlayerIds = new Set();
      this.selectedZones = new Map();
      if (lineupData && lineupData.success) {
        // this.players (roster-players?teamId=X) is scoped to ONE of the
        // match's tagged teams — for a dual-tagged event ("Team: APSL,
        // Liga 1") that leaves starter/bench players from the OTHER team
        // missing jersey/isKeeper/etc, which is exactly how a coach's
        // full 20-man lineup turned into a partial "extra/wrong players"
        // squad list on the post. The eligibility endpoint already does
        // the proper multi-team roster merge (see its own rosterTeamIds
        // comment) and returns firstName/lastName/position per row, so
        // fall back to that for anyone this.players doesn't have.
        const byId = new Map((this.players || []).map(p => [String(p.playerId), p]));
        for (const row of (lineupData.data.lineup || [])) {
          if (row.zone !== 'starter' && row.zone !== 'bench') continue;
          const pid = String(row.playerId);
          this.selectedPlayerIds.add(pid);
          this.selectedZones.set(pid, row.zone);
          if (!byId.has(pid)) {
            const fallback = {
              playerId: pid,
              firstName: row.firstName || '',
              lastName: row.lastName || '',
              position: row.position || '',
              jerseyNumber: '',
              isKeeper: row.position === 'GK',
            };
            byId.set(pid, fallback);
            this.players.push(fallback);
          }
        }
      }

      this.find('#roster-loading').style.display = 'none';
      this.find('#roster-content').style.display = 'block';
      this.renderSelectedPlayers();
      this.updateSelectedCount();
      this.updateCardRoster();

      if (this._pendingPostType) {
        const postType = this._pendingPostType;
        this._pendingPostType = null;
        this.showSocialPreview(postType);
        const activeBtn = this.element.querySelector(`.gdr-social-btn[data-post-type="${postType}"]`);
        if (activeBtn) {
          this.element.querySelectorAll('.gdr-social-btn').forEach(b => b.classList.remove('active'));
          activeBtn.classList.add('active');
          activeBtn.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
      }

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
    // No client-side placeholder: away_team_logo already falls back
    // through opponent aliases, name match, logo cache and finally the
    // league's own crest (EventController). The hardcoded tcwsl.png that
    // used to live here made every untagged informal match look like a
    // women's league game.
    const awayLogoUrl = m.away_team_logo || null;
    awayLogo.innerHTML = this.buildTeamLogoMarkup(awayLogoUrl, {
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
    // Prefer the full street address (owner: "on all views show address
    // of game") \u2014 venue_location is the gcal event's free-text location,
    // the same source the My page already shows; venue_name is just the
    // structured `venues` table row, usually empty for scraped matches.
    const venueText = m.venue_location || m.venue_name;
    if (venueText) {
      this.find('#gdr-venue').textContent = '\ud83d\udccd ' + (m.venue_location ? venueText : this.titleCase(venueText));
    }

    // Dynamic league brand in footer
    const brandEl = this.find('#gdr-card-brand');
    if (brandEl) {
      const comp = `${m.competition_name || ''} ${m.division_name || ''}`;
      const isCasa = m.source_name === 'casa' || /casa|liga\s*[12]/i.test(comp);
      if (isCasa) {
        const isLiga2 = String(m.home_team_id) === '121' || String(m.away_team_id) === '121' || /liga\s*2/i.test(comp);
        const liga = isLiga2 ? '2' : '1';
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
      container.innerHTML = '<div class="gdr-empty">No one on the lineup yet. Tap "✏️ Edit Lineup" to set starters &amp; bench.</div>';
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
      const rsvpClass = p.rsvpStatus === 'yes' ? 'gdr-rsvp-yes' : p.rsvpStatus === 'no' ? 'gdr-rsvp-no' : 'gdr-rsvp-none';
      const rsvpLabel = p.rsvpStatus || 'none';

      // Mini practice dots
      const pracDots = (this.trainingEvents || []).map((te, i) => {
        const entry = p.practice ? p.practice[i] : null;
        const v = entry ? (typeof entry === 'object' ? entry.v : entry) : null;
        const cls = v === 'yes' ? 'gdr-dot-yes' : v === 'no' ? 'gdr-dot-no' : 'gdr-dot-none';
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
      // List filter (official rosters)
      if (this.listFilter !== 'all') {
        const map = {
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
            <th class="gdr-th-cb" title="On the lineup (starter or bench) — set in the Lineup screen">Lineup</th>
            <th>Player</th>
            <th>#</th>
            <th>Pos</th>
            <th>RSVP</th>
            <th>GK</th>
            <th>Fam</th>
            <th class="gdr-section-divider" colspan="${(this.trainingEvents || []).length || 1}">Practice</th>
            <th class="gdr-section-divider" colspan="3">Roster</th>
          </tr>
          <tr class="gdr-subheader">
            <th></th><th></th><th></th><th></th><th></th><th></th><th></th>
            ${practiceHeaders}
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
      const cls = v === 'yes' ? 'gdr-prac-yes' : v === 'no' ? 'gdr-prac-no' : 'gdr-prac-none';
      const ovrCls = isOverride ? ' gdr-prac-override' : '';
      const sym = v === 'yes' ? '&check;' : v === 'no' ? '&cross;' : '&mdash;';
      return `<td class="gdr-cell-center gdr-prac-cell ${cls}${ovrCls}" data-person-id="${p.personId}" data-event-id="${te.id}" data-event-idx="${i}" data-current="${v || ''}" title="${isOverride ? 'Admin override' : 'Synced'}">${sym}</td>`;
    }).join('');

    // Roster membership cells
    const rosterCell = (val) => val ? '<td class="gdr-cell-center gdr-in">&check;</td>' : '<td class="gdr-cell-center gdr-out"></td>';
    
    return `
      <tr class="gdr-overlay-row ${selected ? 'gdr-row-selected' : ''}" data-player-id="${p.playerId}">
        <td class="gdr-cell-center" title="Set in the Lineup screen — starter or bench">${selected ? '&check;' : ''}</td>
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
            <button class="gdr-rsvp-btn ${rsvpValue === 'no' ? 'gdr-rsvp-active-no' : ''}" data-player-id="${p.playerId}" data-rsvp="no" title="Not going">N</button>
          </div>
          ${rsvpSource === 'admin' ? '<span class="gdr-rsvp-src gdr-src-admin" title="Admin override">\u270e</span>' : ''}
        </td>
        <td class="gdr-cell-center">${p.isKeeper ? '\ud83e\udde4' : ''}</td>
        <td class="gdr-cell-center">${p.hasFamilyDiscount ? '\ud83d\udc6a' : ''}</td>
        ${practiceCells}
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
      // Restore underlying value if one exists
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

  updateSelectedCount() {
    const countEl = this.find('#selected-count');
    const selected = this.players.filter(p => this.selectedPlayerIds.has(p.playerId));
    const count = selected.length;
    const gk = selected.filter(p => p.isKeeper).length;
    const field = count - gk;
    countEl.textContent = `${count} on lineup (${field} field, ${gk} GK)`;
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
      selectedIds: this.selectedPlayerIds,
      zones: this.selectedZones
    };
    card.init(container, matchId, team.id, postType, this.matchDetails, rosterData);
    this.activeSocialCard = card;
  }
}
