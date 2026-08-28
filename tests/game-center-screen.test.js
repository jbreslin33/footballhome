// Game Center (#game-center, frontend/js/screens/game-center.js) — the
// one page for a single game: four pills (Game Announcement / 20-Man
// Squad / Starters & Bench / Match Result) over one match load.
//
// What's worth pinning down here, and why:
//   * Every pill renders for both a coach and a player. This screen
//     absorbed three others, so a pill that throws is a whole entry
//     point going dark.
//   * The post card is fed from the screen's own live zones. That
//     shared source is the entire point of the merge — if rosterData
//     drifts from what the coach assigned, the published post is wrong
//     in exactly the way the merge was meant to stop.
//   * The re-mount guard. _render() runs on every zone toggle; without
//     the guard it would wipe a caption the coach is mid-way through
//     typing and re-fire the card's four API calls.
//   * The player gate. Players must never get a publish control, or the
//     coach-only RSVP/jersey overlay.
//   * The RSVP & Player Details overlay, which moved here when
//     #game-day-roster was deleted. Its writes (match RSVP, practice
//     attendance, jersey numbers) have to land in BOTH the overlay's own
//     this.players and the state the rest of the screen reads — this.stats
//     for the RSVP buckets, this.roster for the post graphic — or the
//     page contradicts itself until a reload.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { JSDOM } = require('jsdom');

const FRONTEND = path.join(__dirname, '..', 'frontend', 'js');
const read = f => fs.readFileSync(path.join(FRONTEND, f), 'utf8');

function loadGameCenter() {
  const dom = new JSDOM('<!doctype html><div id="app"></div>', { url: 'https://footballhome.org/#game-center' });
  const sandbox = dom.window;
  sandbox.console = console;

  // jsdom ships no canvas backend, so getContext('2d') returns null and
  // the lighthouse artwork _renderMatchHeader queues on a setTimeout
  // blows up asynchronously — after the assertions have already passed,
  // as unattributable noise. A no-op 2d context keeps that drawing code
  // on its normal path. This is an environment gap, not a code path
  // worth changing: in a browser the context always exists.
  const noopCtx = new Proxy({}, {
    get: (_, prop) => (prop === 'canvas' ? {} : () => noopCtx),
  });
  sandbox.HTMLCanvasElement.prototype.getContext = () => noopCtx;

  vm.createContext(sandbox);

  // Stubs for the two globals game-center.js reaches for at runtime.
  // SocialPostCard records every init so a test can assert both THAT a
  // card was built and WHAT lineup it was handed.
  vm.runInContext(`
    var SOCIAL_INITS = [];
    class SocialPostCard {
      constructor(auth) { this.auth = auth; this.rosterData = null; }
      init(container, matchId, teamId, postTypeName, matchContext, rosterData) {
        this.rosterData = rosterData;
        SOCIAL_INITS.push({ matchId, teamId, postTypeName, matchContext, rosterData });
        container.innerHTML = '<div class="spc-stub"></div>';
      }
    }
    var LighthouseBeam = { animate: () => () => {}, draw: () => {} };
  `, sandbox);

  vm.runInContext(read('screen-base.js'), sandbox);
  vm.runInContext(read('screens/game-center.js'), sandbox);
  // `class X {}` at top level is lexical, not a property of globalThis —
  // pull the binding out by evaluating its name in the same context.
  const GameCenterScreen = vm.runInContext('GameCenterScreen', sandbox);
  return { dom, sandbox, GameCenterScreen };
}

