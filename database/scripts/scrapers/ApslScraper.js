const Scraper = require('../base/Scraper');
const PuppeteerFetcher = require('../fetchers/PuppeteerFetcher');
const CacheManager = require('../services/CacheManager');
const ApslHtmlParser = require('../parsers/ApslHtmlParser');
const SqlGenerator = require('../services/SqlGenerator');
const path = require('path');

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
    this.SOURCE_SYSTEM_ID = 1; // APSL source system ID
    
    // Discovery mode flag
    this.isDiscoveryMode = options.discover || false;
    
    // Use PuppeteerFetcher with CacheManager to avoid bot detection
    const puppeteerFetcher = new PuppeteerFetcher({ timeout: 0 });
    const cacheDir = path.join(__dirname, '../../scraped-html/apsl');
    this.cache = new CacheManager(cacheDir, puppeteerFetcher, 24);
    this.parser = new ApslHtmlParser();
    this.sqlGenerator = new SqlGenerator();
    
    // Track force-refresh flag from options
    this.forceRefresh = options.forceRefresh || false;
    
    // Conference data cache (with tables for team extraction)
    this.conferences = new Map();

    // Track fetched match URLs to avoid duplicates
    this.fetchedMatchUrls = new Set();

    // Initialize APSL compartmentalized data stores
    this.data.apslLeagues = new Map();
    this.data.apslConferences = new Map();
    this.data.apslDivisions = new Map();
    this.data.apslTeams = new Map();
    this.data.apslPlayers = new Map();           // Normalized players table
    this.data.apslTeamPlayers = new Map();       // Junction: team_division_players
    this.data.apslMatches = new Map();
    this.data.apslMatchDivisions = new Map();    // Junction: match_divisions
    this.data.apslPlayerSeasonStats = new Map(); // Season totals from roster pages
    this.data.apslMatchEvents = new Map();       // Individual match events (goals, cards, subs)
    this.data.apslMatchLineups = new Map();      // Match lineups (starters vs subs)
    this.data.apslTeamStats = new Map();
  }

  async initialize() {
    this.log('Initializing APSL scraper...');
    if (this.isDiscoveryMode) {
      this.log('🔍 DISCOVERY MODE: Will scrape structure only (no DB writes)');
    } else {
      this.log('Generating normalized SQL files with source_system_id=1 (APSL)');
    }
  }

  async fetchData() {
    // Discovery mode: Run DiscoveryMode class for structure extraction
    if (this.isDiscoveryMode) {
      const DiscoveryMode = require('../modes/DiscoveryMode');
      const discovery = new DiscoveryMode(this);
      await discovery.discover();
      return; // Exit early - no transformData or SQL generation
    }
    
    // Normal enrichment mode: fetch all data
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
    
    // Use CacheManager to fetch standings page
    const html = await this.cache.fetch(`${this.baseUrl}/standings/`, this.forceRefresh);
    
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
        source_system_id: this.SOURCE_SYSTEM_ID,
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
          source_system_id: this.SOURCE_SYSTEM_ID,
          external_id: teamData.apsl_team_id
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
        const html = await this.cache.fetch(teamUrl, this.forceRefresh);
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
              source_system_id: this.SOURCE_SYSTEM_ID,
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

          // NOTE: player_season_stats table removed - stats now calculated via views
          // from match_events table. Season stats collection code commented out.
          /*
          // Create player season stats if available (includes assists)
          const stats = statsMap.get(playerData.name);
          if (stats) {
            const statsId = playerId; // One stat record per player
            const apslPlayerSeasonStats = {
              id: statsId,
              player_id: playerId,  // References normalized player_id
              team_id: apslTeamId,
              season: '2025/2026', // TODO: Extract from league data
              goals: stats.goals || 0,
              assists: stats.assists || 0,
              yellow_cards: stats.yellow_cards || 0,
              red_cards: stats.red_cards || 0,
              games_played: stats.games_played || 0
            };
            this.data.apslPlayerSeasonStats.set(statsId, apslPlayerSeasonStats);
          }
          */
        }
        
        // NOTE: Stats summary logging removed since player_season_stats table no longer exists
        /*
        // Log stats summary
        const totalGoals = Array.from(this.data.apslPlayerSeasonStats.values())
          .filter(s => {
            // Find team_division_player junction to check if player is on this team
            const teamPlayer = Array.from(this.data.apslTeamPlayers.values())
              .find(tp => tp.player_id === s.player_id && tp.team_id === apslTeamId);
            return teamPlayer !== undefined;
          })
          .reduce((sum, s) => sum + s.goals, 0);
        if (totalGoals > 0) {
          this.log(`   ${apslTeam.name}: ${totalGoals} total goals scored`);
        }
        */
        
      } catch (error) {
        this.logError(`Failed to fetch roster for ${apslTeam.name}`, error);
      }
    }
  }

  async fetchSchedules() {
    this.log('\n📅 Fetching schedules...');
    const startTime = Date.now();
    
    let completedMatches = 0;
    let scheduledMatches = 0;
    let matchCounter = 1;
    let eventCounter = 1;
    let lineupCounter = 1;
    let skippedDuplicates = 0;
    let fetchedMatchPages = 0;

    // Build opponent name -> apsl_team lookup
    const teamsByName = new Map();
    for (const [_, apslTeam] of this.data.apslTeams.entries()) {
      teamsByName.set(apslTeam.name, apslTeam);
    }

    let teamCount = 0;
    const totalTeams = this.data.apslTeams.size;

    for (const [apslTeamId, apslTeam] of this.data.apslTeams.entries()) {
      teamCount++;
      const teamStartTime = Date.now();
      
      try {
        this.log(`   [${teamCount}/${totalTeams}] ${apslTeam.name}...`);
        const teamUrl = `${this.baseUrl}/APSL/Team/${apslTeam.external_id}`;
        const html = await this.cache.fetch(teamUrl, this.forceRefresh);
        this.parser.parse(html);

        const schedule = this.parser.parseSchedule();
        const teamFetchTime = ((Date.now() - teamStartTime) / 1000).toFixed(1);
        this.log(`       → Schedule fetched (${schedule.length} matches, ${teamFetchTime}s)`);

        for (const matchData of schedule) {
          // Create unique match ID from date + teams
          const matchKey = `${matchData.date}-${apslTeam.name}-${matchData.opponent}`;

          // Skip if we've already added this match (will happen when both teams are in APSL)
          if (this.data.apslMatches.has(matchKey)) {
            continue;
          }

          // Find opponent's apsl_team_id
          let opponentTeam = teamsByName.get(matchData.opponent);

          // If opponent team not found, create stub team (likely removed/defunct team)
          if (!opponentTeam && matchData.opponent) {
            const stubTeamId = this.data.apslTeams.size + 1;
            const stubExternalId = `STUB-${matchData.opponent.replace(/\s+/g, '')}`;
            
            // Create stub team record
            const stubTeam = {
              id: stubTeamId,
              sport_division_id: null,  // Unknown division for defunct/removed teams
              name: matchData.opponent,
              city: null,
              logo_url: null,
              source_system_id: this.SOURCE_SYSTEM_ID,
              external_id: stubExternalId
            };
            
            this.data.apslTeams.set(stubTeamId, stubTeam);
            teamsByName.set(matchData.opponent, stubTeam);
            opponentTeam = stubTeam;
            
            this.log(`       → Created stub team: ${matchData.opponent} (ID: ${stubTeamId})`);
          }

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
            home_team_id: homeTeamId,
            away_team_id: awayTeamId,
            match_type_id: 1,  // League match
            match_status_id: matchData.homeScore !== null ? 3 : 1,  // 3=completed, 1=scheduled  
            match_date: matchData.date,
            match_time: null, // APSL doesn't always provide time
            venue_id: null,
            home_score: matchData.homeScore,
            away_score: matchData.awayScore,
            source_system_id: this.SOURCE_SYSTEM_ID,
            external_id: matchKey
          };

          this.data.apslMatches.set(matchKey, apslMatch);

          // Store match-division relationship for junction table
          const divisionId = this.teamDivisions.get(apslTeamId);
          if (divisionId) {
            this.data.apslMatchDivisions.set(`${apslMatchId}-${divisionId}`, {
              match_id: apslMatchId,
              division_id: divisionId
            });
          }

          // --- Fetch per-match player stats (only if not already fetched) ---
          if (matchData.matchStatus === 'completed') {
            if (!matchData.matchUrl) {
              continue;
            }
            const fullMatchUrl = matchData.matchUrl.startsWith('http') 
              ? matchData.matchUrl 
              : `${this.baseUrl}${matchData.matchUrl}`;
            
            // Skip if we already fetched this match URL
            if (this.fetchedMatchUrls.has(fullMatchUrl)) {
              skippedDuplicates++;
              continue;
            }
            
            try {
              const matchFetchStart = Date.now();
              this.fetchedMatchUrls.add(fullMatchUrl);
              
              const matchHtml = await this.cache.fetch(fullMatchUrl, this.forceRefresh);
              
              const matchParser = new (require('../parsers/ApslHtmlParser'))();
              matchParser.parse(matchHtml);
              const { events, lineups } = matchParser.parseMatchPlayerStats(); // Now returns {events, lineups}
              
              const matchFetchTime = ((Date.now() - matchFetchStart) / 1000).toFixed(1);
              fetchedMatchPages++;
              
              let matchedEventCount = 0;
              let matchedLineupCount = 0;
              
              // Map of event types to their IDs in match_event_types table
              const eventTypeMap = {
                'goal': 1,
                'assist': 2,
                'yellow_card': 3,
                'red_card': 4,
                'sub_in': 5,
                'sub_out': 6
              };

              for (const event of events) {
                // Find which team this player belongs to based on teamName from parser
                let playerTeamId = null;
                let player = null;
                
                if (event.team_name) {
                  const teamMatch = teamsByName.get(event.team_name);
                  if (teamMatch) {
                    playerTeamId = teamMatch.id;
                    player = this.findPlayerByName(event.player_name, playerTeamId);
                  }
                }
                
                // If we couldn't determine team from name, try current team then opponent
                if (!player) {
                  player = this.findPlayerByName(event.player_name, apslTeamId);
                  if (player) {
                    playerTeamId = apslTeamId;
                  } else if (opponentTeam) {
                    player = this.findPlayerByName(event.player_name, opponentTeam.id);
                    if (player) {
                      playerTeamId = opponentTeam.id;
                    }
                  }
                }
                
                if (!player || !playerTeamId) continue;
                matchedEventCount++;
                
                // Create match event record
                const matchEvent = {
                  id: eventCounter++,
                  match_id: apslMatchId,
                  player_id: player.id,
                  team_id: playerTeamId,
                  event_type_id: eventTypeMap[event.event_type],
                  minute: event.minute,
                  assisted_by_player_id: null // TODO: Parse assist data if available
                };
                this.data.apslMatchEvents.set(matchEvent.id, matchEvent);
              }
              
              // Process lineups
              for (const lineup of lineups) {
                // Find team by name
                let lineupTeamId = null;
                if (lineup.team_name) {
                  const teamMatch = teamsByName.get(lineup.team_name);
                  if (teamMatch) {
                    lineupTeamId = teamMatch.id;
                  }
                }
                
                if (!lineupTeamId) continue;
                
                // Find player by name on that team
                const player = this.findPlayerByName(lineup.player_name, lineupTeamId);
                if (!player) continue;
                
                matchedLineupCount++;
                const matchLineup = {
                  id: lineupCounter++,
                  match_id: apslMatchId,
                  player_id: player.id,
                  team_id: lineupTeamId,
                  is_starter: lineup.is_starter,
                  position: null // APSL doesn't provide positions in match pages
                };
                this.data.apslMatchLineups.set(matchLineup.id, matchLineup);
              }
              
              this.log(`       → Match events: ${events.length} total, ${matchedEventCount} matched (${matchFetchTime}s)`);
              this.log(`       → Match lineups: ${lineups.length} total, ${matchedLineupCount} matched`);
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

    const totalTime = ((Date.now() - startTime) / 1000).toFixed(1);
    this.log(`   ✓ ${completedMatches} completed matches with scores`);
    this.log(`   ✓ ${scheduledMatches} scheduled matches`);
    this.log(`   ✓ ${fetchedMatchPages} match pages fetched`);
    this.log(`   ✓ ${skippedDuplicates} duplicate matches skipped`);
    this.log(`   ⏱ Total schedule fetch time: ${totalTime}s`);
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
        
        // NOTE: team_stats table removed - stats now calculated via team_season_standings view
        // from matches table. Team stats collection code commented out.
        /*
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
        */
      }
    }
    
    // this.log(`   ✓ ${statsCount} team stat records`);
  }

  async transformData() {
    // Apply team filter if specified
    if (this.hasTeamFilter()) {
      this.applyTeamFilter();
    }
    
    // Migrate APSL teams to registry for club linking
    this.log('\n📦 Migrating APSL teams to registry...');
    for (const [id, team] of this.data.apslTeams.entries()) {
      this.registry.addTeam({
        id: team.id,
        name: team.name,
        sport_division_id: team.sport_division_id || null,
        city: team.city || null,
        logo_url: team.logo_url || null,
        is_active: team.is_active !== false,
        source_system_id: this.SOURCE_SYSTEM_ID,
        external_id: team.external_id
      });
    }
    
    // Link teams to clubs and sport_divisions
    await this.linkTeamsToClubs(this.SOURCE_SYSTEM_ID, 'APSL');
    
    // Sync registry teams back to data.apslTeams
    this.log('\n📥 Syncing linked teams back to data store...');
    for (const team of this.registry.getAllTeams()) {
      if (team.source_system_id === this.SOURCE_SYSTEM_ID) {
        const existingTeam = this.data.apslTeams.get(team.id);
        if (existingTeam) {
          existingTeam.sport_division_id = team.sport_division_id;
        }
      }
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
    this.log('\n� Writing SQL files (APSL structure)...');
    
    // Debug: Check data sizes
    this.log(`   DEBUG: apslLeagues: ${this.data.apslLeagues.size}`);
    this.log(`   DEBUG: apslConferences: ${this.data.apslConferences.size}`);
    this.log(`   DEBUG: apslDivisions: ${this.data.apslDivisions.size}`);
    this.log(`   DEBUG: apslTeams: ${this.data.apslTeams.size}`);
    this.log(`   DEBUG: apslPlayers: ${this.data.apslPlayers.size}`);
    this.log(`   DEBUG: apslTeamPlayers: ${this.data.apslTeamPlayers.size}`);
    this.log(`   DEBUG: apslMatches: ${this.data.apslMatches.size}`);
    this.log(`   DEBUG: apslMatchDivisions: ${this.data.apslMatchDivisions.size}`);
    this.log(`   DEBUG: apslMatchEvents: ${this.data.apslMatchEvents.size}`);
    this.log(`   DEBUG: apslMatchLineups: ${this.data.apslMatchLineups.size}`);
    this.log(`   DEBUG: registry clubs: ${this.registry.clubs.size}`);
    this.log(`   DEBUG: registry sportDivisions: ${this.registry.sportDivisions.size}`);
    
    // Write clubs and sport_divisions SQL (from registry)
    const path = require('path');
    const clubsSql = this.sqlWriter.generateClubsSQL(this.registry.getAllClubs());
    const sportDivsSql = this.sqlWriter.generateSportDivisionsSQL(this.registry.getAllSportDivisions());
    
    await this.sqlWriter.writeFile(
      path.join(__dirname, '../../data/025-apsl-clubs.sql'),
      clubsSql
    );
    await this.sqlWriter.writeFile(
      path.join(__dirname, '../../data/027-apsl-sport-divisions.sql'),
      sportDivsSql
    );
    
    const results = await this.sqlGenerator.generateMultiple([
      // APSL Leagues (table 016)
      {
          filename: '016-apsl-leagues.sql',
          data: this.data.apslLeagues,
          options: {
              title: 'APSL Leagues',
              tableName: 'leagues',
              useInserts: true,
              conflictColumns: ['id']
          }
      },
      // APSL Conferences (table 017)
      {
          filename: '017-apsl-conferences.sql',
          data: this.data.apslConferences,
          options: {
              title: 'APSL Conferences',
              tableName: 'conferences',
              useInserts: true,
              conflictColumns: ['id']
          }
      },
      // APSL Divisions (table 018)
      {
          filename: '018-apsl-divisions.sql',
          data: this.data.apslDivisions,
          options: {
              title: 'APSL Divisions',
              tableName: 'divisions',
              useInserts: true,
              conflictColumns: ['id']
          }
      },
      // APSL Teams (table 030)
      {
          filename: '028-apsl-teams.sql',
          data: this.data.apslTeams,
          options: {
              title: 'APSL Teams',
              tableName: 'teams',
              useInserts: true,
              conflictColumns: ['id']
          }
      },
      // Players (table 032) - MUST come before team_division_players
      {
          filename: '032-apsl-players.sql',
          data: this.data.apslPlayers,
          options: {
              title: 'APSL Players',
              tableName: 'players',
              useInserts: true,
              conflictColumns: ['source_system_id', 'external_id']
          }
      },
      // Team Players (table 033) - MUST come after players
      {
          filename: '034-apsl-team-players.sql',
          data: this.data.apslTeamPlayers,
          options: {
              title: 'APSL Team Rosters',
              tableName: 'team_division_players',
              useInserts: true,
              conflictColumns: ['team_id', 'player_id']
          }
      },
      // APSL Matches (table 037)
      {
          filename: '038-apsl-matches.sql',
          data: this.data.apslMatches,
          options: {
              title: 'APSL Matches',
              tableName: 'matches',
              useInserts: true,
              conflictColumns: ['id']
          }
      },
      // APSL Match Divisions (table 038) - Junction table
      {
          filename: '039-apsl-match-divisions.sql',
          data: this.data.apslMatchDivisions,
          options: {
              title: 'APSL Match-Division Relationships',
              tableName: 'match_divisions',
              useInserts: true,
              conflictColumns: ['match_id', 'division_id']
          }
      },
      // APSL Match Lineups (table 039)
      {
          filename: '052-apsl-match-lineups.sql',
          data: this.data.apslMatchLineups,
          options: {
              title: 'APSL Match Lineups',
              tableName: 'match_lineups',
              useInserts: true,
              conflictColumns: ['match_id', 'player_id']
          }
      },
      // APSL Match Events (table 040)
      {
          filename: '051-apsl-match-events.sql',
          data: this.data.apslMatchEvents,
          options: {
              title: 'APSL Match Events',
              tableName: 'match_events',
              useInserts: true,
              conflictColumns: ['id']
          }
      }
    ]);
    
    for (const result of results) {
      this.logSuccess(`${result.filepath}: ${result.count} records`);
    }
  }

  async cleanup() {
    // Close Puppeteer browser if open (accessed via CacheManager)
    if (this.cache && this.cache.fetcher && this.cache.fetcher.close) {
      await this.cache.fetcher.close();
    }
    this.parser.destroy();
  }

  // Helper method: Normalize player name for matching
  normalizePlayerName(name) {
    return name.trim().toLowerCase().replace(/\s+/g, ' ');
  }

  // Helper method: Find player by name on a specific team
  findPlayerByName(playerName, teamId) {
    const normalizedName = this.normalizePlayerName(playerName);
    
    return Array.from(this.data.apslPlayers.values()).find(p => {
      // Check if this player is on the specified team
      const teamPlayer = Array.from(this.data.apslTeamPlayers.values())
        .find(tp => tp.player_id === p.id && tp.team_id === teamId);
      if (!teamPlayer) return false;
      
      const fullName = this.normalizePlayerName(p.first_name + ' ' + p.last_name);
      const altFullName = this.normalizePlayerName(p.full_name);
      return normalizedName === fullName || normalizedName === altFullName;
    });
  }
}

module.exports = ApslScraper;
