#!/usr/bin/env node
/**
 * Fetch APSL event pages linked from a team's schedule page.
 *
 * Flow:
 *   1. Re-fetch the team page (to get current season schedule with full event hashes)
 *   2. Extract all Event links: /APSL/Event/{numericId}_{HASH}
 *   3. Fetch each event page via HtmlFetcher (Puppeteer stealth, rate-limited)
 *   4. Files saved to apsl scraped-html cache — ApslMatchEventScraper picks them up next
 *
 * Usage:
 *   node fetch-apsl-team-events.js                     # Lighthouse 1893 SC (default)
 *   node fetch-apsl-team-events.js --team 116079       # Specify team ID
 *   node fetch-apsl-team-events.js --force             # Re-fetch even if recently cached
 *   node fetch-apsl-team-events.js --team 116079 --force
 *
 * Notes:
 *   - APSL blocks direct requests; HtmlFetcher falls back to Puppeteer stealth
 *   - 3-7s polite delay between fetches
 *   - Run ApslMatchEventScraper after this to populate match_events table
 */

const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');
const HtmlFetcher = require('../infrastructure/fetchers/HtmlFetcher');

const CACHE_DIR = path.join(__dirname, '../../scraped-html/apsl');
const DEFAULT_TEAM_ID = '116079'; // Lighthouse 1893 SC

function parseArgs() {
  const args = process.argv.slice(2);
  const result = { teamId: DEFAULT_TEAM_ID, force: false };
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--team' && args[i + 1]) result.teamId = args[++i];
    else if (args[i] === '--force') result.force = true;
  }
  return result;
}

/**
 * Extract /APSL/Event/{numericId}_{HASH} links from team page HTML.
 * Returns array of { numericId, hash, url } objects.
 */
function extractEventLinks(html) {
  const dom = new JSDOM(html);
  const document = dom.window.document;
  const seen = new Set();
  const events = [];

  for (const link of document.querySelectorAll('a[href*="/Event/"]')) {
    const href = link.getAttribute('href') || '';
    const m = href.match(/\/Event\/(\d+)_([A-Fa-f0-9]+)/i);
    if (!m) continue;
    const key = m[1];
    if (seen.has(key)) continue;
    seen.add(key);
    events.push({
      numericId: m[1],
      hash: m[2].toUpperCase(),
      url: `https://www.apslsoccer.com/APSL/Event/${m[1]}_${m[2].toUpperCase()}`
    });
  }

  return events;
}

/**
 * Check if an event page is already cached (either old or new naming convention).
 * Old: apsl-event-{numericId}_{...}.html
 * New: {numericId}-{...}.html  (HtmlFetcher default)
 */
function isEventCached(numericId) {
  const files = fs.readdirSync(CACHE_DIR);
  const oldPat = new RegExp(`^apsl-event-${numericId}_[a-f0-9-]+\\.html$`);
  const newPat = new RegExp(`^${numericId}[_-][a-f0-9-]+\\.html$`);
  return files.some(f => oldPat.test(f) || newPat.test(f));
}

async function main() {
  const { teamId, force } = parseArgs();
  const teamUrl = `https://www.apslsoccer.com/APSL/Team/${teamId}`;

  console.log(`\n⚽ APSL Team Event Fetcher`);
  console.log('='.repeat(60));
  console.log(`   Team ID : ${teamId}`);
  console.log(`   Team URL: ${teamUrl}`);
  console.log(`   Force   : ${force}`);

  const fetcher = new HtmlFetcher(CACHE_DIR, {
    delayMs: 3000,
    delayJitterMs: 4000,
    cacheFreshnessDays: force ? 0 : 1, // Re-fetch team page if >1 day old when --force
    maxFetchesPerSession: 30
  });

  // Step 1: Fetch the team page (fresh to get current season schedule)
  console.log(`\n📥 Fetching team page...`);
  let teamHtml;
  try {
    teamHtml = await fetcher.fetch(teamUrl, !force);
  } catch (err) {
    console.error(`❌ Failed to fetch team page: ${err.message}`);
    process.exit(1);
  }

  if (!teamHtml || teamHtml.length < 1000) {
    console.error(`❌ Team page too small (${teamHtml ? teamHtml.length : 0} bytes) — may be blocked`);
    process.exit(1);
  }

  // Step 2: Extract event links
  const events = extractEventLinks(teamHtml);
  console.log(`\n🔗 Found ${events.length} event links on team page`);

  if (events.length === 0) {
    console.log(`   ⚠️  No event links found. The page may not have rendered schedule data.`);
    await fetcher.closeBrowser();
    return;
  }

  // Step 3: Fetch each event page
  const toFetch = force
    ? events
    : events.filter(e => !isEventCached(e.numericId));

  const alreadyCached = events.length - toFetch.length;
  if (alreadyCached > 0) {
    console.log(`   ✓ Already cached: ${alreadyCached}`);
  }
  console.log(`   📥 To fetch: ${toFetch.length}`);

  let succeeded = 0;
  let failed = 0;

  for (const event of toFetch) {
    console.log(`\n   📥 Event ${event.numericId}`);
    console.log(`      URL: ${event.url}`);
    try {
      const html = await fetcher.fetch(event.url, false); // Always fresh for event pages
      if (html && html.length > 1000) {
        console.log(`      ✓ Fetched ${(html.length / 1024).toFixed(1)} KB`);
        succeeded++;
      } else {
        console.log(`      ⚠️  Small/empty response (${html ? html.length : 0} bytes)`);
        failed++;
      }
    } catch (err) {
      console.error(`      ❌ Failed: ${err.message}`);
      failed++;
    }
  }

  await fetcher.closeBrowser();

  console.log(`\n✅ Done`);
  console.log(`   Succeeded: ${succeeded}`);
  console.log(`   Failed   : ${failed}`);
  console.log(`   Cached   : ${alreadyCached}`);
  console.log(`\n👉 Next: run ApslMatchEventScraper to populate match_events table`);
  console.log(`   cd database/scripts && node scrapers/ApslMatchEventScraper.js`);
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
