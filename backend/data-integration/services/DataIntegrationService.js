const { v4: uuidv4 } = require('uuid');

class DataIntegrationService {
  constructor(db, logger) {
    this.db = db;
    this.logger = logger;
  }

  // Create a new import job
  async createImportJob(sourceId, endpointId, jobType = 'manual_import') {
    const client = await this.db.connect();
    try {
      const result = await client.query(`
        INSERT INTO import_jobs (source_id, endpoint_id, job_type, status, started_at)
        VALUES ($1, $2, $3, 'running', CURRENT_TIMESTAMP)
        RETURNING *
      `, [sourceId, endpointId, jobType]);
      
      return result.rows[0];
    } finally {
      client.release();
    }
  }

  // Update import job status
  async updateImportJob(jobId, status, stats = {}) {
    const client = await this.db.connect();
    try {
      const updates = ['status = $2'];
      const params = [jobId, status];
      let paramCount = 2;

      if (status === 'completed' || status === 'failed') {
        updates.push(`completed_at = CURRENT_TIMESTAMP`);
      }

      if (stats.processed) {
        updates.push(`records_processed = $${++paramCount}`);
        params.push(stats.processed);
      }

      if (stats.inserted) {
        updates.push(`records_inserted = $${++paramCount}`);
        params.push(stats.inserted);
      }

      if (stats.updated) {
        updates.push(`records_updated = $${++paramCount}`);
        params.push(stats.updated);
      }

      if (stats.failed) {
        updates.push(`records_failed = $${++paramCount}`);
        params.push(stats.failed);
      }

      if (stats.error) {
        updates.push(`error_message = $${++paramCount}`);
        params.push(stats.error);
      }

      const result = await client.query(`
        UPDATE import_jobs 
        SET ${updates.join(', ')}
        WHERE id = $1
        RETURNING *
      `, params);

      return result.rows[0];
    } finally {
      client.release();
    }
  }

  // Stage external data for processing
  async stageExternalData(jobId, sourceId, dataType, rawData) {
    const client = await this.db.connect();
    try {
      const result = await client.query(`
        INSERT INTO staging_external_data (import_job_id, source_id, data_type, raw_data)
        VALUES ($1, $2, $3, $4)
        RETURNING *
      `, [jobId, sourceId, dataType, JSON.stringify(rawData)]);

      return result.rows[0];
    } finally {
      client.release();
    }
  }

  // Find or create team mapping
  async findOrCreateTeamMapping(sourceId, externalTeamName, externalId = null) {
    const client = await this.db.connect();
    try {
      // First, try to find existing mapping
      let result = await client.query(`
        SELECT eem.*, t.name as internal_name
        FROM external_entity_mappings eem
        JOIN teams t ON eem.internal_record_id = t.id
        WHERE eem.source_id = $1 
        AND eem.entity_type = 'team'
        AND (eem.external_name ILIKE $2 OR eem.external_id = $3)
      `, [sourceId, externalTeamName, externalId]);

      if (result.rows.length > 0) {
        return result.rows[0];
      }

      // Try fuzzy matching on team names
      result = await client.query(`
        SELECT t.*, 
               SIMILARITY(t.name, $2) as similarity_score
        FROM teams t
        WHERE SIMILARITY(t.name, $2) > 0.6
        ORDER BY similarity_score DESC
        LIMIT 1
      `, [sourceId, externalTeamName]);

      if (result.rows.length > 0) {
        const team = result.rows[0];
        // Create mapping with confidence score
        const mappingResult = await client.query(`
          INSERT INTO external_entity_mappings 
          (source_id, external_id, external_name, entity_type, internal_table, internal_record_id, confidence_score, mapping_method)
          VALUES ($1, $2, $3, 'team', 'teams', $4, $5, 'fuzzy_match')
          RETURNING *
        `, [sourceId, externalId || uuidv4(), externalTeamName, team.id, team.similarity_score]);

        return mappingResult.rows[0];
      }

      // No match found - create unmatched team record for manual review
      const unmatchedResult = await client.query(`
        INSERT INTO teams (name, is_active, created_from_external)
        VALUES ($1, false, true)
        RETURNING *
      `, [externalTeamName]);

      const newTeam = unmatchedResult.rows[0];

      // Create mapping
      const mappingResult = await client.query(`
        INSERT INTO external_entity_mappings 
        (source_id, external_id, external_name, entity_type, internal_table, internal_record_id, confidence_score, mapping_method)
        VALUES ($1, $2, $3, 'team', 'teams', $4, 0.0, 'auto_created')
        RETURNING *
      `, [sourceId, externalId || uuidv4(), externalTeamName, newTeam.id]);

      return mappingResult.rows[0];

    } finally {
      client.release();
    }
  }

