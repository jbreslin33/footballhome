// PracticeDashboardScreen — dedicated CRUD screen for practices or
// pickups scoped to a program (mens / womens / youth).
//
// Route:  registered under multiple names in app.js so tiles can jump
//         directly:
//           - 'mens-practice-dash'   → gender=mens,   kind=practice
//           - 'mens-pickup-dash'     → gender=mens,   kind=pickup
//           - 'womens-practice-dash' → gender=womens, kind=practice
//           - 'womens-pickup-dash'   → gender=womens, kind=pickup
//           - 'youth-practice-dash'  → gender=youth,  kind=practice
//           - 'youth-pickup-dash'    → gender=youth,  kind=pickup
//         All routes hit the SAME screen instance — params drive the
//         behavior.
//
// Data model:
//   • Each (gender, kind) pair maps to a single "pool team" in `teams`
//     with is_pool=true.  For example the Lighthouse men's practices
//     live on team_id=908 ("Practice", gender_category=mens, is_pool=t),
//     pickups on 909.
//   • The screen finds the pool team from
//     GET /api/clubs/:clubId?gender=<mens|womens|youth>
//     by matching is_pool && name matches the kind label.
//   • All practices/pickups are loaded from
//     GET /api/matches/team/:poolTeamId.
//   • CRUD:
//       CREATE  POST /api/lineups/games      body: {team_id, match_type_id, title, date, time?}
//       UPDATE  PUT  /api/lineups/games/:id  body: {title, date, time?}
//       DELETE  DELETE /api/matches/:id
//   • Attendance:  navigate to 'match-rsvp-management' with the
//     matchId param — that screen auto-expands the row.
//
// Because practices/pickups live on the shared pool team, they are
// automatically visible in every member team's team-hub via the
// `_fetchPoolMatches` merge — so a practice created here shows up on
// U23 Men, APSL, Liga 1, Liga 2, Tri County, Brazil, Puerto Rico, etc.
// simultaneously.  Delete/edit propagate globally for the same reason.

class PracticeDashboardScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.clubId = null;
    this.gender = 'mens';
    this.kind = 'practice';           // 'practice' | 'pickup'
    this.poolTeamId = null;
    this.poolTeamName = '';
    this.matches = [];
    this._editingId = null;           // matchId when the form is open in edit mode
    this._formOpen = false;
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-practice-dashboard';
    div.innerHTML = `
      <style>
        /* Screen-wide font bump — overrides inline font-sizes below. */
        .screen-practice-dashboard #pd-title       { font-size: 2rem !important; }
        .screen-practice-dashboard #pd-count       { font-size: 1.25rem !important; }
        .screen-practice-dashboard #pd-subtitle    { font-size: 1.25rem !important; line-height: 1.45; }
        .screen-practice-dashboard #pd-add-btn     { font-size: 1.4rem !important; padding: 14px 22px !important; }
        .screen-practice-dashboard .pd-filter-btn  { font-size: 1.2rem !important; padding: 11px 18px !important; }
        .screen-practice-dashboard #pd-form-title  { font-size: 1.4rem !important; }
        .screen-practice-dashboard #pd-form-wrap label { font-size: 1.05rem !important; }
        .screen-practice-dashboard #pd-form-wrap input { font-size: 1.2rem !important; padding: 10px 12px !important; }
        .screen-practice-dashboard #pd-f-save,
        .screen-practice-dashboard #pd-f-cancel    { font-size: 1.2rem !important; padding: 12px 20px !important; }
        .screen-practice-dashboard #pd-f-error     { font-size: 1.05rem !important; }
        .screen-practice-dashboard #pd-loading     { font-size: 1.25rem; }
        .screen-practice-dashboard #pd-empty       { font-size: 1.3rem; }
        .screen-practice-dashboard [data-pd-row]   { padding: 18px 20px !important; gap: 20px !important; }
        .screen-practice-dashboard [data-pd-row] > div:first-child > div:first-child { font-size: 1.45rem !important; }
        .screen-practice-dashboard [data-pd-row] > div:first-child > div:last-child  { font-size: 1.2rem !important; }
        .screen-practice-dashboard [data-pd-row] > div:nth-child(2) > div:first-child { font-size: 1.55rem !important; }
        .screen-practice-dashboard [data-pd-row] > div:nth-child(2) > div:last-child  { font-size: 1.2rem !important; }
        .screen-practice-dashboard [data-pd-attendance],
        .screen-practice-dashboard [data-pd-edit],
        .screen-practice-dashboard [data-pd-delete] { font-size: 1.2rem !important; padding: 12px 16px !important; }
        .screen-practice-dashboard .pd-summary      { font-size: 1.05rem !important; margin-top: 10px !important; }
      </style>

      <div class="screen-header" style="display:flex;align-items:center;gap:var(--space-3);padding:var(--space-3);">
        <button class="btn btn-secondary btn-sm back-btn">← Back</button>
        <h1 id="pd-title" style="margin:0;font-size:1.6rem;">Practice Dashboard</h1>
        <span style="flex:1"></span>
        <span id="pd-count" style="font-size:1rem;color:var(--text-muted);"></span>
      </div>

      <div style="padding:0 var(--space-3) var(--space-3);max-width:1100px;margin:0 auto;">
        <p id="pd-subtitle" style="opacity:0.8;font-size:1.05rem;margin:0 0 var(--space-3);line-height:1.4;"></p>

        <div id="pd-actions" style="display:flex;gap:var(--space-2);margin-bottom:var(--space-3);flex-wrap:wrap;">
          <button type="button" id="pd-add-btn"
                  style="all:unset;cursor:pointer;font-size:1.15rem;font-weight:600;padding:12px 20px;border-radius:8px;background:rgba(34,197,94,0.15);color:#86efac;border:1px solid rgba(34,197,94,0.45);">
            ➕ Add
          </button>
          <div style="flex:1"></div>
          <div id="pd-filter" style="display:flex;gap:6px;">
            <button type="button" class="pd-filter-btn" data-filter="upcoming"
                    style="all:unset;cursor:pointer;font-size:1rem;padding:10px 16px;border-radius:9999px;background:rgba(59,130,246,0.2);color:#93c5fd;border:1px solid rgba(59,130,246,0.5);">
              Upcoming
            </button>
            <button type="button" class="pd-filter-btn" data-filter="past"
                    style="all:unset;cursor:pointer;font-size:1rem;padding:10px 16px;border-radius:9999px;background:transparent;color:var(--text-muted);border:1px solid var(--border-color);">
              Past
            </button>
            <button type="button" class="pd-filter-btn" data-filter="all"
                    style="all:unset;cursor:pointer;font-size:1rem;padding:10px 16px;border-radius:9999px;background:transparent;color:var(--text-muted);border:1px solid var(--border-color);">
              All
            </button>
          </div>
        </div>

        <div id="pd-form-wrap" style="display:none;margin-bottom:var(--space-3);padding:var(--space-3);border-radius:10px;background:rgba(15,23,42,0.55);border:1px solid rgba(148,163,184,0.3);">
          <div id="pd-form-title" style="font-size:1.05rem;font-weight:600;margin-bottom:var(--space-2);">Add practice</div>
          <div style="display:grid;grid-template-columns:1fr 150px 130px 130px auto;gap:10px;align-items:end;">
            <label style="display:flex;flex-direction:column;gap:4px;font-size:0.85rem;color:var(--text-muted);">
              Title
              <input id="pd-f-title" type="text" placeholder="e.g. Tuesday practice — Rowan turf"
                     style="font-size:1rem;padding:8px 10px;border-radius:6px;background:var(--bg-secondary);color:var(--text-primary);border:1px solid var(--border-color);">
            </label>
            <label style="display:flex;flex-direction:column;gap:4px;font-size:0.85rem;color:var(--text-muted);">
              Date
              <input id="pd-f-date" type="date"
                     style="font-size:1rem;padding:8px 10px;border-radius:6px;background:var(--bg-secondary);color:var(--text-primary);border:1px solid var(--border-color);">
            </label>
            <label style="display:flex;flex-direction:column;gap:4px;font-size:0.85rem;color:var(--text-muted);">
              Start (opt.)
              <input id="pd-f-time" type="time"
                     style="font-size:1rem;padding:8px 10px;border-radius:6px;background:var(--bg-secondary);color:var(--text-primary);border:1px solid var(--border-color);">
            </label>
            <label style="display:flex;flex-direction:column;gap:4px;font-size:0.85rem;color:var(--text-muted);">
              End (opt.)
              <input id="pd-f-end-time" type="time"
                     style="font-size:1rem;padding:8px 10px;border-radius:6px;background:var(--bg-secondary);color:var(--text-primary);border:1px solid var(--border-color);">
            </label>
            <div style="display:flex;gap:8px;">
              <button type="button" id="pd-f-save"
                      style="all:unset;cursor:pointer;font-size:0.95rem;font-weight:600;padding:10px 16px;border-radius:6px;background:rgba(59,130,246,0.2);color:#93c5fd;border:1px solid rgba(59,130,246,0.5);">
                Save
              </button>
              <button type="button" id="pd-f-cancel"
                      style="all:unset;cursor:pointer;font-size:0.95rem;padding:10px 16px;border-radius:6px;background:transparent;color:var(--text-muted);border:1px solid var(--border-color);">
                Cancel
              </button>
            </div>
          </div>
          <!-- Venue row (2026-07-09) — dropdown of every venue in the club's book, -->
          <!-- plus a "no venue" option.  Editing here writes matches.venue_id via -->
          <!-- PUT /api/lineups/games/:id, which now accepts the field. -->
          <div style="display:grid;grid-template-columns:1fr;gap:10px;margin-top:10px;">
            <label style="display:flex;flex-direction:column;gap:4px;font-size:0.85rem;color:var(--text-muted);">
              Venue
              <select id="pd-f-venue"
                      style="font-size:1rem;padding:8px 10px;border-radius:6px;background:var(--bg-secondary);color:var(--text-primary);border:1px solid var(--border-color);">
                <option value="">— No venue —</option>
              </select>
            </label>
          </div>
          <div id="pd-f-error" style="display:none;font-size:0.85rem;color:#fca5a5;margin-top:8px;"></div>
        </div>

        <div id="pd-loading" style="text-align:center;padding:var(--space-4);color:var(--text-muted);">
          Loading…
        </div>

        <div id="pd-list" style="display:none;flex-direction:column;gap:8px;"></div>

        <div id="pd-empty" style="display:none;text-align:center;padding:var(--space-4);color:var(--text-muted);">
          <div style="font-size:2rem;margin-bottom:8px;">📭</div>
          <div id="pd-empty-msg">No practices yet.</div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId = params?.clubId || this.navigation.context.club?.id || null;
    this.gender = (params?.gender === 'womens' || params?.gender === 'youth')
      ? params.gender : 'mens';
    this.kind = (params?.kind === 'pickup') ? 'pickup' : 'practice';
    this._filter = 'upcoming';
    this._formOpen = false;
    this._editingId = null;

    const genderLabel = this.gender === 'womens' ? 'Women’s'
                      : this.gender === 'youth'  ? 'Youth' : 'Men’s';
    const kindLabelCap = this.kind === 'pickup' ? 'Pickup' : 'Practice';
    const kindIcon = this.kind === 'pickup' ? '⚡' : '🏃';
    this.find('#pd-title').textContent = `${kindIcon} ${genderLabel} ${kindLabelCap} Dashboard`;
    this.find('#pd-subtitle').textContent =
      `${kindLabelCap}s created here are shared across every ${genderLabel.toLowerCase()} team — APSL, Liga 1, Liga 2, Tri County, U23, and any other member team all see them automatically.`;
    this.find('#pd-empty-msg').textContent = `No ${this.kind}s yet. Click Add to create one.`;
    this.find('#pd-add-btn').textContent = `➕ Add ${kindLabelCap.toLowerCase()}`;
    this.find('#pd-form-title').textContent = `Add ${this.kind}`;

    // Wire on every entry — screen-manager calls render() on each
    // show(), so this.element is a fresh DOM node with no listeners.
    this._wire();

    // Load venues so the form's <select> is populated by the time the
    // user hits ➕ / ✏️.  Non-blocking — the list load can start in
    // parallel.
    this._loadVenues();

    this._loadAll();
  }

  _wire() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      if (e.target.closest('#pd-add-btn')) {
        this._openForm(null);
        return;
      }
      if (e.target.closest('#pd-f-cancel')) {
        this._closeForm();
        return;
      }
      if (e.target.closest('#pd-f-save')) {
        this._onSave();
        return;
      }
      const filterBtn = e.target.closest('.pd-filter-btn');
      if (filterBtn) {
        this._filter = filterBtn.dataset.filter;
        this._renderFilterPills();
        this._renderList();
        return;
      }
      const editBtn = e.target.closest('[data-pd-edit]');
      if (editBtn) {
        const id = parseInt(editBtn.dataset.pdEdit, 10);
        this._openForm(id);
        return;
      }
      const delBtn = e.target.closest('[data-pd-delete]');
      if (delBtn) {
        const id = parseInt(delBtn.dataset.pdDelete, 10);
        this._deleteMatch(id, delBtn);
        return;
      }
      const attBtn = e.target.closest('[data-pd-attendance]');
      if (attBtn) {
        const id = parseInt(attBtn.dataset.pdAttendance, 10);
        // Set team context so match-rsvp-management loads matches for
        // the pool team (it reads navigation.context.team.id).
        this.navigation.context.team = { id: this.poolTeamId, name: this.poolTeamName };
        this.navigation.goTo('match-rsvp-management', { matchId: id });
        return;
      }
    });
  }

  _renderFilterPills() {
    this.element.querySelectorAll('.pd-filter-btn').forEach(btn => {
      const active = btn.dataset.filter === this._filter;
      if (active) {
        btn.style.background = 'rgba(59,130,246,0.2)';
        btn.style.color = '#93c5fd';
        btn.style.borderColor = 'rgba(59,130,246,0.5)';
      } else {
        btn.style.background = 'transparent';
        btn.style.color = 'var(--text-muted)';
        btn.style.borderColor = 'var(--border-color)';
      }
    });
  }

  async _loadAll() {
    this.find('#pd-loading').style.display = 'block';
    this.find('#pd-list').style.display = 'none';
    this.find('#pd-empty').style.display = 'none';
    try {
      await this._resolvePoolTeam();
      await this._loadMatches();
      this._renderList();
    } catch (err) {
      console.error('Practice dashboard load failed:', err);
      this.find('#pd-loading').innerHTML =
        `<p style="color:#fca5a5;">❌ ${this.escapeHtml(err?.message || 'Failed to load')}</p>`;
    }
  }

  // Fetches the venues list once per screen visit so the form dropdown
  // has options.  Cached on `this._venues`; failure is non-fatal —
  // form still opens, just with "— No venue —" as the only option.
  async _loadVenues() {
    try {
      const res = await this.auth.fetch('/api/venues');
      const data = await res.json();
      const arr = Array.isArray(data?.data) ? data.data
                : Array.isArray(data)       ? data
                : [];
      // Sort by name, case-insensitive — the DB has mixed-case entries.
      arr.sort((a, b) => String(a.name || '').toLowerCase()
                          .localeCompare(String(b.name || '').toLowerCase()));
      this._venues = arr;
      // Populate the select right away so a fast "Add" click already sees options.
      const sel = this.find('#pd-f-venue');
      if (sel) {
        const opts = ['<option value="">— No venue —</option>'];
        for (const v of arr) {
          const label = v.city ? `${v.name} — ${v.city}` : v.name;
          opts.push(`<option value="${v.id}">${this.escapeHtml(label)}</option>`);
        }
        sel.innerHTML = opts.join('');
      }
    } catch (err) {
      console.warn('Practice dashboard: venue list load failed:', err);
      this._venues = [];
    }
  }

  async _resolvePoolTeam() {
    if (!this.clubId) throw new Error('No clubId — open this from Club Admin.');
    const res = await this.auth.fetch(`/api/clubs/${this.clubId}?gender=${this.gender}`);
    const data = await res.json();
    // Endpoint returns either {teams:[...]} or {data:{teams:[...]}}.
    const teams = Array.isArray(data?.teams) ? data.teams
                : Array.isArray(data?.data?.teams) ? data.data.teams
                : [];
    // Match the pool team by is_pool + name.  The seeded pool teams
    // are literally named "Practice" and "Pickup".
    const wantName = this.kind === 'pickup' ? 'pickup' : 'practice';
    const pool = teams.find(t => t.is_pool && String(t.name || '').toLowerCase() === wantName);
    if (!pool) {
      throw new Error(`No ${wantName} pool team found for ${this.gender} in this club. Ask an admin to seed it.`);
    }
    this.poolTeamId = pool.id;
    this.poolTeamName = pool.name;
  }

  async _loadMatches() {
    const res = await this.auth.fetch(`/api/matches/team/${this.poolTeamId}`);
    const data = await res.json();
    if (!data?.success) throw new Error(data?.message || 'Failed to load matches');
    this.matches = Array.isArray(data.data) ? data.data : [];
    // Sort ascending by date for stable ordering.
    this.matches.sort((a, b) =>
      String(a.event_date || a.match_date || '').localeCompare(String(b.event_date || b.match_date || ''))
    );
    // Cache of matchId → {rsvp:{yes,no}, attendance:{present,absent}}.
    // Populated lazily per row — kept keyed by id so re-renders reuse data.
    if (!this._summaries) this._summaries = {};
  }

  // Fetch summary for a single match — called after the row is rendered
  // so the initial paint isn't blocked on N HTTP round-trips.
  async _loadSummary(matchId) {
    if (this._summaries[matchId]) return this._summaries[matchId];
    try {
      const res = await this.auth.fetch(`/api/matches/${matchId}/rsvp-summary`);
      const data = await res.json();
      if (data?.success) {
        this._summaries[matchId] = data;
        return data;
      }
    } catch (_) { /* silently degrade — badge shows dashes */ }
    return null;
  }

  _renderList() {
    const list = this.find('#pd-list');
    const empty = this.find('#pd-empty');
    const loading = this.find('#pd-loading');
    const count = this.find('#pd-count');
    loading.style.display = 'none';

    // Match match_type_id strictly — data is now clean (908=3 practice,
    // 909=7 pickup) so we don't need title regex fallbacks that would
    // cross-contaminate.  This keeps the two dashboards pure.
    const isPractice = (m) => Number(m.match_type_id) === 3;
    const isPickup   = (m) => Number(m.match_type_id) === 7;
    const kindFilter = this.kind === 'pickup' ? isPickup : isPractice;

    const now = new Date();
    const nowIso = now.toISOString().slice(0, 19).replace('T', ' ');
    const timeFilter = (m) => {
      const d = String(m.event_date || m.match_date || '');
      if (this._filter === 'upcoming') return d >= nowIso.slice(0, 10);
      if (this._filter === 'past')     return d <  nowIso.slice(0, 10);
      return true;
    };

    const rows = this.matches.filter(kindFilter).filter(timeFilter);
    if (this._filter === 'past') rows.reverse();   // most recent past first

    count.textContent = `${rows.length} ${this.kind}${rows.length === 1 ? '' : 's'}`;

    if (rows.length === 0) {
      list.style.display = 'none';
      empty.style.display = 'block';
      return;
    }
    empty.style.display = 'none';
    list.style.display = 'flex';
    list.innerHTML = rows.map(m => this._renderRow(m)).join('');
    // Kick off async summary fetches; they patch each row's badge div
    // as they arrive.  Deliberately not awaited so paint isn't blocked.
    this._hydrateSummaries();
  }

  _renderRow(m) {
    const dateStr = String(m.event_date || m.match_date || '').slice(0, 10);
    const timeStr = String(m.event_date || '').slice(11, 16) || (m.match_time ? String(m.match_time).slice(0, 5) : '');
    const endTimeStr = m.end_time ? String(m.end_time).slice(0, 5) : '';
    const timeRange = timeStr && endTimeStr
      ? `${timeStr} – ${endTimeStr}`
      : (timeStr || endTimeStr || '—');
    const venue = m.venue_name || m.venue || '';
    const isPast = String(m.event_date || m.match_date || '').slice(0, 10)
                   < new Date().toISOString().slice(0, 10);
    return `
      <div data-pd-row="${m.id}"
           style="display:grid;grid-template-columns:130px 1fr auto;gap:16px;align-items:center;padding:14px 16px;border-radius:8px;background:${isPast ? 'rgba(30,41,59,0.35)' : 'rgba(30,41,59,0.55)'};border:1px solid rgba(71,85,105,0.35);">
        <div style="display:flex;flex-direction:column;">
          <div style="font-size:1.15rem;font-weight:600;color:#e2e8f0;">${this.escapeHtml(this._formatDate(dateStr))}</div>
          <div style="font-size:1rem;color:#94a3b8;">${this.escapeHtml(timeRange)}</div>
        </div>
        <div style="min-width:0;">
          <div style="font-size:1.25rem;font-weight:500;color:#e2e8f0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${this.escapeHtml(m.title || (this.kind === 'pickup' ? 'Pickup' : 'Practice'))}</div>
          ${venue ? `<div style="font-size:1rem;color:#94a3b8;margin-top:2px;">📍 ${this.escapeHtml(venue)}</div>` : ''}
          <!-- RSVP + Attendance summary badges (filled by _hydrateSummary) -->
          <div class="pd-summary" data-pd-summary="${m.id}"
               style="display:flex;gap:10px;margin-top:8px;flex-wrap:wrap;font-size:1rem;color:#94a3b8;">
            <span style="opacity:0.5;">…</span>
          </div>
        </div>
        <div style="display:flex;gap:8px;">
          <button type="button" data-pd-attendance="${m.id}"
                  style="all:unset;cursor:pointer;font-size:1.05rem;font-weight:500;padding:10px 14px;border-radius:6px;background:rgba(59,130,246,0.15);color:#93c5fd;border:1px solid rgba(59,130,246,0.35);">
            📋 RSVP / Attend
          </button>
          <button type="button" data-pd-edit="${m.id}"
                  style="all:unset;cursor:pointer;font-size:1.05rem;padding:10px 14px;border-radius:6px;background:rgba(148,163,184,0.12);color:#e2e8f0;border:1px solid rgba(148,163,184,0.35);"
                  title="Edit — applies globally">
            ✏️ Edit
          </button>
          <button type="button" data-pd-delete="${m.id}"
                  style="all:unset;cursor:pointer;font-size:1.05rem;padding:10px 14px;border-radius:6px;background:rgba(239,68,68,0.12);color:#fca5a5;border:1px solid rgba(239,68,68,0.35);"
                  title="Delete — applies globally">
            🗑️
          </button>
        </div>
      </div>
    `;
  }

  // Load rsvp-summary for each rendered row and patch its badge div.
  // Called after _renderList paints so first paint is instant.
  _hydrateSummaries() {
    const nodes = this.element.querySelectorAll('[data-pd-summary]');
    nodes.forEach(async (node) => {
      const id = node.dataset.pdSummary;
      const data = await this._loadSummary(id);
      if (!data) { node.innerHTML = '<span style="opacity:0.4;">no data</span>'; return; }
      const r = data.rsvp || {};
      const a = data.attendance || {};
      const pill = (bg, color, border, txt) =>
        `<span style="padding:4px 10px;border-radius:9999px;background:${bg};color:${color};border:1px solid ${border};font-weight:600;">${txt}</span>`;
      const rsvpParts = [
        pill('rgba(34,197,94,0.15)',  '#86efac', 'rgba(34,197,94,0.35)',  `👍 ${r.yes|0}`),
        pill('rgba(239,68,68,0.15)',  '#fca5a5', 'rgba(239,68,68,0.35)',  `👎 ${r.no|0}`),
      ].join('');
      const attParts = (a.present || a.absent) ? [
        pill('rgba(14,165,233,0.15)', '#7dd3fc', 'rgba(14,165,233,0.35)', `✅ ${a.present|0}`),
        pill('rgba(148,163,184,0.15)','#cbd5e1', 'rgba(148,163,184,0.35)',`❌ ${a.absent|0}`),
      ].join('') : '';
      node.innerHTML =
        `<span style="font-weight:600;color:#cbd5e1;">RSVP</span>${rsvpParts}` +
        (attParts ? `<span style="font-weight:600;color:#cbd5e1;margin-left:8px;">Attend</span>${attParts}` : '');
    });
  }

  _formatDate(iso) {
    if (!iso) return '';
    try {
      const [y, mo, d] = iso.split('-');
      const dt = new Date(Number(y), Number(mo) - 1, Number(d));
      return dt.toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' });
    } catch (_) { return iso; }
  }

  // ── Form ────────────────────────────────────────────────────────────

  _openForm(matchId) {
    this._editingId = matchId || null;
    this._formOpen = true;
    const wrap = this.find('#pd-form-wrap');
    const titleEl = this.find('#pd-f-title');
    const dateEl = this.find('#pd-f-date');
    const timeEl = this.find('#pd-f-time');
    const endEl  = this.find('#pd-f-end-time');
    const venueEl = this.find('#pd-f-venue');
    this.find('#pd-f-error').style.display = 'none';
    if (matchId) {
      const m = this.matches.find(x => String(x.id) === String(matchId));
      titleEl.value = m?.title || '';
      const iso = String(m?.event_date || m?.match_date || '').slice(0, 10);
      dateEl.value = iso;
      const t = String(m?.event_date || '').slice(11, 16) || (m?.match_time ? String(m.match_time).slice(0, 5) : '');
      timeEl.value = t;
      endEl.value  = m?.end_time ? String(m.end_time).slice(0, 5) : '';
      if (venueEl) venueEl.value = m?.venue_id != null ? String(m.venue_id) : '';
      this.find('#pd-form-title').textContent = `Edit ${this.kind}`;
    } else {
      titleEl.value = this.kind === 'pickup' ? 'Pickup' : 'Practice';
      dateEl.value = new Date().toISOString().slice(0, 10);
      timeEl.value = '';
      endEl.value  = '';
      if (venueEl) venueEl.value = '';
      this.find('#pd-form-title').textContent = `Add ${this.kind}`;
    }
    wrap.style.display = 'block';
    titleEl.focus();
    titleEl.select();
  }

  _closeForm() {
    this._formOpen = false;
    this._editingId = null;
    this.find('#pd-form-wrap').style.display = 'none';
  }

  async _onSave() {
    const err = this.find('#pd-f-error');
    err.style.display = 'none';
    const title = (this.find('#pd-f-title').value || '').trim();
    const date  = (this.find('#pd-f-date').value  || '').trim();
    const time  = (this.find('#pd-f-time').value  || '').trim();
    const endTime = (this.find('#pd-f-end-time').value || '').trim();
    const venueRaw = (this.find('#pd-f-venue')?.value || '').trim();
    // "" → null (backend interprets as "clear venue"); numeric → int
    const venueId = venueRaw === '' ? null : parseInt(venueRaw, 10);
    if (!title) { err.textContent = 'Title required'; err.style.display = 'block'; return; }
    if (!date)  { err.textContent = 'Date required';  err.style.display = 'block'; return; }
    if (endTime && !time) {
      err.textContent = 'Start time required when end time is set';
      err.style.display = 'block';
      return;
    }
    if (time && endTime && endTime <= time) {
      err.textContent = 'End time must be after start time';
      err.style.display = 'block';
      return;
    }

    const saveBtn = this.find('#pd-f-save');
    const oldLabel = saveBtn.textContent;
    saveBtn.disabled = true;
    saveBtn.style.opacity = '0.6';
    saveBtn.textContent = 'Saving…';

    try {
      const matchTypeId = this.kind === 'pickup' ? 7 : 3;
      let res;
      if (this._editingId) {
        res = await this.auth.fetch(`/api/lineups/games/${this._editingId}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            title, date,
            time: time || undefined,
            end_time: endTime || undefined,
            venue_id: venueId,   // null = clear, int = set
          }),
        });
      } else {
        res = await this.auth.fetch('/api/lineups/games', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            team_id: this.poolTeamId,
            match_type_id: matchTypeId,
            title, date,
            time: time || undefined,
            end_time: endTime || undefined,
            venue_id: venueId,   // null = no venue, int = set
          }),
        });
      }
      let data = null;
      try { data = await res.json(); } catch (_) { /* body may be empty */ }
      if (!res.ok || (data && data.error)) {
        err.textContent = (data && (data.error || data.message)) || `HTTP ${res.status}`;
        err.style.display = 'block';
        return;
      }
      this._closeForm();
      // Invalidate summary cache for the saved match — counts unchanged
      // but keeps things tidy on edit.
      if (this._editingId) delete this._summaries[this._editingId];
      await this._loadMatches();
      this._renderList();
    } catch (netErr) {
      err.textContent = netErr?.message || 'Network error';
      err.style.display = 'block';
    } finally {
      saveBtn.disabled = false;
      saveBtn.style.opacity = '1';
      saveBtn.textContent = oldLabel;
    }
  }

  async _deleteMatch(matchId, btnEl) {
    if (!confirm(`Delete this ${this.kind}? This applies globally — every team's calendar loses it. Cannot be undone.`)) return;
    if (btnEl) { btnEl.disabled = true; btnEl.style.opacity = '0.5'; btnEl.textContent = '…'; }
    try {
      const res = await this.auth.fetch(`/api/matches/${matchId}`, { method: 'DELETE' });
      let data = null;
      try { data = await res.json(); } catch (_) { /* ignore */ }
      if (!res.ok || (data && data.success === false)) {
        alert(`Delete failed: ${(data && data.message) || `HTTP ${res.status}`}`);
        if (btnEl) { btnEl.disabled = false; btnEl.style.opacity = '1'; btnEl.textContent = '🗑️'; }
        return;
      }
      this.matches = this.matches.filter(m => String(m.id) !== String(matchId));
      this._renderList();
    } catch (e) {
      alert(`Delete failed: ${e?.message || 'Network error'}`);
      if (btnEl) { btnEl.disabled = false; btnEl.style.opacity = '1'; btnEl.textContent = '🗑️'; }
    }
  }
}
