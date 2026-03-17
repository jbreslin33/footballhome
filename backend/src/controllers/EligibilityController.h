#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"
#include <memory>
#include <vector>
#include <string>

// Represents the resolved eligibility policy for a given scope
struct EligibilityPolicy {
    int id;
    int lookback_count;
    int min_sessions_to_start;
    int priority_starter_sessions;
    int priority_starter_slots;
    bool game_counts_as_session;
    bool pickup_counts_as_session;
    int family_discount;
};

// Eligibility status categories
enum class EligibilityStatus {
    PRIORITY_STARTER,   // Met priority_starter_sessions threshold
    ELIGIBLE_STARTER,   // Met min_sessions_to_start threshold
    BENCH_ONLY,         // Some attendance but below starter threshold
    INELIGIBLE          // Zero attendance or below minimum
};

// Per-player eligibility result
struct PlayerEligibility {
    int player_id;
    std::string first_name;
    std::string last_name;
    std::string jersey_number;
    std::string position;
    std::string photo_url;
    bool has_family_discount;
    int sessions_in_window;
    int sessions_attended;
    int projected_sessions;        // sessions_attended + future RSVP "yes" count
    int effective_min_sessions;    // After family discount
    EligibilityStatus status;
    EligibilityStatus projected_status;  // Status if player attends future RSVP'd sessions
    std::string match_rsvp;       // "yes", "no", "maybe", or ""
    bool on_lineup;
    bool is_starter;
    bool on_official_roster;       // true if on the specific team's league roster
    int person_id;
};

class EligibilityController : public Controller {
private:
    Database* db_;

public:
    EligibilityController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    // Eligibility computation
    Response handleGetMatchEligibility(const Request& request);
    
    // Policy management
    Response handleGetTeamPolicy(const Request& request);
    Response handleUpdateTeamPolicy(const Request& request);
    
    // Lineup management
    Response handleGetMatchLineup(const Request& request);
    Response handleSaveMatchLineup(const Request& request);
    Response handleGetLineupMetadata(const Request& request);
    Response handleSaveLineupMetadata(const Request& request);
    
    // Player attendance
    Response handleGetPlayerAttendance(const Request& request);
    Response handleUpdatePlayerAttendance(const Request& request);
    
    // Helper: resolve cascading policy
    EligibilityPolicy resolvePolicy(const std::string& matchId, 
                                     const std::string& teamId, 
                                     const std::string& clubId);
    
    // Helper: get recent session IDs in lookback window
    std::vector<int> getRecentSessionIds(const std::string& teamId, 
                                          const std::string& clubId,
                                          const std::string& matchDate, 
                                          int lookbackCount,
                                          bool gameCountsAsSession,
                                          bool pickupCountsAsSession);
    
    // Helper: classify eligibility
    EligibilityStatus classifyEligibility(int sessionsAttended, 
                                           int effectiveMinSessions,
                                           int priorityStarterSessions);
    
    // Helper: status to string
    std::string statusToString(EligibilityStatus status);
    
    // Path/JSON helpers
    std::string extractIdFromPath(const std::string& path, const std::string& pattern);
    std::string extractUserIdFromToken(const Request& request);
    std::string parseJsonString(const std::string& body, const std::string& key);
    int parseJsonInt(const std::string& body, const std::string& key, int defaultValue = 0);
    bool parseJsonBool(const std::string& body, const std::string& key, bool defaultValue = false);
    std::string createJsonResponse(bool success, const std::string& message, const std::string& data = "");
    std::string escapeJson(const std::string& str);
};
