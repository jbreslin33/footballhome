// MensDelinquentScreen — surfaces every mens-program player who's overdue
// on dues.  Anchored on `person_billing.next_bill_date`; ranks by
// daysOverdue descending so the worst offenders float to the top.
//
// State scale (matches backend + user directive 2026-07-04):
//   0 or negative → not shown here (paid up)
//   1–3 days      → yellow  · nudge zone
//   4–6 days      → orange · call-them zone
//   7+ days       → red    · DUES OWED (past hold threshold; auto-sweep
//                             disabled 2026-07-04 pm, so state is
//                             advisory only)
//
// Data comes from GET /api/mens-roster which already computes
// `daysOverdue` + `delinquencyState` server-side and emits a top-level
// `delinquency` summary.
//
// "Open in LA" is a best-effort deep link — the LA public API is
// READ-ONLY (verified 2026-07-04), so pausing a member is manual in
// their admin UI.  We ship the URL that's most likely to land on the
// player's registration page; if 404 the admin can copy the visible
// registrationId and paste it into any LA admin search.

class MensDelinquentScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>💰 Delinquent Members</h1>
        <p class="subtitle">Players overdue on dues — 7+ days = dues owed (past hold threshold)</p>
      </div>

      <div style="padding: var(--space-4);">
        <div id="dq-banner" style="margin-bottom: var(--space-3); padding: var(--space-3); border-radius: 6px; background: #f1f5f9; border: 1px solid #e2e8f0; display:flex; align-items:center; gap: var(--space-3); flex-wrap: wrap; font-size: 14px;">
          <span id="dq-banner-icon" style="font-size: 16px;">⏳</span>
          <span id="dq-banner-text" style="flex:1; min-width: 200px;">Loading roster…</span>
          <button id="dq-refresh" class="btn btn-secondary" style="display:none; padding: 4px 10px; font-size: 13px;">🔄 Refresh</button>
        </div>
        <div id="dq-loading" style="text-align:center; padding: var(--space-6); opacity:0.6;">Loading…</div>
        <div id="dq-error"   style="display:none; color: var(--color-error); padding: var(--space-4); text-align:center;"></div>
        <div id="dq-body"    style="display:none;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter() {
    this.element.addEventListener('click', e => {
      if (e.target.closest('.back-btn')) return this.navigation.goBack();
      if (e.target.closest('#dq-refresh')) return this.load();
      const copyBtn = e.target.closest('.dq-copy-reg');
      if (copyBtn) return this._copyReg(copyBtn);
    });
    // Billing badge (edit / mark-billed) shares its click wiring — mark-billed
    // is the fastest way for admin to clear a player's dues-owed state once
    // dues are collected offline.
    if (window.BillingBadge) {
      window.BillingBadge.wire(this.element, this.auth.fetch.bind(this.auth), () => this.load());
    }
    this.load();
  }

  setBanner({ icon, text, showRefresh = false }) {
    const i = this.find('#dq-banner-icon');
    const t = this.find('#dq-banner-text');
    const r = this.find('#dq-refresh');
    if (i) i.textContent = icon;
    if (t) t.textContent = text;
    if (r) r.style.display = showRefresh ? '' : 'none';
  }

  async load() {
    const loading = this.find('#dq-loading');
    const errEl   = this.find('#dq-error');
    const body    = this.find('#dq-body');
    if (loading) loading.style.display = '';
    if (errEl)   errEl.style.display   = 'none';
    if (body)    body.style.display    = 'none';
    this.setBanner({ icon: '⏳', text: 'Loading roster…' });

    try {
      const res = await this.auth.fetch('/api/mens-roster');
      if (!res.ok) throw new Error((await res.text()).slice(0, 200) || `HTTP ${res.status}`);
      const data = await res.json();

      // Merge all buckets + unassigned into one flat list; dedupe by
      // leagueAppsUserId (a player can appear in multiple columns).
      const seen = new Map();
      const add = (arr) => {
        for (const p of arr || []) {
          const uid = p.leagueAppsUserId;
          if (uid == null) continue;
          if (!seen.has(uid)) seen.set(uid, p);
        }
      };
      add(data.unassigned);
      for (const bkt of Object.values(data.buckets || {})) add(bkt);

      const all = [...seen.values()];
      const overdue = all
        .filter(p => (p.daysOverdue || 0) >= 1)
        .sort((a, b) => (b.daysOverdue || 0) - (a.daysOverdue || 0));

      if (loading) loading.style.display = 'none';
      if (body)    body.style.display    = '';

      const summary = data.delinquency || {};
      this.setBanner({
        icon: overdue.length === 0 ? '✓' : (summary.duesOwedCount > 0 ? '🚨' : '⚠'),
        text: overdue.length === 0
          ? 'All members current on dues.'
          : `${overdue.length} overdue · ${summary.duesOwedCount || 0} dues owed (7+ days) · threshold ${summary.holdDays || 7} days`,
        showRefresh: true,
      });

      this.renderList(overdue, summary);
    } catch (err) {
      if (loading) loading.style.display = 'none';
      if (errEl) {
        errEl.style.display = '';
        errEl.textContent = `Failed to load: ${err.message}`;
      }
      this.setBanner({ icon: '✗', text: `Could not load: ${err.message}`, showRefresh: true });
    }
  }

  renderList(players, summary) {
    const container = this.find('#dq-body');

    if (players.length === 0) {
      container.innerHTML = `
        <div style="text-align:center; padding: var(--space-8); opacity:0.7;">
          <div style="font-size: 2.4rem; margin-bottom: var(--space-3);">🎉</div>
          <div style="font-size: 1.05rem; font-weight:600;">Everyone is current on dues.</div>
          <div style="font-size: 0.9rem; margin-top: var(--space-2); opacity:0.7;">
            Threshold: ${summary.holdDays || 7} days past nextBillDate = dues owed.
          </div>
        </div>
      `;
      return;
    }

    // Bucket by state so dues-owed floats above nudge/warning.
    const duesOwed = players.filter(p => p.delinquencyState === 'dues_owed');
    const warning  = players.filter(p => p.delinquencyState !== 'dues_owed' && (p.daysOverdue || 0) >= 4);
    const nudge    = players.filter(p => p.delinquencyState !== 'dues_owed' && (p.daysOverdue || 0) < 4);

    const section = (label, count, color, list) => list.length === 0 ? '' : `
      <div style="margin-bottom: var(--space-4);">
        <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px; padding: 6px 10px; background: ${color}22; border-left: 4px solid ${color}; border-radius: 4px;">
          <strong style="color:${color}; font-size: 0.9rem; letter-spacing: 0.04em; text-transform: uppercase;">${label}</strong>
          <span style="opacity:0.7; font-size: 0.85rem;">${count} ${count === 1 ? 'player' : 'players'}</span>
        </div>
        <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: var(--space-2);">
          ${list.map(p => this.renderCard(p)).join('')}
        </div>
      </div>
    `;

    container.innerHTML = `
      ${section('🚨 Dues owed · 7+ days past due',           duesOwed.length, '#ef4444', duesOwed)}
      ${section('⚠ Warning · 4–6 days overdue',              warning.length,  '#f97316', warning)}
      ${section('· Nudge · 1–3 days overdue',                nudge.length,    '#fbbf24', nudge)}
    `;
  }

  // Color scale (user directive 2026-07-04):
  //   1–3 yellow · 4–6 orange · 7+ red
  daysOverdueBadgeColor(days) {
    if (days >= 7) return '#ef4444';
    if (days >= 4) return '#f97316';
    if (days >= 1) return '#fbbf24';
    return '#94a3b8';
  }

  renderCard(p) {
    const days = p.daysOverdue || 0;
    const isDuesOwed = p.delinquencyState === 'dues_owed';
    const badgeColor = this.daysOverdueBadgeColor(days);

    const iconBtn = 'width:26px; height:26px; padding:0; font-size:0.75rem; line-height:1; border-radius:4px; border:none; cursor:pointer; text-align:center; text-decoration:none; display:inline-flex; align-items:center; justify-content:center;';

    const greeting = p.firstName ? `Hi ${p.firstName},` : 'Hi,';
    const subject  = `Lighthouse 1893 — dues past due`;
    const emailBody = `${greeting}\n\nYour dues are ${days} day${days === 1 ? '' : 's'} past due.  Please pay via LeagueApps at your earliest convenience — thanks!\n\n— Lighthouse 1893`;
    const smsBody   = `Hi${p.firstName ? ' ' + p.firstName : ''}, your Lighthouse 1893 dues are ${days} day${days === 1 ? '' : 's'} past due.  Please pay via LA — thanks!`;

    const emailHref = p.email
      ? `https://mail.google.com/mail/?${new URLSearchParams({
          view: 'cm', fs: '1', authuser: 'soccer@lighthouse1893.org',
          to: p.email, su: subject, body: emailBody,
        }).toString()}`
      : null;
    const smsHref = p.phone ? `sms:${p.phone}?&body=${encodeURIComponent(smsBody)}` : null;
    const telHref = p.phone ? `tel:${p.phone}` : null;

    // Best-effort LA admin deep link.  The public API can't pause a
    // member (verified 2026-07-04) so admin does it manually in LA.
    // Uses the same LA Manager URL pattern as PaymentsScreen — lands on
    // the memberDetails page where the Pause button lives.
    const laUrl = p.leagueAppsUserId
      ? `https://manager.leagueapps.com/console/sites/41983/memberDetails?memberId=${p.leagueAppsUserId}`
      : null;

    const emailBtn = emailHref ? `<a href="${emailHref}" target="_blank" rel="noopener noreferrer" title="Email ${this.escape(p.email)}" style="${iconBtn} background:#3b82f6; color:#fff;">✉</a>` : '';
    const smsBtn   = smsHref   ? `<a href="${smsHref}" title="Text ${this.escape(this.formatPhone(p.phone))}" style="${iconBtn} background:#10b981; color:#fff;">💬</a>` : '';
    const telBtn   = telHref   ? `<a href="${telHref}" title="Call ${this.escape(this.formatPhone(p.phone))}" style="${iconBtn} background:#6366f1; color:#fff;">📞</a>` : '';
    const laBtn = laUrl ? `<a href="${laUrl}" target="_blank" rel="noopener noreferrer" title="Open in LeagueApps Manager — memberDetails (manual pause)" style="${iconBtn} background:#7c3aed; color:#fff; width:auto; padding: 0 8px; font-size:0.7rem; font-weight:700; letter-spacing:0.04em;">LA →</a>` : '';

    const billingBadge = window.BillingBadge ? window.BillingBadge.render(p) : '';

    const outstanding = (typeof p.outstandingBalance === 'number' && p.outstandingBalance > 0)
      ? `<span style="color:#fbbf24; font-weight:600;">$${p.outstandingBalance} due</span>`
      : `<span style="opacity:0.55;">no balance shown</span>`;

    const lastPaid = (p.lastPaidAt && typeof p.lastPaidAmount === 'number')
      ? `<span style="opacity:0.7;">last paid $${p.lastPaidAmount} · ${new Date(p.lastPaidAt).toLocaleDateString()}</span>`
      : '';

    const cardBorder = isDuesOwed
      ? 'border: 2px solid #ef4444; box-shadow: 0 0 0 1px rgba(239, 68, 68, 0.15) inset;'
      : `border: 1px solid ${badgeColor}55;`;

    const cardBg = isDuesOwed
      ? 'background: linear-gradient(180deg, #431515 0%, #1f2937 60%);'
      : 'background: var(--bg-tertiary, #1f2937);';

    const duesOwedTag = isDuesOwed
      ? `<span style="background:#ef4444; color:#fff; font-size:0.65rem; font-weight:700; letter-spacing:0.06em; padding:2px 6px; border-radius:3px; text-transform:uppercase;">Dues owed</span>`
      : '';

    const regId = p.registrationId;
    const regCopyBtn = regId
      ? `<button class="dq-copy-reg" type="button" data-reg="${regId}" title="Copy registrationId" style="background:transparent; border:1px dashed #64748b; color:#94a3b8; font-family: ui-monospace, monospace; font-size:0.65rem; padding: 1px 6px; border-radius: 3px; cursor:pointer;">#${regId}</button>`
      : '';

    return `
      <div style="${cardBg} ${cardBorder} border-radius: 6px; padding: 10px 12px;">
        <div style="display:flex; align-items:center; gap:8px; margin-bottom:4px;">
          <span style="background:${badgeColor}; color:#111; font-weight:800; font-size:0.75rem; padding: 3px 8px; border-radius: 999px; min-width: 44px; text-align:center;">
            ${days}d
          </span>
          <strong style="flex:1; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; font-size:0.95rem;">${this.escape(p.fullName) || '(no name)'}</strong>
          ${duesOwedTag}
        </div>
        <div style="font-size: 0.75rem; opacity: 0.75; margin-bottom: 6px;">
          Bill due <strong>${this.escape(p.nextBillDate) || '—'}</strong>${p.isDefault ? ' <span style="opacity:0.6;">(default)</span>' : ''} · ${outstanding}
        </div>
        ${lastPaid ? `<div style="font-size: 0.7rem; margin-bottom: 6px;">${lastPaid}</div>` : ''}
        <div style="display:flex; gap:5px; align-items:center; flex-wrap: wrap;">
          ${emailBtn}${smsBtn}${telBtn}${laBtn}
          ${billingBadge}
          ${regCopyBtn}
        </div>
      </div>
    `;
  }

  async _copyReg(btn) {
    const reg = btn.dataset.reg;
    if (!reg) return;
    try {
      await navigator.clipboard.writeText(String(reg));
      const orig = btn.textContent;
      btn.textContent = '✓ copied';
      setTimeout(() => { btn.textContent = orig; }, 1200);
    } catch (_e) { /* clipboard denied — no-op */ }
  }

  formatPhone(raw) {
    if (!raw) return '';
    const digits = String(raw).replace(/\D/g, '');
    const ten = digits.length === 11 && digits.startsWith('1') ? digits.slice(1) : digits;
    if (ten.length === 10) return `(${ten.slice(0, 3)}) ${ten.slice(3, 6)}-${ten.slice(6)}`;
    return raw;
  }

  escape(s) {
    if (s == null) return '';
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }
}
