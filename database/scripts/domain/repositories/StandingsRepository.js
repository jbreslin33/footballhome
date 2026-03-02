/**
 * Standings Repository
 * All database operations for standings
 * 
 * Division/season are derived via team.division_id FK chain.
 * Standings are keyed by team_id (UNIQUE constraint).
 */
class StandingsRepository {
  constructor(db) {
    this.db = db;
  }
  
  /**
   * Upsert standings (insert or update by team_id)
   * @param {Object} standings - { teamId, position, played, wins, draws, losses, goalsFor, goalsAgainst, goalDiff, points, fetchedAt, source }
   */
  async upsert(standings) {
    const result = await this.db.query(`
      INSERT INTO standings (
        team_id, position, played, wins, draws, losses,
        goals_for, goals_against, goal_diff, points, fetched_at, source
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
      ON CONFLICT (team_id)
      DO UPDATE SET
        position = EXCLUDED.position,
        played = EXCLUDED.played,
        wins = EXCLUDED.wins,
        draws = EXCLUDED.draws,
        losses = EXCLUDED.losses,
        goals_for = EXCLUDED.goals_for,
        goals_against = EXCLUDED.goals_against,
        goal_diff = EXCLUDED.goal_diff,
        points = EXCLUDED.points,
        fetched_at = EXCLUDED.fetched_at,
        source = EXCLUDED.source,
        updated_at = CURRENT_TIMESTAMP
      RETURNING id
    `, [
      standings.teamId,
      standings.position,
      standings.played,
      standings.wins,
      standings.draws,
      standings.losses,
      standings.goalsFor,
      standings.goalsAgainst,
      standings.goalDiff,
      standings.points,
      standings.fetchedAt || new Date(),
      standings.source || 'APSL'
    ]);
    
    return result.rows[0].id;
  }
  
  /**
   * Upsert many standings records
   */
  async upsertMany(standingsArray) {
    let count = 0;
    
    for (const standings of standingsArray) {
      await this.upsert(standings);
      count++;
    }
    
    return { count };
  }
  
  /**
   * Find standings by division (via team.division_id)
   */
  async findByDivision(divisionId) {
    const result = await this.db.query(`
      SELECT s.*, t.name as team_name
      FROM standings s
      JOIN teams t ON s.team_id = t.id
      WHERE t.division_id = $1
      ORDER BY s.position
    `, [divisionId]);
    
    return result.rows;
  }
}

module.exports = StandingsRepository;
