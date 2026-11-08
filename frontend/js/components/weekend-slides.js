// WeekendSlides — one Instagram carousel with a slide per game (mig 1179).
// Owner 2026-11-07: "can we do the posts as a slide show for game
// announcements … a button somewhere appropriate to post a slide show of all
// games that weekend … then also one for lineup? even though kids dont' have
// one and women don't we can include them again as the game announcement".
//
// Two buttons on #game-center (staff who may post): 🎞 Game Announcements and
// 🎞 Lineups.  Each opens a panel listing the week's games, the Fri–Sun ones
// ticked; every ticked game is drawn with SocialPostCard.buildCardHtml — the
// same drawing as that game's own post — captured, given one still frame of
// the lighthouse beam, padded to Instagram's 4:5 (1080×1350, so the carousel
// never crops a slide), and posted as ONE carousel by SocialController
// (/api/social/carousels…).  A Lineups slide whose game has no lineup (no
// starters set, or a kids' everyone-plays game) is that game's announcement.
//
// The lineup state comes from a GameCenterScreen instance that is never
// mounted: its own _buildRosterData turns the official lineup into the
// pitch, so a slide can't drift from the game's own Starters & Bench card.
//
// Wording: message_templates kind weekend_slides (MessageCopy).
class WeekendSlides {
  static get TYPES() { return ['game_day', 'starters_bench']; }
  static get MAX_SLIDES() { return 10; }
  static get OUT_W() { return 1080; }
  static get OUT_H() { return 1350; }

  // opts: { navigation, games: () => [feed events], escapeHtml }
  constructor(auth, opts) {
    this.auth = auth;
    this.opts = opts;
    this.el = null;
    this.open = null;          // 'game_day' | 'starters_bench' | null
    this.weekOffset = 0;       // 0 = this week, 1 = next
    this.ticked = new Map();   // `${type}:${week}` → Set(match_id)
    this.slides = new Map();   // `${type}:${matchId}` → { dataUrl, slideType } | { error }
    this.carousels = new Map();// `${type}:${week}` → GET row
    this.captions = new Map(); // `${type}:${week}` → caption the coach typed
    this.busy = '';            // progress line while posting
    this.note = '';            // result line
    this._drawSeq = 0;
    this._positions = null;
    this._details = new Map(); // matchId → /api/matches/:id data
    // 🤝 Collaborators, ticked by default (mig 1183).
    this.collab = window.CollaboratorPicks ? new CollaboratorPicks(auth, () => this._paintKeepingCaption()) : null;
  }

