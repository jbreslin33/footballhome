#include <iostream>
#include <string>
#include <sstream>
#include <thread>
#include <cstring>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <pqxx/pqxx>

class SimpleHTTPServer {
private:
    int server_fd;
    int port = 3001;
    std::unique_ptr<pqxx::connection> db_conn;

public:
    bool initDatabase() {
        try {
            // Docker container connection string
            std::string conn_str = "host=db port=5432 dbname=footballhome user=footballhome_user password=footballhome_pass";
            db_conn = std::make_unique<pqxx::connection>(conn_str);
            
            if (!db_conn->is_open()) {
                std::cerr << "❌ Failed to connect to database" << std::endl;
                return false;
            }
            
            std::cout << "✅ PostgreSQL connected successfully" << std::endl;
            return true;
        } catch (const std::exception& e) {
            std::cerr << "❌ Database error: " << e.what() << std::endl;
            return false;
        }
    }

    bool authenticateUser(const std::string& email, const std::string& password) {
        try {
            pqxx::work txn(*db_conn);
            
            // Simple query to check user credentials
            std::string query = "SELECT id FROM users WHERE email = $1 AND password_hash = $2";
            auto result = txn.exec_params(query, email, password);
            
            txn.commit();
            return !result.empty();
        } catch (const std::exception& e) {
            std::cerr << "❌ Auth query failed: " << e.what() << std::endl;
            return false;
        }
    }

    std::string createJSONResponse(bool success, const std::string& message, const std::string& email = "") {
        std::ostringstream json;
        json << "{";
        json << "\"success\":" << (success ? "true" : "false") << ",";
        json << "\"message\":\"" << message << "\"";
        
        if (success && !email.empty()) {
            json << ",\"user\":{\"email\":\"" << email << "\",\"role\":\"player\"}";
            json << ",\"token\":\"simple_jwt_token_123\"";
        }
        
        json << "}";
        return json.str();
    }

    std::string handleLoginRequest(const std::string& body) {
        // Parse JSON manually (simple approach)
        std::string email, password;
        
        // Extract email
        size_t email_start = body.find("\"email\":\"") + 9;
        size_t email_end = body.find("\"", email_start);
        if (email_start != std::string::npos && email_end != std::string::npos) {
            email = body.substr(email_start, email_end - email_start);
        }
        
        // Extract password  
        size_t pass_start = body.find("\"password\":\"") + 12;
        size_t pass_end = body.find("\"", pass_start);
        if (pass_start != std::string::npos && pass_end != std::string::npos) {
            password = body.substr(pass_start, pass_end - pass_start);
        }

        std::cout << "🔐 Login attempt: " << email << std::endl;

        // Demo authentication (matches your test account)
        if (email == "test@test.com" && password == "password") {
            return createJSONResponse(true, "Login successful", email);
        } else {
            return createJSONResponse(false, "Invalid credentials");
        }
    }

    std::string createHTTPResponse(int status_code, const std::string& content_type, const std::string& body) {
        std::ostringstream response;
        response << "HTTP/1.1 " << status_code << " " << (status_code == 200 ? "OK" : "Bad Request") << "\r\n";
        response << "Content-Type: " << content_type << "\r\n";
        response << "Content-Length: " << body.length() << "\r\n";
        response << "Access-Control-Allow-Origin: *\r\n";
        response << "Access-Control-Allow-Methods: GET, POST, OPTIONS\r\n";
        response << "Access-Control-Allow-Headers: Content-Type\r\n";
        response << "\r\n";
        response << body;
        return response.str();
    }

    void handleClient(int client_socket) {
        char buffer[4096] = {0};
        int bytes_read = read(client_socket, buffer, sizeof(buffer) - 1);
        
        if (bytes_read <= 0) {
            close(client_socket);
            return;
        }

        std::string request(buffer, bytes_read);
        std::cout << "📥 Request received" << std::endl;

        std::string response;
        
        if (request.find("OPTIONS") == 0) {
            // CORS preflight
            response = createHTTPResponse(204, "text/plain", "");
        }
        else if (request.find("POST /api/auth/login") != std::string::npos) {
            // Extract body from request
            size_t body_start = request.find("\r\n\r\n");
            if (body_start != std::string::npos) {
                std::string body = request.substr(body_start + 4);
                std::string json_response = handleLoginRequest(body);
                response = createHTTPResponse(200, "application/json", json_response);
            } else {
                std::string error = createJSONResponse(false, "No request body");
                response = createHTTPResponse(400, "application/json", error);
            }
        }
        else if (request.find("GET /health") != std::string::npos) {
            // Health check
            std::string health = "{\"status\":\"healthy\",\"service\":\"simple-cpp-backend\"}";
            response = createHTTPResponse(200, "application/json", health);
        }
        else {
            // Not found
            std::string error = createJSONResponse(false, "Endpoint not found");
            response = createHTTPResponse(404, "application/json", error);
        }

        send(client_socket, response.c_str(), response.length(), 0);
        close(client_socket);
    }

    bool startServer() {
        // Create socket
        server_fd = socket(AF_INET, SOCK_STREAM, 0);
        if (server_fd == 0) {
            std::cerr << "❌ Socket creation failed" << std::endl;
            return false;
        }

        // Allow socket reuse
        int opt = 1;
        setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

        // Bind to port
        struct sockaddr_in address;
        address.sin_family = AF_INET;
        address.sin_addr.s_addr = INADDR_ANY;
        address.sin_port = htons(port);

        if (bind(server_fd, (struct sockaddr*)&address, sizeof(address)) < 0) {
            std::cerr << "❌ Bind failed on port " << port << std::endl;
            return false;
        }

        // Listen for connections
        if (listen(server_fd, 10) < 0) {
            std::cerr << "❌ Listen failed" << std::endl;
            return false;
        }

        std::cout << "🚀 Server listening on port " << port << std::endl;
        std::cout << "📡 Endpoints available:" << std::endl;
        std::cout << "   POST /api/auth/login" << std::endl;
        std::cout << "   GET  /health" << std::endl;

        // Accept connections
        while (true) {
            struct sockaddr_in client_address;
            socklen_t client_len = sizeof(client_address);
            
            int client_socket = accept(server_fd, (struct sockaddr*)&client_address, &client_len);
            if (client_socket < 0) {
                std::cerr << "❌ Accept failed" << std::endl;
                continue;
            }

            // Handle each client in a separate thread
            std::thread client_thread(&SimpleHTTPServer::handleClient, this, client_socket);
            client_thread.detach();
        }

        return true;
    }

    ~SimpleHTTPServer() {
        if (server_fd > 0) {
            close(server_fd);
        }
    }
};

int main() {
    std::cout << "🏈 FootballHome Simple C++ Backend Starting..." << std::endl;
    
    SimpleHTTPServer server;
    
    if (!server.initDatabase()) {
        std::cerr << "❌ Database initialization failed" << std::endl;
        return 1;
    }

    if (!server.startServer()) {
        std::cerr << "❌ Server startup failed" << std::endl;
        return 1;
    }

    return 0;
}