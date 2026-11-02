// CoachScheduleScreen — #coach-schedule (mig 955): club admins set which
// weekdays each coach covers.  A coach sees, and RSVPs to, only those days'
// practices on #my; games are never affected.  No days = call in if needed:
// invite them on the practice in Event Center.  Each tap saves.
//
//   GET  /api/coach-schedule
//   POST /api/coach-schedule  { coach_id, club_section_id, days }
//
// Words: message_templates kind coach_schedule.
class CoachScheduleScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.sections = null;
    this.error = '';
    this.busy = new Set();     // coach:section keys with a save running
  }

  onEnter() {
    this.error = '';
    this._load();
  }

  _t(tier, tokens, fallback) {
    return (window.MessageCopy && MessageCopy.block('coach_schedule', tier, tokens)) || fallback;
  }

  async _json(url, options = {}) {
    const res = await this.auth.fetch(url, options);
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }

  async _load() {
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      const body = await this._json('/api/coach-schedule');
      this.sections = body.sections || [];
    } catch (err) {
      this.error = err.message;
    }
    this._renderBody();
  }

  async _save(sectionId, coachId, days) {
    const section = (this.sections || []).find(s => s.id === sectionId);
    const coach = section && section.coaches.find(c => c.coach_id === coachId);
    const key = `${coachId}:${sectionId}`;
    if (!coach || this.busy.has(key)) return;
    this.busy.add(key);
    this.error = '';
    const before = coach.days;
    coach.days = days;
    this._renderBody();
    try {
      const body = await this._json('/api/coach-schedule', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ coach_id: coachId, club_section_id: sectionId, days }),
      });
      coach.days = body.days;
    } catch (err) {
      coach.days = before;
      this.error = err.message;
    }
    this.busy.delete(key);
    this._renderBody();
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-coach-schedule';
    div.innerHTML = `
      <div class="screen-header" style="padding: var(--space-3) var(--space-4);">
        <button type="button" class="btn btn-secondary" data-cs-back>← Back</button>
        <h1 style="margin: var(--space-2) 0 0;">${this.escapeHtml(this._t('title', {}, 'Coach Schedule'))}</h1>
        <p style="margin: 4px 0 0; opacity: 0.8;">${this.escapeHtml(this._t('sub', {}, 'Coaches RSVP only to the practices on their days'))}</p>
      </div>
      <div id="cs-body" style="padding: var(--space-4); max-width: 760px;"></div>`;
    this.element = div;
    div.addEventListener('click', (e) => this._onClick(e));
    return div;
  }

  // The header reads the DB words once they have loaded.
  _renderHead() {
    const h = this.find('h1'), p = this.find('.screen-header p');
    if (h) h.textContent = this._t('title', {}, 'Coach Schedule');
    if (p) p.textContent = this._t('sub', {}, h ? p.textContent : '');
  }

  _onClick(e) {
    if (e.target.closest('[data-cs-back]')) { this.navigation.goTo('role-selection'); return; }
    const btn = e.target.closest('[data-cs-coach]');
    if (!btn) return;
    const coachId = Number(btn.dataset.csCoach);
    const sectionId = Number(btn.dataset.csSection);
    const section = (this.sections || []).find(s => s.id === sectionId);
    const coach = section && section.coaches.find(c => c.coach_id === coachId);
    if (!coach) return;
    if (btn.dataset.csSet === 'every') { this._save(sectionId, coachId, [1, 2, 3, 4, 5, 6, 7]); return; }
    if (btn.dataset.csSet === 'callin') { this._save(sectionId, coachId, []); return; }
    const day = Number(btn.dataset.csDay);
    const days = coach.days.includes(day) ? coach.days.filter(d => d !== day) : [...coach.days, day].sort();
    this._save(sectionId, coachId, days);
  }

  _planText(days) {
    if (days.length === 7) return this._t('every', {}, 'Every practice');
    if (!days.length) return this._t('call_in', {}, 'Call in if needed');
    return days.map(d => this._t(`day_${d}`, {}, String(d))).join(' · ');
  }

  _renderBody() {
    const body = this.find('#cs-body');
    if (!body) return;
    this._renderHead();
    if (!this.sections) { body.innerHTML = this.error ? `<p style="color:#f87171;">${this.escapeHtml(this.error)}</p>` : '<p>Loading…</p>'; return; }
    const pill = (on) => `padding:7px 0; width:44px; border-radius:8px; font-weight:800; font-size:0.74rem; cursor:pointer;
      border:1px solid ${on ? '#22c55e' : 'rgba(255,255,255,0.2)'}; background:${on ? '#15803d' : 'transparent'}; color:${on ? '#fff' : '#cbd5e1'};`;
    const quick = 'padding:6px 10px; border-radius:8px; border:1px solid rgba(255,255,255,0.2); background:transparent; color:#dbeafe; font-size:0.72rem; font-weight:700; cursor:pointer;';
    const row = (section, c) => {
      const attrs = `data-cs-coach="${c.coach_id}" data-cs-section="${section.id}"`;
      const days = [1, 2, 3, 4, 5, 6, 7].map(d => `<button type="button" ${attrs} data-cs-day="${d}" style="${pill(c.days.includes(d))}">${this.escapeHtml(this._t(`day_${d}`, {}, String(d)))}</button>`).join('');
      return `<div style="padding:10px 12px; margin-bottom:8px; border:1px solid rgba(255,255,255,0.1); border-radius:10px; background:rgba(15,23,42,0.45);">
        <div style="display:flex; justify-content:space-between; gap:8px; flex-wrap:wrap; margin-bottom:8px;">
          <b>${this.escapeHtml(c.name)}</b><span style="font-size:0.8rem; color:#fcd34d; font-weight:700;">${this.escapeHtml(this._planText(c.days))}</span>
        </div>
        <div style="display:flex; gap:4px; flex-wrap:wrap; align-items:center;">
          ${days}
          <button type="button" ${attrs} data-cs-set="every" style="${quick}">${this.escapeHtml(this._t('every', {}, 'Every practice'))}</button>
          <button type="button" ${attrs} data-cs-set="callin" style="${quick}">${this.escapeHtml(this._t('call_in', {}, 'Call in if needed'))}</button>
        </div>
      </div>`;
    };
    body.innerHTML = `
      ${this.error ? `<p style="color:#f87171;">${this.escapeHtml(this.error)}</p>` : ''}
      <p style="font-size:0.8rem; opacity:0.8; margin:0 0 12px;">${this.escapeHtml(this._t('call_in_hint', {}, 'To call a coach in, invite them on the practice in Event Center.'))}</p>
      ${this.sections.map(s => `<h2 style="font-size:1rem; margin:16px 0 8px;">${this.escapeHtml(s.name)}</h2>${s.coaches.map(c => row(s, c)).join('')}`).join('')}`;
  }
}

window.CoachScheduleScreen = CoachScheduleScreen;
