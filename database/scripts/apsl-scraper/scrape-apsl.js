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

// Handle uncaught errors from network requests gracefully
// This prevents the scraper from crashing on transient network errors
process.on('uncaughtException', (err) => {
  if (err.code === 'ECONNRESET' || err.syscall === 'read') {
    console.error(`      ⚠️  Network error (will retry): ${err.message}`);
    // Don't exit - let the retry logic handle it
  } else {
    // Re-throw other types of errors
    console.error('Fatal error:', err);
    process.exit(1);
  }
});

// Configuration
const BASE_URL = 'https://apslsoccer.com';
const LEAGUE_URL = `${BASE_URL}/standings/`;
const SOCCER_SPORT_ID = '550e8400-e29b-41d4-a716-446655440101';
const APSL_LEAGUE_ID = '00000000-0000-0000-0001-000000000001';
const LOGOS_DIR = path.join(__dirname, '../../../frontend/images/teams/logos');
const HEADSHOTS_DIR = path.join(__dirname, '../../../frontend/images/players/headshots');

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

// TeamPass authentication cookies (set by login())
let authCookies = '';

// Helper: Create safe filename from team name
function teamNameToFilename(teamName) {
  return teamName
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

// Helper: Download image from URL and save to disk
async function downloadLogo(url, teamName) {
  if (!url) return null;
  
  const filename = `${teamNameToFilename(teamName)}.png`;
  const filepath = path.join(LOGOS_DIR, filename);
  
  // Create logos directory if it doesn't exist
  if (!fs.existsSync(LOGOS_DIR)) {
    fs.mkdirSync(LOGOS_DIR, { recursive: true });
  }

  return new Promise((resolve, reject) => {
    // Determine protocol
    const client = url.startsWith('https') ? https : require('http');
    
    const maxRetries = 3;
    let attempts = 0;

    const executeDownload = () => {
      attempts++;
      
      const request = client.get(url);
      
      // Attach request error handler IMMEDIATELY
      request.on('error', (err) => {
        if (attempts < maxRetries) {
          console.error(`      Retrying download for ${filename} (attempt ${attempts}/${maxRetries}): ${err.message}`);
          setTimeout(executeDownload, 1000 * attempts); // Exponential backoff
        } else {
          console.error(`      ✗ Failed to download ${filename} after ${maxRetries} attempts: ${err.message}`);
          resolve(null); // Resolve with null on final failure
        }
      });
      
      request.on('response', (response) => {
        if (response.statusCode === 200) {
          const fileStream = fs.createWriteStream(filepath);
          
          // Attach error handlers BEFORE piping
          response.on('error', (err) => {
            fileStream.destroy();
            fs.unlink(filepath, () => {}); // Delete partial file
            if (attempts < maxRetries) {
              console.error(`      Retrying download for ${filename} (attempt ${attempts}/${maxRetries}): ${err.message}`);
              setTimeout(executeDownload, 1000 * attempts); // Exponential backoff
            } else {
              console.error(`      ✗ Failed to download ${filename} after ${maxRetries} attempts: ${err.message}`);
              resolve(null); // Resolve with null on final failure
            }
          });
          
          fileStream.on('error', (err) => {
            fs.unlink(filepath, () => {}); // Delete partial file
            if (attempts < maxRetries) {
              console.error(`      Retrying download for ${filename} (attempt ${attempts}/${maxRetries}): ${err.message}`);
              setTimeout(executeDownload, 1000 * attempts); // Exponential backoff
            } else {
              console.error(`      ✗ Failed to download ${filename} after ${maxRetries} attempts: ${err.message}`);
              resolve(null); // Resolve with null on final failure
            }
          });
          
          fileStream.on('finish', () => {
            fileStream.close();
            resolve(`/images/teams/logos/${filename}`); // Return web path
          });
          
          // Now pipe
          response.pipe(fileStream);
        } else {
          resolve(null); // Return null on non-200 status
        }
      });
    };
    executeDownload();
  });
}

// Helper: Download player headshot from URL and save to disk
async function downloadHeadshot(url, playerName, playerId) {
  if (!url) return null;
  
  // Use UUID for filename to avoid name collisions
  const filename = `${playerId}.png`;
  const filepath = path.join(HEADSHOTS_DIR, filename);
  
  // Create headshots directory if it doesn't exist
  if (!fs.existsSync(HEADSHOTS_DIR)) {
    fs.mkdirSync(HEADSHOTS_DIR, { recursive: true });
  }

  return new Promise((resolve, reject) => {
    // Determine protocol
    const client = url.startsWith('https') ? https : require('http');
    
    const maxRetries = 3;
    let attempts = 0;

    const executeDownload = () => {
      attempts++;
      
      const request = client.get(url);
      
      // Attach request error handler IMMEDIATELY
      request.on('error', (err) => {
        if (attempts < maxRetries) {
          console.error(`      Retrying download for ${filename} (attempt ${attempts}/${maxRetries}): ${err.message}`);
          setTimeout(executeDownload, 1000 * attempts); // Exponential backoff
        } else {
          console.error(`      ✗ Failed to download ${filename} after ${maxRetries} attempts: ${err.message}`);
          resolve(null); // Resolve with null on final failure
        }
      });
      
      request.on('response', (response) => {
        if (response.statusCode === 200) {
          const fileStream = fs.createWriteStream(filepath);
          
          // Attach error handlers BEFORE piping
          response.on('error', (err) => {
            fileStream.destroy();
            fs.unlink(filepath, () => {}); // Delete partial file
            if (attempts < maxRetries) {
              console.error(`      Retrying download for ${filename} (attempt ${attempts}/${maxRetries}): ${err.message}`);
              setTimeout(executeDownload, 1000 * attempts); // Exponential backoff
            } else {
              console.error(`      ✗ Failed to download ${filename} after ${maxRetries} attempts: ${err.message}`);
              resolve(null); // Resolve with null on final failure
            }
          });
          
          fileStream.on('error', (err) => {
            fs.unlink(filepath, () => {}); // Delete partial file
            if (attempts < maxRetries) {
              console.error(`      Retrying download for ${filename} (attempt ${attempts}/${maxRetries}): ${err.message}`);
              setTimeout(executeDownload, 1000 * attempts); // Exponential backoff
            } else {
              console.error(`      ✗ Failed to download ${filename} after ${maxRetries} attempts: ${err.message}`);
              resolve(null); // Resolve with null on final failure
            }
          });
          
          fileStream.on('finish', () => {
            fileStream.close();
            resolve(`/images/players/headshots/${filename}`); // Return web path
          });
          
          // Now pipe
          response.pipe(fileStream);
        } else {
          resolve(null); // Return null on non-200 status
        }
      });
    };
    executeDownload();
  });
}

// Helper: Login to TeamPass to access reserve rosters
async function loginToTeamPass() {
  const querystring = require('querystring');
  
  // Check for credentials in environment, fallback to development defaults
  // WARNING: Development credentials only - override with TEAMPASS_USER/TEAMPASS_PASS for production
  const username = process.env.TEAMPASS_USER || 'soccer@lighthouse1893.org';
  const password = process.env.TEAMPASS_PASS || '1893Soccer!';
  
  console.error('🔐 Logging into TeamPass...');
  
  // Step 1: Get initial session cookies
  const initCookies = await new Promise((resolve, reject) => {
    https.get('https://app.teampass.com/reg/login/', (res) => {
      const cookies = res.headers['set-cookie'] || [];
      resolve(cookies.map(c => c.split(';')[0]).join('; '));
    }).on('error', reject);
  });
  
  // Step 2: Login - MUST include Update_Account=Update button name
  const postData = querystring.stringify({
    'Reg.Login.Action': 'VerifyUser',
    'folder.contentid': '0',
    'Reg_Pass_Folder': '0',
    'form_Login_idValue': '0',
    'form_Login_rowCount': '1',
    'form_Login_newrowCount': '1',
    'form_Login_UserName': username,
    'form_Login_Password': password,
    'Update_Account': 'Update'
  });
  
  const loginResult = await new Promise((resolve, reject) => {
    const req = https.request({
      hostname: 'app.teampass.com',
      path: '/Reg/Login/index.cfm',
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(postData),
        'Cookie': initCookies,
        'Origin': 'https://app.teampass.com',
        'Referer': 'https://app.teampass.com/reg/login/'
      }
    }, (res) => {
      const newCookies = res.headers['set-cookie'] || [];
      
      // Merge all cookies
      const cookieMap = {};
      initCookies.split('; ').forEach(c => {
        const [k, v] = c.split('=');
        if (k && v) cookieMap[k] = v;
      });
      newCookies.forEach(c => {
        const parts = c.split(';')[0].split('=');
        if (parts.length >= 2) cookieMap[parts[0]] = parts.slice(1).join('=');
      });
      
      const allCookies = Object.entries(cookieMap).map(([k,v]) => k+'='+v).join('; ');
      const success = newCookies.some(c => c.includes('NETAPPS.USER.ID'));
      
      resolve({ success, cookies: allCookies });
    });
    req.write(postData);
    req.end();
  });
  
  if (loginResult.success) {
    authCookies = loginResult.cookies;
    console.error('✓ Logged into TeamPass successfully');
    console.error('  Reserve rosters will be included.');
    return true;
  } else {
    console.error('✗ TeamPass login failed');
    return false;
  }
}

