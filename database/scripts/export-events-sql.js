#!/usr/bin/env node

/**
 * Export Match Events to SQL Files
 * 
 * Exports all match_events data (plus auto-created persons/players/rosters)
 * from the live database into SQL files that can be loaded via load.sh.
 * 
 * This ensures `make rebuild` + `make load` gives a complete database
 * without needing to run live scrapers.
 * 
 * Outputs:
 *   - usa-apsl/sql/108.00001-event-players-usa-apsl.sql  (auto-created persons/players/rosters)
 *   - usa-apsl/sql/109.00001-match-events-usa-apsl.sql   (APSL match_events)
 *   - usa-csl/sql/108.00003-event-players-usa-csl.sql    (placeholder for future auto-created CSL players)
 *   - usa-csl/sql/109.00003-match-events-usa-csl.sql     (CSL match_events)
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const LEAGUES_DIR = path.join(__dirname, 'leagues');

class EventSqlExporter {
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
    if (this.client) {
      await this.client.end();
    }
  }

  /**
   * Escape a string for SQL single quotes
   */
  esc(str) {
    if (str === null || str === undefined) return 'NULL';
    return str.replace(/'/g, "''");
  }

  /**
   * Export auto-created APSL event players (persons + players + rosters)
   * These are players that were auto-created by the APSL event scraper
   * because they appeared in match events but weren't on any roster.
   */
  async exportApslEventPlayers() {
    // Get auto-created players (IDs 1-208, source_system_id = 1)
    const result = await this.client.query(`
      SELECT p.id as player_id, per.id as person_id, 
             per.first_name, per.last_name,
             p.source_system_id,
             r.team_id, t.name as team_name, t.source_system_id as team_ss_id
      FROM players p
      JOIN persons per ON p.person_id = per.id
      LEFT JOIN rosters r ON p.id = r.player_id
      LEFT JOIN teams t ON r.team_id = t.id
      WHERE p.id < 10000
        AND p.source_system_id = 1
      ORDER BY p.id
    `);

    if (result.rows.length === 0) {
      console.log('  No auto-created APSL players found');
      return;
    }

    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Event Players - APSL (auto-created from match events)
-- Players found in match events but not on any roster page
-- Total Records: ${result.rows.length}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    // Track which persons/players we've already written
    const seenPlayers = new Set();

    for (const row of result.rows) {
      if (seenPlayers.has(row.player_id)) {
        // Player on multiple rosters — just add the roster entry
        if (row.team_name) {
          sql += `INSERT INTO rosters (team_id, player_id, joined_at)\n`;
          sql += `VALUES (\n`;
          sql += `  (SELECT id FROM teams WHERE name = '${this.esc(row.team_name)}' AND source_system_id = ${row.team_ss_id} LIMIT 1),\n`;
          sql += `  ${row.player_id},\n`;
          sql += `  NOW()\n`;
          sql += `);\n\n`;
        }
        continue;
      }
      seenPlayers.add(row.player_id);

      // Person
      sql += `INSERT INTO persons (id, first_name, last_name)\n`;
      sql += `VALUES (${row.person_id}, '${this.esc(row.first_name)}', '${this.esc(row.last_name)}')\n`;
      sql += `ON CONFLICT (id) DO NOTHING;\n`;

      // Player
      sql += `INSERT INTO players (id, person_id, source_system_id)\n`;
      sql += `VALUES (${row.player_id}, ${row.person_id}, ${row.source_system_id || 'NULL'})\n`;
      sql += `ON CONFLICT (id) DO NOTHING;\n`;

      // Roster
      if (row.team_name) {
        sql += `INSERT INTO rosters (team_id, player_id, joined_at)\n`;
        sql += `VALUES (\n`;
        sql += `  (SELECT id FROM teams WHERE name = '${this.esc(row.team_name)}' AND source_system_id = ${row.team_ss_id} LIMIT 1),\n`;
        sql += `  ${row.player_id},\n`;
        sql += `  NOW()\n`;
        sql += `);\n`;
      }

      sql += `\n`;
    }

    const outFile = path.join(LEAGUES_DIR, 'usa-apsl', 'sql', '108.00001-event-players-usa-apsl.sql');
    fs.writeFileSync(outFile, sql);
    console.log(`  ✓ Exported ${result.rows.length} auto-created APSL players → ${path.basename(outFile)}`);
  }

  /**
   * Export match events for a league
   */
  async exportMatchEvents(leagueKey, sourceSystemId, fileCode) {
    const result = await this.client.query(`
      SELECT 
        me.player_id,
        me.event_type_id,
        met.name as event_type_name,
        me.minute,
        me.assisted_by_player_id,
        m.external_id as match_external_id,
        m.source_system_id as match_ss_id,
        t.name as team_name,
        t.source_system_id as team_ss_id
      FROM match_events me
      JOIN matches m ON me.match_id = m.id
      JOIN match_event_types met ON me.event_type_id = met.id
      JOIN teams t ON me.team_id = t.id
      WHERE m.source_system_id = $1
      ORDER BY m.match_date, m.id, me.id
    `, [sourceSystemId]);

    if (result.rows.length === 0) {
      console.log(`  No ${leagueKey} match events found`);
      return;
    }

    const leagueName = leagueKey.toUpperCase().replace('USA-', '');
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Match Events - ${leagueName}
-- Goals, assists, cards, etc. from match event pages
-- Total Records: ${result.rows.length}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    let currentMatchExtId = null;
    let matchCount = 0;

    for (const row of result.rows) {
      // Add a comment for each new match
      if (row.match_external_id !== currentMatchExtId) {
        currentMatchExtId = row.match_external_id;
        matchCount++;
        sql += `-- Match: ${row.match_external_id}\n`;
      }

      sql += `INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)\n`;
      sql += `SELECT\n`;
      sql += `  m.id,\n`;
      sql += `  ${row.player_id},\n`;
      sql += `  t.id,\n`;
      sql += `  (SELECT id FROM match_event_types WHERE name = '${this.esc(row.event_type_name)}'),\n`;
      sql += `  ${row.minute},\n`;
      sql += `  ${row.assisted_by_player_id || 'NULL'}\n`;
      sql += `FROM matches m\n`;
      sql += `JOIN teams t ON t.name = '${this.esc(row.team_name)}' AND t.source_system_id = ${row.team_ss_id}\n`;
      sql += `WHERE m.external_id = '${this.esc(row.match_external_id)}' AND m.source_system_id = ${row.match_ss_id};\n\n`;
    }

    const outFile = path.join(LEAGUES_DIR, leagueKey, 'sql', `109.${fileCode}-match-events-${leagueKey}.sql`);
    fs.writeFileSync(outFile, sql);
    console.log(`  ✓ Exported ${result.rows.length} ${leagueName} match events (${matchCount} matches) → ${path.basename(outFile)}`);
  }

  async run() {
    console.log('📦 Exporting match events to SQL...\n');

    await this.connect();

    try {
      // 1. Export auto-created APSL event players
      console.log('Auto-created event players:');
      await this.exportApslEventPlayers();

      console.log('\nMatch events:');
      // 2. Export APSL match events (source_system_id = 1)
      await this.exportMatchEvents('usa-apsl', 1, '00001');

      // 3. Export CSL match events (source_system_id = 3)
      await this.exportMatchEvents('usa-csl', 3, '00003');

      console.log('\n✓ Export complete');
    } finally {
      await this.disconnect();
    }
  }
}

const exporter = new EventSqlExporter();
exporter.run().catch(err => {
  console.error('Export failed:', err);
  process.exit(1);
});
