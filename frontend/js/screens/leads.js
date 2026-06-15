// LeadsScreen — View Meta lead gen form submissions under Club Admin
class LeadsScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>📋 Leads</h1>
        <p class="subtitle">Interest form submissions from ads</p>
      </div>

      <div style="padding: var(--space-4);">
        <div id="ads-rundown" style="margin-bottom:var(--space-3);"></div>
        <div id="templates-panel" style="margin-bottom:var(--space-3);"></div>
        <div id="leads-loading" style="text-align:center; padding: var(--space-6); opacity:0.6;">Loading leads…</div>
        <div id="leads-error"   style="display:none; color: var(--color-error); padding: var(--space-4); text-align:center;"></div>
        <div id="leads-empty"   style="display:none; text-align:center; padding: var(--space-6); opacity:0.6;">No leads yet.</div>
        <div id="leads-list"    style="display:none;"></div>
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

    this.loadLeads();
  }

  async loadLeads() {
    this.find('#leads-loading').style.display = 'block';
    this.find('#leads-error').style.display   = 'none';
    this.find('#leads-list').style.display    = 'none';
    this.find('#leads-empty').style.display   = 'none';

    try {
      const [leadsRes, spendRes, statsRes, targetingRes, pickupRes] = await Promise.all([
        this.auth.fetch('/api/leads'),
        this.auth.fetch('/api/ads/spend').catch(() => null),
        this.auth.fetch('/api/leads/contact-stats').catch(() => null),
        this.auth.fetch('/api/ads/targeting').catch(() => null),
        this.auth.fetch('/api/leads/next-pickup').catch(() => null),
      ]);
      if (!leadsRes.ok) throw new Error(`HTTP ${leadsRes.status}`);
      const leads = await leadsRes.json();
      const spend = spendRes && spendRes.ok ? await spendRes.json() : [];
      const stats = statsRes && statsRes.ok ? await statsRes.json() : { per_lead: {}, aggregates: {} };
      const targeting = targetingRes && targetingRes.ok ? await targetingRes.json() : [];
      const pickup    = pickupRes && pickupRes.ok ? await pickupRes.json() : { event: null };
      this._nextPickup = pickup.event || null;

      this.find('#leads-loading').style.display = 'none';

      // Render targeting rundown at top — always, even if there are no leads yet
      this.renderAdsRundown(targeting);
      this.renderTemplatesPanel();

      // Always render the live-ad columns — even with zero leads — so
      // the coach sees an empty board for each currently-active ad.
      this.find('#leads-list').style.display = 'block';
      this._leads = leads;
      this._spend = spend;
      this._stats = stats;
      this._targeting = targeting;
      this.renderLeads(leads, spend, stats, targeting);
    } catch (err) {
      this.find('#leads-loading').style.display = 'none';
      this.find('#leads-error').style.display   = 'block';
      this.find('#leads-error').textContent     = `Failed to load leads: ${err.message}`;
    }
  }

  async refreshStats() {
    try {
      const res = await this.auth.fetch('/api/leads/contact-stats');
      if (!res.ok) return;
      this._stats = await res.json();
      this.renderLeads(this._leads, this._spend, this._stats, this._targeting);
    } catch {}
  }

  renderLeads(leads, spend = [], stats = { per_lead: {}, aggregates: {} }, targeting = []) {
    const container = this.find('#leads-list');
    const agg = stats.aggregates || {};
    // Bot-risk thresholds for a personal long-code number
    //   safe   : <10/hr, <30/day, <=3 in last 5min
    //   warn   : 10-20/hr OR 30-50/day OR 4-5 in 5min
    //   danger : >20/hr OR >50/day OR >5 in 5min
    const txt5 = agg.texts_5min || 0, txtH = agg.texts_hour || 0, txtD = agg.texts_day || 0;
    let risk = 'safe';
    if (txt5 > 5 || txtH > 20 || txtD > 50) risk = 'danger';
    else if (txt5 > 3 || txtH > 10 || txtD > 30) risk = 'warn';
    const riskColors = {
      safe:   { bg:'#0a3d2a', dot:'#10b981', label:'✓ Safe',    msg:'Well below carrier filter thresholds.' },
      warn:   { bg:'#3d2a0a', dot:'#f59e0b', label:'⚠ Warning',  msg:'Approaching carrier filter thresholds. Slow down sends.' },
      danger: { bg:'#3d0a0a', dot:'#ef4444', label:'✕ Danger',  msg:'Likely to get flagged. STOP sending texts for 24h.' },
    };
    const r = riskColors[risk];

    // ── Columns = ACTIVE Meta ads (live from /api/ads/targeting) ─────
    // We report only on what's currently live. Each ACTIVE ad becomes
    // its own column, keyed by ad_id.  Funnel label (e.g. "PR Men",
    // "Boys Club (Grades 1–6)") is used purely for color-coding the
    // column header so the same family of ads stays visually grouped.
    const FUNNEL_COLORS = {
      'Brazil Men':              '#15803d',
      'U23 Men':                 '#1d4ed8',
      'PR Men':                  '#7c3aed',
      'U23 Women':               '#be185d',
      'Tri County Women':        '#9d174d',
      "Men's Club":              '#1d4ed8',
      "Women's Club":            '#be185d',
      'APSL / Liga 1':           '#f59e0b',
      'Youth (Grades 1–6)':      '#c9a14a',
      'Boys Club (Grades 1–6)':  '#0e7490',
      'Boys Club (K-12)':        '#0e7490',
      'Girls Club (Grades 1–6)': '#db2777',
      'Girls Club (K-12)':       '#db2777',
    };
    const DEFAULT_COLOR = '#475569';

    // Sort active ads by funnel label (canonical kanban order) so the
    // columns stay stable across reloads.
    const FUNNEL_ORDER = [
      'Brazil Men', 'U23 Men', 'PR Men', "Men's Club",
      'U23 Women', 'Tri County Women', "Women's Club",
      'APSL / Liga 1',
      'Youth (Grades 1–6)',
      'Boys Club (Grades 1–6)', 'Boys Club (K-12)',
      'Girls Club (Grades 1–6)', 'Girls Club (K-12)',
    ];
    const funnelRank = (label) => {
      const i = FUNNEL_ORDER.indexOf(label);
      return i === -1 ? 999 : i;
    };

    const activeAds = (targeting || [])
      .filter(a => a.status === 'ACTIVE')
      .map(a => {
        const funnel = this.adFunnelLabel(a) || '(no form)';
        return {
          ad_id:   a.ad_id,
          ad_name: a.ad_name || a.ad_id,
          funnel,
          color:   FUNNEL_COLORS[funnel] || DEFAULT_COLOR,
          form_id: a.form_id,
          link_url: a.link_url || null,
          daily:   Number(a.daily_budget_usd || 0),
          spend:   Number(a.spend || 0),
          metaLeads: Number(a.leads || 0), // Meta-reported leads (CPL source)
          start:   a.start_time || null,
          days:    a.start_time ? Math.max(0, Math.floor((Date.now() - new Date(a.start_time).getTime()) / 86400000)) : 0,
        };
      })
      .sort((x, y) => {
        const dr = funnelRank(x.funnel) - funnelRank(y.funnel);
        if (dr !== 0) return dr;
        return x.ad_name.localeCompare(y.ad_name);
      });

    const COLUMNS = activeAds.map(a => a.ad_id);
    const adById  = {};
    for (const a of activeAds) adById[a.ad_id] = a;

    // Load hidden-column preferences (persisted in localStorage, keyed
    // by ad_id).  Stale ad_ids (paused/archived since last visit) are
    // dropped on read so the toggle list stays clean.
    const HIDDEN_KEY = 'leads.hiddenColumns';
    let hidden;
    try {
      hidden = new Set(JSON.parse(localStorage.getItem(HIDDEN_KEY) || '[]'));
    } catch { hidden = new Set(); }
    for (const c of [...hidden]) if (!COLUMNS.includes(c)) hidden.delete(c);
    const visible = COLUMNS.filter(c => !hidden.has(c));

    const fmt = (n) => `$${(n || 0).toFixed(2)}`;

    // Bucket leads by ad_id.  Leads whose ad_id doesn't match any
    // currently-ACTIVE ad are intentionally hidden — per product rule
    // "no dead ads. only live but all of them. that is what we will
    // report on." Use _orphanLeadCount only to surface the count to
    // the coach so they know how many leads are not on the board.
    const grouped = {};
    for (const adId of COLUMNS) grouped[adId] = [];
    let orphanCount = 0;
    for (const l of leads) {
      if (l.ad_id && grouped[l.ad_id]) grouped[l.ad_id].push(l);
      else orphanCount++;
    }
    for (const adId of COLUMNS) {
      grouped[adId].sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
    }

    // Visible lead count (only counts leads in shown columns)
    const visibleLeadCount = visible.reduce((n, c) => n + grouped[c].length, 0);

    container.innerHTML = `
      <div style="display:flex; align-items:center; gap:var(--space-3); flex-wrap:wrap; margin-bottom:var(--space-2); padding:var(--space-2) var(--space-3); background:${r.bg}; border-radius:var(--radius-md); border-left:4px solid ${r.dot};">
        <div style="flex:1; min-width:200px;">
          <div style="font-weight:700; font-size:0.85rem;"><span style="color:${r.dot};">●</span> SMS bot-risk: ${r.label}</div>
          <div style="font-size:0.75rem; opacity:0.85;">${r.msg}</div>
        </div>
        <div style="display:flex; gap:var(--space-3); font-size:0.75rem; opacity:0.9;">
          <div title="texts in last 5 min"><strong>${txt5}</strong> /5m</div>
          <div title="texts in last hour"><strong>${txtH}</strong> /hr</div>
          <div title="texts in last 24h"><strong>${txtD}</strong> /day</div>
          <div title="texts in last 7d"><strong>${agg.texts_week || 0}</strong> /wk</div>
          <div title="emails in last 24h" style="opacity:0.7;">✉ <strong>${agg.emails_day || 0}</strong> /day</div>
        </div>
      </div>
      <div style="display:flex; align-items:center; gap:var(--space-3); flex-wrap:wrap; margin-bottom:var(--space-3); padding:var(--space-2) var(--space-3); background:var(--bg-secondary); border-radius:var(--radius-md);">
        <span style="opacity:0.7; font-size:0.8rem; font-weight:600;">Show:</span>
        ${COLUMNS.length === 0 ? `<span style="opacity:0.6; font-size:0.8rem;">No live ads on Meta right now.</span>` : ''}
        ${COLUMNS.map(adId => {
          const a = adById[adId];
          return `
          <label style="display:inline-flex; align-items:center; gap:6px; font-size:0.8rem; cursor:pointer; user-select:none; padding:2px 6px; border-radius:4px; border-left:3px solid ${a.color};" title="${a.ad_name}">
            <input type="checkbox" class="col-toggle" data-col="${adId}" ${hidden.has(adId) ? '' : 'checked'} style="cursor:pointer;">
            ${a.funnel} <span style="opacity:0.55;">(${grouped[adId].length})</span>
          </label>`;
        }).join('')}
      </div>
      <p style="opacity:0.6; font-size:0.85rem; margin-bottom:var(--space-3);">
        ${visibleLeadCount} of ${leads.length} lead${leads.length !== 1 ? 's' : ''} shown
        ${orphanCount > 0 ? ` &middot; <span style="opacity:0.7;">${orphanCount} hidden (from paused / archived ads)</span>` : ''}
      </p>
      ${COLUMNS.length === 0 ? `
        <div style="text-align:center; padding:var(--space-6); opacity:0.6;">
          No live ads on Meta. Activate an ad to see its leads here.
        </div>
      ` : visible.length === 0 ? `
        <div style="text-align:center; padding:var(--space-6); opacity:0.5;">All columns hidden — check a box above to show leads.</div>
      ` : `
      <div style="display:grid; grid-template-columns:repeat(${visible.length},minmax(220px,1fr)); gap:var(--space-3); align-items:start; overflow-x:auto;">
        ${visible.map(adId => {
          const a = adById[adId];
          const cpl = a.metaLeads > 0 && a.spend > 0 ? (a.spend / a.metaLeads) : null;
          return `
          <div>
            <div style="font-weight:700; font-size:0.85rem; color:#fff; background:${a.color}; border-radius:var(--radius-sm); padding:var(--space-1) var(--space-2); margin-bottom:var(--space-1); text-align:center;" title="${a.ad_name}">
              ${a.funnel} <span style="opacity:0.8;">(${grouped[adId].length})</span>
            </div>
            <div style="font-size:0.65rem; opacity:0.65; text-align:center; margin-bottom:4px; line-height:1.3; word-break:break-word;" title="ad_id ${adId}">
              ${a.ad_name}
            </div>
            <div style="font-size:0.7rem; opacity:0.85; text-align:center; margin-bottom:var(--space-2); line-height:1.4;">
              <span style="color:#10b981;">●</span> ${fmt(a.daily)}/day · ${a.days}d running<br>
              Spent ${fmt(a.spend)}${cpl !== null ? ` · ${fmt(cpl)}/lead` : ''}
            </div>
            <div style="display:flex; flex-direction:column; gap:var(--space-2);">
              ${grouped[adId].map(l => this.renderLead(l, a.funnel, stats.per_lead || {})).join('') || '<div style="opacity:0.4; font-size:0.8rem; text-align:center; padding:var(--space-2);">none</div>'}
            </div>
          </div>
        `;}).join('')}
      </div>`}
    `;

    // Wire checkbox toggles → persist + re-render with cached data
    container.querySelectorAll('.col-toggle').forEach(cb => {
      cb.addEventListener('change', () => {
        const col = cb.getAttribute('data-col');
        if (cb.checked) hidden.delete(col); else hidden.add(col);
        try { localStorage.setItem(HIDDEN_KEY, JSON.stringify([...hidden])); } catch {}
        this.renderLeads(this._leads || leads, this._spend || spend, this._stats || stats, this._targeting || targeting);
      });
    });

    // Wire contact action buttons (text/email/save)
    container.querySelectorAll('.contact-btn').forEach(btn => {
      btn.addEventListener('click', (e) => this.onContactClick(e));
    });
  }

  formLabel(formId) {
    const map = {
      '1668570657681917': 'PR Men',
      '2062202517690808': 'PR Men',
      '875990184755538':  'U23 Women',
      '1696381158350766': 'U23 Women',
      '1552835789741946': 'Brazil Men',
      '1333581472007910': 'Brazil Men',
      '1052472267432735': 'U23 Men',
      '1773598717166962': 'APSL / Liga 1',
      '3249608418562710': 'Youth (Grades 1–6)',
      '1704106777282059': 'Boys Club (Grades 1–6)',
      '1571742281184926': 'Girls Club (Grades 1–6)',
      // Slim forms (name/email/phone only) created 2026-06-10 via
      // scripts/recreate-lead-forms.js — old IDs above stay mapped so
      // historical leads keep their column.
      '2471488896628970': 'Boys Club (Grades 1–6)',
      '1277787647463515': 'Youth (Grades 1–6)',
      '1008195014960429': 'Girls Club (Grades 1–6)',
      // Tri County Women — form id TBD (no live ad yet).
    };
    return map[formId] || null;
  }

  // Funnel label for an ad object. Resolution order:
  //   1. Ad name carries an explicit grade band like "(K-12)" or
  //      "(Grades 1–6)" — use that to disambiguate Boys/Girls Club
  //      ads that share a LeagueApps URL across grade bands.
  //   2. form_id — lead-form ads resolve via formLabel().
  //   3. link_url — direct-CTA ads (no form) fall back to URL pattern
  //      matching on link_url so they don't all bucket as "(no form)".
  adFunnelLabel(ad) {
    const name = (ad.ad_name || '').toLowerCase();
    const url  = (ad.link_url || '').toLowerCase();
    const isK12     = /\(k-?12\)/.test(name);
    const isGrade16 = /\(grades?\s*1[\u2013\-]\s*6\)/.test(name);

    // Boys/Girls Club have parallel K-12 and Grades 1–6 ads sharing the
    // same LeagueApps URL — ad name is the only way to tell them apart.
    if (/boys club/.test(name) || /\bboys-club\b/.test(url)) {
      if (isK12)     return 'Boys Club (K-12)';
      if (isGrade16) return 'Boys Club (Grades 1–6)';
    }
    if (/girls club/.test(name) || /\bgirls-club\b/.test(url)) {
      if (isK12)     return 'Girls Club (K-12)';
      if (isGrade16) return 'Girls Club (Grades 1–6)';
    }

    // Fall back to form_id map, then URL pattern.
    const byForm = this.formLabel(ad.form_id);
    if (byForm) return byForm;
    if (!url) return null;
    if (/\bmens-club\b/.test(url))   return "Men's Club";
    if (/\bwomens-club\b/.test(url)) return "Women's Club";
    if (/\bboys-club\b/.test(url))   return 'Boys Club (Grades 1–6)';
    if (/\bgirls-club\b/.test(url)) return 'Girls Club (Grades 1–6)';
    return null;
  }

  // ── Ads rundown ─────────────────────────────────────────────────────
  // Renders a per-ad summary at the top of the leads screen so the coach
  // can spot targeting/perf problems (geo leaks, dead ads, CPL spikes)
  // without leaving the page. Data comes from /api/ads/targeting which
  // proxies Meta Marketing API and is polled on every screen load.
  renderAdsRundown(ads) {
    const root = this.find('#ads-rundown');
    if (!root) return;
    if (!ads || ads.length === 0) { root.innerHTML = ''; return; }

    // Group ads by funnel label; show ACTIVE first, then others.
    // Within each status, sort by canonical funnel order (same order as
    // the kanban columns) so the rundown is stable + scannable.
    const FUNNEL_ORDER = [
      'Brazil Men', 'U23 Men', 'PR Men', "Men's Club",
      'U23 Women', 'Tri County Women', "Women's Club",
      'APSL / Liga 1',
      'Youth (Grades 1–6)',
      'Boys Club (Grades 1–6)', 'Boys Club (K-12)',
      'Girls Club (Grades 1–6)', 'Girls Club (K-12)',
    ];
    const funnelRank = (label) => {
      const i = FUNNEL_ORDER.indexOf(label);
      return i === -1 ? 999 : i;
    };
    const decorated = ads.map(a => ({ ...a, funnel: this.adFunnelLabel(a) || '(no form)' }));
    const statusRank = { ACTIVE: 0, PENDING_REVIEW: 1, IN_PROCESS: 2, PAUSED: 3, ARCHIVED: 4, DELETED: 5 };
    decorated.sort((x, y) => {
      const ds = (statusRank[x.status] ?? 9) - (statusRank[y.status] ?? 9);
      if (ds !== 0) return ds;
      return funnelRank(x.funnel) - funnelRank(y.funnel);
    });

    // Identify problems for the warning banner at the top
    const warnings = [];
    for (const a of decorated) {
      if (a.status !== 'ACTIVE') continue;
      // Geo leak: top region by impressions is NOT Pennsylvania/New Jersey/Delaware
      const top = a.regions?.[0];
      if (top && top.impressions > 50) {
        const triState = ['Pennsylvania','New Jersey','Delaware'];
        if (!triState.includes(top.region)) {
          warnings.push({ kind:'geo-leak', ad: a, detail: `Top region is ${top.region} (${top.impressions} imp)` });
        }
      }
      // CPL > $20 on adult ads (warn) / > $30 (danger)
      const cpl = a.leads > 0 ? a.spend / a.leads : null;
      if (cpl !== null && cpl > 30) warnings.push({ kind:'cpl-danger', ad: a, detail: `$${cpl.toFixed(2)}/lead` });
      else if (cpl !== null && cpl > 20) warnings.push({ kind:'cpl-warn', ad: a, detail: `$${cpl.toFixed(2)}/lead` });
      // Geo not locked down (must be 'zips' allowlist OR pin at Erie Ave)
      const goodGeo = a.geo?.kind === 'zips'
                   || (a.geo?.kind === 'pin' && /Erie/i.test(a.geo?.address || ''));
      if (!goodGeo) {
        warnings.push({ kind:'geo-loose', ad: a, detail: a.geo?.label || 'unknown' });
      }
      // Includes "recent" visitors (people just passing through Philly)
      if (a.geo?.location_types?.includes('recent')) {
        warnings.push({ kind:'location-recent', ad: a, detail: 'location_types includes "recent"' });
      }
      // Spending budget but no leads in 7+ days running
      const days = a.start_time ? Math.floor((Date.now() - new Date(a.start_time).getTime()) / 86400000) : 0;
      if (a.spend > 50 && a.leads === 0) warnings.push({ kind:'no-leads', ad: a, detail: `$${a.spend.toFixed(2)} spent, 0 leads (${days}d)` });
    }

    const fmt$ = (n) => `$${(n || 0).toFixed(2)}`;
    const statusPill = (s) => {
      const colors = { ACTIVE:'#10b981', PAUSED:'#6b7280', PENDING_REVIEW:'#f59e0b', IN_PROCESS:'#f59e0b', ARCHIVED:'#374151', DELETED:'#991b1b' };
      const c = colors[s] || '#6b7280';
      return `<span style="background:${c}; color:#fff; padding:1px 6px; border-radius:8px; font-size:0.65rem; font-weight:700; letter-spacing:0.04em;">${s}</span>`;
    };
    const geoBadge = (g) => {
      if (!g) return '<span style="opacity:0.6;">no geo</span>';
      const ok = g.kind === 'zips'
              || (g.kind === 'pin' && /Erie/i.test(g.address || ''));
      const color = ok ? '#10b981' : '#f59e0b';
      const lt = (g.location_types || []).join('+') || '?';
      return `<span style="color:${color};">${g.label || '?'}</span> <span style="opacity:0.5; font-size:0.7rem;">(${lt})</span>`;
    };
    const audBadge = (a) => {
      const ages = (a.age_min && a.age_max) ? `${a.age_min}–${a.age_max}` : '?';
      const g = a.genders ? (a.genders.includes(1) && a.genders.includes(2) ? 'All' : a.genders.includes(1) ? 'M' : 'F') : 'All';
      return `ages ${ages} · ${g}`;
    };
    const regionRow = (rs) => {
      if (!rs || rs.length === 0) return '<span style="opacity:0.5;">no region data yet</span>';
      return rs.slice(0, 3).map(r => {
        const triState = ['Pennsylvania','New Jersey','Delaware'].includes(r.region);
        const color = triState ? '#10b981' : '#ef4444';
        return `<span style="color:${color};">${r.region} ${r.impressions}🖼/${r.clicks}🖱/${r.leads}📥</span>`;
      }).join(' · ');
    };

    // Pop-out preview buttons — open Meta-hosted iframe preview in a new
    // tab.  Backend (/api/ads/:adId/preview) proxies to Meta and 302s to
    // the iframe URL so the access token stays server-side.
    const previewBtns = (adId) => {
      const btn = (fmt, label, title) =>
        `<a href="/api/ads/${encodeURIComponent(adId)}/preview?format=${fmt}"
            target="_blank" rel="noopener"
            title="${title}"
            style="display:inline-block; padding:1px 6px; margin:0 2px 2px 0;
                   font-size:0.7rem; border-radius:6px;
                   background:var(--bg-tertiary, #374151); color:#e5e7eb;
                   text-decoration:none; border:1px solid var(--border-color, #4b5563);"
         >${label}</a>`;
      return [
        btn('feed',     '📘 FB',    'Facebook mobile feed preview'),
        btn('ig',       '📷 IG',    'Instagram feed preview'),
        btn('ig_story', '📱 Story', 'Instagram story preview'),
      ].join('');
    };

    const warnBanner = warnings.length > 0 ? `
      <div style="background:#3d2a0a; border-left:4px solid #f59e0b; padding:var(--space-2) var(--space-3); border-radius:var(--radius-md); margin-bottom:var(--space-2);">
        <div style="font-weight:700; font-size:0.85rem; color:#f59e0b;">⚠ ${warnings.length} issue${warnings.length>1?'s':''} detected</div>
        <ul style="margin:4px 0 0 0; padding-left:18px; font-size:0.75rem; opacity:0.9;">
          ${warnings.slice(0, 8).map(w => `<li><strong>${w.ad.funnel}</strong> [${w.kind}]: ${w.detail}</li>`).join('')}
          ${warnings.length > 8 ? `<li>… and ${warnings.length - 8} more</li>` : ''}
        </ul>
      </div>` : '';

    const collapsedKey = 'leads.rundownCollapsed';
    let collapsed = false;
    try { collapsed = localStorage.getItem(collapsedKey) === '1'; } catch {}

    root.innerHTML = `
      ${warnBanner}
      <details ${collapsed ? '' : 'open'} style="background:var(--bg-secondary); border-radius:var(--radius-md); padding:var(--space-2) var(--space-3);">
        <summary style="cursor:pointer; font-weight:700; font-size:0.9rem; user-select:none; outline:none;">
          📡 Ad Targeting Rundown <span style="opacity:0.5; font-weight:400; font-size:0.75rem;">(${decorated.length} ads · live from Meta)</span>
        </summary>
        <div style="overflow-x:auto; margin-top:var(--space-2);">
          <table style="width:100%; font-size:0.75rem; border-collapse:collapse;">
            <thead style="opacity:0.7; text-align:left;">
              <tr>
                <th style="padding:4px 8px;">Ad</th>
                <th style="padding:4px 8px;">Status</th>
                <th style="padding:4px 8px;">Preview</th>
                <th style="padding:4px 8px;">Geo</th>
                <th style="padding:4px 8px;">Audience</th>
                <th style="padding:4px 8px; text-align:right;">$/day</th>
                <th style="padding:4px 8px; text-align:right;">Spend</th>
                <th style="padding:4px 8px; text-align:right;">Imp</th>
                <th style="padding:4px 8px; text-align:right;">Clicks</th>
                <th style="padding:4px 8px; text-align:right;">Leads</th>
                <th style="padding:4px 8px; text-align:right;">CPL</th>
                <th style="padding:4px 8px;">Top regions (30d)</th>
              </tr>
            </thead>
            <tbody>
              ${decorated.map(a => {
                const cpl = a.leads > 0 ? `$${(a.spend / a.leads).toFixed(2)}` : '—';
                const dim = a.status !== 'ACTIVE' ? 'opacity:0.55;' : '';
                return `
                  <tr style="border-top:1px solid var(--bg-tertiary, #1f2937); ${dim}">
                    <td style="padding:6px 8px;"><strong>${a.funnel}</strong><br><span style="opacity:0.5; font-size:0.7rem;">${a.ad_name}</span></td>
                    <td style="padding:6px 8px;">${statusPill(a.status)}</td>
                    <td style="padding:6px 8px; white-space:nowrap;">${previewBtns(a.ad_id)}</td>
                    <td style="padding:6px 8px;">${geoBadge(a.geo)}</td>
                    <td style="padding:6px 8px;">${audBadge(a)}</td>
                    <td style="padding:6px 8px; text-align:right;">${fmt$(a.daily_budget_usd)}</td>
                    <td style="padding:6px 8px; text-align:right;">${fmt$(a.spend)}</td>
                    <td style="padding:6px 8px; text-align:right;">${a.impressions.toLocaleString()}</td>
                    <td style="padding:6px 8px; text-align:right;">${a.clicks.toLocaleString()}</td>
                    <td style="padding:6px 8px; text-align:right;">${a.leads}</td>
                    <td style="padding:6px 8px; text-align:right;">${cpl}</td>
                    <td style="padding:6px 8px; font-size:0.7rem;">${regionRow(a.regions)}</td>
                  </tr>
                `;
              }).join('')}
            </tbody>
          </table>
        </div>
      </details>
    `;

    // Persist collapsed/open state
    const det = root.querySelector('details');
    if (det) det.addEventListener('toggle', () => {
      try { localStorage.setItem(collapsedKey, det.open ? '0' : '1'); } catch {}
    });
  }

  // ── Message Templates panel ─────────────────────────────────────────
  // Renders every initial outreach blurb (SMS + email) and every reply
  // snippet for every funnel, with a Copy-to-clipboard button on each.
  // Lets the coach read & critique exactly what gets sent without needing
  // a real lead in front of them.  Tokens like {first} render as a
  // bracketed placeholder ([Name]) since there's no specific lead.
  renderTemplatesPanel() {
    const root = this.find('#templates-panel');
    if (!root) return;

    // Canonical funnel labels — one of each funnel (formLabel() has dupes
    // because the same funnel often has multiple Meta form IDs).
    const FUNNELS = [
      'Brazil Men',
      'PR Men',
      'U23 Men',
      'APSL / Liga 1',
      'U23 Women',
      'Tri County Women',
      'Boys Club (Grades 1–6)',
      'Girls Club (Grades 1–6)',
      'Youth (Grades 1–6)',
    ];

    // Synthetic "preview" lead — fillTemplate() will sub {first} → [Name].
    const previewLead = { name: '[Name]', phone: '[Phone]' };

    const collapsedKey = 'leads.templatesPanelCollapsed';
    let collapsed = false;
    try { collapsed = localStorage.getItem(collapsedKey) === '1'; } catch {}

    const esc = (s) => String(s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

    const blurbBlock = (title, body, todo = false) => {
      const dim = todo ? 'opacity:0.55;' : '';
      const warn = todo ? ' <span style="color:#f59e0b;" title="Placeholder — fill this in">⚠</span>' : '';
      return `
        <div style="background:var(--bg-primary, #0f172a); border-radius:var(--radius-sm); padding:var(--space-2); margin-bottom:var(--space-2); ${dim}">
          <div style="display:flex; justify-content:space-between; align-items:center; gap:var(--space-2); margin-bottom:4px;">
            <strong style="font-size:0.8rem;">${esc(title)}${warn}</strong>
            <button class="copy-btn btn btn-secondary" data-copy="${esc(body)}" style="font-size:0.7rem; padding:2px 8px;">📋 Copy</button>
          </div>
          <pre style="white-space:pre-wrap; word-break:break-word; margin:0; font-family:inherit; font-size:0.78rem; line-height:1.45; opacity:0.92;">${esc(body)}</pre>
        </div>
      `;
    };

    const funnelBlock = (label) => {
      const t        = this.messageTemplate(label);
      const subject  = this.fillTemplate(t.subject, previewLead);
      const email    = this.fillTemplate(t.email,   previewLead);
      const snippets = this.messageSnippets(label);

      // Render in same tier order as the on-card chips:
      //   qualify → close → soft → info
      // so the coach reads the templates in the order they'd send them.
      const TIER_ORDER = ['qualify', 'close', 'soft', 'info'];
      const TIER_LABEL = { qualify: 'Qualify', close: 'Ask (close)', soft: 'Fallback', info: 'Info' };
      const byTier = {};
      for (const s of snippets) {
        const t = s.tier || 'info';
        (byTier[t] = byTier[t] || []).push(s);
      }
      const snippetHtml = TIER_ORDER.flatMap(tier => {
        const items = byTier[tier];
        if (!items || !items.length) return [];
        const header = `
          <div style="font-size:0.65rem; opacity:0.5; text-transform:uppercase;
                      letter-spacing:1.5px; margin:var(--space-2) 0 4px;">
            ${esc(TIER_LABEL[tier] || tier)}
          </div>`;
        const blocks = items.map(s => {
          const body = this.fillTemplate(s.body, previewLead);
          return blurbBlock(s.label, body, !!s.todo);
        });
        return [header, ...blocks];
      }).join('');

      return `
        <details style="background:var(--bg-secondary); border-radius:var(--radius-md); padding:var(--space-2) var(--space-3); margin-bottom:var(--space-2);">
          <summary style="cursor:pointer; font-weight:700; font-size:0.85rem; user-select:none; outline:none;">
            ${esc(label)} <span style="opacity:0.5; font-weight:400; font-size:0.72rem;">(${snippets.length + 1} blurbs)</span>
          </summary>
          <div style="margin-top:var(--space-2);">
            ${blurbBlock(`First-touch Email · Subject: ${subject}`, email)}
            ${snippetHtml}
          </div>
        </details>
      `;
    };

    root.innerHTML = `
      <details ${collapsed ? '' : 'open'} style="background:var(--bg-secondary); border-radius:var(--radius-md); padding:var(--space-2) var(--space-3);">
        <summary style="cursor:pointer; font-weight:700; font-size:0.9rem; user-select:none; outline:none;">
          📝 Message Templates <span style="opacity:0.5; font-weight:400; font-size:0.75rem;">(${FUNNELS.length} funnels · copy & paste)</span>
        </summary>
        <div style="margin-top:var(--space-2); font-size:0.75rem; opacity:0.7;">
          First-touch email + reply snippets per funnel.  Click 📋 Copy, paste into your Gmail reply, edit the <code>[Name]</code> placeholder.
        </div>
        <div style="margin-top:var(--space-2);">
          ${FUNNELS.map(funnelBlock).join('')}
        </div>
      </details>
    `;

    // Persist collapsed/open state of the outer panel
    const outer = root.querySelector(':scope > details');
    if (outer) outer.addEventListener('toggle', () => {
      try { localStorage.setItem(collapsedKey, outer.open ? '0' : '1'); } catch {}
    });

    // Wire copy buttons (event delegation on the panel root)
    root.addEventListener('click', (e) => {
      const btn = e.target.closest('.copy-btn');
      if (!btn) return;
      e.preventDefault();
      e.stopPropagation();
      const text = btn.getAttribute('data-copy') || '';
      this.copyToClipboard(text, btn);
    });
  }

  copyToClipboard(text, btn) {
    const done = () => {
      if (!btn) return;
      const orig = btn.innerHTML;
      btn.innerHTML = '✓ Copied';
      btn.disabled = true;
      setTimeout(() => { btn.innerHTML = orig; btn.disabled = false; }, 1200);
    };
    const fail = () => {
      if (!btn) return;
      const orig = btn.innerHTML;
      btn.innerHTML = '⚠ Failed';
      setTimeout(() => { btn.innerHTML = orig; }, 1500);
    };
    try {
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(done, fail);
        return;
      }
    } catch {}
    // Legacy fallback for non-secure contexts
    try {
      const ta = document.createElement('textarea');
      ta.value = text;
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      document.body.removeChild(ta);
      done();
    } catch {
      fail();
    }
  }

  renderLead(lead, columnLabel = null, perLeadStats = {}) {
    const date = new Date(lead.created_at).toLocaleDateString('en-US', {
      month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit'
    });

    const fieldMap = this.extractFieldMap(lead.raw_fields);
    const location = this.buildLocationLabel(fieldMap);
    const formattedPhone = this.formatPhoneNumber(lead.phone || '');

    // Parse extra fields from raw_fields for display
    const extras = [];
    const locationKeys = new Set([
      'city', 'current_city', 'state', 'region', 'zip', 'zipcode', 'postal_code',
      'country', 'country_code', 'address', 'street_address'
    ]);
    if (Array.isArray(lead.raw_fields)) {
      for (const f of lead.raw_fields) {
        const key = f.name;
        const keyLower = String(key || '').trim().toLowerCase();
        if (['full_name','name','email','email_address','phone_number','phone'].includes(keyLower)) continue;
        if (locationKeys.has(keyLower)) continue;
        const val = f.values?.[0];
        if (val) extras.push(`<span style="opacity:0.7;">${key}:</span> ${val}`);
      }
    }

    // Contact buttons + status
    const label = columnLabel || this.formLabel(lead.form_id) || '';
    const isYouth = /youth/i.test(label);
    const contact = perLeadStats[lead.id] || {};
    const hasEmail = !!lead.email;
    const mailHref = hasEmail ? this.buildMailHref(lead, label)  : null;

    const ago = (iso) => {
      if (!iso) return '';
      const d = new Date(iso);
      const m = Math.floor((Date.now() - d.getTime()) / 60000);
      if (m < 1)   return 'just now';
      if (m < 60)  return `${m}m ago`;
      const h = Math.floor(m / 60);
      if (h < 24)  return `${h}h ago`;
      return d.toLocaleDateString('en-US', { month:'short', day:'numeric' });
    };

    // Leads workflow is EMAIL-ONLY on the cards as of 2026-06-13 —
    // soccer-club leads (esp. parents) convert better via email and
    // single-channel focus eliminates the SMS-vs-email decision the
    // coach used to have to make per lead.  The SMS / WhatsApp helpers
    // (buildSmsHref, buildWhatsAppHref, messageTemplate.sms,
    // messageSnippets) are intentionally kept for OTHER use cases:
    //   • player attendance / RSVP nudges from elsewhere in the app
    //   • chat-bot or scheduled-reminder workflows
    //   • future re-introduction of multi-channel here if the data
    //     ever justifies it
    // The backend /api/leads/:id/contact endpoint also still accepts
    // 'text' / 'whatsapp' channels for the same reason.
    //
    // Tracked-touch badge for prior emails (no longer showing the
    // text badge since we don't text from here anymore — if you ever
    // want it back, the contact-stats endpoint still returns text_count
    // and last_text_at).
    const emailBadge = contact.email_count
      ? `<span style="display:inline-block; font-size:0.7rem; padding:1px 6px; border-radius:8px; background:#1e2e4a; color:#60a5fa;">✉ Emailed ${ago(contact.last_email_at)}${contact.email_count > 1 ? ` ×${contact.email_count}` : ''}</span>`
      : '';

    const btnStyle = 'flex:1; padding:6px 8px; font-size:0.75rem; font-weight:600; border-radius:6px; border:none; cursor:pointer; text-align:center; text-decoration:none; display:inline-flex; align-items:center; justify-content:center; gap:4px;';

    const emailBtn = hasEmail ? `
      <a href="${mailHref}" class="contact-btn"
         target="_blank" rel="noopener noreferrer"
         data-lead-id="${lead.id}" data-channel="email"
         style="${btnStyle} background:#3b82f6; color:#fff;">✉ Email</a>` : '';
    const saveKind = isYouth ? 'youth-pair' : 'self';
    const saveLabel = isYouth ? '📇 Save (2)' : '📇 Save';
    const saveBtn = `
      <a href="javascript:void(0)" class="contact-btn"
         data-lead-id="${lead.id}" data-channel="vcard" data-kind="${saveKind}"
         style="${btnStyle} background:var(--bg-tertiary, #374151); color:#fff;">${saveLabel}</a>`;

    // Snippet chips were previously rendered here for SMS quick-replies
    // (Register/Pickup/Schedule/etc).  Removed from the card UI on
    // 2026-06-13 to keep leads workflow email-only.  messageSnippets()
    // itself is still defined below — left in place for potential reuse
    // (templates panel, future re-enable, or as a source for email
    // quick-reply templates).


    return `
      <div style="background:var(--bg-secondary); border-radius:var(--radius-lg); padding:var(--space-3);">
        <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:var(--space-1);">
          <strong style="font-size:0.9rem;">${lead.name || '(no name)'}</strong>
          <span style="font-size:0.75rem; opacity:0.5; white-space:nowrap; margin-left:var(--space-2);">${date}</span>
        </div>
        ${lead.email ? `<div style="font-size:0.85rem;">${lead.email}</div>` : ''}
        ${lead.phone ? `<div style="font-size:1rem; font-weight:600; opacity:0.95; letter-spacing:0.01em;">${formattedPhone}</div>` : ''}
        ${location ? `<div style="font-size:0.85rem; opacity:0.85;">📍 ${location}</div>` : ''}
        ${extras.length ? `<div style="font-size:0.8rem; margin-top:var(--space-1); opacity:0.8;">${extras.join(' · ')}</div>` : ''}
        ${emailBadge ? `<div style="display:flex; gap:6px; flex-wrap:wrap; margin-top:6px;">${emailBadge}</div>` : ''}
        <div style="display:flex; gap:6px; margin-top:8px;">${emailBtn}${saveBtn}</div>
      </div>
    `;
  }

  // ── Message templates ────────────────────────────────────────────────
  // Tokens: {first} {full} {phone} {coach}
  //
  // Funnel goal (revised 2026-06-09):
  //   Two-step conversational funnel — first text is a warm intro + ONE
  //   qualifying question, no link.  Once the lead replies, the coach
  //   sends a snippet from messageSnippets() (Register / Schedule /
  //   Requirements / etc.) tailored to what they asked.
  //
  //   Why: cold "tap-to-pay" first messages convert at 1-5%.  Conversation-
  //   first converts at 10-20% based on most documented youth-sports SMS data.
  //
  // Pricing (used in the Register snippet, not the first text):
  //   • $1 to register (card capture)
  //   • Youth   → $35/mo
  //   • Adults  → $9/wk or $35/mo
  //
  // Per-program LeagueApps registration URLs and qualifying questions live in
  // funnelContext() below — single source of truth used by both the initial
  // template and the snippets.

  funnelContext(funnelLabel) {
    // LeagueApps registration URLs ($1 to register; card on file → recurring).
    const URL_MEN   = 'https://lighthouse1893.leagueapps.com/leagues/soccer-(outdoor)/5039300-lighthouse-1893-mens-club-soccer-membership';
    const URL_WOMEN = 'https://lighthouse1893.leagueapps.com/leagues/soccer-(outdoor)/5039340-lighthouse-1893-womens-club-soccer-membership';
    const URL_BOYS  = 'https://lighthouse1893.leagueapps.com/leagues/soccer/5039252-lighthouse-1893-boys-club-soccer-membership';
    const URL_GIRLS = 'https://lighthouse1893.leagueapps.com/leagues/soccer/5039357-lighthouse-1893-girls-club-soccer-membership';
    // Philadelphia Pickup ⚽️ GroupMe chat (id 65284700). Open chat; soft
    // fallback for hesitant leads.  Share link below; the snippet body will
    // ALSO prepend the next scheduled pickup (if any) pulled live from the
    // chat's calendar via /api/leads/next-pickup.
    const PICKUP_LINK = 'https://groupme.com/join_group/65284700/VRuVK50q';

    const LINKS = {
      'Brazil Men':                URL_MEN,
      'PR Men':                    URL_MEN,
      'U23 Men':                   URL_MEN,
      'APSL / Liga 1':             URL_MEN,
      'U23 Women':                 URL_WOMEN,
      'Tri County Women':          URL_WOMEN,
      'Boys Club (Grades 1–6)':    URL_BOYS,
      'Girls Club (Grades 1–6)':   URL_GIRLS,
      'Youth (Grades 1–6)':        URL_BOYS,   // legacy combined form
    };
    const PROGRAM_NAMES = {
      'Youth (Grades 1–6)':        'youth soccer program (grades 1–6)',
      'Boys Club (Grades 1–6)':    'Boys Club soccer program (grades 1–6)',
      'Girls Club (Grades 1–6)':   'Girls Club soccer program (grades 1–6)',
      'Brazil Men':                "Brazilian Men's team",
      'PR Men':                    "Puerto Rican Men's team",
      'U23 Men':                   "U23 Men's team",
      'U23 Women':                 "U23 Women's team",
      'Tri County Women':          "Tri County Women's team",
      'APSL / Liga 1':             'APSL / Liga 1 team',
    };
    // Qualifying question asked in the FIRST message.  Goal: one short answer
    // that lets the coach pick the right follow-up snippet.
    // Per-funnel qualifying question used in the YOUTH initial template.
    // Adult templates don't reference c.question (they ask a single fixed
    // "want to play for our X this season?" — see messageTemplate).
    const QUESTIONS = {
      'Boys Club (Grades 1–6)':    "what's your son's name?",
      'Girls Club (Grades 1–6)':   "what's your daughter's name?",
      'Youth (Grades 1–6)':        'is it for a boy or girl?',
    };

    // Per-funnel public schedule URLs.  Used by the Schedule snippet to give
    // leads a concrete answer ("Sundays, full schedule here") instead of a
    // vague "we'll let you know."  Funnels without an entry fall back to the
    // TODO placeholder so the coach knows to fill it in.
    //   day      — short day-of-week phrase ("Sundays", "Sat/Sun")
    //   url      — public schedule page (optional; omit if no public URL)
    //   sourceOf — label used inline so the lead knows what they're clicking
    //              ("CASA league page", "season Google Sheet", etc.)
    //   practice — short practice cadence note ("practice 2×/week"), optional
    const SCHEDULES = {
      'Brazil Men': {
        day:      'Sundays',
        url:      'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9345724',
        sourceOf: 'CASA Philly Grassroots Cup',
        practice: 'Wed & Fri',
      },
      'PR Men': {
        day:      'Sundays',
        url:      'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9345724',
        sourceOf: 'CASA Philly Grassroots Cup',
        practice: 'Wed & Fri',
      },
      'U23 Men': {
        day:      'Sundays',
        url:      'https://docs.google.com/spreadsheets/d/e/2PACX-1vRFh_2Do_e8aOsItIW3yohRF70hoxsNJDSnuin99F_9TPBYBsqddMNhNg8GESaSng/pubhtml',
        sourceOf: 'season Google Sheet',
        practice: 'Wed & Fri',
      },
      'APSL / Liga 1': {
        day:      'Sundays',
        url:      'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9345724',
        sourceOf: 'CASA Philly Grassroots Cup',
        practice: 'Wed & Fri',
      },
      // Youth / Boys / Girls — no public schedule page yet; verbal summary
      // only.  Games Saturdays (occasionally Sunday) + practice 2×/week
      // (days TBD — likely Mon/Wed but not committed).
      'Boys Club (Grades 1–6)': {
        day:      'Saturdays (sometimes Sundays)',
        practice: '2×/week',
      },
      'Girls Club (Grades 1–6)': {
        day:      'Saturdays (sometimes Sundays)',
        practice: '2×/week',
      },
      'Youth (Grades 1–6)': {
        day:      'Saturdays (sometimes Sundays)',
        practice: '2×/week',
      },
      'Tri County Women': {
        day:      'Sundays',
      },
      // U23 Women — funnel not live yet (no ads running). When launched
      // it'll mirror U23 Men (Sundays + CASA-equivalent women's league).
      // Until then, Schedule chip stays as TODO so the ⚠ reminds the coach to
      // wire it before the first real lead lands.
    };

    const isYouth = /youth|grades?\s*1[–-]6/i.test(funnelLabel || '');
    // Legacy combined youth funnel — the only funnel where the form
    // doesn't pre-identify gender, so the close branches on the lead's
    // boy/girl answer (see Register chip split in messageSnippets).
    const isLegacyYouth = funnelLabel === 'Youth (Grades 1–6)';
    return {
      program:    PROGRAM_NAMES[funnelLabel] || 'program',
      link:       LINKS[funnelLabel] || 'https://lighthouse1893.leagueapps.com',
      linkBoys:   URL_BOYS,
      linkGirls:  URL_GIRLS,
      pickupLink: PICKUP_LINK,
      question:   QUESTIONS[funnelLabel] || 'tell me a bit about your soccer background?',
      schedule:   SCHEDULES[funnelLabel] || null,
      whose:      isYouth ? "your player's" : 'your',
      whoseCap:   isYouth ? "Your player's" : 'Your',
      pricing:    isYouth ? '$35/mo' : '$9/wk or $35/mo',
      isYouth,
      isLegacyYouth,
    };
  }

  messageTemplate(funnelLabel) {
    const c = this.funnelContext(funnelLabel);

    // DESIGN — single-CTA, lean copy:
    //   • Schedule / practice cadence omitted from all 9 first-touch emails.
    //     Generates "doesn't fit my schedule" objections before the lead
    //     even sees the $1 hook.  Schedule lives in the snippet chip for
    //     follow-up after they reply or register.
    //   • Pickup invite omitted — that's the soft-fallback chip for
    //     hesitant adult leads, not part of the cold open.
    //   • Only special line: Tri County Women gets "Games on Sundays."
    //     For women's-league leads, day-of-week is a positive filter
    //     ("yep, Sundays work") not a friction generator.

    // Auto-renewal disclosure — appears as a parenthetical under every
    // first-touch email's CTA link.  Honest upfront disclosure beats
    // post-checkout surprise: lower chargeback rate, fewer "I felt
    // tricked" reviews, builds the word-of-mouth trust that compounds
    // in a small-club market.  LeagueApps re-discloses on the checkout
    // page (Program Description + Cancellation Policy checkbox); this
    // is the belt to LeagueApps' suspenders.
    //   Women's Club (Tri County + U23 Women) → $5/month
    //   All others (Men's + Youth)             → $35/month
    const isWomensClub = /women/i.test(funnelLabel);
    const monthly = isWomensClub ? '$5' : '$35';
    const disclosure = `(Membership renews at ${monthly}/month — cancel anytime, no questions asked.)`;

    // ── Legacy Youth (combined Boys+Girls form, gender unknown) ────────
    // Email closes with BOTH links — parent picks the right one.  Avoids
    // a round-trip ("which one?") and gets the lead to register in one
    // touch.  SMS stays in the "ask boy or girl first" pattern since
    // surfacing both URLs in 160 chars reads spammy.
    if (c.isLegacyYouth) {
      return {
        sms:
          `Hi {first}, this is {coach} w/ Lighthouse 1893 — thanks for your interest in our ${c.program}! ` +
          `Quick Q: ${c.question}`,
        subject: `Lighthouse 1893 — sign up your player for our youth soccer program`,
        email:
          `Hi {first},\n\n` +
          `{coach} here with Lighthouse 1893 SC — thanks for your interest in our ${c.program}!\n\n` +
          `Ready to sign your player up? It's $1 to join — pick the program that matches:\n` +
          `• Boys (Grades 1–6): ${c.linkBoys}\n` +
          `• Girls (Grades 1–6): ${c.linkGirls}\n` +
          `${disclosure}\n\n` +
          `Or just hit reply with any questions — happy to help.\n\n` +
          `Thanks!\n{coach}\nLighthouse 1893 SC\nsoccer@lighthouse1893.org`,
      };
    }

    // ── Gender-specific Youth (Boys Club / Girls Club) ─────────────────
    // Gender is known from which form they filled → we can say
    // "son" or "daughter" directly and link straight to the right program.
    if (c.isYouth) {
      const child = /girls/i.test(funnelLabel) ? 'daughter' : 'son';
      return {
        sms:
          `Hi {first}, this is {coach} w/ Lighthouse 1893 — thanks for your interest in our ${c.program}! ` +
          `Quick Q: ${c.question}`,
        subject: `Lighthouse 1893 — sign your ${child} up for our ${c.program}`,
        email:
          `Hi {first},\n\n` +
          `{coach} here with Lighthouse 1893 SC — thanks for your interest in our ${c.program}!\n\n` +
          `Ready to sign your ${child} up? It's $1 to join — takes about 60 seconds:\n` +
          `${c.link}\n` +
          `${disclosure}\n\n` +
          `Or just hit reply with any questions — happy to help.\n\n` +
          `Thanks!\n{coach}\nLighthouse 1893 SC\nsoccer@lighthouse1893.org`,
      };
    }

    // ── Adult funnels (Brazil / PR / U23 M / U23 W / Tri County W / APSL)
    // SMS stays SMS-native (tight single-sentence ask).  Email is the
    // closing channel: warm intro, the $1 ask, register link, soft reply
    // out.  Reads like a club welcome, not a sales pitch.
    const isTriCountyWomen = funnelLabel === 'Tri County Women';
    const gameLine = isTriCountyWomen ? `Games on Sundays.\n\n` : '';
    return {
      sms:
        `Hi {first}, {coach} w/ Lighthouse 1893 — want to play for our ${c.program} this season?`,
      subject: `Lighthouse 1893 — join our ${c.program} this season`,
      email:
        `Hi {first},\n\n` +
        `{coach} here with Lighthouse 1893 SC — thanks for your interest in our ${c.program}!\n\n` +
        gameLine +
        `Ready to play? It's $1 to join — takes about 60 seconds:\n` +
        `${c.link}\n` +
        `${disclosure}\n\n` +
        `Or just hit reply with any questions — happy to chat.\n\n` +
        `See you on the field,\n{coach}\nLighthouse 1893 SC\nsoccer@lighthouse1893.org`,
    };
  }

  // Per-funnel reply snippets shown as quick-tap chips on each lead card.
  // Each chip opens the user's SMS app with the body pre-filled.
  //
  //   { id, label, body, tier, todo? }
  //     id    — stable identifier (used in logging)
  //     label — chip text shown in UI
  //     body  — message text; supports {first} {coach} tokens
  //     tier  — one of:
  //               'qualify' — mid-conversation digging Qs (no link)
  //               'close'   — the ASK ($1 register) — always lead with this
  //               'soft'    — fallback for hesitant leads (pickup)
  //               'info'    — neutral info replies (schedule, requirements)
  //             Chips are grouped by tier in the UI so the close always
  //             leads and 'soft' reads as a clearly-secondary fallback.
  //     todo  — if true, chip is dimmed + ⚠ marked so you remember to fill in
  //
  // Add more snippets here as you collect common Q&As.  No code changes
  // required beyond appending to the array.
  messageSnippets(funnelLabel) {
    const c = this.funnelContext(funnelLabel);

    // closeLink — trailing CTA appended to info chips (Cost / Schedule /
    // Field).  For known-gender funnels this is one link; for the legacy
    // combined Youth funnel we list BOTH Boys and Girls URLs since the
    // coach can't safely pick one until the lead answers the boy/girl
    // question (asked in the initial template).
    const closeLink = (prefix) => {
      if (c.isLegacyYouth) {
        return `${prefix}\n• Boys: ${c.linkBoys}\n• Girls: ${c.linkGirls}`;
      }
      return `${prefix} ${c.link}`;
    };

    // Register — primary close.  For the legacy Youth funnel (where
    // gender wasn't pre-selected by the form), split into TWO dedicated
    // chips so the coach taps the right one after the lead answers the
    // grade + boy/girl question.  All other funnels get one Register chip.
    const snippets = [];
    if (c.isLegacyYouth) {
      snippets.push({
        id: 'register-boys',
        label: '💳 Register Boys ($1)',
        tier: 'close',
        body: `Great. To register your son as a member of the soccer club, register here: ${c.linkBoys}`,
      });
      snippets.push({
        id: 'register-girls',
        label: '💳 Register Girls ($1)',
        tier: 'close',
        body: `Great. To register your daughter as a member of the soccer club, register here: ${c.linkGirls}`,
      });
    } else if (c.isYouth) {
      // Gender-specific youth funnel (Boys Club / Girls Club) — gender
      // known from the form, so we can say son/daughter directly.
      const child = /girls/i.test(funnelLabel) ? 'daughter' : 'son';
      snippets.push({
        id: 'register',
        label: '💳 Register ($1)',
        tier: 'close',
        body: `Great. To register your ${child} as a member of the soccer club, register here: ${c.link}`,
      });
    } else {
      snippets.push({
        id: 'register',
        label: '💳 Register ($1)',
        tier: 'close',
        body:
          `Great. To become a member of the club it's $1 registration on this link: ${c.link}\n` +
          `Once you're in you can start coming to trainings and games.`,
      });
    }

    // Adult funnels: soft fallback chip for hesitant leads (pickup invite).
    // No qualifying chips — one icebreaker Q in the initial template is enough;
    // anything more creates friction before the close.
    if (!c.isYouth) {
      // Soft fallback for hesitant leads: practice is gated behind the $1
      // register, but pickup is open — they can come play, meet the squad,
      // see if it's a fit, then decide. Doesn't compete with the close.
      // Dynamic body: lead with the NEXT scheduled pickup (date/time/field)
      // if the calendar has one, otherwise fall back to a generic invite to
      // the chat. this._nextPickup is loaded by loadLeads().
      const next = this._nextPickup;
      let pickupBody;
      if (next && next.start_at) {
        const when  = this.formatPickupDate(next.start_at);
        const loc   = (next.location || next.location_address || '').trim();
        const title = (next.title || '').trim();
        const where = loc ? ` @ ${loc}` : '';
        // Derive the per-event GroupMe share URL from the chat join link:
        //   chat:  https://groupme.com/join_group/{conv}/{token}
        //   event: https://groupme.com/join_event/{conv}/{event_id}/{token}
        // Share token is per-chat (same one), so no extra data needed.
        const eventUrl = (next.external_id && /\/join_group\//.test(c.pickupLink))
          ? c.pickupLink.replace('/join_group/', '/join_event/')
                        .replace(/\/([^\/]+)$/, `/${next.external_id}/$1`)
          : c.pickupLink;
        const titleClause = title ? `"${title}" — ` : '';
        pickupBody =
          `Our next pickup: ${titleClause}${when}${where}.\n` +
          `RSVP "Going" here so we know to expect you: ${eventUrl}\n` +
          `Come play, meet the squad, see if it's your scene. If it is, $1 to lock in your team spot.`;
      } else {
        pickupBody =
          `No pressure to commit yet — jump in our Philadelphia Pickup chat for the next session and RSVP "Going" on whichever pickup works for you: ${c.pickupLink}\n` +
          `Come play, meet the squad, see if it's your scene. If it is, $1 to lock in your team spot.`;
      }
      snippets.push({
        id: 'pickup',
        label: '⚽ Pickup',
        tier: 'soft',
        body: pickupBody,
      });
    }

    snippets.push(
      // Field — answers "where do you play?" with both Lighthouse venues +
      // the $1 close. Same two addresses for every Lighthouse team, so this
      // chip lives in the shared snippet code (no per-funnel branch).
      // No flex copy — the "Lighthouse" in both venue names is the flex.
      {
        id: 'field',
        label: '📍 Field',
        tier: 'info',
        body:
          `📍 Lighthouse Sports Complex — 199 E Erie Ave (outdoor)\n` +
          `   https://maps.google.com/?q=199+E+Erie+Ave+Philadelphia+PA+19134\n` +
          `📍 Lighthouse Community Center — 141 W Somerset St (indoor)\n` +
          `   https://maps.google.com/?q=141+W+Somerset+St+Philadelphia+PA+19134\n` +
          `\n` +
          closeLink(`$1 locks ${c.whose} spot:`),
      },
      // Schedule — concrete answer when funnelContext has schedule info.
      // Doubles as a soft-close: answers the logistics question AND
      // immediately gives the register CTA, since leads asking
      // "what's the schedule?" are in a "does this fit my life?" frame
      // and want the next action right there.
      //
      // Three shapes supported:
      //   1. day + url    → "Games <day> — full schedule (<src>): <url>"
      //   2. day only     → "Games <day>, <practice>"  (verbal summary)
      //   3. nothing      → TODO placeholder (dimmed)
      c.schedule
        ? (() => {
            const lines = [];
            // Practice always leads when defined — implies the
            // attendance expectation without ever stating a criterion.
            // Pickup sessions (Tue/Thu/Sat) are intentionally NOT mentioned
            // pre-signup; the coach explains those after the lead registers.
            if (c.schedule.practice) {
              lines.push(`Practice: ${c.schedule.practice}`);
            }
            if (c.schedule.url) {
              lines.push(`Games ${c.schedule.day} — full schedule (${c.schedule.sourceOf}):`);
              lines.push(c.schedule.url);
            } else {
              lines.push(`Games ${c.schedule.day}.`);
              lines.push(`Specific times/fields confirm after rosters close.`);
            }
            lines.push('');
            lines.push(closeLink(`If it works, $1 locks ${c.whose} spot:`));
            return {
              id: 'schedule',
              label: '📅 Schedule',
              tier: 'info',
              body: lines.join('\n'),
            };
          })()
        : {
            id: 'schedule',
            label: '📅 Schedule',
            tier: 'info',
            todo: true,
            body:
              `Practice schedule for our ${c.program}:\n` +
              `(TODO — fill this in once confirmed for the season.)`,
          },
      {
        id: 'cost',
        label: '💵 Cost',
        tier: 'info',
        body:
          `$1 today to lock ${c.whose} spot. After that it's ${c.pricing} — cancel anytime.\n` +
          `\n` +
          closeLink('Register here:'),
      },
      // Add more snippets here as common questions come up:
      //
      //   { id: 'location',  label: '📍 Field',       body: '...' },
      //   { id: 'gear',      label: '👕 What to wear', body: '...' },
      //
      // Use {first} or {coach} tokens in body if you want personalization.
    );
    return snippets;
  }

  // Friendly format for an ISO timestamp from chat_events.start_at.
  //   2026-06-11T23:00:00Z → "Wed Jun 11, 7pm" (in user's local tz)
  formatPickupDate(iso) {
    try {
      const d = new Date(iso);
      if (isNaN(d.getTime())) return '';
      const dow = d.toLocaleDateString('en-US', { weekday: 'short' });
      const md  = d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
      let tm = d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
      tm = tm.toLowerCase().replace(/\s+/g, '').replace(/:00(am|pm)/, '$1'); // 7:00pm → 7pm
      return `${dow} ${md}, ${tm}`;
    } catch { return ''; }
  }

  fillTemplate(tmpl, lead) {
    const full  = (lead.name || '').trim();
    const first = full.split(/\s+/)[0] || 'there';
    // Auto-detect logged-in user's first name for signoff. Falls back to plain "Coach".
    const me    = (this.auth && this.auth.getUser && this.auth.getUser()) || {};
    const coach = me.first_name ? `Coach ${me.first_name}` : 'Coach';
    return tmpl.replace(/\{first\}/g, first)
               .replace(/\{full\}/g,  full)
               .replace(/\{phone\}/g, lead.phone || '')
               .replace(/\{coach\}/g, coach);
  }

  buildSmsHref(lead, label) {
    const t = this.messageTemplate(label);
    const body = this.fillTemplate(t.sms, lead);
    // sms: URI with both ?body= and &body= — iOS uses &, Android uses ?
    const phone = (lead.phone || '').replace(/[^\d+]/g, '');
    return `sms:${phone}?&body=${encodeURIComponent(body)}`;
  }

  // wa.me URL — opens WhatsApp web/app with the chat pre-filled.
  // Phone must be international, digits only (no +, no dashes).  If the
  // captured number has no country code (US 10-digit), default to +1
  // since that's our biggest segment; lead-captured Brazil/PR numbers
  // typically already carry the country code from Meta.
  buildWhatsAppHref(lead, label) {
    const t    = this.messageTemplate(label);
    const body = this.fillTemplate(t.sms, lead);  // SMS template reads fine in WA too
    let digits = (lead.phone || '').replace(/\D/g, '');
    if (digits.length === 10) digits = '1' + digits;  // assume US if bare
    return `https://wa.me/${digits}?text=${encodeURIComponent(body)}`;
  }

  buildMailHref(lead, label) {
    const t = this.messageTemplate(label);
    const subject = this.fillTemplate(t.subject, lead);
    const body    = this.fillTemplate(t.email,   lead);
    // Open Gmail's web compose directly in the soccer@lighthouse1893.org
    // account (not the user's personal Gmail / default mail client).  The
    // `authuser` query param tells Gmail which signed-in Google account to
    // use, so as long as soccer@lighthouse1893.org is one of the accounts
    // signed into this browser, compose opens in that mailbox with To /
    // Subject / Body all pre-filled.  Coach just hits Send.
    //   Wins: no mailto handler weirdness, no Outlook/Mail.app surprises,
    //   no OAuth/SMTP infra, real From: address is the club mailbox so
    //   replies route to soccer@lighthouse1893.org naturally.
    const FROM_ACCOUNT = 'soccer@lighthouse1893.org';
    const params = new URLSearchParams({
      view:     'cm',
      fs:       '1',
      authuser: FROM_ACCOUNT,
      to:       lead.email,
      su:       subject,
      body:     body,
    });
    return `https://mail.google.com/mail/?${params.toString()}`;
  }

  async onContactClick(e) {
    const btn      = e.currentTarget;
    const leadId   = btn.getAttribute('data-lead-id');
    const channel  = btn.getAttribute('data-channel');

    if (channel === 'vcard') {
      e.preventDefault();
      const kind = btn.getAttribute('data-kind') || 'self';
      try {
        const res = await this.auth.fetch(`/api/leads/${leadId}/vcard?kind=${kind}`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const blob = await res.blob();
        // Extract filename from Content-Disposition or fall back
        const cd = res.headers.get('Content-Disposition') || '';
        const m  = /filename="([^"]+)"/.exec(cd);
        const filename = m ? m[1] : `lead-${leadId}.vcf`;
        const url = URL.createObjectURL(blob);
        const a   = document.createElement('a');
        a.href = url; a.download = filename;
        document.body.appendChild(a); a.click(); document.body.removeChild(a);
        setTimeout(() => URL.revokeObjectURL(url), 1000);
      } catch (err) {
        alert(`Failed to download contact: ${err.message}`);
      }
      return;
    }

    // text/email: let the sms: / mailto: navigation proceed,
    // and log the touch in parallel. Don't preventDefault.
    try {
      const lead       = (this._leads || []).find(l => String(l.id) === String(leadId));
      const label      = lead ? this.formLabel(lead.form_id) : '';
      const snippetId  = btn.getAttribute('data-snippet');
      let   body;
      if (snippetId) {
        // Snippet chip click — look up the snippet's body, fall back to '' if missing.
        const snippets = this.messageSnippets(label);
        const snip     = snippets.find(s => s.id === snippetId);
        body = snip ? this.fillTemplate(snip.body, lead || {}) : '';
      } else {
        const tmpl = this.messageTemplate(label);
        body = channel === 'text'
          ? this.fillTemplate(tmpl.sms,   lead || {})
          : this.fillTemplate(tmpl.email, lead || {});
      }
      await this.auth.fetch(`/api/leads/${leadId}/contact`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ channel, message_body: body }),
      });
      // Refresh stats so the badge + risk meter update
      this.refreshStats();
    } catch {}
  }

  formatPhoneNumber(rawPhone) {
    const value = String(rawPhone || '').trim();
    if (!value) return '';

    const digits = value.replace(/\D/g, '');

    // US/Canada number with country code.
    if (digits.length === 11 && digits.startsWith('1')) {
      const local = digits.slice(1);
      return `+1 (${local.slice(0, 3)}) ${local.slice(3, 6)}-${local.slice(6)}`;
    }

    // US/Canada local format.
    if (digits.length === 10) {
      return `(${digits.slice(0, 3)}) ${digits.slice(3, 6)}-${digits.slice(6)}`;
    }

    // For international/non-standard formats, keep user-provided value.
    return value;
  }

  extractFieldMap(rawFields) {
    const map = {};
    if (!Array.isArray(rawFields)) return map;

    for (const field of rawFields) {
      const name = String(field?.name || '').trim().toLowerCase();
      if (!name) continue;
      const value = field?.values?.[0];
      if (value !== undefined && value !== null && value !== '') {
        map[name] = String(value).trim();
      }
    }

    return map;
  }

  buildLocationLabel(fieldMap) {
    const city = fieldMap.current_city || fieldMap.city || null;
    const state = fieldMap.state || fieldMap.region || null;
    const postal = fieldMap.zip || fieldMap.zipcode || fieldMap.postal_code || null;
    const country = fieldMap.country || fieldMap.country_code || null;
    const address = fieldMap.address || fieldMap.street_address || null;

    const localityParts = [city, state].filter(Boolean);
    let locality = localityParts.join(', ');
    if (postal) locality = locality ? `${locality} ${postal}` : postal;
    if (country) locality = locality ? `${locality}, ${country}` : country;

    if (address && locality) return `${address} • ${locality}`;
    return address || locality || '';
  }
}
