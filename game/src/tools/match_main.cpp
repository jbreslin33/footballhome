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
// The DB is never written. GAME_PARAMS="key=value,..." overrides
// game_model_params numbers for the run.
// Env: POSTGRES_HOST (localhost from the host), POSTGRES_DB, POSTGRES_USER,
// POSTGRES_PASSWORD, GAME_TEAM_HOME / GAME_TEAM_AWAY.
//
// Each match uses seed base+m, so N matches are a fixed sample: the same
// DB gives the same numbers, and any difference IS a change.

#include "ai/Brain.hpp"
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

// Pass outcomes by the passer's reason (Orders::why): every kick is
// resolved at the next player to own the ball — his own team (and whether
// it was the man he picked), the other team, or a dead ball first.
struct PassTally {
    long kicks = 0, mate = 0, intended = 0, lost = 0, dead = 0, offside = 0;
};

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
    // GAME_PARAMS="concept.meet-the-pass.keep_running_mps=99,..." — A/B a
    // game_model_params number (both teams) without touching the DB.
    if (const char* gp = std::getenv("GAME_PARAMS")) {
        std::string s = gp;
        std::size_t at = 0;
        while (at < s.size()) {
            std::size_t end = s.find(',', at);
            if (end == std::string::npos) end = s.size();
            const std::string item = s.substr(at, end - at);
            const std::size_t eq = item.find('=');
            if (eq != std::string::npos) {
                base.model_params.setMilli(item.substr(0, eq),
                                           std::llround(std::atof(item.c_str() + eq + 1) * 1000));
                std::printf("param: %s\n", item.c_str());
            }
            at = end + 1;
        }
    }
    applyOverrides(base, argc > 3 ? argv[3] : "-", true);
    applyOverrides(base, argc > 4 ? argv[4] : "-", false);

    const long ticks = static_cast<long>(minutes) * 60 * core::kTickRate;
    const std::uint64_t seed0 = std::strtoull(envOr("GAME_MATCH_SEED", "1000"), nullptr, 10);
    int w = 0, d = 0, l = 0;
    long gh = 0, ga = 0;
    std::vector<int> margins;
    PassTally tally[2][ai::kWhyCount + 1] = {};  // + rungs 1-2: the ball in behind
    // Goal anatomy: the reason of the last completed pass before each goal
    // (the "assist"), and how many were breakaways (no outfield defender
    // goal-side of the shooter when he shot).
    long assist[2][ai::kWhyCount + 2] = {};   // +1 = none (won it and went), +2 slot spare
    long breakaways[2] = {0, 0};
    // Escort attribution: every tick a team carries in the final third
    // (17.5 m past halfway), the nearest defender's reason and distance.
    long esc_ticks[2] = {0, 0}, esc_why[2][ai::kWhyCount] = {}, esc_near[2] = {0, 0};
    long entries[2] = {0, 0};
    // Line height (G4.55): every live tick a team is out of possession, its
    // back line (deepest outfielder) and front (most advanced) in metres
    // from its own goal, and the ball's. Real: the line ~35-45 m out, the
    // team ~30-35 m long, the line ~20-25 m behind the ball.
    double ln_sum[2] = {0, 0}, front_sum[2] = {0, 0}, ball_sum[2] = {0, 0};
    long ln_ticks[2] = {0, 0}, ln_deep[2] = {0, 0};
    long oop_why[2][ai::kWhyCount] = {}, oop_n[2] = {0, 0};   // outfielders' reasons out of possession
    for (int m = 0; m < matches; ++m) {
        server::GameServer::Config cfg = base;
        cfg.match_seed = seed0 + static_cast<std::uint64_t>(m);
        NullTransport t;
        server::GameServer s{cfg, t};
        // GAME_PHASE="code:team" (G4.58): every match starts from that phase
        // of play (team 0 = home in possession); match 1 prints the set-up
        // — each player's metres from his own goal line and across (+ left).
        if (const char* gp = std::getenv("GAME_PHASE")) {
            const std::string spec = gp;
            const auto colon = spec.find(':');
            const std::string code = spec.substr(0, colon);
            const int team = colon == std::string::npos ? 0 : std::atoi(spec.c_str() + colon + 1);
            for (std::size_t p = 0; p < cfg.phases.size(); ++p) {
                if (cfg.phases[p].code != code) continue;
                s.runPhase(static_cast<std::uint8_t>(team), p);
                if (m == 0)
                    for (std::uint8_t i = 0; i < s.world().playerCount(); ++i) {
                        const auto& pl = s.world().player(i);
                        const double x = pl.pos.x.toDouble(), y = pl.pos.y.toDouble();
                        const bool home = pl.team == 0;
                        std::printf("  %s slot %2d: %5.1f m from own goal, %+5.1f m across\n",
                                    home ? names.team_home.c_str() : names.team_away.c_str(), i,
                                    home ? x + 52.5 : 52.5 - x, home ? y : -y);
                    }
            }
        }
        int pend_team = -1, pend_why = 0, pend_other = -1;
        int last_assist[2] = {ai::kWhyCount + 1, ai::kWhyCount + 1};
        bool shot_breakaway[2] = {false, false};
        bool in_third[2] = {false, false};
        for (long k = 0; k < ticks; ++k) {
            const auto before = s.world().ball().owner;
            s.tickOnce();
            const auto& b = s.world().ball();
            if (b.owner && s.world().restartTeam() == 0xFF) {
                const int dt = s.world().player(*b.owner).team ^ 1;   // defending team
                const double hx = 52.5;
                auto from_goal = [&](double x) { return dt == 0 ? x + hx : hx - x; };
                double deep = 1e9, front = -1e9;
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                    const auto& d = s.world().player(j);
                    if (d.team != dt || s.world().isKeeper(j)) continue;
                    const double g = from_goal(d.pos.x.toDouble());
                    if (g < deep) deep = g;
                    if (g > front) front = g;
                    ++oop_why[dt][static_cast<int>(s.lastOrders()[j].why)];
                    ++oop_n[dt];
                }
                ln_sum[dt] += deep; front_sum[dt] += front - deep;
                ball_sum[dt] += from_goal(b.pos.x.toDouble()) - deep;
                ++ln_ticks[dt];
                if (deep < 20.0) ++ln_deep[dt];
            }
            if (b.owner) {
                const auto& c = s.world().player(*b.owner);
                const int ct = c.team;
                const bool third = (ct == 0 ? c.pos.x.toDouble() : -c.pos.x.toDouble()) > 17.5;
                if (third && !in_third[ct]) ++entries[ct];
                in_third[ct] = third;
                in_third[ct ^ 1] = false;
                if (third) {
                    double best = 1e9; int who = -1;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == ct || s.world().isKeeper(j)) continue;
                        const double dx = d.pos.x.toDouble() - c.pos.x.toDouble(), dy = d.pos.y.toDouble() - c.pos.y.toDouble();
                        if (dx * dx + dy * dy < best) { best = dx * dx + dy * dy; who = j; }
                    }
                    ++esc_ticks[ct];
                    if (who >= 0) ++esc_why[ct][static_cast<int>(s.lastOrders()[who].why)];
                    if (best < 1.8 * 1.8) ++esc_near[ct];
                }
            }
            for (const auto& e : s.lastEvents()) {
                if (e.type != core::MatchEventType::Goal) continue;
                ++assist[e.team][last_assist[e.team]];
                if (shot_breakaway[e.team]) ++breakaways[e.team];
            }
            if (b.owner) {  // a change of possession resets the move
                const int ot = s.world().player(*b.owner).team;
                if (before && s.world().player(*before).team != ot) last_assist[ot] = ai::kWhyCount + 1;
            }
            if (pend_team >= 0) {
                PassTally& t = tally[pend_team][pend_why];
                if (s.world().restartTeam() != 0xFF) {
                    ++t.dead;
                    for (const auto& e : s.lastEvents())
                        if (e.type == core::MatchEventType::Offside) ++t.offside;
                    pend_team = -1;
                } else if (b.owner) {
                    if (s.world().player(*b.owner).team == pend_team) {
                        if (pend_why != static_cast<int>(ai::Why::Shoot)) last_assist[pend_team] = pend_why;
                        ++t.mate;
                        if (*b.owner == pend_other) ++t.intended;
                    } else {
                        ++t.lost;
                    }
                    pend_team = -1;
                }
            }
            if (before && !b.owner && b.last_kicker == *before &&
                s.world().restartTeam() == 0xFF) {
                const ai::Orders& o = s.lastOrders()[*before];
                pend_team = s.world().player(*before).team;
                if (o.why == ai::Why::Shoot) {
                    const auto& sh = s.world().player(*before);
                    bool alone = true;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == sh.team || s.world().isKeeper(j)) continue;
                        if (sh.team == 0 ? d.pos.x > sh.pos.x : d.pos.x < sh.pos.x) alone = false;
                    }
                    shot_breakaway[pend_team] = alone;
                }
                pend_why = o.rung >= 1 && o.rung <= 2 ? ai::kWhyCount : static_cast<int>(o.why);
                pend_other = o.other;
                ++tally[pend_team][pend_why].kicks;
            }
        }
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
    // Pass outcomes (Shoot/Clear/punts included: every kick from a carry).
    for (int team = 0; team < 2; ++team) {
        std::printf("\n%s kicks per match by reason: kicks | to a mate (the one he picked) | lost | dead (offside)\n",
                    team == 0 ? names.team_home.c_str() : names.team_away.c_str());
        for (int w = 0; w <= ai::kWhyCount; ++w) {
            const PassTally& t = tally[team][w];
            if (t.kicks == 0) continue;
            const double n = matches;
            std::printf("  %-28s %6.1f | %5.1f%% (%5.1f%%) | %5.1f%% | %5.1f%% (%4.1f%%)\n", w == ai::kWhyCount ? "in behind (rungs 1-2)" : ai::kWhyNames[w],
                        t.kicks / n, 100.0 * t.mate / t.kicks, 100.0 * t.intended / t.kicks,
                        100.0 * t.lost / t.kicks, 100.0 * t.dead / t.kicks, 100.0 * t.offside / t.kicks);
        }
    }
    for (int team = 0; team < 2; ++team)
        if (ln_ticks[team])
            std::printf("\n%s out of possession: back line %.1f m from own goal (inside 20 m %.0f%% of the time), team %.1f m long, ball %.1f m beyond the line\n",
                        team == 0 ? names.team_home.c_str() : names.team_away.c_str(),
                        ln_sum[team] / ln_ticks[team], 100.0 * ln_deep[team] / ln_ticks[team],
                        front_sum[team] / ln_ticks[team], ball_sum[team] / ln_ticks[team]);
    for (int team = 0; team < 2; ++team) {
        if (!oop_n[team]) continue;
        std::printf("%s outfielders out of possession are doing:", team == 0 ? names.team_home.c_str() : names.team_away.c_str());
        for (int w = 0; w < ai::kWhyCount; ++w)
            if (oop_why[team][w] * 100 >= oop_n[team])   // 1%+
                std::printf(" %s %.0f%% ·", ai::kWhyNames[w], 100.0 * oop_why[team][w] / oop_n[team]);
        std::printf("\n");
    }
    for (int team = 0; team < 2; ++team) {
        std::printf("\n%s final-third entries %.1f/match, carrying %.0f s/match there, tight (<1.8 m) %.0f%%; nearest defender doing:\n",
                    team == 0 ? names.team_home.c_str() : names.team_away.c_str(),
                    static_cast<double>(entries[team]) / matches, esc_ticks[team] / 30.0 / matches,
                    esc_ticks[team] ? 100.0 * esc_near[team] / esc_ticks[team] : 0.0);
        for (int w = 0; w < ai::kWhyCount; ++w)
            if (esc_why[team][w] * 100 >= esc_ticks[team] * 2)
                std::printf("  %-28s %4.0f%%\n", ai::kWhyNames[w], 100.0 * esc_why[team][w] / esc_ticks[team]);
    }
    for (int team = 0; team < 2; ++team) {
        std::printf("\n%s goals per match by the last pass before them (breakaways %.2f):\n",
                    team == 0 ? names.team_home.c_str() : names.team_away.c_str(),
                    static_cast<double>(breakaways[team]) / matches);
        for (int w = 0; w <= ai::kWhyCount + 1; ++w) {
            if (!assist[team][w]) continue;
            const char* n = w == ai::kWhyCount ? "in behind (rungs 1-2)"
                          : w == ai::kWhyCount + 1 ? "(no pass: won it / carried)" : ai::kWhyNames[w];
            std::printf("  %-28s %5.2f\n", n, static_cast<double>(assist[team][w]) / matches);
        }
    }
    return 0;
}