// A screen already past _bootstrap, holding a small but realistic lineup:
// 2 starters (one of them the keeper, by position id), 1 bench, 1
// alternate, and a player whose surname is three words.
function mountScreen({ isCoach, role }) {
  const { dom, sandbox, GameCenterScreen } = loadGameCenter();
  const navigation = {
    context: { user: { role }, team: { id: 120, name: 'Lighthouse Boys Club' } },
    goBack() {}, goTo() {},
  };
  const calls = [];
  const auth = {
    viewAsPersonId: null,
    fetch: async (url, opts) => {
      calls.push({ url, method: (opts && opts.method) || 'GET', body: opts && opts.body ? JSON.parse(opts.body) : null });
      return { json: async () => ({ success: true, data: [], rsvpStatus: 'yes' }) };
    },
  };
  const screen = new GameCenterScreen(navigation, auth);
  const el = screen.render();
  dom.window.document.getElementById('app').appendChild(el);

  screen.matchId = 3533;
  screen.teamId = 120;
  screen.isCoach = isCoach;
  screen.matchDetails = {
    id: 3533, home_team_id: 120, home_team_name: 'Lighthouse Boys Club',
    away_team_name: 'Persepolis FC', venue_location: 'Ramp',
    home_team_score: 1, away_team_score: 0,
  };
  screen.positionList = [
    { id: 1, name: 'Goalkeeper', abbreviation: 'GK', sortOrder: 1 },
    { id: 2, name: 'Right Back', abbreviation: 'RB', sortOrder: 2 },
    { id: 9, name: 'Striker', abbreviation: 'ST', sortOrder: 9 },
  ];
  screen.roster = [
    { id: 1, name: 'Musa Abdelgadir', lastName: 'Abdelgadir', lineupRole: 'starter', teamId: 120, jerseyNumber: 9 },
    { id: 2, name: 'Hamzah Dabbour',  lastName: 'Dabbour',    lineupRole: 'bench',   teamId: 120, jerseyNumber: 7 },
    { id: 3, name: 'Juan de la Cruz', lastName: 'de la Cruz', lineupRole: null,      teamId: 120, jerseyNumber: null },
    { id: 4, name: 'Arsene Bado',     lastName: 'Bado',       lineupRole: null,      teamId: 120, jerseyNumber: 1 },
  ];
  screen.zones = new Map([[1, 'starter'], [4, 'starter'], [2, 'bench'], [3, 'alternate']]);
  screen.positions = new Map([[1, 9], [4, 1]]);
  screen.benchOrder = new Map([[2, 1]]);
  screen.stats = new Map([[1, {
    practicesAttended: 2, practicesRecentTotal: 3, practicesProjected: 1,
    practicesUpcomingTotal: 1, gameRsvp: 'yes', practices: [],
  }]]);
  // What GET /api/matches/:matchId/roster-players returns — the
  // enriched admin rows behind the 20-Man Squad pill's overlay.
  screen.trainingEvents = [
    { id: 901, date: '2026-08-25', title: 'Tuesday session' },
    { id: 902, date: '2026-08-27', title: 'Thursday session' },
  ];
  screen.players = [
    { playerId: '1', personId: 11, firstName: 'Musa', lastName: 'Abdelgadir', position: 'ST',
      isKeeper: false, jerseyNumber: '9', rsvpStatus: 'yes', rsvpSource: 'groupme', rosterTeamId: '120',
      practice: [{ v: 'yes', o: false }, null], onRosterLighthouse: true, onRosterCasa: false, onRosterU23: false },
    { playerId: '2', personId: 12, firstName: 'Hamzah', lastName: 'Dabbour', position: 'MF',
      isKeeper: false, jerseyNumber: '7', rsvpStatus: null, rsvpSource: null, rosterTeamId: '120',
      practice: [{ v: 'no', o: true }, null], onRosterLighthouse: false, onRosterCasa: true, onRosterU23: false },
    { playerId: '3', personId: 13, firstName: 'Juan', lastName: 'de la Cruz', position: 'DF',
      isKeeper: false, jerseyNumber: '', rsvpStatus: 'no', rsvpSource: 'admin', rosterTeamId: '120',
      practice: [null, null], onRosterLighthouse: false, onRosterCasa: false, onRosterU23: true },
    { playerId: '4', personId: 14, firstName: 'Arsene', lastName: 'Bado', position: 'GK',
      isKeeper: true, jerseyNumber: '1', rsvpStatus: 'yes', rsvpSource: null, rosterTeamId: '120',
      practice: [null, { v: 'yes', o: false }], onRosterLighthouse: true, onRosterCasa: false, onRosterU23: false },
  ];
  screen.loaded = true;
  screen._wire();
  return { screen, sandbox, calls };
}

const PILLS = ['game_day', 'lineup', 'pre_match_announcement', 'post_game'];
// The two pills with no live in-page graphic of their own open their
// Instagram section by default; the two that already draw one keep it
// closed so only one image is on screen at a time.
const OPENS_BY_DEFAULT = new Set(['game_day', 'post_game']);

test('every pill renders for a coach, with the strip intact', () => {
  const { screen, sandbox } = mountScreen({ isCoach: true, role: 'club' });
  for (const pill of PILLS) {
    sandbox.SOCIAL_INITS.length = 0;
    screen.pill = pill;
    assert.doesNotThrow(() => screen._render(), `${pill} threw`);

    const html = screen.element.innerHTML;
    assert.equal((html.match(/data-game-pill=/g) || []).length, 4, `${pill}: all four pills present`);
    assert.match(html, new RegExp(`data-game-pill="${pill}"\\s+class="btn btn-primary`), `${pill}: active`);
    assert.ok(html.includes('gc-social-toggle'), `${pill}: coach gets the post section`);
    assert.equal(sandbox.SOCIAL_INITS.length > 0, OPENS_BY_DEFAULT.has(pill), `${pill}: default open state`);
  }
});

