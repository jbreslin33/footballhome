const { Pool } = require('pg');
const path = require('path');
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
const StandingsRepository = require('../domain/repositories/StandingsRepository');
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
 * 
 * Data Source: Hardcoded URL (managed in this file)
 */
class CslStructureScraper {
  constructor(client, config = {}) {
    this.client = client;
    this.fetcher = new HtmlFetcher(path.join(__dirname, '../../scraped-html/csl'));
    this.parser = new CslStandingsParser();
    this.orgRepo = new OrganizationRepository(client);
    this.leagueRepo = new LeagueRepository(client);
    this.seasonRepo = new SeasonRepository(client);
    this.conferenceRepo = new ConferenceRepository(client);
    this.divisionRepo = new DivisionRepository(client);
    this.scrapedTeamRepo = new ScrapedTeamRepository(client);
    this.clubRepo = new ClubRepository(client);
    this.divisionTeamRepo = new DivisionTeamRepository(client);
    this.standingsRepo = new StandingsRepository(client);
    
    // CSL configuration - hardcoded
    this.leagueName = 'Cosmopolitan Soccer League';
    this.leagueSlug = 'cosmopolitan-soccer-league';
    this.standingsUrl = 'https://www.cosmosoccerleague.com/CSL/Tables/';
    this.season = config.season || '2025-2026';
    
    // Track failed fetches for retry
    this.failedFetches = [];
  }
  
  /**
   * Main scraping logic
   */
  async scrape() {
    console.log(`\n⚽ CSL Structure Scraper - Teams Only`);
    console.log('============================================================');
    console.log('⚠️  Assumes divisions/seasons already exist in database');
    
    try {
      // Use hardcoded URL
      const url = this.standingsUrl;
      
      // Step 1: Fetch standings page
      console.log(`\n📥 Fetching standings from: ${url}`);
      const html = await this.fetcher.fetch(url, 'csl-standings');
      
      // Step 2: Parse divisions and teams
      console.log('📊 Parsing divisions and teams...');
      const divisions = this.parser.parse(html);
      console.log(`   Found ${divisions.length} divisions`);
      
      // Step 3: Group divisions by season
      const divisionsBySeason = this.groupDivisionsBySeason(divisions);
      console.log(`   Found ${Object.keys(divisionsBySeason).length} seasons`);
      
      // Step 4: Get CSL league ID
      const leagueResult = await this.client.query(`
        SELECT id FROM leagues WHERE name = $1
      `, [this.leagueName]);
      
      if (leagueResult.rows.length === 0) {
        throw new Error(`CSL league not found in database. Please create it first.`);
      }
      const leagueId = leagueResult.rows[0].id;
      
      // Step 5: Process each season
      for (const [seasonName, seasonDivisions] of Object.entries(divisionsBySeason)) {
        console.log(`\n📅 Processing season: ${seasonName}`);
        
        // Look up existing season
        const season = await this.seasonRepo.findByName(leagueId, seasonName);
        if (!season) {
          console.warn(`   ⚠️  Season ${seasonName} not found in database - skipping`);
          continue;
        }
        
        // Process each division in this season
        for (const divisionData of seasonDivisions) {
          await this.processDivision(season.id, divisionData);
        }
      }
      
      // Step 6: Retry failed fetches
      await this.retryFailedFetches();
      
      console.log('\n✅ CSL structure scraping completed');
      return true;
      
    } catch (error) {
      console.error('❌ Error scraping CSL structure:', error.message);
      throw error;
    }
  }
  
  /**
   * Group divisions by their season (extracted from division name)
   * Division names are like "2025/2026 - Division 1"
   */
  groupDivisionsBySeason(divisions) {
    const grouped = {};
    
    for (const division of divisions) {
      // Extract season from division name (e.g., "2025/2026 - Division 1" → "2025/2026")
      const seasonMatch = division.divisionName.match(/^(\d{4}\/\d{4})/);
      if (!seasonMatch) {
        console.warn(`   ⚠️  Could not extract season from: ${division.divisionName}`);
        continue;
      }
      
      const season = seasonMatch[1];
      if (!grouped[season]) {
        grouped[season] = [];
      }
      
      // Strip season prefix from division name (e.g., "2025/2026 - Division 1" → "Division 1")
      const cleanDivisionName = division.divisionName.replace(/^\d{4}\/\d{4}\s*-\s*/, '').trim();
      grouped[season].push({
        ...division,
        divisionName: cleanDivisionName
      });
    }
    
    return grouped;
  }
  
  /**
   * Ensure organization/league exists (without season/conference)
   */
  async ensureLeague() {
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
    
    return { league };
  }
  
  /**
   * Ensure season and conference exist for a given season name
   */
  async ensureSeasonAndConference(leagueId, seasonName) {
    // Create or get season
    let season = await this.seasonRepo.findByName(leagueId, seasonName);
    if (!season) {
      console.log(`   📅 Creating season: ${seasonName}`);
      const seasonModel = new Season({
        name: seasonName,
        leagueId: leagueId,
        isActive: true
      });
      const seasonResult = await this.seasonRepo.upsert(seasonModel);
      season = { id: seasonResult.id, name: seasonName };
    }
    
    // Create or get conference (CSL has only one conference per season)
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
    
    return { season, conference };
  }
  
