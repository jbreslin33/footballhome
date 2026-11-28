// SessionPlanPanel — 🏋️ Session (practices) / 🔥 Warm-up (games) on an event
// page, from the team's session plan (mig 5020, models/SessionPlans).
//
// Owner 2026-11-27: "making it so we can tie it to a practice event and even
// a game as the warmup" · "for youth … mon,wed,fri … for men … -1 game day".
//
// Shows the exercises this practice / game gets: the event's own copy if a
// coach edited it, else the team's plan for its slot (youth: weekday; men /
// women: match day; a game: MD warm-up).  Coaches of the event can ✏️ edit
// this one (copy, then ▲▼, ± minutes, remove, ➕ add from the catalog) or go
// ↩ back to the plan.  Each exercise opens #exercises/<id>.
// Wording: message_templates kind 'exercises'.
//
// Mounted like CarpoolPanel: the host screen calls html() inside a panel,
// routes [data-sp] clicks to click(el, root), and gives rerender().
class SessionPlanPanel {
  constructor(auth, opts) {
    this.auth = auth;
    this.opts = opts;   // { fhEventId(), rerender(), escapeHtml(t), fold(key,title,body), goTo(screen, params) }
    this.reset();
  }

  reset() { this.data = undefined; this.forEvent = null; this.adding = false; this.q = ''; this.busy = false; this.err = null; }

