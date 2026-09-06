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

test('a welcome that is owed renders amber buttons and no pill', () => {
  const { screen } = loadBase();
  const p = { personId: 7, firstName: 'Ana', welcome: { due: true, lastSentAt: null } };
  const html = screen.renderWelcomeButtons(p, { personId: 7, playerPersonId: 9, phone: '+12155550100', email: 'ana@example.com' });
  assert.match(html, /data-welcome="sms"/);
  assert.match(html, /data-welcome="email"/);
  assert.match(html, /data-person-id="7"/);
  assert.match(html, /data-player-person-id="9"/);
  assert.match(html, /background:#b45309/, 'owed welcome is amber');
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
  assert.doesNotMatch(html, /#b45309/);
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
