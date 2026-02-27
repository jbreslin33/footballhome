/**
 * LeagueSnapshot
 * 
 * Universal JSON schema for league data. Every league's scraper/parser
 * produces one of these. The diff engine compares two snapshots.
 * The SQL appender converts diffs into SQL statements.
 * 
 * Flow:
 *   Scraper → HTML/JSON → Parser → LeagueSnapshot → Diff → SQL
 * 
 * This is the universal interchange format between scraping and SQL generation.
 */
class LeagueSnapshot {
  /**
   * @param {Object} options
   * @param {string} options.league - League slug (e.g., 'casa', 'apsl', 'csl')
   * @param {string} options.season - Season name (e.g., '2025/2026')
   * @param {number} options.sourceSystemId - Source system FK
   * @param {string} options.scrapedAt - ISO timestamp of when data was scraped
   */
  constructor({ league, season, sourceSystemId, scrapedAt }) {
    this.league = league;
    this.season = season;
    this.sourceSystemId = sourceSystemId;
    this.scrapedAt = scrapedAt || new Date().toISOString();

    /** @type {SnapshotTeam[]} */
    this.teams = [];

    /** @type {SnapshotMatch[]} */
    this.matches = [];

    /** @type {SnapshotStanding[]} */
    this.standings = [];

    /** @type {SnapshotPlayer[]} */
    this.players = [];
  }

  /**
   * Add a team to the snapshot
   * @param {Object} team
   * @param {string} team.name - Display name (e.g., "Lighthouse Boys Club")
   * @param {string} team.divisionName - Division name (e.g., "Philadelphia Liga 1")
   * @param {string} team.divisionExternalId - Division external ID (e.g., "9090889")
   * @param {string} [team.externalId] - Team external ID from source system
   */
  addTeam({ name, divisionName, divisionExternalId, externalId }) {
    this.teams.push({
      name,
      divisionName,
      divisionExternalId,
      externalId: externalId || `${divisionExternalId}-${name.toLowerCase().replace(/\s+/g, '-')}`,
      // Natural key for diffing: divisionName + name
      _key: `${divisionName}::${name}`
    });
  }

  /**
   * Add a match to the snapshot
   * @param {Object} match
   * @param {string} match.homeTeam - Home team name
   * @param {string} match.awayTeam - Away team name
   * @param {string} match.divisionName - Division this match belongs to
   * @param {string} match.divisionExternalId - Division external ID
   * @param {string} [match.date] - Match date (ISO, may be null for CASA)
   * @param {string} [match.time] - Match time string
   * @param {string} match.status - 'scheduled' | 'completed' | 'cancelled'
   * @param {number} [match.homeScore] - Home score (null if not played)
   * @param {number} [match.awayScore] - Away score (null if not played)
   * @param {string} [match.externalId] - Match external ID from source system
   */
  addMatch({ homeTeam, awayTeam, homeTeamExternalId, awayTeamExternalId, divisionName, divisionExternalId, date, time, status, homeScore, awayScore, externalId }) {
    const matchExternalId = externalId || `${divisionExternalId}_${homeTeam.toLowerCase().replace(/\s+/g, '-')}_${awayTeam.toLowerCase().replace(/\s+/g, '-')}`;
    this.matches.push({
      homeTeam,
      awayTeam,
      homeTeamExternalId: homeTeamExternalId || '',
      awayTeamExternalId: awayTeamExternalId || '',
      divisionName,
      divisionExternalId,
      date: date || null,
      time: time || null,
      status,
      homeScore: homeScore !== undefined ? homeScore : null,
      awayScore: awayScore !== undefined ? awayScore : null,
      externalId: matchExternalId,
      // Natural key for diffing: externalId (unique per source system)
      _key: matchExternalId
    });
  }

  /**
   * Add a standing to the snapshot
   * @param {Object} standing
   * @param {string} standing.teamName - Team name
   * @param {string} standing.divisionName - Division name
   * @param {number} standing.played
   * @param {number} standing.wins
   * @param {number} standing.draws
   * @param {number} standing.losses
   * @param {number} standing.goalsFor
   * @param {number} standing.goalsAgainst
   * @param {number} standing.goalDiff
   * @param {number} standing.points
   */
  addStanding({ teamName, divisionName, played, wins, draws, losses, goalsFor, goalsAgainst, goalDiff, points }) {
    this.standings.push({
      teamName,
      divisionName,
      played, wins, draws, losses,
      goalsFor, goalsAgainst, goalDiff, points,
      // Natural key for diffing: divisionName + teamName
      _key: `${divisionName}::${teamName}`
    });
  }

  /**
   * Add a player to the snapshot
   * @param {Object} player
   * @param {string} player.firstName
   * @param {string} player.lastName
   * @param {string} player.teamName - Team they belong to
   * @param {string} player.divisionName - Division context
   * @param {number} [player.jerseyNumber]
   * @param {string} [player.position]
   */
  addPlayer({ firstName, lastName, teamName, divisionName, jerseyNumber, position }) {
    this.players.push({
      firstName,
      lastName,
      teamName,
      divisionName,
      jerseyNumber: jerseyNumber || null,
      position: position || null,
      // Natural key for diffing: team + name
      _key: `${divisionName}::${teamName}::${lastName}::${firstName}`
    });
  }

  /**
   * Serialize to JSON for caching to disk
   */
  toJSON() {
    return {
      league: this.league,
      season: this.season,
      sourceSystemId: this.sourceSystemId,
      scrapedAt: this.scrapedAt,
      teams: this.teams,
      matches: this.matches,
      standings: this.standings,
      players: this.players
    };
  }

  /**
   * Save snapshot to disk
   * @param {string} filePath - Where to write (e.g., scraped-html/casa/snapshot.json)
   */
  save(filePath) {
    const fs = require('fs');
    const dir = require('path').dirname(filePath);
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(filePath, JSON.stringify(this.toJSON(), null, 2));
  }

  /**
   * Load snapshot from disk
   * @param {string} filePath
   * @returns {LeagueSnapshot}
   */
  static load(filePath) {
    const fs = require('fs');
    const data = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
    const snapshot = new LeagueSnapshot({
      league: data.league,
      season: data.season,
      sourceSystemId: data.sourceSystemId,
      scrapedAt: data.scrapedAt
    });
    snapshot.teams = data.teams || [];
    snapshot.matches = data.matches || [];
    snapshot.standings = data.standings || [];
    snapshot.players = data.players || [];
    return snapshot;
  }
}

module.exports = LeagueSnapshot;
