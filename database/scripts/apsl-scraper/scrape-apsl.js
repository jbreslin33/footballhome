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
 *   - clubs/01-clubs.sql
 *   - clubs/02-divisions.sql
 *   - teams/02-apsl-teams.sql
 *   - users/02-apsl-users.sql
 *   - players/02-apsl-players.sql
 *   - rosters/01-rosters.sql
 * 
 * Usage:
 *   node database/scripts/apsl-scraper/scrape-apsl.js
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
const events = new Map();
const matches = new Map();

// Event type IDs (from 01-core-lookups.sql)
const MATCH_EVENT_TYPE_ID = '550e8400-e29b-41d4-a716-446655440402';
const HOME_STATUS_ID = '550e8400-e29b-41d4-a716-446655440801';
const AWAY_STATUS_ID = '550e8400-e29b-41d4-a716-446655440802';

// System user for creating events (James Breslin - admin)
const SYSTEM_USER_ID = '77d77471-1250-47e0-81ab-d4626595d63c';

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
          
          // Extract APSL team ID from URL (e.g., /APSL/Team/114822)
          const apslIdMatch = teamUrl.match(/\/Team\/(\d+)/);
          const apslTeamId = apslIdMatch ? apslIdMatch[1] : null;

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
            team_url: fullTeamUrl,
            apsl_team_id: apslTeamId
          });

          // Step 3: Scrape player roster for this team
          console.error(`  Scraping roster for ${teamName}...`);
          await scrapeTeamRoster(teamId, fullTeamUrl);
        }
      }

    // Step 4: Scrape fixtures/schedule
    await scrapeFixtures();

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

      // Store user (no email/password - only scraped data)
      if (!users.has(userId)) {
        users.set(userId, {
          id: userId,
          first_name: firstName,
          last_name: lastName
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

// Scrape team schedules from individual team pages
async function scrapeFixtures() {
  console.error('\n📅 Scraping team schedules...');
  
  // Build team ID lookup by APSL team ID
  const teamIdByApslId = new Map();
  for (const [teamId, team] of teams.entries()) {
    if (team.apsl_team_id) {
      teamIdByApslId.set(team.apsl_team_id, { id: teamId, name: team.name, url: team.team_url });
    }
  }
  
  console.error(`  Built lookup map for ${teamIdByApslId.size} teams`);
  
  // Track which matches we've already added (to avoid duplicates from both teams' pages)
  const processedMatches = new Set();
  
  try {
    // Scrape schedule from each team's page
    for (const [apslId, teamData] of teamIdByApslId.entries()) {
      const teamUrl = `${BASE_URL}/APSL/Team/${apslId}`;
      console.error(`  Scraping schedule for ${teamData.name}...`);
      
      const html = await fetchHTML(teamUrl);
      const dom = new JSDOM(html);
      const doc = dom.window.document;
      
      // Find the Match Schedule table
      const tables = doc.querySelectorAll('table.Table');
      let scheduleTable = null;
      
      for (const table of tables) {
        const header = table.querySelector('th');
        if (header?.textContent.includes('Date & Time')) {
          scheduleTable = table;
          break;
        }
      }
      
      if (!scheduleTable) {
        console.error(`    ⚠ No schedule table found`);
        continue;
      }
      
      // Process each row in the schedule
      const rows = scheduleTable.querySelectorAll('tr.TableRow0, tr.TableRow1');
      let matchCount = 0;
      
      for (const row of rows) {
        const cells = row.querySelectorAll('td');
        if (cells.length < 3) continue;
        
        // Cell 0: Date & Time (e.g., "Sunday, Sep 07 - 4:30 PM")
        const dateTimeText = cells[0].textContent.trim();
        const dateMatch = dateTimeText.match(/(\w+),\s*(\w+)\s+(\d+)/);
        const timeMatch = dateTimeText.match(/(\d{1,2}:\d{2})\s*(AM|PM)/i);
        
        if (!dateMatch) continue;
        
        // Parse date - assume current season year (2025)
        const monthName = dateMatch[2];
        const day = parseInt(dateMatch[3]);
        const months = { Jan: 0, Feb: 1, Mar: 2, Apr: 3, May: 4, Jun: 5, Jul: 6, Aug: 7, Sep: 8, Oct: 9, Nov: 10, Dec: 11 };
        const month = months[monthName];
        
        // Determine year: Sep-Dec = 2025, Jan-May = 2026
        const year = month >= 8 ? 2025 : 2026;
        
        const eventDate = new Date(year, month, day);
        
        // Add time if available
        if (timeMatch) {
          let hours = parseInt(timeMatch[1].split(':')[0]);
          const minutes = parseInt(timeMatch[1].split(':')[1]);
          if (timeMatch[2].toUpperCase() === 'PM' && hours !== 12) hours += 12;
          if (timeMatch[2].toUpperCase() === 'AM' && hours === 12) hours = 0;
          eventDate.setHours(hours, minutes, 0, 0);
        }
        
        // Cell 1: Location
        const locationText = cells[1].textContent.trim().split('\n')[0].trim();
        
        // Cell 2: Match info - contains opponent link and vs/@ indicator
        const matchCell = cells[2];
        const opponentLink = matchCell.querySelector('a[href*="/APSL/Team/"]');
        if (!opponentLink) continue;
        
        const opponentApslId = opponentLink.getAttribute('href').match(/\/Team\/(\d+)/)?.[1];
        if (!opponentApslId) continue;
        
        // Determine home/away from vs (home) or @ (away)
        const vsSpan = matchCell.querySelector('span');
        const isHome = vsSpan?.textContent.trim() === 'vs';
        
        // Get opponent team data
        const opponentData = teamIdByApslId.get(opponentApslId);
        if (!opponentData) {
          // Opponent might be from another conference we haven't scraped
          continue;
        }
        
        // Determine home and away teams
        const homeTeamData = isHome ? teamData : opponentData;
        const awayTeamData = isHome ? opponentData : teamData;
        
        // Create dedup key (sorted team IDs + date to handle both teams' pages)
        const sortedIds = [homeTeamData.id, awayTeamData.id].sort();
        const dedupKey = `${sortedIds[0]}-${sortedIds[1]}-${eventDate.toISOString().split('T')[0]}`;
        
        if (processedMatches.has(dedupKey)) {
          continue; // Already processed from other team's page
        }
        processedMatches.add(dedupKey);
        
        const eventId = generateUUID('0010', dedupKey);
        
        // Cell 3: Result (if played)
        const resultCell = cells[3];
        const resultText = resultCell?.textContent.trim() || '';
        const scoreMatch = resultText.match(/\((\d+)\s*-\s*(\d+)\)/);
        const statusMatch = resultText.match(/(Win|Loss|Draw)/i);
        
        let homeScore = null;
        let awayScore = null;
        let matchStatus = 'scheduled';
        
        if (scoreMatch && statusMatch) {
          // Scores in result are from current team's perspective
          // If current team is home: first score is home, second is away
          // If current team is away: first score is away, second is home
          const firstScore = parseInt(scoreMatch[1]);
          const secondScore = parseInt(scoreMatch[2]);
          
          if (isHome) {
            homeScore = firstScore;
            awayScore = secondScore;
          } else {
            homeScore = secondScore;
            awayScore = firstScore;
          }
          matchStatus = 'completed';
        }
        
        // Store event
        events.set(eventId, {
          id: eventId,
          title: `${homeTeamData.name} vs ${awayTeamData.name}`,
          event_date: eventDate.toISOString(),
          location: locationText || null
        });
        
        // Store match with scores
        matches.set(eventId, {
          id: eventId,
          home_team_id: homeTeamData.id,
          away_team_id: awayTeamData.id,
          home_score: homeScore,
          away_score: awayScore,
          match_status: matchStatus,
          competition_name: 'APSL Regular Season'
        });
        
        matchCount++;
      }
      
      console.error(`    ✓ Found ${matchCount} matches`);
    }
    
    console.error(`\n  Total unique matches: ${events.size}`);
    
  } catch (error) {
    console.error('  Error scraping fixtures:', error.message);
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
-- Run scraper to regenerate: node database/scripts/apsl-scraper/scrape-apsl.js
-- ========================================

${content}`;
    
    fs.writeFileSync(fullPath, output);
    console.error(`  ✓ ${relativePath}`);
  }
  
  // Helper to update APSL section in existing file (preserves manual sections)
  function updateAPSLSection(relativePath, header, content) {
    const fullPath = path.join(baseDir, relativePath);
    const dir = path.dirname(fullPath);
    
    // Ensure directory exists
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    
    let existingContent = '';
    let manualSection = '';
    
    if (fs.existsSync(fullPath)) {
      existingContent = fs.readFileSync(fullPath, 'utf8');
      
      // Extract everything before the APSL section
      const apslSectionStart = existingContent.indexOf('-- ========================================\n-- APSL');
      if (apslSectionStart > 0) {
        manualSection = existingContent.substring(0, apslSectionStart);
      }
    }
    
    // Build new content: manual section + APSL section
    const apslSection = `-- ========================================
-- ${header}
-- ========================================
-- Generated: ${new Date().toISOString()}
-- Source: ${LEAGUE_URL}
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/scripts/apsl-scraper/scrape-apsl.js
-- ========================================

${content}`;
    
    const finalContent = manualSection ? manualSection + apslSection : apslSection;
    
    fs.writeFileSync(fullPath, finalContent);
    console.error(`  ✓ ${relativePath} (preserved manual sections)`);
  }
  
  // 1. LEAGUES
  let leaguesSQL = `-- APSL (American Premier Soccer League)
INSERT INTO leagues (id, name, display_name, sport_id, season, website, is_active)
VALUES (${sqlEscape(APSL_LEAGUE_ID)}, 'APSL', 'American Premier Soccer League', ${sqlEscape(SOCCER_SPORT_ID)}, '2024-2025', 'https://apslsoccer.com', true)
ON CONFLICT (id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  website = EXCLUDED.website,
  updated_at = CURRENT_TIMESTAMP;
`;
  writeFile('data/03-leagues.sql', 'LEAGUES', leaguesSQL);
  
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
  writeFile('data/04-conferences.sql', 'LEAGUE CONFERENCES', conferencesSQL);
  
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
  writeFile('data/05-league-divisions.sql', 'LEAGUE DIVISIONS', divisionsSQL);
  
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
  writeFile('data/06-clubs.sql', 'CLUBS', clubsSQL);
  
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
  writeFile('data/07-sport-divisions.sql', 'SPORT DIVISIONS', sportDivisionsSQL);
  
  // 6. TEAMS (preserve manual Lighthouse section)
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
  writeFile('data/11-teams.sql', 'TEAMS', teamsSQL);
  
  // 7. USERS (write to separate APSL file, grouped by team)
  let usersSQL = `
-- Note: Scraped users have no email/password (roster display only)
-- They cannot log in until they register with a real email

`;
  
  // Group users by team
  const usersByTeam = new Map();
  for (const tp of teamPlayers.values()) {
    const teamId = tp.team_id;
    const playerId = tp.player_id;
    const user = users.get(playerId);
    if (user) {
      if (!usersByTeam.has(teamId)) {
        usersByTeam.set(teamId, []);
      }
      usersByTeam.get(teamId).push(user);
    }
  }
  
  // Write users grouped by team
  for (const [teamId, teamUsers] of usersByTeam.entries()) {
    const team = teams.get(teamId);
    if (team) {
      usersSQL += `-- ========================================
-- ${team.name} USERS
-- ========================================
`;
      for (const user of teamUsers) {
        usersSQL += `INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  ${sqlEscape(user.id)},
  ${sqlEscape(user.first_name)},
  ${sqlEscape(user.last_name)},
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

`;
      }
      usersSQL += '\n';
    }
  }
  writeFile('data/08b-users-apsl.sql', 'PLAYER USERS', usersSQL);
  
  // 8. PLAYERS (write to separate file, grouped by team)
  let playersSQL = `

`;
  
  // Group players by team
  const playersByTeam = new Map();
  for (const tp of teamPlayers.values()) {
    const teamId = tp.team_id;
    const playerId = tp.player_id;
    const player = players.get(playerId);
    if (player) {
      if (!playersByTeam.has(teamId)) {
        playersByTeam.set(teamId, []);
      }
      playersByTeam.get(teamId).push(player);
    }
  }
  
  // Write players grouped by team
  for (const [teamId, teamPlayersArr] of playersByTeam.entries()) {
    const team = teams.get(teamId);
    if (team) {
      playersSQL += `-- ========================================
-- ${team.name} PLAYERS
-- ========================================
`;
      for (const player of teamPlayersArr) {
        playersSQL += `INSERT INTO players (id, notes)
VALUES (${sqlEscape(player.id)}, 'APSL player - position: ${player.position || 'not specified'}')
ON CONFLICT (id) DO UPDATE SET
  notes = EXCLUDED.notes;

`;
      }
      playersSQL += '\n';
    }
  }
  writeFile('data/13b-players-apsl.sql', 'PLAYERS', playersSQL);
  
  // 9. ROSTERS (grouped by team)
  let rostersSQL = '';
  
  // Group rosters by team
  const rostersByTeam = new Map();
  for (const tp of teamPlayers.values()) {
    const teamId = tp.team_id;
    if (!rostersByTeam.has(teamId)) {
      rostersByTeam.set(teamId, []);
    }
    rostersByTeam.get(teamId).push(tp);
  }
  
  // Write rosters grouped by team
  for (const [teamId, roster] of rostersByTeam.entries()) {
    const team = teams.get(teamId);
    if (team) {
      rostersSQL += `-- ========================================
-- ${team.name} ROSTER
-- ========================================
`;
      for (const tp of roster) {
        rostersSQL += `INSERT INTO team_players (id, team_id, player_id, jersey_number, is_active)
VALUES (${sqlEscape(tp.id)}, ${sqlEscape(tp.team_id)}, ${sqlEscape(tp.player_id)}, ${tp.jersey_number || 'NULL'}, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  is_active = EXCLUDED.is_active;

`;
      }
      rostersSQL += '\n';
    }
  }
  writeFile('data/14-rosters.sql', 'ROSTERS', rostersSQL);
  
  // 10. EVENTS (matches from fixtures)
  let eventsSQL = `
-- Note: Events are scraped from APSL fixtures page
-- Deduplication key: home_team + away_team + event_date

`;
  
  for (const event of events.values()) {
    eventsSQL += `INSERT INTO events (id, created_by, event_type_id, title, event_date, duration_minutes)
VALUES (
  ${sqlEscape(event.id)},
  ${sqlEscape(SYSTEM_USER_ID)},
  ${sqlEscape(MATCH_EVENT_TYPE_ID)},
  ${sqlEscape(event.title)},
  ${sqlEscape(event.event_date)},
  120
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  event_date = EXCLUDED.event_date,
  updated_at = CURRENT_TIMESTAMP;

`;
  }
  writeFile('data/15-events.sql', 'EVENTS (APSL MATCHES)', eventsSQL);
  
  // 11. MATCHES (extends events with team details)
  let matchesSQL = `
-- Note: Matches extend events with home/away team details
-- Includes scores for completed matches

`;
  
  for (const match of matches.values()) {
    const homeScore = match.home_score !== null ? match.home_score : 'NULL';
    const awayScore = match.away_score !== null ? match.away_score : 'NULL';
    
    matchesSQL += `INSERT INTO matches (id, home_team_id, away_team_id, home_away_status_id, competition_name, match_status, home_team_score, away_team_score)
VALUES (
  ${sqlEscape(match.id)},
  ${sqlEscape(match.home_team_id)},
  ${sqlEscape(match.away_team_id)},
  ${sqlEscape(HOME_STATUS_ID)},
  ${sqlEscape(match.competition_name)},
  ${sqlEscape(match.match_status)},
  ${homeScore},
  ${awayScore}
)
ON CONFLICT (id) DO UPDATE SET
  competition_name = EXCLUDED.competition_name,
  match_status = EXCLUDED.match_status,
  home_team_score = EXCLUDED.home_team_score,
  away_team_score = EXCLUDED.away_team_score;

`;
  }
  writeFile('data/16-matches.sql', 'MATCHES (APSL)', matchesSQL);
  
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
  console.error(`Matches: ${matches.size}`);
  console.error('========================================\n');
}

// Run scraper
scrapeAPSL().then(() => {
  console.error('\n✓ Scraping complete!');
}).catch(error => {
  console.error('\n✗ Scraping failed:', error);
  process.exit(1);
});
