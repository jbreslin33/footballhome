#!/usr/bin/env node
/**
 * Import Training Lighthouse Chat Schedule
 * 
 * Imports practices/events from the Training Lighthouse chat.
 * 
 * Usage: node scripts/import-groupme-training-schedule.js
 */

require('dotenv').config();
const https = require('https');
const { Client } = require('pg');

const ACCESS_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const BASE_URL = 'https://api.groupme.com/v3';
const TRAINING_GROUP_ID = '108640377';

// Constants
const CLUB_TEAM_ID = 'd37eb44b-8e47-0005-9060-f0cbe96fe089'; // Lighthouse 1893 SC
const EVENT_TYPE_TRAINING = '550e8400-e29b-41d4-a716-446655440401';
const SOURCE_APP = '550e8400-e29b-41d4-a716-446655440311';

const client = new Client({
  user: process.env.POSTGRES_USER || 'postgres',
  host: process.env.POSTGRES_HOST || 'localhost',
  database: process.env.POSTGRES_DB || 'footballhome',
  password: process.env.POSTGRES_PASSWORD || 'postgres',
  port: process.env.POSTGRES_PORT || 5432,
});

function apiRequest(path) {
  return new Promise((resolve, reject) => {
    const url = `${BASE_URL}${path}${path.includes('?') ? '&' : '?'}token=${ACCESS_TOKEN}`;
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          resolve(json.response || json);
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

async function getAdminUser() {
  const res = await client.query("SELECT id FROM users LIMIT 1");
  return res.rows[0]?.id;
}

async function importSchedule() {
  try {
    await client.connect();
    console.log('🔌 Connected to database');

    const adminUserId = await getAdminUser();
    console.log(`📥 Fetching calendar events from Training chat (${TRAINING_GROUP_ID})...`);
    
    const events = await apiRequest(`/conversations/${TRAINING_GROUP_ID}/events/list`);
    
    if (!events || !events.events || events.events.length === 0) {
      console.log('   No events found');
      return;
    }

    console.log(`   Found ${events.events.length} events`);
    
    let imported = 0;
    let skipped = 0;

    for (const evt of events.events) {
      const groupmeEventId = evt.id;
      const name = evt.name || 'Training';
      const startTime = new Date(evt.start_at * 1000);
      const endTime = evt.end_at ? new Date(evt.end_at * 1000) : new Date(startTime.getTime() + 90 * 60000);
      
      // Check if already imported
      const existing = await client.query(
        `SELECT id FROM events WHERE external_event_id = $1 AND external_source = 'groupme'`,
        [groupmeEventId]
      );

      if (existing.rows.length > 0) {
        skipped++;
        continue;
      }

      // Insert event
      await client.query(
        `INSERT INTO events 
         (team_id, event_type_id, name, start_time, end_time, created_by, source_id, external_event_id, external_source)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'groupme')`,
        [CLUB_TEAM_ID, EVENT_TYPE_TRAINING, name, startTime, endTime, adminUserId, SOURCE_APP, groupmeEventId]
      );

      imported++;
      console.log(`   + ${name} - ${startTime.toLocaleDateString()}`);
    }

    console.log('');
    console.log('✅ Training schedule import complete');
    console.log(`   Imported: ${imported}`);
    console.log(`   Skipped: ${skipped}`);

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

if (!ACCESS_TOKEN) {
  console.error('❌ GROUPME_ACCESS_TOKEN not set in .env');
  process.exit(1);
}

importSchedule();
