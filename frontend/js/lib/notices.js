// Notices — the strip atop Event Center: things about you and your kids that
// need doing (docs/event-center-design.md, slice 3).  Owner 2026-11-14: "do we
// need my section now? lets think of proper build with oop concepts on front
// and back end".
//
// GET /api/my/notices → { notices: [{kind, …}] } from the C++ NoticeBoard,
// one Notice subclass per kind on both ends:
//
//   NoticeView  →  DuesNoticeView            kind 'dues'            (mig 416/513/614)
//               →  VolunteerShiftNoticeView  kind 'volunteer_shift' (mig 1222)
//
// A new kind = a C++ Notice subclass + a view class here + one line in
// NoticeStrip.VIEWS.  Every word is message_templates (my_dues,
// volunteer_shift).
//
//   const strip = new NoticeStrip(host, { fetchJson, escapeHtml });
//   strip.load();

class NoticeView {
  constructor(data, ctx) { this.data = data; this.ctx = ctx; }
  esc(t) { return this.ctx.escapeHtml(t == null ? '' : String(t)); }
  // HTML for the strip ('' = nothing to show).
  html() { return ''; }
  // After the HTML is in the page: wire or mount anything live.
  mount(_el) {}
}

// 💰 / ⚠️ / ⛔ one person's dues (yours or a child's) with Pay here.
class DuesNoticeView extends NoticeView {
  static money(n) { return '$' + (Number(n) || 0).toFixed(2); }

