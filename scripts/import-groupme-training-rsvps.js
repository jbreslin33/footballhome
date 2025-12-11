#!/usr/bin/env node
/**
 * Import Training Lighthouse Chat RSVPs
 * 
 * Imports RSVPs from the Training Lighthouse chat for existing events.
 * 
 * Usage: node scripts/import-groupme-training-rsvps.js
 */

require('dotenv').config();
const https = require('https');
const { Client } = require('pg');

const ACCESS_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const BASE_URL = 'https://api.groupme.com/v3';
const TRAINING_GROUP_ID = '108640377';

// RSVP status IDs
const RSVP_YES = '550e8400-e29b-41d4-a716-446655440301';
const RSVP_MAYBE = '550e8400-e29b-41d4-a716-446655440302';
const RSVP_NO = '550e8400-e29b-41d4-a716-446655440303';

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

async function getUserIdByGroupMeId(groupmeId) {
  const res = await client.query(
    "SELECT user_id FROM user_external_identities WHERE provider = 'groupme' AND external_id = $1",
    [groupmeId]
  );
  return res.rows[0]?.user_id;
}

function mapRsvpStatus(status) {
  if (status === 'going') return RSVP_YES;
  if (status === 'not_going') return RSVP_NO;
  return RSVP_MAYBE;
}

async function importRsvps() {
  try {
    await client.connect();
    console.log('🔌 Connected to database');

    console.log(`📥 Fetching events from Training chat (${TRAINING_GROUP_ID})...`);
    const events = await apiRequest(`/conversations/${TRAINING_GROUP_ID}/events/list`);
    
    if (!events || !events.events || events.events.length === 0) {
      console.log('   No events found');
      return;
    }

    console.log(`   Found ${events.events.length} events`);
    
    let totalRsvps = 0;
    let skipped = 0;

    for (const evt of events.events) {
      const groupmeEventId = evt.id;
      
      // Get DB event ID
      const eventRes = await client.query(
        `SELECT id FROM events WHERE external_event_id = $1 AND external_source = 'groupme'`,
        [groupmeEventId]
      );

      if (eventRes.rows.length === 0) {
        continue; // Event not imported yet
      }

      const eventId = eventRes.rows[0].id;
      const rsvps = evt.going || [];

      for (const rsvp of rsvps) {
        const groupmeUserId = rsvp.user_id;
        const userId = await getUserIdByGroupMeId(groupmeUserId);

        if (!userId) {
          continue; // User not linked yet
        }

        // Check if RSVP already exists
        const existing = await client.query(
          `SELECT id FROM event_rsvps WHERE event_id = $1 AND player_id = $2`,
          [eventId, userId]
        );

        if (existing.rows.length > 0) {
          skipped++;
          continue;
        }

        const status = mapRsvpStatus(rsvp.status);

        await client.query(
          `INSERT INTO event_rsvps (event_id, player_id, rsvp_status_id)
           VALUES ($1, $2, $3)`,
          [eventId, userId, status]
        );

        totalRsvps++;
      }
    }

    console.log('');
    console.log('✅ Training RSVPs import complete');
    console.log(`   Imported: ${totalRsvps}`);
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

importRsvps();
