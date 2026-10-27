#!/usr/bin/env node
// scripts/casa-insta-scores.js — read CASA scores off the clubs' Instagram
// pages, on the server, on a schedule (mig 749, systemd/casa-insta-scores.timer).
//
// 1. The played CASA games that still have no score (same rule as
//    #casa-scores, mig 520), from the last 10 days.  None → stop before
//    touching Instagram.
// 2. Each club with a handle (club_social_handles, mig 699; Lighthouse left
//    out): its public profile page in headless Chrome, logged out.  The
//    grid's alt text carries each post's date, so only posts from a game day
//    through 3 days after are opened.
// 3. Each such post not read before: caption + picture to Claude, which says
//    whether it is a final score for one of that club's games.  Every post
//    read is a casa_insta_posts row, so nothing is read (or paid for) twice.
//
// Writes only casa_insta_runs / casa_insta_posts.  SportsEngine stays the
// source of truth; James enters or chases the score from #casa-scores.
//
//   node scripts/casa-insta-scores.js           # the timer's run
//   node scripts/casa-insta-scores.js --dry     # list the clubs it would open, read nothing
//   node scripts/casa-insta-scores.js --test=55 # treat game 55 as unscored (any age); print, write nothing

require('dotenv').config({ path: __dirname + '/../env' });
const { Pool } = require('pg');
const puppeteer = require('puppeteer');
const Anthropic = require('@anthropic-ai/sdk');

const DRY = process.argv.includes('--dry');
const TEST_IDS = (process.argv.find(a => a.startsWith('--test=')) || '').slice(7).split(',').filter(Boolean).map(Number);
const TEST = TEST_IDS.length > 0;
const LIGHTHOUSE_CLUB_ID = 134;          // WelcomeLog::kLighthouseClubId
const LOOKBACK_DAYS = 10;                // games older than this are chased by hand
const POST_WINDOW_DAYS = 3;              // game day … 3 days after
const PAGE_GAP_MS = 5000;                // between page loads — a handful of pages per run
const MODEL = 'claude-opus-5-5';
const CHROME = process.env.CASA_INSTA_CHROME || '/usr/bin/google-chrome';

const pool = new Pool({
  host:     process.env.PGHOST     || 'localhost',
  port:     parseInt(process.env.PGPORT || '5432', 10),
  database: process.env.PGDATABASE || 'footballhome',
  user:     process.env.PGUSER     || 'footballhome_user',
  password: process.env.PGPASSWORD || 'footballhome_pass',
});

const gap = () => new Promise(r => setTimeout(r, PAGE_GAP_MS));
const dayKey = (d) => new Date(d).toLocaleDateString('en-CA', { timeZone: 'America/New_York' });

async function waitingGames() {
  const test = TEST ? 'f.id = ANY($2::int[])' : 'false';
  const { rows } = await pool.query(`
    SELECT f.id, f.division_label, f.home_name, f.away_name, f.home_club_id, f.away_club_id, f.starts_at,
           to_char(f.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD FMHH12:MI AM') AS kickoff,
           hh.handle AS home_ig, ah.handle AS away_ig
      FROM league_fixtures f JOIN league_fixture_sources s ON s.id = f.source_id
      LEFT JOIN club_social_handles hh ON hh.club_id = f.home_club_id AND hh.platform = 'instagram'
      LEFT JOIN club_social_handles ah ON ah.club_id = f.away_club_id AND ah.platform = 'instagram'
     WHERE s.league_label = 'CASA' AND s.is_active AND f.removed_at IS NULL AND s.score_due_after_minutes IS NOT NULL
       AND (${test} OR (f.starts_at + make_interval(mins => s.score_due_after_minutes) < now()
       AND f.starts_at > now() - make_interval(days => $1)
       AND f.status NOT IN ('postponed','cancelled','canceled','forfeit') AND (f.home_score IS NULL OR f.away_score IS NULL)))
       AND ${TEST ? test : 'true'}
     ORDER BY f.starts_at`, TEST ? [LOOKBACK_DAYS, TEST_IDS] : [LOOKBACK_DAYS]);
  return rows;
}

// club_id → { handle, games[] } for every club owing a score, ours left out.
function clubsToCheck(games) {
  const clubs = new Map();
  for (const g of games) {
    for (const [id, handle] of [[g.home_club_id, g.home_ig], [g.away_club_id, g.away_ig]]) {
      if (!id || !handle || id === LIGHTHOUSE_CLUB_ID) continue;
      if (!clubs.has(id)) clubs.set(id, { clubId: id, handle, games: [] });
      clubs.get(id).games.push(g);
    }
  }
  return [...clubs.values()];
}

