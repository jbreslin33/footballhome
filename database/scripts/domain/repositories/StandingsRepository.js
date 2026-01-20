/**
 * Standings Repository
 * All database operations for standings
 */
class StandingsRepository {
  constructor(db) {
    this.db = db;
  }
  
  /**
   * Upsert standings (insert or update if exists for competition/season/team)
   * @param {Object} standings - { competitionId, seasonId, teamId, position, played, wins, draws, losses, goalsFor, goalsAgainst, goalDiff, points, fetchedAt, source }
   */
  async upsert(standings) {
    const result = await this.db.query(`
      INSERT INTO standings (
        competition_id, season_id, team_id, position, played, wins, draws, losses,
        goals_for, goals_against, goal_diff, points, fetched_at, source
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
      ON CONFLICT (competition_id, season_id, team_id)
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
        source = EXCLUDED.source
      RETURNING id
    `, [
      standings.competitionId,
      standings.seasonId,
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
    let inserted = 0;
    let updated = 0;
    
    for (const standings of standingsArray) {
      await this.upsert(standings);
      inserted++; // Note: we can't easily distinguish insert vs update with ON CONFLICT
    }
    
    return { inserted, updated };
  }
  
  /**
   * Find standings by competition and season
   */
  async findByCompetitionSeason(competitionId, seasonId) {
    const result = await this.db.query(`
      SELECT s.*, t.name as team_name
      FROM standings s
      JOIN teams t ON s.team_id = t.id
      WHERE s.competition_id = $1 AND s.season_id = $2
      ORDER BY s.position
    `, [competitionId, seasonId]);
    
    return result.rows;
  }
  
  /**
   * Delete all standings for a competition/season (for full refresh)
   */
  async deleteByCompetitionSeason(competitionId, seasonId) {
    await this.db.query(`
      DELETE FROM standings
      WHERE competition_id = $1 AND season_id = $2
    `, [competitionId, seasonId]);
  }
}

module.exports = StandingsRepository;
