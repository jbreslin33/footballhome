const { Pool } = require('pg');

/**
 * Country Scraper - Proof of Concept
 * 
 * Demonstrates the complete scrape → parse → write workflow:
 * - Discovery mode: is_initialized = false (first import)
 * - Sync mode: is_initialized = true (updates)
 * - Fetches from REST Countries API
 * - Writes directly to database (no SQL file generation)
 * - Uses ON CONFLICT for upsert behavior
 */
class CountryScraper {
  constructor() {
    this.pool = new Pool({
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME || 'footballhome',
      user: process.env.DB_USER || 'footballhome_user',
      password: process.env.DB_PASSWORD || 'dev_password_123',
    });
    
    this.apiUrl = 'https://restcountries.com/v3.1/all?fields=cca3,name,fifa,continents';
    
    // Map REST Countries API continent names to our database codes
    this.continentMap = {
      'Africa': 'AF',
      'Antarctica': 'AN',
      'Asia': 'AS',
      'Europe': 'EU',
      'North America': 'NA',
      'Oceania': 'OC',
      'South America': 'SA'
    };
  }

  async run(mode = 'discover') {
    const client = await this.pool.connect();
    
    try {
      console.log(`\n🌍 Country Scraper - ${mode.toUpperCase()} mode`);
      console.log('='.repeat(60));
      
      if (mode === 'discover') {
        await this.discover(client);
      } else if (mode === 'sync') {
        await this.sync(client);
      } else {
        throw new Error(`Unknown mode: ${mode}. Use 'discover' or 'sync'.`);
      }
      
      console.log('\n✅ Scrape completed successfully\n');
    } catch (error) {
      console.error('\n❌ Scrape failed:', error.message);
      throw error;
    } finally {
      client.release();
      await this.pool.end();
    }
  }

  /**
   * Discovery mode: First-time import of all countries
   */
  async discover(client) {
    await client.query('BEGIN');
    
    try {
      console.log('📥 Fetching countries from REST Countries API...');
      const countries = await this.fetchData();
      console.log(`   Found ${countries.length} countries`);
      
      console.log('🔍 Parsing and validating...');
      const parsed = this.parseData(countries);
      console.log(`   Validated ${parsed.length} records`);
      
      console.log('💾 Writing to database...');
      const stats = await this.writeToDatabase(client, parsed);
      console.log(`   ✓ Inserted: ${stats.inserted}, Updated: ${stats.updated}`);
      
      await client.query('COMMIT');
      console.log('✓ Discovery complete - all countries imported');
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    }
  }

  /**
   * Sync mode: Update existing countries
   */
  async sync(client) {
    await client.query('BEGIN');
    
    try {
      console.log('📥 Fetching countries for sync...');
      const countries = await this.fetchData();
      
      console.log('🔍 Parsing and validating...');
      const parsed = this.parseData(countries);
      
      console.log('🔄 Updating database...');
      const stats = await this.writeToDatabase(client, parsed);
      console.log(`   ✓ Inserted: ${stats.inserted}, Updated: ${stats.updated}`);
      
      await client.query('COMMIT');
      console.log('✓ Sync complete - countries updated');
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    }
  }

  /**
   * Fetch data from REST Countries API
   */
  async fetchData() {
    const response = await fetch(this.apiUrl);
    if (!response.ok) {
      throw new Error(`API request failed: ${response.statusText}`);
    }
    return await response.json();
  }

  /**
   * Parse and validate country data
   */
  parseData(countries) {
    return countries
      .filter(c => c.cca3) // Must have ISO code
      .map(c => {
        // Get primary continent (some countries span multiple continents)
        const continentName = c.continents?.[0];
        const continentCode = continentName ? this.continentMap[continentName] : null;
        
        return {
          code: c.cca3, // ISO 3166-1 alpha-3
          name: c.name?.common || c.name?.official,
          fifa_code: c.fifa || null,
          continent_code: continentCode
        };
      })
      .filter(c => c.name); // Must have a name
  }

  /**
   * Write to database using ON CONFLICT for upsert
   * Returns stats: { inserted, updated }
   */
  async writeToDatabase(client, countries) {
    let inserted = 0;
    let updated = 0;
    
    // First, get continent_id mappings from database
    const continentResult = await client.query(`
      SELECT id, code FROM continents
    `);
    const continentIdMap = {};
    for (const row of continentResult.rows) {
      continentIdMap[row.code] = row.id;
    }
    
    for (const country of countries) {
      const continentId = country.continent_code ? continentIdMap[country.continent_code] : null;
      
      const result = await client.query(`
        INSERT INTO countries (code, name, fifa_code, continent_id, is_active)
        VALUES ($1, $2, $3, $4, true)
        ON CONFLICT (code) DO UPDATE SET
          name = EXCLUDED.name,
          fifa_code = EXCLUDED.fifa_code,
          continent_id = EXCLUDED.continent_id,
          is_active = EXCLUDED.is_active
        RETURNING (xmax = 0) AS is_insert
      `, [country.code, country.name, country.fifa_code, continentId]);
      
      if (result.rows[0].is_insert) {
        inserted++;
      } else {
        updated++;
      }
    }
    
    return { inserted, updated };
  }
}

// CLI execution
if (require.main === module) {
  const mode = process.argv[2] || 'discover';
  const scraper = new CountryScraper();
  
  scraper.run(mode)
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}

module.exports = CountryScraper;