// The profile grid: post links with the date Instagram writes into each
// picture's alt text ("Photo by X on October 26, 2026. …").
async function gridPosts(page, handle) {
  await page.goto(`https://www.instagram.com/${handle}/`, { waitUntil: 'networkidle2', timeout: 45000 });
  await page.waitForSelector('a[href*="/p/"], a[href*="/reel/"]', { timeout: 15000 }).catch(() => {});
  return page.evaluate(() => {
    if (/Profile isn.t available/.test(document.body.innerText)) return null;
    const out = [];
    for (const a of document.querySelectorAll('a[href*="/p/"], a[href*="/reel/"]')) {
      const img = a.querySelector('img');
      const m = img && (img.alt || '').match(/ on ([A-Z][a-z]+ \d{1,2}, \d{4})/);
      out.push({ url: new URL(a.getAttribute('href'), location.origin).href, date: m ? m[1] : null });
    }
    return out;
  });
}

// One post page: its caption, picture and timestamp.  The picture is the
// post's own full-size image (the biggest "Photo by …" on the page) —
// og:image is a square crop of the top, which cuts off a score graphic's
// bottom half.  A reel has only its cover, og:image is all there is.
async function readPost(page, url) {
  await page.goto(url, { waitUntil: 'networkidle2', timeout: 45000 });
  return page.evaluate(() => {
    const meta = (p) => (document.querySelector(`meta[property="${p}"]`) || {}).content || '';
    const t = document.querySelector('time[datetime]');
    const big = [...document.querySelectorAll('img')].filter(i => /^Photo (by|shared by)/.test(i.alt || ''))
                                                      .sort((a, b) => b.naturalWidth - a.naturalWidth)[0];
    return { image: big ? big.currentSrc || big.src : meta('og:image'), caption: meta('og:description'), postedAt: t ? t.getAttribute('datetime') : null };
  });
}

const SCORE_SCHEMA = {
  type: 'object',
  properties: {
    fixture_id: { type: ['integer', 'null'], description: 'The listed game this post gives the FINAL score of, or null.' },
    home_score: { type: ['integer', 'null'], description: "Goals for the listed game's HOME team." },
    away_score: { type: ['integer', 'null'], description: "Goals for the listed game's AWAY team." },
    confidence: { type: 'string', enum: ['high', 'medium', 'low'] },
    note:       { type: 'string', description: 'One short line: what the post shows.' },
  },
  required: ['fixture_id', 'home_score', 'away_score', 'confidence', 'note'],
  additionalProperties: false,
};

async function askClaude(client, club, post, imageB64, mediaType) {
  const games = club.games.map(g => `#${g.id} · ${g.kickoff} · ${g.division_label} · HOME ${g.home_name} v AWAY ${g.away_name}`).join('\n');
  const content = [];
  if (imageB64) content.push({ type: 'image', source: { type: 'base64', media_type: mediaType, data: imageB64 } });
  content.push({ type: 'text', text:
`This is an Instagram post by @${club.handle}, an amateur soccer club, posted ${post.postedAt || 'recently'}.
Caption: ${post.caption || '(none)'}

The club's games that are still missing a final score:
${games}

Is this post the FINAL score of one of those games? Score graphics often say "Full Time" / "FT" with two numbers; the club's own goals may be shown first even when it was the away team, so put the numbers in the listed game's HOME/AWAY order. Graphics often show crests instead of names: a full-time graphic posted on the game day or the day after, when the club has exactly one listed game in that window, is that game — "medium". A half-time score, a preview, a lineup or a result against a team named and not in the list is not a final score: fixture_id null. Only "high" when the opponent and the score are both plain to read.` });
  const res = await client.messages.create({
    model: MODEL,
    max_tokens: 16000,
    output_config: { effort: 'low', format: { type: 'json_schema', schema: SCORE_SCHEMA } },
    messages: [{ role: 'user', content }],
  });
  if (res.stop_reason === 'refusal') return { fixture_id: null, home_score: null, away_score: null, confidence: 'low', note: 'declined' };
  const text = res.content.find(b => b.type === 'text');
  return JSON.parse(text.text);
}

