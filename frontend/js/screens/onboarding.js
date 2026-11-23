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
      <div id="onb-body" style="padding: 0 var(--space-4) var(--space-4); max-width: 860px;"></div>`;
    this.element = div;
    div.addEventListener('click', (e) => this._onClick(e));
    div.addEventListener('change', (e) => {
      const inp = e.target.closest('input[data-onb-admin-file]');
      if (!inp || !inp.files || !inp.files[0]) return;
      const f = inp.files[0]; inp.value = '';
      this._upload(Number(inp.dataset.pid), inp.dataset.onbAdminFile, f);
    });
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
    if ((el = t('[data-onb-contact]'))) { this._contact(Number(el.dataset.onbContact)); return; }
    if ((el = t('[data-onb-view]'))) { this._view(Number(el.dataset.onbView)); return; }
    if ((el = t('[data-onb-rmfile]'))) {
      if (confirm('Delete this file?')) this._post('/api/onboarding/file-remove', { id: Number(el.dataset.onbRmfile) });
      return;
    }
    if ((el = t('[data-onb-admin-upload]'))) {
      const inp = this.element.querySelector(`input[data-onb-admin-file="${el.dataset.onbAdminUpload}"][data-pid="${el.dataset.pid}"]`);
      if (inp) inp.click();
      return;
    }
    if ((el = t('[data-onb-send]'))) { this._send(Number(el.dataset.onbSend), el.dataset.stage || 'volunteer'); }
  }

  // 📎 Upload for someone (a document they emailed or handed in).
  async _upload(pid, code, file) {
    try {
      const f = await OnboardingChecklist.readFile(file);
      await this._post('/api/onboarding/upload', { person_id: pid, code, filename: f.filename, file: f.file });
    } catch (err) { this.error = err.message; this._renderBody(); }
  }

  // 👁 Open a stored file in a new tab (fetched with the sign-in, shown as a blob).
  async _view(id) {
    const win = window.open('', '_blank');
    try {
      const res = await this.auth.fetch(`/api/onboarding/file/${id}`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const url = URL.createObjectURL(await res.blob());
      if (win) win.location = url; else window.open(url, '_blank');
      setTimeout(() => URL.revokeObjectURL(url), 60000);
    } catch (err) {
      if (win) win.close();
      this.error = err.message; this._renderBody();
    }
  }

  // ✉️ Every file to compliance, cc the person and you (owner 11/19 "a button
  // for me to send it all to compliance … and we would include the volunteer").
  async _send(pid, stage) {
    const p = this._person(pid);
    if (!p) return;
    const n = (p.steps || []).filter(s => s.stage === stage).reduce((t, s) => t + ((s.files || []).length), 0);
    const st = (this.data.stages || []).find(x => x.stage === stage) || {};
    const to = st.email_to || '';
    if (!confirm(this._t('send_confirm', { n, name: p.name, to }, 'Email {n} file(s) for {name} to {to}, cc {name} and you?'))) return;
    this.sending = pid;
    await this._post('/api/onboarding/send', { person_id: pid, stage });
    this.sending = null;
    this._renderBody();
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
    // ⚽ Players (mig 1740): everyone who owes a player step (SafeSport) —
    // derived from the rosters, so no add / move / remove here.
    const players = people.filter(p => (p.steps || []).some(s => s.stage === 'player'));
    const list = this.pill === 'player' ? players : this.pill === 'paid' ? paid : vol;
    const pill = (key, tier, fb, n) => `<button type="button" class="btn ${this.pill === key ? 'btn-primary' : 'btn-secondary'}" data-onb-pill="${key}" style="min-height:0; padding:6px 14px; border-radius:999px;">${esc(this._t(tier, { n }, fb))}</button>`;
    // Who still has the most to do first; complete people last.
    const order = [...list].sort((a, b) => (b.left - a.left) || ((a.done === a.total) - (b.done === b.total)) || String(a.name).localeCompare(String(b.name)));
    body.innerHTML = `
      <div style="display:flex; gap:8px; flex-wrap:wrap; margin:var(--space-2) 0 var(--space-3);">
        ${pill('volunteer', 'pill_volunteer', '🙋 Volunteers ({n})', vol.length)}
        ${pill('paid', 'pill_paid', '💵 Paid ({n})', paid.length)}
        ${players.length ? pill('player', 'pill_player', '⚽ Players ({n})', players.length) : ''}
      </div>
      ${this.pill === 'player' ? `<p style="font-size:0.82rem; opacity:0.8; margin:0 0 8px;">${esc(this._t('player_note', {}, "Every men's player 18 or older, automatically. Uploaded = 🟡; tap the chip to see the certificate and mark it ✅ Checked."))}</p>` : ''}
      ${this.error ? `<p style="color:#ef4444; margin:0 0 8px;">${esc(this.error)}</p>` : ''}
      <div style="display:flex; flex-direction:column; gap:8px;">
        ${order.length ? order.map(p => this._card(p, esc)).join('') : `<p style="opacity:0.7;">${esc(this._t('empty', {}, 'Nobody here yet.'))}</p>`}
      </div>
      ${this.pill === 'player' ? '' : this._addHtml(esc)}
      ${this.data.policy && this.data.policy.purge_days ? `<p style="font-size:0.78rem; opacity:0.65; margin-top:var(--space-3);">${esc(this._t('files_purge', { days: this.data.policy.purge_days }, 'Files are deleted {days} days after they go to compliance — only the ticks stay.'))}</p>` : ''}`;
  }

  _card(p, esc) {
    const asPlayer = this.pill === 'player';
    // On ⚽ Players the card is the player steps only, with its own tally.
    const steps = (p.steps || []).filter(s => asPlayer ? s.stage === 'player' : true);
    if (asPlayer) p = { ...p, total: steps.length, done: steps.filter(s => s.state === 'done').length, left: steps.filter(s => s.state === 'todo' || s.state === 'renew').length, note: '' };
    const complete = p.total > 0 && p.done === p.total;
    const colour = { todo: '#9ca3af', sent: '#facc15', done: '#22c55e', renew: '#ef4444' };
    const icon = { todo: '⬜', sent: '🟡', done: '✅', renew: '⛔' };
    const chip = (s) => {
      const on = this.sel && this.sel.pid === p.person_id && this.sel.code === s.code;
      return `<button type="button" data-onb-chip="${esc(s.code)}" data-pid="${p.person_id}" title="${esc(s.label)}"
          style="min-height:0; padding:4px 9px; border-radius:8px; font:inherit; font-size:0.78rem; font-weight:700; cursor:pointer;
                 border:${on ? 2 : 1}px solid ${colour[s.state] || '#9ca3af'}; background:${on ? 'rgba(255,255,255,0.08)' : 'transparent'}; color:inherit;
                 ${s.required ? '' : 'opacity:0.55; border-style:dashed;'}">${icon[s.state] || '⬜'} ${esc(s.label)}${(s.files || []).length ? ` 📎${s.files.length}` : ''}</button>`;
    };
    const sel = this.sel && this.sel.pid === p.person_id ? steps.find(s => s.code === this.sel.code) : null;
    const when = (iso) => (iso ? new Date(iso).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : '');
    const actions = sel ? `
        <div style="margin-top:8px; padding:9px 10px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-primary, rgba(0,0,0,0.15)); display:flex; flex-direction:column; gap:6px;">
          <div style="font-weight:800;">${esc(sel.label)} · ${OnboardingChecklist.stateHtml(sel.state, esc)}</div>
          <div style="font-size:0.8rem; opacity:0.8;">${esc(sel.how)}</div>
          ${sel.sent_at || sel.verified_at ? `<div style="font-size:0.78rem; opacity:0.75;">${sel.sent_at ? `🟡 ${esc(when(sel.sent_at))}` : ''}${sel.verified_at ? ` · ✅ ${esc(when(sel.verified_at))}` : ''}${sel.expires_at ? ` · ⏳ ${esc(when(sel.expires_at))}` : ''}</div>` : ''}
          ${(sel.files || []).length ? OnboardingChecklist.filesHtml(sel.files, esc, { removable: true, viewable: true }) : `<div style="font-size:0.78rem; opacity:0.7;">${esc(this._t('no_files', {}, 'No files uploaded yet.'))}</div>`}
          <div><button type="button" class="btn btn-secondary" data-onb-admin-upload="${esc(sel.code)}" data-pid="${p.person_id}" ${this.busy ? 'disabled' : ''} style="min-height:0; padding:5px 10px; font-size:0.8rem;">${esc(this._t('upload', {}, '📎 Upload'))}</button>
            <input type="file" data-onb-admin-file="${esc(sel.code)}" data-pid="${p.person_id}" accept="image/*,application/pdf" hidden></div>
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
        ${asPlayer ? '' : this._sendHtml(p, esc)}
        <div style="display:${asPlayer ? 'none' : 'flex'}; gap:6px; flex-wrap:wrap; margin-top:8px;">
          ${move}
          <button type="button" class="btn btn-secondary" data-onb-track="" data-pid="${p.person_id}" style="min-height:0; padding:5px 10px; font-size:0.8rem; opacity:0.75;">${esc(this._t('act_remove', {}, 'Remove from onboarding'))}</button>
        </div>
      </div>`;
  }

  // ✉️ One button per email stage (owner 11/19 "the first submission is
  // the clearances then yineska the hr lh person has them do financials so
  // we need to do like 2 email stages"): clearances → compliance, finance →
  // HR.  🟢 Ready when every step of the stage has a file (or is ✅) and
  // nothing new is unsent.
  _sendHtml(p, esc) {
    const when = (iso) => new Date(iso).toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    const rows = (this.data.stages || []).map(st => {
      const steps = (p.steps || []).filter(s => s.stage === st.stage);
      if (st.stage === 'player') return '';   // a certificate stays with the club (mig 1740)
      if (st.stage === 'paid' && p.track !== 'paid') return '';
      const files = steps.reduce((l, s) => l.concat(s.files || []), []);
      const sentAt = p.sends && p.sends[st.stage];
      if (!files.length && !sentAt) return '';
      const unsent = files.filter(f => !f.emailed_at).length;
      const complete = steps.length && steps.every(s => s.state === 'done' || (s.files || []).length);
      const ready = complete && unsent > 0;
      const label = this._t(`act_send_${st.stage}`, {}, st.stage === 'paid' ? '✉️ Send finance to HR' : '✉️ Send clearances to compliance');
      const busy = this.busy && this.sending === p.person_id;
      const stageName = st.stage === 'paid' ? 'Finance' : 'Clearances';
      return `<div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-top:8px;">
          ${files.length ? (st.email_to
            ? `<button type="button" class="btn ${ready ? 'btn-primary' : 'btn-secondary'}" data-onb-send="${p.person_id}" data-stage="${st.stage}" ${this.busy ? 'disabled' : ''} style="min-height:0; padding:6px 12px; font-size:0.85rem;">${esc(busy ? this._t('sending', {}, 'Sending…') : `${label} (${files.length})`)}</button>`
            : `<span style="font-size:0.8rem; opacity:0.75;">${esc(label)} · ${esc(this._t('paid_no_email', {}, 'HR email not set yet'))}</span>`) : ''}
          ${ready ? `<span style="font-size:0.8rem; font-weight:800; color:#22c55e;">${esc(this._t('stage_ready', {}, '🟢 Ready to send'))}</span>` : ''}
          ${sentAt ? `<span style="font-size:0.8rem; opacity:0.8;">${esc(this._t('sent_line_stage', { stage: stageName, when: when(sentAt) }, '✉️ {stage} sent {when}'))}</span>` : ''}
        </div>`;
    });
    return rows.join('');
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
