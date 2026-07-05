// YouthRosterScreen — Live Boys/Girls Club roster pulled from
// LeagueApps on every page load.  Bucketed by the US Soccer **school-year**
// age groups (Aug 1 → Jul 31), effective with the 2026-27 season, with
// mailto: / sms: / tel: actions per card so a coach can reach a player's
// parent with one tap.
//
// Data source: GET /api/youth-roster (served by the C++ backend's
// YouthRosterController, which calls the LeagueApps Public Data API
// live).  No DB cache — the dashboard always reflects what's currently
// in LA.
//
// Buckets (Fall 2026 / Spring 2027, season-end-year=2027, served by the backend):
//   In-House                          — U6 and below (co-ed)
//   U8                                — U7 + U8       (co-ed)
//   U10                               — U9 + U10      (co-ed)
//   U12                               — U11 + U12     (co-ed)
//   Philadelphia League — Boys/Girls — U13+          (split by club)
class YouthRosterScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>⚽ Youth Roster</h1>
        <p class="subtitle">Live from LeagueApps — Boys Club + Girls Club</p>
      </div>

      <div style="padding: var(--space-4);">
        <div id="yr-banner" style="margin-bottom: var(--space-3); padding: var(--space-3); border-radius: 6px; background: #f1f5f9; border: 1px solid #e2e8f0; display:flex; align-items:center; gap: var(--space-3); flex-wrap: wrap; font-size: 14px;">
          <span id="yr-banner-icon" style="font-size: 16px;">⏳</span>
          <span id="yr-banner-text" style="flex:1; min-width: 200px;">Pulling latest registrations from LeagueApps…</span>
          <button id="yr-refresh" class="btn btn-secondary" style="display:none; padding: 4px 10px; font-size: 13px;">🔄 Refresh</button>
        </div>
        <div id="yr-loading" style="text-align:center; padding: var(--space-6); opacity:0.6;">Loading…</div>
        <div id="yr-error"   style="display:none; color: var(--color-error); padding: var(--space-4); text-align:center;"></div>
        <div id="yr-empty"   style="display:none; text-align:center; padding: var(--space-6); opacity:0.6;">No registrations yet.</div>
        <div id="yr-list"    style="display:none;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId   = params?.clubId;
    this.clubName = params?.clubName;

    this.element.addEventListener('click', e => {
      if (e.target.closest('.back-btn')) this.navigation.goBack();
      if (e.target.closest('#yr-refresh')) this.load();
    });

    // Billing badge click handling (edit + mark-billed) re-renders via load().
    if (window.BillingBadge) {
      window.BillingBadge.wire(this.element, this.auth.fetch.bind(this.auth), () => this.load());
    }

    this.load();
  }

  setBanner({ icon, text, showRefresh = false }) {
    const i = this.find('#yr-banner-icon');
    const t = this.find('#yr-banner-text');
    const r = this.find('#yr-refresh');
    if (i) i.textContent = icon;
    if (t) t.textContent = text;
    if (r) r.style.display = showRefresh ? '' : 'none';
  }

  async load() {
    const loading = this.find('#yr-loading');
    const errEl   = this.find('#yr-error');
    const empty   = this.find('#yr-empty');
    const list    = this.find('#yr-list');
    if (loading) loading.style.display = '';
    if (errEl)   errEl.style.display   = 'none';
    if (empty)   empty.style.display   = 'none';
    if (list)    list.style.display    = 'none';
    this.setBanner({ icon: '⏳', text: 'Pulling latest registrations from LeagueApps…' });

    try {
      const t0  = performance.now();
      const res = await this.auth.fetch('/api/youth-roster');
      if (!res.ok) {
        const body = await res.text();
        throw new Error(body.slice(0, 200) || `HTTP ${res.status}`);
      }
      const data = await res.json();
      const elapsed = ((performance.now() - t0) / 1000).toFixed(1);

      this._data = data;

      if (loading) loading.style.display = 'none';

      if (!data.total) {
        if (empty) empty.style.display = '';
        this.setBanner({
          icon: '⚠',
          text: `No active registrations found (season ending ${data.seasonEndYear}).`,
          showRefresh: true,
        });
        return;
      }

      if (list) list.style.display = '';
      this.setBanner({
        icon: '✓',
        text: `${data.total} player${data.total === 1 ? '' : 's'} loaded in ${elapsed}s · season ending ${data.seasonEndYear}`,
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

  // ── Bucket metadata is now DB-driven (see youth_age_groups table) ──
  // The API returns `bucketDefs` carrying color, maxRoster, and the active
  // birth-date window per bucket; we just key off label.

  bucketMeta(label) {
    const def = (this._data?.bucketDefs || []).find(b => b.label === label);
    return def || { color: '#475569', maxRoster: null, minBirthDate: null, maxBirthDate: null };
  }

  renderRoster(data) {
    const container = this.find('#yr-list');
    const order     = data.bucketOrder || Object.keys(data.buckets);

    // Visible buckets: always show the travel teams (anything with a roster
    // cap) so empty slots are obvious for recruiting.  Hide unlimited rec/league
    // buckets only when they have no one.
    const visible = order.filter(b => {
      const meta = this.bucketMeta(b);
      const hasPlayers = (data.buckets[b] || []).length > 0;
      const hasCap     = meta.maxRoster != null;
      return hasPlayers || hasCap;
    });

    container.innerHTML = `
      <div style="display:flex; align-items:center; gap:var(--space-3); flex-wrap:wrap; margin-bottom:var(--space-3); padding:var(--space-2) var(--space-3); background:var(--bg-secondary); border-radius:var(--radius-md);">
        <span style="opacity:0.7; font-size:0.8rem; font-weight:600;">Buckets:</span>
        ${visible.map(b => {
          const meta = this.bucketMeta(b);
          const n    = data.buckets[b].length;
          const cap  = meta.maxRoster != null ? `(${n}/${meta.maxRoster})` : `(${n})`;
          return `
            <span style="display:inline-flex; align-items:center; gap:6px; font-size:0.8rem; padding:2px 8px; border-radius:4px; border-left:3px solid ${meta.color};">
              ${b} <span style="opacity:0.55;">${cap}</span>
            </span>`;
        }).join('')}
      </div>

      <div style="overflow-x:auto; padding-bottom:var(--space-2);">
        <div style="display:grid; grid-template-columns: repeat(${visible.length}, minmax(280px, 1fr)); gap:var(--space-3); align-items:start;">
          ${visible.map(b => this.renderBucket(b, data.buckets[b])).join('')}
        </div>
      </div>
    `;
  }

  renderBucket(label, players) {
    const meta  = this.bucketMeta(label);
    const color = meta.color;
    const max   = meta.maxRoster;
    const n     = players.length;

    let countHtml;
    if (max == null) {
      countHtml = `<span style="opacity:0.6; font-size:0.85rem;">${n}</span>`;
    } else {
      const pct      = max ? n / max : 0;
      const overFull = n >= max;
      const nearFull = !overFull && pct >= 0.85;
      const fillColor = overFull ? '#ef4444' : nearFull ? '#f59e0b' : '#10b981';
      countHtml = `
        <span style="font-size:0.85rem; font-weight:600; color:${fillColor};">
          ${n}/${max}${overFull ? ' ⚠' : ''}
        </span>`;
    }

    const window = (meta.minBirthDate && meta.maxBirthDate)
      ? `Born ${meta.minBirthDate} → ${meta.maxBirthDate === '9999-12-31' ? 'newer' : meta.maxBirthDate}`
      : '';

    const inner = players.map(p => this.renderPlayer(p)).join('');
    return `
      <div style="background:var(--bg-secondary); border-radius:var(--radius-lg); padding:var(--space-3); border-top:4px solid ${color};" title="${this.escape(window)}">
        <div style="display:flex; justify-content:space-between; align-items:baseline; margin-bottom:var(--space-2); gap:var(--space-2);">
          <strong style="font-size:1rem;">${label}</strong>
          ${countHtml}
        </div>
        <div style="display:flex; flex-direction:column; gap:var(--space-2);">
          ${inner || '<div style="opacity:0.5; font-size:0.85rem;">(empty)</div>'}
        </div>
      </div>
    `;
  }

  renderPlayer(p) {
    const btn = 'flex:1; padding:6px 8px; font-size:0.75rem; font-weight:600; border-radius:6px; border:none; cursor:pointer; text-align:center; text-decoration:none; display:inline-flex; align-items:center; justify-content:center; gap:4px;';

    const subject = `Lighthouse 1893 — about ${p.firstName || 'your player'}`;
    const greeting = p.parentFirstName ? `Hi ${p.parentFirstName},` : 'Hi,';
    const playerRef = p.firstName || 'your player';
    const emailBody = `${greeting}\n\nThis is your Lighthouse 1893 coach reaching out about ${playerRef}.\n\n`;
    const smsBody   = `Hi${p.parentFirstName ? ' ' + p.parentFirstName : ''}, this is Lighthouse 1893 coach about ${playerRef}.`;

    const emailHref = p.parentEmail
      ? `https://mail.google.com/mail/?${new URLSearchParams({
          view:     'cm',
          fs:       '1',
          authuser: 'soccer@lighthouse1893.org',
          to:       p.parentEmail,
          su:       subject,
          body:     emailBody,
        }).toString()}`
      : null;
    // sms: URI with both ?body= and &body= — iOS uses &, Android uses ?
    const smsHref = p.parentPhone
      ? `sms:${p.parentPhone}?&body=${encodeURIComponent(smsBody)}`
      : null;
    const telHref = p.parentPhone ? `tel:${p.parentPhone}` : null;

    const formattedPhone = this.formatPhone(p.parentPhone);

    const ageGroup = p.ageGroup ? `${p.ageGroup}` : (p.birthYear ? `b.${p.birthYear}` : '?');
    const birthYear = p.birthYear || '?';
    const genderIcon = p.gender === 'Female' ? '♀' : '♂';
    // DOB pretty: "Oct 19, 2019".  Falls back to the ISO string if parsing fails.
    let dobPretty = '';
    if (p.birthDate) {
      const d = new Date(`${p.birthDate}T00:00:00Z`);
      dobPretty = isNaN(d.getTime())
        ? p.birthDate
        : d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric', timeZone: 'UTC' });
    }

    const paymentBadge = p.paymentStatus
      ? `<span style="display:inline-block; font-size:0.7rem; padding:1px 6px; border-radius:8px; background:${p.paymentStatus === 'PAID' ? '#1e3a2e' : '#3a2e1e'}; color:${p.paymentStatus === 'PAID' ? '#34d399' : '#fbbf24'};">${p.paymentStatus}${p.outstandingBalance && p.outstandingBalance > 0 ? ` ($${p.outstandingBalance} due)` : ''}</span>`
      : '';

    const emailBtn = emailHref ? `
      <a href="${emailHref}" target="_blank" rel="noopener noreferrer"
         style="${btn} background:#3b82f6; color:#fff;">✉ Email</a>` : '';
    const smsBtn = smsHref ? `
      <a href="${smsHref}"
         style="${btn} background:#10b981; color:#fff;">💬 Text</a>` : '';
    const telBtn = telHref ? `
      <a href="${telHref}"
         style="${btn} background:#6366f1; color:#fff;">📞 Call</a>` : '';

    // 👤 Save (2026-07-05) — data-URL vCard so tapping opens the
    // native "Add Contact" sheet on iOS/Android (or downloads a .vcf
    // on desktop).  Contact is the PARENT (kids' billing / contact
    // goes to parents); ORG carries "Lighthouse 1893 — [kid's name]"
    // so the coach can find them later in their phone.
    const parentFirst = p.parentFirstName || (p.parentName ? String(p.parentName).split(' ')[0] : '');
    const parentLast  = p.parentLastName  || (p.parentName ? String(p.parentName).split(' ').slice(1).join(' ') : '');
    const parentFull  = p.parentName || `${parentFirst} ${parentLast}`.trim();
    const kidName     = p.fullName || p.firstName || 'youth player';
    const vcardHref = (p.parentPhone || p.parentEmail)
      ? this.buildVcardHref({
          fullName:  parentFull || parentFirst || 'Parent',
          firstName: parentFirst,
          lastName:  parentLast,
          phone:     p.parentPhone,
          email:     p.parentEmail,
          org:       `Lighthouse 1893 — ${kidName}`,
          note:      `Parent of ${kidName}${p.ageGroup ? ` (${p.ageGroup})` : ''}${p.club ? ` · ${p.club}` : ''}`,
        })
      : null;
    const vcardFilename = ((parentFull || parentFirst || 'parent').trim().replace(/\s+/g, '_') || 'contact') + '.vcf';
    const vcardBtn = vcardHref ? `
      <a href="${vcardHref}" download="${this.escape(vcardFilename)}"
         title="Save ${this.escape(parentFull || 'parent')} to your phone contacts"
         style="${btn} background:#0ea5e9; color:#fff;">👤 Save</a>` : '';

    // 💸 PAY (2026-07-05) — parent SMS with payment reminder + LeagueApps
    // dashboard link.  Mirrors the mens-roster PAY button but simpler:
    // youth payload doesn't carry daysOverdue yet, so we can't do the
    // three-tier (1-3 / 4-6 / 7+) messaging — one universal body,
    // triggered whenever LA reports an outstanding balance or a non-PAID
    // paymentStatus.  Message is addressed to the PARENT (parentPhone,
    // parentFirstName) since kids' billing goes to parents.
    const isOverdue = (p.outstandingBalance != null && p.outstandingBalance > 0)
      || (p.paymentStatus && p.paymentStatus !== 'PAID');
    let payBtn = '';
    if (isOverdue && p.parentPhone) {
      const amountNum = (p.outstandingBalance > 0)
        ? p.outstandingBalance
        : (p.nextBillAmount > 0 ? p.nextBillAmount : null);
      const amountStr = amountNum != null ? `$${amountNum}` : 'monthly dues';
      const payUrl    = 'https://lighthouse1893.leagueapps.com/dashboard';
      const kidRef    = p.firstName || 'your player';
      const parentRef = p.parentFirstName ? ` ${p.parentFirstName}` : '';
      const duesPurpose = `Dues cover ref fees, league & player registration, equipment, uniforms and more — without them the club can't function properly.`;
      const payBody = `Hi${parentRef}, heads up — our Lighthouse 1893 Financial Dept flagged ${kidRef}'s monthly dues (${amountStr}) as past due. Looks like the LeagueApps charge didn't go through. ${duesPurpose} LeagueApps has emailed you a pay link — please check your inbox if unsure. To avoid any disruption to ${kidRef}'s practice / game roster eligibility (and any late fees), log in and pay / update your card on file: ${payUrl}  Thanks!`;
      const payHref = `sms:${p.parentPhone}?&body=${encodeURIComponent(payBody)}`;
      payBtn = `
      <a href="${payHref}"
         title="Text ${this.escape(formattedPhone)} a payment reminder with LeagueApps link"
         style="${btn} background:#059669; color:#fff;">💸 Pay</a>`;
    }

    const billingBadge = window.BillingBadge ? window.BillingBadge.render(p) : '';

    return `
      <div style="background:var(--bg-tertiary, #1f2937); border-radius:var(--radius-md); padding:var(--space-2);">
        <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:var(--space-2);">
          <div style="min-width:0;">
            <div style="font-weight:600; font-size:0.95rem;">${this.escape(p.fullName) || '(no name)'}</div>
            <div style="font-size:0.75rem; opacity:0.7;">${genderIcon} ${ageGroup} · ${this.escape(p.club)}</div>
            ${dobPretty ? `<div style="font-size:0.75rem; opacity:0.7;">🎂 ${this.escape(dobPretty)}</div>` : ''}
          </div>
          ${paymentBadge}
        </div>
        ${p.parentName ? `<div style="font-size:0.8rem; opacity:0.85; margin-top:4px;">👪 ${this.escape(p.parentName)}</div>` : ''}
        ${p.parentEmail ? `<div style="font-size:0.8rem; opacity:0.85;">${this.escape(p.parentEmail)}</div>` : ''}
        ${formattedPhone ? `<div style="font-size:0.85rem; font-weight:500; opacity:0.95;">${formattedPhone}</div>` : ''}
        ${billingBadge ? `<div style="margin-top:6px;">${billingBadge}</div>` : ''}
        <div style="display:flex; gap:6px; margin-top:8px; flex-wrap:wrap;">${emailBtn}${smsBtn}${telBtn}${payBtn}${vcardBtn}</div>
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

  // ── helpers ──────────────────────────────────────────────────────────
  formatPhone(raw) {
    if (!raw) return '';
    const digits = String(raw).replace(/\D/g, '');
    // Strip US country code if present
    const ten = digits.length === 11 && digits.startsWith('1') ? digits.slice(1) : digits;
    if (ten.length === 10) {
      return `(${ten.slice(0, 3)}) ${ten.slice(3, 6)}-${ten.slice(6)}`;
    }
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
