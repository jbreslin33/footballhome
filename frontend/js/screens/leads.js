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
      const [leadsRes, spendRes, statsRes, targetingRes] = await Promise.all([
        this.auth.fetch('/api/leads'),
        this.auth.fetch('/api/ads/spend').catch(() => null),
        this.auth.fetch('/api/leads/contact-stats').catch(() => null),
        this.auth.fetch('/api/ads/targeting').catch(() => null),
      ]);
      if (!leadsRes.ok) throw new Error(`HTTP ${leadsRes.status}`);
      const leads = await leadsRes.json();
      const spend = spendRes && spendRes.ok ? await spendRes.json() : [];
      const stats = statsRes && statsRes.ok ? await statsRes.json() : { per_lead: {}, aggregates: {} };
      const targeting = targetingRes && targetingRes.ok ? await targetingRes.json() : [];

      this.find('#leads-loading').style.display = 'none';

      // Render targeting rundown at top — always, even if there are no leads yet
      this.renderAdsRundown(targeting);

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

    const COLUMNS = ['Brazil Men', 'U23 Men', 'PR Men', 'U23 Women', 'APSL Trials', 'Youth (Grades 1–6)', 'Boys Club (Grades 1–6)', 'Girls Club (Grades 1–6)'];
    const COLORS  = {
      'Brazil Men':              '#15803d',
      'U23 Men':                 '#1d4ed8',
      'PR Men':                  '#7c3aed',
      'U23 Women':               '#be185d',
      'APSL Trials':             '#f59e0b',
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
      '1773598717166962': 'APSL Trials',
      '3249608418562710': 'Youth (Grades 1–6)',
      '1704106777282059': 'Boys Club (Grades 1–6)',
      '1571742281184926': 'Girls Club (Grades 1–6)',
    };
    return map[formId] || null;
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
      </div>
    `;
  }

  // ── Message templates ────────────────────────────────────────────────
  // Tokens: {first} {full} {phone} {coach}
  //
  // Funnel goal: get a $1 registration (captures card on file, then
  // recurring billing runs automatically). Practice attendance becomes
  // the *reward* for registering — not a separate ask.
  //
  // Pricing:
  //   • $1 to register (card capture)
  //   • Youth   → $35/mo
  //   • Adults  → $9/wk or $35/mo (their pick at registration)
  //
  // Per-program LeagueApps registration URLs. Swap in program-specific
  // links here as they're created. Defaults to the club site root.
  messageTemplate(funnelLabel) {
    // LeagueApps registration URLs ($1 to register; card on file → recurring).
    const URL_MEN   = 'https://lighthouse1893.leagueapps.com/leagues/soccer-(outdoor)/5039300-lighthouse-1893-mens-club-soccer-membership';
    const URL_WOMEN = 'https://lighthouse1893.leagueapps.com/leagues/soccer-(outdoor)/5039340-lighthouse-1893-womens-club-soccer-membership';
    const URL_BOYS  = 'https://lighthouse1893.leagueapps.com/leagues/soccer/5039252-lighthouse-1893-boys-club-soccer-membership';
    const URL_GIRLS = 'https://lighthouse1893.leagueapps.com/leagues/soccer/5039357-lighthouse-1893-girls-club-soccer-membership';

    const LINKS = {
      // Adults → club Men's Membership program ($1 register, then $9/wk or $35/mo)
      'Brazil Men':                URL_MEN,
      'PR Men':                    URL_MEN,
      'U23 Men':                   URL_MEN,
      'APSL Trials':               URL_MEN,
      // Adult women → club Women's Membership program (same pricing)
      'U23 Women':                 URL_WOMEN,
      // Youth — separate Boys / Girls Meta lead forms once they exist.
      // Wire their form IDs into formLabel() to route to these labels.
      'Boys Club (Grades 1–6)':    URL_BOYS,
      'Girls Club (Grades 1–6)':   URL_GIRLS,
      // Legacy combined-Youth form (gender unknown). Default to Boys URL;
      // coach can manually paste the Girls URL for known-girl leads.
      'Youth (Grades 1–6)':        URL_BOYS,
    };
    // Human-readable program name used inline in the message body.
    const PROGRAM_NAMES = {
      'Youth (Grades 1–6)':        'youth soccer program (grades 1–6)',
      'Boys Club (Grades 1–6)':    'Boys Club soccer program (grades 1–6)',
      'Girls Club (Grades 1–6)':   'Girls Club soccer program (grades 1–6)',
      'Brazil Men':                "Brazilian Men's team",
      'PR Men':                    "Puerto Rican Men's team",
      'U23 Men':                   "U23 Men's team",
      'U23 Women':                 "U23 Women's team",
      'APSL Trials':               'APSL trial',
    };

    const isYouth = /youth/i.test(funnelLabel || '');
    const program = PROGRAM_NAMES[funnelLabel] || 'program';
    const link    = LINKS[funnelLabel] || 'https://lighthouse1893.leagueapps.com';
    const whose   = isYouth ? "your player's" : 'your';
    const pricing = isYouth ? '$35/mo' : '$9/wk or $35/mo';

    // SMS keeps it tight: $1 hook + link, nothing else. Pricing/plan
    // selection is handled on the LeagueApps registration page where it
    // belongs (proper UI, ROSCA-compliant pre-checkout disclosure).
    // Email gets the full pricing breakdown — email is the "tell me more"
    // channel; SMS is the "tap now" channel.
    return {
      sms:
        `Hi {first}, this is {coach} w/ Lighthouse 1893 — thanks for your interest in our ${program}. ` +
        `$1 locks ${whose} spot: ${link}\n\nReply STOP to opt out.`,
      subject: `Lighthouse 1893 — ${program} (next step)`,
      email:
        `Hi {first},\n\n` +
        `Thanks for reaching out about Lighthouse 1893's ${program}.\n\n` +
        `The easiest way to get started is our $1 registration. It locks in ${whose} spot ` +
        `and starts the payment plan (${pricing}, cancel anytime).\n\n` +
        `Register here: ${link}\n\n` +
        `Reply to this email or text me at this number with any questions.\n\n` +
        `Thanks!\n{coach}\nLighthouse 1893 SC\nsoccer@lighthouse1893.org`
    };
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
      const lead  = (this._leads || []).find(l => String(l.id) === String(leadId));
      const label = lead ? this.formLabel(lead.form_id) : '';
      const tmpl  = this.messageTemplate(label);
      const body  = channel === 'text'
        ? this.fillTemplate(tmpl.sms,   lead || {})
        : this.fillTemplate(tmpl.email, lead || {});
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
