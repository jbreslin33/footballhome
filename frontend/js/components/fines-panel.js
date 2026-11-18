// FinesPanel — ⚖️ your fines by month and the rules in force for your section
// (mig 460/461), with "I was there — dispute" on a said-yes / marked-absent
// fine (mig 691).  Moved out of MyScreen into Event Center's 👤 Mine
// (docs/event-center-design.md, slice 3) — same look, same words
// (message_templates my_fines).  Owner 2026-09-27: "list on their my page the
// fines in table list at top ... list the fine rules too".
//
// GET /api/my/fines → { fines: {since, months:[{label, from, to, total,
// items}]} | null, rules }.  Null fines = no rates for the section (parents,
// the women): the panel stays hidden.
//
//   new FinesPanel(host, { fetchJson, escapeHtml, auth }).load();
class FinesPanel {
  constructor(host, ctx) {
    this.host = host;
    this.ctx = ctx;
    this.fines = null;
    this.rules = [];
    this.disputeOpen = null;
    host.addEventListener('click', (e) => {
      const open = e.target.closest('[data-fine-dispute]');
      if (open) { this.disputeOpen = Number(open.dataset.fineDispute); this.render(); return; }
      const send = e.target.closest('[data-fine-dispute-send]');
      if (send) {
        const note = send.parentElement.querySelector('[data-fine-dispute-note]');
        this.sendDispute(Number(send.dataset.fineDisputeSend), note ? note.value.trim() : '');
      }
    });
  }

  esc(t) { return this.ctx.escapeHtml(t == null ? '' : String(t)); }
  t(tier, tokens) { return (window.MessageCopy && MessageCopy.block('my_fines', tier, tokens)) || ''; }

  async load() {
    try {
      const body = await this.ctx.fetchJson('/api/my/fines');
      this.fines = body && body.fines ? body.fines : null;
      this.rules = body && Array.isArray(body.rules) ? body.rules : [];
    } catch (_) { this.fines = null; }
    if (window.MessageCopy) await MessageCopy.load(this.ctx.auth).catch(() => {});
    this.render();
  }

  render() {
    const host = this.host;
    const f = this.fines;
    if (!f || !Array.isArray(f.months) || !(window.MessageCopy && MessageCopy.has('my_fines', 'heading'))) {
      host.hidden = true; host.innerHTML = '';
      if (this.ctx.onSummary) this.ctx.onSummary(null);
      return;
    }
    const money = (n) => { const v = Number(n) || 0; return Number.isInteger(v) ? `$${v}` : `$${v.toFixed(2)}`; };
    const kindLabel = (k) => ({ match: 'Game', intrasquad: 'Intra Squad', practice: 'Practice' }[k] || k || '');
    // A period's dates, first Friday → day before the next (mig 1207).
    const periodDay = (iso) => { const d = iso ? new Date(`${iso}T12:00:00`) : null; return d && !isNaN(d) ? `${d.getMonth() + 1}/${d.getDate()}` : ''; };
    const cell = 'padding:3px 6px; border-bottom:1px solid rgba(255,255,255,0.08); vertical-align:top;';

    const rules = this.rules.length ? `
      <div style="font-size:0.62rem; font-weight:800; letter-spacing:0.04em; text-transform:uppercase; opacity:0.7; margin:6px 0 2px;">${this.esc(this.t('rules_heading'))}</div>
      <table style="width:100%; border-collapse:collapse; font-size:0.74rem;">
        ${this.rules.map(r => `<tr><td style="${cell}">${this.esc(r.label)}</td><td style="${cell} text-align:right; font-weight:800; white-space:nowrap;">${money(r.amount)}</td></tr>`).join('')}
      </table>` : '';

    const sinceDate = f.since ? new Date(`${f.since}T12:00:00`) : null;
    const sinceText = sinceDate && !isNaN(sinceDate)
      ? this.t('since', { since: sinceDate.toLocaleDateString('en-US', { month: 'long', day: 'numeric' }) }) : '';
    const months = f.months.filter(mo => Array.isArray(mo.items) && mo.items.length);
    const total = months.reduce((s, mo) => s + (Number(mo.total) || 0), 0);
    const rows = months.length ? `
      <table style="width:100%; border-collapse:collapse; font-size:0.74rem; margin-top:6px;">
        ${months.map(mo => `
          ${mo.items.map(it => {
            const d = new Date(it.startAt);
            const when = isNaN(d) ? '' : d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
            return `<tr>
              <td style="${cell} white-space:nowrap; opacity:0.8;">${this.esc(when)}</td>
              <td style="${cell}">${this.esc(kindLabel(it.eventKind))}${it.opponent ? ` vs ${this.esc(it.opponent)}` : ''}<div style="opacity:0.7;">${this.esc(it.label)}</div>${this.disputeHtml(it)}</td>
              <td style="${cell} text-align:right; font-weight:800; white-space:nowrap;">${money(it.amount)}</td>
            </tr>`;
          }).join('')}
          <tr><td colspan="3" style="padding:3px 6px 8px; text-align:right; font-weight:800; font-size:0.72rem;">${this.esc(this.t('month_total', { month: mo.label, from: periodDay(mo.from), to: periodDay(mo.to), amount: money(mo.total) }))}</td></tr>`).join('')}
      </table>` : `<div style="font-size:0.74rem; opacity:0.75; margin-top:6px;">${this.esc(this.t('empty'))}</div>`;

    if (this.ctx.onSummary) this.ctx.onSummary({ total, amount: money(total) });
    host.hidden = false;
    host.innerHTML = `
      <div style="padding:8px 10px; border-radius:8px; border:1px solid ${total > 0 ? '#ef4444' : 'rgba(255,255,255,0.16)'}; background:${total > 0 ? 'rgba(239,68,68,0.10)' : 'rgba(15,23,42,0.5)'};">
        <div style="display:flex; justify-content:space-between; align-items:baseline; gap:8px;">
          <h2 style="margin:0; font-size:0.8rem;">⚖️ ${this.esc(this.t('heading'))}</h2>
          <span style="font-size:0.9rem; font-weight:800; color:${total > 0 ? '#fca5a5' : 'inherit'};">${money(total)}</span>
        </div>
        <div style="font-size:0.66rem; opacity:0.7; margin-top:2px; line-height:1.3;">${this.esc(this.t('note'))}${sinceText ? ` ${this.esc(sinceText)}` : ''}</div>
        ${this.disputeError ? `<div style="font-size:0.72rem; color:#f87171; margin-top:4px;">${this.esc(this.disputeError)}</div>` : ''}
        ${rules}
        ${rows}
      </div>`;
  }

