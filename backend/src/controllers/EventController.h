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
    
    // Attendance endpoints
    Response handleGetEventAttendance(const Request& request);
    Response handleUpdateAttendance(const Request& request);
    Response handleGetAttendanceStatuses(const Request& request);
    
    // Game Day Roster endpoints
    Response handleGetGameRoster(const Request& request);
    Response handleUpdateGameRoster(const Request& request);
    Response handleGetEligiblePlayers(const Request& request);
    
    // Helper methods
    std::string extractTeamIdFromPath(const std::string& path);
    std::string extractEventIdFromPath(const std::string& path);
    std::string extractAttendanceIdFromPath(const std::string& path);
    std::string createJSONResponse(bool success, const std::string& message, const std::string& data = "");
    std::string parseJSON(const std::string& body, const std::string& key);
    std::string getCurrentTimestamp();
    std::string escapeJSON(const std::string& str);
};
