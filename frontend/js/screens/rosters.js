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
    this.chip = 'all';                // active category
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
  }

  render() {
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
        <p class="subtitle">Assign members to teams — pick a club, or view all side-by-side</p>
      </div>
      <div style="padding: var(--space-3); max-width: 1600px; margin: 0 auto;">
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
      }
    });

    return div;
  }

  onEnter(params) {
    // Accept deep-link chip from params or the hash.
    const allowed = new Set(['all', 'mens', 'womens', 'boys', 'girls']);
    if (params && typeof params.chip === 'string' && allowed.has(params.chip)) {
      this.chip = params.chip;
    }
    this._buildFilterBar();
    this._mountForChip();
  }

  onLeave() {
    this._unmountAll();
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

window.RostersScreen = RostersScreen;
