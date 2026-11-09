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
#include "server/Rooms.hpp"

#include <cstdio>
#include <cstdlib>
#include <tuple>
#include <string>

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

    cfg.match_seed = std::strtoull(envOr("GAME_MATCH_SEED", "42"), nullptr, 10);
    std::printf("fh-game: seed=%s\n", envOr("GAME_MATCH_SEED", "42"));

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

    // Tactics trainer step 2 (server/Rooms.hpp): the live match is room 0; a practice
    // link opens a room of the viewer's own — two PL sides from a goal kick, paused.
    const server::GameServer::Config base = cfg;
    std::uint64_t practice_n = 0;
    auto practice = [&base, &practice_n](const server::PracticeAsk& ask) -> std::optional<server::GameServer::Config> {
        if (!base.db) return std::nullopt;
        server::GameServer::Config pc = base;
        const std::string hn = ask.home.empty() ? base.roster_home.name : ask.home;
        const std::string an = ask.away.empty() ? base.roster_away.name : ask.away;
        if (hn == an) return std::nullopt;
        auto home = persistence::loadDemoTeam(*base.db, hn);
        auto away = persistence::loadDemoTeam(*base.db, an);
        if (!home || !away) return std::nullopt;
        for (auto [team, spec] : {std::pair{&*home, &pc.formation_home}, std::pair{&*away, &pc.formation_away}})
            if (!team->formation_code.empty())
                if (auto f = persistence::loadFormation(*base.db, team->formation_code)) *spec = std::move(*f);
        pc.roster_home = std::move(*home);
        pc.roster_away = std::move(*away);
        pc.practice = true;
        pc.goal_kick_team = ask.goal_kick == "home" ? 0 : 1;
        ++practice_n;
        pc.match_id = base.match_id * 1000 + practice_n;
        pc.match_seed = base.match_seed + practice_n;   // each practice match its own noise
        return pc;
    };
    server::RoomRouter rooms{transport, cfg, static_cast<std::uint16_t>(speed > 0 ? speed * 100 : 0), practice};

    if (!transport.start()) {
        std::fprintf(stderr, "fh-game: failed to bind %s:%u\n",
                     tcfg.bind_address.c_str(), tcfg.port);
        return 1;
    }

    std::printf("fh-game: match %llu, %u slots, port %u, speed %dx, practice rooms on\n",
                static_cast<unsigned long long>(cfg.match_id),
                cfg.slot_count, transport.boundPort(), speed);
    std::fflush(stdout);  // container logs must see the boot line immediately

    for (;;) rooms.step();
}
