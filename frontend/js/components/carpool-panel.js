// CarpoolPanel — the 🚗 panel, shared by Game Center (games) and the Event
// Center (practices; owner 2026-10-19: "this should be for practices too!").
// One implementation so the two screens can't drift (migs 601/608/609).
//
// Upgrades over the mig-601 panel (owner 2026-10-19: "show 3 options and
// the estimated time … option 1: Goto Driver house at x time, option 2:
// driver does pickup … option 3: nuetral spot like lighthosue … it might
// say Carly is requesting ride. it would take you an addditional x minutes
// … but it not be publlic knowlege"):
//   • "I can drive" opens the 3-option picker (GET …/options), each with
//     leave/pickup times computed back from the event's arrival time;
//     accepting POSTs the chosen plan and the card shows it from then on.
//   • Open requests carry a per-viewer "+X minutes" nudge; the server
//     sends the pickup address only to the requester, the accepted driver
//     and staff — this panel just renders what it's given.
// All wording is the DB's (MessageCopy kind 'carpool').
//
// Host contract: new CarpoolPanel(auth, { fhEventId: () => id|null,
// rerender: () => void, toast: (msg) => void, escapeHtml: (t) => string }).
// The host's click delegation routes every [data-gc-cp] press to click(btn),
// renders html() into its layout, and calls load() when its event changes.
class CarpoolPanel {
  constructor(auth, host) {
    this.auth = auth;
    this.host = host;
    this.data = null;        // {viewerPersonId, requests, riders}
    this.formFor = null;     // personId whose request form is open
    this.optionsFor = null;  // request id whose plan picker is open
    this.options = null;     // {options: [...], missing} for optionsFor
    this.busy = false;
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('carpool', tier, tokens) : ''; }
  _esc(t) { return this.host.escapeHtml(t); }

  _fmtAddress(r) {
    const line1 = [r.address1, r.address2].filter(Boolean).join(', ');
    const line2 = [r.city, [r.state, r.zip].filter(Boolean).join(' ')].filter(Boolean).join(', ');
    return [line1, line2].filter(Boolean).join(', ');
  }

  async load() {
    this.data = null;
    const id = this.host.fhEventId();
    if (!id) return;
    try {
      const res = await this.auth.fetch(`/api/carpool/${id}`);
      const body = await res.json().catch(() => null);
      this.data = (res.ok && body && body.success) ? body : null;
    } catch (err) {
      this.data = null;
    }
  }

  // The agreed (or offered) plan line, one wording per kind.
  _planLine(kind, tokens) {
    if (kind === 'driver_home')
      return this._copy('opt_driver_home', tokens) || `${tokens.rider} comes to the driver's place — leave together by ${tokens.leave}.`;
    if (kind === 'rider_home')
      return this._copy('opt_rider_home', tokens) || `Driver picks ${tokens.rider} up — leave by ${tokens.leave}, pickup about ${tokens.pickup} (+${tokens.minutes} min).`;
    return this._copy('opt_spot', tokens) || `Meet at ${tokens.spot} by ${tokens.pickup} — driver leaves by ${tokens.leave}.`;
  }

  _optionPicker(r) {
    const esc = (t) => this._esc(t);
    const o = this.options;
    if (!o) return `<div style="font-size:0.7rem; opacity:0.7; margin-top:4px;">…</div>`;
    const head = `<div style="font-size:0.7rem; font-weight:700; margin-top:6px;">${esc(this._copy('pick_title') || 'How do you want to do the pickup?')}</div>`;
    if (!o.options || !o.options.length) {
      // No estimate possible (an address or the venue is not on file):
      // the plan still works, just without times.
      return `${head}
        <div style="font-size:0.68rem; color:#f59e0b; margin:3px 0;">${esc(this._copy('no_geo') || 'No drive-time estimate — an address is missing.')}</div>
        <button class="btn btn-primary" data-gc-cp="accept-with" data-cp-id="${r.id}" data-kind=""
                ${this.busy ? 'disabled' : ''} style="padding:4px 10px; font-size:0.7rem;">${esc(this._copy('accept') || 'I can drive')}</button>`;
    }
    const rows = o.options.map(opt => {
      const tokens = { rider: r.name, leave: opt.leaveAt, pickup: opt.pickupAt, minutes: opt.extraMinutes, spot: opt.spotName || '' };
      return `
        <button class="btn btn-secondary" data-gc-cp="accept-with" data-cp-id="${r.id}"
                data-kind="${opt.kind}" data-spot="${opt.spotId || ''}" ${this.busy ? 'disabled' : ''}
                style="display:block; width:100%; text-align:left; margin-top:4px; padding:7px 10px;
                       font-size:0.72rem; min-height:0; white-space:normal; line-height:1.35;">
          ${esc(this._planLine(opt.kind, tokens))}
          ${opt.extraMinutes > 0 ? `<span style="opacity:0.7;"> (+${Number(opt.extraMinutes)} min)</span>` : ''}
        </button>`;
    }).join('');
    return head + rows;
  }

