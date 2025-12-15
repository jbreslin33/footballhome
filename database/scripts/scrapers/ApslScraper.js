const Scraper = require('../base/Scraper');
const HttpFetcher = require('../fetchers/HttpFetcher');
const ApslHtmlParser = require('../parsers/ApslHtmlParser');
const IdGenerator = require('../services/IdGenerator');
const SqlGenerator = require('../services/SqlGenerator');
const DuplicateDetector = require('../services/DuplicateDetector');
const League = require('../models/League');
const Team = require('../models/Team');
const Player = require('../models/Player');
const Match = require('../models/Match');

/**
 * APSL League Scraper
 * Scrapes apslsoccer.com for structure, rosters, and schedules
 */
class ApslScraper extends Scraper {
  constructor(mode = 'full', options = {}) {
    super({
      name: 'APSL',
      mode: mode,
      includeSchedules: options.includeSchedules || false,
      teamFilter: options.teamFilter || null
    });

    this.baseUrl = 'https://apslsoccer.com';
    this.leagueId = '00000000-0000-0000-0001-000000000001';
    this.sportId = '550e8400-e29b-41d4-a716-446655440101';
    
    // Fetcher and parser
    this.fetcher = new HttpFetcher({ timeout: 30000, maxRetries: 3 });
    this.parser = new ApslHtmlParser();
    
    // Services
    this.duplicateDetector = new DuplicateDetector();
    this.sqlGenerator = new SqlGenerator();
    
    // Authentication
    this.authCookies = '';
    
    // Conference data cache (with tables for team extraction)
    this.conferences = new Map();
  }

  async initialize() {
    this.log('Initializing APSL scraper...');
    
    // Create league
    this.data.leagues.set(this.leagueId, new League({
      id: this.leagueId,
      name: 'APSL',
      display_name: 'American Premier Soccer League',
      sport_id: this.sportId
    }));
  }

  async authenticate() {
    // APSL TeamPass authentication if needed for rosters
    if (this.shouldScrapePlayers()) {
      this.log('Authenticating with TeamPass...');
      // TODO: Implement TeamPass login if required
      // For now, rosters are publicly accessible
    }
  }

  async fetchData() {
    // Step 1: Fetch structure (conferences, divisions)
    await this.fetchStructure();
    
    // Step 2: Fetch teams if needed
    if (this.shouldScrapeTeams()) {
      await this.fetchTeams();
    }
    
    // Step 3: Fetch rosters if needed
    if (this.shouldScrapePlayers()) {
      await this.fetchRosters();
    }
    
    // Step 4: Fetch schedules if needed
    if (this.shouldScrapeSchedules()) {
      await this.fetchSchedules();
    }
  }

  async fetchStructure() {
    this.log('\n📊 Fetching APSL structure...');
    
    const html = await this.fetcher.fetch(`${this.baseUrl}/standings/`);
    this.parser.parse(html);
    
    // Parse structure (returns array of conference data with tables)
    const conferenceData = this.parser.parseStandingsStructure();
    
    this.log(`   Found ${conferenceData.length} conferences`);
    
    // Create conference and division entities
    // APSL: Each conference is also treated as a division
    for (const confData of conferenceData) {
      const confName = confData.name;
      const confId = IdGenerator.fromComponents('apsl', 'conference', confName);
      
      // Store conference data for team extraction
      this.conferences.set(confId, {
        id: confId,
        name: confName,
        season: confData.season,
        table: confData.table
      });
    }
    
  }

  async fetchTeams() {
    this.log('\n⚽ Fetching teams...');
    
    // Parse team links from standings page
    const teamLinks = this.parser.parseTeamLinks();
    
    for (const teamData of teamLinks) {
      if (!this.matchesTeamFilter(teamData.name)) {
        this.log(`   ⊘ Skipping ${teamData.name} (filtered out)`);
        continue;
      }
      
      const teamId = IdGenerator.fromComponents('apsl', 'team', teamData.apsl_team_id);
      const team = new Team({
        id: teamId,
        name: teamData.name,
        sport_division_id: 'TBD', // Set after parsing structure
        apsl_team_id: teamData.apsl_team_id
      });
      
      this.data.teams.set(teamId, team);
      this.log(`   ✓ ${teamData.name}`);
    }
  }