// Helper: Fetch HTML from URL (with optional auth)
function fetchHTML(url) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    };
    
    if (authCookies) {
      headers['Cookie'] = authCookies;
    }
    
    const options = {
      hostname: urlObj.hostname,
      path: urlObj.pathname + urlObj.search,
      headers
    };

    const maxRetries = 3;
    let attempts = 0;

    const executeFetch = () => {
      attempts++;
      https.get(options, (res) => {
        let data = '';
        res.on('data', (chunk) => { data += chunk; });
        res.on('end', () => resolve(data));
      }).on('error', (err) => {
        if (attempts < maxRetries) {
          console.error(`      Retrying fetch for ${url} (attempt ${attempts}/${maxRetries}): ${err.message}`);
          setTimeout(executeFetch, 1000 * attempts); // Exponential backoff
        } else {
          console.error(`      ✗ Failed to fetch ${url} after ${maxRetries} attempts: ${err.message}`);
          resolve(null); // Resolve with null on final failure
        }
      });
    };
    executeFetch();
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

// Helper: Format date as EST timezone string for TIMESTAMPTZ
// APSL is a Pennsylvania league, all times are Eastern Time
function formatDateEST(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');
  const seconds = String(date.getSeconds()).padStart(2, '0');
  // Format: 2025-12-02 20:30:00-05 (EST is UTC-5, EDT is UTC-4)
  // Use America/New_York offset based on date
  const isDST = isDaylightSavingTime(date);
  const offset = isDST ? '-04' : '-05';
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}${offset}`;
}

// Helper: Check if date is in DST (rough approximation for US Eastern)
function isDaylightSavingTime(date) {
  const jan = new Date(date.getFullYear(), 0, 1);
  const jul = new Date(date.getFullYear(), 6, 1);
  const stdOffset = Math.max(jan.getTimezoneOffset(), jul.getTimezoneOffset());
  return date.getTimezoneOffset() < stdOffset;
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
    // Try to login for reserve roster access
    await loginToTeamPass();
    
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
  }
}

// Scrape individual team roster
async function scrapeTeamRoster(teamId, teamUrl) {
  try {
    const html = await fetchHTML(teamUrl);
    if (html === null) {
      console.error(`    ✗ Failed to fetch HTML for roster from ${teamUrl}`);
      return; // Skip this team if HTML fetch failed after retries
    }
    const dom = new JSDOM(html);
    const doc = dom.window.document;
    
    // Extract team logo - look for img with max-height:130px that's NOT the header_logo
    const logoImages = doc.querySelectorAll('img[style*="max-height:130px"]');
    let logoUrl = null;
    let localLogoPath = null;
    
    for (const img of logoImages) {
      // Skip the header_logo (APSL league logo)
      if (img.id === 'header_logo') continue;
      
      const src = img.getAttribute('src');
      if (src && src.includes('/mediacontent/')) {
        // Convert relative URL to absolute
        logoUrl = src.startsWith('http') ? src : 'https://app.teampass.com' + src;
        
        // Download logo and get local path
        const team = teams.get(teamId);
        if (team) {
          console.error(`    Found logo: ${logoUrl}`);
          console.error(`    Downloading logo...`);
          localLogoPath = await downloadLogo(logoUrl, team.name);
          
          if (localLogoPath) {
            team.logo_url = localLogoPath;
            console.error(`    ✓ Saved to: ${localLogoPath}`);
          } else {
            console.error(`    ✗ Failed to download logo`);
            team.logo_url = logoUrl; // Fallback to external URL
          }
        }
        break;
      }
    }

    // Find roster tables with TableRoster class (more specific selector)
    // This finds Active, Reserve, and Inactive rosters when authenticated
    const rosterTables = doc.querySelectorAll('table.TableRoster');
    let allPlayerRows = [];
    let mainRosterCount = 0;
    let reserveRosterCount = 0;
    let inactiveSkipped = 0;
    
    console.error(`    Found ${rosterTables.length} roster table(s)`);
    
    // Process each roster table
    for (const table of rosterTables) {
      // Walk UP through DOM to find the h2 header for this section
      let sectionType = 'main';
      let current = table;
      let found = false;
      
      while (current && !found) {
        let prev = current.previousElementSibling;
        while (prev) {
          if (prev.tagName === 'H2') {
            const headerText = prev.textContent.toLowerCase();
            if (headerText.includes('inactive')) {
              sectionType = 'inactive';
            } else if (headerText.includes('reserve')) {
              sectionType = 'reserve';
            }
            found = true;
            break;
          }
          prev = prev.previousElementSibling;
        }
        if (!found) {
          current = current.parentElement;
        }
      }
      
      const rows = Array.from(table.querySelectorAll('tr'));
      const playerRows = rows.filter(r => r.textContent.includes('added:'));
      
      // Skip inactive roster players
      if (sectionType === 'inactive') {
        inactiveSkipped += playerRows.length;
        console.error(`    Skipping ${playerRows.length} inactive player(s)`);
        continue;
      }
      
      if (sectionType === 'reserve') {
        reserveRosterCount += playerRows.length;
        console.error(`    Found ${playerRows.length} reserve player(s)`);
      } else {
        mainRosterCount += playerRows.length;
        console.error(`    Found ${playerRows.length} main roster player(s)`);
      }
      
      allPlayerRows = allPlayerRows.concat(playerRows);
    }
    
    // Fallback: if no TableRoster tables, look for any table with "added:" text
    if (rosterTables.length === 0) {
      console.error(`    No TableRoster found, trying fallback...`);
      const allTables = doc.querySelectorAll('table');
      for (const table of allTables) {
        if (table.textContent.includes('added:')) {
          const rows = Array.from(table.querySelectorAll('tr'));
          allPlayerRows = rows.filter(r => r.textContent.includes('added:'));
          mainRosterCount = allPlayerRows.length;
          console.error(`    Fallback found ${mainRosterCount} player(s)`);
          break;
        }
      }
    }

    if (allPlayerRows.length === 0) {
      console.error(`    No roster found for ${teamUrl}`);
      return;
    }
    
    console.error(`    Total: ${mainRosterCount} main + ${reserveRosterCount} reserve = ${allPlayerRows.length} (skipped ${inactiveSkipped} inactive)`)
    
    let playersAdded = 0;
    for (const row of allPlayerRows) {
      const cells = row.querySelectorAll('td');
      if (cells.length < 2) continue;

      // APSL roster structure:
      // Cell 0: Photo
      // Cell 1: Player name in a div + "added:" date
      // Cell 2: Jersey number
      // Cell 3: (empty or other info)
      
      // Extract player photo from Cell 0
      const photoImg = cells[0]?.querySelector('img');
      let photoUrl = null;
      if (photoImg) {
        const src = photoImg.getAttribute('src');
        if (src && src.includes('/mediacontent/')) {
          photoUrl = src.startsWith('http') ? src : 'https://app.teampass.com' + src;
        }
      }
      
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
        // Download player headshot if available
        let localPhotoPath = null;
        if (photoUrl) {
          try {
            localPhotoPath = await downloadHeadshot(photoUrl, playerName, playerId);
          } catch (err) {
            console.error(`      ✗ Failed to download headshot for ${playerName}:`, err.message);
          }
        }

        users.set(userId, {
          id: userId,
          first_name: firstName,
          last_name: lastName,
          avatar_url: localPhotoPath
        });

        // Store player
        players.set(playerId, {
          id: playerId,
          position: position,
          photo_url: localPhotoPath
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
        playersAdded++;
      }
    }

    // Log roster stats
    let logMsg = `    Found ${playersAdded} players`;
    if (reserveRosterCount > 0 || inactiveSkipped > 0) {
      const parts = [`${mainRosterCount} main`];
      if (reserveRosterCount > 0) parts.push(`${reserveRosterCount} reserve`);
      if (inactiveSkipped > 0) parts.push(`${inactiveSkipped} inactive skipped`);
      logMsg += ` (${parts.join(', ')})`;
    }
    console.error(logMsg);

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
          event_date: formatDateEST(eventDate),
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

// Convert INSERT statements to PostgreSQL COPY format
function convertInsertToCopy(sqlContent, header) {
  const copyHeader = `-- ========================================
