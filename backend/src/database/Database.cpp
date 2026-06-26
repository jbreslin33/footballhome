#include "Database.h"

#include <algorithm>
#include <chrono>
#include <cstdlib>
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <thread>

// ---------------------------------------------------------------------------
// Singleton plumbing
// ---------------------------------------------------------------------------
std::unique_ptr<Database> Database::instance_ = nullptr;
std::mutex Database::instance_mutex_;

Database::Database(const std::string& connection_string)
    : connection_string_(augmentConnString(connection_string)),
      pool_size_(8) {
    // Allow operators to dial the pool up/down without a recompile.
    if (const char* env = std::getenv("DB_POOL_SIZE")) {
        try {
            int n = std::stoi(env);
            if (n > 0 && n <= 64) pool_size_ = static_cast<std::size_t>(n);
        } catch (...) { /* keep default */ }
    }
    pool_.resize(pool_size_);
}

Database* Database::getInstance() {
    // Default for the dockerised dev/prod environment. Caller can
    // override with the explicit overload below.
    return getInstance(
        "host=db port=5432 dbname=footballhome "
        "user=footballhome_user password=footballhome_pass");
}

Database* Database::getInstance(const std::string& connection_string) {
    std::lock_guard<std::mutex> lock(instance_mutex_);
    if (!instance_) {
        instance_.reset(new Database(connection_string));
    }
    return instance_.get();
}

// ---------------------------------------------------------------------------
// Connection-string augmentation
//
// libpq accepts TCP keepalive params directly in the connection string.
// We append them only when absent so an operator override (PGSERVICEFILE,
// PGOPTIONS, or a fully custom getInstance(string)) wins.
// ---------------------------------------------------------------------------
std::string Database::augmentConnString(const std::string& raw) {
    auto contains = [&](const char* key) {
        return raw.find(key) != std::string::npos;
    };

    std::ostringstream out;
    out << raw;

    if (!contains("keepalives=")) {
        out << " keepalives=1"
            << " keepalives_idle=30"
            << " keepalives_interval=10"
            << " keepalives_count=3";
    }
    if (!contains("connect_timeout=")) {
        out << " connect_timeout=5";
    }
    // application_name shows up in pg_stat_activity which makes
    // diagnosing connection storms a lot easier.
    if (!contains("application_name=")) {
        out << " application_name=footballhome_backend";
    }
    return out.str();
}

// ---------------------------------------------------------------------------
// Open one new pqxx::connection from connection_string_. Throws on failure.
// ---------------------------------------------------------------------------
std::unique_ptr<pqxx::connection> Database::openOne() {
    auto c = std::make_unique<pqxx::connection>(connection_string_);
    if (!c->is_open()) {
        throw std::runtime_error("pqxx::connection opened but not is_open()");
    }
    return c;
}

// ---------------------------------------------------------------------------
// Lifecycle
// ---------------------------------------------------------------------------
bool Database::connect() {
    try {
        std::cout << "🔄 Connecting to database (pool size " << pool_size_
                  << ")..." << std::endl;
        waitForDatabase();
    } catch (const std::exception& e) {
        std::cerr << "❌ Database not reachable: " << e.what() << std::endl;
        return false;
    }

    // Warm one slot eagerly so we fail fast on bad credentials. The
    // remaining slots are opened lazily on first lease.
    std::lock_guard<std::mutex> lock(pool_mutex_);
    try {
        if (!pool_[0].conn || !pool_[0].conn->is_open()) {
            pool_[0].conn = openOne();
        }
        std::cout << "✅ Database connected (pool warm: 1/" << pool_size_
                  << ", rest lazy)" << std::endl;
        return true;
    } catch (const std::exception& e) {
        std::cerr << "❌ Database connection error: " << e.what() << std::endl;
        return false;
    }
}

bool Database::isConnected() const {
    // We can't lock pool_mutex_ from a const method without mutable, but
    // we don't need to: this is a best-effort health probe and any
    // racing modification just changes the answer of the next call.
    // Iterate the vector by raw pointers to avoid touching the unique_ptrs.
    auto& slots = const_cast<std::vector<Slot>&>(pool_);
    for (auto& s : slots) {
        if (s.conn && s.conn->is_open()) return true;
    }
    return false;
}

void Database::disconnect() {
    std::lock_guard<std::mutex> lock(pool_mutex_);
    for (auto& slot : pool_) {
        slot.conn.reset();
        slot.in_use = false;
    }
    std::cout << "🔌 Database pool drained" << std::endl;
    pool_cv_.notify_all();
}

bool Database::reconnect() {
    disconnect();
    return connect();
}

