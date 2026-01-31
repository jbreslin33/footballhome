const LeagueCurator = require('../../infrastructure/curation/LeagueCurator');

/**
 * CSL-Specific Curation Rules
 * 
 * CSL has many club variants (e.g., "Central Park Rangers" with 10+ teams)
 * This curator merges CSL entities into existing APSL entities.
 */
class CslCurator extends LeagueCurator {
  constructor(pool) {
    super(pool, 3, 'CSL'); // source_system_id = 3
  }

  /**
   * CSL-specific: Handle Central Park Rangers family
   */
  shouldMergeClubs(club1, club2) {
    // Check for same club family
    const family1 = this.getClubFamily(club1.name);
    const family2 = this.getClubFamily(club2.name);
    
    if (family1 && family2 && family1 === family2) {
      return true;
    }
    
    return super.shouldMergeClubs(club1, club2);
  }

  /**
   * Identify club families (variants of same club)
   */
  getClubFamily(clubName) {
    const name = clubName.toLowerCase();
    
    if (name.includes('central park rangers')) return 'central-park-rangers';
    if (name.includes('manhattan celtic')) return 'manhattan-celtic';
    if (name.includes('manhattan kickers')) return 'manhattan-kickers';
    if (name.includes('sporting astoria')) return 'sporting-astoria';
    if (name.includes('zum schneider')) return 'zum-schneider';
    if (name.includes('hoboken fc')) return 'hoboken-fc';
    if (name.includes('polonia')) return 'polonia';
    
    return null;
  }

  /**
   * Don't merge reserve teams
   */
  isReserveTeam(name) {
    return /\s+(II|III|IV|Reserve|Reserves|Old Boys|Legends|Masters|Dawgz)$/i.test(name);
  }
}

module.exports = CslCurator;
