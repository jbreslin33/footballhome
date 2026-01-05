/**
 * Player Repository
 * All database operations for players (sports role)
 */
class PlayerRepository {
  constructor(db) {
    this.db = db;
  }
  
  /**
   * Find player by person_id
   */
  async findByPersonId(personId) {
    const result = await this.db.query(`
      SELECT id, person_id, height_cm, nationality, photo_url, 
             source_system_id, external_id, created_at, updated_at
      FROM players
      WHERE person_id = $1
    `, [personId]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Find player by source_system_id and external_id
   */
  async findByExternalId(sourceSystemId, externalId) {
    const result = await this.db.query(`
      SELECT id, person_id, height_cm, nationality, photo_url, 
             source_system_id, external_id, created_at, updated_at
      FROM players
      WHERE source_system_id = $1 AND external_id = $2
    `, [sourceSystemId, externalId]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Upsert player (insert or update if exists)
   */
  async upsert(player) {
    // Try to find by external_id first (if provided)
    let existing = null;
    if (player.sourceSystemId && player.externalId) {
      existing = await this.findByExternalId(player.sourceSystemId, player.externalId);
    }
    
    // Fallback to person_id
    if (!existing && player.personId) {
      existing = await this.findByPersonId(player.personId);
    }
    
    if (existing) {
      // Update
      await this.db.query(`
        UPDATE players SET
          photo_url = COALESCE($1, photo_url),
          height_cm = COALESCE($2, height_cm),
          nationality = COALESCE($3, nationality),
          source_system_id = COALESCE($4, source_system_id),
          external_id = COALESCE($5, external_id),
          updated_at = CURRENT_TIMESTAMP
        WHERE id = $6
      `, [
        player.photoUrl, 
        player.heightCm, 
        player.nationality, 
        player.sourceSystemId, 
        player.externalId, 
        existing.id
      ]);
      
      return { id: existing.id, inserted: false };
    }
    
    // Insert new
    const result = await this.db.query(`
      INSERT INTO players (person_id, height_cm, nationality, photo_url, source_system_id, external_id)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id
    `, [
      player.personId, 
      player.heightCm || null, 
      player.nationality || null, 
      player.photoUrl || null, 
      player.sourceSystemId || null, 
      player.externalId || null
    ]);
    
    return { id: result.rows[0].id, inserted: true };
  }
}

module.exports = PlayerRepository;
