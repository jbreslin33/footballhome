#!/usr/bin/env node

/**
 * APSL Update Orchestrator
 *
 * Diff-based update flow:
 *   1. Load old snapshot (database/scraped-html/apsl/snapshot.json)
 *   2. Scrape fresh HTML from apslsoccer.com (standings + team pages)
 *   3. Parse HTML into LeagueSnapshot via generator
 *   4. Diff old vs new → changeset
 *   5. Generate SQL from changeset → append to league SQL files
 *   6. Rewrite standings SQL (always current state)
 *   7. Optionally run SQL against live database
 *   8. Save new snapshot as the "old" for next time
 *
 * Usage:
 *   node update-apsl.js                   # Scrape + diff + update SQL files
 *   node update-apsl.js --dry-run         # Scrape + diff only (no SQL changes)
 *   node update-apsl.js --db              # Also run SQL against live database
 *   node update-apsl.js --baseline        # Re-parse cached HTML → save snapshot
 *   node update-apsl.js --skip-scrape     # Use existing cached HTML (no network)
 */

const fs = require('fs');
const path = require('path');
const LeagueSnapshot = require('../../../../update/LeagueSnapshot');
const LeagueDiff = require('../../../../update/LeagueDiff');
const SqlAppender = require('../../../../update/SqlAppender');

const LEAGUE_DIR = __dirname;
const CONFIG = JSON.parse(fs.readFileSync(path.join(LEAGUE_DIR, 'config.json'), 'utf8'));
const CACHE_DIR = path.join(__dirname, '../../../../../scraped-html/apsl');
const SQL_DIR = path.join(LEAGUE_DIR, 'sql');
const SNAPSHOT_PATH = path.join(CACHE_DIR, 'snapshot.json');

// APSL URL patterns
const STANDINGS_URL = CONFIG.standingsUrl || 'https://www.apslsoccer.com/Standings';
const TEAM_PAGE_BASE = 'https://www.apslsoccer.com/APSL/Team';

class ApslUpdater {
  constructor(options = {}) {
    this.dryRun = options.dryRun || false;
    this.runDb = options.runDb || false;
    this.baselineOnly = options.baselineOnly || false;
    this.skipScrape = options.skipScrape || false;
  }

  /**
   * Scrape fresh HTML from apslsoccer.com
   * Downloads standings page + all team detail pages to cache directory
   */
  async scrapeHtml() {
    const HtmlFetcher = require('../../../../infrastructure/fetchers/HtmlFetcher');
    const fetcher = new HtmlFetcher(CACHE_DIR);

    try {
      // Step 1: Fetch fresh standings page
      console.log(`   🌐 Fetching standings: ${STANDINGS_URL}`);
      await fetcher.fetch(STANDINGS_URL, false);

      // Step 2: Parse standings HTML to discover team external IDs
      const ApslSqlGenerator = require('./generate-sql');
      const tempGenerator = new ApslSqlGenerator();
      const standingsHtml = tempGenerator.readStandingsHtml();
      tempGenerator.parseStandingsPage(standingsHtml);

      const teamIds = tempGenerator.teams
        .map(t => t.externalId)
        .filter(id => id);

      // Step 3: Fetch each team detail page
      console.log(`   🌐 Fetching ${teamIds.length} team pages...`);
      let fetched = 0;
      let failed = 0;

      for (const teamId of teamIds) {
        const teamUrl = `${TEAM_PAGE_BASE}/${teamId}`;
        try {
          await fetcher.fetch(teamUrl, false);
          fetched++;
        } catch (error) {
          failed++;
          if (failed <= 3) {
            console.log(`      ⚠️  Failed: ${teamId} — ${error.message}`);
          }
        }
      }

      if (failed > 3) {
        console.log(`      ⚠️  ... and ${failed - 3} more failures`);
      }
      console.log(`   ✓ Fetched ${fetched}/${teamIds.length} team pages`);
    } finally {
      await fetcher.closeBrowser();
    }
  }