  esc(t) { return this.opts.escapeHtml ? this.opts.escapeHtml(t) : String(t ?? ''); }
  copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('weekend_slides', tier, tokens) : ''; }

  mount(el) {
    if (this.el === el) { this._paintKeepingCaption(); return; }
    this.el = el;
    el.addEventListener('click', (e) => this._onClick(e));
    el.addEventListener('change', (e) => this._onChange(e));
    el.addEventListener('input', (e) => {
      if (e.target.matches('[data-ws-caption]')) this.captions.set(this._key(), e.target.value);
    });
    this.paint();
  }

  // ── the week ─────────────────────────────────────────────────────────
  _monday(offset = this.weekOffset) {
    const d = new Date(); d.setHours(0, 0, 0, 0);
    d.setDate(d.getDate() - ((d.getDay() + 6) % 7) + 7 * offset);
    return d;
  }
  _iso(d) { return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`; }
  _week() { return this._iso(this._monday()); }
  _key(type = this.open) { return `${type}:${this._week()}`; }

  _weekGames() {
    const from = this._monday(), to = this._monday(this.weekOffset + 1);
    return (this.opts.games() || []).filter(ev => {
      const t = new Date(ev.starts_at);
      return !isNaN(t) && t >= from && t < to;
    });
  }

  // Ticked by default: linked games Fri–Sun not yet over.
  _tickedSet() {
    const key = this._key();
    if (!this.ticked.has(key)) {
      const now = Date.now();
      this.ticked.set(key, new Set(this._weekGames().filter(ev => {
        const t = new Date(ev.starts_at);
        return ev.match_id != null && [5, 6, 0].includes(t.getDay()) && t.getTime() + 3 * 3600 * 1000 > now;
      }).map(ev => ev.match_id).slice(0, WeekendSlides.MAX_SLIDES)));
    }
    return this.ticked.get(key);
  }

  _chosen() {
    const set = this._tickedSet();
    return this._weekGames().filter(ev => ev.match_id != null && set.has(ev.match_id));
  }

  // ── paint ────────────────────────────────────────────────────────────
  paint() {
    if (!this.el) return;
    const btn = (type) => {
      const label = this.copy('button_' + type);
      if (!label) return '';
      const on = this.open === type;
      return `<button type="button" class="btn ${on ? 'btn-primary' : 'btn-secondary'}" data-ws-open="${type}"
                      style="flex:1 1 220px; font-weight:700; padding:8px 10px; font-size:0.85rem;">${this.esc(label)}</button>`;
    };
    const buttons = WeekendSlides.TYPES.map(btn).join('');
    if (!buttons) { this.el.innerHTML = ''; return; }
    this.el.innerHTML = `
      <div style="max-width:640px; margin:0 auto 10px;">
        <div style="display:flex; flex-wrap:wrap; gap:6px;">${buttons}</div>
        ${this.open ? this._panelHtml() : ''}
      </div>`;
    this._startThumbs();
  }

  // The beam sweeps on the thumbnails too (mig 1182) — what the post shows.
  _startThumbs() {
    for (const stop of (this._thumbStops || [])) stop();
    this._thumbStops = [];
    if (!this.el || !window.LighthouseBeam) return;
    if (!this._beamStart) this._beamStart = performance.now();
    for (const cvs of this.el.querySelectorAll('[data-ws-thumb]')) {
      const s = this.slides.get(cvs.getAttribute('data-ws-thumb'));
      if (!s || !s.shot) continue;
      this._thumbStops.push(this._animate(cvs, s, this._beamStart).stop);
    }
  }

  _animate(cvs, s, startTime) {
    return window.LighthouseBeam.animate(cvs, {
      startTime,
      rotPeriodSec: window.LighthouseBeam.BEAM_ROTATION_SECONDS,
      ...(s.beam || {}),
      onFrame: (ctx, w, h) => ctx.drawImage(s.shot, 0, 0, w, h),
    });
  }

  _panelHtml() {
    const type = this.open;
    const games = this._weekGames();
    const set = this._tickedSet();
    const chosen = this._chosen();
    const car = this.carousels.get(this._key());
    const posted = car && (car.status === 'posted' || car.status === 'publishing');
    const fmtWeek = (off) => {
      const d = this._monday(off);
      return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    };
    const weekPill = (off) => `<button type="button" data-ws-week="${off}" class="btn ${this.weekOffset === off ? 'btn-primary' : 'btn-secondary'}"
        style="padding:3px 10px; font-size:0.75rem;">Week of ${this.esc(fmtWeek(off))}</button>`;

    const rows = games.length ? games.map(ev => {
      const linked = ev.match_id != null;
      const on = linked && set.has(ev.match_id);
      return `<label style="display:flex; gap:8px; align-items:flex-start; padding:6px 4px; border-bottom:1px solid var(--border-color); ${linked ? '' : 'opacity:0.5;'}">
        <input type="checkbox" data-ws-tick="${linked ? ev.match_id : ''}" ${on ? 'checked' : ''} ${linked && !posted ? '' : 'disabled'} style="margin-top:3px;">
        <span style="display:flex; flex-direction:column; gap:1px;">
          <span style="font-weight:700; font-size:0.85rem;">${this.esc(this._gameLabel(ev))}</span>
          <span style="font-size:0.74rem; opacity:0.8;">${this.esc(this._when(ev))}</span>
        </span>
      </label>`;
    }).join('') : `<div style="padding:8px 4px; opacity:0.8;">${this.esc(this.copy('none'))}</div>`;

    const thumbs = chosen.map(ev => {
      const s = this.slides.get(`${type}:${ev.match_id}`);
      const chip = s && s.slideType && s.slideType !== type ? this.copy('fallback_chip') : '';
      const body = !s ? `<div style="aspect-ratio:4/5; display:flex; align-items:center; justify-content:center; font-size:0.7rem; opacity:0.7;"><div class="spinner"></div></div>`
        : s.error ? `<div style="aspect-ratio:4/5; display:flex; align-items:center; justify-content:center; padding:6px; font-size:0.68rem; color:#f87171;">${this.esc(s.error)}</div>`
        : s.shot ? `<div style="aspect-ratio:4/5; background:#${s.pad};"><canvas data-ws-thumb="${type}:${ev.match_id}" width="${s.shot.width}" height="${s.shot.height}" style="display:block; width:100%; height:100%; object-fit:contain;"></canvas></div>`
        : `<img src="${s.dataUrl}" alt="" style="display:block; width:100%; aspect-ratio:4/5;">`;
      return `<div style="flex:0 0 132px; border:1px solid var(--border-color); border-radius:6px; overflow:hidden; background:#0b1220;">
        ${body}
        <div style="padding:3px 5px; font-size:0.64rem; line-height:1.25;">${this.esc(this._gameLabel(ev))}${chip ? `<br><span style="color:#fbbf24;">${this.esc(chip)}</span>` : ''}</div>
      </div>`;
    }).join('');

    const extra = chosen.length - WeekendSlides.MAX_SLIDES;
    const caption = this.captions.has(this._key()) ? this.captions.get(this._key())
      : (car && car.caption && posted ? car.caption : this._caption(chosen));
    const ready = chosen.length && extra <= 0 && chosen.every(ev => { const s = this.slides.get(`${type}:${ev.match_id}`); return s && s.dataUrl; });
    const reopen = window.MessageCopy ? MessageCopy.block('social_post', 'reopen_button') : '';

    return `
      <div style="margin-top:8px; padding:10px; border:1px solid var(--border-color); border-radius:8px; background:var(--bg-secondary, rgba(255,255,255,0.03));">
        <div style="display:flex; gap:6px; flex-wrap:wrap; margin-bottom:6px;">${weekPill(0)}${weekPill(1)}</div>
        <div style="font-size:0.75rem; opacity:0.85; margin-bottom:6px;">${this.esc(this.copy('hint'))}${type === 'starters_bench' && this.copy('hint_starters_bench') ? ' ' + this.esc(this.copy('hint_starters_bench')) : ''}</div>
        <div>${rows}</div>
        ${chosen.length ? `<div style="display:flex; gap:8px; overflow-x:auto; padding:10px 0 6px;">${thumbs}</div>` : ''}
        ${extra > 0 ? `<div style="color:#fbbf24; font-size:0.78rem; margin:4px 0;">${this.esc(this.copy('too_many', { extra, plural: extra === 1 ? '' : 's' }))}</div>` : ''}
        ${chosen.length ? `
          <label style="display:block; font-size:0.72rem; font-weight:700; margin:6px 0 2px;">${this.esc(this.copy('caption_label'))}</label>
          <textarea data-ws-caption rows="8" ${posted ? 'readonly' : ''} style="width:100%; box-sizing:border-box; font-size:0.8rem; padding:6px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary, #0f172a); color:inherit;">${this.esc(caption)}</textarea>` : ''}
        ${posted ? `
          <div style="margin-top:8px; font-weight:700; color:#4ade80;">${this.esc(this.copy('posted', { when: car.posted_at ? new Date(car.posted_at).toLocaleString('en-US', { weekday: 'short', month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' }) : '' }))}</div>
          ${car.status === 'posted' && reopen ? `<button type="button" data-ws-reopen="${car.id}" class="btn btn-secondary" style="margin-top:6px; font-size:0.75rem;">${this.esc(reopen)}</button>` : ''}`
        : chosen.length ? `
          ${this.collab ? this.collab.html((t) => this.esc(t), { disabled: !!this.busy }) : ''}
          <button type="button" data-ws-post class="btn btn-primary" ${ready && !this.busy ? '' : 'disabled'} style="width:100%; margin-top:8px; font-weight:700; padding:10px;">
            ${this.esc(this.busy || this.copy('post_button', { count: Math.min(chosen.length, WeekendSlides.MAX_SLIDES) }))}</button>` : ''}
        ${car && car.status === 'error' && car.error_message && !this.note ? `<div style="margin-top:6px; font-size:0.78rem; color:#f87171;">${this.esc(this.copy('failed', { reason: car.error_message }))}</div>` : ''}
        ${this.note ? `<div style="margin-top:6px; font-size:0.8rem;">${this.esc(this.note)}</div>` : ''}
      </div>`;
  }

  _gameLabel(ev) {
    const teams = (Array.isArray(ev.teams) ? ev.teams : []).map(t => t.name).filter(Boolean).join(' + ');
    const vs = ev.opponent ? `${ev.is_home === false ? '@' : 'vs'} ${ev.opponent}` : '';
    return [teams, vs].filter(Boolean).join(' ') || 'Game';
  }
  _when(ev) {
    const d = new Date(ev.starts_at);
    if (isNaN(d)) return '';
    return `${d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' })} · ${d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })}`;
  }

  _caption(chosen) {
    const type = this.open;
    const lines = chosen.slice(0, WeekendSlides.MAX_SLIDES).map(ev => {
      const d = new Date(ev.starts_at);
      const det = this._details.get(ev.match_id);
      const venue = (det && SocialPostCard.prototype.buildVenueString.call(SocialPostCard.prototype, det)) || ev.location || '';
      return this.copy('caption_line', {
        game: this._gameLabel(ev),
        day: isNaN(d) ? '' : d.toLocaleDateString('en-US', { weekday: 'long', month: 'short', day: 'numeric' }),
        time: isNaN(d) ? '' : d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' }),
        venue,
      }).replace(/\n📍 $/, '');
    });
    // A Mon–Thu game in it → "this week" (mig 1180), else the weekend head.
    const weekday = chosen.some(ev => { const d = new Date(ev.starts_at).getDay(); return d >= 1 && d <= 4; });
    // "9 GAMES THIS WEEK" (mig 1181): {count} = slides in the post.
    const n = Math.min(chosen.length, WeekendSlides.MAX_SLIDES);
    const tokens = { count: n, s: n === 1 ? '' : 'S' };
    const head = (weekday && this.copy('caption_week_head_' + type, tokens)) || this.copy('caption_head_' + type, tokens);
    return [head, ...lines, this.copy('caption_tail')].filter(Boolean).join('\n\n');
  }

  // ── events ───────────────────────────────────────────────────────────
  _onClick(e) {
    const openBtn = e.target.closest('[data-ws-open]');
    if (openBtn) {
      const type = openBtn.getAttribute('data-ws-open');
      this.open = this.open === type ? null : type;
      this.note = '';
      this.paint();
      if (this.open) this._refresh();
      return;
    }
    const week = e.target.closest('[data-ws-week]');
    if (week) {
      this.weekOffset = Number(week.getAttribute('data-ws-week')) || 0;
      this.note = '';
      this.paint();
      this._refresh();
      return;
    }
    if (e.target.closest('[data-ws-post]')) { this._post(); return; }
    const reopen = e.target.closest('[data-ws-reopen]');
    if (reopen) this._reopen(reopen);
  }

  _onChange(e) {
    if (this.collab && this.collab.handle(e)) return;
    const tick = e.target.closest('[data-ws-tick]');
    if (!tick || !tick.getAttribute('data-ws-tick')) return;
    const id = Number(tick.getAttribute('data-ws-tick'));
    const set = this._tickedSet();
    if (tick.checked) set.add(id); else set.delete(id);
    this.captions.delete(this._key());   // the caption follows the games until typed over again
    this.paint();
    this._drawAll();
  }

  async _refresh() {
    await Promise.all([this._loadCarousels(), window.MessageCopy ? MessageCopy.load(this.auth).catch(() => {}) : null]);
    this.paint();
    this._drawAll();
  }

  async _loadCarousels() {
    const week = this._week();
    try {
      const res = await this.auth.fetch(`/api/social/carousels?week_start=${week}`);
      const body = await res.json();
      for (const type of WeekendSlides.TYPES) this.carousels.delete(`${type}:${week}`);
      for (const c of (body && body.success && body.data) || []) this.carousels.set(`${c.post_type}:${week}`, c);
    } catch (err) {
      console.warn('[weekend-slides] carousels load failed:', err);
    }
  }

  // ── drawing ──────────────────────────────────────────────────────────
  async _drawAll() {
    const type = this.open;
    if (!type) return;
    const seq = ++this._drawSeq;
    for (const ev of this._chosen().slice(0, WeekendSlides.MAX_SLIDES)) {
      const key = `${type}:${ev.match_id}`;
      if (this.slides.has(key) && !this.slides.get(key).error) continue;
      try {
        this.slides.set(key, await this._drawSlide(type, ev));
      } catch (err) {
        console.warn('[weekend-slides] slide failed:', ev.match_id, err);
        this.slides.set(key, { error: (err && err.message) || 'Could not draw' });
      }
      if (seq !== this._drawSeq || type !== this.open) return;
      this.captions.has(this._key()) ? this._paintKeepingCaption() : this.paint();
    }
  }

  // Repaint without losing the caption the coach is typing.
  _paintKeepingCaption() {
    const ta = this.el && this.el.querySelector('[data-ws-caption]');
    const focus = ta && document.activeElement === ta ? [ta.selectionStart, ta.selectionEnd] : null;
    this.paint();
    if (focus) {
      const again = this.el.querySelector('[data-ws-caption]');
      if (again) { again.focus(); again.setSelectionRange(focus[0], focus[1]); }
    }
  }

  async _matchDetails(matchId) {
    if (this._details.has(matchId)) return this._details.get(matchId);
    const res = await this.auth.fetch(`/api/matches/${matchId}`);
    const body = await res.json().catch(() => null);
    if (!res.ok || !body || !body.success) throw new Error('Could not load the game');
    this._details.set(matchId, body.data);
    return body.data;
  }

  async _drawSlide(type, ev) {
    const details = await this._matchDetails(ev.match_id);
    const card = new SocialPostCard(this.auth);
    card.matchId = ev.match_id;
    card.matchContext = details;
    card.postTypeName = 'game_day';
    let slideType = 'game_day';
    if (type === 'starters_bench') {
      const lineup = await this._lineupRosterData(ev, details);
      if (lineup) {
        card.teamId = lineup.teamId;
        card.postTypeName = 'starters_bench';
        card.rosterData = lineup.rosterData;
        slideType = 'starters_bench';
      }
    }
    return { ...(await this._capture(card)), slideType };
  }

  // The official lineup as the Starters & Bench card draws it, or null when
  // the game has none to draw (no starters, or everyone plays).
  async _lineupRosterData(ev, details) {
    if (typeof GameCenterScreen === 'undefined') return null;
    if (!this._positions) {
      const res = await this.auth.fetch('/api/eligibility/positions');
      const body = await res.json().catch(() => null);
      this._positions = (body && body.success && Array.isArray(body.data)) ? body.data : [];
    }
    const res = await this.auth.fetch(`/api/eligibility/lineup/${ev.match_id}`);
    const body = await res.json().catch(() => null);
    const d = body && body.success ? body.data : null;
    if (!d || d.everyonePlays === true) return null;
    const starters = (d.lineup || []).filter(r => r.zone === 'starter');
    if (!starters.length) return null;

    const gc = new GameCenterScreen(this.opts.navigation, this.auth);
    gc.matchId = ev.match_id;
    gc.ev = ev;
    gc.matchDetails = details;   // _fhEventId → the invites read
    gc.teamId = d.teamId || null;
    gc.positionList = this._positions;
    gc.fieldSize = FIELD_SIZES[d.fieldSize] ? Number(d.fieldSize) : DEFAULT_FIELD_SIZE;
    gc.everyonePlays = false;
    const saved = d.formationCode;
    gc.formation = saved && gc._fieldSpec().formations[saved] ? saved : gc._fieldSpec().defaultFormation;
    gc.splitSquad = !!d.splitSquad;
    gc.zones = new Map(); gc.positions = new Map(); gc.benchOrder = new Map(); gc.shares = new Map();
    for (const row of (d.lineup || [])) {
      const pid = Number(row.playerId);
      if (row.zone && row.zone !== 'not_selected') gc.zones.set(pid, row.zone);
      if (row.zone === 'starter' && row.positionId != null) gc.positions.set(pid, Number(row.positionId));
      if (row.zone === 'bench' && row.slotNumber != null) gc.benchOrder.set(pid, Number(row.slotNumber));
      if (row.zone === 'bench' && row.sharesPositionId != null && row.shareOrder != null)
        gc.shares.set(pid, { pos: Number(row.sharesPositionId), order: Number(row.shareOrder) });
    }

    // Names: every roster team on the game, then the call-ups (invites).
    const teamIds = Array.isArray(d.rosterTeamIds) && d.rosterTeamIds.length ? d.rosterTeamIds : (gc.teamId ? [gc.teamId] : []);
    const rosters = await Promise.all(teamIds.map(id =>
      this.auth.fetch(`/api/teams/${id}/roster`).then(r => r.json()).catch(() => null)));
    const byId = new Map();
    rosters.forEach((r, i) => {
      for (const p of (Array.isArray(r?.data) ? r.data : [])) {
        if (p.roleType !== 'PLAYER' || byId.has(Number(p.id))) continue;
        byId.set(Number(p.id), { id: Number(p.id), name: p.name || '', lastName: p.lastName || '', teamId: teamIds[i], jerseyNumber: p.jerseyNumber || null });
      }
    });
    gc.roster = [...byId.values()];
    gc.players = [];
    if (gc._fhEventId()) {
      await gc._loadInvites();
      gc._foldInCallups();
    }

    const pick = (zone) => gc.roster.filter(p => gc.zones.get(p.id) === zone);
    const byZone = { starter: pick('starter'), bench: pick('bench'), alternate: pick('alternate') };
    byZone.bench.sort((a, b) => (gc.benchOrder.get(a.id) ?? Infinity) - (gc.benchOrder.get(b.id) ?? Infinity));
    return { teamId: gc.teamId, rosterData: gc._buildRosterData(byZone) };
  }

  // The card as Instagram gets it: html2canvas at 2×, one still frame of
  // the beam on top (the single posts carry it animated), then letterboxed
  // into 1080×1350 with the card's own edge colour.
  async _capture(card) {
    if (typeof html2canvas === 'undefined') throw new Error('Image library not loaded');
    const { html, width, height } = await card.buildCardHtml({});
    const wrapper = document.createElement('div');
    wrapper.style.cssText = 'position:fixed;left:-9999px;top:0;z-index:-1;pointer-events:none;';
    wrapper.innerHTML = html;
    document.body.appendChild(wrapper);
    let shot;
    try {
      card.hardenGradientsForCapture(wrapper.firstElementChild);
      shot = await Promise.race([
        html2canvas(wrapper.firstElementChild, { backgroundColor: null, scale: 2, useCORS: true }),
        new Promise((_, reject) => setTimeout(() => reject(new Error('Drawing timed out')), 15000)),
      ]);
    } finally {
      document.body.removeChild(wrapper);
    }

    const w = (width || 540) * 2, h = (height || 540) * 2;
    const withBeam = document.createElement('canvas');
    withBeam.width = w; withBeam.height = h;
    await this._beamFrame(withBeam, shot, card);

    const out = document.createElement('canvas');
    out.width = WeekendSlides.OUT_W; out.height = WeekendSlides.OUT_H;
    const ctx = out.getContext('2d');
    const px = shot.getContext('2d').getImageData(2, 2, 1, 1).data;
    const pad = [px[0], px[1], px[2]].map(v => v.toString(16).padStart(2, '0')).join('');
    ctx.fillStyle = `#${pad}`;
    ctx.fillRect(0, 0, out.width, out.height);
    const s = Math.min(out.width / w, out.height / h);
    const dw = Math.round(w * s), dh = Math.round(h * s);
    ctx.drawImage(withBeam, Math.round((out.width - dw) / 2), Math.round((out.height - dh) / 2), dw, dh);
    // shot + beam options: the beam clip is recorded from these at post
    // time (_record); pad is the edge colour the server letterboxes it in.
    const beam = card.beamOptions ? card.beamOptions(w, h) : {};
    return { dataUrl: out.toDataURL('image/jpeg', 0.92), shot, beam, pad };
  }

  async _beamFrame(canvas, shot, card) {
    const plain = () => canvas.getContext('2d').drawImage(shot, 0, 0, canvas.width, canvas.height);
    if (!window.LighthouseBeam) { plain(); return; }
    let drawn = false;
    const anim = window.LighthouseBeam.animate(canvas, {
      // A fixed angle, the beam sweeping up and across the card.
      startTime: performance.now() - window.LighthouseBeam.BEAM_ROTATION_SECONDS * 1000 * 0.62,
      rotPeriodSec: window.LighthouseBeam.BEAM_ROTATION_SECONDS,
      ...(card.beamOptions ? card.beamOptions(canvas.width, canvas.height) : {}),
      onFrame: (ctx, cw, ch) => { ctx.drawImage(shot, 0, 0, cw, ch); drawn = true; },
    });
    // One frame, then stop.  A hidden tab never runs rAF: the card goes
    // without its beam rather than hanging.
    await new Promise(resolve => {
      const t0 = Date.now();
      const tick = () => {
        if (drawn) return requestAnimationFrame(resolve);
        if (Date.now() - t0 > 1500) return resolve();
        setTimeout(tick, 30);
      };
      tick();
    });
    anim.stop();
    if (!drawn) plain();
  }

  // ── recording ────────────────────────────────────────────────────────
  // Every slide's beam, one full sweep (BEAM_ROTATION_SECONDS, so Instagram's
  // loop is seamless), recorded side by side off-screen.  null for a slide
  // the browser can't record.
  async _recordAll(slideList) {
    if (!window.LighthouseBeam || typeof MediaRecorder === 'undefined') return slideList.map(() => null);
    const host = document.createElement('div');
    host.style.cssText = 'position:fixed;left:-99999px;top:0;pointer-events:none;';
    document.body.appendChild(host);
    const start = performance.now();
    const secs = window.LighthouseBeam.BEAM_ROTATION_SECONDS;
    const mime = MediaRecorder.isTypeSupported('video/webm;codecs=vp9') ? 'video/webm;codecs=vp9' : 'video/webm';
    try {
      return await Promise.all(slideList.map(s => new Promise(resolve => {
        try {
          const cvs = document.createElement('canvas');
          cvs.width = s.shot.width; cvs.height = s.shot.height;
          host.appendChild(cvs);
          const anim = this._animate(cvs, s, start);
          const rec = new MediaRecorder(cvs.captureStream(24), { mimeType: mime, videoBitsPerSecond: 1200000 });
          const chunks = [];
          rec.ondataavailable = (e) => { if (e.data.size) chunks.push(e.data); };
          rec.onstop = () => { anim.stop(); resolve(chunks.length ? new Blob(chunks, { type: 'video/webm' }) : null); };
          rec.onerror = () => { anim.stop(); resolve(null); };
          rec.start();
          setTimeout(() => rec.state !== 'inactive' && rec.stop(), secs * 1000);
        } catch (err) {
          console.warn('[weekend-slides] recording failed:', err);
          resolve(null);
        }
      })));
    } finally {
      host.remove();
    }
  }

  // ── posting ──────────────────────────────────────────────────────────
  async _post() {
    const type = this.open;
    const week = this._week();
    const chosen = this._chosen().slice(0, WeekendSlides.MAX_SLIDES);
    const slides = chosen.map(ev => ({ ev, s: this.slides.get(`${type}:${ev.match_id}`) }));
    if (!slides.length || slides.some(x => !x.s || !x.s.dataUrl)) return;
    if (!confirm(this.copy('confirm', { count: slides.length }))) return;
    const ta = this.el.querySelector('[data-ws-caption]');
    const caption = ta ? ta.value.trim() : this._caption(chosen);
    const step = (text) => { this.busy = text; this.note = ''; this._paintKeepingCaption(); };
    try {
      step(this.copy('uploading', { n: 0, count: slides.length }));
      const saveRes = await this.auth.fetch('/api/social/carousels', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ post_type: type, week_start: week, caption,
          slides: slides.map(x => ({ match_id: Number(x.ev.match_id), slide_type: x.s.slideType })) }),
      });
      const saved = await saveRes.json().catch(() => null);
      if (!saveRes.ok || !saved || !saved.success) throw new Error((saved && saved.message) || `HTTP ${saveRes.status}`);
      const id = saved.data.id;
      // One full beam sweep per slide, all recorded at once (mig 1182).
      step(this.copy('building', { count: slides.length }));
      const clips = await this._recordAll(slides.map(x => x.s));
      const send = async (pos, body, type, query = '') => {
        const up = await this.auth.fetch(`/api/social/carousels/${id}/slides/${pos}${query}`, {
          method: 'POST', headers: { 'Content-Type': type }, body,
        });
        const upBody = await up.json().catch(() => null);
        if (!up.ok || !upBody || !upBody.success) throw new Error((upBody && upBody.message) || `HTTP ${up.status}`);
      };
      for (let i = 0; i < slides.length; i++) {
        step(this.copy('uploading', { n: i + 1, count: slides.length }));
        await send(i + 1, await (await fetch(slides[i].s.dataUrl)).blob(), 'image/jpeg');
        // A clip that fails to record or convert leaves the still — the
        // slide still posts, just without the moving beam.
        if (clips[i]) await send(i + 1, clips[i], 'video/webm', `?pad=${slides[i].s.pad}`)
          .catch(err => console.warn('[weekend-slides] clip upload failed, slide', i + 1, err));
      }
      step(this.copy('publishing'));
      const pub = await this.auth.fetch(`/api/social/carousels/${id}/publish`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(this.collab ? this.collab.body() : {}),
      });
      const pubBody = await pub.json().catch(() => null);
      if (!pub.ok || !pubBody || !pubBody.success) throw new Error((pubBody && pubBody.message) || `HTTP ${pub.status}`);
      this.captions.delete(this._key());
      this.note = this.copy('done');
    } catch (err) {
      this.note = this.copy('failed', { reason: err.message || String(err) });
    } finally {
      this.busy = '';
      await this._loadCarousels();
      this.paint();
    }
  }

  async _reopen(btn) {
    if (btn.dataset.armed !== '1') {
      btn.dataset.armed = '1';
      const confirmText = window.MessageCopy ? MessageCopy.block('social_post', 'reopen_confirm') : '';
      if (confirmText) btn.textContent = confirmText;
      setTimeout(() => { if (btn.isConnected) this.paint(); }, 4000);
      return;
    }
    btn.disabled = true;
    try {
      const res = await this.auth.fetch(`/api/social/carousels/${btn.getAttribute('data-ws-reopen')}/reopen`, { method: 'POST' });
      const body = await res.json().catch(() => null);
      if (!res.ok || !body || !body.success) throw new Error((body && body.message) || `HTTP ${res.status}`);
      this.note = '';
    } catch (err) {
      this.note = (window.MessageCopy && MessageCopy.block('social_post', 'reopen_failed', { reason: err.message })) || err.message;
    }
    await this._loadCarousels();
    this.paint();
  }
}

window.WeekendSlides = WeekendSlides;
