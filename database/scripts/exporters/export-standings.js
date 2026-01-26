#!/usr/bin/env node

/**
 * Export Historical Standings to SQL File
 * 
 * Exports FINAL STANDINGS from completed/historical seasons (2022-2024) to SQL file.
 * These are the official published standings from league websites (APSL, CSL, etc.)
 * 
 * Current season (2025/2026) standings remain dynamic (scraped each update).
 * 
 * Standings table = mirror of official league standings (what they publish)
 * Match results = available for analysis/verification, but standings are the official source
 * 
 * Output: database/data/050-standings.sql
 * 
 * Usage: node database/scripts/export-standings.js
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

const OUTPUT_FILE = path.join(__dirname, '../data/050-standings.sql');

function escapeString(str) {
  if (str === null || str === undefined) return 'NULL';
  return `'${str.replace(/'/g, "''")}'`;
}

function formatTimestamp(timestamp) {
  if (!timestamp) return 'NULL';
  return `'${new Date(timestamp).toISOString()}'`;
}

async function exportStandings() {
  const client = new Client(DB_CONFIG);
  
  try {
    await client.connect();
    console.log('✓ Connected to database');

    // Query final standings from historical seasons only (not current 2025/2026)
    console.log('📊 Fetching historical final standings...');
    const result = await client.query(`
      SELECT 
        st.id,
        st.competition_id,
        st.season_id,
        st.team_id,
        st.position,
        st.played,
        st.wins,
        st.draws,
        st.losses,
        st.goals_for,
        st.goals_against,
        st.goal_diff,
        st.points,
        st.fetched_at,
        st.source,
        st.created_at,
        st.updated_at,
        s.name as season_name,
        l.name as league_name,
        t.name as team_name,
        d.name as division_name
      FROM standings st
      JOIN seasons s ON s.id = st.season_id
      JOIN leagues l ON l.id = s.league_id
      JOIN teams t ON t.id = st.team_id
      LEFT JOIN divisions d ON d.id = st.competition_id
      WHERE s.name NOT LIKE '%2025%' 
        AND s.name NOT LIKE '%2026%'
      ORDER BY l.name, s.name, st.competition_id, st.position
    `);

    const standings = result.rows;
    console.log(`✓ Found ${standings.length} historical standings records`);

    if (standings.length === 0) {
      console.log('ℹ️  No historical standings to export');
      return;
    }

    // Build SQL file content
    let sql = '';
    sql += '-- ============================================================================\n';
    sql += '-- HISTORICAL FINAL STANDINGS EXPORT\n';
    sql += '-- ============================================================================\n';
    sql += `-- Generated: ${new Date().toISOString()}\n`;
    sql += `-- Total Records: ${standings.length}\n`;
    sql += '-- \n';
    sql += '-- FINAL STANDINGS from completed seasons (2022-2024).\n';
    sql += '-- These are OFFICIAL PUBLISHED STANDINGS from league websites.\n';
    sql += '-- Current season standings (2025/2026) remain dynamic via scrapers.\n';
    sql += '-- \n';
    sql += '-- Strategy:\n';
    sql += '-- - Standings table = mirror of what leagues officially publish\n';
    sql += '-- - Website displays standings from this table (official source)\n';
    sql += '-- - Match results available for analysis/verification (separate table)\n';
    sql += '-- - Historical seasons = frozen final standings (this file)\n';
    sql += '-- - Current season = dynamic live standings (scraped)\n';
    sql += '-- ============================================================================\n\n';

    // Group by league and season
    const groupedStandings = {};
    for (const standing of standings) {
      const key = `${standing.league_name} - ${standing.season_name}`;
      if (!groupedStandings[key]) {
        groupedStandings[key] = [];
      }
      groupedStandings[key].push(standing);
    }

    // Generate INSERT statements by group
    for (const [groupKey, records] of Object.entries(groupedStandings)) {
      sql += `-- ${groupKey} (${records.length} teams)\n`;
      sql += 'INSERT INTO standings (\n';
      sql += '  id, competition_id, season_id, team_id, position,\n';
      sql += '  played, wins, draws, losses,\n';
      sql += '  goals_for, goals_against, goal_diff, points,\n';
      sql += '  fetched_at, source, created_at, updated_at\n';
      sql += ') VALUES\n';

      const values = records.map((st, idx) => {
        const line = `  (${st.id}, ${st.competition_id}, ${st.season_id}, ${st.team_id}, ${st.position || 'NULL'}, ` +
          `${st.played || 0}, ${st.wins || 0}, ${st.draws || 0}, ${st.losses || 0}, ` +
          `${st.goals_for || 0}, ${st.goals_against || 0}, ${st.goal_diff || 0}, ${st.points || 0}, ` +
          `${formatTimestamp(st.fetched_at)}, ${escapeString(st.source)}, ` +
          `${formatTimestamp(st.created_at)}, ${formatTimestamp(st.updated_at)})`;
        return line + (idx < records.length - 1 ? ',' : '');
      });

      sql += values.join('\n');
      sql += '\nON CONFLICT (competition_id, season_id, team_id) DO NOTHING;\n\n';
    }

    // Update sequence
    sql += '-- Update standings sequence\n';
    sql += `SELECT setval('standings_id_seq', (SELECT MAX(id) FROM standings));\n\n`;

    // Summary
    sql += `-- Summary:\n`;
    sql += `-- Total historical final standings: ${standings.length}\n`;
    for (const [groupKey, records] of Object.entries(groupedStandings)) {
      sql += `--   ${groupKey}: ${records.length} teams\n`;
    }

    // Write to file
    fs.writeFileSync(OUTPUT_FILE, sql);
    console.log(`✅ Exported ${standings.length} final standings records to ${OUTPUT_FILE}`);
    
    // Show breakdown
    console.log('\n📋 Breakdown by season:');
    for (const [groupKey, records] of Object.entries(groupedStandings)) {
      console.log(`   ${groupKey}: ${records.length} teams`);
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
  exportStandings()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error(err);
      process.exit(1);
    });
}

module.exports = { exportStandings };
