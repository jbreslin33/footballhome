class RosterScreenBase extends Screen {
  // Closes any open roster-move-details popover when a click lands
  // outside every such popover (2026-08-02, user directive — clicking
  // away used to leave it hanging open with no way to close it besides
  // picking a new team). One document-level listener shared by every
  // roster screen instance/re-render; each screen's onEnter calls this
  // idempotently, so it's only ever installed once per page load.
  static installMoveDropdownOutsideClose() {
    if (window._rosterMoveDropdownOutsideCloseInstalled) return;
    window._rosterMoveDropdownOutsideCloseInstalled = true;
    document.addEventListener('click', (e) => {
      document.querySelectorAll('.roster-move-details[open]').forEach((d) => {
        if (!d.contains(e.target)) d.open = false;
      });
    });
  }

  // Shared with MensRosterScreen's own copy (mens-roster.js) — kept as
  // a separate method rather than hoisting fully because Mens renders
  // an entirely different read-only layout for players, while the
  // Boys/Girls/Womens family (this base class) reuses the normal card
  // layout and just strips the drag/move affordances below.
  _isPlayerView() {
    const role = (this.navigation?.context?.role || this.auth?.user?.role || '').toString().toLowerCase();
    return role === 'player';
  }

  // ── Card view mode (2026-08-25) ─────────────────────────────────────
  //
  // Owner: "we need option to scroll across on teams page so that stuff
  // don't get cut off in card like names or to make them fit by making
  // the card taller. sould be a pill selectoin to change view on page."
  //
  // Two ways to stop a long name being clipped, and they trade off
  // against each other, so the board offers both rather than picking:
  //
  //   'fit'    — every column stays on screen; the card stacks one item
  //              per line (name, then chips, then the controls) so the
  //              name owns the card's full width and wraps at spaces.
  //              Nothing is hidden, the board never scrolls sideways,
  //              cards get taller and rows get uneven.
  //   'scroll' — cards stay thin: name and controls share one row and
  //              the name never wraps, so a card is one line tall and a
  //              column shows many players at once. The column widens to
  //              whatever its longest name needs and the board pans.
  //
  // 'fit' is the default: it is the one where every column is reachable
  // without panning.
  //
  // 'compact' (truncate with an ellipsis) was dropped 2026-08-26 — owner:
  // "compact i would think is the same as fit so prob redundant?". It was
  // the only mode that hid a name, which is the thing all three were
  // added to stop. A stored 'compact' preference falls back to 'fit'.
  //
  // Persisted per browser so the choice survives a reload — a view
  // preference is exactly the kind of thing that is annoying to re-pick.
  // Wrapped in try/catch: localStorage throws outright in some privacy
  // modes, and a board that will not render is worse than a forgotten
  // preference.
  static VIEW_MODES = [
    { id: 'fit',    label: 'Fit',    title: 'Keep every column on screen — each card stacks one item per line so the full name fits' },
    { id: 'scroll', label: 'Scroll', title: 'Thin one-line cards with the full name — scroll across to reach every column' },
  ];

  get viewMode() {
    if (this._viewMode) return this._viewMode;
    let stored = null;
    try { stored = window.localStorage.getItem('fh.roster.viewMode'); } catch (_) { /* private mode */ }
    const valid = RosterScreenBase.VIEW_MODES.some(m => m.id === stored);
    this._viewMode = valid ? stored : 'fit';
    return this._viewMode;
  }

  set viewMode(mode) {
    if (!RosterScreenBase.VIEW_MODES.some(m => m.id === mode)) return;
    this._viewMode = mode;
    try { window.localStorage.setItem('fh.roster.viewMode', mode); } catch (_) { /* private mode */ }
  }

  // Pill group for the board's control bar. Click handling is delegated
  // per screen (same pattern as the team-focus pills) via
  // onViewModePillClick below.
  renderViewModePills() {
    return `
      <span style="opacity:0.7; font-size:0.8rem; font-weight:600; margin-left:auto;">View:</span>
      ${RosterScreenBase.VIEW_MODES.map((m) => {
        const on = this.viewMode === m.id;
        return `<button type="button" class="roster-view-pill" data-view-mode="${m.id}"
                        title="${this.escape(m.title)}"
                        style="font-size:0.8rem; font-weight:${on ? 700 : 400}; padding:2px 10px; border-radius:999px; cursor:pointer;
                               border:1px solid ${on ? '#94a3b8' : 'var(--border-color)'};
                               background:${on ? '#94a3b8' : 'transparent'};
                               color:${on ? '#0f172a' : 'inherit'};">${m.label}</button>`;
      }).join('')}`;
  }

  // Returns true when the click was a view pill and the board should
  // re-render. Screens wire this into their existing delegated handler.
  onViewModePillClick(btn) {
    const mode = btn?.dataset?.viewMode;
    if (!mode || mode === this.viewMode) return false;
    this.viewMode = mode;
    return true;
  }

  // Style for the grid wrapper: 'scroll' turns the board into a single
  // panning row; 'fit' keeps the wrapping auto-fit grid.
  //
  // overflow-x:auto forces overflow-y to auto as a CSS side effect, which
  // clips the move-dropdown popover on a card near the bottom of a column
  // (found 2026-08-21, see colMinWidth). padding-bottom gives that popover
  // room to open inside the scroll box instead of being cut off.
  gridStyleFor(colCount) {
    if (this.viewMode === 'scroll') {
      // fit-content(), not minmax(190px, max-content). A scroll column's
      // job is to hold its longest name on one line, so it has to size
      // to that name — but minmax() only grows a track when the grid has
      // free space left over, and a board that overflows on purpose has
      // none, so every column pinned itself to the 190px floor and cut
      // exactly the names this mode exists to show (2026-08-26).
      // fit-content(260px) sizes each column to min(content, 260px) and
      // never below its min-content, which — with the card's name set
      // nowrap and non-shrinking below — always includes the whole name.
      // So: thin uniform columns, full names, wider only where a name
      // genuinely demands it.
      return 'display:grid; grid-auto-flow:column; grid-auto-columns:fit-content(260px); '
           + 'gap:var(--space-2); align-items:start; overflow-x:auto; padding-bottom:220px; margin-bottom:-200px;';
    }
    return `display:grid; grid-template-columns: repeat(auto-fit, minmax(${this.colMinWidth(colCount)}, max-content)); `
         + 'gap:var(--space-2); align-items:start;';
  }

  // min-width for a board column box (the column card and its drop zone).
  //
  // 'fit' wants 0: it lets a grid item shrink below its content so the
  // columns always fit the viewport (the cards inside wrap instead).
  // 'scroll' must NOT — min-width:0 also erases the box's min-content
  // contribution, which is the number fit-content() sizes the track
  // from, so the column collapsed narrower than its own widest card and
  // the names it is supposed to show on one line ran out of it
  // (2026-08-26). 'auto' restores the intrinsic floor.
  colBoxMinWidth() {
    return this.viewMode === 'scroll' ? 'auto' : '0';
  }

  // Role → capability. Mirrors the role strings role-selection.js actually
  // sets on navigation.context.role ('coach', 'player', 'club-admin') with
  // a fallback to the account's DB-level role (auth.user.role — 'club',
  // 'super', 'system', 'sport_division', 'team', 'league' all read as
  // full club-admin per the same isAdmin list role-selection.js uses to
  // decide whether to show the Administration tile at all).
  _roleForCards() {
    return (this.navigation?.context?.role || this.auth?.user?.role || '').toString().toLowerCase();
  }

  _cardClassFor() {
    const role = this._roleForCards();
    if (role === 'player') return TeamCard;
    const adminRoles = ['admin', 'club-admin', 'club', 'sport_division', 'team', 'super', 'system', 'league'];
    if (adminRoles.includes(role)) return AdminTeamCard;
    if (role === 'coach') return CoachTeamCard;
    // Unrecognized/missing role: default to view-only rather than
    // silently granting move rights.
    return TeamCard;
  }

  // Which teams the current card class is allowed to move players into.
  // Admin gets every configured column on this board (full club access —
  // no separate lookup needed, it's just "every column we already loaded").
  // Coach gets the specific team_coaches-backed list the Teams screen
  // fetched via GET /api/auth/coach/teams and stashed on
  // navigation.context.coachedTeamIds before mounting this board (see
  // rosters.js). Player never calls this (TeamCard ignores it).
  _coachedTeamIds(columns) {
    const role = this._roleForCards();
    const adminRoles = ['admin', 'club-admin', 'club', 'sport_division', 'team', 'super', 'system', 'league'];
    if (adminRoles.includes(role)) {
      return (columns || []).map((c) => c.teamId);
    }
    return this.navigation?.context?.coachedTeamIds || [];
  }

  // Builds the role-gated move control + drag eligibility for one card via
  // the TeamCard/CoachTeamCard/AdminTeamCard hierarchy (components/TeamCard.js).
  // Returns { rosterSelectHtml, canMove } for renderCompactCard.
  _teamCardCapabilities(player, columns, col) {
    const CardClass = this._cardClassFor();
    const card = new CardClass({ player, columns, col }, {
      coachedTeamIds: this._coachedTeamIds(columns),
      renderMoveDropdown: (p, cols, currentTeamId) => this.renderMoveDropdown(p, cols, currentTeamId),
    });
    return {
      rosterSelectHtml: card.renderMoveControl(),
      canMove: card.canDrag(),
    };
  }

  // ── Roster Role + Official Roster Status dropdowns (2026-08-22) ──────
  //
  // Shared by every roster board (Mens/Boys/Girls/Womens) — "make all
  // pills same since it's generic" (owner directive, after the labels
  // were renamed from "APSL ..." to "1st Team ..." specifically so this
  // could roll out past mens without misleading wording). Both are plain
  // per-(team, person) team_persons designations, independent of which
  // domain/column they're rendered on:
  //   • lineup_role_id  — coach-set "1st Team Starter/Bench/Reserve"
  //     (migration 279/283/293), originally the game-lineup screen's
  //     "Elig: Start/Bench" toggle before it moved to the Teams page.
  //   • roster_status_id — official league roster submission status
  //     (migration 294/295/319/336/337/340/342). The list is NOT
  //     hardcoded here: roster_statuses is fetched once per page load
  //     (loadRosterStatuses below) and each column shows the statuses
  //     its team's league uses (league_roster_statuses, migration 342 —
  //     owner 2026-09-07 "lets do per league"). Adult leagues carry the
  //     ITC / transfer wait, Parks & Rec carries the birth-certificate
  //     docs steps, in-house carries only the docs steps.
  // Keyed by personId (not leagueAppsUserId) — same LA-userId-drift
  // immunity as the reorder/move endpoints; see
  // TeamController::handleSetLineupRoleForPerson /
  // handleSetRosterStatusForPerson.
  //
  // Width (owner 2026-09-06): both dropdowns size to their longest
  // option — "1st Team Starter", "Awaiting Roster Spot" — and stretch
  // to the card's control strip but no further. A native <select> is
  // intrinsically as wide as its widest option, so width:auto does the
  // sizing; max-width:100% is the cap, and min-width:0 lets the flex
  // item actually honour that cap instead of overflowing the card.
  // Replaces the old max-width:92px, which clipped every long label.
  static get SELECT_WIDTH_STYLE() {
    return 'width:auto; max-width:100%; min-width:0; box-sizing:border-box;';
  }

  renderRoleSelect(player, col, canMove) {
    if (!(canMove && col && col.teamId && player.personId)) return '';
    return `<select class="mr-role-select" data-team-id="${col.teamId}" data-person-id="${player.personId}"
               title="Lineup tier — T1 Starter, T2 Starter/Sub, T3 Sub (none = T4 Depth), or 🔄 Reserve for a call-up"
               style="font-size:0.6rem; font-weight:800; letter-spacing:0.01em; padding:0 2px; line-height:1.2; border-radius:3px; border:1px solid #475569; background:#0f172a; color:#fff; ${RosterScreenBase.SELECT_WIDTH_STYLE}">
         <option value=""        ${!player.lineupRole ? 'selected' : ''}>T4 · Depth</option>
         <option value="starter"  ${player.lineupRole === 'starter'  ? 'selected' : ''}>T1 · Starter</option>
         <option value="bench"    ${player.lineupRole === 'bench'    ? 'selected' : ''}>T2 · Starter/Sub</option>
         <option value="sub_late" ${player.lineupRole === 'sub_late' ? 'selected' : ''}>T3 · Sub</option>
         <option value="reserve"  ${player.lineupRole === 'reserve'  ? 'selected' : ''}>🔄 Reserve</option>
       </select>`;
  }

  // ── Roster statuses come from the DB (migration 342) ─────────────────
  //
  // GET /api/teams/roster-statuses is fetched once per page load and
  // cached on the class, shared by every board. Each status carries the
  // leagues whose pipeline includes it (leagueIds), its card colours
  // (colorBg/Fg/Border — the 2026-09-05 palette: green On Roster, yellow
  // "league is sitting on it" waits, orange Possible Drop, emerald Has
  // Docs, rose Needs Docs, everything else neutral) and whether it counts
  // toward the "✓ N on roster" tally (countsAsOnRoster — On Roster and
  // Possible Drop; Suspended is rostered but not playing). Nothing in
  // this file is keyed on a status code any more.
  //
  // A column's dropdown lists the statuses of its team's league
  // (col.leagueId / col.leagueName from teams.division_id → seasons →
  // leagues). A column with no league gets the full list.
  static ROSTER_STATUSES = [];
  static _rosterStatusesPromise = null;
  static NEUTRAL_STATUS_COLORS = { bg: '#0f172a', fg: '#ffffff', border: '#475569' };

  static loadRosterStatuses(auth) {
    if (!RosterScreenBase._rosterStatusesPromise) {
      RosterScreenBase._rosterStatusesPromise = (async () => {
        try {
          const res = await auth.fetch('/api/teams/roster-statuses');
          if (!res.ok) throw new Error(`HTTP ${res.status}`);
          const body = await res.json();
          RosterScreenBase.ROSTER_STATUSES = Array.isArray(body && body.data) ? body.data : [];
        } catch (err) {
          // Dropdowns fall back to "blank + whatever the player already
          // has"; the next load() retries.
          console.warn('roster statuses unavailable:', err);
          RosterScreenBase._rosterStatusesPromise = null;
        }
        return RosterScreenBase.ROSTER_STATUSES;
      })();
    }
    return RosterScreenBase._rosterStatusesPromise;
  }

  // ── Per-card "fill out this form" nudges (migrations 356/357) ──────
  //
  // message_templates rows with kind='registration', one category per
  // board: "Men's Club" → 📋 Liga1/APSL Reg + APSL Reg, "Youth Travel"
  // → 📄 Docs reminder (boys + girls).  label = button text, icon =
  // what renderMessageButtons draws, subject/body = compose pre-fill,
  // sort_order = button order.  Loaded once per page life per category
  // in parallel with the roster (screens await it before first render
  // so renderPlayer stays synchronous); a failed fetch yields no
  // buttons and the next load() retries.
  static _cardTemplates = new Map();          // category → presets[]
  static _cardTemplatePromises = new Map();   // category → Promise

  static loadCardTemplates(auth, category) {
    if (!RosterScreenBase._cardTemplatePromises.has(category)) {
      RosterScreenBase._cardTemplatePromises.set(category, (async () => {
        try {
          const qs = new URLSearchParams({ category, kind: 'registration' });
          const res = await auth.fetch(`/api/messages/templates?${qs}`);
          if (!res.ok) throw new Error(`HTTP ${res.status}`);
          const body = await res.json();
          const rows = Array.isArray(body && body.data) ? body.data : [];
          RosterScreenBase._cardTemplates.set(category, rows.map(t => ({
            key:     String(t.id),
            icon:    t.icon || '',
            label:   t.label,
            subject: t.subject || '',
            body:    t.body || '',
          })));
        } catch (err) {
          console.warn(`card templates unavailable for ${category}:`, err);
          RosterScreenBase._cardTemplates.set(category, []);
          RosterScreenBase._cardTemplatePromises.delete(category);
        }
        return RosterScreenBase.cardTemplates(category);
      })());
    }
    return RosterScreenBase._cardTemplatePromises.get(category);
  }

  static cardTemplates(category) {
    return RosterScreenBase._cardTemplates.get(category) || [];
  }

  // Screens call this alongside their roster fetch and await it before
  // the first render, so renderStatusSelect can stay synchronous.
  ensureRosterStatuses() {
    return Promise.all([
      RosterScreenBase.loadRosterStatuses(this.auth),
      RosterScreenBase.loadHealth(this.auth),
    ]);
  }

  // ── Health: Healthy / injured, with a time frame (migration 510) ─────
  //
  // Owner 2026-10-02: "we need an injured check box or setting in the drop
  // down … Healthy, short term injury, long term injury. or allow for
  // setting time frame … this way we can avoid sending practice reminders
  // and fining them."  A fact about the person, not the team: one
  // setting, shown on every card the player has.  GET /api/person-health
  // brings the dropdown (health_statuses), its words (message_templates
  // kind 'health') and who is injured right now; it is re-read on every
  // board load, because an injury ends on its own when its back-on day
  // arrives.  While injured a player owes no RSVP and is not fined — the
  // server's business (fh_person_injured_at); this file only sets it.
  static HEALTH = { statuses: [], copy: {}, people: {} };

  static async loadHealth(auth) {
    try {
      const res = await auth.fetch('/api/person-health');
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const body = await res.json();
      RosterScreenBase.HEALTH = {
        statuses: Array.isArray(body && body.statuses) ? body.statuses : [],
        copy:     (body && body.copy) || {},
        people:   (body && body.people) || {},
      };
    } catch (err) {
      // No control is drawn without the list; the next load() retries.
      console.warn('health statuses unavailable:', err);
    }
    return RosterScreenBase.HEALTH;
  }

  // The person's health code: their current injury, else the Healthy row.
  static healthCodeFor(personId) {
    const H = RosterScreenBase.HEALTH;
    const mine = H.people[personId];
    if (mine) return mine.code;
    const healthy = H.statuses.find(s => !s.isInjured);
    return healthy ? healthy.code : '';
  }

  static healthColors(code) {
    const s = RosterScreenBase.HEALTH.statuses.find(x => x.code === code);
    if (!s || !s.colorBg) return RosterScreenBase.NEUTRAL_STATUS_COLORS;
    return { bg: s.colorBg, fg: s.colorFg || '#ffffff', border: s.colorBorder || s.colorBg };
  }

  healthStyle(code) {
    const c = RosterScreenBase.healthColors(code);
    return `background:${c.bg}; color:${c.fg}; border:1px solid ${c.border};`;
  }

  // Club-local YYYY-MM-DD, `plusDays` days from today.
  static clubDay(plusDays = 0) {
    const today = new Intl.DateTimeFormat('en-CA', { timeZone: 'America/New_York' }).format(new Date());
    const d = new Date(`${today}T12:00:00Z`);
    d.setUTCDate(d.getUTCDate() + plusDays);
    return d.toISOString().slice(0, 10);
  }

  // The dropdown plus its two dates (shown only while injured), for the
  // card's ⋯ menu.  "Injured since" may be back-dated so events already
  // missed are excused too; "Back on" empty = until someone sets Healthy.
  renderHealthControl(player) {
    const H = RosterScreenBase.HEALTH;
    if (!H.statuses.length || !player.personId) return '';
    const esc     = RosterScreenBase.escapeHtml;
    const mine    = H.people[player.personId] || null;
    const current = RosterScreenBase.healthCodeFor(player.personId);
    const opts = H.statuses.map(s =>
      `<option value="${esc(s.code)}" ${current === s.code ? 'selected' : ''}>${esc((s.icon ? s.icon + ' ' : '') + s.displayName)}</option>`
    ).join('');
    const dateRow = (cls, label, value, bounds) =>
      `<label class="mr-health-dates" style="display:${mine ? 'flex' : 'none'}; flex-direction:column; gap:1px; font-size:0.58rem; font-weight:700; color:#cbd5e1;">
         ${esc(label || '')}
         <input type="date" class="${cls}" value="${esc(value || '')}" ${bounds}
                style="font-size:0.65rem; padding:0 2px; border-radius:3px; border:1px solid #475569; background:#0f172a; color:#fff; color-scheme:dark;">
       </label>`;
    return `<span class="mr-health" data-person-id="${player.personId}" style="display:flex; flex-direction:column; gap:3px;">
         <select class="mr-health-select" title="${esc(H.copy.select_title || '')}"
                 style="font-size:0.6rem; font-weight:800; letter-spacing:0.01em; padding:0 2px; line-height:1.2; border-radius:3px; ${this.healthStyle(current)} ${RosterScreenBase.SELECT_WIDTH_STYLE}">
           ${opts}
         </select>
         ${dateRow('mr-health-since', H.copy.since_label, mine && mine.since, `max="${RosterScreenBase.clubDay()}"`)}
         ${dateRow('mr-health-until', H.copy.until_label, mine && mine.until, `min="${RosterScreenBase.clubDay(1)}"`)}
       </span>`;
  }

  // The read-only chip on the card ("🩹 Short-term injury · back Tue Oct
  // 20" — the server builds the words), hidden while healthy.
  renderHealthChip(player) {
    const H = RosterScreenBase.HEALTH;
    if (!H.statuses.length || !player.personId) return '';
    const mine = H.people[player.personId] || null;
    return `<span data-health-chip="${player.personId}" ${mine ? '' : 'hidden'}
                  style="font-size:0.6rem; font-weight:800; line-height:1.3; padding:0 5px; border-radius:3px; white-space:nowrap; ${this.healthStyle(mine && mine.code)}">${RosterScreenBase.escapeHtml((mine && mine.label) || '')}</span>`;
  }

  // The screens' delegated change listeners call this first; true = the
  // change came from a health control and is being saved.
  onHealthControlChange(target) {
    const wrap = target && target.closest && target.closest('.mr-health');
    if (!wrap) return false;
    this.saveHealth(wrap);
    return true;
  }

  async saveHealth(wrap) {
    const H = RosterScreenBase.HEALTH;
    const personId = parseInt(wrap.dataset.personId, 10);
    const status = H.statuses.find(s => s.code === wrap.querySelector('.mr-health-select').value);
    if (!personId || !status) return;
    const body = { person_id: personId, status: status.code };
    if (status.isInjured) {
      // An empty "since" keeps what is saved (or starts now); an empty
      // "back on" means open-ended.
      const since = wrap.querySelector('.mr-health-since').value;
      const until = wrap.querySelector('.mr-health-until').value;
      if (since) body.since = since;
      if (until) body.until = until;
    }
    const controls = wrap.querySelectorAll('select, input');
    controls.forEach(el => { el.disabled = true; });
    try {
      const res = await this.auth.fetch('/api/person-health', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
      if (data.health) H.people[personId] = data.health; else delete H.people[personId];
    } catch (err) {
      alert(`Could not save health: ${err.message}`);
    } finally {
      controls.forEach(el => { el.disabled = false; });
      this.paintHealth(personId);   // saved state, or back to it after a failure
    }
  }

  // Every card the person has (a player can sit in two columns) shows
  // what is saved: dropdown, dates and chip.
  paintHealth(personId) {
    const mine = RosterScreenBase.HEALTH.people[personId] || null;
    const code = RosterScreenBase.healthCodeFor(personId);
    const c = RosterScreenBase.healthColors(code);
    this.element.querySelectorAll(`.mr-health[data-person-id="${personId}"]`).forEach(wrap => {
      const select = wrap.querySelector('.mr-health-select');
      select.value = code;
      select.style.background = c.bg; select.style.color = c.fg; select.style.borderColor = c.border;
      wrap.querySelectorAll('.mr-health-dates').forEach(l => { l.style.display = mine ? 'flex' : 'none'; });
      wrap.querySelector('.mr-health-since').value = (mine && mine.since) || '';
      wrap.querySelector('.mr-health-until').value = (mine && mine.until) || '';
    });
    this.element.querySelectorAll(`[data-health-chip="${personId}"]`).forEach(chip => {
      chip.hidden = !mine;
      chip.textContent = (mine && mine.label) || '';
      chip.style.background = c.bg; chip.style.color = c.fg; chip.style.border = `1px solid ${c.border}`;
    });
  }

  static rosterStatusByCode(code) {
    if (!code) return null;
    return RosterScreenBase.ROSTER_STATUSES.find(s => s && s.code === code) || null;
  }

  static rosterStatusesForColumn(col) {
    const leagueId = Number(col && col.leagueId) || 0;
    const all = RosterScreenBase.ROSTER_STATUSES;
    if (!leagueId) return all.slice();
    return all.filter(s => Array.isArray(s.leagueIds) && s.leagueIds.includes(leagueId));
  }

  static rosterStatusColors(code) {
    const s = RosterScreenBase.rosterStatusByCode(code);
    if (!s || !s.colorBg) return RosterScreenBase.NEUTRAL_STATUS_COLORS;
    return { bg: s.colorBg, fg: s.colorFg || '#ffffff', border: s.colorBorder || s.colorBg };
  }

  rosterStatusStyle(status) {
    const c = RosterScreenBase.rosterStatusColors(status);
    return `background:${c.bg}; color:${c.fg}; border:1px solid ${c.border};`;
  }

  // Re-paint a status <select> after its value changes (optimistic flip,
  // rollback, or a successful save) so the colour never lags the value.
  applyRosterStatusStyle(select) {
    if (!select) return;
    const c = RosterScreenBase.rosterStatusColors(select.value);
    select.style.background  = c.bg;
    select.style.color       = c.fg;
    select.style.borderColor = c.border;
    // The card's read-only status chip mirrors the select in its ⋯ menu.
    const card = select.closest('[data-roster-card]');
    const chip = card && card.querySelector('[data-roster-status-chip]');
    if (chip) {
      chip.hidden = !select.value || select.value === 'on_roster';   // 📋 ROSTERS says it (mig 1435)
      chip.textContent = select.value ? (select.selectedOptions[0]?.textContent || select.value) : '';
      chip.style.background = c.bg; chip.style.color = c.fg; chip.style.border = `1px solid ${c.border}`;
    }
  }

  static countsAsOnRoster(status) {
    const s = RosterScreenBase.rosterStatusByCode(status);
    return !!(s && s.countsAsOnRoster);
  }

  // Attribute/text escaper local to the base so the mens board (which has
  // no escape() of its own) renders the same dropdown as boys/womens.
  static escapeHtml(v) {
    return String(v == null ? '' : v)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }

  // "✓ N on roster" tally for a team column header, from the same
  // roster_status the per-card dropdown edits. Unassigned has no
  // team_persons rows, so no tally there. Carries data-on-roster-tally
  // so refreshOnRosterTally() can update it live after a dropdown change.
  //
  // Second line (owner 2026-09-05): the team's game format and how many
  // of those On-Roster players are subs — "7v7 · 3 subs". Format comes
  // from teams.field_size (migration 322) via col.fieldSize; columns
  // with no format on file just show the tally line.
  renderOnRosterTally(col, players) {
    // No league roster (winter practice groups, mig 1416) → no tally.
    if (!col || !col.teamId || col.leagueRoster === false) return '';
    const n = (players || []).filter(p => p && RosterScreenBase.countsAsOnRoster(p.rosterStatus)).length;
    const fieldSize = Number(col.fieldSize) || 0;
    return `<span data-on-roster-tally="${col.teamId}" data-field-size="${fieldSize}"
                  title="Players whose league roster status is On Roster"
                  style="display:inline-flex; flex-direction:column; align-items:flex-start; line-height:1.2; white-space:nowrap;">
              ${this.onRosterTallyHtml(n, fieldSize)}
            </span>`;
  }

  // Column sections — two views of the same column, picked by the
  // Players panel's Roster | Team pill (rosters.js; owner 2026-10-27:
  // "there is a roster which is league and a team which is functional" …
  // "planned drops stay in official, default roster").
  //
  // ROSTER (default) — the league side:
  //   ON ROSTER — the league's own list (the 🌐 mirror), one row per
  //     list name in the list's order.  A name matched to a player in this
  //     column is his full card (every control but remove — see
  //     renderMoveDropdown + the mig 772 trigger); a planned drop
  //     (roster_statuses.board_section 'drop') is flagged in place, never
  //     split out, so the section stays 1:1 with the list.  A list name
  //     with no FH person, or not on this team in FH, is a read-only row.
  //     A column with no list uses the On Roster status instead.
  //   NEEDS ADD — board_section proposed + pending_add: only players
  //     someone picked (owner 2026-11-02), grouped by step.
  //   (No NEEDS DROP since mig 1437 — owner 11/17 "take away needs drops".)
  //   Nothing else: a member on no list sits in the team-free left column
  //   (renderMemberStacks), so a column never implies he belongs to it.
  //   The card's status dropdown is the move control (mig 777).
  // TEAM — the functional (RSVP) side, by columnCategoryOf; each card
  //   wears a 📋 chip per official roster he is on: PLAYS, ⭐ CALL-DOWNS
  //   (standing invites riding in from other columns), ↔ CALL INS,
  //   PRACTICE SQUAD, 🩹 INJURED,
  //   💤 INACTIVE.
  // Every card keeps its true coach rank (#N) from the full column.
  // Section copy is message_templates kind roster_sheet (migs 770–775).
  // Read fresh each render so a cached board (Boys while Mens was shown)
  // picks up a pill flip made elsewhere; _boardView covers private mode.
  get boardView() {
    let v = this._boardView;
    try { v = localStorage.getItem(RosterScreenBase.BOARD_VIEW_STORAGE_KEY) || v; } catch (e) { /* private mode */ }
    return v === 'team' ? 'team' : 'roster';
  }

  setBoardView(view) {
    this._boardView = view === 'team' ? 'team' : 'roster';
    try { localStorage.setItem(RosterScreenBase.BOARD_VIEW_STORAGE_KEY, this._boardView); } catch (e) { /* private mode */ }
    if (this._data && typeof this.renderRoster === 'function') this.renderRoster(this._data);
  }

  static get BOARD_VIEW_STORAGE_KEY() { return 'fh.teams.boardView'; }

  // Team view layout (owner 11/19): 'graphic' = the team cards alone,
  // 'list' = the columns alone.  Per browser; graphic by default.
  static get TEAM_LAYOUT_STORAGE_KEY() { return 'fh.teams.teamLayout'; }
  static teamLayoutStored() {
    let v = null;
    try { v = localStorage.getItem(RosterScreenBase.TEAM_LAYOUT_STORAGE_KEY); } catch (e) { /* private mode */ }
    return v === 'list' ? 'list' : 'graphic';
  }
  get teamLayout() { return this._teamLayout || RosterScreenBase.teamLayoutStored(); }
  setTeamLayout(layout) {
    this._teamLayout = layout === 'list' ? 'list' : 'graphic';
    if (this._data && typeof this.renderRoster === 'function') this.renderRoster(this._data);
  }

  // ✅ active / 🩹 injured / practice_squad / inactive (📄 paper mig 1074, ↔ call-in mig 1076 folded in) —
  // the column pills' categories, also the Team view's sections.  An injured
  // player stays in INJURED whatever his squad group.
  columnCategoryOf(p) {
    if (p.squadStatus) return this.injuredInLitSeason(p.personId) ? 'injured' : p.squadStatus;
    // A bare invite-only row was a 📄 paper spot; since mig 1074 that is
    // 💤 Inactive on this team (rows carry the status, this is a guard).
    return p.inviteOnly === true ? 'inactive'   // ↔ Call-in folded in too (mig 1076)
      : (this.injuredInLitSeason(p.personId) ? 'injured' : 'active');
  }

  // Injured for the lit season?  An injury whose back-on day falls on or
  // before that season's start doesn't count there (owner 11/4: "add ryan
  // to ACTIVE because he will be healthy by then") — Winter shows him
  // ACTIVE while Fall still shows 🩹.  No back-on day = injured anywhere.
  injuredInLitSeason(personId) {
    const inj = RosterScreenBase.HEALTH.people[personId];
    if (!inj) return false;
    const t = this._term;
    const start = t && t.term && t.starts && t.starts[t.term];
    if (start && inj.until && String(inj.until).slice(0, 10) <= start) return false;
    return true;
  }

  // Never answered an RSVP himself (standing defaults and admin answers
  // don't count) — known once PersonStanding loads (admins only).
  needsOnboard(p) {
    return !!(p && window.PersonStanding && typeof PersonStanding.answered === 'function' && PersonStanding.answered(p.personId) === false);
  }

  // Never-answered box shaded by days since LA registration (owner 11/16:
  // "if withing 1 days of reg make them green. if 2 days make yellow. if 3
  // make orange 4 or more make red. that is shade of thier box").  No
  // registration date → unshaded.  The tint overlays the whole card.
  onboardShadeWrap(p, inner) {
    if (!this.needsOnboard(p) || !p.laRegisteredAt) return inner;
    const d = new Date(p.laRegisteredAt);
    if (isNaN(d)) return inner;
    const days = Math.max(0, Math.floor((Date.now() - d) / 86400000));
    const [line, fill] = days <= 1 ? ['#22c55e', 'rgba(34,197,94,0.22)']
      : days === 2 ? ['#eab308', 'rgba(234,179,8,0.24)']
      : days === 3 ? ['#f97316', 'rgba(249,115,22,0.24)']
      : ['#ef4444', 'rgba(239,68,68,0.24)'];
    return `<div style="position:relative; border:2px solid ${line}; border-radius:9px; padding:2px; margin-bottom:4px; background:${fill};">
        ${inner}<div style="position:absolute; inset:0; border-radius:7px; background:${fill}; pointer-events:none;"></div></div>`;
  }

  // Never-answered cards lead with when he registered and what we sent
  // (owner 2026-11-05: "show date they registered for needs onboard
  // players atleast so i know if i sent them anything or if they just
  // need to be dropped because they are ghost").  laRegisteredAt is on
  // every board row; p.welcome.lastSentAt is the 👋 welcome log.  Both
  // pills, every season (owner 2026-11-10: "put it on both … and it needs
  // to be on winter etc") — on every card of a man who never answered.
  onboardLeadHtml(p) {
    if (!this.needsOnboard(p)) return '';
    const esc = RosterScreenBase.escapeHtml;
    const copy = (tier, tokens) => (window.MessageCopy && MessageCopy.block('roster_sheet', tier, tokens)) || '';
    const fmt = (iso) => { const d = new Date(iso); return isNaN(d) ? '' : d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }); };
    const ago = (iso) => { const d = new Date(iso); return isNaN(d) ? '' : `${Math.max(0, Math.floor((Date.now() - d) / 86400000))}d ago`; };
    const reg = p.laRegisteredAt
      ? (copy('board_onboard_registered', { date: fmt(p.laRegisteredAt), ago: ago(p.laRegisteredAt) }) || `📝 Registered ${fmt(p.laRegisteredAt)} · ${ago(p.laRegisteredAt)}`)
      : (copy('board_onboard_reg_unknown') || '📝 Registration date unknown');
    const sent = p.welcome && p.welcome.lastSentAt
      ? (copy('board_onboard_welcomed', { date: fmt(p.welcome.lastSentAt), channel: p.welcome.lastChannel || '' })
         || `👋 Welcome sent ${fmt(p.welcome.lastSentAt)}`)
      : (copy('board_onboard_not_welcomed') || '👋 No welcome sent');
    return `<div style="font-size:0.68rem; font-weight:700; color:#f0abfc; padding:4px 6px 0;">${esc(reg)} · ${esc(sent)}</div>`;
  }

  // 💰 Paid line atop every team column (owner 2026-11-11: "show stats of
  // paid status for youth teams by age … do that for men etc too … same
  // with roster pill"): paid / owe $ / no LA for the players the column
  // shows, on both the Roster and Team pills.
  // Main list on top, everything else rolled up (owner 11/16: "would
  // prefer if active is at top and the other stuff is expandable but
  // rolled up by default").  Team pill: ACTIVE on top; Roster pill: ON
  // ROSTER on top.  The fold holds the dues line, the board's own extras
  // (STATUS tallies, docs row) and every other section.
  renderColumnSections(col, shown, renderList, data, ridersHtml = '', extras = '') {
    const { top, rest, n } = this._renderColumnSectionsInner(col, shown, renderList, data, ridersHtml);
    if (!col || !col.teamId) return top + rest;
    const folded = this.paidStatsHtml(shown) + (extras || '') + rest;
    return top + (folded.trim() ? this.foldHtml(col, folded, n) : '');
  }

  // A column's "▸ More" fold — closed by default; one opened stays open
  // across re-renders this page visit (per pill + team).
  foldHtml(col, inner, n) {
    const key = `${this.boardView}:${col.teamId}`;
    const open = RosterScreenBase.OPEN_FOLDS.has(key);
    const label = (window.MessageCopy && MessageCopy.block('roster_sheet', 'board_more_fold', { n })) || `▸ More · ${n}`;
    return `<details class="rs-col-fold" data-fold-key="${RosterScreenBase.escapeHtml(key)}" ${open ? 'open' : ''}
        ontoggle="RosterScreenBase.noteFold(this)" style="margin-top:10px;">
        <summary style="cursor:pointer; list-style:none; font-size:0.74rem; font-weight:800; color:#94a3b8;
          padding:5px 8px; border:1px dashed #475569; border-radius:6px;">${RosterScreenBase.escapeHtml(label)}</summary>
        <div style="margin-top:6px;">${inner}</div>
      </details>`;
  }

  static get OPEN_FOLDS() { return RosterScreenBase._openFolds || (RosterScreenBase._openFolds = new Set()); }
  static noteFold(el) {
    const key = el && el.dataset && el.dataset.foldKey;
    if (!key) return;
    if (el.open) RosterScreenBase.OPEN_FOLDS.add(key); else RosterScreenBase.OPEN_FOLDS.delete(key);
  }

  // 'paid' (nothing owed) · 'owes' · 'none' (no LA registration / no billing data).
  static paidState(p) {
    if (!p || p.noActiveLaRegistration || p.outstandingBalance == null || p.outstandingBalance === '') return 'none';
    return Number(p.outstandingBalance) > 0 ? 'owes' : 'paid';
  }

  paidStatsHtml(players) {
    const list = players || [];
    if (!list.length) return '';
    const esc = RosterScreenBase.escapeHtml;
    const copy = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.block('roster_sheet', tier, tokens)) || fb;
    let paid = 0, owes = 0, none = 0, usd = 0;
    list.forEach((p) => {
      const st = RosterScreenBase.paidState(p);
      if (st === 'paid') paid++;
      else if (st === 'owes') { owes++; usd += Number(p.outstandingBalance) || 0; }
      else none++;
    });
    const money = `$${Math.round(usd).toLocaleString('en-US')}`;
    const pct = Math.round((paid / list.length) * 100);
    const bit = (txt, color) => `<span style="color:${color}; white-space:nowrap;">${esc(txt)}</span>`;
    return `<div class="rs-paid-stats" title="${esc(copy('board_paid_tip', {}, 'Dues from LeagueApps for the players this column shows'))}"
        style="display:flex; flex-wrap:wrap; gap:4px 10px; align-items:center; font-size:0.74rem; font-weight:800;
               padding:4px 8px; margin:0 0 6px; border-radius:6px; background:rgba(148,163,184,0.10); border:1px solid #334155;">
        ${bit(copy('board_paid_ok', { n: paid, pct }, `✅ ${paid} paid (${pct}%)`), '#86efac')}
        ${owes ? bit(copy('board_paid_owe', { n: owes, usd: money }, `🔴 ${owes} owe ${money}`), '#fca5a5') : ''}
        ${none ? bit(copy('board_paid_none', { n: none }, `⚪ ${none} no LA`), '#94a3b8') : ''}
      </div>`;
  }

  _renderColumnSectionsInner(col, shown, renderList, data, ridersHtml = '') {
    if (!col || !col.teamId) return { top: renderList(shown) + ridersHtml, rest: '', n: 0 };
    const esc = RosterScreenBase.escapeHtml;
    const copy = (tier, tokens) => (window.MessageCopy && MessageCopy.block('roster_sheet', tier, tokens)) || '';
    const bucket = (data && data.buckets && data.buckets[String(col.teamId)]) || shown;
    const sectionOf = (p) => {
      const st = p && RosterScreenBase.rosterStatusByCode(p.rosterStatus);
      return (st && st.boardSection) || null;
    };
    const laneFlag = {
      drop:         [copy('board_planned_drop_chip') || '⬇ DROPPING', '#f97316', '#fdba74'],
      pending_drop: [copy('board_pending_drop_chip') || '⏳ PENDING DROP', '#dc2626', '#fca5a5'],
    };
    // Roster pill: he's on this list but also on a team here whose list
    // doesn't have him, a gap the left column can't show because he is on
    // a roster.  Skipped when he's already headed there, it's only a
    // call-in or paper row, or a league rule bars him from that list.
    const listGapChips = (p) => {
      if (!this.onLeagueList(col.teamId, p.personId)) return '';
      return this.listGapTeams(p.personId, data, col.teamId)
        .map(c => { const team = RosterScreenBase.dropClubName(String(c.shortLabel || c.label || '').replace(/^[^\p{L}\p{N}]+/u, '').trim());
          return `<span style="font-size:0.6rem; font-weight:800; line-height:1.3; padding:0 5px; border-radius:3px; white-space:nowrap;
                 background:rgba(245,158,11,0.16); border:1px solid #f59e0b; color:#fcd34d;">${esc(copy('board_also_on_team', { team }) || `⚠ also on ${team} team, not its list`)}</span>`; })
        .join('');
    };
    const card = (p, extraChip = '') => {
      const rank = bucket.indexOf(p) + 1;
      // Team pill 📋 chips folded into the card's 📋 ROSTERS line (mig 1435).
      const chips = (this.boardView === 'team' ? '' : listGapChips(p)) + extraChip;
      const html = this.renderPlayer(chips ? { ...p, nameChipHtml: (p.nameChipHtml || '') + chips } : p,
        data.columns, col, rank, bucket.length);
      const flag = this.boardView === 'roster' && !this.rosterFrozen(col.teamId) && laneFlag[sectionOf(p)];
      const lead = this.onboardLeadHtml(p);
      const body = this.onboardShadeWrap(p, lead + html);
      return flag
        ? `<div style="border:2px solid ${flag[1]}; border-radius:9px; padding:2px;">
             <div style="font-size:0.62rem; font-weight:900; letter-spacing:0.05em; color:${flag[2]}; padding:0 4px 2px;">${esc(flag[0])}</div>${body}</div>`
        : body;
    };
    const ordered = (list) => {
      const keep = new Set(list);
      return this.orderColumnPlayers(bucket, col).map(r => r.player).filter(p => keep.has(p));
    };
    // Section banner (owner 2026-10-27: "make the divider section more
    // clear") — a solid tinted bar with a left rule and a count badge, and
    // a gap above it so sections never run together.
    let firstHead = true;
    const head = (label, n, color, bg, extra = '') => {
      const top = firstHead ? '2px' : '14px';
      firstHead = false;
      return `<div style="display:flex; justify-content:space-between; align-items:center; gap:6px;
        font-size:0.8rem; font-weight:900; letter-spacing:0.06em; color:${color};
        background:${bg}; border:1px solid ${color}; border-left:5px solid ${color}; border-radius:4px;
        padding:5px 8px; margin:${top} 0 4px;">
        <span>${esc(label)}${extra ? `<span style="font-size:0.68rem; font-weight:800; color:#fdba74; margin-left:8px;">${esc(extra)}</span>` : ''}</span>
        <span style="background:${color}; color:#0f172a; border-radius:10px; padding:0 8px; font-size:0.78rem;">${n}</span></div>`;
    };
    // Spot number (owner 11/17 "we should number team and rosters spots
    // … diff then their actual number"): 1, 2, 3 down ACTIVE / ON ROSTER in
    // the order shown — a count to the cap, not the # shirt on the card.
    const spot = (i, html) => `<div style="display:flex; gap:4px; align-items:center;">
        <span class="rs-spot" title="Spot ${i}" style="flex:0 0 auto; min-width:1.5em; text-align:right; font-size:0.7rem; font-weight:800; color:#64748b;">${i}</span>
        <div style="flex:1 1 auto; min-width:0;">${html}</div></div>`;
    const spots = (htmls) => htmls.map((h, i) => spot(i + 1, h)).join('');
    const subHead = (label, n) => `<div style="font-size:0.68rem; font-weight:800; color:#cbd5e1; padding:4px 4px 0;">${esc(label)} · ${n}</div>`;
    const section = (label, list, color, bg, always = false) => (list.length || always)
      ? head(label, list.length, color, bg) + (list.length ? ordered(list).map(p => card(p)).join('') : '<div style="opacity:0.5; font-size:0.8rem;">(none)</div>')
      : '';
    // ⭐ CALL-DOWNS group retired (mig 1450, owner 11/17 "isn't the pill
    // enough"): a call-down is the L1 ⬇ pill in the card's 👁 SEES.
    const ridersCount = 0, riders = '';
    const GREEN = ['#22c55e', 'rgba(34,197,94,0.14)'];
    const AMBER = ['#f59e0b', 'rgba(245,158,11,0.14)'];
    const BLUE  = ['#60a5fa', 'rgba(96,165,250,0.14)'];
    const ROSE  = ['#fb7185', 'rgba(251,113,133,0.14)'];
    const GREY  = ['#94a3b8', 'rgba(148,163,184,0.14)'];
    const RED    = ['#ef4444', 'rgba(239,68,68,0.14)'];

    if (this.boardView === 'team') {
      // Every group shows, empty or not (owner 11/4: "can we not make
      // groups disappear. i would rather show them empty") — unless the
      // column's category pill or 👀 Sees games filter hides it.
      const shows = (cat) => this.columnCategoryShown(col, cat, data);
      const group = (label, list, cat, color, bg) => section(label, list, color, bg, shows(cat));
      const ridersGroup = '';
      // ⛔ not_eligible (mig 1523): set by the official-roster sync, own group.
      const cats = { onboard: [], active: [], injured: [], practice_squad: [], not_eligible: [], standby: [], inactive: [] };
      // NEEDS ONBOARD (owner 2026-11-03): never answered an RSVP himself
      // (standing defaults and admin answers don't count) and not 💤
      // Inactive or 🩹 Injured — he leaves the moment he answers once.
      // Known from PersonStanding (admins); anyone else sees no section.
      for (const p of shown) {
        const cat = this.columnCategoryOf(p);
        // Every man who never answered, whatever his spot (owner 11/3: "any
        // player with no rsvp ever needs to be in needs onboard") — only
        // 💤 Inactive and 🩹 Injured keep their own group.
        const key = cat !== 'injured' && cat !== 'inactive' && cat !== 'not_eligible' && this.needsOnboard(p) ? 'onboard' : cat;
        (cats[key] || cats.active).push(p);
      }
      // ACTIVE = who plays.  Men the Roster pill has in an add lane
      // (Needs Add → … → No Room, roster_statuses.board_section) sit in
      // their own 🟢 NEEDS ADD group under it, one sub-group per step —
      // a mirror of the Roster pill (owner 11/4: "cleaner like with the
      // 'needs ad' from roster mirror … I don't want a wants in section").
      // They keep their RSVPs; the 🌐 pull moves them to On Roster.  The
      // old ⚠ WANTS IN split (mig 1010) is gone; a man off the column's
      // league list keeps a small chip on his card.
      const listName = (c) => RosterScreenBase.dropClubName(String(c.shortLabel || c.label || '').replace(/^[^\p{L}\p{N}]+/u, '').trim());
      // Team pill = who plays, not paperwork (owner 11/3: "active players
      // whether main or reserves should be treated same"): a column's
      // lists are its own plus every folded team's (APSL Active + Reserve),
      // and either one counts as on the list.
      const familyIds = (c) => {
        const top = c.teamPillFoldInto ? Number(c.teamPillFoldInto) : Number(c.teamId);
        return [top, ...(data.columns || []).filter(x => Number(x.teamPillFoldInto) === top).map(x => Number(x.teamId))];
      };
      const familyCol = (data.columns || []).find(x => Number(x.teamId) === familyIds(col)[0]) || col;   // name the family (APSL)
      const hasList = familyIds(col).some(tid => this.leagueListFor(tid));
      const offList = (p) => hasList && !familyIds(col).some(tid => this.onLeagueList(tid, p.personId));
      const offChip = `<span style="font-size:0.6rem; font-weight:800; line-height:1.3; padding:0 5px; border-radius:3px; white-space:nowrap;
          background:rgba(245,158,11,0.16); border:1px solid #f59e0b; color:#fcd34d;">${esc(copy('board_wants_in_chip', { list: listName(familyCol) }) || `⚠ not on ${listName(familyCol)} list`)}</span>`;
      const addSteps = ['proposed', 'pending_add', 'no_room'];
      // No ⬇ NEEDS DROP group (owner 11/17 "take away needs drops from
      // all"; mig 1437 took the drop statuses out).
      const adding = cats.active.filter(p => addSteps.includes(sectionOf(p)));
      const playing = cats.active.filter(p => !addSteps.includes(sectionOf(p)));
      const mirrorGroup = (list, steps, label, colors) => (list.length || shows('active'))
        ? head(label, list.length, ...colors)
          + RosterScreenBase.ROSTER_STATUSES.filter(st => steps.includes(st.boardSection)).map(st => {
            const sub = list.filter(p => p.rosterStatus === st.code);
            return sub.length ? subHead(st.displayName || st.code, sub.length) + ordered(sub).map(p => card(p)).join('') : '';
          }).join('')
          + (list.length ? '' : '<div style="opacity:0.5; font-size:0.8rem;">(none)</div>')
        : '';
      const activeHtml = head(copy('board_plays_h') || 'ACTIVE', playing.length, ...GREEN)
        + (playing.length ? spots(ordered(playing).map(p => card(p, offList(p) ? offChip : undefined))) : '<div style="opacity:0.5; font-size:0.8rem;">(none)</div>');
      const mirrorsHtml = mirrorGroup(adding, addSteps, copy('board_team_needs_add_h') || copy('board_needs_add_h') || '🟢 NEEDS ADD', BLUE);
      // ⭐ CALL-UP POOL is gone until the owner names who is in it (11/3:
      // "take all out of call up pool until i tell you who to put in
      // there … its obvious who is in pool if they are on APSL official
      // or reserve official (shown with label on their card)").  A folded
      // team's men show in whatever other column has them, with 📋 chips.
      // ACTIVE first (owner 11/4: "ACTIVE SHOULD BE top").  The 👀 Sees
      // every game count went 11/4 — each card's 👀⚽ chip says it.  (＋ from LA removed 11/4 —
      // every member is placed on a team; the card's team menu adds more.)
      // NEEDS ONBOARD: each card under its registered / welcomed line.
      const onboardGroup = shows('active')
        ? head(copy('board_needs_onboard_h') || 'NEEDS ONBOARD', cats.onboard.length, '#e879f9', 'rgba(232,121,249,0.14)')
          + (cats.onboard.length ? ordered(cats.onboard).map(p => card(p)).join('') : '<div style="opacity:0.5; font-size:0.8rem;">(none)</div>')
        : '';
      firstHead = true;   // the fold's first banner sits flush too
      // NEEDS ONBOARD sits right under ACTIVE, outside the ▸ fold (owner
      // 11/16: "need to see needs onboard players. they should go right
      // under active players").
      const rest = mirrorsHtml
        + ridersGroup
        + group(copy('board_not_eligible_h') || '⛔ NOT ON ROSTER', cats.not_eligible, 'not_eligible', '#f87171', 'rgba(248,113,113,0.14)')
        + group(copy('board_standby_h') || '🪑 RESERVES', cats.standby, 'standby', ...BLUE)
        + group(copy('board_practice_squad_h') || 'PRACTICE SQUAD', cats.practice_squad, 'practice_squad', ...BLUE)
        + group(copy('board_injured_h') || '🩹 INJURED', cats.injured, 'injured', ...ROSE)
        + group(copy('board_inactive_h') || '💤 INACTIVE', cats.inactive, 'inactive', ...GREY);
      const n = adding.length + ridersCount
        + cats.not_eligible.length + cats.standby.length + cats.practice_squad.length + cats.injured.length + cats.inactive.length;
      return { top: activeHtml + onboardGroup, rest, n };
    }

    const nameRow = (i, name, note, red = false) => `<div style="display:flex; gap:6px; align-items:baseline; font-size:0.8rem;
        padding:3px 6px; border-radius:4px; ${red ? 'background:rgba(239,68,68,0.16); border:1px solid #ef4444;' : 'background:rgba(34,197,94,0.06);'}">
        <span style="font-weight:700;">${esc(name)}</span>
        <span style="font-size:0.65rem; color:${red ? '#fca5a5' : '#f59e0b'}; font-weight:${red ? 800 : 400};">${esc(note)}</span></div>`;
    const nameOf = (p) => p.fullName || `${p.firstName || ''} ${p.lastName || ''}`.trim();
    const official = this.leagueListFor(col.teamId);
    // League eligibility rules (mig 820, owner 2026-10-29: "so we can fix it
    // before league gets on us") — roster_team_rules rows checked against
    // the league lists we mirror.  requires: only players on ONE OF those
    // teams' lists (Reserves ← Liga 1); excludes: never also on that list
    // (APSL ✕ Reserves, flagged on APSL's column).  A rule whose other list
    // is not mirrored is not checked.
    const rules = (data.rosterRules || {})[String(col.teamId)] || { requires: [], excludes: [] };
    const listIds = (tid) => { const l = this.leagueListFor(tid); return l ? new Set(l.personIds.filter(x => x != null).map(Number)) : null; };
    const teamLabel = (tid) => {
      const c = (data.columns || []).find(x => Number(x.teamId) === Number(tid));
      return c ? RosterScreenBase.dropClubName(String(c.label || c.shortLabel || '').replace(/^[^\p{L}\p{N}]+/u, '').trim()) : `Team ${tid}`;
    };
    const reqSets = rules.requires.map(listIds).filter(Boolean);
    const reqSet  = reqSets.length ? new Set(reqSets.flatMap(x => [...x])) : null;
    const reqNames = rules.requires.map(teamLabel).join(' / ');
    const exclSets = rules.excludes.map(tid => ({ tid, ids: listIds(tid) })).filter(x => x.ids);
    const ruleWhy = (pid) => {
      if (pid == null || pid === '') return '';
      const id = Number(pid);
      if (reqSet && !reqSet.has(id)) return copy('board_rule_requires', { teams: reqNames }) || `⚠ not on the ${reqNames} roster`;
      const ex = exclSets.find(x => x.ids.has(id));
      if (!ex) return '';
      const t = teamLabel(ex.tid);
      return copy('board_rule_excludes', { team: t }) || `⚠ also on the ${t} roster — can't be on both`;
    };
    const whyWrap = (why, html) => `<div style="border:2px solid #ef4444; border-radius:9px; padding:2px;">
        <div style="font-size:0.62rem; font-weight:900; letter-spacing:0.03em; color:#fca5a5; padding:0 4px 2px;">${esc(why)}</div>${html}</div>`;
    const ruleCard = (p) => { const why = ruleWhy(p.personId); return why ? whyWrap(why, card(p)) : card(p); };
    const inelRows = [];   // [{ n, html }] — list players breaking a rule
    const lanes = { drop: [], pending_drop: [] };   // [{ p, name, n, note }] — + their official #
    const addLane = (p, n) => { const l = lanes[sectionOf(p)]; if (l && !l.some(d => d.p === p)) l.push({ p, name: nameOf(p), n, note: '' }); };
    // No ✂ CUT block (owner 11/17 "take away the cut section too"): a
    // list man who left LeagueApps is just a row in ON ROSTER.
    const listRows = [];   // every OFFICIAL row {name, n} — the projected list's source
    let rows, officialCount, rest;
    if (official) {
      const byPerson = new Map(bucket.map(p => [Number(p.personId), p]));
      const used = new Set();
      // Cards follow the lit sort pill like every other section (owner
      // 11/17 "the sorts on teams do not work"); only 🌐 Official order
      // keeps the league list's own order.  Otherwise the matched cards
      // sort and the list names with no card here follow them.
      const cardHtml = new Map();   // player → card html, list order
      const rowHtml = official.names.map((n, i) => {
        const id = official.personIds[i];
        const p = id != null && byPerson.get(Number(id));
        listRows.push({ name: p && !used.has(p) ? nameOf(p) : n, n: i + 1 });
        if (p && !used.has(p)) {
          used.add(p);
          if (lanes[sectionOf(p)]) addLane(p, i + 1);
          const why = ruleWhy(id);
          if (why) { inelRows.push({ n: i + 1, html: whyWrap(why, card(p)) }); return ''; }
          const html = card(p);
          cardHtml.set(p, html);
          return { card: p, html };
        }
        const why = ruleWhy(id);
        if (why) { inelRows.push({ n: i + 1, html: nameRow(i, n, why, true) }); return ''; }
        return nameRow(i, n, id == null
          ? (copy('board_official_unmatched') || 'not in Football Home')
          : (copy('board_official_off_team') || 'not on this team in Football Home'));
      }).map(r => (typeof r === 'string' ? { card: null, html: r } : r));
      rows = this.sortOrder === 'official'
        ? spots((this._sortDesc ? [...rowHtml].reverse() : rowHtml).filter(r => r.html).map(r => r.html))
        : spots([...ordered([...cardHtml.keys()]).map(p => cardHtml.get(p)),
          ...rowHtml.filter(r => !r.card && r.html).map(r => r.html)]);
      officialCount = official.names.length;
      rest = shown.filter(p => !used.has(p));
    } else {
      const on = ordered(shown.filter(p => p && RosterScreenBase.countsAsOnRoster(p.rosterStatus)));
      on.forEach((p, i) => { addLane(p, i + 1); listRows.push({ name: nameOf(p), n: i + 1 }); });
      rows = on.length ? spots(on.map(p => card(p))) : '<div style="opacity:0.5; font-size:0.8rem;">(none)</div>';
      officialCount = on.length;
      rest = shown.filter(p => !(p && RosterScreenBase.countsAsOnRoster(p.rosterStatus)));
    }
    // PROJECTED (mig 809) = OFFICIAL − every drop lane +
    // both add lanes; over teams.max_roster turns it red.
    const outNums = new Set([...lanes.drop, ...lanes.pending_drop].map(d => d.n));
    const adds = rest.filter(p => (sectionOf(p) === 'proposed' || sectionOf(p) === 'pending_add') && !RosterScreenBase.HEALTH.people[p.personId]);
    const projected = officialCount - outNums.size + adds.length;
    const moves = outNums.size + adds.length > 0;
    const maxRoster = Number(col.maxRoster) || 0;
    const over = maxRoster > 0 ? projected - maxRoster : 0;
    // A frozen roster (mig 1006) makes no moves — no dropping / projected.
    const live = !this.rosterFrozen(col.teamId);
    const extra = [
      inelRows.length ? (copy('board_ineligible_banner', { n: inelRows.length }) || `${inelRows.length} ineligible`) : '',
      live && lanes.drop.length ? (copy('board_planned_drops', { n: lanes.drop.length }) || `${lanes.drop.length} dropping`) : '',
      live && lanes.pending_drop.length ? (copy('board_pending_drops', { n: lanes.pending_drop.length }) || `${lanes.pending_drop.length} pending drop`) : '',
      live && moves ? (copy('board_projected_banner', { n: projected }) || `→ ${projected} projected`) : '',
    ].filter(Boolean).join(' · ');
    const inelHtml = inelRows.length
      ? head(copy('board_ineligible_h') || '⚠ INELIGIBLE — league rule, fix before the league does', inelRows.length, ...RED)
        + inelRows.map(r => r.html).join('')
      : '';
    const officialHtml = head(copy('board_official_h') || 'ON ROSTER', officialCount, ...GREEN, extra) + rows + inelHtml;
    // NEEDS ADD — one sub-group per paperwork step, in pipeline order.
    const needsAddSection = () => {
      // NO ROOM (awaiting a roster spot) is an add waiting for space — its
      // own step at the foot (owner 2026-11-03), never in PROJECTED.
      const steps = ['proposed', 'pending_add', 'no_room'];
      // 🩹 Injured: no add while hurt (owner 11/3, Mars Milligan) — he
      // waits in NOT ON ROSTER and comes back here when the injury ends.
      // Only real add steps (owner 11/4: winter youth, all 🏋 Practice
      // Squad with no list, belong in NOT ON ROSTER — the Practice Squad →
      // No Room mirror of mig 1031 is gone).
      const stepOf = (p) => steps.includes(sectionOf(p)) ? p.rosterStatus : null;
      const list = rest.filter(p => stepOf(p) && !RosterScreenBase.HEALTH.people[p.personId]);
      // Shown empty too (owner 11/4: "we need the categories in cols for
      // rosters and teams even if empty").
      if (!list.length) return head(copy('board_needs_add_h') || 'NEEDS ADD', 0, ...BLUE) + '<div style="opacity:0.5; font-size:0.8rem;">(none)</div>';
      return head(copy('board_needs_add_h') || 'NEEDS ADD', list.length, ...BLUE)
        + RosterScreenBase.ROSTER_STATUSES.filter(st => steps.includes(st.boardSection)).map(st => {
          const sub = list.filter(p => stepOf(p) === st.code);
          return sub.length ? subHead(st.displayName || st.code, sub.length) + ordered(sub).map(ruleCard).join('') : '';
        }).join('');
    };
    // No NEEDS DROP section (owner 11/17 "take away needs drops from all",
    // mig 1437); ✂ CUT under ON ROSTER still flags list men who left LA.
    // PROJECTED ROSTER — the list once the moves land: OFFICIAL minus the
    // drop lanes (their # shown, so the league list is easy to cross off),
    // then the adds with their step.  Collapsed; only when there are moves.
    const stepName = (code) => { const st = RosterScreenBase.rosterStatusByCode(code); return (st && st.displayName) || code || ''; };
    const projectedSection = () => {
      if (!moves) return '';
      const colors = over > 0 ? RED : BLUE;
      const overNote = over > 0 ? (copy('board_projected_over', { n: over, max: maxRoster }) || `${over} over the ${maxRoster} max`) : '';
      const kept = listRows.filter(r => !outNums.has(r.n));
      const body = kept.map((r, i) => nameRow(i, r.name, '')).join('')
        + ordered(adds).map((p, i) => nameRow(kept.length + i, nameOf(p),
            copy('board_projected_add', { step: stepName(p.rosterStatus) }) || `+ ${stepName(p.rosterStatus)}`)).join('');
      return `<details><summary style="list-style:none; cursor:pointer;">${head(copy('board_projected_h') || 'PROJECTED ROSTER', projected, ...colors, overNote)}</summary>${body}</details>`;
    };
    // League only (owner 2026-11-02: "roster should just be roster
    // functions"); who plays or trains is the Team pill's job.  A roster
    // frozen this season (team_terms.roster_frozen, mig 1006 — youth in
    // fall) has no moves to make: ON ROSTER only.
    // NOT ON ROSTER (mig 1037): the board's members on no league roster
    // whose home is this column — shown empty too, frozen or not.
    // Men (a board with a not_on_roster_home column): one list per person
    // under that column.  Youth (no home column): per column — this team's
    // own kids not on its list and not on an add step shown in this same
    // column (a frozen column shows no add steps, so its Practice Squad
    // kids are listed here; owner 11/4: "we need all la members showing").
    const notOnRosterSection = () => {
      const NONE = '<div style="opacity:0.5; font-size:0.8rem;">(none)</div>';
      const hdr = (n) => head(copy('board_not_on_roster_h') || 'NOT ON ROSTER', n, '#f59e0b', 'rgba(245,158,11,0.14)');
      if ((data.columns || []).some(c => c.notOnRosterHome)) {
        const stack = this.membersOffRosters(data).notOnRoster.filter(e => e.homeCol && Number(e.homeCol.teamId) === Number(col.teamId));
        // Same lit sort pill as the cards above (was always first-name A–Z).
        const byP = new Map(stack.map(e => [e.p, e]));
        const list = this.orderColumnPlayers(stack.map(e => e.p), col).map(r => byP.get(r.player));
        return hdr(list.length) + (list.length ? list.map((e, i) => this.renderMemberStackCard(e, i, list.length, col, data)).join('') : NONE);
      }
      const frozen = this.rosterFrozen(col.teamId);
      const shownAsAdd = (p) => !frozen && !RosterScreenBase.HEALTH.people[p.personId]
        && ['proposed', 'pending_add', 'no_room'].includes(sectionOf(p));
      const list = bucket.filter(p => p && !this.onLeagueList(col.teamId, p.personId)
        && !RosterScreenBase.countsAsOnRoster(p.rosterStatus) && !shownAsAdd(p));
      return hdr(list.length) + (list.length ? ordered(list).map(p => card(p)).join('') : NONE);
    };
    firstHead = true;   // the fold's first banner sits flush too
    if (this.rosterFrozen(col.teamId)) return { top: officialHtml, rest: notOnRosterSection(), n: rest.length };
    return { top: officialHtml, rest: needsAddSection() + notOnRosterSection() + projectedSection(), n: rest.length };
  }

  // This team's league roster is frozen under the lit season pill
  // (team_terms.roster_frozen, mig 1006 — youth in fall): no add / drop lanes.
  rosterFrozen(teamId) {
    const t = this._term;
    return !!(t && t.term && ((t.frozen || {})[String(teamId)] || []).includes(t.term));
  }

  // Columns whose league list is missing a player who plays there (see
  // listGapChips).  A team with no list has nothing to be missing from.
  listGapTeams(personId, data, exceptTeamId) {
    const id = Number(personId);
    const rules = data.rosterRules || {};
    const barred = (a, b) => ((rules[String(a)] || {}).excludes || []).map(Number).includes(Number(b));
    return (data.columns || []).filter(c => {
      if (!c.teamId || Number(c.teamId) === Number(exceptTeamId)) return false;
      if (!this.leagueListFor(c.teamId) || this.onLeagueList(c.teamId, id)) return false;
      if (barred(c.teamId, exceptTeamId) || barred(exceptTeamId, c.teamId)) return false;
      const row = ((data.buckets || {})[String(c.teamId)] || []).find(p => Number(p.personId) === id);
      if (!row || row.inviteOnly === true) return false;
      const st = RosterScreenBase.rosterStatusByCode(row.rosterStatus);
      return !(st && ['proposed', 'pending_add', 'no_room'].includes(st.boardSection));
    });
  }

  // Members on no league list, once each, whatever teams they sit on: the
  // Roster pill's left column.  A team with no list goes by On Roster status.
  // Anyone headed onto a list is that team's NEEDS ADD instead.
  membersOffRosters(data) {
    const cols = (data.columns || []).filter(c => c.teamId);
    const people = new Map();
    const keyOf = (p) => p.personId != null ? `p${p.personId}` : `u${p.leagueAppsUserId}`;
    const entry = (p) => {
      const k = keyOf(p);
      if (!people.has(k)) people.set(k, { p, rows: [] });
      return people.get(k);
    };
    for (const p of (data.unassigned || [])) entry(p);
    for (const c of cols) {
      for (const p of ((data.buckets || {})[String(c.teamId)] || [])) entry(p).rows.push({ col: c, p });
    }
    const section = (p) => {
      const st = RosterScreenBase.rosterStatusByCode(p.rosterStatus);
      return (st && st.boardSection) || null;
    };
    const stacks = { onboard: [], notOnRoster: [], noRoom: [] };
    for (const e of people.values()) {
      const listed = cols.some(c => this.onLeagueList(c.teamId, e.p.personId));
      // Roster pill = league only (owner 2026-11-03): a NO ROOM add sits in
      // his team's NEEDS ADD; onboarding is the Team pill's; everyone else
      // left is simply NOT ON ROSTER.
      const hurt = !!RosterScreenBase.HEALTH.people[e.p.personId];   // 🩹 no add while injured
      const held = e.rows.some(r => (['proposed', 'pending_add', 'no_room'].includes(section(r.p))
            && !this.rosterFrozen(r.col.teamId) && !hurt)
        || (!this.leagueListFor(r.col.teamId) && RosterScreenBase.countsAsOnRoster(r.p.rosterStatus)));
      if (listed || held) continue;
      // Listed under a team (mig 1037): the board's not_on_roster_home
      // column (Men: Liga 1), else his own team (youth: his age group).
      // No team at all = the left column.
      const home = cols.find(c => c.notOnRosterHome);
      e.homeCol = home || (e.rows[0] && e.rows[0].col) || null;
      stacks.notOnRoster.push(e);
    }
    const name = (e) => e.p.fullName || `${e.p.firstName || ''} ${e.p.lastName || ''}`.trim();
    Object.values(stacks).forEach(list => list.sort((a, b) => name(a).localeCompare(name(b))));
    return stacks;
  }

  // One member card for a NOT ON ROSTER list: works on his first team.
  renderMemberStackCard(e, i, n, col, data) {
    const esc = RosterScreenBase.escapeHtml;
    const label = (c) => RosterScreenBase.dropClubName(String(c.shortLabel || c.label || '').replace(/^[^\p{L}\p{N}]+/u, '').trim());
    const tags = e.rows.map(r => {
      const st = RosterScreenBase.rosterStatusByCode(r.p.rosterStatus);
      const text = label(r.col) + (st && st.boardSection === 'no_room' ? `: ${st.displayName}` : '');
      return `<span style="font-size:0.6rem; font-weight:800; line-height:1.3; padding:0 5px; border-radius:3px; white-space:nowrap;
        background:rgba(96,165,250,0.16); border:1px solid #60a5fa; color:#bfdbfe;">${esc(text)}</span>`;
    }).join('');
    const home = e.rows[0];
    const p = home ? home.p : e.p;
    // The per-extra-team status dropdowns under the card went 11/4 (owner:
    // "what is purpose? get rid of it") — the card's own dropdown is enough.
    return this.onboardLeadHtml(p) + this.renderPlayer({ ...p, nameChipHtml: (p.nameChipHtml || '') + tags }, data.columns, home ? home.col : col, i + 1, n);
  }

  // The left column on the Roster pill (owner 2026-11-02): one team-free
  // list, stacked.  Each card works on his first team; further teams get
  // their own status dropdown under it so he can be picked for any of them.
  renderMemberStacks(col, data) {
    const esc = RosterScreenBase.escapeHtml;
    const copy = (tier) => (window.MessageCopy && MessageCopy.block('roster_sheet', tier)) || '';
    const stacks = this.membersOffRosters(data);
    const card = (e, i, n) => this.renderMemberStackCard(e, i, n, col, data);
    const stack = (title, list, color, bg) => `<div style="display:flex; justify-content:space-between; align-items:center; gap:6px; font-size:0.8rem; font-weight:900;
           letter-spacing:0.06em; color:${color}; background:${bg}; border:1px solid ${color}; border-left:5px solid ${color};
           border-radius:4px; padding:5px 8px; margin:8px 0 4px;">
           <span>${esc(title)}</span>
           <span style="background:${color}; color:#0f172a; border-radius:10px; padding:0 8px; font-size:0.78rem;">${list.length}</span></div>`
        + (list.length ? list.map((e, i) => card(e, i, list.length)).join('') : '<div style="opacity:0.5; font-size:0.8rem;">(none)</div>');
    // One stack, shown empty too (owner 11/4).  Onboarding is the Team
    // pill's and No Room is each team's NEEDS ADD step (owner 11/3).
    // Only members with no team are left here; the rest sit under their
    // team column's NOT ON ROSTER (mig 1037).
    const body = stack(copy('board_not_on_roster_h') || 'NOT ON ROSTER', stacks.notOnRoster.filter(e => !e.homeCol), '#f59e0b', 'rgba(245,158,11,0.14)');
    return `<div style="background:var(--bg-secondary); border-radius:var(--radius-md); padding:6px; border-top:3px solid #475569; min-width:${this.colBoxMinWidth()};">
        <div style="display:flex; flex-direction:column; gap:6px; min-height:8px;">${body || '<div style="opacity:0.5; font-size:0.85rem;">(empty)</div>'}</div>
      </div>`;
  }

  // The league's own list for a team column — {names, personIds} from the
  // 🌐 mirror, or null when the team has none (or an upload not yet read).
  leagueListFor(teamId) {
    const o = this._data && this._data.officialRosters && this._data.officialRosters[String(teamId)];
    return (o && (o.names || []).length) ? { names: o.names, personIds: o.personIds || [], cut: o.cut || [], dropAsked: o.dropAsked || [], fromFile: o.system === 'club_file' } : null;
  }

  // ── 🗂 Team cards atop the Team view (owner 11/19 "maybe 2 'game' cards
  // for apsl and liga 1 on same screen with boxes and important info in the
  // boxes" + "no diff between a reserve and a main its just whhat we want
  // them to see. we can just have the reserves pitch hidden by defualt").
  //   one card per top column (folded teams ride inside: APSL Reserves),
  //   the game card's look (blue, gold border, green pitch band, crest);
  //   ACTIVE = the chase list as boxes — name, then PersonStanding.boxLine
  //   (last RSVP / 👻, dues, CASA form) and 📋 when on this team's league
  //   list; a box is a tap → the ⋯ player sheet (⚽ Teams moves him).
  //   Under the pitch, name rows like the game card: 👋 Not chasing,
  //   🏋 Practice squad, 🩹 Injured, 💤 Inactive.  The folded team's men
  //   (on it, not on the top team) are a second pitch, closed by default.
  // Words: roster_sheet tc_* (mig 1521); the rows reuse the cards' own.
  renderTeamCards(data, cols) {
    this._tcCols = cols;
    const esc = RosterScreenBase.escapeHtml;
    const copy = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.block('roster_sheet', tier, tokens || {})) || fb;
    const ec = (tier, fb) => (window.MessageCopy && MessageCopy.block('event_center', tier)) || fb;
    const tops = (cols || []).filter(c => c && c.teamId && !c.isUnassigned && !c.teamPillFoldInto);
    if (!tops.length) return '';
    if (!this._sheetCards) this._sheetCards = new Map();
    this._wirePlayerSheet();
    if (!this._tcOpen) this._tcOpen = new Set();
    const bucket = (id) => (data.buckets && data.buckets[String(id)]) || [];
    const nameOf = (p) => `${p.firstName || ''} ${p.lastName || ''}`.trim() || p.fullName || '?';
    const byLast = (a, b) => String(a.lastName || '').localeCompare(String(b.lastName || '')) || String(a.firstName || '').localeCompare(String(b.firstName || ''));
    const groupOf = (p) => {
      const c = this.columnCategoryOf(p);
      // Never answered = 🪑 Reserves on every team, never 💤 Inactive (owner
      // 11/20 "there should be no inactive right? isn't it all reserves now
      // for all teams?").  Women opt out — all Regulars (owner 11/20 "women
      // have no liga 1 … all active" → "all regulars").
      return c === 'active' && this.needsOnboard(p) && this._neverAnsweredParks() ? 'standby'
        : (c in { active: 1, injured: 1, practice_squad: 1, standby: 1, inactive: 1 } ? c : 'active');
    };
    const ids = new Set();
    // Corner flags (owner 11/19 "a flag at top of card that is DOCS in red?
    // its obvois if liga 1 team its for CASA reg and apsl same. the minus -
    // for not on roster sould be ROSTER in red label instead in same basic
    // spot"): ROSTER = not on this team's official roster (server
    // notOnRoster); DOCS = no registration with this card's league
    // (PersonStanding.docsMissing — CASA on Liga 1, APSL on APSL/Reserves),
    // filled in once PersonStanding loads.
    const flagTag = (text, tip) => `<span style="font-size:10px; line-height:13px; padding:0 4px; border-radius:6px; background:#dc2626; color:#fff; font-weight:800; letter-spacing:0.5px;" title="${esc(tip)}">${esc(text)}</span>`;
    const docsTag = (pid, teamId) => {
      const m = window.PersonStanding && PersonStanding.docsMissing ? PersonStanding.docsMissing(pid, teamId) : null;
      return m ? flagTag(copy('tc_flag_docs', {}, 'DOCS') + (m.stale ? '⚠' : ''), m.tip) : '';
    };
    // Each group follows the lit sort pill like the columns do (owner 11/19
    // "wait we already have sort buttons"); 🤝 Committed = up to date →
    // RSVP → dues → both (migs 1551/1554).  It needs PersonStanding, so that order
    // is re-applied in place once it loads (no re-render).
    const rankOf = (pid) => RosterScreenBase.commitRank(pid);
    // Name colour = commitment (owner 11/19 "if a player has both make his
    // name green … missing one or the other … yellow. if missing both …
    // red"): RSVP (green) + dues; white until PersonStanding loads.
    const nameColor = (pid) => ['#86efac', '#fde047', '#fde047', '#fca5a5', '#fff'][rankOf(pid)] || '#fff';
    // The number badge in the same colour (owner 11/19 "so same with his
    // number"); gold until loaded.
    const numColor = (pid) => ['#86efac', '#fde047', '#fde047', '#fca5a5', '#f5d442'][rankOf(pid)] || '#f5d442';
    // 1, 2, 3 … in the order shown, per group (owner 11/19 "number the
    // plaeyrs"); re-run after the in-place 🤝 Committed re-sort.
    const numberBoxes = (root) => (root || this.element) && (root || this.element).querySelectorAll('[data-tc-pitch]').forEach(el => {
      let i = 0;
      [...el.children].forEach(c => { const n = c.querySelector(':scope > [data-tc-num]'); if (n) n.textContent = String(++i); });
    });
    const ordered = (list, col) => this.orderColumnPlayers(list, col).map(r => r.player);
    const tallyHtml = (pids) => {
      const n = [0, 0, 0, 0, 0];
      pids.forEach(pid => { n[rankOf(pid)] += 1; });
      if (n[4] === pids.length) return '';
      return esc(copy('tc_tally', { ok: n[0], rsvp: n[1], dues: n[2], both: n[3] },
        `✅ ${n[0]} · RSVP ${n[1]} · $ ${n[2]} · both ${n[3]}`));
    };
    const box = (p, col, listTeamIds, groupColor = null) => {
      const pid = Number(p.personId);
      ids.add(pid);
      const key = `tc:${pid}@${col.teamId}`;
      this._sheetCards.set(key, { player: p, col, teams: '', contact: '' });
      const words = nameOf(p).split(/\s+/);
      // Flag the problem only (owner 11/19 "i think we need flag that they
      // are not eligible and if not flagged then they are good"): no 📋 /
      // gold for On Roster — ⛔ Not On Roster is the flag (its band + tag).
      const flagged = p.notOnRoster === true;   // server: NOT fh_team_game_eligible (mig 1528)
      return `<div data-player-sheet="${esc(key)}" data-tc-pid="${pid}" data-sheet-tab="teams" title="${esc(copy('tc_box_tip', {}, 'Tap — player sheet (⚽ Teams to move)'))}"
          style="position:relative; flex:0 0 104px; min-width:0; box-sizing:border-box; display:flex; flex-direction:column; gap:2px; padding:4px 4px 5px; border-radius:8px;
                 border:2px solid ${groupColor || 'rgba(255,255,255,0.55)'}; background:rgba(0,20,60,0.55); cursor:pointer;">
          <span data-tc-num="${pid}" style="position:absolute; top:-8px; left:4px; font-size:10px; line-height:13px; padding:0 4px; border-radius:6px; background:${numColor(pid)}; color:#0f172a; font-weight:800;">@@TCNUM@@</span>
          <span style="position:absolute; top:-8px; right:4px; display:flex; gap:3px;">${(() => { const br = this.ruleBreaks(pid, data); return br.length ? flagTag(copy('tc_flag_illegal', {}, 'ILLEGAL'), br.map(b => b.why).join(' · ')) : ''; })()}${flagged ? flagTag(copy('tc_flag_roster', {}, 'ROSTER'), copy('tc_not_eligible_tip', {}, 'Not On Roster')) : ''}<span data-tc-docs="${pid}" data-tc-docs-team="${esc(col.teamId)}" style="display:contents;">${docsTag(pid, col.teamId)}</span></span>
          <div data-tc-name="${pid}" style="font-size:13px; font-weight:800; line-height:1.15; color:${nameColor(pid)}; text-shadow:0 1px 1px rgba(0,0,0,0.45);">
            <div style="white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">${esc(words[0] || '')}</div>
            <div style="white-space:nowrap; overflow:hidden; text-overflow:ellipsis; min-height:1.15em;">${esc(words.slice(1).join(' '))}</div>
          </div>
          ${p.ageGroup ? `<span data-tc-age="${pid}" title="${esc(copy('tc_age_tip', {}, 'Age group this season'))}" style="position:absolute; bottom:-8px; right:4px; font-size:10px; line-height:13px; padding:0 5px; border-radius:6px; font-weight:800; letter-spacing:0.02em;
               background:${p.gender === 'Female' ? '#db2777' : '#1e3a8a'}; color:${p.gender === 'Female' ? '#fce7f3' : '#dbeafe'}; border:1px solid rgba(255,255,255,0.55);">${esc(p.ageGroup)}</span>` : ''}
          <div data-tc-info="${pid}" data-tc-paid="${esc(p.lastPaidAt || '')}" data-tc-paid-amount="${esc(p.lastPaidAmount == null ? '' : p.lastPaidAmount)}" style="font-size:10px; font-weight:700; line-height:1.25;">${window.PersonStanding && PersonStanding.boxLine ? PersonStanding.boxLine(pid, { paidAt: p.lastPaidAt, paidAmount: p.lastPaidAmount }) : ''}</div>
        </div>`;
    };
    // ⭐ Starters / 🪑 Bench / 🔄 Reserve (owner 11/27 "for each team lets
    // list starter, bench, reserve … segment them as the first sort. then
    // within that sort by age"): the team's lineup roles (team_persons.
    // lineup_role_id) split the pitch first; the lit sort pill orders each
    // segment. A team with no roles set reads as one block, as before.
    // injured = 🩹 players WITH a lineup role (owner 11/27 "show him in
    // starters but in sep box as injured … so he keeps his status" · "add
    // him to starter total"): each role segment ends with its own 🩹 box and
    // its count includes them; role-less injured stay in the band below.
    const segmented = (players, col, listTeamIds, injured = []) => {
      const boxes = (list, start, color = null) => ordered(list, col).map((p, i) => box(p, col, listTeamIds, color)
        .replace('data-tc-pid=', `data-tc-alpha="${list.indexOf(p)}" data-tc-pid=`).replace('@@TCNUM@@', String(start + i + 1))).join('');
      if (!players.some(p => p.lineupRole) && !injured.length) return boxes(players, 0);
      const segs = [
        // Tiers (migs 4020/4021): T1 starter · T2 starter/sub · T3 sub · T4 depth;
        // 🔄 Reserve (Liga 1's APSL call-up pool) sits outside the tiers.
        ['starter',  copy('tc_seg_starter', {}, '⭐ T1 · Starters')],
        ['bench',    copy('tc_seg_bench', {}, '🔁 T2 · Starter/Sub')],
        ['sub_late', copy('tc_seg_sub_late', {}, '🪑 T3 · Subs')],
        ['reserve',  copy('tc_seg_reserve', {}, '🔄 Reserve')],
        ['',         copy('tc_seg_none', {}, '🧱 T4 · Depth')],
      ];
      let n = 0, out = '';
      for (const [code, label] of segs) {
        const list = players.filter(p => (p.lineupRole || '') === code);
        const hurt = injured.filter(p => (p.lineupRole || '') === code);
        if (!list.length && !hurt.length) continue;
        out += `<div data-tc-seg style="flex:0 0 100%; font-size:12px; letter-spacing:3px; font-weight:800; text-transform:uppercase; color:#f5d442; margin:${n ? '6px' : '0'} 0 -4px;">${esc(label)} (${list.length + hurt.length})</div>`;
        out += boxes(list, n);
        n += list.length;
        if (hurt.length) {
          out += `<div data-tc-seg-injured style="flex:0 0 100%; box-sizing:border-box; padding:6px 6px 10px; border-radius:8px; border:1px dashed #fda4af; background:rgba(0,0,0,0.18);">
              <div style="font-size:11px; letter-spacing:2px; font-weight:800; text-transform:uppercase; color:#fda4af; margin-bottom:10px;">${esc(ec('sec_injured', '🩹 Injured'))} (${hurt.length})</div>
              <div data-tc-pitch style="display:flex; flex-wrap:wrap; justify-content:center; gap:12px 6px;">${boxes(hurt, n, '#fda4af')}</div></div>`;
          n += hurt.length;
        }
      }
      return out;
    };
    const pitch = (players, col, listTeamIds, injured = []) => `<div style="margin:0 -18px; padding:12px 8px; box-sizing:border-box; background:#15803d;
          border-top:2px solid rgba(255,255,255,0.35); border-bottom:2px solid rgba(255,255,255,0.35);">
        <div data-tc-pitch style="display:flex; flex-wrap:wrap; justify-content:center; gap:12px 6px;">${segmented(players, col, listTeamIds, injured)
          || `<div style="opacity:0.7; font-size:13px;">${esc(copy('tc_empty', {}, 'Nobody here'))}</div>`}</div></div>`;
    // Every player is a box (owner 11/19 "on teams i need everything to be
    // a box all players"): the groups under the pitch are box bands too,
    // the group's colour as the box border.
    const band = (list, label, color, listTeamIds, tip = '') => list.length ? `<div style="margin-top:10px;"${tip ? ` title="${esc(tip)}"` : ''}>
        <div style="font-size:12px; letter-spacing:3px; color:${color}; font-weight:800; text-transform:uppercase; margin-bottom:2px;">${esc(label)} (${list.length})</div>
        <div data-tc-tally="${esc(list.map(p => p.personId).join(','))}" style="font-size:11px; font-weight:800; margin-bottom:6px; opacity:0.9;">${tallyHtml(list.map(p => p.personId))}</div>
        <div data-tc-pitch style="display:flex; flex-wrap:wrap; justify-content:center; gap:12px 6px; padding:10px 6px; border-radius:8px; background:rgba(0,0,0,0.22);">
          ${ordered(list, list[0] && list[0].__col).map((p, i) => box(p, p.__col, listTeamIds, color).replace('data-tc-pid=', `data-tc-alpha="${list.indexOf(p)}" data-tc-pid=`).replace('@@TCNUM@@', String(i + 1))).join('')}</div></div>` : '';
    // Everyone on this card's official lists breaking a league rule — from
    // the lists themselves, so a listed man who isn't on our board counts.
    const illegalBanner = (teamIds) => {
      const seen = new Set(), hits = [];
      for (const tid of teamIds) {
        const l = this.leagueListFor(tid);
        if (!l) continue;
        l.personIds.forEach((pid, i) => {
          if (pid == null || seen.has(Number(pid))) return;
          const br = this.ruleBreaks(pid, data).filter(b => teamIds.map(Number).includes(b.teamId));
          if (!br.length) return;
          seen.add(Number(pid));
          hits.push({ name: l.names[i] || '?', why: br.map(b => b.why).join(' · ') });
        });
      }
      if (!hits.length) return '';
      return `<div style="margin:0 0 8px; padding:6px 8px; border-radius:8px; background:#7f1d1d; border:2px solid #ef4444; text-align:left;">
          <div style="font-size:12px; font-weight:900; letter-spacing:1px; color:#fff;">${esc(copy('board_ineligible_h', {}, '⚠ INELIGIBLE — league rule, fix before the league does'))} (${hits.length})</div>
          ${hits.map(h => `<div style="font-size:12px; font-weight:700; color:#fecaca;">${esc(h.name)} — ${esc(h.why)}</div>`).join('')}</div>`;
    };
    const card = (col) => {
      const folded = (data.columns || []).filter(x => Number(x.teamPillFoldInto) === Number(col.teamId));
      const listTeamIds = [col.teamId, ...folded.map(x => x.teamId)];
      const mainIds = new Set(bucket(col.teamId).map(p => Number(p.personId)));
      const groups = { active: [], onboard: [], not_eligible: [], standby: [], practice_squad: [], injured: [], inactive: [] };
      for (const p of bucket(col.teamId)) (groups[groupOf(p)] || groups.active).push(Object.assign(p, { __col: col }));
      for (const f of folded) for (const p of bucket(f.teamId)) {
        if (mainIds.has(Number(p.personId))) continue;
        mainIds.add(Number(p.personId));
        // Nothing hidden, simple categories (owner 11/19 "nothing should be
        // hidden. they should just be reserves right? simple categories"):
        // the folded team's own men (APSL Reserves) are 🪑 Reserves here.
        const g = groupOf(p);
        (groups[g === 'active' ? 'standby' : g] || groups.standby).push(Object.assign(p, { __col: f }));
      }
      Object.values(groups).forEach(l => l.sort(byLast));
      // 🩹 with a lineup role keep their role on the pitch (own 🩹 box per
      // segment); only role-less injured stay in the 🩹 band below.
      const injuredRole = groups.injured.filter(p => p.lineupRole);
      groups.injured = groups.injured.filter(p => !p.lineupRole);
      const label = RosterScreenBase.dropClubName(String(col.shortLabel || col.label || ''));
      // Full width (owner 11/19 "use full screen for them so widen it out"):
      // two cards share the row on a wide screen, each takes it on a phone.
      // At most two per row (owner 11/27 "apsl left liga 1 right", then U23 / PR
      // below) — a 3rd card never squeezes up beside them on a wide desktop.
      return `<div style="flex:1 1 calc(50% - 7px); max-width:100%; min-width:min(520px, 100%); box-sizing:border-box; border:4px solid #f5d442;
                 background:linear-gradient(160deg, #0033a0 0%, #003fbf 30%, #0044cc 55%, #002080 100%);
                 color:#fff; text-align:center; padding:14px 18px 12px; overflow:hidden; box-shadow:0 10px 34px rgba(0,0,0,0.35);">
          <div style="display:flex; align-items:center; justify-content:center; gap:8px; margin-bottom:8px;">
            <img src="images/lighthouse-1893-crest.png" style="width:26px; height:26px; object-fit:contain;" alt="">
            <span style="font-size:14px; text-transform:uppercase; letter-spacing:4px; font-weight:800;">${esc(label)}</span>
            <span style="font-size:14px; font-weight:800; color:#f5d442;">${groups.active.length}</span>
          </div>
          ${illegalBanner(listTeamIds)}
          <div data-tc-tally="${esc(groups.active.map(p => p.personId).join(','))}" style="font-size:12px; font-weight:800; margin:-4px 0 8px; opacity:0.95;">${tallyHtml(groups.active.map(p => p.personId))}</div>
          ${pitch(groups.active, col, listTeamIds, injuredRole)}
          ${band(groups.standby, copy('board_standby_h', {}, '🪑 Reserves'), '#93c5fd', listTeamIds)}
          ${band(groups.practice_squad, copy('board_practice_squad_h', {}, '🏋 Practice squad'), '#93c5fd', listTeamIds)}
          ${band(groups.injured, ec('sec_injured', '🩹 Injured'), '#fda4af', listTeamIds)}
          ${band(groups.inactive, ec('sec_inactive', '💤 Inactive'), '#94a3b8', listTeamIds)}
        </div>`;
    };
    const html = `<div data-team-cards style="display:flex; flex-wrap:wrap; gap:14px; align-items:flex-start; width:100%; box-sizing:border-box; padding:0 var(--space-2); margin:0 0 var(--space-3);">${tops.map(card).join('')}</div>`;
    // Box lines arrive with PersonStanding (admins); the folds remember open.
    if (!this._tcWired && this.element) {
      this._tcWired = true;
      this.element.addEventListener('toggle', (e) => {
        const d = e.target && e.target.closest && e.target.closest('[data-tc-fold]');
        if (!d) return;
        const k = d.getAttribute('data-tc-fold');
        if (d.open) this._tcOpen.add(k); else this._tcOpen.delete(k);
      }, true);
    }
    if (window.PersonStanding && PersonStanding.load && ids.size) {
      PersonStanding.load(this.auth, [...ids]).then(() => {
        if (!this.element) return;
        this.element.querySelectorAll('[data-tc-info]').forEach(el => {
          el.innerHTML = PersonStanding.boxLine(el.getAttribute('data-tc-info'), { paidAt: el.getAttribute('data-tc-paid') || '', paidAmount: el.getAttribute('data-tc-paid-amount') || '' });
        });
        if (this.sortOrder === 'committed') this.element.querySelectorAll('[data-tc-pitch]').forEach(el => {
          // Same rule as orderColumnPlayers: flipped = best first, unknown
          // at the foot either way; A–Z (data-tc-alpha) within.
          const flip = this._sortDesc ? -1 : 1;
          // Re-sort inside each ⭐/🪑/🔄 segment (data-tc-seg headers) — never across.
          const runs = [[null, []]];
          [...el.children].forEach(c => {
            if (c.hasAttribute('data-tc-seg')) runs.push([c, []]);
            else if (c.hasAttribute('data-tc-pid')) runs[runs.length - 1][1].push(c);
          });
          for (const [, boxes] of runs) {
            if (!boxes.length) continue;
            const anchor = boxes[boxes.length - 1].nextSibling;
            boxes.map(c => ({ c, r: rankOf(c.getAttribute('data-tc-pid')), n: RosterScreenBase.commitPractices(c.getAttribute('data-tc-pid')), a: Number(c.getAttribute('data-tc-alpha')) || 0 }))
              .sort((x, y) => (x.r === 4) - (y.r === 4) || flip * (x.r - y.r) || flip * (y.n - x.n) || x.a - y.a)
              .forEach(x => el.insertBefore(x.c, anchor));
          }
        });
        numberBoxes();
        this.element.querySelectorAll('[data-tc-name]').forEach(el => { el.style.color = nameColor(el.getAttribute('data-tc-name')); });
        this.element.querySelectorAll('[data-tc-num]').forEach(el => { el.style.background = numColor(el.getAttribute('data-tc-num')); });
        this.element.querySelectorAll('[data-tc-tally]').forEach(el => {
          const pids = (el.getAttribute('data-tc-tally') || '').split(',').filter(Boolean);
          el.innerHTML = tallyHtml(pids);
        });
        this.element.querySelectorAll('[data-tc-docs]').forEach(el => {
          el.innerHTML = docsTag(el.getAttribute('data-tc-docs'), el.getAttribute('data-tc-docs-team'));
        });
        this.element.querySelectorAll('[data-tc-reg]').forEach(el => {
          el.innerHTML = PersonStanding.regMark ? PersonStanding.regMark(el.getAttribute('data-tc-reg')) : '';
        });
      }).catch(() => {});
    }
    return html;
  }

  // 🪑 Regulars / Reserves (mig 1530) — the men's board turns it on.
  _hasReserves() { return false; }

  // Team cards: does a never-answered regular drop to 🪑 Reserves / 💤
  // Inactive?  Men + youth yes (11/19); WomensRosterScreen says no.
  _neverAnsweredParks() { return true; }

  // League rule breaks between the official lists (roster_team_rules, mig
  // 820) for one person → [{ teamId, why }].  On team T's list and T
  // `requires` lists he is on none of, or T `excludes` a list he is also
  // on.  A rule whose other list isn't mirrored isn't checked.  The
  // Graphic team cards' ILLEGAL tag + banner (owner 11/19 "flag if a
  // player is on reserves official but not on liga 1 official as that is
  // illegal with league and if they saw it we would have to fix").
  ruleBreaks(personId, data) {
    if (personId == null || personId === '') return [];
    const id = Number(personId);
    const rules = (data && data.rosterRules) || {};
    const copy = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.block('roster_sheet', tier, tokens || {})) || fb;
    const label = (tid) => {
      const c = ((data && data.columns) || []).find(x => Number(x.teamId) === Number(tid));
      return c ? RosterScreenBase.dropClubName(String(c.label || c.shortLabel || '').replace(/^[^\p{L}\p{N}]+/u, '').trim()) : `Team ${tid}`;
    };
    const out = [];
    for (const [tid, r] of Object.entries(rules)) {
      if (!this.onLeagueList(tid, id)) continue;
      const req = (r.requires || []).filter(t => this.leagueListFor(t));
      if (req.length && !req.some(t => this.onLeagueList(t, id))) {
        const teams = req.map(label).join(' / ');
        out.push({ teamId: Number(tid), why: `${label(tid)}: ${copy('board_rule_requires', { teams }, `⚠ not on the ${teams} roster`)}` });
      }
      for (const t of (r.excludes || [])) {
        if (this.leagueListFor(t) && this.onLeagueList(t, id)) {
          out.push({ teamId: Number(tid), why: `${label(tid)}: ${copy('board_rule_excludes', { team: label(t) }, `⚠ also on the ${label(t)} roster — can't be on both`)}` });
        }
      }
    }
    return out;
  }

  // On the league's own list for this team.
  onLeagueList(teamId, personId) {
    const l = teamId && personId ? this.leagueListFor(teamId) : null;
    return !!(l && l.personIds.some(id => id != null && Number(id) === Number(personId)));
  }

  // On an ONLINE list → only the league takes him off.  A youth file list
  // flags, never locks (mig 868; fh_on_league_list is the server half).
  leagueListLocks(teamId, personId) {
    const l = teamId ? this.leagueListFor(teamId) : null;
    return !!(l && !l.fromFile && this.onLeagueList(teamId, personId));
  }

  // Subs can go negative (owner 2026-09-05: "11v11 with 11 on roster is
  // 0 but 10 on roster is -1 subs") — a short roster is exactly what the
  // coach needs to see, so it's shown in red rather than clamped.
  onRosterTallyHtml(n, fieldSize) {
    const subs = fieldSize > 0 ? n - fieldSize : null;
    const subsColor = subs < 0 ? '#ef4444' : '#cbd5e1';
    return `<span style="font-size:0.8rem; font-weight:800; color:#22c55e;">✓ ${n} on roster</span>`
      + (fieldSize > 0
          ? `<span style="font-size:0.72rem; font-weight:700; color:${subsColor};">${fieldSize}v${fieldSize} · ${subs} sub${Math.abs(subs) === 1 ? '' : 's'}</span>`
          : '');
  }

  refreshOnRosterTally(teamId) {
    if (!this.element || !teamId) return;
    const tally = this.element.querySelector(`[data-on-roster-tally="${teamId}"]`);
    if (!tally) return;
    const selects = this._cardStatusSelects(teamId);
    const n = Array.from(selects).filter(s => RosterScreenBase.countsAsOnRoster(s.value)).length;
    tally.innerHTML = this.onRosterTallyHtml(n, Number(tally.dataset.fieldSize) || 0);
  }

  // ── Per-status tallies (owner 2026-09-10: "show above each team the
  // tallies of the diff roster statuses") ──────────────────────────────
  //
  // One chip per roster status the column's players actually carry,
  // painted in that status's own colours (same palette as the card
  // dropdown) and ordered by the league's pipeline (sort_order), plus a
  // neutral "N No status" chip for players with no status yet. Zero
  // counts are not shown — the strip is a snapshot of where the roster
  // sits, not the full pipeline (the dropdown already lists that).
  // Unassigned has no team_persons rows, so no strip there. Carries
  // data-status-tallies (+ data-league-id for ordering) so
  // refreshRosterStatusTallies() can repaint it live after a dropdown
  // change, exactly like the "✓ N on roster" tally.
  // Coaches on the team with a roster status and role (mig 560, owner
  // 2026-10-09: "add coaches to the teams on fh. that are 'on roster'
  // 'not on roster' etc").  Drawn under the status tallies from
  // /api/team-coaches/:teamId, fetched once per team per page; the ⋯
  // popover on a coach holds the same status list the players use plus
  // the role (head / assistant).  The league roster sheet (Game Center
  // 🖨 Roster sheet) prints the coaches whose status counts as on roster.
  renderCoachesStrip(col) {
    if (!col || !col.teamId) return '';
    this.bindCoachesToggle();
    const teamId = Number(col.teamId);
    if (!this._coaches) this._coaches = new Map();
    if (!this._coaches.has(teamId)) { this._coaches.set(teamId, null); this._loadCoaches(teamId); }
    return `<div data-coaches-strip="${teamId}" style="margin:0 0 6px;">${this.coachesStripHtml(col, this._coaches.get(teamId))}</div>`;
  }
  async _loadCoaches(teamId) {
    try {
      const res = await this.auth.fetch(`/api/team-coaches/${teamId}`);
      const body = await res.json();
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this._coaches.set(teamId, body);
    } catch (err) { console.warn('[roster] coaches load failed:', err); this._coaches.set(teamId, { coaches: [], roles: [] }); }
    const strip = this.element && this.element.querySelector(`[data-coaches-strip="${teamId}"]`);
    const col = (this.columns || []).find(c => Number(c.teamId) === teamId) || { teamId };
    if (strip) strip.innerHTML = this.coachesStripHtml(col, this._coaches.get(teamId));
  }
  coachesStripHtml(col, data) {
    const esc = RosterScreenBase.escapeHtml;
    const copy = (tier) => (window.MessageCopy && MessageCopy.block('roster_sheet', tier)) || '';
    if (!data) return `<span style="font-size:0.62rem; opacity:0.5;">${esc(copy('coaches_h') || 'COACHES')} …</span>`;
    const coaches = data.coaches || [];
    if (!coaches.length) return '';
    const canEdit = this._canEditCoachesFor(col);
    const statuses = RosterScreenBase.rosterStatusesForColumn(col);
    const roles = data.roles || [];
    const rows = coaches.map(c => {
      const st = c.status || '';
      const chip = `<span style="font-size:0.58rem; font-weight:800; line-height:1.3; padding:0 4px; border-radius:3px; white-space:nowrap; ${this.rosterStatusStyle(st)}">${esc(st ? (c.status_label || st) : (copy('coach_no_status') || 'Not on roster'))}</span>`;
      const role = c.role_label && c.role ? `<span style="opacity:0.6;">· ${esc(c.role_label)}</span>` : '';
      const menu = canEdit ? `
        <details class="roster-move-details" style="position:relative; display:inline-flex;">
          <summary style="list-style:none; cursor:pointer; padding:0 5px; font-size:0.7rem; font-weight:800; border-radius:3px; background:#0f172a; border:1px solid var(--border-color);">⋯</summary>
          <div style="position:absolute; top:100%; left:0; z-index:30; margin-top:2px; display:flex; flex-direction:column; gap:4px; background:#0f172a; padding:5px; border-radius:6px; border:1px solid var(--border-color); min-width:170px;">
            <select data-coach-status data-team-id="${col.teamId}" data-person-id="${c.person_id}" style="font-size:0.7rem; padding:3px; ${this.rosterStatusStyle(st)}">
              <option value="" ${st ? '' : 'selected'}>${esc(copy('coach_no_status') || 'Not on roster')}</option>
              ${statuses.map(x => `<option value="${esc(x.code)}" ${x.code === st ? 'selected' : ''}>${esc(x.displayName || x.code)}</option>`).join('')}
              ${st && !statuses.some(x => x.code === st) ? `<option value="${esc(st)}" selected>${esc(c.status_label || st)}</option>` : ''}
            </select>
            <select data-coach-role data-team-id="${col.teamId}" data-person-id="${c.person_id}" style="font-size:0.7rem; padding:3px;">
              <option value="" ${c.role ? '' : 'selected'}>Role…</option>
              ${roles.map(r => `<option value="${esc(r.name)}" ${r.name === c.role ? 'selected' : ''}>${esc(r.label || r.name)}</option>`).join('')}
            </select>
          </div>
        </details>` : '';
      return `<div style="display:flex; align-items:center; gap:5px; flex-wrap:wrap; font-size:0.68rem; padding:1px 0;">
        <span style="font-weight:700;">${esc(c.first_name)} ${esc(c.last_name)}</span>${role}${chip}${menu}</div>`;
    }).join('');
    return `<details data-coaches-toggle ${RosterScreenBase.coachesMinimized() ? '' : 'open'}>
      <summary style="cursor:pointer; font-size:0.62rem; font-weight:700; letter-spacing:0.03em; opacity:0.7;">${esc(copy('coaches_h') || 'COACHES')} (${coaches.length})</summary>
      ${rows}</details>`;
  }
  // Minimized on one column = minimized on all, remembered per browser
  // (owner 2026-10-30: "they should able to be minimized").
  static coachesMinimized() {
    try { return localStorage.getItem('roster.coachesMin') === '1'; } catch (e) { return false; }
  }
  bindCoachesToggle() {
    if (!this.element || this._coachesToggleBound === this.element) return;
    this._coachesToggleBound = this.element;
    // toggle does not bubble, so capture it.
    this.element.addEventListener('toggle', (e) => {
      if (!e.target.matches || !e.target.matches('[data-coaches-toggle]')) return;
      const open = e.target.open;
      try { localStorage.setItem('roster.coachesMin', open ? '0' : '1'); } catch (err) { /* private window */ }
      this.element.querySelectorAll('[data-coaches-toggle]').forEach(d => { d.open = open; });
    }, true);
  }
  // Who may set a coach's status / role: a club admin, or a coach of that team.
  _canEditCoachesFor(col) {
    const ctx = (this.navigation && this.navigation.context) || {};
    if (ctx.role === 'club-admin') return true;
    const ids = Array.isArray(ctx.coachedTeamIds) ? ctx.coachedTeamIds.map(Number) : [];
    return ids.includes(Number(col && col.teamId));
  }
  async onCoachSelectChange(select) {
    const teamId = Number(select.dataset.teamId), personId = Number(select.dataset.personId);
    if (!teamId || !personId) return;
    const payload = select.hasAttribute('data-coach-status') ? { rosterStatus: select.value || null } : { coachRole: select.value || null };
    select.disabled = true;
    try {
      const res = await this.auth.fetch(`/api/team-coaches/${teamId}/${personId}`, { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      const cur = this._coaches.get(teamId) || {}; cur.coaches = body.coaches || []; this._coaches.set(teamId, cur);
    } catch (err) { alert(`Could not save: ${err.message}`); }
    const strip = this.element && this.element.querySelector(`[data-coaches-strip="${teamId}"]`);
    const col = (this.columns || []).find(c => Number(c.teamId) === teamId) || { teamId };
    if (strip) strip.innerHTML = this.coachesStripHtml(col, this._coaches.get(teamId));
  }

  renderRosterStatusTallies(col, players) {
    if (!col || !col.teamId) return '';
    const codes = (players || []).map(p => (p && p.rosterStatus) || '');
    if (!codes.length) return '';
    return `<div data-status-tallies="${col.teamId}" data-league-id="${Number(col.leagueId) || 0}"
                 style="display:flex; align-items:center; gap:4px; flex-wrap:wrap; margin:0 0 6px;">
              ${this.rosterStatusTalliesHtml(col, codes)}
            </div>`;
  }

  rosterStatusTalliesHtml(col, codes) {
    const esc = RosterScreenBase.escapeHtml;
    const counts = new Map();
    for (const c of codes) counts.set(c, (counts.get(c) || 0) + 1);
    if (!counts.size) return '';
    // League order first, then anything a player carries that this
    // league doesn't list (same "nothing vanishes" rule as the dropdown),
    // blank last.
    const ordered = RosterScreenBase.rosterStatusesForColumn(col).map(s => s.code);
    for (const c of counts.keys()) if (c && !ordered.includes(c)) ordered.push(c);
    ordered.push('');
    const chips = ordered.map(code => {
      const n = counts.get(code) || 0;
      if (!n) return '';
      const s = RosterScreenBase.rosterStatusByCode(code);
      const label = code ? ((s && s.displayName) || code) : 'No status';
      const c = RosterScreenBase.rosterStatusColors(code);
      const tip = `${n} ${label}${s && s.description ? ' — ' + s.description : ''}`;
      return `<span title="${esc(tip)}"
                    style="display:inline-flex; align-items:center; gap:3px; font-size:0.62rem; font-weight:800; letter-spacing:0.01em; padding:0 5px; line-height:1.5; border-radius:3px; white-space:nowrap; background:${c.bg}; color:${c.fg}; border:1px solid ${c.border};">
                <span style="font-size:0.72rem;">${n}</span>${esc(label)}
              </span>`;
    }).join('');
    return `<span style="font-size:0.62rem; font-weight:700; letter-spacing:0.03em; opacity:0.7;">STATUS</span>${chips}`;
  }

  refreshRosterStatusTallies(teamId) {
    if (!this.element || !teamId) return;
    const strip = this.element.querySelector(`[data-status-tallies="${teamId}"]`);
    if (!strip) return;
    const selects = this._cardStatusSelects(teamId);
    const codes = Array.from(selects).map(s => s.value || '');
    strip.innerHTML = this.rosterStatusTalliesHtml({ teamId, leagueId: Number(strip.dataset.leagueId) || 0 }, codes);
  }

  renderStatusSelect(player, col, canMove, { withHealth = true } = {}) {
    if (!(canMove && col && col.teamId && player.personId)) return '';
    const esc     = RosterScreenBase.escapeHtml;
    const current = player.rosterStatus || '';
    const options = RosterScreenBase.rosterStatusesForColumn(col);
    // A status the player already carries that this league does not list
    // (set before the league scoping, or the team changed leagues) stays
    // in the dropdown so nothing vanishes silently — the coach sees it
    // and can move him off it.
    if (current && !options.some(s => s.code === current)) {
      options.push(RosterScreenBase.rosterStatusByCode(current)
        || { code: current, displayName: current, description: '' });
    }
    const title = col.leagueName
      ? `Official league roster status — ${col.leagueName} pipeline`
      : 'Official league roster status';
    // On Roster is GRANTED by the 🌐 pull on teams whose league list is
    // online (2026-10-21) — the option is not pickable there (moving a
    // player OFF On Roster stays manual; the selected value still shows).
    const onlineRoster = Array.isArray(this._data && this._data.onlineRosterTeams)
      && this._data.onlineRosterTeams.includes(col.teamId);
    // Roster moves (mig 777, owner 2026-10-27: "not out of 'official'
    // except to put them in 'dropping' col and then pending drop"): a man
    // on this team's league list moves only between On Roster, Dropping
    // and Pending Drop (no blank either); one off a list the team has
    // gets no drop lane.  TeamController enforces the same rule.  A youth
    // file list locks nothing (mig 868).
    const onList  = this.leagueListLocks(col.teamId, player.personId);
    const list    = this.leagueListFor(col.teamId);
    const hasList = !!list && !list.fromFile;
    const dropLane = (st) => st.boardSection === 'drop' || st.boardSection === 'pending_drop';
    const offLane = (st) => onList ? !(st.countsAsOnRoster || dropLane(st)) : (hasList && dropLane(st));
    const opts = options.map(s => {
      const viaPull = onlineRoster && s.code === 'on_roster' && current !== 'on_roster' && !onList;
      const laneOff = !viaPull && offLane(s) && s.code !== current;
      const tip = viaPull ? "Granted by the league's own list — pull 🌐 Roster"
        : laneOff ? (onList ? "On the league's list — only Dropping / Pending Drop; the league takes him off"
                            : "Not on the league's list — nothing to drop")
        : (s.description || '');
      return `<option value="${esc(s.code)}" ${viaPull || laneOff ? 'disabled' : ''}
        title="${esc(tip)}"
        ${current === s.code ? 'selected' : ''}>${esc(s.displayName || s.code)}${viaPull ? ' (via 🌐)' : ''}</option>`;
    }).join('\n         ');
    return `<select class="mr-status-select" data-team-id="${col.teamId}" data-person-id="${player.personId}"
               title="${esc(title)}"
               style="font-size:0.6rem; font-weight:800; letter-spacing:0.01em; padding:0 2px; line-height:1.2; border-radius:3px; ${this.rosterStatusStyle(current)} ${RosterScreenBase.SELECT_WIDTH_STYLE}">
         <option value="" ${!current ? 'selected' : ''} ${onList && current ? 'disabled' : ''}>Status: —</option>
         ${opts}
       </select>${withHealth ? this.renderHealthControl(player) : ''}`;
  }

  // TEAM dropdown (owner 2026-10-29: "a drop down for roster status and
  // another drop down for team status") — his role on THIS team, beside
  // the Roster dropdown (league paperwork); the two are independent.
  //   ✅ Plays / 📄 Paper spot / ↔ Call-in — team_persons.invite_only +
  //     call_in (migs 619/637), per team.
  //   🩹 each injured health status — per PERSON ("injured everywhere"),
  //     the same /api/person-health write as the ⋯ health control; its
  //     since / back-on dates show underneath while injured.
  // Words: message_templates kind roster_sheet team_status_* (mig 814).
  renderTeamStatusSelect(player, col, canMove) {
    if (!(col && col.teamId && player.personId)) return '';
    const esc  = RosterScreenBase.escapeHtml;
    const copy = (tier) => (window.MessageCopy && MessageCopy.block('roster_sheet', tier)) || '';
    const H    = RosterScreenBase.HEALTH;
    const injury = H.people[player.personId] || null;
    const teamCode = player.squadStatus || (player.inviteOnly === true ? 'inactive' : 'plays');
    const current  = injury ? injury.code : teamCode;
    const COLORS = {
      plays:  ['#22c55e', 'rgba(34,197,94,0.18)', '#bbf7d0'],
      callin: ['#a78bfa', 'rgba(167,139,250,0.22)', '#ddd6fe'],
      practice_squad: ['#60a5fa', 'rgba(96,165,250,0.22)', '#bfdbfe'],
      not_eligible:   ['#f87171', 'rgba(248,113,113,0.20)', '#fecaca'],   // mig 1523, set by the sync
      standby:        ['#60a5fa', 'rgba(96,165,250,0.22)', '#bfdbfe'],    // 🪑 Reserves, men (mig 1530)
      inactive:       ['#94a3b8', 'rgba(148,163,184,0.22)', '#e2e8f0'],
    };
    // Men: ✅ Regular / 🪑 Reserves (mig 1530); youth keep their groups.
    const opts = this._hasReserves() ? [
      { code: 'plays',   label: copy('team_status_regular') || '✅ Regular' },
      { code: 'standby', label: copy('team_status_standby') || '🪑 Reserves' },
      ...H.statuses.filter(st => st.isInjured).map(st => ({ code: st.code, label: (st.icon ? st.icon + ' ' : '') + st.displayName })),
    ] : [
      { code: 'plays',  label: copy('team_status_plays')  || '✅ Plays' },
      { code: 'practice_squad', label: copy('team_status_practice_squad') || 'Practice Squad' },
      // ⛔ set by the official-roster sync only (mig 1523): shown, never picked.
      ...(teamCode === 'not_eligible' ? [{ code: 'not_eligible', label: copy('team_status_not_eligible') || '⛔ Not On Roster (auto)', disabled: true }] : []),
      // 💤 Inactive is per team (mig 1074, 📄 Paper spot folded in); the
      // "all teams" pick parks him on every team he is on in one tap.
      { code: 'inactive', label: copy('team_status_inactive') || '💤 Inactive' },
      { code: 'inactive_all', label: copy('team_status_inactive_all') || '💤 Inactive — all his teams' },
      ...H.statuses.filter(st => st.isInjured).map(st => ({ code: st.code, label: (st.icon ? st.icon + ' ' : '') + st.displayName })),
    ];
    const style = injury ? this.healthStyle(current)
      : `background:${COLORS[teamCode][1]}; color:${COLORS[teamCode][2]}; border:1px solid ${COLORS[teamCode][0]};`;
    const selectStyle = `font-size:0.6rem; font-weight:800; letter-spacing:0.01em; padding:0 2px; line-height:1.2; border-radius:3px; ${style} ${RosterScreenBase.SELECT_WIDTH_STYLE}`;
    const label = (opts.find(o => o.code === current) || opts[0]).label;
    if (!canMove) return `<span title="${esc(copy('team_status_title'))}" style="${selectStyle}">${esc(label)}</span>`;
    const dateRow = (cls, text, value, bounds) =>
      `<label class="mr-health-dates" style="display:${injury ? 'flex' : 'none'}; flex-direction:column; gap:1px; font-size:0.58rem; font-weight:700; color:#cbd5e1;">
         ${esc(text || '')}
         <input type="date" class="${cls}" value="${esc(value || '')}" ${bounds}
                style="font-size:0.65rem; padding:0 2px; border-radius:3px; border:1px solid #475569; background:#0f172a; color:#fff; color-scheme:dark;">
       </label>`;
    return `<span class="mr-team-status" data-person-id="${player.personId}" data-team-id="${col.teamId}"
                  data-team-code="${teamCode}" style="display:flex; flex-direction:column; gap:3px;">
         <select class="mr-team-status-select" title="${esc(copy('team_status_title'))}" style="${selectStyle}">
           ${opts.map(o => `<option value="${esc(o.code)}" ${o.code === current ? 'selected' : ''}${o.disabled ? ' disabled' : ''}>${esc(o.label)}</option>`).join('')}
         </select>
         ${dateRow('mr-health-since', H.copy.since_label, injury && injury.since, `max="${RosterScreenBase.clubDay()}"`)}
         ${dateRow('mr-health-until', H.copy.until_label, injury && injury.until, `min="${RosterScreenBase.clubDay(1)}"`)}
       </span>`;
  }

  // The screens' delegated change listeners call this; true = handled.
  // A team code writes invite_only/call_in (and ends an injury — picking
  // Plays says he is back); an injury code writes the person's health.
  // The card's shirt-number box changed → PUT /api/kit/number (the #kit
  // board's write: one number per person per uniform set, no duplicates).
  // Returns true when the event was ours.
  onJerseyChange(target) {
    const input = target && target.closest && target.closest('.roster-jersey-input');
    if (!input) return false;
    const teamId = Number(input.dataset.teamId), personId = Number(input.dataset.personId);
    const value = input.value.trim();
    const prev = input.defaultValue;
    input.disabled = true;
    (async () => {
      try {
        const res = await this.auth.fetch('/api/kit/number', {
          method: 'PUT', headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ team_id: teamId, person_id: personId, jersey_number: value || null }),
        });
        const body = await res.json().catch(() => ({}));
        if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
        const saved = body.jersey_number || '';
        input.value = input.defaultValue = saved;
        const K = (this._data.kitNumbers = this._data.kitNumbers || {});
        const t = (K[String(teamId)] = K[String(teamId)] || {});
        if (saved) t[String(personId)] = saved; else delete t[String(personId)];
      } catch (err) {
        input.value = prev;
        alert(`Could not save the number: ${err.message}`);
      } finally { input.disabled = false; }
    })();
    return true;
  }

  onTeamStatusChange(target) {
    const wrap = target && target.closest && target.closest('.mr-team-status');
    if (!wrap) return false;
    this.saveTeamStatus(wrap);
    return true;
  }

  async saveTeamStatus(wrap) {
    const H = RosterScreenBase.HEALTH;
    const personId = parseInt(wrap.dataset.personId, 10);
    const teamId   = parseInt(wrap.dataset.teamId, 10);
    const value    = wrap.querySelector('.mr-team-status-select').value;
    const injury   = H.statuses.find(st => st.isInjured && st.code === value);
    const put = async (url, method, body) => {
      const res = await this.auth.fetch(url, { method, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
      return data;
    };
    wrap.querySelectorAll('select, input').forEach(el => { el.disabled = true; });
    try {
      if (injury) {
        const body = { person_id: personId, status: injury.code };
        const since = wrap.querySelector('.mr-health-since').value;
        const until = wrap.querySelector('.mr-health-until').value;
        if (since) body.since = since;
        if (until) body.until = until;
        const data = await put('/api/person-health', 'PUT', body);
        if (data.health) H.people[personId] = data.health; else delete H.people[personId];
      } else {
        if (value !== wrap.dataset.teamCode) {
          await put('/api/mens-roster/invite-only', 'POST',
            { personId, teamId, inviteOnly: value !== 'plays', callIn: value === 'callin',
              squadStatus: value === 'inactive_all' ? 'inactive' : ['practice_squad', 'inactive', 'standby'].includes(value) ? value : '',
              allTeams: value === 'inactive_all' });
        }
        if (H.people[personId]) {
          const healthy = H.statuses.find(st => !st.isInjured);
          if (healthy) { await put('/api/person-health', 'PUT', { person_id: personId, status: healthy.code }); delete H.people[personId]; }
        }
      }
    } catch (err) {
      alert(`Could not save team status: ${err.message}`);
    }
    if (typeof this.load === 'function') await this.load({ quiet: true });
    if (typeof this.onMembershipChanged === 'function') this.onMembershipChanged();
  }

  // Optimistic: flip the select's own state immediately, roll back only
  // on a failed save — no full-board reload needed since neither of
  // these moves the card between columns.
  async onLineupRoleSelectChange(select) {
    const teamId = parseInt(select.dataset.teamId, 10);
    const personId = parseInt(select.dataset.personId, 10);
    const lineupRole = select.value || null;
    if (!teamId || !personId) return;

    const prevValue = Array.from(select.options).find(o => o.defaultSelected)?.value ?? '';
    select.disabled = true;
    try {
      const res = await this.auth.fetch(`/api/teams/${teamId}/roster/person/${personId}/lineup-role`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ lineupRole }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      select.querySelectorAll('option').forEach(o => { o.defaultSelected = o.selected; });
    } catch (err) {
      select.value = prevValue;
      alert(`Could not save Roster Role: ${err.message}`);
    } finally {
      select.disabled = false;
    }
  }

  async onRosterStatusSelectChange(select) {
    const teamId = parseInt(select.dataset.teamId, 10);
    const personId = parseInt(select.dataset.personId, 10);
    const rosterStatus = select.value || null;
    if (!teamId || !personId) return;

    const prevValue = Array.from(select.options).find(o => o.defaultSelected)?.value ?? '';
    select.disabled = true;
    // Picked in the player sheet: the card's own copy follows, so the
    // column tallies and the card chip move with it.
    const mirror = (v) => {
      if (!select.closest('.player-sheet')) return;
      this.element.querySelectorAll(`.mr-status-select[data-team-id="${teamId}"][data-person-id="${personId}"]`).forEach(s => {
        if (s !== select && !s.closest('.player-sheet')) { s.value = v; this.applyRosterStatusStyle(s); }
      });
    };
    mirror(select.value);
    this.applyRosterStatusStyle(select);
    this.refreshOnRosterTally(teamId);
    this.refreshRosterStatusTallies(teamId);
    try {
      const res = await this.auth.fetch(`/api/teams/${teamId}/roster/person/${personId}/roster-status`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ rosterStatus }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      select.querySelectorAll('option').forEach(o => { o.defaultSelected = o.selected; });
      // the card may change section, or cross between the panels
      if (typeof this.load === 'function') this.load({ quiet: true });
      if (typeof this.onMembershipChanged === 'function') this.onMembershipChanged();
    } catch (err) {
      select.value = prevValue;
      mirror(prevValue);
      this.applyRosterStatusStyle(select);
      this.refreshOnRosterTally(teamId);
      this.refreshRosterStatusTallies(teamId);
      alert(`Could not save Roster Status: ${err.message}`);
    } finally {
      select.disabled = false;
    }
  }

  formatDobShort(value) {
    if (!value) return '';
    const d = new Date(`${value}T00:00:00Z`);
    if (Number.isNaN(d.getTime())) return String(value);
    return d.toLocaleDateString('en-US', { month: 'numeric', day: 'numeric', year: 'numeric', timeZone: 'UTC' });
  }

  getGenderCode(player) {
    const raw = [player?.gender, player?.genderCategory, player?.sex, player?.sexCode]
      .find((value) => value != null && String(value).trim());
    if (!raw) return '';
    const value = String(raw).trim().toLowerCase();
    if (['m', 'male', 'man', 'mens', 'boy', 'boys'].includes(value)) return 'M';
    if (['f', 'female', 'woman', 'womens', 'girl', 'girls'].includes(value)) return 'F';
    return '';
  }

  // Dues status pill — green when no outstanding balance, red otherwise.
  // Shared by boys/girls/women's and men's cards so the styling only
  // needs to change in one place.
  //
  // FH-only squad cards (2026-08-02, mens board): a player added to a
  // real column via team_persons but with no active LA registration
  // has no billing data — showing the green/red pill would misrepresent
  // them as a confirmed, paid LA member.  Render a distinct neutral
  // badge instead so admin can see at a glance the LA side still needs
  // fixing (see MensRoster.cpp's FH-only squad cards block).
  renderDuesLabel(player) {
    if (player.noActiveLaRegistration) {
      // laHomeCategory: their actual active LA registration category
      // ('boys'/'girls'/'women'), when they have one — e.g. Sheldon
      // Rhoden is an active Boys Club member LA won't let us also
      // register as Mens (16-17 age gap in how LA's programs are set
      // up). Falls back to a generic label if they have no active LA
      // membership anywhere.
      const categoryLabel = { boys: 'Boy', girls: 'Girl', women: 'Women' }[player.laHomeCategory] || null;
      const text = categoryLabel ? `${categoryLabel} LA reg` : 'No LA reg';
      const title = categoryLabel
        ? `Active LeagueApps registration is ${categoryLabel} Club, not Mens — dues status unknown here`
        : `No active LeagueApps registration in any program — dues status unknown`;
      return `<span title="${title}" style="display:inline-flex; align-items:center; gap:4px; font-size:0.68rem; line-height:1.2; padding:0 6px; border-radius:999px; color:#94a3b8; font-weight:700; border:1px solid #94a3b8;">${text}</span>`;
    }
    const balanceValue = Number(player.outstandingBalance || 0);
    const duesColor = balanceValue === 0 ? '#22c55e' : '#ef4444';
    const pillHtml = `<span style="display:inline-flex; align-items:center; gap:4px; font-size:0.68rem; line-height:1.2; padding:0 6px; border-radius:999px; color:${duesColor}; font-weight:700;">Dues</span>`;
    // Tap opens his LeagueApps page to run a card (owner 11/5) — the same
    // link every player card's dues pill carries (PersonStanding.laLink).
    return window.PersonStanding ? PersonStanding.laLink(pillHtml, player.leagueAppsUserId) : pillHtml;
  }

  // Card border is neutral on every board (owner 2026-09-05) — dues risk
  // lives on the Dues pill, not the frame, so the only colour on a card
  // is gender / dues / roster status. `days` kept in the signature so
  // callers didn't have to change.
  static get NEUTRAL_CARD_BORDER() { return '2px solid #475569'; }

  getCompactCardBorder(days, fallback) {
    return RosterScreenBase.NEUTRAL_CARD_BORDER;
  }

  renderPersonActions(person, { returnTo = '', showEdit = false, btnBaseStyle = '' } = {}) {
    if (!window.PersonActions || !person) return '';
    return window.PersonActions.buttonsHtml(person, {
      returnTo,
      btnBaseStyle,
      showEdit,
      neutral: true, // Teams board: only gender/dues/roster status carry colour
    });
  }

  // Roster-move dropdown: a <details>/<summary> popover for the ONE
  // team_persons row this specific card represents (`currentTeamId` —
  // 0 for an Unassigned card). Identical for boys/girls/women's/men's —
  // uses a single shared class name (not per-screen br-/mr- prefixed)
  // because each screen's click listener is delegated on `this.element`
  // (its own DOM subtree), so there's no cross-screen collision risk.
  // The caller still owns click handling (onMoveOptionClick) since that
  // POSTs to a screen-specific endpoint.
  //
  // 2026-08-16 (multi-assign): a player can hold any number of active
  // rows at once, so this dropdown no longer treats team selection as
  // exclusive. Every option other than `currentTeamId` is an ADD (a new
  // row for this player on that team — see MensTeamAssignments::
  // addAssignmentForPerson, which stopped closing sibling rows) and
  // never touches this card's own row. Picking "Unassigned" is the only
  // way to remove — and it removes exactly `currentTeamId`, nothing
  // else, since that's the one row this card owns. Options the player
  // is ALSO already on (via a different card) get a distinct "already
  // on" style so admin isn't surprised clicking one is a no-op instead
  // of a move.
  renderMoveDropdown(player, columns, currentTeamId = 0) {
    const assignedSet = new Set(player.teamIds || []);

    // Options in the open popover use the full team name (owner
    // 2026-08-25: "in drop down write out full name of team") — a flat
    // list of "U10 Intra" / "U12 Intra" / "U16 Intra" reads as
    // near-identical. The closed trigger on the card is the opposite
    // case (owner 2026-09-05: "U10 INTRAMURAL" was bleeding out of the
    // cards): it shows teams.short_label ("U10 Intra") since the column
    // already says which team this is. Leading emoji ("⚽ ", "🏆 ") is
    // stripped from both — "it does not need a soccer ball icon".
    //
    // Sorted by name rather than board order, numeric-aware so U6/U8/U10
    // fall in age order instead of the "U10, U12, U16, U19, U6" a plain
    // string sort produces. Unassigned is pinned first: it is the removal
    // action, not a team, and belongs where the eye lands.
    // Team colour deliberately ignored (owner 2026-09-05): which team a
    // card is on is already obvious from its column, so the dropdown
    // stays neutral and lets roster status be the thing that's coloured.
    const stripIcon = (s) => String(s || '').replace(/^[^\p{L}\p{N}]+/u, '').trim();
    const teamTargets = (columns || []).map(c => ({
      id:    c.teamId,
      label: RosterScreenBase.dropClubName(stripIcon(c.label || c.shortLabel)) || `Team ${c.teamId}`,
      short: RosterScreenBase.dropClubName(stripIcon(c.shortLabel || c.label)) || `Team ${c.teamId}`,
    }));
    teamTargets.sort((a, b) =>
      String(a.label).localeCompare(String(b.label), undefined, { numeric: true, sensitivity: 'base' }));

    // On the league's own list for this team: no Unassigned/remove —
    // "i can move them but not OFF that official roster" (2026-10-27).
    const listLocked = this.leagueListLocks(currentTeamId, player.personId);
    const targets = [
      ...(listLocked ? [] : [{ id: 0, label: 'Unassigned', short: 'Unassigned' }]),
      ...teamTargets,
    ];
    // appearance:none/min-height:0 strip the native OS button-chrome
    // minimum height browsers give real <button> elements (the option
    // buttons); harmless no-op on the <summary> trigger, which has no
    // such native chrome to begin with.
    const btnBase = 'font-size:0.68rem; padding:0 6px; line-height:1.2; font-weight:800; letter-spacing:0.02em; border-radius:3px; white-space:nowrap; appearance:none; -webkit-appearance:none; min-height:0; box-sizing:border-box; margin:0;';
    // Option rows (revealed on click) get a touch more breathing room
    // than the collapsed trigger — line-height/padding bumped so each
    // target reads as its own row instead of a cramped list.
    const optBtnBase = 'font-size:0.68rem; padding:3px 6px; line-height:1.5; font-weight:800; letter-spacing:0.02em; border-radius:3px; white-space:nowrap; appearance:none; -webkit-appearance:none; box-sizing:border-box; margin:0;';

    const activeTarget = targets.find(t => t.id === currentTeamId) || targets[0];
    const optBtns = targets.map(t => {
      const isCurrent = t.id === currentTeamId;
      // Already on this team via a DIFFERENT card (multi-assign) — not
      // this card's own row, so clicking it re-adds (a harmless no-op)
      // rather than removing anything. Styled distinctly from "current"
      // so admin can tell the two apart at a glance.
      const alsoAssigned = !isCurrent && t.id !== 0 && assignedSet.has(t.id);
      let style;
      let prefix = '';
      let title;
      if (isCurrent) {
        style  = `background:#334155; color:#fff; border:1px solid #475569; cursor:pointer;`;
        prefix = '✓ ';
        title  = t.id === 0 ? 'Currently unassigned here' : `Currently on ${t.label} (this card)`;
      } else if (alsoAssigned) {
        style  = `background:transparent; color:#cbd5e1; border:1px solid #64748b; cursor:pointer;`;
        prefix = '• ';
        title  = `Already on ${t.label} (via another card)`;
      } else {
        style  = `background:transparent; color:#cbd5e1; border:1px dashed #64748b; cursor:pointer;`;
        title  = t.id === 0 ? `Remove from ${activeTarget.label}` : `Add to ${t.label}`;
      }
      // The current option is NOT disabled — clicking it is a same-team
      // no-op in onMoveOptionClick, which now closes the popover before
      // checking that, so clicking your current selection is how you
      // roll the dropdown back up (2026-08-02, user directive) rather
      // than a dead end.
      return `<button class="roster-move-option" type="button"
                      data-user-id="${player.leagueAppsUserId}"
                      data-person-id="${player.personId || ''}"
                      data-target-team-id="${t.id}"
                      data-current-team-id="${currentTeamId}"
                      title="${title}"
                      style="${optBtnBase} ${style} text-align:left;">
                ${prefix}${t.label.toUpperCase()}
              </button>`;
    }).join('');
    // Trigger stretches to the full height of the card (a flex item
    // alongside the VIEW button in renderCompactCard's right-hand
    // strip) — height:100% + flex centering on the summary itself,
    // since <details> defaults to block/inline layout that won't pass
    // stretch through to its child on its own.
    return `
      <details class="roster-move-details" style="position:relative; display:flex; height:100%;">
        <summary style="${btnBase} height:100%; display:flex; align-items:center; justify-content:center; background:#0f172a; color:#fff; border:1px solid #475569; cursor:pointer; user-select:none;"
                 title="Add ${this.escape(player.firstName || 'player')} to another team, or remove from this one">
          ${this.escape(activeTarget.short.toUpperCase())} ▾
        </summary>
        <div style="position:absolute; top:100%; left:0; z-index:20; margin-top:2px; display:flex; flex-direction:column; gap:2px; background:#0f172a; padding:3px; border-radius:4px; box-shadow:0 4px 12px rgba(0,0,0,0.45); border:1px solid #334155; min-width:100%;">
          ${optBtns}
        </div>
      </details>`;
  }

  // "Lighthouse Mens Club APSL" → "Mens Club APSL".  Everything on these
  // boards is Lighthouse; on a card the club name only costs width.
  static dropClubName(name) {
    const full = String(name || '');
    // …and the section too when a team name follows it ("Mens Club APSL"
    // → "APSL"; plain "Boys Club" stays) — owner: "we are in mens club
    // don't need to say mens club for team".
    return full.replace(/^\s*Lighthouse\s+(?:1893\s+)?/i, '')
               .replace(/^(?:Men'?s|Women'?s|Boys|Girls)\s+Club\s+(?=\S)/i, '') || full;
  }

  // 👀⚽ on the card (owner 2026-11-04: "just an eye ball and soccer ball
  // … the game they see is then obvious because of column they are in"):
  // this column's games reach him with no per-game invite — a roster row
  // that grants games (full spot, team not call-up-only, mig 605) or a
  // ⭐ standing invite.  Replaces the column's 👀 Sees games filter pill.
  // A youth team is named by its age ("U8"), so a chip naming it reads
  // like a second age chip (owner 11/4: "ONLY 1 age chip … on all players
  // everywhere").  Age-named teams get a word after the name; the card's
  // plain U-chip stays the one age chip.
  static teamChipName(name, kind) {
    const n = String(name || '').trim();
    if (!/^U\s*\d+$/i.test(n)) return n;
    const copy = window.MessageCopy && MessageCopy.block('roster_sheet', kind === 'list' ? 'chip_age_team_list' : 'chip_age_team', { team: n });
    return copy || (kind === 'list' ? `${n} list` : `${n} team`);
  }

  // ── 👁 SEES + 📋 ROSTERS (mig 1435, owner 2026-11-17) ──────────────
  // Their own line on every card, Team and Roster pills, every board:
  //   👁 SEES     what each team's events ask him about by default (no
  //               per-game invite) — fh_person_sees, the RSVP board's own
  //               rules: ⚽ games, 🏃 practices (a coach's days), ⚽ if
  //               called up, ⭐⚽ standing invite, — nothing (💤 / why).
  //               A team with no events of its own (APSL Reserves) is a
  //               roster, so it's never here.
  //   📋 ROSTERS  the official league lists he is on (pulled from the
  //               league sites every load) — replaces the green On Roster
  //               chip and the Team pill's 📋 chips.
  // Each card draws a placeholder; one GET /api/person-sees?ids= per batch
  // fills every placeholder on the board, and the answers are cached for
  // re-renders (a write that changes them calls clearSeesCache()).
  seesRostersHtml(personId) {
    const pid = Number(personId);
    if (!pid) return '';
    const cache = this._seesCache || (this._seesCache = new Map());
    const known = cache.get(pid);
    if (!known) this._queueSees(pid);
    this._bindSeesRestrain();
    return `<div data-sees-person="${pid}" style="flex-basis:100%; display:flex; flex-wrap:wrap; gap:4px 6px; font-size:0.6rem; line-height:1.35; padding:4px 0 0;">${known ? this._seesContent(known, pid) : ''}</div>`;
  }

  clearSeesCache() { this._seesCache = new Map(); }

  // 🚫 / ↺ on an official-list pill (mig 1443): restrain him from that
  // team's games, or lift it. One capture-phase listener so the card's own
  // tap (the ⋯ sheet) never fires; the server re-syncs the game invites.
  _bindSeesRestrain() {
    if (this._seesRestrainBound) return;
    this._seesRestrainBound = true;
    document.addEventListener('click', async (e) => {
      const b = e.target.closest && e.target.closest('[data-sees-restrain], [data-sees-set]');
      if (!b || !this.auth) return;
      e.preventDefault(); e.stopPropagation();
      if (b.dataset.busy) return;
      b.dataset.busy = '1'; b.style.opacity = '0.4';
      // one SEES write (mig 1450): true = call-down, false = restrained, null = roster decides
      const pid = Number(b.dataset.seesRestrain || b.dataset.seesSet), teamId = Number(b.dataset.team);
      const sees = b.dataset.seesSet ? JSON.parse(b.dataset.sees) : (b.dataset.on === '1' ? false : null);
      try {
        const res = await this.auth.fetch('/api/person-sees/set', {
          method: 'POST', headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ person_id: pid, team_id: teamId, sees }),
        });
        const body = await res.json().catch(() => ({}));
        if (!res.ok) throw new Error(body.error || res.status);
        // re-read him whole: SEES, ROSTERS and the ＋ call-down options
        const cache = this._seesCache || (this._seesCache = new Map());
        const again = await this.auth.fetch(`/api/person-sees?ids=${pid}`).then(r => r.ok ? r.json() : null).catch(() => null);
        const fresh = (again && again.people && again.people[String(pid)]) || (body.people || {})[String(pid)];
        if (fresh) cache.set(pid, { ...(cache.get(pid) || {}), ...fresh });
        document.querySelectorAll(`[data-sees-person="${pid}"]`).forEach(el => { el.innerHTML = this._seesContent(cache.get(pid), pid); });
      } catch (err) {
        console.warn('[sees] restrain failed:', err);
        delete b.dataset.busy; b.style.opacity = '';
      }
    }, true);
  }

  _queueSees(pid) {
    const q = this._seesQueue || (this._seesQueue = new Set());
    q.add(pid);
    if (this._seesTimer) return;
    this._seesTimer = setTimeout(() => this._flushSees(), 0);
  }

  async _flushSees() {
    this._seesTimer = null;
    const ids = [...(this._seesQueue || [])];
    this._seesQueue = new Set();
    if (!ids.length || !this.auth) return;
    const cache = this._seesCache || (this._seesCache = new Map());
    for (let i = 0; i < ids.length; i += 300) {
      const chunk = ids.slice(i, i + 300);
      try {
        const res = await this.auth.fetch(`/api/person-sees?ids=${chunk.join(',')}`);
        if (!res.ok) return;   // players / a lapsed session: no sections
        const body = await res.json();
        for (const id of chunk) cache.set(id, (body.people || {})[String(id)] || { sees: [], rosters: [] });
      } catch (err) {
        console.warn('[sees] load failed:', err);
        return;
      }
    }
    const root = this.element || document;
    root.querySelectorAll('[data-sees-person]').forEach(el => {
      const known = cache.get(Number(el.dataset.seesPerson));
      if (known) el.innerHTML = this._seesContent(known, Number(el.dataset.seesPerson));
    });
  }

  _seesContent(entry, personId) {
    const esc = (s) => this.escape(s);
    const cp = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.block('roster_sheet', tier, tokens || {})) || fb;
    const label = (t) => RosterScreenBase.dropClubName(String(t || '').replace(/^[^\p{L}\p{N}]+/u, '').trim()) || t || '';
    const DAY = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const admin = this._cardClassFor() === AdminTeamCard;
    // One entry per team: a coach who also plays merges (best of each).
    const rankG = { yes: 3, invite: 2, callup: 1, no: 0 };
    const rankP = { yes: 2, days: 1, no: 0 };
    const rows = Array.isArray(entry.sees) ? entry.sees : [];
    const byTeam = new Map();
    for (const r of rows) {
      if (r.team_id == null) continue;
      const m = byTeam.get(r.team_id) || { teamId: r.team_id, team: r.team, games: 'no', practices: 'no', days: null, coach: false, plays: false, note: null, bg: r.pill_bg, fg: r.pill_fg, section: r.section };
      if ((rankG[r.games] || 0) > (rankG[m.games] || 0)) m.games = r.games;
      if ((rankP[r.practices] || 0) > (rankP[m.practices] || 0)) { m.practices = r.practices; m.days = r.days; }
      if (r.role === 'coach') m.coach = true;
      if (r.role === 'player') m.plays = true;
      if (r.role === 'staff') m.staff = true;
      if (r.role === 'player' && r.note) m.note = r.note;
      byTeam.set(r.team_id, m);
    }
    // Only the board's own section (seesSections(); null = every team) —
    // no youth teams or 🧢 Youth coach pill on the Men's page.
    const own = typeof this.seesSections === 'function' ? this.seesSections() : null;
    const teams = [...byTeam.values()].filter(t => !own || !t.section || own.includes(t.section));
    // ONE pill look for both blocks (owner 11/17 "be consistent in roster
    // box. use green pill" + "same for sees. use pill"): green = asked /
    // on the list; grey = asked about nothing; red/amber = ⛔ / 🩹.
    const PILL = {
      green: 'background:rgba(34,197,94,0.16); border:1px solid #22c55e; color:#bbf7d0;',
      grey:  'background:rgba(148,163,184,0.12); border:1px solid rgba(148,163,184,0.45); color:#cbd5e1;',
      red:   'background:rgba(239,68,68,0.16); border:1px solid #ef4444; color:#fca5a5;',
      amber: 'background:rgba(245,158,11,0.16); border:1px solid #f59e0b; color:#fcd34d;',
    };
    // A team's own pill colour (teams.card_pill_bg/fg, mig 1438 — APSL
    // royal blue, Liga 1 white) wins over green.
    const hex = (c) => /^#[0-9a-f]{3,8}$/i.test(String(c || '')) ? c : null;
    const pill = (html, tone, bg, fg) => {
      const look = hex(bg) ? `background:${bg}; border:1px solid ${bg}; color:${hex(fg) || '#ffffff'};` : PILL[tone || 'green'];
      return `<span style="white-space:nowrap; font-weight:800; padding:0 6px; border-radius:999px; ${look}">${html}</span>`;
    };
    const item = (t) => {
      const marks = [];
      if (t.games === 'yes') marks.push(cp('card_sees_games', {}, '⚽'));
      else if (t.games === 'invite') marks.push(cp('card_sees_invite', {}, '⭐⚽'));
      else if (t.games === 'callup') marks.push(cp('card_sees_callup', {}, '⚽ if called up'));
      if (t.practices === 'yes') marks.push(cp('card_sees_practices', {}, '🏃'));
      else if (t.practices === 'days') marks.push(cp('card_sees_days', { days: (t.days || []).map(d => DAY[d] || d).join('·') }, '🏃'));
      let why = '';
      if (!marks.length) why = t.note === 'inactive' ? cp('card_sees_why_inactive', {}, '💤')
        : t.note === 'restrained' ? cp('card_sees_why_restrained', {}, '🚫 restrained') : cp('card_sees_nothing', {}, '—');
      else if (t.note === 'practice_squad') why = cp('card_sees_why_practice_squad', {}, 'practice squad');
      else if (t.note === 'not_on_roster') why = cp('card_sees_why_not_on_roster', {}, 'not on roster');
      const coach = t.coach ? cp('card_sees_coach', {}, '🧢') + ' ' : '';
      // 📋 games through an official list → 🚫 restrains; restrained → ↺ lifts (admins).
      // Club staff see every game anyway: no list mark, nothing to restrain.
      const canRestrain = admin && personId && t.teamId && !t.staff && (t.note === 'official_list' || t.note === 'restrained');
      const btn = canRestrain
        ? ` <span role="button" data-sees-restrain="${personId}" data-team="${t.teamId}" data-on="${t.note === 'official_list' ? '1' : '0'}"
              title="${esc(t.note === 'official_list'
                ? cp('card_sees_restrain_tip', { team: t.team }, `On the official list, so asked about ${t.team} games. Tap to restrain.`)
                : cp('card_sees_unrestrain_tip', { team: t.team }, `Restrained from ${t.team} games. Tap to ask him again.`))}"
              style="cursor:pointer; padding:0 2px; margin-left:1px; border-left:1px solid currentColor; opacity:0.85;">${esc(t.note === 'official_list'
                ? cp('card_sees_restrain', {}, '🚫') : cp('card_sees_unrestrain', {}, '↺'))}</span>`
        : '';
      // ⬇ standing call-down (mig 1450: sees yes on the team) → ✕ ends it (admins)
      const endBtn = admin && personId && t.teamId && t.note === 'standing_invite'
        ? ` <span role="button" data-sees-set="${personId}" data-team="${t.teamId}" data-sees="null"
              title="${esc(cp('card_sees_end_call_down_tip', { team: t.team }, `Called down to every ${t.team} game. Tap to stop.`))}"
              style="cursor:pointer; padding:0 2px; margin-left:1px; border-left:1px solid currentColor; opacity:0.85;">${esc(cp('card_sees_end_call_down', {}, '✕'))}</span>`
        : '';
      const via = t.note === 'official_list' && !t.staff ? ' ' + cp('card_sees_via_list', {}, '📋') : '';
      return pill(`${esc(t.raw ? t.team : (RosterScreenBase.dropClubName(String(t.team || '')) || t.team))} ${esc(coach + marks.join(' ') + via)}${why ? ` <span style="font-weight:600; opacity:0.8;">${esc(why)}</span>` : ''}${btn}${endBtn}`, marks.length ? 'green' : 'grey', marks.length ? t.bg : null, t.fg);
    };
    // Coach / club staff of MANY teams in one section (not playing on
    // them) gets ONE pill — "🧢 Youth coach · 18", "🛡 Youth staff · 18" —
    // that opens to those teams (owner 11/17 "maybe we have youth coach
    // pill or something and its clickable to show who he coaches").  A
    // short list (Men: APSL + L1) stays separate pills (owner 11/17 "2
    // possible pills for men. liga 1 and apsl").
    const GROUP = { boys: 'youth', girls: 'youth', mens: 'mens', womens: 'womens' };
    const groups = new Map();
    for (const t of teams) {
      if (!(t.coach || t.staff) || t.plays) continue;
      const g = GROUP[t.section] || 'youth';
      if (!groups.has(g)) groups.set(g, []);
      groups.get(g).push(t);
    }
    const FOLD_AT = 5;
    const folded = new Set([...groups.values()].filter(l => l.length >= FOLD_AT).flat());
    const groupPill = (g, list) => {
      const name = cp('card_sees_group_' + g, {}, g === 'youth' ? 'Youth' : g === 'mens' ? 'Men' : 'Women');
      return `<details data-sees-coach-group style="display:contents;">
          <summary onclick="event.stopPropagation()" style="list-style:none; cursor:pointer; display:inline-flex;">${pill(esc(list.some(t => t.staff)
            ? cp('card_sees_staff_group', { group: name, n: String(list.length) }, `🛡 ${name} staff · ${list.length}`)
            : cp('card_sees_coach_group', { group: name, n: String(list.length) }, `🧢 ${name} coach · ${list.length}`)) + ' ▾')}</summary>
          <div style="flex-basis:100%; display:flex; flex-wrap:wrap; gap:3px 4px; padding:2px 0 2px 8px; border-left:2px solid rgba(34,197,94,0.45);">${list.map(t => item({ ...t, coach: false, staff: false })).join('')}</div>
        </details>`;
    };
    const coachPills = [...groups.entries()].filter(([, l]) => l.length >= FOLD_AT).map(([g, l]) => groupPill(g, l));
    const rest = teams.filter(t => !folded.has(t));
    let sees = rest.map(item).concat(coachPills);
    if (!sees.length) sees = [pill(esc(cp('card_sees_none', {}, 'nothing')), 'grey')];
    // ＋ L1 ⬇ (admins): a league call-down rule lets him be sent down to a
    // team he does not see yet → sees yes on it (mig 1450).
    if (admin && personId) for (const c of (Array.isArray(entry.call_down) ? entry.call_down : [])) {
      const tm = RosterScreenBase.dropClubName(String(c.team || '')) || c.team;
      sees.push(`<span role="button" data-sees-set="${personId}" data-team="${c.team_id}" data-sees="true"
        title="${esc(cp('card_sees_call_down_tip', { team: tm }, `Call him down to every ${tm} game.`))}"
        style="cursor:pointer; white-space:nowrap; font-weight:700; padding:0 6px; border-radius:999px; border:1px dashed rgba(148,163,184,0.6); color:#cbd5e1;">${esc(cp('card_sees_call_down', { team: tm }, `＋ ${tm} ⬇`))}</span>`);
    }
    if (entry.suspended) sees.push(pill(esc(cp('card_sees_suspended', {}, '⛔ suspended')), 'red'));
    if (entry.injured) sees.push(pill(esc(cp('card_sees_injured', {}, '🩹 injured')), 'amber'));
    // 📋 ROSTERS — "<league> <team>", the team left off when the league's
    // name already says it (APSL Reserves / APSL Res → "APSL Reserves";
    // CASA / L1 → "CASA L1"; Parks & Rec / U8 → "Parks & Rec U8").
    const rosters = Array.isArray(entry.rosters) ? entry.rosters : [];
    const rosterName = (r) => {
      const lg = String(r.league || ''), tm = label(r.team);
      return !tm || lg.toLowerCase().includes(tm.toLowerCase()) ? lg : `${lg} ${tm}`;
    };
    const rosterChip = (r) => pill(esc(rosterName(r)), 'green', r.pill_bg, r.pill_fg);
    // Each section is its own boxed block: header on top, contents below.
    const block = (tier, fb, tipTier, tipFb, accent, body, gap) => `
      <div title="${esc(cp(tipTier, {}, tipFb))}" style="flex:1 1 140px; min-width:0; border:1px solid ${accent}; border-radius:6px;
          background:rgba(255,255,255,0.03); padding:3px 6px 4px;">
        <div style="font-weight:900; letter-spacing:0.06em; font-size:0.56rem; opacity:0.75; margin-bottom:2px;">${esc(cp(tier, {}, fb))}</div>
        <div style="display:flex; flex-wrap:wrap; gap:${gap}; align-items:center;">${body}</div>
      </div>`;
    return block('card_sees_h', '👁 SEES', 'card_sees_tip', 'What each team asks him about by default',
        'rgba(148,163,184,0.35)', sees.join(''), '3px 4px')
      + block('card_rosters_h', '📋 ROSTERS', 'card_rosters_tip', 'Official league rosters he is on',
        'rgba(34,197,94,0.45)', rosters.length ? rosters.map(rosterChip).join('') : pill(esc(cp('card_rosters_none', {}, 'none')), 'grey'), '3px 4px');
  }

  // "Also a pickup member" chip. Members and Pickup are two independent
  // LeagueApps sub-programs — a person can hold one, the other, both or
  // neither — and holding both is not supposed to happen (owner
  // 2026-08-25: "i try to only move and not copy from member to pickup
  // member … nobody should be in both"). This card is by definition a
  // Members card, so the chip appearing means a duplicate registration
  // to clean up on the LA side.
  //
  // Amber, not the purple of the also-on-a-team chip: that one is
  // information, this one is an exception worth acting on. Backed by
  // PickupMembership (backend/src/models) via player.pickupMembership,
  // which is null for the overwhelming majority of cards.
  renderPickupBadge(player) {
    const pu = player.pickupMembership || player.pickup_membership;
    if (!pu) return '';
    const since = pu.registeredAt || pu.registered_at || '';
    const paid  = pu.paymentStatus || pu.payment_status || '';
    const bits  = [since ? `registered ${since}` : '', paid ? `LA status ${paid}` : '']
      .filter(Boolean).join(' · ');
    const title = `Also holds a Pickup membership${bits ? ` (${bits})` : ''}`
      + ' — Members and Pickup are separate registrations; nobody should hold both.';
    return `<span title="${this.escape(title)}" style="font-size:0.62rem; line-height:1.3; font-weight:700; padding:0 5px; border-radius:8px; background:rgba(148,163,184,0.18); color:#cbd5e1; white-space:nowrap;">⚡ Pickup</span>`;
  }

  // ── Card order within a column (owner 2026-09-17: "pills on #teams to
  // sort alpha by last name or by rank… default to alpha by last name").
  // 'alpha' — last name, then first.  'rank' — the coach's order, which is
  // how the server sends each column.  The #N on a card is ALWAYS the
  // coach rank, whichever way the column is sorted.  Drag-reorder rebuilds
  // the rank from the on-screen card order, so it is only live in rank
  // mode.  The #N slot picker works from the coach rank (slotReorder
  // below), so it is live in both modes — owner 2026-09-23, on the A–Z
  // default: "there is no way to change rank".
  get sortOrder() { return this._sortOrder || 'alpha'; }

  // Season pill (RostersScreen host, mig 795): the host hands over the lit
  // term's team map — { term, teams: { teamId: [term…] } } — or null for
  // every team.  A team with no term rows shows under every pill.
  setTerm(termInfo) {
    this._term = termInfo || null;
    if (this._data && typeof this.renderRoster === 'function') this.renderRoster(this._data);
  }

  // Column pills (owner 2026-11-09: "pills to toggle them on and off on
  // teams"): each team pill toggles its column in or out; none lit = every
  // column.  Remembered per board in this browser only (a convenience —
  // a blocked storage just starts with every column).
  _focusKey() { return `fh.teamFocus.${this.constructor.name}`; }
  _focusSet() {
    if (!this._teamFocus) {
      let ids = [];
      try { ids = JSON.parse(localStorage.getItem(this._focusKey()) || '[]'); } catch (_) { ids = []; }
      this._teamFocus = new Set(Array.isArray(ids) ? ids.map(Number).filter(Boolean) : []);
    }
    return this._teamFocus;
  }
  _saveFocus() { try { localStorage.setItem(this._focusKey(), JSON.stringify([...this._focusSet()])); } catch (_) { /* storage off */ } }
  hasTeamFocus(cols) { const s = this._focusSet(); return cols ? cols.some(c => s.has(c.teamId)) : s.size > 0; }
  isTeamFocused(teamId) { return this._focusSet().has(teamId); }
  // Lit teams not on this board (other season / category) don't count.
  focusedCols(cols) {
    const lit = cols.filter(c => this._focusSet().has(c.teamId));
    return lit.length ? lit : cols;
  }
  onTeamFocusPillClick(btn) {
    const id = parseInt(btn.dataset.teamFocusId, 10) || 0;
    const set = this._focusSet();
    if (!id) set.clear(); else if (set.has(id)) set.delete(id); else set.add(id);
    this._saveFocus();
    if (this._data) this.renderRoster(this._data);
  }

  // Every board's team-column filter: the season pill (mig 795) and, on
  // the Roster pill, only teams that keep a league roster
  // (teams.league_roster, mig 1007 — youth U19 has none; owner 11/3).
  inTerm(col) {
    if (col && !col.isUnassigned && this.boardView === 'roster' && col.leagueRoster === false) return false;
    // Team pill (mig 1010): a folded team (APSL Reserves) is no column of
    // its own — its men show as the CALL-UP POOL inside the parent column.
    if (col && !col.isUnassigned && this.boardView === 'team' && col.teamPillFoldInto) return false;
    const t = this._term;
    if (!t || !t.term || !col || col.isUnassigned) return true;
    const terms = t.teams && t.teams[String(col.teamId)];
    return !terms || terms.includes(t.term);
  }

  static get SORT_ORDERS() { return ['alpha', 'rank', 'paid', 'official', 'rsvp', 'attendance', 'trials', 'score', 'committed', 'age']; }

  // 🎂 Age group (owner 11/27 "all for sort by age group"): the U-number on
  // the card's age chip (FH season-chart age) — youngest first; no birth date
  // on file sorts at the foot either way.
  static ageNumber(player) {
    const m = /^U(\d+)$/i.exec(String((player && player.ageGroup) || ''));
    return m ? Number(m[1]) : null;
  }

  // ── 📊 🧪 ⭐ Squad-picking sorts (mig 1399, owner 11/16) ─────────────
  // data.selection[personId] = { attended, expected, trials, trialsHeld,
  // rsvpAnswered, rsvpAsked } (fh_selection_scores — practices and trial
  // sessions this club year; 📝 RSVP = practices + games answered, mig 1409);
  // data.selectionPolicy = weights + dues rule.  Each part is 0–1 or null
  // when there is nothing to measure; ⭐ Score = the weighted average of
  // the parts that exist, ×100 (none until a practice or trial counts).
  // Dues use the card's own balance (the
  // same one the dues pill and 💰 Paid status read).
  selectionParts(p) {
    const s = (this._data && this._data.selection && p && p.personId != null) ? this._data.selection[String(p.personId)] : null;
    const pol = (this._data && this._data.selectionPolicy) || null;
    const attendance = s && s.expected > 0 ? s.attended / s.expected : null;
    const trials = s && s.trialsHeld > 0 ? s.trials / s.trialsHeld : null;
    const rsvp = s && s.rsvpAsked > 0 ? s.rsvpAnswered / s.rsvpAsked : null;
    let dues = null;
    const st = RosterScreenBase.paidState(p);
    if (st === 'none') dues = 0;
    else if (st === 'paid') dues = 1;
    else {
      const monthly = pol ? Number(pol.monthlyDues) || 0 : 0;
      const toZero = pol ? Number(pol.duesMonthsToZero) || 2 : 2;
      const months = monthly > 0 ? Math.ceil(Number(p.outstandingBalance) / monthly - 1e-9) : toZero;
      dues = Math.max(0, 1 - months / toZero);
    }
    // No score until there is a practice or trial to measure — dues alone
    // would put a kid who joined today at the top (seen 11/16).
    let score = null;
    if (pol && (attendance != null || trials != null)) {
      let sum = 0, w = 0;
      [[rsvp, pol.rsvpWeight], [trials, pol.trialsWeight], [attendance, pol.attendanceWeight], [dues, pol.duesWeight]].forEach(([v, wt]) => {
        if (v != null && Number(wt) > 0) { sum += v * Number(wt); w += Number(wt); }
      });
      if (w > 0) score = Math.round((sum / w) * 100);
    }
    return { s, rsvp, attendance, trials, dues, score };
  }

  // The chip the 📊 / 🧪 / ⭐ sort puts on each card ('' on other sorts).
  selectionChipHtml(p) {
    const order = this.sortOrder;
    if (!['rsvp', 'attendance', 'trials', 'score'].includes(order) || !p || p.personId == null) return '';
    const esc = RosterScreenBase.escapeHtml;
    const copy = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.block('roster_sheet', tier, tokens)) || fb;
    const parts = this.selectionParts(p);
    const s = parts.s || { attended: 0, expected: 0, trials: 0, trialsHeld: 0, rsvpAnswered: 0, rsvpAsked: 0 };
    const pct = (v) => v == null ? '—' : `${Math.round(v * 100)}%`;
    let txt, tip, v;
    if (order === 'rsvp') {
      v = parts.rsvp;
      txt = copy('board_chip_rsvp', { went: s.rsvpAnswered, of: s.rsvpAsked }, `📝 ${s.rsvpAnswered}/${s.rsvpAsked}`);
      tip = v == null ? copy('board_chip_none_tip', {}, 'Nothing to measure yet') : pct(v);
    } else if (order === 'attendance') {
      v = parts.attendance;
      txt = copy('board_chip_attendance', { went: s.attended, of: s.expected }, `📊 ${s.attended}/${s.expected}`);
      tip = v == null ? copy('board_chip_none_tip', {}, 'Nothing to measure yet') : pct(v);
    } else if (order === 'trials') {
      v = parts.trials;
      txt = copy('board_chip_trials', { went: s.trials, of: s.trialsHeld }, `🧪 ${s.trials}/${s.trialsHeld}`);
      tip = v == null ? copy('board_chip_none_tip', {}, 'Nothing to measure yet') : pct(v);
    } else {
      v = parts.score == null ? null : parts.score / 100;
      txt = copy('board_chip_score', { score: parts.score == null ? '—' : parts.score }, `⭐ ${parts.score == null ? '—' : parts.score}`);
      const tok = {
        rsvp: parts.rsvp == null ? '—' : `${s.rsvpAnswered}/${s.rsvpAsked}`,
        trials: parts.trials == null ? '—' : `${s.trials}/${s.trialsHeld}`,
        attendance: parts.attendance == null ? '—' : `${s.attended}/${s.expected}`,
        dues: pct(parts.dues),
      };
      tip = copy('board_chip_score_tip', tok, `RSVP ${tok.rsvp} · Attendance ${tok.attendance} · Trials ${tok.trials} · Dues ${tok.dues}`);
    }
    const color = v == null ? '#94a3b8' : v >= 0.75 ? '#86efac' : v >= 0.5 ? '#fde68a' : '#fca5a5';
    return `<span title="${esc(tip)}" style="font-size:0.62rem; line-height:1.3; font-weight:800; padding:0 5px; border-radius:8px; background:rgba(148,163,184,0.15); color:${color}; white-space:nowrap;">${esc(txt)}</span>`;
  }

  // desc (owner 11/17 "it needs to sort asc or desc"): tap the lit pill
  // again to flip it.  Direction only redraws — no refetch.
  setSortOrder(value, desc = false) {
    const next = RosterScreenBase.SORT_ORDERS.includes(value) ? value : 'alpha';
    if (next === this.sortOrder && !!desc === !!this._sortDesc) return Promise.resolve();
    const sameOrder = next === this.sortOrder;
    this._sortOrder = next;
    this._sortDesc = !!desc;
    if (sameOrder && this._data && typeof this.renderRoster === 'function') { this.renderRoster(this._data); return Promise.resolve(); }
    return typeof this.load === 'function' ? this.load({ quiet: true }) : Promise.resolve();
  }

  // Sorts whose first-tap order is biggest/best first (shown ↓); the rest
  // start smallest first (A→Z, #1 first — shown ↑).
  static get SORTS_BIG_FIRST() { return ['paid', 'rsvp', 'attendance', 'trials', 'score']; }

  // 🤝 Committed (migs 1551/1554, owner 11/19 "categorize … up to date in rsvp and
  // dues, behind rsvp, behind in dues, behind in both" → "better done as a
  // sort?" → "we already have sort buttons" → "erick david is both and he
  // should be last right?" → "maybe the pill should say 'commited' and then
  // we sort asc" "so most commited"): most committed first — 0 up to date, 1 behind
  // on RSVP (not green), 2 behind on dues, 3 behind on both; 4 = not known
  // yet (PersonStanding not loaded / no access), always at the foot.
  // Practices attended lately (mig 1555) — the tiebreak inside each group,
  // most first (owner 11/19 "commited should also factor in number of
  // practices attended in last 2 weeks").
  static commitPractices(personId) {
    const b = window.PersonStanding && PersonStanding.behind ? PersonStanding.behind(personId) : null;
    return b ? b.practices : 0;
  }
  static commitRank(personId) {
    const b = window.PersonStanding && PersonStanding.behind ? PersonStanding.behind(personId) : null;
    if (!b) return 4;
    return b.rsvp && b.dues ? 3 : b.dues ? 2 : b.rsvp ? 1 : 0;
  }
  static sortArrow(order, flipped) { return (RosterScreenBase.SORTS_BIG_FIRST.includes(order) !== !!flipped) ? '↓' : '↑'; }

  // The lit pill's order, flipped when _sortDesc.  Cards with nothing to
  // sort on (no practices yet, not on the league list) stay at the foot
  // in A–Z either way.
  orderColumnPlayers(players, col) {
    const out = this._orderColumnPlayersFirstTap(players, col);
    if (!this._sortDesc) return out;
    const order = this.sortOrder;
    let missing = () => false;
    if (order === 'committed') {
      missing = (r) => RosterScreenBase.commitRank(r.player.personId) === 4;
    } else if (order === 'age') {
      missing = (r) => RosterScreenBase.ageNumber(r.player) == null;
    } else if (['rsvp', 'attendance', 'trials', 'score'].includes(order)) {
      missing = (r) => this.selectionParts(r.player)[order] == null;
    } else if (order === 'official' && this.officialPositions(col)) {
      const pos = this.officialPositions(col);
      missing = (r) => !pos.has(Number(r.player.personId));
    }
    const have = out.filter(r => !missing(r));
    return [...have.reverse(), ...out.filter(missing)];
  }

  // → [{ player, rank }] in display order; rank is the 1-based coach slot.
  //   alpha    last name, then first
  //   rank     the coach's order (as the server sends it)
  //   paid     owes first (biggest balance first), then no LA, then paid;
  //            A–Z inside each (owner 2026-11-11 "allow for sort by paid status")
  //   official the league website's own order (official_roster_names.sort_order,
  //            the 🌐 mirror — owner: "official order … right from website of
  //            league"); players not on the list follow, A–Z.  Both pills
  //            (officialPositions); a column with no list reads as A–Z.
  // 🌐 Official order: personId → place on the column's league list(s),
  // exactly as the league website lists them.  Team pill (owner 11/17
  // "add sort by official roster … on teams page"): the column's own list,
  // then each folded team's (APSL Active, then Reserve).  null = no list.
  officialPositions(col) {
    if (!col || !col.teamId) return null;
    const cols = (this._data && this._data.columns) || [];
    const ids = [Number(col.teamId)];
    if (this.boardView === 'team') {
      cols.filter(x => Number(x.teamPillFoldInto) === Number(col.teamId))
        .sort((a, b) => Number(a.sortOrder) - Number(b.sortOrder))
        .forEach(x => ids.push(Number(x.teamId)));
    }
    const pos = new Map();
    let base = 0, any = false;
    for (const tid of ids) {
      const list = this.leagueListFor(tid);
      if (!list) continue;
      any = true;
      list.personIds.forEach((id, i) => { if (id != null && !pos.has(Number(id))) pos.set(Number(id), base + i); });
      base += list.personIds.length;
    }
    return any ? pos : null;
  }

  _orderColumnPlayersFirstTap(players, col) {
    const ranked = (players || []).map((player, i) => ({ player, rank: i + 1 }));
    const order = this.sortOrder;
    if (order === 'rank') return ranked;
    const key = (pl) => {
      const last  = (pl.lastName || '').trim();
      const first = (pl.firstName || '').trim();
      // No split name on file → the last word of the full name.
      const fallback = (pl.fullName || '').trim().split(/\s+/).pop() || '';
      return `${last || fallback}\u0000${first}`.toLowerCase();
    };
    const alpha = (a, b) => key(a.player).localeCompare(key(b.player)) || a.rank - b.rank;
    if (order === 'committed') {
      return ranked.sort((a, b) => RosterScreenBase.commitRank(a.player.personId) - RosterScreenBase.commitRank(b.player.personId)
        || RosterScreenBase.commitPractices(b.player.personId) - RosterScreenBase.commitPractices(a.player.personId)
        || alpha(a, b));
    }
    if (order === 'age') {
      return ranked.sort((a, b) => {
        const va = RosterScreenBase.ageNumber(a.player), vb = RosterScreenBase.ageNumber(b.player);
        if (va == null || vb == null) { if (va != null) return -1; if (vb != null) return 1; return alpha(a, b); }
        return (va - vb) || alpha(a, b);
      });
    }
    if (order === 'paid') {
      const w = { owes: 0, none: 1, paid: 2 };
      return ranked.sort((a, b) => {
        const sa = RosterScreenBase.paidState(a.player), sb = RosterScreenBase.paidState(b.player);
        if (sa !== sb) return w[sa] - w[sb];
        if (sa === 'owes') {
          const d = Number(b.player.outstandingBalance || 0) - Number(a.player.outstandingBalance || 0);
          if (d) return d;
        }
        return alpha(a, b);
      });
    }
    if (order === 'rsvp' || order === 'attendance' || order === 'trials' || order === 'score') {
      // Best first; nothing to measure sorts last; ties → more measured, then A–Z.
      const val = (r) => {
        const pt = this.selectionParts(r.player);
        return order === 'rsvp' ? pt.rsvp : order === 'attendance' ? pt.attendance : order === 'trials' ? pt.trials : pt.score;
      };
      const size = (r) => {
        const sel = this.selectionParts(r.player).s;
        return !sel ? 0 : order === 'trials' ? sel.trialsHeld : order === 'rsvp' ? sel.rsvpAsked : sel.expected;
      };
      return ranked.sort((a, b) => {
        const va = val(a), vb = val(b);
        if (va == null || vb == null) { if (va != null) return -1; if (vb != null) return 1; return alpha(a, b); }
        return (vb - va) || (size(b) - size(a)) || alpha(a, b);
      });
    }
    if (order === 'official') {
      const pos = this.officialPositions(col);
      if (pos) {
        const at = (r) => { const v = pos.get(Number(r.player.personId)); return v == null ? 1e9 : v; };
        return ranked.sort((a, b) => (at(a) - at(b)) || alpha(a, b));
      }
    }
    return ranked.sort(alpha);
  }

  // The #N slot picker changed: the column's cards in coach-rank order
  // (data-rank on each picker), with the chosen card moved to its new
  // slot — the list the reorder POST wants.  Rank order, not DOM order,
  // so the picker works in A–Z mode too (owner 2026-09-23: "there is no
  // way to change rank").  In rank mode the DOM is re-sequenced on the
  // spot; in A–Z the cards stay put and the reload repaints the #N chips.
  // null when nothing moved or the card isn't in a coached column.
  slotReorder(select, cardClass, zoneClass) {
    const card = select.closest(`.${cardClass}[data-team-id]`);
    const zone = card && card.closest(`.${zoneClass}[data-drop-team-id]`);
    if (!card || !zone) return null;
    const rankOf = (el) => parseInt(el.querySelector('.roster-position-select')?.dataset.rank, 10) || 0;
    const cardEls = Array.from(zone.querySelectorAll(`.${cardClass}[data-team-id]`))
      .sort((a, b) => rankOf(a) - rankOf(b));
    const fromIdx = cardEls.indexOf(card);
    const toIdx   = parseInt(select.value, 10) - 1;
    if (fromIdx === -1 || !(toIdx >= 0) || toIdx === fromIdx) return null;
    cardEls.splice(fromIdx, 1);
    cardEls.splice(Math.min(toIdx, cardEls.length), 0, card);
    if (this.sortOrder === 'rank') cardEls.forEach(el => zone.appendChild(el));
    return cardEls;
  }

  // Two thin content rows (rank+name, then DOB/age/dues) on the left;
  // the roster-move dropdown and VIEW button sit side by side in a
  // strip on the right that spans the card's full height, using the
  // vertical space row 2 leaves next to it instead of staying
  // thin-and-cramped within row 1 alone.
  // 👻 Last-RSVP chips (PersonStanding, owner 11/3): cards draw what is
  // cached; one fill per render burst loads the rest and paints them.
  _scheduleStandingChips() {
    if (this._standingChipTimer || !window.PersonStanding) return;
    this._standingChipTimer = setTimeout(() => {
      this._standingChipTimer = null;
      // NEEDS ONBOARD + the 📝 Registered line (both pills, every season)
      // hang on who has ever answered — known only once loaded.  Repaint
      // whenever this fill learned it for a card on screen; the repaint's
      // own fill finds nothing new, so it stops there.
      const unknown = [...this.element.querySelectorAll('[data-standing-chip]')]
        .map(e => e.dataset.standingChip).filter(id => PersonStanding.answered(id) === null);
      PersonStanding.fillChips(this.auth, this.element).then(() => {
        const learned = unknown.some(id => PersonStanding.answered(id) !== null);
        if (learned && this._data && typeof this.renderRoster === 'function') this.renderRoster(this._data);
      }).catch(() => {});
    }, 50);
  }

  // The roster-status <select>s the column tallies count — the ones on
  // the cards, never the player sheet's copy of the same picker.
  _cardStatusSelects(teamId) {
    return Array.from(this.element.querySelectorAll(`.mr-status-select[data-team-id="${teamId}"]`))
      .filter(s => !s.closest('.player-sheet'));
  }

  // ⋯ on a card → the player sheet, mounted inside this board's element so
  // the board's own delegated click / change handlers (move, status, role,
  // team status, contact) work on the sheet's pickers too.  Wired once.
  _wirePlayerSheet() {
    if (this._sheetWired || !this.element) return;
    this._sheetWired = true;
    this.element.addEventListener('click', (e) => {
      const btn = e.target.closest('[data-player-sheet]');
      if (!btn || !this.element.contains(btn) || btn.closest('.player-sheet')) return;
      e.preventDefault();
      e.stopPropagation();
      this._openPlayerSheet(btn.getAttribute('data-player-sheet'), btn.getAttribute('data-sheet-tab') || 'teams');
    });
  }

  _openPlayerSheet(key, tab) {
    const entry = () => (this._sheetCards && this._sheetCards.get(key)) || null;
    let last = null;
    PlayerSheet.open({
      host: this.element,
      auth: this.auth,
      tab,
      resolve: () => {
        // After a ⚽ pill move the card he was opened from can be gone
        // (moved off that column): stay on him rather than closing.
        const c = entry();
        if (!c) return last;
        const p = c.player;
        last = {
          personId: p.personId, laUserId: p.leagueAppsUserId,
          firstName: p.firstName || '', lastName: p.lastName || '',
          returnTo: 'teams',
        };
        return last;
      },
      extras: () => {
        const c = entry();
        if (!c) return {};
        const label = c.col && (c.col.shortLabel || c.col.label);
        // The Team status picker is the sheet's own now, for every team he
        // is on (PlayerSheet squadHtml, owner 11/20); this board adds its
        // league-paperwork Roster status and Role for the column's team.
        let own = c.teams || '';
        if (own) {
          const box = document.createElement('div');
          box.innerHTML = own;
          box.querySelectorAll('.mr-team-status').forEach(n => n.remove());
          own = box.innerHTML.trim();
        }
        return {
          teams: own ? `<div style="display:flex; flex-direction:column; gap:6px; align-items:flex-start;">
              ${label ? `<div style="font-size:0.75rem; font-weight:800; opacity:0.75;">${this.escape(RosterScreenBase.dropClubName(label))}</div>` : ''}
              ${own}</div>` : '',
          contact: c.contact || this._sheetContactHtml(c),
        };
      },
      onChange: () => { if (typeof this.load === 'function') this.load({ quiet: true }); },
    });
  }

  // 📇 Contact for a graphic team-card box (owner 11/20 "a bunch of guys
  // are showing [no email or phone]" — clicked from #teams Graphic): the
  // box stores no contact, so draw the board's own list card once and keep
  // its CONTACT button — same recipients (youth → parents), same popup.
  _sheetContactHtml(c) {
    if (!c || !c.player || typeof this.renderPlayer !== 'function') return '';
    if (c.contactBuilt != null) return c.contactBuilt;
    this._capturedContact = '';
    try { this.renderPlayer(c.player, this._tcCols || [], c.col, 0); } catch (e) { /* card draw failed: empty tab */ }
    c.contactBuilt = this._capturedContact || '';
    this._capturedContact = null;
    return c.contactBuilt;
  }

  // The board re-rendered (a save reloads it): the open sheet redraws
  // from the fresh card data.  One redraw per render burst.
  _scheduleSheetRefresh() {
    if (this._sheetRefreshTimer || !window.PlayerSheet || !PlayerSheet.isOpen()) return;
    this._sheetRefreshTimer = setTimeout(() => {
      this._sheetRefreshTimer = null;
      PlayerSheet.refresh();
    }, 0);
  }

  renderCompactCard({
    player,
    col,
    position,
    totalInColumn = 0,
    cardClass,
    cardId,
    rosterSelectHtml = '',
    roleSelectHtml = '',
    statusSelectHtml = '',
    viewButtonHtml = '',
    contactHtml = '',
    duesLabel = '',
    dobShort = '',
    borderColor = RosterScreenBase.NEUTRAL_CARD_BORDER,
    canMove = false,
  }) {
    // The card's # is his SHIRT number (owner 2026-10-29: "they can be
    // replaced with their jersey numbers … leave ability to edit jersey
    // number … if blank just show #") — the #kit board's number for this
    // team's uniform set (data.kitNumbers), never the old coach rank.
    // Editable where the card is (canMove); saved by onJerseyChange.
    const rankEditable = this.sortOrder === 'rank';
    const shirt = (col && col.teamId && player.personId && this._data && this._data.kitNumbers
      && (this._data.kitNumbers[String(col.teamId)] || {})[String(player.personId)]) || '';
    const jerseyChip = (canMove && col && col.teamId && player.personId)
      ? `<span style="font-size:0.72rem; line-height:1.2; color:#fff; font-weight:800; white-space:nowrap;">#<input class="roster-jersey-input" inputmode="numeric" maxlength="3"
           value="${this.escape(shirt)}" data-team-id="${col.teamId}" data-person-id="${player.personId}" title="Shirt number — same as the #kit board"
           style="width:2.2em; min-width:0; min-height:0; padding:0 2px; font-size:0.7rem; font-weight:800; line-height:1.2; border-radius:3px; border:1px solid #475569; background:#0f172a; color:#fff;"></span>`
      : `<span style="font-size:0.72rem; line-height:1.2; color:#fff; font-weight:800; white-space:nowrap;">#${this.escape(shirt)}</span>`;
    // US-Soccer age group (U10, U23, ...) — every roster (youth AND adult,
    // ahead of future U19/U23/Over-30 division work on the mens/womens
    // side).
    // Age chip is colour-coded by gender (blue = boy, pink = girl) so
    // a mixed roster (girls play on boys teams) reads at a glance
    // without a separate chip.  Rendered here in the one shared card
    // component used by every pill (Boys/Girls/Womens/Mens).
    const isFemale = player.gender === 'Female';
    const ageChip = player.ageGroup
      ? `<span style="font-size:0.68rem; line-height:1.2; font-weight:800; letter-spacing:0.02em; padding:0 6px; border-radius:8px; background:${isFemale ? '#db2777' : '#1e3a8a'}; color:${isFemale ? '#fce7f3' : '#dbeafe'}; white-space:nowrap;">${this.escape(player.ageGroup)}</span>`
      : '';
    // Move eligibility is decided by the TeamCard/CoachTeamCard/AdminTeamCard
    // hierarchy (components/TeamCard.js) via _teamCardCapabilities() —
    // players get canMove=false always; coaches get it true only for teams
    // they specifically coach; admins get it true for every column. The
    // backend enforces the same ownership check independently
    // (Controller::canManageTeam) — this is UI-only convenience, not the
    // security boundary.
    // data-person-id rides along with data-user-id so the drag/reorder
    // handler can POST the drift-immune person_id path (see
    // MensTeamAssignments::reorderTeamForPersons) instead of the plain
    // LA userId, which can silently drift out from under a specific
    // player and make their card look stuck / revert on drop.
    // The ids ride on every coached card so the slot picker can find its
    // column-mates in A–Z mode too; draggable="true" — what every drag
    // handler and the grab cursor key off — only in rank mode.
    const dragAttrs = (col && col.teamId && canMove)
      ? `${rankEditable ? 'draggable="true" ' : ''}data-user-id="${player.leagueAppsUserId}" data-team-id="${col.teamId}" data-person-id="${player.personId || ''}"`
      : '';
    // canMove only gates drag-and-drop reordering within a coached column
    // (dragAttrs above) — it's false for Unassigned cards since col.teamId
    // is falsy there, even though renderMoveControl() correctly built a
    // dropdown for them (currentTeamId===0 is an allowed case). Don't wipe
    // rosterSelectHtml based on canMove; renderMoveControl() already
    // decided whether a dropdown belongs on this card.
    const laUidAttr = player.leagueAppsUserId
      ? `data-la-user-id="${player.leagueAppsUserId}"`
      : '';
    // DOB is not drawn (owner 2026-09-17: "drop dob from the card, age chip is
    // enough"); callers may still pass dobShort — it is ignored here.
    const fullName = this.escape(player.fullName || player.firstName || '(no name)') || '(no name)';
    // 👀⚽ and the "also on" team pills folded into the 👁 SEES / 📋 ROSTERS
    // blocks (owner 11/17 "apsl reserves pill NOT in rosters box has to go
    // as does the usasa cup … it all needs to go in rosters box").
    const pickupBadge = this.renderPickupBadge(player);
    // Both modes show the whole name; they differ in where it gets the
    // room to do it.
    //
    // 'scroll' keeps it on one line and lets the column grow sideways
    // (gridStyleFor). 'fit' wraps it — but only at spaces:
    // overflow-wrap:break-word breaks *inside* a word solely when that
    // one word cannot fit on a line of its own. The earlier
    // overflow-wrap:anywhere was what produced the one-letter-per-line
    // columns owner reported 2026-08-26 ("they are written like a letter
    // per line"): 'anywhere' also volunteers every character as a soft
    // break point when the browser measures the box's minimum width, so
    // a name in a side-by-side row could be squeezed to a single glyph
    // and still count as "fitting". break-word makes the longest word
    // the floor instead.
    //
    // The flex sizing differs with it. 'fit' wants the name to shrink and
    // wrap (min-width:0, flex:1). 'scroll' must NOT shrink it: min-width:0
    // lets a flex item go below its own min-content, which is what let the
    // name collapse to a sliver and overlap the buttons, and it also erases
    // the card's min-content contribution — the very number fit-content()
    // sizes the column from. flex:0 0 auto keeps the name at its natural
    // width and makes the column widen to hold it.
    this._scheduleStandingChips();
    this._scheduleSheetRefresh();
    const isScroll = this.viewMode === 'scroll';
    // Same min-width story as colBoxMinWidth(), one level down: every
    // wrapper between the grid track and the name has to keep its
    // intrinsic width in 'scroll', or the track is sized from a card
    // that claims it can be arbitrarily narrow and the name is cut
    // again. 'fit' keeps 0 — there, shrinking is the point.
    const boxMin = isScroll ? 'auto' : '0';

    const statusNow = statusSelectHtml ? (player.rosterStatus || '') : '';
    const statusMeta = statusNow ? RosterScreenBase.rosterStatusByCode(statusNow) : null;
    const statusChip = statusSelectHtml
      // On Roster itself is the 📋 ROSTERS line now (mig 1435, owner 11/17
      // "this would replace the on roster pill"); the moves still chip.
      ? `<span data-roster-status-chip ${statusNow && statusNow !== 'on_roster' ? '' : 'hidden'}
               style="font-size:0.6rem; font-weight:800; line-height:1.3; padding:0 5px; border-radius:3px; white-space:nowrap; ${this.rosterStatusStyle(statusNow)}">${this.escape((statusMeta && statusMeta.displayName) || statusNow)}</span>`
      : '';
    // ⋯ actions menu (owner 2026-09-17: "can we make the buttons on player
    // card on teams in a drop down to save space? so many buttons lol…
    // cards with less height so its easier to see more of roster going
    // down a col").  Everything a coach TAPS — role, profile, contact,
    // link, welcome, registration/docs nudges, and the team / status /
    // role pickers — folds into one popover ("pretty much all the buttons
    // can just go in 1 drop down").  What a coach READS stays on the
    // card: the roster status, as a read-only colour chip (statusChip).
    // The status <select> stays in the DOM inside the closed popover, so
    // the column tallies that count those selects are unaffected.
    // Same <details> popover as the move control, so the shared
    // outside-click closer (installMoveDropdownOutsideClose) shuts it.
    if (this._capturedContact === '') this._capturedContact = contactHtml || '';
    const menuItems = `${rosterSelectHtml}${statusSelectHtml}${roleSelectHtml}${viewButtonHtml}${contactHtml}`.trim();
    const actionsMenu = menuItems
      ? `
      <details class="roster-move-details roster-actions-menu" style="position:relative; display:flex;">
        <summary title="Actions for ${this.escape(player.firstName || 'this player')}"
                 style="list-style:none; display:flex; align-items:center; justify-content:center; padding:0 7px; font-size:0.8rem; font-weight:800; line-height:1.2; border-radius:3px; background:#0f172a; color:#fff; border:1px solid #475569; cursor:pointer; user-select:none;">⋯</summary>
        <div style="position:absolute; top:100%; right:0; z-index:30; margin-top:2px; display:flex; flex-direction:column; align-items:stretch; gap:4px; background:#0f172a; padding:5px; border-radius:4px; box-shadow:0 4px 12px rgba(0,0,0,0.45); border:1px solid #334155; min-width:120px;">
          ${menuItems}
        </div>
      </details>`
      : '';
    // The one player sheet (owner 2026-11-11, player-sheet.js): ⋯ opens
    // the same seven tabs as every other screen, on ⚽ Teams.  The team /
    // status / role pickers ride in that tab, the CONTACT button in 📇
    // Contact; the 👤 tab's own profile buttons replace viewButtonHtml.
    // A hidden copy of the status <select> stays on the card: the column
    // tallies count those (sheet copies are left out) and its chip
    // mirrors it.
    let controls = actionsMenu;
    if (window.PlayerSheet && player.personId && menuItems) {
      const sheetKey = `${cardId}@${(col && col.teamId) || 0}`;
      if (!this._sheetCards) this._sheetCards = new Map();
      this._sheetCards.set(sheetKey, {
        player, col,
        // No move list here (mig 1307): the sheet draws its own ⚽ team
        // pills, the same on every screen.  rosterSelectHtml still
        // decides the ⋯ shows on an Unassigned card (menuItems).
        teams: `${statusSelectHtml}${roleSelectHtml}`.trim(),
        contact: contactHtml || '',
      });
      this._wirePlayerSheet();
      controls = PlayerSheet.button(sheetKey, { tab: 'teams', compact: true })
        + (statusSelectHtml ? `<span hidden data-card-status-copy>${statusSelectHtml}</span>` : '');
    }

    const cardBaseStyle = `background:var(--bg-tertiary, #1f2937); border-radius:5px; padding:1px 5px; border:${borderColor}; min-width:${boxMin};`;

    // ONE row (owner 2026-09-17: "when there is enough space across we
    // should only need 1 row on card as name can go in line"): rank, name,
    // chips, then ⋯ pushed to the right edge.
    //   'scroll' — never wraps; the column widens to hold the row, so
    //              every card is exactly one line tall.
    //   'fit'    — the same row, allowed to wrap: one line when the column
    //              is wide enough, and the chips drop under the name only
    //              when it is not.  The name keeps a floor (its longest
    //              word, via overflow-wrap:break-word) so a narrow column
    //              wraps the chips away rather than crushing the name to a
    //              letter per line.
    const nameStyle = isScroll
      ? 'flex:0 0 auto; white-space:nowrap;'
      : 'flex:1 1 auto; min-width:min-content; white-space:normal; overflow-wrap:break-word;';
    return `
      <div id="${cardId}" class="${cardClass}" data-roster-card ${dragAttrs} ${laUidAttr}
           style="${cardBaseStyle} display:flex; flex-direction:column;">
       <div style="display:flex; flex-direction:row; align-items:center; gap:4px; flex-wrap:${isScroll ? 'nowrap' : 'wrap'}; row-gap:1px;">
        ${jerseyChip}
        <strong style="font-size:0.72rem; line-height:1.2; ${nameStyle}">${fullName}</strong>
        ${player.nameChipHtml || ''}
        ${ageChip}
        ${duesLabel}
        ${this.selectionChipHtml(player)}
        ${window.PersonStanding && player.personId ? `<span data-standing-chip="${player.personId}" data-standing-inactive="${this.boardView === 'roster' ? '0' : '1'}" style="display:inline-flex; gap:3px; align-items:center;">${PersonStanding.chip(player.personId, { inactive: this.boardView !== 'roster' })}</span>` : ''}
        ${statusChip}
        ${this.renderHealthChip(player)}
        ${pickupBadge}
        <span style="display:inline-flex; align-items:stretch; margin-left:auto;">${controls}</span>
       </div>
        ${this.seesRostersHtml(player.personId)}
      </div>
    `;
  }

  // ── Bulk messaging (owner 2026-08-27) ──────────────────────────────
  //
  // Who a message actually goes to. Boys/Girls override this to route
  // at the parent; Mens/Womens take the default and reach the player.
  // RosterMessaging never guesses — every board states its own rule.
  contactFor(p) {
    return {
      phone: (p && p.phone) || null,
      email: (p && p.email) || null,
    };
  }

  // ── Per-card registration-link buttons (owner 2026-08-31) ──────────
  //
  // "Fill out this league form right away" nudges — one SMS button +
  // one EMAIL button per preset in `presets` (owner 2026-08-31: "we
  // need email and text buttons for both" — flat, one tap each, not
  // tucked behind a popover), pre-filled with that preset's body/link,
  // addressed to contactFor(p) (or an explicit {phone,email} override,
  // since callers already have contactPhone/contactEmail computed).
  // Mirrors the boys docsPreset: each program subclass owns
  // its own preset list (its league forms differ) and just calls this
  // method from renderPlayer — Mens goes first with
  // message_templates kind=registration rows (migration 356); Boys/Girls/
  // Womens can opt in later by adding
  // their own list and one call site, no changes here.
  renderRegistrationButtons(p, presets, { phone = null, email = null } = {}) {
    const list = (presets || []).filter(Boolean);
    if (!list.length) return '';
    const contact = (phone || email) ? { phone, email } : this.contactFor(p);
    const contactPhone = contact.phone || null;
    const contactEmail = contact.email || null;
    if (!contactPhone && !contactEmail) return '';

    const btnBase = 'padding:0 4px; font-size:0.6rem; font-weight:800; letter-spacing:0.02em; border-radius:3px; line-height:1.2; white-space:nowrap; border:none; text-decoration:none; display:inline-flex; align-items:center; gap:3px;';

    return list.map(preset => {
      const label     = this.escape(preset.label);
      const smsHref   = contactPhone ? this.buildSmsComposeHref({ to: contactPhone, body: preset.body }) : null;
      const emailHref = contactEmail ? this.buildGmailComposeHref({ to: contactEmail, subject: preset.subject, body: preset.body }) : null;
      const smsBtn = smsHref
        ? `<a href="${smsHref}" title="Text ${this.escape(this.formatPhone(contactPhone))} — ${label}" style="${btnBase} background:#334155; color:#fff;">💬 ${label}</a>`
        : '';
      const emailBtn = emailHref
        ? `<a href="${emailHref}" target="_blank" rel="noopener noreferrer" title="Email ${this.escape(contactEmail)} — ${label}" style="${btnBase} background:#334155; color:#fff;">✉ ${label}</a>`
        : '';
      return smsBtn + emailBtn;
    }).join('');
  }

  // ── Per-card magic sign-in link buttons (owner 2026-09-05) ─────────
  //
  // "Any time we send the footballhome link we should send an auth code
  // in the url for that person" — and it has to be universal across
  // men / women / boys / girls, so it lives here and every board's
  // renderPlayer drops one call into its button strip.
  //
  // One 💬 LINK + one ✉ LINK button per card. Click → POST
  // /api/auth/magic-link/mint for {person_id, channel, contact} (no
  // event — the token is a person credential; verify lands on
  // #calendar and sets the one-year sliding fh_sess cookie) → open the
  // returned Gmail-compose / sms: href in the admin's own client.
  //
  // personId: who gets signed in. Youth boards pass the PARENT's
  // persons.id (p.parentPersonId) because the parent is the one who
  // RSVPs; adult boards pass the player's own. Contact defaults to
  // contactFor(p), which the youth boards already route at the parent.
  renderMagicLinkButtons(p, { personId = null, phone = null, email = null } = {}) {
    const pid = Number(personId || (p && p.personId) || 0);
    if (!pid) return '';
    const contact = (phone || email) ? { phone, email } : this.contactFor(p);
    const contactPhone = contact.phone || null;
    const contactEmail = contact.email || null;
    if (!contactPhone && !contactEmail) return '';

    const who = (p && p.firstName) ? ` for ${this.escape(p.firstName)}` : '';
    const btnBase = 'padding:0 4px; font-size:0.6rem; font-weight:800; letter-spacing:0.02em; border-radius:3px; line-height:1.2; white-space:nowrap; border:none; cursor:pointer; display:inline-flex; align-items:center; gap:3px; background:#0f766e; color:#fff; appearance:none; -webkit-appearance:none; min-height:0; margin:0;';
    const btn = (channel, contact, icon, title) => `
      <button type="button" class="rb-magic-link"
              data-magic-link="${channel}"
              data-person-id="${pid}"
              data-contact="${this.escape(contact)}"
              title="${title}"
              style="${btnBase}">${icon} LINK</button>`;
    const smsBtn = contactPhone
      ? btn('sms', contactPhone, '💬',
            `Text a sign-in link to ${this.escape(this.formatPhone(contactPhone))}${who} (no password; signs them in for a year)`)
      : '';
    const emailBtn = contactEmail
      ? btn('email', contactEmail, '✉',
            `Email a sign-in link to ${this.escape(contactEmail)}${who} (no password; signs them in for a year)`)
      : '';
    return smsBtn + emailBtn;
  }

  // ── One CONTACT button (owner 2026-11-02) ──────────────────────────
  //
  // "should be one contact button. get rid of links and they go in
  // contact popup": the card's ⋯ menu carries one button; everything else
  // lives in the shared ContactPopup (components/contact-popup.js).
  // Boards hand it recipients and their board's own messages.  Fuchsia
  // while a welcome is owed, and the welcome is then the preselected
  // message.  Everyone gets it (owner 11/11: "we should never show a
  // person without a contact button") — with no phone or email the popup
  // greys each route with its reason and still offers 📋 Copy.
  renderContactButton(p, { recipients, section, parentFirst = '', needsDocs = false, context = [], vcard = null, title = '' }) {
    if (!window.ContactPopup || !window.SectionContact) return '';
    const people = (recipients || []).filter(r => r.personId && (r.phone || r.email));
    if (!people.length && p && p.personId) people.push({ personId: p.personId, name: `${p.firstName || ''} ${p.lastName || ''}`.trim() || p.name || '', phone: null, email: null, forPersonId: p.personId });
    if (!people.length) return '';
    const due = !!(p.welcome && p.welcome.due);
    const key = `teams:${this.constructor.name}:${p.personId}`;
    // The section's one list (components/section-contact.js, owner
    // 2026-11-03) — the same popup Event Center and Game Center draw.
    const list = SectionContact.messages(section, {
      screen: this, playerId: p.personId, first: p.firstName || '', parentFirst, needsDocs, context,
      onWelcomeSent: (data) => {
        if (data && data.welcome) p.welcome = data.welcome;
        document.querySelectorAll(`[data-contact-popup="${key}"]`).forEach(b => { b.style.background = '#334155'; });
      },
    });
    return ContactPopup.button({
      key,
      screen: this,
      recipients: people,
      messages: list,
      defaultKey: due ? 'welcome' : list[0].key,
      flagged: due,
      title,
      vcard,
    });
  }

  // A compose-link preset (message_templates row) as a popup message.
  presetMessage(preset) {
    return { key: `reg:${preset.label}`, label: preset.label, subject: preset.subject, body: preset.body };
  }

  async _mintHref(url, payload, channel) {
    const res = await this.auth.fetch(url, {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload),
    });
    if (!res.ok) throw new Error((await res.text()).slice(0, 200) || `HTTP ${res.status}`);
    const data = await res.json();
    const href = channel === 'email' ? (data.gmail_href || data.mailto_href) : data.sms_href;
    if (!href) throw new Error('No message came back');
    return { ...data, href };
  }

  // Recipient may be a parent; the card's player is named in the copy.
  welcomeMessage(p) {
    const needsDocs = !!p.welcomeNeedsDocs;
    return {
      key: 'welcome',
      label: MessageCopy.block('contact_popup', 'msg_welcome') || '👋 Welcome',
      resolve: (r, channel) => this._mintHref('/api/welcomes', {
        person_id: r.personId,
        player_person_id: r.personId !== p.personId ? p.personId : null,
        channel,
        contact: channel === 'email' ? r.email : r.phone,
        needs_docs: needsDocs,
      }, channel),
      onSent: (data) => {
        if (data && data.welcome) p.welcome = data.welcome;
        document.querySelectorAll(`[data-contact-popup="teams:${this.constructor.name}:${p.personId}"]`)
          .forEach(b => { b.style.background = '#334155'; });
      },
    };
  }

  // ── Per-card WELCOME buttons (owner 2026-09-06) ─────────────────────
  //
  // "We need a welcome to Lighthouse email after they sign up … a button
  // for it … only from this date forward for new players … consistent
  // for all clubs … allow to send always even if already sent but show
  // last send and method."
  //
  // One ✉ WELCOME + one 💬 WELCOME button per card, always rendered
  // when the card has a contact.  The backend decides whether a welcome
  // is OWED (p.welcome.due — registered on/after the policy cutoff and
  // never welcomed) and the buttons go fuchsia (owner 2026-09-06: "so it stands out") so the card reads as a
  // to-do; once sent they drop back to slate and a "👋 ✉ Sep 6" pill
  // shows the last send + channel.  Sends are recorded per RECIPIENT
  // (person_welcomes) so welcoming a family through one child covers
  // the siblings.
  //
  // personId: who RECEIVES the welcome and gets signed in by the magic
  // link inside it — the parent on youth boards, the player on adult
  // boards.  playerPersonId: the child the youth copy names.
  // needsDocs (youth travel columns only): the welcome gains a paragraph
  // asking for the travel documents upload.  The form link is the
  // server's business — a club_forms row (migration 365).
  renderWelcomeButtons(p, { personId = null, playerPersonId = null, phone = null, email = null, needsDocs = false } = {}) {
    const pid = Number(personId || (p && p.personId) || 0);
    if (!pid) return '';
    const contact = (phone || email) ? { phone, email } : this.contactFor(p);
    const contactPhone = contact.phone || null;
    const contactEmail = contact.email || null;
    if (!contactPhone && !contactEmail) return '';

    const w    = (p && p.welcome) || {};
    const due  = !!w.due;
    const who  = (p && p.firstName) ? ` for ${this.escape(p.firstName)}` : '';
    const bg   = due ? '#c026d3' : '#334155';
    const btnBase = `padding:0 4px; font-size:0.6rem; font-weight:800; letter-spacing:0.02em; border-radius:3px; line-height:1.2; white-space:nowrap; border:none; cursor:pointer; display:inline-flex; align-items:center; gap:3px; background:${bg}; color:#fff; appearance:none; -webkit-appearance:none; min-height:0; margin:0;`;
    const btn = (channel, to, icon, title) => `
      <button type="button" class="rb-welcome"
              data-welcome="${channel}"
              data-person-id="${pid}"
              data-player-person-id="${Number(playerPersonId || 0) || ''}"
              data-contact="${this.escape(to)}"
              data-needs-docs="${needsDocs ? '1' : ''}"
              title="${title}"
              style="${btnBase}">${icon} WELCOME</button>`;
    const dueNote = due ? ' — welcome not sent yet' : '';
    const smsBtn = contactPhone
      ? btn('sms', contactPhone, '💬',
            `Text the Lighthouse welcome (with sign-in link) to ${this.escape(this.formatPhone(contactPhone))}${who}${dueNote}`)
      : '';
    const emailBtn = contactEmail
      ? btn('email', contactEmail, '✉',
            `Email the Lighthouse welcome (with sign-in link) to ${this.escape(contactEmail)}${who}${dueNote}`)
      : '';
    return `<span class="rb-welcome-wrap" style="display:inline-flex; align-items:center; gap:3px;">`
         + `<span class="rb-welcome-last">${RosterScreenBase.renderWelcomeLastPill(w)}</span>`
         + smsBtn + emailBtn
         + `</span>`;
  }

  // "👋 ✉ Sep 6" — last welcome send + channel.  Empty when never sent.
  static renderWelcomeLastPill(w) {
    if (!w || !w.lastSentAt) return '';
    const icon = w.lastChannel === 'sms' ? '💬' : '✉';
    const chan = w.lastChannel === 'sms' ? 'texted' : 'emailed';
    let abs = String(w.lastSentAt);
    let short = abs;
    try {
      const d = new Date(w.lastSentAt);
      if (!isNaN(d.getTime())) {
        abs   = new Intl.DateTimeFormat('en-US', { timeZone: 'America/New_York', month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' }).format(d);
        short = new Intl.DateTimeFormat('en-US', { timeZone: 'America/New_York', month: 'short', day: 'numeric' }).format(d);
      }
    } catch { /* keep raw iso */ }
    const to  = w.lastContact ? ` to ${w.lastContact}` : '';
    const tip = `Welcome ${chan} ${abs}${to}`;
    return `<span title="${tip.replace(/"/g, '&quot;')}"
                  style="display:inline-flex; align-items:center; gap:3px; padding:0 5px; border:1px solid #334155; background:#0f172a; color:#94a3b8; border-radius:3px; font-size:0.6rem; font-weight:700; letter-spacing:0.02em; white-space:nowrap; line-height:1.2; font-variant-numeric:tabular-nums;">👋 ${icon} ${short}</span>`;
  }

  // Click handler for renderWelcomeButtons.  POST /api/welcomes mints
  // the magic link, records the send, and hands back the compose href;
  // the card repaints in place (pill + slate buttons) so the to-do
  // clears without a roster reload.
  async _onWelcomeClick(btn) {
    const channel        = String(btn.dataset.welcome || '');
    const personId       = parseInt(btn.dataset.personId, 10);
    const playerPersonId = parseInt(btn.dataset.playerPersonId, 10) || 0;
    const contact        = String(btn.dataset.contact || '').trim();
    const needsDocs      = btn.dataset.needsDocs === '1';
    if (!channel || !personId || !contact) return;

    const originalText = btn.innerHTML;
    btn.disabled = true;
    btn.style.opacity = '0.5';
    btn.innerHTML = '⏳';
    try {
      const res = await this.auth.fetch('/api/welcomes', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({
          person_id: personId,
          player_person_id: playerPersonId || null,
          channel,
          contact,
          needs_docs: needsDocs,
        }),
      });
      if (!res.ok) {
        const txt = await res.text();
        throw new Error(txt.slice(0, 200) || `HTTP ${res.status}`);
      }
      const data = await res.json();
      if (channel === 'email') {
        const href = data.gmail_href || data.mailto_href;
        if (!href) throw new Error('No email href returned');
        window.open(href, '_blank', 'noopener');
      } else {
        const href = data.sms_href;
        if (!href) throw new Error('No SMS href returned');
        window.location.href = href;
      }
      btn.innerHTML = '✓';
      // Repaint this card's welcome cluster: pill + no-longer-due colour.
      const wrap = btn.closest('.rb-welcome-wrap');
      if (wrap) {
        const slot = wrap.querySelector('.rb-welcome-last');
        if (slot) slot.innerHTML = RosterScreenBase.renderWelcomeLastPill(data.welcome || {});
        wrap.querySelectorAll('.rb-welcome').forEach(b => {
          b.style.background = '#334155';
          b.title = b.title.replace(/ — welcome not sent yet$/, '');
        });
      }
    } catch (err) {
      console.error('welcome send failed:', err);
      alert(`Could not send welcome: ${err.message}`);
    } finally {
      setTimeout(() => {
        btn.disabled = false;
        btn.style.opacity = '';
        btn.innerHTML = originalText;
      }, 1500);
    }
  }

  // Click handler for renderMagicLinkButtons. Wired by wireMessageButtons
  // so every board that already calls that (all four do) gets it free.
  // Mirrors LineupsScreen._onMintLinkClick minus the match/team scope.
  async _onMagicLinkClick(btn) {
    const channel  = String(btn.dataset.magicLink || '');
    const personId = parseInt(btn.dataset.personId, 10);
    const contact  = String(btn.dataset.contact || '').trim();
    if (!channel || !personId || !contact) return;

    const originalText = btn.innerHTML;
    btn.disabled = true;
    btn.style.opacity = '0.5';
    btn.innerHTML = '⏳';
    try {
      const res = await this.auth.fetch('/api/auth/magic-link/mint', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ person_id: personId, channel, contact }),
      });
      if (!res.ok) {
        const txt = await res.text();
        throw new Error(txt.slice(0, 200) || `HTTP ${res.status}`);
      }
      const data = await res.json();
      if (channel === 'email') {
        const href = data.gmail_href || data.mailto_href;
        if (!href) throw new Error('No email href returned');
        window.open(href, '_blank', 'noopener');
      } else {
        const href = data.sms_href;
        if (!href) throw new Error('No SMS href returned');
        window.location.href = href;
      }
      btn.innerHTML = '✓';
    } catch (err) {
      console.error('magic link mint failed:', err);
      alert(`Could not generate sign-in link: ${err.message}`);
    } finally {
      setTimeout(() => {
        btn.disabled = false;
        btn.style.opacity = '';
        btn.innerHTML = originalText;
      }, 1500);
    }
  }

  // Button pair rendered into a team column header and into the board
  // toolbar. `scope` is the human label used in the confirmation toast
  // and the email subject ("U8 Travel", "all boys"). Players are
  // stashed on the instance keyed by token, because a click handler
  // can't carry an array through a data-attribute.
  // 📇 CONTACT for a whole column (owner 11/16: "those email and texts
  // buttons should open by hitting a contact button that is like player
  // one but goes to that whole group").  Same look as a card's 📇
  // button; tapping it opens the column's group sends (💬 text, ✉ email,
  // and any extras such as the youth DOCS ✉) in a small drop-down that
  // floats over the board.  '' when nobody in the column can be reached.
  // { asLabel }: the button IS the column's title (owner 11/16: "the
  // contact on teams can be with the u10 label and the number can do double
  // duty for contact totals and totals on team") — "📇 U10 · 12" (or 12/16
  // with a cap), opening left-aligned under the title.
  groupContactHtml(col, players, extraHtml = '', { asLabel = false } = {}) {
    if (!col || col.isUnassigned) return '';
    const name = String(col.label || '').replace(/^[^\p{L}\p{N}]+/u, '');
    const btns = this.renderMessageButtons(name, players, { compact: true }) + (extraHtml || '');
    if (!btns.trim()) return '';
    const word = (window.MessageCopy && MessageCopy.block('contact_popup', 'button')) || 'CONTACT';
    const n = (players || []).filter(Boolean).length;
    const text = asLabel ? `📇 ${col.label} · ${n}${col.maxRoster != null ? `/${col.maxRoster}` : ''}` : `📇 ${RosterScreenBase.escapeHtml(word)} · ${n}`;
    const look = asLabel ? 'font-size:0.85rem; font-weight:800; line-height:1.3; padding:2px 8px;' : 'font-size:0.68rem; font-weight:800; line-height:1.2; padding:2px 6px;';
    return `<details class="rs-group-contact" style="position:relative;">
        <summary title="${RosterScreenBase.escapeHtml(word)}" style="list-style:none; cursor:pointer; ${look}
          border-radius:3px; color:#fff; background:#334155; white-space:nowrap;">${text}</summary>
        <div style="position:absolute; ${asLabel ? 'left' : 'right'}:0; top:calc(100% + 4px); z-index:30; display:flex; flex-direction:column; align-items:flex-end; gap:6px;
          padding:8px; border-radius:8px; background:#0f172a; border:1px solid #475569; box-shadow:0 8px 24px rgba(0,0,0,0.5);">${btns}</div>
      </details>`;
  }

  // The column title: the 📇 button carrying the label and the head count
  // when anyone in the column can be reached (merged), else the plain label.
  teamHeadHtml(col, players, extraHtml = '', size = '0.85rem') {
    const btn = this.groupContactHtml(col, players, extraHtml, { asLabel: true });
    return btn ? { labelHtml: btn, merged: true } : { labelHtml: `<strong style="font-size:${size};">${col.label}</strong>`, merged: false };
  }

  renderMessageButtons(scope, players, { compact = false, preset = null, channels = null } = {}) {
    if (!window.RosterMessaging) return '';
    const list = (players || []).filter(Boolean);
    if (!list.length) return '';

    const info = RosterMessaging.collect(list, (p) => this.contactFor(p));
    if (!info.phones.length && !info.emails.length) return '';

    // Token is derived from the scope, not a counter: a re-render must
    // OVERWRITE the previous entry for the same column, or the map grows
    // without bound and a click can fire against a stale player list.
    this._msgScopes = this._msgScopes || new Map();
    const token = [String(scope).replace(/\W+/g, '_').toLowerCase() || 'scope',
                   preset ? preset.key : ''].filter(Boolean).join('__');
    this._msgScopes.set(token, { scope, players: list, preset });

    // Local escape: `escape()` is defined on BoysRosterScreen, not here,
    // and Womens extends this base directly.
    const esc = (v) => String(v == null ? '' : v)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;')
      .replace(/>/g, '&gt;').replace(/"/g, '&quot;');

    const pad = compact ? '1px 6px' : '3px 10px';
    const fs  = compact ? '0.7rem' : '0.78rem';
    const icon = preset ? preset.icon : '';
    // `channels` narrows the pair to one button. Used by the boys/girls
    // DOCS row, which is email-only until multi-recipient SMS works:
    // an sms: URL with N numbers is honoured by some Messages clients
    // and silently truncated by others, so bulk text is off and the
    // per-card DOCS 💬/✉ pair (boys-roster renderPlayer, in the ⋯ menu)
    // covers one parent at a time.
    const wants = (kind) => !channels || channels.includes(kind);
    const btn = (kind, label, count, title) => (count === 0 || !wants(kind)) ? '' : `
      <button type="button" class="rb-msg-btn" data-msg-kind="${kind}" data-msg-token="${token}"
              title="${esc(title)}"
              style="font-size:${fs}; font-weight:700; padding:${pad}; border-radius:999px; cursor:pointer;
                     border:none; background:#334155; color:#fff; white-space:nowrap;">
        ${label} ${count}
      </button>`;

    const smsBtn = btn('sms', `${icon}💬`, info.phones.length,
          preset
            ? `${preset.label}: text ${info.phones.length} for ${scope}`
            : `Text ${info.phones.length} recipient${info.phones.length === 1 ? '' : 's'} for ${scope}`);
    const emailBtn = btn('email', `${icon}✉`, info.emails.length,
          preset
            ? `${preset.label}: email ${info.emails.length} for ${scope} (BCC)`
            : `Email ${info.emails.length} recipient${info.emails.length === 1 ? '' : 's'} for ${scope} (BCC)`);
    // Nothing survived the channel filter (e.g. an email-only DOCS row
    // for a column where no parent has an address) — return '' so the
    // caller drops its label row instead of drawing an empty one.
    if (!smsBtn && !emailBtn) return '';

    return `
      <span style="display:inline-flex; gap:4px; align-items:center;">
        ${smsBtn}
        ${emailBtn}
      </span>`;
  }

  // Custom-scheme navigation. An anchor click is honoured in places
  // where assigning window.location.href is not (notably iOS Safari for
  // sms:/tel:). Must be called synchronously from inside a click
  // handler — see the ORDER IS LOAD-BEARING note in the sms branch.
  static openExternal(url) { BulkMessageComposer.openExternal(url); }

  // Human label for a whole-board send ("all boys"). Each board names
  // itself; the base can't infer it.
  boardScopeLabel() {
    return 'this board';
  }

  // Board total for the lit Roster | Team pill (mig 905): each person once,
  // however many columns they sit in.  Roster counts On Roster only, except
  // on a board whose Roster pill lists everyone.
  renderBoardTotal(data, cols) {
    const everyone = this.boardView === 'team' || this.rosterPillShowsEveryone();
    const people = new Set();
    for (const c of (cols || [])) {
      if (c.isUnassigned) continue;
      for (const p of ((data.buckets || {})[String(c.teamId)] || [])) {
        if (everyone || RosterScreenBase.countsAsOnRoster(p.rosterStatus)) people.add(p.personId);
      }
    }
    let n = people.size;
    // The left column on the Roster pill counts its stacks.
    if (this.columnScope === 'unassigned' && this.boardView === 'roster') {
      n = Object.values(this.membersOffRosters(data)).reduce((sum, list) => sum + list.length, 0);
    }
    const copy = (window.MessageCopy && MessageCopy.block('roster_sheet', 'board_total', { n })) || `${n} players`;
    return `<span data-board-total style="font-size:0.85rem; font-weight:700;">${copy}</span>`;
  }

  // Board-wide pair: every player in this panel's columns, deduped by
  // person (a player sitting in two team columns is one recipient, and
  // siblings sharing a parent collapse to one number/address).
  //
  // Deliberately keyed off `cols` — the panel's full scope — not the
  // team-focus subset. "ALL" means all; when a coach wants one team
  // they have that team's own buttons in its column header.
  renderBoardMessageButtons(data, cols) {
    if (!window.RosterMessaging) return '';
    const players = [];
    for (const c of (cols || [])) {
      if (c.isUnassigned) players.push(...(data.unassigned || []));
      else players.push(...(((data.buckets || {})[String(c.teamId)]) || []));
    }
    const btns = this.renderMessageButtons(this.boardScopeLabel(), players);
    if (!btns) return '';
    return `
      <span style="display:inline-flex; align-items:center; gap:6px; margin-left:auto;">
        <span style="opacity:0.7; font-size:0.8rem; font-weight:600; text-transform:uppercase;">All ${this.boardScopeLabel().replace(/^all /, '')}:</span>
        ${btns}
      </span>`;
  }

  // One delegated listener per screen element. Call from onEnter.
  wireMessageButtons(root) {
    const el = root || this.element;
    if (!el || el._rbMsgWired) return;
    el._rbMsgWired = true;
    el.addEventListener('click', (e) => {
      const linkBtn = e.target.closest('.rb-magic-link');
      if (linkBtn && el.contains(linkBtn)) {
        e.preventDefault();
        e.stopPropagation();
        if (!linkBtn.disabled) this._onMagicLinkClick(linkBtn);
        return;
      }
      const welcomeBtn = e.target.closest('.rb-welcome');
      if (welcomeBtn && el.contains(welcomeBtn)) {
        e.preventDefault();
        e.stopPropagation();
        if (!welcomeBtn.disabled) this._onWelcomeClick(welcomeBtn);
        return;
      }
      const btn = e.target.closest('.rb-msg-btn');
      if (!btn || !el.contains(btn)) return;
      e.preventDefault();
      e.stopPropagation();
      this._handleMessageClick(btn);
    });
  }

  async _handleMessageClick(btn) {
    const entry = this._msgScopes && this._msgScopes.get(btn.dataset.msgToken);
    if (!entry) return;
    const kind = btn.dataset.msgKind;
    const info = RosterMessaging.collect(entry.players, (p) => this.contactFor(p));
    if (kind === 'email' ? !info.emails.length : !info.phones.length) return;
    this._openMessageComposer({ btn, entry, kind, info });
  }

  // Compose in FH, then hand off (owner 2026-08-27: "unless we can make
  // message on fh and that gets pasted too?").
  //
  // The two halves travel by different channels and don't collide:
  //   body       → the sms: URL (`sms:?&body=...`, no recipients) or the
  //                Gmail compose `body` param.
  //   recipients → the clipboard, for the operator to paste into To:.
  // The clipboard can only hold one thing, which is exactly why the body
  // goes in the URL instead.
  _openMessageComposer({ btn, entry, kind, info }) {
    // The box itself lives in components/bulk-message-composer.js so
    // Game Center's game buttons share it (2026-09-30).
    BulkMessageComposer.open({
      screen: this, entry, kind, info,
      onSent: (n) => this._flashMsgBtn(btn, `✓ ${n}`),
    });
  }

  // Fallbacks so base helpers (renderMagicLinkButtons et al.) work on a
  // board that hasn't defined its own. Mens/Boys override with the same
  // bodies; Womens relied on there being none until 2026-09-05.
  formatPhone(raw) {
    if (!raw) return '';
    const digits = String(raw).replace(/\D/g, '');
    const ten = digits.length === 11 && digits.startsWith('1') ? digits.slice(1) : digits;
    if (ten.length === 10) return `(${ten.slice(0, 3)}) ${ten.slice(3, 6)}-${ten.slice(6)}`;
    return raw;
  }

  escape(s) {
    if (s == null) return '';
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  // ── Column category pills (✅/📄/🩹/⭐/🌐/👀) — every board ──────────
  //
  // Born on the mens board (owner 2026-10-20: "for each roster have
  // pills with numbers of players"), lifted here 2026-10-22 so Boys/
  // Girls/Womens columns carry the same truth: ✅ active roster,
  // 📄 paper spots, 🩹 injured, ⭐ standing invitees riding the team's
  // games without a list spot, 🌐 the league's own mirrored roster,
  // and the 👀 Sees games filter. The backend ships one payload shape
  // for all boards (RosterBoardExtras.cpp).

  // Boys + Girls boards override: the Roster pill lists every player.
  rosterPillShowsEveryone() { return false; }

  // The shared delegated-click hooks. Each board's click listener calls
  // this first; true = handled, stop there.
  handleRosterPillClicks(e) {
    const officialPill = e.target.closest('.mr-official-pill');
    if (officialPill) { this.onOfficialPillClick(officialPill); return true; }
    const officialRefresh = e.target.closest('.mr-official-refresh');
    if (officialRefresh) { this.onOfficialRefreshClick(officialRefresh); return true; }
    return false;
  }

  // 🌐 Roster pill: show/hide the league site's own roster for a column.
  onOfficialPillClick(btn) {
    const id = parseInt(btn.dataset.teamId, 10);
    this.officialOpen = this.officialOpen || {};
    this.officialOpen[id] = !this.officialOpen[id];
    if (this._data) this.renderRoster(this._data);
  }

  // 🔄 Pull fresh — re-fetch the league's roster (TeamPass sign-in or the
  // CASA sheet) and reload the board so the mirror and counts update.
  async onOfficialRefreshClick(btn) {
    const teamId = parseInt(btn.dataset.teamId, 10);
    if (!teamId) return;
    btn.disabled = true;
    btn.textContent = '… pulling';
    try {
      const res = await this.auth.fetch('/api/mens-roster/official-roster-refresh', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ teamId }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok || data.error) throw new Error(data.error || `HTTP ${res.status}`);
      await this.load({ quiet: true });
    } catch (err) {
      btn.disabled = false;
      btn.textContent = '🔄 Pull fresh';
      alert(`Could not pull the league roster: ${err.message}`);
    }
  }

  // 🌐 Auto-refresh the league-roster mirror on every board load (owner
  // 2026-10-21: "we should be loading from these links on every mens load
  // of #teams … then updating db then displaying"). The board renders the
  // mirrored rows first, each of its columns' sources re-pulls in the
  // background (TeamPass via the scraper proxy can take seconds, so this
  // never blocks the board), the names land in official_roster_names, and
  // ONE quiet reload re-renders from the DB. Quiet loads are background
  // reconciliations — they never re-pull, which also keeps this from
  // looping through its own reload. Failures stay silent here; the
  // panel's 🔄 Pull fresh button is the loud manual path.
  async autoPullOfficialRosters(data, { quiet = false } = {}) {
    if (quiet || this._officialPullInFlight) return;
    const mirrors = data.officialRosters || {};
    // Every ONLINE roster re-pulls, each column independently (owner
    // 2026-10-21: "this should be done for each roster online").
    // club_file sources are uploads — nothing to fetch, pill stays plain.
    const teamIds = (data.columns || [])
      .map(c => c.teamId)
      .filter(id => {
        const m = id && mirrors[String(id)];
        return m && m.system !== 'club_file';
      });
    if (!teamIds.length) return;
    this._officialPullInFlight = true;
    // Pill state per team: 'pulling' (🟡) → 'ok' (green, fresh stamp) or
    // 'fail' (red, the stamp of the list still showing) — owner: "if on
    // #teams load we don't get latest roster we need to show a red label
    // … green one that has time stamp or a yellow loading".
    this._officialPullState = this._officialPullState || {};
    teamIds.forEach(id => { this._officialPullState[id] = 'pulling'; });
    if (this._data) this.renderRoster(this._data);
    try {
      // ONE pull at a time: every TeamPass pull is a fresh sign-in on the
      // same account, and concurrent sign-ins race — the losing session
      // is served the public, grid-less team page and the parse "fails"
      // (seen 10/21: the Reserves pull read "section not on the page"
      // while the APSL pull, same page, succeeded).  Sequential is also
      // kinder to the league site, and each pill flips green/red as its
      // own pull lands.
      let anyFresh = false;
      for (const teamId of teamIds) {
        try {
          const res = await this.auth.fetch('/api/mens-roster/official-roster-refresh', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ teamId }),
          });
          const body = await res.json().catch(() => ({}));
          // Fresh names must actually land to count — a 200 whose parse
          // found nothing keeps yesterday's list (the backend's
          // empty-parse guard, e.g. TeamPass changed its markup 10/21)
          // and has to read as a failure, not a quiet success.
          if (!res.ok || body.error || !(body.names || []).length)
            throw new Error(body.error || `no names parsed (HTTP ${res.status})`);
          this._officialPullState[teamId] = 'ok';
          anyFresh = true;
        } catch (err) {
          this._officialPullState[teamId] = 'fail';
          console.warn(`[roster] official roster auto-pull failed for team ${teamId}:`, err);
        }
        if (this._data) this.renderRoster(this._data);
      }
      if (anyFresh) await this.load({ quiet: true });
    } finally {
      this._officialPullInFlight = false;
    }
  }

  // The column's pill strip plus the filtered body it implies. Returns
  // { pillsHtml, shown, ridersHtml }: boards drop pillsHtml above the
  // player list, render `shown` instead of the raw column players, and
  // append ridersHtml after the list.
  // Is a category's group on screen for this column?  Hidden only when
  // its category pill is switched off (the 👀 Sees games filter went
  // 11/4 — the card's 👀⚽ chip says it per player).
  // Every section always shows (show/hide pills retired 11/16).
  columnCategoryShown() { return true; }

  renderColumnPills(col, players, data) {
    if (col.isUnassigned) return { pillsHtml: '', shown: players, ridersHtml: '' };

    // ↔ Call In (mig 637) is an invite-only row too, but its own
    // category — a same-level player, not a 📄 roster-filler.
    const catOf = (p) => this.columnCategoryOf(p);
    // Show/hide category pills RETIRED (owner 11/16: "we don't need the
    // pills to turn stuff on and off like active, practice etc right?
    // seems like clutter") — every section always shows; old saved
    // hides in localStorage are ignored.
    const off = () => false;
    // 🌐 The league's OWN roster (official_roster_names, mig 620) —
    // TeamPass for APSL, the CASA sheet for Liga 1.  The league's
    // spelling drifts from ours ("Benzig", "Baidel", a dropped "II"),
    // so matching is normalized and tolerant; the panel marks who is on
    // both, who is league-only, and who is on our list but not the
    // league's.  A club_file source with no extracted names yet gets no
    // pill — there is nothing to show and nothing to pull.
    let official = (data.officialRosters && data.officialRosters[String(col.teamId)]) || null;
    if (official && official.system === 'club_file' && !(official.names || []).length) official = null;
    const officialOpen = !!(this.officialOpen && this.officialOpen[col.teamId]);
    let officialPanel = '';
    if (official && officialOpen) {
      const norm = (s) => String(s || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '')
        .replace(/[^a-z ]/g, ' ').replace(/\b(ii|iii|jr|sr)\b/g, '').replace(/\s+/g, ' ').trim();
      const lev = (a, b) => {
        const m = a.length, n = b.length;
        if (Math.abs(m - n) > 2) return 3;
        let prev = Array.from({ length: n + 1 }, (_, j) => j);
        for (let i = 1; i <= m; i++) {
          const cur = [i];
          for (let j = 1; j <= n; j++)
            cur[j] = Math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1));
          prev = cur;
        }
        return prev[n];
      };
      const ours = players.map(p => ({ p, n: norm(p.fullName || `${p.firstName || ''} ${p.lastName || ''}`) }));
      const matched = new Set();
      const rows = (official.names || []).map(name => {
        const o = norm(name);
        let hit = ours.find(x => x.n === o)
          || ours.find(x => x.n && o && (x.n.includes(o) || o.includes(x.n)));
        if (!hit) {
          const ot = o.split(' '); const ol = ot[ot.length - 1] || '', ofi = (ot[0] || '')[0] || '';
          hit = ours.find(x => {
            const t = x.n.split(' '); const l = t[t.length - 1] || '';
            return ofi === ((t[0] || '')[0] || '') && (l === ol || lev(l, ol) <= 2);
          });
        }
        if (hit) matched.add(hit.p);
        return `<div style="display:flex; justify-content:space-between; gap:8px; padding:2px 0; font-size:0.74rem;">
          <span>${hit ? '✓' : '⚠'} ${this.escape(name)}</span>
          ${hit ? '' : `<span style="color:#f59e0b; font-size:0.68rem;">not on our list</span>`}
        </div>`;
      }).join('');
      const missing = players.filter(p => !matched.has(p));
      // club_file names come from an upload — nothing online to re-pull.
      const refreshBtn = official.system === 'club_file' ? '' : `
              <button type="button" class="mr-official-refresh" data-team-id="${col.teamId}"
                style="font-size:0.64rem; font-weight:700; padding:1px 8px; border-radius:999px; cursor:pointer;
                       border:1px solid #60a5fa; background:transparent; color:#60a5fa;">🔄 Pull fresh</button>`;
      officialPanel = `
        <div style="margin:2px 0 8px; padding:7px 9px; border:1px solid rgba(96,165,250,0.5); border-radius:8px; background:rgba(96,165,250,0.07);">
          <div style="display:flex; justify-content:space-between; align-items:center; gap:6px; flex-wrap:wrap; margin-bottom:4px;">
            <span style="font-size:0.7rem; font-weight:800;">🌐 ${this.escape(official.league || 'League')} roster — the site's own list</span>
            <span style="display:inline-flex; gap:6px; align-items:center;">
              <span style="font-size:0.62rem; opacity:0.6;">pulled ${this.escape(official.pulledAt || '—')}</span>
              ${refreshBtn}
            </span>
          </div>
          ${rows || '<div style="font-size:0.74rem; opacity:0.6;">No names pulled yet — tap 🔄 Pull fresh.</div>'}
          ${missing.length ? `<div style="margin-top:5px; font-size:0.68rem; color:#fca5a5;">
            On our list but NOT on the league's: ${this.escape(missing.map(p => p.fullName || `${p.firstName || ''} ${p.lastName || ''}`.trim()).join(', '))}
          </div>` : ''}
        </div>`;
    }
    // Only the 🌐 league-roster pill is left in this row (category
    // show/hide pills retired 11/16).
    const pillsHtml = !official ? '' : `
      <div style="display:flex; gap:4px; flex-wrap:wrap; margin:2px 0 6px;">
        ${(() => {
          // Pull state on the pill itself (owner 2026-10-21): 🟡 amber
          // while this load's pull runs, green ✓ + stamp once fresh names
          // landed, red ⚠ + the stamp of the list we're STILL showing
          // when the pull failed.  No state (club_file, or pull not yet
          // fired) keeps the plain blue pill.
          const st = (this._officialPullState || {})[col.teamId];
          const color = st === 'pulling' ? '#f59e0b' : st === 'ok' ? '#4ade80' : st === 'fail' ? '#f87171' : '#38bdf8';
          const stamp = official.pulledAt || '—';
          const suffix = st === 'pulling' ? ' · pulling…' : st === 'ok' ? ` · ✓ ${stamp}` : st === 'fail' ? ` · ⚠ ${stamp}` : '';
          const title = st === 'fail'
            ? `Could not pull the league's roster just now — still showing the list pulled ${stamp}`
            : st === 'pulling' ? "Pulling the league's own roster…"
            : `${officialOpen ? 'Hide' : 'Show'} the league site's own roster for this team (TeamPass / league sheet) and the drift against our list`;
          return `
          <button type="button" class="mr-official-pill" data-team-id="${col.teamId}"
            title="${this.escape(title)}"
            style="font-size:0.66rem; font-weight:700; padding:1px 8px; border-radius:999px; cursor:pointer; white-space:nowrap;
                   border:1px solid ${color}; background:${officialOpen ? color + '26' : 'transparent'};
                   color:${officialOpen || st ? color : '#64748b'};">🌐 Roster (${(official.names || []).length})${this.escape(suffix)}</button>`;
        })()}
      </div>
      ${officialPanel}`;

    const shown = players.filter(p => !off(catOf(p)));
    const ridersHtml = '';   // ⭐ standing call-downs: the card's 👁 SEES (mig 1450)
    return { pillsHtml, shown, ridersHtml };
  }

  _flashMsgBtn(btn, text) {
    const orig = btn.innerHTML;
    const origW = btn.style.background;
    btn.innerHTML = text;
    btn.style.background = '#10b981';
    btn.style.color = '#0f172a';
    setTimeout(() => {
      btn.innerHTML = orig;
      btn.style.background = origW || 'var(--bg-primary)';
      btn.style.color = 'inherit';
    }, 2200);
  }
}
