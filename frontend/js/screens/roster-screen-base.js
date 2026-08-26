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
  //     (migration 294/295): Not on Roster / Awaiting Approval /
  //     On Roster / Suspended.
  // Keyed by personId (not leagueAppsUserId) — same LA-userId-drift
  // immunity as the reorder/move endpoints; see
  // TeamController::handleSetLineupRoleForPerson /
  // handleSetRosterStatusForPerson.
  renderRoleSelect(player, col, canMove) {
    if (!(canMove && col && col.teamId && player.personId)) return '';
    return `<select class="mr-role-select" data-team-id="${col.teamId}" data-person-id="${player.personId}"
               title="Roster Role — 1st Team Starter/Bench, or 1st Team Reserve for a call-up"
               style="font-size:0.6rem; font-weight:800; letter-spacing:0.01em; padding:0 2px; line-height:1.2; border-radius:3px; border:1px solid #475569; background:#0f172a; color:#fff; max-width:92px;">
         <option value=""        ${!player.lineupRole ? 'selected' : ''}>Role: —</option>
         <option value="starter" ${player.lineupRole === 'starter' ? 'selected' : ''}>1st Team Starter</option>
         <option value="bench"   ${player.lineupRole === 'bench'   ? 'selected' : ''}>1st Team Bench</option>
         <option value="reserve" ${player.lineupRole === 'reserve' ? 'selected' : ''}>1st Team Reserve</option>
       </select>`;
  }

  renderStatusSelect(player, col, canMove) {
    if (!(canMove && col && col.teamId && player.personId)) return '';
    return `<select class="mr-status-select" data-team-id="${col.teamId}" data-person-id="${player.personId}"
               title="Official league roster status"
               style="font-size:0.6rem; font-weight:800; letter-spacing:0.01em; padding:0 2px; line-height:1.2; border-radius:3px; border:1px solid #475569; background:#0f172a; color:#fff; max-width:92px;">
         <option value=""                  ${!player.rosterStatus ? 'selected' : ''}>Status: —</option>
         <option value="not_on_roster"     ${player.rosterStatus === 'not_on_roster'     ? 'selected' : ''}>Not on Roster</option>
         <option value="awaiting_approval" ${player.rosterStatus === 'awaiting_approval' ? 'selected' : ''}>Awaiting Approval</option>
         <option value="on_roster"         ${player.rosterStatus === 'on_roster'         ? 'selected' : ''}>On Roster</option>
         <option value="suspended"         ${player.rosterStatus === 'suspended'         ? 'selected' : ''}>Suspended</option>
       </select>`;
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
    } catch (err) {
      select.value = prevValue;
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
    return `<span style="display:inline-flex; align-items:center; gap:4px; font-size:0.68rem; line-height:1.2; padding:0 6px; border-radius:999px; color:${duesColor}; font-weight:700;">Dues</span>`;
  }

  getCompactCardBorder(days, fallback = '#facc15') {
    if (days >= 4) {
      return `2px solid ${this.daysOverdueColor(days)}`;
    }
    return `2px solid ${fallback}`;
  }

  renderPersonActions(person, { returnTo = '', showEdit = false, btnBaseStyle = '' } = {}) {
    if (!window.PersonActions || !person) return '';
    return window.PersonActions.buttonsHtml(person, {
      returnTo,
      btnBaseStyle,
      showEdit,
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

    // Full team name, not shortLabel (owner 2026-08-25: "in drop down
    // write out full name of team"). The board columns can afford
    // abbreviations because the colour and position carry meaning; a flat
    // list of options cannot, and "U10 Intra" / "U12 Intra" / "U16 Intra"
    // read as near-identical at a glance. `label` may carry a leading
    // emoji (e.g. "⚽ U10 Intramural") — kept, it aids scanning.
    //
    // Sorted by name rather than board order, numeric-aware so U6/U8/U10
    // fall in age order instead of the "U10, U12, U16, U19, U6" a plain
    // string sort produces. Unassigned is pinned first: it is the removal
    // action, not a team, and belongs where the eye lands.
    const teamTargets = (columns || []).map(c => ({
      id:    c.teamId,
      label: c.label || c.shortLabel || `Team ${c.teamId}`,
      color: c.color || '#334155',
    }));
    teamTargets.sort((a, b) =>
      String(a.label).localeCompare(String(b.label), undefined, { numeric: true, sensitivity: 'base' }));

    const targets = [
      { id: 0, label: 'Unassigned', color: '#475569' },
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
        style  = `background:${t.color}; color:#fff; border:1px solid ${t.color}; cursor:pointer; opacity:0.85;`;
        prefix = '✓ ';
        title  = t.id === 0 ? 'Currently unassigned here' : `Currently on ${t.label} (this card)`;
      } else if (alsoAssigned) {
        style  = `background:transparent; color:${t.color}; border:1px solid ${t.color}; cursor:pointer; opacity:0.75;`;
        prefix = '• ';
        title  = `Already on ${t.label} (via another card)`;
      } else {
        style  = `background:transparent; color:${t.color}; border:1px dashed ${t.color}88; cursor:pointer;`;
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
        <summary style="${btnBase} height:100%; display:flex; align-items:center; justify-content:center; background:${activeTarget.color}; color:#fff; border:1px solid ${activeTarget.color}; cursor:pointer; user-select:none;"
                 title="Add ${this.escape(player.firstName || 'player')} to another team, or remove from this one">
          ${this.escape(activeTarget.label.toUpperCase())} ▾
        </summary>
        <div style="position:absolute; top:100%; left:0; z-index:20; margin-top:2px; display:flex; flex-direction:column; gap:2px; background:#0f172a; padding:3px; border-radius:4px; box-shadow:0 4px 12px rgba(0,0,0,0.45); border:1px solid #334155; min-width:100%;">
          ${optBtns}
        </div>
      </details>`;
  }

  // Multi-team badge — flags a player who holds more than one active
  // roster spot (e.g. a boy called up to a mens team, or someone on two
  // mens squads) so it's visually obvious without cross-referencing
  // every board. Only counts teams OTHER than the one this exact card
  // lives in (col.teamId) — that one's already obvious from the column
  // itself. Backed by ActiveTeamBadges (backend/src/models) via
  // player.activeTeams (Boys/Girls/Mens boards) or player.active_teams
  // (Women's Club cards, rosters.js) — covers every gender_category,
  // not just this board's own domain.
  renderActiveTeamsBadge(player, col) {
    const teams = player.activeTeams || player.active_teams || [];
    const currentTeamId = col && col.teamId ? col.teamId : null;
    const others = teams.filter((t) => t && t.teamId !== currentTeamId);
    if (!others.length) return '';
    const icon = { boys: '🧒', girls: '👧', mens: '🧔', womens: '👩' };
    return others.map((t) => {
      const category = t.genderCategory || t.gender_category || '';
      const name = t.name || 'Team';
      return `<span title="Also on ${this.escape(name)}" style="font-size:0.62rem; line-height:1.3; font-weight:700; padding:0 5px; border-radius:8px; background:rgba(168,85,247,0.22); color:#c084fc; white-space:nowrap;">${icon[category] || '⚽'} ${this.escape(name)}</span>`;
    }).join('');
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
    return `<span title="${this.escape(title)}" style="font-size:0.62rem; line-height:1.3; font-weight:700; padding:0 5px; border-radius:8px; background:rgba(245,158,11,0.22); color:#fbbf24; white-space:nowrap;">⚡ Pickup</span>`;
  }

  // Two thin content rows (rank+name, then DOB/age/dues) on the left;
  // the roster-move dropdown and VIEW button sit side by side in a
  // strip on the right that spans the card's full height, using the
  // vertical space row 2 leaves next to it instead of staying
  // thin-and-cramped within row 1 alone.
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
    duesLabel = '',
    dobShort = '',
    borderColor = '2px solid #facc15',
    canMove = false,
  }) {
    const posChip = position
      ? `<span style="font-size:0.72rem; line-height:1.2; color:#fff; font-weight:800; letter-spacing:0.02em; white-space:nowrap;">#${position}</span>`
      : '';
    // Slot picker (2026-08-21) — alternative to drag-reorder ("drag sucks,
    // it fails if you don't drag it just right" — user). Picking a number
    // jumps this card to that slot; the reorder POST (same endpoint drag
    // already uses) rewrites everyone else's rank around it. Real,
    // coached columns only — same gate as drag (canMove + col.teamId) —
    // and only worth showing once there's more than one card to reorder
    // against.
    const posControl = (canMove && col && col.teamId && position && totalInColumn > 1)
      ? `<select class="roster-position-select" data-user-id="${player.leagueAppsUserId}" data-team-id="${col.teamId}" data-person-id="${player.personId || ''}"
                 title="Move ${this.escape(player.firstName || 'player')} to a specific slot — everyone else shifts to make room"
                 style="font-size:0.68rem; font-weight:800; letter-spacing:0.02em; padding:0 1px; line-height:1.2; border-radius:3px; border:1px solid #475569; background:#0f172a; color:#fff;">
           ${Array.from({ length: totalInColumn }, (_, i) => i + 1)
             .map(n => `<option value="${n}" ${n === position ? 'selected' : ''}>#${n}</option>`)
             .join('')}
         </select>`
      : posChip;
    // US-Soccer age group (U10, U23, ...) — every roster (youth AND adult,
    // ahead of future U19/U23/Over-30 division work on the mens/womens
    // side).
    // Age chip is colour-coded by gender (blue = boy, yellow = girl) so
    // a mixed roster (girls play on boys teams) reads at a glance
    // without a separate chip.  Rendered here in the one shared card
    // component used by every pill (Boys/Girls/Womens/Mens).
    const isFemale = player.gender === 'Female';
    const ageChip = player.ageGroup
      ? `<span style="font-size:0.68rem; line-height:1.2; font-weight:800; letter-spacing:0.02em; padding:0 6px; border-radius:8px; background:${isFemale ? '#eab308' : '#1e3a8a'}; color:${isFemale ? '#422006' : '#dbeafe'}; white-space:nowrap;">${this.escape(player.ageGroup)}</span>`
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
    const dragAttrs = (col && col.teamId && canMove)
      ? `draggable="true" data-user-id="${player.leagueAppsUserId}" data-team-id="${col.teamId}" data-person-id="${player.personId || ''}"`
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
    const dobMarkup = dobShort
      ? `<span style="font-size:0.66rem; line-height:1.2; color:#fff; white-space:nowrap; opacity:0.8;">${this.escape(dobShort)}</span>`
      : '';
    const fullName = this.escape(player.fullName || player.firstName || '(no name)') || '(no name)';
    const activeTeamsBadge = this.renderActiveTeamsBadge(player, col);
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
    const isScroll = this.viewMode === 'scroll';
    const nameClipStyle = isScroll
      ? 'flex:0 0 auto; white-space:nowrap;'
      : 'min-width:0; flex:1; white-space:normal; overflow-wrap:break-word;';

    // Same min-width story as colBoxMinWidth(), one level down: every
    // wrapper between the grid track and the name has to keep its
    // intrinsic width in 'scroll', or the track is sized from a card
    // that claims it can be arbitrarily narrow and the name is cut
    // again. 'fit' keeps 0 — there, shrinking is the point.
    const boxMin = isScroll ? 'auto' : '0';

    // In 'fit' the slot picker moves down to the chip row. It is a real
    // <select> and never gets narrower than its widest option, so sharing
    // row 1 with the name left the name ~44px of a 110px card — six lines
    // for one name, the letter-per-line report all over again. One item
    // per line means the name gets the line to itself.
    const nameRow = `
          <div style="display:flex; align-items:center; gap:4px; min-width:${boxMin};">
            ${isScroll ? posControl : ''}
            <strong style="font-size:0.72rem; line-height:1.2; ${nameClipStyle}">${fullName}</strong>
          </div>`;
    const chipRow = `
          <div style="display:flex; align-items:center; gap:4px; min-width:${boxMin}; flex-wrap:wrap; row-gap:1px;">
            ${isScroll ? '' : posControl}
            ${dobMarkup}
            ${ageChip}
            ${duesLabel}
            ${activeTeamsBadge}
            ${pickupBadge}
          </div>`;
    const controls = `${rosterSelectHtml}${roleSelectHtml}${statusSelectHtml}${viewButtonHtml}`;

    const cardBaseStyle = `background:var(--bg-tertiary, #1f2937); border-radius:5px; padding:1px 5px; border:${borderColor}; min-width:${boxMin};`;

    // 'fit' stacks one item per line (owner 2026-08-26: "the fit pill
    // would have to probably do 1 item per line"). In a Fit column —
    // 110px once nine teams are on screen — a side-by-side row hands the
    // name whatever the control strip leaves over, which is nothing. One
    // per line gives the name the card's full width, and the card simply
    // grows taller, which is the trade Fit already advertises.
    if (!isScroll) {
      const controlRow = controls.trim()
        ? `
        <div style="display:flex; flex-direction:row; align-items:center; gap:4px; flex-wrap:wrap; justify-content:flex-end;">
          ${controls}
        </div>`
        : '';
      return `
      <div id="${cardId}" class="${cardClass}" ${dragAttrs} ${laUidAttr} style="${cardBaseStyle} display:flex; flex-direction:column; gap:2px;">
        ${nameRow}
        ${chipRow}${controlRow}
      </div>
    `;
    }

    // 'scroll': name and controls share one row, so the card stays thin
    // ("Scroll should be thin cards since it allows scroll right to
    // left") and the column, not the card, is what stretches to hold the
    // name. The control strip is nowrap here on purpose — wrapping would
    // let the column size itself as if only one button had to fit, and
    // the card holding the longest name would be the one that grew a
    // second row of buttons. Uniform cards is the whole point of Scroll.
    return `
      <div id="${cardId}" class="${cardClass}" ${dragAttrs} ${laUidAttr} style="${cardBaseStyle} display:flex; flex-direction:row; align-items:stretch; gap:4px;">
        <div style="display:flex; flex-direction:column; gap:0; flex:1; min-width:auto;">
          ${nameRow}
          ${chipRow}
        </div>
        <div style="display:flex; flex-direction:row; align-items:stretch; gap:4px; flex-wrap:nowrap; justify-content:flex-end; align-self:flex-start;">
          ${rosterSelectHtml}
          ${roleSelectHtml}
          ${statusSelectHtml}
          ${viewButtonHtml}
        </div>
      </div>
    `;
  }
}