  static copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('exercises', tier, tokens) : ''; }

  // "Wed", "MD-1 · day before", "MD · game warm-up", "No game this week".
  static slotLabel(slot) {
    if (!slot) return '';
    const c = SessionPlanPanel.copy;
    if (slot.anchor === 'weekday') return (String(c('weekdays')).split('|')[slot.weekday - 1]) || '';
    if (slot.anchor === 'no_game') return c('slot_no_game');
    const m = slot.md_offset;
    return c(`slot_md_${m < 0 ? 'm' + (-m) : m}`) || `MD${m > 0 ? '+' : ''}${m || ''}`;
  }

  // The catalog's light rows for the ➕ search (shared with #exercises).
  static catalog(auth) {
    if (!SessionPlanPanel._cat) {
      SessionPlanPanel._cat = auth.fetch('/api/exercises')
        .then(r => r.ok ? r.json() : Promise.reject(new Error(`HTTP ${r.status}`)))
        .catch(e => { SessionPlanPanel._cat = null; throw e; });
    }
    return SessionPlanPanel._cat;
  }

  async load() {
    const id = this.opts.fhEventId();
    if (!id) return;
    this.forEvent = id;
    try {
      const r = await this.auth.fetch(`/api/session-plans/event/${id}`);
      if (!r.ok) throw new Error(`HTTP ${r.status}`);
      const d = await r.json();
      if (this.opts.fhEventId() !== id) return;
      this.data = d; this.err = null;
    } catch (e) { this.data = null; this.err = e.message; }
    this.opts.rerender();
  }

  async _send(method, url, body) {
    this.busy = true; this.opts.rerender();
    try {
      const r = await this.auth.fetch(url, { method, headers: { 'Content-Type': 'application/json' }, body: body ? JSON.stringify(body) : undefined });
      if (!r.ok) { const j = await r.json().catch(() => ({})); throw new Error(j.error || `HTTP ${r.status}`); }
      this.err = null;
    } catch (e) { this.err = e.message; }
    this.busy = false;
    await this.load();
  }

  title() {
    const isGame = this.data ? this.data.kind === 'match' : false;
    return SessionPlanPanel.copy(isGame ? 'ev_warmup' : 'ev_session');
  }

  html() {
    const esc = (t) => this.opts.escapeHtml(t == null ? '' : String(t));
    const c = SessionPlanPanel.copy;
    if (this.forEvent !== this.opts.fhEventId()) { this.reset(); this.load(); }
    if (this.data === undefined) return this.opts.fold('session', esc(this.title() || '🏋️'), `<div style="opacity:0.7; padding:8px;">Loading…</div>`);
    if (!this.data) return this.opts.fold('session', esc(this.title()), `<div style="opacity:0.7;">${esc(this.err || '')}</div>`);
    const d = this.data;
    const editing = d.source === 'event';
    const canEdit = d.can_edit && !this.busy;
    const total = (d.exercises || []).reduce((n, x) => n + (x.minutes || 0), 0);
    const from = editing
      ? c('ev_edited', { kind: c(d.kind === 'match' ? 'kind_game' : 'kind_practice') })
      : (d.team ? c('ev_from_plan', { team: d.team.label, slot: SessionPlanPanel.slotLabel(d.slot) }) : '');
    let body = `<div style="font-size:0.78rem; opacity:0.75; margin-bottom:6px;">${esc(from)}${total ? ` · ${esc(c('plans_total', { n: total }))}` : ''}${d.theme ? ` · <i>${esc(d.theme)}</i>` : ''}</div>`;
    const rows = d.exercises || [];
    if (!rows.length) body += `<div style="opacity:0.6; font-size:0.85rem; padding:4px 0;">${esc(c('ev_none'))}</div>`;
    rows.forEach((x, i) => {
      body += `<div style="display:flex; gap:8px; align-items:flex-start; padding:7px 0; border-top:1px solid var(--border-color);">
        <div style="min-width:44px; text-align:right; font-weight:800; font-size:0.9rem;">${x.minutes ? esc(x.minutes) + "'" : ''}</div>
        <div style="flex:1; min-width:0;">
          <a href="#exercises/${x.exercise_id}" data-sp-open="${x.exercise_id}" style="font-weight:700; color:inherit;">${esc(x.icon || '')} ${esc(x.title)}</a>
          <div style="font-size:0.76rem; opacity:0.7;">${esc([x.category, x.players, x.area].filter(Boolean).join(' · '))}</div>
          ${x.note ? `<div style="font-size:0.8rem; margin-top:2px;">${esc(x.note)}</div>` : ''}
        </div>
        ${editing && canEdit ? `<div style="display:flex; gap:3px; flex-wrap:wrap; justify-content:flex-end;">
          <button type="button" class="ec-chip" data-sp-min="-5" data-sp-item="${x.id}" data-sp-cur="${x.minutes || 0}">−5</button>
          <button type="button" class="ec-chip" data-sp-min="5" data-sp-item="${x.id}" data-sp-cur="${x.minutes || 0}">+5</button>
          <button type="button" class="ec-chip" data-sp-move="-1" data-sp-item="${x.id}" ${i === 0 ? 'disabled' : ''}>${esc(c('up'))}</button>
          <button type="button" class="ec-chip" data-sp-move="1" data-sp-item="${x.id}" ${i === rows.length - 1 ? 'disabled' : ''}>${esc(c('down'))}</button>
          <button type="button" class="ec-chip" data-sp-del="${x.id}">✕</button></div>` : ''}
      </div>`;
    });
    if (canEdit || d.can_edit_plan) {
      body += `<div style="display:flex; gap:6px; flex-wrap:wrap; margin-top:8px;">`;
      if (canEdit && !editing) body += `<button type="button" class="ec-chip" data-sp-edit>${esc(c('ev_edit'))}</button>`;
      if (canEdit && editing) body += `<button type="button" class="ec-chip" data-sp-add>${esc(c('ev_add'))}</button>
                                       <button type="button" class="ec-chip" data-sp-reset>${esc(c('ev_reset'))}</button>`;
      if (d.can_edit_plan && d.team) body += `<button type="button" class="ec-chip" data-sp-plans="${d.team.id}">${esc(c('ev_open_plans'))}</button>`;
      body += `</div>`;
    }
    if (editing && canEdit && this.adding) body += this._searchHtml();
    if (this.err) body += `<div style="color:#fca5a5; font-size:0.8rem; margin-top:6px;">${esc(this.err)}</div>`;
    return this.opts.fold('session', esc(this.title()), body);
  }

  _searchHtml() {
    const esc = (t) => this.opts.escapeHtml(t == null ? '' : String(t));
    let list = '';
    if (this.cat) {
      const q = this.q.trim().toLowerCase();
      const hits = q.length < 2 ? [] : this.cat.exercises.filter(x =>
        [x.title, x.objective, x.coach].some(v => v && String(v).toLowerCase().includes(q))).slice(0, 25);
      const catById = new Map(this.cat.categories.map(k => [k.id, k]));
      list = hits.map(x => `<button type="button" class="ec-chip" data-sp-pick="${x.id}" style="display:block; width:100%; text-align:left; margin-top:4px;">
          ${esc((catById.get(x.category_id) || {}).icon || '')} <b>${esc(x.title)}</b> <span style="opacity:0.65;">${esc(x.players || '')}</span></button>`).join('');
    } else {
      SessionPlanPanel.catalog(this.auth).then(d => { this.cat = d; this.opts.rerender(); }).catch(() => {});
      list = `<div style="opacity:0.6;">Loading…</div>`;
    }
    return `<div style="margin-top:8px;"><input type="search" data-sp-q value="${esc(this.q)}" placeholder="${esc(SessionPlanPanel.copy('ev_search'))}"
              style="width:100%; padding:6px 10px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary);">${list}</div>`;
  }

  // A [data-sp-*] click inside the host.  true = handled.
  click(el, root) {
    const id = this.opts.fhEventId();
    if (root && !root._spWired) {
      root._spWired = true;
      root.addEventListener('input', (e) => {
        if (!e.target.matches || !e.target.matches('[data-sp-q]')) return;
        this.q = e.target.value;
        clearTimeout(this._qt);
        this._qt = setTimeout(() => {
          this.opts.rerender();
          const inp = root.querySelector('[data-sp-q]');
          if (inp) { inp.focus(); inp.setSelectionRange(inp.value.length, inp.value.length); }
        }, 250);
      });
    }
    const ds = el.dataset;
    if (ds.spOpen) { this.opts.goTo('exercises', { entity: ds.spOpen }); return true; }
    if (ds.spPlans) { this.opts.goTo('exercises', { view: 'plans', team: ds.spPlans }); return true; }
    if ('spEdit' in ds) { this._send('POST', `/api/session-plans/event/${id}/edit`); return true; }
    if ('spReset' in ds) { this.adding = false; this._send('DELETE', `/api/session-plans/event/${id}/edit`); return true; }
    if ('spAdd' in ds) { this.adding = !this.adding; this.opts.rerender(); return true; }
    if (ds.spPick) { this._send('POST', `/api/session-plans/event/${id}/items`, { exercise_id: Number(ds.spPick) }); return true; }
    if (ds.spDel) { this._send('DELETE', `/api/session-plans/items/event/${ds.spDel}`); return true; }
    if (ds.spMove) { this._send('PUT', `/api/session-plans/items/event/${ds.spItem}`, { move: Number(ds.spMove) }); return true; }
    if (ds.spMin) {
      const m = Math.max(5, Math.min(180, (Number(ds.spCur) || 0) + Number(ds.spMin)));
      this._send('PUT', `/api/session-plans/items/event/${ds.spItem}`, { minutes: m });
      return true;
    }
    return false;
  }
}
window.SessionPlanPanel = SessionPlanPanel;