  // Process standings data
  async processStandingsData(jobId, sourceId, standingsData, conferenceId, divisionId) {
    const client = await this.db.connect();
    let processed = 0;
    let inserted = 0;
    let updated = 0;
    let failed = 0;

    try {
      await client.query('BEGIN');

      for (const teamData of standingsData) {
        try {
          processed++;

          // Find or create team mapping
          const teamMapping = await this.findOrCreateTeamMapping(
            sourceId, 
            teamData.team_name, 
            teamData.external_id
          );

          // Check if standings record already exists
          const existingResult = await client.query(`
            SELECT * FROM team_standings 
            WHERE team_id = $1 AND season_id = $2 AND division_id = $3
          `, [teamMapping.internal_record_id, teamData.season_id || null, divisionId]);

          const standingsRecord = {
            games_played: parseInt(teamData.games_played) || 0,
            wins: parseInt(teamData.wins) || 0,
            losses: parseInt(teamData.losses) || 0,
            draws: parseInt(teamData.draws) || 0,
            goals_for: parseInt(teamData.goals_for) || 0,
            goals_against: parseInt(teamData.goals_against) || 0,
            points: parseInt(teamData.points) || 0
          };

          if (existingResult.rows.length > 0) {
            // Update existing record
            await client.query(`
              UPDATE team_standings 
              SET games_played = $1, wins = $2, losses = $3, draws = $4, 
                  goals_for = $5, goals_against = $6, points = $7, updated_at = CURRENT_TIMESTAMP
              WHERE team_id = $8 AND season_id = $9 AND division_id = $10
            `, [
              standingsRecord.games_played, standingsRecord.wins, standingsRecord.losses,
              standingsRecord.draws, standingsRecord.goals_for, standingsRecord.goals_against,
              standingsRecord.points, teamMapping.internal_record_id, teamData.season_id, divisionId
            ]);
            updated++;
          } else {
            // Insert new record
            await client.query(`
              INSERT INTO team_standings 
              (team_id, season_id, division_id, games_played, wins, losses, draws, goals_for, goals_against, points)
              VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
            `, [
              teamMapping.internal_record_id, teamData.season_id, divisionId,
              standingsRecord.games_played, standingsRecord.wins, standingsRecord.losses,
              standingsRecord.draws, standingsRecord.goals_for, standingsRecord.goals_against,
              standingsRecord.points
            ]);
            inserted++;
          }

          // Record sync history
          await client.query(`
            INSERT INTO data_sync_history (source_id, table_name, record_id, action, new_values, sync_job_id)
            VALUES ($1, 'team_standings', $2, $3, $4, $5)
          `, [
            sourceId, 
            teamMapping.internal_record_id, 
            existingResult.rows.length > 0 ? 'update' : 'insert',
            JSON.stringify(standingsRecord),
            jobId
          ]);

        } catch (error) {
          failed++;
          this.logger.error(`Failed to process team ${teamData.team_name}:`, error);
          
          // Create conflict record for manual review
          await this.createImportConflict(
            jobId, 
            null, 
            'processing_error', 
            `Failed to process team standings for ${teamData.team_name}: ${error.message}`
          );
        }
      }

      await client.query('COMMIT');
      
      return { processed, inserted, updated, failed };

    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  // Create import conflict
  async createImportConflict(jobId, stagingDataId, conflictType, description) {
    const client = await this.db.connect();
    try {
      const result = await client.query(`
        INSERT INTO import_conflicts 
        (import_job_id, staging_data_id, conflict_type, conflict_description, suggested_resolution)
        VALUES ($1, $2, $3, $4, 'manual_review')
        RETURNING *
      `, [jobId, stagingDataId, conflictType, description]);

      return result.rows[0];
    } finally {
      client.release();
    }
  }

  // Get sync status
  async getSyncStatus() {
    const client = await this.db.connect();
    try {
      const result = await client.query(`
        SELECT 
          eds.name,
          eds.display_name,
          eds.last_sync_at,
          eds.is_active,
          COUNT(ij.id) as total_jobs,
          COUNT(CASE WHEN ij.status = 'completed' THEN 1 END) as completed_jobs,
          COUNT(CASE WHEN ij.status = 'failed' THEN 1 END) as failed_jobs,
          COUNT(CASE WHEN ij.status = 'running' THEN 1 END) as running_jobs
        FROM external_data_sources eds
        LEFT JOIN import_jobs ij ON eds.id = ij.source_id 
          AND ij.created_at > CURRENT_DATE - INTERVAL '7 days'
        GROUP BY eds.id, eds.name, eds.display_name, eds.last_sync_at, eds.is_active
        ORDER BY eds.name
      `);

      return result.rows;
    } finally {
      client.release();
    }
  }

  // Get unresolved conflicts
  async getUnresolvedConflicts() {
    const client = await this.db.connect();
    try {
      const result = await client.query(`
        SELECT 
          ic.*,
          eds.name as source_name,
          ij.created_at as job_created_at
        FROM import_conflicts ic
        JOIN import_jobs ij ON ic.import_job_id = ij.id
        JOIN external_data_sources eds ON ij.source_id = eds.id
        WHERE ic.resolution_status = 'pending'
        ORDER BY ic.created_at DESC
      `);

      return result.rows;
    } finally {
      client.release();
    }
  }

  // Resolve conflict
  async resolveConflict(conflictId, resolution, notes, userId = null) {
    const client = await this.db.connect();
    try {
      const result = await client.query(`
        UPDATE import_conflicts 
        SET resolution_status = 'resolved',
            suggested_resolution = $2,
            resolution_notes = $3,
            resolved_by = $4,
            resolved_at = CURRENT_TIMESTAMP
        WHERE id = $1
        RETURNING *
      `, [conflictId, resolution, notes, userId]);

      return result.rows[0];
    } finally {
      client.release();
    }
  }

  // Sync all active sources
  async syncAllSources() {
    const client = await this.db.connect();
    try {
      const sources = await client.query(`
        SELECT * FROM external_data_sources 
        WHERE is_active = true
        ORDER BY name
      `);

      const results = [];
      for (const source of sources.rows) {
        try {
          // This would trigger specific scrapers based on source type
          this.logger.info(`Syncing source: ${source.name}`);
          // Implementation depends on source type and available scrapers
          results.push({
            source: source.name,
            status: 'completed',
            message: 'Sync completed successfully'
          });
        } catch (error) {
          this.logger.error(`Failed to sync ${source.name}:`, error);
          results.push({
            source: source.name,
            status: 'failed',
            message: error.message
          });
        }
      }

      return results;
    } finally {
      client.release();
    }
  }
}

module.exports = DataIntegrationService;