test('each pill publishes as its own post type, for this match and team', () => {
  const { screen, sandbox } = mountScreen({ isCoach: true, role: 'club' });
  for (const pill of PILLS) {
    sandbox.SOCIAL_INITS.length = 0;
    screen.pill = pill;
    screen._socialOpen.add(pill);
    screen._render();
    const init = sandbox.SOCIAL_INITS[0];
    assert.ok(init, `${pill}: mounted`);
    assert.equal(init.postTypeName, pill);
    assert.equal(init.matchId, 3533);
    assert.equal(init.teamId, 120);
  }
});

test('the post card is fed from the screen\'s own live zones', () => {
  const { screen, sandbox } = mountScreen({ isCoach: true, role: 'club' });
  screen.pill = 'pre_match_announcement';
  screen._socialOpen.add('pre_match_announcement');
  screen._render();

  const { players, selectedIds, zones } = sandbox.SOCIAL_INITS[0].rosterData;
  // Alternates are not on the game-day roster, so they must not reach a post.
  assert.equal(players.length, 3);
  assert.ok(!selectedIds.has('3'), 'alternate excluded');
  assert.equal(zones.get('1'), 'starter');
  assert.equal(zones.get('2'), 'bench');

  const byLast = n => players.find(p => p.lastName === n);
  assert.equal(byLast('Bado').isKeeper, true, 'GK derived from position id, not name');
  assert.equal(byLast('Abdelgadir').isKeeper, false);
  assert.equal(String(byLast('Abdelgadir').jerseyNumber), '9');
  assert.equal(byLast('Abdelgadir').firstName, 'Musa');
});

test('a multi-word surname keeps its first name intact', () => {
  const { screen, sandbox } = mountScreen({ isCoach: true, role: 'club' });
  screen.zones.set(3, 'starter'); // Juan de la Cruz
  screen.pill = 'pre_match_announcement';
  screen._socialOpen.add('pre_match_announcement');
  screen._render();
  const juan = sandbox.SOCIAL_INITS[0].rosterData.players.find(p => p.lastName === 'de la Cruz');
  assert.equal(juan.firstName, 'Juan');
});

test('re-rendering keeps the live card but refreshes its lineup', () => {
  const { screen, sandbox } = mountScreen({ isCoach: true, role: 'club' });
  screen.pill = 'pre_match_announcement';
  screen._socialOpen.add('pre_match_announcement');
  screen._render();
  const card = screen.socialCard;
  assert.equal(card.rosterData.players.length, 3);

  // A zone toggle re-renders the body. The card must survive it — a
  // rebuild here would discard a caption the coach is drafting.
  screen.zones.set(3, 'starter');
  sandbox.SOCIAL_INITS.length = 0;
  screen._render();
  assert.equal(screen.socialCard, card, 'same instance');
  assert.equal(sandbox.SOCIAL_INITS.length, 0, 'not re-initialised');
  assert.equal(screen.socialCard.rosterData.players.length, 4, 'but sees the new starter');
});

test('switching pills does rebuild the card', () => {
  const { screen, sandbox } = mountScreen({ isCoach: true, role: 'club' });
  screen.pill = 'pre_match_announcement';
  screen._socialOpen.add('pre_match_announcement');
  screen._render();
  sandbox.SOCIAL_INITS.length = 0;

  screen.pill = 'post_game';
  screen._render();
  assert.equal(sandbox.SOCIAL_INITS.length, 1);
  assert.equal(sandbox.SOCIAL_INITS[0].postTypeName, 'post_game');
});

test('the Match Result pill shows a recorded score', () => {
  const { screen } = mountScreen({ isCoach: true, role: 'club' });
  screen.pill = 'post_game';
  screen._render();
  assert.match(screen.element.innerHTML, /1 – 0/);

  screen.matchDetails.home_team_score = null;
  screen.matchDetails.away_team_score = null;
  screen._render();
  assert.match(screen.element.innerHTML, /No score recorded yet/);
});

