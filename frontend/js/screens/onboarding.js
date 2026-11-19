// OnboardingScreen — 🎓 #onboarding (mig 1526): club admins walk every
// volunteer and paid coach through the club's checklist (PA criminal
// history, child abuse, FBI fingerprints, NSOR, photo ID; then W-9 and direct
// deposit for paid).  Owner 2026-11-19: "we should have a volunteer page and
// a paid page … we should try to get all the volunteers onboarded" → "this
// way they feel like they have path to get paid and thus are motivated to
// volunteer".
//
//   🙋 Volunteers (n) / 💵 Paid (n)   pills; a card per person: progress,
//                                     a chip per step (⬜ / 🟡 / ✅ / ⛔),
//                                     tap a chip → ✅ Checked / ↩ Redo / ⬜ Clear
//                                     with a note; 💵 Make paid / 🙋 Back to
//                                     volunteer; 📇 Contact (the player sheet)
//   ➕ Start someone on the path      volunteers + coaches not on it yet
//
// The person sees the same steps in the 🚦 band's popup
// (components/onboarding-checklist.js) and taps "✅ I sent it".
//
//   GET  /api/onboarding
//   POST /api/onboarding/track {person_id, track: volunteer|paid|""}
//   POST /api/onboarding/step  {person_id, code, action: verified|redo|sent|clear, note}
// Words: message_templates kind onboarding.
class OnboardingScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null;
    this.error = '';
    this.pill = 'volunteer';
    this.sel = null;          // { pid, code } — the step whose actions are open
    this.busy = false;
  }

  onEnter() {
    this.error = '';
    this._load();
  }

  _t(tier, tokens, fb) { return OnboardingChecklist.t(tier, tokens, fb); }

  async _json(url, options = {}) {
    const res = await this.auth.fetch(url, { ...options, headers: { 'Content-Type': 'application/json', ...(options.headers || {}) } });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }

  async _load() {
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      this.data = await this._json('/api/onboarding');
    } catch (err) {
      this.error = err.message;
    }
    this._renderBody();
  }

  async _post(url, payload) {
    if (this.busy) return;
    this.busy = true;
    this.error = '';
    this._renderBody();
    try {
      this.data = await this._json(url, { method: 'POST', body: JSON.stringify(payload) });
    } catch (err) {
      this.error = err.message;
    }
    this.busy = false;
    this._renderBody();
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-onboarding';
    div.innerHTML = `
      <div class="screen-header" style="padding: var(--space-3) var(--space-4);">
        <h1 style="margin: var(--space-2) 0 0;">${this.escapeHtml(this._t('title', {}, '🎓 Onboarding'))}</h1>
        <p style="margin: 4px 0 0; opacity: 0.8;">${this.escapeHtml(this._t('sub', {}, 'Volunteer → paid: clearances, ID, then pay paperwork. Tap a step to check it.'))}</p>
      </div>
      <div id="onb-body" style="padding: 0 var(--space-4) var(--space-4); max-width: 860px;"></div>`;
    this.element = div;
    div.addEventListener('click', (e) => this._onClick(e));
    return div;
  }

  _person(pid) { return ((this.data && this.data.people) || []).find(p => Number(p.person_id) === pid) || null; }

  _onClick(e) {
    const t = (sel) => e.target.closest(sel);
    let el;
    if ((el = t('[data-onb-pill]'))) { this.pill = el.dataset.onbPill; this.sel = null; this._renderBody(); return; }
    if ((el = t('[data-onb-chip]'))) {
      const pid = Number(el.dataset.pid), code = el.dataset.onbChip;
      this.sel = this.sel && this.sel.pid === pid && this.sel.code === code ? null : { pid, code };
      this._renderBody();
      return;
    }
    if ((el = t('[data-onb-act]'))) {
      const note = (this.element.querySelector('[data-onb-note]') || {}).value || '';
      this._post('/api/onboarding/step', { person_id: Number(el.dataset.pid), code: el.dataset.code, action: el.dataset.onbAct, note: note.trim() });
      return;
    }
    if ((el = t('[data-onb-track]'))) {
      const track = el.dataset.onbTrack;
      if (!track && !confirm(this._t('act_remove', {}, 'Remove from onboarding') + '?')) return;
      this._post('/api/onboarding/track', { person_id: Number(el.dataset.pid), track });
      return;
    }
    if ((el = t('[data-onb-start]'))) {
      const pick = this.element.querySelector('[data-onb-pick]');
      const pid = Number(pick && pick.value);
      if (pid) this._post('/api/onboarding/track', { person_id: pid, track: el.dataset.onbStart });
      return;
    }
    if ((el = t('[data-onb-contact]'))) { this._contact(Number(el.dataset.onbContact)); }
  }

  _contact(pid) {
    const p = this._person(pid);
    if (!p || !window.PlayerSheet) return;
    const parts = String(p.name || '').split(/\s+/);
    PlayerSheet.open({
      host: this.element, auth: this.auth, tab: 'contact',
      resolve: () => ({ personId: pid, firstName: parts[0] || '', lastName: parts.slice(1).join(' '), returnTo: 'onboarding' }),
    });
  }

  _renderBody() {
    const body = this.element && this.element.querySelector('#onb-body');
    if (!body) return;
    const esc = (s) => this.escapeHtml(s == null ? '' : String(s));
    if (!this.data) {
      body.innerHTML = this.error ? `<p style="color:#ef4444;">${esc(this.error)}</p>` : '<p style="opacity:0.7;">…</p>';
      return;
    }
    const people = this.data.people || [];
    const vol = people.filter(p => p.track === 'volunteer'), paid = people.filter(p => p.track === 'paid');
    const list = this.pill === 'paid' ? paid : vol;
    const pill = (key, tier, fb, n) => `<button type="button" class="btn ${this.pill === key ? 'btn-primary' : 'btn-secondary'}" data-onb-pill="${key}" style="min-height:0; padding:6px 14px; border-radius:999px;">${esc(this._t(tier, { n }, fb))}</button>`;
    // Who still has the most to do first; complete people last.
    const order = [...list].sort((a, b) => (b.left - a.left) || ((a.done === a.total) - (b.done === b.total)) || String(a.name).localeCompare(String(b.name)));
    body.innerHTML = `
      <div style="display:flex; gap:8px; flex-wrap:wrap; margin:var(--space-2) 0 var(--space-3);">
        ${pill('volunteer', 'pill_volunteer', '🙋 Volunteers ({n})', vol.length)}
        ${pill('paid', 'pill_paid', '💵 Paid ({n})', paid.length)}
      </div>
      ${this.error ? `<p style="color:#ef4444; margin:0 0 8px;">${esc(this.error)}</p>` : ''}
      <div style="display:flex; flex-direction:column; gap:8px;">
        ${order.length ? order.map(p => this._card(p, esc)).join('') : `<p style="opacity:0.7;">${esc(this._t('empty', {}, 'Nobody here yet.'))}</p>`}
      </div>
      ${this._addHtml(esc)}`;
  }

  _card(p, esc) {
    const steps = p.steps || [];
    const complete = p.total > 0 && p.done === p.total;
    const colour = { todo: '#9ca3af', sent: '#facc15', done: '#22c55e', renew: '#ef4444' };
    const icon = { todo: '⬜', sent: '🟡', done: '✅', renew: '⛔' };
    const chip = (s) => {
      const on = this.sel && this.sel.pid === p.person_id && this.sel.code === s.code;
      return `<button type="button" data-onb-chip="${esc(s.code)}" data-pid="${p.person_id}" title="${esc(s.label)}"
          style="min-height:0; padding:4px 9px; border-radius:8px; font:inherit; font-size:0.78rem; font-weight:700; cursor:pointer;
                 border:${on ? 2 : 1}px solid ${colour[s.state] || '#9ca3af'}; background:${on ? 'rgba(255,255,255,0.08)' : 'transparent'}; color:inherit;
                 ${s.required ? '' : 'opacity:0.55; border-style:dashed;'}">${icon[s.state] || '⬜'} ${esc(s.label)}</button>`;
    };
    const sel = this.sel && this.sel.pid === p.person_id ? steps.find(s => s.code === this.sel.code) : null;
    const when = (iso) => (iso ? new Date(iso).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : '');
    const actions = sel ? `
        <div style="margin-top:8px; padding:9px 10px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-primary, rgba(0,0,0,0.15)); display:flex; flex-direction:column; gap:6px;">
          <div style="font-weight:800;">${esc(sel.label)} · ${OnboardingChecklist.stateHtml(sel.state, esc)}</div>
          <div style="font-size:0.8rem; opacity:0.8;">${esc(sel.how)}</div>
          ${sel.sent_at || sel.verified_at ? `<div style="font-size:0.78rem; opacity:0.75;">${sel.sent_at ? `🟡 ${esc(when(sel.sent_at))}` : ''}${sel.verified_at ? ` · ✅ ${esc(when(sel.verified_at))}` : ''}${sel.expires_at ? ` · ⏳ ${esc(when(sel.expires_at))}` : ''}</div>` : ''}
          <input type="text" data-onb-note value="${esc(sel.note || '')}" placeholder="Note (optional)" style="padding:6px 8px; border-radius:6px; border:1px solid var(--border-color); background:transparent; color:inherit; font:inherit;">
          <div style="display:flex; gap:6px; flex-wrap:wrap;">
            <button type="button" class="btn btn-primary" data-onb-act="verified" data-pid="${p.person_id}" data-code="${esc(sel.code)}" ${this.busy ? 'disabled' : ''} style="min-height:0; padding:6px 12px;">${esc(this._t('act_verify', {}, '✅ Checked'))}</button>
            <button type="button" class="btn btn-secondary" data-onb-act="redo" data-pid="${p.person_id}" data-code="${esc(sel.code)}" ${this.busy ? 'disabled' : ''} style="min-height:0; padding:6px 12px;">${esc(this._t('act_redo', {}, '↩ Redo'))}</button>
            <button type="button" class="btn btn-secondary" data-onb-act="clear" data-pid="${p.person_id}" data-code="${esc(sel.code)}" ${this.busy ? 'disabled' : ''} style="min-height:0; padding:6px 12px;">${esc(this._t('act_clear', {}, '⬜ Clear'))}</button>
          </div>
        </div>` : '';
    const move = p.track === 'volunteer'
      ? `<button type="button" class="btn btn-secondary" data-onb-track="paid" data-pid="${p.person_id}" style="min-height:0; padding:5px 10px; font-size:0.8rem;">${esc(this._t('act_make_paid', {}, '💵 Make paid'))}</button>`
      : `<button type="button" class="btn btn-secondary" data-onb-track="volunteer" data-pid="${p.person_id}" style="min-height:0; padding:5px 10px; font-size:0.8rem;">${esc(this._t('act_make_volunteer', {}, '🙋 Back to volunteer'))}</button>`;
    return `<div style="border:1px solid ${complete ? 'rgba(34,197,94,0.6)' : 'var(--border-color)'}; border-radius:10px; background:var(--bg-secondary); padding:10px 12px;">
        <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
          <span style="flex:1; min-width:140px; font-weight:800; font-size:1rem;">${esc(p.name)}</span>
          <span style="font-size:0.82rem; font-weight:800; color:${complete ? '#22c55e' : p.left ? '#ef4444' : '#facc15'};">${esc(complete ? this._t('complete', {}, '✅ Complete') : this._t('progress', { done: p.done, total: p.total }, '{done} of {total} done'))}</span>
          ${window.PlayerSheet ? `<button type="button" class="btn btn-secondary" data-onb-contact="${p.person_id}" style="min-height:0; padding:5px 10px; font-size:0.8rem;">📇</button>` : ''}
        </div>
        ${p.note ? `<div style="font-size:0.78rem; opacity:0.75; margin-top:2px;">${esc(p.note)}</div>` : ''}
        <div style="display:flex; gap:5px; flex-wrap:wrap; margin-top:8px;">${steps.map(chip).join('')}</div>
        ${actions}
        <div style="display:flex; gap:6px; flex-wrap:wrap; margin-top:8px;">
          ${move}
          <button type="button" class="btn btn-secondary" data-onb-track="" data-pid="${p.person_id}" style="min-height:0; padding:5px 10px; font-size:0.8rem; opacity:0.75;">${esc(this._t('act_remove', {}, 'Remove from onboarding'))}</button>
        </div>
      </div>`;
  }

  _addHtml(esc) {
    const c = (this.data && this.data.candidates) || [];
    if (!c.length) return '';
    return `<div style="margin-top:var(--space-4); border:1px dashed var(--border-color); border-radius:10px; padding:10px 12px;">
        <div style="font-weight:800;">${esc(this._t('add_title', {}, '➕ Start someone on the path'))}</div>
        <div style="font-size:0.8rem; opacity:0.75; margin:2px 0 8px;">${esc(this._t('add_hint', {}, 'Volunteers and coaches not on the path yet'))}</div>
        <div style="display:flex; gap:6px; flex-wrap:wrap; align-items:center;">
          <select data-onb-pick style="padding:6px 8px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-secondary); color:inherit; font:inherit; max-width:100%;">
            ${c.map(x => `<option value="${x.person_id}">${esc(x.name)}${x.why === 'volunteer' ? ' 🙋' : ''}</option>`).join('')}
          </select>
          <button type="button" class="btn btn-secondary" data-onb-start="volunteer" style="min-height:0; padding:6px 12px;">🙋</button>
          <button type="button" class="btn btn-secondary" data-onb-start="paid" style="min-height:0; padding:6px 12px;">💵</button>
        </div>
      </div>`;
  }
}

window.OnboardingScreen = OnboardingScreen;