  /**
   * Parse cached HTML into a LeagueSnapshot using the APSL generator
   */
  parseSnapshot() {
    const ApslSqlGenerator = require('./generate-sql');
    const generator = new ApslSqlGenerator();

    // Parse all data from cached HTML
    const standingsHtml = generator.readStandingsHtml();
    generator.parseStandingsPage(standingsHtml);
    generator.parseTeamRosters();
    generator.parseMatchSchedules();

    // Build snapshot (no SQL writing needed)
    return generator.toSnapshot();
  }

  /**
   * Create/update baseline snapshot from cached HTML
   */
  createBaseline() {
    console.log('\n📦 Creating baseline snapshot from cached HTML...');
    const snapshot = this.parseSnapshot();

    console.log(`   Teams: ${snapshot.teams.length}`);
    console.log(`   Matches: ${snapshot.matches.length}`);
    console.log(`   Standings: ${snapshot.standings.length}`);
    console.log(`   Players: ${snapshot.players.length}`);

    snapshot.save(SNAPSHOT_PATH);
    console.log(`   💾 Saved: ${SNAPSHOT_PATH}`);
    return snapshot;
  }

  /**
   * Main update flow
   */
  async run() {
    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🔄 APSL Update');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (this.dryRun) console.log('   ⚠️  DRY RUN — no files will be modified');
    if (this.skipScrape) console.log('   ⚠️  SKIP SCRAPE — using existing cached HTML');

    // Step 0: Create baseline if requested
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
      console.log(`   Teams: ${oldSnapshot.teams.length}, Matches: ${oldSnapshot.matches.length}, Standings: ${oldSnapshot.standings.length}`);
    } else {
      console.log('\n📦 No previous snapshot found — creating baseline from cached HTML...');
      oldSnapshot = this.createBaseline();
    }

    // Step 2: Scrape fresh HTML
    if (!this.skipScrape) {
      console.log('\n🌐 Scraping fresh data from apslsoccer.com...');
      await this.scrapeHtml();
    }

    // Step 3: Parse fresh HTML into snapshot
    console.log('\n📊 Parsing cached HTML into snapshot...');
    const newSnapshot = this.parseSnapshot();
    console.log(`   Teams: ${newSnapshot.teams.length}, Matches: ${newSnapshot.matches.length}, Standings: ${newSnapshot.standings.length}, Players: ${newSnapshot.players.length}`);

    // Step 4: Diff
    console.log('\n📊 Computing diff...');
    const differ = new LeagueDiff(oldSnapshot, newSnapshot);
    const diff = differ.compute();

    console.log(LeagueDiff.summarize(diff));

    if (LeagueDiff.isEmpty(diff)) {
      console.log('\n✅ No changes detected — nothing to update');
      if (!this.dryRun) {
        newSnapshot.save(SNAPSHOT_PATH);
      }
      return;
    }

    if (this.dryRun) {
      console.log('\n⚠️  DRY RUN — stopping before SQL changes');
      return;
    }

    // Step 5: Generate SQL from diff
    console.log('\n✏️  Updating SQL files...');
    const appender = new SqlAppender(CONFIG, SQL_DIR);
    const sqlStatements = appender.generateSql(diff);

    // Step 6: Rewrite standings (always current state)
    appender.rewriteStandingsSql(newSnapshot);

    console.log(`   Generated ${sqlStatements.length} SQL statements`);

    // Step 7: Run against DB if requested
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

    // Step 8: Save new snapshot
    newSnapshot.save(SNAPSHOT_PATH);
    console.log(`\n💾 Snapshot updated: ${SNAPSHOT_PATH}`);
    console.log('\n✅ APSL update complete\n');
  }
}

// CLI
if (require.main === module) {
  const args = process.argv.slice(2);
  const options = {
    dryRun: args.includes('--dry-run'),
    runDb: args.includes('--db'),
    baselineOnly: args.includes('--baseline'),
    skipScrape: args.includes('--skip-scrape')
  };

  const updater = new ApslUpdater(options);
  updater.run()
    .then(() => process.exit(0))
    .catch(error => {
      console.error('Fatal error:', error);
      process.exit(1);
    });
}

module.exports = ApslUpdater;
