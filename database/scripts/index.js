#!/usr/bin/env node

/**
 * Unified Scraper CLI
 * Main entry point for all OOP scrapers
 */

require('dotenv').config({ path: require('path').resolve(__dirname, '../../env') });

// Force disable SSL verification for development environment
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const ApslScraper = require('./scrapers/ApslScraper');
const CasaScraper = require('./scrapers/CasaScraper');
const TrainingLighthouseScraper = require('./scrapers/TrainingLighthouseScraper');
const BoysClubLiga1Scraper = require('./scrapers/BoysClubLiga1Scraper');
const OldTimersLiga2Scraper = require('./scrapers/OldTimersLiga2Scraper');
const ApslLighthouseScraper = require('./scrapers/ApslLighthouseScraper');
const VenueScraper = require('./scrapers/VenueScraper');
const { getScrapeTargets } = require('./utils/database');

// Parse command line arguments
const args = process.argv.slice(2);

// Check for new database-driven flags
const fetchMode = args.includes('--fetch');
const parseMode = args.includes('--parse');

// Check for aggregate flags (legacy support)
const runApsl = args.includes('--apsl');
const runCasa = args.includes('--casa');
const runGroupMe = args.includes('--groupme');

// If no aggregate flags, look for specific scraper argument
const scraper = (!runApsl && !runCasa && !runGroupMe) ? args[0] : null;
const mode = args[1] && !args[1].startsWith('--') ? args[1] : 'full';
const includeSchedules = args.includes('--schedules');

// Extract --team parameter
const teamIndex = args.indexOf('--team');
const teamFilter = teamIndex >= 0 && args[teamIndex + 1] ? args[teamIndex + 1] : null;

// Extract --force-refresh parameter (bypass cache)
const forceRefresh = args.includes('--force-refresh');

// Extract --discover flag (discovery mode: structure only, no DB writes)
const discover = args.includes('--discover');

// Extract --location parameter (lat,lng)
const locationIndex = args.indexOf('--location');
const location = locationIndex >= 0 && args[locationIndex + 1] 
  ? (() => {
      const [lat, lng] = args[locationIndex + 1].split(',').map(parseFloat);
      return { lat, lng };
    })()
  : null;

// Extract --radius parameter (meters)
const radiusIndex = args.indexOf('--radius');
const radius = radiusIndex >= 0 && args[radiusIndex + 1] ? parseInt(args[radiusIndex + 1]) : null;

/**
 * Fetch HTML from live websites for all targets
 */
async function fetchTargets(targets) {
  const PuppeteerFetcher = require('./fetchers/PuppeteerFetcher');
  const CacheManager = require('./services/CacheManager');
  const path = require('path');
  
  const fetcher = new PuppeteerFetcher({ timeout: 30000 });
  
  let successCount = 0;
  let failCount = 0;
  
  for (const target of targets) {
    try {
      // Determine cache directory based on source system
      const sourceDir = target.source_system_name ? target.source_system_name.toLowerCase() : 'reference';
      const cacheDir = path.join(__dirname, '../scraped-html', sourceDir);
      const cache = new CacheManager(cacheDir, fetcher, 24);
      
      // Generate filename from URL
      const urlObj = new URL(target.url);
      const filename = `${target.target_type}-${urlObj.pathname.replace(/\//g, '_').replace(/^_/, '')}-${urlObj.search.replace(/\?/, '').replace(/[&=]/g, '_')}.html`;
      
      console.log(`📥 Fetching: ${target.description}`);
      console.log(`   URL: ${target.url}`);
      console.log(`   Cache: ${filename}`);
      
      // Fetch with force refresh (forceRefresh=true)
      const html = await cache.fetch(target.url, true);
      
      console.log(`   ✅ Downloaded ${(html.length / 1024).toFixed(1)} KB\n`);
      successCount++;
      
    } catch (error) {
      console.error(`   ❌ Failed: ${error.message}\n`);
      failCount++;
    }
  }
  
  await fetcher.close();
  
  console.log(`\n📊 Fetch Summary: ${successCount} succeeded, ${failCount} failed`);
}

/**
 * Parse cached HTML and generate SQL files
 */
