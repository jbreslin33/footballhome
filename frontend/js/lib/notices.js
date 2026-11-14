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
    const c = d.tier === 'banner'
      ? { icon: '⛔', border: '#ef4444', bg: 'rgba(239,68,68,0.16)',  fg: '#fca5a5', btn: '#ef4444' }
      : d.tier === 'alternate_banner'
      ? { icon: '💰', border: '#f59e0b', bg: 'rgba(245,158,11,0.16)', fg: '#fcd34d', btn: '#d97706' }
      : { icon: '⚠️', border: '#f59e0b', bg: 'rgba(245,158,11,0.16)', fg: '#fcd34d', btn: '#d97706' };
    const button = mc.block('my_dues', 'banner_button') || 'Pay here';
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
    if (host) VolunteerShiftCard.mount(host, this.ctx.fetchJson);
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
    const views = this.notices
      .map(n => { const V = NoticeStrip.VIEWS[n && n.kind]; return V ? new V(n, this.ctx) : null; })
      .filter(Boolean);
    const parts = views.map(v => ({ v, html: v.html() })).filter(p => p.html);
    this.host.innerHTML = parts.map(p => `<div data-notice>${p.html}</div>`).join('');
    this.host.style.display = parts.length ? '' : 'none';
    const els = this.host.querySelectorAll('[data-notice]');
    parts.forEach((p, i) => p.v.mount(els[i]));
  }
}

window.NoticeView = NoticeView;
window.DuesNoticeView = DuesNoticeView;
window.VolunteerShiftNoticeView = VolunteerShiftNoticeView;
window.NoticeStrip = NoticeStrip;
