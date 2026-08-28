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
// here (see _openDetails). The one piece still elsewhere is score
// entry, on #match-form.
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
// Zone caps: starter max 11 (a full XI), bench max 9. Alternate and the
// starter/bench-eligible flags (lineupRole, separate from zone) are
// unlimited.
const ZONE_CAPS = { starter: 11, bench: 9 };

// Formation pitch graphic row templates (2026-08-22, owner directive) —
// GK row first (bottom of the pitch; _renderFormationPitch reverses the
// array so attack ends up on top). Purely a visual layout — it doesn't
// change what role position id N actually is (see migration 296's
// 4-4-2 shirt-number scheme), just how the 11 dots are arranged and, for
// `rows`, their exact left-to-right order within each row.
//
// `rows`: explicit position-id order per row (owner directive: "front
// row: 10,9. midfield: 11,8,6,7. backline: 3,5,4,2. keeper at bottom").
// `counts`: no owner-specified order for these yet, so slots just fill
// left-to-right in id order, `count` at a time.
const FORMATIONS = {
  '4-4-2':   { rows: [[1], [3, 5, 4, 2], [11, 8, 6, 7], [10, 9]] },
  '4-3-3':   { counts: [1, 4, 3, 3] },
  '3-5-2':   { counts: [1, 3, 5, 2] },
  '4-2-3-1': { counts: [1, 4, 2, 3, 1] },
};

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
// NOTE: 'pre_match_announcement' is the DB name for what the club calls
// Starters & Bench (social_post_types row 1, renamed in a later slice).
// Keep that wire value in this table only, never inline it, so the
// rename stays a one-line change here.
const POST_PILLS = [
  { key: 'game_day',               title: 'Game Announcement', label: '⚽ Game<br>Announcement', accent: '#f59e0b', social: 'open'   },
  { key: 'lineup',                 title: '20-Man Squad',      label: '📋 20-Man<br>Squad',      accent: '#8b5cf6', social: 'closed' },
  { key: 'pre_match_announcement', title: 'Starters & Bench',  label: '⚔️ Starters<br>& Bench',  accent: '#3b82f6', social: 'closed' },
  { key: 'post_game',              title: 'Match Result',      label: '🏆 Match<br>Result',      accent: '#22c55e', social: 'open'   },
];

// Starters & Bench is the landing pill: it's the one a coach actually
// works in, and it's the team sheet a player opens the page to read.
const DEFAULT_PILL = 'pre_match_announcement';

class GameCenterScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.matchId   = null;
    this.title     = '';
    this.when      = '';
    this.teamId    = null;
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
    // 11 fixed named roles the pills use). It just chunks the same 11
    // slots (in sortOrder) into rows sized by the template counts (GK
    // row first) so the graphic reads as a real formation shape on a
    // pitch, purely for the TV-style visual.
    this.formation = '4-4-2';
    // Which of the four game moments is on screen (POST_PILLS above).
    // Supersedes the old two-way subView toggle ('lineup' | 'gameday'),
    // which was itself already collapsing two screens into one — those
    // two views are now the 'pre_match_announcement' and 'lineup' pills.
    // Visible to everyone (coach and player), independent of the
    // coach-only viewMode toggle above.
    this.pill = DEFAULT_PILL;
    // SocialPostCard for the active pill, mounted lazily — it costs four
    // API calls, so it's only built once its section is actually open.
    // Dropped on every re-render so a stale card never sits on a
    // detached node (this screen re-renders on every zone change).
    this.socialCard = null;
    // `${pill}:${open|closed}` of whatever the Instagram section is
    // currently showing — see _renderSocial for why it matters.
    this._socialMountedFor = null;
    // Which pills have their Instagram section expanded. Seeded from the
    // POST_PILLS table, then it's per-visit coach state.
    this._socialOpen = new Set(POST_PILLS.filter(p => p.social === 'open').map(p => p.key));
    // Enriched per-player admin data behind the 20-Man Squad pill's
    // "RSVP & Player Details" overlay — jersey numbers, match RSVP,
    // practice attendance, roster memberships. Coach-only, and a
    // separate fetch from the roster this.roster holds, because it
    // comes from a different endpoint with a different shape
    // (GET /api/matches/:matchId/roster-players — see _bootstrap).
    this.players = [];        // [{playerId, personId, firstName, lastName, isKeeper, jerseyNumber, rsvpStatus, rsvpSource, practice: [...], onRoster*}]
    this.trainingEvents = []; // [{id, date, title}] — the practice columns
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
    this.matchDetails = null; // {home_team_name, home_team_logo, away_team_name, away_team_logo, ...} — see _renderMatchHeader
    this._stopLighthouseAnim = null; // stop fn from LighthouseBeam.animate() — see _mountLighthouseCanvas
    this._lighthouseStartTime = null; // persisted so the beam angle never jumps across re-renders
    this._beamResizeObs = null; // ResizeObserver keeping the full-card beam canvas sized to the card
  }

  // Compact "MATCH DAY" header (2026-08-22, owner directive: "the player
  // view for both needs to look like an insta post... with logos") — home
  // vs away crest, same data source and buildTeamLogoMarkup helper (see
  // screen-base.js) game-day-roster.js's own MATCH DAY card uses, so this
  // screen and the Instagram preview it deep-links to read as one brand
  // instead of a bare pitch diagram with no opponent identity. Shown above
  // every sub-view (Lineup and Game Day, coach and player).
  // Real lighthouse-with-rotating-beam artwork (2026-08-22, owner: "the
  // lh with beam is weeak. use the one from the socials seciont of
  // site. its better. its gotta be good!") — the same LighthouseBeam
  // canvas drawing SocialPostCard.js uses for the actual Instagram post
  // (gold "1893" bands, lantern, rocky cliff, ocean), not a flat CSS
  // approximation. _mountLighthouseCanvas() below starts the animation
  // once this canvas is actually in the live DOM.
  _lighthouseCanvasHtml() {
    return `<canvas id="gl-lighthouse-canvas" style="position:absolute; right:-4px; top:-2px; width:70px; height:160px; pointer-events:none; z-index:0;"></canvas>`;
  }

  // Beam layer (2026-08-24, owner: "the light beam should go in front of
  // all other graphics") — a SECOND canvas stretched over the whole card
  // at a z-index above the content, carrying only the rotating cone. The
  // lighthouse canvas above it stays at z-index:0 on purpose: the tower
  // sits right on top of the away crest and team name, so promoting the
  // whole artwork would hide them. Splitting the two layers is what lets
  // the beam sweep across the crests, date, and lineup below while the
  // tower still reads as standing behind them.
  _beamCanvasHtml() {
    return `<canvas id="gl-beam-canvas" style="position:absolute; left:0; top:0; width:100%; height:100%; pointer-events:none; z-index:5;"></canvas>`;
  }

  // Scheduled via setTimeout(0) from _renderMatchHeader() so it runs
  // after the box.innerHTML assignment that actually mounts the canvas
  // (all three render() branches funnel through _renderMatchHeader, so
  // hooking here covers Lineup, Game Day, and the coach's own view alike
  // without touching each call site).
  _mountLighthouseCanvas() {
    if (this._stopLighthouseAnim) { this._stopLighthouseAnim(); this._stopLighthouseAnim = null; }
    if (this._beamResizeObs) { this._beamResizeObs.disconnect(); this._beamResizeObs = null; }
    const canvas = this.element && this.element.querySelector('#gl-lighthouse-canvas');
    if (!canvas || typeof window.LighthouseBeam === 'undefined') return;
    const dpr = 2;
    const cssW = 70, cssH = 160;
    canvas.width = cssW * dpr;
    canvas.height = cssH * dpr;
    // Geometry math (from lighthouseBeam.js's draw()): topmost point is
    // lhY - 49*s (finial spike), bottommost is lhY + 198*s (ocean base),
    // total span 247*s. At s=1.1 that's ~272 canvas-px tall and ~121
    // wide (rocks span 110*s each side of lhX) — sized to fit fully
    // inside this canvas with margin, both top/bottom AND left/right, so
    // nothing (rocks, ocean, "1893" digits) gets clipped off-canvas like
    // the first pass did.
    const s = 1.1;
    const lanternY = 75 * dpr;
    // The tower itself never moves, so this layer is a one-shot draw
    // rather than an animation — only the beam (on #gl-beam-canvas
    // below) needs a frame loop now.
    const lhCtx = canvas.getContext('2d');
    lhCtx.clearRect(0, 0, canvas.width, canvas.height);
    window.LighthouseBeam.draw(lhCtx, canvas.width / 2, lanternY, s);

    const card = canvas.parentElement;
    const beam = this.element.querySelector('#gl-beam-canvas');
    if (!card || !beam) return;
    if (!this._lighthouseStartTime) this._lighthouseStartTime = performance.now();

    const startBeam = () => {
      if (this._stopLighthouseAnim) { this._stopLighthouseAnim(); this._stopLighthouseAnim = null; }
      const cardRect = card.getBoundingClientRect();
      if (!cardRect.width || !cardRect.height) return;
      const lhRect = canvas.getBoundingClientRect();
      // 1 device px per CSS px here (unlike the 2x lighthouse layer):
      // the card runs the full height of the lineup, so a 2x backing
      // store means clearing and re-filling millions of pixels every
      // frame for a graphic that is nothing but soft gradients — there
      // are no hard edges for the extra resolution to sharpen.
      beam.width = Math.round(cardRect.width);
      beam.height = Math.round(cardRect.height);
      this._stopLighthouseAnim = window.LighthouseBeam.animate(beam, {
        startTime: this._lighthouseStartTime,
        drawLighthouse: false, // tower stays on the layer behind the content
        // Lantern position, read off the live rects rather than
        // recomputed from the inline `right`/`top` above, so the two
        // layers cannot drift apart if those offsets ever change.
        lhX: lhRect.left - cardRect.left + cssW / 2,
        lhY: lhRect.top - cardRect.top + lanternY / dpr,
        // Scale the reach off the card's WIDTH, not the default
        // max(w, h): on a tall lineup card the height-derived default
        // stretches the fade-out so far that the cone stops looking
        // like a beam and just tints the whole card yellow.
        beamLen: cardRect.width * 1.8,
        // Same sweep rate as the posted video (see LighthouseBeam and
        // SocialPostCard.js's postNow()) for consistency across every
        // view (owner, 2026-08-22: "time the beam so the post time shown
        // matches the 360 arc of beam"). No clip length applies to this
        // live decorative canvas specifically, but one shared period
        // everywhere beats guessing a different arbitrary speed per view.
        rotPeriodSec: window.LighthouseBeam.BEAM_ROTATION_SECONDS,
        beamSpread: 0.16,
      }).stop;
    };
    startBeam();

    // The card grows and shrinks after mount — crests finish loading,
    // the Lineup/Game Day toggle swaps the content, a player gets moved
    // between rows — and animate() captures the canvas size once, so the
    // beam layer has to be rebuilt whenever the card resizes or it ends
    // up clipped to a stale height.
    if (typeof ResizeObserver !== 'undefined') {
      let queued = false;
      this._beamResizeObs = new ResizeObserver(() => {
        if (queued) return;
        queued = true;
        requestAnimationFrame(() => { queued = false; startBeam(); });
      });
      this._beamResizeObs.observe(card);
    }
  }

  // Full-size unified frame (2026-08-22, owner: "when i click lineup from
  // main screen it should be full insta post view not tiny one. corect
  // ratio and proper lighthouse with rotating ray light! for all") — one
  // continuous card (crests/VS/date/venue + whatever content is passed
  // in) at real Instagram-post proportions, always with the rotating
  // lighthouse beam, instead of a small compact header strip sitting
  // above a separately-styled content box below it.
  _renderMatchHeader(innerHtml = '') {
    const m = this.matchDetails;
    if (!m) return innerHtml;
    const homeLogo = this.buildTeamLogoMarkup(m.home_team_logo, { className: 'team-logo-lg', alt: 'Home', placeholder: '🏠' });
    const awayLogo = this.buildTeamLogoMarkup(m.away_team_logo, { className: 'team-logo-lg', alt: 'Away', placeholder: '🏟️' });
    // setTimeout(0) queues _mountLighthouseCanvas() to run right after
    // this string gets assigned to box.innerHTML elsewhere in the same
    // synchronous call — the canvas doesn't exist in the live DOM yet
    // at this point in the function, so the animation can't start here.
    setTimeout(() => this._mountLighthouseCanvas(), 0);
    return `
      <div style="position:relative; overflow:hidden; max-width:480px; margin:0 auto 12px; background:linear-gradient(180deg,#1e3a8a,#1e40af); border:2px solid rgba(250,204,21,0.6); border-radius:16px; padding:18px 16px 20px; box-shadow:0 10px 34px rgba(0,0,0,0.35);">
        ${this._lighthouseCanvasHtml()}
        <div style="position:relative; z-index:1; text-align:center;">
          <div style="display:flex; align-items:flex-start; justify-content:center; gap:26px;">
            <div style="display:flex; flex-direction:column; align-items:center; gap:6px; flex:1; min-width:0; max-width:170px;">
              ${homeLogo}
              <div style="font-size:0.78rem; font-weight:700; color:#fff; text-transform:uppercase; overflow-wrap:break-word; line-height:1.2;">${this.escapeHtml(m.home_team_name || 'Home')}</div>
            </div>
            <div style="font-size:0.9rem; font-weight:700; color:#facc15; opacity:0.9; margin-top:26px;">VS</div>
            <div style="display:flex; flex-direction:column; align-items:center; gap:6px; flex:1; min-width:0; max-width:170px;">
              ${awayLogo}
              <div style="font-size:0.78rem; font-weight:700; color:#fff; text-transform:uppercase; overflow-wrap:break-word; line-height:1.2;">${this.escapeHtml(m.away_team_name || 'Away')}</div>
            </div>
          </div>
          ${this.when ? `<div style="margin-top:12px; font-size:0.74rem; color:#dbeafe; opacity:0.9;">📅 ${this.escapeHtml(this.when)}</div>` : ''}
          ${m.venue_location ? `<div style="margin-top:2px; font-size:0.68rem; color:#dbeafe; opacity:0.75; overflow-wrap:break-word;">📍 ${this.escapeHtml(m.venue_location)}</div>` : ''}
        </div>
        <div style="position:relative; z-index:1; margin-top:16px;">
          ${innerHtml}
        </div>
        ${this._beamCanvasHtml()}
      </div>`;
  }

  render() {
    const el = document.createElement('div');
    // screen-game-lineup class kept — css/ still targets it, and the
    // stylesheet rename is not worth coupling to this change.
    el.className = 'screen screen-game-lineup screen-game-center';
    el.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🏟️ Game Center</h1>
        <p class="subtitle" id="gl-subtitle">Loading…</p>
      </div>
      <div id="gl-body" style="padding: var(--space-3) var(--space-4) 0;"></div>
      <!-- The Instagram section lives OUTSIDE #gl-body on purpose.
           _render() rewrites #gl-body wholesale on every zone toggle,
           and the SocialPostCard mounted in here holds live state a
           coach has invested in — a typed caption, a generated image,
           a chosen schedule time. Re-creating it on each tap would
           throw that away and re-fire its four API calls. _renderSocial
           owns this node instead and only rebuilds it when the pill or
           its open/closed state actually changes. -->
      <div id="gc-social" style="padding: 0 var(--space-4) var(--space-6);"></div>

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
    const rawMatchId = params.matchId != null ? params.matchId : ctxMatch?.id;
    this.matchId = rawMatchId != null ? Number(rawMatchId) : null;
    this.title   = params.title || ctxMatch?.title || '';
    this.when    = params.when || '';
    this.viewMode = 'coach';
    this.pill    = this._resolvePill(params);
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
    if (this._stopLighthouseAnim) { this._stopLighthouseAnim(); this._stopLighthouseAnim = null; }
    if (this._beamResizeObs) { this._beamResizeObs.disconnect(); this._beamResizeObs = null; }
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
      const viewToggle = e.target.closest('#gl-view-toggle');
      if (viewToggle && this.isCoach) {
        this.viewMode = this.viewMode === 'coach' ? 'player' : 'coach';
        this._render();
        return;
      }
      const pillBtn = e.target.closest('[data-game-pill]');
      if (pillBtn) {
        const next = pillBtn.getAttribute('data-game-pill');
        if (next !== this.pill && POST_PILLS.some(p => p.key === next)) {
          this.pill = next;
          this._syncHash();
          this._render();
        }
        return;
      }
      // The Instagram section for the active pill. Collapsed sections
      // never mount their SocialPostCard, so this is also what defers
      // that component's four API calls until they're wanted.
      const socialToggle = e.target.closest('#gc-social-toggle');
      if (socialToggle) {
        if (this._socialOpen.has(this.pill)) this._socialOpen.delete(this.pill);
        else this._socialOpen.add(this.pill);
        this._render();
        return;
      }
      if (e.target.closest('#gc-details-open')) { this._openDetails(); return; }
      if (e.target.closest('#gc-details-close')) { this._closeDetails(); return; }

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
      const [lineupRes, positionsRes, matchRes] = await Promise.all([
        this.auth.fetch(`/api/eligibility/lineup/${this.matchId}`),
        this.auth.fetch('/api/eligibility/positions'),
        this.auth.fetch(`/api/matches/${this.matchId}`),
      ]);
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
      this.matchStartsAt = lineupData.data.matchStartsAt || null;
      // isCoach comes from EligibilityController checking the REAL logged-in
      // account's admin/coach status — it never looks at the "view as
      // <player>" impersonation the READ request may be carrying, so an
      // admin using view-as still gets isCoach:true from their own account.
      // Force it off here whenever view-as is active (owner, 2026-08-22:
      // "players dont need player lineup view lol... there view is default
      // player") so view-as always renders exactly what the impersonated
      // player would see — no coach toggle, no edit tools, default view.
      this.isCoach = !!lineupData.data.isCoach && !(this.auth && this.auth.viewAsPersonId);
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

      const [rosterResults, detailsData] = await Promise.all([
        Promise.all(rosterTeamIds.map(id =>
          this.auth.fetch(`/api/teams/${id}/roster`).then(r => r.json()).then(d => ({ id, d })))),
        detailsPromise,
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
  // glance, not a lock. Never exceeds 11 starters: replacing frees a
  // slot in the same stroke as filling it, and there are only 11 pills.
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

    // The four-moment pill strip — the spine of this screen. Scrolls
    // horizontally rather than wrapping, so the row reads as one strip
    // on a phone instead of a 2x2 block.
    const pillStripHtml = `
      <div style="display:flex; gap:6px; margin-bottom:10px; overflow-x:auto;">
        ${POST_PILLS.map(p => {
          const active = p.key === this.pill;
          return `<button type="button" data-game-pill="${p.key}"
            class="btn ${active ? 'btn-primary' : 'btn-secondary'}"
            style="flex:1 1 0; min-width:104px; font-size:0.72rem; line-height:1.25; padding:6px 8px; white-space:nowrap;
                   ${active ? `border-bottom:3px solid ${p.accent};` : ''}">${p.label}</button>`;
        }).join('')}
      </div>`;

    // Coach ↔ Player preview only means something on the two pills that
    // render a team sheet; on Game Announcement and Match Result there's
    // no coach-only content for it to hide.
    const toggleHtml = (this.pill === 'lineup' || this.pill === 'pre_match_announcement') ? viewToggleHtml : '';

    // One assignment point for every pill (below), so the Instagram
    // section and the card mount are wired in exactly one place instead
    // of being repeated down each branch.
    const paint = (bodyHtml) => {
      box.innerHTML = pillStripHtml + toggleHtml + bodyHtml;
      this._renderSocial(byZone);
    };

    if (this.pill === 'game_day') {
      // The match header IS the game announcement — crests, date, venue.
      paint(this._renderMatchHeader(''));
      return;
    }

    if (this.pill === 'post_game') {
      paint(this._renderMatchHeader(this._renderResultSummary()));
      return;
    }

    if (this.pill === 'lineup') {
      // Controls sit OUTSIDE the graphic frame (owner, 2026-08-22:
      // "don't have options on the insta post like drop downs. that
      // should be under it"), same placement as the Starters & Bench
      // pill's formation/availability toolbar.
      const squadCount = byZone.starter.length + byZone.bench.length;
      const detailsHtml = this.isCoach ? `
        <div style="display:flex; justify-content:space-between; align-items:center; gap:8px; margin-top:10px; flex-wrap:wrap;">
          <span style="font-size:0.72rem; opacity:0.75;">${squadCount} on the game-day roster</span>
          <button type="button" id="gc-details-open" class="btn btn-primary"
                  style="font-size:0.75rem; padding:4px 10px;">👥 RSVP &amp; Player Details</button>
        </div>` : '';
      paint(this._renderMatchHeader(this._renderGameDayRoster(byZone)) + detailsHtml);
      return;
    }

    if (effectiveIsPlayerView) {
      paint(this._renderMatchHeader(this._renderPlayerView(byZone)));
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
        <span style="font-size:0.72rem; opacity:0.75;">Starting ${byZone.starter.length}/11 · Bench ${byZone.bench.length} · Alt ${byZone.alternate.length}</span>
        <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
          <select data-lineup-formation-select title="Formation (visual layout only)"
                  style="font-size:0.72rem; font-weight:700; padding:4px 6px; border-radius:4px; border:1px solid #475569; background:#0f172a; color:#fff;">
            ${Object.keys(FORMATIONS).map(f => `<option value="${f}" ${f === this.formation ? 'selected' : ''}>${f}</option>`).join('')}
          </select>
          <button type="button" id="gl-stats-toggle" class="btn btn-secondary" style="font-size:0.72rem; padding:4px 10px;">
            ${this.showLineupStats ? 'Hide' : 'Show'} Availability
          </button>
        </div>
      </div>`;

    const summaryHtml = `
      ${this._renderFormationPitch(byZone, { readOnly: false })}
      ${this._renderBenchGraphic(byZone.bench)}`;

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

    const playerRow = (p) => `
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
      </div>`;

    // Multiple player cards per line instead of one full-width row each
    // (owner directive: "like on teams screen, so there is less blank
    // space on desktop") — every coach-view section (Starting/Bench/
    // Alternates/Going/collapsed Not-Going/No-Response) uses this same
    // auto-fill grid, each card wrapping playerRow's content in its own
    // bordered tile instead of a shared list divider.
    const cardGrid = (players) => players.length
      ? `<div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(280px, 1fr)); gap:6px;">
          ${players.map(p => `<div style="border:1px solid var(--border-color); border-radius:6px; overflow:hidden;">${playerRow(p)}</div>`).join('')}
        </div>`
      : `<div style="padding:6px var(--space-3); opacity:0.6; font-size:0.85em;">None yet</div>`;

    const gridSection = (label, players) => `
      <h2 style="margin: var(--space-3) 0 4px; font-size:0.85rem;">${label} (${players.length})</h2>
      ${cardGrid(players)}
    `;

    // Not Going / No Response rolled up out of the way by default (owner
    // directive: "...have them rolled up so they are not in way") — a
    // coach almost never needs these, unlike Going.
    const collapsedSection = (label, players) => `
      <details style="margin: var(--space-3) 0;">
        <summary style="cursor:pointer; font-size:0.85rem; font-weight:700; padding:4px 0;">${label} (${players.length})</summary>
        ${cardGrid(players)}
      </details>
    `;

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
    paint(this._renderMatchHeader(summaryHtml) + lineupControlsHtml + [
      gridSection('Bench', byZone.bench),
      gridSection('Alternates', byZone.alternate),
      this.isCoach ? gridSection('✓ Going', unassignedGoing) : '',
      this.isCoach ? collapsedSection('✗ Not Going', unassignedNotGoing) : '',
      this.isCoach ? collapsedSection('– No Response', unassignedNoResponse) : '',
    ].join(''));
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

  // Score readout for the Match Result pill. Entering the score still
  // happens on #match-form until that moves here in a later slice —
  // this just surfaces what's recorded so the pill isn't a bare frame,
  // and so a coach can see at a glance whether the result post has a
  // scoreline to publish yet.
  _renderResultSummary() {
    const m = this.matchDetails;
    const hs = m ? (m.home_team_score ?? m.home_score) : null;
    const as = m ? (m.away_team_score ?? m.away_score) : null;
    if (hs == null || as == null) {
      return `
        <div style="border-top:1px solid rgba(255,255,255,0.15); padding-top:12px; text-align:center;">
          <div style="font-size:0.7rem; color:#dbeafe; opacity:0.85;">No score recorded yet</div>
        </div>`;
    }
    return `
      <div style="border-top:1px solid rgba(255,255,255,0.15); padding-top:12px; text-align:center;">
        <div style="font-size:2rem; font-weight:800; color:#facc15; line-height:1;">${this.escapeHtml(String(hs))} – ${this.escapeHtml(String(as))}</div>
        <div style="font-size:0.62rem; color:#dbeafe; opacity:0.8; margin-top:4px; letter-spacing:0.08em;">FINAL</div>
      </div>`;
  }

  // Owns #gc-social — the collapsible Instagram section for whichever
  // pill is active. Only the roles that may actually publish get it
  // (same gate the old deep-link button used).
  //
  // The `_socialMountedFor` guard is what makes this safe to call from
  // every _render(): a coach toggling players upstairs must not lose the
  // caption they're drafting down here. When the section is unchanged we
  // keep the live card and just hand it fresh rosterData, so the next
  // Regenerate draws the lineup as it stands now — the card is rebuilt
  // only when the pill or its open/closed state genuinely changes.
  _renderSocial(byZone) {
    const host = this.find('#gc-social');
    if (!host) return;

    if (!this._canPostSocial()) {
      host.innerHTML = '';
      this.socialCard = null;
      this._socialMountedFor = null;
      return;
    }

    const open = this._socialOpen.has(this.pill);
    const key = `${this.pill}:${open ? 'open' : 'closed'}`;
    if (key === this._socialMountedFor) {
      if (this.socialCard) this.socialCard.rosterData = this._buildRosterData(byZone);
      return;
    }
    this._socialMountedFor = key;

    const meta = POST_PILLS.find(p => p.key === this.pill);
    host.innerHTML = `
      <div style="margin-top: var(--space-4); border-top:1px solid var(--border-color); padding-top:10px;">
        <button type="button" id="gc-social-toggle" class="btn btn-secondary"
                style="width:100%; text-align:left; font-size:0.78rem; padding:6px 10px;">
          ${open ? '▾' : '▸'} 📸 Instagram — ${this.escapeHtml(meta ? meta.title : this.pill)}
        </button>
        <div id="gc-social-mount" style="margin-top:10px;"></div>
      </div>`;

    this.socialCard = null;
    if (!open || !this.matchId || !this.teamId) return;

    const mount = this.find('#gc-social-mount');
    if (!mount) return;
    const card = new SocialPostCard(this.auth);
    card.init(mount, this.matchId, this.teamId, this.pill, this.matchDetails || {}, this._buildRosterData(byZone));
    this.socialCard = card;
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
  _buildRosterData(byZone) {
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
    return { players, selectedIds, zones };
  }

  // rosterById/slotToPlayerId/startingPositions — pure lookups from
  // instance state, shared by the coach's Current Lineup card, the
  // position pills, and the Player Lineup View's formation graphic.
  _slotMaps() {
    const rosterById = new Map(this.roster.map(r => [r.id, r]));
    const slotToPlayerId = new Map();
    for (const [pid, posId] of this.positions.entries()) slotToPlayerId.set(posId, pid);
    const startingPositions = this.positionList.filter(pos => pos.sortOrder <= 11);
    return { rosterById, slotToPlayerId, startingPositions };
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

  // Formation pitch graphic (2026-08-22) — shared by the coach's
  // Current Lineup card (readOnly:false, click a filled slot to
  // unassign) and the Player Lineup View (readOnly:true, "this all will
  // be the player view for lineup" — owner directive). Lighthouse blue
  // chip with a white outline and yellow number (owner: "make chips our
  // lh colors blue and white" / "blue inside white outline" / "yellow
  // number"). Names never truncate — wrap instead of ellipsis (owner:
  // "don't hide names with ...").
  _renderFormationPitch(byZone, { readOnly = false } = {}) {
    const { rosterById, slotToPlayerId, startingPositions } = this._slotMaps();
    const template = FORMATIONS[this.formation] || FORMATIONS['4-4-2'];
    const positionById = new Map(startingPositions.map(pos => [pos.id, pos]));
    let rows;
    if (template.rows) {
      // Explicit left-to-right id order per row (see FORMATIONS doc).
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
    // FORMATIONS (4 rows for 4-4-2, 5 for 4-2-3-1) and would have run
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
    const token = (pos) => {
      const occupantId = slotToPlayerId.get(pos.id);
      const occupant = occupantId != null ? rosterById.get(occupantId) : null;
      const clickable = !readOnly && occupant;
      const title = occupant ? (readOnly ? occupant.name : `Remove ${occupant.name} from ${pos.name}`) : pos.name;
      return `
        <div style="display:flex; flex-direction:column; align-items:center; gap:2px; max-width:78px; position:relative; z-index:1;">
          <button type="button" ${clickable ? `data-lineup-remove-starter="${occupant.id}"` : ''}
                  title="${this.escapeHtml(title)}"
                  style="width:30px; height:30px; border-radius:50%; border:2px solid #fff; flex-shrink:0;
                         background:${occupant ? '#1d4ed8' : 'rgba(255,255,255,0.3)'}; color:${occupant ? '#facc15' : '#fff'};
                         font-weight:800; font-size:0.72rem; cursor:${clickable ? 'pointer' : 'default'}; box-shadow:0 1px 3px rgba(0,0,0,0.3);">
            ${pos.sortOrder}
          </button>
          <span style="font-size:0.58rem; color:#fff; text-align:center; overflow-wrap:break-word; white-space:normal; max-width:78px; text-shadow:0 1px 2px rgba(0,0,0,0.6); ${occupant ? '' : 'opacity:0.7;'}">${occupant ? this.escapeHtml(occupant.name) : '—'}</span>
          ${occupant && this.showLineupStats ? this._rsvpStatusPill(occupant.id) : ''}
        </div>`;
    };
    // Real pitch markings — outline, halfway line, center circle, goal
    // box — layered behind the rows with position:absolute so it reads
    // as an actual pitch, not a plain green rectangle. Portrait,
    // compact (owner: "smaller pitch and closer together").
    return `
      <div style="position:relative; background:linear-gradient(180deg, #16a34a, #14532d); border-radius:10px; padding:14px 8px; max-width:420px; margin:0 auto; min-height:470px; display:flex; flex-direction:column; justify-content:space-between; overflow:hidden;">
        <div style="position:absolute; inset:6px; border:2px solid rgba(255,255,255,0.35); border-radius:4px;"></div>
        <div style="position:absolute; left:50%; bottom:6px; width:100px; height:32px; margin-left:-50px; border:2px solid rgba(255,255,255,0.35); border-bottom:none;"></div>
        ${rows.map(row => row === HALFWAY_ROW
          ? this._halfwayRowHtml()
          : `<div style="display:flex; justify-content:center; align-items:flex-start; gap:10px; position:relative; z-index:1;">${row.map(token).join('')}</div>`).join('')}
      </div>`;
  }

  // Halfway line with the league crest sitting in the center circle.
  // The crest is whatever the DB resolved for this match's `League:` tag
  // (see leagueCrest.js for the full path) — never inferred here from
  // the opponent's name, which is the guessing migration 297 exists to
  // end. A match the DB gives no crest for falls back to the plain empty
  // ring the pitch drew before, so nothing regresses and no match ever
  // gets branded with the wrong league.
  _halfwayRowHtml() {
    const crest = window.LeagueCrest ? window.LeagueCrest.resolve(this.matchDetails) : null;
    const line = `<div style="flex:1; border-top:2px solid rgba(255,255,255,0.35);"></div>`;
    const circle = crest && crest.src
      ? `<div title="${this.escapeHtml(crest.label)}"
              style="width:64px; height:64px; border-radius:50%; border:2px solid rgba(255,255,255,0.5);
                     background:rgba(255,255,255,0.94); display:flex; align-items:center; justify-content:center;
                     flex-shrink:0; box-shadow:0 2px 8px rgba(0,0,0,0.3); overflow:hidden;">
           <img src="${crest.src}" alt="${this.escapeHtml(crest.label)}"
                style="max-width:46px; max-height:46px; object-fit:contain;">
         </div>`
      : `<div style="width:64px; height:64px; border-radius:50%; border:2px solid rgba(255,255,255,0.35); flex-shrink:0;"></div>`;
    return `<div style="display:flex; align-items:center; gap:8px; position:relative; z-index:1;">${line}${circle}${line}</div>`;
  }

  // Bench, attached under the pitch graphic (owner: "show bench in
  // graphic") — simplified to a plain comma-separated name list rather
  // than individual chips (owner: "you can put bench at bottom without
  // chips but list names in full csv"). `bench` is whatever order the
  // caller wants shown (coach's benchOrder vs player's always-
  // alphabetical — see _renderPlayerView).
  _renderBenchGraphic(bench) {
    return `
      <div style="max-width:300px; margin:10px auto 0; text-align:center;">
        <div style="font-size:0.72rem; font-weight:700; opacity:0.75; margin-bottom:4px;">BENCH${bench.length ? '' : ' (0)'}</div>
        <div style="font-size:0.75rem; color:var(--text-primary, #fff); line-height:1.4;">${bench.length ? bench.map(p => this.escapeHtml(p.name)).join(', ') : 'None yet'}</div>
      </div>`;
  }

  // Read-only formation graphic (2026-08-22, owner directive: "this all
  // will be the player view for lineup") — what players actually see,
  // and what a coach sees via the "👀 Player Lineup View" toggle above.
  // Same pitch + bench graphic as the coach's Current Lineup card
  // (_renderFormationPitch/_renderBenchGraphic), just readOnly:true (no
  // remove-on-click) and no stats/formation toggles. Same "not
  // published yet" gate the old text-list view used
  // (byZone.starter.length===0 is the only signal we have — there's no
  // explicit publish flag).
  //
  // Bench is always alphabetical by last name here — "so no one gets
  // mad" (owner directive) — deliberately NOT the coach's bench order,
  // since there's no fairness case for ranking the bench for players.
  // Alternates stays a plain list below the graphic (not part of a
  // real formation/bench concept).
  _renderPlayerView(byZone) {
    if (byZone.starter.length === 0) {
      return `
        <div class="public-card" style="text-align:center; opacity:0.85; padding: var(--space-4);">
          🔒 Lineup not yet published
        </div>`;
    }

    const byLastName = (list) => [...list].sort((a, b) =>
      (a.lastName || a.name || '').toLowerCase().localeCompare((b.lastName || b.name || '').toLowerCase())
    );
    const benchAlpha = byLastName(byZone.bench);
    const alternatesAlpha = byLastName(byZone.alternate);

    const plainRow = (p) => `
      <div style="padding:8px var(--space-3); border-bottom:1px solid var(--border-color);">
        <span style="font-size:0.95em;">${this.escapeHtml(p.name)}</span>
      </div>`;
    const altSection = alternatesAlpha.length ? `
      <h2 style="margin: var(--space-4) 0 4px; font-size:0.8rem; letter-spacing:0.06em; text-transform:uppercase; opacity:0.8;">Alternates</h2>
      <div style="border-top:1px solid var(--border-color); border-radius:4px; overflow:hidden;">
        ${alternatesAlpha.map(plainRow).join('')}
      </div>
    ` : '';

    return `
      <div style="max-width:440px; margin:0 auto;">
        ${this._renderFormationPitch(byZone, { readOnly: true })}
        ${this._renderBenchGraphic(benchAlpha)}
        ${altSection}
      </div>`;
  }

  // Game Day Roster (2026-08-22, owner directive) — reached directly via
  // my.js's own "Game Day Roster" button (params.mode='gameday'), NOT
  // through the coach/player toggle. Plain list of everyone with a
  // standing Roster Role of "1st Team Starter" or "1st Team Bench"
  // (lineupRole, set on the Teams page — mens-roster.js's Roster Role
  // dropdown), alpha by last name. Deliberately per-match-zone-agnostic:
  // this is "who's in the 1st team pool", not "who's starting THIS game"
  // — that's the Lineup button/_renderPlayerView above.
  // Redesigned (2026-08-22, owner: "game day view is still list view...
  // make it insta grade everywhere") from a plain bordered text list into
  // a chip card matching the same blue/gold card language as
  // _renderMatchHeader/_renderFormationPitch, so Lineup and Game Day read
  // as one consistent, graphic-first screen instead of a form-like list
  // for one sub-view and a polished graphic for the other.
  // Reads from THIS MATCH's own zones (owner, 2026-08-22: "game day
  // roster has guys not even going. use source of truth for all. what i
  // selected") — previously read the standing season-long Roster Role
  // from the Teams page instead of the actual per-match starter/bench
  // the coach set on the Lineup sub-view, so it could show people who
  // aren't even part of this game (or miss people who are). byZone is
  // the exact same object the pitch graphic renders from.
  _renderGameDayRoster(byZone) {
    const byLastName = (list) => [...list].sort((a, b) =>
      (a.lastName || a.name || '').toLowerCase().localeCompare((b.lastName || b.name || '').toLowerCase())
    );
    const starters = byLastName(byZone.starter);
    const bench = byLastName(byZone.bench);
    const list = [...starters, ...bench];
    if (list.length === 0) {
      return `
        <div class="public-card" style="text-align:center; opacity:0.85; padding: var(--space-4);">
          Lineup not set yet — set starters &amp; bench on the Lineup tab.
        </div>`;
    }
    const chip = (p) => `
      <div style="display:flex; align-items:center; gap:6px; background:rgba(255,255,255,0.06); border:1px solid rgba(255,255,255,0.1); border-radius:999px; padding:5px 12px 5px 6px;">
        <span style="width:8px; height:8px; border-radius:50%; background:#facc15; flex-shrink:0;"></span>
        <span style="font-size:0.78rem; font-weight:600; color:#fff; overflow-wrap:break-word;">${this.escapeHtml(p.name)}</span>
      </div>`;
    const section = (title, players) => players.length ? `
      <div style="margin-top:14px;">
        <div style="font-size:0.66rem; font-weight:700; letter-spacing:0.08em; text-transform:uppercase; color:#facc15; margin-bottom:6px;">${title} (${players.length})</div>
        <div style="display:flex; flex-wrap:wrap; gap:6px;">
          ${players.map(chip).join('')}
        </div>
      </div>` : '';
    // No card/lighthouse of its own — this renders INSIDE
    // _renderMatchHeader()'s frame now, which already supplies both.
    return `
      <div style="border-top:1px solid rgba(255,255,255,0.15); padding-top:12px;">
        <div style="font-size:0.7rem; font-weight:700; letter-spacing:0.1em; text-transform:uppercase; color:#fff; text-align:center; margin-bottom:2px;">📋 Game Day Squad</div>
        <div style="font-size:0.62rem; color:#dbeafe; opacity:0.8; text-align:center;">${list.length} on the roster for this match</div>
        ${section('Starters', starters)}
        ${section('Bench', bench)}
      </div>`;
  }
}
