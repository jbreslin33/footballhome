/**
 * SqlAppender
 * 
 * Converts a LeagueDiff result into SQL statements.
 * Appends INSERT/UPDATE/DELETE to the appropriate league SQL files.
 * Also runs the SQL against the live database.
 * 
 * Strategy per entity type:
 *   teams:     INSERT new, DELETE removed (rare)
 *   matches:   INSERT new, DELETE cancelled, UPDATE scores/status
 *   standings: Full REPLACE (standings are always "current state")
 *   players:   INSERT new, DELETE dropped
 */
const fs = require('fs');
const path = require('path');

class SqlAppender {
  /**
   * @param {Object} config - League config from config.json
   * @param {string} sqlDir - Path to league's sql/ directory
   */
  constructor(config, sqlDir) {
    this.config = config;
    this.sqlDir = sqlDir;
    this.sqlStatements = []; // Accumulated SQL for running against DB
  }

  /**
   * Escape single quotes for SQL
   */
  escapeSql(str) {
    if (!str) return '';
    return String(str).replace(/'/g, "''");
  }

  /**
   * Generate SQL from a diff result and append to league SQL files
   * @param {Object} diff - Output from LeagueDiff.compute()
   * @returns {string[]} Array of SQL statements to run against DB
   */
  generateSql(diff) {
    this.sqlStatements = [];
    const timestamp = new Date().toISOString().split('T')[0]; // YYYY-MM-DD

    // === ORDER MATTERS FOR FK CONSTRAINTS ===
    // 1. DELETEs: matches before teams (matches reference teams via FK)
    // 2. INSERTs: teams before matches (matches need team rows to exist)

    // Phase 1: DELETE matches first (FK: matches → teams)
    if (diff.matches.removed.length > 0) {
      this._appendMatchDeletesSql(diff.matches.removed, timestamp);
    }

    // Phase 2: DELETE teams (now safe — no matches referencing them)
    if (diff.teams.removed.length > 0) {
      this._appendTeamDeletesSql(diff.teams.removed, timestamp);
    }

    // Phase 3: INSERT teams (must exist before inserting matches)
    if (diff.teams.added.length > 0) {
      this._appendTeamInsertsSql(diff.teams.added, timestamp);
    }

    // Phase 4: INSERT + UPDATE matches
    if (diff.matches.added.length > 0 || diff.matches.updated.length > 0) {
      this._appendMatchChangesSql(diff.matches, timestamp);
    }

    // Standings: Full rewrite (standings are "current state")
    // Note: standings SQL file (104) is always REWRITTEN, not appended to
    // The diff is used for logging only

    // Players: INSERT added, DELETE removed
    if (diff.players.added.length > 0 || diff.players.removed.length > 0) {
      this._appendPlayersSql(diff.players, timestamp);
    }

    return this.sqlStatements;
  }

  /**
   * Append team DELETE statements to SQL file
   */
  _appendTeamDeletesSql(removedTeams, timestamp) {
    const filePath = this._findSqlFile('102');
    if (!filePath) return;

    const lines = [];
    lines.push(`\n-- === REMOVALS ${timestamp} ===`);

    const sourceSystemId = this.config.sourceSystemId;

    for (const team of removedTeams) {
      const sql = `DELETE FROM teams WHERE source_system_id = ${sourceSystemId} AND external_id = '${this.escapeSql(team.externalId)}';`;
      lines.push(`-- Removed: ${team.name} (${team.divisionName})`);
      lines.push(sql);
      this.sqlStatements.push(sql);
    }

    fs.appendFileSync(filePath, lines.join('\n') + '\n');
    console.log(`   ✏️  Appended ${removedTeams.length} team removes to ${path.basename(filePath)}`);
  }

  /**
   * Append team INSERT statements to SQL file
   */
  _appendTeamInsertsSql(addedTeams, timestamp) {
    const filePath = this._findSqlFile('102');
    if (!filePath) return;

    const lines = [];
    lines.push(`\n-- === ADDITIONS ${timestamp} ===`);

    const sourceSystemId = this.config.sourceSystemId;
    const season = this.config.activeSeason;
    const leagueId = this.config.leagueDbId;

    for (const team of addedTeams) {
      const externalId = team.externalId;
      const sql = `INSERT INTO teams (name, external_id, division_id, source_system_id)
SELECT '${this.escapeSql(team.name)}', '${this.escapeSql(externalId)}', d.id, ${sourceSystemId}
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = '${this.escapeSql(team.divisionName)}'
  AND s.name = '${season}'
  AND s.league_id = ${leagueId}
ON CONFLICT (division_id, name) DO NOTHING;`;
      lines.push(`-- Added: ${team.name} (${team.divisionName})`);
      lines.push(sql);
      this.sqlStatements.push(sql);
    }

    fs.appendFileSync(filePath, lines.join('\n') + '\n');
    console.log(`   ✏️  Appended ${addedTeams.length} team adds to ${path.basename(filePath)}`);
  }

  /**
   * Append match DELETE statements to SQL file (run BEFORE team deletes)
   */
  _appendMatchDeletesSql(removedMatches, timestamp) {
    const filePath = this._findSqlFile('106');
    if (!filePath) return;

    const lines = [];
    lines.push(`\n-- === REMOVALS ${timestamp} ===`);

    const sourceSystemId = this.config.sourceSystemId;

    for (const match of removedMatches) {
      const sql = `DELETE FROM matches WHERE source_system_id = ${sourceSystemId} AND external_id = '${this.escapeSql(match.externalId)}';`;
      lines.push(`-- Removed: ${match.homeTeam} vs ${match.awayTeam}`);
      lines.push(sql);
      this.sqlStatements.push(sql);
    }

    fs.appendFileSync(filePath, lines.join('\n') + '\n');
    console.log(`   ✏️  Appended ${removedMatches.length} match removes to ${path.basename(filePath)}`);
  }

  /**
   * Append match INSERT + UPDATE statements to SQL file (run AFTER team inserts)
   */
  _appendMatchChangesSql(matchesDiff, timestamp) {
    const filePath = this._findSqlFile('106');
    if (!filePath) return;

    const lines = [];
    lines.push(`\n-- === CHANGES ${timestamp} ===`);
    lines.push(`-- Added: ${matchesDiff.added.length}, Updated: ${matchesDiff.updated.length}`);

    const sourceSystemId = this.config.sourceSystemId;

    // Added matches
    for (const match of matchesDiff.added) {
      const matchStatus = match.status === 'completed' ? 3 : 1;
      // Use actual team external IDs if available, fall back to division+slug for leagues without numeric IDs
      const homeTeamExternalId = match.homeTeamExternalId || `${match.divisionExternalId}-${match.homeTeam.toLowerCase().replace(/\s+/g, '-')}`;
      const awayTeamExternalId = match.awayTeamExternalId || `${match.divisionExternalId}-${match.awayTeam.toLowerCase().replace(/\s+/g, '-')}`;

      const sql = `INSERT INTO matches (
  match_type_id, match_date, match_time, match_status_id,
  home_team_id, away_team_id, venue_id,
  home_score, away_score, source_system_id, external_id
)
SELECT
  1, '${match.date || '2026-01-01'}', ${match.time ? `'${this.escapeSql(match.time)}'` : 'NULL'}, ${matchStatus},
  ht.id, at.id, NULL,
  ${match.homeScore !== null ? match.homeScore : 'NULL'}, ${match.awayScore !== null ? match.awayScore : 'NULL'},
  ${sourceSystemId}, '${this.escapeSql(match.externalId)}'
FROM teams ht
JOIN teams at ON at.external_id = '${this.escapeSql(awayTeamExternalId)}' AND at.source_system_id = ${sourceSystemId}
WHERE ht.external_id = '${this.escapeSql(homeTeamExternalId)}' AND ht.source_system_id = ${sourceSystemId}
ON CONFLICT (source_system_id, external_id) DO NOTHING;`;
      lines.push(`-- Added: ${match.homeTeam} vs ${match.awayTeam}`);
      lines.push(sql);
      this.sqlStatements.push(sql);
    }

    // Updated matches (score changes, status changes)
    for (const change of matchesDiff.updated) {
      const match = change.new;
      const setClauses = [];

      for (const c of change.changes) {
        if (c.field === 'homeScore' && c.to !== null) setClauses.push(`home_score = ${c.to}`);
        if (c.field === 'awayScore' && c.to !== null) setClauses.push(`away_score = ${c.to}`);
        if (c.field === 'status') {
          const statusId = c.to === 'completed' ? 3 : c.to === 'cancelled' ? 4 : 1;
          setClauses.push(`match_status_id = ${statusId}`);
        }
        if (c.field === 'date' && c.to) setClauses.push(`match_date = '${c.to}'`);
        if (c.field === 'time' && c.to) setClauses.push(`match_time = '${this.escapeSql(c.to)}'`);
      }

      if (setClauses.length > 0) {
        const sql = `UPDATE matches SET ${setClauses.join(', ')} WHERE source_system_id = ${sourceSystemId} AND external_id = '${this.escapeSql(match.externalId)}';`;
        const changeDesc = change.changes.map(c => `${c.field}: ${c.from} → ${c.to}`).join(', ');
        lines.push(`-- Updated: ${match.homeTeam} vs ${match.awayTeam} (${changeDesc})`);
        lines.push(sql);
        this.sqlStatements.push(sql);
      }
    }

    fs.appendFileSync(filePath, lines.join('\n') + '\n');
    console.log(`   ✏️  Appended to ${path.basename(filePath)}`);
  }

  /**
   * Rewrite standings SQL file (104) — standings are always "current state"
   * @param {LeagueSnapshot} newSnapshot - The new snapshot with current standings
   */
  rewriteStandingsSql(newSnapshot) {
    const season = this.config.activeSeason;
    const leagueId = this.config.leagueDbId;
    const sourceSystemId = this.config.sourceSystemId;
    const slug = this.config.leagueSlug;
    const fileCode = this.config.fileCode;

    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Standings - ${this.config.leagueName}
-- Total Records: ${newSnapshot.standings.length}
-- Last updated: ${new Date().toISOString()}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    for (const standing of newSnapshot.standings) {
      const teamSql = `INSERT INTO standings (team_id, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, source)
SELECT t.id, ${standing.played}, ${standing.wins}, ${standing.draws}, ${standing.losses},
  ${standing.goalsFor}, ${standing.goalsAgainst}, ${standing.goalDiff}, ${standing.points},
  '${this.config.leagueName} Standings Page'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = '${this.escapeSql(standing.teamName)}'
  AND d.name = '${this.escapeSql(standing.divisionName)}'
  AND s.name = '${season}'
  AND s.league_id = ${leagueId}
ON CONFLICT (team_id) DO UPDATE SET
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = now(),
  updated_at = CURRENT_TIMESTAMP;`;

      sql += teamSql + '\n\n';
      this.sqlStatements.push(teamSql);
    }

    const filePath = path.join(this.sqlDir, `104.${fileCode}-standings-${slug}.sql`);
    fs.writeFileSync(filePath, sql);
    console.log(`   ✏️  Rewrote ${path.basename(filePath)} (${newSnapshot.standings.length} teams)`);
  }

  /**
   * Append player changes to 105-players SQL file
   */
  _appendPlayersSql(playersDiff, timestamp) {
    const filePath = this._findSqlFile('105');
    if (!filePath) {
      console.log('   ⚠️  No 105-players SQL file found — skipping player changes');
      return;
    }

    const lines = [];
    lines.push(`\n-- === UPDATE ${timestamp} ===`);

    const sourceSystemId = this.config.sourceSystemId;

    for (const player of playersDiff.added) {
      lines.push(`-- Added: ${player.firstName} ${player.lastName} → ${player.teamName}`);
      // Player SQL is complex (persons + players + team_players) — placeholder
      lines.push(`-- TODO: INSERT person + player for ${player.firstName} ${player.lastName}`);
    }

    for (const player of playersDiff.removed) {
      lines.push(`-- Removed: ${player.firstName} ${player.lastName} from ${player.teamName}`);
      lines.push(`-- TODO: Mark player inactive on ${player.teamName}`);
    }

    if (lines.length > 1) {
      fs.appendFileSync(filePath, lines.join('\n') + '\n');
      console.log(`   ✏️  Appended player changes to ${path.basename(filePath)}`);
    }
  }

  /**
   * Find the SQL file matching a prefix (e.g., '102' → '102.00002-teams-casa.sql')
   */
  _findSqlFile(prefix) {
    const files = fs.readdirSync(this.sqlDir);
    const match = files.find(f => f.startsWith(prefix));
    if (!match) {
      console.log(`   ⚠️  No SQL file with prefix ${prefix} found in ${this.sqlDir}`);
      return null;
    }
    return path.join(this.sqlDir, match);
  }

  /**
   * Run accumulated SQL statements against the live database
   * @param {Object} pool - pg Pool instance
   * @returns {Promise<{success: number, failed: number, errors: string[]}>}
   */
  async runAgainstDb(pool) {
    const results = { success: 0, failed: 0, errors: [] };

    if (this.sqlStatements.length === 0) {
      console.log('   ℹ️  No SQL to run');
      return results;
    }

    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      for (const sql of this.sqlStatements) {
        try {
          await client.query(sql);
          results.success++;
        } catch (err) {
          results.failed++;
          results.errors.push(`${err.message}: ${sql.substring(0, 100)}...`);
        }
      }

      if (results.failed === 0) {
        await client.query('COMMIT');
        console.log(`   ✅ Committed ${results.success} statements to database`);
      } else {
        await client.query('ROLLBACK');
        console.log(`   ❌ Rolled back — ${results.failed} failures:`);
        results.errors.forEach(e => console.log(`      ${e}`));
      }
    } finally {
      client.release();
    }

    return results;
  }
}

module.exports = SqlAppender;
