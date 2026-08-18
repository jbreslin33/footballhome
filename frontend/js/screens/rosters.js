// RostersScreen ───────────────────────────────────────────────────────────
//
// Standardized single-screen entry point for every club roster board.
// Follows the same FilterBar pattern as Members + Payments (2026-07-13
// directive: "condense them into 1 screen like the others").
//
// Behaviour (2026-08-16 rewrite — "always show Unassigned, side by side
// with Teams, each independently filterable")
// ─────────────────────────────────────────────────────────────────────
// Two panels, always both visible:
//   Unassigned (left)  — people with no active team_persons row, for
//                          whichever category pill (Mens/Womens/Boys/
//                          Girls) is selected on THIS panel.
//   Teams (right)       — team columns/cards for whichever category
//                          pill is selected on THIS panel, plus its own
//                          Active/Inactive toggle.
// The two pills are fully independent — Unassigned:Boys can sit next to
// Teams:Mens at the same time. This replaces the old model where a
// single top-level chip (All/Mens/Womens/Boys/Girls) swapped the whole
// content area, and Unassigned was just the leftmost column INSIDE
// whichever board that chip mounted.
//
// Rather than reimplement 2500+ lines of column layout, dues badges,
// drag/drop, and LA sync, this screen COMPOSES the existing per-club
// screens (BoysRosterScreen, MensRosterScreen, GirlsRosterScreen) by
// mounting their rendered <div> into a shared host and forwarding
// `onEnter` / `onLeave` — same technique the old 'All' composite used.
// Each of those boards already builds its columns as [Unassigned, ...
// team columns] (see renderRoster in boys-roster.js/mens-roster.js); the
// only change needed there was a `columnScope` filter ('unassigned' |
// 'teams' | undefined) so a panel can ask for just its half instead of
// the whole board. Trade-off: showing the same category on both panels
// mounts TWO independent instances (two LA syncs, two fetches) rather
// than sharing one — same class of double-fetch the old 'All' composite
// already accepted for boys+mens, just now possible for any category.
//
// Category → panel content mapping
// ─────────────────────────────────
//   Mens   → MensRosterScreen, columnScope='unassigned'|'teams'
//   Boys   → BoysRosterScreen, columnScope='unassigned'|'teams'
//   Girls  → GirlsRosterScreen (same data as Boys, girls play on boys
//             teams — this only differs from Boys in a header label,
//             which gets stripped when embedded; see the caption text
//             instead), columnScope='unassigned'|'teams'
//   Womens → No LA program feeds women's teams, so there's no board to
//             reuse. Teams:Womens reads GET /api/clubs/:id?gender=womens
//             (see _mountWomensSection, migration 285) and links into
//             TeamHubScreen for roster edits. Unassigned:Womens has no
//             equivalent data source yet — shows an honest placeholder.
//
// Deep-link
// ─────────
// `onEnter({ unassignedPill, teamsPill })` lets other screens push a
// specific default per panel (see team-dashboard.js's "Manage roster"
// button). Both default to 'mens'.
class RostersScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.navigation = navigation;
    this.auth = auth;
    this.unassignedPill = 'mens';
    this.teamsPill = 'mens';
    this.teamsIncludeInactive = false;
    this._unassignedFilterBar = null;
    this._teamsFilterBar = null;
    // Track every child instance currently mounted across BOTH panels
    // (not just one) so onExit/onLeave and the Active/Inactive toggle
    // can walk them uniformly.
    this._mountedChildren = [];
    // Lazy-instantiated sub-screens, one cache per panel — a category
    // shown on both panels at once needs two separate instances (each
    // owns its own DOM/fetch), never one shared between them.
    this._unassignedInstances = { mens: null, boys: null, girls: null };
    this._teamsInstances      = { mens: null, boys: null, girls: null };
    // In-flight fetch generation for the Women's Club Teams-panel data
    // (the team cards + rosters, see _mountWomensSection).
    this._womensFetchSeq = 0;
    // Same, for the Unassigned:Womens list (see _loadWomensUnassignedList)
    // — separate from _womensFetchSeq since the two panels can be
    // in-flight independently (different pill, same gender).
    this._womensUnassignedSeq = 0;
    // Guards the "N registered, not yet on a team" note under the Teams
    // panel (see _setTeamsUnassignedNote) — bumped on every
    // _mountTeamsPanel call so a stale async count (from either a
    // MensRosterScreen/BoysRosterScreen onDataLoaded callback, or the
    // Womens la-pool fetch) can't land after a pill flip.
    this._teamsNoteSeq = 0;
  }

  render() {
    // ScreenManager wipes container.innerHTML on every transition, so
    // any DOM references cached on the instance (like a FilterBar bound
    // to the previous mount's host element) are now detached garbage.
    // Reset them here so the next _build*Pills() call constructs a
    // fresh one against the freshly-rendered host.
    this._unassignedFilterBar = null;
    this._teamsFilterBar = null;
    this._mountedChildren = [];

    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .rs-panel {
          background: var(--bg-secondary, #111827);
          border: 1px solid var(--border-color, #374151);
          border-radius: 10px;
          padding: var(--space-3);
          min-width: 0;
        }
        .rs-panel-title {
          margin: 0 0 var(--space-2);
          font-size: 1rem;
          font-weight: 700;
        }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🎽 Team Players</h1>
        <p class="subtitle" id="rs-subtitle">Unassigned on the left, team rosters on the right — filter each side independently</p>
      </div>
      <div style="padding: var(--space-3) var(--space-2); display:flex; gap: var(--space-4); align-items:flex-start; flex-wrap:wrap;">
        <section class="rs-panel" style="flex: 0 0 340px; max-width: 100%;">
          <h2 class="rs-panel-title">📦 Unassigned</h2>
          <div id="rs-unassigned-pills" style="margin-bottom: var(--space-2);"></div>
          <div id="rs-unassigned-caption" style="font-size:0.75rem; opacity:0.6; margin-bottom:var(--space-2);"></div>
          <div id="rs-unassigned-body" style="min-height: 120px;">
            <div style="padding: var(--space-3); opacity: 0.6; font-size: 0.9rem;">Loading…</div>
          </div>
        </section>
        <section class="rs-panel" style="flex: 1 1 480px; min-width: 0;">
          <h2 class="rs-panel-title">👥 Teams</h2>
          <div id="rs-teams-pills" style="margin-bottom: var(--space-2);"></div>
          <div id="rs-teams-caption" style="font-size:0.75rem; opacity:0.6; margin-bottom:var(--space-2);"></div>
          <div id="rs-teams-unassigned-note" style="margin-bottom:var(--space-2);"></div>
          <div id="rs-teams-body" style="min-height: 200px;">
            <div style="padding: var(--space-3); opacity: 0.6; font-size: 0.9rem;">Loading…</div>
          </div>
        </section>
      </div>
    `;
    this.element = div;

    div.addEventListener('click', (e) => {
      const back = e.target.closest('.back-btn');
      if (back && back.closest('.screen-header')?.parentElement === div) {
        e.preventDefault();
        this.navigation.goBack();
        return;
      }
    });

    return div;
  }

  async onEnter(params) {
    const allowed = new Set(['mens', 'womens', 'boys', 'girls']);
    if (params && typeof params.unassignedPill === 'string' && allowed.has(params.unassignedPill)) {
      this.unassignedPill = params.unassignedPill;
    }
    if (params && typeof params.teamsPill === 'string' && allowed.has(params.teamsPill)) {
      this.teamsPill = params.teamsPill;
    }
    // clubId/clubName accepted for parity with the old admin-club-teams
    // entry point this screen absorbed — every sub-screen's endpoint
    // (/api/mens-roster, /api/boys-roster, ...) is already single-club
    // scoped server-side, so there's nothing to thread the id into yet.
    this.clubId = params?.clubId ?? this.navigation.context?.club?.id ?? 134;
    this.clubName = params?.clubName ?? 'Lighthouse';

    this.teamsIncludeInactive = false;
    await this._ensureCoachedTeamIds();
    this._buildUnassignedPills();
    this._buildTeamsPills();
    this._mountUnassignedPanel();
    this._mountTeamsPanel();
  }

  // Coach-scoped move rights (CoachTeamCard, components/TeamCard.js) read
  // navigation.context.coachedTeamIds — populate it once per entry so
  // every mounted board (Mens/Boys/Girls, on either panel) sees the same
  // list without each re-fetching it. Admin doesn't need this at all —
  // their card class derives "every column on this board" straight from
  // whatever board it's rendering, no separate fetch required.
  async _ensureCoachedTeamIds() {
    const role = (this.navigation?.context?.role || this.auth?.user?.role || '').toString().toLowerCase();
    if (role !== 'coach') return;
    try {
      const res = await this.auth.fetch('/api/auth/coach/teams');
      if (!res.ok) return;
      const body = await res.json();
      const teams = body?.data || [];
      this.navigation.context.coachedTeamIds = teams.map((t) => parseInt(t.id, 10)).filter((id) => !Number.isNaN(id));
    } catch (err) {
      console.error('[rosters] failed to load coached team ids:', err);
      this.navigation.context.coachedTeamIds = [];
    }
  }

  // ScreenManager's lifecycle hook is `onExit` (not `onLeave`).  We
  // also drop the cached FilterBars here so anything still holding a
  // reference doesn't accidentally paint into the old host after we've
  // been detached.
  onExit() {
    this._unmountAll();
    this._unassignedFilterBar = null;
    this._teamsFilterBar = null;
  }

  // ── Category pills, one FilterBar per panel ─────────────────────────
  _categoryChips() {
    return [
      { id: 'mens',   label: '👨 Mens'   },
      { id: 'womens', label: '👩 Womens' },
      { id: 'boys',   label: '👦 Boys'   },
      { id: 'girls',  label: '👧 Girls'  },
    ];
  }

  _buildUnassignedPills() {
    const host = this.find('#rs-unassigned-pills');
    if (!host) return;
    if (!this._unassignedFilterBar) this._unassignedFilterBar = new FilterBar({ host });
    this._unassignedFilterBar.setRows([{
      name:     'unassigned-category',
      chips:    this._categoryChips(),
      selected: this.unassignedPill,
      onSelect: (id) => {
        if (id == null || id === this.unassignedPill) return;
        this.unassignedPill = id;
        this._buildUnassignedPills();
        this._mountUnassignedPanel();
      },
    }]);
  }

  _buildTeamsPills() {
    const host = this.find('#rs-teams-pills');
    if (!host) return;
    if (!this._teamsFilterBar) this._teamsFilterBar = new FilterBar({ host });
    this._teamsFilterBar.setRows([
      {
        name:     'teams-category',
        chips:    this._categoryChips(),
        selected: this.teamsPill,
        onSelect: (id) => {
          if (id == null || id === this.teamsPill) return;
          this.teamsPill = id;
          this._buildTeamsPills();
          this._mountTeamsPanel();
        },
      },
      {
        // is_active is the source of truth for "does this team show" —
        // independent of the category pill above, so it's its own row
        // (no `clears`). Scoped to the Teams panel only — Womens'
        // ClubController fetch also accepts includeInactive, threaded
        // through in _mountWomensSection.
        name:     'teams-status',
        chips: [
          { id: 'active',   label: 'Active' },
          { id: 'inactive', label: 'Inactive' },
        ],
        selected: this.teamsIncludeInactive ? 'inactive' : 'active',
        onSelect: (id) => {
          if (id == null) return;
          this.teamsIncludeInactive = id === 'inactive';
          if (this.teamsPill === 'womens') {
            this._mountWomensSection(this.find('#rs-teams-body'));
            return;
          }
          for (const child of this._mountedChildren) {
            if (child && child.columnScope === 'teams' && typeof child.setIncludeInactive === 'function') {
              child.setIncludeInactive(this.teamsIncludeInactive);
            }
          }
        },
      },
    ]);
  }

  // ── Sub-screen mounting ───────────────────────────────────────────
  //
  // Instantiate on first use, cache thereafter (per panel — see the
  // two-cache doc in the constructor). Cached instances keep their own
  // DOM around when we unmount them — cheaper than a full rebuild on
  // every pill flip.
  _instanceForPanel(cache, pill) {
    if (pill === 'mens') {
      if (!cache.mens) cache.mens = new MensRosterScreen(this.navigation, this.auth);
      return cache.mens;
    }
    if (pill === 'boys') {
      if (!cache.boys) cache.boys = new BoysRosterScreen(this.navigation, this.auth);
      return cache.boys;
    }
    if (pill === 'girls') {
      if (!cache.girls) cache.girls = new GirlsRosterScreen(this.navigation, this.auth);
      return cache.girls;
    }
    return null;
  }

  // Small caption under each panel's pills — without a header (stripped
  // by _mountChildInto) Boys and Girls would otherwise render byte-for-
  // byte identical content with no way to tell which one is selected
  // besides the pill highlight.
  _captionForPill(pill) {
    return {
      mens:   'Lighthouse Mens Club — LeagueApps APSL + Liga 1',
      womens: 'Tri County Women',
      boys:   'Boys + Girls Club — youth, LeagueApps',
      girls:  'Same roster as Boys — girls play on boys teams',
    }[pill] || '';
  }

  _mountUnassignedPanel() {
    const host = this.find('#rs-unassigned-body');
    if (!host) return;
    const caption = this.find('#rs-unassigned-caption');
    if (caption) caption.textContent = this._captionForPill(this.unassignedPill);

    if (this.unassignedPill === 'womens') {
      this._loadWomensUnassignedList(host);
      return;
    }
    const child = this._instanceForPanel(this._unassignedInstances, this.unassignedPill);
    if (!child) {
      host.innerHTML = `<div style="padding: var(--space-3); color: var(--color-error);">Unknown category: ${this.unassignedPill}</div>`;
      return;
    }
    child.columnScope = 'unassigned';
    this._mountChildInto(host, child, `unassigned (${this.unassignedPill})`);
  }

  _mountTeamsPanel() {
    const host = this.find('#rs-teams-body');
    if (!host) return;
    const caption = this.find('#rs-teams-caption');
    if (caption) caption.textContent = this._captionForPill(this.teamsPill);

    const seq = ++this._teamsNoteSeq;
    this._setTeamsUnassignedNote(null);

    if (this.teamsPill === 'womens') {
      this._mountWomensSection(host);
      this._loadWomensUnassignedNote(seq);
      return;
    }
    const child = this._instanceForPanel(this._teamsInstances, this.teamsPill);
    if (!child) {
      host.innerHTML = `<div style="padding: var(--space-3); color: var(--color-error);">Unknown category: ${this.teamsPill}</div>`;
      return;
    }
    child.columnScope = 'teams';
    if (typeof child.setIncludeInactive === 'function') {
      child.includeInactive = this.teamsIncludeInactive;
    }
    // Mens/Boys/Girls already compute an LA-driven Unassigned count
    // server-side (data.unassignedCount) — mirror it here so the Teams
    // panel shows the same "not yet on a team" signal Womens gets from
    // the la-pool fetch below, instead of only Mens/Boys/Girls' own
    // Unassigned column knowing about it.
    child.onDataLoaded = (data) => {
      if (seq !== this._teamsNoteSeq) return; // pill flipped since mount
      this._setTeamsUnassignedNote(data?.unassignedCount, this.teamsPill);
    };
    this._mountChildInto(host, child, `teams (${this.teamsPill})`);
  }

  // "N registered, not yet on a team" note under the Teams panel caption.
  // `count == null` clears it (used while a fetch is in flight or on
  // error). `pill` is optional — when given, the note becomes a button
  // that jumps the Unassigned panel to the same category so admin can
  // act on it immediately.
  _setTeamsUnassignedNote(count, pill) {
    const el = this.find('#rs-teams-unassigned-note');
    if (!el) return;
    if (count == null || count <= 0) {
      el.innerHTML = '';
      return;
    }
    const label = `⚠ ${count} registered, not yet on a team`;
    if (!pill) {
      el.innerHTML = `<span style="font-size:0.78rem; color:#facc15;">${this.escapeHtml(label)}</span>`;
      return;
    }
    el.innerHTML = `<button type="button" data-jump-unassigned="${pill}"
      style="font-size:0.78rem; color:#facc15; background:none; border:1px dashed #facc1588; border-radius:6px; padding:2px 8px; cursor:pointer;">
      ${this.escapeHtml(label)} — see Unassigned →
    </button>`;
    el.querySelector('[data-jump-unassigned]')?.addEventListener('click', () => {
      if (this.unassignedPill === pill) return;
      this.unassignedPill = pill;
      this._buildUnassignedPills();
      this._mountUnassignedPanel();
    });
  }

  // Womens has no board to reuse (see _mountWomensSection), so its
  // "not yet on a team" count comes straight from the same LA-pool
  // endpoint the Lineups screen already uses for the Womens gender
  // toggle (GET /api/clubs/:id/la-pool?gender=womens) — a person counts
  // as unassigned here when they're an active LA registrant with an
  // empty onRosterOn (no active team_persons row on any club team).
  async _loadWomensUnassignedNote(seq) {
    try {
      const res = await this.auth.fetch(`/api/clubs/${this.clubId}/la-pool?gender=womens`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const body = await res.json();
      if (seq !== this._teamsNoteSeq) return; // stale after a pill flip
      const persons = Array.isArray(body?.persons) ? body.persons : [];
      const count = persons.filter((p) => Array.isArray(p.onRosterOn) && p.onRosterOn.length === 0).length;
      this._setTeamsUnassignedNote(count, 'womens');
    } catch (err) {
      console.error('[rosters] womens la-pool count failed:', err);
    }
  }

  // Unassigned:Womens — real list of active Women's Club LA registrants
  // with no active team_persons row on any womens team, each with an
  // "Add to <team>" action. Same source (`la-pool?gender=womens`) and
  // same unassigned test (`onRosterOn` empty) as
  // _loadWomensUnassignedNote's count, so the two always agree. `teams`
  // comes from the same response (Section 1 of LaPool::run — every
  // team_eligible_genders='womens' row), so a second womens team shows
  // up here with no code change.
  async _loadWomensUnassignedList(host) {
    if (!host) return;
    const seq = ++this._womensUnassignedSeq;
    host.innerHTML = `<div style="padding: var(--space-3); opacity: 0.6; font-size: 0.9rem;">Loading…</div>`;
    try {
      const res = await this.auth.fetch(`/api/clubs/${this.clubId}/la-pool?gender=womens`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const body = await res.json();
      if (seq !== this._womensUnassignedSeq) return; // stale after a pill flip

      const teams = Array.isArray(body?.teams) ? body.teams : [];
      const persons = (Array.isArray(body?.persons) ? body.persons : [])
        .filter((p) => Array.isArray(p.onRosterOn) && p.onRosterOn.length === 0);

      if (!persons.length) {
        host.innerHTML = `
          <div style="padding: var(--space-3); opacity: 0.6; font-size: 0.85rem;">
            No unassigned Women's Club registrants — everyone active is on a team.
          </div>
        `;
        return;
      }

      const rowFor = (p) => {
        const name = this.escapeHtml(`${p.firstName || ''} ${p.lastName || ''}`.trim() || '(no name)');
        // `personId` is null when this LA registrant has no matching
        // persons row yet (see LaPool.cpp `unmatched`) — nothing to
        // POST a team_persons row against until that's linked.
        if (p.personId == null || !teams.length) {
          const reason = p.personId == null ? 'unmatched LA registrant, no linked profile' : 'no active Womens team to add to';
          return `
            <div style="display:flex; align-items:center; justify-content:space-between; gap:8px; padding:8px 10px; border-radius:8px; background:var(--bg-tertiary, #1f2937); border:1px solid var(--border-color, #374151); margin-bottom:6px;">
              <span style="font-size:0.88rem;">${name}</span>
              <span style="font-size:0.72rem; opacity:0.6;">${this.escapeHtml(reason)}</span>
            </div>
          `;
        }
        const buttons = teams.map((t) => `
          <button type="button" class="btn btn-secondary" data-add-womens-person="${p.personId}" data-add-womens-team="${t.id}" style="font-size:0.78rem; padding:3px 10px;">
            + ${this.escapeHtml(t.shortLabel || t.name || 'Team')}
          </button>
        `).join('');
        return `
          <div style="display:flex; align-items:center; justify-content:space-between; gap:8px; padding:8px 10px; border-radius:8px; background:var(--bg-tertiary, #1f2937); border:1px solid var(--border-color, #374151); margin-bottom:6px;">
            <span style="font-size:0.88rem;">${name}</span>
            <span style="display:flex; gap:6px; flex-wrap:wrap;">${buttons}</span>
          </div>
        `;
      };

      host.innerHTML = `<div style="padding: var(--space-2) 0;">${persons.map(rowFor).join('')}</div>`;
      host.querySelectorAll('[data-add-womens-person]').forEach((btn) => {
        btn.addEventListener('click', () => this._addWomensToTeam(btn, host));
      });
    } catch (err) {
      console.error('[rosters] womens unassigned list failed:', err);
      if (seq !== this._womensUnassignedSeq) return;
      host.innerHTML = `
        <div style="padding: var(--space-4); color: var(--color-error);">
          Could not load unassigned Women's Club registrants: ${this.escapeHtml(err && err.message ? err.message : String(err))}
        </div>
      `;
    }
  }

  // Adds one Unassigned:Womens person to a team via the same generic
  // team-roster endpoint TeamHubScreen/coach flows use — no womens-
  // specific backend needed (see TeamRosterController::handleSetMembership).
  // On success, re-fetches the Unassigned list (the person drops off)
  // and, if the Teams panel is also showing Womens, refreshes it too so
  // the new roster spot and the "N registered" note both update.
  async _addWomensToTeam(btn, host) {
    const personId = btn.dataset.addWomensPerson;
    const teamId   = btn.dataset.addWomensTeam;
    if (!personId || !teamId) return;
    btn.disabled = true;
    btn.style.opacity = '0.4';
    try {
      const res = await this.auth.fetch(`/api/teams/${teamId}/roster/${personId}`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ action: 'add' }),
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      this._loadWomensUnassignedList(host);
      if (this.teamsPill === 'womens') this._mountTeamsPanel();
    } catch (err) {
      console.error('[rosters] add womens to team failed:', err);
      btn.disabled = false;
      btn.style.opacity = '';
      alert(`Could not add player: ${err.message}`);
    }
  }

  // Women's Club roster — the Teams panel's Womens pill. There's no LA
  // program feeding women's teams (Boys/Girls/Mens all sync from
  // LeagueApps programs; women's teams are club-scoped only, managed by
  // hand via team_persons), so this can't reuse the LA-backed board
  // machinery those pills share. Instead it reads the same club-scoped
  // team+roster data the admin Teams screen's Women's pill already
  // serves (GET /api/clubs/:id?gender=womens — see
  // ClubController::handleGetClubDetail, migration 285) and links each
  // team into TeamHubScreen for actual roster edits, same as clicking a
  // team card on that screen does.
  async _mountWomensSection(host) {
    if (!host) return;
    // `host` (#rs-teams-body) persists across pill flips (only its
    // children get wiped), so an isConnected check on it would never
    // catch a stale response — use an explicit sequence counter instead.
    const seq = ++this._womensFetchSeq;
    host.innerHTML = `<div style="padding: var(--space-3); opacity: 0.6; font-size: 0.9rem;">Loading Women's Club…</div>`;
    try {
      const qs = this.teamsIncludeInactive ? '&includeInactive=1' : '';
      const res = await this.auth.fetch(`/api/clubs/${this.clubId}?gender=womens${qs}`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const body = await res.json();
      const teams = (body && body.data && Array.isArray(body.data.teams)) ? body.data.teams : [];
      if (seq !== this._womensFetchSeq) return; // stale response after a pill flip / unmount

      if (!teams.length) {
        host.innerHTML = `
          <div style="padding: var(--space-4); opacity: 0.6; font-size: 0.9rem;">
            No ${this.teamsIncludeInactive ? '' : 'active '}women's team yet.
          </div>
        `;
        return;
      }

      // Multi-team badge — same idea as RosterScreenBase.
      // renderActiveTeamsBadge on the Boys/Girls/Mens boards: flags a
      // player who holds more than one active roster spot (e.g. someone
      // also on a Boys/Mens team) so it's visually obvious here too.
      // Excludes the team this card is already listed under.
      const icon = { boys: '🧒', girls: '👧', mens: '🧔', womens: '👩' };
      const activeTeamsBadge = (player, currentTeamId) => {
        const others = (Array.isArray(player.active_teams) ? player.active_teams : [])
          .filter((at) => at && at.teamId !== currentTeamId);
        if (!others.length) return '';
        return others.map((at) => `<span title="Also on ${this.escapeHtml(at.name || 'this team')}" style="font-size:0.62rem; line-height:1.3; font-weight:700; padding:0 5px; border-radius:8px; background:rgba(168,85,247,0.22); color:#c084fc; white-space:nowrap;">${icon[at.genderCategory] || '⚽'} ${this.escapeHtml(at.name || 'Team')}</span>`).join('');
      };

      const cards = teams.map((t) => {
        const roster = Array.isArray(t.roster) ? t.roster : [];
        const rosterHtml = roster.length
          ? roster.map((p) => `
              <div style="display:flex; align-items:center; justify-content:space-between; gap:8px; padding:4px 0; font-size:0.85rem; flex-wrap:wrap; row-gap:2px;">
                <span>${this.escapeHtml(`${p.first_name || ''} ${p.last_name || ''}`.trim() || '(no name)')}</span>
                <span style="display:flex; align-items:center; gap:4px;">
                  ${activeTeamsBadge(p, t.id)}
                  ${p.jersey_number ? `<span style="opacity:0.6;">#${this.escapeHtml(String(p.jersey_number))}</span>` : ''}
                </span>
              </div>
            `).join('')
          : `<div style="opacity:0.6; font-size:0.85rem; padding:4px 0;">No players on roster yet.</div>`;

        return `
          <div style="padding: var(--space-3); border-radius: 8px; background: var(--bg-tertiary, #1f2937); border: 1px solid var(--border-color, #374151);">
            <div style="font-weight:700; font-size:1rem; margin-bottom:6px;">${this.escapeHtml(t.name || 'Team')}</div>
            <div style="font-size:0.75rem; opacity:0.6; margin-bottom:10px;">${t.player_count ?? roster.length} player${(t.player_count ?? roster.length) === 1 ? '' : 's'}</div>
            ${rosterHtml}
            <button type="button" class="btn btn-secondary" data-womens-team-open="${t.id}" style="margin-top:10px; font-size:0.8rem;">Manage roster →</button>
          </div>
        `;
      }).join('');

      host.innerHTML = `<div style="display:flex; flex-wrap:wrap; gap: var(--space-3);">${cards}</div>`;
      host.querySelectorAll('[data-womens-team-open]').forEach((btn) => {
        btn.addEventListener('click', () => {
          const teamId = parseInt(btn.dataset.womensTeamOpen, 10);
          const team = teams.find((t) => t.id === teamId);
          if (!team) return;
          this.navigation.goTo('team-hub', {
            teamId: team.id,
            teamName: team.name,
            clubId: this.clubId,
            lineupTeamId: team.id,
          });
        });
      });
    } catch (err) {
      console.error('[rosters] womens load failed:', err);
      if (seq !== this._womensFetchSeq) return;
      host.innerHTML = `
        <div style="padding: var(--space-4); color: var(--color-error);">
          Could not load Women's Club: ${this.escapeHtml(err && err.message ? err.message : String(err))}
        </div>
      `;
    }
  }

  // Render a child screen into `wrap`, strip its outer .screen chrome
  // + header (we own those), and remember it for later onLeave.
  _mountChildInto(wrap, child, label) {
    if (!wrap) return;
    try {
      if (typeof child?.render !== 'function') {
        throw new Error(`${label}: child instance has no render()`);
      }
      const el = child.render();
      if (!el) throw new Error(`${label}: render() returned no element`);
      el.classList.remove('screen');
      const childHeader = el.querySelector('.screen-header');
      if (childHeader) childHeader.remove();
      // Apply the base-class layout policy to child too — otherwise
      // its inline max-widths / auto margins survive when mounted
      // outside ScreenManager (which does this automatically for
      // top-level screens).
      if (typeof child.applyLayoutRules === 'function') {
        try { child.applyLayoutRules(el); }
        catch (e) { console.warn('[rosters] applyLayoutRules on child failed', e); }
      }
      wrap.innerHTML = '';
      wrap.appendChild(el);
      this._mountedChildren.push(child);
      if (typeof child.onEnter === 'function') child.onEnter();
    } catch (err) {
      console.error(`[rosters] ${label} failed to mount`, err);
      wrap.innerHTML = `<div style="padding: var(--space-3); color: var(--color-error);
                                    border: 1px solid var(--color-error); border-radius: 6px;">
        <b>${label} failed to load.</b><br>
        <span style="font-size: 0.85rem; opacity: 0.85;">${err && err.message ? err.message : err}</span>
      </div>`;
    }
  }

  _unmountAll() {
    for (const child of this._mountedChildren) {
      try {
        if (child && typeof child.onLeave === 'function') child.onLeave();
      } catch (err) {
        console.error('[rosters] child onLeave threw', err);
      }
    }
    this._mountedChildren = [];
  }
}

class PlayerRosterScreen extends RostersScreen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this._welcomeDismissed = false;
  }

  onEnter(params) {
    super.onEnter(params);
    this._renderWelcomeCard();
  }

  _renderWelcomeCard() {
    const host = this.find('#rs-unassigned-pills');
    if (!host) return;

    if (this._welcomeDismissed) {
      const existing = this.element?.querySelector('#player-roster-welcome');
      if (existing) existing.remove();
      return;
    }

    if (this.element?.querySelector('#player-roster-welcome')) return;

    const card = document.createElement('div');
    card.id = 'player-roster-welcome';
    card.style.cssText = 'margin-bottom: var(--space-3); padding: var(--space-3); border: 1px solid rgba(255,255,255,0.14); border-radius: var(--radius-md); background: linear-gradient(135deg, rgba(59,130,246,0.16), rgba(16,185,129,0.12)); display:grid; gap: var(--space-2);';
    card.innerHTML = `
      <div style="font-size: 0.95rem; font-weight: 700;">Welcome to the club!</div>
      <div style="font-size: 0.9rem; line-height: 1.5; opacity: 0.95;">
        Please head to footballhome to set your availability for the week. You do not need to attend every event, but you are expected to set your availability for every event so the club knows where you can help.
        We’re glad to have you with us.
      </div>
      <div style="display:flex; gap: var(--space-2); flex-wrap:wrap;">
        <button type="button" class="btn btn-primary" id="player-roster-welcome-btn" style="padding: 0.45rem 0.8rem;">Welcome</button>
      </div>
    `;
    host.parentNode?.insertBefore(card, host);

    card.querySelector('#player-roster-welcome-btn')?.addEventListener('click', () => {
      const subject = 'Welcome to the club — set your availability on FootballHome';
      const body = [
        'Hi there,',
        '',
        'Welcome to the club! This is where practices, pickups, and games are listed on FootballHome.',
        '',
        'Please log in at https://footballhome.org and set your availability for the week.',
        'You do not need to attend every event, but you are expected to set your availability for every event so the club knows where you can help.',
        '',
        'Thanks,',
        'James Breslin',
        'Soccer Director at Lighthouse',
      ].join('\n');
      const gmailUrl = 'https://mail.google.com/mail/?view=cm&fs=1&tf=1' +
        '&to=' + encodeURIComponent('soccer@lighthouse1893.org') +
        '&su=' + encodeURIComponent(subject) +
        '&body=' + encodeURIComponent(body);
      window.open(gmailUrl, '_blank', 'noopener,noreferrer');
      this._welcomeDismissed = true;
      card.remove();
    });
  }
}

window.RostersScreen = RostersScreen;
window.PlayerRosterScreen = PlayerRosterScreen;
