#include <iostream>
#include <thread>
#include <chrono>
#include <algorithm>
#include <curl/curl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

#include "core/Router.h"
#include "core/Request.h"
#include "core/Response.h"
#include "core/TwilioSMSService.h"
#include "database/Database.h"
#include "database/SqlFileLogger.h"
#include "controllers/AuthController.h"
#include "controllers/OAuthController.h"
#include "controllers/TeamController.h"
#include "controllers/TeamCoachController.h"
#include "controllers/TeamRosterController.h"
#include "controllers/TeamReconciliationController.h"
#include "controllers/MagicLinkAuthController.h"
#include "controllers/EventRsvpController.h"
#include "controllers/PersonOverrideController.h"
#include "controllers/PersonMergeController.h"
#include "controllers/EventController.h"
#include "controllers/DivisionController.h"
#include "controllers/AvailabilityController.h"
#include "controllers/SystemAdminController.h"
#include "controllers/TacticalBoardController.h"
#include "controllers/StatsController.h"
#include "controllers/ClubController.h"
#include "controllers/ClubLaPoolController.h"
#include "controllers/YouthRosterController.h"
#include "controllers/MensRosterController.h"
#include "controllers/PersonBillingController.h"
#include "controllers/EligibilityController.h"
#include "controllers/GroupMeController.h"
#include "controllers/SocialController.h"
#include "controllers/InternalRosterController.h"
#include "controllers/PublicController.h"

class HttpServer {
private:
    int server_fd_;
    int port_;
    Router router_;
    Database* db_;
    
    // Controllers
    std::shared_ptr<AuthController> auth_controller_;
    std::shared_ptr<MagicLinkAuthController> magic_link_auth_controller_;
    std::shared_ptr<EventRsvpController> event_rsvp_controller_;
    std::shared_ptr<OAuthController> oauth_controller_;
    std::shared_ptr<TeamController> team_controller_;
    std::shared_ptr<TeamCoachController> team_coach_controller_;
    std::shared_ptr<TeamRosterController> team_roster_controller_;
    std::shared_ptr<TeamReconciliationController> team_reconciliation_controller_;
    std::shared_ptr<PersonOverrideController> person_override_controller_;
    std::shared_ptr<PersonMergeController> person_merge_controller_;
    std::shared_ptr<EventController> event_controller_;
    std::shared_ptr<DivisionController> division_controller_;
    std::shared_ptr<AvailabilityController> availability_controller_;
    std::shared_ptr<SystemAdminController> system_admin_controller_;
    std::shared_ptr<TacticalBoardController> tactical_board_controller_;
    std::shared_ptr<StatsController> stats_controller_;
    std::shared_ptr<ClubController> club_controller_;
    std::shared_ptr<ClubLaPoolController> club_la_pool_controller_;
    std::shared_ptr<YouthRosterController> youth_roster_controller_;
    std::shared_ptr<MensRosterController> mens_roster_controller_;
    std::shared_ptr<PersonBillingController> person_billing_controller_;
    std::shared_ptr<EligibilityController> eligibility_controller_;
    std::shared_ptr<GroupMeController> groupme_controller_;
    std::shared_ptr<SocialController> social_controller_;
    std::shared_ptr<InternalRosterController> internal_roster_controller_;
    std::shared_ptr<PublicController> public_controller_;

public:
    HttpServer(int port = 3001) : port_(port) {
        db_ = Database::getInstance();
        auth_controller_ = std::make_shared<AuthController>();
        magic_link_auth_controller_ = std::make_shared<MagicLinkAuthController>();
        event_rsvp_controller_ = std::make_shared<EventRsvpController>();
        oauth_controller_ = std::make_shared<OAuthController>();
        team_controller_ = std::make_shared<TeamController>();
        team_coach_controller_ = std::make_shared<TeamCoachController>();
        team_roster_controller_ = std::make_shared<TeamRosterController>();
        team_reconciliation_controller_ = std::make_shared<TeamReconciliationController>();
        person_override_controller_ = std::make_shared<PersonOverrideController>();
        person_merge_controller_ = std::make_shared<PersonMergeController>();
        event_controller_ = std::make_shared<EventController>();
        division_controller_ = std::make_shared<DivisionController>();
        availability_controller_ = std::make_shared<AvailabilityController>();
        system_admin_controller_ = std::make_shared<SystemAdminController>();
        tactical_board_controller_ = std::make_shared<TacticalBoardController>();
        stats_controller_ = std::make_shared<StatsController>();
        club_controller_ = std::make_shared<ClubController>();
        club_la_pool_controller_ = std::make_shared<ClubLaPoolController>();
        youth_roster_controller_ = std::make_shared<YouthRosterController>();
        mens_roster_controller_ = std::make_shared<MensRosterController>();
        person_billing_controller_ = std::make_shared<PersonBillingController>();
        eligibility_controller_ = std::make_shared<EligibilityController>();
        groupme_controller_ = std::make_shared<GroupMeController>();
        social_controller_ = std::make_shared<SocialController>();
        internal_roster_controller_ = std::make_shared<InternalRosterController>();
        public_controller_ = std::make_shared<PublicController>();
    }
    
