#pragma once
#include <pqxx/pqxx>
#include <memory>
#include <string>
#include <mutex>

class Database {
private:
    static std::unique_ptr<Database> instance_;
    static std::mutex mutex_;
    
    std::unique_ptr<pqxx::connection> connection_;
    std::string connection_string_;
    std::mutex connection_mutex_;
    
    // Private constructor for singleton
    Database(const std::string& connection_string);

public:
    // Singleton access
    static Database* getInstance();
    static Database* getInstance(const std::string& connection_string);
    
    // Delete copy constructor and assignment operator
    Database(const Database&) = delete;
    Database& operator=(const Database&) = delete;
    
    ~Database() = default;
    
    // Connection management
    bool connect();
    bool isConnected() const;
    void disconnect();
    bool reconnect();
    
    // Query execution
    pqxx::result query(const std::string& sql);
    pqxx::result query(const std::string& sql, const std::vector<std::string>& params);
    
    // Transaction support
    std::unique_ptr<pqxx::work> beginTransaction();
    void commit(std::unique_ptr<pqxx::work>& transaction);
    void rollback(std::unique_ptr<pqxx::work>& transaction);
    
    // Prepared statements
    void prepare(const std::string& name, const std::string& sql);
    pqxx::result execute(const std::string& statement_name);
    pqxx::result execute(const std::string& statement_name, const std::vector<std::string>& params);
    
    // Utility methods
    std::string escape(const std::string& value);
    bool tableExists(const std::string& table_name);
    
    // Connection info
    std::string getConnectionInfo() const;
    
private:
    void initializeConnection();
    void waitForDatabase(int max_retries = 10, int delay_seconds = 2);
};