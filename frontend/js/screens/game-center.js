// GameCenterScreen — the one page for a single game (#game-center).
//
// Game Center (2026-08-28, owner: "what i really need for games is a
// fully functional way for game announcements, 20 man announcement,
// starters/bench announcement, result... are they related enough to be
// all one page with pills?"). They are: they're four views of the SAME
// match record at four points in time, so this screen is a pill strip
// over one data load — set the lineup and publish the post without
// leaving the page. Named by the owner; a practice center and a pickup
// center may follow the same shape later.
//
// This screen absorbed the old two-screen ping-pong: it used to render
// a "📸 Post to Instagram" button that navigated to #game-day-roster,
// which rendered an "✏️ Edit Lineup" button that navigated straight
// back here — both screens separately fetching
// /api/eligibility/lineup/:matchId and /api/matches/:matchId to do it.
// Now the post pills and the lineup editor share one load and one
// in-memory lineup (see _mountSocial), and #game-day-roster is gone:
// its RSVP/jersey/practice overlay lives under the 20-Man Squad pill
// here (see _openDetails). Score entry landed here too (slice C,
// 2026-09-07): the Match Result pill records the scoreline, and the Game
// Announcement pill owns opponent/date/venue — editable only for a match
// that is NOT bridged to a Google Calendar event, because for a bridged
// game the calendar owns those fields and the My page reads the gcal
// side (see _renderGameDetailsPanel). #match-form keeps only create mode
// and the non-match fields (title, competition, status, notes).
//
// Routes: #game-center is canonical; #game-lineup and #game-day-roster
// stay registered as backward-compat aliases (app.js) for existing
// links and bookmarks.
//
// v1 scope (2026-08-13): tap-to-assign zones only, no pitch/drag — see
// scoping note in the implementation plan. Reuses the exact debounce/
// save pattern from lineups.js's _scheduleSave/_saveLineup, just scoped
// to one match/team instead of a multi-team map.
//
// Coach editing (2026-08-22, owner directive — "I would always put them
// in positions and bench and that would feed the views"):
//   • Starting XI: 1-11 position pills per player (_setPosition), one
//     pill per `positions` row (id/sortOrder 1=GK, 2=RB, ... 11=RM —
//     see GET /api/eligibility/positions). Picking a pill IS how a
//     player becomes a starter — there's no separate "Start" button.
//     A slot already held by someone else renders greyed out but is
//     still clickable: clicking it REPLACES them (they're bumped back
//     to unassigned/their RSVP group) rather than blocking the click.
//     Clicking your own active pill removes you instead.
//   • Bench/Alt: plain toggle buttons (_toggleZone), unchanged.
//   • Bench order: a #1/#2/... dropdown per bench player
//     (_setBenchOrder), move-to-slot-N same as mens-roster.js's
//     roster-position-select. Coach reference only.
//
// Player view: players get a plain read-only "team sheet"
// (_renderPlayerView) — Starting XI ordered 1-11 by position slot
// (with the position abbreviation shown), Bench/Alternates ALWAYS
// alphabetical by last name regardless of the coach's bench order
// ("so no one gets mad" — owner directive). No stats/RSVP/coach
// controls. A coach reaches the identical view via the "👀 Player
// Lineup View" toggle on this same screen (this.viewMode) rather than a
// separate route, so there's only ever one "Lineup" entry point.
//
// Backend surface:
//   GET /api/eligibility/positions → { success, data: [{id, name,
//     abbreviation, sortOrder}, ...] } — the 1-11 pill reference list
//     (positions.sort_order 12-15 exist in the table but aren't offered
//     here; only the first 11 fill a Starting XI).
//   GET /api/eligibility/lineup/:matchId → { success, data: {
//     matchId, teamId, rosterTeamIds, isCoach, rosterStats: [{playerId,
//     practicesAttended, practicesRecentTotal, practicesProjected,
//     practicesUpcomingTotal, gameRsvp, practices: [{date, future,
//     attended}, ...]}], lineup: [{playerId, zone, positionId,
//     slotNumber, firstName, lastName, ...}] } } — positionId is the
//     Starting XI slot (only meaningful when zone==='starter');
//     slotNumber mirrors it there and separately carries the bench
//     order when zone==='bench'. practices is the team's Tue-Sat
//     practice window before
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
//   PUT /api/eligibility/lineup/:matchId → body { starters: [{playerId,
//     positionId?, slotNumber?}], bench: [{playerId, slotNumber?}],
//     alternates: [{playerId}], formationId, rosterSize } — same
//     endpoint lineups.js already writes to, extended 2026-08-22 with
//     positionId (Starting XI slot) and slotNumber (bench order)
//
// lineupRole ('starter'|'bench'|'reserve'|null, migration 279/283/293) is a
// coach-set Roster Role designation shown here read-only (see roleButtons
// below). It's edited from the Teams roster board (mens-roster.js), not
// from this per-match screen — moved there 2026-08-22 per owner directive.
//
// Reached via navigation.goTo('game-center', { matchId, title, when,
// postType }) — title/when are optional, already-sanitized display
// strings (never pass a raw gcal event title here — see
// [[feedback_gcal_title_admin_only]]). postType deep-links straight to
// one pill; params.mode==='gameday' is the older "Game Day Roster"
// entry point, which is the 20-Man Squad pill under its new name.
// matchId also falls back to navigation.context.match.id, which is how
// #game-day-roster's own callers have always passed it.
//
// Zone caps: bench max 9. Starters are capped by the position pills
// themselves — there are exactly `fieldSize` of them (see FIELD_SIZES),
// so a starter slot is freed in the same stroke as it's filled.
// Alternate and the starter/bench-eligible flags (lineupRole, separate
// from zone) are unlimited.
const ZONE_CAPS = { bench: 9 };

// Game formats, keyed by teams.field_size (players per side, migration
// 322 — U8/U10 7v7, U12 9v9, adults 11v11). Each carries its formation
// pitch templates and the default one (2026-09-11, owner: "u8 and u10
// are 7v7 starters and u12 is 9v9... For 7v7 set to a 222 formation and
// for 9v9 set to a 332 formation").
//
// Formation templates (2026-08-22, owner directive) — GK row first
// (bottom of the pitch; _renderFormationPitch reverses the array so
// attack ends up on top). Purely a visual layout — it doesn't change
// what role position id N actually is (see migration 296's 4-4-2
// shirt-number scheme), just how the dots are arranged and, for `rows`,
// their exact left-to-right order within each row.
//
// `rows`: explicit position-id order per row (owner directive: "front
// row: 10,9. midfield: 11,8,6,7. backline: 3,5,4,2. keeper at bottom").
// `counts`: no owner-specified order for these yet, so slots just fill
// left-to-right in id order, `count` at a time.
//
// The small-sided shapes are the 11v11 spine with players removed, so
// a chip keeps the same number/role whatever the format: 9v9 3-3-2
// drops the second CB (5) and second CDM (8); 7v7 2-2-2 drops the four
// wide players (2, 3, 7, 11). The format's starting slots are exactly
// the ids in its default formation — that's what the position pills
// offer and what the pitch draws.
const FIELD_SIZES = {
  11: {
    defaultFormation: '4-4-2',
    formations: {
      '4-4-2':   { rows: [[1], [3, 5, 4, 2], [11, 8, 6, 7], [10, 9]] },
      '4-3-3':   { counts: [1, 4, 3, 3] },
      '3-5-2':   { counts: [1, 3, 5, 2] },
      '4-2-3-1': { counts: [1, 4, 2, 3, 1] },
    },
  },
  9: {
    defaultFormation: '3-3-2',
    formations: {
      '3-3-2': { rows: [[1], [3, 4, 2], [11, 6, 7], [10, 9]] },
    },
  },
  7: {
    defaultFormation: '2-2-2',
    formations: {
      '2-2-2': { rows: [[1], [5, 4], [8, 6], [10, 9]] },
    },
  },
};
for (const spec of Object.values(FIELD_SIZES)) {
  spec.slotIds = new Set(spec.formations[spec.defaultFormation].rows.flat());
}
const DEFAULT_FIELD_SIZE = 11;

// Sentinel row spliced into the formation's rows to mark where the
// halfway line (and the league crest in its center circle) belongs —
// see _renderFormationPitch. Identity comparison only; never rendered
// as positions.
const HALFWAY_ROW = Object.freeze([]);


// The four moments of a game, in the order they happen — the pill strip
// across the top of Game Center. `key` is the social_post_types.name the
// post publishes under, so the pill a coach is looking at IS the post
// they publish; there's no separate "which post type did I mean" step.
//
// `social` is whether the Instagram section under that pill starts open.
// The two pills that already render a live graphic of their own (the
// squad chips, the formation pitch) start CLOSED so there's only one
// image on screen at a time — owner, 2026-08-22: "one image should
// change at top depending on pill selection... don't need multiple
// images on that screen its confusing". The two that have no live
// graphic start open, since otherwise the pill looks empty.
//
// NOTE: 'starters_bench' is social_post_types row 1 (seeded in 010 as
// pre_match_announcement, renamed in migration 343). Keep the wire
// value in this table only, never inline it.
// Wording comes from social_post_types.display_name via
// GET /api/social/post-types (slice E, 2026-09-07); `title` here is only
// the fallback when that fetch fails. Icon, accent and the Instagram
// section's default open/closed state are presentation and stay here.
const POST_PILLS = [
  { key: 'game_day',       icon: '⚽', title: 'Game Announcement', accent: '#f59e0b', social: 'open'   },
  { key: 'lineup',         icon: '📋', title: '20-Man Squad',      accent: '#8b5cf6', social: 'closed' },
  { key: 'starters_bench', icon: '⚔️', title: 'Starters & Bench',  accent: '#3b82f6', social: 'closed' },
  { key: 'post_game',      icon: '🏆', title: 'Match Result',      accent: '#22c55e', social: 'open'   },
];

// Starters & Bench is the landing pill: it's the one a coach actually
// works in, and it's the team sheet a player opens the page to read.
const DEFAULT_PILL = 'starters_bench';

class GameCenterScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.matchId   = null;
    this.title     = '';
    this.when      = '';
    this.teamId    = null;
    // Players per side for this match's team (teams.field_size via the
    // lineup endpoint) — picks the FIELD_SIZES entry: how many starting
    // slots there are and which formations are on offer. Unknown/odd
    // sizes fall back to a full XI.
    this.fieldSize = DEFAULT_FIELD_SIZE;
    this.matchStartsAt = null; // naive UTC-string date of this match, for the trailing "game" pill
    this.isCoach   = false;
    // Coach-only toggle (2026-08-22, owner directive: "only need 1 Lineup
    // button on screen") between the editable coach view and a read-only
    // preview of exactly what players see. Players always get the player
    // view regardless of this flag — see the effectiveIsPlayerView check
    // in _render().
    this.viewMode  = 'coach'; // 'coach' | 'player'
    this.roster    = [];   // [{id:Number, name, lineupRole, jerseyNumber}] — PLAYER rows only
    this.zones     = new Map(); // playerId:Number -> 'starter'|'bench'|'alternate'
    // Starting XI position (2026-08-22, owner directive: "I would always
    // put them in positions and bench and that would feed the views" —
    // picking a position IS how a player becomes a starter here; there's
    // no separate "Start" button. playerId:Number -> positionId:Number.
    // Bench/Alt stay plain zone toggles (no position).
    this.positions     = new Map();
    this.positionList  = []; // [{id, name, abbreviation, sortOrder}, ...] from GET /api/eligibility/positions
    // Bench substitution order (2026-08-22, owner directive: "allow me to
    // edit bench order like in the teams page with dropdown") — a slot
    // picker (#1, #2, ...) exactly like mens-roster.js's coach_sort_order
    // control, reusing match_lineups.slot_number for zone='bench' rows
    // the same column starters use for their position slot, just a
    // different meaning per zone. Coach reference only — the Player
    // Lineup View's Bench section always shows alphabetical regardless
    // (see _renderPlayerView), so this never becomes a fairness dispute.
    this.benchOrder    = new Map(); // playerId:Number -> order:Number (1-based)
    // Availability/RSVP pills in the Current Lineup card are opt-in
    // (2026-08-22, owner directive: "toggle off 'stats' like
    // availability and attendance... at top for current lineup and
    // bench") — off by default to keep the summary compact.
    this.showLineupStats = false;
    // Formation pitch graphic (2026-08-22, owner directive: "show lineup
    // in graphic form as diff formations. default to 442" — "1442
    // counting keeper lol"). This is a pure VISUAL row-count template —
    // it does NOT reassign anyone's actual position/slot (those stay the
    // fixed named roles the pills use). It just chunks the format's
    // starting slots (in sortOrder) into rows sized by the template
    // counts (GK row first) so the graphic reads as a real formation
    // shape on a pitch, purely for the TV-style visual. Reset to the
    // format's default once fieldSize is known (_bootstrap).
    this.formation = FIELD_SIZES[DEFAULT_FIELD_SIZE].defaultFormation;
    // Which of the four game moments is on screen (POST_PILLS above).
    // Supersedes the old two-way subView toggle ('lineup' | 'gameday'),
    // which was itself already collapsing two screens into one — those
    // two views are now the 'starters_bench' and 'lineup' pills.
    // Visible to everyone (coach and player), independent of the
    // coach-only viewMode toggle above.
    this.pill = DEFAULT_PILL;
    // SocialPostCard for the active pill, mounted lazily — it costs four
    // API calls, so it's only built once its section is actually open.
    // Dropped on every re-render so a stale card never sits on a
    // detached node (this screen re-renders on every zone change).
    this.socialCard = null;
    // { post type name → display_name } from /api/social/post-types.
    this.postTypeNames = {};
    // The post (or 'none') the Instagram section is
    // currently showing — see _renderSocial for why it matters.
    this._socialMountedFor = null;
    // Whether the publish panel (_renderSocial) is open under the card.
    this._bottomOpen = false;
    // { post type name → {status, scheduled_at} } for this match's posts,
    // behind the ✅/📅 marks on the Instagram pills (_loadPostStates).
    this.postStates = {};
    // Enriched per-player admin data behind the 20-Man Squad pill's
    // "RSVP & Player Details" overlay — jersey numbers, match RSVP,
    // practice attendance, roster memberships. Coach-only, and a
    // separate fetch from the roster this.roster holds, because it
    // comes from a different endpoint with a different shape
    // (GET /api/matches/:matchId/roster-players — see _bootstrap).
    this.players = [];        // [{playerId, personId, firstName, lastName, isKeeper, jerseyNumber, rsvpStatus, rsvpSource, practice: [...], onRoster*}]
    this.trainingEvents = []; // [{id, date, title}] — the practice columns
    this.reminders = {};      // person_id → {sms, email: {sent_at, count}} already sent about this game
    this.squadNotice = null;  // {squad, untold, sms: {sent_at}, email: {sent_at}} — the squad game reminder
    this.overlayOpen = false;
    this.filterText = '';
    this.filterRsvp = 'all';
    this.listFilter = 'all';
    this._jerseyDebounce = null;
    this.stats     = new Map(); // playerId:Number -> {practicesAttended, practicesRecentTotal, practicesProjected, practicesUpcomingTotal, gameRsvp}
    this.loaded    = false;
    this.error     = null;
    this._saveTimer = null;
    this._wired    = false;
    this.matchDetails = null; // {home_team_name, home_team_logo, away_team_name, away_team_logo, ...} — feeds the card, see _renderCard
    // Slice C panels under the Game Announcement / Match Result frames.
    this.announceEditing = false; // Game Announcement: read-only list vs edit form (unlinked matches only)
    this.venueList = null;        // [{id, name, city}] from GET /api/venues, fetched once when the edit form opens
    this.teamList  = null;        // [{id, name}] from GET /api/teams, same
    this._scoreMsg   = '';        // one-line status under the score inputs
    this._detailsMsg = '';        // one-line status under the game-details form
    this._matchSaving = false;
    this._lighthouseStartTime = null; // persisted so the beam angle never jumps across re-renders
    // The live cards — see _cardSlot.
    this._cardSlots = {};
  }

  // The graphic at the top of every pill IS the Instagram post (owner,
  // 2026-09-19: "the graphic we see at top should be same one we see for
  // insta. they are clearly diff... lets be consistent"). It used to be a
  // second, hand-built drawing of the same information — header, pitch,
  // squad chips, score — which is exactly how the two drifted. Now
  // SocialPostCard.buildCardHtml() is the only drawing: html2canvas
  // captures it for the post, and this shows the same markup live, scaled
  // to the column, under the same LighthouseBeam the posted clip carries.
  //
  // The build is async (accolades), so the last markup is kept and
  // painted synchronously — _render() rewrites #gl-body on every lineup
  // tap and the card must not blink out each time. _mountCard then
  // rebuilds and swaps the markup only if it actually changed.
  _renderCard(slot, pill) {
    const st = this._cardSlot(slot);
    const built = st.built && st.built.key === this._cardKey(pill) ? st.built : null;
    const h = built ? built.height : 700;
    return `
      <div data-gc-card="${slot}" style="position:relative; width:100%; max-width:540px; margin:0 auto 12px; aspect-ratio:540 / ${h}; overflow:hidden; box-shadow:0 10px 34px rgba(0,0,0,0.35);">
        <div data-gc-card-inner style="position:absolute; left:0; top:0; width:540px; transform-origin:0 0;">${built ? built.html : ''}</div>
        <canvas data-gc-card-beam style="position:absolute; left:0; top:0; width:100%; height:100%; pointer-events:none;"></canvas>
      </div>`;
  }

  // State behind a live card host — builder, last markup, build
  // sequence, beam and resize observer. Only 'top' exists today; keyed
  // so a second host never needs new plumbing.
  _cardSlot(slot) {
    this._cardSlots = this._cardSlots || {};
    return this._cardSlots[slot] || (this._cardSlots[slot] = { card: null, built: null, seq: 0, stopBeam: null, resizeObs: null });
  }

  _cardKey(pill) {
    return `${this.matchId}:${pill}`;
  }

  _stopCards() {
    for (const st of Object.values(this._cardSlots || {})) {
      if (st.stopBeam) { st.stopBeam(); st.stopBeam = null; }
      if (st.resizeObs) { st.resizeObs.disconnect(); st.resizeObs = null; }
    }
  }

  // Scale the fixed 540px card to its column and (re)start the beam on
  // the fresh canvas. Runs after every paint and on resize.
  _fitCard(slot) {
    const st = this._cardSlot(slot);
    if (st.resizeObs) { st.resizeObs.disconnect(); st.resizeObs = null; }
    if (st.stopBeam) { st.stopBeam(); st.stopBeam = null; }
    const host = this.element && this.element.querySelector(`[data-gc-card="${slot}"]`);
    if (!host) return;
    const inner = host.querySelector('[data-gc-card-inner]');
    const fit = () => { if (inner && host.clientWidth) inner.style.transform = `scale(${host.clientWidth / 540})`; };
    fit();
    if (typeof ResizeObserver !== 'undefined') {
      st.resizeObs = new ResizeObserver(fit);
      st.resizeObs.observe(host);
    }

    const beam = host.querySelector('[data-gc-card-beam]');
    if (!beam || !st.built || typeof window.LighthouseBeam === 'undefined') return;
    // Same canvas geometry and rotation period as SocialPostCard's
    // startAnimatedPreview, so the beam sits where the posted clip has it.
    beam.width = 540 * 2;
    beam.height = st.built.height * 2;
    if (!this._lighthouseStartTime) this._lighthouseStartTime = performance.now();
    st.stopBeam = window.LighthouseBeam.animate(beam, {
      startTime: this._lighthouseStartTime,
      rotPeriodSec: window.LighthouseBeam.BEAM_ROTATION_SECONDS,
      ...(st.card && st.card.beamOptions ? st.card.beamOptions(beam.width, beam.height) : {}),
    }).stop;
  }

  async _mountCard(slot, pill, byZone) {
    this._fitCard(slot);
    if (typeof SocialPostCard === 'undefined' || !this.matchDetails) return;
    const st = this._cardSlot(slot);
    const card = st.card || (st.card = new SocialPostCard(this.auth));
    const key = this._cardKey(pill);
    card.matchId = this.matchId;
    card.teamId = this.teamId;
    card.postTypeName = pill;
    card.matchContext = this.matchDetails;
    card.rosterData = this._buildRosterData(byZone, { live: slot === 'top' });
    const seq = ++st.seq;
    try {
      // Goalscorers on the result card; players may not be allowed the
      // read, in which case the card simply goes without them.
      if (pill === 'post_game' && card._statsFor !== this.matchId) {
        card._statsFor = this.matchId;
        card.matchStats = [];
        const res = await this.auth.fetch(`/api/social/match/${this.matchId}/stats`).catch(() => null);
        const data = res ? await res.json().catch(() => null) : null;
        if (data && data.success) card.matchStats = data.data || [];
      }
      const built = await card.buildCardHtml({ live: true });
      if (seq !== st.seq) return;
      const changed = !st.built || st.built.key !== key
        || st.built.html !== built.html || st.built.height !== built.height;
      st.built = { key, html: built.html, height: built.height };
      if (!changed) return;
      const host = this.element && this.element.querySelector(`[data-gc-card="${slot}"]`);
      if (!host) return;
      host.style.aspectRatio = `540 / ${built.height}`;
      host.querySelector('[data-gc-card-inner]').innerHTML = built.html;
      this._fitCard(slot);
    } catch (err) {
      console.warn('[game-center] card build failed:', err);
    }
  }

  // "Post to Instagram", straight under the card it publishes. Opens the
  // publish panel (#gc-social) for the active pill right there — caption,
  // photo/video, schedule, "Post live". Only the roles that may publish
  // see it, so a player just gets the pills and the card.
  _postButtonHtml() {
    if (!this._canPostSocial() || !this.matchId || !this.teamId) return '';
    return `
      <div style="max-width:540px; margin:12px auto;">
        <button type="button" id="gc-post-insta" class="btn ${this._bottomOpen ? 'btn-secondary' : 'btn-primary'}" style="width:100%; font-weight:700; padding:10px 12px;">
          ${this._bottomOpen ? '▾ Hide' : '📸 Post to Instagram —'} ${this.escapeHtml(this._pillTitle(this.pill))}${this._bottomOpen ? ' post' : ''}
        </button>
      </div>`;
  }

  render() {
    const el = document.createElement('div');
    // screen-game-lineup class kept — css/ still targets it, and the
    // stylesheet rename is not worth coupling to this change.
    el.className = 'screen screen-game-lineup screen-game-center';
    el.innerHTML = `
      <div class="screen-header" style="flex-wrap:wrap;">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🏟️ Game Center</h1>
        <p class="subtitle" id="gl-subtitle">Loading…</p>
        <!-- Flip to another game without going back to the list: one pill
             per posted club game (_renderGameSwitch).  Its own full-width
             row — the header is a flex row — scrolling sideways on a phone. -->
        <div id="gc-game-switch" role="tablist" aria-label="Switch game" hidden
             style="flex:1 0 100%; min-width:0; display:flex; gap:6px; overflow-x:auto;"></div>
      </div>
      <!-- Three stacked regions. #gl-head (pills, the card, that post's
           tools, the Post button) and #gl-body (lineup editor) are
           rewritten wholesale by _render() on every zone toggle.
           #gc-social between them is NOT: the SocialPostCard mounted in
           it holds live state a coach has invested in — a typed caption,
           a generated image, a chosen schedule time. Re-creating it on
           each tap would throw that away and re-fire its four API calls.
           _renderSocial owns that node and only rebuilds it when the
           post or its open/closed state actually changes. -->
      <div id="gl-head" style="padding: var(--space-3) var(--space-4) 0;"></div>
      <div id="gc-social" style="padding: 0 var(--space-4);"></div>
      <div id="gl-body" style="padding: 0 var(--space-4) var(--space-6);"></div>

      <!-- RSVP & Player Details, moved here from #game-day-roster.
           Also outside #gl-body: it's a modal, and _render() must not
           tear it down (or reset its search box) while a coach has it
           open and is working through the squad. Keeps the gdr-* class
           names so css/game-day-roster.css carries over untouched. -->
      <div id="gc-details-overlay" class="gdr-overlay" style="display:none;">
        <div class="gdr-overlay-content">
          <div class="gdr-overlay-header">
            <h2>RSVP &amp; Player Details</h2>
            <button id="gc-details-close" class="btn btn-secondary btn-sm">✕ Close</button>
          </div>
          <div class="gdr-overlay-filters">
            <input type="text" id="gc-player-search" class="gdr-search-input" placeholder="Search players...">
            <select id="gc-rsvp-filter" class="gdr-filter-select">
              <option value="all">All RSVP</option>
              <option value="yes">Attending</option>
              <option value="none">No Response</option>
              <option value="no">Not Attending</option>
            </select>
            <select id="gc-list-filter" class="gdr-filter-select">
              <option value="all">All Players</option>
              <optgroup label="Official Rosters">
                <option value="roster_lighthouse">APSL Lighthouse 1893</option>
                <option value="roster_casa">Lighthouse Boys Club</option>
                <option value="roster_u23">Lighthouse Boys Club U23</option>
              </optgroup>
            </select>
          </div>
          <div id="gc-details-list" class="gdr-overlay-list"></div>
        </div>
      </div>
    `;
    this.element = el;
    // Screen instances are reused across navigations (e.g. my.js's
    // "Lineup" and "Game Day Roster" buttons both land here) — every
    // render() call creates a brand-new element, but _wire()'s
    // this._wired guard only ever attaches once. Without this reset,
    // the second+ visit's listener is still attached to the FIRST
    // visit's now-detached element, so nothing on the fresh screen
    // (including Back) responds to clicks. Reset here so _wire() (called
    // from onEnter right after render()) re-attaches to the current one.
    this._wired = false;
    // Same reasoning as _wired: this element is brand new, so whatever
    // the Instagram section was showing on the previous visit is gone
    // with the old DOM. Clearing the marker makes _renderSocial rebuild
    // into the fresh #gc-social instead of short-circuiting on a key
    // that describes a node no longer on the page.
    this._socialMountedFor = null;
    this.socialCard = null;
    return el;
  }

  onEnter(params = {}) {
    // navigation.context.match is the fallback because that's how
    // #game-day-roster's callers (my.js's schedule card,
    // team-dashboard.js's "Game Day" button) have always passed the
    // match — Game Center answers to those entry points too, and they
    // keep working unchanged.
    const ctxMatch = this.navigation?.context?.match || null;
    // params.pick — the top-level 🏟️ Game Center tile (owner 2026-09-17:
    // "a game center at top level for admin/coaches. so i can set
    // lineups"): no game yet, so show the picker and ignore whatever
    // match an earlier screen left in the navigation context.
    const rawMatchId = params.pick ? null
      : (params.matchId != null ? params.matchId : ctxMatch?.id);
    this.matchId = rawMatchId != null ? Number(rawMatchId) : null;
    this.title   = params.pick ? '' : (params.title || ctxMatch?.title || '');
    this.when    = params.when || '';
    // params.view === 'player' — the #my door.  Owner 2026-09-17: "the my
    // page should be player view for admin and coaches too. so its not
    // confusing."  My is where you look at the lineup; the top-level
    // Game Center is where staff set it.
    this.playerOnly = params.view === 'player';
    this.view = params.view || null;
    // The last feed is kept across visits (this instance is reused), so
    // the switcher and the picker are there on enter; _loadGames then
    // refreshes them in the background.
    this._applyFeed();
    this.error = null;
    this.loaded = false;
    this.viewMode = 'coach';
    this.pill    = this._resolvePill(params);
    this._bottomOpen = false; // publish panel starts closed
    this.announceEditing = false;
    this._scoreMsg = '';
    this._detailsMsg = '';
    this._wire();
    this._bootstrap();
  }

  // postType is the deep link ("open Game Center on the Match Result
  // pill"); mode==='gameday' is the older my.js / team-dashboard
  // "Game Day Roster" entry point, which is the 20-Man Squad pill under
  // its new name. Anything unrecognized lands on the default rather
  // than rendering a blank body.
  _resolvePill(params) {
    if (params.postType && POST_PILLS.some(p => p.key === params.postType)) return params.postType;
    if (params.mode === 'gameday') return 'lineup';
    return DEFAULT_PILL;
  }

  // Switching pills is a sub-view change, not a navigation, so this is
  // replaceState rather than a goTo: the URL stays honest
  // (#game-center/<matchId>/<pill>) without stacking one history entry
  // per pill tap, which would turn Back into "undo my last four taps"
  // instead of "leave this game". Deliberately does NOT go through
  // navigation.js — that router only knows #state and #state/<entity>,
  // and this is cosmetic anyway (app.js:start always resumes an
  // authenticated session at role-selection, so no hash is deep-linked
  // on reload).
  _syncHash() {
    if (!this.matchId) return;
    try {
      window.history.replaceState(window.history.state, '', `#game-center/${this.matchId}/${this.pill}`);
    } catch (err) {
      console.warn('[game-center] hash sync failed (non-fatal):', err);
    }
  }

  onExit() {
    if (this._saveTimer) { clearTimeout(this._saveTimer); this._saveTimer = null; }
    // The beam's rAF loop and its ResizeObserver both hold the detached
    // canvas alive otherwise — this screen instance is reused across
    // navigations, so a leaked loop per visit would stack up.
    this._stopCards();
    this.socialCard = null;
    this._socialMountedFor = null;
    if (this._jerseyDebounce) { clearTimeout(this._jerseyDebounce); this._jerseyDebounce = null; }
    this.overlayOpen = false;
  }

  // Same admin-only gate my.js uses for the "Post to Instagram" button on
  // the schedule card (SocialController.cpp's requireAdminLevel({"club",
  // "super","marketing"}) is the real backend rule this mirrors), plus
  // the same "view as <player>" suppression — this screen is reachable
  // by players directly, and impersonation only rewrites data fetches,
  // never navigation.context.user.role.
  _canPostSocial() {
    if (this.auth && this.auth.viewAsPersonId) return false;
    if (this.playerOnly) return false;   // the #my door is look-only
    const role = (this.navigation?.context?.user?.role || '').toString().toLowerCase();
    return ['club', 'super', 'marketing'].includes(role);
  }

  _wire() {
    if (this._wired) return;
    this._wired = true;
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const flip = e.target.closest('[data-switch-game]');
      if (flip) { this._switchGame(Number(flip.getAttribute('data-switch-game'))); return; }
      const pick = e.target.closest('[data-pick-game]');
      if (pick && this.pickerGames) {
        const ev = this.pickerGames[Number(pick.getAttribute('data-pick-game'))];
        if (ev && ev.match_id != null) {
          this.navigation.goTo('game-center', {
            matchId: ev.match_id, title: this._gameLabel(ev), when: this._gameWhen(ev),
          });
        }
        return;
      }
      const viewToggle = e.target.closest('#gl-view-toggle');
      if (viewToggle && this.isCoach) {
        this.viewMode = this.viewMode === 'coach' ? 'player' : 'coach';
        this._render();
        return;
      }
      const remindOne = e.target.closest('[data-gc-remind]');
      if (remindOne && this.isCoach && !remindOne.disabled) { this._remindPlayer(remindOne); return; }
      const availBtn = e.target.closest('[data-gc-avail]');
      if (availBtn && !availBtn.disabled) { this._setMyAvailability(availBtn); return; }
      const squadOne = e.target.closest('[data-gc-squad-one]');
      if (squadOne && this.isCoach && !squadOne.disabled) { this._sendSquadNoticeOne(squadOne); return; }
      const squadBtn = e.target.closest('[data-gc-squad-notice]');
      if (squadBtn && this.isCoach && !squadBtn.disabled) { this._sendSquadNotice(squadBtn); return; }
      const remindAll = e.target.closest('[data-gc-remind-all]');
      if (remindAll && this.isCoach && !remindAll.disabled) { this._remindNoResponse(remindAll); return; }
      // The Instagram section. Its pill strip flips between the posts
      // without touching the page above; nothing picked means no
      // SocialPostCard is mounted, which is also what defers that
      // component's four API calls until they're wanted.
      if (e.target.closest('#gc-post-insta')) {
        this._bottomOpen = !this._bottomOpen;
        this._render();
        return;
      }
      const socialPillBtn = e.target.closest('[data-gc-social-pill]');
      if (socialPillBtn) {
        const key = socialPillBtn.getAttribute('data-gc-social-pill');
        if (POST_PILLS.some(p => p.key === key)) {
          if (key !== this.pill) {
            this.pill = key;
            this._syncHash();
            this._render();
          }
        }
        return;
      }
      if (e.target.closest('#gc-details-open')) { this._openDetails(); return; }
      if (e.target.closest('#gc-details-close')) { this._closeDetails(); return; }

      // Slice C: score entry (Match Result pill) and game details (Game
      // Announcement pill). Both gate on isCoach here AND on the backend
      // (PUT /api/matches/:matchId checks coach-of-team / club admin).
      if (e.target.closest('#gc-score-save') && this.isCoach)  { this._saveScore(false); return; }
      if (e.target.closest('#gc-score-clear') && this.isCoach) { this._saveScore(true); return; }
      if (e.target.closest('#gc-announce-edit') && this.isCoach) {
        this.announceEditing = !this.announceEditing;
        this._detailsMsg = '';
        this._render();
        if (this.announceEditing) this._ensureDetailOptions();
        return;
      }
      if (e.target.closest('#gc-announce-save') && this.isCoach) { this._saveGameDetails(); return; }

      // Coach RSVP override, tri-state. Re-renders only the overlay
      // table — the body underneath catches up on close (_closeDetails),
      // so a coach working down the list isn't watching the page reflow
      // behind the modal on every tap.
      const rsvpBtn = e.target.closest('.gdr-rsvp-btn');
      if (rsvpBtn && this.isCoach) {
        this._setPlayerRSVP(rsvpBtn.dataset.playerId, rsvpBtn.dataset.rsvp);
        this._renderDetailsList();
        return;
      }

      // Practice attendance cell. An override cycles yes → no → release
      // (back to whatever the sync says); a synced cell cycles
      // empty → yes → no → yes, each tap setting an override.
      const pracCell = e.target.closest('.gdr-prac-cell');
      if (pracCell && this.isCoach) {
        e.stopPropagation();
        const personId = pracCell.dataset.personId;
        const eventId = pracCell.dataset.eventId;
        const eventIdx = parseInt(pracCell.dataset.eventIdx, 10);
        const current = pracCell.dataset.current;
        if (pracCell.classList.contains('gdr-prac-override')) {
          const next = current === 'yes' ? 'no' : current === 'no' ? null : 'no';
          if (next === null) this._releasePracticeRSVP(personId, eventId, eventIdx);
          else this._setPracticeRSVP(personId, eventId, eventIdx, next);
        } else {
          this._setPracticeRSVP(personId, eventId, eventIdx, current === 'yes' ? 'no' : 'yes');
        }
        this._renderDetailsList();
        return;
      }
      const zoneBtn = e.target.closest('[data-lineup-zone-btn]');
      if (zoneBtn && this.isCoach) {
        const playerId = Number(zoneBtn.getAttribute('data-player-id'));
        const zone = zoneBtn.getAttribute('data-lineup-zone-btn');
        this._toggleZone(playerId, zone);
        return;
      }
      const statsToggle = e.target.closest('#gl-stats-toggle');
      if (statsToggle && this.isCoach) {
        this.showLineupStats = !this.showLineupStats;
        this._render();
        return;
      }
      // Current Lineup card (2026-08-22, owner directive) — Starting XI
      // and Bench no longer have their own sections below, so removing
      // someone happens right from the summary graphic: click their
      // filled slot/bench row to unassign them, same effect as tapping
      // their own active pill/Bench button would have had.
      const removeStarter = e.target.closest('[data-lineup-remove-starter]');
      if (removeStarter && this.isCoach) {
        const playerId = Number(removeStarter.getAttribute('data-lineup-remove-starter'));
        this._setPosition(playerId, null);
        return;
      }
      const removeBench = e.target.closest('[data-lineup-remove-bench]');
      if (removeBench && this.isCoach) {
        const playerId = Number(removeBench.getAttribute('data-lineup-remove-bench'));
        this._toggleZone(playerId, 'bench');
        return;
      }
      // 1-11 position pills (2026-08-22, owner directive) — a slot
      // already taken by someone else just renders greyed out (see
      // positionPills below), it's not disabled: clicking it replaces
      // whoever's there (_setPosition bumps them back to unassigned).
      // Clicking your OWN active pill removes you instead of replacing
      // yourself.
      const posBtn = e.target.closest('[data-lineup-position-btn]');
      if (posBtn && this.isCoach) {
        const playerId = Number(posBtn.getAttribute('data-player-id'));
        const positionId = Number(posBtn.getAttribute('data-lineup-position-btn'));
        const isMine = this.positions.get(playerId) === positionId;
        this._setPosition(playerId, isMine ? null : positionId);
        return;
      }
    });
    this.element.addEventListener('change', (e) => {
      const benchSelect = e.target.closest('[data-lineup-bench-order-select]');
      if (benchSelect && this.isCoach) {
        const playerId = Number(benchSelect.getAttribute('data-player-id'));
        const order = Number(benchSelect.value);
        this._setBenchOrder(playerId, order);
        return;
      }
      const formationSelect = e.target.closest('[data-lineup-formation-select]');
      if (formationSelect && this.isCoach) {
        this.formation = formationSelect.value;
        this._render();
        return;
      }
      if (e.target.id === 'gc-rsvp-filter') {
        this.filterRsvp = e.target.value;
        this._renderDetailsList();
        return;
      }
      if (e.target.id === 'gc-list-filter') {
        this.listFilter = e.target.value;
        this._renderDetailsList();
      }
    });

    this.element.addEventListener('input', (e) => {
      if (e.target.id === 'gc-player-search') {
        this.filterText = e.target.value.toLowerCase();
        this._renderDetailsList();
        return;
      }
      // Jersey number, debounced — the PUT is per-keystroke otherwise,
      // and a two-digit number is two writes.
      if (e.target.classList.contains('gdr-jersey-input')) {
        const playerId = e.target.dataset.playerId;
        const val = e.target.value;
        const player = this.players.find(p => String(p.playerId) === String(playerId));
        if (player) player.jerseyNumber = val;
        clearTimeout(this._jerseyDebounce);
        this._jerseyDebounce = setTimeout(() => this._saveJerseyNumber(playerId, val), 600);
      }
    });
  }

  // Pill wording: social_post_types.display_name when loaded, else the
  // JS fallback title, else the raw key.
  _pillTitle(key) {
    const meta = POST_PILLS.find(p => p.key === key);
    return (this.postTypeNames && this.postTypeNames[key]) || (meta && meta.title) || key;
  }

  async _bootstrap() {
    const sub = this.find('#gl-subtitle');
    if (!this.matchId) {
      if (this._enterNextGame()) return;
      if (sub) sub.textContent = 'Pick a game';
      const social = this.find('#gc-social');
      if (social) social.innerHTML = '';
      this._render();
      await this._loadGames();
      return;
    }
    if (sub) sub.textContent = [this.title, this.when].filter(Boolean).join(' · ') || 'Loading…';
    // The switcher is up on enter — from the last feed, or just this game
    // until the list lands; nothing waits on it.
    this._renderGameSwitch();
    this._loadGames();

    try {
      const [lineupRes, positionsRes, matchRes, postTypesRes] = await Promise.all([
        this.auth.fetch(`/api/eligibility/lineup/${this.matchId}`),
        this.auth.fetch('/api/eligibility/positions'),
        this.auth.fetch(`/api/matches/${this.matchId}`),
        this.auth.fetch('/api/social/post-types').catch(() => null),
      ]);
      const postTypesData = postTypesRes ? await postTypesRes.json().catch(() => null) : null;
      this.postTypeNames = {};
      for (const t of ((postTypesData && postTypesData.success && postTypesData.data) || [])) {
        if (t && t.name) this.postTypeNames[t.name] = t.display_name || '';
      }
      const lineupData = await lineupRes.json();
      if (!lineupData.success) throw new Error(lineupData.message || 'Failed to load lineup');
      const positionsData = await positionsRes.json().catch(() => null);
      this.positionList = (positionsData && positionsData.success && Array.isArray(positionsData.data))
        ? positionsData.data
        : [];
      // Match-day header (2026-08-22, owner directive: "the player view
      // for both needs to look like an insta post") — home/away crests +
      // date/venue, same data source game-day-roster.js's MATCH DAY card
      // uses, so the two screens read as one cohesive brand instead of a
      // bare pitch diagram with no opponent identity.
      const matchData = await matchRes.json().catch(() => null);
      this.matchDetails = (matchData && matchData.success) ? matchData.data : null;

      this.teamId  = lineupData.data.teamId || null;
      this._loadPostStates();
      this.fieldSize = FIELD_SIZES[lineupData.data.fieldSize] ? Number(lineupData.data.fieldSize) : DEFAULT_FIELD_SIZE;
      this.formation = this._fieldSpec().defaultFormation;
      this.matchStartsAt = lineupData.data.matchStartsAt || null;
      // isCoach comes from EligibilityController checking the REAL logged-in
      // account's admin/coach status — it never looks at the "view as
      // <player>" impersonation the READ request may be carrying, so an
      // admin using view-as still gets isCoach:true from their own account.
      // Force it off here whenever view-as is active (owner, 2026-08-22:
      // "players dont need player lineup view lol... there view is default
      // player") so view-as always renders exactly what the impersonated
      // player would see — no coach toggle, no edit tools, default view.
      this.isCoach = !!lineupData.data.isCoach && !(this.auth && this.auth.viewAsPersonId)
        && !this.playerOnly;
      this.zones = new Map();
      this.positions = new Map();
      this.benchOrder = new Map();
      for (const row of (lineupData.data.lineup || [])) {
        if (row.zone && row.zone !== 'not_selected') {
          this.zones.set(Number(row.playerId), row.zone);
        }
        if (row.zone === 'starter' && row.positionId != null) {
          this.positions.set(Number(row.playerId), Number(row.positionId));
        }
        if (row.zone === 'bench' && row.slotNumber != null) {
          this.benchOrder.set(Number(row.playerId), Number(row.slotNumber));
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

      // Enriched admin data for the 20-Man Squad pill's details overlay.
      // Coach-only (the endpoint gates on it too), and deliberately
      // non-fatal: a failure here costs the overlay, not the lineup
      // editor, so it must never reject the whole bootstrap.
      const detailsPromise = this.isCoach && this.teamId
        ? this.auth.fetch(`/api/matches/${this.matchId}/roster-players?teamId=${this.teamId}`)
            .then(r => r.json())
            .catch(err => { console.warn('[game-center] player details unavailable:', err); return null; })
        : Promise.resolve(null);

      // Reminders already sent about this game — dims a No Response
      // card's button.  Admin-only endpoint; a 403 just means no dimming.
      const remindersPromise = this.isCoach
        ? Promise.all([this._loadReminders(), this._loadSquadNotice()]) : Promise.resolve();

      const [rosterResults, detailsData] = await Promise.all([
        Promise.all(rosterTeamIds.map(id =>
          this.auth.fetch(`/api/teams/${id}/roster`).then(r => r.json()).then(d => ({ id, d })))),
        detailsPromise,
        remindersPromise,
      ]);

      if (detailsData && detailsData.success) {
        this.players = detailsData.data || [];
        this.trainingEvents = detailsData.trainingEvents || [];
      }
      const byId = new Map();
      for (const { id: fromTeamId, d: rosterData } of rosterResults) {
        const arr = Array.isArray(rosterData?.data) ? rosterData.data : [];
        for (const p of arr) {
          if (p.roleType !== 'PLAYER') continue;
          const pid = Number(p.id);
          if (byId.has(pid)) continue; // already merged from an earlier team
          byId.set(pid, { id: pid, name: p.name || '(unnamed)', lastName: p.lastName || '', lineupRole: p.lineupRole || null, teamId: fromTeamId, jerseyNumber: p.jerseyNumber || null });
        }
      }
      this.roster = [...byId.values()];

      this.loaded = true;
      this._syncHash();
      this._render();
    } catch (err) {
      console.error('[game-lineup] load failed:', err);
      this.error = err.message || 'Failed to load lineup.';
      this._render();
    }
  }

  // Bench/Alt only — Starting XI assignment goes through _setPosition
  // instead (owner directive: picking a position IS how a player becomes
  // a starter, no separate "Start" button). Either way, a player only
  // ever holds a position while zone === 'starter', so leaving that zone
  // always clears it.
  _toggleZone(playerId, zone) {
    const current = this.zones.get(playerId);
    if (current === zone) {
      this.zones.delete(playerId); // tap active zone again → unassign
    } else {
      const cap = ZONE_CAPS[zone];
      if (cap != null) {
        const countInZone = [...this.zones.values()].filter(z => z === zone).length;
        if (countInZone >= cap) {
          this._toast(`Bench is full (${cap} max)`);
          return;
        }
      }
      this.zones.set(playerId, zone);
    }
    this.positions.delete(playerId);
    // Bench order (owner directive): joining bench appends to the end;
    // leaving bench (to Alt, Starter, or unassigned) drops the order —
    // it's meaningless once they're not on the bench.
    if (this.zones.get(playerId) === 'bench') {
      if (!this.benchOrder.has(playerId)) {
        const benchCount = [...this.zones.values()].filter(z => z === 'bench').length;
        this.benchOrder.set(playerId, benchCount); // just-added player counts itself → lands last
      }
    } else {
      this.benchOrder.delete(playerId);
    }
    this._render();
    this._scheduleSave();
  }

  // Bench order dropdown (2026-08-22, owner directive: "allow me to edit
  // bench order like in the teams page with dropdown") — move-to-slot-N,
  // everyone else shifts, same pattern as mens-roster.js's
  // roster-position-select. Coach reference only — never shown to
  // players (Bench is always alphabetical in _renderPlayerView).
  _setBenchOrder(playerId, newOrder) {
    const benchIds = [...this.zones.entries()].filter(([, z]) => z === 'bench').map(([id]) => id);
    const sorted = benchIds.slice().sort((a, b) =>
      (this.benchOrder.get(a) ?? Infinity) - (this.benchOrder.get(b) ?? Infinity)
    );
    const fromIdx = sorted.indexOf(playerId);
    if (fromIdx === -1) return;
    sorted.splice(fromIdx, 1);
    const toIdx = Math.max(0, Math.min(newOrder - 1, sorted.length));
    sorted.splice(toIdx, 0, playerId);
    sorted.forEach((id, i) => this.benchOrder.set(id, i + 1));
    this._render();
    this._scheduleSave();
  }

  // Starting XI assignment (2026-08-22, owner directive) — picking a
  // position sets zone='starter' with that position_id/slot in one move;
  // picking "—" while already a starter sends them back to their RSVP
  // group, same as tapping an active Bench/Alt pill again. Clicking a
  // slot someone ELSE already holds replaces them — they're bumped back
  // to unassigned (their RSVP group, e.g. "Going") rather than blocking
  // the click; the pill's greyed-out style is just occupancy at a
  // glance, not a lock. Never exceeds the format's starters (7/9/11):
  // replacing frees a slot in the same stroke as filling it, and there
  // are only fieldSize pills.
  _setPosition(playerId, positionId) {
    if (positionId == null) {
      this.zones.delete(playerId);
      this.positions.delete(playerId);
      this._render();
      this._scheduleSave();
      return;
    }
    for (const [otherId, otherPos] of this.positions.entries()) {
      if (otherPos === positionId && otherId !== playerId) {
        this.zones.delete(otherId);
        this.positions.delete(otherId);
        break;
      }
    }
    this.zones.set(playerId, 'starter');
    this.positions.set(playerId, positionId);
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
      if (zone === 'starter') {
        const positionId = this.positions.get(playerId) ?? null;
        // slotNumber mirrors positionId 1:1 for the 1-11 picker (see
        // positionPills) — both land in match_lineups so lineups built
        // before this feature (positionId always null) still sort sanely.
        starters.push({ playerId, ...(positionId != null ? { positionId, slotNumber: positionId } : {}) });
      }
      else if (zone === 'bench') {
        const order = this.benchOrder.get(playerId) ?? null;
        bench.push({ playerId, ...(order != null ? { slotNumber: order } : {}) });
      }
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

  // ── Game picker (no match yet) ──────────────────────────────────────
  // The top-level entry: every upcoming game on the club calendar, soonest
  // first.  Same feed as #calendar (GET /api/calendar/upcoming), so a game
  // shows here exactly when it shows there.  Opening one is a goTo, so
  // Back returns to this list.  Who may EDIT a game is still decided per
  // game by the backend (isCoach on the lineup load).
  async _loadGames() {
    // Flipping pills re-enters the screen each time; a feed this fresh is
    // not worth fetching again.
    if (this._feedGames && Date.now() - this._feedAt < 60000) { this._renderGameSwitch(); return; }
    try {
      // From this week's Monday, so the switcher keeps the games already
      // played this week; the picker itself only lists what is still to come.
      const d = this._weekStart(new Date());
      const start = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
      const res = await this.auth.fetch(`/api/calendar/upcoming?start=${start}&days=35`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const body = await res.json();
      const events = Array.isArray(body.events) ? body.events : [];
      this._feedGames = events
        .filter(ev => ev.kind === 'match')
        .sort((a, b) => String(a.starts_at).localeCompare(String(b.starts_at)));
      this._feedAt = Date.now();
      this._applyFeed();
    } catch (err) {
      console.error('[game-center] games load failed:', err);
      // A failed refresh keeps the last list; only the picker with nothing
      // to show reports it.
      if (!this.games && !this.matchId) this.error = 'Could not load the upcoming games.';
    }
    if (!this.matchId && this._enterNextGame()) return;
    if (!this.matchId) this._render();
    this._paintMyAvailability();
    this._renderGameSwitch();
  }

  // The top-level tile lands on a game, not a list — owner 2026-09-18: "it
  // takes you right to first game chronologically as selected pill but all
  // games are there on pills".  The next posted game still to finish, else
  // the week's last one; the picker stays for a week with nothing posted.
  _enterNextGame() {
    const games = (this.games || []).filter(ev => ev.match_id != null && this._isPosted(ev));
    if (!games.length) return false;
    const now = Date.now();
    const over = (ev) => {
      const end = new Date(ev.ends_at || ev.starts_at).getTime() + (ev.ends_at ? 0 : 2 * 60 * 60 * 1000);
      return end < now;
    };
    this._switchGame((games.find(ev => !over(ev)) || games[games.length - 1]).match_id);
    return true;
  }

  // this.games / this.pickerGames from the kept feed.  The club's games, from
  // every door — owner 2026-09-18: "its not team dependant the drop down
  // its the club games this week".
  _applyFeed() {
    if (!this._feedGames) { this.games = null; this.pickerGames = null; return; }
    this.games = this._feedGames;
    const today = new Date(); today.setHours(0, 0, 0, 0);
    this.pickerGames = this.games.filter(ev => new Date(ev.starts_at) >= today);
  }

  // Monday 00:00 of the week holding this date.
  _weekStart(date) {
    const d = new Date(date); d.setHours(0, 0, 0, 0);
    d.setDate(d.getDate() - ((d.getDay() + 6) % 7));
    return d;
  }

  // Posted = inside the schedule release window My Schedule shows
  // (schedule_window_end, mig 334); an event without one falls back to the
  // end of this week.  Owner 2026-09-18: "only show this weeks games. not
  // future unposted for rsvp ones".
  _isPosted(ev) {
    const t = new Date(ev.starts_at);
    const fallback = this._weekStart(new Date()); fallback.setDate(fallback.getDate() + 7);
    const winEnd = ev.schedule_window_end ? new Date(ev.schedule_window_end) : fallback;
    return !isNaN(t) && t <= winEnd;
  }

  // The header's game pills: the posted club games — this week's, plus
  // whatever the release window has opened early — in kickoff order, this
  // game lit.  Owner 2026-09-18: "pills instead of drop down to cycle
  // through quicker".  Hidden on the picker and when there is nothing else
  // to flip to; before the list is in, this game's pill stands alone.
  _renderGameSwitch() {
    const strip = this.find('#gc-game-switch');
    if (!strip) return;
    const games = (this.games || []).filter(ev => ev.match_id != null
      && (ev.match_id === this.matchId || this._isPosted(ev)));
    if (!this.matchId || (this.games && !games.some(ev => ev.match_id !== this.matchId))) {
      strip.hidden = true;
      strip.style.display = 'none';
      return;
    }
    const pill = (id, top, bottom, active) => `<button type="button" role="tab" aria-selected="${active}"
      ${id != null ? `data-switch-game="${id}"` : ''} class="btn ${active ? 'btn-primary' : 'btn-secondary'}"
      style="flex:0 0 auto; display:flex; flex-direction:column; align-items:center; gap:1px;
             font-size:0.72rem; line-height:1.25; padding:6px 10px; white-space:nowrap;">
        <span style="font-weight:700;">${this.escapeHtml(top)}</span>
        <span style="opacity:0.85;">${this.escapeHtml(bottom)}</span></button>`;
    const short = (ev) => {
      const d = new Date(ev.starts_at);
      return isNaN(d) ? '' : `${d.toLocaleDateString('en-US', { weekday: 'short' })} ${d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })}`;
    };
    // Board labels on top ("🏆 APSL"), kickoff and opponent under them.
    const teamsOf = (ev) => (Array.isArray(ev.teams) ? ev.teams : [])
      .map(t => t.label || t.name).filter(Boolean).join(' + ') || 'Game';
    const vsOf = (ev) => ev.opponent ? `${ev.is_home === false ? '@' : 'vs'} ${ev.opponent}` : '';
    const known = games.some(ev => ev.match_id === this.matchId);
    strip.innerHTML =
      (known ? '' : pill(null, this.title || 'This game', this.when || '', true)) +
      games.map(ev => pill(ev.match_id, teamsOf(ev), [short(ev), vsOf(ev)].filter(Boolean).join(' · '),
                           ev.match_id === this.matchId)).join('');
    strip.hidden = false;
    strip.style.display = 'flex';
    const lit = strip.querySelector('[aria-selected="true"]');
    if (lit && lit.scrollIntoView) lit.scrollIntoView({ block: 'nearest', inline: 'center' });
  }

  // Same page, another game: keep the pill and the door we came in by, and
  // no history entry — Back still leaves Game Center in one step.
  _switchGame(matchId) {
    const ev = (this.games || []).find(g => g.match_id === matchId);
    if (!ev || matchId === this.matchId) return;
    this.onExit();   // timers, beam animation, social card — as if we had left
    const social = this.find('#gc-social');
    if (social) social.innerHTML = '';
    this.onEnter({ matchId, title: this._gameLabel(ev), when: this._gameWhen(ev),
                   view: this.view || undefined, postType: this.pill });
  }

  _gameLabel(ev) {
    const teams = (Array.isArray(ev.teams) ? ev.teams : []).map(t => t.name).filter(Boolean).join(' + ');
    const vs = ev.opponent ? `${ev.is_home === false ? '@' : 'vs'} ${ev.opponent}` : '';
    return [teams, vs].filter(Boolean).join(' ') || 'Game';
  }

  _gameWhen(ev) {
    const d = new Date(ev.starts_at);
    if (isNaN(d.getTime())) return '';
    const day  = d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
    const time = d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
    return `${day} · ${time}`;
  }

  _renderGamePicker() {
    if (!this.pickerGames.length) {
      return `<div class="empty-state" style="padding: var(--space-4); text-align:center; opacity:0.8;">No games on the calendar yet.</div>`;
    }
    return `<div style="display:flex; flex-direction:column; gap:8px; max-width:640px; margin:0 auto; padding-bottom: var(--space-6);">
      ${this.pickerGames.map((ev, i) => {
        const linked = ev.match_id != null;
        return `<button type="button" class="btn btn-secondary" data-pick-game="${i}" ${linked ? '' : 'disabled'}
                        style="display:flex; flex-direction:column; align-items:flex-start; gap:2px; text-align:left; padding:10px 12px;">
          <span style="font-weight:700;">${this.escapeHtml(this._gameLabel(ev))}</span>
          <span style="font-size:0.8rem; opacity:0.8;">${this.escapeHtml([this._gameWhen(ev), ev.location].filter(Boolean).join(' · '))}</span>
          ${linked ? '' : '<span style="font-size:0.72rem; color:#f59e0b;">Not linked to a team yet</span>'}
        </button>`;
      }).join('')}
    </div>`;
  }

  _render() {
    const box = this.find('#gl-body');
    const head = this.find('#gl-head');
    if (!box || !head) return;

    if (this.error || (!this.matchId && this.games) || !this.loaded) {
      head.innerHTML = '';
      const social = this.find('#gc-social');
      if (social) social.innerHTML = '';
      this._socialMountedFor = null;
      this.socialCard = null;
    }
    if (this.error) {
      box.innerHTML = `<div class="empty-state" style="padding: var(--space-4); text-align:center; opacity:0.8;">${this.escapeHtml(this.error)}</div>`;
      return;
    }
    if (!this.matchId && this.games) {
      box.innerHTML = this._renderGamePicker();
      return;
    }
    if (!this.loaded) {
      box.innerHTML = `<div class="loading-state"><div class="spinner"></div><p>Loading…</p></div>`;
      return;
    }

    // Unassigned split into RSVP groups (2026-08-22, owner directive) —
    // same three-way Going/Not Going/No Response partition the older
    // lineups.js multi-team board uses, so a coach can jump straight to
    // "who's actually coming" instead of scanning one long sorted list.
    const rsvpGroup = (playerId) => {
      const rsvp = this.stats.get(playerId)?.gameRsvp;
      if (rsvp === 'yes') return 'going';
      if (rsvp === 'no') return 'notGoing';
      return 'noResponse';
    };
    const starterEligibleRank = (p) => p.lineupRole === 'starter' ? 0 : 1;
    const byStarterRank = (a, b) => starterEligibleRank(a) - starterEligibleRank(b);

    const byZone = { starter: [], bench: [], alternate: [] };
    const unassignedGoing = [], unassignedNotGoing = [], unassignedNoResponse = [];
    for (const p of this.roster) {
      const z = this.zones.get(p.id);
      if (z && byZone[z]) { byZone[z].push(p); continue; }
      const group = rsvpGroup(p.id);
      if (group === 'going') unassignedGoing.push(p);
      else if (group === 'notGoing') unassignedNotGoing.push(p);
      else unassignedNoResponse.push(p);
    }
    unassignedGoing.sort(byStarterRank);
    unassignedNotGoing.sort(byStarterRank);
    unassignedNoResponse.sort(byStarterRank);

    // Coach ↔ Player view toggle (2026-08-22, owner directive: "only need
    // 1 Lineup button on screen" — coach previews exactly what players
    // see via a link on this same page instead of a separate screen/
    // route). Players always get the player view.
    const effectiveIsPlayerView = !this.isCoach || this.viewMode === 'player';
    const viewToggleHtml = this.isCoach
      ? `<div style="text-align:right; margin-bottom:8px;">
           <button id="gl-view-toggle" type="button" class="btn btn-secondary" style="font-size:0.8rem; padding:4px 10px;">
             ${this.viewMode === 'coach' ? '👀 Player Lineup View' : '✏️ Coach View'}
           </button>
         </div>`
      : '';

    // One assignment point for every pill, so the card mount and the
    // publish panel are wired in exactly one place. Everything is up top
    // (owner, 2026-09-19: "is there any reason to have a separate
    // instagram section? why cant we just have it all up top?"): pills
    // flip the one card, that post's tools and Post button sit right
    // under it, and the lineup editor follows.
    const paint = (bodyHtml) => {
      head.innerHTML = `<div id="gc-social-pills" role="tablist" aria-label="Posts for this game" style="display:flex; gap:6px; margin-bottom:10px; overflow-x:auto;">${this._socialPillsHtml()}</div>`
        + `<div data-gc-my-avail>${this._myAvailabilityHtml()}</div>`
        + this._renderCard('top', this.pill) + this._pillToolsHtml(this.pill, byZone) + this._postButtonHtml();
      box.innerHTML = bodyHtml;
      this._renderSocial(byZone);
      this._mountCard('top', this.pill, byZone);
    };

    // The lineup editor belongs to the two posts drawn from it; the
    // announcement and the result have their own tools and nothing else.
    if (this.pill !== 'starters_bench' && this.pill !== 'lineup') {
      paint('');
      return;
    }

    if (effectiveIsPlayerView) {
      paint(viewToggleHtml + (this.pill === 'starters_bench' ? this._renderPlayerNotes(byZone) : ''));
      return;
    }

    // Coach's own Bench section reflects the bench order they set
    // (owner directive) — unlike the Player Lineup View, which always
    // shows Bench alphabetically regardless.
    byZone.bench.sort((a, b) => (this.benchOrder.get(a.id) ?? Infinity) - (this.benchOrder.get(b.id) ?? Infinity));

    // rosterById/slotToPlayerId computed once per render (not per row) —
    // shared by both the top summary graphic and the position pills
    // below it, so every row/cell reflects current global occupancy.
    const { rosterById, slotToPlayerId, startingPositions } = this._slotMaps();

    // Top summary graphic (2026-08-22, owner directive: "show at top the
    // lineup and totals in a graphic form like on tv"). List View removed
    // for now (owner, 2026-08-22: "take out list view for now at least so
    // we don't gunk up things. all insta grade ratio view") — the
    // formation pitch is the only Current Lineup display; assignment
    // itself still happens via the position pills in the roster cards
    // below, unaffected either way. No outer card here — this renders
    // INSIDE _renderMatchHeader()'s frame now.
    // Editing controls (formation dropdown, availability toggle) live
    // OUTSIDE the graphic frame now (owner, 2026-08-22: "don't have
    // options on the insta post like drop downs. that should be under
    // it. to change it on the fly.") — summaryHtml itself is pure post
    // content (pitch + bench) with nothing but the graphic inside the
    // frame; lineupControlsHtml renders as a normal toolbar below it.
    const lineupControlsHtml = `
      <div style="display:flex; justify-content:space-between; align-items:center; margin:10px 0 12px; flex-wrap:wrap; gap:8px;">
        <span style="font-size:0.72rem; opacity:0.75;">Starting ${byZone.starter.length}/${this.fieldSize} · Bench ${byZone.bench.length} · Alt ${byZone.alternate.length}</span>
        <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
          <select data-lineup-formation-select title="Formation (visual layout only)"
                  style="font-size:0.72rem; font-weight:700; padding:4px 6px; border-radius:4px; border:1px solid #475569; background:#0f172a; color:#fff;">
            ${Object.keys(this._fieldSpec().formations).map(f => `<option value="${f}" ${f === this.formation ? 'selected' : ''}>${f}</option>`).join('')}
          </select>
          <button type="button" id="gl-stats-toggle" class="btn btn-secondary" style="font-size:0.72rem; padding:4px 10px;">
            ${this.showLineupStats ? 'Hide' : 'Show'} Availability
          </button>
        </div>
      </div>`;


    // Bench/Alt only now — Starting XI goes through the 1-11 position
    // pills below instead of a "Start" button (owner directive).
    const zoneButtons = (playerId) => `
      <div style="display:flex; gap:4px;">
        ${['bench', 'alternate'].map(z => {
          const active = this.zones.get(playerId) === z;
          const label = z === 'bench' ? 'Bench' : 'Alt';
          return `<button type="button" data-lineup-zone-btn="${z}" data-player-id="${playerId}"
            class="btn btn-sm ${active ? 'btn-primary' : 'btn-secondary'}"
            style="padding:2px 8px; font-size:0.75rem;">${label}</button>`;
        }).join('')}
      </div>`;

    const positionPills = (p) => {
      if (!startingPositions.length) return '';
      return `<div style="display:flex; gap:3px; flex-wrap:wrap; margin-top:4px;">
        ${startingPositions.map(pos => {
          const occupantId = slotToPlayerId.get(pos.id);
          const isMine = occupantId === p.id;
          const takenByOther = occupantId != null && !isMine;
          const style = isMine
            ? 'background:#22c55e; color:#052e16; border:1px solid #22c55e; cursor:pointer;'
            : takenByOther
              ? 'background:#1e293b; color:#64748b; border:1px solid #334155; cursor:pointer;'
              : 'background:#334155; color:#fff; border:1px solid #475569; cursor:pointer;';
          const title = takenByOther
            ? `${pos.name} — currently ${rosterById.get(occupantId)?.name || 'taken'}, click to replace`
            : pos.name;
          return `<button type="button" data-lineup-position-btn="${pos.id}" data-player-id="${p.id}"
            title="${this.escapeHtml(title)}"
            style="padding:1px 7px; font-size:0.68rem; font-weight:800; border-radius:3px; line-height:1.4; min-width:20px; text-align:center; ${style}">
            ${pos.sortOrder}
          </button>`;
        }).join('')}
      </div>`;
    };

    // Bench order dropdown (2026-08-22, owner directive) — move-to-slot-N
    // picker, same UX as mens-roster.js's roster-position-select. Only
    // shown once there's more than one bench player to order (matches
    // that screen's "only worth showing with something to reorder
    // against" convention). See _setBenchOrder.
    const benchTotal = byZone.bench.length;
    const benchOrderControl = (p) => {
      if (benchTotal <= 1) return '';
      const current = this.benchOrder.get(p.id) || benchTotal;
      return `<select data-lineup-bench-order-select data-player-id="${p.id}"
                 title="Bench order — coach reference only, players always see Bench alphabetically"
                 style="font-size:0.68rem; font-weight:700; padding:0 2px; line-height:1.3; border-radius:3px; border:1px solid #475569; background:#0f172a; color:#fff;">
           ${Array.from({ length: benchTotal }, (_, i) => i + 1)
             .map(n => `<option value="${n}" ${n === current ? 'selected' : ''}>#${n}</option>`)
             .join('')}
         </select>`;
    };

    // Read-only Roster Role chip (2026-08-22) — this designation is now
    // set from the Teams roster board (mens-roster.js's Roster Role
    // dropdown, PUT /api/teams/:teamId/roster/person/:personId/lineup-role),
    // not from this per-match screen. Still shown here so a coach building
    // a lineup can see it without leaving the page.
    const ROLE_LABEL = { starter: '1st Team Starter', bench: '1st Team Bench', reserve: '1st Team Reserve' };
    const roleButtons = (p) => {
      const label = ROLE_LABEL[p.lineupRole];
      if (!label) return '';
      return `<span title="Roster Role — set on the Teams page"
        style="padding:1px 6px; font-size:0.68rem; font-weight:700; border-radius:3px; background:#334155; color:#e2e8f0; white-space:nowrap;">${label}</span>`;
    };

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

    const playerRow = (p, extra = '') => `
      <div style="padding:6px var(--space-3); border-bottom:1px solid var(--border-color);">
        <div style="display:flex; align-items:center; justify-content:space-between; gap:8px;">
          <span style="font-size:0.9em; display:flex; align-items:center; gap:6px; min-width:0; flex-wrap:wrap;">
            <span style="overflow-wrap:break-word; white-space:normal;">${this.escapeHtml(p.name)}</span>
            ${this.isCoach ? this._rsvpStatusPill(p.id) : ''}
          </span>
          <div style="display:flex; align-items:center; gap:6px; flex-shrink:0;">
            ${this.isCoach && this.zones.get(p.id) === 'bench' ? benchOrderControl(p) : ''}
            ${this.isCoach ? zoneButtons(p.id) : ''}
          </div>
        </div>
        ${this.isCoach ? positionPills(p) : ''}
        ${this.isCoach ? `
          <div style="display:flex; align-items:center; justify-content:space-between; gap:8px; margin-top:3px;">
            ${statsLine(p.id)}
            ${roleButtons(p)}
          </div>
        ` : ''}
        ${extra}
      </div>`;

    // Multiple player cards per line instead of one full-width row each
    // (owner directive: "like on teams screen, so there is less blank
    // space on desktop") — every coach-view section (Starting/Bench/
    // Alternates/Going/collapsed Not-Going/No-Response) uses this same
    // auto-fill grid, each card wrapping playerRow's content in its own
    // bordered tile instead of a shared list divider.
    const cardGrid = (players, extra = null) => players.length
      ? `<div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(280px, 1fr)); gap:6px;">
          ${players.map(p => `<div style="border:1px solid var(--border-color); border-radius:6px; overflow:hidden;">${playerRow(p, extra ? extra(p) : '')}</div>`).join('')}
        </div>`
      : `<div style="padding:6px var(--space-3); opacity:0.6; font-size:0.85em;">None yet</div>`;

    const gridSection = (label, players, extra = null) => `
      <h2 style="margin: var(--space-3) 0 4px; font-size:0.85rem;">${label} (${players.length})</h2>
      ${cardGrid(players, extra)}
    `;

    // Not Going / No Response rolled up out of the way by default (owner
    // directive: "...have them rolled up so they are not in way") — a
    // coach almost never needs these, unlike Going.
    const collapsedSection = (label, players, { top = '', extra = null } = {}) => `
      <details style="margin: var(--space-3) 0;">
        <summary style="cursor:pointer; font-size:0.85rem; font-weight:700; padding:4px 0;">${label} (${players.length})</summary>
        ${players.length ? top : ''}
        ${cardGrid(players, extra)}
      </details>
    `;

    // No Response gets reminders (owner 2026-09-19: "a group text/email
    // and individual buttons on the player cards for reminders for 'all'
    // rsvps so it catches the practice missing too").  Both go through
    // the #rsvps endpoints, so the message is the DB copy and the send is
    // logged on the player's #rsvps card: a card button is the personal
    // reminder (every unanswered event of the week + their magic link);
    // the bar is ONE group text / BCC email listing the week's open
    // events, no link.  Club admins only, like #rsvps — the backend says
    // so to anyone else.
    // sent: a reminder about this game already went out on that channel.
    // The button dims but stays clickable — some players need a second
    // nudge, and the dim + tooltip says one went already (owner 2026-09-19).
    const remindBtn = (attrs, label, bg, title, sent = null) =>
      `<button type="button" ${attrs} title="${this.escapeHtml(sent ? this._sentTitle(sent) + ' — click to send again' : title)}"
               style="padding:3px 9px; border-radius:6px; border:none; cursor:pointer; font-weight:800; font-size:0.68rem; color:#fff; background:${bg};${sent ? ' opacity:0.4;' : ''}">${label}${sent ? ` ✓ ×${sent.count || 1}` : ''}</button>`;
    const remindBar = `
      <div style="display:flex; gap:8px; flex-wrap:wrap; align-items:center; margin:4px 0 8px; font-size:0.78rem;">
        <span style="opacity:0.75;">Remind everyone who hasn't answered this game — lists the week's open events, practices too:</span>
        ${remindBtn('data-gc-remind-all="sms"', '💬 GROUP TEXT', '#0284c7', 'One group text (split into groups of 10) — no sign-in link, everyone sees each other\'s number')}
        ${remindBtn('data-gc-remind-all="email"', '✉ EMAIL', '#7c3aed', 'One email, everyone BCC\'d — no sign-in link')}
        <span data-gc-remind-result style="flex-basis:100%;"></span>
      </div>`;
    const remindCard = (p) => {
      const personId = this._personIdFor(p.id);
      if (!personId) return '';
      const sent = (this.reminders || {})[personId] || {};
      return `
        <div style="display:flex; gap:6px; align-items:center; margin-top:5px;">
          ${remindBtn(`data-gc-remind="sms" data-person-id="${personId}"`, '💬 REMIND', '#0284c7', 'Text every unanswered event this week + their sign-in link (the parent, for youth)', this._weekSent(sent))}
          ${remindBtn(`data-gc-remind="email" data-person-id="${personId}"`, '✉ REMIND', '#7c3aed', 'Email every unanswered event this week + their sign-in link (the parent, for youth)', this._weekSent(sent))}
          <span data-gc-remind-note style="font-size:0.66rem; opacity:0.75;">${this.escapeHtml(this._sentNote(sent))}</span>
        </div>`;
    };

    // Game reminder to the whole squad — Starting, Bench and Alternates,
    // Going or not (owner 2026-09-19: "i got guys who set going asking if
    // there is a game").  The RSVP reminders above only reach No
    // Response; this one tells everybody picked that the game is on and
    // links straight to this page's Starters & Bench pill, where they see
    // their role and can still change their availability.  Copy is the
    // DB's (kind=squad_notice, mig 383); admins only, like the reminders.
    const squadSize = byZone.starter.length + byZone.bench.length + byZone.alternate.length;
    // told: some notice went out already.  Once it has, a second pair of
    // buttons reaches only whoever was added or moved since (owner
    // 2026-09-19: "send again to all or just the ones changed").
    const told = !!(this.squadNotice && (this.squadNotice.sms || this.squadNotice.email));
    const untold = (this.squadNotice && this.squadNotice.untold) || 0;
    const squadBar = squadSize ? `
      <div data-gc-squad-bar style="display:flex; gap:8px; flex-wrap:wrap; align-items:center; margin:0 0 12px; font-size:0.78rem;">
        <span style="opacity:0.75;">Game reminder to the squad (${squadSize}) — game, where, arrival + a link to this lineup:</span>
        ${remindBtn('data-gc-squad-notice="sms" data-scope="all"', '💬 GROUP TEXT', '#0284c7', 'One group text to Starting, Bench and Alternates (split into groups of 10) — no sign-in link, everyone sees each other\'s number', this.squadNotice?.sms)}
        ${remindBtn('data-gc-squad-notice="email" data-scope="all"', '✉ EMAIL', '#7c3aed', 'One email to Starting, Bench and Alternates, everyone BCC\'d — no sign-in link', this.squadNotice?.email)}
        ${told && untold ? `
          <span style="opacity:0.75;">· ${untold} added or moved since:</span>
          ${remindBtn('data-gc-squad-notice="sms" data-scope="changed"', `💬 TEXT THE ${untold}`, '#0284c7', 'Group text only the players who were never told, or whose role changed since')}
          ${remindBtn('data-gc-squad-notice="email" data-scope="changed"', `✉ EMAIL THE ${untold}`, '#7c3aed', 'Email (BCC) only the players who were never told, or whose role changed since')}`
          : `<span style="opacity:0.75;">${told ? 'everyone told ✓' : ''}</span>`}
        <span data-gc-squad-result style="flex-basis:100%;"></span>
      </div>` : '';
    // Card buttons on Starting / Bench / Alternates — the player's own
    // message: names their role, magic link lands on this game (mig 384).
    // Dim once sent; amber "moved" when the role they were told is not
    // the one they hold now.
    const squadCard = (p) => {
      const personId = this._personIdFor(p.id);
      if (!personId) return '';
      const sent = ((this.squadNotice && this.squadNotice.people) || {})[personId] || {};
      const zone = this.zones.get(p.id);
      const moved = sent.told_zone && sent.told_zone !== zone;
      const live = moved ? {} : sent;   // a moved player's buttons light up again
      return `
        <div style="display:flex; gap:6px; align-items:center; margin-top:5px;">
          ${remindBtn(`data-gc-squad-one="sms" data-person-id="${personId}"`, '💬 GAME LINK', '#0284c7', 'Text their role for this game + their sign-in link straight to this lineup (the parent, for youth)', live.sms)}
          ${remindBtn(`data-gc-squad-one="email" data-person-id="${personId}"`, '✉ GAME LINK', '#7c3aed', 'Email their role for this game + their sign-in link straight to this lineup (the parent, for youth)', live.email)}
          <span data-gc-squad-note style="font-size:0.66rem; opacity:0.75;">${moved
            ? `<span style="color:#fbbf24;">moved since told (${this.escapeHtml(sent.told_zone)})</span>`
            : this.escapeHtml(this._sentNote(sent))}</span>
        </div>`;
    };

    // Bench section (2026-08-24, owner: "the bench needs to be selectable
    // on the graphic to remove them like we do for the starters. or they
    // need to be shown in the area under graphic") — of the two, under
    // the graphic is the one that fits: the bench inside the post is a
    // plain comma-separated name list by explicit directive ("you can put
    // bench at bottom without chips but list names in full csv"), and
    // controls belong outside the frame ("don't have options on the insta
    // post like drop downs. that should be under it").
    //
    // Without this the bench was a dead end. A benched player is no
    // longer unassigned, so they fell out of Going/Not Going/No Response,
    // and there was no Bench grid to land in — the only place their name
    // appeared was the non-interactive CSV in the graphic. Nothing could
    // move them back off. Rendering them through the same cardGrid the
    // other sections use fixes that with no new interaction to learn:
    // tapping the already-active Bench button unassigns (_toggleZone),
    // Alt moves them across, a position pill promotes them to the XI, and
    // the bench-order dropdown is finally reachable on the players it
    // actually applies to. Placed above Alternates — a coach touches the
    // bench far more often. Sorted by the coach's bench order, applied to
    // byZone.bench above.
    // Starters get a card section too (owner 2026-09-17: "we need to still
    // show players we put in lineup in card form so we can still see their
    // practice tallies... no one should" disappear).  Before this a player
    // given a position left the card area for the pitch graphic, taking
    // their practice tally and RSVP pill with them — exactly the numbers a
    // coach weighs when deciding who starts.  Every rostered player is now
    // in exactly one card section, whatever their zone.
    paint(viewToggleHtml + lineupControlsHtml + (this.isCoach ? squadBar : '') + [
      this.isCoach ? gridSection('Starting', [...byZone.starter].sort((a, b) => {
        // In formation order (1 = keeper …), same numbers as the pills.
        const order = (pl) => startingPositions.find(pos => slotToPlayerId.get(pos.id) === pl.id)?.sortOrder ?? Infinity;
        return order(a) - order(b);
      }), squadCard) : '',
      gridSection('Bench', byZone.bench, this.isCoach ? squadCard : null),
      gridSection('Alternates', byZone.alternate, this.isCoach ? squadCard : null),
      this.isCoach ? gridSection('✓ Going', unassignedGoing) : '',
      this.isCoach ? collapsedSection('✗ Not Going', unassignedNotGoing) : '',
      this.isCoach ? collapsedSection('– No Response', unassignedNoResponse, { top: remindBar, extra: remindCard }) : '',
    ].join(''));
  }

  // ---- Your availability ----
  //
  // The squad game reminder links here (owner 2026-09-19: "takes them
  // straight there to set availability … shows a section at top for that
  // player to set their availability again and shows their availability
  // currently").  One row for the viewer when they are expected at this
  // game, one per child for a guardian — the same feed fields and the
  // same POST/DELETE /api/calendar/rsvp that #my answers with, so there
  // is one RSVP, shown in two places.  Nothing renders for a viewer the
  // game does not expect (a coach who does not play, an admin).
  _myAvailabilityRows() {
    const ev = (this.games || []).find(g => g.match_id === this.matchId);
    if (!ev) return null;
    const kids = Array.isArray(ev.guardian_targets) ? ev.guardian_targets : [];
    const rsvps = Array.isArray(ev.rsvps) ? ev.rsvps : [];
    const rows = [];
    if (ev.my_rsvp_eligible !== false && (ev.my_rsvp_eligible === true || !kids.length))
      rows.push({ personId: null, name: 'You', response: ev.my_rsvp || null });
    for (const kid of kids)
      rows.push({ personId: kid.person_id, name: kid.name || 'Your player',
                  response: (rsvps.find(r => r && r.person_id === kid.person_id) || {}).response || null });
    return { ev, rows };
  }

  _myAvailabilityHtml() {
    const mine = this._myAvailabilityRows();
    if (!mine || !mine.rows.length) return '';
    const { ev, rows } = mine;
    const end = new Date(ev.ends_at || ev.starts_at).getTime() + (ev.ends_at ? 0 : 2 * 60 * 60 * 1000);
    const closed = end < Date.now() ? 'This game is over'
      : (ev.rsvps_open_now === false ? 'Availability is not open for this game yet' : '');
    const word = (r) => r === 'yes' ? '✅ Going' : r === 'no' ? '❌ Not Going' : r === 'maybe' ? '❔ Maybe' : '— Not answered yet';
    const btn = (row, response, label, colour) => {
      const active = row.response === response;
      return `<button type="button" data-gc-avail="${response}" ${row.personId ? `data-person-id="${row.personId}"` : ''}
                      ${closed ? `disabled title="${this.escapeHtml(closed)}"` : ''}
                      style="padding:6px 12px; border-radius:8px; font-weight:800; font-size:0.78rem; cursor:${closed ? 'default' : 'pointer'};
                             border:2px solid ${colour}; color:#fff; background:${active ? colour : 'transparent'}; opacity:${closed ? 0.45 : 1};">${label}</button>`;
    };
    return `
      <div style="margin:0 0 12px; padding:10px 12px; border-radius:10px; border:1px solid #334155; background:rgba(15,23,42,0.6);">
        <div style="font-size:0.7rem; font-weight:800; letter-spacing:0.05em; opacity:0.7; margin-bottom:6px;">YOUR AVAILABILITY FOR THIS GAME</div>
        ${rows.map(row => `
          <div style="display:flex; align-items:center; justify-content:space-between; gap:8px; flex-wrap:wrap; margin-top:4px;">
            <span style="font-size:0.85rem;"><strong>${this.escapeHtml(row.name)}</strong> · ${word(row.response)}</span>
            <span style="display:flex; gap:6px;">
              ${btn(row, 'yes', 'Going', '#16a34a')}
              ${btn(row, 'no', 'Not Going', '#dc2626')}
            </span>
          </div>`).join('')}
        <div data-gc-avail-msg style="font-size:0.7rem; margin-top:6px; opacity:0.75;">${this.escapeHtml(closed || 'Plans changed? Change it here any time — the coaches see it right away.')}</div>
      </div>`;
  }

  _paintMyAvailability() {
    const slot = this.element && this.element.querySelector('[data-gc-my-avail]');
    if (slot) slot.innerHTML = this._myAvailabilityHtml();
  }

  // Tapping the answer you already gave clears it, like #my.
  async _setMyAvailability(btn) {
    const mine = this._myAvailabilityRows();
    if (!mine) return;
    const { ev } = mine;
    const response = btn.dataset.gcAvail === 'no' ? 'no' : 'yes';
    const personId = btn.dataset.personId ? Number(btn.dataset.personId) : null;
    const row = mine.rows.find(r => r.personId === personId);
    const clearing = row && row.response === response;
    const payload = { fh_event_id: ev.fh_event_id };
    if (!clearing) payload.response = response;
    if (personId) payload.person_id = personId;
    btn.disabled = true;
    try {
      const res = await this.auth.fetch('/api/calendar/rsvp', {
        method: clearing ? 'DELETE' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
      const final = clearing ? null : ((data.rsvp && data.rsvp.response) || response);
      if (!personId) ev.my_rsvp = final;
      const rsvpPersonId = personId || (data.rsvp && data.rsvp.person_id) || data.person_id;
      if (rsvpPersonId) {
        const rsvps = Array.isArray(ev.rsvps) ? ev.rsvps : (ev.rsvps = []);
        const existing = rsvps.find(r => r && r.person_id === rsvpPersonId);
        if (existing) existing.response = final;
        else if (final) rsvps.push({ person_id: rsvpPersonId, response: final, created_via: 'manual' });
      }
      // Not Going from standby took the player off the alternates (the
      // save did it): drop the card here too and say so, in the DB's words.
      const dropped = data.standby_dropped;
      if (dropped && dropped.player_id) {
        this.zones.delete(Number(dropped.player_id));
        this._render();
        const note = this.element.querySelector('[data-gc-avail-msg]');
        if (note && dropped.message) note.textContent = dropped.message;
      } else {
        this._paintMyAvailability();
      }
    } catch (err) {
      btn.disabled = false;
      const msg = this.element.querySelector('[data-gc-avail-msg]');
      if (msg) msg.innerHTML = `<span style="color:#f87171;">Could not save: ${this.escapeHtml(err.message)}</span>`;
    }
  }

  // The details roster (coach-only) is what knows a card's person.
  _personIdFor(playerId) {
    const row = (this.players || []).find(x => Number(x.playerId) === Number(playerId));
    return row && row.personId ? Number(row.personId) : null;
  }

  // { person_id: { sms: {sent_at, count}, email: {…} } } for this game.
  async _loadReminders() {
    try {
      const res = await this.auth.fetch(`/api/rsvp-board/reminders?match_id=${this.matchId}`);
      const data = await res.json();
      this.reminders = (res.ok && data.reminders) || {};
    } catch (err) {
      this.reminders = {};
    }
  }

  // { squad, untold, sms: {sent_at}, email: {sent_at} } for this game.
  async _loadSquadNotice() {
    try {
      const res = await this.auth.fetch(`/api/rsvp-board/squad-notice?match_id=${this.matchId}`);
      const data = await res.json();
      this.squadNotice = (res.ok && data.status) || null;
    } catch (err) {
      this.squadNotice = null;
    }
  }

  _sentWhen(iso) {
    return new Date(iso).toLocaleString('en-US', { weekday: 'short', hour: 'numeric', minute: '2-digit' });
  }

  _sentTitle(sent) {
    return `Reminded this week — last ${this._sentWhen(sent.sent_at)}` + (sent.count > 1 ? ` (${sent.count} times)` : '');
  }

  // A reminder lists the player's whole week, so either channel — from
  // this game, another game or #rsvps — dims both buttons.  The tally is
  // the week's sends on both channels.
  _weekSent(sent) {
    const each = ['sms', 'email'].map(c => sent[c]).filter(Boolean);
    if (!each.length) return null;
    return { count: each.reduce((n, x) => n + (x.count || 1), 0),
             sent_at: each.map(x => x.sent_at).sort().pop() };
  }

  // "text Sat 10:07 AM ×2 · email Fri 6:30 PM"
  _sentNote(sent) {
    return ['sms', 'email'].filter(c => sent[c]).map(c =>
      `${c === 'sms' ? 'text' : 'email'} ${this._sentWhen(sent[c].sent_at)}${sent[c].count > 1 ? ' ×' + sent[c].count : ''}`).join(' · ')
      + (sent.total ? ` · ${sent.total} all-time` : '');
  }

  // Dim the buttons of whoever a fresh send reached, without a re-render
  // (that would roll the No Response section up).
  _paintSent() {
    this.element.querySelectorAll('[data-gc-remind]').forEach(btn => {
      const sent = (this.reminders || {})[btn.dataset.personId] || {};
      const mine = this._weekSent(sent);
      if (!mine) return;
      btn.style.opacity = '0.4';
      btn.title = this._sentTitle(mine) + ' — click to send again';
      btn.textContent = `${btn.dataset.gcRemind === 'sms' ? '💬' : '✉'} REMIND ✓ ×${mine.count}`;
      const note = btn.parentElement.querySelector('[data-gc-remind-note]');
      if (note) note.textContent = this._sentNote(sent);
    });
  }

  async _postReminder(path, payload) {
    const headers = { 'Content-Type': 'application/json' };
    if (this.auth && this.auth.token) headers['Authorization'] = `Bearer ${this.auth.token}`;
    const res = await fetch(path, { method: 'POST', headers, credentials: 'same-origin', body: JSON.stringify(payload) });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
    return data;
  }

  // Card button — the same personal reminder #rsvps sends.  The DOM is
  // patched in place: a re-render would roll the No Response section up.
  async _remindPlayer(btn) {
    const channel = btn.dataset.gcRemind === 'email' ? 'email' : 'sms';
    const note = btn.parentElement.querySelector('[data-gc-remind-note]');
    const original = btn.textContent;
    btn.disabled = true;
    btn.textContent = '⏳';
    try {
      const data = await this._postReminder('/api/rsvp-board/remind', { person_id: Number(btn.dataset.personId), channel });
      if (channel === 'email') this.openGmailCompose(data.gmail_href);
      else window.location.href = data.sms_href;
      btn.textContent = original;
      await this._loadReminders();
      this._paintSent();
    } catch (err) {
      btn.textContent = original;
      if (note) note.innerHTML = `<span style="color:#f87171;">${this.escapeHtml(err.message)}</span>`;
    }
    btn.disabled = false;
  }

  // Bar button — one group message.  Carriers cap group MMS around 10
  // people (see my.js Text All), so a bigger group becomes several links.
  async _remindNoResponse(btn) {
    const channel = btn.dataset.gcRemindAll === 'email' ? 'email' : 'sms';
    const slot = btn.parentElement.querySelector('[data-gc-remind-result]');
    const original = btn.textContent;
    btn.disabled = true;
    btn.textContent = '⏳';
    try {
      const data = await this._postReminder('/api/rsvp-board/remind-event',
        { match_id: Number(this.matchId), scope: 'week', channel });
      const contacts = data.contacts || [];
      const skipped = data.no_contact
        ? ` · ${data.no_contact} skipped (no ${channel === 'sms' ? 'mobile' : 'email'} on file)` : '';
      let html;
      if (channel === 'email') {
        this.openGmailCompose(this.buildGmailComposeHref({ bcc: contacts.join(','), subject: data.subject, body: data.body }));
        html = `✉ Email drafted to ${contacts.length} (BCC)${skipped}`;
      } else {
        const CHUNK_SIZE = 10;
        const chunks = [];
        for (let i = 0; i < contacts.length; i += CHUNK_SIZE) chunks.push(contacts.slice(i, i + CHUNK_SIZE));
        const hrefs = chunks.map(c => this.buildSmsComposeHref({ to: c.join(','), body: data.body }));
        html = chunks.length === 1
          ? `💬 Group text drafted to ${contacts.length}${skipped}`
          : `Carriers cap a group text around ${CHUNK_SIZE} people — open each part: ` +
            hrefs.map((h, i) => `<a href="${this.escapeHtml(h)}" style="display:inline-block; padding:3px 9px; border-radius:6px; text-decoration:none; font-weight:800; font-size:0.68rem; color:#fff; background:#0284c7;">💬 Part ${i + 1}/${chunks.length} (${chunks[i].length})</a>`).join(' ') + skipped;
        if (chunks.length === 1) window.location.href = hrefs[0];
      }
      if (slot) slot.innerHTML = html;
      await this._loadReminders();
      this._paintSent();
    } catch (err) {
      if (slot) slot.innerHTML = `<span style="color:#f87171;">${this.escapeHtml(err.message)}</span>`;
    }
    btn.textContent = original;
    btn.disabled = false;
  }

  // Squad bar button — one group message, same drafting as
  // _remindNoResponse (carriers cap a group text around 10 people).
  async _sendSquadNotice(btn) {
    const channel = btn.dataset.gcSquadNotice === 'email' ? 'email' : 'sms';
    const slot = btn.parentElement.querySelector('[data-gc-squad-result]');
    const original = btn.textContent;
    btn.disabled = true;
    btn.textContent = '⏳';
    try {
      // A role changed seconds ago must be in the DB before the send reads it.
      if (this._saveTimer) { clearTimeout(this._saveTimer); this._saveTimer = null; await this._saveLineup(); }
      const data = await this._postReminder('/api/rsvp-board/squad-notice',
        { match_id: Number(this.matchId), channel, scope: btn.dataset.scope === 'changed' ? 'changed' : 'all' });
      const contacts = data.contacts || [];
      const skipped = data.no_contact
        ? ` · ${data.no_contact} skipped (no ${channel === 'sms' ? 'mobile' : 'email'} on file)` : '';
      let html;
      if (channel === 'email') {
        this.openGmailCompose(this.buildGmailComposeHref({ bcc: contacts.join(','), subject: data.subject, body: data.body }));
        html = `✉ Email drafted to ${contacts.length} (BCC)${skipped}`;
      } else {
        const CHUNK_SIZE = 10;
        const chunks = [];
        for (let i = 0; i < contacts.length; i += CHUNK_SIZE) chunks.push(contacts.slice(i, i + CHUNK_SIZE));
        const hrefs = chunks.map(c => this.buildSmsComposeHref({ to: c.join(','), body: data.body }));
        html = chunks.length === 1
          ? `💬 Group text drafted to ${contacts.length}${skipped}`
          : `Carriers cap a group text around ${CHUNK_SIZE} people — open each part: ` +
            hrefs.map((h, i) => `<a href="${this.escapeHtml(h)}" style="display:inline-block; padding:3px 9px; border-radius:6px; text-decoration:none; font-weight:800; font-size:0.68rem; color:#fff; background:#0284c7;">💬 Part ${i + 1}/${chunks.length} (${chunks[i].length})</a>`).join(' ') + skipped;
        if (chunks.length === 1) window.location.href = hrefs[0];
      }
      this.squadNotice = data.status || this.squadNotice;
      // Re-render so every card and the bar dim together; the result
      // line (the Part 1/2 links) goes back in afterwards.
      this._render();
      const fresh = this.element.querySelector('[data-gc-squad-result]');
      if (fresh) fresh.innerHTML = html;
      return;
    } catch (err) {
      if (slot) slot.innerHTML = `<span style="color:#f87171;">${this.escapeHtml(err.message)}</span>`;
    }
    btn.textContent = original;
    btn.disabled = false;
  }

  // Card button — one player's own game reminder.
  async _sendSquadNoticeOne(btn) {
    const channel = btn.dataset.gcSquadOne === 'email' ? 'email' : 'sms';
    const note = btn.parentElement.querySelector('[data-gc-squad-note]');
    const original = btn.textContent;
    btn.disabled = true;
    btn.textContent = '⏳';
    try {
      if (this._saveTimer) { clearTimeout(this._saveTimer); this._saveTimer = null; await this._saveLineup(); }
      const data = await this._postReminder('/api/rsvp-board/squad-notice',
        { match_id: Number(this.matchId), person_id: Number(btn.dataset.personId), channel });
      if (channel === 'email') this.openGmailCompose(data.gmail_href);
      else window.location.href = data.sms_href;
      this.squadNotice = data.status || this.squadNotice;
      this._render();
      return;
    } catch (err) {
      if (note) note.innerHTML = `<span style="color:#f87171;">${this.escapeHtml(err.message)}</span>`;
    }
    btn.textContent = original;
    btn.disabled = false;
  }

  // ---- RSVP & Player Details overlay (moved from #game-day-roster) ----
  //
  // The one thing that screen owned outright: per-player jersey numbers,
  // a match RSVP the coach can override, tri-state practice attendance,
  // and which official rosters each player sits on. It hangs off the
  // 20-Man Squad pill because that's the question it answers — who is
  // actually available for this game.
  //
  // "On lineup" here stays READ-ONLY (a ✓, not a checkbox). Who's on the
  // game-day roster is decided by the starter/bench zones on the
  // Starters & Bench pill — owner, 2026-08-22: "it does not need set
  // lineup for 20 man and starters and bench. just one unified set
  // lineup then you glean the post from that... the 20 man is a view."
  // The old screen's own zone-less checkbox is exactly what used to put
  // stray players on the post.

  _openDetails() {
    this.overlayOpen = true;
    const overlay = this.find('#gc-details-overlay');
    if (!overlay) return;
    overlay.style.display = 'flex';
    this._renderDetailsList();
    setTimeout(() => this.find('#gc-player-search')?.focus(), 100);
  }

  _closeDetails() {
    this.overlayOpen = false;
    const overlay = this.find('#gc-details-overlay');
    if (overlay) overlay.style.display = 'none';
    // An RSVP flipped in here changes who's in Going / Not Going /
    // No Response upstairs, so the body has to catch up on close.
    this._render();
  }

  // Which player ids are on the game-day roster, from THIS screen's
  // zones rather than the old screen's separate onGameRoster flag.
  _lineupPlayerIds() {
    const ids = new Set();
    for (const [playerId, zone] of this.zones.entries()) {
      if (zone === 'starter' || zone === 'bench') ids.add(String(playerId));
    }
    return ids;
  }

  _getFilteredPlayers() {
    return this.players.filter(p => {
      if (this.filterText) {
        const name = `${p.firstName} ${p.lastName}`.toLowerCase();
        if (!name.includes(this.filterText)) return false;
      }
      if (this.filterRsvp !== 'all') {
        if (this.filterRsvp === 'none') {
          if (p.rsvpStatus) return false;
        } else if (p.rsvpStatus !== this.filterRsvp) {
          return false;
        }
      }
      if (this.listFilter !== 'all') {
        // These three roster flags are named columns on the
        // roster-players response (EventController.cpp), not something
        // derivable from rosterTeamIds — generalising them is a backend
        // change, so the filter stays keyed to them for now.
        const map = { roster_lighthouse: 'onRosterLighthouse', roster_casa: 'onRosterCasa', roster_u23: 'onRosterU23' };
        const key = map[this.listFilter];
        if (key && !p[key]) return false;
      }
      return true;
    });
  }

  _renderDetailsList() {
    const container = this.find('#gc-details-list');
    if (!container) return;

    if (!this.players.length) {
      container.innerHTML = '<div class="gdr-empty">No player details available for this match.</div>';
      return;
    }

    const filtered = this._getFilteredPlayers();
    if (filtered.length === 0) {
      container.innerHTML = '<div class="gdr-empty">No players match filters</div>';
      return;
    }

    const practiceHeaders = (this.trainingEvents || []).map(te => {
      const d = new Date(te.date + 'T12:00:00');
      const day = d.toLocaleDateString('en-US', { weekday: 'short' });
      const dateStr = d.toLocaleDateString('en-US', { month: 'numeric', day: 'numeric' });
      return `<th class="gdr-th-practice" title="${this.escapeHtml(te.title || '')} - ${day} ${dateStr}">${day}<br><span class="gdr-th-date">${dateStr}</span></th>`;
    }).join('');

    const lineupIds = this._lineupPlayerIds();
    container.innerHTML = `
      <table class="gdr-overlay-table">
        <thead>
          <tr>
            <th class="gdr-th-cb" title="On the game-day roster (starter or bench) — set on the Starters &amp; Bench pill">Lineup</th>
            <th>Player</th>
            <th>#</th>
            <th>Pos</th>
            <th>RSVP</th>
            <th>GK</th>
            <th>Fam</th>
            <th class="gdr-section-divider" colspan="${(this.trainingEvents || []).length || 1}">Practice</th>
            <th class="gdr-section-divider" colspan="3">Roster</th>
          </tr>
          <tr class="gdr-subheader">
            <th></th><th></th><th></th><th></th><th></th><th></th><th></th>
            ${practiceHeaders}
            <th class="gdr-th-roster" title="APSL Lighthouse 1893 SC">APSL</th>
            <th class="gdr-th-roster" title="Lighthouse Boys Club">Casa</th>
            <th class="gdr-th-roster" title="Lighthouse Boys Club U23">U23</th>
          </tr>
        </thead>
        <tbody>
          ${filtered.map(p => this._renderDetailsRow(p, lineupIds)).join('')}
        </tbody>
      </table>`;
  }

  _renderDetailsRow(p, lineupIds) {
    const selected = lineupIds.has(String(p.playerId));
    const rsvpValue = p.rsvpStatus || '';
    const practice = p.practice || [];

    const practiceCells = (this.trainingEvents || []).map((te, i) => {
      const entry = practice[i];
      const v = entry ? (typeof entry === 'object' ? entry.v : entry) : null;
      const isOverride = entry && typeof entry === 'object' ? entry.o : false;
      const cls = v === 'yes' ? 'gdr-prac-yes' : v === 'no' ? 'gdr-prac-no' : 'gdr-prac-none';
      const sym = v === 'yes' ? '&check;' : v === 'no' ? '&cross;' : '&mdash;';
      return `<td class="gdr-cell-center gdr-prac-cell ${cls}${isOverride ? ' gdr-prac-override' : ''}"
                  data-person-id="${p.personId}" data-event-id="${te.id}" data-event-idx="${i}"
                  data-current="${v || ''}" title="${isOverride ? 'Admin override' : 'Synced'}">${sym}</td>`;
    }).join('');

    const rosterCell = (val) => val ? '<td class="gdr-cell-center gdr-in">&check;</td>' : '<td class="gdr-cell-center gdr-out"></td>';

    return `
      <tr class="gdr-overlay-row ${selected ? 'gdr-row-selected' : ''}" data-player-id="${p.playerId}">
        <td class="gdr-cell-center" title="Set on the Starters &amp; Bench pill">${selected ? '&check;' : ''}</td>
        <td class="gdr-cell-name"><strong>${this.escapeHtml(p.firstName)} ${this.escapeHtml(p.lastName)}</strong></td>
        <td class="gdr-cell-jersey">
          <input type="text" class="gdr-jersey-input" data-player-id="${p.playerId}" value="${this.escapeHtml(String(p.jerseyNumber || ''))}" maxlength="4" placeholder="#">
        </td>
        <td>${this.escapeHtml(p.position || '—')}</td>
        <td class="gdr-rsvp-cell">
          <div class="gdr-rsvp-group">
            <button class="gdr-rsvp-btn ${rsvpValue === 'yes' ? 'gdr-rsvp-active-yes' : ''}" data-player-id="${p.playerId}" data-rsvp="yes" title="Going">Y</button>
            <button class="gdr-rsvp-btn ${rsvpValue === 'no' ? 'gdr-rsvp-active-no' : ''}" data-player-id="${p.playerId}" data-rsvp="no" title="Not going">N</button>
          </div>
          ${p.rsvpSource === 'admin' ? '<span class="gdr-rsvp-src gdr-src-admin" title="Admin override">✎</span>' : ''}
        </td>
        <td class="gdr-cell-center">${p.isKeeper ? '🧤' : ''}</td>
        <td class="gdr-cell-center">${p.hasFamilyDiscount ? '👪' : ''}</td>
        ${practiceCells}
        ${rosterCell(p.onRosterLighthouse)}
        ${rosterCell(p.onRosterCasa)}
        ${rosterCell(p.onRosterU23)}
      </tr>`;
  }

  // A match RSVP the coach sets on a player's behalf. Also written into
  // this.stats so the Going / Not Going / No Response buckets and the
  // RSVP pills on the Starters & Bench pill agree with the overlay
  // without waiting for a reload — those read this.stats, the overlay
  // reads this.players, and both describe the same fact.
  async _setPlayerRSVP(playerId, newStatus) {
    if (!this.matchId) return;
    const player = this.players.find(p => String(p.playerId) === String(playerId));
    let effective = newStatus;
    if (player) {
      // Tapping the active button again clears the override.
      if (player.rsvpStatus === newStatus) effective = null;
      player.rsvpStatus = effective;
      player.rsvpSource = effective ? 'admin' : null;
    }
    const stat = this.stats.get(Number(playerId));
    if (stat) stat.gameRsvp = effective;

    try {
      await this.auth.fetch(`/api/matches/${this.matchId}/player-rsvp`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ player_id: String(playerId), rsvp_status: effective }),
      });
    } catch (err) {
      console.error('[game-center] failed to save RSVP:', err);
    }
  }

  async _setPracticeRSVP(personId, chatEventId, eventIdx, newStatus) {
    const player = this.players.find(p => String(p.personId) === String(personId));
    if (player && player.practice) {
      player.practice[eventIdx] = newStatus ? { v: newStatus, o: true } : null;
    }
    try {
      const body = newStatus
        ? { person_id: String(personId), rsvp_status: newStatus }
        : { person_id: String(personId), clear: 'true' };
      await this.auth.fetch(`/api/events/chat-events/${chatEventId}/person-rsvp`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });
    } catch (err) {
      console.error('[game-center] failed to save practice RSVP:', err);
    }
  }

  // Dropping an admin override reveals whatever the synced value under
  // it was, which only the server knows — hence the re-render off the
  // response rather than an optimistic guess.
  async _releasePracticeRSVP(personId, chatEventId, eventIdx) {
    const player = this.players.find(p => String(p.personId) === String(personId));
    if (player && player.practice) player.practice[eventIdx] = null;
    try {
      const resp = await this.auth.fetch(`/api/events/chat-events/${chatEventId}/person-rsvp`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ person_id: String(personId), clear: 'true' }),
      });
      const data = await resp.json();
      if (player && player.practice && data.rsvpStatus) {
        player.practice[eventIdx] = { v: data.rsvpStatus, o: false };
      }
      this._renderDetailsList();
    } catch (err) {
      console.error('[game-center] failed to release practice RSVP:', err);
    }
  }

  async _saveJerseyNumber(playerId, number) {
    const player = this.players.find(p => String(p.playerId) === String(playerId));
    // this.roster is what the post's player rows are built from
    // (_buildRosterData), so a jersey edited here has to land there too
    // or the graphic keeps printing the old number until a reload.
    const rosterRow = this.roster.find(r => String(r.id) === String(playerId));
    if (rosterRow) rosterRow.jerseyNumber = number || null;
    if (!player || !player.rosterTeamId) return;
    try {
      await this.auth.fetch(`/api/teams/${player.rosterTeamId}/roster/${playerId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ jerseyNumber: number ? parseInt(number, 10) : null }),
      });
    } catch (err) {
      console.error('[game-center] failed to save jersey number:', err);
    }
  }

  // Date/time line for the frame. `when` arrives from the My page card
  // (gcal-derived, already formatted) when we got here from there; any
  // other entry point (team dashboard, a saved #game-center link) leaves
  // it empty, so fall back to the same gcal start the trailing "game"
  // practice pill uses, then to the matches row's own date for an
  // unlinked game. Cleared after a details save so the new date shows.
  _whenLabel() {
    if (this.when) return this.when;
    const m = this.matchDetails;
    let d = null;
    if (m && m.gcal_linked && this.matchStartsAt) {
      // EligibilityController renders gcal_events.starts_at through a
      // UTC session with no offset marker ("2026-09-13T16:00:00" for a
      // noon ET kickoff) — parse it as UTC so the local time is right.
      const raw = String(this.matchStartsAt);
      d = new Date(/Z$|[+-]\d\d:?\d\d$/.test(raw) ? raw : raw + 'Z');
    } else if (m && m.event_date) {
      d = new Date(String(m.event_date).replace(' ', 'T')); // naive local date+time on the matches row
    }
    if (!d || isNaN(d.getTime())) return '';
    const date = d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
    const hasTime = !(m && !m.gcal_linked && !m.match_time);
    const time = hasTime ? d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' }) : '';
    return [date, time].filter(Boolean).join(' · ');
  }

  // Which side of the fixture is us — the pill labels and the details
  // panel read "Opponent" from the other side.
  _isHomeSide() {
    const m = this.matchDetails;
    return !!(m && this.teamId != null && String(m.home_team_id) === String(this.teamId));
  }

  // Coach-only panel under the Game Announcement frame (slice C).
  //
  // Two shapes, decided by the match's ownership:
  //  - gcal_linked (every real fixture): opponent, kick-off, venue and
  //    league are read-only with a pointer to the club Google Calendar.
  //    Writing them into `matches` would be a dead edit — the My page
  //    and the RSVP flow read fh_events/gcal_events, so players would
  //    keep seeing the calendar's values while this page drifted.
  //  - unlinked (ad-hoc lineup games, scrimmages): the fields
  //    #match-form used to own — home/away, opponent team, date, time,
  //    venue — edited in place via PUT /api/matches/:matchId.
  _renderGameDetailsPanel() {
    const m = this.matchDetails;
    if (!this.isCoach || !m) return '';
    const isHome = this._isHomeSide();
    const opponent = isHome ? (m.away_team_name || '') : (m.home_team_name || '');
    const venue = m.venue_location || m.venue_name || '';
    const row = (label, value) => `
      <div style="display:flex; justify-content:space-between; gap:12px; padding:5px 0; border-bottom:1px solid var(--border-color); font-size:0.78rem;">
        <span style="opacity:0.7; flex:0 0 auto;">${label}</span>
        <span style="text-align:right; overflow-wrap:anywhere;">${value ? this.escapeHtml(value) : '<span style="opacity:0.5;">—</span>'}</span>
      </div>`;
    const listHtml = `
      ${row('Opponent', opponent)}
      ${row('Home / Away', m.home_team_id ? (isHome ? 'Home' : 'Away') : '')}
      ${row('Kick-off', this._whenLabel())}
      ${row('Venue', venue)}
      ${row('League', m.league_tag || m.competition_name || '')}`;

    const wrap = (inner) => `
      <div style="margin-top:10px; border:1px solid var(--border-color); border-radius:12px; padding:10px 12px;">
        <div style="font-size:0.72rem; font-weight:700; opacity:0.8; margin-bottom:4px;">⚽ Game details</div>
        ${inner}
      </div>`;

    if (m.gcal_linked) {
      return wrap(`
        ${listHtml}
        <div style="font-size:0.7rem; opacity:0.75; margin-top:8px; line-height:1.4;">
          📅 These come from the club schedule — change them there.
        </div>`);
    }

    if (!this.announceEditing) {
      return wrap(`
        ${listHtml}
        <div style="display:flex; justify-content:flex-end; margin-top:8px;">
          <button type="button" id="gc-announce-edit" class="btn btn-secondary" style="font-size:0.75rem; padding:4px 10px;">✏️ Edit details</button>
        </div>
        ${this._detailsMsg ? `<div style="font-size:0.7rem; margin-top:6px; opacity:0.8;">${this.escapeHtml(this._detailsMsg)}</div>` : ''}`);
    }

    // Edit form — the same fields #match-form carried, minus the ones
    // that aren't about the fixture (title, competition, status, notes).
    const opponentId = isHome ? m.away_team_id : m.home_team_id;
    const teamOpts = (this.teamList || [])
      .filter(t => String(t.id) !== String(this.teamId))
      .map(t => `<option value="${t.id}" ${String(t.id) === String(opponentId) ? 'selected' : ''}>${this.escapeHtml(t.name || '')}</option>`)
      .join('');
    const venueOpts = (this.venueList || [])
      .map(v => `<option value="${v.id}" ${String(v.id) === String(m.venue_id) ? 'selected' : ''}>${this.escapeHtml(`${v.name || ''}${v.city ? ' - ' + v.city : ''}`)}</option>`)
      .join('');
    const loading = (!this.teamList || !this.venueList) ? '<span style="font-size:0.68rem; opacity:0.6;">loading lists…</span>' : '';
    const timeVal = m.match_time ? String(m.match_time).slice(0, 5) : '';
    const field = (label, inner) => `
      <label style="display:flex; flex-direction:column; gap:3px; font-size:0.7rem; opacity:0.9;">
        <span style="opacity:0.75;">${label}</span>${inner}
      </label>`;
    return wrap(`
      <div style="display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-top:6px;">
        ${field('Home / Away', `
          <select id="gc-ann-home-away" class="form-input" style="font-size:0.8rem; padding:6px 8px;">
            <option value="home" ${isHome || !m.home_team_id ? 'selected' : ''}>Home</option>
            <option value="away" ${!isHome && m.home_team_id ? 'selected' : ''}>Away</option>
          </select>`)}
        ${field('Opponent', `
          <select id="gc-ann-opponent" class="form-input" style="font-size:0.8rem; padding:6px 8px;">
            <option value="">${opponent ? this.escapeHtml(opponent) + ' (unchanged)' : 'Select opponent…'}</option>${teamOpts}
          </select>`)}
        ${field('Date', `<input type="date" id="gc-ann-date" class="form-input" style="font-size:0.8rem; padding:6px 8px;" value="${this.escapeHtml(m.match_date || '')}">`)}
        ${field('Kick-off', `<input type="time" id="gc-ann-time" class="form-input" style="font-size:0.8rem; padding:6px 8px;" value="${this.escapeHtml(timeVal)}">`)}
      </div>
      <div style="margin-top:8px;">
        ${field('Venue', `
          <select id="gc-ann-venue" class="form-input" style="font-size:0.8rem; padding:6px 8px;">
            <option value="">${venue ? this.escapeHtml(venue) + ' (unchanged)' : 'Select a venue…'}</option>${venueOpts}
          </select>`)}
      </div>
      <div style="display:flex; justify-content:space-between; align-items:center; gap:8px; margin-top:10px;">
        ${loading}
        <div style="display:flex; gap:8px; margin-left:auto;">
          <button type="button" id="gc-announce-edit" class="btn btn-secondary" style="font-size:0.75rem; padding:4px 10px;">Cancel</button>
          <button type="button" id="gc-announce-save" class="btn btn-primary" style="font-size:0.75rem; padding:4px 10px;" ${this._matchSaving ? 'disabled' : ''}>Save details</button>
        </div>
      </div>
      ${this._detailsMsg ? `<div style="font-size:0.7rem; margin-top:6px; opacity:0.8;">${this.escapeHtml(this._detailsMsg)}</div>` : ''}`);
  }

  // Team + venue dropdown sources for the edit form, fetched once per
  // visit and only when the form actually opens — no coach pays for two
  // list fetches just to look at the announcement.
  async _ensureDetailOptions() {
    if (this.teamList && this.venueList) return;
    try {
      const [tRes, vRes] = await Promise.all([
        this.auth.fetch('/api/teams'),
        this.auth.fetch('/api/venues'),
      ]);
      const tData = await tRes.json().catch(() => null);
      const vData = await vRes.json().catch(() => null);
      this.teamList  = (tData && Array.isArray(tData.data)) ? tData.data : [];
      this.venueList = (vData && Array.isArray(vData.data)) ? vData.data : [];
    } catch (err) {
      console.error('[game-center] failed to load team/venue lists:', err);
      this.teamList = this.teamList || [];
      this.venueList = this.venueList || [];
      this._detailsMsg = 'Could not load team and venue lists.';
    }
    if (this.announceEditing && this.pill === 'game_day') this._render();
  }

  async _saveGameDetails() {
    if (this._matchSaving) return;
    const homeAway = this.find('#gc-ann-home-away')?.value || 'home';
    const opponentId = this.find('#gc-ann-opponent')?.value || '';
    const date = this.find('#gc-ann-date')?.value || '';
    const time = this.find('#gc-ann-time')?.value || '';
    const venueId = this.find('#gc-ann-venue')?.value || '';
    const body = {};
    if (date) body.date = date;
    if (time) body.start_time = time;
    if (venueId) body.venue_id = Number(venueId);
    // Team ids only move together, and only when an opponent was chosen —
    // the backend skips absent keys, so an untouched dropdown changes nothing.
    if (opponentId && this.teamId != null) {
      body.home_team_id = homeAway === 'home' ? Number(this.teamId) : Number(opponentId);
      body.away_team_id = homeAway === 'home' ? Number(opponentId) : Number(this.teamId);
    }
    if (!Object.keys(body).length) { this._detailsMsg = 'Nothing to save.'; this._render(); return; }
    const ok = await this._putMatch(body, 'details');
    if (ok) {
      this.announceEditing = false;
      this.when = ''; // re-derive the frame's date line from the saved row
      this._detailsMsg = 'Details saved.';
    }
    this._render();
  }

  // Coach-only score entry under the Match Result frame (slice C). Save
  // writes both scores and flips match_status to completed; Clear sends
  // explicit nulls (the backend treats an absent key as "leave alone")
  // and puts the match back to scheduled.
  _renderScorePanel() {
    const m = this.matchDetails;
    if (!this.isCoach || !m) return '';
    const hs = m.home_team_score ?? m.home_score;
    const as = m.away_team_score ?? m.away_score;
    const hasScore = hs != null && as != null;
    const scoreInput = (id, label, val) => `
      <label style="display:flex; flex-direction:column; gap:3px; font-size:0.7rem; min-width:0;">
        <span style="opacity:0.75; text-transform:uppercase; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${this.escapeHtml(label)}</span>
        <input type="number" inputmode="numeric" min="0" max="999" id="${id}" class="form-input"
               style="font-size:1.2rem; font-weight:700; text-align:center; padding:6px;"
               value="${val != null ? this.escapeHtml(String(val)) : ''}" ${this._matchSaving ? 'disabled' : ''}>
      </label>`;
    return `
      <div style="margin-top:10px; border:1px solid var(--border-color); border-radius:12px; padding:10px 12px;">
        <div style="font-size:0.72rem; font-weight:700; opacity:0.8; margin-bottom:6px;">🏆 ${hasScore ? 'Result' : 'Record the result'}</div>
        <div style="display:grid; grid-template-columns:1fr auto 1fr; gap:10px; align-items:end;">
          ${scoreInput('gc-score-home', m.home_team_name || 'Home', hs)}
          <span style="font-size:1.2rem; font-weight:700; opacity:0.6; padding-bottom:8px;">–</span>
          ${scoreInput('gc-score-away', m.away_team_name || 'Away', as)}
        </div>
        <div style="display:flex; justify-content:flex-end; gap:8px; margin-top:10px;">
          ${hasScore ? `<button type="button" id="gc-score-clear" class="btn btn-secondary" style="font-size:0.75rem; padding:4px 10px;" ${this._matchSaving ? 'disabled' : ''}>Clear</button>` : ''}
          <button type="button" id="gc-score-save" class="btn btn-primary" style="font-size:0.75rem; padding:4px 10px;" ${this._matchSaving ? 'disabled' : ''}>${hasScore ? 'Update result' : 'Save result'}</button>
        </div>
        ${this._scoreMsg ? `<div style="font-size:0.7rem; margin-top:6px; opacity:0.8;">${this.escapeHtml(this._scoreMsg)}</div>` : ''}
      </div>`;
  }

  async _saveScore(clear) {
    if (this._matchSaving) return;
    let body;
    if (clear) {
      body = { home_team_score: null, away_team_score: null, match_status: 'scheduled' };
    } else {
      const h = (this.find('#gc-score-home')?.value || '').trim();
      const a = (this.find('#gc-score-away')?.value || '').trim();
      if (!/^\d{1,3}$/.test(h) || !/^\d{1,3}$/.test(a)) {
        this._scoreMsg = 'Enter both scores as whole numbers.';
        this._render();
        return;
      }
      body = { home_team_score: Number(h), away_team_score: Number(a), match_status: 'completed' };
    }
    const ok = await this._putMatch(body, 'score');
    if (ok) this._scoreMsg = clear ? 'Score cleared.' : 'Result saved.';
    this._render();
  }

  // One PUT /api/matches/:matchId, then a re-read of the same GET the
  // bootstrap uses so matchDetails (header, result summary, Instagram
  // card) reflects the row as saved rather than what we think we sent.
  // Returns true on success; the message slot named by `which` gets the
  // failure text otherwise.
  async _putMatch(body, which) {
    if (!this.matchId) return false;
    this._matchSaving = true;
    this._render();
    let ok = false;
    try {
      const res = await this.auth.fetch(`/api/matches/${this.matchId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });
      const data = await res.json().catch(() => null);
      if (!res.ok || !data || !data.success) {
        throw new Error((data && data.message) || `Save failed (${res.status})`);
      }
      const fresh = await this.auth.fetch(`/api/matches/${this.matchId}`);
      const freshData = await fresh.json().catch(() => null);
      if (freshData && freshData.success) {
        this.matchDetails = freshData.data;
        // The post_game Instagram card builds its preview graphic from this
        // same object inside its render() — hand it the fresh row and
        // repaint, so the "? - ?" placeholder becomes the scoreline without
        // a remount (which would drop a caption mid-draft).
        if (this.socialCard) {
          this.socialCard.matchContext = this.matchDetails || {};
          try { this.socialCard.render(); } catch (err) { console.warn('[game-center] social card repaint failed:', err); }
        }
      }
      ok = true;
    } catch (err) {
      console.error('[game-center] match save failed:', err);
      if (which === 'score') this._scoreMsg = err.message || 'Could not save the result.';
      else this._detailsMsg = err.message || 'Could not save the details.';
    } finally {
      this._matchSaving = false;
    }
    return ok;
  }

  // Owns #gc-social — the publish panel under the card: the active
  // pill's SocialPostCard with its caption, media, schedule and "Post
  // live — <post>" button. Only for the roles that may publish, and only
  // while the Post button has it open, which is also what defers that
  // component's four API calls until they're wanted.
  //
  // The `_socialMountedFor` guard is what makes this safe to call from
  // every _render(): a coach toggling players must not lose the caption
  // they're drafting. While the post is unchanged we keep the live card
  // and just hand it fresh rosterData, so the next Regenerate draws the
  // lineup as it stands now.
  _renderSocial(byZone) {
    const host = this.find('#gc-social');
    if (!host) return;

    const open = this._bottomOpen && this._canPostSocial() && this.matchId && this.teamId;
    const key = open ? this.pill : 'none';
    if (key === this._socialMountedFor) {
      if (this.socialCard) this.socialCard.rosterData = this._buildRosterData(byZone);
      return;
    }
    this._socialMountedFor = key;
    this.socialCard = null;
    host.innerHTML = open ? '<div id="gc-social-mount" style="max-width:540px; margin:0 auto 12px;"></div>' : '';
    if (!open) return;

    const card = new SocialPostCard(this.auth);
    // The card re-renders after every save, schedule and publish, so its
    // own post row is the freshest status there is for that pill.
    card.onPostState = (type, post) => {
      this.postStates[type] = post ? { status: post.status, scheduled_at: post.scheduled_at } : null;
      this._paintSocialPills();
    };
    card.init(this.find('#gc-social-mount'), this.matchId, this.teamId, this.pill, this.matchDetails || {}, this._buildRosterData(byZone));
    this.socialCard = card;
  }

  // The coach tools behind each post. Each renderer gates itself on
  // isCoach, so a player gets nothing here.
  _pillToolsHtml(pill, byZone) {
    let html = '';
    if (pill === 'game_day') html = this._renderGameDetailsPanel();
    else if (pill === 'post_game') html = this._renderScorePanel();
    else if (pill === 'lineup' && this.isCoach) {
      const squadCount = byZone.starter.length + byZone.bench.length;
      html = `
        <div style="display:flex; justify-content:space-between; align-items:center; gap:8px; flex-wrap:wrap;">
          <span style="font-size:0.72rem; opacity:0.75;">${squadCount} on the game-day roster</span>
          <button type="button" id="gc-details-open" class="btn btn-primary"
                  style="font-size:0.75rem; padding:4px 10px;">👥 RSVP &amp; Player Details</button>
        </div>`;
    }
    return html ? `<div style="max-width:540px; margin:10px auto 0;">${html}</div>` : '';
  }

  // The Instagram section's pill strip. Each pill carries what has
  // already gone out for this game — "✅ Posted" or "📅 <when>" — so a
  // coach sees at a glance which posts are still owed. Drafts get no
  // mark: opening a pill creates one, so it would say nothing.
  _socialPillsHtml() {
    const picked = this.pill;
    return POST_PILLS.map(p => {
      const on = p.key === picked;
      const state = this.postStates[p.key];
      let mark = '';
      if (state && state.status === 'posted') mark = '✅ Posted';
      else if (state && state.status === 'scheduled') {
        const d = state.scheduled_at ? new Date(state.scheduled_at) : null;
        mark = d && !isNaN(d)
          ? `📅 ${d.toLocaleString('en-US', { month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' })}`
          : '📅 Scheduled';
      }
      return `
        <button type="button" data-gc-social-pill="${p.key}" role="tab" aria-selected="${on}"
                style="flex:1 1 0; min-width:104px; font-size:0.72rem; font-weight:700; line-height:1.25; padding:6px 8px; white-space:nowrap;
                       border-radius:8px; cursor:pointer; color:#fff; border:2px solid ${on ? p.accent : '#475569'};
                       background:${on ? p.accent : '#0f172a'};">
          ${p.icon} ${this.escapeHtml(this._pillTitle(p.key))}
          ${mark ? `<br><span data-gc-social-mark style="font-size:0.64rem; font-weight:600; opacity:0.95;">${this.escapeHtml(mark)}</span>` : ''}
        </button>`;
    }).join('');
  }

  // Just the strip — never the card under it, which holds a caption the
  // coach may be typing.
  _paintSocialPills() {
    const strip = this.find('#gc-social-pills');
    if (strip) strip.innerHTML = this._socialPillsHtml();
  }

  // One read of this match's posts for the marks above. Fire-and-forget:
  // the strip paints without marks until it lands, and a failure just
  // leaves them off.
  async _loadPostStates() {
    this.postStates = {};
    if (!this._canPostSocial() || !this.matchId || !this.teamId) return;
    const matchId = this.matchId;
    try {
      const res = await this.auth.fetch(`/api/social/match/${matchId}/team/${this.teamId}`);
      const data = await res.json();
      if (matchId !== this.matchId || !data || !data.success) return;
      for (const post of (data.data || [])) {
        if (post && post.post_type) this.postStates[post.post_type] = { status: post.status, scheduled_at: post.scheduled_at };
      }
      this._paintSocialPills();
    } catch (err) {
      console.warn('[game-center] post states failed:', err);
    }
  }

  // The lineup the post draws from — built from THIS screen's live zones
  // rather than a second /api/eligibility/lineup round trip. That shared
  // source is the whole point of Game Center: what the coach just
  // assigned above is what the post publishes, with no
  // save-navigate-reload gap in between where the two could drift.
  //
  // Shape matches what game-day-roster.js passes (see
  // SocialPostCard.getZoneLineup / buildImageRoster): playerId as a
  // STRING, plus the firstName/lastName/jerseyNumber/isKeeper its player
  // rows print. this.roster carries a single display `name`, so first
  // name is whatever precedes the roster's own lastName — not a re-split
  // of the full string, which would mangle a two-word surname.
  _buildRosterData(byZone, { live = false } = {}) {
    const gkPositionIds = new Set(
      this.positionList
        .filter(pos => (pos.abbreviation || '').toUpperCase() === 'GK')
        .map(pos => pos.id)
    );
    const players = [];
    const selectedIds = new Set();
    const zones = new Map();
    for (const zone of ['starter', 'bench']) {
      for (const p of byZone[zone]) {
        const pid = String(p.id);
        selectedIds.add(pid);
        zones.set(pid, zone);
        const lastName = p.lastName || '';
        const firstName = (lastName && p.name.endsWith(lastName))
          ? p.name.slice(0, p.name.length - lastName.length).trim()
          : p.name.split(' ').slice(0, -1).join(' ');
        players.push({
          playerId: pid,
          firstName: firstName || p.name,
          lastName,
          jerseyNumber: p.jerseyNumber || '',
          isKeeper: gkPositionIds.has(this.positions.get(p.id)),
        });
      }
    }
    // The pitch the Starters & Bench image draws (owner, 2026-09-19: the
    // on-screen graphic "should be what goes out to insta"). Only when
    // every starter holds a slot — otherwise the image keeps its name
    // list rather than publishing a pitch with someone missing from it.
    //
    // The rule is the same for the page and the post, empty pitch
    // included — a lineup still being built used to show a pitch up top
    // and a bare name list in the Instagram preview under it (owner,
    // 2026-09-19: "why still a diff? like a table").
    //
    // `live` is the on-page copy of the same card: a filled chip carries
    // the player id its tap-to-remove needs, and "Show Availability"
    // hangs the RSVP pill under the name. Neither reaches the post.
    const editing = live && this.isCoach && this.viewMode !== 'player';
    let pitch = null;
    if (byZone.starter.every(p => this.positions.has(p.id))) {
      const { rosterById, slotToPlayerId } = this._slotMaps();
      pitch = this._pitchRows().map(row => row === HALFWAY_ROW ? null : row.map(pos => {
        const occupant = rosterById.get(slotToPlayerId.get(pos.id));
        const token = { number: pos.sortOrder, name: occupant ? occupant.name : '' };
        if (editing && occupant) {
          token.removeId = occupant.id;
          if (this.showLineupStats) token.badgeHtml = this._rsvpStatusPill(occupant.id);
        }
        return token;
      }));
    }
    return { players, selectedIds, zones, fieldSize: this.fieldSize, pitch };
  }

  // rosterById/slotToPlayerId/startingPositions — pure lookups from
  // instance state, shared by the coach's Current Lineup card, the
  // position pills, and the Player Lineup View's formation graphic.
  _slotMaps() {
    const rosterById = new Map(this.roster.map(r => [r.id, r]));
    const slotToPlayerId = new Map();
    for (const [pid, posId] of this.positions.entries()) slotToPlayerId.set(posId, pid);
    const slotIds = this._fieldSpec().slotIds;
    const startingPositions = this.positionList.filter(pos => slotIds.has(pos.id));
    return { rosterById, slotToPlayerId, startingPositions };
  }

  // The FIELD_SIZES entry for this match's format (see fieldSize).
  _fieldSpec() {
    return FIELD_SIZES[this.fieldSize] || FIELD_SIZES[DEFAULT_FIELD_SIZE];
  }

  _rsvpStatusPill(playerId) {
    const RSVP_PILL = {
      yes:   { label: 'Going',     bg: '#166534', fg: '#bbf7d0' },
      no:    { label: 'Not Going', bg: '#7f1d1d', fg: '#fecaca' },
      maybe: { label: 'Maybe',     bg: '#78350f', fg: '#fde68a' },
    };
    const rsvp = this.stats.get(playerId)?.gameRsvp;
    const v = RSVP_PILL[rsvp] || { label: 'No RSVP', bg: '#374151', fg: '#d1d5db' };
    return `<span title="RSVP for this game" style="font-size:0.6rem; font-weight:700; padding:1px 6px; border-radius:999px; background:${v.bg}; color:${v.fg}; white-space:nowrap;">${v.label}</span>`;
  }

  // What a player reads under the Starters & Bench card: the "not
  // published" notice while no starter is set (byZone.starter.length is
  // the only signal — there is no publish flag), otherwise the
  // alternates, who are not part of the post and so not on the card.
  // Alphabetical by last name, "so no one gets mad" (owner directive).
  _renderPlayerNotes(byZone) {
    if (byZone.starter.length === 0) {
      return `
        <div class="public-card" style="text-align:center; opacity:0.85; padding: var(--space-4);">
          🔒 Lineup not yet published
        </div>`;
    }
    const alternates = [...byZone.alternate].sort((a, b) =>
      (a.lastName || a.name || '').toLowerCase().localeCompare((b.lastName || b.name || '').toLowerCase()));
    if (!alternates.length) return '';
    return `
      <div style="max-width:540px; margin:0 auto;">
        <h2 style="margin: var(--space-4) 0 4px; font-size:0.8rem; letter-spacing:0.06em; text-transform:uppercase; opacity:0.8;">Alternates</h2>
        <div style="border-top:1px solid var(--border-color); border-radius:4px; overflow:hidden;">
          ${alternates.map(p => `
            <div style="padding:8px var(--space-3); border-bottom:1px solid var(--border-color);">
              <span style="font-size:0.95em;">${this.escapeHtml(p.name)}</span>
            </div>`).join('')}
        </div>
      </div>`;
  }

  // The formation's rows, attack at top and keeper at bottom, with
  // HALFWAY_ROW spliced in mid-stack. Shared by the live pitch below and
  // the Instagram image (_buildRosterData), so the post can never draw a
  // different shape than the screen.
  _pitchRows() {
    const { startingPositions } = this._slotMaps();
    const spec = this._fieldSpec();
    const template = spec.formations[this.formation] || spec.formations[spec.defaultFormation];
    const positionById = new Map(startingPositions.map(pos => [pos.id, pos]));
    let rows;
    if (template.rows) {
      // Explicit left-to-right id order per row (see FIELD_SIZES doc).
      rows = template.rows.map(idRow => idRow.map(id => positionById.get(id)).filter(Boolean));
    } else {
      rows = [];
      let idx = 0;
      for (const count of template.counts) {
        rows.push(startingPositions.slice(idx, idx + count));
        idx += count;
      }
    }
    rows.reverse(); // attack at top, keeper at bottom
    // Halfway marker as a REAL flex row rather than the absolutely
    // positioned line + circle it replaces (2026-08-24, owner: "we could
    // put it on the field... are in the center circle like in place of
    // center circle and jusst don't have chips or namess over lap it",
    // then "center circle might be very cool"). A flex row is what makes
    // the no-overlap half of that a guarantee instead of a per-formation
    // gamble: an absolute circle pinned at top:50% lands wherever the
    // rows happen to leave room, which differs for every entry in
    // FIELD_SIZES (4 rows for 4-4-2, 5 for 4-2-3-1) and would have run
    // straight through the midfield tokens on some of them. As a row it
    // simply takes its own space and the rest lay out around it.
    //
    // Inserted at floor(rows.length / 2) — the geometric middle of the
    // row stack, which is the whole point: the line lands mid-pitch
    // whatever the shape. For the 4-row formations (4-4-2, 4-3-3,
    // 3-5-2) that is the midfield/defence gap; for the 5-row 4-2-3-1 it
    // is the gap between the two midfield bands, which is where a
    // halfway line belongs in that shape anyway. Both verified on the
    // real pitch graphic 2026-08-24.
    rows.splice(Math.floor(rows.length / 2), 0, HALFWAY_ROW);
    return rows;
  }

}
