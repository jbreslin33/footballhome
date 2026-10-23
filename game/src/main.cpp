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
        // G4.37: the curriculum first — rosters and presets name concepts.
        // A DB that renumbered a wired concept is refused (ids are wire
        // format and every saved rating keys on them).
        if (auto reg = persistence::loadConcepts(db)) {
            const core::ConceptRegistry wired = core::ConceptRegistry::builtin();
            bool same = true;
            for (int i = 0; i < wired.size(); ++i)
                if (reg->name(i) != wired.name(i)) {
                    std::fprintf(stderr, "fh-game: game_concepts id %d is '%s', wired '%s' — REFUSED, builtin curriculum kept\n",
                                 i, reg->name(i).c_str(), wired.name(i).c_str());
                    same = false;
                }
            if (same) {
                std::printf("fh-game: %d concept(s) in the curriculum (club DB)\n", reg->size());
                core::setConcepts(std::move(*reg));
            }
        }
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
        cfg.admin_user_ids = persistence::loadAdminUserIds(db);
        cfg.db = db;   // G4.32: admin RELOAD_ROSTERS re-reads the teams
        cfg.model_params = persistence::loadModelParams(db);   // G4.33
        std::printf("fh-game: %zu game-model param(s) loaded\n", cfg.model_params.size());
        // Fictional demo rosters (mig 628): named players filling the
        // ladder. A roster's band OVERRIDES GAME_LEVEL_* defaults.
        const char* th = envOr("GAME_TEAM_HOME", "Lighthouse XI");
        const char* ta = envOr("GAME_TEAM_AWAY", "Harbor Athletic");
        if (auto t = persistence::loadDemoTeam(db, th)) {
            cfg.roster_home = std::move(*t);
            cfg.level_home = core::levelParams(cfg.roster_home.level_band);
            cfg.level_home_id = core::levelId(cfg.roster_home.level_band);
            std::printf("fh-game: home roster %s (%s%s%s)\n", th,
                        cfg.roster_home.level_band.c_str(),
                        cfg.roster_home.game_model.empty() ? ""
                                                           : ", plays ",
                        cfg.roster_home.game_model.c_str());
        }
        if (auto t = persistence::loadDemoTeam(db, ta)) {
            cfg.roster_away = std::move(*t);
            cfg.level_away = core::levelParams(cfg.roster_away.level_band);
            cfg.level_away_id = core::levelId(cfg.roster_away.level_band);
            std::printf("fh-game: away roster %s (%s%s%s)\n", ta,
                        cfg.roster_away.level_band.c_str(),
                        cfg.roster_away.game_model.empty() ? ""
                                                           : ", plays ",
                        cfg.roster_away.game_model.c_str());
        }
        // Mig 636: a roster that names its formation plays it (Ukies 4-2-3-1,
        // Lighthouse APSL 4-3-3), over GAME_FORMATION_*.
        for (auto [roster, spec, side] :
             {std::tuple{&cfg.roster_home, &cfg.formation_home, "home"},
              std::tuple{&cfg.roster_away, &cfg.formation_away, "away"}}) {
            if (roster->formation_code.empty()) continue;
            if (auto f = persistence::loadFormation(db, roster->formation_code)) {
                *spec = std::move(*f);
                std::printf("fh-game: %s formation %s (the team's own)\n", side,
                            roster->formation_code.c_str());
            }
        }
        // Game models (mig 652): schools, federations, formations, teams.
        cfg.models = persistence::loadGameModels(db);
        std::printf("fh-game: %zu admin user(s), %zu game model(s) loaded\n",
                    cfg.admin_user_ids.size(), cfg.models.size());
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
