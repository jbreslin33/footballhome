#!/usr/bin/env node
/**
 * Export User Data to SQL
 *
 * Exports admin/coach-created data to SQL files so it survives full rebuilds.
 * Output goes to database/user-data/ and is committed to git.
 *
 * Exports:
 *   1. training_attendance (source='manual') → attendance-overrides.sql
 *   2. match_lineups                         → match-lineups.sql
 *
 * Each SQL file uses subquery lookups (by person name + event title) so they
 * don't depend on auto-increment IDs — safe to load into a fresh DB after sync.
 *
 * Usage:  node database/scripts/export-user-data.js
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const OUT_DIR = path.join(__dirname, '..', 'user-data');

class UserDataExporter {
  constructor() {
    this.client = null;
  }

  async connect() {
    this.client = new Client({
      host: 'localhost',
      port: 5432,
      database: 'footballhome',
      user: 'footballhome_user',
      password: 'footballhome_pass'
    });
    await this.client.connect();
  }

  async disconnect() {
    if (this.client) await this.client.end();
  }

  esc(str) {
    if (str === null || str === undefined) return 'NULL';
    return str.replace(/'/g, "''");
  }

  // ==========================================================================
  // 1. Attendance Overrides (source='manual')
  // ==========================================================================
  async exportAttendanceOverrides() {
    const result = await this.client.query(`
      SELECT ta.attended,
             pe.first_name, pe.last_name,
             ce.title as event_title,
             ce.event_date::text as event_date,
             ta.override_note
      FROM training_attendance ta
      JOIN players p ON p.id = ta.player_id
      JOIN persons pe ON pe.id = p.person_id
      JOIN chat_events ce ON ce.id = ta.chat_event_id
      WHERE ta.source = 'manual'
      ORDER BY pe.last_name, pe.first_name, ce.event_date
    `);

    if (result.rows.length === 0) {
      console.log('  No manual attendance overrides found');
      const outFile = path.join(OUT_DIR, 'attendance-overrides.sql');
      fs.writeFileSync(outFile, '-- No manual attendance overrides\n');
      return;
    }

    let sql = `-- Manual attendance overrides (exported ${new Date().toISOString().split('T')[0]})\n`;
    sql += `-- ${result.rows.length} override(s)\n`;
    sql += `-- Loaded after make sync to overlay on GroupMe-seeded attendance\n\n`;

    for (const row of result.rows) {
      const note = row.override_note ? `'${this.esc(row.override_note)}'` : 'NULL';
      sql += `INSERT INTO training_attendance (player_id, chat_event_id, attended, source, override_note)\n`;
      sql += `SELECT p.id, ce.id, ${row.attended}, 'manual', ${note}\n`;
      sql += `FROM players p\n`;
      sql += `JOIN persons pe ON pe.id = p.person_id\n`;
      sql += `CROSS JOIN chat_events ce\n`;
      sql += `WHERE pe.first_name = '${this.esc(row.first_name)}'\n`;
      sql += `  AND pe.last_name = '${this.esc(row.last_name)}'\n`;
      sql += `  AND ce.title = '${this.esc(row.event_title)}'\n`;
      sql += `  AND ce.event_date = '${row.event_date}'\n`;
      sql += `ON CONFLICT (player_id, chat_event_id)\n`;
      sql += `DO UPDATE SET attended = EXCLUDED.attended, source = 'manual', override_note = EXCLUDED.override_note;\n\n`;
    }

    const outFile = path.join(OUT_DIR, 'attendance-overrides.sql');
    fs.writeFileSync(outFile, sql);
    console.log(`  ✓ ${result.rows.length} attendance override(s) → ${outFile}`);
  }

  // ==========================================================================
  // 2. Match Lineups
  // ==========================================================================
  async exportMatchLineups() {
    const result = await this.client.query(`
      SELECT ml.is_starter,
             pe.first_name, pe.last_name,
             m.match_date::text as match_date,
             ht.name as home_team_name,
             at.name as away_team_name,
             t.name as lineup_team_name,
             pos.abbreviation as position_abbr
      FROM match_lineups ml
      JOIN players p ON p.id = ml.player_id
      JOIN persons pe ON pe.id = p.person_id
      JOIN matches m ON m.id = ml.match_id
      JOIN teams t ON t.id = ml.team_id
      LEFT JOIN teams ht ON ht.id = m.home_team_id
      LEFT JOIN teams at ON at.id = m.away_team_id
      LEFT JOIN positions pos ON pos.id = ml.position_id
      ORDER BY m.match_date, ml.is_starter DESC, pe.last_name, pe.first_name
    `);

    if (result.rows.length === 0) {
      console.log('  No match lineups found');
      const outFile = path.join(OUT_DIR, 'match-lineups.sql');
      fs.writeFileSync(outFile, '-- No match lineups\n');
      return;
    }

    let sql = `-- Match lineups (exported ${new Date().toISOString().split('T')[0]})\n`;
    sql += `-- ${result.rows.length} lineup entry/entries\n\n`;

    for (const row of result.rows) {
      const posClause = row.position_abbr
        ? `(SELECT id FROM positions WHERE abbreviation = '${this.esc(row.position_abbr)}')`
        : 'NULL';

      sql += `INSERT INTO match_lineups (match_id, player_id, team_id, is_starter, position_id)\n`;
      sql += `SELECT m.id, p.id, t.id, ${row.is_starter}, ${posClause}\n`;
      sql += `FROM matches m\n`;
      sql += `JOIN teams ht ON ht.id = m.home_team_id\n`;
      sql += `JOIN teams at ON at.id = m.away_team_id\n`;
      sql += `CROSS JOIN players p\n`;
      sql += `JOIN persons pe ON pe.id = p.person_id\n`;
      sql += `CROSS JOIN teams t\n`;
      sql += `WHERE ht.name = '${this.esc(row.home_team_name)}'\n`;
      sql += `  AND at.name = '${this.esc(row.away_team_name)}'\n`;
      sql += `  AND m.match_date = '${row.match_date}'\n`;
      sql += `  AND pe.first_name = '${this.esc(row.first_name)}'\n`;
      sql += `  AND pe.last_name = '${this.esc(row.last_name)}'\n`;
      sql += `  AND t.name = '${this.esc(row.lineup_team_name)}'\n`;
      sql += `ON CONFLICT (match_id, player_id)\n`;
      sql += `DO UPDATE SET is_starter = EXCLUDED.is_starter, position_id = EXCLUDED.position_id, team_id = EXCLUDED.team_id;\n\n`;
    }

    const outFile = path.join(OUT_DIR, 'match-lineups.sql');
    fs.writeFileSync(outFile, sql);
    console.log(`  ✓ ${result.rows.length} lineup entry/entries → ${outFile}`);
  }

  // ==========================================================================
  // Main
  // ==========================================================================
  async run() {
    console.log('📦 Exporting user data to SQL...');
    await this.connect();

    try {
      await this.exportAttendanceOverrides();
      await this.exportMatchLineups();
      console.log('✓ User data export complete → database/user-data/');
    } finally {
      await this.disconnect();
    }
  }
}

const exporter = new UserDataExporter();
exporter.run().catch(err => {
  console.error('❌ Export failed:', err.message);
  process.exit(1);
});
