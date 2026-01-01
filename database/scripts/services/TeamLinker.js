/**
 * TeamLinker - Links teams to clubs via sport_divisions
 * 
 * Purpose:
 * - Process teams and auto-link to clubs
 * - Handle stub teams (no standings data)
 * - Coordinate between ClubManager and SportDivisionManager
 */
class TeamLinker {
    constructor(registry, clubManager, sportDivisionManager, logger) {
        this.registry = registry;
        this.clubManager = clubManager;
        this.sportDivisionManager = sportDivisionManager;
        this.logger = logger || console;
    }
    
    /**
     * Link a team to a club via sport_division
     * Creates club and sport_division if they don't exist
     * 
     * @param {Object} team - Team entity
     * @param {number} sourceSystemId - Source system ID
     * @param {string} leagueName - League name for context
     * @param {string} divisionName - Division name for context
     * @returns {Object} Updated team entity with sport_division_id
     */
    linkTeamToClub(team, sourceSystemId, leagueName = null, divisionName = null) {
        if (!team || !team.name) {
            this.logger.log(`   ⚠ Cannot link team without name`);
            return team;
        }
        
        // Skip if already linked
        if (team.sport_division_id) {
            this.logger.log(`   ✓ Team "${team.name}" already linked to sport_division ${team.sport_division_id}`);
            return team;
        }
        
        // Find or create club
        const club = this.clubManager.findOrCreateClub(team.name, sourceSystemId);
        
        if (!club) {
            this.logger.log(`   ⚠ Could not find or create club for team "${team.name}"`);
            return team;
        }
        
        // Find or create sport_division
        const sportDiv = this.sportDivisionManager.findOrCreateSportDivision(
            club.id,
            club.display_name,
            'soccer',
            leagueName,
            divisionName
        );
        
        if (!sportDiv) {
            this.logger.log(`   ⚠ Could not find or create sport_division for club ${club.id}`);
            return team;
        }
        
        // Link team to sport_division
        team.sport_division_id = sportDiv.id;
        
        this.logger.log(`   ✓ Linked team "${team.name}" → club "${club.display_name}" → sport_division ${sportDiv.id}`);
        
        return team;
    }
    
    /**
     * Process all teams in the registry and link to clubs
     * 
     * @param {number} sourceSystemId - Source system ID
     * @param {string} leagueName - League name for context
     * @param {string} divisionName - Division name for context (optional)
     */
    linkAllTeams(sourceSystemId, leagueName, divisionName = null) {
        const teams = this.registry.getAllTeams();
        let linkedCount = 0;
        let skippedCount = 0;
        
        this.logger.log(`\n📎 Linking ${teams.length} teams to clubs...`);
        
        for (const team of teams) {
            // Only process teams from this source system
            if (team.source_system_id !== sourceSystemId) {
                continue;
            }
            
            // Skip if already linked
            if (team.sport_division_id) {
                skippedCount++;
                continue;
            }
            
            this.linkTeamToClub(team, sourceSystemId, leagueName, divisionName);
            linkedCount++;
        }
        
        this.logger.log(`\n✓ Team linking complete: ${linkedCount} linked, ${skippedCount} already linked`);
    }
    
    /**
     * Link teams within a specific division
     * 
     * @param {Array<Object>} teams - Array of team entities
     * @param {number} sourceSystemId - Source system ID
     * @param {string} leagueName - League name
     * @param {string} divisionName - Division name
     */
    linkTeamsInDivision(teams, sourceSystemId, leagueName, divisionName) {
        if (!teams || teams.length === 0) return;
        
        this.logger.log(`\n📎 Linking ${teams.length} teams in ${divisionName}...`);
        
        for (const team of teams) {
            this.linkTeamToClub(team, sourceSystemId, leagueName, divisionName);
        }
    }
}

module.exports = TeamLinker;
