#include <iostream>
#include <thread>
#include <chrono>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

#include "core/Router.h"
#include "core/Request.h"
#include "core/Response.h"
#include "core/SQLFileWriter.h"
#include "database/Database.h"
#include "database/SqlFileLogger.h"
#include "controllers/AuthController.h"
#include "controllers/TeamController.h"
#include "controllers/EventController.h"
#include "controllers/DivisionController.h"
#include "controllers/AvailabilityController.h"
#include "controllers/SystemAdminController.h"

class HttpServer {
private:
    int server_fd_;
    int port_;
    Router router_;
    Database* db_;
    
    // Controllers
    std::shared_ptr<AuthController> auth_controller_;
    std::shared_ptr<TeamController> team_controller_;
    std::shared_ptr<EventController> event_controller_;
    std::shared_ptr<DivisionController> division_controller_;
    std::shared_ptr<AvailabilityController> availability_controller_;
    std::shared_ptr<SystemAdminController> system_admin_controller_;

public:
    HttpServer(int port = 3001) : port_(port) {
        db_ = Database::getInstance();
        auth_controller_ = std::make_shared<AuthController>();
        team_controller_ = std::make_shared<TeamController>();
        event_controller_ = std::make_shared<EventController>();
        division_controller_ = std::make_shared<DivisionController>();
        availability_controller_ = std::make_shared<AvailabilityController>();
        system_admin_controller_ = std::make_shared<SystemAdminController>();
    }
    
    bool initialize() {
        std::cout << "🚀 Football Home Server Starting..." << std::endl;
        
        // Initialize SQL file logger
        SqlFileLogger::initialize();
        
        // Initialize SQL file writer for data persistence
        const char* env = std::getenv("ENVIRONMENT");
        auto sqlEnv = (env && std::string(env) == "production") 
            ? SQLFileWriter::Environment::PRODUCTION 
            : SQLFileWriter::Environment::DEVELOPMENT;
        SQLFileWriter::getInstance().initialize(sqlEnv, "/app/database/data");
        
        // Initialize database
        if (!db_->connect()) {
            std::cerr << "❌ Failed to connect to database" << std::endl;
            return false;
        }
        
        // Setup routes
        setupRoutes();
        
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
        router_.useController("/api/auth", auth_controller_);
        router_.useController("/api/teams", team_controller_);
        router_.useController("/api/events", event_controller_);
        router_.useController("/api", division_controller_);
        router_.useController("/api", availability_controller_);
        router_.useController("/api/system-admin", system_admin_controller_);
        
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
            // Read request
            char buffer[4096] = {0};
            ssize_t bytes_read = read(client_fd, buffer, sizeof(buffer) - 1);
            
            if (bytes_read <= 0) {
                close(client_fd);
                return;
            }
            
            std::string raw_request(buffer, bytes_read);
            
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
    try {
        HttpServer server(3001);
        
        if (!server.initialize()) {
            std::cerr << "❌ Server initialization failed" << std::endl;
            return 1;
        }
        
        server.run();
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Server error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}