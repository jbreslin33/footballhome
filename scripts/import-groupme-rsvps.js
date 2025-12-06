#!/usr/bin/env node
/**
 * Import GroupMe RSVPs from practice notes JSON
 * 
 * Reads practices with GroupMe data stored in notes field and creates/updates
 * practice_rsvps records based on going/not_going arrays.
 * 
 * Usage: node import-groupme-rsvps.js [--dry-run]
 */

require('dotenv').config();
const { Client } = require('pg');

const DRY_RUN = process.argv.includes('--dry-run');

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'footballhome',
  user: process.env.DB_USER || 'footballhome_user',
  password: process.env.DB_PASSWORD || 'footballhome_pass',
};

// RSVP status IDs from database
const RSVP_ATTENDING = 'c3a3e3f3-3333-3333-3333-333333333331';
const RSVP_NOT_ATTENDING = 'c3a3e3f3-3333-3333-3333-333333333332';

// Change source for GroupMe imports
const CHANGE_SOURCE_GROUPME = '550e8400-e29b-41d4-a716-446655440444'; // GroupMe import

async function importRSVPs() {
  const client = new Client(dbConfig);
  
  try {
    console.log('🔌 Connecting to database...');
    await client.connect();
    console.log('✅ Connected\n');
    
    if (DRY_RUN) {
      console.log('🏃 DRY RUN MODE - No changes will be made\n');
    }
    
    // Get all practices with GroupMe data
    console.log('📋 Fetching practices with GroupMe data...');
    const practicesResult = await client.query(`
      SELECT 
        p.id as practice_id,
        e.title,
        e.event_date,
        p.notes,
        p.team_id
      FROM practices p
      JOIN events e ON p.id = e.id
      WHERE p.notes IS NOT NULL 
        AND p.notes::text LIKE '%event_id%'
      ORDER BY e.event_date
    `);
    
    console.log(`✅ Found ${practicesResult.rows.length} practice(s) with GroupMe data\n`);
    
    if (practicesResult.rows.length === 0) {
      console.log('No practices to process.');
      return;
    }
    
    let totalRSVPs = 0;
    let totalMatched = 0;
    let totalUnmatched = 0;
    let totalCreated = 0;
    let totalUpdated = 0;
    
    for (const practice of practicesResult.rows) {
      console.log(`⚽ ${practice.title}`);
      console.log(`   📅 ${new Date(practice.event_date).toLocaleString()}`);
      
      let groupmeData;
      try {
        groupmeData = JSON.parse(practice.notes);
      } catch (e) {
        console.log(`   ❌ Failed to parse GroupMe data: ${e.message}\n`);
        continue;
      }
      
      const going = groupmeData.going || [];
      const notGoing = groupmeData.not_going || [];
      const rsvpList = groupmeData.rsvp_list || {};
      
      console.log(`   👥 ${going.length} attending, ${notGoing.length} not attending`);
      
      let matched = 0;
      let unmatched = 0;
      let created = 0;
      let updated = 0;
      
      // Process "going" RSVPs
      for (const groupmeId of going) {
        totalRSVPs++;
        
        // Find player by groupme_id (players.id = users.id)
        const playerResult = await client.query(`
          SELECT p.id as player_id
          FROM users u
          JOIN players p ON u.id = p.id
          WHERE u.groupme_id = $1
        `, [groupmeId]);
        
        if (playerResult.rows.length === 0) {
          unmatched++;
          totalUnmatched++;
          continue;
        }
        
        const playerId = playerResult.rows[0].player_id;
        matched++;
        totalMatched++;
        
        if (!DRY_RUN) {
          // Insert into player_rsvp_history
          await client.query(`
            INSERT INTO player_rsvp_history (event_id, player_id, rsvp_status_id, changed_by, change_source_id)
            VALUES ($1, $2, $3, $2, $4)
          `, [practice.practice_id, playerId, RSVP_ATTENDING, CHANGE_SOURCE_GROUPME]);
          
          created++;
          totalCreated++;
        }
      }
      
      // Process "not_going" RSVPs
      for (const groupmeId of notGoing) {
        totalRSVPs++;
        
        // Find player by groupme_id (players.id = users.id)
        const playerResult = await client.query(`
          SELECT p.id as player_id
          FROM users u
          JOIN players p ON u.id = p.id
          WHERE u.groupme_id = $1
        `, [groupmeId]);
        
        if (playerResult.rows.length === 0) {
          unmatched++;
          totalUnmatched++;
          continue;
        }
        
        const playerId = playerResult.rows[0].player_id;
        matched++;
        totalMatched++;
        
        if (!DRY_RUN) {
          // Insert into player_rsvp_history
          await client.query(`
            INSERT INTO player_rsvp_history (event_id, player_id, rsvp_status_id, changed_by, change_source_id)
            VALUES ($1, $2, $3, $2, $4)
          `, [practice.practice_id, playerId, RSVP_NOT_ATTENDING, CHANGE_SOURCE_GROUPME]);
          
          created++;
          totalCreated++;
        }
      }
      
      if (DRY_RUN) {
        console.log(`   ✓ Would process: ${matched} matched, ${unmatched} skipped (no player record)`);
      } else {
        console.log(`   ✅ Created: ${created}, Skipped: ${unmatched}`);
      }
      console.log('');
    }
    
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📊 Summary:');
    console.log(`   Total RSVPs processed: ${totalRSVPs}`);
    console.log(`   ✅ Matched users: ${totalMatched}`);
    console.log(`   ⚠️  Unmatched (skipped): ${totalUnmatched}`);
    
    if (!DRY_RUN) {
      console.log(`   📝 Created: ${totalCreated}`);
    }
    
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    if (totalUnmatched > 0) {
      console.log(`💡 Tip: Run sync-groupme-ids.js to match more users\n`);
    }
    
    if (DRY_RUN) {
      console.log('🏃 DRY RUN - No changes made to database\n');
    }
    
    console.log('✨ Import complete!');
    
  } catch (error) {
    console.error('❌ Error:', error);
    throw error;
  } finally {
    await client.end();
  }
}

// Run the import
importRSVPs()
  .then(() => {
    console.log('Done!');
    process.exit(0);
  })
  .catch(error => {
    console.error('Import failed:', error);
    process.exit(1);
  });