  async fetchRosters() {
    this.log('\n👥 Fetching rosters...');
    
    for (const [teamId, team] of this.data.teams.entries()) {
      const teamUrl = `${this.baseUrl}/APSL/Team/${team.apsl_team_id}`;
      
      try {
        const html = await this.fetcher.fetch(teamUrl);
        this.parser.parse(html);
        
        const roster = this.parser.parseRoster();
        this.log(`   ${team.name}: ${roster.length} players`);
        
        for (const playerData of roster) {
          const { first, last } = ApslHtmlParser.splitName(playerData.name);
          
          // Check for duplicates
          if (this.duplicateDetector.isDuplicate('player', { first, last }, ['first', 'last'])) {
            const existing = this.duplicateDetector.getExisting('player', { first, last }, ['first', 'last']);
            // Use existing player ID
            continue;
          }
          
          const playerId = IdGenerator.fromComponents('player', first, last);
          const player = new Player({
            id: playerId,
            first_name: first,
            last_name: last,
            jersey_number: playerData.jersey_number,
            position: playerData.position
          });
          
          this.data.players.set(playerId, player);
          this.duplicateDetector.markSeen('player', { first, last }, ['first', 'last']);
          
          // Create team_player association
          // TODO: Add to teamPlayers map
        }
      } catch (error) {
        this.logError(`Failed to fetch roster for ${team.name}`, error);
      }
    }
  }

  async fetchSchedules() {
    this.log('\n📅 Fetching schedules...');
    
    for (const [teamId, team] of this.data.teams.entries()) {
      try {
        const teamUrl = `${this.baseUrl}/APSL/Team/${team.apsl_team_id}`;
        const html = await this.fetcher.fetch(teamUrl);
        this.parser.parse(html);
        
        const schedule = this.parser.parseSchedule();
        this.log(`   ${team.name}: ${schedule.length} matches`);
        
        for (const matchData of schedule) {
          const eventId = IdGenerator.fromComponents('match', team.name, matchData.date, matchData.opponent);
          
          const match = new Match({
            event_id: eventId,
            name: `${team.name} vs ${matchData.opponent}`,
            event_type_id: '550e8400-e29b-41d4-a716-446655440402', // MATCH_EVENT_TYPE_ID
            start_time: matchData.date,
            end_time: null, // Calculate from start_time + 90 minutes
            home_team_id: matchData.isHome ? teamId : null,
            away_team_id: matchData.isHome ? null : teamId,
            created_by: '77d77471-1250-47e0-81ab-d4626595d63c', // SYSTEM_USER_ID
            source_app_id: '550e8400-e29b-41d4-a716-446655440311',
            external_source: 'apsl'
          });
          
          this.data.matches.set(eventId, match);
        }
      } catch (error) {
        this.logError(`Failed to fetch schedule for ${team.name}`, error);
      }
    }
  }

  async transformData() {
    // Apply team filter if specified
    if (this.hasTeamFilter()) {
      this.applyTeamFilter();
    }
  }

  applyTeamFilter() {
    // Filter teams to only those matching the filter
    for (const [id, team] of this.data.teams.entries()) {
      if (!this.matchesTeamFilter(team.name)) {
        this.data.teams.delete(id);
      }
    }
  }

  async generateOutput() {
    this.log('\n💾 Generating SQL output...');
    
    const results = await this.sqlGenerator.generateMultiple([
      {
        filename: '03-leagues-apsl.sql',
        data: this.data.leagues,
        options: {
          title: 'APSL League',
          useInserts: true
        }
      },
      {
        filename: '22-teams-apsl.sql',
        data: this.data.teams,
        options: {
          title: 'APSL Teams',
          useInserts: true
        }
      },
      {
        filename: '08b-users-apsl.sql',
        data: this.data.players,
        options: {
          title: 'APSL Players (Users)',
          useInserts: true
        }
      },
      {
        filename: '25-schedule-apsl.sql',
        data: this.data.matches,
        options: {
          title: 'APSL Match Schedule',
          useInserts: true
        }
      }
    ]);
    
    for (const result of results) {
      this.logSuccess(`${result.filepath}: ${result.count} records`);
    }
  }

  async cleanup() {
    this.parser.destroy();
  }
}

module.exports = ApslScraper;
