/**
 * Match Domain Model
 * 
 * Represents a soccer match between two teams
 */
class Match {
  constructor({
    id = null,
    matchTypeId,
    homeTeamId,
    awayTeamId,
    matchDate,
    matchTime = null,
    venueId = null,
    title = null,
    description = null,
    matchStatusId = 1, // Default: scheduled
    homeScore = null,
    awayScore = null,
    roundName = null,
    bracketPosition = null,
    nextMatchId = null,
    loserNextMatchId = null,
    seedHome = null,
    seedAway = null,
    sourceSystemId = null,
    externalId = null,
    createdByUserId = null,
    createdAt = null
  }) {
    this.id = id;
    this.matchTypeId = matchTypeId;
    this.homeTeamId = homeTeamId;
    this.awayTeamId = awayTeamId;
    this.matchDate = matchDate;
    this.matchTime = matchTime;
    this.venueId = venueId;
    this.title = title;
    this.description = description;
    this.matchStatusId = matchStatusId;
    this.homeScore = homeScore;
    this.awayScore = awayScore;
    this.roundName = roundName;
    this.bracketPosition = bracketPosition;
    this.nextMatchId = nextMatchId;
    this.loserNextMatchId = loserNextMatchId;
    this.seedHome = seedHome;
    this.seedAway = seedAway;
    this.sourceSystemId = sourceSystemId;
    this.externalId = externalId;
    this.createdByUserId = createdByUserId;
    this.createdAt = createdAt;
  }
  
  /**
   * Check if match is in the past
   */
  isPast() {
    const matchDateTime = new Date(this.matchDate);
    if (this.matchTime) {
      const [hours, minutes] = this.matchTime.split(':');
      matchDateTime.setHours(parseInt(hours), parseInt(minutes));
    }
    return matchDateTime < new Date();
  }
  
  /**
   * Get inferred match status based on date (fallback if no explicit status)
   */
  inferStatus() {
    if (this.homeScore !== null && this.awayScore !== null) {
      return 2; // completed
    }
    return this.isPast() ? 2 : 1; // completed : scheduled
  }
}

module.exports = Match;
