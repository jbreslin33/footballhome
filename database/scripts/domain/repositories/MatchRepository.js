/**
 * Match Repository
 * 
 * Handles database operations for matches
 */
class MatchRepository {
  constructor(dbClient) {
    this.db = dbClient;
  }
  
  /**
   * Find match by ID
   */
  async findById(id) {
    const result = await this.db.query(`
      SELECT * FROM matches WHERE id = $1
    `, [id]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Find match by external ID and source system
   */
  async findByExternalId(sourceSystemId, externalId) {
    const result = await this.db.query(`
      SELECT * FROM matches
      WHERE source_system_id = $1 AND external_id = $2
    `, [sourceSystemId, externalId]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Find all matches for a team
   */
  async findByTeam(teamId) {
    const result = await this.db.query(`
      SELECT * FROM matches
      WHERE home_team_id = $1 OR away_team_id = $1
      ORDER BY match_date DESC, match_time DESC NULLS LAST
    `, [teamId]);
    
    return result.rows;
  }
  
  /**
   * Find all matches for a division
   */
  async findByDivision(divisionId) {
    const result = await this.db.query(`
      SELECT m.*
      FROM matches m
      JOIN match_divisions md ON m.id = md.match_id
      WHERE md.division_id = $1
      ORDER BY m.match_date DESC, m.match_time DESC NULLS LAST
    `, [divisionId]);
    
    return result.rows;
  }
  
  /**
   * Create a new match
   * @param {Match} match - Match domain model
   * @returns {Object} Created match record
   */
  async create(match) {
    const result = await this.db.query(`
      INSERT INTO matches (
        match_type_id, home_team_id, away_team_id, match_date, match_time,
        venue_id, title, description, match_status_id, home_score, away_score,
        round_name, bracket_position, next_match_id, loser_next_match_id,
        seed_home, seed_away, source_system_id, external_id,
        created_by_user_id
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20
      )
      RETURNING *
    `, [
      match.matchTypeId, match.homeTeamId, match.awayTeamId, match.matchDate, match.matchTime,
      match.venueId, match.title, match.description, match.matchStatusId, match.homeScore, match.awayScore,
      match.roundName, match.bracketPosition, match.nextMatchId, match.loserNextMatchId,
      match.seedHome, match.seedAway, match.sourceSystemId, match.externalId,
      match.createdByUserId
    ]);
    
    return result.rows[0];
  }
  
  /**
   * Update an existing match
   * @param {number} id - Match ID
   * @param {Match} match - Match domain model with updated values
   * @returns {Object} Updated match record
   */
  async update(id, match) {
    const result = await this.db.query(`
      UPDATE matches SET
        match_type_id = $1,
        home_team_id = $2,
        away_team_id = $3,
        match_date = $4,
        match_time = $5,
        venue_id = $6,
        title = $7,
        description = $8,
        match_status_id = $9,
        home_score = $10,
        away_score = $11,
        round_name = $12,
        bracket_position = $13,
        next_match_id = $14,
        loser_next_match_id = $15,
        seed_home = $16,
        seed_away = $17,
        source_system_id = $18,
        external_id = $19
      WHERE id = $20
      RETURNING *
    `, [
      match.matchTypeId, match.homeTeamId, match.awayTeamId, match.matchDate, match.matchTime,
      match.venueId, match.title, match.description, match.matchStatusId, match.homeScore, match.awayScore,
      match.roundName, match.bracketPosition, match.nextMatchId, match.loserNextMatchId,
      match.seedHome, match.seedAway, match.sourceSystemId, match.externalId,
      id
    ]);
    
    return result.rows[0];
  }
  
  /**
   * Upsert match (insert or update based on source_system_id + external_id)
   * @param {Match} match - Match domain model
   * @returns {Object} Upserted match record
   */
  async upsert(match) {
    // If has external_id, try to find existing
    if (match.sourceSystemId && match.externalId) {
      const existing = await this.findByExternalId(match.sourceSystemId, match.externalId);
      if (existing) {
        return await this.update(existing.id, match);
      }
    }
    
    return await this.create(match);
  }
  
  /**
   * Link match to a division
   */
  async linkToDivision(matchId, divisionId, countsForStandings = true) {
    const result = await this.db.query(`
      INSERT INTO match_divisions (match_id, division_id, counts_for_standings)
      VALUES ($1, $2, $3)
      ON CONFLICT (match_id, division_id)
      DO UPDATE SET counts_for_standings = EXCLUDED.counts_for_standings
      RETURNING *
    `, [matchId, divisionId, countsForStandings]);
    
    return result.rows[0];
  }
  
  /**
   * Delete a match
   */
  async delete(id) {
    const result = await this.db.query(`
      DELETE FROM matches
      WHERE id = $1
      RETURNING *
    `, [id]);
    
    return result.rows[0] || null;
  }
}

module.exports = MatchRepository;
