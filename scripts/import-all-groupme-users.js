#!/usr/bin/env node
/**
 * Import All GroupMe Users from Multiple Groups
 * 
 * MODES:
 *   lighthouse - Create external_identities only (user_id=NULL), no users/team_players
 *   (none)     - Full import: creates users, links them, adds to teams (old behavior)
 * 
 * Usage:
 *   node scripts/import-all-groupme-users.js lighthouse
 *   node scripts/import-all-groupme-users.js
 * 
 * STAGED IMPORT PATTERN:
 *   When mode='lighthouse', script creates user_external_identities with user_id=NULL
 *   instead of creating users. Admin must manually link/merge via Division Roster Management UI.
 */

require('dotenv').config();
const https = require('https');
const { Client } = require('pg');

const ACCESS_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const BASE_URL = 'https://api.groupme.com/v3';
const MODE = process.argv[2]; // 'lighthouse' or undefined (full import)
const GROUPME_PROVIDER_ID = '550e8400-e29b-41d4-a716-446655440a03';

// Configuration: Map GroupMe Group IDs to DB Team IDs
const CLUB_TEAM_ID = 'a16e9445-9bed-4fe6-804d-e77c56258610'; // Lighthouse 1893 SC (The "Club" container)

const GROUP_MAPPINGS = [
  {
    name: 'APSL Lighthouse',
    groupMeId: '109785985',
    dbTeamId: 'a16e9445-9bed-4fe6-804d-e77c56258610', // Lighthouse 1893 SC (APSL)
    // No longer skipping roster import - will use 'chat_only' status for non-official players
  },
  {
    name: 'Lighthouse Boys Club (Liga 1)',
    groupMeId: '109786182',
    dbTeamId: '57d88568-993d-4411-8aa3-6244ca7ff704' // Lighthouse Boys Club (CASA)
  },
  {
    name: 'Lighthouse Old Timers Club (Liga 2)',
    groupMeId: '109786278',
    dbTeamId: 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11' // Lighthouse Old Timers Club (CASA)
  },
  {
    name: 'Training Lighthouse',
    groupMeId: '108640377',
    dbTeamId: '3ee933c4-3ecc-4478-8737-b5a148fcebc7' // Lighthouse Training
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

        if (MODE === 'lighthouse') {
          // LIGHTHOUSE MODE: Create external_identities only, no users/team_players
          
          // Check if identity already exists
          const identityCheck = await client.query(
            `SELECT id FROM user_external_identities 
             WHERE provider_id = $1 AND external_id = $2`,
            [GROUPME_PROVIDER_ID, gmId]
          );

          if (identityCheck.rows.length > 0) {
            stats.skipped++;
          } else {
            // Create new external identity with user_id=NULL
            await client.query(
              `INSERT INTO user_external_identities (provider_id, external_id, external_username, external_data, user_id)
               VALUES ($1, $2, $3, $4::jsonb, NULL)
               ON CONFLICT (provider_id, external_id) DO UPDATE SET
                 external_username = EXCLUDED.external_username,
                 external_data = EXCLUDED.external_data,
                 updated_at = CURRENT_TIMESTAMP`,
              [GROUPME_PROVIDER_ID, gmId, nickname, JSON.stringify({
                first_name: first,
                last_name: last,
                avatar_url: avatar,
                group_name: mapping.name,
                group_id: mapping.groupMeId,
                team_id: mapping.dbTeamId,
                team_name: mapping.name
              })]
            );
            stats.created++;
          }
          
        } else {
          // FULL IMPORT MODE: Create users and link them (old behavior)
          // FULL IMPORT MODE: Create users and link them (old behavior)
          let userId = null;

          // A. Check by GroupMe ID in external identities
          let userResult = await client.query(
            `SELECT user_id FROM user_external_identities 
             WHERE provider_id = $1 AND external_id = $2`,
            [GROUPME_PROVIDER_ID, gmId]
          );

          if (userResult.rows.length > 0) {
            userId = userResult.rows[0].user_id;
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
                `INSERT INTO user_external_identities (user_id, provider_id, external_id, external_username, external_data)
                 VALUES ($1, $2, $3, $4, $5)
                 ON CONFLICT (provider_id, external_id) DO UPDATE SET 
                   external_id = EXCLUDED.external_id,
                   external_username = EXCLUDED.external_username,
                   external_data = EXCLUDED.external_data,
                   updated_at = CURRENT_TIMESTAMP`,
                [userId, GROUPME_PROVIDER_ID, gmId, nickname, JSON.stringify({ avatar_url: avatar })]
              );
              // Also update avatar if not set
              await client.query(
                `UPDATE users SET avatar_url = COALESCE(avatar_url, $1) WHERE id = $2`,
                [avatar, userId]
              );
              stats.updated++;
            } else {
              // C. Create New User - DISABLED per user request (2025-12-24)
              // We do NOT want to automatically create users from GroupMe anymore.
              // They should be imported as identities only (via 'lighthouse' mode) and linked manually.
              console.log(`⚠️  Skipping auto-creation of user for GroupMe member: ${nickname}`);
              stats.skipped++;
              continue;
              
              /* 
              // OLD LOGIC:
              const insertRes = await client.query(
                `INSERT INTO users (first_name, last_name, preferred_name, avatar_url)
                 VALUES ($1, $2, $3, $4)
                 RETURNING id`,
                [first, last, nickname, avatar]
              );
              userId = insertRes.rows[0].id;
              
              // Link GroupMe identity
              await client.query(
                `INSERT INTO user_external_identities (user_id, provider_id, external_id, external_username, external_data)
                 VALUES ($1, $2, $3, $4, $5)`,
                [userId, GROUPME_PROVIDER_ID, gmId, nickname, JSON.stringify({ avatar_url: avatar })]
              );
              
              // Create Player record
              await client.query(
                `INSERT INTO players (id) VALUES ($1) ON CONFLICT (id) DO NOTHING`,
                [userId]
              );
              stats.created++;
              */
            }
          }

          if (userId) {
            // 2. Add to Specific Team
            // Logic: If player is already on team (from scraper), do nothing (keep official status).
            //        If player is NOT on team, add them with status 7 (Chat Only).
            try {
              const teamCheck = await client.query(
                `SELECT id, roster_status_id FROM team_players WHERE team_id = $1 AND player_id = $2`,
                [mapping.dbTeamId, userId]
              );

              if (teamCheck.rows.length === 0) {
                // Not on roster -> Add as Chat Only (7)
                await client.query(
                  `INSERT INTO team_players (team_id, player_id, roster_status_id)
                   VALUES ($1, $2, 7)`,
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
                  // Add to club container as Chat Only (7)
                  await client.query(
                    `INSERT INTO team_players (team_id, player_id, roster_status_id)
                     VALUES ($1, $2, 7)`,
                    [CLUB_TEAM_ID, userId]
                  );
                  stats.clubAdded++;
                }
              } catch (err) {
                console.error(`   ⚠️  Failed to add to club: ${err.message}`);
              }
            }
          }
        } // end else (full import mode)
      } // end for members

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
