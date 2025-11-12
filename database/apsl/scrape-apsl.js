#!/usr/bin/env node

/**
 * APSL League Data Scraper
 * 
 * Scrapes American Premier Soccer League website for:
 * - All conferences
 * - All teams within each conference
 * - All player rosters for each team
 * 
 * Generates SQL INSERT statements with ON CONFLICT DO UPDATE for idempotency.
 * Output: database/apsl/apsl-data.sql (auto-loaded by schema/init.sql on rebuild)
 * 
 * Usage:
 *   node database/apsl/scrape-apsl.js > database/apsl/apsl-data.sql
 */

const https = require('https');
const { JSDOM } = require('jsdom');

// Configuration
const BASE_URL = 'https://apslsoccer.com';
const LEAGUE_URL = `${BASE_URL}/standings/`;
const SOCCER_SPORT_ID = '550e8400-e29b-41d4-a716-446655440101';
const APSL_LEAGUE_ID = '00000000-0000-0000-0001-000000000001';

// Tracking data structures
const conferences = new Map();
const divisions = new Map();
const clubs = new Map();
const sportDivisions = new Map();
const teams = new Map();
const users = new Map();
const players = new Map();
const teamPlayers = new Map();

// Helper: Fetch HTML from URL
function fetchHTML(url) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const options = {
      hostname: urlObj.hostname,
      path: urlObj.pathname + urlObj.search,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      }
    };
    
    https.get(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => resolve(data));
    }).on('error', reject);
  });
}

// Helper: Generate deterministic UUID from string
// Helper: Generate deterministic UUID
function generateUUID(prefix, seed) {
  const crypto = require('crypto');
  const hash = crypto.createHash('md5').update(seed).digest('hex');
  // UUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  // Use prefix for first part, hash for the rest
  return `${hash.substring(0,8)}-${hash.substring(8,12)}-${prefix}-${hash.substring(12,16)}-${hash.substring(16,28)}`;
}

