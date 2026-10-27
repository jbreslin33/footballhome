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
    const section = (label, html) => `<div class="ec-h" style="margin:var(--space-4) 0 var(--space-2);">${label}</div>${html}`;
    if (key === 'sides') return this._sidesHtml();
    if (key === 'plan') return this._planHtml()
      + section((window.MessageCopy && MessageCopy.block('cone_setup', 'pill')) || '🔶 Cones', this._conesHtml());
    return super.pillHtml(key);
  }

  onPill(key) {
    super.onPill(key);
    if (key === 'sides' && !this.sides) this._loadSides();
    if (key === 'plan' && this.plan === undefined) this._loadPlan();
    if (key === 'plan' && this.cones === undefined) this._loadCones();
  }

  // Groups / teams ride on the All Players cards, so they load with it.
  onEventLoaded() { this._loadSides(); }

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
      ${sessions.map(s => `<div class="ec-box">
        <div style="display:flex; justify-content:space-between; align-items:baseline; gap:8px;">
          <span class="ec-h">${this.escapeHtml(s.title || 'Session')}</span>
          <span style="font-size:0.78rem; opacity:0.7;">${this.escapeHtml(s.start_time)} – ${this.escapeHtml(s.end_time)}</span>
        </div>
        ${s.notes ? `<div style="font-size:0.85rem; opacity:0.85; white-space:pre-wrap;">${this.escapeHtml(s.notes)}</div>` : ''}
        ${(s.exercises || []).map(x => `<div style="padding:6px 0; border-top:1px solid var(--border-color); margin-top:6px;">
            <div style="font-weight:700; font-size:0.92rem;">${this.escapeHtml(x.title)}${x.player_count ? ` <span style="font-weight:400; opacity:0.6; font-size:0.78rem;">· ${x.player_count} players</span>` : ''}</div>
            ${x.description ? `<div style="font-size:0.82rem; opacity:0.85; white-space:pre-wrap;">${this.escapeHtml(x.description)}</div>` : ''}
            ${para('Setup', x.setup)}${para('Coaching points', x.coaching_points)}${para('Notes', x.notes)}
          </div>`).join('') || `<div style="font-size:0.82rem; opacity:0.55;">No exercises yet.</div>`}
      </div>`).join('')}
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
    const summary = onSide.length
      ? onSide.map(([c, list]) => `<div class="ec-box">
          <div class="ec-h">${swatch(c)} ${this.escapeHtml(c.label)} (${list.length})</div>
          <div style="font-size:0.9rem; margin-top:4px;">${list.map(p => this.escapeHtml(nameOf(p))).join(' · ')}</div>
        </div>`).join('')
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
      ? `<div class="ec-box"><div class="ec-h">${label} (${list.length})</div>${list.map(row).join('')}</div>` : '';
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