test('a player gets no publish controls and no editor on any pill', () => {
  const { screen, sandbox } = mountScreen({ isCoach: false, role: 'player' });
  for (const pill of PILLS) {
    sandbox.SOCIAL_INITS.length = 0;
    screen.pill = pill;
    assert.doesNotThrow(() => screen._render(), `${pill} threw`);
    const html = screen.element.innerHTML;
    assert.ok(!html.includes('gc-social-toggle'), `${pill}: no post section`);
    assert.ok(!html.includes('data-lineup-position-btn'), `${pill}: no position pills`);
    assert.equal(sandbox.SOCIAL_INITS.length, 0, `${pill}: no post card`);
  }
});

test('an admin using "view as <player>" is treated as a player', () => {
  const { screen } = mountScreen({ isCoach: true, role: 'club' });
  screen.auth.viewAsPersonId = 42;
  screen.pill = 'pre_match_announcement';
  screen._render();
  assert.ok(!screen.element.innerHTML.includes('gc-social-toggle'));
});

test('deep links resolve to the right pill', () => {
  const { screen } = mountScreen({ isCoach: true, role: 'club' });
  assert.equal(screen._resolvePill({ postType: 'post_game' }), 'post_game');
  // The older "Game Day Roster" entry point, under its new name.
  assert.equal(screen._resolvePill({ mode: 'gameday' }), 'lineup');
  assert.equal(screen._resolvePill({ postType: 'not-a-post-type' }), 'pre_match_announcement');
  assert.equal(screen._resolvePill({}), 'pre_match_announcement');
});

test('matchId falls back to navigation.context.match', () => {
  const { screen } = mountScreen({ isCoach: true, role: 'club' });
  screen._bootstrap = async () => {};

  // How #game-day-roster's own callers have always passed the match.
  screen.navigation.context.match = { id: '3533', title: 'Persepolis FC vs Lighthouse Boys Club' };
  screen.onEnter({});
  assert.equal(screen.matchId, 3533);
  assert.equal(screen.title, 'Persepolis FC vs Lighthouse Boys Club');

  screen.onEnter({ matchId: 999, postType: 'game_day' });
  assert.equal(screen.matchId, 999, 'explicit params win');
  assert.equal(screen.pill, 'game_day');
});


// ---- RSVP & Player Details overlay (slice D: moved off #game-day-roster) ----

test('the 20-Man Squad pill offers the details overlay to a coach only', () => {
  const { screen } = mountScreen({ isCoach: true, role: 'club' });
  screen.pill = 'lineup';
  screen._render();
  assert.ok(screen.element.innerHTML.includes('gc-details-open'), 'coach gets the button');
  // 2 starters + 1 bench, alternates excluded.
  assert.match(screen.element.innerHTML, /3 on the game-day roster/);

  const player = mountScreen({ isCoach: false, role: 'player' }).screen;
  player.pill = 'lineup';
  player._render();
  assert.ok(!player.element.innerHTML.includes('gc-details-open'));
});

