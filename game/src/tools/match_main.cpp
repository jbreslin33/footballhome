// game/src/tools/match_main.cpp — fh-game-match (G4.43; rewritten lean G5.23, DESIGN §8.121)
//
// N full matches of the REAL matchup through the live daemon's own path
// (server::loadMatchFromDb → GameServer, a no-op network). Every line is a
// number we hold a real one for — StatsBomb PL 2015/16 events or DFL
// tracking — printed with the real figure in brackets where it is one number.
// The old harness (3,500 lines measuring the deleted brain) is gone.
//
//   fh-game-match [matches=30] [minutes=90]
//
// Env: POSTGRES_HOST / _DB / _USER / _PASSWORD, GAME_TEAM_HOME / _AWAY,
// GAME_MATCH_SEED (base; match m plays seed base+m — a fixed sample),
// GAME_PARAMS="key=value,..." (game_model_params numbers for the run; the DB
// is never written), GAME_DEAD_TRACE=1 (a stalled dead ball, every 10 s).

#include "ai/Brain.hpp"
#include "ai/Players.hpp"
#include "core/Clock.hpp"
#include "net/INetworkTransport.hpp"
#include "persistence/FormationStore.hpp"
#include "server/GameServer.hpp"
#include "server/MatchSetup.hpp"

#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

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

const char* const kRoleName[ai::kRoleCount] = {"CB", "FB", "DM/CM", "AM", "WIDE", "ST"};
const char* const kDistName[4] = {"<12 m", "12-18", "18-25", "25+"};
const char* const kOutName[5] = {"goal", "keeper", "blocked", "off target", "other"};

// Everything counted, across all matches.
struct Stats {
    long goals[2] = {}, w = 0, d = 0, l = 0;
    // Shots (G5.23): by distance band; how each ended (first thing after it).
    long shots[2] = {}, shot_band[4] = {}, shot_out[5] = {}, band_goal[4] = {};
    long rel_n[5] = {}, rel_shot[5] = {};   // balls let go in open play by distance (<12, 12-18, 18-25, 25-35, 35+), and shots
    // Concept acts, StatsBomb's cuts (G5.17).
    long press = 0, cpress = 0, passes = 0, switches = 0, crosses = 0, cutbacks = 0, takeon = 0, takeon_ok = 0,
         ret = 0, ret_base = 0, carry10 = 0;
    // Phases (G5.21).
    long ph[ai::kPhaseCount] = {}, ph_n = 0;
    // Entries inside 30 m and the carry through the block (G5.19b / G5.20).
    long en = 0, en_spd[3] = {}, en3 = 0; double en_gs = 0, en_deep = 0, en3_b = 0, en3_gs = 0, en3_deep = 0, en3_line = 0;
    long cy = 0, cy_first[8][2] = {}, cy_rn[ai::kRoleCount] = {}, cy_rgs[ai::kRoleCount] = {};
    double cy_du = 0, cy_m = 0, cy_gs0 = 0, cy_pass = 0, cy_gs1 = 0, cy_near0 = 0, cy_close = 0, cy_eng = 0, cy_w5 = 0,
           cy_rd[ai::kRoleCount] = {};
    // Shapes by ball band (DFL): defending, metres off its own line; in possession, off THEIR line.
    long ds_f[10] = {}, ds_n[10][ai::kRoleCount] = {}; double ds_mid[10] = {}, ds_s[10][ai::kRoleCount] = {};
    long ps_f[10] = {}, ps_n[10][ai::kRoleCount] = {};
    double ps_back[10] = {}, ps_mid[10] = {}, ps_front[10] = {}, ps_s[10][ai::kRoleCount] = {};
    double fit_n = 0, fit_b = 0, fit_m = 0, fit_bb = 0, fit_bm = 0, gap_s[ai::kRoleCount] = {}; long gap_n[ai::kRoleCount] = {};
};

