#!/usr/bin/env node

/**
 * APSL Schedule Scraper
 * 
 * Scrapes game schedules for APSL teams and generates SQL insert statements.
 * This does NOT scrape rosters - only schedules/matches.
 * 
 * MODES:
 *   (none)     - Scrape all team schedules
 *   lighthouse - Scrape Lighthouse 1893 SC schedule only
 * 
 * Usage:
 *   node database/scripts/apsl-scraper/scrape-apsl-schedule.js
 *   node database/scripts/apsl-scraper/scrape-apsl-schedule.js lighthouse
 * 
 * Output: database/data/25-schedule-apsl.sql
 */

const https = require('https');
const { JSDOM } = require('jsdom');
const fs = require('fs');
const path = require('path');

// Parse mode from command line argument
const MODE = process.argv[2]; // 'lighthouse' or undefined (all teams)

const BASE_URL = 'https://apslsoccer.com';
const LEAGUE_URL = `${BASE_URL}/standings/`;
const OUTPUT_FILE = path.join(__dirname, '../../data/25-schedule-apsl.sql');

// Event type IDs
const MATCH_EVENT_TYPE_ID = '550e8400-e29b-41d4-a716-446655440402';
const HOME_STATUS_ID = '550e8400-e29b-41d4-a716-446655440801';
const AWAY_STATUS_ID = '550e8400-e29b-41d4-a716-446655440802';
const SYSTEM_USER_ID = '77d77471-1250-47e0-81ab-d4626595d63c';
const SOURCE_APP = '550e8400-e29b-41d4-a716-446655440311';

const events = [];
const matches = [];

// Helper: HTTP GET request
function httpsGet(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { timeout: 30000 }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data));
    }).on('error', reject).on('timeout', () => reject(new Error('Request timeout')));
  });
}

// Helper: Generate deterministic UUID from string
function deterministicUUID(str, namespace = '00000000-0000-0000-0000') {
  const hash = str.split('').reduce((acc, char) => {
    return ((acc << 5) - acc) + char.charCodeAt(0) | 0;
  }, 0);
  const hex = Math.abs(hash).toString(16).padStart(12, '0').substring(0, 12);
  return `${namespace}-${hex}`;
}

// Scrape team schedules from TeamPass
async function scrapeTeamSchedule(teamUrl, teamName) {
  console.log(`      Fetching schedule for ${teamName}...`);
  
  try {
    const html = await httpsGet(teamUrl);
    const dom = new JSDOM(html);
    const doc = dom.window.document;
    
    // Look for schedule table (varies by team page structure)
    const scheduleRows = doc.querySelectorAll('table.schedule tbody tr');
    
    let gameCount = 0;
    
    for (const row of scheduleRows) {
      const cells = row.querySelectorAll('td');
      if (cells.length < 4) continue;
      
      const dateStr = cells[0]?.textContent?.trim();
      const opponent = cells[1]?.textContent?.trim();
      const location = cells[2]?.textContent?.trim();
      const result = cells[3]?.textContent?.trim();
      
      if (!dateStr || !opponent) continue;
      
      // Parse date
      const gameDate = new Date(dateStr);
      if (isNaN(gameDate.getTime())) continue;
      
      // Determine home/away
      const isHome = location?.toLowerCase().includes('home') || 
                     location?.toLowerCase().includes(teamName.toLowerCase());
      
      // Create event ID
      const eventId = deterministicUUID(`apsl-${teamName}-${dateStr}-${opponent}`, '550e8400-e29b-41d4-a716');
      
      // Create event
      events.push({
        id: eventId,
        teamName: teamName,
        name: `vs ${opponent}`,
        startTime: gameDate.toISOString(),
        endTime: new Date(gameDate.getTime() + 90 * 60000).toISOString(),
        location: location || null,
        externalSource: 'apsl',
        externalEventId: `apsl-${teamName}-${dateStr}`
      });
      
      // Create match record
      matches.push({
        eventId: eventId,
        homeTeam: isHome ? teamName : opponent,
        awayTeam: isHome ? opponent : teamName,
        status: result || 'scheduled'
      });
      
      gameCount++;
    }
    
    console.log(`        ✓ Found ${gameCount} games`);
    
  } catch (error) {
    console.error(`        ✗ Error scraping schedule: ${error.message}`);
  }
}

