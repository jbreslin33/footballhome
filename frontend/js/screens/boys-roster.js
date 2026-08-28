// BoysRosterScreen — Live Boys/Girls roster pulled from LeagueApps every
// page load (both Boys Club + Girls Club programs — girls play on boys
// teams for now).  Mirror of MensRosterScreen with two youth-specific
// tweaks:
//   • Cards carry an age-group chip ("U10") derived from DOB (Aug-1
//     school-year cutover) and a gender chip (♂ Boy / ♀ Girl) so the
//     coach can spot "U10 girl playing on U10 Boys" at a glance.
//   • Move-to-column targets are DB-driven from data.columns (domain
//     = 'boys' in roster_columns) rather than hardcoded APSL/Liga1/
//     Dues Owed.  Add a column by inserting a row — no code change.
//
// Everything else (Payments badge, drag reorder, contact popover,
// delinquency PAY button, LA deep-link) is intentionally identical to
// mens.  The backend routes just point at BoysRosterController which
// shares MensTeamColumns/MensTeamAssignments parametrised by domain.
class BoysRosterScreen extends RosterScreenBase {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        /* Hide the default triangle marker on the CONTACT / ROSTER
           <summary> popovers so they render as clean buttons.  Scoped
           to this screen via .roster-move-details / .br-contact. */
        .roster-move-details > summary,
        .br-contact          > summary { list-style: none; }
        .roster-move-details > summary::-webkit-details-marker,
        .br-contact          > summary::-webkit-details-marker { display: none; }
        .roster-move-details > summary::marker,
        .br-contact          > summary::marker { display: none; content: ''; }

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
        <h1>🎽 Boys Teams</h1>
        <p class="subtitle">Live from LeagueApps — Boys + Girls Club (girls surfaced too; girls play on boys teams for now)</p>
      </div>

      <div style="padding: var(--space-2) 0;">
        <div id="br-banner" style="margin: 0 var(--space-2) var(--space-3); padding: var(--space-3); border-radius: 6px; background: #f1f5f9; border: 1px solid #e2e8f0; display:flex; align-items:center; gap: var(--space-3); flex-wrap: wrap; font-size: 14px;">
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
    RosterScreenBase.installMoveDropdownOutsideClose();
    this.wireMessageButtons();
    this.element.addEventListener('click', e => {
      if (e.target.closest('.back-btn')) return this.navigation.goBack();
      if (e.target.closest('#br-refresh')) return this.load({ refreshLa: true });
      const moveOpt = e.target.closest('.roster-move-option');
      if (moveOpt) return this.onMoveOptionClick(moveOpt);
      const toggle = e.target.closest('.br-roster-toggle');
      if (toggle) return this.onRosterToggleClick(toggle);
      const pill = e.target.closest('.br-pill');
      if (pill) return this.onPillClick(pill);
      const focusPill = e.target.closest('.br-team-focus-pill');
      if (focusPill) return this.onTeamFocusPillClick(focusPill);
      const viewPill = e.target.closest('.roster-view-pill');
      if (viewPill) {
        // Card view mode (2026-08-25) — shared with every roster board via
        // RosterScreenBase. Purely client-side, same as the focus pills.
        if (this.onViewModePillClick(viewPill) && this._data) this.renderRoster(this._data);
        return;
      }
      const laBtn = e.target.closest('.br-la-open');
      if (laBtn) { window.open(laBtn.dataset.laUrl, '_blank', 'noopener'); return; }
      const pauseBtn = e.target.closest('.br-copy-pause');
      if (pauseBtn) return this._copyPauseMessage(pauseBtn);
      // PAY-reminder click (2026-07-09 rewrite).  Owner directive:
      // "we need to make those buttons generate 'message' on the fly
      // and hit db after button".  Instead of navigating the stale
      // href immediately, we preventDefault, refetch the roster with
      // refreshLa=1 (forces a live LeagueApps sync), then find the
      // freshly-rendered anchor for this player + method and open
      // that href.  Guarantees the SMS/email body reflects the LA
      // outstandingBalance the coach just edited.
      const payLog = e.target.closest('.br-pay-log');
      if (payLog) {
        this._handlePayClickRefresh(payLog, e);
        return;
      }
      // 👤 PROFILE / ✎ EDIT buttons are now rendered by the shared
      // PersonActions component (components/PersonActions.js) and
      // routed globally by a delegated document-level click handler
      // installed once at app bootstrap (see app.js).  No per-screen
      // wiring needed here — the buttons carry data-la-user-id +
      // data-return-to and land on the universal PersonScreen.  The
      // whole-card click drill-down was removed 2026-07-14 to stop
      // it hijacking drag-and-drop moves.
    });

