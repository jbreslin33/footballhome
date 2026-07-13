// PausedMembersScreen — Club-admin view of everyone currently on an
// active- or paused-variant LA sub-program (Men / Women / Boys / Girls,
// or their paused counterparts).
//
// Data source: `GET /api/admin/{paused-,}members?variant=…`, which reads
// the `person_la_memberships` junction table populated by PersonLinker.
// Paused members are still members of the club (they show up in the
// paused view) but are hidden from the LA pool + team rosters.
//
// Screen is used for BOTH the "Membership" and "Paused Membership" tiles
// on admin-club — the `variant` navigation param toggles which slice is
// shown; the title/subtitle/icon swap automatically.  An optional
// `category` param (men / women / boys / girls) narrows the view to a
// single sub-program so bulk actions (Email All → Gmail BCC) apply
// only to that group.
class PausedMembersScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="members-title">Membership</h1>
        <p class="subtitle" id="members-subtitle">Members grouped by sub-program</p>
      </div>

      <div style="padding: var(--space-4);">

        <div id="members-sync-bar" style="margin-bottom: var(--space-3); display:flex;
             align-items:center; gap: var(--space-2); flex-wrap: wrap;">
          <span id="members-sync-time" style="padding:4px 12px; border-radius:9999px;
                font-size:0.85rem; font-weight:500; background: transparent;
                color: #94a3b8; border: 1px solid #94a3b8; white-space:nowrap;">
            Last sync: —
          </span>
          <button class="sync-now-btn btn btn-secondary" style="padding: 4px 12px; font-size: 0.85rem;">
            🔄 Sync now
          </button>
        </div>

        <div id="members-filters" style="display:none; margin-bottom: var(--space-3);
             flex-wrap:wrap; gap: var(--space-1);">
        </div>

        <div id="members-sort" style="display:none; margin-bottom: var(--space-3);
             flex-wrap:wrap; gap: var(--space-1); align-items:center;">
        </div>

        <div id="members-search-wrap" style="margin-bottom: var(--space-3); display:none;">
          <input id="members-search" type="search" placeholder="Search name, email, phone…"
                 style="width:100%; padding: var(--space-2) var(--space-3); font-size: 1rem;
                        border-radius: var(--radius-md); border: 1px solid var(--color-border);
                        background: var(--bg-secondary); color: var(--text-primary);">
        </div>

        <div id="members-bulk-bar" style="display:none; margin-bottom: var(--space-3);
             padding: var(--space-2) var(--space-3); border-radius: var(--radius-md);
             background: var(--bg-secondary); border: 1px solid var(--color-border);
             display:flex; flex-wrap:wrap; gap: var(--space-2); align-items:center;">
        </div>

        <div id="members-loading" style="display:block; padding: var(--space-4);">
          <div id="members-boot" style="max-width: 520px; margin: 0 auto;
               background: #0b1220; color: #d1d5db;
               border: 1px solid #1f2937; border-radius: var(--radius-md);
               padding: var(--space-4);
               font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
               font-size: 0.9rem; line-height: 1.55;">
            <div style="opacity: 0.7; margin-bottom: var(--space-3);">
              football-home boot &middot; refresh membership
            </div>
            <div class="boot-line" data-step="1" style="display:flex; gap:8px; align-items:baseline;">
              <span class="boot-mark" style="width:1.6em; display:inline-block;">[<span class="boot-spin">·</span>]</span>
              <span>Contacting LeagueApps</span>
            </div>
            <div class="boot-line" data-step="2" style="display:flex; gap:8px; align-items:baseline; opacity:0.4;">
              <span class="boot-mark" style="width:1.6em; display:inline-block;">[ ]</span>
              <span>Refreshing local database</span>
            </div>
            <div class="boot-line" data-step="3" style="display:flex; gap:8px; align-items:baseline; opacity:0.4;">
              <span class="boot-mark" style="width:1.6em; display:inline-block;">[ ]</span>
              <span>Loading member list</span>
            </div>
            <div id="members-boot-detail" style="margin-top: var(--space-3);
                 opacity: 0.6; min-height: 1.2em; font-size: 0.8rem;"></div>
          </div>
        </div>
        <div id="members-error" style="display:none; color: var(--color-error);
                                       padding: var(--space-4); text-align:center;"></div>
        <div id="members-empty" style="display:none; text-align:center; padding: var(--space-6); opacity:0.6;">
          No members found.
        </div>

        <div id="members-groups" style="display:none;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId   = params?.clubId;
    this.clubName = params?.clubName;
    // Which LA sub-program is currently in focus.  `null` == no
    // program-specific selection.  Mutually exclusive with
    // `categoryFilter` — clicking a program chip clears categoryFilter
    // and vice-versa.  When BOTH are null the "All" chip is active.
    this.programId = null;
    // Category-aggregate filter ("men" | "women" | "boys" | "girls" |
    // null).  When set, all programs matching that category are shown
    // together (both active + pickup variants).  The "All Men" chip
    // sets this to "men", "All Women" → "women", etc.  Mutually
    // exclusive with `programId`.
    this.categoryFilter = null;
    // Legacy nav params (`variant=active|paused`, `category=men|…`)
    // still arrive from admin-club tiles.  Translate them into a
    // best-effort pre-selected chip once the first load resolves —
    // see `_applyLegacyParams()`.  Stored so we can consume them
    // exactly once per screen entry.
    this._pendingLegacyCategory = String(params?.category || '').toLowerCase();
    this._pendingLegacyVariant  = (params?.variant === 'active' || params?.variant === 'pickup' || params?.variant === 'paused')
      ? (params.variant === 'paused' ? 'pickup' : params.variant)
      : '';
    this._groups  = [];
    this._filter  = '';
    // Sort key for the member cards inside each group.  Default is
    // registration date descending so new sign-ups float to the top of
    // every sub-program — the club admin acts on them first (welcome
    // email, roster placement, etc.).  Persisted in localStorage so a
    // page reload preserves the choice.
    // Values: 'joined_desc' | 'joined_asc' | 'inactive_desc' | 'inactive_asc' | 'last_asc' | 'first_asc'
    this._sort = localStorage.getItem('members-sort') || 'joined_desc';
    // Two mutually-inclusive status filters, applied AFTER category +
    // search text.  Persisted so a reload preserves the operator's
    // triage view.  A member matching EITHER active filter is shown
    // (OR-semantics) so admins can build a single "needs attention"
    // bucket by turning both on.
    this._flagNoAccount = localStorage.getItem('members-flag-no-account') === '1';
    this._flagDormant   = localStorage.getItem('members-flag-dormant')   === '1';

    // Title + subtitle default to the "all clubs" view; `_updateTitle`
    // and `_updateSubtitle` re-run after each chip click and after the
    // legacy nav params resolve (see `_applyLegacyParams`).
    this._updateTitle();
    this._updateSubtitle();

    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const bulkBtn = e.target.closest('[data-bulk]');
      if (bulkBtn) {
        this._handleBulk(bulkBtn.getAttribute('data-bulk'));
        return;
      }
      // Manual re-sync: same code path as sync-on-load — brings the
      // boot screen back, hits POST /membership/sync, then reloads
      // the list.  Also used as the "Try again" button when the
      // initial sync fails and blocks the screen.
      if (e.target.closest('.sync-now-btn') || e.target.closest('.sync-retry-btn')) {
        this._load();
        return;
      }
      // Chip row — two chip types.  User directive 2026-07-12: every
      // chip click MUST re-sync from LeagueApps first (so the DB
      // reflects the current LA console for that scope) before we
      // re-query the DB and re-render.  No client-side-only filtering
      // anymore.  Sync scope is narrower than the global initial load:
      //   • program chip  → sync just that (variant, category) pair
      //   • category chip → sync all variants for that category
      //   • "All" chip    → full sync (variant=all)
      const chip = e.target.closest('[data-program-chip]');
      if (chip) {
        const pid = chip.getAttribute('data-program-chip');
        this.programId = (pid === 'all') ? null : Number(pid);
        this.categoryFilter = null;
        let scope = {};
        if (this.programId != null) {
          const g = (this._groups || []).find(x => Number(x.program_id) === this.programId);
          if (g) scope = {
            syncVariant:  String(g.variant  || '').toLowerCase(),
            syncCategory: String(g.category || '').toLowerCase(),
          };
        }
        this._load(scope);
        return;
      }
      const catChip = e.target.closest('[data-category-chip]');
      if (catChip) {
        this.categoryFilter = catChip.getAttribute('data-category-chip') || null;
        this.programId = null;
        this._load({
          syncVariant:  '',                   // both variants (Club + Pickup)
          syncCategory: this.categoryFilter,  // narrow to this gender
        });
        return;
      }
      // Sort pill row — re-orders cards inside each sub-program group.
      // Clicking the currently active "Reg date" pill toggles between
      // newest-first (default) and oldest-first so admins can also flip
      // to see long-time members bottom-up.  "Inactivity" behaves the
      // same way: click while active to flip most-dormant / least-dormant.
      const sortBtn = e.target.closest('[data-sort]');
      if (sortBtn) {
        const next = sortBtn.getAttribute('data-sort');
        if (next === 'joined_desc' && this._sort === 'joined_desc') {
          this._sort = 'joined_asc';
        } else if (next === 'joined_desc' && this._sort === 'joined_asc') {
          this._sort = 'joined_desc';
        } else if (next === 'inactive_desc' && this._sort === 'inactive_desc') {
          this._sort = 'inactive_asc';
        } else if (next === 'inactive_desc' && this._sort === 'inactive_asc') {
          this._sort = 'inactive_desc';
        } else {
          this._sort = next;
        }
        try { localStorage.setItem('members-sort', this._sort); } catch (_) {}
        this._renderSortPills();
        this._renderGroups();
        return;
      }
      // Account-status filter toggles — multi-select.  Turning either
      // on narrows the visible member list to the union of both filters
      // (see `_visibleMembers`).  Both off === no filter (show all).
      const flagBtn = e.target.closest('[data-flag]');
      if (flagBtn) {
        const which = flagBtn.getAttribute('data-flag');
        if (which === 'no-account') {
          this._flagNoAccount = !this._flagNoAccount;
          try { localStorage.setItem('members-flag-no-account', this._flagNoAccount ? '1' : '0'); } catch (_) {}
        } else if (which === 'dormant') {
          this._flagDormant = !this._flagDormant;
          try { localStorage.setItem('members-flag-dormant', this._flagDormant ? '1' : '0'); } catch (_) {}
        }
        this._renderSortPills();
        this._renderGroups();
        this._renderBulkBar();
        this._updateSubtitle();
        return;
      }
      // Per-row "👤 Save" → download a single-entry vCard for that member.
      // Phones/browsers open .vcf directly with their Contacts app so
      // the operator can add the person with one tap.  Data source is
      // the same row already on screen — no extra API call.
      const vcardBtn = e.target.closest('[data-vcard-person-id]');
      if (vcardBtn) {
        const pid = Number(vcardBtn.getAttribute('data-vcard-person-id')) || 0;
        const m = this._visibleMembers().find(x => Number(x.person_id) === pid);
        if (m) {
          const name = `${m.first_name || 'contact'}-${m.last_name || pid}`
            .toLowerCase().replace(/[^a-z0-9-]+/g, '-').replace(/^-+|-+$/g, '') || `contact-${pid}`;
          this._downloadVcard([m], `${name}.vcf`);
        }
        return;
      }
    });

    const search = this.find('#members-search');
    if (search) {
      search.addEventListener('input', (e) => {
        this._filter = (e.target.value || '').trim().toLowerCase();
        this._renderGroups();
        this._renderBulkBar();
      });
    }

    this._load();
    // Ticker keeps the pill's color/age label fresh while the screen
    // stays open — walks green → yellow → orange → red as time drifts.
    this._updateSyncPill();
    this._startSyncTicker();
  }

  onExit() {
    this._stopSyncTicker();
  }

  async _load(scope) {
    const loadingEl = this.find('#members-loading');
    const errorEl   = this.find('#members-error');
    const emptyEl   = this.find('#members-empty');
    const groupsEl  = this.find('#members-groups');
    const searchWrap = this.find('#members-search-wrap');
    const filtersEl  = this.find('#members-filters');
    const bulkBar   = this.find('#members-bulk-bar');

    loadingEl.style.display = 'block';
    errorEl.style.display   = 'none';
    emptyEl.style.display   = 'none';
    groupsEl.style.display  = 'none';
    if (searchWrap) searchWrap.style.display = 'none';
    if (filtersEl)  filtersEl.style.display  = 'none';
    if (bulkBar)    bulkBar.style.display    = 'none';

    this._resetBoot();

    // Sync scope: on initial load (or the global "All" chip) we sync
    // every program (variant=all).  On chip clicks the caller passes a
    // narrower (syncVariant, syncCategory) so we only hit LA for the
    // relevant program(s).  The DB READ afterwards is ALWAYS full-
    // response (variant=all) so the chip row's per-program counts stay
    // accurate no matter which chip triggered the reload.
    const syncVariant  = (scope && typeof scope.syncVariant  === 'string') ? scope.syncVariant  : 'all';
    const syncCategory = (scope && typeof scope.syncCategory === 'string') ? scope.syncCategory : '';
    const syncParams = new URLSearchParams();
    if (syncVariant)  syncParams.set('variant',  syncVariant);
    if (syncCategory) syncParams.set('category', syncCategory);
    const syncQs  = syncParams.toString();
    const fetchQs = 'variant=all';

    // ── Step 1 + 2: sync from LeagueApps → upsert local DB ─────────
    // A single POST to the backend covers both.  The backend fans out
    // over every LA program matching (variant, category) and runs
    // LaProgramSync per program.  We show the two steps sequentially
    // for UX; both are already done by the time the POST returns.
    let syncInfo = null;
    try {
      const syncRes = await this.auth.fetch(`/api/admin/membership/sync?${syncQs}`, {
        method: 'POST',
      });
      if (!syncRes.ok) throw new Error(`sync HTTP ${syncRes.status}`);
      const syncBody = await syncRes.json();
      if (!syncBody?.success) throw new Error(syncBody?.error || 'Sync failed');
      syncInfo = syncBody.data || null;

      this._markBoot(1, 'ok', this._bootProgramLine(syncInfo));
      // Brief pause so both checkmarks don't flash at once — vibes.
      await this._sleep(180);
      this._markBoot(2, 'ok', this._bootDbLine(syncInfo));
      // Record the moment for the on-screen "Last sync" pill + track
      // partial-failure count so the pill can turn amber.
      this._lastSyncAt = new Date();
      this._lastSyncFailedPrograms = syncInfo?.programsFailed || 0;
      this._updateSyncPill();
    } catch (err) {
      console.error('membership sync failed', err);
      this._markBoot(1, 'fail', err.message);
      this._markBoot(2, 'fail', 'Skipped');
      // Hard-fail: don't render a stale list.  The operator needs to
      // know sync broke *before* they act on the data.
      errorEl.style.display = 'block';
      errorEl.innerHTML = `
        <div style="max-width: 520px; margin: 0 auto; padding: var(--space-3); text-align:left;
                    background: #fee2e2; color: #7f1d1d; border: 1px solid #fca5a5;
                    border-radius: var(--radius-md);">
          <div style="font-weight:600; margin-bottom: var(--space-2);">Sync with LeagueApps failed</div>
          <div style="font-size: 0.9rem; margin-bottom: var(--space-3); opacity: 0.85;">
            ${this._escapeHtml(err.message)}
          </div>
          <button class="btn btn-primary sync-retry-btn">🔄 Try again</button>
        </div>
      `;
      return;
    }

    // ── Step 3: load members from DB (fresh) ────────────────────────
    try {
      const res = await this.auth.fetch(`/api/admin/members?${fetchQs}`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const body = await res.json();
      if (!body?.success) throw new Error(body?.error || 'Load failed');

      this._groups = Array.isArray(body?.data?.groups) ? body.data.groups : [];
      const total  = this._filteredGroups().reduce((n, g) => n + (g.members?.length || 0), 0);

      this._markBoot(3, 'ok', total === 1 ? '1 member' : `${total} members`);
      await this._sleep(220); // Let the last checkmark register visually.

      loadingEl.style.display = 'none';

      if (this._groups.length === 0) {
        emptyEl.style.display = 'block';
        emptyEl.textContent = 'No members found in any sub-program.';
        return;
      }

      // Consume any legacy `?variant=`/`?category=` nav params from the
      // admin-club tile: pick the first program group matching them so
      // the old "go to Pickup Membership" tile still lands on the right
      // chip.  Runs at most once per screen entry.
      this._applyLegacyParams();

      this._renderProgramChips();
      this._renderSortPills();
      if (filtersEl)  filtersEl.style.display  = 'flex';
      if (searchWrap) searchWrap.style.display = 'block';
      this._updateSyncPill();

      if (total === 0) {
        emptyEl.style.display = 'block';
        emptyEl.textContent = 'No members match the current filter.';
        return;
      }

      this._updateSubtitle();
      groupsEl.style.display = 'block';
      this._renderGroups();
      this._renderBulkBar();
    } catch (err) {
      console.error('members load failed', err);
      this._markBoot(3, 'fail', err.message);
      // Leave the boot screen visible with the failure state so the
      // operator can see which step broke.
      errorEl.style.display   = 'block';
      errorEl.textContent     = `Failed to load members: ${err.message}`;
    }
  }

  // ── Boot-screen helpers ───────────────────────────────────────────
  _resetBoot() {
    const boot = this.find('#members-boot');
    if (!boot) return;
    boot.style.display = 'block';
    boot.querySelectorAll('.boot-line').forEach((line, i) => {
      line.style.opacity = (i === 0) ? '1' : '0.4';
      const mark = line.querySelector('.boot-mark');
      if (mark) mark.innerHTML = (i === 0)
        ? '[<span class="boot-spin">·</span>]'
        : '[ ]';
    });
    const detail = this.find('#members-boot-detail');
    if (detail) detail.textContent = '';
  }
  _markBoot(step, state, detailText) {
    const boot = this.find('#members-boot');
    if (!boot) return;
    const line = boot.querySelector(`.boot-line[data-step="${step}"]`);
    if (line) {
      line.style.opacity = '1';
      const mark = line.querySelector('.boot-mark');
      if (mark) {
        if (state === 'ok')      mark.textContent = '[✓]';
        else if (state === 'fail') mark.textContent = '[✗]';
        else                       mark.innerHTML   = '[<span class="boot-spin">·</span>]';
      }
    }
    // Reveal + spinner-ify the next step, if this one succeeded.
    if (state === 'ok') {
      const next = boot.querySelector(`.boot-line[data-step="${step + 1}"]`);
      if (next) {
        next.style.opacity = '1';
        const nmark = next.querySelector('.boot-mark');
        if (nmark) nmark.innerHTML = '[<span class="boot-spin">·</span>]';
      }
    }
    const detail = this.find('#members-boot-detail');
    if (detail && detailText) detail.textContent = detailText;
  }
  _bootProgramLine(info) {
    if (!info) return '';
    const n = Array.isArray(info.programs) ? info.programs.length : 0;
    const totalMs = info.elapsedMs || 0;
    const totalRecs = info.totalRecords || 0;
    return `${n} program${n === 1 ? '' : 's'} · ${totalRecs} record${totalRecs === 1 ? '' : 's'} · ${totalMs} ms`;
  }
  _bootDbLine(info) {
    if (!info) return '';
    const fails = info.programsFailed || 0;
    return fails > 0 ? `${fails} program${fails === 1 ? '' : 's'} failed` : 'ok';
  }
  _renderSyncStrip() {
    // Deprecated — replaced by the persistent #members-sync-bar pill.
    // Kept as a no-op so any stale call sites don't blow up.
  }

  // Returns the color palette for the last-sync pill based on age:
  //   0-5m  green   |  5-10m  yellow  |  10-15m  orange  |  15m+  red
  // Amber override when the last sync had partial program failures.
  _syncPillStyle() {
    const failed = this._lastSyncFailedPrograms || 0;
    if (!this._lastSyncAt) {
      return { bg: 'transparent', color: '#94a3b8', border: '#94a3b8', ago: null, min: null };
    }
    const min = Math.floor((Date.now() - this._lastSyncAt.getTime()) / 60000);
    let bg, color, border;
    if (failed > 0)     { bg='#fef3c7'; color='#92400e'; border='#f59e0b'; }
    else if (min < 5)   { bg='#d1fae5'; color='#065f46'; border='#10b981'; }
    else if (min < 10)  { bg='#fef9c3'; color='#854d0e'; border='#eab308'; }
    else if (min < 15)  { bg='#fed7aa'; color='#7c2d12'; border='#f97316'; }
    else                { bg='#fee2e2'; color='#7f1d1d'; border='#ef4444'; }
    const ago = min < 1 ? 'just now' : `${min}m ago`;
    return { bg, color, border, ago, min };
  }

  _updateSyncPill() {
    const el = this.find('#members-sync-time');
    if (!el) return;
    const s = this._syncPillStyle();
    el.style.background   = s.bg;
    el.style.color        = s.color;
    el.style.borderColor  = s.border;
    if (!this._lastSyncAt) {
      el.textContent = 'Last sync: —';
      return;
    }
    const timeStr = this._lastSyncAt.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
    const failed = this._lastSyncFailedPrograms || 0;
    const warn = failed > 0 ? ` · ⚠ ${failed} failed` : '';
    el.textContent = `Last sync: ${timeStr} (${s.ago})${warn}`;
  }

  _startSyncTicker() {
    this._stopSyncTicker();
    // 30s cadence — age is minute-granular so this is plenty responsive
    // and cheap.  Ticker is stopped on onExit to avoid leaks.
    this._syncTicker = setInterval(() => this._updateSyncPill(), 30 * 1000);
  }
  _stopSyncTicker() {
    if (this._syncTicker) {
      clearInterval(this._syncTicker);
      this._syncTicker = null;
    }
  }

  _escapeHtml(s) {
    return String(s || '')
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }
  _sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

  // Groups after applying the chip selection.  Program chip wins if
  // both are set (shouldn't happen — they're mutually exclusive), but
  // check in the safe order anyway.  Returns everything when neither
  // is set (== "All" chip active).
  _filteredGroups() {
    if (this.programId != null) {
      return this._groups.filter(g => Number(g.program_id) === this.programId);
    }
    if (this.categoryFilter) {
      return this._groups.filter(g => String(g.category || '').toLowerCase() === this.categoryFilter);
    }
    return this._groups;
  }

  // One-shot legacy param translator: if the caller navigated in with
  // `?variant=active&category=boys` (old admin-club tile shape), pick
  // the first matching program group and pre-select its chip.  If only
  // `category` was given (no variant), pre-select the category-aggregate
  // chip instead.  Consumes the pending params so subsequent renders
  // don't reapply them.
  _applyLegacyParams() {
    const wantCat     = this._pendingLegacyCategory;
    const wantVariant = this._pendingLegacyVariant;
    this._pendingLegacyCategory = '';
    this._pendingLegacyVariant  = '';
    if (!wantCat && !wantVariant) return;
    // Category-only → aggregate chip ("All Men", "All Boys", …).
    if (wantCat && !wantVariant) {
      this.categoryFilter = wantCat;
      return;
    }
    const match = (this._groups || []).find(g => {
      const catOk     = !wantCat     || String(g.category || '').toLowerCase() === wantCat;
      const variantOk = !wantVariant || String(g.variant  || '').toLowerCase() === wantVariant;
      return catOk && variantOk;
    });
    if (match) this.programId = Number(match.program_id);
  }

  // Sort a member list per the current `this._sort` key.  Non-mutating
  // (returns a fresh array) so the underlying `_groups` cache from the
  // API stays stable across re-sorts.  Missing values sort to the end.
  _sortMembers(list) {
    const arr = Array.isArray(list) ? list.slice() : [];
    const key = this._sort || 'joined_desc';
    const strCmp = (a, b) => String(a || '').toLowerCase()
      .localeCompare(String(b || '').toLowerCase());
    const tieBreak = (a, b) => strCmp(a.last_name, b.last_name)
      || strCmp(a.first_name, b.first_name);
    const joinedTs = (m) => {
      if (!m.joined_at) return null;
      const t = new Date(m.joined_at).getTime();
      return Number.isFinite(t) ? t : null;
    };
    if (key === 'first_asc') {
      arr.sort((a, b) => strCmp(a.first_name, b.first_name)
        || strCmp(a.last_name, b.last_name));
    } else if (key === 'last_asc') {
      arr.sort((a, b) => strCmp(a.last_name, b.last_name)
        || strCmp(a.first_name, b.first_name));
    } else if (key === 'inactive_desc' || key === 'inactive_asc') {
      // Sort by days_since_activity.  "desc" (default) surfaces the
      // most-dormant at the top — that's the triage direction.  Null
      // (== never seen / no account) is treated as infinitely dormant
      // so those rows also float to the top under desc, which is what
      // an admin doing outreach wants.  Under asc the nulls sink to
      // the bottom for the same reason.
      const dir = key === 'inactive_asc' ? 1 : -1;
      const inact = (m) => {
        const d = m.days_since_activity;
        if (d == null) return Number.POSITIVE_INFINITY;
        const n = Number(d);
        return Number.isFinite(n) ? n : Number.POSITIVE_INFINITY;
      };
      arr.sort((a, b) => {
        const da = inact(a);
        const db = inact(b);
        if (da === db) return tieBreak(a, b);
        // ±Infinity math works cleanly here: (Infinity - Infinity) is
        // NaN so guard by equality first (above).
        return (da < db ? -1 : 1) * dir;
      });
    } else {
      // joined_desc / joined_asc — nulls at the bottom regardless of dir.
      const dir = key === 'joined_asc' ? 1 : -1;
      arr.sort((a, b) => {
        const ta = joinedTs(a);
        const tb = joinedTs(b);
        if (ta === null && tb === null) return tieBreak(a, b);
        if (ta === null) return 1;
        if (tb === null) return -1;
        return (ta === tb) ? tieBreak(a, b) : (ta - tb) * dir;
      });
    }
    return arr;
  }

  _renderSortPills() {
    const el = this.find('#members-sort');
    if (!el) return;
    // Only surface the control once the list is populated — keeps the
    // pre-load boot screen uncluttered.
    const hasData = (this._groups || []).some(g => (g.members || []).length);
    if (!hasData) { el.style.display = 'none'; return; }
    el.style.display = 'flex';

    const isJoined      = this._sort === 'joined_desc'   || this._sort === 'joined_asc';
    const isInactive    = this._sort === 'inactive_desc' || this._sort === 'inactive_asc';
    const joinedArrow   = this._sort === 'joined_asc'   ? ' ↑' : ' ↓';
    const inactiveArrow = this._sort === 'inactive_asc' ? ' ↑' : ' ↓';
    const active = (on) => on
      ? 'background:var(--color-primary, #2563eb); color:#fff; border-color:transparent;'
      : 'background:var(--bg-secondary); color:var(--text-primary);';
    const flagActive = (on) => on
      ? 'background:#7f1d1d; color:#fecaca; border-color:#b91c1c;'
      : 'background:var(--bg-secondary); color:var(--text-primary);';
    const base = 'padding:5px 12px; border-radius:999px; cursor:pointer;'
      + ' font-weight:600; font-size:0.8rem; border:1px solid var(--color-border);';

    // Counts for the two status filter chips.  Scoped to the current
    // category (so "No account (12)" reflects only Boys when Boys is
    // selected, etc.) but NOT to the search text — admins expect the
    // chip counter to be stable while they type.
    const scope = [];
    for (const g of this._filteredGroups()) {
      for (const m of (g.members || [])) scope.push(m);
    }
    const noAccountCount = scope.filter(m => !m.has_fh_account).length;
    const dormantCount   = scope.filter(m => m.has_fh_account
      && (m.days_since_activity == null || Number(m.days_since_activity) >= 8)).length;

    el.innerHTML = `
      <span style="opacity:0.6; font-size:0.8rem; margin-right:4px;">Sort:</span>
      <button data-sort="joined_desc" title="Registration date — click again to flip direction"
              style="${base} ${active(isJoined)}">
        📅 Reg date${isJoined ? joinedArrow : ''}
      </button>
      <button data-sort="inactive_desc" title="Days since last activity — most-dormant first, click again to flip"
              style="${base} ${active(isInactive)}">
        ⏰ Inactivity${isInactive ? inactiveArrow : ''}
      </button>
      <button data-sort="last_asc"
              style="${base} ${active(this._sort === 'last_asc')}">
        🔤 Last name
      </button>
      <button data-sort="first_asc"
              style="${base} ${active(this._sort === 'first_asc')}">
        🔤 First name
      </button>

      <span style="opacity:0.4; margin:0 4px;">│</span>

      <span style="opacity:0.6; font-size:0.8rem; margin-right:4px;">Filter:</span>
      <button data-flag="no-account" title="Members who have not created an FH account"
              style="${base} ${flagActive(this._flagNoAccount)}">
        🚫 No account (${noAccountCount})
      </button>
      <button data-flag="dormant" title="Members with an account but no activity in 8+ days (or never logged in)"
              style="${base} ${flagActive(this._flagDormant)}">
        💤 Dormant 8d+ (${dormantCount})
      </button>
    `;
  }

  _renderProgramChips() {
    const el = this.find('#members-filters');
    if (!el) return;

    // Chip row layout, per category (order driven by backend's
    // ORDER BY category, variant<>'active', program_id):
    //   [👥 All]
    //   [👨 All Men] [👨 Mens Club Members] [👨 Mens Pickup Members]
    //   [👩 All Women] [👩 Womens Club Members] [👩 Womens Pickup Members]
    //   [👦 All Boys] [👦 Boys Club Members] [👦 Boys Pickup Members]
    //   [👧 All Girls] [👧 Girls Club Members] [👧 Girls Pickup Members]
    // The "All <Category>" chip is inserted the first time we see a
    // new category as we walk `this._groups`, and its count is the sum
    // of every program in that category (Club + Pickup, de-duplicated
    // by person_id — a person enrolled in both variants counts once).
    const emoji = (cat) => ({ men:'👨', women:'👩', boys:'👦', girls:'👧' }[cat] || '👥');
    const catLabel = (cat) => ({ men:'All Men', women:'All Women', boys:'All Boys', girls:'All Girls' }[cat] || `All ${cat}`);

    // Global All count — unique persons across every group.
    const allSeen = new Set();
    for (const g of this._groups) {
      for (const m of (g.members || [])) allSeen.add(m.person_id);
    }
    const totalAll = allSeen.size;

    // Per-category unique-person counts (dedupe across Club + Pickup).
    const catSeen = new Map(); // cat -> Set(person_id)
    for (const g of this._groups) {
      const cat = String(g.category || '').toLowerCase();
      if (!cat) continue;
      let set = catSeen.get(cat);
      if (!set) { set = new Set(); catSeen.set(cat, set); }
      for (const m of (g.members || [])) set.add(m.person_id);
    }

    const pillBase = 'padding:6px 12px; border-radius:999px; cursor:pointer;'
      + ' font-weight:600; font-size:0.85rem; border:1px solid var(--color-border);';
    const pillActive   = 'background:var(--color-primary, #2563eb); color:white;';
    const pillInactive = 'background:var(--bg-secondary); color:var(--text-primary);';

    const programChip = (pid, text, count, active) => `
      <button data-program-chip="${pid}"
              style="${pillBase} ${active ? pillActive : pillInactive}">
        ${text} <span style="opacity:0.7; font-weight:400;">(${count})</span>
      </button>`;

    const categoryChip = (cat, count, active) => `
      <button data-category-chip="${cat}"
              style="${pillBase} ${active ? pillActive : pillInactive}">
        ${emoji(cat)} ${catLabel(cat)} <span style="opacity:0.7; font-weight:400;">(${count})</span>
      </button>`;

    const chips = [
      programChip('all', '👥 All', totalAll,
                  this.programId == null && !this.categoryFilter),
    ];
    let seenCat = null;
    for (const g of this._groups) {
      const cat = String(g.category || '').toLowerCase();
      if (cat && cat !== seenCat) {
        // Insert the aggregate chip the first time we see this category.
        chips.push(categoryChip(cat,
                                (catSeen.get(cat) || new Set()).size,
                                this.categoryFilter === cat));
        seenCat = cat;
      }
      const label = `${emoji(cat)} ${g.label || g.program_name || 'Club'}`;
      const count = (g.members || []).length;
      chips.push(programChip(g.program_id, label, count,
                             Number(g.program_id) === this.programId));
    }

    el.innerHTML = chips.join(' ');
  }

  // Backward-compat shim for any legacy call sites that still use the
  // old category-chip name.  Redirects to the per-program renderer.
  _renderCategoryChips() { this._renderProgramChips(); }

  _updateSubtitle() {
    const subtitle = this.find('#members-subtitle');
    if (!subtitle) return;
    const groups = this._filteredGroups();
    // De-duplicate across groups so a person enrolled in both Club and
    // Pickup variants counts once in the aggregate views ("All Men",
    // "All", etc.).
    const seen = new Set();
    for (const g of groups) {
      for (const m of (g.members || [])) seen.add(m.person_id);
    }
    const total = seen.size;
    if (this.programId != null && groups.length === 1) {
      const g = groups[0];
      subtitle.textContent = `${g.label || g.program_name} — ${total} member${total === 1 ? '' : 's'}`;
    } else if (this.categoryFilter) {
      const catLabel = ({ men:'All Men', women:'All Women', boys:'All Boys', girls:'All Girls' }[this.categoryFilter] || `All ${this.categoryFilter}`);
      subtitle.textContent = `${catLabel} — ${total} unique member${total === 1 ? '' : 's'} across ${groups.length} sub-program${groups.length === 1 ? '' : 's'}`;
    } else {
      subtitle.textContent = `${total} unique member${total === 1 ? '' : 's'} across ${groups.length} sub-program${groups.length === 1 ? '' : 's'}`;
    }
  }

  _updateTitle() {
    const titleEl = this.find('#members-title');
    if (!titleEl) return;
    if (this.programId != null) {
      const g = (this._groups || []).find(x => Number(x.program_id) === this.programId);
      if (g) {
        const cat = String(g.category || '').toLowerCase();
        const emoji = ({ men:'👨', women:'👩', boys:'👦', girls:'👧' }[cat] || '👥');
        titleEl.textContent = `${emoji} ${g.label || g.program_name || 'Membership'}`;
        return;
      }
    }
    if (this.categoryFilter) {
      const cat = this.categoryFilter;
      const emoji = ({ men:'👨', women:'👩', boys:'👦', girls:'👧' }[cat] || '👥');
      const label = ({ men:'All Men', women:'All Women', boys:'All Boys', girls:'All Girls' }[cat] || `All ${cat}`);
      titleEl.textContent = `${emoji} ${label}`;
      return;
    }
    titleEl.textContent = '👥 Membership';
  }

  _updateVariantToggle() { /* removed — the Active/Pickup toggle is gone; each sub-program is its own chip now. */ }

  // Return the flat list of members currently in view (respects the
  // search filter).  Used to power bulk actions and the summary strip.
  // Sorted per the active sort pill so bulk exports (vCard, emails,
  // phones) come out in the same order the admin sees on screen.
  //
  // Applies four gates in order: category chip → status flags → sort
  // → search text.  Category + flags shrink the pool; search then
  // further narrows.  Sort runs in between so the emitted list stays
  // in card-display order even after the search filter runs.
  _visibleMembers() {
    const filter = this._filter;
    const matches = (m) => {
      if (!filter) return true;
      const hay = [
        m.first_name, m.last_name, m.email, m.phone, m.dob,
        `${m.first_name || ''} ${m.last_name || ''}`,
      ].map(v => (v || '').toLowerCase()).join(' ');
      return hay.includes(filter);
    };
    const passesFlags = (m) => this._passesStatusFlags(m);
    const out = [];
    for (const g of this._filteredGroups()) {
      for (const m of this._sortMembers((g.members || []).filter(passesFlags))) {
        if (matches(m)) out.push(m);
      }
    }
    return out;
  }

  // Both flags off === no filter (everyone visible).  Either flag on
  // narrows to matching members; both flags on unions the two buckets
  // ("no account" OR "dormant").  A member with no FH account never
  // matches "dormant" because dormant explicitly requires has_fh_account.
  _passesStatusFlags(m) {
    if (!this._flagNoAccount && !this._flagDormant) return true;
    const noAccount = !m.has_fh_account;
    const dormant   = !!m.has_fh_account
      && (m.days_since_activity == null || Number(m.days_since_activity) >= 8);
    return (this._flagNoAccount && noAccount)
        || (this._flagDormant   && dormant);
  }

  _renderBulkBar() {
    const bar = this.find('#members-bulk-bar');
    if (!bar) return;
    const visible = this._visibleMembers();
    const emails = [...new Set(visible.map(m => (m.email || '').trim()).filter(Boolean))];
    const phones = [...new Set(visible.map(m => this._phoneDigits(m.phone)).filter(Boolean))];

    if (visible.length === 0) {
      bar.style.display = 'none';
      return;
    }
    bar.style.display = 'flex';
    bar.innerHTML = `
      <div style="font-weight:600; margin-right: var(--space-2);">
        ${visible.length} in view
      </div>
      <button class="btn btn-sm btn-primary" data-bulk="email"
              ${emails.length ? '' : 'disabled'}
              title="Open Gmail with all ${emails.length} email${emails.length===1?'':'s'} as BCC">
        ✉️ Email All (${emails.length})
      </button>
      <button class="btn btn-sm btn-secondary" data-bulk="copy-emails"
              ${emails.length ? '' : 'disabled'}
              title="Copy emails to clipboard, comma-separated">
        📋 Copy emails
      </button>
      <button class="btn btn-sm btn-secondary" data-bulk="copy-phones"
              ${phones.length ? '' : 'disabled'}
              title="Copy phones to clipboard, comma-separated">
        📋 Copy phones
      </button>
      <button class="btn btn-sm btn-secondary" data-bulk="vcard"
              title="Download a single .vcf with all ${visible.length} contact${visible.length===1?'':'s'} — tap on phone to add to Contacts">
        👤 Save Contacts (${visible.length})
      </button>
    `;
  }

  _handleBulk(action) {
    const visible = this._visibleMembers();
    if (action === 'email') {
      const emails = [...new Set(visible.map(m => (m.email || '').trim()).filter(Boolean))];
      if (!emails.length) return;
      // Gmail compose URL — puts every email into the BCC field so the
      // list stays private between recipients.  `su=` presets the
      // account (Gmail ignores it if the user isn't logged into that
      // account, so it's a safe hint).
      const bcc = encodeURIComponent(emails.join(','));
      const url = `https://mail.google.com/mail/?view=cm&fs=1&tf=1&bcc=${bcc}`;
      window.open(url, '_blank', 'noopener');
      return;
    }
    if (action === 'copy-emails') {
      const emails = [...new Set(visible.map(m => (m.email || '').trim()).filter(Boolean))];
      this._copyToClipboard(emails.join(', '), `${emails.length} email${emails.length===1?'':'s'} copied`);
      return;
    }
    if (action === 'copy-phones') {
      const phones = [...new Set(visible.map(m => this._phoneDigits(m.phone)).filter(Boolean))];
      this._copyToClipboard(phones.join(', '), `${phones.length} phone${phones.length===1?'':'s'} copied`);
      return;
    }
    if (action === 'vcard') {
      // Bulk export — one .vcf file containing every visible member,
      // filename baked from selected sub-program (or "all") + count so
      // the file lands in Downloads with a recognisable name.  iOS/Android
      // Contacts apps happily import multi-entry vCards as a batch.
      if (!visible.length) return;
      let slug = 'all';
      if (this.programId != null) {
        const g = (this._groups || []).find(x => Number(x.program_id) === this.programId);
        if (g && g.label) {
          slug = String(g.label).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '') || 'all';
        }
      }
      const fname = `lighthouse-${slug}-${visible.length}-contacts.vcf`;
      this._downloadVcard(visible, fname);
      return;
    }
  }

  _copyToClipboard(text, successMsg) {
    if (!text) return;
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text)
        .then(() => this._toast(successMsg))
        .catch(() => this._fallbackCopy(text, successMsg));
    } else {
      this._fallbackCopy(text, successMsg);
    }
  }

  _fallbackCopy(text, successMsg) {
    const ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.left = '-9999px';
    document.body.appendChild(ta);
    ta.select();
    try {
      document.execCommand('copy');
      this._toast(successMsg);
    } catch (e) {
      alert('Copy failed — the values were:\n\n' + text);
    } finally {
      ta.remove();
    }
  }

  _toast(msg) {
    // Cheap, no-dep toast.  Clears itself after 2.5s.
    let t = this.find('#members-toast');
    if (!t) {
      t = document.createElement('div');
      t.id = 'members-toast';
      t.style.cssText = `
        position:fixed; bottom:24px; left:50%; transform:translateX(-50%);
        background:#0b3a2e; color:#a7f3d0; padding:10px 16px;
        border-radius:8px; font-weight:600; z-index:9999;
        box-shadow:0 4px 20px rgba(0,0,0,0.4);
        transition:opacity 0.25s;`;
      this.element.appendChild(t);
    }
    t.textContent = msg;
    t.style.opacity = '1';
    clearTimeout(this._toastT);
    this._toastT = setTimeout(() => { if (t) t.style.opacity = '0'; }, 2500);
  }

  _renderGroups() {
    const groupsEl = this.find('#members-groups');
    if (!groupsEl) return;

    const filter = this._filter;
    const matches = (m) => {
      if (!filter) return true;
      const hay = [
        m.first_name, m.last_name, m.email, m.phone, m.dob,
        `${m.first_name || ''} ${m.last_name || ''}`,
      ].map(v => (v || '').toLowerCase()).join(' ');
      return hay.includes(filter);
    };

    const html = this._filteredGroups().map(g => {
      const members = this._sortMembers(
        (g.members || []).filter(m => this._passesStatusFlags(m)).filter(matches)
      );
      const count = members.length;
      // Verb used in the "since" line — per-group so "Pickup since" only
      // appears for pickup-variant sub-programs.
      const sinceLabel = (String(g.variant || '').toLowerCase() === 'pickup') ? 'Pickup since' : 'Joined';
      const cards = members.map(m => this._renderCard(m, sinceLabel)).join('');

      // Skip empty groups when filtering.
      if (filter && count === 0) return '';

      return `
        <section style="margin-bottom: var(--space-5);">
          <h3 style="margin: 0 0 var(--space-2); opacity:0.9;">
            ${this._esc(g.label || 'Members')}
            <span style="opacity:0.6; font-weight:400; font-size:0.85rem;">(${count})</span>
          </h3>
          <p style="opacity:0.6; font-size:0.8rem; margin: 0 0 var(--space-3);">
            ${this._esc(g.program_name || '')}
          </p>
          ${count === 0
            ? `<div style="opacity:0.5; font-style:italic;">No members.</div>`
            : `<div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: var(--space-3);">${cards}</div>`}
        </section>
      `;
    }).join('');

    groupsEl.innerHTML = html || `<div style="opacity:0.6; text-align:center; padding: var(--space-4);">No matches.</div>`;
  }

  _renderCard(m, sinceLabel) {
    const name  = `${m.first_name || ''} ${m.last_name || ''}`.trim() || '(no name)';
    const email = m.email || '';
    const phone = m.phone || '';
    const phoneDigits = this._phoneDigits(phone);
    const dob   = m.dob || '';
    const joined = m.joined_at ? new Date(m.joined_at).toLocaleDateString() : '';
    // Dormancy chip — sits right under the name so it's the first
    // thing an admin scans.  See `_activityChip` for the color bands.
    const activityChip = this._activityChip(m);
    // "Next step" widget — sends the right onboarding message for the
    // person's current state (no account / never logged in / done).
    // See `_onboardingSection` for the copy per state.
    const onboardingSection = this._onboardingSection(m);
    // Youth (boys/girls) usually have contact info on the parent row;
    // the API returns the parent value when the child has none and flags
    // it so we can label it clearly.
    const emailViaParent = !!m.email_via_parent;
    const phoneViaParent = !!m.phone_via_parent;
    const parentTag = m.parent_name
      ? ` <span style="opacity:0.6; font-size:0.7rem;">(via ${this._esc(m.parent_name)})</span>`
      : ` <span style="opacity:0.6; font-size:0.7rem;">(via parent)</span>`;

    const dobLine = dob
      ? `<div style="font-size:0.8rem; opacity:0.75;">🎂 ${this._esc(this._fmtDob(dob))}</div>`
      : '';
    const emailLine = email
      ? `<div style="font-size:0.85rem; opacity:0.85;">✉ ${this._esc(email)}${emailViaParent ? parentTag : ''}</div>`
      : '';
    const phoneLine = phone
      ? `<div style="font-size:0.85rem; opacity:0.85;">📞 ${this._esc(this._fmtPhone(phone))}${phoneViaParent ? parentTag : ''}</div>`
      : '';

    const buttons = [];
    if (email) {
      // Gmail compose (not mailto:) so it opens in the operator's Gmail
      // tab rather than Apple Mail / Outlook.  Pre-fill a short body
      // that asks the recipient to reply — that reply is what opens
      // a communication channel even for people who aren't on FH yet.
      const subject = `Football Home — checking in`;
      const body    =
        `Hey ${(m.first_name || '').trim() || 'there'},\n\n` +
        `Just checking in — please reply and let me know you got this so ` +
        `I know I have the right email for you.\n\n` +
        `--James Breslin\nSoccer Director at Lighthouse`;
      const gmailUrl =
        `https://mail.google.com/mail/?view=cm&fs=1&tf=1` +
        `&to=${encodeURIComponent(email)}` +
        `&su=${encodeURIComponent(subject)}` +
        `&body=${encodeURIComponent(body)}`;
      buttons.push(
        `<a href="${gmailUrl}" target="_blank" rel="noopener"
             style="padding:5px 10px; border-radius:4px; text-decoration:none;
                    background:#0b3a2e; color:#a7f3d0; border:1px solid #10b981;
                    font-size:0.75rem; font-weight:700;">✉️ Email</a>`
      );
    }
    if (phoneDigits && m.phone_sms !== false) {
      buttons.push(
        `<a href="sms:${phoneDigits}"
             style="padding:5px 10px; border-radius:4px; text-decoration:none;
                    background:#3a2e05; color:#fde68a; border:1px solid #d97706;
                    font-size:0.75rem; font-weight:700;">💬 Text</a>`
      );
    }
    if (phoneDigits && m.phone_call !== false) {
      buttons.push(
        `<a href="tel:${phoneDigits}"
             style="padding:5px 10px; border-radius:4px; text-decoration:none;
                    background:#1f2937; color:#e5e7eb; border:1px solid #4b5563;
                    font-size:0.75rem; font-weight:700;">📞 Call</a>`
      );
    }
    // "Save" → download a single-contact vCard.  Always offered (even
    // when there's no phone/email) so admins can still stash a name +
    // DOB + person_id reference in their phone book.
    if (m.person_id) {
      buttons.push(
        `<button type="button" data-vcard-person-id="${m.person_id}"
                 style="padding:5px 10px; border-radius:4px; cursor:pointer;
                        background:#111827; color:#c7d2fe; border:1px solid #4b5563;
                        font-size:0.75rem; font-weight:700;">👤 Save</button>`
      );
    }
    const btnRow = buttons.length
      ? `<div style="display:flex; gap:6px; margin-top: var(--space-2); flex-wrap:wrap;">${buttons.join('')}</div>`
      : '';

    return `
      <div class="paused-card" style="background: var(--bg-secondary);
            border-radius: var(--radius-md); padding: var(--space-3);
            border: 1px solid var(--color-border);
            display:flex; flex-direction:column; gap:4px;">
        <div style="font-weight:600;">${this._esc(name)}</div>
        ${activityChip}
        ${onboardingSection}
        ${dobLine}
        ${emailLine}
        ${phoneLine}
        ${joined ? `<div style="font-size:0.75rem; opacity:0.6; margin-top: var(--space-1);">
                      ${this._esc(sinceLabel)} ${this._esc(joined)}
                    </div>` : ''}
        ${btnRow}
      </div>
    `;
  }

  // ── Onboarding "next step" widget ───────────────────────────────
  // Small widget under the activity chip that either flags "✅ Onboarded"
  // (green pill, no action needed) or renders per-member outreach
  // buttons pre-populated with the *specific* next step for their
  // current funnel state.
  //
  // States:
  //   Onboarded          — has_fh_account && days_since_activity != null.
  //                        Any activity ever = they've crossed the FH
  //                        threshold, so we don't nudge them here even
  //                        if they're currently dormant (that's a
  //                        re-engagement problem, not onboarding).
  //   🚫 No account      — needs to sign in with Google for the first
  //                        time.  Body carries the 1-click CTA.
  //   💤 Never logged in — account exists but they've never actually
  //                        authenticated against the new backend.
  //                        Body says "you're set up, come use it".
  //
  // Ships as plain mailto:/sms: URIs — no SMTP infra needed.  Admin
  // taps the button, native mail/messages app opens with the body
  // pre-filled, admin can edit before send.
  _onboardingSection(m) {
    const first  = (m.first_name || '').trim() || 'there';
    const email  = (m.email || '').trim();
    const phoneD = this._phoneDigits(m.phone || '');
    const canEmail = !!email;
    const canText  = !!phoneD && m.phone_sms !== false;

    // ✅ Onboarded → single green pill, no buttons.
    if (m.has_fh_account && m.days_since_activity != null) {
      return `<div style="display:inline-flex; align-items:center; gap:4px;
                          align-self:flex-start; padding:2px 8px; border-radius:999px;
                          font-size:0.7rem; font-weight:700;
                          background:#0b3a2e; color:#a7f3d0; border:1px solid #10b981;">
                ✅ Onboarded
              </div>`;
    }

    // Pick copy by state.
    let step, subject, body;
    if (!m.has_fh_account) {
      step    = 'Sign in with Google';
      subject = 'Welcome to the club — join us on FootballHome';
      body    = `Hey ${first},\n\n` +
                `Welcome to the club! This is where practices, pickups, and ` +
                `games are listed: FootballHome.\n\n` +
                `Please go to https://footballhome.org and tap "Sign in with Google" ` +
                `(5 seconds, uses your Gmail), then set your availability accurately ` +
                `for the week.\n\n` +
                `Please reply and let me know you got this so I know I have the ` +
                `right contact info for you.\n\n` +
                `--James Breslin Soccer Director at Lighthouse`;
    } else {
      step    = 'First visit — set your availability';
      subject = 'Welcome to the club — set your availability on FootballHome';
      body    = `Hey ${first},\n\n` +
                `Welcome to the club! This is where practices, pickups, and ` +
                `games are listed: FootballHome.\n\n` +
                `You're already set up — please log in at https://footballhome.org ` +
                `and set your availability accurately for the week.\n\n` +
                `Please reply and let me know you got this so I know I have the ` +
                `right contact info for you.\n\n` +
                `--James Breslin Soccer Director at Lighthouse`;
    }

    const encSubject = encodeURIComponent(subject);
    const encBody    = encodeURIComponent(body);
    // Gmail compose — not mailto: — so the operator's Gmail tab
    // handles it instead of Apple Mail.  `to=` puts the recipient in
    // the To field; the &su/&body params are the same names Gmail's
    // compose URL uses.
    const gmailUrl =
      `https://mail.google.com/mail/?view=cm&fs=1&tf=1` +
      `&to=${encodeURIComponent(email)}` +
      `&su=${encSubject}` +
      `&body=${encBody}`;

    const buttons = [];
    if (canEmail) {
      buttons.push(
        `<a href="${gmailUrl}"
            target="_blank" rel="noopener"
            style="padding:4px 10px; border-radius:4px; text-decoration:none;
                   background:#0b3a2e; color:#a7f3d0; border:1px solid #10b981;
                   font-size:0.7rem; font-weight:700;">✉️ Email</a>`
      );
    }
    if (canText) {
      buttons.push(
        `<a href="sms:${phoneD}?body=${encBody}"
            style="padding:4px 10px; border-radius:4px; text-decoration:none;
                   background:#3a2e05; color:#fde68a; border:1px solid #d97706;
                   font-size:0.7rem; font-weight:700;">💬 Text</a>`
      );
    }

    const noContactHint = buttons.length ? '' :
      `<div style="font-size:0.7rem; opacity:0.65;">
         (no email/phone on file — reach out in person)
       </div>`;

    return `
      <div style="background: rgba(59,130,246,0.06);
                  border: 1px solid rgba(59,130,246,0.28);
                  border-radius: var(--radius-sm);
                  padding: 6px 8px;
                  display:flex; flex-direction:column; gap:4px;
                  margin-top: 2px;">
        <div style="font-size:0.65rem; font-weight:700; opacity:0.75;
                    letter-spacing:0.05em; text-transform:uppercase;">
          📣 Onboarding — ${this._esc(step)}
        </div>
        ${buttons.length ? `<div style="display:flex; gap:6px; flex-wrap:wrap;">${buttons.join('')}</div>` : ''}
        ${noContactHint}
      </div>
    `;
  }

  // ── Activity chip ────────────────────────────────────────────────
  // Small color-coded pill on each member card that answers "is this
  // person engaged with FH?" at a glance.  Backend supplies two
  // fields on every member row:
  //   has_fh_account       (bool)   — do they have a `users` row?
  //   days_since_activity  (int|nl) — floor((NOW - last_seen_at)/24h),
  //                                    NULL when no account or account
  //                                    has never sent an authenticated
  //                                    request.
  // Bands:
  //   🚫 Never   — no FH account at all.
  //   💤 Never   — account exists, has never logged in.
  //   ⏰ 0–7d    — green   (active within the past week + 1d cushion).
  //   ⏰ 8d+     — red     (dormant — needs a nudge or is cold).
  _activityChip(m) {
    const chip = (bg, fg, border, text) =>
      `<div style="display:inline-flex; align-items:center; gap:4px;
                   align-self:flex-start; padding:2px 8px; border-radius:999px;
                   font-size:0.7rem; font-weight:700;
                   background:${bg}; color:${fg}; border:1px solid ${border};">${text}</div>`;

    if (!m.has_fh_account) {
      return chip('#1f2937', '#9ca3af', '#374151', '🚫 No account');
    }
    const raw = m.days_since_activity;
    if (raw == null) {
      return chip('#3f1d1d', '#fecaca', '#7f1d1d', '💤 Never logged in');
    }
    const d = Number(raw);
    if (!Number.isFinite(d) || d < 0) {
      return chip('#1f2937', '#9ca3af', '#374151', '⏰ unknown');
    }
    if (d < 8) {
      return chip('#0b3a2e', '#a7f3d0', '#10b981', `⏰ ${d === 0 ? 'today' : d + 'd'}`);
    }
    return chip('#3f1d1d', '#fecaca', '#b91c1c', `⏰ ${d}d`);
  }

  // ── vCard export ─────────────────────────────────────────────────
  // Client-side .vcf generation — no backend endpoint needed since
  // the row already carries first_name / last_name / email / phone /
  // dob / person_id / joined_at.  Format is vCard 3.0 (widest
  // compatibility with iOS Contacts, Android Contacts, macOS
  // Contacts, Google Contacts).  Multi-entry vCards are just
  // concatenated BEGIN/END:VCARD blocks separated by CRLF.

  _vcardEscape(s) {
    // vCard 3.0 spec: escape backslash, comma, semicolon, and newlines.
    // Anything else passes through verbatim (Contacts apps are lenient
    // about the rest).
    return String(s == null ? '' : s)
      .replace(/\\/g, '\\\\')
      .replace(/\n/g, '\\n')
      .replace(/\r/g, '')
      .replace(/,/g, '\\,')
      .replace(/;/g, '\\;');
  }

  _vcardPhone(phone) {
    // Normalise to E.164 when we can (10 digits → +1XXX, 11 starting
    // with 1 → +1XXX).  Anything else we emit as-is so international
    // formats or weird placeholders still round-trip.
    const d = this._phoneDigits(phone);
    if (d.length === 10)                       return `+1${d}`;
    if (d.length === 11 && d.startsWith('1'))  return `+${d}`;
    return d || String(phone || '');
  }

  _generateVcard(m) {
    const esc   = (s) => this._vcardEscape(s);
    const first = (m.first_name || '').trim();
    const last  = (m.last_name  || '').trim();
    const fn    = `${first} ${last}`.trim() || `Person #${m.person_id || ''}`.trim();
    const email = (m.email || '').trim();
    const phone = this._vcardPhone(m.phone);
    const joined = m.joined_at
      ? new Date(m.joined_at).toLocaleDateString()
      : '';
    // NOTE keeps enough breadcrumb that a reimport / manual lookup
    // later can trace the row back to the FH person record.
    const noteParts = [];
    if (m.person_id) noteParts.push(`FH person #${m.person_id}`);
    if (joined)      noteParts.push(`joined ${joined}`);
    const note = noteParts.join(' · ');

    const lines = [
      'BEGIN:VCARD',
      'VERSION:3.0',
      `FN:${esc(fn)}`,
      `N:${esc(last)};${esc(first)};;;`,
    ];
    if (phone) lines.push(`TEL;TYPE=CELL:${esc(phone)}`);
    if (email) lines.push(`EMAIL;TYPE=INTERNET:${esc(email)}`);
    lines.push('ORG:Lighthouse 1893 SC');
    if (note)        lines.push(`NOTE:${esc(note)}`);
    if (m.person_id) lines.push(`X-FH-PERSON-ID:${m.person_id}`);
    lines.push('END:VCARD');
    return lines.join('\r\n');
  }

  _downloadVcard(members, filename) {
    if (!members || !members.length) return;
    const body = members.map(m => this._generateVcard(m)).join('\r\n') + '\r\n';
    const blob = new Blob([body], { type: 'text/vcard;charset=utf-8' });
    const url  = URL.createObjectURL(blob);
    const a    = document.createElement('a');
    a.href = url;
    a.download = filename || 'contacts.vcf';
    document.body.appendChild(a);
    a.click();
    a.remove();
    // Revoke slightly later so mobile Safari has time to hand the file
    // off to the Contacts app.
    setTimeout(() => URL.revokeObjectURL(url), 5000);
    this._toast(members.length === 1
      ? `Saved ${(members[0].first_name || '').trim()} ${(members[0].last_name || '').trim()}.vcf`.trim()
      : `Saved ${members.length} contacts to ${filename}`);
  }

  // ── Formatters ────────────────────────────────────────────────────
  _fmtDob(ymd) {
    if (!ymd) return '';
    const s = String(ymd);
    const mt = s.match(/^(\d{4})-(\d{2})-(\d{2})/);
    if (!mt) return s;
    const y  = Number(mt[1]);
    const mo = Number(mt[2]);
    const d  = Number(mt[3]);
    const now = new Date();
    let age = now.getUTCFullYear() - y;
    const m2 = now.getUTCMonth() + 1;
    const d2 = now.getUTCDate();
    if (m2 < mo || (m2 === mo && d2 < d)) age -= 1;
    return `${mo}/${d}/${y} (age ${age})`;
  }

  _phoneDigits(s) {
    return String(s || '').replace(/\D+/g, '');
  }

  _fmtPhone(s) {
    const d = this._phoneDigits(s);
    if (d.length === 10) return `(${d.slice(0,3)}) ${d.slice(3,6)}-${d.slice(6)}`;
    if (d.length === 11 && d.startsWith('1')) return `+1 (${d.slice(1,4)}) ${d.slice(4,7)}-${d.slice(7)}`;
    return s;
  }

  _esc(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }
}