    bool initialize() {
        std::cout << "🚀 Football Home Server Starting..." << std::endl;
        
        // Initialize SQL file logger
        SqlFileLogger::initialize();
        
        // Initialize Twilio SMS service
        const char* twilioSid = std::getenv("TWILIO_ACCOUNT_SID");
        const char* twilioToken = std::getenv("TWILIO_AUTH_TOKEN");
        const char* twilioPhone = std::getenv("TWILIO_FROM_PHONE");
        
        if (twilioSid && twilioToken && twilioPhone) {
            TwilioSMSService::getInstance().initialize(
                std::string(twilioSid),
                std::string(twilioToken),
                std::string(twilioPhone)
            );
        } else {
            std::cout << "⚠️  Twilio credentials not found - SMS disabled" << std::endl;
        }
        
        // Initialize database
        if (!db_->connect()) {
            std::cerr << "❌ Failed to connect to database" << std::endl;
            return false;
        }
        
        // Setup routes
        setupRoutes();
        
        // Start background schedulers
        social_controller_->startScheduler();
        
        // Create socket
        if (!createSocket()) {
            return false;
        }
        
        std::cout << "✅ Server initialized successfully on port " << port_ << std::endl;
        return true;
    }
    
    void run() {
        std::cout << "🎯 Server listening on http://localhost:" << port_ << std::endl;
        std::cout << "📋 Available endpoints:" << std::endl;
        router_.printRoutes();
        
        while (true) {
            handleClient();
        }
    }
    
    ~HttpServer() {
        if (server_fd_ >= 0) {
            close(server_fd_);
        }
        if (db_) {
            db_->disconnect();
        }
    }

private:
    void setupRoutes() {
        // Register controllers
        router_.useController("/api/auth/google", oauth_controller_);
        // Magic-link / cookie session controller registered BEFORE the
        // legacy AuthController so that /api/auth/me and /api/auth/logout
        // resolve to the FH-native cookie semantics (Phase 4) instead of
        // the older bearer/email-password handlers.  The legacy ones
        // (login, register, me/roles, user/teams, ...) stay reachable
        // because their paths don't collide.
        router_.useController("/api/auth", magic_link_auth_controller_);
        router_.useController("/api/auth", auth_controller_);
        router_.useController("/api/auth/google", oauth_controller_);
        router_.useController("/api/teams", team_controller_);
        router_.useController("/api/teams", team_coach_controller_);
        router_.useController("/api/teams", team_roster_controller_);
        router_.useController("/api/teams", team_reconciliation_controller_);
        router_.useController("/api/persons", person_override_controller_);
        router_.useController("/api/persons", person_merge_controller_);
        // FH-native cookie-authed event + RSVP surface registered
        // BEFORE the legacy EventController so /api/events/:chatEventId
        // resolves here (chat_events table) instead of the older
        // /api/events/:eventId handler (deprecated internal `events`
        // table).  Also owns /api/rsvp.  Phase 5.
        router_.useController("/api", event_rsvp_controller_);
        router_.useController("/api/events", event_controller_);
        router_.useController("/api", division_controller_);
        router_.useController("/api", availability_controller_);
        router_.useController("/api/system-admin", system_admin_controller_);
        router_.useController("/api/tactical-boards", tactical_board_controller_);
        router_.useController("/api/stats", stats_controller_);
        // FH-native LA-pool list registered BEFORE the generic ClubController
        // so /api/clubs/:clubId/la-pool resolves here (Phase 6) instead of
        // the more generic club-detail handler.
        router_.useController("/api/clubs", club_la_pool_controller_);
        router_.useController("/api/clubs", club_controller_);
        // Phase 7 — youth-roster ported to C++.  Registered with the exact
        // path as prefix so there's no trailing-slash mismatch.
        router_.useController("/api/youth-roster", youth_roster_controller_);
        // Phase 8 — mens-roster (GET + /assign + /roster-status) ported to C++.
        router_.useController("/api/mens-roster", mens_roster_controller_);
        // Phase 9 — person-billing (POST upsert + /mark-billed) ported to C++.
        router_.useController("/api/person-billing", person_billing_controller_);
        router_.useController("/api/eligibility", eligibility_controller_);
        router_.useController("/api/groupme", groupme_controller_);
        router_.useController("/api/social", social_controller_);
        router_.useController("/api/internal", internal_roster_controller_);
        router_.useController("/api/public", public_controller_);
        
        // Add basic health check endpoint
        router_.get("/health", [](const Request& request) {
            return Response::json("{\"status\":\"healthy\",\"service\":\"footballhome-backend\"}");
        });
        
        // Add root endpoint
        router_.get("/", [](const Request& request) {
            return Response::json("{\"message\":\"Football Home API Server\",\"version\":\"1.0\"}");
        });
        
        std::cout << "✅ Routes configured successfully" << std::endl;
    }
    
