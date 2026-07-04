// PaymentsScreen — LeagueApps financial view per program.
//
// Two views:
//   • Members (default) — one card per current LA member on the program,
//     joined with the "what have you done for me lately?" window
//     (current + previous calendar month).  Status badge, lifetime totals,
//     inline recent txns, action buttons.  Sorted so the operator's work
//     queue (never-paid / overdue) lands at the top.
//   • Transactions — the raw ledger, DESC by paid_at.
//
// Four program tabs: Mens / Womens / Boys / Girls (each hits its own
// endpoint pair — /api/payments/:program/members and /api/payments/:program).
//
// Every load calls the backend which itself calls LaProgramSync +
// PersonPayments::syncFromLa so we mirror LA on every page hit.
class PaymentsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.tab  = 'mens';                     // program tab
    this.view = 'members';                  // view mode: members / transactions / queue
    this.search = '';
    // Status filter for the Members view.  '' = All; otherwise one of
    // 'current' | 'behind' | 'overdue' | 'never'.  Cards are rendered
    // grouped by status so the operator can spot "who owes me" without
    // scrolling; the chips let them narrow to a single status.
    this.statusFilter = '';
    // Members-view state
    this.membersByTab       = { mens: null, womens: null, boys: null, girls: null };
    this.membersLoadingByTab= { mens: false, womens: false, boys: false, girls: false };
    this.membersErrorByTab  = { mens: null, womens: null, boys: null, girls: null };
    // Transactions-view state (existing raw ledger)
    this.txnsByTab          = { mens: null, womens: null, boys: null, girls: null };
    this.txnsLoadingByTab   = { mens: false, womens: false, boys: false, girls: false };
    this.txnsErrorByTab     = { mens: null, womens: null, boys: null, girls: null };
    // Charge-flag queue state (Phase 2).  Keyed by tab (program) so the
    // per-tab dashboards stay independent.  `pendingByLaUserId[tab]` is
    // used to badge existing pending flags on the Members view.
    this.flagsByTab            = { mens: null, womens: null, boys: null, girls: null };
    this.flagsLoadingByTab     = { mens: false, womens: false, boys: false, girls: false };
    this.flagsErrorByTab       = { mens: null, womens: null, boys: null, girls: null };
    this.pendingByLaUserIdByTab= { mens: {}, womens: {}, boys: {}, girls: {} };
    // Map tab → LA program id.  Populated from members-endpoint responses
    // (they include `programId`); needed by the Flag-for-Charge modal and
    // the queue loader when the operator hasn't loaded the Members view yet.
    this.programIdByTab        = { mens: null, womens: null, boys: null, girls: null };
    // La site id for building deep links to Manager (fallback in case env
    // isn't reflected).  Hardcoded here as a UI-only value; the backend
    // canonical is LEAGUEAPPS_SITE_ID.
    this.laSiteId = 41983;
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>💳 Payments</h1>
        <p class="subtitle">Full LeagueApps financials — synced on every load</p>
      </div>

      <div style="padding: var(--space-4); max-width: 1400px; margin: 0 auto;">
        <div id="pay-tabs" role="tablist"
             style="display:flex; gap:var(--space-2); border-bottom:2px solid var(--border-color, #334155); margin-bottom: var(--space-3); flex-wrap:wrap;">
        </div>

        <div style="display:flex; gap:var(--space-2); margin-bottom: var(--space-3);">
          <button id="view-members"     class="pay-view" data-view="members"
                  style="padding:6px 14px; border-radius:6px; cursor:pointer; font-weight:700; font-size:0.85rem;">
            👥 Members
          </button>
          <button id="view-transactions" class="pay-view" data-view="transactions"
                  style="padding:6px 14px; border-radius:6px; cursor:pointer; font-weight:700; font-size:0.85rem;">
            🧾 Transactions
          </button>
          <button id="view-queue" class="pay-view" data-view="queue"
                  style="padding:6px 14px; border-radius:6px; cursor:pointer; font-weight:700; font-size:0.85rem;">
            🚩 Charge Queue
          </button>
        </div>

        <div id="pay-summary"
             style="display:flex; gap:var(--space-4); flex-wrap:wrap;
                    padding: var(--space-3);
                    background: var(--bg-tertiary, #1f2937);
                    border: 1px solid var(--border-color, #374151);
                    border-radius: 6px; margin-bottom: var(--space-3);
                    font-size: 0.85rem;">
        </div>

        <div id="pay-status-chips" style="display:none; margin-bottom: var(--space-3);
             flex-wrap:wrap; gap: var(--space-1);"></div>

        <div style="margin-bottom: var(--space-3);">
          <input id="pay-search" type="text" placeholder="🔎 Filter by name, gateway, type, id…"
                 style="width:100%; padding: 8px 12px; border-radius: 6px;
                        border: 1px solid var(--border-color, #374151);
                        background: var(--bg-secondary, #111827);
                        color: var(--fg, #e5e7eb); font-size: 0.9rem;">
        </div>

        <div id="pay-status" style="text-align:center; padding: var(--space-4); opacity:0.6;">Loading…</div>
        <div id="pay-error"  style="display:none; color: var(--color-error, #ef4444); padding: var(--space-3); text-align:center;"></div>

        <!-- Members view -->
        <div id="pay-members" style="display:none;"></div>

        <!-- Charge-flag queue view (Phase 2) -->
        <div id="pay-queue" style="display:none;"></div>

        <!-- Transactions view (raw ledger) -->
        <div id="pay-table-wrap" style="display:none; overflow:auto; border:1px solid var(--border-color, #374151); border-radius:6px;">
          <table id="pay-table" style="width:100%; border-collapse:collapse; font-size:0.8rem; font-variant-numeric: tabular-nums;">
            <thead style="background: var(--bg-tertiary, #1f2937); position:sticky; top:0; z-index:1;">
              <tr>
                <th style="text-align:left;  padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Date</th>
                <th style="text-align:left;  padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Payer</th>
                <th style="text-align:right; padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Amount</th>
                <th style="text-align:right; padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Net</th>
                <th style="text-align:left;  padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Type</th>
                <th style="text-align:left;  padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Gateway</th>
                <th style="text-align:right; padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Reg&nbsp;ID</th>
                <th style="text-align:right; padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Txn&nbsp;ID</th>
              </tr>
            </thead>
            <tbody id="pay-tbody"></tbody>
          </table>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    // Deep-link support: admin-club Financials tiles pass initialTab and
    // optional initialView.
    if (params) {
      if (['mens','womens','boys','girls'].includes(params.initialTab)) {
        this.tab = params.initialTab;
      }
      if (['members','transactions'].includes(params.initialView)) {
        this.view = params.initialView;
      }
    }
    this.find('#pay-tabs').innerHTML = this.renderTabsMarkup();
    this.paintViewButtons();

    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) return this.navigation.goBack();
      const tabBtn = e.target.closest('.pay-tab');
      if (tabBtn) return this.switchTab(tabBtn.dataset.tab);
      const viewBtn = e.target.closest('.pay-view');
      if (viewBtn) return this.switchView(viewBtn.dataset.view);
      const openLa = e.target.closest('[data-open-la-user]');
      if (openLa) {
        const uid = openLa.getAttribute('data-open-la-user');
        window.open(`https://manager.leagueapps.com/console/sites/${this.laSiteId}/memberDetails?memberId=${uid}`, '_blank');
        return;
      }
      const flagBtn = e.target.closest('[data-flag-la-user]');
      if (flagBtn) {
        const uid  = flagBtn.getAttribute('data-flag-la-user');
        const name = flagBtn.getAttribute('data-flag-name') || '';
        this.openFlagModal(uid, name);
        return;
      }
      const ranBtn = e.target.closest('[data-resolve-flag]');
      if (ranBtn) {
        const id     = ranBtn.getAttribute('data-resolve-flag');
        const status = ranBtn.getAttribute('data-status') || 'ran';
        this.resolveFlag(id, status);
        return;
      }
      const statusChip = e.target.closest('[data-status-chip]');
      if (statusChip) {
        const s = statusChip.getAttribute('data-status-chip');
        this.statusFilter = (s === 'all') ? '' : s;
        this.rerender();
        return;
      }
    });
    const search = this.find('#pay-search');
    if (search) {
      search.addEventListener('input', (e) => {
        this.search = e.target.value.trim().toLowerCase();
        this.rerender();
      });
    }
    this.loadCurrent();
  }

  // ── Program tabs ────────────────────────────────────────────────────
  renderTabBtn(key, label) {
    const active = this.tab === key;
    const style = active
      ? 'background:#0ea5e9; color:#fff; border:1px solid #0ea5e9;'
      : 'background:transparent; color:var(--fg, #e5e7eb); border:1px solid var(--border-color, #374151);';
    return `
      <button class="pay-tab" data-tab="${key}"
              style="padding:8px 14px; border-radius:6px 6px 0 0; cursor:pointer;
                     font-weight:700; font-size:0.9rem; ${style}">
        ${label}
      </button>
    `;
  }

  renderTabsMarkup() {
    const labels = {
      mens:   '👨 Mens',
      womens: '👩 Womens',
      boys:   '👦 Boys',
      girls:  '👧 Girls',
    };
    return ['mens','womens','boys','girls']
      .map((k) => this.renderTabBtn(k, labels[k]))
      .join('');
  }

  switchTab(key) {
    if (!key || this.tab === key) return;
    this.tab = key;
    this.find('#pay-tabs').innerHTML = this.renderTabsMarkup();
    this.loadCurrent();
  }

  // ── View mode (Members vs Transactions) ─────────────────────────────
  paintViewButtons() {
    const paint = (id, isActive) => {
      const el = this.find('#' + id);
      if (!el) return;
      el.style.background = isActive ? '#0ea5e9' : 'transparent';
      el.style.color      = isActive ? '#fff' : 'var(--fg, #e5e7eb)';
      el.style.border     = isActive ? '1px solid #0ea5e9' : '1px solid var(--border-color, #374151)';
    };
    paint('view-members',      this.view === 'members');
    paint('view-transactions', this.view === 'transactions');
    paint('view-queue',        this.view === 'queue');
  }

  switchView(view) {
    if (!view || this.view === view) return;
    this.view = view;
    this.paintViewButtons();
    this.loadCurrent();
  }

  // ── Loader dispatch ─────────────────────────────────────────────────
  loadCurrent() {
    if (this.view === 'members')      return this.loadMembers(this.tab);
    if (this.view === 'transactions') return this.loadTransactions(this.tab);
    if (this.view === 'queue')        return this.loadFlags(this.tab);
  }

  rerender() {
    if (this.view === 'members')      return this.renderMembers();
    if (this.view === 'transactions') return this.renderTransactions();
    if (this.view === 'queue')        return this.renderQueue();
  }

  showStatus(text) {
    const s = this.find('#pay-status');
    const e = this.find('#pay-error');
    const m = this.find('#pay-members');
    const w = this.find('#pay-table-wrap');
    const q = this.find('#pay-queue');
    if (s) { s.style.display = ''; s.textContent = text; }
    if (e) e.style.display = 'none';
    if (m) m.style.display = 'none';
    if (w) w.style.display = 'none';
    if (q) q.style.display = 'none';
  }

  showError(msg) {
    const s = this.find('#pay-status');
    const e = this.find('#pay-error');
    const m = this.find('#pay-members');
    const w = this.find('#pay-table-wrap');
    const q = this.find('#pay-queue');
    if (s) s.style.display = 'none';
    if (m) m.style.display = 'none';
    if (w) w.style.display = 'none';
    if (q) q.style.display = 'none';
    if (e) { e.style.display = ''; e.textContent = `Failed to load: ${msg}`; }
  }

  // ── Members view ────────────────────────────────────────────────────
  async loadMembers(key) {
    if (this.membersByTab[key]) {
      this.renderMembers();
    } else {
      this.showStatus('Loading members…');
    }
    if (this.membersLoadingByTab[key]) return;
    this.membersLoadingByTab[key] = true;
    this.membersErrorByTab[key] = null;
    try {
      const res = await this.auth.fetch(`/api/payments/${key}/members`);
      if (!res.ok) {
        const body = await res.text();
        throw new Error(body.slice(0, 200) || `HTTP ${res.status}`);
      }
      const data = await res.json();
      this.membersByTab[key] = data;
      if (data && data.programId) {
        this.programIdByTab[key] = data.programId;
      }
      // Fetch current pending flags in parallel so we can badge cards.
      this.loadFlags(key, /*silent=*/true);
      if (this.tab === key && this.view === 'members') this.renderMembers();
    } catch (err) {
      this.membersErrorByTab[key] = err.message;
      if (this.tab === key && this.view === 'members') this.showError(err.message);
    } finally {
      this.membersLoadingByTab[key] = false;
    }
  }

  renderMembers() {
    const data = this.membersByTab[this.tab];
    if (!data) {
      const err = this.membersErrorByTab[this.tab];
      if (err) return this.showError(err);
      return this.showStatus('Loading members…');
    }
    const s = this.find('#pay-status');
    const e = this.find('#pay-error');
    const m = this.find('#pay-members');
    const w = this.find('#pay-table-wrap');
    const qv = this.find('#pay-queue');
    const chipsEl = this.find('#pay-status-chips');
    if (s) s.style.display = 'none';
    if (e) e.style.display = 'none';
    if (w) w.style.display = 'none';
    if (qv) qv.style.display = 'none';
    if (m) m.style.display = '';

    // Summary strip
    const c = data.counts || {};
    this.find('#pay-summary').innerHTML = `
      <div><span style="opacity:0.7;">Members:</span> <span style="font-weight:700;">${data.total ?? 0}</span></div>
      <div><span style="opacity:0.7;">🟢 Current:</span> <span style="font-weight:700; color:#86efac;">${c.current || 0}</span></div>
      <div><span style="opacity:0.7;">🟡 Behind:</span> <span style="font-weight:700; color:#fbbf24;">${c.behind || 0}</span></div>
      <div><span style="opacity:0.7;">🔴 Overdue:</span> <span style="font-weight:700; color:#fca5a5;">${c.overdue || 0}</span></div>
      <div><span style="opacity:0.7;">⚫ Never paid:</span> <span style="font-weight:700; color:#e5e7eb;">${c.never || 0}</span></div>
      <div style="margin-left:auto;"><span style="opacity:0.7;">Needs attention:</span>
           <span style="font-weight:700; color:#fca5a5;">${data.needsAttention ?? 0}</span></div>
    `;

    // Status filter chips.  Same shape as the members-screen category
    // chips: pill buttons with counts, the active one filled with the
    // primary color.  "All" leaves the grouped view intact; a specific
    // status hides the other groups.
    if (chipsEl) {
      const chip = (id, text, count, active) => `
        <button data-status-chip="${id}"
                style="padding:6px 12px; border-radius:999px; cursor:pointer;
                       font-weight:600; font-size:0.85rem;
                       border:1px solid var(--border-color, #374151);
                       background:${active ? '#0ea5e9' : 'transparent'};
                       color:${active ? '#fff' : 'var(--fg, #e5e7eb)'};">
          ${text} <span style="opacity:0.7; font-weight:400;">(${count})</span>
        </button>`;
      const total = data.total ?? 0;
      chipsEl.innerHTML = [
        chip('all',     'All',         total,          !this.statusFilter),
        chip('overdue', '🔴 Overdue',  c.overdue || 0, this.statusFilter === 'overdue'),
        chip('never',   '⚫ Never Paid', c.never || 0, this.statusFilter === 'never'),
        chip('behind',  '🟡 Behind',   c.behind || 0,  this.statusFilter === 'behind'),
        chip('current', '🟢 Paid Up',  c.current || 0, this.statusFilter === 'current'),
      ].join(' ');
      chipsEl.style.display = 'flex';
    }

    // Search + optional status filter.
    const q = this.search;
    const rows = (data.members || []).filter((mm) => {
      if (this.statusFilter && mm.status !== this.statusFilter) return false;
      if (!q) return true;
      const hay = [mm.firstName, mm.lastName, mm.status, String(mm.laUserId || ''),
                   mm.email, mm.phone, mm.dob]
        .filter(Boolean).join(' ').toLowerCase();
      return hay.includes(q);
    });

    if (rows.length === 0) {
      m.innerHTML = `
        <div style="padding: 20px; text-align:center; opacity:0.6; border:1px dashed var(--border-color, #374151); border-radius:6px;">
          ${data.members && data.members.length ? 'No members match this filter.' : 'No members on this program yet.'}
        </div>`;
      return;
    }

    // Group by status.  Work-queue order first: overdue → never → behind
    // → current.  A chip filter collapses to the single group.
    const statusOrder = ['overdue', 'never', 'behind', 'current'];
    const statusMeta = {
      overdue: { icon:'🔴', label:'Overdue',    color:'#fca5a5' },
      never:   { icon:'⚫', label:'Never Paid', color:'#e5e7eb' },
      behind:  { icon:'🟡', label:'Behind',     color:'#fbbf24' },
      current: { icon:'🟢', label:'Paid Up',    color:'#86efac' },
    };
    const byStatus = {};
    for (const st of statusOrder) byStatus[st] = [];
    const other = [];
    for (const row of rows) {
      if (byStatus[row.status]) byStatus[row.status].push(row);
      else other.push(row);
    }

    const groupHtml = (st) => {
      const list = byStatus[st] || [];
      if (list.length === 0) return '';
      const meta = statusMeta[st];
      return `
        <section style="margin-bottom: var(--space-5);">
          <h3 style="margin:0 0 var(--space-2); color:${meta.color};">
            ${meta.icon} ${meta.label}
            <span style="opacity:0.6; font-weight:400; font-size:0.85rem;">(${list.length})</span>
          </h3>
          <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: var(--space-3);">
            ${list.map((mm) => this.renderMemberCard(mm)).join('')}
          </div>
        </section>
      `;
    };

    const otherHtml = other.length
      ? `
        <section style="margin-bottom: var(--space-5);">
          <h3 style="margin:0 0 var(--space-2); opacity:0.8;">
            ❓ Unknown status
            <span style="opacity:0.6; font-weight:400; font-size:0.85rem;">(${other.length})</span>
          </h3>
          <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: var(--space-3);">
            ${other.map((mm) => this.renderMemberCard(mm)).join('')}
          </div>
        </section>`
      : '';

    m.innerHTML = statusOrder.map(groupHtml).join('') + otherHtml;
  }

  renderMemberCard(m) {
    const badge = this.renderStatusBadge(m.status);
    const name  = `${this.escape(m.firstName || '')} ${this.escape(m.lastName || '')}`.trim() || '—';
    const lastLine = m.lastPaidAt
      ? `Last: ${this.fmtMoney(m.lastAmount)} · ${this.fmtDate(m.lastPaidAt)}`
      : `<span style="color:#fca5a5;">No payments on record</span>`;

    // Contact line — DOB + age, primary email, primary phone.
    const dobLine = m.dob
      ? `<div style="font-size:0.75rem; opacity:0.7;">🎂 ${this.fmtDob(m.dob)}</div>`
      : '';
    const contactBits = [];
    if (m.email) {
      contactBits.push(`<span style="opacity:0.85;">✉️ ${this.escape(m.email)}</span>`);
    }
    if (m.phone) {
      contactBits.push(`<span style="opacity:0.85;">📱 ${this.escape(this.fmtPhone(m.phone))}</span>`);
    }
    const contactLine = contactBits.length
      ? `<div style="font-size:0.75rem; display:flex; flex-wrap:wrap; gap:8px;">${contactBits.join('')}</div>`
      : '';

    const recent = m.recentTransactions || [];
    const recentHtml = recent.length
      ? recent.map((t) => `
          <div style="display:flex; justify-content:space-between; gap:8px; padding:2px 0;">
            <span style="opacity:0.7; white-space:nowrap;">${this.fmtDate(t.paidAt)}</span>
            <span style="font-weight:700; color:${t.txnType && t.txnType.includes('Refund') ? '#fca5a5' : '#86efac'};">
              ${t.txnType && t.txnType.includes('Refund') ? '−' : ''}${this.fmtMoney(t.amount)}
            </span>
            <span style="opacity:0.6; font-size:0.7rem;">${this.escape(t.txnType || '')}</span>
          </div>
        `).join('')
      : `<div style="opacity:0.5; font-style:italic;">No payments in current or previous month</div>`;

    const laBtn = m.laUserId
      ? `<button data-open-la-user="${m.laUserId}"
                 style="padding:6px 10px; border-radius:4px; cursor:pointer;
                        background:#1e3a8a; color:#dbeafe; border:1px solid #3b82f6;
                        font-size:0.75rem; font-weight:700;">🔗 Open in LA</button>`
      : '';

    // Contact action buttons — mailto / sms / tel.  SMS + Call only appear
    // when the phone row is flagged to receive that channel.
    const contactBtns = [];
    if (m.email) {
      contactBtns.push(
        `<a href="mailto:${this.escape(m.email)}"
             style="padding:6px 10px; border-radius:4px; text-decoration:none;
                    background:#0b3a2e; color:#a7f3d0; border:1px solid #10b981;
                    font-size:0.75rem; font-weight:700;">✉️ Email</a>`
      );
    }
    const phoneDigits = m.phone ? this.digits(m.phone) : '';
    if (phoneDigits && m.phoneSms !== false) {
      contactBtns.push(
        `<a href="sms:${phoneDigits}"
             style="padding:6px 10px; border-radius:4px; text-decoration:none;
                    background:#3a2e05; color:#fde68a; border:1px solid #d97706;
                    font-size:0.75rem; font-weight:700;">💬 Text</a>`
      );
    }
    if (phoneDigits && m.phoneCall !== false) {
      contactBtns.push(
        `<a href="tel:${phoneDigits}"
             style="padding:6px 10px; border-radius:4px; text-decoration:none;
                    background:#1f2937; color:#e5e7eb; border:1px solid #4b5563;
                    font-size:0.75rem; font-weight:700;">📞 Call</a>`
      );
    }

    // Flag-for-Charge button — disabled+badged if a pending flag already
    // exists for this LA user on this program.
    const pendingMap = this.pendingByLaUserIdByTab[this.tab] || {};
    const pending    = m.laUserId ? pendingMap[String(m.laUserId)] : null;
    const flagBtn = m.laUserId
      ? (pending
          ? `<span title="Flag id ${pending.id}"
                   style="padding:6px 10px; border-radius:4px;
                          background:#3a2e05; color:#fbbf24; border:1px solid #d97706;
                          font-size:0.75rem; font-weight:700;">
              🚩 Pending ${this.fmtMoney(pending.amount)}
             </span>`
          : `<button data-flag-la-user="${m.laUserId}"
                     data-flag-name="${this.escape((m.firstName||'') + ' ' + (m.lastName||''))}"
                     style="padding:6px 10px; border-radius:4px; cursor:pointer;
                            background:#3a1f1f; color:#fca5a5; border:1px solid #b91c1c;
                            font-size:0.75rem; font-weight:700;">🚩 Flag for Charge</button>`)
      : '';

    return `
      <div style="background: var(--bg-secondary, #111827); border:1px solid var(--border-color, #374151);
                  border-radius:8px; padding:12px 14px; display:flex; flex-direction:column; gap:8px;">
        <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:8px;">
          <div style="font-weight:700; font-size:1rem;">${name}</div>
          ${badge}
        </div>
        ${dobLine}
        ${contactLine}
        <div style="font-size:0.8rem; opacity:0.85;">${lastLine}</div>
        <div style="font-size:0.75rem; opacity:0.7;">
          Lifetime: ${this.fmtMoney(m.totalPaid || 0)}
          ${m.totalRefunded ? ` · refunded ${this.fmtMoney(m.totalRefunded)}` : ''}
          · ${m.txnCount || 0} payment${m.txnCount === 1 ? '' : 's'}
        </div>
        <div style="border-top:1px dashed var(--border-color, #374151); padding-top:6px;
                    font-size:0.75rem; display:flex; flex-direction:column; gap:2px;">
          <div style="opacity:0.6; font-size:0.7rem; text-transform:uppercase; letter-spacing:0.5px;">
            Recent (this month + last)
          </div>
          ${recentHtml}
        </div>
        <div style="display:flex; gap:6px; margin-top:4px; flex-wrap:wrap;">${laBtn}${contactBtns.join('')}${flagBtn}</div>
      </div>
    `;
  }

  renderStatusBadge(status) {
    let icon, label, bg, fg;
    switch (status) {
      case 'current': icon='🟢'; label='Current'; bg='#052e1a'; fg='#86efac'; break;
      case 'behind':  icon='🟡'; label='Behind';  bg='#3a2e05'; fg='#fbbf24'; break;
      case 'overdue': icon='🔴'; label='Overdue'; bg='#3a1f1f'; fg='#fca5a5'; break;
      case 'never':   icon='⚫'; label='Never paid'; bg='#1f2937'; fg='#e5e7eb'; break;
      default:        icon='❓'; label=status || '—'; bg='#1f2937'; fg='#cbd5e1';
    }
    return `<span style="display:inline-block; padding:3px 8px; font-size:0.7rem; font-weight:700;
                          border-radius:4px; background:${bg}; color:${fg}; white-space:nowrap;">
              ${icon} ${label}
            </span>`;
  }

  // ── Transactions view (raw ledger — pre-existing behaviour) ─────────
  async loadTransactions(key) {
    if (this.txnsByTab[key]) {
      this.renderTransactions();
    } else {
      this.showStatus('Loading transactions…');
    }
    if (this.txnsLoadingByTab[key]) return;
    this.txnsLoadingByTab[key] = true;
    this.txnsErrorByTab[key] = null;
    try {
      const res = await this.auth.fetch(`/api/payments/${key}`);
      if (!res.ok) {
        const body = await res.text();
        throw new Error(body.slice(0, 200) || `HTTP ${res.status}`);
      }
      const data = await res.json();
      this.txnsByTab[key] = data;
      if (this.tab === key && this.view === 'transactions') this.renderTransactions();
    } catch (err) {
      this.txnsErrorByTab[key] = err.message;
      if (this.tab === key && this.view === 'transactions') this.showError(err.message);
    } finally {
      this.txnsLoadingByTab[key] = false;
    }
  }

  renderTransactions() {
    const data = this.txnsByTab[this.tab];
    if (!data) {
      const err = this.txnsErrorByTab[this.tab];
      if (err) return this.showError(err);
      return this.showStatus('Loading transactions…');
    }
    const s = this.find('#pay-status');
    const e = this.find('#pay-error');
    const m = this.find('#pay-members');
    const w = this.find('#pay-table-wrap');
    const qv = this.find('#pay-queue');
    const chipsEl = this.find('#pay-status-chips');
    if (s) s.style.display = 'none';
    if (e) e.style.display = 'none';
    if (m) m.style.display = 'none';
    if (qv) qv.style.display = 'none';
    if (chipsEl) chipsEl.style.display = 'none';
    if (w) w.style.display = '';

    this.find('#pay-summary').innerHTML = `
      <div><span style="opacity:0.7;">Program:</span> <span style="font-weight:700;">${this.escape(data.programName || '—')}</span></div>
      <div><span style="opacity:0.7;">Payments:</span> <span style="font-weight:700;">${data.total ?? 0}</span></div>
      <div><span style="opacity:0.7;">Gross:</span> <span style="font-weight:700; color:#86efac;">${this.fmtMoney(data.totalPositive || 0)}</span></div>
      <div><span style="opacity:0.7;">Refunds:</span> <span style="font-weight:700; color:#fca5a5;">${this.fmtMoney(data.totalRefunds || 0)}</span></div>
    `;

    const q = this.search;
    const filter = (p) => {
      if (!q) return true;
      const hay = [
        p.firstName, p.lastName, p.gateway, p.txnType,
        p.programName,
        String(p.transactionId || ''), String(p.registrationId || ''),
        String(p.invoiceId || ''), String(p.userId || ''),
      ].filter(Boolean).join(' ').toLowerCase();
      return hay.includes(q);
    };
    const rows = (data.payments || []).filter(filter);
    const tbody = this.find('#pay-tbody');
    if (rows.length === 0) {
      tbody.innerHTML = `
        <tr><td colspan="8" style="padding: 20px; text-align:center; opacity:0.6;">
          ${data.payments && data.payments.length ? 'No payments match this filter.' : 'No payments recorded yet.'}
        </td></tr>`;
      return;
    }
    tbody.innerHTML = rows.map((p) => this.renderTxnRow(p)).join('');
  }

  renderTxnRow(p) {
    const isRefund = p.txnType === 'Refund' || p.txnType === 'Partial Refund';
    const amountColour = isRefund ? '#fca5a5' : '#e5e7eb';
    const amountSign = isRefund ? '−' : '';
    const name = `${this.escape(p.firstName || '')} ${this.escape(p.lastName || '')}`.trim() || '—';
    return `
      <tr style="border-bottom:1px solid var(--border-color, #374151);">
        <td style="padding:6px 10px; white-space:nowrap;">${this.fmtDate(p.paidAt)}</td>
        <td style="padding:6px 10px;">${name}</td>
        <td style="padding:6px 10px; text-align:right; color:${amountColour}; font-weight:700;">${amountSign}${this.fmtMoney(p.amount)}</td>
        <td style="padding:6px 10px; text-align:right; opacity:0.85;">${p.netAmount == null ? '—' : this.fmtMoney(p.netAmount)}</td>
        <td style="padding:6px 10px;">${this.renderTypePill(p.txnType)}</td>
        <td style="padding:6px 10px; opacity:0.85;">${this.escape(p.gateway || '')}</td>
        <td style="padding:6px 10px; text-align:right; opacity:0.7;">${p.registrationId || ''}</td>
        <td style="padding:6px 10px; text-align:right; opacity:0.7;">${p.transactionId || ''}</td>
      </tr>
    `;
  }

  renderTypePill(t) {
    if (!t) return '';
    let bg, fg;
    switch (t) {
      case 'Charge':          bg = '#052e1a'; fg = '#86efac'; break;
      case 'Bank':            bg = '#0c2c3f'; fg = '#7dd3fc'; break;
      case 'Offline Payment': bg = '#1e293b'; fg = '#cbd5e1'; break;
      case 'Refund':
      case 'Partial Refund':  bg = '#3a1f1f'; fg = '#fca5a5'; break;
      default:                bg = '#1f2937'; fg = '#cbd5e1'; break;
    }
    return `<span style="display:inline-block; padding:2px 8px; font-size:0.7rem; font-weight:700;
                          border-radius:4px; background:${bg}; color:${fg};">${this.escape(t)}</span>`;
  }

  // ── Charge-flag queue (Phase 2) ─────────────────────────────────────
  async loadFlags(key, silent = false) {
    const programId = this.programIdByTab[key];
    // If we don't know the programId yet, we must piggyback on the
    // Members endpoint (which returns it).  Members loader triggers us
    // silently after it has that id, so this path only hits if the queue
    // tab is opened first.  In that case load members quietly.
    if (!programId) {
      if (!this.membersByTab[key] && !this.membersLoadingByTab[key]) {
        await this.loadMembers(key);
      }
      const pid = this.programIdByTab[key];
      if (!pid) {
        this.flagsErrorByTab[key] = 'Program id unknown — try Members tab first.';
        if (!silent && this.tab === key && this.view === 'queue') {
          this.showError(this.flagsErrorByTab[key]);
        }
        return;
      }
    }
    const pid = this.programIdByTab[key];
    if (!silent && !this.flagsByTab[key]) {
      this.showStatus('Loading charge queue…');
    }
    if (this.flagsLoadingByTab[key]) return;
    this.flagsLoadingByTab[key] = true;
    this.flagsErrorByTab[key] = null;
    try {
      const res = await this.auth.fetch(`/api/charge-flags?program=${pid}`);
      if (!res.ok) {
        const body = await res.text();
        throw new Error(body.slice(0, 200) || `HTTP ${res.status}`);
      }
      const data = await res.json();
      this.flagsByTab[key] = data;
      // Rebuild the pending-by-user map (used to badge Members cards).
      const map = {};
      for (const f of (data.flags || [])) {
        if (f.status === 'pending' && f.laUserId) map[String(f.laUserId)] = f;
      }
      this.pendingByLaUserIdByTab[key] = map;
      if (this.tab === key) {
        if (this.view === 'queue')   this.renderQueue();
        if (this.view === 'members') this.renderMembers();  // repaint badges
      }
    } catch (err) {
      this.flagsErrorByTab[key] = err.message;
      if (!silent && this.tab === key && this.view === 'queue') {
        this.showError(err.message);
      }
    } finally {
      this.flagsLoadingByTab[key] = false;
    }
  }

  renderQueue() {
    const data = this.flagsByTab[this.tab];
    if (!data) {
      const err = this.flagsErrorByTab[this.tab];
      if (err) return this.showError(err);
      return this.showStatus('Loading charge queue…');
    }
    const s  = this.find('#pay-status');
    const e  = this.find('#pay-error');
    const m  = this.find('#pay-members');
    const w  = this.find('#pay-table-wrap');
    const qv = this.find('#pay-queue');
    const chipsEl = this.find('#pay-status-chips');
    if (s) s.style.display = 'none';
    if (e) e.style.display = 'none';
    if (m) m.style.display = 'none';
    if (w) w.style.display = 'none';
    if (chipsEl) chipsEl.style.display = 'none';
    if (qv) qv.style.display = '';

    const c = data.counts || {};
    this.find('#pay-summary').innerHTML = `
      <div><span style="opacity:0.7;">🚩 Pending:</span>
           <span style="font-weight:700; color:#fca5a5;">${c.pending || 0}</span></div>
      <div><span style="opacity:0.7;">Pending total:</span>
           <span style="font-weight:700; color:#fca5a5;">${this.fmtMoney(data.totalPending || 0)}</span></div>
      <div><span style="opacity:0.7;">✅ Ran:</span>
           <span style="font-weight:700; color:#86efac;">${c.ran || 0}</span></div>
      <div><span style="opacity:0.7;">🚫 Canceled:</span>
           <span style="font-weight:700; opacity:0.7;">${c.canceled || 0}</span></div>
    `;

    const q = this.search;
    const rows = (data.flags || []).filter((f) => {
      if (!q) return true;
      const hay = [f.firstName, f.lastName, f.reason, f.status, String(f.laUserId || '')]
        .filter(Boolean).join(' ').toLowerCase();
      return hay.includes(q);
    });
    if (rows.length === 0) {
      qv.innerHTML = `
        <div style="padding: 20px; text-align:center; opacity:0.6;
                    border:1px dashed var(--border-color, #374151); border-radius:6px;">
          ${data.flags && data.flags.length
              ? 'No flags match this filter.'
              : 'No flags yet. Flag a member from the Members view to add one.'}
        </div>`;
      return;
    }
    qv.innerHTML = `
      <div style="overflow:auto; border:1px solid var(--border-color, #374151); border-radius:6px;">
        <table style="width:100%; border-collapse:collapse; font-size:0.85rem; font-variant-numeric: tabular-nums;">
          <thead style="background: var(--bg-tertiary, #1f2937); position:sticky; top:0; z-index:1;">
            <tr>
              <th style="text-align:left;  padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Status</th>
              <th style="text-align:left;  padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Member</th>
              <th style="text-align:right; padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Amount</th>
              <th style="text-align:left;  padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Reason</th>
              <th style="text-align:left;  padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Created</th>
              <th style="text-align:left;  padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Resolved</th>
              <th style="text-align:left;  padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">Actions</th>
            </tr>
          </thead>
          <tbody>
            ${rows.map((f) => this.renderFlagRow(f)).join('')}
          </tbody>
        </table>
      </div>
    `;
  }

  renderFlagRow(f) {
    const name = `${this.escape(f.firstName || '')} ${this.escape(f.lastName || '')}`.trim()
              || `LA #${f.laUserId}`;
    const statusPill = this.renderFlagStatusPill(f.status);
    const actions = f.status === 'pending'
      ? `
        <button data-open-la-user="${f.laUserId}"
                style="padding:4px 8px; border-radius:4px; cursor:pointer;
                       background:#1e3a8a; color:#dbeafe; border:1px solid #3b82f6;
                       font-size:0.7rem; font-weight:700; margin-right:4px;">🔗 LA</button>
        <button data-resolve-flag="${f.id}" data-status="ran"
                style="padding:4px 8px; border-radius:4px; cursor:pointer;
                       background:#052e1a; color:#86efac; border:1px solid #16a34a;
                       font-size:0.7rem; font-weight:700; margin-right:4px;">✅ Ran</button>
        <button data-resolve-flag="${f.id}" data-status="canceled"
                style="padding:4px 8px; border-radius:4px; cursor:pointer;
                       background:#1f2937; color:#cbd5e1; border:1px solid #4b5563;
                       font-size:0.7rem; font-weight:700;">🚫 Cancel</button>`
      : (f.resolvedNote
          ? `<span style="opacity:0.7; font-size:0.75rem;">${this.escape(f.resolvedNote)}</span>`
          : '');
    return `
      <tr style="border-bottom:1px solid var(--border-color, #374151);">
        <td style="padding:6px 10px;">${statusPill}</td>
        <td style="padding:6px 10px;">${name}</td>
        <td style="padding:6px 10px; text-align:right; font-weight:700;">${this.fmtMoney(f.amount)}</td>
        <td style="padding:6px 10px; opacity:0.85;">${this.escape(f.reason || '')}</td>
        <td style="padding:6px 10px; white-space:nowrap; opacity:0.75;">${this.fmtDate(f.createdAt)}</td>
        <td style="padding:6px 10px; white-space:nowrap; opacity:0.75;">${f.resolvedAt ? this.fmtDate(f.resolvedAt) : '—'}</td>
        <td style="padding:6px 10px;">${actions}</td>
      </tr>
    `;
  }

  renderFlagStatusPill(status) {
    let icon, label, bg, fg;
    switch (status) {
      case 'pending':  icon='🚩'; label='Pending';  bg='#3a1f1f'; fg='#fca5a5'; break;
      case 'ran':      icon='✅'; label='Ran';      bg='#052e1a'; fg='#86efac'; break;
      case 'canceled': icon='🚫'; label='Canceled'; bg='#1f2937'; fg='#9ca3af'; break;
      default:         icon='❓'; label=status || '—'; bg='#1f2937'; fg='#cbd5e1';
    }
    return `<span style="display:inline-block; padding:3px 8px; font-size:0.7rem; font-weight:700;
                          border-radius:4px; background:${bg}; color:${fg}; white-space:nowrap;">
              ${icon} ${label}
            </span>`;
  }

  // ── Flag actions ────────────────────────────────────────────────────
  async openFlagModal(laUserId, name) {
    const programId = this.programIdByTab[this.tab];
    if (!programId) {
      alert('Program id not loaded — reload the Members view first.');
      return;
    }
    // MVP: two native prompts.  Cheap, keyboard-friendly, no CSS needed.
    // (Can upgrade to <dialog> later without touching backend.)
    const amtStr = window.prompt(
      `Flag ${name.trim() || 'this member'} for charge.\n\nAmount in dollars (e.g. 35 or 17.50):`,
      '35'
    );
    if (amtStr == null) return;                          // cancelled
    const amount = Number(String(amtStr).replace(/[^0-9.]/g, ''));
    if (!isFinite(amount) || amount <= 0) {
      alert('Invalid amount.');
      return;
    }
    const reason = window.prompt('Reason / note (optional):', '') || '';

    try {
      const res = await this.auth.fetch('/api/charge-flags', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          laUserId:    Number(laUserId),
          laProgramId: Number(programId),
          amount,
          reason,
        }),
      });
      if (res.status === 409) {
        alert('A pending flag already exists for this member.');
        return;
      }
      if (!res.ok) {
        const body = await res.text();
        throw new Error(body.slice(0, 200) || `HTTP ${res.status}`);
      }
      // Refresh flags for this tab; repaints Members badges too.
      this.flagsByTab[this.tab] = null;
      await this.loadFlags(this.tab, /*silent=*/true);
    } catch (err) {
      alert('Failed to flag: ' + err.message);
    }
  }

  async resolveFlag(id, status) {
    let note = '';
    if (status === 'ran') {
      const n = window.prompt('Note (optional): how did you run this charge?', '');
      if (n == null) return;
      note = n;
    } else if (status === 'canceled') {
      if (!window.confirm('Cancel this charge flag?')) return;
    }
    try {
      const res = await this.auth.fetch(`/api/charge-flags/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status, note }),
      });
      if (!res.ok) {
        const body = await res.text();
        throw new Error(body.slice(0, 200) || `HTTP ${res.status}`);
      }
      // Refresh + repaint.
      this.flagsByTab[this.tab] = null;
      await this.loadFlags(this.tab, /*silent=*/true);
      if (this.view === 'queue') this.renderQueue();
    } catch (err) {
      alert('Failed to update flag: ' + err.message);
    }
  }

  // ── Formatters ──────────────────────────────────────────────────────
  fmtMoney(v) {
    const n = Number(v);
    if (!isFinite(n)) return '$?';
    return `$${n.toFixed(2)}`;
  }

  fmtDate(iso) {
    if (!iso) return '—';
    const d = new Date(iso);
    if (isNaN(d.getTime())) return this.escape(iso);
    const y = d.getUTCFullYear();
    const m = d.getUTCMonth() + 1;
    const day = d.getUTCDate();
    return `${m}/${day}/${y}`;
  }

  // Format a birth date (YYYY-MM-DD, no timezone) and append the age in
  // full years, computed against today.  Non-parseable input falls back
  // to escaped raw text.
  fmtDob(ymd) {
    if (!ymd) return '—';
    const s = String(ymd);
    const mtch = s.match(/^(\d{4})-(\d{2})-(\d{2})/);
    if (!mtch) return this.escape(s);
    const y  = Number(mtch[1]);
    const mo = Number(mtch[2]);
    const d  = Number(mtch[3]);
    const now = new Date();
    let age = now.getUTCFullYear() - y;
    const m2 = now.getUTCMonth() + 1;
    const d2 = now.getUTCDate();
    if (m2 < mo || (m2 === mo && d2 < d)) age -= 1;
    return `${mo}/${d}/${y} (age ${age})`;
  }

  // Digits only for tel:/sms: hrefs.
  digits(s) {
    return String(s || '').replace(/\D+/g, '');
  }

  // Pretty US format when it's exactly 10 digits (or 11 with leading 1);
  // otherwise return the input as-is.
  fmtPhone(s) {
    const d = this.digits(s);
    if (d.length === 10) {
      return `(${d.slice(0,3)}) ${d.slice(3,6)}-${d.slice(6)}`;
    }
    if (d.length === 11 && d.startsWith('1')) {
      return `+1 (${d.slice(1,4)}) ${d.slice(4,7)}-${d.slice(7)}`;
    }
    return s;
  }

  escape(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;')
      .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }
}
