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
        <div id="ap-pills"   style="display:none; gap: var(--space-2); margin-bottom: var(--space-4); flex-wrap:wrap;"></div>
        <div id="ap-list"    style="display:none; display: flex; flex-direction: column; gap: var(--space-5);"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId   = params?.clubId;
    this.clubName = params?.clubName;
    this.allAds   = [];
    this.filter   = 'all';

    this.element.addEventListener('click', e => {
      if (e.target.closest('.back-btn')) this.navigation.goBack();
      const pill = e.target.closest('.ap-pill');
      if (pill) {
        this.filter = pill.dataset.status;
        this.renderPills();
        this.renderList();
      }
    });

    this.loadAds();
  }

  async loadAds() {
    this.find('#ap-loading').style.display = 'block';
    this.find('#ap-error').style.display   = 'none';
    this.find('#ap-list').style.display    = 'none';
    this.find('#ap-pills').style.display   = 'none';
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

      // Default sort: newest created first, regardless of status —
      // status filtering (below) is a separate axis from ordering.
      // Ads with no created_time (shouldn't normally happen) sort last.
      this.allAds = [...ads].sort((a, b) => {
        const ta = a.created_time ? Date.parse(a.created_time) : 0;
        const tb = b.created_time ? Date.parse(b.created_time) : 0;
        return tb - ta;
      });
      this.filter = 'all';

      this.renderPills();
      this.renderList();
    } catch (err) {
      this.find('#ap-loading').style.display = 'none';
      this.find('#ap-error').style.display   = 'block';
      this.find('#ap-error').textContent     = `Failed to load ads: ${err.message}`;
    }
  }

  // Classify an ad by `effective_status` — the real delivery state Meta
  // computes from ad + adset + campaign together — rather than the ad's
  // own `status` field, which stays ACTIVE even when its adset or
  // campaign is paused (i.e. it isn't actually delivering). Falls back
  // to `status` only if Meta ever omits effective_status.
  // Bucket is what pills/filtering key off; label/color drive the badge.
  classify(ad) {
    const es = ad.effective_status || ad.status || 'OTHER';
    if (es === 'ACTIVE') {
      return { bucket: 'ACTIVE', label: '● LIVE', color: '#22c55e' };
    }
    if (es === 'PAUSED' || es === 'CAMPAIGN_PAUSED' || es === 'ADSET_PAUSED') {
      // Show *why* it's not delivering when it's not a plain ad-level pause.
      const reason = es === 'CAMPAIGN_PAUSED' ? 'CAMPAIGN PAUSED'
                   : es === 'ADSET_PAUSED'    ? 'ADSET PAUSED'
                   : 'PAUSED';
      return { bucket: 'PAUSED', label: `⏸ ${reason}`, color: '#f59e0b' };
    }
    if (['PENDING_REVIEW', 'PREAPPROVED', 'PENDING_BILLING_INFO', 'IN_PROCESS'].includes(es)) {
      return { bucket: 'PENDING', label: `🕓 ${es.replace(/_/g, ' ')}`, color: '#3b82f6' };
    }
    if (es === 'DISAPPROVED' || es === 'WITH_ISSUES') {
      return { bucket: 'ISSUES', label: `⚠ ${es.replace(/_/g, ' ')}`, color: '#ef4444' };
    }
    if (es === 'ARCHIVED' || es === 'DELETED') {
      return { bucket: 'ARCHIVED', label: `🗄 ${es}`, color: '#6b7280' };
    }
    return { bucket: 'OTHER', label: es, color: '#6b7280' };
  }

  // Status pills: "All" plus one per bucket actually present in the
  // account, each with a count. There's no separate "new/draft" status
  // in Meta's model — every ad is created PAUSED (see
  // scripts/ads/create-ad.js) and only becomes ACTIVE when manually
  // launched, so a freshly-built ad and a deliberately-paused old one
  // both bucket as PAUSED here. renderAdCard() below adds a "NEW" badge
  // (created_time-based heuristic) to tell them apart at a glance.
  renderPills() {
    const pillsEl = this.find('#ap-pills');
    if (!pillsEl) return;

    const bucketMeta = {
      ACTIVE:   { label: 'Active',   color: '#22c55e' },
      PAUSED:   { label: 'Paused',   color: '#f59e0b' },
      PENDING:  { label: 'Pending',  color: '#3b82f6' },
      ISSUES:   { label: 'Issues',   color: '#ef4444' },
      ARCHIVED: { label: 'Archived', color: '#6b7280' },
      OTHER:    { label: 'Other',    color: '#6b7280' },
    };
    const bucketOrder = ['ACTIVE', 'PAUSED', 'PENDING', 'ISSUES', 'ARCHIVED', 'OTHER'];

    const counts = { all: this.allAds.length };
    for (const ad of this.allAds) {
      const b = this.classify(ad).bucket;
      counts[b] = (counts[b] || 0) + 1;
    }

    const pills = [
      { key: 'all', label: 'All', color: 'var(--text-secondary, #6b7280)' },
      ...bucketOrder.filter(b => counts[b]).map(b => ({ key: b, ...bucketMeta[b] })),
    ];

    pillsEl.style.display = 'flex';
    pillsEl.innerHTML = pills.map(p => {
      const active = this.filter === p.key;
      return `
        <button type="button" class="ap-pill" data-status="${p.key}" style="
          display:flex; align-items:center; gap:6px;
          padding: 6px 14px; border-radius: 999px; cursor:pointer;
          font-size:0.85rem; font-weight:600;
          border: 1px solid ${active ? p.color : 'var(--border-color)'};
          background: ${active ? p.color + '22' : 'transparent'};
          color: ${active ? p.color : 'var(--text-primary)'};
        ">
          <span style="width:8px; height:8px; border-radius:50%; background:${p.color}; flex-shrink:0;"></span>
          ${p.label}
          <span style="opacity:0.6;">${counts[p.key] || 0}</span>
        </button>
      `;
    }).join('');
  }

  renderList() {
    const list = this.find('#ap-list');
    if (!list) return;

    const filtered = this.filter === 'all'
      ? this.allAds
      : this.allAds.filter(ad => this.classify(ad).bucket === this.filter);

    list.style.display = 'flex';
    list.innerHTML = filtered.length
      ? filtered.map(ad => this.renderAdCard(ad)).join('')
      : `<div style="text-align:center; padding: var(--space-6); opacity:0.6;">No ads in this category.</div>`;
  }

  renderAdCard(ad) {
    const { bucket, label: statusLabel, color: statusColor } = this.classify(ad);

    // "NEW" badge: created in the last 7 days and bucketed PAUSED — every
    // ad starts PAUSED (see scripts/ads/create-ad.js) so this is a
    // heuristic for "never launched yet" rather than "we paused an old
    // one," not a real Meta status. A launched-then-repaused ad within 7
    // days would also get this badge; acceptable since the window is short.
    const createdMs = ad.created_time ? Date.parse(ad.created_time) : NaN;
    const isNew = bucket === 'PAUSED' && !isNaN(createdMs) && (Date.now() - createdMs) < 7 * 24 * 60 * 60 * 1000;
    const createdLabel = !isNaN(createdMs)
      ? new Date(createdMs).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
      : '';

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

    const imageBlock = ad.image_url
      ? `<div style="width:100%; aspect-ratio:1/1; overflow:hidden; background:#f0f2f5;">
           <img src="${ad.image_url}" alt="Ad image"
             style="width:100%; height:100%; object-fit:cover; display:block;"
             onerror="this.style.display='none'; this.parentElement.innerHTML='<div style=&quot;display:flex;align-items:center;justify-content:center;height:200px;opacity:0.4;font-size:14px;&quot;>Image unavailable</div>';"
           />
         </div>`
      : `<div style="width:100%; height:200px; background:#f0f2f5; display:flex; align-items:center; justify-content:center; opacity:0.4; font-size:14px;">No image</div>`;

    const profileAvatar = `
      <div style="
        width:40px; height:40px; border-radius:50%;
        background: #fff;
        display:flex; align-items:center; justify-content:center;
        overflow:hidden; flex-shrink:0;
        border:1px solid #e4e6eb;
      "><img src="/images/teams/logos/lighthouse-1893.png" style="width:100%; height:100%; object-fit:contain;" onerror="this.outerHTML='⚽';"></div>`;

    const facebookMockup = `
      <!-- Facebook post mockup -->
      <div style="font-size:11px; font-weight:600; color:#65676b; margin-bottom:6px; text-transform:uppercase; letter-spacing:.05em;">📘 Facebook Feed</div>
      <div style="
        background: #fff;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 1px 3px rgba(0,0,0,0.25);
        font-family: -apple-system, 'Segoe UI', sans-serif;
        color: #050505;
        margin-bottom: var(--space-5);
      ">
        <div style="display:flex; align-items:center; gap:10px; padding:12px 12px 8px;">
          ${profileAvatar}
          <div style="flex:1; min-width:0;">
            <div style="font-weight:600; font-size:14px;">The Lighthouse 1893 Soccer Club</div>
            <div style="font-size:12px; color:#65676b;">Sponsored · <span style="font-size:11px;">🌐</span></div>
          </div>
          <div style="font-size:20px; color:#65676b;">···</div>
        </div>
        ${bodyHtml ? `<div style="padding:0 12px 10px; font-size:14px; line-height:1.5;">${bodyHtml}</div>` : ''}
        ${imageBlock}
        <div style="display:flex; align-items:center; justify-content:space-between; background:#f0f2f5; padding:10px 12px; gap:8px;">
          <div style="min-width:0; flex:1;">
            ${ad.link ? `<div style="font-size:11px; color:#65676b; text-transform:uppercase; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${new URL(ad.link).hostname}</div>` : ''}
            ${ad.headline ? `<div style="font-size:14px; font-weight:600; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${ad.headline}</div>` : ''}
          </div>
          <button style="background:#1877F2; color:#fff; border:none; border-radius:6px; padding:7px 14px; font-size:14px; font-weight:600; cursor:pointer; white-space:nowrap; flex-shrink:0;">${ctaLabel}</button>
        </div>
        <div style="padding:8px 12px; display:flex; gap:4px; border-top:1px solid #e4e6eb;">
          <button style="flex:1; background:none; border:none; color:#65676b; font-size:14px; font-weight:600; padding:6px; border-radius:6px; cursor:pointer;">👍 Like</button>
          <button style="flex:1; background:none; border:none; color:#65676b; font-size:14px; font-weight:600; padding:6px; border-radius:6px; cursor:pointer;">💬 Comment</button>
          <button style="flex:1; background:none; border:none; color:#65676b; font-size:14px; font-weight:600; padding:6px; border-radius:6px; cursor:pointer;">↗ Share</button>
        </div>
      </div>`;

    const instagramMockup = `
      <!-- Instagram feed mockup -->
      <div style="font-size:11px; font-weight:600; color:#65676b; margin-bottom:6px; text-transform:uppercase; letter-spacing:.05em;">📷 Instagram Feed</div>
      <div style="
        background: #fff;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 1px 3px rgba(0,0,0,0.25);
        font-family: -apple-system, 'Segoe UI', sans-serif;
        color: #262626;
      ">
        <!-- IG header -->
        <div style="display:flex; align-items:center; gap:10px; padding:10px 12px;">
          <div style="
            width:32px; height:32px; border-radius:50%;
            background: linear-gradient(45deg, #f09433, #e6683c, #dc2743, #cc2366, #bc1888);
            padding: 2px; flex-shrink:0;
          ">
            <div style="width:100%; height:100%; border-radius:50%; background:#fff; display:flex; align-items:center; justify-content:center; overflow:hidden;"><img src="/images/teams/logos/lighthouse-1893.png" style="width:100%; height:100%; object-fit:contain;" onerror="this.outerHTML='⚽';"></div>
          </div>
          <div style="flex:1; min-width:0;">
            <div style="font-weight:600; font-size:13px; line-height:1.2;">lighthouse1893soccerclub</div>
            <div style="font-size:11px; color:#8e8e8e;">Sponsored</div>
          </div>
          <div style="font-size:18px; color:#262626;">···</div>
        </div>
        <!-- IG image -->
        ${imageBlock}
        <!-- IG CTA button -->
        <div style="padding:8px 12px;">
          <button style="width:100%; background:#1877F2; color:#fff; border:none; border-radius:6px; padding:9px; font-size:14px; font-weight:600; cursor:pointer;">${ctaLabel}</button>
        </div>
        <!-- IG action icons -->
        <div style="display:flex; align-items:center; padding:4px 12px 6px; gap:14px;">
          <span style="font-size:22px; cursor:pointer;">🤍</span>
          <span style="font-size:22px; cursor:pointer;">💬</span>
          <span style="font-size:22px; cursor:pointer;">↗</span>
          <span style="font-size:22px; margin-left:auto; cursor:pointer;">🔖</span>
        </div>
        <!-- IG caption -->
        <div style="padding:0 12px 12px; font-size:13px; line-height:1.5;">
          <span style="font-weight:600;">lighthouse1893soccerclub</span>
          ${bodyHtml ? ` ${bodyHtml}` : ''}
        </div>
      </div>`;

    return `
      <div style="max-width: 400px; margin: 0 auto; width: 100%;">
        <!-- Status badge -->
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: var(--space-3); gap: var(--space-2);">
          <div style="display:flex; align-items:center; gap:8px; min-width:0;">
            <span style="font-size:0.75rem; font-weight:600; color:${statusColor}; white-space:nowrap;">${statusLabel}</span>
            ${isNew ? '<span style="font-size:0.65rem; font-weight:700; color:#fff; background:#3b82f6; padding:1px 7px; border-radius:999px; letter-spacing:.03em;">NEW</span>' : ''}
            ${createdLabel ? `<span style="font-size:0.7rem; opacity:0.45; white-space:nowrap;">${createdLabel}</span>` : ''}
          </div>
          <span style="font-size:0.7rem; opacity:0.5; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:45%;" title="${ad.name}">${ad.name}</span>
        </div>
        ${facebookMockup}
        ${instagramMockup}
      </div>
    `;
  }
}
