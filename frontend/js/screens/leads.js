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

      if (!leads.length) {
        this.find('#leads-empty').style.display = 'block';
        return;
      }

      this.find('#leads-list').style.display = 'block';
      this._leads = leads;
      this._spend = spend;
      this._stats = stats;
      this.renderLeads(leads, spend, stats);
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
      this.renderLeads(this._leads, this._spend, this._stats);
    } catch {}
  }

  renderLeads(leads, spend = [], stats = { per_lead: {}, aggregates: {} }) {
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

    const COLUMNS = ['Brazil Men', 'U23 Men', 'PR Men', 'U23 Women', 'Tri County Women', 'APSL / Liga 1', 'Youth (Grades 1–6)', 'Boys Club (Grades 1–6)', 'Girls Club (Grades 1–6)'];
    const COLORS  = {
      'Brazil Men':              '#15803d',
      'U23 Men':                 '#1d4ed8',
      'PR Men':                  '#7c3aed',
      'U23 Women':               '#be185d',
      'Tri County Women':        '#9d174d',
      'APSL / Liga 1':           '#f59e0b',
      'Youth (Grades 1–6)':      '#c9a14a',
      'Boys Club (Grades 1–6)':  '#0e7490',
      'Girls Club (Grades 1–6)': '#db2777',
    };

    // Load hidden-column preferences (persisted in localStorage)
    const HIDDEN_KEY = 'leads.hiddenColumns';
    let hidden;
    try {
      hidden = new Set(JSON.parse(localStorage.getItem(HIDDEN_KEY) || '[]'));
    } catch { hidden = new Set(); }
    // Sanitize against stale entries
    for (const c of [...hidden]) if (!COLUMNS.includes(c)) hidden.delete(c);
    const visible = COLUMNS.filter(c => !hidden.has(c));

    // Aggregate spend by column (sum across all forms mapping to same column)
    const spendByCol = {};
    for (const col of COLUMNS) spendByCol[col] = { daily: 0, total: 0, days: 0, active: false };
    for (const s of spend) {
      const col = this.formLabel(s.form_id);
      if (!col || !spendByCol[col]) continue;
      spendByCol[col].daily += Number(s.daily_budget_usd || 0);
      spendByCol[col].total += Number(s.total_spend_usd || 0);
      if (s.days_running > spendByCol[col].days) spendByCol[col].days = s.days_running;
      if (s.ad_active) spendByCol[col].active = true;
    }
    const fmt = (n) => `$${n.toFixed(2)}`;

    // Group + sort each column by date descending
    const grouped = {};
    for (const col of COLUMNS) grouped[col] = [];
    for (const l of leads) {
      const label = this.formLabel(l.form_id) || 'Other';
      if (grouped[label]) grouped[label].push(l);
    }
    for (const col of COLUMNS) {
      grouped[col].sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
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
        ${COLUMNS.map(col => `
          <label style="display:inline-flex; align-items:center; gap:6px; font-size:0.8rem; cursor:pointer; user-select:none; padding:2px 6px; border-radius:4px; border-left:3px solid ${COLORS[col]};">
            <input type="checkbox" class="col-toggle" data-col="${col}" ${hidden.has(col) ? '' : 'checked'} style="cursor:pointer;">
            ${col} <span style="opacity:0.55;">(${grouped[col].length})</span>
          </label>
        `).join('')}
      </div>
      <p style="opacity:0.6; font-size:0.85rem; margin-bottom:var(--space-3);">${visibleLeadCount} of ${leads.length} lead${leads.length !== 1 ? 's' : ''} shown</p>
      ${visible.length === 0 ? `
        <div style="text-align:center; padding:var(--space-6); opacity:0.5;">All columns hidden — check a box above to show leads.</div>
      ` : `
      <div style="display:grid; grid-template-columns:repeat(${visible.length},1fr); gap:var(--space-3); align-items:start;">
        ${visible.map(col => {
          const s = spendByCol[col];
          const cpl = grouped[col].length > 0 && s.total > 0 ? (s.total / grouped[col].length) : null;
          const statusDot = s.active ? '<span style="color:#10b981;">●</span>' : '<span style="opacity:0.4;">○</span>';
          return `
          <div>
            <div style="font-weight:700; font-size:0.85rem; color:#fff; background:${COLORS[col]}; border-radius:var(--radius-sm); padding:var(--space-1) var(--space-2); margin-bottom:var(--space-1); text-align:center;">
              ${col} <span style="opacity:0.8;">(${grouped[col].length})</span>
            </div>
            <div style="font-size:0.7rem; opacity:0.85; text-align:center; margin-bottom:var(--space-2); line-height:1.4;">
              ${statusDot} ${fmt(s.daily)}/day · ${s.days}d running<br>
              Spent ${fmt(s.total)}${cpl !== null ? ` · ${fmt(cpl)}/lead` : ''}
            </div>
            <div style="display:flex; flex-direction:column; gap:var(--space-2);">
              ${grouped[col].map(l => this.renderLead(l, col, stats.per_lead || {})).join('') || '<div style="opacity:0.4; font-size:0.8rem; text-align:center; padding:var(--space-2);">none</div>'}
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
        this.renderLeads(this._leads || leads, this._spend || spend, this._stats || stats);
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
      'Brazil Men', 'U23 Men', 'PR Men', 'U23 Women', 'Tri County Women', 'APSL / Liga 1',
      'Youth (Grades 1–6)', 'Boys Club (Grades 1–6)', 'Girls Club (Grades 1–6)',
    ];
    const funnelRank = (label) => {
      const i = FUNNEL_ORDER.indexOf(label);
      return i === -1 ? 999 : i;
    };
    const decorated = ads.map(a => ({ ...a, funnel: this.formLabel(a.form_id) || '(no form)' }));
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
      const sms      = this.fillTemplate(t.sms,     previewLead);
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
            ${esc(label)} <span style="opacity:0.5; font-weight:400; font-size:0.72rem;">(${snippets.length + 2} blurbs)</span>
          </summary>
          <div style="margin-top:var(--space-2);">
            ${blurbBlock('Intro — SMS', sms)}
            ${blurbBlock(`Intro — Email · Subject: ${subject}`, email)}
            ${snippetHtml}
          </div>
        </details>
      `;
    };

    root.innerHTML = `
      <details ${collapsed ? '' : 'open'} style="background:var(--bg-secondary); border-radius:var(--radius-md); padding:var(--space-2) var(--space-3);">
        <summary style="cursor:pointer; font-weight:700; font-size:0.9rem; user-select:none; outline:none;">
          📝 Message Templates <span style="opacity:0.5; font-weight:400; font-size:0.75rem;">(${FUNNELS.length} funnels · preview / copy)</span>
        </summary>
        <div style="margin-top:var(--space-2); font-size:0.75rem; opacity:0.7;">
          Preview of every initial text/email and reply snippet across all funnels. <code>[Name]</code> is a placeholder — edit after pasting.
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
    const hasPhone = !!lead.phone;
    const hasEmail = !!lead.email;
    const smsHref  = hasPhone ? this.buildSmsHref(lead, label)   : null;
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

    const textBadge  = contact.text_count
      ? `<span style="display:inline-block; font-size:0.7rem; padding:1px 6px; border-radius:8px; background:#0a3d2a; color:#10b981;">✓ Texted ${ago(contact.last_text_at)}${contact.text_count > 1 ? ` ×${contact.text_count}` : ''}</span>`
      : '';
    const emailBadge = contact.email_count
      ? `<span style="display:inline-block; font-size:0.7rem; padding:1px 6px; border-radius:8px; background:#1e2e4a; color:#60a5fa;">✉ Emailed ${ago(contact.last_email_at)}${contact.email_count > 1 ? ` ×${contact.email_count}` : ''}</span>`
      : '';

    const btnStyle = 'flex:1; padding:6px 8px; font-size:0.75rem; font-weight:600; border-radius:6px; border:none; cursor:pointer; text-align:center; text-decoration:none; display:inline-flex; align-items:center; justify-content:center; gap:4px;';
    const textBtn = hasPhone ? `
      <a href="${smsHref}" class="contact-btn"
         data-lead-id="${lead.id}" data-channel="text"
         style="${btnStyle} background:#10b981; color:#fff;">📱 Text</a>` : '';
    const emailBtn = hasEmail ? `
      <a href="${mailHref}" class="contact-btn"
         data-lead-id="${lead.id}" data-channel="email"
         style="${btnStyle} background:#3b82f6; color:#fff;">✉ Email</a>` : '';
    const saveKind = isYouth ? 'youth-pair' : 'self';
    const saveLabel = isYouth ? '📇 Save (2)' : '📇 Save';
    const saveBtn = `
      <a href="javascript:void(0)" class="contact-btn"
         data-lead-id="${lead.id}" data-channel="vcard" data-kind="${saveKind}"
         style="${btnStyle} background:var(--bg-tertiary, #374151); color:#fff;">${saveLabel}</a>`;

    // Snippet chips — quick-reply pills shown under the main buttons.
    // Each chip opens the SMS app with that snippet's body pre-filled.
    // TODO-marked snippets are dimmed + flagged so the coach remembers to fill in.
    //
    // Chips are grouped by tier so the close always leads and the soft
    // fallback (pickup) reads as clearly secondary:
    //   1. Qualify  — mid-conversation digging Qs ("what level?")
    //   2. Close    — the ASK ($1 register) — gold-bordered, the hero chip
    //   3. Soft     — fallback for hesitant leads (pickup), muted
    //   4. Info     — neutral info replies (schedule/requirements)
    const snippets = hasPhone ? this.messageSnippets(label) : [];
    const baseChip =
      'display:inline-flex; align-items:center; gap:4px; ' +
      'padding:3px 8px; font-size:0.7rem; font-weight:600; ' +
      'border-radius:999px; border:1px solid var(--border-color, #374151); ' +
      'background:var(--bg-tertiary, #1f2937); color:#e5e7eb; ' +
      'text-decoration:none; cursor:pointer; line-height:1.4;';
    const tierStyle = {
      qualify: '',
      // Close = gold border + slight glow so the eye lands here first.
      close:   'border-color:#f5d442; color:#f5d442; font-weight:800; box-shadow:0 0 0 1px rgba(245,212,66,0.25);',
      // Soft fallback = muted so it doesn't compete with the close.
      soft:    'opacity:0.7; font-weight:500;',
      info:    'opacity:0.8;',
    };
    const chipFor = (s) => {
      const body = this.fillTemplate(s.body, lead);
      const phoneDigits = (lead.phone || '').replace(/[^\d+]/g, '');
      const href = `sms:${phoneDigits}?&body=${encodeURIComponent(body)}`;
      const dim  = s.todo ? 'opacity:0.55;' : '';
      const mark = s.todo ? ' ⚠' : '';
      const extra = tierStyle[s.tier] || '';
      const titleAttr = body.replace(/"/g, '&quot;').slice(0, 200);
      return `
        <a href="${href}" class="contact-btn snippet-btn"
           data-lead-id="${lead.id}" data-channel="text" data-snippet="${s.id}"
           title="${titleAttr}"
           style="${baseChip} ${extra} ${dim}">${s.label}${mark}</a>`;
    };

    // Group chips by tier, render in order: qualify → close → soft → info.
    // Each group gets a tiny prefix label so the coach reads the hierarchy.
    const groupLabel = (txt) =>
      `<span style="font-size:0.6rem; opacity:0.45; align-self:center; ` +
      `text-transform:uppercase; letter-spacing:1px; margin-right:2px;">${txt}</span>`;
    const tierOrder = [
      ['qualify', 'Qualify'],
      ['close',   'Ask'],
      ['soft',    'Fallback'],
      ['info',    'Info'],
    ];
    const tierBlocks = tierOrder.map(([tier, label]) => {
      const items = snippets.filter(s => (s.tier || 'info') === tier);
      if (!items.length) return '';
      return `
        <div style="display:flex; gap:4px; flex-wrap:wrap; align-items:center;">
          ${groupLabel(label)}
          ${items.map(chipFor).join('')}
        </div>`;
    }).filter(Boolean).join('');
    const snippetRow = snippets.length ? `
      <div style="display:flex; flex-direction:column; gap:4px; margin-top:6px;">
        ${tierBlocks}
      </div>` : '';

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
        ${(textBadge || emailBadge) ? `<div style="display:flex; gap:6px; flex-wrap:wrap; margin-top:6px;">${textBadge}${emailBadge}</div>` : ''}
        <div style="display:flex; gap:6px; margin-top:8px;">${textBtn}${emailBtn}${saveBtn}</div>
        ${snippetRow}
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
      'APSL / Liga 1':             'APSL / Liga 1 trial',
    };
    // Qualifying question asked in the FIRST message.  Goal: one short answer
    // that lets the coach pick the right follow-up snippet.
    const QUESTIONS = {
      'Brazil Men':                'have you played 11v11 before, and what position?',
      'PR Men':                    'have you played 11v11 before, and what position?',
      'U23 Men':                   'what year were you born, and how long have you been playing?',
      'U23 Women':                 'what year were you born, and how long have you been playing?',
      'Tri County Women':          'what year were you born, and how long have you been playing?',
      'APSL / Liga 1':             'what level have you played at — college, semi-pro, top flight overseas?',
      'Boys Club (Grades 1–6)':    'what grade is your player in? (all experience levels welcome!)',
      'Girls Club (Grades 1–6)':   'what grade is your player in? (all experience levels welcome!)',
      'Youth (Grades 1–6)':        'what grade is your player in? (all experience levels welcome!)',
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
      // only.  Games Saturdays (occasionally Sunday) + practice 2×/week.
      // Specific times/fields confirm after rosters close.
      'Boys Club (Grades 1–6)': {
        day:      'Saturdays (sometimes Sundays)',
        practice: 'practice 2×/week',
      },
      'Girls Club (Grades 1–6)': {
        day:      'Saturdays (sometimes Sundays)',
        practice: 'practice 2×/week',
      },
      'Youth (Grades 1–6)': {
        day:      'Saturdays (sometimes Sundays)',
        practice: 'practice 2×/week',
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
    return {
      program:    PROGRAM_NAMES[funnelLabel] || 'program',
      link:       LINKS[funnelLabel] || 'https://lighthouse1893.leagueapps.com',
      pickupLink: PICKUP_LINK,
      question:   QUESTIONS[funnelLabel] || 'tell me a bit about your soccer background?',
      schedule:   SCHEDULES[funnelLabel] || null,
      whose:      isYouth ? "your player's" : 'your',
      whoseCap:   isYouth ? "Your player's" : 'Your',
      pricing:    isYouth ? '$35/mo' : '$9/wk or $35/mo',
      isYouth,
    };
  }

  messageTemplate(funnelLabel) {
    const c = this.funnelContext(funnelLabel);
    return {
      sms:
        `Hi {first}, this is {coach} w/ Lighthouse 1893 — thanks for your interest in our ${c.program}! ` +
        `Quick Q: ${c.question}`,
      subject: `Lighthouse 1893 — thanks for reaching out!`,
      email:
        `Hi {first},\n\n` +
        `{coach} here with Lighthouse 1893 — thanks for your interest in our ${c.program}!\n\n` +
        `Quick question to get started: ${c.question}\n\n` +
        `Looking forward to hearing from you.\n\n` +
        `Thanks!\n{coach}\nLighthouse 1893 SC\nsoccer@lighthouse1893.org`
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
    const snippets = [
      {
        id: 'register',
        label: '💳 Register ($1)',
        tier: 'close',
        body:
          `You're set — ${c.whose} spot is $1 to lock in: ${c.link}\n` +
          `Then ${c.pricing} (cancel anytime). Once you're registered I'll text you the practice details.`,
      },
    ];

    // Adult funnels: after they answer the qualifying Q (position / year-born /
    // level), dig one layer deeper to gauge experience before pitching.
    if (!c.isYouth) {
      snippets.push({
        id: 'followup-level',
        label: '🎯 Follow-up',
        tier: 'qualify',
        body: 'Perfect — what level have you played at most recently?',
      });
      snippets.push({
        id: 'followup-club',
        label: '🏟️ Which club?',
        tier: 'qualify',
        body: "Got it — any clubs/teams I'd know? (HS, college, adult, anywhere overseas)",
      });
      // Soft fallback for hesitant leads: practice is gated behind the $1
      // register, but pickup is open — they can come play, see the level,
      // meet the squad, then decide. Doesn't compete with the close.
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
          `Come play, see the level, meet the squad. If it's a fit, $1 to lock in your team spot.`;
      } else {
        pickupBody =
          `No pressure to commit yet — jump in our Philadelphia Pickup chat for the next session and RSVP "Going" on whichever pickup works for you: ${c.pickupLink}\n` +
          `Come play, see the level, meet the squad. If it's a fit, $1 to lock in your team spot.`;
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
          `$1 locks ${c.whose} spot: ${c.link}`,
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
            lines.push(`If it works, $1 locks ${c.whose} spot: ${c.link}`);
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
          `Register here: ${c.link}`,
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

  buildMailHref(lead, label) {
    const t = this.messageTemplate(label);
    const subject = this.fillTemplate(t.subject, lead);
    const body    = this.fillTemplate(t.email,   lead);
    // Note: mailto can't force the From address. User's default mail client picks it.
    // The signature in the body identifies the club so replies route correctly.
    return `mailto:${encodeURIComponent(lead.email)}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
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
