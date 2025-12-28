const Scraper = require('../base/Scraper');
const HttpFetcher = require('../fetchers/HttpFetcher');
const ApslHtmlParser = require('../parsers/ApslHtmlParser');
const IdGenerator = require('../services/IdGenerator');
const SqlGenerator = require('../services/SqlGenerator');
const DuplicateDetector = require('../services/DuplicateDetector');

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

    // Initialize APSL compartmentalized data stores
    this.data.apslLeagues = new Map();
    this.data.apslConferences = new Map();
    this.data.apslDivisions = new Map();
    this.data.apslTeams = new Map();
    this.data.apslPlayers = new Map();
    this.data.apslMatches = new Map();
    this.data.apslPlayerStats = new Map();
    this.data.apslTeamStats = new Map();
  }

  async initialize() {
    this.log('Initializing APSL scraper...');
    this.log('Scraping to compartmentalized apsl_* tables only');
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
    
    // Step 5: Fetch standings (team stats)
    if (this.shouldScrapeTeams()) {
      await this.fetchStandings();
    }
  }

  async fetchStructure() {
    this.log('\n📊 Fetching APSL structure...');
    
    const html = await this.fetcher.fetch(`${this.baseUrl}/standings/`);
    this.parser.parse(html);
    
    // Parse structure (returns array of conference data with tables)
    const conferenceData = this.parser.parseStandingsStructure();
    
    this.log(`   Found ${conferenceData.length} conferences`);
    
    // Create APSL League (single league for all APSL data)
    const season = conferenceData[0]?.season || '2024-2025';
    const apslLeagueId = 1; // Single league ID
    this.data.apslLeagues.set(apslLeagueId, {
      id: apslLeagueId,
      name: 'APSL',
      season: season,
      website_url: this.baseUrl,
      is_active: true
    });
    
    // Create conferences and divisions
    // APSL: Each conference is treated as both conference AND division (flat structure)
    let conferenceCounter = 1;
    let divisionCounter = 1;
    
    for (const confData of conferenceData) {
      const confName = confData.name;
      const apslConferenceId = conferenceCounter++;
      
      // Parse the standings table data
      const tableRows = this.parser.parseStandingsTable(confData.table);
      
      // Create APSL Conference
      this.data.apslConferences.set(apslConferenceId, {
        id: apslConferenceId,
        apsl_league_id: apslLeagueId,
        name: confName,
        abbreviation: null,
        sort_order: apslConferenceId
      });
      
      // Create APSL Division (one division per conference in APSL)
      const apslDivisionId = divisionCounter++;
      this.data.apslDivisions.set(apslDivisionId, {
        id: apslDivisionId,
        apsl_conference_id: apslConferenceId,
        name: confName,
        age_group: null,
        skill_level: null,
        gender: null,
        sort_order: apslDivisionId
      });
      
      // Store conference data for team extraction
      this.conferences.set(apslConferenceId, {
        id: apslConferenceId,
        divisionId: apslDivisionId,
        name: confName,
        season: confData.season,
        table: tableRows
      });
    }
    
  }

  async fetchTeams() {
    this.log('\n⚽ Fetching teams...');
    
    // Parse team links from standings page
    const teamLinks = this.parser.parseTeamLinks();
    
    let teamCounter = 1;
    
    for (const teamData of teamLinks) {
      if (!this.matchesTeamFilter(teamData.name)) {
        this.log(`   ⊘ Skipping ${teamData.name} (filtered out)`);
        continue;
      }
      
      // Generate unique ID for APSL team
      const normalizedName = teamData.name.trim();
      const apslTeamId = teamCounter++;
      
      // Find which APSL division this team belongs to
      let apslDivisionId = null;
      let conferenceForLog = null;
      for (const [confId, conf] of this.conferences) {
        if (conf.table && Array.isArray(conf.table) && conf.table.some(row => row.team === normalizedName)) {
          apslDivisionId = conf.divisionId;
          conferenceForLog = conf;
          break;
        }
      }

      // Create APSL Team
      this.data.apslTeams.set(apslTeamId, {
          id: apslTeamId,
          apsl_division_id: apslDivisionId,
          name: normalizedName,
          city: null,
          logo_url: null,
          apsl_team_id: teamData.apsl_team_id  // Their external ID
      });

      this.log(`   ✓ ${normalizedName}${conferenceForLog ? ` (${conferenceForLog.name})` : ''}`);
    }
  }

  async fetchRosters() {
    this.log('\n👥 Fetching rosters...');
    
    let playerCounter = 1;
    
    for (const [apslTeamId, apslTeam] of this.data.apslTeams.entries()) {
      const teamUrl = `${this.baseUrl}/APSL/Team/${apslTeam.apsl_team_id}`;
      
      try {
        const html = await this.fetcher.fetch(teamUrl);
        this.parser.parse(html);
        
        const roster = this.parser.parseRoster();
        const playerStats = this.parser.parsePlayerStats();
        
        this.log(`   ${apslTeam.name}: ${roster.length} players, ${playerStats.length} with stats`);
        
        // Create a map of player stats for quick lookup
        const statsMap = new Map();
        for (const stat of playerStats) {
          statsMap.set(stat.name, stat);
        }
        
        for (const playerData of roster) {
          const { first, last } = ApslHtmlParser.splitName(playerData.name);
          
          // Create APSL Player (each roster entry is unique to team)
          const apslPlayerId = playerCounter++;
          
          this.data.apslPlayers.set(apslPlayerId, {
              id: apslPlayerId,
              apsl_team_id: apslTeamId,
              name: `${first} ${last}`,
              jersey_number: playerData.jersey_number || null,
              position: playerData.position,
              apsl_player_id: `${apslTeam.apsl_team_id}-${first}-${last}`.toLowerCase().replace(/\s+/g, '-')
          });

          // Create APSL player season stats if available
          const stats = statsMap.get(playerData.name);
          if (stats) {
            // Stats are stored per match, but we're simplifying to season stats
            // We'll need match-level stats later when we scrape individual matches
            const statsId = apslPlayerId; // One stat record per player for now
            const apslPlayerStats = {
              id: statsId,
              apsl_match_id: null, // Will be populated when we scrape match details
              apsl_player_id: apslPlayerId,
              goals: stats.goals || 0,
              assists: stats.assists || 0,
              yellow_cards: stats.yellow_cards || 0,
              red_cards: stats.red_cards || 0
            };
            this.data.apslPlayerStats.set(statsId, apslPlayerStats);
          }
        }
        
        // Log stats summary
        const totalGoals = Array.from(this.data.apslPlayerStats.values())
          .filter(s => {
            const player = this.data.apslPlayers.get(s.apsl_player_id);
            return player && player.apsl_team_id === apslTeamId;
          })
          .reduce((sum, s) => sum + s.goals, 0);
        if (totalGoals > 0) {
          this.log(`   ${apslTeam.name}: ${totalGoals} total goals scored`);
        }
        
      } catch (error) {
        this.logError(`Failed to fetch roster for ${apslTeam.name}`, error);
      }
    }
  }

  async fetchSchedules() {
    this.log('\n📅 Fetching schedules...');
    
    let completedMatches = 0;
    let scheduledMatches = 0;
    let matchCounter = 1;
    
    // Build opponent name -> apsl_team lookup
    const teamsByName = new Map();
    for (const [_, apslTeam] of this.data.apslTeams.entries()) {
      teamsByName.set(apslTeam.name, apslTeam);
    }
    
    for (const [apslTeamId, apslTeam] of this.data.apslTeams.entries()) {
      try {
        const teamUrl = `${this.baseUrl}/APSL/Team/${apslTeam.apsl_team_id}`;
        const html = await this.fetcher.fetch(teamUrl);
        this.parser.parse(html);
        
        const schedule = this.parser.parseSchedule();
        this.log(`   ${apslTeam.name}: ${schedule.length} matches`);
        
        for (const matchData of schedule) {
          // Create unique match ID from date + teams
          const matchKey = `${matchData.date}-${apslTeam.name}-${matchData.opponent}`;
          
          // Skip if we've already added this match (will happen when both teams are in APSL)
          if (this.data.apslMatches.has(matchKey)) {
            continue;
          }
          
          // Find opponent's apsl_team_id
          const opponentTeam = teamsByName.get(matchData.opponent);
          
          // Determine home/away team IDs
          let homeTeamId = null;
          let awayTeamId = null;
          
          if (matchData.isHome) {
            homeTeamId = apslTeamId;
            awayTeamId = opponentTeam ? opponentTeam.id : null;
          } else {
            homeTeamId = opponentTeam ? opponentTeam.id : null;
            awayTeamId = apslTeamId;
          }
          
          // Create apsl_matches record
          const apslMatchId = matchCounter++;
          const apslMatch = {
            id: apslMatchId,
            apsl_division_id: apslTeam.apsl_division_id,
            home_team_id: homeTeamId,
            away_team_id: awayTeamId,
            match_date: matchData.date,
            match_time: null, // APSL doesn't always provide time
            venue_id: null, // Will need to match venue later
            status: matchData.matchStatus || 'scheduled',
            home_score: matchData.homeScore,
            away_score: matchData.awayScore,
            apsl_match_id: matchKey
          };
          
          this.data.apslMatches.set(matchKey, apslMatch);
          
          if (matchData.matchStatus === 'completed') {
            completedMatches++;
          } else {
            scheduledMatches++;
          }
        }
      } catch (error) {
        this.logError(`Failed to fetch schedule for ${apslTeam.name}`, error);
      }
    }
    
    this.log(`   ✓ ${completedMatches} completed matches with scores`);
    this.log(`   ✓ ${scheduledMatches} scheduled matches`);
  }

  async fetchStandings() {
    this.log('\n📊 Fetching team standings/stats...');
    
    // Parse standings from conference tables (already fetched in fetchStructure)
    let statsCount = 0;
    let statCounter = 1;
    
    for (const [confId, conf] of this.conferences) {
      if (!conf.table || !Array.isArray(conf.table)) continue;
      
      const apslDivisionId = conf.divisionId;
      
      for (const row of conf.table) {
        const teamName = row.team;
        
        // Find matching apsl_team by name
        let apslTeamId = null;
        for (const [teamId, team] of this.data.apslTeams) {
          if (team.name === teamName) {
            apslTeamId = teamId;
            break;
          }
        }
        
        if (!apslTeamId) {
          this.log(`   ⚠ Team not found: ${teamName}`);
          continue;
        }
        
        // Create team stats record from standings table
        const statsId = statCounter++;
        const teamStats = {
          id: statsId,
          apsl_division_id: apslDivisionId,
          apsl_team_id: apslTeamId,
          wins: row.w || 0,
          losses: row.l || 0,
          ties: row.t || 0,
          goals_for: row.gf || 0,
          goals_against: row.ga || 0,
          points: row.pts || 0
        };
        
        this.data.apslTeamStats.set(statsId, teamStats);
        statsCount++;
      }
    }
    
    this.log(`   ✓ ${statsCount} team stat records`);
  }

  async transformData() {
    // Apply team filter if specified
    if (this.hasTeamFilter()) {
      this.applyTeamFilter();
    }
  }

  applyTeamFilter() {
    // Filter apsl teams to only those matching the filter
    for (const [id, team] of this.data.apslTeams.entries()) {
      if (!this.matchesTeamFilter(team.name)) {
        this.data.apslTeams.delete(id);
      }
    }
  }

  async generateOutput() {
    this.log('\n💾 Generating SQL output (APSL structure)...');
    
    // Debug: Check data sizes
    this.log(`   DEBUG: apslLeagues: ${this.data.apslLeagues.size}`);
    this.log(`   DEBUG: apslConferences: ${this.data.apslConferences.size}`);
    this.log(`   DEBUG: apslDivisions: ${this.data.apslDivisions.size}`);
    this.log(`   DEBUG: apslTeams: ${this.data.apslTeams.size}`);
    this.log(`   DEBUG: apslPlayers: ${this.data.apslPlayers.size}`);
    this.log(`   DEBUG: apslMatches: ${this.data.apslMatches.size}`);
    this.log(`   DEBUG: apslPlayerStats: ${this.data.apslPlayerStats.size}`);
    this.log(`   DEBUG: apslTeamStats: ${this.data.apslTeamStats.size}`);
    
    const results = await this.sqlGenerator.generateMultiple([
      // APSL Leagues
      {
          filename: '10a-apsl-1-leagues.sql',
          data: this.data.apslLeagues,
          options: {
              title: 'APSL Leagues',
              tableName: 'apsl_leagues',
              useInserts: true,
              conflictColumns: ['id']
          }
      },
      // APSL Conferences
      {
          filename: '10a-apsl-2-conferences.sql',
          data: this.data.apslConferences,
          options: {
              title: 'APSL Conferences',
              tableName: 'apsl_conferences',
              useInserts: true,
              conflictColumns: ['id']
          }
      },
      // APSL Divisions
      {
          filename: '10a-apsl-3-divisions.sql',
          data: this.data.apslDivisions,
          options: {
              title: 'APSL Divisions',
              tableName: 'apsl_divisions',
              useInserts: true,
              conflictColumns: ['id']
          }
      },
      // APSL Teams
      {
          filename: '10a-apsl-4-teams.sql',
          data: this.data.apslTeams,
          options: {
              title: 'APSL Teams',
              tableName: 'apsl_teams',
              useInserts: true,
              conflictColumns: ['apsl_team_id']
          }
      },
      // APSL Players
      {
          filename: '10a-apsl-5-players.sql',
          data: this.data.apslPlayers,
          options: {
              title: 'APSL Players',
              tableName: 'apsl_players',
              useInserts: true,
              conflictColumns: ['apsl_player_id']
          }
      },
      // APSL Matches
      {
          filename: '10a-apsl-6-matches.sql',
          data: this.data.apslMatches,
          options: {
              title: 'APSL Matches',
              tableName: 'apsl_matches',
              useInserts: true,
              conflictColumns: ['apsl_match_id']
          }
      },
      // APSL Player Stats
      {
          filename: '10a-apsl-7-player-stats.sql',
          data: this.data.apslPlayerStats,
          options: {
              title: 'APSL Player Statistics',
              tableName: 'apsl_player_stats',
              useInserts: true,
              conflictColumns: ['id']
          }
      },
      // APSL Team Stats
      {
          filename: '10a-apsl-8-team-stats.sql',
          data: this.data.apslTeamStats,
          options: {
              title: 'APSL Team Statistics',
              tableName: 'apsl_team_stats',
              useInserts: true,
              conflictColumns: ['apsl_division_id', 'apsl_team_id']
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

  slugify(text) {
    return text.toString().toLowerCase()
      .replace(/\s+/g, '-')
      .replace(/[^\w\-]+/g, '')
      .replace(/\-\-+/g, '-')
      .replace(/^-+/, '')
      .replace(/-+$/, '');
  }
}

module.exports = ApslScraper;
