// =============================================================================
// LineupNotificationHub  (Phase 13 — /api/stream)
// =============================================================================
#include "LineupNotificationHub.h"

#include <pqxx/pqxx>

#include <sys/socket.h>
#include <unistd.h>

#include <cerrno>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <iostream>
#include <sstream>
#include <vector>

namespace {

// pqxx 6.x notification API: derive from notification_receiver and route the
// payload into a std::function so the hub can stay non-virtual.
class CallbackReceiver : public pqxx::notification_receiver {
public:
    CallbackReceiver(pqxx::connection_base& c,
                     const std::string& channel,
                     std::function<void(const std::string&)> cb)
        : pqxx::notification_receiver(c, channel),
          cb_(std::move(cb)) {}

    void operator()(const std::string& payload, int /*backend_pid*/) override {
        if (cb_) cb_(payload);
    }

private:
    std::function<void(const std::string&)> cb_;
};

std::string envOr(const char* name, const char* def) {
    const char* v = std::getenv(name);
    return (v && *v) ? std::string(v) : std::string(def);
}

}  // namespace

LineupNotificationHub& LineupNotificationHub::getInstance() {
    static LineupNotificationHub instance;
    return instance;
}

LineupNotificationHub::~LineupNotificationHub() {
    stop();
}

std::string LineupNotificationHub::defaultConnString() {
    std::ostringstream out;
    out << "host="     << envOr("POSTGRES_HOST",     "db")
        << " port="    << envOr("POSTGRES_PORT",     "5432")
        << " dbname="  << envOr("POSTGRES_DB",       "footballhome")
        << " user="    << envOr("POSTGRES_USER",     "footballhome_user")
        << " password="<< envOr("POSTGRES_PASSWORD", "footballhome_pass")
        // Same keepalives the main pool uses.
        << " keepalives=1 keepalives_idle=30 keepalives_interval=10 keepalives_count=3"
        << " connect_timeout=5"
        << " application_name=footballhome_backend_listener";
    return out.str();
}

void LineupNotificationHub::start(const std::string& connStr,
                                  const std::string& channel) {
    bool expected = false;
    if (!started_.compare_exchange_strong(expected, true)) return;  // already started

    connStr_ = connStr;
    channel_ = channel;
    running_ = true;
    lastHeartbeat_ = std::chrono::steady_clock::now();
    thread_ = std::thread([this]() { run(); });
}

void LineupNotificationHub::stop() {
    if (!running_.exchange(false)) return;
    if (thread_.joinable()) thread_.join();

    // Close any still-subscribed fds so client sockets aren't leaked.
    std::lock_guard<std::mutex> lk(subs_mutex_);
    for (int fd : subs_) ::close(fd);
    subs_.clear();
}

void LineupNotificationHub::subscribe(int fd) {
    std::lock_guard<std::mutex> lk(subs_mutex_);
    subs_.insert(fd);
}

void LineupNotificationHub::unsubscribe(int fd) {
    std::lock_guard<std::mutex> lk(subs_mutex_);
    subs_.erase(fd);
}

std::size_t LineupNotificationHub::subscriberCount() {
    std::lock_guard<std::mutex> lk(subs_mutex_);
    return subs_.size();
}

// -----------------------------------------------------------------------------
// Internals
// -----------------------------------------------------------------------------

void LineupNotificationHub::broadcast(const std::string& frame) {
    // Snapshot fds under lock, then send without holding the lock so a
    // slow socket can't stall other subscribers OR new subscribe()/
    // unsubscribe() calls from the request threads.
    std::vector<int> snapshot;
    {
        std::lock_guard<std::mutex> lk(subs_mutex_);
        snapshot.reserve(subs_.size());
        for (int fd : subs_) snapshot.push_back(fd);
    }
    if (snapshot.empty()) return;

    std::vector<int> dead;
    for (int fd : snapshot) {
        ssize_t n = ::send(fd, frame.data(), frame.size(), MSG_NOSIGNAL);
        if (n < 0) {
            // EPIPE / ECONNRESET / EBADF → client gone.
            dead.push_back(fd);
        } else if (static_cast<std::size_t>(n) < frame.size()) {
            // Partial write — extremely unlikely for sub-2 KiB SSE frames on
            // a healthy local socket.  Treat as dead rather than block here
            // (the listener thread must not stall on a slow consumer).
            dead.push_back(fd);
        }
    }
    if (dead.empty()) return;

    {
        std::lock_guard<std::mutex> lk(subs_mutex_);
        for (int fd : dead) subs_.erase(fd);
    }
    for (int fd : dead) ::close(fd);
}

void LineupNotificationHub::run() {
    using namespace std::chrono;

    unsigned backoffMs = 1000;

    while (running_) {
        try {
            pqxx::connection conn(connStr_);
            if (!conn.is_open()) {
                throw std::runtime_error("listener connection not open");
            }

            // Wire the receiver — it auto-installs in the connection's
            // dispatch table for its lifetime.
            CallbackReceiver receiver(conn, channel_, [this](const std::string& p) {
                std::string frame;
                frame.reserve(p.size() + 8);
                frame.append("data: ");
                frame.append(p);
                frame.append("\n\n");
                broadcast(frame);
            });

            backoffMs = 1000;  // reset on successful connect
            std::cout << "📡 LISTEN " << channel_ << " ready" << std::endl;

            while (running_) {
                // Block up to 1 s for a notification.  Returns the number
                // of notifications received (≥0).  Throws on connection
                // loss → fall through to the outer catch.
                conn.await_notification(1, 0);

                // Heartbeat every 25 s — matches Node's setInterval(25000).
                auto now = steady_clock::now();
                if (duration_cast<seconds>(now - lastHeartbeat_).count() >= 25) {
                    broadcast(": heartbeat\n\n");
                    lastHeartbeat_ = now;
                }
            }

            // Clean shutdown.
            try { conn.disconnect(); } catch (...) {}
            return;

        } catch (const std::exception& e) {
            std::cerr << "📡 LISTEN " << channel_ << " error: " << e.what()
                      << " — reconnecting in " << backoffMs << "ms" << std::endl;

            // Exponential backoff with 30 s cap.  Sleep in small slices so
            // stop() can break out promptly.
            auto deadline = steady_clock::now() + milliseconds(backoffMs);
            while (running_ && steady_clock::now() < deadline) {
                std::this_thread::sleep_for(milliseconds(100));
            }
            backoffMs = std::min<unsigned>(backoffMs * 2, 30000);
        }
    }
}
