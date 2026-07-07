#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"
#include <memory>

class EventController : public Controller {
private:
    Database* db_;

public:
    EventController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleCreateEvent(const Request& request);
    Response handleGetEvents(const Request& request);
    Response handleGetMatches(const Request& request);
    Response handleGetEvent(const Request& request);
    Response handleGetVenues(const Request& request);
    Response handleUpdateEvent(const Request& request);
    Response handleDeleteEvent(const Request& request);
    Response handleCreateRSVP(const Request& request);
    Response handleGetEventRSVPs(const Request& request);
    
    // Match-specific endpoints
    Response handleCreateMatch(const Request& request);
    Response handleGetMatch(const Request& request);
    Response handleUpdateMatch(const Request& request);
    Response handleDeleteMatch(const Request& request);
    Response handleSyncLeague(const Request& request);

    // Practice-specific endpoints
    Response handleGetPractices(const Request& request);
    
    // Attendance endpoints
    Response handleGetEventAttendance(const Request& request);
    Response handleUpdateAttendance(const Request& request);
    Response handleGetAttendanceStatuses(const Request& request);
    
    // Game Day Roster endpoints
    Response handleGetGameRoster(const Request& request);
    Response handleUpdateGameRoster(const Request& request);
    Response handleAddToLineup(const Request& request);
    Response handleRemoveFromLineup(const Request& request);
    Response handleGetEligiblePlayers(const Request& request);

    // Visibility flags (gameday_hidden / lineup_hidden) for public views
    Response handleSetMatchVisibility(const Request& request);
    
    // Club Chat Events & RSVP Override
    Response handleGetClubChatEvents(const Request& request);
    Response handleOverrideRSVP(const Request& request);

    // Enriched roster player data + RSVP set
    Response handleGetRosterPlayers(const Request& request);
    Response handleSetPlayerRSVP(const Request& request);
    Response handleSetPracticeRSVP(const Request& request);

    // Compact RSVP + attendance counts for a single match — used by
    // Practice/Pickup Dashboard row badges.
    Response handleGetMatchRsvpSummary(const Request& request);

    // Aggregated upcoming events across all mens teams (for the Mens
    // Reminders admin screen).
    Response handleGetMensUpcomingEvents(const Request& request);
    
    // Helper methods
    std::string extractUserIdFromToken(const Request& request);
    std::string extractTeamIdFromPath(const std::string& path);
    std::string extractEventIdFromPath(const std::string& path);
    std::string extractMatchIdFromPath(const std::string& path);
    std::string extractAttendanceIdFromPath(const std::string& path);
    std::string parseJSON(const std::string& body, const std::string& key);
    std::string getCurrentTimestamp();
};
