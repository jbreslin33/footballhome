// ⚔️ Lineup editing — split squad, bench, the position / bench / move / swap sheets, drafts (mig 495), compare, save
//
// Part of GameCenterScreen (screens/game-center.js), split into its own file
// 2026-11-16 (owner: "practice and games should be consistent interface and
// extend from same base class") so the game child of EventScreen stays slim:
// these methods are copied onto GameCenterScreen's prototype by Mixin.into
// (lib/mixin.js) — `this` is the screen, exactly as before the move.

class GameCenterLineupEdit {
  // Split squad on: every position still without a 2nd takes the next
  // unpaired bench player (bench order, outfield first, keeper last).
  _toggleSplitSquad() {
    this.splitSquad = !this.splitSquad;
    if (this.splitSquad) this._fillSecondSpots();
    this._render();
    this._scheduleSave();
  }

  _openSecondSpots() {
    const { startingPositions } = this._slotMaps();
    const isGk = (pos) => (pos.abbreviation || '').toUpperCase() === 'GK';
    return startingPositions.filter(pos => !this._sharersOf(pos.id).length)
      .sort((a, b) => (isGk(a) - isGk(b)) || (a.sortOrder - b.sortOrder));
  }

  _fillSecondSpots() {
    const free = [...this.zones.entries()].filter(([pid, z]) => z === 'bench' && !this.shares.has(pid)).map(([pid]) => pid)
      .sort((a, b) => (this.benchOrder.get(a) ?? Infinity) - (this.benchOrder.get(b) ?? Infinity));
    for (const pos of this._openSecondSpots()) {
      const pid = free.shift(); if (pid == null) break;
      this.shares.set(pid, { pos: pos.id, order: 2 });
    }
    this._normShares();
  }

  // Bench slot for a newcomer: after everyone already there.
  _nextBenchOrder(excludeId) {
    let n = 0;
    for (const [pid, z] of this.zones.entries()) if (z === 'bench' && pid !== excludeId) n++;
    return n + 1;
  }

  // Match-day squad (mig 760).  The bench is full when it already holds
  // benchCap players other than `playerId`.
  _benchCapNow() { return Number.isInteger(this.benchCap) ? this.benchCap : DEFAULT_BENCH_CAP; }

  _benchFull(playerId) {
    if (this.zones.get(playerId) === 'bench') return false;
    return [...this.zones.values()].filter(z => z === 'bench').length >= this._benchCapNow();
  }

  _squadTokens() {
    return { cap: this._benchCapNow(), squad: this.squadSize, next: this.squadSize + 1, team_squad: this.teamSquadSize };
  }

  // "Extend to an N-man squad — this game only": one more bench spot on
  // this game; the next save carries squadSize and the server stores it
  // on match_lineup_metadata.squad_size.  Official lineup only — a
  // personal draft has no cap to extend.
  _canExtendSquad() { return this.isCoach && !this._isDraftView(); }

  _extendSquad() {
    this.squadSize += 1;
    this.benchCap = this._benchCapNow() + 1;
    this._pendingSquadSize = this.squadSize;
  }

  _swapCopy(tier, tokens) {
    return window.MessageCopy ? MessageCopy.block('lineup_swap', tier, tokens) : '';
  }

  // "{spot}" for a placement: "6 · Centre Midfield", "Bench #3",
  // "Alternates", "off the lineup".
  _spotText(pl) {
    if (pl.zone === 'starter') {
      const pos = this.positionList.find(x => x.id === pl.positionId);
      return this._swapCopy('spot_position', { number: pos?.sortOrder ?? '', position: pos?.name ?? '' });
    }
    if (pl.zone === 'bench' && pl.share) {
      const pos = this.positionList.find(x => x.id === pl.share.pos);
      const t = this._swapCopy('spot_share', { nth: this._nth(pl.share.order), position: pos?.name || '' });
      if (t) return t;
    }
    if (pl.zone === 'bench') return this._swapCopy('spot_bench', { n: pl.benchOrder ?? this._nextBenchOrder() });
    if (pl.zone === 'alternate') return this._swapCopy('spot_alt', {});
    return this._swapCopy('spot_off', {});
  }

