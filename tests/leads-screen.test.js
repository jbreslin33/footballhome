const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

function loadLeadsScreenClass() {
  const sourcePath = path.join(__dirname, '..', 'frontend', 'js', 'screens', 'leads.js');
  const source = fs.readFileSync(sourcePath, 'utf8');

  const context = {
    console,
    setTimeout,
    clearTimeout,
    setInterval,
    clearInterval,
    URLSearchParams,
    Blob,
    ClipboardItem: class {},
    window: {},
    navigator: {},
    document: {
      createElement() { return { style: {}, appendChild() {}, removeChild() {}, setAttribute() {}, querySelector() { return null; }, innerHTML: '', textContent: '' }; },
      body: { appendChild() {}, removeChild() {} },
    },
    localStorage: {
      getItem() { return null; },
      setItem() {},
    },
    Screen: class {},
  };

  vm.createContext(context);
  vm.runInContext(source + '\nthis.LeadsScreen = LeadsScreen;', context);
  return context.LeadsScreen;
}

test('youth lead snippets use youth-specific more-info copy', () => {
  const LeadsScreen = loadLeadsScreenClass();
  const screen = new LeadsScreen();
  screen.auth = { getUser: () => ({ first_name: 'Mike', last_name: 'Breslin' }) };
  screen.escapeHtml = (s) => String(s);
  screen._proBold = (s) => String(s);
  screen._nextPractice = () => ({ label: 'Thu, Jul 23' });
  screen._nextPickup = null;
  screen.formatPickupDate = () => '';

  const snippets = screen.messageSnippets('Boys Club (Grades 1–6)');
  const moreInfo = snippets.find((s) => s.id === 'more-info');

  assert.ok(moreInfo, 'expected a more-info snippet for youth lead');
  assert.match(moreInfo.body, /Boys Club|Girls Club|youth/i);
  assert.doesNotMatch(moreInfo.body, /Lighthouse Men's Soccer Club 1893/i);
  assert.doesNotMatch(moreInfo.body, /Men's Club/i);

  const intro = screen.messageTemplate('Boys Club (Grades 1–6)');
  assert.match(intro.email, /Boys Club soccer program/i);
  assert.doesNotMatch(intro.email, /Men's Club soccer team/i);
});
