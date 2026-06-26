// =============================================================================
// LineupNotificationHub  (Phase 13 — /api/stream)
// =============================================================================
//
// Mirrors the Node webhook's NOTIFY pump:
//
//   1. A dedicated pqxx::connection runs `LISTEN fh_lineups` on a background
//      thread (pqxx connections / pool slots are NOT safe to hold a LISTEN
//      reliably for long-lived use).
//   2. The trigger in database/migrations/058-lineup-change-notify.sql fires
//      `pg_notify('fh_lineups', json_payload)` on every roster/lineup change.
//   3. The hub fans each NOTIFY payload out to every subscribed socket fd as
//      an SSE frame:  `data: <payload>\n\n`.
//   4. Every 25 s the hub also sends `: heartbeat\n\n` to every subscriber to
//      keep idle connections from being closed by intermediate proxies.
//   5. Write failures (EPIPE / EBADF / etc.) are treated as client gone:
//      the fd is removed from the subscriber set and close()'d.
//
// Threading model:
//   * Exactly one background thread (`thread_`) owns the pqxx::connection
//     and is the ONLY writer to subscriber sockets.  Subscriber-set
//     mutations are protected by `subs_mutex_` and snapshotted before each
//     fan-out to keep socket writes lock-free.
//   * Reconnects use exponential backoff (1 s → 30 s cap) on
//     pqxx::broken_connection or any other pqxx exception.
//
// Lifecycle:
//   * Singleton; `start(connStr)` is idempotent (no-op on second call).
//   * No explicit stop in normal operation — the hub lives for the whole
//     process and the subscriber thread detaches on `stop()` if needed.
//
// =============================================================================
#pragma once

#include <atomic>
#include <chrono>
#include <mutex>
#include <set>
#include <string>
#include <thread>

class LineupNotificationHub {
public:
    static LineupNotificationHub& getInstance();

    // Build the listener connection string from the same env vars Node uses
    // (POSTGRES_HOST / _PORT / _DB / _USER / _PASSWORD) with identical
    // defaults.  Returned string is suitable for pqxx::connection.
    static std::string defaultConnString();

    // Spawn the listener thread.  Safe to call multiple times — only the
    // first call has effect.  `connStr` is libpq key=value form.
    void start(const std::string& connStr,
               const std::string& channel = "fh_lineups");

    // Register a fd to receive SSE frames.  The hub takes co-ownership: when
    // the client disconnects (detected on write failure) the hub will
    // unsubscribe AND close(fd).
    void subscribe(int fd);

    // Remove a fd from the subscriber set without closing it.  Used only by
    // the hub itself on write failure (caller is expected to close), or by
    // an external party that wants to keep the fd alive (no current use).
    void unsubscribe(int fd);

    // Snapshot of current subscriber count — handy for /health-style probes.
    std::size_t subscriberCount();

    // Stop the listener thread (used in tests / shutdown).  Idempotent.
    void stop();

private:
    LineupNotificationHub() = default;
    ~LineupNotificationHub();
    LineupNotificationHub(const LineupNotificationHub&) = delete;
    LineupNotificationHub& operator=(const LineupNotificationHub&) = delete;

    // The main listener loop — owns its own pqxx::connection.
    void run();

    // Write `frame` to every subscriber; drop subscribers whose fd is dead.
    // Called from the listener thread ONLY.
    void broadcast(const std::string& frame);

    std::thread       thread_;
    std::atomic<bool> running_{false};
    std::atomic<bool> started_{false};

    std::mutex     subs_mutex_;
    std::set<int>  subs_;

    std::string connStr_;
    std::string channel_;

    std::chrono::steady_clock::time_point lastHeartbeat_{};
};
