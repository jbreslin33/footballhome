#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');

/**
 * Analyze match HTML files to see which have actual player stats
 */
async function analyzeMatchHtml() {
  console.log('📊 Match HTML Content Analysis Report');
  console.log('============================================================\n');

  // Analyze CSL
  console.log('🔵 CSL (Colorado Soccer League)');
  console.log('------------------------------------------------------------');
  const cslResults = await analyzeLeague('csl', parseCslMatch);
  printLeagueResults(cslResults);

  console.log('\n🔴 APSL (Adult Premier Soccer League)');
  console.log('------------------------------------------------------------');
  const apslResults = await analyzeLeague('apsl', parseApslMatch);
  printLeagueResults(apslResults);

  // Summary
  console.log('\n📈 SUMMARY');
  console.log('============================================================');
  console.log('CSL:');
  console.log(`  Matches with stats:    ${cslResults.withStats} / ${cslResults.total} (${pct(cslResults.withStats, cslResults.total)}%)`);
  console.log(`  Empty files:           ${cslResults.empty}`);
  console.log(`  No stats found:        ${cslResults.noStats}`);
  console.log('\nAPSL:');
  console.log(`  Matches with stats:    ${apslResults.withStats} / ${apslResults.total} (${pct(apslResults.withStats, apslResults.total)}%)`);
  console.log(`  Empty files:           ${apslResults.empty}`);
  console.log(`  No stats found:        ${apslResults.noStats}`);

  console.log('\n💡 RECOMMENDATIONS:');
  console.log('------------------------------------------------------------');
  if (cslResults.empty > 0) {
    console.log(`❌ CSL: Delete ${cslResults.empty} empty HTML files and re-download`);
  }
  if (apslResults.empty > 0) {
    console.log(`❌ APSL: Delete ${apslResults.empty} empty HTML files and re-download`);
  }
  if (cslResults.noStats > 0) {
    console.log(`⚠️  CSL: ${cslResults.noStats} matches have HTML but no player stats`);
  }
  if (apslResults.noStats > 0) {
    console.log(`⚠️  APSL: ${apslResults.noStats} matches have HTML but no player stats`);
  }
  console.log('✅ Run scrapers to generate SQL files from HTML with stats\n');
}

async function analyzeLeague(league, parseFunction) {
  const dir = path.join(__dirname, '../scraped-html', league);
  const pattern = league === 'csl' ? /^\d+-.*\.html$/ : /^apsl-event-\d+.*\.html$/;
  
  const files = fs.readdirSync(dir)
    .filter(f => pattern.test(f))
    .sort();

  let total = 0;
  let empty = 0;
  let withStats = 0;
  let noStats = 0;
  const samples = [];

  for (const file of files) {
    total++;
    const filePath = path.join(dir, file);
    const size = fs.statSync(filePath).size;
    
    if (size === 0) {
      empty++;
      continue;
    }

    const content = fs.readFileSync(filePath, 'utf8');
    const stats = parseFunction(content, file);

    if (stats.goals > 0 || stats.assists > 0 || stats.yellows > 0 || stats.reds > 0) {
      withStats++;
      if (samples.length < 5) {
        samples.push({ file, ...stats });
      }
    } else {
      noStats++;
    }
  }

  return { total, empty, withStats, noStats, samples };
}

function parseCslMatch(html, filename) {
  const dom = new JSDOM(html);
  const doc = dom.window.document;

  // CSL uses tables with "Goals" and "Assists" headers
  let goals = 0;
  let assists = 0;
  let yellows = 0;
  let reds = 0;

  // Count goal entries
  const tables = doc.querySelectorAll('table');
  for (const table of tables) {
    const text = table.textContent || '';
    if (text.includes('Goals')) {
      // Count rows in goals section
      const rows = table.querySelectorAll('tr');
      for (const row of rows) {
        const rowText = row.textContent || '';
        if (rowText.match(/\d+'/)) { // Match minute markers like "45'"
          goals++;
        }
      }
    }
    if (text.includes('Assists')) {
      const rows = table.querySelectorAll('tr');
      for (const row of rows) {
        const rowText = row.textContent || '';
        if (rowText.match(/\d+'/)) {
          assists++;
        }
      }
    }
    if (text.includes('Yellow')) yellows++;
    if (text.includes('Red')) reds++;
  }

  const matchId = filename.split('-')[0];
  return { matchId, goals, assists, yellows, reds };
}

function parseApslMatch(html, filename) {
  const dom = new JSDOM(html);
  const doc = dom.window.document;

  let goals = 0;
  let assists = 0;
  let yellows = 0;
  let reds = 0;

  // APSL shows events in a timeline-style list
  const events = doc.querySelectorAll('.event-item, .timeline-event, tr');
  for (const event of events) {
    const text = (event.textContent || '').toLowerCase();
    if (text.includes('goal')) goals++;
    if (text.includes('assist')) assists++;
    if (text.includes('yellow')) yellows++;
    if (text.includes('red card')) reds++;
  }

  const matchId = filename.match(/apsl-event-(\d+)/)?.[1] || 'unknown';
  return { matchId, goals, assists, yellows, reds };
}

function printLeagueResults(results) {
  console.log(`Total HTML files:       ${results.total}`);
  console.log(`Empty files:            ${results.empty}`);
  console.log(`Files with stats:       ${results.withStats}`);
  console.log(`Files with no stats:    ${results.noStats}`);
  
  if (results.samples.length > 0) {
    console.log('\nSample matches with stats:');
    for (const sample of results.samples) {
      console.log(`  ${sample.matchId}: ${sample.goals}G ${sample.assists}A ${sample.yellows}Y ${sample.reds}R`);
    }
  }
}

function pct(num, total) {
  return total === 0 ? 0 : Math.round((num / total) * 100);
}

// Run
analyzeMatchHtml().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
