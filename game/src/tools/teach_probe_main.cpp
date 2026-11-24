// game/src/tools/teach_probe_main.cpp — fh-teach-probe: a teaching room, headless.
//
// Loads a club tactic plan and two teams from the DB exactly as the daemon's teaching
// room does (docs/teaching-room.md), plays their goal kick for N seconds with no network,
// and prints, at the freeze and every few seconds: the plan step the room is on and, for
// each outfielder of ours, his number, whether he is on his plan job, how far he is from
// his spot, and the man his job names. A read of the room, not a benchmark.
//
//   POSTGRES_HOST=localhost POSTGRES_PASSWORD=… fh-teach-probe <plan_id> [seconds] [us team] [them team]

#include "persistence/FormationStore.hpp"
#include "server/MatchSetup.hpp"
#include "teach/TeachingPlan.hpp"
#include "teach/TeachingServer.hpp"

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <string>

using namespace fh::game;

namespace {

const char* envOr(const char* k, const char* d) {
    const char* v = std::getenv(k);
    return v && *v ? v : d;
}

class NullTransport final : public net::INetworkTransport {
public:
    void setOnConnect(OnConnectFn) override {}
    void setOnDisconnect(OnDisconnectFn) override {}
    void setOnMessage(OnMessageFn) override {}
    bool send(ClientId, std::span<const std::uint8_t>) override { return true; }
    void disconnect(ClientId) override {}
    std::size_t clientCount() const override { return 0; }
    void poll(int) override {}
};

void print(const teach::TeachingServer& s, const char* when) {
    const auto& w = s.world();
    const auto& b = w.ball();
    std::printf("\n%s  t=%.1fs  step %d  ball (%.1f, %.1f) %s\n", when, w.tickCount() / 30.0, s.stateId(),
                b.pos.x.toDouble(), b.pos.y.toDouble(),
                b.owner ? ("with their/our slot " + std::to_string(*b.owner)).c_str()
                        : (w.restartTeam() != 0xFF ? "dead" : "loose"));
    const auto& orders = s.lastOrders();
    for (std::uint8_t i = 0; i < 11 && i < orders.size(); ++i) {
        const auto& me = w.player(i);
        const double dx = orders[i].target.x.toDouble() - me.pos.x.toDouble();
        const double dy = orders[i].target.y.toDouble() - me.pos.y.toDouble();
        std::printf("  our #%-2d %-8s at (%6.1f, %6.1f)  %5.1f m off his spot  why=%-18s on #%d\n", s.brain().numberOf(i),
                    s.onJob(i) ? "PLAN" : "engine", me.pos.x.toDouble(), me.pos.y.toDouble(), std::hypot(dx, dy),
                    ai::kWhyNames[static_cast<int>(orders[i].why)],
                    orders[i].other >= 0 ? s.brain().numberOf(static_cast<core::SlotIndex>(orders[i].other)) : 0);
    }
}

}  // namespace

int main(int argc, char** argv) {
    if (argc < 2) { std::fprintf(stderr, "usage: fh-teach-probe <plan_id> [seconds] [us team] [them team]\n"); return 2; }
    const int plan_id = std::atoi(argv[1]);
    const int seconds = argc > 2 ? std::atoi(argv[2]) : 20;
    persistence::DbConfig db;
    db.host = envOr("POSTGRES_HOST", "localhost");
    db.dbname = envOr("POSTGRES_DB", "footballhome");
    db.user = envOr("POSTGRES_USER", "footballhome_user");
    db.password = envOr("POSTGRES_PASSWORD", "");
    server::GameServer::Config cfg;
    server::MatchNames names;
    names.team_home = argc > 3 ? argv[3] : "West Ham United";
    names.team_away = argc > 4 ? argv[4] : "Arsenal";
    server::loadMatchFromDb(cfg, db, names, false);
    auto plan = teach::loadPlan(db, plan_id);
    if (!plan) { std::fprintf(stderr, "plan %d did not load\n", plan_id); return 1; }
    std::printf("plan %d: %s v %s, %s block, %zu step(s)\n", plan->id, plan->us_code.c_str(), plan->them_code.c_str(),
                plan->block.c_str(), plan->states.size());
    cfg.match_seed = 42;
    NullTransport t;
    teach::TeachingServer s{cfg, t, std::move(*plan), 0};
    print(s, "FREEZE (their goal kick)");
    int last_step = s.stateId();
    for (int i = 0; i < seconds * 30; ++i) {
        s.tickOnce();
        const bool ours = s.world().ball().owner && *s.world().ball().owner < 11;
        if (s.stateId() != last_step) { last_step = s.stateId(); print(s, "NEW STEP"); }
        else if (i % 150 == 149) print(s, "…");
        if (ours) { print(s, "WE WON IT"); break; }
    }
    return 0;
}
