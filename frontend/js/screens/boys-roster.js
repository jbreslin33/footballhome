// BoysRosterScreen — Live Boys/Girls roster pulled from LeagueApps every
// page load (both Boys Club + Girls Club programs — girls play on boys
// teams for now).  Mirror of MensRosterScreen with two youth-specific
// tweaks:
//   • Cards carry an age-group chip ("U10") derived from DOB (Aug-1
//     school-year cutover) and a gender chip (♂ Boy / ♀ Girl) so the
//     coach can spot "U10 girl playing on U10 Boys" at a glance.
//   • Move-to-column targets are DB-driven from data.columns (domain
//     = 'boys' in roster_columns) rather than hardcoded APSL/Liga1/
//     Purgatory.  Add a column by inserting a row — no code change.
//
// Everything else (Payments badge, drag reorder, contact popover,
// delinquency PAY button, LA deep-link) is intentionally identical to
// mens.  The backend routes just point at BoysRosterController which
// shares MensTeamColumns/MensTeamAssignments parametrised by domain.
class BoysRosterScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        /* Hide the default triangle marker on the CONTACT / ROSTER
           <summary> popovers so they render as clean buttons.  Scoped
           to this screen via .br-move-details / .br-contact. */
        .br-move-details > summary,
        .br-contact      > summary { list-style: none; }
        .br-move-details > summary::-webkit-details-marker,
        .br-contact      > summary::-webkit-details-marker { display: none; }
        .br-move-details > summary::marker,
        .br-contact      > summary::marker { display: none; content: ''; }

        /* Drag-and-drop cursor + insertion indicator (2026-07-04 pm).
           Cards on real columns are grabbable; while dragging, a bright
           border appears on the target edge so the drop point is
           obvious.  See onDragStart / onDragOver in boys-roster.js. */
        .br-card[draggable="true"]        { cursor: grab; }
        .br-card[draggable="true"]:active { cursor: grabbing; }
        .br-card.br-dragging              { opacity: 0.35; }
        .br-card.br-drop-before           { box-shadow: 0 -3px 0 0 #10b981 inset; }
        .br-card.br-drop-after            { box-shadow: 0  3px 0 0 #10b981 inset; }
        .br-drop-zone.br-drop-empty       { box-shadow: 0 0 0 2px #10b981 inset; border-radius: 4px; }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🎽 Boys Roster Board</h1>
        <p class="subtitle">Live from LeagueApps — Boys + Girls Club (girls surfaced too; girls play on boys teams for now)</p>
      </div>

      <div style="padding: var(--space-4);">
        <div id="br-banner" style="margin-bottom: var(--space-3); padding: var(--space-3); border-radius: 6px; background: #f1f5f9; border: 1px solid #e2e8f0; display:flex; align-items:center; gap: var(--space-3); flex-wrap: wrap; font-size: 14px;">
          <span id="br-banner-icon" style="font-size: 16px;">⏳</span>
          <span id="br-banner-text" style="flex:1; min-width: 200px;">Pulling latest registrations from LeagueApps…</span>
          <button id="br-refresh" class="btn btn-secondary" title="Force a fresh pull from LeagueApps (registrations + payments)" style="padding: 4px 10px; font-size: 13px;">🔄 Refresh</button>
        </div>
        <div id="br-loading" style="text-align:center; padding: var(--space-6); opacity:0.6;">Loading…</div>
        <div id="br-error"   style="display:none; color: var(--color-error); padding: var(--space-4); text-align:center;"></div>
        <div id="br-list"    style="display:none;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter() {
    this.element.addEventListener('click', e => {
      if (e.target.closest('.back-btn')) return this.navigation.goBack();
      if (e.target.closest('#br-refresh')) return this.load({ refreshLa: true });
      const moveOpt = e.target.closest('.br-move-option');
      if (moveOpt) return this.onMoveOptionClick(moveOpt);
      const toggle = e.target.closest('.br-roster-toggle');
      if (toggle) return this.onRosterToggleClick(toggle);
      const pill = e.target.closest('.br-pill');
      if (pill) return this.onPillClick(pill);
      const laBtn = e.target.closest('.br-la-open');
      if (laBtn) { window.open(laBtn.dataset.laUrl, '_blank', 'noopener'); return; }
      const pauseBtn = e.target.closest('.br-copy-pause');
      if (pauseBtn) return this._copyPauseMessage(pauseBtn);
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
    const i = this.find('#br-banner-icon');
    const t = this.find('#br-banner-text');
    const r = this.find('#br-refresh');
    if (i) i.textContent = icon;
    if (t) t.textContent = text;
    if (r) r.style.display = showRefresh ? '' : 'none';
  }

  async load({ refreshLa = false } = {}) {
    const loading = this.find('#br-loading');
    const errEl   = this.find('#br-error');
    const list    = this.find('#br-list');
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
        ? '/api/boys-roster?refreshLa=1'
        : '/api/boys-roster';
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
      const dqText = (dq.overdueCount > 0 || dq.purgatoryCount > 0)
        ? ` · ⚠ ${dq.overdueCount || 0} overdue · 🚨 ${dq.purgatoryCount || 0} purgatory`
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
    const container = this.find('#br-list');

    // Purgatory is now a REAL DB column (team_id=910, added via
    // migration 085) with mutex_group='mens-selection' shared with
    // APSL(35) and Liga 1(120).  So Unassigned / APSL / Liga 1 /
    // Purgatory are all mutually exclusive at the DB level — admin
    // clicks one move button and the row atomically leaves the others.
    //
    // Everyone left in data.unassigned is truly on no team (no active
    // rows in mens_team_assignments for any real column).  The old
    // delinquencyState filter is gone — dues do not auto-move anyone
    // per user directive "don't auto manage it".
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
    // Purgatory (the soft-parked column) is detected dynamically by
    // shortLabel — mens seeds it at 910, boys at 915, and this way any
    // future domain works without a code change.
    const isPurgatory = (col.shortLabel || '').toUpperCase() === 'PURG'
                        || /purgatory/i.test(col.label || '');
    const players = col.isUnassigned
      ? (data.unassigned || [])
      : (data.buckets[String(col.teamId)] || []);

    let countHtml;
    if (col.maxRoster != null) {
      const overFull = players.length >= col.maxRoster;
      const pct      = col.maxRoster ? players.length / col.maxRoster : 0;
      const nearFull = !overFull && pct >= 0.85;
      const fc = overFull ? '#ef4444' : nearFull ? '#f59e0b' : '#10b981';
      countHtml = `<span style="font-size:0.85rem; font-weight:600; color:${fc};">${players.length}/${col.maxRoster}${overFull ? ' ⚠' : ''}</span>`;
    } else {
      countHtml = `<span style="opacity:0.6; font-size:0.85rem;">${players.length}</span>`;
    }

    const renderList = (list) => list.map((p, i) => this.renderPlayer(p, data.columns, { ...col, isPurgatory }, i + 1)).join('');

    let body;
    if (players.length === 0) {
      body = isPurgatory
        ? '<div style="opacity:0.6; font-size:0.75rem; text-align:center; padding:8px 4px; color:#10b981;">✓ Nobody parked</div>'
        : '<div style="opacity:0.5; font-size:0.85rem;">(empty)</div>';
    } else {
      body = renderList(players);
    }

    // Column-level dues risk: how many players in this column are
    // currently overdue.  Coach uses this to spot at-a-glance which
    // rosters need attention.  Excluded from Purgatory (already isolated).
    const overdueInCol = isPurgatory ? 0 : players.filter(p => (p.daysOverdue || 0) >= 1).length;
    const overdueHtml = overdueInCol > 0
      ? `<div style="margin-bottom:6px; padding:3px 6px; background:#3a1f1f; color:#fca5a5; border:1px solid #7f1d1d; border-radius:3px; font-size:0.65rem; font-weight:700; letter-spacing:0.05em; text-align:center;">⚠ ${overdueInCol} OVERDUE</div>`
      : '';
    const purgatoryHint = isPurgatory
      ? `<div style="margin-bottom:6px; padding:3px 6px; background:#3a1f1f; color:#fca5a5; border:1px dashed #b91c1c; border-radius:3px; font-size:0.65rem; letter-spacing:0.03em; text-align:center; line-height:1.35;">Admin-parked: off all rosters.<br>Move card to another column to reinstate.</div>`
      : '';

    return `
      <div style="background:var(--bg-secondary); border-radius:var(--radius-md); padding:8px; border-top:3px solid ${col.color};">
        <div style="display:flex; justify-content:space-between; align-items:baseline; margin-bottom:6px; gap:6px;">
          <strong style="font-size:0.85rem;">${col.label}</strong>
          ${countHtml}
        </div>
        ${overdueHtml}
        ${purgatoryHint}
        <div class="br-drop-zone" data-drop-team-id="${col.isUnassigned ? '' : col.teamId}"
             style="display:flex; flex-direction:column; gap:8px; min-height:8px;">
          ${body}
        </div>
      </div>
    `;
  }

  renderPlayer(p, columns, col, position) {
    // Card redesign (2026-07-04): the coach's primary action on this
    // board is "move player X to roster Y".  Everything else (contact,
    // dues action) is secondary.  So the card leads with the move
    // popover and drops the tiny legacy pills entirely.  Contact +
    // dues actions are still present but sized so they're readable,
    // not decorative.

    // For youth, we contact the PARENT, not the player.  LA's parent
    // fields are the truth; player phone/email are a fallback for the
    // handful of rare records that omit them.  This applies to CONTACT,
    // PAY, and SAVE (vCard) buttons — everything the admin can trigger
    // from a card should route to the parent by default.
    const parentFirst = p.parentFirstName || '';
    const parentName  = p.parentName
      || `${parentFirst} ${p.parentLastName || ''}`.trim()
      || 'there';
    const parentPhone = p.parentPhone || p.phone || null;
    const parentEmail = p.parentEmail || p.email || null;

    // Polite parent-facing bodies for the generic CONTACT popover.
    // The PAY button below builds its own tier-scaled body.
    const kidRef       = p.firstName ? ` regarding ${p.firstName}` : '';
    const emailSubject = `Lighthouse 1893${p.firstName ? ` — ${p.firstName}` : ''}`;
    const emailBody    = `Hi ${parentFirst || 'there'},\n\nThis is Lighthouse 1893${kidRef}.\n\n`;
    const smsBody      = `Hi${parentFirst ? ' ' + parentFirst : ''}, this is Lighthouse 1893${kidRef}.`;

    const emailHref = parentEmail
      ? `https://mail.google.com/mail/?${new URLSearchParams({
          view:     'cm',
          fs:       '1',
          authuser: 'soccer@lighthouse1893.org',
          to:       parentEmail,
          su:       emailSubject,
          body:     emailBody,
        }).toString()}`
      : null;
    const smsHref = parentPhone ? `sms:${parentPhone}?&body=${encodeURIComponent(smsBody)}` : null;
    const telHref = parentPhone ? `tel:${parentPhone}` : null;

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

    // ── Age-group + gender chips (youth-only) ─────────────────────
    // Two extra pills unique to the youth board so the coach can spot
    // "U10 girl playing on U10 Boys" at a glance.  ageGroup comes
    // from BoysRoster.cpp (Aug-1 school-year cutover from DOB); gender
    // is the LA value, defaulted to club-of-record when missing.
    const isBoy      = (p.gender || '').toLowerCase().startsWith('m');
    const ageChip    = p.ageGroup
      ? `<span style="font-size:0.85rem; font-weight:800; letter-spacing:0.02em; padding:2px 8px; border-radius:10px; background:#1e3a8a; color:#dbeafe; white-space:nowrap;">${this.escape(p.ageGroup)}</span>`
      : '';
    const genderChip = `<span style="font-size:0.65rem; font-weight:800; letter-spacing:0.02em; padding:1px 6px; border-radius:10px; background:${isBoy ? '#1e40af' : '#831843'}; color:${isBoy ? '#dbeafe' : '#fce7f3'}; white-space:nowrap;">${isBoy ? '♂ BOY' : '♀ GIRL'}</span>`;

    // ---- Move-to-roster buttons ----------------------------------------
    //
    // Targets are data-driven from data.columns (domain='boys' in
    // roster_columns).  All boys columns share mutex_group
    // 'boys-selection', so adding a player to one atomically removes
    // them from any other — same guarantee as mens.  "Unassigned"
    // (id 0) means remove from whichever real column they're on.
    const assignedSet = new Set(p.teamIds || []);
    // Restrict "current" detection to configured boys columns — a
    // stray LA team assignment shouldn't confuse the selector.
    const configuredIds = new Set((columns || []).map(c => c.teamId));
    let currentTeamId = 0;
    for (const tid of assignedSet) {
      if (configuredIds.has(tid)) { currentTeamId = tid; break; }
    }

    const targets = [
      { id: 0, label: 'Unassigned', color: '#475569' },
      ...(columns || []).map(c => ({
        id:    c.teamId,
        label: c.shortLabel || c.label || `Team ${c.teamId}`,
        color: c.color || '#334155',
      })),
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
      return `<button class="br-move-option" type="button"
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
      <details class="br-move-details" style="position:relative; display:inline-block;">
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
      ? `<button class="br-la-open" type="button" data-la-url="${this.laManagerUrl(p.leagueAppsUserId)}"
                 title="Open ${this.escape(p.firstName || 'player')} in LA Manager"
                 style="${btnBase} border:none; cursor:pointer; background:#7c3aed; color:#fff;">
           LA
         </button>`
      : '';
    let delinqBtns = '';
    if (days >= 1 && p.leagueAppsUserId) {
      // Amount preference: LA's outstandingBalance if it's > 0,
      // otherwise the monthly nextBillAmount.  Falls back to just
      // "the outstanding balance" if we somehow have neither.
      const amountNum = (p.outstandingBalance > 0)
        ? p.outstandingBalance
        : (p.nextBillAmount > 0 ? p.nextBillAmount : null);
      const amountStr = amountNum != null ? `$${amountNum}` : 'the outstanding balance';
      const daysStr   = daysAreExact
        ? `${days} day${days === 1 ? '' : 's'}`
        : 'a few days';
      const payUrl    = 'https://lighthouse1893.leagueapps.com/dashboard';

      // ── Parent-facing PAY reminder ──────────────────────────────
      //
      // Youth board voice: extremely polite, apologetic, addressed to
      // the parent by first name and referring to the child by first
      // name.  We do NOT threaten roster removal — youth is different
      // from mens; kids don't get parked for late dues.  Tone is
      // "sorry to bother you, quick heads-up from the office".
      //
      // Three tiers scaled to lateness:
      //   1–3 days  → gentle nudge, "charge didn't go through"
      //   4–6 days  → slightly firmer, note that dues fund the program
      //   7+ days   → still polite, but ask them to reach out if there
      //               is a hardship so we can work something out
      //
      // Every tier tells the parent LeagueApps has already emailed a
      // pay link and points to the dashboard URL as a fallback so they
      // can update card-on-file.
      const parentFirstStr = parentFirst ? ` ${parentFirst}` : '';
      const kidStr         = p.firstName ? ` ${p.firstName}'s` : ' your child\'s';
      const kidRefName     = p.firstName || 'your child';
      const duesPurpose    = `Dues help cover ref fees, league & player registration, equipment, uniforms, and field costs — thank you for supporting the club!`;
      const signOff        = `Thank you so much, and please let us know if there's anything we can do to help.`;

      // SMS body — single blob; SMS clients render walls of text fine
      // and it saves the parent from scrolling a long message.
      let payBody;
      if (days >= 7) {
        payBody = `Hi${parentFirstStr}, so sorry to bother you — this is Lighthouse 1893.  We wanted to gently follow up on${kidStr} membership dues (${amountStr}), which are showing about ${daysStr} past due in our system.  LeagueApps has emailed you a pay link — please have a look if you can!  You can also log in and pay here: ${payUrl}  If you're experiencing any hardship or the timing isn't great, please just reply to this message — we're happy to work something out.  ${signOff}`;
      } else if (days >= 4) {
        payBody = `Hi${parentFirstStr}, hope you're doing well — this is a quick, friendly note from Lighthouse 1893.  We noticed${kidStr} dues (${amountStr}) are about ${daysStr} past due; it looks like the LeagueApps charge didn't go through.  LeagueApps has emailed you a pay link, or you can log in and pay here: ${payUrl}  ${duesPurpose}  ${signOff}`;
      } else {
        payBody = `Hi${parentFirstStr}, hope all is well!  Quick heads-up from Lighthouse 1893 — it looks like${kidStr} most recent dues charge (${amountStr}) didn't go through on LeagueApps.  Whenever you get a chance, LeagueApps has emailed you a pay link, or you can log in and pay here: ${payUrl}  ${signOff}`;
      }

      // Email body — same content as SMS but broken into readable
      // paragraphs with a proper greeting/signature block.  Gmail's
      // compose window preserves \n line breaks, so paragraph splits
      // render cleanly.  2026-07-06: user asked for better email
      // formatting than one wall of text.
      const greetingLine = `Hi${parentFirstStr},`;
      const signature    = `Thanks so much,\nLighthouse 1893`;
      let payEmailBody;
      if (days >= 7) {
        payEmailBody = [
          greetingLine,
          `So sorry to bother you — this is Lighthouse 1893.`,
          `We wanted to gently follow up on${kidStr} membership dues (${amountStr}), which are showing about ${daysStr} past due in our system.`,
          `LeagueApps has emailed you a pay link — please have a look if you can! You can also log in and pay here:\n${payUrl}`,
          `If you're experiencing any hardship or the timing isn't great, please just reply to this email — we're happy to work something out.`,
          signOff,
          signature,
        ].join('\n\n');
      } else if (days >= 4) {
        payEmailBody = [
          greetingLine,
          `Hope you're doing well — this is a quick, friendly note from Lighthouse 1893.`,
          `We noticed${kidStr} dues (${amountStr}) are about ${daysStr} past due; it looks like the LeagueApps charge didn't go through.`,
          `LeagueApps has emailed you a pay link, or you can log in and pay here:\n${payUrl}`,
          duesPurpose,
          signOff,
          signature,
        ].join('\n\n');
      } else {
        payEmailBody = [
          greetingLine,
          `Hope all is well! Quick heads-up from Lighthouse 1893 — it looks like${kidStr} most recent dues charge (${amountStr}) didn't go through on LeagueApps.`,
          `Whenever you get a chance, LeagueApps has emailed you a pay link, or you can log in and pay here:\n${payUrl}`,
          signOff,
          signature,
        ].join('\n\n');
      }

      // Two buttons: 💬 PAY (SMS to parent) and ✉ PAY (email to parent).
      // Whichever channel the parent uses, one tap gets there.  If we
      // only have one of the two, only that button renders.
      const paySmsHref = parentPhone
        ? `sms:${parentPhone}?&body=${encodeURIComponent(payBody)}`
        : null;
      const payEmailHref = parentEmail
        ? `https://mail.google.com/mail/?${new URLSearchParams({
            view:     'cm',
            fs:       '1',
            authuser: 'soccer@lighthouse1893.org',
            to:       parentEmail,
            su:       `Lighthouse 1893 — quick note about ${kidRefName}'s dues`,
            body:     payEmailBody,
          }).toString()}`
        : null;

      const paySmsBtn = paySmsHref
        ? `<a href="${paySmsHref}"
              title="Text ${this.escape(this.formatPhone(parentPhone))} a polite dues reminder"
              style="${btnBase} border:none; cursor:pointer; background:#059669; color:#fff; text-decoration:none;">
             💬 PAY
           </a>`
        : '';
      const payEmailBtn = payEmailHref
        ? `<a href="${payEmailHref}" target="_blank" rel="noopener noreferrer"
              title="Email ${this.escape(parentEmail)} a polite dues reminder"
              style="${btnBase} border:none; cursor:pointer; background:#0284c7; color:#fff; text-decoration:none;">
             ✉ PAY
           </a>`
        : '';
      delinqBtns = `${paySmsBtn}${payEmailBtn}`;
    }

    // ---- Contact popover -----------------------------------------------
    // One CONTACT button collapses EMAIL / SMS / CALL into a native
    // <details> popover.  Only the methods the player actually has
    // contact data for are rendered inside.  Uses <details>/<summary>
    // so there's no JS listener wiring, no click-outside tracking.
    const contactBase = btnBase + ' border:none; text-decoration:none; display:inline-flex; align-items:center; gap:3px;';
    // 👤 SAVE (2026-07-05) — data-URL vCard so tapping opens the native
    // "Add Contact" sheet on iOS/Android (or downloads a .vcf on
    // desktop).  Only rendered if we have at least a phone or email.
    // For youth, we save the PARENT to contacts (with the kid's name
    // in the org/note) so the coach ends up with a usable entry.
    const vcardHref = (parentPhone || parentEmail)
      ? this.buildVcardHref({
          fullName:  parentName && parentName !== 'there' ? parentName : (p.fullName || `${p.firstName || ''} ${p.lastName || ''}`.trim()),
          firstName: parentFirst || p.firstName,
          lastName:  p.parentLastName || p.lastName,
          phone:     parentPhone,
          email:     parentEmail,
          org:       `Lighthouse 1893 Youth`,
          note:      p.firstName ? `Parent of ${p.firstName}${p.lastName ? ' ' + p.lastName : ''}` : '',
        })
      : null;
    const vcardFilename = ((parentName && parentName !== 'there' ? parentName : (p.fullName || `${p.firstName || 'player'}_${p.lastName || ''}`)).trim().replace(/\s+/g, '_') || 'contact') + '.vcf';
    const contactItems = [
      emailHref ? `<a href="${emailHref}" target="_blank" rel="noopener noreferrer" title="${this.escape(parentEmail)}" style="${contactBase} background:#3b82f6; color:#fff;">✉ EMAIL</a>` : '',
      smsHref   ? `<a href="${smsHref}"   title="Text ${this.escape(this.formatPhone(parentPhone))}"       style="${contactBase} background:#10b981; color:#fff;">💬 SMS</a>` : '',
      telHref   ? `<a href="${telHref}"   title="Call ${this.escape(this.formatPhone(parentPhone))}"       style="${contactBase} background:#6366f1; color:#fff;">📞 CALL</a>` : '',
      vcardHref ? `<a href="${vcardHref}" download="${this.escape(vcardFilename)}" title="Save ${this.escape(parentFirst || p.firstName || 'contact')} to your phone contacts" style="${contactBase} background:#0ea5e9; color:#fff;">👤 SAVE</a>` : '',
    ].filter(Boolean);
    const contactBtns = contactItems.length > 0 ? `
      <details class="br-contact" style="position:relative; display:inline-block;">
        <summary style="${btnBase} background:#334155; color:#fff; border:none; cursor:pointer; list-style:none; user-select:none;"
                 title="Contact ${this.escape(parentFirst || 'parent')}${p.firstName ? ` (${this.escape(p.firstName)}'s parent)` : ''}">📇 CONTACT</summary>
        <div style="position:absolute; top:100%; left:0; z-index:20; margin-top:2px; display:flex; flex-direction:column; gap:2px; background:#0f172a; padding:3px; border-radius:4px; box-shadow:0 4px 12px rgba(0,0,0,0.45); border:1px solid #334155;">
          ${contactItems.join('')}
        </div>
      </details>` : '';

    const billingBadge = window.BillingBadge ? window.BillingBadge.render(p) : '';

    const cardId = `br-card-${p.leagueAppsUserId}`;

    // Card border: bright yellow by default for clear separation on the
    // dark background.  Heavy-overdue (4+ days) cards get a red border
    // tint so risk states pop from a distance.  Purgatory cards use the
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
    // rebuild the ordered list and POST /api/boys-roster/reorder.
    const dragAttrs = col && col.teamId
      ? `draggable="true" data-user-id="${p.leagueAppsUserId}" data-team-id="${col.teamId}"`
      : '';
    return `
      <div id="${cardId}" class="br-card" ${dragAttrs} style="background:var(--bg-tertiary, #1f2937); border-radius:6px; padding:4px 6px; border:${cardBorder}; ${cardShadow}">
        <div style="display:flex; flex-wrap:wrap; align-items:center; gap:4px; row-gap:3px;">
          ${posChip}
          <strong style="font-size:0.8rem; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:100%;">${this.escape(p.fullName) || '(no name)'}</strong>
          ${ageChip}
          ${genderChip}
          ${dobShort ? `<span style="font-size:0.85rem; color:#fff; white-space:nowrap;">🎂 ${this.escape(dobShort)}</span>` : ''}
          ${moveSelect}
          ${laBtn}
          ${delinqBtns}
          ${contactBtns}
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
  // via the br-drop-empty state on the column's br-drop-zone.
  //
  // After a drop, we rearrange the DOM in place, collect the ordered
  // list of userIds, POST /reorder, then reload the whole board so the
  // #N chips + coachSortOrder come back from the server.

  _dragClearMarkers() {
    this.element.querySelectorAll('.br-drop-before, .br-drop-after')
      .forEach(el => el.classList.remove('br-drop-before', 'br-drop-after'));
    this.element.querySelectorAll('.br-drop-empty')
      .forEach(el => el.classList.remove('br-drop-empty'));
  }

  onDragStart(e) {
    const card = e.target.closest && e.target.closest('.br-card[draggable="true"]');
    if (!card) return;
    this._dragSourceUserId = card.dataset.userId;
    this._dragSourceTeamId = card.dataset.teamId;
    card.classList.add('br-dragging');
    // Firefox requires setData() for dragstart to succeed at all.
    if (e.dataTransfer) {
      try {
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/plain', card.dataset.userId);
      } catch (_) { /* ignore */ }
    }
  }

  onDragEnd(_e) {
    this.element.querySelectorAll('.br-card.br-dragging')
      .forEach(el => el.classList.remove('br-dragging'));
    this._dragClearMarkers();
    this._dragSourceUserId = null;
    this._dragSourceTeamId = null;
  }

  onDragOver(e) {
    if (!this._dragSourceUserId) return;
    const zone = e.target.closest && e.target.closest('.br-drop-zone[data-drop-team-id]');
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

    const overCard = e.target.closest && e.target.closest('.br-card[draggable="true"]');
    if (!overCard || overCard.classList.contains('br-dragging')) {
      // Empty area (or over the currently dragged card) — highlight
      // the whole zone so the user knows "drop at end".
      if (zone.children.length === 0) zone.classList.add('br-drop-empty');
      return;
    }
    const rect = overCard.getBoundingClientRect();
    const before = (e.clientY - rect.top) < (rect.height / 2);
    overCard.classList.add(before ? 'br-drop-before' : 'br-drop-after');
  }

  onDragLeave(e) {
    // Only clear when the pointer leaves the drop zone entirely — not
    // when it moves between children within the same zone.  We check
    // relatedTarget: if it's still inside the same zone, do nothing.
    const zone = e.target.closest && e.target.closest('.br-drop-zone');
    if (!zone) return;
    const to = e.relatedTarget;
    if (to && zone.contains(to)) return;
    zone.classList.remove('br-drop-empty');
    zone.querySelectorAll('.br-drop-before, .br-drop-after')
      .forEach(el => el.classList.remove('br-drop-before', 'br-drop-after'));
  }

  async onDrop(e) {
    if (!this._dragSourceUserId) return;
    const zone = e.target.closest && e.target.closest('.br-drop-zone[data-drop-team-id]');
    if (!zone) return;
    const teamId = parseInt(zone.dataset.dropTeamId, 10);
    if (!teamId || String(teamId) !== this._dragSourceTeamId) return;

    e.preventDefault();
    const sourceCard = this.element.querySelector(
      `.br-card[draggable="true"][data-user-id="${this._dragSourceUserId}"][data-team-id="${this._dragSourceTeamId}"]`
    );
    if (!sourceCard) { this._dragClearMarkers(); return; }

    const overCard = e.target.closest && e.target.closest('.br-card[draggable="true"]');
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
      zone.querySelectorAll('.br-card[draggable="true"]')
    ).map(el => parseInt(el.dataset.userId, 10)).filter(n => Number.isFinite(n));
    if (orderedIds.length === 0) return;

    try {
      const res = await this.auth.fetch('/api/boys-roster/reorder', {
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
      const res = await this.auth.fetch('/api/boys-roster/assign', {
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
  //   • target == 35 / 120 / 910   → POST add.  Backend's mutex_group
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
      const res = await this.auth.fetch('/api/boys-roster/assign', {
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
      const res = await this.auth.fetch('/api/boys-roster/roster-status', {
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
