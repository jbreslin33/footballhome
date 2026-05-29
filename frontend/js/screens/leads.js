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
      const res = await this.auth.fetch('/api/leads');
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const leads = await res.json();

      this.find('#leads-loading').style.display = 'none';

      if (!leads.length) {
        this.find('#leads-empty').style.display = 'block';
        return;
      }

      this.find('#leads-list').style.display = 'block';
      this.renderLeads(leads);
    } catch (err) {
      this.find('#leads-loading').style.display = 'none';
      this.find('#leads-error').style.display   = 'block';
      this.find('#leads-error').textContent     = `Failed to load leads: ${err.message}`;
    }
  }

  renderLeads(leads) {
    const container = this.find('#leads-list');

    const COLUMNS = ['Brazil Men', 'U23 Men', 'PR Men', 'U23 Women'];
    const COLORS  = {
      'Brazil Men':  '#15803d',
      'U23 Men':     '#1d4ed8',
      'PR Men':      '#7c3aed',
      'U23 Women':   '#be185d',
    };

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
      <div style="display:grid; grid-template-columns:repeat(4,1fr); gap:var(--space-3); align-items:start;">
        ${COLUMNS.map(col => `
          <div>
            <div style="font-weight:700; font-size:0.85rem; color:#fff; background:${COLORS[col]}; border-radius:var(--radius-sm); padding:var(--space-1) var(--space-2); margin-bottom:var(--space-2); text-align:center;">
              ${col} <span style="opacity:0.8;">(${grouped[col].length})</span>
            </div>
            <div style="display:flex; flex-direction:column; gap:var(--space-2);">
              ${grouped[col].map(l => this.renderLead(l, false)).join('') || '<div style="opacity:0.4; font-size:0.8rem; text-align:center; padding:var(--space-2);">none</div>'}
            </div>
          </div>
        `).join('')}
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
    };
    return map[formId] || null;
  }

  renderLead(lead) {
    const date = new Date(lead.created_at).toLocaleDateString('en-US', {
      month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit'
    });

    // Parse extra fields from raw_fields for display
    const extras = [];
    if (Array.isArray(lead.raw_fields)) {
      for (const f of lead.raw_fields) {
        const key = f.name;
        if (['full_name','name','email','email_address','phone_number','phone'].includes(key)) continue;
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
        ${lead.phone ? `<div style="font-size:0.85rem; opacity:0.8;">${lead.phone}</div>` : ''}
        ${extras.length ? `<div style="font-size:0.8rem; margin-top:var(--space-1); opacity:0.8;">${extras.join(' · ')}</div>` : ''}
      </div>
    `;
  }
}
