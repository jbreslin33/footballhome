#!/usr/bin/env node

/**
 * Export Historical Match Events to SQL File
 * 
 * Exports match events (goals, cards, subs) from completed seasons (2022-2024).
 * Current season (2025/2026) events remain dynamic (scraped each update).
 * 
 * Output: database/data/052-match-events.sql
 * 
 * Usage: node database/scripts/export-match-events.js
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const DB_CONFIG = {
  host: 'localhost',
  port: 5432,
  database: 'footballhome',
  user: 'footballhome_user',
  password: 'footballhome_pass'
};

const OUTPUT_DIR = path.join(__dirname, '../data');
const MATCH_EVENTS_FILE = path.join(OUTPUT_DIR, '052-match-events.sql');
const MATCH_DIVISIONS_FILE = path.join(OUTPUT_DIR, '052b-match-divisions.sql');

function escapeString(str) {
  if (str === null || str === undefined) return 'NULL';
  return `'${str.replace(/'/g, "''")}'`;
}

function formatTimestamp(timestamp) {
  if (!timestamp) return 'NULL';
  return `'${new Date(timestamp).toISOString()}'`;
}

async function exportMatchEvents() {
  const client = new Client(DB_CONFIG);
  
  try {
    await client.connect();
    console.log('✓ Connected to database');

    // Export match_events
    console.log('\n📊 Fetching historical match events...');
    const eventsResult = await client.query(`
      SELECT DISTINCT
        me.id,
        me.match_id,
        me.player_id,
        me.team_id,
        me.event_type_id,
        me.minute,
        me.assisted_by_player_id,
        me.created_at,
        s.name as season_name,
        l.name as league_name
      FROM match_events me
      JOIN matches m ON m.id = me.match_id
      LEFT JOIN match_divisions md ON md.match_id = m.id
      LEFT JOIN divisions d ON d.id = md.division_id
      LEFT JOIN seasons s ON s.id = d.season_id
      LEFT JOIN leagues l ON l.id = s.league_id
      WHERE s.name NOT LIKE '%2025%' 
        AND s.name NOT LIKE '%2026%'
      ORDER BY l.name, s.name, me.match_id, me.minute, me.id
    `);

    const events = eventsResult.rows;
    console.log(`✓ Found ${events.length} historical match events`);

    if (events.length > 0) {
      let sql = '';
      sql += '-- ============================================================================\n';
      sql += '-- HISTORICAL MATCH EVENTS EXPORT\n';
      sql += '-- ============================================================================\n';
      sql += `-- Generated: ${new Date().toISOString()}\n`;
      sql += `-- Total Events: ${events.length}\n`;
      sql += '-- \n';
      sql += '-- Match events from completed seasons (2022-2024).\n';
      sql += '-- Includes goals, assists, cards, substitutions, etc.\n';
      sql += '-- ============================================================================\n\n';

      // Group by league and season
      const groupedEvents = {};
      for (const event of events) {
        const key = `${event.league_name} - ${event.season_name}`;
        if (!groupedEvents[key]) {
          groupedEvents[key] = [];
        }
        groupedEvents[key].push(event);
      }

      // Generate INSERT statements
      for (const [groupKey, records] of Object.entries(groupedEvents)) {
        sql += `-- ${groupKey} (${records.length} events)\n`;
        sql += 'INSERT INTO match_events (\n';
        sql += '  id, match_id, player_id, team_id, event_type_id,\n';
        sql += '  minute, assisted_by_player_id, created_at\n';
        sql += ') VALUES\n';

        const values = records.map((e, idx) => {
          const line = `  (${e.id}, ${e.match_id}, ${e.player_id || 'NULL'}, ${e.team_id || 'NULL'}, ` +
            `${e.event_type_id}, ${e.minute || 'NULL'}, ` +
            `${e.assisted_by_player_id || 'NULL'}, ${formatTimestamp(e.created_at)})`;
          return line + (idx < records.length - 1 ? ',' : '');
        });

        sql += values.join('\n');
        sql += '\nON CONFLICT (id) DO NOTHING;\n\n';
      }

      // Update sequence
      sql += '-- Update match_events sequence\n';
      sql += `SELECT setval('match_events_id_seq', (SELECT MAX(id) FROM match_events));\n\n`;

      // Summary
      sql += `-- Summary:\n`;
      sql += `-- Total historical match events: ${events.length}\n`;
      for (const [groupKey, records] of Object.entries(groupedEvents)) {
        sql += `--   ${groupKey}: ${records.length} events\n`;
      }

      fs.writeFileSync(MATCH_EVENTS_FILE, sql);
      console.log(`✅ Exported ${events.length} match events to ${MATCH_EVENTS_FILE}`);
    }

    // Export match_divisions
    console.log('\n📊 Fetching historical match-division associations...');
    const divisionsResult = await client.query(`
      SELECT DISTINCT
        md.match_id,
        md.division_id,
        md.counts_for_standings,
        s.name as season_name,
        l.name as league_name
      FROM match_divisions md
      JOIN divisions d ON d.id = md.division_id
      JOIN seasons s ON s.id = d.season_id
      JOIN leagues l ON l.id = s.league_id
      WHERE s.name NOT LIKE '%2025%' 
        AND s.name NOT LIKE '%2026%'
      ORDER BY l.name, s.name, md.match_id
    `);

    const matchDivisions = divisionsResult.rows;
    console.log(`✓ Found ${matchDivisions.length} historical match-division associations`);

    if (matchDivisions.length > 0) {
      let sql = '';
      sql += '-- ============================================================================\n';
      sql += '-- HISTORICAL MATCH-DIVISION ASSOCIATIONS EXPORT\n';
      sql += '-- ============================================================================\n';
      sql += `-- Generated: ${new Date().toISOString()}\n`;
      sql += `-- Total Associations: ${matchDivisions.length}\n`;
      sql += '-- \n';
      sql += '-- Links matches to divisions (supports cross-division games).\n';
      sql += '-- ============================================================================\n\n';

      // Group by league and season
      const groupedMD = {};
      for (const md of matchDivisions) {
        const key = `${md.league_name} - ${md.season_name}`;
        if (!groupedMD[key]) {
          groupedMD[key] = [];
        }
        groupedMD[key].push(md);
      }

      // Generate INSERT statements
      for (const [groupKey, records] of Object.entries(groupedMD)) {
        sql += `-- ${groupKey} (${records.length} associations)\n`;
        sql += 'INSERT INTO match_divisions (match_id, division_id, counts_for_standings) VALUES\n';

        const values = records.map((md, idx) => {
          const line = `  (${md.match_id}, ${md.division_id}, ${md.counts_for_standings !== false})`;
          return line + (idx < records.length - 1 ? ',' : '');
        });

        sql += values.join('\n');
        sql += '\nON CONFLICT (match_id, division_id) DO NOTHING;\n\n';
      }

      // Summary
      sql += `-- Summary:\n`;
      sql += `-- Total historical match-division associations: ${matchDivisions.length}\n`;
      for (const [groupKey, records] of Object.entries(groupedMD)) {
        sql += `--   ${groupKey}: ${records.length} associations\n`;
      }

      fs.writeFileSync(MATCH_DIVISIONS_FILE, sql);
      console.log(`✅ Exported ${matchDivisions.length} match-division associations to ${MATCH_DIVISIONS_FILE}`);
    }

    console.log('\n✅ Export complete!');

  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  } finally {
    await client.end();
  }
}

exportMatchEvents().catch(console.error);
