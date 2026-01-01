/**
 * NameNormalizer - Handles team/club name normalization and fuzzy matching
 * 
 * Purpose: Convert team names to standardized forms for comparison
 * - Removes common suffixes (FC, United, SC, etc.)
 * - Handles spacing variations
 * - Generates matching variants
 */
class NameNormalizer {
    constructor() {
        // Common suffixes to strip for matching
        this.suffixes = [
            'fc', 'f.c.', 'sc', 's.c.',
            'united', 'utd',
            'soccer club', 'football club',
            'soccer', 'football',
            'club', 'team'
        ];
        
        // Roman numerals to strip
        this.romanNumerals = ['i', 'ii', 'iii', 'iv', 'v', 'vi', 'vii', 'viii', 'ix', 'x'];
        
        // Words to ignore when matching
        this.ignoreWords = ['the', 'de', 'del', 'la', 'los', 'las'];
    }
    
    /**
     * Normalize a name to its base form for comparison
     * @param {string} name - Original name
     * @returns {string} Normalized name
     */
    normalize(name) {
        if (!name) return '';
        
        let normalized = name.toLowerCase().trim();
        
        // Remove punctuation except hyphens and apostrophes
        normalized = normalized.replace(/[^\w\s\-']/g, ' ');
        
        // Remove multiple spaces
        normalized = normalized.replace(/\s+/g, ' ').trim();
        
        return normalized;
    }
    
    /**
     * Get the core name by stripping common suffixes and prefixes
     * @param {string} name - Original name
     * @returns {string} Core name
     */
    getCoreName(name) {
        let core = this.normalize(name);
        
        // Remove roman numerals at the end
        const words = core.split(' ');
        if (words.length > 1 && this.romanNumerals.includes(words[words.length - 1])) {
            words.pop();
            core = words.join(' ');
        }
        
        // Remove common suffixes
        for (const suffix of this.suffixes) {
            const pattern = new RegExp(`\\s+${suffix}$`, 'i');
            core = core.replace(pattern, '');
            
            // Also try removing from beginning
            const prefixPattern = new RegExp(`^${suffix}\\s+`, 'i');
            core = core.replace(prefixPattern, '');
        }
        
        // Remove ignore words
        const coreWords = core.split(' ').filter(word => !this.ignoreWords.includes(word));
        core = coreWords.join(' ');
        
        return core.trim();
    }
    
    /**
     * Generate all possible variants of a name for fuzzy matching
     * @param {string} name - Original name
     * @returns {Array<string>} Array of name variants
     */
    generateVariants(name) {
        const variants = new Set();
        const normalized = this.normalize(name);
        
        variants.add(normalized);
        variants.add(this.getCoreName(name));
        
        // Add version without spaces
        variants.add(normalized.replace(/\s+/g, ''));
        
        // Add version with hyphens instead of spaces
        variants.add(normalized.replace(/\s+/g, '-'));
        
        // Add acronym (first letter of each word)
        const words = normalized.split(' ');
        if (words.length > 1) {
            variants.add(words.map(w => w[0]).join(''));
        }
        
        // Add first word only (for "Lighthouse Boys Club" → "Lighthouse")
        if (words.length > 0 && words[0].length > 3) {
            variants.add(words[0]);
        }
        
        // Add first two words
        if (words.length > 1) {
            variants.add(words.slice(0, 2).join(' '));
        }
        
        // Remove numbers from variants for better matching
        const noNumbers = normalized.replace(/\d+/g, '').replace(/\s+/g, ' ').trim();
        if (noNumbers !== normalized) {
            variants.add(noNumbers);
            variants.add(this.getCoreName(noNumbers));
        }
        
        // Remove empty variants
        return Array.from(variants).filter(v => v && v.length > 0);
    }
    
    /**
     * Check if two names match using fuzzy logic
     * @param {string} name1 - First name
     * @param {string} name2 - Second name
     * @returns {boolean} True if names match
     */
    matches(name1, name2) {
        if (!name1 || !name2) return false;
        
        // Exact match
        const norm1 = this.normalize(name1);
        const norm2 = this.normalize(name2);
        if (norm1 === norm2) return true;
        
        // Core name match
        const core1 = this.getCoreName(name1);
        const core2 = this.getCoreName(name2);
        if (core1 && core2 && core1 === core2) return true;
        
        // Variant match
        const variants1 = this.generateVariants(name1);
        const variants2 = this.generateVariants(name2);
        
        for (const v1 of variants1) {
            for (const v2 of variants2) {
                if (v1 === v2 && v1.length >= 3) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    /**
     * Find the best matching name from a list
     * @param {string} targetName - Name to find
     * @param {Array<string>} nameList - List of possible matches
     * @returns {string|null} Best match or null
     */
    findBestMatch(targetName, nameList) {
        if (!targetName || !nameList || nameList.length === 0) return null;
        
        const targetCore = this.getCoreName(targetName);
        const targetVariants = this.generateVariants(targetName);
        
        // Try exact normalized match first
        const targetNorm = this.normalize(targetName);
        for (const name of nameList) {
            if (this.normalize(name) === targetNorm) {
                return name;
            }
        }
        
        // Try core name match
        for (const name of nameList) {
            const core = this.getCoreName(name);
            if (core && targetCore && core === targetCore) {
                return name;
            }
        }
        
        // Try variant match
        for (const name of nameList) {
            if (this.matches(targetName, name)) {
                return name;
            }
        }
        
        return null;
    }
}

module.exports = NameNormalizer;
