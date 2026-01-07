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
      org = await this.orgRepo.upsert({
        name: this.leagueName,
        slug: this.leagueSlug,
        type: 'league',
        is_active: true
      });
    }
    
    // 2. Create or get league (same as organization for standalone leagues)
    let league = await this.leagueRepo.findBySlug(this.leagueSlug);
    if (!league) {
      console.log(`🏆 Creating league: ${this.leagueName}`);
      league = await this.leagueRepo.upsert({
        organization_id: org.id,
        name: this.leagueName,
        slug: this.leagueSlug,
        is_active: true
      });
    }
    
    // 3. Create or get season
    let season = await this.seasonRepo.findByName(league.id, this.season);
    if (!season) {
      console.log(`   📅 Creating season: ${this.season}`);
      const seasonData = {
        league_id: league.id,
        name: this.season,
        start_date: new Date(`${this.season.split('-')[0]}-09-01`),
        end_date: new Date(`${this.season.split('-')[1]}-06-30`),
        is_active: true
      };
      const seasonResult = await this.seasonRepo.upsert(seasonData);
      season = { id: seasonResult.id, ...seasonData };
    }
    
    // 4. Create or get conference (CSL has only one conference)
    const conferenceName = 'Main';
    let conference = await this.conferenceRepo.findByName(season.id, conferenceName);
    if (!conference) {
      console.log(`   📋 Creating conference: ${conferenceName}`);
      const conferenceData = {
        season_id: season.id,
        name: conferenceName,
        slug: 'main',
        is_active: true
      };
      const conferenceResult = await this.conferenceRepo.upsert(conferenceData);
      conference = { id: conferenceResult.id, ...conferenceData };
    }
    
    return { league, season, conference };
  }
  
  /**
   * Process a division and its teams
   */
  async processDivision(conferenceId, seasonId, divisionData) {
    console.log(`\n📂 Processing division: ${divisionData.divisionName}`);
    console.log(`   Teams: ${divisionData.teams.length}`);
    
    // Create or get division
    let division = await this.divisionRepo.findByConferenceAndName(conferenceId, divisionData.divisionName);
    
    if (!division) {
      const level = this.determineDivisionLevel(divisionData.divisionName);
      division = await this.divisionRepo.create({
        conferenceId,
        name: divisionData.divisionName,
        slug: this.slugify(divisionData.divisionName),
        level,
        isActive: true
      });
      console.log(`   ✅ Created division: ${divisionData.divisionName}`);
    } else {
      console.log(`   ⏭️  Division exists: ${divisionData.divisionName}`);
    }
    
    // Process teams in this division
    for (const teamData of divisionData.teams) {
      await this.processTeam(division.id, seasonId, teamData);
    }
  }
  
  /**
   * Process a team and link it to division
   */
  async processTeam(divisionId, seasonId, teamData) {
    // 1. Create scraped_teams entry
    const scrapedTeamSlug = this.slugify(teamData.name);
    let scrapedTeam = await this.scrapedTeamRepo.findBySlug(scrapedTeamSlug);
    
    if (!scrapedTeam) {
      scrapedTeam = await this.scrapedTeamRepo.create({
        name: teamData.name,
        slug: scrapedTeamSlug,
        source: 'csl',
        isActive: true
      });
      console.log(`      ✅ Created scraped team: ${teamData.name}`);
    }
    
    // 2. Try to link to club (if exists)
    const club = await this.clubRepo.findByDisplayName(teamData.name);
    const clubId = club ? club.id : null;
    
    // 3. Create division_teams junction
    const existing = await this.divisionTeamRepo.findByDivisionAndTeam(divisionId, scrapedTeam.id);
    
    if (!existing) {
      await this.divisionTeamRepo.create({
        divisionId,
        scrapedTeamId: scrapedTeam.id,
        clubId,
        season: seasonId
      });
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
