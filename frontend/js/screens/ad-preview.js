// AdPreviewScreen — Shows active Meta ads exactly as users see them
class AdPreviewScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>📱 Ad Preview</h1>
        <p class="subtitle">Exactly what users see on Facebook & Instagram</p>
      </div>

      <div style="padding: var(--space-4);">
        <div id="ap-loading" style="text-align:center; padding: var(--space-6); opacity:0.6;">Loading ads…</div>
        <div id="ap-error"   style="display:none; color: var(--color-error); padding: var(--space-4); text-align:center;"></div>
        <div id="ap-empty"   style="display:none; text-align:center; padding: var(--space-6); opacity:0.6;">No ads found.</div>
        <div id="ap-list"    style="display:none; display: flex; flex-direction: column; gap: var(--space-5);"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId   = params?.clubId;
    this.clubName = params?.clubName;

    this.element.addEventListener('click', e => {
      if (e.target.closest('.back-btn')) this.navigation.goBack();
    });

    this.loadAds();
  }

  async loadAds() {
    this.find('#ap-loading').style.display = 'block';
    this.find('#ap-error').style.display   = 'none';
    this.find('#ap-list').style.display    = 'none';
    this.find('#ap-empty').style.display   = 'none';

    try {
      const res = await this.auth.fetch('/api/ads/preview');
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const ads = await res.json();

      this.find('#ap-loading').style.display = 'none';

      if (!ads.length) {
        this.find('#ap-empty').style.display = 'block';
        return;
      }

      const list = this.find('#ap-list');
      list.style.display = 'flex';
      list.innerHTML = ads.map(ad => this.renderAdCard(ad)).join('');
    } catch (err) {
      this.find('#ap-loading').style.display = 'none';
      this.find('#ap-error').style.display   = 'block';
      this.find('#ap-error').textContent     = `Failed to load ads: ${err.message}`;
    }
  }

  renderAdCard(ad) {
    const statusColor = ad.status === 'ACTIVE'  ? '#22c55e'
                      : ad.status === 'PAUSED'  ? '#f59e0b'
                      : '#6b7280';
    const statusLabel = ad.status === 'ACTIVE'  ? '● LIVE'
                      : ad.status === 'PAUSED'  ? '⏸ PAUSED'
                      : ad.status;

    // Format body text: newlines → <br>, preserve emoji
    const bodyHtml = ad.body
      ? ad.body.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\n/g,'<br>')
      : '';

    const ctaLabel = {
      SIGN_UP:       'Sign Up',
      LEARN_MORE:    'Learn More',
      APPLY_NOW:     'Apply Now',
      CONTACT_US:    'Contact Us',
      GET_QUOTE:     'Get Quote',
    }[ad.cta] || ad.cta || 'Sign Up';

    return `
      <div style="max-width: 400px; margin: 0 auto; width: 100%;">
        <!-- Status badge -->
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: var(--space-2);">
          <span style="font-size:0.75rem; font-weight:600; color:${statusColor};">${statusLabel}</span>
          <span style="font-size:0.7rem; opacity:0.5; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:60%;" title="${ad.name}">${ad.name}</span>
        </div>

        <!-- Facebook post mockup -->
        <div style="
          background: #fff;
          border-radius: 8px;
          overflow: hidden;
          box-shadow: 0 1px 3px rgba(0,0,0,0.25);
          font-family: -apple-system, 'Segoe UI', sans-serif;
          color: #050505;
        ">
          <!-- Post header -->
          <div style="display:flex; align-items:center; gap:10px; padding:12px 12px 8px;">
            <div style="
              width:40px; height:40px; border-radius:50%;
              background: #1877F2;
              display:flex; align-items:center; justify-content:center;
              font-size:18px; flex-shrink:0;
            ">⚽</div>
            <div style="flex:1; min-width:0;">
              <div style="font-weight:600; font-size:14px;">Footballhome</div>
              <div style="font-size:12px; color:#65676b;">Sponsored · <span style="font-size:11px;">🌐</span></div>
            </div>
            <div style="font-size:20px; color:#65676b; cursor:pointer;">···</div>
          </div>

          <!-- Post body text -->
          ${bodyHtml ? `
          <div style="padding:0 12px 10px; font-size:14px; line-height:1.5; color:#050505;">
            ${bodyHtml}
          </div>` : ''}

          <!-- Post image -->
          ${ad.image_url ? `
          <div style="width:100%; aspect-ratio:1/1; overflow:hidden; background:#f0f2f5;">
            <img src="${ad.image_url}" alt="Ad image"
              style="width:100%; height:100%; object-fit:cover; display:block;"
              onerror="this.style.display='none'; this.parentElement.innerHTML='<div style=&quot;display:flex;align-items:center;justify-content:center;height:200px;opacity:0.4;font-size:14px;&quot;>Image unavailable</div>';"
            />
          </div>` : `
          <div style="width:100%; height:200px; background:#f0f2f5; display:flex; align-items:center; justify-content:center; opacity:0.4; font-size:14px;">No image</div>
          `}

          <!-- Link bar + CTA -->
          <div style="
            display:flex; align-items:center; justify-content:space-between;
            background:#f0f2f5; padding:10px 12px; gap:8px;
          ">
            <div style="min-width:0; flex:1;">
              ${ad.link ? `<div style="font-size:11px; color:#65676b; text-transform:uppercase; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${new URL(ad.link).hostname}</div>` : ''}
              ${ad.headline ? `<div style="font-size:14px; font-weight:600; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${ad.headline}</div>` : ''}
            </div>
            <button style="
              background:#1877F2; color:#fff; border:none; border-radius:6px;
              padding:7px 14px; font-size:14px; font-weight:600; cursor:pointer;
              white-space:nowrap; flex-shrink:0;
            ">${ctaLabel}</button>
          </div>

          <!-- Like/Comment/Share bar -->
          <div style="padding:8px 12px; display:flex; gap:4px; border-top:1px solid #e4e6eb;">
            <button style="flex:1; background:none; border:none; color:#65676b; font-size:14px; font-weight:600; padding:6px; border-radius:6px; cursor:pointer;">👍 Like</button>
            <button style="flex:1; background:none; border:none; color:#65676b; font-size:14px; font-weight:600; padding:6px; border-radius:6px; cursor:pointer;">💬 Comment</button>
            <button style="flex:1; background:none; border:none; color:#65676b; font-size:14px; font-weight:600; padding:6px; border-radius:6px; cursor:pointer;">↗ Share</button>
          </div>
        </div>
      </div>
    `;
  }
}
