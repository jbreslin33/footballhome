#!/usr/bin/env node

/**
 * Export Historical Matches to SQL File
 * 
 * Exports matches from completed/historical seasons (2022-2024) to SQL file.
 * Current season (2025/2026) matches remain dynamic (scraped each update).
 * 
 * Matches are the SOURCE OF TRUTH for standings calculations.
 * Standings are derived data calculated from match results.
 * 
 * Output: database/data/051-matches.sql
 * 
 * Usage: node database/scripts/export-matches.js
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

const OUTPUT_FILE = path.join(__dirname, '../data/051-matches.sql');

function escapeString(str) {
  if (str === null || str === undefined) return 'NULL';
  return `'${str.replace(/'/g, "''")}'`;
}

function formatDate(date) {
  if (!date) return 'NULL';
  const d = new Date(date);
  return `'${d.toISOString().split('T')[0]}'`;
}

function formatTime(time) {
  if (!time) return 'NULL';
  return `'${time}'`;
}

function formatTimestamp(timestamp) {
  if (!timestamp) return 'NULL';
  return `'${new Date(timestamp).toISOString()}'`;
}

async function exportMatches() {
  const client = new Client(DB_CONFIG);
  
  try {
    await client.connect();
    console.log('✓ Connected to database');

    // Query matches from historical seasons only (not current 2025/2026)
    console.log('📊 Fetching historical matches...');
    const result = await client.query(`
      SELECT DISTINCT
        m.id,
        m.match_type_id,
        m.home_team_id,
        m.away_team_id,
        m.match_date,
        m.match_time,
        m.venue_id,
        m.title,
        m.description,
        m.match_status_id,
        m.home_score,
        m.away_score,
        m.round_name,
        m.bracket_position,
        m.next_match_id,
        m.loser_next_match_id,
        m.seed_home,
        m.seed_away,
        m.source_system_id,
        m.external_id,
        m.created_by_user_id,
        m.created_at,
        s.name as season_name,
        l.name as league_name,
        ht.name as home_team_name,
        at.name as away_team_name
      FROM matches m
      LEFT JOIN teams ht ON ht.id = m.home_team_id
      LEFT JOIN teams at ON at.id = m.away_team_id
      LEFT JOIN match_divisions md ON md.match_id = m.id
      LEFT JOIN divisions d ON d.id = md.division_id
      LEFT JOIN seasons s ON s.id = d.season_id
      LEFT JOIN leagues l ON l.id = s.league_id
      WHERE s.name NOT LIKE '%2025%' 
        AND s.name NOT LIKE '%2026%'
      ORDER BY l.name, s.name, m.match_date, m.id
    `);

    const matches = result.rows;
    console.log(`✓ Found ${matches.length} historical matches`);

    if (matches.length === 0) {
      console.log('ℹ️  No historical matches to export');
      return;
    }

    // Build SQL file content
    let sql = '';
    sql += '-- ============================================================================\n';
    sql += '-- HISTORICAL MATCHES EXPORT\n';
    sql += '-- ============================================================================\n';
    sql += `-- Generated: ${new Date().toISOString()}\n`;
    sql += `-- Total Matches: ${matches.length}\n`;
    sql += '-- \n';
    sql += '-- Historical matches from completed seasons (2022-2024).\n';
    sql += '-- Current season matches (2025/2026) remain dynamic via scrapers.\n';
    sql += '-- \n';
    sql += '-- MATCHES ARE SOURCE OF TRUTH:\n';
    sql += '-- - Standings calculated from match results (W/D/L, GF/GA, Points)\n';
    sql += '-- - Match events (goals, cards, subs) linked to these matches\n';
    sql += '-- - Historical progression calculated by querying matches up to date X\n';
    sql += '-- \n';
    sql += '-- Strategy:\n';
    sql += '-- 1. Export matches from historical seasons only\n';
    sql += '-- 2. Use ON CONFLICT DO NOTHING for idempotency\n';
    sql += '-- 3. Let scrapers handle current season matches\n';
    sql += '-- 4. Calculate standings on-the-fly from these results\n';
    sql += '-- ============================================================================\n\n';

    // Group by league and season
    const groupedMatches = {};
    for (const match of matches) {
      const key = `${match.league_name} - ${match.season_name}`;
      if (!groupedMatches[key]) {
        groupedMatches[key] = [];
      }
      groupedMatches[key].push(match);
    }

    // Generate INSERT statements by group
    for (const [groupKey, records] of Object.entries(groupedMatches)) {
      sql += `-- ${groupKey} (${records.length} matches)\n`;
      sql += 'INSERT INTO matches (\n';
      sql += '  id, match_type_id, home_team_id, away_team_id,\n';
      sql += '  match_date, match_time, venue_id, title, description,\n';
      sql += '  match_status_id, home_score, away_score,\n';
      sql += '  round_name, bracket_position, next_match_id, loser_next_match_id,\n';
      sql += '  seed_home, seed_away,\n';
      sql += '  source_system_id, external_id,\n';
      sql += '  created_by_user_id, created_at\n';
      sql += ') VALUES\n';

      const values = records.map((m, idx) => {
        const line = `  (${m.id}, ${m.match_type_id}, ` +
          `${m.home_team_id || 'NULL'}, ${m.away_team_id || 'NULL'}, ` +
          `${formatDate(m.match_date)}, ${formatTime(m.match_time)}, ${m.venue_id || 'NULL'}, ` +
          `${escapeString(m.title)}, ${escapeString(m.description)}, ` +
          `${m.match_status_id || 1}, ${m.home_score || 'NULL'}, ${m.away_score || 'NULL'}, ` +
          `${escapeString(m.round_name)}, ${escapeString(m.bracket_position)}, ` +
          `${m.next_match_id || 'NULL'}, ${m.loser_next_match_id || 'NULL'}, ` +
          `${m.seed_home || 'NULL'}, ${m.seed_away || 'NULL'}, ` +
          `${m.source_system_id || 'NULL'}, ${escapeString(m.external_id)}, ` +
          `${m.created_by_user_id || 'NULL'}, ${formatTimestamp(m.created_at)})`;
        return line + (idx < records.length - 1 ? ',' : '');
      });

      sql += values.join('\n');
      sql += '\nON CONFLICT (source_system_id, external_id) DO NOTHING;\n\n';
    }

    // Update sequence
    sql += '-- Update matches sequence\n';
    sql += `SELECT setval('matches_id_seq', (SELECT MAX(id) FROM matches));\n\n`;

    // Summary
    sql += `-- Summary:\n`;
    sql += `-- Total historical matches: ${matches.length}\n`;
    for (const [groupKey, records] of Object.entries(groupedMatches)) {
      const completed = records.filter(m => m.home_score !== null && m.away_score !== null).length;
      sql += `--   ${groupKey}: ${records.length} matches (${completed} completed)\n`;
    }

    // Write to file
    fs.writeFileSync(OUTPUT_FILE, sql);
    console.log(`✅ Exported ${matches.length} matches to ${OUTPUT_FILE}`);
    
    // Show breakdown
    console.log('\n📋 Breakdown by season:');
    for (const [groupKey, records] of Object.entries(groupedMatches)) {
      const completed = records.filter(m => m.home_score !== null && m.away_score !== null).length;
      console.log(`   ${groupKey}: ${records.length} matches (${completed} with results)`);
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  } finally {
    await client.end();
  }
}

// Run if called directly
if (require.main === module) {
  exportMatches()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error(err);
      process.exit(1);
    });
}

module.exports = { exportMatches };
