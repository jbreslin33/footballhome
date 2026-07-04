// TeamHubScreen — unified roster + lineup + practice page.
//
// Replaces the split between game-day-roster.js and game-day-lineup.js with
// a single screen that is consistent regardless of whether the team has an
// upcoming match scheduled.
//
// ── States ─────────────────────────────────────────────────────────────
//   A. Match upcoming   → game card shows ⚽ match, pitch/zones active,
//                         sparkline anchored to match date
//   B. Match picked     → coach picked a non-default match from the picker,
//                         same as (A) but anchored to picked date
//   C. No upcoming match → 👻 ghost game card, pitch greyed out, sparkline
//                         anchored to FURTHEST FUTURE scheduled training
//                         session (walk back 5 sessions)
//
// ── Two-roster model ───────────────────────────────────────────────────
//   Internal roster   = "coach says this player is on the team" (drag adds them)
//   Official roster   = `player.onOfficialRoster` (explicit ✅/☐ toggle)
//
// ── Phase 1 (this file as initially shipped) ──────────────────────────
//   • Page shell + ghost game card + anchor resolution
//   • Pool sidebar lists the team's roster (`/api/teams/:teamId/roster`)
//   • Sparkline placeholder (real component lands in Phase 2)
//   • Right pane is an empty stage that Phase 2 will populate with pitch
//     + bench + alternates (reusing handlers from game-day-lineup.js)
//
// Old game-day-* screens remain registered and reachable; this screen is
// added as a separate route (`team-hub`) so it can be tested side-by-side
// before the swap.
class TeamHubScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this._teamMatches = [];
    this._anchorMatch = null;     // {id, title, event_date} when state A/B
    this._roster      = [];       // players from /api/teams/:teamId/roster
    this._sessions    = [];       // Phase 2: walked-back session window
    this._loadToken   = 0;        // ignore late responses from prior loads
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-team-hub';
    div.innerHTML = `
      <style>
        /* Screen-wide font bump for team-hub strip + pool sidebar. */
        .screen-team-hub #th-gamecard-title { font-size: 1.4rem !important; }
        .screen-team-hub #th-gamecard-sub   { font-size: 1.15rem !important; }
        .screen-team-hub #th-pool-count     { font-size: 1.1rem !important; }
        .screen-team-hub #th-pool-search    { font-size: 1.15rem !important; padding: 10px 12px !important; }
        .screen-team-hub .th-pool-chip      { font-size: 1.15rem !important; padding: 10px 12px !important; }
        .screen-team-hub #th-strip-caption  { font-size: 1.05rem !important; }
        .screen-team-hub [data-event-id]    { min-height: 195px !important; padding: 16px !important; }
        .screen-team-hub [data-event-id] > div:first-child > span[style*="text-transform:uppercase"] { font-size: 1.1rem !important; }
        .screen-team-hub [data-event-id] > div:first-child > span:first-child { font-size: 2rem !important; }
        .screen-team-hub [data-event-id] > div[title]        { font-size: 1.5rem !important; }
        .screen-team-hub [data-event-id] > div:nth-of-type(3){ font-size: 1.25rem !important; }
        .screen-team-hub [data-event-id] > div:nth-of-type(4){ font-size: 1.15rem !important; }
        .screen-team-hub [data-event-id] button              { font-size: 1.15rem !important; padding: 11px 12px !important; }
      </style>

      <div class="screen-header" style="display:flex;align-items:center;gap:var(--space-3);padding:var(--space-3);">
        <button class="btn btn-secondary btn-sm" data-action="back">← Back</button>
        <h1 id="th-team-title" style="margin:0;font-size:1.5rem;">Team Hub</h1>
        <span style="flex:1"></span>
        <span id="th-state-badge" class="th-state-badge" style="font-size:0.85rem;padding:4px 10px;border-radius:9999px;background:rgba(148,163,184,0.2);color:#cbd5e1;">…</span>
      </div>

      <!-- Game card — real match in state A/B, 👻 ghost in state C -->
      <div id="th-gamecard" style="margin:0 var(--space-3) var(--space-3);padding:var(--space-3);border-radius:10px;background:linear-gradient(180deg,rgba(15,23,42,0.85),rgba(15,23,42,0.55));border:1px solid rgba(148,163,184,0.25);min-height:64px;display:flex;align-items:center;gap:var(--space-3);">
        <div id="th-gamecard-icon" style="font-size:2rem;">⚽</div>
        <div style="flex:1;min-width:0;">
          <div id="th-gamecard-title" style="font-weight:600;color:#e2e8f0;font-size:1.15rem;">Loading…</div>
          <div id="th-gamecard-sub"   style="font-size:0.95rem;color:#94a3b8;margin-top:4px;">—</div>
        </div>
        <select id="th-match-picker" style="display:none;font-size:0.95rem;padding:6px 10px;border-radius:6px;background:#0f172a;color:#e2e8f0;border:1px solid rgba(148,163,184,0.3);"></select>
      </div>

      <!-- Body: two-column layout. Pool sidebar (left) + Stage (right). -->
      <div id="th-body" style="display:grid;grid-template-columns:260px 1fr;gap:var(--space-3);padding:0 var(--space-3) var(--space-3);align-items:start;">
        <aside id="th-pool" style="position:sticky;top:var(--space-3);max-height:calc(100vh - 200px);overflow:auto;padding:var(--space-3);border-radius:10px;background:rgba(15,23,42,0.55);border:1px solid rgba(148,163,184,0.2);">
          <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:var(--space-2);">
            <h3 style="margin:0;font-size:1rem;color:#cbd5e1;letter-spacing:0.04em;text-transform:uppercase;">👥 Pool</h3>
            <span id="th-pool-count" style="font-size:0.85rem;color:#94a3b8;">0</span>
          </div>
          <input id="th-pool-search" type="search" placeholder="Search players…" style="width:100%;font-size:0.95rem;padding:8px 10px;border-radius:6px;background:#0f172a;color:#e2e8f0;border:1px solid rgba(148,163,184,0.3);margin-bottom:var(--space-2);">
          <div id="th-pool-list"></div>
        </aside>
        <main id="th-stage" style="min-width:0;min-height:60vh;display:flex;flex-direction:column;gap:var(--space-3);">
          <!-- Lead-up strip — 6 columns, left→right = oldest→newest.
               Columns 1..5 = the 5 practice/pickup events leading up
               to the anchor game, column 6 = the anchor game itself
               (rightmost).  Practices/pickups live on the pool teams'
               calendars (via the chat_event_create_match trigger) and
               are merged into this team's events in _loadAll. -->
          <section id="th-strip-wrap" style="padding:var(--space-3);border-radius:10px;background:rgba(15,23,42,0.55);border:1px solid rgba(148,163,184,0.2);">
            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:var(--space-2);">
              <h3 style="margin:0;font-size:1rem;color:#cbd5e1;letter-spacing:0.04em;text-transform:uppercase;">📅 Lead-up to next game</h3>
              <span id="th-strip-caption" style="font-size:0.85rem;color:#94a3b8;">—</span>
            </div>
            <div id="th-strip" style="display:grid;grid-template-columns:repeat(6, minmax(180px, 1fr));gap:10px;overflow-x:auto;padding-bottom:4px;">
              <div style="grid-column: 1 / -1; font-size:0.95rem;color:#64748b;padding:var(--space-2) 0;">Loading events…</div>
            </div>
          </section>

          <!-- Phase 2 pitch placeholder retained so subsequent phases can
               drop into an existing slot without another restructure. -->
          <section id="th-stage-pitch" style="padding:var(--space-4);border-radius:10px;background:rgba(15,23,42,0.45);border:1px dashed rgba(148,163,184,0.25);color:#94a3b8;text-align:center;">
            <div style="font-size:0.85rem;">⚽ Pitch + Bench + Alternates land here in Phase 2</div>
            <div id="th-sparkline-placeholder" style="margin-top:var(--space-3);font-size:0.78rem;color:#64748b;"></div>
          </section>
        </main>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    // Allow callers to pass {teamId, teamName} or rely on nav context.
    if (params?.teamId) {
      this.navigation.context.team = {
        id: params.teamId,
        name: params.teamName || this.navigation.context.team?.name || 'Team',
        clubId: params.clubId ?? this.navigation.context.team?.clubId ?? null,
      };
    }
    if (params?.lineupTeamId) {
      this.navigation.context.lineupTeamId = params.lineupTeamId;
    }
    // Cache club id explicitly so the pool-matches fetch can find it
    // even if navigation.context.team.clubId is missing.
    this._clubIdParam = params?.clubId
      ?? this.navigation.context.team?.clubId
      ?? this.navigation.context.club?.id
      ?? null;

    const team = this.navigation.context.team;
    const titleEl = this.find('#th-team-title');
    if (titleEl) titleEl.textContent = team?.name ? `${team.name} — Hub` : 'Team Hub';

    this._wireEvents();
    this._loadAll();
  }

  onExit() {
    this._loadToken++; // invalidate any in-flight load
  }

  _wireEvents() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('[data-action="back"]')) {
        this.navigation.goBack();
        return;
      }
      // Take-attendance: jump to the working match-rsvp-management
      // screen (the older practice-attendance screen queries dead
      // tables — events, practices, attendance_statuses — that don't
      // exist in this schema).  We pass the specific matchId as a
      // param so the target screen can auto-expand that row.
      const attBtn = e.target.closest('[data-attendance-open]');
      if (attBtn) {
        e.preventDefault();
        e.stopPropagation();
        const matchId = parseInt(attBtn.dataset.attendanceOpen, 10);
        this.navigation.goTo('match-rsvp-management', {
          matchId: Number.isFinite(matchId) && matchId > 0 ? matchId : undefined,
        });
        return;
      }
      // Edit event — reuse the existing match-form screen in edit mode.
      // Practices/pickups are a single row in `matches` shared across
      // teams (pool teams' calendars mirror to member teams), so an
      // edit here is inherently global.
      const editBtn = e.target.closest('[data-event-edit]');
      if (editBtn) {
        e.preventDefault();
        e.stopPropagation();
        const matchId = parseInt(editBtn.dataset.eventEdit, 10);
        if (Number.isFinite(matchId) && matchId > 0) {
          this.navigation.goTo('match-form', { mode: 'edit', matchId });
        }
        return;
      }
      // Delete event — single DELETE /api/matches/:id row removal.
      // Cascades to events + RSVPs; propagates to every team calendar
      // that referenced this match (pool + member teams).
      const delBtn = e.target.closest('[data-event-delete]');
      if (delBtn) {
        e.preventDefault();
        e.stopPropagation();
        const matchId = parseInt(delBtn.dataset.eventDelete, 10);
        if (Number.isFinite(matchId) && matchId > 0) {
          this._deleteEvent(matchId, delBtn);
        }
        return;
      }
    });
    const picker = this.find('#th-match-picker');
    if (picker) {
      picker.addEventListener('change', (e) => this._onMatchPicked(e.target.value));
    }
    const search = this.find('#th-pool-search');
    if (search) {
      search.addEventListener('input', () => this._renderPool());
    }
  }

  // ── Data load ─────────────────────────────────────────────────────────

  async _loadAll() {
    const teamId = this._teamId();
    if (!teamId) {
      this._setStateBadge('error', 'No team in context');
      return;
    }
    const token = ++this._loadToken;
    this._setStateBadge('loading', 'Loading…');

    // Load own matches + roster in parallel.  Pool matches are fetched
    // in a follow-up step because we need the club id first (which may
    // arrive via /api/clubs/:id if not in nav context).
    const [matches, roster, poolMatches] = await Promise.all([
      this._fetchMatches(teamId),
      this._fetchRoster(teamId),
      this._fetchPoolMatches(),
    ]);
    if (token !== this._loadToken) return; // superseded

    this._teamMatches = matches;
    this._roster      = roster;

    // Merge own + pool matches by id.  For pool teams this is
    // effectively a no-op (own already includes them); for club teams
    // like U23 / APSL / Liga this brings in the shared practice+pickup
    // events so they can appear in the lead-up strip.
    const byId = new Map();
    [...matches, ...poolMatches].forEach(m => {
      if (m && m.id != null && !byId.has(m.id)) byId.set(m.id, m);
    });
    this._allEvents = [...byId.values()];

    this._anchorMatch = this._pickAnchor(this._allEvents);

    this._renderGameCard();
    this._renderMatchPicker();
    this._renderPool();
    this._renderStrip();
    this._renderSparklinePlaceholder();
    this._setStateBadge(this._anchorMatch ? 'live' : 'no-match',
                        this._anchorMatch ? 'Match scheduled' : '👻 No upcoming match');
  }

  async _fetchMatches(teamId) {
    try {
      const res = await this.auth.fetch(`/api/matches/team/${teamId}`);
      const data = await res.json();
      return data?.data || [];
    } catch (err) {
      console.warn('[team-hub] fetch matches failed:', err);
      return [];
    }
  }

  async _fetchRoster(teamId) {
    try {
      const res = await this.auth.fetch(`/api/teams/${teamId}/roster`);
      const data = await res.json();
      // Backend may return { data: [...] } OR a bare array — normalise.
      const arr = Array.isArray(data?.data) ? data.data
                : Array.isArray(data) ? data
                : [];
      return arr;
    } catch (err) {
      console.warn('[team-hub] fetch roster failed:', err);
      return [];
    }
  }

  // Fetch matches for the club's pool teams (Practice, Pickup, …) so
  // the lead-up strip on a NON-POOL team page (U23 / APSL / Liga) can
  // show the shared practice+pickup events that live on those pool
  // teams' calendars.  For a pool team page itself this returns
  // matches we already have — the merge in _loadAll dedupes by id.
  async _fetchPoolMatches() {
    const clubId = this.navigation.context?.team?.clubId
                ?? this.navigation.context?.club?.id
                ?? this._clubIdParam;
    if (!clubId) return [];
    try {
      const res = await this.auth.fetch(`/api/clubs/${clubId}?gender=all`);
      const payload = await res.json();
      const club = payload?.data || payload;
      const teams = Array.isArray(club?.teams) ? club.teams : [];
      const poolIds = teams.filter(t => t.is_pool).map(t => t.id);
      if (!poolIds.length) return [];
      const results = await Promise.all(poolIds.map(id => this._fetchMatches(id)));
      return results.flat();
    } catch (err) {
      console.warn('[team-hub] fetch pool matches failed:', err);
      return [];
    }
  }

  _pickNextMatch(matches) {
    if (!matches?.length) return null;
    const now = Date.now();
    // 3-hour live window so a kicked-off match still counts as current
    const liveCutoff = now - 3 * 60 * 60 * 1000;
    const asc = [...matches].sort(
      (a, b) => new Date(a.event_date).getTime() - new Date(b.event_date).getTime()
    );
    return asc.find(m => !m.has_ended && new Date(m.event_date).getTime() >= liveCutoff) || null;
  }

  // Preferred anchor is the next real GAME (match_type_id NOT IN
  // {3 practice, 7 pickup}) so the strip shows "lead-up to the game".
  // Fallbacks:
  //   1. Next event of any type (practice/pickup) if no game scheduled
  //   2. Most recent past event (so the strip is never empty when data exists)
  _pickAnchor(events) {
    if (!events?.length) return null;
    const now = Date.now();
    const liveCutoff = now - 3 * 60 * 60 * 1000;
    const asc = [...events].sort(
      (a, b) => new Date(a.event_date).getTime() - new Date(b.event_date).getTime()
    );
    // Strict: rely on match_type_id — no title regex.  Data is clean
    // now (pool 908 = 3, pool 909 = 7).
    const isNonGame = (m) => {
      const t = Number(m.match_type_id ?? m.match_type);
      return t === 3 || t === 7;
    };
    const nextGame = asc.find(m =>
      !isNonGame(m) && new Date(m.event_date).getTime() >= liveCutoff && !m.has_ended
    );
    if (nextGame) return nextGame;
    const nextAny = asc.find(m => new Date(m.event_date).getTime() >= liveCutoff && !m.has_ended);
    if (nextAny) return nextAny;
    return asc[asc.length - 1] || null;
  }

  // ── Render ────────────────────────────────────────────────────────────

  _renderGameCard() {
    const icon = this.find('#th-gamecard-icon');
    const ttl  = this.find('#th-gamecard-title');
    const sub  = this.find('#th-gamecard-sub');
    if (!icon || !ttl || !sub) return;

    if (this._anchorMatch) {
      const m = this._anchorMatch;
      const d = new Date(m.event_date);
      icon.textContent = '⚽';
      ttl.textContent  = m.title || 'Upcoming match';
      sub.textContent  = isNaN(d) ? '' : d.toLocaleString(undefined, {
        weekday: 'short', month: 'short', day: 'numeric',
        hour: 'numeric', minute: '2-digit'
      });
    } else {
      // 👻 Ghost card — keeps the layout identical so the rest of the UI
      // doesn't shift when a match drops onto the calendar.
      icon.textContent = '👻';
      ttl.textContent  = 'No upcoming match';
      sub.textContent  = 'Managing season roster';
    }
  }

  _renderMatchPicker() {
    const sel = this.find('#th-match-picker');
    if (!sel) return;
    if (!this._teamMatches.length) {
      sel.style.display = 'none';
      return;
    }
    const now = Date.now();
    const asc = [...this._teamMatches].sort(
      (a, b) => new Date(a.event_date).getTime() - new Date(b.event_date).getTime()
    );
    const upcoming = asc.filter(m => new Date(m.event_date).getTime() >= now - 3 * 60 * 60 * 1000);
    const past     = asc.filter(m => new Date(m.event_date).getTime() <  now - 3 * 60 * 60 * 1000).slice(-5).reverse();
    const fmt = (m) => {
      const d = new Date(m.event_date);
      const ds = isNaN(d) ? '' : d.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
      return `${ds} — ${m.title || 'Match'}`;
    };
    const currentId = String(this._anchorMatch?.id || '');
    const opts = [];
    if (upcoming.length) {
      opts.push('<optgroup label="Upcoming / live">');
      upcoming.forEach(m => opts.push(
        `<option value="${m.id}"${String(m.id) === currentId ? ' selected' : ''}>${this.escapeHtml(fmt(m))}</option>`
      ));
      opts.push('</optgroup>');
    }
    if (past.length) {
      opts.push('<optgroup label="Recent past">');
      past.forEach(m => opts.push(
        `<option value="${m.id}"${String(m.id) === currentId ? ' selected' : ''}>${this.escapeHtml(fmt(m))}</option>`
      ));
      opts.push('</optgroup>');
    }
    sel.innerHTML = opts.join('');
    sel.style.display = '';
  }

  _renderPool() {
    const list  = this.find('#th-pool-list');
    const count = this.find('#th-pool-count');
    if (!list) return;

    const term = (this.find('#th-pool-search')?.value || '').trim().toLowerCase();
    const all  = this._roster || [];
    const filtered = term
      ? all.filter(p => this._playerLabel(p).toLowerCase().includes(term))
      : all;

    if (count) count.textContent = String(filtered.length);

    if (!filtered.length) {
      list.innerHTML = `<div style="font-size:0.95rem;color:#64748b;padding:var(--space-2) 0;">No players ${term ? 'match search' : 'on roster'}.</div>`;
      return;
    }

    list.innerHTML = filtered.map(p => {
      const name   = this.escapeHtml(this._playerLabel(p));
      const jersey = (p.jerseyNumber ?? p.jersey_number ?? '') !== '' ? `#${p.jerseyNumber ?? p.jersey_number}` : '#—';
      const onLeague = !!(p.onOfficialRoster || p.on_official_roster);
      const leagueChip = onLeague
        ? '<span title="On league roster" style="font-size:0.9rem;color:#22d3ee;">⚖️</span>'
        : '<span title="Not on league roster" style="font-size:0.9rem;color:#475569;">○</span>';
      return `
        <div class="th-pool-chip" style="display:flex;align-items:center;gap:8px;padding:8px 10px;border-radius:6px;background:rgba(2,6,23,0.6);border:1px solid rgba(71,85,105,0.4);margin-bottom:6px;font-size:0.95rem;color:#e2e8f0;">
          <span style="font-variant-numeric:tabular-nums;color:#94a3b8;width:36px;">${jersey}</span>
          <span style="flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${name}</span>
          ${leagueChip}
        </div>
      `;
    }).join('');
  }

  _renderSparklinePlaceholder() {
    const el = this.find('#th-sparkline-placeholder');
    if (!el) return;
    const anchor = this._resolveAnchorDate();
    if (anchor) {
      el.textContent = `Sparkline anchor: ${anchor.toDateString()} · walking back 5 sessions (Phase 2)`;
    } else {
      el.textContent = 'Sparkline anchor: today (no future sessions in GM yet) · Phase 2';
    }
  }

  // 6-column lead-up strip.  Layout, left → right:
  //
  //   [prev-5] [prev-4] [prev-3] [prev-2] [prev-1] [ANCHOR GAME]
  //
  // Anchor game = next real match (see _pickAnchor).  Preceding slots
  // are the 5 most recent events BEFORE the anchor's date (practices,
  // pickups, or other games) sorted oldest→newest.  Empty slots render
  // as dashed placeholders so the grid width is stable.
  _renderStrip() {
    const strip = this.find('#th-strip');
    const cap   = this.find('#th-strip-caption');
    if (!strip) return;

    const anchor = this._anchorMatch;
    const all    = this._allEvents || [];

    let preceding = [];
    if (anchor) {
      const anchorTime = new Date(anchor.event_date).getTime();
      preceding = all
        .filter(m => m && m.id !== anchor.id && new Date(m.event_date).getTime() < anchorTime)
        .sort((a, b) => new Date(b.event_date).getTime() - new Date(a.event_date).getTime())
        .slice(0, 5)
        .reverse(); // oldest first (leftmost)
    }

    const anchorLabel = anchor
      ? (anchor.title || 'Next event')
      : 'No upcoming event';
    if (cap) cap.textContent = anchor
      ? `Anchor: ${anchorLabel}`
      : 'No anchor event';

    // Build 6 slots: 5 preceding (pad with null) + 1 anchor
    const slots = [];
    for (let i = 0; i < 5; i++) slots.push(preceding[i] || null);
    slots.push(anchor || null);

    strip.innerHTML = slots.map((ev, idx) => this._renderStripSlot(ev, idx === 5)).join('');
  }

  _renderStripSlot(m, isAnchor) {
    if (!m) {
      return `
        <div style="min-height:130px;padding:10px;border-radius:8px;border:1px dashed rgba(71,85,105,0.35);display:flex;align-items:center;justify-content:center;color:#475569;font-size:0.85rem;">
          —
        </div>
      `;
    }
    const d = new Date(m.event_date);
    const dateStr = isNaN(d) ? '' : d.toLocaleDateString(undefined, {
      weekday: 'short', month: 'short', day: 'numeric',
    });
    const timeStr = isNaN(d) ? '' : d.toLocaleTimeString(undefined, {
      hour: 'numeric', minute: '2-digit',
    });
    const title = String(m.title || '').toLowerCase();
    const mtId  = Number(m.match_type_id ?? m.match_type);
    let icon = '⚽', kind = 'Game';
    if (mtId === 3)      { icon = '🏋️'; kind = 'Practice'; }
    else if (mtId === 7) { icon = '👟'; kind = 'Pickup';   }

    const opponent = m.opponent_team_name || m.opponent || '';
    const venue    = m.venue_name || m.venue_address || '';
    const label    = m.title || (isAnchor ? 'Next event' : kind);

    // Anchor gets a distinct highlight so the "next game" reads at a glance.
    const bg     = isAnchor ? 'rgba(59,130,246,0.14)' : 'rgba(2,6,23,0.5)';
    const border = isAnchor ? '2px solid rgba(59,130,246,0.6)' : '1px solid rgba(71,85,105,0.35)';
    const badge  = isAnchor
      ? `<span style="font-size:0.95rem;font-weight:700;color:#93c5fd;letter-spacing:0.06em;text-transform:uppercase;">Next game</span>`
      : `<span style="font-size:0.95rem;font-weight:600;color:#94a3b8;letter-spacing:0.06em;text-transform:uppercase;">${this.escapeHtml(kind)}</span>`;

    return `
      <div data-event-id="${m.id}"
           style="min-height:170px;padding:14px;border-radius:8px;background:${bg};border:${border};display:flex;flex-direction:column;gap:8px;">
        <div style="display:flex;align-items:center;gap:8px;">
          <span style="font-size:1.75rem;line-height:1;">${icon}</span>
          ${badge}
        </div>
        <div style="font-size:1.3rem;font-weight:700;color:#e2e8f0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;line-height:1.25;"
             title="${this.escapeHtml(label)}${opponent ? ' vs ' + this.escapeHtml(opponent) : ''}">
          ${this.escapeHtml(label)}${opponent ? ` <span style="color:#94a3b8;font-weight:400;">vs ${this.escapeHtml(opponent)}</span>` : ''}
        </div>
        <div style="font-size:1.1rem;color:#cbd5e1;font-weight:500;">
          ${this.escapeHtml(dateStr)}${timeStr ? ` · ${this.escapeHtml(timeStr)}` : ''}
        </div>
        ${venue ? `<div style="font-size:1rem;color:#94a3b8;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="${this.escapeHtml(venue)}">📍 ${this.escapeHtml(venue)}</div>` : ''}
        <div style="flex:1"></div>
        <button type="button" data-attendance-open="${m.id}"
                style="all:unset;cursor:pointer;text-align:center;font-size:1rem;font-weight:600;padding:9px 12px;border-radius:6px;background:rgba(59,130,246,0.15);color:#93c5fd;border:1px solid rgba(59,130,246,0.35);">
          📋 Attendance
        </button>
        <div style="display:flex;gap:8px;">
          <button type="button" data-event-edit="${m.id}"
                  style="flex:1;all:unset;cursor:pointer;text-align:center;font-size:0.95rem;font-weight:500;padding:8px;border-radius:6px;background:rgba(148,163,184,0.12);color:#e2e8f0;border:1px solid rgba(148,163,184,0.35);"
                  title="Edit this event — changes apply globally (all teams share this event)">
            ✏️ Edit
          </button>
          <button type="button" data-event-delete="${m.id}"
                  style="flex:1;all:unset;cursor:pointer;text-align:center;font-size:0.95rem;font-weight:500;padding:8px;border-radius:6px;background:rgba(239,68,68,0.12);color:#fca5a5;border:1px solid rgba(239,68,68,0.35);"
                  title="Delete this event — removes it globally (all teams)">
            🗑️ Delete
          </button>
        </div>
      </div>
    `;
  }

  // Delete a match globally.  Practices/pickups live as a single row in
  // `matches` (with the pool team as home_team_id via the
  // chat_event_create_match trigger), so a single DELETE removes it from
  // every team's calendar that referenced it.  Server cascades to
  // events + RSVPs.  Refreshes the strip on success.
  async _deleteEvent(matchId, btnEl) {
    if (!confirm('Delete this event? This applies globally — it will disappear from every team\'s calendar. Cannot be undone.')) return;
    if (btnEl) { btnEl.disabled = true; btnEl.style.opacity = '0.5'; btnEl.textContent = 'Deleting…'; }
    try {
      const res = await this.auth.fetch(`/api/matches/${matchId}`, { method: 'DELETE' });
      let data = null;
      try { data = await res.json(); } catch (_) { /* body may be empty */ }
      if (!res.ok || (data && data.success === false)) {
        alert(`Delete failed: ${(data && data.message) || `HTTP ${res.status}`}`);
        if (btnEl) { btnEl.disabled = false; btnEl.style.opacity = '1'; btnEl.innerHTML = '🗑️ Delete'; }
        return;
      }
      // Remove locally & re-render immediately for snappy feedback,
      // then refetch to reconcile.
      if (Array.isArray(this._allEvents)) {
        this._allEvents = this._allEvents.filter(e => String(e.id) !== String(matchId));
      }
      this._renderStrip();
      this._loadAll();
    } catch (err) {
      alert(`Delete failed: ${err?.message || 'Network error'}`);
      if (btnEl) { btnEl.disabled = false; btnEl.style.opacity = '1'; btnEl.innerHTML = '🗑️ Delete'; }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  // Anchor resolution rule (final):
  //   anchor = nextMatchDate
  //         ?? furthestFutureScheduledSessionDate   (Phase 2: from GM)
  //         ?? today
  // Phase 1 implements the match path; the GM-furthest path is computed
  // in Phase 2 alongside the new sessions endpoint.
  _resolveAnchorDate() {
    if (this._anchorMatch) {
      const d = new Date(this._anchorMatch.event_date);
      return isNaN(d) ? null : d;
    }
    return null; // Phase 2 fills this in from the sessions endpoint
  }

  _onMatchPicked(matchId) {
    if (!matchId) return;
    const picked = this._teamMatches.find(m => String(m.id) === String(matchId));
    if (!picked) return;
    this._anchorMatch = picked;
    this._renderGameCard();
    this._renderSparklinePlaceholder();
  }

  _teamId() {
    return this.navigation.context.lineupTeamId
        || this.navigation.context.team?.id
        || null;
  }

  _playerLabel(p) {
    const first = p.firstName ?? p.first_name ?? '';
    const last  = p.lastName  ?? p.last_name  ?? '';
    const full  = `${first} ${last}`.trim();
    return full || p.name || p.displayName || 'Unknown';
  }

  _setStateBadge(kind, text) {
    const el = this.find('#th-state-badge');
    if (!el) return;
    el.textContent = text;
    const colors = {
      loading:    { bg: 'rgba(148,163,184,0.2)', fg: '#cbd5e1' },
      live:       { bg: 'rgba(34,197,94,0.18)',  fg: '#86efac' },
      'no-match': { bg: 'rgba(148,163,184,0.18)', fg: '#cbd5e1' },
      error:      { bg: 'rgba(239,68,68,0.2)',   fg: '#fca5a5' },
    };
    const c = colors[kind] || colors.loading;
    el.style.background = c.bg;
    el.style.color = c.fg;
  }
}
