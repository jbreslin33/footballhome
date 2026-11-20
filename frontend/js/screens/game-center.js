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
//     still clickable.  Until 2026-09-26 that REPLACED them (bumped
//     back to unassigned, no warning); now it opens the swap sheet
//     (_openPositionSheet): swap the two, or send the holder to Bench
//     / Alternates.  Same sheet when the bench is full
//     (_openBenchSheet).  An empty target is still one tap.
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
// Zone caps: bench = the match-day squad minus the starters (mig 760:
// teams.matchday_squad_size, NULL = field_size + 9 → 20 for 11v11), sent
// by the lineup GET as benchCap; 9 is only the fallback before it loads.
// A full bench offers "extend to an N-man squad — this game only"
// (_extendSquad), stored on match_lineup_metadata.squad_size.  Starters
// are capped by the position pills themselves — there are exactly
// `fieldSize` of them (see FIELD_SIZES), so a starter slot is freed in
// the same stroke as it's filled.  Alternate and the starter/bench-
// eligible flags (lineupRole, separate from zone) are unlimited.
const DEFAULT_BENCH_CAP = 9;

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
// Owner 2026-11-06: "always put striker a little higher up then
// 'wingers' or inside wingers" — where a striker shares a row with the
// wide men, his chip draws this many px higher (chipLifts).  A four-man
// front (11 10 9 7) lifts both central strikers.
const STRIKER_LIFT = 14;
const STRIKER_UP = Object.freeze({ 9: STRIKER_LIFT });
const STRIKERS_UP = Object.freeze({ 10: STRIKER_LIFT, 9: STRIKER_LIFT });