  // Luke (playerId) tapped Caleb's (holderId) position.
  _openPositionSheet(playerId, positionId, holderId) {
    const player = this.roster.find(p => p.id === playerId);
    const other  = this.roster.find(p => p.id === holderId);
    const pos    = this.positionList.find(x => x.id === positionId);
    if (!player || !other || !pos) return false;
    const tk = { player: player.name, other: other.name, position: pos.name, number: pos.sortOrder, ...this._squadTokens() };
    const title = this._swapCopy('position_title', tk);
    if (!title) return false;   // copy not loaded → caller keeps the old path

    const mine = this._placementOf(playerId);
    // {other} heads to the bench, so it is full when it already holds the cap.
    const benchFull = mine.zone !== 'bench' && this._benchFull(holderId);
    const canExtend = benchFull && this._canExtendSquad();
    const rows = [];
    rows.push({
      label: mine.zone ? this._swapCopy('swap', { ...tk, spot: this._spotText(mine) }) : this._swapCopy('swap_off', tk),
      run: () => this._swapPlayers(playerId, holderId),
    });
    // "to Bench" / "to Alternates" only where they differ from Swap.
    if (mine.zone !== 'bench') {
      rows.push({
        label: this._swapCopy('to_bench', tk),
        note: canExtend ? this._swapCopy('to_bench_extend', tk) : benchFull ? this._swapCopy('bench_full', tk) : '',
        disabled: benchFull && !canExtend,
        run: () => {
          if (benchFull) this._extendSquad();
          this._applyPlacement(holderId, { zone: 'bench', positionId: null, benchOrder: this._nextBenchOrder(playerId) });
          this._applyPlacement(playerId, { zone: 'starter', positionId, benchOrder: null });
        },
      });
    }
    if (mine.zone !== 'alternate') {
      rows.push({
        label: this._swapCopy('to_alt', tk),
        run: () => {
          this._applyPlacement(holderId, { zone: 'alternate', positionId: null, benchOrder: null });
          this._applyPlacement(playerId, { zone: 'starter', positionId, benchOrder: null });
        },
      });
    }
    // Or share it (mig 763): {player} comes on for {other} — or, already
    // sharing it, stops.
    if (mine.share && mine.share.pos === positionId) {
      const label = this._swapCopy('unshare', tk);
      if (label) rows.push({ label, run: () => { this.shares.delete(playerId); } });
    } else {
      const nth = this._nth(this._sharersOf(positionId).length + 2);
      const label = this._swapCopy('share', { ...tk, nth });
      const shareFull = mine.zone !== 'bench' && this._benchFull(playerId) && !this._canExtendSquad();
      if (label) rows.push({
        label,
        note: shareFull ? this._swapCopy('bench_full', tk) : mine.zone !== 'bench' ? this._swapCopy('share_note', tk) : '',
        disabled: shareFull,
        run: () => { this._sharePosition(playerId, positionId); },
      });
    }
    this._openSwapSheet({ title, sub: this._swapCopy('position_sub', tk), rows });
    return true;
  }

  // Luke (playerId) tapped Bench while it is full: pick who comes off.
  _openBenchSheet(playerId) {
    const player = this.roster.find(p => p.id === playerId);
    if (!player) return false;
    const tk = { player: player.name, ...this._squadTokens() };
    const title = this._swapCopy('bench_title', tk);
    if (!title) return false;
    const mine = this._placementOf(playerId);
    const benchIds = [...this.zones.entries()].filter(([, z]) => z === 'bench').map(([id]) => id)
      .sort((a, b) => (this.benchOrder.get(a) ?? Infinity) - (this.benchOrder.get(b) ?? Infinity));
    const rows = benchIds.map((id, i) => {
      const other = this.roster.find(p => p.id === id);
      return {
        label: other?.name || '(unnamed)',
        note: this._swapCopy('bench_row', { ...tk, other: other?.name || '', n: this.benchOrder.get(id) ?? (i + 1), spot: this._spotText(mine) }),
        run: () => this._swapPlayers(playerId, id),
      };
    });
    // Or keep everyone: one more bench spot, this game only (mig 760).
    const extendLabel = this._canExtendSquad() ? this._swapCopy('extend', tk) : '';
    if (extendLabel) {
      rows.unshift({
        label: extendLabel,
        note: this._swapCopy('extend_note', tk),
        run: () => {
          this._extendSquad();
          this._applyPlacement(playerId, { zone: 'bench', positionId: null, benchOrder: this._nextBenchOrder(playerId) });
        },
      });
    }
    this._openSwapSheet({ title, sub: this._swapCopy('bench_sub', tk), rows });
    return true;
  }

