const LeagueCurator = require('../../infrastructure/curation/LeagueCurator');

/**
 * CASA-Specific Curation Rules
 * 
 * CASA has fewer teams but may have duplicates with APSL/CSL.
 */
class CasaCurator extends LeagueCurator {
  constructor(pool) {
    super(pool, 2, 'CASA'); // source_system_id = 2
  }

  /**
   * CASA-specific rules (if needed)
   */
  shouldMergeClubs(club1, club2) {
    // Don't merge "Select" teams
    if (club1.name.includes('Select') || club2.name.includes('Select')) {
      return false;
    }
    
    return super.shouldMergeClubs(club1, club2);
  }
}

module.exports = CasaCurator;
