#!/usr/bin/env node
/**
 * scraper/server.js
 *
 * Tiny HTTP server that scrapes all 3 Lighthouse team schedules/results and
 * loads them into the PostgreSQL DB.
 *
 *   - Lighthouse 1893 SC      → APSL (Puppeteer, apslsoccer.com)
 *   - Lighthouse Boys Club    → CASA Liga 1 (SportsEngine REST API)
 *   - Lighthouse Old Timers   → CASA Liga 2 (SportsEngine REST API)
 *
 * Endpoints:
 *   GET  /health    — liveness check
 *   POST /refresh   — run all scrapers and update DB, returns JSON summary
 */

'use strict';

const http              = require('http');
const { execSync }      = require('child_process');
const puppeteer         = require('puppeteer-core');
const { JSDOM }         = require('jsdom');
const { Client }        = require('pg');

// ─── Config ───────────────────────────────────────────────────────────────────
const PORT      = 3010;
const CHROME_PATH = process.env.PUPPETEER_EXECUTABLE_PATH || '/usr/bin/chromium';
const APSL_TEAM_URL = 'https://apslsoccer.com/APSL/Team/116079';

// SportsEngine program IDs (CASA league microsites)
const CASA_LIGA1_PROGRAM = '6827a0840b95c8019f7e2b38';
const CASA_LIGA2_PROGRAM = '682f9676528c0e00bfc9d2f2';

const LIGHTHOUSE_1893_ID       = 'd37eb44b-8e47-0005-9060-f0cbe96fe089';
const LIGHTHOUSE_BOYS_ID       = '04b164cd-4e35-4302-84b0-60e2a5e71500';
const LIGHTHOUSE_OLD_TIMERS_ID = '449ef257-2d8f-43c0-8ae1-6374894d17f1';
const CREATOR_USER_ID          = '77d77471-1250-47e0-81ab-d4626595d63c';
const MATCH_EVENT_TYPE_ID      = '550e8400-e29b-41d4-a716-446655440402';
const SOCCER_SPORT_ID          = '550e8400-e29b-41d4-a716-446655440101';

// APSL season: Sep–Dec = 2025, Jan–Jul = 2026
const MONTH_YEAR = {
  Jan:2026, Feb:2026, Mar:2026, Apr:2026, May:2026, Jun:2026, Jul:2026,
  Aug:2025, Sep:2025, Oct:2025, Nov:2025, Dec:2025,
};
const MONTH_NUM = {
  Jan:1,Feb:2,Mar:3,Apr:4,May:5,Jun:6,Jul:7,Aug:8,Sep:9,Oct:10,Nov:11,Dec:12,
};

// SOCKS5 proxy for external HTTP calls
const SOCKS5_PROXY = '127.0.0.1:40000';

// ─── Parsing helpers ──────────────────────────────────────────────────────────
function slugify(s) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
}

// "Sunday, Sep 07 - 4:30 PM" → "2025-09-07 16:30:00"
function parseAPSLDate(s) {
  const m = s.match(/(\w+),\s+(\w{3})\s+(\d+)\s+-\s+(\d+):(\d+)\s+(AM|PM)/);
  if (!m) return null;
  const [,, mon, day, rawH, rawM, ampm] = m;
  let h = parseInt(rawH, 10);
  if (ampm === 'PM' && h !== 12) h += 12;
  if (ampm === 'AM' && h === 12) h = 0;
  const yr = MONTH_YEAR[mon] || 2026;
  const mn = String(MONTH_NUM[mon]).padStart(2, '0');
  const dy = String(parseInt(day, 10)).padStart(2, '0');
  return `${yr}-${mn}-${dy} ${String(h).padStart(2, '0')}:${String(parseInt(rawM, 10)).padStart(2, '0')}:00`;
}

// "Win (2 - 3) (view)" → { status, homeScore, awayScore }
function parseResult(s) {
  const m = s.match(/(Win|Loss|Draw)\s*\((\d+)\s*-\s*(\d+)\)/i);
  if (!m) return { status: 'scheduled', homeScore: null, awayScore: null };
  return { status: 'completed', homeScore: parseInt(m[2], 10), awayScore: parseInt(m[3], 10) };
}

