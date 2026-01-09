const { Pool } = require('pg');
const HtmlFetcher = require('../infrastructure/fetchers/HtmlFetcher');
const CslStandingsParser = require('../infrastructure/parsers/CslStandingsParser');
const OrganizationRepository = require('../domain/repositories/OrganizationRepository');
const LeagueRepository = require('../domain/repositories/LeagueRepository');
const SeasonRepository = require('../domain/repositories/SeasonRepository');
const ConferenceRepository = require('../domain/repositories/ConferenceRepository');
const DivisionRepository = require('../domain/repositories/DivisionRepository');
const ScrapedTeamRepository = require('../domain/repositories/ScrapedTeamRepository');
const ClubRepository = require('../domain/repositories/ClubRepository');
const DivisionTeamRepository = require('../domain/repositories/DivisionTeamRepository');
const Organization = require('../domain/models/Organization');
const League = require('../domain/models/League');
const Season = require('../domain/models/Season');
const Conference = require('../domain/models/Conference');
const Division = require('../domain/models/Division');
const ScrapedTeam = require('../domain/models/ScrapedTeam');

/**
 * Cosmopolitan Soccer League Structure Scraper
 * 
 * Extracts soccer hierarchy from CSL standings page:
 * Organization → League → Season → Conference → Divisions → Teams
 * 
 * CSL is a feeder league to APSL Metropolitan Conference
 */
class CslStructureScraper {
  constructor(client, config = {}) {
    this.client = client;
    this.fetcher = new HtmlFetcher('database/scraped-html/csl');
    this.parser = new CslStandingsParser();
    this.orgRepo = new OrganizationRepository(client);
    this.leagueRepo = new LeagueRepository(client);
    this.seasonRepo = new SeasonRepository(client);
    this.conferenceRepo = new ConferenceRepository(client);
    this.divisionRepo = new DivisionRepository(client);
    this.scrapedTeamRepo = new ScrapedTeamRepository(client);
    this.clubRepo = new ClubRepository(client);
    this.divisionTeamRepo = new DivisionTeamRepository(client);
    
    // CSL configuration
    this.leagueName = 'Cosmopolitan Soccer League';
    this.leagueSlug = 'cosmopolitan-soccer-league';
    this.standingsUrl = 'https://www.cosmosoccerleague.com/CSL/Tables/';
    this.season = config.season || '2025-2026';
  }
  
  /**
   * Main scraping logic
   */
  async scrape() {
    console.log(`\n⚽ CSL Structure Scraper - ${this.season}`);
    console.log('============================================================');
    
    try {
      // Step 1: Fetch standings page
      console.log(`\n📥 Fetching standings from: ${this.standingsUrl}`);
      const html = await this.fetcher.fetch(this.standingsUrl, `csl-standings-${this.season}`);
      
      // Step 2: Parse divisions and teams
      console.log('📊 Parsing divisions and teams...');
      const divisions = this.parser.parse(html);
      console.log(`   Found ${divisions.length} divisions`);
      
      // Step 3: Ensure organization/league/season/conference hierarchy exists
      const { league, season, conference } = await this.ensureHierarchy();
      
      // Step 4: Process each division
      for (const divisionData of divisions) {
        await this.processDivision(conference.id, season.id, divisionData);
      }
      
      console.log('\n✅ CSL structure scraping completed');
      return true;
      
    } catch (error) {
      console.error('❌ Error scraping CSL structure:', error.message);
      throw error;
    }
  }
  
  /**
   * Ensure organization/league/season/conference hierarchy exists
   */
  async ensureHierarchy() {
    // 1. Create or get CSL organization
    let org = await this.orgRepo.findByName(this.leagueName);
    if (!org) {
      console.log(`\n🏢 Creating organization: ${this.leagueName}`);
      const orgModel = new Organization({
        name: this.leagueName,
        isActive: true
      });
      const orgResult = await this.orgRepo.upsert(orgModel);
      org = { id: orgResult.id, name: this.leagueName };
    }
    
    // 2. Create or get league (same as organization for standalone leagues)
    let league = await this.leagueRepo.findByName(org.id, this.leagueName);
    if (!league) {
      console.log(`🏆 Creating league: ${this.leagueName}`);
      const leagueModel = new League({
        name: this.leagueName,
        organizationId: org.id,
        isActive: true
      });
      const leagueResult = await this.leagueRepo.upsert(leagueModel);
      league = { id: leagueResult.id, name: this.leagueName };
    }
    
    // 3. Create or get season
    let season = await this.seasonRepo.findByName(league.id, this.season);
    if (!season) {
      console.log(`   📅 Creating season: ${this.season}`);
      const seasonModel = new Season({
        name: this.season,
        leagueId: league.id,
        isActive: true
      });
      const seasonResult = await this.seasonRepo.upsert(seasonModel);
      season = { id: seasonResult.id, name: this.season };
    }
    
    // 4. Create or get conference (CSL has only one conference)
    const conferenceName = 'Main';
    let conference = await this.conferenceRepo.findByName(season.id, conferenceName);
    if (!conference) {
      console.log(`   📋 Creating conference: ${conferenceName}`);
      const conferenceModel = new Conference({
        name: conferenceName,
        seasonId: season.id,
        isActive: true
      });
      const conferenceResult = await this.conferenceRepo.upsert(conferenceModel);
      conference = { id: conferenceResult.id, name: conferenceName };
    }
    
    return { league, season, conference };
  }
  
