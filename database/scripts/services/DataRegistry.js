/**
 * DataRegistry - Central registry for all scraped entities
 * 
 * Purpose: Maintain normalized indexes and lookups for:
 * - Clubs
 * - Sport Divisions
 * - Teams
 * - Players
 * - Matches
 * - Venues
 * 
 * Provides fast lookup by various keys (ID, name, external_id)
 */
class DataRegistry {
    constructor() {
        // Primary data stores (Map<id, entity>)
        this.clubs = new Map();
        this.sportDivisions = new Map();
        this.teams = new Map();
        this.players = new Map();
        this.matches = new Map();
        this.venues = new Map();
        
        // Lookup indexes for fast searching
        this.clubsByName = new Map();
        this.clubsByExternalId = new Map();
        
        this.sportDivisionsByName = new Map();
        this.sportDivisionsByClubAndName = new Map();
        
        this.teamsByName = new Map();
        this.teamsByExternalId = new Map();
        
        this.playersByName = new Map();
        this.playersByExternalId = new Map();
        
        this.venuesByName = new Map();
        this.venuesByExternalId = new Map();
        
        // Sequence counters for auto-incrementing IDs
        this.sequences = {
            club: 1,
            sportDivision: 1,
            team: 1,
            player: 1,
            match: 1,
            venue: 1
        };
    }
    
    // ==================== CLUBS ====================
    
    addClub(club) {
        if (!club.id) {
            club.id = this.sequences.club++;
        } else {
            this.sequences.club = Math.max(this.sequences.club, club.id + 1);
        }
        
        this.clubs.set(club.id, club);
        
        if (club.display_name) {
            this.clubsByName.set(club.display_name.toLowerCase(), club);
        }
        if (club.external_id) {
            this.clubsByExternalId.set(club.external_id, club);
        }
        
        return club;
    }
    
    getClubById(id) {
        return this.clubs.get(id);
    }
    
    getClubByName(name) {
        return this.clubsByName.get(name.toLowerCase());
    }
    
    getClubByExternalId(externalId) {
        return this.clubsByExternalId.get(externalId);
    }
    
    getAllClubs() {
        return Array.from(this.clubs.values());
    }
    
    // ==================== SPORT DIVISIONS ====================
    
    addSportDivision(sportDivision) {
        if (!sportDivision.id) {
            sportDivision.id = this.sequences.sportDivision++;
        } else {
            this.sequences.sportDivision = Math.max(this.sequences.sportDivision, sportDivision.id + 1);
        }
        
        this.sportDivisions.set(sportDivision.id, sportDivision);
        
        if (sportDivision.display_name) {
            this.sportDivisionsByName.set(sportDivision.display_name.toLowerCase(), sportDivision);
        }
        
        if (sportDivision.club_id && sportDivision.display_name) {
            const key = `${sportDivision.club_id}:${sportDivision.display_name.toLowerCase()}`;
            this.sportDivisionsByClubAndName.set(key, sportDivision);
        }
        
        return sportDivision;
    }
    
    getSportDivisionById(id) {
        return this.sportDivisions.get(id);
    }
    
    getSportDivisionByName(name) {
        return this.sportDivisionsByName.get(name.toLowerCase());
    }
    
    getSportDivisionByClubAndName(clubId, name) {
        const key = `${clubId}:${name.toLowerCase()}`;
        return this.sportDivisionsByClubAndName.get(key);
    }
    
    getSportDivisionsByClub(clubId) {
        return Array.from(this.sportDivisions.values())
            .filter(sd => sd.club_id === clubId);
    }
    
    getAllSportDivisions() {
        return Array.from(this.sportDivisions.values());
    }
    
    // ==================== TEAMS ====================
    
    addTeam(team) {
        if (!team.id) {
            team.id = this.sequences.team++;
        } else {
            this.sequences.team = Math.max(this.sequences.team, team.id + 1);
        }
        
        this.teams.set(team.id, team);
        
        if (team.name) {
            this.teamsByName.set(team.name.toLowerCase(), team);
        }
        if (team.external_id) {
            this.teamsByExternalId.set(team.external_id, team);
        }
        
        return team;
    }
    
