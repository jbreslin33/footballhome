const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

function loadLeadsSandbox() {
  const sourcePath = path.join(__dirname, '..', 'frontend', 'js', 'screens', 'leads.js');
  const source = fs.readFileSync(sourcePath, 'utf8');

  const consoleErrors = [];
  const context = {
    __consoleErrors: consoleErrors,
    console: { ...console, error: (...a) => consoleErrors.push(a.join(' ')) },
    setTimeout,
    clearTimeout,
    setInterval,
    clearInterval,
    URLSearchParams,
    Blob,
    ClipboardItem: class {},
    File: class { constructor(parts, name, opts) { this.parts = parts; this.name = name; this.type = (opts || {}).type; } },
    URL: { createObjectURL: () => 'blob:stub', revokeObjectURL() {} },
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

  // leads.js reads window.LighthouseProgramInfo for the program copy and
  // the registration links (DB-driven since 2026-08-21). Load the real
  // module rather than stubbing it — it is the single source of truth
  // the snippet assertions below are actually about, and a stub would
  // let the copy drift without the test noticing. Its REGISTER_LINKS
  // start empty exactly as they do in the browser before
  // loadRegisterLinks() resolves; the templates fall back to the bare
  // LeagueApps URL, which is all these tests need.
  vm.runInContext(
    fs.readFileSync(path.join(__dirname, '..', 'frontend', 'js', 'lib', 'program-info.js'), 'utf8'),
    context);

  vm.runInContext(source + '\nthis.LeadsScreen = LeadsScreen;', context);
  return context;
}

// The class closes over the sandbox's globals (navigator, File, URL,
// document), so a test that wants to swap one has to reach the context
// itself — hence the sandbox variant above.
function loadLeadsScreenClass() {
  return loadLeadsSandbox().LeadsScreen;
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
  // Was doesNotMatch(/Men's Club/i), which broke when the shared program
  // description grew a history sentence naming all four clubs ("through
  // its Boys Club, Girls Club, Men's Club, and Women's Club"). The words
  // are not the problem — the adult *framing* is, so assert on the line
  // that actually differs: youth copy addresses a parent about their
  // player, adult copy addresses the player.
  assert.match(moreInfo.body, /Your player's membership/i);
  assert.doesNotMatch(moreInfo.body, /Your membership runs/i);

  const intro = screen.messageTemplate('Boys Club (Grades 1–6)');
  assert.match(intro.email, /Boys Club soccer program/i);
  assert.doesNotMatch(intro.email, /Men's Club soccer team/i);
});


// ── Save to phone contacts (2026-08-26) ─────────────────────────────────
//
// Owner: "on leads page i need to be able to click a button and add
// player to contacts on my android phone but for others apple too."
// The feature is only useful if the tap reaches the Contacts app, so
// what these assert is the delivery path — share sheet where the browser
// supports it, .vcf download only where it does not.

function vcardHarness({ navigator: nav } = {}) {
  const ctx = loadLeadsSandbox();
  const calls = { fetches: [], downloads: [] };

  ctx.navigator = nav || {};
  ctx.document.createElement = () => {
    const a = { style: {}, click() { calls.downloads.push(a.download); } };
    return a;
  };

  const screen = new ctx.LeadsScreen();
  screen.auth = {
    fetch: async (url) => {
      calls.fetches.push(url);
      return {
        ok: true,
        blob: async () => ({ size: 42 }),
        headers: { get: () => 'attachment; filename="Jane_Doe_Lighthouse.vcf"' },
      };
    },
  };
  return { screen, calls };
}

test('save contact hands the vCard to the OS share sheet when the browser can', async () => {
  let shared = null;
  const { screen, calls } = vcardHarness({
    navigator: { canShare: (d) => !!(d && d.files && d.files.length), share: async (d) => { shared = d; } },
  });

  const outcome = await screen.saveLeadContact(7, 'self');

  assert.equal(outcome, 'shared');
  assert.deepEqual(calls.downloads, [], 'sharing must not also drop a file in Downloads');
  assert.equal(shared.files.length, 1);
  assert.equal(shared.files[0].name, 'Jane_Doe_Lighthouse.vcf');
  // Android picks share targets off the MIME type — octet-stream offers
  // file managers instead of Contacts.
  assert.equal(shared.files[0].type, 'text/vcard');
  // Files only: a title/text turns the sheet into "share a message" and
  // the Contacts target disappears.
  assert.equal(shared.title, undefined);
  assert.equal(shared.text, undefined);
});

test('save contact falls back to a .vcf download when file sharing is unavailable', async () => {
  const { screen, calls } = vcardHarness({ navigator: {} });

  const outcome = await screen.saveLeadContact(7, 'self');

  assert.equal(outcome, 'downloaded');
  assert.deepEqual(calls.downloads, ['Jane_Doe_Lighthouse.vcf']);
});

test('a dismissed share sheet still leaves a .vcf that opens into Contacts', async () => {
  // Whether the sheet lists Contacts at all depends on the ROM, so a
  // dismissal is as likely to mean "it wasn't in there" as "never mind".
  // The button must not silently do nothing.
  const abort = Object.assign(new Error('cancelled'), { name: 'AbortError' });
  const { screen, calls } = vcardHarness({
    navigator: { canShare: () => true, share: async () => { throw abort; } },
  });

  assert.equal(await screen.saveLeadContact(7, 'self'), 'downloaded');
  assert.deepEqual(calls.downloads, ['Jane_Doe_Lighthouse.vcf']);
});

test('save contact keeps the blob so a retry can share without an await', async () => {
  // iOS Safari can reject navigator.share when a fetch is awaited first
  // (transient activation). We fall back to the download and keep the
  // blob so the next tap shares straight away.
  let shares = 0;
  const nav = {
    canShare: () => true,
    share: async () => {
      shares += 1;
      if (shares === 1) throw Object.assign(new Error('gesture'), { name: 'NotAllowedError' });
    },
  };
  const { screen, calls } = vcardHarness({ navigator: nav });

  assert.equal(await screen.saveLeadContact(7, 'youth-pair'), 'downloaded');
  assert.equal(await screen.saveLeadContact(7, 'youth-pair'), 'shared');
  assert.equal(calls.fetches.length, 1, 'second tap must not re-fetch the vCard');
  assert.equal(calls.fetches[0], '/api/leads/7/vcard?kind=youth-pair');
});

test('every contactable lead card carries a save-to-contacts button', () => {
  const LeadsScreen = loadLeadsScreenClass();
  const screen = new LeadsScreen();
  screen.formLabel = () => '';
  screen.formatPhoneNumber = (p) => p;
  screen.buildMailHref = () => 'mailto:x';
  screen.buildSmsHref = () => 'sms:x';
  screen.buildMailHrefForSnippet = () => 'mailto:x';
  screen.buildSmsHrefForSnippet = () => 'sms:x';

  const adult = screen.renderLead({ id: 3, name: 'Jane Doe', phone: '5551234567' }, "Men's Club");
  assert.match(adult, /data-channel="vcard"/);
  assert.match(adult, /data-kind="self"/);

  // Youth funnels save a pair — parent card plus player placeholder.
  const youth = screen.renderLead({ id: 4, name: 'Sam Ray', email: 's@x.com' }, 'Youth Boys Club');
  assert.match(youth, /data-kind="youth-pair"/);
  assert.match(youth, /Save \(2\)/);

  // A name with no phone and no email makes a useless address-book row.
  const empty = screen.renderLead({ id: 5, name: 'No Contact' }, "Men's Club");
  assert.doesNotMatch(empty, /data-channel="vcard"/);
});


// ── Registration links (2026-08-26) ─────────────────────────────────────
//
// Owner: "the mens text more info is sending people to members and pickup
// reg page! all leads links email and text for all programs must go
// directly to proper member reg for men or women or boys or girls. we are
// losing players!"
//
// The bare https://lighthouse1893.leagueapps.com fallback is not a
// harmless default: it is the club's programme LIST, which offers Pickup
// with its own Register button right next to Membership. Any funnel that
// reaches it is a funnel that can register a lead into the wrong
// programme, so no funnel may reach it when the links have loaded.

const CATEGORY_URLS = {
  boys:   'https://lighthouse1893.leagueapps.com/leagues/soccer/5039252-boys',
  girls:  'https://lighthouse1893.leagueapps.com/leagues/soccer/5039357-girls',
  mens:   'https://lighthouse1893.leagueapps.com/leagues/soccer-(outdoor)/5039300-mens',
  womens: 'https://lighthouse1893.leagueapps.com/leagues/soccer-(outdoor)/5039340-womens',
};

// Drive the real loader rather than assigning REGISTER_LINKS directly —
// program-info.js exposes it through a getter with no setter, so a direct
// assignment is silently dropped. Feeding the API payload also exercises
// the parts that matter: the active-only filter and the category→key
// mapping. Pickup rows are included on purpose; they must not survive.
async function linkScreen() {
  const ctx = loadLeadsSandbox();
  ctx.fetch = async () => ({
    ok: true,
    json: async () => ({ data: [
      { category: 'boys',  variant: 'active', registrationUrl: CATEGORY_URLS.boys },
      { category: 'boys',  variant: 'pickup', registrationUrl: 'https://…/5064618-boys-pickup' },
      { category: 'girls', variant: 'active', registrationUrl: CATEGORY_URLS.girls },
      { category: 'girls', variant: 'pickup', registrationUrl: 'https://…/5064662-girls-pickup' },
      { category: 'men',   variant: 'active', registrationUrl: CATEGORY_URLS.mens },
      { category: 'men',   variant: 'pickup', registrationUrl: 'https://…/5070075-mens-pickup' },
      { category: 'men',   variant: 'inactive', registrationUrl: null },
      { category: 'women', variant: 'active', registrationUrl: CATEGORY_URLS.womens },
      { category: 'women', variant: 'pickup', registrationUrl: 'https://…/5064686-womens-pickup' },
    ] }),
  });
  await ctx.window.LighthouseProgramInfo.loadRegisterLinks();
  const screen = new ctx.LeadsScreen();
  screen.auth = { getUser: () => ({ first_name: 'Mike', last_name: 'Breslin' }) };
  screen.escapeHtml = (s) => String(s);
  screen._proBold = (s) => String(s);
  screen._nextPractice = () => ({ label: 'Thu, Jul 23' });
  screen._nextPickup = null;
  screen.formatPickupDate = () => '';
  return { screen, errors: ctx.__consoleErrors };
}

test('every funnel links straight to its own category membership page', async () => {
  const { screen } = await linkScreen();

  const EXPECTED = {
    "Men's Club":              'mens',
    'Brazil Men':              'mens',
    'PR Men':                  'mens',
    'U23 Men':                 'mens',
    'APSL / Liga 1':           'mens',
    'APSL Trials':             'mens',
    'LIGA 1 Trials':           'mens',
    "Women's Club":            'womens',
    'U23 Women':               'womens',
    'Tri County Women':        'womens',
    'Boys Club (Grades 1–6)':  'boys',
    'Boys Club (K-12)':        'boys',
    'Boys Club (U11/U12)':     'boys',
    'Girls Club (Grades 1–6)': 'girls',
    'Girls Club (K-12)':       'girls',
    'Girls Club (U11/U12)':    'girls',
    'Youth (Grades 1–6)':      'boys',
  };

  for (const [funnel, category] of Object.entries(EXPECTED)) {
    const ctx = screen.funnelContext(funnel);
    assert.equal(ctx.link, CATEGORY_URLS[category],
      `${funnel} should link to the ${category} membership page`);
  }
});

test('no funnel message ever sends a lead to the programme list', async () => {
  const { screen } = await linkScreen();
  // The bare club URL lists Membership AND Pickup — landing a lead there
  // is how they register for the wrong one.
  const BARE = 'https://lighthouse1893.leagueapps.com';
  const isBare = (url) => url === BARE || url === BARE + '/';

  for (const funnel of ["Men's Club", "Women's Club", 'Boys Club (Grades 1–6)',
                        'Girls Club (Grades 1–6)', 'APSL Trials', 'LIGA 1 Trials']) {
    const { link } = screen.funnelContext(funnel);
    assert.ok(!isBare(link), `${funnel} fell through to the programme list`);
    // A membership link must not be the pickup checkout either.
    assert.doesNotMatch(link, /pickup/i, `${funnel} links to a pickup programme`);
  }
});

test('an unmapped funnel is loud about it and never yields the programme list', async () => {
  const { screen, errors } = await linkScreen();

  const { link } = screen.funnelContext('Some Funnel We Never Mapped');

  // 2026-09-06: the bare club URL is no longer a fallback at all — it
  // sent club-wide-ad parents to the Pickup checkout. The "link" is a
  // placeholder no coach can mistake for a working URL.
  assert.equal(link, screen.constructor.MISSING_REGISTRATION_LINK);
  assert.doesNotMatch(link, /leagueapps\.com/);
  assert.ok(errors.some(e => /No registration URL for funnel/.test(e)),
    'expected a console.error naming the unmapped funnel');
});

test('a funnel outside the exact map still resolves by keyword', async () => {
  const { screen } = await linkScreen();
  assert.equal(screen.funnelContext('U23 Men + PR').link,        CATEGORY_URLS.mens);
  assert.equal(screen.funnelContext('Tri County Women 2027').link, CATEGORY_URLS.womens);
  assert.equal(screen.funnelContext('Girls Club (U9/U10)').link,  CATEGORY_URLS.girls);
  assert.equal(screen.funnelContext('Boys Club (K-12) fall').link, CATEGORY_URLS.boys);
});

// The club-wide ad (form 1813864682814937, 2026-08-30) pools all four
// programs into one form; the program lives in the lead's
// program_interest answer. Every template for such a lead must be built
// from THAT, not from the 'Club-Wide (All Programs)' column label — the
// column label carried no category, fell through to the programme list,
// and parents registered for Pickup instead of Membership (2026-09-06).
test('club-wide leads take their funnel from program_interest', async () => {
  const { screen } = await linkScreen();
  const CLUB_WIDE = screen.constructor.CLUB_WIDE_LABEL;
  const lead = (answer) => ({
    id: 1, form_id: '1813864682814937', email: 'p@example.com',
    raw_fields: [{ name: 'program_interest', values: [answer] }],
  });

  const CASES = [
    ['boys',                               'Boys Club (Grades 1–6)'],
    ['Boys (grades 1–6)',                  'Boys Club (Grades 1–6)'],
    ['girls',                              'Girls Club (Grades 1–6)'],
    ['men',                                "Men's Club"],
    ["Men's team (18+)",                   "Men's Club"],
    ['women',                              "Women's Club"],
    ["Women's team (18+)",                 "Women's Club"],
    ['boys_girls',                         'Youth (Grades 1–6)'],
    ['Boys & Girls (more than one child)', 'Youth (Grades 1–6)'],
  ];
  for (const [answer, expected] of CASES) {
    assert.equal(screen.leadFunnelLabel(lead(answer)),            expected, `answer ${answer}`);
    assert.equal(screen.leadFunnelLabel(lead(answer), CLUB_WIDE), expected, `answer ${answer} (column)`);
  }
  // Program-specific forms ignore program_interest entirely.
  assert.equal(screen.leadFunnelLabel({ form_id: '821845431008120', raw_fields: [] }), "Men's Club");
  // Club-wide lead with no answer keeps the column label (and the
  // placeholder link) rather than guessing a club.
  assert.equal(screen.leadFunnelLabel(lead(''), CLUB_WIDE), CLUB_WIDE);
});

test('a club-wide parent close email carries the boys membership link, not the programme list', async () => {
  const { screen } = await linkScreen();
  const lead = {
    id: 7, form_id: '1813864682814937', email: 'p@example.com', first_name: 'Ana',
    raw_fields: [{ name: 'program_interest', values: ['Boys (grades 1–6)'] }],
  };
  const label = screen.leadFunnelLabel(lead, screen.constructor.CLUB_WIDE_LABEL);
  const close = screen.messageSnippets(label).find(s => s.id === 'close');
  assert.ok(close);
  assert.match(close.body, new RegExp(CATEGORY_URLS.boys.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')));
  assert.doesNotMatch(close.body, /leagueapps\.com(\s|$)/);
  assert.doesNotMatch(close.body, /pickup/i);
  assert.match(close.body, /your son/);

  // And the column-level preview for the pooled form must not hand out
  // the programme list either.
  const pooled = screen.funnelContext(screen.constructor.CLUB_WIDE_LABEL).link;
  assert.doesNotMatch(pooled, /leagueapps\.com/);
});
