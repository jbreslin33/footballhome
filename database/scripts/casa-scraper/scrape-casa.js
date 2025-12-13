#!/usr/bin/env node
/**
 * CASA League Scraper
 * 
 * Scrapes CASA Soccer League data.
 * 
 * MODES:
 *   structure  - Scrape Liga 1 & Liga 2 teams, standings, and schedule from website
 *   lighthouse - Scrape Lighthouse Boys Club + Old Timers rosters from Google Sheets
 *   full       - Both structure and lighthouse rosters
 * 
 * Usage:
 *   node scrape-casa.js structure
 *   node scrape-casa.js lighthouse
 *   node scrape-casa.js full
 */

const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer');

// Parse mode from command line argument
const MODE = process.argv[2] || 'full';

// Configuration
const CASA_LEAGUE_ID = '00000000-0000-0000-0001-000000000002'; // CASA ID
const SOCCER_SPORT_ID = '550e8400-e29b-41d4-a716-446655440101';

// URLs
const LIGA1_STANDINGS_URL = 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9090889';
const LIGA1_SCHEDULE_URL = 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9090889';
const LIGA2_STANDINGS_URL = 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9096430';
const LIGA2_SCHEDULE_URL = 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9096430';

const LIGA1_ROSTER_CSV = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSmsWzjTsLR81d-eQTLDM4EnaqzqUOy5OcWLy1Lna1NYVFY7gOj0nZAQdIk99e99g/pub?gid=480494399&output=csv';
const LIGA2_ROSTER_CSV = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vQsDtR6AQPgThg1105AinjkLqHMaWgQfCFJuWqfEtadH41k5OSKYZ2Hqb0N-CnO2Q/pub?gid=310279135&output=csv';

// Directories
const BASE_DIR = path.join(__dirname, '../..');
const HEADSHOTS_DIR = path.join(BASE_DIR, '../frontend/images/players/headshots');

// Data storage
const conferences = new Map();
const divisions = new Map();
const clubs = new Map();
const sportDivisions = new Map();
const teams = new Map();
const matches = new Map();
const externalIdentities = [];

// Helper: Generate deterministic UUID (v4-compliant)
function generateUUID(namespace, seed) {
  const crypto = require('crypto');
  // Combine namespace and seed
  const input = namespace + ':' + (seed || Math.random().toString());
  const hash = crypto.createHash('md5').update(input).digest('hex');
  
  // Format as UUID v4
  // xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
  const p1 = hash.substring(0, 8);
  const p2 = hash.substring(8, 12);
  const p3 = '4' + hash.substring(13, 16); // Version 4
  const p4 = '8' + hash.substring(17, 20); // Variant 10xx (8,9,a,b) - using 8 for simplicity
  const p5 = hash.substring(20, 32);
  
  return `${p1}-${p2}-${p3}-${p4}-${p5}`;
}

function slugify(text) {
  return text.toString().toLowerCase()
    .replace(/\s+/g, '-')           // Replace spaces with -
    .replace(/[^\w\-]+/g, '')       // Remove all non-word chars
    .replace(/\-\-+/g, '-')         // Replace multiple - with single -
    .replace(/^-+/, '')             // Trim - from start of text
    .replace(/-+$/, '');            // Trim - from end of text
}

function sqlEscape(str) {
  if (str === null || str === undefined) return 'NULL';
  if (typeof str === 'boolean') return str ? 'true' : 'false';
  if (typeof str === 'number') return str;
  return "'" + str.replace(/'/g, "''") + "'";
}

// Helper: Fetch URL content
function fetchURL(url) {
  return new Promise((resolve, reject) => {
    const client = url.startsWith('https') ? https : http;
    client.get(url, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        return resolve(fetchURL(res.headers.location));
      }
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data));
    }).on('error', reject);
  });
}

