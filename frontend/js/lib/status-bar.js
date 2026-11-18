// StatusBar — 🚦 one line atop the Calendar: everything outstanding, coloured
// by the worst of it (mig 1468).  Owner 2026-11-18: "all the outstanding
// items should go [here] … unread messages, … unset rsvp, dues, fines etc.
// then if all set on all it should show in green and say up to date? then
// in yellow if something minor and red if major?" → "this would keep cal
// area cleaner".
//
// Mig 1469 (owner: "really there prob is no yellow just green and red"):
// an 'action' item (something to do) turns the bar red; an 'info' item is a
// grey chip and the bar stays green.
//
// The page feeds it items as they load; the rules (action / info, the
// "answer soon" window) come from status_items via /api/my/notices.  The
// bar is a button: tap → the details body (folded by default).  Words:
// message_templates event_center status_* / chip_<code>.
//
//   const bar = new StatusBar(headEl, bodyEl, { escapeHtml });
//   bar.setRules([{code, severity, window_hours}]);
//   bar.set('fines_owed', { amount: '$4' });   bar.set('fines_owed', null);
class StatusBar {
  constructor(head, body, ctx) {
    this.head = head;
    this.body = body;
    this.ctx = ctx;
    this.rules = new Map();
    this.items = new Map();
    this.open = false;
    this.ready = false;
    if (head) head.addEventListener('click', () => { this.open = !this.open; this.render(); });
  }

  static copy(tier, tokens, fb) {
    return (window.MessageCopy && MessageCopy.has && MessageCopy.has('event_center', tier))
      ? MessageCopy.block('event_center', tier, tokens) : fb;
  }

  setRules(list) {
    this.rules = new Map((list || []).map((r, i) => [r.code, { ...r, order: i }]));
    this.ready = true;
    this.render();
  }

  windowHours(code) { const r = this.rules.get(code); return (r && r.window_hours) || 48; }

  // data null / undefined = that item is clear.
  set(code, data) {
    if (data) this.items.set(code, data); else this.items.delete(code);
    this.render();
  }

  render() {
    if (!this.head) return;
    const esc = (t) => this.ctx.escapeHtml(t == null ? '' : String(t));
    // Items without a rule row are off (is_active false or unknown).
    const live = [...this.items.entries()]
      .filter(([code]) => this.rules.has(code))
      .sort((a, b) => this.rules.get(a[0]).order - this.rules.get(b[0]).order);
    const actions = live.filter(([code]) => this.rules.get(code).severity === 'action').length;
    const level = actions ? 'action' : 'ok';
    const headline = level === 'ok' ? StatusBar.copy('status_ok', {}, "✓ You're all set")
      : (actions === 1 ? StatusBar.copy('status_major_one', {}, '⛔ 1 thing needs you') : StatusBar.copy('status_major_many', { n: actions }, `⛔ ${actions} things need you`));
    const chips = live.map(([code, d]) => {
      const sev = this.rules.get(code).severity;
      const text = StatusBar.copy(`chip_${code}`, { ...d, hours: this.windowHours(code) }, code);
      return `<span style="display:inline-block; padding:1px 8px; border-radius:999px; font-size:0.72rem; font-weight:800; white-space:nowrap;
                 background:${sev === 'action' ? 'rgba(239,68,68,0.28)' : 'rgba(148,163,184,0.22)'}; color:${sev === 'action' ? '#fecaca' : '#e2e8f0'};">${esc(text)}</span>`;
    }).join('');
    const c = level === 'ok' ? { b: '#16a34a', bg: 'rgba(22,163,74,0.16)', fg: '#bbf7d0' }
      : { b: '#ef4444', bg: 'rgba(239,68,68,0.16)', fg: '#fecaca' };
    const hasBody = !!(this.body && this.body.textContent.trim());
    const toggle = hasBody ? `<span style="margin-left:auto; font-size:0.74rem; font-weight:700; opacity:0.85; white-space:nowrap;">${esc(this.open
      ? StatusBar.copy('status_close', {}, 'Hide ▴') : StatusBar.copy('status_open', {}, 'Details ▾'))}</span>` : '';
    this.head.style.cssText = `display:flex; align-items:center; gap:6px 8px; flex-wrap:wrap; width:100%; min-height:0; padding:8px 12px;
        border-radius:10px; cursor:${hasBody ? 'pointer' : 'default'}; text-align:left; font:inherit;
        border:2px solid ${c.b}; background:${c.bg}; color:${c.fg};`;
    this.head.setAttribute('aria-expanded', String(this.open));
    this.head.innerHTML = `<span style="font-weight:800; font-size:0.92rem;">${esc(headline)}</span>${chips}${toggle}`;
    this.head.hidden = !this.ready && !live.length;
    if (this.body) this.body.hidden = !this.open;
  }
}

window.StatusBar = StatusBar;
