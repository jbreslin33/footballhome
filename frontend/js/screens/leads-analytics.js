// LeadsAnalyticsScreen — Cross-references logged touches (email / text /
// whatsapp / call) with live LeagueApps registration data (Mens + Youth)
// to answer "of the leads we contacted, which actually registered?"
//
// Data source: GET /api/leads/analytics (LeadsController::handleAnalytics)
// which live-fetches MensRoster + YouthRoster on every hit and builds
// email/phone lookup sets to match against lead.email / lead.phone.
//
// Because LA data is live-fetched (no persistent la_registrations table)
// the response takes ~1-2s warm.  We show a banner + spinner, then paint
// several tables.  This screen is opened deliberately from Club Admin,
// not on every render.
//
// Sections rendered (top to bottom):
//   1. Summary tile row
//   2. By funnel (form_id → human label via LeadsScreen.formLabel)
//   3. By touch count (1 / 2 / 3 / 4+)
//   4. By second-touch gap (<1d / 1-3d / 3-7d / 7-14d / 14-30d / 30d+)
//   5. Recent daily activity (last 30 days)
//   6. Matched-but-not-marked (actionable list — likely registered but
//      nobody clicked the "Signed up" checkbox in the Leads screen)
class LeadsAnalyticsScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>📊 Leads Analytics</h1>
        <p class="subtitle">Which touches actually turn into registrations?</p>
      </div>

      <div style="padding: var(--space-4);">
        <div id="la-banner" style="margin-bottom: var(--space-3); padding: var(--space-3); border-radius: 6px; background: #f1f5f9; border: 1px solid #e2e8f0; display:flex; align-items:center; gap: var(--space-3); flex-wrap: wrap; font-size: 14px;">
          <span id="la-banner-icon" style="font-size: 16px;">⏳</span>
          <span id="la-banner-text" style="flex:1; min-width: 200px;">Cross-referencing leads with LeagueApps registrations…</span>
          <button id="la-refresh" class="btn btn-secondary" style="display:none; padding: 4px 10px; font-size: 13px;">🔄 Refresh</button>
        </div>
        <div id="la-loading" style="text-align:center; padding: var(--space-6); opacity:0.6;">Loading…</div>
        <div id="la-error"   style="display:none; color: var(--color-error); padding: var(--space-4); text-align:center;"></div>
        <div id="la-body"    style="display:none;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId   = params?.clubId;
    this.clubName = params?.clubName;

    // Share the formLabel map with LeadsScreen so we don't duplicate the
    // form_id → human name table.  Fall back to raw id if the LeadsScreen
    // class isn't loaded (shouldn't happen — index.html loads leads.js first).
    this._leadsHelper = (typeof LeadsScreen === 'function')
      ? Object.create(LeadsScreen.prototype)
      : { formLabel: () => '' };

    this.element.addEventListener('click', e => {
      if (e.target.closest('.back-btn'))   this.navigation.goBack();
      if (e.target.closest('#la-refresh')) this.load();
      const openLead = e.target.closest('[data-open-lead]');
      if (openLead) {
        // Jump back to the Leads screen — user can filter/act from there.
        this.navigation.goTo('leads', {
          clubId:   this.clubId,
          clubName: this.clubName,
        });
      }
    });

    this.load();
  }

  setBanner({ icon, text, showRefresh = false }) {
    const i = this.find('#la-banner-icon');
    const t = this.find('#la-banner-text');
    const r = this.find('#la-refresh');
    if (i) i.textContent = icon;
    if (t) t.textContent = text;
    if (r) r.style.display = showRefresh ? '' : 'none';
  }

  async load() {
    const loading = this.find('#la-loading');
    const errEl   = this.find('#la-error');
    const body    = this.find('#la-body');
    if (loading) loading.style.display = '';
    if (errEl)   errEl.style.display   = 'none';
    if (body)    body.style.display    = 'none';
    this.setBanner({ icon: '⏳', text: 'Cross-referencing leads with LeagueApps registrations…' });

    try {
      const t0  = performance.now();
      const res = await this.auth.fetch('/api/leads/analytics');
      if (!res.ok) {
        const txt = await res.text();
        throw new Error(txt.slice(0, 300) || `HTTP ${res.status}`);
      }
      const data = await res.json();
      const elapsed = ((performance.now() - t0) / 1000).toFixed(1);

      if (loading) loading.style.display = 'none';
      if (body)    body.style.display    = '';

      const mensBad  = data.laFetchOk && data.laFetchOk.mens  === false;
      const youthBad = data.laFetchOk && data.laFetchOk.youth === false;
      let bannerNote = '';
      if (mensBad && youthBad)  bannerNote = ' · ⚠ LA fetch failed — match counts are 0';
      else if (mensBad)         bannerNote = ' · ⚠ Mens LA fetch failed — adult matches missing';
      else if (youthBad)        bannerNote = ' · ⚠ Youth LA fetch failed — kid matches missing';

      const laCounts = data.laRegistrationCounts || {};
      this.setBanner({
        icon: (mensBad || youthBad) ? '⚠' : '✓',
        text: `Loaded in ${elapsed}s · ${laCounts.emails || 0} LA emails + ${laCounts.phones || 0} phones cross-referenced${bannerNote}`,
        showRefresh: true,
      });

      this.renderReport(data);
    } catch (err) {
      if (loading) loading.style.display = 'none';
      if (errEl) {
        errEl.style.display = '';
        errEl.textContent = `Failed to load analytics: ${err.message}`;
      }
      this.setBanner({ icon: '✗', text: 'Failed to load analytics', showRefresh: true });
    }
  }

  renderReport(d) {
    const body = this.find('#la-body');
    if (!body) return;

    body.innerHTML = [
      this.renderSummary(d.summary || {}),
      this.renderByFunnel(d.byFunnel || []),
      this.renderByTouchCount(d.byTouchCount || []),
      this.renderByGap(d.bySecondTouchGap || []),
      this.renderDaily(d.recentActivity || []),
      this.renderMatchedUnmarked(d.matchedUnmarked || []),
    ].join('');
  }

  // ── Section 1: Summary tiles ──────────────────────────────────────
  renderSummary(s) {
    const pct = (num, den) => (den > 0) ? ((num / den) * 100).toFixed(1) + '%' : '—';
    const trueConv = pct(s.leadsMatchedLa || 0, s.leadsTouched || 0);
    const markedConv = pct(s.leadsMarkedConverted || 0, s.totalLeads || 0);

    const tile = (label, value, sub) => `
      <div style="flex:1; min-width: 140px; background:#0f172a; color:#e0f2fe; border:1px solid #334155; border-radius:8px; padding: var(--space-3);">
        <div style="font-size: 0.8rem; opacity: 0.7; text-transform: uppercase; letter-spacing: 0.05em;">${label}</div>
        <div style="font-size: 1.75rem; font-weight: 700; margin-top: 4px;">${value}</div>
        ${sub ? `<div style="font-size: 0.8rem; opacity: 0.65; margin-top: 2px;">${sub}</div>` : ''}
      </div>
    `;

    return `
      <div style="margin-bottom: var(--space-4);">
        <h2 style="margin: 0 0 var(--space-3);">Summary</h2>
        <div style="display:flex; gap: var(--space-2); flex-wrap: wrap;">
          ${tile('Total leads',       s.totalLeads       || 0, `${s.leadsWithEmail || 0} w/ email · ${s.leadsWithPhone || 0} w/ phone`)}
          ${tile('Touched',           s.leadsTouched     || 0, pct(s.leadsTouched || 0, s.totalLeads || 0) + ' of leads')}
          ${tile('Matched in LA',     s.leadsMatchedLa   || 0, trueConv + ' of touched')}
          ${tile('Marked "Signed up"',s.leadsMarkedConverted || 0, markedConv + ' of all leads')}
          ${tile('Matched but not marked', s.matchedNotMarked || 0, 'action needed')}
          ${tile('Dead',              s.leadsDead        || 0, pct(s.leadsDead || 0, s.totalLeads || 0) + ' of leads')}
        </div>
      </div>
    `;
  }

  // ── Section 2: By funnel ──────────────────────────────────────────
  renderByFunnel(rows) {
    if (!rows.length) return '';
    // Sort by leads desc so the biggest funnels are first.
    const sorted = rows.slice().sort((a, b) => (b.leads || 0) - (a.leads || 0));
    const trBody = sorted.map(r => {
      const label = this._leadsHelper.formLabel(r.formId) || (r.formId ? `Form ${r.formId}` : 'No form');
      const touchedRate = r.leads > 0 ? ((r.touched / r.leads) * 100).toFixed(0) + '%' : '—';
      const matchedRate = r.touched > 0 ? ((r.matched / r.touched) * 100).toFixed(1) + '%' : '—';
      return `<tr>
        <td>${label}</td>
        <td style="text-align:right;">${r.leads}</td>
        <td style="text-align:right;">${r.touched} <span style="opacity:0.6;">(${touchedRate})</span></td>
        <td style="text-align:right; color:#0369a1; font-weight:600;">${r.matched} <span style="opacity:0.6; font-weight:400;">(${matchedRate})</span></td>
        <td style="text-align:right;">${r.marked}</td>
      </tr>`;
    }).join('');

    return this._table('Funnel performance (by ad form)',
      ['Funnel', 'Leads', 'Touched', 'Matched in LA', 'Marked'], trBody,
      'LA match rate = share of touched leads whose email or phone appears in the live LeagueApps roster.');
  }

  // ── Section 3: By touch count ────────────────────────────────────
  renderByTouchCount(rows) {
    if (!rows.length) return '';
    const trBody = rows.map(r => {
      const matchedRate = r.leads > 0 ? ((r.matched / r.leads) * 100).toFixed(1) + '%' : '—';
      return `<tr>
        <td>${r.touches === '0' ? 'Never touched' : r.touches + ' touch' + (r.touches === '1' ? '' : 'es')}</td>
        <td style="text-align:right;">${r.leads}</td>
        <td style="text-align:right; color:#0369a1; font-weight:600;">${r.matched} <span style="opacity:0.6; font-weight:400;">(${matchedRate})</span></td>
        <td style="text-align:right;">${r.marked}</td>
      </tr>`;
    }).join('');

    return this._table('Conversion by touch count',
      ['Touches', 'Leads', 'Matched in LA', 'Marked'], trBody,
      'Does sending more emails help?  Compare match rates across touch counts.');
  }

  // ── Section 4: By 2nd-touch gap ──────────────────────────────────
  renderByGap(rows) {
    if (!rows.length) return '';
    const trBody = rows.map(r => {
      const matchedRate = r.leads > 0 ? ((r.matched / r.leads) * 100).toFixed(1) + '%' : '—';
      return `<tr>
        <td>${r.bucket}</td>
        <td style="text-align:right;">${r.leads}</td>
        <td style="text-align:right; color:#0369a1; font-weight:600;">${r.matched} <span style="opacity:0.6; font-weight:400;">(${matchedRate})</span></td>
        <td style="text-align:right;">${r.marked}</td>
      </tr>`;
    }).join('');

    return this._table('Second-touch gap → conversion',
      ['Gap between 1st and 2nd email', 'Leads', 'Matched in LA', 'Marked'], trBody,
      'Only counts leads that got a 2nd email.  Short gaps (<1d) look spammy — see if the data confirms it.');
  }

  // ── Section 5: Recent daily activity ─────────────────────────────
  renderDaily(rows) {
    if (!rows.length) return '';
    // Server returns most-recent first — keep that order.
    const trBody = rows.map(r => `<tr>
        <td>${r.day}</td>
        <td style="text-align:right;">${r.emails}</td>
        <td style="text-align:right;">${r.texts}</td>
        <td style="text-align:right;">${r.newLeads}</td>
      </tr>`).join('');

    return this._table('Recent activity (last 30 days)',
      ['Date', 'Emails sent', 'Texts sent', 'New leads'], trBody);
  }

  // ── Section 6: Matched but not marked ────────────────────────────
  renderMatchedUnmarked(rows) {
    if (!rows.length) {
      return `
        <div style="margin-bottom: var(--space-4);">
          <h2 style="margin: 0 0 var(--space-3);">Matched but not marked</h2>
          <p style="opacity:0.65;">Nothing to review — every LA-matched lead is already marked "Signed up".</p>
        </div>
      `;
    }

    const trBody = rows.map(r => {
      const label = this._leadsHelper.formLabel(r.formId) || (r.formId ? `Form ${r.formId}` : '—');
      const last = r.lastTouchAt ? new Date(r.lastTouchAt).toLocaleDateString() : '—';
      return `<tr>
        <td><a href="#" data-open-lead style="color:#0369a1; text-decoration:none;">${this._esc(r.name || '(no name)')}</a></td>
        <td>${this._esc(r.email || '')}</td>
        <td>${this._esc(r.phone || '')}</td>
        <td>${label}</td>
        <td style="text-align:right;">${r.touchCount}</td>
        <td>${last}</td>
      </tr>`;
    }).join('');

    return `
      <div style="margin-bottom: var(--space-4);">
        <h2 style="margin: 0 0 var(--space-2);">Matched but not marked <span style="opacity:0.6; font-size:0.9rem;">(${rows.length})</span></h2>
        <p style="opacity:0.65; margin: 0 0 var(--space-3); font-size: 0.9rem;">
          These leads appear in the LeagueApps roster (email or phone match) but nobody has clicked "Signed up" in the Leads screen.
          Click a name to jump to the Leads screen and mark them as converted.
        </p>
        <div style="overflow-x:auto;">
          <table style="width:100%; border-collapse: collapse; font-size: 0.9rem;">
            <thead><tr style="border-bottom: 1px solid #cbd5e1; text-align:left;">
              <th style="padding: 6px 8px;">Name</th>
              <th style="padding: 6px 8px;">Email</th>
              <th style="padding: 6px 8px;">Phone</th>
              <th style="padding: 6px 8px;">Funnel</th>
              <th style="padding: 6px 8px; text-align:right;">Touches</th>
              <th style="padding: 6px 8px;">Last touch</th>
            </tr></thead>
            <tbody>${trBody.replace(/<td/g, '<td style="padding: 6px 8px; border-bottom: 1px solid #f1f5f9;"')}</tbody>
          </table>
        </div>
      </div>
    `;
  }

  // ── Helpers ──────────────────────────────────────────────────────
  _table(title, headers, rowsHtml, subtitle) {
    const th = headers.map((h, i) => `<th style="padding: 6px 8px; text-align:${i === 0 ? 'left' : 'right'};">${h}</th>`).join('');
    // Inject padding + border into every <td> without duplicating in every
    // caller — one regex pass on the row HTML.
    const paddedBody = rowsHtml.replace(/<td/g, '<td style="padding: 6px 8px; border-bottom: 1px solid #f1f5f9;"');
    return `
      <div style="margin-bottom: var(--space-4);">
        <h2 style="margin: 0 0 var(--space-2);">${title}</h2>
        ${subtitle ? `<p style="opacity:0.65; margin: 0 0 var(--space-3); font-size: 0.9rem;">${subtitle}</p>` : ''}
        <div style="overflow-x:auto;">
          <table style="width:100%; border-collapse: collapse; font-size: 0.9rem;">
            <thead><tr style="border-bottom: 1px solid #cbd5e1;">${th}</tr></thead>
            <tbody>${paddedBody}</tbody>
          </table>
        </div>
      </div>
    `;
  }

  _esc(s) {
    return String(s || '').replace(/[&<>"']/g, c => ({
      '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    }[c]));
  }
}
