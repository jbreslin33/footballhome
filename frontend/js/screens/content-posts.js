// ContentPostsScreen - Upload photos/videos for Instagram posts, reels, or stories
// Optionally adds logo overlays (sponsor, EPYSA, APSL, CASA)
class ContentPostsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.posts = [];
    this.currentFile = null;
    this.currentPreviewUrl = null;
    // Available overlay logos with their display info
    this.overlayOptions = [
      { key: 'sponsor', label: 'We Love Junk (Sponsor)', icon: '💰', src: '/images/sponsors/welovejunk.png', checked: true },
      { key: 'epysa', label: 'EPYSA', icon: '🏅', src: '/images/leagues/epysa.png', checked: false },
      { key: 'apsl', label: 'APSL', icon: '⚽', src: '/images/leagues/apsl.png', checked: false },
      { key: 'casa', label: 'CASA', icon: '🏆', src: '/images/leagues/casa.png', checked: false }
    ];
  }

  getSelectedOverlays() {
    return this.overlayOptions.filter(o => {
      const cb = this.find(`#overlay-${o.key}`);
      return cb ? cb.checked : o.checked;
    }).map(o => o.key);
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

      const thumb = p.image_url
        ? `<img src="${this.escapeHtml(p.image_url)}" style="width:80px;height:80px;object-fit:cover;border-radius:8px;">`
        : '<div style="width:80px;height:80px;background:#e5e7eb;border-radius:8px;display:flex;align-items:center;justify-content:center;">\ud83d\uddbc\ufe0f</div>';

      const formatLabel = { post: '\ud83d\uddbc\ufe0f Post', reel: '\ud83c\udfac Reel', story: '\ud83d\udcf1 Story' }[p.format] || p.format;

      return `
        <div style="display:flex;gap:16px;align-items:center;padding:12px;background:var(--bg-secondary);border-radius:8px;">
          ${thumb}
          <div style="flex:1;">
            <div style="font-weight:600;">${this.escapeHtml(p.title)}</div>
            <div style="font-size:0.85rem;opacity:0.7;">${formatLabel} \u2022 ${p.overlay_logos ? p.overlay_logos.split(',').join(', ') : (p.include_sponsor ? 'sponsor' : 'none')}</div>
            ${p.caption ? `<div style="font-size:0.8rem;opacity:0.6;margin-top:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:400px;">${this.escapeHtml(p.caption)}</div>` : ''}
          </div>
          <div style="display:flex;flex-direction:column;align-items:flex-end;gap:6px;">
            ${badge}
            ${!isPosted && p.image_url ? `<button class="btn btn-sm btn-primary publish-content-btn" data-id="${p.id}">\ud83d\ude80 Publish</button>` : ''}
          </div>
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
          <label style="display:block;font-weight:600;margin-bottom:8px;">Logo Overlays</label>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;">
            ${this.overlayOptions.map(o => `
              <label style="display:flex;align-items:center;gap:8px;cursor:pointer;padding:8px 12px;background:var(--bg-primary);border-radius:8px;border:1px solid var(--border-color);">
                <input type="checkbox" id="overlay-${o.key}" ${o.checked ? 'checked' : ''} style="width:18px;height:18px;">
                <img src="${o.src}" style="height:24px;width:24px;object-fit:contain;border-radius:4px;">
                <span style="font-size:0.9rem;">${o.label}</span>
              </label>
            `).join('')}
          </div>
          <div style="margin-top:4px;font-size:0.8rem;opacity:0.5;">Selected logos appear at the bottom of the image</div>
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

    // Wire up overlay checkboxes for live preview update
    this.overlayOptions.forEach(o => {
      const cb = this.find(`#overlay-${o.key}`);
      if (cb) {
        cb.addEventListener('change', () => {
          if (this.currentFile) this.updatePreview();
        });
      }
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
    const selected = this.getSelectedOverlays();
    const hasOverlays = selected.length > 0;

    // Build overlay HTML showing selected logos
    let overlayHtml = '';
    if (hasOverlays) {
      const logoImgs = selected.map(key => {
        const opt = this.overlayOptions.find(o => o.key === key);
        return opt ? `<img src="${opt.src}" style="height:28px;object-fit:contain;" title="${opt.label}">` : '';
      }).join('');

      overlayHtml = `
        <div style="position:absolute;bottom:0;left:0;right:0;padding:10px 16px;background:linear-gradient(transparent, rgba(0,0,0,0.7));display:flex;align-items:flex-end;justify-content:space-between;">
          <span style="font-size:11px;letter-spacing:2px;color:#f5d442;text-transform:uppercase;font-weight:700;">LIGHTHOUSE 1893</span>
          <div style="display:flex;align-items:center;gap:8px;">${logoImgs}</div>
        </div>
      `;
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
    const overlayLogos = selectedOverlays.join(',');

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
        const finalDataUrl = await this.renderImageWithOverlay(this.currentFile, selectedOverlays);
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

  renderImageWithOverlay(file, overlayKeys) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        canvas.width = img.width;
        canvas.height = img.height;
        const ctx = canvas.getContext('2d');

        // Draw original image
        ctx.drawImage(img, 0, 0);

        if (overlayKeys.length === 0) {
          resolve(canvas.toDataURL('image/jpeg', 0.92));
          return;
        }

        const w = canvas.width;
        const h = canvas.height;
        const barH = Math.max(60, h * 0.08);

        // Semi-transparent gradient bar at bottom
        const grad = ctx.createLinearGradient(0, h - barH * 2, 0, h);
        grad.addColorStop(0, 'rgba(0,0,0,0)');
        grad.addColorStop(0.5, 'rgba(0,0,0,0.5)');
        grad.addColorStop(1, 'rgba(0,0,0,0.7)');
        ctx.fillStyle = grad;
        ctx.fillRect(0, h - barH * 2, w, barH * 2);

        // Club name - bottom left
        const fontSize = Math.max(12, Math.round(w * 0.025));
        ctx.font = `700 ${fontSize}px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif`;
        ctx.fillStyle = '#f5d442';
        ctx.textAlign = 'left';
        ctx.textBaseline = 'bottom';
        ctx.fillText('LIGHTHOUSE 1893', w * 0.03, h - barH * 0.35);

        // Load all selected logo images, then draw them right-aligned
        const logoSrcs = overlayKeys.map(key => {
          const opt = this.overlayOptions.find(o => o.key === key);
          return opt ? opt.src : null;
        }).filter(Boolean);

        if (logoSrcs.length === 0) {
          resolve(canvas.toDataURL('image/jpeg', 0.92));
          return;
        }

        let loaded = 0;
        const logos = [];
        logoSrcs.forEach((src, i) => {
          const logo = new Image();
          logo.crossOrigin = 'anonymous';
          logo.onload = () => {
            logos[i] = logo;
            loaded++;
            if (loaded === logoSrcs.length) {
              // Draw all logos from right to left
              const logoH = barH * 0.7;
              let xPos = w * 0.97;
              for (let j = logos.length - 1; j >= 0; j--) {
                if (!logos[j]) continue;
                const logoW = logoH * (logos[j].width / logos[j].height);
                xPos -= logoW;
                const logoY = h - barH * 0.35 - logoH + fontSize * 0.15;
                ctx.drawImage(logos[j], xPos, logoY, logoW, logoH);
                xPos -= w * 0.02; // gap between logos
              }
              resolve(canvas.toDataURL('image/jpeg', 0.92));
            }
          };
          logo.onerror = () => {
            logos[i] = null;
            loaded++;
            if (loaded === logoSrcs.length) {
              resolve(canvas.toDataURL('image/jpeg', 0.92));
            }
          };
          logo.src = src;
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

  escapeHtml(str) {
    if (!str) return '';
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }
}
