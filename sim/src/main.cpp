// footballhome sim - process entrypoint
//
// M0 bootstrap:
//   * Reads JWT_SECRET, SIM_BIND_ADDRESS, SIM_PORT, SIM_MATCH_SEED,
//     SIM_MATCH_ID from the env (all with sensible defaults except
//     JWT_SECRET which is required).
//   * Constructs JwtVerifier + WebSocketTransport + EmptyPitchScenario
//     + Match + BinaryV1Serializer + SimServer.
//   * Installs SIGINT/SIGTERM handlers that call SimServer::stop().
//   * Runs the sim loop forever (or until stop).
//
// No exceptions escape main(); every construction failure prints to
// stderr and exits with a non-zero code.

#include "auth/JwtVerifier.hpp"
#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "net/BinaryV1Serializer.hpp"
#include "net/WebSocketTransport.hpp"
#include "physics/StubPhysics.hpp"
#include "scenario/EmptyPitchScenario.hpp"
#include "server/SimServer.hpp"

#include <atomic>
#include <chrono>
#include <csignal>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <string>

namespace {

// Global stop signal so signal handlers can reach the server without
// std::function or heap allocations. Set to non-null only while run()
// is executing.
std::atomic<fh::sim::server::SimServer*> g_server{nullptr};

extern "C" void handleSignal(int /*sig*/) noexcept
{
    auto* srv = g_server.load(std::memory_order_relaxed);
    if (srv != nullptr) { srv->stop(); }
}

const char* envOr(const char* name, const char* fallback) noexcept
{
    const char* v = std::getenv(name);
    return (v != nullptr && v[0] != '\0') ? v : fallback;
}

std::uint16_t parsePort(const char* s) noexcept
{
    if (s == nullptr) { return 0; }
    const long v = std::strtol(s, nullptr, 10);
    if (v < 0 || v > 0xFFFF) { return 0; }
    return static_cast<std::uint16_t>(v);
}

std::uint64_t parseU64(const char* s, std::uint64_t fallback) noexcept
{
    if (s == nullptr || s[0] == '\0') { return fallback; }
    char* end = nullptr;
    const unsigned long long v = std::strtoull(s, &end, 10);
    if (end == s) { return fallback; }
    return static_cast<std::uint64_t>(v);
}

std::int64_t nowSecs() noexcept
{
    using namespace std::chrono;
    return duration_cast<seconds>(
        system_clock::now().time_since_epoch()).count();
}

} // namespace

int main(int /*argc*/, char** /*argv*/)
{
    // ------------------------------------------------------------------
    // Config
    // ------------------------------------------------------------------
    const char* secret_c = std::getenv("JWT_SECRET");
    if (secret_c == nullptr || secret_c[0] == '\0') {
        std::fprintf(stderr, "footballhome_sim: JWT_SECRET is required\n");
        return 2;
    }
    const std::string jwt_secret{secret_c};

    const std::string  bind_addr{envOr("SIM_BIND_ADDRESS", "0.0.0.0")};
    const std::uint16_t port     = parsePort(envOr("SIM_PORT", "9100"));
    const std::uint64_t match_id = parseU64(std::getenv("SIM_MATCH_ID"),   1);
    const std::uint64_t seed     = parseU64(std::getenv("SIM_MATCH_SEED"), 42);

    // ------------------------------------------------------------------
    // Dependencies
    // ------------------------------------------------------------------
    auto verifier = std::make_unique<fh::sim::auth::JwtVerifier>(
        jwt_secret, &nowSecs);

    fh::sim::net::ws::WebSocketTransport::Config tx_cfg;
    tx_cfg.bind_address = bind_addr;
    tx_cfg.port         = port;
    auto transport = std::make_unique<fh::sim::net::ws::WebSocketTransport>(
        tx_cfg, verifier.get());

    if (!transport->start()) {
        std::fprintf(stderr,
                     "footballhome_sim: failed to bind %s:%u\n",
                     bind_addr.c_str(),
                     static_cast<unsigned>(port));
        return 3;
    }

    // Match ------------------------------------------------------------
    fh::sim::match::MatchConfig mcfg;
    mcfg.id       = match_id;
    mcfg.seed     = seed;
    mcfg.physics  = std::make_unique<fh::sim::physics::StubPhysics>();
    mcfg.scenario = std::make_unique<fh::sim::scenario::EmptyPitchScenario>();
    mcfg.clock    = std::make_unique<fh::sim::match::RealtimeClock>(20);
    auto match = std::make_unique<fh::sim::match::Match>(std::move(mcfg));

    auto serializer = std::make_unique<fh::sim::net::BinaryV1Serializer>();

    // Server -----------------------------------------------------------
    fh::sim::server::SimServer::Config scfg;
    scfg.tick_hz  = 20;
    scfg.match_id = match_id;

    fh::sim::server::SimServer server(scfg,
                                      std::move(transport),
                                      std::move(serializer),
                                      std::move(match));

    // ------------------------------------------------------------------
    // Signals
    // ------------------------------------------------------------------
    g_server.store(&server, std::memory_order_relaxed);

    struct sigaction sa{};
    sa.sa_handler = handleSignal;
    ::sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;   // deliberately NOT SA_RESTART: poll() returning
                       // EINTR is fine and gives us a natural loop wake.
    ::sigaction(SIGINT,  &sa, nullptr);
    ::sigaction(SIGTERM, &sa, nullptr);

    // Broken-pipe on send() is handled by MSG_NOSIGNAL inside the
    // transport; still, ignore SIGPIPE globally to be safe.
    struct sigaction ign{};
    ign.sa_handler = SIG_IGN;
    ::sigaction(SIGPIPE, &ign, nullptr);

    std::fprintf(stderr,
                 "footballhome_sim: listening on %s:%u  match=%llu  seed=%llu\n",
                 bind_addr.c_str(),
                 static_cast<unsigned>(port),
                 static_cast<unsigned long long>(match_id),
                 static_cast<unsigned long long>(seed));

    server.run();

    g_server.store(nullptr, std::memory_order_relaxed);

    std::fprintf(stderr, "footballhome_sim: shutdown complete\n");
    return 0;
}
