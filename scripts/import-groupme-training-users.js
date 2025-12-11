#!/usr/bin/env node
/**
 * Import GroupMe Training Chat Members to external_identities
 * 
 * Creates external_identities with division_id (Lighthouse 1893 SC division)
 * but NO team_id since all teams in the division use this training chat.
 * 
 * Usage: node scripts/import-groupme-training-users.js
 */

require('dotenv').config();
const https = require('https');
const { Client } = require('pg');

const ACCESS_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const BASE_URL = 'https://api.groupme.com/v3';
const TRAINING_GROUP_ID = '108640377'; // Training Lighthouse chat

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
          if (json.meta && json.meta.code >= 400) {
            reject(new Error(`API Error ${json.meta.code}: ${JSON.stringify(json.meta.errors)}`));
          } else {
            resolve(json.response);
          }
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

function splitName(fullName) {
  const parts = fullName.trim().split(/\s+/);
  if (parts.length === 1) return { first: parts[0], last: '' };
  const first = parts[0];
  const last = parts.slice(1).join(' ');
  return { first, last };
}

async function importTrainingUsers() {
  try {
    await client.connect();
    console.log('🔌 Connected to database');

    // Get Lighthouse 1893 SC sport division ID
    const divisionRes = await client.query(
      "SELECT id FROM sport_divisions WHERE name = 'Lighthouse 1893 SC'"
    );
    
    if (divisionRes.rows.length === 0) {
      console.error('❌ Lighthouse 1893 SC sport division not found in database');
      process.exit(1);
    }
    
    const divisionId = divisionRes.rows[0].id;
    console.log(`📋 Found sport division: Lighthouse 1893 SC (${divisionId})`);

    // Fetch GroupMe members
    console.log(`📥 Fetching members from Training chat (${TRAINING_GROUP_ID})...`);
    const group = await apiRequest(`/groups/${TRAINING_GROUP_ID}`);
    const members = group.members;
    console.log(`   Found ${members.length} members`);

    let created = 0;
    let updated = 0;
    let skipped = 0;

    for (const member of members) {
      const groupmeId = member.user_id;
      const name = member.nickname || member.name || 'Unknown';
      const { first, last } = splitName(name);

      // Check if external_identity already exists
      const existing = await client.query(
        `SELECT id FROM user_external_identities 
         WHERE provider = 'groupme' AND external_id = $1`,
        [groupmeId]
      );

      if (existing.rows.length > 0) {
        // Update sport_division_id if not already set
        const result = await client.query(
          `UPDATE user_external_identities 
           SET sport_division_id = $1, 
               external_username = $2,
               first_name = $3,
               last_name = $4,
               updated_at = CURRENT_TIMESTAMP
           WHERE provider = 'groupme' AND external_id = $5 AND sport_division_id IS NULL
           RETURNING id`,
          [divisionId, name, first, last, groupmeId]
        );
        
        if (result.rows.length > 0) {
          updated++;
          console.log(`   ✓ Updated: ${name} (${groupmeId})`);
        } else {
          skipped++;
        }
      } else {
        // Create new external_identity with sport division context
        await client.query(
          `INSERT INTO user_external_identities 
           (provider, external_id, external_username, sport_division_id, first_name, last_name)
           VALUES ('groupme', $1, $2, $3, $4, $5)`,
          [groupmeId, name, divisionId, first, last]
        );
        created++;
        console.log(`   + Created: ${name} (${groupmeId})`);
      }
    }

    console.log('');
    console.log('✅ Training users import complete');
    console.log(`   Created: ${created}`);
    console.log(`   Updated: ${updated}`);
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

importTrainingUsers();
