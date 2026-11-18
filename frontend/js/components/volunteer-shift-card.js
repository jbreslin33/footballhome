// VolunteerShiftCard — 🙋 a player behind on dues coaches the kids instead
// (migrations 1222 → 1461).
//
// Owner 2026-11-18 (mig 1461): "i like your idea of slots" → weekday youth
// practice SLOTS off the calendar, at least 2 hours a week (the policy row),
// "whole day" = every slot that day; "monthly waiver" — every week met →
// that month's dues waived; one told-ahead miss a month is OK, a no-show or
// a second miss bills the month.
//
// GET /api/my/volunteer → { offer, policy:{min, min_minutes, dues}, slots:[…],
//                           pick:{status, slots, total, label, ledger?} | null }
//   offer, no pick → the deal, the commitment tick, slots by day (tap one,
//                    or Whole day), running total, Send
//   pick pending   → what he picked, the club will confirm, Cancel my pick
//   pick approved  → his slots + this month / last month, week by week
// The owner approves / ends on #payments.  Every word is message_templates
// kind volunteer_shift.
//
//   VolunteerShiftCard.mount(host, fetchJson, { folded })
//   folded (mig 1460): the offer stays hidden until 'fh:volunteer-toggle'
//   (the dues notice's 🙋 Volunteer button) — a pick always shows.
//   VolunteerShiftCard.monthHtml(month, esc)  one month's line + weeks (#payments too)
(function () {
  const esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const t = (tier, tokens) => (window.MessageCopy && MessageCopy.block('volunteer_shift', tier, tokens)) || '';
  const fmtMin = (m) => m < 60 ? `${m} min` : (m % 60 ? `${Math.floor(m / 60)}h ${m % 60}m` : `${m / 60} ${m === 60 ? 'hour' : 'hours'}`);
  const key = (s) => `${s.isodow}|${s.starts_at}`;

  class VolunteerShiftCard {
    constructor(host, fetchJson, opts = {}) {
      this.host = host;
      this.fetchJson = fetchJson;
      this.folded = !!opts.folded;
      this.open = false;
      this.data = null;
      this.agreed = false;
      this.chosen = new Set();
      this.busy = false;
      this.error = '';
      this._onToggle = () => {
        if (!this.host.isConnected) { window.removeEventListener('fh:volunteer-toggle', this._onToggle); return; }
        this.open = !this.open; this.render();
        if (this.open) this.host.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
      };
      if (this.folded) window.addEventListener('fh:volunteer-toggle', this._onToggle);
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
      try { this.data = await this.fetchJson('/api/my/volunteer', options); this.chosen.clear(); }
      catch (err) { this.error = err.message || 'Could not save'; }
      this.busy = false; this.render();
    }

    _slots() { return (this.data && Array.isArray(this.data.slots)) ? this.data.slots : []; }
    _total() { return this._slots().filter(s => this.chosen.has(key(s))).reduce((n, s) => n + Number(s.minutes || 0), 0); }

    _onClick(e) {
      if (this.busy) return;
      const slot = e.target.closest('[data-vol-slot]');
      if (slot) {
        const k = slot.getAttribute('data-vol-slot');
        if (this.chosen.has(k)) this.chosen.delete(k); else this.chosen.add(k);
        this.error = ''; this.render(); return;
      }
      const day = e.target.closest('[data-vol-day]');
      if (day) {
        const dow = Number(day.getAttribute('data-vol-day'));
        const all = this._slots().filter(s => Number(s.isodow) === dow).map(key);
        const on = all.every(k => this.chosen.has(k));
        all.forEach(k => on ? this.chosen.delete(k) : this.chosen.add(k));
        this.error = ''; this.render(); return;
      }
      if (e.target.closest('[data-vol-send]')) {
        const min = Number(this.data.policy && this.data.policy.min_minutes) || 120;
        if (!this.agreed) { this.error = t('agree_first') || 'Tick the box above first.'; this.render(); return; }
        if (this._total() < min) { this.error = t('total_short', { min: this.data.policy.min }) || 'Pick more slots.'; this.render(); return; }
        const slots = this._slots().filter(s => this.chosen.has(key(s))).map(s => ({ isodow: Number(s.isodow), starts_at: s.starts_at }));
        this._send({ method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ slots, agreed: true }) });
        return;
      }
      if (e.target.closest('[data-vol-withdraw]')) this._send({ method: 'DELETE' });
    }

    // One month: the headline, then each week (used on #payments too).
    static monthHtml(m, escFn) {
      const e = escFn || esc;
      if (!m) return '';
      const why = m.why === 'noshow' ? t('why_noshow') : m.why === 'misses' ? t('why_misses', { n: m.misses }) : '';
      const head = m.status === 'waived' ? t('month_waived', { month: m.name })
        : m.status === 'billed' ? t('month_billed', { month: m.name, dues: m.dues, why })
        : m.status === 'pending' ? t('month_pending', { month: m.name })
        : m.status === 'open' ? t('month_open', { month: m.name }) : '';
      const color = m.status === 'waived' ? '#86efac' : m.status === 'billed' ? '#fca5a5' : '#fde68a';
      const tier = { met: 'week_met', told: 'week_told', noshow: 'week_noshow', short: 'week_short',
                     unmarked: 'week_unmarked', coming: 'week_coming', off: 'week_off' };
      const weeks = (m.weeks || []).map(w => `<div style="font-size:0.76rem;">${e(t(tier[w.status] || 'week_coming', w))}</div>`).join('');
      return `${head ? `<div style="font-weight:800; color:${color};">${e(head)}</div>` : ''}${weeks}`;
    }

    render() {
      const d = this.data;
      const box = (inner) => `<div style="margin:0 0 6px; padding:10px 12px; border-radius:8px; border:1px solid #2563eb;
          background:rgba(37,99,235,0.14); color:#bfdbfe; font-size:0.8rem; line-height:1.4;">${inner}</div>`;
      const err = this.error ? `<div style="color:#fca5a5; font-weight:700; margin-top:6px;">${esc(this.error)}</div>` : '';
      if (!d || (!d.offer && !d.pick)) { this.host.innerHTML = ''; return; }
      const pol = d.policy || {};

      if (d.pick) {
        const approved = d.pick.status === 'approved';
        const tokens = { shift: d.pick.label || d.pick.shift || '', total: d.pick.total || '', min: pol.min || '' };
        const ledger = approved && Array.isArray(d.pick.ledger) ? d.pick.ledger : [];
        this.host.innerHTML = box(`
          <div style="font-weight:800;">🙋 ${esc(t(approved ? 'approved' : 'pending', tokens))}</div>
          ${ledger.length ? `<div style="margin-top:8px; display:flex; flex-direction:column; gap:2px;">
              ${VolunteerShiftCard.monthHtml(ledger[0])}
              ${ledger[1] ? `<div style="margin-top:6px; opacity:0.85;">${VolunteerShiftCard.monthHtml(ledger[1])}</div>` : ''}
            </div>` : ''}
          ${approved ? `<div style="margin-top:8px; font-size:0.74rem; opacity:0.9;">${esc(t('terms'))}</div>` : `<button type="button" data-vol-withdraw ${this.busy ? 'disabled' : ''}
              style="margin-top:8px; font-size:0.72rem; font-weight:700; color:#bfdbfe; background:transparent;
                     border:1px solid rgba(191,219,254,0.5); padding:4px 10px; border-radius:999px; cursor:pointer;">${esc(t('withdraw'))}</button>`}
          ${err}`);
        return;
      }

      if (this.folded && !this.open) { this.host.innerHTML = ''; return; }
      const slots = this._slots();
      const min = Number(pol.min_minutes) || 120;
      const total = this._total();
      const days = [...new Set(slots.map(s => Number(s.isodow)))];
      const dayBlock = (dow) => {
        const own = slots.filter(s => Number(s.isodow) === dow);
        const allOn = own.every(s => this.chosen.has(key(s)));
        const slotBtn = (s) => {
          const on = this.chosen.has(key(s));
          const time = String(s.label || '').replace(/^\S+\s/, '');   // "Mon 4:45–5:45 PM" → "4:45–5:45 PM"
          return `<button type="button" data-vol-slot="${esc(key(s))}" ${this.busy ? 'disabled' : ''}
              style="flex:1 1 45%; min-width:130px; padding:6px 8px; border-radius:8px; cursor:pointer; text-align:left; line-height:1.25;
                     border:1px solid #3b82f6; background:${on ? '#2563eb' : 'transparent'}; color:${on ? '#fff' : '#bfdbfe'};">
              <span style="font-weight:800;">${on ? '✓ ' : ''}${esc(time)}</span>
              <span style="display:block; font-size:0.7rem; opacity:0.85;">${esc(s.teams)} · ${esc(fmtMin(Number(s.minutes)))}</span>
            </button>`;
        };
        return `<div style="margin-top:8px;">
            <div style="display:flex; align-items:center; gap:8px; margin-bottom:4px;">
              <span style="font-weight:800; color:#fff;">${esc(own[0].day)}</span>
              <button type="button" data-vol-day="${dow}" ${this.busy ? 'disabled' : ''}
                  style="font-size:0.7rem; font-weight:700; padding:2px 10px; border-radius:999px; cursor:pointer;
                         border:1px solid #93c5fd; background:${allOn ? '#93c5fd' : 'transparent'}; color:${allOn ? '#1e3a8a' : '#93c5fd'};">${esc(t('whole_day') || 'Whole day')}</button>
            </div>
            <div style="display:flex; gap:6px; flex-wrap:wrap;">${own.map(slotBtn).join('')}</div>
          </div>`;
      };
      const enough = total >= min;
      const ready = enough && this.agreed;
      this.host.innerHTML = box(`
        <div style="font-weight:800; font-size:0.9rem;">${esc(t('heading'))}</div>
        <div style="margin-top:4px;">${esc(t('intro', { min: pol.min || '', dues: pol.dues || '' }))}</div>
        <div style="margin-top:6px; font-weight:700; color:#fde68a;">${esc(t('terms'))}</div>
        <label style="display:flex; gap:8px; align-items:flex-start; margin-top:8px; cursor:pointer; font-weight:700;">
          <input type="checkbox" data-vol-agree ${this.agreed ? 'checked' : ''} style="margin-top:2px; width:18px; height:18px; flex:none;">
          <span>${esc(t('agree'))}</span>
        </label>
        ${slots.length ? days.map(dayBlock).join('') : `<div style="margin-top:8px; font-weight:700;">${esc(t('no_slots'))}</div>`}
        ${slots.length ? `<div style="position:sticky; bottom:0; margin-top:10px; padding-top:8px; border-top:1px solid rgba(147,197,253,0.3);
                               display:flex; align-items:center; justify-content:space-between; gap:8px; flex-wrap:wrap;">
            <span style="font-weight:800; color:${enough ? '#86efac' : '#fde68a'};">${esc(t('total', { total: fmtMin(total), min: pol.min || fmtMin(min) }))}</span>
            <button type="button" data-vol-send ${this.busy ? 'disabled' : ''}
                style="padding:8px 14px; border-radius:999px; font-weight:800; border:0; cursor:pointer;
                       background:${ready ? '#16a34a' : '#475569'}; color:#fff;">${esc(t('submit'))}</button>
          </div>` : ''}
        ${err}`);
    }

    static mount(host, fetchJson, opts) {
      if (!host) return null;
      const card = new VolunteerShiftCard(host, fetchJson, opts);
      card.load();
      return card;
    }
  }

  window.VolunteerShiftCard = VolunteerShiftCard;
})();