int distBand(double d) { return d < 12 ? 0 : d < 18 ? 1 : d < 25 ? 2 : 3; }

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
    if (const char* gp = std::getenv("GAME_PARAMS")) {
        std::string s = gp;
        std::size_t at = 0;
        while (at < s.size()) {
            std::size_t end = s.find(',', at);
            if (end == std::string::npos) end = s.size();
            const std::string item = s.substr(at, end - at);
            const std::size_t eq = item.find('=');
            if (eq != std::string::npos) {
                base.model_params.setMilli(item.substr(0, eq), std::llround(std::atof(item.c_str() + eq + 1) * 1000));
                std::printf("param: %s\n", item.c_str());
            }
            at = end + 1;
        }
    }
    const long ticks = static_cast<long>(minutes) * 60 * core::kTickRate;
    const std::uint64_t seed0 = std::strtoull(envOr("GAME_MATCH_SEED", "1000"), nullptr, 10);
    const bool dead_trace = std::getenv("GAME_DEAD_TRACE") != nullptr;
    Stats S;

    for (int m = 0; m < matches; ++m) {
        server::GameServer::Config cfg = base;
        cfg.match_seed = seed0 + static_cast<std::uint64_t>(m);
        NullTransport t;
        server::GameServer s{cfg, t};
        const auto& W = s.world();
        const double hx = W.pitchHalfX().toDouble();
        const std::uint8_t N = W.playerCount();
        auto role = [&](std::uint8_t j) { return static_cast<int>(ai::roleOfNumber(s.brain().numberOf(j))); };
        // Per-match state.
        struct Shot { bool on = false; int team = 0, band = 0; long tick = 0; } shot;
        int owner = -1, owner_team = -1; long owner_got = 0; double own_sx = 0, own_px = 0, own_py = 0;
        bool own_set = false;
        struct Rel { int p = -1, team = -1; double x = 0, y = 0; bool set = false, cross = false, shot = false; } rel;
        int from[32]; long from_t[32], pressed_in[32]; int facing[32];
        for (int j = 0; j < 32; ++j) { from[j] = -1; from_t[j] = -1000; pressed_in[j] = -1; facing[j] = 0; }
        long loss_tick[2] = {-1000, -1000};
        // 5 Hz ring for "3 s before" (ball x, every man's x).
        long rk[16]; double rbx[16], rpx[16][32]; for (long& v : rk) v = -1;
        bool en_arm[2] = {false, false}; double en_prev[2] = {0, 0}; long en_pk[2] = {-100, -100};
        struct Carry { bool on = false, done = false; int pid = -1, att = -1, miss = 0, fr = 0, eng = 0, first = -1; long k0 = 0, last = 0;
                       double btl0 = 0, near0 = 0, close = 0, w5 = 0; bool gs[32] = {}; int r[32] = {}; double rd[32] = {}; } cy;

        for (long k = 0; k < ticks; ++k) {
            const auto before = W.ball().owner;
            s.tickOnce();
            const auto& b = W.ball();
            for (const auto& e : s.lastEvents())
                if (e.type == core::MatchEventType::Goal) {
                    ++S.goals[e.team];
                    if (shot.on && shot.team == e.team) { ++S.shot_out[0]; ++S.band_goal[shot.band]; shot.on = false; }
                }
            if (dead_trace && k % 300 == 0 && W.restartTeam() != 0xFF)
                std::fprintf(stderr, "dead-trace m%d k%ld restart %d kind %d owner %d ball %.1f,%.1f\n", m, k, W.restartTeam(),
                             static_cast<int>(W.restartKind()), b.owner ? *b.owner : -1, b.pos.x.toDouble(), b.pos.y.toDouble());

            // ── a shot struck this tick, and how it ends ──────────────────
            if (before && !b.owner && b.last_kicker == *before && s.lastOrders()[*before].why == ai::Why::Shoot) {
                const auto& p = W.player(*before);
                const double gx = (p.team == 0 ? hx : -hx) - p.pos.x.toDouble(), gy = p.pos.y.toDouble();
                shot = Shot{true, p.team, distBand(std::hypot(gx, gy)), k};
                ++S.shots[p.team]; ++S.shot_band[shot.band];
            } else if (shot.on && k > shot.tick) {
                const int def = shot.team ^ 1;
                if (b.owner) {
                    const auto o = *b.owner;
                    ++S.shot_out[W.isKeeper(o) && W.player(o).team == def ? 1 : W.player(o).team == def ? 2 : 4];
                    shot.on = false;
                } else if (W.lastTouchTeam() == def) {
                    ++S.shot_out[2]; shot.on = false;   // a defender's touch (a keeper's parry counts here too)
                } else if (W.outStage() != 0 || W.restartTeam() != 0xFF) {
                    ++S.shot_out[3]; shot.on = false;
                } else if (k - shot.tick > 150) {
                    ++S.shot_out[4]; shot.on = false;
                }
            }

            // ── concept acts by ownership (StatsBomb's cuts) ──────────────
            const int own = b.owner ? static_cast<int>(*b.owner) : -1;
            auto endPass = [&](double ex, double ey) {
                if (rel.p < 0 || rel.set || rel.shot) { rel = Rel{}; return; }
                const double sg = rel.team == 0 ? 1.0 : -1.0;
                ++S.passes;
                if (std::fabs(ey - rel.y) >= 34) ++S.switches;
                if (rel.cross) ++S.crosses;
                const double stl = hx - rel.x * sg, etl = hx - ex * sg;
                if (stl < 9 && etl > stl + 1 && etl < 16.5 && std::fabs(ey) < 20.16) ++S.cutbacks;
                rel = Rel{};
            };
            if (own != owner) {
                if (owner >= 0) {
                    const double sg = owner_team == 0 ? 1.0 : -1.0;
                    if (!own_set && (own_px - own_sx) * sg >= 10) ++S.carry10;
                    if (facing[owner] > 0) { ++S.takeon; facing[owner] = 0; }
                    if (own < 0) {
                        const auto why = s.lastOrders()[owner].why;
                        if (!own_set && why != ai::Why::KeeperPunt) {
                            const double d = std::hypot((owner_team == 0 ? hx : -hx) - own_px, own_py);
                            const int rb = d < 12 ? 0 : d < 18 ? 1 : d < 25 ? 2 : d < 35 ? 3 : 4;
                            ++S.rel_n[rb]; if (why == ai::Why::Shoot) ++S.rel_shot[rb];
                        }
                        rel = Rel{owner, owner_team, own_px, own_py, own_set, why == ai::Why::Cross, why == ai::Why::Shoot};
                        if (!own_set && !rel.shot && from[owner] >= 0 && owner_got - from_t[owner] <= 1 && k - owner_got <= 150) {
                            ++S.ret_base;
                            if (s.lastOrders()[owner].other == from[owner]) ++S.ret;
                        }
                    }
                }
                if (own >= 0) {
                    const auto& q = W.player(static_cast<std::uint8_t>(own));
                    if (rel.p >= 0) {
                        const bool mate = rel.team == q.team && rel.p != own;
                        from[own] = (mate && !rel.set) ? rel.p : -1; from_t[own] = k;
                        endPass(q.pos.x.toDouble(), q.pos.y.toDouble());
                    } else from[own] = -1;
                    if (owner_team >= 0 && q.team != owner_team) loss_tick[owner_team] = k;
                    owner = own; owner_team = q.team; owner_got = k; own_sx = q.pos.x.toDouble();
                    for (int j = 0; j < 32; ++j) { pressed_in[j] = -1; facing[j] = 0; }
                } else owner = -1;
            }
            if (rel.p >= 0 && W.outStage() != 0) endPass(b.pos.x.toDouble(), b.pos.y.toDouble());
            if (own >= 0) {
                const auto& c = W.player(static_cast<std::uint8_t>(own));
                const double sg = c.team == 0 ? 1.0 : -1.0;
                own_px = c.pos.x.toDouble(); own_py = c.pos.y.toDouble(); own_set = W.restartTeam() != 0xFF;
                if (!own_set) for (std::uint8_t j = 0; j < N && j < 32; ++j) {
                    const auto& d = W.player(j);
                    if (d.team == c.team) continue;
                    const double dx = c.pos.x.toDouble() - d.pos.x.toDouble(), dy = c.pos.y.toDouble() - d.pos.y.toDouble(), dd = std::hypot(dx, dy);
                    // pressure: within 4.5 m and closing at 1 m/s+, once per man per spell
                    if (dd < 4.5 && dd > 0.01 && (d.vel.x.toDouble() * dx + d.vel.y.toDouble() * dy) / dd >= 1.0 && pressed_in[j] < 0) {
                        pressed_in[j] = static_cast<long>(k); ++S.press; if (k - loss_tick[d.team] <= 150) ++S.cpress;
                    }
                    // take-on: a man goal-side within 1.5 m in his 45° cone; done 1 m past him with it
                    const double ahead = -dx * sg;
                    if (!facing[own] && dd < 1.5 && ahead > 0 && std::fabs(dy) <= ahead) facing[own] = j + 1;
                }
                if (facing[own] > 0) {
                    const auto& d = W.player(static_cast<std::uint8_t>(facing[own] - 1));
                    if ((c.pos.x.toDouble() - d.pos.x.toDouble()) * sg >= 1) { ++S.takeon; ++S.takeon_ok; facing[own] = 0; }
                }
            }

            if (k % 6 == 0) {
                for (std::uint8_t tm = 0; tm < 2; ++tm) ++S.ph[static_cast<int>(s.brain().phaseOf(tm))];
                ++S.ph_n;
            }
            // ── 5 Hz, in play, the last team on the ball (as DFL flags it) ──
            if (k % 6 != 0 || W.outStage() != 0 || W.restartTeam() != 0xFF || W.lastTouchTeam() > 1) continue;
            const int a = W.lastTouchTeam(), dteam = a ^ 1;
            const double sg = a == 0 ? 1.0 : -1.0, bx = b.pos.x.toDouble(), by = b.pos.y.toDouble();
            const double tl = hx - bx * sg;   // ball metres off THEIR line
            const int ri = static_cast<int>((k / 6) % 16), rj = static_cast<int>(((k / 6) + 1) % 16);   // rj = 15 frames back
            const bool then_ok = rk[rj] == k - 90;
            {   // shapes
                const int bd = std::min(9, std::max(0, static_cast<int>((2 * hx - tl) / 10)));   // ball off the defenders' line
                const int bp = std::min(9, std::max(0, static_cast<int>(tl / 10)));
                double dm = 0, pm = 0, back = -1e9, front = 1e9; int dn = 0, pn = 0;
                for (std::uint8_t j = 0; j < N; ++j) {
                    if (W.isKeeper(j)) continue;
                    const auto& q = W.player(j);
                    const int r = role(j);
                    if (q.team == dteam) {
                        const double v = hx + q.pos.x.toDouble() * (dteam == 0 ? 1.0 : -1.0);   // off his own line
                        S.ds_s[bd][r] += v; ++S.ds_n[bd][r]; dm += v; ++dn;
                    } else {
                        const double v = hx - q.pos.x.toDouble() * sg;   // off THEIR line
                        S.ps_s[bp][r] += v; ++S.ps_n[bp][r]; pm += v; ++pn;
                        back = std::max(back, v); front = std::min(front, v);
                    }
                }
                if (dn) { ++S.ds_f[bd]; S.ds_mid[bd] += dm / dn; }
                if (pn) {
                    ++S.ps_f[bp]; S.ps_mid[bp] += pm / pn; S.ps_back[bp] += back; S.ps_front[bp] += front;
                    const double xb = 2 * hx - tl, xm = 2 * hx - pm / pn;   // both from OUR goal
                    S.fit_n += 1; S.fit_b += xb; S.fit_m += xm; S.fit_bb += xb * xb; S.fit_bm += xb * xm;
                    if (tl >= 25 && tl < 75)
                        for (std::uint8_t j = 0; j < N; ++j) {
                            if (W.isKeeper(j) || W.player(j).team != a) continue;
                            S.gap_s[role(j)] += (pm / pn) - (hx - W.player(j).pos.x.toDouble() * sg); ++S.gap_n[role(j)];
                        }
                }
            }
            {   // ENTRIES inside 30 m (re-armed past 40)
                if (k < en_pk[0] - 6 || k < en_pk[1] - 6) { en_arm[0] = en_arm[1] = false; en_pk[0] = en_pk[1] = -100; }
                if (tl >= 40) en_arm[a] = true;
                const bool cross = en_arm[a] && en_pk[a] == k - 6 && en_prev[a] >= 30 && tl < 30;
                en_prev[a] = tl; en_pk[a] = k;
                if (cross) {
                    en_arm[a] = false;
                    const double spd = std::hypot(b.vel.x.toDouble(), b.vel.y.toDouble());
                    ++S.en; ++S.en_spd[spd < 7 ? 0 : spd < 12 ? 1 : 2];
                    int gs = 0; double deep = 1e9;
                    for (std::uint8_t j = 0; j < N; ++j) {
                        if (W.isKeeper(j) || W.player(j).team == a) continue;
                        const double p = hx - W.player(j).pos.x.toDouble() * sg;
                        if (p < tl) ++gs;
                        deep = std::min(deep, p);
                    }
                    S.en_gs += gs; S.en_deep += deep;
                    if (then_ok) {
                        const double b0 = hx - rbx[rj] * sg;
                        std::vector<double> th;
                        for (std::uint8_t j = 0; j < N && j < 32; ++j)
                            if (!W.isKeeper(j) && W.player(j).team != a) th.push_back(hx - rpx[rj][j] * sg);
                        std::sort(th.begin(), th.end());
                        int g0 = 0; for (double v : th) if (v < b0) ++g0;
                        if (th.size() >= 2) { ++S.en3; S.en3_gs += g0; S.en3_deep += th[0]; S.en3_line += th[1]; S.en3_b += b0; }
                    }
                }
            }
            {   // THE CARRY THROUGH THE BLOCK, by positions as DFL has them
                int cr = -1; double crd = 2.0;
                for (std::uint8_t j = 0; j < N && j < 32; ++j) {
                    if (W.player(j).team != a) continue;
                    const double dd = std::hypot(W.player(j).pos.x.toDouble() - bx, W.player(j).pos.y.toDouble() - by);
                    if (dd < crd) { crd = dd; cr = j; }
                }
                if (cy.on && (cy.att != a || k - cy.last > 18 || (cr >= 0 && cr != cy.pid))) cy.on = false;
                bool skip = false;
                if (cy.on && cr < 0) {
                    const auto& q = W.player(static_cast<std::uint8_t>(cy.pid));
                    if (std::hypot(q.pos.x.toDouble() - bx, q.pos.y.toDouble() - by) > 4 || cy.miss >= 2) cy.on = false;
                    else { ++cy.miss; cy.last = k; }
                    skip = true;
                }
                if (!skip && cr >= 0) {
                    double dist[32]; int nd = 0, w5 = 0, bj = -1; double best = 1e9;
                    for (std::uint8_t j = 0; j < N && j < 32; ++j) {
                        if (W.isKeeper(j) || W.player(j).team == a) { dist[j] = 1e9; continue; }
                        dist[j] = std::hypot(W.player(j).pos.x.toDouble() - bx, W.player(j).pos.y.toDouble() - by); ++nd;
                        if (dist[j] < best) { best = dist[j]; bj = j; }
                        if (dist[j] < 5) ++w5;
                    }
                    if (!cy.on) {
                        if (tl >= 35 && nd >= 9) {
                            cy = Carry{}; cy.on = true; cy.pid = cr; cy.att = a; cy.k0 = k; cy.last = k; cy.btl0 = tl; cy.near0 = best; cy.close = best;
                            for (std::uint8_t j = 0; j < N && j < 32; ++j) {
                                if (dist[j] > 1e8) continue;
                                const double p = hx - W.player(j).pos.x.toDouble() * sg;
                                cy.gs[j] = p < tl; cy.r[j] = role(j); cy.rd[j] = tl - p;
                            }
                        }
                    } else {
                        cy.miss = 0; cy.last = k;
                        if (!cy.done) {
                            ++cy.fr; cy.close = std::min(cy.close, best); cy.w5 += w5;
                            if (best < 2) { ++cy.eng; if (cy.first < 0) cy.first = bj; }
                            if (tl < 30) {
                                cy.done = true;
                                int gs0 = 0, pass = 0, gs1 = 0;
                                for (std::uint8_t j = 0; j < N && j < 32; ++j) {
                                    if (dist[j] > 1e8) continue;
                                    const bool now = hx - W.player(j).pos.x.toDouble() * sg < tl;
                                    gs0 += cy.gs[j]; gs1 += now; pass += cy.gs[j] && !now;
                                    ++S.cy_rn[cy.r[j]]; S.cy_rgs[cy.r[j]] += cy.gs[j]; S.cy_rd[cy.r[j]] += cy.rd[j];
                                }
                                ++S.cy; S.cy_du += (k - cy.k0) / 30.0; S.cy_m += cy.btl0 - tl;
                                S.cy_gs0 += gs0; S.cy_pass += pass; S.cy_gs1 += gs1; S.cy_near0 += cy.near0; S.cy_close += cy.close;
                                S.cy_eng += static_cast<double>(cy.eng) / std::max(1, cy.fr); S.cy_w5 += cy.w5 / std::max(1, cy.fr);
                                if (cy.first < 0) ++S.cy_first[7][0];
                                else ++S.cy_first[role(static_cast<std::uint8_t>(cy.first))][cy.gs[cy.first] ? 0 : 1];
                            }
                        }
                    }
                }
            }
            rk[ri] = k; rbx[ri] = bx;
            for (std::uint8_t j = 0; j < N && j < 32; ++j) rpx[ri][j] = W.player(j).pos.x.toDouble();
        }
        const int hg = W.score(0), ag = W.score(1);
        if (hg > ag) ++S.w; else if (hg == ag) ++S.d; else ++S.l;
    }

    // ── the report ──────────────────────────────────────────────────────
    const double nm = matches, tm = 2.0 * matches;
    std::printf("%s vs %s over %d matches: W%ld D%ld L%ld | goals %.2f - %.2f\n", names.team_home.c_str(), names.team_away.c_str(),
                matches, S.w, S.d, S.l, S.goals[0] / nm, S.goals[1] / nm);
    std::printf("%s shots %.1f/match\n%s shots %.1f/match\n", names.team_home.c_str(), S.shots[0] / nm, names.team_away.c_str(), S.shots[1] / nm);
    {
        const double sh = std::max(1L, S.shots[0] + S.shots[1]);
        std::printf("SHOTS a team-match %.1f, goals %.2f, %.1f%% scored; by distance:", (S.shots[0] + S.shots[1]) / tm, (S.goals[0] + S.goals[1]) / tm,
                    100.0 * (S.goals[0] + S.goals[1]) / sh);
        for (int i = 0; i < 4; ++i) std::printf(" %s %.0f%% (scored %.1f%%);", kDistName[i], 100.0 * S.shot_band[i] / sh, 100.0 * S.band_goal[i] / std::max(1L, S.shot_band[i]));
        std::printf("\n   how they ended:");
        for (int i = 0; i < 5; ++i) std::printf(" %s %.1f%%;", kOutName[i], 100.0 * S.shot_out[i] / sh);
        static const char* rbn[5] = {"<12 m", "12-18", "18-25", "25-35", "35+"};
        std::printf("\n   of the balls let go in open play, the share that were shots:");
        for (int i = 0; i < 5; ++i) std::printf(" %s %.1f%% (of %.1f a team-match);", rbn[i], 100.0 * S.rel_shot[i] / std::max(1L, S.rel_n[i]), S.rel_n[i] / tm);
        std::printf("\n");
    }
    std::printf("CONCEPT ACTS a team-match (StatsBomb cuts; real PL 15/16 in brackets): pressures %.1f (151.8), counter-press %.1f = %.1f%% (21.0%%); passes %.1f (433.8): switches %.2f (10.69), crosses %.2f (11.47), cut-backs %.2f (1.03); take-ons %.2f tried (18.05), %.2f completed (10.59); return passes %.2f (42.11) = %.1f%% of passes after a receipt (15.7%%); carries 10 m+ %.2f (34.64)\n",
                S.press / tm, S.cpress / tm, 100.0 * S.cpress / std::max(1L, S.press), S.passes / tm, S.switches / tm, S.crosses / tm, S.cutbacks / tm,
                S.takeon / tm, S.takeon_ok / tm, S.ret / tm, 100.0 * S.ret / std::max(1L, S.ret_base), S.carry10 / tm);
    std::printf("   PHASES (share of time, both teams):");
    for (int q = 0; q < ai::kPhaseCount; ++q) std::printf(" %s %.1f%%;", ai::kPhaseNames[q], 50.0 * S.ph[q] / std::max(1L, S.ph_n));
    std::printf("\n");
    if (S.en) {
        const double e = S.en, e3 = std::max(1L, S.en3);
        std::printf("   ENTRIES inside 30 m (real DFL in brackets): %.1f a team-match; ball speed at the entry under 7 m/s %.0f%%, 7-12 %.0f%%, 12+ %.0f%%\n     at the entry: goal-side %.2f, their deepest outfielder %.1f m off his line\n     3 s before: ball %.1f m out, goal-side %.2f, deepest %.1f m, second-deepest (the line) %.1f m\n",
                    e / tm, 100.0 * S.en_spd[0] / e, 100.0 * S.en_spd[1] / e, 100.0 * S.en_spd[2] / e, S.en_gs / e, S.en_deep / e,
                    S.en3_b / e3, S.en3_gs / e3, S.en3_deep / e3, S.en3_line / e3);
    }
    if (S.cy) {
        const double c = S.cy;
        std::printf("   CARRY THROUGH THE BLOCK (35 m+ out to inside 30, one carrier): %.1f a team-match (%.0f%% of entries); %.1f s, %.1f m toward goal (%.1f m/s)\n     goal-side at its start %.2f, left behind by the entry %.2f, goal-side at the entry %.2f; nearest defender at the start %.1f m, closest along it %.1f m\n     a defender within 2 m %.0f%% of its frames; defenders within 5 m %.2f; first man within 2 m:",
                    c / tm, 100.0 * c / std::max(1L, S.en), S.cy_du / c, S.cy_m / c, S.cy_m / std::max(1e-9, S.cy_du),
                    S.cy_gs0 / c, S.cy_pass / c, S.cy_gs1 / c, S.cy_near0 / c, S.cy_close / c, 100.0 * S.cy_eng / c, S.cy_w5 / c);
        static const char* rf[8] = {"CB", "FB", "DM/CM", "AM", "WIDE", "ST", "?", "none"};
        for (int r = 0; r < 8; ++r) for (int q = 0; q < 2; ++q) if (S.cy_first[r][q]) std::printf(" %s%s %.0f%%", rf[r], r == 7 ? "" : q ? "/not" : "/gs", 100.0 * S.cy_first[r][q] / c);
        std::printf("\n     at its start by role, goal-side share / metres goal-side of the ball:");
        for (int r = 0; r < ai::kRoleCount; ++r) if (S.cy_rn[r]) std::printf(" %s %.0f%% %+.1f;", kRoleName[r], 100.0 * S.cy_rgs[r] / S.cy_rn[r], S.cy_rd[r] / S.cy_rn[r]);
        std::printf("\n");
    }
    std::printf("DEFENDING SHAPE (the side without it; metres from its own line, ball band = ball m from that line):\n   band    frames  middle      CB      FB   DM/CM      AM    WIDE      ST\n");
    for (int k = 0; k < 10; ++k) {
        if (!S.ds_f[k]) continue;
        std::printf("   %2d-%-3d %7ld  %5.1f   ", 10 * k, 10 * k + 10, S.ds_f[k], S.ds_mid[k] / S.ds_f[k]);
        for (int r = 0; r < ai::kRoleCount; ++r) std::printf("  %6.1f", S.ds_n[k][r] ? S.ds_s[k][r] / S.ds_n[k][r] : 0.0);
        std::printf("\n");
    }
    std::printf("POSSESSION SHAPE (last touch, in play; metres from THEIR line by the ball's band):\n   band    frames  back/middle/front  ");
    for (int r = 0; r < ai::kRoleCount; ++r) std::printf("  %6s", kRoleName[r]);
    std::printf("\n");
    for (int k = 0; k < 10; ++k) {
        if (!S.ps_f[k]) continue;
        const double f = S.ps_f[k];
        std::printf("   %2d-%-3d %7ld  %5.1f/%5.1f/%5.1f   ", 10 * k, 10 * k + 10, S.ps_f[k], S.ps_back[k] / f, S.ps_mid[k] / f, S.ps_front[k] / f);
        for (int r = 0; r < ai::kRoleCount; ++r) { if (S.ps_n[k][r]) std::printf("  %6.1f", S.ps_s[k][r] / S.ps_n[k][r]); else std::printf("       -"); }
        std::printf("\n");
    }
    {
        const double n = std::max(1.0, S.fit_n), sl = (S.fit_bm - S.fit_b * S.fit_m / n) / std::max(1e-9, S.fit_bb - S.fit_b * S.fit_b / n);
        std::printf("   middle on the ball, from our goal: slope %.2f, offset %.1f m\n   each role ahead of the middle, ball 25-75 m off their line:", sl, S.fit_m / n - sl * S.fit_b / n);
        for (int r = 0; r < ai::kRoleCount; ++r) if (S.gap_n[r]) std::printf(" %s %+.1f;", kRoleName[r], S.gap_s[r] / S.gap_n[r]);
        std::printf("\n");
    }
    return 0;
}
