// 🧾 Budget lines on #finances → Expenses (mig 921): edit an estimate, ✓ settle
// a finished bill.  A settled line takes no new invoice lines on #invoices, but
// a line already pointing at it must keep it, or a save would clear the link.
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
  w.MessageCopy = { block: (_k, tier, v) => ({
    budget_columns: 'Budget line|Estimate|Invoiced|Still to come|Settled',
    budget_per_member: `per member × ${v && v.units}`,
  }[tier] || '') };
  const ctx = dom.getInternalVMContext();
  vm.runInContext(read('screen-base.js') + '\n;globalThis.Screen = Screen;', ctx);
  vm.runInContext(read('screens/finances.js') + '\n;globalThis.FinancesScreen = FinancesScreen;', ctx);
  vm.runInContext(read('screens/invoices.js') + '\n;globalThis.InvoicesScreen = InvoicesScreen;', ctx);
  return w;
}

const budget = [
  { id: 1, label: 'U8 league dues', amount: 500, amount_per: 'fixed', units: 1, invoiced: 350, remaining: 0, settled: true, is_assumed: false },
  { id: 2, label: 'Kits', amount: 35, amount_per: 'member', units: 60, invoiced: 0, remaining: 2100, settled: false, is_assumed: true },
];

function screen(w) {
  const s = new w.FinancesScreen({}, { fetch: async () => ({ ok: true, json: async () => ({}) }) });
  s.element = s.render();
  s.expenses = { budget };
  return s;
}

test('every budget line shows its estimate and tick, settled lines included', () => {
  const s = screen(load());
  s.element.innerHTML = s._budgetHtml();
  const rows = [...s.element.querySelectorAll('[data-budget-line]')];
  assert.equal(rows.length, 2);
  assert.equal(rows[0].querySelector('[data-budget-settled]').checked, true);
  assert.equal(rows[1].querySelector('[data-budget-settled]').checked, false);
  assert.equal(rows[1].querySelector('[data-budget-amount]').value, '35.00');
  assert.match(rows[1].textContent, /per member × 60/);
  assert.match(rows[1].textContent, /Kits\*/);
});

test('editing an estimate and ticking settled each post that one change', () => {
  const w = load();
  const s = screen(w);
  const saved = [];
  s._saveBudgetLine = (id, change) => { saved.push([id, change]); };
  s.element.querySelector('#fn-body').innerHTML = s._budgetHtml();
  const amount = s.element.querySelector('[data-budget-line="2"] [data-budget-amount]');
  amount.value = '40';
  amount.dispatchEvent(new w.Event('change', { bubbles: true }));
  const tick = s.element.querySelector('[data-budget-line="2"] [data-budget-settled]');
  tick.checked = true;
  tick.dispatchEvent(new w.Event('change', { bubbles: true }));
  assert.equal(JSON.stringify(saved), JSON.stringify([['2', { amount: 40 }], ['2', { settled: true }]]));
});

test('a blank estimate saves nothing', () => {
  const w = load();
  const s = screen(w);
  s._renderBody = () => {};
  s._saveBudgetLine = () => { assert.fail('blank must not save'); };
  s.element.querySelector('#fn-body').innerHTML = s._budgetHtml();
  const amount = s.element.querySelector('[data-budget-line="1"] [data-budget-amount]');
  amount.value = '';
  amount.dispatchEvent(new w.Event('change', { bubbles: true }));
});

test('#invoices hides a settled budget line unless the line already points at it', () => {
  const w = load();
  const s = new w.InvoicesScreen({}, {});
  s.board = { budget_lines: [
    { id: 1, label: 'Settled', category: 'league_dues', remaining: 0, settled: true },
    { id: 2, label: 'Open', category: 'league_dues', remaining: 500, settled: false },
  ] };
  assert.doesNotMatch(s._budgetSel('league_dues', null), /value="1"/);
  assert.match(s._budgetSel('league_dues', null), /value="2"/);
  assert.match(s._budgetSel('league_dues', 1), /value="1" selected/);
  assert.doesNotMatch(s._budgetSel('__any__', null), /value="1"/);
});
