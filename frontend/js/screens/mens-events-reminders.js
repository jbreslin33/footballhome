// MensEventsRemindersScreen — coach's "who hasn't RSVP'd yet?" board.
//
// Layout (v3, 2026-07-17 — post-gcal rip):
//   Horizontal-scrolling row of EVENT COLUMNS, ordered left-to-right
//   by time.  Next event is leftmost.  Only shows events in the next
//   7 days.  Each column contains three stacked sections:
//     ✅ Going       ❌ Can't go      ⚪ No response
//   Every roster-eligible player for that event lands in exactly one
//   section based on their fh_event_rsvps row (if any).
//
// Per-player row has FOUR contact buttons:
//   📧  plain mailto:  (generic body, links to https://footballhome.org/)
//   💬  plain sms:     (generic body, same URL)
//   🔗📧 magic-link mailto:  (POST /api/events/:fhEventId/remind{channel:email,
//                             person_ids:[id]} → open returned mailto_href)
//   🔗💬 magic-link sms:     (same but channel:sms → sms_href)
//
// Data source: GET /api/mens/week-availability?days=7
// Magic-link source: POST /api/events/:fhEventId/remind
//
// The magic-link buttons hit a rate-limit (one nudge per player per
// event per 5 min) — we surface any 429-like message inline on the
// clicked button and disable it briefly.
class MensEventsRemindersScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null;         // full /api/mens/week-availability payload
    this._colWidthPx = 320;   // per-event column width
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-mens-events-reminders';
    div.innerHTML = `
      <div class="screen-header" style="display:flex;align-items:center;gap:var(--space-3);padding:var(--space-3);">
        <button class="btn btn-secondary btn-sm back-btn">← Back</button>
        <h1 style="margin:0;font-size:1.5rem;">📢 Mens Reminders</h1>
        <span style="flex:1"></span>
        <span id="mer-range" style="font-size:0.85rem;color:var(--text-muted);"></span>
      </div>

      <div style="padding:0 var(--space-3) var(--space-2);max-width:1400px;margin:0 auto;">
        <p style="opacity:0.75;font-size:0.9rem;margin:0 0 var(--space-2);line-height:1.4;">
          Every mens event in the next 7 days, left-to-right in time order.  Each
          column shows every eligible player bucketed by their current RSVP.
          Tap a player's 📧 / 💬 buttons to open your Mail / Messages app with
          a reminder pre-filled — magic-link (🔗) variants one-tap-sign-in the
          player and drop them on the RSVP page.
        </p>
      </div>

      <div id="mer-loading" style="text-align:center;padding:var(--space-4);color:var(--text-muted);">
        Loading week…
      </div>

      <div id="mer-empty" style="display:none;text-align:center;padding:var(--space-4);color:var(--text-muted);">
        <div style="font-size:2rem;margin-bottom:8px;">📭</div>
        <div>No mens events scheduled in the next 7 days.</div>
      </div>

      <div id="mer-board-scroll" style="display:none;overflow-x:auto;padding:0 var(--space-3) var(--space-4);-webkit-overflow-scrolling:touch;">
        <div id="mer-board" style="display:flex;gap:12px;align-items:flex-start;min-height:200px;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const magicBtn = e.target.closest('.mer-magic-btn');
      if (magicBtn) {
        e.preventDefault();
        this.handleMagicClick(magicBtn);
      }
    });

    this.load();
  }

  async load() {
    try {
      const resp = await this.auth.fetch('/api/mens/week-availability?days=7', {
        headers: { 'Cache-Control': 'no-cache' }
      });
      if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
      const payload = await resp.json();
      this.data = payload;

      this.find('#mer-loading').style.display = 'none';

      const events = (this.data && this.data.events) || [];
      if (events.length === 0) {
        this.find('#mer-empty').style.display = 'block';
        this.find('#mer-range').textContent = '';
        return;
      }

      if (this.data.week_start && this.data.week_end) {
        this.find('#mer-range').textContent =
          `${this._fmtDate(this.data.week_start)} – ${this._fmtDate(this.data.week_end)}`;
      }

      this.find('#mer-board-scroll').style.display = 'block';
      this.renderBoard();
    } catch (err) {
      console.error('mens week-availability load failed:', err);
      this.find('#mer-loading').innerHTML =
        `<p style="color:#f87171;">❌ Failed to load: ${this._escape(String(err.message || err))}</p>`;
    }
  }

  renderBoard() {
    const board = this.find('#mer-board');
    board.innerHTML = this.data.events.map((ev) => this.renderColumn(ev)).join('');
  }

  renderColumn(ev) {
    const badge = this._typeBadge(ev.kind);
    const away = '';
    const venue = ev.venue_name
      ? `<div style="font-size:0.78rem;color:var(--text-muted);margin-top:2px;">📍 ${this._escape(ev.venue_name)}</div>`
      : '';

    // Pickup-only split (user directive 2026-07-07):
    // On pickup event columns (kind === 'pickup') we push players who
    // have NO active roster_assignments on APSL/Liga 1/Liga 2 into a
    // separate "PICKUP ONLY" section that renders at the bottom of the
    // column under its own banner.  Rationale: we don't want pickup-
    // only members cluttering the "who to nudge" view — we're only
    // reminding actual league members to RSVP — but the coach still
    // needs the option to nudge pickup-only guys, so they remain
    // visible with all contact buttons intact.
    //
    // For non-pickup events (games/practice) is_pickup_only players
    // shouldn't appear anyway because the eligibility rules filter to
    // teams 35/120/121; treating everyone as "regular" here is safe.
    const isPickupEvent = ev.kind === 'pickup';
    const allPlayers = ev.players || [];
    const regularPlayers    = isPickupEvent ? allPlayers.filter(p => !p.is_pickup_only) : allPlayers;
    const pickupOnlyPlayers = isPickupEvent ? allPlayers.filter(p =>  p.is_pickup_only) : [];

    // Bucket regular players by RSVP status.  Null = "no response".
    // ("maybe" was deprecated 2026-07-10; buckets/rendering removed.)
    const buckets = { yes: [], no: [], none: [] };
    regularPlayers.forEach((p) => {
      const key = p.rsvp_status === 'yes'   ? 'yes'
                : p.rsvp_status === 'no'    ? 'no'
                :                             'none';
      buckets[key].push(p);
    });

    // Section order per user directive: Going → Can't → No response.
    // "No response" is the highlighted one (that's the whole reason
    // the coach is on this screen), so it gets the loudest border.
    const sections = [
      { key: 'yes',   label: '✅ Going',       color: '#10b981', muted: true  },
      { key: 'no',    label: '❌ Can\'t go',   color: '#94a3b8', muted: true  },
      { key: 'none',  label: '⚪ No response', color: '#ef4444', muted: false },
    ];

    const totalMissing = buckets.none.length;
    const totalPlayers = regularPlayers.length;

    const sectionsHtml = sections.map((s) => this.renderSection(s, buckets[s.key], ev)).join('');

    // RSVP breakdown chips by home team (user directive 2026-07-07 —
    // "show where the rsvp came from so it shows on apsl game for
    // example that lets say 5 apsl guys, 3 liga 1 guys 6 liga 2 guys").
    // Groups the "yes" (Going) bucket by each player's home team using
    // the `home_team_short` field added to /api/mens/week-availability
    // in the same edit.  Order: APSL → L1 → L2 → Adult, hiding zeros.
    // Pickup-only responders (no home team) roll into a "Pickup" chip.
    const breakdownChips = (() => {
      const going = buckets.yes.concat(
        pickupOnlyPlayers.filter((p) => p.rsvp_status === 'yes')
      );
      if (going.length === 0) return '';
      const teamOrder = [
        { key: 'APSL',  label: 'APSL',  color: '#fbbf24' },  // gold
        { key: 'L1',    label: 'L1',    color: '#60a5fa' },  // blue
        { key: 'L2',    label: 'L2',    color: '#818cf8' },  // indigo
        { key: 'Adult', label: 'Adult', color: '#a78bfa' },  // violet
        { key: null,    label: 'Pickup',color: '#94a3b8' },  // gray (no home team)
      ];
      const counts = new Map();
      going.forEach((p) => {
        const k = p.home_team_short || null;
        counts.set(k, (counts.get(k) || 0) + 1);
      });
      const chips = teamOrder
        .filter((t) => (counts.get(t.key) || 0) > 0)
        .map((t) => `
          <span style="display:inline-flex;align-items:center;gap:3px;
                       background:${t.color}22;color:${t.color};
                       font-size:0.68rem;font-weight:700;
                       padding:2px 6px;border-radius:6px;
                       border:1px solid ${t.color}55;">
            ${t.label} <b style="font-weight:800;">${counts.get(t.key)}</b>
          </span>`).join('');
      if (!chips) return '';
      return `
        <div style="margin-top:6px;display:flex;flex-wrap:wrap;gap:4px;align-items:center;">
          <span style="font-size:0.68rem;color:var(--text-muted);margin-right:2px;">Going:</span>
          ${chips}
        </div>`;
    })();

    // "PICKUP ONLY" section (pickup events only; hidden if empty).
    // Sub-buckets so the coach can still see who has/hasn't RSVPed
    // among the pickup-only crowd — but visually de-emphasized so
    // the eye lands on the main sections first.
    let pickupOnlyHtml = '';
    if (pickupOnlyPlayers.length > 0) {
      const pBuckets = { yes: [], no: [], none: [] };
      pickupOnlyPlayers.forEach((p) => {
        const key = p.rsvp_status === 'yes'   ? 'yes'
                  : p.rsvp_status === 'no'    ? 'no'
                  :                             'none';
        pBuckets[key].push(p);
      });
      const pSectionsHtml = sections.map((s) => this.renderSection(
        { ...s, muted: true }, pBuckets[s.key], ev)).join('');
      pickupOnlyHtml = `
        <div style="margin-top:10px;border-top:1px dashed rgba(148,163,184,0.35);padding-top:8px;opacity:0.85;">
          <div style="font-size:0.72rem;font-weight:700;letter-spacing:0.06em;text-transform:uppercase;
                      color:#a78bfa;background:rgba(167,139,250,0.12);padding:4px 8px;border-radius:4px;
                      margin-bottom:6px;text-align:center;">
            ⚽ Pickup Only <span style="opacity:0.65;">(${pickupOnlyPlayers.length}) — optional nudge</span>
          </div>
          <div style="display:flex;flex-direction:column;gap:6px;">
            ${pSectionsHtml}
          </div>
        </div>
      `;
    }

    return `
      <div class="mer-column" style="flex:0 0 ${this._colWidthPx}px;background:var(--bg-secondary);
                                     border-radius:12px;border-top:4px solid ${this._typeColor(ev.kind)};
                                     overflow:hidden;display:flex;flex-direction:column;">
        <div style="padding:10px 12px;background:rgba(15,23,42,0.35);border-bottom:1px solid rgba(148,163,184,0.15);">
          <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;margin-bottom:4px;">
            ${badge}
            <span style="font-size:0.78rem;color:var(--text-muted);">${this._escape(ev.date_str || ev.match_date || '')}</span>
            ${ev.time_str ? `<span style="font-size:0.78rem;color:var(--text-muted);">· ${this._escape(ev.time_str)}</span>` : ''}
          </div>
          <div style="font-weight:700;font-size:0.98rem;line-height:1.25;">
            ${this._escape(ev.title || ev.type_label || 'Event')}${away}
          </div>
          ${venue}
          <div style="margin-top:6px;font-size:0.72rem;color:var(--text-muted);">
            <b style="color:${totalMissing > 0 ? '#fca5a5' : '#86efac'};">${totalMissing}</b>
            missing of ${totalPlayers}
          </div>
          ${breakdownChips}
        </div>
        <div style="padding:8px;display:flex;flex-direction:column;gap:8px;">
          ${sectionsHtml}
          ${pickupOnlyHtml}
        </div>
      </div>
    `;
  }

  renderSection(section, players, ev) {
    if (players.length === 0) return '';   // hide empty sections to save vertical space

    const rows = players.map((p) => this.renderPlayerRow(p, ev)).join('');

    return `
      <div style="border-left:3px solid ${section.color};padding-left:8px;opacity:${section.muted ? 0.85 : 1};">
        <div style="font-size:0.72rem;font-weight:700;letter-spacing:0.03em;color:${section.color};
                    margin-bottom:4px;text-transform:uppercase;">
          ${section.label} (${players.length})
        </div>
        <div style="display:flex;flex-direction:column;gap:6px;">
          ${rows}
        </div>
      </div>
    `;
  }

  renderPlayerRow(p, ev) {
    const name = `${this._escape(p.first_name || '')} ${this._escape(p.last_name || '')}`.trim() || 'Unknown';

    // Plain-URL RSVP link — always the calendar surface post-gcal rip
    // (2026-07-17).  Signed-in players land straight on their next-7
    // events; signed-out players get magic-link'd via /#calendar's
    // AuthScreen redirect flow.
    const rsvpUrl = `https://footballhome.org/#calendar`;

    // Plain body — no server round-trip; player has to sign in.
    // 2026-07-06 pm — spell out that RSVPing every event is mandatory
    // so coaches can plan (mirrors the same policy line in the magic-
    // link body served by EventReminderController::handleSendReminders
    // and the /#my week-schedule page).
    const eventWhen = [ev.date_str, ev.time_str].filter(Boolean).join(' ');
    const eventTitle = ev.title || ev.type_label || 'the next event';
    const bodyLines = [
      `Hi ${p.first_name || 'there'} — heads up, we don't have your RSVP yet for ${eventTitle}${eventWhen ? ' on ' + eventWhen : ''}${ev.venue_name ? ' at ' + ev.venue_name : ''}.`,
      '',
      `RSVPing to every event on your schedule is required — it's how we plan rosters, subs, and cancellations.`,
      '',
      `Not sure? Tap Not Going — you can always change it later if plans free up.`,
      '',
      `Tap here to RSVP: ${rsvpUrl}`,
      '',
      'Thanks — Lighthouse 1893',
    ];
    const plainBody = bodyLines.join('\n');
    const plainSmsBody = bodyLines.join('\n');
    const plainSubject = `Football Home — RSVP for ${eventTitle}`;

    const hasEmail = !!p.email;
    const hasSms   = !!(p.phone && p.sms_capable);

    // Base button style — thin & tight, room for four side-by-side.
    const btnBase = 'display:inline-flex;align-items:center;justify-content:center;'
                  + 'padding:4px 6px;border-radius:5px;font-size:0.72rem;font-weight:700;'
                  + 'text-decoration:none;line-height:1;white-space:nowrap;border:none;cursor:pointer;';

    // Plain (no magic link).
    const emailPlainBtn = hasEmail
      ? `<a href="${this._plainMailtoHref(p.email, plainSubject, plainBody)}"
             target="_blank" rel="noopener noreferrer"
             title="Email ${this._escape(p.email)} a plain RSVP reminder"
             style="${btnBase}background:#3b82f6;color:#fff;">📧</a>`
      : this._disabledBtn(btnBase, '📧', 'No email on file');

    const smsPlainBtn = hasSms
      ? `<a href="sms:${this._escape(p.phone)}?body=${encodeURIComponent(plainSmsBody)}"
             title="Text ${this._escape(this._fmtPhone(p.phone))} a plain RSVP reminder"
             style="${btnBase}background:#10b981;color:#fff;">💬</a>`
      : this._disabledBtn(btnBase, '💬', 'No SMS phone on file');

    // Magic-link — deferred, hits /api/events/:fhEventId/remind on click.
    const magicAttrs = `data-fh-event-id="${ev.fh_event_id}" data-person-id="${p.person_id}"`;
    const emailMagicBtn = hasEmail
      ? `<button type="button" class="mer-magic-btn" ${magicAttrs} data-channel="email"
                 title="Email ${this._escape(p.email)} a one-tap magic-link RSVP"
                 style="${btnBase}background:#0d9488;color:#fff;">🔗📧</button>`
      : this._disabledBtn(btnBase, '🔗📧', 'No email on file');

    const smsMagicBtn = hasSms
      ? `<button type="button" class="mer-magic-btn" ${magicAttrs} data-channel="sms"
                 title="Text ${this._escape(this._fmtPhone(p.phone))} a one-tap magic-link RSVP"
                 style="${btnBase}background:#0ea5e9;color:#fff;">🔗💬</button>`
      : this._disabledBtn(btnBase, '🔗💬', 'No SMS phone on file');

    return `
      <div style="display:flex;flex-direction:column;gap:3px;padding:5px 6px;background:rgba(15,23,42,0.35);border-radius:6px;">
        <div style="font-size:0.82rem;font-weight:600;line-height:1.15;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
          ${name}
        </div>
        <div style="display:flex;gap:3px;flex-wrap:nowrap;">
          ${emailPlainBtn}${smsPlainBtn}${emailMagicBtn}${smsMagicBtn}${window.PersonActions ? window.PersonActions.buttonsHtml({ leagueAppsUserId: p.leagueapps_user_id || p.la_user_id, personId: p.person_id, firstName: p.first_name, fullName: `${p.first_name || ''} ${p.last_name || ''}`.trim() }, { returnTo: 'mensEventsReminders' }) : ''}
        </div>
      </div>
    `;
  }

  _disabledBtn(btnBase, icon, tooltip) {
    return `<span title="${this._escape(tooltip)}"
                  style="${btnBase}background:rgba(148,163,184,0.15);color:rgba(148,163,184,0.5);cursor:not-allowed;">${icon}</span>`;
  }

  async handleMagicClick(btn) {
    const fhEventId = btn.getAttribute('data-fh-event-id');
    const personId  = btn.getAttribute('data-person-id');
    const channel   = btn.getAttribute('data-channel') || 'sms';

    if (!fhEventId || !personId) return;

    const original = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = '⏳';

    try {
      const resp = await this.auth.fetch(`/api/events/${fhEventId}/remind`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ channel, person_ids: [Number(personId)] })
      });
      const data = await resp.json();
      if (!resp.ok) throw new Error(data.error || `HTTP ${resp.status}`);

      const rec = (data.recipients || [])[0];
      if (!rec) {
        // Every skip path (rate-limit, no contact) collapses to no
        // recipient — surface the specific reason if the server gave us
        // one, otherwise a generic hint.
        const bits = [];
        if (data.skipped_rate_limited) bits.push('rate-limited (5-min cooldown)');
        if (data.skipped_no_contact)   bits.push(`no ${channel === 'sms' ? 'SMS phone' : 'email'} on file`);
        alert(bits.length
          ? `No link generated — ${bits.join('; ')}.`
          : 'No link generated (already RSVP\'d, no contact, or rate-limited).');
        return;
      }

      const href = channel === 'sms' ? rec.sms_href : rec.mailto_href;
      if (!href) {
        alert('Server returned a recipient with no launchable link.');
        return;
      }
      window.location.href = href;
    } catch (err) {
      console.error('magic link failed:', err);
      alert(`Failed: ${err.message || err}`);
    } finally {
      btn.disabled = false;
      btn.innerHTML = original;
    }
  }

  _plainMailtoHref(email, subject, body) {
    // Gmail compose URL is a lot friendlier on desktop than a raw
    // mailto:; mens-roster.js does the same thing.  authuser= pins the
    // sender so the coach doesn't accidentally send from a personal
    // Google account.
    const params = new URLSearchParams({
      view: 'cm',
      fs: '1',
      authuser: 'soccer@lighthouse1893.org',
      to: email,
      su: subject,
      body: body,
    });
    return `https://mail.google.com/mail/?${params.toString()}`;
  }

  _typeBadge(kind) {
    const t = (kind || '').toLowerCase();
    const styles = {
      practice: { bg:'rgba(59,130,246,0.22)',  fg:'#93c5fd', label:'🏃 Practice' },
      pickup:   { bg:'rgba(168,85,247,0.22)',  fg:'#c4b5fd', label:'⚡ Pickup'   },
      match:    { bg:'rgba(34,197,94,0.22)',   fg:'#86efac', label:'⚽ Match'    },
      meeting:  { bg:'rgba(148,163,184,0.22)', fg:'#cbd5e1', label:'📅 Meeting'  },
      camp:     { bg:'rgba(234,179,8,0.22)',   fg:'#fde68a', label:'🏕 Camp'      },
    };
    const s = styles[t] || { bg:'rgba(148,163,184,0.22)', fg:'#cbd5e1', label:'📅 Event' };
    return `<span style="padding:2px 8px;border-radius:9999px;font-size:0.72rem;
                          background:${s.bg};color:${s.fg};font-weight:700;
                          white-space:nowrap;">${s.label}</span>`;
  }

  _typeColor(kind) {
    const t = (kind || '').toLowerCase();
    return { practice:'#3b82f6', pickup:'#a855f7', match:'#22c55e',
             meeting:'#94a3b8', camp:'#eab308'
           }[t] || '#94a3b8';
  }

  _fmtDate(iso) {
    // "2026-07-06" → "Mon, Jul 6" — no timezone conversion since
    // the server already gave us America/New_York local dates.
    if (!iso) return '';
    const [y, m, d] = iso.split('-').map((x) => parseInt(x, 10));
    if (!y || !m || !d) return iso;
    const dt = new Date(Date.UTC(y, m - 1, d));
    return dt.toLocaleDateString('en-US', {
      weekday: 'short', month: 'short', day: 'numeric', timeZone: 'UTC'
    });
  }

  _fmtPhone(p) {
    if (!p) return '';
    const digits = String(p).replace(/\D/g, '');
    if (digits.length === 11 && digits.startsWith('1')) {
      return `(${digits.slice(1, 4)}) ${digits.slice(4, 7)}-${digits.slice(7)}`;
    }
    if (digits.length === 10) {
      return `(${digits.slice(0, 3)}) ${digits.slice(3, 6)}-${digits.slice(6)}`;
    }
    return p;
  }

  _escape(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }
}