// "vs Philadelphia Soccer Club (8-4-4) (Regular Season)"
// "@ Sewell Old Boys FC (6-2-10) (Regular Season)"
function parseMatchCell(s) {
  const m = s.match(/^(vs|@)\s+(.+?)(?:\s+\(\d+-\d+-\d+\))?\s+\(([^)]+)\)\s*$/);
  if (m) return { isHome: m[1] === 'vs', opponent: m[2].trim() };
  const m2 = s.match(/^(vs|@)\s+(.+?)(?:\s+\(\d+-\d+-\d+\))?(?:\s+\([^)]+\))?$/);
  if (m2) return { isHome: m2[1] === 'vs', opponent: m2[2].trim() };
  return null;
}

// ISO UTC → "YYYY-MM-DD HH:MM:SS" in America/New_York
function utcToEastern(isoStr) {
  const d = new Date(isoStr);
  const fmt = new Intl.DateTimeFormat('en-US', {
    timeZone: 'America/New_York',
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit', second: '2-digit',
    hour12: false,
  });
  const parts = Object.fromEntries(fmt.formatToParts(d).map(p => [p.type, p.value]));
  const h = parts.hour === '24' ? '00' : parts.hour;
  return `${parts.year}-${parts.month}-${parts.day} ${h}:${parts.minute}:${parts.second}`;
}

// ─── APSL scraper (Puppeteer) ─────────────────────────────────────────────────
async function fetchAPSL() {
  console.log('[scraper] Launching Chromium for APSL...');
  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-gpu',
           '--disable-dev-shm-usage',
           `--proxy-server=socks5://${SOCKS5_PROXY}`],
    headless: true,
  });

  try {
    const page = await browser.newPage();
    await page.setUserAgent(
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36'
    );
    await page.goto(APSL_TEAM_URL, { waitUntil: 'networkidle2', timeout: 45000 });
    const html = await page.content();
    await browser.close();

    const doc = new JSDOM(html).window.document;
    const matches = [];

    for (const table of doc.querySelectorAll('table')) {
      const headers = [...table.querySelectorAll('th')].map(th => th.textContent.toLowerCase());
      if (!headers.some(h => h.includes('date'))) continue;

      for (const row of table.querySelectorAll('tbody tr, tr')) {
        const cells = [...row.querySelectorAll('td')].map(td => td.textContent.trim());
        if (cells.length < 3) continue;
        const [dateStr, venueName, matchStr, resultStr = ''] = cells;
        if (!dateStr.match(/\w+,\s+\w{3}/)) continue;

        const eventDate = parseAPSLDate(dateStr);
        if (!eventDate) continue;

        const parsed = parseMatchCell(matchStr);
        if (!parsed) continue;

        const { status, homeScore, awayScore } = parseResult(resultStr);

        matches.push({
          lighthouseTeamId:   LIGHTHOUSE_1893_ID,
          lighthouseTeamName: 'Lighthouse 1893 SC',
          competition:        'APSL 2025/2026',
          opponent:           parsed.opponent,
          isHome:             parsed.isHome,
          eventDate,
          venueName:          venueName.replace(/@$/, '').trim(),
          homeScore,
          awayScore,
          status,
          externalId: `apsl-1893-${slugify(eventDate)}-${slugify(parsed.opponent)}`,
        });
      }
    }

    console.log(`[scraper] APSL: found ${matches.length} matches`);
    return matches;
  } catch (err) {
    await browser.close().catch(() => {});
    throw err;
  }
}

