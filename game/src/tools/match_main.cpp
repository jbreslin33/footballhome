// game/src/tools/match_main.cpp — fh-game-match (G4.43)
//
// James: "yes" to "a version that loads both real teams from the database".
// fh-game-calibrate measures ratings typed on its command line; this runs
// the REAL matchup through the same path the live daemon uses
// (server::loadMatchFromDb → GameServer with a no-op network): the squads,
// game models, qualities, attributes, hand edits, formations, settings and
// curriculum, as they are in the club DB right now.
//
//   fh-game-match [matches=30] [minutes=90] [home:concept=demand,...|-] [away:...|-]
//
// Overrides change a team's game-model DEMAND for one run (A/B a concept on
// the real matchup), e.g. "home:blind-side-run=0"; "home:!marking" drops
// the players' own ABILITY rows for that concept (they fall back to their
// quality); "home:~direct-ball" drops their TENDENCY rows for it (G4.47).
// The DB is never written.
// Env: POSTGRES_HOST (localhost from the host), POSTGRES_DB, POSTGRES_USER,
// POSTGRES_PASSWORD, GAME_TEAM_HOME / GAME_TEAM_AWAY.
//
// Each match uses seed base+m, so N matches are a fixed sample: the same
// DB gives the same numbers, and any difference IS a change.

#include "core/Clock.hpp"
#include "net/INetworkTransport.hpp"
#include "server/GameServer.hpp"
#include "server/MatchSetup.hpp"

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

using namespace fh::game;

namespace {

const char* envOr(const char* name, const char* fallback) {
    const char* v = std::getenv(name);
    return v && *v ? v : fallback;
}

// No clients, no I/O: the server just plays.
class NullTransport : public net::INetworkTransport {
public:
    void setOnConnect(OnConnectFn) override {}
    void setOnDisconnect(OnDisconnectFn) override {}
    void setOnMessage(OnMessageFn) override {}
    bool send(ClientId, std::span<const std::uint8_t>) override { return true; }
    void disconnect(ClientId) override {}
    std::size_t clientCount() const override { return 0; }
    void poll(int) override {}
};

// "home:blind-side-run=0,pass-ladder=50" → demand overrides on that side's model.
void applyOverrides(server::GameServer::Config& cfg, const char* spec, bool home) {
    if (!spec || !std::strcmp(spec, "-")) return;
    std::string s = spec;
    const std::string prefix = home ? "home:" : "away:";
    if (s.rfind(prefix, 0) != 0) {
        std::fprintf(stderr, "override '%s' must start with %s\n", spec, prefix.c_str());
        std::exit(2);
    }
    s = s.substr(prefix.size());
    const std::string& model = home ? cfg.roster_home.game_model : cfg.roster_away.game_model;
    persistence::GameModel* gm = nullptr;
    for (auto& m : cfg.models)
        if (m.name == model) gm = &m;
    if (!gm) {
        std::fprintf(stderr, "the %s team plays no game model; nothing to override\n", home ? "home" : "away");
        std::exit(2);
    }
    std::size_t at = 0;
    while (at < s.size()) {
        std::size_t end = s.find(',', at);
        if (end == std::string::npos) end = s.size();
        const std::string item = s.substr(at, end - at);
        if (!item.empty() && item[0] == '~') {
            const int id = core::concepts().find(item.substr(1));
            if (id < 0) { std::fprintf(stderr, "unknown concept '%s'\n", item.c_str() + 1); std::exit(2); }
            auto& team = home ? cfg.roster_home : cfg.roster_away;
            int dropped = 0;
            for (auto& p : team.players)
                for (auto it = p.tendencies.begin(); it != p.tendencies.end();)
                    if (it->first == id) { it = p.tendencies.erase(it); ++dropped; } else ++it;
            std::printf("override: %s tendency rows for %s dropped (%d)\n", model.c_str(), item.c_str() + 1, dropped);
            at = end + 1;
            continue;
        }
        if (!item.empty() && item[0] == '!') {
            const int id = core::concepts().find(item.substr(1));
            if (id < 0) { std::fprintf(stderr, "unknown concept '%s'\n", item.c_str() + 1); std::exit(2); }
            auto& team = home ? cfg.roster_home : cfg.roster_away;
            int dropped = 0;
            for (auto& p : team.players)
                for (auto it = p.concepts.begin(); it != p.concepts.end();)
                    if (it->first == id) { it = p.concepts.erase(it); ++dropped; } else ++it;
            std::printf("override: %s ability rows for %s dropped (%d)\n", model.c_str(), item.c_str() + 1, dropped);
            at = end + 1;
            continue;
        }
        const std::size_t eq = item.find('=');
        const int id = core::concepts().find(item.substr(0, eq));
        if (eq == std::string::npos || id < 0) {
            std::fprintf(stderr, "unknown override '%s'\n", item.c_str());
            std::exit(2);
        }
        gm->overlay[id] = static_cast<std::int16_t>(std::atoi(item.c_str() + eq + 1));
        std::printf("override: %s %s demand = %d\n", model.c_str(), item.substr(0, eq).c_str(), gm->overlay[id]);
        at = end + 1;
    }
}

}  // namespace

