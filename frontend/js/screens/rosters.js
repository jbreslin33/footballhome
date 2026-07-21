// RostersScreen ───────────────────────────────────────────────────────────
//
// Standardized single-screen entry point for every club roster board.
// Follows the same FilterBar pattern as Members + Payments (2026-07-13
// directive: "condense them into 1 screen like the others").
//
// Behaviour
// ─────────
// One host container.  A single FilterBar row of category chips —
// All / Mens / Womens / Boys / Girls — swaps which existing roster
// screen is mounted underneath.
//
// Rather than reimplement 2500+ lines of column layout, dues badges,
// drag/drop, and LA sync, this screen COMPOSES the existing per-club
// screens (BoysRosterScreen, MensRosterScreen, GirlsRosterScreen) by
// mounting their rendered <div> into a shared host and forwarding
// `onEnter` / `onLeave`.
//
// The 'All' chip inlines the horizontal composite layout that used to
// live in the standalone ClubRostersScreen (retired 2026-07-13): Youth
// (Boys) on the left, Men's Club on the right, per-section overdue
// badges up top, one outer horizontal scroll.
//
// Chip → view mapping
// ────────────────────
//   All    → horizontal composite (Boys + Mens side-by-side, inline)
//   Mens   → MensRosterScreen  (the workbench — assignment board)
//   Womens → placeholder message (no dedicated screen yet)
//   Boys   → BoysRosterScreen  (LA roster viewer)
//   Girls  → GirlsRosterScreen (same data as Boys, girls-focused
//                                header — girls play on boys teams)
//
// Deep-link
// ─────────
// `onEnter({ chip: 'mens' | 'womens' | 'boys' | 'girls' | 'all' })`
// lets other screens push a specific default chip.  Otherwise defaults
// to 'all' so a fresh navigation lands on the composite view (same
// UX pattern as Payments' default 'all' tab).
class RostersScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.navigation = navigation;
    this.auth = auth;
    this.chip = 'all';
    this._filterBar = null;
    // Track every child instance currently mounted (single-chip views
    // hold one; the 'all' composite holds two — boys + mens).
    this._mountedChildren = [];
    // Lazy-instantiated sub-screens (created on first mount to keep
    // the initial screen render cheap — mens+boys are hefty).
    this._instances = {
      mens:  null,
      boys:  null,
      girls: null,
    };
    // In-flight fetch generation for the pickup variant so a stale
    // response from a previous category doesn't overwrite the DOM
    // after the user clicks a different chip.
    this._pickupFetchSeq = 0;
  }

  render() {
    // ScreenManager wipes container.innerHTML on every transition,
    // so any DOM references cached on the instance (like a FilterBar
    // bound to the previous mount's host element) are now detached
    // garbage.  Reset them here so the next _buildFilterBar() call
    // constructs a fresh one against the freshly-rendered host —
    // otherwise the category pills quietly render into a dead node
    // and vanish on the second visit.
    this._filterBar = null;
    this._mountedChildren = [];

    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        /* 'All' composite view overrides (inlined from the retired
           ClubRostersScreen 2026-07-13).  Force each mounted child's
           grid columns to a fixed width so they don't collapse when
           the outer flex row shrinks their basis to content; also
           drop each child's own overflow-x wrapper so we have ONE
           outer horizontal scroll instead of three nested ones. */
        .rs-hscroll {
          overflow-x: auto;
          overflow-y: visible;
          padding: 0 var(--space-3) var(--space-4);
        }
        .rs-row {
          display: inline-flex;
          align-items: flex-start;
          gap: var(--space-5);
          min-width: 100%;
        }
        .rs-section { flex: 0 0 auto; }
        .rs-section-title {
          margin: var(--space-3) 0 var(--space-2);
          padding: 6px 10px;
          font-size: 1.05rem;
          font-weight: 700;
          letter-spacing: 0.02em;
          background: var(--bg-secondary, #111827);
          border-radius: 6px;
          border-left: 4px solid #64748b;
          display: flex;
          align-items: center;
          gap: 10px;
          flex-wrap: wrap;
        }
        .rs-overdue-badge {
          font-size: 0.8rem;
          font-weight: 600;
          letter-spacing: 0;
          opacity: 0.9;
          padding: 2px 8px;
          border-radius: 4px;
          background: rgba(148, 163, 184, 0.18);
        }
        .rs-overdue-badge.rs-overdue-warn {
          background: rgba(251, 191, 36, 0.22);
          color: #fbbf24;
        }
        .rs-overdue-badge.rs-overdue-alert {
          background: rgba(239, 68, 68, 0.22);
          color: #ef4444;
        }
        .rs-section [style*="grid-template-columns"] {
          display: flex !important;
          gap: var(--space-2) !important;
          align-items: flex-start;
        }
        .rs-section [style*="grid-template-columns"] > * {
          min-width: 440px !important;
          max-width: 440px !important;
          flex: 0 0 440px !important;
        }
        .rs-section [style*="overflow-x"] {
          overflow-x: visible !important;
          padding-bottom: 0 !important;
        }
        .rs-section > div > div[style*="padding"] {
          padding: 0 !important;
        }

      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🎽 Rosters</h1>
        <p class="subtitle" id="rs-subtitle">Assign members to teams — pick a club, or view all side-by-side</p>
      </div>
      <div style="padding: var(--space-3) var(--space-2);">
        <div id="rosters-filters" style="margin-bottom: var(--space-3);"></div>
        <div id="rosters-host" style="min-height: 200px;">
          <div style="padding: var(--space-3); opacity: 0.6; font-size: 0.9rem;">Loading…</div>
        </div>
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

  onEnter(params) {
    const allowed = new Set(['all', 'mens', 'womens', 'boys', 'girls']);
    if (params && typeof params.chip === 'string' && allowed.has(params.chip)) {
      this.chip = params.chip;
    }
    this._syncHeaderState();
    this._buildFilterBar();
    this._mountForChip();
  }

  // ScreenManager's lifecycle hook is `onExit` (not `onLeave`).  We
  // also drop the cached FilterBar here so anything still holding a
  // reference doesn't accidentally paint into the old host after we've
  // been detached.
  onExit() {
    this._unmountAll();
    this._filterBar = null;
  }

  _syncHeaderState() {
    const subtitle = this.element?.querySelector('#rs-subtitle');
    if (subtitle) {
      subtitle.textContent = 'Assign members to teams — pick a club, or view all side-by-side';
    }
  }

  // ── FilterBar ─────────────────────────────────────────────────────
  _buildFilterBar() {
    const host = this.find('#rosters-filters');
    if (!host) return;
    if (!this._filterBar) {
      this._filterBar = new FilterBar({ host });
    }
    const chips = [
      { id: 'all',    label: '🗂️ All'    },
      { id: 'mens',   label: '👨 Mens'   },
      { id: 'womens', label: '👩 Womens' },
      { id: 'boys',   label: '👦 Boys'   },
      { id: 'girls',  label: '👧 Girls'  },
    ];
    this._filterBar.setRows([
      {
        name:     'category',
        chips,
        selected: this.chip,
        onSelect: (id) => {
          // Non-toggle behaviour — every chip picks exactly one view;
          // clicking the active chip is a no-op (falling back to
          // 'all' on toggle-off would confuse the operator).
          if (id == null) return;
          if (id === this.chip) return;
          this.chip = id;
          this._buildFilterBar();
          this._mountForChip();
        },
      },
    ]);
  }

  // ── Sub-screen mounting ───────────────────────────────────────────
  //
  // Instantiate on first use, cache thereafter.  Cached instances keep
  // their own DOM around when we unmount them — cheaper than a full
  // rebuild on chip flip.
  _instanceForChip(chip) {
    if (chip === 'mens') {
      if (!this._instances.mens) {
        this._instances.mens = new MensRosterScreen(this.navigation, this.auth);
      }
      return this._instances.mens;
    }
    if (chip === 'boys') {
      if (!this._instances.boys) {
        this._instances.boys = new BoysRosterScreen(this.navigation, this.auth);
      }
      return this._instances.boys;
    }
    if (chip === 'girls') {
      if (!this._instances.girls) {
        this._instances.girls = new GirlsRosterScreen(this.navigation, this.auth);
      }
      return this._instances.girls;
    }
    return null;
  }

  _mountForChip() {
    const host = this.find('#rosters-host');
    if (!host) return;

    // Detach previous children (fire their onLeave so timers/listeners
    // are cleaned up) before swapping in the new view.
    this._unmountAll();
    host.innerHTML = '';

    if (this.chip === 'womens') {
      host.innerHTML = `
        <div style="padding: var(--space-4); border: 1px dashed var(--border-color, #374151);
                    border-radius: 6px; opacity: 0.8; font-size: 0.9rem;">
          👩 <b>Women's Roster</b> — no dedicated roster board yet.
          Womens players are managed via
          <a href="#members" style="color: var(--color-primary, #60a5fa);">Members</a>
          and the Womens Dashboard.
        </div>
      `;
      return;
    }

    if (this.chip === 'all') {
      this._mountComposite(host);
      return;
    }

    // Single-child view (mens / boys / girls).
    const child = this._instanceForChip(this.chip);
    if (!child) {
      host.innerHTML = `<div style="padding: var(--space-3); color: var(--color-error);">Unknown roster: ${this.chip}</div>`;
      return;
    }
    this._mountChildInto(host, child, this.chip);
  }

  // ── Pickup rendering ─────────────────────────────────────────────
  //
  // Enforces the LA → DB → render rule end-to-end:
  //   1. POST /api/admin/membership/sync?variant=pickup&category=<cat>
  //      → server calls LaProgramSync::run() for the matching pickup
  //        LA program (5070075 / 5064618 / 5064662 / 5064686),
  //        upserts persons/aliases/memberships, closes ended_at for
  //        anyone LA no longer returns.
  //   2. GET /api/admin/members?variant=pickup&category=<cat>
  //      → fresh DB read, no client-side filtering.
  //   3. Render cards.
  //
  // If step 1 fails we DO NOT render stale data — surface the error.
  async _mountPickupForCategory(host, category) {
    const seq = ++this._pickupFetchSeq;
    // Titles for each pickup category.
    const catLabel = {
      mens:   'Men',
      womens: 'Women',
      boys:   'Boys',
      girls:  'Girls',
    }[category] || category;
    // Map screen category → backend category (backend uses singular).
    const backendCategory = ({
      mens:   'men',
      womens: 'women',
      boys:   'boys',
      girls:  'girls',
    })[category] || category;

    host.innerHTML = `
      <div id="rs-pickup-banner"
           style="margin-bottom: var(--space-3); padding: var(--space-3);
                  border-radius: 6px; background: var(--bg-secondary, #111827);
                  border: 1px solid var(--border-color, #374151);
                  display:flex; align-items:center; gap: var(--space-3);
                  flex-wrap: wrap; font-size: 0.9rem;">
        <span style="font-size: 1rem;">⏳</span>
        <span style="flex:1; min-width: 200px;">Syncing ${catLabel} Pickup roster from LeagueApps…</span>
      </div>
      <div id="rs-pickup-list"
           style="display:grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
                  gap: var(--space-3);"></div>
    `;

    const setBanner = (icon, text, isError = false) => {
      if (seq !== this._pickupFetchSeq) return;
      const b = this.element?.querySelector('#rs-pickup-banner');
      if (!b) return;
      b.style.borderColor = isError ? 'var(--color-error, #ef4444)' : 'var(--border-color, #374151)';
      b.innerHTML = `
        <span style="font-size: 1rem;">${icon}</span>
        <span style="flex:1; min-width: 200px; ${isError ? 'color: var(--color-error, #ef4444);' : ''}">
          ${text}
        </span>
      `;
    };

    try {
      // Step 1: sync (mandatory — do NOT render on failure).
      const syncQs = `variant=pickup&category=${encodeURIComponent(backendCategory)}`;
      const syncRes = await this.auth.fetch(`/api/admin/membership/sync?${syncQs}`, { method: 'POST' });
      if (seq !== this._pickupFetchSeq) return;
      if (!syncRes.ok) {
        const body = await syncRes.text();
        throw new Error(`sync HTTP ${syncRes.status}: ${body.slice(0, 200)}`);
      }

      // Step 2: DB read (post-sync, fresh).
      const fetchQs = `variant=pickup&category=${encodeURIComponent(backendCategory)}`;
      const res = await this.auth.fetch(`/api/admin/members?${fetchQs}`);
      if (seq !== this._pickupFetchSeq) return;
      if (!res.ok) {
        const body = await res.text();
        throw new Error(`fetch HTTP ${res.status}: ${body.slice(0, 200)}`);
      }
      const payload = await res.json();
      if (seq !== this._pickupFetchSeq) return;

      // Response shape: { success, data: { groups: [{category, variant, label, members: [...]}, ...] } }
      const groups = (payload && payload.data && Array.isArray(payload.data.groups))
        ? payload.data.groups
        : [];
      // Endpoint returns exactly one group per (variant, category)
      // pair — pickup + our category → one group.
      const group = groups.find(g => g && g.variant === 'pickup') || groups[0] || null;
      const members = (group && Array.isArray(group.members)) ? group.members : [];

      setBanner('✓', `${catLabel} Pickup — ${members.length} member${members.length === 1 ? '' : 's'} live from LeagueApps`, false);
      this._renderPickupCards(catLabel, members);
    } catch (err) {
      console.error('[rosters] pickup load failed', err);
      setBanner('✗', `Could not load ${catLabel} Pickup: ${err && err.message ? err.message : err}`, true);
      const list = this.element?.querySelector('#rs-pickup-list');
      if (list) list.innerHTML = '';
    }
  }

  _renderPickupCards(catLabel, members) {
    const list = this.element?.querySelector('#rs-pickup-list');
    if (!list) return;
    if (!members.length) {
      list.innerHTML = `
        <div style="grid-column: 1 / -1; padding: var(--space-4);
                    text-align: center; opacity: 0.6; font-size: 0.9rem;
                    border: 1px dashed var(--border-color, #374151);
                    border-radius: 6px;">
          No ${catLabel} Pickup members yet.  Populate the pickup
          sub-program on the LeagueApps console — they'll show here
          on the next load.
        </div>
      `;
      return;
    }
    const esc = (s) => String(s == null ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    const cards = members.map(m => {
      const name = esc(`${m.first_name || ''} ${m.last_name || ''}`.trim() || '(no name)');
      const email = m.email ? esc(m.email) : '';
      const phone = m.phone ? esc(m.phone) : '';
      const joined = m.joined_at
        ? new Date(m.joined_at).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })
        : '';
      const inClub = !!m.has_active;
      const chip = inClub
        ? `<span style="display:inline-block; padding: 2px 8px; border-radius: 4px;
                        font-size: 0.75rem; font-weight: 600;
                        background: rgba(34, 197, 94, 0.18); color: #22c55e;">
             ✓ Also in Club
           </span>`
        : `<span style="display:inline-block; padding: 2px 8px; border-radius: 4px;
                        font-size: 0.75rem; font-weight: 600;
                        background: rgba(148, 163, 184, 0.18); color: #94a3b8;">
             Pickup only
           </span>`;
      return `
        <div style="padding: var(--space-3); border-radius: 6px;
                    background: var(--bg-secondary, #111827);
                    border: 1px solid var(--border-color, #374151);
                    display:flex; flex-direction:column; gap: 6px;">
          <div style="display:flex; align-items:center; justify-content:space-between; gap: 8px;">
            <div style="font-weight: 700; font-size: 1rem;">${name}</div>
            ${chip}
          </div>
          ${email ? `<div style="font-size: 0.85rem; opacity: 0.85;">✉ ${email}</div>` : ''}
          ${phone ? `<div style="font-size: 0.85rem; opacity: 0.85;">📞 ${phone}</div>` : ''}
          ${joined ? `<div style="font-size: 0.75rem; opacity: 0.6;">Pickup since ${esc(joined)}</div>` : ''}
        </div>
      `;
    }).join('');
    list.innerHTML = cards;
  }

  // Horizontal composite: Youth Club (Boys) + Men's Club side-by-side,
  // plus a Women's Club placeholder card and per-section overdue
  // badges up top.  Inlined from the retired ClubRostersScreen.
  _mountComposite(host) {
    host.innerHTML = `
      <div class="rs-hscroll">
        <div class="rs-row">
          <section class="rs-section" id="rs-section-youth">
            <h2 class="rs-section-title">
              🧒 Youth Club (Boys + Girls)
              <span class="rs-overdue-badge" id="rs-youth-overdue"></span>
            </h2>
            <div id="rs-boys-wrap">
              <div style="padding: var(--space-3); opacity: 0.6; font-size: 0.85rem;">Loading Youth Club…</div>
            </div>
          </section>
          <section class="rs-section" id="rs-section-men">
            <h2 class="rs-section-title">
              🧔 Men's Club
              <span class="rs-overdue-badge" id="rs-mens-overdue"></span>
            </h2>
            <div id="rs-mens-wrap">
              <div style="padding: var(--space-3); opacity: 0.6; font-size: 0.85rem;">Loading Men's Club…</div>
            </div>
          </section>
          <section class="rs-section" id="rs-section-women">
            <h2 class="rs-section-title">👩 Women's Club</h2>
            <div style="padding: var(--space-3); min-width: 260px; opacity: 0.6; font-size: 0.85rem;">
              No dedicated Women's roster board yet — womens players
              are managed via Members / Payments.
            </div>
          </section>
        </div>
      </div>
    `;

    const boys = this._instanceForChip('boys');
    const mens = this._instanceForChip('mens');
    this._mountChildInto(host.querySelector('#rs-boys-wrap'), boys, 'boys (composite)');
    this._mountChildInto(host.querySelector('#rs-mens-wrap'), mens, 'mens (composite)');
    this._loadCompositeOverdueBadges();
  }

  // Populate the per-section overdue pill next to each composite
  // section header.  Runs in parallel with the mounted child screens
  // (they hit the same endpoints — no caching, so this is two extra
  // roundtrips but keeps the aggregate visible even before the
  // per-child banners paint).
  async _loadCompositeOverdueBadges() {
    const setBadge = (id, overdue, total) => {
      const el = this.element?.querySelector('#' + id);
      if (!el) return;
      if (!total || total <= 0) { el.textContent = ''; return; }
      const pct = Math.round((overdue / total) * 100);
      const cls = overdue === 0
        ? ''
        : (pct >= 25 ? ' rs-overdue-alert' : ' rs-overdue-warn');
      el.className = 'rs-overdue-badge' + cls;
      el.textContent = `⚠ ${overdue}/${total} overdue (${pct}%)`;
    };
    const fetchJson = async (url) => {
      const res = await this.auth.fetch(url);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return res.json();
    };
    // Mens — backend emits data.delinquency.overdueCount directly.
    fetchJson('/api/mens-roster').then((data) => {
      const overdue = data?.delinquency?.overdueCount || 0;
      setBadge('rs-mens-overdue', overdue, data?.total || 0);
    }).catch(() => setBadge('rs-mens-overdue', 0, 0));
    // Boys — no server-side delinquency count; proxy from
    // outstandingBalance > 0 || paymentStatus === 'UNPAID' per player,
    // deduped by leagueAppsUserId across all buckets + unassigned.
    fetchJson('/api/boys-roster').then((data) => {
      let overdue = 0;
      const seen = new Set();
      const walk = (arr) => {
        for (const p of arr || []) {
          const uid = p.leagueAppsUserId;
          if (uid == null || seen.has(uid)) continue;
          seen.add(uid);
          const bal = Number(p.outstandingBalance || 0);
          const unpaid = String(p.paymentStatus || '').toUpperCase() === 'UNPAID';
          if (bal > 0 || unpaid) overdue++;
        }
      };
      walk(data?.unassigned);
      for (const b of Object.values(data?.buckets || {})) walk(b);
      setBadge('rs-youth-overdue', overdue, data?.total || 0);
    }).catch(() => setBadge('rs-youth-overdue', 0, 0));
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
  }

  onEnter(params) {
    this.chip = 'mens';
    this._syncHeaderState();
    this._buildFilterBar();
    this._mountForChip();
  }

  _syncHeaderState() {
    const subtitle = this.element?.querySelector('#rs-subtitle');
    if (subtitle) {
      subtitle.textContent = 'Mens roster — APSL and Liga 1 only';
    }
  }

  _buildFilterBar() {
    const host = this.find('#rosters-filters');
    if (!host) return;
    if (!this._filterBar) {
      this._filterBar = new FilterBar({ host });
    }
    this._filterBar.setRows([
      {
        name: 'category',
        chips: [{ id: 'mens', label: '👨 Mens' }],
        selected: this.chip,
        onSelect: (id) => {
          if (id == null || id === this.chip) return;
          this.chip = id;
          this._buildFilterBar();
          this._mountForChip();
        },
      },
    ]);
  }
}

window.RostersScreen = RostersScreen;
window.PlayerRosterScreen = PlayerRosterScreen;