test('the overlay lists every player with jersey, RSVP and practice cells', () => {
  const { screen } = mountScreen({ isCoach: true, role: 'club' });
  screen._openDetails();
  assert.equal(screen.overlayOpen, true);
  assert.equal(screen.find('#gc-details-overlay').style.display, 'flex');

  const html = screen.find('#gc-details-list').innerHTML;
  assert.equal((html.match(/class="gdr-overlay-row/g) || []).length, 4);
  assert.equal((html.match(/gdr-jersey-input/g) || []).length, 4);
  // Two practice columns, one cell per player per column.
  assert.equal((html.match(/gdr-prac-cell/g) || []).length, 8);
  // An admin-set RSVP is marked as such; a synced one is not.
  assert.equal((html.match(/gdr-src-admin/g) || []).length, 1);

  screen._closeDetails();
  assert.equal(screen.overlayOpen, false);
  assert.equal(screen.find('#gc-details-overlay').style.display, 'none');
});

test('"on lineup" in the overlay reflects the zones, and is read-only', () => {
  const { screen } = mountScreen({ isCoach: true, role: 'club' });
  screen._openDetails();
  const html = screen.find('#gc-details-list').innerHTML;
  // Players 1, 4 (starters) and 2 (bench) are on it; 3 is an alternate.
  assert.equal((html.match(/gdr-row-selected/g) || []).length, 3);
  // The old screen's zone-less checkbox is what put stray players on a
  // post — there must be no way to set membership from in here.
  assert.ok(!html.includes('<input type="checkbox"'));
});

test('overlay filters narrow the list', () => {
  const { screen } = mountScreen({ isCoach: true, role: 'club' });
  const names = () => screen._getFilteredPlayers().map(p => p.lastName);

  screen.filterText = 'dabb';
  assert.deepEqual(names(), ['Dabbour']);
  screen.filterText = '';

  screen.filterRsvp = 'yes';
  assert.deepEqual(names(), ['Abdelgadir', 'Bado']);
  screen.filterRsvp = 'none';
  assert.deepEqual(names(), ['Dabbour']);
  screen.filterRsvp = 'all';

  screen.listFilter = 'roster_u23';
  assert.deepEqual(names(), ['de la Cruz']);
});

test('a coach RSVP override writes through and keeps the lineup view in sync', async () => {
  const { screen, calls } = mountScreen({ isCoach: true, role: 'club' });
  screen.stats.set(1, { gameRsvp: 'yes', practices: [] });

  await screen._setPlayerRSVP('1', 'no');
  const put = calls.find(c => c.url.includes('/player-rsvp'));
  assert.ok(put, 'PUT issued');
  assert.equal(put.method, 'PUT');
  assert.deepEqual(put.body, { player_id: '1', rsvp_status: 'no' });
  assert.equal(screen.players[0].rsvpStatus, 'no');
  assert.equal(screen.players[0].rsvpSource, 'admin');
  // The Going/Not Going buckets read this.stats, not this.players — both
  // describe the same fact, so the override has to land in both.
  assert.equal(screen.stats.get(1).gameRsvp, 'no');
});

test('tapping the active RSVP button again clears the override', async () => {
  const { screen, calls } = mountScreen({ isCoach: true, role: 'club' });
  screen.stats.set(1, { gameRsvp: 'yes', practices: [] });
  await screen._setPlayerRSVP('1', 'yes'); // already 'yes'
  assert.equal(screen.players[0].rsvpStatus, null);
  assert.equal(screen.players[0].rsvpSource, null);
  assert.equal(screen.stats.get(1).gameRsvp, null);
  assert.equal(calls.find(c => c.url.includes('/player-rsvp')).body.rsvp_status, null);
});

test('a jersey edit reaches both the roster PUT and the post graphic', async () => {
  const { screen, calls } = mountScreen({ isCoach: true, role: 'club' });
  await screen._saveJerseyNumber('1', '23');
  const put = calls.find(c => c.url === '/api/teams/120/roster/1');
  assert.ok(put, 'PUT issued against the player\'s roster team');
  assert.deepEqual(put.body, { jerseyNumber: 23 });
  // _buildRosterData reads this.roster, so the graphic would keep
  // printing the old number if only this.players were updated.
  assert.equal(screen.roster.find(r => r.id === 1).jerseyNumber, '23');
});

test('practice attendance cycles and releases', async () => {
  const { screen, calls } = mountScreen({ isCoach: true, role: 'club' });

  // Field-by-field rather than deepEqual: these objects are built inside
  // the vm realm, so they carry a different Object.prototype and
  // deepStrictEqual rejects them on prototype identity alone.
  await screen._setPracticeRSVP('11', 901, 0, 'no');
  assert.equal(screen.players[0].practice[0].v, 'no');
  assert.equal(screen.players[0].practice[0].o, true, 'marked as an override');
  assert.deepEqual(calls.at(-1).body, { person_id: '11', rsvp_status: 'no' });

  // Releasing an override falls back to the synced value, which only the
  // server knows — the stub answers 'yes'.
  await screen._releasePracticeRSVP('11', 901, 0);
  assert.deepEqual(calls.at(-1).body, { person_id: '11', clear: 'true' });
  assert.equal(screen.players[0].practice[0].v, 'yes');
  assert.equal(screen.players[0].practice[0].o, false, 'no longer an override');
});

test('the overlay survives a body re-render', () => {
  const { screen } = mountScreen({ isCoach: true, role: 'club' });
  screen._openDetails();
  const search = screen.find('#gc-player-search');
  search.value = 'dabb';

  // A zone toggle rewrites #gl-body. The modal lives outside it, so a
  // coach mid-way through the squad keeps their place.
  screen.pill = 'pre_match_announcement';
  screen._render();
  assert.equal(screen.find('#gc-details-overlay').style.display, 'flex');
  assert.equal(screen.find('#gc-player-search').value, 'dabb');
});

test('a player never gets the overlay data fetched or rendered', () => {
  const { screen } = mountScreen({ isCoach: false, role: 'player' });
  screen.pill = 'lineup';
  screen._render();
  assert.ok(!screen.element.innerHTML.includes('gc-details-open'));
});
