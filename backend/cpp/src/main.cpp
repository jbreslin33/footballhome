#include <drogon/drogon.h>
#include <json/json.h>
#include <iostream>

using namespace drogon;

int main() {
    // Database configuration
    std::string db_host = std::getenv("DATABASE_URL") ? std::getenv("DATABASE_URL") : "postgresql://footballapp:footballpass123@localhost:5432/footballhome";
    
    // Configure Drogon
    app().setLogLevel(trantor::Logger::kInfo);
    app().addListener("0.0.0.0", 8080);
    
    // Enable CORS for frontend
    app().registerPreRoutingAdvice([](const HttpRequestPtr &req) {
        return PreRoutingAdviceResult::kContinue;
    });
    
    app().registerPostRoutingAdvice([](const HttpRequestPtr &, const HttpResponsePtr &resp) {
        resp->addHeader("Access-Control-Allow-Origin", "*");
        resp->addHeader("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS");
        resp->addHeader("Access-Control-Allow-Headers", "Content-Type,Authorization");
    });

    // Health check endpoint
    app().registerHandler("/api/health",
        [](const HttpRequestPtr &req,
           std::function<void(const HttpResponsePtr &)> &&callback) {
            Json::Value response;
            response["status"] = "ok";
            response["service"] = "footballhome-api";
            response["version"] = "1.0.0";
            
            auto resp = HttpResponse::newHttpJsonResponse(response);
            callback(resp);
        },
        {Get});

    // Get all events for a team
    app().registerHandler("/api/teams/{team_id}/events",
        [](const HttpRequestPtr &req,
           std::function<void(const HttpResponsePtr &)> &&callback,
           const std::string &team_id) {
            
            Json::Value response;
            response["team_id"] = team_id;
            response["events"] = Json::Value(Json::arrayValue);
            
            // Sample event data for testing
            Json::Value event;
            event["id"] = "sample-event-1";
            event["title"] = "Training Session";
            event["event_type"] = "training";
            event["event_date"] = "2025-10-20T16:00:00Z";
            event["location"] = "Main Pitch";
            event["duration_minutes"] = 90;
            
            response["events"].append(event);
            
            auto resp = HttpResponse::newHttpJsonResponse(response);
            callback(resp);
        },
        {Get});

    // Create new event
    app().registerHandler("/api/events",
        [](const HttpRequestPtr &req,
           std::function<void(const HttpResponsePtr &)> &&callback) {
            
            if (req->getMethod() != Post) {
                auto resp = HttpResponse::newHttpResponse();
                resp->setStatusCode(k405MethodNotAllowed);
                callback(resp);
                return;
            }
            
            auto json = req->getJsonObject();
            if (!json) {
                auto resp = HttpResponse::newHttpResponse();
                resp->setStatusCode(k400BadRequest);
                callback(resp);
                return;
            }
            
            // TODO: Insert into database
            Json::Value response;
            response["id"] = "new-event-123";
            response["status"] = "created";
            response["message"] = "Event created successfully";
            
            auto resp = HttpResponse::newHttpJsonResponse(response);
            resp->setStatusCode(k201Created);
            callback(resp);
        },
        {Post, Options});

    // RSVP to event
    app().registerHandler("/api/events/{event_id}/rsvp",
        [](const HttpRequestPtr &req,
           std::function<void(const HttpResponsePtr &)> &&callback,
           const std::string &event_id) {
            
            if (req->getMethod() != Post) {
                auto resp = HttpResponse::newHttpResponse();
                resp->setStatusCode(k405MethodNotAllowed);
                callback(resp);
                return;
            }
            
            auto json = req->getJsonObject();
            if (!json) {
                auto resp = HttpResponse::newHttpResponse();
                resp->setStatusCode(k400BadRequest);
                callback(resp);
                return;
            }
            
            // TODO: Insert/update RSVP in database
            Json::Value response;
            response["event_id"] = event_id;
            response["status"] = "rsvp_updated";
            response["message"] = "RSVP submitted successfully";
            
            auto resp = HttpResponse::newHttpJsonResponse(response);
            callback(resp);
        },
        {Post, Options});

    std::cout << "Football Home API starting on port 8080..." << std::endl;
    
    // Start the application
    app().run();
    
    return 0;
}