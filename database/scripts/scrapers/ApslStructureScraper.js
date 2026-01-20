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
const Club = require('../domain/models/Club');

/**
 * APSL Structure Scraper
 * 
 * Extracts soccer hierarchy from APSL standings page:
 * Organization → League → Season → Conferences → Divisions
 * 
 * This is a thin orchestrator - all logic is in reusable components.
 * 
 * Data Source: scrape_targets table (id=1 for current season, 2-4 for historical)
 */
class ApslStructureScraper {
  constructor(scrapeTarget, fetcher, parser, orgRepo, leagueRepo, seasonRepo, conferenceRepo, divisionRepo, teamRepo, clubRepo, divisionTeamRepo, standingsRepo) {
    this.scrapeTarget = scrapeTarget;
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
    // Fetch HTML from URL (respecting cache control from orchestrator)
    const url = this.scrapeTarget.url;
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
    
    // 1a. Link organization to scrape_target (audit trail)
    await this._client.query(
      `INSERT INTO organization_scrape_targets (scrape_target_id, organization_id) 
       VALUES ($1, $2) 
       ON CONFLICT (scrape_target_id, organization_id) DO NOTHING`,
      [this.scrapeTarget.id, orgResult.id]
    );
    
    // 2. Upsert league (link to organization)
    league.organizationId = orgResult.id;
    const leagueResult = await this.leagueRepo.upsert(league);
    console.log(`   ✓ League: ${leagueResult.inserted ? 'inserted' : 'updated'} (id=${leagueResult.id})`);
    
    // 2a. Link league to scrape_target (audit trail)
    await this._client.query(
      `INSERT INTO league_scrape_targets (scrape_target_id, league_id) 
       VALUES ($1, $2) 
       ON CONFLICT (scrape_target_id, league_id) DO NOTHING`,
      [this.scrapeTarget.id, leagueResult.id]
    );
    
    // 3. Upsert season (link to league)
    season.leagueId = leagueResult.id;
    const seasonResult = await this.seasonRepo.upsert(season);
    console.log(`   ✓ Season: ${seasonResult.inserted ? 'inserted' : 'updated'} (id=${seasonResult.id})`);
    
    // 3a. Link season to scrape_target (audit trail)
    await this._client.query(
      `INSERT INTO season_scrape_targets (scrape_target_id, season_id) 
       VALUES ($1, $2) 
       ON CONFLICT (scrape_target_id, season_id) DO NOTHING`,
      [this.scrapeTarget.id, seasonResult.id]
    );
    
    // 4. Upsert conferences (link to season)
    for (const conference of conferences) {
      conference.seasonId = seasonResult.id;
    }
    const confResult = await this.conferenceRepo.upsertMany(conferences);
    console.log(`   ✓ Conferences: ${confResult.totalInserted} inserted, ${confResult.totalUpdated} updated`);
    
    // 4a. Link conferences to scrape_target (audit trail)
    const savedConferences = await this.conferenceRepo.findBySeason(seasonResult.id);
    for (const conf of savedConferences) {
      await this._client.query(
        `INSERT INTO conference_scrape_targets (scrape_target_id, conference_id) 
         VALUES ($1, $2) 
         ON CONFLICT (scrape_target_id, conference_id) DO NOTHING`,
        [this.scrapeTarget.id, conf.id]
      );
    }
    
    // 5. Upsert divisions (link to conferences and season)
    // Map divisions to their saved conference IDs (reuse savedConferences from above)
    const conferenceMap = new Map(savedConferences.map(c => [c.external_id, c.id]));
    
    for (const division of divisions) {
      division.seasonId = seasonResult.id;
      division.conferenceId = conferenceMap.get(division.externalId);
    }
    const divResult = await this.divisionRepo.upsertMany(divisions);
    console.log(`   ✓ Divisions: ${divResult.inserted} inserted, ${divResult.updated} updated`);
    
    // 5a. Link divisions to scrape_target (audit trail)
    const savedDivisions = await this.divisionRepo.findBySeason(seasonResult.id);
    for (const div of savedDivisions) {
      await this._client.query(
        `INSERT INTO division_scrape_targets (scrape_target_id, division_id) 
         VALUES ($1, $2) 
         ON CONFLICT (scrape_target_id, division_id) DO NOTHING`,
        [this.scrapeTarget.id, div.id]
      );
    }
    
    // 6. Upsert teams (create club/organization for each team)
    if (teams && teams.length > 0) {
      let clubsCreated = 0;
      let teamsLinked = 0;
      const failedFetches = [];
      
      for (const team of teams) {
        // For APSL, each team IS a club (e.g., "Lighthouse 1893 SC")
        // Create organization + club with same name as team
        const teamOrg = new Organization({
          name: team.name,
          isActive: true
        });
        
        const orgResult = await this.orgRepo.upsert(teamOrg);
        if (orgResult.inserted) clubsCreated++;
        
        // Link team organization to scrape_target
        await this._client.query(
          `INSERT INTO organization_scrape_targets (scrape_target_id, organization_id) 
           VALUES ($1, $2) 
           ON CONFLICT (scrape_target_id, organization_id) DO NOTHING`,
          [this.scrapeTarget.id, orgResult.id]
        );
        
        // Create club under that organization
        const club = new Club({
          name: team.name,
          organizationId: orgResult.id,
          sportId: 1, // Soccer
          isActive: true
        });
        
        const clubResult = await this.clubRepo.upsert(club);
        
        // Link club to scrape_target
        await this._client.query(
          `INSERT INTO club_scrape_targets (scrape_target_id, club_id) 
           VALUES ($1, $2) 
           ON CONFLICT (scrape_target_id, club_id) DO NOTHING`,
          [this.scrapeTarget.id, clubResult.id]
        );
        
        // Link team to club
        team.clubId = clubResult.id;
        teamsLinked++;
        
        // Download team page if we have an external_id (use cache to avoid re-downloading)
        if (team.externalId) {
          const teamUrl = `https://www.apslsoccer.com/APSL/Team/${team.externalId}`;
          try {
            await this.fetcher.fetch(teamUrl, true); // Use cache to preserve existing good files
          } catch (error) {
            if (error.message === 'EMPTY_CACHE' || error.message.includes('timeout')) {
              failedFetches.push({ url: teamUrl, team: team.name });
            } else {
              console.warn(`      ⚠️  Failed to fetch team page for ${team.name}: ${error.message}`);
            }
          }
        }
      }
      
      // Retry failed fetches at the end
      if (failedFetches.length > 0) {
        console.log(`\n   🔄 Retrying ${failedFetches.length} failed team page fetches...`);
        for (let attempt = 1; attempt <= 2; attempt++) {
          const stillFailing = [];
          for (const { url, team } of failedFetches) {
            try {
              await this.fetcher.fetch(url, false, attempt); // Don't use cache, pass attempt number
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
      
      const teamResult = await this.teamRepo.upsertMany(teams);
      console.log(`   ✓ Teams: ${teamResult.inserted} inserted, ${teamResult.updated} updated`);
      console.log(`   ✓ Clubs/Organizations: ${clubsCreated} created, ${teamsLinked} teams linked to clubs`);
      
      // 6a. Link teams to scrape_target (audit trail)
      const savedTeams = await this.teamRepo.findBySourceSystem(1); // APSL source_system_id = 1
      for (const team of savedTeams) {
        await this._client.query(
          `INSERT INTO team_scrape_targets (scrape_target_id, team_id) 
           VALUES ($1, $2) 
           ON CONFLICT (scrape_target_id, team_id) DO NOTHING`,
          [this.scrapeTarget.id, team.id]
        );
      }
      
      // 7. Populate division_teams (link teams to divisions) and save standings
      if (divisionTeams && divisionTeams.length > 0) {
        console.log('🔗 Linking teams to divisions and saving standings...');
        
        // Build maps for quick lookup
        const divisionsByName = new Map(savedDivisions.map(d => [d.name, d.id]));
        const teamsByName = new Map(savedTeams.map(t => [t.name, t.id]));
        
        let linksCreated = 0;
        let standingsSaved = 0;
        
        for (const divisionData of divisionTeams) {
          const divisionName = divisionData.conferenceName.replace(/\s+Conference$/i, '').trim();
          const divisionId = divisionsByName.get(divisionName);
          
          if (!divisionId) {
            console.warn(`   ⚠️  Division not found: ${divisionName}`);
            continue;
          }
          
          // Process each team in this division
          for (let i = 0; i < divisionData.teams.length; i++) {
            const team = divisionData.teams[i];
            const teamId = teamsByName.get(team.name);
            
            if (!teamId) {
              console.warn(`   ⚠️  Team not found: ${team.name}`);
              continue;
            }
            
            // Link team to division
            await this.divisionTeamRepo.upsert(divisionId, teamId);
            linksCreated++;
            
            // Save standings data if available
            if (divisionData.standings && divisionData.standings[i]) {
              const stats = divisionData.standings[i];
              
              // For APSL, competition_id = division_id (each division is its own competition)
              await this.standingsRepo.upsert({
                competitionId: divisionId,  // APSL: division = competition
                seasonId: seasonResult.id,
                teamId: teamId,
                position: stats.position,
                played: stats.played,
                wins: stats.wins,
                draws: stats.draws,
                losses: stats.losses,
                goalsFor: stats.goalsFor,
                goalsAgainst: stats.goalsAgainst,
                goalDiff: stats.goalDiff,
                points: stats.points,
                fetchedAt: new Date(),
                source: 'APSL Standings Page'
              });
              
              standingsSaved++;
            }
          }
        }
        
        console.log(`   ✓ Division-Team Links: ${linksCreated} created`);
        console.log(`   ✓ Standings: ${standingsSaved} records saved`);
      }
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
    
    // Load scrape_target from database (id=1 for current APSL season)
    const scrapeTargetId = process.env.SCRAPE_TARGET_ID || 1;
    const result = await client.query('SELECT * FROM scrape_targets WHERE id = $1', [scrapeTargetId]);
    
    if (result.rows.length === 0) {
      throw new Error(`scrape_target id=${scrapeTargetId} not found`);
    }
    
    const scrapeTarget = result.rows[0];
    console.log(`📋 Loaded scrape_target: id=${scrapeTarget.id}, url=${scrapeTarget.url}`);
    
    // Create all dependencies
    const fetcher = new HtmlFetcher();
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
      scrapeTarget,
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
