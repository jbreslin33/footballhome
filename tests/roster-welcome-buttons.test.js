const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

// Loads RosterScreenBase in a sandbox with the minimum the class needs at
// definition time. The WELCOME buttons are pure render helpers, so a stub
// Screen and a few instance helpers are all a test needs.
function loadBase() {
  const src = fs.readFileSync(path.join(__dirname, '..', 'frontend', 'js', 'screens', 'roster-screen-base.js'), 'utf8');
  const ctx = {
    console, setTimeout, clearTimeout, Intl, Date, Number, String,
    window: {}, document: { createElement() { return { style: {} }; } }, navigator: {},
    Screen: class {},
    RosterMessaging: {},
  };
  vm.createContext(ctx);
  vm.runInContext(src + '\nthis.RosterScreenBase = RosterScreenBase;', ctx);
  const screen = new ctx.RosterScreenBase();
  screen.escape = (s) => String(s == null ? '' : s).replace(/"/g, '&quot;');
  screen.formatPhone = (s) => String(s);
  screen.contactFor = (p) => ({ phone: p.phone || null, email: p.email || null });
  return { RosterScreenBase: ctx.RosterScreenBase, screen };
}

test('a welcome that is owed renders fuchsia buttons and no pill', () => {
  const { screen } = loadBase();
  const p = { personId: 7, firstName: 'Ana', welcome: { due: true, lastSentAt: null } };
  const html = screen.renderWelcomeButtons(p, { personId: 7, playerPersonId: 9, phone: '+12155550100', email: 'ana@example.com' });
  assert.match(html, /data-welcome="sms"/);
  assert.match(html, /data-welcome="email"/);
  assert.match(html, /data-person-id="7"/);
  assert.match(html, /data-player-person-id="9"/);
  assert.match(html, /background:#c026d3/, 'owed welcome is fuchsia');
  assert.match(html, /welcome not sent yet/);
  assert.doesNotMatch(html, /👋 /, 'no last-sent pill before a send');
});

test('a sent welcome renders slate buttons plus the last-send pill, and stays clickable', () => {
  const { screen } = loadBase();
  const p = { personId: 7, firstName: 'Ana', welcome: { due: false, lastSentAt: '2026-09-06T18:30:00.000Z', lastChannel: 'email', lastContact: 'ana@example.com' } };
  const html = screen.renderWelcomeButtons(p, { personId: 7, email: 'ana@example.com' });
  assert.match(html, /data-welcome="email"/, 'button still offered after a send');
  assert.doesNotMatch(html, /data-welcome="sms"/, 'no phone → no SMS button');
  assert.match(html, /background:#334155/);
  assert.doesNotMatch(html, /#c026d3/);
  assert.match(html, /👋 ✉ Sep 6/);
  assert.match(html, /Welcome emailed .* to ana@example\.com/);
});

test('no recipient person or no contact → nothing rendered', () => {
  const { screen } = loadBase();
  assert.equal(screen.renderWelcomeButtons({ welcome: { due: true } }, { personId: 0, email: 'x@y.z' }), '');
  assert.equal(screen.renderWelcomeButtons({ personId: 3, welcome: { due: true } }, {}), '');
});

test('last-send pill: sms channel and never-sent', () => {
  const { RosterScreenBase } = loadBase();
  assert.equal(RosterScreenBase.renderWelcomeLastPill(null), '');
  assert.equal(RosterScreenBase.renderWelcomeLastPill({ due: true }), '');
  assert.match(RosterScreenBase.renderWelcomeLastPill({ lastSentAt: '2026-09-06T18:30:00.000Z', lastChannel: 'sms' }), /👋 💬 Sep 6/);
});

test('travel-column youth cards carry the docs ask; others do not', () => {
  const { screen } = loadBase();
  const p = { personId: 9, firstName: 'Jaquil', welcome: { due: true } };
  const withDocs = screen.renderWelcomeButtons(p, { personId: 7, playerPersonId: 9, email: 'a@b.c', needsDocs: true, docsFormUrl: 'https://forms.gle/x' });
  assert.match(withDocs, /data-needs-docs="1"/);
  assert.match(withDocs, /data-docs-form-url="https:\/\/forms\.gle\/x"/);
  const without = screen.renderWelcomeButtons(p, { personId: 7, playerPersonId: 9, email: 'a@b.c' });
  assert.match(without, /data-needs-docs=""/);
  assert.match(without, /data-docs-form-url=""/);
});

// Docs rule (migration 340): status beats column.
test('playerNeedsDocs: needs_docs asks, has_docs never asks, blank falls back to the column', () => {
  const src = fs.readFileSync(path.join(__dirname, '..', 'frontend', 'js', 'screens', 'boys-roster.js'), 'utf8');
  const ctx = { console, window: {}, document: {}, Screen: class {}, RosterScreenBase: class {}, RosterMessaging: {} };
  vm.createContext(ctx);
  vm.runInContext(src + '\nthis.BoysRosterScreen = BoysRosterScreen;', ctx);
  const B = ctx.BoysRosterScreen;
  const intra  = { label: 'U10 Intramural', teamId: 1 };
  const travel = { label: 'U10 Travel', teamId: 2 };
  assert.equal(B.playerNeedsDocs({ rosterStatus: 'needs_docs' }, travel), true);
  assert.equal(B.playerNeedsDocs({ rosterStatus: 'has_docs' }, intra), false);
  assert.equal(B.playerNeedsDocs({ rosterStatus: 'on_roster' }, intra), false);
  assert.equal(B.playerNeedsDocs({ rosterStatus: null }, intra), true);
  assert.equal(B.playerNeedsDocs({ rosterStatus: '' }, travel), false);
});

test('status dropdown offers Needs Docs and Has Docs, and Has Docs is green', () => {
  const { screen, RosterScreenBase } = loadBase();
  const html = screen.renderStatusSelect({ personId: 5, rosterStatus: 'has_docs' }, { teamId: 3 }, true);
  assert.match(html, /<option value="needs_docs"/);
  assert.match(html, /<option value="has_docs"\s+selected/);
  assert.match(html, /background:#059669/);
  assert.ok(RosterScreenBase.ROSTER_STATUS_COLORS.needs_docs);
});
