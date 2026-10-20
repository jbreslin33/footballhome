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
    if (kind === 'midpoint') {
      // The computed neutral point; its address follows pickup-address
      // privacy, so a viewer who may not see it gets the line without one.
      if (!tokens.spot) return `Meeting halfway — driver leaves by ${tokens.leave}.`;
      return this._copy('opt_midpoint', tokens) || `Meet in the middle at ${tokens.spot} by ${tokens.pickup} — driver leaves by ${tokens.leave}.`;
    }
    return this._copy('opt_spot', tokens) || `Meet at ${tokens.spot} by ${tokens.pickup} — driver leaves by ${tokens.leave}.`;
  }

  // The rider's multi-select, as the driver reads it on an open request.
  _willingLabels(w) {
    if (!w) return [];
    const L = [];
    if (w.riderHome)  L.push(this._copy('will_rider_home')  || 'Pick me up at my address');
    if (w.driverHome) L.push(this._copy('will_driver_home') || "I can get to the driver's place");
    if (w.spot)       L.push(this._copy('will_spot')        || 'Meet at a club spot (like Lighthouse Field)');
    if (w.midpoint)   L.push(this._copy('will_midpoint')    || "Meet somewhere in the middle — we'll suggest the address");
    return L;
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
      // What the rider said works for them (mig 610) — a would-be driver
      // reads this before opening the picker.
      const willList = this._willingLabels(r.willing);
      const willing = !driver && willList.length
        ? `<div style="font-size:0.68rem; opacity:0.8; margin-top:2px;">${esc(this._copy('willing_line', { name: r.name, list: willList.join(' · ') }) || `${r.name} is OK with: ${willList.join(' · ')}.`)}</div>` : '';
      // The agreed plan, once a driver picked one.
      const plan = driver && r.meetPlan && r.meetPlan.kind
        ? `<div style="font-size:0.7rem; color:#22c55e; margin-top:2px;">🗺 ${esc(this._planLine(r.meetPlan.kind, { rider: r.name, leave: r.meetPlan.leaveAt || '', pickup: r.meetPlan.pickupAt || '', minutes: r.meetPlan.extraMinutes ?? '', spot: r.meetPlan.spot || '' }))}</div>` : '';
      return `
        <div style="padding:7px 0; border-top:1px solid var(--border-color); font-size:0.76rem;">
          <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
            <b>${esc(r.name)}</b> ${status}
            <span style="flex:1;"></span> ${btns}
          </div>
          ${nudge}${willing}${plan}
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

    // The rider's multi-select (mig 610; owner: "have option to set what i
    // am willing to do") — the driver later single-selects ONE of these.
    const willBoxes = `
      <div style="grid-column:1/-1; font-size:0.68rem; margin-top:2px;">
        <div style="font-weight:700; margin-bottom:3px;">${esc(this._copy('will_title') || "What works for you? Pick everything you'd be OK with — the driver chooses one.")}</div>
        ${[['rider_home', true,  this._copy('will_rider_home')  || 'Pick me up at my address'],
           ['driver_home', false, this._copy('will_driver_home') || "I can get to the driver's place"],
           ['spot', false,        this._copy('will_spot')        || 'Meet at a club spot (like Lighthouse Field)'],
           ['midpoint', false,    this._copy('will_midpoint')    || "Meet somewhere in the middle — we'll suggest the address"]]
          .map(([key, on, label]) => `
            <label style="display:flex; gap:6px; align-items:center; padding:2px 0; cursor:pointer;">
              <input type="checkbox" data-w="${key}" ${on ? 'checked' : ''}> ${esc(label)}
            </label>`).join('')}
      </div>`;

    const form = (k) => `
      <div data-gc-cp-form="${k.personId}" style="display:grid; grid-template-columns:repeat(auto-fit, minmax(120px, 1fr)); gap:4px; margin-top:6px;">
        ${!this._fmtAddress(k) ? `<div style="grid-column:1/-1; font-size:0.68rem; color:#f59e0b;">${esc(this._copy('no_address') || 'No address on file — type the pickup address.')}</div>` : ''}
        ${[['address1', k.address1], ['address2', k.address2], ['city', k.city], ['state', k.state], ['zip', k.zip]].map(([f, v]) =>
          `<input data-f="${f}" value="${esc(v || '')}" placeholder="${f[0].toUpperCase() + f.slice(1)}" style="font-size:0.72rem; padding:5px 6px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); min-width:0;">`).join('')}
        ${willBoxes}
        <input data-f="note" placeholder="${esc(this._copy('note_ph') || 'Anything the driver should know')}" style="grid-column:1/-1; font-size:0.72rem; padding:5px 6px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); min-width:0;">
        <button class="btn btn-primary" data-gc-cp="save" data-cp-person="${k.personId}" ${this.busy ? 'disabled' : ''} style="padding:4px 8px; font-size:0.7rem;">${esc(this._copy('save') || 'Post request')}</button>
      </div>`;

    // Personalized (owner: "why am i seeing ride request for everyone lol"):
    // a button only for yourself and your own kids. Staff keep the
    // post-on-behalf power, tucked into one dropdown instead of a wall of
    // buttons.
    const available = (cp.riders || []).filter(k => !k.open);
    const mine   = available.filter(k => k.mine !== false);   // older backend: treat all as mine
    const others = available.filter(k => k.mine === false);
    const askBtn = (k) => {
      const self = Number(k.personId) === me;
      const label = self
        ? (this._copy('request_mine') || '🚗 Request a ride')
        : (this._copy('request_kid', { name: k.name }) || `🚗 Request a ride for ${k.name}`);
      return `
        <div style="margin-top:6px;">
          <button class="btn btn-secondary" data-gc-cp="form" data-cp-person="${k.personId}" style="padding:3px 10px; font-size:0.7rem;">
            ${this.formFor === Number(k.personId) ? '✕ ' : ''}${esc(label)}
          </button>
          ${this.formFor === Number(k.personId) ? form(k) : ''}
        </div>`;
    };
    const behalfPicked = others.find(k => this.formFor === Number(k.personId));
    const behalf = others.length ? `
      <div style="margin-top:8px;">
        <select data-gc-cp-behalf style="font-size:0.7rem; padding:4px 6px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); max-width:100%;">
          <option value="">${esc(this._copy('staff_pick') || "Request on someone's behalf…")}</option>
          ${others.map(k => `<option value="${k.personId}" ${this.formFor === Number(k.personId) ? 'selected' : ''}>${esc(k.name)}</option>`).join('')}
        </select>
        ${behalfPicked ? form(behalfPicked) : ''}
      </div>` : '';
    const askBtns = mine.map(askBtn).join('') + behalf;

    return `
      <div style="margin-top:10px; border:1px solid var(--border-color); border-radius:12px; padding:10px 12px;">
        <div style="font-size:0.72rem; font-weight:700; opacity:0.8; margin-bottom:4px;">${esc(this._copy('title') || '🚗 Carpool')}</div>
        <div style="font-size:0.7rem; opacity:0.75; line-height:1.4; margin-bottom:4px;">${esc(this._copy('hint') || '')}</div>
        ${rows || `<div style="font-size:0.72rem; opacity:0.75;">${esc(this._copy('empty') || 'No ride requests for this game yet.')}</div>`}
        ${askBtns}
      </div>`;
  }

  // The staff behalf-of dropdown ([data-gc-cp-behalf]) — hosts route its
  // change event here; picking a name opens that person's request form.
  behalf(value) {
    this.formFor = value ? Number(value) : null;
    this.host.rerender();
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
        const will = (k) => { const el = form && form.querySelector(`[data-w="${k}"]`); return el ? el.checked : false; };
        res = await this.auth.fetch(`/api/carpool/${this.host.fhEventId()}/requests`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ person_id: pid, address1: val('address1'), address2: val('address2'),
                                 city: val('city'), state: val('state'), zip: val('zip'), note: val('note'),
                                 willing_rider_home: will('rider_home'), willing_driver_home: will('driver_home'),
                                 willing_spot: will('spot'), willing_midpoint: will('midpoint') }),
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
