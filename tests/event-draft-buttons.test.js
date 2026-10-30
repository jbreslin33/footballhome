// ✉️ draft buttons on a game opened on the plain #event screen (the #my
// staff door): the same mig 728 buttons Game Center draws.  One click opens
// Gmail with everyone, then marks the draft sent and the button goes.
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

test('a game shows its draft button, and a click opens Gmail then marks it sent', async () => {
  const w = load();
  const draft = { id: 7, label: 'Cancel it', subject: 'S', body: 'B', recipients: [{ name: 'A', email: 'a@x.org' }, { name: 'B', email: 'b@x.org' }] };
  let sent = false;
  const auth = { fetch: async (url) => ({
    ok: true,
    json: async () => (url.includes('for-match') ? { club: { contacts: [{ id: 1 }] }, league: { contacts: [{ id: 2 }] } }
      : { drafts: sent ? [] : [draft] }),
  }) };
  const s = new w.EventScreen({}, auth);
  s.ev = { kind: 'match', match_id: 9 };
  s._render = () => {};
  await s._loadGameDrafts();
  const html = s._panelDraftButtons('data-ec-draft-open');
  assert.match(html, /data-ec-draft-open="7"/);
  assert.match(html, /✉️ Cancel it/);

  let href = '';
  s.openGmailCompose = (h) => { href = h; };
  s._postReminder = async (p, b) => { assert.equal(p, '/api/contact-drafts/sent'); assert.equal(b.id, 7); sent = true; return {}; };
  await s._panelDraftOpen(7);
  assert.match(decodeURIComponent(href), /a@x\.org,b@x\.org/);
  assert.equal(s._panelDraftButtons('data-ec-draft-open'), '');
});

test('a practice never looks for drafts', () => {
  const w = load();
  let called = false;
  const s = new w.EventScreen({}, { fetch: async () => { called = true; return { ok: false }; } });
  s.ev = { kind: 'practice' };
  s.onEventLoaded();
  assert.equal(called, false);
});