    bool createSocket() {
        // Create socket
        server_fd_ = socket(AF_INET, SOCK_STREAM, 0);
        if (server_fd_ < 0) {
            std::cerr << "❌ Socket creation failed" << std::endl;
            return false;
        }
        
        // Set socket options
        int opt = 1;
        if (setsockopt(server_fd_, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0) {
            std::cerr << "❌ setsockopt failed" << std::endl;
            return false;
        }
        
        // Bind socket
        struct sockaddr_in address;
        address.sin_family = AF_INET;
        address.sin_addr.s_addr = INADDR_ANY;
        address.sin_port = htons(port_);
        
        if (bind(server_fd_, (struct sockaddr*)&address, sizeof(address)) < 0) {
            std::cerr << "❌ Bind failed on port " << port_ << std::endl;
            return false;
        }
        
        // Listen
        if (listen(server_fd_, 10) < 0) {
            std::cerr << "❌ Listen failed" << std::endl;
            return false;
        }
        
        return true;
    }
    
    void handleClient() {
        struct sockaddr_in client_addr;
        socklen_t client_len = sizeof(client_addr);
        
        int client_fd = accept(server_fd_, (struct sockaddr*)&client_addr, &client_len);
        if (client_fd < 0) {
            std::cerr << "❌ Accept failed" << std::endl;
            return;
        }
        
        // Handle request in separate thread for better concurrency
        std::thread([this, client_fd]() {
            this->processRequest(client_fd);
        }).detach();
    }
    
    void processRequest(int client_fd) {
        try {
            // Read request with support for large bodies (up to 10MB)
            static const size_t MAX_BODY_SIZE = 200 * 1024 * 1024;
            static const size_t CHUNK_SIZE = 65536;

            // Read initial chunk (headers + start of body)
            char initial_buf[CHUNK_SIZE];
            ssize_t bytes_read = read(client_fd, initial_buf, sizeof(initial_buf));

            if (bytes_read <= 0) {
                close(client_fd);
                return;
            }

            std::string raw_request(initial_buf, bytes_read);

            // Find end of headers to determine Content-Length
            size_t header_end = raw_request.find("\r\n\r\n");
            if (header_end != std::string::npos) {
                size_t body_start = header_end + 4;
                size_t body_received = raw_request.size() - body_start;

                // Parse Content-Length from headers
                size_t content_length = 0;
                std::string headers_section = raw_request.substr(0, header_end);
                size_t cl_pos = headers_section.find("Content-Length:");
                if (cl_pos == std::string::npos)
                    cl_pos = headers_section.find("content-length:");
                if (cl_pos != std::string::npos) {
                    size_t val_start = cl_pos + 15; // length of "Content-Length:"
                    while (val_start < headers_section.size() && headers_section[val_start] == ' ')
                        val_start++;
                    size_t val_end = headers_section.find("\r\n", val_start);
                    if (val_end == std::string::npos) val_end = headers_section.size();
                    content_length = std::stoull(headers_section.substr(val_start, val_end - val_start));
                }

                // Read remaining body if needed (cap at MAX_BODY_SIZE)
                if (content_length > MAX_BODY_SIZE) content_length = MAX_BODY_SIZE;
                if (content_length > 0 && body_received < content_length) {
                    size_t remaining = content_length - body_received;
                    raw_request.reserve(body_start + content_length);
                    char chunk[CHUNK_SIZE];
                    while (remaining > 0) {
                        size_t to_read = std::min(remaining, sizeof(chunk));
                        ssize_t n = read(client_fd, chunk, to_read);
                        if (n <= 0) break;
                        raw_request.append(chunk, n);
                        remaining -= n;
                    }
                }
            }
            
            // Parse request and route
            Request request(raw_request);
            std::cout << "📨 " << request.toString() << std::endl;
            
            Response response = router_.handle(request);
            
            // Send response
            std::string http_response = response.toHttpString();
            send(client_fd, http_response.c_str(), http_response.length(), 0);
            
            std::cout << "📤 " << response.toString() << std::endl;
            
        } catch (const std::exception& e) {
            std::cerr << "❌ Request processing error: " << e.what() << std::endl;
            
            // Send error response
            Response error_response = Response::internalError("Internal server error");
            std::string http_response = error_response.toHttpString();
            send(client_fd, http_response.c_str(), http_response.length(), 0);
        }
        
        close(client_fd);
    }
};

int main() {
    // Initialize libcurl globally before any threads are created
    curl_global_init(CURL_GLOBAL_ALL);

    try {
        HttpServer server(3001);
        
        if (!server.initialize()) {
            std::cerr << "❌ Server initialization failed" << std::endl;
            curl_global_cleanup();
            return 1;
        }
        
        server.run();
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Server error: " << e.what() << std::endl;
        curl_global_cleanup();
        return 1;
    }
    
    curl_global_cleanup();
    return 0;
}