  html() {
    const d = this.data;
    const mc = window.MessageCopy;
    if (!mc || !mc.has || !mc.has('my_dues', d.tier)) return '';
    const tokens = { amount: DuesNoticeView.money(d.balance), min_payment: DuesNoticeView.money(d.min_payment),
                     pause_amount: DuesNoticeView.money(d.line) };
    const who = d.is_self ? '' : `${this.esc(d.first_name || 'Your player')}: `;
    const c = d.tier === 'volunteer_owed'
      ? { icon: '', border: '#2563eb', bg: 'rgba(37,99,235,0.14)', fg: '#bfdbfe', btn: '#2563eb' }
      : d.tier === 'banner'
      ? { icon: '⛔', border: '#ef4444', bg: 'rgba(239,68,68,0.16)',  fg: '#fca5a5', btn: '#ef4444' }
      : d.tier === 'alternate_banner'
      ? { icon: '💰', border: '#f59e0b', bg: 'rgba(245,158,11,0.16)', fg: '#fcd34d', btn: '#d97706' }
      : { icon: '⚠️', border: '#f59e0b', bg: 'rgba(245,158,11,0.16)', fg: '#fcd34d', btn: '#d97706' };
    const button = mc.block('my_dues', 'banner_button') || 'Pay here';
    // 🙋 Owner 11/18: "shorter message stating they are behind and need to
    // fix and to pay here or to volunteer and let them know volunteer button
    // contains more info" — with a volunteer offer open, ONE short line and
    // two doors; the full volunteer card unfolds from its button.
    if (d.is_self && this.ctx.volunteerOffer && mc.has('my_dues', 'behind_short')) {
      const pay = /^https:\/\//.test(d.pay_url || '') ? `<a href="${this.esc(d.pay_url)}" target="_blank" rel="noopener"
             style="padding:6px 14px; border-radius:999px; background:${c.btn}; color:#fff; font-weight:800; text-decoration:none; white-space:nowrap;">${this.esc(button)}</a>` : '';
      const vol = `<button type="button" data-vol-open
             style="padding:6px 14px; border-radius:999px; background:#2563eb; color:#fff; font-weight:800; border:0; cursor:pointer; white-space:nowrap;">${this.esc(mc.block('my_dues', 'volunteer_button') || '🙋 Volunteer')}</button>`;
      return `<div style="display:flex; flex-direction:column; gap:8px; padding:10px 12px; border-radius:8px;
                          border:1px solid ${c.border}; background:${c.bg}; color:${c.fg}; font-size:0.85rem; font-weight:700; line-height:1.35;">
          <span>${c.icon} ${this.esc(mc.block('my_dues', 'behind_short', tokens))}</span>
          <span style="display:flex; gap:8px; flex-wrap:wrap;">${pay}${vol}</span>
        </div>`;
    }
    return `<div style="display:flex; align-items:center; justify-content:space-between; gap:8px; flex-wrap:wrap; padding:8px 10px; border-radius:8px;
                        border:1px solid ${c.border}; background:${c.bg}; color:${c.fg}; font-size:0.78rem; font-weight:700; line-height:1.3;">
        <span>${c.icon} ${who}${this.esc(mc.block('my_dues', d.tier, tokens))}</span>
        ${/^https:\/\//.test(d.pay_url || '') ? `<a href="${this.esc(d.pay_url)}" target="_blank" rel="noopener"
             style="padding:4px 10px; border-radius:999px; background:${c.btn}; color:#fff; font-weight:800; text-decoration:none; white-space:nowrap;">${this.esc(button)}</a>` : ''}
      </div>`;
  }
}

// 🙋 Volunteer one evening a week instead of paying — the existing card
// (components/volunteer-shift-card.js) mounted in the strip.
class VolunteerShiftNoticeView extends NoticeView {
  html() { return window.VolunteerShiftCard ? '<div data-notice-volunteer></div>' : ''; }
  mount(el) {
    const host = el.querySelector('[data-notice-volunteer]');
    // Folded behind the dues notice's 🙋 Volunteer button when that is up.
    if (host) VolunteerShiftCard.mount(host, this.ctx.fetchJson, { folded: !!this.ctx.volunteerFolded });
  }
}

class NoticeStrip {
  static get VIEWS() { return { dues: DuesNoticeView, volunteer_shift: VolunteerShiftNoticeView }; }

  constructor(host, ctx) {
    this.host = host;
    this.ctx = ctx;           // { fetchJson(url, opts), escapeHtml }
    this.notices = [];
    this.loaded = false;
  }

  get hasNotices() { return !!(this.host && this.host.childElementCount); }

  async load() {
    try {
      const body = await this.ctx.fetchJson('/api/my/notices');
      this.notices = Array.isArray(body && body.notices) ? body.notices : [];
    } catch (err) {
      console.error('[notices] load failed:', err);
      this.notices = [];
    }
    if (window.MessageCopy) await MessageCopy.load(this.ctx.auth).catch(() => {});
    this.render();
    this.loaded = true;
  }

  render() {
    if (!this.host) return;
    // A volunteer offer (no pick yet) + your own dues notice = one short
    // dues line with Pay here / 🙋 Volunteer; the card folds behind it.
    const offer = this.notices.some(n => n && n.kind === 'volunteer_shift' && n.offer && !n.pick);
    const selfDues = this.notices.some(n => n && n.kind === 'dues' && n.is_self);
    this.ctx.volunteerOffer = offer;
    this.ctx.volunteerFolded = offer && selfDues && !!(window.MessageCopy && MessageCopy.has && MessageCopy.has('my_dues', 'behind_short'));
    const views = this.notices
      .map(n => { const V = NoticeStrip.VIEWS[n && n.kind]; return V ? new V(n, this.ctx) : null; })
      .filter(Boolean);
    const parts = views.map(v => ({ v, html: v.html() })).filter(p => p.html);
    this.host.innerHTML = parts.map(p => `<div data-notice>${p.html}</div>`).join('');
    this.host.style.display = parts.length ? '' : 'none';
    const els = this.host.querySelectorAll('[data-notice]');
    parts.forEach((p, i) => p.v.mount(els[i]));
    if (!this.host._volWired) {
      this.host._volWired = true;
      this.host.addEventListener('click', (e) => {
        if (!e.target.closest('[data-vol-open]')) return;
        window.dispatchEvent(new CustomEvent('fh:volunteer-toggle'));
      });
    }
  }
}

window.NoticeView = NoticeView;
window.DuesNoticeView = DuesNoticeView;
window.VolunteerShiftNoticeView = VolunteerShiftNoticeView;
window.NoticeStrip = NoticeStrip;