async function scrapeStructure() {
  console.log('Scraping CASA structure...');

  // 1. Setup League/Conference/Division structure
  const confId = generateUUID('casa', 'CASA Conference');
  conferences.set(confId, {
    id: confId,
    league_id: CASA_LEAGUE_ID,
    name: 'CASA Conference',
    display_name: 'CASA Conference',
    slug: 'casa-conference'
  });

  const liga1Id = generateUUID('casa', 'Liga 1');
  divisions.set(liga1Id, {
    id: liga1Id,
    conference_id: confId,
    name: 'Liga 1',
    display_name: 'Liga 1',
    slug: 'liga-1',
    tier: 1
  });

  const liga2Id = generateUUID('casa', 'Liga 2');
  divisions.set(liga2Id, {
    id: liga2Id,
    conference_id: confId,
    name: 'Liga 2',
    display_name: 'Liga 2',
    slug: 'liga-2',
    tier: 2
  });

  // 2. Scrape Liga 1
  const browser = await puppeteer.launch({
    headless: "new",
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  try {
    await scrapeDivision(browser, LIGA1_STANDINGS_URL, LIGA1_SCHEDULE_URL, liga1Id, 'Liga 1');

    // 3. Scrape Liga 2
    await scrapeDivision(browser, LIGA2_STANDINGS_URL, LIGA2_SCHEDULE_URL, liga2Id, 'Liga 2');
  } finally {
    await browser.close();
  }

  // 4. Generate SQL
  generateStructureSQL();
}

async function scrapeDivision(browser, standingsUrl, scheduleUrl, divisionId, divisionName) {
  console.log(`  Scraping ${divisionName}...`);
  const page = await browser.newPage();

  // Standings (Teams)
  try {
    await page.goto(standingsUrl, { waitUntil: 'networkidle2' });
    
    // Wait for table
    try {
        await page.waitForSelector('table tbody tr', { timeout: 10000 });
    } catch (e) {
        console.log('    Timeout waiting for table, trying to continue anyway...');
    }

    const teamsData = await page.evaluate(() => {
        const data = [];
        const rows = document.querySelectorAll('table tbody tr');
        rows.forEach(row => {
            const cells = row.querySelectorAll('td');
            if (cells.length > 0) {
                let name = cells[0].textContent.trim();
                if (/^\d+$/.test(name) && cells.length > 1) {
                    name = cells[1].textContent.trim();
                }
                if (name && name !== 'Team' && name.length > 2) {
                    data.push(name);
                }
            }
        });
        return data;
    });

    for (const teamName of teamsData) {
        const clubId = generateUUID('club', teamName);
        const sportDivId = generateUUID('sdiv', teamName);
        const teamId = generateUUID('team', teamName);

        if (!clubs.has(clubId)) {
          clubs.set(clubId, {
            id: clubId,
            name: teamName,
            display_name: teamName,
            slug: slugify(teamName)
          });
        }

        if (!sportDivisions.has(sportDivId)) {
          sportDivisions.set(sportDivId, {
            id: sportDivId,
            club_id: clubId,
            sport_id: SOCCER_SPORT_ID,
            name: teamName,
            display_name: teamName,
            slug: slugify(teamName)
          });
        }

        teams.set(teamName, { // Map by name for schedule lookup
          id: teamId,
          name: teamName,
          division_id: sportDivId,
          league_division_id: divisionId
        });
    }
    console.log(`    Found ${teams.size} teams so far`);
  } catch (err) {
    console.error(`    Error scraping standings: ${err.message}`);
  }

  // Schedule
  try {
    await page.goto(scheduleUrl, { waitUntil: 'networkidle2' });
    
    // Wait for table
    try {
        await page.waitForSelector('table tbody tr', { timeout: 10000 });
    } catch (e) {
        console.log('    Timeout waiting for schedule table, trying to continue anyway...');
    }

    const matchesData = await page.evaluate(() => {
        const data = [];
        const rows = document.querySelectorAll('table tbody tr');
        rows.forEach(row => {
            const cells = row.querySelectorAll('td');
            if (cells.length >= 3) {
                let dateText = '';
                let homeText = '';
                let awayText = '';
                
                // Simple heuristic: iterate cells
                for (const cell of cells) {
                    const text = cell.textContent.trim();
                    // We can't check against 'teams' map here easily without passing it in, 
                    // so we'll just grab text and filter later or return all text
                    // Actually, let's just return the raw text of cells and process in Node
                }
            }
        });
        // Let's just return the raw text of all cells for each row
        const rawRows = [];
        rows.forEach(row => {
            const cells = row.querySelectorAll('td');
            const rowData = [];
            cells.forEach(cell => rowData.push(cell.textContent.trim()));
            if (rowData.length > 0) rawRows.push(rowData);
        });
        return rawRows;
    });

    for (const rowData of matchesData) {
        let dateText = '';
        let homeText = '';
        let awayText = '';
        
        for (const text of rowData) {
          if (teams.has(text)) {
            if (!homeText) homeText = text;
            else if (!awayText) awayText = text;
          }
          if (!dateText && /\d{1,2}[\/-]\d{1,2}/.test(text)) {
            dateText = text;
          }
        }
        
        if (dateText && homeText && awayText) {
          const homeTeam = teams.get(homeText);
          const awayTeam = teams.get(awayText);

          if (homeTeam && awayTeam) {
            const matchId = generateUUID('match', `${dateText}-${homeText}-${awayText}`);
            matches.set(matchId, {
              id: matchId,
              home_team_id: homeTeam.id,
              away_team_id: awayTeam.id,
              date: dateText, 
              competition: divisionName
            });
          }
        }
    }
    console.log(`    Found ${matches.size} matches so far`);
  } catch (err) {
    console.error(`    Error scraping schedule: ${err.message}`);
  }
  
  await page.close();
}

async function scrapeLighthouseRosters() {
  console.log('Scraping Lighthouse rosters (CSV)...');
  
  // Process Liga 1 (Boys Club)
  await processRosterCSV(LIGA1_ROSTER_CSV, 'Lighthouse Boys Club');
  
  // Process Liga 2 (Old Timers)
  await processRosterCSV(LIGA2_ROSTER_CSV, 'Lighthouse Old Timers');

  generateRosterSQL();
}

async function processRosterCSV(url, teamName) {
  try {
    const csv = await fetchURL(url);
    const lines = csv.split('\n');
    // Skip header
    for (let i = 1; i < lines.length; i++) {
      const line = lines[i].trim();
      if (!line) continue;
      
      // CSV parsing (simple split, might need robust parser if quotes used)
      const cols = line.split(','); 
      // Assuming: First, Last, Jersey, ...
      if (cols.length >= 2) {
        const firstName = cols[0].trim();
        const lastName = cols[1].trim();
        const jersey = cols[2]?.trim();
        
        if (firstName && lastName) {
          externalIdentities.push({
            first_name: firstName,
            last_name: lastName,
            jersey_number: jersey,
            team_name: teamName
          });
        }
      }
    }
    console.log(`  Processed ${teamName}: ${lines.length - 1} rows`);
  } catch (err) {
    console.error(`  Error processing CSV for ${teamName}: ${err.message}`);
  }
}

function generateStructureSQL() {
  console.log('Generating Structure SQL...');
  
  // Helper to write file
  const writeFile = (filename, header, content) => {
    const fullPath = path.join(BASE_DIR, 'data', filename);
    const sql = `-- ========================================
-- ${header}
-- ========================================
-- Generated: ${new Date().toISOString()}
-- Source: CASA Website
-- ========================================

${content}`;
    fs.writeFileSync(fullPath, sql);
    console.log(`  ✓ ${filename}`);
  };

  // 1. Conferences
  let confSQL = '';
  for (const conf of conferences.values()) {
    confSQL += `INSERT INTO league_conferences (id, league_id, name, display_name, slug, is_active)
VALUES (${sqlEscape(conf.id)}, ${sqlEscape(conf.league_id)}, ${sqlEscape(conf.name)}, ${sqlEscape(conf.display_name)}, ${sqlEscape(conf.slug)}, true)
ON CONFLICT (id) DO NOTHING;\n`;
  }
  writeFile('04-conferences-casa.sql', 'CASA CONFERENCES', confSQL);

  // 2. Divisions
  let divSQL = '';
  for (const div of divisions.values()) {
    divSQL += `INSERT INTO league_divisions (id, conference_id, name, display_name, slug, tier, is_active)
VALUES (${sqlEscape(div.id)}, ${sqlEscape(div.conference_id)}, ${sqlEscape(div.name)}, ${sqlEscape(div.display_name)}, ${sqlEscape(div.slug)}, ${div.tier}, true)
ON CONFLICT (id) DO NOTHING;\n`;
  }
  writeFile('05-league-divisions-casa.sql', 'CASA DIVISIONS', divSQL);

  // 3. Clubs
  let clubSQL = '';
  for (const club of clubs.values()) {
    clubSQL += `INSERT INTO clubs (id, name, display_name, slug, is_active)
VALUES (${sqlEscape(club.id)}, ${sqlEscape(club.name)}, ${sqlEscape(club.display_name)}, ${sqlEscape(club.slug)}, true)
ON CONFLICT (id) DO NOTHING;\n`;
  }
  writeFile('06-clubs-casa.sql', 'CASA CLUBS', clubSQL);

  // 4. Sport Divisions
  let sdSQL = '';
  for (const sd of sportDivisions.values()) {
    sdSQL += `INSERT INTO sport_divisions (id, club_id, sport_id, name, display_name, slug, is_active)
VALUES (${sqlEscape(sd.id)}, ${sqlEscape(sd.club_id)}, ${sqlEscape(sd.sport_id)}, ${sqlEscape(sd.name)}, ${sqlEscape(sd.display_name)}, ${sqlEscape(sd.slug)}, true)
ON CONFLICT (id) DO NOTHING;\n`;
  }
  writeFile('07-sport-divisions-casa.sql', 'CASA SPORT DIVISIONS', sdSQL);

  // 5. Teams
  let teamSQL = '';
  for (const team of teams.values()) {
    teamSQL += `INSERT INTO teams (id, name, division_id, league_division_id, season, is_active)
VALUES (${sqlEscape(team.id)}, ${sqlEscape(team.name)}, ${sqlEscape(team.division_id)}, ${sqlEscape(team.league_division_id)}, '2024-2025', true)
ON CONFLICT (id) DO NOTHING;\n`;
  }
  writeFile('21-teams-casa.sql', 'CASA TEAMS', teamSQL);
}

function generateRosterSQL() {
  console.log('Generating Roster SQL...');
  
  const fullPath = path.join(BASE_DIR, 'data', '23-external-identities-casa.sql');
  let sql = `-- ========================================
-- CASA LIGHTHOUSE ROSTERS
-- ========================================
-- Generated: ${new Date().toISOString()}
-- Source: Google Sheets
-- ========================================

`;

  for (const identity of externalIdentities) {
    // Find the team ID from our scraped teams map
    const team = teams.get(identity.team_name);
    const teamId = team ? team.id : null;
    
    // Generate a deterministic external ID based on name and team
    const externalId = `casa-${slugify(identity.team_name)}-${slugify(identity.first_name)}-${slugify(identity.last_name)}`;
    const displayName = `${identity.first_name} ${identity.last_name}`;
    
    const externalData = JSON.stringify({
      jersey_number: identity.jersey_number,
      position: null, // Not in CSV
      team_name: identity.team_name
    });

    // We use a PL/pgSQL block to handle the dependent inserts cleanly
    sql += `DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := ${teamId ? sqlEscape(teamId) : 'NULL'};
    v_external_id VARCHAR := ${sqlEscape(externalId)};
BEGIN
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, ${sqlEscape(identity.first_name)}, ${sqlEscape(identity.last_name)}, true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            ${identity.jersey_number && !isNaN(parseInt(identity.jersey_number)) ? parseInt(identity.jersey_number) : 'NULL'},
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        ${sqlEscape(displayName)},
        v_user_id, -- Linked to the user we just created/found
        ${sqlEscape(identity.first_name)},
        ${sqlEscape(identity.last_name)},
        v_team_id,
        ${sqlEscape(externalData)}
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

`;
  }
  
  fs.writeFileSync(fullPath, sql);
  console.log(`  ✓ 23-external-identities-casa.sql`);
}

// Main execution
(async () => {
  try {
    // If both flags are present in dev.sh, we might get 'lighthouse' but want 'full' if structure was also requested
    // But dev.sh logic is tricky. Let's rely on the MODE passed.
    // If MODE is 'lighthouse', we ONLY do lighthouse.
    // If MODE is 'structure', we ONLY do structure.
    // If MODE is 'full', we do BOTH.
    
    if (MODE === 'structure' || MODE === 'full') {
      await scrapeStructure();
    }
    
    // FALLBACK: Ensure Lighthouse teams exist BEFORE scraping rosters (so team IDs are available)
    if (teams.size === 0 && (MODE === 'lighthouse' || MODE === 'full')) {
        console.log('⚠ Structure scrape skipped or failed. Injecting fallback Lighthouse teams...');
        ensureFallbackTeams();
        generateStructureSQL();
    }
    
    if (MODE === 'lighthouse' || MODE === 'full') {
      await scrapeLighthouseRosters();
    }
    
    // Note: Coach assignments are now handled dynamically by database/data/53-team-coaches.sql
    // This ensures all Lighthouse teams (APSL or CASA) are linked to the admin user automatically.

  } catch (err) {
    console.error('Fatal error:', err);
    process.exit(1);
  }
})();

function ensureFallbackTeams() {
    // Ensure hierarchy exists
    const confId = generateUUID('casa', 'CASA Conference');
    if (!conferences.has(confId)) {
        conferences.set(confId, {
            id: confId,
            league_id: CASA_LEAGUE_ID,
            name: 'CASA Conference',
            display_name: 'CASA Conference',
            slug: 'casa-conference'
        });
    }

    const liga1Id = generateUUID('casa', 'Liga 1');
    if (!divisions.has(liga1Id)) {
        divisions.set(liga1Id, {
            id: liga1Id,
            conference_id: confId,
            name: 'Liga 1',
            display_name: 'Liga 1',
            slug: 'liga-1',
            tier: 1
        });
    }

    const liga2Id = generateUUID('casa', 'Liga 2');
    if (!divisions.has(liga2Id)) {
        divisions.set(liga2Id, {
            id: liga2Id,
            conference_id: confId,
            name: 'Liga 2',
            display_name: 'Liga 2',
            slug: 'liga-2',
            tier: 2
        });
    }

    // Ensure Teams exist
    const teamsToEnsure = [
        { name: 'Lighthouse Boys Club', divId: liga1Id },
        { name: 'Lighthouse Old Timers', divId: liga2Id }
    ];

    for (const t of teamsToEnsure) {
        if (!teams.has(t.name)) {
            const clubId = generateUUID('club', t.name);
            const sportDivId = generateUUID('sdiv', t.name);
            const teamId = generateUUID('team', t.name);

            clubs.set(clubId, {
                id: clubId,
                name: t.name,
                display_name: t.name,
                slug: slugify(t.name)
            });

            sportDivisions.set(sportDivId, {
                id: sportDivId,
                club_id: clubId,
                sport_id: SOCCER_SPORT_ID,
                name: t.name,
                display_name: t.name,
                slug: slugify(t.name)
            });

            teams.set(t.name, {
                id: teamId,
                name: t.name,
                division_id: sportDivId,
                league_division_id: t.divId
            });
            console.log(`  + Injected fallback team: ${t.name}`);
        }
    }
}

