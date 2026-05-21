// FlyersScreen — Generate printable recruitment flyers with QR codes for club admin
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

    this.renderFlyersList();

    this.element.addEventListener('click', e => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
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

  openFlyer(key) {
    this.currentFlyerKey = key;
    const renderArea = this.find('#flyer-render-area');
    renderArea.innerHTML = this.buildFlyerHTML(key);
    this.find('#flyer-preview-title').textContent = "U23 Women's Flyer Preview";
    this.find('#flyer-preview-area').style.display = 'block';
    this.find('#flyer-preview-area').scrollIntoView({ behavior: 'smooth' });
  }

  buildFlyerHTML(key) {
    if (key === 'u23-womens') return this.u23WomensFlyerHTML();
    return '';
  }

  u23WomensFlyerHTML() {
    const qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=' +
      encodeURIComponent('https://tr.ee/hSxfHUV4jR') + '&format=png';

    return `
      <div style="
        width:1080px;height:1080px;position:relative;overflow:hidden;
        background:linear-gradient(160deg,#1565C0 0%,#0a1628 55%,#0D47A1 100%);
        color:white;font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif;
        box-sizing:border-box;
      ">
        <!-- dot pattern -->
        <div style="position:absolute;top:0;left:0;right:0;bottom:0;opacity:0.04;
          background-image:radial-gradient(#ffffff 1px,transparent 1px);
          background-size:28px 28px;pointer-events:none;"></div>

        <!-- glow -->
        <div style="position:absolute;top:-60px;right:-60px;width:450px;height:450px;
          opacity:0.1;border-radius:50%;
          background:radial-gradient(circle,#ffffff 0%,transparent 70%);
          pointer-events:none;"></div>

        <!-- gold top bar -->
        <div style="position:absolute;top:0;left:0;right:0;height:10px;
          background:linear-gradient(90deg,#1565C0,#f5d442,#0D47A1);"></div>

        <!-- gold bottom bar -->
        <div style="position:absolute;bottom:0;left:0;right:0;height:6px;
          background:linear-gradient(90deg,#1565C0,#f5d442,#0D47A1);"></div>

        <!-- main content column -->
        <div style="position:absolute;top:0;left:0;right:0;bottom:0;
          display:flex;flex-direction:column;align-items:center;justify-content:space-between;
          padding:28px 60px;">

          <!-- CASA badge -->
          <div style="background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.25);
            border-radius:40px;padding:10px 30px;margin-top:12px;
            font-size:22px;font-weight:700;letter-spacing:3px;text-transform:uppercase;
            color:#f5d442;">
            ⚽ CASA U23 Women's Premier League
          </div>

          <!-- Title -->
          <div style="display:flex;flex-direction:column;align-items:center;gap:10px;">
            <div style="font-size:28px;font-weight:700;letter-spacing:6px;text-transform:uppercase;
              color:rgba(255,255,255,0.6);">Now Forming</div>
            <div style="font-size:84px;font-weight:900;letter-spacing:6px;text-transform:uppercase;
              text-shadow:0 6px 20px rgba(0,0,0,0.7);color:white;line-height:1;">U23</div>
            <div style="font-size:40px;font-weight:700;letter-spacing:5px;color:#f5d442;">Women's Team</div>
          </div>

          <!-- Info pills -->
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;width:100%;">
            <div style="background:rgba(255,255,255,0.09);border:1px solid rgba(255,255,255,0.18);
              border-radius:14px;padding:14px 18px;display:flex;align-items:center;gap:12px;
              font-size:23px;font-weight:500;">
              <span style="font-size:26px;flex-shrink:0;">📅</span>
              <span>
                <span style="font-size:14px;opacity:0.5;display:block;letter-spacing:1px;text-transform:uppercase;margin-bottom:2px;">First Match</span>
                May 31, 2026
              </span>
            </div>
            <div style="background:rgba(255,255,255,0.09);border:1px solid rgba(255,255,255,0.18);
              border-radius:14px;padding:14px 18px;display:flex;align-items:center;gap:12px;
              font-size:23px;font-weight:500;">
              <span style="font-size:26px;flex-shrink:0;">🏆</span>
              <span>
                <span style="font-size:14px;opacity:0.5;display:block;letter-spacing:1px;text-transform:uppercase;margin-bottom:2px;">League</span>
                CASA U23 Women's Premier
              </span>
            </div>
            <div style="background:rgba(255,255,255,0.09);border:1px solid rgba(255,255,255,0.18);
              border-radius:14px;padding:14px 18px;display:flex;align-items:center;gap:12px;
              font-size:23px;font-weight:500;">
              <span style="font-size:26px;flex-shrink:0;">📍</span>
              <span>
                <span style="font-size:14px;opacity:0.5;display:block;letter-spacing:1px;text-transform:uppercase;margin-bottom:2px;">Location</span>
                Philadelphia, PA
              </span>
            </div>
            <div style="background:rgba(255,255,255,0.09);border:1px solid rgba(255,255,255,0.18);
              border-radius:14px;padding:14px 18px;display:flex;align-items:center;gap:12px;
              font-size:23px;font-weight:500;">
              <span style="font-size:26px;flex-shrink:0;">🎯</span>
              <span>
                <span style="font-size:14px;opacity:0.5;display:block;letter-spacing:1px;text-transform:uppercase;margin-bottom:2px;">Eligibility</span>
                Ages 16–25 Welcome
              </span>
            </div>
          </div>

          <!-- Open to all banner -->
          <div style="background:rgba(255,255,255,0.1);border:2px solid #f5d442;
            border-radius:12px;padding:12px 40px;
            font-size:26px;font-weight:800;letter-spacing:4px;text-transform:uppercase;
            color:white;text-align:center;width:100%;">
            🌟 Open to All Players — Spots Available!
          </div>

          <!-- QR code section -->
          <div style="background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.2);
            border-radius:16px;padding:18px 36px;display:flex;align-items:center;gap:28px;width:100%;">
            <img src="${qrUrl}" width="220" height="220"
                 style="background:white;padding:10px;border-radius:10px;flex-shrink:0;"
                 crossorigin="anonymous">
            <div>
              <div style="font-size:26px;font-weight:800;margin-bottom:8px;">📲 Scan to Fill Out the Interest Form</div>
              <div style="font-size:20px;opacity:0.7;">Or visit: linktr.ee/Lighthouse1893Soccer</div>
              <div style="font-size:17px;opacity:0.5;margin-top:4px;">Free to join · All skill levels welcome</div>
            </div>
          </div>

          <!-- Sponsor row -->
          <div style="display:flex;align-items:center;justify-content:center;gap:32px;padding-bottom:4px;">
            <div style="text-align:center;">
              <div style="font-size:14px;opacity:0.5;letter-spacing:2px;text-transform:uppercase;margin-bottom:2px;">Sponsored By</div>
              <div style="font-size:22px;font-weight:800;color:#f5d442;">We Love Junk</div>
            </div>
            <div style="width:1px;height:48px;background:rgba(255,255,255,0.25);"></div>
            <div style="text-align:center;">
              <div style="font-size:14px;opacity:0.5;letter-spacing:2px;text-transform:uppercase;margin-bottom:2px;">Home Games At</div>
              <div style="font-size:18px;font-weight:800;color:#f5d442;">The Lighthouse Sports &amp; Entertainment Complex</div>
            </div>
            <div style="width:1px;height:48px;background:rgba(255,255,255,0.25);"></div>
            <div style="text-align:center;">
              <div style="font-size:14px;opacity:0.5;letter-spacing:2px;text-transform:uppercase;margin-bottom:2px;">Team</div>
              <div style="font-size:22px;font-weight:800;color:#f5d442;">Lighthouse Women's Club U23</div>
            </div>
          </div>

        </div>
      </div>
    `;
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
      link.download = `u23-womens-flyer-${Date.now()}.png`;
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
