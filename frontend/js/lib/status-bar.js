// StatusBar — 🚦 the band at the top of every screen: everything outstanding,
// green or red (migs 1468 → 1472).  Owner 2026-11-18: "all the outstanding
// items should go [here] … green and say up to date … red" → "really there
// prob is no yellow just green and red" → "just like the viewing as bar" →
// "it needs to be more actionable and clear" → "Overdue dues pay now button?
// missing x rsvps do so below?" → "amount fined so far?".
//
// One short segment per item, each with the thing to do:
//   ⛔ Overdue dues $70 [Pay now ›]   ⛔ Missing 8 RSVPs · $11 in fines if not set [Answer below ›]
//   Fined so far $4 ›   3 new messages ›
// 'action' items (status_items) turn the band red and lead; 'info' items are
// lighter buttons and the band stays green ("✓ All set").  The band itself
// toggles the details; a button calls ctx.onChip(code).
// Words: event_center seg_<code> (the label) + act_<code> (the button).
//
//   const bar = new StatusBar(headEl, bodyEl, { escapeHtml, onChip(code) });
//   bar.setRules([{code, severity, window_hours}]);
//   bar.set('fines_owed', { amount: '$4' });   bar.set('fines_owed', null);
//   bar.toggle(true)  open the details
class StatusBar {
  constructor(head, body, ctx) {
    this.head = head;
    this.body = body;
    this.ctx = ctx;
    this.rules = new Map();
    this.items = new Map();
    this.open = false;
    this.ready = false;
    if (head) {
      head.addEventListener('click', (e) => {
        const chip = e.target.closest('[data-sb-chip]');
        if (chip) { if (this.ctx.onChip) this.ctx.onChip(chip.getAttribute('data-sb-chip')); return; }
        this.toggle(!this.open);
      });
      head.addEventListener('keydown', (e) => {
        if ((e.key === 'Enter' || e.key === ' ') && e.target === head) { e.preventDefault(); this.toggle(!this.open); }
      });
    }
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

  toggle(open) { this.open = !!open; this.render(); }

  render() {
    if (!this.head) return;
    const esc = (t) => this.ctx.escapeHtml(t == null ? '' : String(t));
    const live = [...this.items.entries()]
      .filter(([code]) => this.rules.has(code))   // no rule row = off
      .sort((a, b) => this.rules.get(a[0]).order - this.rules.get(b[0]).order);
    const sev = (code) => this.rules.get(code).severity;
    // The two RSVP items read as one: the total, and how many are soon.
    const soon = this.items.get('rsvp_soon'), later = this.items.get('rsvp_open');
    const total = (soon ? Number(soon.n) || 0 : 0) + (later ? Number(later.n) || 0 : 0);
    // "amount they will be fined if they don't set availability this week"
    const stake = (soon && soon.stake) || (later && later.stake) || '';
    const shown = live.filter(([code]) => !(code === 'rsvp_open' && soon && this.rules.has('rsvp_soon')));
    const actions = shown.filter(([code]) => sev(code) === 'action');
    const infos = shown.filter(([code]) => sev(code) !== 'action');

    const FB = {
      rsvp_soon:    (d) => [`⛔ Missing ${total} RSVPs — ${d.n} in the next ${d.hours}h${stake ? ` · ${stake} in fines if not set` : ''}`, 'Answer below ›'],
      rsvp_open:    () => [`⛔ Missing ${total} RSVPs${stake ? ` · ${stake} in fines if not set` : ''}`, 'Answer below ›'],
      dues_blocked: (d) => [`⛔ Can't play — overdue dues ${d.amount}`, 'Pay now ›'],
      dues_owed:    (d) => [`⛔ Overdue dues ${d.amount}`, 'Pay now ›'],
      fines_owed:   (d) => ['', `Fined so far ${d.amount} ›`],
      chat_unread:  (d) => ['', `${d.n} new messages ›`],
      suspended:    () => ['', 'Suspended ›'],
    };
    const seg = ([code, d], strong) => {
      const tokens = { ...d, hours: this.windowHours(code), total, stake };
      const [lfb, bfb] = (FB[code] || (() => ['', `${code} ›`]))(tokens);
      const rsvp = code === 'rsvp_soon' || code === 'rsvp_open';
      const label = StatusBar.copy(`seg_${code}${rsvp && stake ? '_fine' : ''}`, tokens, lfb);
      const btn = StatusBar.copy(`act_${code}`, tokens, bfb);
      // One box per item, the whole box is the button (owner 11/18 "each item
      // needs to be in a box and actionable … phone stacked, desktop across").
      // An info item has no label: its button words fill the box.
      return `<button type="button" class="sb-box ${strong ? 'sb-box-act' : 'sb-box-info'}" data-sb-chip="${esc(code)}">
          <span class="sb-box-label">${esc(label || btn.replace(/\s*›\s*$/, ''))}</span>
          <span class="sb-box-go">${esc(label ? btn : '›')}</span>
        </button>`;
    };
    const lead = actions.length ? '' : `<span class="sb-ok">${esc(StatusBar.copy('status_ok', {}, '✓ All set'))}</span>`;
    const boxes = [...actions.map(it => seg(it, true)), ...infos.map(it => seg(it, false))];

    const c = actions.length ? { b: '#b91c1c', bg: '#dc2626' } : { b: '#15803d', bg: '#16a34a' };
    const hasBody = !!(this.body && this.body.textContent.trim());
    const toggle = hasBody ? `<span class="sb-toggle">${esc(this.open
      ? StatusBar.copy('status_close', {}, 'Hide ▴') : StatusBar.copy('status_open', {}, 'Details ▾'))}</span>` : '';
    this.head.setAttribute('role', 'button');
    this.head.setAttribute('tabindex', '0');
    this.head.className = 'sb-band';
    this.head.style.cssText = `border-bottom:1px solid ${c.b}; cursor:${hasBody ? 'pointer' : 'default'}; background:${c.bg};`;
    this.head.setAttribute('aria-expanded', String(this.open));
    this.head.innerHTML = `${lead}${boxes.length ? `<div class="sb-boxes">${boxes.join('')}</div>` : ''}${toggle}`;
    // Hidden until the rules arrive (NoticeStrip.load always hands them over,
    // [] on failure) — never a green "all set" before anything is known.
    this.head.hidden = !this.ready;
    if (this.body) this.body.hidden = !this.open;
  }
}

window.StatusBar = StatusBar;
