// RsvpEligibilityScreen — Diagnostic board that shows exactly which
// mens-selection teams each FH member can RSVP for.
//
// UX theme (2026-07-13 refactor): follows the exact same visual +
// interaction language as MembersScreen / PaymentsScreen so operators
// don't have to switch mental models between screens.
//   * Shared `FilterBar` component (categories row) — same chip
//     styling / click semantics as members + payments.
//   * Search input with identical styling.
//   * Grouped card grid (one section per category) — cards are
//     clickable and drill into the universal PersonScreen with the
//     same restoreChip / _snapshotHistoryState back-nav contract used
//     by members + payments.
//   * Team-eligibility toggles are rendered INSIDE each card as a
//     row of colored pill-buttons (was: a wide-scrolling table).
//     Clicking a pill flips grant/revoke via PUT — same underlying
//     endpoint as before, just presented as chip toggles.
//
// Data flow (LA-authoritative per project rule):
//   1. onEnter / chip change / Sync-now:
//        POST /api/admin/membership/sync?variant=active
//   2. GET  /api/admin/members?variant=active               (grouped)
//   3. Per-member (parallel):
//        GET  /api/mens-roster/rsvp-eligibility?leagueAppsUserId=X
//   4. On toggle:
//        PUT  /api/mens-roster/rsvp-eligibility
//             body {leagueAppsUserId, teamIds:[...]}   ← set-replace
//
// Team catalog (MUST stay in sync with MensRosterController.cpp
// `kEligibilityTeams`):
//   35 APSL · 120 Liga 1 · 121 Liga 2 · 122 Adult · 908 Practice · 909 Pickup
class RsvpEligibilityScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🗳️ RSVP Eligibility</h1>
        <p class="subtitle" id="rsvp-elig-subtitle">Who can RSVP for which mens team</p>
      </div>

      <div style="padding: var(--space-4);">

        <div id="rsvp-elig-sync-bar" style="margin-bottom: var(--space-3); display:flex;
             align-items:center; gap: var(--space-2); flex-wrap: wrap;">
          <span id="rsvp-elig-sync-time" style="padding:4px 12px; border-radius:9999px;
                font-size:0.85rem; font-weight:500; background: transparent;
                color: #94a3b8; border: 1px solid #94a3b8; white-space:nowrap;">
            Last sync: —
          </span>
          <button class="rsvp-elig-sync-now btn btn-secondary" style="padding: 4px 12px; font-size: 0.85rem;">
            🔄 Sync now
          </button>
        </div>

        <!-- FilterBar host (chip rows).  Hidden until the first load
             resolves so we don't flash an empty pill row. -->
        <div id="rsvp-elig-filters" style="display:none; margin-bottom: var(--space-3);
             flex-wrap:wrap; gap: var(--space-1);"></div>

        <div id="rsvp-elig-search-wrap" style="margin-bottom: var(--space-3); display:none;">
          <input id="rsvp-elig-search" type="search"
                 placeholder="Search name, email, phone…"
                 style="width:100%; padding: var(--space-2) var(--space-3); font-size: 1rem;
                        border-radius: var(--radius-md); border: 1px solid var(--color-border);
                        background: var(--bg-secondary); color: var(--text-primary);">
        </div>

        <!-- Team-color legend so an admin can decode the pill row on
             every card at a glance. -->
        <div id="rsvp-elig-legend" style="display:none; margin-bottom: var(--space-3);
             flex-wrap:wrap; gap:6px; font-size:0.8rem;"></div>

        <div id="rsvp-elig-loading" style="text-align:center; padding: var(--space-6); opacity:0.7;">
          Loading members and eligibility…
        </div>
        <div id="rsvp-elig-error" style="display:none; color: var(--color-error);
             padding: var(--space-4); text-align:center;"></div>
        <div id="rsvp-elig-empty" style="display:none; text-align:center; padding: var(--space-6); opacity:0.6;">
          No members match this filter.
        </div>

        <div id="rsvp-elig-groups" style="display:none;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  // Team catalog — MUST match MensRosterController.cpp `kEligibilityTeams`.
  // Colors match the per-player modal in mens-roster.js
  // openRsvpEligibilityModal().
  _teams() {
    return [
      { id: 35,  short: 'APSL',   label: 'APSL',     color: '#2563eb' },
      { id: 120, short: 'Liga 1', label: 'Liga 1',   color: '#0891b2' },
      { id: 121, short: 'Liga 2', label: 'Liga 2',   color: '#14b8a6' },
      { id: 122, short: 'Adult',  label: 'Adult',    color: '#a78bfa' },
      { id: 908, short: 'Pract.', label: 'Practice', color: '#f59e0b' },
      { id: 909, short: 'Pickup', label: 'Pickup',   color: '#10b981' },
    ];
  }

  onEnter(params) {
    // Passed through from admin-club when the operator opens this
    // screen; forwarded on to PersonScreen so its Back button can
    // return here with the exact same context.
    this.clubId   = params?.clubId;
    this.clubName = params?.clubName;

    // Active category filter — mirrors MembersScreen.categoryFilter.
    // null == "All" chip selected.
    this.categoryFilter = params?.category || null;

    // Restore-state contract (paired with PersonScreen._goBack() +
    // this._snapshotHistoryState()).  When PersonScreen navigates
    // back to us via window.history.back() we get these params from
    // the /rsvp-eligibility history entry we stamped before drilling
    // in — pre-select the exact chip + search + scroll target the
    // operator had.  One-shot: consumed on next _load().
    this._pendingRestoreChip   = params?.restoreChip || null;
    this._pendingRestoreSearch = typeof params?.restoreSearch === 'string'
      ? params.restoreSearch : '';
    this._pendingFocusLaUserId = params?.focusLaUserId || null;

    // FilterBar host is inside the DOM tree that ScreenManager
    // rebuilds on every entry, so the cached instance would write
    // into a detached ghost element (same reason MembersScreen
    // resets its `_filterBar` in onEnter — see that file's comment
    // for the full story).
    this._filterBar = null;

    // Preserve prior data on re-entry (back-nav) so we can render
    // chips + list immediately from cache while the async sync
    // repopulates.  Fresh entries fall through to the empty defaults.
    if (!Array.isArray(this._groups)) this._groups = [];
    if (!(this._elig instanceof Map)) this._elig = new Map(); // uid → Set<teamId>
    if (typeof this._filter !== 'string') this._filter = '';
    if (typeof this._lastSyncAt !== 'string') this._lastSyncAt = '';

    // ── Wire top-level event handlers.  Single delegated click
    //    handler on the screen — cheaper than per-element listeners
    //    and survives every re-render of the card grid. ──
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      if (e.target.closest('.rsvp-elig-sync-now')) {
        this._load({ force: true });
        return;
      }
      // Team-eligibility toggle chip — inside a card, sits ABOVE the
      // card body's own click handler so this catches first.
      const teamChip = e.target.closest('[data-elig-team]');
      if (teamChip) {
        e.stopPropagation();
        const uid    = teamChip.getAttribute('data-la-user-id');
        const teamId = Number(teamChip.getAttribute('data-elig-team'));
        const has    = teamChip.getAttribute('data-elig-on') === '1';
        this._toggle(uid, teamId, !has, teamChip);
        return;
      }
      // Card body → open PersonScreen.  Guard against clicks on any
      // inner control so those handlers keep charge.
      const anchorInside = e.target.closest('a, button, input, textarea, select, label');
      if (anchorInside) return;
      const card = e.target.closest('.rsvp-elig-card[data-la-user-id]');
      if (card) {
        const laUid = card.getAttribute('data-la-user-id');
        if (laUid) {
          // Snapshot our live filter state into the current history
          // entry BEFORE pushing /person — PersonScreen's Back
          // (window.history.back()) will then land back here with
          // the exact chip + search restored.  See project rule
          // comment on members.js._snapshotHistoryState() for the
          // paired-halves rationale.
          this._snapshotHistoryState();
          this.navigation.goTo('person', {
            leagueAppsUserId: laUid,
            returnTo: 'rsvp-eligibility',
            returnToParams: this._returnParams(),
          });
        }
      }
    });

    const search = this.find('#rsvp-elig-search');
    if (search) {
      search.addEventListener('input', (ev) => {
        this._filter = (ev.target.value || '').trim().toLowerCase();
        this._renderGroups();
      });
    }

    this._load();
  }

  // ── Data flow ────────────────────────────────────────────────────
  //
  // Warm-cache + LA-first sync-then-fetch.  Follows the same pattern
  // as MembersScreen._load(): if we already have data (back-nav
  // re-entry), render chips + list immediately from stale data, then
  // fire the LA sync + refetch in the background so the operator
  // never sees an empty pill row.  Cold entries take the plain
  // loading-spinner path.
  //
  // `opts.force` — Sync-now button; always POST the sync even on
  //                warm entries.
  async _load(opts = {}) {
    const loadingEl = this.find('#rsvp-elig-loading');
    const errorEl   = this.find('#rsvp-elig-error');
    const emptyEl   = this.find('#rsvp-elig-empty');
    const groupsEl  = this.find('#rsvp-elig-groups');
    errorEl.style.display = 'none';

    const hasCache = Array.isArray(this._groups) && this._groups.length > 0;
    if (hasCache) {
      // Warm entry — reveal chips + list + search from cached data
      // while the sync churns in the background.  Consume pending
      // restore params here so back-nav lands on the right chip.
      loadingEl.style.display = 'none';
      groupsEl.style.display  = 'block';
      this._consumePendingRestore();
      this._renderChips();
      this._renderLegend();
      this._renderGroups();
      this._revealChrome();
    } else {
      loadingEl.style.display = 'block';
      loadingEl.textContent   = 'Contacting LeagueApps…';
      groupsEl.style.display  = 'none';
      emptyEl.style.display   = 'none';
    }

    try {
      // ── LA sync (per project rule: LA → DB → query → render) ──
      // Skip only when we're on a warm re-entry AND `force` is false —
      // the caller (chip click) has its own sync tag.
      const shouldSync = !hasCache || !!opts.force;
      if (shouldSync) {
        const syncRes = await this.auth.fetch(
          '/api/admin/membership/sync?variant=active',
          { method: 'POST' }
        );
        if (!syncRes.ok) {
          console.warn(`LA sync HTTP ${syncRes.status} — continuing with DB state`);
        } else {
          this._lastSyncAt = new Date().toISOString();
        }
      }

      if (!hasCache) loadingEl.textContent = 'Loading member list…';

      const res = await this.auth.fetch('/api/admin/members?variant=active');
      if (!res.ok) throw new Error(`members HTTP ${res.status}`);
      const body = await res.json();
      if (!body?.success) throw new Error(body?.error || 'members load failed');
      this._groups = Array.isArray(body?.data?.groups) ? body.data.groups : [];

      // Batch-fetch per-member eligibility.  N parallel GETs is fine
      // for ~150 members; if it gets slow later we can add a bulk
      // endpoint that takes a comma-separated list of la user ids.
      const uids = new Set();
      for (const g of this._groups) {
        for (const m of (g.members || [])) {
          const uid = m.leagueapps_user_id;
          if (uid !== null && uid !== undefined && uid !== '') {
            uids.add(String(uid));
          }
        }
      }
      if (!hasCache) {
        loadingEl.textContent =
          `Fetching RSVP eligibility for ${uids.size} member${uids.size === 1 ? '' : 's'}…`;
      }
      await Promise.all(Array.from(uids).map(async (uid) => {
        try {
          const r = await this.auth.fetch(
            `/api/mens-roster/rsvp-eligibility?leagueAppsUserId=${encodeURIComponent(uid)}`
          );
          if (!r.ok) { this._elig.set(uid, new Set()); return; }
          const b = await r.json();
          this._elig.set(uid, new Set((b?.teamIds || []).map(Number)));
        } catch (_e) {
          this._elig.set(uid, new Set());
        }
      }));

      loadingEl.style.display = 'none';
      groupsEl.style.display  = 'block';
      this._consumePendingRestore();
      this._renderChips();
      this._renderLegend();
      this._renderGroups();
      this._revealChrome();
      this._updateSyncBar();
      this._maybeScrollToFocused();
    } catch (err) {
      console.error('rsvp-eligibility load failed', err);
      loadingEl.style.display = 'none';
      errorEl.style.display   = 'block';
      errorEl.textContent     = `Failed to load: ${err.message}`;
    }
  }

  // Consume the one-shot restore params PersonScreen back-nav gives us.
  // Called once per _load; running it twice would clobber a subsequent
  // user interaction (chip click) with the stale snapshot.
  _consumePendingRestore() {
    if (this._pendingRestoreChip) {
      // categoryFilter may be null (means: "All" chip).  Passing null
      // is deliberate — different from "leave it alone".
      this.categoryFilter = this._pendingRestoreChip.categoryFilter ?? null;
      this._pendingRestoreChip = null;
    }
    if (this._pendingRestoreSearch) {
      this._filter = this._pendingRestoreSearch.toLowerCase();
      const search = this.find('#rsvp-elig-search');
      if (search) search.value = this._pendingRestoreSearch;
      this._pendingRestoreSearch = '';
    }
  }

  _revealChrome() {
    const filters = this.find('#rsvp-elig-filters');
    const search  = this.find('#rsvp-elig-search-wrap');
    const legend  = this.find('#rsvp-elig-legend');
    if (filters) filters.style.display = 'flex';
    if (search)  search.style.display  = 'block';
    if (legend)  legend.style.display  = 'flex';
  }

  _updateSyncBar() {
    const el = this.find('#rsvp-elig-sync-time');
    if (!el || !this._lastSyncAt) return;
    try {
      const t = new Date(this._lastSyncAt);
      el.textContent = `Last sync: ${t.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;
      el.style.color = 'var(--text-primary)';
      el.style.borderColor = 'var(--color-border)';
    } catch (_e) { /* leave placeholder */ }
  }

  // ── FilterBar (shared chip component) ────────────────────────────
  // One row: [👥 All] [👨 All Men] [👩 All Women] [👦 All Boys] [👧 All Girls].
  // Category counts = unique persons across every program in that
  // category (dedupe by person_id — a person enrolled in Club +
  // Pickup counts once).  Same aggregation as MembersScreen so the
  // numbers line up between the two screens.
  _renderChips() {
    const el = this.find('#rsvp-elig-filters');
    if (!el) return;

    const emoji = (cat) => ({ men:'👨', women:'👩', boys:'👦', girls:'👧' }[cat] || '👥');
    const catLabel = (cat) => ({ men:'All Men', women:'All Women', boys:'All Boys', girls:'All Girls' }[cat] || `All ${cat}`);

    const allSeen = new Set();
    for (const g of this._groups) {
      for (const m of (g.members || [])) allSeen.add(m.person_id);
    }
    const totalAll = allSeen.size;

    const catOrder = [];
    const catSeen  = new Map();
    for (const g of this._groups) {
      const cat = String(g.category || '').toLowerCase();
      if (!cat) continue;
      if (!catSeen.has(cat)) { catSeen.set(cat, new Set()); catOrder.push(cat); }
      for (const m of (g.members || [])) catSeen.get(cat).add(m.person_id);
    }

    const chips = [{ id: 'all', label: '👥 All', count: totalAll }];
    for (const cat of catOrder) {
      chips.push({
        id:    cat,
        label: `${emoji(cat)} ${catLabel(cat)}`,
        count: (catSeen.get(cat) || new Set()).size,
      });
    }

    if (!this._filterBar) {
      this._filterBar = new FilterBar({ host: el });
    }
    this._filterBar.setRows([{
      name:     'category',
      chips,
      selected: this.categoryFilter || 'all',
      onSelect: (id) => {
        this.categoryFilter = (id === 'all' || id == null) ? null : id;
        this._renderGroups();
      },
    }]);
  }

  _renderLegend() {
    const el = this.find('#rsvp-elig-legend');
    if (!el) return;
    el.innerHTML = this._teams().map(t => `
      <span style="display:inline-flex; align-items:center; gap:4px;
                   padding:3px 8px; border-radius:999px;
                   background:${t.color}22; color:${t.color};
                   border:1px solid ${t.color}66;">
        <span style="width:8px; height:8px; border-radius:2px; background:${t.color};"></span>
        ${t.label} <span style="opacity:0.6;">#${t.id}</span>
      </span>
    `).join(' ');
  }

  // ── Card grid ────────────────────────────────────────────────────
  // Grouped by category (Men / Women / Boys / Girls), one section
  // per group.  Layout matches MembersScreen._renderGroups() so the
  // two screens feel identical.
  _renderGroups() {
    const groupsEl = this.find('#rsvp-elig-groups');
    const emptyEl  = this.find('#rsvp-elig-empty');
    if (!groupsEl) return;

    const filter = this._filter;
    const matches = (m) => {
      if (!filter) return true;
      const hay = [
        m.first_name, m.last_name, m.email, m.phone,
        `${m.first_name || ''} ${m.last_name || ''}`,
      ].map(v => (v || '').toLowerCase()).join(' ');
      return hay.includes(filter);
    };

    // Category filter applies at the group level so the "All Men"
    // chip hides Women/Boys/Girls groups entirely — mirrors Members.
    const groups = this._groups.filter(g => {
      if (!this.categoryFilter) return true;
      return String(g.category || '').toLowerCase() === this.categoryFilter;
    });

    let totalShown = 0;
    const html = groups.map(g => {
      const members = (g.members || []).filter(matches);
      totalShown += members.length;
      if (filter && members.length === 0) return '';
      const cards = members.map(m => this._renderCard(m)).join('');
      return `
        <section style="margin-bottom: var(--space-5);">
          <h3 style="margin: 0 0 var(--space-2); opacity:0.9;">
            ${this._esc(g.label || 'Members')}
            <span style="opacity:0.6; font-weight:400; font-size:0.85rem;">(${members.length})</span>
          </h3>
          <p style="opacity:0.6; font-size:0.8rem; margin: 0 0 var(--space-3);">
            ${this._esc(g.program_name || '')}
          </p>
          ${members.length === 0
            ? `<div style="opacity:0.5; font-style:italic;">No members.</div>`
            : `<div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: var(--space-3);">${cards}</div>`}
        </section>
      `;
    }).join('');

    groupsEl.innerHTML = html || '';
    if (totalShown === 0) {
      groupsEl.style.display = 'none';
      emptyEl.style.display  = 'block';
    } else {
      groupsEl.style.display = 'block';
      emptyEl.style.display  = 'none';
    }
    this._updateSubtitle(totalShown);
  }

  _renderCard(m) {
    const name  = `${m.first_name || ''} ${m.last_name || ''}`.trim() || '(no name)';
    const email = m.email || '';
    const phone = m.phone || '';
    const uid   = (m.leagueapps_user_id == null) ? '' : String(m.leagueapps_user_id);
    const noUid = !uid;
    const set   = this._elig.get(uid) || new Set();

    // Team-eligibility chip row.  Each chip is an atomic toggle —
    // click flips it, PUT saves the new set.  Filled = granted,
    // outline = not granted, disabled = no LA user id (can't set).
    const eligChips = this._teams().map(t => {
      const on = set.has(t.id);
      const bg     = on ? t.color        : 'transparent';
      const fg     = on ? '#fff'         : t.color;
      const border = t.color;
      const dis    = noUid ? 'opacity:0.35; cursor:not-allowed;' : 'cursor:pointer;';
      return `
        <button type="button"
                data-elig-team="${t.id}"
                data-la-user-id="${this._esc(uid)}"
                data-elig-on="${on ? '1' : '0'}"
                ${noUid ? 'disabled' : ''}
                title="${t.label} #${t.id} — ${on ? 'click to revoke' : 'click to grant'}"
                style="padding:4px 10px; border-radius:999px; font-weight:700;
                       font-size:0.75rem; line-height:1;
                       background:${bg}; color:${fg}; border:1px solid ${border};
                       ${dis}">
          ${t.short}
        </button>`;
    }).join(' ');

    const emailLine = email
      ? `<div style="font-size:0.78rem; opacity:0.75;">${this._esc(email)}</div>` : '';
    const phoneLine = phone
      ? `<div style="font-size:0.78rem; opacity:0.75;">${this._esc(phone)}</div>` : '';
    const uidLine = uid
      ? `<div style="font-size:0.7rem; opacity:0.5;">LA #${this._esc(uid)}</div>`
      : `<div style="font-size:0.7rem; color:#f59e0b;">⚠ no LA user id — eligibility cannot be set</div>`;

    return `
      <div class="rsvp-elig-card"
           data-la-user-id="${this._esc(uid)}"
           data-person-id="${m.person_id || ''}"
           style="background: var(--bg-secondary);
                  border-radius: var(--radius-md); padding: var(--space-3);
                  border: 1px solid var(--color-border);
                  display:flex; flex-direction:column; gap:6px;
                  ${uid ? 'cursor:pointer;' : ''}">
        <div style="font-weight:600;">${this._esc(name)}</div>
        ${emailLine}
        ${phoneLine}
        ${uidLine}
        <div style="display:flex; flex-wrap:wrap; gap:4px; margin-top: var(--space-1);">
          ${eligChips}
        </div>
      </div>
    `;
  }

  _updateSubtitle(count) {
    const el = this.find('#rsvp-elig-subtitle');
    if (!el) return;
    const catLabel = { men:'Men', women:'Women', boys:'Boys', girls:'Girls' }[this.categoryFilter] || 'All';
    el.textContent =
      `${count} member${count === 1 ? '' : 's'} — ${catLabel} · click a team chip to grant/revoke RSVP eligibility, click the card to open the person profile`;
  }

  // Scroll the focused member's card into view (only if the caller
  // passed `focusLaUserId` — e.g. PersonScreen's "Manage RSVP
  // eligibility →" button).  Idempotent within a load cycle.
  _maybeScrollToFocused() {
    if (!this._pendingFocusLaUserId) return;
    const uid = this._pendingFocusLaUserId;
    this._pendingFocusLaUserId = null;
    // Defer to next tick so the card grid is fully painted.
    setTimeout(() => {
      const card = this.element.querySelector(
        `.rsvp-elig-card[data-la-user-id="${uid}"]`
      );
      if (!card) return;
      card.scrollIntoView({ behavior: 'smooth', block: 'center' });
      // Brief highlight so the operator's eye lands on it.
      const originalOutline = card.style.outline;
      card.style.outline = '2px solid var(--color-primary, #2563eb)';
      setTimeout(() => { card.style.outline = originalOutline; }, 1600);
    }, 60);
  }

  // ── PUT toggle ───────────────────────────────────────────────────
  // Optimistic update: flip the chip visual + local Set immediately,
  // roll back on PUT failure.  Endpoint semantics: PUT sends the FULL
  // new team-id list for that user (set-replace), so we send
  // `Array.from(set)` — not just the delta.
  async _toggle(uid, teamId, want, chipEl) {
    if (!uid) return;
    const set = this._elig.get(uid) || new Set();
    const had = set.has(teamId);
    if (want) set.add(teamId); else set.delete(teamId);
    this._elig.set(uid, set);
    this._paintChip(chipEl, teamId, want);

    try {
      const r = await this.auth.fetch('/api/mens-roster/rsvp-eligibility', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          leagueAppsUserId: Number(uid),
          teamIds: Array.from(set),
        }),
      });
      if (!r.ok) throw new Error(`HTTP ${r.status}`);
    } catch (err) {
      // Rollback both state and pixels.
      if (had) set.add(teamId); else set.delete(teamId);
      this._elig.set(uid, set);
      this._paintChip(chipEl, teamId, had);
      alert(`Failed to save RSVP eligibility: ${err.message}`);
    }
  }

  _paintChip(chipEl, teamId, on) {
    if (!chipEl) return;
    const team = this._teams().find(t => t.id === teamId);
    if (!team) return;
    chipEl.setAttribute('data-elig-on', on ? '1' : '0');
    chipEl.style.background = on ? team.color : 'transparent';
    chipEl.style.color      = on ? '#fff'     : team.color;
  }

  // ── Back-nav restore contract ─────────────────────────────────────
  _returnParams() {
    return {
      clubId:        this.clubId,
      clubName:      this.clubName,
      restoreChip:   { categoryFilter: this.categoryFilter },
      restoreSearch: this._filter || '',
    };
  }

  _snapshotHistoryState() {
    try {
      const cur = window.history.state || {};
      const merged = {
        ...cur,
        screen: cur.screen || 'rsvp-eligibility',
        params: { ...(cur.params || {}), ...this._returnParams() },
      };
      window.history.replaceState(merged, '', '#rsvp-eligibility');
    } catch (_) { /* replaceState is non-throwable in practice */ }
  }

  _esc(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }
}
