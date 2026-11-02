const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

// Team pill groups come from team_persons (mig 945) and the Roster pill keeps
// every player on the team in exactly one league group.
function load() {
  const src = fs.readFileSync(path.join(__dirname, '..', 'frontend', 'js', 'screens', 'roster-screen-base.js'), 'utf8');
  const ctx = {
    console, setTimeout, clearTimeout, Intl, Date, Number, String, Array, Set, Map,
    window: {}, document: { createElement() { return { style: {} }; } }, navigator: {},
    localStorage: { getItem: () => null, setItem() {} },
    Screen: class {}, RosterMessaging: {},
  };
  vm.createContext(ctx);
  vm.runInContext(src + '\nthis.RosterScreenBase = RosterScreenBase;', ctx);
  const B = ctx.RosterScreenBase;
  B.ROSTER_STATUSES = [
    { code: 'needs_add', displayName: 'Needs Add', boardSection: 'proposed' },
    { code: 'awaiting_approval', displayName: 'Awaiting Approval', boardSection: 'pending_add' },
    { code: 'on_roster', displayName: 'On Roster', countsAsOnRoster: true },
    { code: 'possible_drop', displayName: 'Possible Drop', countsAsOnRoster: true, boardSection: 'drop' },
  ];
  const screen = new B();
  screen.renderPlayer = (p) => `<card>${p.fullName}</card>`;
  screen.orderColumnPlayers = (list) => list.map(player => ({ player }));
  return { B, screen };
}

function column(screen, players) {
  const data = { buckets: { 7: players }, columns: [] };
  screen._boardView = 'roster';
  return screen.renderColumnSections({ teamId: 7 }, players, () => '', data);
}

// The section's text up to the PROJECTED ROSTER block, which repeats names.
const sectionOf = (html, name) => {
  const at = html.indexOf(`>${name}<`);
  return at < 0 ? '' : html.slice(at).split('PROJECTED ROSTER')[0];
};

test('a squad status wins over paper, an injury wins over a squad status', () => {
  const { B, screen } = load();
  assert.equal(screen.columnCategoryOf({ personId: 1, inviteOnly: true, squadStatus: 'inactive' }), 'inactive');
  assert.equal(screen.columnCategoryOf({ personId: 1, inviteOnly: true, squadStatus: 'practice_squad' }), 'practice_squad');
  B.HEALTH.people[2] = { code: 'hurt' };
  assert.equal(screen.columnCategoryOf({ personId: 2, inviteOnly: true, squadStatus: 'inactive' }), 'injured');
  assert.equal(screen.columnCategoryOf({ personId: 3, inviteOnly: true }), 'paper');
});

test('the Team dropdown offers both new groups and marks the current one', () => {
  const { B, screen } = load();
  B.HEALTH.statuses = [];
  const html = screen.renderTeamStatusSelect({ personId: 5, squadStatus: 'inactive', inviteOnly: true }, { teamId: 7 }, true);
  assert.match(html, /<option value="practice_squad"/);
  assert.match(html, /<option value="inactive" selected>/);
  assert.match(html, /data-team-code="inactive"/);
});

test('team columns hold league groups only: a blank status stays out of NEEDS ADD and the column', () => {
  const { screen } = load();
  const html = column(screen, [
    { personId: 1, fullName: 'Listed', rosterStatus: 'on_roster' },
    { personId: 2, fullName: 'Picked', rosterStatus: 'needs_add' },
    { personId: 3, fullName: 'Blank' },
    { personId: 4, fullName: 'Waiting', rosterStatus: 'awaiting_roster_spot' },
  ]);
  assert.match(html, /<card>Listed<\/card>/);
  assert.match(sectionOf(html, 'NEEDS ADD'), /Picked/);
  assert.doesNotMatch(html, /Blank|Waiting/);
});

test('the left column holds each off-roster member once, in one stack', () => {
  const { B, screen } = load();
  B.ROSTER_STATUSES.push({ code: 'awaiting_roster_spot', displayName: 'No Room', boardSection: 'no_room' });
  screen._data = { officialRosters: { 7: { names: ['Listed'], personIds: [1] } } };
  const t7 = { teamId: 7, label: 'Liga 1' }, t8 = { teamId: 8, label: 'Reserves' }, t9 = { teamId: 9, label: 'Women' };
  const data = {
    columns: [t7, t8, t9],
    unassigned: [{ personId: 5, fullName: 'Nobody', welcome: { due: true } }, { personId: 6, fullName: 'Oldtimer' }],
    buckets: {
      7: [{ personId: 1, fullName: 'Listed' }, { personId: 2, fullName: 'Twice' }, { personId: 3, fullName: 'Picked', rosterStatus: 'needs_add' }],
      8: [{ personId: 1, fullName: 'Listed' }, { personId: 2, fullName: 'Twice' }, { personId: 4, fullName: 'Full', rosterStatus: 'awaiting_roster_spot' }],
      9: [{ personId: 7, fullName: 'Women On', rosterStatus: 'on_roster' }, { personId: 8, fullName: 'Women Off' }],
    },
  };
  const s = screen.membersOffRosters(data);
  const names = (l) => [...l].map(e => e.p.fullName);
  assert.deepEqual(names(s.onboard), ['Nobody']);
  assert.deepEqual(names(s.notOnRoster), ['Oldtimer', 'Twice', 'Women Off']);
  assert.deepEqual(names(s.noRoom), ['Full']);
});

test('the gap warning names a team whose list is missing him, unless a rule bars him or he is on the way', () => {
  const { B, screen } = load();
  screen._data = { officialRosters: { 7: { names: ['A'], personIds: [1] }, 8: { names: ['Z'], personIds: [9] }, 6: { names: ['Y'], personIds: [9] } } };
  const data = {
    columns: [{ teamId: 7, label: 'APSL' }, { teamId: 8, label: 'Liga 1' }, { teamId: 6, label: 'Reserves' }],
    rosterRules: { 7: { excludes: [6] } },
    buckets: { 7: [{ personId: 1 }], 8: [{ personId: 1 }], 6: [{ personId: 1 }] },
  };
  assert.deepEqual([...screen.listGapTeams(1, data, 7)].map(c => c.label), ['Liga 1']);
  data.buckets[8][0].rosterStatus = 'needs_add';
  assert.equal(screen.listGapTeams(1, data, 7).length, 0);
  data.buckets[8][0] = { personId: 1, inviteOnly: true };
  assert.equal(screen.listGapTeams(1, data, 7).length, 0);
});

test('a drop stays in ON ROSTER and is listed under NEEDS DROP', () => {
  const { screen } = load();
  const html = column(screen, [{ personId: 1, fullName: 'Going', rosterStatus: 'possible_drop' }]);
  assert.equal(html.split('<card>Going</card>').length, 2);
  assert.match(sectionOf(html, 'NEEDS DROP'), /Going/);
});