// ─── CASA scraper (SportsEngine REST API via curl+SOCKS5) ─────────────────────
// programId: SE microsite program ID
// apiTeamName: exact team name as it appears in the SE API
// dbTeamId: UUID of this team in our DB
// dbTeamName: display name for titles (may differ from apiTeamName)
// competition: e.g. 'CASA Liga 1 2025/2026'
// prefix: short slug prefix for external IDs e.g. 'casa-boys'
async function fetchCASA(programId, apiTeamName, dbTeamId, dbTeamName, competition, prefix) {
  console.log(`[scraper] Fetching CASA ${competition} (${apiTeamName})...`);

  const url = `https://se-api.sportsengine.com/v3/microsites/events?per_page=200&program_id=${programId}&order_by=starts_at&direction=asc`;
  const curlCmd = `curl -sf --socks5 ${SOCKS5_PROXY} -A "Mozilla/5.0" -H "Accept: application/json" "${url}"`;

  const raw = execSync(curlCmd, { timeout: 30000, encoding: 'utf8', maxBuffer: 20 * 1024 * 1024 });
  const data = JSON.parse(raw);
  const events = data.result || [];

  const matches = [];
  for (const event of events) {
    if (event.event_type !== 'game') continue;
    const gd = event.game_details;
    if (!gd) continue;

    // team_1 is always HOME, team_2 is always AWAY
    const t1Name = gd.team_1.name;
    const t2Name = gd.team_2.name;
    const lighthouseIsT1 = t1Name === apiTeamName;
    const lighthouseIsT2 = t2Name === apiTeamName;
    if (!lighthouseIsT1 && !lighthouseIsT2) continue;

    const isHome     = lighthouseIsT1; // team_1 is always home
    const opponent   = isHome ? t2Name : t1Name;
    const homeScore  = gd.team_1.score !== '' ? parseInt(gd.team_1.score, 10) : null;
    const awayScore  = gd.team_2.score !== '' ? parseInt(gd.team_2.score, 10) : null;
    const status     = gd.status === 'completed' ? 'completed' : 'scheduled';
    const eventDate  = utcToEastern(event.start_date_time);
    const dateSlug   = event.start_date_time.substring(0, 10);

    matches.push({
      lighthouseTeamId:   dbTeamId,
      lighthouseTeamName: dbTeamName,
      competition,
      opponent,
      isHome,
      eventDate,
      venueName: event.location_name || null,
      homeScore,
      awayScore,
      status,
      externalId: `${prefix}-${dateSlug}-${slugify(opponent)}`,
    });
  }

  console.log(`[scraper] ${competition}: found ${matches.length} Lighthouse matches`);
  return matches;
}

// ─── DB load ──────────────────────────────────────────────────────────────────
async function loadToDatabase(matches) {
  const db = new Client({
    host:     process.env.DB_HOST     || 'db',
    port:     parseInt(process.env.DB_PORT || '5432', 10),
    database: process.env.DB_NAME     || 'footballhome',
    user:     process.env.DB_USER     || 'footballhome_user',
    password: process.env.DB_PASSWORD || process.env.POSTGRES_PASSWORD || 'footballhome_pass',
  });
  await db.connect();

  let inserted = 0;
  let updated  = 0;

  try {
    await db.query('BEGIN');

    for (const m of matches) {
      const opponentSlug = slugify(m.opponent);
      const sdSlug       = opponentSlug + '-soccer';

      // Upsert venue
      if (m.venueName) {
        const vExists = await db.query('SELECT 1 FROM venues WHERE name = $1 LIMIT 1', [m.venueName]);
        if (vExists.rows.length === 0) {
          await db.query('INSERT INTO venues (name, venue_type) VALUES ($1, $2)', [m.venueName, 'field']);
        }
      }

      // Upsert opponent club
      await db.query(
        'INSERT INTO clubs (name, display_name, slug, is_active) VALUES ($1,$2,$3,true) ON CONFLICT (slug) DO NOTHING',
        [m.opponent, m.opponent, opponentSlug]
      );

      // Upsert opponent sport_division
      await db.query(`
        INSERT INTO sport_divisions (club_id, sport_id, name, display_name, slug, is_active)
        SELECT c.id, $1, 'Soccer', $2, $3, true
        FROM clubs c WHERE c.slug = $4
        ON CONFLICT (club_id, sport_id, slug) DO NOTHING
      `, [SOCCER_SPORT_ID, m.opponent + ' Soccer', sdSlug, opponentSlug]);

      // Upsert opponent team
      await db.query(`
        INSERT INTO teams (name, division_id, is_active)
        SELECT $1, sd.id, true
        FROM sport_divisions sd JOIN clubs c ON sd.club_id = c.id
        WHERE c.slug = $2 AND sd.slug = $3
        AND NOT EXISTS (SELECT 1 FROM teams WHERE name = $4)
      `, [m.opponent, opponentSlug, sdSlug, m.opponent]);

      // Get opponent team id
      const teamRow = await db.query('SELECT id FROM teams WHERE name = $1 LIMIT 1', [m.opponent]);
      if (teamRow.rows.length === 0) continue;
      const opponentId = teamRow.rows[0].id;

      const homeId = m.isHome ? m.lighthouseTeamId : opponentId;
      const awayId = m.isHome ? opponentId : m.lighthouseTeamId;

      // Build human-readable title
      const title = m.isHome
        ? `${m.lighthouseTeamName} vs ${m.opponent}`
        : `${m.opponent} vs ${m.lighthouseTeamName}`;

      // Get venue id
      let venueId = null;
      if (m.venueName) {
        const vRow = await db.query('SELECT id FROM venues WHERE name = $1 LIMIT 1', [m.venueName]);
        if (vRow.rows.length > 0) venueId = vRow.rows[0].id;
      }

      // Check if event already exists
      const existing = await db.query(
        'SELECT id FROM events WHERE external_event_id = $1',
        [m.externalId]
      );

      if (existing.rows.length === 0) {
        // Insert new event + match
        const { rows } = await db.query(`
          INSERT INTO events (created_by, event_type_id, title, event_date, venue_id, duration_minutes, external_event_id)
          VALUES ($1, $2, $3, $4, $5, 90, $6) RETURNING id
        `, [CREATOR_USER_ID, MATCH_EVENT_TYPE_ID, title, m.eventDate, venueId, m.externalId]);

        const eid = rows[0].id;
        await db.query(`
          INSERT INTO matches (id, home_team_id, away_team_id, home_team_score, away_team_score, match_status, competition_name)
          VALUES ($1, $2, $3, $4, $5, $6, $7)
        `, [eid, homeId, awayId, m.homeScore, m.awayScore, m.status, m.competition]);
        inserted++;
      } else {
        // Update scores/status/venue/title
        const eid = existing.rows[0].id;
        await db.query(
          'UPDATE events SET title = $1, event_date = $2, venue_id = $3 WHERE id = $4',
          [title, m.eventDate, venueId, eid]
        );
        await db.query(
          'UPDATE matches SET home_team_score = $1, away_team_score = $2, match_status = $3 WHERE id = $4',
          [m.homeScore, m.awayScore, m.status, eid]
        );
        updated++;
      }
    }

    await db.query('COMMIT');
  } catch (err) {
    await db.query('ROLLBACK');
    throw err;
  } finally {
    await db.end();
  }

  return { inserted, updated };
}