  // Tapped on the live graphic: where should {player} go?  The 1-N
  // position grid (their own slot lit, a taken slot greyed and handing
  // off to _openPositionSheet), then Bench (full → _openBenchSheet),
  // Alternates, Unassign.  Copy: kind='lineup_move' (migration 454).
  _openMoveSheet(playerId) {
    const player = this.roster.find(p => p.id === playerId);
    if (!player) return false;
    const mine = this._placementOf(playerId);
    const tk = { player: player.name, spot: this._spotText(mine) };
    const copy = (tier, t = tk) => window.MessageCopy ? MessageCopy.block('lineup_move', tier, t) : '';
    const title = copy('title');
    if (!title) return false;

    const { rosterById, slotToPlayerId, startingPositions } = this._slotMaps();
    const benchFull = this._benchFull(playerId);

    const grid = startingPositions.map(pos => {
      const holderId = slotToPlayerId.get(pos.id);
      const isMine = holderId === playerId;
      const taken = holderId != null && !isMine;
      return {
        label: String(pos.sortOrder),
        title: taken ? copy('taken', { ...tk, other: rosterById.get(holderId)?.name || '' }) : pos.name,
        active: isMine, taken,
        run: () => {
          if (isMine) return;
          if (taken) { if (!this._openPositionSheet(playerId, pos.id, holderId)) { this._setPosition(playerId, pos.id); } return; }
          this._setPosition(playerId, pos.id);
        },
      };
    });
    const current = copy('current');
    const rows = [
      { label: copy('bench'), note: mine.zone === 'bench' ? current : '', disabled: mine.zone === 'bench',
        run: () => {
          if (benchFull) {   // hands off to the bench picker, which saves itself
            if (!this._openBenchSheet(playerId)) this._toast(`Bench is full (${this._benchCapNow()} max)`);
            return false;
          }
          this._applyPlacement(playerId, { zone: 'bench', positionId: null, benchOrder: this._nextBenchOrder(playerId) });
        } },
      { label: copy('alt'), note: mine.zone === 'alternate' ? current : '', disabled: mine.zone === 'alternate',
        run: () => { this._applyPlacement(playerId, { zone: 'alternate', positionId: null, benchOrder: null }); } },
      { label: copy('unassign'), note: !mine.zone ? current : '', disabled: !mine.zone,
        run: () => { this._applyPlacement(playerId, null); } },
    ];
    // Swap with the starter, from either side (mig 765): a sharer swaps
    // with the position's starter; a starter with each of its sharers.
    const swapRow = (subId, starterId, posId) => {
      const sub = this.roster.find(p => p.id === subId), st = this.roster.find(p => p.id === starterId);
      const pos = this.positionList.find(x => x.id === posId);
      const sh = this.shares.get(subId);
      const label = sub && st && sh ? copy('share_swap', { player: sub.name, other: st.name, position: pos?.name || '', nth: this._nth(sh.order) }) : '';
      return label ? { label, run: () => { this._swapPlayers(subId, starterId); } } : null;
    };
    const swaps = mine.share
      ? [this._holderOf(mine.share.pos) != null ? swapRow(playerId, this._holderOf(mine.share.pos), mine.share.pos) : null]
      : mine.zone === 'starter' && mine.positionId != null ? this._sharersOf(mine.positionId).map(id => swapRow(id, playerId, mine.positionId)) : [];
    // Sharing a position (mig 763): move up one, or stop sharing.
    if (mine.share) {
      const pos = this.positionList.find(x => x.id === mine.share.pos);
      if (mine.share.order > 2 && copy('share_up', { ...tk, nth: this._nth(mine.share.order - 1) }))
        rows.unshift({ label: copy('share_up', { ...tk, nth: this._nth(mine.share.order - 1) }), run: () => { this._shareUp(playerId); } });
      const un = this._swapCopy('unshare', { player: player.name, position: pos?.name || '' });
      if (un) rows.unshift({ label: un, run: () => { this.shares.delete(playerId); } });
    }
    rows.unshift(...swaps.filter(Boolean));
    // 📇 Contact him from here (owner 2026-11-13: "i see a starter or bench
    // guy with a certain P: and A: and then i can hit contact from there …
    // along with switch pos").  The note = his criteria row; short or only
    // projected → 🏃 Practice criteria preselected (mig 1342).
    const personId = this._personIdFor(playerId);
    const contactLabel = personId && window.ContactPopup ? copy('contact') : '';
    if (contactLabel) {
      const s = !this.everyonePlays && this.stats ? this.stats.get(Number(playerId)) : null;
      const st = s ? this._criteriaState(s) : null;
      const remind = st && (st.state === 'projected' || st.state === 'needs' || st.state === 'not_met');
      rows.unshift({
        label: contactLabel,
        note: st ? (this._eligCopy('row_' + st.state, st.tokens) || '') : '',
        run: () => { this._gcContactOpen(Number(personId), remind ? 'practice_criteria' : null); return false; },
      });
    }
    // ⋯ The one player sheet, as from any event (owner 11/19 "consistent
    // interface"), its 📇 Contact knowing this game.
    const sheetLabel = personId && window.PlayerSheet
      ? ((window.MessageCopy && MessageCopy.block('event_center', 'person_sheet')) || '⋯ Player sheet') : '';
    if (sheetLabel) rows.push({ label: sheetLabel, run: () => { this._openPersonSheet(Number(personId)); return false; } });
    // ✅ Attendance on top from game day (owner 11/18 "if we click a player
    // during start of practice or game it adds in attendance option").
    const top = this._attendanceTop(personId ? Number(personId) : 0);
    this._openSwapSheet({ title, sub: copy('sub'), gridLabel: copy('grid'), grid, rows,
                          topLabel: top.length ? this._attendanceTopLabel() : '', top });
    return true;
  }

