#!/usr/bin/env node
/**
 * CASA Roster Scraper
 * 
 * Scrapes official CASA Liga 1 and Liga 2 rosters from published Google Sheets
 * - Extracts player data (name, DOB, headshots)
 * - Downloads and stores headshot images locally
 * - Generates SQL for users, external identities, and team rosters
 * 
 * Usage: node scrape-casa.js
 */

const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');

// Configuration
const LIGA1_BOYS_CLUB_URL = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSmsWzjTsLR81d-eQTLDM4EnaqzqUOy5OcWLy1Lna1NYVFY7gOj0nZAQdIk99e99g/pub?gid=480494399&output=csv';
const LIGA2_OLD_TIMERS_URL = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vQsDtR6AQPgThg1105AinjkLqHMaWgQfCFJuWqfEtadH41k5OSKYZ2Hqb0N-CnO2Q/pub?gid=310279135&output=csv';

const BOYS_CLUB_TEAM_ID = 'b0c1abb0-c1ab-0001-b0c1-ab0c1abb0c1a';
const OLD_TIMERS_TEAM_ID = '01d71ee5-01d7-0002-1ee5-01d71ee501d7';

// Directories
const BASE_DIR = path.join(__dirname, '../..');
const HEADSHOTS_DIR = path.join(BASE_DIR, '../frontend/images/players/headshots');
const DATA_DIR = path.join(BASE_DIR, 'data');

// Data storage
const users = [];
const externalIdentities = [];
const teamRosters = [];

// Helper: Generate UUID v4
function generateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

// Helper: Fetch URL content (handles redirects)
function fetchURL(url, redirectCount = 0) {
  return new Promise((resolve, reject) => {
    if (redirectCount > 5) {
      return reject(new Error('Too many redirects'));
    }
    
    const client = url.startsWith('https') ? https : http;
    client.get(url, (res) => {
      // Handle redirects
      if (res.statusCode === 301 || res.statusCode === 302 || res.statusCode === 307 || res.statusCode === 308) {
        return resolve(fetchURL(res.headers.location, redirectCount + 1));
      }
      
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data));
    }).on('error', reject);
  });
}

// Helper: Download headshot image
async function downloadHeadshot(url, playerId) {
  if (!url || url.includes('PLAYER SHOULD BRING ID')) return null;
  
  const filename = `${playerId}.png`;
  const filepath = path.join(HEADSHOTS_DIR, filename);
  
  if (!fs.existsSync(HEADSHOTS_DIR)) {
    fs.mkdirSync(HEADSHOTS_DIR, { recursive: true });
  }

  return new Promise((resolve) => {
    const client = url.startsWith('https') ? https : http;
    const maxRetries = 3;
    let attempts = 0;

    const executeDownload = () => {
      attempts++;
      const request = client.get(url);
      
      request.on('error', (err) => {
        if (attempts < maxRetries) {
          console.error(`      Retry ${attempts}/${maxRetries} for ${filename}: ${err.message}`);
          setTimeout(executeDownload, 1000 * attempts);
        } else {
          console.error(`      ✗ Failed ${filename}: ${err.message}`);
          resolve(null);
        }
      });
      
      request.on('response', (response) => {
        if (response.statusCode === 200) {
          const fileStream = fs.createWriteStream(filepath);
          
          response.on('error', (err) => {
            fileStream.destroy();
            fs.unlink(filepath, () => {});
            if (attempts < maxRetries) {
              setTimeout(executeDownload, 1000 * attempts);
            } else {
              resolve(null);
            }
          });
          
          fileStream.on('error', (err) => {
            fs.unlink(filepath, () => {});
            resolve(null);
          });
          
          fileStream.on('finish', () => {
            resolve(`/images/players/headshots/${filename}`);
          });
          
          response.pipe(fileStream);
        } else {
          console.error(`      ✗ HTTP ${response.statusCode} for ${filename}`);
          resolve(null);
        }
      });
    };

    executeDownload();
  });
}

// Parse roster CSV
async function parseRoster(csvContent, teamId, teamName) {
  console.error(`\n📋 Processing ${teamName}...`);
  
  // Normalize line endings and split by newlines
  const lines = csvContent.replace(/\r\n/g, '\n').replace(/\r/g, '\n').split('\n');
  
  let playerCount = 0;
  let inDataSection = false;
  
  for (const line of lines) {
    if (!line.trim()) continue;
    
    // Parse CSV line (basic - handles most cases)
    const row = line.split(',').map(cell => cell.trim().replace(/^"|"$/g, ''));
    
    // Skip until we find the header row
    if (row[1] === 'First Name' && row[2] === 'Last Name') {
      inDataSection = true;
      continue;
    }
    
    if (!inDataSection) continue;
    
    const firstName = row[1]?.trim();
    const lastName = row[2]?.trim();
    
    if (!firstName || !lastName || firstName === '' || lastName === '') continue;
    
    const dob = row[3]?.trim();
    const headshotNote = row[4]?.trim();
    const dateAdded = row[5]?.trim();
    const jerseyNum = row[6]?.trim();
    
    playerCount++;
    const playerId = generateUUID();
    
    // For now, no headshot URLs in the CSV
    // When they add image URLs to sheets, we'll extract them
    const headshotPath = null;
    
    // Create user
    users.push({
      id: playerId,
      firstName: firstName,
      lastName: lastName,
      dob: dob || null,
      avatarUrl: headshotPath,
      jerseyNum: jerseyNum || null
    });
    
    // Create external identity for CASA
    externalIdentities.push({
      userId: playerId,
      provider: 'casa',
      externalId: `${teamName.toLowerCase().replace(/\s+/g, '-')}-${firstName.toLowerCase()}-${lastName.toLowerCase()}`,
      externalUsername: `${firstName} ${lastName}`,
      externalData: {
        team: teamName,
        date_of_birth: dob,
        date_added: dateAdded,
        jersey_number: jerseyNum,
        headshot_note: headshotNote
      }
    });
    
    // Add to team roster
    teamRosters.push({
      teamId: teamId,
      playerId: playerId,
      jerseyNum: jerseyNum || null
    });
  }
  
  console.error(`  ✓ Processed ${playerCount} players`);
  return playerCount;
}

