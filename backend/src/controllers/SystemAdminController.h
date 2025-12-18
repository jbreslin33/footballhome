#ifndef SYSTEMADMINCONTROLLER_H
#define SYSTEMADMINCONTROLLER_H

#include "../core/Controller.h"
#include "../core/Router.h"
#include "../database/Database.h"
#include "../database/SqlFileLogger.h"
#include "../database/SqlBuilder.h"
#include "../services/UserService.h"
#include <memory>

class SystemAdminController : public Controller {
public:
    SystemAdminController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Database* db_;
    UserService* userService_;
    
    // Dashboard & Overview
    Response handleGetDashboard(const Request& request);
    Response handleGetSystemHealth(const Request& request);
    
    // System Settings
    Response handleGetSettings(const Request& request);
    Response handleGetSetting(const Request& request);
    Response handleUpdateSetting(const Request& request);
    
    // Feature Flags
    Response handleGetFeatureFlags(const Request& request);
    Response handleToggleFeatureFlag(const Request& request);
    
    // User Management
    Response handleGetAllUsers(const Request& request);
    Response handleGetUser(const Request& request);
    Response handleUpdateUser(const Request& request);
    Response handleUpdateUserStatus(const Request& request);
    Response handleGetUserTeams(const Request& request);
    Response handleAddUserToTeam(const Request& request);
    Response handleRemoveUserFromTeam(const Request& request);
    Response handleImpersonateUser(const Request& request);
    Response handleBulkUserOperation(const Request& request);
    
    // System Admins
    Response handleGetSystemAdmins(const Request& request);
    Response handleGrantSystemAdmin(const Request& request);
    Response handleRevokeSystemAdmin(const Request& request);
    
    // Audit Logs
    Response handleGetAuditLogs(const Request& request);
    Response handleGetApiUsageLogs(const Request& request);
    
    // Data Management
    Response handleGetImportJobs(const Request& request);
    Response handleCreateImportJob(const Request& request);
    Response handleGetScraperLogs(const Request& request);
    Response handleTriggerScraper(const Request& request);
    
    // System Notifications
    Response handleGetSystemNotifications(const Request& request);
    Response handleCreateSystemNotification(const Request& request);
    Response handleUpdateSystemNotification(const Request& request);
    Response handleDeleteSystemNotification(const Request& request);
    
    // Lookup Tables Management
    Response handleGetLookupTables(const Request& request);
    Response handleGetLookupTable(const Request& request);
    Response handleCreateLookupEntry(const Request& request);
    Response handleUpdateLookupEntry(const Request& request);
    Response handleDeleteLookupEntry(const Request& request);
    
    // Helper methods
    std::string extractIdFromPath(const std::string& path, const std::string& prefix);
    bool isSystemAdmin(const std::string& user_id);
    void logAuditAction(const std::string& admin_id, const std::string& action_type, 
                       const std::string& entity_type, const std::string& entity_id,
                       const std::string& description, const std::string& old_values = "",
                       const std::string& new_values = "");
};

#endif // SYSTEMADMINCONTROLLER_H