  /**
   * Process a division and its teams
   */
  async processDivision(conferenceId, seasonId, divisionData) {
    console.log(`\n📂 Processing division: ${divisionData.divisionName}`);
    console.log(`   Teams: ${divisionData.teams.length}`);
    
    // Create division model and upsert
    const level = this.determineDivisionLevel(divisionData.divisionName);
    const divisionModel = new Division({
      seasonId: seasonId,
      conferenceId: conferenceId,
      name: divisionData.divisionName,
      sourceSystemId: 8, // CSL
      isActive: true
    });
    
    const divisionResult = await this.divisionRepo.upsert(divisionModel);
    console.log(`   ✅ ${divisionResult.inserted ? 'Created' : 'Found'} division: ${divisionData.divisionName} (id=${divisionResult.id})`);
    
    // Process teams in this division
    for (const teamData of divisionData.teams) {
      await this.processTeam(divisionResult.id, seasonId, teamData);
    }
  }
  
  /**
   * Process a team and link it to division
   */
  async processTeam(divisionId, seasonId, teamData) {
    // 1. Create scraped_teams entry using upsert (handles duplicates)
    const scrapedTeamModel = new ScrapedTeam({
      name: teamData.name,
      sourceSystemId: 8, // CSL
      externalId: teamData.externalId // Store team ID for roster scraping
    });
    const scrapedTeamResult = await this.scrapedTeamRepo.upsert(scrapedTeamModel);
    console.log(`      ✅ ${scrapedTeamResult.inserted ? 'Created' : 'Found'} scraped team: ${teamData.name}${teamData.externalId ? ` (ID: ${teamData.externalId})` : ''}`);
    
    // 2. Download team page if we have an external_id (use cache to avoid re-downloading)
    if (teamData.externalId) {
      try {
        const teamUrl = `https://www.cosmosoccerleague.com/CSL/Team/${teamData.externalId}`;
        await this.fetcher.fetch(teamUrl, true); // Use cache to avoid overwriting good files
      } catch (error) {
        console.log(`      ⚠️  Failed to fetch team page: ${error.message}`);
      }
    }
    
    // 3. Create division_teams junction (CSL teams are independent, no club link)
    const existing = await this.divisionTeamRepo.findByDivisionAndTeam(divisionId, scrapedTeamResult.id);
    
    if (!existing) {
      await this.divisionTeamRepo.upsert(divisionId, scrapedTeamResult.id, true);
    }
  }
  
  /**
   * Slugify text for URL-friendly format
   */
  slugify(text) {
    return text
      .toLowerCase()
      .trim()
      .replace(/[^\w\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-');
  }
  
  /**
   * Determine division level from name
   * Division 1 = level 1, Division 1 Reserve = level 1 (but marked as reserve)
   */
  determineDivisionLevel(divisionName) {
    const normalized = divisionName.toLowerCase();
    
    if (normalized.includes('division 1')) return 1;
    if (normalized.includes('division 2')) return 2;
    if (normalized.includes('division 3')) return 3;
    if (normalized.includes('division 4')) return 4;
    if (normalized.includes('over-40')) return 5;
    if (normalized.includes('summer')) return 6;
    
    return 99; // Unknown
  }
}

// Run if called directly
async function main() {
  const { Pool } = require('pg');
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'footballhome',
    user: process.env.DB_USER || 'footballhome_user',
    password: process.env.DB_PASS || 'footballhome_pass',
  });
  
  const client = await pool.connect();
  
  try {
    const scraper = new CslStructureScraper(client, { season: '2025-2026' });
    await scraper.scrape();
    console.log('CslStructureScraper completed successfully');
  } finally {
    client.release();
    await pool.end();
  }
  process.exit(0);
}

if (require.main === module) {
  main().catch(error => {
    console.error(error);
    process.exit(1);
  });
}

module.exports = CslStructureScraper;
