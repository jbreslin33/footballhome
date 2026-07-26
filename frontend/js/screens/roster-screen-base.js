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

  renderCompactCard({
    player,
    col,
    position,
    cardClass,
    cardId,
    actionHtml,
    metaHtml = '',
    duesLabel = '',
    dobShort = '',
    borderColor = '2px solid #facc15',
  }) {
    const posChip = position
      ? `<span style="font-size:0.72rem; color:#fff; font-weight:800; letter-spacing:0.02em; white-space:nowrap;">#${position}</span>`
      : '';
    const dragAttrs = col && col.teamId
      ? `draggable="true" data-user-id="${player.leagueAppsUserId}" data-team-id="${col.teamId}"`
      : '';
    const laUidAttr = player.leagueAppsUserId
      ? `data-la-user-id="${player.leagueAppsUserId}"`
      : '';
    const dobMarkup = dobShort
      ? `<span style="font-size:0.68rem; color:#fff; white-space:nowrap; opacity:0.8;">${this.escape(dobShort)}</span>`
      : '';
    const fullName = this.escape(player.fullName || player.firstName || '(no name)') || '(no name)';

    return `
      <div id="${cardId}" class="${cardClass}" ${dragAttrs} ${laUidAttr} style="background:var(--bg-tertiary, #1f2937); border-radius:5px; padding:3px 5px; border:${borderColor}; min-width:0;">
        <div style="display:flex; align-items:center; gap:4px; min-width:0; flex-wrap:wrap; row-gap:3px;">
          ${posChip}
          <strong style="font-size:0.72rem; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; flex:1;">${fullName}</strong>
          ${dobMarkup}
          ${duesLabel}
          ${metaHtml}
          ${actionHtml}
        </div>
      </div>
    `;
  }
}
