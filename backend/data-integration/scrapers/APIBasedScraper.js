const axios = require('axios');

/**
 * Generic API-based scraper for leagues that provide REST APIs
 */
class APIBasedScraper {
  constructor(dataIntegrationService, logger, sourceConfig) {
    this.dataService = dataIntegrationService;
    this.logger = logger;
    this.config = sourceConfig;
    this.baseUrl = sourceConfig.base_url;
    this.authType = sourceConfig.authentication_type;
    this.authConfig = sourceConfig.authentication_config || {};
  }

  async syncLeagueData() {
    this.logger.info(`Starting API sync for ${this.config.name}`);
    
    const client = await this.dataService.db.connect();
    let endpoints;

    try {
      // Get all endpoints for this source
      const endpointsResult = await client.query(`
        SELECT * FROM data_source_endpoints 
        WHERE source_id = $1 AND is_active = true
        ORDER BY name
      `, [this.config.id]);

      endpoints = endpointsResult.rows;
    } finally {
      client.release();
    }

    const results = [];
    
    for (const endpoint of endpoints) {
      try {
        this.logger.info(`Processing ${endpoint.name}...`);
        
        let result;
        switch (endpoint.data_type) {
          case 'standings':
            result = await this.syncStandings(endpoint);
            break;
          case 'fixtures':
            result = await this.syncFixtures(endpoint);
            break;
          case 'results':
            result = await this.syncResults(endpoint);
            break;
          case 'teams':
            result = await this.syncTeams(endpoint);
            break;
          default:
            throw new Error(`Unsupported data type: ${endpoint.data_type}`);
        }
        
        results.push({
          endpoint: endpoint.name,
          status: 'success',
          ...result
        });
        
      } catch (error) {
        this.logger.error(`Failed to process ${endpoint.name}:`, error);
        results.push({
          endpoint: endpoint.name,
          status: 'error',
          error: error.message
        });
      }
    }

    // Update last sync time
    const client2 = await this.dataService.db.connect();
    try {
      await client2.query(`
        UPDATE external_data_sources 
        SET last_sync_at = CURRENT_TIMESTAMP 
        WHERE id = $1
      `, [this.config.id]);
    } finally {
      client2.release();
    }

    return results;
  }

  async syncStandings(endpoint) {
    const job = await this.dataService.createImportJob(this.config.id, endpoint.id);

    try {
      const response = await this.makeAPIRequest(endpoint.endpoint_path);
      const standingsData = this.transformStandingsData(response.data, endpoint);

      // Find the division this data belongs to
      const divisionId = await this.findDivisionId(endpoint);

      const stats = await this.dataService.processStandingsData(
        job.id,
        this.config.id,
        standingsData,
        null, // conferenceId - set if needed
        divisionId
      );

      await this.dataService.updateImportJob(job.id, 'completed', stats);
      return { recordsFound: standingsData.length, ...stats };

    } catch (error) {
      await this.dataService.updateImportJob(job.id, 'failed', { error: error.message });
      throw error;
    }
  }

  async syncFixtures(endpoint) {
    // Implementation for fixture/match data
    this.logger.info('Fixture sync not yet implemented');
    return { message: 'Fixture sync placeholder' };
  }

  async syncResults(endpoint) {
    // Implementation for match results
    this.logger.info('Results sync not yet implemented');
    return { message: 'Results sync placeholder' };
  }

  async syncTeams(endpoint) {
    // Implementation for team data
    this.logger.info('Teams sync not yet implemented');
    return { message: 'Teams sync placeholder' };
  }

  async makeAPIRequest(path) {
    const url = `${this.baseUrl}${path}`;
    const config = {
      timeout: 30000,
      headers: {
        'User-Agent': 'FootballHome-DataSync/1.0',
        'Accept': 'application/json'
      }
    };

    // Add authentication if configured
    if (this.authType === 'api_key' && this.authConfig.api_key) {
      if (this.authConfig.header_name) {
        config.headers[this.authConfig.header_name] = this.authConfig.api_key;
      } else {
        config.headers['X-API-Key'] = this.authConfig.api_key;
      }
    } else if (this.authType === 'basic_auth') {
      config.auth = {
        username: this.authConfig.username,
        password: this.authConfig.password
      };
    }

    return axios.get(url, config);
  }

  transformStandingsData(apiData, endpoint) {
    // Parse transformation rules from endpoint config
    const rules = JSON.parse(endpoint.transformation_rules || '{}');
    
    // Generic transformation - adapt based on actual API structure
    if (Array.isArray(apiData)) {
      return apiData.map(team => ({
        team_name: this.extractValue(team, rules.team_name || 'name'),
        games_played: this.extractValue(team, rules.games_played || 'played') || 0,
        wins: this.extractValue(team, rules.wins || 'wins') || 0,
        losses: this.extractValue(team, rules.losses || 'losses') || 0,
        draws: this.extractValue(team, rules.draws || 'draws') || 0,
        goals_for: this.extractValue(team, rules.goals_for || 'goals_for') || 0,
        goals_against: this.extractValue(team, rules.goals_against || 'goals_against') || 0,
        points: this.extractValue(team, rules.points || 'points') || 0,
        external_id: this.extractValue(team, rules.external_id || 'id'),
        season_id: null // Will be set by the data service
      }));
    }

    // Handle nested data structures
    if (apiData.standings && Array.isArray(apiData.standings)) {
      return this.transformStandingsData(apiData.standings, endpoint);
    }

    throw new Error('Unexpected API data structure');
  }

  extractValue(object, path) {
    // Support dot notation for nested properties (e.g., "team.name")
    return path.split('.').reduce((obj, key) => obj && obj[key], object);
  }

  async findDivisionId(endpoint) {
    // Logic to map endpoint to division
    // This would be customized based on the league structure
    const client = await this.dataService.db.connect();
    try {
      // Default: try to find by endpoint name
      const result = await client.query(`
        SELECT ld.id 
        FROM league_divisions ld
        JOIN league_conferences lc ON ld.conference_id = lc.id
        JOIN leagues l ON lc.league_id = l.id
        WHERE l.name ILIKE $1
        LIMIT 1
      `, [`%${this.config.name}%`]);

      if (result.rows.length > 0) {
        return result.rows[0].id;
      }

      throw new Error(`Could not find division for endpoint: ${endpoint.name}`);
    } finally {
      client.release();
    }
  }

  async testConnection() {
    try {
      const response = await this.makeAPIRequest('/');
      return {
        success: true,
        status: response.status,
        message: `${this.config.name} API is accessible`
      };
    } catch (error) {
      return {
        success: false,
        error: error.message,
        message: `Failed to connect to ${this.config.name} API`
      };
    }
  }
}

module.exports = APIBasedScraper;