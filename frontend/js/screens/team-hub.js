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
      <div class="screen-header" style="display:flex;align-items:center;gap:var(--space-3);padding:var(--space-3);">
        <button class="btn btn-secondary btn-sm" data-action="back">← Back</button>
        <h1 id="th-team-title" style="margin:0;font-size:1.15rem;">Team Hub</h1>
        <span style="flex:1"></span>
        <span id="th-state-badge" class="th-state-badge" style="font-size:0.72rem;padding:2px 8px;border-radius:9999px;background:rgba(148,163,184,0.2);color:#cbd5e1;">…</span>
      </div>

      <!-- Game card — real match in state A/B, 👻 ghost in state C -->
      <div id="th-gamecard" style="margin:0 var(--space-3) var(--space-3);padding:var(--space-3);border-radius:10px;background:linear-gradient(180deg,rgba(15,23,42,0.85),rgba(15,23,42,0.55));border:1px solid rgba(148,163,184,0.25);min-height:64px;display:flex;align-items:center;gap:var(--space-3);">
        <div id="th-gamecard-icon" style="font-size:1.6rem;">⚽</div>
        <div style="flex:1;min-width:0;">
          <div id="th-gamecard-title" style="font-weight:600;color:#e2e8f0;font-size:1rem;">Loading…</div>
          <div id="th-gamecard-sub"   style="font-size:0.78rem;color:#94a3b8;margin-top:2px;">—</div>
        </div>
        <select id="th-match-picker" style="display:none;font-size:0.8rem;padding:4px 8px;border-radius:6px;background:#0f172a;color:#e2e8f0;border:1px solid rgba(148,163,184,0.3);"></select>
      </div>

      <!-- Body: two-column layout. Pool sidebar (left) + Stage (right). -->
      <div id="th-body" style="display:grid;grid-template-columns:260px 1fr;gap:var(--space-3);padding:0 var(--space-3) var(--space-3);align-items:start;">
        <aside id="th-pool" style="position:sticky;top:var(--space-3);max-height:calc(100vh - 200px);overflow:auto;padding:var(--space-3);border-radius:10px;background:rgba(15,23,42,0.55);border:1px solid rgba(148,163,184,0.2);">
          <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:var(--space-2);">
            <h3 style="margin:0;font-size:0.85rem;color:#cbd5e1;letter-spacing:0.04em;text-transform:uppercase;">👥 Pool</h3>
            <span id="th-pool-count" style="font-size:0.72rem;color:#94a3b8;">0</span>
          </div>
          <input id="th-pool-search" type="search" placeholder="Search players…" style="width:100%;font-size:0.82rem;padding:6px 8px;border-radius:6px;background:#0f172a;color:#e2e8f0;border:1px solid rgba(148,163,184,0.3);margin-bottom:var(--space-2);">
          <div id="th-pool-list"></div>
        </aside>
        <main id="th-stage" style="min-width:0;min-height:60vh;padding:var(--space-4);border-radius:10px;background:rgba(15,23,42,0.45);border:1px dashed rgba(148,163,184,0.25);color:#94a3b8;text-align:center;">
          <div style="font-size:0.85rem;">⚽ Pitch + Bench + Alternates land here in Phase 2</div>
          <div id="th-sparkline-placeholder" style="margin-top:var(--space-3);font-size:0.78rem;color:#64748b;"></div>
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

    const [matches, roster] = await Promise.all([
      this._fetchMatches(teamId),
      this._fetchRoster(teamId),
    ]);
    if (token !== this._loadToken) return; // superseded

    this._teamMatches = matches;
    this._roster      = roster;
    this._anchorMatch = this._pickNextMatch(matches);

    this._renderGameCard();
    this._renderMatchPicker();
    this._renderPool();
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
      list.innerHTML = `<div style="font-size:0.78rem;color:#64748b;padding:var(--space-2) 0;">No players ${term ? 'match search' : 'on roster'}.</div>`;
      return;
    }

    list.innerHTML = filtered.map(p => {
      const name   = this.escapeHtml(this._playerLabel(p));
      const jersey = (p.jerseyNumber ?? p.jersey_number ?? '') !== '' ? `#${p.jerseyNumber ?? p.jersey_number}` : '#—';
      const onLeague = !!(p.onOfficialRoster || p.on_official_roster);
      const leagueChip = onLeague
        ? '<span title="On league roster" style="font-size:0.72rem;color:#22d3ee;">⚖️</span>'
        : '<span title="Not on league roster" style="font-size:0.72rem;color:#475569;">○</span>';
      return `
        <div class="th-pool-chip" style="display:flex;align-items:center;gap:6px;padding:6px 8px;border-radius:6px;background:rgba(2,6,23,0.6);border:1px solid rgba(71,85,105,0.4);margin-bottom:4px;font-size:0.82rem;color:#e2e8f0;">
          <span style="font-variant-numeric:tabular-nums;color:#94a3b8;width:30px;">${jersey}</span>
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
