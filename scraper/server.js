#!/usr/bin/env node
/**
 * scraper/server.js
 *
 * Tiny HTTP server that scrapes Lighthouse APSL schedule/results and
 * loads them into the PostgreSQL DB.
 *
 * Endpoints:
 *   GET  /health    — liveness check
 *   POST /refresh   — run scraper and update DB, returns JSON summary
 */

'use strict';

const http       = require('http');
const puppeteer  = require('puppeteer-core');
const { JSDOM }  = require('jsdom');
const { Client } = require('pg');

// ─── Config ───────────────────────────────────────────────────────────────────
const PORT              = 3010;
const CHROME_PATH       = process.env.PUPPETEER_EXECUTABLE_PATH || '/usr/bin/chromium';
const APSL_TEAM_URL     = 'https://apslsoccer.com/APSL/Team/116079';

const LIGHTHOUSE_1893_ID  = 'd37eb44b-8e47-0005-9060-f0cbe96fe089';
const CREATOR_USER_ID     = '77d77471-1250-47e0-81ab-d4626595d63c';
const MATCH_EVENT_TYPE_ID = '550e8400-e29b-41d4-a716-446655440402';
const SOCCER_SPORT_ID     = '550e8400-e29b-41d4-a716-446655440101';

// APSL season: Sep–Dec = 2025, Jan–Jul = 2026
const MONTH_YEAR = {
  Jan:2026, Feb:2026, Mar:2026, Apr:2026, May:2026, Jun:2026, Jul:2026,
  Aug:2025, Sep:2025, Oct:2025, Nov:2025, Dec:2025,
};
const MONTH_NUM = {
  Jan:1,Feb:2,Mar:3,Apr:4,May:5,Jun:6,Jul:7,Aug:8,Sep:9,Oct:10,Nov:11,Dec:12,
};

// ─── Parsing helpers ──────────────────────────────────────────────────────────
function slugify(s) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
}

// "Sunday, Sep 07 - 4:30 PM" → "2025-09-07 16:30:00"
function parseAPSLDate(s) {
  const m = s.match(/(\w+),\s+(\w{3})\s+(\d+)\s+-\s+(\d+):(\d+)\s+(AM|PM)/);
  if (!m) return null;
  const [,,, mon, day, rawH, rawM, ampm] = m;
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

// ─── APSL scraper ─────────────────────────────────────────────────────────────
async function fetchAPSL() {
  console.log('[scraper] Launching Chromium for APSL...');
  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-gpu',
           '--disable-dev-shm-usage',
           '--proxy-server=socks5://127.0.0.1:40000'],
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
          opponent:   parsed.opponent,
          isHome:     parsed.isHome,
          eventDate,
          venueName:  venueName.replace(/@$/, '').trim(),
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
        'INSERT INTO clubs (name, display_name, slug, is_active) VALUES ($1,$1,$2,true) ON CONFLICT (slug) DO NOTHING',
        [m.opponent, opponentSlug]
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
        AND NOT EXISTS (SELECT 1 FROM teams WHERE name = $1)
      `, [m.opponent, opponentSlug, sdSlug]);

      // Get opponent team id
      const teamRow = await db.query('SELECT id FROM teams WHERE name = $1 LIMIT 1', [m.opponent]);
      if (teamRow.rows.length === 0) continue;
      const opponentId = teamRow.rows[0].id;

      const homeId = m.isHome ? LIGHTHOUSE_1893_ID : opponentId;
      const awayId = m.isHome ? opponentId : LIGHTHOUSE_1893_ID;

      // Build human-readable title
      const title = m.isHome
        ? `Lighthouse 1893 SC vs ${m.opponent}`
        : `${m.opponent} vs Lighthouse 1893 SC`;

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
          VALUES ($1, $2, $3, $4, $5, $6, 'APSL 2025/2026')
        `, [eid, homeId, awayId, m.homeScore, m.awayScore, m.status]);
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
      const matches = await fetchAPSL();
      const { inserted, updated } = await loadToDatabase(matches);
      const finished = new Date().toISOString();
      console.log(`[scraper] Done — inserted ${inserted}, updated ${updated}`);

      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        success:  true,
        message:  `Loaded ${matches.length} APSL matches (${inserted} new, ${updated} updated)`,
        total:    matches.length,
        inserted,
        updated,
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
