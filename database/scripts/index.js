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
    const source = (target.source_system_name || 'reference').toLowerCase();
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
  const standingsTarget = targets.find(t => t.target_type_name === 'league_structure');
  if (!standingsTarget) {
    console.log('   ⚠️  No league_structure target found for APSL');
    return;
  }
  
  const standingsTargetId = standingsTarget.id;
  
  // Find team roster template target
  const rosterTemplate = targets.find(t => t.target_type_name === 'team_roster');
  const rosterTargetId = rosterTemplate ? rosterTemplate.id : null;
  
  // Find match event template target
  const matchTemplate = targets.find(t => t.target_type_name === 'match_event');
  const matchTargetId = matchTemplate ? matchTemplate.id : null;
  
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
    
    // Parse match event HTML files
    console.log(`   📋 Parsing match events...`);
    const matchFiles = files.filter(f => f.startsWith('apsl-event-') && f.endsWith('.html'));
    console.log(`   🏆 Found ${matchFiles.length} match event files`);
    
    for (let i = 0; i < matchFiles.length; i++) {
      const matchFile = matchFiles[i];
      try {
        const matchHtml = await fs.readFile(path.join(cacheDir, matchFile), 'utf-8');
        const matchParser = new ApslHtmlParser();
        matchParser.parse(matchHtml);
        
        // Parse match details
        const matchInfo = matchParser.parseMatchInfo();
        if (matchInfo && matchInfo.homeTeam && matchInfo.awayTeam) {
          // Extract event ID from filename (e.g., "apsl-event-226814_..." → "226814")
          const eventId = matchFile.match(/apsl-event-(\d+)/)?.[1];
          
          matchInfo.external_id = eventId;
          matchInfo.source = 'APSL';
          
          // Parse lineups and events
          const { events, lineups } = matchParser.parseMatchPlayerStats();
          matchInfo.lineups = lineups;
          matchInfo.events = events;
          
          allMatches.push(matchInfo);
        }
      } catch (error) {
        console.log(`      ⚠️  Failed to parse ${matchFile}: ${error.message}`);
      }
    }
    
    console.log(`   ✅ Parsed ${allMatches.length} matches with events`);
    
    // Generate SQL for teams, players, and matches
    // Pass scrape_target_id values for data lineage
    await generateApslSql(conferences, parser, allPlayers, allMatches, {
      standingsTargetId,
      rosterTargetId,
      matchTargetId
    });
    
  } catch (error) {
    console.error(`   ❌ Parse error: ${error.message}`);
    console.error(error.stack);
  }
}

/**
 * Generate SQL files for APSL scraped data
 */
