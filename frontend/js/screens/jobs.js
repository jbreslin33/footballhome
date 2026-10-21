// JobsScreen — #jobs: event jobs, auto-assigned, default-done (mig 625).
//
// Top-level 🧹 Jobs tile (admins + coaches).  Pick an event (games and
// practices of the window), and footballhome has already assigned its
// job set from who is actually going (RSVP yes / marked present):
// sticky home jobs first — never bumped, no forced rotation — then
// gap-fills by done-it-before, then fewest jobs lately.  Late RSVPs
// re-run the fill on every open.
//
// Check-off defaults to DONE: at the end of the event only the
// exceptions get tapped ("didn't do"), everything else counts as done.
// Toggleable jobs (tents) have a per-event ON/OFF — off frees those
// players for other gaps.  Job titles and the detail shown on tap are
// job_definitions rows — copy lives in the DB, never here.
//
//   GET  /api/jobs/board?from=&days=
//   GET  /api/jobs/event/:id
//   POST /api/jobs/event/:id/mark      { assignment_id, not_done }
//   POST /api/jobs/event/:id/toggle    { job_definition_id, on }
//   POST /api/jobs/event/:id/assign    { job_definition_id, person_id }
//   POST /api/jobs/event/:id/unassign  { assignment_id }
class JobsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.events = null;
    this.eventId = null;
    this.detail = null;
    this.openDesc = new Set();   // job ids with the description expanded
    this.addFor = null;          // job id with the assign-select open
    this.error = null;
  }

  onEnter(params = {}) {
    this.error = null;
    this.detail = null;
    this.eventId = params && params.eventId ? Number(params.eventId) : this.eventId;
    this._render();
    this._loadBoard();
  }

  // ── data ──────────────────────────────────────────────────────────────
  async _json(url, options = {}) {
    const res = await this.auth.fetch(url, options);
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }

  async _loadBoard() {
    try {
      const body = await this._json('/api/jobs/board');
      this.events = body.events || [];
      // Default pick: today's first event, else the next upcoming, else
      // the most recent past one.
      if (!this.eventId && this.events.length) {
        const today = new Date().toISOString().slice(0, 10);
        const pick = this.events.find(e => e.date >= today) || this.events[this.events.length - 1];
        this.eventId = pick.id;
      }
      this._renderBody();
      if (this.eventId) this._loadEvent();
    } catch (err) { this.error = err.message; this._renderBody(); }
  }

  async _loadEvent() {
    try {
      this.detail = await this._json(`/api/jobs/event/${this.eventId}`);
      this._renderBody();
    } catch (err) { this.error = err.message; this._renderBody(); }
  }

  async _post(path, payload) {
    try {
      this.detail = await this._json(`/api/jobs/event/${this.eventId}/${path}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      this._renderBody();
    } catch (err) { this.error = err.message; this._renderBody(); }
  }

  // ── render ────────────────────────────────────────────────────────────
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-jobs';
    div.innerHTML = `
      <style>
        .jb-pill { padding:4px 10px; border-radius:999px; cursor:pointer; font-size:0.78rem; font-weight:700; white-space:nowrap;
                   border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .jb-pill.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .jb-job { border:1px solid var(--border-color); border-radius:var(--radius-md); padding:10px 12px; margin-bottom:8px;
                  background:var(--bg-secondary); }
        .jb-job.off { opacity:0.55; }
        .jb-who { display:inline-flex; align-items:center; gap:6px; padding:3px 9px; border-radius:999px; font-size:0.8rem;
                  border:1px solid #4ade80; background:rgba(74,222,128,0.12); }
        .jb-who.notdone { border-color:#f87171; background:rgba(248,113,113,0.14); }
        .jb-who button { border:none; background:transparent; color:inherit; cursor:pointer; padding:0; font-size:0.8rem; }
        .jb-ghost { font-size:0.72rem; opacity:0.6; }
        .jb-src { font-size:0.68rem; opacity:0.55; }
      </style>
      <div class="screen-header" style="padding: var(--space-3) var(--space-4);">
        <div style="display:flex; align-items:center; gap:12px; flex-wrap:wrap;">
          <button class="btn btn-secondary" id="jb-back">← Back</button>
          <h1 style="margin:0;">🧹 Jobs</h1>
          <p class="subtitle" style="margin:0;">Auto-assigned from who's going — everything counts DONE unless flagged</p>
        </div>
      </div>
      <div id="jb-body" style="padding: 0 var(--space-4) var(--space-4); max-width: 900px;">Loading…</div>
    `;
    this.element = div;
    div.querySelector('#jb-back').addEventListener('click', () => this.navigation.goTo('role-selection'));
    div.addEventListener('click', (e) => this._onClick(e));
    div.addEventListener('change', (e) => this._onChange(e));
    return div;
  }

  _render() { if (this.element) this._renderBody(); }

  _renderBody() {
    const body = this.find('#jb-body');
    if (!body) return;
    const esc = (t) => this.escapeHtml(t);
    if (this.error) {
      body.innerHTML = `<div class="card" style="padding:14px; color:#f87171;">${esc(this.error)}</div>`;
      this.error = null;
      return;
    }
    if (!this.events) { body.innerHTML = 'Loading…'; return; }

    const evLabel = (e) => e.kind === 'match'
      ? `⚽ ${e.league ? e.league + ' ' : ''}${e.is_home === false ? 'at' : 'vs'} ${e.opponent || 'TBD'}`
      : `🏃 ${e.summary || e.team_label || 'Practice'}`;
    const pills = this.events.map(e => `
      <button class="jb-pill ${e.id === this.eventId ? 'on' : ''}" data-ev="${e.id}"
        title="${esc(e.day_label)} ${esc(e.time_label)}${e.flagged ? ` · ${e.flagged} flagged` : ''}">
        ${esc(e.day_label)} · ${esc(evLabel(e))}${e.flagged ? ' ⚠' : ''}</button>`).join('');

    let detailHtml = '';
    const d = this.detail;
    if (d && d.event && d.event.id === this.eventId) {
      const jobs = (d.jobs || []).map(j => this._jobHtml(j, d.pool || [])).join('')
        || `<div class="jb-ghost" style="padding:10px 0;">No jobs are defined for this kind of event yet — they're job_definitions rows, added by migration.</div>`;
      const idle = (d.pool || []).filter(p => !p.has_job);
      detailHtml = `
        <div style="margin:10px 0 6px; font-weight:800;">
          ${esc(evLabel(d.event))} — ${esc(d.event.day_label)} ${esc(d.event.time_label)}
          <span class="jb-ghost" style="font-weight:400;">· ${(d.pool || []).length} going</span>
        </div>
        ${jobs}
        ${idle.length ? `<div class="jb-ghost" style="margin-top:6px;">Going, no job: ${esc(idle.map(p => p.name).join(', '))}</div>` : ''}`;
    } else if (this.eventId) {
      detailHtml = '<div style="padding:10px 0;">Loading…</div>';
    } else {
      detailHtml = '<div class="jb-ghost" style="padding:10px 0;">No games or practices in the window.</div>';
    }

    body.innerHTML = `
      <div style="display:flex; gap:6px; flex-wrap:wrap; margin-bottom:6px;">${pills}</div>
      ${detailHtml}`;
  }

  _jobHtml(j, pool) {
    const esc = (t) => this.escapeHtml(t);
    const chips = (j.assignments || []).map(a => `
      <span class="jb-who ${a.not_done ? 'notdone' : ''}" title="${a.source === 'home' ? 'Home job' : a.source === 'manual' ? 'Assigned by hand' : 'Gap fill'}">
        ${esc(a.name)} <span class="jb-src">${a.source === 'home' ? '🏠' : a.source === 'manual' ? '✍️' : '＋'}</span>
        <button data-mark="${a.id}" data-nd="${a.not_done ? 0 : 1}"
          title="${a.not_done ? 'Flagged — tap to count it done after all' : 'Counts as DONE — tap only if they didn’t do it'}">
          ${a.not_done ? "✗ didn't do" : '✓'}</button>
        <button data-unassign="${a.id}" title="Take ${esc(a.name)} off this job">×</button>
      </span>`).join(' ');
    const short = Math.max(0, j.needed - (j.assignments || []).length);
    const addSel = this.addFor === j.id ? `
      <select data-add-sel="${j.id}" style="font-size:0.8rem; margin-left:6px;">
        <option value="">— pick a player —</option>
        ${pool.map(p => `<option value="${p.person_id}">${esc(p.name)}${p.has_job ? ' (has a job)' : ''}</option>`).join('')}
      </select>` : `
      <button class="jb-pill" data-add="${j.id}" style="padding:2px 8px; font-size:0.72rem;">＋ assign</button>`;
    return `
      <div class="jb-job ${j.off ? 'off' : ''}">
        <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
          <button data-desc="${j.id}" style="border:none; background:transparent; color:inherit; cursor:pointer;
                  font-weight:800; font-size:0.95rem; padding:0;">${esc(j.title)}</button>
          <span class="jb-ghost">${j.needed} needed</span>
          ${j.toggleable ? `
            <button class="jb-pill ${j.off ? '' : 'on'}" data-toggle="${j.id}" data-on="${j.off ? 1 : 0}"
              style="padding:2px 8px; font-size:0.72rem;">${j.off ? 'OFF this event' : 'ON'}</button>` : ''}
          ${!j.off && short ? `<span style="color:#f59e0b; font-size:0.74rem; font-weight:700;">${short} short</span>` : ''}
          <span style="flex:1;"></span>
          ${j.off ? '' : addSel}
        </div>
        ${this.openDesc.has(j.id) ? `<div class="jb-ghost" style="margin-top:4px; font-size:0.8rem;">${esc(j.description)}</div>` : ''}
        ${j.off ? '' : `<div style="display:flex; gap:6px; flex-wrap:wrap; margin-top:6px;">${chips || '<span class="jb-ghost">nobody yet</span>'}</div>`}
      </div>`;
  }

  // ── events ────────────────────────────────────────────────────────────
  async _onClick(e) {
    const ev = e.target.closest('[data-ev]');
    if (ev) { this.eventId = Number(ev.dataset.ev); this.detail = null; this.addFor = null; this._renderBody(); this._loadEvent(); return; }
    const desc = e.target.closest('[data-desc]');
    if (desc) {
      const id = Number(desc.dataset.desc);
      this.openDesc.has(id) ? this.openDesc.delete(id) : this.openDesc.add(id);
      this._renderBody(); return;
    }
    const mark = e.target.closest('[data-mark]');
    if (mark) { await this._post('mark', { assignment_id: Number(mark.dataset.mark), not_done: mark.dataset.nd === '1' }); return; }
    const un = e.target.closest('[data-unassign]');
    if (un) { await this._post('unassign', { assignment_id: Number(un.dataset.unassign) }); return; }
    const tog = e.target.closest('[data-toggle]');
    if (tog) { await this._post('toggle', { job_definition_id: Number(tog.dataset.toggle), on: tog.dataset.on === '1' }); return; }
    const add = e.target.closest('[data-add]');
    if (add) { this.addFor = Number(add.dataset.add); this._renderBody(); return; }
  }

  async _onChange(e) {
    const sel = e.target.closest('[data-add-sel]');
    if (sel && sel.value) {
      const jobId = Number(sel.dataset.addSel);
      this.addFor = null;
      await this._post('assign', { job_definition_id: jobId, person_id: Number(sel.value) });
    }
  }
}
