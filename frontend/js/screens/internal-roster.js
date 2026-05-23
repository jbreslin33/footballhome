// InternalRosterScreen - Lighthouse summer squad planning kanban board
class InternalRosterScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.teams = [];
    this.players = [];
    this.filterText = '';
    this.activeSourceFilters = new Set();
    this.dragPlayerId = null;
    this._dragPlaceholder = null;
    this.dragSourceSlot = null;  // { colId, di, si } | null
    this.depthChart = new Map(); // Map<colId, Array(33)> null|playerId per slot
    this.hiddenColumns = new Set();
    this.columnOrder = new Map(); // colId (int|null) → [playerId, ...]
  }

  // Column order and metadata
  columns() {
    const planning = this.teams.map(t => ({ id: t.id, name: t.name }));
    return [{ id: null, name: 'Unassigned' }, ...planning];
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-internal-roster';
    div.style.cssText = 'display:flex; flex-direction:column; height:100vh; overflow:hidden;';
    div.innerHTML = `
      <div style="display:flex; align-items:center; gap:var(--space-3); padding:var(--space-3) var(--space-4);
                  background:#1e3a8a; border-bottom:3px solid #f59e0b; flex-shrink:0;">
        <button id="ir-back-btn" class="btn" style="padding:6px 12px;background:rgba(255,255,255,0.12);color:#fff;border:1px solid rgba(255,255,255,0.3);border-radius:var(--radius-md);">← Back</button>
        <h2 style="margin:0; font-size:1.1rem; color:#fff; font-weight:700; letter-spacing:0.02em;">Squad Planner</h2>
        <input id="ir-search" type="text" class="form-control" placeholder="Search players…"
               style="max-width:220px; padding:6px 10px; font-size:0.85rem;background:rgba(255,255,255,0.12);color:#fff;border:1px solid rgba(255,255,255,0.25);" />
        <span id="ir-total" style="font-size:0.8rem; color:rgba(255,255,255,0.65); margin-left:auto;"></span>
        <button id="ir-add-player-btn" class="btn" style="padding:6px 14px; font-size:0.85rem;font-weight:700;background:#f59e0b;color:#1e3a8a;border:none;border-radius:var(--radius-md);">+ Add</button>
      </div>

      <div id="ir-loading" style="padding:var(--space-6); text-align:center;">
        <div class="spinner"></div><p>Loading…</p>
      </div>

      <div id="ir-col-toggles" style="display:none; padding:5px 10px;
           background:rgba(30,58,138,0.15); border-bottom:1px solid rgba(30,58,138,0.35);
           flex-wrap:wrap; gap:4px; flex-shrink:0; align-items:center;"></div>

      <div id="ir-board-wrapper" style="display:none; flex:1; overflow:hidden;">
        <div style="display:flex; flex-direction:row; height:100%;">
          <div id="ir-alpha-panel" style="width:230px; flex-shrink:0; overflow-y:auto;
               border-right:1px solid var(--color-border); background:var(--color-surface);"></div>
          <div id="ir-board" style="flex:1; overflow:hidden;
               padding:var(--space-3); gap:var(--space-3); display:flex; flex-direction:row; align-items:stretch;"></div>
        </div>
      </div>

      <!-- Add Player Modal -->
      <div id="ir-add-modal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.55);
           z-index:1000; align-items:center; justify-content:center;">
        <div style="background:var(--color-card); border-radius:var(--radius-lg); padding:var(--space-5);
                    width:340px; box-shadow:var(--shadow-xl);">
          <h3 style="margin:0 0 var(--space-4);">Add Player</h3>
          <div style="display:flex; flex-direction:column; gap:var(--space-3);">
            <input id="ir-new-first" type="text" class="form-control" placeholder="First name" />
            <input id="ir-new-last"  type="text" class="form-control" placeholder="Last name" />
            <input id="ir-new-year" type="number" class="form-control" placeholder="Birth year" min="1980" max="2015" />
          </div>
          <div style="display:flex; gap:var(--space-3); margin-top:var(--space-4); justify-content:flex-end;">
            <button id="ir-modal-cancel" class="btn btn-secondary">Cancel</button>
            <button id="ir-modal-save"   class="btn btn-primary">Save</button>
          </div>
          <div id="ir-modal-error" style="color:var(--color-danger); font-size:0.85rem; margin-top:var(--space-2);"></div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }

  async onEnter() {
    await this.loadData();
    this.bindEvents();
  }

  async loadData() {
    try {
      const [teamsResp, rosterResp] = await Promise.all([
        fetch('/api/internal/teams'),
        fetch('/api/internal/roster')
      ]);
      const teamsData  = await teamsResp.json();
      const rosterData = await rosterResp.json();

      if (!teamsData.success || !rosterData.success) {
        throw new Error('API error');
      }

      this.teams   = teamsData.data;
      this.players = rosterData.data;
      this.loadColumnOrderFromStorage(); // restore saved order
      this.loadDepthChartFromStorage();
      this.renderBoard();
    } catch (err) {
      console.error('InternalRosterScreen load error:', err);
      this.find('#ir-loading').innerHTML = '<p style="color:var(--color-danger)">Failed to load.</p>';
      return;
    }
    this.find('#ir-loading').style.display = 'none';
    this.find('#ir-col-toggles').style.display = 'flex';
    this.find('#ir-board-wrapper').style.display = 'flex';
    this.updateTotal();
  }

  updateTotal() {
    const search = this.filterText.toLowerCase();
    const visible = search
      ? this.players.filter(p => (p.firstName + ' ' + p.lastName).toLowerCase().includes(search))
      : this.players;
    this.find('#ir-total').textContent = visible.length + ' / ' + this.players.length + ' players';
  }

  // ── Board rendering ──────────────────────────────────────────────────────────

  renderBoard() {
    const alphaPanel = this.find('#ir-alpha-panel');
    if (alphaPanel) alphaPanel.style.display = this.hiddenColumns.has('alpha') ? 'none' : '';
    this.renderAlphaList();
    this.renderColumnToggles();
    const board = this.find('#ir-board');
    board.innerHTML = '';
    const search = this.filterText.toLowerCase();

    const visibleColCount = this.columns().filter(col => {
      const k = col.id === null ? 'null' : String(col.id);
      return !this.hiddenColumns.has(k);
    }).length;
    const compact = visibleColCount > 3;
    const tier = visibleColCount <= 1 ? 1 : visibleColCount <= 2 ? 2 : visibleColCount <= 4 ? 3 : 4;

    for (const col of this.columns()) {
      const colKey = col.id === null ? 'null' : String(col.id);
      if (this.hiddenColumns.has(colKey)) continue;

      // All players in this column (unfiltered) — used to maintain order
      const allInCol = this.players.filter(p =>
        col.id === null ? p.workingTeamIds.length === 0 : p.workingTeamIds.includes(col.id)
      );
      // Initialize or update columnOrder for this column
      if (!this.columnOrder.has(col.id)) {
        this.columnOrder.set(col.id, allInCol.map(p => p.playerId));
      } else {
        const prev = this.columnOrder.get(col.id);
        const currentIds = new Set(allInCol.map(p => p.playerId));
        const kept  = prev.filter(id => currentIds.has(id));
        const keptSet = new Set(kept);
        const added = allInCol.filter(p => !keptSet.has(p.playerId)).map(p => p.playerId);
        this.columnOrder.set(col.id, [...kept, ...added]);
      }
      const order = this.columnOrder.get(col.id);

      // Filtered + sorted players for display
      const colPlayers = allInCol
        .filter(p => !search || (p.firstName + ' ' + p.lastName).toLowerCase().includes(search))
        .sort((a, b) => order.indexOf(a.playerId) - order.indexOf(b.playerId));

      const colEl = document.createElement('div');
      colEl.className = 'ir-column';
      colEl.dataset.teamId = col.id === null ? '' : col.id;
      colEl.style.cssText = `
        display:flex; flex-direction:column; flex:1; min-width:0;
        background:var(--color-surface); border-radius:var(--radius-md);
        border:1px solid var(--color-border); overflow:hidden;
      `;

      const headerColor = this.columnHeaderColor(col.id);

      if (col.id !== null) {
        // ── Depth chart layout for team columns ────────────────────────────────
        const chart    = this.getColChart(col.id);
        const slottedSet = new Set(chart.filter(id => id !== null));
        const unslotted  = allInCol.filter(p => !slottedSet.has(p.playerId));

        // Header
        const hdr = document.createElement('div');
        hdr.style.cssText = 'padding:5px 8px;background:' + headerColor + ';display:flex;justify-content:space-between;align-items:center;flex-shrink:0;';
        hdr.innerHTML = '<span style="font-weight:600;font-size:0.78rem;color:#fff;">' + this.escapeHtml(col.name) + '</span>'
          + '<span class="ir-col-count" style="background:rgba(255,255,255,0.25);color:#fff;border-radius:999px;padding:1px 6px;font-size:0.68rem;">' + allInCol.length + '</span>';
        colEl.appendChild(hdr);

        // Sub-column labels S / B / 3
        const subHdr = document.createElement('div');
        subHdr.style.cssText = 'display:grid;grid-template-columns:12px repeat(3,1fr);background:' + headerColor + 'dd;padding:1px 2px;flex-shrink:0;';
        subHdr.innerHTML = '<div></div>'
          + ['S','B','3'].map(l => '<div style="text-align:center;font-size:0.56rem;font-weight:700;color:rgba(255,255,255,0.85);padding:1px 0;">' + l + '</div>').join('');
        colEl.appendChild(subHdr);

        // Depth grid: row-num col (12px) + 3 slot cols, 11 rows
        const grid = document.createElement('div');
        grid.style.cssText = 'display:grid;grid-template-columns:12px repeat(3,1fr);grid-template-rows:repeat(11,1fr);gap:1px;padding:2px;overflow:hidden;flex:1;background:rgba(0,0,0,0.12);';

        for (let si = 0; si < 11; si++) {
          const rn = document.createElement('div');
          const rnFs = tier <= 2 ? '0.62rem' : '0.5rem';
          rn.style.cssText = 'font-size:' + rnFs + ';color:#6b7280;display:flex;align-items:center;justify-content:flex-end;padding-right:2px;';
          rn.textContent = si + 1;
          grid.appendChild(rn);

          for (let di = 0; di < 3; di++) {
            const pid    = chart[di * 11 + si];
            const player = pid ? this.players.find(p => p.playerId === pid) : null;
            const slot   = document.createElement('div');
            slot.dataset.colId = col.id;
            slot.dataset.di    = di;
            slot.dataset.si    = si;

            if (player) {
              slot.draggable = true;
              slot.dataset.playerId = pid;
              const slotFs  = tier === 1 ? '0.82rem' : tier === 2 ? '0.72rem' : tier === 3 ? '0.68rem' : '0.62rem';
              const slotDir = tier <= 2 ? 'column' : 'row';
              const slotPad = tier <= 2 ? '3px 5px' : '1px 3px';
              slot.style.cssText = 'display:flex;flex-direction:' + slotDir + ';align-items:center;justify-content:center;padding:' + slotPad + ';background:' + headerColor + '28;border-left:2px solid ' + headerColor + ';border-radius:2px;cursor:grab;overflow:hidden;';
              const nameEl = document.createElement('span');
              const slotName = tier === 1
                ? ((player.firstName || '') + ' ' + (player.lastName || '?')).trim()
                : tier === 2
                  ? ((player.firstName || '?')[0] + '. ' + (player.lastName || '?'))
                  : (player.lastName || '?');
              nameEl.textContent   = slotName;
              nameEl.title         = player.firstName + ' ' + player.lastName;
              nameEl.style.cssText = 'font-size:' + slotFs + ';font-weight:500;color:#f1f5f9;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;line-height:1.3;pointer-events:none;';
              slot.appendChild(nameEl);
              if (tier <= 2 && (player.jerseyNumber || player.position)) {
                const metaEl = document.createElement('div');
                metaEl.style.cssText = 'display:flex;gap:3px;align-items:center;pointer-events:none;';
                if (player.jerseyNumber) {
                  const jEl = document.createElement('span');
                  jEl.textContent    = '#' + player.jerseyNumber;
                  jEl.style.cssText  = 'font-size:0.58rem;color:rgba(255,255,255,0.5);flex-shrink:0;pointer-events:none;';
                  metaEl.appendChild(jEl);
                }
                if (player.position) {
                  const pEl = document.createElement('span');
                  pEl.textContent   = player.position;
                  pEl.style.cssText = 'font-size:0.54rem;background:rgba(255,255,255,0.15);color:#d1d5db;padding:0 3px;border-radius:2px;flex-shrink:0;pointer-events:none;';
                  metaEl.appendChild(pEl);
                }
                slot.appendChild(metaEl);
              }

              let longPressFired = false, holdTimer = null;
              const startHold  = () => { longPressFired = false; holdTimer = setTimeout(() => { longPressFired = true; holdTimer = null; this.removeFromDepthSlot(col.id, di, si); }, 550); };
              const cancelHold = () => { if (holdTimer) { clearTimeout(holdTimer); holdTimer = null; } };
              slot.addEventListener('mousedown',  startHold);
              slot.addEventListener('touchstart', startHold, { passive: true });
              slot.addEventListener('mouseup',    cancelHold);
              slot.addEventListener('mouseleave', cancelHold);
              slot.addEventListener('touchend',   cancelHold);
              slot.addEventListener('touchmove',  cancelHold);
              slot.addEventListener('dragstart', e => {
                cancelHold();
                this.dragPlayerId   = pid;
                this.dragSourceSlot = { colId: col.id, di, si };
                slot.style.opacity  = '0.4';
                e.dataTransfer.effectAllowed = 'move';
                e.dataTransfer.setData('text/plain', String(pid));
              });
              slot.addEventListener('dragend', () => {
                slot.style.opacity  = '1';
                this.dragPlayerId   = null;
                this.dragSourceSlot = null;
              });
              slot.addEventListener('click', e => {
                if (longPressFired) { longPressFired = false; return; }
                e.preventDefault(); e.stopPropagation();
                this.openPlayerCard(player);
              });
            } else {
              slot.style.cssText = 'border-radius:2px;background:rgba(255,255,255,0.02);border:1px dashed rgba(255,255,255,0.08);';
            }

            slot.addEventListener('dragover',  e => { if (!this.dragPlayerId) return; e.preventDefault(); e.stopPropagation(); slot.style.outline = '1.5px solid #f59e0b'; });
            slot.addEventListener('dragleave', e => { if (!slot.contains(e.relatedTarget)) slot.style.outline = ''; });
            slot.addEventListener('drop', e => {
              e.preventDefault(); e.stopPropagation();
              slot.style.outline = '';
              const droppedPid = parseInt(e.dataTransfer.getData('text/plain'));
              if (!droppedPid || isNaN(droppedPid)) return;
              const displaced = chart[di * 11 + si];
              if (this.dragSourceSlot) {
                const src     = this.dragSourceSlot;
                const srcChart = this.getColChart(src.colId);
                if (src.colId === col.id) {
                  // same-team: swap displaced into source slot
                  srcChart[src.di * 11 + src.si] = displaced || null;
                } else {
                  // cross-team: just vacate source slot
                  srcChart[src.di * 11 + src.si] = null;
                }
              }
              this.slotPlayer(droppedPid, col.id, di, si);
            });
            grid.appendChild(slot);
          }
        }
        colEl.appendChild(grid);

        // Overflow: players in team but not yet slotted
        const overflow = document.createElement('div');
        overflow.className      = 'ir-card-list';
        overflow.dataset.teamId = col.id;
        overflow.style.cssText  = 'padding:2px;display:flex;flex-wrap:wrap;gap:2px;min-height:20px;border-top:1px solid rgba(255,255,255,0.1);flex-shrink:0;';
        for (const p of unslotted) overflow.appendChild(this.makeCard(p, col.id, visibleColCount > 2));
        this.bindDropZone(overflow, col.id);
        colEl.appendChild(overflow);

      } else {
        // ── Unassigned column: flat card grid ──────────────────────────────────
        colEl.innerHTML = '<div style="padding:8px 12px;background:' + headerColor + ';display:flex;justify-content:space-between;align-items:center;flex-shrink:0;">'
          + '<span style="font-weight:600;font-size:0.85rem;color:#fff;">' + this.escapeHtml(col.name) + '</span>'
          + '<span class="ir-col-count" style="background:rgba(255,255,255,0.25);color:#fff;border-radius:999px;padding:1px 7px;font-size:0.75rem;">' + colPlayers.length + '</span>'
          + '</div>'
          + '<div class="ir-card-list" data-team-id="" style="flex:1;overflow:hidden;padding:4px;display:grid;grid-template-columns:repeat(2,1fr);gap:2px;align-content:start;min-height:40px;"></div>';
        const cardList = colEl.querySelector('.ir-card-list');
        for (const p of colPlayers) cardList.appendChild(this.makeCard(p, col.id, compact));
        this.bindDropZone(cardList, col.id);
      }

      board.appendChild(colEl);
    }
  }

  makeCard(player, colId, compact = false) {
    const card = document.createElement('div');
    card.className = 'ir-card';
    card.draggable = true;
    card.dataset.playerId = player.playerId;
    const pad = compact ? '2px 4px' : '5px 8px';
    const teamColor = this.columnHeaderColor(colId);
    const cardBg = `${teamColor}28`;
    const cardBorderLeft = `3px solid ${teamColor}`;
    card.style.cssText = `
      display:flex; align-items:center; gap:3px;
      background:${cardBg};
      border-top:1px solid rgba(255,255,255,0.08); border-right:1px solid rgba(255,255,255,0.08);
      border-bottom:1px solid rgba(255,255,255,0.08); border-left:${cardBorderLeft};
      border-radius:4px; padding:${pad}; cursor:grab; user-select:none;
      transition:box-shadow 0.15s, opacity 0.15s; position:relative;
    `;

    const fullName = (player.firstName || '') + ' ' + (player.lastName || '');
    const displayName = compact
      ? this.escapeHtml(player.lastName || '—')
      : this.escapeHtml(fullName);
    const fontSize = compact ? '0.72rem' : '0.82rem';
    const jersey = player.jerseyNumber
      ? `<span style="font-size:0.63rem;opacity:0.4;flex-shrink:0;">#${player.jerseyNumber}</span>`
      : '';
    const posTag = player.position
      ? `<span style="background:#374151;color:#fff;padding:0 3px;border-radius:3px;font-size:0.58rem;flex-shrink:0;">${this.escapeHtml(player.position)}</span>`
      : '';
    const otherTags = compact ? '' : this.getOtherDimensionTag(player, colId);

    card.innerHTML = `
      ${jersey}
      <span style="flex:1;font-size:${fontSize};font-weight:500;min-width:0;word-break:break-word;line-height:1.2;"
            title="${this.escapeHtml(fullName)}">${displayName}</span>
      ${posTag}
      ${otherTags ? `<div style="display:flex;gap:2px;align-items:center;flex-shrink:0;">${otherTags}</div>` : ''}
    `;

    card.title = colId !== null ? 'Click to edit · Hold to remove from this roster' : 'Click to edit';

    // ── Click opens card; long-press (column cards only) removes from roster ──
    if (colId !== null) {
      let holdTimer = null;
      let longPressFired = false;
      const startHold = () => {
        longPressFired = false;
        holdTimer = setTimeout(() => {
          holdTimer = null;
          longPressFired = true;
          card.style.transition = 'background 0.15s';
          card.style.background = 'rgba(220,38,38,0.18)';
          setTimeout(() => { card.style.background = ''; }, 400);
          this.unassignFromTeam(player.playerId, colId);
        }, 550);
      };
      const cancelHold = () => { if (holdTimer) { clearTimeout(holdTimer); holdTimer = null; } };
      card.addEventListener('mousedown',  startHold);
      card.addEventListener('touchstart', startHold, { passive: true });
      card.addEventListener('mouseup',    cancelHold);
      card.addEventListener('mouseleave', cancelHold);
      card.addEventListener('touchend',   cancelHold);
      card.addEventListener('touchmove',  cancelHold);
      card.addEventListener('dragstart',  cancelHold);
      card.addEventListener('click', e => {
        if (longPressFired) { longPressFired = false; return; }
        e.preventDefault(); e.stopPropagation();
        this.openPlayerCard(player);
      });
    } else {
      card.addEventListener('click', e => {
        e.preventDefault(); e.stopPropagation();
        this.openPlayerCard(player);
      });
    }

    card.addEventListener('dragstart', e => {
      this.dragPlayerId = player.playerId;
      card.style.opacity = '0.45';
      e.dataTransfer.effectAllowed = 'move';
      e.dataTransfer.setData('text/plain', String(player.playerId));
    });
    card.addEventListener('dragend', () => {
      card.style.opacity = '1';
      this.dragPlayerId = null;
      this._removePlaceholder();
      this.find('#ir-board').querySelectorAll('.ir-card-list').forEach(el => {
        el.style.background = '';
        el.style.outline = '';
      });
    });

    return card;
  }

  async addToTeam(playerId, teamId) {
    const player = this.players.find(p => p.playerId === playerId);
    if (!player) return;
    if (player.workingTeamIds.includes(teamId)) return;
    const prevIds = [...player.workingTeamIds];
    player.workingTeamIds = [...player.workingTeamIds, teamId];
    this.renderBoard();
    try {
      const resp = await fetch(`/api/internal/roster/${playerId}/team`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ teamId, onlyAdd: true })
      });
      const data = await resp.json();
      if (!data.success) throw new Error(data.message || 'Failed');
    } catch (err) {
      console.error('addToTeam error:', err);
      player.workingTeamIds = prevIds;
      this.renderBoard();
    }
  }

  async unassignFromTeam(playerId, teamId) {
    const player = this.players.find(p => p.playerId === playerId);
    if (!player) return;
    const prevIds = [...player.workingTeamIds];
    player.workingTeamIds = player.workingTeamIds.filter(id => id !== teamId);
    this.renderBoard();
    try {
      const resp = await fetch(`/api/internal/roster/${playerId}/team`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ teamId, onlyRemove: true })
      });
      const data = await resp.json();
      if (!data.success) throw new Error(data.message || 'Failed');
    } catch (err) {
      console.error('unassignFromTeam error:', err);
      player.workingTeamIds = prevIds;
      this.renderBoard();
    }
  }

  _getPlaceholder() {
    if (!this._dragPlaceholder) {
      const ph = document.createElement('div');
      ph.className = 'ir-drag-placeholder';
      ph.style.cssText = 'height:26px;background:rgba(99,102,241,0.15);border:1.5px dashed #6366f1;border-radius:4px;box-sizing:border-box;pointer-events:none;';
      this._dragPlaceholder = ph;
    }
    return this._dragPlaceholder;
  }

  _removePlaceholder() {
    if (this._dragPlaceholder && this._dragPlaceholder.parentNode) {
      this._dragPlaceholder.parentNode.removeChild(this._dragPlaceholder);
    }
  }

  bindDropZone(listEl, colId) {
    listEl.addEventListener('dragover', e => {
      if (this.dragPlayerId === null) return;
      e.preventDefault();
      const dragging = this.players.find(p => p.playerId === this.dragPlayerId);
      if (!dragging) return;
      const inSameCol = colId === null
        ? dragging.workingTeamIds.length === 0
        : dragging.workingTeamIds.includes(colId);
      if (inSameCol) {
        listEl.style.background = '';
        listEl.style.outline = '';
        const ph = this._getPlaceholder();
        const cardEls = Array.from(listEl.children).filter(c =>
          c !== ph && c.dataset.playerId !== String(this.dragPlayerId));
        let insertBefore = null;
        for (const cardEl of cardEls) {
          const rect = cardEl.getBoundingClientRect();
          if (e.clientY < rect.top + rect.height / 2) { insertBefore = cardEl; break; }
        }
        if (insertBefore) listEl.insertBefore(ph, insertBefore);
        else listEl.appendChild(ph);
      } else {
        this._removePlaceholder();
        e.dataTransfer.dropEffect = 'move';
        listEl.style.background = 'rgba(99,102,241,0.08)';
        listEl.style.outline = '2px dashed #6366f1';
      }
    });
    listEl.addEventListener('dragleave', e => {
      if (!listEl.contains(e.relatedTarget)) {
        this._removePlaceholder();
        listEl.style.background = '';
        listEl.style.outline = '';
      }
    });
    listEl.addEventListener('drop', e => {
      e.preventDefault();
      listEl.style.background = '';
      listEl.style.outline = '';
      if (this.dragPlayerId === null) return;
      const dragging = this.players.find(p => p.playerId === this.dragPlayerId);
      if (!dragging) return;
      const inSameCol = colId === null
        ? dragging.workingTeamIds.length === 0
        : dragging.workingTeamIds.includes(colId);
      if (inSameCol) {
        const ph = this._dragPlaceholder;
        if (!ph || ph.parentNode !== listEl) { this._removePlaceholder(); return; }
        const newOrder = [];
        for (const child of listEl.children) {
          if (child === ph) newOrder.push(this.dragPlayerId);
          else if (child.dataset.playerId && child.dataset.playerId !== String(this.dragPlayerId))
            newOrder.push(parseInt(child.dataset.playerId));
        }
        this.columnOrder.set(colId, newOrder);
        this.saveColumnOrderToStorage();
        this._removePlaceholder();
        this.renderBoard();
      } else {
        this._removePlaceholder();
        const playerId = parseInt(e.dataTransfer.getData('text/plain'));
        if (playerId && !isNaN(playerId)) this.assignPlayer(playerId, colId !== null ? colId : null);
      }
    });
  }

  // ── Assignment ───────────────────────────────────────────────────────────────

  static get SQUAD_TEAMS()  { return new Set([901, 902, 903, 904, 905, 906]); }
  static get LEAGUE_TEAMS() { return new Set([907, 908, 909]); }
  static get NATIONAL_TEAMS() { return new Set([904, 905]); }  // Brazil & PR — warn on switch

  async assignPlayer(playerId, teamId, opts = {}) {
    const player = this.players.find(p => p.playerId === playerId);
    if (!player) return;
    if (teamId !== null && player.workingTeamIds.includes(teamId)) return;

    // Warn before switching between competing national teams
    const NATIONAL = InternalRosterScreen.NATIONAL_TEAMS;
    if (!opts.skipConfirm && teamId !== null && NATIONAL.has(teamId)) {
      const currentNational = player.workingTeamIds.find(id => NATIONAL.has(id));
      if (currentNational) {
        const fromName = this.teams.find(t => t.id === currentNational)?.name || currentNational;
        const toName   = this.teams.find(t => t.id === teamId)?.name || teamId;
        if (!confirm(`${player.firstName} ${player.lastName} is on ${fromName}.\nMove to ${toName}?`)) return;
      }
    }

    const SQUAD  = InternalRosterScreen.SQUAD_TEAMS;
    const LEAGUE = InternalRosterScreen.LEAGUE_TEAMS;
    const prevIds = [...player.workingTeamIds];

    // Optimistic update — dimension-aware
    if (teamId === null) {
      player.workingTeamIds = [];
    } else if (SQUAD.has(teamId)) {
      player.workingTeamIds = player.workingTeamIds.filter(id => !SQUAD.has(id));
      player.workingTeamIds.push(teamId);
    } else if (LEAGUE.has(teamId)) {
      player.workingTeamIds = player.workingTeamIds.filter(id => !LEAGUE.has(id));
      player.workingTeamIds.push(teamId);
    }
    this.renderBoard();

    try {
      const resp = await fetch(`/api/internal/roster/${playerId}/team`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ teamId })
      });
      const data = await resp.json();
      if (!data.success) throw new Error(data.message || 'Failed');
    } catch (err) {
      console.error('assignPlayer error:', err);
      player.workingTeamIds = prevIds;
      this.renderBoard();
    }
  }

  // ── Events ───────────────────────────────────────────────────────────────────

  bindEvents() {
    this.element.addEventListener('click', e => {
      if (e.target.id === 'ir-back-btn')       this.navigation.goBack();
      if (e.target.id === 'ir-add-player-btn') this.openAddModal();
      if (e.target.id === 'ir-modal-cancel')   this.closeAddModal();
      if (e.target.id === 'ir-modal-save')     this.saveNewPlayer();
      const groupToggleBtn = e.target.closest('.ir-col-group-toggle');
      if (groupToggleBtn) {
        const ids = JSON.parse(groupToggleBtn.dataset.colGroupIds);
        const allHidden = ids.every(id => this.hiddenColumns.has(String(id)));
        if (allHidden) ids.forEach(id => this.hiddenColumns.delete(String(id)));
        else ids.forEach(id => this.hiddenColumns.add(String(id)));
        this.renderBoard();
        return;
      }
      const toggleBtn = e.target.closest('.ir-col-toggle');
      if (toggleBtn) {
        const key = toggleBtn.dataset.colKey;
        if (this.hiddenColumns.has(key)) this.hiddenColumns.delete(key);
        else this.hiddenColumns.add(key);
        this.renderBoard();
      }
      const deleteBtn = e.target.closest('.ir-delete-btn');
      if (deleteBtn) {
        e.stopPropagation();
        e.preventDefault();
        this.deletePlayer(parseInt(deleteBtn.dataset.playerId));
      }
    });

    let searchTimer;
    this.element.addEventListener('input', e => {
      if (e.target.id === 'ir-search') {
        clearTimeout(searchTimer);
        searchTimer = setTimeout(() => {
          this.filterText = e.target.value.trim();
          this.renderBoard();
          this.updateTotal();
        }, 200);
      }
    });
  }

  async deletePlayer(playerId) {
    const player = this.players.find(p => p.playerId === playerId);
    if (!player) return;
    const name = `${player.firstName || ''} ${player.lastName || ''}`.trim();
    if (!confirm(`Delete "${name}" from the database?\n\nThis cannot be undone.`)) return;
    try {
      const resp = await fetch(`/api/internal/roster/${playerId}`, { method: 'DELETE' });
      const data = await resp.json();
      if (!data.success) throw new Error(data.message || 'Failed');
      this.players = this.players.filter(p => p.playerId !== playerId);
      this.renderBoard();
      this.updateTotal();
    } catch (err) {
      alert('Could not delete player: ' + (err.message || 'Unknown error'));
    }
  }

  openAddModal() {
    ['#ir-new-first', '#ir-new-last', '#ir-new-year'].forEach(id => { this.find(id).value = ''; });
    this.find('#ir-modal-error').textContent = '';
    this.find('#ir-add-modal').style.display = 'flex';
    this.find('#ir-new-first').focus();
  }

  closeAddModal() {
    this.find('#ir-add-modal').style.display = 'none';
  }

  openEditModal(player) { this.openPlayerCard(player); } // compat alias

  openPlayerCard(player) {
    const posOptions = ['','GK','CB','RB','LB','CDM','CM','CAM','RW','LW','ST']
      .map(v => `<option value="${v}" ${(player.position||'')=== v?'selected':''}>${v || '— not set —'}</option>`)
      .join('');
    const eligRows = [
      { id:'pc-elig-apsl-starter',  label:'APSL Starter',   f:'eligApslStarter'  },
      { id:'pc-elig-apsl-bench',    label:'APSL Bench',     f:'eligApslBench'    },
      { id:'pc-elig-liga1-starter', label:'Liga 1 Starter', f:'eligLiga1Starter' },
      { id:'pc-elig-liga1-bench',   label:'Liga 1 Bench',   f:'eligLiga1Bench'   },
      { id:'pc-elig-liga2-starter', label:'Liga 2 Starter', f:'eligLiga2Starter' },
      { id:'pc-elig-liga2-bench',   label:'Liga 2 Bench',   f:'eligLiga2Bench'   },
    ].map(r => `
      <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;padding:4px 0;">
        <span style="font-size:0.88rem;">${r.label}</span>
        <input type="checkbox" id="${r.id}" style="width:18px;height:18px;cursor:pointer;accent-color:var(--accent);" ${player[r.f]?'checked':''}>
      </label>`).join('');

    const name = this.escapeHtml(((player.firstName||'')+' '+(player.lastName||'')).trim());
    const overlay = document.createElement('div');
    overlay.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,0.55);z-index:1000;display:flex;align-items:flex-end;justify-content:center;';
    overlay.innerHTML = `
      <div style="background:var(--color-card);border-radius:16px 16px 0 0;width:100%;max-width:480px;max-height:90vh;overflow-y:auto;">
        <div style="display:flex;align-items:flex-start;justify-content:space-between;padding:16px;
                    position:sticky;top:0;z-index:1;background:var(--color-card);border-bottom:1px solid var(--color-border);">
          <div>
            <h3 style="margin:0;font-size:1rem;">${name}</h3>
            <div style="font-size:0.75rem;color:var(--color-muted);">${player.position||'No position set'} · #${player.jerseyNumber||'—'}</div>
          </div>
          <button id="pc-close" style="background:none;border:none;font-size:1.2rem;cursor:pointer;color:var(--color-muted);padding:4px;">&#x2715;</button>
        </div>
        <div style="padding:0 16px;">

          <!-- ROSTERS -->
          <div style="border-bottom:1px solid var(--color-border);padding:12px 0;display:flex;flex-direction:column;gap:10px;">
            <div style="font-size:0.7rem;color:var(--color-muted);font-weight:700;letter-spacing:0.06em;">ROSTERS</div>
            <div>
              <div style="font-size:0.72rem;color:var(--color-muted);margin-bottom:6px;">Squad</div>
              <div id="pc-squad-pills" style="display:flex;flex-wrap:wrap;gap:6px;"></div>
            </div>
            <div>
              <div style="font-size:0.72rem;color:var(--color-muted);margin-bottom:6px;">League</div>
              <div id="pc-league-pills" style="display:flex;flex-wrap:wrap;gap:6px;"></div>
            </div>
          </div>

          <!-- PLAYER INFO -->
          <div style="border-bottom:1px solid var(--color-border);padding:12px 0;display:flex;flex-direction:column;gap:10px;">
            <div style="font-size:0.7rem;color:var(--color-muted);font-weight:700;letter-spacing:0.06em;">PLAYER INFO</div>
            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <span style="font-size:0.88rem;"># Jersey</span>
              <input type="text" id="pc-jersey" inputmode="numeric" value="${player.jerseyNumber||''}" placeholder="—"
                style="width:64px;padding:5px 8px;border-radius:6px;border:1px solid var(--color-border);background:var(--color-surface);color:inherit;font-size:0.9rem;text-align:center;">
            </label>
            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <span style="font-size:0.88rem;">&#x1F382; Date of Birth</span>
              <input type="date" id="pc-dob" value="${player.dateOfBirth||''}"
                style="padding:5px 6px;border-radius:6px;border:1px solid var(--color-border);background:var(--color-surface);color:inherit;font-size:0.82rem;">
            </label>
            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <span style="font-size:0.88rem;">&#x26BD; Position</span>
              <select id="pc-position" style="padding:4px 8px;border-radius:6px;border:1px solid var(--color-border);background:var(--color-surface);color:inherit;font-size:0.88rem;">
                ${posOptions}
              </select>
            </label>
            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <span style="font-size:0.88rem;">&#x2B50; Designated Player</span>
              <input type="checkbox" id="pc-designated" style="width:20px;height:20px;cursor:pointer;accent-color:var(--accent);" ${player.isDesignated?'checked':''}>
            </label>
            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div>
                <div style="font-size:0.88rem;">&#x1F3DF;&#xFE0F; Number of Clubs</div>
                <div style="font-size:0.72rem;color:var(--color-muted);">2 clubs = ranked lower</div>
              </div>
              <select id="pc-numclubs" style="padding:4px 8px;border-radius:6px;border:1px solid var(--color-border);background:var(--color-surface);color:inherit;font-size:0.88rem;">
                <option value="1" ${(player.numClubs||1)===1?'selected':''}>1 club</option>
                <option value="2" ${(player.numClubs||1)===2?'selected':''}>2 clubs</option>
              </select>
            </label>
            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div>
                <div style="font-size:0.88rem;">&#x1F9E4; Goalkeeper</div>
                <div style="font-size:0.72rem;color:var(--color-muted);">0 practices required</div>
              </div>
              <input type="checkbox" id="pc-keeper" style="width:20px;height:20px;cursor:pointer;accent-color:var(--accent);" ${player.isKeeper?'checked':''}>
            </label>
            <label style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
              <div>
                <div style="font-size:0.88rem;">&#x1F476; Child</div>
                <div style="font-size:0.72rem;color:var(--color-muted);">0 practices required</div>
              </div>
              <input type="checkbox" id="pc-child" style="width:20px;height:20px;cursor:pointer;accent-color:var(--accent);" ${player.isChild?'checked':''}>
            </label>
          </div>

          <!-- STATUS -->
          <div style="border-bottom:1px solid var(--color-border);padding:12px 0;display:flex;flex-direction:column;gap:10px;">
            <div style="font-size:0.7rem;color:var(--color-muted);font-weight:700;letter-spacing:0.06em;">STATUS</div>
            <label style="display:flex;align-items:center;justify-content:space-between;">
              <span style="font-size:0.88rem;">&#x1FA79; Injured</span>
              <input type="checkbox" id="pc-injured" style="width:20px;height:20px;cursor:pointer;" ${player.isInjured?'checked':''}>
            </label>
            <label style="display:flex;align-items:center;justify-content:space-between;">
              <span style="font-size:0.88rem;">&#x1F6AB; Suspended (League)</span>
              <input type="checkbox" id="pc-susp-league" style="width:20px;height:20px;cursor:pointer;" ${player.isSuspendedLeague?'checked':''}>
            </label>
            <label style="display:flex;align-items:center;justify-content:space-between;">
              <span style="font-size:0.88rem;">&#x1F6AB; Suspended (In-House)</span>
              <input type="checkbox" id="pc-susp-inhouse" style="width:20px;height:20px;cursor:pointer;" ${player.isSuspendedInhouse?'checked':''}>
            </label>
          </div>

          <!-- ELIGIBLE FOR -->
          <div style="padding:12px 0 24px;display:flex;flex-direction:column;gap:4px;">
            <div style="font-size:0.7rem;color:var(--color-muted);font-weight:700;letter-spacing:0.06em;margin-bottom:4px;">ELIGIBLE FOR</div>
            ${eligRows}
          </div>

          <div id="pc-save-status" style="margin-bottom:16px;font-size:0.75rem;color:var(--color-muted);text-align:center;min-height:1.2em;"></div>
        </div>
      </div>
    `;
    document.body.appendChild(overlay);

    overlay.querySelector('#pc-close').addEventListener('click', () => overlay.remove());
    overlay.addEventListener('click', e => { if (e.target === overlay) overlay.remove(); });

    // ── Roster pills ─────────────────────────────────────────────────────────
    const SQUAD_IDS  = [901, 902, 903, 904, 905, 906];
    const LEAGUE_IDS = [907, 908, 909];
    const PILL_ABBR  = { 901:'TCW', 902:'U23W', 903:'U23M', 904:'BRA', 905:'PR', 906:'Pool', 907:'APSL', 908:'L1', 909:'L2' };
    const renderRosterPills = () => {
      [{ sel:'#pc-squad-pills', ids:SQUAD_IDS }, { sel:'#pc-league-pills', ids:LEAGUE_IDS }]
        .forEach(({ sel, ids }) => {
          const container = overlay.querySelector(sel);
          if (!container) return;
          container.innerHTML = ids.map(tid => {
            const active = player.workingTeamIds.includes(tid);
            const bg     = active ? this.columnHeaderColor(tid) : 'var(--color-surface)';
            const border = active ? this.columnHeaderColor(tid) : 'var(--color-border)';
            const color  = active ? '#fff' : 'inherit';
            const weight = active ? '600' : '400';
            return `<button class="pc-team-pill" data-team-id="${tid}"
              style="padding:5px 14px;border-radius:999px;border:2px solid ${border};
                     background:${bg};color:${color};font-size:0.82rem;cursor:pointer;
                     font-weight:${weight};transition:all 0.15s;">${PILL_ABBR[tid]}</button>`;
          }).join('');
        });
    };
    renderRosterPills();
    overlay.addEventListener('click', async e => {
      const pill = e.target.closest('.pc-team-pill');
      if (!pill) return;
      e.stopPropagation();
      const tid = parseInt(pill.dataset.teamId);
      if (player.workingTeamIds.includes(tid)) {
        await this.unassignFromTeam(player.playerId, tid);
      } else {
        await this.addToTeam(player.playerId, tid);
      }
      renderRosterPills();
    });

    const saveStatus = overlay.querySelector('#pc-save-status');
    const prevDob = player.dateOfBirth || '';
    let saveTimer = null;
    const scheduleSave = () => {
      if (saveStatus) saveStatus.textContent = 'Saving…';
      clearTimeout(saveTimer);
      saveTimer = setTimeout(async () => {
        const designated       = overlay.querySelector('#pc-designated').checked;
        const numClubs         = parseInt(overlay.querySelector('#pc-numclubs').value);
        const isKeeper         = overlay.querySelector('#pc-keeper').checked;
        const isChild          = overlay.querySelector('#pc-child').checked;
        const jersey           = overlay.querySelector('#pc-jersey').value.trim() || null;
        const isInjured        = overlay.querySelector('#pc-injured').checked;
        const isSuspLeague     = overlay.querySelector('#pc-susp-league').checked;
        const isSuspInhouse    = overlay.querySelector('#pc-susp-inhouse').checked;
        const position         = overlay.querySelector('#pc-position').value || null;
        const dobVal           = overlay.querySelector('#pc-dob').value.trim() || '';
        const eligApslStarter  = overlay.querySelector('#pc-elig-apsl-starter').checked;
        const eligApslBench    = overlay.querySelector('#pc-elig-apsl-bench').checked;
        const eligLiga1Starter = overlay.querySelector('#pc-elig-liga1-starter').checked;
        const eligLiga1Bench   = overlay.querySelector('#pc-elig-liga1-bench').checked;
        const eligLiga2Starter = overlay.querySelector('#pc-elig-liga2-starter').checked;
        const eligLiga2Bench   = overlay.querySelector('#pc-elig-liga2-bench').checked;

        // Optimistic local update
        player.isDesignated = designated; player.numClubs = numClubs;
        player.isKeeper = isKeeper;       player.isChild = isChild;
        player.jerseyNumber = jersey;     player.isInjured = isInjured;
        player.isSuspendedLeague = isSuspLeague;
        player.isSuspendedInhouse = isSuspInhouse;
        player.position = position;
        player.eligApslStarter = eligApslStarter; player.eligApslBench = eligApslBench;
        player.eligLiga1Starter = eligLiga1Starter; player.eligLiga1Bench = eligLiga1Bench;
        player.eligLiga2Starter = eligLiga2Starter; player.eligLiga2Bench = eligLiga2Bench;
        if (dobVal) player.dateOfBirth = dobVal;

        const saves = [
          fetch(`/api/eligibility/player/${player.playerId}/flags`, {
            method: 'PUT', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              isDesignated: designated, numClubs, isKeeper, isChild,
              jerseyNumber: jersey, internalRole: player.internalRole || '',
              isInjured, isSuspendedLeague: isSuspLeague, isSuspendedInhouse: isSuspInhouse,
              eligApslStarter, eligApslBench, eligLiga1Starter, eligLiga1Bench,
              eligLiga2Starter, eligLiga2Bench
            })
          }),
          fetch(`/api/internal/roster/${player.playerId}/attrs`, {
            method: 'PUT', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ position })
          })
        ];
        if (dobVal && dobVal !== prevDob) {
          saves.push(fetch(`/api/eligibility/person/${player.personId}/dob`, {
            method: 'PUT', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ dateOfBirth: dobVal })
          }));
        }
        try {
          await Promise.all(saves);
          if (saveStatus) {
            saveStatus.textContent = '&#x2713; Saved';
            setTimeout(() => { if (saveStatus) saveStatus.textContent = ''; }, 2000);
          }
          this.renderBoard();
        } catch (err) {
          if (saveStatus) saveStatus.textContent = '&#x26A0; Save failed';
        }
      }, 600);
    };
    overlay.querySelectorAll('input[type=checkbox],select').forEach(el => el.addEventListener('change', scheduleSave));
    overlay.querySelector('#pc-jersey').addEventListener('blur', scheduleSave);
    overlay.querySelector('#pc-dob').addEventListener('change', scheduleSave);
  }

  async saveNewPlayer() {
    const firstName = this.find('#ir-new-first').value.trim();
    const lastName  = this.find('#ir-new-last').value.trim();
    const birthYear = parseInt(this.find('#ir-new-year').value) || undefined;
    const errorEl   = this.find('#ir-modal-error');

    if (!firstName || !lastName) { errorEl.textContent = 'First and last name are required.'; return; }

    errorEl.textContent = '';
    const saveBtn = this.find('#ir-modal-save');
    saveBtn.disabled = true;
    saveBtn.textContent = 'Saving…';

    try {
      const resp = await fetch('/api/internal/players', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ firstName, lastName, birthYear })
      });
      const data = await resp.json();
      if (!data.success) throw new Error(data.message);

      this.players.push({
        playerId: data.data.playerId, personId: data.data.personId,
        firstName, lastName,
        birthYear: birthYear ? String(birthYear) : null,
        dateOfBirth: birthYear ? `${birthYear}-01-01` : null,
        workingTeamIds: [],
        officialTeams: null,
        groupMeChats: null,
        position: null,
        jerseyNumber: null,
        isKeeper: false, isDesignated: false, isChild: false, numClubs: 1,
        eligApslStarter: false, eligApslBench: false,
        eligLiga1Starter: false, eligLiga1Bench: false,
        eligLiga2Starter: false, eligLiga2Bench: false,
        isInjured: false, isSuspendedLeague: false, isSuspendedInhouse: false
      });

      this.closeAddModal();
      this.renderBoard();
      this.updateTotal();
    } catch (err) {
      errorEl.textContent = err.message || 'Failed to create player.';
    } finally {
      saveBtn.disabled = false;
      saveBtn.textContent = 'Save';
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  renderColumnToggles() {
    const bar = this.find('#ir-col-toggles');
    if (!bar) return;
    bar.innerHTML = '';

    // ── Squad group pills ────────────────────────────────────────────────────
    const COLUMN_GROUPS = [
      { key: 'summerM', label: 'Summer Men',   color: '#0369a1', ids: [903, 904, 905] },
      { key: 'summerW', label: 'Summer Women', color: '#7c3aed', ids: [902] },
      { key: 'fallM',   label: 'Fall Men',     color: '#b45309', ids: [907, 908, 909] },
      { key: 'fallW',   label: 'Fall Women',   color: '#be185d', ids: [901] },
    ];
    for (const grp of COLUMN_GROUPS) {
      const someHidden = grp.ids.some(id => this.hiddenColumns.has(String(id)));
      const active = !someHidden; // active = all visible
      const btn = document.createElement('button');
      btn.dataset.colGroupKey = grp.key;
      btn.dataset.colGroupIds = JSON.stringify(grp.ids);
      btn.className = 'ir-col-group-toggle';
      btn.style.cssText = `padding:2px 10px;border-radius:999px;border:2px solid ${grp.color};
        background:${active ? grp.color : 'transparent'};color:${active ? '#fff' : grp.color};
        font-size:0.72rem;font-weight:600;cursor:pointer;white-space:nowrap;`;
      btn.textContent = grp.label;
      bar.appendChild(btn);
    }

    // Divider
    const divider = document.createElement('span');
    divider.style.cssText = 'width:1px;height:16px;background:var(--color-border);align-self:center;margin:0 4px;flex-shrink:0;';
    bar.appendChild(divider);

    // ── Individual column toggles ────────────────────────────────────────────
    bar.insertAdjacentHTML('beforeend', '<span style="font-size:0.72rem;color:var(--color-muted);margin-right:2px;white-space:nowrap;">Columns:</span>');

    // Extra toggles: All Players panel + Unassigned column
    const extras = [
      { key: 'alpha', label: 'All Players', color: '#475569' },
      { key: 'null',  label: 'Unassigned',  color: '#6b7280' },
    ];
    for (const { key, label, color } of extras) {
      const hidden = this.hiddenColumns.has(key);
      const btn = document.createElement('button');
      btn.dataset.colKey = key;
      btn.className = 'ir-col-toggle';
      btn.style.cssText = `padding:2px 8px;border-radius:999px;border:2px solid ${color};
        background:${hidden ? 'transparent' : color};color:${hidden ? color : '#fff'};
        font-size:0.72rem;font-weight:600;cursor:pointer;white-space:nowrap;`;
      btn.textContent = label;
      bar.appendChild(btn);
    }

    // Team column toggles (skip Unassigned since handled above)
    for (const col of this.teams) {
      const key   = String(col.id);
      const hidden = this.hiddenColumns.has(key);
      const color  = this.columnHeaderColor(col.id);
      const btn = document.createElement('button');
      btn.dataset.colKey = key;
      btn.className = 'ir-col-toggle';
      btn.style.cssText = `padding:2px 8px;border-radius:999px;border:2px solid ${color};
        background:${hidden ? 'transparent' : color};color:${hidden ? color : '#fff'};
        font-size:0.72rem;font-weight:600;cursor:pointer;white-space:nowrap;`;
      btn.textContent = col.name;
      bar.appendChild(btn);
    }
  }

  renderAlphaList() {
    const panel = this.find('#ir-alpha-panel');
    const search = this.filterText.toLowerCase();
    let players = [...this.players];
    if (search) players = players.filter(p =>
      (p.firstName + ' ' + p.lastName).toLowerCase().includes(search)
    );

    // ── Collect available source options from player data ────────────────────
    const gmChats = new Set();
    const officialTeamNames = new Set();
    for (const p of this.players) {
      if (p.groupMeChats) p.groupMeChats.split(', ').forEach(c => gmChats.add(c));
      if (p.officialTeams) p.officialTeams.split(', ').forEach(t => officialTeamNames.add(t));
    }

    // Apply source filters
    if (this.activeSourceFilters.size > 0) {
      players = players.filter(p => {
        for (const src of this.activeSourceFilters) {
          if (src.startsWith('gm:')) {
            const chat = src.slice(3);
            if (p.groupMeChats && p.groupMeChats.split(', ').includes(chat)) return true;
          } else {
            const team = src.slice(3);
            if (p.officialTeams && p.officialTeams.split(', ').includes(team)) return true;
          }
        }
        return false;
      });
    }

    players.sort((a, b) => {
      const la = (a.lastName || '').toLowerCase(), lb = (b.lastName || '').toLowerCase();
      if (la !== lb) return la < lb ? -1 : 1;
      const fa = (a.firstName || '').toLowerCase(), fb = (b.firstName || '').toLowerCase();
      return fa < fb ? -1 : fa > fb ? 1 : 0;
    });

    // Detect duplicates across full unfiltered list
    const nameCounts = {};
    for (const p of this.players) {
      const key = ((p.firstName || '') + '|' + (p.lastName || '')).toLowerCase();
      nameCounts[key] = (nameCounts[key] || 0) + 1;
    }

    const abbr = { 901: 'TCW', 902: 'U23W', 903: 'U23M', 904: 'BRA', 905: 'PR', 906: 'Pool', 907: 'APSL', 908: 'L1', 909: 'L2' };

    const rows = players.map(p => {
      const key = ((p.firstName || '') + '|' + (p.lastName || '')).toLowerCase();
      const isDup = nameCounts[key] > 1;
      const name = this.escapeHtml((p.lastName || '—') + ', ' + (p.firstName || ''));
      const year = p.birthYear ? String(p.birthYear).substring(0, 4) : '';
      const teamTags = (p.workingTeamIds || []).map(tid =>
        `<span style="background:${this.columnHeaderColor(tid)};color:#fff;
                      padding:1px 4px;border-radius:3px;font-size:0.62rem;flex-shrink:0;">${abbr[tid] || '?'}</span>`
      ).join('');
      const dupTag = isDup
        ? '<span style="background:#d97706;color:#fff;padding:1px 4px;border-radius:3px;font-size:0.62rem;flex-shrink:0;">DUP</span>'
        : '';
      const bg = isDup ? 'rgba(217,119,6,0.1)' : 'transparent';
      const border = isDup ? '1px solid rgba(217,119,6,0.3)' : '1px solid transparent';
      return `
        <div draggable="true" data-player-id="${p.playerId}"
             style="padding:3px 6px;border-radius:4px;background:${bg};border:${border};cursor:grab;position:relative;">
          <div style="display:flex;align-items:center;gap:3px;justify-content:space-between;padding-right:18px;">
            <span style="font-size:0.75rem;line-height:1.3;min-width:0;overflow:hidden;
                         text-overflow:ellipsis;white-space:nowrap;">${name}</span>
            <div style="display:flex;gap:2px;flex-shrink:0;">${dupTag}${teamTags}</div>
          </div>
          ${year ? `<div style="font-size:0.67rem;color:var(--color-muted);">${year}</div>` : ''}
          <button class="ir-delete-btn" data-player-id="${p.playerId}"
                  style="position:absolute;top:50%;right:3px;transform:translateY(-50%);
                         width:16px;height:16px;border-radius:50%;background:#6b7280;color:#fff;
                         border:none;cursor:pointer;font-size:0.7rem;line-height:16px;display:none;
                         align-items:center;justify-content:center;padding:0;z-index:2;"
                  title="Delete player">×</button>
        </div>`;
    }).join('');

    // ── Filter section HTML ─────────────────────────────────────────────────
    const makeSrcPill = (src, label) => {
      const active = this.activeSourceFilters.has(src);
      const bg     = active ? '#f59e0b' : 'transparent';
      const border = active ? '#f59e0b' : '#374151';
      const color  = active ? '#1e3a8a' : '#6b7280';
      return `<span data-src-key="${this.escapeHtml(src)}" style="cursor:pointer;padding:2px 7px;border-radius:8px;font-size:0.62rem;font-weight:500;white-space:nowrap;flex-shrink:0;border:1px solid ${border};background:${bg};color:${color}">${this.escapeHtml(label)}</span>`;
    };
    let filterSection = '';
    if (gmChats.size > 0 || officialTeamNames.size > 0) {
      let inner = '';
      if (gmChats.size > 0) {
        const pills = [...gmChats].sort().map(c => makeSrcPill('gm:' + c, c)).join('');
        inner += `<div style="display:flex;flex-wrap:wrap;gap:3px;${officialTeamNames.size > 0 ? 'margin-bottom:3px;' : ''}">${pills}</div>`;
      }
      if (officialTeamNames.size > 0) {
        const pills = [...officialTeamNames].sort().map(t => makeSrcPill('ot:' + t, t)).join('');
        inner += `<div style="display:flex;flex-wrap:wrap;gap:3px;">${pills}</div>`;
      }
      filterSection = `<div style="padding:5px 8px;border-bottom:1px solid #374151;">${inner}</div>`;
    }

    panel.innerHTML = `
      <div style="padding:8px 10px;font-weight:700;font-size:0.75rem;color:#fff;
                  text-transform:uppercase;letter-spacing:0.05em;border-bottom:2px solid #f59e0b;
                  background:#1e3a8a;position:sticky;top:0;z-index:1;">
        All Players (${players.length})
      </div>
      ${filterSection}
      <div style="padding:4px 6px;display:flex;flex-direction:column;gap:2px;">${rows}</div>`;

    // Source filter pill click handlers
    panel.querySelectorAll('[data-src-key]').forEach(pill => {
      pill.addEventListener('click', () => {
        const key = pill.dataset.srcKey;
        if (this.activeSourceFilters.has(key)) this.activeSourceFilters.delete(key);
        else this.activeSourceFilters.add(key);
        this.renderAlphaList();
      });
    });

    panel.querySelectorAll('[data-player-id]').forEach(el => {
      const playerId = parseInt(el.dataset.playerId);
      const delBtn = el.querySelector('.ir-delete-btn');
      el.addEventListener('mouseenter', () => { delBtn.style.display = 'flex'; });
      el.addEventListener('mouseleave', () => { delBtn.style.display = 'none'; });
      el.addEventListener('dragstart', e => {
        this.dragPlayerId = playerId;
        el.style.opacity = '0.45';
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/plain', String(playerId));
      });
      el.addEventListener('dragend', () => {
        el.style.opacity = '1';
        this.dragPlayerId = null;
        this.find('#ir-board').querySelectorAll('.ir-card-list').forEach(l => {
          l.style.background = '';
          l.style.outline = '';
        });
      });
      el.addEventListener('click', e => {
        if (e.target.closest('.ir-delete-btn')) return;
        if (this.dragPlayerId !== null) return;
        const player = this.players.find(p => p.playerId === playerId);
        if (player) this.openPlayerCard(player);
      });
    });
  }

  officialBadges(p) {
    const badges = [];
    if (p.eligApslStarter || p.eligApslBench)
      badges.push('<span style="background:#1d4ed8;color:#fff;padding:1px 4px;border-radius:3px;font-size:0.65rem;">APSL</span>');
    if (p.eligLiga1Starter || p.eligLiga1Bench)
      badges.push('<span style="background:#047857;color:#fff;padding:1px 4px;border-radius:3px;font-size:0.65rem;">L1</span>');
    if (p.eligLiga2Starter || p.eligLiga2Bench)
      badges.push('<span style="background:#b45309;color:#fff;padding:1px 4px;border-radius:3px;font-size:0.65rem;">L2</span>');
    if (p.isInjured)
      badges.push('<span style="background:#dc2626;color:#fff;padding:1px 4px;border-radius:3px;font-size:0.65rem;">INJ</span>');
    return badges.join('');
  }

  // ── Depth chart ───────────────────────────────────────────────────────────────

  getColChart(colId) {
    if (!this.depthChart.has(colId)) this.depthChart.set(colId, new Array(33).fill(null));
    return this.depthChart.get(colId);
  }

  slotPlayer(playerId, colId, di, si) {
    const chart = this.getColChart(colId);
    // Remove player from any other slot in this column first
    for (let i = 0; i < chart.length; i++) { if (chart[i] === playerId) chart[i] = null; }
    chart[di * 11 + si] = playerId;
    this.saveDepthChartToStorage();
    const player = this.players.find(p => p.playerId === playerId);
    if (player && colId !== null && !player.workingTeamIds.includes(colId)) {
      this.addToTeam(playerId, colId); // addToTeam calls renderBoard
      return;
    }
    this.renderBoard();
  }

  removeFromDepthSlot(colId, di, si) {
    const chart    = this.getColChart(colId);
    const idx      = di * 11 + si;
    const playerId = chart[idx];
    if (!playerId) return;
    chart[idx] = null;
    this.saveDepthChartToStorage();
    if (!chart.some(id => id === playerId)) {
      this.unassignFromTeam(playerId, colId); // calls renderBoard
      return;
    }
    this.renderBoard();
  }

  saveDepthChartToStorage() {
    try {
      const obj = {};
      for (const [k, v] of this.depthChart.entries()) obj[k === null ? 'null' : String(k)] = v;
      localStorage.setItem('ir-depth-chart', JSON.stringify(obj));
    } catch (e) {}
  }

  loadDepthChartFromStorage() {
    try {
      const raw = localStorage.getItem('ir-depth-chart');
      if (!raw) return;
      for (const [k, v] of Object.entries(JSON.parse(raw)))
        this.depthChart.set(k === 'null' ? null : parseInt(k), v);
    } catch (e) { this.depthChart = new Map(); }
  }

  saveColumnOrderToStorage() {
    try {
      localStorage.setItem('ir-column-order', JSON.stringify([...this.columnOrder.entries()]));
    } catch (e) {}
  }

  loadColumnOrderFromStorage() {
    try {
      const raw = localStorage.getItem('ir-column-order');
      this.columnOrder = raw ? new Map(JSON.parse(raw)) : new Map();
    } catch (e) {
      this.columnOrder = new Map();
    }
  }

  playerStatusIcon(p) {
    if (p.isInjured) return '&#x1FA79;';
    if (p.isSuspendedLeague || p.isSuspendedInhouse) return '&#x1F6AB;';
    const hasElig = p.eligApslStarter || p.eligApslBench ||
                    p.eligLiga1Starter || p.eligLiga1Bench ||
                    p.eligLiga2Starter || p.eligLiga2Bench;
    return hasElig ? '&#x2705;' : '&#x26AA;';
  }

  getOtherDimensionTag(player, colId) {
    const abbr  = { 901:'TCW', 902:'U23W', 903:'U23M', 904:'BRA', 905:'PR', 906:'Pool', 907:'APSL', 908:'L1', 909:'L2' };
    const SQUAD  = new Set([901, 902, 903, 904, 905, 906]);
    const LEAGUE = new Set([907, 908, 909]);
    const tags = [];
    for (const tid of (player.workingTeamIds || [])) {
      const show = colId === null
        ? true
        : (SQUAD.has(colId)  && LEAGUE.has(tid))
        || (LEAGUE.has(colId) && SQUAD.has(tid));
      if (show) {
        tags.push(`<span style="background:${this.columnHeaderColor(tid)};color:#fff;padding:0 4px;border-radius:3px;font-size:0.6rem;">${abbr[tid]||'?'}</span>`);
      }
    }
    return tags.join('');
  }

  columnHeaderColor(teamId) {
    const colors = {
      901: '#7c3aed',  // Tri County Women – purple
      902: '#be185d',  // U23 Women – pink
      903: '#1d4ed8',  // U23 Men – blue
      904: '#15803d',  // Brazil – green
      905: '#b91c1c',  // Puerto Rico – red
      906: '#374151',  // Pool – dark gray
      907: '#1e40af',  // APSL – dark blue
      908: '#065f46',  // Liga 1 – dark emerald
      909: '#92400e',  // Liga 2 – dark amber
    };
    return teamId === null ? '#6b7280' : (colors[teamId] || '#4b5563');
  }
}