-- ${header}
-- ========================================
-- Generated: ${new Date().toISOString()}
-- Source: ${LEAGUE_URL}
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/scripts/apsl-scraper/scrape-apsl.js
-- ========================================

`;

  // Parse INSERT statements and convert to COPY
  // Updated regex to handle multi-row INSERTs with VALUES\n(...),\n(...)
  const insertRegex = /INSERT INTO (\w+) \(([^)]+)\)\s*VALUES\s*([\s\S]+?)(?:ON CONFLICT[\s\S]+?)?;/gi;
  
  const tableData = new Map();
  let match;
  
  while ((match = insertRegex.exec(sqlContent)) !== null) {
    const tableName = match[1];
    const columns = match[2];
    const valuesBlock = match[3].trim();
    
    // Parse multi-row VALUES: (row1), (row2), (row3)
    // Handle both single-line and multi-line formats
    // Parse rows manually to respect quote boundaries
    const rows = [];
    let i = 0;
    
    while (i < valuesBlock.length) {
      // Skip whitespace and commas
      while (i < valuesBlock.length && /[\s,]/.test(valuesBlock[i])) i++;
      if (i >= valuesBlock.length) break;
      
      // Expect opening paren
      if (valuesBlock[i] !== '(') break;
      i++;
      
      // Extract content until matching closing paren (respecting quotes)
      let rowContent = '';
      let inQuote = false;
      let quoteChar = null;
      let parenDepth = 0;
      
      while (i < valuesBlock.length) {
        const char = valuesBlock[i];
        
        if (!inQuote && (char === "'" || char === '"')) {
          inQuote = true;
          quoteChar = char;
          rowContent += char;
          i++;
          continue;
        }
        
        if (inQuote && char === quoteChar) {
          // Check for escaped quote
          if (i + 1 < valuesBlock.length && valuesBlock[i + 1] === quoteChar) {
            rowContent += char + char;
            i += 2;
            continue;
          }
          inQuote = false;
          quoteChar = null;
          rowContent += char;
          i++;
          continue;
        }
        
        if (!inQuote) {
          if (char === '(') parenDepth++;
          if (char === ')') {
            if (parenDepth === 0) {
              i++; // Skip closing paren
              break;
            }
            parenDepth--;
          }
        }
        
        rowContent += char;
        i++;
      }
      
      rows.push(rowContent);
    }
    
    for (const valuesStr of rows) {
      
      // Parse values - handle quoted strings, NULLs, and nested content
      const values = [];
      let current = '';
      let inQuote = false;
      let quoteChar = null;
      let parenDepth = 0;
      
      for (let i = 0; i < valuesStr.length; i++) {
        const char = valuesStr[i];
        
        // Track parentheses depth for nested content (like ARRAY or function calls)
        if (!inQuote) {
          if (char === '(') parenDepth++;
          if (char === ')') parenDepth--;
        }
        
        if (!inQuote && (char === "'" || char === '"')) {
          inQuote = true;
          quoteChar = char;
          continue;
        }
        
        if (inQuote && char === quoteChar) {
          // Check for escaped quote
          if (i + 1 < valuesStr.length && valuesStr[i + 1] === quoteChar) {
            current += char;
            i++; // Skip next char
            continue;
          }
          inQuote = false;
          quoteChar = null;
          continue;
        }
        
        // Only split on commas at depth 0 (not inside nested parens)
        if (!inQuote && char === ',' && parenDepth === 0) {
          values.push(current.trim());
          current = '';
          continue;
        }
        
        current += char;
      }
      
      if (current.trim()) {
        values.push(current.trim());
      }
      
      // Convert values to COPY format (tab-separated, \N for NULL, boolean as t/f)
      const copyValues = values.map(v => {
        const trimmed = v.trim();
        if (trimmed === 'NULL') return '\\N';
        if (trimmed === 'true') return 't';
        if (trimmed === 'false') return 'f';
        // Remove surrounding quotes if present
        return trimmed.replace(/^['"]|['"]$/g, '').replace(/\t/g, '    ');
      }).join('\t');
      
      if (!tableData.has(tableName)) {
        tableData.set(tableName, { columns, rows: [] });
      }
      tableData.get(tableName).rows.push(copyValues);
    }
  }
  
  // Build COPY output
  let copyOutput = copyHeader;
  
  for (const [tableName, data] of tableData.entries()) {
    copyOutput += `COPY ${tableName} (${data.columns}) FROM stdin;\n`;
    for (const row of data.rows) {
      copyOutput += row + '\n';
    }
    copyOutput += '\\.\n\n';
  }
  
  return copyOutput;
}

// Generate SQL output to multiple files
function generateSQL() {
  const baseDir = path.join(__dirname, '../..');
  
  console.error('\n📝 Writing SQL files...');
  
  // Delete old .copy.sql files to ensure clean regeneration
  console.error('  🗑️  Cleaning old .copy.sql files...');
  const dataDir = path.join(baseDir, 'data');
  if (fs.existsSync(dataDir)) {
    const files = fs.readdirSync(dataDir);
    let deleteCount = 0;
    for (const file of files) {
      if (file.endsWith('.copy.sql')) {
        fs.unlinkSync(path.join(dataDir, file));
        deleteCount++;
      }
    }
    console.error(`  ✓ Deleted ${deleteCount} old .copy.sql files`);
  }
  
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
    
    // Write INSERT version (.sql) - COPY disabled due to formatting issues
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
    const logoValue = team.logo_url ? sqlEscape(team.logo_url) : 'NULL';
    teamsSQL += `INSERT INTO teams (id, name, division_id, league_division_id, season, is_active, logo_url)
