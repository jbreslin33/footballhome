class RosterScreenBase extends Screen {
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
  renderDuesLabel(player) {
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

    const activeTarget = targets.find(t => t.id === currentTeamId) || targets[0];
    const optBtns = targets.map(t => {
      const active = t.id === currentTeamId;
      const style = active
        ? `background:${t.color}; color:#fff; border:1px solid ${t.color}; cursor:default; opacity:0.85;`
        : `background:transparent; color:${t.color}; border:1px dashed ${t.color}88; cursor:pointer;`;
      return `<button class="roster-move-option" type="button"
                      data-user-id="${player.leagueAppsUserId}"
                      data-target-team-id="${t.id}"
                      data-current-team-id="${currentTeamId}"
                      ${active ? 'disabled' : ''}
                      title="${active ? 'Currently on ' + t.label : 'Move to ' + t.label}"
                      style="${btnBase} ${style} text-align:left;">
                ${active ? '✓ ' : ''}${t.label.toUpperCase()}
              </button>`;
    }).join('');
    return `
      <details class="roster-move-details" style="position:relative; display:inline-block;">
        <summary style="${btnBase} background:${activeTarget.color}; color:#fff; border:1px solid ${activeTarget.color}; cursor:pointer; user-select:none;"
                 title="Move ${this.escape(player.firstName || 'player')} to another column">
          ${this.escape(activeTarget.label.toUpperCase())} ▾
        </summary>
        <div style="position:absolute; top:100%; left:0; z-index:20; margin-top:2px; display:flex; flex-direction:column; gap:2px; background:#0f172a; padding:3px; border-radius:4px; box-shadow:0 4px 12px rgba(0,0,0,0.45); border:1px solid #334155; min-width:100%;">
          ${optBtns}
        </div>
      </details>`;
  }

  // Exactly two thin rows. Row 1: [rank] [name] ... [roster-move dropdown]
  // pinned to the far right. Row 2: [DOB] [age group] [dues] ... [view
  // button] pinned to the far right.
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
    const ageChip = player.ageGroup
      ? `<span style="font-size:0.68rem; line-height:1.2; font-weight:800; letter-spacing:0.02em; padding:0 6px; border-radius:8px; background:#1e3a8a; color:#dbeafe; white-space:nowrap;">${this.escape(player.ageGroup)}</span>`
      : '';
    const dragAttrs = col && col.teamId
      ? `draggable="true" data-user-id="${player.leagueAppsUserId}" data-team-id="${col.teamId}"`
      : '';
    const laUidAttr = player.leagueAppsUserId
      ? `data-la-user-id="${player.leagueAppsUserId}"`
      : '';
    const dobMarkup = dobShort
      ? `<span style="font-size:0.66rem; line-height:1.2; color:#fff; white-space:nowrap; opacity:0.8;">${this.escape(dobShort)}</span>`
      : '';
    const fullName = this.escape(player.fullName || player.firstName || '(no name)') || '(no name)';

    return `
      <div id="${cardId}" class="${cardClass}" ${dragAttrs} ${laUidAttr} style="background:var(--bg-tertiary, #1f2937); border-radius:5px; padding:1px 5px; border:${borderColor}; min-width:0; display:flex; flex-direction:column; gap:0;">
        <div style="display:flex; align-items:center; gap:4px; min-width:0;">
          ${posChip}
          <strong style="font-size:0.72rem; line-height:1.2; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; flex:1;">${fullName}</strong>
          ${rosterSelectHtml}
        </div>
        <div style="display:flex; align-items:center; gap:4px; min-width:0;">
          <div style="display:flex; align-items:center; gap:4px; min-width:0; flex-wrap:wrap; row-gap:1px; flex:1;">
            ${dobMarkup}
            ${ageChip}
            ${duesLabel}
          </div>
          ${viewButtonHtml}
        </div>
      </div>
    `;
  }
}
