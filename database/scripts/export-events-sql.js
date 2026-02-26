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
 * NEW ARCHITECTURE: Uses name-based lookups instead of hardcoded IDs.
 * - persons: ON CONFLICT (first_name, last_name) DO NOTHING
 * - players: ON CONFLICT (person_id) DO NOTHING
 * - player_sources: tracks source system observations
 * - rosters: lookup player by person name
 * 
 * Outputs:
 *   - north-america/usa/apsl/sql/108.00001-event-players-apsl.sql  (auto-created persons/players/rosters)
 *   - north-america/usa/apsl/sql/109.00001-match-events-apsl.sql   (APSL match_events)
 *   - north-america/usa/csl/sql/108.00003-event-players-csl.sql    (placeholder for future auto-created CSL players)
 *   - north-america/usa/csl/sql/109.00003-match-events-csl.sql     (CSL match_events)
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
   * Slugify a string for external_id construction
   */
  slugify(str) {
    return str
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '');
  }

  /**
   * Export auto-created event players for a league (persons + players + rosters)
   * These are players that were auto-created by event scrapers
   * because they appeared in match events but weren't on any roster.
   * 
   * NEW: Uses name-based lookups instead of hardcoded IDs.
   */
  async exportEventPlayers(leaguePath, leagueSlug, sourceSystemId, fileCode) {
    const leagueName = leagueSlug.toUpperCase();
    
    // Get auto-created players for this source system that are NOT from roster pages
    // These are players found in match events but not in the standings/roster scrape
    const result = await this.client.query(`
      SELECT DISTINCT per.first_name, per.last_name,
             t.name as team_name, t.source_system_id as team_ss_id,
             t.external_id as team_external_id
      FROM match_events me
      JOIN players p ON me.player_id = p.id
      JOIN persons per ON p.person_id = per.id
      JOIN teams t ON me.team_id = t.id
      LEFT JOIN rosters r ON r.player_id = p.id AND r.team_id = t.id
      WHERE t.source_system_id = $1
        AND r.id IS NULL
      ORDER BY per.last_name, per.first_name
    `, [sourceSystemId]);

    if (result.rows.length === 0) {
      console.log(`  No auto-created ${leagueName} event players found`);
      return;
    }

    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Event Players - ${leagueName} (auto-created from match events)
-- Players found in match events but not on any roster page
-- Total Records: ${result.rows.length}
--
-- Architecture: Name-based lookups (no hardcoded IDs)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    // Track which persons we've already written
    const seenPersons = new Set();

    for (const row of result.rows) {
      const personKey = `${row.first_name.toLowerCase()}|${row.last_name.toLowerCase()}`;
      
      if (!seenPersons.has(personKey)) {
        seenPersons.add(personKey);
        
        // 1. Person (auto-gen ID, skip if name already exists from roster scrape)
        sql += `INSERT INTO persons (first_name, last_name)\n`;
        sql += `VALUES ('${this.esc(row.first_name)}', '${this.esc(row.last_name)}')\n`;
        sql += `ON CONFLICT (first_name, last_name) DO NOTHING;\n`;

        // 2. Player (auto-gen ID, one per person)
        sql += `INSERT INTO players (person_id, source_system_id)\n`;
        sql += `SELECT id, ${sourceSystemId} FROM persons\n`;
        sql += `WHERE first_name = '${this.esc(row.first_name)}' AND last_name = '${this.esc(row.last_name)}'\n`;
        sql += `ON CONFLICT (person_id) DO NOTHING;\n`;
        
        // 3. Player source tracking
        const externalId = this.slugify((row.team_name || '') + '-' + row.first_name + '-' + row.last_name);
        sql += `INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id)\n`;
        sql += `SELECT pl.id, ${sourceSystemId}, '${this.esc(externalId)}', ${row.team_external_id ? `'${this.esc(row.team_external_id)}'` : 'NULL'}\n`;
        sql += `FROM players pl JOIN persons per ON pl.person_id = per.id\n`;
        sql += `WHERE per.first_name = '${this.esc(row.first_name)}' AND per.last_name = '${this.esc(row.last_name)}'\n`;
        sql += `ON CONFLICT (source_system_id, external_id) DO NOTHING;\n`;
      }

      // 4. Roster entry (lookup player and team by name)
      if (row.team_name) {
        sql += `INSERT INTO rosters (team_id, player_id, joined_at)\n`;
        sql += `SELECT t.id, pl.id, NOW()\n`;
        sql += `FROM teams t, players pl\n`;
        sql += `JOIN persons per ON pl.person_id = per.id\n`;
        sql += `WHERE t.name = '${this.esc(row.team_name)}' AND t.source_system_id = ${row.team_ss_id}\n`;
        sql += `  AND per.first_name = '${this.esc(row.first_name)}' AND per.last_name = '${this.esc(row.last_name)}'\n`;
        sql += `ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;\n`;
      }

      sql += `\n`;
    }

    const outFile = path.join(LEAGUES_DIR, leaguePath, 'sql', `108.${fileCode}-event-players-${leagueSlug}.sql`);
    fs.writeFileSync(outFile, sql);
    console.log(`  ✓ Exported ${result.rows.length} auto-created ${leagueName} players → ${path.basename(outFile)}`);
  }

  /**
   * Export match events for a league
   * 
   * NEW: Uses name-based player lookup instead of hardcoded player IDs.
   */
  async exportMatchEvents(leaguePath, leagueSlug, sourceSystemId, fileCode) {
    const result = await this.client.query(`
      SELECT 
        per.first_name as player_first_name,
        per.last_name as player_last_name,
        me.event_type_id,
        met.name as event_type_name,
        me.minute,
        a_per.first_name as assist_first_name,
        a_per.last_name as assist_last_name,
        m.external_id as match_external_id,
        m.source_system_id as match_ss_id,
        t.name as team_name,
        t.source_system_id as team_ss_id
      FROM match_events me
      JOIN matches m ON me.match_id = m.id
      JOIN match_event_types met ON me.event_type_id = met.id
      JOIN teams t ON me.team_id = t.id
      JOIN players p ON me.player_id = p.id
      JOIN persons per ON p.person_id = per.id
      LEFT JOIN players a_p ON me.assisted_by_player_id = a_p.id
      LEFT JOIN persons a_per ON a_p.person_id = a_per.id
      WHERE m.source_system_id = $1
      ORDER BY m.match_date, m.id, me.id
    `, [sourceSystemId]);

    if (result.rows.length === 0) {
      console.log(`  No ${leagueSlug} match events found`);
      return;
    }

    const leagueName = leagueSlug.toUpperCase();
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Match Events - ${leagueName}
-- Goals, assists, cards, etc. from match event pages
-- Total Records: ${result.rows.length}
--
-- Architecture: Name-based player lookups (no hardcoded IDs)
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

      // Build assist subquery if there's an assist
      const assistSubquery = row.assist_first_name 
        ? `(SELECT pl.id FROM players pl JOIN persons per ON pl.person_id = per.id WHERE per.first_name = '${this.esc(row.assist_first_name)}' AND per.last_name = '${this.esc(row.assist_last_name)}' LIMIT 1)`
        : 'NULL';

      sql += `INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)\n`;
      sql += `SELECT\n`;
      sql += `  m.id,\n`;
      sql += `  pl.id,\n`;
      sql += `  t.id,\n`;
      sql += `  (SELECT id FROM match_event_types WHERE name = '${this.esc(row.event_type_name)}'),\n`;
      sql += `  ${row.minute},\n`;
      sql += `  ${assistSubquery}\n`;
      sql += `FROM matches m\n`;
      sql += `JOIN teams t ON t.name = '${this.esc(row.team_name)}' AND t.source_system_id = ${row.team_ss_id}\n`;
      sql += `JOIN players pl ON true\n`;
      sql += `JOIN persons per ON pl.person_id = per.id\n`;
      sql += `  AND per.first_name = '${this.esc(row.player_first_name)}' AND per.last_name = '${this.esc(row.player_last_name)}'\n`;
      sql += `WHERE m.external_id = '${this.esc(row.match_external_id)}' AND m.source_system_id = ${row.match_ss_id};\n\n`;
    }

    const outFile = path.join(LEAGUES_DIR, leaguePath, 'sql', `109.${fileCode}-match-events-${leagueSlug}.sql`);
    fs.writeFileSync(outFile, sql);
    console.log(`  ✓ Exported ${result.rows.length} ${leagueName} match events (${matchCount} matches) → ${path.basename(outFile)}`);
  }

  async run() {
    console.log('📦 Exporting match events to SQL...\n');

    await this.connect();

    try {
      // 1. Export auto-created event players (name-based, no hardcoded IDs)
      console.log('Auto-created event players:');
      await this.exportEventPlayers('north-america/usa/apsl', 'apsl', 1, '00001');

      console.log('\nMatch events:');
      // 2. Export APSL match events (source_system_id = 1)
      await this.exportMatchEvents('north-america/usa/apsl', 'apsl', 1, '00001');

      // 3. Export CSL match events (source_system_id = 3)
      await this.exportMatchEvents('north-america/usa/csl', 'csl', 3, '00003');

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