VALUES (${sqlEscape(team.id)}, ${sqlEscape(team.name)}, ${sqlEscape(team.division_id)}, ${sqlEscape(team.league_division_id)}, '2024-2025', true, ${logoValue})
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  league_division_id = EXCLUDED.league_division_id,
  logo_url = COALESCE(EXCLUDED.logo_url, teams.logo_url),
  updated_at = CURRENT_TIMESTAMP;

`;
  }
  writeFile('data/22-teams-apsl.sql', 'TEAMS', teamsSQL);
  
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
      
      // Generate bulk INSERT with multiple VALUES
      usersSQL += `INSERT INTO users (id, first_name, last_name, avatar_url, is_active)\nVALUES\n`;
      
      const valueRows = teamUsers.map((user, idx) => {
        const comma = idx < teamUsers.length - 1 ? ',' : '';
        return `  (${sqlEscape(user.id)}, ${sqlEscape(user.first_name)}, ${sqlEscape(user.last_name)}, ${sqlEscape(user.avatar_url)}, true)${comma}`;
      }).join('\n');
      
      usersSQL += valueRows + '\n';
      usersSQL += `ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  avatar_url = COALESCE(EXCLUDED.avatar_url, users.avatar_url),
  updated_at = CURRENT_TIMESTAMP;

