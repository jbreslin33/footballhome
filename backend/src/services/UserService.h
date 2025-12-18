#ifndef USERSERVICE_H
#define USERSERVICE_H

#include "../database/Database.h"
#include "../database/SqlFileLogger.h"
#include <string>
#include <vector>
#include <memory>

/**
 * UserService - Business logic for user management
 * 
 * Handles CRUD operations for users with permission-aware methods.
 * Can be used by SystemAdminController, ClubAdminController, etc.
 * 
 * Permission Levels:
 * - System Admin: Full access to all users
 * - Club Admin: Access to users within their club(s)
 * - Coach: Read-only access (NO profile editing)
 */
class UserService {
public:
    UserService(Database* db);
    
    // Read operations (available to all admin levels)
    struct UserDetails {
        std::string id;
        std::string first_name;
        std::string last_name;
        std::string email;
        std::string phone;
        std::string date_of_birth;
        bool is_active;
        std::string created_at;
        std::string updated_at;
    };
    
    UserDetails getUserById(const std::string& user_id);
    std::vector<UserDetails> getUsersByClub(const std::string& club_id);
    
    // Update operations (System Admin + Club Admin only)
    bool updateUserBasicInfo(const std::string& user_id, 
                             const std::string& first_name,
                             const std::string& last_name,
                             const std::string& email,
                             const std::string& phone,
                             const std::string& date_of_birth,
                             const std::string& admin_id);
    
    bool updateUserStatus(const std::string& user_id, 
                         bool is_active,
                         const std::string& admin_id);
    
    // Team associations (System Admin + Club Admin)
    struct TeamMembership {
        std::string team_id;
        std::string team_name;
        std::string sport_division_name;
        std::string jersey_number;
        std::string position_id;
        std::string position_name;
    };
    
    std::vector<TeamMembership> getUserTeams(const std::string& user_id);
    bool addUserToTeam(const std::string& user_id, 
                      const std::string& team_id,
                      const std::string& jersey_number,
                      const std::string& admin_id);
    bool removeUserFromTeam(const std::string& user_id,
                           const std::string& team_id,
                           const std::string& admin_id);
    
    // Permission checks
    bool canUserManageUser(const std::string& admin_id, 
                          const std::string& target_user_id,
                          const std::string& permission_level); // "system_admin", "club_admin", "coach"
    
private:
    Database* db_;
    
    void logAuditAction(const std::string& admin_id,
                       const std::string& action_type,
                       const std::string& entity_type,
                       const std::string& entity_id,
                       const std::string& description,
                       const std::string& old_values = "",
                       const std::string& new_values = "");
};

#endif // USERSERVICE_H
