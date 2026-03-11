const { Pool } = require('pg');
const HtmlFetcher = require('../infrastructure/fetchers/HtmlFetcher');
const ApslStandingsParser = require('../infrastructure/parsers/ApslStandingsParser');
const OrganizationRepository = require('../domain/repositories/OrganizationRepository');
const LeagueRepository = require('../domain/repositories/LeagueRepository');
const SeasonRepository = require('../domain/repositories/SeasonRepository');
const ConferenceRepository = require('../domain/repositories/ConferenceRepository');
const DivisionRepository = require('../domain/repositories/DivisionRepository');
const ScrapedTeamRepository = require('../domain/repositories/ScrapedTeamRepository');
const ClubRepository = require('../domain/repositories/ClubRepository');
const DivisionTeamRepository = require('../domain/repositories/DivisionTeamRepository');
const StandingsRepository = require('../domain/repositories/StandingsRepository');
const Organization = require('../domain/models/Organization');
const Division = require('../domain/models/Division');

/**
 * APSL Structure Scraper
 * 
 * Extracts soccer hierarchy from APSL standings page:
 * Organization → League → Season → Conferences → Divisions
 * 
 * This is a thin orchestrator - all logic is in reusable components.
 * 
 * Data Source: Hardcoded URL (managed in this file)
 */
class ApslStructureScraper {
  constructor(fetcher, parser, orgRepo, leagueRepo, seasonRepo, conferenceRepo, divisionRepo, teamRepo, clubRepo, divisionTeamRepo, standingsRepo) {
    this.standingsUrl = 'https://www.apslsoccer.com/Standings';
    this.fetcher = fetcher;
    this.parser = parser;
    this.orgRepo = orgRepo;
    this.leagueRepo = leagueRepo;
    this.seasonRepo = seasonRepo;
    this.conferenceRepo = conferenceRepo;
    this.divisionRepo = divisionRepo;
    this.teamRepo = teamRepo;
    this.clubRepo = clubRepo;
    this.divisionTeamRepo = divisionTeamRepo;
    this.standingsRepo = standingsRepo;
  }
  
  /**
   * Main entry point
   */
  async run() {
    console.log(`\n⚽ APSL Structure Scraper`);
    console.log('='.repeat(60));
    
    try {
      await this.scrapeAndSave();
      console.log('\n✅ Scrape completed successfully\n');
    } catch (error) {
      console.error('\n❌ Scrape failed:', error.message);
      console.error(error.stack);
      throw error;
    }
  }
  