async function parseTargets(targets) {
  const ApslHtmlParser = require('./parsers/ApslHtmlParser');
  const SqlGenerator = require('./services/SqlGenerator');
  const path = require('path');
  const fs = require('fs').promises;
  
  const sqlGenerator = new SqlGenerator();
  
  // Group targets by source system
  const targetsBySource = targets.reduce((acc, target) => {
    const source = target.source_system_name || 'reference';
    if (!acc[source]) acc[source] = [];
    acc[source].push(target);
    return acc;
  }, {});
  
  // Process each source system
  for (const [sourceName, sourceTargets] of Object.entries(targetsBySource)) {
    console.log(`\n📊 Processing ${sourceName.toUpperCase()} (${sourceTargets.length} targets)`);
    
    if (sourceName === 'apsl') {
      await parseApslTargets(sourceTargets, sqlGenerator);
    } else if (sourceName === 'casa') {
      await parseCasaTargets(sourceTargets, sqlGenerator);
    } else {
      console.log(`   ⚠️  No parser implemented for ${sourceName} yet`);
    }
  }
}

/**
 * Parse APSL targets (standings page contains all data)
 */
async function parseApslTargets(targets, sqlGenerator) {
  const ApslHtmlParser = require('./parsers/ApslHtmlParser');
  const path = require('path');
  const fs = require('fs').promises;
  
  const parser = new ApslHtmlParser();
  const cacheDir = path.join(__dirname, '../scraped-html/apsl');
  
  // APSL only has one target: the standings page
  const standingsTarget = targets.find(t => t.target_type === 'league_structure');
  if (!standingsTarget) {
    console.log('   ⚠️  No league_structure target found for APSL');
    return;
  }
  
  try {
    // Find the cached HTML file (look for standings*.html)
    const files = await fs.readdir(cacheDir);
    const htmlFile = files.find(f => f.startsWith('standings') && f.endsWith('.html'));
    
    if (!htmlFile) {
      console.log('   ❌ No cached HTML found. Run with --fetch first.');
      return;
    }
    
    const htmlPath = path.join(cacheDir, htmlFile);
    const html = await fs.readFile(htmlPath, 'utf-8');
    
    console.log(`   📄 Parsing: ${htmlFile}`);
    
    // Parse HTML into DOM
    parser.parse(html);
    
    // Extract structure
    const conferences = parser.parseStandingsStructure();
    
    if (!conferences || conferences.length === 0) {
      console.log(`   ⚠️  No conferences found in HTML`);
      return;
    }
    
    console.log(`   ✅ Parsed ${conferences.length} conferences`);
    
    // Generate SQL for conferences, divisions, and teams
    await generateApslSql(conferences, parser);
    
  } catch (error) {
    console.error(`   ❌ Parse error: ${error.message}`);
    console.error(error.stack);
  }
}

/**
 * Generate SQL files for APSL scraped data
 */
