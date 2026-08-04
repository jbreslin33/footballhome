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

  // Roster-move dropdown: a <details>/<summary> popover showing the
  // player's current column, with click-to-move buttons for every other
  // column plus "Unassigned". Identical for boys/girls/women's/men's —
  // mutex enforcement lives server-side; the frontend only needs the
  // column list. Uses a single shared class name (not per-screen
  // br-/mr- prefixed) because each screen's click listener is delegated
  // on `this.element` (its own DOM subtree), so there's no cross-screen
  // collision risk. The caller still owns click handling (onMoveOptionClick)
  // since that POSTs to a screen-specific endpoint.
  renderMoveDropdown(player, columns) {
    const assignedSet = new Set(player.teamIds || []);
    const configuredIds = new Set((columns || []).map(c => c.teamId));
    let currentTeamId = 0;
    for (const tid of assignedSet) {
      if (configuredIds.has(tid)) { currentTeamId = tid; break; }
    }

    const targets = [
      { id: 0, label: 'Unassigned', color: '#475569' },
      ...(columns || []).map(c => ({
        id:    c.teamId,
        label: c.shortLabel || c.label || `Team ${c.teamId}`,
        color: c.color || '#334155',
      })),
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
      const active = t.id === currentTeamId;
      const style = active
        ? `background:${t.color}; color:#fff; border:1px solid ${t.color}; cursor:pointer; opacity:0.85;`
        : `background:transparent; color:${t.color}; border:1px dashed ${t.color}88; cursor:pointer;`;
      // The active/current option is NOT disabled — clicking it is a
      // same-team no-op in onMoveOptionClick, which now closes the
      // popover before checking that, so clicking your current
      // selection is how you roll the dropdown back up (2026-08-02,
      // user directive) rather than a dead end.
      return `<button class="roster-move-option" type="button"
                      data-user-id="${player.leagueAppsUserId}"
                      data-person-id="${player.personId || ''}"
                      data-target-team-id="${t.id}"
                      data-current-team-id="${currentTeamId}"
                      title="${active ? 'Currently on ' + t.label : 'Move to ' + t.label}"
                      style="${optBtnBase} ${style} text-align:left;">
                ${active ? '✓ ' : ''}${t.label.toUpperCase()}
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
                 title="Move ${this.escape(player.firstName || 'player')} to another column">
          ${this.escape(activeTarget.label.toUpperCase())} ▾
        </summary>
        <div style="position:absolute; top:100%; left:0; z-index:20; margin-top:2px; display:flex; flex-direction:column; gap:2px; background:#0f172a; padding:3px; border-radius:4px; box-shadow:0 4px 12px rgba(0,0,0,0.45); border:1px solid #334155; min-width:100%;">
          ${optBtns}
        </div>
      </details>`;
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
    cardClass,
    cardId,
    rosterSelectHtml = '',
    viewButtonHtml = '',
    duesLabel = '',
    dobShort = '',
    borderColor = '2px solid #facc15',
  }) {
    const posChip = position
      ? `<span style="font-size:0.72rem; line-height:1.2; color:#fff; font-weight:800; letter-spacing:0.02em; white-space:nowrap;">#${position}</span>`
      : '';
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
    // Players get a look-but-don't-touch board — no drag handle, no
    // move dropdown (server-side team assignment has no separate
    // admin check of its own, so the UI is the only gate; see
    // _isPlayerView above).
    const isPlayerView = this._isPlayerView();
    const dragAttrs = (col && col.teamId && !isPlayerView)
      ? `draggable="true" data-user-id="${player.leagueAppsUserId}" data-team-id="${col.teamId}"`
      : '';
    if (isPlayerView) rosterSelectHtml = '';
    const laUidAttr = player.leagueAppsUserId
      ? `data-la-user-id="${player.leagueAppsUserId}"`
      : '';
    const dobMarkup = dobShort
      ? `<span style="font-size:0.66rem; line-height:1.2; color:#fff; white-space:nowrap; opacity:0.8;">${this.escape(dobShort)}</span>`
      : '';
    const fullName = this.escape(player.fullName || player.firstName || '(no name)') || '(no name)';

    return `
      <div id="${cardId}" class="${cardClass}" ${dragAttrs} ${laUidAttr} style="background:var(--bg-tertiary, #1f2937); border-radius:5px; padding:1px 5px; border:${borderColor}; min-width:0; display:flex; flex-direction:row; align-items:stretch; gap:4px;">
        <div style="display:flex; flex-direction:column; gap:0; flex:1; min-width:0;">
          <div style="display:flex; align-items:center; gap:4px; min-width:0;">
            ${posChip}
            <strong style="font-size:0.72rem; line-height:1.2; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; flex:1;">${fullName}</strong>
          </div>
          <div style="display:flex; align-items:center; gap:4px; min-width:0; flex-wrap:wrap; row-gap:1px;">
            ${dobMarkup}
            ${ageChip}
            ${duesLabel}
          </div>
        </div>
        <div style="display:flex; flex-direction:row; align-items:stretch; gap:4px;">
          ${rosterSelectHtml}
          ${viewButtonHtml}
        </div>
      </div>
    `;
  }
}
