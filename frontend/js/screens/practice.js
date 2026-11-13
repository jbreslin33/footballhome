// PracticeScreen — #practice: a practice or a pickup, the EventScreen
// child (screens/event-screen.js) that adds 🎽 Groups (Teams on a pickup)
// and 📝 Practice Plan with its 🔶 Cones (owner 2026-10-27: "it would
// instead have pill for all players, and then a pill to make groups for
// practice, and a pill to plan practice").
//
//   GET             /api/calendar/events/:id/session-plan   the practice plan
//                   attached to the event (edited on #practice-plan)
//   GET|POST        /api/calendar/events/:id/sides     pickup sides / practice
//                   groups by bib colour (match_lineups.squad_color; the
//                   colours are squad_colors rows, migration 372)
//   cone setups (mig 559) — GET|PUT /api/calendar/events/:id/cones
class PracticeScreen extends EventScreen {
  pills(ev) {
    const cp = (tier, fb) => (window.MessageCopy && MessageCopy.block('event_center', tier)) || fb;
    return [
      ...super.pills(ev),
      ev.kind === 'pickup'
        ? { key: 'sides', icon: '🎽', title: cp('pill_teams', 'Teams'), accent: '#8b5cf6' }
        : { key: 'sides', icon: '🎽', title: cp('pill_groups', 'Groups'), accent: '#8b5cf6' },
      { key: 'plan', icon: '📝', title: cp('pill_plan', 'Practice Plan'), accent: '#22c55e' },
    ];
  }

  pillHtml(key) {
    if (key === 'sides') return this._sidesHtml();
    if (key === 'plan') return this._planHtml()
      + this.panelFoldHtml('cones', this.escapeHtml((window.MessageCopy && MessageCopy.block('cone_setup', 'pill')) || '🔶 Cones'), this._conesHtml());
    if (key === 'players') return this._teamCardHtml() + this._callsHtml() + super.pillHtml(key);
    return super.pillHtml(key);
  }