  /**
   * Ensure organization/league/season/conference hierarchy exists (DEPRECATED - kept for compatibility)
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
   * Now looks up existing divisions instead of creating them
   */
  async processDivision(seasonId, divisionData) {
    console.log(`\n📂 Processing division: ${divisionData.divisionName}`);
    console.log(`   Teams: ${divisionData.teams.length}`);
    
    // Look up existing division by season and name
    const division = await this.divisionRepo.findBySeasonAndName(seasonId, divisionData.divisionName);
    
    if (!division) {
      console.warn(`   ⚠️  Division "${divisionData.divisionName}" not found in database - skipping`);
      return;
    }
    
    console.log(`   ✅ Found division: ${divisionData.divisionName} (id=${division.id})`);
    
    // Process teams in this division
    let standingsSaved = 0;
    for (let i = 0; i < divisionData.teams.length; i++) {
      const saved = await this.processTeam(division.id, seasonId, divisionData.teams[i], i);
      if (saved) standingsSaved++;
    }
    
    console.log(`   ✓ Standings: ${standingsSaved} records saved`);
  }
  
  /**
   * Process a team and link it to division
   */
  async processTeam(divisionId, seasonId, teamData, teamIndex) {
    // 1. Create scraped_teams entry using upsert (handles duplicates)
    const scrapedTeamModel = new ScrapedTeam({
      name: teamData.name,
      sourceSystemId: 3, // CSL
      externalId: teamData.externalId // Store team ID for roster scraping
    });
    const scrapedTeamResult = await this.scrapedTeamRepo.upsert(scrapedTeamModel);
    console.log(`      ✅ ${scrapedTeamResult.inserted ? 'Created' : 'Found'} scraped team: ${teamData.name}${teamData.externalId ? ` (ID: ${teamData.externalId})` : ''}`);
    
    // 2. Download team page if we have an external_id (use cache to avoid re-downloading)
    if (teamData.externalId) {
      const teamUrl = `https://www.cosmosoccerleague.com/CSL/Team/${teamData.externalId}`;
      try {
        await this.fetcher.fetch(teamUrl, true); // Use cache to avoid overwriting good files
      } catch (error) {
        if (error.message === 'EMPTY_CACHE' || error.message.includes('timeout')) {
          this.failedFetches.push({ url: teamUrl, team: teamData.name });
        } else {
          console.log(`      ⚠️  Failed to fetch team page: ${error.message}`);
        }
      }
    }
    
    // 3. Create division_teams junction (CSL teams are independent, no club link)
    const existing = await this.divisionTeamRepo.findByDivisionAndTeam(divisionId, scrapedTeamResult.id);
    
    if (!existing) {
      await this.divisionTeamRepo.register(divisionId, scrapedTeamResult.id);
    }
    
    // 4. Save standings data (CSL parser extracts standings from tables)
    if (teamData.rank !== undefined && teamData.played !== undefined) {
      await this.standingsRepo.upsert({
        competitionId: divisionId,  // CSL: division = competition (like APSL)
        seasonId: seasonId,
        teamId: scrapedTeamResult.id,
        position: teamData.rank,
        played: teamData.played,
        wins: teamData.wins,
        draws: teamData.draws,
        losses: teamData.losses,
        goalsFor: teamData.goalsFor,
        goalsAgainst: teamData.goalsAgainst,
        goalDiff: teamData.goalDiff,
        points: teamData.points,
        fetchedAt: new Date(),
        source: 'CSL Standings Page'
      });
      return true; // Standings saved
    }
    
    return false; // No standings data
  }
  
  /**
   * Retry failed team page fetches
   */
  async retryFailedFetches() {
    if (this.failedFetches.length === 0) return;
    
    console.log(`\n🔄 Retrying ${this.failedFetches.length} failed team page fetches...`);
    
    for (let attempt = 1; attempt <= 2; attempt++) {
      const stillFailing = [];
      
      for (const { url, team } of this.failedFetches) {
        try {
          await this.fetcher.fetch(url, false, attempt); // Don't use cache, pass attempt number
        } catch (error) {
          if (attempt === 2) {
            console.warn(`   ⚠️  Final attempt failed for ${team}: ${error.message}`);
          } else {
            stillFailing.push({ url, team });
          }
        }
      }
      
      if (stillFailing.length === 0) {
        console.log(`   ✅ All retries succeeded!`);
        break;
      }
      
      this.failedFetches = stillFailing;
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
    // Load scrape_target from database (default to id=5 for current CSL season)
    const scrapeTargetId = process.env.SCRAPE_TARGET_ID || 5;
    const result = await client.query('SELECT * FROM scrape_targets WHERE id = $1', [scrapeTargetId]);
    
    if (result.rows.length === 0) {
      console.log(`⚠️  scrape_target id=${scrapeTargetId} not found, using fallback URL`);
      const scraper = new CslStructureScraper(client, { season: '2025-2026' });
      await scraper.scrape();
    } else {
      const scrapeTarget = result.rows[0];
      console.log(`📋 Loaded scrape_target: id=${scrapeTarget.id}, url=${scrapeTarget.url}`);
      const scraper = new CslStructureScraper(client, { scrapeTarget });
      await scraper.scrape();
    }
    
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
