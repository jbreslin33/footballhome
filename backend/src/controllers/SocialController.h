#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"
#include <memory>
#include <regex>

class SocialController : public Controller {
private:
    Database* db_;

    // Path parameter extraction helpers
    std::string extractMatchIdFromPath(const std::string& path);
    std::string extractTeamIdFromPath(const std::string& path);
    std::string extractPostIdFromPath(const std::string& path);

public:
    SocialController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    // Post types
    Response handleGetPostTypes(const Request& request);

    // Social posts CRUD
    Response handleGetMatchPosts(const Request& request);
    Response handleGetTeamCalendar(const Request& request);
    Response handleCreateOrUpdatePost(const Request& request);
    Response handleDeletePost(const Request& request);
    Response handlePostToInstagram(const Request& request);
    Response handleUploadMedia(const Request& request);

    // Schedule templates
    Response handleGetScheduleTemplates(const Request& request);
    Response handleSaveScheduleTemplates(const Request& request);

    // Apply schedule to a match (auto-generate posts with scheduled times)
    Response handleApplySchedule(const Request& request);

    // Holiday posts
    Response handleGetHolidayPosts(const Request& request);
    Response handleSaveHolidayPost(const Request& request);
    Response handleUploadHolidayMedia(const Request& request);
    Response handlePublishHolidayPost(const Request& request);
    std::string extractHolidayIdFromPath(const std::string& path);

    // Instagram Graph API helpers
    std::string httpPost(const std::string& url, const std::string& postData);

    // Utility
    std::string escapeJson(const std::string& input);
    std::string createJSONResponse(bool success, const std::string& message, const std::string& data = "");
};
