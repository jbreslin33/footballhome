// game/src/main.cpp — fh-game match daemon
//
// One process == one match. Env config (12-factor, matches the club stack's
// conventions):
//   GAME_BIND_ADDRESS (default 0.0.0.0)   GAME_PORT (default 9200)
//   GAME_MATCH_ID (default 1)             GAME_SLOT_COUNT (default 22)
//   GAME_SPEED (default 1; 0 = headless max-speed — calibration/FM mode,
//               DESIGN.md §4: pacing lives HERE, never inside the sim)
//   JWT_SECRET (required — the club backend's shared HMAC secret)
//
// Wall-clock pacing deliberately uses std::chrono here, outside the sim
// loop; the World itself never sees time except as tick counts.

#include "net/WebSocketTransport.hpp"
#include "persistence/FormationStore.hpp"
#include "server/GameServer.hpp"

#include <chrono>
#include <cstdio>
#include <cstdlib>
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
    // 5-minute halves by default on the sandbox match — long enough to
    // feel like a game, short enough that a visitor sees a full cycle.
    cfg.half_length_ticks = static_cast<std::uint32_t>(
        std::atoi(envOr("GAME_HALF_MINUTES", "5")) * 60 * core::kTickRate);
    const int speed = std::atoi(envOr("GAME_SPEED", "1"));

    // Skill levels (G4.3): u10 | u14 | amateur | semipro | pro | world |
    // perfect. The level ladder is the history ladder (DESIGN.md 5.1).
    cfg.level_home = core::levelParams(envOr("GAME_LEVEL_HOME", "amateur"));
    cfg.level_away = core::levelParams(envOr("GAME_LEVEL_AWAY", "amateur"));
    cfg.match_seed = std::strtoull(envOr("GAME_MATCH_SEED", "42"), nullptr, 10);
    std::printf("fh-game: levels home=%s away=%s seed=%s\n",
                envOr("GAME_LEVEL_HOME", "amateur"),
                envOr("GAME_LEVEL_AWAY", "amateur"),
                envOr("GAME_MATCH_SEED", "42"));

    // Formations come from the club's own `formations` table (open system:
    // rows added on the club page become playable AI shapes). DB down or
    // code unknown = loud log + built-in shapes; the sandbox always boots.
    {
        persistence::DbConfig db;
        db.host = envOr("POSTGRES_HOST", "footballhome_db");
        db.dbname = envOr("POSTGRES_DB", "footballhome");
        db.user = envOr("POSTGRES_USER", "footballhome_user");
        db.password = envOr("POSTGRES_PASSWORD", "");
        const char* home_code = envOr("GAME_FORMATION_HOME", "4-4-2");
        const char* away_code = envOr("GAME_FORMATION_AWAY", "4-3-3");
        if (auto f = persistence::loadFormation(db, home_code)) {
            cfg.formation_home = std::move(*f);
            std::printf("fh-game: home formation %s (club DB)\n", home_code);
        } else {
            std::printf("fh-game: home formation FALLBACK (built-in)\n");
        }
        if (auto f = persistence::loadFormation(db, away_code)) {
            cfg.formation_away = std::move(*f);
            std::printf("fh-game: away formation %s (club DB)\n", away_code);
        } else {
            std::printf("fh-game: away formation FALLBACK (built-in)\n");
        }
    }

    auth::JwtVerifier verifier{secret};

    net::ws::WebSocketTransport::Config tcfg;
    tcfg.bind_address = envOr("GAME_BIND_ADDRESS", "0.0.0.0");
    tcfg.port = static_cast<std::uint16_t>(std::atoi(envOr("GAME_PORT", "9200")));
    net::ws::WebSocketTransport transport{tcfg, &verifier};

    server::GameServer server{cfg, transport};

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
        server.tickOnce();

        if (speed > 0) {
            next += tick_period / speed;
            const auto now = clock::now();
            if (next > now) {
                std::this_thread::sleep_until(next);
            } else {
                next = now;  // fell behind — don't try to "catch up" with a burst
            }
        }
        // speed == 0: free-run (headless calibration / fast-forward).
    }
}
