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
// is never written), GAME_DEAD_TRACE=1 (a stalled dead ball, every 10 s),
// GAME_HOLD_TRACE=1 (full-backs and wide men holding shape at 5 Hz: spot, velocity, intent; §8.128;
// =all: every role).

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
    long rel_n[5] = {}, rel_shot[5] = {};
    long goal_by[ai::kWhyCount + 1] = {}, goal_own = 0;
    std::vector<double> near_band[5];
    long pz_n[10] = {}, pz_to[10][10] = {};
    long bx_f[6] = {}, bx_in[6] = {}, bx_run[6] = {}; double bx_run_tl[6] = {};   // ours in the box zone (0-18 m, |y| < 20.16) by the ball's zone (DFL box)   // passes as played: origin zone → end zone (the pass policy's grid)   // the nearest defender to the man on the ball, by band (DFL press)   // each goal by the last kick's why (+ none), own goals   // balls let go in open play by distance (<12, 12-18, 18-25, 25-35, 35+), and shots
    // Concept acts, StatsBomb's cuts (G5.17).
    long pass_ok = 0;
    // In behind (G5.27, benchmarks_tracking_behind.py): passes met past their line as it stood at the kick.
    long tkl[2][3] = {};
    long tick_n = 0, tick_live = 0, dead_n[13] = {}, out_by[2][ai::kWhyCount + 1] = {}; std::vector<double> dead_s[13]; long fouls = 0;
    long tk_spells = 0, tk_frames = 0, tk_press = 0, tk_takeon = 0, tk_press_z[5] = {};
    long press_why[ai::kWhyCount] = {}, press_d[5] = {}, gap_h[10] = {}, led = 0, bh_pass = 0, bh_n = 0, bh_ok = 0, bh_air = 0, bh_fwd = 0, bh_frun = 0, bh_z[10] = {};
    std::vector<double> bh_gap, bh_spd, bh_vx, bh_lead, bh_t, bh_len, bh_past, bh_mtl;
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
    long dt_n[10][ai::kRoleCount] = {}; double dt_s[10][ai::kRoleCount] = {}, dt_v[10][ai::kRoleCount] = {}, dt_a[10][ai::kRoleCount] = {};   // holders' targets and speed toward their own line
    long ps_f[10] = {}, ps_n[10][ai::kRoleCount] = {};
    double ps_back[10] = {}, ps_mid[10] = {}, ps_front[10] = {}, ps_s[10][ai::kRoleCount] = {};
    double fit_n = 0, fit_b = 0, fit_m = 0, fit_bb = 0, fit_bm = 0, gap_s[ai::kRoleCount] = {}; long gap_n[ai::kRoleCount] = {};
    // RECOVERY (§8.128, benchmarks_tracking_recover.py): the side without it, by s since it lost it.
    long rc_n[5] = {}, rc_s[5][3] = {}, rc_fb[5] = {}; double rc_v[5] = {}, rc_back[5] = {};
    long rc_fast[ai::kWhyCount][3] = {}, rc_fast_role[ai::kRoleCount] = {}, rc_hold_near[3] = {};   // + holders with the ball inside 40 m of their goal
    long rc_zn[2] = {}, rc_z[2][3] = {}, rc_zk[2][5] = {}, rc_zkb[2][5] = {};   // + by s since lost: steps, 5+ back
    long rc_gap[4] = {}, rc_gapb[4] = {};   // holders in danger by metres off their spot: steps, 5+ back   // the ball inside 40 m of their goal / further: steps, 5+ back / up / across   // 5+ m/s: by why × back / up / across, by role
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
        int rc_team = -1; long rc_k = 0;   // the last touch's side, and since when
        // Per-match state.
        struct Shot { bool on = false; int team = 0, band = 0; long tick = 0; } shot;
        int last_kick_why = ai::kWhyCount, last_kick_team = -1;
        const bool bh_trace = std::getenv("GAME_BEHIND_TRACE") != nullptr;
        struct Bh { bool led = false; double tx = 0, ty = 0; bool on = false, geo = false, behind = false, air = false; int team = -1, r = -1, runners = 0, z = 0; long k0 = 0, bk = 0;
                    double line = 0, gap = 0, spd = 0, vx = 0, bx = 0, by = 0, rx = 0, ry = 0, best = 1e9, mrx = 0, mry = 0; } bh;
        int owner = -1, owner_team = -1; long owner_got = 0; double own_sx = 0, own_px = 0, own_py = 0;
        bool own_set = false;
        struct Rel { int p = -1, team = -1; double x = 0, y = 0; bool set = false, cross = false, shot = false; } rel;
        int from[32]; long from_t[32], pressed_in[32]; int facing[32];
        for (int j = 0; j < 32; ++j) { from[j] = -1; from_t[j] = -1000; pressed_in[j] = -1; facing[j] = 0; }
        long loss_tick[2] = {-1000, -1000};
        // 5 Hz ring for "3 s before" (ball x, every man's x).
        long rk[16]; double rbx[16], rpx[16][32]; for (long& v : rk) v = -1;
        bool en_arm[2] = {false, false}; double en_prev[2] = {0, 0}; long en_pk[2] = {-100, -100};
        long dead_k0 = -1; int dead_kind = 0, dead_why = 0; char out_note[256] = "";
        struct Tk { int car = -1; long last = -100000; bool faced = false; std::uint32_t pressed = 0; double prev[32]; bool has[32]; } tk{};
        struct Carry { bool on = false, done = false; int pid = -1, att = -1, miss = 0, fr = 0, eng = 0, first = -1; long k0 = 0, last = 0;
                       double btl0 = 0, near0 = 0, close = 0, w5 = 0; bool gs[32] = {}; int r[32] = {}; double rd[32] = {}; } cy;

        for (long k = 0; k < ticks; ++k) {
            const auto before = W.ball().owner;
            s.tickOnce();
            const auto& b = W.ball();
            for (const auto& e : s.lastEvents()) {
                if (e.type == core::MatchEventType::Foul) ++S.fouls;
                if (e.type == core::MatchEventType::TackleWon || e.type == core::MatchEventType::TackleLost) {
                    const double tx = b.pos.x.toDouble() * (e.team == 0 ? 1.0 : -1.0) + hx;   // metres from the tackler's own goal
                    ++S.tkl[e.type == core::MatchEventType::TackleWon ? 0 : 1][tx < 35 ? 0 : tx < 70 ? 1 : 2];
                }
            }
            for (const auto& e : s.lastEvents())
                if (e.type == core::MatchEventType::Goal) {
                    ++S.goals[e.team];
                    if (last_kick_team >= 0 && last_kick_team != e.team) ++S.goal_own;
                    ++S.goal_by[last_kick_why];
                    if (shot.on && shot.team == e.team) { ++S.shot_out[0]; ++S.band_goal[shot.band]; shot.on = false; }
                }
            if (std::getenv("GAME_PLAY_TRACE") && k % 300 == 0)
                std::fprintf(stderr, "play m%d %lds ball %.1f,%.1f,%.1f v %.1f,%.1f owner %d last %d restart %d out %d lastTouch %d pass_to %d\n", m, k / 30, b.pos.x.toDouble(), b.pos.y.toDouble(), b.pos.z.toDouble(),
                             b.vel.x.toDouble(), b.vel.y.toDouble(), b.owner ? *b.owner : -1, b.last_kicker, W.restartTeam(), W.outStage(), W.lastTouchTeam(), b.pass_to);
            {   // in play, and each dead spell by the restart that ends it (benchmarks_tracking_dead.py)
                const bool dead = W.restartTeam() != 0xFF || W.outStage() != 0;
                ++S.tick_n; if (!dead) ++S.tick_live;
                if (dead) { if (dead_k0 < 0) { dead_k0 = k; dead_why = before ? ai::kWhyCount : last_kick_why; } if (W.restartTeam() != 0xFF) dead_kind = static_cast<int>(W.restartKind()); }
                else if (dead_k0 >= 0) {
                    const int kd = std::min(12, std::max(0, dead_kind));
                    ++S.dead_n[kd]; S.dead_s[kd].push_back((k - dead_k0) / 30.0); if (kd == 3 || kd == 4) { ++S.out_by[kd - 3][dead_why]; if (std::getenv("GAME_OUT_TRACE") && dead_why != ai::kWhyCount) std::fprintf(stderr, "out kind %d %s\n", kd, out_note); } dead_k0 = -1; dead_kind = 0;
                }
            }
            if (dead_trace && k % 300 == 0 && W.restartTeam() != 0xFF)
                std::fprintf(stderr, "dead-trace m%d k%ld restart %d kind %d owner %d ball %.1f,%.1f\n", m, k, W.restartTeam(),
                             static_cast<int>(W.restartKind()), b.owner ? *b.owner : -1, b.pos.x.toDouble(), b.pos.y.toDouble());

            if (before && !b.owner && b.last_kicker == *before) {   // a kick
                last_kick_why = static_cast<int>(s.lastOrders()[*before].why);
                last_kick_team = W.player(*before).team;
                if (std::getenv("GAME_OUT_TRACE")) {
                    const auto& lo2 = s.lastOrders()[*before];
                    const auto& kp = W.player(*before);
                    const double sg2 = kp.team == 0 ? 1.0 : -1.0;
                    double rx = 0, ry = 0; if (lo2.other >= 0) { rx = W.player(lo2.other).pos.x.toDouble() * sg2; ry = W.player(lo2.other).pos.y.toDouble(); }
                    std::snprintf(out_note, sizeof out_note, "why %d act %d from %.1f,%.1f tgt %.1f,%.1f carry %d to %d at %.1f,%.1f v %.1f,%.1f,%.1f",
                                  static_cast<int>(lo2.why), static_cast<int>(lo2.action), kp.pos.x.toDouble() * sg2, kp.pos.y.toDouble(),
                                  lo2.target.x.toDouble() * sg2, lo2.target.y.toDouble(), static_cast<int>(lo2.carry_m), lo2.other, rx, ry,
                                  b.vel.x.toDouble() * sg2, b.vel.y.toDouble(), b.vel.z.toDouble());
                }
                // IN BEHIND: an open-play pass to a named man — where he stands against their line at the kick
                const auto& lo = s.lastOrders()[*before];
                if (!own_set && (lo.why == ai::Why::Pass || lo.why == ai::Why::Cross || lo.why == ai::Why::InBehind) && lo.other >= 0 && lo.other < N) {
                    const int tm0 = W.player(*before).team;
                    const double sg = tm0 == 0 ? 1.0 : -1.0;
                    std::vector<double> dx;
                    for (std::uint8_t j = 0; j < N; ++j) if (W.player(j).team != tm0) dx.push_back(W.player(j).pos.x.toDouble() * sg);
                    std::sort(dx.rbegin(), dx.rend());
                    const double bx0 = b.pos.x.toDouble(), by0 = b.pos.y.toDouble();
                    if (lo.why == ai::Why::InBehind) ++S.led;
                    bh = Bh{}; bh.on = true; bh.team = tm0; bh.r = lo.other; bh.k0 = k; bh.bx = bx0; bh.by = by0;
                    bh.air = lo.action == core::Action::LoftedKick;
                    bh.led = lo.why == ai::Why::InBehind; bh.tx = lo.target.x.toDouble(); bh.ty = lo.target.y.toDouble();
                    bh.line = std::max({dx.size() > 1 ? dx[1] : hx, 0.0, bx0 * sg});
                    const auto& rp = W.player(static_cast<std::uint8_t>(lo.other));
                    bh.rx = rp.pos.x.toDouble(); bh.ry = rp.pos.y.toDouble(); bh.gap = bh.line - bh.rx * sg;
                    bh.spd = std::hypot(rp.vel.x.toDouble(), rp.vel.y.toDouble()); bh.vx = rp.vel.x.toDouble() * sg;
                    const double ktl = hx - bx0 * sg;
                    bh.z = (ktl < 18 ? 0 : ktl < 35 ? 1 : ktl < 52 ? 2 : ktl < 70 ? 3 : 4) * 2 + (std::fabs(by0) < 20.16 ? 0 : 1);
                    for (std::uint8_t j = 0; j < N; ++j) {
                        const auto& q = W.player(j);
                        if (q.team != tm0 || j == *before || W.isKeeper(j)) continue;
                        if (std::fabs(bh.line - q.pos.x.toDouble() * sg) < 3 && q.vel.x.toDouble() * sg > 4) ++bh.runners;
                    }
                }
            }
            if (bh.on) {   // the ball's arrival: nearest him in the next 4 s (stop under 1.5 m), then who got it
                const double sg = bh.team == 0 ? 1.0 : -1.0;
                if (bh_trace && bh.led && (k - bh.k0) % 6 == 0 && !bh.geo) {
                    const auto& rp = W.player(static_cast<std::uint8_t>(bh.r));
                    const auto* st = s.brain().stateOf(static_cast<std::uint8_t>(bh.r));
                    std::fprintf(stderr, "   +%.1fs ball %.1f,%.1f,%.1f v %.1f | him %.1f,%.1f v %.1f,%.1f %s why %s tgt %.1f,%.1f pass_to %d\n", (k - bh.k0) / 30.0,
                                 b.pos.x.toDouble(), b.pos.y.toDouble(), b.pos.z.toDouble(), std::hypot(b.vel.x.toDouble(), b.vel.y.toDouble()), rp.pos.x.toDouble(), rp.pos.y.toDouble(),
                                 rp.vel.x.toDouble(), rp.vel.y.toDouble(), st ? st->name() : "?", ai::kWhyNames[static_cast<int>(s.lastOrders()[bh.r].why)],
                                 s.lastOrders()[bh.r].target.x.toDouble(), s.lastOrders()[bh.r].target.y.toDouble(), b.pass_to);
                }
                if (!bh.geo) {
                    const auto& rp = W.player(static_cast<std::uint8_t>(bh.r));
                    const double dd = std::hypot(b.pos.x.toDouble() - rp.pos.x.toDouble(), b.pos.y.toDouble() - rp.pos.y.toDouble());
                    if (k > bh.k0 && dd < bh.best) { bh.best = dd; bh.mrx = rp.pos.x.toDouble(); bh.mry = rp.pos.y.toDouble(); bh.bk = k; }
                    if (dd < 1.5 || k - bh.k0 >= 120 || (b.owner && k > bh.k0) || W.outStage() != 0) {
                        bh.geo = true;
                        const double fwd = (bh.mrx - bh.bx) * sg;
                        ++S.bh_pass;
                        ++S.gap_h[std::max(0, std::min(9, static_cast<int>(std::floor(bh.gap / 2))))];
                        if (fwd > 5) { ++S.bh_fwd; S.bh_frun += bh.runners; }
                        bh.behind = bh.best < 1e8 && fwd > 0 && bh.mrx * sg > bh.line + 0.5;
                    }
                }
                if (bh.geo && (b.owner || W.outStage() != 0 || W.restartTeam() != 0xFF || k - bh.k0 > 300)) {
                    if (bh_trace && bh.led) {
                        const auto& rp = W.player(static_cast<std::uint8_t>(bh.r));
                        std::fprintf(stderr, "led m%d k%ld t%d %s from %.1f,%.1f line %.1f | him %.1f,%.1f gap %.1f v %.1f | spot %.1f,%.1f | met %.1f,%.1f d %.1f after %.1fs | now him %.1f,%.1f | got %d (team %d, him=%d) out %d\n",
                                     m, bh.k0, bh.team, bh.air ? "air" : "ground", bh.bx, bh.by, bh.line, bh.rx, bh.ry, bh.gap, bh.spd, bh.tx, bh.ty, bh.mrx, bh.mry, bh.best,
                                     (bh.bk - bh.k0) / 30.0, rp.pos.x.toDouble(), rp.pos.y.toDouble(), b.owner ? *b.owner : -1, b.owner ? W.player(*b.owner).team : -1,
                                     b.owner && *b.owner == bh.r, W.outStage());
                    }
                    if (bh.behind) {
                        const bool ok = b.owner && W.player(*b.owner).team == bh.team;
                        ++S.bh_n; S.bh_ok += ok; S.bh_air += bh.air; ++S.bh_z[bh.z];
                        S.bh_gap.push_back(bh.gap); S.bh_spd.push_back(bh.spd); S.bh_vx.push_back(bh.vx);
                        S.bh_lead.push_back(std::hypot(bh.mrx - bh.rx, bh.mry - bh.ry)); S.bh_t.push_back((bh.bk - bh.k0) / 30.0);
                        S.bh_len.push_back(std::hypot(bh.mrx - bh.bx, bh.mry - bh.by)); S.bh_past.push_back(bh.mrx * sg - bh.line);
                        S.bh_mtl.push_back(hx - bh.mrx * sg);
                    }
                    bh.on = false;
                }
            }
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
                auto zn = [](double d, double y) { int b = d < 18 ? 0 : d < 35 ? 1 : d < 52 ? 2 : d < 70 ? 3 : 4; return b * 2 + (std::fabs(y) < 20.16 ? 0 : 1); };
                { const int oz = zn(stl, rel.y), ez = zn(etl, ey); ++S.pz_n[oz]; ++S.pz_to[oz][ez]; }
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
                        if (mate && !rel.set && !rel.shot) ++S.pass_ok;
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
                        pressed_in[j] = static_cast<long>(k); ++S.press; ++S.press_why[static_cast<int>(s.lastOrders()[j].why)];
                        { const double ctl = hx - c.pos.x.toDouble() * sg; ++S.press_d[ctl < 18 ? 0 : ctl < 35 ? 1 : ctl < 52 ? 2 : ctl < 70 ? 3 : 4]; } if (k - loss_tick[d.team] <= 150) ++S.cpress;
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
            if (W.lastTouchTeam() <= 1 && W.lastTouchTeam() != rc_team) { rc_team = W.lastTouchTeam(); rc_k = static_cast<long>(k); }
            // ── 5 Hz, in play, the last team on the ball (as DFL flags it) ──
            if (k % 6 != 0 || W.outStage() != 0 || W.restartTeam() != 0xFF || W.lastTouchTeam() > 1) continue;
            const int a = W.lastTouchTeam(), dteam = a ^ 1;
            {   // RECOVERY: the side without it, each outfielder, by seconds since it lost it
                const double since = (static_cast<long>(k) - rc_k) / 30.0;
                const int kb = since < 2 ? 0 : since < 4 ? 1 : since < 6 ? 2 : since < 10 ? 3 : 4;
                const double ds = dteam == 0 ? 1.0 : -1.0;
                for (std::uint8_t j = 0; j < N; ++j) {
                    if (W.isKeeper(j) || W.player(j).team != dteam) continue;
                    const auto& q = W.player(j);
                    const double v = std::hypot(q.vel.x.toDouble(), q.vel.y.toDouble()), back = -q.vel.x.toDouble() * ds;
                    ++S.rc_n[kb]; ++S.rc_s[kb][v < 2 ? 0 : v < 5 ? 1 : 2];
                    if (v >= 5 && back >= 0.7 * v) ++S.rc_fb[kb];
                    if (v >= 5) {
                        ++S.rc_fast[static_cast<int>(s.lastOrders()[j].why)][back >= 0.7 * v ? 0 : back <= -0.7 * v ? 1 : 2];
                        ++S.rc_fast_role[role(j)];
                        if (s.lastOrders()[j].why == ai::Why::Hold && hx + b.pos.x.toDouble() * ds < 40)
                            ++S.rc_hold_near[back >= 0.7 * v ? 0 : back <= -0.7 * v ? 1 : 2];
                    }
                    S.rc_v[kb] += v; S.rc_back[kb] += back;
                    const int z = hx + b.pos.x.toDouble() * ds < 40 ? 0 : 1;
                    ++S.rc_zn[z]; ++S.rc_zk[z][kb];
                    if (v >= 5 && back >= 0.7 * v) ++S.rc_zkb[z][kb];
                    if (z == 0 && s.lastOrders()[j].why == ai::Why::Hold) {
                        const auto& t = s.lastOrders()[j].target;
                        const double g = std::hypot(t.x.toDouble() - q.pos.x.toDouble(), t.y.toDouble() - q.pos.y.toDouble());
                        const int gb = g < 3 ? 0 : g < 8 ? 1 : g < 15 ? 2 : 3;
                        ++S.rc_gap[gb]; if (v >= 5 && back >= 0.7 * v) ++S.rc_gapb[gb];
                    }
                    if (v >= 5) ++S.rc_z[z][back >= 0.7 * v ? 0 : back <= -0.7 * v ? 1 : 2];
                }
            }
            const double sg = a == 0 ? 1.0 : -1.0, bx = b.pos.x.toDouble(), by = b.pos.y.toDouble();
            const double tl = hx - bx * sg;   // ball metres off THEIR line
            const int ri = static_cast<int>((k / 6) % 16), rj = static_cast<int>(((k / 6) + 1) % 16);   // rj = 15 frames back
            const bool then_ok = rk[rj] == k - 90;
            {   // shapes
                const int bd = std::min(9, std::max(0, static_cast<int>(tl / 10)));   // ball metres off the defenders' own line
                const int bp = std::min(9, std::max(0, static_cast<int>(tl / 10)));
                double dm = 0, pm = 0, back = -1e9, front = 1e9; int dn = 0, pn = 0;
                for (std::uint8_t j = 0; j < N; ++j) {
                    if (W.isKeeper(j)) continue;
                    const auto& q = W.player(j);
                    const int r = role(j);
                    if (q.team == dteam) {
                        const double v = hx + q.pos.x.toDouble() * (dteam == 0 ? 1.0 : -1.0);   // off his own line
                        S.ds_s[bd][r] += v; ++S.ds_n[bd][r]; dm += v; ++dn;
                        if (std::getenv("GAME_HOLD_TRACE") && s.lastOrders()[j].why == ai::Why::Hold &&
                            (std::getenv("GAME_HOLD_TRACE")[0] == 'a' || r == 1 || r == 4)) {
                            const auto* st = s.brain().stateOf(j);
                            const double ds = dteam == 0 ? 1.0 : -1.0;
                            const auto& lo = s.lastOrders()[j];
                            std::fprintf(stderr, "hold k %ld slot %d r %d band %d %s own %s | at %.1f tgt %.1f dy %.1f | vx %.2f vy %.2f | mv %.2f,%.2f face %.2f,%.2f\n", k, j, r, bd,
                                         st ? st->name() : "?", b.owner ? "carried" : "free", hx + q.pos.x.toDouble() * ds, hx + lo.target.x.toDouble() * ds,
                                         lo.target.y.toDouble() - q.pos.y.toDouble(), -q.vel.x.toDouble() * ds, q.vel.y.toDouble(),
                                         -lo.move.move.x.toDouble() * ds, lo.move.move.y.toDouble(), q.face.x.toDouble() * ds, q.face.y.toDouble());
                        }
                        if (s.lastOrders()[j].why == ai::Why::Hold) {
                            ++S.dt_n[bd][r]; S.dt_s[bd][r] += hx + s.lastOrders()[j].target.x.toDouble() * (dteam == 0 ? 1.0 : -1.0);
                            S.dt_v[bd][r] += -q.vel.x.toDouble() * (dteam == 0 ? 1.0 : -1.0);
                            S.dt_a[bd][r] += v;
                        }
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
            if (tl < 52) {   // in the box, by the ball's zone (benchmarks_tracking_box.py)
                const int bz = (tl < 18 ? 0 : tl < 35 ? 1 : 2) * 2 + (std::fabs(by) < 20.16 ? 0 : 1);
                ++S.bx_f[bz];
                for (std::uint8_t j = 0; j < N; ++j) {
                    if (W.isKeeper(j) || W.player(j).team != a) continue;
                    const double ptl = hx - W.player(j).pos.x.toDouble() * sg;
                    if (ptl < 18 && std::fabs(W.player(j).pos.y.toDouble()) < 20.16) ++S.bx_in[bz];
                    if (s.lastOrders()[j].why == ai::Why::AttackBox) { ++S.bx_run[bz]; S.bx_run_tl[bz] += hx - s.lastOrders()[j].target.x.toDouble() * sg; }
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
                {   // the DFL cut (benchmarks_tracking_pressure.py): spells by proximity, 5 Hz
                    if (cr < 0) { if (tk.car >= 0 && k - tk.last > 30) { if (tk.faced) ++S.tk_takeon; tk.car = -1; } }
                    else {
                        if (tk.car != cr || k - tk.last > 60) {
                            if (tk.car >= 0 && tk.faced) ++S.tk_takeon;
                            tk.car = cr; tk.faced = false; tk.pressed = 0; for (bool& h : tk.has) h = false; ++S.tk_spells;
                        }
                        tk.last = k; ++S.tk_frames;
                        const auto& q = W.player(static_cast<std::uint8_t>(cr));
                        const int z = tl < 18 ? 0 : tl < 35 ? 1 : tl < 52 ? 2 : tl < 70 ? 3 : 4;
                        for (std::uint8_t j = 0; j < N && j < 32; ++j) {
                            if (W.player(j).team == a || W.isKeeper(j)) continue;
                            const double dx = W.player(j).pos.x.toDouble() - q.pos.x.toDouble(), dy = W.player(j).pos.y.toDouble() - q.pos.y.toDouble();
                            const double dd = std::hypot(dx, dy);
                            if (tk.has[j] && dd < 4.5 && (tk.prev[j] - dd) / 0.2 >= 1.0 && !((tk.pressed >> j) & 1u)) { tk.pressed |= 1u << j; ++S.tk_press; ++S.tk_press_z[z]; }
                            tk.prev[j] = dd; tk.has[j] = true;
                            const double ahead = dx * sg;
                            if (!tk.faced && dd < 1.5 && ahead > 0 && std::fabs(dy) <= ahead) tk.faced = true;
                        }
                    }
                }
                if (cy.on && (cy.att != a || k - cy.last > 18 || (cr >= 0 && cr != cy.pid))) cy.on = false;
                bool skip = false;
                if (cy.on && cr < 0) {
                    const auto& q = W.player(static_cast<std::uint8_t>(cy.pid));
                    if (std::hypot(q.pos.x.toDouble() - bx, q.pos.y.toDouble() - by) > 4 || cy.miss >= 2) cy.on = false;
                    else { ++cy.miss; cy.last = k; }
                    skip = true;
                }
                if (cr >= 0) {   // the nearest defender to the man on the ball (DFL: benchmarks_tracking_press.py)
                    double nd2 = 1e9;
                    for (std::uint8_t j = 0; j < N; ++j)
                        if (!W.isKeeper(j) && W.player(j).team != a)
                            nd2 = std::min(nd2, std::hypot(W.player(j).pos.x.toDouble() - W.player(static_cast<std::uint8_t>(cr)).pos.x.toDouble(),
                                                           W.player(j).pos.y.toDouble() - W.player(static_cast<std::uint8_t>(cr)).pos.y.toDouble()));
                    const int nb = tl < 18 ? 0 : tl < 35 ? 1 : tl < 52 ? 2 : tl < 70 ? 3 : 4;
                    if (nd2 < 1e8) S.near_band[nb].push_back(nd2);
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
        std::printf("\n   goals by the last kick before them:");
        for (int i = 0; i <= ai::kWhyCount; ++i) if (S.goal_by[i]) std::printf(" %s %ld;", i < ai::kWhyCount ? ai::kWhyNames[i] : "none", S.goal_by[i]);
        std::printf(" (own goals %ld)", S.goal_own);
        static const char* rbn[5] = {"<12 m", "12-18", "18-25", "25-35", "35+"};
        std::printf("\n   of the balls let go in open play, the share that were shots:");
        for (int i = 0; i < 5; ++i) std::printf(" %s %.1f%% (of %.1f a team-match);", rbn[i], 100.0 * S.rel_shot[i] / std::max(1L, S.rel_n[i]), S.rel_n[i] / tm);
        std::printf("\n");
    }
    std::printf("CONCEPT ACTS a team-match (StatsBomb cuts; real PL 15/16 in brackets): pressures %.1f (151.8), counter-press %.1f = %.1f%% (21.0%%); passes %.1f (433.8): switches %.2f (10.69), crosses %.2f (11.47), cut-backs %.2f (1.03); take-ons %.2f tried (18.05), %.2f completed (10.59); return passes %.2f (42.11) = %.1f%% of passes after a receipt (15.7%%); carries 10 m+ %.2f (34.64)\n",
                S.press / tm, S.cpress / tm, 100.0 * S.cpress / std::max(1L, S.press), S.passes / tm, S.switches / tm, S.crosses / tm, S.cutbacks / tm,
                S.takeon / tm, S.takeon_ok / tm, S.ret / tm, 100.0 * S.ret / std::max(1L, S.ret_base), S.carry10 / tm);
    std::printf("   passes completed %.1f%% (79.1%%)\n", 100.0 * S.pass_ok / std::max(1L, S.passes));
    {
        std::printf("BALL IN PLAY %.1f%% of the match (real DFL 55.2%%); dead before each restart, a team-match / median s (real):", 100.0 * S.tick_live / std::max(1L, S.tick_n));
        static const char* kn[13] = {"?", "goal", "throw-in", "goal kick", "corner", "kick-off", "", "", "", "", "offside FK", "", "free kick"};
        static const char* rl[13] = {"", "", "19.9 / 13.8", "7.1 / 23.2", "3.2 / 32.8", "1.0 / 64.2", "", "", "", "", "offsides ~1.1", "", "10.5 / 32.5"};
        for (int i = 0; i < 13; ++i) {
            if (!S.dead_n[i]) continue;
            auto v = S.dead_s[i]; std::sort(v.begin(), v.end());
            std::printf(" %s %.1f / %.1f (%s);", kn[i], S.dead_n[i] / tm, v[v.size() / 2], rl[i]);
        }
        std::printf("\n");
        for (int g = 0; g < 2; ++g) {   // what put it over the byline: the last kick's why, or carried out
            std::printf("   %s by what put it out (a team-match; StatsBomb PL 15/16 %s):", g ? "corners" : "goal kicks",
                        g ? "5.4: clearance 1.38, block 1.34, shot 0.92, keeper save 0.60, dispossessed 0.43, dribble 0.23"
                          : "8.3: shot 4.28, pass 2.65 (air 2.18), miscontrol 0.64, block 0.39, dribble 0.11");
            for (int y = 0; y <= ai::kWhyCount; ++y)
                if (S.out_by[g][y]) std::printf(" %s %.2f;", y == ai::kWhyCount ? "carried out" : ai::kWhyNames[y], S.out_by[g][y] / tm);
            std::printf("\n");
        }
    }
    std::printf("   TACKLES a team-match won / lost, by the tackler's own third / middle / their third (StatsBomb tackle duels 10.30 7.82 2.20, fouls 2.78 6.71 3.02):");
    for (int z = 0; z < 3; ++z) std::printf(" %.1f/%.1f", S.tkl[0][z] / tm, S.tkl[1][z] / tm);
    std::printf("; fouls %.1f (12.52, advantage 1.73)\n", S.fouls / tm);
    std::printf("   THE DFL CUT (5 Hz, man on the ball = nearest within 2 m; real DFL benchmarks_tracking_pressure.py): spells %.1f (640.4), %.2f s each (1.21); pressures %.1f (375.2) = %.2f a spell (0.59), by the carrier's metres off their line",
                S.tk_spells / tm, 0.2 * S.tk_frames / std::max(1L, S.tk_spells), S.tk_press / tm, static_cast<double>(S.tk_press) / std::max(1L, S.tk_spells));
    { static const double rz[5] = {40.8, 80.1, 89.0, 91.1, 74.2}; for (int i = 0; i < 5; ++i) std::printf(" %.1f (%.1f)", S.tk_press_z[i] / tm, rz[i]); }
    std::printf("; take-ons %.1f (44.2)\n", S.tk_takeon / tm);
    std::printf("   pressures by the presser's why:");
    for (int i = 0; i < ai::kWhyCount; ++i) if (S.press_why[i]) std::printf(" %s %.1f;", ai::kWhyNames[i], S.press_why[i] / tm);
    std::printf("\n   pressures by the ball's metres from the pressers' own line... (carrier off THEIR line 0-18/18-35/35-52/52-70/70+):");
    for (int i = 0; i < 5; ++i) std::printf(" %.1f", S.press_d[i] / tm);
    std::printf("\n");
    {
        static const char* zz[10] = {"0-18 centre", "0-18 wide", "18-35 centre", "18-35 wide", "35-52 centre", "35-52 wide", "52-70 centre", "52-70 wide", "70+ centre", "70+ wide"};
        std::printf("   PASS POLICY as played (origin: passes a team-match | share to each end zone [0]..[9] as benchmarks_statsbomb_passes.py):\n");
        for (int o = 0; o < 10; ++o) {
            if (!S.pz_n[o]) continue;
            std::printf("     %-12s %6.1f |", zz[o], S.pz_n[o] / tm);
            for (int d = 0; d < 10; ++d) std::printf(" %4.1f", 100.0 * S.pz_to[o][d] / S.pz_n[o]);
            std::printf("\n");
        }
    }
    {
        static const char* nbn[5] = {"0-18", "18-35", "35-52", "52-70", "70+"};
        static const double real_med[5] = {2.1, 3.0, 3.9, 5.5, 8.0};
        std::printf("   NEAREST DEFENDER to the man on the ball, median by the ball's metres from their line (real DFL):");
        for (int i = 0; i < 5; ++i) {
            auto& v = S.near_band[i];
            if (v.empty()) continue;
            std::nth_element(v.begin(), v.begin() + v.size() / 2, v.end());
            std::printf(" %s %.1f (%.1f);", nbn[i], v[v.size() / 2], real_med[i]);
        }
        std::printf("\n");
    }
    {
        static const char* bzn[6] = {"0-18 centre", "0-18 wide", "18-35 centre", "18-35 wide", "35-52 centre", "35-52 wide"};
        static const double real_in[6] = {3.45, 2.29, 1.04, 0.79, 0.13, 0.09};
        std::printf("   IN THE BOX (ours, 0-18 m |y| < 20.16) by the ball's zone (real DFL):");
        for (int z = 0; z < 6; ++z) if (S.bx_f[z]) std::printf(" %s %.2f (%.2f) [runners %.2f, target %.1f m];", bzn[z], static_cast<double>(S.bx_in[z]) / S.bx_f[z], real_in[z],
                                                             static_cast<double>(S.bx_run[z]) / S.bx_f[z], S.bx_run_tl[z] / std::max(1L, S.bx_run[z]));
        std::printf("\n");
    }
    {
        auto med = [](std::vector<double> v) { if (v.empty()) return 0.0; std::sort(v.begin(), v.end()); return v[v.size() / 2]; };
        const double nb = std::max(1L, S.bh_n);
        std::printf("   IN BEHIND (met past their line as it stood at the kick; real DFL in brackets): %.1f a team-match (37.7) = %.1f%% of named passes (10.4%%), completed %.0f%% (47.5%%), in the air %.0f%% (58%%)\n",
                    S.bh_n / tm, 100.0 * S.bh_n / std::max(1L, S.bh_pass), 100.0 * S.bh_ok / nb, 100.0 * S.bh_air / nb);
        std::printf("     medians: his gap short of the line at the kick %.1f m (2.0), speed %.1f m/s (3.8), toward goal %.1f (2.7); runs to it %.1f m (10.2); ball to him %.1f s (2.8); pass %.1f m (24.6); met %.1f m past the line (5.2), %.1f m off their line (23.2)\n",
                    med(S.bh_gap), med(S.bh_spd), med(S.bh_vx), med(S.bh_lead), med(S.bh_t), med(S.bh_len), med(S.bh_past), med(S.bh_mtl));
        static const double real_z[10] = {2.00, 1.43, 4.79, 4.43, 6.14, 4.00, 4.79, 3.36, 4.57, 2.21};
        static const char* zz[10] = {"0-18c", "0-18w", "18-35c", "18-35w", "35-52c", "35-52w", "52-70c", "52-70w", "70+c", "70+w"};
        std::printf("     balls played in behind (the led pass): %.1f a team-match\n", S.led / tm);
        static const double real_gh[10] = {8.0, 5.9, 5.0, 4.5, 4.9, 4.5, 4.6, 4.3, 3.9, 53.1};
        std::printf("     named passes by the man's gap short of their line (2 m bins, 0..18+; real DFL %%):");
        for (int g = 0; g < 10; ++g) std::printf(" %d: %.1f%% (%.1f);", 2 * g, 100.0 * S.gap_h[g] / std::max(1L, S.bh_pass), real_gh[g]);
        std::printf("\n");
        std::printf("     from (a team-match):");
        for (int z = 0; z < 10; ++z) std::printf(" %s %.2f (%.2f);", zz[z], S.bh_z[z] / tm, real_z[z]);
        std::printf("\n     forward passes (5+ m on) %.1f a team-match (145.3); runners at the line (within 3 m, 4+ m/s at goal) %.2f a pass (0.06)\n",
                    S.bh_fwd / tm, static_cast<double>(S.bh_frun) / std::max(1L, S.bh_fwd));
    }
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
    {
        long tot = 0; for (int i = 0; i < 5; ++i) tot += S.rc_n[i];
        static const char* lab[5] = {"0-2", "2-4", "4-6", "6-10", "10+"};
        std::printf("RECOVERY (the side without it, outfielders, 5 Hz, by s since it lost it; real DFL benchmarks_tracking_recover.py):\n"
                    "   since  share | under 2 / 2-5 / 5+ m/s | 5+ back | mean m/s, back m/s\n");
        long s0 = 0, s1 = 0, s2 = 0, fb = 0; double sv = 0, sb = 0;
        for (int i = 0; i < 5; ++i) {
            const long n = S.rc_n[i]; if (!n) continue;
            std::printf("   %5s %5.1f%% | %5.1f %5.1f %5.1f | %5.1f | %.2f, %+.2f\n", lab[i], 100.0 * n / tot, 100.0 * S.rc_s[i][0] / n,
                        100.0 * S.rc_s[i][1] / n, 100.0 * S.rc_s[i][2] / n, 100.0 * S.rc_fb[i] / n, S.rc_v[i] / n, S.rc_back[i] / n);
            s0 += S.rc_s[i][0]; s1 += S.rc_s[i][1]; s2 += S.rc_s[i][2]; fb += S.rc_fb[i]; sv += S.rc_v[i]; sb += S.rc_back[i];
        }
        long fast = 0; for (int w = 0; w < ai::kWhyCount; ++w) fast += S.rc_fast[w][0] + S.rc_fast[w][1] + S.rc_fast[w][2];
        if (fast) {
            std::printf("   5+ m/s by why, %% of the side's 5+ steps (back / up / across):");
            for (int w = 0; w < ai::kWhyCount; ++w) {
                const long n = S.rc_fast[w][0] + S.rc_fast[w][1] + S.rc_fast[w][2];
                if (n * 200 >= fast) std::printf(" %s %.1f (%.1f/%.1f/%.1f);", ai::kWhyNames[w], 100.0 * n / fast, 100.0 * S.rc_fast[w][0] / fast,
                                                 100.0 * S.rc_fast[w][1] / fast, 100.0 * S.rc_fast[w][2] / fast);
            }
            static const char* rn[ai::kRoleCount] = {"CB", "FB", "DM/CM", "AM", "WIDE", "ST"};
            std::printf("\n   of which hold shape with the ball inside 40 m of their goal %.1f (%.1f/%.1f/%.1f)", 100.0 * (S.rc_hold_near[0] + S.rc_hold_near[1] + S.rc_hold_near[2]) / fast,
                        100.0 * S.rc_hold_near[0] / fast, 100.0 * S.rc_hold_near[1] / fast, 100.0 * S.rc_hold_near[2] / fast);
            for (int z = 0; z < 2; ++z)
                if (S.rc_zn[z])
                    std::printf("\n   5+ m/s %s: %.1f%% of steps; back / up / across %.2f / %.2f / %.2f%% of them", z ? "further out" : "ball inside 40 m of their goal",
                                100.0 * S.rc_zn[z] / tot, 100.0 * S.rc_z[z][0] / S.rc_zn[z], 100.0 * S.rc_z[z][1] / S.rc_zn[z], 100.0 * S.rc_z[z][2] / S.rc_zn[z]);
            static const char* kl[5] = {"0-2", "2-4", "4-6", "6-10", "10+"};
            for (int z = 0; z < 2; ++z) {
                std::printf("\n   5+ m/s back %s by s since lost (share of the zone's steps):", z ? "further out" : "inside 40 m");
                for (int i = 0; i < 5; ++i)
                    if (S.rc_zk[z][i]) std::printf(" %s %.1f (%.0f%%);", kl[i], 100.0 * S.rc_zkb[z][i] / S.rc_zk[z][i], 100.0 * S.rc_zk[z][i] / S.rc_zn[z]);
            }
            std::printf("\n   holders inside 40 m by metres off their spot <3 / 3-8 / 8-15 / 15+: share of holder steps, 5+ back:");
            {
                long gt = 0; for (long g : S.rc_gap) gt += g;
                for (int i = 0; i < 4; ++i) if (gt && S.rc_gap[i]) std::printf(" %.0f%% %.1f;", 100.0 * S.rc_gap[i] / gt, 100.0 * S.rc_gapb[i] / S.rc_gap[i]);
            }
            std::printf("\n   5+ m/s by role, %% of the side's 5+ steps:");
            for (int r = 0; r < ai::kRoleCount; ++r) std::printf(" %s %.1f%%;", rn[r], 100.0 * S.rc_fast_role[r] / fast);
            std::printf("\n");
        }
        if (tot) std::printf("     all        | %5.1f %5.1f %5.1f | %5.1f | %.2f, %+.2f\n", 100.0 * s0 / tot, 100.0 * s1 / tot, 100.0 * s2 / tot,
                             100.0 * fb / tot, sv / tot, sb / tot);
    }
    std::printf("DEFENDING SHAPE (the side without it; metres from its own line, ball band = ball m from that line):\n   band    frames  middle      CB      FB   DM/CM      AM    WIDE      ST\n");
    for (int k = 0; k < 10; ++k) {
        if (!S.ds_f[k]) continue;
        std::printf("   %2d-%-3d %7ld  %5.1f   ", 10 * k, 10 * k + 10, S.ds_f[k], S.ds_mid[k] / S.ds_f[k]);
        for (int r = 0; r < ai::kRoleCount; ++r) std::printf("  %6.1f", S.ds_n[k][r] ? S.ds_s[k][r] / S.ds_n[k][r] : 0.0);
        std::printf("   holders' target");
        for (int r = 0; r < ai::kRoleCount; ++r) std::printf(" %5.1f", S.dt_n[k][r] ? S.dt_s[k][r] / S.dt_n[k][r] : 0.0);
        std::printf(" | holders at");
        for (int r = 0; r < ai::kRoleCount; ++r) std::printf(" %5.1f", S.dt_n[k][r] ? S.dt_a[k][r] / S.dt_n[k][r] : 0.0);
        std::printf(" | back m/s");
        for (int r = 0; r < ai::kRoleCount; ++r) std::printf(" %4.1f", S.dt_n[k][r] ? S.dt_v[k][r] / S.dt_n[k][r] : 0.0);
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
