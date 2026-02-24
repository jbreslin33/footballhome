#!/usr/bin/env node

/**
 * CASA Update Orchestrator
 *
 * Diff-based update flow:
 *   1. Load old snapshot (database/scraped-html/casa/snapshot.json)
 *   2. Scrape fresh data from casasoccerleagues.com → new LeagueSnapshot
 *   3. Diff old vs new → changeset
 *   4. Generate SQL from changeset → append to league SQL files
 *   5. Rewrite standings SQL (always current state)
 *   6. Optionally run SQL against live database
 *   7. Save new snapshot as the "old" for next time
 *
 * Usage:
 *   node update-casa.js                   # Scrape + diff + update SQL files
 *   node update-casa.js --dry-run         # Scrape + diff only (no SQL changes)
 *   node update-casa.js --db              # Also run SQL against live database
 *   node update-casa.js --baseline        # Create baseline snapshot from existing JSON
 */

const fs = require('fs');
const path = require('path');
const LeagueSnapshot = require('../../../../update/LeagueSnapshot');
const LeagueDiff = require('../../../../update/LeagueDiff');
const SqlAppender = require('../../../../update/SqlAppender');

const LEAGUE_DIR = __dirname;
const CONFIG = JSON.parse(fs.readFileSync(path.join(LEAGUE_DIR, 'config.json'), 'utf8'));
const CACHE_DIR = path.join(__dirname, '../../../../../scraped-html/casa');
const SQL_DIR = path.join(LEAGUE_DIR, 'sql');
const SNAPSHOT_PATH = path.join(CACHE_DIR, 'snapshot.json');

class CasaUpdater {
  constructor(options = {}) {
    this.dryRun = options.dryRun || false;
    this.runDb = options.runDb || false;
    this.baselineOnly = options.baselineOnly || false;
  }

  /**
   * Create a baseline LeagueSnapshot from existing JSON files
   * (Used for first run when no snapshot.json exists yet)
   */
  createBaseline() {
    console.log('\n📦 Creating baseline snapshot from existing JSON files...');

    const snapshot = new LeagueSnapshot({
      league: CONFIG.leagueSlug,
      season: CONFIG.activeSeason,
      sourceSystemId: CONFIG.sourceSystemId,
      scrapedAt: new Date().toISOString()
    });

    // Read division-teams.json / standings-data.json
    const standingsPath = path.join(CACHE_DIR, 'standings-data.json');
    if (fs.existsSync(standingsPath)) {
      const standingsData = JSON.parse(fs.readFileSync(standingsPath, 'utf8'));

      for (const division of standingsData.divisions) {
        for (const team of (division.teams || [])) {
          // Skip header rows that leaked into data
          if (team.teamName === 'Teams') continue;

          snapshot.addTeam({
            name: team.teamName,
            divisionName: division.name,
            divisionExternalId: division.external_id,
            externalId: `${division.external_id}-${team.teamName.toLowerCase().replace(/\s+/g, '-')}`
          });

          snapshot.addStanding({
            teamName: team.teamName,
            divisionName: division.name,
            played: team.played || 0,
            wins: team.wins || 0,
            draws: team.draws || 0,
            losses: team.losses || 0,
            goalsFor: team.goalsFor || 0,
            goalsAgainst: team.goalsAgainst || 0,
            goalDiff: team.goalDiff || 0,
            points: team.points || 0
          });
        }
      }
    }

    // Read division-matches.json
    const matchesPath = path.join(CACHE_DIR, 'division-matches.json');
    if (fs.existsSync(matchesPath)) {
      const matchesData = JSON.parse(fs.readFileSync(matchesPath, 'utf8'));

      for (const division of matchesData.divisions) {
        const matchCounters = {};

        for (const match of (division.matches || [])) {
          // Generate stable external ID
          const pairKey = `${match.home}::${match.away}`;
          matchCounters[pairKey] = (matchCounters[pairKey] || 0) + 1;
          const occurrence = matchCounters[pairKey];

          const homeSlug = match.home.toLowerCase().replace(/\s+/g, '-');
          const awaySlug = match.away.toLowerCase().replace(/\s+/g, '-');
          const externalId = `${division.external_id}_${homeSlug}_vs_${awaySlug}_${occurrence}`;

          // Parse score
          let homeScore = null, awayScore = null;
          if (match.score) {
            const scoreMatch = match.score.match(/(\d+)\s*-\s*(\d+)/);
            if (scoreMatch) {
              homeScore = parseInt(scoreMatch[1]);
              awayScore = parseInt(scoreMatch[2]);
            }
          }

          const status = (match.status || '').toLowerCase().includes('final') ? 'completed' : 'scheduled';

          snapshot.addMatch({
            homeTeam: match.home,
            awayTeam: match.away,
            divisionName: division.name,
            divisionExternalId: division.external_id,
            date: null,
            time: match.time || null,
            status,
            homeScore,
            awayScore,
            externalId
          });
        }
      }
    }

    console.log(`   Teams: ${snapshot.teams.length}`);
    console.log(`   Matches: ${snapshot.matches.length}`);
    console.log(`   Standings: ${snapshot.standings.length}`);

    snapshot.save(SNAPSHOT_PATH);
    console.log(`   💾 Saved: ${SNAPSHOT_PATH}`);
    return snapshot;
  }