  // ── 🗂 The practice card (owner 2026-11-13: "practice needs a graphic
  // like game but auto filled … separate in lineup by age. same with mens
  // practice sep by 'team' apsl or liga 1", then "i like it on pitch", "if
  // col is small then put another under", "if indoor then indoor pitch. if
  // outdoor then outdoor", "in order of highest age to lowest").
  //   one pitch per tagged team, oldest first (U12 → U10 → U8; adult teams
  //   keep the event's order), dropped into the shortest of two columns
  //   format  indoor (ev.setting, mig 931) → the 5v5 indoor shape on boards;
  //           outdoor → the team's field_size shape on striped grass
  //   who     every Going player under his team among the event's tagged
  //           teams (rsvps.team_ids); a man on two (APSL + L1) once, under
  //           the first, +L1; Going on none of them (invites) → their own block
  //   where   his usual spot (rsvps.usual_position = where he has started
  //           most), else a neighbouring spot, else any open one; beyond the
  //           shape → a bench line under the pitch.  Coaches a foot line,
  //           never counted.
  _teamCardHtml() {
    const ev = this.ev;
    const rsvps = Array.isArray(ev && ev.rsvps) ? ev.rsvps : [];
    const going = rsvps.filter(r => r && r.response === 'yes' && !r.suspension);
    if (!going.length) return '';
    const cp = (tier, fb, tokens = {}) => (window.MessageCopy && MessageCopy.block('event_center', tier, tokens))
      || fb.replace(/\{(\w+)\}/g, (m, k) => (k in tokens ? tokens[k] : m));
    const esc = (t) => this.escapeHtml(String(t == null ? '' : t));
    const indoor = ev.setting === 'indoor';
    const age = (t) => { const m = /U(\d+)/i.exec(t.short_label || t.label || t.name || ''); return m ? Number(m[1]) : 99; };
    const teams = (Array.isArray(ev.teams) ? ev.teams : []).map((t, i) => ({ t, i }))
      .sort((a, b) => age(b.t) - age(a.t) || a.i - b.i).map(x => x.t);   // oldest first
    const byId = new Map(teams.map(t => [Number(t.id), t]));
    const first = (r) => String(r.name || r.first_name || '?').trim().split(/\s+/)[0];
    const short = (r) => {
      const parts = String(r.name || [r.first_name, r.last_name].filter(Boolean).join(' ') || '?').trim().split(/\s+/);
      return parts.length > 1 ? `${parts[0]} ${parts[parts.length - 1][0]}.` : parts[0];
    };
    const blocks = new Map(teams.map(t => [Number(t.id), { team: t, rows: [] }]));
    const other = { team: { short_label: cp('card_other', 'Invited'), color: '#f59e0b', field_size: 11 }, rows: [] };
    const players = going.filter(r => !r.is_coach);
    for (const r of players) {
      const mine = (Array.isArray(r.team_ids) ? r.team_ids : []).map(Number).filter(id => byId.has(id))
        .sort((a, b) => teams.indexOf(byId.get(a)) - teams.indexOf(byId.get(b)));
      (mine.length ? blocks.get(mine[0]) : other).rows.push({ r, also: mine.slice(1).map(id => byId.get(id).short_label || '').filter(Boolean) });
    }
    const list = [...blocks.values(), other].filter(b => b.rows.length);
    // The shapes: Game Center's FIELD_SIZES when loaded, else the same defaults.
    const SHAPES = { 11: [[1], [3, 5, 4, 2], [11, 8, 6, 7], [10, 9]], 9: [[1], [3, 4, 2], [11, 6, 7], [10, 9]], 7: [[1], [5, 4], [8, 6], [10, 9]], 5: [[1], [4], [11, 7], [9]] };
    const shape = (n) => {
      try { if (typeof FIELD_SIZES !== 'undefined' && FIELD_SIZES[n]) { const f = FIELD_SIZES[n]; return f.formations[f.defaultFormation].rows; } } catch (_) {}
      return SHAPES[n] || SHAPES[11];
    };
    const NEAR = { 2: [3, 7, 4, 5], 3: [2, 11, 5, 4], 4: [5, 6, 2, 3], 5: [4, 6, 3, 2], 6: [8, 4, 5, 10], 7: [11, 2, 9, 10], 8: [6, 10, 5, 4],
                   9: [10, 7, 11, 8], 10: [9, 8, 11, 7], 11: [7, 3, 10, 9] };
    const place = (rows, people) => {
      const slots = rows.flat().filter(id => id > 0), free = new Set(slots), at = new Map(), left = [];
      const pool = people.slice();
      const take = (pick) => { for (let i = 0; i < pool.length; i++) { const id = pick(pool[i]); if (id != null) { at.set(id, pool[i]); free.delete(id); pool.splice(i--, 1); } } };
      take(x => (free.has(Number(x.r.usual_position)) ? Number(x.r.usual_position) : null));                    // his spot
      take(x => { const n = NEAR[Number(x.r.usual_position)] || []; return n.find(id => free.has(id)) ?? null; });   // next to it
      take(x => (x.r.usual_position && Number(x.r.usual_position) !== 1 ? [...free].find(id => id !== 1) ?? null : null)); // an outfield player, any outfield spot
      for (const x of pool) { const id = [...free].find(i => i !== 1) ?? (free.has(1) ? 1 : null); if (id != null) { at.set(id, x); free.delete(id); } else left.push(x); }
      return { at, bench: left };
    };
    const pitchSvg = (rows, at, color) => {
      const W = 100, H = 140, chip = (x, y, id, who) => `
        <g><circle cx="${x}" cy="${y}" r="5.2" fill="${who ? color : 'rgba(255,255,255,0.18)'}" stroke="#fff" stroke-width="0.8"/>
          <text x="${x}" y="${y + 1.9}" text-anchor="middle" font-size="5" font-weight="800" fill="#fff">${id}</text>
          ${who ? `<text x="${x}" y="${y + 11}" text-anchor="middle" font-size="5.6" font-weight="700" fill="#fff" stroke="rgba(0,0,0,0.55)" stroke-width="1.6" paint-order="stroke">${esc(first(who.r))}</text>` : ''}</g>`;
      const n = rows.length; let dots = '';
      rows.forEach((row, ri) => {   // keeper at the bottom, attacking up
        const y = H - 12 - ri * ((H - 30) / Math.max(1, n - 1));
        row.forEach((id, ci) => { if (id > 0) dots += chip(W * (ci + 1) / (row.length + 1), y, id, at.get(id)); });
      });
      const ground = indoor
        ? `<rect x="1.5" y="1.5" width="${W - 3}" height="${H - 3}" rx="9" fill="#1f6f43" stroke="#94a3b8" stroke-width="3"/>
           <line x1="4" y1="${H / 2}" x2="${W - 4}" y2="${H / 2}" stroke="rgba(255,255,255,0.7)" stroke-width="0.7"/>
           <circle cx="${W / 2}" cy="${H / 2}" r="9" fill="none" stroke="rgba(255,255,255,0.7)" stroke-width="0.7"/>
           <path d="M30 ${H - 3} A20 20 0 0 1 70 ${H - 3} M30 3 A20 20 0 0 0 70 3" fill="none" stroke="rgba(255,255,255,0.7)" stroke-width="0.7"/>
           <rect x="42" y="${H - 4}" width="16" height="3" fill="#e2e8f0"/><rect x="42" y="1" width="16" height="3" fill="#e2e8f0"/>`
        : `<defs><pattern id="pc-grass" width="${W}" height="20" patternUnits="userSpaceOnUse"><rect width="${W}" height="10" fill="#2f7d32"/><rect y="10" width="${W}" height="10" fill="#388e3c"/></pattern></defs>
           <rect x="0" y="0" width="${W}" height="${H}" fill="url(#pc-grass)"/>
           <rect x="4" y="4" width="${W - 8}" height="${H - 8}" fill="none" stroke="#fff" stroke-width="0.8"/>
           <line x1="4" y1="${H / 2}" x2="${W - 4}" y2="${H / 2}" stroke="#fff" stroke-width="0.8"/>
           <circle cx="${W / 2}" cy="${H / 2}" r="10" fill="none" stroke="#fff" stroke-width="0.8"/>
           <rect x="24" y="${H - 22}" width="52" height="18" fill="none" stroke="#fff" stroke-width="0.8"/><rect x="24" y="4" width="52" height="18" fill="none" stroke="#fff" stroke-width="0.8"/>
           <rect x="38" y="${H - 10}" width="24" height="6" fill="none" stroke="#fff" stroke-width="0.8"/><rect x="38" y="4" width="24" height="6" fill="none" stroke="#fff" stroke-width="0.8"/>`;
      return `<svg viewBox="0 0 ${W} ${H}" style="width:100%; display:block; border-radius:${indoor ? 10 : 4}px;" role="img">${ground}${dots}</svg>`;
    };
    const ncols = Math.min(2, list.length);
    const cols = Array.from({ length: ncols }, () => ({ h: 0, html: '' }));
    for (const b of list) {
      b.rows.sort((x, y) => short(x.r).localeCompare(short(y.r)));
      const size = indoor ? 5 : (Number(b.team.field_size) || 11);
      const rows = shape(size);
      const { at, bench } = place(rows, b.rows);
      const c = /^#[0-9a-f]{6}$/i.test(b.team.color || '') ? b.team.color : '#64748b';
      const also = b.rows.filter(x => x.also.length);
      const col = cols.reduce((m, k) => (k.h < m.h ? k : m), cols[0]);   // shortest column takes the next team
      col.html += `<div style="margin-bottom:12px;">
          <div style="display:flex; justify-content:space-between; align-items:baseline; border-bottom:2px solid ${c}; padding-bottom:3px; margin-bottom:5px;">
            <span style="font-weight:900; letter-spacing:0.04em; color:#fff;">${esc(b.team.short_label || b.team.label || b.team.name)}</span>
            <span style="font-weight:800; color:${c}; font-size:0.85rem;">${b.rows.length}</span></div>
          ${pitchSvg(rows, at, c)}
          ${bench.length ? `<div style="font-size:0.72rem; color:#cbd5e1; margin-top:4px; line-height:1.35;"><b style="color:${c};">${esc(cp('card_bench', 'Rotating in'))}:</b> ${bench.map(x => esc(short(x.r))).join(', ')}</div>` : ''}
          ${also.length ? `<div style="font-size:0.65rem; color:#94a3b8; margin-top:2px;">${also.map(x => `${esc(first(x.r))} +${esc(x.also.join(' +'))}`).join(' · ')}</div>` : ''}
        </div>`;
      col.h += 14 + (bench.length ? Math.ceil(bench.length / 3) : 0);   // a pitch ≈ 14 lines, bench by its lines
    }
    const coaches = going.filter(r => r.is_coach);
    const when = [this._when(ev), EventLabels.timesLine(ev)].filter(Boolean).join(' · ');
    return `<div style="margin:0 0 var(--space-3); border:3px solid #d4af37; border-radius:14px; padding:14px 14px;
                 background:linear-gradient(160deg, #0b1f3a, #132b52); box-shadow:0 4px 14px rgba(0,0,0,0.35);">
        <div style="text-align:center; font-weight:900; letter-spacing:0.12em; color:#d4af37; font-size:0.95rem;">${esc(cp('card_title', 'LIGHTHOUSE · {kind}', { kind: ev.kind === 'pickup' ? 'PICKUP' : 'PRACTICE' }))}</div>
        <div style="text-align:center; color:#cbd5e1; font-size:0.8rem; margin:2px 0 12px;">${esc(when)}${ev.location ? ` · ${esc(ev.location)}` : ''} · ${esc(cp(indoor ? 'card_indoor' : 'card_outdoor', indoor ? 'Indoor' : 'Outdoor'))}</div>
        <div style="display:grid; grid-template-columns:repeat(${ncols}, minmax(0, 1fr)); gap:12px; align-items:start;">
          ${cols.map(k => `<div>${k.html}</div>`).join('')}</div>
        <div style="text-align:center; color:#d4af37; font-weight:800; font-size:0.85rem; margin-top:2px;">${esc(cp('card_total', '{n} going', { n: players.length }))}</div>
        ${coaches.length ? `<div style="text-align:center; color:#94a3b8; font-size:0.75rem; margin-top:4px;">${esc(cp('card_coaches', 'Coaches: {names}', { names: coaches.map(short).join(', ') }))}</div>` : ''}
      </div>`;
  }