  html() {
    const cp = this.data;
    if (!cp) return '';
    const esc = (t) => this._esc(t);
    const me = Number(cp.viewerPersonId);
    const smsBtn = (phone, label) => phone ? `<a href="sms:${esc(phone)}" style="display:inline-flex; align-items:center; gap:4px; padding:2px 8px; border-radius:999px; border:1px solid var(--border-color); color:inherit; text-decoration:none; font-size:0.66rem;">💬 ${esc(label || phone)}</a>` : '';
    const act = (action, id, cls, label) => `<button class="btn ${cls}" data-gc-cp="${action}" data-cp-id="${id}" ${this.busy ? 'disabled' : ''} style="padding:3px 10px; font-size:0.7rem; font-weight:700;">${label}</button>`;

    const rows = (cp.requests || []).map(r => {
      const addr = this._fmtAddress(r);
      const mineReq = Number(r.requestedBy.personId) === me;
      const driver = r.acceptedBy;
      const iDrive = driver && Number(driver.personId) === me;
      const status = driver
        ? `<span style="color:#22c55e; font-weight:700;">${esc(this._copy('accepted_by', { driver: driver.name }) || `🚗 ${driver.name} is driving`)}</span>`
        : `<span style="color:#f59e0b; font-weight:700;">${esc(this._copy('needs_driver') || 'Needs a driver')}</span>`;
      const btns = [
        !driver && !mineReq ? act('options', r.id, 'btn-primary', esc(this._copy('accept') || 'I can drive')) : '',
        iDrive ? act('unaccept', r.id, 'btn-secondary', esc(this._copy('unaccept') || "Can't drive anymore")) : '',
        mineReq ? act('cancel', r.id, 'btn-secondary', esc(this._copy('cancel') || 'Cancel request')) : '',
      ].filter(Boolean).join(' ');
      // The personalized detour nudge — minutes, never the address.
      const nudge = !driver && !mineReq && r.extraMinutes != null
        ? `<div style="font-size:0.7rem; color:#60a5fa; margin-top:2px;">${esc(this._copy('nudge_extra', { name: r.name, minutes: r.extraMinutes }) || `${r.name} is requesting a ride — picking them up adds about ${r.extraMinutes} min for you.`)}</div>` : '';
      // The agreed plan, once a driver picked one.
      const plan = driver && r.meetPlan && r.meetPlan.kind
        ? `<div style="font-size:0.7rem; color:#22c55e; margin-top:2px;">🗺 ${esc(this._planLine(r.meetPlan.kind, { rider: r.name, leave: r.meetPlan.leaveAt || '', pickup: r.meetPlan.pickupAt || '', minutes: r.meetPlan.extraMinutes ?? '', spot: r.meetPlan.spot || '' }))}</div>` : '';
      return `
        <div style="padding:7px 0; border-top:1px solid var(--border-color); font-size:0.76rem;">
          <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
            <b>${esc(r.name)}</b> ${status}
            <span style="flex:1;"></span> ${btns}
          </div>
          ${nudge}${plan}
          ${addr ? `<div style="font-size:0.7rem; opacity:0.85; margin-top:2px;">📍 ${esc(this._copy('pickup_label') || 'Pickup')}: ${esc(addr)}</div>` : ''}
          ${r.note ? `<div style="font-size:0.7rem; opacity:0.75; margin-top:2px;">${esc(r.note)}</div>` : ''}
          ${this.optionsFor === r.id && !driver ? this._optionPicker(r) : ''}
          <div style="display:flex; gap:6px; flex-wrap:wrap; align-items:center; margin-top:3px; font-size:0.66rem; opacity:0.9;">
            <span style="opacity:0.7;">${esc(this._copy('asked_by', { name: r.requestedBy.name }) || `Asked by ${r.requestedBy.name}`)}</span>
            ${!mineReq ? smsBtn(r.requestedBy.phone, r.requestedBy.name) : ''}
            ${driver && !iDrive ? smsBtn(driver.phone, driver.name) : ''}
          </div>
        </div>`;
    }).join('');

    const form = (k) => `
      <div data-gc-cp-form="${k.personId}" style="display:grid; grid-template-columns:repeat(auto-fit, minmax(120px, 1fr)); gap:4px; margin-top:6px;">
        ${!this._fmtAddress(k) ? `<div style="grid-column:1/-1; font-size:0.68rem; color:#f59e0b;">${esc(this._copy('no_address') || 'No address on file — type the pickup address.')}</div>` : ''}
        ${[['address1', k.address1], ['address2', k.address2], ['city', k.city], ['state', k.state], ['zip', k.zip]].map(([f, v]) =>
          `<input data-f="${f}" value="${esc(v || '')}" placeholder="${f[0].toUpperCase() + f.slice(1)}" style="font-size:0.72rem; padding:5px 6px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); min-width:0;">`).join('')}
        <input data-f="note" placeholder="${esc(this._copy('note_ph') || 'Anything the driver should know')}" style="grid-column:1/-1; font-size:0.72rem; padding:5px 6px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); min-width:0;">
        <button class="btn btn-primary" data-gc-cp="save" data-cp-person="${k.personId}" ${this.busy ? 'disabled' : ''} style="padding:4px 8px; font-size:0.7rem;">${esc(this._copy('save') || 'Post request')}</button>
      </div>`;

    const askBtns = (cp.riders || []).filter(k => !k.open).map(k => `
      <div style="margin-top:6px;">
        <button class="btn btn-secondary" data-gc-cp="form" data-cp-person="${k.personId}" style="padding:3px 10px; font-size:0.7rem;">
          ${this.formFor === Number(k.personId) ? '✕ ' : ''}${esc(this._copy('request_for', { name: k.name }) || `🚗 Request a ride for ${k.name}`)}
        </button>
        ${this.formFor === Number(k.personId) ? form(k) : ''}
      </div>`).join('');

    return `
      <div style="margin-top:10px; border:1px solid var(--border-color); border-radius:12px; padding:10px 12px;">
        <div style="font-size:0.72rem; font-weight:700; opacity:0.8; margin-bottom:4px;">${esc(this._copy('title') || '🚗 Carpool')}</div>
        <div style="font-size:0.7rem; opacity:0.75; line-height:1.4; margin-bottom:4px;">${esc(this._copy('hint') || '')}</div>
        ${rows || `<div style="font-size:0.72rem; opacity:0.75;">${esc(this._copy('empty') || 'No ride requests for this game yet.')}</div>`}
        ${askBtns}
      </div>`;
  }

