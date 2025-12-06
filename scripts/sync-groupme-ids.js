#!/usr/bin/env node

/**
 * Sync GroupMe IDs to Users Table
 * 
 * Fetches GroupMe group members and updates the users table with their GroupMe IDs
 * based on name matching. Run this before importing practices to enable direct ID matching.
 * 
 * Usage: node scripts/sync-groupme-ids.js <group_id> [--dry-run]
 */

require('dotenv').config();
const https = require('https');
const { Client } = require('pg');

const GROUPME_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const TEAM_ID = 'd37eb44b-8e47-0005-9060-f0cbe96fe089'; // Lighthouse 1893 SC

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'footballhome',
  user: process.env.DB_USER || 'footballhome_user',
  password: process.env.DB_PASSWORD || 'footballhome_pass',
};

// Parse command line arguments
const args = process.argv.slice(2);
const groupId = args[0];
const DRY_RUN = args.includes('--dry-run');

if (!groupId) {
  console.error('Usage: node sync-groupme-ids.js <group_id> [--dry-run]');
  console.error('Example: node sync-groupme-ids.js 108640377 --dry-run');
  process.exit(1);
}

if (!GROUPME_TOKEN) {
  console.error('Error: GROUPME_ACCESS_TOKEN not found in .env');
  process.exit(1);
}

// Make API request to GroupMe
function apiRequest(path) {
  return new Promise((resolve, reject) => {
    const url = `https://api.groupme.com/v3${path}?token=${GROUPME_TOKEN}`;
    
    https.get(url, (res) => {
      let data = '';
      
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (json.response) {
            resolve(json.response);
          } else {
            reject(new Error('Invalid API response'));
          }
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

// Fetch group members from GroupMe API
async function fetchGroupMembers(groupId) {
  console.log('👥 Fetching group members from GroupMe...');
  
  try {
    const response = await apiRequest(`/groups/${groupId}`);
    const members = response.members || [];
    
    console.log(`✅ Found ${members.length} group members\n`);
    return members;
  } catch (error) {
    console.error('❌ Error fetching members:', error.message);
    return [];
  }
}

// Fuzzy name matching
function matchName(groupmeName, dbFirstName, dbLastName, dbPreferredName) {
  const gName = groupmeName.toLowerCase().trim();
  const first = dbFirstName.toLowerCase().trim();
  const last = dbLastName.toLowerCase().trim();
  const preferred = dbPreferredName ? dbPreferredName.toLowerCase().trim() : '';
  const full = `${first} ${last}`;
  const preferredFull = preferred ? `${preferred} ${last}` : '';
  
  // Exact matches
  if (gName === full || gName === preferredFull) return 100;
  if (gName === first || gName === last || gName === preferred) return 90;
  
  // Contains matches
  if (full.includes(gName) || gName.includes(full)) return 80;
  if (preferredFull && (preferredFull.includes(gName) || gName.includes(preferredFull))) return 85;
  if (gName.includes(first) || first.includes(gName)) return 70;
  if (gName.includes(last) || last.includes(gName)) return 70;
  if (preferred && (gName.includes(preferred) || preferred.includes(gName))) return 75;
  
  // Initial + last name
  if (gName.startsWith(first[0]) && gName.includes(last)) return 60;
  if (preferred && gName.startsWith(preferred[0]) && gName.includes(last)) return 65;
  
  return 0;
}

// Main sync function
async function syncGroupMeIds(groupId) {
  const client = new Client(dbConfig);
  
  try {
    console.log('🔌 Connecting to database...');
    await client.connect();
    console.log('✅ Connected\n');
    
    // Fetch GroupMe members
    const members = await fetchGroupMembers(groupId);
    
    if (members.length === 0) {
      console.log('No members to sync.');
      return;
    }
    
    // Get all users on the team from roster
    const result = await client.query(`
      SELECT DISTINCT
        u.id, 
        u.first_name, 
        u.last_name, 
        u.preferred_name,
        u.email,
        u.groupme_id
      FROM users u
      JOIN rosters r ON u.id = r.player_id
      WHERE r.team_id = $1 AND r.is_active = true
      ORDER BY u.last_name, u.first_name
    `, [TEAM_ID]);
    
    console.log(`📋 Processing ${result.rows.length} team members:\n`);
    
    let updated = 0;
    let skipped = 0;
    let alreadySet = 0;
    
    for (const user of result.rows) {
      // Skip if already has groupme_id
      if (user.groupme_id) {
        alreadySet++;
        continue;
      }
      
      // Find best matching GroupMe member
      let bestMatch = null;
      let bestScore = 0;
      
      for (const member of members) {
        const score = matchName(
          member.nickname || member.name,
          user.first_name,
          user.last_name,
          user.preferred_name
        );
        
        if (score > bestScore) {
          bestScore = score;
          bestMatch = member;
        }
      }
      
      const displayName = user.preferred_name || user.first_name;
      
      if (bestMatch && bestScore >= 60) {
        console.log(`✅ ${displayName} ${user.last_name}`);
        console.log(`   → ${bestMatch.nickname || bestMatch.name} (${bestScore}% match)`);
        console.log(`   → GroupMe ID: ${bestMatch.user_id}`);
        
        if (!DRY_RUN) {
          await client.query(`
            UPDATE users 
            SET groupme_id = $1, updated_at = NOW()
            WHERE id = $2
          `, [bestMatch.user_id, user.id]);
        } else {
          console.log(`   🏃 DRY RUN - would update`);
        }
        
        updated++;
        console.log('');
      } else {
        console.log(`⚠️  ${displayName} ${user.last_name}`);
        console.log(`   → No good match found (best: ${bestScore}%)`);
        console.log('');
        skipped++;
      }
    }
    
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`📊 Summary:`);
    console.log(`   ✅ Updated: ${updated}`);
    console.log(`   ⏭️  Already set: ${alreadySet}`);
    console.log(`   ⚠️  Skipped (no match): ${skipped}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    if (DRY_RUN) {
      console.log('🏃 DRY RUN - No changes made to database');
      console.log('   Run without --dry-run to apply changes\n');
    }
    
    if (skipped > 0) {
      console.log('💡 Tip: For users with no match, manually set groupme_id:');
      console.log('   UPDATE users SET groupme_id = \'<their_groupme_id>\' WHERE email = \'user@example.com\';\n');
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
    throw error;
  } finally {
    await client.end();
  }
}

// Run the sync
syncGroupMeIds(groupId)
  .then(() => {
    console.log('✨ Sync complete!');
    process.exit(0);
  })
  .catch(error => {
    console.error('Sync failed:', error);
    process.exit(1);
  });