// Helper: Create slug from string
function slugify(str) {
  return str.toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

// Helper: Generate random password for players
function generatePassword() {
  return 'Player' + Math.random().toString(36).substring(2, 10) + '!';
}

// Helper: SQL escape
function sqlEscape(str) {
  if (str === null || str === undefined) return 'NULL';
  return "'" + str.toString().replace(/'/g, "''") + "'";
}

// Helper: SQL array escape
function sqlArray(arr) {
  if (!arr || arr.length === 0) return 'NULL';
  return "ARRAY[" + arr.map(sqlEscape).join(',') + "]";
}

// Main scraping function
async function scrapeAPSL() {
  console.log('-- ========================================');
  console.log('-- APSL LEAGUE DATA (AUTO-GENERATED)');
  console.log('-- ========================================');
  console.log('-- Generated: ' + new Date().toISOString());
  console.log('-- Source: ' + LEAGUE_URL);
  console.log('-- Includes: Conferences, Divisions, Teams, Players');
  console.log('--');
  console.log('-- This file is automatically regenerated on rebuild.');
  console.log('-- Uses ON CONFLICT DO UPDATE for idempotent inserts.');
  console.log('-- ========================================\n');

  try {
    console.error('Fetching APSL standings page...');
    const html = await fetchHTML(LEAGUE_URL);
    const dom = new JSDOM(html);
    const doc = dom.window.document;

    // Step 1: Scrape conferences and divisions
    console.error('Scraping conferences and divisions...');
    
    // Find all divs that contain conference names
    const allDivs = doc.querySelectorAll('div');
    const conferenceData = [];
    
    for (const div of allDivs) {
      const text = div.textContent.trim();
      // Look for "2025/2026 - Conference Name" pattern
      const confMatch = text.match(/^(\d{4}\/\d{4})\s*-\s*(.+?)\s+Conference\s*$/);
      if (confMatch) {
        const season = confMatch[1];
        const confName = confMatch[2].trim() + ' Conference';
        
        // Find the next sibling that contains the standings table
        let currentElement = div.parentElement;
        let table = null;
        
        // Look for the table in the next few siblings
        while (currentElement && !table) {
          currentElement = currentElement.nextElementSibling;
          if (currentElement) {
            table = currentElement.querySelector('table');
          }
        }
        
        if (table) {
          conferenceData.push({ name: confName, season, table });
        }
      }
    }
    
    console.error(`Found ${conferenceData.length} conferences`);
    
    for (const confData of conferenceData) {
      const confName = confData.name;
      const confId = generateUUID('0002', confName);
      const confSlug = slugify(confName);
      
      conferences.set(confId, {
        id: confId,
        name: confName,
        display_name: confName,
        slug: confSlug,
        league_id: APSL_LEAGUE_ID
      });

      // For now, treat each conference as a single division
      // APSL doesn't have multiple divisions per conference on the standings page
      const divId = generateUUID('0003', confName);
      const divSlug = slugify(confName);
      
      divisions.set(divId, {
        id: divId,
        conference_id: confId,
        name: confName,
        display_name: confName,
        slug: divSlug,
        tier: 1
      });

      // Step 2: Scrape teams from standings table
      console.error(`Scraping teams from ${confName}...`);
      const teamRows = confData.table.querySelectorAll('tbody tr, tr');
      
      for (const row of teamRows) {
        const teamLink = row.querySelector('td a, a');
        if (!teamLink) continue;

          const teamName = teamLink.textContent.trim();
          const teamUrl = teamLink.getAttribute('href');
          const fullTeamUrl = teamUrl.startsWith('http') ? teamUrl : BASE_URL + teamUrl;

          const clubId = generateUUID('0003', teamName);
          const sportDivId = generateUUID('0004', teamName);
          const teamId = generateUUID('0005', teamName);

          // Store club
          if (!clubs.has(clubId)) {
            clubs.set(clubId, {
              id: clubId,
              name: teamName,
              display_name: teamName,
              slug: slugify(teamName)
            });
          }

          // Store sport division
          if (!sportDivisions.has(sportDivId)) {
            sportDivisions.set(sportDivId, {
              id: sportDivId,
              club_id: clubId,
              sport_id: SOCCER_SPORT_ID,
              name: teamName + ' Soccer',
              display_name: teamName + ' Soccer',
              slug: slugify(teamName + '-soccer')
            });
          }

          // Store team
          teams.set(teamId, {
            id: teamId,
            name: teamName,
            division_id: sportDivId,
            league_division_id: divId,
            team_url: fullTeamUrl
          });

          // Step 3: Scrape player roster for this team
          console.error(`  Scraping roster for ${teamName}...`);
          await scrapeTeamRoster(teamId, fullTeamUrl);
        }
      }

    // Generate SQL output
    generateSQL();

  } catch (error) {
    console.error('Error scraping APSL:', error.message);
    process.exit(1);
  }
}

// Scrape individual team roster
async function scrapeTeamRoster(teamId, teamUrl) {
  try {
    const html = await fetchHTML(teamUrl);
    const dom = new JSDOM(html);
    const doc = dom.window.document;

    // Find all tables on the page
    const tables = doc.querySelectorAll('table');
    let playerRows = [];
    
    // Look for the table containing "added:" text (roster table)
    for (const table of tables) {
      const tableText = table.textContent.toLowerCase();
      if (tableText.includes('added:')) {
        playerRows = Array.from(table.querySelectorAll('tr'));
        break;
      }
    }

    if (playerRows.length === 0) {
      console.error(`    No roster found for ${teamUrl}`);
      return;
    }
    
    for (const row of playerRows) {
      const cells = row.querySelectorAll('td');
      if (cells.length < 2) continue;

      // APSL roster structure:
      // Cell 0: Photo
      // Cell 1: Player name in a div + "added:" date
      // Cell 2: Jersey number
      // Cell 3: (empty or other info)
      
      // Look for player name in a div with style="font-size:12px;line-height:1;"
      const nameDiv = cells[1]?.querySelector('div[style*="font-size:12px"]');
      const playerName = nameDiv?.textContent.trim();
      
      // Get jersey number from cell 2
      const jerseyNum = cells[2]?.textContent.trim() || null;
      
      const position = null; // APSL doesn't provide positions in roster
      
      if (!playerName || playerName.toLowerCase() === 'player') continue;

      // Generate IDs
      const userId = generateUUID('0006', playerName + teamId);
      const playerId = userId;
      const teamPlayerId = generateUUID('0007', teamId + userId);

      // Generate email from name + team (to handle duplicate names across teams)
      const teamSlug = teams.get(teamId)?.slug || teamId.substring(0, 8);
      const email = slugify(playerName).replace(/-/g, '.') + '.' + teamSlug + '@apsl.player';
      const password = generatePassword();

      // Store user
      if (!users.has(userId)) {
        users.set(userId, {
          id: userId,
          email: email,
          name: playerName,
          password: password
        });

        // Store player
        players.set(playerId, {
          id: playerId,
          position: position
        });
      }

      // Store team_player relationship
      const tpKey = `${teamId}-${playerId}`;
      if (!teamPlayers.has(tpKey)) {
        teamPlayers.set(tpKey, {
          id: teamPlayerId,
          team_id: teamId,
          player_id: playerId,
          jersey_number: jerseyNum ? parseInt(jerseyNum) : null,
          position: position
        });
      }
    }

    console.error(`    Found ${playerRows.length} players`);

  } catch (error) {
    console.error(`    Error scraping roster from ${teamUrl}:`, error.message);
  }
}

// Generate SQL output
function generateSQL() {
  console.log('\n-- ========================================');
  console.log('-- LEAGUE STRUCTURE');
  console.log('-- ========================================\n');

  // Insert league
  console.log('-- APSL League');
  console.log(`INSERT INTO leagues (id, name, display_name, sport_id, season, website, is_active)`);
  console.log(`VALUES (${sqlEscape(APSL_LEAGUE_ID)}, 'APSL', 'American Premier Soccer League', ${sqlEscape(SOCCER_SPORT_ID)}, '2024-2025', 'https://apslsoccer.com', true)`);
  console.log(`ON CONFLICT (id) DO UPDATE SET`);
  console.log(`  display_name = EXCLUDED.display_name,`);
  console.log(`  website = EXCLUDED.website,`);
  console.log(`  updated_at = CURRENT_TIMESTAMP;\n`);

  // Insert conferences
  console.log('-- Conferences');
  for (const conf of conferences.values()) {
    console.log(`INSERT INTO league_conferences (id, league_id, name, display_name, slug, is_active)`);
    console.log(`VALUES (${sqlEscape(conf.id)}, ${sqlEscape(conf.league_id)}, ${sqlEscape(conf.name)}, ${sqlEscape(conf.display_name)}, ${sqlEscape(conf.slug)}, true)`);
    console.log(`ON CONFLICT (id) DO UPDATE SET`);
    console.log(`  name = EXCLUDED.name,`);
    console.log(`  display_name = EXCLUDED.display_name,`);
    console.log(`  updated_at = CURRENT_TIMESTAMP;\n`);
  }

  // Insert divisions
  console.log('-- League Divisions');
  for (const div of divisions.values()) {
    console.log(`INSERT INTO league_divisions (id, conference_id, name, display_name, slug, tier, is_active)`);
    console.log(`VALUES (${sqlEscape(div.id)}, ${sqlEscape(div.conference_id)}, ${sqlEscape(div.name)}, ${sqlEscape(div.display_name)}, ${sqlEscape(div.slug)}, ${div.tier}, true)`);
    console.log(`ON CONFLICT (id) DO UPDATE SET`);
    console.log(`  name = EXCLUDED.name,`);
    console.log(`  display_name = EXCLUDED.display_name,`);
    console.log(`  tier = EXCLUDED.tier,`);
    console.log(`  updated_at = CURRENT_TIMESTAMP;\n`);
  }

  // Insert clubs
  console.log('\n-- ========================================');
  console.log('-- CLUBS');
  console.log('-- ========================================\n');
  for (const club of clubs.values()) {
    console.log(`INSERT INTO clubs (id, name, display_name, slug, is_active)`);
    console.log(`VALUES (${sqlEscape(club.id)}, ${sqlEscape(club.name)}, ${sqlEscape(club.display_name)}, ${sqlEscape(club.slug)}, true)`);
    console.log(`ON CONFLICT (id) DO UPDATE SET`);
    console.log(`  name = EXCLUDED.name,`);
    console.log(`  display_name = EXCLUDED.display_name,`);
    console.log(`  updated_at = CURRENT_TIMESTAMP;\n`);
  }

  // Insert sport divisions
  console.log('-- Sport Divisions');
  for (const sd of sportDivisions.values()) {
    console.log(`INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)`);
    console.log(`VALUES (${sqlEscape(sd.id)}, ${sqlEscape(sd.club_id)}, ${sqlEscape(sd.sport_id)}, ${sqlEscape(sd.name)}, ${sqlEscape(sd.display_name)}, ${sqlEscape(sd.slug)}, true)`);
    console.log(`ON CONFLICT (id) DO UPDATE SET`);
    console.log(`  name = EXCLUDED.name,`);
    console.log(`  display_name = EXCLUDED.display_name,`);
    console.log(`  updated_at = CURRENT_TIMESTAMP;\n`);
  }

  // Insert teams
  console.log('-- Teams');
  for (const team of teams.values()) {
    console.log(`INSERT INTO teams (id, name, division_id, league_division_id, season, is_active)`);
    console.log(`VALUES (${sqlEscape(team.id)}, ${sqlEscape(team.name)}, ${sqlEscape(team.division_id)}, ${sqlEscape(team.league_division_id)}, '2024-2025', true)`);
    console.log(`ON CONFLICT (id) DO UPDATE SET`);
    console.log(`  name = EXCLUDED.name,`);
    console.log(`  league_division_id = EXCLUDED.league_division_id,`);
    console.log(`  updated_at = CURRENT_TIMESTAMP;\n`);
  }

  // Insert users
  console.log('\n-- ========================================');
  console.log('-- USERS (PLAYERS)');
  console.log('-- ========================================\n');
  console.log('-- Note: Passwords are bcrypt-hashed. Default pattern: Player[random]!');
  console.log('-- Players should reset passwords on first login.\n');

  for (const user of users.values()) {
    console.log(`INSERT INTO users (id, email, name, password_hash, is_active)`);
    console.log(`VALUES (`);
    console.log(`  ${sqlEscape(user.id)},`);
    console.log(`  ${sqlEscape(user.email)},`);
    console.log(`  ${sqlEscape(user.name)},`);
    console.log(`  crypt(${sqlEscape(user.password)}, gen_salt('bf')),`);
    console.log(`  true`);
    console.log(`)`);
    console.log(`ON CONFLICT (email) DO UPDATE SET`);
    console.log(`  name = EXCLUDED.name,`);
    console.log(`  updated_at = CURRENT_TIMESTAMP;\n`);
  }

  // Insert players
  console.log('-- Player Entities');
  for (const player of players.values()) {
    console.log(`INSERT INTO players (id, notes)`);
    console.log(`VALUES (${sqlEscape(player.id)}, 'APSL player - position: ${player.position || 'not specified'}')`);
    console.log(`ON CONFLICT (id) DO UPDATE SET`);
    console.log(`  notes = EXCLUDED.notes;\n`);
  }

  // Insert team_players
  console.log('-- Team Rosters');
  for (const tp of teamPlayers.values()) {
    console.log(`INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)`);
    console.log(`VALUES (${sqlEscape(tp.id)}, ${sqlEscape(tp.team_id)}, ${sqlEscape(tp.player_id)}, ${tp.jersey_number || 'NULL'}, true)`);
    console.log(`ON CONFLICT (team_id, player_id) DO UPDATE SET`);
    console.log(`  jersey_number = EXCLUDED.jersey_number,`);
    console.log(`  is_active = EXCLUDED.is_active;\n`);
  }

  // Summary
  console.log('\n-- ========================================');
  console.log('-- SCRAPE SUMMARY');
  console.log('-- ========================================');
  console.log(`-- Conferences: ${conferences.size}`);
  console.log(`-- Divisions: ${divisions.size}`);
  console.log(`-- Clubs: ${clubs.size}`);
  console.log(`-- Teams: ${teams.size}`);
  console.log(`-- Players: ${players.size}`);
  console.log(`-- Total User Accounts Created: ${users.size}`);
  console.log('-- ========================================\n');
}

// Run scraper
scrapeAPSL().then(() => {
  console.error('\n✓ Scraping complete!');
}).catch(error => {
  console.error('\n✗ Scraping failed:', error);
  process.exit(1);
});