async function generateApslSql(conferences, parser, allPlayers, allMatches, targetIds = {}) {
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
  
  // Generate clubs and sport_divisions SQL
  const clubLines = [];
  const sportDivisionLines = [];
  
  clubLines.push('-- Clubs (Football Home club data + scraped teams)');
  clubLines.push('-- Each team gets its own club by default (can consolidate later in UI)');
  clubLines.push('-- This file is generated by scrapers and committed to git');
  clubLines.push('');
  clubLines.push('INSERT INTO clubs (id, display_name, slug, is_active) VALUES');
  clubLines.push("    (1, 'Lighthouse 1893 SC', 'lighthouse-1893', true)");
  
  // Generate club for each scraped team (starting at id=2)
  const teamToClubId = new Map();
  const teamToSportDivisionId = new Map();
  let clubId = 2;
  let sportDivisionId = 2; // sport_division 1 is for Lighthouse
  
  teams.forEach((team, idx) => {
    const slug = team.name.toLowerCase()
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .substring(0, 50);
    
    clubLines.push(',');
    clubLines.push(`    (${clubId}, '${team.name.replace(/'/g, "''")}', '${slug}', true)`);
    
    teamToClubId.set(team.name, clubId);
    teamToSportDivisionId.set(team.name, sportDivisionId);
    
    clubId++;
    sportDivisionId++;
  });
  
  clubLines.push('');
  clubLines.push('ON CONFLICT (id) DO NOTHING;');
  clubLines.push('');
  
  // Generate sport_divisions
  sportDivisionLines.push('-- Sport Divisions (Football Home club divisions + scraped teams)');
  sportDivisionLines.push('-- Each club has sport divisions (groups of teams by age/competition level)');
  sportDivisionLines.push('-- By default: 1 club → 1 sport_division → 1+ teams');
  sportDivisionLines.push('-- This file is generated by scrapers and committed to git');
  sportDivisionLines.push('');
  sportDivisionLines.push('INSERT INTO sport_divisions (id, club_id, display_name, sport_id, is_active) VALUES');
  sportDivisionLines.push("    (1, 1, 'Lighthouse Soccer', 1, true)");
  
  teams.forEach((team, idx) => {
    const clubId = teamToClubId.get(team.name);
    const sportDivId = teamToSportDivisionId.get(team.name);
    
    sportDivisionLines.push(',');
    sportDivisionLines.push(`    (${sportDivId}, ${clubId}, '${team.name.replace(/'/g, "''")}', 1, true)`);
  });
  
  sportDivisionLines.push('');
  sportDivisionLines.push('ON CONFLICT (id) DO NOTHING;');
  sportDivisionLines.push('');
  
  // Write clubs and sport_divisions to separate files
  await fs.writeFile(path.join(dataDir, '030-clubs.sql'), clubLines.join('\n'), 'utf-8');
  await fs.writeFile(path.join(dataDir, '031-sport-divisions.sql'), sportDivisionLines.join('\n'), 'utf-8');
  
  // Generate combined SQL file for teams + players
  const allLines = [];
  
  allLines.push('-- Scraped Teams & Players (All Sources)');
  allLines.push('-- Generated by database-driven scraper');
  allLines.push('-- Uses CTEs with RETURNING to get auto-generated IDs');
  allLines.push('-- Source tracking: team_division_external_ids for teams');
  allLines.push('-- Rosters scoped to team_divisions (competition-specific)');
  allLines.push('');
  allLines.push('-- ====================');
  allLines.push('-- TEAMS');
  allLines.push('-- ====================');
  allLines.push('');
  
  // Generate teams SQL using CTEs with RETURNING
  if (teams.length > 0) {
    const lines = [];
    lines.push('-- Insert teams and link to divisions with external IDs');
    
    lines.push('WITH inserted_teams AS (');
    lines.push('  INSERT INTO teams (name, sport_division_id, scrape_target_id) VALUES');
    
    const teamValueLines = teams.map((team, idx) => {
      const isLast = idx === teams.length - 1;
      const scrapeTargetId = targetIds.standingsTargetId || 'NULL';
      const sportDivId = teamToSportDivisionId.get(team.name) || 'NULL';
      return `    ('${team.name.replace(/'/g, "''")}', ${sportDivId}, ${scrapeTargetId})${isLast ? '' : ','}`;
    });
    
    lines.push(...teamValueLines);
    lines.push('  ON CONFLICT (name) DO NOTHING');
    lines.push('  RETURNING id, name');
    lines.push('),');
    lines.push('all_teams AS (');
    lines.push('  SELECT id, name FROM inserted_teams');
    lines.push('  UNION ALL');
    lines.push('  SELECT id, name FROM teams WHERE name IN (');
    teams.forEach((team, idx) => {
      const isLast = idx === teams.length - 1;
      lines.push(`    '${team.name.replace(/'/g, "''")}'${isLast ? '' : ','}`);
    });
    lines.push('  ) AND id NOT IN (SELECT id FROM inserted_teams)');
    lines.push('),');
    lines.push('inserted_team_divisions AS (');
    lines.push('  INSERT INTO team_divisions (team_id, division_id, is_active)');
    lines.push('  SELECT');
    lines.push('    at.id,');
    lines.push('    CASE at.name');
    
    teams.forEach(team => {
      lines.push(`      WHEN '${team.name.replace(/'/g, "''")}' THEN ${team.division_id}`);
    });
    
    lines.push('    END,');
    lines.push('    true');
    lines.push('  FROM all_teams at');
    lines.push('  ON CONFLICT (team_id, division_id) DO NOTHING');
    lines.push('  RETURNING id, team_id');
    lines.push(')');
    lines.push('SELECT COUNT(*) as team_divisions_inserted FROM inserted_team_divisions;');
    lines.push('');
    allLines.push(...lines);
    allLines.push('');
    
    // Separate statement for external_ids (depends on team_divisions existing)
    const extIdLines = [];
    extIdLines.push('INSERT INTO team_division_external_ids (team_division_id, source_system_id, external_id)');
    extIdLines.push('SELECT');
    extIdLines.push('  td.id,');
    extIdLines.push('  1,  -- source_system_id (APSL)');
    extIdLines.push('  CASE t.name');
    
    teams.forEach(team => {
      extIdLines.push(`    WHEN '${team.name.replace(/'/g, "''")}' THEN '${team.external_id}'`);
    });
    
    extIdLines.push('  END');
    extIdLines.push('FROM teams t');
    extIdLines.push('JOIN team_divisions td ON td.team_id = t.id');
    extIdLines.push('WHERE td.division_id = CASE t.name');
    
    teams.forEach(team => {
      extIdLines.push(`  WHEN '${team.name.replace(/'/g, "''")}' THEN ${team.division_id}`);
    });
    
    extIdLines.push('END');
    extIdLines.push('ON CONFLICT (source_system_id, external_id) DO UPDATE SET');
    extIdLines.push('  team_division_id = EXCLUDED.team_division_id;');
    
    allLines.push(...extIdLines);
    allLines.push('');
    allLines.push('');
  }
  
  allLines.push('-- ====================');
  allLines.push('-- PLAYERS');
  allLines.push('-- ====================');
  allLines.push('');
  
  // Generate players SQL using CTEs with RETURNING
  if (allPlayers.length > 0) {
    const lines = [];
    lines.push('-- Players (Scraped Data)');
    lines.push('-- Insert persons and players');
    lines.push('-- Uses CTEs with RETURNING to get auto-generated IDs');
    lines.push('-- No external_id: APSL provides no player IDs, only names');
    lines.push('');
    
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
      
      playersByTeam[player.team_name].push({
        firstName: firstName.replace(/'/g, "''"),
        lastName: lastName.replace(/'/g, "''"),
        teamName: player.team_name.replace(/'/g, "''"),
        goals: player.goals || 0,
        assists: player.assists || 0
      });
    }
    
    const allPlayerRecords = Object.values(playersByTeam).flat();
    
    if (allPlayerRecords.length > 0) {
      // Insert all persons (including those with duplicate names - they're different people!)
      lines.push('-- Insert persons for all players');
      lines.push('WITH inserted_persons AS (');
      lines.push('  INSERT INTO persons (first_name, last_name) VALUES');
      
      const personLines = allPlayerRecords.map((p, idx) => {
        const isLast = idx === allPlayerRecords.length - 1;
        return `    ('${p.firstName}', '${p.lastName}')${isLast ? '' : ','}`;
      });
      
      lines.push(...personLines);
      lines.push('  RETURNING id');
      lines.push('),');
      lines.push('indexed_persons AS (');
      lines.push('  SELECT id, ROW_NUMBER() OVER (ORDER BY id) as row_num');
      lines.push('  FROM inserted_persons');
      lines.push('),');
      lines.push('inserted_players AS (');
      lines.push(`  INSERT INTO players (person_id, scrape_target_id)`);
      lines.push('  SELECT ip.id, ' + (targetIds.rosterTargetId || 'NULL'));
      lines.push('  FROM indexed_persons ip');
      lines.push('  RETURNING id, person_id');
      lines.push(')');
      lines.push('SELECT COUNT(*) as players_inserted FROM inserted_players;');
      
      allLines.push(...lines);
      allLines.push('');
    }
  }
  
  allLines.push('');
  allLines.push('-- ====================');
  allLines.push('-- TEAM_PLAYERS (Rosters)');
  allLines.push('-- ====================');
  allLines.push('');
  
  // Generate team_division_players junction table (depends on both teams and players existing)
  if (allPlayers.length > 0) {
    const lines = [];
    lines.push('-- Link players to teams via team_divisions');
    lines.push('-- Rosters are competition-specific (team_division_id not team_id)');
    lines.push('-- Source tracking: team_division_players → team_divisions → team_division_external_ids');
    lines.push('');
    
    const allPlayerRecords = [];
    const playersByTeam = {};
    for (const player of allPlayers) {
      if (!playersByTeam[player.team_name]) {
        playersByTeam[player.team_name] = [];
      }
      
      // Split name into first/last
      const nameParts = player.name.trim().split(' ');
      const firstName = nameParts.slice(0, -1).join(' ') || nameParts[0];
      const lastName = nameParts[nameParts.length - 1];
      
      const p = {
        firstName: firstName.replace(/'/g, "''"),
        lastName: lastName.replace(/'/g, "''"),
        teamName: player.team_name.replace(/'/g, "''"),
        goals: player.goals || 0,
        assists: player.assists || 0
      };
      
      playersByTeam[player.team_name].push(p);
      allPlayerRecords.push(p);
    }
    
    if (allPlayerRecords.length > 0) {
      lines.push('WITH indexed_players AS (');
      lines.push('  SELECT p.id, ROW_NUMBER() OVER (ORDER BY p.id) as row_num');
      lines.push('  FROM players p');
      lines.push('  JOIN persons per ON p.person_id = per.id');
      lines.push('  ORDER BY p.id');
      lines.push('  LIMIT ' + allPlayerRecords.length);
      lines.push('),');
      lines.push('team_division_lookup AS (');
      lines.push('  SELECT td.id, t.name as team_name');
      lines.push('  FROM team_divisions td');
      lines.push('  JOIN teams t ON td.team_id = t.id');
      lines.push('  WHERE td.is_active = true');
      lines.push(')');
      lines.push('INSERT INTO team_division_players (team_division_id, player_id)');
      lines.push('SELECT');
      lines.push('  tdl.id,');
      lines.push('  ipl.id');
      lines.push('FROM indexed_players ipl');
      lines.push('CROSS JOIN LATERAL (');
      lines.push('  SELECT CASE ipl.row_num');
      
      // Map EVERY player to their team (not just one per team!)
      allPlayerRecords.forEach((p, idx) => {
        lines.push(`    WHEN ${idx + 1} THEN '${p.teamName}'`);
      });
      
      lines.push('  END as team_name');
      lines.push(') team_names');
      lines.push('JOIN team_division_lookup tdl ON tdl.team_name = team_names.team_name');
      lines.push('ON CONFLICT (team_division_id, player_id) DO NOTHING;');
      
      allLines.push(...lines);
    }
  }
  
  // Write combined file
  if (allLines.length > 0) {
    const sqlPath = path.join(dataDir, '032-teams-players.sql');
    await fs.writeFile(sqlPath, allLines.join('\n'), 'utf-8');
    
    console.log(`   ✅ Generated SQL: 032-teams-players.sql (${teams.length} teams, ${allPlayers.length} players)`);
  }
  
  // Generate match SQL files
  if (allMatches && allMatches.length > 0) {
    console.log(`   🏆 Generating match SQL for ${allMatches.length} matches...`);
    
    const matchLines = [];
    const matchDivisionLines = [];
    const matchLineupLines = [];
    const matchEventLines = [];
    
    matchLines.push('-- Matches (All Sources)');
    matchLines.push('-- Generated by database-driven scraper');
    matchLines.push('');
    
    // Build map of team names to divisions (so we can link matches to divisions)
    const teamToDivision = new Map();
    teams.forEach(t => {
      teamToDivision.set(t.name, t.division_id);
    });
    
    matchLines.push('INSERT INTO matches (');
    matchLines.push('  home_team_id, away_team_id, match_type_id, match_status_id, match_date,');
    matchLines.push('  home_score, away_score, source_system_id, external_id, scrape_target_id');
    matchLines.push(')');
    matchLines.push('SELECT');
    matchLines.push('  ht.id,');
    matchLines.push('  at.id,');
    matchLines.push('  1, -- match_type_id (Regular Season)');
    matchLines.push('  CASE WHEN m.home_score IS NOT NULL THEN 3 ELSE 1 END, -- match_status_id (3=Completed, 1=Scheduled)');
    matchLines.push("  CURRENT_DATE, -- match_date (APSL pages don't show dates)");
    matchLines.push('  m.home_score,');
    matchLines.push('  m.away_score,');
    matchLines.push('  1, -- source_system_id (APSL)');
    matchLines.push('  m.external_id,');
    matchLines.push(`  ${targetIds.matchTargetId || 'NULL'} -- scrape_target_id`);
    matchLines.push('FROM (VALUES');
    
    const matchValues = allMatches.map((match, idx) => {
      const isLast = idx === allMatches.length - 1;
      const homeScore = match.homeScore !== null ? match.homeScore : 'NULL';
      const awayScore = match.awayScore !== null ? match.awayScore : 'NULL';
      return `  ('${match.homeTeam.replace(/'/g, "''")}', '${match.awayTeam.replace(/'/g, "''")}', ${homeScore}, ${awayScore}, '${match.external_id}')${isLast ? '' : ','}`;
    });
    
    matchLines.push(...matchValues);
    matchLines.push(') AS m(home_team, away_team, home_score, away_score, external_id)');
    matchLines.push('JOIN teams ht ON ht.name = m.home_team');
    matchLines.push('JOIN teams at ON at.name = m.away_team');
    matchLines.push('ON CONFLICT (source_system_id, external_id) DO UPDATE SET');
    matchLines.push('  home_score = EXCLUDED.home_score,');
    matchLines.push('  away_score = EXCLUDED.away_score,');
    matchLines.push('  match_status_id = EXCLUDED.match_status_id;');
    matchLines.push('');
    
    const matchSqlPath = path.join(dataDir, '050-matches.sql');
    await fs.writeFile(matchSqlPath, matchLines.join('\n'), 'utf-8');
    
    // Generate match_divisions
    matchDivisionLines.push('-- Match Divisions (Links matches to divisions)');
    matchDivisionLines.push('-- Generated by database-driven scraper');
    matchDivisionLines.push('');
    matchDivisionLines.push('INSERT INTO match_divisions (match_id, division_id)');
    matchDivisionLines.push('SELECT DISTINCT');
    matchDivisionLines.push('  m.id,');
    matchDivisionLines.push('  td.division_id');
    matchDivisionLines.push('FROM matches m');
    matchDivisionLines.push('JOIN team_divisions td ON td.team_id = m.home_team_id');
    matchDivisionLines.push('WHERE m.source_system_id = 1 -- APSL only');
    matchDivisionLines.push('ON CONFLICT (match_id, division_id) DO NOTHING;');
    matchDivisionLines.push('');
    
    const matchDivisionSqlPath = path.join(dataDir, '051-match-divisions.sql');
    await fs.writeFile(matchDivisionSqlPath, matchDivisionLines.join('\n'), 'utf-8');
    
    // Generate match_events
    const allEvents = [];
    allMatches.forEach(match => {
      if (match.events && match.events.length > 0) {
        match.events.forEach(event => {
          allEvents.push({
            external_id: match.external_id,
            player_name: event.player_name,
            team_name: event.team_name,
            event_type: event.event_type,
            minute: event.minute,
            assisted_by: event.assisted_by
          });
        });
      }
    });
    
    if (allEvents.length > 0) {
      matchEventLines.push('-- Match Events (Goals, Cards, Substitutions)');
      matchEventLines.push('-- Generated by database-driven scraper');
      matchEventLines.push('');
      matchEventLines.push('INSERT INTO match_events (');
      matchEventLines.push('  match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id');
      matchEventLines.push(')');
      matchEventLines.push('SELECT');
      matchEventLines.push('  m.id,');
      matchEventLines.push('  p.id,');
      matchEventLines.push('  t.id,');
      matchEventLines.push('  met.id,');
      matchEventLines.push('  e.minute,');
      matchEventLines.push('  ap.id');
      matchEventLines.push('FROM (VALUES');
      
      const eventValues = allEvents.map((event, idx) => {
        const isLast = idx === allEvents.length - 1;
        const minute = event.minute !== null && event.minute !== undefined ? event.minute : 'NULL';
        const assistedBy = event.assisted_by ? `'${event.assisted_by.replace(/'/g, "''")}'` : 'NULL';
        return `  ('${event.external_id}', '${event.player_name.replace(/'/g, "''")}', '${event.team_name?.replace(/'/g, "''")}', '${event.event_type}', ${minute}, ${assistedBy})${isLast ? '' : ','}`;
      });
      
      matchEventLines.push(...eventValues);
      matchEventLines.push(') AS e(match_external_id, player_name, team_name, event_type, minute, assisted_by)');
      matchEventLines.push('JOIN matches m ON m.external_id = e.match_external_id AND m.source_system_id = 1');
      matchEventLines.push('JOIN teams t ON t.name = e.team_name');
      matchEventLines.push('JOIN match_event_types met ON met.name = e.event_type');
      matchEventLines.push('JOIN team_division_players tp ON tp.team_division_id IN (');
      matchEventLines.push('  SELECT td.id FROM team_divisions td WHERE td.team_id = t.id');
      matchEventLines.push(')');
      matchEventLines.push('JOIN players p ON p.id = tp.player_id');
      matchEventLines.push('JOIN persons per ON per.id = p.person_id');
      matchEventLines.push('  AND per.first_name || \' \' || per.last_name = e.player_name');
      matchEventLines.push('LEFT JOIN persons aper ON aper.first_name || \' \' || aper.last_name = e.assisted_by');
      matchEventLines.push('LEFT JOIN players ap ON ap.person_id = aper.id');
      matchEventLines.push('ON CONFLICT DO NOTHING;');
      matchEventLines.push('');
      
      const matchEventSqlPath = path.join(dataDir, '052-match-events.sql');
      await fs.writeFile(matchEventSqlPath, matchEventLines.join('\n'), 'utf-8');
    }
    
    // Generate match_lineups
    const allLineups = [];
    allMatches.forEach(match => {
      if (match.lineups && match.lineups.length > 0) {
        match.lineups.forEach(lineup => {
          allLineups.push({
            external_id: match.external_id,
            player_name: lineup.player_name,
            team_name: lineup.team_name,
            is_starter: lineup.is_starter
          });
        });
      }
    });
    
    if (allLineups.length > 0) {
      matchLineupLines.push('-- Match Lineups (Starting XI and Substitutes)');
      matchLineupLines.push('-- Generated by database-driven scraper');
      matchLineupLines.push('');
      matchLineupLines.push('INSERT INTO match_lineups (');
      matchLineupLines.push('  match_id, player_id, team_id, is_starter');
      matchLineupLines.push(')');
      matchLineupLines.push('SELECT');
      matchLineupLines.push('  m.id,');
      matchLineupLines.push('  p.id,');
      matchLineupLines.push('  t.id,');
      matchLineupLines.push('  l.is_starter');
      matchLineupLines.push('FROM (VALUES');
      
      const lineupValues = allLineups.map((lineup, idx) => {
        const isLast = idx === allLineups.length - 1;
        return `  ('${lineup.external_id}', '${lineup.player_name.replace(/'/g, "''")}', '${lineup.team_name.replace(/'/g, "''")}', ${lineup.is_starter})${isLast ? '' : ','}`;
      });
      
      matchLineupLines.push(...lineupValues);
      matchLineupLines.push(') AS l(match_external_id, player_name, team_name, is_starter)');
      matchLineupLines.push('JOIN matches m ON m.external_id = l.match_external_id AND m.source_system_id = 1');
      matchLineupLines.push('JOIN teams t ON t.name = l.team_name');
      matchLineupLines.push('JOIN team_division_players tp ON tp.team_division_id IN (');
      matchLineupLines.push('  SELECT td.id FROM team_divisions td WHERE td.team_id = t.id');
      matchLineupLines.push(')');
      matchLineupLines.push('JOIN players p ON p.id = tp.player_id');
      matchLineupLines.push('JOIN persons per ON per.id = p.person_id');
      matchLineupLines.push('  AND per.first_name || \' \' || per.last_name = l.player_name');
      matchLineupLines.push('ON CONFLICT (match_id, player_id) DO NOTHING;');
      matchLineupLines.push('');
      
      const matchLineupSqlPath = path.join(dataDir, '053-match-lineups.sql');
      await fs.writeFile(matchLineupSqlPath, matchLineupLines.join('\n'), 'utf-8');
    }
    
    console.log(`   ✅ Generated SQL: 050-matches.sql (${allMatches.length} matches)`);
    console.log(`   ✅ Generated SQL: 051-match-divisions.sql`);
    if (allEvents.length > 0) {
      console.log(`   ✅ Generated SQL: 052-match-events.sql (${allEvents.length} events)`);
    }
    if (allLineups.length > 0) {
      console.log(`   ✅ Generated SQL: 053-match-lineups.sql (${allLineups.length} lineups)`);
    }
  }
}

/**
 * Parse CASA targets (rosters, schedules, standings)
 */
async function parseCasaTargets(targets, sqlGenerator) {
  const path = require('path');
  const fs = require('fs').promises;
  const { JSDOM } = require('jsdom');
  
  const cacheDir = path.join(__dirname, '../scraped-html/casa');
  
  console.log(`   📋 Parsing CASA targets...`);
  
  // Find scrape target IDs for each league
  const over40Standings = targets.find(t => t.label === 'CASA Over 40 Standings');
  const over40Roster = targets.find(t => t.label === 'CASA Over 40 Roster Sheet');
  const over50Standings = targets.find(t => t.label === 'CASA Over 50 Standings');
  const over50Roster = targets.find(t => t.label === 'CASA Over 50 Roster Sheet');
  
  if (!over40Roster && !over50Roster) {
    console.log(`   ⚠️  No CASA roster targets found`);
    return;
  }
  
  // Parse Google Sheets roster files
  try {
    const files = await fs.readdir(cacheDir);
    const sheetsFiles = files.filter(f => f.startsWith('spreadsheets') && f.endsWith('.html'));
    
    console.log(`   💾 Found ${sheetsFiles.length} Google Sheets roster files`);
    
    const allTeams = [];
    
    for (const file of sheetsFiles) {
      const filePath = path.join(cacheDir, file);
      const html = await fs.readFile(filePath, 'utf-8');
      
      // Extract league name from title
      const dom = new JSDOM(html);
      const title = dom.window.document.title;
      const leagueName = title.includes('Select') ? 'Select Liga 1' : 'Traditional';
      
      console.log(`   📄 Parsing: ${title}`);
      
      // Extract team names from page switcher tabs
      // Pattern: items.push({name: "Team Name", pageUrl: "...", gid: "..."});
      const teamMatches = html.match(/items\.push\({name:\s*"([^"]+)"/g);
      if (!teamMatches) {
        console.log(`   ⚠️  No team names found in ${file}`);
        continue;
      }
      
      const teams = teamMatches.map(match => {
        const nameMatch = match.match(/name:\s*"([^"]+)"/);
        return nameMatch ? nameMatch[1] : null;
      }).filter(Boolean);
      
      console.log(`   ✅ Found ${teams.length} teams: ${teams.join(', ')}`);
      
      // Determine scrape target ID based on league
      const scrapeTargetId = title.includes('Select') 
        ? (over50Roster ? over50Roster.id : null)
        : (over40Roster ? over40Roster.id : null);
      
      teams.forEach(teamName => {
        allTeams.push({
          name: teamName,
          leagueName: leagueName,
          scrapeTargetId: scrapeTargetId
        });
      });
    }
    
    console.log(`   📊 Total teams parsed: ${allTeams.length}`);
    
    // Generate SQL files
    if (allTeams.length > 0) {
      await generateCasaSql(allTeams, sqlGenerator);
    }
    
  } catch (error) {
    console.log(`   ⚠️  Error parsing CASA data: ${error.message}`);
    console.error(error.stack);
  }
}

async function generateCasaSql(teams, sqlGenerator) {
  console.log(`   🔨 Generating CASA SQL...`);
  
  // Generate clubs (1 per team)
  const clubInserts = teams.map((team, idx) => {
    const clubId = 1000 + idx; // Start at 1000 to avoid conflicts with APSL
    const slug = team.name.toLowerCase().replace(/[^a-z0-9]+/g, '-');
    return `(${clubId}, '${team.name}', '${slug}', true)`;
  });
  
  // Generate sport_divisions (1 per club, sport_id=1 for Soccer)
  const sportDivisionInserts = teams.map((team, idx) => {
    const clubId = 1000 + idx;
    const sportDivisionId = 1000 + idx;
    return `(${sportDivisionId}, ${clubId}, 1, '${team.name}', true)`;
  });
  
  // Generate teams
  const teamInserts = teams.map((team, idx) => {
    const sportDivisionId = 1000 + idx;
    return `('${team.name}', ${sportDivisionId}, ${team.scrapeTargetId})`;
  });
  
  // Write SQL files
  const fs = require('fs').promises;
  const path = require('path');
  
  // Append to existing clubs file
  const clubsSql = `\n-- CASA clubs\nINSERT INTO clubs (id, display_name, slug, is_active) VALUES\n${clubInserts.join(',\n')};\n`;
  await fs.appendFile(path.join(__dirname, '../data/030-clubs.sql'), clubsSql);
  
  // Append to existing sport_divisions file
  const sportDivisionsSql = `\n-- CASA sport_divisions\nINSERT INTO sport_divisions (id, club_id, sport_id, display_name, is_active) VALUES\n${sportDivisionInserts.join(',\n')};\n`;
  await fs.appendFile(path.join(__dirname, '../data/031-sport-divisions.sql'), sportDivisionsSql);
  
  // Append to existing teams file
  const teamsSql = `\n-- CASA teams\nINSERT INTO teams (name, sport_division_id, scrape_target_id) VALUES\n${teamInserts.join(',\n')};\n`;
  await fs.appendFile(path.join(__dirname, '../data/032-teams-players.sql'), teamsSql);
  
  console.log(`   ✅ Generated SQL for ${teams.length} CASA teams`);
}

/**
 * Load scrape targets from config file (source of truth)
 */
async function loadTargetsFromConfig() {
  // Load scrape targets from database instead of JSON file
  const { getScrapeTargets } = require('./utils/database');
  
  try {
    const targets = await getScrapeTargets();
    console.log(`   Loaded ${targets.length} targets from database`);
    return targets;
  } catch (error) {
    console.error(`❌ Failed to load scrape targets from database: ${error.message}`);
    console.error('   Make sure the database is running and scrape_targets table exists.');
    return [];
  }
}

async function main() {
  try {
    // NEW DATABASE-DRIVEN MODE
    if (fetchMode || parseMode) {
      console.log('\n🎯 Database-driven mode');
      console.log('📋 Reading scrape targets from config...\n');
      
      const targets = await loadTargetsFromConfig();
      
      if (targets.length === 0) {
        console.error('❌ No active scrape targets found in database');
        console.error('   Check that scrape_targets table has is_active=true rows');
        process.exit(1);
      }
      
      console.log(`Found ${targets.length} active scrape targets\n`);
      
      if (fetchMode) {
        console.log('📥 FETCH MODE: Downloading HTML from live websites...\n');
        await fetchTargets(targets);
      }
      
      if (parseMode) {
        console.log('📊 PARSE MODE: Parsing cached HTML and generating SQL...\n');
        await parseTargets(targets);
      }
      
      console.log('\n✨ Database-driven scraping completed successfully.');
      
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
