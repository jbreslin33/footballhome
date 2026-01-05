const path = require('path');
const fs = require('fs').promises;
const { Pool } = require('pg');

/**
 * Governing Body Scraper - Proof of Concept
 * 
 * Tests the complete scrape → parse → write workflow:
 * 1. Discovery mode: is_initialized = false
 * 2. Fetch data from JSON source
 * 3. Parse and validate
 * 4. Write directly to database (no SQL file generation)
 * 5. Set is_initialized = true
 * 6. Sync mode: is_initialized = true (update existing data)
 */
class GoverningBodyScraper {
  constructor() {
    this.pool = new Pool({
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME || 'footballhome',
      user: process.env.DB_USER || 'footballhome_user',
      password: process.env.DB_PASSWORD || 'footballhome_pass',
    });
    
    this.sourceFile = path.join(__dirname, '../../config/governing-bodies-source.json');
    this.sourceSystemId = 7; // static_json
    this.scraperTypeId = 2; // google_sheets (repurposed for JSON)
    this.targetTypeId = 18; // governing_bodies
  }

  /**
   * Main entry point
   */
  async run(mode = 'discover') {
    const client = await this.pool.connect();
    
    try {
      console.log(`\n🏛️  Governing Bodies Scraper - ${mode.toUpperCase()} mode`);
      console.log('=' .repeat(60));
      
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
   * Discovery mode: First-time import
   * - Creates organizations for each governing body
   * - Creates governing_bodies records
   * - Sets is_initialized = true
   */
  async discover(client) {
    await client.query('BEGIN');
    
    try {
      // 1. Fetch data
      console.log('📥 Fetching governing bodies data...');
      const data = await this.fetchData();
      console.log(`   Found ${data.governing_bodies.length} governing bodies`);
      
      // 2. Parse and validate
      console.log('🔍 Parsing and validating...');
      const parsed = this.parseData(data);
      console.log(`   Validated ${parsed.length} records`);
      
      // 3. Write to database
      console.log('💾 Writing to database...');
      await this.writeToDatabase(client, parsed);
      
      // 4. Mark as initialized
      console.log('✓ Marking scrape target as initialized...');
      await client.query(`
        UPDATE scrape_targets
        SET is_initialized = true, last_synced_at = NOW()
        WHERE source_system_id = $1 AND target_type_id = $2
      `, [this.sourceSystemId, this.targetTypeId]);
      
      await client.query('COMMIT');
      console.log('✓ Discovery complete - data imported and initialized');
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    }
  }

  /**
   * Sync mode: Update existing data
   * - Updates existing records
   * - Adds new records if found
   */
  async sync(client) {
    await client.query('BEGIN');
    
    try {
      console.log('📥 Fetching governing bodies data for sync...');
      const data = await this.fetchData();
      
      console.log('🔍 Parsing and validating...');
      const parsed = this.parseData(data);
      
      console.log('🔄 Updating existing records...');
      await this.writeToDatabase(client, parsed);
      
      console.log('✓ Updating sync timestamp...');
      await client.query(`
        UPDATE scrape_targets
        SET last_synced_at = NOW()
        WHERE source_system_id = $1 AND target_type_id = $2
      `, [this.sourceSystemId, this.targetTypeId]);
      
      await client.query('COMMIT');
      console.log('✓ Sync complete - data updated');
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    }
  }

  /**
   * Fetch data from JSON file
   */
  async fetchData() {
    const content = await fs.readFile(this.sourceFile, 'utf8');
    return JSON.parse(content);
  }

  /**
   * Parse and validate data
   */
  parseData(data) {
    const scopeMap = {
      'international': 1,
      'confederation': 2,
      'national': 3,
      'regional': 4
    };
    
    return data.governing_bodies.map(gb => ({
      id: gb.id,
      name: gb.name,
      short_name: gb.short_name,
      scope_id: scopeMap[gb.scope],
      parent_id: gb.parent_id,
      website_url: gb.website_url,
      description: gb.description
    }));
  }

  /**
   * Write to database using ON CONFLICT for upsert
   */
  async writeToDatabase(client, governingBodies) {
    for (const gb of governingBodies) {
      // First, create/update the organization
      const orgResult = await client.query(`
        INSERT INTO organizations (id, name, short_name, website_url, is_active)
        VALUES ($1, $2, $3, $4, true)
        ON CONFLICT (id) DO UPDATE SET
          name = EXCLUDED.name,
          short_name = EXCLUDED.short_name,
          website_url = EXCLUDED.website_url
        RETURNING id
      `, [gb.id, gb.name, gb.short_name, gb.website_url]);
      
      const orgId = orgResult.rows[0].id;
      
      // Then create/update the governing_body
      await client.query(`
        INSERT INTO governing_bodies (id, organization_id, parent_governing_body_id, scope_id, is_active)
        VALUES ($1, $2, $3, $4, true)
        ON CONFLICT (organization_id) DO UPDATE SET
          parent_governing_body_id = EXCLUDED.parent_governing_body_id,
          scope_id = EXCLUDED.scope_id
      `, [gb.id, orgId, gb.parent_id, gb.scope_id]);
      
      console.log(`   ✓ ${gb.name} (${gb.short_name})`);
    }
  }
}

// CLI execution
if (require.main === module) {
  const mode = process.argv[2] || 'discover';
  const scraper = new GoverningBodyScraper();
  
  scraper.run(mode)
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}

module.exports = GoverningBodyScraper;
