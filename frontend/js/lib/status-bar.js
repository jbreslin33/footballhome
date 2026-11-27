// StatusBar — 🚦 the band at the top of every screen: everything outstanding,
// one box per item, green or red (migs 1468 → 1473).  Owner 2026-11-18:
// "all the outstanding items should go [here] … green and say up to date …
// red" → "really there prob is no yellow just green and red" → "just like
// the viewing as bar" → "more actionable and clear" → "Overdue dues pay now
// button? missing x rsvps do so below?" → "amount fined so far?" → "amount
// they will be fined if they don't set availability this week" → "each item
// needs to be in a box and actionable … phone stacked, desktop across" →
// "what is point of details? just let each box do its own expanding".
//
//   [⛔ Overdue dues $70  Pay now › 🙋 Volunteer ›] [⛔ Missing 8 RSVPs · $11 in fines if not set  Answer ›]
//   [⚖️ Fined so far $4  See ›] [💬 Juan: see you at 7  3 new ›]
//
// A box = a label (seg_<code>) + one or more buttons (act_<code>, plus any
// d.extra [{code, text}]).  Tapping the box does its first button.  An
// 'action' item (status_items) turns the band red; 'info' boxes are lighter.
// The page decides what a button does (ctx.onChip(code)) and which one is
// open (bar.openCode → that box is outlined; its popup is the page's).
//
//   const bar = new StatusBar(headEl, { escapeHtml, onChip(code) });
//   bar.setRules([{code, severity, window_hours}]);
//   bar.set('fines_owed', { amount: '$4', stake: '$11' });   bar.set('fines_owed', null);
// Fines (owner 11/18 "a box with fines. current and new potential"): one box,
// what is owed so far + what this week's unanswered events would add.
class StatusBar {
  constructor(head, ctx) {
    this.head = head;
    this.ctx = ctx;
    this.rules = new Map();
    this.items = new Map();
    this.openCode = null;
    this.ready = false;
    this.tail = '';   // the page's own HTML at the band's right end (the 💬 button)
    if (head) head.addEventListener('click', (e) => {
      const hit = e.target.closest('[data-sb-chip]');
      if (hit && this.ctx.onChip) this.ctx.onChip(hit.getAttribute('data-sb-chip'));
    });
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

  has(code) { return this.items.has(code) && this.rules.has(code); }

  setTail(html) { if (html !== this.tail) { this.tail = html || ''; this.render(); } }

  render() {
    if (!this.head) return;
    const esc = (t) => this.ctx.escapeHtml(t == null ? '' : String(t));
    const live = [...this.items.entries()]
      .filter(([code]) => this.rules.has(code))   // no rule row = off
      .sort((a, b) => this.rules.get(a[0]).order - this.rules.get(b[0]).order);
    // A box may carry its own severity (🆕 onboarding report: 'info' while all
    // green / everyone onboarded, so the report never turns the band red).
    const sev = (code) => (this.items.get(code) || {}).severity || this.rules.get(code).severity;
    // The two RSVP items read as one box: the total, how many are soon.
    const soon = this.items.get('rsvp_soon'), later = this.items.get('rsvp_open');
    const total = (soon ? Number(soon.n) || 0 : 0) + (later ? Number(later.n) || 0 : 0);
    // Only the NEW fines at stake, on the RSVP box — never a past total
    // (owner 11/18 "don't show total at all except in a fines section").
    const stake = (soon && soon.stake) || (later && later.stake) || '';
    const shown = live.filter(([code]) => !(code === 'rsvp_open' && soon && this.rules.has('rsvp_soon')));
    const actions = shown.filter(([code]) => sev(code) === 'action');
    const infos = shown.filter(([code]) => sev(code) !== 'action');

    const FB = {
      rsvp_soon:    (d) => [`⛔ Missing ${total} RSVPs — ${d.n} in the next ${d.hours}h${stake ? ` · ${stake} in fines if not set` : ''}`, 'Answer ›'],
      rsvp_open:    () => [`⛔ Missing ${total} RSVPs${stake ? ` · ${stake} in fines if not set` : ''}`, 'Answer ›'],
      dues_blocked: (d) => [`⛔ Can't play — overdue dues ${d.amount}`, 'Pay now ›'],
      dues_owed:    (d) => [`⛔ Overdue dues ${d.amount}`, 'Pay now ›'],
      fines_owed:   (d) => [`⚖️ Fines ${d.amount} so far${d.stake ? ` · +${d.stake} if RSVPs not set` : ''}`, 'See ›'],
      chat_unread:  (d) => [`💬 ${d.text || 'Chat'}`, d.n ? `${d.n} new ›` : 'Open ›'],
      suspended:    () => ['⛔ Suspended', ''],
      onboarding:   (d) => [`⛔ Onboarding — ${d.left} to do: ${d.list}`, 'Finish ›'],
      todo:         (d) => [`✅ To do — ${d.list}`, 'Open ›'],
      welcome_owed: (d) => [`👋 Welcome — ${d.n} new: ${d.list}`, 'Welcome ›'],
      prorate_owed: (d) => [`💵 Prorate — ${d.n} new to bill: ${d.list}`, 'Bill ›'],
      leads_new:    (d) => [`🎯 New leads — ${d.n} waiting: ${d.list}`, 'Contact ›'],
      new_members:  (d) => [d.ok ? `🆕 Onboarding — all ${d.total} new members onboarded ✓` : `🆕 Onboarding — ${d.left} of ${d.total} not onboarded: ${d.list}`, 'Onboard ›'],
    };
    const caret = (code, text) => (this.openCode === code ? String(text).replace('▾', '▴') : text);
    const pill = (code, text) => `<button type="button" class="sb-box-go" data-sb-chip="${esc(code)}">${esc(caret(code, text))}</button>`;
    const box = ([code, d], strong) => {
      const tokens = { ...d, hours: this.windowHours(code), total, stake };
      const [lfb, bfb] = (FB[code] || (() => [code, '›']))(tokens);
      const rsvp = code === 'rsvp_soon' || code === 'rsvp_open';
      const label = StatusBar.copy(`seg_${code}${rsvp && stake ? '_fine' : ''}${code === 'fines_owed' && d.stake ? '_stake' : ''}${code === 'new_members' && d.ok ? '_ok' : ''}`, tokens, lfb);
      const actTier = code === 'chat_unread' && !d.n ? 'act_chat_read' : `act_${code}`;
      const btn = bfb ? StatusBar.copy(actTier, tokens, bfb) : '';
      // A choice reads as one: [Pay now ›] or [🙋 Volunteer ›] (owner 11/18 "Pay now OR Volunteer").
      const orWord = `<span class="sb-box-or">${esc(StatusBar.copy('or_word', {}, 'or'))}</span>`;
      const extra = (Array.isArray(d.extra) ? d.extra : []).map(x => orWord + pill(x.code, x.text)).join('');
      const open = this.openCode === code || (Array.isArray(d.extra) && d.extra.some(x => x.code === this.openCode));
      return `<div class="sb-box ${strong ? 'sb-box-act' : 'sb-box-info'} ${open ? 'sb-box-open' : ''}" data-sb-chip="${esc(code)}" data-sb-code="${esc(code)}" role="button" tabindex="0">
          <span class="sb-box-label">${esc(label)}</span>
          ${btn || extra ? `<span class="sb-box-btns">${btn ? pill(code, btn) : ''}${extra}</span>` : ''}
        </div>`;
    };
    const lead = actions.length ? '' : `<span class="sb-ok">${esc(StatusBar.copy('status_ok', {}, '✓ All set'))}</span>`;
    const boxes = [...actions.map(it => box(it, true)), ...infos.map(it => box(it, false))];

    const c = actions.length ? { b: '#b91c1c', bg: '#dc2626' } : { b: '#15803d', bg: '#16a34a' };
    this.head.className = 'sb-band';
    this.head.style.cssText = `border-bottom:1px solid ${c.b}; background:${c.bg};`;
    this.head.innerHTML = `${lead}${boxes.length ? `<div class="sb-boxes">${boxes.join('')}</div>` : ''}${this.tail}`;
    // Hidden until the rules arrive — never a green "all set" before anything is known.
    this.head.hidden = !this.ready;
  }
}

window.StatusBar = StatusBar;
