#pragma once
#include <pqxx/pqxx>
#include <atomic>
#include <condition_variable>
#include <cstddef>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

// ---------------------------------------------------------------------------
// Database — singleton facade over a small, self-healing pqxx connection
// pool.
//
// Why a pool: the original implementation held a single pqxx::connection
// behind one mutex. When the OS or DB closed that socket (idle NAT timeout,
// DB restart, network blip) every subsequent query failed forever because
// nothing reopened it. The pool below solves that by:
//   • Keeping N persistent connections (DB_POOL_SIZE env, default 8).
//   • Baking TCP keepalives into the libpq connection string so dead
//     sockets surface quickly instead of hanging.
//   • Lazily re-opening any slot whose connection has gone bad before
//     handing it out (RAII Lease).
//   • Transparently retrying a query once when pqxx reports
//     broken_connection mid-flight.
//
// Public API is unchanged so controllers continue to use db_->query(...).
// ---------------------------------------------------------------------------
class Database {
public:
    static Database* getInstance();
    static Database* getInstance(const std::string& connection_string);

    Database(const Database&) = delete;
    Database& operator=(const Database&) = delete;
    ~Database() = default;

    // Warm the pool. Safe to call repeatedly; idempotent.
    bool connect();
    // True if at least one slot in the pool is open right now.
    bool isConnected() const;
    // Drop every pooled connection. The next query() will lazily reopen.
    void disconnect();
    // disconnect() + connect().
    bool reconnect();

    // Hot path. Each call leases a connection, runs the work, and
    // returns the slot. A single retry happens automatically on
    // pqxx::broken_connection so callers see DB blips as a brief
    // latency bump rather than an error.
    pqxx::result query(const std::string& sql);
    pqxx::result query(const std::string& sql, const std::vector<std::string>& params);

    // Legacy. No controller in this repo currently calls these. They
    // route through one-shot connections so the pool isn't tied up for
    // the lifetime of the returned work / prepared statement. Prepared
    // statements DO NOT persist across calls — use parameterised
    // query() instead.
    std::unique_ptr<pqxx::work> beginTransaction();
    void commit(std::unique_ptr<pqxx::work>& transaction);
    void rollback(std::unique_ptr<pqxx::work>& transaction);

    void prepare(const std::string& name, const std::string& sql);
    pqxx::result execute(const std::string& statement_name);
    pqxx::result execute(const std::string& statement_name,
                         const std::vector<std::string>& params);

    std::string escape(const std::string& value);
    bool tableExists(const std::string& table_name);
    std::string getConnectionInfo() const;

private:
    explicit Database(const std::string& connection_string);

    struct Slot {
        std::unique_ptr<pqxx::connection> conn;
        bool in_use = false;
    };

    static std::unique_ptr<Database> instance_;
    static std::mutex instance_mutex_;

    std::string connection_string_;   // augmented with TCP keepalives
    std::size_t pool_size_;
    std::vector<Slot> pool_;
    std::mutex pool_mutex_;
    std::condition_variable pool_cv_;

    // Open a fresh pqxx::connection from connection_string_. Throws on
    // failure. Caller owns the result.
    std::unique_ptr<pqxx::connection> openOne();

    // Block until the DB accepts at least one fresh connection or we
    // exhaust max_retries. Used on initial warm-up only.
    void waitForDatabase(int max_retries = 30, int delay_seconds = 2);

    // Augment a libpq connection string with TCP keepalives + a sane
    // connect_timeout if the caller hasn't set them.
    static std::string augmentConnString(const std::string& raw);

    // RAII lease for a single pool slot. Acquires under pool_mutex_,
    // re-opens the slot if its connection has died, and releases the
    // slot on destruction. Call poison() to mark the slot for
    // replacement (e.g. mid-query broken_connection) so the next
    // acquirer gets a fresh socket instead of the dead one.
    class Lease {
    public:
        explicit Lease(Database& db);
        ~Lease();
        Lease(const Lease&) = delete;
        Lease& operator=(const Lease&) = delete;

        pqxx::connection& conn() { return *conn_; }
        void poison() { poisoned_ = true; }

    private:
        Database& db_;
        pqxx::connection* conn_;
        std::size_t slot_idx_;
        bool poisoned_ = false;
    };
};