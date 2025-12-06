#!/usr/bin/env node
/**
 * GroupMe Practice Importer - Import calendar events and RSVPs from GroupMe
 * 
 * This script:
 * 1. Fetches calendar events from GroupMe API
 * 2. Creates practices in Football Home for each event
 * 3. Imports RSVPs for each practice
 * 
 * Usage:
 *   node scripts/import-groupme-practices.js <group_id> [--dry-run]
 *   node scripts/import-groupme-practices.js 108640377 --dry-run
 */

require('dotenv').config();
const https = require('https');
const { Client } = require('pg');
const { execSync } = require('child_process');

const ACCESS_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const BASE_URL = 'https://api.groupme.com/v3';

// Database connection
const dbConfig = {
  host: process.env.POSTGRES_HOST || 'localhost',
  port: process.env.POSTGRES_PORT || 5432,
  database: process.env.POSTGRES_DB || 'footballhome',
  user: process.env.POSTGRES_USER || 'footballhome_user',
  password: process.env.POSTGRES_PASSWORD || 'footballhome_pass'
};

const DRY_RUN = process.argv.includes('--dry-run');
const TEAM_ID = 'd37eb44b-8e47-0005-9060-f0cbe96fe089'; // Lighthouse 1893 SC
const CREATOR_ID = '77d77471-1250-47e0-81ab-d4626595d63c'; // jbreslin
const TRAINING_EVENT_TYPE_ID = '550e8400-e29b-41d4-a716-446655440401'; // Training/Practice

if (!ACCESS_TOKEN) {
  console.error('❌ Error: GROUPME_ACCESS_TOKEN not found in .env file');
  console.error('   Get your token from: https://dev.groupme.com/');
  process.exit(1);
}

