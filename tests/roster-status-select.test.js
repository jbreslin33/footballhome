const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

// The roster-status dropdown is built from GET /api/teams/roster-statuses
// (migration 342), scoped to the column's league. These tests feed the
// class a fixture in place of the fetch and check the pure render side.
function loadBase() {
  const src = fs.readFileSync(path.join(__dirname, '..', 'frontend', 'js', 'screens', 'roster-screen-base.js'), 'utf8');
  const ctx = {
    console, setTimeout, clearTimeout, Intl, Date, Number, String, Array,
    window: {}, document: { createElement() { return { style: {} }; } }, navigator: {},
    Screen: class {},
    RosterMessaging: {},
  };
  vm.createContext(ctx);
  vm.runInContext(src + '\nthis.RosterScreenBase = RosterScreenBase;', ctx);
  return { RosterScreenBase: ctx.RosterScreenBase, screen: new ctx.RosterScreenBase() };
}

const APSL = 1, PARKS = 8, INTERNAL = 6;
const FIXTURE = [
  { code: 'not_on_roster',     displayName: 'Not on Roster',     description: 'Internal only', leagueIds: [APSL, PARKS], countsAsOnRoster: false, colorBg: null },
  { code: 'needs_itc',         displayName: 'Needs ITC',         description: 'ITC not yet requested', leagueIds: [APSL], countsAsOnRoster: false, colorBg: null },
  { code: 'needs_docs',        displayName: 'Needs Docs',        description: 'Birth certificate + headshot', leagueIds: [PARKS, INTERNAL], countsAsOnRoster: false, colorBg: '#be123c', colorFg: '#ffffff', colorBorder: '#fb7185' },
  { code: 'awaiting_approval', displayName: 'Awaiting Approval', description: '', leagueIds: [APSL, PARKS], countsAsOnRoster: false, colorBg: '#eab308', colorFg: '#422006', colorBorder: '#eab308' },
  { code: 'on_roster',         displayName: 'On Roster',         description: '', leagueIds: [APSL, PARKS], countsAsOnRoster: true,  colorBg: '#16a34a', colorFg: '#ffffff', colorBorder: '#16a34a' },
  { code: 'possible_drop',     displayName: 'Possible Drop',     description: '', leagueIds: [APSL, PARKS], countsAsOnRoster: true,  colorBg: '#f97316', colorFg: '#431407', colorBorder: '#f97316' },
];

function withFixture() {
  const loaded = loadBase();
  loaded.RosterScreenBase.ROSTER_STATUSES = FIXTURE;
  return loaded;
}

const optionCodes = (html) => [...html.matchAll(/<option value="([^"]*)"/g)].map(m => m[1]);

test('an APSL column offers the adult pipeline and none of the youth docs steps', () => {
  const { screen } = withFixture();
  const html = screen.renderStatusSelect({ personId: 7, rosterStatus: null }, { teamId: 35, leagueId: APSL, leagueName: 'American Premier Soccer League' }, true);
  assert.deepEqual(optionCodes(html), ['', 'not_on_roster', 'needs_itc', 'awaiting_approval', 'on_roster', 'possible_drop']);
  assert.match(html, /American Premier Soccer League pipeline/);
  assert.match(html, /<option value="" selected>Status: —<\/option>/);
});

test('a Parks & Rec column offers the docs steps and no ITC', () => {
  const { screen } = withFixture();
  const html = screen.renderStatusSelect({ personId: 7, rosterStatus: 'needs_docs' }, { teamId: 913, leagueId: PARKS }, true);
  const codes = optionCodes(html);
  assert.ok(codes.includes('needs_docs'));
  assert.ok(!codes.includes('needs_itc'));
  assert.match(html, /value="needs_docs" title="Birth certificate \+ headshot" selected/);
  assert.match(html, /background:#be123c; color:#ffffff; border:1px solid #fb7185/, 'colour comes from the row, not a JS map');
});

test('an intramural column is the short docs-only list', () => {
  const { screen } = withFixture();
  const html = screen.renderStatusSelect({ personId: 7 }, { teamId: 935, leagueId: INTERNAL }, true);
  assert.deepEqual(optionCodes(html), ['', 'needs_docs']);
});

test('a status the league does not list stays visible when the player already carries it', () => {
  const { screen } = withFixture();
  // An APSL man tagged Needs Docs before the scoping: still shown, still selected.
  const html = screen.renderStatusSelect({ personId: 7, rosterStatus: 'needs_docs' }, { teamId: 35, leagueId: APSL }, true);
  assert.match(html, /value="needs_docs"[^>]*selected>Needs Docs</);
  // A code the lookup has never heard of still renders rather than vanishing.
  const html2 = screen.renderStatusSelect({ personId: 7, rosterStatus: 'legacy_code' }, { teamId: 35, leagueId: APSL }, true);
  assert.match(html2, /value="legacy_code"[^>]*selected>legacy_code</);
});

test('a column with no league gets the whole list', () => {
  const { screen } = withFixture();
  const html = screen.renderStatusSelect({ personId: 7 }, { teamId: 999, leagueId: null }, true);
  assert.equal(optionCodes(html).length, 1 + FIXTURE.length);
});

test('the on-roster tally and neutral colours come from the lookup', () => {
  const { RosterScreenBase, screen } = withFixture();
  assert.equal(RosterScreenBase.countsAsOnRoster('on_roster'), true);
  assert.equal(RosterScreenBase.countsAsOnRoster('possible_drop'), true);
  assert.equal(RosterScreenBase.countsAsOnRoster('awaiting_approval'), false);
  assert.equal(RosterScreenBase.countsAsOnRoster(''), false);
  assert.equal(screen.rosterStatusStyle('not_on_roster'), 'background:#0f172a; color:#ffffff; border:1px solid #475569;');
  assert.equal(screen.rosterStatusStyle('on_roster'), 'background:#16a34a; color:#ffffff; border:1px solid #16a34a;');
});

test('the select is hidden for viewers who cannot edit, and before the lookup loads only blank + current show', () => {
  const { RosterScreenBase, screen } = loadBase();
  assert.equal(screen.renderStatusSelect({ personId: 7 }, { teamId: 35, leagueId: APSL }, false), '');
  RosterScreenBase.ROSTER_STATUSES = [];
  const html = screen.renderStatusSelect({ personId: 7, rosterStatus: 'on_roster' }, { teamId: 35, leagueId: APSL }, true);
  assert.deepEqual(optionCodes(html), ['', 'on_roster']);
});
