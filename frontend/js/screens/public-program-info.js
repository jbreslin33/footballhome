// PublicProgramInfoScreen — auth-less landing page linked from flyer QR
// codes (see flyers.js). Shows the full Lighthouse program description
// (from frontend/js/lib/program-info.js — the single source of truth,
// shared with the Leads screen's LA Program Description snippet) plus
// Register buttons for each club, so one QR code can cover both Boys/
// Girls (or Men's/Women's) instead of needing one QR per link.
class PublicProgramInfoScreen extends Screen {
  onEnter(params = {}) {
    this.audience = params.audience === 'adult' ? 'adult' : 'youth';
    this.renderContent();
  }

  render() {
    const el = document.createElement('div');
    el.className = 'screen';
    el.innerHTML = `<div id="ppi-root"></div>`;
    this.element = el;
    return el;
  }

  renderContent() {
    const root = this.find('#ppi-root');
    if (!root) return;
    root.innerHTML = this.audience === 'adult' ? this.renderAdult() : this.renderYouth();
  }

  pageShell(bodyHtml) {
    return `
      <style>
        .ppi-card h3 { font-size: 17px; margin: 20px 0 8px; color: #f5d442; }
        .ppi-card h3:first-child { margin-top: 0; }
        .ppi-card p { margin: 0 0 12px; color: rgba(255,255,255,0.92); }
        .ppi-card ul { margin: 0 0 12px; padding-left: 22px; color: rgba(255,255,255,0.92); }
        .ppi-card ul ul { margin: 6px 0; }
        .ppi-card li { margin-bottom: 6px; }
        .ppi-card a { color: #f5d442; }
        .ppi-card strong { color: #fff; }
      </style>
      <div style="min-height:100vh; background:linear-gradient(160deg,#0D2A52 0%,#0a1628 55%,#0D2A52 100%); color:#fff; font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif;">
        <div class="narrow" style="max-width:720px; margin:0 auto; padding:32px 20px 60px; box-sizing:border-box;">
          <div style="display:flex; flex-direction:column; align-items:center; gap:10px; text-align:center; margin-bottom:28px;">
            <img src="/images/lighthouse-1893-crest.png" alt="Lighthouse 1893 crest" style="width:88px; height:88px; object-fit:contain;">
            <div style="font-size:13px; letter-spacing:2px; text-transform:uppercase; opacity:0.6;">footballhome.org &middot; Lighthouse 1893</div>
            <div style="font-size:30px; font-weight:900; letter-spacing:1px;">Lighthouse 1893</div>
          </div>
          ${bodyHtml}
          <div style="text-align:center; margin-top:36px; opacity:0.5; font-size:13px;">
            Questions? Email <a href="mailto:soccer@lighthouse1893.org" style="color:#f5d442;">soccer@lighthouse1893.org</a>
          </div>
        </div>
      </div>
    `;
  }

  registerButton(label, url, feeLabel) {
    return `
      <a href="${this.escapeHtml(url)}" target="_blank" rel="noopener" style="display:block; text-align:center; background:#f5d442; color:#0a1628; font-weight:800; font-size:16px; padding:14px 20px; border-radius:12px; text-decoration:none; margin-bottom:10px; box-sizing:border-box;">
        ${this.escapeHtml(label)} — ${this.escapeHtml(feeLabel)}
      </a>
    `;
  }

  descCard(html) {
    return `<div class="ppi-card" style="background:rgba(255,255,255,0.06); border:1px solid rgba(255,255,255,0.15); border-radius:16px; padding:22px; line-height:1.55; margin-bottom:20px;">${html}</div>`;
  }

  renderYouth() {
    const links = window.LighthouseProgramInfo.REGISTER_LINKS;
    const desc = window.LighthouseProgramInfo.buildProgramDescription({ isYouth: true, isWomensClub: false, isMensClub: false });
    return this.pageShell(`
      <h1 style="text-align:center; font-size:27px; margin:0 0 4px;">Youth Soccer at Lighthouse</h1>
      <p style="text-align:center; opacity:0.7; margin:0 0 22px;">Boys Club &amp; Girls Club — ages 5–19</p>
      <div style="margin-bottom:6px;">
        ${this.registerButton('⚽ Register — Lighthouse Boys Club', links.boys, desc.feeLabel)}
        ${this.registerButton('⚽ Register — Lighthouse Girls Club', links.girls, desc.feeLabel)}
      </div>
      ${this.descCard(desc.html)}
    `);
  }

  renderAdult() {
    const links = window.LighthouseProgramInfo.REGISTER_LINKS;
    const mens = window.LighthouseProgramInfo.buildProgramDescription({ isYouth: false, isWomensClub: false, isMensClub: true });
    const womens = window.LighthouseProgramInfo.buildProgramDescription({ isYouth: false, isWomensClub: true, isMensClub: false });
    return this.pageShell(`
      <h1 style="text-align:center; font-size:27px; margin:0 0 4px;">Adult Soccer at Lighthouse</h1>
      <p style="text-align:center; opacity:0.7; margin:0 0 22px;">Men's Club &amp; Women's Club</p>

      <h2 style="font-size:19px; margin:0 0 10px; color:#f5d442;">Lighthouse Men's Club</h2>
      ${this.registerButton("⚽ Register — Lighthouse Men's Club", links.mens, mens.feeLabel)}
      ${this.descCard(mens.html)}

      <h2 style="font-size:19px; margin:26px 0 10px; color:#f5d442;">Lighthouse Women's Club</h2>
      ${this.registerButton("⚽ Register — Lighthouse Women's Club", links.womens, womens.feeLabel)}
      ${this.descCard(womens.html)}
    `);
  }

  onExit() { /* nothing to clean up */ }
}
