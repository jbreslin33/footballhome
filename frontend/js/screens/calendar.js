// CalendarScreen — read-only view over the Google Calendar mirror
// (populated every 5 min by scripts/gcal-sync.js + gcal-classify.js).
//
// Slice 5 of docs/calendar-design.md.  §10.1 lists three views for
// this screen — week grid, month grid, agenda list.  We ship the
// agenda list first because it's the smallest surface that proves
// the pipeline end-to-end and doubles as the mobile fallback per
// §10.1.  Week / month grids are follow-ups.
//
// Data:
//   GET /api/calendar/upcoming?days=14
//     → { days, count, events: [{
//         fh_event_id, gcal_event_id, calendar_role, calendar_time_zone,
//         google_event_id, recurring_event_id,
//         summary, description, location,
//         starts_at (UTC ISO), ends_at (UTC ISO), all_day, status,
//         html_link, hangout_link,
//         kind, category, is_home, fh_notes,
//         teams:            [{ id, name, gender_category }, ...]   // §6.1.5 junction
//         rsvps_open_at:    UTC ISO | null,
//         rsvps_open_now:   bool,
//         my_rsvp:          'yes'|'no'|'maybe'|null,
//         my_rsvp_eligible: bool | null   // null when anonymous; §6.1.5
//       }, ...] }
//
// Auth: GET endpoint is public but session-aware — if the caller has
// an fh_sess cookie or Bearer token, each event carries the caller's
// current `my_rsvp` value so the buttons can reflect state.
// We route through auth.fetch() to pick up the global no-cache
// headers (per user pref: no browser caching outside login).
//
// Slice 6 write path:
//   POST /api/calendar/rsvp
//     Body: { fh_event_id, response:'yes'|'no'|'maybe' }
//   Session-gated (401 when anonymous), 409 when
//   now() < fh_events.rsvps_open_at (window closed), 404 when the
//   event is tombstoned/cancelled.  Success returns { rsvp: {...} }.
class CalendarScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.events    = [];
    this.count     = 0;
    this.days      = 14;
    this.loading   = false;
    this.error     = null;
    this.fetchedAt = null;   // Date of last successful fetch
    // Set of fh_event_ids currently posting an RSVP.  Prevents double
    // submission when a user hammers a button and lets the render
    // path grey out the whole card while a write is in flight.
    this._rsvpInFlight = new Set();
  }

  // ---------- lifecycle ----------

  render() {
    const el = document.createElement('div');
    el.className = 'screen screen-calendar';
    el.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🗓️ Calendar</h1>
        <p class="subtitle" id="cal-subtitle">Next 14 days — mirrored from Google Calendar</p>
      </div>

      <div style="padding: 0 var(--space-4) var(--space-4);">
        <div id="cal-toolbar" style="display:flex; align-items:center; gap: var(--space-2);
             flex-wrap:wrap; margin-bottom: var(--space-3);">
          <span id="cal-fetched" style="padding:4px 12px; border-radius:9999px;
                font-size:0.85rem; background:transparent; color:#94a3b8;
                border:1px solid #94a3b8; white-space:nowrap;">Loading…</span>
          <button id="cal-refresh" class="btn btn-secondary"
                  style="padding:4px 12px; font-size:0.85rem;">🔄 Refresh</button>
          <span style="flex:1"></span>
          <label style="font-size:0.85rem; opacity:0.85;">
            Window:
            <select id="cal-days"
                    style="margin-left:6px; padding:4px 8px; border-radius:6px;
                           background: var(--bg-secondary);
                           color: var(--text-primary);
                           border:1px solid var(--color-border);">
              <option value="7">7 days</option>
              <option value="14" selected>14 days</option>
              <option value="30">30 days</option>
              <option value="60">60 days</option>
              <option value="90">90 days</option>
            </select>
          </label>
        </div>

        <div id="cal-loading" style="text-align:center; padding: var(--space-6); opacity:0.7;">
          Loading calendar…
        </div>
        <div id="cal-error" style="display:none; color: var(--color-error);
             padding: var(--space-4); text-align:center;"></div>
        <div id="cal-empty" style="display:none; text-align:center;
             padding: var(--space-6); opacity:0.6;">
          No classified events in this window.
        </div>
        <div id="cal-groups" style="display:none;"></div>

        <p style="opacity:0.55; font-size:0.8rem; margin-top: var(--space-4);
                  text-align:center; line-height:1.5;">
          Football Home mirrors <code>soccer@lighthouse1893.org</code> +
          <code>sports@lighthouse1893.org</code>.  To add or change an event,
          edit it in Google Calendar — FH picks it up within ~5&nbsp;minutes.
        </p>
      </div>
    `;
    this.element = el;
    return el;
  }

  onEnter(_params) {
    this.error = null;
    this._wire();
    this._load();
  }

  onExit() {
    // No timers to clean up (yet).  Slice 6a's countdown may add one.
  }

  // ---------- events ----------

  _wire() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      if (e.target.closest('#cal-refresh')) {
        this._load();
        return;
      }
      const rsvpBtn = e.target.closest('[data-rsvp-response]');
      if (rsvpBtn) {
        const card = rsvpBtn.closest('[data-fh-event-id]');
        if (!card) return;
        const fhEventId = parseInt(card.getAttribute('data-fh-event-id'), 10);
        const response  = rsvpBtn.getAttribute('data-rsvp-response');
        if (Number.isFinite(fhEventId) && response) {
          this._submitRsvp(fhEventId, response);
        }
        return;
      }
    });
    this.find('#cal-days').addEventListener('change', (e) => {
      const n = parseInt(e.target.value, 10);
      if (Number.isFinite(n) && n > 0) {
        this.days = n;
        this._load();
      }
    });
  }

  // ---------- data ----------

  async _load() {
    if (this.loading) return;
    this.loading = true;
    this._renderLoading();
    try {
      const res = await this.auth.fetch(`/api/calendar/upcoming?days=${this.days}`);
      if (!res.ok) {
        let msg = `HTTP ${res.status}`;
        try {
          const body = await res.json();
          if (body && body.error) msg = body.error;
        } catch (_) {}
        throw new Error(msg);
      }
      const body = await res.json();
      this.events    = Array.isArray(body.events) ? body.events : [];
      this.count     = body.count ?? this.events.length;
      this.fetchedAt = new Date();
      this.error     = null;
      this._renderGroups();
    } catch (err) {
      console.error('[calendar] load failed:', err);
      this.error = err.message || 'Failed to load calendar.';
      this._renderError();
    } finally {
      this.loading = false;
      this._renderToolbar();
    }
  }

  // ---------- rendering ----------

  _renderLoading() {
    this.find('#cal-loading').style.display = '';
    this.find('#cal-error').style.display   = 'none';
    this.find('#cal-empty').style.display   = 'none';
    this.find('#cal-groups').style.display  = 'none';
    this._renderToolbar();
  }

  _renderError() {
    this.find('#cal-loading').style.display = 'none';
    this.find('#cal-empty').style.display   = 'none';
    this.find('#cal-groups').style.display  = 'none';
    const errEl = this.find('#cal-error');
    errEl.textContent = this.error || 'Something went wrong.';
    errEl.style.display = '';
  }

  _renderToolbar() {
    const el = this.find('#cal-fetched');
    if (this.error) {
      el.textContent = 'Fetch failed';
      el.style.color = 'var(--color-error)';
      el.style.borderColor = 'var(--color-error)';
    } else if (this.fetchedAt) {
      const t = this.fetchedAt.toLocaleTimeString(undefined,
        { hour: 'numeric', minute: '2-digit' });
      el.textContent = `Fetched at ${t} · ${this.count} event${this.count === 1 ? '' : 's'}`;
      el.style.color = '#94a3b8';
      el.style.borderColor = '#94a3b8';
    } else {
      el.textContent = 'Loading…';
    }
    // Keep the <select> in sync in case a background action ever
    // changes this.days without a DOM click.
    const sel = this.find('#cal-days');
    if (sel) sel.value = String(this.days);
  }

  _renderGroups() {
    this.find('#cal-loading').style.display = 'none';
    this.find('#cal-error').style.display   = 'none';

    if (!this.events.length) {
      this.find('#cal-empty').style.display  = '';
      this.find('#cal-groups').style.display = 'none';
      return;
    }

    // Bucket by calendar date in the user's local zone.
    // Buckets: Today, Tomorrow, This week (rest of), Next week, Later.
    const now = new Date();
    const startOfDay = (d) => new Date(d.getFullYear(), d.getMonth(), d.getDate());
    const today    = startOfDay(now);
    const tomorrow = new Date(today); tomorrow.setDate(tomorrow.getDate() + 1);
    const dayAfter = new Date(today); dayAfter.setDate(dayAfter.getDate() + 2);
    // Days remaining until Sunday 00:00 (exclusive).  In JS: Sun=0.
    const daysToNextSunday = (7 - now.getDay()) % 7 || 7;
    const nextSunday       = new Date(today); nextSunday.setDate(nextSunday.getDate() + daysToNextSunday);
    const twoSundaysOut    = new Date(nextSunday); twoSundaysOut.setDate(twoSundaysOut.getDate() + 7);

    const buckets = [
      { key: 'today',    label: 'Today',      test: (d) => d >= today    && d < tomorrow      },
      { key: 'tomorrow', label: 'Tomorrow',   test: (d) => d >= tomorrow && d < dayAfter      },
      { key: 'thisweek', label: 'This week',  test: (d) => d >= dayAfter && d < nextSunday    },
      { key: 'nextweek', label: 'Next week',  test: (d) => d >= nextSunday && d < twoSundaysOut },
      { key: 'later',    label: 'Later',      test: (d) => d >= twoSundaysOut                  },
    ];
    const groups = buckets.map(b => ({ ...b, events: [] }));
    for (const ev of this.events) {
      const d  = new Date(ev.starts_at);
      const dd = startOfDay(d);
      const g  = groups.find(b => b.test(dd));
      if (g) g.events.push(ev);
    }

    const host = this.find('#cal-groups');
    host.innerHTML = groups
      .filter(g => g.events.length)
      .map(g => this._renderGroup(g))
      .join('');
    this.find('#cal-empty').style.display  = 'none';
    host.style.display = '';
  }

  _renderGroup(group) {
    return `
      <section style="margin-bottom: var(--space-5);">
        <h3 style="margin: 0 0 var(--space-2); opacity:0.9;
                   font-size:1.05rem; letter-spacing:0.02em;">
          ${this._escape(group.label)}
          <span style="opacity:0.55; font-weight:400; font-size:0.85rem;">
            &nbsp;·&nbsp;${group.events.length}
          </span>
        </h3>
        <div style="display:grid; gap: var(--space-2);
                    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));">
          ${group.events.map(ev => this._renderCard(ev)).join('')}
        </div>
      </section>
    `;
  }

  _renderCard(ev) {
    const startD = new Date(ev.starts_at);
    const endD   = new Date(ev.ends_at);
    const dayLbl = startD.toLocaleDateString(undefined,
      { weekday: 'short', month: 'short', day: 'numeric' });
    const timeLbl = ev.all_day
      ? 'All day'
      : `${startD.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })}` +
        ` – ${endD.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })}`;

    // Kind → color.  Matches §10.1 palette.
    const kindColors = {
      pickup:   { bg: '#1e3a8a', fg: '#dbeafe' },  // blue
      practice: { bg: '#064e3b', fg: '#d1fae5' },  // green
      match:    { bg: '#7f1d1d', fg: '#fecaca' },  // red
      meeting:  { bg: '#334155', fg: '#e2e8f0' },  // grey
      camp:     { bg: '#78350f', fg: '#fed7aa' },  // amber
      other:    { bg: '#334155', fg: '#e2e8f0' },
    };
    const kc = kindColors[ev.kind] || kindColors.other;

    // Kind-pill trailer: prefer `category` (single-club events);
    // fall back to unique gender_categories aggregated across the
    // §6.1.5 junction (multi-club events return category=NULL from
    // the backend since the CHECK constraint only allows a single
    // value there).  Empty when there's no team info at all.
    const teams = Array.isArray(ev.teams) ? ev.teams : [];
    let kindTrailer = '';
    if (ev.category) {
      kindTrailer = ev.category;
    } else if (teams.length) {
      const cats = [...new Set(teams.map(t => t.gender_category).filter(Boolean))];
      if (cats.length) kindTrailer = cats.join('+');
    }
    const kindLabel = ev.kind + (kindTrailer ? ` · ${kindTrailer}` : '');

    // Compact team chip strip below the kind pill — shows which
    // rosters this event is attached to.  Only rendered when there
    // are teams; keeps single-team events visually quiet by putting
    // the team name inline with the kind pill instead.
    let teamStrip = '';
    if (teams.length === 1) {
      teamStrip = `
        <div style="opacity:0.7; font-size:0.8rem;">
          👥 ${this._escape(teams[0].name)}
        </div>`;
    } else if (teams.length > 1) {
      teamStrip = `
        <div style="display:flex; gap:4px; flex-wrap:wrap;">
          ${teams.map(t => `
            <span style="padding:1px 8px; border-radius:9999px;
                         background:#1f2937; color:#cbd5e1;
                         font-size:0.75rem; border:1px solid var(--color-border);">
              ${this._escape(t.name)}
            </span>`).join('')}
        </div>`;
    }

    // fh_notes (from `Notes:` DSL tag) rendered as a plain-text block.
    // Preserves user newlines via CSS white-space so multi-line notes
    // like "Bring water\nNo cleats" render on separate visual lines.
    const notesBlock = ev.fh_notes ? `
      <div style="opacity:0.85; font-size:0.9rem; padding: 6px 10px;
                  border-left: 3px solid #64748b; background:#0f172a;
                  border-radius:4px; white-space:pre-wrap;">
        📝 ${this._escape(ev.fh_notes)}
      </div>` : '';

    // Google Meet button when the underlying gcal event has a Meet
    // attached.  Rendered above the RSVP block so a player who's
    // late can jump into the Meet without scrolling past the RSVP UI.
    const meetBlock = ev.hangout_link ? `
      <a href="${this._escape(ev.hangout_link)}" target="_blank" rel="noopener"
         style="display:inline-block; padding:6px 12px; border-radius:6px;
                background:#065f46; color:#d1fae5; font-size:0.85rem;
                font-weight:600; text-decoration:none;">
        📹 Join Meet
      </a>` : '';

    // RSVP block per §6.5 + §6.1.5 eligibility gate.  Applies to any
    // "weekly cadence" kind (pickup + practice — same Sunday 20:00 ET
    // window rule).  match/meeting/camp get no RSVP UI until §6.5.4
    // specifies their windows.
    //
    //   Not signed in                          → "sign in to respond" pill
    //   Signed in, my_rsvp_eligible === false  → "not on this roster" pill
    //   Signed in, my_rsvp_eligible === true, window open   → YES/NO/MAYBE buttons
    //   Signed in, window not yet open         → amber countdown pill
    //   Signed in, teams[] empty (no DSL tag)  → "ops needs to tag this event" pill
    let rsvpBlock = '';
    const isWeekly = ev.kind === 'pickup' || ev.kind === 'practice';
    if (isWeekly) {
      const inFlight = this._rsvpInFlight.has(ev.fh_event_id);
      const signedIn = this._isSignedIn();

      if (!signedIn) {
        rsvpBlock = `
          <div style="margin-top: var(--space-2); padding: 6px 10px; border-radius:6px;
                      background:#065f46; color:#d1fae5; font-size:0.85rem;">
            ✅ Sign in to RSVP
          </div>`;
      } else if (teams.length === 0) {
        rsvpBlock = `
          <div style="margin-top: var(--space-2); padding: 6px 10px; border-radius:6px;
                      background:#78350f; color:#fed7aa; font-size:0.85rem;">
            ⚠ Waiting on ops to attach a roster to this event
          </div>`;
      } else if (ev.my_rsvp_eligible === false) {
        rsvpBlock = `
          <div style="margin-top: var(--space-2); padding: 6px 10px; border-radius:6px;
                      background:#334155; color:#cbd5e1; font-size:0.85rem;">
            You're not on the roster for this event
          </div>`;
      } else if (ev.rsvps_open_now) {
        rsvpBlock = this._renderRsvpButtons(ev, inFlight);
      } else if (ev.rsvps_open_at) {
        const opens = new Date(ev.rsvps_open_at);
        const opensLbl = opens.toLocaleString(undefined, {
          weekday: 'short', month: 'short', day: 'numeric',
          hour: 'numeric', minute: '2-digit',
        });
        rsvpBlock = `
          <div style="margin-top: var(--space-2); padding: 6px 10px; border-radius:6px;
                      background:#78350f; color:#fed7aa; font-size:0.85rem;">
            ⏱ RSVPs open ${this._escape(opensLbl)}
          </div>`;
      }
    }

    const gcalLink = ev.html_link
      ? `<a href="${this._escape(ev.html_link)}" target="_blank" rel="noopener"
            style="color:#93c5fd; font-size:0.85rem; text-decoration:none;">
           Open in Google Calendar ↗
         </a>`
      : '';

    return `
      <div class="cal-card" data-fh-event-id="${ev.fh_event_id}"
           style="background: var(--bg-secondary);
           border:1px solid var(--color-border); border-radius: var(--radius-md);
           padding: var(--space-3); display:flex; flex-direction:column; gap:6px;">
        <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
          <span style="background:${kc.bg}; color:${kc.fg};
                       padding:2px 8px; border-radius:9999px;
                       font-size:0.75rem; text-transform:uppercase;
                       letter-spacing:0.05em; font-weight:600;">
            ${this._escape(kindLabel)}
          </span>
          <span style="opacity:0.65; font-size:0.8rem;">
            ${this._escape(dayLbl)}
          </span>
        </div>
        <div style="font-weight:600; font-size:1rem;">
          ${this._escape(ev.summary || '(untitled)')}
        </div>
        ${teamStrip}
        <div style="opacity:0.8; font-size:0.9rem;">
          🕒 ${this._escape(timeLbl)}
        </div>
        ${ev.location ? `
          <div style="opacity:0.8; font-size:0.9rem;">
            📍 ${this._escape(ev.location)}
          </div>` : ''}
        ${notesBlock}
        ${meetBlock}
        ${rsvpBlock}
        ${gcalLink ? `<div style="margin-top:auto; padding-top: var(--space-1);">${gcalLink}</div>` : ''}
      </div>
    `;
  }

  // ---------- RSVP (Slice 6) ----------

  // Cheap sign-in check so anonymous callers see the read-only pill
  // instead of dead-clicking a button that would 401.  Uses the same
  // localStorage token that auth.fetch() sets Authorization from.
  _isSignedIn() {
    if (this.auth && typeof this.auth.isLoggedIn === 'function') {
      return !!this.auth.isLoggedIn();
    }
    return false;
  }

  _renderRsvpButtons(ev, inFlight) {
    // One button per allowed response.  data-* attrs let the delegated
    // click handler in _wire() find both the event id (on the card)
    // and the response (on the button) without inline handlers.
    //
    // Selection styling follows the same palette as the kind pill so
    // "which one am I on" is instantly readable at a glance.
    const responses = [
      { key: 'yes',   label: '✓ YES',    on: '#065f46', off: '#1f2937', fg: '#d1fae5' },
      { key: 'no',    label: '✗ NO',     on: '#7f1d1d', off: '#1f2937', fg: '#fecaca' },
      { key: 'maybe', label: '? MAYBE',  on: '#78350f', off: '#1f2937', fg: '#fed7aa' },
    ];
    const current = ev.my_rsvp; // 'yes'|'no'|'maybe'|null
    const disabled = inFlight ? 'disabled' : '';
    const opacity  = inFlight ? '0.5'      : '1';
    const buttons = responses.map(r => {
      const active = current === r.key;
      const bg = active ? r.on  : r.off;
      const bd = active ? r.on  : 'var(--color-border)';
      return `
        <button type="button"
                data-rsvp-response="${r.key}"
                ${disabled}
                style="flex:1 1 0; padding:6px 10px; border-radius:6px;
                       border:1px solid ${bd}; background:${bg};
                       color:${r.fg}; font-size:0.85rem; font-weight:600;
                       cursor:${inFlight ? 'wait' : 'pointer'};
                       opacity:${opacity};">
          ${r.label}
        </button>`;
    }).join('');

    return `
      <div style="margin-top: var(--space-2); display:flex; gap:6px;">
        ${buttons}
      </div>`;
  }

  async _submitRsvp(fhEventId, response) {
    if (this._rsvpInFlight.has(fhEventId)) return;
    // Optimistic mark so a second click before the network round-trip
    // returns is a no-op.  Re-render the single card to grey the
    // buttons out and swap the cursor.
    this._rsvpInFlight.add(fhEventId);
    this._patchCard(fhEventId);
    try {
      const res = await this.auth.fetch('/api/calendar/rsvp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ fh_event_id: fhEventId, response }),
      });
      if (!res.ok) {
        let msg = `HTTP ${res.status}`;
        try {
          const body = await res.json();
          if (body && body.error) msg = body.error;
        } catch (_) {}
        // Common cases worth surfacing distinctly:
        //   401 — session expired, tell them to sign back in.
        //   409 — window closed (probably raced the Sunday 20:00 open).
        //   404 — event was cancelled between fetch and click.
        if (res.status === 401) msg = 'Please sign in to RSVP.';
        alert(msg); // TODO: replace with an inline banner in a follow-up
        return;
      }
      const body = await res.json();
      // Reflect the server's canonical response locally without a full
      // reload — patch the my_rsvp field on the matching event and
      // re-render just that card.
      const ev = this.events.find(e => e.fh_event_id === fhEventId);
      if (ev) ev.my_rsvp = body?.rsvp?.response || response;
    } catch (err) {
      console.error('[calendar] RSVP failed:', err);
      alert(err.message || 'Failed to save RSVP.');
    } finally {
      this._rsvpInFlight.delete(fhEventId);
      this._patchCard(fhEventId);
    }
  }

  // Replace the DOM subtree for exactly one card so we don't nuke the
  // whole agenda list (and scroll position) on every click.
  _patchCard(fhEventId) {
    const ev = this.events.find(e => e.fh_event_id === fhEventId);
    if (!ev) return;
    const old = this.element.querySelector(`[data-fh-event-id="${fhEventId}"]`);
    if (!old) return;
    const tmp = document.createElement('div');
    tmp.innerHTML = this._renderCard(ev).trim();
    const fresh = tmp.firstChild;
    if (fresh) old.replaceWith(fresh);
  }

  // ---------- utils ----------

  _escape(s) {
    if (s == null) return '';
    return String(s)
      .replaceAll('&',  '&amp;')
      .replaceAll('<',  '&lt;')
      .replaceAll('>',  '&gt;')
      .replaceAll('"',  '&quot;')
      .replaceAll('\'', '&#39;');
  }
}
