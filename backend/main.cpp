#include <iostream>
#include <string>
#include <sstream>
#include <thread>
#include <mutex>
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
    std::mutex db_mutex;  // Protect database access

public:
    bool initDatabase() {
        const int MAX_RETRIES = 10;
        const int RETRY_DELAY_SECONDS = 2;
        
        for (int attempt = 1; attempt <= MAX_RETRIES; attempt++) {
            try {
                std::cout << "🔄 Database connection attempt " << attempt << "/" << MAX_RETRIES << std::endl;
                
                // Docker container connection string
                std::string conn_str = "host=db port=5432 dbname=footballhome user=footballhome_user password=footballhome_pass";
                db_conn = std::make_unique<pqxx::connection>(conn_str);
                
                if (!db_conn->is_open()) {
                    std::cerr << "❌ Failed to connect to database" << std::endl;
                    if (attempt < MAX_RETRIES) {
                        std::cout << "⏳ Waiting " << RETRY_DELAY_SECONDS << " seconds before retry..." << std::endl;
                        std::this_thread::sleep_for(std::chrono::seconds(RETRY_DELAY_SECONDS));
                        continue;
                    }
                    return false;
                }
                
                std::cout << "✅ PostgreSQL connected successfully" << std::endl;
                return true;
            } catch (const std::exception& e) {
                std::cerr << "❌ Database error: " << e.what() << std::endl;
                if (attempt < MAX_RETRIES) {
                    std::cout << "⏳ Waiting " << RETRY_DELAY_SECONDS << " seconds before retry..." << std::endl;
                    std::this_thread::sleep_for(std::chrono::seconds(RETRY_DELAY_SECONDS));
                } else {
                    std::cerr << "❌ Database initialization failed after " << MAX_RETRIES << " attempts" << std::endl;
                    return false;
                }
            }
        }
        return false;
    }

    struct UserData {
        std::string id;
        std::string email;
        std::string name;
        std::string role;
        bool valid;
    };

    UserData authenticateUser(const std::string& email, const std::string& password) {
        UserData userData;
        userData.valid = false;
        
        std::cout << "🔍 authenticateUser called for: " << email << std::endl;
        std::cout << "🔍 Password received: [" << password << "]" << std::endl;
        std::cout << "🔍 Password length: " << password.length() << std::endl;
        
        // Lock mutex to protect database access
        std::lock_guard<std::mutex> lock(db_mutex);
        
        try {
            std::cout << "🔍 Starting database transaction" << std::endl;
            pqxx::work txn(*db_conn);
            std::cout << "🔍 Transaction started successfully" << std::endl;
            
            // Demo authentication - hardcoded accounts
            std::cout << "🔍 Checking test@test.com: " << (email == "test@test.com" ? "email match" : "email no match") << std::endl;
            if (email == "test@test.com" && password == "password") {
                userData.valid = true;
                userData.id = "test-user-123";
                userData.email = email;
                userData.name = "Test User";
                userData.role = "player";
                txn.commit();
                return userData;
            }
            
            std::cout << "🔍 Checking jbreslin@footballhome.org: " << (email == "jbreslin@footballhome.org" ? "email match" : "email no match") << std::endl;
            std::cout << "🔍 Password comparison: [" << password << "] vs [1893Soccer!]" << std::endl;
            if (email == "jbreslin@footballhome.org" && password == "1893Soccer!") {
                userData.valid = true;
                userData.id = "77d77471-1250-47e0-81ab-d4626595d63c";
                userData.email = email;
                userData.name = "James Breslin";
                userData.role = "admin";
                txn.commit();
                return userData;
            }
            
            // Query database for user by email (get the password hash)
            std::cout << "🔍 Querying DB for user: " << email << std::endl;
            std::string query = "SELECT u.id, u.email, u.name, u.password_hash, r.name as role_name "
                              "FROM users u "
                              "LEFT JOIN user_roles ur ON u.id = ur.user_id "
                              "LEFT JOIN roles r ON ur.role_id = r.id "
                              "WHERE u.email = $1 "
                              "LIMIT 1";
            auto result = txn.exec_params(query, email);
            std::cout << "🔍 Query returned " << result.size() << " rows" << std::endl;
            
            // If user found, verify password using PostgreSQL's crypt function
            if (!result.empty()) {
                auto row = result[0];
                std::string stored_hash = row["password_hash"].as<std::string>();
                
                std::cout << "🔍 User found in DB: " << email << std::endl;
                std::cout << "🔍 Hash from DB: " << stored_hash << std::endl;
                
                // Use PostgreSQL's crypt function to verify bcrypt hash
                std::string verify_query = "SELECT crypt($1, $2) = $2 AS password_match";
                auto verify_result = txn.exec_params(verify_query, password, stored_hash);
                
                bool password_match = !verify_result.empty() && verify_result[0]["password_match"].as<bool>();
                std::cout << "🔍 Password match result: " << (password_match ? "true" : "false") << std::endl;
                
                if (password_match) {
                    userData.valid = true;
                    userData.id = row["id"].as<std::string>();
                    userData.email = row["email"].as<std::string>();
                    userData.name = row["name"].as<std::string>();
                    userData.role = row["role_name"].is_null() ? "player" : row["role_name"].as<std::string>();
                }
            } else {
                std::cout << "🔍 No user found in DB for: " << email << std::endl;
            }
            
            txn.commit();
        } catch (const std::exception& e) {
            std::cerr << "❌ Auth query failed: " << e.what() << std::endl;
        }
        
        return userData;
    }

    std::string createJSONResponse(bool success, const std::string& message, const UserData& userData = {}) {
        std::ostringstream json;
        json << "{";
        json << "\"success\":" << (success ? "true" : "false") << ",";
        json << "\"message\":\"" << message << "\"";
        
        if (success && userData.valid) {
            // Split name into firstName and lastName for frontend compatibility
            std::string firstName = userData.name;
            std::string lastName = "";
            
            size_t spacePos = userData.name.find(' ');
            if (spacePos != std::string::npos) {
                firstName = userData.name.substr(0, spacePos);
                lastName = userData.name.substr(spacePos + 1);
            }
            
            json << ",\"user\":{";
            json << "\"id\":\"" << userData.id << "\",";
            json << "\"email\":\"" << userData.email << "\",";
            json << "\"name\":\"" << userData.name << "\",";
            json << "\"firstName\":\"" << firstName << "\",";
            json << "\"lastName\":\"" << lastName << "\",";
            json << "\"role\":\"" << userData.role << "\"";
            json << "}";
            json << ",\"token\":\"jwt_" << userData.id << "_" << std::hash<std::string>{}(userData.email) << "\"";
        }
        
        json << "}";
        return json.str();
    }

    std::string handleLoginRequest(const std::string& body) {
        try {
            // Parse JSON manually (simple approach)
            std::string email, password;
        
            // Extract email
            size_t email_pos = body.find("\"email\":\"");
            if (email_pos != std::string::npos) {
                size_t email_start = email_pos + 9;
                size_t email_end = body.find("\"", email_start);
                if (email_end != std::string::npos) {
                    email = body.substr(email_start, email_end - email_start);
                }
            }
        
            // Extract password  
            size_t pass_pos = body.find("\"password\":\"");
            if (pass_pos != std::string::npos) {
                size_t pass_start = pass_pos + 12;
                size_t pass_end = body.find("\"", pass_start);
                if (pass_end != std::string::npos) {
                    password = body.substr(pass_start, pass_end - pass_start);
                }
            }

            std::cout << "🔐 Login attempt: " << email << std::endl;

            // Authenticate user
            std::cout << "🔍 About to call authenticateUser..." << std::endl;
            UserData userData = authenticateUser(email, password);
            std::cout << "🔍 authenticateUser returned, valid=" << userData.valid << std::endl;
        
        if (userData.valid) {
            std::cout << "✅ Authentication successful: " << email << " (" << userData.name << ")" << std::endl;
            return createJSONResponse(true, "Login successful", userData);
        } else {
            std::cout << "❌ Authentication failed: " << email << std::endl;
            return createJSONResponse(false, "Invalid credentials");
        }
        } catch (const std::exception& e) {
            std::cerr << "❌ FATAL ERROR in handleLoginRequest: " << e.what() << std::endl;
            return createJSONResponse(false, "Internal server error");
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