// MensRosterScreen — Live Men's roster pulled from LeagueApps every page
// load, joined to football-home team assignments (Brazil / Puerto Rico /
// U23 / future APSL / Liga 1 / Liga 2).
//
// Each player card carries one toggle pill per configured column.  Tapping
// a pill saves an assignment (POST /api/mens-roster/assign) and re-renders
// the affected columns.  Pills sharing a `mutexGroup` (e.g. Brazil & PR)
// are at-most-one — adding one removes the other server-side.  A player
// with zero pills lit lives in the leftmost "Unassigned" column.
//
// Columns are DB-driven (mens_team_columns table); to add APSL / Liga 1 /
// Liga 2 later just insert rows there — no code change required.
class MensRosterScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>👨 Men's Roster</h1>
        <p class="subtitle">Live from LeagueApps — assign Brazil / Puerto Rico / U23</p>
      </div>

      <div style="padding: var(--space-4);">
        <div id="mr-banner" style="margin-bottom: var(--space-3); padding: var(--space-3); border-radius: 6px; background: #f1f5f9; border: 1px solid #e2e8f0; display:flex; align-items:center; gap: var(--space-3); flex-wrap: wrap; font-size: 14px;">
          <span id="mr-banner-icon" style="font-size: 16px;">⏳</span>
          <span id="mr-banner-text" style="flex:1; min-width: 200px;">Pulling latest registrations from LeagueApps…</span>
          <button id="mr-refresh" class="btn btn-secondary" style="display:none; padding: 4px 10px; font-size: 13px;">🔄 Refresh</button>
        </div>
        <div id="mr-loading" style="text-align:center; padding: var(--space-6); opacity:0.6;">Loading…</div>
        <div id="mr-error"   style="display:none; color: var(--color-error); padding: var(--space-4); text-align:center;"></div>
        <div id="mr-list"    style="display:none;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter() {
    this.element.addEventListener('click', e => {
      if (e.target.closest('.back-btn')) return this.navigation.goBack();
      if (e.target.closest('#mr-refresh')) return this.load();
      const toggle = e.target.closest('.mr-roster-toggle');
      if (toggle) return this.onRosterToggleClick(toggle);
      const pill = e.target.closest('.mr-pill');
      if (pill) return this.onPillClick(pill);
    });
    // Billing badge click handling (edit + mark-billed) is owned by the
    // shared helper; it re-renders via this.load() on success.
    if (window.BillingBadge) {
      window.BillingBadge.wire(this.element, this.auth.fetch.bind(this.auth), () => this.load());
    }
    this.load();
  }

  setBanner({ icon, text, showRefresh = false }) {
    const i = this.find('#mr-banner-icon');
    const t = this.find('#mr-banner-text');
    const r = this.find('#mr-refresh');
    if (i) i.textContent = icon;
    if (t) t.textContent = text;
    if (r) r.style.display = showRefresh ? '' : 'none';
  }

  async load() {
    const loading = this.find('#mr-loading');
    const errEl   = this.find('#mr-error');
    const list    = this.find('#mr-list');
    if (loading) loading.style.display = '';
    if (errEl)   errEl.style.display   = 'none';
    if (list)    list.style.display    = 'none';
    this.setBanner({ icon: '⏳', text: 'Pulling latest registrations from LeagueApps…' });

    try {
      const t0  = performance.now();
      const res = await this.auth.fetch('/api/mens-roster');
      if (!res.ok) {
        const body = await res.text();
        throw new Error(body.slice(0, 200) || `HTTP ${res.status}`);
      }
      const data = await res.json();
      const elapsed = ((performance.now() - t0) / 1000).toFixed(1);
      this._data = data;

      if (loading) loading.style.display = 'none';
      if (list)    list.style.display    = '';

      this.setBanner({
        icon: '✓',
        text: `${data.total} player${data.total === 1 ? '' : 's'} loaded in ${elapsed}s · ${data.unassignedCount} unassigned`,
        showRefresh: true,
      });
      this.renderRoster(data);
    } catch (err) {
      if (loading) loading.style.display = 'none';
      if (errEl) {
        errEl.style.display = '';
        errEl.textContent = `Failed to load roster: ${err.message}`;
      }
      this.setBanner({
        icon: '✗',
        text: `Could not reach LeagueApps: ${err.message}`,
        showRefresh: true,
      });
    }
  }

  renderRoster(data) {
    const container = this.find('#mr-list');

    // Columns: Unassigned first, then DB-defined columns in sort order.
    const cols = [
      { teamId: 0, label: '📭 Unassigned', color: '#475569', count: data.unassignedCount, isUnassigned: true },
      ...data.columns,
    ];

    container.innerHTML = `
      <div style="display:flex; align-items:center; gap:var(--space-3); flex-wrap:wrap; margin-bottom:var(--space-3); padding:var(--space-2) var(--space-3); background:var(--bg-secondary); border-radius:var(--radius-md);">
        <span style="opacity:0.7; font-size:0.8rem; font-weight:600;">Columns:</span>
        ${cols.map(c => {
          const cap = c.maxRoster != null ? `(${c.count}/${c.maxRoster})` : `(${c.count})`;
          return `
            <span style="display:inline-flex; align-items:center; gap:6px; font-size:0.8rem; padding:2px 8px; border-radius:4px; border-left:3px solid ${c.color};">
              ${c.label} <span style="opacity:0.55;">${cap}</span>
            </span>`;
        }).join('')}
      </div>

      <div style="overflow-x:auto; padding-bottom:var(--space-2);">
        <div style="display:grid; grid-template-columns: repeat(${cols.length}, minmax(${this.colMinWidth(cols.length)}, 1fr)); gap:var(--space-2); align-items:start;">
          ${cols.map(c => this.renderColumn(c, data)).join('')}
        </div>
      </div>
    `;
  }

  // Cards get thinner when there are few columns (lots of room per col) and
  // wider when there are many (so the pills still fit on one row-ish).
  colMinWidth(n) {
    if (n <= 4) return '140px';
    if (n <= 6) return '170px';
    return '200px';
  }

  renderColumn(col, data) {
    const players = col.isUnassigned
      ? data.unassigned
      : (data.buckets[String(col.teamId)] || []);

    let countHtml;
    if (col.maxRoster != null) {
      const overFull = players.length >= col.maxRoster;
      const pct      = col.maxRoster ? players.length / col.maxRoster : 0;
      const nearFull = !overFull && pct >= 0.85;
      const fc = overFull ? '#ef4444' : nearFull ? '#f59e0b' : '#10b981';
      countHtml = `<span style="font-size:0.85rem; font-weight:600; color:${fc};">${players.length}/${col.maxRoster}${overFull ? ' ⚠' : ''}</span>`;
    } else if (!col.isUnassigned && col.onRosterCount != null) {
      const r = col.onRosterCount;
      countHtml = `<span style="font-size:0.85rem;"><span style="color:#34d399; font-weight:600;">${r}</span><span style="opacity:0.6;"> on roster · ${players.length} total</span></span>`;
    } else {
      countHtml = `<span style="opacity:0.6; font-size:0.85rem;">${players.length}</span>`;
    }

    // Split roster vs not-on-roster.  Backend already returns roster
    // players first (alpha), then off-roster (alpha) — we just find the
    // boundary and insert a divider.  Unassigned column has no split.
    const isOnRoster = (p) => col.isUnassigned ? true : !!p.onRoster;
    const onRoster   = players.filter(isOnRoster);
    const offRoster  = players.filter(p => !isOnRoster(p));

    const renderList = (list) => list.map(p => this.renderPlayer(p, data.columns, col)).join('');

    let body;
    if (players.length === 0) {
      body = '<div style="opacity:0.5; font-size:0.85rem;">(empty)</div>';
    } else {
      const divider = offRoster.length > 0 ? `
        <div style="
          margin: var(--space-2) 0 var(--space-1);
          padding: 4px 8px;
          background: #3a1f1f;
          color: #fca5a5;
          font-size: 0.7rem;
          font-weight: 700;
          letter-spacing: 0.06em;
          text-align: center;
          border-radius: 4px;
          border: 1px dashed #b91c1c;
        ">⚠ NOT ON ROSTER (${offRoster.length})</div>` : '';
      body = `${renderList(onRoster)}${divider}${renderList(offRoster)}`;
    }

    return `
      <div style="background:var(--bg-secondary); border-radius:var(--radius-md); padding:8px; border-top:3px solid ${col.color};">
        <div style="display:flex; justify-content:space-between; align-items:baseline; margin-bottom:6px; gap:6px;">
          <strong style="font-size:0.85rem;">${col.label}</strong>
          ${countHtml}
        </div>
        <div style="display:flex; flex-direction:column; gap:6px;">
          ${body}
        </div>
      </div>
    `;
  }

  renderPlayer(p, columns, col) {
    // Dense card: icon-only action buttons, compact pills, single-line meta.
    const iconBtn = 'width:22px; height:22px; padding:0; font-size:0.7rem; line-height:1; border-radius:4px; border:none; cursor:pointer; text-align:center; text-decoration:none; display:inline-flex; align-items:center; justify-content:center;';

    const greeting = p.firstName ? `Hi ${p.firstName},` : 'Hi,';
    const subject  = `Lighthouse 1893 Men's`;
    const emailBody = `${greeting}\n\nThis is your Lighthouse 1893 coach.\n\n`;
    const smsBody   = `Hi${p.firstName ? ' ' + p.firstName : ''}, this is Lighthouse 1893 coach.`;

    const emailHref = p.email
      ? `https://mail.google.com/mail/?${new URLSearchParams({
          view:     'cm',
          fs:       '1',
          authuser: 'soccer@lighthouse1893.org',
          to:       p.email,
          su:       subject,
          body:     emailBody,
        }).toString()}`
      : null;
    const smsHref = p.phone
      ? `sms:${p.phone}?&body=${encodeURIComponent(smsBody)}`
      : null;
    const telHref = p.phone ? `tel:${p.phone}` : null;

    // Full DOB on a separate compact line (e.g. "3/10/2008").
    let dobShort = '';
    if (p.birthDate) {
      const d = new Date(`${p.birthDate}T00:00:00Z`);
      dobShort = isNaN(d.getTime())
        ? p.birthDate
        : d.toLocaleDateString('en-US', { month: 'numeric', day: 'numeric', year: 'numeric', timeZone: 'UTC' });
    }

    // Tiny payment dot — green=paid, amber=balance, hide otherwise.
    let payDot = '';
    if (p.paymentStatus) {
      const dotColor = p.paymentStatus === 'PAID' ? '#34d399' : '#fbbf24';
      const tip = `${p.paymentStatus}${p.outstandingBalance > 0 ? ` ($${p.outstandingBalance} due)` : ''}`;
      payDot = `<span title="${tip}" style="display:inline-block; width:8px; height:8px; border-radius:50%; background:${dotColor}; flex-shrink:0;"></span>`;
    }

    const emailBtn = emailHref ? `<a href="${emailHref}" target="_blank" rel="noopener noreferrer" title="${this.escape(p.email)}" style="${iconBtn} background:#3b82f6; color:#fff;">✉</a>` : '';
    const smsBtn   = smsHref   ? `<a href="${smsHref}"   title="Text" style="${iconBtn} background:#10b981; color:#fff;">💬</a>` : '';
    const telBtn   = telHref   ? `<a href="${telHref}"   title="${this.escape(this.formatPhone(p.phone))}" style="${iconBtn} background:#6366f1; color:#fff;">📞</a>` : '';

    const billingBadge = window.BillingBadge ? window.BillingBadge.render(p) : '';

    const assignedSet = new Set(p.teamIds || []);
    const pills = columns.map(c => {
      const on = assignedSet.has(c.teamId);
      const style = on
        ? `background:${c.color}; color:#fff; border:1.5px solid ${c.color}; box-shadow:0 0 0 1px rgba(255,255,255,0.15) inset;`
        : `background:transparent; color:${c.color}; border:1px dashed ${c.color}; opacity:0.55;`;
      const short = this.escape(c.shortLabel || c.label || '');
      return `<button class="mr-pill" type="button"
                      data-user-id="${p.leagueAppsUserId}"
                      data-team-id="${c.teamId}"
                      data-action="${on ? 'remove' : 'add'}"
                      title="${on ? 'Remove from' : 'Add to'} ${this.escape(c.label)}"
                      style="padding:1px 6px; border-radius:999px; font-size:0.7rem; font-weight:600; line-height:1.3; cursor:pointer; white-space:nowrap; ${style}">
                ${on ? '✓ ' : ''}${short}
              </button>`;
    }).join('');

    const cardId = `mr-card-${p.leagueAppsUserId}`;

    // Per-column on-roster toggle: small, clearly green-filled when on.
    let rosterToggle = '';
    if (col && !col.isUnassigned) {
      const on = !!p.onRoster;
      const tStyle = on
        ? `background:#16a34a; color:#fff; border:1px solid #16a34a;`
        : `background:transparent; color:#fca5a5; border:1px dashed #b91c1c;`;
      rosterToggle = `
        <button class="mr-roster-toggle" type="button"
                data-user-id="${p.leagueAppsUserId}"
                data-team-id="${col.teamId}"
                data-on-roster="${on ? '1' : '0'}"
                title="${on ? 'Remove from roster' : 'Add to roster'}"
                style="padding:2px 6px; font-size:0.65rem; font-weight:700; border-radius:4px; cursor:pointer; letter-spacing:0.04em; line-height:1.3; ${tStyle}">
          ${on ? '✓ ROSTER' : '○ NOT ON ROSTER'}
        </button>`;
    }

    return `
      <div id="${cardId}" style="background:var(--bg-tertiary, #1f2937); border-radius:4px; padding:5px 6px; font-size:0.75rem; line-height:1.3;">
        <div style="display:flex; align-items:center; gap:5px; min-width:0;">
          ${payDot}
          <strong style="font-size:0.8rem; flex:1; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${this.escape(p.fullName) || '(no name)'}</strong>
        </div>
        ${dobShort ? `<div style="font-size:0.65rem; opacity:0.6; margin-top:1px;">🎂 ${this.escape(dobShort)}</div>` : ''}
        <div style="display:flex; gap:3px; margin-top:4px; align-items:center; flex-wrap:wrap;">
          ${emailBtn}${smsBtn}${telBtn}
          ${rosterToggle}
          ${billingBadge}
        </div>
        <div style="display:flex; gap:3px; margin-top:3px; flex-wrap:wrap;">${pills}</div>
      </div>
    `;
  }

  // Pulls the leading emoji + 1 short word from labels like "🇧🇷 Brazil"
  // → "🇧🇷 Brazil" stays short already; trims long names.
  shortLabel(label) {
    if (!label) return '';
    if (label.length <= 14) return this.escape(label);
    return this.escape(label.slice(0, 12)) + '…';
  }

  async onPillClick(btn) {
    const userId = parseInt(btn.dataset.userId, 10);
    const teamId = parseInt(btn.dataset.teamId, 10);
    const action = btn.dataset.action;
    if (!userId || !teamId || !action) return;

    btn.disabled = true;
    btn.style.opacity = '0.4';
    try {
      const res = await this.auth.fetch('/api/mens-roster/assign', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ leagueAppsUserId: userId, teamId, action }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      // Easiest correct re-render: full reload (cheap — 53 records).
      await this.load();
    } catch (err) {
      btn.disabled = false;
      btn.style.opacity = '';
      alert(`Could not save assignment: ${err.message}`);
    }
  }

  async onRosterToggleClick(btn) {
    const userId   = parseInt(btn.dataset.userId, 10);
    const teamId   = parseInt(btn.dataset.teamId, 10);
    const current  = btn.dataset.onRoster === '1';
    if (!userId || !teamId) return;

    btn.disabled = true;
    btn.style.opacity = '0.4';
    try {
      const res = await this.auth.fetch('/api/mens-roster/roster-status', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({
          leagueAppsUserId: userId,
          teamId,
          onRoster: !current,
        }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      await this.load();
    } catch (err) {
      btn.disabled = false;
      btn.style.opacity = '';
      alert(`Could not update roster status: ${err.message}`);
    }
  }

  // ── helpers ─────────────────────────────────────────────────────────
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