async function main() {
  const games = await waitingGames();
  const clubs = clubsToCheck(games);
  console.log(`[casa-insta] ${games.length} games waiting, ${clubs.length} clubs with a handle`);
  if (DRY) { for (const c of clubs) console.log(`  @${c.handle}: ${c.games.map(g => '#' + g.id).join(' ')}`); return; }

  // --test: a pretend run — nothing is written, nothing counts as read.
  const db = TEST ? { query: async (sql, args) => /^\s*SELECT/.test(sql) ? pool.query(sql, args) : { rows: [{ id: 0 }] } } : pool;
  const { rows: [run] } = await db.query('INSERT INTO casa_insta_runs (games_waiting) VALUES ($1) RETURNING id', [games.length]);
  if (!clubs.length) { await finish(db, run.id, 0, 0, 0, null); return; }
  const problems = [];
  let checked = 0, read = 0, found = 0;

  const client = new Anthropic();
  const browser = await puppeteer.launch({ executablePath: CHROME, headless: true, args: ['--no-sandbox'] });
  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 2000 });
    const { rows: seenRows } = await db.query('SELECT post_url FROM casa_insta_posts');
    const seen = new Set(seenRows.map(r => r.post_url));

    for (const club of clubs) {
      let posts;
      try { posts = await gridPosts(page, club.handle); checked++; }
      catch (e) { problems.push(`@${club.handle}: ${e.message.split('\n')[0]}`); continue; }
      if (!posts) { problems.push(`@${club.handle} isn't on Instagram any more — fix the handle on 📇 contacts`); await gap(); continue; }
      if (!posts.length) { problems.push(`@${club.handle} showed no posts (login wall?)`); await gap(); continue; }

      // Posts dated within any of this club's game windows.
      const windows = club.games.map(g => { const d = new Date(dayKey(g.starts_at)); return [d, new Date(d.getTime() + POST_WINDOW_DAYS * 864e5)]; });
      const inWindow = (d) => windows.some(([a, b]) => d >= a && d <= b);
      const wanted = posts.filter(p => !seen.has(p.url) && (!p.date || inWindow(new Date(dayKey(p.date)))));
      await gap();

      for (const p of wanted) {
        try {
          const post = await readPost(page, p.url);
          // An undated grid tile that turns out to be outside every window: note it read, ask nothing.
          if (!p.date && post.postedAt && !inWindow(new Date(dayKey(post.postedAt)))) {
            await db.query(`INSERT INTO casa_insta_posts (post_url, club_id, handle, posted_at, caption, note, run_id)
                              VALUES ($1,$2,$3,$4,$5,'outside the game window',$6) ON CONFLICT (post_url) DO NOTHING`,
                             [p.url, club.clubId, club.handle, post.postedAt, post.caption, run.id]);
            await gap(); continue;
          }
          let b64 = null, mediaType = 'image/jpeg';
          if (post.image) {
            const img = await fetch(post.image);
            if (img.ok) { mediaType = (img.headers.get('content-type') || 'image/jpeg').split(';')[0]; b64 = Buffer.from(await img.arrayBuffer()).toString('base64'); }
          }
          const r = await askClaude(client, club, post, b64, mediaType);
          const valid = r.fixture_id && club.games.some(g => g.id === r.fixture_id) && Number.isInteger(r.home_score) && Number.isInteger(r.away_score);
          await db.query(`INSERT INTO casa_insta_posts (post_url, club_id, handle, posted_at, caption, fixture_id, home_score, away_score, confidence, note, run_id)
                            VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11) ON CONFLICT (post_url) DO NOTHING`,
                           [p.url, club.clubId, club.handle, post.postedAt, post.caption,
                            valid ? r.fixture_id : null, valid ? r.home_score : null, valid ? r.away_score : null, r.confidence, r.note, run.id]);
          read++; if (valid) found++;
          console.log(`  @${club.handle} ${p.url} → ${valid ? `#${r.fixture_id} ${r.home_score}-${r.away_score} (${r.confidence})` : '—'} ${r.note}`);
        } catch (e) {
          problems.push(`@${club.handle} ${p.url}: ${e.message.split('\n')[0]}`);
        }
        await gap();
      }
    }
  } finally {
    await browser.close();
  }
  await finish(db, run.id, checked, read, found, problems.length ? problems.join('; ').slice(0, 1000) : null);
}

async function finish(db, runId, checked, read, found, problem) {
  await db.query('UPDATE casa_insta_runs SET finished_at = now(), clubs_checked = $2, posts_read = $3, scores_found = $4, problem = $5 WHERE id = $1',
                   [runId, checked, read, found, problem]);
  console.log(`[casa-insta] run ${runId}: ${checked} clubs, ${read} posts read, ${found} scores found${problem ? ' · ' + problem : ''}`);
}

main()
  .catch((e) => { console.error('[casa-insta] failed:', e); process.exitCode = 1; })
  .finally(() => pool.end());
