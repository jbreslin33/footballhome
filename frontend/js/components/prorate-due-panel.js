// ProrateDuePanel — 💵 new members billed only the $1 card fee, in the 🚦
// band's popup (mig 1603).  Owner 2026-11-20: "todo at top for new players
// tuition … find new players who we did not prorate yet" + "it should calc
// pro rate like on tution page and bascially tell me how much and button
// take me to la like on tution to inovice them".
//
// The band shows a red "💵 Prorate — N new to bill: …  Bill ›" box while
// anyone is owed (club/super admins, never while viewing as).  The popup:
//
//   [✓ Done all (13)]
//   Noah Randley   Boys · registered Nov 16     [🔗 Open in LA] [✓ Done]
//   Prorate $22.75 — 18 of 28 days, $1 paid
//
// The amount is BillingBadge.projectedProrate — the Tuition page's Prorate
// cell; past their first cycle it is the full month less what was paid.
// Billing anything past $1 in LA takes them off at the next sync.
//
//   const p = new ProrateDuePanel(el, { fetchJson, escapeHtml, auth, onChange(list) });
//   p.load();   p.render();
class ProrateDuePanel {
  constructor(el, ctx) {
    this.el = el;
    this.ctx = ctx;
    this.due = [];
    this.busy = false;
    this.err = '';
    if (el) el.addEventListener('click', (e) => {
      const done = e.target.closest('[data-pd-done]');
      if (done) { this.done([Number(done.getAttribute('data-pd-done'))]); return; }
      if (e.target.closest('[data-pd-done-all]')) { this.done(this.due.map(p => Number(p.person_id))); return; }
      const la = e.target.closest('[data-pd-la]');
      if (la) {
        const uid = la.getAttribute('data-pd-la');
        const url = ProrateDuePanel.cp('prorate_la_url', { uid }, `https://manager.leagueapps.com/console/sites/41983/memberDetails?memberId=${uid}`);
        window.open(url, '_blank', 'noopener');
      }
    });
  }

  static cp(tier, tokens, fb) {
    return (window.MessageCopy && MessageCopy.has && MessageCopy.has('event_center', tier))
      ? MessageCopy.block('event_center', tier, tokens) : fb;
  }

  static wanted(auth) {
    const role = auth && auth.user && auth.user.role;
    return !!auth && !auth.viewAsPersonId && ['club', 'super'].includes(role);
  }

  async load() {
    if (!ProrateDuePanel.wanted(this.ctx.auth)) { this.set([]); return; }
    try { this.set((await this.ctx.fetchJson('/api/prorates/due')).due || []); }
    catch (_) { /* the band just shows no box */ }
  }

  set(list) {
    this.due = Array.isArray(list) ? list : [];
    this.render();
    if (this.ctx.onChange) this.ctx.onChange(this.due);
  }

  async done(ids) {
    if (this.busy || !ids.length) return;
    this.busy = true; this.err = ''; this.render();
    try {
      await this.ctx.fetchJson('/api/prorates/dismiss', { method: 'POST', body: JSON.stringify({ person_ids: ids }) });
      const gone = new Set(ids);
      this.busy = false;
      this.set(this.due.filter(p => !gone.has(Number(p.person_id))));
    } catch (e) {
      this.busy = false; this.err = e.message || 'Could not mark done'; this.render();
    }
  }

  static nameOf(p) { return `${p.first_name || ''} ${p.last_name || ''}`.trim(); }

  // The Tuition page's math: projectedProrate with what LA says was paid
  // (the $1 fee) counted toward it; null there = first cycle over → full month.
  static amountLine(p) {
    const cp = ProrateDuePanel.cp;
    const money = (n) => `$${(Number(n) || 0).toFixed(2).replace(/\.00$/, '')}`;
    const paid = Number(p.paid_usd) || 0;
    const BB = window.BillingBadge;
    const pr = BB && BB.projectedProrate && p.registered_at
      ? BB.projectedProrate({ laRegisteredAt: p.registered_at, paymentsWindow: paid > 0 ? [{ paidAt: p.registered_at, amount: paid }] : [] })
      : null;
    if (pr && pr.amount > 0)
      return cp('prorate_amount', { amount: money(pr.amount), days: pr.daysRemain, cycle: pr.cycleDays, paid: money(paid) },
                `Prorate ${money(pr.amount)} — ${pr.daysRemain} of ${pr.cycleDays} days, ${money(paid)} paid`);
    const monthly = window.MessageCopy && MessageCopy.duesPolicy && MessageCopy.duesPolicy.monthlyDuesUsd;
    if (!Number.isFinite(monthly)) return '';
    return cp('prorate_full', { amount: money(Math.max(0, monthly - paid)) }, `Full month ${money(Math.max(0, monthly - paid))} — first cycle already over`);
  }

