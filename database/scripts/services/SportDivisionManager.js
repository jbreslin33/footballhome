/**
 * SportDivisionManager - Manages sport_divisions (club + sport combinations)
 * 
 * Purpose:
 * - Find existing sport_divisions for a club
 * - Auto-create sport_divisions when needed
 * - Handle multiple sports per club (soccer, futsal, etc.)
 */
class SportDivisionManager {
    constructor(registry, logger) {
        this.registry = registry;
        this.logger = logger || console;
    }
    
    /**
     * Find an existing sport_division for a club
     * 
     * @param {number} clubId - Club ID
     * @param {string} sport - Sport name (default: 'soccer')
     * @returns {Object|null} SportDivision entity or null
     */
    findSportDivision(clubId, sport = 'soccer') {
        if (!clubId) return null;
        
        const divisions = this.registry.getSportDivisionsByClub(clubId);
        
        // Look for existing division with matching sport
        for (const div of divisions) {
            if (div.sport && div.sport.toLowerCase() === sport.toLowerCase()) {
                return div;
            }
        }
        
        // If only one division exists, return it regardless of sport
        if (divisions.length === 1) {
            return divisions[0];
        }
        
        return null;
    }
    
    /**
     * Create a new sport_division for a club
     * 
     * @param {number} clubId - Club ID
     * @param {string} clubDisplayName - Club display name
     * @param {string} sport - Sport name (default: 'soccer')
     * @param {string} leagueName - Optional league name to include
     * @param {string} divisionName - Optional division name to include
     * @returns {Object} New SportDivision entity
     */
    createSportDivision(clubId, clubDisplayName, sport = 'soccer', leagueName = null, divisionName = null) {
        if (!clubId || !clubDisplayName) {
            throw new Error('Club ID and display name are required to create sport division');
        }
        
        // Build display name
        let displayName = clubDisplayName;
        
        // Add league/division context if provided
        if (leagueName && divisionName) {
            displayName = `${clubDisplayName} (${leagueName} - ${divisionName})`;
        } else if (leagueName) {
            displayName = `${clubDisplayName} (${leagueName})`;
        } else if (divisionName) {
            displayName = `${clubDisplayName} (${divisionName})`;
        } else {
            // Default: just add sport
            displayName = `${clubDisplayName} Soccer`;
        }
        
        const sportDivision = {
            club_id: clubId,
            display_name: displayName,
            sport: sport,
            is_active: true
        };
        
        this.registry.addSportDivision(sportDivision);
        
        this.logger.log(`   ✓ Created sport_division: "${sportDivision.display_name}" (ID: ${sportDivision.id})`);
        
        return sportDivision;
    }
    
    /**
     * Find or create a sport_division for a club
     * 
     * @param {number} clubId - Club ID
     * @param {string} clubDisplayName - Club display name
     * @param {string} sport - Sport name (default: 'soccer')
     * @param {string} leagueName - Optional league name
     * @param {string} divisionName - Optional division name
     * @returns {Object} SportDivision entity (existing or new)
     */
    findOrCreateSportDivision(clubId, clubDisplayName, sport = 'soccer', leagueName = null, divisionName = null) {
        if (!clubId) return null;
        
        // Try to find existing sport_division first
        let sportDiv = this.findSportDivision(clubId, sport);
        
        if (!sportDiv) {
            // Create new sport_division
            sportDiv = this.createSportDivision(clubId, clubDisplayName, sport, leagueName, divisionName);
        }
        
        return sportDiv;
    }
    
    /**
     * Bulk import sport_divisions from array
     * 
     * @param {Array<Object>} sportDivisions - Array of sport_division objects
     */
    importSportDivisions(sportDivisions) {
        for (const sd of sportDivisions) {
            this.registry.addSportDivision(sd);
        }
        this.logger.log(`   ✓ Imported ${sportDivisions.length} sport_divisions`);
    }
}

module.exports = SportDivisionManager;
