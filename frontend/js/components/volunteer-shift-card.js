// VolunteerShiftCard — 🙋 #my card: an overdue player helps the club one
// evening a week instead of paying (migration 1222).  Owner 2026-11-10:
// "lets add for men that they can also volunteer if over due … monday wed
// fri … 5pm to 7pm" → "pick one day to help" → "they need to understand
// they have to be on time and show up each week on that day and that if
// they can't make it they must let us know ahead of time" → "after they
// show they are reliable we can start process to actually get them paid".
//
// GET /api/my/volunteer → { offer, shifts: [{id, label}], pick }.
//   offer, no pick  → the commitment, an "I understand" tick, one button
//                     per evening (picking needs the tick)
//   pick pending    → "You picked Wednesday 5–7 PM … the club will confirm"
//                     + Cancel my pick
//   pick approved   → "You're a club volunteer: Wednesday 5–7 PM, every week"
// The owner approves on #payments (VolunteerController), which makes him
// a 🙋 Volunteer.  Every word is message_templates kind volunteer_shift.
//
//   VolunteerShiftCard.mount(host, fetchJson)   fetchJson(url, options) → body
(function () {
  const esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const t = (tier, tokens) => (window.MessageCopy && MessageCopy.block('volunteer_shift', tier, tokens)) || '';

  class VolunteerShiftCard {
    constructor(host, fetchJson) {
      this.host = host;
      this.fetchJson = fetchJson;
      this.data = null;
      this.agreed = false;
      this.busy = false;
      this.error = '';
      host.addEventListener('click', (e) => this._onClick(e));
      host.addEventListener('change', (e) => {
        if (e.target.matches('[data-vol-agree]')) { this.agreed = e.target.checked; this.error = ''; this.render(); }
      });
    }

    async load() {
      try { this.data = await this.fetchJson('/api/my/volunteer'); }
      catch (_) { this.data = null; }
      this.render();
    }

    async _send(options) {
      this.busy = true; this.error = ''; this.render();
      try { this.data = await this.fetchJson('/api/my/volunteer', options); }
      catch (err) { this.error = err.message || 'Could not save'; }
      this.busy = false; this.render();
    }

    _onClick(e) {
      const pick = e.target.closest('[data-vol-shift]');
      if (pick && !this.busy) {
        if (!this.agreed) { this.error = t('agree_first') || 'Tick the box above first.'; this.render(); return; }
        this._send({ method: 'POST', headers: { 'Content-Type': 'application/json' },
                     body: JSON.stringify({ shift_id: Number(pick.dataset.volShift), agreed: true }) });
        return;
      }
      if (e.target.closest('[data-vol-withdraw]') && !this.busy) this._send({ method: 'DELETE' });
    }

    render() {
      const d = this.data;
      const box = (inner) => `<div style="margin:0 0 6px; padding:10px 12px; border-radius:8px; border:1px solid #2563eb;
          background:rgba(37,99,235,0.14); color:#bfdbfe; font-size:0.78rem; line-height:1.4;">${inner}</div>`;
      const err = this.error ? `<div style="color:#fca5a5; font-weight:700; margin-top:6px;">${esc(this.error)}</div>` : '';
      if (!d || (!d.offer && !d.pick)) { this.host.innerHTML = ''; return; }

      if (d.pick) {
        const approved = d.pick.status === 'approved';
        this.host.innerHTML = box(`
          <div style="font-weight:800;">🙋 ${esc(t(approved ? 'approved' : 'pending', { shift: d.pick.shift }))}</div>
          ${approved ? '' : `<button type="button" data-vol-withdraw ${this.busy ? 'disabled' : ''}
              style="margin-top:8px; font-size:0.72rem; font-weight:700; color:#bfdbfe; background:transparent;
                     border:1px solid rgba(191,219,254,0.5); padding:4px 10px; border-radius:999px; cursor:pointer;">${esc(t('withdraw'))}</button>`}
          ${err}`);
        return;
      }

      const shifts = (d.shifts || []).map(s => `<button type="button" data-vol-shift="${Number(s.id)}" ${this.busy ? 'disabled' : ''}
          style="flex:1 1 30%; min-width:120px; padding:8px 10px; border-radius:8px; font-weight:800; font-size:0.78rem; cursor:pointer;
                 border:1px solid #3b82f6; background:${this.agreed ? '#2563eb' : 'transparent'}; color:${this.agreed ? '#fff' : '#93c5fd'};
                 opacity:${this.agreed ? 1 : 0.6};">${esc(s.label)}</button>`).join('');
      this.host.innerHTML = box(`
        <div style="font-weight:800; font-size:0.86rem;">${esc(t('heading'))}</div>
        <div style="margin-top:4px;">${esc(t('intro'))}</div>
        <div style="margin-top:6px; font-weight:700; color:#fde68a;">${esc(t('terms'))}</div>
        <label style="display:flex; gap:8px; align-items:flex-start; margin-top:8px; cursor:pointer; font-weight:700;">
          <input type="checkbox" data-vol-agree ${this.agreed ? 'checked' : ''} style="margin-top:2px; width:18px; height:18px; flex:none;">
          <span>${esc(t('agree'))}</span>
        </label>
        <div style="display:flex; gap:6px; flex-wrap:wrap; margin-top:8px;">${shifts}</div>
        ${err}`);
    }

    static mount(host, fetchJson) {
      if (!host) return null;
      const card = new VolunteerShiftCard(host, fetchJson);
      card.load();
      return card;
    }
  }

  window.VolunteerShiftCard = VolunteerShiftCard;
})();