  /**
   * Main update flow
   */
  async run() {
    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🔄 CASA Update');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (this.dryRun) console.log('   ⚠️  DRY RUN — no files will be modified');

    // Step 0: Create baseline if needed
    if (this.baselineOnly) {
      this.createBaseline();
      return;
    }

    // Step 1: Load old snapshot
    let oldSnapshot;
    if (fs.existsSync(SNAPSHOT_PATH)) {
      console.log('\n📂 Loading old snapshot...');
      oldSnapshot = LeagueSnapshot.load(SNAPSHOT_PATH);
      console.log(`   From: ${oldSnapshot.scrapedAt}`);
      console.log(`   Teams: ${oldSnapshot.teams.length}, Matches: ${oldSnapshot.matches.length}`);
    } else {
      console.log('\n📦 No previous snapshot found — creating baseline from JSON...');
      oldSnapshot = this.createBaseline();
    }

    // Step 2: Scrape fresh data
    console.log('\n🌐 Scraping fresh data from casasoccerleagues.com...');
    const CasaStructureScraper = require('../../../../scrapers/CasaStructureScraper');
    const scraper = new CasaStructureScraper();
    const newSnapshot = await scraper.scrape();

    // Step 3: Diff
    console.log('\n📊 Computing diff...');
    const differ = new LeagueDiff(oldSnapshot, newSnapshot);
    const diff = differ.compute();

    console.log(LeagueDiff.summarize(diff));

    if (LeagueDiff.isEmpty(diff)) {
      console.log('\n✅ No changes detected — nothing to update');
      // Still save the new snapshot (updated timestamp)
      if (!this.dryRun) {
        newSnapshot.save(SNAPSHOT_PATH);
      }
      return;
    }

    if (this.dryRun) {
      console.log('\n⚠️  DRY RUN — stopping before SQL changes');
      return;
    }

    // Step 4: Generate SQL from diff
    console.log('\n✏️  Updating SQL files...');
    const appender = new SqlAppender(CONFIG, SQL_DIR);
    const sqlStatements = appender.generateSql(diff);

    // Step 5: Rewrite standings (always current state)
    appender.rewriteStandingsSql(newSnapshot);

    console.log(`   Generated ${sqlStatements.length} SQL statements`);

    // Step 6: Run against DB if requested
    if (this.runDb) {
      console.log('\n🗄️  Running SQL against database...');
      const { Pool } = require('pg');
      const pool = new Pool({
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT || 5432,
        database: process.env.DB_NAME || 'footballhome',
        user: process.env.DB_USER || 'footballhome_user',
        password: process.env.DB_PASSWORD || 'footballhome_pass'
      });

      try {
        const result = await appender.runAgainstDb(pool);
        if (result.failed > 0) {
          console.log(`   ⚠️  ${result.failed} statements failed — check errors above`);
        }
      } finally {
        await pool.end();
      }
    }

    // Step 7: Save new snapshot as "old" for next run
    newSnapshot.save(SNAPSHOT_PATH);
    console.log(`\n💾 Snapshot updated: ${SNAPSHOT_PATH}`);
    console.log('\n✅ CASA update complete\n');
  }
}

// CLI
if (require.main === module) {
  const args = process.argv.slice(2);
  const options = {
    dryRun: args.includes('--dry-run'),
    runDb: args.includes('--db'),
    baselineOnly: args.includes('--baseline')
  };

  const updater = new CasaUpdater(options);
  updater.run()
    .then(() => process.exit(0))
    .catch(error => {
      console.error('Fatal error:', error);
      process.exit(1);
    });
}

module.exports = CasaUpdater;