// Main scraper function
async function scrapeSchedules() {
  console.log('🏆 APSL Schedule Scraper');
  console.log('========================\n');
  
  try {
    // Step 1: Get all teams from standings page
    console.log('📊 Fetching APSL standings page...');
    const standingsHtml = await httpsGet(LEAGUE_URL);
    const dom = new JSDOM(standingsHtml);
    const doc = dom.window.document;
    
    const teamLinks = doc.querySelectorAll('a[href*="/team/"]');
    const teams = new Set();
    
    teamLinks.forEach(link => {
      const teamUrl = link.href.startsWith('http') ? link.href : `${BASE_URL}${link.href}`;
      const teamName = link.textContent.trim();
      if (teamName) {
        teams.add({ name: teamName, url: teamUrl });
      }
    });
    
    console.log(`   Found ${teams.size} teams\n`);
    
    // Step 2: Scrape each team's schedule (filter by mode if specified)
    console.log('📅 Scraping team schedules...');
    for (const team of teams) {
      // If lighthouse mode, only scrape Lighthouse 1893 SC
      if (MODE === 'lighthouse' && !team.name.toLowerCase().includes('lighthouse')) {
        console.log(`   ⊘ Skipping ${team.name} (not Lighthouse)`);
        continue;
      }
      await scrapeTeamSchedule(team.url, team.name);
    }
    
    console.log(`\n✅ Scraping complete`);
    console.log(`   Events: ${events.length}`);
    console.log(`   Matches: ${matches.length}\n`);
    
    // Step 3: Generate SQL
    console.log('💾 Generating SQL...');
    generateSQL();
    console.log(`   ✓ SQL written to ${OUTPUT_FILE}\n`);
    
  } catch (error) {
    console.error('❌ Fatal error:', error.message);
    process.exit(1);
  }
}

function generateSQL() {
  const lines = [];
  
  lines.push('-- APSL Game Schedules');
  lines.push('-- Generated by scrape-apsl-schedule.js');
  lines.push(`-- Generated at: ${new Date().toISOString()}`);
  lines.push('');
  lines.push('-- Insert events and matches for APSL teams');
  lines.push('');
  
  // Generate events
  for (const event of events) {
    lines.push(`-- Event: ${event.name} (${event.teamName})`);
    lines.push(`INSERT INTO events (id, team_id, event_type_id, name, start_time, end_time, location, created_by, source_id, external_event_id, external_source)`);
    lines.push(`SELECT`);
    lines.push(`  '${event.id}'::uuid,`);
    lines.push(`  (SELECT id FROM teams WHERE name = '${event.teamName.replace(/'/g, "''")}' LIMIT 1),`);
    lines.push(`  '${MATCH_EVENT_TYPE_ID}'::uuid,`);
    lines.push(`  '${event.name.replace(/'/g, "''")}',`);
    lines.push(`  '${event.startTime}'::timestamp,`);
    lines.push(`  '${event.endTime}'::timestamp,`);
    lines.push(`  ${event.location ? `'${event.location.replace(/'/g, "''")}'` : 'NULL'},`);
    lines.push(`  '${SYSTEM_USER_ID}'::uuid,`);
    lines.push(`  '${SOURCE_APP}'::uuid,`);
    lines.push(`  '${event.externalEventId}',`);
    lines.push(`  '${event.externalSource}'`);
    lines.push(`WHERE NOT EXISTS (`);
    lines.push(`  SELECT 1 FROM events WHERE external_event_id = '${event.externalEventId}' AND external_source = '${event.externalSource}'`);
    lines.push(`);`);
    lines.push('');
  }
  
  // Generate matches
  for (const match of matches) {
    const matchEvent = events.find(e => e.id === match.eventId);
    if (!matchEvent) continue;
    
    lines.push(`-- Match: ${match.homeTeam} vs ${match.awayTeam}`);
    lines.push(`INSERT INTO matches (event_id, home_team_id, away_team_id, status)`);
    lines.push(`SELECT`);
    lines.push(`  '${match.eventId}'::uuid,`);
    lines.push(`  (SELECT id FROM teams WHERE name = '${match.homeTeam.replace(/'/g, "''")}' LIMIT 1),`);
    lines.push(`  (SELECT id FROM teams WHERE name = '${match.awayTeam.replace(/'/g, "''")}' LIMIT 1),`);
    lines.push(`  '${match.status}'`);
    lines.push(`WHERE EXISTS (SELECT 1 FROM events WHERE id = '${match.eventId}'::uuid)`);
    lines.push(`  AND NOT EXISTS (SELECT 1 FROM matches WHERE event_id = '${match.eventId}'::uuid);`);
    lines.push('');
  }
  
  fs.writeFileSync(OUTPUT_FILE, lines.join('\n'));
}

// Run scraper
scrapeSchedules();
