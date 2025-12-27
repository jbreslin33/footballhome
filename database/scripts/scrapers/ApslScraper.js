const Scraper = require('../base/Scraper');
const HttpFetcher = require('../fetchers/HttpFetcher');
const ApslHtmlParser = require('../parsers/ApslHtmlParser');
const IdGenerator = require('../services/IdGenerator');
const SqlGenerator = require('../services/SqlGenerator');
const DuplicateDetector = require('../services/DuplicateDetector');
const League = require('../models/League');
const Club = require('../models/Club');
const SportDivision = require('../models/SportDivision');
const Team = require('../models/Team');
const Player = require('../models/Player');
const TeamPlayer = require('../models/TeamPlayer');
const Coach = require('../models/Coach');
const TeamCoach = require('../models/TeamCoach');
const Match = require('../models/Match');
const TeamSeasonStats = require('../models/TeamSeasonStats');
const PlayerSeasonStats = require('../models/PlayerSeasonStats');

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

    // Initialize data stores for new schema
    this.data.apslDivisions = new Map();
    this.data.apslTeams = new Map();
    this.data.apslPlayers = new Map();
    this.data.apslTeamPlayers = new Map();
    this.data.teamSeasonStats = new Map();
    this.data.playerSeasonStats = new Map();
    this.data.venues = new Map();
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
      
      // Store conference data for team extraction
      this.conferences.set(confId, {
        id: confId,
        name: confName,
        season: confData.season,
        table: confData.table
      });

      // Create APSL Division
      const apslDivisionId = IdGenerator.fromComponents('apsl', 'division', confName);
      this.data.apslDivisions.set(apslDivisionId, {
        id: apslDivisionId,
        apsl_id: confName, // Using name as ID since APSL doesn't expose a clear ID
        name: confName,
        season: confData.season,
        league_division_id: null // To be linked manually or via fuzzy match later
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
      
      // Generate consistent IDs based on normalized name (not league-specific)
      const normalizedName = teamData.name.trim();
      const clubId = IdGenerator.fromComponents('club', normalizedName);
      const sportDivId = IdGenerator.fromComponents('sportdiv', normalizedName);
      const teamId = IdGenerator.fromComponents('apsl', 'team', teamData.apsl_team_id);
      
      // Create club (reuse if already exists from another league)
      if (!this.data.clubs.has(clubId)) {
        const club = new Club({
          id: clubId,
          name: normalizedName,
          display_name: normalizedName,
          slug: this.slugify(normalizedName)
        });
        this.data.clubs.set(clubId, club);
      }
      
      // Create sport division (reuse if already exists from another league)
      if (!this.data.sportDivisions.has(sportDivId)) {
        const sportDiv = new SportDivision({
          id: sportDivId,
          club_id: clubId,
          sport_id: this.sportId,
          name: `${normalizedName} Soccer`,
          display_name: `${normalizedName} Soccer`,
          slug: this.slugify(normalizedName)
        });
        this.data.sportDivisions.set(sportDivId, sportDiv);
      }
      
      const team = new Team({
        id: teamId,
        name: normalizedName,
        sport_division_id: sportDivId,
        league_division_id: null, // APSL doesn't use league divisions
        apsl_team_id: teamData.apsl_team_id
      });
      
      this.data.teams.set(teamId, team);

      // Create APSL Team
      const apslTeamId = IdGenerator.fromComponents('apsl', 'team_record', teamData.apsl_team_id);
      // Find division ID (simplified logic, assumes we can map back)
      // In reality, we'd need to know which conference this team belongs to from the table data
      let apslDivisionId = null;
      for (const [confId, conf] of this.conferences) {
          // This is a simplification. Ideally we check if team is in conf.table
          // For now, we'll leave it null or implement better lookup if needed
      }

      this.data.apslTeams.set(apslTeamId, {
          id: apslTeamId,
          apsl_id: teamData.apsl_team_id,
          name: normalizedName,
          apsl_division_id: apslDivisionId,
          team_id: teamId // Link to internal team
      });

      this.log(`   ✓ ${normalizedName}`);
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
        const playerStats = this.parser.parsePlayerStats();
        
        this.log(`   ${team.name}: ${roster.length} players, ${playerStats.length} with stats`);
        
        // Create a map of player stats for quick lookup
        const statsMap = new Map();
        for (const stat of playerStats) {
          statsMap.set(stat.name, stat);
        }
        
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
            position: playerData.position
          });
          
          this.data.players.set(playerId, player);
          this.duplicateDetector.markSeen('player', { first, last }, ['first', 'last']);
          
          // Create team-player association
          const teamPlayerKey = `${teamId}_${playerId}`;
          const teamPlayer = new TeamPlayer({
            team_id: teamId,
            player_id: playerId,
            jersey_number: playerData.jersey_number || null,
            is_active: true
          });
          this.data.teamPlayers.set(teamPlayerKey, teamPlayer);

          // Create player season stats if available
          const stats = statsMap.get(playerData.name);
          if (stats) {
            const statsId = IdGenerator.fromComponents('player_stats', playerId, teamId, '2025-2026');
            const playerSeasonStats = new PlayerSeasonStats({
              id: statsId,
              player_id: playerId,
              team_id: teamId,
              league_id: this.leagueId,
              league_division_id: null, // Will need to determine from team if needed
              season: '2025-2026',
              goals: stats.goals,
              assists: stats.assists,
              games_played: 0 // Not provided by APSL
            });
            this.data.playerSeasonStats.set(statsId, playerSeasonStats);
          }

          // Create APSL Player
          // We use a composite ID of name because APSL might not give unique IDs per player easily
          // Or if playerData has an ID, use that. Assuming name is unique enough for now within context
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
          const apslTeamId = IdGenerator.fromComponents('apsl', 'team_record', team.apsl_team_id);
          const apslTeamPlayerId = IdGenerator.fromComponents('apsl', 'team_player', team.apsl_team_id, first, last);
          
          this.data.apslTeamPlayers.set(apslTeamPlayerId, {
              id: apslTeamPlayerId,
              apsl_team_id: apslTeamId,
              apsl_player_id: apslPlayerId,
              jersey_number: playerData.jersey_number || null,
              position: playerData.position,
              is_active: true
          });

        }
        
        // Log stats summary
        const totalGoals = Array.from(this.data.playerSeasonStats.values())
          .filter(s => s.team_id === teamId)
          .reduce((sum, s) => sum + s.goals, 0);
        if (totalGoals > 0) {
          this.log(`   ${team.name}: ${totalGoals} total goals scored`);
        }
        
      } catch (error) {
        this.logError(`Failed to fetch roster for ${team.name}`, error);
      }
    }
  }

  async fetchSchedules() {
    this.log('\n📅 Fetching schedules...');
    
    let completedMatches = 0;
    let scheduledMatches = 0;
    
    for (const [teamId, team] of this.data.teams.entries()) {
      try {
        const teamUrl = `${this.baseUrl}/APSL/Team/${team.apsl_team_id}`;
        const html = await this.fetcher.fetch(teamUrl);
        this.parser.parse(html);
        
        const schedule = this.parser.parseSchedule();
        this.log(`   ${team.name}: ${schedule.length} matches`);
        
        for (const matchData of schedule) {
          const eventId = IdGenerator.fromComponents('match', team.name, matchData.date, matchData.opponent);
          
          // Create or find venue if location provided
          let venueId = null;
          if (matchData.location) {
            venueId = IdGenerator.fromComponents('venue', matchData.location);
            
            // Check if venue already exists
            if (!this.data.venues.has(venueId)) {
              // Extract place_id from Google Maps URL if available
              // Format: https://maps.google.com/?q=place_id:ChIJ...
              let placeId = null;
              if (matchData.googleMapsUrl) {
                const placeIdMatch = matchData.googleMapsUrl.match(/place_id[=:]([^&]+)/);
                if (placeIdMatch) {
                  placeId = placeIdMatch[1];
                }
              }
              
              this.data.venues.set(venueId, {
                id: venueId,
                name: matchData.location,
                venue_type: 'field',
                place_id: placeId,
                data_source: 'apsl',
                is_active: true
              });
            }
          }
          
          const match = new Match({
            event_id: eventId,
            name: `${team.name} vs ${matchData.opponent}`,
            event_type_id: '550e8400-e29b-41d4-a716-446655440402', // MATCH_EVENT_TYPE_ID
            start_time: matchData.date,
            end_time: null, // Calculate from start_time + 90 minutes
            venue_id: venueId,
            home_team_id: matchData.isHome ? teamId : null,
            away_team_id: matchData.isHome ? null : teamId,
            home_team_score: matchData.homeScore,
            away_team_score: matchData.awayScore,
            match_status: matchData.matchStatus,
            created_by: '77d77471-1250-47e0-81ab-d4626595d63c', // SYSTEM_USER_ID
            source_app_id: '550e8400-e29b-41d4-a716-446655440311',
            external_source: 'apsl'
          });
          
          this.data.matches.set(eventId, match);
          
          if (matchData.matchStatus === 'completed') {
            completedMatches++;
          } else {
            scheduledMatches++;
          }
        }
      } catch (error) {
        this.logError(`Failed to fetch schedule for ${team.name}`, error);
      }
    }
    
    this.log(`   ✓ ${completedMatches} completed matches with scores`);
    this.log(`   ✓ ${scheduledMatches} scheduled matches`);
  }

  async fetchStandings() {
    this.log('\n📊 Fetching team standings/stats...');
    
    // Read standings data from local JSON file (scraped separately from SportsEngine)
    // This file should be updated periodically: curl https://[actual-standings-api-url] > standings.json
    const fs = require('fs');
    const path = require('path');
    const standingsPath = path.join(__dirname, '../../../standings.json');
    
    if (!fs.existsSync(standingsPath)) {
      this.logWarn('standings.json not found - skipping stats. Run: curl [standings-api] > standings.json');
      return;
    }
    
    try {
      const standingsJson = fs.readFileSync(standingsPath, 'utf8');
      const standingsData = JSON.parse(standingsJson);
      
      if (!standingsData.result || !Array.isArray(standingsData.result)) {
        this.logWarn('No standings data found in standings.json');
        return;
      }
      
      let statsCount = 0;
      
      // Process each division's standings
      for (const division of standingsData.result) {
        const divisionName = division.standings_node_name;
        const teamRecords = division.teamRecords || [];
        
        for (const record of teamRecords) {
          const teamName = record.team_name;
          const values = record.values || {};
          
          // Find matching team in our data by name
          let matchingTeamId = null;
          for (const [teamId, team] of this.data.teams.entries()) {
            if (team.name === teamName) {
              matchingTeamId = teamId;
              break;
            }
          }
          
          if (!matchingTeamId) {
            continue; // Team not in our filtered list
          }
          
          // Create team season stats record
          const statsId = IdGenerator.fromComponents('stats', teamName, '2024-2025');
          const stats = new TeamSeasonStats({
            id: statsId,
            team_id: matchingTeamId,
            league_id: this.leagueId,
            league_division_id: null, // Could map from divisionName if needed
            season: '2024-2025',
            games_played: values.games || 0,
            wins: values.w || 0,
            losses: values.l || 0,
            ties: values.t || 0,
            goals_for: values.pf || 0,
            goals_against: values.pa || 0,
            goal_differential: values.pd || 0,
            points: values.st_pts || 0,
            win_percentage: values.pct || null
          });
          
          this.data.teamSeasonStats.set(statsId, stats);
          statsCount++;
        }
      }
      
      this.log(`   Imported stats for ${statsCount} teams`);
      
    } catch (error) {
      this.logError('Failed to parse standings.json', error);
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
    
    // Debug: Check if player stats exist
    this.log(`   DEBUG: playerSeasonStats size: ${this.data.playerSeasonStats.size}`);
    
    // Note: League is hardcoded in 03-leagues.sql, not generated by scraper
    const results = await this.sqlGenerator.generateMultiple([
      {
        filename: '06a-clubs-apsl.sql',
        data: this.data.clubs,
        options: {
          title: 'APSL Clubs',
          useInserts: true
        }
      },
      {
        filename: '07a-sport-divisions-apsl.sql',
        data: this.data.sportDivisions,
        options: {
          title: 'APSL Sport Divisions',
          useInserts: true
        }
      },
      {
        filename: '08a-users-apsl.sql',
        data: this.data.players,
        options: {
          title: 'APSL Users',
          tableName: 'users', // Keep populating base users
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
        filename: '24-players-apsl.sql',
        data: this.data.players, // This might be redundant if 08a handles it, but keeping for now
        options: {
            title: 'APSL Players (Base)',
            tableName: 'players',
            useInserts: true
        }
      },
      {
        filename: '30-rosters-apsl.sql',
        data: this.data.teamPlayers,
        options: {
          title: 'APSL Rosters (Internal)',
          tableName: 'team_players',
          useInserts: true
        }
      },
      // New APSL Specific Tables
      {
          filename: '04-conferences-apsl.sql', // Using as divisions
          data: this.data.apslDivisions,
          options: {
              title: 'APSL Divisions',
              tableName: 'apsl_divisions',
              useInserts: true,
              conflictColumns: ['apsl_id']
          }
      },
      {
          filename: '22b-teams-apsl-linked.sql',
          data: this.data.apslTeams,
          options: {
              title: 'APSL Teams (Linked)',
              tableName: 'apsl_teams',
              useInserts: true,
              conflictColumns: ['apsl_id']
          }
      },
      {
          filename: '24b-players-apsl-linked.sql',
          data: this.data.apslPlayers,
          options: {
              title: 'APSL Players (Linked)',
              tableName: 'apsl_players',
              useInserts: true,
              conflictColumns: ['apsl_id']
          }
      },
      {
          filename: '30b-rosters-apsl-linked.sql',
          data: this.data.apslTeamPlayers,
          options: {
              title: 'APSL Rosters (Linked)',
              tableName: 'apsl_team_players',
              useInserts: true,
              conflictColumns: ['apsl_team_id', 'apsl_player_id']
          }
      },
      {
          filename: '31a-team-season-stats-apsl.sql',
          data: this.data.teamSeasonStats,
          options: {
              title: 'APSL Team Season Statistics',
              tableName: 'team_season_stats',
              useInserts: true,
              conflictColumns: ['team_id', 'league_id', 'league_division_id', 'season']
          }
      },
      {
          filename: '32a-player-season-stats-apsl.sql',
          data: this.data.playerSeasonStats,
          options: {
              title: 'APSL Player Season Statistics',
              tableName: 'player_season_stats',
              useInserts: true,
              conflictColumns: ['player_id', 'team_id', 'league_id', 'league_division_id', 'season']
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
