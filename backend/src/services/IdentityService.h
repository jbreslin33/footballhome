#pragma once

#include "../database/Database.h"
#include "../database/SqlFileLogger.h"
#include <string>
#include <vector>
#include <map>

/**
 * IdentityService - Business logic for external identity management
 * 
 * Handles fetching, filtering, and linking of external identities (GroupMe, etc.)
 * to system users.
 */
class IdentityService {
public:
    IdentityService(Database* db);

    struct IdentityDTO {
        std::string id;
        std::string external_id;
        std::string external_username;
        std::string first_name;
        std::string last_name;
        std::string provider_id;
        std::string provider_name;
        std::string team_id;
        std::string team_name;
        std::string user_id;
        std::string user_first;
        std::string user_last;
        std::string user_email;
    };

    struct IdentityFilter {
        std::string team_id;
        std::string club_id;
        std::string provider_id;
        bool only_unlinked = false;
        bool only_linked = false;
    };

    /**
     * Get identities matching the specified filters
     */
    std::vector<IdentityDTO> getIdentities(const IdentityFilter& filter);

    /**
     * Link an external identity to a system user
     * @return true if successful
     */
    bool linkIdentity(const std::string& identity_id, const std::string& user_id, const std::string& admin_id);

    /**
     * Unlink an external identity
     * @return true if successful
     */
    bool unlinkIdentity(const std::string& identity_id, const std::string& admin_id);

    /**
     * Update the team association for an identity
     * @return true if successful
     */
    bool updateIdentityTeam(const std::string& identity_id, const std::string& team_id, const std::string& admin_id);

private:
    Database* db_;
    
    // Helper to safely extract string from DB result
    std::string safeStr(const pqxx::field& f);
};