// Helper function to make GroupMe API requests
function apiRequest(path) {
  return new Promise((resolve, reject) => {
    const url = `${BASE_URL}${path}${path.includes('?') ? '&' : '?'}token=${ACCESS_TOKEN}`;
    
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (json.response) {
            resolve(json.response);
          } else {
            reject(new Error('Invalid response from GroupMe API'));
          }
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

// Fetch calendar events from GroupMe
async function fetchCalendarEvents(groupId) {
  console.log('📅 Fetching calendar events from GroupMe...');
  
  try {
    const events = await apiRequest(`/conversations/${groupId}/events/list`);
    
    // Filter to upcoming events only
    const now = new Date();
    const upcoming = events.filter(event => {
      const eventDate = new Date(event.starts_at);
      return eventDate >= now;
    });
    
    console.log(`✅ Found ${upcoming.length} upcoming event(s)\n`);
    return upcoming;
  } catch (error) {
    console.error('❌ Error fetching events:', error.message);
    console.error('   Note: Calendar API endpoint may require special permissions');
    return [];
  }
}

// Scrape RSVPs for a single event using the calendar scraper
async function scrapeEventRSVPs(groupId, eventId) {
  try {
    const output = execSync(
      `node scripts/groupme-calendar-scraper.js ${groupId} ${eventId}`,
      { encoding: 'utf8', stdio: 'pipe' }
    );
    
    // Parse output to extract RSVP data
    const rsvps = {
      going: [],
      maybe: [],
      not_going: [],
      no_response: []
    };
    
    let currentSection = null;
    const lines = output.split('\n');
    
    for (const line of lines) {
      if (line.includes('✅ Going')) currentSection = 'going';
      else if (line.includes('❓ Maybe')) currentSection = 'maybe';
      else if (line.includes('❌ Not Going')) currentSection = 'not_going';
      else if (line.includes('⏳ No Response')) currentSection = 'no_response';
      else if (line.trim().startsWith('-') && currentSection) {
        const name = line.trim().substring(1).trim();
        if (name) rsvps[currentSection].push(name);
      }
    }
    
    return rsvps;
  } catch (error) {
    console.error(`   ⚠️  Could not scrape RSVPs: ${error.message}`);
    return { going: [], maybe: [], not_going: [], no_response: [] };
  }
}

// Fuzzy name matching
function matchName(groupmeName, dbFirstName, dbLastName) {
  const gName = groupmeName.toLowerCase().trim();
  const first = dbFirstName.toLowerCase().trim();
  const last = dbLastName.toLowerCase().trim();
  const full = `${first} ${last}`;
  
  if (gName === full) return 100;
  if (gName === first || gName === last) return 90;
  if (full.includes(gName) || gName.includes(full)) return 80;
  if (gName.includes(first) || first.includes(gName)) return 70;
  if (gName.includes(last) || last.includes(gName)) return 70;
  if (gName.startsWith(first[0]) && gName.includes(last)) return 60;
  
  return 0;
}

// Find best matching user
async function findMatchingUser(client, groupmeName) {
  const result = await client.query(`
    SELECT u.id, u.first_name, u.last_name, u.email
    FROM users u
    JOIN rosters r ON u.id = r.player_id
    WHERE r.team_id = $1 AND r.is_active = true
  `, [TEAM_ID]);
  
  let bestMatch = null;
  let bestScore = 0;
  
  for (const user of result.rows) {
    const score = matchName(groupmeName, user.first_name, user.last_name);
    if (score > bestScore) {
      bestScore = score;
      bestMatch = user;
    }
  }
  
  return bestScore >= 60 ? { ...bestMatch, score: bestScore } : null;
}

// Main import function
async function importPractices(groupId) {
  const client = new Client(dbConfig);
  
  try {
    console.log('🔌 Connecting to database...');
    await client.connect();
    console.log('✅ Connected\n');
    
    // Fetch calendar events
    const events = await fetchCalendarEvents(groupId);
    
    if (events.length === 0) {
      console.log('No upcoming events to import.');
      return;
    }
    
    // Get default venue (or create one)
    const venueResult = await client.query(`
      SELECT id FROM venues WHERE name LIKE 'Lighthouse%' LIMIT 1
    `);
    
    const defaultVenueId = venueResult.rows.length > 0 
      ? venueResult.rows[0].id 
      : null;
    
    console.log('📋 Processing events:\n');
    
    for (const event of events) {
      const eventDate = new Date(event.starts_at);
      const title = event.name || 'Practice';
      const description = event.description || '';
      
      console.log(`⚽ ${title}`);
      console.log(`   📅 ${eventDate.toLocaleString()}`);
      console.log(`   🆔 Event ID: ${event.event_id}`);
      
      if (DRY_RUN) {
        console.log('   🏃 DRY RUN - would create practice\n');
        continue;
      }
      
      // Create event in Football Home
      const eventId = require('crypto').randomUUID();
      
      await client.query(`
        INSERT INTO events (id, created_by, event_type_id, title, description, event_date, duration_minutes, venue_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        ON CONFLICT (id) DO NOTHING
      `, [eventId, CREATOR_ID, TRAINING_EVENT_TYPE_ID, title, description, eventDate, 120, defaultVenueId]);
      
      // Create practice record
      await client.query(`
        INSERT INTO practices (id, team_id)
        VALUES ($1, $2)
        ON CONFLICT (id) DO NOTHING
      `, [eventId, TEAM_ID]);
      
      console.log(`   ✅ Practice created (ID: ${eventId})`);
      
      // Scrape and import RSVPs
      console.log(`   📥 Fetching RSVPs...`);
      const rsvps = await scrapeEventRSVPs(groupId, event.event_id);
      
      const totalRsvps = rsvps.going.length + rsvps.maybe.length + 
                         rsvps.not_going.length + rsvps.no_response.length;
      
      if (totalRsvps === 0) {
        console.log(`   ⚠️  No RSVPs found\n`);
        continue;
      }
      
      // Get RSVP status IDs
      const statusIds = {};
      const statusResult = await client.query('SELECT id, name FROM rsvp_statuses');
      for (const row of statusResult.rows) {
        statusIds[row.name] = row.id;
      }
      
      // Get bulk_import source ID
      const sourceResult = await client.query(
        "SELECT id FROM rsvp_change_sources WHERE name = 'bulk_import'"
      );
      const sourceId = sourceResult.rows[0].id;
      
      // Import each RSVP
      let imported = 0;
      let skipped = 0;
      
      for (const [status, names] of Object.entries(rsvps)) {
        if (status === 'no_response' || names.length === 0) continue;
        
        const mappedStatus = status === 'going' ? 'yes' : status === 'not_going' ? 'no' : status;
        const statusId = statusIds[mappedStatus];
        
        if (!statusId) continue;
        
        for (const name of names) {
          const match = await findMatchingUser(client, name);
          
          if (match) {
            await client.query(`
              INSERT INTO event_rsvps (event_id, user_id, rsvp_status_id, change_source_id, response_date)
              VALUES ($1, $2, $3, $4, NOW())
              ON CONFLICT (event_id, user_id) 
              DO UPDATE SET 
                rsvp_status_id = EXCLUDED.rsvp_status_id,
                response_date = EXCLUDED.response_date,
                change_source_id = EXCLUDED.change_source_id
            `, [eventId, match.id, statusId, sourceId]);
            
            imported++;
          } else {
            skipped++;
          }
        }
      }
      
      console.log(`   ✅ Imported ${imported} RSVP(s), ${skipped} skipped (no match)\n`);
    }
    
    console.log('✨ Import complete!\n');
    
  } catch (error) {
    console.error('\n❌ Error:', error);
    throw error;
  } finally {
    await client.end();
  }
}

// Main
const groupId = process.argv[2];

if (!groupId || groupId === '--help' || groupId === '-h') {
  console.log('GroupMe Practice Importer\n');
  console.log('Usage:');
  console.log('  node scripts/import-groupme-practices.js <GROUP_ID> [--dry-run]\n');
  console.log('Example:');
  console.log('  node scripts/import-groupme-practices.js 108640377');
  console.log('  node scripts/import-groupme-practices.js 108640377 --dry-run\n');
  console.log('Setup:');
  console.log('  1. Get GroupMe Access Token: https://dev.groupme.com/');
  console.log('  2. Add to .env: GROUPME_ACCESS_TOKEN=your-token');
  console.log('  3. Add GroupMe credentials for calendar scraper:');
  console.log('     GROUPME_EMAIL=your-email@example.com');
  console.log('     GROUPME_PASSWORD=your-password');
  process.exit(0);
}

importPractices(groupId).catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
