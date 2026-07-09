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
//
// Dues reporting is baked in (2026-07-04) so selection == dues-awareness:
//   • Each card carries a color-coded days-overdue pill (1-3 yellow, 4-6
//     orange, 7+ red) that replaces the old tiny paid-dot.
//   • Each column header shows "⚠ N OVERDUE" when any current roster member
//     is behind on dues — the coach sees per-team risk without clicking in.
//   • A trailing "🚨 Dues Owed" column surfaces players the admin has
//     parked as delinquent — the column strips them off every other
//     roster (mens-selection mutex).  Two action buttons per card
//     (lifted from PaymentsScreen):
//       LA  — opens LA Manager memberDetails for manual pause
//       ⏸  — copies the canonical pause-warning message to clipboard
//   • Backend used to block /assign for delinquent players (HTTP 409);
//     that gate was REMOVED 2026-07-04 pm per user directive.  Admin
//     now decides roster + Dues Owed column placement manually.
class MensRosterScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        /* Hide the default triangle marker on the CONTACT / ROSTER
           <summary> popovers so they render as clean buttons.  Scoped
           to this screen via .mr-move-details / .mr-contact. */
        .mr-move-details > summary,
        .mr-contact      > summary { list-style: none; }
        .mr-move-details > summary::-webkit-details-marker,
        .mr-contact      > summary::-webkit-details-marker { display: none; }
        .mr-move-details > summary::marker,
        .mr-contact      > summary::marker { display: none; content: ''; }

        /* Drag-and-drop cursor + insertion indicator (2026-07-04 pm).
           Cards on real columns are grabbable; while dragging, a bright
           border appears on the target edge so the drop point is
           obvious.  See onDragStart / onDragOver in mens-roster.js. */
        .mr-card[draggable="true"]        { cursor: grab; }
        .mr-card[draggable="true"]:active { cursor: grabbing; }
        .mr-card.mr-dragging              { opacity: 0.35; }
        .mr-card.mr-drop-before           { box-shadow: 0 -3px 0 0 #10b981 inset; }
        .mr-card.mr-drop-after            { box-shadow: 0  3px 0 0 #10b981 inset; }
        .mr-drop-zone.mr-drop-empty       { box-shadow: 0 0 0 2px #10b981 inset; border-radius: 4px; }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🎽 Roster Board</h1>
        <p class="subtitle">Live from LeagueApps — dues-aware roster selection with per-team overdue counts</p>
      </div>

      <div style="padding: var(--space-4);">
        <div id="mr-banner" style="margin-bottom: var(--space-3); padding: var(--space-3); border-radius: 6px; background: #f1f5f9; border: 1px solid #e2e8f0; display:flex; align-items:center; gap: var(--space-3); flex-wrap: wrap; font-size: 14px;">
          <span id="mr-banner-icon" style="font-size: 16px;">⏳</span>
          <span id="mr-banner-text" style="flex:1; min-width: 200px;">Pulling latest registrations from LeagueApps…</span>
          <button id="mr-refresh" class="btn btn-secondary" title="Force a fresh pull from LeagueApps (registrations + payments)" style="padding: 4px 10px; font-size: 13px;">🔄 Refresh</button>
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
      if (e.target.closest('#mr-refresh')) return this.load({ refreshLa: true });
      const moveOpt = e.target.closest('.mr-move-option');
      if (moveOpt) return this.onMoveOptionClick(moveOpt);
      const toggle = e.target.closest('.mr-roster-toggle');
      if (toggle) return this.onRosterToggleClick(toggle);
      const pill = e.target.closest('.mr-pill');
      if (pill) return this.onPillClick(pill);
      const laBtn = e.target.closest('.mr-la-open');
      if (laBtn) { window.open(laBtn.dataset.laUrl, '_blank', 'noopener'); return; }
      const rsvpBtn = e.target.closest('.mr-rsvp-elig');
      if (rsvpBtn) return this.openRsvpEligibilityModal(rsvpBtn);
      const pauseBtn = e.target.closest('.mr-copy-pause');
      if (pauseBtn) return this._copyPauseMessage(pauseBtn);
      // PAY-reminder click log (2026-07-06).  Fire-and-forget; the sms:
      // link still navigates.  See _logPayReminder for details.
      const payLog = e.target.closest('.mr-pay-log');
      if (payLog) this._logPayReminder(payLog);
    });

    // Drag-and-drop reorder (2026-07-04 pm).  Native HTML5 events wired
    // via delegation on the screen element so re-renders don't leak
    // listeners.  See onDragStart / onDragOver / onDrop below.
    this.element.addEventListener('dragstart', e => this.onDragStart(e));
    this.element.addEventListener('dragend',   e => this.onDragEnd(e));
    this.element.addEventListener('dragover',  e => this.onDragOver(e));
    this.element.addEventListener('dragleave', e => this.onDragLeave(e));
    this.element.addEventListener('drop',      e => this.onDrop(e));

    // Billing badge click handling (edit + mark-billed) is owned by the
    // shared helper; it re-renders via this.load() on success.
    if (window.BillingBadge) {
      window.BillingBadge.wire(this.element, this.auth.fetch.bind(this.auth), () => this.load());
    }
    // Initial load always refreshes LA — the singleton model cache is
    // empty on backend boot, and this is the moment the operator opens
    // the board, so we want the truthiest possible snapshot.
    this.load({ refreshLa: true });
  }

  setBanner({ icon, text, showRefresh = true }) {
    // Refresh button is always visible now (user directive 2026-07-06:
    // "always for boys and men etc").  showRefresh is retained for API
    // compatibility but defaulted true; callers can pass false to hide.
    const i = this.find('#mr-banner-icon');
    const t = this.find('#mr-banner-text');
    const r = this.find('#mr-refresh');
    if (i) i.textContent = icon;
    if (t) t.textContent = text;
    if (r) r.style.display = showRefresh ? '' : 'none';
  }

  async load({ refreshLa = false } = {}) {
    const loading = this.find('#mr-loading');
    const errEl   = this.find('#mr-error');
    const list    = this.find('#mr-list');
    if (loading) loading.style.display = '';
    if (errEl)   errEl.style.display   = 'none';
    if (list)    list.style.display    = 'none';
    this.setBanner({
      icon: '⏳',
      text: refreshLa
        ? 'Pulling latest registrations from LeagueApps…'
        : 'Reloading roster from cache…',
    });

    try {
      const t0  = performance.now();
      // refreshLa=1 → backend does a live LA fetch + payment sync.
      // Otherwise the backend serves its cached snapshot so mid-session
      // reloads (e.g. after a move) don't wait on LeagueApps.
      const url = refreshLa
        ? '/api/mens-roster?refreshLa=1'
        : '/api/mens-roster';
      const res = await this.auth.fetch(url);
      if (!res.ok) {
        const body = await res.text();
        throw new Error(body.slice(0, 200) || `HTTP ${res.status}`);
      }
      const data = await res.json();
      const elapsed = ((performance.now() - t0) / 1000).toFixed(1);
      this._data = data;

      if (loading) loading.style.display = 'none';
      if (list)    list.style.display    = '';

      // Extend the banner with delinquency headline numbers so the coach
      // knows the state of the club before scanning columns.  Backend
      // exposes these under top-level `data.delinquency`.
      const dq = data.delinquency || {};
      const overduePct = data.total > 0
        ? Math.round(((dq.overdueCount || 0) / data.total) * 100)
        : 0;
      const dqText = (dq.overdueCount > 0 || dq.duesOwedCount > 0)
        ? ` · ⚠ ${dq.overdueCount || 0}/${data.total} overdue (${overduePct}%) · 🚨 ${dq.duesOwedCount || 0} dues owed`
        : '';
      this.setBanner({
        icon: '✓',
        text: `${data.total} player${data.total === 1 ? '' : 's'} loaded in ${elapsed}s · ${data.unassignedCount} unassigned${dqText}`,
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

    // Columns are data-driven from `data.columns` (roster_columns with
    // domain='mens', not archived).  All non-Unassigned columns share
    // mutex_group='mens-selection' at the DB layer, so admin clicks
    // one move button and the row atomically leaves the others.
    //
    // The old "Dues Owed" column (team 910) was retired 2026-07-07 via
    // migration 100 — the OVERDUE chip on each card + the dedicated
    // /mens-delinquent screen already surface who owes dues, and
    // parking warm bodies in a sin-bin cost playable spots.  The
    // `daysOverdue` + `delinquencyState='dues_owed'` fields are still
    // emitted per-player so the chip + banner keep working.
    const cols = [
      { teamId: 0, label: '📦 Unassigned', color: '#475569', count: (data.unassigned || []).length, isUnassigned: true },
      ...data.columns,
    ];

    container.innerHTML = `
      <div style="display:flex; align-items:center; gap:var(--space-3); flex-wrap:wrap; margin-bottom:var(--space-3); padding:var(--space-2) var(--space-3); background:var(--bg-secondary); border-radius:var(--radius-md);">
        <span style="opacity:0.7; font-size:0.8rem; font-weight:600;">Columns:</span>
        ${cols.map(c => {
          const count = c.isUnassigned ? c.count : ((data.buckets[String(c.teamId)] || []).length);
          const cap = c.maxRoster != null ? `(${count}/${c.maxRoster})` : `(${count})`;
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
  // wider when there are many (so the big move buttons still fit).
  colMinWidth(n) {
    if (n <= 4) return '155px';
    if (n <= 6) return '145px';
    return '155px';
  }

  renderColumn(col, data) {
    // Data source: Unassigned pulls from data.unassigned (no active team
    // rows); every real column pulls from data.buckets keyed by teamId.
    const players = col.isUnassigned
      ? (data.unassigned || [])
      : (data.buckets[String(col.teamId)] || []);

    let countHtml;
    if (col.maxRoster != null) {
      const overFull = players.length >= col.maxRoster;
      const pct      = col.maxRoster ? players.length / col.maxRoster : 0;
      const nearFull = !overFull && pct >= 0.85;
      const fc = overFull ? '#ef4444' : nearFull ? '#f59e0b' : '#10b981';
      const pctText  = `${Math.round(pct * 100)}%`;
      const left     = col.maxRoster - players.length;
      const detail   = overFull
        ? `${pctText} ⚠`
        : `${left} left · ${pctText}`;
      countHtml = `<span style="font-size:0.85rem; font-weight:600; color:${fc}; white-space:nowrap;">${players.length}/${col.maxRoster} · ${detail}</span>`;
    } else {
      countHtml = `<span style="opacity:0.6; font-size:0.85rem;">${players.length}</span>`;
    }

    const renderList = (list) => list.map((p, i) => this.renderPlayer(p, data.columns, col, i + 1)).join('');

    const body = players.length === 0
      ? '<div style="opacity:0.5; font-size:0.85rem;">(empty)</div>'
      : renderList(players);

    // Column-level dues risk: how many players in this column are
    // currently overdue.  Coach uses this to spot at-a-glance which
    // rosters need attention.
    const overdueInCol = players.filter(p => (p.daysOverdue || 0) >= 1).length;
    const overdueHtml = overdueInCol > 0
      ? `<div style="margin-bottom:6px; padding:3px 6px; background:#3a1f1f; color:#fca5a5; border:1px solid #7f1d1d; border-radius:3px; font-size:0.65rem; font-weight:700; letter-spacing:0.05em; text-align:center;">⚠ ${overdueInCol} OVERDUE</div>`
      : '';

    return `
      <div style="background:var(--bg-secondary); border-radius:var(--radius-md); padding:8px; border-top:3px solid ${col.color};">
        <div style="display:flex; justify-content:space-between; align-items:baseline; margin-bottom:6px; gap:6px;">
          <strong style="font-size:0.85rem;">${col.label}</strong>
          ${countHtml}
        </div>
        ${overdueHtml}
        <div class="mr-drop-zone" data-drop-team-id="${col.isUnassigned ? '' : col.teamId}"
             style="display:flex; flex-direction:column; gap:8px; min-height:8px;">
          ${body}
        </div>
      </div>
    `;
  }

  renderPlayer(p, columns, col, position) {
    // Card redesign (2026-07-04): the coach's primary action on this
    // board is "move player X to roster Y".  Everything else (contact,
    // dues action) is secondary.  So the card leads with a big 3-button
    // roster-selector row (Unassigned / APSL / Liga 1) and drops the
    // tiny legacy pills entirely.  Contact + dues actions are still
    // present but sized so they're readable, not decorative.

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
    const smsHref = p.phone ? `sms:${p.phone}?&body=${encodeURIComponent(smsBody)}` : null;
    const telHref = p.phone ? `tel:${p.phone}` : null;

    // Full DOB (e.g. "3/10/2008").
    let dobShort = '';
    if (p.birthDate) {
      const d = new Date(`${p.birthDate}T00:00:00Z`);
      dobShort = isNaN(d.getTime())
        ? p.birthDate
        : d.toLocaleDateString('en-US', { month: 'numeric', day: 'numeric', year: 'numeric', timeZone: 'UTC' });
    }

    // Dues status — consolidated into BillingBadge.renderBalance().
    // User directive 2026-07-05 pm: "use only 1 section of card for
    // financial info".  The BAL cell now carries paid/owed/late signal
    // and its own colour scheme; a separate chip here was duplicative.
    // rawDays + hasUnpaidBalance are still computed so the delinquency
    // action buttons (PAY, card border colour) stay tier-aware.
    const rawDays          = p.daysOverdue || 0;
    const balanceNum       = Number(p.outstandingBalance) || 0;
    const paidStatus       = p.paymentStatus === 'PAID' || p.paymentStatus === 'WAIVED';
    const hasUnpaidBalance = balanceNum > 0 && !paidStatus;
    const days             = rawDays >= 1 ? rawDays : (hasUnpaidBalance ? 1 : 0);
    const daysAreExact     = rawDays >= 1;

    // Payment history is rendered exclusively by the shared BillingBadge
    // component (see billing-badge.js → renderLastPaid).  We used to
    // render a duplicate "Payments · May – Jul" block here but it was
    // showing the same data as "RECENT PAYMENTS" — dropped 2026-07-04 pm.

    // ---- Move-to-roster buttons ----------------------------------------
    //
    // Four hard-coded targets, all mutually exclusive at the DB level
    // (mens-selection mutex_group on 35 / 120 / 121 — migrations 085 +
    // 101).  APSL (35), Liga 1 (120), Liga 2 (121) are the real
    // division teams; Unassigned (0) means "remove from whichever real
    // team they're on".  Practice + Pickup are all-hands teams
    // (backfilled server-side) so they never appear as buttons.
    const assignedSet = new Set(p.teamIds || []);
    const isOnApsl     = assignedSet.has(35);
    const isOnLiga1    = assignedSet.has(120);
    const isOnLiga2    = assignedSet.has(121);
    const currentTeamId = isOnApsl ? 35 : isOnLiga1 ? 120 : isOnLiga2 ? 121 : 0;

    const targets = [
      { id: 0,   label: 'Unassigned', color: '#475569' },
      { id: 35,  label: 'APSL',       color: '#2563eb' },
      { id: 120, label: 'Liga 1',     color: '#0891b2' },
      { id: 121, label: 'Liga 2',     color: '#14b8a6' },
    ];
    // Shared button style — as thin as legible.  Zero vertical padding
    // plus a tight line-height give ~11-12 px total height while the
    // sides keep a proper 5 px cushion.  All actions (move, delinq,
    // contact, payments pill) share this base so they align.
    const btnBase = 'padding:0 5px; font-size:0.66rem; font-weight:800; letter-spacing:0.02em; border-radius:3px; line-height:1.35; white-space:nowrap;';

    // ── Move-to-roster: <details> popover ─────────────────────────
    // Same popover pattern as CONTACT below.  Summary shows the
    // player's current team (color-coded); opening it reveals the
    // four options as click-to-move buttons.  Mutex enforcement is
    // still server-side (mens-selection group at the DB layer).
    const activeTarget = targets.find(t => t.id === currentTeamId) || targets[0];
    const optBtns = targets.map(t => {
      const active = t.id === currentTeamId;
      const style = active
        ? `background:${t.color}; color:#fff; border:1px solid ${t.color}; cursor:default; opacity:0.85;`
        : `background:transparent; color:${t.color}; border:1px dashed ${t.color}88; cursor:pointer;`;
      return `<button class="mr-move-option" type="button"
                      data-user-id="${p.leagueAppsUserId}"
                      data-target-team-id="${t.id}"
                      data-current-team-id="${currentTeamId}"
                      ${active ? 'disabled' : ''}
                      title="${active ? 'Currently on ' + t.label : 'Move to ' + t.label}"
                      style="${btnBase} font-size:0.82rem; padding:2px 7px; ${style} text-align:left;">
                ${active ? '✓ ' : ''}${t.label.toUpperCase()}
              </button>`;
    }).join('');
    const moveSelect = `
      <details class="mr-move-details" style="position:relative; display:inline-block;">
        <summary style="${btnBase} font-size:0.85rem; padding:2px 8px; background:${activeTarget.color}; color:#fff; border:1px solid ${activeTarget.color}; cursor:pointer; user-select:none;"
                 title="Move ${this.escape(p.firstName || 'player')} to another column">
          ${this.escape(activeTarget.label.toUpperCase())} ▾
        </summary>
        <div style="position:absolute; top:100%; left:0; z-index:20; margin-top:2px; display:flex; flex-direction:column; gap:2px; background:#0f172a; padding:3px; border-radius:4px; box-shadow:0 4px 12px rgba(0,0,0,0.45); border:1px solid #334155; min-width:100%;">
          ${optBtns}
        </div>
      </details>`;

    // Reserve/On-Roster toggle removed 2026-07-04 (pm) per user directive:
    // column membership is the whole game.  Match-day roster selection
    // lives on a separate lineups screen.

    // ---- Delinquency action buttons (LA + Pay + Pause) -----------------
    // Shortened labels (2026-07-04 pm) so they don't dominate the row.
    // "LA MANAGER" → "LA"; "⏸ COPY PAUSE" → "⏸ PAUSE".  Tooltip still
    // carries the full description for anyone hovering.
    //
    // 💸 PAY (2026-07-05) — opens native SMS with a pre-filled payment
    // reminder that includes the outstanding amount + LA dashboard link.
    // Covers two failure modes the coach can't fix from admin side:
    //   (a) card on file but charge failed / expired
    //   (b) no card on file at all (LA only saves on a successful $1)
    // In both cases the player must log in and either update the card
    // or add one.  LA's public API doesn't expose card-on-file status
    // (verified 2026-07-05), so one universal message covers both.
    //
    // LA quick-jump button (2026-07-05, per user): always visible for
    // any player with a leagueAppsUserId — not just overdue ones —
    // so the coach can eyeball LA payment status for PAID players too.
    // Hoisted out of the delinq-only block.
    const laBtn = p.leagueAppsUserId
      ? `<button class="mr-la-open" type="button" data-la-url="${this.laManagerUrl(p.leagueAppsUserId)}"
                 title="Open ${this.escape(p.firstName || 'player')} in LA Manager"
                 style="${btnBase} border:none; cursor:pointer; background:#7c3aed; color:#fff;">
           LA
         </button>`
      : '';
    // RSVP-eligibility popup trigger (2026-07-07).  Small button next
    // to LA — opens a modal with 6 checkboxes (APSL / Liga 1 / Liga 2 /
    // Adult / Practice / Pickup).  Reads from GET /rsvp-eligibility
    // on open, writes via PUT on save.  Server-side is the source of
    // truth; the button carries no state itself.
    const rsvpEligBtn = p.leagueAppsUserId
      ? `<button class="mr-rsvp-elig" type="button"
                 data-user-id="${p.leagueAppsUserId}"
                 data-name="${this.escape(p.fullName || '')}"
                 title="Configure which teams ${this.escape(p.firstName || 'this player')} can RSVP for"
                 style="${btnBase} border:none; cursor:pointer; background:#0ea5e9; color:#fff;">
           RSVP
         </button>`
      : '';
    let delinqBtns = '';
    // Prorate context (2026-07-09) — if the player is a mid-cycle
    // signup who hasn't yet paid the full $35 for the partial cycle,
    // the PAY reminder should explain the prorate math instead of
    // parroting a generic "$35 dues past due" line.  Also opens the
    // PAY button for fresh signups (days=0) so the coach can nudge
    // them BEFORE the invoice fails — the whole point of the prorate
    // cell is to prompt the coach to add the LA charge NOW.
    const pr = (window.BillingBadge && window.BillingBadge.projectedProrate)
      ? window.BillingBadge.projectedProrate(p)
      : null;
    const prorateOwed = !!(pr && pr.amount > 0);
    if ((days >= 1 || prorateOwed) && p.leagueAppsUserId) {
      // Amount preference order (2026-07-09 owner directive on LA
      // Balance Due being manually edited):
      //   1. LA outstandingBalance   (authoritative when set)
      //   2. computed prorate amount (mid-cycle signup fallback)
      //   3. nextBillAmount          (monthly expectation)
      //   4. EXPECTED_MONTHLY_AMOUNT (final fallback)
      const proAmt   = prorateOwed && pr && pr.amount > 0 ? pr.amount : null;
      const nbAmt    = p.nextBillAmount > 0 ? p.nextBillAmount : null;
      const amountNum = (p.outstandingBalance > 0)
        ? p.outstandingBalance
        : (proAmt != null ? proAmt : (nbAmt != null ? nbAmt : 35));
      const amountStr = Number.isInteger(amountNum) ? `$${amountNum}` : `$${amountNum.toFixed(2)}`;
      // daysStr carries the whole "N days past due" phrase (or the
      // generic "past due") so we don't have to sprinkle "past due"
      // into every template.
      const daysStr   = daysAreExact
        ? `${days} day${days === 1 ? '' : 's'} past due`
        : 'past due';
      const payUrl    = 'https://lighthouse1893.leagueapps.com/dashboard';
      // Three-tier body scaled to delinquency severity (2026-07-05):
      //   1–3 days  → gentle nudge; assume card-on-file issue
      //   4–6 days  → firmer, team-aware: mention *temporary* demotion
      //               one tier down (APSL→Liga 1, Liga 1→Liga 2)
      //   7+ days   → same tone; state the demotion is what has to happen
      //               to keep the higher-tier spot open for paid members
      //
      // Rewritten 2026-07-08 per user directive:
      //   • Drop "removed from all rosters / replaced" language — we do
      //     NOT have a Lighthouse League feeder yet, so those threats
      //     were fiction.  We're recruiting to fill APSL / Liga 1 /
      //     Liga 2 and don't want to cut anyone.
      //   • Lead with "check your card on file" — most overdue accounts
      //     are just declined/expired cards, not bad-faith non-payers.
      //   • Every tier ties back to the club goal: fill three teams.
      //   • Liga 2 + Lighthouse Adult → no demotion, collect only.
      //   • Voice: warm, signed from "Lighthouse 1893" (dropped the
      //     Financial Dept framing — felt collections-bot).
      const firstNameStr = p.firstName ? ` ${p.firstName}` : '';
      const isDuesOwedState = p.delinquencyState === 'dues_owed' || days >= 7;

      // Determine the player's top selection-team tier for demotion
      // wording.  Mens selection teams are mutex-grouped, so a player
      // should be on at most one of {APSL, Liga 1, Liga 2, LL Adult}.
      //   35  = APSL             → demote to Liga 1
      //   120 = Liga 1           → demote to Liga 2
      //   121 = Liga 2           → collect only
      //   122 = Lighthouse Adult → collect only
      //   (unassigned)           → collect only (no team spot to lose)
      const tids = Array.isArray(p.teamIds) ? p.teamIds : [];
      let demotionTarget = null;  // "Liga 1" | "Liga 2" | null
      let currentTierName = null; // "APSL"   | "Liga 1" | null
      if (tids.includes(35))        { currentTierName = 'APSL';   demotionTarget = 'Liga 1'; }
      else if (tids.includes(120))  { currentTierName = 'Liga 1'; demotionTarget = 'Liga 2'; }

      // Copy rewritten 2026-07-09 per user directive: "for Men we will
      // run the card. for parents we are not running cards until aug 7.
      // we are asking them to pay. if mens card don't run we are
      // asking them same as parents."
      //
      // → Mens IS running cards.  A PAY button on a mens card means
      //   the charge on the card on file didn't clear — so the copy
      //   leads with "card didn't clear, please pay or update card".
      //   Two variants:
      //     (a) prorate — mid-current-cycle signup: explain that July
      //         dues are prorated and use the LA outstandingBalance
      //         (which the owner manually edits per player) as the
      //         authoritative amount to pay — no on-the-fly $ math
      //         that could contradict what LA shows.
      //     (b) normal  — July $35 didn't clear on card, please pay
      //         / update card.
      //   Both point to the LA dashboard.
      let payBody;
      if (prorateOwed) {
        const regShort = pr.regDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
        payBody = `Hi${firstNameStr}, welcome to Lighthouse 1893! Since you registered on ${regShort} (mid-cycle), your July dues are prorated for the ${pr.daysRemain} of ${pr.cycleDays} days remaining — ${amountStr} for July. Looks like the card on file didn't clear — usually just an expired or declined card. Gentle reminder to log in and pay ${amountStr} or update your card on file when you get a moment: ${payUrl}. Thanks!`;
      } else {
        payBody = `Hi${firstNameStr}, gentle reminder from Lighthouse 1893 — your July dues (${amountStr}) didn't clear on the card on file. Usually just an expired or declined card. When you get a moment, please log in and pay or update your card: ${payUrl}. Thanks!`;
      }
      const payHref   = p.phone ? `sms:${p.phone}?&body=${encodeURIComponent(payBody)}` : null;
      const payBtn    = payHref
        ? `<a href="${payHref}"
              class="mr-pay-log"
              data-la-user-id="${p.leagueAppsUserId || ''}"
              data-method="sms"
              data-amount="${amountNum != null ? amountNum : ''}"
              data-days-overdue="${daysAreExact ? days : ''}"
              data-tier="${daysAreExact ? (isDuesOwedState ? '7+' : (days >= 4 ? '4-6' : '1-3')) : ''}"
              title="Text ${this.escape(this.formatPhone(p.phone))} a payment reminder with LA link"
              style="${btnBase} border:none; cursor:pointer; background:#059669; color:#fff; text-decoration:none;">
             💸 PAY
           </a>`
        : '';
      // Last-reminder pill so admin sees "already texted 2h ago" first.
      const lastReminderPill = window.BillingBadge && window.BillingBadge.renderLastPayReminder
        ? window.BillingBadge.renderLastPayReminder(p)
        : '';
      delinqBtns = `
        ${lastReminderPill}${payBtn}`;
    }

    // ── Football Home invite copy (2026-07-06) ─────────────────────
    //
    // Plain sms:/mailto: deep-links pre-filled with a short onboarding
    // message pointing at https://footballhome.org.  No magic-link
    // token is minted — the player logs in with Google (same email as
    // LeagueApps) or sets a password.  Magic-link is reserved for
    // event-specific "tap to RSVP for Tue" nudges.
    //
    // Built unconditionally so the CONTACT popover can always offer
    // an INVITE action, even for players who've already signed in
    // (useful for re-nudging lapsed users).  The outer JOIN cluster
    // next to the FH pill stays gated on "never signed in" so the
    // roster still visually flags who hasn't onboarded.
    const firstNameForJoin = p.firstName || 'there';
    const inviteUrl = 'https://footballhome.org';
    const inviteSmsBody = `Hey ${firstNameForJoin} — Lighthouse 1893 is using ${inviteUrl} for weekly RSVPs. Log in with the Google account you use for LeagueApps (or set a password) to see this week's practices, games and pickups and RSVP YES / NO / MAYBE to all of them. Thanks!`;
    const inviteEmailSubject = 'Football Home — Lighthouse 1893 weekly RSVPs';
    const inviteEmailBody = [
      `Hi ${firstNameForJoin},`,
      '',
      `Lighthouse 1893 is rolling out ${inviteUrl} so we have a clearer picture of who's coming each week.`,
      '',
      `Head to ${inviteUrl} and sign in with the same Google account you use for LeagueApps (or set a password on the sign-in page). From your home screen you'll see this week's practices, games and pickups and can RSVP YES / NO / MAYBE to all of them in one tap.`,
      '',
      'You can also set default availability by day-of-week + event type so the page auto-fills going forward.',
      '',
      '— Lighthouse Soccer',
    ].join('\n');
    const inviteSmsHref = p.phone
      ? `sms:${this.escape(p.phone)}?&body=${encodeURIComponent(inviteSmsBody)}`
      : null;
    // INVITE email uses Gmail compose (same authuser pattern as the
    // regular EMAIL button above) so clicking it lands on
    // mail.google.com pre-filled from soccer@lighthouse1893.org rather
    // than firing an OS mailto: handler (which on desktop typically
    // does nothing useful).  Matches the leads page.
    const inviteEmailHref = p.email
      ? `https://mail.google.com/mail/?${new URLSearchParams({
          view:     'cm',
          fs:       '1',
          authuser: 'soccer@lighthouse1893.org',
          to:       p.email,
          su:       inviteEmailSubject,
          body:     inviteEmailBody,
        }).toString()}`
      : null;

    // ---- Contact popover -----------------------------------------------
    // One CONTACT button collapses EMAIL / SMS / CALL / SAVE and the
    // two INVITE actions into a native <details> popover.  Only the
    // methods the player actually has contact data for are rendered
    // inside.  Uses <details>/<summary> so there's no JS listener
    // wiring, no click-outside tracking.
    const contactBase = btnBase + ' border:none; text-decoration:none; display:inline-flex; align-items:center; gap:3px;';
    // 👤 SAVE (2026-07-05) — data-URL vCard so tapping opens the native
    // "Add Contact" sheet on iOS/Android (or downloads a .vcf on
    // desktop).  Only rendered if we have at least a phone or email.
    const vcardHref = (p.phone || p.email)
      ? this.buildVcardHref({
          fullName: p.fullName || `${p.firstName || ''} ${p.lastName || ''}`.trim(),
          firstName: p.firstName,
          lastName: p.lastName,
          phone: p.phone,
          email: p.email,
          org: `Lighthouse 1893 Men's`,
        })
      : null;
    const vcardFilename = ((p.fullName || `${p.firstName || 'player'}_${p.lastName || ''}`).trim().replace(/\s+/g, '_') || 'contact') + '.vcf';
    const contactItems = [
      emailHref       ? `<a href="${emailHref}"       target="_blank" rel="noopener noreferrer" title="${this.escape(p.email)}"                                            style="${contactBase} background:#3b82f6; color:#fff;">✉ EMAIL</a>` : '',
      smsHref         ? `<a href="${smsHref}"                                                   title="Text ${this.escape(this.formatPhone(p.phone))}"                    style="${contactBase} background:#10b981; color:#fff;">💬 SMS</a>` : '',
      telHref         ? `<a href="${telHref}"                                                   title="Call ${this.escape(this.formatPhone(p.phone))}"                    style="${contactBase} background:#6366f1; color:#fff;">📞 CALL</a>` : '',
      vcardHref       ? `<a href="${vcardHref}"       download="${this.escape(vcardFilename)}" title="Save ${this.escape(p.firstName || 'player')} to your phone contacts" style="${contactBase} background:#0ea5e9; color:#fff;">👤 SAVE</a>` : '',
      inviteSmsHref   ? `<a href="${inviteSmsHref}"                                            title="Text ${this.escape(this.formatPhone(p.phone))} an invite to footballhome.org" style="${contactBase} background:#0d9488; color:#fff;">💬 INVITE (SMS)</a>` : '',
      inviteEmailHref ? `<a href="${inviteEmailHref}" target="_blank" rel="noopener noreferrer" title="Email ${this.escape(p.email)} an invite to footballhome.org"      style="${contactBase} background:#14b8a6; color:#fff;">✉ INVITE (email)</a>` : '',
    ].filter(Boolean);
    const contactBtns = contactItems.length > 0 ? `
      <details class="mr-contact" style="position:relative; display:inline-block;">
        <summary style="${btnBase} background:#334155; color:#fff; border:none; cursor:pointer; list-style:none; user-select:none;"
                 title="Contact ${this.escape(p.firstName || 'player')}">📇 CONTACT</summary>
        <div style="position:absolute; top:100%; left:0; z-index:20; margin-top:2px; display:flex; flex-direction:column; gap:2px; background:#0f172a; padding:3px; border-radius:4px; box-shadow:0 4px 12px rgba(0,0,0,0.45); border:1px solid #334155;">
          ${contactItems.join('')}
        </div>
      </details>` : '';

    // ── Football Home outer JOIN cluster (2026-07-06) ──────────────
    //
    // FH pill = "last footballhome.org activity" (see billing-badge
    // renderFhLastActivity).  Always visible.
    //
    // JOIN buttons here mirror the INVITE items in the CONTACT
    // popover but are promoted to the top-of-card level so the
    // roster loudly flags who still needs to onboard.  Gated on
    // fhLastActivityAt == null; once they've signed in once, the
    // CONTACT popover is enough for manual re-nudges.
    const fhPill = window.BillingBadge && window.BillingBadge.renderFhLastActivity
      ? window.BillingBadge.renderFhLastActivity(p)
      : '';
    let joinCluster = fhPill;
    if (!p.fhLastActivityAt) {
      const joinBase = btnBase + ' border:none; cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:3px;';
      const joinSmsBtn = inviteSmsHref
        ? `<a href="${inviteSmsHref}"
              title="Text ${this.escape(this.formatPhone(p.phone))} an invite to footballhome.org"
              style="${joinBase} background:#0d9488; color:#fff;">
             💬 JOIN
           </a>`
        : '';
      const joinEmailBtn = inviteEmailHref
        ? `<a href="${inviteEmailHref}"
              target="_blank" rel="noopener noreferrer"
              title="Email ${this.escape(p.email)} an invite to footballhome.org"
              style="${joinBase} background:#0ea5e9; color:#fff;">
             ✉ JOIN
           </a>`
        : '';
      joinCluster = `${fhPill}${joinSmsBtn}${joinEmailBtn}`;
    }

    const billingBadge = window.BillingBadge ? window.BillingBadge.render(p) : '';

    const cardId = `mr-card-${p.leagueAppsUserId}`;

    // Card border: bright yellow by default for clear separation on the
    // dark background.  Heavy-overdue (4+ days) cards get a red border
    // tint so risk states pop from a distance.  Dues Owed cards use the
    // same styling as every other column — the column header + hint
    // already communicate the parked state (2026-07-04 pm).
    const baseBorder = '2px solid #facc15';  // yellow-400
    const cardBorder = days >= 4 ? `2px solid ${this.daysOverdueColor(days)}` : baseBorder;
    const cardShadow = '';

    // Position number within the column (1-based).  Gives the coach a
    // running count so they can see "we've got 14 in APSL" while
    // scrolling, not just at the header.  White + full opacity so it's
    // legible from a distance (bumped from 0.62rem/0.55 opacity).
    const posChip = position
      ? `<span style="font-size:0.72rem; color:#fff; font-weight:800; letter-spacing:0.02em; white-space:nowrap;">#${position}</span>`
      : '';

    // ONE big flex-wrap row.  Order: [dues chip] [name] [DOB] [move
    // buttons] [delinq buttons] [contact buttons] [RECENT PAY pill].
    // Name has a bounded min-width so short names don't hog the row —
    // buttons pack immediately to the right and wrap only when the
    // card runs out of horizontal space.
    //
    // Drag reorder: real columns only (col.teamId truthy — Unassigned
    // has no team_id row so it can't store a coach rank).  The card
    // carries data-user-id + data-team-id so the drop handler can
    // rebuild the ordered list and POST /api/mens-roster/reorder.
    const dragAttrs = col && col.teamId
      ? `draggable="true" data-user-id="${p.leagueAppsUserId}" data-team-id="${col.teamId}"`
      : '';
    return `
      <div id="${cardId}" class="mr-card" ${dragAttrs} style="background:var(--bg-tertiary, #1f2937); border-radius:6px; padding:4px 6px; border:${cardBorder}; ${cardShadow}">
        <div style="display:flex; flex-wrap:wrap; align-items:center; gap:4px; row-gap:3px;">
          ${posChip}
          <strong style="font-size:0.8rem; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:100%;">${this.escape(p.fullName) || '(no name)'}</strong>
          ${dobShort ? `<span style="font-size:0.85rem; color:#fff; white-space:nowrap;">🎂 ${this.escape(dobShort)}</span>` : ''}
          ${moveSelect}
          ${laBtn}
          ${rsvpEligBtn}
          ${delinqBtns}
          ${contactBtns}
          ${joinCluster}
          ${billingBadge}
        </div>
      </div>
    `;
  }

  // ── vCard builder (2026-07-05) ───────────────────────────────────
  //
  // Builds a `data:text/vcard;charset=utf-8,...` URL that, when opened
  // via an <a href>, triggers the OS-native "Add Contact" flow on
  // iOS/Android or downloads a .vcf on desktop.  vCard 3.0 with CRLF
  // line endings per RFC 2426.  Field values are escaped (backslash,
  // comma, semicolon, newline) before the whole payload is
  // URI-encoded for the data URL.
  buildVcardHref({ fullName, firstName, lastName, phone, email, org, note }) {
    const esc = (s) => String(s == null ? '' : s)
      .replace(/\\/g, '\\\\')
      .replace(/\n/g, '\\n')
      .replace(/,/g, '\\,')
      .replace(/;/g, '\\;');
    const lines = ['BEGIN:VCARD', 'VERSION:3.0'];
    // N: Family;Given;Additional;Prefix;Suffix
    if (firstName || lastName) {
      lines.push(`N:${esc(lastName)};${esc(firstName)};;;`);
    }
    if (fullName) lines.push(`FN:${esc(fullName)}`);
    if (org) lines.push(`ORG:${esc(org)}`);
    if (phone) lines.push(`TEL;TYPE=CELL:${esc(phone)}`);
    if (email) lines.push(`EMAIL;TYPE=INTERNET:${esc(email)}`);
    if (note) lines.push(`NOTE:${esc(note)}`);
    lines.push('END:VCARD');
    const body = lines.join('\r\n');
    return `data:text/vcard;charset=utf-8,${encodeURIComponent(body)}`;
  }

  // Pulls the leading emoji + 1 short word from labels like "🇧🇷 Brazil"
  // → "🇧🇷 Brazil" stays short already; trims long names.
  shortLabel(label) {
    if (!label) return '';
    if (label.length <= 14) return this.escape(label);
    return this.escape(label.slice(0, 12)) + '…';
  }

  // ── Drag-and-drop reorder (2026-07-04 pm) ────────────────────────
  //
  // Native HTML5 DnD.  Cards on real columns are draggable (see
  // renderPlayer); Unassigned cards are not (no team_id row can hold a
  // coach rank).  Drops must land in the SAME column — cross-column
  // moves still go through the roster-move popover, which handles the
  // mutex_group DELETE atomically.
  //
  // While dragging, we show a green insertion indicator either above or
  // below the card the pointer is currently over (based on which half
  // of it the pointer hit).  Dropping into an empty column body works
  // via the mr-drop-empty state on the column's mr-drop-zone.
  //
  // After a drop, we rearrange the DOM in place, collect the ordered
  // list of userIds, POST /reorder, then reload the whole board so the
  // #N chips + coachSortOrder come back from the server.

  _dragClearMarkers() {
    this.element.querySelectorAll('.mr-drop-before, .mr-drop-after')
      .forEach(el => el.classList.remove('mr-drop-before', 'mr-drop-after'));
    this.element.querySelectorAll('.mr-drop-empty')
      .forEach(el => el.classList.remove('mr-drop-empty'));
  }

  onDragStart(e) {
    const card = e.target.closest && e.target.closest('.mr-card[draggable="true"]');
    if (!card) return;
    this._dragSourceUserId = card.dataset.userId;
    this._dragSourceTeamId = card.dataset.teamId;
    card.classList.add('mr-dragging');
    // Firefox requires setData() for dragstart to succeed at all.
    if (e.dataTransfer) {
      try {
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/plain', card.dataset.userId);
      } catch (_) { /* ignore */ }
    }
  }

  onDragEnd(_e) {
    this.element.querySelectorAll('.mr-card.mr-dragging')
      .forEach(el => el.classList.remove('mr-dragging'));
    this._dragClearMarkers();
    this._dragSourceUserId = null;
    this._dragSourceTeamId = null;
  }

  onDragOver(e) {
    if (!this._dragSourceUserId) return;
    const zone = e.target.closest && e.target.closest('.mr-drop-zone[data-drop-team-id]');
    if (!zone) return;
    const zoneTeamId = zone.dataset.dropTeamId;
    // Empty string = Unassigned column (no team_id).  Reject.
    if (!zoneTeamId) return;
    // Same-column only.  Cross-column drops are ignored — the move
    // popover is the correct affordance for changing team assignments.
    if (zoneTeamId !== this._dragSourceTeamId) return;

    e.preventDefault();
    if (e.dataTransfer) e.dataTransfer.dropEffect = 'move';
    this._dragClearMarkers();

    const overCard = e.target.closest && e.target.closest('.mr-card[draggable="true"]');
    if (!overCard || overCard.classList.contains('mr-dragging')) {
      // Empty area (or over the currently dragged card) — highlight
      // the whole zone so the user knows "drop at end".
      if (zone.children.length === 0) zone.classList.add('mr-drop-empty');
      return;
    }
    const rect = overCard.getBoundingClientRect();
    const before = (e.clientY - rect.top) < (rect.height / 2);
    overCard.classList.add(before ? 'mr-drop-before' : 'mr-drop-after');
  }

  onDragLeave(e) {
    // Only clear when the pointer leaves the drop zone entirely — not
    // when it moves between children within the same zone.  We check
    // relatedTarget: if it's still inside the same zone, do nothing.
    const zone = e.target.closest && e.target.closest('.mr-drop-zone');
    if (!zone) return;
    const to = e.relatedTarget;
    if (to && zone.contains(to)) return;
    zone.classList.remove('mr-drop-empty');
    zone.querySelectorAll('.mr-drop-before, .mr-drop-after')
      .forEach(el => el.classList.remove('mr-drop-before', 'mr-drop-after'));
  }

  async onDrop(e) {
    if (!this._dragSourceUserId) return;
    const zone = e.target.closest && e.target.closest('.mr-drop-zone[data-drop-team-id]');
    if (!zone) return;
    const teamId = parseInt(zone.dataset.dropTeamId, 10);
    if (!teamId || String(teamId) !== this._dragSourceTeamId) return;

    e.preventDefault();
    const sourceCard = this.element.querySelector(
      `.mr-card[draggable="true"][data-user-id="${this._dragSourceUserId}"][data-team-id="${this._dragSourceTeamId}"]`
    );
    if (!sourceCard) { this._dragClearMarkers(); return; }

    const overCard = e.target.closest && e.target.closest('.mr-card[draggable="true"]');
    if (overCard && overCard !== sourceCard) {
      const rect = overCard.getBoundingClientRect();
      const before = (e.clientY - rect.top) < (rect.height / 2);
      overCard.parentNode.insertBefore(sourceCard, before ? overCard : overCard.nextSibling);
    } else if (!overCard) {
      // Dropped in empty area of the zone → append at end.
      zone.appendChild(sourceCard);
    }
    this._dragClearMarkers();

    // Collect ordered userIds directly from the DOM (source of truth
    // after the manual insertBefore above) and persist.
    const orderedIds = Array.from(
      zone.querySelectorAll('.mr-card[draggable="true"]')
    ).map(el => parseInt(el.dataset.userId, 10)).filter(n => Number.isFinite(n));
    if (orderedIds.length === 0) return;

    try {
      const res = await this.auth.fetch('/api/mens-roster/reorder', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ teamId, userIds: orderedIds }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      // Reload so #N chips + backend sort come back authoritative.
      await this.load();
    } catch (err) {
      alert(`Could not save order: ${err.message}`);
      await this.load();
    }
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

  // Move-to-roster <details> popover option handler (2026-07-04 pm).
  // Semantics unchanged:
  //   • target == 0 (Unassigned)  → POST remove on whichever real team
  //     the player currently sits on (backend mutex guarantees at most
  //     one).  No-op if already unassigned.
  //   • target == 35 / 120 / 121   → POST add.  Backend's mutex_group
  //     handling in MensTeamAssignments::addAssignment auto-removes the
  //     other division, so we don't need a separate remove call.
  async onMoveOptionClick(btn) {
    const userId        = parseInt(btn.dataset.userId, 10);
    const targetTeamId  = parseInt(btn.dataset.targetTeamId, 10);
    const currentTeamId = parseInt(btn.dataset.currentTeamId || '0', 10);
    if (!userId || Number.isNaN(targetTeamId)) return;
    if (targetTeamId === currentTeamId) return;

    // Close the popover immediately for snappier UX.
    const details = btn.closest('details');
    if (details) details.open = false;

    btn.disabled = true;
    btn.style.opacity = '0.4';
    try {
      let body;
      if (targetTeamId === 0) {
        if (currentTeamId <= 0) { await this.load(); return; }
        body = { leagueAppsUserId: userId, teamId: currentTeamId, action: 'remove' };
      } else {
        body = { leagueAppsUserId: userId, teamId: targetTeamId, action: 'add' };
      }
      const res = await this.auth.fetch('/api/mens-roster/assign', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(body),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      await this.load();
    } catch (err) {
      btn.disabled = false;
      btn.style.opacity = '';
      alert(`Could not move player: ${err.message}`);
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
  // Matches PaymentsScreen's LA deep-link scheme.  Hardcoded site id
  // mirrors PaymentsScreen.laSiteId (41983) — UI-only value; backend
  // canonical is LEAGUEAPPS_SITE_ID in env.
  laManagerUrl(uid) {
    return `https://manager.leagueapps.com/console/sites/41983/memberDetails?memberId=${uid}`;
  }

  // ── RSVP-eligibility modal (2026-07-07) ─────────────────────────
  //
  // Per user directive "i think in the player card we can just have
  // popup to allow us to check off what they can rsvp to".  Six
  // checkboxes covering the mens teams the player can RSVP for:
  //   35  APSL
  //   120 Liga 1
  //   121 Liga 2
  //   122 Adult
  //   908 Practice
  //   909 Pickup
  // Server list must stay in sync — see
  // MensRosterController.cpp `kEligibilityTeams`.
  //
  // Read on open (GET), diff+write on save (PUT).  Modal is a
  // fixed-position overlay dropped straight into <body> so it's not
  // constrained by the card's stacking context.  Removed via close().
  async openRsvpEligibilityModal(btn) {
    const uid  = Number(btn.dataset.userId);
    const name = btn.dataset.name || 'this player';
    if (!uid) return;
    const teams = [
      { id: 35,  label: 'APSL',     color: '#2563eb' },
      { id: 120, label: 'Liga 1',   color: '#0891b2' },
      { id: 121, label: 'Liga 2',   color: '#14b8a6' },
      { id: 122, label: 'Adult',    color: '#a78bfa' },
      { id: 908, label: 'Practice', color: '#f59e0b' },
      { id: 909, label: 'Pickup',   color: '#10b981' },
    ];

    // Fetch current set first so we can pre-check the boxes.
    let currentIds = new Set();
    try {
      const r = await this.auth.fetch(
        `/api/mens-roster/rsvp-eligibility?leagueAppsUserId=${uid}`
      );
      if (r.ok) {
        const body = await r.json();
        currentIds = new Set(body.teamIds || []);
      }
    } catch (_e) { /* modal still opens with all unchecked */ }

    const overlay = document.createElement('div');
    overlay.style.cssText = `
      position:fixed; inset:0; z-index:9999;
      background:rgba(0,0,0,0.55);
      display:flex; align-items:center; justify-content:center;
      padding:16px;
    `;
    const cbs = teams.map(t => {
      const checked = currentIds.has(t.id) ? 'checked' : '';
      return `
        <label style="display:flex; align-items:center; gap:10px;
                      padding:10px 12px; border-radius:6px;
                      background:${t.color}22; color:#fff;
                      border:1px solid ${t.color}88; cursor:pointer;
                      font-size:0.95rem; font-weight:600;">
          <input type="checkbox" data-team-id="${t.id}" ${checked}
                 style="width:18px; height:18px; accent-color:${t.color}; cursor:pointer;">
          <span style="flex:1;">${t.label}</span>
          <span style="font-size:0.7rem; opacity:0.6;">#${t.id}</span>
        </label>`;
    }).join('');

    overlay.innerHTML = `
      <div style="background:#0f172a; border-radius:10px; padding:16px 18px;
                  min-width:min(360px, 96vw); max-width:420px;
                  border:1px solid #334155;
                  box-shadow:0 20px 60px rgba(0,0,0,0.6);">
        <div style="font-size:1.05rem; font-weight:800; color:#fff; margin-bottom:2px;">
          RSVP Eligibility
        </div>
        <div style="font-size:0.85rem; color:#94a3b8; margin-bottom:12px;">
          ${this.escape(name)} — choose which teams they can RSVP for.
        </div>
        <div style="display:flex; flex-direction:column; gap:6px; margin-bottom:14px;">
          ${cbs}
        </div>
        <div id="mr-rsvp-elig-msg" style="min-height:1em; font-size:0.8rem; color:#fca5a5; margin-bottom:8px;"></div>
        <div style="display:flex; justify-content:flex-end; gap:8px;">
          <button id="mr-rsvp-elig-cancel" type="button"
                  style="padding:6px 14px; border-radius:5px; border:1px solid #475569;
                         background:transparent; color:#cbd5e1; font-weight:700; cursor:pointer;">
            Cancel
          </button>
          <button id="mr-rsvp-elig-save" type="button"
                  style="padding:6px 14px; border-radius:5px; border:none;
                         background:#0ea5e9; color:#fff; font-weight:800; cursor:pointer;">
            Save
          </button>
        </div>
      </div>
    `;
    document.body.appendChild(overlay);

    const close = () => overlay.remove();
    overlay.addEventListener('click', (e) => { if (e.target === overlay) close(); });
    overlay.querySelector('#mr-rsvp-elig-cancel').addEventListener('click', close);
    overlay.querySelector('#mr-rsvp-elig-save').addEventListener('click', async () => {
      const checked = Array.from(overlay.querySelectorAll('input[type=checkbox]:checked'))
        .map(el => Number(el.dataset.teamId));
      const msg = overlay.querySelector('#mr-rsvp-elig-msg');
      msg.textContent = '';
      try {
        const r = await this.auth.fetch('/api/mens-roster/rsvp-eligibility', {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ leagueAppsUserId: uid, teamIds: checked }),
        });
        if (!r.ok) {
          const t = await r.text();
          msg.textContent = `Save failed: ${t.slice(0, 200)}`;
          return;
        }
        close();
      } catch (err) {
        msg.textContent = `Save failed: ${err.message || err}`;
      }
    });
  }

  // Color scale (user directive 2026-07-04): 1-3 yellow · 4-6 orange · 7+ red.
  daysOverdueColor(days) {
    if (days >= 7) return '#ef4444';
    if (days >= 4) return '#f97316';
    if (days >= 1) return '#fbbf24';
    return null;
  }

  // Lifted verbatim from PaymentsScreen's [data-copy-pause] handler — the
  // canonical warning admin pastes into LA's Remind flow before flipping
  // a player to Paused Membership.
  async _copyPauseMessage(btn) {
    const first = btn.dataset.firstName || 'Player';
    const msg = `${first}, you have not made initial registration payment. We have to move you to a paused membership which makes you ineligible for practice and games until paid.`;
    try {
      await navigator.clipboard.writeText(msg);
      const orig = btn.innerHTML;
      const origBg = btn.style.background;
      btn.innerHTML = '✓';
      btn.style.background = '#10b981';
      setTimeout(() => {
        btn.innerHTML = orig;
        btn.style.background = origBg || '#f97316';
      }, 1400);
    } catch (_e) {
      alert('Could not copy to clipboard — you can retype the message from Payments → Copy Pause.');
    }
  }

  // Fire-and-forget POST /api/pay-reminder-log on 💸 PAY click.  Does
  // NOT preventDefault — sms: still opens.  keepalive:true lets the
  // request survive the tab switch on iOS/Android.  Also paints an
  // optimistic "just now" pill so the admin sees instant confirmation.
  _logPayReminder(anchor) {
    const laUserId = parseInt(anchor.dataset.laUserId, 10);
    const method   = anchor.dataset.method;
    if (!laUserId || !method) return;
    const body = {
      leagueAppsUserId: laUserId,
      method,
      club:  'mens',
      tier:  anchor.dataset.tier || null,
      amount: anchor.dataset.amount ? Number(anchor.dataset.amount) : null,
      daysOverdue: anchor.dataset.daysOverdue !== '' && anchor.dataset.daysOverdue != null
        ? parseInt(anchor.dataset.daysOverdue, 10)
        : null,
    };
    try {
      const token = this.auth && this.auth.token ? this.auth.token : null;
      const headers = { 'Content-Type': 'application/json' };
      if (token) headers['Authorization'] = `Bearer ${token}`;
      fetch('/api/pay-reminder-log', {
        method: 'POST',
        headers,
        keepalive: true,
        body: JSON.stringify(body),
      }).catch(() => { /* fire-and-forget */ });
    } catch (_e) { /* ignore */ }

    try {
      const nowIso = new Date().toISOString();
      const fresh = window.BillingBadge && window.BillingBadge.renderLastPayReminderInline
        ? window.BillingBadge.renderLastPayReminderInline({ method, sentAt: nowIso })
        : '';
      const slots = this.element.querySelectorAll(`.bb-pay-reminder-slot[data-uid="${laUserId}"]`);
      slots.forEach(s => { s.innerHTML = fresh; });
    } catch (_e) { /* non-fatal */ }
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
