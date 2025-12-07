#!/usr/bin/env node
/**
 * Import GroupMe Members into the Database
 * 
 * 1. Fetches all members from the GroupMe group.
 * 2. Matches them to existing DB users by GroupMe ID or Name.
 * 3. Creates new users if they don't exist.
 * 4. Adds them to a specified Team in the DB (e.g., "Club Team").
 * 
 * Usage: node scripts/import-groupme-users.js <group_id> <team_id>
 */

require('dotenv').config();
const https = require('https');
const { Client } = require('pg');

const ACCESS_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const BASE_URL = 'https://api.groupme.com/v3';
const GROUP_ID = process.argv[2];
const TEAM_ID = process.argv[3];

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'footballhome',
  user: process.env.DB_USER || 'footballhome_user',
  password: process.env.DB_PASSWORD || 'footballhome_pass',
};

if (!ACCESS_TOKEN || !GROUP_ID || !TEAM_ID) {
  console.error('Usage: node scripts/import-groupme-users.js <group_id> <team_id>');
  process.exit(1);
}

// Helper: GroupMe API Request
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

// Helper: Split Name
function splitName(fullName) {
  const parts = fullName.trim().split(/\s+/);
  if (parts.length === 1) return { first: parts[0], last: 'Unknown' };
  const first = parts[0];
  const last = parts.slice(1).join(' ');
  return { first, last };
}

async function importUsers() {
  const client = new Client(dbConfig);
  
  try {
    await client.connect();
    console.log('🔌 Connected to database');

    // 1. Fetch GroupMe Members
    console.log(`📥 Fetching members from GroupMe group ${GROUP_ID}...`);
    const group = await apiRequest(`/groups/${GROUP_ID}`);
    const members = group.members;
    console.log(`   Found ${members.length} members.`);

    // 2. Process Each Member
    let created = 0;
    let updated = 0;
    let skipped = 0;
    let teamAdded = 0;

    for (const member of members) {
      const gmId = member.user_id;
      const nickname = member.nickname;
      const avatar = member.image_url;
      const { first, last } = splitName(nickname);

      // A. Check by GroupMe ID
      let userResult = await client.query(
        `SELECT user_id as id, u.first_name, u.last_name 
         FROM user_external_identities uei
         JOIN users u ON uei.user_id = u.id
         WHERE uei.provider = 'groupme' AND uei.external_id = $1`,
        [gmId]
      );

      let userId = null;

      if (userResult.rows.length > 0) {
        // Found by ID
        userId = userResult.rows[0].id;
        // console.log(`   ✅ Matched by ID: ${nickname} -> ${userResult.rows[0].first_name} ${userResult.rows[0].last_name}`);
        skipped++;
      } else {
        // B. Check by Name (Fuzzy)
        // Remove emojis and extra spaces for matching
        const cleanName = nickname.replace(/[\u{1F600}-\u{1F6FF}]/gu, '').trim();
        const { first: cFirst, last: cLast } = splitName(cleanName);

        userResult = await client.query(
          `SELECT id FROM users 
           WHERE LOWER(first_name) = LOWER($1) AND LOWER(last_name) = LOWER($2)`,
          [cFirst, cLast]
        );

        if (userResult.rows.length > 0) {
          // Found by Name -> Link GroupMe ID
          userId = userResult.rows[0].id;
          await client.query(
            `INSERT INTO user_external_identities (user_id, provider, external_id, external_username, external_data)
             VALUES ($1, 'groupme', $2, $3, $4)
             ON CONFLICT (user_id, provider) DO UPDATE SET
               external_id = EXCLUDED.external_id,
               external_username = EXCLUDED.external_username,
               external_data = EXCLUDED.external_data,
               updated_at = CURRENT_TIMESTAMP`,
            [userId, gmId, nickname, JSON.stringify({ avatar_url: avatar })]
          );
          await client.query(
            `UPDATE users SET avatar_url = COALESCE(avatar_url, $1) WHERE id = $2`,
            [avatar, userId]
          );
          console.log(`   🔗 Linked GroupMe ID: ${nickname}`);
          updated++;
        } else {
          // C. Create New User
          const insertRes = await client.query(
            `INSERT INTO users (first_name, last_name, preferred_name, avatar_url)
             VALUES ($1, $2, $3, $4)
             RETURNING id`,
            [first, last, nickname, avatar]
          );
          userId = insertRes.rows[0].id;
          
          // Link GroupMe identity
          await client.query(
            `INSERT INTO user_external_identities (user_id, provider, external_id, external_username, external_data)
             VALUES ($1, 'groupme', $2, $3, $4)`,
            [userId, gmId, nickname, JSON.stringify({ avatar_url: avatar })]
          );
          
          // Also create Player record (required for team_players)
          await client.query(
            `INSERT INTO players (id) VALUES ($1) ON CONFLICT (id) DO NOTHING`,
            [userId]
          );
          
          console.log(`   ✨ Created User: ${nickname}`);
          created++;
        }
      }

      // 3. Add to Team (if not already on it)
      if (userId) {
        try {
          // Check if already on team
          const teamCheck = await client.query(
            `SELECT id FROM team_players WHERE team_id = $1 AND player_id = $2`,
            [TEAM_ID, userId]
          );

          if (teamCheck.rows.length === 0) {
            await client.query(
              `INSERT INTO team_players (team_id, player_id, roster_status_id)
               VALUES ($1, $2, 1)`, // 1 = Active/Standard status usually
              [TEAM_ID, userId]
            );
            teamAdded++;
          }
        } catch (err) {
          console.error(`   ⚠️  Failed to add to team: ${err.message}`);
        }
      }
    }

    console.log('\n📊 Summary:');
    console.log(`   Total Members: ${members.length}`);
    console.log(`   Created:       ${created}`);
    console.log(`   Linked/Upd:    ${updated}`);
    console.log(`   Existing:      ${skipped}`);
    console.log(`   Added to Team: ${teamAdded}`);

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await client.end();
  }
}

importUsers();
