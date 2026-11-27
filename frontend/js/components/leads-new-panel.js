// LeadsNewPanel — 🎯 new leads nobody has contacted yet, in the 🚦 band's
// popup (mig 1646).  Owner 2026-11-21: "we need also for admin if a new
// lead is sitting it should show there and be actionable".
//
// The band shows a red "🎯 New leads — N waiting: …  Contact ›" box while
// any lead on a live ad's form is still New (club / super / marketing
// admins, never while viewing as).  This is its popup:
//
//   Tap a name — their contact opens with touch 1 ready …
//   [🎯 Ralf            Adult Men · 3h ago ]
//                                   [📋 Open the Leads board]
//
// A name opens #leads with that lead's 📇 Contact popup (touch 1
// preselected).  Any send or call logs a touch, so the lead is no longer
// New and leaves the band.  Words: event_center leads_new_*.
//
//   const p = new LeadsNewPanel(el, { fetchJson, escapeHtml, auth, navigation, onChange(list), onGo() });
//   p.load();   p.render();
class LeadsNewPanel {
  constructor(el, ctx) {
    this.el = el;
    this.ctx = ctx;
    this.leads = [];
    if (el) el.addEventListener('click', (e) => {
      const b = e.target.closest('[data-ln-lead]');
      if (b) { this.go(Number(b.getAttribute('data-ln-lead'))); return; }
      if (e.target.closest('[data-ln-board]')) this.go(0);
    });
  }

  static cp(tier, tokens, fb) {
    return (window.MessageCopy && MessageCopy.has && MessageCopy.has('event_center', tier))
      ? MessageCopy.block('event_center', tier, tokens) : fb;
  }

  // Whoever can open #leads, and only as themselves — a 403 just means no box.
  static wanted(auth) {
    const role = auth && auth.user && auth.user.role;
    return !!auth && !auth.viewAsPersonId && ['club', 'super', 'marketing'].includes(role);
  }

  async load() {
    if (!LeadsNewPanel.wanted(this.ctx.auth)) { this.set([]); return; }
    try { this.set((await this.ctx.fetchJson('/api/leads/new')).leads || []); }
    catch (_) { /* the band just shows no box */ }
  }

  set(list) {
    this.leads = Array.isArray(list) ? list : [];
    this.render();
    if (this.ctx.onChange) this.ctx.onChange(this.leads);
  }

  // The Leads screen owns the message copy and the touch log, so the
  // contact opens there.  Already on #leads with its list in hand: no reload.
  go(leadId) {
    const nav = this.ctx.navigation || (window.app && window.app.navigation);
    const scr = window.app && window.app.screens && window.app.screens.leads;
    if (this.ctx.onGo) this.ctx.onGo();
    if (!nav) return;
    if (leadId && nav.currentState === 'leads' && scr && scr.openLead(leadId)) return;
    if (nav.context) nav.context.role = 'marketing';   // the hat #leads wears from the menu
    nav.goTo('leads', leadId ? { openLeadId: leadId } : {});
  }

  static ago(iso) {
    const mins = Math.max(0, Math.round((Date.now() - new Date(iso).getTime()) / 60000));
    if (!isFinite(mins)) return '';
    if (mins < 60) return `${mins || 1}m`;
    if (mins < 60 * 24) return `${Math.round(mins / 60)}h`;
    return `${Math.round(mins / 1440)}d`;
  }

  render() {
    if (!this.el) return;
    const esc = this.ctx.escapeHtml;
    const cp = LeadsNewPanel.cp;
    const board = `<button type="button" data-ln-board
        style="margin-top:6px; padding:7px 14px; border-radius:8px; border:1px solid var(--border-color, #374151); background:transparent; color:inherit; font:inherit; font-weight:700; cursor:pointer;">
        ${esc(cp('leads_new_board', {}, '📋 Open the Leads board'))}</button>`;
    if (!this.leads.length) {
      this.el.innerHTML = `<p style="margin:4px 0; color:#94a3b8;">${esc(cp('leads_new_empty', {}, 'No new leads waiting. ✓'))}</p>${board}`;
      return;
    }
    const scr = window.app && window.app.screens && window.app.screens.leads;
    const rows = this.leads.map(l => {
      const funnel = (scr && scr.formLabel(l.form_id)) || '';
      const bits = [funnel, l.created_at ? cp('leads_new_ago', { ago: LeadsNewPanel.ago(l.created_at) }, `${LeadsNewPanel.ago(l.created_at)} ago`) : '']
        .filter(Boolean).join(' · ');
      return `<button type="button" data-ln-lead="${esc(l.id)}"
          style="width:100%; display:flex; align-items:center; gap:8px; text-align:left; padding:9px 10px; margin:0 0 6px;
                 border:1px solid #f0abfc; border-left:4px solid #c026d3; border-radius:6px; background:#fdf4ff; cursor:pointer; font:inherit;">
          <span style="font-weight:800; color:#0f172a; overflow-wrap:anywhere;">🎯 ${esc(l.name || cp('leads_new_noname', {}, '(no name)'))}</span>
          <span style="margin-left:auto; font-size:0.78rem; color:#64748b; text-align:right;">${esc(bits)}</span>
        </button>`;
    }).join('');
    this.el.innerHTML = `<p style="margin:0 0 8px; font-size:0.85rem; color:#94a3b8;">${esc(cp('leads_new_intro', {},
      'Tap a name — their contact opens with touch 1 ready. They leave this list once you email, text or call.'))}</p>${rows}${board}`;
  }
}

window.LeadsNewPanel = LeadsNewPanel;
