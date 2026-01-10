#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const CslMatchEventParser = require('./infrastructure/parsers/CslMatchEventParser');
const ApslMatchEventParser = require('./infrastructure/parsers/ApslMatchEventParser');

/**
 * Comprehensive report on match HTML files and stats
 */
async function generateReport() {
  console.log('📊 MATCH HTML & STATS REPORT');
  console.log('============================================================\n');

  // Analyze CSL
  console.log('🔵 CSL (Colorado Soccer League)');
  console.log('------------------------------------------------------------');
  const cslResults = analyzeLeague('csl', new CslMatchEventParser());
  printLeagueReport(cslResults);

  // Analyze APSL
  console.log('\n🔴 APSL (Adult Premier Soccer League)');
  console.log('------------------------------------------------------------');
  const apslResults = analyzeLeague('apsl', new ApslMatchEventParser());
  printLeagueReport(apslResults);

  // Overall Summary
  console.log('\n📈 OVERALL SUMMARY');
  console.log('============================================================');
  printSummary('CSL', cslResults);
  printSummary('APSL', apslResults);

  // Recommendations
  console.log('\n💡 NEXT STEPS');
  console.log('============================================================');
  if (cslResults.emptyFiles > 0) {
    console.log(`1. Delete ${cslResults.emptyFiles} empty CSL files:`);
    console.log(`   cd database/scraped-html/csl && find . -type f -size 0 -delete`);
  }
  if (apslResults.emptyFiles > 0) {
    console.log(`2. Delete ${apslResults.emptyFiles} empty APSL files:`);
    console.log(`   cd database/scraped-html/apsl && find . -type f -name "apsl-event-*" -size 0 -delete`);
  }
  console.log(`3. Run scrapers to generate SQL files:`);
  console.log(`   ./build.sh --refresh --csl --apsl`);
  console.log();
}

function analyzeLeague(league, parser) {
  const dir = path.join(__dirname, '../scraped-html', league);
  const pattern = league === 'csl' ? /^\d+-.*\.html$/ : /^apsl-event-\d+.*\.html$/;
  
  const files = fs.readdirSync(dir)
    .filter(f => pattern.test(f))
    .sort();

  let totalFiles = 0;
  let emptyFiles = 0;
  let filesWithStats = 0;
  let filesNoStats = 0;
  let totalGoals = 0;
  let totalAssists = 0;
  let totalPlayers = 0;
  const samples = [];

  for (const file of files) {
    totalFiles++;
    const filePath = path.join(dir, file);
    const size = fs.statSync(filePath).size;
    
    if (size === 0) {
      emptyFiles++;
      continue;
    }

    const html = fs.readFileSync(filePath, 'utf8');
    const matchId = league === 'csl' ? file.split('-')[0] : file.match(/apsl-event-(\d+)/)?.[1];
    
    try {
      // Parse with actual parser
      let stats;
      if (league === 'csl') {
        stats = parser.parse(html, 'Home Team', 'Away Team');
      } else {
        stats = parser.parse(html);
      }
      
      const homeStats = stats.homeTeam || [];
      const awayStats = stats.awayTeam || [];
      const allPlayers = [...homeStats, ...awayStats];
      
      const goals = allPlayers.reduce((sum, p) => sum + (p.goals || 0), 0);
      const assists = allPlayers.reduce((sum, p) => sum + (p.assists || 0), 0);
      
      if (goals > 0 || assists > 0 || allPlayers.length > 0) {
        filesWithStats++;
        totalGoals += goals;
        totalAssists += assists;
        totalPlayers += allPlayers.length;
        
        if (samples.length < 5) {
          samples.push({
            matchId,
            goals,
            assists,
            players: allPlayers.length
          });
        }
      } else {
        filesNoStats++;
      }
    } catch (error) {
      filesNoStats++;
    }
  }

  return {
    totalFiles,
    emptyFiles,
    filesWithStats,
    filesNoStats,
    totalGoals,
    totalAssists,
    totalPlayers,
    samples
  };
}

function printLeagueReport(results) {
  console.log(`Total HTML files:           ${results.totalFiles}`);
  console.log(`Empty files:                ${results.emptyFiles}`);
  console.log(`Files with stats:           ${results.filesWithStats} (${pct(results.filesWithStats, results.totalFiles - results.emptyFiles)}%)`);
  console.log(`Files with no stats:        ${results.filesNoStats}`);
  console.log(`\nExtracted Stats:`);
  console.log(`  Total goals:              ${results.totalGoals}`);
  console.log(`  Total assists:            ${results.totalAssists}`);
  console.log(`  Players with stats:       ${results.totalPlayers}`);
  
  if (results.samples.length > 0) {
    console.log(`\nSample matches:`);
    for (const sample of results.samples) {
      console.log(`  ${sample.matchId}: ${sample.goals}G ${sample.assists}A (${sample.players} players)`);
    }
  }
}

function printSummary(league, results) {
  const validFiles = results.totalFiles - results.emptyFiles;
  const coverage = pct(results.filesWithStats, validFiles);
  console.log(`${league}:`);
  console.log(`  Coverage:     ${results.filesWithStats}/${validFiles} matches (${coverage}%)`);
  console.log(`  Goals:        ${results.totalGoals}`);
  console.log(`  Assists:      ${results.totalAssists}`);
  console.log(`  Players:      ${results.totalPlayers}`);
}

function pct(num, total) {
  return total === 0 ? 0 : Math.round((num / total) * 100);
}

// Run
generateReport().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
