// footballhome sim — AdminHttpServer
//
// Purpose
// -------
// Serves a single internal admin RPC — `POST /admin/replay` — that
// runs `tools::replayMatch()` for the requested match and returns the
// canonical FNV-1a-64 snapshot hash. Callable ONLY from inside the
// container network; the `footballhome_backend` container proxies to
// it via `GET /api/sim/debug/matches/:id/state?tick=T`
// (SimDebugController::handleState).
//
// This file is the reason DESIGN.md §16.6 sub-slice 8.1 exists — it
// closes the "how do we serve /state?tick=T from a container that
// doesn't own the sim binary?" question with the industry-standard
// answer: **an internal RPC endpoint on the sim daemon itself**, over
// plain HTTP/1.1 + JSON on the compose network. No cross-container
// binary bundling. No podman-socket sharing. No shared filesystem.
//
// -----------------------------------------------------------------------
// Wire protocol
// -----------------------------------------------------------------------
// Request:
//
//   POST /admin/replay HTTP/1.1
//   Host: footballhome_sim:9101
//   Authorization: Bearer <FH_SIM_ADMIN_TOKEN>
//   Content-Type: application/json
//   Content-Length: N
//
//   {"match_id": 123, "up_to_tick": 6969, "emit_hex": false}
//
//   Fields:
//     match_id     u64,     REQUIRED
//     up_to_tick   u32,     optional (default: MatchEnd tick)
//     emit_hex     bool,    optional (default: false)
//
// Success response (HTTP 200):
//
//   Content-Type: application/json; charset=utf-8
//
//   {
//     "match_id":          123,
//     "final_tick":        6969,
//     "hash_hex":          "0x4004d2933dc960e5",
//     "hash_u64":          4613043448172863717,
//     "inputs_applied":    1234,
//     "slots_synthesized": 3,
//     "canonical_hex":     "..."     // only present when emit_hex=true
//   }
//
// Error responses (all `application/json; charset=utf-8`):
//
//   400 {"error":"bad request",     "detail":"<why>"}   — parse/validation
//   401 {"error":"unauthorized"}                        — missing bearer
//   403 {"error":"forbidden"}                           — wrong token
//   404 {"error":"match not found", "match_id":N}       — no such match
//   405 {"error":"method not allowed"}                  — not POST
//   408 {"error":"request timeout"}                     — slow reader
//   413 {"error":"payload too large"}                   — body > 16 KiB
//   500 {"error":"internal error",  "detail":"<why>"}   — DB / replay
//
// -----------------------------------------------------------------------
// Auth model
// -----------------------------------------------------------------------
// Shared secret from env var `FH_SIM_ADMIN_TOKEN`, present in BOTH
// `footballhome_sim` and `footballhome_backend` environments. The sim
// side is the authenticator; the backend side is the caller.
//
//   * Empty / missing token in sim env → AdminHttpServer::start()
//     returns false; the endpoint is unavailable (fail-closed). The
//     backend's `/state?tick=T` will fall through to a 502-shaped
//     response documenting that the sim admin surface is disabled.
//   * Any request without an `Authorization: Bearer …` header → 401.
//   * Any request whose token does not equal the configured token,
//     compared in constant time (§13-style timing-oracle avoidance) → 403.
//
// Tokens are opaque. Rotation = redeploy both services with a new value.
//
// -----------------------------------------------------------------------
// Threading & lifetime
// -----------------------------------------------------------------------
// * `start()` spawns ONE background std::thread that runs an accept
//   loop against a listen socket bound to `Config::bind_address` :
//   `Config::port` (default `0.0.0.0:9101`).
// * The loop is single-request-at-a-time: while a replay is running
//   for one caller, other TCP connects park in the listen backlog.
//   Replay is CPU-heavy and DB-heavy; parallelising would need a
//   PgClient pool and would trade throughput of a debug endpoint for
//   complexity. This is a debug surface, not a hot path — one at a
//   time is exactly right.
// * `stop()` shuts down the listen socket + joins the worker thread.
//   Safe to call from a signal handler in the sim main thread; the
//   accept loop notices the closed fd and exits within one poll cycle.
// * The server owns its own `IPgClient` (typically a dedicated
//   PgClient — a fresh Postgres connection). It does NOT share the
//   main sim daemon's connection: replay reads the same tables that
//   the tick loop writes to via the async input/event logs, so
//   isolating connections avoids libpqxx thread-safety concerns
//   entirely (per DESIGN.md §22.12 decision #4: one connection per
//   thread).
//
// -----------------------------------------------------------------------
// Body size / timeout limits
// -----------------------------------------------------------------------
// * Max request bytes (headers + body): `kMaxRequestBytes` (16 KiB).
//   Larger → 413.
// * Read timeout per request: `Config::read_timeout_ms` (default
//   5 000 ms). Slow reader → 408.
// * Replay runtime is NOT capped — a legitimate long match may need
//   several seconds. Callers (backend) should set their own libcurl
//   timeout appropriate to expected match length.
//
// -----------------------------------------------------------------------
// Non-goals
// -----------------------------------------------------------------------
// * No TLS. The socket is bound to the container network only; the
//   compose file never publishes port 9101 to the host. Adding TLS
//   here would require in-container cert rotation for zero security
//   benefit inside the compose bridge network.
// * No connection reuse / keepalive. Every request opens + closes a
//   TCP connection. Debug surface, low volume; simplicity wins.
// * No request logging beyond one stderr line per request
//   (`method path status person_id_or_dash duration_ms`). Access
//   logging at the sim layer would duplicate what the backend
//   already logs when it proxies.
// -----------------------------------------------------------------------

