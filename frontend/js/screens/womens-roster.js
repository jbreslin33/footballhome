// WomensRosterScreen — Live Women's Club roster pulled from LeagueApps
// every page load, joined to football-home team assignments (Tri County
// Women). Structurally a sibling of MensRosterScreen (single LA
// program) but with the entire delinquency/PAY/prorate block removed:
// the Women's Club LA program is NA_FREE, so there's no dues to chase,
// no days-overdue pill, no card-border risk color.
//
// Each player card carries the same shared roster-move dropdown
// Mens/Boys/Girls use (RosterScreenBase.renderMoveDropdown + the shared
// renderCompactCard shell — that shell only ever wires up
// rosterSelectHtml + viewButtonHtml, so this screen doesn't compute a
// separate contact/LA-manager button block that renderCompactCard would
// just discard). Tapping a move-dropdown target saves an assignment
// (POST /api/womens-roster/assign) and reloads. Columns are DB-driven
// (`teams` where gender_category='womens', migration 250 — currently
// just Tri County Women); to add a second women's team later just set
// board_sort_order on that row — no code change required.
class WomensRosterScreen extends RosterScreenBase {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        /* Hide the default triangle marker on the move-dropdown
           <summary> popover so it renders as a clean button. */
        .roster-move-details > summary { list-style: none; }
        .roster-move-details > summary::-webkit-details-marker { display: none; }
        .roster-move-details > summary::marker { display: none; content: ''; }

