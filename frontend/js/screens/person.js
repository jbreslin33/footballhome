// PersonScreen ────────────────────────────────────────────────────────────
//
// Universal "everything we know about one person" profile.  Reachable
// from every card that shows a person (Members, Payments, Rosters,
// eventually Coaches / Admins / RSVPs) so the operator has a single
// destination to open when they click a name.
//
// Backend endpoint: `GET /api/persons/la/:leagueAppsUserId` returns a
// JSON bundle with { person, contact, memberships, billing, chargeFlags,
// overrides, merges }.  See `backend/src/controllers/PersonProfileController.h`
// for the exact shape.  We render every section, hide the truly empty
// ones, and never client-side-cache — every entry re-fetches (matches
// the "no caching anywhere" project rule).
//
// Navigation
// ──────────
//   this.navigation.goTo('person', { leagueAppsUserId: '12345' })
//   this.navigation.goTo('person', { personId: 42 })
//   this.navigation.goTo('person', { personId: 42, edit: '1' })
//
// A `returnTo` hint lets the back button pop to the caller's screen.
// If absent we fall back to the browser's own history.
class PersonScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.navigation = navigation;
    this.auth = auth;
    this.leagueAppsUserId = null;
    this.personId = null;
    this._returnTo = null;
    this._returnToParams = null;
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="person-title">Person</h1>
        <p class="subtitle" id="person-subtitle">Loading profile…</p>
      </div>

      <div style="padding: var(--space-4); max-width: 900px; margin: 0 auto;">

        <div id="person-loading" style="padding: var(--space-6); text-align:center; opacity:0.7;">
          Loading…
        </div>

        <div id="person-error" style="display:none; padding: var(--space-4);
             text-align:center; color: var(--color-error);"></div>

        <div id="person-body" style="display:none;">

          <!-- Header card: name, birth date, FH-member status, LA payment status -->
          <section class="ps-card" id="ps-header-card"></section>

          <!-- Contact: emails + phones -->
          <section class="ps-card" id="ps-contact-card">
            <h2 class="ps-card-title">Contact</h2>
            <div id="ps-emails-wrap"></div>
            <div id="ps-phones-wrap" style="margin-top: var(--space-3);"></div>
          </section>

          <!-- FH login account (users row linked to this person) -->
          <section class="ps-card" id="ps-account-card">
            <h2 class="ps-card-title">Football Home account</h2>
            <div id="ps-account-body"></div>
          </section>

          <!-- LA memberships (current + past).  Past rows render greyed
               with an "ended" timestamp so an admin can tell whether
               someone was previously paused / dropped. -->
          <section class="ps-card" id="ps-memberships-card">
            <h2 class="ps-card-title">LeagueApps memberships</h2>
            <div id="ps-memberships-list"></div>
          </section>

          <!-- Team assignments — every roster row for this person's
               player record, current rows first then historical. -->
          <section class="ps-card" id="ps-teams-card">
            <h2 class="ps-card-title">
              Team assignments <span id="ps-teams-count" class="ps-count"></span>
            </h2>
            <div id="ps-teams-list"></div>
          </section>

          <!-- RSVP eligibility + the next few matches this player can
               actually RSVP to.  Drill-down button opens the shared
               RSVP-eligibility admin screen filtered to this person. -->
          <section class="ps-card" id="ps-rsvp-card">
            <h2 class="ps-card-title">
              RSVP eligibility <span id="ps-rsvp-count" class="ps-count"></span>
            </h2>
            <div id="ps-rsvp-teams"></div>
            <h3 class="ps-subheading" style="margin-top: var(--space-4);">
              Upcoming matches <span id="ps-upcoming-count" class="ps-count"></span>
            </h3>
            <div id="ps-upcoming-list"></div>
            <div style="margin-top: var(--space-3); text-align: right;">
              <button type="button" class="btn btn-secondary btn-sm"
                      id="ps-open-rsvp-admin">
                Manage RSVP eligibility →
              </button>
            </div>
          </section>

          <!-- Upcoming bill (person_billing) + open/recent charge flags. -->
          <section class="ps-card" id="ps-billing-card">
            <h2 class="ps-card-title">Billing</h2>
            <div id="ps-billing-summary"></div>
            <div id="ps-flags-wrap" style="margin-top: var(--space-3);"></div>
            <div style="margin-top: var(--space-3); text-align: right;">
              <button type="button" class="btn btn-secondary btn-sm"
                      id="ps-open-payments">
                Open in Payments →
              </button>
            </div>
          </section>

          <!-- Recent RSVP responses this player has actually made. -->
          <section class="ps-card" id="ps-recent-rsvps-card">
            <h2 class="ps-card-title">
              Recent RSVP responses <span id="ps-recent-rsvps-count" class="ps-count"></span>
            </h2>
            <div id="ps-recent-rsvps-list"></div>
          </section>

          <!-- Data-quality tier: field overrides + merge history. -->
          <section class="ps-card" id="ps-dq-card">
            <h2 class="ps-card-title">Data quality</h2>
            <div id="ps-overrides-wrap"></div>
            <div id="ps-merges-wrap" style="margin-top: var(--space-3);"></div>
          </section>

          <!-- Scraped league/opponent identity candidates (admin-confirmed link). -->
          <section class="ps-card" id="ps-scraped-card">
            <h2 class="ps-card-title">
              Scraped identity matches
              <span id="ps-scraped-count" class="ps-count"></span>
            </h2>
            <p style="margin: 0 0 var(--space-2); font-size:0.85rem; opacity:0.7;">
              Name matches against scraped league/opponent people with no LA membership.
              Confirm to merge their roster onto this Lighthouse person (reversible).
            </p>
            <div id="ps-scraped-list"></div>
          </section>

        </div>
      </div>

      <style>
        .ps-card {
          background: var(--bg-secondary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          padding: var(--space-4);
          margin-bottom: var(--space-3);
        }
        .ps-card-title {
          margin: 0 0 var(--space-3) 0;
          font-size: 1rem;
          font-weight: 600;
          opacity: 0.85;
          text-transform: uppercase;
          letter-spacing: 0.05em;
        }
        .ps-name {
          font-size: 1.5rem;
          font-weight: 700;
          margin: 0 0 var(--space-2) 0;
        }
        .ps-meta {
          display: flex;
          flex-wrap: wrap;
          gap: var(--space-2);
          margin-top: var(--space-2);
        }
        .ps-pill {
          display: inline-block;
          padding: 2px 10px;
          border-radius: 9999px;
          font-size: 0.8rem;
          border: 1px solid var(--color-border);
          background: var(--bg-primary);
        }
        .ps-pill.member  { background:#059669; color:#fff; border-color:#059669; }
        .ps-pill.paused  { background:#f59e0b; color:#000; border-color:#f59e0b; }
        .ps-pill.dropped { background:#6b7280; color:#fff; border-color:#6b7280; }
        .ps-pill.flag    { background:#dc2626; color:#fff; border-color:#dc2626; }

        .ps-row {
          display: flex;
          justify-content: space-between;
          align-items: baseline;
          gap: var(--space-3);
          padding: var(--space-2) 0;
          border-bottom: 1px dashed var(--color-border);
        }
        .ps-row:last-child { border-bottom: none; }
        .ps-row-label { opacity: 0.7; font-size: 0.9rem; }
        .ps-row-value { font-weight: 500; word-break: break-all; }
        .ps-row-value.muted { opacity: 0.5; }

        .ps-empty {
          padding: var(--space-3);
          text-align: center;
          opacity: 0.5;
          font-size: 0.9rem;
          font-style: italic;
        }

        /* Section-heading count badge (e.g. "Team assignments  3"). */
        .ps-count {
          display: inline-block;
          margin-left: 6px;
          padding: 1px 8px;
          border-radius: 9999px;
          background: var(--bg-primary);
          border: 1px solid var(--color-border);
          font-size: 0.75rem;
          opacity: 0.75;
          font-weight: 500;
          text-transform: none;
          letter-spacing: 0;
          vertical-align: middle;
        }
        .ps-subheading {
          margin: 0 0 var(--space-2);
          font-size: 0.85rem;
          font-weight: 600;
          opacity: 0.7;
          text-transform: uppercase;
          letter-spacing: 0.05em;
        }
        .btn-sm {
          padding: 4px 12px;
          font-size: 0.85rem;
        }

        /* Team / match / RSVP list rows.  Denser than ps-row so a
           player rostered on 5 teams doesn't overflow the card. */
        .ps-line {
          display: flex;
          justify-content: space-between;
          align-items: baseline;
          gap: var(--space-3);
          padding: 6px 0;
          border-bottom: 1px dashed var(--color-border);
          font-size: 0.9rem;
        }
        .ps-line:last-child { border-bottom: none; }
        .ps-line.past { opacity: 0.55; }
        .ps-line-primary { font-weight: 500; }
        .ps-line-meta    { opacity: 0.7; font-size: 0.8rem; text-align: right; }
        .ps-line-meta .ps-jersey {
          display: inline-block;
          min-width: 22px;
          padding: 0 4px;
          margin-right: 6px;
          background: var(--bg-primary);
          border: 1px solid var(--color-border);
          border-radius: 4px;
          text-align: center;
          font-weight: 700;
          font-size: 0.75rem;
        }
      </style>
    `;
    this.element = div;

    div.querySelector('.back-btn').addEventListener('click', () => this._goBack());

    // Drill-down: RSVP eligibility → RsvpEligibilityScreen (LA-user
    // scoped filter is handled by that screen; we just deep-link).
    div.querySelector('#ps-open-rsvp-admin')
      .addEventListener('click', () => this._openRsvpAdmin());

    // Drill-down: Billing → Payments screen (person view).  Payments
    // opens on the "members" view already; the LA user id lets the
    // screen scroll / highlight this person if it grows that behavior
    // later — for now the deep-link at least gets the operator there
    // in one click instead of navigating manually.
    div.querySelector('#ps-open-payments')
      .addEventListener('click', () => this._openPayments());

    // Inline RSVP toggles + unmerge actions (delegation — chips are
    // rebuilt on every _render).
    div.addEventListener('click', (e) => {
      const chip = e.target.closest('[data-rsvp-team-id]');
      if (chip) {
        e.preventDefault();
        const teamId = Number(chip.getAttribute('data-rsvp-team-id'));
        const want = chip.getAttribute('data-elig-on') !== '1';
        this._toggleRsvp(teamId, want, chip);
        return;
      }
      const unmergeBtn = e.target.closest('[data-unmerge-id]');
      if (unmergeBtn) {
        e.preventDefault();
        this._unmerge(Number(unmergeBtn.getAttribute('data-unmerge-id')), unmergeBtn);
        return;
      }
      const linkBtn = e.target.closest('[data-link-scraped]');
      if (linkBtn) {
        e.preventDefault();
        this._linkScraped(Number(linkBtn.getAttribute('data-link-scraped')), linkBtn);
      }
    });

    return div;
  }

  onEnter(params) {
    // Accept LA user id and/or personId.  PersonActions may send either
    // (or both).  Prefer the explicit LA id when present; otherwise load
    // by persons.id via GET /api/persons/:personId.
    const rawLa = params?.leagueAppsUserId ?? params?.laUserId ?? null;
    this.leagueAppsUserId = rawLa != null && String(rawLa) !== ''
      ? String(rawLa)
      : null;
    const rawPid = params?.personId ?? null;
    this.personId = rawPid != null && String(rawPid) !== ''
      ? String(rawPid)
      : null;
    this._returnTo = params?.returnTo || null;
    this._returnToParams = params?.returnToParams || null;
    // `edit=1` is set by the shared PersonActions Edit button.  Both
    // View and Edit land on this same Person hub; Edit remembers the
    // operator intent as editable controls expand here.
    this._editMode = params?.edit === '1' || params?.edit === true;

    if (!this.leagueAppsUserId && !this.personId) {
      this._showError('No leagueAppsUserId or personId provided');
      return;
    }
    this._load();
  }

  _goBack() {
    // ALWAYS pop the browser history entry rather than pushing a new
    // one onto the stack.  Pushing (via navigation.goTo) leaves a
    // phantom /person entry directly behind the caller — so the
    // caller's own Back button (which uses history.back / goBack)
    // lands the operator on /person again instead of the tile that
    // led them here (admin-club, etc.).  See members.js
    // _snapshotHistoryState for the paired half of this contract:
    // callers save their current filter state INTO their history
    // entry before opening us, so the browser back-nav restores the
    // exact view we came from.
    //
    // Fallback: if there is somehow no history to pop (opened via a
    // fresh URL / new tab), fall through to the configured
    // returnTo — that path DOES push, but it's a first-entry
    // scenario so there's nothing to double-up.
    if (window.history.length > 1) {
      window.history.back();
      return;
    }
    if (this._returnTo) {
      this.navigation.goTo(this._returnTo, this._returnToParams || {});
    }
  }

  async _load() {
    const body = this.element.querySelector('#person-body');
    const loading = this.element.querySelector('#person-loading');
    const errBox = this.element.querySelector('#person-error');
    body.style.display = 'none';
    errBox.style.display = 'none';
    loading.style.display = 'block';

    try {
      const url = this.leagueAppsUserId
        ? `/api/persons/la/${encodeURIComponent(this.leagueAppsUserId)}`
        : `/api/persons/${encodeURIComponent(this.personId)}`;
      const res = await this.auth.fetch(url);
      if (!res.ok) {
        const txt = await res.text().catch(() => '');
        throw new Error(`HTTP ${res.status}${txt ? ' — ' + txt : ''}`);
      }
      const data = await res.json();
      // Keep both keys in sync so RSVP / LA deep-links work after a
      // personId-only entry.
      if (data.leagueAppsUserId != null && data.leagueAppsUserId !== '') {
        this.leagueAppsUserId = String(data.leagueAppsUserId);
      }
      if (data.personId != null) {
        this.personId = String(data.personId);
        this._personId = data.personId;
      }
      this._render(data);
      loading.style.display = 'none';
      body.style.display = 'block';
    } catch (e) {
      console.error('PersonScreen load failed:', e);
      this._showError(e.message || String(e));
    }
  }

  _showError(msg) {
    const errBox = this.element.querySelector('#person-error');
    const loading = this.element.querySelector('#person-loading');
    const body = this.element.querySelector('#person-body');
    body.style.display = 'none';
    loading.style.display = 'none';
    errBox.textContent = 'Failed to load: ' + msg;
    errBox.style.display = 'block';
  }

  // ── Rendering ────────────────────────────────────────────────────
  _render(data) {
    const p = data.person || {};
    const name = `${p.firstName || ''} ${p.lastName || ''}`.trim() || '(unnamed)';

    this._personId = data.personId || null;
    this._rsvpElig = new Set(
      (data.rsvpEligibility || []).map((e) => Number(e.teamId)).filter(Boolean)
    );

    // Update the header bar.
    this.element.querySelector('#person-title').textContent = name;
    const laPart = data.leagueAppsUserId
      ? `LA user ${data.leagueAppsUserId}`
      : 'No LA alias';
    this.element.querySelector('#person-subtitle').textContent =
      `${laPart} · FH person #${data.personId}${this._editMode ? ' · Edit' : ''}`;

    // Header card.
    this._renderHeaderCard(data);
    this._renderContactCard(data.contact || { emails: [], phones: [] });
    this._renderAccountCard(data.account || null);
    this._renderMembershipsCard(data.memberships || []);
    this._renderTeamsCard(data.teams || []);
    this._renderRsvpCard(data.rsvpEligibility || [], data.upcomingMatches || []);
    this._renderBillingCard(data.billing, data.chargeFlags || []);
    this._renderRecentRsvpsCard(data.recentRsvps || []);
    this._renderDataQualityCard(data.overrides || [], data.merges || []);
    this._loadScrapedCandidates(data.personId);
  }

  // Mens-selection + women/boys teams — keep in sync with
  // rsvp-eligibility.js / MensRosterController.cpp `kEligibilityTeams`.
  _rsvpTeams() {
    return [
      { id: 35,  short: 'APSL',   label: 'APSL',     color: '#2563eb', category: 'men' },
      { id: 120, short: 'Liga 1', label: 'Liga 1',   color: '#0891b2', category: 'men' },
      { id: 121, short: 'Liga 2', label: 'Liga 2',   color: '#14b8a6', category: 'men' },
      { id: 122, short: 'Adult',  label: 'Adult',    color: '#a78bfa', category: 'men' },
      { id: 908, short: 'Pract.', label: 'Practice', color: '#f59e0b', category: 'men' },
      { id: 909, short: 'Pickup', label: 'Pickup',   color: '#10b981', category: 'men' },
      { id: 901, short: 'Tri Co', label: 'Tri County Women', color: '#db2777', category: 'women' },
      { id: 918, short: 'Pract.', label: 'Women Practice', color: '#f59e0b', category: 'women' },
      { id: 919, short: 'Pickup', label: 'Women Pickup',   color: '#10b981', category: 'women' },
      { id: 916, short: 'U8',     label: 'Boys U8',  color: '#16a34a', category: 'boys' },
      { id: 917, short: 'U12',    label: 'Boys U12', color: '#7c3aed', category: 'boys' },
      { id: 911, short: 'U16',    label: 'Boys U16', color: '#2563eb', category: 'boys' },
      { id: 920, short: 'Pract.', label: 'Boys Practice', color: '#f59e0b', category: 'boys' },
      { id: 921, short: 'Pickup', label: 'Boys Pickup',   color: '#10b981', category: 'boys' },
      { id: 922, short: 'Pract.', label: 'Girls Practice', color: '#f59e0b', category: 'girls' },
      { id: 923, short: 'Pickup', label: 'Girls Pickup',   color: '#10b981', category: 'girls' },
    ];
  }

  // Matches Payments / MensRoster LA deep-link scheme.  Hardcoded site
  // id mirrors PaymentsScreen.laSiteId (41983) — UI-only value; backend
  // canonical is LEAGUEAPPS_SITE_ID in env.
  _laManagerUrl(uid) {
    return `https://manager.leagueapps.com/console/sites/41983/memberDetails?memberId=${uid}`;
  }

  _renderHeaderCard(data) {
    const p = data.person || {};
    const fullName = `${p.firstName || ''} ${p.lastName || ''}`.trim() || '(unnamed)';
    const laUid = data.leagueAppsUserId || this.leagueAppsUserId;

    const pills = [];
    if (p.fhMemberAt) {
      pills.push(`<span class="ps-pill member">FH member</span>`);
    }
    if (p.leagueAppsPaymentStatus) {
      pills.push(`<span class="ps-pill">LA: ${this._escape(p.leagueAppsPaymentStatus)}</span>`);
    }
    // Summary pills for the current membership variants (active vs paused).
    (data.memberships || []).forEach(m => {
      if (m.endedAt) return;
      const cls = m.variant === 'paused' ? 'paused' : 'member';
      const label = `${m.category || '?'} ${m.variant || '?'}`;
      pills.push(`<span class="ps-pill ${cls}">${this._escape(label)}</span>`);
    });
    if ((data.chargeFlags || []).some(f => f.status === 'pending')) {
      pills.push(`<span class="ps-pill flag">Charge flagged</span>`);
    }

    const rows = [
      ['Birth date', this._fmtDate(p.birthDate)],
      ['FH member since', this._fmtDateTime(p.fhMemberAt)],
      ['Parent person id',
        p.parentPersonId != null
          ? String(p.parentPersonId)
          : '<span class="muted">—</span>'],
      ['Created', this._fmtDateTime(p.createdAt)],
      ['Updated', this._fmtDateTime(p.updatedAt)],
    ];

    const laLink = laUid
      ? `<div style="margin-top: var(--space-3);">
           <a class="btn btn-secondary btn-sm" target="_blank" rel="noopener"
              href="${this._escape(this._laManagerUrl(laUid))}"
              title="Open this member in LeagueApps Manager">
             Open in LeagueApps →
           </a>
         </div>`
      : '';

    const html = `
      <p class="ps-name">${this._escape(fullName)}</p>
      <div class="ps-meta">${pills.join('') || '<span class="ps-row-value muted">No status</span>'}</div>
      ${laLink}
      <div style="margin-top: var(--space-3);">
        ${rows.map(([k, v]) => `
          <div class="ps-row">
            <span class="ps-row-label">${this._escape(k)}</span>
            <span class="ps-row-value">${v}</span>
          </div>`).join('')}
      </div>
    `;
    this.element.querySelector('#ps-header-card').innerHTML = html;
  }

  _renderContactCard(contact) {
    const emails = contact.emails || [];
    const phones = contact.phones || [];

    const emailsHtml = emails.length === 0
      ? `<div class="ps-empty">No emails on file</div>`
      : `<div>${emails.map(e => `
          <div class="ps-row">
            <span class="ps-row-label">
              ${e.isPrimary ? '<strong>primary</strong> · ' : ''}
              ${e.isVerified ? 'verified' : 'unverified'}
            </span>
            <span class="ps-row-value">
              <a href="mailto:${encodeURIComponent(e.email)}">${this._escape(e.email)}</a>
            </span>
          </div>`).join('')}</div>`;

    const phonesHtml = phones.length === 0
      ? `<div class="ps-empty">No phones on file</div>`
      : `<div>${phones.map(ph => `
          <div class="ps-row">
            <span class="ps-row-label">
              ${ph.isPrimary ? '<strong>primary</strong> · ' : ''}
              ${ph.canReceiveSms ? 'sms ok' : 'no sms'}
            </span>
            <span class="ps-row-value">
              <a href="tel:${encodeURIComponent(ph.phone)}">${this._escape(ph.phone)}</a>
            </span>
          </div>`).join('')}</div>`;

    this.element.querySelector('#ps-emails-wrap').innerHTML = emailsHtml;
    this.element.querySelector('#ps-phones-wrap').innerHTML = phonesHtml;
  }

  _renderAccountCard(account) {
    const el = this.element.querySelector('#ps-account-body');
    if (!el) return;
    if (!account) {
      el.innerHTML = `<div class="ps-empty">No Football Home login account linked</div>`;
      return;
    }
    const active = account.isActive !== false;
    el.innerHTML = `
      <div class="ps-row">
        <span class="ps-row-label">User id</span>
        <span class="ps-row-value">#${this._escape(String(account.userId))}</span>
      </div>
      <div class="ps-row">
        <span class="ps-row-label">Status</span>
        <span class="ps-row-value">
          <span class="ps-pill ${active ? 'member' : 'dropped'}">
            ${active ? 'active' : 'inactive'}
          </span>
        </span>
      </div>
      <div class="ps-row">
        <span class="ps-row-label">Last seen</span>
        <span class="ps-row-value">${this._fmtDateTime(account.lastSeenAt)}</span>
      </div>
      <div class="ps-row">
        <span class="ps-row-label">Last login</span>
        <span class="ps-row-value">${this._fmtDateTime(account.lastLoginAt)}</span>
      </div>
      <div class="ps-row">
        <span class="ps-row-label">Account created</span>
        <span class="ps-row-value">${this._fmtDateTime(account.createdAt)}</span>
      </div>
    `;
  }

  _renderMembershipsCard(memberships) {
    const list = this.element.querySelector('#ps-memberships-list');
    if (!memberships.length) {
      list.innerHTML = `<div class="ps-empty">Not a member of any LA program</div>`;
      return;
    }
    // Order: open rows first (already sorted server-side), then ended.
    list.innerHTML = memberships.map(m => {
      const closed = !!m.endedAt;
      const cls = closed ? 'dropped' : (m.variant === 'paused' ? 'paused' : 'member');
      const label = `${m.category || '?'} ${m.variant || '?'}`;
      return `
        <div class="ps-row">
          <span class="ps-row-label">
            <span class="ps-pill ${cls}">${this._escape(label)}</span>
            ${closed
              ? `<span style="margin-left:8px; opacity:0.6;">ended ${this._fmtDate(m.endedAt)}</span>`
              : `<span style="margin-left:8px; opacity:0.6;">joined ${this._fmtDate(m.joinedAt)}</span>`}
          </span>
          <span class="ps-row-value ${closed ? 'muted' : ''}">
            ${this._escape(m.programName || '')}
            <span style="opacity:0.5; font-size:0.8em; margin-left:6px;">#${m.programId}</span>
          </span>
        </div>`;
    }).join('');
  }

  _renderBillingCard(billing, chargeFlags) {
    const summaryEl = this.element.querySelector('#ps-billing-summary');
    const flagsWrap = this.element.querySelector('#ps-flags-wrap');

    if (!billing) {
      summaryEl.innerHTML = `<div class="ps-empty">No upcoming bill</div>`;
    } else {
      const amt = billing.nextBillAmount != null
        ? `$${Number(billing.nextBillAmount).toFixed(2)}`
        : '—';
      summaryEl.innerHTML = `
        <div class="ps-row">
          <span class="ps-row-label">Next bill</span>
          <span class="ps-row-value">${this._fmtDate(billing.nextBillDate)} · ${amt}</span>
        </div>
        <div class="ps-row">
          <span class="ps-row-label">Updated</span>
          <span class="ps-row-value">${this._fmtDateTime(billing.updatedAt)}</span>
        </div>
      `;
    }

    if (!chargeFlags.length) {
      flagsWrap.innerHTML = `<div class="ps-empty">No charge flags</div>`;
      return;
    }
    flagsWrap.innerHTML = `
      <h3 style="margin: var(--space-3) 0 var(--space-2); font-size:0.85rem;
                 opacity:0.7; text-transform:uppercase; letter-spacing:0.05em;">
        Charge flags
      </h3>
      ${chargeFlags.map(f => {
        const amount = `$${(f.amountCents / 100).toFixed(2)}`;
        const statusCls = f.status === 'pending' ? 'flag'
                         : f.status === 'ran'    ? 'member'
                         : 'dropped';
        return `
          <div class="ps-row">
            <span class="ps-row-label">
              <span class="ps-pill ${statusCls}">${this._escape(f.status)}</span>
              <span style="margin-left:8px; opacity:0.7;">
                ${this._fmtDate(f.createdAt)}
              </span>
            </span>
            <span class="ps-row-value">
              ${amount}
              ${f.reason ? ` · <span style="opacity:0.7;">${this._escape(f.reason)}</span>` : ''}
            </span>
          </div>`;
      }).join('')}
    `;
  }

  // ── Team assignments ──────────────────────────────────────────────
  _renderTeamsCard(teams) {
    const list  = this.element.querySelector('#ps-teams-list');
    const count = this.element.querySelector('#ps-teams-count');
    const active = teams.filter(t => !t.leftAt);
    count.textContent = active.length
      ? `${active.length} current${teams.length > active.length
                                  ? ` · ${teams.length - active.length} past`
                                  : ''}`
      : (teams.length ? `${teams.length} past` : '');

    if (!teams.length) {
      list.innerHTML = `<div class="ps-empty">Not on any team roster</div>`;
      return;
    }
    list.innerHTML = teams.map(t => {
      const past = !!t.leftAt;
      const bits = [];
      if (t.clubName)     bits.push(this._escape(t.clubName));
      if (t.divisionName) bits.push(this._escape(t.divisionName));
      const context = bits.length ? ` · ${bits.join(' · ')}` : '';
      const jersey = t.jerseyNumber
        ? `<span class="ps-jersey">#${this._escape(String(t.jerseyNumber))}</span>`
        : '';
      const source = t.source === 'assignment'
        ? ' · LA roster'
        : (t.source === 'legacy' ? ' · legacy roster' : '');
      const dateBit = past
        ? `left ${this._fmtDate(t.leftAt)}`
        : `since ${this._fmtDate(t.joinedAt)}`;
      return `
        <div class="ps-line ${past ? 'past' : ''}">
          <span class="ps-line-primary">
            ${jersey}${this._escape(t.teamName)}
            <span style="opacity:0.6; font-weight:400;">${context}${source}</span>
          </span>
          <span class="ps-line-meta">${dateBit}</span>
        </div>`;
    }).join('');
  }

  // ── RSVP eligibility + upcoming matches ───────────────────────────
  _renderRsvpCard(eligibility, upcoming) {
    const teamsEl    = this.element.querySelector('#ps-rsvp-teams');
    const upEl       = this.element.querySelector('#ps-upcoming-list');
    const cntEl      = this.element.querySelector('#ps-rsvp-count');
    const upCntEl    = this.element.querySelector('#ps-upcoming-count');

    const granted = this._rsvpElig || new Set(
      (eligibility || []).map((e) => Number(e.teamId)).filter(Boolean)
    );
    cntEl.textContent   = granted.size ? String(granted.size) : '';
    upCntEl.textContent = upcoming.length    ? String(upcoming.length)    : '';

    // Inline set-replace toggles — same PUT as the RSVP Eligibility board
    // and mens roster modal, so Club Admin can fix grants without leaving
    // the person profile.
    const byCat = {};
    for (const t of this._rsvpTeams()) {
      (byCat[t.category] || (byCat[t.category] = [])).push(t);
    }
    const catOrder = ['men', 'women', 'boys', 'girls'];
    const catLabel = { men: 'Men', women: 'Women', boys: 'Boys', girls: 'Girls' };
    teamsEl.innerHTML = `
      ${catOrder.map((cat) => {
        const teams = byCat[cat] || [];
        if (!teams.length) return '';
        return `
          <div style="margin-bottom: var(--space-2);">
            <div style="font-size:0.7rem; font-weight:700; opacity:0.65;
                        letter-spacing:0.04em; text-transform:uppercase; margin-bottom:4px;">
              ${catLabel[cat] || cat}
            </div>
            <div style="display:flex; flex-wrap:wrap; gap:6px;">
              ${teams.map((t) => {
                const on = granted.has(t.id);
                return `<button type="button"
                          data-rsvp-team-id="${t.id}"
                          data-elig-on="${on ? '1' : '0'}"
                          title="${this._escape(t.label)}"
                          style="padding:4px 10px; border-radius:999px; font-size:0.75rem;
                                 font-weight:700; cursor:pointer;
                                 border:1px solid ${t.color};
                                 background:${on ? t.color : 'transparent'};
                                 color:${on ? '#fff' : t.color};">
                          ${this._escape(t.short)}
                        </button>`;
              }).join('')}
            </div>
          </div>`;
      }).join('')}
      <div style="font-size:0.75rem; opacity:0.65; margin-bottom: var(--space-2);">
        Tap a team to grant or revoke RSVP eligibility for this person.
      </div>
    `;

    if (!upcoming.length) {
      upEl.innerHTML = `<div class="ps-empty">
        No upcoming matches for these teams
      </div>`;
      return;
    }
    upEl.innerHTML = upcoming.map(m => {
      const label = m.homeTeamName && m.awayTeamName
        ? `${this._escape(m.homeTeamName)} vs ${this._escape(m.awayTeamName)}`
        : this._escape(m.title || `Match #${m.id}`);
      const venue = m.venueName ? ` · ${this._escape(m.venueName)}` : '';
      const timeBit = m.matchTime ? ` ${this._fmtTime(m.matchTime)}` : '';
      return `
        <div class="ps-line">
          <span class="ps-line-primary">${label}</span>
          <span class="ps-line-meta">
            ${this._fmtDate(m.matchDate)}${timeBit}${venue}
          </span>
        </div>`;
    }).join('');
  }

  async _toggleRsvp(teamId, want, chipEl) {
    if (!this.leagueAppsUserId || !teamId) return;
    const set = this._rsvpElig || new Set();
    const had = set.has(teamId);
    if (want) set.add(teamId); else set.delete(teamId);
    this._rsvpElig = set;
    this._paintRsvpChip(chipEl, teamId, want);

    try {
      const r = await this.auth.fetch('/api/mens-roster/rsvp-eligibility', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          leagueAppsUserId: Number(this.leagueAppsUserId),
          teamIds: Array.from(set),
        }),
      });
      if (!r.ok) throw new Error(`HTTP ${r.status}`);
      const cntEl = this.element.querySelector('#ps-rsvp-count');
      if (cntEl) cntEl.textContent = set.size ? String(set.size) : '';
    } catch (err) {
      if (had) set.add(teamId); else set.delete(teamId);
      this._rsvpElig = set;
      this._paintRsvpChip(chipEl, teamId, had);
      alert(`Failed to save RSVP eligibility: ${err.message || err}`);
    }
  }

  _paintRsvpChip(chipEl, teamId, on) {
    if (!chipEl) return;
    const team = this._rsvpTeams().find((t) => t.id === teamId);
    if (!team) return;
    chipEl.setAttribute('data-elig-on', on ? '1' : '0');
    chipEl.style.background = on ? team.color : 'transparent';
    chipEl.style.color = on ? '#fff' : team.color;
  }

  // ── Recent RSVP responses ─────────────────────────────────────────
  _renderRecentRsvpsCard(rows) {
    const list  = this.element.querySelector('#ps-recent-rsvps-list');
    const count = this.element.querySelector('#ps-recent-rsvps-count');
    count.textContent = rows.length ? String(rows.length) : '';
    if (!rows.length) {
      list.innerHTML = `<div class="ps-empty">No RSVP history</div>`;
      return;
    }
    list.innerHTML = rows.map(r => {
      const label = r.homeTeamName && r.awayTeamName
        ? `${this._escape(r.homeTeamName)} vs ${this._escape(r.awayTeamName)}`
        : this._escape(r.title || `Match #${r.eventId}`);
      const status = r.status ? this._escape(r.status) : '—';
      return `
        <div class="ps-line">
          <span class="ps-line-primary">
            <span class="ps-pill">${status}</span>
            <span style="margin-left:8px;">${label}</span>
          </span>
          <span class="ps-line-meta">
            ${this._fmtDate(r.matchDate)}
            <span style="opacity:0.5; margin-left:6px;">
              (${this._fmtDate(r.changedAt)})
            </span>
          </span>
        </div>`;
    }).join('');
  }

  // ── Drill-down navigation helpers ─────────────────────────────────
  _openRsvpAdmin() {
    this.navigation.goTo('rsvp-eligibility', {
      focusLaUserId: this.leagueAppsUserId,
      returnTo: 'person',
      returnToParams: {
        leagueAppsUserId: this.leagueAppsUserId,
        returnTo: this._returnTo,
        returnToParams: this._returnToParams,
      },
    });
  }

  _openPayments() {
    this.navigation.goTo('payments', {
      focusLaUserId: this.leagueAppsUserId,
      initialView: 'members',
      returnTo: 'person',
      returnToParams: {
        leagueAppsUserId: this.leagueAppsUserId,
        returnTo: this._returnTo,
        returnToParams: this._returnToParams,
      },
    });
  }

  _renderDataQualityCard(overrides, merges) {
    const ovWrap = this.element.querySelector('#ps-overrides-wrap');
    const mgWrap = this.element.querySelector('#ps-merges-wrap');

    if (!overrides.length) {
      ovWrap.innerHTML = `<div class="ps-empty">No field overrides</div>`;
    } else {
      ovWrap.innerHTML = `
        <h3 style="margin: 0 0 var(--space-2); font-size:0.85rem;
                   opacity:0.7; text-transform:uppercase; letter-spacing:0.05em;">
          Field overrides
        </h3>
        ${overrides.map(o => `
          <div class="ps-row">
            <span class="ps-row-label">${this._escape(o.fieldName)}</span>
            <span class="ps-row-value">
              ${o.value != null ? this._escape(o.value) : '<span class="muted">(cleared)</span>'}
              ${o.originalValue
                ? `<span style="opacity:0.5;"> ← was ${this._escape(o.originalValue)}</span>`
                : ''}
            </span>
          </div>`).join('')}
      `;
    }

    if (!merges.length) {
      mgWrap.innerHTML = `<div class="ps-empty">No merge history</div>`;
    } else {
      mgWrap.innerHTML = `
        <h3 style="margin: var(--space-3) 0 var(--space-2); font-size:0.85rem;
                   opacity:0.7; text-transform:uppercase; letter-spacing:0.05em;">
          Merge history
        </h3>
        ${merges.map(m => `
          <div class="ps-row" style="align-items:center;">
            <span class="ps-row-label">
              ${m.reversedAt ? 'reversed' : 'merged'}
              ${m.reversedAt
                ? ` ${this._fmtDate(m.reversedAt)}`
                : ` ${this._fmtDate(m.mergedAt)}`}
            </span>
            <span class="ps-row-value" style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
              #${m.droppedPersonId} → #${m.keptPersonId}
              ${!m.reversedAt ? `
                <button type="button" class="btn btn-secondary"
                        data-unmerge-id="${m.id}"
                        style="padding:2px 8px; font-size:0.7rem; font-weight:700;">
                  Unmerge
                </button>` : ''}
            </span>
          </div>`).join('')}
      `;
    }
  }

  async _unmerge(mergeId, btn) {
    if (!mergeId) return;
    const ok = window.confirm(
      `Reverse merge #${mergeId}?\n\nThe dropped person row and snapshotted child data will be restored.`
    );
    if (!ok) return;
    const prev = btn ? btn.textContent : '';
    if (btn) {
      btn.disabled = true;
      btn.textContent = '…';
    }
    try {
      const res = await this.auth.fetch(`/api/persons/unmerge/${mergeId}`, {
        method: 'POST',
      });
      if (!res.ok) {
        const t = await res.text();
        throw new Error(t || `HTTP ${res.status}`);
      }
      await this._load();
    } catch (err) {
      alert(`Unmerge failed: ${err.message || err}`);
      if (btn) {
        btn.disabled = false;
        btn.textContent = prev;
      }
    }
  }

  async _loadScrapedCandidates(personId) {
    const list = this.element.querySelector('#ps-scraped-list');
    const count = this.element.querySelector('#ps-scraped-count');
    if (!list || !personId) return;
    list.innerHTML = `<div class="ps-empty">Looking for scraped matches…</div>`;
    try {
      const res = await this.auth.fetch(
        `/api/persons/${personId}/scraped-match-candidates`
      );
      if (!res.ok) {
        const t = await res.text();
        throw new Error(t || `HTTP ${res.status}`);
      }
      const data = await res.json();
      const candidates = Array.isArray(data.candidates) ? data.candidates : [];
      if (count) count.textContent = candidates.length ? String(candidates.length) : '';
      if (!candidates.length) {
        list.innerHTML = `<div class="ps-empty">No scraped name matches</div>`;
        return;
      }
      list.innerHTML = candidates.map((c) => {
        const name = `${c.firstName || ''} ${c.lastName || ''}`.trim() || `Person #${c.personId}`;
        const teams = c.teamNames || 'no current roster';
        const clubs = c.clubNames ? ` · ${c.clubNames}` : '';
        const dobBit = c.dob
          ? `${c.dobMatch ? 'DOB match' : 'DOB'} ${c.dob}`
          : 'no DOB';
        return `
          <div class="ps-row" style="align-items:center; flex-wrap:wrap; gap:8px;">
            <span class="ps-row-label" style="flex:1; min-width:160px;">
              <strong>${this._escape(name)}</strong>
              <span style="opacity:0.55;"> #${c.personId}</span>
              <div style="font-size:0.8rem; opacity:0.75; margin-top:2px;">
                ${this._escape(teams)}${this._escape(clubs)}
              </div>
              <div style="font-size:0.75rem; opacity:0.6;">${this._escape(dobBit)}</div>
            </span>
            <button type="button" class="btn btn-secondary"
                    data-link-scraped="${c.personId}"
                    style="padding:4px 10px; font-size:0.75rem; font-weight:700;">
              Link to this person
            </button>
          </div>`;
      }).join('');
    } catch (err) {
      list.innerHTML = `<div class="ps-empty">Could not load scraped matches: ${this._escape(err.message || String(err))}</div>`;
    }
  }

  async _linkScraped(scrapedPersonId, btn) {
    if (!this._personId || !scrapedPersonId) return;
    const ok = window.confirm(
      `Link scraped person #${scrapedPersonId} onto Lighthouse person #${this._personId}?\n\n` +
      `Their player/roster rows move onto this person. Reversible via Unmerge.`
    );
    if (!ok) return;
    const prev = btn ? btn.textContent : '';
    if (btn) {
      btn.disabled = true;
      btn.textContent = 'Linking…';
    }
    try {
      const res = await this.auth.fetch('/api/persons/link-scraped', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          keepPersonId: this._personId,
          scrapedPersonId,
        }),
      });
      if (!res.ok) {
        const t = await res.text();
        throw new Error(t || `HTTP ${res.status}`);
      }
      await this._load();
    } catch (err) {
      alert(`Link failed: ${err.message || err}`);
      if (btn) {
        btn.disabled = false;
        btn.textContent = prev;
      }
    }
  }

  // ── Formatting helpers ─────────────────────────────────────────────
  _fmtDate(iso) {
    if (!iso) return '<span class="ps-row-value muted">—</span>';
    try {
      const d = new Date(iso);
      if (isNaN(d.getTime())) return this._escape(String(iso));
      return d.toLocaleDateString(undefined, {
        year: 'numeric', month: 'short', day: 'numeric',
      });
    } catch (_) { return this._escape(String(iso)); }
  }

  _fmtDateTime(iso) {
    if (!iso) return '<span class="ps-row-value muted">—</span>';
    try {
      const d = new Date(iso);
      if (isNaN(d.getTime())) return this._escape(String(iso));
      return d.toLocaleString(undefined, {
        year: 'numeric', month: 'short', day: 'numeric',
        hour: '2-digit', minute: '2-digit',
      });
    } catch (_) { return this._escape(String(iso)); }
  }

  // Matches `matches.match_time` (TIME WITHOUT TIME ZONE, "HH:MM:SS"
  // string).  Format as e.g. "6:30 PM"; return raw string on parse
  // failure so we never render a broken cell.
  _fmtTime(t) {
    if (!t) return '';
    const s = String(t);
    const m = s.match(/^(\d{1,2}):(\d{2})/);
    if (!m) return this._escape(s);
    const hh = parseInt(m[1], 10);
    const mm = m[2];
    const period = hh >= 12 ? 'PM' : 'AM';
    const disp = ((hh + 11) % 12) + 1;
    return `${disp}:${mm} ${period}`;
  }

  _escape(s) {
    if (s == null) return '';
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }
}
