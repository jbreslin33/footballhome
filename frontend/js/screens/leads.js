class LeadsBoardModel {
  constructor({ leads, formLabel, activeStatus = 'all', hiddenFunnels = null, alwaysShow = [] } = {}) {
    this.leads = Array.isArray(leads) ? leads : [];
    this.formLabel = formLabel || (() => null);
    this.activeStatus = activeStatus;
    this.hiddenFunnels = hiddenFunnels instanceof Set ? hiddenFunnels : new Set();
    this.alwaysShow = alwaysShow;
    this.build();
  }

  build() {
    const filteredLeads = this.leads;
    this.filteredLeads = filteredLeads;

    const FUNNEL_ORDER = [
      'Brazil Men', 'U23 Men', 'PR Men', "Men's Club",
      'U23 Women', 'Tri County Women', "Women's Club",
      'APSL / Liga 1',
      'Youth (Grades 1–6)',
      'Boys Club (Grades 1–6)', 'Boys Club (K-12)', 'Boys Club (U11/U12)',
      'Girls Club (Grades 1–6)', 'Girls Club (K-12)', 'Girls Club (U11/U12)',
    ];
    const funnelRank = (label) => {
      const i = FUNNEL_ORDER.indexOf(label);
      return i === -1 ? 999 : i;
    };

    const grouped = {};
    const statusCounts = { open: 0, followup: 0, converted: 0, all: filteredLeads.length };

    for (const lead of filteredLeads) {
      const label = this.formLabel(lead.form_id) || 'Other';
      if (!grouped[label]) grouped[label] = [];
      grouped[label].push(lead);

      const baseStatus = lead.converted_at ? 'converted' : (lead.needs_followup ? 'followup' : 'open');
      if (baseStatus === 'open') statusCounts.open += 1;
      else if (baseStatus === 'followup') statusCounts.followup += 1;
      else if (baseStatus === 'converted') statusCounts.converted += 1;
    }

    for (const label of Object.keys(grouped)) {
      grouped[label].sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
    }

    for (const label of this.alwaysShow) {
      if (!grouped[label]) grouped[label] = [];
    }

    const columns = Object.keys(grouped).sort((a, b) => {
      const dr = funnelRank(a) - funnelRank(b);
      if (dr !== 0) return dr;
      return a.localeCompare(b);
    });

    const hidden = new Set(this.hiddenFunnels);
    for (const col of [...hidden]) if (!columns.includes(col)) hidden.delete(col);

    const visible = columns.filter(col => !hidden.has(col));

    const STATUS_TABS = [
      { id: 'open',      label: 'Open',          match: l => !l.converted_at && !l.needs_followup },
      { id: 'followup',  label: 'Follow-up due', match: l => !l.converted_at &&  l.needs_followup },
      { id: 'converted', label: 'Converted',     match: l => !!l.converted_at                     },
      { id: 'all',       label: 'All',           match: () => true                                 },
    ];

    let activeStatus = this.activeStatus || 'all';
    if (!STATUS_TABS.some(t => t.id === activeStatus)) activeStatus = 'all';
    const statusMatch = (STATUS_TABS.find(t => t.id === activeStatus) || STATUS_TABS[0]).match;

    const groupedFiltered = {};
    for (const col of columns) {
      groupedFiltered[col] = grouped[col].filter(statusMatch);
    }

    const visibleLeadCount = visible.reduce((n, col) => n + groupedFiltered[col].length, 0);

    this.columns = columns;
    this.visible = visible;
    this.grouped = grouped;
    this.groupedFiltered = groupedFiltered;
    this.statusCounts = statusCounts;
    this.visibleLeadCount = visibleLeadCount;
    this.activeStatus = activeStatus;
    this.hidden = hidden;
    this.statusTabs = STATUS_TABS;
  }
}

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
        <div id="leads-sync-banner" style="margin-bottom: var(--space-3); padding: var(--space-3); border-radius: 6px; background: #f1f5f9; border: 1px solid #e2e8f0; display:flex; align-items:center; gap: var(--space-3); flex-wrap: wrap; font-size: 14px;">
          <span id="leads-sync-icon" style="font-size: 16px;">⏳</span>
          <span id="leads-sync-status" style="flex:1; min-width: 200px;">Syncing latest leads from Meta…</span>
          <span id="leads-sync-time" style="padding:3px 10px; border-radius:9999px; font-size:12px; font-weight:500; background:transparent; color:#94a3b8; border:1px solid #94a3b8; white-space:nowrap;">Last sync: —</span>
          <button id="leads-sync-log-toggle" class="btn btn-secondary" style="padding: 4px 10px; font-size: 13px;" title="Show/hide load log">📜 Log</button>
          <button id="leads-sync-refresh" class="btn btn-secondary" style="padding: 4px 10px; font-size: 13px;">🔄 Sync now</button>
        </div>
        <div id="leads-sync-log" style="display:block; margin: 0 0 var(--space-3) 0; max-height: 220px; overflow-y: auto; padding: 8px 10px; border-radius: 6px; background: #0f172a; color: #cbd5e1; border: 1px solid #1e293b; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: 12px; line-height: 1.4;"></div>
        <div id="leads-form-status-pills" style="display:flex; gap:var(--space-2); margin-bottom:var(--space-3);">
          <button type="button" class="form-status-pill" data-form-status="active">🟢 Active</button>
          <button type="button" class="form-status-pill" data-form-status="inactive">⚪ Inactive</button>
        </div>
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

    // Active/Inactive pill above the board — filters which Meta lead
    // forms are shown by whether they currently have a live ad running.
    // Always defaults to Active on screen entry (not persisted) so a
    // coach who last looked at Inactive doesn't land there again and
    // miss new leads.
    this._formStatus = 'active';

    this.element.addEventListener('click', e => {
      if (e.target.closest('.back-btn')) this.navigation.goBack();
      if (e.target.closest('#leads-sync-refresh')) this.loadLeads({ force: true });
      if (e.target.closest('#leads-sync-log-toggle')) {
        const log = this.find('#leads-sync-log');
        if (log) log.style.display = (log.style.display === 'none') ? 'block' : 'none';
      }
      const pillBtn = e.target.closest('.form-status-pill');
      if (pillBtn) this.switchFormStatus(pillBtn.getAttribute('data-form-status'));
    });

    this._updateFormStatusPills();
    this.loadLeads();
    // Ticker keeps the last-sync pill's color/age label fresh while the
    // screen stays open (green → yellow → orange → red as time drifts).
    this._updateSyncPill();
    this._startSyncTicker();
    // Kick off the registration-links fetch now so it's ready by the time
    // funnelContext() needs it (message drafting happens after the coach
    // reviews a lead, well after screen load).
    window.LighthouseProgramInfo.loadRegisterLinks();
  }

  _updateFormStatusPills() {
    const wrap = this.find('#leads-form-status-pills');
    if (!wrap) return;
    wrap.querySelectorAll('.form-status-pill').forEach(btn => {
      const active = btn.getAttribute('data-form-status') === this._formStatus;
      btn.style.padding      = '6px 14px';
      btn.style.fontSize     = '0.85rem';
      btn.style.fontWeight   = '700';
      btn.style.borderRadius = '999px';
      btn.style.cursor       = 'pointer';
      btn.style.background   = active ? '#14532d' : 'var(--bg-secondary)';
      btn.style.color        = active ? '#bbf7d0' : 'inherit';
      btn.style.border       = `1px solid ${active ? '#22c55e' : 'transparent'}`;
    });
  }

  // Switching the Active/Inactive pill is a pure DB re-read filtered by
  // lead_forms (already kept fresh by the live Meta pull that runs at
  // the top of loadLeads()) — no Meta round-trip here, so it's fast and
  // doesn't disturb the sync banner/log.
  async switchFormStatus(status) {
    if (status === this._formStatus) return;
    this._formStatus = status;
    this._updateFormStatusPills();

    this.find('#leads-error').style.display   = 'none';
    this.find('#leads-empty').style.display   = 'none';
    this.find('#leads-list').style.display    = 'none';
    this.find('#leads-loading').style.display = 'block';

    try {
      const res = await this.auth.fetch(`/api/leads?status=${encodeURIComponent(status)}`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const leads = await res.json();
      this._leads = leads;
      this.find('#leads-loading').style.display = 'none';
      this.find('#leads-list').style.display    = 'block';
      this.renderLeads(leads);
    } catch (err) {
      this.find('#leads-loading').style.display = 'none';
      this.find('#leads-error').style.display   = 'block';
      this.find('#leads-error').textContent     = `Failed to load ${status} leads: ${err.message}`;
    }
  }

  onExit() {
    this._stopSyncTicker();
  }

  _setSyncBanner({ icon, text, showRefresh = true }) {
    // Sync button is always visible so the operator can force a fresh
    // pull at any time — during first load, after success, or after
    // failure.  `showRefresh` is kept for backward-compat callers but
    // now defaults to true and is effectively ignored (button never
    // hides).
    const iconEl = this.find('#leads-sync-icon');
    const textEl = this.find('#leads-sync-status');
    const btnEl  = this.find('#leads-sync-refresh');
    if (iconEl) iconEl.textContent = icon;
    if (textEl) textEl.textContent = text;
    if (btnEl)  btnEl.style.display = 'inline-block';
  }

  // Color palette for the last-sync pill based on age:
  //   0-5m  green   |  5-10m  yellow  |  10-15m  orange  |  15m+  red
  _syncPillStyle() {
    if (!this._lastSyncAt) {
      return { bg: 'transparent', color: '#94a3b8', border: '#94a3b8', ago: null, min: null };
    }
    const min = Math.floor((Date.now() - this._lastSyncAt.getTime()) / 60000);
    let bg, color, border;
    if (min < 5)       { bg='#d1fae5'; color='#065f46'; border='#10b981'; }
    else if (min < 10) { bg='#fef9c3'; color='#854d0e'; border='#eab308'; }
    else if (min < 15) { bg='#fed7aa'; color='#7c2d12'; border='#f97316'; }
    else               { bg='#fee2e2'; color='#7f1d1d'; border='#ef4444'; }
    const ago = min < 1 ? 'just now' : `${min}m ago`;
    return { bg, color, border, ago, min };
  }

  _updateSyncPill() {
    const el = this.find('#leads-sync-time');
    if (!el) return;
    const s = this._syncPillStyle();
    el.style.background   = s.bg;
    el.style.color        = s.color;
    el.style.borderColor  = s.border;
    if (!this._lastSyncAt) {
      el.textContent = 'Last sync: —';
      return;
    }
    const timeStr = this._lastSyncAt.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
    el.textContent = `Last sync: ${timeStr} (${s.ago})`;
  }

  _startSyncTicker() {
    this._stopSyncTicker();
    // 30s cadence — age is minute-granular so this is plenty responsive.
    this._syncTicker = setInterval(() => this._updateSyncPill(), 30 * 1000);
  }
  _stopSyncTicker() {
    if (this._syncTicker) {
      clearInterval(this._syncTicker);
      this._syncTicker = null;
    }
  }

  // Sticky paste-instruction banner shown after clicking ✉ Email.  Two
  // jobs:
  //   1. Tell the coach the body is on the clipboard and how to use it
  //      (Ctrl+A then Ctrl+V in Gmail's compose body to swap the plain-
  //      text pre-fill for the HTML version with a clickable link).
  //   2. Reassure: even if they don't paste, Gmail auto-linkifies URLs
  //      for the recipient on send — clicking Send as-is still works.
  // Banner is dismissible and auto-hides after 20s so it doesn't linger.
  _showEmailPasteBanner(copied, toEmail) {
    let el = this.find('#leads-paste-banner');
    if (!el) {
      el = document.createElement('div');
      el.id = 'leads-paste-banner';
      el.style.cssText =
        'position:sticky; top:0; z-index:50; margin: 0 0 var(--space-3) 0; ' +
        'padding: 10px 14px; border-radius:6px; background:#1e3a5f; ' +
        'color:#dbeafe; border:1px solid #3b82f6; display:flex; ' +
        'align-items:flex-start; gap:10px; font-size:13px; line-height:1.4;';
      const banner = this.find('#leads-sync-banner');
      if (banner && banner.parentElement) {
        banner.parentElement.insertBefore(el, banner);
      } else {
        this.element.appendChild(el);
      }
    }
    if (this._pasteBannerTimer) {
      clearTimeout(this._pasteBannerTimer);
      this._pasteBannerTimer = null;
    }
    const msg = copied
      ? `<strong>📋 Rich body copied to clipboard.</strong> Gmail's compose pre-fills the body as <em>plain text</em> and won't show the URL as a link in the editor. ` +
        `In the new Gmail tab, click in the body, press <kbd>Ctrl+A</kbd> then <kbd>Ctrl+V</kbd> to swap in the version with a clickable link — then hit Send. ` +
        `(If you skip the paste, Gmail still auto-links URLs for the recipient on Send.)`
      : `<strong>⚠ Clipboard blocked.</strong> Gmail opened with the body pre-filled as plain text. ` +
        `Hit Send and Gmail will auto-link the URL for the recipient.`;
    el.innerHTML =
      `<span style="font-size:16px;">✉</span>` +
      `<div style="flex:1;">${msg}` +
      (toEmail ? `<div style="opacity:0.75; font-size:11px; margin-top:4px;">→ ${toEmail}</div>` : '') +
      `</div>` +
      `<button type="button" data-paste-banner-close style="background:transparent; color:#dbeafe; border:1px solid #3b82f6; border-radius:4px; padding:2px 8px; cursor:pointer; font-size:12px;">Dismiss</button>`;
    el.style.display = 'flex';
    const closeBtn = el.querySelector('[data-paste-banner-close]');
    if (closeBtn) closeBtn.onclick = () => { el.style.display = 'none'; };
    this._pasteBannerTimer = setTimeout(() => { el.style.display = 'none'; }, 20000);
  }

  _clearLog() {
    const log = this.find('#leads-sync-log');
    if (log) log.innerHTML = '';
  }

  _appendLog(message, level = 'info') {
    const log = this.find('#leads-sync-log');
    if (!log) return;
    const time = new Date().toLocaleTimeString([], { hour12: false });
    const color =
      level === 'error' ? '#f87171' :
      level === 'warn'  ? '#fbbf24' :
      level === 'ok'    ? '#4ade80' :
      level === 'step'  ? '#60a5fa' :
                          '#cbd5e1';
    const row = document.createElement('div');
    row.style.cssText = `padding:1px 0; color:${color}; white-space:pre-wrap;`;
    row.textContent = `${time}  ${message}`;
    log.appendChild(row);
    log.scrollTop = log.scrollHeight;
  }

  async loadLeads({ force = false } = {}) {
    // ── Accuracy > speed ─────────────────────────────────────────────
    // We ALWAYS sync from Meta first, then render the DB.  Webhooks
    // are usually live but Meta occasionally drops events; pulling
    // before render is the only way the coach can trust the screen.
    // The banner reports each phase so the user knows it isn't hung.
    this.find('#leads-error').style.display = 'none';
    this.find('#leads-list').style.display  = 'none';
    this.find('#leads-empty').style.display = 'none';
    this.find('#leads-loading').style.display = 'block';
    this._setSyncBanner({ icon: '⏳', text: 'Syncing latest leads from Meta…' });
    this._clearLog();
    this._appendLog(`Load started${force ? ' (force=1, bypassing 30s TTL)' : ''}.`, 'step');
    this._appendLog('POST /api/leads/sync — pulling latest from Meta Graph API…', 'step');
    this._appendLog('POST /api/leads/refresh-ad-status — pulling live ad status from Instagram/Facebook…', 'step');

    const syncStartMs = Date.now();
    let syncReport = null;

    // First thing on load: ask Meta which lead forms currently have a
    // live ad running (not the DB — that's the whole point) and upsert
    // that into lead_forms server-side. The Active-pill leads GET below
    // waits on this so it always filters against a just-refreshed set,
    // never a stale one.
    const adStatusPromise = (async () => {
      const start = Date.now();
      try {
        const res = await this.auth.fetch('/api/leads/refresh-ad-status', { method: 'POST' });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = await res.json();
        if (data.ok === false) throw new Error(data.error || 'unknown error');
        const n = (data.active_form_ids || []).length;
        this._appendLog(`Ad status OK: ${n} form(s) currently active on Meta (${Date.now() - start}ms).`, 'ok');
      } catch (err) {
        this._appendLog(`Ad status refresh FAILED: ${err.message} — Active/Inactive split may be stale.`, 'warn');
      }
    })();

    const syncPromise = (async () => {
      try {
        const syncRes = await this.auth.fetch(
          `/api/leads/sync${force ? '?force=1' : ''}`,
          { method: 'POST' }
        );
        if (!syncRes.ok) throw new Error(`sync HTTP ${syncRes.status}`);
        const report = await syncRes.json();
        const syncMs = Date.now() - syncStartMs;
        if (report.skippedByTtl) {
          this._appendLog(`Sync skipped: cached <30s ago (use Sync now to force). (${syncMs}ms)`, 'info');
        } else {
          const synced  = report.syncedRows ?? 0;
          const formsT  = report.formsTotal ?? '?';
          const formsS  = report.formsSynced ?? '?';
          const failed  = (report.failedForms || []).length;
          this._appendLog(`Sync OK: ${synced} row(s) from ${formsS}/${formsT} form(s) in ${syncMs}ms.`, 'ok');
          if (failed) {
            this._appendLog(`${failed} form(s) failed during sync:`, 'warn');
            for (const f of report.failedForms) {
              this._appendLog(`  • form ${f.form_id || f.formId || '?'}: ${f.error || 'unknown'}`, 'warn');
            }
          }
          if (Array.isArray(report.perForm)) {
            for (const f of report.perForm) {
              const label = f.label || f.form_id || '?';
              this._appendLog(`  • ${label}: +${f.synced ?? 0} new`, 'info');
            }
          }
        }
        return { report, syncMs };
      } catch (err) {
        this._appendLog(`Sync FAILED: ${err.message}`, 'error');
        this._setSyncBanner({
          icon: '⚠️',
          text: `Meta sync failed (${err.message}) — showing cached leads. Click Sync now to retry.`,
          showRefresh: true,
        });
        return { report: null, syncMs: Date.now() - syncStartMs };
      }
    })();

    const leadsPromise = (async () => {
      await adStatusPromise;  // don't filter against a stale lead_forms table
      this._appendLog(`GET /api/leads?status=${this._formStatus} — reading from database…`, 'step');
      const dbStart = Date.now();
      const leadsRes = await this.auth.fetch(`/api/leads?status=${encodeURIComponent(this._formStatus)}`);
      if (!leadsRes.ok) throw new Error(`HTTP ${leadsRes.status}`);
      const leads = await leadsRes.json();
      this._appendLog(`DB returned ${leads.length} lead(s) in ${Date.now() - dbStart}ms.`, 'ok');

      try {
        const buckets = {};
        for (const l of leads) {
          const lbl = this.formLabel(l.form_id) || 'Other';
          buckets[lbl] = (buckets[lbl] || 0) + 1;
        }
        const summary = Object.entries(buckets)
          .sort((a, b) => b[1] - a[1])
          .map(([k, v]) => `${k}=${v}`)
          .join(', ');
        if (summary) this._appendLog(`By funnel: ${summary}`, 'info');
        const emailed = leads.filter(l => (l.email_count || 0) > 0).length;
        this._appendLog(`Contact history: ${emailed}/${leads.length} have been emailed at least once.`, 'info');
      } catch { /* non-fatal */ }

      return leads;
    })();

    // The registration links MUST be in hand before renderLeads() runs.
    // Every card's Email/Text href is built during render by
    // funnelContext(), which reads window.LighthouseProgramInfo
    // .REGISTER_LINKS synchronously. onEnter only *starts* that fetch, so
    // before 2026-08-26 this was a race: if the links lost it — or the
    // request failed outright, which left REGISTER_LINKS {} forever — every
    // lead on the board got the bare `https://lighthouse1893.leagueapps.com`
    // fallback. That URL is the club's programme LIST: Membership and
    // Pickup side by side, each with its own Register button. The lead
    // picks, and half the time they pick wrong (see person 22546,
    // registered Pickup on 2026-08-07 when the parent meant the club).
    //
    // The promise is cached inside loadRegisterLinks(), so awaiting it here
    // costs one round-trip on first load and nothing on later refreshes.
    // It is deliberately part of the same Promise.all as the Meta sync
    // rather than sequenced after it — the two are independent, and the
    // sync is much the slower of the two, so this adds no wall-clock in
    // the normal case.
    try {
      const [{ report }, leads] = await Promise.all([
        syncPromise,
        leadsPromise,
        window.LighthouseProgramInfo.loadRegisterLinks(),
      ]);
      syncReport = report;

      this.find('#leads-loading').style.display = 'none';
      this.find('#leads-list').style.display = 'block';
      this._leads = leads;

      if (syncReport) {
        const elapsedSec = ((Date.now() - syncStartMs) / 1000).toFixed(1);
        this._lastSyncAt = new Date();
        this._updateSyncPill();
        let icon = '✅';
        let text;
        if (syncReport.skippedByTtl) {
          icon = 'ℹ️';
          text = `Cached (synced <30s ago). ${leads.length} leads.`;
        } else if (syncReport.failedForms && syncReport.failedForms.length) {
          icon = '⚠️';
          text = `Partial sync: ${syncReport.syncedRows} rows from ${syncReport.formsSynced}/${syncReport.formsTotal} forms in ${elapsedSec}s. ${syncReport.failedForms.length} form(s) failed.`;
        } else {
          text = `Synced ${syncReport.syncedRows} row${syncReport.syncedRows === 1 ? '' : 's'} from ${syncReport.formsTotal} form${syncReport.formsTotal === 1 ? '' : 's'} in ${elapsedSec}s. ${leads.length} leads total.`;
        }
        this._setSyncBanner({ icon, text, showRefresh: true });
      }

      this._appendLog('Rendering cards…', 'step');
      const renderStart = Date.now();
      this.renderLeads(leads);
      this._appendLog(`Render complete in ${Date.now() - renderStart}ms. Done.`, 'ok');
    } catch (err) {
      this._appendLog(`Failed to load leads: ${err.message}`, 'error');
      this.find('#leads-loading').style.display = 'none';
      this.find('#leads-error').style.display   = 'block';
      this.find('#leads-error').textContent     = `Failed to load leads: ${err.message}`;
      this._setSyncBanner({
        icon: '❌',
        text: `Could not load leads from database: ${err.message}`,
        showRefresh: true,
      });
    }
  }

  renderLeads(leads) {
    const container = this.find('#leads-list');

    // The leads screen is a prospect board.  We still surface member
    // state per lead so operators can see which prospects already belong
    // to the club, but we do not load or render the full roster section.
    // SMS bot-risk banner removed 2026-06-16: leads page is email-only
    // now (initial-touch via Gmail compose).  SMS will return as part
    // of a separate RSVP-reminder workflow with its own throttling UI.

    // ── Columns = funnel labels derived from each lead's own form_id ──
    // We intentionally do NOT call /api/ads/targeting here — that's a
    // Meta API hop and slows down the page.  Group by funnel label so
    // leads from multiple ads pointing at the same form roll up
    // cleanly.  Empty funnel columns (live ad, no leads yet) live on
    // the Ads Stats screen, not here.
    const FUNNEL_COLORS = {
      'Brazil Men':              '#15803d',
      'U23 Men':                 '#1d4ed8',
      'PR Men':                  '#7c3aed',
      'U23 Women':               '#be185d',
      'Tri County Women':        '#9d174d',
      "Men's Club":              '#1d4ed8',
      "Women's Club":            '#be185d',
      'APSL / Liga 1':           '#f59e0b',
      'APSL Trials':             '#f59e0b',
      'LIGA 1 Trials':           '#f59e0b',
      'Youth (Grades 1–6)':      '#c9a14a',
      'Boys Club (Grades 1–6)':  '#0e7490',
      'Boys Club (K-12)':        '#0e7490',
      'Boys Club (U11/U12)':     '#0e7490',
      'Girls Club (Grades 1–6)': '#db2777',
      'Girls Club (K-12)':       '#db2777',
      'Girls Club (U11/U12)':    '#db2777',
    };
    const DEFAULT_COLOR = '#475569';

    const HIDDEN_KEY = 'leads.hiddenFunnels';
    const STATUS_KEY  = 'leads.activeStatus.v2';

    let hidden;
    try {
      hidden = new Set(JSON.parse(localStorage.getItem(HIDDEN_KEY) || '[]'));
    } catch { hidden = new Set(); }

    let activeStatus;
    try {
      activeStatus = localStorage.getItem(STATUS_KEY) || 'all';
    } catch { activeStatus = 'all'; }

    const board = new LeadsBoardModel({
      leads,
      formLabel: this.formLabel.bind(this),
      activeStatus,
      hiddenFunnels: hidden,
      alwaysShow: [
        'U23 Men',
        'Youth (Grades 1–6)',
        'Boys Club (Grades 1–6)',
        'Girls Club (Grades 1–6)',
        'Boys Club (U11/U12)',
        'Girls Club (U11/U12)',
      ],
    });

    const { columns, visible, grouped, groupedFiltered, statusCounts, visibleLeadCount, statusTabs, hidden: resolvedHidden } = board;
    hidden = resolvedHidden;

    container.innerHTML = `
      <div style="display:flex; align-items:center; gap:var(--space-2); flex-wrap:wrap; margin-bottom:var(--space-2);">
        ${statusTabs.map(t => {
          const active = t.id === activeStatus;
          const bg     = active ? '#1e3a5f' : 'var(--bg-secondary)';
          const fg     = active ? '#dbeafe' : 'inherit';
          const border = active ? '#3b82f6' : 'transparent';
          return `
          <button type="button" class="status-tab" data-status="${t.id}"
                  style="padding:6px 12px; font-size:0.85rem; font-weight:600; border-radius:999px; cursor:pointer;
                         background:${bg}; color:${fg}; border:1px solid ${border};">
            ${t.label}
            <span style="opacity:0.65; font-weight:500; margin-left:4px;">(${statusCounts[t.id]})</span>
          </button>`;
        }).join('')}
      </div>
      <div style="display:flex; align-items:center; gap:var(--space-3); flex-wrap:wrap; margin-bottom:var(--space-3); padding:var(--space-2) var(--space-3); background:var(--bg-secondary); border-radius:var(--radius-md);">
        <span style="opacity:0.7; font-size:0.8rem; font-weight:600;">Show:</span>
        ${columns.length === 0 ? `<span style="opacity:0.6; font-size:0.8rem;">No leads yet.</span>` : ''}
        ${columns.map(label => {
          const color = FUNNEL_COLORS[label] || DEFAULT_COLOR;
          return `
          <label style="display:inline-flex; align-items:center; gap:6px; font-size:0.8rem; cursor:pointer; user-select:none; padding:2px 6px; border-radius:4px; border-left:3px solid ${color};">
            <input type="checkbox" class="col-toggle" data-col="${label}" ${hidden.has(label) ? '' : 'checked'} style="cursor:pointer;">
            ${label} <span style="opacity:0.55;">(${groupedFiltered[label].length}${groupedFiltered[label].length !== grouped[label].length ? `/${grouped[label].length}` : ''})</span>
          </label>`;
        }).join('')}
      </div>
      <p style="opacity:0.6; font-size:0.85rem; margin-bottom:var(--space-3);">
        ${visibleLeadCount} of ${leads.length} lead${leads.length !== 1 ? 's' : ''} shown
        ${activeStatus !== 'all' ? `<span style="opacity:0.7;">— filtered by <strong>${(statusTabs.find(t => t.id === activeStatus) || {}).label}</strong></span>` : ''}
      </p>
      ${columns.length === 0 ? `
        <div style="text-align:center; padding:var(--space-6); opacity:0.6;">No leads yet.</div>
      ` : visible.length === 0 ? `
        <div style="text-align:center; padding:var(--space-6); opacity:0.5;">All columns hidden — check a box above to show leads.</div>
      ` : visibleLeadCount === 0 ? `
        <div style="text-align:center; padding:var(--space-6); opacity:0.5;">No leads in this tab. Try a different status above.</div>
      ` : `
      <div style="display:grid; grid-template-columns:repeat(${visible.length},minmax(220px,1fr)); gap:var(--space-3); align-items:start; overflow-x:auto;">
        ${visible.map(label => {
          const color = FUNNEL_COLORS[label] || DEFAULT_COLOR;
          const inner = groupedFiltered[label].map(l => this.renderLead(l, label)).join('');
          return `
          <div>
            <div style="font-weight:700; font-size:0.85rem; color:#fff; background:${color}; border-radius:var(--radius-sm); padding:var(--space-1) var(--space-2); margin-bottom:var(--space-2); text-align:center;">
              ${label} <span style="opacity:0.8;">(${groupedFiltered[label].length}${groupedFiltered[label].length !== grouped[label].length ? `/${grouped[label].length}` : ''})</span>
            </div>
            <div style="display:flex; flex-direction:column; gap:var(--space-2);">
              ${inner}
            </div>
          </div>
        `;}).join('')}
      </div>`}
    `;

    // Wire status-tab clicks → persist + re-render from cached data.
    container.querySelectorAll('.status-tab').forEach(btn => {
      btn.addEventListener('click', () => {
        const id = btn.getAttribute('data-status');
        try { localStorage.setItem(STATUS_KEY, id); } catch {}
        this.renderLeads(this._leads || leads);
      });
    });

    // Wire checkbox toggles → persist + re-render with cached data
    container.querySelectorAll('.col-toggle').forEach(cb => {
      cb.addEventListener('change', () => {
        const col = cb.getAttribute('data-col');
        if (cb.checked) hidden.delete(col); else hidden.add(col);
        try { localStorage.setItem(HIDDEN_KEY, JSON.stringify([...hidden])); } catch {}
        this.renderLeads(this._leads || leads);
      });
    });

    // Wire contact action buttons (email / save vCard).  SMS / WhatsApp
    // / snippet copy buttons are no longer rendered on this screen —
    // copy snippets live on the Messages screen.
    container.querySelectorAll('.contact-btn').forEach(btn => {
      btn.addEventListener('click', (e) => this.onContactClick(e));
    });

    // Wire signed-up / undo buttons.  Confirm before clearing so a
    // misclick doesn't wipe a valid conversion record.
    container.querySelectorAll('.convert-btn').forEach(btn => {
      btn.addEventListener('click', (e) => this.onConvertClick(e));
    });

    // Wire mark-dead / revive buttons.  No confirm — the dead lead
    // stays visible in All + Dead tabs and revive is one click away.
    container.querySelectorAll('.dead-btn').forEach(btn => {
      btn.addEventListener('click', (e) => this.onDeadClick(e));
    });

    // Wire ✏️ Edit buttons → opens the lifecycle / color-override
    // modal.  Cards themselves no longer render lifecycle controls;
    // those live in the modal so the card stays scannable.
    container.querySelectorAll('.edit-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const leadId = e.currentTarget.getAttribute('data-lead-id');
        if (leadId) this.openEditModal(leadId);
      });
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
      // Club-wide player ad created 2026-08-30 via
      // scripts/ads/create-ad.js club-wide.  One pooled audience across all
      // four programs; the segment arrives as the 'program_interest' answer
      // in raw_fields rather than as separate funnels, so every lead from
      // this ad shares one label here.
      '1813864682814937': 'Club-Wide (All Programs)',
      // K-12 lead forms created 2026-06-15 via
      // scripts/convert-k12-to-form.js — converted the previously
      // direct-CTA → LeagueApps ads into proper lead-form ads so we
      // capture parent name/email/phone before the LeagueApps handoff.
      '27218140947855660': 'Boys Club (K-12)',
      '3904012603227821':  'Girls Club (K-12)',
      // Men's / Women's Club lead forms created 2026-06-15 via
      // scripts/convert-club-to-form.js — same conversion treatment as
      // K-12 but with one extra question (DOB) so the coach knows the
      // player's age before reaching out.  GENDER dropped — graphic
      // already says MENS CLUB / WOMENS CLUB.
      '821845431008120':  "Men's Club",
      '3929429224026650': "Women's Club",
      // Womens Club relaunched 2026-08-13 as a proper LEADS campaign (see
      // scripts/ads/create-ad.js "womens-club" — old campaign above paused,
      // same broken-hybrid issue mens-club had before its 6/25 fix).
      '1057769040350305': "Women's Club",
      // Tri County Women — form id TBD (no live ad yet).
      // U11/U12 Travel lead forms created 2026-06-20 via scripts/ads/create-ad.js —
      // ads share boys-club / girls-club LeagueApps URLs but use
      // utm_content=*-u11u12-travel to distinguish in funnel reports.
      '966641426206505':  'Boys Club (U11/U12)',
      '1666471931283440': 'Girls Club (U11/U12)',
      // Trial-pathway lead forms created 2026-07-04 via scripts/ads/create-ad.js.
      // Both ads point at the SAME Men's Club LeagueApps URL and are
      // differentiated only by utm_content=apsl-trials / liga1-trials.
      '1452427476902521': 'APSL Trials',
      '829329860110560':  'LIGA 1 Trials',
      // APSL Trials ad relaunched 2026-08-13 (new copy/graphic — "FALL
      // TRYOUTS", committed-players framing) replacing the 7/4 version
      // above, which is now paused. New lead form ID, same funnel label.
      '1063284936304533': 'APSL Trials',
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
    const isU1112   = /u11\s*\/?\s*u12|u11u12|u11-u12/.test(name) || /utm_content=[a-z]+-u11u12-travel/.test(url);

    // Boys/Girls Club have parallel K-12 and Grades 1–6 ads sharing the
    // same LeagueApps URL — ad name is the only way to tell them apart.
    if (/boys club/.test(name) || /\bboys-club\b/.test(url)) {
      if (isU1112)   return 'Boys Club (U11/U12)';
      if (isK12)     return 'Boys Club (K-12)';
      if (isGrade16) return 'Boys Club (Grades 1–6)';
    }
    if (/girls club/.test(name) || /\bgirls-club\b/.test(url)) {
      if (isU1112)   return 'Girls Club (U11/U12)';
      if (isK12)     return 'Girls Club (K-12)';
      if (isGrade16) return 'Girls Club (Grades 1–6)';
    }

    // Fall back to form_id map, then URL pattern.
    const byForm = this.formLabel(ad.form_id);
    if (byForm) return byForm;
    if (!url) return null;
    // Trial-pathway ads share the mens-club LeagueApps URL; utm_content
    // is the only reliable pre-form_id differentiator so it MUST be
    // matched before the generic `mens-club` fallback below.
    if (/utm_content=apsl-trials/.test(url))  return 'APSL Trials';
    if (/utm_content=liga1-trials/.test(url)) return 'LIGA 1 Trials';
    if (/\bmens-club\b/.test(url))   return "Men's Club";
    if (/\bwomens-club\b/.test(url)) return "Women's Club";
    if (/\bboys-club\b/.test(url))   return 'Boys Club (Grades 1–6)';
    if (/\bgirls-club\b/.test(url)) return 'Girls Club (Grades 1–6)';
    return null;
  }

  // ── Per-column ad details ───────────────────────────────────────────
  // All ad-specific info — targeting (status/geo/audience/regions),
  // Meta preview buttons, per-funnel message templates, and any
  // performance warnings — lives inside each column's "⋮ Ad details"
  // disclosure.  Replaces the old club-wide #ads-rundown table and
  // #templates-panel so every piece of context for an ad is right
  // where the coach is looking when they triage that ad's leads.

  // Issues / warnings for a single ad (geo leak, CPL spike, dead spend,
  // loose geo, "recent visitors" enabled).  Returns [] for non-ACTIVE ads.
  _adWarnings(a) {
    const out = [];
    if (!a || a.status !== 'ACTIVE') return out;
    // Geo leak: top region by impressions is NOT tri-state
    const top = a.regions?.[0];
    if (top && top.impressions > 50) {
      const triState = ['Pennsylvania','New Jersey','Delaware'];
      if (!triState.includes(top.region)) {
        out.push({ kind:'geo-leak', detail: `Top region is ${top.region} (${top.impressions} imp)` });
      }
    }
    // CPL > $20 warn / > $30 danger
    const cpl = a.leads > 0 ? a.spend / a.leads : null;
    if      (cpl !== null && cpl > 30) out.push({ kind:'cpl-danger', detail: `$${cpl.toFixed(2)}/lead` });
    else if (cpl !== null && cpl > 20) out.push({ kind:'cpl-warn',   detail: `$${cpl.toFixed(2)}/lead` });
    // Geo not locked down (zips allowlist or Erie Ave pin)
    const goodGeo = a.geo?.kind === 'zips'
                 || (a.geo?.kind === 'pin' && /Erie/i.test(a.geo?.address || ''));
    if (!goodGeo) out.push({ kind:'geo-loose', detail: a.geo?.label || 'unknown' });
    // "recent visitors" includes people passing through Philly
    if (a.geo?.location_types?.includes('recent')) {
      out.push({ kind:'location-recent', detail: 'location_types includes "recent"' });
    }
    // Spending budget but zero leads
    if (a.spend > 50 && a.leads === 0) {
      const days = a.start_time ? Math.floor((Date.now() - new Date(a.start_time).getTime()) / 86400000) : 0;
      out.push({ kind:'no-leads', detail: `$${a.spend.toFixed(2)} spent, 0 leads (${days}d)` });
    }
    return out;
  }

  // HTML for the per-column "⋮ Ad details" disclosure: warnings +
  // targeting (status / geo / audience / spend / regions) + Meta
  // preview buttons + per-funnel message templates.
  _renderAdColumnDetails(rawAd, funnelLabel) {
    const a = rawAd || {};
    const fmt$ = (n) => `$${(n || 0).toFixed(2)}`;
    const statusPill = (s) => {
      const colors = { ACTIVE:'#10b981', PAUSED:'#6b7280', PENDING_REVIEW:'#f59e0b', IN_PROCESS:'#f59e0b', ARCHIVED:'#374151', DELETED:'#991b1b' };
      const c = colors[s] || '#6b7280';
      return `<span style="background:${c}; color:#fff; padding:1px 6px; border-radius:8px; font-size:0.62rem; font-weight:700; letter-spacing:0.04em;">${s || '—'}</span>`;
    };
    const geoBadge = (g) => {
      if (!g) return '<span style="opacity:0.6;">no geo</span>';
      const ok = g.kind === 'zips'
              || (g.kind === 'pin' && /Erie/i.test(g.address || ''));
      const color = ok ? '#10b981' : '#f59e0b';
      const lt = (g.location_types || []).join('+') || '?';
      return `<span style="color:${color};">${g.label || '?'}</span> <span style="opacity:0.5; font-size:0.65rem;">(${lt})</span>`;
    };
    const audBadge = (ad) => {
      const ages = (ad.age_min && ad.age_max) ? `${ad.age_min}–${ad.age_max}` : '?';
      const g = ad.genders ? (ad.genders.includes(1) && ad.genders.includes(2) ? 'All' : ad.genders.includes(1) ? 'M' : 'F') : 'All';
      return `ages ${ages} · ${g}`;
    };
    const regionRows = (rs) => {
      if (!rs || rs.length === 0) return '<span style="opacity:0.5;">no region data yet</span>';
      return rs.slice(0, 3).map(r => {
        const triState = ['Pennsylvania','New Jersey','Delaware'].includes(r.region);
        const color = triState ? '#10b981' : '#ef4444';
        return `<div style="color:${color}; font-size:0.68rem;">${r.region} — ${r.impressions}🖼 / ${r.clicks}🖱 / ${r.leads}📥</div>`;
      }).join('');
    };
    const previewBtn = (fmt, label, title) => `<a
        href="/api/ads/${encodeURIComponent(a.ad_id)}/preview?format=${fmt}"
        target="_blank" rel="noopener" title="${title}"
        style="display:inline-block; padding:2px 8px; margin:0 4px 4px 0;
               font-size:0.7rem; border-radius:6px;
               background:var(--bg-tertiary, #374151); color:#e5e7eb;
               text-decoration:none; border:1px solid var(--border-color, #4b5563);"
      >${label}</a>`;

    const warnings = this._adWarnings(a);
    const warnHtml = warnings.length ? `
      <div style="background:#3d2a0a; border-left:3px solid #f59e0b; padding:6px 8px; border-radius:6px; margin-bottom:8px;">
        <div style="font-weight:700; font-size:0.7rem; color:#f59e0b; margin-bottom:4px;">⚠ ${warnings.length} issue${warnings.length>1?'s':''}</div>
        <ul style="margin:0; padding-left:16px; font-size:0.68rem; opacity:0.9; line-height:1.45;">
          ${warnings.map(w => `<li>[${w.kind}] ${w.detail}</li>`).join('')}
        </ul>
      </div>` : '';

    const targetingHtml = `
      <div style="font-size:0.7rem; line-height:1.7;">
        <div><span style="opacity:0.55;">Status:</span> ${statusPill(a.status)}</div>
        <div><span style="opacity:0.55;">Geo:</span> ${geoBadge(a.geo)}</div>
        <div><span style="opacity:0.55;">Audience:</span> ${audBadge(a)}</div>
        <div><span style="opacity:0.55;">Daily / Spend:</span> ${fmt$(a.daily_budget_usd)} / ${fmt$(a.spend)}</div>
        <div><span style="opacity:0.55;">Imp / Clk / Lds:</span> ${(a.impressions||0).toLocaleString()} / ${(a.clicks||0).toLocaleString()} / ${a.leads||0}</div>
        <div style="margin-top:4px;"><span style="opacity:0.55;">Top regions (30d):</span>${regionRows(a.regions)}</div>
      </div>`;

    const previewHtml = a.ad_id ? `
      <div style="margin-top:6px;">
        <div style="opacity:0.55; font-size:0.7rem; margin-bottom:2px;">Preview:</div>
        ${previewBtn('feed',     '📘 FB',    'Facebook mobile feed preview')}
        ${previewBtn('ig',       '📷 IG',    'Instagram feed preview')}
        ${previewBtn('ig_story', '📱 Story', 'Instagram story preview')}
      </div>` : '';

    return `
      <details style="background:var(--bg-tertiary, #1f2937); border-radius:var(--radius-sm); padding:6px 8px; margin-bottom:var(--space-2);">
        <summary style="cursor:pointer; font-size:0.72rem; font-weight:600; user-select:none; outline:none; opacity:0.85;">
          ⋮ Ad details${warnings.length ? ` <span style="color:#f59e0b;">· ⚠ ${warnings.length}</span>` : ''}
        </summary>
        <div style="margin-top:6px;">
          ${warnHtml}
          ${targetingHtml}
          ${previewHtml}
          <details style="margin-top:8px; background:var(--bg-secondary); border-radius:var(--radius-sm); padding:4px 6px;">
            <summary style="cursor:pointer; font-size:0.72rem; font-weight:600; user-select:none; outline:none; opacity:0.85;">
              📝 Message templates
            </summary>
            <div style="margin-top:6px;">
              ${this._renderFunnelTemplatesHtml(funnelLabel)}
            </div>
          </details>
        </div>
      </details>`;
  }

  // First-touch email + reply snippets for a single funnel, rendered as
  // copy-to-clipboard blurbs.  Tokens like {first} render as [Name]
  // placeholders so the templates read sensibly with no real lead.
  //
  // NOTE: pre/wrapper styling intentionally stays neutral — coaches
  // often manually select + Cmd-C the body, and inline backgrounds
  // get carried into Gmail/SMS as rich-text styling on paste.
  _renderFunnelTemplatesHtml(funnelLabel) {
    const esc = (s) => String(s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    const previewLead = { name: '[Name]', phone: '[Phone]' };

    const blurbBlock = (title, body, todo = false) => {
      const dim  = todo ? 'opacity:0.55;' : '';
      const warn = todo ? ' <span style="color:#f59e0b;" title="Placeholder — fill this in">⚠</span>' : '';
      return `
        <div style="border:1px solid var(--border-color, #334155); border-radius:var(--radius-sm); padding:6px 8px; margin-bottom:6px; ${dim}">
          <div style="display:flex; justify-content:space-between; align-items:center; gap:6px; margin-bottom:4px;">
            <strong style="font-size:0.72rem;">${esc(title)}${warn}</strong>
            <button class="copy-btn btn btn-secondary" data-copy="${esc(body)}" style="font-size:0.65rem; padding:1px 6px;">📋 Copy</button>
          </div>
          <pre style="white-space:pre-wrap; word-break:break-word; margin:0; font-family:inherit; font-size:0.7rem; line-height:1.4;">${esc(body)}</pre>
        </div>`;
    };

    const t        = this.messageTemplate(funnelLabel);
    const subject  = this.fillTemplate(t.subject, previewLead);
    const email    = this.fillTemplate(t.email,   previewLead);
    const snippets = this.messageSnippets(funnelLabel);

    const TIER_ORDER = ['alumni', 'broadcast', 'followup', 'qualify', 'close', 'soft', 'info'];
    const TIER_LABEL = { alumni: 'Alumni return', broadcast: 'Broadcast (paste to LA Messages)', followup: 'Follow-up (touch 2)', qualify: 'Qualify', close: 'Ask (close)', soft: 'Fallback', info: 'Info' };
    const byTier = {};
    for (const s of snippets) {
      const tt = s.tier || 'info';
      (byTier[tt] = byTier[tt] || []).push(s);
    }
    const snippetHtml = TIER_ORDER.flatMap(tier => {
      const items = byTier[tier];
      if (!items || !items.length) return [];
      const header = `<div style="font-size:0.6rem; opacity:0.5; text-transform:uppercase; letter-spacing:1.5px; margin:8px 0 4px;">
                        ${esc(TIER_LABEL[tier] || tier)}
                      </div>`;
      const blocks = items.map(s => {
        const body = this.fillTemplate(s.body, previewLead);
        return blurbBlock(s.label, body, !!s.todo);
      });
      return [header, ...blocks];
    }).join('');

    // Rendered HTML preview — what the recipient actually sees once the
    // coach pastes the rich body into Gmail (Ctrl+A, Ctrl+V swap).  The
    // plain-text source above is what gets copied; this is the visual
    // confirmation that the branded logo + bold labels are intact.  Open
    // by default so it's discoverable — easy to spot the difference
    // between the plain pre-fill in Gmail and the actual sent version.
    const renderedHtml = this.toLinkifiedHtml(email);
    const renderedBlock = `
      <details open style="border:1px solid var(--border-color, #334155); border-radius:var(--radius-sm); padding:6px 8px; margin-bottom:6px; background:#f9fafb;">
        <summary style="cursor:pointer; font-size:0.72rem; font-weight:600; user-select:none; outline:none; color:#1e3a8a;">
          📧 Recipient preview — what they see after you paste in Gmail
        </summary>
        <div style="background:#ffffff; border:1px solid #e5e7eb; border-radius:4px; padding:14px; margin-top:6px;">
          ${renderedHtml}
        </div>
      </details>`;

    return `
      ${blurbBlock(`First-touch Email · Subject: ${subject}`, email)}
      ${renderedBlock}
      ${snippetHtml}`;
  }

  // Auto-linkify a plain-text body into HTML: escape, wrap URLs in <a href>,
  // turn newlines into <br>.  Used by copyToClipboard to give Gmail (and any
  // other rich-text target) a proper clickable hyperlink on paste while
  // keeping the plain-text fallback intact for SMS / Notes / etc.
  // URL regex matches http(s):// up to whitespace; trims trailing punctuation
  // (.,!?;:) so 'register here: https://x.com.' doesn't capture the period.
  //
  // For full first-touch emails (detected by the "Lighthouse 1893 SC /
  // soccer@lighthouse1893.org" sign-off), we wrap the linkified body in a
  // light branded shell — small 1893 crest + club name at the top, plus
  // the labeled-block headers ("Practice — ", "Where — ", "Next:", "Games
  // — ", "Cost — ", "Season — ") bolded so the lead can scan the key
  // facts.  Snippet replies (which don't include the sign-off) fall
  // through to the plain linkified <div> — short SMS-flavored chips
  // shouldn't carry a giant logo header.
  toLinkifiedHtml(text) {
    const esc = (s) => String(s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    const URL_RE = /\bhttps?:\/\/[^\s<>"']+/g;
    let html = '';
    let last = 0;
    text.replace(URL_RE, (match, offset) => {
      html += esc(text.slice(last, offset));
      // Strip trailing punctuation so the period after a sentence doesn't
      // get pulled into the href.
      const trimmed = match.replace(/[.,!?;:)\]]+$/, '');
      const trail   = match.slice(trimmed.length);
      html += `<a href="${esc(trimmed)}">${esc(trimmed)}</a>${esc(trail)}`;
      last = offset + match.length;
      return match;
    });
    html += esc(text.slice(last));

    // Detect a full club email (sign-off present).  Snippet/SMS replies
    // bypass the branded wrapper.
    const isClubEmail = /Lighthouse 1893 SC\s*\n\s*soccer@lighthouse1893\.org/.test(text);
    if (!isClubEmail) {
      // Newlines → <br> so multi-line bodies render correctly in Gmail's
      // rich-text composer.  Wrapped in a <div> so paste doesn't inherit the
      // surrounding paragraph's color/font (Gmail respects div defaults).
      return `<div>${html.replace(/\n/g, '<br>')}</div>`;
    }

    // Bold labeled-block headers at line starts.  Match BEFORE the
    // newline→<br> swap (so `\n` anchors still work).  Allowlist of
    // labels keeps mid-sentence em-dashes ("We're in season — new
    // players welcome") from getting bolded.
    html = html
      .replace(/(^|\n)(Practice|Where|Games|Cost|Season|Subject) — /g,
               (_, pfx, lbl) => `${pfx}<strong>${lbl} — </strong>`)
      .replace(/(^|\n)Next: /g, '$1<strong>Next:</strong> ');

    // Final newline → <br> swap.
    html = html.replace(/\n/g, '<br>');

    // Branded email shell.  Inline styles only (Gmail strips <style>
    // blocks on paste).  Logo loads from /images/ on footballhome.org —
    // public, no auth required, survives the paste-into-Gmail round-trip.
    // Recipient mail clients fetch the <img src> over the wire; modern
    // clients (Gmail web, Apple Mail) load it inline.  Conservative
    // clients (Outlook desktop default config) show a tasteful alt-text
    // placeholder until the recipient clicks "show images" — still reads
    // professional, never blocks the actual message content.
    const LOGO = 'https://footballhome.org/images/lighthouse-1893-crest.png';
    return (
      `<div style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif; color:#1f2937; font-size:14px; line-height:1.55; max-width:560px;">` +
        `<table cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse; margin-bottom:14px; padding-bottom:10px; border-bottom:2px solid #1e3a8a;">` +
          `<tr>` +
            `<td style="padding-right:12px; vertical-align:middle;">` +
              `<img src="${LOGO}" alt="Lighthouse 1893 SC" width="48" height="48" style="display:block; border:0; width:48px; height:48px;">` +
            `</td>` +
            `<td style="vertical-align:middle;">` +
              `<div style="font-weight:700; font-size:14px; color:#1e3a8a; letter-spacing:0.5px;">LIGHTHOUSE 1893 SC</div>` +
              `<div style="font-size:11px; color:#6b7280; letter-spacing:1px; text-transform:uppercase;">Est. Kensington &middot; 1893</div>` +
            `</td>` +
          `</tr>` +
        `</table>` +
        `<div>${html}</div>` +
      `</div>`
    );
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
    // Modern path — write BOTH text/plain (for SMS / Notes) AND text/html
    // (for Gmail / Slack / rich editors) so URLs paste as clickable links
    // in rich targets while plain-text targets get raw URLs.  Requires
    // ClipboardItem support (Chrome 76+ / Safari 13.1+ / Firefox 127+ in
    // 2024+) — falls through to writeText / execCommand on older browsers.
    try {
      if (navigator.clipboard && window.ClipboardItem && navigator.clipboard.write) {
        const html = this.toLinkifiedHtml(text);
        const item = new ClipboardItem({
          'text/plain': new Blob([text], { type: 'text/plain' }),
          'text/html':  new Blob([html], { type: 'text/html' }),
        });
        navigator.clipboard.write([item]).then(done, () => {
          // Some browsers reject HTML clipboard for security reasons —
          // fall back to plain text rather than failing the whole copy.
          navigator.clipboard.writeText(text).then(done, fail);
        });
        return;
      }
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

  // Parent-fronted funnels: the person who filled the form is the kid's
  // parent, so the contact saves as "… Lighthouse Parent" and no birth
  // year is available (the youth lead forms never ask for one).
  //
  // Matched on the leading word, not a bare /youth/, because the funnel
  // labels that matter are "Boys Club (K-12)" and "Girls Club (U11/U12)"
  // — plain /youth/i caught only the "Youth (Grades 1–6)" column and
  // silently handed every Boys/Girls Club lead the adult treatment.
  // Anchoring also keeps "Men's Club" / "Women's Club" out.
  isParentFunnel(label) {
    return /^(youth|boys club|girls club)\b/i.test(label || '');
  }

  renderLead(lead, columnLabel = null) {
    // Funnel + capability flags.  Funnel label drives the SMS / email
    // body templates; isYouth controls vCard-pair generation.
    const label    = columnLabel || this.formLabel(lead.form_id) || '';
    const hasEmail = !!lead.email;
    const hasPhone = !!lead.phone;
    const mailHref         = hasEmail ? this.buildMailHref(lead, label) : null;
    const smsHref          = hasPhone ? this.buildSmsHref (lead, label) : null;
    // Follow-up chip hrefs — one per (template × channel) combination.
    // Email variants use buildMailHrefForSnippet (Gmail compose w/ body
    // pre-filled); text variants use buildSmsHrefForSnippet (sms: URI
    // w/ snip.smsBody pre-filled).  Order matters below — we render
    // the chip only when the corresponding channel exists on the lead.
    const closeMailHref    = hasEmail ? this.buildMailHrefForSnippet(lead, label, 'close')     : null;
    const closeSmsHref     = hasPhone ? this.buildSmsHrefForSnippet (lead, label, 'close')     : null;
    const moreInfoMailHref = hasEmail ? this.buildMailHrefForSnippet(lead, label, 'more-info') : null;
    const moreInfoSmsHref  = hasPhone ? this.buildSmsHrefForSnippet (lead, label, 'more-info') : null;
    // Call button is a plain tel: URI — no template body, no clipboard,
    // just fire the dialer.  We still POST a `call` contact row so we
    // know a dial was attempted (see onContactClick channel='call' branch).
    const callHref         = hasPhone
      ? `tel:${(lead.phone || '').replace(/[^\d+]/g, '')}`
      : null;
    const formattedPhone = this.formatPhoneNumber(lead.phone || '');
    const memberBadge = lead.member_status === 'active'
      ? `<div style="margin-top:6px; font-size:0.73rem; font-weight:700; color:#0f766e; background:rgba(20,184,166,0.12); border:1px solid rgba(20,184,166,0.25); border-radius:999px; padding:3px 8px; display:inline-flex; align-items:center; gap:5px;">● Already a member</div>`
      : (lead.member_status === 'inactive'
        ? `<div style="margin-top:6px; font-size:0.73rem; font-weight:700; color:#92400e; background:rgba(245,158,11,0.16); border:1px solid rgba(245,158,11,0.24); border-radius:999px; padding:3px 8px; display:inline-flex; align-items:center; gap:5px;">● Former member</div>`
        : '');
    // Program badge (2026-08-31) — the club-wide ad (see formLabel's
    // '1813864682814937' entry) pools all four programs into one lead
    // form, so which program a lead actually wants only lives in the
    // 'program_interest' CUSTOM-question answer inside raw_fields
    // (scripts/ads/create-ad.js club-wide), not in a dedicated column.
    // Program-specific ads never answer this question, so the badge is
    // simply absent there — no need to gate on form_id here.  Matched
    // by keyword rather than an exact key/value lookup because Meta may
    // hand back either the option's key ("boys_girls") or its display
    // value ("Boys & Girls (more than one child)") depending on
    // question type, and this reads correctly either way.
    const programBadge = (() => {
      const raw = this.extractFieldMap(lead.raw_fields).program_interest;
      if (!raw) return '';
      const v = raw.toLowerCase();
      const display = (v.includes('boys') && v.includes('girls')) ? '👦👧 Boys &amp; Girls'
        : v.includes('boys')  ? '👦 Boys'
        : v.includes('girls') ? '👧 Girls'
        : v.includes('women') ? '👩 Women'
        : v.includes('men')   ? '👨 Men'
        : raw;
      return `<div style="margin-top:6px; font-size:0.73rem; font-weight:700; color:#4338ca; background:rgba(99,102,241,0.12); border:1px solid rgba(99,102,241,0.25); border-radius:999px; padding:3px 8px; display:inline-flex; align-items:center; gap:5px;">${display}</div>`;
    })();

    // Visual status (5 buckets) — combines lifecycle (4-state, migration
    // 074) + manual override (migration 075, COALESCEd server-side) +
    // staleness derivation (touched leads with no fresh contact in
    // 3+ days bump from "Emailed/Texted" → "Needs recontact").  A manual
    // override bypasses the stale check so coaches can pin a card.
    //
    // Card carries TWO redundant signals so status reads at a glance:
    //   1. Whole-card color (left border + bg tint, fade for dead)
    //   2. Small text pill at the top of the card
    //
    //   new             green   "New"
    //   contacted       yellow  "Emailed" / "Texted" / "Emailed + Texted"
    //                            (depending on which channels logged a touch)
    //   needs_recontact orange  "Needs recontact"    (touched + stale)
    //   signedup        blue    "Signed up"          (Lighthouse blue)
    //   dead            red     "Dead"               + 0.55 opacity
    const baseStatus = lead.status || 'new';
    const overridden = !!lead.status_override;
    const isStale    = !overridden && !!lead.needs_followup;
    const visualStatus = (baseStatus === 'responded' && isStale)
      ? 'needs_recontact'
      : (baseStatus === 'responded' ? 'contacted' : baseStatus);

    // Channel-specific label for the contacted bucket.  Override + dead
    // + signedup + new all use the static visualStatus label.
    // Show "×N" when a channel was touched more than once so a
    // recontact is visible at a glance without opening the modal.
    const emailedN = Number(lead.email_count || 0);
    const textedN  = Number(lead.text_count  || 0);
    const partE = emailedN ? `Emailed${emailedN > 1 ? ' ×' + emailedN : ''}` : '';
    const partT = textedN  ? `Texted${textedN  > 1 ? ' ×' + textedN  : ''}` : '';
    const contactedLabel = [partE, partT].filter(Boolean).join(' + ') || 'Contacted';

    const STATUS_STYLES = {
      new:             { border: '#16a34a', tint: 'rgba(22, 163, 74, 0.10)', opacity: '1',    label: 'New'             },
      contacted:       { border: '#eab308', tint: 'rgba(234, 179, 8, 0.10)', opacity: '1',    label: contactedLabel    },
      needs_recontact: { border: '#f97316', tint: 'rgba(249, 115, 22, 0.14)', opacity: '1',   label: 'Needs recontact' },
      signedup:        { border: '#2563eb', tint: 'rgba(37, 99, 235, 0.16)', opacity: '1',    label: 'Signed up'       },
      dead:            { border: '#dc2626', tint: 'rgba(220, 38, 38, 0.08)', opacity: '0.55', label: 'Dead'            },
    };
    const c = STATUS_STYLES[visualStatus] || STATUS_STYLES.new;

    const statusPill = `
      <span style="display:inline-flex; align-items:center; gap:6px;
                   font-size:0.7rem; font-weight:700; letter-spacing:0.04em;
                   text-transform:uppercase; color:${c.border};">
        <span style="display:inline-block; width:8px; height:8px; border-radius:50%; background:${c.border};"></span>
        ${c.label}${overridden ? ' (forced)' : ''}
      </span>`;

    // Inline timestamps on the card so the coach sees both "when did
    // this lead come in" and "when did we last reach out" without
    // opening the modal.
    //
    // Top-right strip owns the lead-age info only:    "in 4d".
    // A separate per-channel touches line under the contact details
    // shows the latest send time for each channel independently so
    // the coach can tell at a glance whether they emailed an hour
    // ago or texted yesterday — see `touchesLine` below.
    const agoShort = (iso) => {
      if (!iso) return '';
      const d = new Date(iso);
      const m = Math.floor((Date.now() - d.getTime()) / 60000);
      if (m < 1)   return 'now';
      if (m < 60)  return `${m}m`;
      const h = Math.floor(m / 60);
      if (h < 24)  return `${h}h`;
      const dys = Math.floor(h / 24);
      if (dys < 30) return `${dys}d`;
      const mo = Math.floor(dys / 30);
      if (mo < 12)  return `${mo}mo`;
      return `${Math.floor(mo / 12)}y`;
    };
    const lastEmailAt = lead.last_email_at || null;
    const lastTextAt  = lead.last_text_at  || null;
    const lastCallAt  = lead.last_call_at  || null;
    const callN       = Number(lead.call_count || 0);

    const inAgo = lead.created_at ? agoShort(lead.created_at) : '';
    const timeStrip = inAgo ? `
      <span style="font-size:0.7rem; opacity:0.6; font-variant-numeric:tabular-nums;">
        in ${inAgo}
      </span>` : '';

    // Unified last-contact badge — computes the single most recent
    // touch across all three channels (email / text / call) and shows
    // its icon, template name, and time-ago in one bold line.  This is
    // the "at-a-glance freshness" indicator the coach uses to decide
    // whether a lead needs another poke.  Template names are shortened
    // for card real-estate ("first-touch" → "touch 1", "more-info" →
    // "info"); the full name lives in the modal history.  A NULL
    // template (legacy pre-072 email rows) renders as "—".
    const TEMPLATE_LABELS = {
      'first-touch': 'touch 1',
      'close':       'close',
      'more-info':   'info',
      'call':        'call',
    };
    const contactChannels = [
      { at: lastEmailAt, tpl: lead.last_email_template, icon: '✉',  channel: 'email' },
      { at: lastTextAt,  tpl: lead.last_text_template,  icon: '💬', channel: 'text'  },
      { at: lastCallAt,  tpl: lead.last_call_template,  icon: '📞', channel: 'call'  },
    ].filter(x => !!x.at);
    let lastContactBadge = '';
    if (contactChannels.length) {
      contactChannels.sort((a, b) => new Date(b.at) - new Date(a.at));
      const top = contactChannels[0];
      const tplLabel = TEMPLATE_LABELS[top.tpl] || (top.tpl || '—');
      lastContactBadge = `
        <div style="font-size:0.82rem; font-weight:700; opacity:0.95;
                    font-variant-numeric:tabular-nums; margin-top:6px;">
          Last: ${top.icon} ${tplLabel} · ${agoShort(top.at)} ago
        </div>`;
    }

    // Per-channel last-touch line.  Renders only when at least one
    // channel has been touched.  Format:
    //   ✉ 1m            (one email)
    //   ✉ 1m (×2)        (multiple emails, time = MAX(sent_at))
    //   💬 4h            (text)
    //   📞 2d            (call)
    //   ✉ 1m · 💬 4h · 📞 2d    (multi-channel)
    // Dimmer than lastContactBadge — the badge is "what happened
    // most recently", this line is "what's happened on each channel".
    const touchParts = [];
    if (emailedN) {
      touchParts.push(
        `✉ ${lastEmailAt ? agoShort(lastEmailAt) : '?'}` +
        (emailedN > 1 ? ` (×${emailedN})` : '')
      );
    }
    if (textedN) {
      touchParts.push(
        `💬 ${lastTextAt ? agoShort(lastTextAt) : '?'}` +
        (textedN > 1 ? ` (×${textedN})` : '')
      );
    }
    if (callN) {
      touchParts.push(
        `📞 ${lastCallAt ? agoShort(lastCallAt) : '?'}` +
        (callN > 1 ? ` (×${callN})` : '')
      );
    }
    const touchesLine = touchParts.length ? `
      <div style="font-size:0.72rem; font-weight:500; opacity:0.7;
                  font-variant-numeric:tabular-nums; margin-top:2px;">
        ${touchParts.join(' · ')}
      </div>` : '';

    // Action buttons — two conceptual rows that wrap freely.
    //
    // Row 1 (primary — Row 1 is where 90% of the daily clicks land):
    //   Email  → touch-1 outreach (data-template="first-touch")
    //   Text   → touch-1 outreach (data-template="first-touch")
    //   Call   → dial + log a call touch (data-template="call")
    //   Save   → vCard to the phone's contacts (data-channel="vcard")
    //   Edit   → open lifecycle modal
    //
    // Row 2 (follow-ups — chips for template × channel combinations):
    //   Close · Email → send close reply via email  (data-template="close")
    //   Close · Text  → send close reply via text
    //   Info · Email  → send more-info via email    (data-template="more-info")
    //   Info · Text   → send more-info via text
    //
    // EVERY contact-btn carries data-channel + data-template so
    // onContactClick can POST /api/leads/:id/contact with the correct
    // (channel, template) pair and update the last-contact badge on
    // the next render.
    const btnStyle = 'flex:1; padding:6px 8px; font-size:0.75rem; font-weight:600; border-radius:6px; border:none; cursor:pointer; text-align:center; text-decoration:none; display:inline-flex; align-items:center; justify-content:center; gap:4px; min-width:76px;';

    const emailBtn = hasEmail ? `
      <a href="${mailHref}" class="contact-btn"
         target="_blank" rel="noopener noreferrer"
         data-lead-id="${lead.id}" data-channel="email" data-template="first-touch"
         style="${btnStyle} background:#3b82f6; color:#fff;">Email</a>` : '';
    const textBtn = hasPhone ? `
      <a href="${smsHref}" class="contact-btn"
         data-lead-id="${lead.id}" data-channel="text" data-template="first-touch"
         style="${btnStyle} background:#16a34a; color:#fff;">Text</a>` : '';
    // Call button — tel: URI fires the native dialer on mobile / OS
    // handler on desktop.  onContactClick's channel='call' branch
    // POSTs a `call` contact row (empty message_body, template='call')
    // then lets the tel: link's default action proceed so the dial
    // actually happens.  data-template="call" so the last-contact
    // badge can render "Last: 📞 call · 1m ago".
    const callBtn = hasPhone ? `
      <a href="${callHref}" class="contact-btn"
         data-lead-id="${lead.id}" data-channel="call" data-template="call"
         title="Dial ${formattedPhone} and log a call touch"
         style="${btnStyle} background:#eab308; color:#111;">Call</a>` : '';
    // Save-to-contacts, on the card itself (owner 2026-08-26: "on leads
    // page i need to be able to click a button and add player to
    // contacts on my android phone but for others apple too"). It
    // existed before, but only inside the Edit modal — two taps and a
    // scroll away from the row you are actually looking at, which is not
    // where you are when a lead is on the phone with you.
    //
    // Youth funnels save a pair (parent card + player placeholder), same
    // isParentFunnel rule the modal uses — the backend's 'youth-pair' kind.
    // Skipped when the lead has neither phone nor email: a vCard with
    // just a name is not worth a row in anyone's address book.
    const isYouthLead = this.isParentFunnel(label);
    const saveBtn = (hasPhone || hasEmail) ? `
      <a href="javascript:void(0)" class="contact-btn"
         data-lead-id="${lead.id}" data-channel="vcard" data-kind="${isYouthLead ? 'youth-pair' : 'self'}"
         title="Add ${(lead.name || 'this lead').replace(/"/g, '&quot;')} to your phone's contacts${isYouthLead ? ' (parent + player placeholder)' : ''}"
         style="${btnStyle} background:#0d9488; color:#fff;">Save${isYouthLead ? ' (2)' : ''}</a>` : '';
    const editBtn = `
      <a href="javascript:void(0)" class="edit-btn"
         data-lead-id="${lead.id}"
         style="${btnStyle} background:var(--bg-tertiary, #374151); color:#fff;">Edit</a>`;

    // Row 2 chips.  Purple = close (locking in a YES reply); teal =
    // more-info (answering a "tell me more" question).  Second word
    // (Email / Text) denotes the channel so the coach can pattern-match
    // at a glance which combination they're firing.  Same button width
    // across the row via flex:1 + min-width, no emoji glyphs (which
    // rendered at inconsistent widths and made the row look ragged).
    const closeMailBtn = hasEmail && closeMailHref ? `
      <a href="${closeMailHref}" class="contact-btn"
         target="_blank" rel="noopener noreferrer"
         data-lead-id="${lead.id}" data-channel="email" data-template="close" data-snippet="close"
         title="Reply to a YES — email w/ register link"
         style="${btnStyle} background:#7c3aed; color:#fff;">Close · Email</a>` : '';
    const closeSmsBtn = hasPhone && closeSmsHref ? `
      <a href="${closeSmsHref}" class="contact-btn"
         data-lead-id="${lead.id}" data-channel="text" data-template="close" data-snippet="close"
         title="Reply to a YES — text w/ register link"
         style="${btnStyle} background:#7c3aed; color:#fff;">Close · Text</a>` : '';
    const moreInfoMailBtn = hasEmail && moreInfoMailHref ? `
      <a href="${moreInfoMailHref}" class="contact-btn"
         target="_blank" rel="noopener noreferrer"
         data-lead-id="${lead.id}" data-channel="email" data-template="more-info" data-snippet="more-info"
         title="Send full program description — email"
         style="${btnStyle} background:#0891b2; color:#fff;">Info · Email</a>` : '';
    const moreInfoSmsBtn = hasPhone && moreInfoSmsHref ? `
      <a href="${moreInfoSmsHref}" class="contact-btn"
         data-lead-id="${lead.id}" data-channel="text" data-template="more-info" data-snippet="more-info"
         title="Send full program description — text"
         style="${btnStyle} background:#0891b2; color:#fff;">Info · Text</a>` : '';

    return `
      <div class="lead-card" data-lead-id="${lead.id}"
           style="background:linear-gradient(90deg, ${c.tint} 0%, var(--bg-secondary) 65%);
                  border-radius:var(--radius-lg); padding:var(--space-3);
                  border-left:6px solid ${c.border}; opacity:${c.opacity};">
        <div style="display:flex; justify-content:space-between; align-items:center; gap:8px; margin-bottom:4px;">
          ${statusPill}
          ${timeStrip}
        </div>
        <div style="font-size:0.95rem; font-weight:600;">${lead.name || '(no name)'}</div>
        ${hasPhone ? `<div style="font-size:0.95rem; opacity:0.92; letter-spacing:0.01em;">${formattedPhone}</div>` : ''}
        ${hasEmail ? `<div style="font-size:0.85rem; opacity:0.85; word-break:break-all;">${lead.email}</div>` : ''}
        ${memberBadge}
        ${programBadge}
        ${lastContactBadge}
        ${touchesLine}
        <div style="display:flex; gap:6px; margin-top:8px; flex-wrap:wrap;">${emailBtn}${textBtn}${callBtn}${saveBtn}${editBtn}</div>
        <div style="display:flex; gap:6px; margin-top:6px; flex-wrap:wrap;">${closeMailBtn}${closeSmsBtn}${moreInfoMailBtn}${moreInfoSmsBtn}</div>
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
  //   • Youth / Men → $1 to register (card capture), then $35/month.
  //     Mid-month signups get a single prorated invoice for the rest of
  //     the current month (calendar-day prorate on $35/mo), then normal
  //     $35 on the first Friday of each following month.
  //   • Women       → LA registration is free (no card-on-file model).
  //     Cost instead is a few $/game for refs (paid at the field) plus a
  //     separate $35 registration with the Women's Tri County Soccer
  //     League on their own site.
  //   See the LA Program Description snippet for the full customer-facing copy.
  //
  // Per-program LeagueApps registration URLs and qualifying questions live in
  // funnelContext() below — single source of truth used by both the initial
  // template and the snippets.

  funnelContext(funnelLabel) {
    // LeagueApps registration URLs ($1 to register; card on file → recurring)
    // come from the DB (leagueapps_programs.registration_url), fetched once
    // in onEnter via window.LighthouseProgramInfo.loadRegisterLinks() and
    // read live here — NOT hardcoded. Hardcoded copies of these URLs (here,
    // in program-info.js, and in the ad scripts) are what let the
    // 'APSL Trials' / 'LIGA 1 Trials' funnels (added 2026-07-04) fall
    // through to a bare, non-working link for real leads (found 2026-08-21).
    const REGISTER_LINKS = window.LighthouseProgramInfo.REGISTER_LINKS;
    const URL_BOYS  = REGISTER_LINKS.boys  || '';
    const URL_GIRLS = REGISTER_LINKS.girls || '';

    // A missing link is never silent. The old `|| bare club URL` fallback
    // degraded into the programme-list page — Membership and Pickup side
    // by side — which is indistinguishable from working right up until a
    // lead registers for the wrong one. loadLeads() now awaits the links
    // before rendering, so reaching this branch means the row is actually
    // absent from leagueapps_programs (or the fetch failed), and that is
    // worth shouting about in the console the coach can check.
    const registerLink = (label) => {
      const key = FUNNEL_CATEGORY[label];
      const url = key ? REGISTER_LINKS[key] : '';
      if (!url) {
        console.error(
          `[leads] No registration URL for funnel "${label}" (category "${key || 'unmapped'}"). ` +
          'Falling back to the club programme list, which offers Pickup alongside Membership — ' +
          'check leagueapps_programs.registration_url for that category.');
        return 'https://lighthouse1893.leagueapps.com';
      }
      return url;
    };

    // Funnel label -> program category. This mapping (which ad funnel sells
    // which club) is stable business logic, unlike the URLs themselves —
    // safe to keep hardcoded. Add a new adult Men funnel here and its
    // registration link resolves automatically from REGISTER_LINKS.
    const FUNNEL_CATEGORY = {
      'Brazil Men':                'mens',
      'PR Men':                    'mens',
      'U23 Men':                   'mens',
      'APSL / Liga 1':             'mens',
      'APSL Trials':               'mens',
      'LIGA 1 Trials':             'mens',
      "Men's Club":                'mens',
      'U23 Women':                 'womens',
      'Tri County Women':          'womens',
      "Women's Club":              'womens',
      'Boys Club (Grades 1–6)':    'boys',
      'Boys Club (K-12)':          'boys',
      'Boys Club (U11/U12)':       'boys',
      'Girls Club (Grades 1–6)':   'girls',
      'Girls Club (K-12)':         'girls',
      'Girls Club (U11/U12)':      'girls',
      'Youth (Grades 1–6)':        'boys',   // legacy combined form
    };
    const PROGRAM_NAMES = {
      'Youth (Grades 1–6)':        'youth soccer program (grades 1–6)',
      'Boys Club (Grades 1–6)':    'Boys Club soccer program (grades 1–6)',
      'Boys Club (K-12)':          'Boys Club soccer program',
      'Boys Club (U11/U12)':       'Boys U11/U12 travel team',
      'Girls Club (Grades 1–6)':   'Girls Club soccer program (grades 1–6)',
      'Girls Club (K-12)':         'Girls Club soccer program',
      'Girls Club (U11/U12)':      'Girls U11/U12 travel team (co-ed for fall 2026 — plays in the boys division)',
      'Brazil Men':                "Brazilian Men's team",
      'PR Men':                    "Puerto Rican Men's team",
      'U23 Men':                   "U23 Men's team",
      "Men's Club":                "Men's Club soccer team",
      'U23 Women':                 "U23 Women's team",
      'Tri County Women':          "Tri County Women's team",
      "Women's Club":              "Women's Club soccer team",
      'APSL / Liga 1':             'APSL / Liga 1 team',
      'APSL Trials':               'APSL / Liga 1 team',
      'LIGA 1 Trials':             'APSL / Liga 1 team',
    };
    // Qualifying question asked in the FIRST message.  Goal: one short answer
    // that lets the coach pick the right follow-up snippet.
    // Per-funnel qualifying question used in the YOUTH initial template.
    // Adult templates don't reference c.question (they ask a single fixed
    // "want to play for our X this season?" — see messageTemplate).
    const QUESTIONS = {
      'Boys Club (Grades 1–6)':    "what's your son's name?",
      'Boys Club (K-12)':          "what's your son's name?",
      'Boys Club (U11/U12)':       "what's your son's name?",
      'Girls Club (Grades 1–6)':   "what's your daughter's name?",
      'Girls Club (K-12)':         "what's your daughter's name?",
      'Girls Club (U11/U12)':      "what's your daughter's name?",
      'Youth (Grades 1–6)':        'is it for a boy or girl?',
    };

    // Per-funnel public schedule URLs.  Used by the Schedule snippet to give
    // leads a concrete answer ("Sundays, full schedule here") instead of a
    // vague "we'll let you know."  Funnels without an entry fall back to the
    // TODO placeholder so the coach knows to fill it in.
    //   day          — short day-of-week phrase ("Sundays", "Sat/Sun")
    //   url          — public schedule page (optional; omit if no public URL)
    //   sourceOf     — label used inline so the lead knows what they're clicking
    //                  ("CASA league page", "season Google Sheet", etc.)
    //   practice     — concrete practice day/time ("Wednesday, Thursday & Friday 7–8:30pm"), optional
    //   practiceNote — extra free-form line printed under Practice: (used for
    //                  Men funnels so the lead knows pickups count as a
    //                  practice if Wed/Thu/Fri don't fit), optional
    const SCHEDULES = {
      'Brazil Men': {
        day:          'Sundays',
        url:          'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9345724',
        sourceOf:     'CASA Philly Grassroots Cup',
        practice:     'Wednesday, Thursday & Friday 7–8:30pm',
        practiceNote: "If those days don't work, you can hit one of our pickups instead — Tuesday 7–8:30pm or Saturday 11am–12:30pm — and it counts as a practice. We do this so it's as easy as possible to make a practice during the week.",
      },
      'PR Men': {
        day:          'Sundays',
        url:          'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9345724',
        sourceOf:     'CASA Philly Grassroots Cup',
        practice:     'Wednesday, Thursday & Friday 7–8:30pm',
        practiceNote: "If those days don't work, you can hit one of our pickups instead — Tuesday 7–8:30pm or Saturday 11am–12:30pm — and it counts as a practice.",
      },
      'U23 Men': {
        day:          'Sundays',
        url:          'https://docs.google.com/spreadsheets/d/e/2PACX-1vRFh_2Do_e8aOsItIW3yohRF70hoxsNJDSnuin99F_9TPBYBsqddMNhNg8GESaSng/pubhtml',
        sourceOf:     'season Google Sheet',
        practice:     'Wednesday, Thursday & Friday 7–8:30pm',
        practiceNote: "If those days don't work, you can hit one of our pickups instead — Tuesday 7–8:30pm or Saturday 11am–12:30pm — and it counts as a practice.",
      },
      'APSL / Liga 1': {
        day:          'Sundays',
        url:          'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9345724',
        sourceOf:     'CASA Philly Grassroots Cup',
        practice:     'Wednesday, Thursday & Friday 7–8:30pm',
        practiceNote: "If those days don't work, you can hit one of our pickups instead — Tuesday 7–8:30pm or Saturday 11am–12:30pm — and it counts as a practice.",
      },
      // APSL Trials / LIGA 1 Trials — separate ad funnels (form ids added
      // 2026-07-04) into the same APSL / Liga 1 team; mirror its config.
      'APSL Trials': {
        day:          'Sundays',
        url:          'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9345724',
        sourceOf:     'CASA Philly Grassroots Cup',
        practice:     'Wednesday, Thursday & Friday 7–8:30pm',
        practiceNote: "If those days don't work, you can hit one of our pickups instead — Tuesday 7–8:30pm or Saturday 11am–12:30pm — and it counts as a practice.",
      },
      'LIGA 1 Trials': {
        day:          'Sundays',
        url:          'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9345724',
        sourceOf:     'CASA Philly Grassroots Cup',
        practice:     'Wednesday, Thursday & Friday 7–8:30pm',
        practiceNote: "If those days don't work, you can hit one of our pickups instead — Tuesday 7–8:30pm or Saturday 11am–12:30pm — and it counts as a practice.",
      },
      // Youth / Boys / Girls — no public schedule page yet; verbal summary
      // only.  Games on Sunday mornings to early afternoon + practice Mon/Wed.
      'Boys Club (Grades 1–6)': {
        day:      'Sunday mornings to early afternoon',
        practice: 'Mondays & Wednesdays — by grade in the upcoming school year: 2nd grade and younger 4:30–5:30pm, 3rd grade and older 5:30–7pm.',
      },
      'Boys Club (K-12)': {
        day:      'Sunday mornings to early afternoon',
        practice: 'Mondays & Wednesdays — by grade in the upcoming school year: 2nd grade and younger 4:30–5:30pm, 3rd grade and older 5:30–7pm.',
      },
      'Girls Club (Grades 1–6)': {
        day:      'Sunday mornings to early afternoon',
        practice: 'Mondays & Wednesdays — by grade in the upcoming school year: 2nd grade and younger 4:30–5:30pm, 3rd grade and older 5:30–7pm.',
      },
      'Girls Club (K-12)': {
        day:      'Sunday mornings to early afternoon',
        practice: 'Mondays & Wednesdays — by grade in the upcoming school year: 2nd grade and younger 4:30–5:30pm, 3rd grade and older 5:30–7pm.',
      },
      'Boys Club (U11/U12)': {
        day:      'Sunday mornings to early afternoon',
        practice: 'Mondays & Wednesdays 5:30–7pm (5th & 6th graders).',
      },
      'Girls Club (U11/U12)': {
        day:      'Sunday mornings to early afternoon',
        practice: 'Mondays & Wednesdays 5:30–7pm (5th & 6th graders).',
      },
      'Youth (Grades 1–6)': {
        day:      'Sunday mornings to early afternoon',
        practice: 'Mondays & Wednesdays — by grade in the upcoming school year: 2nd grade and younger 4:30–5:30pm, 3rd grade and older 5:30–7pm.',
      },
      'Tri County Women': {
        day: 'Sundays, late morning to early afternoon',
      },
      // U23 Women — funnel not live yet (no ads running). When launched
      // it'll mirror U23 Men (Sundays + CASA-equivalent women's league).
      // Until then, Schedule chip stays as TODO so the ⚠ reminds the coach to
      // wire it before the first real lead lands.
    };

    // Per-funnel public handbook URLs.  Currently only the Men's
    // handbook exists (covers all adult Men funnels — Brazil, PR, U23,
    // APSL, Men's Club).  Surfaced in the adult Welcome + More info
    // snippets so new members can dig in on logistics without pinging
    // the coach.  Add 'Women's Club' / etc. here when those handbooks
    // are ready.
    const MENS_HANDBOOK = 'https://docs.google.com/document/d/1xjekFzKZeYGnFL-QIy9YzII8trd50Nrz-tn1D-HQH_c/edit?usp=sharing';
    const HANDBOOKS = {
      'Brazil Men':    MENS_HANDBOOK,
      'PR Men':        MENS_HANDBOOK,
      'U23 Men':       MENS_HANDBOOK,
      'APSL / Liga 1': MENS_HANDBOOK,
      'APSL Trials':   MENS_HANDBOOK,
      'LIGA 1 Trials': MENS_HANDBOOK,
      "Men's Club":    MENS_HANDBOOK,
    };

    // External team-roster registration URLs.  Separate from LINKS
    // (LeagueApps club membership) — these are league-side roster
    // forms required to play sanctioned games.  Currently CASA Philly
    // Grassroots Cup uses one SportsEngine form for all its teams.
    // PR Men + Brazil Men share that form; if APSL / Liga 1 or U23 Men
    // need it later, add them here.  Surfaced in the adult Welcome
    // blurb so new members register once they're locked into the team.
    const CASA_ROSTER_URL = 'https://casasoccerleagues.sportngin.com/register/form/824938975';
    const ROSTER_LINKS = {
      'PR Men':     CASA_ROSTER_URL,
      'Brazil Men': CASA_ROSTER_URL,
    };
    // The CASA / Grassroots Cup form asks the player to pick their
    // country (Puerto Rico vs Brazil) — that's how it routes to the
    // right team.  Spell out the answer per funnel so the player
    // doesn't pick the wrong one.
    const ROSTER_TEAM_NAME = {
      'PR Men':     'Puerto Rico',
      'Brazil Men': 'Brazil',
    };

    // Some leagues don't give us a sharable registration URL — instead
    // they email each player directly with a player-specific link
    // (Squadi for U23 Men's USASA league is the canonical case).  For
    // those funnels we surface the *instruction* ("watch your inbox")
    // as a numbered Welcome step instead of a link.  rosterNote and
    // rosterLink are mutually exclusive at the funnel level — the
    // Welcome builder picks whichever exists.
    const ROSTER_NOTES = {
      'U23 Men': 'Watch your inbox for an email from Squadi — that\'s our league\'s registration platform. Open it and complete the player registration so you\'re eligible for league games.',
    };

    const isYouth = /youth|grades?\s*1[–-]6|boys\s*club|girls\s*club/i.test(funnelLabel || '');
    const isWomensClub = /women/i.test(funnelLabel || '');
    // Legacy combined youth funnel — the only funnel where the form
    // doesn't pre-identify gender, so the close branches on the lead's
    // boy/girl answer (see Register chip split in messageSnippets).
    const isLegacyYouth = funnelLabel === 'Youth (Grades 1–6)';
    // 'U23 Men + PR' is a combined funnel for players who are on both
    // U23 Men's (USASA / Squadi) AND PR Men (CASA / SportsEngine).
    // Reuse U23 Men's base lookups (chats, schedule, handbook, etc.)
    // but layer on the CASA roster link with PR as the country pick so
    // the Welcome lists BOTH registrations.
    const isCombinedU23PR = funnelLabel === 'U23 Men + PR';
    const baseLabel = isCombinedU23PR ? 'U23 Men' : funnelLabel;
    // Branded club name keyed off the lead's source funnel — single
    // source of truth used as the touch-1 email subject AND inside the
    // Touch-2 "That's great that you want to play for ${clubTitle}!"
    // opener. So a Boys Club lead sees "Lighthouse Boys Soccer Club
    // 1893", a Women's lead sees "Lighthouse Women's Soccer Club
    // 1893", the legacy combined youth funnel (no pre-identified
    // gender) sees "Lighthouse Boys & Girls Soccer Club 1893", and
    // adult-men funnels (PR / Brazil / U23) see "Lighthouse Men's
    // Soccer Club 1893". Checks ordered most-specific → most-general.
    const fl = funnelLabel || '';
    const clubTitle =
        isLegacyYouth         ? 'Lighthouse Boys & Girls Soccer Club 1893'
      : isWomensClub          ? "Lighthouse Women's Soccer Club 1893"
      : /girls/i.test(fl)     ? 'Lighthouse Girls Soccer Club 1893'
      : /boys/i.test(fl)      ? 'Lighthouse Boys Soccer Club 1893'
      : /\bmen\b/i.test(fl)   ? "Lighthouse Men's Soccer Club 1893"
      : isYouth               ? 'Lighthouse Boys & Girls Soccer Club 1893'
      :                         'Lighthouse Soccer Club 1893';
    // Touch-2 opener phrasing.  Youth flips subject to parent-of ("your
    // son / daughter / child wants to play soccer for …") AND swaps the
    // per-gender club name for the combined "Boys & Girls" branding, so
    // a parent who picked the Boys funnel still sees the club as one
    // co-ed program.  Adults keep the first-person "you want to play
    // soccer for {gendered clubTitle}" (Men's / Women's / fallback).
    const isBoysYouth  = isYouth && !isLegacyYouth && /boys/i.test(fl);
    const isGirlsYouth = isYouth && !isLegacyYouth && /girls/i.test(fl);
    const openerLine =
        isBoysYouth    ? 'your son wants to play soccer for Lighthouse Boys & Girls Soccer Club 1893'
      : isGirlsYouth   ? 'your daughter wants to play soccer for Lighthouse Boys & Girls Soccer Club 1893'
      : isLegacyYouth  ? 'your child wants to play soccer for Lighthouse Boys & Girls Soccer Club 1893'
      :                  `you want to play soccer for ${clubTitle}`;
    // Close-context opener — tighter than openerLine, used by the
    // `close` snippet (response to a YES reply on touch-1's "want to
    // play?" question).  Deliberately drops the full club title and
    // stays under ~10 words so the SMS variant fits in a single
    // segment, and the email variant reads as a one-line congratulation
    // + register CTA rather than an info dump.  Women's Club gets "with"
    // instead of "for" — it's a co-ed-friendly community team, not a
    // competitive travel squad, and the "with" phrasing matches how
    // the coach speaks about it verbally.
    const closerLine =
        isBoysYouth    ? 'glad your son wants to play for Lighthouse'
      : isGirlsYouth   ? 'glad your daughter wants to play for Lighthouse'
      : isLegacyYouth  ? 'glad your player wants to play for Lighthouse'
      : isWomensClub   ? 'glad you want to play with Lighthouse'
      :                  'glad you want to play for Lighthouse';
    return {
      program:       PROGRAM_NAMES[baseLabel] || 'program',
      link:          registerLink(baseLabel),
      linkBoys:      URL_BOYS,
      linkGirls:     URL_GIRLS,
      handbookLink:  HANDBOOKS[baseLabel] || null,
      rosterLink:    isCombinedU23PR ? CASA_ROSTER_URL : (ROSTER_LINKS[baseLabel] || null),
      rosterNote:    ROSTER_NOTES[baseLabel] || null,
      rosterTeam:    isCombinedU23PR ? 'Puerto Rico' : (ROSTER_TEAM_NAME[baseLabel] || null),
      question:      QUESTIONS[baseLabel] || 'tell me a bit about your soccer background?',
      schedule:      SCHEDULES[baseLabel] || null,
      whose:         isYouth ? "your player's" : 'your',
      whoseCap:      isYouth ? "Your player's" : 'Your',
      // Women's Club: LA registration itself is free; cost comes from
      // per-game ref fees plus a separate league registration — no card-
      // on-file / auto-charge model applies (see program-info.js).
      initialFee:    isWomensClub ? 'Free' : '$1',
      pricing:       isWomensClub ? 'a few $/game for refs; $35 separately on the league site' : '$35/month',
      isYouth,
      isLegacyYouth,
      isWomensClub,
      clubTitle,
      openerLine,
      closerLine,
    };
  }

  // ── Practice date helpers ─────────────────────────────────────────
  // Shared by every lead-facing surface that needs to surface a fresh
  // "next practice" date — first-touch lead emails (messageTemplate)
  // and roster broadcasts (messageSnippets).  Living on the class
  // means the cancellation skip-list and override schedule have a
  // single source of truth; otherwise an added cancellation would
  // silently disagree between the lead email and the broadcast.

  _practiceCancellations() {
    // One-off skips (club events, holidays, weather).  YYYY-MM-DD.
    // If this grows past ~5 entries, promote to a config endpoint so
    // the coach can edit without a deploy.
    return new Set([
      '2026-06-29', // Mon — club event at Lighthouse (youth)
    ]);
  }

  _practiceOverride(ymd) {
    // One-off time overrides for practices that still happen but at a
    // different time than the usual cadence (e.g. shifted earlier so
    // the team can watch a big game after).
    //   time — replaces the default time on the "Next:" line
    //   note — appears in parens after the time; phrase the reason
    //          the way you'd say it out loud ("earlier so we can catch
    //          the USA World Cup game after — regular time is 7pm–8:30pm").
    //          "Why we moved practice" is a community-identity signal,
    //          not a logistics footnote — surface it.
    const overrides = new Map([
      ['2026-07-01', {
        time: '5:30pm–7pm',
        note: 'earlier so we can catch the USA World Cup game after — regular time is 7pm–8:30pm',
      }],
    ]);
    return overrides.get(ymd) || null;
  }

  _nextPractice(cadenceDays, endHour) {
    // Compute next practice for a given cadence so every render shows
    // a fresh date — never stale, no manual updates.
    //   cadenceDays — array of weekday numbers (0=Sun … 6=Sat)
    //   endHour     — hour after which today no longer counts as "next"
    //                 (19 for youth's 7pm end; 21 for men's 8:30pm end
    //                 with a half-hour buffer so 8:15pm reads still on).
    // If today is in the cadence, before endHour, and not cancelled,
    // today counts ("join us tonight").  Otherwise advance day-by-day,
    // skipping cancellations.  Returns { ymd, label } so callers can
    // look up _practiceOverride(ymd) while rendering the human label.
    const ymd = (x) => {
      const y  = x.getFullYear();
      const m  = String(x.getMonth() + 1).padStart(2, '0');
      const dd = String(x.getDate()).padStart(2, '0');
      return `${y}-${m}-${dd}`;
    };
    const cancellations = this._practiceCancellations();
    const now = new Date();
    const stillToday =
      cadenceDays.includes(now.getDay()) &&
      now.getHours() < endHour &&
      !cancellations.has(ymd(now));
    const d = new Date(now);
    if (!stillToday) {
      do {
        d.setDate(d.getDate() + 1);
      } while (!cadenceDays.includes(d.getDay()) || cancellations.has(ymd(d)));
    }
    return {
      ymd:   ymd(d),
      label: d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' }),
    };
  }

  _nextKickoff() {
    // Women's league kickoff = Sunday after Labor Day = first Sunday
    // on or after Sept 8.  Computed from current year so the email
    // stays fresh year-over-year without a code change.  If we're
    // already past this year's kickoff, shows next year's date.
    const forYear = (y) => {
      const sept1 = new Date(y, 8, 1);
      const daysToMonday = (1 - sept1.getDay() + 7) % 7;  // Labor Day = first Mon of Sept
      return new Date(y, 8, 1 + daysToMonday + 6);        // Sunday after Labor Day
    };
    const now = new Date();
    let k = forYear(now.getFullYear());
    if (k < now) k = forYear(now.getFullYear() + 1);
    return k.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' });
  }

  // Convert ASCII letters/digits to Unicode mathematical sans-serif bold
  // codepoints (U+1D5D4..U+1D7FF).  These are REAL Unicode characters,
  // not styling — they render as visually bold in every modern email
  // client (Gmail web, Gmail mobile, Apple Mail, iOS Mail, Outlook 2019+,
  // Thunderbird) without needing any HTML.  Crucially, they survive the
  // Gmail compose `?body=` URL pre-fill round-trip, so the lead sees
  // bold section labels even when the coach skips the Ctrl+A/Ctrl+V
  // paste of the rich-HTML clipboard payload.
  //
  // Accessibility caveat: screen readers announce these char-by-char
  // ("mathematical sans-serif bold P, r, a, c, t, i, c, e"), so we use
  // them ONLY on short structural labels (Practice / Where / Next /
  // Games / Cost / Season), NEVER on body content.  Sighted recipients
  // get visual hierarchy; screen-reader users still hear the words
  // (just spelled out), which is acceptable for a 6-character label.
  _boldText(s) {
    const OFFSET_UPPER = 0x1D5D4 - 0x41;   // A → 𝗔
    const OFFSET_LOWER = 0x1D5EE - 0x61;   // a → 𝗮
    const OFFSET_DIGIT = 0x1D7EC - 0x30;   // 0 → 𝟬
    return String(s).replace(/[A-Za-z0-9]/g, (ch) => {
      const code = ch.charCodeAt(0);
      if (code >= 0x41 && code <= 0x5A) return String.fromCodePoint(code + OFFSET_UPPER);
      if (code >= 0x61 && code <= 0x7A) return String.fromCodePoint(code + OFFSET_LOWER);
      if (code >= 0x30 && code <= 0x39) return String.fromCodePoint(code + OFFSET_DIGIT);
      return ch;
    });
  }

  // Bold the labeled-block section headers in a first-touch email body
  // so the plain-text version has clear visual hierarchy.  Matches at
  // line starts only (^ or after \n) so mid-sentence em-dashes
  // ("We're in season — new players welcome") aren't accidentally bolded.
  // Allowlist of labels keeps the transformation predictable as new
  // copy lands.  Applied at template-build time (before fillTemplate
  // substitutes {first}/{coach} tokens) so dynamic text never gets
  // bolded by accident.
  _proBold(text) {
    const bold = (s) => this._boldText(s);
    return String(text)
      .replace(/(^|\n)(Practice|Where|Games|Cost|Season|Subject) — /g,
               (_, pfx, lbl) => `${pfx}${bold(lbl)} — `)
      .replace(/(^|\n)Next: /g, (_, pfx) => `${pfx}${bold('Next:')} `);
  }

  messageTemplate(funnelLabel) {
    const c = this.funnelContext(funnelLabel);

    // ─────────────────────────────────────────────────────────────────
    // TOUCH-1 INTRO — first contact for every Meta lead (all 5 funnels).
    // ─────────────────────────────────────────────────────────────────
    //
    // Soft open, no ask.  No LeagueApps link.  No price.  No logistics.
    // Goal: get a "yes" reply (or a real question) so the conversation
    // moves forward.  The subject ("Confirming your interest...") sets a
    // yes/no frame BEFORE the lead opens the email, which pushes reply
    // rate roughly 2-3x over open-ended "what can I help with?" first
    // touches in cold Meta-lead funnels.
    //
    // Why ONE body for all 5 funnels (Legacy Youth / Boys / Girls /
    // Men / Women):
    //   • `${c.program}` (from funnelContext) is the only funnel-specific
    //     noun — "Boys Club soccer program", "Brazilian Men's team", etc.
    //     Funnels without an entry fall back to the literal word
    //     "program" — slightly awkward but not worse than the previous
    //     behaviour and easy to fix by adding to PROGRAM_NAMES.
    //   • The conversion ask (price, LeagueApps link, labeled Practice /
    //     Games / Cost blocks) is DELIBERATELY moved to touch 2/3 once
    //     the multi-touch sequence ships (migration 072 plus the
    //     LeadContact.template column already drafted on this branch).
    //     The old per-funnel labeled-block templates live in git
    //     history (see commit before this one) and will be revived as
    //     the touch-3 content when we wire the sequence.
    //   • Adult vs youth tone differences are tiny — both audiences
    //     respond to a calm, professional first touch from the Soccer
    //     Director.  Branching the copy adds maintenance cost for
    //     marginal lift.
    //
    // Why `{coachFirst}` instead of `{coach}`:
    //   `{coach}` renders as "Coach Mike" via fillTemplate, which reads
    //   redundant next to the "Soccer Director" title ("Coach Mike,
    //   Soccer Director at Lighthouse 1893 SC").  `{coachFirst}` drops
    //   the prefix so the title carries the authority cleanly.
    //
    // SMS vs email parity:
    //   Same content, different channel — coach typically sends SMS
    //   first, then email the same day.  No links in either body, so
    //   SMS doesn't pull the lead out of the conversation thread.
    //
    // No _proBold() wrapper here:
    //   _proBold() only bolds labelled-block headers (Practice / Where /
    //   Games / Cost / Season / Next:).  The touch-1 intro has none of
    //   those, so the wrapper would be a no-op.  Skipping it also
    //   signals to future maintainers that this is a plain-prose body.
    // Club-title shown in the touch-1 subject line.  Branded by audience
    // Club name comes from funnelContext (single source of truth shared
    // with messageSnippets so the Touch-2 "That's great that you want
    // to play for ${clubTitle}!" opener stays in lock-step with the
    // touch-1 subject line). See funnelContext.clubTitle for the per-
    // funnel mapping (Boys / Girls / Women's / Men's / Legacy Youth).
    const clubTitle = c.clubTitle;

    return {
      sms:
        `Hi {first}, {coachFirst} here — Soccer Director at ` +
        `Lighthouse 1893. Are you looking to join our ${c.program} ` +
        `this season?`,
      subject: clubTitle,
      email:
        `Hi {first},\n\n` +
        `{coachFirst} here, Soccer Director at Lighthouse 1893.\n\n` +
        `Are you looking to join our ${c.program} this season?\n\n` +
        `Thanks,\n{coachFirst}\nSoccer Director\nLighthouse 1893 SC\n` +
        `soccer@lighthouse1893.org`,
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

    // ── LeagueApps Program Description ────────────────────────────────
    // Canonical copy for the LA program-listing "Description" field, built
    // by window.LighthouseProgramInfo.buildProgramDescription() (see
    // frontend/js/lib/program-info.js) — the single source of truth for
    // this copy, also used by the public program-info pages linked from
    // flyer QR codes.  Edit the copy there, not here.
    //
    // Hoisted to the outer function scope (via `let laDescText`) so the
    // ℹ️ More info follow-up snippet below can reuse the exact same
    // policy copy — one source of truth for the club's program
    // description / details across both the LA program page and the
    // more-info email reply.
    let laDescText;
    {
      const { html: laDescHtml, text: descText, feeShort } = window.LighthouseProgramInfo.buildProgramDescription({
        isYouth: c.isYouth,
        isWomensClub: c.isWomensClub,
        isMensClub: funnelLabel === "Men's Club",
      });
      laDescText = descText;
      snippets.push({
        id: 'la-program-description',
        label: `📋 LA Program Description (${feeShort})`,
        tier: 'program',
        subject: 'Program Description',
        html: laDescHtml,
        body: laDescText,
      });
    }

    // ── Broadcasts (LA Messages — paste into LeagueApps Messages to
    // blast the entire roster).  Currently: Spring → Summer/Fall
    // re-registration heads-up for Boys / Girls Club families.  Lives
    // here so the Messages page surfaces it on the youth funnels.
    // U11/U12 funnels are brand-new — no Spring roster to re-register
    // — so they're skipped.
    const isU1112 = /u11\s*\/?\s*u12/i.test(funnelLabel);
    const springRenewalBody = (clubName, childRel, link) => this._proBold(
      `Hi Lighthouse 1893 ${clubName} families,\n\n` +
      `Quick heads-up: the Summer/Fall 2026 season is a NEW registration — it does NOT auto-renew from the Spring season. To hold your ${childRel}'s spot on the roster, please register again:\n` +
      `${link}\n\n` +
      `Practice — Mondays & Wednesdays (next: ${this._nextPractice([1, 3], 19).label})\n` +
      `Where — Lighthouse Sports Complex\n` +
      `199 East Erie Avenue, Philadelphia PA 19140\n` +
      `• 2nd grade and younger: 4:30pm–5:30pm\n` +
      `• 3rd grade and older: 5:30pm–7pm\n\n` +
      `Games — Sunday mornings to early afternoon\n\n` +
      `Cost — $1 to register, then $35/month\n` +
      `Uniforms, tournaments, and gear all included — no hidden fees.\n\n` +
      `Hit reply with any questions — happy to help.\n\n` +
      `Thanks,\nLighthouse 1893 SC\nsoccer@lighthouse1893.org`
    );
    if (c.isLegacyYouth) {
      snippets.push({
        id: 'spring-renewal-boys',
        label: '📣 Spring → re-register (Boys)',
        tier: 'broadcast',
        subject: 'Lighthouse 1893 Boys Club — re-register for Summer/Fall (new registration)',
        body: springRenewalBody('Boys Club', 'son', c.linkBoys),
      });
      snippets.push({
        id: 'spring-renewal-girls',
        label: '📣 Spring → re-register (Girls)',
        tier: 'broadcast',
        subject: 'Lighthouse 1893 Girls Club — re-register for Summer/Fall (new registration)',
        body: springRenewalBody('Girls Club', 'daughter', c.linkGirls),
      });
    } else if (c.isYouth && !isU1112) {
      const isGirls   = /girls/i.test(funnelLabel);
      const clubName  = isGirls ? 'Girls Club' : 'Boys Club';
      const childRel  = isGirls ? 'daughter'   : 'son';
      snippets.push({
        id: 'spring-renewal',
        label: `📣 Spring → re-register (${clubName})`,
        tier: 'broadcast',
        subject: `Lighthouse 1893 ${clubName} — re-register for Summer/Fall (new registration)`,
        body: springRenewalBody(clubName, childRel, c.link),
      });
    }

    // ── Broadcast: Alumni return (Men's Club only) — short SMS-length
    // outreach to last-season players who haven't re-registered.
    // Paired with `alumni-return-followup` below, which the coach
    // sends after an "in" reply (includes the LeagueApps link + the
    // U.S. Soccer / FIFA name-and-DOB ask needed to file clearance).
    //
    // Copy is DELIBERATELY plain-text (no _proBold / _boldText) —
    // this snippet is designed for SMS/WhatsApp/iMessage where
    // Unicode-math bold renders as boxed characters on old Android
    // and where screen readers spell math-bold char-by-char (see
    // accessibility caveat on _boldText).  Emphasis is carried by
    // quoted keywords ("in" / "out" / "explanation") and by the
    // three-beat expectation list.
    //
    // Response frame is intentionally three-way (yes / no /
    // explanation) rather than binary — captures the guys who'd
    // default to "out" only because their situation (injury, work
    // travel, moving, kit fee friction) doesn't fit a clean yes.
    // "We want you back" as the reason for the flexibility flips
    // the third option from concession to invitation.
    if (funnelLabel === "Men's Club") {
      snippets.push({
        id: 'alumni-return-sms',
        label: '📣 Alumni',
        tier: 'alumni',
        body:
          `Hey {first} — James at Lighthouse 1893. ` +
          `Pre-season is on and I want you back for APSL, U.S. Open Cup, and Amateur Cup. ` +
          `The expectation is simple: this week, 1st team players are signed, preparing for the season, and at practice. ` +
          `Reply "in" for the link. ` +
          `Reply "out" if this year isn't yours. ` +
          `Or reply with an explanation if it's complicated (injury, work, life) — we'll figure it out because we want you back. ` +
          `I need a response either way. ` +
          `Yes, no, or explanation?`,
      });
      snippets.push({
        id: 'alumni-return-followup',
        label: '✅ Alumni — send link',
        tier: 'alumni',
        body:
          `Hey {first} — welcome back. Here's the registration:\n\n` +
          `→ ${c.link}\n\n` +
          `$1 today. LeagueApps will send a single prorated invoice for the rest of July (~$1.13/day). Regular $35/month starts Fri Aug 7 — no per-season/per-tournament/kit/indoor fees. Pause or cancel anytime.\n\n` +
          `Once you're registered, reply with your full legal name (as on passport / ID) and your date of birth — I need those to file your U.S. Soccer / FIFA clearance. If you've ever been registered with a soccer federation outside the U.S., also tell me which country and which club so I can add the FIFA international clearance (ITC) to the filing.\n\n` +
          `— James Breslin\nSoccer Director, Lighthouse 1893 SC`,
      });
    }

    // ── Broadcast: Practice schedule — sent to CURRENTLY REGISTERED
    // players (no registration ask, just logistics).  Explains the
    // grade-based practice slots and first-practice date.  Surfaces on
    // every youth funnel so the coach can paste into LA Messages once
    // per club.
    const practiceScheduleBody = (clubName) => this._proBold(
      `Hi Lighthouse 1893 ${clubName} families,\n\n` +
      `Thanks for registering for the Summer/Fall 2026 season! Quick heads-up on the practice schedule so you can plan your week.\n\n` +
      `Practice — Mondays & Wednesdays (next: ${this._nextPractice([1, 3], 19).label})\n` +
      `Where — Lighthouse Sports Complex\n` +
      `199 East Erie Avenue, Philadelphia PA 19140\n` +
      `• 2nd grade and younger: 4:30pm–5:30pm\n` +
      `• 3rd grade and older: 5:30pm–7pm\n\n` +
      `Games — Sunday mornings to early afternoon\n\n` +
      `Bring water and shin guards. Uniforms will be handed out at the field.\n\n` +
      `Hit reply with any questions — see you on the field!\n\n` +
      `Thanks,\nLighthouse 1893 SC\nsoccer@lighthouse1893.org`
    );
    if (c.isLegacyYouth) {
      snippets.push({
        id: 'practice-schedule-boys',
        label: '📣 Practice schedule (Boys — registered)',
        tier: 'broadcast',
        subject: 'Lighthouse 1893 Boys Club — Summer/Fall practice schedule',
        body: practiceScheduleBody('Boys Club'),
      });
      snippets.push({
        id: 'practice-schedule-girls',
        label: '📣 Practice schedule (Girls — registered)',
        tier: 'broadcast',
        subject: 'Lighthouse 1893 Girls Club — Summer/Fall practice schedule',
        body: practiceScheduleBody('Girls Club'),
      });
    } else if (c.isYouth && !isU1112) {
      const clubName2 = /girls/i.test(funnelLabel) ? 'Girls Club' : 'Boys Club';
      snippets.push({
        id: 'practice-schedule',
        label: `📣 Practice schedule (${clubName2} — registered)`,
        tier: 'broadcast',
        subject: `Lighthouse 1893 ${clubName2} — Summer/Fall practice schedule`,
        body: practiceScheduleBody(clubName2),
      });
    }

    // ── Broadcast: Men's Club — "set your availability at footballhome.org"
    // Audience: CURRENT mens registrations (active + behind-on-payment).
    // Do NOT mention dues, pause tier, or the free pickup registration —
    // pickup-only members get a separate message via the pickup chat.
    // "Set availability" wording is deliberate: some guys don't know
    // "RSVP" as a verb, and "set availability" reads unambiguously on a
    // phone.  Surfaces on the Men's Club and APSL / Liga 1 funnels so
    // the coach can paste it into LA Messages once per program.
    const MENS_BROADCAST_FUNNELS = new Set(["Men's Club", 'APSL / Liga 1']);
    if (MENS_BROADCAST_FUNNELS.has(funnelLabel)) {
      const availabilityBody =
        `Hi guys,\n\n` +
        `We track availability for games, practice and pickup on footballhome.org — which works on your phone or computer, and also installs as an app on your phone.\n\n` +
        `How to get in:\n` +
        `1. Open https://footballhome.org on your phone or computer\n` +
        `2. On your phone? Tap Share → Add to Home Screen (iOS) or Install app (Android) so it lives on your home screen like a real app.\n` +
        `3. Tap Sign In\n` +
        `4. Tap "Continue with Google" — use the same email you're registered with on LeagueApps\n\n` +
        `No Google account? No problem:\n` +
        `• Tap "Sign in with email & password"\n` +
        `• Tap "Forgot / set password"\n` +
        `• Enter your LeagueApps email — we'll send you a link to set a password. Set it, then sign in.\n\n` +
        `Once you're in, you'll see your week under My Schedule. For every game / practice / pickup, just tap:\n` +
        `• Going\n` +
        `• Can't go\n\n` +
        `You must set availability for EVERY event on your weekly schedule. Not sure? Tap Can't go — you can always change it later if plans free up.\n\n` +
        `Please sign in and set your availability for this week. There's also a button to set your **recurring** availability — everyone should commit to 2 recurring practice/pickups if you can. Then you only need to change it the week of if you CANNOT make it.\n\n` +
        `Only use recurring if your schedule actually allows it — we don't want no-shows. If your week is unpredictable, just set availability week-by-week.\n\n` +
        `Going forward we'll be fining no-shows AND anyone who shows up without setting their availability — it hurts the teams and the club when we can't plan.\n\n` +
        `Any questions, DM me — let's keep the chat clear so everyone can see this message.\n\n` +
        `Thanks,\nLighthouse 1893 SC\nsoccer@lighthouse1893.org`;
      snippets.push({
        id: 'fh-set-availability',
        label: "📣 Set availability at footballhome.org (Men's Club)",
        tier: 'broadcast',
        subject: 'Lighthouse 1893 — set your availability at footballhome.org',
        body: this._proBold(availabilityBody),
      });
    }

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
        label: `💳 Register (${c.initialFee})`,
        tier: 'close',
        body: c.isWomensClub
          ? (
            `Great. Registering with Lighthouse is free — register here: ${c.link}\n` +
            `Once you're in you can start coming to trainings and games. Games run a few $ per player for refs, and you'll separately register with the Women's Tri County Soccer League for $35.`
          )
          : (
            `Great. To become a member of the club it's ${c.initialFee} registration on this link: ${c.link}\n` +
            `Once you're in you can start coming to trainings and games.`
          ),
      });
    }

    // Welcome — sent AFTER the lead registers.  Two flavors:
    //
    //   • Adult funnels  → short "you're in, reply anytime" note plus
    //                      any league-team roster registration steps
    //                      (CASA for PR/Brazil Men, etc.).  We DO NOT
    //                      hand out chat/join links — practice, pickup,
    //                      and game details flow through the coach's
    //                      own text/email replies, and match RSVPs go
    //                      through the FH magic-link the coach sends.
    //
    //   • Youth funnels  → there's no parent/player chat yet, so the
    //                      blurb sets expectations: practice & game
    //                      schedule will arrive by email, field address,
    //                      reply with any questions.
    if (c.isYouth) {
      const practiceLine = c.schedule?.practice
        ? `Practice is ${c.schedule.practice}.`
        : `We'll confirm practice days as soon as the schedule's locked in.`;
      // Games for youth: Sunday mornings to early afternoon.  Do NOT pull
      // from c.schedule.day; that field is set per-funnel in SCHEDULES and
      // historically said "Saturdays", which over-promised the wrong day.
      const gameLine = `Games are on Sunday mornings to early afternoon.`;
      // Numbered steps so the parent can refer back ("did you read step
      // 3?") and so it visually mirrors the adult Welcome layout.
      const lines = [
        `🎉 ${c.whoseCap} officially a member of the club. Next steps to play in games and attend practices:`,
        ``,
        `1. 📬 Practice & game schedule emails will go out before the season starts — keep an eye on this inbox.`,
        `2. 🏃 ${practiceLine}`,
        `3. ⚽ ${gameLine}`,
        `4. 📍 Field address (practices and games):`,
        `   Lighthouse Sports Complex — 199 E Erie Ave, Philadelphia PA 19140`,
        `   https://maps.google.com/?q=Lighthouse+Sport+Complex+Field`,
        ``,
        `Reply to this email with any questions — happy to help.`,
      ];
      snippets.push({
        id: 'welcome',
        label: '🎉 Welcome (Youth)',
        tier: 'close',
        subject: 'Welcome to Lighthouse 1893 SC! Next steps',
        body: lines.join('\n'),
      });
    } else {
      // Adult: short welcome + league roster steps only.  No chat links —
      // practice/pickup/game logistics come from the coach's own texts and
      // emails; match RSVPs go through the FH magic-link the coach sends.
      const stepLines = [];
      let n = 1;
      if (c.rosterLink) {
        stepLines.push(`${n++}. 📝 League team roster — required to play sanctioned games:`);
        stepLines.push(`   ${c.rosterLink}`);
        if (c.rosterTeam) {
          stepLines.push(`   ⚠️ When the form asks for your country, choose **${c.rosterTeam}**.`);
          stepLines.push(`   (You're not locked into just ${c.rosterTeam} games — we run friendlies every weekend, and you're welcome in any of them.)`);
        }
      }
      if (c.rosterNote) {
        stepLines.push(`${n++}. 📬 League registration — ${c.rosterNote}`);
      }

      const lines = [`🎉 You're officially a member of the club.`, ``];
      if (stepLines.length) {
        lines.push(...stepLines, ``);
      }
      lines.push(`Reply anytime and I'll send you the next practice, pickup, and match details — including the RSVP link for each match.`, ``, `See you on the field. 🤝`);

      snippets.push({
        id: 'welcome',
        label: '🎉 Welcome',
        tier: 'close',
        subject: 'Welcome to Lighthouse 1893 SC! Next steps',
        body: lines.join('\n'),
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
      // if the calendar has one, otherwise fall back to a generic invite.
      // this._nextPickup is loaded by loadLeads().  No join URL — the coach
      // texts/emails logistics directly; if the lead replies "in" we know
      // to expect them.
      const next = this._nextPickup;
      let pickupBody;
      if (next && next.start_at) {
        const when  = this.formatPickupDate(next.start_at);
        const loc   = (next.location || next.location_address || '').trim();
        const title = (next.title || '').trim();
        const where = loc ? ` @ ${loc}` : '';
        const titleClause = title ? `"${title}" — ` : '';
        pickupBody =
          `Our next pickup: ${titleClause}${when}${where}.\n` +
          `Reply "in" if you can make it and I'll expect you.\n` +
          `Come play, meet the squad, see if it's your scene. If it is, $1 to lock in your team spot.`;
      } else {
        pickupBody =
          `No pressure to commit yet — reply and I'll let you know when the next pickup is scheduled.\n` +
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
      // Close — response to a YES reply on touch-1's "want to play?"
      // question.  Ultra-minimum: one-line congratulation + register
      // link + sign-off.  NO info dump.  A lead who said "yes I want
      // to play" already has intent; adding cost/schedule/field details
      // here just gives them more surface to reconsider on.  Info-
      // hungry leads (who reply with "can you tell me more about…")
      // get the More Info snippet instead.
      //
      // Subject deliberately inherits 'Re: ' + touch-1 subject (via
      // buildMailHrefForSnippet fallback) so Gmail visually threads the
      // reply into the original outreach — coach clicks Send and it
      // looks like a natural continuation of the conversation.
      //
      // smsBody: same message compressed to one segment so the coach
      // can close via SMS on leads that came in phone-preferred.
      (() => {
        const linkBlock = c.isLegacyYouth
          ? `Register here (full program details on the page):\n` +
            `• Boys: ${c.linkBoys}\n` +
            `• Girls: ${c.linkGirls}`
          : `Register here (full program details on the page):\n${c.link}`;
        const smsLinkBit = c.isLegacyYouth
          ? `Boys: ${c.linkBoys} · Girls: ${c.linkGirls}`
          : c.link;
        return {
          id: 'close',
          label: '📨 Close',
          tier: 'followup',
          body:
            `Hi {first},\n` +
            `\n` +
            `Great — ${c.closerLine}.\n` +
            `\n` +
            `${linkBlock}\n` +
            `\n` +
            `Once you're registered, I'll send you a link to set your availability for practices and games.\n` +
            `\n` +
            `Let me know if you have any questions!\n` +
            `\n` +
            `— {coachFirst}\n` +
            `Soccer Director\n` +
            `Lighthouse 1893 SC`,
          smsBody:
            `Great — ${c.closerLine}. Register: ${smsLinkBit}\n` +
            `Once registered, I'll send a link to set your availability for practices & games.\n` +
            `Let me know if you have any questions!\n` +
            `— {coachFirst}`,
        };
      })(),
      // More info — catch-all reply for the "tell me more" /
      // "send me more info" follow-up.  The email body is a coach-
      // wrapped clone of the LA program description text (single
      // source of truth: any edit to laDescText updates both the LA
      // program page copy AND this reply).  SMS body stays compressed
      // — SMS can't carry a policy dump without ballooning to a
      // 6-segment monster, and the three questions leads actually ask
      // via text are field / cost / register link.
      //
      // Next-practice injection: the SCHEDULE section gets a fresh
      // "Next practice: <weekday, mon day>" line prepended (Unicode-
      // bold so it survives Gmail's plain-text pipeline).  Lives ONLY
      // in the more-info email — the LA program page is static content
      // and cannot carry a time-sensitive date.  Women's Club skips
      // this (no practice yet, kickoff is Sundays starting Sept).
      (() => {
        // Cadence used to compute "next practice" per audience:
        //   • youth   → Mon/Wed — the days shared by BOTH grade tiers
        //               (2nd-and-under practice Mon/Wed; 3rd-and-older
        //               practice Mon/Wed/Fri).  Using the shared pair
        //               avoids surfacing a Friday date that only applies
        //               to half the roster.
        //   • adult M → Tue/Wed/Thu/Fri/Sat — all five weekly sessions
        //               (practice Wed/Thu/Fri + pickup Tue/Sat);
        //               8:30pm end hour + buffer means 21.
        //   • women's → skipped (no practice yet).
        let nextPracticeLine = '';
        if (c.isYouth) {
          const np = this._nextPractice([1, 3], 19);
          nextPracticeLine = `  • ${this._boldText('Next practice:')} ${np.label}\n`;
        } else if (!c.isWomensClub) {
          const np = this._nextPractice([2, 3, 4, 5, 6], 21);
          nextPracticeLine = `  • ${this._boldText('Next practice:')} ${np.label}\n`;
        }
        // Inject the next-practice line right under the SCHEDULE:
        // header so it sits at the top of the schedule bullets.  The
        // laDescText variable itself is untouched — this is a per-
        // render string transform.
        const moreInfoDescText = nextPracticeLine
          ? laDescText.replace(/SCHEDULE:\n/, `SCHEDULE:\n${nextPracticeLine}`)
          : laDescText;
        const registerLine = c.isLegacyYouth
          ? `To register, head here:\n` +
            `• Boys: ${c.linkBoys}\n` +
            `• Girls: ${c.linkGirls}\n`
          : `To register, head here: ${c.link}\n`;
        const moreInfoBody = c.isYouth
          ? (
            `Hi {first},\n` +
            `\n` +
            `Let me know any questions!\n` +
            `\n` +
            registerLine +
            `\n` +
            `Here's the full program description:\n` +
            `\n` +
            moreInfoDescText
          )
          : (
            `Hi {first},\n` +
            `\n` +
            `That's great that you want to play soccer for Lighthouse ${c.isWomensClub ? "Women's" : "Men's"} Soccer Club 1893!\n` +
            `\n` +
            `To register, head here: ${c.link}\n` +
            `\n` +
            (c.isWomensClub ? '' : `Once registered you can join in practices and games to find your appropriate place at the club.\n\n`) +
            `Here's the full program description:\n` +
            `\n` +
            moreInfoDescText
          );
        return {
          id: 'more-info',
          label: 'ℹ️ More info',
          tier: 'followup',
          body: moreInfoBody,
          // SMS variant — compressed to a couple of segments.  Ditches
          // the full description; keeps field address, cost, card-on-
          // file requirement, and register link (the four questions
          // leads actually ask via text — and the one policy line that
          // sets billing expectation before checkout). Women's Club has
          // no card-on-file model (LA registration is free), so that
          // line is skipped for it.
          smsBody:
            `Hi {first} — quick details on ${c.program}:\n` +
            `• Field: 199 E Erie Ave, Philadelphia PA\n` +
            `• Cost: ${c.initialFee} to register, then ${c.pricing}\n` +
            (c.isWomensClub ? '' : `• Card on file with sufficient funds required (auto-charged monthly)\n`) +
            `Register: ${c.isLegacyYouth ? (c.linkBoys + ' (boys) · ' + c.linkGirls + ' (girls)') : c.link}\n` +
            `Reply w/ any Qs — {coachFirst}`,
        };
      })(),
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
          `   https://maps.google.com/?q=Lighthouse+Sport+Complex+Field\n` +
          `📍 Lighthouse Community Center — 141 W Somerset St (indoor)\n` +
          `   https://maps.google.com/?q=141+W+Somerset+St+Philadelphia+PA+19140\n` +
          `\n` +
          closeLink(`$1 locks ${c.whose} spot:`),
      },
      // Schedule chips — three chips off the same data:
      //   📅 Practice  — just practice line(s) (+ pickup-counts-as-practice note)
      //   📅 Games     — just games line(s) + public URL when available
      //   📅 Schedule  — both combined, for the generic "what's the schedule?" Q
      // Each doubles as a soft-close — leads asking logistics are in a
      // "does this fit my life?" frame, so every chip ends with the $1
      // register CTA right there.
      ...(c.schedule
        ? (() => {
            // Shared line builders so all three chips stay in sync.
            const practiceLines = () => {
              const out = [];
              if (c.schedule.practice) {
                out.push(`Practice: ${c.schedule.practice}`);
                out.push(`Lighthouse Sports Complex, 199 East Erie Avenue, Philadelphia PA 19140`);
              }
              // For Men funnels practiceNote tells the lead our pickups also
              // count as a practice if Wed/Fri don't fit — lowers the
              // friction of "I can't make those exact days" objections.
              if (c.schedule.practiceNote) out.push(c.schedule.practiceNote);
              return out;
            };
            const gamesLines = () => {
              const out = [];
              if (c.schedule.url) {
                out.push(`Games are mostly on ${c.schedule.day} — full schedule (${c.schedule.sourceOf}):`);
                out.push(c.schedule.url);
              } else {
                out.push(`Games are mostly on ${c.schedule.day}.`);
                out.push(`Specific times/fields confirm after rosters close.`);
              }
              return out;
            };
            const close = closeLink(`If it works, $1 locks ${c.whose} spot:`);

            const chips = [];
            // Practice chip — only shown when the funnel actually has
            // a practice schedule defined (Tri County Women has none).
            if (c.schedule.practice) {
              chips.push({
                id: 'practice',
                label: '📅 Practice',
                tier: 'info',
                body: [...practiceLines(), '', close].join('\n'),
              });
            }
            chips.push({
              id: 'games',
              label: '📅 Games',
              tier: 'info',
              body: [...gamesLines(), '', close].join('\n'),
            });
            // Combined Schedule chip — catches the generic "what's the
            // schedule?" question that doesn't specify practice vs games.
            chips.push({
              id: 'schedule',
              label: '📅 Schedule',
              tier: 'info',
              body: [...practiceLines(), ...gamesLines(), '', close].join('\n'),
            });
            return chips;
          })()
        : [{
            id: 'schedule',
            label: '📅 Schedule',
            tier: 'info',
            todo: true,
            body:
              `Practice schedule for our ${c.program}:\n` +
              `(TODO — fill this in once confirmed for the season.)`,
          }]),
      {
        id: 'cost',
        label: '💵 Cost',
        tier: 'info',
        body:
          (c.isWomensClub
            ? `Registering with Lighthouse is free. After that it's ${c.pricing}.\n`
            : `${c.initialFee} today to lock ${c.whose} spot. After that it's ${c.pricing}.\n`) +
          `\n` +
          closeLink('Register here:'),
      },
      // 📚 Fall Format — explains the 3-band Fall 2026 structure for
      // youth funnels (PreK–1st in-house, 2nd–6th select/travel +
      // alternative program, 7th+ tournament format).  Only relevant
      // to youth funnels; adult chips don't render this.
      ...(c.isYouth ? [{
        id: 'fall-format',
        label: '📚 Fall Format',
        tier: 'info',
        body:
          `Fall 2026 season format at Lighthouse 1893 SC:\n` +
          `• PreK–1st grade: In-House league\n` +
          `• 2nd–6th grade: Select/Travel teams — players not selected take part in the Lighthouse In-House League, tournaments, friendly games, festivals, practices & pickup sessions\n` +
          `• 7th–12th grade: Lighthouse In-House League, tournaments, friendly games, festivals, practices & pickup sessions\n` +
          `\n` +
          closeLink('Register here:'),
      }] : []),
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
    // Auto-detect logged-in user's name for signoff. Falls back to plain "Coach".
    const me    = (this.auth && this.auth.getUser && this.auth.getUser()) || {};
    const coach = me.first_name ? `Coach ${me.first_name}` : 'Coach';
    // `{coachFirst}` is the bare name (no "Coach " prefix) — used in
    // touch-1 intros that sign off with a job title ("Soccer Director")
    // instead of the "Coach " prefix, to avoid "Coach Mike, Soccer
    // Director" redundancy.  Resolves to "{first_name} {last_name}"
    // when both are on the auth profile so the signoff carries the full
    // name (token name kept for backwards compat with existing
    // templates).  Falls back to "Coach" when no logged-in user.
    const coachFirst = me.first_name
      ? (me.last_name ? `${me.first_name} ${me.last_name}` : me.first_name)
      : 'Coach';
    return tmpl.replace(/\{first\}/g, first)
               .replace(/\{full\}/g,  full)
               .replace(/\{phone\}/g, lead.phone || '')
               .replace(/\{coachFirst\}/g, coachFirst)
               .replace(/\{coach\}/g, coach);
  }

  buildSmsHref(lead, label) {
    const t = this.messageTemplate(label);
    const body = this.fillTemplate(t.sms, lead);
    // sms: URI with both ?body= and &body= — iOS uses &, Android uses ?
    const phone = (lead.phone || '').replace(/[^\d+]/g, '');
    return `sms:${phone}?&body=${encodeURIComponent(body)}`;
  }

  // SMS variant of buildMailHrefForSnippet — pre-fills the phone's
  // Messages app with a snippet's `smsBody` (or `body` as a fallback,
  // so snippets that only defined the email variant still work at all,
  // just not as pretty).  Powers the 📨 Close 💬 and ℹ Info 💬 chips.
  buildSmsHrefForSnippet(lead, label, snippetId) {
    const snippets = this.messageSnippets(label) || [];
    const snip = snippets.find(s => s.id === snippetId);
    if (!snip || !lead.phone) return '';
    const raw = snip.smsBody || snip.body || '';
    const body = this.fillTemplate(raw, lead);
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

  // Touch-2 (or any snippet) variant of buildMailHref — pre-fills Gmail
  // compose with the snippet's body and a sensible follow-up subject so
  // a single click on the lead card opens a ready-to-send email.
  //
  // Subject precedence:
  //   1. snippet.subject (broadcasts set this explicitly)
  //   2. fallback: 'Re: ' + the touch-1 club title — keeps the visual
  //      thread with the original outreach even though Gmail can't
  //      actually merge it into the existing thread (no In-Reply-To
  //      header is possible from a compose link).
  //
  // Body is the personalized snippet body — same flow as the existing
  // copy chip on the Messages page, just one-click instead of two.
  buildMailHrefForSnippet(lead, label, snippetId) {
    const snippets = this.messageSnippets(label) || [];
    const snip = snippets.find(s => s.id === snippetId);
    if (!snip || !lead.email) return '';
    const body = this.fillTemplate(snip.body, lead);
    const subjectRaw = snip.subject
      || ('Re: ' + (this.messageTemplate(label).subject || ''));
    const subject = this.fillTemplate(subjectRaw, lead);
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

  // Mark-signed-up / undo handler.  POSTs (or DELETEs) to
  // /api/leads/:id/mark-converted, then patches the in-memory lead
  // array with the refreshed row and re-renders so the card moves
  // between tabs without a full reload.
  async onConvertClick(e) {
    const btn    = e.currentTarget;
    const leadId = btn.getAttribute('data-lead-id');
    const action = btn.getAttribute('data-action');  // 'mark' | 'unmark'
    if (!leadId || !action) return;

    // Guard against double-clicks while the request is in flight.
    if (btn.dataset.busy === '1') return;
    btn.dataset.busy = '1';
    const origText = btn.textContent;
    btn.textContent = '…';

    try {
      let res;
      if (action === 'mark') {
        res = await this.auth.fetch(`/api/leads/${leadId}/mark-converted`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ source: 'manual' }),
        });
      } else {
        // Undo — confirm so a stray tap doesn't wipe a real conversion.
        if (!confirm('Clear the signed-up flag on this lead?')) {
          btn.dataset.busy = '0';
          btn.textContent = origText;
          return;
        }
        res = await this.auth.fetch(`/api/leads/${leadId}/mark-converted`, {
          method: 'DELETE',
        });
      }
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const refreshed = await res.json();

      // Patch the cached array in place so re-render picks up the
      // new converted_at / needs_followup state without another GET.
      if (Array.isArray(this._leads)) {
        const idx = this._leads.findIndex(l => String(l.id) === String(leadId));
        if (idx >= 0) this._leads[idx] = refreshed;
      }
      this.renderLeads(this._leads || []);
    } catch (err) {
      btn.dataset.busy = '0';
      btn.textContent = origText;
      alert(`Failed to ${action === 'mark' ? 'mark signed up' : 'undo'}: ${err.message}`);
    }
  }

  // Mark-dead / revive handler.  POSTs (or DELETEs) to
  // /api/leads/:id/mark-dead, patches the in-memory lead array, and
  // re-renders so the card moves between status tabs without a full
  // reload.  No confirm() prompt: dead leads remain visible in the
  // All + Dead tabs and revive is one click away.
  async onDeadClick(e) {
    const btn    = e.currentTarget;
    const leadId = btn.getAttribute('data-lead-id');
    const action = btn.getAttribute('data-action');  // 'mark' | 'unmark'
    if (!leadId || !action) return;

    if (btn.dataset.busy === '1') return;
    btn.dataset.busy = '1';
    const origText = btn.textContent;
    btn.textContent = '…';

    try {
      const res = await this.auth.fetch(`/api/leads/${leadId}/mark-dead`, {
        method: action === 'mark' ? 'POST' : 'DELETE',
        headers: { 'Content-Type': 'application/json' },
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const refreshed = await res.json();

      if (Array.isArray(this._leads)) {
        const idx = this._leads.findIndex(l => String(l.id) === String(leadId));
        if (idx >= 0) this._leads[idx] = refreshed;
      }
      this.renderLeads(this._leads || []);
    } catch (err) {
      btn.dataset.busy = '0';
      btn.textContent = origText;
      alert(`Failed to ${action === 'mark' ? 'mark dead' : 'revive'}: ${err.message}`);
    }
  }

  // ─── Lead edit modal ─────────────────────────────────────────────
  // The card render intentionally only shows essentials (name / phone
  // / email / Email / Text / Edit).  All lifecycle actions, color
  // overrides, vCard download, and richer metadata live in this
  // modal so the card itself stays scannable.  Whole-card color is
  // the primary at-a-glance signal; this modal is the back-channel
  // for forcing or correcting that color.

  // Patch this._leads in place with the freshest server payload.
  // Used by every modal action so the underlying card re-renders
  // immediately with the new status / color / timestamps.
  _patchLead(refreshed) {
    if (!refreshed || !Array.isArray(this._leads)) return;
    const idx = this._leads.findIndex(l => String(l.id) === String(refreshed.id));
    if (idx >= 0) this._leads[idx] = refreshed;
  }

  openEditModal(leadId) {
    const lead = (this._leads || []).find(l => String(l.id) === String(leadId));
    if (!lead) return;

    // Tear down any prior modal so re-opening on a different lead
    // doesn't stack overlays.
    document.getElementById('lead-edit-modal')?.remove();

    const overlay = document.createElement('div');
    overlay.id = 'lead-edit-modal';
    overlay.style.cssText = 'position:fixed; inset:0; z-index:9999; background:rgba(0,0,0,0.65); display:flex; align-items:center; justify-content:center; padding:var(--space-3);';

    overlay.innerHTML = `
      <div id="lead-edit-modal-panel"
           style="background:var(--bg-secondary); border-radius:var(--radius-lg);
                  padding:var(--space-3); max-width:480px; width:100%;
                  max-height:90vh; overflow-y:auto; color:var(--text-primary);
                  box-shadow:0 20px 50px rgba(0,0,0,0.4);">
        <div id="lead-edit-modal-body">${this.renderEditModalBody(lead)}</div>
      </div>
    `;

    document.body.appendChild(overlay);

    // Backdrop click closes; clicks inside the panel are swallowed by
    // the target check so they don't propagate as close.
    overlay.addEventListener('click', (e) => {
      if (e.target === overlay) overlay.remove();
    });

    this.wireEditModal(leadId);
  }

  renderEditModalBody(lead) {
    const label       = this.formLabel(lead.form_id) || '';
    const override    = lead.status_override || null;
    const convertedAt = lead.converted_at || null;
    const deadAt      = lead.dead_at || null;

    const fmtDate = (iso) => {
      if (!iso) return '';
      const d = new Date(iso);
      return d.toLocaleDateString('en-US', { month:'short', day:'numeric', year:'numeric' });
    };
    const fmtDateTime = (iso) => {
      if (!iso) return '';
      const d = new Date(iso);
      return d.toLocaleString('en-US', { month:'short', day:'numeric', year:'numeric', hour:'2-digit', minute:'2-digit' });
    };
    const ago = (iso) => {
      if (!iso) return '';
      const d = new Date(iso);
      const m = Math.floor((Date.now() - d.getTime()) / 60000);
      if (m < 1)  return 'just now';
      if (m < 60) return `${m}m ago`;
      const h = Math.floor(m / 60);
      if (h < 24) return `${h}h ago`;
      return fmtDate(iso);
    };

    // Same palette as the card so the swatch the coach picks matches
    // exactly what the card flips to.
    const SWATCHES = [
      { id: 'new',       color: '#16a34a', label: 'New'       },
      { id: 'responded', color: '#eab308', label: 'Responded' },
      { id: 'signedup',  color: '#2563eb', label: 'Signed up' },
      { id: 'dead',      color: '#dc2626', label: 'Dead'      },
    ];

    const swatchRow = SWATCHES.map(s => {
      const isActive = override === s.id;
      return `<button type="button" class="status-swatch" data-status="${s.id}"
                title="Force color: ${s.label}"
                style="width:38px; height:38px; border-radius:50%; cursor:pointer; background:${s.color}; padding:0;
                       border:${isActive ? '3px solid #fff' : '2px solid rgba(255,255,255,0.20)'};
                       box-shadow:${isActive ? '0 0 0 2px rgba(255,255,255,0.35)' : 'none'};"></button>`;
    }).join('');

    const autoActive = (override === null || override === undefined);
    const autoBtn = `<button type="button" class="status-swatch" data-status=""
        title="Auto (clear override — follow lifecycle)"
        style="height:38px; padding:0 14px; border-radius:19px; cursor:pointer; font-size:0.8rem;
               background:${autoActive ? '#374151' : 'transparent'}; color:var(--text-primary);
               border:${autoActive ? '3px solid #fff' : '2px solid rgba(255,255,255,0.20)'};">↺ Auto</button>`;

    const btnStyle = 'padding:8px 14px; font-size:0.85rem; font-weight:600; border-radius:6px; border:none; cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; justify-content:center; gap:6px;';

    const convertSection = convertedAt
      ? `
        <div style="font-size:0.8rem; opacity:0.85;">✓ Signed up ${ago(convertedAt)}${lead.converted_source && lead.converted_source !== 'manual' ? ` · ${lead.converted_source}` : ''}</div>
        <button type="button" class="modal-convert-btn" data-action="unmark"
                style="${btnStyle} background:#374151; color:#93c5fd; align-self:flex-start;">↩ Undo signed up</button>`
      : `<button type="button" class="modal-convert-btn" data-action="mark"
                style="${btnStyle} background:#15803d; color:#fff; align-self:flex-start;">✓ Mark signed up</button>`;

    const deadSection = deadAt
      ? `
        <div style="font-size:0.8rem; opacity:0.85;">✖ Marked dead ${ago(deadAt)}</div>
        <button type="button" class="modal-dead-btn" data-action="unmark"
                style="${btnStyle} background:#374151; color:#fca5a5; align-self:flex-start;">↩ Revive</button>`
      : `<button type="button" class="modal-dead-btn" data-action="mark"
                style="${btnStyle} background:#7f1d1d; color:#fff; align-self:flex-start;">✖ Mark dead</button>`;

    const emailCount = Number(lead.email_count || 0);
    const textCount  = Number(lead.text_count  || 0);
    const lastEmailedLine = emailCount
      ? `Emailed ${ago(lead.last_email_at)} (×${emailCount})`
      : 'Never emailed';
    const lastTextedLine = textCount
      ? `Texted ${ago(lead.last_text_at)} (×${textCount})`
      : 'Never texted';

    const isYouth   = this.isParentFunnel(label);
    const saveKind  = isYouth ? 'youth-pair' : 'self';
    const saveLabel = isYouth ? '📇 Save contact (2)' : '📇 Save contact';

    return `
      <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:var(--space-2); margin-bottom:var(--space-3);">
        <div>
          <div style="font-size:1.05rem; font-weight:700;">${lead.name || '(no name)'}</div>
          ${label ? `<div style="font-size:0.78rem; opacity:0.65;">${label}</div>` : ''}
        </div>
        <button type="button" id="lead-edit-close"
                style="background:none; border:none; color:var(--text-primary); cursor:pointer; font-size:1.5rem; line-height:1; padding:0 4px;">×</button>
      </div>

      <div style="margin-bottom:var(--space-3);">
        <div style="font-size:0.78rem; opacity:0.7; margin-bottom:8px; text-transform:uppercase; letter-spacing:0.05em;">Color override</div>
        <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">${swatchRow}${autoBtn}</div>
        <div style="font-size:0.72rem; opacity:0.55; margin-top:8px;">
          ${override ? `Forced to <strong>${override}</strong> — card ignores lifecycle.` : 'Auto — card color follows lifecycle.'}
        </div>
      </div>

      <div style="margin-bottom:var(--space-3); display:flex; gap:8px; flex-direction:column;">
        <div style="font-size:0.78rem; opacity:0.7; text-transform:uppercase; letter-spacing:0.05em;">Lifecycle</div>
        ${convertSection}
        ${deadSection}
      </div>

      <div style="margin-bottom:var(--space-3); font-size:0.82rem; opacity:0.85; line-height:1.6;">
        <div style="font-size:0.78rem; opacity:0.85; margin-bottom:6px; text-transform:uppercase; letter-spacing:0.05em;">Details</div>
        ${lead.phone ? `<div>Phone: ${this.formatPhoneNumber(lead.phone)}</div>` : ''}
        ${lead.email ? `<div>Email: ${lead.email}</div>` : ''}
        <div>Created: ${fmtDateTime(lead.created_at)}</div>
        <div>${lastEmailedLine}</div>
        <div>${lastTextedLine}</div>
        ${lead.form_id ? `<div>Form: ${lead.form_id}</div>` : ''}
        ${lead.ad_id  ? `<div>Ad: ${lead.ad_id}</div>` : ''}
      </div>

      <div style="margin-bottom:var(--space-3);">
        <div style="font-size:0.78rem; opacity:0.85; margin-bottom:6px; text-transform:uppercase; letter-spacing:0.05em;">Recent touches</div>
        <div style="font-size:0.70rem; opacity:0.55; margin-bottom:6px;">
          Click ✕ if you opened the composer but didn't actually send.  Deleting
          a fan-out touch also clears the sibling rows on duplicate-email/phone leads.
        </div>
        <div id="lead-edit-contacts" style="font-size:0.82rem; opacity:0.9;">Loading…</div>
      </div>

      <div>
        <a href="javascript:void(0)" class="modal-vcard-btn"
           data-kind="${saveKind}"
           style="${btnStyle} background:var(--bg-tertiary, #374151); color:#fff;">${saveLabel}</a>
      </div>
    `;
  }

  // Re-attach handlers after every modal body refresh.  Cheap to
  // re-bind on a single-card panel and keeps the state machine
  // trivial (one source of truth = this._leads).
  wireEditModal(leadId) {
    const overlay = document.getElementById('lead-edit-modal');
    if (!overlay) return;

    overlay.querySelector('#lead-edit-close')?.addEventListener('click', () => overlay.remove());

    overlay.querySelectorAll('.status-swatch').forEach(btn => {
      btn.addEventListener('click', () => {
        const v = btn.getAttribute('data-status');
        this.onModalStatusOverride(leadId, v ? v : null);
      });
    });

    overlay.querySelector('.modal-convert-btn')?.addEventListener('click', (e) => {
      this.onModalConvert(leadId, e.currentTarget.getAttribute('data-action'));
    });

    overlay.querySelector('.modal-dead-btn')?.addEventListener('click', (e) => {
      this.onModalDead(leadId, e.currentTarget.getAttribute('data-action'));
    });

    overlay.querySelector('.modal-vcard-btn')?.addEventListener('click', async (e) => {
      const kind = e.currentTarget.getAttribute('data-kind') || 'self';
      try {
        await this.saveLeadContact(leadId, kind);
      } catch (err) {
        alert(`Failed to save contact: ${err.message}`);
      }
    });

    // Recent-touches list lives in its own placeholder so we can
    // re-render it independently of the rest of the modal body when
    // a row is deleted.  Loaded asynchronously so the modal opens
    // immediately rather than waiting on a round-trip.
    this.loadModalContacts(leadId);
  }

  // GET /api/leads/:id/contacts → render the Recent-touches list.
  async loadModalContacts(leadId) {
    const root = document.getElementById('lead-edit-contacts');
    if (!root) return;
    try {
      const res = await this.auth.fetch(`/api/leads/${leadId}/contacts`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const payload = await res.json();
      const list = Array.isArray(payload.contacts) ? payload.contacts : [];
      this._renderModalContacts(leadId, list);
    } catch (err) {
      root.innerHTML = `<span style="opacity:0.6;">Failed to load: ${err.message}</span>`;
    }
  }

  _renderModalContacts(leadId, list) {
    const root = document.getElementById('lead-edit-contacts');
    if (!root) return;
    if (!list.length) {
      root.innerHTML = '<span style="opacity:0.6;">No touches yet.</span>';
      root._contacts = [];
      return;
    }
    const ago = (iso) => {
      if (!iso) return '';
      const d = new Date(iso);
      const m = Math.floor((Date.now() - d.getTime()) / 60000);
      if (m < 1)  return 'just now';
      if (m < 60) return `${m}m ago`;
      const h = Math.floor(m / 60);
      if (h < 24) return `${h}h ago`;
      const days = Math.floor(h / 24);
      if (days < 30) return `${days}d ago`;
      return d.toLocaleDateString('en-US', { month:'short', day:'numeric', year:'numeric' });
    };
    const verbOf = (ch) => ch === 'email' ? 'Emailed' : ch === 'text' ? 'Texted' : ch;
    root.innerHTML = list.map(c => {
      const tpl = c.template ? ` <span style="opacity:0.55;">· ${c.template}</span>` : '';
      return `
        <div style="display:flex; justify-content:space-between; align-items:center; padding:5px 0; border-bottom:1px solid rgba(255,255,255,0.06);">
          <span>${verbOf(c.channel)} ${ago(c.sent_at)}${tpl}</span>
          <button type="button" class="modal-del-contact"
                  data-cid="${c.id}" data-channel="${c.channel}"
                  title="Delete this touch (also removes sibling fan-out rows)"
                  style="background:none; border:none; color:#fca5a5; cursor:pointer; font-size:1.2rem; line-height:1; padding:0 8px;">✕</button>
        </div>`;
    }).join('');
    root._contacts = list;
    root.querySelectorAll('.modal-del-contact').forEach(btn => {
      btn.addEventListener('click', () => {
        this.onModalDeleteContact(
          leadId,
          Number(btn.getAttribute('data-cid')),
          btn.getAttribute('data-channel'),
        );
      });
    });
  }

  // DELETE one logged touch + fan-out siblings.  Decrement cached
  // counts immediately so every affected card flips back; refresh
  // the modal lead's timestamps from the fresh contacts list.
  async onModalDeleteContact(leadId, contactId, channel) {
    if (!confirm('Delete this logged touch?\n\nIf this was a fan-out send (duplicate email/phone) the matching sibling rows will also be removed.')) return;
    try {
      const res = await this.auth.fetch(`/api/leads/${leadId}/contacts/${contactId}`, { method: 'DELETE' });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const payload = await res.json();
      const affected = Array.isArray(payload.affected_lead_ids) && payload.affected_lead_ids.length
        ? payload.affected_lead_ids.map(Number)
        : [Number(leadId)];

      // Decrement cached counts on every affected lead.  Sibling
      // last_X_at timestamps may temporarily lag (their next page
      // refresh fixes them) — the modal lead gets fresh timestamps
      // recomputed below from the just-reloaded contacts list.
      for (const aid of affected) {
        const target = (this._leads || []).find(l => String(l.id) === String(aid));
        if (!target) continue;
        if (channel === 'email') {
          target.email_count = Math.max(0, Number(target.email_count || 0) - 1);
          if (target.email_count === 0) target.last_email_at = null;
        } else if (channel === 'text') {
          target.text_count = Math.max(0, Number(target.text_count || 0) - 1);
          if (target.text_count === 0) target.last_text_at = null;
        }
      }

      // Reload the modal lead's contacts (gives us authoritative
      // last_X_at values for this card).
      await this.loadModalContacts(leadId);
      const root = document.getElementById('lead-edit-contacts');
      const fresh = (root && root._contacts) || [];
      const modalLead = (this._leads || []).find(l => String(l.id) === String(leadId));
      if (modalLead) {
        const newestEmail = fresh.find(c => c.channel === 'email');
        const newestText  = fresh.find(c => c.channel === 'text');
        modalLead.last_email_at = newestEmail ? newestEmail.sent_at : null;
        modalLead.last_text_at  = newestText  ? newestText.sent_at  : null;
      }

      // Re-render cards + the modal body (counts, pill label, color
      // all derive from this._leads).
      this.renderLeads(this._leads || []);
      const body = document.getElementById('lead-edit-modal-body');
      if (body && modalLead) {
        body.innerHTML = this.renderEditModalBody(modalLead);
        this.wireEditModal(leadId);
      }
    } catch (err) {
      alert(`Failed to delete touch: ${err.message}`);
    }
  }

  // Refresh both the underlying card grid and the modal body in
  // place.  Called by every modal action handler after a successful
  // server round-trip.
  _refreshAfterModalAction(leadId, refreshed) {
    this._patchLead(refreshed);
    this.renderLeads(this._leads || []);
    const body = document.getElementById('lead-edit-modal-body');
    if (body) {
      body.innerHTML = this.renderEditModalBody(refreshed);
      this.wireEditModal(leadId);
    }
  }

  async onModalStatusOverride(leadId, value) {
    try {
      const res = await this.auth.fetch(`/api/leads/${leadId}/status-override`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: value }),
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      this._refreshAfterModalAction(leadId, await res.json());
    } catch (err) {
      alert(`Failed to set color override: ${err.message}`);
    }
  }

  async onModalConvert(leadId, action) {
    try {
      const res = await this.auth.fetch(`/api/leads/${leadId}/mark-converted`, {
        method: action === 'mark' ? 'POST' : 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: action === 'mark' ? JSON.stringify({ source: 'manual' }) : undefined,
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      this._refreshAfterModalAction(leadId, await res.json());
    } catch (err) {
      alert(`Failed to ${action === 'mark' ? 'mark signed up' : 'undo'}: ${err.message}`);
    }
  }

  async onModalDead(leadId, action) {
    try {
      const res = await this.auth.fetch(`/api/leads/${leadId}/mark-dead`, {
        method: action === 'mark' ? 'POST' : 'DELETE',
        headers: { 'Content-Type': 'application/json' },
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      this._refreshAfterModalAction(leadId, await res.json());
    } catch (err) {
      alert(`Failed to ${action === 'mark' ? 'mark dead' : 'revive'}: ${err.message}`);
    }
  }

  // ── Save a lead to the phone's contacts ──────────────────────────────
  //
  // Owner 2026-08-26: "on leads page i need to be able to click a button
  // and add player to contacts on my android phone but for others apple
  // too."
  //
  // The vCard itself is built server-side (GET /api/leads/:id/vcard,
  // LeadsController::handleVcard) — parent/player pair logic, the note
  // lines and the name mangling all live there, and duplicating that in
  // JS would give us two formats to keep in step. This method is only
  // about *delivery*, which is where the phones differ.
  //
  //   1. Web Share (navigator.share with a File) — the one path that
  //      actually reaches the Contacts app. Android's sheet lists
  //      Contacts as a target for a text/vcard file; iOS shows the
  //      contact preview with "Add to Contacts". One tap, no file
  //      manager. Supported by Chrome on Android and Safari 15+ on iOS.
  //   2. <a download> blob — desktop, and any mobile browser without
  //      file sharing. On a phone this only lands the .vcf in Downloads
  //      and leaves the user to open it themselves, which is exactly the
  //      "why is this a file" problem, so it is the fallback, not the
  //      default.
  //
  // The blob is cached per (lead, kind). Not for speed: iOS Safari
  // enforces transient activation on navigator.share, and awaiting the
  // fetch first can burn it (NotAllowedError). When that happens we fall
  // back to the download AND keep the blob, so the user's second tap
  // shares with no await in between and goes straight to the sheet.
  async saveLeadContact(leadId, kind = 'self') {
    const cacheKey = `${leadId}:${kind}`;
    this._vcardCache = this._vcardCache || new Map();

    let entry = this._vcardCache.get(cacheKey);
    if (!entry) {
      const res = await this.auth.fetch(`/api/leads/${leadId}/vcard?kind=${kind}`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const blob = await res.blob();
      const cd   = res.headers.get('Content-Disposition') || '';
      const m    = /filename="([^"]+)"/.exec(cd);
      entry = { blob, filename: m ? m[1] : `lead-${leadId}.vcf` };
      this._vcardCache.set(cacheKey, entry);
    }

    // type on the File, not just the Blob: Android picks the share
    // targets from the MIME type, and an octet-stream .vcf offers file
    // managers instead of Contacts.
    const file = (typeof File === 'function')
      ? new File([entry.blob], entry.filename, { type: 'text/vcard' })
      : null;

    if (file && navigator.canShare && navigator.canShare({ files: [file] })) {
      try {
        // Files only — no title/text. Adding either drops the share
        // sheet into "share a message" mode on both platforms and the
        // Contacts target disappears.
        await navigator.share({ files: [file] });
        return 'shared';
      } catch (err) {
        // Every failure falls through to the download, dismissal
        // included. Whether the sheet even offers Contacts depends on
        // the ROM and the OS version, so a dismissal is as likely to
        // mean "it wasn't in there" as "never mind" — and the download
        // is the path that always ends in the Contacts app: the .vcf in
        // Downloads (Android) or Files (iOS) opens straight into the
        // import screen. Worst case the user backs out on purpose and
        // finds a stray .vcf; the alternative is a button that silently
        // does nothing, which is how this reads as broken.
      }
    }

    const url = URL.createObjectURL(entry.blob);
    const a   = document.createElement('a');
    a.href = url; a.download = entry.filename;
    document.body.appendChild(a); a.click(); document.body.removeChild(a);
    setTimeout(() => URL.revokeObjectURL(url), 1000);
    return 'downloaded';
  }

  async onContactClick(e) {
    const btn      = e.currentTarget;
    const leadId   = btn.getAttribute('data-lead-id');
    const channel  = btn.getAttribute('data-channel');

    if (channel === 'vcard') {
      e.preventDefault();
      const kind = btn.getAttribute('data-kind') || 'self';
      try {
        await this.saveLeadContact(leadId, kind);
      } catch (err) {
        alert(`Failed to save contact: ${err.message}`);
      }
      return;
    }

    // text/email/call — intercept so we can:
    //   1. (email only) write the rich-HTML body to the clipboard —
    //      Gmail compose pre-fills body= as PLAIN TEXT and won't
    //      linkify the URL in the editor.  Ctrl+A then Ctrl+V swaps
    //      in the <a>-tagged version with a clickable link.
    //   2. (email only) open Gmail compose ourselves AFTER the
    //      clipboard write resolves — letting the link's default
    //      navigation fire steals focus and may cancel the pending
    //      clipboard write.
    //   3. (call) skip clipboard/Gmail entirely — just POST the touch
    //      then let the tel: link's default action fire the dialer.
    //   4. (text) pre-fill the sms: URI with the snippet's smsBody
    //      (or the touch-1 SMS template if no snippet) — the OS
    //      Messages app opens the compose sheet w/ text ready.
    //   5. always POST the touch to /contact w/ (channel, template,
    //      body) + bump the cached counts so the card re-renders
    //      immediately with fresh badge + status pill.
    if (channel === 'email') e.preventDefault();
    // Read the template the coach clicked (first-touch / close /
    // more-info / call).  Fall back to first-touch when a legacy
    // button (no data-template) fires so the DB row still gets a
    // non-NULL value.
    const template = btn.getAttribute('data-template') || 'first-touch';
    try {
      const lead       = (this._leads || []).find(l => String(l.id) === String(leadId));
      const label      = lead ? this.formLabel(lead.form_id) : '';
      const snippetId  = btn.getAttribute('data-snippet');
      let   body;
      if (channel === 'call') {
        // Call channel — no message body, just an intent-to-dial log.
        body = '';
      } else if (snippetId) {
        // Snippet chip click — look up the snippet's body, fall back
        // to '' if missing.  For text channel we prefer smsBody
        // (shorter, plain-text formatting); email uses the rich body.
        const snippets = this.messageSnippets(label);
        const snip     = snippets.find(s => s.id === snippetId);
        if (snip) {
          const raw = (channel === 'text' && snip.smsBody) ? snip.smsBody : snip.body;
          body = this.fillTemplate(raw, lead || {});
        } else {
          body = '';
        }
      } else {
        const tmpl = this.messageTemplate(label);
        body = channel === 'text'
          ? this.fillTemplate(tmpl.sms,   lead || {})
          : this.fillTemplate(tmpl.email, lead || {});
      }
      // Email: copy rich HTML to clipboard AND open Gmail compose, both
      // fired in this same synchronous tick (before any `await` below
      // suspends the handler).  Previously the clipboard write was
      // `await`ed first and window.open() only ran once it resolved —
      // that pushed the navigation outside the click's user-activation
      // window, so browsers stopped honoring the compose URL and just
      // surfaced Gmail's already-open tab at its last (inbox) location
      // instead of the pre-filled compose view.  clipboard.write() only
      // needs to be *called* while this tab still has focus to succeed
      // (it validates focus at call time, not at resolution), so kicking
      // it off without awaiting first — right before window.open() —
      // keeps both the paste-ready clipboard and the compose window.
      if (channel === 'email' && body) {
        const html = this.toLinkifiedHtml(body);
        let clipboardPromise = Promise.resolve(false);
        try {
          if (navigator.clipboard && window.ClipboardItem && navigator.clipboard.write) {
            const item = new ClipboardItem({
              'text/plain': new Blob([body], { type: 'text/plain' }),
              'text/html':  new Blob([html], { type: 'text/html' }),
            });
            clipboardPromise = navigator.clipboard.write([item]).then(() => true).catch(() => false);
          } else if (navigator.clipboard?.writeText) {
            clipboardPromise = navigator.clipboard.writeText(body).then(() => true).catch(() => false);
          }
        } catch { /* clipboard blocked — fall through; Gmail still opens */ }

        // Open Gmail in a new tab now, still inside the click's
        // synchronous handler.  We use the precomputed href (already on
        // the <a>) so To/Subject/Body all pre-fill.  The plain-text body
        // is the failsafe: if the coach forgets to paste, Gmail still
        // linkifies recognizable URLs on send.
        const href = btn.getAttribute('href');
        if (href) window.open(href, '_blank', 'noopener,noreferrer');

        // Show a sticky banner explaining the paste step once we know
        // whether the copy actually succeeded.  Lives near the top of
        // the screen so it's visible when the coach Alt-Tabs back from
        // Gmail.
        const copied = await clipboardPromise;
        this._showEmailPasteBanner(copied, lead?.email || '');
      }
      const res = await this.auth.fetch(`/api/leads/${leadId}/contact`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ channel, message_body: body, template }),
      });
      // Server fans the contact out to every lead sharing the same
      // email (for channel='email') or phone (for channel='text'),
      // returning the list of affected lead IDs in
      // `affected_lead_ids`.  Patch each cached lead row so all
      // duplicate cards flip together — coach sees consistent state
      // across funnels for the same person.  Falls back to the
      // single clicked lead when the response is malformed / older
      // backend / vcard channel etc.
      let affectedIds = [Number(leadId)];
      try {
        if (res && res.ok) {
          const payload = await res.json();
          if (Array.isArray(payload.affected_lead_ids) && payload.affected_lead_ids.length) {
            affectedIds = payload.affected_lead_ids.map(Number);
          }
        }
      } catch { /* non-JSON or empty body — fall through */ }

      if (channel === 'email' || channel === 'text' || channel === 'call') {
        const nowIso = new Date().toISOString();
        for (const aid of affectedIds) {
          const target = (this._leads || []).find(l => String(l.id) === String(aid));
          if (!target) continue;
          if (channel === 'email') {
            target.email_count       = Number(target.email_count || 0) + 1;
            target.last_email_at     = nowIso;
            target.last_email_template = template;
          } else if (channel === 'text') {
            target.text_count        = Number(target.text_count || 0) + 1;
            target.last_text_at      = nowIso;
            target.last_text_template = template;
          } else {
            target.call_count        = Number(target.call_count || 0) + 1;
            target.last_call_at      = nowIso;
            target.last_call_template = template;
          }
          // Bump status to 'responded' if the lead was 'new' so the pill
          // flips colors immediately.  (Server-derived status takes over
          // on next refresh — this just keeps the optimistic render in
          // sync with the persisted row.)
          if (target.status === 'new' && !target.status_override) {
            target.status = 'responded';
          }
          // Fresh touch — lead is no longer stale.  Clear the optimistic
          // staleness flag so a "Needs recontact" card flips back to the
          // yellow "Emailed/Texted" bucket immediately instead of staying
          // orange until the next server refresh.
          target.needs_followup = false;
        }
        this.renderLeads(this._leads);
      }
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
