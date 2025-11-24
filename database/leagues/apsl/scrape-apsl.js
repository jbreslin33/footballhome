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
 * Outputs to multiple files in standardized database structure:
 *   - leagues/01-leagues.sql
 *   - leagues/02-conferences.sql
 *   - leagues/03-divisions.sql
 *   - clubs/01-all-clubs.sql
 *   - clubs/02-sport-divisions.sql
 *   - teams/01-apsl-teams.sql
 *   - users/01-all-users.sql (appends to existing)
 *   - players/01-all-players.sql (appends to existing)
 *   - rosters/01-apsl-rosters.sql
 * 
 * Usage:
 *   node database/leagues/apsl/scrape-apsl.js
 */

const https = require('https');
const { JSDOM } = require('jsdom');
const fs = require('fs');
const path = require('path');

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

      // Parse name into first_name and last_name
      // Handle formats: "First Last", "First Middle Last", "First"
      let firstName = playerName;
      let lastName = '';
      
      const nameParts = playerName.trim().split(/\s+/);
      if (nameParts.length >= 2) {
        firstName = nameParts[0];
        lastName = nameParts.slice(1).join(' '); // Everything after first name
      }

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
          first_name: firstName,
          last_name: lastName,
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

// Generate SQL output to multiple files
function generateSQL() {
  const baseDir = path.join(__dirname, '../..');
  
  console.error('\n📝 Writing SQL files...');
  
  // Helper to write file with header
  function writeFile(relativePath, header, content) {
    const fullPath = path.join(baseDir, relativePath);
    const dir = path.dirname(fullPath);
    
    // Ensure directory exists
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    
    const output = `-- ========================================
-- ${header}
-- ========================================
-- Generated: ${new Date().toISOString()}
-- Source: ${LEAGUE_URL}
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/leagues/apsl/scrape-apsl.js
-- ========================================

${content}`;
    
    fs.writeFileSync(fullPath, output);
    console.error(`  ✓ ${relativePath}`);
  }
  
  // Helper to append to existing file
  function appendToFile(relativePath, content) {
    const fullPath = path.join(baseDir, relativePath);
    const existing = fs.existsSync(fullPath) ? fs.readFileSync(fullPath, 'utf8') : '';
    
    // Remove old APSL section if exists
    const withoutOld = existing.replace(/-- APSL [\s\S]*?(?=\n-- |$)/g, '');
    
    fs.writeFileSync(fullPath, withoutOld + '\n' + content);
    console.error(`  ✓ ${relativePath} (appended)`);
  }
  
  // 1. LEAGUES
  let leaguesSQL = `-- APSL (American Premier Soccer League)
INSERT INTO leagues (id, name, display_name, slug, sport_id, season, website, is_active)
VALUES (${sqlEscape(APSL_LEAGUE_ID)}, 'APSL', 'American Premier Soccer League', 'apsl', ${sqlEscape(SOCCER_SPORT_ID)}, '2024-2025', 'https://apslsoccer.com', true)
ON CONFLICT (id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  website = EXCLUDED.website,
  updated_at = CURRENT_TIMESTAMP;
`;
  writeFile('leagues/01-leagues.sql', 'LEAGUES', leaguesSQL);
  
  // 2. CONFERENCES
  let conferencesSQL = '';
  for (const conf of conferences.values()) {
    conferencesSQL += `INSERT INTO league_conferences (id, league_id, name, display_name, slug, is_active)
VALUES (${sqlEscape(conf.id)}, ${sqlEscape(conf.league_id)}, ${sqlEscape(conf.name)}, ${sqlEscape(conf.display_name)}, ${sqlEscape(conf.slug)}, true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

`;
  }
  writeFile('leagues/02-conferences.sql', 'LEAGUE CONFERENCES', conferencesSQL);
  
  // 3. DIVISIONS
  let divisionsSQL = '';
  for (const div of divisions.values()) {
    divisionsSQL += `INSERT INTO league_divisions (id, conference_id, name, display_name, slug, tier, is_active)
VALUES (${sqlEscape(div.id)}, ${sqlEscape(div.conference_id)}, ${sqlEscape(div.name)}, ${sqlEscape(div.display_name)}, ${sqlEscape(div.slug)}, ${div.tier}, true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  tier = EXCLUDED.tier,
  updated_at = CURRENT_TIMESTAMP;

`;
  }
  writeFile('leagues/03-divisions.sql', 'LEAGUE DIVISIONS', divisionsSQL);
  
  // 4. CLUBS
  let clubsSQL = '';
  for (const club of clubs.values()) {
    clubsSQL += `INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES (${sqlEscape(club.id)}, ${sqlEscape(club.name)}, ${sqlEscape(club.display_name)}, ${sqlEscape(club.slug)}, true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

`;
  }
  writeFile('clubs/01-all-clubs.sql', 'CLUBS', clubsSQL);
  
  // 5. SPORT DIVISIONS
  let sportDivisionsSQL = '';
  for (const sd of sportDivisions.values()) {
    sportDivisionsSQL += `INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES (${sqlEscape(sd.id)}, ${sqlEscape(sd.club_id)}, ${sqlEscape(sd.sport_id)}, ${sqlEscape(sd.name)}, ${sqlEscape(sd.display_name)}, ${sqlEscape(sd.slug)}, true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  updated_at = CURRENT_TIMESTAMP;

`;
  }
  writeFile('clubs/02-sport-divisions.sql', 'SPORT DIVISIONS', sportDivisionsSQL);
  
  // 6. TEAMS
  let teamsSQL = '';
  for (const team of teams.values()) {
    teamsSQL += `INSERT INTO teams (id, name, division_id, league_division_id, season, is_active)
VALUES (${sqlEscape(team.id)}, ${sqlEscape(team.name)}, ${sqlEscape(team.division_id)}, ${sqlEscape(team.league_division_id)}, '2024-2025', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  updated_at = CURRENT_TIMESTAMP;

`;
  }
  writeFile('teams/01-apsl-teams.sql', 'APSL TEAMS', teamsSQL);
  
  // 7. USERS (append to existing file)
  let usersSQL = `
-- ========================================
-- APSL PLAYERS
-- ========================================
-- Generated: ${new Date().toISOString()}
-- Note: Passwords are bcrypt-hashed. Default pattern: Player[random]!
-- Players should reset passwords on first login.

`;
  for (const user of users.values()) {
    usersSQL += `INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  ${sqlEscape(user.id)},
  ${sqlEscape(user.email)},
  ${sqlEscape(user.first_name)},
  ${sqlEscape(user.last_name)},
  crypt(${sqlEscape(user.password)}, gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

`;
  }
  appendToFile('users/01-all-users.sql', usersSQL);
  
  // 8. PLAYERS (append to existing file)
  let playersSQL = `
-- ========================================
-- APSL PLAYERS
-- ========================================
-- Generated: ${new Date().toISOString()}

`;
  for (const player of players.values()) {
    playersSQL += `INSERT INTO players (id, notes)
VALUES (${sqlEscape(player.id)}, 'APSL player - position: ${player.position || 'not specified'}')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes;

`;
  }
  appendToFile('players/01-all-players.sql', playersSQL);
  
  // 9. ROSTERS
  let rostersSQL = '';
  for (const tp of teamPlayers.values()) {
    rostersSQL += `INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES (${sqlEscape(tp.id)}, ${sqlEscape(tp.team_id)}, ${sqlEscape(tp.player_id)}, ${tp.jersey_number || 'NULL'}, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

`;
  }
  writeFile('rosters/01-apsl-rosters.sql', 'APSL ROSTERS', rostersSQL);
  
  // Summary
  console.error('\n========================================');
  console.error('SCRAPE SUMMARY');
  console.error('========================================');
  console.error(`Conferences: ${conferences.size}`);
  console.error(`Divisions: ${divisions.size}`);
  console.error(`Clubs: ${clubs.size}`);
  console.error(`Teams: ${teams.size}`);
  console.error(`Players: ${players.size}`);
  console.error(`Total User Accounts: ${users.size}`);
  console.error('========================================\n');
}

// Run scraper
scrapeAPSL().then(() => {
  console.error('\n✓ Scraping complete!');
}).catch(error => {
  console.error('\n✗ Scraping failed:', error);
  process.exit(1);
});
