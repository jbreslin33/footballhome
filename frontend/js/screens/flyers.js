// FlyersScreen — Generate printable recruitment flyers with QR codes for club admin.
// Two sources: saved presets (below) and the "+ Create Flyer" form, which
// can also be pre-filled from a calendar event (see calendar.js "Flyer"
// action → navigation.context.flyerPrefill).
class FlyersScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🖨️ Flyers</h1>
        <p class="subtitle">Generate printable recruitment flyers with QR codes</p>
      </div>

      <div style="padding: var(--space-4); max-width: 900px; margin: 0 auto;">
        <button id="create-flyer-btn" class="btn btn-primary" style="margin-bottom: var(--space-4);">➕ Create Flyer</button>
        <div id="flyers-list"></div>

        <div id="flyer-preview-area" style="display:none; margin-top: var(--space-4);">
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:var(--space-3);">
            <h3 id="flyer-preview-title">Preview</h3>
            <div style="display:flex;gap:var(--space-2);">
              <button class="btn btn-secondary close-preview-btn">✕ Close</button>
              <button class="btn btn-success download-flyer-btn">⬇️ Download PNG</button>
            </div>
          </div>
          <div style="background:#0a0f1e;padding:20px;border-radius:12px;overflow:hidden;">
            <div id="flyer-scale-wrap" style="transform:scale(0.35);transform-origin:top center;margin-bottom:-700px;">
              <div id="flyer-render-area"></div>
            </div>
          </div>
          <p style="text-align:center;opacity:0.5;font-size:0.8rem;margin-top:var(--space-2);">
            Preview is scaled down. Download will be full resolution (1080×1080 PNG).
          </p>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId = params?.clubId;
    this.clubName = params?.clubName;
    this.currentFlyerKey = null;
    this.customFlyerConfig = null;

    this.renderFlyersList();

    this.element.addEventListener('click', e => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      if (e.target.closest('#create-flyer-btn')) {
        this.openCreateFlyerForm();
        return;
      }
      const previewBtn = e.target.closest('.preview-flyer-btn');
      if (previewBtn) {
        this.openFlyer(previewBtn.dataset.key);
        return;
      }
      if (e.target.closest('.close-preview-btn')) {
        this.find('#flyer-preview-area').style.display = 'none';
        return;
      }
      if (e.target.closest('.download-flyer-btn')) {
        this.downloadCurrentFlyer();
        return;
      }
    });

    // Prefill from a calendar event (see calendar.js) — open the create
    // form pre-populated rather than skipping straight to a generated
    // image, so the marketing person still reviews/edits before printing.
    const prefill = this.navigation.context.flyerPrefill;
    if (prefill) {
      this.navigation.context.flyerPrefill = null;
      this.openCreateFlyerForm(prefill);
    }
  }

  renderFlyersList() {
    const list = this.find('#flyers-list');
    const flyers = [
      {
        key: 'u23-womens',
        title: "U23 Women's Interest Form",
        description: "CASA U23 Women's Premier League recruitment flyer with QR code linking to the interest form.",
        icon: '⚽',
        url: 'linktr.ee/Lighthouse1893Soccer',
      },
      {
        key: 'youth-clubs',
        title: 'Youth Soccer at Lighthouse',
        description: 'Boys Club & Girls Club recruitment flyer with two QR codes — each links straight to that club\'s LeagueApps registration page.',
        icon: '⚽',
        url: 'Boys Club + Girls Club registration',
      },
      {
        key: 'adult-clubs',
        title: 'Adult Soccer at Lighthouse',
        description: "Men's Club & Women's Club recruitment flyer with two QR codes — each links straight to that club's LeagueApps registration page.",
        icon: '⚽',
        url: "Men's Club + Women's Club registration",
      },
    ];

    list.innerHTML = flyers.map(f => `
      <div style="background:var(--bg-secondary);border-radius:var(--radius-lg);padding:var(--space-4);
                  display:flex;align-items:center;gap:var(--space-4);margin-bottom:var(--space-3);">
        <div style="font-size:3rem;">${f.icon}</div>
        <div style="flex:1;">
          <div style="font-weight:700;font-size:1.1rem;margin-bottom:4px;">${f.title}</div>
          <div style="opacity:0.7;font-size:0.9rem;">${f.description}</div>
          <div style="opacity:0.45;font-size:0.8rem;margin-top:4px;">QR → ${f.url}</div>
        </div>
        <button class="btn btn-primary preview-flyer-btn" data-key="${f.key}">
          Preview &amp; Download
        </button>
      </div>
    `).join('');
  }

  // ---------- Create Flyer form ----------

  openCreateFlyerForm(prefill = {}) {
    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay';
    overlay.innerHTML = `
      <div class="modal-content" style="max-width: 560px;">
        <div class="modal-header">
          <h2>➕ Create Flyer</h2>
          <button class="modal-close" data-action="close">&times;</button>
        </div>
        <div style="display:flex;flex-direction:column;gap:12px;">
          <div>
            <label style="display:block;font-weight:600;margin-bottom:4px;font-size:0.9rem;">Badge / league line</label>
            <input type="text" id="cf-badge" class="form-input" style="width:100%;box-sizing:border-box;" placeholder="e.g. ⚽ APSL Match Day" value="${this.escapeHtml(prefill.badge || '')}">
          </div>
          <div>
            <label style="display:block;font-weight:600;margin-bottom:4px;font-size:0.9rem;">Eyebrow (small text above title)</label>
            <input type="text" id="cf-eyebrow" class="form-input" style="width:100%;box-sizing:border-box;" placeholder="e.g. Game Day" value="${this.escapeHtml(prefill.eyebrow || '')}">
          </div>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
            <div>
              <label style="display:block;font-weight:600;margin-bottom:4px;font-size:0.9rem;">Title (big text)</label>
              <input type="text" id="cf-title" class="form-input" style="width:100%;box-sizing:border-box;" placeholder="e.g. GAME DAY" value="${this.escapeHtml(prefill.title || '')}">
            </div>
            <div>
              <label style="display:block;font-weight:600;margin-bottom:4px;font-size:0.9rem;">Subtitle</label>
              <input type="text" id="cf-subtitle" class="form-input" style="width:100%;box-sizing:border-box;" placeholder="e.g. vs Persepolis I" value="${this.escapeHtml(prefill.subtitle || '')}">
            </div>
          </div>

          <label style="font-weight:600;font-size:0.9rem;margin-bottom:-4px;">Info pills <span style="font-weight:400;opacity:0.6;">— leave blank to skip one</span></label>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;">
            ${[0, 1, 2, 3].map(i => {
              const p = (prefill.pills && prefill.pills[i]) || {};
              return `
                <div style="display:flex;gap:6px;align-items:center;background:var(--bg-primary);border:1px solid var(--border-color);border-radius:8px;padding:6px 8px;">
                  <input type="text" id="cf-pill-icon-${i}" class="form-input" style="width:44px;text-align:center;box-sizing:border-box;" placeholder="📅" value="${this.escapeHtml(p.icon || '')}">
                  <input type="text" id="cf-pill-label-${i}" class="form-input" style="width:70px;box-sizing:border-box;" placeholder="Label" value="${this.escapeHtml(p.label || '')}">
                  <input type="text" id="cf-pill-value-${i}" class="form-input" style="flex:1;box-sizing:border-box;" placeholder="Value" value="${this.escapeHtml(p.value || '')}">
                </div>
              `;
            }).join('')}
          </div>

          <div>
            <label style="display:block;font-weight:600;margin-bottom:4px;font-size:0.9rem;">Banner (optional highlight bar)</label>
            <input type="text" id="cf-banner" class="form-input" style="width:100%;box-sizing:border-box;" placeholder="e.g. 🌟 Open to All Players — Spots Available!" value="${this.escapeHtml(prefill.banner || '')}">
          </div>

          <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
            <div>
              <label style="display:block;font-weight:600;margin-bottom:4px;font-size:0.9rem;">Link <span style="font-weight:400;opacity:0.6;">— adds a QR code</span></label>
              <input type="text" id="cf-link" class="form-input" style="width:100%;box-sizing:border-box;" placeholder="https://…" value="${this.escapeHtml(prefill.link || '')}">
            </div>
            <div>
              <label style="display:block;font-weight:600;margin-bottom:4px;font-size:0.9rem;">QR caption</label>
              <input type="text" id="cf-qr-caption" class="form-input" style="width:100%;box-sizing:border-box;" placeholder="Scan to learn more" value="${this.escapeHtml(prefill.qrCaption || '')}">
            </div>
          </div>

          <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
            <div>
              <label style="display:block;font-weight:600;margin-bottom:4px;font-size:0.9rem;">Venue (footer, optional)</label>
              <input type="text" id="cf-venue" class="form-input" style="width:100%;box-sizing:border-box;" value="${this.escapeHtml(prefill.venue || '')}">
            </div>
            <div>
              <label style="display:block;font-weight:600;margin-bottom:4px;font-size:0.9rem;">Team (footer, optional)</label>
              <input type="text" id="cf-team" class="form-input" style="width:100%;box-sizing:border-box;" value="${this.escapeHtml(prefill.team || '')}">
            </div>
          </div>

          <button id="cf-generate-btn" class="btn btn-primary" style="margin-top:8px;">Generate Preview</button>
        </div>
      </div>
    `;
    document.body.appendChild(overlay);

    const close = () => overlay.remove();
    overlay.addEventListener('click', (e) => {
      if (e.target === overlay || e.target.closest('[data-action="close"]')) close();
    });

    overlay.querySelector('#cf-generate-btn').addEventListener('click', () => {
      const val = (id) => (overlay.querySelector(id)?.value || '').trim();
      const pills = [0, 1, 2, 3]
        .map(i => ({ icon: val(`#cf-pill-icon-${i}`), label: val(`#cf-pill-label-${i}`), value: val(`#cf-pill-value-${i}`) }))
        .filter(p => p.value);

      this.customFlyerConfig = {
        badge: val('#cf-badge'),
        eyebrow: val('#cf-eyebrow'),
        title: val('#cf-title'),
        subtitle: val('#cf-subtitle'),
        pills,
        banner: val('#cf-banner'),
        link: val('#cf-link'),
        qrCaption: val('#cf-qr-caption') || 'Scan to learn more',
        venue: val('#cf-venue'),
        team: val('#cf-team'),
      };

      if (!this.customFlyerConfig.title) {
        alert('Please enter a title.');
        return;
      }

      close();
      this.openFlyer('custom');
    });
  }

  openFlyer(key) {
    this.currentFlyerKey = key;
    const renderArea = this.find('#flyer-render-area');
    renderArea.innerHTML = this.buildFlyerHTML(key);
    const titles = {
      'u23-womens': "U23 Women's Flyer Preview",
      'youth-clubs': 'Youth Soccer at Lighthouse — Flyer Preview',
      'adult-clubs': 'Adult Soccer at Lighthouse — Flyer Preview',
    };
    this.find('#flyer-preview-title').textContent = key === 'custom' ? 'Flyer Preview' : (titles[key] || 'Flyer Preview');
    this.find('#flyer-preview-area').style.display = 'block';
    this.find('#flyer-preview-area').scrollIntoView({ behavior: 'smooth' });
  }

  buildFlyerHTML(key) {
    if (key === 'u23-womens') return this.u23WomensFlyerHTML();
    if (key === 'youth-clubs') return this.youthClubsFlyerHTML();
    if (key === 'adult-clubs') return this.adultClubsFlyerHTML();
    if (key === 'custom' && this.customFlyerConfig) return this.renderFlyerHTML(this.customFlyerConfig);
    return '';
  }

  // Generic 1080×1080 flyer template. All sections but title are optional.
  renderFlyerHTML(cfg) {
    const qrUrl = cfg.link
      ? 'https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=' + encodeURIComponent(cfg.link) + '&format=png'
      : null;
    const pills = (cfg.pills || []).slice(0, 4);
    const hasFooter = cfg.venue || cfg.team;

    return `
      <div style="
        width:1080px;height:1080px;position:relative;overflow:hidden;
        background:linear-gradient(160deg,#1565C0 0%,#0a1628 55%,#0D47A1 100%);
        color:white;font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif;
        box-sizing:border-box;
      ">
        <div style="position:absolute;top:0;left:0;right:0;bottom:0;opacity:0.04;
          background-image:radial-gradient(#ffffff 1px,transparent 1px);
          background-size:28px 28px;pointer-events:none;"></div>
        <div style="position:absolute;top:-60px;right:-60px;width:450px;height:450px;
          opacity:0.1;border-radius:50%;
          background:radial-gradient(circle,#ffffff 0%,transparent 70%);
          pointer-events:none;"></div>
        <div style="position:absolute;top:0;left:0;right:0;height:10px;
          background:linear-gradient(90deg,#1565C0,#f5d442,#0D47A1);"></div>
        <div style="position:absolute;bottom:0;left:0;right:0;height:6px;
          background:linear-gradient(90deg,#1565C0,#f5d442,#0D47A1);"></div>

        <div style="position:absolute;top:0;left:0;right:0;bottom:0;
          display:flex;flex-direction:column;align-items:center;justify-content:space-between;
          padding:28px 60px;">

          ${cfg.badge ? `
          <div style="background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.25);
            border-radius:40px;padding:10px 30px;margin-top:12px;
            font-size:22px;font-weight:700;letter-spacing:3px;text-transform:uppercase;
            color:#f5d442;">
            ${this.escapeHtml(cfg.badge)}
          </div>` : '<div></div>'}

          <div style="display:flex;flex-direction:column;align-items:center;gap:10px;">
            ${cfg.eyebrow ? `<div style="font-size:28px;font-weight:700;letter-spacing:6px;text-transform:uppercase;
              color:rgba(255,255,255,0.6);">${this.escapeHtml(cfg.eyebrow)}</div>` : ''}
            <div style="font-size:84px;font-weight:900;letter-spacing:4px;text-transform:uppercase;
              text-shadow:0 6px 20px rgba(0,0,0,0.7);color:white;line-height:1;text-align:center;">${this.escapeHtml(cfg.title)}</div>
            ${cfg.subtitle ? `<div style="font-size:40px;font-weight:700;letter-spacing:3px;color:#f5d442;text-align:center;">${this.escapeHtml(cfg.subtitle)}</div>` : ''}
          </div>

          ${pills.length ? `
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;width:100%;">
            ${pills.map(p => `
            <div style="background:rgba(255,255,255,0.09);border:1px solid rgba(255,255,255,0.18);
              border-radius:14px;padding:14px 18px;display:flex;align-items:center;gap:12px;
              font-size:23px;font-weight:500;">
              <span style="font-size:26px;flex-shrink:0;">${this.escapeHtml(p.icon || '•')}</span>
              <span>
                ${p.label ? `<span style="font-size:14px;opacity:0.5;display:block;letter-spacing:1px;text-transform:uppercase;margin-bottom:2px;">${this.escapeHtml(p.label)}</span>` : ''}
                ${this.escapeHtml(p.value)}
              </span>
            </div>
            `).join('')}
          </div>` : ''}

          ${cfg.banner ? `
          <div style="background:rgba(255,255,255,0.1);border:2px solid #f5d442;
            border-radius:12px;padding:12px 40px;
            font-size:26px;font-weight:800;letter-spacing:2px;text-transform:uppercase;
            color:white;text-align:center;width:100%;">
            ${this.escapeHtml(cfg.banner)}
          </div>` : ''}

          ${qrUrl ? `
          <div style="background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.2);
            border-radius:16px;padding:18px 36px;display:flex;align-items:center;gap:28px;width:100%;">
            <img src="${qrUrl}" width="220" height="220"
                 style="background:white;padding:10px;border-radius:10px;flex-shrink:0;"
                 crossorigin="anonymous">
            <div>
              <div style="font-size:26px;font-weight:800;margin-bottom:8px;">📲 ${this.escapeHtml(cfg.qrCaption || 'Scan to learn more')}</div>
              <div style="font-size:20px;opacity:0.7;word-break:break-all;">${this.escapeHtml(cfg.link)}</div>
            </div>
          </div>` : ''}

          ${hasFooter ? `
          <div style="display:flex;align-items:center;justify-content:center;gap:32px;padding-bottom:4px;">
            ${cfg.venue ? `
            <div style="text-align:center;">
              <div style="font-size:14px;opacity:0.5;letter-spacing:2px;text-transform:uppercase;margin-bottom:2px;">Location</div>
              <div style="font-size:18px;font-weight:800;color:#f5d442;">${this.escapeHtml(cfg.venue)}</div>
            </div>` : ''}
            ${cfg.venue && cfg.team ? `<div style="width:1px;height:48px;background:rgba(255,255,255,0.25);"></div>` : ''}
            ${cfg.team ? `
            <div style="text-align:center;">
              <div style="font-size:14px;opacity:0.5;letter-spacing:2px;text-transform:uppercase;margin-bottom:2px;">Team</div>
              <div style="font-size:22px;font-weight:800;color:#f5d442;">${this.escapeHtml(cfg.team)}</div>
            </div>` : ''}
          </div>` : ''}

        </div>
      </div>
    `;
  }

  u23WomensFlyerHTML() {
    return this.renderFlyerHTML({
      badge: "⚽ CASA U23 Women's Premier League",
      eyebrow: 'Now Forming',
      title: 'U23',
      subtitle: "Women's Team",
      pills: [
        { icon: '📅', label: 'First Match', value: 'May 31, 2026' },
        { icon: '🏆', label: 'League', value: "CASA U23 Women's Premier" },
        { icon: '📍', label: 'Location', value: 'Philadelphia, PA' },
        { icon: '🎯', label: 'Eligibility', value: 'Ages 16–25 Welcome' },
      ],
      banner: "🌟 Open to All Players — Spots Available!",
      link: 'https://tr.ee/hSxfHUV4jR',
      qrCaption: 'Scan to Fill Out the Interest Form',
      venue: 'The Lighthouse Sports & Entertainment Complex',
      team: "Lighthouse Women's Club U23",
    });
  }

  // Two-QR layout — one QR per registration link, each linking straight to
  // its LeagueApps registration page. Shared by the youth (Boys/Girls) and
  // adult (Men's/Women's) flyers below. Distinct from renderFlyerHTML(),
  // which only supports a single link/QR block.
  twoQrFlyerHTML({ title, boxes, venue }) {
    const qr = (link) => 'https://api.qrserver.com/v1/create-qr-code/?size=260x260&data=' + encodeURIComponent(link) + '&format=png';
    return `
      <div style="
        width:1080px;height:1080px;position:relative;overflow:hidden;
        background:linear-gradient(160deg,#1565C0 0%,#0a1628 55%,#0D47A1 100%);
        color:white;font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif;
        box-sizing:border-box;
      ">
        <div style="position:absolute;top:0;left:0;right:0;bottom:0;opacity:0.04;
          background-image:radial-gradient(#ffffff 1px,transparent 1px);
          background-size:28px 28px;pointer-events:none;"></div>
        <div style="position:absolute;top:-60px;right:-60px;width:450px;height:450px;
          opacity:0.1;border-radius:50%;
          background:radial-gradient(circle,#ffffff 0%,transparent 70%);
          pointer-events:none;"></div>
        <div style="position:absolute;top:0;left:0;right:0;height:10px;
          background:linear-gradient(90deg,#1565C0,#f5d442,#0D47A1);"></div>
        <div style="position:absolute;bottom:0;left:0;right:0;height:6px;
          background:linear-gradient(90deg,#1565C0,#f5d442,#0D47A1);"></div>

        <div style="position:absolute;top:0;left:0;right:0;bottom:0;
          display:flex;flex-direction:column;align-items:center;justify-content:space-between;
          padding:48px 60px;">

          <div style="background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.25);
            border-radius:40px;padding:10px 30px;
            font-size:22px;font-weight:700;letter-spacing:3px;text-transform:uppercase;
            color:#f5d442;">
            ⚽ Lighthouse 1893
          </div>

          <div style="font-size:62px;font-weight:900;letter-spacing:2px;text-transform:uppercase;
            text-shadow:0 6px 20px rgba(0,0,0,0.7);color:white;line-height:1.15;text-align:center;">
            ${this.escapeHtml(title)}
          </div>

          <div style="display:flex;gap:28px;width:100%;justify-content:center;">
            ${boxes.map(b => `
            <div style="flex:1;background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.2);
              border-radius:18px;padding:26px;display:flex;flex-direction:column;align-items:center;gap:14px;">
              <div style="font-size:27px;font-weight:800;letter-spacing:0.5px;text-align:center;color:#f5d442;">
                ${this.escapeHtml(b.label)}
              </div>
              <img src="${qr(b.link)}" width="240" height="240"
                   style="background:white;padding:10px;border-radius:10px;" crossorigin="anonymous">
              <div style="font-size:18px;font-weight:700;">📲 Scan to Register</div>
              <div style="font-size:14px;opacity:0.65;">${this.escapeHtml(b.cost)}</div>
            </div>
            `).join('')}
          </div>

          <div style="text-align:center;">
            <div style="font-size:14px;opacity:0.5;letter-spacing:2px;text-transform:uppercase;margin-bottom:2px;">Location</div>
            <div style="font-size:18px;font-weight:800;color:#f5d442;">${this.escapeHtml(venue)}</div>
          </div>

        </div>
      </div>
    `;
  }

  youthClubsFlyerHTML() {
    const links = window.LighthouseProgramInfo.REGISTER_LINKS;
    const feeLabel = window.LighthouseProgramInfo.buildProgramDescription({ isYouth: true }).feeLabel;
    return this.twoQrFlyerHTML({
      title: 'Youth Soccer at Lighthouse',
      boxes: [
        { label: 'Lighthouse Boys Club', link: links.boys, cost: feeLabel },
        { label: 'Lighthouse Girls Club', link: links.girls, cost: feeLabel },
      ],
      venue: 'The Lighthouse Sports & Entertainment Complex',
    });
  }

  adultClubsFlyerHTML() {
    const links = window.LighthouseProgramInfo.REGISTER_LINKS;
    const mensFeeLabel = window.LighthouseProgramInfo.buildProgramDescription({ isMensClub: true }).feeLabel;
    const womensFeeLabel = window.LighthouseProgramInfo.buildProgramDescription({ isWomensClub: true }).feeLabel;
    return this.twoQrFlyerHTML({
      title: 'Adult Soccer at Lighthouse',
      boxes: [
        { label: "Lighthouse Men's Club", link: links.mens, cost: mensFeeLabel },
        { label: "Lighthouse Women's Club", link: links.womens, cost: womensFeeLabel },
      ],
      venue: 'The Lighthouse Sports & Entertainment Complex',
    });
  }

  async downloadCurrentFlyer() {
    const btn = this.find('.download-flyer-btn');
    const originalHTML = btn.innerHTML;
    btn.innerHTML = '⏳ Generating...';
    btn.disabled = true;

    try {
      if (typeof html2canvas === 'undefined') {
        throw new Error('html2canvas library not loaded');
      }

      const element = this.find('#flyer-render-area').firstElementChild;
      const scaleWrap = this.find('#flyer-scale-wrap');
      const origTransform = scaleWrap.style.transform;
      const origMargin = scaleWrap.style.marginBottom;

      scaleWrap.style.transform = 'none';
      scaleWrap.style.marginBottom = '0';

      // Allow styles to apply and QR image to finish loading
      await new Promise(resolve => setTimeout(resolve, 300));

      const canvas = await html2canvas(element, {
        scale: 1,
        useCORS: true,
        allowTaint: false,
        backgroundColor: null,
        width: 1080,
        height: 1080,
      });

      scaleWrap.style.transform = origTransform;
      scaleWrap.style.marginBottom = origMargin;

      const link = document.createElement('a');
      link.download = `${this.currentFlyerKey || 'flyer'}-${Date.now()}.png`;
      link.href = canvas.toDataURL('image/png');
      link.click();
    } catch (err) {
      console.error('Flyer download failed:', err);
      alert('Download failed. Please try again.');
    } finally {
      btn.innerHTML = originalHTML;
      btn.disabled = false;
    }
  }
}