int main(int argc, char** argv) {
    const int matches = argc > 1 ? std::atoi(argv[1]) : 30;
    const int minutes = argc > 2 ? std::atoi(argv[2]) : 90;

    server::GameServer::Config base{};
    base.match_id = 1;
    base.slot_count = 22;
    persistence::DbConfig db;
    db.host = envOr("POSTGRES_HOST", "localhost");
    db.dbname = envOr("POSTGRES_DB", "footballhome");
    db.user = envOr("POSTGRES_USER", "footballhome_user");
    db.password = envOr("POSTGRES_PASSWORD", "");
    server::MatchNames names;
    names.team_home = envOr("GAME_TEAM_HOME", names.team_home.c_str());
    names.team_away = envOr("GAME_TEAM_AWAY", names.team_away.c_str());
    server::loadMatchFromDb(base, db, names, true);
    applyOverrides(base, argc > 3 ? argv[3] : "-", true);
    applyOverrides(base, argc > 4 ? argv[4] : "-", false);

    const long ticks = static_cast<long>(minutes) * 60 * core::kTickRate;
    const std::uint64_t seed0 = std::strtoull(envOr("GAME_MATCH_SEED", "1000"), nullptr, 10);
    int w = 0, d = 0, l = 0;
    long gh = 0, ga = 0;
    std::vector<int> margins;
    for (int m = 0; m < matches; ++m) {
        server::GameServer::Config cfg = base;
        cfg.match_seed = seed0 + static_cast<std::uint64_t>(m);
        NullTransport t;
        server::GameServer s{cfg, t};
        for (long k = 0; k < ticks; ++k) s.tickOnce();
        const int h = s.world().score(0), a = s.world().score(1);
        gh += h; ga += a;
        margins.push_back(h - a);
        (h > a ? w : (h == a ? d : l))++;
        std::printf("match %2d: %s %d - %d %s\n", m + 1, names.team_home.c_str(), h, a, names.team_away.c_str());
    }
    double mean = 0, var = 0;
    for (int x : margins) mean += x;
    mean /= margins.size();
    for (int x : margins) var += (x - mean) * (x - mean);
    const double se = margins.size() > 1 ? std::sqrt(var / (margins.size() - 1) / margins.size()) : 0.0;
    std::printf("\n%s vs %s over %d matches: W%d D%d L%d | goals %.2f - %.2f | margin %+.2f ± %.2f (1 SE)\n",
                names.team_home.c_str(), names.team_away.c_str(), matches, w, d, l,
                static_cast<double>(gh) / matches, static_cast<double>(ga) / matches, mean, se);
    return 0;
}