    getTeamById(id) {
        return this.teams.get(id);
    }
    
    getTeamByName(name) {
        return this.teamsByName.get(name.toLowerCase());
    }
    
    getTeamByExternalId(externalId) {
        return this.teamsByExternalId.get(externalId);
    }
    
    getAllTeams() {
        return Array.from(this.teams.values());
    }
    
    // ==================== PLAYERS ====================
    
    addPlayer(player) {
        if (!player.id) {
            player.id = this.sequences.player++;
        } else {
            this.sequences.player = Math.max(this.sequences.player, player.id + 1);
        }
        
        this.players.set(player.id, player);
        
        const fullName = `${player.first_name} ${player.last_name}`.toLowerCase();
        this.playersByName.set(fullName, player);
        
        if (player.external_id) {
            this.playersByExternalId.set(player.external_id, player);
        }
        
        return player;
    }
    
    getPlayerById(id) {
        return this.players.get(id);
    }
    
    getPlayerByName(firstName, lastName) {
        const fullName = `${firstName} ${lastName}`.toLowerCase();
        return this.playersByName.get(fullName);
    }
    
    getPlayerByExternalId(externalId) {
        return this.playersByExternalId.get(externalId);
    }
    
    getAllPlayers() {
        return Array.from(this.players.values());
    }
    
    // ==================== MATCHES ====================
    
    addMatch(match) {
        if (!match.id) {
            match.id = this.sequences.match++;
        } else {
            this.sequences.match = Math.max(this.sequences.match, match.id + 1);
        }
        
        this.matches.set(match.id, match);
        return match;
    }
    
    getMatchById(id) {
        return this.matches.get(id);
    }
    
    getAllMatches() {
        return Array.from(this.matches.values());
    }
    
    // ==================== VENUES ====================
    
    addVenue(venue) {
        if (!venue.id) {
            venue.id = this.sequences.venue++;
        } else {
            this.sequences.venue = Math.max(this.sequences.venue, venue.id + 1);
        }
        
        this.venues.set(venue.id, venue);
        
        if (venue.name) {
            this.venuesByName.set(venue.name.toLowerCase(), venue);
        }
        if (venue.external_id) {
            this.venuesByExternalId.set(venue.external_id, venue);
        }
        
        return venue;
    }
    
    getVenueById(id) {
        return this.venues.get(id);
    }
    
    getVenueByName(name) {
        return this.venuesByName.get(name.toLowerCase());
    }
    
    getVenueByExternalId(externalId) {
        return this.venuesByExternalId.get(externalId);
    }
    
    getAllVenues() {
        return Array.from(this.venues.values());
    }
    
    // ==================== UTILITIES ====================
    
    /**
     * Get statistics about the registry
     */
    getStats() {
        return {
            clubs: this.clubs.size,
            sportDivisions: this.sportDivisions.size,
            teams: this.teams.size,
            players: this.players.size,
            matches: this.matches.size,
            venues: this.venues.size
        };
    }
    
    /**
     * Clear all data (useful for testing)
     */
    clear() {
        this.clubs.clear();
        this.sportDivisions.clear();
        this.teams.clear();
        this.players.clear();
        this.matches.clear();
        this.venues.clear();
        
        this.clubsByName.clear();
        this.clubsByExternalId.clear();
        this.sportDivisionsByName.clear();
        this.sportDivisionsByClubAndName.clear();
        this.teamsByName.clear();
        this.teamsByExternalId.clear();
        this.playersByName.clear();
        this.playersByExternalId.clear();
        this.venuesByName.clear();
        this.venuesByExternalId.clear();
        
        this.sequences = {
            club: 1,
            sportDivision: 1,
            team: 1,
            player: 1,
            match: 1,
            venue: 1
        };
    }
}

module.exports = DataRegistry;
