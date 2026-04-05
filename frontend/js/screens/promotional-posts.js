// PromotionalPostsScreen - Custom promotional posts with Lighthouse branding for Instagram
class PromotionalPostsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.dbPosts = {};       // keyed by id
    this.imageDataUrls = {};
  }

  getPromos() {
    return [
      {
        title: 'Travel Team Registration',
        heading: 'SPOTS AVAILABLE',
        subheading: 'Travel Teams 2026-27',
        bodyLines: [
          'U13 Boys & Girls',
          'U15 Boys & Girls',
          'U19 Boys & Girls',
        ],
        footer: 'Inter County Soccer League',
        caption: "A few spots remaining for U13, U15 & U19 Boys & Girls Lighthouse Travel teams.\n\nInter County Soccer League\n\n#Lighthouse1893 #PhillySoccer #TravelSoccer #YouthSoccer #ICSL"
      }
    ];
  }

  render() {
    const div = document.createElement('div');
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>📢 Promotional Posts</h1>
        <p class="subtitle">Lighthouse 1893 Instagram promotional posts</p>
      </div>
      <div id="promo-list" style="padding: var(--space-4); max-width: 800px; margin: 0 auto;">
        <div class="loading-state"><div class="spinner"></div><p>Loading...</p></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const publishBtn = e.target.closest('.publish-btn');
      if (publishBtn) {
        const idx = parseInt(publishBtn.dataset.idx);
        this.publishPromo(idx);
      }
    });
    this.loadAndRender();
  }

  async loadAndRender() {
    try {
      const response = await this.auth.fetch('/api/social/promos');
      if (response.ok) {
        const result = await response.json();
        if (result.success && result.data) {
          this.dbPosts = {};
          result.data.forEach(p => { this.dbPosts[p.title] = p; });
        }
      }
    } catch (e) {
      console.error('Failed to load promo posts:', e);
    }
    this.renderList();
  }

  renderList() {
    const container = this.find('#promo-list');
    if (!container) return;

    const promos = this.getPromos();

    container.innerHTML = promos.map((p, i) => {
      const dbPost = this.dbPosts[p.title];
      const isPosted = dbPost && dbPost.status === 'posted';
      const isError = dbPost && dbPost.status === 'error';

      let statusBadge = '';
      if (isPosted) {
        statusBadge = `<span style="background:#4CAF50;color:white;padding:2px 10px;border-radius:12px;font-size:0.8rem;">✅ POSTED</span>`;
      } else if (isError) {
        statusBadge = `<span style="background:#f44336;color:white;padding:2px 10px;border-radius:12px;font-size:0.8rem;">⚠️ ERROR</span>`;
      }

      return `
        <div class="card" style="padding: var(--space-3); margin-bottom: var(--space-3);">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
            <div>
              <span style="font-size: 1.5rem; margin-right: 8px;">📢</span>
              <strong style="font-size: 1.1rem;">${p.title}</strong>
            </div>
            ${statusBadge}
          </div>

          <div id="preview-${i}" style="text-align: center; margin-bottom: 12px;">
            <img id="img-${i}" style="max-width: 100%; height: auto; border-radius: 8px; border: 2px solid var(--border-color);">
          </div>

          <details style="margin-bottom: 12px;">
            <summary style="cursor: pointer; font-weight: 600; opacity: 0.8;">📝 Caption</summary>
            <p style="white-space: pre-wrap; opacity: 0.85; margin-top: 8px; padding: 12px; background: var(--bg-secondary); border-radius: 8px; font-size: 0.9rem;">${p.caption}</p>
          </details>

          ${isError && dbPost.error_message ? `<div style="color: #f44336; font-size: 0.85rem; margin-bottom: 8px;">⚠️ ${dbPost.error_message}</div>` : ''}

          <div style="display: flex; gap: 8px; align-items: center;">
            ${isPosted
              ? `<span style="color: #4CAF50; font-weight: 600;">✅ Published${dbPost.posted_at ? ' ' + new Date(dbPost.posted_at).toLocaleDateString() : ''}</span>`
              : `<button class="btn btn-primary publish-btn" data-idx="${i}" style="padding: 10px 20px;">🚀 Post to Instagram</button>`
            }
          </div>
        </div>
      `;
    }).join('');

    // Generate card images
    promos.forEach((p, i) => this.drawPromoCard(i, p));

    // Pre-load logos for card rendering
    const logosToLoad = [
      { key: 'logoImg', src: '/images/teams/logos/lighthouse-1893.png' },
      { key: 'icslLogo', src: '/images/leagues/icsl.png' },
      { key: 'epysaLogo', src: '/images/leagues/epysa.png' },
      { key: 'sponsorLogo', src: '/images/sponsors/welovejunk.png' }
    ];
    let pending = 0;
    logosToLoad.forEach(({ key, src }) => {
      if (!this[key]) {
        pending++;
        const img = new Image();
        img.onload = () => {
          this[key] = img;
          pending--;
          if (pending === 0) promos.forEach((p, i) => this.drawPromoCard(i, p));
        };
        img.onerror = () => { pending--; };
        img.src = src;
      }
    });
  }

  drawPromoCard(index, promo) {
    const scale = 2;
    const canvas = document.createElement('canvas');
    canvas.width = 1080 * scale;
    canvas.height = 1080 * scale;
    const ctx = canvas.getContext('2d');
    ctx.scale(scale, scale);
    const w = 1080, h = 1080;

    const gold = '#f5d442';
    const white = '#ffffff';

    // --- Deep blue gradient background (matches match day cards) ---
    const bgGrad = ctx.createLinearGradient(0, 0, w * 0.6, h);
    bgGrad.addColorStop(0, '#0033a0');
    bgGrad.addColorStop(0.3, '#003fbf');
    bgGrad.addColorStop(0.55, '#0044cc');
    bgGrad.addColorStop(1, '#002080');
    ctx.fillStyle = bgGrad;
    ctx.fillRect(0, 0, w, h);

    // Subtle radial glow in center for depth
    const glowGrad = ctx.createRadialGradient(w / 2, h * 0.4, 50, w / 2, h * 0.4, 500);
    glowGrad.addColorStop(0, 'rgba(0, 100, 255, 0.15)');
    glowGrad.addColorStop(1, 'rgba(0, 0, 0, 0)');
    ctx.fillStyle = glowGrad;
    ctx.fillRect(0, 0, w, h);

    // --- Gold border ---
    ctx.strokeStyle = gold;
    ctx.lineWidth = 8;
    ctx.strokeRect(24, 24, w - 48, h - 48);

    // Inner thin border
    ctx.strokeStyle = 'rgba(245, 212, 66, 0.3)';
    ctx.lineWidth = 1;
    ctx.strokeRect(40, 40, w - 80, h - 80);

    ctx.textAlign = 'center';

    // --- Top section ---
    // "LIGHTHOUSE 1893" header
    ctx.fillStyle = gold;
    ctx.font = '700 18px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.letterSpacing = '6px';
    ctx.fillText('L I G H T H O U S E   1 8 9 3', w / 2, 90);

    // Thin gold divider
    const divY = 115;
    ctx.strokeStyle = gold;
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(w * 0.25, divY);
    ctx.lineTo(w * 0.75, divY);
    ctx.stroke();

    // Small soccer ball
    ctx.font = '28px sans-serif';
    ctx.fillStyle = white;
    ctx.fillText('⚽', w / 2, divY + 6);

    // Gold dot accents on divider
    ctx.fillStyle = gold;
    ctx.beginPath();
    ctx.arc(w * 0.25, divY, 3, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(w * 0.75, divY, 3, 0, Math.PI * 2);
    ctx.fill();

    // --- Main heading ---
    ctx.fillStyle = white;
    ctx.font = '800 72px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText(promo.heading, w / 2, 220);

    // Gold underline accent
    ctx.strokeStyle = gold;
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.moveTo(w / 2 - 140, 242);
    ctx.lineTo(w / 2 + 140, 242);
    ctx.stroke();

    // Subheading
    ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
    ctx.font = '600 32px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText(promo.subheading, w / 2, 295);

    // --- Age group pills ---
    const pillStartY = 370;
    const pillH = 64;
    const pillGap = 20;
    const pillW = 520;

    promo.bodyLines.forEach((line, i) => {
      const py = pillStartY + i * (pillH + pillGap);

      // Pill background - semi-transparent white
      const pillRadius = pillH / 2;
      ctx.fillStyle = 'rgba(255, 255, 255, 0.1)';
      ctx.beginPath();
      ctx.roundRect(w / 2 - pillW / 2, py, pillW, pillH, pillRadius);
      ctx.fill();

      // Pill border
      ctx.strokeStyle = 'rgba(245, 212, 66, 0.4)';
      ctx.lineWidth = 1.5;
      ctx.beginPath();
      ctx.roundRect(w / 2 - pillW / 2, py, pillW, pillH, pillRadius);
      ctx.stroke();

      // Pill text
      ctx.fillStyle = white;
      ctx.font = '700 30px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.fillText(line, w / 2, py + pillH / 2 + 10);
    });

    // --- Footer league name ---
    const leagueY = pillStartY + promo.bodyLines.length * (pillH + pillGap) + 50;
    ctx.fillStyle = gold;
    ctx.font = '600 28px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText(promo.footer, w / 2, leagueY);

    // --- "Registration & interest form in bio" CTA ---
    ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
    ctx.font = '600 24px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText('Registration & interest form in bio', w / 2, leagueY + 45);

    // --- Three logos row: ICSL | Lighthouse | EPYSA ---
    const logoY = h - 330;
    const centerLogoSize = 60;
    const sideLogoH = 40;
    const logoGap = 16;

    // Lighthouse club logo (center)
    if (this.logoImg) {
      ctx.drawImage(this.logoImg, w / 2 - centerLogoSize / 2, logoY, centerLogoSize, centerLogoSize);
    }

    // ICSL logo (left of center)
    if (this.icslLogo) {
      const aspect = this.icslLogo.width / this.icslLogo.height;
      const icslW = sideLogoH * aspect;
      const icslX = w / 2 - centerLogoSize / 2 - logoGap - icslW;
      const icslY = logoY + (centerLogoSize - sideLogoH) / 2;
      ctx.drawImage(this.icslLogo, icslX, icslY, icslW, sideLogoH);
    }

    // EPYSA logo (right of center)
    if (this.epysaLogo) {
      const aspect = this.epysaLogo.width / this.epysaLogo.height;
      const epysaW = sideLogoH * aspect;
      const epysaX = w / 2 + centerLogoSize / 2 + logoGap;
      const epysaY = logoY + (centerLogoSize - sideLogoH) / 2;
      ctx.drawImage(this.epysaLogo, epysaX, epysaY, epysaW, sideLogoH);
    }

    // --- "LIGHTHOUSE 1893 ⚽ CLUB" ---
    ctx.fillStyle = gold;
    ctx.font = '700 16px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText('LIGHTHOUSE 1893 ⚽ CLUB', w / 2, h - 245);

    // --- Sponsor: We Love Junk ---
    if (this.sponsorLogo) {
      const spH = 140;
      const spAspect = this.sponsorLogo.width / this.sponsorLogo.height;
      const spW = spH * spAspect;
      ctx.drawImage(this.sponsorLogo, w / 2 - spW / 2, h - 220, spW, spH);
      ctx.fillStyle = 'rgba(255, 255, 255, 0.85)';
      ctx.font = '600 22px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.fillText('Sponsored by We Love Junk Philly', w / 2, h - 50);
    }

    // Finalize
    const dataUrl = canvas.toDataURL('image/jpeg', 0.92);
    this.imageDataUrls[index] = dataUrl;
    const img = this.find(`#img-${index}`);
    if (img) img.src = dataUrl;
  }



  async publishPromo(index) {
    const promos = this.getPromos();
    const p = promos[index];
    if (!confirm(`Post "${p.title}" to Instagram now?`)) return;

    const btn = this.element.querySelector(`.publish-btn[data-idx="${index}"]`);
    if (btn) { btn.disabled = true; btn.textContent = '⏳ Saving...'; }

    try {
      // 1. Save to DB
      const dbPost = this.dbPosts[p.title];
      const saveBody = { title: p.title, caption: p.caption };
      if (dbPost) saveBody.id = String(dbPost.id);

      const saveResp = await this.auth.fetch('/api/social/promos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(saveBody)
      });
      if (!saveResp.ok) throw new Error(`Save HTTP ${saveResp.status}`);
      const saveResult = await saveResp.json();
      if (!saveResult.success) throw new Error(saveResult.message || 'Save failed');
      const postId = saveResult.data.id;

      if (btn) btn.textContent = '⏳ Uploading image...';

      // 2. Upload the generated image
      const dataUrl = this.imageDataUrls[index] || '';
      if (!dataUrl) throw new Error('Image not ready yet — please wait a moment and try again');
      const uploadResp = await this.auth.fetch(`/api/social/promos/${postId}/media`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ data: dataUrl })
      });
      if (!uploadResp.ok) throw new Error(`Upload HTTP ${uploadResp.status}`);
      const uploadResult = await uploadResp.json();
      if (!uploadResult.success) throw new Error(uploadResult.message || 'Upload failed');

      if (btn) btn.textContent = '⏳ Publishing...';

      // 3. Publish to Instagram
      const pubResp = await this.auth.fetch(`/api/social/promos/${postId}/publish`, {
        method: 'POST'
      });
      if (!pubResp.ok) throw new Error(`Publish HTTP ${pubResp.status}`);
      const pubResult = await pubResp.json();
      if (!pubResult.success) throw new Error(pubResult.message || 'Publish failed');

      alert('✅ Posted to Instagram!');
      await this.loadAndRender();
    } catch (error) {
      alert('Error: ' + error.message);
      await this.loadAndRender();
    }
  }
}
