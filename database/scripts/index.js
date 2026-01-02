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
  const PuppeteerFetcher = require('./fetchers/PuppeteerFetcher');
  const CacheManager = require('./services/CacheManager');
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
    
    // Extract team links from standings page
    const teamLinks = parser.parseTeamLinks();
    console.log(`   📋 Found ${teamLinks.length} team links to fetch`);
    
    // Fetch and parse each team's roster and schedule
    const fetcher = new PuppeteerFetcher({ timeout: 30000 });
    const cache = new CacheManager(cacheDir, fetcher, 24);
    const allPlayers = [];
    const allMatches = [];
    
    for (let i = 0; i < teamLinks.length; i++) {
      const team = teamLinks[i];
      console.log(`   [${i + 1}/${teamLinks.length}] ${team.name}...`);
      
      try {
        // Fetch roster page
        const rosterUrl = `https://apslsoccer.com${team.url}`;
        const rosterHtml = await cache.fetch(rosterUrl, false); // Use cache if available
        
        // Parse roster
        const rosterParser = new ApslHtmlParser();
        rosterParser.parse(rosterHtml);
        const playerStats = rosterParser.parsePlayerStats();
        
        // Add team context to players
        playerStats.forEach(p => {
          p.team_name = team.name;
          p.apsl_team_id = team.apsl_team_id;
        });
        
        allPlayers.push(...playerStats);
        
      } catch (error) {
        console.log(`      ⚠️  Failed to fetch roster: ${error.message}`);
      }
    }
    
    await fetcher.close();
    
    console.log(`   ✅ Collected ${allPlayers.length} players from ${teamLinks.length} teams`);
    
    // Generate SQL for teams, players, and matches
    await generateApslSql(conferences, parser, allPlayers, allMatches);
    
  } catch (error) {
    console.error(`   ❌ Parse error: ${error.message}`);
    console.error(error.stack);
  }
}

/**
 * Generate SQL files for APSL scraped data
 */
