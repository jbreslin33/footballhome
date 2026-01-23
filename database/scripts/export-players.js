#!/usr/bin/env node

/**
 * Export Players to SQL File
 * 
 * Exports all persons and players from the database to a SQL file.
 * Players are entities (like teams) - not relationships.
 * Once exported to SQL, scrapers should lookup existing players instead of creating duplicates.
 * 
 * Output: database/data/053-players.sql
 * 
 * Usage: node database/scripts/export-players.js
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

const OUTPUT_FILE = path.join(__dirname, '../data/053-players.sql');

function escapeString(str) {
  if (str === null || str === undefined) return 'NULL';
  return `'${str.replace(/'/g, "''")}'`;
}

function formatDate(date) {
  if (!date) return 'NULL';
  return `'${date.toISOString().split('T')[0]}'`;
}

function formatTimestamp(timestamp) {
  if (!timestamp) return 'NULL';
  return `'${timestamp.toISOString()}'`;
}

async function exportPlayers() {
  const client = new Client(DB_CONFIG);
  
  try {
    await client.connect();
    console.log('✓ Connected to database');

    // Query all players with their person data
    console.log('📊 Fetching players...');
    const result = await client.query(`
      SELECT 
        p.id as person_id,
        p.first_name,
        p.last_name,
        p.birth_date,
        p.created_at as person_created_at,
        p.updated_at as person_updated_at,
        pl.id as player_id,
        pl.height_cm,
        pl.nationality,
        pl.photo_url,
        pl.source_system_id,
        pl.external_id,
        pl.created_at as player_created_at,
        pl.updated_at as player_updated_at,
        ss.name as source_system_name
      FROM persons p
      INNER JOIN players pl ON pl.person_id = p.id
      LEFT JOIN source_systems ss ON pl.source_system_id = ss.id
      ORDER BY p.last_name, p.first_name, p.id
    `);

    const players = result.rows;
    console.log(`✓ Found ${players.length} players`);

    if (players.length === 0) {
      console.log('ℹ️  No players to export');
      return;
    }

    // Build SQL file content
    let sql = '';
    sql += '-- ============================================================================\n';
    sql += '-- PLAYERS EXPORT (Persons + Players)\n';
    sql += '-- ============================================================================\n';
    sql += `-- Generated: ${new Date().toISOString()}\n`;
    sql += `-- Total Players: ${players.length}\n`;
    sql += '-- \n';
    sql += '-- Players are entities (like teams), not relationships.\n';
    sql += '-- Scrapers should lookup existing players before creating new ones.\n';
    sql += '-- \n';
    sql += '-- Strategy:\n';
    sql += '-- 1. Insert persons (with ON CONFLICT DO NOTHING for idempotency)\n';
    sql += '-- 2. Insert players (with ON CONFLICT DO NOTHING for idempotency)\n';
    sql += '-- ============================================================================\n\n';

    // Group by source system for better organization
    const bySource = {};
    players.forEach(player => {
      const source = player.source_system_name || 'manual';
      if (!bySource[source]) bySource[source] = [];
      bySource[source].push(player);
    });

    // Generate INSERT statements for each source
    for (const [sourceName, sourcePlayers] of Object.entries(bySource)) {
      sql += `-- ============================================================================\n`;
      sql += `-- ${sourceName.toUpperCase()} Players (${sourcePlayers.length})\n`;
      sql += `-- ============================================================================\n\n`;

      // Persons INSERT
      sql += `-- Insert persons (idempotent)\n`;
      sql += `INSERT INTO persons (id, first_name, last_name, birth_date, created_at, updated_at)\n`;
      sql += `VALUES\n`;
      
      const personValues = sourcePlayers.map((player, idx) => {
        const comma = idx < sourcePlayers.length - 1 ? ',' : '';
        return `    (${player.person_id}, ${escapeString(player.first_name)}, ${escapeString(player.last_name)}, ${formatDate(player.birth_date)}, ${formatTimestamp(player.person_created_at)}, ${formatTimestamp(player.person_updated_at)})${comma}`;
      });
      
      sql += personValues.join('\n');
      sql += '\n';
      sql += `ON CONFLICT (id) DO NOTHING;\n\n`;

      // Update sequence to max ID
      const maxPersonId = Math.max(...sourcePlayers.map(p => p.person_id));
      sql += `-- Update persons sequence\n`;
      sql += `SELECT setval('persons_id_seq', (SELECT GREATEST(${maxPersonId}, (SELECT MAX(id) FROM persons))));\n\n`;

      // Players INSERT
      sql += `-- Insert players (idempotent)\n`;
      sql += `INSERT INTO players (id, person_id, height_cm, nationality, photo_url, source_system_id, external_id, created_at, updated_at)\n`;
      sql += `VALUES\n`;
      
      const playerValues = sourcePlayers.map((player, idx) => {
        const comma = idx < sourcePlayers.length - 1 ? ',' : '';
        const heightCm = player.height_cm ? player.height_cm : 'NULL';
        const nationality = player.nationality ? escapeString(player.nationality) : 'NULL';
        const photoUrl = player.photo_url ? escapeString(player.photo_url) : 'NULL';
        const sourceSystemId = player.source_system_id ? player.source_system_id : 'NULL';
        const externalId = player.external_id ? escapeString(player.external_id) : 'NULL';
        
        return `    (${player.player_id}, ${player.person_id}, ${heightCm}, ${nationality}, ${photoUrl}, ${sourceSystemId}, ${externalId}, ${formatTimestamp(player.player_created_at)}, ${formatTimestamp(player.player_updated_at)})${comma}`;
      });
      
      sql += playerValues.join('\n');
      sql += '\n';
      sql += `ON CONFLICT (id) DO NOTHING;\n\n`;

      // Update sequence to max ID
      const maxPlayerId = Math.max(...sourcePlayers.map(p => p.player_id));
      sql += `-- Update players sequence\n`;
      sql += `SELECT setval('players_id_seq', (SELECT GREATEST(${maxPlayerId}, (SELECT MAX(id) FROM players))));\n\n`;
    }

    // Summary
    sql += '-- ============================================================================\n';
    sql += '-- EXPORT SUMMARY\n';
    sql += '-- ============================================================================\n';
    sql += `-- Total persons: ${players.length}\n`;
    sql += `-- Total players: ${players.length}\n`;
    for (const [sourceName, sourcePlayers] of Object.entries(bySource)) {
      sql += `--   ${sourceName}: ${sourcePlayers.length} players\n`;
    }
    sql += '-- ============================================================================\n';

    // Write to file
    fs.writeFileSync(OUTPUT_FILE, sql);
    console.log(`✅ Exported ${players.length} players to ${path.basename(OUTPUT_FILE)}`);
    
    // Summary by source
    console.log('\n📋 Breakdown by source:');
    for (const [sourceName, sourcePlayers] of Object.entries(bySource)) {
      console.log(`   ${sourceName}: ${sourcePlayers.length} players`);
    }

  } catch (err) {
    console.error('❌ Error exporting players:', err);
    process.exit(1);
  } finally {
    await client.end();
  }
}

// Run if called directly
if (require.main === module) {
  exportPlayers();
}

module.exports = { exportPlayers };
