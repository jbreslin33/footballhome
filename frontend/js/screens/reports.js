// ReportsScreen — #reports — the club's report hub.  One report today,
// Attendance & RSVP, backed by GET /api/reports/attendance
// (backend/src/controllers/ReportsController.cpp); the Payments chip
// hands off to the existing #payments screen rather than duplicating
// the LeagueApps financials here.
//
// What the table answers, per player per team:
//   • RSVP % — did they answer at all (yes OR no both count).  The
//     complement, "no response", is the negligence signal the owner
//     asked for: forgetting to RSVP is the problem, not saying no.
//   • Attendance % — of the events where the coach took attendance,
//     how many were they at (present or late).  Events nobody checked
//     in for are left out of the denominator.
//   • Reliability % — of the events they said YES to and attendance
//     was taken, how many did they actually show for.  No-shows are
//     the yes-then-absent count.
//   • Activity — last RSVP, last attended, last login, folded into a
//     "days since last activity" number that sorts, plus the silent
//     streak: how many of their most recent expected events in a row
//     went unanswered.  Both are the "did this player quit?" sorts.
//
// Games (match + intrasquad), practices and pickup are separate
// buckets; the view chips pick which bucket the detail columns show
// while the All view puts games and practices side by side.
//
// Every column header sorts; click again to flip.  Category (Men /
// Women / Boys / Girls) and team chips use the shared FilterBar so
// this screen reads like Members / Payments / Event Access.
//
// Scope comes from the backend: club admins see every rostered team,
// coaches see the teams they coach.  Clicking a row expands the
// per-event detail (GET /api/reports/attendance/events).
class ReportsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.report   = 'attendance';
    this.view     = 'all';          // all | game | practice | pickup
    this.range    = '90';           // 30 | 90 | season | all | custom
    this.from     = null;           // YYYY-MM-DD when range === 'custom'
    this.to       = null;
    this.category = null;           // mens | womens | boys | girls | null
    this.teamId   = null;
    this.search   = '';
    this.sort     = { key: 'silent_streak', dir: 'desc' };
    this.data     = null;
    this.loading  = false;
    this.error    = null;
    this.expanded = new Set();      // "personId:teamId" rows showing events
    this.eventsCache = new Map();   // same key → events[]
    this._filterBar = null;
    try {
      const saved = JSON.parse(localStorage.getItem('fh.reports.attendance.sort') || 'null');
      if (saved && saved.key && saved.dir) this.sort = saved;
    } catch (_) { /* localStorage unavailable — keep default */ }
  }

  static get SEASON_START() { return '2026-08-01'; }
  static get CATEGORY_LABELS() {
    return { mens: 'Men', womens: 'Women', boys: 'Boys', girls: 'Girls' };
  }
  static get VIEW_LABELS() {
    return { all: 'All', game: 'Games', practice: 'Practices', pickup: 'Pickup' };
  }

  // ── Render ──────────────────────────────────────────────────────
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .rpt-table { width:100%; border-collapse:collapse; font-size:0.85rem; }
        .rpt-table th { position:sticky; top:0; background:var(--bg-surface); color:var(--text-muted);
                        font-size:0.7rem; text-transform:uppercase; letter-spacing:0.04em;
                        padding:8px 6px; border-bottom:2px solid var(--border-color);
                        text-align:right; white-space:nowrap; cursor:pointer; user-select:none; }
        .rpt-table th:first-child, .rpt-table th.rpt-left { text-align:left; }
        .rpt-table th.rpt-sorted { color:var(--accent); }
        .rpt-table td { padding:6px; border-bottom:1px solid var(--border-color); text-align:right;
                        white-space:nowrap; vertical-align:top; }
        .rpt-table td:first-child, .rpt-table td.rpt-left { text-align:left; }
        .rpt-table tbody tr.rpt-row { cursor:pointer; }
        .rpt-table tbody tr.rpt-row:hover { background:var(--bg-surface); }
        .rpt-sub { display:block; font-size:0.7rem; opacity:0.6; }
        .rpt-pct { font-weight:700; }
        .rpt-good { color:#4ade80; } .rpt-mid { color:#facc15; } .rpt-bad { color:#f87171; }
        .rpt-none { opacity:0.4; }
        .rpt-tile { flex:1 1 140px; padding:10px 12px; border-radius:8px; background:var(--bg-secondary);
                    border:1px solid var(--border-color); }
        .rpt-tile .v { font-size:1.4rem; font-weight:800; }
        .rpt-tile .l { font-size:0.75rem; opacity:0.7; }
        .rpt-chip { padding:5px 12px; border-radius:999px; cursor:pointer; font-weight:600; font-size:0.8rem;
                    border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .rpt-chip.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .rpt-events { background:var(--bg-primary); }
        .rpt-events td { white-space:normal; }
        .rpt-ev { display:grid; grid-template-columns: 9rem 7rem 1fr 1fr; gap:4px 12px; font-size:0.8rem; padding:2px 0; }
        @media (max-width: 768px) { .rpt-ev { grid-template-columns: 1fr 1fr; } }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>📊 Reports</h1>
        <p class="subtitle" id="rpt-subtitle">Attendance &amp; RSVP — who answers, who shows up, who has gone quiet</p>
      </div>

      <div style="padding: var(--space-4); max-width: 1500px; margin: 0 auto;">
        <div id="rpt-reports" style="display:flex; gap:var(--space-2); flex-wrap:wrap; margin-bottom: var(--space-3);">
          <button class="rpt-chip on" data-report="attendance">📋 Attendance &amp; RSVP</button>
          <button class="rpt-chip" data-report="payments" title="Opens the Payments screen">💳 Payments →</button>
        </div>

        <div id="rpt-range" style="display:flex; gap:var(--space-2); flex-wrap:wrap; align-items:center; margin-bottom: var(--space-2);"></div>
        <div id="rpt-filters" style="display:flex; flex-wrap:wrap; gap:var(--space-1); margin-bottom: var(--space-2);"></div>

        <div style="display:flex; gap:var(--space-2); flex-wrap:wrap; align-items:center; margin-bottom: var(--space-3);">
          <div id="rpt-views" style="display:flex; gap:var(--space-1); flex-wrap:wrap;"></div>
          <input id="rpt-search" type="search" placeholder="Search player…"
                 style="padding:6px 10px; border-radius:6px; border:1px solid var(--border-color);
                        background:var(--bg-secondary); color:var(--text-primary); min-width:180px;">
          <span style="flex:1;"></span>
          <button id="rpt-export" class="btn btn-secondary" style="padding:4px 12px; font-size:0.85rem;">⬇️ CSV</button>
          <button id="rpt-refresh" class="btn btn-secondary" style="padding:4px 12px; font-size:0.85rem;">🔄 Refresh</button>
        </div>

        <div id="rpt-tiles" style="display:flex; gap:var(--space-2); flex-wrap:wrap; margin-bottom: var(--space-3);"></div>
        <div id="rpt-note" style="font-size:0.75rem; opacity:0.65; margin-bottom: var(--space-2);"></div>
        <div id="rpt-status" style="opacity:0.7; margin-bottom: var(--space-2);"></div>
        <div id="rpt-body" style="overflow-x:auto;"></div>
      </div>
    `;
    this.element = div;
    this._wireEvents();
    return div;
  }

  onEnter(params) {
    if (params?.teamId)   this.teamId   = Number(params.teamId);
    if (params?.category) this.category = params.category;
    if (params?.view && ReportsScreen.VIEW_LABELS[params.view]) this.view = params.view;
    this._renderRange();
    this._renderViews();
    this.load();
  }

  _wireEvents() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }

      const rep = e.target.closest('[data-report]');
      if (rep) {
        if (rep.dataset.report === 'payments') this.navigation.goTo('payments');
        return;
      }
      const range = e.target.closest('[data-range]');
      if (range) {
        this.range = range.dataset.range;
        this._renderRange();
        if (this.range !== 'custom') this.load();
        return;
      }
      const view = e.target.closest('[data-view]');
      if (view) {
        this.view = view.dataset.view;
        this._renderViews();
        this._renderTable();
        return;
      }
      const th = e.target.closest('th[data-sort]');
      if (th) {
        const key = th.dataset.sort;
        if (this.sort.key === key) {
          this.sort.dir = this.sort.dir === 'desc' ? 'asc' : 'desc';
        } else {
          this.sort = { key, dir: th.dataset.dir || 'desc' };
        }
        try { localStorage.setItem('fh.reports.attendance.sort', JSON.stringify(this.sort)); } catch (_) {}
        this._renderTable();
        return;
      }
      if (e.target.closest('#rpt-refresh')) { this.load(); return; }
      if (e.target.closest('#rpt-export'))  { this._exportCsv(); return; }

      const profile = e.target.closest('[data-person-profile]');
      if (profile) {
        e.preventDefault();
        e.stopPropagation();
        this.navigation.goTo('person', { personId: Number(profile.dataset.personProfile), returnTo: 'reports' });
        return;
      }
      const row = e.target.closest('tr.rpt-row');
      if (row) { this._toggleRow(row.dataset.key); return; }
    });

    this.element.addEventListener('input', (e) => {
      if (e.target.id === 'rpt-search') {
        this.search = e.target.value.trim().toLowerCase();
        this._renderTable();
      }
    });
    this.element.addEventListener('change', (e) => {
      if (e.target.id === 'rpt-from' || e.target.id === 'rpt-to') {
        this.from = this.find('#rpt-from').value || null;
        this.to   = this.find('#rpt-to').value   || null;
        if (this.from && this.to) this.load();
      }
    });
  }

  // ── Data ────────────────────────────────────────────────────────
  _window() {
    const today = new Date();
    const iso = (d) => d.toISOString().slice(0, 10);
    const daysAgo = (n) => { const d = new Date(today); d.setDate(d.getDate() - n); return iso(d); };
    switch (this.range) {
      case '30':     return { from: daysAgo(30), to: iso(today) };
      case '90':     return { from: daysAgo(90), to: iso(today) };
      case 'season': return { from: ReportsScreen.SEASON_START, to: iso(today) };
      case 'all':    return { from: '2026-01-01', to: iso(today) };
      case 'custom': return { from: this.from, to: this.to };
      default:       return { from: daysAgo(90), to: iso(today) };
    }
  }

  async load() {
    const w = this._window();
    if (!w.from || !w.to) return;
    this.loading = true;
    this.error = null;
    this.expanded.clear();
    this.eventsCache.clear();
    this._setStatus('Loading…');
    try {
      const res = await this.auth.fetch(`/api/reports/attendance?from=${w.from}&to=${w.to}`);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.data = body;
      // A team preselected by a coach page that isn't in the response
      // (renamed, out of scope) must not leave the table empty.
      if (this.teamId && !this.data.teams.some(t => t.id === this.teamId)) this.teamId = null;
      if (this.teamId && !this.category) {
        this.category = this.data.teams.find(t => t.id === this.teamId)?.category || null;
      }
    } catch (err) {
      console.error('[reports] load failed', err);
      this.error = err.message || String(err);
      this.data = null;
    } finally {
      this.loading = false;
    }
    this._setStatus(this.error ? `⚠️ ${this.escapeHtml(this.error)}` : '');
    this._renderFilters();
    this._renderTiles();
    this._renderNote();
    this._renderTable();
  }

  _setStatus(html) {
    const el = this.find('#rpt-status');
    if (el) el.innerHTML = html;
  }

  // Rows after the category / team / search filters.
  _filteredRows() {
    if (!this.data) return [];
    return this.data.rows.filter(r => {
      if (this.category && r.category !== this.category) return false;
      if (this.teamId && r.team_id !== this.teamId) return false;
      if (this.search) {
        const name = `${r.first_name || ''} ${r.last_name || ''}`.toLowerCase();
        if (!name.includes(this.search)) return false;
      }
      return true;
    });
  }

  // ── Derived numbers ─────────────────────────────────────────────
  static lastActivity(row) {
    const a = row.activity || {};
    const times = [a.last_rsvp_at, a.last_attended_at, a.last_login_at]
      .filter(Boolean).map(t => Date.parse(t)).filter(n => !Number.isNaN(n));
    return times.length ? Math.max(...times) : null;
  }
  static daysSince(iso) {
    if (!iso) return null;
    const t = typeof iso === 'number' ? iso : Date.parse(iso);
    if (Number.isNaN(t)) return null;
    return Math.floor((Date.now() - t) / 86400000);
  }
  static fmtDate(iso) {
    if (!iso) return '—';
    const d = new Date(iso);
    if (Number.isNaN(d.getTime())) return '—';
    return d.toLocaleDateString(undefined, { month: 'numeric', day: 'numeric' });
  }
  static fmtDateTime(iso) {
    if (!iso) return '—';
    const d = new Date(iso);
    if (Number.isNaN(d.getTime())) return '—';
    return d.toLocaleString(undefined, { weekday: 'short', month: 'numeric', day: 'numeric', hour: 'numeric', minute: '2-digit' });
  }

  // Column specs.  `get` returns the sortable value (null sorts last),
  // `html` renders the cell.  `dir` is the first-click direction.
  _columns() {
    const pctCell = (pct, num, den, cls = '') => {
      if (pct == null) return `<span class="rpt-none">—</span><span class="rpt-sub">0 events</span>`;
      const tone = pct >= 75 ? 'rpt-good' : pct >= 50 ? 'rpt-mid' : 'rpt-bad';
      return `<span class="rpt-pct ${tone} ${cls}">${pct}%</span><span class="rpt-sub">${num}/${den}</span>`;
    };
    const countCell = (n, tone = '') => n
      ? `<span class="${tone}">${n}</span>`
      : `<span class="rpt-none">0</span>`;
    const b = (row, bucket) => row.buckets[bucket];

    const nameCol = {
      key: 'name', label: 'Player', left: true, dir: 'asc',
      get: r => `${r.last_name || ''} ${r.first_name || ''}`.toLowerCase(),
      html: r => {
        const flags = [];
        if (r.suspended_now) flags.push('<span title="RSVP suspended" style="color:#f87171;">⛔</span>');
        if (!r.rsvp_eligible) flags.push(`<span title="${this.escapeHtml(r.roster_status_label || '')}" style="opacity:0.6;">🚫</span>`);
        if (r.is_youth) flags.push('<span title="Youth — RSVPs come from a parent" style="opacity:0.6;">👨‍👧</span>');
        return `<a href="#person" data-person-profile="${r.person_id}" style="color:inherit; font-weight:600; text-decoration:none;">
                  ${this.escapeHtml(r.first_name || '')} ${this.escapeHtml(r.last_name || '')}</a> ${flags.join(' ')}`;
      },
    };
    const teamCol = {
      key: 'team', label: 'Team', left: true, dir: 'asc',
      get: r => `${r.section || ''} ${r.team_name || ''}`.toLowerCase(),
      html: r => `${this.escapeHtml(r.team_name || '')}<span class="rpt-sub">${ReportsScreen.CATEGORY_LABELS[r.category] || r.category || ''}</span>`,
    };
    const activityCols = [
      {
        key: 'silent_streak', label: 'Silent streak', dir: 'desc',
        title: 'Most recent expected events in a row with no RSVP',
        get: r => r.activity.silent_streak,
        html: r => {
          const n = r.activity.silent_streak;
          const tone = n >= 5 ? 'rpt-bad' : n >= 3 ? 'rpt-mid' : '';
          return n ? `<span class="rpt-pct ${tone}">${n}</span><span class="rpt-sub">unanswered</span>` : '<span class="rpt-none">0</span>';
        },
      },
      {
        key: 'last_activity', label: 'Last activity', dir: 'desc',
        title: 'Days since the latest of: last RSVP, last attended, last login',
        get: r => { const d = ReportsScreen.daysSince(ReportsScreen.lastActivity(r)); return d == null ? Number.POSITIVE_INFINITY : d; },
        html: r => {
          const d = ReportsScreen.daysSince(ReportsScreen.lastActivity(r));
          const a = r.activity;
          const tone = d == null || d >= 21 ? 'rpt-bad' : d >= 10 ? 'rpt-mid' : 'rpt-good';
          const sub = `RSVP ${ReportsScreen.fmtDate(a.last_rsvp_at)} · At ${ReportsScreen.fmtDate(a.last_attended_at)} · Login ${ReportsScreen.fmtDate(a.last_login_at)}`;
          return `<span class="rpt-pct ${tone}">${d == null ? 'never' : d + 'd'}</span><span class="rpt-sub">${sub}</span>`;
        },
      },
    ];

    if (this.view === 'all') {
      const rsvp = (bucket, label) => ({
        key: `rsvp_${bucket}`, label, dir: 'asc', title: 'Answered (yes or no) ÷ expected',
        get: r => b(r, bucket).rsvp_pct,
        html: r => pctCell(b(r, bucket).rsvp_pct, b(r, bucket).responded, b(r, bucket).expected),
      });
      const att = (bucket, label) => ({
        key: `att_${bucket}`, label, dir: 'asc', title: 'Present or late ÷ events where attendance was taken',
        get: r => b(r, bucket).attend_pct,
        html: r => pctCell(b(r, bucket).attend_pct, b(r, bucket).attended, b(r, bucket).checked),
      });
      return [
        nameCol, teamCol,
        rsvp('game', 'RSVP % games'), rsvp('practice', 'RSVP % practices'), rsvp('all', 'RSVP % all'),
        {
          key: 'no_response_all', label: 'No reply', dir: 'desc', title: 'Expected events with no RSVP at all (all kinds)',
          get: r => b(r, 'all').no_response,
          html: r => countCell(b(r, 'all').no_response, b(r, 'all').no_response >= 5 ? 'rpt-bad' : ''),
        },
        att('game', 'Attend % games'), att('practice', 'Attend % practices'),
        {
          key: 'rel_all', label: 'Reliability', dir: 'asc', title: 'Said yes and was there ÷ said yes and attendance was taken',
          get: r => b(r, 'all').reliability_pct,
          html: r => pctCell(b(r, 'all').reliability_pct, b(r, 'all').yes_showed, b(r, 'all').yes_checked),
        },
        ...activityCols,
      ];
    }

    const v = this.view;
    return [
      nameCol, teamCol,
      { key: 'expected', label: 'Expected', dir: 'desc', get: r => b(r, v).expected, html: r => countCell(b(r, v).expected) },
      { key: 'responded', label: 'Answered', dir: 'desc', get: r => b(r, v).responded, html: r => countCell(b(r, v).responded) },
      { key: 'rsvp_pct', label: 'RSVP %', dir: 'asc', get: r => b(r, v).rsvp_pct, html: r => pctCell(b(r, v).rsvp_pct, b(r, v).responded, b(r, v).expected) },
      { key: 'yes', label: 'Yes', dir: 'desc', get: r => b(r, v).yes, html: r => countCell(b(r, v).yes, 'rpt-good') },
      { key: 'no', label: 'No', dir: 'desc', get: r => b(r, v).no, html: r => countCell(b(r, v).no) },
      { key: 'no_response', label: 'No reply', dir: 'desc', get: r => b(r, v).no_response, html: r => countCell(b(r, v).no_response, b(r, v).no_response >= 5 ? 'rpt-bad' : '') },
      { key: 'checked', label: 'Checked', dir: 'desc', title: 'Events where attendance was taken', get: r => b(r, v).checked, html: r => countCell(b(r, v).checked) },
      { key: 'attended', label: 'Attended', dir: 'desc', get: r => b(r, v).attended, html: r => countCell(b(r, v).attended, 'rpt-good') },
      { key: 'attend_pct', label: 'Attend %', dir: 'asc', get: r => b(r, v).attend_pct, html: r => pctCell(b(r, v).attend_pct, b(r, v).attended, b(r, v).checked) },
      { key: 'no_shows', label: 'No-shows', dir: 'desc', title: 'Said yes, attendance taken, not there', get: r => b(r, v).no_shows, html: r => countCell(b(r, v).no_shows, 'rpt-bad') },
      { key: 'reliability', label: 'Reliability', dir: 'asc', get: r => b(r, v).reliability_pct, html: r => pctCell(b(r, v).reliability_pct, b(r, v).yes_showed, b(r, v).yes_checked) },
      { key: 'walk_ons', label: 'Walk-ons', dir: 'desc', title: 'Showed up without saying yes', get: r => b(r, v).walk_ons, html: r => countCell(b(r, v).walk_ons) },
      ...activityCols,
    ];
  }

  _sortedRows(rows, columns) {
    const col = columns.find(c => c.key === this.sort.key) || columns[0];
    const dir = this.sort.dir === 'asc' ? 1 : -1;
    const name = columns[0];
    const val = (r) => { const v = col.get(r); return v == null ? null : v; };
    return rows.slice().sort((a, b) => {
      const va = val(a), vb = val(b);
      if (va == null && vb == null) return name.get(a) < name.get(b) ? -1 : 1;
      if (va == null) return 1;               // blanks always last
      if (vb == null) return -1;
      if (va < vb) return -1 * dir;
      if (va > vb) return  1 * dir;
      return name.get(a) < name.get(b) ? -1 : 1;
    });
  }

  // ── Renderers ───────────────────────────────────────────────────
  _renderRange() {
    const el = this.find('#rpt-range');
    if (!el) return;
    const w = this._window();
    const chip = (id, label) => `<button class="rpt-chip ${this.range === id ? 'on' : ''}" data-range="${id}">${label}</button>`;
    el.innerHTML = `
      <span style="opacity:0.6; font-size:0.8rem;">Window:</span>
      ${chip('30', 'Last 30 days')}${chip('90', 'Last 90 days')}${chip('season', 'Season')}${chip('all', 'All')}${chip('custom', 'Custom')}
      <span style="display:${this.range === 'custom' ? 'inline-flex' : 'none'}; gap:6px; align-items:center; font-size:0.8rem;">
        <input id="rpt-from" type="date" value="${this.from || w.from || ''}" style="padding:4px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary);">
        →
        <input id="rpt-to" type="date" value="${this.to || w.to || ''}" style="padding:4px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary);">
      </span>
      <span style="opacity:0.5; font-size:0.75rem;">${this.data ? `${this.data.from} → ${this.data.to}` : ''}</span>`;
  }

  _renderViews() {
    const el = this.find('#rpt-views');
    if (!el) return;
    el.innerHTML = Object.entries(ReportsScreen.VIEW_LABELS).map(([id, label]) =>
      `<button class="rpt-chip ${this.view === id ? 'on' : ''}" data-view="${id}">${label}</button>`).join('');
  }

  _renderFilters() {
    const el = this.find('#rpt-filters');
    if (!el || !this.data) return;
    const teams = this.data.teams;
    const cats = ['mens', 'womens', 'boys', 'girls'];
    const catChips = [{ id: 'all', label: 'All', count: teams.length }].concat(cats.map(c => ({
      id: c, label: ReportsScreen.CATEGORY_LABELS[c],
      count: teams.filter(t => t.category === c).length,
      disabled: !teams.some(t => t.category === c),
    })));
    const teamChips = teams
      .filter(t => !this.category || t.category === this.category)
      .map(t => ({
        id: String(t.id),
        label: `${t.name} · ${t.games}G/${t.practices}P${t.pickups ? '/' + t.pickups + 'PU' : ''}`,
        count: t.roster_size,
      }));

    if (!this._filterBar) this._filterBar = new FilterBar({ host: el, compact: 'compact' });
    this._filterBar.setRows([
      {
        name: 'category', chips: catChips, selected: this.category || 'all',
        onSelect: (id) => {
          this.category = (id === 'all' || id == null) ? null : id;
          this.teamId = null;
          this._renderFilters(); this._renderTiles(); this._renderTable();
        },
      },
      {
        name: 'team', chips: teamChips, selected: this.teamId ? String(this.teamId) : null,
        onSelect: (id) => {
          this.teamId = id == null ? null : Number(id);
          this._renderFilters(); this._renderTiles(); this._renderTable();
        },
      },
    ]);
  }

  _renderTiles() {
    const el = this.find('#rpt-tiles');
    if (!el) return;
    const rows = this._filteredRows();
    if (!rows.length) { el.innerHTML = ''; return; }
    const v = this.view;
    const sum = (f) => rows.reduce((n, r) => n + (f(r) || 0), 0);
    const pct = (n, d) => d ? Math.round(n / d * 100) + '%' : '—';
    const expected = sum(r => r.buckets[v].expected), responded = sum(r => r.buckets[v].responded);
    const checked = sum(r => r.buckets[v].checked),  attended  = sum(r => r.buckets[v].attended);
    const yesChecked = sum(r => r.buckets[v].yes_checked), yesShowed = sum(r => r.buckets[v].yes_showed);
    const quiet = rows.filter(r => { const d = ReportsScreen.daysSince(ReportsScreen.lastActivity(r)); return d == null || d >= 14; }).length;
    const silent = rows.filter(r => r.activity.silent_streak >= 3).length;
    const tile = (v, l, tone = '') => `<div class="rpt-tile"><div class="v ${tone}">${v}</div><div class="l">${l}</div></div>`;
    el.innerHTML =
      tile(rows.length, 'players (rows)') +
      tile(pct(responded, expected), `RSVP rate · ${responded}/${expected} ${ReportsScreen.VIEW_LABELS[v].toLowerCase()}`) +
      tile(expected - responded, 'no reply', expected - responded ? 'rpt-bad' : '') +
      tile(pct(attended, checked), `attendance · ${attended}/${checked} checked`) +
      tile(pct(yesShowed, yesChecked), `reliability · yes → showed`) +
      tile(silent, 'silent 3+ in a row', silent ? 'rpt-mid' : '') +
      tile(quiet, 'no activity 14+ days', quiet ? 'rpt-bad' : '');
  }

  _renderNote() {
    const el = this.find('#rpt-note');
    if (!el || !this.data) return;
    el.innerHTML = `${this.data.scope === 'coach' ? 'Showing the teams you coach. ' : ''}`
      + 'Expected = everyone on the team\'s current roster (minus suspended). '
      + 'Attendance % only counts events where the coach took attendance; on those, no mark = not there. '
      + 'Click a row for the event-by-event detail, the name for the profile.';
  }

  _renderTable() {
    const el = this.find('#rpt-body');
    if (!el) return;
    if (!this.data) { el.innerHTML = ''; return; }
    const columns = this._columns();
    if (!columns.some(c => c.key === this.sort.key)) this.sort = { key: 'silent_streak', dir: 'desc' };
    const rows = this._sortedRows(this._filteredRows(), columns);
    if (!rows.length) {
      el.innerHTML = '<div style="opacity:0.6; padding: var(--space-4);">No players match.</div>';
      return;
    }
    const arrow = (c) => this.sort.key === c.key ? (this.sort.dir === 'asc' ? ' ↑' : ' ↓') : '';
    const head = columns.map(c =>
      `<th data-sort="${c.key}" data-dir="${c.dir}" class="${c.left ? 'rpt-left' : ''} ${this.sort.key === c.key ? 'rpt-sorted' : ''}"
           title="${this.escapeHtml(c.title || 'Click to sort')}">${c.label}${arrow(c)}</th>`).join('');
    const body = rows.map(r => {
      const key = `${r.person_id}:${r.team_id}`;
      const cells = columns.map(c => `<td class="${c.left ? 'rpt-left' : ''}">${c.html(r)}</td>`).join('');
      const open = this.expanded.has(key);
      return `<tr class="rpt-row" data-key="${key}">${cells}</tr>`
        + (open ? `<tr class="rpt-events"><td colspan="${columns.length}" class="rpt-left">${this._eventsHtml(key)}</td></tr>` : '');
    }).join('');
    el.innerHTML = `<table class="rpt-table"><thead><tr>${head}</tr></thead><tbody>${body}</tbody></table>`;
  }

  // ── Per-row event detail ────────────────────────────────────────
  async _toggleRow(key) {
    if (this.expanded.has(key)) { this.expanded.delete(key); this._renderTable(); return; }
    this.expanded.add(key);
    this._renderTable();
    if (this.eventsCache.has(key)) return;
    const [personId, teamId] = key.split(':');
    const w = this._window();
    try {
      const res = await this.auth.fetch(`/api/reports/attendance/events?personId=${personId}&teamId=${teamId}&from=${w.from}&to=${w.to}`);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.eventsCache.set(key, body.events || []);
    } catch (err) {
      this.eventsCache.set(key, { error: err.message || String(err) });
    }
    if (this.expanded.has(key)) this._renderTable();
  }

  _eventsHtml(key) {
    const ev = this.eventsCache.get(key);
    if (!ev) return '<span style="opacity:0.6;">Loading events…</span>';
    if (ev.error) return `<span style="color:#f87171;">⚠️ ${this.escapeHtml(ev.error)}</span>`;
    if (!ev.length) return '<span style="opacity:0.6;">No expected events in this window.</span>';
    const kindLabel = { match: 'Game', intrasquad: 'Intrasquad', practice: 'Practice', pickup: 'Pickup' };
    const rsvp = (e) => {
      if (e.response === 'yes')   return `<span class="rpt-good">✔ yes</span> <span style="opacity:0.5;">${ReportsScreen.fmtDate(e.responded_at)}</span>`;
      if (e.response === 'no')    return `<span>✖ no</span> <span style="opacity:0.5;">${ReportsScreen.fmtDate(e.responded_at)}</span>`;
      if (e.response === 'maybe') return `<span class="rpt-mid">? maybe</span>`;
      return '<span class="rpt-bad">no reply</span>';
    };
    const att = (e) => {
      if (!e.checked) return '<span style="opacity:0.4;">not taken</span>';
      const map = { present: '<span class="rpt-good">present</span>', late: '<span class="rpt-mid">late</span>',
                    absent: '<span class="rpt-bad">absent</span>', excused: '<span>excused</span>' };
      return map[e.attendance] || '<span class="rpt-bad">not marked</span>';
    };
    return ev.map(e => `
      <div class="rpt-ev">
        <span>${ReportsScreen.fmtDateTime(e.start_at)}</span>
        <span>${kindLabel[e.kind] || e.kind}${e.opponent ? ' vs ' + this.escapeHtml(e.opponent) : ''}</span>
        <span>RSVP: ${rsvp(e)}</span>
        <span>Attendance: ${att(e)}</span>
      </div>`).join('');
  }

  // ── CSV ─────────────────────────────────────────────────────────
  _exportCsv() {
    if (!this.data) return;
    const columns = this._columns();
    const rows = this._sortedRows(this._filteredRows(), columns);
    const b = (r, k) => r.buckets[k];
    const head = ['Player', 'Team', 'Category',
      'Games expected', 'Games answered', 'Games RSVP %', 'Games yes', 'Games no', 'Games no reply',
      'Games checked', 'Games attended', 'Games attend %', 'Games no-shows',
      'Practices expected', 'Practices answered', 'Practices RSVP %', 'Practices yes', 'Practices no', 'Practices no reply',
      'Practices checked', 'Practices attended', 'Practices attend %', 'Practices no-shows',
      'Pickup expected', 'Pickup answered', 'Pickup RSVP %', 'Pickup attended', 'Pickup attend %',
      'All RSVP %', 'All attend %', 'Reliability %',
      'Silent streak', 'Last RSVP', 'Last attended', 'Last login', 'Days since activity'];
    const line = (r) => {
      const g = b(r, 'game'), p = b(r, 'practice'), u = b(r, 'pickup'), a = b(r, 'all');
      const d = ReportsScreen.daysSince(ReportsScreen.lastActivity(r));
      return [`${r.first_name || ''} ${r.last_name || ''}`.trim(), r.team_name, ReportsScreen.CATEGORY_LABELS[r.category] || r.category,
        g.expected, g.responded, g.rsvp_pct, g.yes, g.no, g.no_response, g.checked, g.attended, g.attend_pct, g.no_shows,
        p.expected, p.responded, p.rsvp_pct, p.yes, p.no, p.no_response, p.checked, p.attended, p.attend_pct, p.no_shows,
        u.expected, u.responded, u.rsvp_pct, u.attended, u.attend_pct,
        a.rsvp_pct, a.attend_pct, a.reliability_pct,
        r.activity.silent_streak, r.activity.last_rsvp_at, r.activity.last_attended_at, r.activity.last_login_at, d];
    };
    const esc = (v) => { const s = v == null ? '' : String(v); return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s; };
    const csv = [head, ...rows.map(line)].map(cols => cols.map(esc).join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `attendance-${this.data.from}-to-${this.data.to}.csv`;
    document.body.appendChild(a);
    a.click();
    setTimeout(() => { URL.revokeObjectURL(a.href); a.remove(); }, 0);
  }
}