async function generateApslSql(conferences, parser) {
  const path = require('path');
  const fs = require('fs').promises;
  
  const dataDir = path.join(__dirname, '../data');
  const leagueId = 1; // APSL league ID from 016-leagues.sql
  
  // Maps to track conference IDs (match existing manual SQL IDs 1-8)
  const conferenceMap = {
    'Mayflower Conference': 1,
    'Constitution Conference': 2,
    'Metropolitan Conference': 3,
    'Delaware River Conference': 4,
    'Mid-Atlantic Conference': 5,
    'Terminus Conference': 6,
    'Pine Tree Conference': 7,
    'Trinity Conference': 8
  };
  
  // Division IDs (match existing manual SQL IDs 1-8)
  const divisionMap = {
    1: 1, // Mayflower -> Division 1
    2: 2, // Constitution -> Division 2
    3: 3, // Metropolitan -> Division 3
    4: 4, // Delaware River -> Division 4
    5: 5, // Mid-Atlantic -> Division 5
    6: 6, // Terminus -> Division 6
    7: 7, // Pine Tree -> Division 7
    8: 8  // Trinity -> Division 8
  };
  
  const teams = [];
  let teamIdCounter = 1000; // Start team IDs at 1000 to avoid conflicts
  
  // Process each conference
  for (const conf of conferences) {
    const conferenceId = conferenceMap[conf.name];
    if (!conferenceId) {
      console.log(`   ⚠️  Unknown conference: ${conf.name}`);
      continue;
    }
    
    const divisionId = divisionMap[conferenceId];
    
    // Parse standings table to get teams
    const standings = parser.parseStandingsTable(conf.table);
    
    console.log(`      • ${conf.name}: ${standings.length} teams`);
    
    // Generate team records
    for (const standing of standings) {
      teams.push({
        id: teamIdCounter++,
        division_id: divisionId,
        name: standing.team,
        // Store standings stats (will need separate team_stats table in future)
        notes: `GP:${standing.gp} W:${standing.w} T:${standing.t} L:${standing.l} GF:${standing.gf} GA:${standing.ga} Pts:${standing.pts}`
      });
    }
  }
  
  // Generate teams SQL file
  if (teams.length > 0) {
    const lines = [];
    lines.push('-- APSL Teams (Scraped Data)');
    lines.push('-- Generated by database-driven scraper from apslsoccer.com');
    lines.push('-- This file is regenerated on each scrape - do not edit manually');
    lines.push('');
    lines.push('-- Insert teams');
    lines.push('INSERT INTO teams (id, name, source_system_id) VALUES');
    
    const teamValueLines = teams.map((team, idx) => {
      const isLast = idx === teams.length - 1;
      return `  (${team.id}, '${team.name.replace(/'/g, "''")}', 1)${isLast ? '' : ','}`;
    });
    
    lines.push(...teamValueLines);
    lines.push('ON CONFLICT (id) DO UPDATE SET');
    lines.push('  name = EXCLUDED.name,');
    lines.push('  source_system_id = EXCLUDED.source_system_id;');
    lines.push('');
    
    // Insert team-division associations
    lines.push('-- Link teams to divisions');
    lines.push('INSERT INTO team_divisions (team_id, division_id, is_active) VALUES');
    
    const divisionValueLines = teams.map((team, idx) => {
      const isLast = idx === teams.length - 1;
      return `  (${team.id}, ${team.division_id}, true)${isLast ? '' : ','}`;
    });
    
    lines.push(...divisionValueLines);
    lines.push('ON CONFLICT (team_id, division_id) DO UPDATE SET');
    lines.push('  is_active = EXCLUDED.is_active;');
    lines.push('');
    
    // TODO: Store standings stats in a separate team_stats table
    lines.push('-- TODO: Store standings stats (GP, W, T, L, GF, GA, Pts) in team_stats table');
    lines.push('');
    
    const sqlPath = path.join(dataDir, '028-apsl-teams-scraped.sql');
    await fs.writeFile(sqlPath, lines.join('\n'), 'utf-8');
    
    console.log(`   ✅ Generated SQL: 028-apsl-teams-scraped.sql (${teams.length} teams)`);
  }
}

/**
 * Parse CASA targets (rosters, schedules, standings)
 */
async function parseCasaTargets(targets, sqlGenerator) {
  const path = require('path');
  const fs = require('fs').promises;
  
  const cacheDir = path.join(__dirname, '../scraped-html/casa');
  
  console.log(`   ⚠️  CASA parser not yet implemented`);
  console.log(`   TODO: Parse ${targets.length} targets (rosters, schedules, standings)`);
  
  // Check cached files
  try {
    const files = await fs.readdir(cacheDir);
    const htmlFiles = files.filter(f => f.endsWith('.html'));
    console.log(`   💾 Found ${htmlFiles.length} cached HTML files`);
  } catch (error) {
    console.log(`   ⚠️  No cache directory found`);
  }
}