    this.element.addEventListener('change', e => {
      const posSelect = e.target.closest('.roster-position-select');
      if (posSelect) return this.onPositionSelectChange(posSelect);
      const roleSelect = e.target.closest('.mr-role-select');
      if (roleSelect) return this.onLineupRoleSelectChange(roleSelect);
      const statusSelect = e.target.closest('.mr-status-select');
      if (statusSelect) return this.onRosterStatusSelectChange(statusSelect);
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

  // Active/Inactive pill (RostersScreen host) — see mens-roster.js's
  // identical setIncludeInactive for the rationale.
  setIncludeInactive(value) {
    this.includeInactive = !!value;
    return this.load();
  }

  // quiet (2026-08-21): skips the loading-skeleton/banner flash — used
  // after an optimistic local action (move/reorder) where the board
  // already shows the new state and this is just background
  // reconciliation with the server, not a first load.
  async load({ refreshLa = false, quiet = false } = {}) {
    const loading = this.find('#br-loading');
    const errEl   = this.find('#br-error');
    const list    = this.find('#br-list');
    if (!quiet) {
      if (loading) loading.style.display = '';
      if (errEl)   errEl.style.display   = 'none';
      if (list)    list.style.display    = 'none';
      this.setBanner({
        icon: '⏳',
        text: refreshLa
          ? 'Pulling latest registrations from LeagueApps…'
          : 'Reloading roster from cache…',
      });
    }

    try {
      const t0  = performance.now();
      // refreshLa=1 → backend does a live LA fetch + payment sync.
      // Otherwise the backend serves its cached snapshot so mid-session
      // reloads (e.g. after a move) don't wait on LeagueApps.
      const params = new URLSearchParams();
      if (refreshLa) params.set('refreshLa', '1');
      if (this.includeInactive) params.set('includeInactive', '1');
      const qs = params.toString();
      const url = qs ? `/api/boys-roster?${qs}` : '/api/boys-roster';
      const res = await this.auth.fetch(url);
      if (!res.ok) {
        const body = await res.text();
        throw new Error(body.slice(0, 200) || `HTTP ${res.status}`);
      }
      const data = await res.json();
      const elapsed = ((performance.now() - t0) / 1000).toFixed(1);
      this._data = data;
      // Optional hook — RostersScreen (rosters.js) sets this so the
      // Teams panel can surface data.unassignedCount without reaching
      // into this screen's private DOM/state. Inherited by
      // GirlsRosterScreen (girls-roster.js extends this class).
      if (typeof this.onDataLoaded === 'function') this.onDataLoaded(data);

      if (loading) loading.style.display = 'none';
      if (list)    list.style.display    = '';

      // Banner intentionally shows ONLY roster-pertinent counts.
      // Financial roll-ups (overdue count, dues owed) were removed
      // 2026-07-14 per user directive: "the financial stuff can be
      // on payments screen or in player card when we click edit".
      // Per-card overdue signal is retained via the tiny status
      // pill on each player card; the club-wide aggregate lives on
      // the dedicated /payments screen where it belongs.
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
        errEl.textContent = `Failed to load team players: ${err.message}`;
      }
      this.setBanner({
        icon: '✗',
        text: `Could not reach LeagueApps: ${err.message}`,
        showRefresh: true,
      });
    }
  }

  // Boys/Girls contact the PARENT (owner: "for boys/girls its parents
  // obviously"). Same precedence renderPlayer already uses for the
  // per-card CONTACT button — parent fields are the truth, the player's
  // own phone/email are a fallback for records that omit them.
  // ── "Docs" reminder preset (owner 2026-08-27) ──────────────────────
  //
  // Only U8/U10/U12 Intramural get this button. The other intramural
  // columns (U6/U16/U19) deliberately do not — the owner named these
  // three. Matched on the column label because there is no
  // "needs-documents" flag on `teams`; if this list grows, a boolean
  // column there beats extending this regex.
  static DOCS_TEAM_RE = /^U(8|10|12)\s+Intramural$/i;

  // Same gate for the column DOCS row and the per-card 📄 DOCS button,
  // so a team never gets one without the other.
  static columnNeedsDocs(col) {
    if (!col || col.isUnassigned) return false;
    const name = String(col.label || '').replace(/^[^\p{L}\p{N}]+/u, '').trim();
    return BoysRosterScreen.DOCS_TEAM_RE.test(name);
  }

  static DOCS_PRESET = {
    key:     'docs',
    icon:    '📄',
    label:   'Docs reminder',
    subject: 'Lighthouse Soccer — travel team docs needed',
    body: [
      'Dear Lighthouse Soccer Parents, in order to play in the Philadelphia Parks & Rec Soccer League (All games in Philadelphia) you must please right away fill out this form that has you simply upload picture of birth certificate and head shot of child. We have a limited number of spots on travel so we are filling the spots as parents fill out form.',
      '',
      'https://forms.gle/n2bj8aHiTRqLs6cg9',
    ].join('\n'),
  };

  // Second row under the column header — kept off the header line
  // because Fit-mode columns are ~110px and the header already carries
  // the team name plus the count (see the 2026-08-26 fix for names
  // breaking one letter per line).
  // Email only (owner 2026-08-27: "the bcc bulk email works. but the
  // text ... just put a docs text reminder on the player cards until we
  // get the bulk text working"). BCC through Gmail reaches the whole
  // column reliably; a single sms: URL carrying every parent's number
  // does not, so texting is done one card at a time via the 📄 DOCS
  // button renderPlayer puts on each card in these columns.
  renderDocsRow(col, players) {
    if (!BoysRosterScreen.columnNeedsDocs(col)) return '';
    const name = String(col.label || '').replace(/^[^\p{L}\p{N}]+/u, '').trim();
    const btns = this.renderMessageButtons(name, players, {
      compact:  true,
      preset:   BoysRosterScreen.DOCS_PRESET,
      channels: ['email'],
    });
    if (!btns) return '';
    return `
      <div style="display:flex; align-items:center; gap:4px; flex-wrap:wrap; margin:0 0 6px;">
        <span style="font-size:0.65rem; font-weight:700; letter-spacing:0.03em; opacity:0.7;">DOCS</span>
        ${btns}
      </div>`;
  }

  boardScopeLabel() { return 'all boys'; }

  contactFor(p) {
    return {
      phone: (p && (p.parentPhone || p.phone)) || null,
      email: (p && (p.parentEmail || p.email)) || null,
    };
  }

  renderRoster(data) {
    const container = this.find('#br-list');

    // Columns are data-driven from `data.columns` (roster_columns with
    // domain='boys', not archived).  All non-Unassigned columns share
    // mutex_group='boys-selection' at the DB layer, so admin clicks
    // one move button and the row atomically leaves the others.
    //
    // The old "Dues Owed" column (team 915) was retired 2026-07-07 via
    // migration 100 — the OVERDUE chip on each card already surfaces
    // who owes dues, and parking warm bodies in a sin-bin cost playable
    // spots.  The `daysOverdue` + `delinquencyState='dues_owed'` fields
    // are still emitted per-player so the chip keeps working.
    const allCols = [
      { teamId: 0, label: '📦 Unassigned', color: '#475569', count: (data.unassigned || []).length, isUnassigned: true },
      ...data.columns,
    ];
    // columnScope (2026-08-16, rosters.js side-by-side layout): a caller
    // that only wants the Unassigned tray, or only wants real team
    // columns, sets this before mount instead of rendering the whole
    // board. Undefined/'all' (every other call site — direct board
    // navigation) keeps today's single-board behavior unchanged.
    const cols = this.columnScope === 'unassigned'
      ? allCols.filter(c => c.isUnassigned)
      : this.columnScope === 'teams'
        ? allCols.filter(c => !c.isUnassigned)
        : allCols;

    // Team-focus pills (2026-08-21): click a team's chip to isolate its
    // column; click again (or All) to bring every team back. Purely
    // client-side filter over the already-loaded data — no re-fetch.
    // Only offered on the Teams panel (columnScope==='unassigned' always
    // has exactly one column, nothing to focus down to).
    const showFocusPills = this.columnScope !== 'unassigned' && cols.length > 1;
    if (this.teamFocusId && !cols.some(c => c.teamId === this.teamFocusId)) {
      this.teamFocusId = null;
    }
    const visibleCols = this.teamFocusId ? cols.filter(c => c.teamId === this.teamFocusId) : cols;

    container.innerHTML = `
      <div style="display:flex; align-items:center; gap:var(--space-2); flex-wrap:wrap; margin: 0 var(--space-2) var(--space-3); padding:var(--space-2) var(--space-3); background:var(--bg-secondary); border-radius:var(--radius-md);">
        <span style="opacity:0.7; font-size:0.8rem; font-weight:600;">Columns:</span>
        ${showFocusPills ? `
          <button type="button" class="br-team-focus-pill" data-team-focus-id="0"
                  style="font-size:0.8rem; font-weight:700; padding:2px 10px; border-radius:999px; cursor:pointer;
                         border:1px solid ${this.teamFocusId ? 'var(--border-color)' : '#94a3b8'};
                         background:${this.teamFocusId ? 'transparent' : '#94a3b8'};
                         color:${this.teamFocusId ? 'inherit' : '#0f172a'};">All</button>
        ` : ''}
        ${cols.map(c => {
          const count = c.isUnassigned ? c.count : ((data.buckets[String(c.teamId)] || []).length);
          const cap = c.maxRoster != null ? `(${count}/${c.maxRoster})` : `(${count})`;
          const active = this.teamFocusId === c.teamId;
          if (!showFocusPills) {
            return `
              <span style="display:inline-flex; align-items:center; gap:6px; font-size:0.8rem; padding:2px 8px; border-radius:4px; border-left:3px solid ${c.color};">
                ${c.label} <span style="opacity:0.55;">${cap}</span>
              </span>`;
          }
          return `
            <button type="button" class="br-team-focus-pill" data-team-focus-id="${c.teamId}"
                    title="${active ? `Showing only ${c.label} — click All to see every team` : `Show only ${c.label}`}"
                    style="display:inline-flex; align-items:center; gap:6px; font-size:0.8rem; font-weight:${active ? 700 : 400}; padding:2px 8px; border-radius:999px; cursor:pointer;
                           border:1px solid ${c.color}; border-left:3px solid ${c.color};
                           background:${active ? c.color : 'transparent'}; color:${active ? '#fff' : 'inherit'};">
              ${c.label} <span style="opacity:${active ? '0.85' : '0.55'};">${cap}</span>
            </button>`;
        }).join('')}
        ${this.renderViewModePills()}
        ${this.renderBoardMessageButtons(data, cols)}
      </div>

      <div style="padding: 0 var(--space-2) var(--space-2);">
        <div style="${this.gridStyleFor(visibleCols.length)}">
          ${visibleCols.map(c => this.renderColumn(c, data)).join('')}
        </div>
      </div>
    `;
  }

  // Purely client-side — re-renders from the already-loaded data, no
  // network round-trip (see renderRoster's showFocusPills block).
  onTeamFocusPillClick(btn) {
    const id = parseInt(btn.dataset.teamFocusId, 10) || 0;
    this.teamFocusId = id || null;
    if (this._data) this.renderRoster(this._data);
  }

  // Cards get thinner when there are few columns (lots of room per col) and
  // wider when there are many (so the big move buttons still fit). Feeds
  // the wrapping grid's minmax() floor (see renderRoster) — columns that
  // don't fit on one row wrap to the next instead of needing overflow-x
  // scroll, which used to clip the move dropdown popover open below a
  // card near the bottom of a column (overflow-x:auto forces overflow-y
  // to auto too — a CSS quirk, not a real height shortage — found 2026-08-21).
  colMinWidth(n) {
    if (n <= 4) return '150px';
    if (n <= 6) return '130px';
    if (n <= 8) return '120px';
    return '110px';
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

    const renderList = (list) => list.map((p, i) => this.renderPlayer(p, data.columns, col, i + 1, list.length)).join('');

    const body = players.length === 0
      ? '<div style="opacity:0.5; font-size:0.85rem;">(empty)</div>'
      : renderList(players);

    // Column-header financial roll-up ("⚠ N OVERDUE") was removed
    // 2026-07-14 — belongs on the /payments screen, not here.  The
    // per-card overdue pill keeps the signal at the row level where
    // it's actionable for roster picks.

    return `
      <div style="background:var(--bg-secondary); border-radius:var(--radius-md); padding:8px; border-top:3px solid ${col.color}; min-width:${this.colBoxMinWidth()};">
        <div style="display:flex; justify-content:space-between; align-items:baseline; margin-bottom:6px; gap:6px;">
          <strong style="font-size:0.85rem;">${col.label}</strong>
          <span style="display:inline-flex; align-items:center; gap:6px;">
            ${col.isUnassigned ? '' : this.renderMessageButtons(col.label.replace(/^[^\p{L}\p{N}]+/u, ''), players, { compact: true })}
            ${countHtml}
          </span>
        </div>
        ${this.renderDocsRow(col, players)}
        <div class="br-drop-zone" data-drop-team-id="${col.isUnassigned ? '' : col.teamId}"
             style="display:flex; flex-direction:column; gap:8px; min-height:8px; min-width:${this.colBoxMinWidth()};">
          ${body}
        </div>
      </div>
    `;
  }

  renderPlayer(p, columns, col, position, totalInColumn = 0) {
    // Card redesign (2026-07-04): the coach's primary action on this
    // board is "move player X to roster Y".  Everything else (contact,
    // dues action) is secondary.  So the card leads with the move
    // popover and drops the tiny legacy pills entirely.  Contact +
    // dues actions are still present but sized so they're readable,
    // not decorative.

    // For boys/girls, we contact the PARENT, not the player.  The card
    // still shows the player name, but every contact action routes to the
    // parent by default.  Parent fields are the truth; player phone/email
    // are a fallback only for the rare records that omit them.
    const contactFirst = p.parentFirstName || '';
    const contactName  = p.parentName
      || `${contactFirst} ${p.parentLastName || ''}`.trim()
      || 'there';
    const contactPhone = p.parentPhone || p.phone || null;
    const contactEmail = p.parentEmail || p.email || null;

    // Polite parent-facing bodies for the generic CONTACT popover.
    // The PAY button below builds its own tier-scaled body.
    const kidRef       = p.firstName ? ` regarding ${p.firstName}` : '';
    const emailSubject = `Lighthouse 1893${p.firstName ? ` — ${p.firstName}` : ''}`;
    const emailBody    = `Hi ${contactFirst || 'there'},\n\nThis is Lighthouse 1893${kidRef}.\n\n`;
    const smsBody      = `Hi${contactFirst ? ' ' + contactFirst : ''}, this is Lighthouse 1893${kidRef}.`;

    const emailHref = contactEmail
      ? `https://mail.google.com/mail/?${new URLSearchParams({
          view:     'cm',
          fs:       '1',
          authuser: 'soccer@lighthouse1893.org',
          to:       contactEmail,
          su:       emailSubject,
          body:     emailBody,
        }).toString()}`
      : null;
    const smsHref = contactPhone ? `sms:${contactPhone}?&body=${encodeURIComponent(smsBody)}` : null;
    const telHref = contactPhone ? `tel:${contactPhone}` : null;

    // Full DOB (e.g. "3/10/2008").
    const dobShort = this.formatDobShort(p.birthDate);

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


    // ---- Move-to-roster dropdown -----------------------------------
    //
    // Targets are data-driven from data.columns (domain='boys' in
    // roster_columns).  All boys columns share mutex_group
    // 'boys-selection', so adding a player to one atomically removes
    // them from any other — same guarantee as mens.  "Unassigned"
    // (id 0) means remove from whichever real column they're on.
    // Rendering itself is identical to mens (and girls/women's, which
    // inherit this screen), so it lives once in RosterScreenBase.
    const { rosterSelectHtml: moveSelect, canMove } = this._teamCardCapabilities(p, columns, col);
    // Shared button style — as thin as legible.  Zero vertical padding
    // plus a tight line-height give ~11-12 px total height while the
    // sides keep a proper 5 px cushion.  All actions (move, delinq,
    // contact, payments pill) share this base so they align.
    const btnBase = 'padding:0 5px; font-size:0.66rem; font-weight:800; letter-spacing:0.02em; border-radius:3px; line-height:1.35; white-space:nowrap;';

    // Roster Role + Official Roster Status dropdowns (2026-08-22) — see
    // RosterScreenBase.renderRoleSelect / renderStatusSelect for the doc.
    const roleSelect   = this.renderRoleSelect(p, col, canMove);
    const statusSelect = this.renderStatusSelect(p, col, canMove);

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
    // 👤 VIEW button (2026-07-26) — dedicated drill-down into the
    // universal PersonScreen.  The boys roster is kept intentionally
    // slim, so only the View action is rendered here.
    const profileBtn = this.renderPersonActions(p, {
      returnTo: 'boys-roster',
      showEdit: false,
      // Sits next to the roster-move dropdown in a full-height strip
      // (renderCompactCard) — display:flex centering keeps the label
      // centered now that the button stretches taller than its text.
      // appearance:none + min-height:0 strip the native OS button-chrome
      // minimum height that browsers apply to real <button> elements
      // (the dropdown trigger is a <summary>, which has no such native
      // chrome, so it didn't need this — this button did).
      btnBaseStyle: 'font-size:0.68rem; padding:0 6px; line-height:1.2; appearance:none; -webkit-appearance:none; min-height:0; box-sizing:border-box; margin:0; display:flex; align-items:center; justify-content:center;',
    });
    // 📄 DOCS (2026-08-27) — texts ONE parent the same travel-documents
    // reminder the column's DOCS email sends, on the cards of the teams
    // that need it (columnNeedsDocs). Stands in for the bulk text that
    // was pulled from the DOCS row; a one-recipient sms: URL is the part
    // every Messages client gets right.
    const docsSmsHref = (contactPhone && BoysRosterScreen.columnNeedsDocs(col))
      ? `sms:${contactPhone}?&body=${encodeURIComponent(BoysRosterScreen.DOCS_PRESET.body)}`
      : null;
    const docsBtn = docsSmsHref
      ? `<a href="${docsSmsHref}"
            title="Text ${this.escape(this.formatPhone(contactPhone))} the travel documents reminder${p.firstName ? ` for ${this.escape(p.firstName)}` : ''}"
            style="${btnBase} border:none; cursor:pointer; background:#b45309; color:#fff; text-decoration:none; display:flex; align-items:center; justify-content:center;">
           📄 DOCS
         </a>`
      : '';

    let delinqBtns = '';
    // Prorate context (2026-07-09) — mirror mens-roster: if the youth
    // player is a mid-cycle signup who hasn't paid the full $35 yet,
    // the PAY reminder should explain the prorate math so the parent
    // knows exactly what LeagueApps will charge and when normal $35/mo
    // billing takes over.  Also opens the PAY buttons for fresh
    // signups (days=0) so the coach can send the invoicing note the
    // moment they register — no waiting for a failed charge.
    const pr = (window.BillingBadge && window.BillingBadge.projectedProrate)
      ? window.BillingBadge.projectedProrate(p)
      : null;
    const prorateOwed = !!(pr && pr.amount > 0);
    if ((days >= 1 || prorateOwed) && p.leagueAppsUserId) {
      // Amount preference order (2026-07-09 owner directive: "You can
      // change the emails by reading Balance Due from la which i am
      // manually editing before each email"):
      //   1. LA outstandingBalance   (authoritative when coach has set it)
      //   2. computed prorate amount (for mid-cycle signups where LA
      //      balance not yet edited)
      //   3. nextBillAmount          (backend monthly expectation)
      //   4. EXPECTED_MONTHLY_AMOUNT (final fallback so message never
      //      reads with an English phrase where a dollar figure belongs)
      const proAmt   = prorateOwed && pr && pr.amount > 0 ? pr.amount : null;
      const nbAmt    = p.nextBillAmount > 0 ? p.nextBillAmount : null;
      const amountNum = (p.outstandingBalance > 0)
        ? p.outstandingBalance
        : (proAmt != null ? proAmt : (nbAmt != null ? nbAmt : 35));
      const amountStr = Number.isInteger(amountNum) ? `$${amountNum}` : `$${amountNum.toFixed(2)}`;
      const daysStr   = daysAreExact
        ? `${days} day${days === 1 ? '' : 's'}`
        : 'a few days';
      const payUrl    = 'https://lighthouse1893.leagueapps.com/dashboard';

      // ── Parent-facing PAY reminder ──────────────────────────────
      //
      // Youth board voice: light, one gentle template for all tiers.
      // 2026-07-09 revision — user asked to drop the sliding-scale
      // apology copy in favor of a single "Gentle reminder" opener
      // that just explains we really need a valid card on file so
      // LeagueApps can auto-charge each month (cuts down admin work).
      // No more "hardship / work something out" escape hatches, no
      // more three-tier voice.
      const parentFirstStr = contactFirst ? ` ${contactFirst}` : '';
      const kidStr         = p.firstName ? ` ${p.firstName}'s` : ' your child\'s';

      // Copy rewritten 2026-07-09 per user directive: "right now i
      // need them to pay July and i don't want to run their cards and
      // surprise them. so gentle reminders."  Plus: "You can change
      // the emails by reading Balance Due from la which i am manually
      // editing before each email so you should read to construct
      // message on the fly".
      //
      // → Auto-charge language dropped (Aug 7 heads-up is separate).
      //   LA outstandingBalance is the authoritative amount (owner
      //   manually edits per player), so we render `amountStr` in the
      //   ask instead of computing on-the-fly $ math that could
      //   contradict LA.  Two variants:
      //     (a) prorate — mid-current-cycle signup, explains the
      //         partial-cycle context and points to the LA balance.
      //     (b) normal  — July dues outstanding, please pay.
      let payBody, payEmailBody;
      const greetingLine = `Hi${parentFirstStr},`;
      const signature    = `Thanks so much,\nLighthouse 1893`;
      // Aug 7 auto-charge heads-up (owner directive 2026-07-09):
      // "starting Aug 7 League Apps will auto charge $35 monthly dues.
      // But right now as a courtesy we are asking parents to pay
      // manually so the payment does not come as a surprise."  Goes
      // on ALL youth PAY messages (prorate + normal, SMS + email).
      const autoChargeNote = `Heads-up: starting Aug 7 LeagueApps will auto-charge the $35 monthly dues to the card on file. Right now as a courtesy we're asking parents to pay manually so the charge doesn't come as a surprise.`;
      if (prorateOwed) {
        const regShort = pr.regDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
        payBody = `Hi${parentFirstStr}, welcome to Lighthouse 1893! Since${kidStr} registration came in on ${regShort} (mid-cycle), July dues are prorated for the ${pr.daysRemain} of ${pr.cycleDays} days remaining — ${amountStr} for July. Gentle reminder to log in and pay ${amountStr} on LeagueApps when you get a moment: ${payUrl}. ${autoChargeNote} Thanks so much!`;
        payEmailBody = [
          greetingLine,
          `Welcome to Lighthouse 1893! Since${kidStr} registration came in on ${regShort} (mid-cycle), July dues are prorated for the ${pr.daysRemain} of ${pr.cycleDays} days remaining in the cycle.`,
          `Balance for July:  ${amountStr}.`,
          `Gentle reminder to log in and pay ${amountStr} on LeagueApps when you get a moment:\n${payUrl}`,
          autoChargeNote,
          signature,
        ].join('\n\n');
      } else {
        payBody = `Hi${parentFirstStr}, gentle reminder from Lighthouse 1893 —${kidStr} July dues (${amountStr}) are still outstanding on LeagueApps. When you get a moment please log in and pay, and while you're in there please make sure a valid card is saved on file: ${payUrl}. ${autoChargeNote} Thanks so much!`;
        payEmailBody = [
          greetingLine,
          `Gentle reminder from Lighthouse 1893 —${kidStr} July dues (${amountStr}) are still outstanding on LeagueApps.`,
          `When you get a moment please log in and pay, and while you're in there please make sure a valid card is saved on file:\n${payUrl}`,
          autoChargeNote,
          signature,
        ].join('\n\n');
      }

      // Two buttons: 💬 PAY (SMS to parent) and ✉ PAY (email to parent).
      // Whichever channel the parent uses, one tap gets there.  If we
      // only have one of the two, only that button renders.
      const paySmsHref = contactPhone
        ? `sms:${contactPhone}?&body=${encodeURIComponent(payBody)}`
        : null;
      const payEmailHref = contactEmail
        ? `https://mail.google.com/mail/?${new URLSearchParams({
            view:     'cm',
            fs:       '1',
            authuser: 'soccer@lighthouse1893.org',
            to:       contactEmail,
            su:       `Lighthouse 1893 — quick note about ${p.firstName || 'your child'}'s dues`,
            body:     payEmailBody,
          }).toString()}`
        : null;

      const paySmsBtn = paySmsHref
        ? `<a href="${paySmsHref}"
              class="br-pay-log"
              data-la-user-id="${p.leagueAppsUserId || ''}"
              data-method="sms"
              data-amount="${amountNum != null ? amountNum : ''}"
              data-days-overdue="${daysAreExact ? days : ''}"
              data-tier="${daysAreExact ? (days >= 7 ? '7+' : (days >= 4 ? '4-6' : '1-3')) : ''}"
              title="Text ${this.escape(this.formatPhone(contactPhone))} a polite dues reminder"
              style="${btnBase} border:none; cursor:pointer; background:#059669; color:#fff; text-decoration:none;">
             💬 PAY
           </a>`
        : '';
      const payEmailBtn = payEmailHref
        ? `<a href="${payEmailHref}" target="_blank" rel="noopener noreferrer"
              class="br-pay-log"
              data-la-user-id="${p.leagueAppsUserId || ''}"
              data-method="email"
              data-amount="${amountNum != null ? amountNum : ''}"
              data-days-overdue="${daysAreExact ? days : ''}"
              data-tier="${daysAreExact ? (days >= 7 ? '7+' : (days >= 4 ? '4-6' : '1-3')) : ''}"
              title="Email ${this.escape(contactEmail)} a polite dues reminder"
              style="${btnBase} border:none; cursor:pointer; background:#0284c7; color:#fff; text-decoration:none;">
             ✉ PAY
           </a>`
        : '';
      // Last-reminder pill sits IMMEDIATELY before the PAY buttons so
      // the admin sees "already texted 2h ago" before tapping again.
      const lastReminderPill = window.BillingBadge && window.BillingBadge.renderLastPayReminder
        ? window.BillingBadge.renderLastPayReminder(p)
        : '';
      delinqBtns = `${lastReminderPill}${paySmsBtn}${payEmailBtn}`;
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
    const vcardHref = (contactPhone || contactEmail)
      ? this.buildVcardHref({
          fullName:  contactName && contactName !== 'there' ? contactName : (p.fullName || `${p.firstName || ''} ${p.lastName || ''}`.trim()),
          firstName: contactFirst || p.firstName,
          lastName:  p.parentLastName || p.lastName,
          phone:     contactPhone,
          email:     contactEmail,
          org:       `Lighthouse 1893 Youth`,
          note:      p.firstName ? `Parent of ${p.firstName}${p.lastName ? ' ' + p.lastName : ''}` : '',
        })
      : null;
    const vcardFilename = ((contactName && contactName !== 'there' ? contactName : (p.fullName || `${p.firstName || 'player'}_${p.lastName || ''}`)).trim().replace(/\s+/g, '_') || 'contact') + '.vcf';
    const contactItems = [
      emailHref ? `<a href="${emailHref}" target="_blank" rel="noopener noreferrer" title="${this.escape(contactEmail)}" style="${contactBase} background:#3b82f6; color:#fff;">✉ EMAIL</a>` : '',
      smsHref   ? `<a href="${smsHref}"   title="Text ${this.escape(this.formatPhone(contactPhone))}"       style="${contactBase} background:#10b981; color:#fff;">💬 SMS</a>` : '',
      telHref   ? `<a href="${telHref}"   title="Call ${this.escape(this.formatPhone(contactPhone))}"       style="${contactBase} background:#6366f1; color:#fff;">📞 CALL</a>` : '',
      vcardHref ? `<a href="${vcardHref}" download="${this.escape(vcardFilename)}" title="Save ${this.escape(contactFirst || p.firstName || 'contact')} to your phone contacts" style="${contactBase} background:#0ea5e9; color:#fff;">👤 SAVE</a>` : '',
    ].filter(Boolean);
    const contactBtns = contactItems.length > 0 ? `
      <details class="br-contact" style="position:relative; display:inline-block;">
        <summary style="${btnBase} background:#334155; color:#fff; border:none; cursor:pointer; list-style:none; user-select:none;"
                 title="Contact ${this.escape(contactFirst || 'parent')}${p.firstName ? ` (${this.escape(p.firstName)}'s parent)` : ''}">📇 CONTACT</summary>
        <div style="position:absolute; top:100%; left:0; z-index:20; margin-top:2px; display:flex; flex-direction:column; gap:2px; background:#0f172a; padding:3px; border-radius:4px; box-shadow:0 4px 12px rgba(0,0,0,0.45); border:1px solid #334155;">
          ${contactItems.join('')}
        </div>
      </details>` : '';

    const duesLabel = this.renderDuesLabel(p);
    const billingBadge = window.BillingBadge ? window.BillingBadge.render(p) : '';

    const cardId = `br-card-${p.leagueAppsUserId}`;

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

    // Row 1: rank + name + roster-move dropdown (far right). Row 2: DOB +
    // age group + dues + view button (far right).
    return this.renderCompactCard({
      player: p,
      col,
      position,
      totalInColumn,
      cardClass: 'br-card',
      cardId,
      dobShort,
      duesLabel,
      rosterSelectHtml: moveSelect,
      roleSelectHtml: roleSelect,
      statusSelectHtml: statusSelect,
      viewButtonHtml: `${docsBtn}${profileBtn}`,
      borderColor: cardBorder,
      canMove,
    });
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

  // Resolves "where in this zone does clientY want to insert" from the
  // pointer's Y position alone — not from which element it's precisely
  // hovering. Old behavior required the pointer to be directly over a
  // card's rect to get any insertion marker at all; landing in the 8px
  // gap between cards (easy on the compact rows this board uses) fell
  // through to "no overCard" and silently reinterpreted the drop as
  // "append to end", which read as the drag just not working. Walking
  // every non-dragging card's vertical midpoint instead makes the whole
  // zone height — gaps included — resolve to a sensible slot, matching
  // ordinary Trello-style drag-reorder behavior.
  _dragInsertionPoint(zone, clientY) {
    const cards = Array.from(zone.querySelectorAll('.br-card[draggable="true"]'))
      .filter(el => !el.classList.contains('br-dragging'));
    for (const card of cards) {
      const rect = card.getBoundingClientRect();
      if (clientY < rect.top + rect.height / 2) return { before: card, cards };
    }
    return { before: null, cards };
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

    const { before, cards } = this._dragInsertionPoint(zone, e.clientY);
    if (before) {
      before.classList.add('br-drop-before');
    } else if (cards.length === 0) {
      // Nothing left to anchor to (empty column, or dragging the column's
      // only card) — highlight the whole zone so the user knows "drop here".
      zone.classList.add('br-drop-empty');
    } else {
      cards[cards.length - 1].classList.add('br-drop-after');
    }
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

    const { before } = this._dragInsertionPoint(zone, e.clientY);
    if (before) {
      before.parentNode.insertBefore(sourceCard, before);
    } else {
      zone.appendChild(sourceCard);
    }
    this._dragClearMarkers();

    // Collect ordered userIds (+ parallel personIds, when every card has
    // one) directly from the DOM (source of truth after the manual
    // insertBefore above) and persist. personIds is the drift-immune
    // path (see MensTeamAssignments::reorderTeamForPersons) — sent
    // whenever available so a stale persons.la_user_id can't make one
    // card's drag silently no-op and snap back after reload.
    const cardEls = Array.from(zone.querySelectorAll('.br-card[draggable="true"]'));
    const orderedIds = cardEls
      .map(el => parseInt(el.dataset.userId, 10)).filter(n => Number.isFinite(n));
    if (orderedIds.length === 0) return;
    const orderedPersonIds = cardEls.map(el => parseInt(el.dataset.personId, 10));
    const personIds = orderedPersonIds.every(n => Number.isFinite(n)) ? orderedPersonIds : null;

    try {
      const res = await this.auth.fetch('/api/boys-roster/reorder', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ teamId, userIds: orderedIds, ...(personIds ? { personIds } : {}) }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      // Quiet reload so #N chips + backend sort come back authoritative
      // without flashing the loading skeleton over an already-reordered board.
      await this.load({ quiet: true });
    } catch (err) {
      alert(`Could not save order: ${err.message}`);
      await this.load({ quiet: true });
    }
  }

  // Slot picker (2026-08-21) — alternative to drag-reorder for coaches
  // who find drag unreliable ("fails if you don't drag it just right").
  // Same persistence path as onDrop (DOM-first reorder, then POST the
  // rebuilt order to the reorder endpoint) — just triggered by a <select>
  // change instead of a drag gesture.
  async onPositionSelectChange(select) {
    const teamId = parseInt(select.dataset.teamId, 10);
    const targetPos = parseInt(select.value, 10);
    if (!teamId || !targetPos) return;

    const card = select.closest('.br-card[draggable="true"]');
    const zone = card && card.closest('.br-drop-zone[data-drop-team-id]');
    if (!card || !zone) return;

    const cardEls = Array.from(zone.querySelectorAll('.br-card[draggable="true"]'));
    const fromIdx = cardEls.indexOf(card);
    const toIdx   = targetPos - 1;
    if (fromIdx === -1 || toIdx === fromIdx) return;

    cardEls.splice(fromIdx, 1);
    cardEls.splice(Math.max(0, Math.min(toIdx, cardEls.length)), 0, card);
    cardEls.forEach(el => zone.appendChild(el));

    const orderedIds = cardEls.map(el => parseInt(el.dataset.userId, 10)).filter(n => Number.isFinite(n));
    if (orderedIds.length === 0) return;
    const orderedPersonIds = cardEls.map(el => parseInt(el.dataset.personId, 10));
    const personIds = orderedPersonIds.every(n => Number.isFinite(n)) ? orderedPersonIds : null;

    try {
      const res = await this.auth.fetch('/api/boys-roster/reorder', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ teamId, userIds: orderedIds, ...(personIds ? { personIds } : {}) }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      await this.load({ quiet: true });
    } catch (err) {
      alert(`Could not save order: ${err.message}`);
      await this.load({ quiet: true });
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
      // Easiest correct re-render: quiet reload (cheap — 53 records).
      await this.load({ quiet: true });
    } catch (err) {
      btn.disabled = false;
      btn.style.opacity = '';
      alert(`Could not save assignment: ${err.message}`);
    }
  }

  // Move-to-roster <details> popover option handler (2026-07-04 pm).
  // 2026-08-16 (multi-assign): each card's dropdown owns exactly ONE
  // team_persons row (`currentTeamId`, threaded through from
  // RosterScreenBase.renderMoveDropdown):
  //   • target == 0 (Unassigned)  → POST remove on `currentTeamId`, the
  //     row THIS card represents. Never touches any other active row
  //     the player may hold. No-op if this card is already Unassigned.
  //   • any other target team      → POST add. Purely additive
  //     (MensTeamAssignments::addAssignmentForPerson no longer closes
  //     sibling rows) — the player keeps every other team they're on.
  async onMoveOptionClick(btn) {
    const userId        = parseInt(btn.dataset.userId, 10);
    const personId       = parseInt(btn.dataset.personId, 10) || undefined;
    const targetTeamId  = parseInt(btn.dataset.targetTeamId, 10);
    const currentTeamId = parseInt(btn.dataset.currentTeamId || '0', 10);
    if (!userId || Number.isNaN(targetTeamId)) return;

    // Close the popover immediately for snappier UX — also doubles as
    // "roll it back up" when the option clicked is the current team,
    // which is a no-op below.
    const details = btn.closest('details');
    if (details) details.open = false;
    if (targetTeamId === currentTeamId) return;

    // Instant feedback (2026-08-21): fade the whole card right away so
    // the coach sees the move registered immediately, instead of waiting
    // on the network + a full board reload to notice anything happened.
    // A quiet reload right after brings back the authoritative board
    // fast enough that the fade reads as "in progress" rather than a stall.
    const card = btn.closest('.br-card');
    if (card) { card.style.opacity = '0.35'; card.style.pointerEvents = 'none'; }

    btn.disabled = true;
    btn.style.opacity = '0.4';
    try {
      let body;
      if (targetTeamId === 0) {
        if (currentTeamId <= 0) { await this.load({ quiet: true }); return; }
        body = { leagueAppsUserId: userId, personId, teamId: currentTeamId, action: 'remove' };
      } else {
        body = { leagueAppsUserId: userId, personId, teamId: targetTeamId, action: 'add' };
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
      await this.load({ quiet: true });
      // Tell the sibling Unassigned/Teams panel (if RostersScreen has
      // wired one up) to quietly catch up too — this card's board just
      // reloaded itself, but the OTHER panel's cached data still thinks
      // this player is where they were before the move.
      if (typeof this.onMembershipChanged === 'function') this.onMembershipChanged();
    } catch (err) {
      if (card) { card.style.opacity = ''; card.style.pointerEvents = ''; }
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
      await this.load({ quiet: true });
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

  // PAY-button per-click refresh (2026-07-09).  When the coach taps
  // 💬 PAY or ✉ PAY, refetch the full roster with refreshLa=1 first
  // so the message body reflects the balance the coach just edited
  // in LA — no more sending yesterday's numbers because the tab
  // hasn't been refreshed.  Then find the freshly-rendered anchor
  // (which has a rebuilt sms:/https: href with fresh amount) and
  // navigate to that href.
  //
  // Popup-blocker note: for the email variant we synchronously open
  // about:blank in a new tab BEFORE awaiting the refresh, so the tab
  // survives the async gap.  After the refresh completes we point
  // that tab at the fresh Gmail compose URL.
  async _handlePayClickRefresh(payLog, e) {
    e.preventDefault();
    const uid    = payLog.dataset.laUserId;
    const method = payLog.dataset.method;
    const fallbackHref = payLog.getAttribute('href');

    // Reserve the tab now so popup blockers accept it — must be
    // synchronous inside the click handler, before any await.
    //
    // IMPORTANT: do NOT pass 'noopener' in the features string.  Per
    // HTML spec, when noopener is requested window.open() returns
    // null, so `emailTab.location.href = ...` below would throw, the
    // catch block would fall through to `window.location.href` and
    // Gmail would open in the CURRENT tab (2026-07-09 regression).
    // We null out `opener` after the handoff instead — same security
    // guarantee, without losing the window handle.
    const emailTab = method === 'email'
      ? window.open('about:blank', '_blank')
      : null;

    // Optimistic visual feedback — the anchor is about to be re-rendered
    // out of existence by this.load() but the loader banner will take over.
    payLog.style.opacity = '0.55';

    try {
      // Full-roster refetch.  Slow (2-5s while LA responds) but the
      // correct source of truth.  A single-player refresh endpoint
      // could optimize this later.
      await this.load({ refreshLa: true });

      // Find the freshly-rendered anchor for this uid + method.  The
      // href on this new node has the up-to-date amount baked in.
      const selector = `.br-pay-log[data-la-user-id="${uid}"][data-method="${method}"]`;
      const freshAnchor = this.element.querySelector(selector);
      const targetHref  = freshAnchor ? freshAnchor.getAttribute('href') : fallbackHref;

      // Log the reminder (fire and forget) using the fresh anchor if
      // it exists so data-attributes are the current amount/tier.
      this._logPayReminder(freshAnchor || payLog);

      if (!targetHref) return;
      if (method === 'email' && emailTab) {
        try { emailTab.opener = null; } catch (_) { /* cross-origin after nav */ }
        emailTab.location.href = targetHref;
      } else {
        window.location.href = targetHref;
      }
    } catch (err) {
      // Refresh failed — fall back to the stale href so the coach
      // still gets some message rather than nothing.
      console.warn('[boys] PAY refresh failed, using stale href:', err);
      this._logPayReminder(payLog);
      if (fallbackHref) {
        if (emailTab) {
          try { emailTab.opener = null; } catch (_) { /* cross-origin after nav */ }
          emailTab.location.href = fallbackHref;
        } else {
          window.location.href = fallbackHref;
        }
      } else if (emailTab) {
        emailTab.close();
      }
    }
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

  // Fire-and-forget POST /api/pay-reminder-log on 💬 PAY / ✉ PAY click.
  // Does NOT block the sms:/mailto: navigation.  keepalive:true lets
  // the request complete after the tab switches away.  We also
  // optimistically swap the "last reminder" pill in place so the admin
  // sees "📩 SMS · just now" without waiting for a full re-load.
  _logPayReminder(anchor) {
    const laUserId = parseInt(anchor.dataset.laUserId, 10);
    const method   = anchor.dataset.method;
    if (!laUserId || !method) return;
    const body = {
      leagueAppsUserId: laUserId,
      method,
      club:  'boys',
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

    // Optimistic UI: paint fresh pill in every slot for this uid on the
    // page (there may be multiple cards if this player is in more than
    // one column) so the admin gets instant feedback.
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
