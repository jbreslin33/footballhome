// ✉️ draft buttons on a game opened on the plain #event screen (the #my
// staff door): the same mig 728 buttons Game Center draws.  A button belongs
// to its game, and a click opens Gmail with everyone and leaves it in place.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { JSDOM } = require('jsdom');

const read = f => fs.readFileSync(path.join(__dirname, '..', 'frontend', 'js', f), 'utf8');

function load() {
  const dom = new JSDOM('<!doctype html><div id="app"></div>', { url: 'https://footballhome.org/', runScripts: 'outside-only' });
  const w = dom.window;
  w.console = console;
  w.CarpoolPanel = class {};
  w.MessageCopy = { outreachEmail: 'x@example.com', block: (_k, _t, v) => (v && v.to) || '' };
  const ctx = dom.getInternalVMContext();
  vm.runInContext(read('screen-base.js') + '\n;globalThis.Screen = Screen;', ctx);
  vm.runInContext(read('screens/event-screen.js') + '\n;globalThis.EventScreen = EventScreen;', ctx);
  return w;
}

test('only this game\'s drafts show, and a click opens Gmail and keeps the button', async () => {
  const w = load();
  const recipients = [{ name: 'A', email: 'a@x.org' }, { name: 'B', email: 'b@x.org' }];
  const drafts = [
    { id: 7, match_id: 9, label: 'Cancel it', subject: 'S', body: 'B', recipients },
    { id: 8, match_id: 10, label: 'Another game', subject: 'S', body: 'B', recipients },
    { id: 9, match_id: null, label: 'No game', subject: 'S', body: 'B', recipients },
  ];
  const auth = { fetch: async (url) => ({
    ok: true,
    json: async () => (url.includes('for-match') ? { club: { contacts: [{ id: 1 }] }, league: { contacts: [{ id: 2 }] } }
      : { drafts }),
  }) };
  const s = new w.EventScreen({}, auth);
  s.ev = { kind: 'match', match_id: 9 };
  s._render = () => {};
  await s._loadGameDrafts();
  const html = s._panelDraftButtons('data-ec-draft-open');
  assert.match(html, /data-ec-draft-open="7"/);
  assert.match(html, /data-ec-draft-open="9"/);
  assert.doesNotMatch(html, /data-ec-draft-open="8"/);

  let href = '';
  s.openGmailCompose = (h) => { href = h; };
  s._postReminder = async () => { assert.fail('a click must not mark a draft sent'); };
  await s._panelDraftOpen(7);
  assert.match(decodeURIComponent(href), /a@x\.org,b@x\.org/);
  assert.equal(s._panelDraftButtons('data-ec-draft-open'), html);
});

test('a practice never looks for drafts', () => {
  const w = load();
  let called = false;
  const s = new w.EventScreen({}, { fetch: async () => { called = true; return { ok: false }; } });
  s.ev = { kind: 'practice' };
  s.onEventLoaded();
  assert.equal(called, false);
});
