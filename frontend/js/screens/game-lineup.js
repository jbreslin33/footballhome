// GameLineupScreen — single-match lineup editor (coach) / viewer (player).
//
// v1 scope (2026-08-13): tap-to-assign zones only, no pitch/drag — see
// scoping note in the implementation plan. A coach taps a player card's
// Starter/Bench/Alt button to assign them (tap the active one again to
// clear back to unassigned); players see the same grouped lists read-only.
// Reuses the exact debounce/save pattern from lineups.js's _scheduleSave/
// _saveLineup, just scoped to one match/team instead of a multi-team map.
//
// Backend surface:
//   GET /api/eligibility/lineup/:matchId → { success, data: {
//     matchId, teamId, rosterTeamIds, isCoach, rosterStats: [{playerId,
//     practicesAttended, practicesRecentTotal, practicesProjected,
//     practicesUpcomingTotal, gameRsvp, practices: [{date, future,
//     attended}, ...]}], lineup: [{playerId, zone, firstName, lastName,
//     ...}] } } — practices is the team's Tue-Sat practice window before
//     this match (≤5), oldest first. future=false entries use real
//     attendance; future=true entries (days that haven't happened yet)
//     use RSVP/standing projection instead — attended there means
//     "projected to go". rosterStats is coach-only (empty array for
//     players) — see migration 278 (fh_events<->matches bridge) for why
//     this reads fh_events/fh_event_attendance/fh_event_rsvps instead of
//     the old chat_events path. rosterTeamIds is every team fh_event_teams
//     tags this match to (e.g. a "Team: APSL, Liga1" game shares one
//     roster pool across both) — teamId alone is just the primary/home
//     team, kept for the lineup save below. Fetch+merge roster from every
//     id in rosterTeamIds, not just teamId, or dual-rostered players go
//     missing from Unassigned.
//   GET /api/teams/:teamId/roster        → { success, data: [{id, name,
//     roleType, lineupRole}, ...] }
//   PUT /api/eligibility/lineup/:matchId → same shape lineups.js already writes
//   PUT /api/teams/:teamId/roster/:playerId/lineup-role → { lineupRole: 'starter'|'bench'|null }
//     coach/admin-only manual starter/bench-eligible designation (migration 279)
//     — :teamId must be one of the teams that specific player actually
//     rosters on (see roster merge below), not necessarily the match's
//     primary team.
//
// Reached via navigation.goTo('game-lineup', { matchId, title, when }) —
// title/when are optional, already-sanitized display strings (never pass a
// raw gcal event title here — see [[feedback_gcal_title_admin_only]]).
//
// Zone caps: starter max 11 (a full XI), bench max 9. Alternate and the
// starter/bench-eligible flags (lineupRole, separate from zone) are
// unlimited.
const ZONE_CAPS = { starter: 11, bench: 9 };

class GameLineupScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.matchId   = null;
    this.title     = '';
    this.when      = '';
    this.teamId    = null;
    this.matchStartsAt = null; // naive UTC-string date of this match, for the trailing "game" pill
    this.isCoach   = false;
    this.roster    = [];   // [{id:Number, name, lineupRole}] — PLAYER rows only
    this.zones     = new Map(); // playerId:Number -> 'starter'|'bench'|'alternate'
    this.stats     = new Map(); // playerId:Number -> {practicesAttended, practicesRecentTotal, practicesProjected, practicesUpcomingTotal, gameRsvp}
    this.loaded    = false;
    this.error     = null;
    this._saveTimer = null;
    this._wired    = false;
  }

  render() {
    const el = document.createElement('div');
    el.className = 'screen screen-game-lineup';
    el.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>⚽ Lineup</h1>
        <p class="subtitle" id="gl-subtitle">Loading…</p>
      </div>
      <div id="gl-body" style="padding: var(--space-3) var(--space-4) var(--space-6);"></div>
    `;
    this.element = el;
    return el;
  }

  onEnter(params = {}) {
    this.matchId = params.matchId != null ? Number(params.matchId) : null;
    this.title   = params.title || '';
    this.when    = params.when || '';
    this._wire();
    this._bootstrap();
  }

  onExit() {
    if (this._saveTimer) { clearTimeout(this._saveTimer); this._saveTimer = null; }
  }

  _wire() {
    if (this._wired) return;
    this._wired = true;
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const zoneBtn = e.target.closest('[data-lineup-zone-btn]');
      if (zoneBtn && this.isCoach) {
        const playerId = Number(zoneBtn.getAttribute('data-player-id'));
        const zone = zoneBtn.getAttribute('data-lineup-zone-btn');
        this._toggleZone(playerId, zone);
        return;
      }
      const roleBtn = e.target.closest('[data-lineup-role-btn]');
      if (roleBtn && this.isCoach) {
        const playerId = Number(roleBtn.getAttribute('data-player-id'));
        const role = roleBtn.getAttribute('data-lineup-role-btn');
        this._setLineupRole(playerId, role);
      }
    });
  }

  async _bootstrap() {
    const sub = this.find('#gl-subtitle');
    if (!this.matchId) {
      this.error = 'No match specified.';
      if (sub) sub.textContent = this.error;
      this._render();
      return;
    }
    if (sub) sub.textContent = [this.title, this.when].filter(Boolean).join(' · ') || 'Loading…';

    try {
      const lineupRes = await this.auth.fetch(`/api/eligibility/lineup/${this.matchId}`);
      const lineupData = await lineupRes.json();
      if (!lineupData.success) throw new Error(lineupData.message || 'Failed to load lineup');

      this.teamId  = lineupData.data.teamId || null;
      this.matchStartsAt = lineupData.data.matchStartsAt || null;
      this.isCoach = !!lineupData.data.isCoach;
      this.zones = new Map();
      for (const row of (lineupData.data.lineup || [])) {
        if (row.zone && row.zone !== 'not_selected') {
          this.zones.set(Number(row.playerId), row.zone);
        }
      }
      this.stats = new Map();
      for (const row of (lineupData.data.rosterStats || [])) {
        this.stats.set(Number(row.playerId), row);
      }

      // A game tagged "Team: APSL, Liga1" shares one roster pool across
      // both — fetch every team in rosterTeamIds and merge, not just the
      // primary teamId, or the second team's players go missing from
      // Unassigned. Each player keeps the id of the FIRST team its roster
      // row came from, since that's what the lineup-role PUT targets.
      const rosterTeamIds = Array.isArray(lineupData.data.rosterTeamIds) && lineupData.data.rosterTeamIds.length
        ? lineupData.data.rosterTeamIds
        : (this.teamId ? [this.teamId] : []);

      const rosterResults = await Promise.all(
        rosterTeamIds.map(id => this.auth.fetch(`/api/teams/${id}/roster`).then(r => r.json()).then(d => ({ id, d })))
      );
      const byId = new Map();
      for (const { id: fromTeamId, d: rosterData } of rosterResults) {
        const arr = Array.isArray(rosterData?.data) ? rosterData.data : [];
        for (const p of arr) {
          if (p.roleType !== 'PLAYER') continue;
          const pid = Number(p.id);
          if (byId.has(pid)) continue; // already merged from an earlier team
          byId.set(pid, { id: pid, name: p.name || '(unnamed)', lineupRole: p.lineupRole || null, teamId: fromTeamId });
        }
      }
      this.roster = [...byId.values()];

      this.loaded = true;
      this._render();
    } catch (err) {
      console.error('[game-lineup] load failed:', err);
      this.error = err.message || 'Failed to load lineup.';
      this._render();
    }
  }

  _toggleZone(playerId, zone) {
    const current = this.zones.get(playerId);
    if (current === zone) {
      this.zones.delete(playerId); // tap active zone again → unassign
    } else {
      const cap = ZONE_CAPS[zone];
      if (cap != null) {
        const countInZone = [...this.zones.values()].filter(z => z === zone).length;
        if (countInZone >= cap) {
          this._toast(`${zone === 'starter' ? 'Starting XI' : 'Bench'} is full (${cap} max)`);
          return;
        }
      }
      this.zones.set(playerId, zone);
    }
    this._render();
    this._scheduleSave();
  }

  _toast(msg) {
    // Cheap, no-dep toast. Clears itself after 2.5s.
    let t = this.find('#game-lineup-toast');
    if (!t) {
      t = document.createElement('div');
      t.id = 'game-lineup-toast';
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

  _scheduleSave() {
    if (this._saveTimer) clearTimeout(this._saveTimer);
    this._saveTimer = setTimeout(() => {
      this._saveTimer = null;
      this._saveLineup();
    }, 600);
  }

  async _saveLineup() {
    const starters = [];
    const bench = [];
    const alternates = [];
    for (const [playerId, zone] of this.zones.entries()) {
      if (zone === 'starter') starters.push({ playerId });
      else if (zone === 'bench') bench.push({ playerId });
      else if (zone === 'alternate') alternates.push({ playerId });
    }
    try {
      const res = await this.auth.fetch(`/api/eligibility/lineup/${this.matchId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ starters, bench, alternates, formationId: 0, rosterSize: 0 }),
      });
      const data = await res.json();
      if (!data.success) throw new Error(data.message || 'Save failed');
    } catch (err) {
      console.error('[game-lineup] save failed:', err);
    }
  }

  // Coach-set "starter eligible" / "bench eligible" designation — a plain
  // manual flag on team_persons (migration 279), separate from this
  // match's zone assignment. Tapping the active role again clears it.
  async _setLineupRole(playerId, role) {
    const player = this.roster.find(p => p.id === playerId);
    if (!player || !player.teamId) return;
    const nextRole = player.lineupRole === role ? null : role;
    const prevRole = player.lineupRole;
    player.lineupRole = nextRole;
    this._render();
    try {
      const res = await this.auth.fetch(`/api/teams/${player.teamId}/roster/${playerId}/lineup-role`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ lineupRole: nextRole }),
      });
      const data = await res.json();
      if (!data.success) throw new Error(data.message || 'Save failed');
    } catch (err) {
      console.error('[game-lineup] lineup-role save failed:', err);
      player.lineupRole = prevRole;
      this._render();
    }
  }

  _render() {
    const box = this.find('#gl-body');
    if (!box) return;

    if (this.error) {
      box.innerHTML = `<div class="empty-state" style="padding: var(--space-4); text-align:center; opacity:0.8;">${this.escapeHtml(this.error)}</div>`;
      return;
    }
    if (!this.loaded) {
      box.innerHTML = `<div class="loading-state"><div class="spinner"></div><p>Loading…</p></div>`;
      return;
    }

    // Unassigned default sort: Going first (not going / no response after —
    // maybe counts as no response, same "yes or it didn't happen" read as
    // the practice pills), then Starter Eligible within each RSVP tier.
    const rsvpRank = (playerId) => {
      const rsvp = this.stats.get(playerId)?.gameRsvp;
      if (rsvp === 'yes') return 0;
      if (rsvp === 'no') return 1;
      return 2;
    };
    const starterEligibleRank = (p) => p.lineupRole === 'starter' ? 0 : 1;

    const byZone = { starter: [], bench: [], alternate: [] };
    const unassigned = [];
    for (const p of this.roster) {
      const z = this.zones.get(p.id);
      if (z && byZone[z]) byZone[z].push(p);
      else unassigned.push(p);
    }
    unassigned.sort((a, b) =>
      (rsvpRank(a.id) - rsvpRank(b.id)) || (starterEligibleRank(a) - starterEligibleRank(b))
    );

    if (!this.isCoach && byZone.starter.length === 0) {
      box.innerHTML = `
        <div class="public-card" style="text-align:center; opacity:0.85; padding: var(--space-4);">
          🔒 Lineup not yet published
        </div>`;
      return;
    }

    const zoneButtons = (playerId) => `
      <div style="display:flex; gap:4px;">
        ${['starter', 'bench', 'alternate'].map(z => {
          const active = this.zones.get(playerId) === z;
          const label = z === 'starter' ? 'Start' : z === 'bench' ? 'Bench' : 'Alt';
          return `<button type="button" data-lineup-zone-btn="${z}" data-player-id="${playerId}"
            class="btn btn-sm ${active ? 'btn-primary' : 'btn-secondary'}"
            style="padding:2px 8px; font-size:0.75rem;">${label}</button>`;
        }).join('')}
      </div>`;

    const roleButtons = (p) => `
      <div style="display:flex; gap:4px;">
        ${['starter', 'bench'].map(r => {
          const active = p.lineupRole === r;
          const label = r === 'starter' ? 'Elig: Start' : 'Elig: Bench';
          return `<button type="button" data-lineup-role-btn="${r}" data-player-id="${p.id}"
            class="btn btn-sm ${active ? 'btn-primary' : 'btn-secondary'}"
            style="padding:1px 6px; font-size:0.68rem; opacity:${active ? '1' : '0.7'};">${label}</button>`;
        }).join('')}
      </div>`;

    const rsvpBadge = (rsvp) => {
      if (rsvp === 'yes') return '<span title="RSVP: Going" style="color:#22c55e;">✓</span>';
      if (rsvp === 'no') return '<span title="RSVP: Not going" style="color:#ef4444;">✗</span>';
      if (rsvp === 'maybe') return '<span title="RSVP: Maybe" style="opacity:0.7;">?</span>';
      return '<span title="No RSVP yet" style="opacity:0.4;">–</span>';
    };

    const DOW = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const pill = (label, ok, tooltip, dim) => `<span title="${tooltip}"
      style="background:${ok ? '#22c55e' : '#ef4444'}; color:#fff; border-radius:10px; padding:1px 6px;
        font-size:0.62rem; white-space:nowrap; ${dim ? 'opacity:0.75;' : ''}">${label}</span>`;

    const practicePills = (s) => {
      const practices = s?.practices;
      if (!practices || !practices.length) return '';
      const spans = practices.map(p => {
        const d = new Date(p.date);
        const label = `${DOW[d.getDay()]} ${d.getMonth() + 1}/${d.getDate()}`;
        const statusText = p.future
          ? (p.attended ? 'Projected: Going' : 'Projected: Not going / no response')
          : (p.attended ? 'Present' : 'Absent');
        return pill(label, p.attended, `${label}: ${statusText}`, p.future);
      });
      if (this.matchStartsAt) {
        const gd = new Date(this.matchStartsAt);
        const gameLabel = `Game ${gd.getMonth() + 1}/${gd.getDate()}`;
        const going = s.gameRsvp === 'yes';
        spans.push(pill(gameLabel, going, `${gameLabel}: ${going ? 'Going' : 'Not going / no response'}`, true));
      }
      return `<div style="display:flex; gap:3px; margin-top:2px;">${spans.join('')}</div>`;
    };

    const statsLine = (playerId) => {
      const s = this.stats.get(playerId);
      if (!s) return '';
      return `<div style="font-size:0.68rem; opacity:0.65; margin-top:2px;">
        Practices ${s.practicesAttended}/${s.practicesRecentTotal}
        ${s.practicesUpcomingTotal > 0 ? `· proj ${s.practicesProjected}/${s.practicesUpcomingTotal}` : ''}
        · Game ${rsvpBadge(s.gameRsvp)}
        ${practicePills(s)}
      </div>`;
    };

    const playerRow = (p) => `
      <div style="padding:6px var(--space-3); border-bottom:1px solid var(--border-color);">
        <div style="display:flex; align-items:center; justify-content:space-between; gap:8px;">
          <span style="font-size:0.9em;">${this.escapeHtml(p.name)}</span>
          ${this.isCoach ? zoneButtons(p.id) : ''}
        </div>
        ${this.isCoach ? `
          <div style="display:flex; align-items:center; justify-content:space-between; gap:8px; margin-top:3px;">
            ${statsLine(p.id)}
            ${roleButtons(p)}
          </div>
        ` : ''}
      </div>`;

    const section = (label, players) => `
      <h2 style="margin: var(--space-3) 0 4px; font-size:0.85rem;">${label} (${players.length})</h2>
      ${players.length
        ? players.map(playerRow).join('')
        : `<div style="padding:6px var(--space-3); opacity:0.6; font-size:0.85em;">None yet</div>`}
    `;

    box.innerHTML = [
      section('Starting', byZone.starter),
      section('Bench', byZone.bench),
      section('Alternates', byZone.alternate),
      this.isCoach ? section('Unassigned', unassigned) : '',
    ].join('');
  }
}