// Generate SQL output
function generateSQL() {
  console.error('\n📝 Writing SQL files...');
  
  // Users SQL
  let usersSQL = `-- ========================================
-- CASA USERS (Liga 1 Boys Club + Liga 2 Old Timers)
-- ========================================
-- Generated: ${new Date().toISOString()}
-- Source: CASA Google Sheets
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/scripts/casa-scraper/scrape-casa.js
-- ========================================

`;

  const userValues = users.map(u => {
    const firstName = u.firstName.replace(/'/g, "''");
    const lastName = u.lastName.replace(/'/g, "''");
    const avatarUrl = u.avatarUrl ? `'${u.avatarUrl}'` : 'NULL';
    const dob = u.dob ? `'${u.dob}'` : 'NULL';
    
    return `  ('${u.id}', '${firstName}', '${lastName}', ${avatarUrl}, ${dob}, true)`;
  });

  usersSQL += `INSERT INTO users (id, first_name, last_name, avatar_url, date_of_birth, is_active) VALUES\n`;
  usersSQL += userValues.join(',\n');
  usersSQL += `\nON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  avatar_url = COALESCE(EXCLUDED.avatar_url, users.avatar_url),
  date_of_birth = COALESCE(EXCLUDED.date_of_birth, users.date_of_birth),
  updated_at = CURRENT_TIMESTAMP;

`;

  // External identities SQL
  let identitiesSQL = `-- External identities for CASA players
INSERT INTO user_external_identities (user_id, provider, external_id, external_username, external_data) VALUES\n`;
  
  const identityValues = externalIdentities.map(ei => {
    const username = ei.externalUsername.replace(/'/g, "''");
    const data = JSON.stringify(ei.externalData).replace(/'/g, "''");
    return `  ('${ei.userId}', '${ei.provider}', '${ei.externalId}', '${username}', '${data}'::jsonb)`;
  });
  
  identitiesSQL += identityValues.join(',\n');
  identitiesSQL += `\nON CONFLICT (user_id, provider) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  external_username = EXCLUDED.external_username,
  external_data = EXCLUDED.external_data,
  updated_at = CURRENT_TIMESTAMP;

`;

  usersSQL += identitiesSQL;

  // Players SQL (ensure player records exist)
  usersSQL += `-- Ensure player records exist for all CASA users
INSERT INTO players (id) VALUES\n`;
  usersSQL += users.map(u => `  ('${u.id}')`).join(',\n');
  usersSQL += `\nON CONFLICT (id) DO NOTHING;

`;

  // Rosters SQL
  let rostersSQL = `-- ========================================
-- CASA TEAM ROSTERS
-- ========================================

`;

  const rosterValues = teamRosters.map(r => {
    const jersey = r.jerseyNum ? `${r.jerseyNum}` : 'NULL';
    return `  ('${r.teamId}', '${r.playerId}', 1, ${jersey})`;
  });

  rostersSQL += `INSERT INTO team_players (team_id, player_id, roster_status_id, jersey_number) VALUES\n`;
  rostersSQL += rosterValues.join(',\n');
  rostersSQL += `\nON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = COALESCE(EXCLUDED.jersey_number, team_players.jersey_number),
  is_active = true;

`;

  // Write files
  const usersFile = path.join(DATA_DIR, '21-users-casa.sql');
  const rostersFile = path.join(DATA_DIR, '31-rosters-casa.sql');
  
  fs.writeFileSync(usersFile, usersSQL);
  fs.writeFileSync(rostersFile, rostersSQL);
  
  console.error(`  ✓ ${usersFile}`);
  console.error(`  ✓ ${rostersFile}`);
}

// Main execution
async function main() {
  try {
    console.error('========================================');
    console.error('CASA ROSTER SCRAPER');
    console.error('========================================\n');
    
    // Fetch and parse rosters
    const boysClubCSV = await fetchURL(LIGA1_BOYS_CLUB_URL);
    await parseRoster(boysClubCSV, BOYS_CLUB_TEAM_ID, 'Lighthouse Boys Club');
    
    const oldTimersCSV = await fetchURL(LIGA2_OLD_TIMERS_URL);
    await parseRoster(oldTimersCSV, OLD_TIMERS_TEAM_ID, 'Lighthouse Old Timers Club');
    
    // Generate SQL
    generateSQL();
    
    console.error('\n========================================');
    console.error('SUMMARY');
    console.error('========================================');
    console.error(`Total Users: ${users.length}`);
    console.error(`External Identities: ${externalIdentities.length}`);
    console.error(`Team Roster Entries: ${teamRosters.length}`);
    console.error('========================================\n');
    
    console.error('✓ Scraping complete!\n');
    
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

// Handle uncaught errors
process.on('uncaughtException', (err) => {
  if (err.code === 'ECONNRESET' || err.code === 'ETIMEDOUT') {
    console.error('⚠️  Network error (retrying): ' + err.message);
  } else {
    console.error('❌ Uncaught error:', err);
    process.exit(1);
  }
});

main();
