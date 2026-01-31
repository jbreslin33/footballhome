const BaseCurator = require('./BaseCurator');

/**
 * League Curator - Compare new league against existing leagues
 * 
 * Finds duplicate clubs/orgs across leagues and generates merge SQL.
 * Extended by league-specific curators (ApslCurator, CslCurator, etc.)
 */
class LeagueCurator extends BaseCurator {
  constructor(pool, sourceSystemId, leagueName) {
    super(pool);
    this.sourceSystemId = sourceSystemId;
    this.leagueName = leagueName;
  }

  /**
   * Main curation process
   */
  async curate() {
    console.log(`\n🔍 Curating ${this.leagueName}...`);
    
    // Get entities from this league
    const newOrgs = await this.getNewOrganizations();
    const newClubs = await this.getNewClubs();
    
    // Get entities from existing leagues
    const existingOrgs = await this.getExistingOrganizations();
    const existingClubs = await this.getExistingClubs();
    
    console.log(`   New: ${newOrgs.length} orgs, ${newClubs.length} clubs`);
    console.log(`   Existing: ${existingOrgs.length} orgs, ${existingClubs.length} clubs`);
    
    // Find duplicates
    await this.findDuplicateOrganizations(newOrgs, existingOrgs);
    await this.findDuplicateClubs(newClubs, existingClubs);
    
    console.log(`   Generated: ${this.sqlStatements.length} merge statements`);
    
    return this.sqlStatements;
  }

  /**
   * Get organizations from this league
   */
  async getNewOrganizations() {
    return await this.query(`
      SELECT DISTINCT o.id, o.name, o.source_system_id
      FROM organizations o
      WHERE o.source_system_id = $1
      ORDER BY o.name
    `, [this.sourceSystemId]);
  }

  /**
   * Get organizations from other leagues
   */
  async getExistingOrganizations() {
    return await this.query(`
      SELECT DISTINCT o.id, o.name, o.source_system_id
      FROM organizations o
      WHERE o.source_system_id != $1
      ORDER BY o.name
    `, [this.sourceSystemId]);
  }

  /**
   * Get clubs from this league
   */
  async getNewClubs() {
    return await this.query(`
      SELECT c.id, c.name, c.organization_id, c.source_system_id
      FROM clubs c
      WHERE c.source_system_id = $1
      ORDER BY c.name
    `, [this.sourceSystemId]);
  }

  /**
   * Get clubs from other leagues
   */
  async getExistingClubs() {
    return await this.query(`
      SELECT c.id, c.name, c.organization_id, c.source_system_id
      FROM clubs c
      WHERE c.source_system_id != $1
      ORDER BY c.name
    `, [this.sourceSystemId]);
  }

  /**
   * Find duplicate organizations
   */
  async findDuplicateOrganizations(newOrgs, existingOrgs) {
    for (const newOrg of newOrgs) {
      for (const existingOrg of existingOrgs) {
        if (this.shouldMergeOrganizations(newOrg, existingOrg)) {
          this.mergeDuplicateOrganization(newOrg, existingOrg);
        }
      }
    }
  }

  /**
   * Find duplicate clubs
   */
  async findDuplicateClubs(newClubs, existingClubs) {
    for (const newClub of newClubs) {
      for (const existingClub of existingClubs) {
        if (this.shouldMergeClubs(newClub, existingClub)) {
          this.mergeDuplicateClub(newClub, existingClub);
        }
      }
    }
  }

  /**
   * Should these organizations be merged? (override in subclass)
   */
  shouldMergeOrganizations(org1, org2) {
    return this.fuzzyMatch(org1.name, org2.name);
  }

  /**
   * Should these clubs be merged? (override in subclass)
   */
  shouldMergeClubs(club1, club2) {
    return this.fuzzyMatch(club1.name, club2.name);
  }

  /**
   * Generate SQL to merge duplicate organization
   */
  mergeDuplicateOrganization(duplicate, canonical) {
    // Update clubs to point to canonical org
    this.addSql(
      `UPDATE clubs SET organization_id = ${canonical.id} WHERE organization_id = ${duplicate.id};`,
      `Merge "${duplicate.name}" → "${canonical.name}" (org ${canonical.id})`
    );
    
    // Delete duplicate org
    this.addSql(
      `DELETE FROM organizations WHERE id = ${duplicate.id};`,
      `Delete duplicate org "${duplicate.name}"`
    );
  }

  /**
   * Generate SQL to merge duplicate club
   */
  mergeDuplicateClub(duplicate, canonical) {
    // Update teams to point to canonical club
    this.addSql(
      `UPDATE teams SET club_id = ${canonical.id} WHERE club_id = ${duplicate.id};`,
      `Merge "${duplicate.name}" → "${canonical.name}" (club ${canonical.id})`
    );
    
    // Delete duplicate club
    this.addSql(
      `DELETE FROM clubs WHERE id = ${duplicate.id};`,
      `Delete duplicate club "${duplicate.name}"`
    );
  }
}

module.exports = LeagueCurator;
