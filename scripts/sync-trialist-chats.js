#!/usr/bin/env node
/**
 * Sync Brazil and Puerto Rico Trialist GroupMe members into chat_external_members.
 * Updates chat names to match GroupMe, fetches members, and auto-links to persons
 * where a matching GroupMe user ID already exists in chat_external_members.
 *
 * Usage: node scripts/sync-trialist-chats.js
 */

require('dotenv').config({ path: require('path').join(__dirname, '..', 'env') });
const { Client } = require('pg');

const ACCESS_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const PROVIDER_ID = 1; // GroupMe

const CHATS = [
  { dbId: 8, groupMeId: '114866775', realName: 'Brazil 🇧🇷 Trialists' },
  { dbId: 9, groupMeId: '114866725', realName: 'Puerto Rico 🇵🇷 Trialists' },
];

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'footballhome',
  user: process.env.DB_USER || 'footballhome_user',
  password: process.env.DB_PASSWORD || 'footballhome_pass',
};

async function fetchGroupMembers(groupId) {
  const url = `https://api.groupme.com/v3/groups/${groupId}?token=${ACCESS_TOKEN}`;
  const res = await fetch(url);
  const data = await res.json();
  return data.response?.members || [];
}

async function main() {
  const db = new Client(dbConfig);
  await db.connect();

  try {
    // Load existing GroupMe user_id → person_id mappings from other chats
    const existingLinks = await db.query(
      'SELECT DISTINCT external_user_id, person_id FROM chat_external_members WHERE person_id IS NOT NULL AND provider_id = $1',
      [PROVIDER_ID]
    );
    const knownUsers = new Map(); // external_user_id → person_id
    for (const row of existingLinks.rows) {
      knownUsers.set(row.external_user_id, row.person_id);
    }
    console.log(`Loaded ${knownUsers.size} known GroupMe user→person mappings.`);

    for (const chat of CHATS) {
      console.log(`\n── ${chat.realName} (chat_id=${chat.dbId}, groupMe=${chat.groupMeId}) ──`);

      // Update chat name to match real GroupMe name
      await db.query('UPDATE chats SET name = $1 WHERE id = $2', [chat.realName, chat.dbId]);
      console.log(`  Chat name updated to: ${chat.realName}`);

      const members = await fetchGroupMembers(chat.groupMeId);
      console.log(`  Fetched ${members.length} members from GroupMe`);

      let inserted = 0, updated = 0, skipped = 0;

      for (const m of members) {
        const userId = String(m.user_id);
        const nickname = m.nickname || null;
        const personId = knownUsers.get(userId) || null;

        // Upsert into chat_external_members
        const result = await db.query(
          `INSERT INTO chat_external_members (chat_id, provider_id, external_user_id, external_username, person_id, synced_at)
           VALUES ($1, $2, $3, $4, $5, NOW())
           ON CONFLICT (chat_id, provider_id, external_user_id)
           DO UPDATE SET external_username = EXCLUDED.external_username,
                         person_id = COALESCE(chat_external_members.person_id, EXCLUDED.person_id),
                         synced_at = NOW()
           RETURNING (xmax = 0) AS is_insert`,
          [chat.dbId, PROVIDER_ID, userId, nickname, personId]
        );

        if (result.rows[0]?.is_insert) inserted++;
        else updated++;
        if (personId) console.log(`    Linked: ${nickname} → person_id ${personId}`);
      }

      console.log(`  Done: ${inserted} inserted, ${updated} updated`);
    }

    console.log('\n✓ Sync complete.');
  } finally {
    await db.end();
  }
}

main().catch(err => { console.error('Error:', err.message); process.exit(1); });
