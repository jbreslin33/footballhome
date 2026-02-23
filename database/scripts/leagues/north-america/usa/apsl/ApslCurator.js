const LeagueCurator = require('../../infrastructure/curation/LeagueCurator');

/**
 * APSL-Specific Curation Rules
 * 
 * APSL is the first league loaded, so this will be empty.
 * Future: Add rules for APSL-specific club structures.
 */
class ApslCurator extends LeagueCurator {
  constructor(pool) {
    super(pool, 1, 'APSL'); // source_system_id = 1
  }

  /**
   * APSL-specific: Don't merge reserve/II teams into parent
   */
  shouldMergeClubs(club1, club2) {
    if (this.isReserveTeam(club1.name) || this.isReserveTeam(club2.name)) {
      return false;
    }
    return super.shouldMergeClubs(club1, club2);
  }

  isReserveTeam(name) {
    return /\s+(II|III|Reserve|Reserves)$/i.test(name);
  }
}

module.exports = ApslCurator;
