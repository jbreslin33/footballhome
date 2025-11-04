const axios = require('axios');
const cheerio = require('cheerio');
const { RateLimiterMemory } = require('rate-limiter-flexible');

class APSLScraper {
  constructor(dataIntegrationService, logger) {
    this.dataService = dataIntegrationService;
    this.logger = logger;
    this.baseUrl = 'https://www.apslsoccer.com';
    
    // Rate limiter: max 10 requests per minute to be respectful
    this.rateLimiter = new RateLimiterMemory({
      keyGenerator: () => 'apsl-scraper',
      points: 10, // Number of requests
      duration: 60, // Per 60 seconds
    });
  }

  async syncAllConferences() {
    this.logger.info('Starting APSL sync for all conferences');
    
    const client = await this.dataService.db.connect();
    let sourceId, endpoints;

    try {
      // Get APSL source configuration
      const sourceResult = await client.query(`
        SELECT * FROM external_data_sources WHERE slug = 'apsl-website'
      `);
      
      if (sourceResult.rows.length === 0) {
        throw new Error('APSL data source not configured');
      }
      
      sourceId = sourceResult.rows[0].id;

      // Get all APSL endpoints
      const endpointsResult = await client.query(`
        SELECT dse.*, lc.id as conference_id, ld.id as division_id
        FROM data_source_endpoints dse
        LEFT JOIN league_conferences lc ON lc.name ILIKE '%' || 
          CASE 
            WHEN dse.name ILIKE '%delaware river%' THEN 'Delaware River'
            WHEN dse.name ILIKE '%metro%' THEN 'Metropolitan NY/NJ'
            WHEN dse.name ILIKE '%southeast%' THEN 'Southeast'
            WHEN dse.name ILIKE '%mid-atlantic%' THEN 'Mid-Atlantic'
            WHEN dse.name ILIKE '%northeast%' THEN 'Northeast'
            WHEN dse.name ILIKE '%south atlantic%' THEN 'South Atlantic'
          END || '%'
        LEFT JOIN league_divisions ld ON ld.conference_id = lc.id AND ld.name = 'Premier'
        WHERE dse.source_id = $1 AND dse.data_type = 'standings'
      `, [sourceId]);

      endpoints = endpointsResult.rows;

    } finally {
      client.release();
    }

    const results = [];
    
    for (const endpoint of endpoints) {
      try {
        this.logger.info(`Scraping ${endpoint.name}...`);
        
        const result = await this.scrapeConferenceStandings(
          sourceId, 
          endpoint, 
          endpoint.conference_id, 
          endpoint.division_id
        );
        
        results.push({
          conference: endpoint.name,
          status: 'success',
          ...result
        });
        
        // Add delay between requests
        await new Promise(resolve => setTimeout(resolve, 2000));
        
      } catch (error) {
        this.logger.error(`Failed to scrape ${endpoint.name}:`, error);
        results.push({
          conference: endpoint.name,
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
      `, [sourceId]);
    } finally {
      client2.release();
    }

    this.logger.info('APSL sync completed');
    return results;
  }

  async scrapeConferenceStandings(sourceId, endpoint, conferenceId, divisionId) {
    // Rate limiting
    await this.rateLimiter.consume('apsl-scraper');

    // Create import job
    const job = await this.dataService.createImportJob(sourceId, endpoint.id, 'scheduled_sync');

    try {
      // Fetch the webpage
      const response = await axios.get(`${this.baseUrl}${endpoint.endpoint_path}`, {
        timeout: 30000,
        headers: {
          'User-Agent': 'FootballHome-DataSync/1.0 (respectful web scraper)'
        }
      });

      const $ = cheerio.load(response.data);
      const standingsData = [];
      
      // Parse extraction config
      const config = JSON.parse(endpoint.extraction_config);
      
      // Extract standings data using configured selectors
      $(config.table_selector).each((index, row) => {
        const $row = $(row);
        
        // Skip header rows or empty rows
        if ($row.find('th').length > 0 || $row.text().trim() === '') {
          return;
        }
        
        const teamName = $row.find(config.team_name).text().trim();
        
        if (teamName && teamName !== '') {
          const teamData = {
            team_name: teamName,
            games_played: $row.find(config.games_played).text().trim() || '0',
            wins: $row.find(config.wins).text().trim() || '0',
            losses: $row.find(config.losses).text().trim() || '0',
            draws: $row.find(config.draws).text().trim() || '0',
            goals_for: $row.find(config.goals_for).text().trim() || '0',
            goals_against: $row.find(config.goals_against).text().trim() || '0',
            points: $row.find(config.points).text().trim() || '0',
            external_id: `apsl_${teamName.toLowerCase().replace(/[^a-z0-9]/g, '_')}`,
            season_id: null // We'll need to implement season management
          };
          
          standingsData.push(teamData);
        }
      });

      this.logger.info(`Extracted ${standingsData.length} teams from ${endpoint.name}`);

      // Process the standings data
      const stats = await this.dataService.processStandingsData(
        job.id,
        sourceId,
        standingsData,
        conferenceId,
        divisionId
      );

      // Update job as completed
      await this.dataService.updateImportJob(job.id, 'completed', stats);

      return {
        teamsFound: standingsData.length,
        ...stats
      };

    } catch (error) {
      // Update job as failed
      await this.dataService.updateImportJob(job.id, 'failed', {
        error: error.message
      });
      throw error;
    }
  }

  async testConnection() {
    try {
      const response = await axios.get(`${this.baseUrl}/APSL/Tables/`, {
        timeout: 10000,
        headers: {
          'User-Agent': 'FootballHome-DataSync/1.0 (connection test)'
        }
      });
      
      return {
        success: true,
        status: response.status,
        message: 'APSL website is accessible'
      };
    } catch (error) {
      return {
        success: false,
        error: error.message,
        message: 'Failed to connect to APSL website'
      };
    }
  }
}

module.exports = APSLScraper;