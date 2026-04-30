// PromotionalPostsScreen - Custom promotional posts with Lighthouse branding for Instagram
class PromotionalPostsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.posts = [];         // array from DB
    this.imageDataUrls = {};
    this.editing = null;     // post object being edited/created, or null
    // Tic-tac-toe overlay positioning (same system as content posts)
    this.positions = ['tl','tc','tr','bl','bc','br'];
    this.positionLabels = { tl:'↖', tc:'↑', tr:'↗', bl:'↙', bc:'↓', br:'↘' };
    this.overlayOptions = [
      { key: 'lighthouse_graphic', label: 'Lighthouse + Beam', icon: '🏮', src: null, pos: 'br', isGraphic: true },
      { key: 'lighthouse', label: 'Lighthouse 1893 Logo', icon: '🏠', src: '/images/teams/logos/lighthouse-1893.png', pos: 'br' },
      { key: 'fifa', label: 'FIFA', icon: '🌍', src: '/images/leagues/fifa.png', pos: 'bl' },
      { key: 'concacaf', label: 'Concacaf', icon: '🌎', src: '/images/leagues/concacaf.png', pos: 'bl' },
      { key: 'ussoccer', label: 'US Soccer', icon: '🇺🇸', src: '/images/leagues/ussoccer.png', pos: 'bl' },
      { key: 'ussfr1', label: 'USSF Region 1', icon: '🇺🇸', src: '/images/leagues/ussf-region1.jpg', pos: 'bl' },
      { key: 'epsa', label: 'Eastern PA Soccer', icon: '⚽', src: '/images/leagues/epsa.png', pos: 'bl' },
      { key: 'epysa', label: 'EPYSA', icon: '🏅', src: '/images/leagues/epysa.png', pos: 'bl' },
      { key: 'apsl', label: 'APSL', icon: '⚽', src: '/images/leagues/apsl.png', pos: 'bl' },
      { key: 'tcwsl', label: 'Tri County WSL', icon: '⚽', src: '/images/leagues/tcwsl.png', pos: 'bl' },
      { key: 'casa', label: 'CASA', icon: '🏆', src: '/images/leagues/casa.png', pos: 'bl' },
      { key: 'icsl', label: 'Inter County SL', icon: '⚽', src: '/images/leagues/icsl.png', pos: 'bl' },
      { key: 'sponsor', label: 'We Love Junk', icon: '💰', src: '/images/sponsors/welovejunk.png', pos: null },
    ];
    this._defaultOverlayPositions = Object.fromEntries(this.overlayOptions.map(o => [o.key, o.pos]));
    this.currentFile = null;
    this.currentPreviewUrl = null;
    this.mediaType = 'card'; // 'card' or 'media'
    this.animFrameId = null;
    this.animStartTime = null;
    this.activeTab = 'all';
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
      overlay_logos: '',
      overlay_text: '',
    };
  }

  getSelectedOverlaysWithPositions() {
    return this.overlayOptions.filter(o => {
      const hidden = this.find(`#pos-${o.key}`);
      const pos = hidden ? hidden.value : o.pos;
      return pos && pos !== 'off';
    }).map(o => {
      const hidden = this.find(`#pos-${o.key}`);
      return { key: o.key, pos: hidden ? hidden.value : o.pos };
    });
  }

  applyOverlayPositionsFromString(str) {
    // Reset all to null
    this.overlayOptions.forEach(o => o.pos = null);
    if (!str) return;
    str.split(',').forEach(part => {
      const [key, pos] = part.split(':');
      const opt = this.overlayOptions.find(o => o.key === key);
      if (opt && pos && pos !== 'off') opt.pos = pos;
    });
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

  onLeave() {
    if (this.animFrameId) {
      cancelAnimationFrame(this.animFrameId);
      this.animFrameId = null;
    }
  }

  onEnter(params) {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        if (this.editing) { this.editing = null; this.renderArea(); }
        else this.navigation.goBack();
        return;
      }
      const createBtn = e.target.closest('.create-btn');
      if (createBtn) {
        this.overlayOptions.forEach(o => o.pos = this._defaultOverlayPositions[o.key] ?? null);
        this.editing = this.getDefaultPromo();
        this.renderArea();
        return;
      }

      const editBtn = e.target.closest('.edit-btn');
      if (editBtn) {
        const id = parseInt(editBtn.dataset.id);
        const post = this.posts.find(p => p.id === id);
        if (post) {
          this.editing = { ...post };
          this.applyOverlayPositionsFromString(post.overlay_logos || '');
          this.renderArea();
        }
        return;
      }

      const publishBtn = e.target.closest('.publish-btn');
      if (publishBtn) { this.publishPromo(parseInt(publishBtn.dataset.id)); return; }

      const scheduleBtn = e.target.closest('.schedule-btn');
      if (scheduleBtn) { this.schedulePromo(parseInt(scheduleBtn.dataset.id)); return; }

      const cancelBtn = e.target.closest('.cancel-schedule-btn');
      if (cancelBtn) { this.cancelSchedule(parseInt(cancelBtn.dataset.id)); return; }

      const tabBtn = e.target.closest('.promo-tab-btn');
      if (tabBtn) {
        this.activeTab = tabBtn.dataset.tab;
        this.renderArea();
        return;
      }

      const deleteBtn = e.target.closest('.delete-btn');
      if (deleteBtn) { this.deletePromo(parseInt(deleteBtn.dataset.id)); return; }
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
    const isMedia = this.mediaType === 'media';
    container.innerHTML = `
      <div class="card" style="padding:var(--space-3);margin-bottom:var(--space-3);">
        <h2 style="margin-bottom:16px;">${isNew ? '➕ New Promo Post' : '✏️ Edit Promo Post'}</h2>

        <div style="margin-bottom:16px;">
          <label style="display:block;font-weight:600;margin-bottom:8px;">Post Type</label>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;">
            <button type="button" id="type-card-btn" class="btn" style="padding:14px;border-radius:8px;border:2px solid ${!isMedia ? 'var(--accent-color)' : 'var(--border-color)'};background:${!isMedia ? 'var(--accent-color)' : 'var(--bg-secondary)'};color:${!isMedia ? '#fff' : 'inherit'};cursor:pointer;font-weight:600;">
              🎨 Designed Card
            </button>
            <button type="button" id="type-media-btn" class="btn" style="padding:14px;border-radius:8px;border:2px solid ${isMedia ? 'var(--accent-color)' : 'var(--border-color)'};background:${isMedia ? 'var(--accent-color)' : 'var(--bg-secondary)'};color:${isMedia ? '#fff' : 'inherit'};cursor:pointer;font-weight:600;">
              📷 Photo / Video
            </button>
          </div>
        </div>

        <div style="display:grid;gap:12px;margin-bottom:16px;">
          <div>
            <label style="display:block;font-weight:600;margin-bottom:4px;">Title</label>
            <input type="text" id="promo-title" value="${this.esc(p.title)}" placeholder="e.g. Travel Team Registration" style="width:100%;padding:10px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-primary);color:inherit;font-size:1rem;">
          </div>

          <div id="card-fields" style="display:${isMedia ? 'none' : 'grid'};gap:12px;">
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
          </div>

          <div id="media-upload-section" style="display:${isMedia ? 'block' : 'none'};">
            <label style="display:block;font-weight:600;margin-bottom:6px;">Upload Photo or Video</label>
            <input type="file" id="promo-file" accept="image/*,video/*" style="display:none;">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;">
              <button id="promo-file-btn" class="btn btn-secondary" style="padding:24px;border:2px dashed var(--border-color);border-radius:8px;text-align:center;cursor:pointer;">
                📁 Choose from device
              </button>
              <button id="promo-drive-btn" class="btn btn-secondary" style="padding:24px;border:2px dashed var(--border-color);border-radius:8px;text-align:center;cursor:pointer;">
                📱 Browse Google Drive
              </button>
            </div>
            <div id="promo-file-name" style="margin-top:6px;font-size:0.85rem;opacity:0.7;"></div>
            <div id="promo-media-preview" style="display:none;margin-top:12px;text-align:center;"></div>
          </div>

          <div>
            <label style="display:block;font-weight:600;margin-bottom:4px;">Instagram Caption</label>
            <textarea id="promo-caption" rows="4" placeholder="Caption text + hashtags..." style="width:100%;padding:10px;border-radius:6px;border:1px solid var(--border-color);background:var(--bg-primary);color:inherit;font-size:1rem;resize:vertical;">${this.esc(p.caption || '')}</textarea>
          </div>
        </div>

        <div style="margin-bottom:16px;">
          <label style="display:block;font-weight:600;margin-bottom:8px;">Logo Overlays <span style="font-weight:400;font-size:0.8rem;opacity:0.6;">— tap a grid cell to place, tap again to remove</span></label>
          <div id="overlay-list" style="display:flex;flex-direction:column;gap:8px;">
            ${this.overlayOptions.map(o => `
              <div class="overlay-row" draggable="true" data-key="${o.key}" style="display:flex;align-items:center;gap:10px;padding:8px 12px;background:var(--bg-primary);border-radius:8px;border:1px solid var(--border-color);cursor:grab;">
                <span style="font-size:14px;opacity:0.4;flex-shrink:0;">⠿</span>
                ${o.src ? `<img src="${o.src}" style="height:28px;width:auto;max-width:60px;object-fit:contain;border-radius:4px;flex-shrink:0;">` : `<span style="font-size:20px;flex-shrink:0;">${o.icon}</span>`}
                <span style="font-size:0.9rem;flex:1;">${o.label}</span>
                <div style="display:grid;grid-template-columns:repeat(3,22px);grid-template-rows:repeat(2,22px);gap:2px;flex-shrink:0;">
                  ${this.positions.map(pos => `
                    <button type="button" class="pos-btn" data-key="${o.key}" data-pos="${pos}"
                      style="width:22px;height:22px;border:1px solid var(--border-color);border-radius:3px;font-size:10px;line-height:22px;text-align:center;cursor:pointer;padding:0;
                      background:${pos === o.pos ? 'var(--accent-color)' : 'var(--bg-secondary)'};color:${pos === o.pos ? '#fff' : 'inherit'};">
                      ${this.positionLabels[pos]}
                    </button>
                  `).join('')}
                </div>
                <input type="hidden" id="pos-${o.key}" value="${o.pos || 'off'}">
              </div>
            `).join('')}
          </div>
        </div>

        <div id="canvas-preview-section" style="margin-bottom:16px;display:${isMedia ? 'none' : 'block'};">
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
    this.find('#cancel-edit-btn')?.addEventListener('click', () => { this.editing = null; this.currentFile = null; this.currentPreviewUrl = null; this.mediaType = 'card'; this.renderArea(); });
    this.find('#save-draft-btn')?.addEventListener('click', () => this.saveDraft());

    // Wire up media type toggle
    this.find('#type-card-btn')?.addEventListener('click', () => {
      this.mediaType = 'card';
      this.renderForm(container);
    });
    this.find('#type-media-btn')?.addEventListener('click', () => {
      this.mediaType = 'media';
      this.renderForm(container);
    });

    // Wire up file picker and Drive browse (media mode)
    const fileBtn = this.find('#promo-file-btn');
    const fileInput = this.find('#promo-file');
    if (fileBtn && fileInput) {
      fileBtn.addEventListener('click', () => fileInput.click());
      fileInput.addEventListener('change', (e) => this.handleFileSelected(e));
    }
    const driveBtn = this.find('#promo-drive-btn');
    if (driveBtn) {
      driveBtn.addEventListener('click', () => this.openDriveGallery());
    }

    // Wire up drag-to-reorder overlay rows
    const overlayList = container.querySelector('#overlay-list');
    if (overlayList) {
      let dragSrc = null;
      overlayList.querySelectorAll('.overlay-row').forEach(row => {
        row.addEventListener('dragstart', (e) => {
          dragSrc = row;
          e.dataTransfer.effectAllowed = 'move';
          setTimeout(() => row.style.opacity = '0.4', 0);
        });
        row.addEventListener('dragend', () => { row.style.opacity = ''; });
        row.addEventListener('dragover', (e) => { e.preventDefault(); e.dataTransfer.dropEffect = 'move'; });
        row.addEventListener('dragenter', (e) => { e.preventDefault(); row.style.outline = '2px solid var(--accent-color)'; });
        row.addEventListener('dragleave', () => { row.style.outline = ''; });
        row.addEventListener('drop', (e) => {
          e.preventDefault();
          row.style.outline = '';
          if (dragSrc === row) return;
          const rows = [...overlayList.querySelectorAll('.overlay-row')];
          const srcIdx = rows.indexOf(dragSrc);
          const dstIdx = rows.indexOf(row);
          // Reorder overlayOptions array to match
          const [moved] = this.overlayOptions.splice(srcIdx, 1);
          this.overlayOptions.splice(dstIdx, 0, moved);
          // Save current pos values before re-render
          this.overlayOptions.forEach(o => {
            const h = container.querySelector(`#pos-${o.key}`);
            if (h) o.pos = h.value === 'off' ? null : h.value;
          });
          this.renderForm(container);
        });
      });
    }

    // Wire up tic-tac-toe position grid
    container.querySelectorAll('.pos-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const key = btn.dataset.key;
        const pos = btn.dataset.pos;
        const hidden = this.find(`#pos-${key}`);
        if (!hidden) return;
        const current = hidden.value;
        if (current === pos) {
          hidden.value = 'off';
        } else {
          hidden.value = pos;
        }
        const newVal = hidden.value;
        container.querySelectorAll(`.pos-btn[data-key="${key}"]`).forEach(b => {
          const active = b.dataset.pos === newVal;
          b.style.background = active ? 'var(--accent-color)' : 'var(--bg-secondary)';
          b.style.color = active ? '#fff' : 'inherit';
        });
        this.updateFormPreview();
      });
    });

    // Initial preview
    if (!isMedia) this.updateFormPreview();
    if (isMedia && this.currentFile) this.updateMediaPreview();
  }

  getFormData() {
    const overlaysWithPos = this.getSelectedOverlaysWithPositions();
    return {
      title: (this.find('#promo-title')?.value || '').trim(),
      heading: (this.find('#promo-heading')?.value || '').trim(),
      subheading: (this.find('#promo-subheading')?.value || '').trim(),
      body_lines: (this.find('#promo-bodylines')?.value || '').trim(),
      footer: (this.find('#promo-footer')?.value || '').trim(),
      caption: (this.find('#promo-caption')?.value || '').trim(),
      overlay_logos: overlaysWithPos.map(s => `${s.key}:${s.pos}`).join(','),
      overlay_text: '',
    };
  }

  updateFormPreview() {
    const canvas = this.find('#promo-canvas');
    if (!canvas) return;
    const data = this.getFormData();
    const overlaysWithPos = this.getSelectedOverlaysWithPositions();
    const promo = {
      heading: data.heading || 'HEADING',
      subheading: data.subheading || 'Subheading',
      bodyLines: data.body_lines ? data.body_lines.split('\n').filter(l => l.trim()) : [],
      footer: data.footer || '',
      overlays: overlaysWithPos,
      overlayText: data.overlay_text || '',
    };
    this.startPromoAnimation(canvas, promo);
  }

  esc(str) {
    return (str || '').replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  handleFileSelected(e) {
    const file = e.target.files[0];
    if (!file) return;
    this.currentFile = file;
    const nameEl = this.find('#promo-file-name');
    if (nameEl) nameEl.textContent = `${file.name} (${(file.size / 1024 / 1024).toFixed(1)} MB)`;
    this.updateMediaPreview();
  }

  updateMediaPreview() {
    const previewEl = this.find('#promo-media-preview');
    if (!previewEl || !this.currentFile) return;
    previewEl.style.display = 'block';

    if (this.currentPreviewUrl) URL.revokeObjectURL(this.currentPreviewUrl);
    this.currentPreviewUrl = URL.createObjectURL(this.currentFile);

    const isVideo = this.currentFile.type.startsWith('video/');
    const selectedWithPos = this.getSelectedOverlaysWithPositions();

    const regionStyles = {
      tl: 'top:6px;left:6px;', tc: 'top:6px;left:50%;transform:translateX(-50%);',
      tr: 'top:6px;right:6px;', bl: 'bottom:6px;left:6px;',
      bc: 'bottom:6px;left:50%;transform:translateX(-50%);', br: 'bottom:6px;right:6px;'
    };
    let overlayHtml = '';
    if (selectedWithPos.length > 0) {
      const regions = {};
      selectedWithPos.forEach(s => { if (!regions[s.pos]) regions[s.pos] = []; regions[s.pos].push(s.key); });
      for (const [pos, keys] of Object.entries(regions)) {
        const items = keys.map(key => {
          if (key === 'sponsor') {
            const opt = this.overlayOptions.find(o => o.key === 'sponsor');
            return `<div style="display:flex;align-items:center;gap:6px;"><div style="padding:1px 3px;background:rgba(65,105,225,0.9);border-radius:2px;"><span style="font-size:11px;color:#eee;text-transform:uppercase;letter-spacing:1.5px;font-weight:600;">Sponsored by</span></div><img src="${opt.src}" style="height:50px;object-fit:contain;filter:drop-shadow(0 0 4px rgba(0,0,0,0.7));"></div>`;
          }
          const opt = this.overlayOptions.find(o => o.key === key);
          return opt ? `<img src="${opt.src}" style="height:28px;object-fit:contain;filter:drop-shadow(0 0 3px rgba(0,0,0,0.6));" title="${opt.label}">` : '';
        }).join('');
        overlayHtml += `<div style="position:absolute;${regionStyles[pos]}display:flex;align-items:center;gap:6px;">${items}</div>`;
      }
    }

    if (isVideo) {
      previewEl.innerHTML = `<div style="display:inline-block;position:relative;max-width:400px;"><video src="${this.currentPreviewUrl}" controls muted style="max-width:100%;max-height:400px;display:block;border-radius:8px;"></video>${overlayHtml}</div>`;
    } else {
      previewEl.innerHTML = `<div style="display:inline-block;position:relative;max-width:400px;"><img src="${this.currentPreviewUrl}" style="max-width:100%;max-height:400px;display:block;border-radius:8px;">${overlayHtml}</div>`;
    }
  }

  renderImageWithOverlay(file, overlaysWithPos) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        canvas.width = img.width;
        canvas.height = img.height;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0);

        if (overlaysWithPos.length === 0) { resolve(canvas.toDataURL('image/jpeg', 0.92)); return; }

        const w = canvas.width, h = canvas.height;
        const margin = w * 0.02;
        const regions = {};
        overlaysWithPos.forEach(s => { if (!regions[s.pos]) regions[s.pos] = []; regions[s.pos].push(s.key); });

        const toLoad = [];
        overlaysWithPos.forEach(s => {
          const opt = this.overlayOptions.find(o => o.key === s.key);
          if (opt && opt.src) toLoad.push({ key: s.key, src: opt.src, pos: s.pos });
        });

        const drawAll = (loadedImages) => {
          for (const [pos, keys] of Object.entries(regions)) {
            let anchorX, anchorY, alignH, alignV;
            if (pos.startsWith('t')) anchorY = margin, alignV = 'top';
            else anchorY = h - margin, alignV = 'bottom';
            if (pos.endsWith('l')) anchorX = margin, alignH = 'left';
            else if (pos.endsWith('c')) anchorX = w / 2, alignH = 'center';
            else anchorX = w - margin, alignH = 'right';

            const items = [];
            const logoH = Math.max(40, h * 0.065);
            const fontSize = Math.max(14, Math.round(w * 0.028));
            const smallFont = Math.max(12, Math.round(w * 0.022));
            const gap = w * 0.015;

            keys.forEach(key => {
              if (key === 'sponsor') {
                const limg = loadedImages[key];
                const sH = Math.max(50, h * 0.08);
                const sW = limg ? sH * (limg.width / limg.height) : 0;
                ctx.font = `600 ${smallFont}px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif`;
                const pillW = ctx.measureText('Sponsored by').width + 6;
                items.push({ type: 'sponsor', w: pillW + gap * 0.5 + sW, h: sH, imgW: sW, imgH: sH, pillW, img: limg });
              } else {
                const limg = loadedImages[key];
                if (limg) { const lw = logoH * (limg.width / limg.height); items.push({ type: 'logo', w: lw, h: logoH, img: limg, key }); }
              }
            });

            const totalW = items.reduce((sum, it) => sum + it.w, 0) + Math.max(0, items.length - 1) * gap;
            const maxH = Math.max(...items.map(it => it.h));
            let startX;
            if (alignH === 'left') startX = anchorX;
            else if (alignH === 'center') startX = anchorX - totalW / 2;
            else startX = anchorX - totalW;

            let curX = startX;
            items.forEach(item => {
              let itemY = alignV === 'top' ? anchorY : anchorY - maxH;
              if (item.type === 'sponsor') {
                const midY = itemY + maxH / 2;
                const pillH = smallFont + 4;
                ctx.fillStyle = 'rgba(65,105,225,0.9)';
                ctx.beginPath(); ctx.roundRect(curX, midY - pillH / 2, item.pillW, pillH, 2); ctx.fill();
                ctx.fillStyle = '#eeeeee';
                ctx.font = `600 ${smallFont}px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif`;
                ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
                ctx.fillText('Sponsored by', curX + item.pillW / 2, midY);
                if (item.img) {
                  ctx.shadowColor = 'rgba(0,0,0,0.6)'; ctx.shadowBlur = Math.max(4, w * 0.005);
                  ctx.drawImage(item.img, curX + item.pillW + gap * 0.5, midY - item.imgH / 2, item.imgW, item.imgH);
                  ctx.shadowColor = 'transparent'; ctx.shadowBlur = 0;
                }
                ctx.textAlign = 'center';
              } else {
                ctx.shadowColor = 'rgba(0,0,0,0.5)'; ctx.shadowBlur = 4;
                ctx.drawImage(item.img, curX, itemY + (maxH - item.h) / 2, item.w, item.h);
                ctx.shadowColor = 'transparent'; ctx.shadowBlur = 0;
              }
              curX += item.w + gap;
            });
          }
          resolve(canvas.toDataURL('image/jpeg', 0.92));
        };

        if (toLoad.length === 0) { drawAll({}); return; }
        let loadCount = 0;
        const loadedImages = {};
        toLoad.forEach(item => {
          const logo = new Image();
          logo.onload = () => { loadedImages[item.key] = logo; loadCount++; if (loadCount === toLoad.length) drawAll(loadedImages); };
          logo.onerror = () => { loadCount++; if (loadCount === toLoad.length) drawAll(loadedImages); };
          logo.src = item.src;
        });
      };
      img.onerror = reject;
      img.src = URL.createObjectURL(file);
    });
  }

  fileToBase64(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result);
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
  }

  recordCanvasToBase64(canvas, durationMs = 10000) {
    return new Promise((resolve, reject) => {
      const stream = canvas.captureStream(30);
      const mimeType = MediaRecorder.isTypeSupported('video/webm;codecs=vp9')
        ? 'video/webm;codecs=vp9'
        : MediaRecorder.isTypeSupported('video/webm') ? 'video/webm' : 'video/mp4';
      const recorder = new MediaRecorder(stream, { mimeType, videoBitsPerSecond: 2_500_000 });
      const chunks = [];
      recorder.ondataavailable = e => { if (e.data.size > 0) chunks.push(e.data); };
      recorder.onstop = () => {
        const blob = new Blob(chunks, { type: mimeType.split(';')[0] });
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result);
        reader.onerror = reject;
        reader.readAsDataURL(blob);
      };
      recorder.onerror = reject;
      recorder.start();
      setTimeout(() => recorder.stop(), durationMs);
    });
  }

  async saveDraft() {
    const data = this.getFormData();
    if (!data.title) { alert('Please enter a title.'); return; }

    const isMedia = this.mediaType === 'media';
    if (isMedia && !this.currentFile) { alert('Please select a photo or video.'); return; }

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
        overlay_logos: data.overlay_logos,
        overlay_text: data.overlay_text,
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

      const postId = saveResult.data.id;

      if (isMedia) {
        // Upload user media (photo or video)
        if (btn) btn.textContent = '⏳ Processing media...';
        const isVideo = this.currentFile.type.startsWith('video/');

        if (isVideo) {
          const b64 = await this.fileToBase64(this.currentFile);
          const uploadResp = await this.auth.fetch(`/api/social/promos/${postId}/media`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ data: b64 })
          });
          const uploadResult = await uploadResp.json();
          if (!uploadResult.success) throw new Error(uploadResult.message);
        } else {
          // For images: render with canvas to bake in logo overlays
          if (btn) btn.textContent = '⏳ Generating image...';
          const overlaysWithPos = this.getSelectedOverlaysWithPositions();
          const finalDataUrl = await this.renderImageWithOverlay(this.currentFile, overlaysWithPos);
          const uploadResp = await this.auth.fetch(`/api/social/promos/${postId}/media`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ data: finalDataUrl })
          });
          const uploadResult = await uploadResp.json();
          if (!uploadResult.success) throw new Error(uploadResult.message);
        }
      } else {
        // Record the animated canvas as video (captures lightbeam, fish, logo animations)
        const canvas = this.find('#promo-canvas');
        if (canvas) {
          if (btn) btn.textContent = '⏳ Recording animation (30s)...';
          const videoDataUrl = await this.recordCanvasToBase64(canvas, 30000);
          if (btn) btn.textContent = '⏳ Uploading video...';
          const uploadResp = await this.auth.fetch(`/api/social/promos/${postId}/media`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ data: videoDataUrl })
          });
          if (!uploadResp.ok) {
            const errData = await uploadResp.json().catch(() => ({}));
            throw new Error(errData.message || `Media upload failed (HTTP ${uploadResp.status})`);
          }
        }
      }

      this.editing = null;
      this.currentFile = null;
      this.currentPreviewUrl = null;
      this.mediaType = 'card';
      await this.loadAndRender();
    } catch (error) {
      alert('Error: ' + error.message);
      if (btn) { btn.disabled = false; btn.textContent = '💾 Save Draft'; }
    }
  }

  renderList(container) {
    const allPosts = this.posts;
    const tabDefs = [
      { key: 'all',       label: 'All',       filter: () => true },
      { key: 'draft',     label: 'Drafts',    filter: p => p.status === 'draft' },
      { key: 'scheduled', label: 'Scheduled', filter: p => p.status === 'scheduled' },
      { key: 'published', label: 'Published', filter: p => p.status === 'posted' },
      { key: 'error',     label: 'Errors',    filter: p => p.status === 'error' },
    ];
    const activeTabDef = tabDefs.find(t => t.key === this.activeTab) || tabDefs[0];
    const posts = allPosts.filter(activeTabDef.filter);

    const tabCounts = Object.fromEntries(tabDefs.map(t => [t.key, t.key === 'all' ? allPosts.length : allPosts.filter(t.filter).length]));

    const tabsHtml = tabDefs.map(t => {
      const active = t.key === this.activeTab;
      const count = tabCounts[t.key];
      return `<button class="promo-tab-btn" data-tab="${t.key}" style="padding:8px 16px;border:none;border-bottom:3px solid ${active ? 'var(--accent-color)' : 'transparent'};background:transparent;color:${active ? 'var(--accent-color)' : 'inherit'};font-weight:${active ? '700' : '400'};cursor:pointer;font-size:0.95rem;white-space:nowrap;">${t.label}${count > 0 ? ` <span style="font-size:0.75rem;background:${active ? 'var(--accent-color)' : 'var(--bg-secondary)'};color:${active ? '#fff' : 'inherit'};border-radius:10px;padding:1px 7px;">${count}</span>` : ''}</button>`;
    }).join('');

    let html = `
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;gap:8px;flex-wrap:wrap;">
        <div style="display:flex;overflow-x:auto;border-bottom:1px solid var(--border-color);flex:1;min-width:0;">${tabsHtml}</div>
        <button class="btn btn-primary create-btn" style="padding:10px 20px;flex-shrink:0;">➕ New Promo</button>
      </div>
    `;

    if (posts.length === 0) {
      html += `<p style="opacity:0.6;text-align:center;padding:40px 0;">No ${activeTabDef.key === 'all' ? '' : activeTabDef.label.toLowerCase() + ' '}posts yet.${activeTabDef.key === 'all' ? ' Create your first one!' : ''}</p>`;
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
              ? `<div style="display:flex;flex-wrap:wrap;gap:8px;align-items:center;">
                  <span style="color:#4CAF50;font-weight:600;">✅ Published${p.posted_at ? ' ' + new Date(p.posted_at).toLocaleDateString() : ''}</span>
                  <button class="btn btn-secondary edit-btn" data-id="${p.id}" style="padding:6px 14px;font-size:0.85rem;">✏️ Edit</button>
                  <button class="btn btn-primary publish-btn" data-id="${p.id}" style="padding:8px 16px;font-size:0.85rem;">🔁 Re-post</button>
                  <button class="btn btn-danger delete-btn" data-id="${p.id}" style="padding:6px 14px;font-size:0.85rem;background:#d32f2f;color:#fff;border:none;border-radius:6px;cursor:pointer;">🗑️</button>
                </div>`
              : isScheduled
                ? `<div style="display:flex;gap:8px;align-items:center;">
                    <span style="color:#FF9800;font-weight:600;">⏰ Scheduled</span>
                    <button class="btn btn-secondary cancel-schedule-btn" data-id="${p.id}" style="padding:6px 14px;font-size:0.85rem;">Cancel</button>
                  </div>`
                : isPublishing
                  ? `<span style="color:#2196F3;font-weight:600;">⏳ Publishing to Instagram...</span>`
                  : `<div style="display:flex;flex-wrap:wrap;gap:8px;align-items:center;">
                      <button class="btn btn-secondary edit-btn" data-id="${p.id}" style="padding:8px 14px;">✏️ Edit</button>
                      <button class="btn btn-danger delete-btn" data-id="${p.id}" style="padding:8px 14px;background:#d32f2f;color:#fff;border:none;border-radius:6px;cursor:pointer;">🗑️ Delete</button>
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
    const frameBottom = h - 68;
    const innerFrameBottom = frameBottom - 8;
    const contentShiftY = 0;
    const lighthouseLift = 24;

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
    ctx.beginPath();
    ctx.moveTo(24, 24);
    ctx.lineTo(w - 24, 24);
    ctx.lineTo(w - 24, frameBottom);
    ctx.lineTo(24, frameBottom);
    ctx.closePath();
    ctx.stroke();

    // Inner thin border
    ctx.strokeStyle = 'rgba(245, 212, 66, 0.3)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(40, 40);
    ctx.lineTo(w - 40, 40);
    ctx.lineTo(w - 40, innerFrameBottom);
    ctx.lineTo(40, innerFrameBottom);
    ctx.closePath();
    ctx.stroke();

    ctx.textAlign = 'center';
    ctx.textBaseline = 'alphabetic';

    // --- Top section ---
    // "LIGHTHOUSE 1893" header — centered between thick border (y≈28) and thin divider (y=115)
    ctx.fillStyle = gold;
    ctx.font = '700 18px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.letterSpacing = '6px';
    ctx.textBaseline = 'middle';
    ctx.fillText('L I G H T H O U S E   1 8 9 3', w / 2, 72 + contentShiftY);
    ctx.textBaseline = 'alphabetic';

    // Top divider with soccer ball
    const divY = 115 + contentShiftY;

    // Draw line first so the ball sits on top of it
    // Add a dark underlay so the divider remains visible over bright pixels.
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.45)';
    ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.moveTo(w * 0.25, divY);
    ctx.lineTo(w * 0.75, divY);
    ctx.stroke();
    ctx.strokeStyle = gold;
    ctx.lineWidth = 2;
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
    ctx.font = '800 56px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textBaseline = 'middle';
    ctx.fillText(promo.heading, w / 2, 187 + contentShiftY);
    ctx.textBaseline = 'alphabetic';

    // Gold separator
    ctx.strokeStyle = gold;
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.moveTo(w / 2 - 140, 248 + contentShiftY);
    ctx.lineTo(w / 2 + 140, 248 + contentShiftY);
    ctx.stroke();
    ctx.font = '28px sans-serif';
    ctx.fillStyle = white;
    ctx.textBaseline = 'middle';
    ctx.fillText('⚽', w / 2, 248 + contentShiftY);
    ctx.textBaseline = 'alphabetic';

    // Subheading
    ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
    ctx.font = '600 24px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText(promo.subheading, w / 2, 283 + contentShiftY);

    // --- Body lines (plain text) ---
    const bodyLineStartY = 348 + contentShiftY;
    const bodyLineGap = 50;
    ctx.font = '600 34px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.shadowColor = 'rgba(0, 0, 0, 0.75)';
    ctx.shadowBlur = 18;
    ctx.shadowOffsetX = 0;
    ctx.shadowOffsetY = 2;
    promo.bodyLines.forEach((line, i) => {
      const lineY = bodyLineStartY + i * bodyLineGap;
      ctx.fillStyle = 'rgba(255, 255, 255, 0.95)';
      ctx.fillText(line, w / 2, lineY);
    });
    ctx.shadowColor = 'transparent';
    ctx.shadowBlur = 0;
    ctx.shadowOffsetY = 0;

    // --- Footer league name ---
    const leagueY = bodyLineStartY + promo.bodyLines.length * bodyLineGap + 50;
    ctx.fillStyle = gold;
    ctx.font = '600 28px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText(promo.footer, w / 2, leagueY);

    // --- Position-based logo overlays (tic-tac-toe grid) ---
    // Sponsor always at bottom; other logos positioned above
    const overlays = promo.overlays || [];
    const sponsorOverlay = overlays.find(s => s.key === 'sponsor');
    const nonSponsorOverlays = overlays.filter(s => s.key !== 'sponsor');

    if (nonSponsorOverlays.length > 0 || sponsorOverlay) {
      const margin = 50;
      const logoH = 70;
      const gap = 14;
      let bottomAnchorY = h - margin;

      const lighthouseGraphic = overlays.find(o => o.key === 'lighthouse_graphic' && o.pos);
      if (lighthouseGraphic) {
        const lhTopOffset = 98;
        const lhBotOffset = 380;
        let waterLhY;
        if (lighthouseGraphic.pos.startsWith('t')) waterLhY = margin + lhTopOffset;
        else if (lighthouseGraphic.pos.startsWith('b')) waterLhY = h - margin - lhBotOffset;
        else waterLhY = h / 2 - (lhBotOffset - lhTopOffset) / 2;
        waterLhY -= lighthouseLift;

        const oceanY = waterLhY + 352;
        const oceanH = 44;
        const logoTopAtDefaultAnchor = h - margin - logoH;
        const logoBottomAtDefaultAnchor = h - margin;
        const oceanOverlapsBottomLogos = oceanY < logoBottomAtDefaultAnchor && (oceanY + oceanH) > logoTopAtDefaultAnchor;
        if (oceanOverlapsBottomLogos) {
          bottomAnchorY = Math.min(bottomAnchorY, oceanY - 10);
        }
      }

      // Draw non-sponsor overlays in their grid positions
      if (nonSponsorOverlays.length > 0) {
        const regions = {};
        nonSponsorOverlays.forEach(s => {
          if (!regions[s.pos]) regions[s.pos] = [];
          regions[s.pos].push(s.key);
        });

        for (const [pos, keys] of Object.entries(regions)) {
          let anchorX, anchorY, alignH, alignV;
          if (pos.startsWith('t')) { anchorY = margin; alignV = 'top'; }
          else { anchorY = bottomAnchorY; alignV = 'bottom'; }
          if (pos.endsWith('l')) { anchorX = margin; alignH = 'left'; }
          else if (pos.endsWith('c')) { anchorX = w / 2; alignH = 'center'; }
          else { anchorX = w - margin; alignH = 'right'; }

          const items = [];
          keys.forEach(key => {
            const img = this.loadedLogos[key];
            if (img) {
              const lw = logoH * (img.width / img.height);
              items.push({ type: 'logo', w: lw, h: logoH, img, key });
            }
          });

          if (items.length === 0) continue;

          const totalW = items.reduce((sum, it) => sum + it.w, 0) + Math.max(0, items.length - 1) * gap;
          const maxH = Math.max(...items.map(it => it.h));

          let startX;
          if (alignH === 'left') startX = anchorX;
          else if (alignH === 'center') startX = anchorX - totalW / 2;
          else startX = anchorX - totalW;

          let curX = startX;
          items.forEach(item => {
            let itemY;
            if (alignV === 'top') itemY = anchorY;
            else itemY = anchorY - maxH;

            ctx.shadowColor = 'rgba(0,0,0,0.5)';
            ctx.shadowBlur = 6;
            ctx.drawImage(item.img, curX, itemY + (maxH - item.h) / 2, item.w, item.h);
            ctx.shadowColor = 'transparent';
            ctx.shadowBlur = 0;
            curX += item.w + gap;
          });

        }
      }

      // Draw sponsor just above any bottom-row logos
      if (sponsorOverlay) {
        const img = this.loadedLogos['sponsor'];
        const sH = 100;
        const sW = img ? sH * (img.width / img.height) : 0;
        const sponsorFont = 24;
        const hasBottomLogos = nonSponsorOverlays.some(o => o.pos && o.pos.startsWith('b'));
        const sponsorBottomY = hasBottomLogos ? bottomAnchorY - logoH - gap : bottomAnchorY;
        const sponsorY = sponsorBottomY - sH;

        ctx.font = `600 ${sponsorFont}px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif`;
        const pillW = ctx.measureText('Sponsored by').width + 12;
        const totalSponsorW = pillW + gap + sW;
        const sponsorX = w / 2 - totalSponsorW / 2;

        // Pill background
        const pillH = sponsorFont + 8;
        const pillY = sponsorY + (sH - pillH) / 2;
        ctx.fillStyle = 'rgba(65,105,225,0.9)';
        ctx.beginPath();
        ctx.roundRect(sponsorX, pillY, pillW, pillH, 4);
        ctx.fill();

        // Pill text
        ctx.fillStyle = '#eeeeee';
        ctx.font = `600 ${sponsorFont}px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif`;
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('Sponsored by', sponsorX + pillW / 2, pillY + pillH / 2);

        // Sponsor logo
        if (img) {
          ctx.shadowColor = 'rgba(0,0,0,0.6)';
          ctx.shadowBlur = 6;
          ctx.drawImage(img, sponsorX + pillW + gap, sponsorY, sW, sH);
          ctx.shadowColor = 'transparent';
          ctx.shadowBlur = 0;
        }
      }
    }
  }

  startPromoAnimation(canvas, promo) {
    // Cancel any previous animation loop
    if (this.animFrameId) {
      cancelAnimationFrame(this.animFrameId);
      this.animFrameId = null;
    }

    const scale = 2;
    const w = 1080, h = 1080;
    const frameBottom = h - 68;
    const innerFrameBottom = frameBottom - 8;
    const contentShiftY = 0;
    const lighthouseLift = 36;
    canvas.width = w * scale;
    canvas.height = h * scale;
    const ctx = canvas.getContext('2d');
    ctx.scale(scale, scale);

    // Check if lighthouse graphic is positioned
    const lighthouseOverlay = (promo.overlays || []).find(o => o.key === 'lighthouse_graphic');
    let lhX = null, lhY = null;
    
    if (lighthouseOverlay && lighthouseOverlay.pos) {
      // Actual lighthouse dimensions (s=2 inside drawLighthouseOnCtx):
      // - top of finial is at lhY - 98
      // - bottom of ocean is at lhY + 380 (tower=300, rock=56, ocean=24)
      const margin = 50;
      const lhTopOffset = 98;   // distance from lhY to top of finial
      const lhBotOffset = 380;  // distance from lhY to bottom of ocean
      const lhW = 120;          // half-width includes ocean (rockW=100)
      const pos = lighthouseOverlay.pos;

      if (pos.startsWith('t')) lhY = margin + lhTopOffset;
      else if (pos.startsWith('b')) lhY = h - margin - lhBotOffset;
      else lhY = h / 2 - (lhBotOffset - lhTopOffset) / 2;
      lhY -= lighthouseLift;

      if (pos.endsWith('l')) lhX = margin + lhW;
      else if (pos.endsWith('r')) lhX = w - 10 - lhW;
      else lhX = w / 2;
    }

    const beamLen = Math.max(w, h) * 1.2;
    const beamSpread = 0.18;
    const rotPeriod = 30;
    const rotSpeed = (2 * Math.PI) / rotPeriod;

    if (!this.animStartTime) {
      // Start beam pointing toward nearest wall (off-canvas) so first frame isn't jarring.
      // beamAngle = angle + PI*0.25, so to start pointing east (right wall): angle = -PI/4
      // to start pointing west (left wall): angle = 3PI/4
      let startAngleOffset = 0;
      if (lhX !== null) {
        startAngleOffset = lhX < w / 2
          ? Math.PI - Math.PI * 0.25   // left-side lighthouse → beam starts pointing west
          : -Math.PI * 0.25;            // right-side lighthouse → beam starts pointing east
      }
      this.animStartTime = performance.now() - (startAngleOffset / rotSpeed) * 1000;
    }
    const startTime = this.animStartTime;

    const drawFrame = (now) => {
      const elapsed = (now - startTime) / 1000;
      const angle = elapsed * rotSpeed; // continuous — no modulo wrap, cos/sin handle large angles fine

      // Clear canvas
      ctx.clearRect(0, 0, w, h);

      // Draw the base card (without lighthouse if it's positioned elsewhere).
      // In animated lighthouse mode, skip base text so it can be drawn once on top.
      this.drawPromoCardBaseOnly(ctx, w, h, promo, lhX !== null, lhX !== null, frameBottom, contentShiftY, lighthouseLift);

      // Draw lighthouse with beam if positioned
      if (lhX !== null && lhY !== null) {
        // Clip beam to inner border so animation stays inside the painted area
        const paintInset = 28;
        ctx.save();
        ctx.beginPath();
        ctx.rect(paintInset, paintInset, w - paintInset * 2, frameBottom - paintInset);
        ctx.clip();

        // Draw light beam (rotating cone)
        const beamAngle = angle + Math.PI * 0.25;
        const a1 = beamAngle - beamSpread;
        const a2 = beamAngle + beamSpread;
        const tipX1 = lhX + Math.cos(a1) * beamLen;
        const tipY1 = lhY + Math.sin(a1) * beamLen;
        const tipX2 = lhX + Math.cos(a2) * beamLen;
        const tipY2 = lhY + Math.sin(a2) * beamLen;

        // Outer glow
        const grad = ctx.createRadialGradient(lhX, lhY, 10, lhX, lhY, beamLen * 0.7);
        grad.addColorStop(0, 'rgba(255, 230, 0, 0.55)');
        grad.addColorStop(0.3, 'rgba(255, 223, 0, 0.25)');
        grad.addColorStop(1, 'rgba(255, 223, 0, 0)');
        ctx.beginPath();
        ctx.moveTo(lhX, lhY);
        ctx.lineTo(tipX1, tipY1);
        ctx.lineTo(tipX2, tipY2);
        ctx.closePath();
        ctx.fillStyle = grad;
        ctx.fill();

        // Bright core
        const ca1 = beamAngle - beamSpread * 0.4;
        const ca2 = beamAngle + beamSpread * 0.4;
        const coreLen = beamLen * 0.6;
        ctx.beginPath();
        ctx.moveTo(lhX, lhY);
        ctx.lineTo(lhX + Math.cos(ca1) * coreLen, lhY + Math.sin(ca1) * coreLen);
        ctx.lineTo(lhX + Math.cos(ca2) * coreLen, lhY + Math.sin(ca2) * coreLen);
        ctx.closePath();
        const coreGrad = ctx.createRadialGradient(lhX, lhY, 5, lhX, lhY, coreLen * 0.5);
        coreGrad.addColorStop(0, 'rgba(255, 240, 50, 0.5)');
        coreGrad.addColorStop(1, 'rgba(255, 240, 50, 0)');
        ctx.fillStyle = coreGrad;
        ctx.fill();

        ctx.restore();

        // Draw lighthouse on top of beam
        this.drawLighthouseOnCtx(ctx, lhX, lhY, elapsed, w, h, promo, frameBottom);
      }

      // Redraw text on top so it appears over lighthouse (but not beam)
      const gold = '#f5d442';
      const white = '#ffffff';
      ctx.textAlign = 'center';

      // --- Top section ---
      // "LIGHTHOUSE 1893" header
      ctx.fillStyle = gold;
      ctx.font = '700 18px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.letterSpacing = '6px';
      ctx.textBaseline = 'middle';
      ctx.fillText('L I G H T H O U S E   1 8 9 3', w / 2, 72 + contentShiftY);
      ctx.textBaseline = 'alphabetic';

      // Thin gold divider with soccer ball
      const divY = 115 + contentShiftY;

      // Draw line first so the ball sits on top of it
      // Add a dark underlay so the divider remains visible over bright pixels.
      ctx.strokeStyle = 'rgba(0, 0, 0, 0.45)';
      ctx.lineWidth = 4;
      ctx.beginPath();
      ctx.moveTo(w * 0.25, divY);
      ctx.lineTo(w * 0.75, divY);
      ctx.stroke();
      ctx.strokeStyle = gold;
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo(w * 0.25, divY);
      ctx.lineTo(w * 0.75, divY);
      ctx.stroke();

      ctx.font = '28px sans-serif';
      ctx.fillStyle = white;
      ctx.fillText('⚽', w / 2, divY + 6);

      // Gold dots on divider
      ctx.fillStyle = gold;
      ctx.beginPath();
      ctx.arc(w * 0.25, divY, 3, 0, Math.PI * 2);
      ctx.fill();
      ctx.beginPath();
      ctx.arc(w * 0.75, divY, 3, 0, Math.PI * 2);
      ctx.fill();

      // --- Main heading ---
      ctx.fillStyle = white;
      ctx.font = '800 56px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.textBaseline = 'middle';
      ctx.fillText(promo.heading, w / 2, 187 + contentShiftY);
      ctx.textBaseline = 'alphabetic';

      // Gold separator
      ctx.strokeStyle = gold;
      ctx.lineWidth = 3;
      ctx.beginPath();
      ctx.moveTo(w / 2 - 140, 248 + contentShiftY);
      ctx.lineTo(w / 2 + 140, 248 + contentShiftY);
      ctx.stroke();
      ctx.font = '28px sans-serif';
      ctx.fillStyle = white;
      ctx.textBaseline = 'middle';
      ctx.fillText('⚽', w / 2, 248 + contentShiftY);
      ctx.textBaseline = 'alphabetic';

      // Subheading
      ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
      ctx.font = '600 24px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.fillText(promo.subheading, w / 2, 283 + contentShiftY);

      // --- Body lines ---
      const bodyLineStartY = 348 + contentShiftY;
      const bodyLineGap = 50;
      ctx.font = '600 34px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.textBaseline = 'middle';
      ctx.shadowColor = 'rgba(0, 0, 0, 0.75)';
      ctx.shadowBlur = 18;
      ctx.shadowOffsetX = 0;
      ctx.shadowOffsetY = 2;
      promo.bodyLines.forEach((line, i) => {
        const lineY = bodyLineStartY + i * bodyLineGap;
        ctx.fillStyle = 'rgba(255, 255, 255, 0.95)';
        ctx.fillText(line, w / 2, lineY);
      });
      ctx.shadowColor = 'transparent';
      ctx.shadowBlur = 0;
      ctx.shadowOffsetY = 0;

      // --- Footer league name ---
      const leagueY = bodyLineStartY + promo.bodyLines.length * bodyLineGap + 50;
      ctx.fillStyle = gold;
      ctx.font = '600 28px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.fillText(promo.footer, w / 2, leagueY);

      // Re-draw frame on top so moving logos/animation feel beneath the painting border
      ctx.strokeStyle = gold;
      ctx.lineWidth = 8;
      ctx.beginPath();
      ctx.moveTo(24, 24);
      ctx.lineTo(w - 24, 24);
      ctx.lineTo(w - 24, frameBottom);
      ctx.lineTo(24, frameBottom);
      ctx.closePath();
      ctx.stroke();
      ctx.strokeStyle = 'rgba(245, 212, 66, 0.3)';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(40, 40);
      ctx.lineTo(w - 40, 40);
      ctx.lineTo(w - 40, innerFrameBottom);
      ctx.lineTo(40, innerFrameBottom);
      ctx.closePath();
      ctx.stroke();

      this.animFrameId = requestAnimationFrame(drawFrame);
    };

    this.animFrameId = requestAnimationFrame(drawFrame);
  }

  drawPromoCardBaseOnly(ctx, w, h, promo, skipLighthouseGraphic, skipText = false, frameBottom = h - 68, contentShiftY = 0, lighthouseLift = 36) {
    // Render just the base card (without lighthouse beam) - extracted from drawPromoCardOnCanvas
    const gold = '#f5d442';
    const white = '#ffffff';

    // Deep blue gradient background
    const bgGrad = ctx.createLinearGradient(0, 0, w * 0.6, h);
    bgGrad.addColorStop(0, '#0033a0');
    bgGrad.addColorStop(0.3, '#003fbf');
    bgGrad.addColorStop(0.55, '#0044cc');
    bgGrad.addColorStop(1, '#002080');
    ctx.fillStyle = bgGrad;
    ctx.fillRect(0, 0, w, h);

    // Subtle radial glow
    const glowGrad = ctx.createRadialGradient(w / 2, h * 0.4, 50, w / 2, h * 0.4, 500);
    glowGrad.addColorStop(0, 'rgba(0, 100, 255, 0.15)');
    glowGrad.addColorStop(1, 'rgba(0, 0, 0, 0)');
    ctx.fillStyle = glowGrad;
    ctx.fillRect(0, 0, w, h);

    // Gold border
    ctx.strokeStyle = gold;
    ctx.lineWidth = 8;
    ctx.beginPath();
    ctx.moveTo(24, 24);
    ctx.lineTo(w - 24, 24);
    ctx.lineTo(w - 24, frameBottom);
    ctx.lineTo(24, frameBottom);
    ctx.closePath();
    ctx.stroke();
    ctx.strokeStyle = 'rgba(245, 212, 66, 0.3)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(40, 40);
    ctx.lineTo(w - 40, 40);
    ctx.lineTo(w - 40, frameBottom - 8);
    ctx.lineTo(40, frameBottom - 8);
    ctx.closePath();
    ctx.stroke();

    if (!skipText) {
      ctx.textAlign = 'center';

      // "LIGHTHOUSE 1893" header
      ctx.fillStyle = gold;
      ctx.font = '700 18px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.letterSpacing = '6px';
      ctx.fillText('L I G H T H O U S E   1 8 9 3', w / 2, 90 + contentShiftY);

      // Divider with soccer ball
      const divY = 115 + contentShiftY;

      // Draw line first so the ball sits on top of it
      // Add a dark underlay so the divider remains visible over bright pixels.
      ctx.strokeStyle = 'rgba(0, 0, 0, 0.45)';
      ctx.lineWidth = 4;
      ctx.beginPath();
      ctx.moveTo(w * 0.25, divY);
      ctx.lineTo(w * 0.75, divY);
      ctx.stroke();
      ctx.strokeStyle = gold;
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo(w * 0.25, divY);
      ctx.lineTo(w * 0.75, divY);
      ctx.stroke();

      // Soccer ball
      ctx.font = '28px sans-serif';
      ctx.fillStyle = white;
      ctx.fillText('⚽', w / 2, divY + 6);

      // Gold dots on divider
      ctx.fillStyle = gold;
      ctx.beginPath();
      ctx.arc(w * 0.25, divY, 3, 0, Math.PI * 2);
      ctx.fill();
      ctx.beginPath();
      ctx.arc(w * 0.75, divY, 3, 0, Math.PI * 2);
      ctx.fill();

      // Main heading
      ctx.fillStyle = white;
      ctx.font = '800 56px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.fillText(promo.heading, w / 2, 142 + contentShiftY);

      // Gold separator
      ctx.strokeStyle = gold;
      ctx.lineWidth = 3;
      ctx.beginPath();
      ctx.moveTo(w / 2 - 140, 188 + contentShiftY);
      ctx.lineTo(w / 2 + 140, 188 + contentShiftY);
      ctx.stroke();
      ctx.font = '28px sans-serif';
      ctx.fillStyle = white;
      ctx.textBaseline = 'middle';
      ctx.fillText('⚽', w / 2, 188 + contentShiftY);
      ctx.textBaseline = 'alphabetic';

      // Subheading
      ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
      ctx.font = '600 24px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.fillText(promo.subheading, w / 2, 228 + contentShiftY);

      // Body lines (plain text)
      const bodyLineStartY = 288 + contentShiftY;
      const bodyLineGap = 50;
      ctx.font = '600 34px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      promo.bodyLines.forEach((line, i) => {
        const lineY = bodyLineStartY + i * bodyLineGap;
        ctx.shadowColor = 'rgba(0, 0, 0, 0.75)';
        ctx.shadowBlur = 18;
        ctx.shadowOffsetX = 0;
        ctx.shadowOffsetY = 2;
        ctx.fillStyle = 'rgba(255, 255, 255, 0.95)';
        ctx.fillText(line, w / 2, lineY);
      });
      ctx.shadowColor = 'transparent';
      ctx.shadowBlur = 0;
      ctx.shadowOffsetY = 0;

      // Footer league name
      const leagueY = bodyLineStartY + promo.bodyLines.length * bodyLineGap + 50;
      ctx.fillStyle = gold;
      ctx.font = '600 28px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.fillText(promo.footer, w / 2, leagueY);

    }

    // Sponsor section at bottom
    const overlays = promo.overlays || [];
    const sponsorOverlay = overlays.find(s => s.key === 'sponsor');
    const nonSponsorOverlays = overlays.filter(s => s.key !== 'sponsor');

    if (nonSponsorOverlays.length > 0 || sponsorOverlay) {
      const margin = 50;
      const logoH = 70;
      const gap = 14;
      let bottomAnchorY = h - margin;
      let oceanYForLogos = null;
      const oceanHForLogos = 44;

      const lighthouseGraphic = overlays.find(o => o.key === 'lighthouse_graphic' && o.pos);
      if (lighthouseGraphic) {
        const lhTopOffset = 98;
        const lhBotOffset = 380;
        let waterLhY;
        if (lighthouseGraphic.pos.startsWith('t')) waterLhY = margin + lhTopOffset;
        else if (lighthouseGraphic.pos.startsWith('b')) waterLhY = h - margin - lhBotOffset;
        else waterLhY = h / 2 - (lhBotOffset - lhTopOffset) / 2;
        waterLhY -= lighthouseLift;

        const oceanY = waterLhY + 352;
        const oceanH = oceanHForLogos;
        oceanYForLogos = oceanY;
        const logoTopAtDefaultAnchor = h - margin - logoH;
        const logoBottomAtDefaultAnchor = h - margin;
        const oceanOverlapsBottomLogos = oceanY < logoBottomAtDefaultAnchor && (oceanY + oceanH) > logoTopAtDefaultAnchor;
        if (oceanOverlapsBottomLogos) {
          bottomAnchorY = Math.min(bottomAnchorY, oceanY - 10);
        }
      }

      if (nonSponsorOverlays.length > 0) {
        const staticOverlays = skipLighthouseGraphic
          ? nonSponsorOverlays.filter(o => !(o.pos && o.pos.startsWith('b')))
          : nonSponsorOverlays;

        const regions = {};
        staticOverlays.forEach(s => {
          if (!regions[s.pos]) regions[s.pos] = [];
          regions[s.pos].push(s.key);
        });

        for (const [pos, keys] of Object.entries(regions)) {
          let anchorX, anchorY, alignH, alignV;
          if (pos.startsWith('t')) { anchorY = margin; alignV = 'top'; }
          else { anchorY = bottomAnchorY; alignV = 'bottom'; }
          if (pos.endsWith('l')) { anchorX = margin; alignH = 'left'; }
          else if (pos.endsWith('c')) { anchorX = w / 2; alignH = 'center'; }
          else { anchorX = w - margin; alignH = 'right'; }

          const items = [];
          keys.forEach(key => {
            const img = this.loadedLogos[key];
            if (img) {
              const lw = logoH * (img.width / img.height);
              items.push({ type: 'logo', w: lw, h: logoH, img, key });
            }
          });

          if (items.length === 0) continue;

          const totalW = items.reduce((sum, it) => sum + it.w, 0) + Math.max(0, items.length - 1) * gap;
          const maxH = Math.max(...items.map(it => it.h));

          let startX;
          if (alignH === 'left') startX = anchorX;
          else if (alignH === 'center') startX = anchorX - totalW / 2;
          else startX = anchorX - totalW;

          let curX = startX;
          items.forEach(item => {
            let itemY;
            if (alignV === 'top') itemY = anchorY;
            else itemY = anchorY - maxH;

            ctx.shadowColor = 'rgba(0,0,0,0.5)';
            ctx.shadowBlur = 6;
            ctx.drawImage(item.img, curX, itemY + (maxH - item.h) / 2, item.w, item.h);
            ctx.shadowColor = 'transparent';
            ctx.shadowBlur = 0;
            curX += item.w + gap;
          });

        }
      }

      if (sponsorOverlay) {
        const img = this.loadedLogos['sponsor'];
        const sH = 100;
        const sW = img ? sH * (img.width / img.height) : 0;
        const sponsorFont = 24;
        const hasBottomLogos = nonSponsorOverlays.some(o => o.pos && o.pos.startsWith('b'));
        const sponsorBottomY = hasBottomLogos ? bottomAnchorY - logoH - gap : bottomAnchorY;
        const sponsorY = sponsorBottomY - sH;

        ctx.font = `600 ${sponsorFont}px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif`;
        const pillW = ctx.measureText('Sponsored by').width + 12;
        const totalSponsorW = pillW + gap + sW;
        const sponsorX = w / 2 - totalSponsorW / 2;

        const pillH = sponsorFont + 8;
        const pillY = sponsorY + (sH - pillH) / 2;
        ctx.fillStyle = 'rgba(65,105,225,0.9)';
        ctx.beginPath();
        ctx.roundRect(sponsorX, pillY, pillW, pillH, 4);
        ctx.fill();

        ctx.fillStyle = '#eeeeee';
        ctx.font = `600 ${sponsorFont}px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif`;
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('Sponsored by', sponsorX + pillW / 2, pillY + pillH / 2);

        if (img) {
          ctx.shadowColor = 'rgba(0,0,0,0.6)';
          ctx.shadowBlur = 6;
          ctx.drawImage(img, sponsorX + pillW + gap, sponsorY, sW, sH);
          ctx.shadowColor = 'transparent';
          ctx.shadowBlur = 0;
        }
      }
    }
  }

  drawLighthouseOnCtx(ctx, lhX, lhY, t = 0, w = 1080, h = 1080, promo = null, frameBottom = h - 68) {
    const s = 2;
    ctx.save();

    const topW = 26 * s, botW = 38 * s, towerH = 150 * s;
    const topY = lhY + 8 * s;
    const botY = lhY + towerH;

    const towerPath = () => {
      ctx.beginPath();
      ctx.moveTo(lhX - topW / 2, topY);
      ctx.lineTo(lhX + topW / 2, topY);
      ctx.lineTo(lhX + botW / 2, botY);
      ctx.lineTo(lhX - botW / 2, botY);
      ctx.closePath();
    };

    // Tower body (white)
    towerPath();
    ctx.fillStyle = '#ffffff';
    ctx.fill();

    // 4 royal blue bands with gold "1893" digits
    const digits = ['1', '8', '9', '3'];
    const bandH = 18 * s;
    const bandZone = towerH * 0.82;
    const bandGap = (bandZone - bandH * 4) / 5;
    for (let i = 0; i < 4; i++) {
      const bandY = topY + bandGap * (i + 1) + bandH * i;
      const fracTop = (bandY - topY) / towerH;
      const fracBot = (bandY + bandH - topY) / towerH;
      const wTop = topW + (botW - topW) * fracTop;
      const wBot = topW + (botW - topW) * fracBot;

      ctx.save();
      towerPath();
      ctx.clip();
      ctx.beginPath();
      ctx.moveTo(lhX - wTop / 2, bandY);
      ctx.lineTo(lhX + wTop / 2, bandY);
      ctx.lineTo(lhX + wBot / 2, bandY + bandH);
      ctx.lineTo(lhX - wBot / 2, bandY + bandH);
      ctx.closePath();
      ctx.fillStyle = '#0033a0';
      ctx.fill();

      const fontSize = Math.round(14 * s);
      ctx.font = `900 ${fontSize}px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillStyle = '#f5d442';
      ctx.fillText(digits[i], lhX, bandY + bandH / 2);
      ctx.restore();
    }

    // Tower outline
    towerPath();
    ctx.strokeStyle = 'rgba(255,255,255,0.6)';
    ctx.lineWidth = 1.5 * s;
    ctx.stroke();

    // Gallery platform
    const platW = topW + 12 * s;
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(lhX - platW / 2, topY - 3 * s, platW, 6 * s);
    ctx.strokeStyle = '#0033a0';
    ctx.lineWidth = 1 * s;
    ctx.strokeRect(lhX - platW / 2, topY - 3 * s, platW, 6 * s);

    // Railing posts
    const railH = 10 * s;
    const railY = topY - 3 * s - railH;
    const numPosts = 7;
    for (let i = 0; i < numPosts; i++) {
      const px = lhX - platW / 2 + 3 * s + i * ((platW - 6 * s) / (numPosts - 1));
      ctx.beginPath();
      ctx.moveTo(px, topY - 3 * s);
      ctx.lineTo(px, railY);
      ctx.strokeStyle = '#ffffff';
      ctx.lineWidth = 1 * s;
      ctx.stroke();
    }
    ctx.beginPath();
    ctx.moveTo(lhX - platW / 2 + 2 * s, railY);
    ctx.lineTo(lhX + platW / 2 - 2 * s, railY);
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 1.5 * s;
    ctx.stroke();

    // Lantern room
    const lanternW = 20 * s, lanternH = 16 * s;
    const lanternTop = railY - lanternH;
    ctx.fillStyle = '#f5d442';
    ctx.fillRect(lhX - lanternW / 2, lanternTop, lanternW, lanternH);
    ctx.strokeStyle = '#0033a0';
    ctx.lineWidth = 1.5 * s;
    ctx.beginPath();
    ctx.moveTo(lhX, lanternTop);
    ctx.lineTo(lhX, lanternTop + lanternH);
    ctx.moveTo(lhX - lanternW / 2, lanternTop + lanternH / 2);
    ctx.lineTo(lhX + lanternW / 2, lanternTop + lanternH / 2);
    ctx.stroke();
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 2 * s;
    ctx.strokeRect(lhX - lanternW / 2, lanternTop, lanternW, lanternH);

    // Dome
    const domeW = lanternW + 4 * s;
    ctx.beginPath();
    ctx.moveTo(lhX - domeW / 2, lanternTop);
    ctx.quadraticCurveTo(lhX, lanternTop - 22 * s, lhX + domeW / 2, lanternTop);
    ctx.closePath();
    ctx.fillStyle = '#0033a0';
    ctx.fill();
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 1.5 * s;
    ctx.stroke();

    // Finial
    ctx.beginPath();
    ctx.arc(lhX, lanternTop - 18 * s, 3 * s, 0, Math.PI * 2);
    ctx.fillStyle = '#f5d442';
    ctx.fill();
    ctx.beginPath();
    ctx.moveTo(lhX, lanternTop - 21 * s);
    ctx.lineTo(lhX, lanternTop - 28 * s);
    ctx.strokeStyle = '#f5d442';
    ctx.lineWidth = 2 * s;
    ctx.stroke();

    // Lantern glow
    const glowCY = lanternTop + lanternH / 2;
    const glowGrad = ctx.createRadialGradient(lhX, glowCY, 0, lhX, glowCY, 24 * s);
    glowGrad.addColorStop(0, 'rgba(255, 230, 0, 0.7)');
    glowGrad.addColorStop(0.4, 'rgba(255, 223, 0, 0.2)');
    glowGrad.addColorStop(1, 'rgba(255, 223, 0, 0)');
    ctx.beginPath();
    ctx.arc(lhX, glowCY, 24 * s, 0, Math.PI * 2);
    ctx.fillStyle = glowGrad;
    ctx.fill();

    // === ROCKY CLIFF ===
    const rockY = botY + 2 * s;
    const rockW = 50 * s;
    const rockH = 28 * s;

    ctx.beginPath();
    ctx.moveTo(lhX - rockW, rockY + rockH);
    ctx.lineTo(lhX - rockW, rockY + 6 * s);
    ctx.quadraticCurveTo(lhX - rockW * 0.7, rockY - 4 * s, lhX - rockW * 0.4, rockY + 2 * s);
    ctx.lineTo(lhX - rockW * 0.2, rockY - 2 * s);
    ctx.lineTo(lhX, rockY);
    ctx.lineTo(lhX + rockW * 0.15, rockY - 3 * s);
    ctx.lineTo(lhX + rockW * 0.35, rockY + 1 * s);
    ctx.quadraticCurveTo(lhX + rockW * 0.6, rockY - 2 * s, lhX + rockW * 0.8, rockY + 4 * s);
    ctx.lineTo(lhX + rockW, rockY + 8 * s);
    ctx.lineTo(lhX + rockW, rockY + rockH);
    ctx.closePath();
    ctx.fillStyle = '#2c2c2c';
    ctx.fill();

    ctx.save();
    ctx.globalAlpha = 0.3;
    const rockShapes = [
      { x: lhX - 20 * s, y: rockY + 6 * s, rx: 10 * s, ry: 5 * s },
      { x: lhX + 15 * s, y: rockY + 8 * s, rx: 8 * s, ry: 4 * s },
      { x: lhX - 5 * s, y: rockY + 14 * s, rx: 12 * s, ry: 5 * s },
      { x: lhX + 30 * s, y: rockY + 12 * s, rx: 9 * s, ry: 5 * s },
      { x: lhX - 35 * s, y: rockY + 12 * s, rx: 11 * s, ry: 4 * s },
    ];
    for (const r of rockShapes) {
      ctx.beginPath();
      ctx.ellipse(r.x, r.y, r.rx, r.ry, 0, 0, Math.PI * 2);
      ctx.fillStyle = '#444444';
      ctx.fill();
    }
    ctx.restore();

    ctx.beginPath();
    ctx.moveTo(lhX - rockW, rockY + 6 * s);
    ctx.quadraticCurveTo(lhX - rockW * 0.7, rockY - 4 * s, lhX - rockW * 0.4, rockY + 2 * s);
    ctx.lineTo(lhX - rockW * 0.2, rockY - 2 * s);
    ctx.lineTo(lhX, rockY);
    ctx.lineTo(lhX + rockW * 0.15, rockY - 3 * s);
    ctx.lineTo(lhX + rockW * 0.35, rockY + 1 * s);
    ctx.quadraticCurveTo(lhX + rockW * 0.6, rockY - 2 * s, lhX + rockW * 0.8, rockY + 4 * s);
    ctx.lineTo(lhX + rockW, rockY + 8 * s);
    ctx.strokeStyle = '#666666';
    ctx.lineWidth = 1.5 * s;
    ctx.stroke();

    // === OCEAN WAVES ===
    const oceanY = rockY + rockH - 4 * s;
    const oceanH = 22 * s;
    const paintInset = 28;
    const paintLeft = paintInset;
    const paintWidth = w - paintInset * 2;
    const waveStep = 12 * s;
    const waveSpeed = 25; // canvas pixels per second

    // Full-width ocean background
    ctx.save();
    ctx.beginPath();
    ctx.rect(paintLeft, oceanY, paintWidth, oceanH);
    ctx.clip();

    const oceanGrad = ctx.createLinearGradient(0, oceanY, 0, oceanY + oceanH);
    oceanGrad.addColorStop(0, '#1a6baa');
    oceanGrad.addColorStop(1, '#0d4a7a');
    ctx.fillStyle = oceanGrad;
    ctx.fillRect(paintLeft, oceanY, paintWidth, oceanH);
    ctx.restore(); // end background clip

    // Draw fish — clipped to ocean height; canvas edges clip them horizontally
    ctx.save();
    ctx.beginPath();
    ctx.rect(paintLeft, oceanY, paintWidth, oceanH);
    ctx.clip();

    // Randomized fish pass-throughs (changes every few seconds)
    const rand = (n) => {
      const x = Math.sin(n * 12.9898) * 43758.5453;
      return x - Math.floor(x);
    };
    const drawFish = (fx, fy, size, type, color, dir) => {
      ctx.save();
      ctx.translate(fx, fy);
      if (dir < 0) ctx.scale(-1, 1);

      ctx.fillStyle = color;
      ctx.strokeStyle = 'rgba(255,255,255,0.35)';
      ctx.lineWidth = 0.8 * s;

      if (type === 0) {
        // Oval fish
        ctx.beginPath();
        ctx.ellipse(0, 0, 4.2 * size, 2.2 * size, 0, 0, Math.PI * 2);
        ctx.fill();
      } else if (type === 1) {
        // Pointed fish
        ctx.beginPath();
        ctx.moveTo(-4.2 * size, 0);
        ctx.lineTo(2.8 * size, -2.1 * size);
        ctx.lineTo(4.2 * size, 0);
        ctx.lineTo(2.8 * size, 2.1 * size);
        ctx.closePath();
        ctx.fill();
      } else {
        // Chubbier fish
        ctx.beginPath();
        ctx.ellipse(0.5 * size, 0, 4.6 * size, 2.7 * size, 0, 0, Math.PI * 2);
        ctx.fill();
      }

      // Tail
      ctx.beginPath();
      ctx.moveTo(-4.2 * size, 0);
      ctx.lineTo(-7.0 * size, -2.0 * size);
      ctx.lineTo(-6.0 * size, 0);
      ctx.lineTo(-7.0 * size, 2.0 * size);
      ctx.closePath();
      ctx.fill();

      // Eye
      ctx.fillStyle = '#f3f7ff';
      ctx.beginPath();
      ctx.arc(2.6 * size, -0.5 * size, 0.8 * size, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = '#0b1b2b';
      ctx.beginPath();
      ctx.arc(2.8 * size, -0.45 * size, 0.35 * size, 0, Math.PI * 2);
      ctx.fill();

      ctx.restore();
    };

    const fishColors = ['#f7a64b', '#4fc3f7', '#8ce99a', '#f38bb8', '#ffd166'];
    const fishCount = 18;
    for (let i = 0; i < fishCount; i++) {
      const seed = i * 97 + 31;
      const dir = rand(seed + 1) > 0.5 ? 1 : -1;
      const lane = 3 + rand(seed + 2) * (oceanH - 7);
      const speed = 16 + rand(seed + 3) * 26;
      const size = 0.55 * s + rand(seed + 4) * 0.55 * s;
      const type = Math.floor(rand(seed + 5) * 3);
      const color = fishColors[Math.floor(rand(seed + 6) * fishColors.length)];
      const bob = Math.sin(t * (2.2 + rand(seed + 7) * 1.4) + i * 1.7) * (0.8 * s);
      const fishPad = 70; // keep fish fully off-canvas before entry/after exit
      const span = paintWidth + fishPad * 2;
      const cycleSec = span / speed;
      const phase = rand(seed + 8);
      const progress = (((t / cycleSec) + phase) % 1) * span;
      const travel = progress;
      const fx = dir > 0 ? (paintLeft - fishPad + travel) : (paintLeft + paintWidth + fishPad - travel);
      const fy = oceanY + lane + bob;
      drawFish(fx, fy, size, type, color, dir);
    }

    ctx.restore(); // end fish clip

    const movingLogoOverlays = (promo?.overlays || []).filter(
      (o) => o.key !== 'sponsor' && o.key !== 'lighthouse_graphic' && o.pos && o.pos.startsWith('b')
    );
    const movingLogoItems = movingLogoOverlays
      .map((o) => ({ key: o.key, img: this.loadedLogos[o.key] }))
      .filter((o) => o.img)
      .map((o) => ({ key: o.key, img: o.img, h: 44, w: 44 * (o.img.width / o.img.height) }));

    if (movingLogoItems.length > 0) {
      const convoyGap = 16;
      const convoyW = movingLogoItems.reduce((sum, item) => sum + item.w, 0) + (movingLogoItems.length - 1) * convoyGap;
      const convoyDir = 1;
      const convoySpeed = 42;
      const convoyPad = 24;
      // Include full convoy width in span so reset happens only after train fully exits.
      const convoySpan = paintWidth + convoyW + convoyPad * 2;
      const convoyTravel = ((t * convoySpeed) % convoySpan);
      const convoyStartX = convoyDir > 0
        ? (paintLeft - convoyW - convoyPad + convoyTravel)
        : (paintLeft + paintWidth + convoyPad - convoyTravel - convoyW);
      const convoyY = h - 56 + Math.sin(t * 1.25) * 1.4;

      ctx.save();
      ctx.beginPath();
      ctx.rect(paintLeft, frameBottom + 4, paintWidth, h - (frameBottom + 4));
      ctx.clip();

      const drawConvoy = (startX) => {
        let curX = startX;
        movingLogoItems.forEach((item) => {
          ctx.shadowColor = 'rgba(0,0,0,0.45)';
          ctx.shadowBlur = 4;
          ctx.drawImage(item.img, curX, convoyY, item.w, item.h);
          ctx.shadowColor = 'transparent';
          ctx.shadowBlur = 0;
          curX += item.w + convoyGap;
        });
      };

      ctx.globalAlpha = 0.92;
      drawConvoy(convoyStartX);
      ctx.globalAlpha = 1;
      ctx.restore();
    }

    // Draw wave lines — full canvas width
    ctx.save();
    ctx.beginPath();
    ctx.rect(paintLeft, oceanY, paintWidth, oceanH);
    ctx.clip();

    ctx.strokeStyle = 'rgba(255, 255, 255, 0.4)';
    ctx.lineWidth = 1.5 * s;
    for (let row = 0; row < 3; row++) {
      const wy = oceanY + 4 * s + row * 6 * s;
      const dir = row % 2 === 0 ? 1 : -1;
      const phase = ((t * waveSpeed * dir) % waveStep + waveStep) % waveStep;
      ctx.beginPath();
      for (let x = paintLeft - waveStep; x < paintLeft + paintWidth + waveStep; x += waveStep) {
        const px = x + phase;
        const amp = 2 * s;
        ctx.moveTo(px, wy);
        ctx.quadraticCurveTo(px + 3 * s, wy - amp, px + 6 * s, wy);
        ctx.quadraticCurveTo(px + 9 * s, wy + amp, px + 12 * s, wy);
      }
      ctx.stroke();
    }

    ctx.restore(); // end wave clip

    // Foam at rock base — oscillates gently
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.6)';
    ctx.lineWidth = 2 * s;
    ctx.beginPath();
    for (let x = lhX - rockW; x < lhX + rockW; x += 8 * s) {
      const foamY = oceanY + 1 * s + Math.sin(t * 3 + x * 0.05) * s;
      ctx.moveTo(x, foamY);
      ctx.quadraticCurveTo(x + 2 * s, foamY - 3 * s, x + 4 * s, foamY);
    }
    ctx.stroke();

    ctx.restore();
  }

  loadLogos() {
    this.loadedLogos = {};
    this.overlayOptions.forEach(({ key, src }) => {
      if (src) {
        const img = new Image();
        img.onload = () => { this.loadedLogos[key] = img; };
        img.onerror = () => {};
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

  async deletePromo(postId) {
    const p = this.posts.find(x => x.id === postId);
    if (!p) return;

    if (!confirm(`⚠️ Permanently delete promotional post "${p.title}"? This cannot be undone.`)) return;

    try {
      const resp = await this.auth.fetch(`/api/social/promos/${postId}`, {
        method: 'DELETE'
      });
      if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
      const result = await resp.json();
      if (!result.success) throw new Error(result.message || 'Delete failed');

      alert('✅ Post deleted.');
      await this.loadAndRender();
    } catch (error) {
      alert('Error: ' + error.message);
    }
  }

  // ========== Google Drive Gallery ==========

  async openDriveGallery() {
    const modal = document.createElement('div');
    modal.id = 'drive-gallery-modal';
    modal.style.cssText = 'position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.8);z-index:10000;display:flex;flex-direction:column;align-items:center;justify-content:center;';
    modal.innerHTML = `
      <div style="background:var(--bg-primary);border-radius:12px;width:90vw;max-width:800px;max-height:85vh;display:flex;flex-direction:column;overflow:hidden;">
        <div style="padding:16px 20px;border-bottom:1px solid var(--border-color);display:flex;justify-content:space-between;align-items:center;">
          <h3 style="margin:0;">📱 Google Drive Photos & Videos</h3>
          <button id="drive-close-btn" style="background:none;border:none;font-size:24px;cursor:pointer;color:var(--text-primary);">✕</button>
        </div>
        <div id="drive-gallery-grid" style="flex:1;overflow-y:auto;padding:16px;display:grid;grid-template-columns:repeat(auto-fill,minmax(140px,1fr));gap:10px;align-content:start;">
          <div style="grid-column:1/-1;text-align:center;padding:40px;"><div class="spinner"></div><p>Loading photos from Google Drive...</p></div>
        </div>
        <div id="drive-load-more" style="padding:12px;text-align:center;border-top:1px solid var(--border-color);display:none;">
          <button id="drive-more-btn" class="btn btn-secondary">Load More</button>
        </div>
      </div>
    `;
    document.body.appendChild(modal);
    modal.querySelector('#drive-close-btn').addEventListener('click', () => modal.remove());
    modal.addEventListener('click', (e) => { if (e.target === modal) modal.remove(); });
    this.driveNextPageToken = null;
    await this.loadDriveFiles(modal);
  }

  async loadDriveFiles(modal, append = false) {
    const grid = modal.querySelector('#drive-gallery-grid');
    const loadMoreDiv = modal.querySelector('#drive-load-more');
    const moreBtn = modal.querySelector('#drive-more-btn');
    if (!append) grid.innerHTML = '<div style="grid-column:1/-1;text-align:center;padding:40px;"><div class="spinner"></div><p>Loading...</p></div>';

    try {
      let url = '/api/social/drive/media';
      if (this.driveNextPageToken) url += '?pageToken=' + encodeURIComponent(this.driveNextPageToken);

      const resp = await this.auth.fetch(url);
      const data = await resp.json();

      if (data.error || data.success === false) {
        const errMsg = (data.error && data.error.message) || data.message || 'Failed to load Drive files';
        grid.innerHTML = `<div style="grid-column:1/-1;text-align:center;padding:40px;"><p style="color:#ef4444;">❌ ${this.escapeHtml(errMsg)}</p><p style="font-size:0.85rem;opacity:0.7;">Please log out and log back in with Google to connect Google Drive.</p></div>`;
        return;
      }

      const files = data.files || [];
      if (!append) grid.innerHTML = '';
      if (files.length === 0 && !append) {
        grid.innerHTML = '<div style="grid-column:1/-1;text-align:center;padding:40px;opacity:0.6;">No photos or videos found in your Google Drive.</div>';
        return;
      }

      files.forEach(file => {
        const isVideo = file.mimeType && file.mimeType.startsWith('video/');
        const thumb = file.thumbnailLink || '';
        const card = document.createElement('div');
        card.style.cssText = 'cursor:pointer;border-radius:8px;overflow:hidden;border:2px solid transparent;transition:border-color 0.2s;position:relative;aspect-ratio:1;background:var(--bg-secondary);';
        card.innerHTML = `
          ${thumb ? `<img src="${this.escapeHtml(thumb)}" style="width:100%;height:100%;object-fit:cover;" loading="lazy">` : `<div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:2rem;">${isVideo ? '🎬' : '🖼️'}</div>`}
          ${isVideo ? '<div style="position:absolute;top:4px;right:4px;background:rgba(0,0,0,0.7);color:#fff;font-size:10px;padding:2px 6px;border-radius:4px;">🎬 Video</div>' : ''}
          <div style="position:absolute;bottom:0;left:0;right:0;background:linear-gradient(transparent,rgba(0,0,0,0.8));padding:4px 6px;"><div style="color:#fff;font-size:0.7rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${this.escapeHtml(file.name)}</div></div>
        `;
        card.addEventListener('mouseenter', () => card.style.borderColor = 'var(--accent-color)');
        card.addEventListener('mouseleave', () => card.style.borderColor = 'transparent');
        card.addEventListener('click', () => this.selectDriveFile(file, modal));
        grid.appendChild(card);
      });

      this.driveNextPageToken = data.nextPageToken || null;
      if (this.driveNextPageToken) {
        loadMoreDiv.style.display = 'block';
        const newBtn = moreBtn.cloneNode(true);
        moreBtn.parentNode.replaceChild(newBtn, moreBtn);
        newBtn.addEventListener('click', () => this.loadDriveFiles(modal, true));
      } else {
        loadMoreDiv.style.display = 'none';
      }
    } catch (e) {
      console.error('Drive gallery error:', e);
      if (!append) grid.innerHTML = `<div style="grid-column:1/-1;text-align:center;padding:40px;"><p style="color:#ef4444;">❌ Failed to load Google Drive files</p><p style="font-size:0.85rem;opacity:0.7;">${this.escapeHtml(e.message)}</p></div>`;
    }
  }

  async selectDriveFile(file, modal) {
    const grid = modal.querySelector('#drive-gallery-grid');
    grid.innerHTML = `<div style="grid-column:1/-1;text-align:center;padding:40px;"><div class="spinner"></div><p>Downloading ${this.escapeHtml(file.name)}...</p></div>`;

    try {
      const resp = await this.auth.fetch(`/api/social/drive/download?fileId=${encodeURIComponent(file.id)}`);
      if (!resp.ok) throw new Error('Download failed');
      const blob = await resp.blob();
      const driveFile = new File([blob], file.name, { type: file.mimeType });

      this.currentFile = driveFile;
      const nameEl = this.find('#promo-file-name');
      if (nameEl) nameEl.textContent = `${file.name} (${(blob.size / 1024 / 1024).toFixed(1)} MB) — from Google Drive`;

      this.updateMediaPreview();
      modal.remove();
    } catch (e) {
      alert('Failed to download file from Google Drive: ' + e.message);
      await this.loadDriveFiles(modal);
    }
  }

  escapeHtml(str) {
    if (!str) return '';
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }
}
