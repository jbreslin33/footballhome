/**
 * Division Repository
 * All database operations for divisions
 */
class DivisionRepository {
  constructor(db) {
    this.db = db;
  }
  
  /**
   * Find division by external ID, source system, and season
   * Divisions are season-specific, so same external_id can exist across multiple seasons
   */
  async findByExternalId(sourceSystemId, externalId, seasonId = null) {
    if (seasonId) {
      const result = await this.db.query(`
        SELECT id, season_id, conference_id, name, division_type_id,
               skill_level, skill_label, source_system_id, external_id, sort_order
        FROM divisions
        WHERE source_system_id = $1 AND external_id = $2 AND season_id = $3
      `, [sourceSystemId, externalId, seasonId]);
      
      return result.rows[0] || null;
    } else {
      // Fallback for backward compatibility
      const result = await this.db.query(`
        SELECT id, season_id, conference_id, name, division_type_id,
               skill_level, skill_label, source_system_id, external_id, sort_order
        FROM divisions
        WHERE source_system_id = $1 AND external_id = $2
      `, [sourceSystemId, externalId]);
      
      return result.rows[0] || null;
    }
  }
  
  /**
   * Find divisions by conference
   */
  async findByConference(conferenceId) {
    const result = await this.db.query(`
      SELECT id, season_id, conference_id, name, division_type_id,
             skill_level, skill_label, source_system_id, external_id, sort_order
      FROM divisions
      WHERE conference_id = $1
      ORDER BY sort_order, name
    `, [conferenceId]);
    
    return result.rows;
  }
  
  /**
   * Find divisions by season
   */
  async findBySeason(seasonId) {
    const result = await this.db.query(`
      SELECT id, season_id, conference_id, name, division_type_id,
             skill_level, skill_label, source_system_id, external_id, sort_order
      FROM divisions
      WHERE season_id = $1
      ORDER BY sort_order, name
    `, [seasonId]);
    
    return result.rows;
  }
  
  /**
   * Find division by season and name
   */
  async findBySeasonAndName(seasonId, name) {
    const result = await this.db.query(`
      SELECT id, season_id, conference_id, name, division_type_id,
             skill_level, skill_label, source_system_id, external_id, sort_order
      FROM divisions
      WHERE season_id = $1 AND name = $2
    `, [seasonId, name]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Upsert division (insert or update if external_id exists for this season)
   */
  async upsert(division) {
    const row = division.toDbRow();
    
    // If has external_id, try update first (must match season too!)
    if (row.external_id && row.source_system_id && row.season_id) {
      const existing = await this.findByExternalId(row.source_system_id, row.external_id, row.season_id);
      
      if (existing) {
        const result = await this.db.query(`
          UPDATE divisions SET
            season_id = $1,
            conference_id = $2,
            name = $3,
            division_type_id = $4,
            skill_level = $5,
            skill_label = $6,
            sort_order = $7
          WHERE id = $8
          RETURNING id
        `, [
          row.season_id, row.conference_id, row.name, row.division_type_id,
          row.skill_level, row.skill_label, row.sort_order, existing.id
        ]);
        
        return { id: result.rows[0].id, inserted: false };
      }
    }
    
    // Insert new
    const result = await this.db.query(`
      INSERT INTO divisions (
        season_id, conference_id, name, division_type_id,
        skill_level, skill_label, source_system_id, external_id, sort_order
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING id
    `, [
      row.season_id, row.conference_id, row.name, row.division_type_id,
      row.skill_level, row.skill_label, row.source_system_id, 
      row.external_id, row.sort_order
    ]);
    
    return { id: result.rows[0].id, inserted: true };
  }
  
  /**
   * Batch upsert divisions
   */
  async upsertMany(divisions) {
    const results = { inserted: 0, updated: 0 };
    
    for (const division of divisions) {
      const result = await this.upsert(division);
      if (result.inserted) {
        results.inserted++;
      } else {
        results.updated++;
      }
    }
    
    return results;
  }
}

module.exports = DivisionRepository;
