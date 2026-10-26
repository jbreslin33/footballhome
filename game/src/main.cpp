// game/src/main.cpp — fh-game match daemon
//
// One process == one match. Env config (12-factor, matches the club stack's
// conventions):
//   GAME_BIND_ADDRESS (default 0.0.0.0)   GAME_PORT (default 9200)
//   GAME_MATCH_ID (default 1)             GAME_SLOT_COUNT (default 22)
//   GAME_SPEED (default 1; 0 = headless max-speed — calibration/FM mode,
//               DESIGN.md §4: pacing lives HERE, never inside the sim).
//               An admin retunes it live (SPEED 0x31, G4.61): slow motion
//               to 5 %, fast forward to 400 %, pause — the same ticks.
//   JWT_SECRET (required — the club backend's shared HMAC secret)
//
// Wall-clock pacing deliberately uses std::chrono here, outside the sim
// loop; the World itself never sees time except as tick counts.

#include "net/WebSocketTransport.hpp"
#include "persistence/FormationStore.hpp"
#include "server/GameServer.hpp"
#include "server/MatchSetup.hpp"

#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <tuple>
#include <string>
#include <thread>

namespace {

const char* envOr(const char* name, const char* fallback) {
    const char* v = std::getenv(name);
    return (v && *v) ? v : fallback;
}

}  // namespace

int main() {
    using namespace fh::game;

    const char* secret = std::getenv("JWT_SECRET");
    if (!secret || !*secret) {
        std::fprintf(stderr, "fh-game: JWT_SECRET is required\n");
        return 1;
    }

    server::GameServer::Config cfg;
    cfg.match_id   = std::strtoull(envOr("GAME_MATCH_ID", "1"), nullptr, 10);
    cfg.slot_count = static_cast<std::uint8_t>(
        std::atoi(envOr("GAME_SLOT_COUNT", "22")));
    // Real football: 2 x 45-minute halves at real time (James, 10/22:
    // "it needs to be real football 90 minutes"). The clock is never
    // compressed FIFA-style — scorelines stay calibrated to real play.
    cfg.half_length_ticks = static_cast<std::uint32_t>(
        std::atoi(envOr("GAME_HALF_MINUTES", "45")) * 60 * core::kTickRate);
    const int speed = std::atoi(envOr("GAME_SPEED", "1"));

    // Skill levels (G4.3): u10 | u14 | amateur | semipro | pro | world |
    // perfect. The level ladder is the history ladder (DESIGN.md 5.1).
    cfg.level_home = core::levelParams(envOr("GAME_LEVEL_HOME", "amateur"));
    cfg.level_away = core::levelParams(envOr("GAME_LEVEL_AWAY", "amateur"));
    cfg.level_home_id = core::levelId(envOr("GAME_LEVEL_HOME", "amateur"));
    cfg.level_away_id = core::levelId(envOr("GAME_LEVEL_AWAY", "amateur"));
    cfg.match_seed = std::strtoull(envOr("GAME_MATCH_SEED", "42"), nullptr, 10);
    std::printf("fh-game: levels home=%s away=%s seed=%s\n",
                envOr("GAME_LEVEL_HOME", "amateur"),
                envOr("GAME_LEVEL_AWAY", "amateur"),
                envOr("GAME_MATCH_SEED", "42"));

    {
        persistence::DbConfig db;
        db.host = envOr("POSTGRES_HOST", "footballhome_db");
        db.dbname = envOr("POSTGRES_DB", "footballhome");
        db.user = envOr("POSTGRES_USER", "footballhome_user");
        db.password = envOr("POSTGRES_PASSWORD", "");
        server::MatchNames names;
        names.formation_home = envOr("GAME_FORMATION_HOME", "4-4-2");
        names.formation_away = envOr("GAME_FORMATION_AWAY", "4-3-3");
        names.team_home = envOr("GAME_TEAM_HOME", names.team_home.c_str());
        names.team_away = envOr("GAME_TEAM_AWAY", names.team_away.c_str());
        // G4.43: the same loader the match harness uses (server/MatchSetup).
        server::loadMatchFromDb(cfg, db, names, true);
    }

    auth::JwtVerifier verifier{secret};

    net::ws::WebSocketTransport::Config tcfg;
    tcfg.bind_address = envOr("GAME_BIND_ADDRESS", "0.0.0.0");
    tcfg.port = static_cast<std::uint16_t>(std::atoi(envOr("GAME_PORT", "9200")));
    net::ws::WebSocketTransport transport{tcfg, &verifier};

    server::GameServer server{cfg, transport};
    if (speed > 0) server.setSpeedPct(static_cast<std::uint16_t>(speed * 100));

    if (!transport.start()) {
        std::fprintf(stderr, "fh-game: failed to bind %s:%u\n",
                     tcfg.bind_address.c_str(), tcfg.port);
        return 1;
    }

    std::printf("fh-game: match %llu, %u slots, port %u, speed %dx\n",
                static_cast<unsigned long long>(cfg.match_id),
                cfg.slot_count, transport.boundPort(), speed);
    std::fflush(stdout);  // container logs must see the boot line immediately

    using clock = std::chrono::steady_clock;
    const auto tick_period =
        std::chrono::microseconds{1'000'000 / core::kTickRate};
    auto next = clock::now();

    for (;;) {
        // Drain the socket right up to the tick boundary, then advance.
        transport.poll(/*timeout_ms=*/0);
        // Paused (G4.61): no ticks; a frozen snapshot every 200 ms keeps
        // the clients' watchdogs quiet; the socket is drained meanwhile.
        if (speed > 0 && server.speedPct() == 0) {
            transport.poll(/*timeout_ms=*/200);
            server.heartbeat();
            next = clock::now();
            continue;
        }
        server.tickOnce();

        if (speed > 0) {
            // The live speed: the gap between ticks stretches (slow motion)
            // or shrinks (fast forward); each tick is the same tick.
            next += tick_period * 100 / server.speedPct();
            const auto now = clock::now();
            if (next > now) {
                // Wait on the socket, not a sleep: at 5 % a tick is 667 ms
                // away, and the coach's next tap must land now. A speed
                // change re-times the next tick.
                const std::uint16_t was = server.speedPct();
                for (auto t = clock::now(); t < next; t = clock::now()) {
                    const auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(next - t).count();
                    transport.poll(static_cast<int>(ms > 0 ? ms : 1));
                    if (server.speedPct() != was) { next = clock::now(); break; }
                }
            } else {
                next = now;  // fell behind — don't try to "catch up" with a burst
            }
        }
        // speed == 0: free-run (headless calibration / fast-forward).
    }
}
