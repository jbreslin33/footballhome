// BoysRosterScreen — Boys/Girls dashboard sibling of MensRosterScreen.
//
// Pulls kids from BOTH the LeagueApps Boys Club and Girls Club programs
// via GET /api/boys-roster (backed by BoysRoster.cpp).  The screen mirrors
// the mens Roster Board's column-based layout: kids go into one of
//   Lighthouse League · U8 Boys · U10 Boys · U12 Boys · Purgatory
// via a per-card "Move ▾" dropdown (POST /api/boys-roster/assign).
//
// Card differences from mens:
//   • No dues / overdue / lastPaid pills — youth billing lives elsewhere.
//   • Two identity chips: a real-age chip ("U10") derived from the kid's
//     DOB (Aug 1 cutover) and a gender chip (♂ Boy / ♀ Girl).  Both help
//     the coach spot the "U10 girl playing on U10 Boys" case at a glance.
//
// Backing store: roster_columns / roster_assignments filtered to
// domain='boys'.  All mutex logic + coach-sort ordering is inherited from
// MensTeamColumns / MensTeamAssignments (parametrised by domain).
class BoysRosterScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .br-card { background: var(--color-surface-alt, #1f2937); border: 1px solid var(--color-border, #374151); border-radius: 6px; padding: 8px 10px; margin-bottom: 8px; font-size: 13px; line-height: 1.35; }
        .br-card .br-name { font-weight: 700; font-size: 14px; margin-bottom: 4px; }
        .br-chip-row { display: flex; flex-wrap: wrap; gap: 4px; margin-bottom: 6px; }
        .br-chip { display: inline-block; padding: 2px 6px; border-radius: 10px; font-size: 11px; font-weight: 600; letter-spacing: 0.02em; }
        .br-chip-age    { background: #1e3a8a; color: #dbeafe; }
        .br-chip-boy    { background: #1e40af; color: #dbeafe; }
        .br-chip-girl   { background: #831843; color: #fce7f3; }
        .br-chip-dob    { background: #334155; color: #e2e8f0; }
        .br-move { display: inline-block; margin-top: 4px; padding: 3px 8px; font-size: 12px; background: #374151; color: #f3f4f6; border: 1px solid #4b5563; border-radius: 4px; cursor: pointer; }
        .br-move:hover { background: #4b5563; }
        .br-move-menu { position: absolute; z-index: 50; margin-top: 2px; background: #111827; border: 1px solid #374151; border-radius: 4px; padding: 4px 0; min-width: 160px; box-shadow: 0 4px 12px rgba(0,0,0,0.35); }
        .br-move-option { display: block; padding: 6px 12px; color: #f3f4f6; font-size: 12px; cursor: pointer; background: transparent; border: none; text-align: left; width: 100%; }
        .br-move-option:hover { background: #1f2937; }
        .br-move-option.br-current { color: #10b981; font-weight: 700; }
        .br-columns { display: flex; gap: 10px; overflow-x: auto; padding-bottom: 8px; }
        .br-column  { min-width: 240px; max-width: 260px; flex: 0 0 auto; background: #0f172a; border: 1px solid #1e293b; border-radius: 6px; padding: 8px; }
        .br-column-header { font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px; padding: 4px 6px; border-radius: 3px; }
        .br-column-count { float: right; opacity: 0.7; font-weight: 500; }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🎽 Boys Roster</h1>
        <p class="subtitle">Live from LeagueApps — boys + girls (girls play on boys teams for now)</p>
      </div>

      <div style="padding: var(--space-4);">
        <div id="br-banner" style="margin-bottom: var(--space-3); padding: var(--space-3); border-radius: 6px; background: #1f2937; border: 1px solid #374151; display:flex; align-items:center; gap: var(--space-3); flex-wrap: wrap; font-size: 14px;">
          <span id="br-banner-icon" style="font-size: 16px;">⏳</span>
          <span id="br-banner-text" style="flex:1; min-width: 200px;">Pulling latest registrations from LeagueApps…</span>
          <button id="br-refresh" class="btn btn-secondary" style="display:none; padding: 4px 10px; font-size: 13px;">🔄 Refresh</button>
        </div>
        <div id="br-loading" style="text-align:center; padding: var(--space-6); opacity:0.6;">Loading…</div>
        <div id="br-error"   style="display:none; color: var(--color-error); padding: var(--space-4); text-align:center;"></div>
        <div id="br-list"    style="display:none;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter() {
    // Delegated click handling for back / refresh / move-toggle / move-option.
    this.element.addEventListener('click', e => {
      if (e.target.closest('.back-btn'))   return this.navigation.goBack();
      if (e.target.closest('#br-refresh')) return this.load({ refreshLa: true });

      const moveBtn = e.target.closest('.br-move');
      if (moveBtn) {
        e.stopPropagation();
        return this.toggleMoveMenu(moveBtn);
      }

      const moveOpt = e.target.closest('.br-move-option');
      if (moveOpt) {
        e.stopPropagation();
        return this.onMoveOptionClick(moveOpt);
      }

      // Click anywhere else closes any open move menu.
      this.closeAllMoveMenus();
    });

    // Escape closes menus too.
    document.addEventListener('keydown', this._escHandler = e => {
      if (e.key === 'Escape') this.closeAllMoveMenus();
    });

    this.load({ refreshLa: false });
  }

  onExit() {
    if (this._escHandler) {
      document.removeEventListener('keydown', this._escHandler);
      this._escHandler = null;
    }
  }

  async load({ refreshLa } = {}) {
    const banner  = this.element.querySelector('#br-banner');
    const icon    = this.element.querySelector('#br-banner-icon');
    const text    = this.element.querySelector('#br-banner-text');
    const refresh = this.element.querySelector('#br-refresh');
    const loading = this.element.querySelector('#br-loading');
    const errBox  = this.element.querySelector('#br-error');
    const list    = this.element.querySelector('#br-list');

    icon.textContent = '⏳';
    text.textContent = refreshLa
      ? 'Refreshing from LeagueApps…'
      : 'Pulling latest registrations from LeagueApps…';
    refresh.style.display = 'none';
    loading.style.display = 'block';
    errBox.style.display  = 'none';
    list.style.display    = 'none';
    list.innerHTML        = '';

    try {
      const url = refreshLa ? '/api/boys-roster?refreshLa=1' : '/api/boys-roster';
      const res = await this.auth.fetch(url, { cache: 'no-store' });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();

      icon.textContent      = '✅';
      text.textContent      = `${data.total || 0} players · ${data.unassignedCount || 0} unassigned · season end ${data.seasonEndYear || '?'}`;
      refresh.style.display = 'inline-block';
      loading.style.display = 'none';
      list.style.display    = 'block';

      this._data = data;
      this.renderColumns(data);
    } catch (err) {
      icon.textContent      = '❌';
      text.textContent      = 'Load failed — see error below.';
      loading.style.display = 'none';
      errBox.style.display  = 'block';
      errBox.textContent    = err.message || 'Unknown error';
    }
  }

  renderColumns(data) {
    const list = this.element.querySelector('#br-list');
    const cols = (data.columns || []).slice().sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0));

    // Prepend a synthetic "Unassigned" column so kids without a bucket
    // are visible + draggable into a real column.
    const columnsHtml = [
      this.renderColumn({
        teamId: 0,
        label: '📋 Unassigned',
        shortLabel: 'UNASSIGNED',
        color: '#475569',
        mutexGroup: null,
        sortOrder: 0,
        players: data.unassigned || [],
        allColumns: cols,
      }),
      ...cols.map(c => this.renderColumn({
        teamId:     c.teamId,
        label:      c.label,
        shortLabel: c.shortLabel,
        color:      c.color,
        mutexGroup: c.mutexGroup,
        sortOrder:  c.sortOrder,
        players:    (data.buckets && data.buckets[String(c.teamId)]) || [],
        allColumns: cols,
      })),
    ].join('');

    list.innerHTML = `<div class="br-columns">${columnsHtml}</div>`;
  }

  renderColumn(col) {
    const headerBg = col.color || '#334155';
    const players = col.players || [];
    return `
      <div class="br-column" data-team-id="${col.teamId}">
        <div class="br-column-header" style="background:${headerBg}; color:#fff;">
          ${col.label} <span class="br-column-count">${players.length}</span>
        </div>
        ${players.map(p => this.renderCard(p, col, col.allColumns)).join('') || '<div style="opacity:0.5; font-size:12px; text-align:center; padding:6px;">empty</div>'}
      </div>
    `;
  }

  renderCard(p, currentCol, allColumns) {
    const uid       = p.leagueAppsUserId;
    const name      = this.escapeHtml(p.fullName || `${p.firstName || ''} ${p.lastName || ''}`.trim() || '(no name)');
    const ageChip   = p.ageGroup
      ? `<span class="br-chip br-chip-age">${this.escapeHtml(p.ageGroup)}</span>`
      : '';
    const isBoy     = (p.gender || '').toLowerCase().startsWith('m');
    const genderChip = `<span class="br-chip ${isBoy ? 'br-chip-boy' : 'br-chip-girl'}">${isBoy ? '♂ Boy' : '♀ Girl'}</span>`;
    const dobChip   = p.birthDate
      ? `<span class="br-chip br-chip-dob">${this.escapeHtml(p.birthDate)}</span>`
      : '';

    // Move menu: list every configured column + Unassigned.  Current
    // column marked so the coach sees where the kid is now.
    const moveOptions = [
      { teamId: 0, label: '📋 Unassigned' },
      ...allColumns.map(c => ({ teamId: c.teamId, label: c.label })),
    ].map(opt => {
      const isCurrent = opt.teamId === currentCol.teamId;
      return `<button class="br-move-option ${isCurrent ? 'br-current' : ''}" data-uid="${uid}" data-target-team="${opt.teamId}" data-current-team="${currentCol.teamId}">
        ${isCurrent ? '✓ ' : ''}${this.escapeHtml(opt.label)}
      </button>`;
    }).join('');

    return `
      <div class="br-card" data-uid="${uid}">
        <div class="br-name">${name}</div>
        <div class="br-chip-row">${ageChip}${genderChip}${dobChip}</div>
        <div style="position:relative; display:inline-block;">
          <button class="br-move" data-uid="${uid}">Move ▾</button>
          <div class="br-move-menu" style="display:none;">${moveOptions}</div>
        </div>
      </div>
    `;
  }

  toggleMoveMenu(btn) {
    const menu = btn.nextElementSibling;
    const isOpen = menu.style.display !== 'none';
    this.closeAllMoveMenus();
    if (!isOpen) menu.style.display = 'block';
  }

  closeAllMoveMenus() {
    this.element.querySelectorAll('.br-move-menu').forEach(m => (m.style.display = 'none'));
  }

  async onMoveOptionClick(btn) {
    const uid         = Number(btn.dataset.uid);
    const targetTeam  = Number(btn.dataset.targetTeam);
    const currentTeam = Number(btn.dataset.currentTeam);

    if (!uid) return;
    if (targetTeam === currentTeam) {
      this.closeAllMoveMenus();
      return;
    }

    try {
      // "Unassigned" (teamId=0) means remove from the current column.  Any
      // other target is an add — the backend mutex clears the previous
      // column atomically.
      if (targetTeam === 0 && currentTeam > 0) {
        await this.postAssign({ leagueAppsUserId: uid, teamId: currentTeam, action: 'remove' });
      } else if (targetTeam > 0) {
        await this.postAssign({ leagueAppsUserId: uid, teamId: targetTeam, action: 'add' });
      }
      this.closeAllMoveMenus();
      // Re-render from the same cached snapshot with the new assignment.
      // Full refresh (refreshLa=1) would go back to LA; local re-fetch is
      // enough since the assignment write is already durable.
      await this.load({ refreshLa: false });
    } catch (err) {
      alert(`Move failed: ${err.message || err}`);
    }
  }

  async postAssign(body) {
    const res = await this.auth.fetch('/api/boys-roster/assign', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify(body),
    });
    if (!res.ok) {
      const txt = await res.text().catch(() => '');
      throw new Error(`HTTP ${res.status} ${txt}`);
    }
    return res.json();
  }

  escapeHtml(s) {
    return String(s ?? '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }
}
