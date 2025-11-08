const axios = require('axios');
const cheerio = require('cheerio');
const { Pool } = require('pg');

/**
 * Base League Scraper Class
 * Provides common functionality for scraping different league websites
 */
class BaseScraper {
  constructor(config) {
    this.leagueName = config.leagueName;
    this.baseUrl = config.baseUrl;
    this.dataSource = config.dataSource;
    this.season = config.season;
    this.pool = config.pool;
    
    // Rate limiting
    this.requestDelay = config.requestDelay || 1000; // 1 second between requests
    this.lastRequest = 0;
  }

  /**
   * Rate-limited HTTP request
   */
  async makeRequest(url, options = {}) {
    const now = Date.now();
    const elapsed = now - this.lastRequest;
    
    if (elapsed < this.requestDelay) {
      await new Promise(resolve => setTimeout(resolve, this.requestDelay - elapsed));
    }
    
    try {
      console.log(`Fetching: ${url}`);
      const response = await axios.get(url, {
        timeout: 10000,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        },
        ...options
      });
      
      this.lastRequest = Date.now();
      return response;
    } catch (error) {
      console.error(`Failed to fetch ${url}:`, error.message);
      throw error;
    }
  }

  /**
   * Parse HTML content with cheerio
   */
  parseHTML(html) {
    return cheerio.load(html);
  }

  /**
   * Check if a game already exists in the database
   */
  async checkGameExists(homeTeamId, awayTeamId, matchDate, venueId = null) {
    const result = await this.pool.query(
      'SELECT check_duplicate_league_game($1, $2, $3, $4)',
      [homeTeamId, awayTeamId, matchDate, venueId]
    );
    return result.rows[0].check_duplicate_league_game;
  }

  /**
   * Find or create team by name with fuzzy matching
   */
  async findOrCreateTeam(teamName, leagueInfo = {}) {
    // Clean team name
    teamName = teamName.trim();

    // First try exact match
    const existingTeam = await this.pool.query(
      'SELECT id, name FROM teams WHERE LOWER(name) = LOWER($1)',
      [teamName]
    );

    if (existingTeam.rows.length > 0) {
      console.log(`Found existing team: ${existingTeam.rows[0].name} -> ${teamName}`);
      return existingTeam.rows[0].id;
    }

    // Get the External League Teams division
    const divisionResult = await this.pool.query(
      "SELECT id FROM sport_divisions WHERE name = 'External League Teams' LIMIT 1"
    );
    
    const divisionId = divisionResult.rows.length > 0 
      ? divisionResult.rows[0].id 
      : null;

    // Create new team if not found
    console.log(`Creating new team: ${teamName}`);
    const newTeam = await this.pool.query(
      'INSERT INTO teams (name, description, division_id) VALUES ($1, $2, $3) RETURNING id',
      [teamName, `Auto-created from ${this.leagueName} scraping`, divisionId]
    );

    return newTeam.rows[0].id;
  }

  /**
   * Create a league game record
   */
  async createLeagueGame(gameData) {
    const {
      homeTeamId, awayTeamId, scheduledDate, competitionName,
      competitionRound, leagueGameId, externalUrl, venueId,
      leagueDivisionId, refereeName
    } = gameData;

    // Check for duplicates
    const isDuplicate = await this.checkGameExists(homeTeamId, awayTeamId, scheduledDate, venueId);
    if (isDuplicate) {
      console.log(`Skipping duplicate game: ${homeTeamId} vs ${awayTeamId} on ${scheduledDate}`);
      return null;
    }

    const result = await this.pool.query(`
      INSERT INTO league_games (
        season, home_team_id, away_team_id, scheduled_date,
        venue_id, competition_name, competition_round,
        league_game_id, external_url, data_source,
        league_division_id, referee_name, scraped_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      RETURNING id
    `, [
      this.season, homeTeamId, awayTeamId, scheduledDate,
      venueId, competitionName, competitionRound,
      leagueGameId, externalUrl, this.dataSource,
      leagueDivisionId, refereeName, new Date()
    ]);

    console.log(`Created league game: ${competitionName} - ${homeTeamId} vs ${awayTeamId}`);
    return result.rows[0].id;
  }

  /**
   * Update game with match results
   */
  async updateGameResult(gameId, resultData) {
    const {
      homeScore, awayScore, homeHTScore, awayHTScore,
      attendance, gameStatus = 'completed', rawMatchData
    } = resultData;

    await this.pool.query(
      'SELECT update_league_game_stats($1, $2, $3, $4, $5, $6, $7)',
      [gameId, homeScore, awayScore, homeHTScore, awayHTScore, attendance, rawMatchData]
    );

    console.log(`Updated game ${gameId} result: ${homeScore}-${awayScore}`);
  }

  /**
   * Add match event
   */
  async addMatchEvent(gameId, eventData) {
    const {
      eventType, teamId, playerName, minute,
      description, additionalData
    } = eventData;

    const result = await this.pool.query(
      'SELECT add_league_match_event($1, $2, $3, $4, $5, $6, $7)',
      [gameId, eventType, teamId, playerName, minute, description, additionalData]
    );

    return result.rows[0].add_league_match_event;
  }

  /**
   * Add player statistics
   */
  async addPlayerStats(gameId, statsData) {
    const {
      teamId, playerName, minutesPlayed = 0, goals = 0, assists = 0,
      yellowCards = 0, redCards = 0, shots = 0, shotsOnTarget = 0,
      startingPosition, isStarter = false, isCaptain = false,
      substitutedOnMinute, substitutedOffMinute, rawStatsData
    } = statsData;

    await this.pool.query(`
      INSERT INTO league_match_player_stats (
        league_game_id, team_id, player_name, minutes_played,
        goals, assists, yellow_cards, red_cards, shots, shots_on_target,
        starting_position, is_starter, is_captain,
        substituted_on_minute, substituted_off_minute, raw_stats_data
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
      ON CONFLICT (league_game_id, team_id, player_name) 
      DO UPDATE SET
        goals = EXCLUDED.goals,
        assists = EXCLUDED.assists,
        yellow_cards = EXCLUDED.yellow_cards,
        red_cards = EXCLUDED.red_cards,
        shots = EXCLUDED.shots,
        shots_on_target = EXCLUDED.shots_on_target,
        updated_at = CURRENT_TIMESTAMP
    `, [
      gameId, teamId, playerName, minutesPlayed,
      goals, assists, yellowCards, redCards, shots, shotsOnTarget,
      startingPosition, isStarter, isCaptain,
      substitutedOnMinute, substitutedOffMinute, rawStatsData
    ]);

    console.log(`Added/updated player stats: ${playerName} - ${goals}G ${assists}A`);
  }

  /**
   * Abstract method to be implemented by specific scrapers
   */
  async scrapeFixtures() {
    throw new Error('scrapeFixtures() must be implemented by subclass');
  }

  /**
   * Abstract method to be implemented by specific scrapers
   */
  async scrapeMatchDetails(gameId, externalUrl) {
    throw new Error('scrapeMatchDetails() must be implemented by subclass');
  }

  /**
   * Main scraping workflow
   */
  async scrape() {
    try {
      console.log(`Starting ${this.leagueName} scrape for ${this.season} season`);
      
      // Step 1: Scrape fixture list
      const fixtures = await this.scrapeFixtures();
      console.log(`Found ${fixtures.length} fixtures`);

      // Step 2: Process each fixture
      for (const fixture of fixtures) {
        try {
          const gameId = await this.createLeagueGame(fixture);
          
          if (gameId && fixture.externalUrl) {
            // Step 3: Scrape detailed match data if game was completed
            if (fixture.status === 'completed') {
              await this.scrapeMatchDetails(gameId, fixture.externalUrl);
            }
          }

          // Rate limiting between fixtures
          await new Promise(resolve => setTimeout(resolve, this.requestDelay));
        } catch (error) {
          console.error(`Error processing fixture:`, error.message);
          continue; // Continue with next fixture
        }
      }

      console.log(`Completed ${this.leagueName} scrape`);
    } catch (error) {
      console.error(`Scraping failed:`, error);
      throw error;
    }
  }
}

module.exports = BaseScraper;