#!/usr/bin/env node
/**
 * GroupMe Practice Importer - SIMPLIFIED
 * 
 * This script ONLY imports practices from GroupMe calendar events.
 * NO RSVP logic - just creates practice records.
 * 
 * Usage:
 *   node scripts/import-groupme-practices-simple.js <group_id> [--dry-run]
 *   node scripts/import-groupme-practices-simple.js 108640377 --dry-run
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

// Parse command line arguments
const args = process.argv.slice(2);
const groupId = args[0];
const DRY_RUN = args.includes('--dry-run');

const TEAM_ID = 'd37eb44b-8e47-0005-9060-f0cbe96fe089'; // Lighthouse 1893 SC
const CREATOR_ID = '77d77471-1250-47e0-81ab-d4626595d63c'; // jbreslin
const TRAINING_EVENT_TYPE_ID = '550e8400-e29b-41d4-a716-446655440401'; // Training/Practice

if (!groupId) {
  console.error('Usage: node import-groupme-practices-simple.js <group_id> [--dry-run]');
  console.error('Example: node import-groupme-practices-simple.js 108640377 --dry-run');
  process.exit(1);
}

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
            reject(new Error('Invalid API response'));
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
    const response = await apiRequest(`/conversations/${groupId}/events/list`);
    
    // Check if response has events array
    const events = Array.isArray(response) ? response : (response.events || response.data || []);
    
    if (!Array.isArray(events)) {
      console.error('❌ API response is not an array:', typeof events);
      return [];
    }
    
    console.log(`✅ Found ${events.length} event(s)\n`);
    return events;
  } catch (error) {
    console.error('❌ Error fetching events:', error.message);
    return [];
  }
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
      console.log('No events to import.');
      return;
    }
    
    // Get default venue (Lighthouse)
    const venueResult = await client.query(`
      SELECT id FROM venues WHERE name LIKE 'Lighthouse%' LIMIT 1
    `);
    
    const defaultVenueId = venueResult.rows.length > 0 
      ? venueResult.rows[0].id 
      : null;
    
    console.log('📋 Processing events:\n');
    
    let created = 0;
    let skipped = 0;
    
    for (const event of events) {
      const eventDate = new Date(event.start_at);
      const endDate = new Date(event.end_at);
      const durationMinutes = Math.round((endDate - eventDate) / 60000);
      const title = event.name || 'Practice';
      const description = event.location?.name || '';
      
      console.log(`⚽ ${title}`);
      console.log(`   📅 ${eventDate.toLocaleString()}`);
      console.log(`   ⏱️  Duration: ${durationMinutes} minutes`);
      console.log(`   🆔 GroupMe Event ID: ${event.event_id}`);
      
      if (DRY_RUN) {
        console.log('   🏃 DRY RUN - would create practice\n');
        continue;
      }
      
      // Create event in Football Home
      const eventId = require('crypto').randomUUID();
      
      try {
        await client.query(`
          INSERT INTO events (id, created_by, event_type_id, title, description, event_date, duration_minutes, venue_id)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
          ON CONFLICT (id) DO NOTHING
        `, [eventId, CREATOR_ID, TRAINING_EVENT_TYPE_ID, title, description, eventDate, durationMinutes, defaultVenueId]);
        
        // Save raw GroupMe data as JSON for future RSVP processing
        const groupmeData = {
          event_id: event.event_id,
          going: event.going || [],
          not_going: event.not_going || [],
          rsvp_list: event.rsvp_list || {},
          location: event.location,
          creator_id: event.creator_id,
          timezone: event.timezone,
          created_at: event.created_at,
          updated_at: event.updated_at
        };
        
        // Create practice record with GroupMe data in notes field
        await client.query(`
          INSERT INTO practices (id, team_id, notes)
          VALUES ($1, $2, $3)
          ON CONFLICT (id) DO NOTHING
        `, [eventId, TEAM_ID, JSON.stringify(groupmeData)]);
        
        console.log(`   ✅ Practice created (ID: ${eventId})\n`);
        created++;
        
      } catch (error) {
        console.log(`   ❌ Error creating practice: ${error.message}\n`);
        skipped++;
      }
    }
    
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`📊 Summary:`);
    console.log(`   ✅ Created: ${created}`);
    console.log(`   ⚠️  Skipped: ${skipped}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
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
importPractices(groupId)
  .then(() => {
    console.log('Done!');
    process.exit(0);
  })
  .catch(error => {
    console.error('Import failed:', error);
    process.exit(1);
  });
