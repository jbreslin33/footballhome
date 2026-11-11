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
        <h1>💳 Tuition</h1>
        <p class="subtitle">Player dues from LeagueApps — synced on every load</p>
      </div>

      <div style="padding: var(--space-4); max-width: 1400px; margin: 0 auto;">
        <!-- Summary + Projections lived here for a day (mig 489); they are
             on #finances since mig 490 so billing stays clean. -->
        <!-- 📊 ONE stats section (11/11): pills pick which programmes it
             counts — replaces the old "🌐 All Programs" bar + the per-tab
             strip, which showed the same numbers twice. -->
        <div id="pay-stats" style="${MoneyBoard.STATS_STYLE}">
          <div style="opacity:0.7;">📊 Stats — loading…</div>
        </div>
        </div>

        <!-- Standardized filter chip rows (FilterBar): category / program / status.
             Replaces the old pay-tabs tab bar + inline status-chip row so the
             Payments screen shares styling and behaviour with Members. -->
        <div id="pay-filters" style="margin-bottom: var(--space-3);"></div>

        <!-- Views (MoneyBoard, same tabs style as #fines) -->
        <div id="pay-views" style="display:flex; gap:var(--space-2); margin-bottom: var(--space-3);">
          ${MoneyBoard.viewTabsHtml([
            { id: 'members',      label: '👥 Members' },
            { id: 'transactions', label: '🧾 Transactions' },
            { id: 'queue',        label: '🚩 Charge Queue' },
          ], this.view, 'pay-view')}
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

        <!-- 🙋 Volunteer requests (mig 1222): approve / decline a pick -->
        <div id="pay-volunteers"></div>

        <!-- Members view -->
        <div id="pay-members" style="display:none;"></div>

        <!-- Charge-flag queue view (Phase 2) -->
        <div id="pay-queue" style="display:none;"></div>

        <!-- Transactions view (raw ledger) -->
        <div id="pay-table-wrap" style="display:none; overflow:auto; border:1px solid var(--border-color, #374151); border-radius:6px;">
          <table id="pay-table" style="width:100%; border-collapse:collapse; font-size:0.8rem; font-variant-numeric: tabular-nums;">
            <thead style="background: var(--bg-tertiary, #1f2937); position:sticky; top:0; z-index:1;">
              <tr>
                <th style="text-align:left;  padding:8px 10px; border-bottom:1px solid var(--border-color, #374151);">When</th>
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
    // MoneyBoard.sectionPills makes a fresh FilterBar when the screen's
    // DOM was rebuilt (re-entry).
    this._buildFilterBar();
    this.paintViewButtons();

    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) return this.navigation.goBack();
      // ⋯ / banner / injury chip → the player sheet (mig 1235).
      const sheetBtn = e.target.closest('[data-player-sheet]');
      if (sheetBtn) { this.openPlayerSheet(sheetBtn.getAttribute('data-player-sheet'), sheetBtn.getAttribute('data-sheet-tab')); return; }
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
      // Fines panel → copy the billing cycle's fines for the LA invoice
      // description (mig 1157).
      const copyFinesBtn = e.target.closest('[data-copy-fines]');
      if (copyFinesBtn) {
        this._copyToClipboard(copyFinesBtn.getAttribute('data-copy-fines'), copyFinesBtn.getAttribute('data-copy-fines-toast'));
        return;
      }
      // 🙋 volunteer request → Make volunteer / Decline (mig 1222).
      const volBtn = e.target.closest('[data-pay-volunteer]');
      if (volBtn) {
        volBtn.closest('[data-pay-vol-row]')?.querySelectorAll('button').forEach((b) => { b.disabled = true; });
        this._decideVolunteer(Number(volBtn.getAttribute('data-pay-volunteer')), volBtn.getAttribute('data-decision'));
        return;
      }
      // ⚖️ dispute strip → Approve (marks present) / Deny (mig 691/1210).
      const disputeBtn = e.target.closest('[data-pay-dispute]');
      if (disputeBtn) {
        disputeBtn.closest('.pay-dispute-strip')?.querySelectorAll('button').forEach((b) => { b.disabled = true; });
        this._decideFineDispute(Number(disputeBtn.getAttribute('data-pay-dispute')), disputeBtn.getAttribute('data-decision'), disputeBtn.getAttribute('data-tab'));
        return;
      }
      const ranBtn = e.target.closest('[data-resolve-flag]');
      if (ranBtn) {
        const id     = ranBtn.getAttribute('data-resolve-flag');
        const status = ranBtn.getAttribute('data-status') || 'ran';
        this.resolveFlag(id, status);
        return;
      }
      // A fines box on a card → the sheet's Fines tab (every period's
      // line items are open there).
      const finesBtn = e.target.closest('.pay-fines-cell[data-fines-month]');
      if (finesBtn) {
        const fcard = finesBtn.closest('.pay-member-card[data-player-key]');
        if (fcard) this.openPlayerSheet(fcard.getAttribute('data-player-key'), 'fines');
        return;
      }
      // Card body → the player sheet on Money.  Inline buttons, anchors
      // and form controls keep their own handlers.
      const anchorInside = e.target.closest('a, button, input, textarea, select, label');
      if (anchorInside) return;
      const card = e.target.closest('.pay-member-card[data-player-key]');
      if (card) {
        this.openPlayerSheet(card.getAttribute('data-player-key'), 'money');
        return;
      }
      // (Category / program / status chip clicks are handled by the
      // shared FilterBar component — see `_buildFilterBar` below.)
    });
    // Due-date dropdown change events don't bubble as clicks — attach
    // a dedicated `change` listener.  Uses data-set-next-due=<regId>.
    this.element.addEventListener('change', (e) => {
      const sel = e.target.closest('select[data-set-next-due]');
      if (!sel) return;
      const regId = sel.getAttribute('data-set-next-due');
      const iso   = sel.value;
      if (!regId || !iso) return;
      this.setNextDue(regId, iso);
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
      // renderMembers() → _renderStats() when it lands.
      this.loadMembers(k);
    }
  }

  // ── Section pills (FilterBar) ───────────────────────────────────────
  // ONE row (owner 2026-11-11: "drop all the pills except all, men,
  // women, boys, girls and boys/girls"):
  //   [💰 All] [👨 Mens] [👩 Womens] [👦 Boys + Girls] [👧 Girls]
  // It picks the section for the stats box AND the list.  Boys shows Boys
  // + Girls (club rule, Screen.sectionIncludes), so its pill says so —
  // that is the "boys/girls" pill; Girls is girls only.  Gone: the stats
  // box's own pills, the Club / Pickup program row (pickup members sit in
  // their section with a Pickup chip — mig 1240) and the status row (the
  // list is already split into status sections, the stats box counts).
  _buildFilterBar() {
    MoneyBoard.sectionPills(this, this.find('#pay-filters'), this.tab || 'all', (id) => {
      this.tab = id;
      this.loadCurrent();
    });
  }

  _titleCase(s) {
    if (!s) return '';
    return s.charAt(0).toUpperCase() + s.slice(1);
  }

  // Which per-program shards a tab is made of.  Boys is the whole youth
  // club — girls play on boys teams — so the Boys tab shows the Boys AND
  // Girls programmes together and Girls stays girls-only (owner
  // 2026-09-24: "when we click boys it should always show girls but
  // girls should only show girls ... for all screens"; same rule as
  // Screen.sectionIncludes).  'all' is every programme.
  static get ALL_TABS() { return ['mens', 'womens', 'boys', 'girls']; }
  _shardKeys(tab = this.tab) {
    if (tab === 'all') return PaymentsScreen.ALL_TABS;
    return PaymentsScreen.ALL_TABS.filter(k => Screen.sectionIncludes(tab, k));
  }
  _showsTab(key) { return this._shardKeys().includes(key); }
  _shardLabel(keys) {
    return keys.length === PaymentsScreen.ALL_TABS.length ? 'All Programs' : keys.map(k => this._titleCase(k)).join(' + ');
  }
  // The current tab's payload: a single programme's response as-is, or
  // the shards merged into the same shape.
  _currentMembers() { const k = this._shardKeys(); return k.length === 1 ? this.membersByTab[k[0]] : this._aggregatedMembers(k); }
  _currentTxns()    { const k = this._shardKeys(); return k.length === 1 ? this.txnsByTab[k[0]]    : this._aggregatedTxns(k); }
  _currentFlags()   { const k = this._shardKeys(); return k.length === 1 ? this.flagsByTab[k[0]]   : this._aggregatedFlags(k); }
  _currentError(bag) { return this._firstError(bag, this._shardKeys()); }

  // Counts used to label the status chips — summed over the tab's shards.
  // The person's current injury (#teams / player sheet health), or null.
  // Injured players sit in their own 🩹 sections and count only there
  // (owner 2026-11-11, mig 1235) — their balance still shows.
  _injuryOf(m) { return (window.PlayerSheet && m && m.personId) ? PlayerSheet.injuryFor(m.personId) : null; }

  // Status counts for a set of programmes, from the rows themselves so the
  // 🩹 injured split is the same everywhere (chips, stats).
  _countsFor(keys) {
    const c = { current: 0, behind: 0, overdue: 0, never: 0, volunteer: 0, injured: 0, finalNotice: 0, active: 0 };
    for (const k of keys) {
      const d = this.membersByTab[k];
      for (const m of ((d && d.members) || [])) {
        if (m.variant === 'inactive') continue;
        c.active++;
        if (m.status !== 'volunteer' && this._injuryOf(m)) { c.injured++; continue; }
        if (c[m.status] != null) c[m.status]++;
        if (m.finalNotice) c.finalNotice++;
      }
    }
    return c;
  }

  // ── 'All' aggregation helpers ───────────────────────────────────────
  // Combine the four per-category payloads (mens/womens/boys/girls) that
  // were loaded in the background into one payload with the same shape
  // as a single-program response.  Returns null if none of the four have
  // landed yet, so the caller keeps showing the loader.  Concatenates
  // members/flags/payments lists and sums counts/totals.

  _aggregatedMembers(keys = PaymentsScreen.ALL_TABS) {
    const shards = keys.map((k) => this.membersByTab[k]).filter(Boolean);
    if (!shards.length) return null;
    const out = {
      programId:   null,
      programName: this._shardLabel(keys),
      total:       0,
      inactiveCount: 0,
      counts:      { current: 0, behind: 0, overdue: 0, never: 0, volunteer: 0, injured: 0 },
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
      out.inactiveCount += (d.inactiveCount || 0);
      for (const k of ['current','behind','overdue','never','volunteer','injured']) {
        out.counts[k] += (d.counts?.[k] || 0);
      }
      if (Array.isArray(d.members)) out.members.push(...d.members);
      out.totalCollected += (d.totalCollected || 0);
      out.totalRefunds   += (d.totalRefunds   || 0);
      if (Array.isArray(d.recentPayments)) out.recentPayments.push(...d.recentPayments);
    }
    return out;
  }

  _aggregatedTxns(keys = PaymentsScreen.ALL_TABS) {
    const shards = keys.map((k) => this.txnsByTab[k]).filter(Boolean);
    if (!shards.length) return null;
    const out = {
      programName:   this._shardLabel(keys),
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
    // Newest first by the full timestamp (same as each programme's own
    // ORDER BY paid_at DESC, la_transaction_id DESC).
    out.payments.sort(PaymentsScreen.byPaidAtDesc);
    return out;
  }

  // Transactions order: paid_at (full timestamp) newest first, then the
  // higher transaction id — two items of one LA transaction share a time.
  static byPaidAtDesc(a, b) {
    const at = Date.parse(a.paidAt || a.paid_at || '') || 0;
    const bt = Date.parse(b.paidAt || b.paid_at || '') || 0;
    return (bt - at) || ((Number(b.transactionId) || 0) - (Number(a.transactionId) || 0));
  }

  _aggregatedFlags(keys = PaymentsScreen.ALL_TABS) {
    const shards = keys.map((k) => this.flagsByTab[k]).filter(Boolean);
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
  _firstError(bag, keys = PaymentsScreen.ALL_TABS) {
    for (const k of keys) {
      if (bag[k]) return bag[k];
    }
    return null;
  }

  switchTab(key) {
    if (!key || this.tab === key) return;
    this.tab = key;
    this._buildFilterBar();
    this.loadCurrent();
  }

  // ── View mode (Members vs Transactions) ─────────────────────────────
  paintViewButtons() {
    MoneyBoard.paintViewTabs(this.element, 'pay-view', this.view);
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
    const keys = this._shardKeys();
    if (keys.length > 1) {
      for (const k of keys) {
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
      const copyReady = MessageCopy.load(this.auth); // payment notice wording (migration 367), in parallel
      const formsReady = window.SectionContact ? SectionContact.load(this.auth) : Promise.resolve(); // 📇 section forms
      const disputesReady = this._loadFineDisputes();                // ⚖️ strip on the card (mig 1210)
      const healthReady = window.PlayerSheet ? PlayerSheet.loadHealth(this.auth) : Promise.resolve();   // 🩹 sections (mig 1235)
      copyReady.then(() => this._loadVolunteerRequests());           // 🙋 panel (mig 1222)
      const res = await this.auth.fetch(`/api/payments/${key}/members`);
      await Promise.all([copyReady, formsReady, disputesReady, healthReady]);
      if (!res.ok) {
        const body = await res.text();
        throw new Error(body.slice(0, 200) || `HTTP ${res.status}`);
      }
      const data = await res.json();
      // Remember which programme each row came from: merged tabs (Boys =
      // Boys + Girls, All) need it to flag a charge on the right one.
      for (const m of ((data && data.members) || [])) m._tab = key;
      this.membersByTab[key] = data;
      if (data && data.programId) {
        this.programIdByTab[key] = data.programId;
      }
      // Fetch current pending flags in parallel so we can badge cards.
      this.loadFlags(key, /*silent=*/true);
      if (this._showsTab(key) && this.view === 'members') this.renderMembers();
      // Always refresh the All-Programs roll-up bar — even for tabs
      // loaded in the background (see _loadAllProgramsInBackground) so
      // totals accumulate as each program's data lands.
      this._renderStats();
    } catch (err) {
      this.membersErrorByTab[key] = err.message;
      if (this._showsTab(key) && this.view === 'members') this.showError(err.message);
    } finally {
      this.membersLoadingByTab[key] = false;
    }
  }

  renderMembers() {
    // When 'all' is selected, aggregate the four background-loaded
    // tabs.  If none have landed yet, keep showing the loader.
    const data = this._currentMembers();
    if (!data) {
      const err = this._currentError(this.membersErrorByTab);
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

    // Members view has no strip of its own — the 📊 stats section counts
    // (Transactions / Charge Queue keep their view-specific lines).
    const sumEl = this.find('#pay-summary');
    if (sumEl) { sumEl.innerHTML = ''; sumEl.style.display = 'none'; }

    // Refresh the stats section whenever a tab finishes loading.
    this._renderStats();

    // Rebuild the FilterBar so status-chip counts reflect the latest
    // data (works for both single-tab and 'all' aggregation modes).
    this._buildFilterBar();

    // Search (shared by every section) + optional status filter (status
    // groups only — the Inactive section isn't a payment-status bucket,
    // so status chips don't apply to it).
    const q = this.search;
    const searchMatch = (mm) => {
      if (!q) return true;
      const hay = [mm.firstName, mm.lastName, mm.status, String(mm.laUserId || ''),
                   mm.email, mm.phone, mm.dob]
        .filter(Boolean).join(' ').toLowerCase();
      return hay.includes(q);
    };

    // Members moved to the category's "inactive" LA sub-program (2 months
    // unpaid — migration 266) render in their own section above the
    // status groups, not folded into Overdue/Never/etc, so ops can watch
    // this specific "did they pay yet, do we restore them" queue.
    const inactiveMembers = (data.members || [])
      .filter((mm) => mm.variant === 'inactive' && searchMatch(mm));

    const injuredOf = (mm) => (mm.status !== 'volunteer' ? this._injuryOf(mm) : null);
    const rows = (data.members || []).filter((mm) => {
      if (mm.variant === 'inactive') return false;
      if (injuredOf(mm)) return searchMatch(mm);
      return searchMatch(mm);
    });

    if (rows.length === 0 && inactiveMembers.length === 0) {
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
    const statusOrder = ['overdue', 'never', 'behind', 'current', 'volunteer', 'injured'];
    const statusMeta = {
      overdue: { icon:'🔴', label:'OVERDUE',    fg:'#7f1d1d', bg:'#fee2e2', border:'#dc2626' },
      never:   { icon:'⚫', label:'NEVER PAID', fg:'#1f2937', bg:'#e5e7eb', border:'#4b5563' },
      behind:  { icon:'🟡', label:'BEHIND',     fg:'#78350f', bg:'#fef3c7', border:'#d97706' },
      current: { icon:'🟢', label:'CURRENT',    fg:'#14532d', bg:'#dcfce7', border:'#16a34a' },
      volunteer: { icon:'', label:this._duesFreeCopy('volunteer', 'label').toUpperCase(), fg:'#1e3a8a', bg:'#dbeafe', border:'#2563eb' },
      injured:   { icon:'', label:this._duesFreeCopy('injured', 'label').toUpperCase(),   fg:'#78350f', bg:'#fef3c7', border:'#d97706' },
    };
    const byStatus = {};
    for (const st of statusOrder) byStatus[st] = [];
    const other = [];
    // 🩹 one section per injury kind (Short-term, Long-term — health
    // statuses in their order), real balances shown: the owner decides at
    // billing time (mig 1235).
    const byInjury = new Map();
    for (const row of rows) {
      const inj = injuredOf(row);
      if (inj) {
        if (!byInjury.has(inj.code)) byInjury.set(inj.code, { status: inj.status, list: [] });
        byInjury.get(inj.code).list.push(row);
      } else if (byStatus[row.status]) byStatus[row.status].push(row);
      else other.push(row);
    }

    // Overdue is subdivided by the LA-authoritative months-behind bucket
    // (monthsOverdue, migration 270; FULL months since 416 — $35-69 due
    // = 1 month, $70+ = 2, the line) instead of one flat OVERDUE pile, so ops can tell
    // "probably still going to pay" from "further gone" at a glance
    // (owner directive 2026-08-08). Rows with no snapshot yet
    // (monthsOverdue null) fall back into a plain OVERDUE bucket rather
    // than disappearing.
    const overdueByMonths = {};
    const overdueUnknown = [];
    for (const row of byStatus.overdue) {
      const mo = Number.isFinite(row.monthsOverdue) ? row.monthsOverdue : null;
      if (mo === null || mo < 1) {
        overdueUnknown.push(row);
      } else {
        (overdueByMonths[mo] = overdueByMonths[mo] || []).push(row);
      }
    }

    // Section bars + card grids: MoneyBoard, the same as #fines.
    const grid = (meta, list, note) => MoneyBoard.section(meta, list.length, list.map((mm) => this.renderMemberCard(mm)).join(''), note);

    const groupHtml = (st) => {
      const list = byStatus[st] || [];
      return list.length ? grid(statusMeta[st], list) : '';
    };

    // Worst (most months behind) first — matches the existing work-queue
    // urgency convention (overdue sat above never/behind/current before
    // this split).
    const overdueMonthsHtml = Object.keys(overdueByMonths)
      .map(Number)
      .sort((a, b) => b - a)
      .map((mo) => grid({
        icon: '🔴',
        label: `OVERDUE — ${mo} FULL MONTH${mo === 1 ? '' : 'S'}`,
        fg: '#7f1d1d', bg: '#fee2e2', border: '#dc2626',
      }, overdueByMonths[mo])).join('');

    const overdueUnknownHtml = overdueUnknown.length ? grid(statusMeta.overdue, overdueUnknown) : '';

    const otherHtml = other.length
      ? grid({ icon:'❓', label:'UNKNOWN STATUS', fg:'#1f2937', bg:'#f3f4f6', border:'#9ca3af' }, other)
      : '';

    // Inactive section always renders first — moved off the active LA
    // program, so they're gone from rosters/pool, but ops still needs
    // eyes on them to catch a payment and restore them.
    const inactiveHtml = inactiveMembers.length
      ? grid({ icon:'🚫', label:'INACTIVE — MONITOR FOR REACTIVATION', fg:'#4c1d95', bg:'#ede9fe', border:'#7c3aed' }, inactiveMembers)
      : '';

    const healthOrder = ((window.PlayerSheet && PlayerSheet.HEALTH.statuses) || []).map((h) => h.code);
    const injuredHtml = [...byInjury.entries()]
      .sort((a, b) => healthOrder.indexOf(a[0]) - healthOrder.indexOf(b[0]))
      .map(([, g]) => grid({ icon: g.status.icon || '🩹', label: String(g.status.displayName || '').toUpperCase(),
                             fg:'#78350f', bg:'#fef3c7', border:'#d97706' }, g.list,
                           this._sheetCopy('injured_section_note', 'Billed as usual unless you skip them — you decide at billing time.'))).join('');

    m.innerHTML = inactiveHtml + overdueMonthsHtml + overdueUnknownHtml
      + statusOrder.filter((st) => st !== 'overdue' && st !== 'injured').map(groupHtml).join('') + injuredHtml + otherHtml;
    // An open player sheet follows the fresh rows (due date moved, dispute
    // settled, health changed).
    if (window.PlayerSheet) PlayerSheet.refresh();
    // Team status + official-list pills (mig 1221) arrive after the cards.
    if (window.PersonStanding && PersonStanding.fillRosters) PersonStanding.fillRosters(this.auth, m);
  }

  // Parses a "YYYY-MM-DD..." prefix into a LOCAL calendar date, ignoring
  // any time/timezone suffix — next_due_at / upcoming_due_at are always
  // calendar-date anchors (first-Friday-of-month), so treating them via
  // `new Date(isoString)` (which applies the browser's timezone offset
  // to a UTC midnight) risks rolling a 1st-of-month date back into the
  // prior month for any timezone behind UTC. Reading the y/m/d digits
  // directly sidesteps that entirely.
  _parseIsoDateOnly(iso) {
    if (!iso) return null;
    const [y, mo, d] = iso.slice(0, 10).split('-').map(Number);
    if (!y || !mo || !d) return null;
    return new Date(y, mo - 1, d);
  }

  // For a member flagged `finalNotice` (owner protocol 2026-08-05: unpaid
  // at the next due-date rollover = carrying 2 unpaid cycles = pause
  // candidate) — builds the real month names + due date from the data
  // instead of a hardcoded "2 months" string. Returns null when the
  // dates aren't both present (nothing to compute) or nothing is owed.
  _finalNoticeDetails(m) {
    const due      = this._parseIsoDateOnly(m.nextDueAt);
    const upcoming = this._parseIsoDateOnly(m.upcomingDueAt);
    if (!due || !upcoming) return null;
    const monthName = (d) => d.toLocaleDateString('en-US', { month: 'long' });
    const owedMonths = [];
    const cursor = new Date(due.getFullYear(), due.getMonth(), 1);
    const upcomingMonthStart = new Date(upcoming.getFullYear(), upcoming.getMonth(), 1);
    while (cursor < upcomingMonthStart) {
      owedMonths.push(monthName(cursor));
      cursor.setMonth(cursor.getMonth() + 1);
    }
    if (!owedMonths.length) return null;
    return {
      owedMonths,
      owedPhrase: owedMonths.join(' and '),
      nextMonthName: monthName(upcoming),
      // Total months unpaid once `upcoming` also passes unpaid — usually
      // 2, but climbs higher for anyone already several cycles behind
      // (e.g. next_due_at 3 months ago → will be 4 months behind).
      monthsBehindAtRollover: owedMonths.length + 1,
      upcomingLabel: upcoming.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' }),
    };
  }

  // How far behind on dues this member is — the one fact the reminder is
  // built from (owner 2026-09-22: "just say the amount and months").
  //   amount → live LA outstanding balance, else the last-sync snapshot
  //   months → FULL months, floor(amount / monthly dues rate), when both
  //            are known (migration 416), else the LA-sync bucket (also
  //            full months), else the unpaid cycles between next_due_at
  //            and the upcoming rollover, else 0 (owed, under a month).
  // → {amount: '$70.00'|'', months: 2, monthsLabel: '2 full months'} or
  // null when nothing is owed.
  _duesStanding(m) {
    let owed = null;
    if (Number.isFinite(m.laOutstandingBalance)) owed = Number(m.laOutstandingBalance);
    else if (Number.isFinite(m.laAmountOwedCents) && Number.isFinite(m.laAmountPaidCents)) {
      owed = (m.laAmountOwedCents - m.laAmountPaidCents) / 100;
    }
    // Live balance ÷ the club's monthly rate (dues_policies, mig 401)
    // beats the last-sync snapshot: a payment since the sync shows at once.
    const rate = MessageCopy.duesPolicy.monthlyDuesUsd;
    let months = null;
    if (owed !== null && owed > 0.005 && Number.isFinite(rate) && rate > 0) {
      months = Math.floor(owed / rate);
    } else if (Number.isFinite(m.monthsOverdue) && m.monthsOverdue >= 0 && (m.status === 'overdue' || m.status === 'never' || m.monthsOverdue >= 1)) {
      months = m.monthsOverdue;
    }
    if (months === null) {
      const fd = this._finalNoticeDetails(m);
      if (fd) months = fd.owedMonths.length;
    }
    if (months === null && (m.status === 'overdue' || m.status === 'never' || (owed !== null && owed > 0.005))) {
      months = 0;
    }
    if (months === null) return null;
    return {
      amount:      (owed !== null && owed > 0.005) ? this.fmtMoney(owed) : '',
      amountNum:   (owed !== null && owed > 0.005) ? owed : null,
      months,
      monthsLabel: months === 0 ? 'under a month' : `${months} full month${months === 1 ? '' : 's'}`,
    };
  }

  // Wording: message_templates kind 'payment_notice_email' /
  // 'payment_notice_sms', tier 'behind_1' | 'behind_2' | 'behind_3'
  // (migration 399/416/536) — under a month, 1 full month, at/over the
  // line (said softly since 536: "could lead shortly to not being
  // eligible ... or even release from the team roster").  The tier is full months
  // behind + 1, capped at the line (dues_policies.pause_after_months,
  // full months); the operator never chooses it.
  // → {subject, body, standing, tier} or null.
  _paymentNotice(m, channel) {
    if (m.status === 'volunteer' || m.status === 'injured') return null;   // no dues (mig 704/715)
    const standing = this._duesStanding(m);
    if (!standing) return null;
    const pauseAt = this._pauseAfterMonths();
    if (!pauseAt) return null;   // policy not loaded: never guess the threshold
    const tier = `behind_${Math.min(pauseAt, standing.months) + 1}`;
    const dates = this._duesDates(m, standing.months);
    // Per-channel tally from pay_reminder_log (row.payReminders) — the
    // button says "sent ×2" so the operator can see two emails went
    // unanswered and try a text instead.
    const tally = (m.payReminders && m.payReminders[channel]) || { count: 0, lastAt: null };
    const tokens = {
      first:        (m && m.firstName || '').trim(),
      club:         (m && m.programName) || '',
      amount:       standing.amount,
      months:       standing.months,
      months_label: standing.monthsLabel,
      sent:         tally.count > 0 ? tally.count : '',
      deadline:     dates.deadline,     // next first-Friday due date
      pause_date:   dates.pauseDate,    // first Friday they reach the pause threshold
      pause_months: pauseAt,            // dues_policies.pause_after_months
      partial_amounts: MessageCopy.partialAmountsText, // dues_policies.partial_amounts_usd (mig 414)
      // 🙋 "Out of work? volunteer one evening a week instead" (mig 1222):
      // only when the server offers it (volunteerOffer = the days); empty
      // drops the notice's [[{volunteer}]] block.
      volunteer:    m.volunteerOffer ? (MessageCopy.block('payment_notice_volunteer', channel === 'sms' ? 'sms' : 'email',
                                                          { days: m.volunteerOffer }) || '') : '',
      ...this._pauseLine(standing, pauseAt),            // {pause_amount} {keep_active_amount} {min_payment} (mig 415/416)
    };
    // Men today (mig 1149, duesSelection from the dues policy): the
    // *_selection tier — bottom of the selection list for starters and
    // bench, never a ban or practice ("its a soft cut").
    const kind = channel === 'sms' ? 'payment_notice_sms' : 'payment_notice_email';
    const copyTier = m.duesSelection && MessageCopy.has(kind, `${tier}_selection`) ? `${tier}_selection` : tier;
    const copy = MessageCopy.render(kind, copyTier, tokens);
    if (!copy) return null;
    const label = MessageCopy.has('payment_notice_button', channel)
      ? MessageCopy.block('payment_notice_button', channel, tokens)
      : (channel === 'sms' ? '💬 Dues' : '✉️ Dues');
    return { ...copy, standing, tier, label, tally };
  }

  // Fire-and-forget POST /api/pay-reminder-log on a dues-notice click
  // (same endpoint the roster PAY buttons use).  Does NOT preventDefault
  // — the compose window still opens; keepalive survives the tab switch.
  // The member row's tally is bumped in memory and the card re-rendered
  // so the button reads "sent ×N" at once.
  _logPayNotice(anchor) {
    const laUserId = parseInt(anchor.dataset.laUserId, 10);
    const method   = anchor.dataset.method;
    if (!laUserId || !method) return;
    const body = {
      leagueAppsUserId: laUserId,
      method,
      club: 'payments',
      tier: anchor.dataset.tier || null,
      amount: anchor.dataset.amount ? Number(anchor.dataset.amount) : null,
      daysOverdue: anchor.dataset.daysOverdue !== '' ? parseInt(anchor.dataset.daysOverdue, 10) : null,
    };
    try {
      const headers = { 'Content-Type': 'application/json' };
      if (this.auth && this.auth.token) headers['Authorization'] = `Bearer ${this.auth.token}`;
      fetch('/api/pay-reminder-log', { method: 'POST', headers, keepalive: true, body: JSON.stringify(body) })
        .catch(() => { /* fire-and-forget */ });
    } catch (_e) { /* ignore */ }

    // The row may sit in any loaded tab (the all-programs view merges them).
    let m = null;
    for (const d of Object.values(this.membersByTab || {})) {
      m = d && Array.isArray(d.members) ? d.members.find(x => String(x.laUserId) === String(laUserId)) : null;
      if (m) break;
    }
    if (!m) return;
    m.payReminders = m.payReminders || { sms: { count: 0, lastAt: null }, email: { count: 0, lastAt: null } };
    m.payReminders[method] = { count: (m.payReminders[method]?.count || 0) + 1, lastAt: new Date().toISOString() };
    const copy = this._paymentNotice(m, method);
    if (copy) {
      anchor.innerHTML = copy.label;
      anchor.title = this._paymentNoticeTitle(copy, method);
    }
  }

  // Tooltip for a dues button: tier + what this channel has already sent.
  _paymentNoticeTitle(copy, channel) {
    const what = channel === 'sms' ? 'text' : 'email';
    const sent = copy.tally && copy.tally.count
      ? `${copy.tally.count} ${what}${copy.tally.count === 1 ? '' : 's'} sent, last ${this.fmtDate(copy.tally.lastAt)}`
      : `no ${what} sent yet`;
    return `${copy.standing.monthsLabel} behind — ${copy.tier.replace('behind_', 'tier ')} · ${sent}`;
  }

  // Dates for the notice (migration 400).  Dues roll over on the first
  // Friday of each month, so from the upcoming rollover we can name the
  // Friday a member reaches 3 months behind — the pause threshold.
  //   deadline  = upcoming rollover (server's upcoming_due, else the
  //               first Friday of next month)
  //   pauseDate = that rollover plus (pause_after_months − months − 1)
  //               further rollovers; empty once they are already there.
  // → {deadline: 'Friday, October 2'|'', pauseDate: …|''}
  _duesDates(m, months) {
    let upcoming = this._parseIsoDateOnly(m.upcomingDueAt);
    if (!upcoming) {
      const now = new Date();
      const ff  = this._firstFridayOfMonth(new Date(Date.UTC(now.getFullYear(), now.getMonth() + 1, 1)));
      upcoming  = new Date(ff.getUTCFullYear(), ff.getUTCMonth(), ff.getUTCDate());
    }
    const fmt = (d) => d.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' });
    const rolloversToPause = this._pauseAfterMonths() - months - 1;
    let pauseDate = '';
    if (rolloversToPause >= 0) {
      const ff = this._firstFridayOfMonth(new Date(Date.UTC(upcoming.getFullYear(), upcoming.getMonth() + rolloversToPause, 1)));
      pauseDate = fmt(new Date(ff.getUTCFullYear(), ff.getUTCMonth(), ff.getUTCDate()));
    }
    return { deadline: fmt(upcoming), pauseDate };
  }

  // The eligibility line in dollars and the two asks around it
  // (migrations 415/416; owner 2026-09-23: "2 full months behind is the
  // pause threshold … if they can bring it under $70 then they are
  // safe").  Full months is floor(owed / rate); the line is
  // pause_after_months full months, i.e. pause_after_months × rate ($70).
  //   pause_amount        the line                                  $70
  //   keep_active_amount  least to pay now to still be under the line
  //                       after the next posting adds a month:
  //                       ceil(owed + rate − line + 0.01)   $40 → $6
  //   min_payment         least to pay now to get under the line today:
  //                       ceil(owed − line + 0.01)          $70 → $1
  // Each is '' when it isn't needed or the balance is unknown, so the
  // [[ … ]] around it drops.  Whole dollars, matching fh_dues_min_payment_usd.
  _pauseLine(standing, pauseAt) {
    const rate = MessageCopy.duesPolicy.monthlyDuesUsd;
    if (!(Number.isFinite(rate) && rate > 0 && pauseAt >= 1)) return { pause_amount: '', keep_active_amount: '', min_payment: '' };
    const line = pauseAt * rate;
    const owed = standing.amountNum;
    const dollars = (x) => (x > 0.005 ? this.fmtMoney(Math.ceil(x)) : '');
    return {
      pause_amount:       this.fmtMoney(line),
      keep_active_amount: owed === null ? '' : dollars(owed + rate - line + 0.01),
      min_payment:        owed === null ? '' : dollars(owed - line + 0.01),
    };
  }

  // dues_policies.pause_after_months (migration 401), via the copy
  // payload.  The screen awaits MessageCopy.load() before rendering.
  _pauseAfterMonths() {
    const n = MessageCopy.duesPolicy.pauseAfterMonths;
    return (Number.isFinite(n) && n >= 1) ? n : null;   // null → no dues button
  }

  // Button colours follow the tier (tier = full months + 1): under the
  // month before the line = calm, the month before it = amber, at or
  // over the line = red.
  _paymentNoticeStyle(tier) {
    const n = Number(String(tier).replace('behind_', '')) || 1;
    const pauseAt = this._pauseAfterMonths() || (n - 1);
    const c = n >= pauseAt + 1 ? { bg: '#3a1f1f', fg: '#fca5a5', border: '#b91c1c' }
            : n >= pauseAt     ? { bg: '#3a2e05', fg: '#fde68a', border: '#d97706' }
            :                    { bg: '#0b3a2e', fg: '#a7f3d0', border: '#10b981' };
    return `padding:6px 10px; border-radius:4px; text-decoration:none; background:${c.bg}; color:${c.fg}; border:1px solid ${c.border}; font-size:0.75rem; font-weight:700;`;
  }

  // No dues: volunteers (club_volunteers, mig 704) and the long-term
  // injured (#teams health, mig 715).  Wording from message_templates kind payments_overview,
  // tiers <status>_label / <status>_note.
  _duesFreeCopy(status, part) {
    const tier = `${status}_${part}`;
    if (window.MessageCopy && MessageCopy.has('payments_overview', tier)) return MessageCopy.block('payments_overview', tier);
    return part === 'label' ? ({ volunteer: '🙋 Volunteer', injured: '🩹 Injured' }[status] || status) : '';
  }

  // Everything a Tuition row shows, in pieces: the card front takes a
  // few, the player sheet's tabs take the rest (owner 2026-11-11).
  _cardParts(m) {
    const duesFree = m.status === 'volunteer' || m.status === 'injured';
    const badge = this.renderStatusBadge(m.status, m.daysOverdue);
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

    // Activity line — last RSVP + last attended event + 30-day tallies
    // (row.activity, PersonActivity roll-up).  Owner 2026-09-24: "show
    // some attendance and rsvp data so we can see if the player is a
    // ghost and over due and maybe just drop them ... like last rsvp and
    // last attendent event".
    const activityLine = this.renderActivityLine(m);

    const recent = m.recentTransactions || [];
    const recentHtml = recent.length
      ? recent.map((t) => `
          <div style="display:flex; justify-content:space-between; gap:8px; padding:2px 0;">
            <span style="opacity:0.7; white-space:nowrap;">${this.fmtDateTime(t.paidAt)}</span>
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

    // One CONTACT button (owner 2026-11-02).  The dues notice is the
    // preselected message: subject + words from message_templates kind
    // 'payment_notice_*', tier by months behind (mig 399); the subject
    // leads with the real LA club name ({club}), not "Football Home" —
    // members pay Lighthouse dues.  Every send still lands in
    // pay_reminder_log.  Never from the club number.
    const emailNotice = m.email ? this._paymentNotice(m, 'email') : null;
    const textNotice  = (m.phone && m.phoneSms !== false) ? this._paymentNotice(m, 'sms') : null;
    const anyNotice   = emailNotice || textNotice;
    const contactContext = [
      ...(anyNotice ? [{
        key: 'dues',
        label: anyNotice.label,
        subject: emailNotice ? emailNotice.subject : '',
        body: emailNotice ? emailNotice.body : textNotice.body,
        smsBody: textNotice ? textNotice.body : '',
        noClub: true,
        onSent: (_data, via) => {
          const method = via === 'email' ? 'email' : 'sms';
          const c = method === 'email' ? emailNotice : textNotice;
          if (c) this._logPayNotice({ dataset: {
            laUserId: String(m.laUserId || ''), method, tier: c.tier,
            amount: String(c.standing.amountNum ?? ''),
            daysOverdue: Number.isFinite(m.daysOverdue) ? String(m.daysOverdue) : '',
          } });
        },
      }] : []),
    ];
    // The section's one list after the dues notice (section-contact.js, 11/3).
    const contactMessages = window.SectionContact
      ? SectionContact.messages(m._tab || this.tab, { screen: this, playerId: m.personId, first: m.firstName || '', context: contactContext })
      : contactContext;
    const contactBtn = (window.ContactPopup && contactMessages.length && (m.email || m.phone))
      ? ContactPopup.button({
          key: `payments:${m._tab || this.tab}:${m.laUserId || m.personId}`,
          screen: this,
          recipients: [{ personId: m.personId, name: `${m.firstName || ''} ${m.lastName || ''}`.trim(), phone: m.phone || null, email: m.email || null,
                         noText: m.phoneSms === false, noCall: m.phoneCall === false }],
          messages: contactMessages,
          flagged: !!anyNotice,
          big: true,
          title: anyNotice ? this._paymentNoticeTitle(anyNotice, emailNotice ? 'email' : 'sms') : '',
        })
      : '';

    // Flag-for-Charge button — disabled+badged if a pending flag already
    // exists for this LA user on this program.
    const pendingMap = this.pendingByLaUserIdByTab[m._tab || this.tab] || {};   // row's own programme on merged tabs
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

    // Projected prorate — shared BillingBadge helper.  Mid-cycle signups
    // owe a partial-cycle charge; showing the amount inline lets the
    // operator adjust the auto-generated LA invoice to match instead of
    // hunting through the roster screen.  BillingBadge.projectedProrate
    // expects `laRegisteredAt` + `paymentsWindow` on the shape it's
    // given, so we pass a tiny adapter object.
    const prorateCell =
      (window.BillingBadge && typeof window.BillingBadge.renderProrateCell === 'function')
        ? window.BillingBadge.renderProrateCell({
            laRegisteredAt: m.laRegisteredAt || null,
            paymentsWindow: m.recentTransactions || [],
          })
        : '';

    // Fines by month — one box per month next to Prorate (owner
    // 2026-09-27: "similar to pro rate ... show next to pro rate ...
    // last 3 months ... each in a box").  row.fines is null for anyone
    // whose section has no fine rate (parents and the women), so their
    // cards show nothing.  Tap a box for the month's line items.
    // Between them sit the bills they go on — this month's and next
    // month's so far, dues + fines (owner 2026-10-06: "instead of 35
    // they will owe 35+").
    const finesCells = this.renderFinesCells(m);
    const finesDetail = this.renderFinesDetail(m);

    return { duesFree, badge, name, lastLine, dobLine, contactLine, activityLine, recentHtml,
             laBtn, contactBtn, flagBtn, pauseBtn, prorateCell, finesCells, finesDetail, anyNotice };
  }

  // The card front: name + chips + the ⋯ button, team pills, a banner
  // when something needs the owner, the dues hero and the ghost line.
  // Every action lives in the player sheet (PlayerSheet, mig 1235).
  renderMemberCard(m) {
    const c = this._cardParts(m);
    const key = this._sheetKey(m);
    const disputes = this._pendingDisputes(m);
    const banner = disputes.length
      ? `<button type="button" data-player-sheet="${this.escape(key)}" data-sheet-tab="fines"
                 style="text-align:left; font-size:0.82rem; font-weight:700; cursor:pointer; color:#fde68a;
                        background:#3a2e05; border:1px solid #d97706; border-radius:6px; padding:6px 10px;">
           ${this.escape(this._sheetCopy('dispute_banner', `⚖️ ${disputes.length} fine dispute(s) waiting — tap to settle`, { count: disputes.length }))} ›
         </button>`
      : '';
    const injury = m.status !== 'volunteer' ? this._injuryOf(m) : null;
    const injuryChip = injury
      ? `<button type="button" data-player-sheet="${this.escape(key)}" data-sheet-tab="health"
                 style="align-self:flex-start; font-size:0.75rem; font-weight:800; cursor:pointer; padding:2px 8px; border-radius:4px;
                        background:${injury.status.colorBg || '#3a2e05'}; color:${injury.status.colorFg || '#fde68a'}; border:1px solid ${injury.status.colorBorder || '#d97706'};">
           ${this.escape(injury.label || injury.status.displayName)}</button>`
      : '';
    // In LA's pickup program right now — still a club member for dues
    // (the registration and its payments move with them; mig 1240).
    const pickupChip = m.variant === 'pickup'
      ? `<span title="${this.escape(this._sheetCopy('pickup_chip_title', 'Registration is in the LA pickup program right now — counts toward club dues'))}"
               style="align-self:flex-start; font-size:0.75rem; font-weight:800; padding:2px 8px; border-radius:4px; background:#1e293b; color:#a5f3fc; border:1px solid #0891b2;">
           ${this.escape(this._sheetCopy('pickup_chip', '🔁 Pickup'))}</span>`
      : '';
    return `
      ${MoneyBoard.cardOpen(key)}
        <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:8px;">
          <div style="font-weight:700; font-size:1rem;">${c.name}</div>
          <div style="display:flex; align-items:center; gap:6px; flex-wrap:wrap; justify-content:flex-end;">${c.prorateCell}${c.finesCells}${c.badge}${window.PlayerSheet ? PlayerSheet.button(key, { tab: 'money' }) : ''}</div>
        </div>
        ${m.personId ? `<div data-roster-standing="${m.personId}"></div>` : ''}
        ${pickupChip}
        ${injuryChip}
        ${banner}
        ${c.duesFree ? `<div style="font-size:0.8rem; color:#93c5fd; background:#172554; border:1px solid #2563eb; border-radius:6px; padding:6px 10px;">${this.escape(this._duesFreeCopy(m.status, 'note'))}</div>` : this.renderDueHero(m)}
        ${c.activityLine}
      </div>
    `;
  }

  _sheetKey(m) { return m.laUserId ? `la${m.laUserId}` : `p${m.personId}`; }
  _memberByKey(key) {
    for (const k of PaymentsScreen.ALL_TABS) {
      const hit = ((this.membersByTab[k] && this.membersByTab[k].members) || []).find((m) => this._sheetKey(m) === key);
      if (hit) return hit;
    }
    return null;
  }
  _sheetCopy(tier, fallback, tokens) {
    return (window.MessageCopy && MessageCopy.has('player_sheet', tier)) ? MessageCopy.block('player_sheet', tier, tokens || {}) : fallback;
  }
  _pendingDisputes(m) {
    return ((this.fineDisputesByPerson && this.fineDisputesByPerson.get(m.personId)) || []).filter((d) => d.amount != null);
  }

  // ⋯ / card tap → the player sheet, starting on `tab`.  #payments adds
  // what it holds to the sheet's fixed tabs.
  openPlayerSheet(key, tab) {
    if (!window.PlayerSheet) return;
    this._snapshotHistoryState();   // 👤 Full profile → back lands on this tab/search
    PlayerSheet.open({
      host: this.element,
      auth: this.auth,
      tab: tab || 'money',
      resolve: () => {
        const m = this._memberByKey(key);
        return m ? { personId: m.personId, laUserId: m.laUserId, firstName: m.firstName, lastName: m.lastName,
                     dob: m.dob ? this.fmtDob(m.dob) : '', email: m.email, phone: m.phone,
                     phoneLabel: m.phone ? this.fmtPhone(m.phone) : '', returnTo: 'payments', _row: m } : null;
      },
      extras: (p) => this._sheetExtras(p._row),
      onChange: () => this.renderMembers(),
    });
  }

  _sheetExtras(m) {
    const c = this._cardParts(m);
    const box = (title, html) => `
      <div style="border-top:1px dashed var(--border-color, #374151); padding-top:8px; margin-top:8px;">
        ${title ? `<div style="opacity:0.6; font-size:0.72rem; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:4px;">${title}</div>` : ''}
        ${html}
      </div>`;
    const actions = [c.laBtn, c.duesFree ? '' : c.pauseBtn + c.flagBtn].join('');
    const money = `
      ${c.duesFree ? `<div style="font-size:0.85rem; color:#93c5fd; background:#172554; border:1px solid #2563eb; border-radius:6px; padding:6px 10px;">${this.escape(this._duesFreeCopy(m.status, 'note'))}</div>` : this.renderDueHero(m)}
      <div style="display:flex; align-items:center; gap:6px; flex-wrap:wrap; margin-top:8px;">${c.prorateCell}${c.badge}</div>
      <div style="font-size:0.85rem; margin-top:8px;">${c.lastLine}</div>
      ${c.duesFree ? '' : `<div style="margin-top:6px;">${this.renderDueDateDropdown(m)}</div>`}
      <div style="font-size:0.8rem; opacity:0.75; margin-top:6px;">
        Lifetime: ${this.fmtMoney(m.totalPaid || 0)}${m.totalRefunded ? ` · refunded ${this.fmtMoney(m.totalRefunded)}` : ''}
        · ${m.txnCount || 0} payment${m.txnCount === 1 ? '' : 's'}
      </div>
      ${box('Recent (this month + last)', `<div style="font-size:0.8rem;">${c.recentHtml}</div>`)}
      ${actions ? box('', `<div style="display:flex; gap:6px; flex-wrap:wrap;">${actions}</div>`) : ''}`;
    const disputes = this._pendingDisputes(m);
    const fines = `${this.renderDisputeStrip(m)}
      ${c.finesCells ? `<div style="display:flex; gap:6px; flex-wrap:wrap; margin-top:8px;">${c.finesCells}</div>` : ''}
      <div style="display:flex; flex-direction:column; gap:8px; margin-top:8px;">${c.finesDetail.replace(/ hidden\n/g, '\n')}</div>`;
    return {
      person: '',
      contact: c.contactBtn ? `<div style="display:flex;">${c.contactBtn}</div>` : '',
      money: { html: money, flag: !!c.anyNotice },
      fines: { html: (disputes.length || c.finesCells) ? fines : '', flag: disputes.length > 0 },
      activity: c.activityLine,
    };
  }

  // One box per month of fines (row.fines from /api/payments/:program/
  // members, PersonFines, migration 460), styled like the Prorate cell.
  // The current month is still filling ("so far"); a finished month is
  // what goes on the next posting in LA together with the monthly dues
  // and any prorate.  The box is a button so the card's own click (open
  // the person) leaves it alone.
  // The bottom line of a box says where the posting stands, read from
  // the LA charges FH mirrors (owner 2026-09-27: "detect what a charge is
  // for by amount and timing").  A month's fines go on LA with the next
  // month's dues on its first Friday.
  _postingLine(posting, current) {
    if (!posting) return current ? 'so far' : 'none';
    const md = (iso) => { const d = this._parseIsoDateOnly(iso); return d ? `${d.getMonth() + 1}/${d.getDate()}` : ''; };
    const fmtAmt = (n) => (Number.isInteger(n) ? `$${n}` : `$${Number(n).toFixed(2)}`);
    switch (posting.status) {
      case 'posted':     return `✓ ${md(posting.postedOn)}`;
      case 'drift':      return `posted ${fmtAmt(Number(posting.postedAmount) || 0)}`;
      case 'not_posted': return 'NOT POSTED';
      case 'due':        return current ? 'so far' : `post ${md(posting.firstFriday)}`;
      default:           return current ? 'so far' : 'none';
    }
  }

  _postingColors(status, on) {
    if (status === 'not_posted' || status === 'drift') return { bg: '#3a2e05', fg: '#fde68a', border: '#d97706' };
    if (status === 'posted') return { bg: '#052e16', fg: '#86efac', border: '#15803d' };
    return on ? { bg: '#3a1f1f', fg: '#fca5a5', border: '#b91c1c' } : { bg: '#1e293b', fg: '#94a3b8', border: '#334155' };
  }

  _cellHtml({ cls, attrs, tip, colors, top, big, bottom }) {
    return `
        <button type="button" class="${cls}" ${attrs || ''}
                title="${this.escape(tip)}"
                style="display:inline-flex; flex-direction:column; align-items:center; justify-content:center;
                       min-width:52px; padding:3px 7px; margin-right:3px; box-sizing:border-box; cursor:pointer;
                       border:1px solid ${colors.border}; background:${colors.bg}; color:${colors.fg}; border-radius:3px;
                       font-variant-numeric:tabular-nums; vertical-align:middle; font-family:inherit;">
          <div style="font-size:0.55rem; font-weight:800; letter-spacing:0.06em; opacity:0.85;">${this.escape(top)}</div>
          <div style="font-size:0.95rem; font-weight:800; line-height:1.15;">${this.escape(big)}</div>
          <div style="font-size:0.5rem; font-weight:700; opacity:0.7; letter-spacing:0.04em;">${this.escape(bottom)}</div>
        </button>`;
  }

  // Bill wording (message_templates kind tuition_bill, migration 535).
  _billCopy(tier, tokens, fallback) {
    return (window.MessageCopy && MessageCopy.has('tuition_bill', tier)) ? MessageCopy.block('tuition_bill', tier, tokens) : fallback;
  }

  // The two bills the fines ride on (owner 2026-10-06: "it should work
  // like pro rate. i will then add it to total at end of month. so
  // instead of 35 they will owe 35+"):
  //   this  this month's bill = dues + last month's fines, with where it
  //         stands on LA (the dues charge and the fines posting together);
  //   next  next month's bill so far = dues + this month's fines.
  // Each carries finesMonth, the month whose fines are on it.
  _bills(f) {
    const months = (f && Array.isArray(f.months)) ? f.months : [];
    const d = f && f.dues;
    const out = { this: null, next: null };
    if (!d || !d.status || !months.length) return out;
    const rate = Number(d.rate) || 0;
    const cur = months[months.length - 1];
    const prev = months.find((mo) => !mo.current && mo.posting && mo.posting.month === d.month) || null;
    const prevFines = prev ? (Number(prev.total) || 0) : 0;
    const ps = prev && prev.posting ? prev.posting.status : 'nothing';
    // What LA holds of this bill: the dues, plus whatever went on as fines.
    const finesOnLa = (ps === 'posted' || ps === 'drift') ? (Number(prev.posting.postedAmount) || 0) : 0;
    let status = d.status;                       // posted | not_posted | due
    if (status === 'posted' && (ps === 'drift' || ps === 'not_posted' || (ps === 'due' && prevFines > 0))) status = 'short';
    out.this = { month: d.month, label: d.label, firstFriday: d.firstFriday, postedOn: d.postedOn, rate,
                 fines: prevFines, total: rate + prevFines, onLa: rate + finesOnLa, status,
                 finesMonth: prev ? prev.month : '', finesLabel: prev ? prev.label : '' };
    if (cur && cur.current && cur.posting) {
      const fines = Number(cur.total) || 0;
      out.next = { month: cur.posting.month, label: cur.posting.label, firstFriday: cur.posting.firstFriday, rate,
                   fines, total: rate + fines, finesMonth: cur.month, finesLabel: cur.label };
    }
    return out;
  }

  // "Oct bill: $35 dues + $2 Sep fines = $37" — the sum behind a bill box.
  _billLine(b, soFar) {
    const fmtAmt = (n) => (Number.isInteger(n) ? `$${n}` : `$${Number(n).toFixed(2)}`);
    const tokens = { month: b.label, dues: fmtAmt(b.rate), fines: fmtAmt(b.fines), fines_month: b.finesLabel,
                     total: fmtAmt(b.total), date: this.fmtDate(b.firstFriday) };
    if (!b.finesLabel) return this._billCopy('line_dues_only', tokens, `${b.label} bill: ${tokens.dues} dues`);
    return soFar
      ? this._billCopy('line_so_far', tokens, `${b.label} bill so far: ${tokens.dues} dues + ${tokens.fines} ${b.finesLabel} fines = ${tokens.total} — post ${tokens.date}`)
      : this._billCopy('line', tokens, `${b.label} bill: ${tokens.dues} dues + ${tokens.fines} ${b.finesLabel} fines = ${tokens.total}`);
  }

  _billState(b) {
    const fmtAmt = (n) => (Number.isInteger(n) ? `$${n}` : `$${Number(n).toFixed(2)}`);
    const md = (iso) => { const d = this._parseIsoDateOnly(iso); return d ? `${d.getMonth() + 1}/${d.getDate()}` : ''; };
    switch (b.status) {
      case 'posted':     return this._billCopy('posted', { date: md(b.postedOn) }, `✓ ${md(b.postedOn)}`);
      case 'short':      return this._billCopy('on_la', { amount: fmtAmt(b.onLa) }, `${fmtAmt(b.onLa)} on LA`);
      case 'not_posted': return this._billCopy('not_posted', {}, 'NOT POSTED');
      default:           return this._billCopy('post', { date: md(b.firstFriday) }, `post ${md(b.firstFriday)}`);
    }
  }

  // 🙋 Volunteer requests (mig 1222, owner 2026-11-10: an overdue man picks
  // ONE evening — Mon / Wed / Fri 5–7 PM — to help instead of paying; "You
  // approve first").  Make volunteer → club_volunteers (mig 704): $0
  // balance, no notices, not an alternate.  Words: kind volunteer_shift.
  async _loadVolunteerRequests() {
    const host = this.find('#pay-volunteers');
    if (!host) return;
    let list = [];
    try {
      const res = await this.auth.fetch('/api/volunteer/requests');
      const body = res.ok ? await res.json() : {};
      list = Array.isArray(body.requests) ? body.requests : [];
    } catch (_) { list = []; }
    if (!list.length) { host.innerHTML = ''; return; }
    const t = (tier, tokens) => (window.MessageCopy && MessageCopy.block('volunteer_shift', tier, tokens)) || '';
    const money = (n) => (Number.isInteger(Number(n)) ? `$${Number(n)}` : `$${Number(n).toFixed(2)}`);
    const btn = (bg) => `background:${bg}; color:#fff; border:0; border-radius:6px; padding:5px 10px; font-weight:700; font-size:0.8rem; cursor:pointer;`;
    host.innerHTML = `<div style="margin-bottom:var(--space-3); padding:10px 12px; border-radius:8px; border:1px solid #2563eb; background:rgba(37,99,235,0.12);">
      <div style="font-weight:800; margin-bottom:6px;">${this.escape(t('requests_heading'))} (${list.length})</div>
      ${list.map((r) => `<div data-pay-vol-row style="display:flex; justify-content:space-between; align-items:center; gap:8px; flex-wrap:wrap; padding:4px 0;">
          <span style="font-size:0.85rem;">${this.escape(t('request_line', { name: r.name, shift: r.shift, owed: money(r.owed), when: this.fmtDate(r.created_at) }))}</span>
          <span style="display:inline-flex; gap:6px;">
            <button type="button" data-pay-volunteer="${Number(r.id)}" data-decision="approve" style="${btn('#16a34a')}">${this.escape(t('approve'))}</button>
            <button type="button" data-pay-volunteer="${Number(r.id)}" data-decision="deny" style="${btn('#6b7280')}">${this.escape(t('deny'))}</button>
          </span>
        </div>`).join('')}
    </div>`;
  }

  async _decideVolunteer(id, decision) {
    try {
      const res = await this.auth.fetch(`/api/volunteer/requests/${id}`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ decision }) });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    } catch (err) { this._toast(`Could not save: ${err.message}`, 'error'); }
    this._loadVolunteerRequests();
    // Approved → 🙋 Volunteer, $0 balance: refetch for the new status.
    if (decision === 'approve') this.loadMembers(this.tab);
  }

  // Pending "I was there" disputes (mig 691), keyed by person, for the ⚖️
  // strip on each card.  A failure just leaves the strip off.
  async _loadFineDisputes() {
    try {
      const res = await this.auth.fetch('/api/fines/disputes');
      const body = res.ok ? await res.json() : {};
      const by = new Map();
      for (const d of (Array.isArray(body.disputes) ? body.disputes : [])) {
        if (!by.has(d.person_id)) by.set(d.person_id, []);
        by.get(d.person_id).push(d);
      }
      this.fineDisputesByPerson = by;
    } catch (_) { this.fineDisputesByPerson = new Map(); }
  }

  async _decideFineDispute(id, decision, tab) {
    try {
      const res = await this.auth.fetch(`/api/fines/disputes/${id}`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ decision }) });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    } catch (err) { this._toast(`Could not save: ${err.message}`, 'error'); }
    // Approve marks the player present, so the fine itself goes away —
    // refetch the tab for the new totals.
    this.loadMembers(tab || this.tab);
  }

  // ⚖️ one line per pending dispute, Approve / Deny on the card front
  // (owner 2026-11-10, mig 1210).  Words: the 'fines' rows from mig 691.
  renderDisputeStrip(m) {
    // A dispute with no live fine behind it (amount null — waived, or the
    // fine no longer applies) stays on #fines only.
    const list = ((this.fineDisputesByPerson && this.fineDisputesByPerson.get(m.personId)) || []).filter((d) => d.amount != null);
    if (!list.length) return '';
    const fmtAmt = (n) => (Number.isInteger(n) ? `$${n}` : `$${Number(n).toFixed(2)}`);
    const copy = (tier, tokens, fallback) =>
      (window.MessageCopy && MessageCopy.has('fines', tier)) ? MessageCopy.block('fines', tier, tokens) : fallback;
    const btn = (bg) => `background:${bg}; color:#fff; border:0; border-radius:6px; padding:5px 10px; font-weight:700; font-size:0.8rem; cursor:pointer;`;
    const tab = this.escape(m._tab || this.tab);
    return list.map((d) => {
      const amount = d.amount != null ? fmtAmt(Number(d.amount)) : '';
      const line = copy('dispute_line', { name: d.name, event: d.event, amount },
                        `${d.name} says they were at ${d.event} (${amount} no-show fine)`);
      return `
        <div class="pay-dispute-strip" style="display:flex; align-items:center; gap:8px; flex-wrap:wrap; font-size:0.82rem;
             background:#3a2e05; border:1px solid #d97706; border-radius:6px; padding:6px 10px;">
          <div style="flex:1; min-width:200px;">⚖️ ${this.escape(line)}${d.note ? ` — <i>“${this.escape(d.note)}”</i>` : ''}</div>
          <button type="button" data-pay-dispute="${d.id}" data-decision="approve" data-tab="${tab}" style="${btn('#059669')}">${this.escape(copy('dispute_approve', {}, 'Approve'))}</button>
          <button type="button" data-pay-dispute="${d.id}" data-decision="deny" data-tab="${tab}" style="${btn('#7f1d1d')}">${this.escape(copy('dispute_deny', {}, 'Deny'))}</button>
        </div>`;
    }).join('');
  }

  renderFinesCells(m) {
    const f = m && m.fines;
    if (!f || !Array.isArray(f.months) || !f.months.length) return '';
    const fmtAmt = (n) => (Number.isInteger(n) ? `$${n}` : `$${Number(n).toFixed(2)}`);
    const bills = this._bills(f);
    const finished = f.months.filter((mo) => !mo.current);
    const lastYm = finished.length ? finished[finished.length - 1].month : '';   // the "last" Friday→Friday period

    const finesCell = (mo) => {
      const n = Array.isArray(mo.items) ? mo.items.length : 0;
      const total = Number(mo.total) || 0;
      const p = mo.posting || null;
      const status = (!mo.current && p) ? p.status : '';
      const md = (iso) => { const d = this._parseIsoDateOnly(iso); return d ? `${d.getMonth() + 1}/${d.getDate()}` : ''; };
      const name = mo.from ? `${mo.label} (${md(mo.from)}–${md(mo.to)})` : mo.label;   // period dates, mig 1207
      const lines = n
        ? `${name} fines: ${n} — ` + mo.items.map((it) => `${this.fmtDate(it.startAt)} ${it.label} ${fmtAmt(it.amount)}`).join('; ')
        : `${name} fines: none${mo.current ? ' so far' : ''}`;
      // The last finished period: "$10 ($5)" — the total, and what is left
      // if every pending dispute is approved (owner 2026-11-10, mig 1210).
      const disputed = mo.month === lastYm
        ? (mo.items || []).filter((it) => it.dispute === 'pending').reduce((s, it) => s + (Number(it.amount) || 0), 0) : 0;
      const left = total - disputed;
      const big = disputed > 0
        ? this._billCopy('disputed_big', { total: fmtAmt(total), left: fmtAmt(left) }, `${fmtAmt(total)} (${fmtAmt(left)})`)
        : fmtAmt(total);
      const tip = lines + (p && (total > 0 || p.status === 'drift') ? ` · ${this._postingTip(mo, p)}` : '')
        + (disputed > 0 ? ` · ${this._billCopy('disputed_tip', { disputed: fmtAmt(disputed), left: fmtAmt(left) },
                                               `${fmtAmt(disputed)} under dispute — ${fmtAmt(left)} if approved`)}` : '');
      return this._cellHtml({ cls: 'pay-fines-cell', attrs: `data-fines-month="${this.escape(mo.month)}"`, tip,
                              colors: this._postingColors(status, total > 0),
                              top: `${mo.label.toUpperCase()} FINES`, big,
                              bottom: this._postingLine(mo.current ? null : p, mo.current) });
    };

    // A bill box: the amount to put on LA — dues + the fines riding on it.
    // Tap it for the fines behind the sum.
    const billCell = (b, next) => {
      if (!b) return '';
      const status = next ? '' : (b.status === 'short' ? 'drift' : b.status);
      const sum = this._billCopy(next ? 'sum_so_far' : 'sum', { dues: fmtAmt(b.rate), fines: fmtAmt(b.fines) },
                                 `${fmtAmt(b.rate)} + ${fmtAmt(b.fines)}${next ? ' so far' : ''}`);
      const bottom = next ? (b.fines > 0 ? sum : this._billState(b)) : this._billState(b);
      const tip = this._billLine(b, next) + (next ? '' : ` · ${this._billState(b)}`);
      return this._cellHtml({ cls: b.finesMonth ? 'pay-fines-cell' : 'pay-dues-cell',
                              attrs: b.finesMonth ? `data-fines-month="${this.escape(b.finesMonth)}"` : '', tip,
                              colors: this._postingColors(status, next ? b.fines > 0 : true),
                              top: this._billCopy('box_top', { month: b.label.toUpperCase() }, `${b.label.toUpperCase()} BILL`),
                              big: fmtAmt(b.total), bottom });
    };

    // Ledger order: a month's fines, then the bill they go on.
    return f.months.map((mo) => {
      let cell = finesCell(mo);
      if (bills.this && bills.this.finesMonth === mo.month) cell += billCell(bills.this, false);
      if (mo.current) {
        if (bills.this && !bills.this.finesMonth) cell = billCell(bills.this, false) + cell;
        cell += billCell(bills.next, true);
      }
      return cell;
    }).join('');
  }

  _postingTip(mo, p) {
    const fmtAmt = (n) => (Number.isInteger(n) ? `$${n}` : `$${Number(n).toFixed(2)}`);
    switch (p.status) {
      case 'posted':     return `added in LA on ${this.fmtDate(p.postedOn)} with ${p.label} dues`;
      case 'drift':      return `LA shows ${fmtAmt(Number(p.postedAmount) || 0)} charged ${this.fmtDate(p.postedOn)}, fines now total ${fmtAmt(Number(mo.total) || 0)}`;
      case 'not_posted': return `no matching LA charge — post with ${p.label} dues (first Friday was ${this.fmtDate(p.firstFriday)})`;
      case 'due':        return `post with ${p.label} dues on ${this.fmtDate(p.firstFriday)}`;
      default:           return '';
    }
  }

  // The month's line items, hidden until its box is tapped.
  renderFinesDetail(m) {
    const f = m && m.fines;
    if (!f || !Array.isArray(f.months) || !f.months.length) return '';
    const fmtAmt = (n) => (Number.isInteger(n) ? `$${n}` : `$${Number(n).toFixed(2)}`);
    const kindLabel = (k) => ({ match: 'Game', intrasquad: 'Intra Squad', practice: 'Practice' }[k] || k || '');
    const bills = this._bills(f);
    return f.months.map((mo) => {
      // The bill this month's fines go on, and where it stands.
      const bill = (bills.next && bills.next.finesMonth === mo.month) ? this._billLine(bills.next, true)
        : (bills.this && bills.this.finesMonth === mo.month) ? `${this._billLine(bills.this, false)} · ${this._billState(bills.this)}`
        : '';
      const items = Array.isArray(mo.items) ? mo.items : [];
      const rows = items.length
        ? items.map((it) => `
            <div style="display:flex; justify-content:space-between; gap:8px; padding:2px 0;">
              <span style="opacity:0.7; white-space:nowrap;">${this.fmtDate(it.startAt)}</span>
              <span style="flex:1;">${this.escape(kindLabel(it.eventKind))}${it.opponent ? ` vs ${this.escape(it.opponent)}` : ''} · ${this.escape(it.label)}</span>
              <span style="font-weight:700; color:#fca5a5;">${fmtAmt(it.amount)}</span>
            </div>`).join('')
        : `<div style="opacity:0.5; font-style:italic;">No fines${mo.current ? ' so far' : ''}</div>`;
      return `
        <div class="pay-fines-detail" data-fines-month="${this.escape(mo.month)}" hidden
             style="border:1px dashed #b91c1c; border-radius:6px; padding:6px 8px; font-size:0.75rem;">
          <div style="opacity:0.6; font-size:0.7rem; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:2px;">
            ${this.escape(mo.label)} fines · ${fmtAmt(Number(mo.total) || 0)}${mo.current ? ' so far' : ''}
          </div>
          ${rows}
          ${mo.posting && ((Number(mo.total) || 0) > 0 || mo.posting.status === 'drift') ? `<div style="margin-top:4px; opacity:0.8;">${this.escape(this._postingTip(mo, mo.posting))}</div>` : ''}
          ${bill ? `<div style="margin-top:4px; font-weight:700;">${this.escape(bill)}</div>` : ''}
          ${this._finesCopyButton(f, mo)}
        </div>`;
    }).join('');
  }

  // The billing cycle a month names runs first Friday → next month's first
  // Friday (owner 2026-11-07: "october billing cycle so first friday of oct
  // to first fri of nov").  Since mig 1207 the boxes ARE those periods —
  // the backend sends each one's from/to and its own items.
  _finesCycle(f, mo) {
    const md = (iso) => { const d = this._parseIsoDateOnly(iso); return d ? `${d.getMonth() + 1}/${d.getDate()}` : ''; };
    const etDay = (iso) => new Date(iso).toLocaleDateString('en-CA', { timeZone: 'America/New_York' });
    const items = (Array.isArray(mo.items) ? mo.items : []).map((it) => ({ ...it, day: etDay(it.startAt) }));
    return { items, from: md(mo.from), to: md(mo.to), total: items.reduce((s, it) => s + (Number(it.amount) || 0), 0) };
  }

  _finesCopyButton(f, mo) {
    const cyc = this._finesCycle(f, mo);
    if (!cyc.items.length) return '';
    const fmtAmt = (n) => (Number.isInteger(n) ? `$${n}` : `$${Number(n).toFixed(2)}`);
    const tokens = { month: mo.label, from: cyc.from, to: cyc.to, total: fmtAmt(cyc.total) };
    // One part per fine kind, in the order they first happened.
    const byKind = new Map();
    for (const it of cyc.items) {
      if (!byKind.has(it.kind)) byKind.set(it.kind, { label: it.label, amount: 0, dates: [] });
      const k = byKind.get(it.kind);
      k.amount += Number(it.amount) || 0;
      const [, mm, dd] = it.day.split('-').map(Number);
      k.dates.push(`${mm}/${dd}`);
    }
    const parts = [...byKind.values()].map((k) => this._billCopy('fines_desc_kind',
      { count: k.dates.length, label: k.label, amount: fmtAmt(k.amount), dates: k.dates.join(', ') },
      `${k.dates.length}× ${k.label} ${fmtAmt(k.amount)} (${k.dates.join(', ')})`));
    const text = `${this._billCopy('fines_desc_header', tokens, `${mo.label} fines ${cyc.from}–${cyc.to}: ${tokens.total}`)} — ${parts.join('; ')}`;
    const label = this._billCopy('fines_desc_button', tokens, `📋 Copy ${mo.label} fines for LA (${cyc.from}–${cyc.to}) · ${tokens.total}`);
    const toast = this._billCopy('fines_desc_copied', { month: mo.label }, `${mo.label} fines copied — paste into the LA invoice description.`);
    return `
          <button type="button" data-copy-fines="${this.escape(text)}" data-copy-fines-toast="${this.escape(toast)}"
                  title="${this.escape(text)}"
                  style="margin-top:6px; padding:4px 8px; border:1px solid #b91c1c; background:#3a1f1f; color:#fca5a5;
                         border-radius:4px; font-size:0.75rem; font-weight:700; cursor:pointer; font-family:inherit;">
            ${this.escape(label)}
          </button>`;
  }

  // RSVP + attendance trail for one card (row.activity from
  // /api/payments/:program/members, PersonActivity roll-up).
  //   🗓 Last RSVP: ✅ yes · practice 9/24   |   🏟 Last attended: match 9/20
  //   30 days: 3 yes · 5 no · 2 attended · 1 absent
  // 👻 GHOST is a judgement aid, not a rule: no present/late mark in the
  // window AND no "yes" RSVP in the window.  A never-heard-from row (no
  // RSVP, no mark, ever) says so instead — that can also mean their team
  // isn't being tracked yet, so it's kept distinct from a ghost.
  renderActivityLine(m) {
    const a = m && m.activity;
    if (!a) return '';
    const days = a.windowDays || 30;
    const when = (ref) => {
      if (!ref) return '';
      const kind = ref.eventKind ? this.escape(ref.eventKind) : 'event';
      const opp  = ref.opponent ? ` v ${this.escape(ref.opponent)}` : '';
      const date = this.fmtDate(ref.eventStartAt || ref.at);
      return `${kind}${opp} ${date}`;
    };
    const rsvpIcon = { yes: '✅', no: '❌' };
    const bits = [];
    if (a.lastRsvp) {
      bits.push(`<span title="Newest RSVP, answered ${this.fmtDate(a.lastRsvp.at)}">🗓 Last RSVP: ${rsvpIcon[a.lastRsvp.status] || ''} ${this.escape(a.lastRsvp.status)} · ${when(a.lastRsvp)}</span>`);
    } else {
      bits.push(`<span style="opacity:0.7;">🗓 No RSVP ever</span>`);
    }
    if (a.lastAttended) {
      bits.push(`<span title="Newest event marked present or late">🏟 Last attended: ${when(a.lastAttended)}</span>`);
    } else if (a.lastMarked) {
      bits.push(`<span title="Has attendance marks but none present/late">🏟 Never marked present · last ${this.escape(a.lastMarked.status)} ${when(a.lastMarked)}</span>`);
    } else {
      bits.push(`<span style="opacity:0.7;">🏟 No attendance marks</span>`);
    }
    const tally = `${days} days: ${a.rsvpYes30 || 0} yes · ${a.rsvpNo30 || 0} no · ${a.attended30 || 0} attended · ${a.absent30 || 0} absent`;

    const heardFrom = a.lastRsvp || a.lastMarked;
    const ghost  = heardFrom && !(a.attended30 > 0) && !(a.rsvpYes30 > 0);
    // Says yes, gets marked absent, never present in the window — not a
    // ghost by the RSVP rule, but the same drop conversation.
    const noShow = heardFrom && !ghost && !(a.attended30 > 0) && (a.absent30 > 0);
    const pill = (text, title, bg, fg, border) =>
      `<span title="${this.escape(title)}" style="padding:1px 6px; border-radius:999px; background:${bg}; color:${fg}; border:1px solid ${border}; font-weight:800;">${text}</span>`;
    const flag = ghost
      ? pill('👻 GHOST', `No present/late mark and no yes RSVP in the last ${days} days`, '#3a1f1f', '#fca5a5', '#b91c1c')
      : noShow
        ? pill('🙈 NO-SHOW', `RSVPs yes but only absent marks in the last ${days} days`, '#3a2e05', '#fbbf24', '#d97706')
        : (!heardFrom
            ? pill('no trail', 'No RSVP and no attendance mark on record — may be untracked rather than absent', '#1f2937', '#9ca3af', '#4b5563')
            : '');

    return `<div style="font-size:0.75rem; display:flex; flex-wrap:wrap; gap:8px; align-items:center;">
              ${flag}${bits.join('')}
              <span style="opacity:0.65;">${tally}</span>
            </div>`;
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

  _toast(msg, kind = 'info') {
    // Cheap, no-dep toast pinned near the top-right.  Self-clears after 3s.
    // kind: 'info' (amber) | 'success' (green) | 'error' (red).
    if (!msg) return;
    let host = document.getElementById('pay-toast-host');
    if (!host) {
      host = document.createElement('div');
      host.id = 'pay-toast-host';
      host.style.cssText = 'position:fixed; top:16px; right:16px; z-index:9999; display:flex; flex-direction:column; gap:8px; max-width:min(420px, calc(100vw - 32px));';
      document.body.appendChild(host);
    }
    const palette = kind === 'success' ? { border: '#16a34a', prefix: '✅ ' }
                  : kind === 'error'   ? { border: '#dc2626', prefix: '⚠️ ' }
                  :                      { border: '#d97706', prefix: '' };
    const t = document.createElement('div');
    t.textContent = palette.prefix + msg;
    t.style.cssText = `background:#0f172a; color:#e5e7eb; border:1px solid ${palette.border}; border-radius:6px; padding:10px 14px; box-shadow:0 4px 14px rgba(0,0,0,0.35); font-size:0.85rem; line-height:1.35; opacity:0; transition:opacity 0.15s ease-in;`;
    host.appendChild(t);
    requestAnimationFrame(() => { t.style.opacity = '1'; });
    setTimeout(() => {
      t.style.opacity = '0';
      setTimeout(() => t.remove(), 200);
    }, 3000);
  }

  // Full-screen semi-transparent overlay with a spinner. Blocks pointer
  // events so the operator can't fire another mutation while the current
  // one is in-flight. Used for actions that shuffle cards between
  // sections (setNextDue) because the card visibly jumps and without
  // a blocker it's easy to double-click or fat-finger a second row.
  _showBusy(msg) {
    let ov = document.getElementById('pay-busy-overlay');
    if (!ov) {
      ov = document.createElement('div');
      ov.id = 'pay-busy-overlay';
      ov.style.cssText = 'position:fixed; inset:0; z-index:10000; background:rgba(2,6,23,0.55); backdrop-filter:blur(2px); display:flex; align-items:center; justify-content:center; cursor:progress;';
      ov.innerHTML = `
        <style>
          @keyframes pay-spin { to { transform: rotate(360deg); } }
        </style>
        <div style="background:#0f172a; border:1px solid #334155; border-radius:10px; padding:20px 28px; display:flex; align-items:center; gap:14px; box-shadow:0 10px 30px rgba(0,0,0,0.5); min-width:220px;">
          <div style="width:22px; height:22px; border:3px solid #334155; border-top-color:#f59e0b; border-radius:50%; animation: pay-spin 0.8s linear infinite;"></div>
          <div id="pay-busy-msg" style="color:#e5e7eb; font-size:0.9rem; font-weight:500;"></div>
        </div>
      `;
      document.body.appendChild(ov);
    }
    const msgEl = ov.querySelector('#pay-busy-msg');
    if (msgEl) msgEl.textContent = msg || 'Working…';
    ov.style.display = 'flex';
  }
  _hideBusy() {
    const ov = document.getElementById('pay-busy-overlay');
    if (ov) ov.remove();
  }

  renderStatusBadge(status, daysOverdue) {
    let icon, label, bg, fg;
    // Day-count suffix — server sends an int for every card.  Shown
    // only on the two "money owed now" statuses so operators see how
    // long the clock has been running.  Never-paid with days=0 (no
    // reg date on file) falls back to the bare label.
    const days = Number.isFinite(daysOverdue) ? daysOverdue : 0;
    switch (status) {
      case 'current': icon='🟢'; label='Current'; bg='#052e1a'; fg='#86efac'; break;
      case 'behind':  icon='🟡'; label='Behind';  bg='#3a2e05'; fg='#fbbf24'; break;
      case 'volunteer': icon=''; label=this.escape(this._duesFreeCopy('volunteer', 'label')); bg='#172554'; fg='#93c5fd'; break;
      case 'injured':   icon=''; label=this.escape(this._duesFreeCopy('injured', 'label'));   bg='#3a2e05'; fg='#fbbf24'; break;
      case 'overdue':
        icon='🔴';
        label = days > 0 ? `Overdue · ${days}d` : 'Overdue';
        bg='#3a1f1f'; fg='#fca5a5';
        break;
      case 'never':
        icon='⚫';
        label = days > 0 ? `Never paid · ${days}d` : 'Never paid';
        bg='#1f2937'; fg='#e5e7eb';
        break;
      default:        icon='❓'; label=status || '—'; bg='#1f2937'; fg='#cbd5e1';
    }
    return `<span style="display:inline-block; padding:3px 8px; font-size:0.7rem; font-weight:700;
                          border-radius:4px; background:${bg}; color:${fg}; white-space:nowrap;">
              ${icon} ${label}
            </span>`;
  }

  // ── Due hero (top of card) ─────────────────────────────────────────
  // Big, unambiguous "here is what they owe and when" block that sits
  // directly under the name.  Two lines:
  //   1. Amount currently due (LA-authoritative outstanding balance).
  //   2. Due date (next_due_at from our DB) with day-count overdue.
  // Falls back gracefully when LA is unreachable or the row has no
  // next_due_at set.
  renderDueHero(m) {
    // ── amount ────────────────────────────────────────────────────
    // Prefer live LA outstanding balance (fresh every request).  When
    // that field isn't present (LA unreachable → no `laOutstanding-
    // Balance` on the row) fall back to snapshot cents captured on
    // last sync.  If neither is available, hide the amount line.
    let owedNum = null;
    let owedSource = '';
    if (Number.isFinite(m.laOutstandingBalance)) {
      owedNum = Number(m.laOutstandingBalance);
      owedSource = 'la';
    } else if (Number.isFinite(m.laAmountOwedCents) && Number.isFinite(m.laAmountPaidCents)) {
      owedNum = (m.laAmountOwedCents - m.laAmountPaidCents) / 100;
      owedSource = 'snapshot';
    }
    const owedFmt = (owedNum === null)
      ? null
      : this.fmtMoney(Math.max(0, owedNum));

    // ── due date ──────────────────────────────────────────────────
    let dueIso  = m.nextDueAt ? m.nextDueAt.slice(0, 10) : '';
    let dueDate = null;
    let dueLbl  = '';
    let overdue = false;
    let daysBy  = 0;
    if (dueIso) {
      const [y, mo, da] = dueIso.split('-').map(Number);
      dueDate = new Date(Date.UTC(y, mo - 1, da));
      dueLbl  = this._fmtFri(dueDate);
      const today0 = new Date();
      today0.setUTCHours(0, 0, 0, 0);
      const diffDays = Math.floor((today0.getTime() - dueDate.getTime()) / 86400000);
      overdue = diffDays > 0;
      daysBy  = Math.max(0, diffDays);
    }

    const amountColor = (owedNum && owedNum > 0.005) ? '#fca5a5' : '#86efac';
    const dateColor   = overdue ? '#fca5a5' : '#cbd5e1';

    // Months-behind bucket — server-computed (ceil(LA outstandingBalance /
    // monthly dues), migration 270) so active AND inactive-tier cards get
    // the same treatment. Only shown when it's actually ≥1 month.
    const monthsOverdue = Number.isFinite(m.monthsOverdue) ? m.monthsOverdue : null;
    const monthsBadge = (monthsOverdue !== null && monthsOverdue >= 1)
      ? `<span style="font-size:0.65rem; font-weight:700; padding:2px 6px; border-radius:3px;
                      background:#3a1f1f; color:#fca5a5; white-space:nowrap;">
           ${monthsOverdue} full month${monthsOverdue === 1 ? '' : 's'} behind
         </span>`
      : '';

    const amountBlock = (owedFmt !== null)
      ? `<div style="display:flex; align-items:baseline; gap:6px;">
           <span style="font-size:0.65rem; opacity:0.55; text-transform:uppercase; letter-spacing:0.5px;">Due</span>
           <span style="font-size:1.4rem; font-weight:800; color:${amountColor}; line-height:1;">
             ${owedFmt}
           </span>
           ${owedSource === 'snapshot'
             ? '<span style="font-size:0.6rem; opacity:0.4;">(cached)</span>'
             : ''}
           ${monthsBadge}
         </div>`
      : `<div style="font-size:0.75rem; opacity:0.5;">LA balance unavailable</div>`;

    const dateBlock = dueLbl
      ? `<div style="font-size:0.9rem; font-weight:600; color:${dateColor};">
           ${overdue ? 'Was due' : 'Due'} ${dueLbl}${overdue ? ` · ${daysBy}d late` : ''}
         </div>`
      : `<div style="font-size:0.8rem; opacity:0.55; font-style:italic;">No due date set — pick a Friday below</div>`;

    // Final-notice strip — real month names/date computed from the
    // data (see _finalNoticeDetails), not a hardcoded string. Only
    // shown when the backend flags this row (m.finalNotice).
    const fd = m.finalNotice ? this._finalNoticeDetails(m) : null;
    const finalNoticeBlock = fd
      ? `<div style="width:100%; font-size:0.78rem; font-weight:700; color:#fbbf24;
                    background:#3a2e05; border:1px solid #d97706; border-radius:4px;
                    padding:5px 8px;">
           ⚠️ Owes ${fd.owedPhrase} — ${fd.nextMonthName} also comes due ${fd.upcomingLabel}.
           Unpaid then = ${fd.monthsBehindAtRollover} months behind → paused per club policy.
         </div>`
      : '';

    return `
      <div style="background:#0b1220; border:1px solid ${overdue ? '#7f1d1d' : '#1f2937'};
                  border-radius:6px; padding:8px 10px;
                  display:flex; justify-content:space-between; align-items:center;
                  gap:10px; flex-wrap:wrap;">
        ${amountBlock}
        ${dateBlock}
        ${finalNoticeBlock}
      </div>
    `;
  }

  // ── Due-date dropdown helpers ───────────────────────────────────────  // Return the first Friday of the month containing `d` (Date, UTC).
  // Used to compute the three dropdown choices.
  _firstFridayOfMonth(d) {
    const y  = d.getUTCFullYear();
    const mo = d.getUTCMonth();
    const first = new Date(Date.UTC(y, mo, 1));
    const dow   = first.getUTCDay();                // 0=Sun..5=Fri
    const add   = (5 - dow + 7) % 7;
    return new Date(Date.UTC(y, mo, 1 + add));
  }

  // Return `{last, next, following}` — three 1st-Friday-of-month
  // Date objects relative to today (UTC).  User directive: "last 1st
  // friday, next 1st friday, and the first friday after that in case
  // someone pays early somehow".
  _fridayChoices() {
    const now      = new Date();
    const thisFri  = this._firstFridayOfMonth(now);
    // "next" = first 1st-Friday on or after today.  "last" = the one
    // in the previous month.  "following" = the one after "next".
    let next;
    if (thisFri.getTime() >= Date.UTC(
          now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate())) {
      next = thisFri;
    } else {
      next = this._firstFridayOfMonth(
        new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() + 1, 1)));
    }
    const last = this._firstFridayOfMonth(
      new Date(Date.UTC(next.getUTCFullYear(), next.getUTCMonth() - 1, 1)));
    const following = this._firstFridayOfMonth(
      new Date(Date.UTC(next.getUTCFullYear(), next.getUTCMonth() + 1, 1)));
    return { last, next, following };
  }

  // Format a Date as 'YYYY-MM-DD' (UTC).  This is the wire format the
  // backend POST /next-due endpoint accepts and the format we store
  // in the <option value=>.
  _isoDate(d) {
    const y  = d.getUTCFullYear();
    const mo = String(d.getUTCMonth() + 1).padStart(2, '0');
    const dd = String(d.getUTCDate()).padStart(2, '0');
    return `${y}-${mo}-${dd}`;
  }

  // Human label for a Friday date: "Fri Jul 3".
  _fmtFri(d) {
    const months = ['January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    const day = d.getUTCDate();
    // 11/12/13 are 'th'; otherwise 1→st, 2→nd, 3→rd, rest→th.
    const suffix = (day % 100 >= 11 && day % 100 <= 13)
      ? 'th'
      : ({1:'st', 2:'nd', 3:'rd'}[day % 10] || 'th');
    return `${months[d.getUTCMonth()]} ${day}${suffix}`;
  }

  // Render the due-date <select>.  Value = ISO date currently on the
  // member row (YYYY-MM-DD extracted from m.nextDueAt).  Options are
  // last / next / following 1st-Fridays.  When the current value
  // matches none of those, it's added as a fourth option so the display
  // doesn't lie about state.
  renderDueDateDropdown(m) {
    // Registration-id-less rows (rare — legacy) can't be POSTed to.
    if (!m.laRegistrationId) return '';
    const cur     = m.nextDueAt ? m.nextDueAt.slice(0, 10) : '';   // 'YYYY-MM-DD' or ''
    const choices = this._fridayChoices();
    const options = [
      { v: this._isoDate(choices.last),      lbl: this._fmtFri(choices.last) },
      { v: this._isoDate(choices.next),      lbl: this._fmtFri(choices.next) },
      { v: this._isoDate(choices.following), lbl: this._fmtFri(choices.following) },
    ];
    const knownValues = new Set(options.map((o) => o.v));
    // If the current value isn't in the standard 3, surface it as a
    // fourth option so the operator can see what's actually stored
    // (e.g. an old operator override or a la_seed date not aligned
    // with a Friday).  We still render just the date, no prefix.
    if (cur && !knownValues.has(cur)) {
      const [y, mo, da] = cur.split('-').map(Number);
      const d = new Date(Date.UTC(y, mo - 1, da));
      options.unshift({ v: cur, lbl: this._fmtFri(d) });
    }
    const src = m.nextDueSource
      ? `<span style="opacity:0.6; font-size:0.65rem; margin-left:6px;">
           ${m.nextDueSource === 'operator_override' ? '✎ overridden'
            : m.nextDueSource === 'payment_advance'  ? '↻ auto'
            : m.nextDueSource === 'la_seed'          ? '⇢ la'
            : this.escape(m.nextDueSource)}
         </span>`
      : '';
    return `
      <div style="display:flex; align-items:center; gap:6px; font-size:0.75rem; opacity:0.9;">
        <label style="opacity:0.75;">Due:</label>
        <select data-set-next-due="${m.laRegistrationId}"
                style="background:#0f172a; color:#e5e7eb;
                       border:1px solid #374151; border-radius:4px;
                       padding:3px 6px; font-size:0.75rem;">
          ${cur ? '' : '<option value="">— pick a Friday —</option>'}
          ${options.map((o) =>
            `<option value="${o.v}"${o.v === cur ? ' selected' : ''}>${o.lbl}</option>`
          ).join('')}
        </select>
        ${src}
      </div>
    `;
  }

  // POST the operator's chosen next_due_at, then re-fetch the current
  // tab's members payload so the badge reflects the new anchor.
  async setNextDue(laRegistrationId, isoDate) {
    if (!laRegistrationId || !isoDate) return;
    this._showBusy('Saving due date…');
    try {
      const res = await this.auth.fetch(
        `/api/payments/members/${laRegistrationId}/next-due`,
        {
          method:  'POST',
          headers: { 'Content-Type': 'application/json' },
          body:    JSON.stringify({ nextDueAt: isoDate }),
        }
      );
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200) || `HTTP ${res.status}`);
      }
      // Only reload the tab the operator is actually looking at, in
      // the foreground.  Every /api/payments/{tab}/members call
      // triggers a fresh LaProgramSync::run for that program (external
      // LA API round trip), so awaiting all four in Promise.all made
      // the "saving..." spinner wait on the slowest of four LA calls.
      // The other tabs are refreshed silently in the background - the
      // operator will see fresh data when they switch tabs, and the
      // "All Programs" bar recomputes from membersByTab whenever any
      // tab lands.
      const currentTabs = this.tab === 'all' ? [] : this._shardKeys().filter(k => this.membersByTab[k] !== null);
      await Promise.all(currentTabs.map(k => this.loadMembers(k)));
      // Fire-and-forget the other tabs.
      for (const k of PaymentsScreen.ALL_TABS) {
        if (currentTabs.includes(k)) continue;
        if (this.membersByTab[k] === null) continue;   // never loaded - leave for on-demand
        this.loadMembers(k).catch(() => {});
      }
      this._toast(`Due date set to ${isoDate}`, 'success');
    } catch (err) {
      this._toast(`Failed to set due date: ${err.message}`, 'error');
    } finally {
      this._hideBusy();
    }
  }

  // ── Transactions view (raw ledger — pre-existing behaviour) ─────────
  async loadTransactions(key) {
    const somethingToShow = !!this._currentTxns();
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
      if (this._showsTab(key) && this.view === 'transactions') this.renderTransactions();
    } catch (err) {
      this.txnsErrorByTab[key] = err.message;
      if (this._showsTab(key) && this.view === 'transactions') this.showError(err.message);
    } finally {
      this.txnsLoadingByTab[key] = false;
    }
  }

  renderTransactions() {
    const data = this._currentTxns();
    if (!data) {
      const err = this._currentError(this.txnsErrorByTab);
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

    this.find('#pay-summary').style.display = 'flex';
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
    const rows = (data.payments || []).filter(filter).sort(PaymentsScreen.byPaidAtDesc);
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
        <td style="padding:6px 10px; white-space:nowrap;">${this.fmtDateTime(p.paidAt)}</td>
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
        if (!silent && this._showsTab(key) && this.view === 'queue') {
          this.showError(this.flagsErrorByTab[key]);
        }
        return;
      }
    }
    const pid = this.programIdByTab[key];
    if (!silent) {
      const somethingToShow = !!this._currentFlags();
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
      if (this._showsTab(key)) {
        if (this.view === 'queue')   this.renderQueue();
        if (this.view === 'members') this.renderMembers();  // repaint badges
      }
    } catch (err) {
      this.flagsErrorByTab[key] = err.message;
      if (!silent && this._showsTab(key) && this.view === 'queue') {
        this.showError(err.message);
      }
    } finally {
      this.flagsLoadingByTab[key] = false;
    }
  }

  renderQueue() {
    const data = this._currentFlags();
    if (!data) {
      const err = this._currentError(this.flagsErrorByTab);
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
    this.find('#pay-summary').style.display = 'flex';
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
        ${window.PersonActions
          ? window.PersonActions.buttonsHtml(
              {
                leagueAppsUserId: f.laUserId,
                firstName: f.firstName,
                fullName: `${f.firstName || ''} ${f.lastName || ''}`.trim(),
              },
              { returnTo: 'payments', size: 'sm' }
            )
          : ''}
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
          : (window.PersonActions
              ? window.PersonActions.buttonsHtml(
                  {
                    leagueAppsUserId: f.laUserId,
                    firstName: f.firstName,
                    fullName: `${f.firstName || ''} ${f.lastName || ''}`.trim(),
                  },
                  { returnTo: 'payments', size: 'sm' }
                )
              : ''));
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
    // Merged tabs (Boys = Boys + Girls, All) hold rows from several
    // programmes — flag on the row's own, which loadMembers stamped.
    const cur = this._currentMembers();
    const owner = ((cur && cur.members) || []).find(m => String(m.laUserId) === String(laUserId));
    const programId = this.programIdByTab[(owner && owner._tab) || this.tab];
    if (!programId) {
      alert('Program id not loaded — reload the Members view first.');
      return;
    }
    // MVP: two native prompts.  Cheap, keyboard-friendly, no CSS needed.
    // (Can upgrade to <dialog> later without touching backend.)
    const amtStr = window.prompt(
      `Flag ${name.trim() || 'this member'} for charge.\n\nAmount in dollars (e.g. ${MessageCopy.duesPolicy.monthlyDuesUsd ?? ''} or 17.50):`,
      String(MessageCopy.duesPolicy.monthlyDuesUsd ?? '')
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
  // _renderStats() for the 📊 stats section.
  //
  // "This Month" is the CALENDAR month (1st → end, in the viewer's
  //   local time), not the 15th-to-14th dues cycle the backend uses for
  //   paid/overdue status (owner 2026-09-26: "it should be the actual
  //   month of sept etc sept 1 to end").  The $35 floor applies to
  //   status only; the money total sums every non-refund payment in the
  //   month (money is money) net of refunds in-month.  The backend
  //   returns transactions back to the previous calendar month, so the
  //   whole current month is always present.
  _summarize(data) {
    const members = (data && data.members) || [];
    const now = new Date();
    const y  = now.getFullYear();
    const mo = now.getMonth();
    const cycleStart = new Date(y, mo,     1);
    const cycleEnd   = new Date(y, mo + 1, 1);

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
      // Sum txns in the current calendar month. The backend returns
      // older ones too, so filter by [cycleStart, cycleEnd) here.
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
        (y - first.getFullYear()) * 12 +
        (mo - first.getMonth()) + 1;   // inclusive of both ends
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
  _combinedSummary(tabs = PaymentsScreen.ALL_TABS) {
    let netCollected     = 0;
    let thisMonth        = 0;
    let totalMembers     = 0;
    let outstandingCount = 0;
    let outstandingTotal = 0;
    let earliestMonthsElapsed = 0;   // biggest monthsElapsed = earliest start
    let inactiveCount = 0;
    const counts = { current: 0, behind: 0, overdue: 0, never: 0, volunteer: 0, injured: 0 };
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
      inactiveCount += d.inactiveCount || 0;
      loaded.push(k);
    }
    Object.assign(counts, (({ current, behind, overdue, never, volunteer, injured }) => ({ current, behind, overdue, never, volunteer, injured }))(this._countsFor(loaded)));
    const avgPerMonth         = earliestMonthsElapsed > 0 ? netCollected     / earliestMonthsElapsed : 0;
    const outstandingPerMonth = earliestMonthsElapsed > 0 ? outstandingTotal / earliestMonthsElapsed : 0;
    return {
      loaded, loadedCount: loaded.length, wanted: tabs.length,
      totalMembers, inactiveCount, counts, netCollected, thisMonth,
      monthsElapsed: earliestMonthsElapsed, avgPerMonth,
      outstandingCount, outstandingTotal, outstandingPerMonth,
    };
  }

  // 📊 The one stats section — counts the section the pill row picked
  // (Boys = Boys + Girls, Screen.sectionIncludes).  Multi-programme sums
  // add each programme's own estimate (fees differ per programme).
  _renderStats() {
    const el = this.find('#pay-stats');
    if (!el) return;
    const keys = this._shardKeys(this.tab);
    const s = this._combinedSummary(keys);
    const cell = (label, value, color, title) => ({ label, value, color, title });
    const c = s.counts;
    // ⏳ LoadProgress (mig 1246): the sums grow as each programme lands.  A
    // programme that failed counts as in (its error shows on the list), so
    // the bar never sticks.
    const done = keys.filter(k => this.membersByTab[k] || this.membersErrorByTab[k]).length;
    el.innerHTML = MoneyBoard.statsHtml({
      title: `📊 Stats · ${this._shardLabel(keys)}`,
      progress: { done, total: keys.length, what: this._duesFreeCopy('load', 'parts') || 'programs' },
      rows: [
        { title: 'PLAYERS', cells: [
          cell('Members', s.totalMembers - s.inactiveCount),
          cell('🟢 Paid up', c.current, '#86efac'),
          cell('🟡 Behind', c.behind, '#fbbf24'),
          cell('🔴 Overdue', c.overdue, '#fca5a5'),
          cell('⚫ Never paid', c.never, '#e5e7eb'),
          cell(this.escape(this._duesFreeCopy('volunteer', 'label')), c.volunteer, '#93c5fd'),
          cell(this.escape(this._duesFreeCopy('injured', 'label')), c.injured, '#fbbf24'),
          cell('🚫 Inactive', s.inactiveCount, '#c4b5fd'),
        ] },
        { title: 'MONEY IN', cells: [
          cell('💰 Collected', this.fmtMoney(s.netCollected), '#86efac'),
          cell('This month', this.fmtMoney(s.thisMonth), '#86efac'),
          cell('Avg / month', this.fmtMoney(s.avgPerMonth) + (s.monthsElapsed ? `<span style="opacity:0.5; font-size:0.72rem; font-weight:400;"> (${s.monthsElapsed} mo)</span>` : '')),
        ] },
        { title: 'OWED', cells: [
          cell('🔴 Outstanding', `${s.outstandingCount} member${s.outstandingCount === 1 ? '' : 's'}`, '#fca5a5', 'Never paid + overdue'),
          cell('Est. owed', `~${this.fmtMoney(s.outstandingTotal)}`, '#fca5a5', 'Outstanding × est. fee (median of paid members, per programme)'),
          cell('Est. owed / month', `~${this.fmtMoney(s.outstandingPerMonth)}`, '#fca5a5', 'Est. owed ÷ months elapsed'),
        ] },
      ],
    });
  }

  // ── Formatters ──────────────────────────────────────────────────────
  fmtMoney(v) {
    const n = Number(v);
    if (!isFinite(n)) return '$?';
    return `$${n.toFixed(2)}`;
  }

  // A transaction's full time in club time (Philadelphia) — "11/11/2026
  // 7:16 AM".  LA stamps every payment to the second; a UTC date alone
  // put evening payments on the next day.
  fmtDateTime(iso) {
    if (!iso) return '—';
    const d = new Date(iso);
    if (isNaN(d.getTime())) return this.escape(iso);
    return d.toLocaleString('en-US', {
      timeZone: 'America/New_York', month: 'numeric', day: 'numeric', year: 'numeric',
      hour: 'numeric', minute: '2-digit',
    }).replace(',', '');
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
