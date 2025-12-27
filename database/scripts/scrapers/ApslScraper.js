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

    // Initialize APSL compartmentalized data stores
    this.data.apslDivisions = new Map();
    this.data.apslTeams = new Map();
    this.data.apslPlayers = new Map();
    this.data.apslTeamPlayers = new Map();
    this.data.playerSeasonStats = new Map(); // Will hold apsl_player_stats records
    this.data.teamSeasonStats = new Map(); // Will hold apsl_team_stats records
    // Note: matches Map will hold apsl_matches records
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
    
    // Create conference and division entities
    // APSL: Each conference is also treated as a division
    for (const confData of conferenceData) {
      const confName = confData.name;
      const confId = IdGenerator.fromComponents('apsl', 'conference', confName);
      
      // Parse the standings table data
      const tableRows = this.parser.parseStandingsTable(confData.table);
      
      // Create APSL Division
      const apslDivisionId = IdGenerator.fromComponents('apsl', 'division', confName);
      this.data.apslDivisions.set(apslDivisionId, {
        id: apslDivisionId,
        apsl_id: confName, // Using name as ID since APSL doesn't expose a clear ID
        name: confName,
        season: confData.season,
        league_division_id: null // To be linked manually or via fuzzy match later
      });
      
      // Store conference data for team extraction
      this.conferences.set(confId, {
        id: confId,
        divisionId: apslDivisionId,  // Store division ID for standings
        name: confName,
        season: confData.season,
        table: tableRows // Now an array of row objects instead of DOM element
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
      
      // Generate unique ID for APSL team
      const normalizedName = teamData.name.trim();
      const apslTeamId = IdGenerator.fromComponents('apsl', 'team_record', teamData.apsl_team_id);
      
      // Find which APSL division this team belongs to
      // Check all conferences' tables for this team
      let apslDivisionId = null;
      let conferenceForLog = null;
      for (const [confId, conf] of this.conferences) {
        if (conf.table && Array.isArray(conf.table) && conf.table.some(row => row.team === normalizedName)) {
          apslDivisionId = conf.divisionId; // Use division ID, not conference ID
          conferenceForLog = conf;
          break;
        }
      }

      // Create APSL Team (compartmentalized - no FK to main DB)
      this.data.apslTeams.set(apslTeamId, {
          id: apslTeamId,
          apsl_id: teamData.apsl_team_id,
          name: normalizedName,
          apsl_division_id: apslDivisionId
      });

      this.log(`   ✓ ${normalizedName}${conferenceForLog ? ` (${conferenceForLog.name})` : ''}`);
    }
  }

  async fetchRosters() {
    this.log('\n👥 Fetching rosters...');
    
    for (const [apslTeamId, apslTeam] of this.data.apslTeams.entries()) {
      const teamUrl = `${this.baseUrl}/APSL/Team/${apslTeam.apsl_id}`;
      
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
          
          // Create APSL Player (use name-based ID since APSL doesn't provide unique player IDs)
          const apslPlayerId = IdGenerator.fromComponents('apsl', 'player', first, last);
          
          if (!this.data.apslPlayers.has(apslPlayerId)) {
              this.data.apslPlayers.set(apslPlayerId, {
                  id: apslPlayerId,
                  apsl_id: `${first}-${last}`.toLowerCase(), // Generate a slug-like ID
                  name: `${first} ${last}`,
                  license_number: null,
                  user_id: null // Users will be linked via UI later
              });
          }

          // Create APSL Team Player (Junction)
          const apslTeamPlayerId = IdGenerator.fromComponents('apsl', 'team_player', apslTeam.apsl_id, first, last);
          
          this.data.apslTeamPlayers.set(apslTeamPlayerId, {
              id: apslTeamPlayerId,
              apsl_team_id: apslTeamId,
              apsl_player_id: apslPlayerId,
              jersey_number: playerData.jersey_number || null,
              position: playerData.position,
              is_active: true
          });

          // Create APSL player season stats if available
          const stats = statsMap.get(playerData.name);
          if (stats) {
            const statsId = IdGenerator.fromComponents('apsl_player_stats', apslPlayerId, apslTeamId, '2025-2026');
            const apslPlayerStats = {
              id: statsId,
              apsl_player_id: apslPlayerId,
              apsl_team_id: apslTeamId,
              apsl_division_id: apslTeam.apsl_division_id, // Division from team
              season: '2025-2026',
              games_played: stats.games_played || 0,
              goals: stats.goals || 0,
              assists: stats.assists || 0,
              yellow_cards: stats.yellow_cards || 0,
              red_cards: stats.red_cards || 0,
              minutes_played: stats.minutes_played || 0
            };
            this.data.playerSeasonStats.set(statsId, apslPlayerStats);
          }
        }
        
        // Log stats summary
        const totalGoals = Array.from(this.data.playerSeasonStats.values())
          .filter(s => s.apsl_team_id === apslTeamId)
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
    
    // Build opponent name -> apsl_team lookup
    const teamsByName = new Map();
    for (const [_, apslTeam] of this.data.apslTeams.entries()) {
      teamsByName.set(apslTeam.name, apslTeam);
    }
    
    for (const [apslTeamId, apslTeam] of this.data.apslTeams.entries()) {
      try {
        const teamUrl = `${this.baseUrl}/APSL/Team/${apslTeam.apsl_id}`;
        const html = await this.fetcher.fetch(teamUrl);
        this.parser.parse(html);
        
        const schedule = this.parser.parseSchedule();
        this.log(`   ${apslTeam.name}: ${schedule.length} matches`);
        
        for (const matchData of schedule) {
          // Create unique match ID from date + teams
          const apslMatchId = IdGenerator.fromComponents('apsl_match', matchData.date, apslTeam.name, matchData.opponent);
          
          // Skip if we've already added this match (will happen when both teams are in APSL)
          if (this.data.matches.has(apslMatchId)) {
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
          const apslMatch = {
            apsl_match_id: apslMatchId,
            home_team_id: homeTeamId,
            away_team_id: awayTeamId,
            home_score: matchData.homeScore,
            away_score: matchData.awayScore,
            match_date: matchData.date,
            match_status: matchData.matchStatus,
            venue_name: matchData.location || null,
            google_maps_url: matchData.googleMapsUrl || null
          };
          
          this.data.matches.set(apslMatchId, apslMatch);
          
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
    
    for (const [confId, conf] of this.conferences) {
      if (!conf.table || !Array.isArray(conf.table)) continue;
      
      const apslDivisionId = conf.divisionId; // Use division ID stored in conference
      
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
        const statsId = IdGenerator.fromComponents('apsl_team_stats', apslTeamId, apslDivisionId, '2025-2026');
        const teamStats = {
          id: statsId,
          apsl_team_id: apslTeamId,
          apsl_division_id: apslDivisionId,
          season: '2025-2026',
          games_played: row.gp || 0,
          wins: row.w || 0,
          losses: row.l || 0,
          ties: row.t || 0,
          goals_for: row.gf || 0,
          goals_against: row.ga || 0,
          goal_differential: row.gd || 0,
          points: row.pts || 0
        };
        
        this.data.teamSeasonStats.set(statsId, teamStats);
        statsCount++;
      }
    }
    
    this.log(`   ✓ ${statsCount} team standings from ${this.conferences.size} conferences`);
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
    this.log('\n💾 Generating SQL output (APSL compartmentalized tables only)...');
    
    // Debug: Check data sizes
    this.log(`   DEBUG: apslDivisions: ${this.data.apslDivisions.size}`);
    this.log(`   DEBUG: apslTeams: ${this.data.apslTeams.size}`);
    this.log(`   DEBUG: apslPlayers: ${this.data.apslPlayers.size}`);
    this.log(`   DEBUG: apslTeamPlayers: ${this.data.apslTeamPlayers.size}`);
    this.log(`   DEBUG: matches: ${this.data.matches.size}`);
    this.log(`   DEBUG: playerSeasonStats: ${this.data.playerSeasonStats.size}`);
    this.log(`   DEBUG: teamSeasonStats: ${this.data.teamSeasonStats.size}`);
    
    const results = await this.sqlGenerator.generateMultiple([
      // APSL Divisions (conferences)
      {
          filename: '04a-apsl-divisions.sql',
          data: this.data.apslDivisions,
          options: {
              title: 'APSL Divisions',
              tableName: 'apsl_divisions',
              useInserts: true,
              conflictColumns: ['apsl_id']
          }
      },
      // APSL Teams
      {
          filename: '21a-apsl-teams.sql',
          data: this.data.apslTeams,
          options: {
              title: 'APSL Teams',
              tableName: 'apsl_teams',
              useInserts: true,
              conflictColumns: ['apsl_id']
          }
      },
      // APSL Players
      {
          filename: '24a-apsl-players.sql',
          data: this.data.apslPlayers,
          options: {
              title: 'APSL Players',
              tableName: 'apsl_players',
              useInserts: true,
              conflictColumns: ['apsl_id']
          }
      },
      // APSL Team Players (Rosters)
      {
          filename: '30a-apsl-rosters.sql',
          data: this.data.apslTeamPlayers,
          options: {
              title: 'APSL Rosters',
              tableName: 'apsl_team_players',
              useInserts: true,
              conflictColumns: ['apsl_team_id', 'apsl_player_id']
          }
      },
      // APSL Matches
      {
          filename: '30b-apsl-matches.sql',
          data: this.data.matches,
          options: {
              title: 'APSL Matches',
              tableName: 'apsl_matches',
              useInserts: true,
              conflictColumns: ['apsl_match_id']
          }
      },
      // APSL Player Stats
      {
          filename: '32a-apsl-player-stats.sql',
          data: this.data.playerSeasonStats,
          options: {
              title: 'APSL Player Season Statistics',
              tableName: 'apsl_player_stats',
              useInserts: true,
              conflictColumns: ['apsl_player_id', 'apsl_team_id', 'apsl_division_id', 'season']
          }
      },
      // APSL Team Stats (standings scraped from APSL)
      {
          filename: '31a-apsl-team-stats.sql',
          data: this.data.teamSeasonStats,
          options: {
              title: 'APSL Team Season Statistics',
              tableName: 'apsl_team_stats',
              useInserts: true,
              conflictColumns: ['apsl_team_id', 'apsl_division_id', 'season']
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
