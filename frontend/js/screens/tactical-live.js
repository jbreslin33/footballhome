// TacticalLiveScreen — #tactical-live — the meeting board the PLAYERS drive
// (owner 2026-10-19: "how quick can we get one up that the players can use
// during tonights meeting. the feature we need is for them to control thier
// own piece via drag" / "name on piece coudl defulat to their last name
// unless they over ride").
//
// A coach starts a board for a team (one open board at a time); pieces are
// seeded from the roster, one per player, labelled with his LAST NAME.
// Each signed-in player drags only his own piece (server-enforced); the
// ball is everyone's; coaches drag anything.  Moves ride the existing
// Postgres NOTIFY → /api/stream SSE pipe (fn_tactical_live_notify, mig
// 606), so every phone follows live; a slow poll heals missed events.
// All wording is the DB's (MessageCopy 'tactical_live').
class TacticalLiveScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.board = null;        // {id, teamId, teamName, title, closedAt}
    this.pieces = [];         // [{id, personId, label, kind, x, y}]
    this.viewer = null;       // {personId, isStaff}
    this.teams = [];          // staff only: teams a board can start for
    this._es = null;          // EventSource
    this._pollTimer = null;
    this._drag = null;        // {pieceId, moved, lastSentAt}
    this._selectedPieceId = null; // rename target
  }

  _copy(tier, tokens = {}) {
    return window.MessageCopy ? MessageCopy.block('tactical_live', tier, tokens) : '';
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>♟️ <span data-tl-title>Live Tactical Board</span></h1>
        <p class="subtitle" data-tl-sub></p>
      </div>
      <div style="padding: var(--space-3); max-width: 560px; margin: 0 auto;">
        <div data-tl-staff hidden style="display:flex; gap:var(--space-2); flex-wrap:wrap; align-items:center; margin-bottom:var(--space-2);"></div>
        <div data-tl-empty hidden style="padding: var(--space-4); text-align:center; opacity:0.8;"></div>
        <div data-tl-pitchwrap hidden>
          <div data-tl-pitch style="position:relative; width:100%; aspect-ratio: 2 / 3; max-width:100%;
               background:#1a7a3a; border:2px solid rgba(255,255,255,0.7); border-radius:8px;
               touch-action:none; overflow:hidden; user-select:none; -webkit-user-select:none;">
            <svg viewBox="0 0 100 150" preserveAspectRatio="none"
                 style="position:absolute; inset:0; width:100%; height:100%; pointer-events:none;">
              <g stroke="rgba(255,255,255,0.55)" stroke-width="0.6" fill="none">
                <line x1="0" y1="75" x2="100" y2="75"/>
                <circle cx="50" cy="75" r="12"/>
                <rect x="22" y="0" width="56" height="16"/>
                <rect x="22" y="134" width="56" height="16"/>
                <rect x="38" y="0" width="24" height="6"/>
                <rect x="38" y="144" width="24" height="6"/>
              </g>
            </svg>
          </div>
          <div style="display:flex; gap:var(--space-2); align-items:center; flex-wrap:wrap; margin-top:var(--space-2);">
            <input data-tl-rename maxlength="20" hidden
                   style="flex:1; min-width:140px; padding:8px; border-radius:8px;
                          border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary);">
            <button class="btn btn-primary" data-tl-rename-save hidden style="min-width:0; min-height:0; padding:8px 14px;">✓</button>
          </div>
        </div>
      </div>`;
    this.element = div;

    div.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      const start = e.target.closest('[data-tl-start]');
      if (start) { this._startBoard(); return; }
      const close = e.target.closest('[data-tl-close]');
      if (close) { this._closeBoard(); return; }
      const save = e.target.closest('[data-tl-rename-save]');
      if (save) { this._saveRename(); return; }
    });

    const pitch = div.querySelector('[data-tl-pitch]');
    pitch.addEventListener('pointerdown', (e) => this._onPointerDown(e));
    pitch.addEventListener('pointermove', (e) => this._onPointerMove(e));
    pitch.addEventListener('pointerup',   (e) => this._onPointerUp(e));
    pitch.addEventListener('pointercancel', (e) => this._onPointerUp(e));
    return div;
  }

  async onEnter(params) {
    this._boardIdParam = params?.board || null;
    await this._load();
    this._connectStream();
    this._pollTimer = setInterval(() => this._load(true), 7000);
  }

  onExit() {
    if (this._es) { try { this._es.close(); } catch {} this._es = null; }
    if (this._pollTimer) { clearInterval(this._pollTimer); this._pollTimer = null; }
  }

  async _load(quiet) {
    try {
      const q = this._boardIdParam ? `?id=${encodeURIComponent(this._boardIdParam)}` : '';
      const res = await this.auth.fetch(`/api/tactical-live/board${q}`);
      const data = await res.json().catch(() => null);
      if (!res.ok || !data?.success) return;
      this.board = data.board; this.viewer = data.viewer; this.teams = data.teams || [];
      // Never clobber the piece being dragged with a stale poll.
      const draggingId = this._drag?.pieceId;
      const held = draggingId ? this.pieces.find(p => p.id === draggingId) : null;
      this.pieces = data.pieces || [];
      if (held) {
        const fresh = this.pieces.find(p => p.id === draggingId);
        if (fresh) { fresh.x = held.x; fresh.y = held.y; }
      }
      this._renderBoard();
    } catch (err) {
      if (!quiet) console.warn('[tactical-live] load failed:', err);
    }
  }

  // ── Live updates: NOTIFY → SSE, same pipe as the lineup boards ──────
  _connectStream() {
    if (this._es) return;
    const token = localStorage.getItem('token');
    if (!token) return;
    try {
      this._es = new EventSource(`/api/stream?token=${encodeURIComponent(token)}`);
      this._es.onmessage = (ev) => {
        let msg = null;
        try { msg = JSON.parse(ev.data); } catch { return; }
        if (msg?.kind !== 'tactical_live' || !this.board || msg.board_id !== this.board.id) return;
        const pc = msg.piece;
        if (!pc) return;
        if (this._drag && this._drag.pieceId === pc.id) return;  // my own echo mid-drag
        const mine = this.pieces.find(p => p.id === pc.id);
        if (!mine) { this._load(true); return; }                 // new piece — refetch
        mine.x = Number(pc.x); mine.y = Number(pc.y); mine.label = pc.label;
        this._positionPiece(mine);
      };
    } catch (err) {
      console.warn('[tactical-live] SSE failed, poll covers it:', err);
    }
  }

  // ── Rendering ────────────────────────────────────────────────────────
  _renderBoard() {
    const titleEl = this.find('[data-tl-title]');
    if (titleEl) titleEl.textContent = this._copy('title') || 'Live Tactical Board';
    const sub = this.find('[data-tl-sub]');
    const empty = this.find('[data-tl-empty]');
    const wrap = this.find('[data-tl-pitchwrap]');
    const staff = this.find('[data-tl-staff]');
    const isStaff = !!this.viewer?.isStaff;

    if (staff) {
      staff.hidden = !isStaff;
      if (isStaff) {
        const opts = this.teams.map(t => `<option value="${t.id}">${this.escapeHtml(t.name)}</option>`).join('');
        staff.innerHTML = `
          <select data-tl-team style="padding:8px; border-radius:8px; border:1px solid var(--border-color);
                  background:var(--bg-primary); color:var(--text-primary); max-width:220px;">${opts}</select>
          <button class="btn btn-primary" data-tl-start style="min-width:0; min-height:0; padding:8px 12px;">
            ${this.escapeHtml((this._copy('start', { team: '' }) || 'Start a board').replace('{team}', '').trim())}</button>
          ${this.board && !this.board.closedAt ? `<button class="btn btn-secondary" data-tl-close
              style="min-width:0; min-height:0; padding:8px 12px;">${this.escapeHtml(this._copy('close') || 'End this board')}</button>` : ''}`;
      }
    }

    if (!this.board || this.board.closedAt) {
      if (wrap) wrap.hidden = true;
      if (empty) { empty.hidden = false; empty.textContent = this._copy('no_board') || 'No live board is open right now.'; }
      if (sub) sub.textContent = '';
      return;
    }
    if (empty) empty.hidden = true;
    if (wrap) wrap.hidden = false;
    if (sub) {
      sub.textContent = `${this.board.teamName}${this.board.title ? ' — ' + this.board.title : ''} · ` +
        (isStaff ? (this._copy('hint_coach') || 'You can drag every piece.')
                 : (this._copy('hint_player') || 'Drag your piece — everyone sees it move.'));
    }

    const pitch = this.find('[data-tl-pitch]');
    if (!pitch) return;
    for (const el of pitch.querySelectorAll('[data-tl-piece]')) el.remove();
    for (const p of this.pieces) pitch.appendChild(this._pieceEl(p));
    this._syncRenameInput();
  }

  _canDrag(p) {
    return !!this.viewer && (this.viewer.isStaff || p.kind === 'ball' || p.personId === this.viewer.personId);
  }

  _pieceEl(p) {
    const mine = p.personId && this.viewer && p.personId === this.viewer.personId;
    const el = document.createElement('div');
    el.dataset.tlPiece = p.id;
    const size = p.kind === 'ball' ? 26 : 44;   // 44px touch targets for people
    const bg = p.kind === 'ball' ? '#f5f5f5' : p.kind === 'opponent' ? '#7a1a1a' : '#14328c';
    el.style.cssText = `position:absolute; width:${size}px; height:${size}px; margin-left:${-size / 2}px; margin-top:${-size / 2}px;
      border-radius:50%; background:${bg}; display:flex; align-items:center; justify-content:center;
      color:#fff; font-size:0.6rem; font-weight:700; text-align:center; line-height:1;
      box-shadow:0 2px 5px rgba(0,0,0,0.45); ${mine ? 'outline:3px solid #ffd54a;' : ''}
      cursor:${this._canDrag(p) ? 'grab' : 'default'}; touch-action:none;`;
    if (p.kind !== 'ball') {
      const label = document.createElement('span');
      label.style.cssText = 'pointer-events:none; padding:2px; overflow:hidden; max-width:100%;';
      label.textContent = p.kind === 'opponent' ? (p.label || 'X') : (p.label || '?');
      el.appendChild(label);
    } else {
      el.textContent = '⚽';
    }
    this._positionPiece(p, el);
    return el;
  }

  _positionPiece(p, el) {
    const node = el || this.find(`[data-tl-piece="${p.id}"]`);
    if (!node) return;
    node.style.left = `${Number(p.x) * 100}%`;
    node.style.top = `${Number(p.y) * 100}%`;
  }

  // ── Drag ─────────────────────────────────────────────────────────────
  _pieceFromEvent(e) {
    const el = e.target.closest('[data-tl-piece]');
    if (!el) return null;
    return this.pieces.find(p => p.id === Number(el.dataset.tlPiece)) || null;
  }

  _onPointerDown(e) {
    const p = this._pieceFromEvent(e);
    if (!p) return;
    if (!this._canDrag(p)) {
      // Tap on someone else's piece: say whose it is (copy from the DB).
      const sub = this.find('[data-tl-sub]');
      if (sub && p.kind === 'player') sub.textContent = (this._copy('not_yours', { name: p.label }) || `Only ${p.label} can move that piece.`);
      return;
    }
    e.preventDefault();
    const pitch = this.find('[data-tl-pitch]');
    try { pitch.setPointerCapture(e.pointerId); } catch {}
    this._drag = { pieceId: p.id, startX: e.clientX, startY: e.clientY, moved: false, lastSentAt: 0 };
  }

  _onPointerMove(e) {
    if (!this._drag) return;
    const p = this.pieces.find(x => x.id === this._drag.pieceId);
    if (!p) return;
    if (Math.abs(e.clientX - this._drag.startX) + Math.abs(e.clientY - this._drag.startY) > 5) this._drag.moved = true;
    const rect = this.find('[data-tl-pitch]').getBoundingClientRect();
    p.x = Math.min(1, Math.max(0, (e.clientX - rect.left) / rect.width));
    p.y = Math.min(1, Math.max(0, (e.clientY - rect.top) / rect.height));
    this._positionPiece(p);
    const now = Date.now();
    if (now - this._drag.lastSentAt > 150) {   // live for the room, light on the server
      this._drag.lastSentAt = now;
      this._sendMove(p);
    }
  }

  _onPointerUp(e) {
    if (!this._drag) return;
    const drag = this._drag;
    const p = this.pieces.find(x => x.id === drag.pieceId);
    this._drag = null;
    if (!p) return;
    if (drag.moved) { this._sendMove(p); return; }
    // A tap (no drag): select my piece for renaming.
    if (p.kind === 'player' && (this.viewer?.isStaff || p.personId === this.viewer?.personId)) {
      this._selectedPieceId = p.id;
      this._syncRenameInput();
    }
  }

  async _sendMove(p) {
    try {
      await this.auth.fetch(`/api/tactical-live/pieces/${p.id}/move`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ x: p.x, y: p.y }),
      });
    } catch (err) { /* next throttle tick or the poll heals it */ }
  }

  // ── Rename (default is the roster last name; this is the override) ──
  _syncRenameInput() {
    const input = this.find('[data-tl-rename]');
    const save = this.find('[data-tl-rename-save]');
    if (!input || !save) return;
    const p = this.pieces.find(x => x.id === this._selectedPieceId);
    const canRename = p && p.kind === 'player' && (this.viewer?.isStaff || p.personId === this.viewer?.personId);
    input.hidden = save.hidden = !canRename;
    if (canRename) {
      input.placeholder = this._copy('rename_ph') || 'Name on your piece';
      input.value = p.label || '';
    }
  }

  async _saveRename() {
    const input = this.find('[data-tl-rename]');
    const p = this.pieces.find(x => x.id === this._selectedPieceId);
    if (!input || !p) return;
    const label = input.value.trim();
    if (!label) return;
    try {
      const res = await this.auth.fetch(`/api/tactical-live/pieces/${p.id}/label`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ label }),
      });
      if (res.ok) {
        p.label = label;
        this._renderBoard();
      }
    } catch (err) { console.warn('[tactical-live] rename failed:', err); }
  }

  // ── Staff actions ────────────────────────────────────────────────────
  async _startBoard() {
    const sel = this.find('[data-tl-team]');
    const teamId = Number(sel?.value || 0);
    if (!teamId) return;
    try {
      const res = await this.auth.fetch('/api/tactical-live/boards', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ team_id: teamId }),
      });
      if (res.ok) { this._boardIdParam = null; await this._load(); }
    } catch (err) { console.warn('[tactical-live] start failed:', err); }
  }

  async _closeBoard() {
    if (!this.board) return;
    try {
      const res = await this.auth.fetch(`/api/tactical-live/boards/${this.board.id}/close`, { method: 'POST' });
      if (res.ok) await this._load();
    } catch (err) { console.warn('[tactical-live] close failed:', err); }
  }
}
