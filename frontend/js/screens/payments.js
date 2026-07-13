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
    this.tab  = 'all';                      // program tab ('all' aggregates the 4 categories)
    this.view = 'members';                  // view mode: members / transactions / queue
    this.search = '';
    // Program-variant modifier that pairs with `this.tab` when the
    // operator picked a specific Program chip.  `null` = category
    // row is active (or 'all').  `'club'` = the Club variant for
    // `this.tab` is selected.  (Pickup is disabled for now.)
    this._programVariant = null;
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
        <div id="pay-all-programs"
             style="display:flex; gap:var(--space-3); flex-wrap:wrap;
                    padding: var(--space-3);
                    background: linear-gradient(90deg, rgba(14,165,233,0.08), rgba(14,165,233,0.02));
                    border: 1px solid rgba(14,165,233,0.4);
                    border-radius: 6px; margin-bottom: var(--space-3);
                    font-size: 0.85rem;">
          <div style="opacity:0.7;">🌐 <b>All Programs</b> — loading…</div>
        </div>

        <!-- Standardized filter chip rows (FilterBar): category / program / status.
             Replaces the old pay-tabs tab bar + inline status-chip row so the
             Payments screen shares styling and behaviour with Members. -->
        <div id="pay-filters" style="margin-bottom: var(--space-3);"></div>

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

        <div id="pay-status-chips" style="display:none;"></div>

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
      if (['all','mens','womens','boys','girls'].includes(params.initialTab)) {
        this.tab = params.initialTab;
      }
      if (['members','transactions','queue'].includes(params.initialView)) {
        this.view = params.initialView;
      }
    }
    this._buildFilterBar();
    this.paintViewButtons();

    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) return this.navigation.goBack();
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
      const pauseBtn = e.target.closest('[data-copy-pause]');
      if (pauseBtn) {
        // Copy the standard "initial-registration not paid" warning to
        // the clipboard with the player's first name inlined.  Operator
        // then clicks 🔗 Open in LA and pastes it into LA's Remind flow.
        const first = pauseBtn.getAttribute('data-copy-pause') || 'Player';
        const msg = `${first}, you have not made initial registration payment. We have to move you to a paused membership which makes you ineligible for practice and games until paid.`;
        this._copyToClipboard(msg, `Pause warning for ${first} copied — now click 🔗 Open in LA and paste into Remind.`);
        return;
      }
      const ranBtn = e.target.closest('[data-resolve-flag]');
      if (ranBtn) {
        const id     = ranBtn.getAttribute('data-resolve-flag');
        const status = ranBtn.getAttribute('data-status') || 'ran';
        this.resolveFlag(id, status);
        return;
      }
      // Card body → open the universal PersonScreen.  Guard against
      // clicks on the inline action buttons and anchors above so their
      // handlers stay in charge.
      const anchorInside = e.target.closest('a, button, input, textarea, select, label');
      if (anchorInside) return;
      const card = e.target.closest('.pay-member-card[data-la-user-id]');
      if (card) {
        const laUid = card.getAttribute('data-la-user-id');
        if (laUid) {
          // Snapshot current view state (tab + view + search) into the
          // /payments browser history entry BEFORE pushing /person.
          // Person's Back uses window.history.back() rather than
          // navigation.goTo — see PersonScreen._goBack() for the
          // rationale.  Without this snapshot, back-nav would land us
          // on payments with the initial-entry params instead of
          // whatever tab/search the operator was on.
          this._snapshotHistoryState();
          this.navigation.goTo('person', {
            leagueAppsUserId: laUid,
            returnTo: 'payments',
          });
        }
        return;
      }
      // (Category / program / status chip clicks are handled by the
      // shared FilterBar component — see `_buildFilterBar` below.)
    });
    const search = this.find('#pay-search');
    if (search) {
      search.addEventListener('input', (e) => {
        this.search = e.target.value.trim().toLowerCase();
        this.rerender();
      });
    }
    this.loadCurrent();
    // Kick off the other three program tabs in the background so the
    // "All Programs" roll-up bar at the top can render totals across all
    // four Mens / Womens / Boys / Girls without the operator having to
    // click each tab.  Silent = no spinner takeover on the current view.
    this._loadAllProgramsInBackground();
  }

  _loadAllProgramsInBackground() {
    for (const k of ['mens','womens','boys','girls']) {
      if (this.membersByTab[k] || this.membersLoadingByTab[k]) continue;
      // loadMembers already re-renders the "All Programs" bar via
      // renderMembers() → _renderAllProgramsBar() when it lands.
      this.loadMembers(k);
    }
  }

  // ── Program / category / status filters (FilterBar) ─────────────────
  // Payments mirrors the Members screen's filter layout via the shared
  // `FilterBar` component: three rows (category / program / status) so
  // an admin can slice the ledger the same way they slice membership.
  //
  // Row 1 — Category  [💰 All] [👨 Mens] [👩 Womens] [👦 Boys] [👧 Girls]
  //         Radio; mutually exclusive with the program row.  Selecting
  //         a category loads the corresponding LA program (or, for
  //         'all', aggregates the four background-loaded ones).
  //
  // Row 2 — Program   [👨 Mens Club Payments] [👨 Mens Pickup Payments] …
  //         Radio; mutually exclusive with the category row.  Pickup
  //         chips are DISABLED for now — pickup is free, so there's no
  //         ledger to show.  Rendered anyway so the visual parity with
  //         Members holds; when we start charging for pickup we flip
  //         the `disabled` flag and add the endpoint.
  //
  // Row 3 — Status    [All] [🔴 Overdue] [⚫ Never Paid] [🟡 Behind] [🟢 Paid Up]
  //         Radio; narrows the Members list to a single status band.
  //         Counts come from whatever data the current tab has loaded.
  _buildFilterBar() {
    const host = this.find('#pay-filters');
    if (!host) return;

    // ── Row 1: Category chips ──
    const categoryChips = [
      { id: 'all',    label: '💰 All'    },
      { id: 'mens',   label: '👨 Mens'   },
      { id: 'womens', label: '👩 Womens' },
      { id: 'boys',   label: '👦 Boys'   },
      { id: 'girls',  label: '👧 Girls'  },
    ];

    // ── Row 2: Program chips (Club + Pickup per category) ──
    // Pickup is disabled until we charge for it — but we render the
    // chip so admins see the future shape of the filter.
    const emoji = (cat) => ({ mens:'👨', womens:'👩', boys:'👦', girls:'👧' }[cat] || '💰');
    const clubLabel   = (cat) => `${emoji(cat)} ${this._titleCase(cat)} Club Payments`;
    const pickupLabel = (cat) => `${emoji(cat)} ${this._titleCase(cat)} Pickup Payments`;
    const programChips = [];
    for (const cat of ['mens','womens','boys','girls']) {
      programChips.push({ id: `${cat}-club`,   label: clubLabel(cat)   });
      programChips.push({
        id:       `${cat}-pickup`,
        label:    pickupLabel(cat),
        disabled: true,   // Pickup is free — no charges to show yet.
      });
    }

    // ── Row 3: Status chips (Members-view only) ──
    // Counts come from the currently selected tab's data (or from the
    // aggregated all-tab data when 'all' is selected).  Rebuilt on
    // every setRows() call so numbers stay live.
    const c = this._activeCounts();
    const statusChips = [
      { id: 'all',     label: 'All',            count: this._activeTotal() },
      { id: 'overdue', label: '🔴 Overdue',    count: c.overdue || 0 },
      { id: 'never',   label: '⚫ Never Paid', count: c.never   || 0 },
      { id: 'behind',  label: '🟡 Behind',     count: c.behind  || 0 },
      { id: 'current', label: '🟢 Paid Up',    count: c.current || 0 },
    ];

    // Category-row selection reflects the current tab; program-row
    // selection reflects the current tab when a Club variant is
    // implicitly chosen (pickup is disabled so program-selected can
    // only be `<cat>-club`).  When the category row is set to
    // anything, the program row is cleared, and vice-versa.
    const categorySelected = this._catSelectedId();
    const programSelected  = (this.tab !== 'all' && this._programVariant === 'club')
                             ? `${this.tab}-club` : null;
    const statusSelected   = this.statusFilter || 'all';

    if (!this._filterBar) {
      this._filterBar = new FilterBar({ host });
    }
    this._filterBar.setRows([
      {
        name: 'category',
        chips: categoryChips,
        selected: categorySelected,
        clears: ['program'],
        onSelect: (id) => {
          if (id == null || id === 'all') {
            this.tab = 'all';
            this._programVariant = null;
          } else {
            this.tab = id;
            this._programVariant = null;
          }
          this.loadCurrent();
        },
      },
      {
        name: 'program',
        chips: programChips,
        selected: programSelected,
        clears: ['category'],
        onSelect: (id) => {
          if (id == null) {
            // Toggle-off → fall back to "All".
            this.tab = 'all';
            this._programVariant = null;
            this.loadCurrent();
            return;
          }
          const [cat, variant] = id.split('-');
          if (variant === 'pickup') return; // safety — chip is disabled
          this.tab = cat;
          this._programVariant = 'club';
          this.loadCurrent();
        },
      },
      {
        name: 'status',
        chips: statusChips,
        selected: statusSelected,
        onSelect: (id) => {
          this.statusFilter = (id === 'all' || id == null) ? '' : id;
          this.rerender();
        },
      },
    ]);
  }

  // Returns the id of the category chip that should render as selected
  // given the current tab.  `null` means the whole row is cleared
  // (never happens for Payments — we always have a tab).
  _catSelectedId() {
    // If a specific Club program is chosen, the category row is
    // cleared (mutual exclusion with the program row).
    if (this._programVariant === 'club') return null;
    return this.tab || 'all';
  }

  _titleCase(s) {
    if (!s) return '';
    return s.charAt(0).toUpperCase() + s.slice(1);
  }

  // Counts used to label the status chips.  For 'all' we sum the four
  // per-tab counts (background-loaded); for a specific tab we use its
  // own counts.
  _activeCounts() {
    if (this.tab !== 'all') {
      const d = this.membersByTab[this.tab];
      return (d && d.counts) || {};
    }
    const combined = { current: 0, behind: 0, overdue: 0, never: 0 };
    for (const k of ['mens','womens','boys','girls']) {
      const d = this.membersByTab[k];
      if (!d || !d.counts) continue;
      combined.current += d.counts.current || 0;
      combined.behind  += d.counts.behind  || 0;
      combined.overdue += d.counts.overdue || 0;
      combined.never   += d.counts.never   || 0;
    }
    return combined;
  }

  _activeTotal() {
    if (this.tab !== 'all') {
      const d = this.membersByTab[this.tab];
      return (d && d.total) || 0;
    }
    let n = 0;
    for (const k of ['mens','womens','boys','girls']) {
      const d = this.membersByTab[k];
      if (d && d.total) n += d.total;
    }
    return n;
  }

  // ── 'All' aggregation helpers ───────────────────────────────────────
  // Combine the four per-category payloads (mens/womens/boys/girls) that
  // were loaded in the background into one payload with the same shape
  // as a single-program response.  Returns null if none of the four have
  // landed yet, so the caller keeps showing the loader.  Concatenates
  // members/flags/payments lists and sums counts/totals.

  _aggregatedMembers() {
    const shards = ['mens','womens','boys','girls']
      .map((k) => this.membersByTab[k]).filter(Boolean);
    if (!shards.length) return null;
    const out = {
      programId:   null,
      programName: 'All Programs',
      total:       0,
      counts:      { current: 0, behind: 0, overdue: 0, never: 0 },
      members:     [],
      // Fields needed by _summarize().  Concatenating recentPayments
      // gives a naive "who paid recently across all programs" list;
      // gathering money numbers by sum is correct because the
      // per-program values are additive.
      totalCollected:  0,
      totalRefunds:    0,
      recentPayments:  [],
    };
    for (const d of shards) {
      out.total += (d.total || 0);
      for (const k of ['current','behind','overdue','never']) {
        out.counts[k] += (d.counts?.[k] || 0);
      }
      if (Array.isArray(d.members)) out.members.push(...d.members);
      out.totalCollected += (d.totalCollected || 0);
      out.totalRefunds   += (d.totalRefunds   || 0);
      if (Array.isArray(d.recentPayments)) out.recentPayments.push(...d.recentPayments);
    }
    return out;
  }

  _aggregatedTxns() {
    const shards = ['mens','womens','boys','girls']
      .map((k) => this.txnsByTab[k]).filter(Boolean);
    if (!shards.length) return null;
    const out = {
      programName:   'All Programs',
      total:         0,
      totalPositive: 0,
      totalRefunds:  0,
      payments:      [],
    };
    for (const d of shards) {
      out.total         += (d.total         || 0);
      out.totalPositive += (d.totalPositive || 0);
      out.totalRefunds  += (d.totalRefunds  || 0);
      if (Array.isArray(d.payments)) out.payments.push(...d.payments);
    }
    // Newest first so the aggregate ledger still reads DESC by date.
    out.payments.sort((a, b) => {
      const at = String(a.paidAt || a.paid_at || '');
      const bt = String(b.paidAt || b.paid_at || '');
      return bt.localeCompare(at);
    });
    return out;
  }

  _aggregatedFlags() {
    const shards = ['mens','womens','boys','girls']
      .map((k) => this.flagsByTab[k]).filter(Boolean);
    if (!shards.length) return null;
    const out = {
      counts:       { pending: 0, ran: 0, canceled: 0 },
      totalPending: 0,
      flags:        [],
    };
    for (const d of shards) {
      out.counts.pending  += (d.counts?.pending  || 0);
      out.counts.ran      += (d.counts?.ran      || 0);
      out.counts.canceled += (d.counts?.canceled || 0);
      out.totalPending    += (d.totalPending || 0);
      if (Array.isArray(d.flags)) out.flags.push(...d.flags);
    }
    return out;
  }

  // First non-null value from a { mens, womens, boys, girls } bag.
  _firstError(bag) {
    for (const k of ['mens','womens','boys','girls']) {
      if (bag[k]) return bag[k];
    }
    return null;
  }

  switchTab(key) {
    if (!key || this.tab === key) return;
    this.tab = key;
    this._programVariant = null;
    this._buildFilterBar();
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
    // "All" is a client-side aggregation: kick off the four
    // per-category loads (each idempotent — reuses cached data) and
    // render whenever the last one lands.  Rendering is safe even
    // before every tab finishes: aggregate() just uses whatever is in
    // membersByTab / txnsByTab / flagsByTab at render time.
    if (this.tab === 'all') {
      for (const k of ['mens','womens','boys','girls']) {
        if (this.view === 'members')      this.loadMembers(k);
        if (this.view === 'transactions') this.loadTransactions(k);
        if (this.view === 'queue')        this.loadFlags(k);
      }
      this.rerender();
      return;
    }
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
      if ((this.tab === key || this.tab === 'all') && this.view === 'members') this.renderMembers();
      // Always refresh the All-Programs roll-up bar — even for tabs
      // loaded in the background (see _loadAllProgramsInBackground) so
      // totals accumulate as each program's data lands.
      this._renderAllProgramsBar();
    } catch (err) {
      this.membersErrorByTab[key] = err.message;
      if ((this.tab === key || this.tab === 'all') && this.view === 'members') this.showError(err.message);
    } finally {
      this.membersLoadingByTab[key] = false;
    }
  }

  renderMembers() {
    // When 'all' is selected, aggregate the four background-loaded
    // tabs.  If none have landed yet, keep showing the loader.
    const data = (this.tab === 'all')
      ? this._aggregatedMembers()
      : this.membersByTab[this.tab];
    if (!data) {
      const err = (this.tab === 'all')
        ? this._firstError(this.membersErrorByTab)
        : this.membersErrorByTab[this.tab];
      if (err) return this.showError(err);
      return this.showStatus('Loading members…');
    }
    const s = this.find('#pay-status');
    const e = this.find('#pay-error');
    const m = this.find('#pay-members');
    const w = this.find('#pay-table-wrap');
    const qv = this.find('#pay-queue');
    if (s) s.style.display = 'none';
    if (e) e.style.display = 'none';
    if (w) w.style.display = 'none';
    if (qv) qv.style.display = 'none';
    if (m) m.style.display = '';

    // Summary strip
    const c = data.counts || {};
    const fin = this._summarize(data);
    this.find('#pay-summary').innerHTML = `
      <div><span style="opacity:0.7;">Members:</span> <span style="font-weight:700;">${data.total ?? 0}</span></div>
      <div><span style="opacity:0.7;">🟢 Current:</span> <span style="font-weight:700; color:#86efac;">${c.current || 0}</span></div>
      <div><span style="opacity:0.7;">🟡 Behind:</span> <span style="font-weight:700; color:#fbbf24;">${c.behind || 0}</span></div>
      <div><span style="opacity:0.7;">🔴 Overdue:</span> <span style="font-weight:700; color:#fca5a5;">${c.overdue || 0}</span></div>
      <div><span style="opacity:0.7;">⚫ Never paid:</span> <span style="font-weight:700; color:#e5e7eb;">${c.never || 0}</span></div>
      <div style="flex-basis:100%; height:0;"></div>
      <div><span style="opacity:0.7;">💰 Collected:</span> <span style="font-weight:700; color:#86efac;">${this.fmtMoney(fin.netCollected)}</span></div>
      <div><span style="opacity:0.7;">This Month:</span> <span style="font-weight:700; color:#86efac;">${this.fmtMoney(fin.thisMonth)}</span></div>
      <div><span style="opacity:0.7;">Avg / Month:</span> <span style="font-weight:700;">${this.fmtMoney(fin.avgPerMonth)}</span>${fin.monthsElapsed ? `<span style="opacity:0.5; font-size:0.75rem;"> (${fin.monthsElapsed} mo)</span>` : ''}</div>
      <div style="flex-basis:100%; height:0;"></div>
      <div><span style="opacity:0.7;">🔴 Outstanding:</span>
           <span style="font-weight:700; color:#fca5a5;">${fin.outstandingCount} member${fin.outstandingCount === 1 ? '' : 's'}</span></div>
      <div title="Outstanding × est. per-member fee (median of paid members: ${this.fmtMoney(fin.estFeePerMember)})">
        <span style="opacity:0.7;">Est. Owed:</span>
        <span style="font-weight:700; color:#fca5a5;">~${this.fmtMoney(fin.outstandingTotal)}</span></div>
      <div title="Estimated outstanding ÷ months elapsed">
        <span style="opacity:0.7;">Est. Owed / Month:</span>
        <span style="font-weight:700; color:#fca5a5;">~${this.fmtMoney(fin.outstandingPerMonth)}</span></div>
      <div style="opacity:0.55; font-size:0.72rem; margin-left:auto; align-self:center;">
        est. fee = median of paid: ${this.fmtMoney(fin.estFeePerMember)}
      </div>
    `;

    // Refresh the cross-program roll-up whenever a tab finishes loading.
    this._renderAllProgramsBar();

    // Rebuild the FilterBar so status-chip counts reflect the latest
    // data (works for both single-tab and 'all' aggregation modes).
    this._buildFilterBar();

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
    // Section headers are full-width bars, colour-coded by status so the
    // operator can visually chunk the list at a glance.
    //   • fg      — text/icon colour (readable on the tinted bar)
    //   • bg      — subtle tinted background for the bar itself
    //   • border  — accent line on the left edge
    const statusOrder = ['overdue', 'never', 'behind', 'current'];
    const statusMeta = {
      overdue: { icon:'🔴', label:'OVERDUE',    fg:'#7f1d1d', bg:'#fee2e2', border:'#dc2626' },
      never:   { icon:'⚫', label:'NEVER PAID', fg:'#1f2937', bg:'#e5e7eb', border:'#4b5563' },
      behind:  { icon:'🟡', label:'BEHIND',     fg:'#78350f', bg:'#fef3c7', border:'#d97706' },
      current: { icon:'🟢', label:'CURRENT',    fg:'#14532d', bg:'#dcfce7', border:'#16a34a' },
    };
    const byStatus = {};
    for (const st of statusOrder) byStatus[st] = [];
    const other = [];
    for (const row of rows) {
      if (byStatus[row.status]) byStatus[row.status].push(row);
      else other.push(row);
    }

    // Full-width section bar — bold status label on the left, count
    // pill on the right, coloured stripe on the left edge.
    const sectionBar = (meta, count) => `
      <div style="
        display:flex; align-items:center; justify-content:space-between;
        gap:var(--space-3);
        background:${meta.bg}; color:${meta.fg};
        border-left:6px solid ${meta.border};
        border-radius: var(--radius-md, 8px);
        padding: var(--space-3) var(--space-4);
        margin: var(--space-4) 0 var(--space-3);
        box-shadow: 0 1px 2px rgba(0,0,0,0.04);
      ">
        <div style="display:flex; align-items:center; gap:var(--space-2);
                    font-weight:800; font-size:1.05rem; letter-spacing:0.06em;">
          <span style="font-size:1.25rem; line-height:1;">${meta.icon}</span>
          <span>${meta.label}</span>
        </div>
        <span style="
          background:${meta.border}; color:#fff;
          padding: 2px 10px; border-radius: 999px;
          font-weight:700; font-size:0.85rem;
        ">${count}</span>
      </div>
    `;

    const groupHtml = (st) => {
      const list = byStatus[st] || [];
      if (list.length === 0) return '';
      const meta = statusMeta[st];
      return `
        <section style="margin-bottom: var(--space-5);">
          ${sectionBar(meta, list.length)}
          <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: var(--space-3);">
            ${list.map((mm) => this.renderMemberCard(mm)).join('')}
          </div>
        </section>
      `;
    };

    const otherHtml = other.length
      ? `
        <section style="margin-bottom: var(--space-5);">
          ${sectionBar({ icon:'❓', label:'UNKNOWN STATUS',
                         fg:'#1f2937', bg:'#f3f4f6', border:'#9ca3af' }, other.length)}
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

    // Copy-Pause-Warning button — copies the standard "not paid initial
    // registration → paused membership" reminder with the player's first
    // name pre-filled.  Operator flow: click here, then click 🔗 Open in
    // LA and paste into LA's Remind textarea.  Shown for every card so
    // the operator can decide when it applies (typically "never paid").
    const pauseBtn = `<button data-copy-pause="${this.escape(m.firstName || 'Player')}"
                              title="Copy pause-membership warning with ${this.escape(m.firstName || 'the player')}'s name pre-filled"
                              style="padding:6px 10px; border-radius:4px; cursor:pointer;
                                     background:#3a2e05; color:#fde68a; border:1px solid #d97706;
                                     font-size:0.75rem; font-weight:700;">📋 Copy Pause Warning</button>`;

    return `
      <div class="pay-member-card"
           data-la-user-id="${m.laUserId || ''}"
           style="background: var(--bg-secondary, #111827); border:1px solid var(--border-color, #374151);
                  border-radius:8px; padding:12px 14px; display:flex; flex-direction:column; gap:8px;
                  ${m.laUserId ? 'cursor:pointer;' : ''}">
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
        <div style="display:flex; gap:6px; margin-top:4px; flex-wrap:wrap;">${laBtn}${contactBtns.join('')}${pauseBtn}${flagBtn}</div>
      </div>
    `;
  }

  // Copy `text` to the clipboard and show a small toast with `successMsg`.
  // Falls back to a hidden textarea + execCommand('copy') on older
  // browsers / non-secure contexts where navigator.clipboard is missing.
  _copyToClipboard(text, successMsg) {
    if (!text) return;
    const done  = () => this._toast(successMsg || 'Copied');
    const fail  = () => this._fallbackCopy(text, successMsg);
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(done).catch(fail);
    } else {
      fail();
    }
  }

  _fallbackCopy(text, successMsg) {
    const ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.left = '-9999px';
    document.body.appendChild(ta);
    ta.select();
    try {
      document.execCommand('copy');
      this._toast(successMsg || 'Copied');
    } catch (e) {
      alert('Copy failed — the message was:\n\n' + text);
    } finally {
      ta.remove();
    }
  }

  _toast(msg) {
    // Cheap, no-dep toast pinned near the top-right.  Self-clears after 3s.
    if (!msg) return;
    let host = document.getElementById('pay-toast-host');
    if (!host) {
      host = document.createElement('div');
      host.id = 'pay-toast-host';
      host.style.cssText = 'position:fixed; top:16px; right:16px; z-index:9999; display:flex; flex-direction:column; gap:8px; max-width:min(420px, calc(100vw - 32px));';
      document.body.appendChild(host);
    }
    const t = document.createElement('div');
    t.textContent = msg;
    t.style.cssText = 'background:#0f172a; color:#e5e7eb; border:1px solid #d97706; border-radius:6px; padding:10px 14px; box-shadow:0 4px 14px rgba(0,0,0,0.35); font-size:0.85rem; line-height:1.35; opacity:0; transition:opacity 0.15s ease-in;';
    host.appendChild(t);
    requestAnimationFrame(() => { t.style.opacity = '1'; });
    setTimeout(() => {
      t.style.opacity = '0';
      setTimeout(() => t.remove(), 200);
    }, 3000);
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
    const somethingToShow = (this.tab === 'all')
      ? !!this._aggregatedTxns()
      : !!this.txnsByTab[this.tab];
    if (somethingToShow) {
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
      if ((this.tab === key || this.tab === 'all') && this.view === 'transactions') this.renderTransactions();
    } catch (err) {
      this.txnsErrorByTab[key] = err.message;
      if ((this.tab === key || this.tab === 'all') && this.view === 'transactions') this.showError(err.message);
    } finally {
      this.txnsLoadingByTab[key] = false;
    }
  }

  renderTransactions() {
    const data = (this.tab === 'all')
      ? this._aggregatedTxns()
      : this.txnsByTab[this.tab];
    if (!data) {
      const err = (this.tab === 'all')
        ? this._firstError(this.txnsErrorByTab)
        : this.txnsErrorByTab[this.tab];
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
    if (!silent) {
      const somethingToShow = (this.tab === 'all')
        ? !!this._aggregatedFlags()
        : !!this.flagsByTab[this.tab];
      if (!somethingToShow) this.showStatus('Loading charge queue…');
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
      if (this.tab === key || this.tab === 'all') {
        if (this.view === 'queue')   this.renderQueue();
        if (this.view === 'members') this.renderMembers();  // repaint badges
      }
    } catch (err) {
      this.flagsErrorByTab[key] = err.message;
      if (!silent && (this.tab === key || this.tab === 'all') && this.view === 'queue') {
        this.showError(err.message);
      }
    } finally {
      this.flagsLoadingByTab[key] = false;
    }
  }

  renderQueue() {
    const data = (this.tab === 'all')
      ? this._aggregatedFlags()
      : this.flagsByTab[this.tab];
    if (!data) {
      const err = (this.tab === 'all')
        ? this._firstError(this.flagsErrorByTab)
        : this.flagsErrorByTab[this.tab];
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

  // ── Financial roll-ups ──────────────────────────────────────────────
  // Given a members-endpoint response, compute the per-tab money numbers
  // shown in the summary strip.  Kept pure so we can also feed it into
  // _renderAllProgramsBar() for the cross-program total.
  //
  // Billing-cycle definition (mirrors backend PersonPayments.cpp):
  //   A "monthly payment" for a given cycle counts as any non-refund
  //   payment of $35 or above whose paidAt falls in
  //     [cycle_start, cycle_end) = [prev-month-15, this-month-15)
  //   when today ≤ 14, otherwise
  //     [this-month-15, next-month-15).
  //   The "This Month" money total therefore sums the CURRENT cycle,
  //   not the calendar month.  The $35 floor applies to status only;
  //   the money total sums every non-refund payment in the window
  //   (money is money) net of refunds in-window.
  _summarize(data) {
    const members = (data && data.members) || [];
    // Build the current billing cycle window.
    const now = new Date();
    const y = now.getUTCFullYear();
    const mo = now.getUTCMonth();
    const day = now.getUTCDate();
    // 15th of the "reference" month (prev if day ≤ 14, else this).
    const cycleStart = (day <= 14)
      ? new Date(Date.UTC(y, mo - 1, 15))
      : new Date(Date.UTC(y, mo,     15));
    const cycleEnd = new Date(Date.UTC(
      cycleStart.getUTCFullYear(),
      cycleStart.getUTCMonth() + 1,
      15
    ));

    let totalPaid     = 0;
    let totalRefunded = 0;
    let thisMonth     = 0;
    let earliestPaidMs = null;
    // Collect per-member net-paid amounts (paid – refunded) for paid
    // members so we can compute a median.  Median is our proxy for the
    // registration fee per member on this program — we don't have an
    // explicit price stored anywhere, so this is the best signal we
    // have from the data itself.
    const paidAmounts = [];
    for (const m of members) {
      const p = Number(m.totalPaid)     || 0;
      const r = Number(m.totalRefunded) || 0;
      totalPaid     += p;
      totalRefunded += r;
      const netPaid = p - r;
      if (netPaid > 0) paidAmounts.push(netPaid);
      if (m.firstPaidAt) {
        const t = new Date(m.firstPaidAt).getTime();
        if (isFinite(t) && (earliestPaidMs == null || t < earliestPaidMs)) {
          earliestPaidMs = t;
        }
      }
      // Sum txns in current billing cycle. The backend returns the
      // previous cycle too, so filter by [cycleStart, cycleEnd) here.
      // Refunds subtract; other types (Charge / Bank / Offline) add.
      for (const t of (m.recentTransactions || [])) {
        if (!t || !t.paidAt) continue;
        const d = new Date(t.paidAt);
        if (isNaN(d.getTime())) continue;
        if (d < cycleStart || d >= cycleEnd) continue;
        const amt = Number(t.amount) || 0;
        if (t.txnType && t.txnType.includes('Refund')) thisMonth -= amt;
        else                                            thisMonth += amt;
      }
    }
    const netCollected = totalPaid - totalRefunded;
    // Months elapsed since the earliest payment on this program — used
    // as the denominator for average monthly collection.  Clamped to a
    // minimum of 1 so a brand-new program doesn't produce a divide-by-0.
    let monthsElapsed = 0;
    if (earliestPaidMs != null) {
      const first = new Date(earliestPaidMs);
      monthsElapsed =
        (y - first.getUTCFullYear()) * 12 +
        (mo - first.getUTCMonth()) + 1;   // inclusive of both ends
      if (monthsElapsed < 1) monthsElapsed = 1;
    }
    const avgPerMonth = monthsElapsed > 0 ? netCollected / monthsElapsed : 0;

    const counts = data && data.counts ? data.counts : {};
    const outstandingCount = (counts.never || 0) + (counts.overdue || 0);

    // Estimated per-member fee — median of net-paid amounts among
    // members who have paid.  Used to translate the outstanding member
    // count into a dollar estimate.  Falls back to the mean if we have
    // very few data points.
    let estFeePerMember = 0;
    if (paidAmounts.length > 0) {
      const sorted = paidAmounts.slice().sort((a, b) => a - b);
      const mid = Math.floor(sorted.length / 2);
      estFeePerMember = sorted.length % 2
        ? sorted[mid]
        : (sorted[mid - 1] + sorted[mid]) / 2;
    }
    const outstandingTotal    = outstandingCount * estFeePerMember;
    const outstandingPerMonth = monthsElapsed > 0 ? outstandingTotal / monthsElapsed : 0;

    return {
      totalMembers: (data && data.total) || 0,
      totalPaid, totalRefunded, netCollected,
      thisMonth, monthsElapsed, avgPerMonth,
      outstandingCount, outstandingTotal, outstandingPerMonth,
      estFeePerMember,
      counts,
    };
  }

  // Sum the per-tab summaries into a cross-program roll-up.  Uses the
  // earliest firstPaidAt across programs for the avg-per-month
  // denominator so combined avg is calculated on a common timeline.
  _combinedSummary() {
    const tabs = ['mens','womens','boys','girls'];
    let netCollected     = 0;
    let thisMonth        = 0;
    let totalMembers     = 0;
    let outstandingCount = 0;
    let outstandingTotal = 0;
    let earliestMonthsElapsed = 0;   // biggest monthsElapsed = earliest start
    const loaded = [];
    for (const k of tabs) {
      const d = this.membersByTab[k];
      if (!d) continue;
      const s = this._summarize(d);
      netCollected     += s.netCollected;
      thisMonth        += s.thisMonth;
      totalMembers     += s.totalMembers;
      outstandingCount += s.outstandingCount;
      outstandingTotal += s.outstandingTotal;
      if (s.monthsElapsed > earliestMonthsElapsed) earliestMonthsElapsed = s.monthsElapsed;
      loaded.push(k);
    }
    const avgPerMonth         = earliestMonthsElapsed > 0 ? netCollected     / earliestMonthsElapsed : 0;
    const outstandingPerMonth = earliestMonthsElapsed > 0 ? outstandingTotal / earliestMonthsElapsed : 0;
    return {
      loaded, loadedCount: loaded.length,
      totalMembers, netCollected, thisMonth,
      monthsElapsed: earliestMonthsElapsed, avgPerMonth,
      outstandingCount, outstandingTotal, outstandingPerMonth,
    };
  }

  _renderAllProgramsBar() {
    const el = this.find('#pay-all-programs');
    if (!el) return;
    const s = this._combinedSummary();
    const tabsTotal = 4;
    const doneLabel = s.loadedCount === tabsTotal
      ? '<span style="color:#86efac;">all 4 loaded</span>'
      : `<span style="opacity:0.6;">${s.loadedCount}/${tabsTotal} loaded\u2026</span>`;
    el.innerHTML = `
      <div style="font-weight:700;">🌐 All Programs</div>
      <div>${doneLabel}</div>
      <div><span style="opacity:0.7;">Members:</span> <span style="font-weight:700;">${s.totalMembers}</span></div>
      <div><span style="opacity:0.7;">💰 Collected:</span> <span style="font-weight:700; color:#86efac;">${this.fmtMoney(s.netCollected)}</span></div>
      <div><span style="opacity:0.7;">This Month:</span> <span style="font-weight:700; color:#86efac;">${this.fmtMoney(s.thisMonth)}</span></div>
      <div><span style="opacity:0.7;">Avg / Month:</span> <span style="font-weight:700;">${this.fmtMoney(s.avgPerMonth)}</span>${s.monthsElapsed ? `<span style="opacity:0.5; font-size:0.75rem;"> (${s.monthsElapsed} mo)</span>` : ''}</div>
      <div style="flex-basis:100%; height:0;"></div>
      <div><span style="opacity:0.7;">🔴 Outstanding:</span>
           <span style="font-weight:700; color:#fca5a5;">${s.outstandingCount} member${s.outstandingCount === 1 ? '' : 's'}</span></div>
      <div title="Outstanding × est. per-member fee (median of paid members)">
        <span style="opacity:0.7;">Est. Owed:</span>
        <span style="font-weight:700; color:#fca5a5;">~${this.fmtMoney(s.outstandingTotal)}</span></div>
      <div title="Estimated outstanding ÷ months elapsed">
        <span style="opacity:0.7;">Est. Owed / Month:</span>
        <span style="font-weight:700; color:#fca5a5;">~${this.fmtMoney(s.outstandingPerMonth)}</span></div>
    `;
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

  // Rewrite the current /payments browser history entry so its
  // stored `params` capture the operator's live tab + view + search
  // state.  Called immediately before pushing /person onto history —
  // pairs with PersonScreen._goBack()'s plain window.history.back()
  // to make back-nav land on the exact filtered payments view we
  // came from, not the initial-entry defaults.
  _snapshotHistoryState() {
    try {
      const cur = window.history.state || {};
      const snapshot = {
        initialTab:  this.tab,
        initialView: this.view,
        search:      this.search || '',
      };
      const merged = {
        ...cur,
        screen: cur.screen || 'payments',
        params: { ...(cur.params || {}), ...snapshot },
      };
      window.history.replaceState(merged, '', '#payments');
    } catch (_) { /* no-op */ }
  }
}
