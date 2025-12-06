#!/usr/bin/env node
/**
 * Import All GroupMe Users from Multiple Groups
 * 
 * 1. Iterates through defined GroupMe Groups (APSL, Boys Club, Old Timers).
 * 2. Fetches members from each group.
 * 3. Upserts users into the DB (matching by GroupMe ID or Name).
 * 4. Adds users to their specific Team (e.g., Boys Club).
 * 5. Adds ALL users to the "Club" Team (Lighthouse 1893 SC) for unified events.
 * 
 * Usage: node scripts/import-all-groupme-users.js
 */

require('dotenv').config();
const https = require('https');
const { Client } = require('pg');

const ACCESS_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const BASE_URL = 'https://api.groupme.com/v3';

// Configuration: Map GroupMe Group IDs to DB Team IDs
const CLUB_TEAM_ID = 'd37eb44b-8e47-0005-9060-f0cbe96fe089'; // Lighthouse 1893 SC (The "Club" container)

const GROUP_MAPPINGS = [
  {
    name: 'APSL Lighthouse',
    groupMeId: '109785985',
    dbTeamId: 'd37eb44b-8e47-0005-9060-f0cbe96fe089' // Same as Club ID for now
  },
  {
    name: 'Lighthouse Boys Club (Liga 1)',
    groupMeId: '109786182',
    dbTeamId: '0b9e8271-fb51-446a-af39-0d2ab69f9448'
  },
  {
    name: 'Lighthouse Old Timers Club (Liga 2)',
    groupMeId: '109786278',
    dbTeamId: '1a7a9174-1093-472e-8dfb-d1275836075f'
  }
];

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'footballhome',
  user: process.env.DB_USER || 'footballhome_user',
  password: process.env.DB_PASSWORD || 'footballhome_pass',
};

if (!ACCESS_TOKEN) {
  console.error('❌ Error: GROUPME_ACCESS_TOKEN not found in .env file');
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
             // If group not found (404), resolve null to skip gracefully
             if (json.meta.code === 404) resolve(null);
             else reject(new Error(`API Error ${json.meta.code}: ${JSON.stringify(json.meta.errors)}`));
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

async function importAllUsers() {
  const client = new Client(dbConfig);
  
  try {
    await client.connect();
    console.log('🔌 Connected to database\n');

    for (const mapping of GROUP_MAPPINGS) {
      console.log(`==================================================`);
      console.log(`📥 Processing Group: ${mapping.name}`);
      console.log(`   GroupMe ID: ${mapping.groupMeId}`);
      console.log(`   Target Team ID: ${mapping.dbTeamId}`);
      console.log(`==================================================`);

      const group = await apiRequest(`/groups/${mapping.groupMeId}`);
      
      if (!group) {
        console.log(`⚠️  Group not found or inaccessible. Skipping.\n`);
        continue;
      }

      const members = group.members;
      console.log(`   Found ${members.length} members.`);

      let stats = { created: 0, updated: 0, skipped: 0, teamAdded: 0, clubAdded: 0 };

      for (const member of members) {
        const gmId = member.user_id;
        const nickname = member.nickname;
        const avatar = member.image_url;
        const { first, last } = splitName(nickname);

        // 1. Find or Create User
        let userId = null;

        // A. Check by GroupMe ID
        let userResult = await client.query(
          `SELECT id FROM users WHERE groupme_id = $1`,
          [gmId]
        );

        if (userResult.rows.length > 0) {
          userId = userResult.rows[0].id;
          stats.skipped++;
        } else {
          // B. Check by Name (Fuzzy)
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
              `UPDATE users SET groupme_id = $1, avatar_url = COALESCE(avatar_url, $2) WHERE id = $3`,
              [gmId, avatar, userId]
            );
            stats.updated++;
          } else {
            // C. Create New User
            const insertRes = await client.query(
              `INSERT INTO users (first_name, last_name, preferred_name, groupme_id, avatar_url)
               VALUES ($1, $2, $3, $4, $5)
               RETURNING id`,
              [first, last, nickname, gmId, avatar]
            );
            userId = insertRes.rows[0].id;
            
            // Create Player record
            await client.query(
              `INSERT INTO players (id) VALUES ($1) ON CONFLICT (id) DO NOTHING`,
              [userId]
            );
            stats.created++;
          }
        }

        if (userId) {
          // 2. Add to Specific Team
          try {
            const teamCheck = await client.query(
              `SELECT id FROM team_players WHERE team_id = $1 AND player_id = $2`,
              [mapping.dbTeamId, userId]
            );

            if (teamCheck.rows.length === 0) {
              await client.query(
                `INSERT INTO team_players (team_id, player_id, roster_status_id)
                 VALUES ($1, $2, 1)`,
                [mapping.dbTeamId, userId]
              );
              stats.teamAdded++;
            }
          } catch (err) {
            console.error(`   ⚠️  Failed to add to team: ${err.message}`);
          }

          // 3. Add to Club Team (if different)
          if (mapping.dbTeamId !== CLUB_TEAM_ID) {
            try {
              const clubCheck = await client.query(
                `SELECT id FROM team_players WHERE team_id = $1 AND player_id = $2`,
                [CLUB_TEAM_ID, userId]
              );

              if (clubCheck.rows.length === 0) {
                await client.query(
                  `INSERT INTO team_players (team_id, player_id, roster_status_id)
                   VALUES ($1, $2, 1)`,
                  [CLUB_TEAM_ID, userId]
                );
                stats.clubAdded++;
              }
            } catch (err) {
              console.error(`   ⚠️  Failed to add to club: ${err.message}`);
            }
          }
        }
      }

      console.log(`   Stats: +${stats.created} New, ^${stats.updated} Linked, =${stats.skipped} Existing`);
      console.log(`          +${stats.teamAdded} to Team, +${stats.clubAdded} to Club\n`);
    }

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await client.end();
  }
}

importAllUsers();
