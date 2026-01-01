const NameNormalizer = require('./NameNormalizer');

/**
 * ClubManager - Manages club entities with intelligent matching
 * 
 * Purpose:
 * - Find clubs by fuzzy name matching
 * - Auto-create clubs when needed
 * - Handle club normalization
 */
class ClubManager {
    constructor(registry, logger) {
        this.registry = registry;
        this.logger = logger || console;
        this.normalizer = new NameNormalizer();
    }
    
    /**
     * Find an existing club by team name
     * Uses fuzzy matching to handle variations
     * 
     * @param {string} teamName - Name of the team
     * @returns {Object|null} Club entity or null
     */
    findClubByTeamName(teamName) {
        if (!teamName) return null;
        
        const allClubs = this.registry.getAllClubs();
        const clubNames = allClubs.map(c => c.display_name);
        
        // Try to find best match
        const matchedName = this.normalizer.findBestMatch(teamName, clubNames);
        
        if (matchedName) {
            const club = this.registry.getClubByName(matchedName);
            if (club) {
                this.logger.log(`   ✓ Matched team "${teamName}" to club "${club.display_name}" (ID: ${club.id})`);
                return club;
            }
        }
        
        return null;
    }
    
    /**
     * Create a new club from team information
     * 
     * @param {string} teamName - Name of the team
     * @param {number} sourceSystemId - Source system ID
     * @returns {Object} New club entity
     */
    createClubFromTeam(teamName, sourceSystemId) {
        if (!teamName) {
            throw new Error('Team name is required to create club');
        }
        
        // Get core name for club (strip FC, United, etc.)
        const coreName = this.normalizer.getCoreName(teamName);
        const clubDisplayName = coreName
            .split(' ')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ');
        
        // Generate slug from core name
        const slug = coreName.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
        
        const club = {
            display_name: clubDisplayName,
            slug: slug,
            source_system_id: sourceSystemId,
            is_active: true
        };
        
        this.registry.addClub(club);
        
        this.logger.log(`   ✓ Created new club: "${club.display_name}" (ID: ${club.id})`);
        
        return club;
    }
    
    /**
     * Find or create a club for a team
     * 
     * @param {string} teamName - Name of the team
     * @param {number} sourceSystemId - Source system ID
     * @returns {Object} Club entity (existing or new)
     */
    findOrCreateClub(teamName, sourceSystemId) {
        if (!teamName) return null;
        
        // Try to find existing club first
        let club = this.findClubByTeamName(teamName);
        
        if (!club) {
            // Create new club
            club = this.createClubFromTeam(teamName, sourceSystemId);
        }
        
        return club;
    }
    
    /**
     * Bulk import clubs from array
     * 
     * @param {Array<Object>} clubs - Array of club objects
     */
    importClubs(clubs) {
        for (const club of clubs) {
            this.registry.addClub(club);
        }
        this.logger.log(`   ✓ Imported ${clubs.length} clubs`);
    }
}

module.exports = ClubManager;
