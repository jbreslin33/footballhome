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
      const [leadsRes, spendRes] = await Promise.all([
        this.auth.fetch('/api/leads'),
        this.auth.fetch('/api/ads/spend').catch(() => null),
      ]);
      if (!leadsRes.ok) throw new Error(`HTTP ${leadsRes.status}`);
      const leads = await leadsRes.json();
      const spend = spendRes && spendRes.ok ? await spendRes.json() : [];

      this.find('#leads-loading').style.display = 'none';

      if (!leads.length) {
        this.find('#leads-empty').style.display = 'block';
        return;
      }

      this.find('#leads-list').style.display = 'block';
      this.renderLeads(leads, spend);
    } catch (err) {
      this.find('#leads-loading').style.display = 'none';
      this.find('#leads-error').style.display   = 'block';
      this.find('#leads-error').textContent     = `Failed to load leads: ${err.message}`;
    }
  }

  renderLeads(leads, spend = []) {
    const container = this.find('#leads-list');

    const COLUMNS = ['Brazil Men', 'U23 Men', 'PR Men', 'U23 Women', 'APSL Trials'];
    const COLORS  = {
      'Brazil Men':  '#15803d',
      'U23 Men':     '#1d4ed8',
      'PR Men':      '#7c3aed',
      'U23 Women':   '#be185d',
      'APSL Trials': '#f59e0b',
    };

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

    container.innerHTML = `
      <p style="opacity:0.6; font-size:0.85rem; margin-bottom:var(--space-3);">${leads.length} lead${leads.length !== 1 ? 's' : ''}</p>
      <div style="display:grid; grid-template-columns:repeat(5,1fr); gap:var(--space-3); align-items:start;">
        ${COLUMNS.map(col => {
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
              ${grouped[col].map(l => this.renderLead(l, false)).join('') || '<div style="opacity:0.4; font-size:0.8rem; text-align:center; padding:var(--space-2);">none</div>'}
            </div>
          </div>
        `;}).join('')}
      </div>
    `;
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
    };
    return map[formId] || null;
  }

  renderLead(lead) {
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
      </div>
    `;
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
