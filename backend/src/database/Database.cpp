#include "Database.h"
#include <iostream>
#include <thread>
#include <chrono>

// Static member initialization
std::unique_ptr<Database> Database::instance_ = nullptr;
std::mutex Database::mutex_;

Database::Database(const std::string& connection_string) 
    : connection_string_(connection_string) {
    // Constructor is private - connection happens in connect()
}

Database* Database::getInstance() {
    // Default connection string for Docker environment
    return getInstance("host=db port=5432 dbname=footballhome user=footballhome_user password=footballhome_pass");
}

Database* Database::getInstance(const std::string& connection_string) {
    std::lock_guard<std::mutex> lock(mutex_);
    if (instance_ == nullptr) {
        instance_ = std::unique_ptr<Database>(new Database(connection_string));
    }
    return instance_.get();
}

bool Database::connect() {
    std::lock_guard<std::mutex> lock(connection_mutex_);
    
    try {
        std::cout << "🔄 Connecting to database..." << std::endl;
        
        // Wait for database to be ready (important for Docker startup)
        waitForDatabase();
        
        connection_ = std::make_unique<pqxx::connection>(connection_string_);
        
        if (!connection_->is_open()) {
            std::cerr << "❌ Failed to open database connection" << std::endl;
            return false;
        }
        
        std::cout << "✅ Database connected successfully" << std::endl;
        return true;
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Database connection error: " << e.what() << std::endl;
        return false;
    }
}

bool Database::isConnected() const {
    // Note: Can't use mutex in const method, but this is a simple read operation
    return connection_ && connection_->is_open();
}

void Database::disconnect() {
    std::lock_guard<std::mutex> lock(connection_mutex_);
    if (connection_ && connection_->is_open()) {
        // Reset connection (destructor handles cleanup)
        std::cout << "🔌 Database disconnected" << std::endl;
    }
    connection_.reset();
}

bool Database::reconnect() {
    disconnect();
    return connect();
}

pqxx::result Database::query(const std::string& sql) {
    std::lock_guard<std::mutex> lock(connection_mutex_);
    
    if (!connection_ || !connection_->is_open()) {
        throw std::runtime_error("Database not connected");
    }
    
    try {
        pqxx::nontransaction work(*connection_);
        pqxx::result result = work.exec(sql);
        return result;
    } catch (const std::exception& e) {
        std::cerr << "❌ Query error: " << e.what() << std::endl;
        std::cerr << "   SQL: " << sql << std::endl;
        throw;
    }
}

pqxx::result Database::query(const std::string& sql, const std::vector<std::string>& params) {
    std::lock_guard<std::mutex> lock(connection_mutex_);
    
    if (!connection_ || !connection_->is_open()) {
        throw std::runtime_error("Database not connected");
    }
    
    try {
        pqxx::work work(*connection_);
        
        // Use pqxx::work::exec_params for parameterized queries
        pqxx::result result;
        
        if (params.size() == 0) {
            result = work.exec(sql);
        } else if (params.size() == 1) {
            result = work.exec_params(sql, params[0]);
        } else if (params.size() == 2) {
            result = work.exec_params(sql, params[0], params[1]);
        } else if (params.size() == 3) {
            result = work.exec_params(sql, params[0], params[1], params[2]);
        } else if (params.size() == 4) {
            result = work.exec_params(sql, params[0], params[1], params[2], params[3]);
        } else if (params.size() == 5) {
            result = work.exec_params(sql, params[0], params[1], params[2], params[3], params[4]);
        } else {
            throw std::runtime_error("Too many parameters (max 5 supported)");
        }
        
        work.commit();
        return result;
    } catch (const std::exception& e) {
        std::cerr << "❌ Parameterized query error: " << e.what() << std::endl;
        std::cerr << "   SQL: " << sql << std::endl;
        throw;
    }
}

std::unique_ptr<pqxx::work> Database::beginTransaction() {
    std::lock_guard<std::mutex> lock(connection_mutex_);
    
    if (!connection_ || !connection_->is_open()) {
        throw std::runtime_error("Database not connected");
    }
    
    return std::make_unique<pqxx::work>(*connection_);
}

void Database::commit(std::unique_ptr<pqxx::work>& transaction) {
    if (transaction) {
        transaction->commit();
        transaction.reset();
    }
}

void Database::rollback(std::unique_ptr<pqxx::work>& transaction) {
    if (transaction) {
        transaction->abort();
        transaction.reset();
    }
}

void Database::prepare(const std::string& name, const std::string& sql) {
    std::lock_guard<std::mutex> lock(connection_mutex_);
    
    if (!connection_ || !connection_->is_open()) {
        throw std::runtime_error("Database not connected");
    }
    
    connection_->prepare(name, sql);
}

pqxx::result Database::execute(const std::string& statement_name) {
    std::lock_guard<std::mutex> lock(connection_mutex_);
    
    if (!connection_ || !connection_->is_open()) {
        throw std::runtime_error("Database not connected");
    }
    
    pqxx::nontransaction work(*connection_);
    return work.exec_prepared(statement_name);
}

pqxx::result Database::execute(const std::string& statement_name, const std::vector<std::string>& params) {
    std::lock_guard<std::mutex> lock(connection_mutex_);
    
    if (!connection_ || !connection_->is_open()) {
        throw std::runtime_error("Database not connected");
    }
    
    pqxx::nontransaction work(*connection_);
    
    // Convert vector to pqxx's parameter format
    switch (params.size()) {
        case 0: return work.exec_prepared(statement_name);
        case 1: return work.exec_prepared(statement_name, params[0]);
        case 2: return work.exec_prepared(statement_name, params[0], params[1]);
        case 3: return work.exec_prepared(statement_name, params[0], params[1], params[2]);
        // Add more cases as needed
        default:
            throw std::runtime_error("Too many parameters for prepared statement");
    }
}

std::string Database::escape(const std::string& value) {
    std::lock_guard<std::mutex> lock(connection_mutex_);
    
    if (!connection_ || !connection_->is_open()) {
        throw std::runtime_error("Database not connected");
    }
    
    return connection_->quote(value);
}

bool Database::tableExists(const std::string& table_name) {
    try {
        std::string sql = "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = $1)";
        pqxx::result result = query(sql, {table_name});
        
        if (!result.empty()) {
            return result[0][0].as<bool>();
        }
        return false;
    } catch (const std::exception& e) {
        std::cerr << "❌ Error checking table existence: " << e.what() << std::endl;
        return false;
    }
}

std::string Database::getConnectionInfo() const {
    return connection_string_;
}

void Database::waitForDatabase(int max_retries, int delay_seconds) {
    for (int attempt = 1; attempt <= max_retries; ++attempt) {
        try {
            std::cout << "🔄 Database connection attempt " << attempt << "/" << max_retries << std::endl;
            
            pqxx::connection test_conn(connection_string_);
            if (test_conn.is_open()) {
                // Connection successful, destructor will clean up
                std::cout << "✅ Database is ready" << std::endl;
                return;
            }
        } catch (const std::exception& e) {
            std::cout << "⏳ Database not ready, attempt " << attempt << ": " << e.what() << std::endl;
        }
        
        if (attempt < max_retries) {
            std::cout << "⏳ Waiting " << delay_seconds << " seconds before retry..." << std::endl;
            std::this_thread::sleep_for(std::chrono::seconds(delay_seconds));
        }
    }
    
    throw std::runtime_error("Database not available after " + std::to_string(max_retries) + " attempts");
}