async function main() {
  try {
    // NEW DATABASE-DRIVEN MODE
    if (fetchMode || parseMode) {
      console.log('\n🎯 Database-driven mode');
      console.log('📋 Reading scrape targets from database...\n');
      
      try {
        const targets = await getScrapeTargets();
        
        if (targets.length === 0) {
          console.log('⚠️  No active scrape targets found in database');
          console.log('    Check: database/data/005-scrape-targets.sql');
          process.exit(1);
        }
        
        console.log(`Found ${targets.length} active scrape targets`);
        
        if (fetchMode) {
          console.log('\n📥 FETCH MODE: Downloading HTML from live websites...\n');
          await fetchTargets(targets);
        }
        
        if (parseMode) {
          console.log('\n📊 PARSE MODE: Parsing cached HTML and generating SQL...\n');
          await parseTargets(targets);
        }
        
        console.log('\n✨ Database-driven scraping completed successfully.');
        
      } catch (error) {
        console.error(`\n❌ Database error: ${error.message}`);
        console.error('    Make sure database is running: ./dev.sh');
        process.exit(1);
      }
      
      process.exit(0);
    }

    // LEGACY HARDCODED MODE
    const scrapersToRun = [];

    // 1. Aggregate Flags
    if (runApsl) {
      // Always include schedules for APSL to enable per-match player stats
      scrapersToRun.push(new ApslScraper(mode, { includeSchedules: true, teamFilter, forceRefresh, discover }));
    }

    if (runCasa) {
      scrapersToRun.push(new CasaScraper(mode, { includeSchedules, teamFilter, forceRefresh, discover }));
    }

    if (runGroupMe) {
      scrapersToRun.push(new TrainingLighthouseScraper(mode, { includeSchedules }));
      scrapersToRun.push(new BoysClubLiga1Scraper(mode, { includeSchedules }));
      scrapersToRun.push(new OldTimersLiga2Scraper(mode, { includeSchedules }));
      scrapersToRun.push(new ApslLighthouseScraper(mode, { includeSchedules }));
    }

    // 2. Specific Scraper (if no aggregate flags)
    if (scrapersToRun.length === 0 && scraper) {
      switch (scraper) {
        case 'apsl':
          scrapersToRun.push(new ApslScraper(mode, { includeSchedules, teamFilter, forceRefresh, discover }));
          break;
          
        case 'casa':
          scrapersToRun.push(new CasaScraper(mode, { includeSchedules, teamFilter, forceRefresh, discover }));
          break;
          
        case 'groupme-training':
          scrapersToRun.push(new TrainingLighthouseScraper(mode, { includeSchedules }));
          break;
          
        case 'groupme-boys-club':
          scrapersToRun.push(new BoysClubLiga1Scraper(mode, { includeSchedules }));
          break;
          
        case 'groupme-old-timers':
          scrapersToRun.push(new OldTimersLiga2Scraper(mode, { includeSchedules }));
          break;
          
        case 'groupme-apsl':
          scrapersToRun.push(new ApslLighthouseScraper(mode, { includeSchedules }));
          break;
          
        case 'venues':
          scrapersToRun.push(new VenueScraper(mode, { location, radius }));
          break;
          
        default:
          console.error(`Unknown scraper: ${scraper}`);
          printUsage();
          process.exit(1);
      }
    }

    if (scrapersToRun.length === 0) {
      printUsage();
      process.exit(1);
    }

    // Run all selected scrapers sequentially
    console.log(`\n🚀 Starting ${scrapersToRun.length} scraper(s)...\n`);
    
    for (const instance of scrapersToRun) {
      await instance.scrape();
      console.log('\n----------------------------------------\n');
    }
    
    console.log('✨ All tasks completed successfully.');
    
    // Explicitly exit after successful scrape (Puppeteer can keep event loop alive)
    process.exit(0);
    
  } catch (error) {
    console.error('\n❌ Fatal error:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

function printUsage() {
  console.log('\nUsage: node index.js [scraper] [mode] [options]');
  console.log('       node index.js --fetch              # Database-driven: fetch HTML (not yet implemented)');
  console.log('       node index.js --parse              # Database-driven: parse HTML (not yet implemented)');
  console.log('       node index.js --apsl [mode]        # Legacy: hardcoded APSL');
  console.log('       node index.js --casa [mode]        # Legacy: hardcoded CASA');
  console.log('\nScrapers (Legacy):');
  console.log('  apsl                - APSL Soccer League');
  console.log('  casa                - CASA Soccer League');
  console.log('  groupme-training    - Training Lighthouse chat');
  console.log('  groupme-boys-club   - Lighthouse Boys Club Liga 1 chat');
  console.log('  groupme-old-timers  - Lighthouse Old Timers Liga 2 chat');
  console.log('  groupme-apsl        - APSL Lighthouse chat');
  console.log('  venues              - Google Places venues');
  console.log('\nAggregate Flags (Legacy):');
  console.log('  --apsl              - Run APSL scraper');
  console.log('  --casa              - Run CASA scraper');
  console.log('  --groupme           - Run all GroupMe scrapers');
  console.log('\nModes:');
  console.log('  structure - League structure only');
  console.log('  teams     - Structure + teams');
  console.log('  players   - Structure + teams + rosters');
  console.log('  full      - Everything (default)');
  console.log('\nOptions:');
  console.log('  --schedules              Include match schedules');
  console.log('  --team <name>            Filter to teams matching name (e.g., "Lighthouse", "United")');
  console.log('  --location <lat,lng>     Search location for venues (e.g., "39.9526,-75.1652")');
  console.log('  --radius <meters>        Search radius for venues (default: 50000)');
}

main();