#pragma once

#include "common/IdTypes.hpp"
#include "persistence/IPgClient.hpp"

#include <atomic>
#include <cstddef>
#include <cstdint>
#include <memory>
#include <optional>
#include <string>
#include <thread>

namespace fh::sim::admin {

// Hard cap on the total request byte count (request line + headers +
// body). Kept tight because the only known request shape is ~80 bytes.
inline constexpr std::size_t kMaxRequestBytes = 16u * 1024u;

class AdminHttpServer {
public:
    struct Config {
        // Address/port to bind. Port 0 requests an ephemeral port
        // (used by tests via `boundPort()`).
        std::string   bind_address     = "0.0.0.0";
        std::uint16_t port             = 9101;

        // listen(2) backlog. Small on purpose — a debug endpoint
        // should never see meaningful queue depth.
        int           backlog          = 8;

        // Per-request read timeout (headers + body). Applied via
        // SO_RCVTIMEO on the accepted socket. 0 disables (test-only).
        int           read_timeout_ms  = 5'000;

        // Same for writes.
        int           write_timeout_ms = 5'000;

        // Shared secret — MUST be non-empty for start() to succeed.
        // Compared against `Authorization: Bearer <token>` in constant
        // time on every request.
        std::string   admin_token;
    };

    // Constructor is trivial — start() is where sockets open, threads
    // spawn, and error handling lives. Rationale: tests want to build
    // and inspect the object without side-effects.
    //
    // `db` MUST outlive the server. Typically the caller constructs a
    // dedicated `PgClient` for the admin server and hands it in.
    AdminHttpServer(const Config& cfg, persistence::IPgClient& db);

    // Deletes copy + move so the accept-loop thread can safely
    // capture `this`.
    AdminHttpServer(const AdminHttpServer&)            = delete;
    AdminHttpServer& operator=(const AdminHttpServer&) = delete;
    AdminHttpServer(AdminHttpServer&&)                 = delete;
    AdminHttpServer& operator=(AdminHttpServer&&)      = delete;

    // Auto-stops on destruction if still running.
    ~AdminHttpServer();

    // Opens the listen socket, spawns the accept loop thread, and
    // returns true. Returns false and leaves the object safely
    // stopped if:
    //   * Config::admin_token is empty (auth cannot be enforced)
    //   * socket / bind / listen fails
    // In every failure case a diagnostic is written to stderr with
    // the `[sim-admin]` prefix.
    bool start();

    // Signals the accept loop to exit and joins the worker thread.
    // Idempotent — safe to call multiple times and safe to call
    // when start() was never invoked or failed.
    void stop() noexcept;

    // The actual port the socket is listening on (useful when
    // Config::port == 0). Returns 0 before start() succeeds or after
    // stop().
    std::uint16_t boundPort() const noexcept { return bound_port_; }

    // Whether the accept loop is currently running.
    bool running() const noexcept { return running_.load(std::memory_order_acquire); }

private:
    // Accept loop body — runs on the worker thread.
    void acceptLoop();

    // Handles one accepted client fd end-to-end: read → parse →
    // authenticate → dispatch → write → close. All errors terminate
    // the connection; nothing propagates back to the accept loop.
    void handleConnection(int client_fd) noexcept;

    Config                     cfg_;
    persistence::IPgClient&    db_;

    int                        listen_fd_   = -1;
    std::uint16_t              bound_port_  = 0;
    std::atomic<bool>          running_{false};
    std::atomic<bool>          stopping_{false};
    std::thread                worker_;
};

// -----------------------------------------------------------------------
// Free functions exposed for testing (declared here so tests link
// against the same object file). Not part of the public admin API.
// -----------------------------------------------------------------------

// Parses an HTTP/1.1 request into method / path / body. Recognises
// `Authorization`, `Content-Type`, and `Content-Length` headers. Returns
// std::nullopt on any of: missing "\r\n\r\n" terminator, missing
// Content-Length when Content-Length would be needed, body length
// mismatch, or oversized total.
struct ParsedRequest {
    std::string method;
    std::string path;
    std::string authorization;   // full value after "Authorization: "
    std::string content_type;    // full value after "Content-Type: "
    std::string body;            // raw bytes
};
std::optional<ParsedRequest>
parseHttpRequest(std::string_view raw, std::string* reject_reason = nullptr);

// Parses the JSON payload of /admin/replay. Deliberately hand-rolled:
// the schema has three fields and adding a JSON library dependency
// for one endpoint isn't justified. Any deviation from the exact
// {"match_id":N,"up_to_tick":T,"emit_hex":B} shape (whitespace ok)
// returns std::nullopt.
struct ReplayRequest {
    MatchId                   match_id{0};
    std::optional<TickNum>    up_to_tick{};
    bool                      emit_hex{false};
};
std::optional<ReplayRequest>
parseReplayJson(std::string_view body, std::string* reject_reason = nullptr);

// Constant-time byte comparison. Returns true iff a and b have the
// same size and equal contents. Uses XOR-accumulate — no early exit,
// no branch on data.
bool constantTimeEquals(std::string_view a, std::string_view b) noexcept;

} // namespace fh::sim::admin
