// ClubRostersScreen — one horizontal roster board across every FH club.
//
// Layout (user directive 2026-07-07): Youth Club → Men's Club → Women's
// Club, laid out LEFT→RIGHT in a single horizontal scroll strip so the
// coach can pan across the whole club roster without vertical hopping.
// Each section's columns keep their existing card + column colors and
// behaviour (we still instantiate the classic BoysRosterScreen and
// MensRosterScreen and let them render themselves) — the outer flex
// row + inline CSS overrides are what put them side-by-side.
//
// Section order chosen so first-time coaches see the youngest cohort
// first (biggest funnel + parent-driven signups) before adult teams;
// Womens sits last as a placeholder until a dedicated womens roster
// exists.
class ClubRostersScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.boys = new BoysRosterScreen(navigation, auth);
    this.mens = new MensRosterScreen(navigation, auth);
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    // .cr-scoped-* CSS overrides:
    //  · Force each child section's internal grid to a fixed 160 px
    //    column width so the columns don't collapse under `1fr` when
    //    the outer flex row shrinks the section's flex-basis to
    //    content.  `!important` beats the child's inline
    //    `grid-template-columns: repeat(N, minmax(155px, 1fr))`.
    //  · Drop the child's own `overflow-x: auto` wrapper so we have
    //    ONE horizontal scroll at the outer level instead of three
    //    nested scrolls (one per section).
    //  · Cap each column's card stack at 70 vh with internal vertical
    //    scroll so a 20-player Liga 2 column doesn't push the row
    //    height off the fold.
    //  · NO color changes — the mens/boys screens keep their exact
    //    card + column colors (user directive 2026-07-07).
    div.innerHTML = `
      <style>
        .cr-hscroll {
          overflow-x: auto;
          overflow-y: visible;
          padding: 0 var(--space-3) var(--space-4);
        }
        .cr-row {
          display: inline-flex;
          align-items: flex-start;
          gap: var(--space-5);
          min-width: 100%;
        }
        .cr-section {
          flex: 0 0 auto;
        }
        .cr-section-title {
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
        .cr-overdue-badge {
          font-size: 0.8rem;
          font-weight: 600;
          letter-spacing: 0;
          opacity: 0.9;
          padding: 2px 8px;
          border-radius: 4px;
          background: rgba(148, 163, 184, 0.18);
        }
        .cr-overdue-badge.cr-overdue-warn {
          background: rgba(251, 191, 36, 0.22);
          color: #fbbf24;
        }
        .cr-overdue-badge.cr-overdue-alert {
          background: rgba(239, 68, 68, 0.22);
          color: #ef4444;
        }
        /* Force fixed-width columns inside each child section (was
           repeat(N, minmax(155px, 1fr)) — the 1fr collapses under an
           inline-flex parent). */
        .cr-section [style*="grid-template-columns"] {
          display: flex !important;
          gap: var(--space-2) !important;
          align-items: flex-start;
        }
        .cr-section [style*="grid-template-columns"] > * {
          min-width: 440px !important;
          max-width: 440px !important;
          flex: 0 0 440px !important;
        }
        /* Drop child's per-section horizontal scroll — outer .cr-hscroll owns it. */
        .cr-section [style*="overflow-x"] {
          overflow-x: visible !important;
          padding-bottom: 0 !important;
        }
        /* Columns run full-height down the page — no internal card-stack
           scroll (user directive 2026-07-07: "just run it down page"). */
        /* Trim the child screens' outer padding — the outer wrap owns spacing. */
        .cr-section > div > div[style*="padding"] {
          padding: 0 !important;
        }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🗂️ Club Rosters</h1>
        <p class="subtitle">Every club side-by-side — pan right to walk from Youth → Men → Women</p>
      </div>
      <div class="cr-hscroll">
        <div class="cr-row">
          <section class="cr-section" id="cr-section-youth">
            <h2 class="cr-section-title">
              🧒 Youth Club (Boys + Girls)
              <span class="cr-overdue-badge" id="cr-youth-overdue"></span>
            </h2>
            <div id="cr-boys-wrap">
              <div id="cr-boys-status" style="padding: var(--space-3); opacity: 0.6; font-size: 0.85rem;">Loading Youth Club…</div>
            </div>
          </section>
          <section class="cr-section" id="cr-section-men">
            <h2 class="cr-section-title">
              🧔 Men's Club
              <span class="cr-overdue-badge" id="cr-mens-overdue"></span>
            </h2>
            <div id="cr-mens-wrap">
              <div id="cr-mens-status" style="padding: var(--space-3); opacity: 0.6; font-size: 0.85rem;">Loading Men's Club…</div>
            </div>
          </section>
          <section class="cr-section" id="cr-section-women">
            <h2 class="cr-section-title">
              👩 Women's Club
              <span class="cr-overdue-badge" id="cr-womens-overdue"></span>
            </h2>
            <div id="cr-womens-wrap" style="padding: var(--space-3); min-width: 260px; opacity: 0.6; font-size: 0.85rem;">
              No dedicated Women's roster board yet — womens players are managed via the Members / Paused Membership tiles.
            </div>
          </section>
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

  onEnter() {
    const mountChild = (child, wrapSelector, label) => {
      const wrap = this.element.querySelector(wrapSelector);
      if (!wrap) {
        console.error(`[club-rosters] wrap ${wrapSelector} not found`);
        return;
      }
      wrap.innerHTML = '';
      try {
        if (typeof child?.render !== 'function') {
          throw new Error(`${label}: child instance has no render() — did the class fail to load?`);
        }
        const el = child.render();
        if (!el) throw new Error(`${label}: render() returned no element`);
        el.classList.remove('screen');
        const header = el.querySelector('.screen-header');
        if (header) header.remove();
        wrap.appendChild(el);
        if (typeof child.onEnter === 'function') child.onEnter();
      } catch (err) {
        console.error(`[club-rosters] ${label} failed to mount`, err);
        wrap.innerHTML = `<div style="padding: var(--space-3); color: var(--color-error); border: 1px solid var(--color-error); border-radius: 6px;">
          <strong>${label} failed to load.</strong><br>
          <span style="font-size: 0.85rem; opacity: 0.85;">${err && err.message ? err.message : err}</span>
        </div>`;
      }
    };
    mountChild(this.boys, '#cr-boys-wrap', 'Youth Club');
    mountChild(this.mens, '#cr-mens-wrap', "Men's Club");
    this.loadOverdueBadges();
  }

  // Populate the per-section "N/N overdue (X%)" pill in each
  // section title.  Runs in parallel with the mounted child screens
  // (they hit the same endpoints — browser cache-busting is on, so
  // this is two extra roundtrips but keeps the aggregate visible on
  // the club-rosters screen even before the child banners paint).
  async loadOverdueBadges() {
    const setBadge = (id, overdue, total) => {
      const el = this.element?.querySelector('#' + id);
      if (!el) return;
      if (!total || total <= 0) { el.textContent = ''; return; }
      const pct = Math.round((overdue / total) * 100);
      const cls = overdue === 0
        ? ''
        : (pct >= 25 ? ' cr-overdue-alert' : ' cr-overdue-warn');
      el.className = 'cr-overdue-badge' + cls;
      el.textContent = `⚠ ${overdue}/${total} overdue (${pct}%)`;
    };

    const fetchJson = async (url) => {
      const res = await this.auth.fetch(url);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return res.json();
    };

    // Mens — backend already emits data.delinquency.overdueCount.
    fetchJson('/api/mens-roster').then((data) => {
      const overdue = data?.delinquency?.overdueCount || 0;
      setBadge('cr-mens-overdue', overdue, data?.total || 0);
    }).catch(() => setBadge('cr-mens-overdue', 0, 0));

    // Boys — backend doesn't populate delinquency yet, so proxy from
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
      setBadge('cr-youth-overdue', overdue, data?.total || 0);
    }).catch(() => setBadge('cr-youth-overdue', 0, 0));
  }
}