// ---------------------------------------------------------------------------
// Lease (RAII slot acquisition)
// ---------------------------------------------------------------------------
Database::Lease::Lease(Database& db)
    : db_(db), conn_(nullptr), slot_idx_(0) {
    std::unique_lock<std::mutex> lk(db_.pool_mutex_);

    // Wait until at least one slot is free. The pool is small but
    // requests are fast, so we should rarely block.
    db_.pool_cv_.wait(lk, [&] {
        for (auto& s : db_.pool_) {
            if (!s.in_use) return true;
        }
        return false;
    });

    // Find a free slot and (if needed) lazily open / replace its
    // connection. We try every free slot before giving up so a single
    // bad-network blip on one slot doesn't fail the request.
    std::string last_err;
    for (std::size_t i = 0; i < db_.pool_.size(); ++i) {
        auto& slot = db_.pool_[i];
        if (slot.in_use) continue;

        if (!slot.conn || !slot.conn->is_open()) {
            try {
                slot.conn = db_.openOne();
            } catch (const std::exception& e) {
                last_err = e.what();
                std::cerr << "⚠️  Pool slot " << i << " reconnect failed: "
                          << last_err << std::endl;
                slot.conn.reset();
                continue;
            }
        }

        slot.in_use = true;
        slot_idx_ = i;
        conn_ = slot.conn.get();
        return;
    }

    // Every free slot is unusable (DB down). Surface a clear error.
    throw std::runtime_error(
        std::string("Database not connected") +
        (last_err.empty() ? "" : ": " + last_err));
}

Database::Lease::~Lease() {
    if (!conn_) return;  // never acquired (construction threw)
    std::lock_guard<std::mutex> lk(db_.pool_mutex_);
    auto& slot = db_.pool_[slot_idx_];
    if (poisoned_ || !slot.conn || !slot.conn->is_open()) {
        // Drop the dead handle; the next lease for this slot will reopen.
        slot.conn.reset();
    }
    slot.in_use = false;
    db_.pool_cv_.notify_one();
}

// ---------------------------------------------------------------------------
// Helpers for parameterised exec — pqxx's exec_params is variadic and
// can't take a runtime-sized container, so we expand by size up to 16.
// ---------------------------------------------------------------------------
namespace {

pqxx::result execParams(pqxx::work& w,
                        const std::string& sql,
                        const std::vector<std::string>& p) {
    switch (p.size()) {
        case 0:  return w.exec(sql);
        case 1:  return w.exec_params(sql, p[0]);
        case 2:  return w.exec_params(sql, p[0], p[1]);
        case 3:  return w.exec_params(sql, p[0], p[1], p[2]);
        case 4:  return w.exec_params(sql, p[0], p[1], p[2], p[3]);
        case 5:  return w.exec_params(sql, p[0], p[1], p[2], p[3], p[4]);
        case 6:  return w.exec_params(sql, p[0], p[1], p[2], p[3], p[4], p[5]);
        case 7:  return w.exec_params(sql, p[0], p[1], p[2], p[3], p[4], p[5], p[6]);
        case 8:  return w.exec_params(sql, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);
        case 9:  return w.exec_params(sql, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]);
        case 10: return w.exec_params(sql, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9]);
        case 11: return w.exec_params(sql, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10]);
        case 12: return w.exec_params(sql, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10], p[11]);
        case 13: return w.exec_params(sql, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10], p[11], p[12]);
        case 14: return w.exec_params(sql, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10], p[11], p[12], p[13]);
        case 15: return w.exec_params(sql, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10], p[11], p[12], p[13], p[14]);
        case 16: return w.exec_params(sql, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10], p[11], p[12], p[13], p[14], p[15]);
        default:
            throw std::runtime_error("Too many parameters (max 16 supported)");
    }
}

pqxx::result execPreparedParams(pqxx::nontransaction& w,
                                const std::string& name,
                                const std::vector<std::string>& p) {
    switch (p.size()) {
        case 0:  return w.exec_prepared(name);
        case 1:  return w.exec_prepared(name, p[0]);
        case 2:  return w.exec_prepared(name, p[0], p[1]);
        case 3:  return w.exec_prepared(name, p[0], p[1], p[2]);
        case 4:  return w.exec_prepared(name, p[0], p[1], p[2], p[3]);
        case 5:  return w.exec_prepared(name, p[0], p[1], p[2], p[3], p[4]);
        case 6:  return w.exec_prepared(name, p[0], p[1], p[2], p[3], p[4], p[5]);
        case 7:  return w.exec_prepared(name, p[0], p[1], p[2], p[3], p[4], p[5], p[6]);
        case 8:  return w.exec_prepared(name, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);
        default:
            throw std::runtime_error("Too many parameters for prepared statement (max 8)");
    }
}

}  // namespace

// ---------------------------------------------------------------------------
// query() — leased, with one transparent retry on broken_connection.
// ---------------------------------------------------------------------------
pqxx::result Database::query(const std::string& sql) {
    for (int attempt = 0; attempt < 2; ++attempt) {
        Lease lease(*this);
        try {
            pqxx::nontransaction work(lease.conn());
            return work.exec(sql);
        } catch (const pqxx::broken_connection& e) {
            lease.poison();
            if (attempt == 1) {
                std::cerr << "❌ Query failed after retry: " << e.what()
                          << "\n   SQL: " << sql << std::endl;
                throw;
            }
            std::cerr << "⚠️  Broken DB connection during query, retrying once"
                      << std::endl;
            continue;
        } catch (const std::exception& e) {
            std::cerr << "❌ Query error: " << e.what()
                      << "\n   SQL: " << sql << std::endl;
            throw;
        }
    }
    // Unreachable — the loop either returns or throws.
    throw std::runtime_error("Database::query unreachable state");
}

