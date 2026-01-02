/**
 * Database Connection Utility
 * Provides connection to PostgreSQL database for reading scrape_targets
 */

const { Client } = require('pg');

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'footballhome',
  user: process.env.DB_USER || 'footballhome_user',
  password: process.env.DB_PASSWORD || 'footballhome_pass'
};

/**
 * Get active scrape targets from database
 * @returns {Promise<Array>} Array of scrape target objects
 */
async function getScrapeTargets() {
  const client = new Client(dbConfig);
  
  try {
    await client.connect();
    
    const result = await client.query(`
      SELECT 
        st.id,
        st.target_type,
        st.url,
        st.description,
        st.config,
        ss.name as source_system_name
      FROM scrape_targets st
      LEFT JOIN source_systems ss ON st.source_system_id = ss.id
      WHERE st.is_active = true
      ORDER BY st.source_system_id, st.target_type, st.id
    `);
    
    await client.end();
    return result.rows;
    
  } catch (error) {
    await client.end().catch(() => {});
    throw new Error(`Database connection failed: ${error.message}`);
  }
}

module.exports = {
  getScrapeTargets
};
