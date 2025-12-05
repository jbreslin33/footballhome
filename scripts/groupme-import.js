#!/usr/bin/env node
/**
 * GroupMe RSVP Importer - Import RSVPs from GroupMe into Football Home database
 * 
 * Usage:
 *   node scripts/groupme-import.js <group_id> [--dry-run]
 * 
 * This script:
 * 1. Fetches recent messages with RSVP patterns from GroupMe
 * 2. Attempts to match GroupMe users to Football Home users (by name)
 * 3. Imports RSVPs into the database
 * 4. Shows a report of matched/unmatched players
 */

require('dotenv').config();
const https = require('https');
const { Client } = require('pg');

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

if (!ACCESS_TOKEN) {
  console.error('❌ Error: GROUPME_ACCESS_TOKEN not found in .env file');
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

// Fuzzy name matching - handles "John Doe", "John", "Doe", "J. Doe", etc.
function matchName(groupmeName, dbFirstName, dbLastName) {
  const gName = groupmeName.toLowerCase().trim();
  const first = dbFirstName.toLowerCase().trim();
  const last = dbLastName.toLowerCase().trim();
  const full = `${first} ${last}`;
  
  // Exact full name match
  if (gName === full) return 100;
  
  // Exact first or last name
  if (gName === first || gName === last) return 90;
  
  // Full name contains GroupMe name or vice versa
  if (full.includes(gName) || gName.includes(full)) return 80;
  
  // First name match
  if (gName.includes(first) || first.includes(gName)) return 70;
  
  // Last name match
  if (gName.includes(last) || last.includes(gName)) return 70;
  
  // First initial + last name (e.g., "J. Doe")
  if (gName.startsWith(first[0]) && gName.includes(last)) return 60;
  
  return 0;
}

// Find best matching user in database
async function findMatchingUser(client, groupmeName) {
  const result = await client.query(`
    SELECT u.id, u.first_name, u.last_name, u.email
    FROM users u
    JOIN team_players tp ON u.id = tp.player_id
    WHERE tp.team_id = $1 AND tp.is_active = true
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
  
  // Only return if confidence is decent (>= 60%)
  return bestScore >= 60 ? { ...bestMatch, score: bestScore } : null;
}

// Parse RSVPs from messages
async function parseRSVPs(groupId) {
  const messages = await apiRequest(`/groups/${groupId}/messages?limit=100`);
  
  if (!messages || !messages.messages) {
    return [];
  }
  
  const patterns = {
    yes: /\b(yes|in|attending|i'?m in|count me in|i'?ll be there|coming|going)\b/i,
    no: /\b(no|out|can'?t make it|won'?t make it|not coming|can'?t come|not going)\b/i,
    maybe: /\b(maybe|might|possibly|not sure|tentative)\b/i
  };
  
  const rsvps = [];
  const seenUsers = new Set();
  
  // Process most recent first, skip duplicates (keep latest response)
  for (const msg of messages.messages) {
    if (!msg.text || seenUsers.has(msg.user_id)) continue;
    
    let status = null;
    if (patterns.yes.test(msg.text)) status = 'yes';
    else if (patterns.no.test(msg.text)) status = 'no';
    else if (patterns.maybe.test(msg.text)) status = 'maybe';
    
    if (status) {
      seenUsers.add(msg.user_id);
      rsvps.push({
        groupme_user_id: msg.user_id,
        groupme_name: msg.name,
        status: status,
        message: msg.text,
        timestamp: new Date(msg.created_at * 1000)
      });
    }
  }
  
  return rsvps;
}

// Main import function
async function importRSVPs(groupId) {
  const client = new Client(dbConfig);
  
  try {
    console.log('🔌 Connecting to database...');
    await client.connect();
    console.log('✅ Connected\n');
    
    console.log('📨 Fetching RSVPs from GroupMe...');
    const rsvps = await parseRSVPs(groupId);
    console.log(`✅ Found ${rsvps.length} RSVP(s)\n`);
    
    if (rsvps.length === 0) {
      console.log('No RSVPs to import.');
      return;
    }
    
    console.log('🔍 Matching GroupMe users to Football Home users...\n');
    
    const matched = [];
    const unmatched = [];
    
    for (const rsvp of rsvps) {
      const match = await findMatchingUser(client, rsvp.groupme_name);
      
      if (match) {
        matched.push({ ...rsvp, db_user: match });
        console.log(`✅ Matched: ${rsvp.groupme_name} → ${match.first_name} ${match.last_name} (${match.score}% confidence)`);
      } else {
        unmatched.push(rsvp);
        console.log(`❌ No match: ${rsvp.groupme_name}`);
      }
    }
    
    console.log(`\n📊 Match Summary:`);
    console.log(`   ✅ Matched: ${matched.length}`);
    console.log(`   ❌ Unmatched: ${unmatched.length}`);
    
    if (DRY_RUN) {
      console.log('\n🏃 DRY RUN - No data will be imported\n');
      
      console.log('Would import:');
      matched.forEach(m => {
        console.log(`  - ${m.db_user.first_name} ${m.db_user.last_name}: ${m.status}`);
      });
      
      if (unmatched.length > 0) {
        console.log('\nUnmatched players (need manual mapping):');
        unmatched.forEach(u => {
          console.log(`  - ${u.groupme_name} (GroupMe ID: ${u.groupme_user_id})`);
        });
      }
      
      return;
    }
    
    // Get the most recent practice to link RSVPs to
    const practiceResult = await client.query(`
      SELECT e.id, e.title, e.event_date
      FROM events e
      JOIN practices p ON e.id = p.id
      WHERE p.team_id = $1 AND e.event_date >= NOW()
      ORDER BY e.event_date ASC
      LIMIT 1
    `, [TEAM_ID]);
    
    if (practiceResult.rows.length === 0) {
      console.log('\n⚠️  No upcoming practices found. RSVPs need an event to link to.');
      console.log('   Create a practice first, then run this import again.');
      return;
    }
    
    const practice = practiceResult.rows[0];
    console.log(`\n🎯 Linking RSVPs to: ${practice.title} (${new Date(practice.event_date).toLocaleString()})`);
    
    // Import RSVPs
    console.log('\n💾 Importing RSVPs...');
    
    for (const m of matched) {
      // Get RSVP status ID
      const statusResult = await client.query(
        'SELECT id FROM rsvp_statuses WHERE name = $1',
        [m.status]
      );
      
      if (statusResult.rows.length === 0) {
        console.log(`  ⚠️  Skipping ${m.db_user.first_name}: Unknown status "${m.status}"`);
        continue;
      }
      
      const rsvpStatusId = statusResult.rows[0].id;
      
      // Get bulk_import source ID
      const sourceResult = await client.query(
        'SELECT id FROM rsvp_change_sources WHERE name = $1',
        ['bulk_import']
      );
      
      if (sourceResult.rows.length === 0) {
        console.log(`  ⚠️  Skipping ${m.db_user.first_name}: No bulk_import source found`);
        continue;
      }
      
      const sourceId = sourceResult.rows[0].id;
      
      // Insert RSVP
      await client.query(`
        INSERT INTO player_rsvp_history (event_id, player_id, rsvp_status_id, changed_at, change_source_id, notes)
        VALUES ($1, $2, $3, $4, $5, $6)
      `, [practice.id, m.db_user.id, rsvpStatusId, m.timestamp, sourceId, `Imported from GroupMe: "${m.message}"`]);
      
      console.log(`  ✅ ${m.db_user.first_name} ${m.db_user.last_name}: ${m.status}`);
    }
    
    console.log(`\n✨ Successfully imported ${matched.length} RSVP(s)!`);
    
    if (unmatched.length > 0) {
      console.log(`\n⚠️  ${unmatched.length} player(s) could not be matched:`);
      unmatched.forEach(u => {
        console.log(`   - ${u.groupme_name}`);
      });
      console.log('\n💡 Tip: Add these players to the roster, then re-run the import.');
    }
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    throw error;
  } finally {
    await client.end();
  }
}

// Main
const groupId = process.argv[2];

if (!groupId || groupId === '--help' || groupId === '-h') {
  console.log('GroupMe RSVP Importer\n');
  console.log('Usage:');
  console.log('  node scripts/groupme-import.js <GROUP_ID> [--dry-run]\n');
  console.log('Options:');
  console.log('  --dry-run    Show what would be imported without actually importing\n');
  console.log('Example:');
  console.log('  node scripts/groupme-import.js 108640377 --dry-run');
  process.exit(0);
}

console.log('🚀 GroupMe RSVP Importer\n');
if (DRY_RUN) {
  console.log('🏃 DRY RUN MODE - No data will be modified\n');
}

importRSVPs(groupId).catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