  // An empty spot on the live card (owner 11/18 "if we can do the graphic as
  // most of the work of setting lineup and attendance then we do it"): who
  // plays #N?  Going · not placed first, then the bench, alternates, no
  // response.  A pick = _setPosition (the move sheet's grid does the same).
  _openFillSheet(positionId) {
    const pos = this.positionList.find(x => x.id === positionId);
    if (!pos) return false;
    const cp = (tier, tk, fb) => (window.MessageCopy && MessageCopy.block('event_center', tier, tk)) || fb;
    const out = this._rsvpOut || {};
    const placed = new Set(this.positions.keys());
    const groups = [
      [out.unplaced || [], cp('fill_unplaced', {}, 'Going · not placed')],
      [this.roster.filter(p => this.zones.get(p.id) === 'bench' && !placed.has(p.id)), cp('fill_bench', {}, 'Bench')],
      [this.roster.filter(p => this.zones.get(p.id) === 'alternate'), cp('fill_alt', {}, 'Alternate')],
      [out.noResponse || [], cp('fill_noresp', {}, 'No response')],
      [out.notChasing || [], cp('sec_not_chasing', {}, '👋 Not chasing')],   // mig 1520: still pickable
    ];
    const seen = new Set(), rows = [];
    for (const [list, note] of groups) for (const p of [...list].sort(this._byLastName)) {
      if (seen.has(p.id)) continue;
      seen.add(p.id);
      rows.push({ label: p.name, note, run: () => { this._setPosition(p.id, positionId); return false; } });
    }
    const title = cp('fill_title', { number: pos.sortOrder, position: pos.name }, `Who plays #${pos.sortOrder} · ${pos.name}?`);
    this._openSwapSheet({ title, sub: '', rows });
    return true;
  }

  // _openSwapSheet / _closeSwapSheet live on EventScreen (11/18: the
  // practice card's player sheet uses them too).

