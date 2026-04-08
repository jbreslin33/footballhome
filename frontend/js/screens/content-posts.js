// ContentPostsScreen - Upload photos/videos for Instagram posts, reels, or stories
// Optionally adds logo overlays (sponsor, EPYSA, APSL, CASA)
class ContentPostsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.posts = [];
    this.currentFile = null;
    this.currentPreviewUrl = null;
    // Available overlay logos with their display info and default positions
    // Positions: tl=top-left, tc=top-center, tr=top-right, bl=bottom-left, bc=bottom-center, br=bottom-right
    // pos: null means off, a position string means on at that location
    this.positions = ['tl','tc','tr','bl','bc','br'];
    this.positionLabels = { tl:'↖', tc:'↑', tr:'↗', bl:'↙', bc:'↓', br:'↘' };
    this.overlayOptions = [
      { key: 'clubname', label: 'Lighthouse 1893', icon: '🏠', src: null, pos: null },
      { key: 'sponsor', label: 'We Love Junk', icon: '💰', src: '/images/sponsors/welovejunk_logo.png', pos: 'tr' },
      { key: 'epysa', label: 'EPYSA', icon: '🏅', src: '/images/leagues/epysa.png', pos: null },
      { key: 'apsl', label: 'APSL', icon: '⚽', src: '/images/leagues/apsl.png', pos: null },
      { key: 'casa', label: 'CASA', icon: '🏆', src: '/images/leagues/casa.png', pos: null }
    ];
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

  getSelectedOverlays() {
    return this.getSelectedOverlaysWithPositions().map(o => o.key);
  }

  render() {
    const div = document.createElement('div');
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">\u2190 Back</button>
        <h1>\ud83d\udcf7 Content Posts</h1>
        <p class="subtitle">Upload photos & videos for Instagram</p>
      </div>
      <div id="content-posts-area" style="padding: var(--space-4); max-width: 900px; margin: 0 auto;">
        <div class="loading-state"><div class="spinner"></div><p>Loading...</p></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const publishBtn = e.target.closest('.publish-content-btn');
      if (publishBtn) {
        this.publishPost(parseInt(publishBtn.dataset.id));
        return;
      }
      const deleteBtn = e.target.closest('.delete-content-btn');
      if (deleteBtn) {
        this.deletePost(parseInt(deleteBtn.dataset.id));
        return;
      }
    });
    this.loadPosts();
  }

  async loadPosts() {
    try {
      const resp = await this.auth.fetch('/api/social/content');
      const result = await resp.json();
      if (result.success) {
        this.posts = result.data || [];
      }
    } catch (e) {
      console.error('Failed to load content posts:', e);
    }
    this.renderArea();
  }

  renderArea() {
    const area = this.find('#content-posts-area');
    if (!area) return;

    // Existing posts list
    const postsHtml = this.posts.map(p => {
      const isPosted = p.status === 'posted';
      const badge = isPosted
        ? '<span style="background:#22c55e;color:#fff;padding:2px 8px;border-radius:4px;font-size:0.75rem;">\u2705 Posted</span>'
        : p.status === 'error'
        ? `<span style="background:#ef4444;color:#fff;padding:2px 8px;border-radius:4px;font-size:0.75rem;">\u274c ${this.escapeHtml(p.error_message || 'Error')}</span>`
        : '<span style="background:#6b7280;color:#fff;padding:2px 8px;border-radius:4px;font-size:0.75rem;">Draft</span>';

      const preview = p.image_url
        ? `<img src="${this.escapeHtml(p.image_url)}" style="max-width:100%;max-height:400px;object-fit:contain;border-radius:8px;display:block;margin:0 auto;">`
        : p.video_url
        ? `<video src="${this.escapeHtml(p.video_url)}" controls muted style="max-width:100%;max-height:400px;border-radius:8px;display:block;margin:0 auto;"></video>`
        : '<div style="padding:40px;text-align:center;background:#e5e7eb;border-radius:8px;opacity:0.5;">No media uploaded</div>';

      const formatLabel = { post: '\ud83d\uddbc\ufe0f Post', reel: '\ud83c\udfac Reel', story: '\ud83d\udcf1 Story' }[p.format] || p.format;
      const overlayInfo = p.overlay_logos ? p.overlay_logos.split(',').join(', ') : (p.include_sponsor ? 'sponsor' : 'none');

      return `
        <div style="background:var(--bg-secondary);border-radius:12px;overflow:hidden;margin-bottom:8px;">
          <div style="padding:12px 16px;display:flex;justify-content:space-between;align-items:center;">
            <div>
              <div style="font-weight:600;font-size:1.1rem;">${this.escapeHtml(p.title)}</div>
              <div style="font-size:0.85rem;opacity:0.7;">${formatLabel} \u2022 Logos: ${overlayInfo}</div>
              ${p.caption ? `<div style="font-size:0.8rem;opacity:0.6;margin-top:4px;">${this.escapeHtml(p.caption)}</div>` : ''}
            </div>
            <div style="display:flex;align-items:center;gap:8px;">
              ${badge}
              ${!isPosted && p.image_url ? `<button class="btn btn-sm btn-primary publish-content-btn" data-id="${p.id}">\ud83d\ude80 Publish</button>` : ''}
              <button class="btn btn-sm delete-content-btn" data-id="${p.id}" style="background:#ef4444;color:#fff;border:none;padding:4px 10px;border-radius:4px;cursor:pointer;">\ud83d\uddd1\ufe0f Delete</button>
            </div>
          </div>
          <div style="padding:0 16px 16px;">${preview}</div>
        </div>
      `;
    }).join('');

    area.innerHTML = `
      <!-- Upload Form -->
      <div style="background:var(--bg-secondary);border-radius:12px;padding:24px;margin-bottom:24px;">
        <h3 style="margin-top:0;">\ud83d\udce4 New Content Post</h3>

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:16px;">
          <div>
            <label style="display:block;font-weight:600;margin-bottom:6px;">Title</label>
            <input type="text" id="content-title" class="form-input" placeholder="e.g. Training highlights" style="width:100%;box-sizing:border-box;">
          </div>
          <div>
            <label style="display:block;font-weight:600;margin-bottom:6px;">Format</label>
            <select id="content-format" class="form-input" style="width:100%;box-sizing:border-box;">
              <option value="post">\ud83d\uddbc\ufe0f Post (Square)</option>
              <option value="reel">\ud83c\udfac Reel (9:16 Video)</option>
              <option value="story">\ud83d\udcf1 Story (9:16 Image)</option>
            </select>
          </div>
        </div>

        <div style="margin-bottom:16px;">
          <label style="display:block;font-weight:600;margin-bottom:6px;">Upload Photo or Video</label>
          <input type="file" id="content-file" accept="image/*,video/*" style="display:none;">
          <button id="content-file-btn" class="btn btn-secondary" style="width:100%;padding:24px;border:2px dashed var(--border-color);border-radius:8px;text-align:center;cursor:pointer;">
            \ud83d\udcc1 Click to select a file (photo or video)
          </button>
          <div id="content-file-name" style="margin-top:6px;font-size:0.85rem;opacity:0.7;"></div>
        </div>

        <div id="content-preview-area" style="display:none;margin-bottom:16px;text-align:center;">
          <div id="content-preview" style="display:inline-block;position:relative;border-radius:8px;overflow:hidden;max-width:100%;"></div>
        </div>

        <div style="margin-bottom:16px;">
          <label style="display:block;font-weight:600;margin-bottom:8px;">Logo Overlays <span style="font-weight:400;font-size:0.8rem;opacity:0.6;">— tap a grid cell to place, tap again to remove</span></label>
          <div style="display:flex;flex-direction:column;gap:8px;">
            ${this.overlayOptions.map(o => `
              <div style="display:flex;align-items:center;gap:10px;padding:8px 12px;background:var(--bg-primary);border-radius:8px;border:1px solid var(--border-color);">
                ${o.src ? `<img src="${o.src}" style="height:28px;width:28px;object-fit:contain;border-radius:4px;flex-shrink:0;">` : `<span style="font-size:20px;flex-shrink:0;">${o.icon}</span>`}
                <span style="font-size:0.9rem;flex:1;">${o.label}</span>
                <div style="display:grid;grid-template-columns:repeat(3,22px);grid-template-rows:repeat(2,22px);gap:2px;flex-shrink:0;">
                  ${this.positions.map(p => `
                    <button type="button" class="pos-btn" data-key="${o.key}" data-pos="${p}"
                      style="width:22px;height:22px;border:1px solid var(--border-color);border-radius:3px;font-size:10px;line-height:22px;text-align:center;cursor:pointer;padding:0;
                      background:${p === o.pos ? 'var(--accent-color)' : 'var(--bg-secondary)'};color:${p === o.pos ? '#fff' : 'inherit'};">
                      ${this.positionLabels[p]}
                    </button>
                  `).join('')}
                </div>
                <input type="hidden" id="pos-${o.key}" value="${o.pos || 'off'}">
              </div>
            `).join('')}
          </div>
        </div>

        <div style="margin-bottom:16px;">
          <label style="display:block;font-weight:600;margin-bottom:6px;">Caption</label>
          <textarea id="content-caption" class="form-input" rows="4" placeholder="Write your Instagram caption..." style="width:100%;box-sizing:border-box;resize:vertical;"></textarea>
        </div>

        <button id="content-save-btn" class="btn btn-primary" style="width:100%;">\ud83d\udcbe Save Draft</button>
      </div>

      <!-- Existing Posts -->
      ${this.posts.length ? `
        <h3>\ud83d\udcda Previous Content Posts</h3>
        <div style="display:flex;flex-direction:column;gap:12px;">
          ${postsHtml}
        </div>
      ` : ''}
    `;

    // Wire up file picker
    const fileBtn = this.find('#content-file-btn');
    const fileInput = this.find('#content-file');
    if (fileBtn && fileInput) {
      fileBtn.addEventListener('click', () => fileInput.click());
      fileInput.addEventListener('change', (e) => this.handleFileSelected(e));
    }

    // Wire up tic-tac-toe position grid (click = place/move, click active = remove)
    area.querySelectorAll('.pos-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const key = btn.dataset.key;
        const pos = btn.dataset.pos;
        const hidden = this.find(`#pos-${key}`);
        if (!hidden) return;

        const current = hidden.value;
        if (current === pos) {
          // Clicking active cell = turn off
          hidden.value = 'off';
        } else {
          // Clicking any other cell = place/move there
          hidden.value = pos;
        }

        // Update button highlights
        const newVal = hidden.value;
        area.querySelectorAll(`.pos-btn[data-key="${key}"]`).forEach(b => {
          const active = b.dataset.pos === newVal;
          b.style.background = active ? 'var(--accent-color)' : 'var(--bg-secondary)';
          b.style.color = active ? '#fff' : 'inherit';
        });

        if (this.currentFile) this.updatePreview();
      });
    });

    // Wire up save
    const saveBtn = this.find('#content-save-btn');
    if (saveBtn) {
      saveBtn.addEventListener('click', () => this.saveDraft());
    }
  }

  handleFileSelected(e) {
    const file = e.target.files[0];
    if (!file) return;

    this.currentFile = file;
    const nameEl = this.find('#content-file-name');
    if (nameEl) nameEl.textContent = `${file.name} (${(file.size / 1024 / 1024).toFixed(1)} MB)`;

    // Auto-detect format from file type
    const formatSelect = this.find('#content-format');
    if (file.type.startsWith('video/') && formatSelect) {
      formatSelect.value = 'reel';
    }

    this.updatePreview();
  }

  updatePreview() {
    const previewArea = this.find('#content-preview-area');
    const previewEl = this.find('#content-preview');
    if (!previewArea || !previewEl || !this.currentFile) return;

    previewArea.style.display = 'block';

    if (this.currentPreviewUrl) {
      URL.revokeObjectURL(this.currentPreviewUrl);
    }
    this.currentPreviewUrl = URL.createObjectURL(this.currentFile);

    const isVideo = this.currentFile.type.startsWith('video/');
    const selectedWithPos = this.getSelectedOverlaysWithPositions();
    const hasOverlays = selectedWithPos.length > 0;

    // Group selected overlays by position region
    let overlayHtml = '';
    if (hasOverlays) {
      const regionStyles = {
        tl: 'top:6px;left:6px;',
        tc: 'top:6px;left:50%;transform:translateX(-50%);',
        tr: 'top:6px;right:6px;',
        bl: 'bottom:6px;left:6px;',
        bc: 'bottom:6px;left:50%;transform:translateX(-50%);',
        br: 'bottom:6px;right:6px;'
      };

      const regions = {};
      selectedWithPos.forEach(s => {
        if (!regions[s.pos]) regions[s.pos] = [];
        regions[s.pos].push(s.key);
      });

      for (const [pos, keys] of Object.entries(regions)) {
        const items = keys.map(key => {
          if (key === 'clubname') {
            return '<span style="font-size:11px;letter-spacing:2px;color:#f5d442;text-transform:uppercase;font-weight:700;text-shadow:0 0 4px rgba(0,0,0,0.7);">LIGHTHOUSE 1893</span>';
          }
          if (key === 'sponsor') {
            const opt = this.overlayOptions.find(o => o.key === 'sponsor');
            return `<div style="display:flex;align-items:center;gap:6px;">
              <div style="padding:1px 3px;background:rgba(65,105,225,0.9);border-radius:2px;"><span style="font-size:11px;color:#eee;text-transform:uppercase;letter-spacing:1.5px;font-weight:600;">Sponsored by</span></div>
              <img src="${opt.src}" style="height:50px;object-fit:contain;filter:drop-shadow(0 0 4px rgba(0,0,0,0.7));">
            </div>`;
          }
          const opt = this.overlayOptions.find(o => o.key === key);
          return opt ? `<img src="${opt.src}" style="height:28px;object-fit:contain;filter:drop-shadow(0 0 3px rgba(0,0,0,0.6));" title="${opt.label}">` : '';
        }).join('');

        overlayHtml += `<div style="position:absolute;${regionStyles[pos]}display:flex;align-items:center;gap:6px;">${items}</div>`;
      }
    }

    if (isVideo) {
      previewEl.innerHTML = `
        <video src="${this.currentPreviewUrl}" controls muted style="max-width:400px;max-height:400px;display:block;border-radius:8px;"></video>
        ${overlayHtml}
      `;
    } else {
      previewEl.innerHTML = `
        <img src="${this.currentPreviewUrl}" style="max-width:400px;max-height:400px;display:block;border-radius:8px;">
        ${overlayHtml}
      `;
    }
  }

  async saveDraft() {
    const title = (this.find('#content-title')?.value || '').trim();
    const format = this.find('#content-format')?.value || 'post';
    const caption = (this.find('#content-caption')?.value || '').trim();
    const selectedOverlays = this.getSelectedOverlays();
    const selectedWithPos = this.getSelectedOverlaysWithPositions();
    const overlayLogos = selectedWithPos.map(s => `${s.key}:${s.pos}`).join(',');

    if (!title) {
      alert('Please enter a title.');
      return;
    }
    if (!this.currentFile) {
      alert('Please select a file to upload.');
      return;
    }

    const saveBtn = this.find('#content-save-btn');
    if (saveBtn) {
      saveBtn.disabled = true;
      saveBtn.textContent = '\u23f3 Saving...';
    }

    try {
      // 1. Create the post record
      const saveResp = await this.auth.fetch('/api/social/content', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, caption, format, overlay_logos: overlayLogos })
      });
      const saveResult = await saveResp.json();
      if (!saveResult.success) throw new Error(saveResult.message);

      const postId = saveResult.data.id;

      // 2. Generate final media (with optional sponsor overlay) and upload
      if (saveBtn) saveBtn.textContent = '\u23f3 Processing media...';

      const isVideo = this.currentFile.type.startsWith('video/');

      if (isVideo) {
        // For video: read as base64 and upload directly
        // Sponsor overlay on video would require ffmpeg server-side; skip overlay for now
        const b64 = await this.fileToBase64(this.currentFile);
        const uploadResp = await this.auth.fetch(`/api/social/content/${postId}/media`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ data: b64 })
        });
        const uploadResult = await uploadResp.json();
        if (!uploadResult.success) throw new Error(uploadResult.message);
      } else {
        // For images: render with canvas to add logo overlays
        if (saveBtn) saveBtn.textContent = '\u23f3 Generating image...';
        const finalDataUrl = await this.renderImageWithOverlay(this.currentFile, selectedWithPos);
        const uploadResp = await this.auth.fetch(`/api/social/content/${postId}/media`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ data: finalDataUrl })
        });
        const uploadResult = await uploadResp.json();
        if (!uploadResult.success) throw new Error(uploadResult.message);
      }

      // 3. Reset form and reload
      this.currentFile = null;
      this.currentPreviewUrl = null;
      await this.loadPosts();

    } catch (e) {
      alert('Error: ' + e.message);
    } finally {
      if (saveBtn) {
        saveBtn.disabled = false;
        saveBtn.textContent = '\ud83d\udcbe Save Draft';
      }
    }
  }

  fileToBase64(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result);
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
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

        if (overlaysWithPos.length === 0) {
          resolve(canvas.toDataURL('image/jpeg', 0.92));
          return;
        }

        const w = canvas.width;
        const h = canvas.height;
        const margin = w * 0.02;

        // Group by position
        const regions = {};
        overlaysWithPos.forEach(s => {
          if (!regions[s.pos]) regions[s.pos] = [];
          regions[s.pos].push(s.key);
        });

        // Collect images to load (all non-clubname overlays that have src)
        const toLoad = [];
        overlaysWithPos.forEach(s => {
          if (s.key === 'clubname') return;
          const opt = this.overlayOptions.find(o => o.key === s.key);
          if (opt && opt.src) toLoad.push({ key: s.key, src: opt.src, pos: s.pos });
        });

        const drawAll = (loadedImages) => {
          // For each region, render grouped items
          for (const [pos, keys] of Object.entries(regions)) {
            // Calculate anchor point
            let anchorX, anchorY, alignH, alignV;
            if (pos.startsWith('t')) anchorY = margin, alignV = 'top';
            else if (pos.startsWith('b')) anchorY = h - margin, alignV = 'bottom';
            if (pos.endsWith('l')) anchorX = margin, alignH = 'left';
            else if (pos.endsWith('c')) anchorX = w / 2, alignH = 'center';
            else if (pos.endsWith('r')) anchorX = w - margin, alignH = 'right';

            // Measure all items in this region to lay them out
            const items = [];
            const logoH = Math.max(40, h * 0.065);
            const fontSize = Math.max(14, Math.round(w * 0.028));
            const smallFont = Math.max(12, Math.round(w * 0.022));
            const gap = w * 0.015;

            keys.forEach(key => {
              if (key === 'clubname') {
                ctx.font = `700 ${fontSize}px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif`;
                const tw = ctx.measureText('LIGHTHOUSE 1893').width;
                items.push({ type: 'clubname', w: tw, h: fontSize });
              } else if (key === 'sponsor') {
                const limg = loadedImages[key];
                const sH = Math.max(50, h * 0.08);
                const sW = limg ? sH * (limg.width / limg.height) : 0;
                ctx.font = `600 ${smallFont}px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif`;
                const pillW = ctx.measureText('Sponsored by').width + 6;
                items.push({ type: 'sponsor', w: pillW + gap * 0.5 + sW, h: sH, imgW: sW, imgH: sH, pillW, img: limg });
              } else {
                const limg = loadedImages[key];
                if (limg) {
                  const lw = logoH * (limg.width / limg.height);
                  items.push({ type: 'logo', w: lw, h: logoH, img: limg, key });
                }
              }
            });

            // Total width of all items + gaps
            const totalW = items.reduce((sum, it) => sum + it.w, 0) + Math.max(0, items.length - 1) * gap;
            const maxH = Math.max(...items.map(it => it.h));

            // Starting x based on alignment
            let startX;
            if (alignH === 'left') startX = anchorX;
            else if (alignH === 'center') startX = anchorX - totalW / 2;
            else startX = anchorX - totalW;

            let curX = startX;

            items.forEach(item => {
              // Y position
              let itemY;
              if (alignV === 'top') itemY = anchorY;
              else itemY = anchorY - maxH;

              if (item.type === 'clubname') {
                ctx.shadowColor = 'rgba(0,0,0,0.7)';
                ctx.shadowBlur = 6;
                ctx.font = `700 ${fontSize}px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif`;
                ctx.fillStyle = '#f5d442';
                ctx.textAlign = 'left';
                ctx.textBaseline = 'top';
                ctx.fillText('LIGHTHOUSE 1893', curX, itemY + (maxH - item.h) / 2);
                ctx.shadowColor = 'transparent';
                ctx.shadowBlur = 0;
              } else if (item.type === 'sponsor') {
                const midY = itemY + maxH / 2;
                // Text pill
                const pillH = smallFont + 4;
                ctx.fillStyle = 'rgba(65,105,225,0.9)';
                ctx.beginPath();
                ctx.roundRect(curX, midY - pillH / 2, item.pillW, pillH, 2);
                ctx.fill();
                ctx.fillStyle = '#eeeeee';
                ctx.font = `600 ${smallFont}px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif`;
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';
                ctx.fillText('Sponsored by', curX + item.pillW / 2, midY);
                // Logo
                if (item.img) {
                  const lx = curX + item.pillW + gap * 0.5;
                  ctx.shadowColor = 'rgba(0,0,0,0.6)';
                  ctx.shadowBlur = Math.max(4, w * 0.005);
                  ctx.drawImage(item.img, lx, midY - item.imgH / 2, item.imgW, item.imgH);
                  ctx.shadowColor = 'transparent';
                  ctx.shadowBlur = 0;
                }
              } else {
                // League logo
                ctx.shadowColor = 'rgba(0,0,0,0.5)';
                ctx.shadowBlur = 4;
                ctx.drawImage(item.img, curX, itemY + (maxH - item.h) / 2, item.w, item.h);
                ctx.shadowColor = 'transparent';
                ctx.shadowBlur = 0;
              }

              curX += item.w + gap;
            });
          }

          resolve(canvas.toDataURL('image/jpeg', 0.92));
        };

        // Load all images, then draw
        if (toLoad.length === 0) {
          drawAll({});
          return;
        }

        let loadCount = 0;
        const loadedImages = {};
        toLoad.forEach(item => {
          const logo = new Image();
          logo.onload = () => {
            loadedImages[item.key] = logo;
            loadCount++;
            if (loadCount === toLoad.length) drawAll(loadedImages);
          };
          logo.onerror = () => {
            loadCount++;
            if (loadCount === toLoad.length) drawAll(loadedImages);
          };
          logo.src = item.src;
        });
      };
      img.onerror = reject;
      img.src = URL.createObjectURL(file);
    });
  }

  async publishPost(id) {
    if (!confirm('Publish this post to Instagram now?')) return;

    const btn = this.element.querySelector(`.publish-content-btn[data-id="${id}"]`);
    if (btn) {
      btn.disabled = true;
      btn.textContent = '\u23f3 Publishing...';
    }

    try {
      const resp = await this.auth.fetch(`/api/social/content/${id}/publish`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      });
      const result = await resp.json();
      if (!result.success) throw new Error(result.message);
      await this.loadPosts();
    } catch (e) {
      alert('Publish failed: ' + e.message);
      if (btn) {
        btn.disabled = false;
        btn.textContent = '\ud83d\ude80 Publish';
      }
    }
  }

  async deletePost(id) {
    if (!confirm('Delete this content post?')) return;

    try {
      const resp = await this.auth.fetch(`/api/social/content/${id}`, {
        method: 'DELETE'
      });
      const result = await resp.json();
      if (!result.success) throw new Error(result.message);
      await this.loadPosts();
    } catch (e) {
      alert('Delete failed: ' + e.message);
    }
  }

  escapeHtml(str) {
    if (!str) return '';
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }
}
