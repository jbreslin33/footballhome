#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"
#include <curl/curl.h>
#include <memory>
#include <regex>
#include <atomic>
#include <thread>

class SocialController : public Controller {
private:
    Database* db_;

    // Path parameter extraction helpers
    std::string extractMatchIdFromPath(const std::string& path);
    std::string extractTeamIdFromPath(const std::string& path);
    std::string extractPostIdFromPath(const std::string& path);

public:
    SocialController();
    ~SocialController();
    void registerRoutes(Router& router, const std::string& prefix) override;

    // Scheduler for auto-publishing scheduled promo posts
    void startScheduler();
    void stopScheduler();

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

    // Promotional posts
    Response handleGetPromoPosts(const Request& request);
    Response handleSavePromoPost(const Request& request);
    Response handleUploadPromoMedia(const Request& request);
    Response handlePublishPromoPost(const Request& request);
    std::string extractPromoIdFromPath(const std::string& path);
    void ensurePromotionalPostsSchema();
    bool publishPromoById(const std::string& promoId, std::string& errorOut);

    // Content posts (user-uploaded media)
    Response handleGetContentPosts(const Request& request);
    Response handleSaveContentPost(const Request& request);
    Response handleUploadContentMedia(const Request& request);
    Response handlePublishContentPost(const Request& request);
    Response handleDeleteContentPost(const Request& request);
    std::string extractContentIdFromPath(const std::string& path);

    // Google Drive media browser
    Response handleListDriveMedia(const Request& request);
    Response handleDownloadDriveFile(const Request& request);
    std::string extractUserIdFromJWT(const Request& request);
    std::string getGoogleAccessToken(const std::string& userId);
    std::string refreshGoogleToken(const std::string& userId, const std::string& refreshToken);

    // Instagram Graph API helpers
    std::string httpPost(const std::string& url, const std::string& postData);
    std::string httpGet(const std::string& url);
    std::string urlEncode(CURL* curl, const std::string& value);

    // Scheduler internals
    std::atomic<bool> schedulerRunning_{false};
    std::thread schedulerThread_;
    void schedulerLoop();
    void checkScheduledPosts();

    // Utility
    std::string escapeJson(const std::string& input);
    std::string escapeSql(const std::string& input);
    std::string createJSONResponse(bool success, const std::string& message, const std::string& data = "");
};