async function generateApslSql(conferences, parser, allPlayers, allMatches) {
  const path = require('path');
  const fs = require('fs').promises;
  const crypto = require('crypto');
  
  const dataDir = path.join(__dirname, '../data');
  
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
    1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8
  };
  
  const teams = [];
  const teamNameToApslId = new Map(); // Map team names to APSL external IDs
  
  // Extract team links to get APSL team IDs
  const teamLinks = parser.parseTeamLinks();
  teamLinks.forEach(link => {
    teamNameToApslId.set(link.name, link.apsl_team_id);
  });
  
  // Process each conference to build teams list
  for (const conf of conferences) {
    const conferenceId = conferenceMap[conf.name];
    if (!conferenceId) {
      console.log(`   ⚠️  Unknown conference: ${conf.name}`);
      continue;
    }
    
    const divisionId = divisionMap[conferenceId];
    const standings = parser.parseStandingsTable(conf.table);
    
    console.log(`      • ${conf.name}: ${standings.length} teams`);
    
    for (const standing of standings) {
      const apslTeamId = teamNameToApslId.get(standing.team);
      if (!apslTeamId) {
        console.log(`   ⚠️  No APSL team ID found for: ${standing.team}`);
        continue;
      }
      
      teams.push({
        name: standing.team,
        division_id: divisionId,
        external_id: apslTeamId,  // Just the APSL ID (e.g., "114814")
        notes: `GP:${standing.gp} W:${standing.w} T:${standing.t} L:${standing.l} GF:${standing.gf} GA:${standing.ga} Pts:${standing.pts}`
      });
    }
  }
  
  // Generate teams SQL file using CTEs with RETURNING
  if (teams.length > 0) {
    const lines = [];
    lines.push('-- APSL Teams (Scraped Data)');
    lines.push('-- Generated by database-driven scraper from apslsoccer.com');
    lines.push('-- Uses CTEs with RETURNING to get auto-generated IDs');
    lines.push('-- external_id stored in team_divisions (source-specific relationship)');
    lines.push('');
    
    lines.push('WITH inserted_teams AS (');
    lines.push('  INSERT INTO teams (name) VALUES');
    
    const teamValueLines = teams.map((team, idx) => {
      const isLast = idx === teams.length - 1;
      return `    ('${team.name.replace(/'/g, "''")}')${isLast ? '' : ','}`;
    });
    
    lines.push(...teamValueLines);
    lines.push('  RETURNING id, name');
    lines.push(')');
    lines.push('INSERT INTO team_divisions (team_id, division_id, source_system_id, external_id, is_active)');
    lines.push('SELECT');
    lines.push('  it.id,');
    lines.push('  CASE it.name');
    
    teams.forEach(team => {
      lines.push(`    WHEN '${team.name.replace(/'/g, "''")}' THEN ${team.division_id}`);
    });
    
    lines.push('  END,');
    lines.push('  1,  -- source_system_id (APSL)');
    lines.push('  CASE it.name');
    
    teams.forEach(team => {
      lines.push(`    WHEN '${team.name.replace(/'/g, "''")}' THEN '${team.external_id}'`);
    });
    
    lines.push('  END,');
    lines.push('  true');
    lines.push('FROM inserted_teams it');
    lines.push('ON CONFLICT (team_id, division_id) DO UPDATE SET');
    lines.push('  external_id = EXCLUDED.external_id,');
    lines.push('  is_active = EXCLUDED.is_active;');
    lines.push('');
    lines.push('-- TODO: Store standings stats (GP, W, T, L, GF, GA, Pts) in team_stats table');
    lines.push('');
    
    const sqlPath = path.join(dataDir, '028-apsl-teams-scraped.sql');
    await fs.writeFile(sqlPath, lines.join('\n'), 'utf-8');
    
    console.log(`   ✅ Generated SQL: 028-apsl-teams-scraped.sql (${teams.length} teams)`);
  }
  
  // Generate players SQL file using CTEs with RETURNING
  if (allPlayers.length > 0) {
    const lines = [];
    lines.push('-- APSL Players (Scraped Data)');
    lines.push('-- Generated by database-driven scraper from apslsoccer.com');
    lines.push('-- Uses CTEs with RETURNING to get auto-generated IDs');
    lines.push('-- external_id on players tracks source-specific player identity');
    lines.push('');
    
    // Helper function to normalize name for external_id
    const normalizeForExternalId = (name) => {
      return name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
    };
    
    // Group players by team for efficient SQL generation
    const playersByTeam = {};
    for (const player of allPlayers) {
      if (!playersByTeam[player.team_name]) {
        playersByTeam[player.team_name] = [];
      }
      
      // Split name into first/last
      const nameParts = player.name.trim().split(' ');
      const firstName = nameParts.slice(0, -1).join(' ') || nameParts[0];
      const lastName = nameParts[nameParts.length - 1];
      
      const apslTeamId = teamNameToApslId.get(player.team_name);
      const normalizedName = normalizeForExternalId(player.name);
      
      playersByTeam[player.team_name].push({
        firstName: firstName.replace(/'/g, "''"),
        lastName: lastName.replace(/'/g, "''"),
        externalId: `${apslTeamId}-${normalizedName}`,  // e.g., "114814-john-smith"
        teamName: player.team_name.replace(/'/g, "''"),
        goals: player.goals || 0,
        assists: player.assists || 0
      });
    }
    
    const allPlayerRecords = Object.values(playersByTeam).flat();
    
    if (allPlayerRecords.length > 0) {
      lines.push('WITH inserted_persons AS (');
      lines.push('  INSERT INTO persons (first_name, last_name) VALUES');
      
      const personLines = allPlayerRecords.map((p, idx) => {
        const isLast = idx === allPlayerRecords.length - 1;
        return `    ('${p.firstName}', '${p.lastName}')${isLast ? '' : ','}`;
      });
      
      lines.push(...personLines);
      lines.push('  RETURNING id, first_name, last_name');
      lines.push('),');
      lines.push('inserted_players AS (');
      lines.push('  INSERT INTO players (person_id, source_system_id, external_id)');
      lines.push('  SELECT');
      lines.push('    ip.id,');
      lines.push('    1,  -- source_system_id (APSL)');
      lines.push('    CASE');
      
      allPlayerRecords.forEach((p, idx) => {
        lines.push(`      WHEN ip.first_name = '${p.firstName}' AND ip.last_name = '${p.lastName}' THEN '${p.externalId}'`);
      });
      
      lines.push('    END');
      lines.push('  FROM inserted_persons ip');
      lines.push('  ON CONFLICT (external_id) DO UPDATE SET');
      lines.push('    person_id = EXCLUDED.person_id');
      lines.push('  RETURNING id, external_id');
      lines.push('),');
      lines.push('team_lookup AS (');
      lines.push('  SELECT t.id, t.name FROM teams t');
      lines.push(')');
      lines.push('INSERT INTO team_players (team_id, player_id, source_system_id)');
      lines.push('SELECT');
      lines.push('  tl.id,');
      lines.push('  ipl.id,');
      lines.push('  1');
      lines.push('FROM inserted_players ipl');
      lines.push('CROSS JOIN LATERAL (');
      lines.push('  SELECT CASE ipl.external_id');
      
      allPlayerRecords.forEach((p, idx) => {
        if (idx === 0 || allPlayerRecords[idx - 1].teamName !== p.teamName) {
          lines.push(`    WHEN '${p.externalId}' THEN '${p.teamName}'`);
        }
      });
      
      lines.push('  END as team_name');
      lines.push(') team_names');
      lines.push('JOIN team_lookup tl ON tl.name = team_names.team_name');
      lines.push('ON CONFLICT (team_id, player_id) DO UPDATE SET');
      lines.push('  source_system_id = EXCLUDED.source_system_id;');
      lines.push('');
      lines.push('-- TODO: Add player season stats (goals, assists) to separate player_season_stats table');
      lines.push('');
      
      const sqlPath = path.join(dataDir, '029-apsl-players-scraped.sql');
      await fs.writeFile(sqlPath, lines.join('\n'), 'utf-8');
      
      console.log(`   ✅ Generated SQL: 029-apsl-players-scraped.sql (${allPlayerRecords.length} players)`);
    }
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