  render() {
    if (!this.el) return;
    const esc = this.ctx.escapeHtml;
    const cp = ProrateDuePanel.cp;
    if (!this.due.length) {
      this.el.innerHTML = `<p style="margin:4px 0; color:#94a3b8;">${esc(cp('prorate_empty', {}, 'Every new member has been billed. ✓'))}</p>`;
      return;
    }
    const SECTION = { mens: "Men's", womens: "Women's", boys: 'Boys', girls: 'Girls' };
    const day = (iso) => {
      const d = new Date(iso);
      return isNaN(d) ? '' : d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    };
    const rows = this.due.map(p => {
      const bits = [SECTION[p.section] || '', p.registered_at ? cp('prorate_reg_on', { date: day(p.registered_at) }, `registered ${day(p.registered_at)}`) : '']
        .filter(Boolean).join(' · ');
      const amount = ProrateDuePanel.amountLine(p);
      return `<div title="${esc(p.programs || '')}" style="display:flex; flex-wrap:wrap; align-items:center; gap:6px 8px; margin:0 0 6px; padding:8px 10px;
                  border:1px solid #fcd34d; border-left:4px solid #d97706; border-radius:6px; background:#fffbeb; color:#0f172a;">
          <span style="font-weight:800;">💵 ${esc(ProrateDuePanel.nameOf(p))}</span>
          <span style="font-size:0.78rem; color:#64748b;">${esc(bits)}</span>
          <span style="margin-left:auto; display:inline-flex; gap:6px;">
            ${p.la_user_id ? `<button type="button" data-pd-la="${esc(p.la_user_id)}"
              style="padding:5px 10px; border-radius:6px; border:1px solid #3b82f6; background:#1e3a8a; color:#dbeafe; font:inherit; font-size:0.78rem; font-weight:700; cursor:pointer;">${esc(cp('prorate_open_la', {}, '🔗 Open in LA'))}</button>` : ''}
            <button type="button" data-pd-done="${esc(p.person_id)}" ${this.busy ? 'disabled' : ''}
              style="padding:5px 10px; border-radius:6px; border:1px solid #16a34a; background:transparent; color:#15803d; font:inherit; font-size:0.78rem; font-weight:800; cursor:pointer;">${esc(cp('prorate_done', {}, '✓ Done'))}</button>
          </span>
          ${amount ? `<span style="flex-basis:100%; font-weight:800; color:#b45309;">${esc(amount)}</span>` : ''}
        </div>`;
    }).join('');
    const all = `<button type="button" data-pd-done-all ${this.busy ? 'disabled' : ''}
        style="align-self:flex-start; margin:0 0 10px; padding:7px 14px; border-radius:8px; border:0; background:#16a34a; color:#fff; font:inherit; font-weight:800; cursor:pointer;">
        ${esc(cp('prorate_done_all', { n: this.due.length }, `✓ Done all (${this.due.length})`))}</button>`;
    const err = this.err ? `<p style="margin:0 0 8px; color:#fca5a5; font-size:0.8rem;">${esc(this.err)}</p>` : '';
    this.el.innerHTML = `<p style="margin:0 0 8px; font-size:0.85rem; color:#94a3b8;">${esc(cp('prorate_intro', {},
      'Only the $1 card fee billed so far. Add the charge in LA — they leave this list at the next sync once anything past $1 is billed.'))}</p>${all}${err}${rows}`;
  }
}

window.ProrateDuePanel = ProrateDuePanel;