  async click(btn, rootEl) {
    const action = btn.dataset.gcCp;
    if (action === 'form') {
      const pid = Number(btn.dataset.cpPerson);
      this.formFor = this.formFor === pid ? null : pid;
      this.host.rerender();
      return;
    }
    if (action === 'options') {
      const id = Number(btn.dataset.cpId);
      if (this.optionsFor === id) { this.optionsFor = null; this.host.rerender(); return; }
      this.optionsFor = id;
      this.options = null;
      this.host.rerender();
      try {
        const res = await this.auth.fetch(`/api/carpool/requests/${id}/options`);
        const data = await res.json().catch(() => ({}));
        this.options = res.ok && data.success ? data : { options: [], missing: 'error' };
      } catch (err) {
        this.options = { options: [], missing: 'error' };
      }
      this.host.rerender();
      return;
    }
    if (this.busy) return;
    this.busy = true;
    this.host.rerender();
    try {
      let res;
      if (action === 'save') {
        const pid = Number(btn.dataset.cpPerson);
        const form = rootEl.querySelector(`[data-gc-cp-form="${pid}"]`);
        const val = (f) => { const el = form && form.querySelector(`[data-f="${f}"]`); return el ? el.value.trim() : ''; };
        res = await this.auth.fetch(`/api/carpool/${this.host.fhEventId()}/requests`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ person_id: pid, address1: val('address1'), address2: val('address2'),
                                 city: val('city'), state: val('state'), zip: val('zip'), note: val('note') }),
        });
        if (res.ok) this.formFor = null;
      } else if (action === 'accept-with') {
        const id = Number(btn.dataset.cpId);
        const payload = btn.dataset.kind
          ? { meet_kind: btn.dataset.kind, ...(btn.dataset.spot ? { meet_spot_id: Number(btn.dataset.spot) } : {}) }
          : {};
        res = await this.auth.fetch(`/api/carpool/requests/${id}/accept`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        });
        if (res.ok) { this.optionsFor = null; this.options = null; }
      } else {
        res = await this.auth.fetch(`/api/carpool/requests/${Number(btn.dataset.cpId)}/${action}`, { method: 'POST' });
      }
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
      await this.load();
    } catch (err) {
      this.host.toast(`⚠ ${err.message}`);
    } finally {
      this.busy = false;
      this.host.rerender();
    }
  }
}
window.CarpoolPanel = CarpoolPanel;
