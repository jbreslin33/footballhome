const Scraper = require('../base/Scraper');
const HttpFetcher = require('../fetchers/HttpFetcher');
const PuppeteerFetcher = require('../fetchers/PuppeteerFetcher');
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
    
    // Use PuppeteerFetcher for dynamic pages (schedule, match events)
    this.fetcher = new PuppeteerFetcher({ timeout: 30000 });
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
    this.data.apslPlayers = new Map();           // Normalized players table
    this.data.apslTeamPlayers = new Map();       // Junction: team_players
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
      organization_id: 1,  // APSL organization
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
        league_id: apslLeagueId,
        name: confName,
        abbreviation: null,
        sort_order: apslConferenceId
      });
      
      // Create APSL Division (one division per conference in APSL)
      const apslDivisionId = divisionCounter++;
      this.data.apslDivisions.set(apslDivisionId, {
        id: apslDivisionId,
        league_id: apslLeagueId,
        conference_id: apslConferenceId,
        name: confName,
        skill_level: null,
        skill_label: null,
        source_system_id: 1,  // APSL
        external_id: `apsl-conf-${apslConferenceId}`,
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
          sport_division_id: null,  // Teams link to divisions via team_divisions junction
          name: normalizedName,
          city: null,
          logo_url: null,
          source_system_id: 1,  // APSL
          external_id: teamData.apsl_team_id  // Their external ID
      });
      
      // Store team-division mapping separately for junction table
      this.teamDivisions = this.teamDivisions || new Map();
      this.teamDivisions.set(apslTeamId, apslDivisionId);

      this.log(`   ✓ ${normalizedName}${conferenceForLog ? ` (${conferenceForLog.name})` : ''}`);
    }
  }

  async fetchRosters() {
    this.log('\n👥 Fetching rosters...');
    
    let playerCounter = 1;
    
    for (const [apslTeamId, apslTeam] of this.data.apslTeams.entries()) {
      const teamUrl = `${this.baseUrl}/APSL/Team/${apslTeam.external_id}`;
      
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
          
          // Create Player entity (normalized table)
          const playerId = playerCounter++;
          const externalId = `${apslTeam.external_id}-${first}-${last}`.toLowerCase().replace(/\s+/g, '-');
          
          this.data.apslPlayers.set(playerId, {
              id: playerId,
              full_name: `${first} ${last}`,
              first_name: first,
              last_name: last,
              source_system_id: 1,  // APSL
              external_id: externalId
          });
          
          // Create Team-Player junction (roster membership)
          const teamPlayerId = playerCounter;  // Reuse same counter for junction ID
          this.data.apslTeamPlayers.set(teamPlayerId, {
              id: teamPlayerId,
              team_id: apslTeamId,
              player_id: playerId,
              jersey_number: playerData.jersey_number || null,
              position: playerData.position
          });

          // Create player season stats if available
          const stats = statsMap.get(playerData.name);
          if (stats) {
            // Stats are stored per match, but we're simplifying to season stats
            // We'll need match-level stats later when we scrape individual matches
            const statsId = playerId; // One stat record per player for now
            const apslPlayerStats = {
              id: statsId,
              match_id: null, // Will be populated when we scrape match details
              player_id: playerId,  // References normalized player_id
              team_id: apslTeamId,
              goals: stats.goals || 0,
              assists: stats.assists || 0,
              yellow_cards: stats.yellow_cards || 0,
              red_cards: stats.red_cards || 0,
              games_played: stats.games_played || 0
            };
            this.data.apslPlayerStats.set(statsId, apslPlayerStats);
          }
        }
        
        // Log stats summary
        const totalGoals = Array.from(this.data.apslPlayerStats.values())
          .filter(s => {
            // Find team_player junction to check if player is on this team
            const teamPlayer = Array.from(this.data.apslTeamPlayers.values())
              .find(tp => tp.player_id === s.player_id && tp.team_id === apslTeamId);
            return teamPlayer !== undefined;
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
    let playerStatCounter = 1;

    // Build opponent name -> apsl_team lookup
    const teamsByName = new Map();
    for (const [_, apslTeam] of this.data.apslTeams.entries()) {
      teamsByName.set(apslTeam.name, apslTeam);
    }

    for (const [apslTeamId, apslTeam] of this.data.apslTeams.entries()) {
      try {
        const teamUrl = `${this.baseUrl}/APSL/Team/${apslTeam.external_id}`;
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
            division_id: this.teamDivisions.get(apslTeamId),
            home_team_id: homeTeamId,
            away_team_id: awayTeamId,
            match_type_id: 1,  // League match
            match_status_id: matchData.homeScore !== null ? 3 : 1,  // 3=completed, 1=scheduled  
            match_date: matchData.date,
            match_time: null, // APSL doesn't always provide time
            venue_id: null, // Will need to match venue later
            home_score: matchData.homeScore,
            away_score: matchData.awayScore,
            source_system_id: 1,  // APSL
            external_id: matchKey
          };

          this.data.apslMatches.set(matchKey, apslMatch);

          // --- NEW: Fetch per-match player stats ---
          if (matchData.matchStatus === 'completed' && matchData.matchUrl) {
            try {
              // Ensure matchUrl is absolute
              const fullMatchUrl = matchData.matchUrl.startsWith('http') 
                ? matchData.matchUrl 
                : `${this.baseUrl}${matchData.matchUrl}`;
              
              const matchHtml = await this.fetcher.fetch(fullMatchUrl);
              const matchParser = new (require('../parsers/ApslHtmlParser'))();
              matchParser.parse(matchHtml);
              const playerStats = matchParser.parseMatchPlayerStats();
              
              let matchedCount = 0;
              
              for (const stat of playerStats) {
                // Robust player name matching (case-insensitive, ignore extra spaces)
                const statNameNorm = stat.name.trim().toLowerCase().replace(/\s+/g, ' ');
                const player = Array.from(this.data.apslPlayers.values()).find(p => {
                  const fullName = (p.first_name + ' ' + p.last_name).trim().toLowerCase().replace(/\s+/g, ' ');
                  const altFullName = p.full_name.trim().toLowerCase().replace(/\s+/g, ' ');
                  return statNameNorm === fullName || statNameNorm === altFullName;
                });
                if (!player) continue;
                matchedCount++;
                const apslPlayerStat = {
                  id: playerStatCounter++,
                  match_id: apslMatchId,
                  player_id: player.id,
                  team_id: apslTeamId,
                  goals: stat.goals || 0,
                  assists: stat.assists || 0,
                  yellow_cards: stat.yellow_cards || 0,
                  red_cards: stat.red_cards || 0,
                  games_played: 1,
                  is_starter: stat.is_starter,
                  sub_in_minute: stat.sub_in_minute,
                  sub_out_minute: stat.sub_out_minute,
                  minutes_played: stat.minutes_played
                };
                this.data.apslPlayerStats.set(apslPlayerStat.id, apslPlayerStat);
              }
            } catch (err) {
              this.logError(`Failed to fetch player stats for match ${matchKey}`, err);
            }
          }

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
          division_id: apslDivisionId,
          team_id: apslTeamId,
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
    this.log(`   DEBUG: apslTeamPlayers: ${this.data.apslTeamPlayers.size}`);
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
              tableName: 'leagues',
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
              tableName: 'conferences',
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
              tableName: 'divisions',
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
              tableName: 'teams',
              useInserts: true,
              conflictColumns: ['id']
          }
      },
      // Players (normalized) - MUST come before team_players
      {
          filename: '10a-apsl-5-players.sql',
          data: this.data.apslPlayers,
          options: {
              title: 'APSL Players',
              tableName: 'players',
              useInserts: true,
              conflictColumns: ['source_system_id', 'external_id']
          }
      },
      // Team Players (roster junction) - MUST come after players
      {
          filename: '10a-apsl-5z-team-players.sql',
          data: this.data.apslTeamPlayers,
          options: {
              title: 'APSL Team Rosters',
              tableName: 'team_players',
              useInserts: true,
              conflictColumns: ['team_id', 'player_id']
          }
      },
      // APSL Matches
      {
          filename: '10a-apsl-6-matches.sql',
          data: this.data.apslMatches,
          options: {
              title: 'APSL Matches',
              tableName: 'matches',
              useInserts: true,
              conflictColumns: ['id']
          }
      },
      // APSL Player Stats
      {
          filename: '10a-apsl-7-player-stats.sql',
          data: this.data.apslPlayerStats,
          options: {
              title: 'APSL Player Statistics',
              tableName: 'player_stats',
              useInserts: true,
              conflictColumns: ['player_id', 'match_id']
          }
      },
      // APSL Team Stats
      {
          filename: '10a-apsl-8-team-stats.sql',
          data: this.data.apslTeamStats,
          options: {
              title: 'APSL Team Statistics',
              tableName: 'team_stats',
              useInserts: true,
              conflictColumns: ['team_id', 'match_id']
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