  _toast(msg) {
    // Cheap, no-dep toast. Clears itself after 2.5s.
    let t = this.find('#game-lineup-toast');
    if (!t) {
      t = document.createElement('div');
      t.id = 'game-lineup-toast';
      t.style.cssText = `
        position:fixed; bottom:24px; left:50%; transform:translateX(-50%);
        background:#0b3a2e; color:#a7f3d0; padding:10px 16px;
        border-radius:8px; font-weight:600; z-index:9999;
        box-shadow:0 4px 20px rgba(0,0,0,0.4);
        transition:opacity 0.25s;`;
      this.element.appendChild(t);
    }
    t.textContent = msg;
    t.style.opacity = '1';
    clearTimeout(this._toastT);
    this._toastT = setTimeout(() => { if (t) t.style.opacity = '0'; }, 2500);
  }

  // ── lineup drafts (mig 495) ──────────────────────────────────────────
  _copyLd(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('lineup_drafts', tier, tokens) : ''; }
  _snapshot() { return { zones: new Map(this.zones), positions: new Map(this.positions), benchOrder: new Map(this.benchOrder), shares: new Map(this.shares), splitSquad: !!this.splitSquad, formation: this.formation, matchupId: this.matchupId || null }; }
  _restore(snap) { this.zones = new Map(snap.zones); this.positions = new Map(snap.positions); this.benchOrder = new Map(snap.benchOrder); this.shares = new Map(snap.shares || []); this.splitSquad = !!snap.splitSquad; this.formation = snap.formation; this.matchupId = snap.matchupId || null; }
  _isDraftView() { return String(this.lineupView).startsWith('draft:'); }
  _viewPersonId() { return this._isDraftView() ? Number(this.lineupView.slice(6)) : null; }
  _draftFor(personId) { return (this.drafts || []).find(d => Number(d.authorPersonId) === Number(personId)) || null; }
  _mapsFromRows(rows) {
    const snap = { zones: new Map(), positions: new Map(), benchOrder: new Map(), shares: new Map(), formation: this._fieldSpec().defaultFormation };
    for (const row of rows || []) {
      if (row.zone) snap.zones.set(Number(row.playerId), row.zone);
      if (row.zone === 'starter' && row.positionId != null) snap.positions.set(Number(row.playerId), Number(row.positionId));
      if (row.zone === 'bench' && row.slotNumber != null) snap.benchOrder.set(Number(row.playerId), Number(row.slotNumber));
      if (row.zone === 'bench' && row.sharesPositionId != null && row.shareOrder != null) snap.shares.set(Number(row.playerId), { pos: Number(row.sharesPositionId), order: Number(row.shareOrder) });
    }
    return snap;
  }
  _rowsFromMaps() {
    const rows = [];
    for (const [playerId, zone] of this.zones.entries())
      rows.push({ playerId, zone, positionId: zone === 'starter' ? (this.positions.get(playerId) ?? null) : null, slotNumber: zone === 'bench' ? (this.benchOrder.get(playerId) ?? null) : null,
                  sharesPositionId: zone === 'bench' ? (this.shares.get(playerId)?.pos ?? null) : null, shareOrder: zone === 'bench' ? (this.shares.get(playerId)?.order ?? null) : null });
    return rows;
  }