  // ── 📞 Attendance calls (mig 1277; owner 2026-11-11: "call all coaches
  // that set going to practice 1/2 way through to remind to take
  // attendance … until all players who set going are markd off"). A strip
  // over the Players pill for coaches/admins: when the calls start, who
  // gets rung, who is still unmarked, the rounds so far.  The calls
  // themselves: AttendanceCallScheduler.  Refreshes every minute here.
  async _loadCalls() {
    const id = this.ev && this.ev.fh_event_id;
    if (!id || this.ev.kind !== 'practice') return;
    try {
      const body = await this._json(`/api/attendance-calls/event?id=${encodeURIComponent(id)}`);
      if (!this.ev || this.ev.fh_event_id !== id) return;
      this.calls = body;
    } catch (err) {
      this.calls = null;   // non-staff get a 403: no strip
    }
    if (this.pill === 'players') this._render();
  }

  _startCallsPoll() {
    this._stopCallsPoll();
    this._callsTimer = setInterval(() => this._loadCalls(), 60 * 1000);
  }
  _stopCallsPoll() { if (this._callsTimer) { clearInterval(this._callsTimer); this._callsTimer = null; } }

  _callsHtml() {
    const c = this.calls;
    if (!c || c.kind !== 'practice') return '';
    const esc = (t) => this.escapeHtml(String(t == null ? '' : t));
    const cp = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.block('attendance_call', tier, tokens)) || fb;
    const line = (txt, style = '') => `<div style="font-size:0.8rem; ${style}">${esc(txt)}</div>`;
    let body = '';
    if (!c.on) {
      body = line(cp('strip_off', {}, 'Attendance calls are off for this section'), 'opacity:0.7;');
    } else {
      const coaches = c.coaches || [];
      const unmarked = c.unmarked || [];
      body += line(cp('strip_when', { time: c.calls_from, every: c.repeat_minutes },
        `From ${c.calls_from} the coaches who said Going get a call every ${c.repeat_minutes} min until every Going player is marked`), 'opacity:0.85;');
      if (!c.live) body += line(cp('strip_test', { who: c.test_name || '' }, `🧪 Test mode: calls ring ${c.test_name || ''} only, not the coaches`), 'color:#fbbf24; font-weight:700;');
      body += coaches.length
        ? line(cp('strip_coaches', { names: coaches.map(x => x.name + (x.phone ? '' : ' (no phone)')).join(', ') },
            `Calls: ${coaches.map(x => x.name).join(', ')}`))
        : line(cp('strip_nocoach', {}, 'No coach said Going — nobody to call'), 'color:#f87171;');
      body += unmarked.length
        ? line(cp('strip_wait', { n: unmarked.length }, `${unmarked.length} going players not marked yet`) + ': ' + unmarked.join(', '), 'color:#fca5a5; font-weight:700;')
        : (c.going_players ? line(cp('strip_done', {}, '✅ Every going player is marked — no calls'), 'color:#86efac; font-weight:700;') : '');
      (c.rounds || []).slice(0, 3).forEach((r) => {
        body += line(`${cp('strip_last', { round: r.round, time: r.at }, `Round ${r.round} at ${r.at}`)} · 📞 ${r.ok}/${r.tried}${r.live ? '' : ' 🧪'} · ${r.unmarked}`, 'opacity:0.7;');
      });
    }
    // Rolled up like every pill (owner 11/11); still waiting on marks
    // shows on the closed summary.
    const unmarkedN = (c.on && (c.unmarked || []).length) || 0;
    return this.panelFoldHtml('calls', esc(cp('strip_title', {}, '📞 Attendance calls')), body,
      { aside: unmarkedN ? `<span style="color:#fca5a5;">${esc(cp('strip_wait', { n: unmarkedN }, `${unmarkedN} going players not marked yet`))}</span>` : '' });
  }

  onPill(key) {
    super.onPill(key);
    if (key === 'sides' && !this.sides) this._loadSides();
    if (key === 'plan' && this.plan === undefined) this._loadPlan();
    if (key === 'plan' && this.cones === undefined) this._loadCones();
  }

  // Groups / teams ride on the All Players cards, so they load with it.
  onEventLoaded() { this._loadSides(); this.calls = null; this._loadCalls(); this._startCallsPoll(); }

  onExit() { this._stopCallsPoll(); if (super.onExit) super.onExit(); }

  resetKind() {
    this.sides = null;        // { canEdit, colors, players }
    this.plan = undefined;
    this.cones = undefined;    // undefined = not loaded; null = no plan
    this.sideColors = null;   // Set of colour codes in play on this event
  }

  onClick(t) {
    let el;
    if ((el = t('[data-ec-practice-plan]'))) { this.navigation.goTo('practice-plan', {}); return true; }
    if ((el = t('[data-ec-side]'))) { this._setSide(Number(el.dataset.personId), el.dataset.ecSide); return true; }
    if ((el = t('[data-ec-side-color]'))) {
      const code = el.dataset.ecSideColor;
      if (this.sideColors.has(code)) this.sideColors.delete(code); else this.sideColors.add(code);
      this._render();
      return true;
    }
    return false;
  }

  _wire() {
    super._wire();
    this.element.addEventListener('change', (e) => { const sel = e.target.closest('[data-ec-cones]'); if (sel) this._pickCones(sel.value); });
  }

  // ── groups on the cards ─────────────────────────────────────────────
  _sideOf(pid) {
    const p = this.sides && !this.sides.failed && this.sides.players.find(x => x.person_id === pid);
    return p ? p.squad_color : null;
  }

  _colorOf(code) { return (this.sides && this.sides.colors.find(c => c.code === code)) || null; }

  _swatch(c, size = 14) {
    return `<span style="display:inline-block; width:${size}px; height:${size}px; border-radius:50%;
      background:${c.hex}; border:1px solid var(--border-color); vertical-align:middle;"></span>`;
  }

  // Group swatches: the colours in play, for whoever may edit sides.
  _cardSideHtml(r) {
    if (!this.sides || this.sides.failed) return '<span></span>';
    const mine = this._sideOf(r.person_id);
    if (!this.sides.canEdit) {
      const c = mine && this._colorOf(mine);
      return c ? `<span title="${this.escapeHtml(c.label)}">${this._swatch(c)}</span>` : '<span></span>';
    }
    const saving = this.saving.has(`side:${r.person_id}`);
    return `<span style="display:inline-flex; gap:5px;">${this.sides.colors.filter(c => this.sideColors && this.sideColors.has(c.code)).map(c => {
      const active = mine === c.code;
      return `<button type="button" class="ec-att" data-ec-side="${c.code}" data-person-id="${r.person_id}"
                ${saving ? 'disabled' : ''} title="${this.escapeHtml(c.label)}${active ? ' — tap to clear' : ''}"
                style="background:${c.hex}; border:${active ? '3px solid var(--primary-color)' : '1px solid var(--border-color)'};
                       opacity:${active || !mine ? 1 : 0.35};"></button>`;
    }).join('')}</span>`;
  }

  // Groups in play + who is on each, over the Going cards (the 🎽 pill
  // keeps the full editor).
  _goingTopHtml(going) {
    const sideOf = (pid) => this._sideOf(pid), swatch = (c, s) => this._swatch(c, s);
    const cp = (tier, tokens) => (window.MessageCopy && MessageCopy.block('event_center', tier, tokens)) || '';
    if (this.sides && !this.sides.failed) {
      const onSide = this.sides.colors.map(c => [c, going.filter(r => sideOf(r.person_id) === c.code)]).filter(([, l]) => l.length);
      const chooser = this.sides.canEdit ? `<div style="display:flex; gap:var(--space-1); flex-wrap:wrap; align-items:center; margin-bottom:6px;">
          <span style="font-size:0.72rem; font-weight:800; opacity:0.75;">${this.escapeHtml(cp(this.ev.kind === 'pickup' ? 'teams_in_play' : 'groups_in_play') || (this.ev.kind === 'pickup' ? 'Teams' : 'Groups'))}</span>
          ${this.sides.colors.map(c => `<button type="button" class="ec-chip ${this.sideColors && this.sideColors.has(c.code) ? 'on' : ''}"
              data-ec-side-color="${c.code}">${swatch(c, 10)} ${this.escapeHtml(c.label)}</button>`).join('')}
        </div>` : '';
      const summary = onSide.length ? `<div style="display:flex; gap:10px; flex-wrap:wrap; font-size:0.78rem; margin-bottom:6px;">
          ${onSide.map(([c, l]) => `<span>${swatch(c, 10)} <b>${this.escapeHtml(c.label)}</b> ${l.length}</span>`).join('')}
          <span style="opacity:0.6;">${going.length - onSide.reduce((n, [, l]) => n + l.length, 0)} unassigned</span>
        </div>` : '';
      return chooser + summary;
    }
    return '';
  }

  async _loadPlan() {
    const id = this.ev.fh_event_id;
    try {
      const body = await this._json(`/api/calendar/events/${id}/session-plan`);
      if (!this.ev || this.ev.fh_event_id !== id) return;
      this.plan = body.practice || null;
    } catch (err) {
      console.error('[practice] session plan load failed:', err);
      this.plan = null;
    }
    this._render();
  }

  // Cone setups (mig 559, owner 2026-10-09): the layout this session uses,
  // the default unless a coach picks another for it.
  async _loadCones() {
    const id = this.ev.fh_event_id;
    try {
      const body = await this._json(`/api/calendar/events/${id}/cone-setup`);
      if (!this.ev || this.ev.fh_event_id !== id) return;
      this.cones = body;
    } catch (err) { console.error('[practice] cone setup load failed:', err); this.cones = null; }
    this._render();
  }

  async _pickCones(value) {
    const id = this.ev.fh_event_id;
    try {
      this.cones = await this._json(`/api/calendar/events/${id}/cone-setup`, { method: 'POST', body: JSON.stringify({ cone_setup_id: value ? Number(value) : null }) });
    } catch (err) { alert(`Could not save: ${err.message}`); }
    this._render();
  }

  // The cones of a setup: every cone_spacing_yd along each rectangle's
  // edges, corners once.  Pure geometry from the rows — nothing stored per cone.
  static coneDots(setup) {
    const sp = Number(setup.cone_spacing_yd) || 5, seen = new Set(), dots = [];
    const add = (x, y) => { const k = `${x.toFixed(2)},${y.toFixed(2)}`; if (!seen.has(k)) { seen.add(k); dots.push([x, y]); } };
    for (const a of (setup.areas || [])) {
      const x0 = Number(a.x), y0 = Number(a.y), w = Number(a.w), h = Number(a.h);
      for (let d = 0; d <= w + 1e-9; d += sp) { add(x0 + d, y0); add(x0 + d, y0 + h); }
      for (let d = 0; d <= h + 1e-9; d += sp) { add(x0, y0 + d); add(x0 + w, y0 + d); }
    }
    return dots;
  }

  // The drawing: the part of the pitch in use (goal line at the bottom),
  // its boxes, and a dot per cone.  1 yard = 6 px.
  static coneSvg(setup) {
    const W = Number(setup.area_width_yd), L = Number(setup.area_length_yd), k = 6, pad = 18;
    const esc = (t) => String(t == null ? '' : t).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
    const dots = PracticeScreen.coneDots(setup);
    const goalAtBottom = setup.area_anchor !== 'top';
    const half = setup.area_anchor !== 'full';
    const gw = 8 * k, gx = (W * k - gw) / 2, pa = 18 * k, pw = 44 * k, px = (W * k - pw) / 2, ga = 6 * k, gaw = 20 * k, gax = (W * k - gaw) / 2;
    const box = (w, d) => `<rect x="${(W * k - w) / 2}" y="${goalAtBottom ? L * k - d : 0}" width="${w}" height="${d}" fill="none" stroke="#9ca3af" stroke-width="1" stroke-dasharray="3 3"/>`;
    return `<svg viewBox="${-pad} ${-pad} ${W * k + 2 * pad} ${L * k + 2 * pad}" style="width:100%; max-width:560px; display:block; background:#14532d; border-radius:8px;" xmlns="http://www.w3.org/2000/svg">
      <rect x="0" y="0" width="${W * k}" height="${L * k}" fill="#166534" stroke="#e5e7eb" stroke-width="1.5"/>
      ${box(pw, pa)}${box(gaw, ga)}
      <rect x="${gx}" y="${goalAtBottom ? L * k : -3}" width="${gw}" height="3" fill="#e5e7eb"/>
      ${half ? `<line x1="0" y1="${goalAtBottom ? 0 : L * k}" x2="${W * k}" y2="${goalAtBottom ? 0 : L * k}" stroke="#e5e7eb" stroke-width="1" stroke-dasharray="6 4"/><circle cx="${W * k / 2}" cy="${goalAtBottom ? 0 : L * k}" r="${10 * k}" fill="none" stroke="#9ca3af" stroke-width="1" stroke-dasharray="3 3"/>` : ''}
      ${(setup.areas || []).map(a => `<rect x="${Number(a.x) * k}" y="${Number(a.y) * k}" width="${Number(a.w) * k}" height="${Number(a.h) * k}" fill="rgba(251,191,36,0.10)" stroke="#fbbf24" stroke-width="1"/>
        <text x="${(Number(a.x) + Number(a.w) / 2) * k}" y="${(Number(a.y) + Number(a.h) / 2) * k}" fill="#fde68a" font-size="11" text-anchor="middle" dominant-baseline="middle" opacity="0.9">${esc(a.label)} · ${esc(Number(a.w))}×${esc(Number(a.h))}</text>`).join('')}
      ${dots.map(([x, y]) => `<circle cx="${x * k}" cy="${y * k}" r="3.2" fill="#f97316" stroke="#7c2d12" stroke-width="0.8"/>`).join('')}
      <text x="${W * k / 2}" y="${goalAtBottom ? L * k + 13 : -6}" fill="#e5e7eb" font-size="9" text-anchor="middle" opacity="0.7">${esc(W)} yd</text>
      <text x="${-6}" y="${L * k / 2}" fill="#e5e7eb" font-size="9" text-anchor="middle" transform="rotate(-90 -6 ${L * k / 2})" opacity="0.7">${esc(L)} yd</text>
    </svg>`;
  }

  _conesHtml() {
    if (this.cones === undefined) return `<div style="text-align:center; opacity:0.7; padding:var(--space-6);">Loading…</div>`;
    const c = this.cones;
    const copy = (tier, tokens) => window.MessageCopy ? MessageCopy.block('cone_setup', tier, tokens) : '';
    if (!c || !c.setup) return `<div class="ec-box" style="opacity:0.7;">No cone setups are defined yet.</div>`;
    const s = c.setup, dots = PracticeScreen.coneDots(s);
    const areaWord = copy(`area_${s.area_anchor}`, { length: s.area_length_yd, width: s.area_width_yd }) || `${s.area_anchor} ${s.area_length_yd} × ${s.area_width_yd} yd`;
    const picker = c.can_edit ? `
      <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin-bottom:8px;">
        <span style="font-size:0.8rem; opacity:0.8;">${this.escapeHtml(copy('choose') || 'Cone setup for this practice')}</span>
        <select data-ec-cones style="font-size:0.85rem; padding:4px 8px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary);">
          ${(c.setups || []).map(x => `<option value="${x.id}" ${x.id === s.id ? 'selected' : ''}>${this.escapeHtml(x.name)}${x.is_default ? ` (${this.escapeHtml(copy('default_tag') || 'default')})` : ''}</option>`).join('')}
        </select>
      </div>` : '';
    return `<div class="ec-box">
      ${picker}
      <div style="font-weight:700;">${this.escapeHtml(s.name)}${s.is_default ? ` <span style="font-size:0.7rem; opacity:0.6; font-weight:400;">· ${this.escapeHtml(copy('default_tag') || 'default')}</span>` : ''}</div>
      ${s.description ? `<div style="font-size:0.82rem; opacity:0.8; margin:2px 0 8px;">${this.escapeHtml(s.description)}</div>` : ''}
      ${c.chosen_id == null ? `<div style="font-size:0.76rem; opacity:0.65; margin-bottom:6px;">${this.escapeHtml(copy('using_default') || 'Using the default setup.')}</div>` : ''}
      ${PracticeScreen.coneSvg(s)}
      <div style="font-size:0.8rem; opacity:0.8; margin-top:6px;">${this.escapeHtml(copy('summary', { cones: dots.length, boxes: (s.areas || []).length, spacing: s.cone_spacing_yd, area: areaWord }) || `${dots.length} cones · ${(s.areas || []).length} boxes · every ${s.cone_spacing_yd} yd · ${areaWord}`)}</div>
    </div>`;
  }

  async _loadSides() {
    const id = this.ev.fh_event_id;
    try {
      const body = await this._json(`/api/calendar/events/${id}/sides`);
      if (!this.ev || this.ev.fh_event_id !== id) return;
      this.sides = { canEdit: !!body.can_edit, colors: body.colors || [], players: body.players || [] };
      // In play: whatever is already used; a fresh event starts with the
      // first two colours.
      const used = new Set(this.sides.players.map(p => p.squad_color).filter(Boolean));
      if (!this.sideColors) {
        this.sideColors = used.size ? used : new Set(this.sides.colors.slice(0, 2).map(c => c.code));
      } else {
        used.forEach(c => this.sideColors.add(c));
      }
    } catch (err) {
      console.error('[practice] sides load failed:', err);
      this.sides = { canEdit: false, colors: [], players: [], failed: true };
    }
    this._render();
  }

  // Tap a colour to put the player on it; tap their current colour to take
  // them off.
  async _setSide(personId, color) {
    const key = `side:${personId}`;
    if (this.saving.has(key)) return;
    const player = this.sides.players.find(p => p.person_id === personId);
    if (!player) return;
    const next = player.squad_color === color ? null : color;
    this.saving.add(key);
    this._render();
    try {
      await this._json(`/api/calendar/events/${this.ev.fh_event_id}/sides`, {
        method: 'POST',
        body: JSON.stringify({ person_id: personId, squad_color: next }),
      });
      player.squad_color = next;
    } catch (err) {
      console.error('[practice] side save failed:', err);
      alert(`Could not save: ${err.message}`);
    } finally {
      this.saving.delete(key);
    }
    this._render();
  }

  // The practice plan attached to this event, read-only — sessions in order,
  // each with its exercises.  Editing stays on #practice-plan.
  _planHtml() {
    if (this.plan === undefined) return `<div style="text-align:center; opacity:0.7; padding:var(--space-6);">Loading…</div>`;
    const canMark = !!(this.att && this.att.canMark);
    const editBtn = canMark
      ? `<button type="button" class="btn btn-secondary" data-ec-practice-plan style="padding:4px 12px; font-size:0.85rem;">📋 Practice Plans</button>` : '';
    if (!this.plan) {
      return `<div class="ec-box" style="display:flex; justify-content:space-between; align-items:center; gap:8px; flex-wrap:wrap;">
        <span style="opacity:0.7;">No session plan is attached to this event.</span>${editBtn}</div>`;
    }
    const para = (label, text) => text
      ? `<div style="font-size:0.82rem; margin-top:4px; white-space:pre-wrap;"><b>${label}:</b> ${this.escapeHtml(text)}</div>` : '';
    const sessions = this.plan.sessions || [];
    return `
      ${this.plan.notes ? `<div class="ec-box" style="white-space:pre-wrap;">${this.escapeHtml(this.plan.notes)}</div>` : ''}
      ${sessions.map((s, si) => this.panelFoldHtml(`plan_${si}`,
          `${this.escapeHtml(s.title || 'Session')} <span style="font-weight:400; opacity:0.7;">${this.escapeHtml(s.start_time)} – ${this.escapeHtml(s.end_time)}</span>`, `
        ${s.notes ? `<div style="font-size:0.85rem; opacity:0.85; white-space:pre-wrap;">${this.escapeHtml(s.notes)}</div>` : ''}
        ${(s.exercises || []).map(x => `<div style="padding:6px 0; border-top:1px solid var(--border-color); margin-top:6px;">
            <div style="font-weight:700; font-size:0.92rem;">${this.escapeHtml(x.title)}${x.player_count ? ` <span style="font-weight:400; opacity:0.6; font-size:0.78rem;">· ${x.player_count} players</span>` : ''}</div>
            ${x.description ? `<div style="font-size:0.82rem; opacity:0.85; white-space:pre-wrap;">${this.escapeHtml(x.description)}</div>` : ''}
            ${para('Setup', x.setup)}${para('Coaching points', x.coaching_points)}${para('Notes', x.notes)}
          </div>`).join('') || `<div style="font-size:0.82rem; opacity:0.55;">No exercises yet.</div>`}
      `)).join('')}
      ${editBtn ? `<div style="text-align:right;">${editBtn}</div>` : ''}`;
  }

  // Pickup sides / practice groups by bib colour.  Top: each colour and who
  // is on it.  Below, for whoever may edit: the roster, people who are
  // coming first, with one swatch per colour in play.
  _sidesHtml() {
    if (!this.sides) return `<div style="text-align:center; opacity:0.7; padding:var(--space-6);">Loading…</div>`;
    if (this.sides.failed) return `<div class="ec-box" style="opacity:0.7;">Could not load.</div>`;
    const { canEdit, colors, players } = this.sides;
    const word = this.ev.kind === 'pickup' ? 'team' : 'group';
    const nameOf = (p) => [p.first_name, p.last_name].filter(Boolean).join(' ') || 'Unknown';
    const swatch = (c, size = 14) => `<span style="display:inline-block; width:${size}px; height:${size}px; border-radius:50%;
      background:${c.hex}; border:1px solid var(--border-color); vertical-align:middle;"></span>`;

    const onSide = colors
      .map(c => [c, players.filter(p => p.squad_color === c.code)])
      .filter(([, list]) => list.length);
    // Each colour a fold (owner 11/11: every pill rolled up).
    const summary = onSide.length
      ? onSide.map(([c, list]) => this.panelFoldHtml(`side_${c.code}`, `${swatch(c)} ${this.escapeHtml(c.label)} (${list.length})`,
          `<div style="font-size:0.9rem;">${list.map(p => this.escapeHtml(nameOf(p))).join(' · ')}</div>`)).join('')
      : `<div class="ec-box" style="opacity:0.7;">Nobody is on a ${word} yet.</div>`;
    if (!canEdit) return summary;

    const inPlay = colors.filter(c => this.sideColors.has(c.code));
    const row = (p) => {
      const saving = this.saving.has(`side:${p.person_id}`);
      return `<div class="ec-row">
        <span>${this.escapeHtml(nameOf(p))}</span>
        <span style="display:inline-flex; gap:6px;">${inPlay.map(c => {
          const active = p.squad_color === c.code;
          return `<button type="button" class="ec-att" data-ec-side="${c.code}" data-person-id="${p.person_id}"
                    ${saving ? 'disabled' : ''} title="${this.escapeHtml(c.label)}${active ? ' — tap to clear' : ''}"
                    style="background:${c.hex}; border:${active ? '3px solid var(--primary-color)' : '1px solid var(--border-color)'};
                           opacity:${active || !p.squad_color ? 1 : 0.35};"></button>`;
        }).join('')}</span>
      </div>`;
    };
    const group = (label, list) => list.length
      ? this.panelFoldHtml(`sides_${label.replace(/[^a-z]/gi, '').toLowerCase()}`, `${label} (${list.length})`, list.map(row).join('')) : '';
    return `
      ${summary}
      <div style="display:flex; gap:var(--space-1); flex-wrap:wrap; align-items:center; margin:var(--space-3) 0 var(--space-2);">
        <span class="ec-h">Colours in play</span>
        ${colors.map(c => `<button type="button" class="ec-chip ${this.sideColors.has(c.code) ? 'on' : ''}"
            data-ec-side-color="${c.code}">${swatch(c, 10)} ${this.escapeHtml(c.label)}</button>`).join('')}
      </div>
      ${group('Going', players.filter(p => !p.is_coach && p.rsvp === 'yes'))}
      ${group('No response', players.filter(p => !p.is_coach && p.rsvp !== 'yes' && p.rsvp !== 'no'))}
      ${group('Not going', players.filter(p => !p.is_coach && p.rsvp === 'no'))}
      ${players.some(p => p.is_coach) ? `<div class="ec-box" style="border-style:dashed; opacity:0.85;"><span class="ec-h">Coaches — not on a side</span>
        <div class="ec-row"><span>${players.filter(p => p.is_coach).map(p => this.escapeHtml([p.first_name, p.last_name].filter(Boolean).join(' '))).join(', ')}</span></div></div>` : ''}`;
  }
}

window.PracticeScreen = PracticeScreen;
