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
//
// A `returnTo` hint lets the back button pop to the caller's screen.
// If absent we fall back to the browser's own history.
class PersonScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.navigation = navigation;
    this.auth = auth;
    this.leagueAppsUserId = null;
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

          <!-- LA memberships (current + past).  Past rows render greyed
               with an "ended" timestamp so an admin can tell whether
               someone was previously paused / dropped. -->
          <section class="ps-card" id="ps-memberships-card">
            <h2 class="ps-card-title">LeagueApps memberships</h2>
            <div id="ps-memberships-list"></div>
          </section>

          <!-- Upcoming bill (person_billing) + open/recent charge flags. -->
          <section class="ps-card" id="ps-billing-card">
            <h2 class="ps-card-title">Billing</h2>
            <div id="ps-billing-summary"></div>
            <div id="ps-flags-wrap" style="margin-top: var(--space-3);"></div>
          </section>

          <!-- Data-quality tier: field overrides + merge history. -->
          <section class="ps-card" id="ps-dq-card">
            <h2 class="ps-card-title">Data quality</h2>
            <div id="ps-overrides-wrap"></div>
            <div id="ps-merges-wrap" style="margin-top: var(--space-3);"></div>
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
      </style>
    `;
    this.element = div;

    div.querySelector('.back-btn').addEventListener('click', () => this._goBack());

    return div;
  }

  onEnter(params) {
    // Accept both { leagueAppsUserId } and { laUserId } for flexibility.
    const raw = params?.leagueAppsUserId ?? params?.laUserId ?? null;
    this.leagueAppsUserId = raw != null ? String(raw) : null;
    this._returnTo = params?.returnTo || null;
    this._returnToParams = params?.returnToParams || null;

    if (!this.leagueAppsUserId) {
      this._showError('No leagueAppsUserId provided');
      return;
    }
    this._load();
  }

  _goBack() {
    if (this._returnTo) {
      this.navigation.goTo(this._returnTo, this._returnToParams || {});
    } else {
      // Fall back to browser history so "back" behaves naturally when
      // the screen is opened from anywhere.
      window.history.back();
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
      const res = await this.auth.fetch(
        `/api/persons/la/${encodeURIComponent(this.leagueAppsUserId)}`);
      if (!res.ok) {
        const txt = await res.text().catch(() => '');
        throw new Error(`HTTP ${res.status}${txt ? ' — ' + txt : ''}`);
      }
      const data = await res.json();
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

    // Update the header bar.
    this.element.querySelector('#person-title').textContent = name;
    this.element.querySelector('#person-subtitle').textContent =
      `LA user ${data.leagueAppsUserId} · FH person #${data.personId}`;

    // Header card.
    this._renderHeaderCard(data);
    this._renderContactCard(data.contact || { emails: [], phones: [] });
    this._renderMembershipsCard(data.memberships || []);
    this._renderBillingCard(data.billing, data.chargeFlags || []);
    this._renderDataQualityCard(data.overrides || [], data.merges || []);
  }

  _renderHeaderCard(data) {
    const p = data.person || {};
    const fullName = `${p.firstName || ''} ${p.lastName || ''}`.trim() || '(unnamed)';

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

    const html = `
      <p class="ps-name">${this._escape(fullName)}</p>
      <div class="ps-meta">${pills.join('') || '<span class="ps-row-value muted">No status</span>'}</div>
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
          <div class="ps-row">
            <span class="ps-row-label">
              ${m.reversedAt ? 'reversed' : 'merged'}
              ${m.reversedAt
                ? ` ${this._fmtDate(m.reversedAt)}`
                : ` ${this._fmtDate(m.mergedAt)}`}
            </span>
            <span class="ps-row-value">
              #${m.droppedPersonId} → #${m.keptPersonId}
            </span>
          </div>`).join('')}
      `;
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