        /* Drag-and-drop cursor + insertion indicator — same pattern as
           mens-roster.js/boys-roster.js. See onDragStart / onDragOver
           below. */
        .wr-card[draggable="true"]        { cursor: grab; }
        .wr-card[draggable="true"]:active { cursor: grabbing; }
        .wr-card.wr-dragging              { opacity: 0.35; }
        .wr-card.wr-drop-before           { box-shadow: 0 -3px 0 0 #10b981 inset; }
        .wr-card.wr-drop-after            { box-shadow: 0  3px 0 0 #10b981 inset; }
        .wr-drop-zone.wr-drop-empty       { box-shadow: 0 0 0 2px #10b981 inset; border-radius: 4px; }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🎽 Women's Team Players Board</h1>
        <p class="subtitle">Live from LeagueApps — Lighthouse Women's Club</p>
      </div>

      <div style="padding: var(--space-2) 0;">
        <div id="wr-banner" style="margin: 0 var(--space-2) var(--space-3); padding: var(--space-3); border-radius: 6px; background: #f1f5f9; border: 1px solid #e2e8f0; display:flex; align-items:center; gap: var(--space-3); flex-wrap: wrap; font-size: 14px;">
          <span id="wr-banner-icon" style="font-size: 16px;">⏳</span>
          <span id="wr-banner-text" style="flex:1; min-width: 200px;">Pulling latest registrations from LeagueApps…</span>
          <button id="wr-refresh" class="btn btn-secondary" title="Force a fresh pull from LeagueApps (registrations)" style="padding: 4px 10px; font-size: 13px;">🔄 Refresh</button>
        </div>
        <div id="wr-loading" style="text-align:center; padding: var(--space-6); opacity:0.6;">Loading…</div>
        <div id="wr-error"   style="display:none; color: var(--color-error); padding: var(--space-4); text-align:center;"></div>
        <div id="wr-list"    style="display:none;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter() {
    RosterScreenBase.installMoveDropdownOutsideClose();
    this.element.addEventListener('click', e => {
      if (e.target.closest('.back-btn')) return this.navigation.goBack();
      if (e.target.closest('#wr-refresh')) return this.load({ refreshLa: true });
      const moveOpt = e.target.closest('.roster-move-option');
      if (moveOpt) return this.onMoveOptionClick(moveOpt);
      // 👤 PROFILE button is rendered by the shared PersonActions
      // component and routed globally by a delegated document-level
      // click handler installed once at app bootstrap — no per-screen
      // wiring needed here (see mens-roster.js/boys-roster.js).
    });

    // Drag-and-drop reorder — native HTML5 events wired via delegation
    // on the screen element so re-renders don't leak listeners.
    this.element.addEventListener('dragstart', e => this.onDragStart(e));
    this.element.addEventListener('dragend',   e => this.onDragEnd(e));
    this.element.addEventListener('dragover',  e => this.onDragOver(e));
    this.element.addEventListener('dragleave', e => this.onDragLeave(e));
    this.element.addEventListener('drop',      e => this.onDrop(e));

    // Initial load always refreshes LA — the singleton model cache is
    // empty on backend boot, and this is the moment the operator opens
    // the board, so we want the truthiest possible snapshot.
    this.load({ refreshLa: true });
  }

  setBanner({ icon, text, showRefresh = true }) {
    const i = this.find('#wr-banner-icon');
    const t = this.find('#wr-banner-text');
    const r = this.find('#wr-refresh');
    if (i) i.textContent = icon;
    if (t) t.textContent = text;
    if (r) r.style.display = showRefresh ? '' : 'none';
  }

  // Active/Inactive pill (RostersScreen host) — same pattern as
  // mens-roster.js's identical setIncludeInactive.
  setIncludeInactive(value) {
    this.includeInactive = !!value;
    return this.load();
  }

  async load({ refreshLa = false } = {}) {
    const loading = this.find('#wr-loading');
    const errEl   = this.find('#wr-error');
    const list    = this.find('#wr-list');
    if (loading) loading.style.display = '';
    if (errEl)   errEl.style.display   = 'none';
    if (list)    list.style.display    = 'none';
    this.setBanner({
      icon: '⏳',
      text: refreshLa
        ? 'Pulling latest registrations from LeagueApps…'
        : 'Reloading roster from cache…',
    });

    try {
      const t0  = performance.now();
      const params = new URLSearchParams();
      if (refreshLa) params.set('refreshLa', '1');
      if (this.includeInactive) params.set('includeInactive', '1');
      const qs = params.toString();
      const url = qs ? `/api/womens-roster?${qs}` : '/api/womens-roster';
      const res = await this.auth.fetch(url);
      if (!res.ok) {
        const body = await res.text();
        throw new Error(body.slice(0, 200) || `HTTP ${res.status}`);
      }
      const data = await res.json();
      const elapsed = ((performance.now() - t0) / 1000).toFixed(1);
      this._data = data;
      // Optional hook — RostersScreen (rosters.js) sets this so the
      // Teams panel can surface data.unassignedCount without reaching
      // into this screen's private DOM/state.
      if (typeof this.onDataLoaded === 'function') this.onDataLoaded(data);

      if (loading) loading.style.display = 'none';
      if (list)    list.style.display    = '';

      this.setBanner({
        icon: '✓',
        text: `${data.total} player${data.total === 1 ? '' : 's'} loaded in ${elapsed}s · ${data.unassignedCount} unassigned`,
        showRefresh: true,
      });
      this.renderRoster(data);
    } catch (err) {
      if (loading) loading.style.display = 'none';
      if (errEl) {
        errEl.style.display = '';
        errEl.textContent = `Failed to load team players: ${err.message}`;
      }
      this.setBanner({
        icon: '✗',
        text: `Could not reach LeagueApps: ${err.message}`,
        showRefresh: true,
      });
    }
  }

  renderRoster(data) {
    const container = this.find('#wr-list');

    const allCols = [
      { teamId: 0, label: '📦 Unassigned', color: '#475569', count: (data.unassigned || []).length, isUnassigned: true },
      ...data.columns,
    ];
    // columnScope (2026-08-16, rosters.js side-by-side layout) — see the
    // identical block in boys-roster.js/mens-roster.js's renderRoster.
    const cols = this.columnScope === 'unassigned'
      ? allCols.filter(c => c.isUnassigned)
      : this.columnScope === 'teams'
        ? allCols.filter(c => !c.isUnassigned)
        : allCols;

    container.innerHTML = `
      <div style="display:flex; align-items:center; gap:var(--space-3); flex-wrap:wrap; margin: 0 var(--space-2) var(--space-3); padding:var(--space-2) var(--space-3); background:var(--bg-secondary); border-radius:var(--radius-md);">
        <span style="opacity:0.7; font-size:0.8rem; font-weight:600;">Columns:</span>
        ${cols.map(c => {
          const count = c.isUnassigned ? c.count : ((data.buckets[String(c.teamId)] || []).length);
          const cap = c.maxRoster != null ? `(${count}/${c.maxRoster})` : `(${count})`;
          return `
            <span style="display:inline-flex; align-items:center; gap:6px; font-size:0.8rem; padding:2px 8px; border-radius:4px; border-left:3px solid ${c.color};">
              ${c.label} <span style="opacity:0.55;">${cap}</span>
            </span>`;
        }).join('')}
      </div>

      <div style="padding: 0 var(--space-2) var(--space-2);">
        <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(${this.colMinWidth(cols.length)}, max-content)); gap:var(--space-2); align-items:start;">
          ${cols.map(c => this.renderColumn(c, data)).join('')}
        </div>
      </div>
    `;
  }

  // Feeds the wrapping grid's minmax() floor above — columns that don't
  // fit on one row wrap to the next instead of needing overflow-x scroll,
  // which used to clip the move dropdown popover open below a card near
  // the bottom of a column (overflow-x:auto forces overflow-y to auto
  // too — a CSS quirk, not a real height shortage — found 2026-08-21).
  colMinWidth(n) {
    if (n <= 4) return '150px';
    if (n <= 6) return '130px';
    if (n <= 8) return '120px';
    return '110px';
  }

  renderColumn(col, data) {
    const players = col.isUnassigned
      ? (data.unassigned || [])
      : (data.buckets[String(col.teamId)] || []);

    let countHtml;
    if (col.maxRoster != null) {
      const overFull = players.length >= col.maxRoster;
      const pct      = col.maxRoster ? players.length / col.maxRoster : 0;
      const nearFull = !overFull && pct >= 0.85;
      const fc = overFull ? '#ef4444' : nearFull ? '#f59e0b' : '#10b981';
      const pctText  = `${Math.round(pct * 100)}%`;
      const left     = col.maxRoster - players.length;
      const detail   = overFull
        ? `${pctText} ⚠`
        : `${left} left · ${pctText}`;
      countHtml = `<span style="font-size:0.85rem; font-weight:600; color:${fc}; white-space:nowrap;">${players.length}/${col.maxRoster} · ${detail}</span>`;
    } else {
      countHtml = `<span style="opacity:0.6; font-size:0.85rem;">${players.length}</span>`;
    }

    const renderList = (list) => list.map((p, i) => this.renderPlayer(p, data.columns, col, i + 1)).join('');

    const body = players.length === 0
      ? '<div style="opacity:0.5; font-size:0.85rem;">(empty)</div>'
      : renderList(players);

    return `
      <div style="background:var(--bg-secondary); border-radius:var(--radius-md); padding:8px; border-top:3px solid ${col.color}; min-width:0;">
        <div style="display:flex; justify-content:space-between; align-items:baseline; margin-bottom:6px; gap:6px;">
          <strong style="font-size:0.85rem;">${col.label}</strong>
          ${countHtml}
        </div>
        <div class="wr-drop-zone" data-drop-team-id="${col.isUnassigned ? '' : col.teamId}"
             style="display:flex; flex-direction:column; gap:8px; min-height:8px; min-width:0;">
          ${body}
        </div>
      </div>
    `;
  }

  renderPlayer(p, columns, col, position) {
    // Full DOB (e.g. "3/10/2008").
    const dobShort = this.formatDobShort(p.birthDate);

    // ---- Move-to-roster dropdown -----------------------------------
    //
    // Targets are data-driven from data.columns (teams where
    // gender_category='womens', migration 250). Rendering itself is
    // identical to Mens/Boys/Girls — it lives once in RosterScreenBase.
    const { rosterSelectHtml: moveSelect, canMove } = this._teamCardCapabilities(p, columns, col);

    // 👤 VIEW button — dedicated drill-down into the universal
    // PersonScreen, same shared component every other roster uses.
    const profileBtn = this.renderPersonActions(p, {
      returnTo: 'womens-roster',
      showEdit: false,
      btnBaseStyle: 'font-size:0.68rem; padding:0 6px; line-height:1.2; appearance:none; -webkit-appearance:none; min-height:0; box-sizing:border-box; margin:0; display:flex; align-items:center; justify-content:center;',
    });

    const duesLabel = this.renderDuesLabel(p);
    const cardId = `wr-card-${p.leagueAppsUserId}`;

    // No delinquency concept for a free program — every card gets the
    // same yellow border Mens/Boys use for their non-overdue state.
    const cardBorder = '2px solid #facc15';

    return this.renderCompactCard({
      player: p,
      col,
      position,
      cardClass: 'wr-card',
      cardId,
      dobShort,
      duesLabel,
      rosterSelectHtml: moveSelect,
      viewButtonHtml: profileBtn,
      borderColor: cardBorder,
      canMove,
    });
  }

  // ── Drag-and-drop reorder — identical to boys-roster.js/mens-roster.js,
  // just scoped to .wr-card/.wr-drop-zone.
  _dragClearMarkers() {
    this.element.querySelectorAll('.wr-drop-before, .wr-drop-after')
      .forEach(el => el.classList.remove('wr-drop-before', 'wr-drop-after'));
    this.element.querySelectorAll('.wr-drop-empty')
      .forEach(el => el.classList.remove('wr-drop-empty'));
  }

  _dragInsertionPoint(zone, clientY) {
    const cards = Array.from(zone.querySelectorAll('.wr-card[draggable="true"]'))
      .filter(el => !el.classList.contains('wr-dragging'));
    for (const card of cards) {
      const rect = card.getBoundingClientRect();
      if (clientY < rect.top + rect.height / 2) return { before: card, cards };
    }
    return { before: null, cards };
  }

  onDragStart(e) {
    const card = e.target.closest && e.target.closest('.wr-card[draggable="true"]');
    if (!card) return;
    this._dragSourceUserId = card.dataset.userId;
    this._dragSourceTeamId = card.dataset.teamId;
    card.classList.add('wr-dragging');
    if (e.dataTransfer) {
      try {
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/plain', card.dataset.userId);
      } catch (_) { /* ignore */ }
    }
  }

  onDragEnd(_e) {
    this.element.querySelectorAll('.wr-card.wr-dragging')
      .forEach(el => el.classList.remove('wr-dragging'));
    this._dragClearMarkers();
    this._dragSourceUserId = null;
    this._dragSourceTeamId = null;
  }

  onDragOver(e) {
    if (!this._dragSourceUserId) return;
    const zone = e.target.closest && e.target.closest('.wr-drop-zone[data-drop-team-id]');
    if (!zone) return;
    const zoneTeamId = zone.dataset.dropTeamId;
    if (!zoneTeamId) return;
    if (zoneTeamId !== this._dragSourceTeamId) return;

    e.preventDefault();
    if (e.dataTransfer) e.dataTransfer.dropEffect = 'move';
    this._dragClearMarkers();

    const { before, cards } = this._dragInsertionPoint(zone, e.clientY);
    if (before) {
      before.classList.add('wr-drop-before');
    } else if (cards.length === 0) {
      zone.classList.add('wr-drop-empty');
    } else {
      cards[cards.length - 1].classList.add('wr-drop-after');
    }
  }

  onDragLeave(e) {
    const zone = e.target.closest && e.target.closest('.wr-drop-zone');
    if (!zone) return;
    const to = e.relatedTarget;
    if (to && zone.contains(to)) return;
    zone.classList.remove('wr-drop-empty');
    zone.querySelectorAll('.wr-drop-before, .wr-drop-after')
      .forEach(el => el.classList.remove('wr-drop-before', 'wr-drop-after'));
  }

  async onDrop(e) {
    if (!this._dragSourceUserId) return;
    const zone = e.target.closest && e.target.closest('.wr-drop-zone[data-drop-team-id]');
    if (!zone) return;
    const teamId = parseInt(zone.dataset.dropTeamId, 10);
    if (!teamId || String(teamId) !== this._dragSourceTeamId) return;

    e.preventDefault();
    const sourceCard = this.element.querySelector(
      `.wr-card[draggable="true"][data-user-id="${this._dragSourceUserId}"][data-team-id="${this._dragSourceTeamId}"]`
    );
    if (!sourceCard) { this._dragClearMarkers(); return; }

    const { before } = this._dragInsertionPoint(zone, e.clientY);
    if (before) {
      before.parentNode.insertBefore(sourceCard, before);
    } else {
      zone.appendChild(sourceCard);
    }
    this._dragClearMarkers();

    const cardEls = Array.from(zone.querySelectorAll('.wr-card[draggable="true"]'));
    const orderedIds = cardEls
      .map(el => parseInt(el.dataset.userId, 10)).filter(n => Number.isFinite(n));
    if (orderedIds.length === 0) return;
    const orderedPersonIds = cardEls.map(el => parseInt(el.dataset.personId, 10));
    const personIds = orderedPersonIds.every(n => Number.isFinite(n)) ? orderedPersonIds : null;

    try {
      const res = await this.auth.fetch('/api/womens-roster/reorder', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ teamId, userIds: orderedIds, ...(personIds ? { personIds } : {}) }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      await this.load();
    } catch (err) {
      alert(`Could not save order: ${err.message}`);
      await this.load();
    }
  }

  // Move-to-roster <details> popover option handler — identical logic to
  // boys-roster.js/mens-roster.js's onMoveOptionClick (multi-assign:
  // target 0 removes exactly this card's own row, any other target is a
  // purely additive add).
  async onMoveOptionClick(btn) {
    const userId        = parseInt(btn.dataset.userId, 10);
    const personId       = parseInt(btn.dataset.personId, 10) || undefined;
    const targetTeamId  = parseInt(btn.dataset.targetTeamId, 10);
    const currentTeamId = parseInt(btn.dataset.currentTeamId || '0', 10);
    if (!userId || Number.isNaN(targetTeamId)) return;

    const details = btn.closest('details');
    if (details) details.open = false;
    if (targetTeamId === currentTeamId) return;

    btn.disabled = true;
    btn.style.opacity = '0.4';
    try {
      let body;
      if (targetTeamId === 0) {
        if (currentTeamId <= 0) { await this.load(); return; }
        body = { leagueAppsUserId: userId, personId, teamId: currentTeamId, action: 'remove' };
      } else {
        body = { leagueAppsUserId: userId, personId, teamId: targetTeamId, action: 'add' };
      }
      const res = await this.auth.fetch('/api/womens-roster/assign', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(body),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      await this.load();
    } catch (err) {
      btn.disabled = false;
      btn.style.opacity = '';
      alert(`Could not move player: ${err.message}`);
    }
  }

  escape(s) {
    if (s == null) return '';
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }
}
