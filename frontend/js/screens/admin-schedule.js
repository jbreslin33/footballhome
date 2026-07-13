// AdminScheduleScreen — Club-wide unified schedule board.
//
// Renders every match + practice for every team in the current club
// on a single grouped card grid so a coach doesn't have to hop team →
// team → team dashboard to see the week ahead.
//
// UX theme (matches MembersScreen / RsvpEligibilityScreen / PaymentsScreen):
//   * Shared `FilterBar` component for context chips.
//   * Sort + status-filter pill row (same visual language, same click
//     semantics — active pill flips direction on repeat click).
//   * Live search input (client-side match against title / team names /
//     venue).
//   * Grouped card grid — one <section> per date bucket
//     (Today · Tomorrow · This week · Next week · Later · Past),
//     `repeat(auto-fill, minmax(320px, 1fr))` grid inside each.
//   * Cards are clickable → drills into the existing match-detail
//     screen with `_snapshotHistoryState()` so the browser Back
//     button restores the exact pill + search state we were on.
//   * Sync-now button + last-sync chip in the header row.
//
// Data flow (no LA involved — matches are FH-authoritative):
//   1. GET /api/clubs/:clubId?gender=all
//        → list of teams belonging to this club, each carrying
//          `gender_category` (mens/womens/boys — DB uses the plural
//          forms) so we can filter the schedule by scope.
//   2. In parallel per team:
//        GET /api/matches/team/:teamId?include_past=true
//        → returns matches, practices, and pickups (practices/
//          pickups are stored in the same `matches` table,
//          distinguished by `match_type`).
//   3. Dedupe matches by id (a league match appears in BOTH home +
//      away team feeds; we keep the first copy).
//   4. Enrich each row with a `_category` (mens/womens/boys/girls) +
//      `_kind` (match/practice/pickup) derived from the team catalog
//      and the row's `match_type`.
//   5. Render.  All filtering + sorting is client-side.
//
// Series (recurring weekly templates) intentionally stay on their own
// screen (admin-series-editor) — templates are a different mental
// model (they generate matches, they aren't schedule items).  This
// screen exposes a small "Manage recurring series →" link so the
// operator has a one-click hop.
class AdminScheduleScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>📅 Schedule</h1>
        <p class="subtitle" id="sched-subtitle">Every match and practice across the club</p>
      </div>

      <div style="padding: var(--space-4);">

        <!-- Sync bar + shortcut into the recurring-series editor.
             Matches on this screen are FH-authoritative (not LA), so
             "Sync now" just re-fetches from the DB. -->
        <div id="sched-sync-bar" style="margin-bottom: var(--space-3); display:flex;
             align-items:center; gap: var(--space-2); flex-wrap: wrap;">
          <span id="sched-sync-time" style="padding:4px 12px; border-radius:9999px;
                font-size:0.85rem; font-weight:500; background: transparent;
                color: #94a3b8; border: 1px solid #94a3b8; white-space:nowrap;">
            Last sync: —
          </span>
          <button class="sched-sync-now btn btn-secondary" style="padding: 4px 12px; font-size: 0.85rem;">
            🔄 Sync now
          </button>
          <button class="sched-open-series btn btn-secondary" style="padding: 4px 12px; font-size: 0.85rem;">
            🔁 Manage recurring series →
          </button>
        </div>

        <!-- FilterBar host (context pill rows).  Hidden until data
             lands so we don't flash an empty pill row. -->
        <div id="sched-filters" style="display:none; margin-bottom: var(--space-3);
             flex-wrap:wrap; gap: var(--space-1);"></div>

        <!-- Sort + status-filter pill row (mirrors #members-sort). -->
        <div id="sched-sort" style="display:none; margin-bottom: var(--space-3);
             flex-wrap:wrap; gap: var(--space-1); align-items:center;"></div>

        <div id="sched-search-wrap" style="margin-bottom: var(--space-3); display:none;">
          <input id="sched-search" type="search"
                 placeholder="Search title, team, venue…"
                 style="width:100%; padding: var(--space-2) var(--space-3); font-size: 1rem;
                        border-radius: var(--radius-md); border: 1px solid var(--color-border);
                        background: var(--bg-secondary); color: var(--text-primary);">
        </div>

        <div id="sched-loading" style="text-align:center; padding: var(--space-6); opacity:0.7;">
          Loading schedule…
        </div>
        <div id="sched-error" style="display:none; color: var(--color-error);
             padding: var(--space-4); text-align:center;"></div>
        <div id="sched-empty" style="display:none; text-align:center; padding: var(--space-6); opacity:0.6;">
          No events match this filter.
        </div>

        <div id="sched-groups" style="display:none;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId   = params?.clubId;
    this.clubName = params?.clubName;

    // Filter state.
    this.kindFilter     = params?.kind     || null;   // 'match' | 'practice' | null(all)
    this.categoryFilter = params?.category || null;   // 'mens' | 'womens' | 'boys' | 'girls' | null(all)
    this.dateRange      = params?.dateRange || 'upcoming'; // 'upcoming' | 'past' | 'all'

    // Restore-state contract (paired with match-detail's back-nav).
    // One-shot: consumed on first _load().
    this._pendingRestore = params?.restore || null;

    // FilterBar is DOM-bound — screen manager rebuilds the DOM on
    // every entry, so a cached instance would write to a ghost node.
    // See MembersScreen for the same pattern.
    this._filterBar = null;

    // Warm cache — preserve across back-nav entries so we can render
    // instantly and refetch in the background.
    if (!Array.isArray(this._rows))    this._rows    = [];
    if (!Array.isArray(this._teams))   this._teams   = [];
    if (typeof this._filter !== 'string') this._filter = '';
    if (typeof this._lastSyncAt !== 'string') this._lastSyncAt = '';

    // Sort key + status flags — persisted per-screen.
    // Values: 'date_asc' | 'date_desc' | 'venue_asc' | 'home_asc' | 'status_asc'
    if (typeof this._sort !== 'string') {
      this._sort = localStorage.getItem('sched-sort') || 'date_asc';
    }
    if (typeof this._flagOverride !== 'boolean') {
      this._flagOverride = localStorage.getItem('sched-flag-override') === '1';
    }
    if (typeof this._flagNoVenue !== 'boolean') {
      this._flagNoVenue = localStorage.getItem('sched-flag-no-venue') === '1';
    }

    // ── Delegated event handler on the whole screen. ──
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      if (e.target.closest('.sched-sync-now')) {
        this._load({ force: true });
        return;
      }
      if (e.target.closest('.sched-open-series')) {
        this._snapshotHistoryState();
        this.navigation.goTo('admin-series-editor', {
          clubId: this.clubId,
          clubName: this.clubName,
        });
        return;
      }
      // Date-range button row (built by _renderSortPills).
      const rangeBtn = e.target.closest('[data-range]');
      if (rangeBtn) {
        this.dateRange = rangeBtn.getAttribute('data-range');
        this._renderSortPills();
        this._renderGroups();
        return;
      }
      // Sort pill row — same idiom as MembersScreen.
      const sortBtn = e.target.closest('[data-sort]');
      if (sortBtn) {
        const next = sortBtn.getAttribute('data-sort');
        if (next === 'date_asc' && this._sort === 'date_asc') {
          this._sort = 'date_desc';
        } else if (next === 'date_asc' && this._sort === 'date_desc') {
          this._sort = 'date_asc';
        } else {
          this._sort = next;
        }
        try { localStorage.setItem('sched-sort', this._sort); } catch (_) {}
        this._renderSortPills();
        this._renderGroups();
        return;
      }
      // Status-filter chips (OR-semantics).
      const flagBtn = e.target.closest('[data-flag]');
      if (flagBtn) {
        const which = flagBtn.getAttribute('data-flag');
        if (which === 'override') {
          this._flagOverride = !this._flagOverride;
          try { localStorage.setItem('sched-flag-override', this._flagOverride ? '1' : '0'); } catch (_) {}
        } else if (which === 'no-venue') {
          this._flagNoVenue = !this._flagNoVenue;
          try { localStorage.setItem('sched-flag-no-venue', this._flagNoVenue ? '1' : '0'); } catch (_) {}
        }
        this._renderSortPills();
        this._renderGroups();
        return;
      }
      // Card body → open the unified schedule-item detail screen.
      // Guard against clicks on inner controls (future-proof for
      // per-card edit / quick-status buttons).
      const anchorInside = e.target.closest('a, button, input, textarea, select, label');
      if (anchorInside) return;
      const card = e.target.closest('.sched-card[data-item-id]');
      if (card) {
        const itemId = Number(card.getAttribute('data-item-id')) || 0;
        if (itemId > 0) {
          this._snapshotHistoryState();
          this.navigation.goTo('admin-schedule-item', {
            matchId: itemId,
            returnTo: 'admin-schedule',
            returnToParams: {
              clubId:   this.clubId,
              clubName: this.clubName,
            },
          });
        }
      }
    });

    const search = this.find('#sched-search');
    if (search) {
      search.addEventListener('input', (ev) => {
        this._filter = (ev.target.value || '').trim().toLowerCase();
        this._renderGroups();
      });
    }

    this._load();
  }

  // ── Data flow ────────────────────────────────────────────────────
  async _load(opts = {}) {
    const loadingEl = this.find('#sched-loading');
    const errorEl   = this.find('#sched-error');
    const emptyEl   = this.find('#sched-empty');
    const groupsEl  = this.find('#sched-groups');
    errorEl.style.display = 'none';

    const hasCache = Array.isArray(this._rows) && this._rows.length > 0;
    if (hasCache && !opts.force) {
      // Warm entry — reveal chrome from cache while a background
      // refresh runs.
      loadingEl.style.display = 'none';
      groupsEl.style.display  = 'block';
      this._consumePendingRestore();
      this._renderChips();
      this._renderSortPills();
      this._renderGroups();
      this._revealChrome();
    } else {
      loadingEl.style.display = 'block';
      loadingEl.textContent   = 'Loading teams…';
      groupsEl.style.display  = 'none';
      emptyEl.style.display   = 'none';
    }

    try {
      // 1. Club teams (catalog of what to fan out to next).
      const clubRes = await this.auth.fetch(`/api/clubs/${this.clubId}?gender=all`);
      if (!clubRes.ok) throw new Error(`clubs HTTP ${clubRes.status}`);
      const clubBody = await clubRes.json();
      const club = clubBody?.data || clubBody;
      const teams = Array.isArray(club?.teams) ? club.teams : [];
      // Map: team_id → gender_category (used later to bucket matches
      // whose home/away is one of our teams).  DB values are the
      // plural forms 'mens' / 'womens' / 'boys' — see chip IDs below.
      const teamCat = new Map();
      for (const t of teams) {
        teamCat.set(Number(t.id), String(t.gender_category || '').toLowerCase());
      }
      this._teams = teams;

      if (!hasCache) {
        loadingEl.textContent =
          `Fetching schedule across ${teams.length} team${teams.length === 1 ? '' : 's'}…`;
      }

      // 2. Fan out matches per team.  Practices + pickups are stored
      //    in the `matches` table (differentiated by match_type_id),
      //    so `/api/matches/team/:id` already returns everything we
      //    need — no separate /api/events call.  Fetch failures for
      //    any single team are non-fatal.
      const perTeam = await Promise.all(teams.map(async (t) => {
        const matchesRes = await this.auth
          .fetch(`/api/matches/team/${t.id}?include_past=true`)
          .catch(() => null);
        const matches = await this._safeJson(matchesRes);
        return {
          teamId:   Number(t.id),
          matches:  Array.isArray(matches?.data)  ? matches.data  : (Array.isArray(matches)  ? matches  : []),
        };
      }));

      // 3. Merge + dedupe.  A match involving two of our teams shows
      //    up in both feeds — keep the first occurrence.
      const seenMatch = new Set();
      const rows = [];
      for (const bag of perTeam) {
        for (const m of bag.matches) {
          const id = Number(m.id);
          if (!id || seenMatch.has(id)) continue;
          seenMatch.add(id);
          rows.push(this._normaliseMatch(m, teamCat));
        }
      }
      this._rows = rows;
      this._lastSyncAt = new Date().toISOString();

      loadingEl.style.display = 'none';
      groupsEl.style.display  = 'block';
      this._consumePendingRestore();
      this._renderChips();
      this._renderSortPills();
      this._renderGroups();
      this._revealChrome();
      this._updateSyncBar();
    } catch (err) {
      console.error('schedule load failed', err);
      loadingEl.style.display = 'none';
      errorEl.style.display   = 'block';
      errorEl.textContent     = `Failed to load: ${err.message}`;
    }
  }

  async _safeJson(res) {
    if (!res || !res.ok) return null;
    try { return await res.json(); } catch (_) { return null; }
  }

  // Match row → uniform shape.  Preserves original fields so the
  // eventual click-through screen (match-detail) can consume them
  // directly.  Practices and pickups arrive on this same feed and
  // are distinguished by `match_type` (from match_types lookup).
  _normaliseMatch(m, teamCat) {
    const dt = m.event_date ? new Date(m.event_date) : null;
    const homeId = Number(m.home_team_id) || null;
    const awayId = Number(m.away_team_id) || null;
    // Category = whichever of our teams participates.  Home takes
    // priority; falls back to away if home is an opponent team.
    let cat = '';
    if (homeId && teamCat.has(homeId)) cat = teamCat.get(homeId);
    else if (awayId && teamCat.has(awayId)) cat = teamCat.get(awayId);
    // Kind from match_type name.  practice → 'practice', pickup →
    // 'pickup', everything else (league, custom, scrimmage, cup,
    // tournament) → 'match'.
    const mtype = String(m.match_type || '').toLowerCase();
    let kind = 'match';
    if (mtype === 'practice')    kind = 'practice';
    else if (mtype === 'pickup') kind = 'pickup';
    return {
      _kind:       kind,
      _category:   cat,
      _dt:         dt,
      _sortTime:   dt ? dt.getTime() : Number.POSITIVE_INFINITY,
      id:          Number(m.id),
      // `matchId` is retained for older consumers (e.g. anywhere that
      // still uses r.matchId directly).  New card wiring keys off
      // `r.id` instead so practices + pickups are also clickable.
      matchId:     Number(m.id),
      title:       m.title || '',
      homeName:    m.home_team_name || '',
      awayName:    m.away_team_name || '',
      venueName:   m.venue_name || '',
      status:      String(m.match_status || 'scheduled').toLowerCase(),
      homeScore:   m.home_team_score,
      awayScore:   m.away_team_score,
      competition: m.competition_name || '',
      manualOverride: !!m.manual_override,
    };
  }

  _consumePendingRestore() {
    const r = this._pendingRestore;
    if (!r) return;
    if (r.kind !== undefined)     this.kindFilter     = r.kind;
    if (r.category !== undefined) this.categoryFilter = r.category;
    if (r.dateRange)              this.dateRange      = r.dateRange;
    if (typeof r.search === 'string') {
      this._filter = r.search.toLowerCase();
      const search = this.find('#sched-search');
      if (search) search.value = r.search;
    }
    this._pendingRestore = null;
  }

  _revealChrome() {
    const filters = this.find('#sched-filters');
    const sort    = this.find('#sched-sort');
    const search  = this.find('#sched-search-wrap');
    if (filters) filters.style.display = 'flex';
    if (sort)    sort.style.display    = 'flex';
    if (search)  search.style.display  = 'block';
  }

  _updateSyncBar() {
    const el = this.find('#sched-sync-time');
    if (!el || !this._lastSyncAt) return;
    try {
      const t = new Date(this._lastSyncAt);
      el.textContent = `Last sync: ${t.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;
      el.style.color = 'var(--text-primary)';
      el.style.borderColor = 'var(--color-border)';
    } catch (_e) { /* leave placeholder */ }
  }

  // ── FilterBar (context pills) ────────────────────────────────────
  // Two rows:
  //   Kind:     [All] [⚽ Match] [🏃 Practice] [🎯 Pickup]
  //   Category: [👥 All] [👨 Men] [👩 Women] [👦 Boys] [👧 Girls]
  // Counts are computed across the ENTIRE row set (not filtered),
  // so numbers stay stable as chips are toggled — same rule Members
  // uses for its per-chip counters.
  _renderChips() {
    const el = this.find('#sched-filters');
    if (!el) return;

    const kindCount = (k) => this._rows.filter(r => r._kind === k).length;
    const catCount  = (c) => this._rows.filter(r => r._category === c).length;

    const kindChips = [
      { id: 'all',      label: 'All',         count: this._rows.length },
      { id: 'match',    label: '⚽ Match',    count: kindCount('match') },
      { id: 'practice', label: '🏃 Practice', count: kindCount('practice') },
      { id: 'pickup',   label: '🎯 Pickup',   count: kindCount('pickup') },
    ];
    const catChips = [
      { id: 'all',    label: '👥 All',   count: this._rows.length },
      { id: 'mens',   label: '👨 Men',   count: catCount('mens') },
      { id: 'womens', label: '👩 Women', count: catCount('womens') },
      { id: 'boys',   label: '👦 Boys',  count: catCount('boys') },
      { id: 'girls',  label: '👧 Girls', count: catCount('girls') },
    ];

    if (!this._filterBar) {
      this._filterBar = new FilterBar({ host: el });
    }
    this._filterBar.setRows([
      {
        name:     'kind',
        chips:    kindChips,
        selected: this.kindFilter || 'all',
        onSelect: (id) => {
          this.kindFilter = (id === 'all' || id == null) ? null : id;
          this._renderSortPills();
          this._renderGroups();
        },
      },
      {
        name:     'category',
        chips:    catChips,
        selected: this.categoryFilter || 'all',
        onSelect: (id) => {
          this.categoryFilter = (id === 'all' || id == null) ? null : id;
          this._renderSortPills();
          this._renderGroups();
        },
      },
    ]);
  }

  // ── Sort + status-filter + date-range pill row ───────────────────
  _renderSortPills() {
    const el = this.find('#sched-sort');
    if (!el) return;
    if (!this._rows.length) { el.style.display = 'none'; return; }
    el.style.display = 'flex';

    const isDate     = this._sort === 'date_asc' || this._sort === 'date_desc';
    const dateArrow  = this._sort === 'date_desc' ? ' ↓' : ' ↑';
    const active = (on) => on
      ? 'background:var(--color-primary, #2563eb); color:#fff; border-color:transparent;'
      : 'background:var(--bg-secondary); color:var(--text-primary);';
    const flagActive = (on) => on
      ? 'background:#7f1d1d; color:#fecaca; border-color:#b91c1c;'
      : 'background:var(--bg-secondary); color:var(--text-primary);';
    const rangeActive = (on) => on
      ? 'background:#1e3a8a; color:#dbeafe; border-color:#3b82f6;'
      : 'background:var(--bg-secondary); color:var(--text-primary);';
    const base = 'padding:5px 12px; border-radius:999px; cursor:pointer;'
      + ' font-weight:600; font-size:0.8rem; border:1px solid var(--color-border);';

    // Counts for the status-filter chips — scoped to the current
    // kind + category (like MembersScreen scopes to category).
    const scoped = this._rows.filter(r => this._passesContext(r));
    const overrideCount = scoped.filter(r => r.manualOverride).length;
    const noVenueCount  = scoped.filter(r => !r.venueName).length;

    el.innerHTML = `
      <span style="opacity:0.6; font-size:0.8rem; margin-right:4px;">When:</span>
      <button data-range="upcoming" style="${base} ${rangeActive(this.dateRange === 'upcoming')}">
        ⏭ Upcoming
      </button>
      <button data-range="past" style="${base} ${rangeActive(this.dateRange === 'past')}">
        ⏮ Past
      </button>
      <button data-range="all" style="${base} ${rangeActive(this.dateRange === 'all')}">
        ♾ All
      </button>

      <span style="opacity:0.4; margin:0 4px;">│</span>

      <span style="opacity:0.6; font-size:0.8rem; margin-right:4px;">Sort:</span>
      <button data-sort="date_asc" title="Sort by date — click again to flip direction"
              style="${base} ${active(isDate)}">
        📅 Date${isDate ? dateArrow : ''}
      </button>
      <button data-sort="venue_asc"
              style="${base} ${active(this._sort === 'venue_asc')}">
        🏟️ Venue
      </button>
      <button data-sort="home_asc"
              style="${base} ${active(this._sort === 'home_asc')}">
        ⚽ Home team
      </button>
      <button data-sort="status_asc"
              style="${base} ${active(this._sort === 'status_asc')}">
        ⚡ Status
      </button>

      <span style="opacity:0.4; margin:0 4px;">│</span>

      <span style="opacity:0.6; font-size:0.8rem; margin-right:4px;">Filter:</span>
      <button data-flag="override" title="Manual override — upstream league sync cannot overwrite these"
              style="${base} ${flagActive(this._flagOverride)}">
        📼 Manual (${overrideCount})
      </button>
      <button data-flag="no-venue" title="Missing venue — needs assigning"
              style="${base} ${flagActive(this._flagNoVenue)}">
        ⚠️ No venue (${noVenueCount})
      </button>
    `;
  }

  // Predicate: row passes the context chips (kind + category).
  // Used for scoped counts AND as the first-pass filter in _renderGroups.
  _passesContext(r) {
    if (this.kindFilter     && r._kind     !== this.kindFilter)     return false;
    if (this.categoryFilter && r._category !== this.categoryFilter) return false;
    return true;
  }

  _passesStatusFlags(r) {
    if (!this._flagOverride && !this._flagNoVenue) return true;
    if (this._flagOverride && r.manualOverride)    return true;
    if (this._flagNoVenue  && !r.venueName)        return true;
    return false;
  }

  _passesDateRange(r) {
    if (this.dateRange === 'all')     return true;
    if (!r._dt)                       return this.dateRange === 'upcoming';
    const now = Date.now();
    if (this.dateRange === 'upcoming') return r._sortTime >= now - 6 * 3600 * 1000; // 6h grace
    if (this.dateRange === 'past')     return r._sortTime <  now - 6 * 3600 * 1000;
    return true;
  }

  _passesSearch(r) {
    const q = this._filter;
    if (!q) return true;
    const hay = [r.title, r.homeName, r.awayName, r.venueName, r.competition]
      .map(v => String(v || '').toLowerCase()).join(' ');
    return hay.includes(q);
  }

  _sortRows(rows) {
    const arr = rows.slice();
    const strCmp = (a, b) => String(a || '').toLowerCase()
      .localeCompare(String(b || '').toLowerCase());
    const dateAsc = (a, b) => (a._sortTime - b._sortTime) || strCmp(a.homeName, b.homeName);
    const key = this._sort || 'date_asc';
    if (key === 'date_desc') arr.sort((a, b) => (b._sortTime - a._sortTime) || strCmp(a.homeName, b.homeName));
    else if (key === 'venue_asc') arr.sort((a, b) => strCmp(a.venueName, b.venueName) || dateAsc(a, b));
    else if (key === 'home_asc')  arr.sort((a, b) => strCmp(a.homeName,  b.homeName)  || dateAsc(a, b));
    else if (key === 'status_asc') arr.sort((a, b) => strCmp(a.status,   b.status)    || dateAsc(a, b));
    else arr.sort(dateAsc);
    return arr;
  }

  // ── Date bucket grouping ─────────────────────────────────────────
  // Buckets, in render order:
  //   Today · Tomorrow · This week · Next week · Later · Past
  // "Past" appears at the bottom, matches the natural mental scroll
  // direction (upcoming on top, history below).
  _bucketFor(dt) {
    if (!dt) return 'Undated';
    const now = new Date();
    const startOfDay = (d) => { const x = new Date(d); x.setHours(0,0,0,0); return x; };
    const today = startOfDay(now);
    const tomorrow = new Date(today); tomorrow.setDate(tomorrow.getDate() + 1);
    const dayAfterTomorrow = new Date(today); dayAfterTomorrow.setDate(dayAfterTomorrow.getDate() + 2);
    const endOfThisWeek = new Date(today);
    // Sunday=0..Saturday=6.  End of week = next Sunday 00:00.
    endOfThisWeek.setDate(today.getDate() + (7 - today.getDay()));
    const endOfNextWeek = new Date(endOfThisWeek);
    endOfNextWeek.setDate(endOfNextWeek.getDate() + 7);

    const d = startOfDay(dt);
    if (d < today)              return 'Past';
    if (d.getTime() === today.getTime()) return 'Today';
    if (d.getTime() === tomorrow.getTime()) return 'Tomorrow';
    if (d < endOfThisWeek)      return 'This week';
    if (d < endOfNextWeek)      return 'Next week';
    return 'Later';
  }

  _bucketOrder() {
    // Order for the "upcoming" and "all" views.
    if (this.dateRange === 'past') return ['Past', 'Undated'];
    return ['Today', 'Tomorrow', 'This week', 'Next week', 'Later', 'Undated', 'Past'];
  }

  // ── Card grid ────────────────────────────────────────────────────
  _renderGroups() {
    const groupsEl = this.find('#sched-groups');
    const emptyEl  = this.find('#sched-empty');
    if (!groupsEl) return;

    // Filter pipeline (order matters — cheapest first).
    let rows = this._rows
      .filter(r => this._passesContext(r))
      .filter(r => this._passesDateRange(r))
      .filter(r => this._passesStatusFlags(r))
      .filter(r => this._passesSearch(r));
    rows = this._sortRows(rows);

    // Bucket + render.
    const buckets = new Map();
    for (const r of rows) {
      const b = this._bucketFor(r._dt);
      if (!buckets.has(b)) buckets.set(b, []);
      buckets.get(b).push(r);
    }

    const order = this._bucketOrder();
    const html = order
      .filter(b => buckets.has(b))
      .map(b => {
        const list = buckets.get(b);
        const cards = list.map(r => this._renderCard(r)).join('');
        return `
          <section style="margin-bottom: var(--space-5);">
            <h3 style="margin: 0 0 var(--space-3); opacity:0.9;">
              ${this._esc(b)}
              <span style="opacity:0.6; font-weight:400; font-size:0.85rem;">(${list.length})</span>
            </h3>
            <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: var(--space-3);">
              ${cards}
            </div>
          </section>
        `;
      }).join('');

    groupsEl.innerHTML = html || '';
    if (!rows.length) {
      groupsEl.style.display = 'none';
      emptyEl.style.display  = 'block';
    } else {
      groupsEl.style.display = 'block';
      emptyEl.style.display  = 'none';
    }
    this._updateSubtitle(rows.length);
  }

  _renderCard(r) {
    // Kind badge — inline chip with a colour that matches the kind
    // filter chip so the visual mapping is 1:1.
    const kindStyle = {
      match:    { icon: '⚽', label: 'Match',    color: '#2563eb' },
      practice: { icon: '🏃', label: 'Practice', color: '#14b8a6' },
      pickup:   { icon: '🎯', label: 'Pickup',   color: '#10b981' },
    }[r._kind] || { icon: '📅', label: r._kind || 'Event', color: '#6b7280' };
    const kindChip = `
      <span style="display:inline-flex; align-items:center; gap:4px;
                   padding:2px 8px; border-radius:999px; font-size:0.72rem; font-weight:600;
                   background:${kindStyle.color}22; color:${kindStyle.color};
                   border:1px solid ${kindStyle.color}66;">
        ${kindStyle.icon} ${kindStyle.label}
      </span>`;

    // Status chip — small colour cue for the current match state.
    const statusStyle = {
      scheduled:    { label: 'Scheduled',   color: '#6b7280' },
      in_progress:  { label: 'In progress', color: '#f59e0b' },
      completed:    { label: 'Final',       color: '#10b981' },
      postponed:    { label: 'Postponed',   color: '#ef4444' },
    }[r.status] || { label: r.status || '—', color: '#6b7280' };
    const statusChip = `
      <span style="display:inline-flex; align-items:center; padding:2px 8px;
                   border-radius:999px; font-size:0.7rem; font-weight:600;
                   background:${statusStyle.color}22; color:${statusStyle.color};
                   border:1px solid ${statusStyle.color}66;">
        ${statusStyle.label}
      </span>`;

    const overrideChip = r.manualOverride
      ? `<span style="display:inline-flex; padding:2px 8px; border-radius:999px;
              font-size:0.68rem; font-weight:600; background:#7f1d1d;
              color:#fecaca; border:1px solid #b91c1c;">📼 Manual</span>`
      : '';

    // Date + time line.
    const dateLine = r._dt
      ? r._dt.toLocaleDateString([], { weekday: 'short', month: 'short', day: 'numeric' })
      : 'Date TBD';
    const timeLine = r._dt
      ? r._dt.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      : '';

    // Score line (matches only, when completed).
    const scoreLine = (r._kind === 'match' && r.status === 'completed')
      ? `<div style="font-size:1rem; font-weight:700; margin-top:2px;">
           ${r.homeScore ?? '-'} &ndash; ${r.awayScore ?? '-'}
         </div>`
      : '';

    // Matchup line — home vs away for matches; single team for practices.
    let matchup;
    if (r._kind === 'match') {
      matchup = `
        <div style="font-size:0.92rem; line-height:1.35;">
          <div style="font-weight:600;">${this._esc(r.homeName || 'TBD')}</div>
          <div style="opacity:0.5; font-size:0.75rem; margin: 1px 0;">vs</div>
          <div style="font-weight:600;">${this._esc(r.awayName || 'TBD')}</div>
        </div>`;
    } else {
      matchup = `
        <div style="font-size:0.92rem; font-weight:600;">
          ${this._esc(r.title || kindStyle.label)}
        </div>
        ${r.homeName ? `<div style="font-size:0.78rem; opacity:0.7;">${this._esc(r.homeName)}</div>` : ''}
      `;
    }

    const venueLine = r.venueName
      ? `<div style="font-size:0.78rem; opacity:0.75;">📍 ${this._esc(r.venueName)}</div>`
      : `<div style="font-size:0.78rem; color:#f59e0b;">⚠ No venue</div>`;

    // Every card is clickable — schedule-item screen handles matches,
    // practices, and pickups uniformly.  The row's `id` is the match
    // primary key (practices + pickups are matches under the hood).
    const itemId = Number(r.id) || 0;

    return `
      <div class="sched-card"
           ${itemId ? `data-item-id="${itemId}"` : ''}
           style="background: var(--bg-secondary);
                  border-radius: var(--radius-md); padding: var(--space-3);
                  border: 1px solid var(--color-border);
                  display:flex; flex-direction:column; gap:6px;
                  ${itemId ? 'cursor:pointer;' : ''}">
        <div style="display:flex; align-items:center; gap:6px; flex-wrap:wrap;">
          ${kindChip}
          ${statusChip}
          ${overrideChip}
        </div>
        <div style="display:flex; align-items:baseline; justify-content:space-between; gap:6px;">
          <div style="font-weight:700; font-size:0.9rem;">${this._esc(dateLine)}</div>
          <div style="opacity:0.75; font-size:0.85rem;">${this._esc(timeLine)}</div>
        </div>
        ${matchup}
        ${scoreLine}
        ${venueLine}
        ${r.competition ? `<div style="font-size:0.72rem; opacity:0.55;">🏆 ${this._esc(r.competition)}</div>` : ''}
      </div>
    `;
  }

  _updateSubtitle(count) {
    const el = this.find('#sched-subtitle');
    if (!el) return;
    const parts = [`${count} event${count === 1 ? '' : 's'}`];
    if (this.kindFilter)     parts.push({ match:'matches', practice:'practices', pickup:'pickups' }[this.kindFilter] || this.kindFilter);
    if (this.categoryFilter) parts.push({ men:'Men', women:'Women', boys:'Boys', girls:'Girls' }[this.categoryFilter] || this.categoryFilter);
    const rangeLabel = { upcoming: 'Upcoming', past: 'Past', all: 'All time' }[this.dateRange] || '';
    if (rangeLabel) parts.push(rangeLabel);
    parts.push('· click a match card to open it');
    el.textContent = parts.join(' · ');
  }

  // ── Back-nav snapshot ────────────────────────────────────────────
  _returnParams() {
    return {
      clubId:   this.clubId,
      clubName: this.clubName,
      restore:  {
        kind:      this.kindFilter,
        category:  this.categoryFilter,
        dateRange: this.dateRange,
        search:    this._filter,
      },
    };
  }

  _snapshotHistoryState() {
    try {
      const cur = window.history.state || {};
      window.history.replaceState({
        ...cur,
        screen: cur.screen || 'admin-schedule',
        params: { ...(cur.params || {}), ...this._returnParams() },
      }, '', '#admin-schedule');
    } catch (_) { /* replaceState is non-throwable in practice */ }
  }

  _esc(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }
}
