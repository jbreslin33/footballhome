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
 * @param {Object} filters - Optional filters
 * @param {string} filters.sourceSystem - Filter by source system name (e.g., 'apsl', 'casa')
 * @param {string} filters.targetType - Filter by target type name (e.g., 'league_structure', 'team_roster')
 * @param {string} filters.scraperType - Filter by scraper type name (e.g., 'teampass_html', 'google_sheets')
 * @returns {Promise<Array>} Array of scrape target objects
 */
async function getScrapeTargets(filters = {}) {
  const client = new Client(dbConfig);
  
  try {
    await client.connect();
    
    let query = `
      SELECT 
        st.id,
        st.url,
        st.label,
        st.params,
        st.is_active,
        ss.id as source_system_id,
        ss.name as source_system_name,
        ss.description as source_system_description,
        sct.id as scraper_type_id,
        sct.name as scraper_type_name,
        sct.parser_class,
        sct.platform,
        stt.id as target_type_id,
        stt.name as target_type_name,
        stt.description as target_type_description
      FROM scrape_targets st
      LEFT JOIN source_systems ss ON st.source_system_id = ss.id
      LEFT JOIN scraper_types sct ON st.scraper_type_id = sct.id
      LEFT JOIN scrape_target_types stt ON st.target_type_id = stt.id
      WHERE st.is_active = true
    `;
    
    const params = [];
    let paramCount = 1;
    
    if (filters.sourceSystem) {
      query += ` AND ss.name = $${paramCount}`;
      params.push(filters.sourceSystem);
      paramCount++;
    }
    
    if (filters.targetType) {
      query += ` AND stt.name = $${paramCount}`;
      params.push(filters.targetType);
      paramCount++;
    }
    
    if (filters.scraperType) {
      query += ` AND sct.name = $${paramCount}`;
      params.push(filters.scraperType);
      paramCount++;
    }
    
    query += ` ORDER BY st.source_system_id, st.target_type_id, st.id`;
    
    const result = await client.query(query, params);
    
    await client.end();
    return result.rows;
    
  } catch (error) {
    await client.end().catch(() => {});
    throw new Error(`Database connection failed: ${error.message}`);
  }
}

/**
 * Log scrape execution to database
 * @param {number} scrapeTargetId - ID of scrape target
 * @param {number} statusId - Status ID (1=pending, 2=running, 3=success, 4=partial, 5=failed)
 * @param {Object} data - Execution data
 * @returns {Promise<number>} Execution ID
 */
async function logScrapeExecution(scrapeTargetId, statusId, data = {}) {
  const client = new Client(dbConfig);
  
  try {
    await client.connect();
    
    const result = await client.query(`
      INSERT INTO scrape_executions (
        scrape_target_id,
        status_id,
        started_at,
        completed_at,
        duration_ms,
        entities_created,
        entities_updated,
        error_message,
        metadata
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING id
    `, [
      scrapeTargetId,
      statusId,
      data.started_at || new Date(),
      data.completed_at || null,
      data.duration_ms || null,
      data.entities_created || 0,
      data.entities_updated || 0,
      data.error_message || null,
      data.metadata ? JSON.stringify(data.metadata) : null
    ]);
    
    await client.end();
    return result.rows[0].id;
    
  } catch (error) {
    await client.end().catch(() => {});
    throw new Error(`Failed to log execution: ${error.message}`);
  }
}

/**
 * Update scrape execution status
 * @param {number} executionId - Execution ID to update
 * @param {number} statusId - New status ID
 * @param {Object} data - Additional data to update
 */
async function updateScrapeExecution(executionId, statusId, data = {}) {
  const client = new Client(dbConfig);
  
  try {
    await client.connect();
    
    const updates = ['status_id = $2'];
    const params = [executionId, statusId];
    let paramCount = 3;
    
    if (data.completed_at) {
      updates.push(`completed_at = $${paramCount}`);
      params.push(data.completed_at);
      paramCount++;
    }
    
    if (data.duration_ms !== undefined) {
      updates.push(`duration_ms = $${paramCount}`);
      params.push(data.duration_ms);
      paramCount++;
    }
    
    if (data.entities_created !== undefined) {
      updates.push(`entities_created = $${paramCount}`);
      params.push(data.entities_created);
      paramCount++;
    }
    
    if (data.entities_updated !== undefined) {
      updates.push(`entities_updated = $${paramCount}`);
      params.push(data.entities_updated);
      paramCount++;
    }
    
    if (data.error_message) {
      updates.push(`error_message = $${paramCount}`);
      params.push(data.error_message);
      paramCount++;
    }
    
    if (data.metadata) {
      updates.push(`metadata = $${paramCount}`);
      params.push(JSON.stringify(data.metadata));
      paramCount++;
    }
    
    await client.query(`
      UPDATE scrape_executions 
      SET ${updates.join(', ')}
      WHERE id = $1
    `, params);
    
    await client.end();
    
  } catch (error) {
    await client.end().catch(() => {});
    throw new Error(`Failed to update execution: ${error.message}`);
  }
}

module.exports = {
  getScrapeTargets,
  logScrapeExecution,
  updateScrapeExecution
};