  async _loadDrafts() {
    const matchId = this.matchId;
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      const res = await this.auth.fetch(`/api/lineup-drafts/${matchId}`);
      if (res.status === 403 || res.status === 401) { this.canDraft = false; this.drafts = []; return; }
      const body = await res.json().catch(() => ({}));
      if (!res.ok || !body.success) throw new Error(body.error || `HTTP ${res.status}`);
      if (this.matchId !== matchId) return;
      this.canDraft = true;
      this.viewerPersonId = body.viewerPersonId != null ? Number(body.viewerPersonId) : null;
      this.drafters = body.drafters || [];
      this.drafts = body.drafts || [];
      if (this.lineupView !== 'official') this._applyView(this.lineupView, { silent: true });
      this._render();
    } catch (err) { console.warn('[game-center] drafts unavailable:', err.message); }
  }

  // Switch what the editor shows: the official lineup, one person's draft
  // (editable only by its author), or the comparison.
  _applyView(view, { silent = false } = {}) {
    if (view === 'official' || view === 'compare') {
      if (this.official) this._restore(this.official);
      this.isCoach = view === 'official' ? this.realIsCoach : false;
    } else {
      const pid = Number(String(view).slice(6));
      const d = this._draftFor(pid);
      const snap = this._mapsFromRows(d ? d.rows : []);
      if (d && d.formationCode && this._fieldSpec().formations[d.formationCode]) snap.formation = d.formationCode;
      snap.matchupId = d ? d.matchupId : null;
      this._restore(snap);
      this.isCoach = pid === this.viewerPersonId;   // the author edits, everyone else reads
      if (this.isCoach) this.viewMode = 'coach';
    }
    this.lineupView = view;
    if (!silent) this._render();
  }

  // The chosen draft becomes the official lineup: load it into the editor
  // and save through the coach-gated official PUT.
  async _makeOfficial() {
    if (!this.realIsCoach || !this._isDraftView()) return;
    const d = this._draftFor(this._viewPersonId());
    if (!d) return;
    const snap = this._snapshot();
    this.lineupView = 'official';
    this._restore(snap);
    this.isCoach = this.realIsCoach;
    await this._saveLineup();
    this.flash = this._copyLd('made_official', { name: d.firstName || d.authorName }) || `${d.authorName}'s draft is now the official lineup.`;
    this._render();
  }

  _draftBarHtml() {
    if (!this.canDraft || this.everyonePlays) return '';   // nothing to draft when everyone plays
    const esc = (t) => this.escapeHtml(t);
    const pill = (key, label, extra = '') => `<button type="button" data-lineup-view="${esc(key)}" class="btn btn-sm ${this.lineupView === key ? 'btn-primary' : 'btn-secondary'}" style="font-size:0.78rem; padding:4px 10px; border-radius:999px;">${label}${extra}</button>`;
    // Official | My draft | one pill per draft someone else has started | Compare
    const pills = [pill('official', esc(this._copyLd('pill_official') || 'Official'))]
      .concat(this.viewerPersonId != null ? [pill(`draft:${this.viewerPersonId}`, `📝 ${esc(this._copyLd('pill_my_draft') || 'My draft')}`)] : [])
      .concat(this.drafters.filter(p => Number(p.personId) !== this.viewerPersonId && this._draftFor(p.personId))
        .map(p => pill(`draft:${p.personId}`, `📝 ${esc(p.firstName || p.name)}`)))
      .concat([pill('compare', `🔀 ${esc(this._copyLd('pill_compare') || 'Compare')}`)]);
    let hint = '';
    if (this.lineupView === 'official') hint = this._copyLd('official_hint');
    else if (this._isDraftView()) {
      const pid = this._viewPersonId(); const d = this._draftFor(pid); const who = this.drafters.find(p => Number(p.personId) === pid) || {};
      hint = pid === this.viewerPersonId ? this._copyLd('draft_hint')
           : d ? this._copyLd('draft_readonly', { name: who.firstName || who.name || '' })
               : this._copyLd('draft_empty', { name: who.firstName || who.name || '' });
      if (d && d.updatedAt) hint += ` <span style="opacity:0.6;">· ${esc(d.updatedAt)}</span>`;
    }
    const makeOfficial = this._isDraftView() && this.realIsCoach && this._draftFor(this._viewPersonId())
      ? `<button type="button" id="gl-make-official" class="btn btn-primary" style="font-size:0.78rem; padding:4px 10px;">${esc(this._copyLd('make_official') || '✅ Make this the official lineup')}</button>` : '';
    return `
      <div style="display:flex; gap:6px; flex-wrap:wrap; align-items:center; margin-bottom:6px;">${pills.join('')}</div>
      <div style="display:flex; justify-content:space-between; align-items:center; gap:8px; flex-wrap:wrap; font-size:0.78rem; opacity:0.85; margin-bottom:10px;"><span>${hint}</span>${makeOfficial}</div>`;
  }

  // Official next to every draft, one column each: S<pos> / B / A / –.
  _renderCompare() {
    const esc = (t) => this.escapeHtml(t);
    const versions = [{ key: 'official', label: this._copyLd('pill_official') || 'Official', snap: this.official || this._snapshot() }]
      .concat(this.drafters.filter(p => this._draftFor(p.personId)).map(p => { const d = this._draftFor(p.personId); return { key: `draft:${p.personId}`, label: Number(p.personId) === this.viewerPersonId ? (this._copyLd('pill_my_draft') || 'My draft') : (p.firstName || p.name), snap: this._mapsFromRows(d.rows), formation: d.formationCode }; }));
    versions[0].formation = versions[0].snap.formation;
    const byId = new Map(this.roster.map(p => [p.id, p]));
    const ids = new Set(); for (const v of versions) if (v.snap) for (const id of v.snap.zones.keys()) ids.add(id);
    const cell = (v, id) => { if (!v.snap) return ''; const z = v.snap.zones.get(id); if (!z) return '–'; if (z === 'starter') { const n = v.snap.positions.get(id); return `S${n != null ? n : ''}`; } return z === 'bench' ? 'B' : 'A'; };
    const rows = [...ids].map(id => { const cells = versions.map(v => cell(v, id)); const differs = new Set(cells.filter(c => c !== '')).size > 1; return { id, name: byId.get(id)?.name || `#${id}`, cells, differs }; })
      .sort((a, b) => (b.differs - a.differs) || a.name.localeCompare(b.name));
    const shown = this.compareOnlyDiff ? rows.filter(r => r.differs) : rows;
    const counts = (v) => { if (!v.snap) return '—'; let s = 0, b = 0, a = 0; for (const z of v.snap.zones.values()) { if (z === 'starter') s++; else if (z === 'bench') b++; else a++; } return `${s} / ${b} / ${a}`; };
    const th = 'padding:4px 8px; text-align:center; font-size:0.72rem; opacity:0.8; white-space:nowrap;';
    const td = 'padding:4px 8px; text-align:center; font-size:0.85rem; font-weight:700;';
    return `
      <div style="border:1px solid var(--border-color); border-radius:8px; padding:10px; background:var(--bg-secondary);">
        <div style="display:flex; justify-content:space-between; align-items:center; gap:8px; flex-wrap:wrap; margin-bottom:6px;">
          <span style="font-size:0.78rem; opacity:0.8;">${esc(this._copyLd('compare_note'))}</span>
          <label style="font-size:0.78rem; display:flex; gap:6px; align-items:center;"><input type="checkbox" id="gl-compare-diff" ${this.compareOnlyDiff ? 'checked' : ''}> ${esc(this._copyLd('compare_only_diff') || 'Differences only')}</label>
        </div>
        <div style="overflow-x:auto;"><table style="border-collapse:collapse; min-width:100%;">
          <thead>
            <tr><th style="${th} text-align:left;"></th>${versions.map(v => `<th style="${th}">${esc(v.label)}${v.snap ? '' : '<br><span style="opacity:0.5;">no draft</span>'}</th>`).join('')}</tr>
            <tr><th style="${th} text-align:left; font-weight:400;">formation</th>${versions.map(v => `<th style="${th} font-weight:400;">${esc(v.formation || '')}</th>`).join('')}</tr>
            <tr><th style="${th} text-align:left; font-weight:400;">S / B / A</th>${versions.map(v => `<th style="${th} font-weight:400;">${counts(v)}</th>`).join('')}</tr>
          </thead>
          <tbody>
            ${shown.map(r => `<tr style="${r.differs ? 'background:rgba(245,158,11,0.12);' : ''} border-top:1px solid var(--border-color);">
              <td style="padding:4px 8px; font-size:0.85rem; white-space:nowrap;">${esc(r.name)}</td>
              ${r.cells.map(c => `<td style="${td} ${c === '–' ? 'opacity:0.35;' : c.startsWith('S') ? 'color:#86efac;' : c === 'B' ? 'color:#fbbf24;' : ''}">${esc(c)}</td>`).join('')}
            </tr>`).join('')}
            ${shown.length ? '' : `<tr><td colspan="${versions.length + 1}" style="padding:10px; opacity:0.7; font-size:0.85rem;">${esc(this._copyLd('compare_same') || 'Every version agrees.')}</td></tr>`}
          </tbody>
        </table></div>
      </div>`;
  }

  _scheduleSave() {
    this._normShares();
    if (this._saveTimer) clearTimeout(this._saveTimer);
    this._saveTimer = setTimeout(() => {
      this._saveTimer = null;
      this._saveLineup();
    }, 600);
  }

  // formations.id for the shape on screen (0 = unknown, leaves the saved one).
  _formationId() {
    const row = (this.formations || []).find(f => f.code === this.formation);
    return row ? Number(row.id) : 0;
  }

  async _saveLineup() {
    const starters = [];
    const bench = [];
    const alternates = [];
    for (const [playerId, zone] of this.zones.entries()) {
      if (zone === 'starter') {
        const positionId = this.positions.get(playerId) ?? null;
        // slotNumber mirrors positionId 1:1 for the 1-11 picker (see
        // positionPills) — both land in match_lineups so lineups built
        // before this feature (positionId always null) still sort sanely.
        starters.push({ playerId, ...(positionId != null ? { positionId, slotNumber: positionId } : {}) });
      }
      else if (zone === 'bench') {
        const order = this.benchOrder.get(playerId) ?? null;
        const share = this.shares.get(playerId);
        bench.push({ playerId, ...(order != null ? { slotNumber: order } : {}), ...(share ? { sharesPositionId: share.pos, shareOrder: share.order } : {}) });
      }
      else if (zone === 'alternate') alternates.push({ playerId });
    }
    const payload = { starters, bench, alternates, formationId: this._formationId(), matchupId: this.matchupId || null, rosterSize: 0 };
    if (!this._isDraftView()) payload.splitSquad = !!this.splitSquad;   // mig 763
    // A bench extended this game (mig 760) rides the official save.
    if (this._pendingSquadSize && !this._isDraftView()) payload.squadSize = this._pendingSquadSize;
    this._savingLineup = true;   // the live poll stands down while a PUT is in flight
    const officialSave = !this._isDraftView();
    if (officialSave) { this._dbState = 'saving'; this._paintDbStrip(); }
    try {
      if (this._isDraftView()) {
        // My draft (mig 495) — the same shape, my own row.
        if (this._viewPersonId() !== this.viewerPersonId) return;
        const res = await this.auth.fetch(`/api/lineup-drafts/${this.matchId}/mine`, { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
        const data = await res.json();
        if (!data.success) throw new Error(data.message || 'Save failed');
        const me = this.drafters.find(p => Number(p.personId) === this.viewerPersonId) || {};
        const d = this._draftFor(this.viewerPersonId);
        const rows = this._rowsFromMaps();
        if (d) { d.rows = rows; d.formationCode = this.formation; d.matchupId = this.matchupId || null; }
        else this.drafts.push({ id: data.draftId, authorPersonId: this.viewerPersonId, authorName: me.name || '', firstName: me.firstName || '', mine: true, formationCode: this.formation, matchupId: this.matchupId || null, updatedAt: '', rows });
        return;
      }
      const res = await this.auth.fetch(`/api/eligibility/lineup/${this.matchId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const data = await res.json();
      if (!data.success) throw new Error(data.message || 'Save failed');
      this.official = this._snapshot();
      if (payload.squadSize && payload.squadSize === this._pendingSquadSize) this._pendingSquadSize = 0;
      // DB confirmed the save: its stamp becomes the "last change".
      if (data.data && data.data.savedAt) this.lineupChangedAt = data.data.savedAt;
      this._dbSyncAt = new Date();
      this._dbState = 'ok';
      this._paintDbStrip();
    } catch (err) {
      console.error('[game-lineup] save failed:', err);
      // LOUD failure (10/21: silent 500s let the board lie for a day) —
      // red strip with the server's reason; the board still shows the
      // DB's last saved lineup stamp.
      if (officialSave) {
        this._dbState = 'savefail';
        this._dbFailMsg = err.message || '';
        this._paintDbStrip();
      }
    } finally {
      this._savingLineup = false;
    }
  }
}

Mixin.into(GameCenterScreen, GameCenterLineupEdit);
