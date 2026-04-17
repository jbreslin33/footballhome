#!/usr/bin/env node
/**
 * Fetch specific APSL event pages that are missing from the cache.
 * These are completed matches with no cached event HTML and no scores.
 * 
 * Usage:
 *   node fetch-missing-events.js           # Fetch missing event pages
 *   VPN must be active (APSL blocks direct requests)
 */

const path = require('path');
const HtmlFetcher = require('../infrastructure/fetchers/HtmlFetcher');

const CACHE_DIR = path.join(__dirname, '../../scraped-html/apsl');

// 4 matches with missing scores (from April 8 and April 12, 2026)
const MISSING_EVENTS = [
  { id: '262668', hash: 'C6933A7FA49158E6147EADC716016FA5', desc: 'Apr 08: Lighthouse 1893 SC vs WC Predators' },
  { id: '262671', hash: 'A6EF7135869B9FB9BF327416D824E954', desc: 'Apr 08: Philadelphia Heritage SC vs Oaklyn United FC' },
  { id: '262673', hash: '7EB3068265CAC47C1ED38702B2A43794', desc: 'Apr 12: Oaklyn United FC vs Lighthouse 1893 SC' },
  { id: '262676', hash: 'EAA13CF90AAB938A3075D74133DAA1E3', desc: 'Apr 12: Real Central NJ Soccer vs WC Predators' },
];

async function main() {
  const fetcher = new HtmlFetcher(CACHE_DIR, {
    delayMs: 3000,
    delayJitterMs: 4000,
    cacheFreshnessDays: 0,   // Always fetch fresh
    maxFetchesPerSession: 10
  });

  console.log('🔍 Fetching missing APSL event pages...\n');

  for (const event of MISSING_EVENTS) {
    const url = `https://www.apslsoccer.com/APSL/Event/${event.id}_${event.hash}`;
    console.log(`  📥 ${event.desc}`);
    console.log(`     URL: ${url}`);
    
    try {
      const html = await fetcher.fetch(url, false); // force fresh fetch
      if (html && html.length > 1000) {
        console.log(`     ✓ Fetched ${(html.length / 1024).toFixed(1)} KB\n`);
      } else {
        console.log(`     ⚠️  Small/empty response (${html ? html.length : 0} bytes)\n`);
      }
    } catch (err) {
      console.error(`     ❌ Failed: ${err.message}\n`);
    }
  }

  // Also re-fetch the 4 team pages that should now have updated scores
  console.log('\n🔄 Re-fetching team pages for updated scores...\n');
  const teamPages = [
    { id: '116079', name: 'Lighthouse 1893 SC' },
    { id: '114833', name: 'Oaklyn United FC' },
    { id: '114850', name: 'WC Predators' },
    { id: '114835', name: 'Philadelphia Heritage SC' },
    { id: '114840', name: 'Real Central NJ Soccer' },
  ];

  for (const team of teamPages) {
    const url = `https://www.apslsoccer.com/APSL/Team/${team.id}`;
    console.log(`  📥 ${team.name} (${team.id})`);
    try {
      const html = await fetcher.fetch(url, false);
      if (html && html.length > 1000) {
        console.log(`     ✓ Fetched ${(html.length / 1024).toFixed(1)} KB\n`);
      } else {
        console.log(`     ⚠️  Small/empty response\n`);
      }
    } catch (err) {
      console.error(`     ❌ Failed: ${err.message}\n`);
    }
  }

  await fetcher.closeBrowser();
  console.log('\n✓ Done');
}

main().catch(err => {
  console.error('Fatal:', err);
  process.exit(1);
});