`;
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
      
      // Generate bulk INSERT with multiple VALUES
      playersSQL += `INSERT INTO players (id, photo_url, notes)\nVALUES\n`;
      
      const valueRows = teamPlayersArr.map((player, idx) => {
        const playerData = players.get(player.id);
        const photoUrl = playerData?.photo_url || null;
        const comma = idx < teamPlayersArr.length - 1 ? ',' : '';
        return `  (${sqlEscape(player.id)}, ${sqlEscape(photoUrl)}, 'APSL player - position: ${player.position || 'not specified'}')${comma}`;
      }).join('\n');
      
      playersSQL += valueRows + '\n';
      playersSQL += `ON CONFLICT (id) DO UPDATE SET
  photo_url = EXCLUDED.photo_url,
  notes = EXCLUDED.notes;

`;
    }
  }
  writeFile('data/24-players-apsl.sql', 'PLAYERS', playersSQL);
  
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
      
      // Generate bulk INSERT with multiple VALUES
      // Default to 'active' status (id=1) for all scraped players
      // Coaches can later change status to 'official_inactive', 'trial', etc.
      rostersSQL += `INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)\nVALUES\n`;
      
      const valueRows = roster.map((tp, idx) => {
        const comma = idx < roster.length - 1 ? ',' : '';
        return `  (${sqlEscape(tp.id)}, ${sqlEscape(tp.team_id)}, ${sqlEscape(tp.player_id)}, ${tp.jersey_number || 'NULL'}, 1, true)${comma}`;
      }).join('\n');
      
      rostersSQL += valueRows + '\n';
      rostersSQL += `ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

`;
    }
  }
  writeFile('data/30-rosters-apsl.sql', 'ROSTERS', rostersSQL);
  
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
  // writeFile('data/15-events.sql', 'EVENTS (APSL MATCHES)', eventsSQL);  // DISABLED: Causes init to stop
  
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
  // writeFile('data/16-matches.sql', 'MATCHES (APSL)', matchesSQL);  // DISABLED: Causes init to stop
  
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
});