  // "I was there — dispute" (mig 691; no-RSVP fines are not disputable).
  // Pending / denied show as a status line; an approved one is gone.
  disputeHtml(it) {
    if (!it || !it.disputable) return '';
    if (it.dispute) {
      const color = it.dispute === 'denied' ? '#fca5a5' : it.dispute === 'approved' ? '#86efac' : '#fcd34d';
      return `<div style="margin-top:3px; font-size:0.68rem; font-weight:800; color:${color};">${this.esc(this.t('dispute_' + it.dispute))}</div>`;
    }
    if (this.disputeOpen === it.fhEventId) {
      return `<div style="margin-top:4px; display:flex; flex-direction:column; gap:4px;">
          <textarea data-fine-dispute-note rows="2" maxlength="500" placeholder="${this.esc(this.t('dispute_note'))}"
            style="width:100%; box-sizing:border-box; font:inherit; font-size:0.72rem; padding:4px 6px; border-radius:6px; border:1px solid rgba(255,255,255,0.2); background:rgba(15,23,42,0.6); color:inherit;"></textarea>
          <button type="button" data-fine-dispute-send="${it.fhEventId}"
            style="align-self:flex-start; min-width:0; min-height:0; padding:4px 10px; border-radius:6px; border:none; cursor:pointer; font-size:0.7rem; font-weight:800; color:#fff; background:#0284c7;">${this.esc(this.t('dispute_send'))}</button>
        </div>`;
    }
    return `<button type="button" data-fine-dispute="${it.fhEventId}"
        style="margin-top:4px; min-width:0; min-height:0; padding:3px 9px; border-radius:999px; cursor:pointer; font-size:0.66rem; font-weight:800;
               border:1px solid #f59e0b; background:rgba(245,158,11,0.15); color:#fcd34d;">${this.esc(this.t('dispute_button'))}</button>`;
  }

  async sendDispute(fhEventId, note) {
    try {
      const body = await this.ctx.fetchJson('/api/my/fines/dispute', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ fh_event_id: fhEventId, note: note || '' }) });
      for (const mo of (this.fines && this.fines.months) || [])
        for (const it of mo.items || []) if (it.fhEventId === fhEventId) it.dispute = (body && body.status) || 'pending';
      this.disputeOpen = null;
      this.disputeError = '';
    } catch (err) {
      this.disputeError = err.message || 'Could not send the dispute';
    }
    this.render();
  }
}

window.FinesPanel = FinesPanel;
