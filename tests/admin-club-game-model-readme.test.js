const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

function loadAdminClubScreenClass() {
  const sourcePath = path.join(__dirname, '..', 'frontend', 'js', 'screens', 'admin-club.js');
  const source = fs.readFileSync(sourcePath, 'utf8');

  const context = {
    console,
    setTimeout,
    clearTimeout,
    setInterval,
    clearInterval,
    URLSearchParams,
    Blob,
    window: {},
    navigator: {},
    document: {
      createElement() {
        return {
          style: {},
          appendChild() {},
          removeChild() {},
          setAttribute() {},
          querySelector() { return null; },
          querySelectorAll() { return []; },
          innerHTML: '',
          textContent: '',
          addEventListener() {},
          closest() { return null; },
          classList: { add() {}, remove() {}, contains() { return false; } },
        };
      },
      body: { appendChild() {}, removeChild() {} },
    },
    localStorage: {
      getItem() { return null; },
      setItem() {},
    },
    Screen: class {},
  };

  vm.createContext(context);
  vm.runInContext(source + '\nthis.AdminClubScreen = AdminClubScreen;', context);
  return context.AdminClubScreen;
}

test('game model panel includes practice-readme guidance for varying numbers and abilities', () => {
  const AdminClubScreen = loadAdminClubScreenClass();
  const screen = new AdminClubScreen();

  const html = screen.buildGameModelReadmeHtml();

  assert.match(html, /Practice Design README/i);
  assert.match(html, /numbers/i);
  assert.match(html, /abilities/i);
  assert.match(html, /small groups/i);
  assert.match(html, /mixed ability/i);
});
