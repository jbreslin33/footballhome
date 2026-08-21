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
//   Womens → WomensRosterScreen, columnScope='unassigned'|'teams' — a
//             real peer of Mens/Boys/Girls now (WomensRoster.cpp backed
//             by LEAGUEAPPS_WOMENS_PROGRAM_ID, same board-column
//             machinery via teams.gender_category='womens').
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
    this._unassignedInstances = { mens: null, boys: null, girls: null, womens: null };
    this._teamsInstances      = { mens: null, boys: null, girls: null, womens: null };
    // Guards the "N registered, not yet on a team" note under the Teams
    // panel (see _setTeamsUnassignedNote) — bumped on every
    // _mountTeamsPanel call so a stale async onDataLoaded callback
    // (Mens/Boys/Girls/Womens all wire the same hook) can't land after
    // a pill flip.
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
        // (no `clears`). Scoped to the Teams panel only.
        name:     'teams-status',
        chips: [
          { id: 'active',   label: 'Active' },
          { id: 'inactive', label: 'Inactive' },
        ],
        selected: this.teamsIncludeInactive ? 'inactive' : 'active',
        onSelect: (id) => {
          if (id == null) return;
          this.teamsIncludeInactive = id === 'inactive';
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
  // Unassigned:X and Teams:X are two independent instances (own DOM, own
  // fetch — see the two-cache doc in the constructor), so an assign/
  // unassign that succeeds in one never touched the other's cached data.
  // 2026-08-21 (owner report): "sent unassigned woman to Tri County,
  // she did not appear [in Teams] — reload fixes it" — exactly that gap.
  // Each instance gets an onMembershipChanged hook, wired once at
  // construction, that quietly reloads the SAME-category instance in the
  // OTHER cache (looked up lazily, so wiring order doesn't matter — the
  // sibling may not exist yet when this one is created).
  _instanceForPanel(cache, pill) {
    const otherCache = cache === this._unassignedInstances ? this._teamsInstances : this._unassignedInstances;
    const makeAndWire = (ClassRef, key) => {
      if (!cache[key]) {
        cache[key] = new ClassRef(this.navigation, this.auth);
        cache[key].onMembershipChanged = () => {
          const sibling = otherCache[key];
          if (sibling && typeof sibling.load === 'function') sibling.load({ quiet: true });
        };
      }
      return cache[key];
    };
    if (pill === 'mens')   return makeAndWire(MensRosterScreen, 'mens');
    if (pill === 'boys')   return makeAndWire(BoysRosterScreen, 'boys');
    if (pill === 'girls')  return makeAndWire(GirlsRosterScreen, 'girls');
    if (pill === 'womens') return makeAndWire(WomensRosterScreen, 'womens');
    return null;
  }

  // Small caption under each panel's pills — without a header (stripped
  // by _mountChildInto) Boys and Girls would otherwise render byte-for-
  // byte identical content with no way to tell which one is selected
  // besides the pill highlight.
  _captionForPill(pill) {
    return {
      mens:   'Lighthouse Mens Club — LeagueApps APSL + Liga 1',
      womens: "Lighthouse Women's Club — LeagueApps",
      boys:   'Boys + Girls Club — youth, LeagueApps',
      girls:  'Same roster as Boys — girls play on boys teams',
    }[pill] || '';
  }

  _mountUnassignedPanel() {
    const host = this.find('#rs-unassigned-body');
    if (!host) return;
    const caption = this.find('#rs-unassigned-caption');
    if (caption) caption.textContent = this._captionForPill(this.unassignedPill);

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

    const child = this._instanceForPanel(this._teamsInstances, this.teamsPill);
    if (!child) {
      host.innerHTML = `<div style="padding: var(--space-3); color: var(--color-error);">Unknown category: ${this.teamsPill}</div>`;
      return;
    }
    child.columnScope = 'teams';
    if (typeof child.setIncludeInactive === 'function') {
      child.includeInactive = this.teamsIncludeInactive;
    }
    // Mens/Boys/Girls/Womens each compute an LA-driven Unassigned count
    // server-side (data.unassignedCount) — mirror it here so the Teams
    // panel shows a "not yet on a team" note without reaching into the
    // child's own Unassigned column state.
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