const FIELD_SIZES = {
  11: {
    defaultFormation: '4-4-2',
    formations: {
      '4-4-2':   { rows: [[1], [3, 5, 4, 2], [11, 8, 6, 7], [10, 9]] },
      // Owner 2026-09-29: "7 and 11 are wingers, 9 striker, 8 and 10
      // attacking mids (10 left), 6 def mid, 3 LB, 5 LCB, 4 RCB, 2 RB".
      // Drawn as a triangle so the 6 sits behind the 8 and 10.
      '4-3-3':   { rows: [[1], [3, 5, 4, 2], [6], [10, 8], [11, 9, 7]], chipLifts: STRIKER_UP },
      // Owner: "for the 4231 the 8 and 6 are the cdms left to right and
      // the rest are same as 433" — 10 is the central attacking mid.
      '4-2-3-1': { rows: [[1], [3, 5, 4, 2], [8, 6], [11, 10, 7], [9]] },
      // Owner 2026-11-05 (mig 1106): "the diff is the width of the 7,11
      // and 2,3" — wide puts the 7 and 11 on the touchlines; narrow puts
      // the 2 and 3 there and tucks the 7 and 11 in beside the 10
      // (`narrowIds`: tighter chip cap, see buildImagePitch). Narrow,
      // owner: "move the fullbacks up a little and the 6,8 a little
      // higher and the 11,10,7 a little lower" — `chipLifts` (position
      // id → px up) nudges single chips; a negative `lifts` drops a row.
      // Then "2 and 3 up a little more and in": `chipInsets` (id → px)
      // holds a wide chip that far off its touchline.
      '4-2-3-1 wide':   { rows: [[1], [3, 5, 4, 2], [8, 6], [11, 10, 7], [9]], wideIds: [11, 7] },
      '4-2-3-1 narrow': { rows: [[1], [3, 5, 4, 2], [8, 6], [11, 10, 7], [9]], wideIds: [3, 2], narrowIds: [11, 7],
                          chipLifts: { 3: 30, 2: 30 }, chipInsets: { 3: 36, 2: 36 }, lifts: { 2: 12, 3: -12 } },
      // Owner 2026-10-19: both back-three shapes drop the 6 INTO the
      // back line (back three 5-6-4). Flat 3-4-3: "balanced 8 and 10
      // in middle" of the four (10 left, same rule as 4-3-3), 3 and 2
      // as the wide men.
      //
      // `wideIds`: chips pushed out to the sidelines (owner 2026-10-19:
      // "move the 2 and 3 wider to sideline") — see buildImagePitch.
      // `halfwayOn`: index into `rows` (as written) of the row that
      // stands ON the halfway line, crest between its two middle chips —
      // see _pitchRows.
      //
      // Owner 2026-11-06 (mig 1109): every back-three shape shares one
      // "bowl" — 3, 5, 6, 4, 2 left to right (back line 5-6-4, wing backs
      // 3 and 2) — and the bracket is the inside five (10 8 11 7 9) read
      // from the bottom of the bowl up. Owner rules (mig 1115): "always
      // 11 and 7 if 2 man front ... then 9 goes into midfield", "9 is
      // always middle of 10 and 8 but 9 would be the 1 in a 122", and
      // "always put striker a little higher up then wingers or inside
      // wingers" — `chipLifts` (id → px up) on the striker. Then "put line
      // under midfield in all 3 back" and "put the wing backs on the line
      // in all back 3": above the halfway line on the graphic = primarily
      // an attacker, so in every back-three shape the 3 and 2 stand ON
      // the line (`halfwayOn`, crest between them) with the midfield
      // above; a holder (the 1-2-2's 9, the 3-4-3 (1-1-3)'s 8) stays
      // below it.
      '3-4-3 (2-3)':   { rows: [[1], [5, 6, 4], [3, 2], [10, 8], [11, 9, 7]], wideIds: [3, 2], halfwayOn: 2, chipLifts: STRIKER_UP },
      '3-4-3 (2-2-1)': { rows: [[1], [5, 6, 4], [3, 2], [10, 8], [11, 7], [9]], wideIds: [3, 2], halfwayOn: 2 },
      // Owner 11/6: "we need a 343(41)" (mig 1119) — the 2-2-1 with the 11
      // and 7 dropped level with the 10 and 8, the 9 alone up top.
      '3-4-3 (4-1)':   { rows: [[1], [5, 6, 4], [3, 2], [11, 10, 8, 7], [9]], wideIds: [3, 2], halfwayOn: 2 },
      '3-5-2 (2-1-2)': { rows: [[1], [5, 6, 4], [3, 2], [10, 8], [9], [11, 7]], wideIds: [3, 2], halfwayOn: 2 },
      '3-5-2 (1-2-2)': { rows: [[1], [5, 6, 4], [9], [3, 2], [10, 8], [11, 7]], wideIds: [3, 2], halfwayOn: 3 },
      '3-5-2 (3-2)':   { rows: [[1], [5, 6, 4], [3, 2], [10, 9, 8], [11, 7]], wideIds: [3, 2], halfwayOn: 2 },
      // Asymmetric (migs 1112–1118): an R/L before a row in the bracket =
      // that pair sits right/left of center; never mirrored for free.
      // R2 = 11 the striker, 7 in the hole right of center; L2 = 7 the
      // striker, 11 in the hole left of center. The 0 is an empty column
      // (GAP_POS) holding a chip off-center.
      // First one, owner: "him [Amir] as right sided '10'/inside winger".
      // 3-R2, owner: "move 7 down further ... put him where a 10 would be
      // in a 433" (mig 1117) — the 7 has his own band right of center
      // (the 4-3-3's 10/8 height), the 11 stands alone up top; "balance
      // the 7 in between and ahead of the 9 and 8": with the midfield a
      // row of three, a two-column band (0 7) puts him exactly midway
      // between the 9 (center) and the 8.
      '3-5-2 (3-R2)':   { rows: [[1], [5, 6, 4], [3, 2], [10, 9, 8], [0, 7], [11]], wideIds: [3, 2], halfwayOn: 2 },
      // 3-L2 = the 3-R2 mirrored (owner 11/6: "the 11 just like on the R
      // one should be in traditional 10 position above and between ... and
      // others like it!"): every R/L shape drops its inside winger (7 for
      // R, 11 for L) into the hole ahead of the midfield, off-center to his
      // side, and the other stands alone up top as the striker. Four-
      // column bands (0 0 7 0 / 0 11 0 0) put him half a chip off center.
      '3-5-2 (3-L2)':   { rows: [[1], [5, 6, 4], [3, 2], [10, 9, 8], [11, 0], [7]], wideIds: [3, 2], halfwayOn: 2 },
      '3-5-2 (1-2-R2)': { rows: [[1], [5, 6, 4], [9], [3, 2], [10, 8], [0, 0, 7, 0], [11]], wideIds: [3, 2], halfwayOn: 3 },
      '3-5-2 (1-2-L2)': { rows: [[1], [5, 6, 4], [9], [3, 2], [10, 8], [0, 11, 0, 0], [7]], wideIds: [3, 2], halfwayOn: 3 },
      '3-5-2 (2-1-R2)': { rows: [[1], [5, 6, 4], [3, 2], [10, 8], [9], [0, 0, 7, 0], [11]], wideIds: [3, 2], halfwayOn: 2 },
      '3-5-2 (2-1-L2)': { rows: [[1], [5, 6, 4], [3, 2], [10, 8], [9], [0, 11, 0, 0], [7]], wideIds: [3, 2], halfwayOn: 2 },
      // Owner: "8 where a 6 would normally be and the 10 behind the 9
      // and in front of the 8 ... its really a 3313" — the 8-10-9
      // spine stacks like an American-football I formation. The 2 and
      // 3 stand ON the halfway line at the sidelines (owner: "for 3313
      // you can move 2 and 3 up the line mid line"), crest between them;
      // the 8 holds the base alone. `lifts` (row index → px, see
      // _pitchRows) nudges the 8 up toward the logo (owner: "push 8 up
      // a little in the 3313"). Renamed 3-4-3 (1-1-3) in the bowl family
      // (mig 1110): inside five 8 / 10 / 11 9 7.
      '3-4-3 (1-1-3)': { rows: [[1], [5, 6, 4], [8], [3, 2], [10], [11, 9, 7]], wideIds: [3, 2], halfwayOn: 3, lifts: { 2: 12 }, chipLifts: STRIKER_UP },
      // Match opponent (mig 912, formation_matchups): their shape flipped,
      // a libero added behind and one off our front line. Owner: "if we
      // play vs 4231 that actually looks like a 2323".
      '2-3-2-3': { rows: [[1], [5, 4], [3, 6, 2], [10, 8], [11, 9, 7]], chipLifts: STRIKER_UP },
      '2-4-1-3': { rows: [[1], [5, 4], [3, 6, 8, 2], [10], [11, 9, 7]], chipLifts: STRIKER_UP },
      '3-3-4':   { rows: [[1], [5, 6, 4], [3, 2], [8], [11, 10, 9, 7]], wideIds: [3, 2], halfwayOn: 2, chipLifts: STRIKERS_UP },
      '2-4-4':   { rows: [[1], [5, 4], [3, 6, 8, 2], [11, 10, 9, 7]], chipLifts: STRIKERS_UP },
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
  // PPR Indoor (owner 2026-11-04: "games are 5v5 (4v4 + keeper)") — the
  // indoor diamond: keeper, a 4 behind, 11 and 7 wide, 9 up top.
  5: {
    defaultFormation: '1-2-1',
    formations: {
      '1-2-1': { rows: [[1], [4], [11, 7], [9]] },
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

// Third sentinel, for one column rather than a row: a 0 in a FIELD_SIZES
// row is an empty column the width of a chip, so an asymmetric shape can
// hold a chip off-center (owner 2026-11-06: "can we put asymmetrical
// formations in?").  The card draws it as invisible space (token.gap).
const GAP_POS = Object.freeze({ gap: true });


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

// 🎯 Tactics (mig 1120) rides the same strip but is no post (owner 11/6:
// "needs be where the pills for game announce 20 man starters bench"):
// it swaps the graphic for the coach-drawn situations pitch.  11v11 with a
// formation only (pills()).
const TACTICS_PILL = { key: 'tactics', icon: '🎯', title: 'Tactics', accent: '#ef4444', social: 'closed' };
// 👥 All Players — EventScreen's list, first pill of every event (owner 11/11).
const PLAYERS_PILL = 'players';

// A game lands on ⚔️ Starters & Bench (owner 11/11: "games should default
// to starters and bench pill"); 👥 All Players is one tap away.
const DEFAULT_PILL = 'starters_bench';

// The game child of EventScreen (screens/event-screen.js — owner 2026-10-27:
// "base class is event … then game or practice child").  Opened by its event
// ({ event }, via EventKindSwitch.open) like every other kind; the match id
// it keys its lineup on comes from that event.  Inherits the live-refresh
// timer and the pill-row hook (pills()); keeps its own player cards, RSVP
// and invite tools until they fold into the base.
class GameCenterScreen extends EventScreen {
  // The base game; each game kind extends it (screens/game-center/
  // mens-game.js, youth-game.js — owner 11/18 "each extends game and adds or
  // hides").  STATE = this class's screen state; stateFor(ev) picks the kind
  // from the event's teams (teams[].section): Mens → MensGameScreen, Boys /
  // Girls → YouthGameScreen, anything else (Womens) → this base.
  static get STATE() { return 'game-center'; }
  static stateFor(ev) {
    const secs = new Set((Array.isArray(ev && ev.teams) ? ev.teams : []).map(t => t && t.section).filter(Boolean));
    if (secs.has('Mens') && window.MensGameScreen) return MensGameScreen.STATE;
    if ((secs.has('Boys') || secs.has('Girls')) && window.YouthGameScreen) return YouthGameScreen.STATE;
    return GameCenterScreen.STATE;
  }

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
    // Kids' games (teams.lineup_everyone_plays, mig 515): no bench — the
    // lineup is everyone whose game RSVP is Going, spread over the pitch
    // (owner 2026-10-03: "if 12 going show a 444 formation … just fake it
    // as the kids will be rotated for equal time").  Nothing is picked or
    // saved in this mode; see _everyoneShape.
    this.everyonePlays = false;
    this.matchStartsAt = null; // naive UTC-string date of this match, for the trailing "game" pill
    this.isCoach   = false;
    // Lineup drafts (mig 495): 'official' | 'draft:<personId>' | 'compare'.
    // realIsCoach is the account's true standing; isCoach is per view
    // (a drafter edits only their own draft, so isCoach flips with the view).
    this.lineupView = 'official';
    this.realIsCoach = false;
    this.canDraft = false;
    this.viewerPersonId = null;
    this.drafters = [];
    this.drafts = [];
    this.official = null;          // snapshot of the official maps + formation
    this.compareOnlyDiff = true;
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
    // Shared positions (mig 763): a bench player who comes on for a
    // starting position — playerId -> { pos, order } (order 2 = next in
    // after the starter).  splitSquad = draw starters as Squad A and
    // every 2nd as Squad B.
    this.shares        = new Map();
    this.splitSquad    = false;
    // 🎯 Tactics (mig 1120): coach-drawn situations for the formation on
    // screen, the day's lineup laid on them by position.  data = the
    // GET /api/formation-tactics/:id answer; draft = a coach's unsaved
    // copy of the situation being dragged.
    this._tactics = { formationId: 0, data: null, loading: false, error: null, idx: 0, editing: false, draft: null, msg: '' };
    // 🧠 Game model (mig 1121): jobs per ball position.  key = the four
    // query values the data answers; stateId = the state on screen;
    // draft = a coach's unsaved copy of it; playing = the animation runs.
    this._tacticsMode = 'plan';
    // The pitch's view (owner 11/7): ↕ upright / ↔ sideways — remembered per
    // browser — and ⛶ Big = the whole tactics panel full screen.
    this._tacticsView = { big: false, orientation: 'portrait' };
    try { if (localStorage.getItem('fh.tactics.orientation') === 'landscape') this._tacticsView.orientation = 'landscape'; } catch (e) { /* private mode */ }
    this._plan = { key: '', data: null, loading: false, error: null, oppFormationId: 0, moment: 'out_of_possession', block: 'high',
                   stateId: 0, editing: false, draft: null, msg: '', playing: false, speed: 1, popupPid: 0 };
    this._tacticsPitchObj = null;
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
    this.matchups = [];      // formation_matchups rows (mig 912)
    this.matchupId = null;   // the pick for this game, null = none
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
    // Per-player rows from GET /api/matches/:matchId/roster-players (see
    // _bootstrap) — the player id ↔ person id map the lineup cards use.
    this.players = [];        // [{playerId, personId, firstName, lastName, …}]
    this.reminders = {};      // person_id → {sms, email: {sent_at, count}} already sent about this game
    this.squadNotice = null;  // {squad, untold, sms: {sent_at}, email: {sent_at}} — the squad game reminder
    this.oppContacts = null;  // {club:{contacts}, tiers, date…} — the opponent of this game (mig 483)
    this.invites = null;      // {invites, candidates} — 🎟 Call-ups section (fh_event_invites, mig 355)
    this.regGaps = null;      // [{person_id, …, subject, body}] — Going, not on the official roster (mig 638)
    this.textMarks = null;    // {marks: {person_id: {game_link, reg_link}}, optedIn: Set} — club-number texts (mig 647)
    this.relay = null;        // FH Texter status for 📲 Text's fallback (mig 673)
    this._invBusy = new Set();   // person_ids with an invite POST/DELETE in flight
    this.officialRoster = null;  // {available, league, saved} — the league's own roster sheet for this game (mig 501)
    this.gameRecipients = null;  // [{personId, name, kind, rsvp, email, phone, viaParent}] — roster + call-ups + candidates (migs 506/600)
    // 🚗 Carpool (migs 601/608/609) — the shared CarpoolPanel component
    // (components/carpool-panel.js), also mounted by the Event Center for
    // practices, so the two screens can't drift.
    this.carpoolPanel = new CarpoolPanel(this.auth, {
      fhEventId: () => this._fhEventId(),
      rerender: () => this._render(),
      toast: (m) => this._toast(m),
      escapeHtml: (t) => this.escapeHtml(t),
      fold: (key, title, body) => this.panelFoldHtml(key, title, body),
    });
    // 🎯 Match plan (mig 966) — the match-day timeline from getting there to
    // kickoff, set pieces, tactics (components/match-plan-panel.js).
    this.matchPlanPanel = new MatchPlanPanel(this.auth, {
      fhEventId: () => this._fhEventId(),
      rerender: () => this._render(),
      toast: (m) => this._toast(m),
      escapeHtml: (t) => this.escapeHtml(t),
      squad: () => this._matchPlanSquad(),
    });
    this._rosterPull = null;     // {busy} | {error} while / after a pull
    this._oppAddOpen = false;
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
    const h = built ? (built.drawn || built.height) : 700;
    const w = (built && built.width) || 540;
    // The card carries everything (the explanation box: _buildRosterData legend).
    return `
      <div data-gc-card="${slot}" style="position:relative; width:100%; max-width:540px; margin:0 auto 12px; aspect-ratio:${w} / ${h}; overflow:hidden; box-shadow:0 10px 34px rgba(0,0,0,0.35);">
        <div data-gc-card-inner style="position:absolute; left:0; top:0; width:${w}px; transform-origin:0 0;">${built ? built.html : ''}</div>
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
    const cardW = (st.built && st.built.width) || 540;
    // The host always takes the height the card actually draws at — late
    // crests/photos or a longer bench grow it after the first measure.
    const fit = () => {
      if (!inner) return;
      const drawn = inner.firstElementChild ? inner.firstElementChild.offsetHeight : 0;
      if (drawn > 0 && st.built && st.built.drawn !== drawn) {
        st.built.drawn = drawn;
        host.style.aspectRatio = `${cardW} / ${drawn}`;
      }
      if (host.clientWidth) inner.style.transform = `scale(${host.clientWidth / cardW})`;
    };
    fit();
    if (typeof ResizeObserver !== 'undefined') {
      st.resizeObs = new ResizeObserver(fit);
      st.resizeObs.observe(host);
      if (inner && inner.firstElementChild) st.resizeObs.observe(inner.firstElementChild);
    }

    const beam = host.querySelector('[data-gc-card-beam]');
    if (!beam || !st.built || typeof window.LighthouseBeam === 'undefined') return;
    // Same canvas geometry and rotation period as SocialPostCard's
    // startAnimatedPreview, so the beam sits where the posted clip has it.
    beam.width = cardW * 2;
    beam.height = (st.built.drawn || st.built.height) * 2;
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
      // Keep the measured height when nothing changed — dropping it made
      // the next lineup tap repaint at the minimum height and clip the
      // bottom of the card (owner 2026-11-13 "it needs to always show all").
      const keepDrawn = !changed && st.built ? st.built.drawn : undefined;
      st.built = { key, html: built.html, width: built.width, height: built.height, drawn: keepDrawn };
      if (!changed) return;
      const host = this.element && this.element.querySelector(`[data-gc-card="${slot}"]`);
      if (!host) return;
      host.style.aspectRatio = `${built.width || 540} / ${built.height}`;
      const inner = host.querySelector('[data-gc-card-inner]');
      inner.style.width = `${built.width || 540}px`;
      inner.innerHTML = built.html;
      // The live card grows to fit its notes (SocialPostCard live: height
      // is a minimum, not a clip — it never goes to Instagram), so the
      // host takes the height the card actually drew at.
      const drawn = inner.firstElementChild ? inner.firstElementChild.offsetHeight : 0;
      if (drawn > 0) { st.built.drawn = drawn; host.style.aspectRatio = `${built.width || 540} / ${drawn}`; }
      this._fitCard(slot);
    } catch (err) {
      console.warn('[game-center] card build failed:', err);
    }
  }

  // "Post to Instagram", straight under the card it publishes. Opens the
  // publish panel (#gc-social) for the active pill right there — caption,
  // photo/video, schedule, "Post live". Only the roles that may publish
  // see it, so a player just gets the pills and the card.
  // Staff: the button sits hidden and ☰ lists it like the pills and chips
  // (EventScreen._menuNavHtml — owner 11/18 staff event pages, piece by
  // piece: the graphic is the page; every other button lives in ☰).
  _postButtonHtml() {
    if (!this._canPostSocial() || !this.matchId || !this.teamId) return '';
    return this._menuNavHtml(`
      <div style="max-width:540px; margin:12px auto;">
        <button type="button" id="gc-post-insta" data-gc-post-insta="1" class="btn ${this._bottomOpen ? 'btn-secondary' : 'btn-primary'}" style="width:100%; font-weight:700; padding:10px 12px;">
          ${this._bottomOpen ? '▾ Hide' : '📸 Post to Instagram —'} ${this.escapeHtml(this._pillTitle(this.pill))}${this._bottomOpen ? ' post' : ''}
        </button>
      </div>`);
  }

  render() {
    const el = document.createElement('div');
    // screen-game-lineup class kept — css/ still targets it, and the
    // stylesheet rename is not worth coupling to this change.
    el.className = 'screen screen-game-lineup screen-game-center';
    el.innerHTML = `
      <style>
        .screen-game-center .ec-att { width:26px; height:26px; padding:0; border-radius:50%; line-height:1; font-size:0.75rem; font-weight:800; cursor:pointer; }
        .screen-game-center .ec-att[disabled] { opacity:0.5; cursor:wait; }
      </style>
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

  // The game as the coach left it — which game (the in-screen switcher
  // changes it without a navigation), pill, and open folds — for
  // Navigation.rememberForReturn, so a phone reload after a REMIND text
  // reopens it as it was.
  resumeState() {
    return {
      matchId: this.matchId, title: this.title, when: this.when, view: this.view,
      postType: this.pill, folds: [...this.folds], invOpen: !!this._invOpen,
    };
  }

  onEnter(params = {}) {
    // The event door (EventKindSwitch.open): the match id, title and time
    // come from the event; the event itself is this.ev, as on every
    // EventScreen.  Older doors pass matchId alone — the feed fills this.ev.
    if (params.event && params.event.match_id != null) {
      params = { ...params, matchId: params.event.match_id,
                 title: params.title || EventLabels.title(params.event), when: params.when || EventLabels.when(params.event) };
    }
    this.ev = params.event || null;
    if (params.resume) {
      const r = params.resume;
      this.folds = new Map(Array.isArray(r.folds) ? r.folds.filter(Array.isArray) : []);   // [key, open] pairs (EventScreen.foldOpen)
      this._invOpen = !!r.invOpen;
      params = r.matchId != null
        ? { matchId: r.matchId, title: r.title || '', when: r.when || '', view: r.view || undefined, postType: r.postType }
        : { pick: true };
    }
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
    const nextMatchId = rawMatchId != null ? Number(rawMatchId) : null;
    // Another game: the 📇 opponent message starts back on that game's
    // confirmation, not whatever the last game was left on (mig 803).
    if (nextMatchId !== this.matchId) { this._oppTier = 'confirm'; this._oppMsg = ''; }
    this.matchId = nextMatchId;
    this.title   = params.pick ? '' : (params.title || ctxMatch?.title || '');
    this.when    = params.when || '';
    // params.view === 'player' — the #my door.  Owner 2026-09-17: "the my
    // page should be player view for admin and coaches too. so its not
    // confusing."  My is where you look at the lineup; the top-level
    // Game Center is where staff set it.
    this.playerOnly = params.view === 'player';
    this.view = params.view || null;
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
    this._startLivePoll();
  }

  // postType is the deep link ("open Game Center on the Match Result
  // pill"); mode==='gameday' is the older my.js / team-dashboard
  // "Game Day Roster" entry point, which is the 20-Man Squad pill under
  // its new name. Anything unrecognized lands on the default rather
  // than rendering a blank body.
  _resolvePill(params) {
    // #event/<id>/<pill> (EventKindSwitch) names it pill; older doors postType.
    if (params.pill && (POST_PILLS.some(p => p.key === params.pill) || params.pill === TACTICS_PILL.key || params.pill === PLAYERS_PILL)) return params.pill;
    // #game-center/<id>/<pill> (app.js) hands the pill over as postType, 🎯 too.
    if (params.postType && (POST_PILLS.some(p => p.key === params.postType) || params.postType === TACTICS_PILL.key)) return params.postType;
    if (params.mode === 'gameday') return 'lineup';
    return DEFAULT_PILL;
  }

  // Switching pills is a sub-view change, not a navigation: the URL is
  // the one every opened event has, #event/<fh_event_id>/<pill>
  // (EventKindSwitch.syncHash — replaceState, so Back still leaves the
  // game).  A game the feed hasn't matched to its event yet keeps the
  // old #game-center/<matchId>/<pill>, which app.js still opens.
  _syncHash() {
    if (!this.matchId) return;
    if (this.ev && this.ev.fh_event_id != null) { EventKindSwitch.syncHash(this.navigation, this.ev, this.pill); return; }
    try {
      window.history.replaceState(window.history.state, '', `#game-center/${this.matchId}/${this.pill}`);
    } catch (err) {
      console.warn('[game-center] hash sync failed (non-fatal):', err);
    }
  }

  onExit() {
    this._stopLivePoll();
    if (this._saveTimer) { clearTimeout(this._saveTimer); this._saveTimer = null; }
    // The beam's rAF loop and its ResizeObserver both hold the detached
    // canvas alive otherwise — this screen instance is reused across
    // navigations, so a leaked loop per visit would stack up.
    this._stopCards();
    this.socialCard = null;
    this._socialMountedFor = null;
    if (this._planRaf) { cancelAnimationFrame(this._planRaf); this._planRaf = null; }
    this._plan.playing = false;
    this._tacticsBigOff();
    this._closeSwapSheet();
  }

  // ── Live RSVP poll ───────────────────────────────────────────────────
  // RSVPs land from phones while this page sits open, so the screen
  // re-checks the game every 15s. On a change it applies the payload it
  // already fetched straight to state and repaints with the same cheap
  // _render() every zone toggle uses — NOT _bootstrap(), whose full
  // fetch-everything reload reads as a page refresh (owner 2026-10-19:
  // "i don't like how page refreshes … after i send email invite").
  // Your own actions update state locally first, so the tick after one
  // repaints pixel-identical content — invisible. 15s is human-RSVP
  // speed; the lineup GET is a few indexed queries against the local DB,
  // so even a dozen open tabs is noise. The poll never fires into an
  // edit — a pending autosave, the details overlay, the swap sheet, a
  // draft view, or any focused field postpones it to a later tick rather
  // than re-rendering the DOM out from under the coach.
  // _startLivePoll / _stopLivePoll: EventScreen's 15 s timer, which calls
  // the _pollLive below.

  // One string per game state: lineup zones + roster RSVPs + call-up
  // answers. Only these fields — anything volatile (stats, timestamps)
  // would make every poll look like a change.
  _liveFp(lineupRows, statsRows, invites) {
    const l = (lineupRows || []).map(r => [Number(r.playerId), r.zone || null, r.positionId ?? null, r.slotNumber ?? null, r.sharesPositionId ?? null, r.shareOrder ?? null]).sort((a, b) => a[0] - b[0]);
    const s = (statsRows || []).map(r => [Number(r.playerId), r.gameRsvp ?? null]).sort((a, b) => a[0] - b[0]);
    const i = ((invites && invites.invites) || []).map(v => [Number(v.person_id), v.response ?? null]).sort((a, b) => a[0] - b[0]);
    return JSON.stringify([l, s, i]);
  }

  async _pollLive() {
    if (document.hidden || !this.matchId || !this.loaded || this.error || this._pollBusy) return;
    if (this._liveFpLast == null) return;   // no baseline yet — bootstrap sets it
    // Never refresh into an edit — catch up on a later tick instead.
    if (this._saveTimer || this.announceEditing || this._draftEdit || this._tactics.editing || this._plan.editing || this._plan.playing) return;
    if (document.activeElement && document.activeElement.matches && document.activeElement.matches('[data-gc-opp-msg]')) return;
    if (this._isDraftView()) return;
    if (document.getElementById('gc-swap-sheet')) return;
    const focused = document.activeElement;
    if (focused && this.element && this.element.contains(focused)
        && /^(INPUT|TEXTAREA|SELECT)$/.test(focused.tagName)) return;

    this._pollBusy = true;
    const matchId = this.matchId;
    try {
      const fhEventId = this._isCoach ? this._fhEventId() : null;
      // The game's event row too (RSVPs, late/leaving chips) — the same
      // beat EventScreen keeps on a practice, so 👥 All Players moves live.
      const [lineupRes, invitesRes, evChanged] = await Promise.all([
        this.auth.fetch(`/api/eligibility/lineup/${matchId}`),
        fhEventId
          ? this.auth.fetch(`/api/calendar/events/${fhEventId}/invites`).catch(() => null)
          : Promise.resolve(null),
        this._refreshEvent(),
      ]);
      if (evChanged && matchId === this.matchId) this._render();
      const lineupData = await lineupRes.json().catch(() => null);
      if (!lineupData || !lineupData.success) {
        this._dbState = 'syncfail';
        this._paintDbStrip();
        return;
      }
      // A quiet tick is still a successful DB sync — the strip's green
      // stamp moves even when nothing changed.
      this._dbSyncAt = new Date();
      if (this._dbState === 'syncfail') this._dbState = 'ok';
      this._paintDbStrip();
      const invData = invitesRes && invitesRes.ok ? await invitesRes.json().catch(() => null) : null;
      const fp = this._liveFp(
        lineupData.data.lineup, lineupData.data.rosterStats,
        invData ? { invites: invData.invites || [] } : this.invites);
      // The screen may have moved on, or an edit begun, while the fetch
      // was in flight — a lineup PUT racing this GET must win.
      if (!this._pollTimer || matchId !== this.matchId) return;
      if (this._saveTimer || this._savingLineup) return;
      if (fp !== this._liveFpLast) {
        this._liveFpLast = fp;
        this._applyLiveData(lineupData.data, invData);
      }
    } catch (err) {
      // A network blip just means the next tick retries — but the strip
      // goes red so nobody trusts a stale board (owner 2026-10-21).
      this._dbState = 'syncfail';
      this._paintDbStrip();
    } finally {
      this._pollBusy = false;
    }
  }

  // ── DB-truth status strip (mig 626) ──────────────────────────────────
  // "Last change <stamp> · DB ✓ <synced>" — the stamp is the SERVER's
  // match_lineup_metadata.updated_at, never local state; 🟡 while a save
  // is in flight, red when a save or sync failed (with the reason).
  // Players get it too: at a glance, has the lineup moved since I looked?
  _dbStripHtml() {
    const esc = (t) => this.escapeHtml(t);
    const copy = (tier, tokens) => (window.MessageCopy && MessageCopy.has && MessageCopy.has('lineup_status', tier))
      ? MessageCopy.block('lineup_status', tier, tokens) : '';
    const changed = this.lineupChangedAt
      ? (copy('last_change', { when: this.lineupChangedAt }) || `Last change ${this.lineupChangedAt}`)
      : (copy('no_change', {}) || 'No lineup saved yet');
    const state = this._dbState || 'ok';
    const color = state === 'saving' ? '#f59e0b' : state === 'ok' ? '#4ade80' : '#f87171';
    const syncT = this._dbSyncAt
      ? this._dbSyncAt.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit', second: '2-digit' }) : '—';
    const label = state === 'saving' ? (copy('saving', {}) || 'saving…')
      : state === 'savefail' ? (copy('save_fail', { when: this.lineupChangedAt || '—', reason: this._dbFailMsg || '' })
                                || `NOT SAVED — the board still shows ${this.lineupChangedAt || '—'}. ${this._dbFailMsg || ''}`)
      : state === 'syncfail' ? (copy('sync_fail', {}) || 'sync failed — retrying')
      : (copy('synced', { when: syncT }) || `DB ✓ ${syncT}`);
    return `<div data-db-strip style="font-size:0.72rem; font-weight:700; margin:4px 0 6px; color:${color};">
      <span style="opacity:0.85;">${esc(changed)}</span> · <span>${esc(label)}</span></div>`;
  }

  _paintDbStrip() {
    if (!this.element) return;
    const els = this.element.querySelectorAll('[data-db-strip]');
    if (!els.length) return;
    const fresh = this._dbStripHtml();
    els.forEach(el => { el.outerHTML = fresh; });
  }

  // A remote change, applied the way a local tap is: overwrite the bits
  // of state the poll fetched, then one in-place repaint. No network, no
  // "Loading…" pass, no card teardown.
  _applyLiveData(data, invData) {
    if (data.lineupChangedAt !== undefined) this.lineupChangedAt = data.lineupChangedAt;
    this.zones = new Map();
    this.positions = new Map();
    this.benchOrder = new Map();
    this.shares = new Map();
    for (const row of (data.lineup || [])) {
      if (row.zone && row.zone !== 'not_selected') {
        this.zones.set(Number(row.playerId), row.zone);
      }
      if (row.zone === 'starter' && row.positionId != null) {
        this.positions.set(Number(row.playerId), Number(row.positionId));
      }
      if (row.zone === 'bench' && row.slotNumber != null) {
        this.benchOrder.set(Number(row.playerId), Number(row.slotNumber));
      }
      if (row.zone === 'bench' && row.sharesPositionId != null && row.shareOrder != null) {
        this.shares.set(Number(row.playerId), { pos: Number(row.sharesPositionId), order: Number(row.shareOrder) });
      }
    }
    if (data.splitSquad !== undefined) this.splitSquad = !!data.splitSquad;
    this.official = this._snapshot();
    this.stats = new Map();
    for (const row of (data.rosterStats || [])) {
      this.stats.set(Number(row.playerId), row);
    }
    if (invData) {
      this.invites = { invites: invData.invites || [], candidates: invData.candidates || [], caps: invData.caps || [], suspended: invData.suspended || [] };
      this._foldInCallups();
    }
    this._render();
    // An RSVP change can open or close a registration gap (mig 638).
    if (this.realIsCoach) this._loadRegGaps().then(() => this._render()).catch(() => {});
    // Delivery reports land within seconds of a club text (mig 647).
    if (this._isCoach) this._loadTextMarks().then(() => this._render()).catch(() => {});
  }

  // Same admin-only gate my.js uses for the "Post to Instagram" button on
  // the schedule card (SocialController.cpp's requireAdminLevel({"club",
  // "super","marketing"}) is the real backend rule this mirrors), plus
  // the same "view as <player>" suppression — this screen is reachable
  // by players directly, and impersonation only rewrites data fetches,
  // never navigation.context.user.role.
  // Posting tools on show: may post AND not 👀 seeing as a player.
  _canPostSocial() { return this._mayPostSocial() && this.viewMode !== 'player'; }

  // May this account post (role)?  Loads ask this so the data is there
  // when a coach comes back from 👀 See as player.
  _mayPostSocial() {
    if (this.auth && this.auth.viewAsPersonId) return false;
    if (this.playerOnly) return false;   // the #my door is look-only
    const role = (this.navigation?.context?.user?.role || '').toString().toLowerCase();
    return ['club', 'super', 'marketing'].includes(role);
  }

  // A name on the live card → the ONE player sheet (📇 Contact, remind,
  // Activity …), for the viewers EventScreen._cardTapAttr lets tap (owner
  // 11/20 "i can't click suhaylah and angel to remind them!" → "all names
  // need to be cickable" → "we need access to their player profile with
  // standard interface").  null = no tap (the post, a player's view).
  _cardTapPerson(playerId) {
    if (!this.viewer || !this.viewer.canMark()) return null;
    return this._personIdFor(playerId) || null;
  }

  _wire() {
    if (this._wired) return;
    this._wired = true;
    // 👥 All Players folds stay as the coach left them (EventScreen's
    // capture-phase toggle — toggle does not bubble).
    this.element.addEventListener('toggle', (e) => {
      const d = e.target.matches && e.target.matches('[data-ec-fold]') ? e.target : null;   // that fold only, never a parent
      if (d) this.folds.set(d.dataset.ecFold, d.open);
    }, true);
    this.element.addEventListener('click', (e) => {
      if (this._sheetClick(e)) return;   // ⋯ on a card → the shared player sheet
      // A name on the card → the player sheet (SocialPostCard._tapAttr).
      const tapPerson = e.target.closest('[data-ec-tap-person]');
      if (tapPerson) { this._openPersonSheet(Number(tapPerson.dataset.ecTapPerson)); return; }
      // 📇 CONTACT on the card and its group 💬 / ✉ (EventScreen._contactPillHtml).
      const contactPill = e.target.closest('[data-ec-contact-pill]');
      if (contactPill) { this._contactOpen = !this._contactOpen; this._render(); return; }
      const groupMsg = e.target.closest('[data-ec-group-msg]');
      if (groupMsg) { this._onGroupMessage(groupMsg); return; }
      const mpBtn = e.target.closest('[data-mp-save]');
      if (mpBtn) { this.matchPlanPanel.click(mpBtn); return; }
      // ✅ Attendance P/A/L/E on a game card (EventScreen._attendanceCell).
      const attBtn = e.target.closest('[data-ec-att]');
      if (attBtn) { this._markAttendance(Number(attBtn.dataset.personId), attBtn.dataset.ecAtt, attBtn.dataset.active === '1'); return; }
      // Lineup version bar (Official | My draft | … | Compare) and Make official are buttons: click, not change.
      const viewBtn = e.target.closest('[data-lineup-view]');
      if (viewBtn) { this._applyView(viewBtn.getAttribute('data-lineup-view')); return; }
      if (e.target.closest('#gl-make-official')) { this._makeOfficial(); return; }
      // 👀 See as (EventScreen._seeAsHtml, slice 5): one bar on every pill
      // in place of Game Center's own Player View toggle.
      const seeAsBtn = e.target.closest('[data-ec-see-as]');
      if (seeAsBtn) { this.seeAs = seeAsBtn.dataset.ecSeeAs || null; this._render(); return; }
      const postBtn = e.target.closest('[data-ec-post]');
      if (postBtn) { this._onPostAction(postBtn); return; }
      const remindOne = e.target.closest('[data-gc-remind]');
      if (remindOne && this.isCoach && !remindOne.disabled) { this._remindPlayer(remindOne); return; }
      const availBtn = e.target.closest('[data-gc-avail]');
      if (availBtn && !availBtn.disabled) { this._setMyAvailability(availBtn); return; }
      const eligBtn = e.target.closest('[data-elig-rsvp]');
      if (eligBtn && !eligBtn.disabled) { this._setEligibilityRsvp(eligBtn); return; }
      const why = e.target.closest('[data-gc-why]');
      if (why) {
        const note = why.closest('[data-gc-contact]')?.querySelector('[data-gc-squad-note]');
        if (note) note.innerHTML = `<span style="color:#fbbf24; font-weight:700;">${this.escapeHtml(why.dataset.gcWhy)}</span>`;
        return;
      }
      const fixReg = e.target.closest('[data-gc-fix-reg]');
      if (fixReg && this.isCoach) { this._gcContactOpen(Number(fixReg.dataset.gcFixReg), 'reg'); return; }
      const duesNote = e.target.closest('[data-gc-dues-note]');
      if (duesNote && this.isCoach) { this._gcContactOpen(Number(duesNote.dataset.gcDuesNote), 'dues'); return; }
      const jump = e.target.closest('[data-gc-jump]');
      if (jump) {
        const card = this.element.querySelector(`#gc-card-${jump.dataset.gcJump}`);
        if (card) {
          card.closest('details')?.setAttribute('open', '');
          card.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
        return;
      }
      const contactOpen = e.target.closest('[data-gc-contact-open]');
      if (contactOpen && this.isCoach) { this._openContactSheet(Number(contactOpen.dataset.gcContactOpen)); return; }
      const groupWho = e.target.closest('[data-gc-group-who]');
      if (groupWho) { this._groupWho = groupWho.dataset.gcGroupWho; this._render(); return; }
      const clubText = e.target.closest('[data-gc-club-text]');
      if (clubText && this.isCoach && !clubText.disabled) { this._sendClubText(clubText); return; }
      const squadOne = e.target.closest('[data-gc-squad-one]');
      if (squadOne && this.isCoach && !squadOne.disabled) { this._sendSquadNoticeOne(squadOne); return; }
      const squadBtn = e.target.closest('[data-gc-squad-notice]');
      if (squadBtn && this.isCoach && !squadBtn.disabled) { this._sendSquadNotice(squadBtn); return; }
      const remindAll = e.target.closest('[data-gc-remind-all]');
      if (remindAll && this.isCoach && !remindAll.disabled) { this._remindNoResponse(remindAll); return; }
      // 🎟 Everyone / <team> Official pill (mig 1174).
      const invPill = e.target.closest('[data-gc-inv-pill]');
      if (invPill && this.realIsCoach) { this._invPill = { ev: this._fhEventId(), key: invPill.dataset.gcInvPill }; this._invOpen = true; this._render(); return; }
      const invRevoke = e.target.closest('[data-gc-inv-revoke]');
      if (invRevoke && this.realIsCoach && !invRevoke.disabled) { this._revokeInvite(invRevoke); return; }
      const autoInv = e.target.closest('[data-gc-auto-inv]');
      if (autoInv && this.realIsCoach && !autoInv.disabled) { this._setAutoInvite(autoInv); return; }
      const oppSend = e.target.closest('[data-gc-opp-send]');
      if (oppSend && this.isCoach && !oppSend.disabled) { this._sendToOpponent(oppSend); return; }
      const oppSendAll = e.target.closest('[data-gc-opp-send-all]');
      if (oppSendAll && this.isCoach && !oppSendAll.disabled) { this._sendToOpponentAll(oppSendAll); return; }
      const bigDraft = e.target.closest('[data-gc-draft-open]');
      if (bigDraft && this.isCoach) { this._panelDraftOpen(Number(bigDraft.dataset.gcDraftOpen)); return; }
      const draftBtn = e.target.closest('[data-gc-draft-toggle], [data-gc-draft-new], [data-gc-draft-edit], [data-gc-draft-cancel], [data-gc-draft-save], [data-gc-draft-send], [data-gc-draft-delete], [data-gc-draft-unrec]');
      if (draftBtn && this.isCoach && !draftBtn.disabled) { this._draftClick(draftBtn); return; }
      const oppAdd = e.target.closest('[data-gc-opp-add]');
      if (oppAdd && this.isCoach) { this._oppAddOpen = !this._oppAddOpen; this._render(); return; }
      const oppSave = e.target.closest('[data-gc-opp-save]');
      if (oppSave && this.isCoach) { this._saveOpponentContact(oppSave); return; }
      const askRes = e.target.closest('[data-gc-ask-reserves]');
      if (askRes && this.realIsCoach) { this._askReserves(askRes.dataset.gcAskReserves); return; }
      const msgBtn = e.target.closest('[data-gc-msg-kind]');
      if (msgBtn && this.realIsCoach && !msgBtn.disabled) { this._messageGame(msgBtn); return; }
      const sheetBtn = e.target.closest('[data-gc-roster-sheet]');
      if (sheetBtn && !sheetBtn.disabled) { this._printRosterSheet(sheetBtn); return; }
      const rosterPull = e.target.closest('[data-gc-roster-pull]');
      if (rosterPull && !rosterPull.disabled) { this._printOfficialRoster(true); return; }
      const rosterOpen = e.target.closest('[data-gc-roster-open]');
      if (rosterOpen && !rosterOpen.disabled) { this._printOfficialRoster(false); return; }
      const oppPage = e.target.closest('[data-gc-opp-page]');
      if (oppPage) { this.navigation.goTo('opponents', { clubId: Number(oppPage.dataset.gcOppPage) || 0, matchId: Number(this.matchId) || 0 }); return; }
      // 🚗 Carpool (mig 601) — everyone on the game, not just coaches.
      const cpBtn = e.target.closest('[data-gc-cp]');
      if (cpBtn && !cpBtn.disabled) { this._carpoolClick(cpBtn); return; }
      // The Instagram section. Its pill strip flips between the posts
      // without touching the page above; nothing picked means no
      // SocialPostCard is mounted, which is also what defers that
      // component's four API calls until they're wanted.
      if (e.target.closest('#gc-post-insta')) {
        this._bottomOpen = !this._bottomOpen;
        this._render();
        // Opened from ☰ there is no button on screen to look at — bring
        // the publish panel into view.
        if (this._bottomOpen) requestAnimationFrame(() => { const m = this.find('#gc-social'); if (m) m.scrollIntoView({ behavior: 'smooth', block: 'start' }); });
        return;
      }
      // 👥 All Players pane: EventScreen's own buttons (P/A/L/E, ✓/✗,
      // remind, 📇, call-in, mark all present).
      if (e.target.closest('[data-gc-players-pane]') && this._playersPaneClick((sel) => e.target.closest(sel))) return;
      const socialPillBtn = e.target.closest('[data-gc-social-pill]');
      if (socialPillBtn) {
        const key = socialPillBtn.getAttribute('data-gc-social-pill');
        if (POST_PILLS.some(p => p.key === key) || key === TACTICS_PILL.key || key === PLAYERS_PILL) {
          if (key !== this.pill) {
            this.pill = key;
            this._syncHash();
            this._render();
          }
        }
        return;
      }
      // 👥 on the 20-Man Squad pill: the game's 👥 All Players (the one RSVP
      // list every event has — the old RSVP & Player Details sheet wrote to
      // an endpoint retired in July and was deleted 11/16).
      if (e.target.closest('#gc-details-open')) { this.pill = PLAYERS_PILL; this._syncHash(); this._render(); return; }

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

      const zoneBtn = e.target.closest('[data-lineup-zone-btn]');
      if (zoneBtn && this.isCoach) {
        const playerId = Number(zoneBtn.getAttribute('data-player-id'));
        const zone = zoneBtn.getAttribute('data-lineup-zone-btn');
        this._toggleZone(playerId, zone);
        return;
      }
      if (e.target.closest('[data-gc-split]') && this.isCoach) { this._toggleSplitSquad(); return; }
      const sitPill = e.target.closest('[data-gc-tactics-sit]');
      if (sitPill && !this._tactics.editing) { this._tactics.idx = Number(sitPill.dataset.gcTacticsSit) || 0; this._tactics.msg = ''; this._render(); return; }
      if (e.target.closest('[data-gc-tactics-edit]') && this._tacticsCanEdit()) { this._startTacticsEdit(); return; }
      if (e.target.closest('[data-gc-tactics-cancel]')) { this._tactics.editing = false; this._tactics.draft = null; this._render(); return; }
      if (e.target.closest('[data-gc-tactics-save]') && this._tacticsCanEdit()) { this._saveTactics(); return; }
      const tMode = e.target.closest('[data-gc-tactics-mode]');
      if (tMode) { this._stopPlanPlay(); this._tacticsMode = tMode.dataset.gcTacticsMode; this._render(); return; }
      const tOrient = e.target.closest('[data-gc-tactics-orient]');
      if (tOrient) {
        this._stopPlanPlay();
        this._tacticsView.orientation = tOrient.dataset.gcTacticsOrient === 'landscape' ? 'landscape' : 'portrait';
        try { localStorage.setItem('fh.tactics.orientation', this._tacticsView.orientation); } catch (err) { /* private mode */ }
        this._render();
        return;
      }
      if (e.target.closest('[data-gc-tactics-big]')) { this._setTacticsBig(!this._tacticsView.big); return; }
      if (e.target.matches('[data-gc-tp-popup-bg]') || e.target.closest('[data-gc-tp-popup-x]')) { this._plan.popupPid = 0; this._render(); return; }
      const tpState = e.target.closest('[data-gc-tp-state]');
      if (tpState && !this._plan.editing) { this._stopPlanPlay(); this._plan.stateId = Number(tpState.dataset.gcTpState); this._plan.msg = ''; this._render(); return; }
      if (e.target.closest('[data-gc-tp-create]') && this._tacticsCanEdit()) { this._createPlan(); return; }
      const tpPass = e.target.closest('[data-gc-tp-pass]');
      if (tpPass && !this._plan.editing && !this._plan.playing) {
        const cur = this._planState(this._plan.stateId) || this._planStates()[0];
        const n = Number(tpPass.dataset.gcTpPass);
        const kid = cur && this._planStates().find(st => st.parent_state_id === cur.id && Number(st.ball_with) === n);
        if (kid) { this._plan.stateId = kid.id; this._plan.msg = ''; this._render(); }
        else if (cur && this._tacticsCanEdit()) this._addPlanState(cur.id, n);
        return;
      }
      const star = e.target.closest('[data-gc-tp-shortcut]');
      if (star && this._tacticsCanEdit()) { this._togglePlanShortcut(star.dataset.gcTpShortcut, star.dataset.on !== '1'); return; }
      const tgt = e.target.closest('[data-gc-tp-tgt]');
      if (tgt && this._tacticsCanEdit()) { this._editPlanJob(Number(tgt.dataset.gcTpTgt), 'toggle', tgt.dataset.n); return; }
      if (e.target.closest('[data-gc-tp-edit]') && this._tacticsCanEdit()) { this._startPlanEdit(); return; }
      if (e.target.closest('[data-gc-tp-cancel]')) { this._plan.editing = false; this._plan.draft = null; this._render(); return; }
      if (e.target.closest('[data-gc-tp-save]') && this._tacticsCanEdit()) { this._savePlanState(); return; }
      if (e.target.closest('[data-gc-tp-delete]') && this._tacticsCanEdit()) { this._deletePlanState(); return; }
      if (e.target.closest('[data-gc-tp-play]')) { if (this._plan.playing) this._stopPlanPlay(); else this._playPlan(); return; }
      const fillBtn = e.target.closest('[data-gc-split-fill]');
      if (fillBtn && this.isCoach) { this._fillSecondSpots(); this._render(); this._scheduleSave(); return; }
      const statsToggle = e.target.closest('#gl-stats-toggle');
      if (statsToggle && this.isCoach) {
        this.showLineupStats = !this.showLineupStats;
        this._render();
        return;
      }
      // Current Lineup card — a filled pitch chip or a bench name opens
      // the move sheet (2026-09-26, owner: "popup to move them. have pos
      // grid show and bench and alt and unassign button").  Before that
      // the tap unassigned them outright (2026-08-22); that is still the
      // fallback while the copy rows have not loaded.
      // A bench name first: a 2nd/3rd under a starter (mig 763) sits
      // INSIDE the starter's chip, so it must win over the chip.
      const moveBench = e.target.closest('[data-lineup-remove-bench]');
      if (moveBench && this.isCoach) {
        const playerId = Number(moveBench.getAttribute('data-lineup-remove-bench'));
        if (!this._openMoveSheet(playerId)) this._toggleZone(playerId, 'bench');
        return;
      }
      // An empty spot on the live card → who plays here (_openFillSheet).
      const fillPos = e.target.closest('[data-lineup-fill-pos]');
      if (fillPos && this.isCoach) { this._openFillSheet(Number(fillPos.getAttribute('data-lineup-fill-pos'))); return; }
      const moveStarter = e.target.closest('[data-lineup-remove-starter]');
      if (moveStarter && this.isCoach) {
        const playerId = Number(moveStarter.getAttribute('data-lineup-remove-starter'));
        if (!this._openMoveSheet(playerId)) this._setPosition(playerId, null);
        return;
      }
      // 1-11 position pills (2026-08-22, owner directive) — a slot
      // already taken by someone else just renders greyed out (see
      // positionPills below), it's not disabled: clicking it asks what
      // to do with whoever's there (_openPositionSheet, 2026-09-26).
      // Clicking your OWN active pill removes you instead of replacing
      // yourself.
      const posBtn = e.target.closest('[data-lineup-position-btn]');
      if (posBtn && this.isCoach) {
        const playerId = Number(posBtn.getAttribute('data-player-id'));
        const positionId = Number(posBtn.getAttribute('data-lineup-position-btn'));
        const isMine = this.positions.get(playerId) === positionId;
        if (isMine) { this._setPosition(playerId, null); return; }
        const holderId = this._holderOf(positionId);
        if (holderId != null && holderId !== playerId && this._openPositionSheet(playerId, positionId, holderId)) return;
        this._setPosition(playerId, positionId);
        return;
      }
    });
    // Keep the 🎟 Call-ups details open across the re-render an invite
    // triggers ('toggle' doesn't bubble — capture phase).
    this.element.addEventListener('toggle', (e) => {
      if (e.target && e.target.hasAttribute && e.target.hasAttribute('data-gc-inv-details')) this._invOpen = e.target.open;
      if (e.target && e.target.hasAttribute && e.target.hasAttribute('data-mp-fold')) this.matchPlanPanel.toggle(e.target);
    }, true);
    this.element.addEventListener('change', (e) => {
      // 🎯 Match plan picks and checklist ticks (mig 966).
      if (e.target.matches('[data-mp-pick], [data-mp-tick]')) { this.matchPlanPanel.input(e.target); return; }
      // 📝 draft To: ＋ add (mig 726).
      if (e.target.matches('[data-gc-draft-addrec]') && this._draftEdit) {
        const id = Number(e.target.value); if (!id) return;
        const o = this.oppContacts || {};
        const c = [...(((o.club || {}).contacts) || []), ...(((o.league || {}).contacts) || [])].find(x => x.id === id);
        this._draftReadForm();
        if (c) this._draftEdit.recipients = [...(this._draftEdit.recipients || []), { id: c.id, name: c.name, email: c.email }];
        this._render(); return;
      }
      const cpBehalf = e.target.closest('[data-gc-cp-behalf]');
      if (cpBehalf) { this.carpoolPanel.behalf(cpBehalf.value); return; }
      const cpDep = e.target.closest('[data-gc-cp-dep-add]');
      if (cpDep) { this.carpoolPanel.departureAdd(cpDep.dataset.gcCpDepAdd, cpDep.value); return; }
      const benchSelect = e.target.closest('[data-lineup-bench-order-select]');
      if (benchSelect && this.isCoach) {
        const playerId = Number(benchSelect.getAttribute('data-player-id'));
        const order = Number(benchSelect.value);
        this._setBenchOrder(playerId, order);
        return;
      }
      if (e.target.id === 'gl-compare-diff') { this.compareOnlyDiff = !!e.target.checked; this._render(); return; }
      const tpSel = e.target.closest('[data-gc-tp-select]');
      if (tpSel) {
        const which = tpSel.dataset.gcTpSelect;
        if (which === 'speed') { this._plan.speed = Number(tpSel.value) || 1; return; }
        this._stopPlanPlay();
        if (which === 'us') this._plan.usFormationId = Number(tpSel.value) || 0;
        if (which === 'opp') this._plan.oppFormationId = Number(tpSel.value) || 0;
        if (which === 'moment') this._plan.moment = tpSel.value;
        if (which === 'block') this._plan.block = tpSel.value;
        this._loadPlan();
        return;
      }
      const tpJob = e.target.closest('[data-gc-tp-job]');
      if (tpJob && this._tacticsCanEdit()) { this._editPlanJob(Number(tpJob.dataset.gcTpJob), tpJob.dataset.gcTpField, tpJob.value); return; }
      const formationSelect = e.target.closest('[data-lineup-formation-select]');
      if (formationSelect && this.isCoach) {
        this.formation = formationSelect.value;
        this.matchupId = null;   // a shape picked by hand is no longer the match
        this._render();
        this._saveLineup();   // the shape is part of the lineup (match_lineup_metadata.formation_id)
        return;
      }
      const matchupSelect = e.target.closest('[data-lineup-matchup-select]');
      if (matchupSelect && this.isCoach) {
        const m = this._matchup(Number(matchupSelect.value));
        this.matchupId = m ? m.id : null;
        if (m) this.formation = m.code;
        this._render();
        this._saveLineup();
        return;
      }
      // The opponent Message dropdown: ✍️ Write your own opens its box.
      if (e.target.matches('[data-gc-opp-tier]')) { this._oppTier = e.target.value; this._render(); return; }
    });

    this.element.addEventListener('input', (e) => {
      // 🎯 Match plan tactics notes: kept across re-renders (mig 966).
      if (e.target.matches('[data-mp-tactics]')) { this.matchPlanPanel.input(e.target); return; }
      // 📝 contact draft (mig 724): keep the text across re-renders.
      if (e.target.matches('[data-gc-draft-subject], [data-gc-draft-body]')) { this._draftReadForm(); return; }
      // ✍️ Write your own (mig 803): keep the typed text across re-renders.
      if (e.target.matches('[data-gc-opp-msg]')) { this._oppMsg = e.target.value; return; }
    });
  }

  // Pill wording: social_post_types.display_name when loaded, else the
  // JS fallback title, else the raw key.
  _pillTitle(key) {
    if (key === TACTICS_PILL.key) return this._copyTactics('pill') || TACTICS_PILL.title;
    const meta = POST_PILLS.find(p => p.key === key);
    // Everyone plays (mig 515/516): no starters or bench to name.
    if (key === 'starters_bench' && this.everyonePlays && this._copyLe('title')) return this._copyLe('title');
    return (this.postTypeNames && this.postTypeNames[key]) || (meta && meta.title) || key;
  }

  async _bootstrap() {
    // No game named (an old 🏟️ Game Center tile door, a saved return with
    // no match): the 📅 Calendar is the picker now (owner 11/16).
    if (!this.matchId) {
      setTimeout(() => EventKindSwitch.go(this.navigation, 'match'), 0);
      return;
    }
    this._refreshEvent();
    // Copy rows (dues flag, migration 416) — cached across screens.
    if (window.MessageCopy) MessageCopy.load(this.auth).catch(() => {});
    if (window.SectionContact) SectionContact.load(this.auth).catch(() => {});
    // Pull Google Calendar in the background (GcalRefresh, 11/3) — this
    // render stays on the DB; the next open / live poll has the pull.
    if (window.GcalRefresh) GcalRefresh.ping(this.auth);

    try {
      const [lineupRes, positionsRes, matchRes, postTypesRes] = await Promise.all([
        this.auth.fetch(`/api/eligibility/lineup/${this.matchId}`),
        this.auth.fetch('/api/eligibility/positions'),
        this.auth.fetch(`/api/matches/${this.matchId}`),
        // Post-type titles only matter for the staff post pills; the
        // endpoint is admin-gated, and a player asking for it was how the
        // #my door logged players out (2026-09-23).
        this.playerOnly
          ? Promise.resolve(null)
          : this.auth.fetch('/api/social/post-types').catch(() => null),
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
      if (!this.ev) this._refreshEvent().then(() => {   // matchId-only door: the event-keyed loads again
        if (this._isCoach) return Promise.all([this._loadReminders(), this._loadTextMarks(), this._loadInvites()]);
      }).then(() => this._render());

      this.teamId  = lineupData.data.teamId || null;
      this._loadPostStates();
      this.fieldSize = FIELD_SIZES[lineupData.data.fieldSize] ? Number(lineupData.data.fieldSize) : DEFAULT_FIELD_SIZE;
      this.everyonePlays = lineupData.data.everyonePlays === true;
      this.benchCap      = Number.isInteger(lineupData.data.benchCap) ? lineupData.data.benchCap : DEFAULT_BENCH_CAP;
      this.squadSize     = Number(lineupData.data.squadSize) || (this.fieldSize + this.benchCap);
      this.teamSquadSize = Number(lineupData.data.teamSquadSize) || this.squadSize;
      this._pendingSquadSize = 0;
      // The saved shape (formations.code via match_lineup_metadata) when the
      // page can draw it for this field size; else the size's default.
      this.formations = Array.isArray(lineupData.data.formations) ? lineupData.data.formations : [];
      const savedCode = lineupData.data.formationCode;
      this.formation = savedCode && this._fieldSpec().formations[savedCode] ? savedCode : this._fieldSpec().defaultFormation;
      // Match opponent (mig 912): their shape → our shape + who takes whom.
      this.matchups = Array.isArray(lineupData.data.formationMatchups) ? lineupData.data.formationMatchups : [];
      this.matchupId = lineupData.data.matchupId || null;
      this.matchStartsAt = lineupData.data.matchStartsAt || null;
      // DB-truth status strip (mig 626): when the lineup last changed
      // (server's stamp, shown to players too) and when WE last synced.
      this.lineupChangedAt = lineupData.data.lineupChangedAt || null;
      this._dbSyncAt = new Date();
      this._dbState = 'ok';
      // isCoach comes from EligibilityController checking the REAL logged-in
      // account's admin/coach status — it never looks at the "view as
      // <player>" impersonation the READ request may be carrying, so an
      // admin using view-as still gets isCoach:true from their own account.
      // Force it off here whenever view-as is active (owner, 2026-08-22:
      // "players dont need player lineup view lol... there view is default
      // player") so view-as always renders exactly what the impersonated
      // player would see — no coach toggle, no edit tools, default view.
      // 🎭 View-as: the server answers isCoach as the viewed person.
      this.isCoach = !!lineupData.data.isCoach && !this.playerOnly;
      this.zones = new Map();
      this.positions = new Map();
      this.benchOrder = new Map();
      this.shares = new Map();
      this.splitSquad = !!lineupData.data.splitSquad;
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
        if (row.zone === 'bench' && row.sharesPositionId != null && row.shareOrder != null) {
          this.shares.set(Number(row.playerId), { pos: Number(row.sharesPositionId), order: Number(row.shareOrder) });
        }
      }
      this.realIsCoach = this._isCoach;
      this.official = this._snapshot();
      this._loadDrafts();   // non-fatal; re-applies the open draft when it lands
      this.stats = new Map();
      for (const row of (lineupData.data.rosterStats || [])) {
        this.stats.set(Number(row.playerId), row);
      }
      // Starter eligibility (mig 456): a player's own row + the policy.
      this.myPlayerId = lineupData.data.myPlayerId != null ? Number(lineupData.data.myPlayerId) : null;
      this.eligibilityPolicy = lineupData.data.eligibilityPolicy || null;

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
      // One fetch per roster team, the game's own team first: the endpoint
      // answers for a single team, so on a two-team game (APSL + APSL
      // Reserves) the second team's players had no details row — no person
      // id, and their No Response cards lost the REMIND buttons (owner
      // 2026-10-02: "why josue david not having email or text for rsvp
      // reminder").
      const detailTeamIds = [...new Set([this.teamId, ...rosterTeamIds].filter(Boolean).map(Number))];
      const detailsPromise = this._isCoach && detailTeamIds.length
        ? Promise.all(detailTeamIds.map(id =>
            this.auth.fetch(`/api/matches/${this.matchId}/roster-players?teamId=${id}`)
              .then(r => r.json())
              .catch(err => { console.warn('[game-center] player details unavailable:', err); return null; })))
        : Promise.resolve([]);

      // Reminders already sent about this game — dims a No Response
      // card's button.  Admin-only endpoint; a 403 just means no dimming.
      const remindersPromise = this._isCoach
        ? Promise.all([this._loadReminders(), this._loadSquadNotice(), this._loadOpponentContacts(), this._loadGameRecipients(), this._loadHealth(), this._loadInvites(), this._loadRegGaps(), this._loadTextMarks(), this._loadGameAttendance()]) : Promise.resolve();
      // The league's roster sheet is for the players too (owner 2026-09-30:
      // "all players to see it so we can ask one to print it if we forget").
      const officialRosterPromise = this._loadOfficialRoster();
      // 🚗 Carpool is for everyone on the game, parents included (mig 601).
      const carpoolPromise = this._loadCarpool();
      // 🎯 Match plan is for everyone on the game too (mig 966).
      const matchPlanPromise = this.matchPlanPanel.load();

      const [rosterResults, detailsData] = await Promise.all([
        Promise.all(rosterTeamIds.map(id =>
          this.auth.fetch(`/api/teams/${id}/roster`).then(r => r.json()).then(d => ({ id, d })))),
        detailsPromise,
        remindersPromise,
        officialRosterPromise,
        carpoolPromise,
        matchPlanPromise,
      ]);

      // A player on two of the game's teams keeps the first team's row.
      const detailSets = (detailsData || []).filter(d => d && d.success);
      if (detailSets.length) {
        const seen = new Set();
        this.players = detailSets.flatMap(d => d.data || []).filter(p => {
          const key = String(p.playerId);
          if (seen.has(key)) return false;
          seen.add(key);
          return true;
        });
      }
      const byId = new Map();
      // Call-up-only teams on this game (APSL Reserves, mig 605): a player
      // whose ONLY row here is one of them is pool, not squad (owner 11/5).
      this.callupOnlyTeamIds = new Set((lineupData.data.callupOnlyTeamIds || []).map(Number));
      const squadRow = new Set();
      for (const { id: fromTeamId, d: rosterData } of rosterResults) {
        const arr = Array.isArray(rosterData?.data) ? rosterData.data : [];
        for (const p of arr) {
          if (p.roleType !== 'PLAYER') continue;
          const pid = Number(p.id);
          if (!this.callupOnlyTeamIds.has(Number(fromTeamId))) squadRow.add(pid);
          if (byId.has(pid)) continue; // already merged from an earlier team
          byId.set(pid, { id: pid, name: p.name || '(unnamed)', lastName: p.lastName || '', lineupRole: p.lineupRole || null, teamId: fromTeamId, jerseyNumber: p.jerseyNumber || null,
                          duesEligible: p.duesEligible !== false,   // migration 416: under the dues line
                          squadStatus: p.squadStatus || null,        // 💤 inactive → own fold (mig 945)
                          needsOnboard: p.needsOnboard === true,     // 👋 never answered anything → Not chasing (mig 1520)
                          calldownFrom: p.calldownFrom || null,      // ⬇ On Roster only for APSL → a call-down (mig 1527)
                          notOnRoster: p.notOnRoster === true });    // ⛔ flag on his box (mig 1528)
        }
      }
      this.roster = [...byId.values()];
      for (const r of this.roster) r.poolOnly = !squadRow.has(r.id);

      this._foldInCallups();

      this.loaded = true;
      // Baseline for the live poll — same fields _pollLive fingerprints,
      // from the data this render was built on.
      this._liveFpLast = this._liveFp(lineupData.data.lineup, lineupData.data.rosterStats, this.invites);
      this._syncHash();
      this._render();
      // 👻 Last RSVP + dues standing on every card (PersonStanding, 11/3).
      if (window.PersonStanding && this._isCoach) {
        PersonStanding.load(this.auth, (this.players || []).map(x => x.personId)).then(() => this._render()).catch(() => {});
      }
      if (this._isCoach) this._pullLeagueList();
    } catch (err) {
      console.error('[game-lineup] load failed:', err);
      this.error = err.message || 'Failed to load lineup.';
      this._render();
    }
  }

  // 🎟 A call-up who answered Going joins the lineup pool like a
  // rostered player (owner 2026-10-16: "the call ups if they say
  // going to show in lineup! they are all eligible") — deliberately
  // NO stats row, so the practice/RSVP-deadline criteria never mark
  // them ineligible; their card carries a call-up chip instead.
  // Idempotent (every push is guarded), so the live poll can re-run it
  // whenever a fresh invites payload lands.
  // EVERY invitee — call-up, call-down, ↔ call-in, ⭐ standing — joins
  // the squad's lists the moment the invite exists: No Response until they
  // answer, then Going / Not Going, with a chip saying which kind (owner
  // 2026-11-05: "the initial invite to call up dumps them into no response
  // immediately so we can treat them like everyone else for that event" …
  // "do same for call down etc" … "for all teams").  Before mig 1069 only
  // standing call-downs did (owner 2026-10-23); one-game call-ups waited
  // in the 🎟 panel until they said Going.  An invite withdrawn since the
  // last fold takes its card out again.
  _foldInCallups() {
    const invites = (this.invites && this.invites.invites) || [];
    const live = new Set(invites.filter(i => i.player_id).map(i => Number(i.player_id)));
    this.roster = this.roster.filter(r => !r.folded || live.has(Number(r.id)));
    for (const inv of invites) {
      if (!inv.player_id) continue;
      const pid = Number(inv.player_id);
      const name = `${inv.first_name || ''} ${inv.last_name || ''}`.trim() || 'Invited player';
      const have = this.roster.find(r => Number(r.id) === pid);
      // 💤 Inactive on this team but invited (⭐ standing, or 🎟 CALL IN):
      // the invite wins — his card joins the answer groups with the chip
      // instead of sitting in the Inactive fold (David Masi, APSL, 11/5).
      // Same for a pool-only card (on this game only through a call-up-only
      // team, APSL Reserves): invited = called up, out of the 🎟 Call-up
      // pool fold (Lusayo, APSL vs Westtown, Going but hidden, 11/7).
      if (have && !have.callUp && (have.squadStatus === 'inactive' || have.poolOnly)) {
        Object.assign(have, { callUp: true, fromTeam: inv.from_team || '', fromTeamId: inv.from_team_id || null,
                              standing: !!inv.auto, callIn: !!inv.call_in });
      }
      if (have) { if (have.callUp) { have.inviteRsvp = inv.response || null; have.badge = inv.badge || null; } }
      else {
        this.roster.push({ id: pid, name, lastName: inv.last_name || '', lineupRole: null,
                           teamId: this.teamId, jerseyNumber: null, duesEligible: true,
                           callUp: true, folded: true, badge: inv.badge || null,
                           fromTeam: inv.from_team || '', fromTeamId: inv.from_team_id || null,
                           standing: !!inv.auto, callIn: !!inv.call_in, inviteRsvp: inv.response || null });
      }
      if (!this.players.some(d => Number(d.playerId) === pid))
        this.players.push({ playerId: pid, personId: inv.person_id, name });
      if (Array.isArray(this.gameRecipients) && !this.gameRecipients.some(r => Number(r.personId) === Number(inv.person_id)))
        this.gameRecipients.push({ personId: inv.person_id, name, kind: 'callup', rsvp: inv.response || null, email: inv.email || null,
                                   phone: inv.phone || null, viaParent: !!inv.parent_person_id });
    }
  }

  // League call-down cap (migs 616/617): would putting `playerId` into
  // starters/bench exceed a cap (e.g. 2 down from APSL on a CASA game)?
  // Call-downs are exactly the folded invitees, so the invite rows'
  // from_team_id identifies them.  Returns the blocking cap row or null;
  // the PUT enforces the same rule server-side.
  // A folded invitee whose from-team has a cap row for this game is a
  // CALL-DOWN (APSL → CASA); every other invitee is a call-up.
  // Since mig 1527 the official rosters decide (owner 11/19 "not more than
  // 2 apsl guys that are not on liga 1 roster"): a roster card carries
  // calldownFrom (On Roster for APSL, not for this team — Caleb Rojas);
  // an invitee still counts by its from-team.  → the cap's from_team_id or null.
  _callDownFrom(playerId) {
    const caps = (this.invites && this.invites.caps) || [];
    if (!caps.length) return null;
    const r = this.roster.find(x => Number(x.id) === Number(playerId));
    if (!r) return null;
    const from = r.calldownFrom ? Number(r.calldownFrom) : (r.callUp && r.fromTeamId ? Number(r.fromTeamId) : null);
    return from && caps.some(c => Number(c.from_team_id) === from) ? from : null;
  }
  _isCallDown(playerId) { return this._callDownFrom(playerId) != null; }

  // The squad's call-downs per cap: [{ cap, ids }] (starters + bench).
  _callDownTally() {
    const caps = (this.invites && this.invites.caps) || [];
    return caps.map(c => ({ cap: c, ids: [...this.zones.entries()]
      .filter(([id, z]) => (z === 'starter' || z === 'bench') && this._callDownFrom(id) === Number(c.from_team_id))
      .map(([id]) => id) }));
  }

  // Placing playerId would put a cap over its max → { cap, n } (n = the
  // count with him), else null.  A warning, not a block (owner 11/19 "flag
  // them as call downs and warn if 3 of more"): the caller asks.
  _callDownCapHit(playerId) {
    const from = this._callDownFrom(playerId);
    if (!from) return null;
    for (const t of this._callDownTally()) {
      if (Number(t.cap.from_team_id) !== from) continue;
      const n = t.ids.filter(id => Number(id) !== Number(playerId)).length + 1;
      if (n > Number(t.cap.max)) return { cap: t.cap, n };
    }
    return null;
  }
  // true = go ahead (under the cap, or the coach said yes).
  _callDownOk(playerId) {
    const hit = this._callDownCapHit(playerId);
    if (!hit) return true;
    const tk = { max: hit.cap.max, team: hit.cap.from_team || 'APSL', n: hit.n };
    return window.confirm((window.MessageCopy && MessageCopy.block('event_center', 'calldown_confirm', tk))
      || `League rule: at most ${tk.max} ${tk.team} call-downs in the squad. This makes ${tk.n}. Place anyway?`);
  }

  // Bench/Alt only — Starting XI assignment goes through _setPosition
  // instead (owner directive: picking a position IS how a player becomes
  // a starter, no separate "Start" button). Either way, a player only
  // ever holds a position while zone === 'starter', so leaving that zone
  // always clears it.
  // ⛔ Suspended for this game (mig 1077; invites GET carries the person
  // ids): own section, never placed in the lineup.
  _isSuspended(playerId) {
    const ids = (this.invites && this.invites.suspended) || [];
    if (!ids.length) return false;
    const pl = (this.players || []).find(x => Number(x.playerId) === Number(playerId));
    return !!(pl && ids.map(Number).includes(Number(pl.personId)));
  }

  _suspendedToast() {
    this._toast((window.MessageCopy && MessageCopy.block('suspended', 'refused')) || 'Suspended for this game.');
  }

  _toggleZone(playerId, zone) {
    const current = this.zones.get(playerId);
    if (current === zone) {
      this.zones.delete(playerId); // tap active zone again → unassign
    } else {
      if (this._isSuspended(playerId)) { this._suspendedToast(); return; }
      if (zone === 'bench' && this.zones.get(playerId) !== 'starter' && !this._callDownOk(playerId)) return;   // ⬇ mig 1527: warn + ask
      if (zone === 'bench' && this._benchFull(playerId)) {
        // Full: swap with someone or extend the squad for this game
        // (2026-09-26 / mig 760).  The toast is the fallback while the
        // copy rows have not landed.
        if (this._openBenchSheet(playerId)) return;
        this._toast(`Bench is full (${this._benchCapNow()} max)`);
        return;
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
      this.shares.delete(playerId);
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
  // group, same as tapping an active Bench/Alt pill again. A slot
  // someone ELSE already holds normally goes through the swap sheet
  // first (2026-09-26); reaching here with it still taken (copy rows not
  // loaded) keeps the original rule — they're bumped back to unassigned
  // (their RSVP group, e.g. "Going"). Never exceeds the format's starters (7/9/11):
  // replacing frees a slot in the same stroke as filling it, and there
  // are only fieldSize pills.
  _setPosition(playerId, positionId) {
    if (positionId != null && this._isSuspended(playerId)) { this._suspendedToast(); return; }
    if (positionId == null) {
      this.zones.delete(playerId);
      this.positions.delete(playerId);
      this.shares.delete(playerId);
      this._render();
      this._scheduleSave();
      return;
    }
    {
      // Call-down cap (migs 616/617) — a position pill is the starter door.
      if (!['starter', 'bench'].includes(this.zones.get(playerId)) && !this._callDownOk(playerId)) return;   // ⬇ mig 1527: warn + ask
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
    this.benchOrder.delete(playerId);   // a promoted bench player's slot number is meaningless now
    this.shares.delete(playerId);
    this._render();
    this._scheduleSave();
  }

  // ── Swap sheet (2026-09-26, owner: "when we click something that is
  // filled … popup saying full and that we need to swap someone") ─────
  //
  // Two situations, one sheet:
  //   • a position pill whose slot someone else holds  (_openPositionSheet)
  //   • the Bench button while the bench is at ZONE_CAPS  (_openBenchSheet)
  // An EMPTY target never prompts — the common case stays one tap.
  //
  // Every outcome is a swap of placements: a player's placement is
  // {zone, positionId, benchOrder} (_placementOf), and giving player A
  // player B's placement and B A's (_swapPlayers) covers Luke↔Caleb
  // whether Luke was a starter, benched, an alternate, or unassigned —
  // the last is the only case where the holder comes off the lineup,
  // which is what the old silent bump did every time.  "to Bench" and
  // "to Alternates" move the holder somewhere else instead, then the
  // mover takes the slot.  All of it lands in ONE debounced save.
  //
  // Words come from message_templates kind='lineup_swap' (migration
  // 453) through MessageCopy; with no rows loaded the openers return
  // false and the callers fall back to the pre-sheet behaviour.

  _holderOf(positionId) {
    for (const [pid, pos] of this.positions.entries()) if (pos === positionId) return pid;
    return null;
  }

  _placementOf(playerId) {
    return {
      zone: this.zones.get(playerId) ?? null,
      positionId: this.positions.get(playerId) ?? null,
      benchOrder: this.benchOrder.get(playerId) ?? null,
      share: this.shares.get(playerId) ? { ...this.shares.get(playerId) } : null,
    };
  }

  _applyPlacement(playerId, pl) {
    this.zones.delete(playerId);
    this.positions.delete(playerId);
    this.benchOrder.delete(playerId);
    this.shares.delete(playerId);
    if (!pl || !pl.zone) return;
    this.zones.set(playerId, pl.zone);
    if (pl.zone === 'starter' && pl.positionId != null) this.positions.set(playerId, pl.positionId);
    if (pl.zone === 'bench' && pl.benchOrder != null) this.benchOrder.set(playerId, pl.benchOrder);
    if (pl.zone === 'bench' && pl.share) this.shares.set(playerId, { ...pl.share });
  }

  _swapPlayers(aId, bId) {
    const a = this._placementOf(aId);
    const b = this._placementOf(bId);
    this._applyPlacement(aId, b);
    this._applyPlacement(bId, a);
  }

  // ── Shared positions (mig 763, owner 2026-10-27: "each position has x
  // players you can put in") ──────────────────────────────────────────
  // The starter is 1st; the bench players sharing the spot are 2nd, 3rd …
  // in share order.  They stay zone 'bench' — only the drawing differs.

  _sharersOf(positionId) {
    return [...this.shares.entries()].filter(([, sh]) => sh.pos === positionId)
      .sort((a, b) => a[1].order - b[1].order).map(([pid]) => pid);
  }

  // Shares only live on the bench, and orders run 2, 3, … with no gaps.
  _normShares() {
    for (const pid of [...this.shares.keys()]) if (this.zones.get(pid) !== 'bench') this.shares.delete(pid);
    const byPos = new Map();
    for (const [pid, sh] of this.shares.entries()) { if (!byPos.has(sh.pos)) byPos.set(sh.pos, []); byPos.get(sh.pos).push([pid, sh.order]); }
    for (const [pos, list] of byPos) list.sort((a, b) => a[1] - b[1]).forEach(([pid], i) => this.shares.set(pid, { pos, order: i + 2 }));
  }

  _nth(n) { const v = n % 100; return n + (v >= 11 && v <= 13 ? 'th' : ({ 1: 'st', 2: 'nd', 3: 'rd' }[n % 10] || 'th')); }

  // {playerId} joins {positionId} as its next sharer — onto the bench first
  // if they are not there.  false when the bench is full and can't extend.
  _sharePosition(playerId, positionId) {
    if (this.zones.get(playerId) !== 'bench') {
      if (this._benchFull(playerId)) {
        if (!this._canExtendSquad()) return false;
        this._extendSquad();
      }
      this._applyPlacement(playerId, { zone: 'bench', positionId: null, benchOrder: this._nextBenchOrder(playerId) });
    }
    this.shares.set(playerId, { pos: positionId, order: 1000 });
    this._normShares();
    return true;
  }

  // One up the order at their position (3rd → 2nd).
  _shareUp(playerId) {
    const sh = this.shares.get(playerId); if (!sh || sh.order <= 2) return;
    const list = this._sharersOf(sh.pos); const i = list.indexOf(playerId);
    [list[i - 1], list[i]] = [list[i], list[i - 1]];
    list.forEach((pid, k) => this.shares.set(pid, { pos: sh.pos, order: k + 2 }));
  }

  // Under the controls while split squad is on: how it works, the spots
  // still without a 2nd, and a one-tap fill from the free bench.
  _splitNoteHtml() {
    if (!this.splitSquad || this.everyonePlays) return '';
    const esc = (t) => this.escapeHtml(t);
    const open = this._openSecondSpots();
    const free = [...this.zones.entries()].filter(([pid, z]) => z === 'bench' && !this.shares.has(pid)).length;
    const n = Math.min(open.length, free);
    return `<div style="font-size:0.75rem; opacity:0.85; margin:-4px 0 10px; display:flex; flex-direction:column; gap:4px;">
      <span>${esc(this._copySplit('hint'))}</span>
      ${open.length ? `<span style="color:#fbbf24;">${esc(this._copySplit('unpaired', { positions: open.map(p => p.sortOrder).join(', ') }))}</span>` : ''}
      ${n ? `<span><button type="button" data-gc-split-fill class="btn btn-secondary" style="font-size:0.72rem; padding:3px 9px;">${esc(this._copySplit('fill', { n }))}</button></span>` : ''}
    </div>`;
  }

  _copySplit(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('lineup_split', tier, tokens) : ''; }

  // ── 🎯 Tactics (mig 1120) ─────────────────────────────────────────────
  // Owner 2026-11-06: "show the tactics depending on where opponents and
  // ball are" → coach-drawn situations per formation (A), 3-5-2 (3-R2)
  // first.  The pitch is TacticsPitch (components/tactics-pitch.js); the
  // situations are positions only, so today's lineup fills them by slot.
  _copyTactics(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('tactics', tier, tokens) : ''; }

  _tacticsCanEdit() { return this.isCoach && this.viewMode !== 'player'; }

  // Coach/player view = EventScreen's 👀 See as (slice 5): 'player' only
  // while a coach / admin is looking as a player.  Setting 'coach' clears it.
  get viewMode() { return this.seeAs === 'player' ? 'player' : 'coach'; }

  // isCoach = may edit what is on screen now: the raw flag (_isCoach — the
  // lineup GET's isCoach, or a drafter on their own draft) unless 👀 See as
  // player is on, so every coach tool hides exactly as for a player.
  // Loads read _isCoach so the data is there on the way back.
  get isCoach() { return !!this._isCoach && this.seeAs !== 'player'; }
  set isCoach(v) { this._isCoach = !!v; }
  set viewMode(v) { this.seeAs = v === 'player' ? 'player' : null; }

  // Staff tools on show: really a coach here (EventAccess via the lineup
  // GET's isCoach) and not looking as a player.
  _staffView() { return !!this.realIsCoach && this.viewMode !== 'player'; }

  // The tier Game Center's lineup panels ask (lib/panel.js): coach-or-up
  // while isCoach (the lineup GET, or a drafter on their own draft) — the
  // real viewer when it already ranks that high, so an admin stays admin;
  // otherwise a player.  👀 See as player turns isCoach off.
  get panelViewer() {
    if (!this.isCoach) return new PlayerViewer();
    const v = this.viewer;
    return v.atLeast('coach') ? v : new CoachViewer();
  }

  // The 👀 See as bar for this game — staff only, never on the #my
  // look-only door or under view-as (isCoach is forced off there).
  _gcSeeAsHtml() {
    if (!this.realIsCoach || this.playerOnly) return '';
    return this._seeAsHtml();
  }

  _tacticsAvailable() { return !this.everyonePlays && this.fieldSize === 11; }

  // 🎯 Tactics + match plan → screens/game-center/tactics-plan.js (GameCenterTactics, mixed in).

  // ⚔️ Lineup editing → screens/game-center/lineup-edit.js (GameCenterLineupEdit, mixed in).

  // The game's own event row — GET /api/calendar/events/:id, the call every
  // EventScreen makes (was the club's whole 35-day game feed on every open,
  // only to find this one row — owner 11/16: games and practices one base).
  // A matchId-only door (old #game-center/<id> link) learns the id from the
  // match row (matchDetails.fh_event_id) and asks again after the lineup load.
  async _refreshEvent() {
    const id = (this.ev && this.ev.fh_event_id) || this._fhEventId();
    if (!id) return false;
    const matchId = this.matchId;
    try {
      const body = await this._json(`/api/calendar/events/${id}`);
      if (!body || !body.event || matchId !== this.matchId) return false;
      const before = this.ev ? JSON.stringify((this.ev.rsvps || []).map(r => [r.person_id, r.response, r.arrive_label, r.leave_label])) : null;
      this.ev = body.event;
      this._syncHash();
      this._paintMyAvailability();
      return before !== JSON.stringify((this.ev.rsvps || []).map(r => [r.person_id, r.response, r.arrive_label, r.leave_label]));
    } catch (err) {
      console.error('[game-center] event load failed:', err);
      return false;
    }
  }

  _render() {
    // The lit pill must be one this viewer has (a player: ⚔️ Starters & Bench).
    if (this.ev) { const ps = this.pills(this.ev); if (ps.length && !ps.some(p => p.key === this.pill)) this.pill = ps[0].key; }
    const box = this.find('#gl-body');
    const head = this.find('#gl-head');
    if (!box || !head) return;

    if (this.error || !this.loaded) {
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
      // Coaching only (mig 688): a coach who also plays, not playing this one.
      if (rsvp === 'no' || rsvp === 'coaching') return 'notGoing';
      return 'noResponse';
    };
    // Dues alternates (mig 613: any balance, Men) sink to the bottom of
    // every selection list — the owner's "bottom of the selection pool".
    const starterEligibleRank = (p) => (p.lineupRole === 'starter' ? 0 : 1)
      + (this.stats.get(Number(p.id))?.duesAlternate ? 10 : 0);
    const byStarterRank = (a, b) => starterEligibleRank(a) - starterEligibleRank(b);

    const byZone = { starter: [], bench: [], alternate: [] };
    // A yes from a player over the dues line (duesEligible=false,
    // migration 416) is kept but counted apart from Going (owner
    // 2026-09-23: "sep total for ineligible").
    const unassignedGoing = [], unassignedIneligible = [], unassignedNotGoing = [], unassignedNoResponse = [];
    for (const p of this.roster) {
      const z = this.zones.get(p.id);
      // A folded-in invitee has no stats row: their answer is the
      // invite's (a standing call-down may not have answered yet), and
      // they never count as ineligible.
      const group = p.callUp
        ? (p.inviteRsvp === 'yes' ? 'going' : p.inviteRsvp === 'no' ? 'notGoing' : 'noResponse')
        : rsvpGroup(p.id);
      // Everyone plays: Going IS the lineup, alphabetical; no bench, no picks.
      if (this.everyonePlays) {
        if (group === 'going') byZone.starter.push(p);
        else if (group === 'notGoing') unassignedNotGoing.push(p);
        else unassignedNoResponse.push(p);
        continue;
      }
      if (z && byZone[z]) { byZone[z].push(p); continue; }
      if (group === 'going' && p.duesEligible === false) unassignedIneligible.push(p);
      else if (group === 'going') unassignedGoing.push(p);
      else if (group === 'notGoing') unassignedNotGoing.push(p);
      else unassignedNoResponse.push(p);
    }
    if (this.everyonePlays) byZone.starter.sort(this._byLastName);
    unassignedGoing.sort(byStarterRank);
    unassignedNotGoing.sort(byStarterRank);
    unassignedNoResponse.sort(byStarterRank);
    // 🩹 An open injury answers for them (mig 510, as on #my and the event
    // screen): no answer → the Injured group, never No Response, so the
    // REMIND bar skips them (mig 984).  Coaches load health; others see none.
    const unassignedInjured = unassignedNoResponse.filter(p => this._isInjured(p.id));
    if (unassignedInjured.length) {
      const hurt = new Set(unassignedInjured.map(p => p.id));
      unassignedNoResponse.splice(0, unassignedNoResponse.length, ...unassignedNoResponse.filter(p => !hurt.has(p.id)));
    }
    const injuredLabel = (window.MessageCopy && MessageCopy.block('event_center', 'sec_injured')) || '🩹 Injured';
    // 💤 Inactive (Team pill, mig 945; owner 2026-11-03: "show in sep section
    // on all screens … so i don't bother with them"): billed, never fined or
    // reminded.  Out of No Response / Not Going (so the REMIND bar skips
    // them) into their own closed fold.  A yes brings him back (trigger),
    // so a Going card never reads inactive.
    const isInactive = (p) => !p.callUp && p.squadStatus === 'inactive';
    // Practice Squad (mig 1031) does not see this team's games — not in No
    // Response, never in Remind all (owner 2026-11-05, U8 vs West Philly:
    // "why is the no response section have players for game that should not
    // be there").  They sit in their own closed fold with 🎟 CALL IN; once
    // invited they join the lists with the call-up chip (_foldInCallups).
    const isPracticeSquad = (p) => !p.callUp && p.squadStatus === 'practice_squad';
    const unassignedPracticeSquad = [...unassignedNoResponse, ...unassignedNotGoing, ...unassignedGoing, ...unassignedIneligible]
      .filter(isPracticeSquad).sort(this._byLastName);
    if (unassignedPracticeSquad.length) {
      for (const list of [unassignedNoResponse, unassignedNotGoing, unassignedGoing, unassignedIneligible])
        list.splice(0, list.length, ...list.filter(p => !isPracticeSquad(p)));
    }
    const practiceSquadLabel = (window.MessageCopy && MessageCopy.block('roster_sheet', 'board_practice_squad_h')) || 'PRACTICE SQUAD';
    // ⛔ Not eligible (mig 1523, owner 11/19 "if your not eligible at this
    // momnemt to play liga 1 i thik you need to be secitoned off"): On
    // Roster on no official roster that counts for this team — no game
    // here, so out of every list (and Remind all) into a closed fold.  The
    // official-roster sync clears it; a call-up still folds him in.
    const isNotEligible = (p) => !p.callUp && p.squadStatus === 'not_eligible';
    const unassignedNotEligible = [...unassignedNoResponse, ...unassignedNotGoing, ...unassignedGoing, ...unassignedIneligible]
      .filter(isNotEligible).sort(this._byLastName);
    if (unassignedNotEligible.length) {
      for (const list of [unassignedNoResponse, unassignedNotGoing, unassignedGoing, unassignedIneligible])
        list.splice(0, list.length, ...list.filter(p => !isNotEligible(p)));
    }
    const notEligibleLabel = this._ecCopy('sec_not_eligible', '⛔ Not On Roster');
    // 🎟 Call-up pool (owner 11/5, APSL at Vidas: "why on apsl is a bunch of
    // guys no response … those guys are supposed to be inactive right? then
    // i could call them up"): on this game only through a call-up-only team
    // (APSL Reserves) and not called up — out of No Response / Remind all,
    // into a closed fold with 🎟 CALL IN.  Once invited, _foldInCallups
    // brings them into the lists with the call-up chip.
    const isPool = (p) => !p.callUp && p.poolOnly && !isPracticeSquad(p) && !isInactive(p);
    const unassignedPool = [...unassignedNoResponse, ...unassignedNotGoing, ...unassignedGoing, ...unassignedIneligible]
      .filter(isPool).sort(this._byLastName);
    if (unassignedPool.length) {
      for (const list of [unassignedNoResponse, unassignedNotGoing, unassignedGoing, unassignedIneligible])
        list.splice(0, list.length, ...list.filter(p => !isPool(p)));
    }
    const poolLabel = (window.MessageCopy && MessageCopy.block('event_center', 'sec_callup_pool')) || '🎟 Call-up pool';
    // 👋 Not chasing (mig 1520, owner 11/19 "they are cluttering my graphic
    // and the players view graphic"): a man who has never answered an RSVP
    // (#teams NEEDS ONBOARD) leaves No Response — and Remind all, which the
    // server skips too — for his own closed fold.  His first answer brings
    // him back into the lists like anyone else.
    const isNotChasing = (p) => !p.callUp && p.needsOnboard && !isInactive(p) && !this._isSuspended(p.id);
    const unassignedNotChasing = unassignedNoResponse.filter(isNotChasing).sort(this._byLastName);
    if (unassignedNotChasing.length)
      unassignedNoResponse.splice(0, unassignedNoResponse.length, ...unassignedNoResponse.filter(p => !isNotChasing(p)));
    const notChasingLabel = this._ecCopy('sec_not_chasing', '👋 Not chasing');
    // ⛔ Suspended (mig 1077): out of every answer group into its own fold.
    const unassignedSuspended = [...unassignedGoing, ...unassignedIneligible, ...unassignedNoResponse, ...unassignedNotGoing]
      .filter(p => this._isSuspended(p.id)).sort(this._byLastName);
    if (unassignedSuspended.length) {
      for (const list of [unassignedGoing, unassignedIneligible, unassignedNoResponse, unassignedNotGoing])
        list.splice(0, list.length, ...list.filter(p => !this._isSuspended(p.id)));
    }
    const suspendedLabel = (window.MessageCopy && MessageCopy.block('suspended', 'section')) || '⛔ Suspended';
    const unassignedInactive = [...unassignedNoResponse, ...unassignedNotGoing].filter(isInactive).sort(this._byLastName);
    if (unassignedInactive.length) {
      for (const list of [unassignedNoResponse, unassignedNotGoing])
        list.splice(0, list.length, ...list.filter(p => !isInactive(p)));
    }
    // 💤 = never answered too (mig 1528, owner 11/19 "inactive should be
    // same as not chasing"): one fold, one graphic row.
    // 🪑 Reserves (men, mig 1530; owner 11/19 "a list of guys that we hit up
    // for practice and games and then a 2nd teir that we hit up if
    // desparate"): Reserves who haven't said yes, plus Regulars who never
    // answered anything, sit in one closed fold with 📣 Ask Reserves — never
    // in No Response or Remind all.  A Reserve who answers goes where a
    // Regular would (owner 11/19 "they should be in reserve cat if they
    // didn't respond … if they respond they go to that pending spot like
    // regulars"): Going → ⚠️ Going · Not placed yet for the coach to place,
    // Not going → ✗ Not going.  Only the unanswered ones sit in 🪑 Reserves.
    const isReserve = (p) => !p.callUp && p.squadStatus === 'standby';
    const unassignedReserves = this._hasReserves() ? unassignedNoResponse.filter(isReserve) : [];
    if (unassignedReserves.length) {
      const res = new Set(unassignedReserves.map(p => p.id));
      unassignedNoResponse.splice(0, unassignedNoResponse.length, ...unassignedNoResponse.filter(p => !res.has(p.id)));
    }
    if (unassignedNotChasing.length) {
      // Never answered = 🪑 Reserves on every team, never 💤 Inactive
      // (owner 11/20 "there should be no inactive right? isn't it all reserves now for all teams?").
      unassignedReserves.push(...unassignedNotChasing);
      unassignedNotChasing.length = 0;
    }
    unassignedReserves.sort(this._byLastName);
    unassignedInactive.sort(this._byLastName);
    this._reservesUnanswered = unassignedReserves.filter(p => (p.callUp ? p.inviteRsvp : rsvpGroup(p.id)) !== 'notGoing');
    const reservesLabel = this._ecCopy('sec_standby', '🪑 Reserves');
    const inactiveLabel = (window.MessageCopy && MessageCopy.block('event_center', 'sec_inactive')) || '💤 Inactive';

    // Coach ↔ Player view toggle (2026-08-22, owner directive: "only need
    // 1 Lineup button on screen" — coach previews exactly what players
    // see via a link on this same page instead of a separate screen/
    // route). Players always get the player view.
    // The toggle is now the shared 👀 See as bar atop every pill (seeAs,
    // slice 5) — the head in paint() below.
    // – No response / ✗ Not going under the substitutes on the live card
    // (owner 11/18 "we need not responded on graphic and not going …
    // obviously this goes under substitutes") — the same lists as the
    // sections, after injured / inactive / pool / suspended came out.
    // + ⚠️ Going · not placed yet (and ⛔ said going · ineligible) on top
    // (owner 11/18 "also what about not assigned yet. we need them on graphic").
    this._rsvpOut = { unplaced: [...unassignedGoing], ineligible: [...unassignedIneligible],
                      noResponse: [...unassignedNoResponse], notGoing: [...unassignedNotGoing],
                      // 👋 coaches only on the graphic (players never see the row)
                      notChasing: this.isCoach ? [...unassignedInactive] : [],
                      // 🪑 everyone sees who is a Reserve (owner 11/19 "show reserves
                      // to players view too … so everyone including them know they are possible")
                      reserves: [...unassignedReserves] };

    const seeAsBar = this._gcSeeAsHtml();

    // One assignment point for every pill, so the card mount and the
    // publish panel are wired in exactly one place. Everything is up top
    // (owner, 2026-09-19: "is there any reason to have a separate
    // instagram section? why cant we just have it all up top?"): pills
    // flip the one card, that post's tools and Post button sit right
    // under it, and the lineup editor follows.
    // The top of every pill, in EventScreen's order (owner 11/16: practice
    // and games one interface): 👀 bar, the pill row, your availability —
    // then the pill's own pieces (the lineup pills' Official / draft bar …).
    // Staff: the row sits hidden and ☰ lists its pills (EventScreen._menuNavHtml).
    const pillRow = this._menuNavHtml(`<div id="gc-social-pills" role="tablist" aria-label="Posts for this game" style="display:flex; gap:6px; margin-bottom:10px; overflow-x:auto;">${this._socialPillsHtml()}</div>`);
    // GOING / NOT GOING: on the card for a player (Viewer.eventAvailOnGraphic), here for staff.
    const top = seeAsBar + pillRow + (this._availOnGraphic() ? '' : this._myAvailBlockHtml());
    const paint = (bodyHtml) => {      if (this.pill === PLAYERS_PILL) {
        // 👥 All Players: EventScreen's list (Going / No response / Not
        // going, P/A/L/E, ✓/✗, reminders, 📇, call-in requests, mark all
        // present) — the very list a practice opens on.
        this._stopCards();
        this._tacticsBigOff();
        head.innerHTML = top + this._duesAlternateStripHtml();
        EventScreen.ensureCardStyles();
        box.innerHTML = `<div data-gc-players-pane>${this._playersPaneHtml()}</div>`;
        this._syncExtrasMenu();
        return;
      }
      if (this.pill === TACTICS_PILL.key) {
        // The tactics pitch in place of the graphic; nothing under it.
        this._stopCards();
        head.innerHTML = top + (this.viewer.eventLineupDrafts ? this._draftBarHtml() : '') + this._tacticsSectionHtml();
        box.innerHTML = '';
        this._mountTactics();
        this._syncExtrasMenu();
        return;
      }
      this._tacticsBigOff();
      // Official / My draft / Compare belongs to the lineup pills only.
      const lineupPill = this.pill === 'lineup' || this.pill === 'starters_bench';
      // The official lineup only — no draft picker (lib/viewer.js eventLineupDrafts, off for everyone 11/18).
      if (!this.viewer.eventLineupDrafts) this.lineupView = 'official';
      head.innerHTML = top + (lineupPill && this.viewer.eventLineupDrafts ? this._draftBarHtml() : '')
        + (this._hasTextView() && !this._textViewOn() ? '' : this._unplacedTopHtml())   // graphic-first: the card's ⚠️ row says it
        + this._duesAlternateStripHtml()
        + this._renderCard('top', this.pill) + (this.lineupView === 'official' ? this._pillToolsHtml(this.pill, byZone) + this._postButtonHtml() : '');
      box.innerHTML = bodyHtml;
      this._syncExtrasMenu();
      this._renderSocial(byZone);
      this._mountCard('top', this.pill, byZone);
    };

    // The lineup editor belongs to the two posts drawn from it; the
    // announcement and the result have their own tools and nothing else.
    if (this.pill !== 'starters_bench' && this.pill !== 'lineup') {
      paint('');
      return;
    }

    if (this.lineupView === 'compare') { paint(this._renderCompare()); return; }

    // The lineup pills' body = panels (lib/panel.js, Event Center slice 5B):
    // a coach gets every player panel plus the coach ones, in one list —
    // no separate player layout.  Tier = panelViewer (isCoach: a drafter
    // on their own draft edits like a coach; 👀 See as player turns it off).
    //   player  db strip (coach: inside the toolbar), 🚗 carpool off the
    //           official view (the head carries it there), my eligibility +
    //           everyone's criteria (not where everyone plays, mig 515), the
    //           published-lineup note (coach: the editor instead)
    //   coach   toolbar, reg gaps, 📣 group bar, the card sections
    const coach = {};   // the coach panels' parts, filled below only when drawn
    const panels = this.lineupPlayerPanels(byZone, coach);
    if (!this.panelViewer.atLeast('coach')) { paint(this._renderPanels(panels)); return; }

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
    // Everyone plays (mig 515): the tally is the faked shape, and there is
    // no formation to choose.
    const everyone = this.everyonePlays;
    const tallyText = everyone
      ? this._copyLe('count', { n: byZone.starter.length, shape: this._everyoneShape(byZone.starter.length).join('-') })
      : `Starting ${byZone.starter.length}/${this.fieldSize} · Bench ${byZone.bench.length}/${this._benchCapNow()} · Alt ${byZone.alternate.length}`
        + (this.squadSize > this.teamSquadSize && this._swapCopy('extended_strip', {}) ? ` · ${this._swapCopy('extended_strip', this._squadTokens())}` : '');
    const lineupControlsHtml = `
      <div style="display:flex; justify-content:space-between; align-items:center; margin:10px 0 12px; flex-wrap:wrap; gap:8px;">
        <span style="display:inline-flex; align-items:center; gap:10px; flex-wrap:wrap;">
          <span style="font-size:0.72rem; opacity:0.75;">${this.escapeHtml(tallyText)}</span>
          ${this._dbStripHtml()}
        </span>
        <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
          <select ${everyone ? 'hidden' : ''} data-lineup-formation-select title="Formation (visual layout only)"
                  style="font-size:0.72rem; font-weight:700; padding:4px 6px; border-radius:4px; border:1px solid #475569; background:#0f172a; color:#fff;">
            ${Object.keys(this._fieldSpec().formations).map(f => `<option value="${f}" ${f === this.formation ? 'selected' : ''}>${f}</option>`).join('')}
          </select>
          ${this._matchupSelectHtml(everyone)}
          <button type="button" id="gl-stats-toggle" class="btn btn-secondary" style="font-size:0.72rem; padding:4px 10px;">
            ${this.showLineupStats ? 'Hide' : 'Show'} Availability
          </button>
          ${!everyone && this._copySplit('button_on') ? `<button type="button" data-gc-split class="btn ${this.splitSquad ? 'btn-primary' : 'btn-secondary'}" style="font-size:0.72rem; padding:4px 10px;">
            ${this.escapeHtml(this._copySplit(this.splitSquad ? 'button_off' : 'button_on'))}</button>` : ''}
        </div>
      </div>
      ${this._splitNoteHtml()}
      ${this._matchupNoteHtml(everyone)}`;


    // Bench/Alt only now — Starting XI goes through the 1-11 position
    // pills below instead of a "Start" button (owner directive).
    const zoneButtons = (playerId) => everyone ? '' : `
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
      if (!startingPositions.length || everyone) return '';
      return `<div style="display:flex; gap:3px; flex-wrap:wrap; margin-top:4px;">
        ${startingPositions.map(pos => {
          const occupantId = slotToPlayerId.get(pos.id);
          const isMine = occupantId === p.id;
          const takenByOther = occupantId != null && !isMine;
          const share = this.shares.get(p.id);
          const sharesThis = share && share.pos === pos.id;
          const style = isMine
            ? 'background:#22c55e; color:#052e16; border:1px solid #22c55e; cursor:pointer;'
            : sharesThis
              ? 'background:#422006; color:#fbbf24; border:1px solid #f59e0b; cursor:pointer;'
            : takenByOther
              ? 'background:#1e293b; color:#64748b; border:1px solid #334155; cursor:pointer;'
              : 'background:#334155; color:#fff; border:1px solid #475569; cursor:pointer;';
          const title = sharesThis
            ? `${this._nth(share.order)} at ${pos.name} — tap to change`
            : takenByOther
            ? `${pos.name} — currently ${rosterById.get(occupantId)?.name || 'taken'}, tap to swap, share or move them`
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
      if (!label || everyone) return '';
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
      // Wrap: a weekday-game window carries 8–11 practices plus the Game
      // chip (owner 2026-09-26: "the game is getting cut off").
      return `<div style="display:flex; flex-wrap:wrap; gap:3px; margin-top:2px;">${spans.join('')}</div>`;
    };

    const statsLine = (playerId) => {
      const s = this.stats.get(playerId);
      if (!s) return '';
      // Coach row (owner 2026-09-26: "clear with the pill who is eligible,
      // not eligible and why, highlighted and color coded"): the same
      // green / yellow / red Practice Criteria pill the players see, then
      // the day chips that are the "why".
      const st = this._criteriaState(s);
      const [cbg, cfg] = st.colour;
      const rowText = this._eligCopy('row_' + st.state, st.tokens) || st.state;
      const windowNote = `${s.windowTotal != null ? s.windowTotal : s.practicesRecentTotal} practices count for this game${s.extended ? ' (weekday-game window)' : ''}`;
      const rt = this._rsvpTimingState(s);
      const rtText = rt ? this._eligCopy('rsvp_row_' + rt.state, rt.tokens) : '';
      return `<div style="font-size:0.68rem; opacity:0.85; margin-top:2px;">
        ${everyone ? '' : `<span title="${this.escapeHtml(windowNote)}" style="display:inline-block; padding:1px 8px; border-radius:999px; background:${cbg}; color:${cfg}; font-weight:700; white-space:nowrap;">${this.escapeHtml(rowText)}</span>`}
        ${rtText && !everyone ? `<span style="display:inline-block; padding:1px 8px; border-radius:999px; background:${rt.colour[0]}; color:${rt.colour[1]}; font-weight:700; white-space:nowrap;">${this.escapeHtml(rtText)}</span>` : ''}
        ${s.practicesUpcomingTotal > 0 ? `· proj ${s.practicesProjected}/${s.practicesUpcomingTotal}` : ''}
        · Game ${rsvpBadge(s.gameRsvp)}${this._rsvpTimeChips(playerId)}
        ${practicePills(s)}
      </div>`;
    };

    // A game's card (EventScreen.cardHtml): name + call-up / RSVP / dues /
    // injury chips; bench order + zone buttons on the right; then position
    // pills, the eligibility line, the contact line and whatever the
    // section adds.
    const playerRow = (p, extra = '') => ({
      name: `<span ${this._eligNameTitle(p.id)}style="overflow-wrap:break-word; white-space:normal; ${this._eligNameStyle(p.id)}">${this.escapeHtml(p.name)}</span>
            ${p.callUp ? (() => {
              // Which kind of invitee (owner 2026-10-22): ⭐ Standing
              // Call-up = a team_auto_invites rider (Rhoden, Pena); ↔ Call
              // In = rostered here invite-only from a same-level squad
              // (Lucca, mig 637); 🎟 Call Down = a per-game invite from a
              // capped squad above (APSL → CASA, migs 616/617, e.g. Luke);
              // 🎟 Call-up otherwise.  The cap still binds a standing
              // call-up — _isCallDown decides that, not the label.
              // Direction (mig 1069): the cap row still decides a capped
              // call-down; otherwise the invite badge (board order of the
              // from-team vs this game's team) says up / down / neither.
              const dir = p.badge && p.badge.dir;
              const down = this._isCallDown(p.id) || dir === 'down';
              const kind = p.standing ? 'standing' : p.callIn ? 'call_in' : down ? 'call_down' : dir === 'up' ? 'call_up' : 'invited';
              const fallback = { standing: '⭐ Standing Call-down', call_in: '↔ Call In', call_down: '🎟 Call Down', call_up: '🎟 Call-up', invited: '🎟 Invited' }[kind];
              const label = (window.MessageCopy && MessageCopy.block('invite_chip', kind)) || fallback;
              const [bg, fg] = { standing: ['#1e3a8a', '#bfdbfe'], call_in: ['#4c1d95', '#ddd6fe'], call_down: ['#7c2d12', '#fed7aa'], call_up: ['#166534', '#dcfce7'], invited: ['#78350f', '#fde68a'] }[kind];
              const tip = this._isCallDown(p.id) ? 'From the squad above — counts toward the league cap in starters/bench'
                : p.callIn ? 'Call In — rostered here, plays when invited; eligible'
                : "Invited for this game — the practice criteria don't apply, they're eligible";
              return `<span title="${tip}"
              style="padding:1px 8px; border-radius:999px; font-size:0.68rem; font-weight:700; white-space:nowrap;
                     background:${bg}; color:${fg};">${this.escapeHtml(label)}${p.fromTeam && !p.callIn ? ` · ${this.escapeHtml(p.fromTeam)}` : ''}</span>`;
            })() : ''}
            ${this.isCoach && !p.callUp ? this._rsvpStatusPill(p.id) : ''}
            ${this._duesFlag(p)}
            ${this.isCoach ? this._injuryChip(p.id) : ''}`,
      right: `${this.isCoach && this.zones.get(p.id) === 'bench' ? benchOrderControl(p) : ''}
            ${this.isCoach ? zoneButtons(p.id) : ''}`,
      body: `        ${this.isCoach ? positionPills(p) : ''}
        ${this.isCoach ? `
          <div style="display:flex; align-items:center; justify-content:space-between; gap:8px; margin-top:3px;">
            ${statsLine(p.id)}
            ${roleButtons(p)}
          </div>
        ` : ''}
        ${this.isCoach ? this._gameAttendanceHtml(p.id) : ''}
        ${this.isCoach && window.PersonStanding ? PersonStanding.html(this._personIdFor(p.id)) : ''}
        ${this.isCoach && !String(extra).includes('data-gc-contact') ? this._contactLine(p.id) : ''}
        ${extra}`,
    });

    // Multiple player cards per line instead of one full-width row each
    // (owner directive: "like on teams screen, so there is less blank
    // space on desktop") — every coach-view section (Starting/Bench/
    // Alternates/Going/collapsed Not-Going/No-Response) uses this same
    // auto-fill grid, each card wrapping playerRow's content in its own
    // bordered tile instead of a shared list divider.
    const cardGrid = (players, extra = null) =>
      this.cardGridHtml(players.map(p => this._cardWrap(p, playerRow(p, extra ? extra(p) : ''))));

    // Rolled up like every Event Center pill (owner 11/11: "no matter what
    // tab/pill in event center is clicked we need roll up"): Starting,
    // Bench, Alternates and Going are folds too, keyed by their label.
    const gridSection = (label, players, extra = null) =>
      collapsedSection(label, players, { extra, key: String(label).replace(/[^a-z]/gi, '').toLowerCase() || 'going' });

    // Not Going / No Response rolled up out of the way by default (owner
    // directive: "...have them rolled up so they are not in way") — a
    // coach almost never needs these, unlike Going.
    // key: which fold this is, so it stays open across the re-render a
    // REMIND tap triggers (owner 2026-10-22: "its still closing the no
    // response people and i need to open again").
    // 🎟 CALL IN on a 💤 Inactive card (mig 1076, owner 2026-11-05: "merge
    // them and have a call in button on the inactive for that event"): the
    // 📇 popup with the call-up preselected; sending it invites him and he
    // drops into No Response with the squad.  Coaches, official view only.
    const callInBtn = (p) => {
      if (!this.isCoach || this.lineupView !== 'official' || !window.SectionContact) return '';
      const pl = (this.players || []).find(x => Number(x.playerId) === Number(p.id));
      const personId = pl ? Number(pl.personId) : 0;
      const cand = personId && this.invites ? (this.invites.candidates || []).find(c => Number(c.person_id) === personId) : null;
      if (!cand) return '';
      return SectionContact.callupButton(this, this._fhEventId(), cand, {
        section: this.ev && this.ev.category,
        label: (window.MessageCopy && MessageCopy.block('contact_popup', 'callin_button')) || '🎟 CALL UP',
        onSent: () => this._loadInvites().then(() => this._render()),
      });
    };
    // Same open/closed memory and standing-open list as every EventScreen
    // fold (EventScreen.foldOpen); lineup_ keeps these apart from 👥 All
    // Players' own Not going / No response folds.
    const collapsedSection = (label, players, { top = '', extra = null, key = '' } = {}) =>
      this.cardFoldHtml('data-ec-fold', `lineup_${key}`, this.foldOpen(`lineup_${key}`), label, players.length, cardGrid(players, extra), { top });

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
    // Card buttons on Starting / Bench / Alternates — the player's own
    // message: names their role, magic link lands on this game (mig 384).
    // Dim once sent; amber "moved" when the role they were told is not
    // the one they hold now.
    const squadCard = (p) => {
      const personId = this._personIdFor(p.id);
      if (!personId) return '';
      const sent = ((this.squadNotice && this.squadNotice.people) || {})[personId] || {};
      // No squad role = the pool message (mig 593): the same personal
      // magic link, no role named — every card gets the buttons (owner
      // 2026-10-16: "call ups and ALL PLayers need email and text link
      // personalized to invite to game").
      const zone = this.zones.get(p.id) || 'pool';
      const moved = sent.told_zone && sent.told_zone !== zone;
      // One ✉ CONTACT button per card (mig 654; owner 2026-10-23: "its
      // confusing in game center what does what as far as communication …
      // needs to be more clear").  The card keeps the primary-channel
      // badge and one status line; WHAT / HOW and whether each way works
      // live in the contact sheet (_openContactSheet).
      const gap = this._regGapFor(personId);
      const regOn = !!(gap && !gap.player_done);
      const line = regOn ? this._leagueListLine() : null;
      const st = (this.textMarks && this.textMarks.people && this.textMarks.people[String(personId)]) || null;
      const cb = (tier, tokens) => (window.MessageCopy && MessageCopy.block('contact_box', tier, tokens)) || '';
      const cm = (tier, tokens) => (window.MessageCopy && MessageCopy.block('contact_menu', tier, tokens)) || '';
      const hasPhone = st ? !!st.phone : true;
      const consent = st ? st.consent : 'none';
      const badge = !hasPhone ? cb('badge_nophone') : consent === 'in' ? cb('badge_in')
                  : consent === 'stopped' ? cb('badge_stopped') : cb('badge_none');
      this._contactCtx = this._contactCtx || {};
      this._contactCtx[personId] = { name: p.name || '', noResp: !!(this._noRespIds && this._noRespIds.has(p.id)),
                                     gap: regOn ? gap : null, st,
                                     duesAlt: !!this.stats.get(Number(p.id))?.duesAlternate };
      const reply = st && st.reply_body ? cb('reply', { time: this._sentWhen(st.reply_at), body: st.reply_body }) : '';
      // One status line, always present, so a send never grows the card.
      const remindSent = (this.reminders || {})[personId] || {};
      const status = [
        moved ? `<span style="color:#fbbf24;">moved since told (${this.escapeHtml(sent.told_zone)})</span>` : this.escapeHtml(this._sentNote(sent)),
        this._contactCtx[personId].noResp ? this.escapeHtml(this._sentNote(remindSent)) : '',
        this._textMarkHtml(personId, 'game_link'),
        regOn ? `<span style="opacity:0.8;">${this.escapeHtml(this._regGapReason(gap))}</span>` : '',
        this._textMarkHtml(personId, 'reg_link'),
        line && line.bad ? `<span style="font-weight:800; color:#ef4444;">⚠ ${this.escapeHtml((window.MessageCopy && MessageCopy.block('reg_gap', 'card_stale')) || 'list check failed')}</span>` : '',
        reply ? `<span style="color:#38bdf8; font-weight:700;">${this.escapeHtml(reply)}</span>` : '',
      ].filter(Boolean).join(' · ');
      return `
        <div data-gc-contact style="margin-top:5px;">
          <div style="display:flex; align-items:center; justify-content:space-between; gap:6px;">
            <span style="font-size:0.68rem; font-weight:800;">${this.escapeHtml(badge)}</span>
            ${this._gcContactButton(personId)}
          </div>
          <div data-gc-squad-note style="font-size:0.66rem; opacity:0.85; min-height:1.3em; margin-top:3px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${status || '&nbsp;'}</div>
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
    // Messaging tools belong to the official lineup only: a draft's author
    // edits like a coach (isCoach flips per view), but a squad reminder or
    // a Game Link about a mock lineup would tell players a role they do
    // not hold.  The backend gates the sends on club admin; this keeps the
    // buttons off every draft view, admin or not.
    const canMessage = this.isCoach && this.lineupView === 'official';
    // Everyone plays: one Playing section (the Going RSVPs, as drawn), no
    // Bench / Alternates, and no squad reminder or Game Link — those name
    // a picked role, and nobody is picked.  The RSVP reminders stay.
    // Every card gets the personal GAME LINK buttons, role or not (the
    // pool message, mig 593) — No Response cards carry the RSVP REMIND
    // buttons as well.
    this._noRespIds = new Set(unassignedNoResponse.map(x => x.id));
    // 📣 One group bar (mig 654) in place of the squad bar and the No
    // Response bar: WHO, then HOW.  The buttons are the same tracked
    // sends as before (squad notice / remind-event), so dimming and
    // "everyone told ✓" carry over.
    const groupBar = this._groupBarHtml({
      squad: everyone ? 0 : squadSize, changed: told ? untold : 0,
      noResp: unassignedNoResponse.length, squadSent: this.squadNotice,
    }, remindBtn);
    const bothCards = canMessage ? squadCard : null;
    coach.controls = lineupControlsHtml;
    coach.canMessage = canMessage;
    coach.groupBar = groupBar;
    if (everyone) {
      coach.sections = [
        gridSection(this.escapeHtml(this._copyLe('section') || 'Going'), byZone.starter, canMessage ? squadCard : null),
        collapsedSection('✗ Not Going', unassignedNotGoing, canMessage ? { extra: squadCard, key: 'notgoing' } : { key: 'notgoing' }),
        collapsedSection('– No Response', unassignedNoResponse, canMessage ? { extra: bothCards, key: 'noresponse' } : { key: 'noresponse' }),
        unassignedReserves.length ? collapsedSection(this.escapeHtml(reservesLabel), unassignedReserves, { key: 'reserves', top: this._askReservesBtn() }) : '',
        collapsedSection(this.escapeHtml(injuredLabel), unassignedInjured, { key: 'injured' }),
        collapsedSection(this.escapeHtml(practiceSquadLabel), unassignedPracticeSquad, { key: 'practice_squad', extra: callInBtn }),
        unassignedNotEligible.length ? collapsedSection(this.escapeHtml(notEligibleLabel), unassignedNotEligible, { key: 'not_eligible' }) : '',
        unassignedPool.length ? collapsedSection(this.escapeHtml(poolLabel), unassignedPool, { key: 'callup_pool', extra: callInBtn }) : '',
        collapsedSection(this.escapeHtml(inactiveLabel), unassignedInactive, { key: 'inactive', extra: callInBtn }),
        collapsedSection(this.escapeHtml(suspendedLabel), unassignedSuspended, { key: 'suspended' }),
        this._renderCallupSection(),
      ].join('');
      paint(this._lineupBodyHtml(panels));
      return;
    }
    coach.sections = [
      this.isCoach ? gridSection('Starting', [...byZone.starter].sort((a, b) => {
        // In formation order (1 = keeper …), same numbers as the pills.
        const order = (pl) => startingPositions.find(pos => slotToPlayerId.get(pos.id) === pl.id)?.sortOrder ?? Infinity;
        return order(a) - order(b);
      }), canMessage ? squadCard : null) : '',
      gridSection('Bench', byZone.bench, canMessage ? squadCard : null),
      gridSection('Alternates', byZone.alternate, canMessage ? squadCard : null),
      this.isCoach ? gridSection('✓ Going', unassignedGoing, canMessage ? squadCard : null) : '',
      this.isCoach && unassignedIneligible.length ? gridSection('⛔ Going · Ineligible (dues)', unassignedIneligible, canMessage ? squadCard : null) : '',
      this.isCoach ? collapsedSection('✗ Not Going', unassignedNotGoing, canMessage ? { extra: squadCard, key: 'notgoing' } : { key: 'notgoing' }) : '',
      this.isCoach ? collapsedSection('– No Response', unassignedNoResponse, canMessage ? { extra: bothCards, key: 'noresponse' } : { key: 'noresponse' }) : '',
      this.isCoach && unassignedReserves.length ? collapsedSection(this.escapeHtml(reservesLabel), unassignedReserves, { key: 'reserves', top: this._askReservesBtn() }) : '',
      this.isCoach ? collapsedSection(this.escapeHtml(injuredLabel), unassignedInjured, { key: 'injured' }) : '',
      this.isCoach ? collapsedSection(this.escapeHtml(practiceSquadLabel), unassignedPracticeSquad, { key: 'practice_squad', extra: callInBtn }) : '',
      this.isCoach && unassignedNotEligible.length ? collapsedSection(this.escapeHtml(notEligibleLabel), unassignedNotEligible, { key: 'not_eligible' }) : '',
      this.isCoach && unassignedPool.length ? collapsedSection(this.escapeHtml(poolLabel), unassignedPool, { key: 'callup_pool', extra: callInBtn }) : '',
      this.isCoach ? collapsedSection(this.escapeHtml(inactiveLabel), unassignedInactive, { key: 'inactive', extra: callInBtn }) : '',
      this.isCoach ? collapsedSection(this.escapeHtml(suspendedLabel), unassignedSuspended, { key: 'suspended' }) : '',
      this.isCoach ? this._renderCallupSection() : '',
    ].join('');
    paint(this._lineupBodyHtml(panels));
  }

  // The coach's lineup body.  📝 Text view: every panel under the graphic,
  // as before.  Graphic-first (default): no toolbar and no card lists — the
  // card does that work — and the rest (📣 message a group, reg gaps) go
  // into ☰ like every other extra.
  _lineupBodyHtml(panels) {
    if (this._textViewOn() || !this._extrasInMenu()) return Panel.render(panels, this);
    return this._renderPanels(panels.filter(p => !['lineup_controls', 'sections'].includes(p.key)));
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
  // Late / leaving early (migration 436): the yellow "arrives 7:20" /
  // "leaves 8:30" chips a player set on #my, beside the game RSVP badge.
  // Read from the game's event row (this.ev.rsvps).
  _rsvpTimeChips(playerId) {
    const ev = this.ev;
    const personId = this._personIdFor(playerId);
    if (!ev || !personId) return '';
    const r = (Array.isArray(ev.rsvps) ? ev.rsvps : []).find(x => x && x.person_id === personId);
    if (!r || (!r.arrive_label && !r.leave_label)) return '';
    const mc = window.MessageCopy;
    const t = (tier, tokens, fb) => (mc && mc.block && mc.block('rsvp_times', tier, tokens)) || fb;
    const chip = (text) => `<span style="display:inline-block; margin-left:5px; padding:1px 6px; border-radius:999px;
        background:#fde68a; color:#1f2937; font-size:0.62rem; font-weight:800; vertical-align:middle;">${this.escapeHtml(text)}</span>`;
    return (r.arrive_label ? chip(t('chip_arrive', { time: r.arrive_label }, `arrives ${r.arrive_label}`)) : '')
         + (r.leave_label  ? chip(t('chip_leave',  { time: r.leave_label },  `leaves ${r.leave_label}`))  : '');
  }

  // Not Going from standby took the player off the alternates (the save
  // did it): drop the card here too and say so, in the DB's words.
  _onMyAvailabilitySaved(data) {
    const dropped = data && data.standby_dropped;
    if (!dropped || !dropped.player_id) return false;
    this.zones.delete(Number(dropped.player_id));
    this._render();
    const note = this.element.querySelector('[data-gc-avail-msg]');
    if (note && dropped.message) { note.style.display = ''; note.textContent = dropped.message; }
    return true;
  }

  // The details roster (coach-only) is what knows a card's person.
  // ⋯ sheet: the RSVP row when there is one, else the roster's name (a
  // player on the lineup who never answered).
  _sheetPerson(pid) {
    const base = super._sheetPerson(pid);
    if (base.firstName) return base;
    const r = (this.roster || []).find(x => Number(this._personIdFor(x.id)) === Number(pid));
    return r ? { ...base, firstName: r.name || '' } : base;
  }

  _personIdFor(playerId) {
    const row = (this.players || []).find(x => Number(x.playerId) === Number(playerId));
    return row && row.personId ? Number(row.personId) : null;
  }

  // Phone + email on every player card, whatever the section — Going,
  // Not Going, No Response, Starting/Bench (owner 2026-10-16: "every
  // player should have contact info on card. going, not going call up
  // etc").  Same rows the bulk-message buttons use (/api/game-message
  // recipients, mig 506): the parent's contact for youth, hence the
  // (parent) tag.  The Contact popup lets a coach reach one player
  // off-script; the REMIND/GAME LINK buttons stay the tracked, DB-copy
  // path.  Admin/coach endpoint — anyone else has no gameRecipients and
  // gets no line.
  _contactLine(playerId) {
    const personId = this._personIdFor(playerId);
    const btn = personId ? this._gcContactButton(personId) : '';
    if (!btn) return '';
    const r = (this.gameRecipients || []).find(x => Number(x.personId) === personId);
    return `<div style="font-size:0.66rem; opacity:0.9; margin-top:4px; display:flex; gap:6px; flex-wrap:wrap; align-items:center;">
      ${btn}
      ${r && r.viaParent ? `<span style="opacity:0.7;">(parent)</span>` : ''}
    </div>`;
  }

  // ── The one 📇 Contact popup for a player (owner 2026-11-03: "no more
  // ways outside of contact button to contact. contact popup is all
  // inclusive" + "consistent within men or boys or girls") ────────────
  // This game's own messages lead — the registration form on a gap, the
  // dues note for a dues alternate, the RSVP reminder when they owe an
  // answer, the personal game link — then the section's list
  // (components/section-contact.js), the same one #teams and Event Center
  // offer.  Every per-card way in (the card button, the registration
  // banner's fix, the dues chip, the registration strip) opens this.
  _gcContactCfg(personId, defaultKey = null) {
    if (!window.ContactPopup || !window.SectionContact || !personId) return null;
    const pl = (this.players || []).find(x => Number(x.personId) === personId) || {};
    const st = (this.textMarks && this.textMarks.people && this.textMarks.people[String(personId)]) || null;
    const gr = (this.gameRecipients || []).find(x => Number(x.personId) === personId) || null;
    // Every parent separately when the contact states are known (admins,
    // mig 682); else the game's recipient row (coaches).
    const recipients = (st && Array.isArray(st.recipients) && st.recipients.length
      ? st.recipients.map(x => ({ personId: x.recipient_person_id || personId, rid: x.recipient_person_id || null,
                                  name: x.recipient_name || pl.name || '', phone: x.phone || null, email: x.email || null, forPersonId: personId }))
      : gr ? [{ personId, rid: null, name: gr.name || '', phone: gr.phone || null, email: gr.email || null, forPersonId: personId }] : [])
      .filter(x => x.phone || x.email);
    // Never a person without a contact button (owner 11/11): the popup
    // greys each route with its reason and still offers 📋 Copy.
    if (!recipients.length) recipients.push({ personId, rid: null, name: pl.name || (gr && gr.name) || '', phone: null, email: null, forPersonId: personId });

    const only = (rc) => (rc.rid ? { recipient_person_ids: [rc.rid] } : {});
    const hrefOf = (data, channel) => {
      const x = (data.sends && data.sends[0]) || data;
      const href = channel === 'email' ? (x.gmail_href || x.mailto_href) : x.sms_href;
      if (!href) throw new Error('No message came back');
      return { ...x, href };
    };
    const flushLineup = async () => { if (this._saveTimer) { clearTimeout(this._saveTimer); this._saveTimer = null; await this._saveLineup(); } };
    const refreshMarks = () => this._loadTextMarks().then(() => this._render());

    const gap = this._regGapFor(personId);
    const regOn = !!(gap && !gap.player_done);
    const duesAlt = !!(pl.playerId != null && this.stats.get(Number(pl.playerId))?.duesAlternate);
    const noResp = !!(pl.playerId != null && this._noRespIds && (this._noRespIds.has(pl.playerId) || this._noRespIds.has(Number(pl.playerId)) || this._noRespIds.has(String(pl.playerId))));
    const ctx = [];
    // 💤 Inactive (mig 1217, owner 2026-11-10: "it should have that as
    // option just like active players"): his RSVP link is the 🎟 call-up —
    // first and preselected; the game link alone can't let him answer.
    const cand = !pl.callUp && pl.squadStatus === 'inactive' && this.invites
      ? (this.invites.candidates || []).find(c => Number(c.person_id) === personId) : null;
    if (cand && this._fhEventId()) ctx.push(SectionContact.callupMessage(this, this._fhEventId(), personId, {
      onSent: () => this._loadInvites().then(() => this._render()),
    }));
    if (regOn) ctx.push({
      key: 'reg', label: this._cm('what_reg', { form: gap.form_label || '' }) || '📝 Registration form',
      subject: gap.subject || '', body: gap.body || '', purpose: `reg_link:${this._fhEventId()}`,
      sendClub: async () => this._clubSend(`/api/calendar/events/${this._fhEventId()}/registration-gaps/text`, { person_id: personId }),
      onSent: refreshMarks,
    });
    if (duesAlt) ctx.push({
      key: 'dues', label: this._cm('what_dues') || '💰 Dues note', noClub: true, purpose: `dues:${this.matchId}`,
      resolve: async (rc, channel) => hrefOf(await this._postReminder('/api/rsvp-board/dues-note',
        { match_id: Number(this.matchId), person_id: personId, channel, ...only(rc) }), channel),
    });
    if (noResp) ctx.push({
      key: 'remind', label: this._remindLabel(), noClub: true, purpose: `remind:${this.matchId}`,
      resolve: async (rc, channel) => hrefOf(await this._postReminder('/api/rsvp-board/remind',
        { person_id: personId, channel, fh_event_id: this._fhEventId() || 0, ...only(rc) }), channel),
      onSent: () => this._loadReminders().then(() => this._render()),
    });
    ctx.push({
      key: 'game', label: this._cm('what_game') || '🏟 Game link', purpose: `game_link:${this.matchId}`,
      resolve: async (rc, channel) => {
        await flushLineup();
        const data = await this._postReminder('/api/rsvp-board/squad-notice', { match_id: Number(this.matchId), person_id: personId, channel, ...only(rc) });
        this.squadNotice = data.status || this.squadNotice;
        return hrefOf(data, channel);
      },
      sendClub: async (rc) => {
        await flushLineup();
        const data = await this._clubSend('/api/rsvp-board/squad-notice', { match_id: Number(this.matchId), person_id: personId, channel: 'club_sms', ...only(rc) });
        if (data.status) this.squadNotice = data.status;
      },
      onSent: refreshMarks,
    });

    const parentRow = recipients.find(x => x.rid && x.rid !== personId);
    const messages = SectionContact.messages(this.ev && this.ev.category, {
      screen: this, playerId: personId, first: pl.firstName || '',
      parentFirst: parentRow ? String(parentRow.name || '').split(' ')[0]
                 : (gr && gr.viaParent ? String(gr.name || '').split(' ')[0] : ''),
      context: ctx,
    });
    // A asked-for message this section doesn't offer (🏃 is men's only)
    // falls back to the screen's own first one.
    const wanted = defaultKey && messages.some(m => m.key === defaultKey) ? defaultKey : null;
    return {
      key: `gc-player:${personId}`, screen: this, recipients,
      messages,
      defaultKey: wanted || ctx[0].key,
      flagged: regOn || duesAlt || noResp,
      title: `Contact ${pl.name || [pl.firstName, pl.lastName].filter(Boolean).join(' ')}`,
    };
  }

  // The player sheet's 📇 Contact on a game: this game's own list (reg,
  // dues, RSVP reminder, call-up, game link) for a lineup player; anyone
  // else (a 🪑 Reserve not on the roster) gets the event's.
  _sheetContactCfg(pid) {
    const id = Number(pid);
    const inLineup = (this.players || []).some(x => Number(x.personId) === id);
    return (inLineup && this._gcContactCfg(id)) || super._sheetContactCfg(id);
  }

  _gcContactButton(personId, extra = {}) {
    const cfg = this._gcContactCfg(personId);
    return cfg ? ContactPopup.button({ ...cfg, ...extra }) : '';
  }

  _gcContactOpen(personId, defaultKey) {
    const cfg = this._gcContactCfg(personId, defaultKey);
    if (cfg) ContactPopup.open(cfg);
  }

  // A tracked club-number send (game link / registration form): the
  // server writes the delivery mark the card reads.
  async _clubSend(url, payload) {
    const res = await this.auth.fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
    const data = await res.json().catch(() => ({}));
    if (!res.ok || data.error) {
      const why = data.error || data.message || `HTTP ${res.status}`;
      throw new Error(why === 'not_opted_in' ? ((window.MessageCopy && MessageCopy.block('text_mark', 'no_consent')) || why) : why);
    }
    return data;
  }

  // Who is injured right now (person_injuries, migration 510) — set on
  // #teams, shown here as the same chip on the player's card in every
  // section (owner 2026-10-02: "show the injury chip in game center no
  // response too").  The words, colours and tooltip are the server's.
  // Admins and coaches only; anyone else just gets no chips.
  async _loadHealth() {
    this.health = { people: {}, statuses: [], copy: {} };
    try {
      const res = await this.auth.fetch('/api/person-health');
      const data = await res.json();
      if (res.ok) this.health = { people: data.people || {}, statuses: data.statuses || [], copy: data.copy || {} };
    } catch (err) {
      console.warn('[game-center] health unavailable:', err);
    }
  }

  _isInjured(playerId) {
    const personId = this._personIdFor(playerId);
    const mine = personId && this.health && this.health.people[personId];
    return !!(mine && mine.label);
  }

  _injuryChip(playerId) {
    const personId = this._personIdFor(playerId);
    const mine = personId && this.health && this.health.people[personId];
    if (!mine || !mine.label) return '';
    const st = (this.health.statuses || []).find(x => x.code === mine.code) || {};
    return `<span title="${this.escapeHtml(this.health.copy.select_title || '')}"
                  style="display:inline-block; padding:1px 8px; border-radius:999px; font-size:0.68rem; font-weight:700; white-space:nowrap; background:${st.colorBg || '#f59e0b'}; color:${st.colorFg || '#422006'};">${this.escapeHtml(mine.label)}</span>`;
  }

  // 📇 Opponent contacts → screens/game-center/opponent-contacts.js (GameCenterOpponent, mixed in).

  // 🎟 Call-ups — the same club-pass invites the Event Center's Invites
  // pill offers (fh_event_invites, mig 355), as a section alongside the
  // RSVP sections here (owner 2026-10-16: "this should be available from
  // game center … could be a section like the other rsvp sections").
  // Candidates come from fh_event_invite_candidates(): for youth, every
  // player within clubs.club_pass_years_up (2) single-age years below the
  // game's age — all U8/U9s for a U10 game, all U10/U11s for U12 — and
  // for adults the section's other squads.  An invite row is the ONLY way
  // a call-up sees the game on their page (never tag the younger team).
  _fhEventId() { return (this.ev && this.ev.match_id === this.matchId && this.ev.fh_event_id) || (this.matchDetails && this.matchDetails.fh_event_id) || null; }

  // ✅ Attendance on game cards (owner 11/7: "we should be able to take
  // attendance from event center … for games and practices"): the same
  // P/A/L/E row a practice card carries (EventScreen._attendanceCell), the
  // same /api/calendar/events/:id/attendance, the same who-may-mark
  // (can_mark = this game's coaches + club admins).  From game day on, so
  // the lineup cards stay clean all week; only people the backend counts
  // on this game (its teams, coaches, live invites) get the row.
  async _loadGameAttendance() {
    const id = this._fhEventId();
    if (!id) { this.att = null; return; }
    try {
      const res = await this.auth.fetch(`/api/calendar/events/${id}/attendance`);
      const body = res.ok ? await res.json() : null;
      if (this._fhEventId() !== id) return;
      const viewer = body ? Viewer.fromAttendance(body) : null;
      this.att = body ? { viewer, me: Number(body.me_person_id) || 0,
                          roster: new Map((body.roster || []).map(r => [Number(r.person_id), r])) } : null;
    } catch (err) {
      console.warn('[game-center] attendance unavailable:', err);
      this.att = null;
    }
  }

  _gameDayReached() {
    const s = this.ev && this.ev.starts_at;
    if (!s) return true;
    const d = new Date(s);
    if (isNaN(d)) return true;
    d.setHours(0, 0, 0, 0);
    return Date.now() >= d.getTime();
  }

  // A game's roll opens at kick-off (owner 11/19 "game needs it too after
  // game starts"); a practice's from its day (EventScreen).
  _boxAttOpen() {
    const d = new Date(this.ev && this.ev.starts_at);
    return isNaN(d) ? false : Date.now() >= d.getTime();
  }

  _gameAttendanceHtml(playerId) {
    if (!this.att || !this.viewer.canMark() || !this._gameDayReached()) return '';
    const personId = this._personIdFor(playerId);
    if (!personId || !this.att.roster.has(personId)) return '';
    const label = (window.MessageCopy && MessageCopy.block('event_center', 'attendance_label')) || 'Attendance';
    return `<div style="display:flex; justify-content:flex-end; align-items:center; gap:6px; margin-top:4px;">
      <span style="font-size:0.68rem; opacity:0.7;">${this.escapeHtml(label)}</span>${this._attendanceCell(personId)}</div>`;
  }

  // EventScreen's load (caps + suspended ride along); a send or a withdraw
  // reloads it and the card joins or leaves the squad's lists straight away
  // (mig 1069), not on the next poll.  A failed load reads as none here.
  async _loadInvites() {
    await super._loadInvites();
    if (this.invites && this.invites.error) this.invites = null;
    if (this.invites && this.loaded) this._foldInCallups();
  }

  // ⚠ Going but not on the official roster (mig 638; owner 2026-10-22:
  // "if a player is set going to a game and NOT on official roster yet
  // then there should be on game center a quick send registration link
  // for apsl or casa").  The server picks the league's form and fills its
  // link; a league with no form answers an empty list.
  async _loadRegGaps() {
    const id = this._fhEventId();
    if (!id) { this.regGaps = null; return; }
    try {
      const res = await this.auth.fetch(`/api/calendar/events/${id}/registration-gaps`);
      const body = await res.json().catch(() => null);
      this.regGaps = res.ok && body ? (body.gaps || []) : null;
      this.leagueList = res.ok && body ? (body.league_list || null) : null;
      // Every list the check reads (mig 1011: APSL Active + Reserve).
      this.leagueLists = res.ok && body ? (body.league_lists || (body.league_list ? [body.league_list] : [])) : [];
    } catch (err) {
      this.regGaps = null;
      this.leagueList = null;
      this.leagueLists = [];
    }
  }

  // 🌐 Re-pull the league's own list (the CASA sheet) once per game open
  // (mig 645; owner 2026-10-23: "not on casa roster as looked up … on
  // screen load").  The same refresh #teams runs; the gaps then reload
  // from the fresh list.  A failed pull keeps yesterday's names and the
  // strip says so in red — "we need to make sure we show that it failed".
  async _pullLeagueList() {
    const id = this._fhEventId();
    const lists = (this.leagueLists || []).filter(l => l && l.team_id);
    if (!id || !lists.length || this._leagueListPulledFor === id) return;
    this._leagueListPulledFor = id;
    this._leagueListState = 'pulling';
    this._leagueListError = null;
    this._leagueListFailed = null;
    this._render();
    // One at a time — never parallel TeamPass pulls (one account, its
    // sessions race).  APSL's two lists share one TeamPass page.
    for (const list of lists) {
      try {
        const res = await this.auth.fetch('/api/mens-roster/official-roster-refresh', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ teamId: list.team_id }),
        });
        const body = await res.json().catch(() => ({}));
        if (!res.ok || body.error || !(body.names || []).length)
          throw new Error(body.error || body.message || `no names parsed (HTTP ${res.status})`);
      } catch (err) {
        this._leagueListState = 'fail';
        this._leagueListError = err.message;
        this._leagueListFailed = list.source_id;
        break;
      }
    }
    if (this._leagueListState !== 'fail') this._leagueListState = 'ok';
    if (this._fhEventId() !== id) return;
    await this._loadRegGaps();
    this._render();
  }

  // The league lists' state line for the strip: 🟡 pulling, ✓ checked,
  // or ⚠ failed / never pulled — the last two in red, naming the list.
  _leagueListLine() {
    const lists = (this.leagueLists && this.leagueLists.length) ? this.leagueLists : (this.leagueList ? [this.leagueList] : []);
    if (!lists.length) return null;
    const copy = (tier, tokens) => (window.MessageCopy ? MessageCopy.block('reg_gap', tier, tokens) : '') || '';
    const when = (iso) => iso ? new Date(iso).toLocaleString([], { weekday: 'short', hour: 'numeric', minute: '2-digit' }) : '';
    const all = lists.map(l => l.league || '').filter(Boolean).join(' + ');
    if (this._leagueListState === 'pulling') return { bad: false, text: copy('list_pulling', { league: all }) };
    const never = lists.find(l => !l.names_pulled_at);
    if (never) return { bad: true, text: copy('list_never', { league: never.league || '' }) };
    const failed = lists.find(l => (this._leagueListState === 'fail' && l.source_id === this._leagueListFailed) || l.ok === false);
    if (failed) return { bad: true, text: copy('list_failed', { league: failed.league || '', time: when(failed.names_pulled_at),
                                                                note: (failed.source_id === this._leagueListFailed && this._leagueListError) || failed.note || '?' }) };
    const oldest = lists.map(l => l.fetched_at).filter(Boolean).sort()[0];
    return { bad: false, text: copy('list_ok', { league: all, time: when(oldest), n: lists.reduce((a, l) => a + (Number(l.names) || 0), 0) }) };
  }

  // ---- Can't-play warnings (mig 661) ----
  //
  // Owner 2026-10-23: "we need a warning system on game center that a
  // player is not on roster or in the case of call downs that there are
  // too many call downs … telegraph the remedy and put that player in red
  // like the whole card should be flashing red".  A registration gap
  // (Going, not on the league's list / roster, or a call-down once both
  // squad spots are taken) pulses red with why and a Fix button; a player
  // who already submitted is amber and steady.  Coaches only.

  _regWarnCopy(tier, tokens, fallback) {
    return (window.MessageCopy && MessageCopy.block('reg_warning', tier, tokens)) || fallback || '';
  }

  // Why this gap can't play, in one line.
  _regWarnText(g) {
    const league = (this.leagueList && this.leagueList.league) || 'league';
    if (g.player_done) return this._regWarnCopy('waiting', { league });
    if (g.reason === 'calldown_cap_full') {
      const cap = ((this.invites && this.invites.caps) || [])[0] || {};
      return this._regWarnCopy('calldown', { used: cap.used ?? '?', max: cap.max ?? '?', league });
    }
    if (g.reason === 'not_on_list') return this._regWarnCopy('not_on_list', { league });
    return this._regWarnCopy('not_on_roster', { status: g.status_label || 'no status' });
  }

  // Every card in a section grid comes through here — EventScreen's one
  // player card (cardHtml), plain, or — for a registration gap — the red
  // pulsing one with the banner and the fix on top.
  _cardWrap(p, parts) {
    const personId = this._personIdFor(p.id);
    const g = this.isCoach && personId ? this._regGapFor(personId) : null;
    const id = personId ? `gc-card-${personId}` : '';
    const sheet = this._staffView() && personId ? personId : null;
    if (!g) return this.cardHtml({ id, sheet, ...parts });
    this._ensureWarnStyles();
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const waiting = !!g.player_done;
    const canFix = !waiting && this.lineupView === 'official';
    const banner = `
      <div style="padding:6px 10px; font-size:0.74rem; font-weight:800; color:#fff; background:${waiting ? '#b45309' : '#b91c1c'};">
        ${esc(this._regWarnText(g))}
        ${canFix ? `<div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-top:5px;">
          <button type="button" data-gc-fix-reg="${personId}" style="padding:5px 12px; border-radius:6px; border:2px solid #fff; cursor:pointer;
                  font-weight:900; font-size:0.76rem; color:#b91c1c; background:#fff;">${esc(this._regWarnCopy('fix'))}</button>
          ${g.reason === 'calldown_cap_full' ? `<span style="font-weight:600; opacity:0.9;">${esc(this._regWarnCopy('calldown_alt'))}</span>` : ''}
        </div>` : ''}
      </div>`;
    return this.cardHtml({ id, sheet, ...parts, banner, cls: waiting ? 'gc-warn-wait' : 'gc-warn-alert' });
  }

  // The pulse lives in one stylesheet; reduced-motion users get a steady
  // red border instead of the flash.
  _ensureWarnStyles() {
    if (document.getElementById('gc-warn-styles')) return;
    const st = document.createElement('style');
    st.id = 'gc-warn-styles';
    st.textContent = `
      @keyframes gcWarnPulse {
        0%, 100% { box-shadow: 0 0 0 2px #dc2626, 0 0 0 0 rgba(220,38,38,0.0); background: rgba(220,38,38,0.10); }
        50%      { box-shadow: 0 0 0 3px #ef4444, 0 0 18px 4px rgba(239,68,68,0.55); background: rgba(220,38,38,0.28); }
      }
      .gc-warn-alert { animation: gcWarnPulse 1.1s ease-in-out infinite; }
      .gc-warn-wait  { box-shadow: 0 0 0 2px #d97706; background: rgba(217,119,6,0.10); }
      @media (prefers-reduced-motion: reduce) {
        .gc-warn-alert { animation: none; box-shadow: 0 0 0 3px #dc2626; background: rgba(220,38,38,0.18); }
      }`;
    document.head.appendChild(st);
  }

  // ---- Contact sheet hooks (the sheet itself is EventScreen's) ----
  // WHAT a game card can send: the game link to everyone, the RSVP
  // reminder first when they have not answered, the registration form on
  // a gap, the dues note for a dues alternate (mig 613/687), a blank text.
  contactWhats(c) {
    const whats = [{ key: 'game', label: this._cm('what_game') }];
    if (c.noResp) whats.unshift({ key: 'remind', label: this._cm('what_remind') });
    if (c.gap) whats.push({ key: 'reg', label: this._cm('what_reg', { form: c.gap.form_label || '' }) });
    if (c.duesAlt) whats.push({ key: 'dues', label: this._cm('what_dues') });
    whats.push({ key: 'blank', label: this._cm('what_blank') });
    return whats;
  }

  // Registration first, then dues, then the RSVP reminder / game link.
  contactRecommended(c, whats) { return c.gap ? 'reg' : c.duesAlt ? 'dues' : whats[0].key; }
  contactHasProblem(c) { return !!(c.gap || c.duesAlt || c.noResp); }

  // The club number carries the game link and the registration form.
  clubTextWhats() { return ['game', 'reg']; }

  eventId() { return this._fhEventId() || super.eventId(); }

  async afterContactSend() { await this._loadTextMarks(); }

  // The tracked personal message for some of a player's parents, built
  // server-side — one entry per parent, each with their own sign-in link
  // (mig 682).  Dues note and game link are a game's; the RSVP reminder is
  // EventScreen's.
  async _composeSends(what, channel, ids) {
    const pid = Number(this._contactSheet.personId);
    const body = { person_id: pid, channel, ...(ids.length ? { recipient_person_ids: ids } : {}) };
    if (what === 'dues') {
      const data = await this._postReminder('/api/rsvp-board/dues-note', { ...body, match_id: Number(this.matchId) });
      return data.sends || [data];
    }
    if (what !== 'game') return super._composeSends(what, channel, ids);
    if (this._saveTimer) { clearTimeout(this._saveTimer); this._saveTimer = null; await this._saveLineup(); }
    const data = await this._postReminder('/api/rsvp-board/squad-notice', { ...body, match_id: Number(this.matchId) });
    this.squadNotice = data.status || this.squadNotice;
    return data.sends || [data];
  }

  // The FH Texter message for what only a game sends — the registration
  // form, the dues note, the game link — and its RSVP reminder (purpose
  // keyed on the match, as its delivery marks read it); a blank text is
  // EventScreen's.
  async _relayMessage(what, c, t, personId, only) {
    if (what === 'reg') {
      return { href: this.buildSmsComposeHref({ to: c.gap.phone, body: c.gap.body || '' }), tokenId: 0, purpose: `reg_link:${this._fhEventId()}` };
    }
    if (what === 'remind') {
      const data = await this._postReminder('/api/rsvp-board/remind', { person_id: personId, channel: 'sms', fh_event_id: this._fhEventId() || 0, ...only });
      await this._loadReminders();
      return { href: data.sms_href, tokenId: data.token_id || 0, purpose: `remind:${this.matchId}` };
    }
    if (what === 'dues') {
      const data = await this._postReminder('/api/rsvp-board/dues-note',
        { match_id: Number(this.matchId), person_id: personId, channel: 'sms', ...only });
      return { href: data.sms_href, tokenId: data.token_id || 0, purpose: `dues:${this.matchId}` };
    }
    if (what === 'game') {
      if (this._saveTimer) { clearTimeout(this._saveTimer); this._saveTimer = null; await this._saveLineup(); }
      const data = await this._postReminder('/api/rsvp-board/squad-notice',
        { match_id: Number(this.matchId), person_id: personId, channel: 'sms', ...only });
      this.squadNotice = data.status || this.squadNotice;
      return { href: data.sms_href, tokenId: data.token_id || 0, purpose: `game_link:${this.matchId}` };
    }
    return super._relayMessage(what, c, t, personId, only);
  }

  // 📣 WHO pills, then the HOW buttons for that group (the tracked squad
  // notice / remind-event sends).  In "everyone plays" games there is no
  // squad, so only No response is offered.
  _groupBarHtml({ squad, changed, noResp, squadSent }, remindBtn) {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const whos = [
      squad ? { key: 'squad', label: this._cm('who_squad', { n: squad }) } : null,
      changed ? { key: 'changed', label: this._cm('who_changed', { n: changed }) } : null,
      { key: 'noresp', label: this._cm('who_noresp', { n: noResp }) },
    ].filter(Boolean);
    const who = whos.some(w => w.key === this._groupWho) ? this._groupWho : whos[0].key;
    const n = who === 'squad' ? squad : who === 'changed' ? changed : noResp;
    const pill = (w) => `<button type="button" data-gc-group-who="${w.key}" style="padding:4px 10px; border-radius:999px; cursor:pointer; font-size:0.74rem; font-weight:700;
        border:1px solid ${w.key === who ? '#0284c7' : 'var(--border-color)'}; background:${w.key === who ? 'rgba(2,132,199,0.2)' : 'transparent'}; color:inherit;">${esc(w.label)}</button>`;
    const btns = !n ? `<span style="opacity:0.7;">${esc(this._cm('group_none'))}</span>`
      : who === 'noresp'
        ? `${remindBtn('data-gc-remind-all="sms"', esc(this._cm('group_text')), '#0284c7', '')}
           ${remindBtn('data-gc-remind-all="email"', esc(this._cm('group_email')), '#7c3aed', '')}`
        : `${remindBtn(`data-gc-squad-notice="sms" data-scope="${who === 'changed' ? 'changed' : 'all'}"`, esc(this._cm('group_text')), '#0284c7', '', who === 'squad' ? squadSent?.sms : null)}
           ${remindBtn(`data-gc-squad-notice="email" data-scope="${who === 'changed' ? 'changed' : 'all'}"`, esc(this._cm('group_email')), '#7c3aed', '', who === 'squad' ? squadSent?.email : null)}`;
    return `
      <div style="margin:0 0 12px; padding:8px 12px; border:1px solid var(--border-color); border-radius:10px;">
        <div style="font-weight:800; font-size:0.88rem; margin-bottom:6px;">${esc(this._cm('bar_title'))}</div>
        <div style="display:flex; gap:6px; flex-wrap:wrap; margin-bottom:6px;">
          <span style="font-size:0.7rem; font-weight:800; opacity:0.6; align-self:center;">${esc(this._cm('who').toUpperCase())}</span>${whos.map(pill).join('')}</div>
        <div style="font-size:0.74rem; opacity:0.75; margin-bottom:6px;">${esc(this._cm(who === 'noresp' ? 'group_what_noresp' : 'group_what_squad'))}</div>
        <div style="display:flex; gap:8px; flex-wrap:wrap; align-items:center; font-size:0.78rem;">${btns}
          <span data-gc-squad-result data-gc-remind-result style="flex-basis:100%;"></span></div>
      </div>`;
  }

  // 📲 Club-number texts (mig 647): EventScreen's marks for this game's
  // event, plus FH Texter's status for 📲 Text's fallback (mig 667/673).
  async _loadTextMarks() {
    await Promise.all([super._loadTextMarks(), this._loadRelay()]);
  }

  // sent → delivered ✓ / FAILED — reason, then opened ✓ once the link
  // in it was really tapped.
  _textMarkHtml(personId, kind) {
    const all = this.textMarks && this.textMarks.marks[String(personId)];
    if (!all || !all[kind]) return '';
    const copy = (tier, tokens) => (window.MessageCopy && MessageCopy.block('text_mark', tier, tokens)) || '';
    // Two parents texted separately → one mark each, named (mig 682/683).
    const by = Array.isArray(all[kind + '_by']) && all[kind + '_by'].length > 1 ? all[kind + '_by'] : [all[kind]];
    const people = (this.textMarks.people || {})[String(personId)] || {};
    const nameOf = (rid) => ((people.recipients || []).find(r => r.recipient_person_id === rid) || {}).recipient_name || '';
    return by.map(m => {
      const time = this._sentWhen(m.sent_at);
      const st = m.status || '';
      const failed = st === 'failed' || st === 'undelivered';
      const text = failed ? copy('failed', { time, error: m.error_text || m.error_code || st })
                 : st === 'delivered' ? copy('delivered', { time })
                 : st === 'queued' ? copy('queued', { time }) : copy('sent', { time });
      const opened = m.opened_at ? ` · ${copy('opened', { time: this._sentWhen(m.opened_at) })}` : '';
      // 📱 = went from the owner's phone through FH Texter (mig 673).
      const via = m.via === 'phone' ? `${copy('via_phone')} ` : '';
      const who = by.length > 1 && nameOf(m.recipient_person_id) ? `${nameOf(m.recipient_person_id)}: ` : '';
      return `<span style="font-size:0.66rem; font-weight:${failed ? 800 : 600}; color:${failed ? '#ef4444' : '#34d399'};">${this.escapeHtml(who + via + text + opened)}</span>`;
    }).join(' · ');
  }


  // ids: the parents to text from the club number (mig 682); omitted =
  // every opted-in one the server finds.
  async _sendClubText(btn, ids) {
    const personId = Number(btn.dataset.personId);
    const kind = btn.dataset.gcClubText;
    btn.disabled = true;
    btn.textContent = '⏳';
    try {
      if (kind === 'game_link' && this._saveTimer) { clearTimeout(this._saveTimer); this._saveTimer = null; await this._saveLineup(); }
      const res = kind === 'game_link'
        ? await this.auth.fetch('/api/rsvp-board/squad-notice', {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ match_id: Number(this.matchId), person_id: personId, channel: 'club_sms',
                                   ...(ids && ids.filter(x => x != null).length ? { recipient_person_ids: ids.filter(x => x != null) } : {}) }) })
        : await this.auth.fetch(`/api/calendar/events/${this._fhEventId()}/registration-gaps/text`, {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ person_id: personId }) });
      const data = await res.json().catch(() => ({}));
      if (!res.ok || data.error) {
        const why = data.error || data.message || `HTTP ${res.status}`;
        throw new Error(why === 'not_opted_in' ? ((window.MessageCopy && MessageCopy.block('text_mark', 'no_consent')) || why) : why);
      }
      if (data.status) this.squadNotice = data.status;
    } catch (err) {
      const note = btn.closest('[data-gc-contact]')?.querySelector('[data-gc-squad-note]');
      if (note) note.innerHTML = `<span style="color:#f87171;">${this.escapeHtml(err.message)}</span>`;
      else alert(err.message);
      btn.disabled = false;
      return false;
    }
    await this._loadTextMarks();
    this._render();
    return true;
  }

  // The gap row for one person (mig 638/645) — the card's registration
  // buttons read it.
  _regGapFor(personId) {
    return (this.regGaps || []).find(g => g.person_id === personId) || null;
  }

  // 💬/✉ registration link pair for one gap — the strip and the card
  // share it.  The message is the league form's DB copy, filled server-side.
  _regGapButtons(g) {
    // The one 📇 Contact popup, opening on the registration form (owner
    // 2026-11-03: no ways to contact outside the Contact button).
    const cfg = this._gcContactCfg(g.person_id, 'reg');
    return cfg ? ContactPopup.button({ ...cfg, key: `gc-reg:${g.person_id}` })
      : '<span style="font-size:0.74rem; opacity:0.5;">no phone or email on file</span>';
  }

  // Why this person is a gap: the league-list reasons (mig 645) name the
  // league; otherwise their roster status.
  _regGapReason(g) {
    const copy = (tier, tokens = {}) => window.MessageCopy ? MessageCopy.block('reg_gap', tier, tokens) : '';
    const league = (this.leagueList && this.leagueList.league) || '';
    if (g.reason === 'not_on_list' || g.reason === 'calldown_cap_full') {
      const why = copy(g.reason, { league });
      if (why) return g.status_label ? `${why} · ${g.status_label}` : why;
    }
    return g.status_label || copy('no_status') || 'no status';
  }

  // One row per gap: name, roster status, and the league's registration
  // nudge as 💬 text + ✉ email — the same message the #teams roster card
  // sends.  Players who already submitted (roster_statuses.player_done)
  // are listed without buttons.  Coach + official lineup view only.
  _renderRegGapSection() {
    const gaps = this.regGaps;
    const line = this._leagueListLine();
    // The strip also stands alone to say the list check failed — an
    // empty list from a stale pull must not read as "all registered".
    if (!this._staffView() || this.lineupView !== 'official' || !gaps) return '';
    if (!gaps.length && !(line && (line.bad || this._leagueListState === 'pulling'))) return '';
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const copy = (tier, tokens = {}) => window.MessageCopy ? MessageCopy.block('reg_gap', tier, tokens) : '';
    const rows = gaps.map(g => {
      const name = `${g.first_name || ''} ${g.last_name || ''}`.trim();
      const actions = g.player_done
        ? `<span style="font-size:0.74rem; opacity:0.7;">${esc(copy('waiting') || 'submitted — waiting on the league')}</span>`
        : this._regGapButtons(g);
      return `<div style="display:flex; justify-content:space-between; align-items:center; gap:8px; flex-wrap:wrap; padding:5px 0; border-bottom:1px solid var(--border-color);">
        <span style="font-size:0.88rem;"><a href="javascript:void(0)" data-gc-jump="${g.person_id}" style="color:inherit; font-weight:800; text-decoration:underline;">${esc(name)}</a> <span style="font-size:0.72rem; opacity:0.75;">· ${esc(this._regGapReason(g))}</span></span>
        <span style="display:inline-flex; gap:6px; align-items:center;">${actions}</span>
      </div>`;
    }).join('');
    const lineHtml = line && line.text ? `<div data-gc-league-list style="font-size:0.74rem; margin:2px 0 4px; font-weight:${line.bad ? 800 : 600};
        color:${line.bad ? '#ef4444' : 'inherit'}; opacity:${line.bad ? 1 : 0.8};">${esc(line.text)}</div>` : '';
    const blocked = gaps.filter(g => !g.player_done).length;
    const waiting = gaps.length - blocked;
    const red = blocked > 0 || (line && line.bad);
    const title = blocked
      ? this._regWarnCopy('strip_title', { n: blocked }) + (waiting ? ` · ${this._regWarnCopy('strip_waiting', { n: waiting })}` : '')
      : (copy('title', { n: gaps.length }) || `⚠ Going but not on the official roster (${gaps.length})`);
    // Rolled up like every pill (owner 11/11); the red/amber box and its
    // count stay on the closed summary.
    return `<details data-ec-fold="reg_gaps" ${this.foldOpen('reg_gaps') ? 'open' : ''} style="margin:0 0 12px; padding:8px 12px; border:2px solid ${red ? '#ef4444' : '#f59e0b'}; border-radius:10px; background:${red ? 'rgba(220,38,38,0.10)' : 'rgba(245,158,11,0.08)'};">
      <summary style="cursor:pointer; font-weight:800; font-size:0.9rem; color:${blocked ? '#f87171' : 'inherit'};">${esc(title)}</summary>
      <div style="font-size:0.74rem; opacity:0.75; margin:2px 0 4px;">${esc(copy('hint'))}</div>
      ${lineHtml}
      ${rows}
    </details>`;
  }

  // ⭐ Auto toggle (team_auto_invites, mig 617): a standing call-down is
  // invited to every new game of this team automatically; off revokes its
  // open auto invites on future games (hand-sent invites stay).
  async _setAutoInvite(btn) {
    const personId = Number(btn.dataset.gcAutoInv);
    if (this._invBusy.has(personId)) return;
    this._invBusy.add(personId);
    this._render();
    try {
      const res = await this.auth.fetch(`/api/calendar/events/${this._fhEventId()}/auto-invites`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ person_id: personId, team_id: Number(btn.dataset.team),
                               from_team_id: Number(btn.dataset.from) || null,
                               active: btn.dataset.on !== '1' }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.message || data.error || `HTTP ${res.status}`);
    } catch (err) {
      this._toast(`⚠ ${err.message}`);
    } finally {
      this._invBusy.delete(personId);
      await this._loadInvites();
      this._render();
    }
  }

  // Withdraw: EventScreen's DELETE (and its reloads).  Game Center's 🎟
  // section hands over its button, the 👥 pane (EventScreen) a person id.
  async _revokeInvite(arg) {
    const personId = typeof arg === 'object' && arg ? Number(arg.dataset.gcInvRevoke) : Number(arg);
    if (!personId || this._invBusy.has(personId)) return;
    this._invBusy.add(personId);
    this._render();
    try { await super._revokeInvite(personId); }
    finally { this._invBusy.delete(personId); this._render(); }
  }

  // The section itself — rolled up like Not Going / No Response, invited
  // players (with their answer, re-send, withdraw) on top, then everyone
  // who could be invited, grouped by the squad they come from.
  _renderCallupSection() {
    const data = this.invites;
    if (!this._staffView() || this.lineupView !== 'official' || !data) return '';
    if (!data.invites.length && !data.candidates.length) return '';
    const esc = (t) => this.escapeHtml(t);
    const copy = (tier, tokens = {}) => window.MessageCopy ? MessageCopy.block('callup_panel', tier, tokens) : '';
    const nm = (r) => `${r.first_name || ''} ${r.last_name || ''}`.trim() || 'Unknown';
    const answers = { yes: ['Available', '#22c55e'], no: ['Not available', '#f87171'], maybe: ['Maybe', '#fbbf24'] };
    const answerChip = (resp) => {
      const [label, color] = answers[resp] || ['No response', 'inherit'];
      return `<span style="font-size:0.72rem; font-weight:700; color:${color}; ${answers[resp] ? '' : 'opacity:0.5;'}">${label}</span>`;
    };
    // One 📇 Contact per row (mig 1068): the call-up preselected; sending
    // it creates the invite.  No other send buttons here.
    // Invited rows have no button here: their card sits in No Response /
    // Going / Not Going with the squad (mig 1069) and its 📇 leads with the
    // RSVP reminder.  This list keeps ⭐ Auto and ✕ withdraw.
    const contactBtn = (r, resend) => SectionContact.callupButton(this, this._fhEventId(), r, {
      section: this.ev && this.ev.category, resend,
      onSent: () => this._loadInvites().then(() => this._render()),
    });
    const row = (inner) => `<div style="display:flex; align-items:center; justify-content:space-between; gap:8px; flex-wrap:wrap;
        padding:6px var(--space-3); border:1px solid var(--border-color); border-radius:6px;">${inner}</div>`;
    // ⭐ Standing call-down toggle (mig 617) — only on rows whose squad has
    // a cap row for this game (the call-down case, e.g. APSL on CASA).
    const autoBtn = (personId, fromTeamId, on) => {
      const cap = (data.caps || []).find(c => Number(c.from_team_id) === Number(fromTeamId || 0));
      if (!cap) return '';
      return `<button type="button" data-gc-auto-inv="${personId}" data-team="${cap.to_team_id}" data-from="${fromTeamId}"
        data-on="${on ? 1 : 0}" ${this._invBusy.has(Number(personId)) ? 'disabled' : ''}
        title="${on ? 'Standing call-down — invited to every game of this team automatically. Tap to turn off.'
                    : 'Make this a standing call-down — invited to every new game of this team automatically.'}"
        style="font-size:0.7rem; font-weight:700; padding:2px 8px; border-radius:999px; cursor:pointer;
               border:1px solid ${on ? '#f59e0b' : 'var(--border-color)'};
               background:${on ? 'rgba(245,158,11,0.18)' : 'transparent'}; color:${on ? '#fcd34d' : 'inherit'};">${on ? '⭐ Auto' : '☆ Auto'}</button>`;
    };
    // The contact the invite buttons would use, visible on the card like
    // every other section's (owner 2026-10-16) — parent's for youth.
    const contactBits = (r) => {
      const bits = [r.phone ? `📞 ${r.phone}` : '', r.email ? `✉ ${r.email}` : ''].filter(Boolean);
      return bits.length ? `<span style="font-size:0.66rem; opacity:0.65; overflow-wrap:anywhere;">${esc(bits.join(' · '))}</span>` : '';
    };
    // ✓ <team> official on a name on a league/club official roster (mig 1174).
    const officialChips = (r) => (r.official_lists || []).map(l =>
      `<span style="font-size:0.66rem; font-weight:700; color:#86efac; margin-left:6px; white-space:nowrap;">${esc(copy('official_chip', { team: l.team }) || `✓ ${l.team} official`)}</span>`).join('');
    const standing = data.invites.filter(r => r.auto);
    const invited = data.invites.filter(r => !r.auto).map(r => row(`
        <span style="font-size:0.9em; display:flex; flex-direction:column; min-width:0;">
          <span>${esc(nm(r))}${r.from_team ? `<span style="font-size:0.72rem; opacity:0.6;"> · ${esc(r.from_team)}</span>` : ''}${officialChips(r)}</span>
          ${contactBits(r)}
        </span>
        <span style="display:inline-flex; align-items:center; gap:8px;">
          ${answerChip(r.response)}
          ${autoBtn(r.person_id, r.from_team_id, r.auto)}
          <button type="button" data-gc-inv-revoke="${r.person_id}" ${this._invBusy.has(Number(r.person_id)) ? 'disabled' : ''}
                  title="Withdraw this invite — the game disappears for them again"
                  style="font-size:0.72rem; font-weight:700; color:#fca5a5; background:transparent;
                         border:1px solid rgba(248,113,113,0.5); padding:2px 8px; border-radius:999px; cursor:pointer;">✕</button>
        </span>`)).join('');
    // Everyone / <team> Official pills (mig 1174; owner 11/7: "need to
    // know which ones are on the u8 roster official so i know they are
    // eligible … same with all teams that have call up functionality").
    // One pill per official list that carries someone in this panel; a
    // name on a list wears its chip in every view.
    const lists = new Map();
    for (const c of data.candidates) for (const l of (c.official_lists || [])) {
      const k = String(l.team_id);
      if (!lists.has(k)) lists.set(k, { team: l.team, n: 0 });
      lists.get(k).n++;
    }
    let pill = (this._invPill && this._invPill.ev === this._fhEventId()) ? this._invPill.key : 'all';
    if (pill !== 'all' && !lists.has(pill)) pill = 'all';
    const shown = pill === 'all' ? data.candidates
      : data.candidates.filter(c => (c.official_lists || []).some(l => String(l.team_id) === pill));
    const pillBtn = (key, label, n) => `<button type="button" data-gc-inv-pill="${key}"
        style="font-size:0.72rem; font-weight:700; padding:3px 10px; border-radius:999px; cursor:pointer;
               border:1px solid ${pill === key ? '#22c55e' : 'var(--border-color)'};
               background:${pill === key ? 'rgba(34,197,94,0.18)' : 'transparent'}; color:inherit;">${esc(label)} (${n})</button>`;
    const pills = lists.size ? `<div style="display:flex; gap:6px; flex-wrap:wrap; margin:0 0 6px;">
        ${pillBtn('all', copy('pill_everyone') || 'Everyone', data.candidates.length)}
        ${[...lists.entries()].map(([k, l]) => pillBtn(k, copy('pill_official', { team: l.team }) || `${l.team} Official`, l.n)).join('')}
      </div>` : '';
    const byTeam = new Map();
    for (const c of shown) {
      const k = c.from_team || 'Other';
      if (!byTeam.has(k)) byTeam.set(k, []);
      byTeam.get(k).push(c);
    }
    const candidates = [...byTeam.entries()].map(([team, list]) => `
      <div style="font-size:0.72rem; font-weight:700; opacity:0.55; margin:8px 0 4px;">${esc(team)} (${list.length})</div>
      <div style="display:grid; gap:4px;">
        ${list.map(c => row(`
          <span style="font-size:0.9em; display:flex; flex-direction:column; min-width:0;">
            <span>${esc(nm(c))}${c.single_age ? `<span style="font-size:0.72rem; opacity:0.6;"> · U${esc(String(c.single_age))}</span>` : ''}${officialChips(c)}</span>
            ${contactBits(c)}
          </span>
          <span style="display:inline-flex; align-items:center; gap:8px;">
            ${autoBtn(c.person_id, c.from_team_id, c.auto)}
            ${contactBtn(c, false)}
          </span>`)).join('')}
      </div>`).join('');
    return `
      <details data-gc-inv-details ${this._invOpen ? 'open' : ''} style="margin: var(--space-3) 0;">
        <summary style="cursor:pointer; font-size:0.85rem; font-weight:700; padding:4px 0;">🎟 Call-ups (${data.invites.length - standing.length} invited · ${data.candidates.length} eligible)</summary>
        <div style="font-size:0.7rem; opacity:0.75; line-height:1.4; margin:2px 0 8px;">
          ${esc(copy('hint') || "An invited player (or their parent) sees this game on their page and gets a Go/No — it's the only way a call-up sees it. Nobody else outside the squad can.")}
        </div>
        ${(data.caps || []).map(c => `
          <div style="font-size:0.72rem; font-weight:700; margin:0 0 6px; color:${c.used >= c.max ? '#f87171' : '#fcd34d'};">
            ⬇ ${esc(copy('cap_line', { from: c.from_team, used: c.used, max: c.max }) || `${c.from_team}: ${c.used} of ${c.max} call-downs in the squad (starters + bench) — invites and Going are unlimited`)}
          </div>`).join('')}
        ${standing.length ? `<div style="font-size:0.74rem; margin:0 0 8px; display:flex; gap:8px; flex-wrap:wrap; align-items:center;">
          <span style="opacity:0.8;">${esc(copy('standing_note', { names: standing.map(nm).join(', ') }))}</span>
          ${standing.map(r => `<span style="display:inline-flex; gap:4px; align-items:center;">${esc(nm(r))} ${autoBtn(r.person_id, r.from_team_id, true)}</span>`).join('')}
        </div>` : ''}
        ${invited ? `<div style="display:grid; gap:4px; margin-bottom:6px;">${invited}</div>` : ''}
        ${data.candidates.length ? pills + candidates : `<div style="font-size:0.8rem; opacity:0.55;">Nobody eligible — everyone age-eligible in the program is rostered or already invited.</div>`}
      </details>`;
  }

  // Bulk ✉ / 💬 to everyone on the game's rosters, by RSVP (owner
  // 2026-09-30: "email in bulk everyone from a game. diff buttons for
  // those going, going and undecided, then an all button … game changed
  // to diff day so i need to email all parents of just u8").  The list
  // comes from /api/game-message (parents for youth), the box is the
  // roster boards' BulkMessageComposer, so Gmail opens with everyone in
  // BCC and nothing is sent from here.
  async _loadGameRecipients() {
    try {
      const res = await this.auth.fetch(`/api/game-message/${this.matchId}/recipients`);
      const data = await res.json();
      this.gameRecipients = res.ok && data.success ? (data.people || []) : null;
    } catch (err) {
      this.gameRecipients = null;
    }
  }

  _copyGm(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('game_message', tier, tokens) : ''; }

  // The lists the buttons offer.  "Undecided" is anyone who has not said
  // no: no answer yet, or maybe.  Since mig 600 the server's rows carry a
  // kind — roster, callup (an actual invite, whatever they answered) or
  // candidate (COULD still be called up).  The first three groups are the
  // squad: roster + call-ups, going or not (owner 2026-10-19: "message
  // all whether going or not"); the last adds the potential call-ups
  // ("can't leave out potentional u8 call ups") and only appears when
  // there are some.
  _gameRecipientGroups() {
    const all = this.gameRecipients || [];
    const squad = all.filter(p => p.kind !== 'candidate');
    const groups = [
      { key: 'going',           people: squad.filter(p => p.rsvp === 'yes') },
      { key: 'going_undecided', people: squad.filter(p => p.rsvp !== 'no') },
      { key: 'all',             people: squad },
    ];
    if (squad.length < all.length) groups.push({ key: 'with_candidates', people: all });
    return groups;
  }

  _gameLabelForMessage() {
    const m = this.matchDetails || {};
    const home = m.home_team_name || '', away = m.away_team_name || '';
    const teams = home && away ? `${home} vs ${away}` : (home || away || this.title || '');
    return [teams, this._whenLabel()].filter(Boolean).join(' · ');
  }

  _renderGameMessagePanel() {
    if (!this._staffView() || this.lineupView !== 'official' || !this.gameRecipients || !window.RosterMessaging) return '';
    const esc = (t) => this.escapeHtml(t);
    const contact = (p) => ({ phone: p.phone, email: p.email, extra: p.parents });   // every parent (mig 682)
    const rows = this._gameRecipientGroups().map(g => {
      const info = RosterMessaging.collect(g.people, contact);
      const btn = (kind, icon, n) => `
        <button type="button" class="btn btn-secondary" data-gc-msg-kind="${kind}" data-gc-msg-group="${g.key}" ${n ? '' : 'disabled'}
                style="padding:3px 10px; font-size:0.72rem; font-weight:700;">${icon} ${n}</button>`;
      return `
        <div style="display:flex; align-items:center; gap:6px; flex-wrap:wrap; padding:5px 0; border-top:1px solid var(--border-color); font-size:0.76rem;">
          <div style="flex:1; min-width:120px;"><b>${esc(this._copyGm('group_' + g.key))}</b> <span style="opacity:0.65;">· ${g.people.length}</span></div>
          ${btn('email', '✉', info.emails.length)}${btn('sms', '💬', info.phones.length)}
        </div>`;
    }).join('');
    return `
      ${this.panelFoldHtml('game_message', `${esc(this._copyGm('title'))}`, `
        <div style="font-size:0.7rem; opacity:0.75; line-height:1.4; margin-bottom:4px;">${esc(this._copyGm('hint'))}</div>
        ${rows}
`)}`;
  }

  // ── 🪑 Reserves (mig 1530) ─────────────────────────────────────────
  // The base game has none; MensGameScreen turns them on.
  _hasReserves() { return false; }

  // 📣 Ask Reserves: the unanswered Reserves (and never-answered Regulars)
  // for THIS game, one BCC email / group text from your own app — nothing
  // is sent by the server, so nobody is spammed behind your back.
  _askReservesPeople() {
    const ids = new Set((this._reservesUnanswered || []).map(p => Number(this._personIdFor(p.id))).filter(Boolean));
    return (this.gameRecipients || []).filter(r => ids.has(Number(r.personId)));
  }
  _askReservesBtn() {
    if (!this.realIsCoach || !window.RosterMessaging) return '';
    const people = this._askReservesPeople();
    if (!people.length) return '';
    const info = RosterMessaging.collect(people, (p) => ({ phone: p.phone, email: p.email, extra: p.parents }));
    const label = (window.MessageCopy && MessageCopy.block('event_center', 'ask_standby', { n: people.length })) || `📣 Ask Reserves (${people.length})`;
    const b = (kind, icon, n) => `<button type="button" class="btn btn-secondary" data-gc-ask-reserves="${kind}" ${n ? '' : 'disabled'}
        style="padding:3px 10px; font-size:0.72rem; font-weight:700;">${icon} ${n}</button>`;
    return `<div style="display:flex; gap:6px; align-items:center; flex-wrap:wrap; margin:0 0 6px;">
        <span style="font-size:0.78rem; font-weight:800;">${this.escapeHtml(label)}</span>${b('sms', '💬', info.phones.length)}${b('email', '✉', info.emails.length)}</div>`;
  }
  _askReserves(kind) {
    if (!window.RosterMessaging || !window.BulkMessageComposer) return;
    const info = RosterMessaging.collect(this._askReservesPeople(), (p) => ({ phone: p.phone, email: p.email, extra: p.parents }));
    if (kind === 'email' ? !info.emails.length : !info.phones.length) return;
    const event = this._gameLabelForMessage();
    const where = (this.ev && window.EventLabels && (EventLabels.homeSetup(this.ev) || this.ev.location)) || '';
    const cp = (tier, tk) => (window.MessageCopy && MessageCopy.block('event_center', tier, tk)) || '';
    BulkMessageComposer.open({
      screen: this, kind, info,
      entry: { scope: cp('sec_standby', {}) || '🪑 Reserves',
               preset: { label: '', subject: cp('ask_standby_subject', { event }) || `Can you make it? ${event}`,
                         body: cp('ask_standby_body', { event, where }) || `We're short for ${event}. Can you make it?` } },
      onSent: (n) => { this._toast(`✓ ${n}`); this._logAsk(kind, this._askReservesPeople()); },
    });
  }

  // A group message about this game counts as a reminder for each person
  // in it (mig 1562, owner 11/19 "never a fine for no rsvp unless there
  // was a reminder sent") — nothing is sent by the server.
  _logAsk(kind, people) {
    const id = this._fhEventId ? this._fhEventId() : 0;
    const ids = (people || []).map(p => Number(p.personId)).filter(Boolean);
    if (!id || !ids.length || !this.auth) return;
    this.auth.fetch('/api/rsvp-board/log-ask', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ fh_event_id: Number(id), channel: kind === 'email' ? 'email' : 'sms', person_ids: ids }),
    }).catch(() => {});
  }

  _messageGame(btn) {
    const group = this._gameRecipientGroups().find(g => g.key === btn.dataset.gcMsgGroup);
    if (!group || !window.RosterMessaging || !window.BulkMessageComposer) return;
    const kind = btn.dataset.gcMsgKind;
    const info = RosterMessaging.collect(group.people, (p) => ({ phone: p.phone, email: p.email, extra: p.parents }));
    if (kind === 'email' ? !info.emails.length : !info.phones.length) return;
    const game = this._gameLabelForMessage();
    const scope = this._copyGm('scope', { group: this._copyGm('group_' + group.key), game });
    const subject = this._copyGm('subject', { game });
    // The box opens naming this game (game_message body, mig 1470; owner
    // 11/18 "should mention the event in particular", no link).
    const where = (this.ev && window.EventLabels && (EventLabels.homeSetup(this.ev) || this.ev.location)) || '';
    const body = this._copyGm('body', { game, where }) || `${game}\n`;
    BulkMessageComposer.open({
      screen: this, kind, info,
      entry: { scope, preset: { label: '', subject, body } },
      onSent: (n) => { this._toast(`✓ ${n}`); this._logAsk(kind, group.people); },
    });
  }

  // 🚗 Carpool (mig 601, owner 2026-10-19: "would be great to have a
  // carpool feature on each game. request ride. then they could auto have
  // address for pickup of child on there. then someone could click to
  // acccpet carpool to drive?").  A parent posts a ride request for their
  // player — the pickup address pre-fills from person_addresses and is
  // snapshotted on the request — and anyone on the game taps "I can
  // drive".  The endpoint answers 403 to anyone not on the game, and the
  // panel stays away.  Rendering and actions live in the shared
  // CarpoolPanel component (components/carpool-panel.js) since migs
  // 608/609 added the 3-option pickup plans — the Event Center mounts the
  // same component for practices.
  async _loadCarpool() {
    await this.carpoolPanel.load();
  }

  _renderCarpoolPanel() {
    return this.carpoolPanel ? this.carpoolPanel.html() : '';
  }

  // What the 🎯 Match plan needs from the lineup (MatchPlanPanel host
  // contract): starters by position number (positions.sort_order — the
  // 1-11 pills), the bench in the coach's order (first = the next best not
  // starting), the rest of the roster, the shape and the match-up.  The
  // panel only shows on the official view (_pillToolsHtml), so the editor
  // state IS the official lineup here.
  _matchPlanSquad() {
    const { rosterById, slotToPlayerId, startingPositions } = this._slotMaps();
    const person = (id) => { const r = rosterById.get(id); return r ? { id: r.id, name: r.name } : null; };
    const byNumber = new Map();
    for (const pos of startingPositions) {
      const pid = slotToPlayerId.get(pos.id);
      const p = pid != null ? person(pid) : null;
      if (p && pos.sortOrder != null) byNumber.set(Number(pos.sortOrder), p);
    }
    const bench = this.roster.filter(r => this.zones.get(r.id) === 'bench')
      .sort((a, b) => (this.benchOrder.get(a.id) ?? Infinity) - (this.benchOrder.get(b.id) ?? Infinity))
      .map(r => ({ id: r.id, name: r.name }));
    const used = new Set([...byNumber.values(), ...bench].map(p => p.id));
    const others = this.roster.filter(r => !used.has(r.id)).map(r => ({ id: r.id, name: r.name }))
      .sort((a, b) => a.name.localeCompare(b.name));
    const m = this.everyonePlays ? null : this._matchup(this.matchupId);
    return {
      byNumber, bench, others,
      formation: this.everyonePlays ? '' : (this.formation || ''),
      matchup: m ? this._copyMatchup('option', { opponent: m.opponentCode, ours: m.code }) : '',
      viewerPersonId: this.viewerPersonId != null ? Number(this.viewerPersonId) : (this.myPlayerId != null ? Number(this.myPlayerId) : null),
      coachView: this._staffView(),
    };
  }

  async _carpoolClick(btn) {
    await this.carpoolPanel.click(btn, this.element);
  }

  // 🖨 Official roster + roster sheet → screens/game-center/roster-print.js (GameCenterRosterPrint, mixed in).

  // 📣 Squad game reminder + player reminders (mig 383/384) → screens/game-center/squad-notice.js (GameCenterSquadNotice, mixed in).

  // 📝 Game details + score → screens/game-center/details-score.js (GameCenterDetailsScore, mixed in).

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
  // The tools under a pill's card = panels (lib/panel.js, slice 5B), each
  // with the lowest tier that gets it — the same list for everyone, cut by
  // panelViewer.  Each render fn keeps its own data / view guards.
  //   game_day        🎯 match plan · game details (coach) · 🚗 carpool ·
  //                   📇 opponent contacts (coach)
  //   post_game       score entry (coach)
  //   lineup          the game-day roster count + 👥 All Players (coach)
  //   lineup / starters_bench   🎯 match plan · ✉️ message everyone (coach,
  //                   official view) · 🚗 carpool · 📇 contacts (coach) ·
  //                   🖨 official league roster (server: rosters/coaches) ·
  //                   🖨 roster sheet.  The league sheet sits with the squad
  //                   pills, the landing pill included; contacts on the
  //                   lineup views too (owner 2026-10-16).
  pillToolPanels(pill, byZone) {
    const P = (key, minTier, html) => new Panel({ key, minTier, html });
    const plan     = P('match_plan', 'player', (s) => s.matchPlanPanel.html());
    const carpool  = P('carpool', 'player', (s) => s._renderCarpoolPanel());
    const contacts = P('opp_contacts', 'coach', (s) => s._renderOpponentContactsPanel());
    if (pill === 'game_day') return [plan, P('game_details', 'coach', (s) => s._renderGameDetailsPanel()), carpool, contacts];
    if (pill === 'post_game') return [P('score', 'coach', (s) => s._renderScorePanel())];
    if (pill !== 'lineup' && pill !== 'starters_bench') return [];
    return [
      ...(pill === 'lineup' ? [P('squad_count', 'coach', () => `
        <div style="display:flex; justify-content:space-between; align-items:center; gap:8px; flex-wrap:wrap;">
          <span style="font-size:0.72rem; opacity:0.75;">${byZone.starter.length + byZone.bench.length} on the game-day roster</span>
          <button type="button" id="gc-details-open" class="btn btn-primary"
                  style="font-size:0.75rem; padding:4px 10px;">👥 ${this.escapeHtml(this._ecCopy('pill_players', 'All Players'))}</button>
        </div>`)] : []),
      plan,
      P('game_message', 'coach', (s) => s._renderGameMessagePanel()),
      carpool,
      contacts,
      P('official_roster', 'player', (s) => s._renderOfficialRosterPanel()),
      P('roster_sheet', 'player', (s) => s._renderRosterSheetPanel()),
    ];
  }

  // ── Graphic-first lineup (owner 11/18 "if we can do the graphic as most of
  // the work of setting lineup and attendance then we do it imo"): names and
  // empty spots on the card are taps; the toolbar's pieces are ☰ items; the
  // card lists come back with 📝 Text view (EventScreen.menuOwnItems).
  _lineupPillOn() { return this.pill === 'starters_bench' || this.pill === 'lineup'; }
  _hasTextView() { return !!(this.loaded && this.isCoach && this._lineupPillOn() && this.lineupView === 'official'); }
  menuOwnItems() {
    if (!this._hasTextView()) return [];
    const cp = (tier, tk, fb) => (window.MessageCopy && MessageCopy.block('event_center', tier, tk)) || fb;
    const items = [];
    if (!this.everyonePlays) {
      items.push({ label: cp('menu_formation', { formation: this.formation }, `📐 Formation · ${this.formation}`), run: () => this._openFormationSheet() });
      if (this._matchupSelectHtml(false)) {
        const m = this._matchup(this.matchupId);
        items.push({ label: cp('menu_matchup', {}, '🆚 Match opponent') + (m ? ` · ${m.opponentCode}` : ''), run: () => this._openMatchupSheet() });
      }
    }
    items.push({ label: this.showLineupStats ? cp('menu_avail_hide', {}, '👁 Hide availability') : cp('menu_avail_show', {}, '👁 Show availability'),
                 run: () => { this.showLineupStats = !this.showLineupStats; this._render(); } });
    if (!this.everyonePlays && this._copySplit('button_on'))
      items.push({ label: this._copySplit(this.splitSquad ? 'button_off' : 'button_on'), run: () => this._toggleSplitSquad() });
    return [...items, ...super.menuOwnItems()];
  }
  _openFormationSheet() {
    const cp = (tier, fb) => (window.MessageCopy && MessageCopy.block('event_center', tier)) || fb;
    const grid = Object.keys(this._fieldSpec().formations).map(f => ({
      label: f, title: f, active: f === this.formation,
      run: () => { if (f === this.formation) return; this.formation = f; this.matchupId = null; this._render(); this._saveLineup(); },
    }));
    this._openSwapSheet({ title: cp('sheet_formation', '📐 Formation'), sub: '', grid, rows: [] });
  }
  _openMatchupSheet() {
    const cp = (tier, fb) => (window.MessageCopy && MessageCopy.block('event_center', tier)) || fb;
    const pick = (m) => () => { this.matchupId = m ? m.id : null; if (m) this.formation = m.code; this._render(); this._saveLineup(); return false; };
    const cur = this._matchup(this.matchupId);
    const rows = [{ label: this._copyMatchup('none'), disabled: !cur, run: pick(null) },
      ...this._matchupOptions().map(m => ({ label: this._copyMatchup('option', { opponent: m.opponentCode, ours: m.code }),
        note: m.id === this.matchupId ? m.note : '', disabled: m.id === this.matchupId, run: pick(m) }))];
    this._openSwapSheet({ title: cp('menu_matchup', '🆚 Match opponent'), sub: '', rows });
  }

  // ☰ extras (EventScreen._renderPanels): the "Last change · DB ✓" strip is
  // a status line, not a menu item — dropped there.
  menuSkipPanels() { return ['db_strip']; }

  // The lineup body's panels (lib/panel.js).  A game kind adds or hides:
  // MensGameScreen adds Starter Eligibility, YouthGameScreen hides the
  // everyone-plays note.  coach = the coach panels' parts, filled later.
  lineupPlayerPanels(byZone, coach) {
    return [
      new Panel({ key: 'lineup_controls', minTier: 'coach', html: () => coach.controls }),
      new Panel({ key: 'db_strip', maxTier: 'player', html: (s) => s._dbStripHtml() }),
      new Panel({ key: 'carpool', applies: (s) => s.lineupView !== 'official', html: (s) => s._renderCarpoolPanel() }),
      new Panel({ key: 'player_notes', maxTier: 'player', applies: (s) => s.pill === 'starters_bench', html: (s) => s._renderPlayerNotes(byZone) }),
      new Panel({ key: 'reg_gaps', minTier: 'coach', html: (s) => s._renderRegGapSection() }),
      new Panel({ key: 'group_bar', minTier: 'coach', applies: () => coach.canMessage, html: () => coach.groupBar, label: (sc) => sc._cm('bar_title') }),
      new Panel({ key: 'everyone_note', minTier: 'coach', applies: (s) => s.everyonePlays, html: (s) => s._everyoneNoteHtml() }),
      new Panel({ key: 'sections', minTier: 'coach', html: () => coach.sections }),
    ];
  }

  _pillToolsHtml(pill, byZone) {
    const html = this._renderPanels(this.pillToolPanels(pill, byZone));
    return html ? `<div style="max-width:540px; margin:10px auto 0;">${html}</div>` : '';
  }

  // The Instagram section's pill strip. Each pill carries what has
  // already gone out for this game — "✅ Posted" or "📅 <when>" — so a
  // coach sees at a glance which posts are still owed. Drafts get no
  // mark: opening a pill creates one, so it would say nothing.
  // EventScreen's pill hook: a game's four moments (POST_PILLS), titles
  // from the DB copy.
  pills(ev) {
    // 👥 All Players first — the same list every Event Center event opens
    // on (EventScreen), then the game's own moments (owner 11/11: "there
    // should be no game center. its just event center").
    const list = [...super.pills(ev), ...POST_PILLS.map(p => ({ ...p, title: this._pillTitle(p.key) }))];
    if (this._tacticsAvailable()) list.push({ ...TACTICS_PILL, title: this._pillTitle(TACTICS_PILL.key) });
    // The viewer's pills (lib/viewer.js eventPillKeys): a player gets ⚔️ Starters & Bench only.
    const keys = this.viewer.eventPillKeys(ev);
    return keys ? list.filter(p => keys.includes(p.key)) : list;
  }

  // ── 👥 All Players, game side (mig 1284; owner 11/11: "the ones 'going'
  // who have not been assinged starter or bench or alt need to show at top
  // of page so i can immediaely assing them … rolled up … expandable") ──
  _rollUp() { return true; }
  _ecCopy(tier, fb) { return (window.MessageCopy && MessageCopy.block('event_center', tier)) || fb; }
  _playerIdOfPerson(personId) {
    const p = (this.players || []).find(x => Number(x.personId) === Number(personId));
    return p && p.playerId != null ? Number(p.playerId) : null;
  }
  // Going split by this game's official lineup.  Everyone-plays games and
  // a lineup still loading keep the one Going section.
  _goingSplit(going) {
    if (!this.loaded || this.everyonePlays) return null;
    const by = { unplaced: [], starter: [], bench: [], alternate: [] };
    const pidOf = new Map();
    for (const r of going) {
      const pid = this._playerIdOfPerson(r.person_id);
      pidOf.set(r.person_id, pid);
      const z = pid != null ? this.zones.get(pid) : null;
      (by[z] || by.unplaced).push(r);
    }
    const sortOf = new Map((this.positionList || []).map(p => [p.id, p.sortOrder]));
    const posRank = (r) => sortOf.get(this.positions.get(pidOf.get(r.person_id))) ?? 99;
    by.starter.sort((a, b) => posRank(a) - posRank(b));
    by.bench.sort((a, b) => (this.benchOrder.get(pidOf.get(a.person_id)) ?? 99) - (this.benchOrder.get(pidOf.get(b.person_id)) ?? 99));
    const esc = (t) => this.escapeHtml(t);
    return {
      unplaced: by.unplaced,
      groups: [
        { key: 'starters', label: esc(this._ecCopy('sec_starters', '⭐ Starters')), list: by.starter },
        { key: 'bench',    label: esc(this._ecCopy('sec_bench', '🪑 Bench')),       list: by.bench },
        { key: 'alt',      label: esc(this._ecCopy('sec_alt', '🔁 Alt')),           list: by.alternate },
      ],
    };
  }
  // On each Going card: the position numbers (tap = start there; a taken
  // number opens the swap sheet as in the lineup editor), Bench, Alt.
  // Same data-lineup-* buttons, so the lineup's own click wiring saves.
  _cardSideHtml(r) {
    if (!this.isCoach || this.everyonePlays || !this.loaded || r.response !== 'yes') return '<span></span>';
    const pid = this._playerIdOfPerson(r.person_id);
    const esc = (t) => this.escapeHtml(t);
    if (pid == null) return `<span style="font-size:0.72rem; opacity:0.6;">${esc(this._ecCopy('side_no_roster', 'Not on this game\'s roster'))}</span>`;
    const { slotToPlayerId, startingPositions, rosterById } = this._slotMaps();
    const nums = startingPositions.map(pos => {
      const occ = slotToPlayerId.get(pos.id);
      const mine = occ === pid;
      const taken = occ != null && !mine;
      const style = mine ? 'background:#22c55e; color:#052e16; border:1px solid #22c55e;'
        : taken ? 'background:#1e293b; color:#64748b; border:1px solid #334155;'
        : 'background:#334155; color:#fff; border:1px solid #475569;';
      const title = taken ? `${pos.name} — ${(rosterById.get(occ) || {}).name || 'taken'}` : pos.name;
      return `<button type="button" data-lineup-position-btn="${pos.id}" data-player-id="${pid}" title="${esc(title)}"
        style="padding:2px 7px; font-size:0.7rem; font-weight:800; border-radius:3px; min-width:22px; cursor:pointer; ${style}">${pos.sortOrder}</button>`;
    }).join('');
    const zone = this.zones.get(pid);
    const zb = (z, tier, fb) => `<button type="button" data-lineup-zone-btn="${z}" data-player-id="${pid}"
        class="btn btn-sm ${zone === z ? 'btn-primary' : 'btn-secondary'}" style="padding:2px 8px; font-size:0.72rem;">${esc(this._ecCopy(tier, fb))}</button>`;
    return `<span style="display:flex; flex-direction:column; gap:4px; min-width:0;">
        <span style="display:flex; gap:3px; flex-wrap:wrap; align-items:center;">
          <span style="font-size:0.68rem; opacity:0.7; margin-right:2px;">${esc(this._ecCopy('side_start', 'Start:'))}</span>${nums}
        </span>
        <span style="display:flex; gap:4px;">${zb('bench', 'side_bench', 'Bench')}${zb('alternate', 'side_alt', 'Alt')}</span>
      </span>`;
  }

  // ⚔️ Starters & Bench opens on the Going players not placed yet, open,
  // at the top (owner 11/11: "i just need to see unrolled going players
  // who are not assigned yet … at top"); everything under it is a fold.
  // Same cards and buttons as 👥 All Players, so the same click wiring.
  _unplacedTopHtml() {
    if (this.pill !== 'starters_bench' || !this.isCoach || this.viewMode === 'player' || this.lineupView !== 'official') return '';
    if (!this.ev || !Array.isArray(this.ev.rsvps)) return '';
    try {
      const html = this._comingHtml({ unplacedOnly: true });
      if (!html) return '';
      EventScreen.ensureCardStyles();
      return `<div data-gc-players-pane>${html}</div>`;
    } catch (err) {
      console.error('[game-center] unplaced list failed:', err);
      return '';
    }
  }

  _playersPaneHtml() {
    if (!this.ev || !Array.isArray(this.ev.rsvps)) return `<div class="loading-state"><div class="spinner"></div><p>Loading…</p></div>`;
    try {
      return this._comingHtml() + this._jobsHtml();
    } catch (err) {
      console.error('[game-center] players pane failed:', err);
      return `<div style="opacity:0.7; padding:var(--space-3);">Could not draw the players list.</div>`;
    }
  }

  _socialPillsHtml() {
    // The shared big row (lib/event-pills.js) — a practice draws the same one.
    const mark = (p) => {
      const state = this.postStates[p.key];
      if (state && state.status === 'posted') return '✅ Posted';
      if (state && state.status === 'scheduled') {
        const d = state.scheduled_at ? new Date(state.scheduled_at) : null;
        return d && !isNaN(d)
          ? `📅 ${d.toLocaleString('en-US', { month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' })}`
          : '📅 Scheduled';
      }
      return '';
    };
    const pills = this.pills(this.ev);
    if (pills.length <= 1) return '';   // one page (a player): no strip
    return EventPills.buttons(pills, this.pill,
      { attr: 'data-gc-social-pill', escapeHtml: (t) => this.escapeHtml(t), mark });
  }

  // Just the strip — never the card under it, which holds a caption the
  // coach may be typing.
  _paintSocialPills() {
    const strip = this.find('#gc-social-pills');
    if (strip) strip.innerHTML = this._socialPillsHtml();
    this._syncExtrasMenu();   // ☰ lists these pills for staff (✅ Posted marks follow)
  }

  // One read of this match's posts for the marks above. Fire-and-forget:
  // the strip paints without marks until it lands, and a failure just
  // leaves them off.
  async _loadPostStates() {
    this.postStates = {};
    if (!this._mayPostSocial() || !this.matchId || !this.teamId) return;
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
          nameStyle: live ? this._cardNameStyle(p.id) : '',
          noteHtml: live ? this._lineupNote(p.id) : '',
          boxColor: live ? this._lineupBoxColor(p.id) : null,
          tapPersonId: live ? this._cardTapPerson(p.id) : null,
          isKeeper: !this.everyonePlays && gkPositionIds.has(this.positions.get(p.id)),
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
    // hangs the RSVP pill under the name. Neither reaches the post, and
    // nor does the eligibility mark on a name (_eligNameStyle).
    const editing = live && this.isCoach && this.viewMode !== 'player' && !this.everyonePlays;
    let pitch = null;
    if (this.everyonePlays) {
      // Going, back line first, dealt into the faked shape; the chip shows
      // the shirt number when the player has one.
      let idx = 0;
      const lines = this._everyoneShape(byZone.starter.length).map(count =>
        byZone.starter.slice(idx, idx += count).map(p => {
          const token = { number: p.jerseyNumber || '', name: p.name };
          // The practice box + mini calendar, as on a men's card (owner 11/20
          // "it shold look like men. it can even show attendance").
          if (live) { token.noteHtml = this._lineupNote(p.id); token.boxColor = this._lineupBoxColor(p.id); token.tapPersonId = this._cardTapPerson(p.id); }
          if (live && this.isCoach && this.viewMode !== 'player' && this.showLineupStats) token.badgeHtml = this._rsvpStatusPill(p.id);
          return token;
        }));
      lines.reverse(); // attack at top
      if (lines.length) lines.splice(Math.floor(lines.length / 2), 0, null);
      pitch = lines;
    } else if (byZone.starter.every(p => this.positions.has(p.id))) {
      const { rosterById, slotToPlayerId } = this._slotMaps();
      const spec = this._fieldSpec();
      const tpl = spec.formations[this.formation] || spec.formations[spec.defaultFormation];
      const wideIds = new Set(tpl.wideIds || []);
      const narrowIds = new Set(tpl.narrowIds || []);
      const chipLifts = tpl.chipLifts || {};
      const chipInsets = tpl.chipInsets || {};
      pitch = this._pitchRows().map(row => {
        if (row === HALFWAY_ROW) return null;
        const tokens = row.map(pos => {
          if (pos === GAP_POS) return { gap: true };
          const occupant = rosterById.get(slotToPlayerId.get(pos.id));
          const token = { number: pos.sortOrder, name: occupant ? occupant.name : '' };
          // The bench players sharing this spot, 2nd first (mig 763).
          const subs = this._sharersOf(pos.id).map(id => rosterById.get(id)).filter(Boolean);
          if (subs.length) token.subs = subs.map(r => ({ name: r.name, moveId: editing ? r.id : null, style: '', noteHtml: live ? this._lineupNote(r.id) : '', tapPersonId: live ? this._cardTapPerson(r.id) : null }));
          if (wideIds.has(pos.id)) token.wide = true;
          if (narrowIds.has(pos.id)) token.narrow = true;
          if (chipLifts[pos.id]) token.lift = chipLifts[pos.id];
          if (chipInsets[pos.id]) token.inset = chipInsets[pos.id];
          if (live && occupant) token.nameStyle = this._cardNameStyle(occupant.id, { onPitch: true });
          if (live && occupant) { token.noteHtml = this._lineupNote(occupant.id); token.boxColor = this._lineupBoxColor(occupant.id); token.tapPersonId = this._cardTapPerson(occupant.id); }
          if (editing && !occupant) token.fillPosId = pos.id;   // tap = who plays here (_openFillSheet)
          if (editing && occupant) {
            token.removeId = occupant.id;
            if (this.showLineupStats) token.badgeHtml = this._rsvpStatusPill(occupant.id);
          }
          return token;
        });
        // Row-level flags ride on the array (in-memory pipeline only):
        // buildImagePitch draws the halfway line through a halfway row
        // and lifts a lift row by that many px.
        if (row.halfway) tokens.halfway = true;
        if (row.lift) tokens.lift = row.lift;
        return tokens;
      });
    }
    const title = this.everyonePlays ? this._copyLe('title') : '';
    // Sharers sit under their starter on the pitch, not in the bench list;
    // split squad colours Squad B and adds the swap times (mig 763).
    const sharedIds = pitch && !this.everyonePlays ? new Set([...this.shares.keys()].map(String)) : new Set();
    const split = this.splitSquad && !this.everyonePlays && pitch
      ? { band: this._copySplit('band'), times: this._copySplit('times') } : null;
    // The when / where lines, on the live card under the matchup (never
    // the post): Arrival · Warmup · Kickoff, 🏟 HOME-11v11.
    const info = live && this.ev
      ? [EventLabels.timesLine(this.ev), EventLabels.homeSetup(this.ev) ? `🏟 ${EventLabels.homeSetup(this.ev)}` : ''].filter(Boolean) : [];
    const out = live && this._rsvpOut ? this._rsvpOut : null;
    // Heading colours (owner 11/18 "not placed yellow, no response orange → yellow too 11/18,
    // not going red, alternates powder blue"); ineligible keeps the gold.
    // ids ride along while editing: a name is a tap → the move sheet (owner 11/18 graphic-first).
    const outRow = (list, tier, fb, color) => { const l = [...list].sort(this._byLastName);
      return { label: `${this._ecCopy(tier, fb)} (${list.length})`, color, names: l.map(p => p.name), ids: editing ? l.map(p => p.id) : null,
               pids: l.map(p => this._cardTapPerson(p.id)) }; };
    // Order (owner 11/18): substitutes, not placed yet (+ ineligible), no response, not going, alternates.
    // ⬇ Call-downs in the squad, per cap (mig 1527, owner 11/19 "show me a
    // tally of how many bench and starters i have like that" + "warn if 3
    // of more"): gold under the cap, red over it.  Coaches only.
    const calldownRows = out && this.isCoach ? this._callDownTally().filter(t => t.ids.length).map(t => {
      const over = t.ids.length > Number(t.cap.max);
      const tk = { n: t.ids.length, max: t.cap.max, team: t.cap.from_team || 'APSL' };
      const ppl = t.ids.map(id => this.roster.find(r => Number(r.id) === Number(id))).filter(Boolean).sort(this._byLastName);
      return { label: over ? ((window.MessageCopy && MessageCopy.block('event_center', 'card_calldowns_over', tk)) || `⚠ ${tk.team} call-downs ${tk.n}/${tk.max} — league max is ${tk.max}`)
                           : ((window.MessageCopy && MessageCopy.block('event_center', 'card_calldowns', tk)) || `⬇ ${tk.team} call-downs ${tk.n}/${tk.max}`),
               color: over ? '#f87171' : '#f5d442', names: ppl.map(p => p.name), ids: editing ? ppl.map(p => p.id) : null, pids: ppl.map(p => this._cardTapPerson(p.id)) };
    }) : [];
    const rsvpOut = out ? [...calldownRows,
                           outRow(out.unplaced || [], 'sec_unplaced', '⚠️ Going · Not placed yet', '#facc15'),
                           outRow(out.ineligible || [], 'sec_ineligible', '⛔ Said going · Ineligible (dues)', '#f5d442'),
                           outRow(out.noResponse, 'sec_noresp', '– No response', '#facc15'),
                           outRow(out.notGoing, 'sec_notgoing', '✗ Not going', '#f87171'),
                           outRow(out.notChasing || [], 'sec_inactive', '💤 Inactive', '#94a3b8'),
                           outRow(out.reserves || [], 'sec_standby', '🪑 Reserves', '#93c5fd'),
                           outRow(byZone.alternate || [], 'card_alternates', '🔁 Alternates', '#b0e0e6')].filter(r => r.names.length) : [];
    // GOING / NOT GOING on the live card for a player (owner 11/18 "going or
    // not going button should be on graphic! … graphic is the focus").
    // 📇 CONTACT under it for staff (EventScreen._contactPillHtml, owner 11/20).
    const availHtml = live ? (this._availOnGraphic() ? this._myAvailBlockHtml() : '') + this._contactPillHtml() : '';
    // The key to the boxes' mini calendars (eligibility strip_legend, mig 1505).
    const legend = live ? this._cardLegend() : '';
    return { players, selectedIds, zones, fieldSize: this.fieldSize, pitch, editing, live, title, sharedIds, split, info, rsvpOut, availHtml, legend };
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

  // Match opponent (mig 912): the rows this format can draw, and the pick.
  _matchupOptions() { return (this.matchups || []).filter(m => this._fieldSpec().formations[m.code]); }
  _matchup(id) { return this._matchupOptions().find(m => m.id === id) || null; }
  _copyMatchup(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('lineup_matchup', tier, tokens) : ''; }

  _matchupSelectHtml(everyone) {
    const options = this._matchupOptions();
    if (everyone || !this.isCoach || !options.length || !this._copyMatchup('none')) return '';
    const esc = (t) => this.escapeHtml(t);
    return `<select data-lineup-matchup-select title="${esc(this._copyMatchup('none'))}"
                  style="font-size:0.72rem; font-weight:700; padding:4px 6px; border-radius:4px; border:1px solid #475569; background:#0f172a; color:#fff;">
            <option value="">${esc(this._copyMatchup('none'))}</option>
            ${options.map(m => `<option value="${m.id}" ${m.id === this.matchupId ? 'selected' : ''}>${esc(this._copyMatchup('option', { opponent: m.opponentCode, ours: m.code }))}</option>`).join('')}
          </select>`;
  }

  // Who takes whom. Under the toolbar, never on the graphic: it's the plan,
  // and the graphic is the post.
  _matchupNoteHtml(everyone) {
    const m = everyone ? null : this._matchup(this.matchupId);
    if (!m) return '';
    const esc = (t) => this.escapeHtml(t);
    return `<div style="margin:-4px 0 12px; font-size:0.74rem; line-height:1.4;">
      <b>${esc(this._copyMatchup('note_title', { opponent: m.opponentCode, ours: m.code }))}</b><br>${esc(m.note)}
    </div>`;
  }

  // The FIELD_SIZES entry for this match's format (see fieldSize).
  _fieldSpec() {
    return FIELD_SIZES[this.fieldSize] || FIELD_SIZES[DEFAULT_FIELD_SIZE];
  }

  // ✅ Eligibility → screens/game-center/eligibility.js (GameCenterEligibility, mixed in).

  // ── Everyone plays (mig 515) ──────────────────────────────────────────
  // The faked shape for n players, back line first: three lines, as even
  // as they go, the odd ones to the back (12 → 4-4-4, 10 → 4-3-3,
  // 7 → 3-2-2); fewer lines for a handful, a fourth past five across.
  _everyoneShape(n) {
    if (n <= 0) return [];
    const lines = n <= 2 ? 1 : n <= 4 ? 2 : Math.max(3, Math.ceil(n / 5));
    const base = Math.floor(n / lines), extra = n % lines;
    return Array.from({ length: lines }, (_, i) => base + (i < extra ? 1 : 0));
  }

  _byLastName(a, b) {
    return (a.lastName || a.name || '').toLowerCase().localeCompare((b.lastName || b.name || '').toLowerCase());
  }

  _copyLe(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('lineup_everyone', tier, tokens) : ''; }

  _everyoneNoteHtml() {
    const note = this._copyLe('note');
    return note ? `<div style="max-width:540px; margin:0 auto var(--space-3); font-size:0.78rem; opacity:0.8; text-align:center;">${this.escapeHtml(note)}</div>` : '';
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
      // 0 in a row is an empty column (GAP_POS) — it holds width so an
      // asymmetric shape can sit a chip off-center (mig 1112).
      rows = template.rows.map(idRow => idRow.map(id => id === 0 ? GAP_POS : positionById.get(id)).filter(Boolean));
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
    // `lifts` ({row index as written → px}): that row draws a touch
    // higher than its evenly-spaced slot — a visual nudge, not a slot
    // change (owner 2026-10-19: "push 8 up a little in the 3313").
    // Applied before the splices below so the written indices hold.
    for (const [idx, px] of Object.entries(template.lifts || {})) {
      rows[rows.length - 1 - Number(idx)].lift = px;
    }
    // A formation with `halfwayOn` stands that row ON the line instead
    // (owner 2026-11-06: "put the wing backs on the line in all back
    // 3"): the line draws through it, crest between its middle chips.
    if (template.rows && template.halfwayOn != null) {
      rows[rows.length - 1 - template.halfwayOn].halfway = true;
    } else {
      rows.splice(Math.floor(rows.length / 2), 0, HALFWAY_ROW);
    }
    return rows;
  }

}