pqxx::result Database::query(const std::string& sql,
                             const std::vector<std::string>& params) {
    for (int attempt = 0; attempt < 2; ++attempt) {
        Lease lease(*this);
        try {
            pqxx::work work(lease.conn());
            auto result = execParams(work, sql, params);
            work.commit();
            return result;
        } catch (const pqxx::broken_connection& e) {
            lease.poison();
            if (attempt == 1) {
                std::cerr << "❌ Parameterised query failed after retry: "
                          << e.what() << "\n   SQL: " << sql << std::endl;
                throw;
            }
            std::cerr << "⚠️  Broken DB connection during parameterised query, "
                         "retrying once" << std::endl;
            continue;
        } catch (const std::exception& e) {
            std::cerr << "❌ Parameterised query error: " << e.what()
                      << "\n   SQL: " << sql << std::endl;
            throw;
        }
    }
    throw std::runtime_error("Database::query(params) unreachable state");
}

// ---------------------------------------------------------------------------
// escape() — uses a leased connection's quote(); short-lived so no retry
// loop is needed.
// ---------------------------------------------------------------------------
std::string Database::escape(const std::string& value) {
    Lease lease(*this);
    try {
        return lease.conn().quote(value);
    } catch (const pqxx::broken_connection& e) {
        lease.poison();
        // One quick retry on a fresh slot.
        Lease retry(*this);
        return retry.conn().quote(value);
    }
}

bool Database::tableExists(const std::string& table_name) {
    try {
        auto r = query(
            "SELECT EXISTS (SELECT 1 FROM information_schema.tables "
            "WHERE table_name = $1)",
            {table_name});
        return !r.empty() && r[0][0].as<bool>();
    } catch (const std::exception& e) {
        std::cerr << "❌ Error checking table existence: " << e.what()
                  << std::endl;
        return false;
    }
}

std::string Database::getConnectionInfo() const {
    return connection_string_;
}

// ---------------------------------------------------------------------------
// Legacy: beginTransaction / commit / rollback
//
// No controller in the repo calls these. To avoid pinning a pool slot for
// the unbounded lifetime of the returned work, we hand out a connection
// that is NOT in the pool. The connection is parked on a thread-local
// holder so the returned work has a live referent until the next call on
// the same thread; commit/rollback should be done before another
// beginTransaction() on that thread.
// ---------------------------------------------------------------------------
std::unique_ptr<pqxx::work> Database::beginTransaction() {
    thread_local std::unique_ptr<pqxx::connection> tls_tx_conn;
    tls_tx_conn = openOne();
    return std::make_unique<pqxx::work>(*tls_tx_conn);
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

// ---------------------------------------------------------------------------
// Legacy: prepare / execute
//
// Prepared statements are scoped to a single pqxx::connection. With a
// pool, a prepare()/execute() pair on different leases will fail. These
// methods are kept for binary compatibility but should be considered
// unsupported — use parameterised query() instead.
// ---------------------------------------------------------------------------
void Database::prepare(const std::string& name, const std::string& sql) {
    Lease lease(*this);
    lease.conn().prepare(name, sql);
}

pqxx::result Database::execute(const std::string& statement_name) {
    Lease lease(*this);
    pqxx::nontransaction work(lease.conn());
    return work.exec_prepared(statement_name);
}

pqxx::result Database::execute(const std::string& statement_name,
                               const std::vector<std::string>& params) {
    Lease lease(*this);
    pqxx::nontransaction work(lease.conn());
    return execPreparedParams(work, statement_name, params);
}

// ---------------------------------------------------------------------------
// waitForDatabase — used by connect() on startup to ride out the brief
// window where the DB container is still booting in docker-compose.
// ---------------------------------------------------------------------------
void Database::waitForDatabase(int max_retries, int delay_seconds) {
    for (int attempt = 1; attempt <= max_retries; ++attempt) {
        try {
            std::cout << "🔄 Database connection attempt " << attempt << "/"
                      << max_retries << std::endl;
            pqxx::connection test_conn(connection_string_);
            if (test_conn.is_open()) {
                std::cout << "✅ Database is ready" << std::endl;
                return;
            }
        } catch (const std::exception& e) {
            std::cout << "⏳ Database not ready, attempt " << attempt << ": "
                      << e.what() << std::endl;
        }

        if (attempt < max_retries) {
            std::this_thread::sleep_for(std::chrono::seconds(delay_seconds));
        }
    }
    throw std::runtime_error("Database not available after " +
                             std::to_string(max_retries) + " attempts");
}