  async scrapeAndSave() {
    // Fetch HTML from hardcoded URL
    const url = this.standingsUrl;
    const useCache = process.env.SCRAPE_USE_CACHE === 'true';
    
    console.log('🌐 Fetching APSL standings...');
    console.log(`   ${url}`);
    const html = await this.fetcher.fetch(url, useCache);
    console.log(`   ✓ Fetched ${html.length} bytes`);
    
    console.log('🔍 Parsing HTML into domain models...');
    const { organization, league, season, conferences, divisions, teams, divisionTeams } = this.parser.parse(html);
    console.log(`   ✓ Found: ${organization.name}`);
    console.log(`   ✓ League: ${league.name}`);
    console.log(`   ✓ Season: ${season.name}`);
    console.log(`   ✓ Conferences: ${conferences.length}`);
    console.log(`   ✓ Divisions: ${divisions.length} (1 per conference)`);
    console.log(`   ✓ Teams: ${teams.length}`);
    
    console.log('💾 Saving to database...');
    
    // 1. Upsert organization
    const orgResult = await this.orgRepo.upsert(organization);
    console.log(`   ✓ Organization: ${orgResult.inserted ? 'inserted' : 'updated'} (id=${orgResult.id})`);
    
    // 2. Upsert league (link to organization)
    league.organizationId = orgResult.id;
    const leagueResult = await this.leagueRepo.upsert(league);
    console.log(`   ✓ League: ${leagueResult.inserted ? 'inserted' : 'updated'} (id=${leagueResult.id})`);
    
    // 3. Upsert season (link to league)
    season.leagueId = leagueResult.id;
    const seasonResult = await this.seasonRepo.upsert(season);
    console.log(`   ✓ Season: ${seasonResult.inserted ? 'inserted' : 'updated'} (id=${seasonResult.id})`);
    
    // 4. Upsert conferences (link to season)
    for (const conference of conferences) {
      conference.seasonId = seasonResult.id;
    }
    const confResult = await this.conferenceRepo.upsertMany(conferences);
    console.log(`   ✓ Conferences: ${confResult.totalInserted} inserted, ${confResult.totalUpdated} updated`);
    
    // 5. LOOKUP divisions, auto-creating any that are missing
    // APSL pattern: 1 division per conference, division name = conference name
    // Cup competitions (State Cups, Over-30, Amateur) are discovered dynamically
    console.log(`   🔍 Looking up divisions from database...`);
    let savedDivisions = await this.divisionRepo.findBySeason(seasonResult.id);
    console.log(`   ✓ Found ${savedDivisions.length} divisions in database for season ${seasonResult.id}`);
    
    // 5b. Map each team to its division_id, auto-creating missing divisions
    const divisionsByName = new Map(savedDivisions.map(d => [d.name, d.id]));
    const savedConferences = await this.conferenceRepo.findBySeason(seasonResult.id);
    const conferencesByName = new Map(savedConferences.map(c => [c.name, c.id]));
    
    for (const divisionData of divisionTeams) {
      let divisionId = divisionsByName.get(divisionData.conferenceName);
      if (!divisionId) {
        // Auto-create division for this conference (cups, new conferences, etc.)
        const conferenceId = conferencesByName.get(divisionData.conferenceName);
        if (!conferenceId) {
          console.warn(`   ⚠️  No conference found for: ${divisionData.conferenceName} — skipping`);
          continue;
        }
        console.log(`   🆕 Auto-creating division: ${divisionData.conferenceName}`);
        const newDiv = new Division({
          name: divisionData.conferenceName,
          seasonId: seasonResult.id,
          conferenceId: conferenceId,
          sourceSystemId: 1,
          divisionTypeId: 1
        });
        const divResult = await this.divisionRepo.upsert(newDiv);
        divisionId = divResult.id;
        divisionsByName.set(divisionData.conferenceName, divisionId);
      }
      for (const team of divisionData.teams) {
        team.divisionId = divisionId;
      }
    }
    
    // 6. Download team pages (orgs/clubs/teams/standings handled by SQL pipeline)
    // The scraper only fetches HTML — generate-sql.js + load.sh handle all team-level DB writes.
    // This avoids ID conflicts between scraper auto-increment IDs and SQL explicit IDs.
    if (teams && teams.length > 0) {
      const failedFetches = [];
      let downloaded = 0;
      
      for (const team of teams) {
        if (team.externalId) {
          const teamUrl = `https://www.apslsoccer.com/APSL/Team/${team.externalId}`;
          try {
            await this.fetcher.fetch(teamUrl, true); // Use cache to preserve existing good files
            downloaded++;
          } catch (error) {
            if (error.message === 'EMPTY_CACHE' || error.message.includes('timeout')) {
              failedFetches.push({ url: teamUrl, team: team.name });
            } else {
              console.warn(`      ⚠️  Failed to fetch team page for ${team.name}: ${error.message}`);
            }
          }
        }
      }
      
      // Retry failed fetches
      if (failedFetches.length > 0) {
        console.log(`\n   🔄 Retrying ${failedFetches.length} failed team page fetches...`);
        for (let attempt = 1; attempt <= 2; attempt++) {
          const stillFailing = [];
          for (const { url, team } of failedFetches) {
            try {
              await this.fetcher.fetch(url, false, attempt);
              downloaded++;
            } catch (error) {
              if (attempt === 2) {
                console.warn(`      ⚠️  Final attempt failed for ${team}: ${error.message}`);
              } else {
                stillFailing.push({ url, team });
              }
            }
          }
          if (stillFailing.length === 0) break;
          failedFetches.length = 0;
          failedFetches.push(...stillFailing);
        }
      }
      
      console.log(`   ✓ Team pages: ${downloaded} downloaded, ${failedFetches.length} failed`);
    }
    
    // Print conference + division details
    for (let i = 0; i < conferences.length; i++) {
      console.log(`     - ${conferences[i].name} → ${divisions[i].name}`);
    }
  }
  
  /**
   * Factory method to create scraper with all dependencies
   */
  static async create() {
    const pool = new Pool({
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME || 'footballhome',
      user: process.env.DB_USER || 'footballhome_user',
      password: process.env.DB_PASSWORD || 'footballhome_pass',
    });
    
    const client = await pool.connect();
    
    // Create all dependencies — APSL-safe rate limiting
    const fetcher = new HtmlFetcher(null, {
      delayMs: 3000,           // 3s min between requests
      delayJitterMs: 4000,     // + 0-4s random (3-7s total)
      cacheFreshnessDays: 7,   // Skip re-fetch if cache < 7 days old
      maxFetchesPerSession: 10 // Max 10 live fetches per run (safety cap)
    });
    const parser = new ApslStandingsParser();
    const orgRepo = new OrganizationRepository(client);
    const leagueRepo = new LeagueRepository(client);
    const seasonRepo = new SeasonRepository(client);
    const conferenceRepo = new ConferenceRepository(client);
    const divisionRepo = new DivisionRepository(client);
    const teamRepo = new ScrapedTeamRepository(client);
    const clubRepo = new ClubRepository(client);
    const divisionTeamRepo = new DivisionTeamRepository(client);
    const standingsRepo = new StandingsRepository(client);
    
    // Inject dependencies
    const scraper = new ApslStructureScraper(
      fetcher,
      parser,
      orgRepo,
      leagueRepo,
      seasonRepo,
      conferenceRepo,
      divisionRepo,
      teamRepo,
      clubRepo,
      divisionTeamRepo,
      standingsRepo
    );
    
    // Store pool and client for cleanup
    scraper._pool = pool;
    scraper._client = client;
    
    return scraper;
  }
  
  async cleanup() {
    if (this.fetcher) {
      await this.fetcher.closeBrowser();
    }
    if (this._client) {
      this._client.release();
    }
    if (this._pool) {
      await this._pool.end();
    }
  }
}

// CLI execution
if (require.main === module) {
  (async () => {
    const scraper = await ApslStructureScraper.create();
    
    try {
      await scraper.run();
      process.exit(0);
    } catch (error) {
      console.error(error);
      process.exit(1);
    } finally {
      await scraper.cleanup();
    }
  })();
}

module.exports = ApslStructureScraper;