// ─── HTTP server ──────────────────────────────────────────────────────────────
let refreshRunning = false;

const server = http.createServer(async (req, res) => {
  if (req.method === 'GET' && req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok' }));
    return;
  }

  if (req.method === 'POST' && req.url === '/refresh') {
    if (refreshRunning) {
      res.writeHead(409, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, message: 'Refresh already in progress' }));
      return;
    }

    refreshRunning = true;
    const started = new Date().toISOString();
    console.log(`[scraper] Refresh started at ${started}`);

    try {
      // Run all 3 scrapers; collect results even if some fail
      const results = await Promise.allSettled([
        fetchAPSL(),
        fetchCASA(CASA_LIGA1_PROGRAM, 'Lighthouse Boys Club',
                  LIGHTHOUSE_BOYS_ID, 'Lighthouse Boys Club',
                  'CASA Liga 1 2025/2026', 'casa-boys'),
        fetchCASA(CASA_LIGA2_PROGRAM, 'Lighthouse Boys Club U23',
                  LIGHTHOUSE_OLD_TIMERS_ID, 'Lighthouse Old Timers',
                  'CASA Liga 2 2025/2026', 'casa-ot'),
      ]);

      const errors = [];
      let allMatches = [];
      const labels = ['APSL', 'CASA Liga 1', 'CASA Liga 2'];

      for (let i = 0; i < results.length; i++) {
        if (results[i].status === 'fulfilled') {
          allMatches = allMatches.concat(results[i].value);
        } else {
          console.error(`[scraper] ${labels[i]} failed:`, results[i].reason.message);
          errors.push(`${labels[i]}: ${results[i].reason.message}`);
        }
      }

      const { inserted, updated } = await loadToDatabase(allMatches);
      const finished = new Date().toISOString();
      console.log(`[scraper] Done — ${allMatches.length} total matches, inserted ${inserted}, updated ${updated}`);

      const status = errors.length === 0 ? 200 : 207;
      res.writeHead(status, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        success:  errors.length === 0,
        message:  `Loaded ${allMatches.length} matches (${inserted} new, ${updated} updated)`,
        total:    allMatches.length,
        inserted,
        updated,
        errors:   errors.length > 0 ? errors : undefined,
        started,
        finished,
      }));
    } catch (err) {
      console.error('[scraper] Error:', err.message);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, message: err.message }));
    } finally {
      refreshRunning = false;
    }
    return;
  }

  res.writeHead(404);
  res.end();
});

server.listen(PORT, () => {
  console.log(`[scraper] Listening on port ${PORT}`);
});
