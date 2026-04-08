// PromotionalPostsScreen - Custom promotional posts with Lighthouse branding for Instagram
class PromotionalPostsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.posts = [];         // array from DB
    this.imageDataUrls = {};
    this.editing = null;     // post object being edited/created, or null
    this.loadLogos();
  }

  getDefaultPromo() {
    return {
      title: '',
      heading: '',
      subheading: '',
      body_lines: '',
      footer: '',
      caption: '',
    };
  }

  render() {
    const div = document.createElement('div');
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>📢 Promotional Posts</h1>
        <p class="subtitle">Lighthouse 1893 Instagram promotional posts</p>
      </div>
      <div id="promo-area" style="padding: var(--space-4); max-width: 800px; margin: 0 auto;">
        <div class="loading-state"><div class="spinner"></div><p>Loading...</p></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        if (this.editing) { this.editing = null; this.renderArea(); }
        else this.navigation.goBack();
        return;
      }
      const createBtn = e.target.closest('.create-btn');
      if (createBtn) { this.editing = this.getDefaultPromo(); this.renderArea(); return; }

      const editBtn = e.target.closest('.edit-btn');
      if (editBtn) {
        const id = parseInt(editBtn.dataset.id);
        const post = this.posts.find(p => p.id === id);
        if (post) { this.editing = { ...post }; this.renderArea(); }
        return;
      }

      const publishBtn = e.target.closest('.publish-btn');
      if (publishBtn) { this.publishPromo(parseInt(publishBtn.dataset.id)); return; }

      const scheduleBtn = e.target.closest('.schedule-btn');
      if (scheduleBtn) { this.schedulePromo(parseInt(scheduleBtn.dataset.id)); return; }

      const cancelBtn = e.target.closest('.cancel-schedule-btn');
      if (cancelBtn) { this.cancelSchedule(parseInt(cancelBtn.dataset.id)); return; }
    });
    this.loadAndRender();
  }

  async loadAndRender() {
    try {
      const response = await this.auth.fetch('/api/social/promos');
      if (response.ok) {
        const result = await response.json();
        if (result.success && result.data) {
          this.posts = result.data;
        }
      }
    } catch (e) {
      console.error('Failed to load promo posts:', e);
    }
    this.renderArea();
  }

  renderArea() {
    const area = this.find('#promo-area');
    if (!area) return;

    if (this.editing) {
      this.renderForm(area);
    } else {
      this.renderList(area);
    }
  }

  renderForm(container) {
    const p = this.editing;
    const isNew = !p.id;
    container.innerHTML = `
      <div class="card" style="padding:var(--space-3);margin-bottom:var(--space-3);">
        <h2 style="margin-bottom:16px;">${isNew ? '➕ New Promo Post' : '✏️ Edit Promo Post'}</h2>

        <div style="display:grid;gap:12px;margin-bottom:16px;">
          <div>
            <label style="display:block;font-weight:600;margin-bottom:4px;">Title</label>
            <input type="text" id="promo-title" value="${this.esc(p.title)}" placeholder="e.g. Travel Team Registration" style="width:100%;padding:10px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-primary);color:inherit;font-size:1rem;">
          </div>
          <div>
            <label style="display:block;font-weight:600;margin-bottom:4px;">Heading <span style="opacity:0.5;font-weight:400;">(large text on card)</span></label>
            <input type="text" id="promo-heading" value="${this.esc(p.heading || '')}" placeholder="e.g. SPOTS AVAILABLE" style="width:100%;padding:10px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-primary);color:inherit;font-size:1rem;">
          </div>
          <div>
            <label style="display:block;font-weight:600;margin-bottom:4px;">Subheading</label>
            <input type="text" id="promo-subheading" value="${this.esc(p.subheading || '')}" placeholder="e.g. Travel Teams 2026-27" style="width:100%;padding:10px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-primary);color:inherit;font-size:1rem;">
          </div>
          <div>
            <label style="display:block;font-weight:600;margin-bottom:4px;">Body Lines <span style="opacity:0.5;font-weight:400;">(one per line — appear as pills on card)</span></label>
            <textarea id="promo-bodylines" rows="4" placeholder="U13 Boys & Girls&#10;U15 Boys & Girls&#10;U19 Boys & Girls" style="width:100%;padding:10px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-primary);color:inherit;font-size:1rem;resize:vertical;">${this.esc(p.body_lines || '')}</textarea>
          </div>
          <div>
            <label style="display:block;font-weight:600;margin-bottom:4px;">Footer Line</label>
            <input type="text" id="promo-footer" value="${this.esc(p.footer || '')}" placeholder="e.g. Inter County Soccer League" style="width:100%;padding:10px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-primary);color:inherit;font-size:1rem;">
          </div>
          <div>
            <label style="display:block;font-weight:600;margin-bottom:4px;">Instagram Caption</label>
            <textarea id="promo-caption" rows="4" placeholder="Caption text + hashtags..." style="width:100%;padding:10px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-primary);color:inherit;font-size:1rem;resize:vertical;">${this.esc(p.caption || '')}</textarea>
          </div>
        </div>

        <div style="margin-bottom:16px;">
          <label style="display:block;font-weight:600;margin-bottom:8px;">Preview</label>
          <div id="promo-preview" style="text-align:center;">
            <canvas id="promo-canvas" style="max-width:100%;height:auto;border-radius:8px;border:2px solid var(--border-color);"></canvas>
          </div>
        </div>

        <div style="display:flex;flex-wrap:wrap;gap:8px;">
          <button class="btn btn-primary" id="save-draft-btn">💾 Save Draft</button>
          <button class="btn btn-secondary" id="preview-btn">🔄 Update Preview</button>
          <button class="btn btn-secondary" style="margin-left:auto;" id="cancel-edit-btn">Cancel</button>
        </div>
      </div>
    `;

    // Wire up buttons
    this.find('#preview-btn')?.addEventListener('click', () => this.updateFormPreview());
    this.find('#cancel-edit-btn')?.addEventListener('click', () => { this.editing = null; this.renderArea(); });
    this.find('#save-draft-btn')?.addEventListener('click', () => this.saveDraft());

    // Initial preview
    this.updateFormPreview();
  }

  getFormData() {
    return {
      title: (this.find('#promo-title')?.value || '').trim(),
      heading: (this.find('#promo-heading')?.value || '').trim(),
      subheading: (this.find('#promo-subheading')?.value || '').trim(),
      body_lines: (this.find('#promo-bodylines')?.value || '').trim(),
      footer: (this.find('#promo-footer')?.value || '').trim(),
      caption: (this.find('#promo-caption')?.value || '').trim(),
    };
  }

  updateFormPreview() {
    const canvas = this.find('#promo-canvas');
    if (!canvas) return;
    const data = this.getFormData();
    const promo = {
      heading: data.heading || 'HEADING',
      subheading: data.subheading || 'Subheading',
      bodyLines: data.body_lines ? data.body_lines.split('\n').filter(l => l.trim()) : [],
      footer: data.footer || '',
    };
    this.drawPromoCardOnCanvas(canvas, promo);
  }

  esc(str) {
    return (str || '').replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  async saveDraft() {
    const data = this.getFormData();
    if (!data.title) { alert('Please enter a title.'); return; }

    const btn = this.find('#save-draft-btn');
    if (btn) { btn.disabled = true; btn.textContent = '⏳ Saving...'; }

    try {
      const saveBody = {
        title: data.title,
        caption: data.caption,
        status: 'draft',
        heading: data.heading,
        subheading: data.subheading,
        body_lines: data.body_lines,
        footer: data.footer,
      };
      if (this.editing.id) saveBody.id = String(this.editing.id);

      const saveResp = await this.auth.fetch('/api/social/promos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(saveBody)
      });
      if (!saveResp.ok) throw new Error(`Save HTTP ${saveResp.status}`);
      const saveResult = await saveResp.json();
      if (!saveResult.success) throw new Error(saveResult.message || 'Save failed');

      // Also upload the card image
      const canvas = this.find('#promo-canvas');
      if (canvas) {
        const dataUrl = canvas.toDataURL('image/jpeg', 0.92);
        const postId = saveResult.data.id;
        await this.auth.fetch(`/api/social/promos/${postId}/media`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ data: dataUrl })
        });
      }

      this.editing = null;
      await this.loadAndRender();
    } catch (error) {
      alert('Error: ' + error.message);
      if (btn) { btn.disabled = false; btn.textContent = '💾 Save Draft'; }
    }
  }

  renderList(container) {
    const posts = this.posts;

    let html = `
      <div style="margin-bottom:16px;">
        <button class="btn btn-primary create-btn" style="padding:10px 20px;">➕ Create New Promo</button>
      </div>
    `;

    if (posts.length === 0) {
      html += `<p style="opacity:0.6;text-align:center;padding:40px 0;">No promotional posts yet. Create your first one!</p>`;
    }

    html += posts.map(p => {
      const isPosted = p.status === 'posted';
      const isError = p.status === 'error';
      const isScheduled = p.status === 'scheduled';
      const isPublishing = p.status === 'publishing';

      let statusBadge = '';
      if (isPosted) {
        statusBadge = `<span style="background:#4CAF50;color:white;padding:2px 10px;border-radius:12px;font-size:0.8rem;">✅ POSTED</span>`;
      } else if (isScheduled) {
        const when = p.scheduled_at ? new Date(p.scheduled_at).toLocaleString() : '';
        statusBadge = `<span style="background:#FF9800;color:white;padding:2px 10px;border-radius:12px;font-size:0.8rem;">⏰ SCHEDULED${when ? ' — ' + when : ''}</span>`;
      } else if (isPublishing) {
        statusBadge = `<span style="background:#2196F3;color:white;padding:2px 10px;border-radius:12px;font-size:0.8rem;">⏳ PUBLISHING</span>`;
      } else if (isError) {
        statusBadge = `<span style="background:#f44336;color:white;padding:2px 10px;border-radius:12px;font-size:0.8rem;">⚠️ ERROR</span>`;
      } else {
        statusBadge = `<span style="background:var(--bg-secondary);padding:2px 10px;border-radius:12px;font-size:0.8rem;">📝 DRAFT</span>`;
      }

      return `
        <div class="card" style="padding: var(--space-3); margin-bottom: var(--space-3);">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
            <div>
              <span style="font-size: 1.5rem; margin-right: 8px;">📢</span>
              <strong style="font-size: 1.1rem;">${this.esc(p.title)}</strong>
            </div>
            ${statusBadge}
          </div>

          ${p.image_url ? `<div style="text-align:center;margin-bottom:12px;"><img src="${this.esc(p.image_url)}" style="max-width:100%;height:auto;border-radius:8px;border:2px solid var(--border-color);"></div>` : ''}

          ${p.caption ? `
          <details style="margin-bottom: 12px;">
            <summary style="cursor: pointer; font-weight: 600; opacity: 0.8;">📝 Caption</summary>
            <p style="white-space: pre-wrap; opacity: 0.85; margin-top: 8px; padding: 12px; background: var(--bg-secondary); border-radius: 8px; font-size: 0.9rem;">${this.esc(p.caption)}</p>
          </details>` : ''}

          ${isError && p.error_message ? `<div style="color: #f44336; font-size: 0.85rem; margin-bottom: 8px;">⚠️ ${this.esc(p.error_message)}</div>` : ''}

          <div style="display: flex; flex-direction: column; gap: 10px;">
            ${isPosted
              ? `<span style="color: #4CAF50; font-weight: 600;">✅ Published${p.posted_at ? ' ' + new Date(p.posted_at).toLocaleDateString() : ''}</span>`
              : isScheduled
                ? `<div style="display:flex;gap:8px;align-items:center;">
                    <span style="color:#FF9800;font-weight:600;">⏰ Scheduled</span>
                    <button class="btn btn-secondary cancel-schedule-btn" data-id="${p.id}" style="padding:6px 14px;font-size:0.85rem;">Cancel</button>
                  </div>`
                : isPublishing
                  ? `<span style="color:#2196F3;font-weight:600;">⏳ Publishing to Instagram...</span>`
                  : `<div style="display:flex;flex-wrap:wrap;gap:8px;align-items:center;">
                      <button class="btn btn-secondary edit-btn" data-id="${p.id}" style="padding:8px 14px;">✏️ Edit</button>
                      ${p.image_url ? `<button class="btn btn-primary publish-btn" data-id="${p.id}" style="padding: 10px 20px;">🚀 Post Now</button>` : ''}
                      ${p.image_url ? `<div style="display:flex;align-items:center;gap:6px;">
                        <input type="datetime-local" id="schedule-time-${p.id}" style="padding:8px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-primary);color:inherit;font-size:0.85rem;">
                        <button class="btn btn-secondary schedule-btn" data-id="${p.id}" style="padding:8px 14px;">⏰ Schedule</button>
                      </div>` : '<span style="opacity:0.5;font-size:0.85rem;">Save draft to generate image first</span>'}
                    </div>`
            }
          </div>
        </div>
      `;
    }).join('');

    container.innerHTML = html;
  }

  drawPromoCardOnCanvas(canvas, promo) {
    const scale = 2;
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
  }

  loadLogos() {
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
        img.onload = () => { this[key] = img; pending--; };
        img.onerror = () => { pending--; };
        img.src = src;
      }
    });
  }

  async publishPromo(postId) {
    const p = this.posts.find(x => x.id === postId);
    if (!p) return;
    if (!confirm(`Post "${p.title}" to Instagram now?`)) return;

    const btn = this.element.querySelector(`.publish-btn[data-id="${postId}"]`);
    if (btn) { btn.disabled = true; btn.textContent = '⏳ Publishing...'; }

    try {
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

  async schedulePromo(postId) {
    const p = this.posts.find(x => x.id === postId);
    if (!p) return;

    const input = this.find(`#schedule-time-${postId}`);
    if (!input || !input.value) {
      alert('Please pick a date and time first.');
      return;
    }

    const scheduledAt = new Date(input.value).toISOString();
    if (new Date(input.value) <= new Date()) {
      alert('Scheduled time must be in the future.');
      return;
    }

    const scheduleBtn = this.element.querySelector(`.schedule-btn[data-id="${postId}"]`);
    if (scheduleBtn) { scheduleBtn.disabled = true; scheduleBtn.textContent = '⏳ Saving...'; }

    try {
      const resp = await this.auth.fetch('/api/social/promos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: String(postId), title: p.title, caption: p.caption, status: 'scheduled', scheduled_at: scheduledAt })
      });
      if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
      const result = await resp.json();
      if (!result.success) throw new Error(result.message || 'Failed');

      alert('⏰ Scheduled for ' + new Date(scheduledAt).toLocaleString());
      await this.loadAndRender();
    } catch (error) {
      alert('Error: ' + error.message);
      await this.loadAndRender();
    }
  }

  async cancelSchedule(postId) {
    const p = this.posts.find(x => x.id === postId);
    if (!p) return;

    if (!confirm(`Cancel scheduled post "${p.title}"?`)) return;

    try {
      const resp = await this.auth.fetch('/api/social/promos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: String(postId), title: p.title, caption: p.caption, status: 'draft', scheduled_at: '' })
      });
      if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
      const result = await resp.json();
      if (!result.success) throw new Error(result.message || 'Failed');

      alert('Schedule cancelled.');
      await this.loadAndRender();
    } catch (error) {
      alert('Error: ' + error.message);
    }
  }
}
