#!/usr/bin/env node
// scripts/pyramid-chrome-sync.js — the #apsl pyramid's browser-only tables
// (mig 819, systemd/pyramid-chrome-sync.timer).
//
// Most leagues' tables are read by the backend (PyramidSync) on page open.
// A few sites only build their tables in the browser — Michigan Premier
// (Root Soccer, Next.js) streams its rows in lazy chunks — so this opens
// each active pyramid_sources row of such a system in headless Chrome,
// reads the rendered tables, and hands them to the same writer the backend
// uses, fh_pyramid_load().  A failed read keeps the previous tables and
// stamps last_fetch_ok / last_fetch_note on the source.
//
//   node scripts/pyramid-chrome-sync.js          # every due source
//   node scripts/pyramid-chrome-sync.js --all    # ignore the weekly rule (mig 865)
//   node scripts/pyramid-chrome-sync.js --dry    # print what it read, write nothing

require('dotenv').config({ path: __dirname + '/../env' });
const { Pool } = require('pg');
const puppeteer = require('puppeteer');

const DRY = process.argv.includes('--dry');
const ALL = process.argv.includes('--all') || DRY;
const CHROME = process.env.PYRAMID_CHROME || '/usr/bin/google-chrome';
const BROWSER_SYSTEMS = ['root_soccer'];

const pool = new Pool({
  host:     process.env.PGHOST     || 'localhost',
  port:     parseInt(process.env.PGPORT || '5432', 10),
  database: process.env.PGDATABASE || 'footballhome',
  user:     process.env.PGUSER     || 'footballhome_user',
  password: process.env.PGPASSWORD || 'footballhome_pass',
});

// Root Soccer /standings: a heading, then a table whose head names the
// columns (# Team GP W L T GF GA GD Pts — read by name, not position).
function readRootSoccer() {
  const num = (t) => { const n = parseInt(String(t || '').replace(/[^\d-]/g, ''), 10); return Number.isFinite(n) ? n : 0; };
  const out = [];
  let sort = 0;
  for (const table of document.querySelectorAll('table')) {
    const heads = [...table.querySelectorAll('thead th')].map((th) => th.innerText.trim().toUpperCase());
    const col = (...names) => heads.findIndex((h) => names.includes(h));
    const iTeam = col('TEAM'), iGp = col('GP', 'MP'), iW = col('W'), iD = col('T', 'D'), iL = col('L'),
          iGf = col('GF'), iGa = col('GA'), iPts = col('PTS'), iPos = col('#', 'POS', 'RANK');
    if (iTeam < 0 || iPts < 0) continue;
    // Nearest heading before the table.
    let name = '';
    for (let el = table; el && !name; el = el.parentElement) {
      let sib = el.previousElementSibling;
      while (sib && !name) {
        const h = sib.matches('h1,h2,h3,h4,h5,h6') ? sib : sib.querySelector('h1,h2,h3,h4,h5,h6');
        if (h) name = h.textContent.trim();
        sib = sib.previousElementSibling;
      }
    }
    const teams = [];
    for (const tr of table.querySelectorAll('tbody tr')) {
      const c = [...tr.cells].map((td) => td.innerText.trim());
      const team = c[iTeam];
      if (!team) continue;
      const link = tr.cells[iTeam].querySelector('a[href*="/teams/"]');
      teams.push({ ext_id: link ? link.getAttribute('href').split('/teams/')[1] : team, name: team,
                   pos: iPos >= 0 ? num(c[iPos]) : null, gp: num(c[iGp]), w: num(c[iW]), d: num(c[iD]),
                   l: num(c[iL]), gf: num(c[iGf]), ga: num(c[iGa]), pts: num(c[iPts]) });
    }
    if (name && teams.length) out.push({ ext_id: name, name, sort: ++sort, teams });
  }
  return out;
}

const READERS = { root_soccer: readRootSoccer };

async function main() {
  const { rows: sources } = await pool.query(`
    SELECT id, system, locator FROM pyramid_sources
     WHERE is_active AND system = ANY($1::text[])
       AND ($2::boolean OR fh_pyramid_source_due(id))
     ORDER BY id`, [BROWSER_SYSTEMS, ALL]);
  if (!sources.length) { console.log('[pyramid-chrome] nothing due'); return; }

  const browser = await puppeteer.launch({ executablePath: CHROME, headless: true, args: ['--no-sandbox'] });
  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 2000 });
    for (const src of sources) {
      try {
        await page.goto(src.locator, { waitUntil: 'networkidle2', timeout: 60000 });
        await page.waitForSelector('table tbody tr', { timeout: 30000 });
        const divisions = await page.evaluate(READERS[src.system]);
        const teams = divisions.reduce((a, d) => a + d.teams.length, 0);
        if (DRY) {
          for (const d of divisions) console.log(`  ${d.name} (${d.teams.length}): ${d.teams.map((t) => `${t.pos}.${t.name} ${t.pts}`).join(', ')}`);
          console.log(`[pyramid-chrome] source ${src.id}: ${divisions.length} tables, ${teams} teams (dry)`);
          continue;
        }
        const { rows } = await pool.query('SELECT fh_pyramid_load($1::int, $2::jsonb) AS teams', [src.id, JSON.stringify(divisions)]);
        console.log(`[pyramid-chrome] source ${src.id}: ${divisions.length} tables, ${rows[0].teams} teams`);
      } catch (e) {
        console.error(`[pyramid-chrome] source ${src.id} failed:`, e.message);
        if (!DRY) {
          await pool.query(
            'UPDATE pyramid_sources SET last_fetched_at = now(), last_fetch_ok = false, last_fetch_note = $2 WHERE id = $1',
            [src.id, String(e.message).slice(0, 500)]);
        }
      }
    }
  } finally {
    await browser.close();
  }
}

main()
  .catch((e) => { console.error('[pyramid-chrome] failed:', e); process.exitCode = 1; })
  .finally(() => pool.end());
