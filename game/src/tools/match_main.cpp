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
//
// Play-practice-play (G4.59, DESIGN §8.55): GAME_PHASE="code:team" turns
// the run into N EPISODES of that phase of play instead of matches (team 0
// = home in possession). Each episode sets the phase up, plays it, and ends
// at the first of: a goal, the other team owning the ball, a dead ball given
// to them, or GAME_PHASE_SECONDS (default 30) with the ball still ours.
// The report is the coach's: did the restart get played, did we get over
// halfway and into the final third, how long it took, did we shoot, and
// where we lost it. Episode 1 prints the set-up.

#include "ai/Brain.hpp"
#include "core/Clock.hpp"
#include "net/INetworkTransport.hpp"
#include "server/GameServer.hpp"
#include "persistence/FormationStore.hpp"
#include "server/MatchSetup.hpp"

#include <algorithm>
#include <array>
#include <map>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

using namespace fh::game;

namespace {

long g_hold_tv[2][5], g_hold_tv_n[2]; double g_hold_tv_sum[2];   // G5.6 diag
long g_blk_sp[5], g_blk_n; double g_blk_v, g_blk_xx, g_blk_yy, g_blk_mx, g_blk_my, g_blk_lx;
// G5.7: where the block without the ball STANDS by ball position (5 Hz), as
// benchmarks_tracking_shift.py reads DFL: 15 m bins of ball depth from its
// own goal line → back line / middle / top man; 10 m bins of |ball y| → middle y.
long g_rk_n, g_ra_n; double g_rk[10], g_rk_far, g_ra[10];   // G5.7: ranked y, ball wide
long g_aw_n[128]; double g_aw_y[128], g_aw_t[128];   // attackers on the far side (y < -10), ball wide
long g_lw_n[128]; double g_lw_y[128], g_lw_t[128];   // G5.7 diag: ball |y| 24+, by why
long g_blocks[2];
// G5.11: a cross's first touch — [high?][0 ours foot, 1 ours head, 2 theirs foot, 3 theirs head, 4 keeper, 5 out]
double g_cx_tx, g_cx_ty, g_cx_kx, g_cx_ky; // G5.12: ball wide 0-18, by role [att/def][role 0 CB 1 FB-ball 2 FB-far 3 DM 4 AM 5 WIDE-ball 6 WIDE-far 7 ST]: frames, in box; out-of-box jobs
long g_ch_n, g_ch_chan[2], g_ch_box[2], g_ch_ahead[7], g_ch_run[7], g_ch_why[128];   // G5.13: ball wide 18-35, last touch
long g_wt_n[2][7][2], g_wt_why[2][7][2][128], g_nd_lim[5]; double g_wt_a[2][7][2], g_wt_y[2][7][2], g_nd_sum, g_wt_anc[7][2], g_wt_ancy[7][2], g_line_sum; // G5.17 (§8.114): concept acts a team-match, counted as StatsBomb tags them — benchmarks: concepts (StatsBomb PL 15/16)
long g_ca_press, g_ca_cpress, g_ca_pass, g_ca_switch, g_ca_cross, g_ca_cutback, g_ca_drib, g_ca_dribok, g_ca_ret, g_ca_rtp, g_ca_carry10;
long g_dsh_n[10][7], g_dsh_f[10], g_dsh_why[7][128], g_dsh_wn[7]; double g_dsh_s[10][7], g_dsh_m[10], g_dsh_an[10][7], g_dsh_ot[10][7], g_dsh_da[10][7], g_dsh_ht[10][7], g_dsh_hp[10][7], g_dsh_hv[10][7]; long g_dsh_hn[10][7];   // G5.15 defending shape by ball band
long g_fa_n[7], g_fa_hn[7]; double g_fa_a[7], g_fa_v[7], g_fa_5[7], g_fa_5f[7], g_fa_h[7], g_fa_hv[7];   // G5.15 front men by possession age
long g_h3_n[7][2], g_h3_bn; double g_h3_ball, g_h3_adv[7][2], g_h3_was[7][2], g_h3_b15; long g_h3_age[4];   // G5.15 three seconds before, ball wide 18-35
long g_ag_n[7]; double g_ag_b[7], g_ag_m[7], g_ag_v[7], g_ag_5[7], g_ag_5f[7]; long g_hl_n[4], g_hf_n[7]; double g_hf_fx[7], g_hf_ay[7], g_hf_d[7]; double g_hl_d[4], g_hl_v[4], g_hl_vt[4], g_hl_want[4];   // G5.14 holders' lag
long g_ps_n[10][7], g_ps_f[10], g_ps_gn[7]; double g_ps_s[10][7], g_ps_back[10], g_ps_mid[10], g_ps_front[10], g_ps_g[7], g_ps_N, g_ps_B, g_ps_M, g_ps_BB, g_ps_BM;   // G5.14 possession shape
long g_wt_ancn[7][2], g_wt_tn[7][2], g_wt_hn[7][2]; double g_wt_t[7][2], g_wt_h[7][2], g_wt_hp[7][2];   // G5.14: where they stand
long g_ws_n, g_ws_end[6], g_ws_from[6], g_ws_to[6], g_ws_why[128], g_ws_pwhy[128], g_ws_ticks;   // G5.13: spells starting wide 18-35
double g_ws_carry_m;
long g_zn[4][2], g_zl[4][2];   // G5.12: possession by zone, 5 Hz [0-18, 18-35, 35-70, 70+][centre, wide]
long g_br_n[2][8], g_br_box[2][8], g_br_why[2][8][128], g_br_tin[2][8]; double g_br_late[2][8];
long g_cx_until = -1, g_cx_n, g_cx_bin[2][4]; std::vector<double> g_cx_d[2];   // G5.11: the same, first drop after a high open-play cross (4 s)
long g_dr_n, g_dr_bin[2][4], g_dr_why[128], g_dr_go[5]; double g_dr_go_d = 0; long g_dr_tg[4], g_dr_sp[3]; double g_dr_pz = 0; std::vector<double> g_dr_d[2];   // G5.11: a ball dropping through 2.4 m in a box — nearest defender [0] / attacker [1]
long g_cf_md[2][6][6]; double g_cf_min = 1e9, g_cf_minv = 0;   // G5.11 diag: nearest opponent to a cross's flight (below 1.5 m), by outcome
long g_cf[2][6], g_cf_n[2]; int g_cf_on = 0, g_cf_team = -1, g_cf_kicker = -1, g_cf_high = 0; double g_cf_z = 0;
long g_bpw[128];
long g_dw_n[128]; double g_dw_tl[128], g_dw_ttl[128];   // four deepest defenders' jobs, ball wide 18-30
long g_ab_n, g_dl_n; double g_ab_gap, g_ab_v, g_ab_tl, g_ab_ttl, g_dl_gap, g_dl_v, g_dl_tl, g_dl_ttl;   // G5.9 diag: runners / back line   // G5.9 diag: jobs of the 3 most advanced attackers, ball wide 0-18
double g_bp_l1[2], g_bp_l2[2];
long g_bp_n[2], g_bp_tgt0[2]; double g_bp_box[2], g_bp_tgt[2], g_bp_dbox[2];   // G5.9 box presence, ball wide 0-18 / 18-30
int g_cr_on = 0, g_cr_team = -1; long g_cr_tick = 0; double g_cr_pz = 0; int g_cr_traced = 0;   // G5.9 cross trace
long g_xin_carry, g_xin_pass, g_xin_pass_wide;   // G5.9: arrivals in the crossing zone (18 m off their line, |y| 14+)   // G5.9: body blocks by the blocking team
long g_lv_n[7], g_ly_n[4]; double g_lv_line[7], g_lv_mid[7], g_lv_top[7], g_ly_mid[4], g_ly_ball[4];
double g_hold_num[12]; long g_hold_num_n[12], g_hold_num_fast[12];

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
        gm->overlay[id] = gm->own[id] = static_cast<std::int16_t>(std::atoi(item.c_str() + eq + 1));
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

double median(std::vector<double> v) {
    if (v.empty()) return 0.0;
    std::sort(v.begin(), v.end());
    return v[v.size() / 2];
}

// GAME_PHASE episodes: the phase's own scoreboard, from the possessing
// team's side. Distances are metres from that team's own goal line.
int runPhaseEpisodes(const server::GameServer::Config& base, const server::MatchNames& names,
                     const std::string& spec, int episodes) {
    const auto colon = spec.find(':');
    const std::string code = spec.substr(0, colon);
    const int team = colon == std::string::npos ? 0 : std::atoi(spec.c_str() + colon + 1);
    std::size_t phase = base.phases.size();
    for (std::size_t p = 0; p < base.phases.size(); ++p)
        if (base.phases[p].code == code) phase = p;
    if (phase == base.phases.size() || team < 0 || team > 1) {
        std::fprintf(stderr, "GAME_PHASE '%s': no such phase (or team not 0/1); phases:", spec.c_str());
        for (const auto& ph : base.phases) std::fprintf(stderr, " %s", ph.code.c_str());
        std::fprintf(stderr, "\n");
        return 2;
    }
    const long cap = std::atol(envOr("GAME_PHASE_SECONDS", "30")) * core::kTickRate;
    const int trace = std::atoi(envOr("GAME_PHASE_TRACE", "0"));
    const char* watch = envOr("GAME_PHASE_WATCH", "");
    const std::uint64_t seed0 = std::strtoull(envOr("GAME_MATCH_SEED", "1000"), nullptr, 10);
    const std::string& us = team == 0 ? names.team_home : names.team_away;
    const std::string& them = team == 0 ? names.team_away : names.team_home;
    enum End { Goal, Conceded, LostOwn, LostMid, LostFinal, OutToThem, Kept, EndCount };
    const char* end_names[EndCount] = {"scored", "conceded (their counter)", "lost it in our third",
                                       "lost it in the middle third", "lost it in their third",
                                       "dead ball to them (out / offside)", "still ours at the cap"};
    long ends[EndCount] = {}, played = 0, halfway = 0, third = 0, shot = 0;
    long passes = 0;
    // Where their build-up goes (G4.64), by the receiver's position number:
    // full-back 2/3, centre-back 4/5, the middle 6/8/10, else. A full-back's
    // pass back to a centre-back is the return pass the 9 locks out.
    std::map<std::pair<int, int>, long> by_number;   // (passer, receiver) numbers
    long to_fb = 0, to_cb = 0, to_mid = 0, to_else = 0, fb_to_cb = 0, fb_rx = 0, lost_after_fb = 0;
    // How each loss happened: taken off the carrier's foot, or the last
    // kick we made (by its reason) going to them.
    long lost_carry = 0, lost_kick[ai::kWhyCount + 1] = {}, losses = 0;
    long kicks[ai::kWhyCount + 1] = {};
    std::vector<double> t_play, t_half, t_third, depth_max, lost_at, kept_s;
    // The defending side (G4.63): how close the nearest defender is on each
    // first touch, and seconds of each defender order per episode.
    std::vector<double> touch_gap, touch_gap_short;
    double kick_x = 0, kick_y = 0;
    long d_why[ai::kWhyCount] = {}, d_ticks = 0;
    // Their 9 while we build (G4.99, James 10/30: "lh 9 is still going after
    // cb of ukies"): his job, by who has the ball or who it's going to —
    // keeper, centre-back 4/5, the middle 6/8/10, full-back 2/3 — in our half.
    const char* const nine_names[4] = {"keeper", "centre-back", "the middle", "full-back"};
    long nine_n[4] = {}, nine_job[4][ai::kWhyCount] = {}, nine_on[4] = {}, nine_cb[4] = {}, nine_cb_job[4][ai::kWhyCount] = {};
    // G4.70-71 calls, [0 = us, 1 = them][why]: man-ticks a call was due to a
    // talker / he made it / a listener heard one.
    long call_due[2][ai::kWhyCount] = {}, call_made[2][ai::kWhyCount] = {}, call_heard[2][ai::kWhyCount] = {};
    for (int m = 0; m < episodes; ++m) {
        server::GameServer::Config cfg = base;
        cfg.match_seed = seed0 + static_cast<std::uint64_t>(m);
        NullTransport t;
        server::GameServer s{cfg, t};
        s.runPhase(static_cast<std::uint8_t>(team), phase);
        const double hx = s.world().pitchHalfX().toDouble();
        auto from_goal = [&](double x) { return team == 0 ? x + hx : hx - x; };
        if (m == 0)
            for (std::uint8_t i = 0; i < s.world().playerCount(); ++i) {
                const auto& pl = s.world().player(i);
                const double x = pl.pos.x.toDouble(), y = pl.pos.y.toDouble();
                const bool home = pl.team == 0;
                std::printf("  %s slot %2d: %5.1f m from own goal, %+5.1f m across\n",
                            home ? names.team_home.c_str() : names.team_away.c_str(), i,
                            home ? x + hx : hx - x, home ? y : -y);
            }
        // Dead-ball phases wait for the restart to be played; open play is live.
        bool live = s.world().restartTeam() == 0xFF;
        if (live) t_play.push_back(0.0);
        int end = Kept, shots = 0, ep_passes = 0, last_ours = -1, last_kick = -1;
        double deepest = 0.0, where = 0.0;
        bool got_half = false, got_third = false;
        long k = 0;
        long fb_tick = -1000;
        int last_toucher = s.world().ball().last_kicker;
        int tracked = -1;
        for (; k < cap; ++k) {
            const auto before = s.world().ball().owner;
            s.tickOnce();
            const auto& b = s.world().ball();
            const double sec = (k + 1) / static_cast<double>(core::kTickRate);
            bool done = false;
            for (const auto& e : s.lastEvents())
                if (e.type == core::MatchEventType::Goal) { end = e.team == team ? Goal : Conceded; done = true; }
            if (done) break;
            if (!live) {
                if (s.world().restartTeam() != 0xFF) continue;
                live = true;
                t_play.push_back(sec);
            } else if (s.world().restartTeam() != 0xFF) {
                if (s.world().restartTeam() != team) { end = OutToThem; where = from_goal(b.pos.x.toDouble()); break; }
                continue;   // our throw / corner: the phase goes on
            }
            if (before && !b.owner && b.last_kicker == *before && s.world().player(*before).team == team) {
                const ai::Orders& o = s.lastOrders()[*before];
                last_kick = o.rung >= 1 && o.rung <= 2 ? ai::kWhyCount : static_cast<int>(o.why);
                kick_x = b.pos.x.toDouble(); kick_y = b.pos.y.toDouble();
                if (trace == m + 1 && o.other >= 0) {
                    const auto& r = s.world().player(static_cast<std::uint8_t>(o.other));
                    const double dx = r.pos.x.toDouble() - b.pos.x.toDouble(), dy = r.pos.y.toDouble() - b.pos.y.toDouble();
                    std::printf("  t=%4.2f KICK %s by slot %d to slot %d, %.1f m away (at %.1f m, %+.1f across), ball %.1f m/s\n", sec,
                                ai::kWhyNames[static_cast<int>(o.why)], *before, o.other, std::sqrt(dx * dx + dy * dy),
                                from_goal(r.pos.x.toDouble()), team == 0 ? r.pos.y.toDouble() : -r.pos.y.toDouble(),
                                std::sqrt(b.vel.x.toDouble() * b.vel.x.toDouble() + b.vel.y.toDouble() * b.vel.y.toDouble()));
                    tracked = o.other;
                    // Their men at the kick: what each is doing, how far from the receiver.
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == team) continue;
                        const ai::Orders& dj = s.lastOrders()[j];
                        const double ex = d.pos.x.toDouble() - r.pos.x.toDouble(), ey = d.pos.y.toDouble() - r.pos.y.toDouble();
                        std::printf("           them slot %2d %-22s %5.1f m from the receiver%s\n", j, ai::kWhyNames[static_cast<int>(dj.why)],
                                    std::sqrt(ex * ex + ey * ey), dj.other >= 0 ? (" → slot " + std::to_string(dj.other)).c_str() : "");
                    }
                }
                ++kicks[last_kick];
                if (o.why == ai::Why::Shoot) ++shots;
            }
            // Traced: every touch that doesn't stick (a bobble / deflection).
            if (trace == m + 1 && !b.owner && before == b.owner && b.last_kicker != last_toucher)
                std::printf("  t=%4.2f TOUCH slot %d (%s) at %.1f m/s — didn't keep it\n", sec, b.last_kicker,
                            ai::kWhyNames[static_cast<int>(s.lastOrders()[b.last_kicker].why)],
                            std::sqrt(b.vel.x.toDouble() * b.vel.x.toDouble() + b.vel.y.toDouble() * b.vel.y.toDouble()));
            last_toucher = b.last_kicker;
            {
                int who = b.owner ? *b.owner : s.lastOrders()[b.last_kicker].other;
                const int wn = who >= 0 ? s.brain().numberOf(static_cast<std::uint8_t>(who)) : 0;
                const int zone = s.world().isKeeper(static_cast<std::uint8_t>(who < 0 ? 0 : who)) ? 0
                               : wn == 4 || wn == 5 ? 1 : wn == 6 || wn == 8 || wn == 10 ? 2 : wn == 2 || wn == 3 ? 3 : -1;
                if (who >= 0 && zone >= 0 && s.world().player(static_cast<std::uint8_t>(who)).team == team &&
                    from_goal(b.pos.x.toDouble()) < hx)
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == team || s.brain().numberOf(j) != 9) continue;
                        auto gap = [&](std::uint8_t o) {
                            const auto& p = s.world().player(o);
                            return std::hypot(d.pos.x.toDouble() - p.pos.x.toDouble(), d.pos.y.toDouble() - p.pos.y.toDouble());
                        };
                        ++nine_n[zone];
                        ++nine_job[zone][static_cast<int>(s.lastOrders()[j].why)];
                        if (gap(static_cast<std::uint8_t>(who)) < 3.0) ++nine_on[zone];
                        for (std::uint8_t o = 0; o < s.world().playerCount(); ++o) {
                            const int on = s.brain().numberOf(o);
                            if (s.world().player(o).team == team && (on == 4 || on == 5) && gap(o) < 3.0) {
                                ++nine_cb[zone];
                                ++nine_cb_job[zone][static_cast<int>(s.lastOrders()[j].why)];
                                break;
                            }
                        }
                    }
            }
            // GAME_PHASE_TRACE=n: episode n, twice a second — who has it,
            // what he's doing, where, and how close the nearest opponent is.
            // GAME_PHASE_WATCH=9,7,11: the defending side's men with those
            // numbers on the traced episode — what each is doing, and where.
            if (trace == m + 1 && k % (core::kTickRate / 2) == 0 && watch[0]) {
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                    const auto& d = s.world().player(j);
                    if (d.team == team) continue;
                    const int num = s.brain().numberOf(j);
                    bool want = false;
                    for (const char* q = watch; *q;) {
                        want = want || std::atoi(q) == num;
                        while (*q && *q != ',') ++q;
                        if (*q == ',') ++q;
                    }
                    if (want) {
                        const int o = s.lastOrders()[j].other;
                        std::printf("  t=%4.1f   watch #%d slot %d %-22s at %5.1f m, %+5.1f across", sec, num, j,
                                    ai::kWhyNames[static_cast<int>(s.lastOrders()[j].why)],
                                    from_goal(d.pos.x.toDouble()), team == 0 ? d.pos.y.toDouble() : -d.pos.y.toDouble());
                        if (o >= 0) std::printf(" → their #%d (slot %d)", s.brain().numberOf(static_cast<std::uint8_t>(o)), o);
                        std::printf("\n");
                    }
                }
            }
            if (trace == m + 1 && k % (core::kTickRate / 2) == 0) {
                if (b.owner) {
                    const auto& c = s.world().player(*b.owner);
                    double near = 1e9;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == c.team) continue;
                        const double dx = d.pos.x.toDouble() - c.pos.x.toDouble(), dy = d.pos.y.toDouble() - c.pos.y.toDouble();
                        near = std::min(near, std::sqrt(dx * dx + dy * dy));
                    }
                    std::printf("  t=%4.1f slot %2d %-22s at %5.1f m, %+5.1f across, nearest opponent %.1f m\n", sec, *b.owner,
                                ai::kWhyNames[static_cast<int>(s.lastOrders()[*b.owner].why)],
                                from_goal(c.pos.x.toDouble()), team == 0 ? c.pos.y.toDouble() : -c.pos.y.toDouble(), near);
                } else {
                    // Loose: the nearest man of each side and what he's doing.
                    int nb[2] = {-1, -1};
                    double nd[2] = {1e9, 1e9};
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        const double dx = d.pos.x.toDouble() - b.pos.x.toDouble(), dy = d.pos.y.toDouble() - b.pos.y.toDouble();
                        const double dd = std::sqrt(dx * dx + dy * dy);
                        const int side = d.team == team ? 0 : 1;
                        if (dd < nd[side]) { nd[side] = dd; nb[side] = j; }
                    }
                    if (tracked >= 0) {
                        const auto& r = s.world().player(static_cast<std::uint8_t>(tracked));
                        const double dx = r.pos.x.toDouble() - b.pos.x.toDouble(), dy = r.pos.y.toDouble() - b.pos.y.toDouble();
                        std::printf("  t=%4.1f   receiver slot %d %.1f m from the ball, %s\n", sec, tracked, std::sqrt(dx * dx + dy * dy),
                                    ai::kWhyNames[static_cast<int>(s.lastOrders()[tracked].why)]);
                    }
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j)
                        if (s.lastOrders()[j].why == ai::Why::JumpPass) {
                            const auto& d = s.world().player(j);
                            const auto& o = s.lastOrders()[j];
                            const auto& r = s.world().player(static_cast<std::uint8_t>(o.other));
                            const double ex = d.pos.x.toDouble() - r.pos.x.toDouble(), ey = d.pos.y.toDouble() - r.pos.y.toDouble();
                            const double tx = d.pos.x.toDouble() - o.target.x.toDouble(), ty = d.pos.y.toDouble() - o.target.y.toDouble();
                            std::printf("  t=%4.1f   JUMP slot %d on slot %d: %.1f m from him, %.1f m from his spot, %.1f m/s\n", sec, j, o.other,
                                        std::sqrt(ex * ex + ey * ey), std::sqrt(tx * tx + ty * ty),
                                        std::sqrt(d.vel.x.toDouble() * d.vel.x.toDouble() + d.vel.y.toDouble() * d.vel.y.toDouble()));
                        }
                    std::printf("  t=%4.1f ball loose at %5.1f m, %+5.1f across, %.1f m/s | ours: slot %d %.1f m %s | theirs: slot %d %.1f m %s\n",
                                sec, from_goal(b.pos.x.toDouble()), team == 0 ? b.pos.y.toDouble() : -b.pos.y.toDouble(),
                                std::sqrt(b.vel.x.toDouble() * b.vel.x.toDouble() + b.vel.y.toDouble() * b.vel.y.toDouble()),
                                nb[0], nd[0], ai::kWhyNames[static_cast<int>(s.lastOrders()[nb[0]].why)],
                                nb[1], nd[1], ai::kWhyNames[static_cast<int>(s.lastOrders()[nb[1]].why)]);
                }
            }
            if (live)
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j)
                    if (s.world().player(j).team != team && !s.world().isKeeper(j)) {
                        ++d_why[static_cast<int>(s.lastOrders()[j].why)];
                        ++d_ticks;
                    }
            if (live)
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                    const ai::Orders& o = s.lastOrders()[j];
                    const int side = s.world().player(j).team == team ? 0 : 1;
                    if (o.due != ai::Why::Hold) ++call_due[side][static_cast<int>(o.due)];
                    if (o.call_to >= 0) ++call_made[side][static_cast<int>(o.call)];
                    if (o.heard != ai::Why::Hold) ++call_heard[side][static_cast<int>(o.heard)];
                }
            if (!b.owner) continue;
            const auto& c = s.world().player(*b.owner);
            const double g = from_goal(b.pos.x.toDouble());
            if (c.team != team) {
                where = g;
                end = g < hx * 2 / 3 ? LostOwn : g < hx * 4 / 3 ? LostMid : LostFinal;
                ++losses;
                if (k - fb_tick <= 5 * core::kTickRate) ++lost_after_fb;
                if (before && s.world().player(*before).team == team) ++lost_carry;
                else if (last_kick >= 0) ++lost_kick[last_kick];
                break;
            }
            if (!before) {   // a first touch: how close is their nearest man?
                double near = 1e9;
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                    const auto& d = s.world().player(j);
                    if (d.team == team) continue;
                    const double dx = d.pos.x.toDouble() - c.pos.x.toDouble(), dy = d.pos.y.toDouble() - c.pos.y.toDouble();
                    near = std::min(near, std::sqrt(dx * dx + dy * dy));
                }
                touch_gap.push_back(near);
                const double kx = c.pos.x.toDouble() - kick_x, ky = c.pos.y.toDouble() - kick_y;
                if (std::sqrt(kx * kx + ky * ky) <= 25.0) touch_gap_short.push_back(near);
            }
            last_kick = -1;   // ours again: the kick reached a mate
            if (last_ours >= 0 && *b.owner != last_ours) {
                ++ep_passes;
                const int rn = s.brain().numberOf(*b.owner), pn = s.brain().numberOf(static_cast<std::uint8_t>(last_ours));
                const bool fb = rn == 2 || rn == 3;
                ++by_number[{pn, rn}];
                if (fb) { ++to_fb; ++fb_rx; fb_tick = k; }
                else if (rn == 4 || rn == 5) { ++to_cb; if (pn == 2 || pn == 3) ++fb_to_cb; }
                else if (rn == 6 || rn == 8 || rn == 10) ++to_mid;
                else ++to_else;
            }
            last_ours = *b.owner;
            if (g > deepest) deepest = g;
            if (!got_half && g > hx) { got_half = true; t_half.push_back(sec); }
            if (!got_third && g > hx * 4 / 3) { got_third = true; t_third.push_back(sec); }
        }
        ++ends[end];
        played += live;
        halfway += got_half; third += got_third;
        shot += shots > 0;
        passes += ep_passes;
        depth_max.push_back(deepest);
        kept_s.push_back(k / static_cast<double>(core::kTickRate));
        if (end >= LostOwn && end <= OutToThem) lost_at.push_back(where);
        std::printf("episode %3d: %-34s %4.1f s | %2d passes | deepest %5.1f m", m + 1, end_names[end],
                    k / static_cast<double>(core::kTickRate), ep_passes, deepest);
        if (shots) std::printf(" | %d shot%s", shots, shots > 1 ? "s" : "");
        if (end >= LostOwn && end <= OutToThem) std::printf(" | lost at %.1f m", where);
        std::printf("\n");
    }
    const double n = episodes;
    std::printf("\nPhase '%s', %s in possession against %s: %d episodes, cap %ld s\n", code.c_str(),
                us.c_str(), them.c_str(), episodes, cap / core::kTickRate);
    std::printf("  restart played     %5.1f%%  (median %.1f s)\n", 100.0 * played / n, median(t_play));
    std::printf("  over halfway       %5.1f%%  (median %.1f s)\n", 100.0 * halfway / n, median(t_half));
    std::printf("  into final third   %5.1f%%  (median %.1f s)\n", 100.0 * third / n, median(t_third));
    std::printf("  got a shot         %5.1f%%\n", 100.0 * shot / n);
    std::printf("  kept the ball      %5.1f s (median episode)\n", median(kept_s));
    std::printf("  passes completed   %5.1f per episode; deepest ball %.1f m (median)\n", passes / n, median(depth_max));
    {
        const long all = to_fb + to_cb + to_mid + to_else;
        if (all)
            std::printf("  passes to: full-back %.0f%% · centre-back %.0f%% · the middle (6/8/10) %.0f%% · else %.0f%% (of %ld)\n"
                        "  full-back back to a centre-back: %.2f per episode; lost within 5 s of a pass to a full-back: %.0f%% (of %ld)\n",
                        100.0 * to_fb / all, 100.0 * to_cb / all, 100.0 * to_mid / all, 100.0 * to_else / all, all,
                        fb_to_cb / n, fb_rx ? 100.0 * lost_after_fb / fb_rx : 0.0, fb_rx);
        std::vector<std::pair<long, std::pair<int, int>>> top;
        for (const auto& [k2, v] : by_number) top.push_back({v, k2});
        std::sort(top.rbegin(), top.rend());
        if (!top.empty()) std::printf("  commonest passes (by number):");
        for (std::size_t i = 0; i < top.size() && i < 8; ++i)
            std::printf(" %d→%d %ld", top[i].second.first, top[i].second.second, top[i].first);
        if (!top.empty()) std::printf("\n");
    }
    std::printf("  how it ended:\n");
    for (int e = 0; e < EndCount; ++e)
        if (ends[e]) std::printf("    %-36s %5.1f%%\n", end_names[e], 100.0 * ends[e] / n);
    if (!lost_at.empty()) std::printf("  lost it %.1f m from our goal (median)\n", median(lost_at));
    if (losses) {
        std::printf("  how the ball was lost (of %ld): taken off the carrier %.0f%%", losses, 100.0 * lost_carry / losses);
        for (int w = 0; w <= ai::kWhyCount; ++w)
            if (lost_kick[w])
                std::printf(" · %s %.0f%%", w == ai::kWhyCount ? "in behind" : ai::kWhyNames[w], 100.0 * lost_kick[w] / losses);
        std::printf("\n  kicks per episode:");
        for (int w = 0; w <= ai::kWhyCount; ++w)
            if (kicks[w]) std::printf(" %s %.2f", w == ai::kWhyCount ? "in behind" : ai::kWhyNames[w], kicks[w] / n);
        std::printf("\n");
    }
    if (!touch_gap.empty()) {
        long tight = 0;
        for (double g : touch_gap) tight += g <= 2.0;
        std::printf("  %s on our first touch: nearest man %.1f m (median), within 2 m %.0f%% (of %zu)\n", them.c_str(),
                    median(touch_gap), 100.0 * tight / touch_gap.size(), touch_gap.size());
        tight = 0;
        for (double g : touch_gap_short) tight += g <= 2.0;
        if (!touch_gap_short.empty())
            std::printf("    after a pass of 25 m or less: nearest man %.1f m (median), within 2 m %.0f%% (of %zu)\n",
                        median(touch_gap_short), 100.0 * tight / touch_gap_short.size(), touch_gap_short.size());
    }
    if (d_ticks) {
        for (int z = 0; z < 4; ++z) {
            if (!nine_n[z]) continue;
            std::printf("  their 9, ball with %-11s %5.1f s/ep: on him %2.0f%%, within 3 m of a CB %2.0f%%; doing:", nine_names[z],
                        static_cast<double>(nine_n[z]) / core::kTickRate / std::max(1, episodes),
                        100.0 * nine_on[z] / nine_n[z], 100.0 * nine_cb[z] / nine_n[z]);
            for (int w = 0; w < ai::kWhyCount; ++w)
                if (nine_job[z][w] * 100 >= nine_n[z] * 4)
                    std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * nine_job[z][w] / nine_n[z]);
            std::printf(" | by a CB:");
            for (int w = 0; w < ai::kWhyCount; ++w)
                if (nine_cb[z] && nine_cb_job[z][w] * 100 >= nine_cb[z] * 10)
                    std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * nine_cb_job[z][w] / nine_cb[z]);
            std::printf("\n");
        }
        std::printf("  %s outfield orders (share of man-ticks):", them.c_str());
        for (int w = 0; w < ai::kWhyCount; ++w)
            if (d_why[w] * 1000 >= d_ticks) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * d_why[w] / d_ticks);
            else if (d_why[w]) std::printf(" %s %.2f%%", ai::kWhyNames[w], 100.0 * d_why[w] / d_ticks);   // rare: still shown
        std::printf("\n");
    }
    for (int side = 0; side < 2; ++side) {
        bool head = false;
        for (int w = 0; w < ai::kWhyCount; ++w) {
            if (!call_due[side][w]) continue;
            if (!head) std::printf("  %s calls:", (side == 0 ? us : them).c_str());
            head = true;
            std::printf(" | %s: due %.1f s/ep, made %.0f%%, heard by %.2f per call", ai::kWhyNames[w] + 6,
                        call_due[side][w] / 30.0 / n, 100.0 * call_made[side][w] / call_due[side][w],
                        call_made[side][w] ? static_cast<double>(call_heard[side][w]) / call_made[side][w] : 0.0);
        }
        if (head) std::printf("\n");
    }
    return 0;
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
    // G5.17: GAME_DEMAND="counter-press=40,switch-play=30" — A/B a concept's
    // demand (every model, both teams) without touching the DB.
    if (const char* gd = std::getenv("GAME_DEMAND")) {
        std::string s = gd;
        std::size_t at = 0;
        while (at < s.size()) {
            std::size_t end = s.find(',', at);
            if (end == std::string::npos) end = s.size();
            const std::string item = s.substr(at, end - at);
            const std::size_t eq = item.find('=');
            const int id = eq == std::string::npos ? -1 : core::concepts().find(item.substr(0, eq));
            if (id >= 0) {
                for (auto& gm : base.models) gm.overlay[id] = static_cast<std::int16_t>(std::atoi(item.c_str() + eq + 1));
                std::printf("demand: %s (concept %d)\n", item.c_str(), id);
            } else std::printf("demand: %s UNKNOWN concept\n", item.c_str());
            at = end + 1;
        }
    }
    // Try a team on another of its tactics (a model name) without changing
    // what the team plays.
    if (const char* gm = std::getenv("GAME_MODEL_HOME")) base.roster_home.game_model = gm;
    applyOverrides(base, argc > 3 ? argv[3] : "-", true);
    applyOverrides(base, argc > 4 ? argv[4] : "-", false);

    if (const char* gp = std::getenv("GAME_PHASE"))
        return runPhaseEpisodes(base, names, gp, matches);

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
    double carrier_near[6] = {};     // G5.4: <2, 2-5, 5-10, 10+, sum m, n
    long conv_shots[5] = {}, conv_goals[5] = {};  // G5.4
    int conv_bin[2] = {0, 0};
    long conv_k[2] = {-100000, -100000};
    int st_team = -1, st_cand = -1, st_cand_slot = -1; long st_cand_tick = 0, st_start = 0, st_spells = 0, st_ticks = 0, st_high[2] = {0, 0}; double st_cand_x = 0;  // G5.4
    double pass_dir[3][2][6] = {};   // G5.4: third, pressed: n, fwd, square, back, gain, dist
    // Line height (G4.55): every live tick a team is out of possession, its
    // back line (deepest outfielder) and front (most advanced) in metres
    // from its own goal, and the ball's. Real: the line ~35-45 m out, the
    // team ~30-35 m long, the line ~20-25 m behind the ball.
    double ln_sum[2] = {0, 0}, front_sum[2] = {0, 0}, ball_sum[2] = {0, 0};
    long ln_ticks[2] = {0, 0}, ln_deep[2] = {0, 0};
    long oop_why[2][ai::kWhyCount] = {}, oop_n[2] = {0, 0};   // outfielders' reasons out of possession
    // G4.80: the crowd (outfielders within 10 m of the ball, carrier
    // excluded) and the spread (outfield width x length), by team, with the
    // ball [0] and without [1]; overruns = player-ticks moving > 2.5 m/s
    // AWAY from his own target while within 2.5 m of it (ran past it).
    double crowd_sum[2][2] = {}, wide_sum[2][2] = {}, long_sum[2][2] = {};
    long crowd_ticks[2][2] = {}, overrun[2] = {0, 0}, overrun_why[2][ai::kWhyCount] = {};
    // Off his position: outfielder-ticks > 10 m from his ball-shifted
    // formation spot, by why, with [0] / without [1] the ball.
    long off_ticks[2][2] = {}, off_n[2][2] = {}, off_why[2][2][ai::kWhyCount] = {};
    double off_sum[2][2] = {};
    long ip_why[2][ai::kWhyCount] = {}, ip_n[2] = {0, 0};   // outfielders' reasons in possession (off the ball)
    // G5.0 rest defence: full-backs wider than their man; the back five
    // goal-side of him with the ball past him.
    long fb_n[2] = {}, fb_wide[2] = {}, fb_wide3[2] = {}, back_n[2] = {}, back_goal_side[2] = {}, fb_wide_why[2][ai::kWhyCount] = {};
    // G5.1 how many they leave up: with the ball in their half, by how many
    // of their outfielders it is past [up]: ticks, our outfielders behind
    // the ball, and our back five marking (PreventiveMark).
    long up_ticks[2][8] = {}, up_behind[2][8] = {}, up_marks[2][8] = {}, up_short[2][8] = {};
    // ... and by where the ball is (metres from halfway, the pro script's
    // zones): mates ahead of the ball, the same count the freeze frames give.
    long zn_ticks[2][3] = {}, zn_ahead[2][3] = {}, num_ahead[2][12] = {}, num_n[2][12] = {};
    // Each number against the ball and the spot his orders want, by zone;
    // and the deepest of their outfielders against the ball.
    double zn_x[2][3][12] = {}, zn_tx[2][3][12] = {}, zn_line[2][3] = {};
    long zn_xn[2][3][12] = {};
    // ... by how old the spell is: does the team get there given time?
    long age_ticks[2][3][4] = {}, age_ahead[2][3][4] = {};
    // Possession spells (a team's ball, from winning it to losing it), and
    // a man holding shape's gap to the spot he holds, in the first 5 s of
    // his team's spell [0] or after [1] — lag behind a shape that moved.
    long spells = 0, spell_ticks = 0;
    // Shot anatomy (G4.81): each shot by the spell's age when it was hit
    // (transition < 10 s vs settled), the defending outfielders goal-side
    // of the ball, its distance, the nearest defender. Rest defence: at
    // each change of possession, the LOSING team's outfielders goal-side
    // of the ball. Real: most shots come from settled attacks against
    // 6-9 men behind the ball; a counter faces 3-4.
    long shot_age[2][4] = {}, shot_behind[2][4] = {}, shot_dist[2][4] = {}, shot_near[2][4] = {};
    long shot_n[2] = {0, 0}, rest_hist[2][12] = {}, rest_n[2] = {0, 0};
    // ...and the shooter's own touch: defenders goal-side of him when he GOT
    // it (beaten by the ball to him vs by his carry), the metres he carried,
    // where his team won the ball (m from the goal it attacks).
    long recv_behind[2][4] = {}, carry_m[2][4] = {}, won_at[2][4] = {};
    // How a team loses the ball within 35 m of its OWN goal: the why of its
    // last kick in that spell (+ kick metres, ball height), or dispossessed
    // on the ball (no kick), and how long it had held it.
    long own3_lost[2][ai::kWhyCount + 1] = {}, own3_n[2] = {0, 0}, own3_age[2][4] = {};
    double own3_kick_m[2] = {0, 0}; long own3_kicks[2] = {0, 0};
    long own3_rwhy[2][ai::kWhyCount] = {}, own3_rn[2] = {0, 0};
    double own3_rgap[2] = {0, 0}, own3_igap[2] = {0, 0};
    long own3_first[2][5] = {};
    // Every pass to a picked man (not shots/clears/punts), by how free he was
    // at the kick (his nearest opponent): played / to him / lost.
    long fr_n[2][4] = {}, fr_got[2][4] = {}, fr_lost[2][4] = {};
    // An own-third loss the winners shoot from — inside 10 s / that spell
    // (benchmark own_third_loss_shot_*), counted on the LOSING team.
    long own3_shot10[2] = {0, 0}, own3_shot_spell[2] = {0, 0};
    // How each spell ended (G4.82), by the LOSING team: 0 pass, 1 clear (or
    // punt), 2 shot, 3 bad touch, 4 on the ball (tackled / stolen).
    long end_cause[2][5] = {}, ends[2] = {0, 0};
    // A pass the other side took: cut out while still travelling (>= 3 m/s
    // the tick before — StatsBomb's Interception) or picked up slower (a
    // recovery), by the team that TOOK it; and every bobble (bad touch).
    long cut[2] = {0, 0}, picked[2] = {0, 0}, bobbles[2] = {0, 0};
    // ...each bad touch (G4.85): whose ball it was (the pass meant for him /
    // another of ours / theirs — a reaction touch) × its speed the tick before.
    long bt_kind[3][4] = {};
    // ...the defender's side of it (G4.86): every touch on THEIR moving ball
    // (3 m/s+), kept or off him, by his job and his own speed (<2 / 2-4 / 4-6
    // / 6+ m/s) — is the reaction touch a lunge or a man who was set?
    // The officials (G4.88): offsides whistled against each team; whistles for
    // an onside man and offside touches nobody flagged (World counters); men
    // flagged wrong / missed at each kick into their half; where the judging
    // assistant stood off level with the line (+ = beyond it).
    // Each offside whistle (G4.89): the kick it came off, was he the man it
    // was played to, his job at the kick, how far past the line he stood.
    long ow_n = 0, ow_why[ai::kWhyCount + 1] = {}, ow_intended = 0, ow_job[ai::kWhyCount] = {}, ow_depth[4] = {};
    // Men standing in an offside position at a kick (G4.91): by job, by how
    // far past, how long he has been there; and the kicks with one.
    // Passes to a mate by his gap to the law's line at the kick (G4.92): 3 m+
    // onside / 1-3 onside / within 1 m onside / within 1 m offside / 1 m+
    // offside — and how many of each the assistant flagged.
    long tg_n[5] = {}, tg_flag[5] = {}, tg_all = 0;
    // Time on the ball before a pass (G4.92; benchmark time_on_ball_s):
    // from his first touch of it to the kick, passes to a mate only.
    // Own-third dispossessions (G4.95): how long he'd had it, was he still in
    // his control touch, what he and the man who took it were doing.
    // Balls in behind (G4.96): at the kick, the runner's and his nearest
    // defender's speed toward goal, the gap between them, the defender's job.
    // The home 9 while their centre-back (4/5) has it (G4.97, James 10/29:
    // "lh 9 is supposed to sit and cover shadow"): his job, split by whether
    // the centre-back is driving forward (2 m/s+ toward our goal).
    long n9_n[2] = {}, n9_job[2][ai::kWhyCount] = {}, n9_near[2] = {};
    // The passer of a ball in behind (G4.98): at the kick — his nearest
    // opponent, how long he'd had it, where he stood, how far past their
    // last outfielder he aimed it, ladder fire or plain gain.
    long pb_n = 0, pb_near[3] = {}, pb_held[4] = {}, pb_zone[3] = {}, pb_depth[4] = {}, pb_fire = 0, pb_loft = 0;
    // Every pass aimed past their last outfield man at the kick, 3 m+ forward
    // (G4.98) — the pro's question from the 360 freeze frames
    // (benchmarks_statsbomb_360.py): per team, reached a mate, lofted, from
    // his own half, his nearest opponent inside 2.5 m, how far past the line.
    long bl_n[2] = {}, bl_mate[2] = {}, bl_why[2][ai::kWhyCount + 1] = {}, bl_loft = 0, bl_own = 0, bl_pressed = 0, bl_depth[4] = {};
    bool pend_bl = false;
    long bh_n = 0, bh_gap[4] = {}, bh_dv[4] = {}, bh_job[ai::kWhyCount] = {}, bh_face_back = 0;
    long dp_n = 0, dp_held[4] = {}, dp_in_touch = 0, dp_carrier[ai::kWhyCount] = {}, dp_taker[ai::kWhyCount] = {};
    long tob_n = 0, tob_b[4] = {}; double tob_s = 0; long got_tick[64] = {};
    long op_men = 0, op_kicks = 0, op_all_kicks = 0, op_job[ai::kWhyCount] = {}, op_depth[4] = {}, op_age[4] = {};
    long off_called[2] = {}, off_wrong = 0, off_missed = 0, flag_wrong = 0, flag_missed = 0, flag_kicks = 0;
    // G5.2: restarts — per kind (0 throw, 1 goal kick, 2 corner): how many per
    // team, seconds dead (ball over the line → played), kept / shot within 10 s.
    long rs_goal[3] = {};
    long rs_n[3][2] = {}, rs_kept[3] = {}, rs_shot[3] = {}, rs_called_by[3] = {}, rs_deflect = 0;
    // G5.5 (§8.103): what put it out, as benchmarks_statsbomb_out.py counts it.
    // 0 ground pass, 1 air pass, 2 clearance, 3 shot, 4 keeper kick, 5 keeper
    // touch, 6 outfield touch (block, tackle, poke), 7 carried out.
    long oc_n[3][8] = {}, oc_clear_kicks = 0;
    // G5.8: clearances by where they're struck (0 box, 1 own third, 2 beyond ×
    // 0 centre |y|<12, 1 mid, 2 wide 24+), as clr.py reads StatsBomb.
    long oc_cz_n[3][3] = {}, oc_cz_throw[3][3] = {}, oc_cz_corner[3][3] = {};
    int oc_cz = -1;
    long rel_n[4] = {}, rel_clear[4] = {};
    long xz_n[4][3] = {}, xz_cross[4][3] = {};   // G5.9: releases by m off their line (0-6, 6-18, 18-30, 30+) x width   // G5.8: foot releases by zone (box, own3, mid, final 3rd)
    int oc_kicker = -1, oc_cat = -1;
    long oc_owned_tick = -100, oc_kick_tick = 0;
    double oc_from[2] = {}, oc_to[2] = {}, oc_speed = 0;
    int oc_other = -1, oc_near_why = -1;
    std::vector<std::string> oc_log;
    double oc_near = 1e9, oc_near_v = 0, oc_near_z = 0, oc_near_run = 0;
    long oc_near_hist[6] = {}, oc_rx_n[5] = {}, oc_rx_out[5] = {}, oc_rx_lead_n = 0, oc_dead_cat[8] = {};
    int oc_rx_bin = -1;
    long oc_rx_why[ai::kWhyCount + 1] = {}, oc_sp_t[3] = {}, oc_sp_why[ai::kWhyCount + 1] = {};
    int oc_prev_why[64] = {};
    long oc_sp_gap[ai::kWhyCount + 1][4] = {}, oc_sp_side[2] = {};
    double oc_sp_v = 0;
    double oc_rx_lead = 0;
    std::vector<double> rs_dead[3], rs_len[3];
    int rs_open = -1, rs_team = 0, rs_watch = -1, rs_watch_team = 0, rs_keep_check = -1;
    int rs_last = -1, rs_last_team = 0, rs_trace = 0, rs_trace_n = 0;
    long rs_last_tick = 0;
    int rs_headers_at_kick = 0;
    int air_seen[2] = {};
    long air_tick[2] = {-1, -1}, air_scored[2] = {};   // G5.3
    long air_duels = 0, air_lone = 0, air_goal[2] = {}, air_clear[2] = {};   // G5.3
    bool rs_traced_owner = false;
    const int trace_corner = std::atoi(envOr("GAME_TRACE_CORNER", "0"));
    double rs_dead_s = 0, rs_start_x = 0, rs_start_y = 0;
    long rs_played_tick = -1, rs_tick = 0, rs_wrong_total = 0, rs_dead_ticks = 0, rs_ticks = 0;
    long ar_off[5] = {};
    double ar_off_sum = 0;
    long rt_n[2][ai::kWhyCount] = {}, rt_sp[2][4] = {}, rt_rel[2][4] = {};
    // ...balls in behind the read gave to THEM at the kick (G4.86): how far
    // the strike went off his aim, and where their man meets it — in the lane
    // before the spot, at it (±3 m), or after it ran on.
    long ib_n = 0, ib_err[4] = {}, ib_where[3] = {}, ib_all_read[2] = {}, ib_theirs_read[2] = {};
    bool kick_read = false;
    long ib_seen[2] = {}, ib_age[4] = {}, ib_loft_all[2] = {}, ib_loft_theirs[2] = {};   // read & theirs: their man in the passer's view at the kick; the passer's look age
    // ...each interception: how far the man moved from where he stood at the
    // kick (< 1 m = he was in the lane), how long the pass had flown, and
    // the pass's kind (by its why).
    long pred_all[3] = {}, pred_cut[3] = {}, pred_why[ai::kWhyCount + 1][3] = {};
    // Cut passes the flight read gave to US: was the cutter their predicted
    // first man; our predicted man's job 0.3 s in; the margin we had (ticks).
    long po_n = 0, po_cutter_pred = 0, po_us_why[ai::kWhyCount] = {}, po_margin[4] = {};   // passes (any kind) by the flight read at kick+1, and the cut ones
    long cut_moved[4] = {}, cut_time[4] = {}, cut_n = 0, cut_by_why[ai::kWhyCount + 1] = {}, cut_why_taker[ai::kWhyCount] = {};
    double hold_gap[2] = {0, 0};
    long hold_n[2] = {0, 0};
    for (int m = 0; m < matches; ++m) {
        server::GameServer::Config cfg = base;
        cfg.match_seed = seed0 + static_cast<std::uint64_t>(m);
        NullTransport t;
        server::GameServer s{cfg, t};
        int pend_team = -1, pend_why = 0, pend_other = -1;
        int last_assist[2] = {ai::kWhyCount + 1, ai::kWhyCount + 1};
        bool shot_breakaway[2] = {false, false};
        bool in_third[2] = {false, false};
        int spell_team = -1;
        long spell_start = 0;
        int rx_slot = -1, rx_behind = 0;
        int lk_to[2] = {-1, -1};
        double prev_ball_v = 0;
        int prev_ltt = -1, prev_pass_to = -1;
        double prev_bvx = 0, prev_bvy = 0;
        std::uint64_t prev_ctrl_until = 0;
        std::vector<int> prev_why(64, 0);
        std::vector<std::array<double, 2>> prev_ov(64, {0.0, 0.0});   // everyone's velocity last tick
        std::vector<math::Vec2> kick_at;   // everyone's spot at the last kick
        long kick_tick = 0;
        math::Vec2 kick_aim{}, kick_from{};
        int kick_passer = -1;
        std::vector<long> off_since(64, 0);   // the tick each man last stood onside (G4.91)
        std::vector<int> kick_job;   // everyone's job at the last kick
        int kick_pred = -1;
        int pred_us = -1, pred_them = -1, pred_margin = 0, pred_us_why = -1;   // at kick+1 / +10
        // GAME_TRACE_FLIP=n: passes the read gave to us that they cut (match 1).
        static const int trace_flip = std::atoi(envOr("GAME_TRACE_FLIP", "0"));
        int flips = 0;
        std::vector<std::string> flip_lines;   // flight read one tick after the kick: 0 ours first, 1 theirs first, 2 nobody
        std::uint64_t prev_bad = 0;
        // GAME_TRACE_LOST=n: print the first n own-third lost kicks (match 1).
        static const int trace_lost = std::atoi(envOr("GAME_TRACE_LOST", "0"));
        int traced = 0;
        int lk_rwhy10[2] = {-1, -1}, lk_first10[2] = {-9, -9};
        int pf_bucket = -1;
        int o3_team = -1; long o3_tick = 0; bool o3_10 = false, o3_any = false;   // the spell an own-third loss started
        // GAME_TRACE_FREE=n: the first n passes to a man 10 m+ free that went
        // wrong (match 1): the kick, then who touched it.
        static const int trace_free = std::atoi(envOr("GAME_TRACE_FREE", "0"));
        int tf_done = 0; long tf_tick = -1; int tf_to = -1, tf_team = -1; double tf_len = 0;
        std::string tf_line;
        std::vector<std::string> tf_ticks;   // GAME_TRACE_FREE_TICKS=1: the flight, every 6 ticks
        static const bool tf_verbose = std::atoi(envOr("GAME_TRACE_FREE_TICKS", "0")) != 0;
        std::vector<math::Vec2> lk_snap[2];
        double lk_tx[2] = {0, 0}, lk_ty[2] = {0, 0}, lk_vx[2] = {0, 0}, lk_vy[2] = {0, 0};
        int lk_why[2] = {-1, -1}; long lk_tick[2] = {-1, -1}; double lk_x[2] = {0, 0}, lk_y[2] = {0, 0};
        double rx_x = 0, rx_y = 0, won_x = 0;
        auto goalSide = [&](int team, double x) {   // opponents of `team` goal-side of x
            int n = 0;
            for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                const auto& d = s.world().player(j);
                if (d.team == team || s.world().isKeeper(j)) continue;
                if (team == 0 ? d.pos.x.toDouble() > x : d.pos.x.toDouble() < x) ++n;
            }
            return n;
        };
        for (long k = 0; k < ticks; ++k) {
            const auto before = s.world().ball().owner;
            s.tickOnce();
            const auto& b = s.world().ball();
            {   // G5.11 (§8.108): the drop — benchmarks: drop (DFL)
                const auto& bb = s.world().ball();
                const double bx = bb.pos.x.toDouble(), by = bb.pos.y.toDouble(), bz = bb.pos.z.toDouble();
                const double hx = s.world().pitchHalfX().toDouble();
                if (s.world().outStage() == 0 && g_dr_pz > 2.4 && bz <= 2.4 && std::fabs(by) < 20.16 && std::fabs(bx) > hx - 16.5) {
                    const int dteam = bx < 0 ? 0 : 1;   // team 0 defends -x
                    double nd[2] = {1e9, 1e9}, go = 1e9, gtg = 0, gsp = 0; int ndw = 0;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        if (s.world().isKeeper(j)) continue;
                        const auto& q = s.world().player(j);
                        const double dd = std::hypot(q.pos.x.toDouble() - bx, q.pos.y.toDouble() - by);
                        const int r = q.team == dteam ? 0 : 1;
                        if (r == 0 && dd < nd[0]) ndw = std::min(127, (int)s.lastOrders()[j].why);
                        if (r == 0) {
                            const auto w = s.lastOrders()[j].why;
                            if ((w == ai::Why::MeetPass || w == ai::Why::Chase || w == ai::Why::JumpPass || w == ai::Why::AttackDrop || w == ai::Why::RunBackDrop) && dd < go) {
                                go = dd;
                                const auto& tg = s.lastOrders()[j].target;
                                gtg = std::hypot(tg.x.toDouble() - bx, tg.y.toDouble() - by);
                                gsp = std::hypot(q.vel.x.toDouble(), q.vel.y.toDouble());
                            }
                        }
                        nd[r] = std::min(nd[r], dd);
                    }
                    ++g_dr_why[ndw];
                    ++g_dr_go[go < 1 ? 0 : go < 2 ? 1 : go < 4 ? 2 : go < 1e8 ? 3 : 4];
                    if (go < 1e8) { g_dr_go_d += go; ++g_dr_tg[gtg < 1 ? 0 : gtg < 2 ? 1 : gtg < 4 ? 2 : 3]; ++g_dr_sp[gsp < 2 ? 0 : gsp < 5 ? 1 : 2]; }
                    if (k <= g_cx_until) {
                        g_cx_until = -1; ++g_cx_n;
                        if (std::getenv("GAME_TRACE_CX"))
                            std::printf("CX from (%.1f,%.1f) aim (%.1f,%.1f) drop (%.1f,%.1f) aim-to-drop %.1f m; kick-to-aim %.1f kick-to-drop %.1f; nearest def %.1f att %.1f\n", g_cx_kx, g_cx_ky, g_cx_tx, g_cx_ty, bx, by,
                                        std::hypot(bx - g_cx_tx, by - g_cx_ty), std::hypot(g_cx_tx - g_cx_kx, g_cx_ty - g_cx_ky), std::hypot(bx - g_cx_kx, by - g_cx_ky), nd[0], nd[1]);
                        for (int r = 0; r < 2; ++r) { g_cx_d[r].push_back(nd[r]); ++g_cx_bin[r][nd[r] < 1 ? 0 : nd[r] < 2 ? 1 : nd[r] < 4 ? 2 : 3]; }
                    }
                    ++g_dr_n;
                    for (int r = 0; r < 2; ++r) {
                        g_dr_d[r].push_back(nd[r]);
                        ++g_dr_bin[r][nd[r] < 1 ? 0 : nd[r] < 2 ? 1 : nd[r] < 4 ? 2 : 3];
                    }
                }
                g_dr_pz = bz;
            }
            if (g_cf_on) {
                const auto& bb = s.world().ball();
                int cat = -1;
                if (s.world().outStage() != 0) cat = 5;
                else {
                    int who = bb.owner ? (int)*bb.owner : (bb.last_kicker != g_cf_kicker ? (int)bb.last_kicker : -1);
                    if (who >= 0 && who < s.world().playerCount()) {
                        const auto& q = s.world().player(static_cast<std::uint8_t>(who));
                        const bool head = g_cf_z > 1.5;
                        cat = s.world().isKeeper(static_cast<std::uint8_t>(who)) ? 4 : (q.team == g_cf_team ? (head ? 1 : 0) : (head ? 3 : 2));
                    }
                }
                if (cat < 0 && bb.pos.z.toDouble() < 1.5)
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        if (s.world().player(j).team == g_cf_team || s.world().isKeeper(j)) continue;
                        const double dd = std::hypot(s.world().player(j).pos.x.toDouble() - bb.pos.x.toDouble(), s.world().player(j).pos.y.toDouble() - bb.pos.y.toDouble());
                        if (dd < g_cf_min) { g_cf_min = dd; g_cf_minv = std::hypot(bb.vel.x.toDouble(), bb.vel.y.toDouble()); }
                    }
                if (cat >= 0) {
                    ++g_cf[g_cf_high][cat]; g_cf_on = 0;
                    const int bin = g_cf_min < 0.5 ? 0 : g_cf_min < 1.0 ? 1 : g_cf_min < 1.5 ? 2 : g_cf_min < 2.5 ? 3 : g_cf_min < 5 ? 4 : 5;
                    ++g_cf_md[g_cf_high][cat][bin];
                    if (std::getenv("GAME_TRACE_CF") && g_cf_min < 2.5) std::printf("CF %s cat %d nearest opp %.2f m at %.1f m/s\n", g_cf_high ? "high" : "low", cat, g_cf_min, g_cf_minv);
                    g_cf_min = 1e9;
                }
                g_cf_z = bb.pos.z.toDouble();
            }
            if (b.owner && (!before || *before != *b.owner)) {
                if (*b.owner < 64) got_tick[*b.owner] = k;
                const auto& r = s.world().player(*b.owner);
                rx_slot = *b.owner; rx_x = r.pos.x.toDouble(); rx_y = r.pos.y.toDouble();
                rx_behind = goalSide(r.team, rx_x);
                lk_tick[r.team] = -1;   // a mate got it: the kick wasn't lost
            }
            if (tf_verbose && tf_tick >= 0 && (k - tf_tick) % 6 == 0) {
                const auto& w = s.world();
                auto who = [&](int j) {
                    char t[160];
                    const auto& d = w.player(j);
                    const double bx = d.pos.x.toDouble() - b.pos.x.toDouble(), by = d.pos.y.toDouble() - b.pos.y.toDouble();
                    std::snprintf(t, sizeof t, "#%d %.1fm v%.1f %s", j, std::sqrt(bx * bx + by * by),
                                  std::sqrt(d.vel.x.toDouble() * d.vel.x.toDouble() + d.vel.y.toDouble() * d.vel.y.toDouble()),
                                  ai::kWhyNames[static_cast<int>(s.lastOrders()[j].why)]);
                    return std::string(t);
                };
                int nm = -1, no = -1; double dm = 1e9, dop = 1e9;
                for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
                    if (j == tf_to) continue;
                    const auto& d = w.player(j);
                    const double bx = d.pos.x.toDouble() - b.pos.x.toDouble(), by = d.pos.y.toDouble() - b.pos.y.toDouble();
                    const double dd = bx * bx + by * by;
                    if (d.team == tf_team) { if (dd < dm) { dm = dd; nm = j; } }
                    else if (dd < dop) { dop = dd; no = j; }
                }
                char t[600];
                std::snprintf(t, sizeof t, "   +%.1fs ball %.0f,%.0f %.1f m/s | for %s | mate %s | opp %s", (k - tf_tick) / 30.0,
                              b.pos.x.toDouble(), b.pos.y.toDouble(),
                              std::sqrt(b.vel.x.toDouble() * b.vel.x.toDouble() + b.vel.y.toDouble() * b.vel.y.toDouble()),
                              who(tf_to).c_str(), nm >= 0 ? who(nm).c_str() : "-", no >= 0 ? who(no).c_str() : "-");
                tf_ticks.push_back(t);
            }
            for (int tm = 0; tm < 2; ++tm)
                if (lk_tick[tm] >= 0 && k - lk_tick[tm] == 10 && lk_to[tm] >= 0 && lk_to[tm] < s.world().playerCount())
                {
                    lk_rwhy10[tm] = static_cast<int>(s.lastOrders()[lk_to[tm]].why);
                    const auto& fr = s.brain().flightRead(s.world());
                    const int f = fr.live ? fr.first[tm] : -8;
                    lk_first10[tm] = f == lk_to[tm] ? 0 : f < 0 ? (f == -8 ? 4 : 1) : f == s.world().ball().last_kicker ? 2 : 3;
                }
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
            {   // G5.17 (§8.114): concept acts by ownership — release, next owner — with StatsBomb's cuts
                struct Rel { int p = -1, team = -1, other = -1; double x = 0, y = 0; long tick = 0; bool set = false, cross = false, shot = false; };
                static int ca_owner = -1, ca_team = -1, ca_m = -1; static long ca_got = 0, ca_loss[2] = {-1000, -1000}; static double ca_sx = 0, ca_sy = 0, ca_px = 0, ca_py = 0;
                static Rel ca_rel; static int ca_from[32]; static long ca_from_t[32]; static long ca_in[32]; static int ca_face[32]; static int ca_why = 0, ca_oth = -1; static bool ca_set = false;
                if (m != ca_m || k == 0) { ca_m = m; ca_owner = -1; ca_team = -1; ca_rel = Rel{}; for (int j = 0; j < 32; ++j) { ca_from[j] = -1; ca_in[j] = -1; ca_face[j] = 0; } ca_loss[0] = ca_loss[1] = -1000; }
                const int own = b.owner ? static_cast<int>(*b.owner) : -1;
                const double hx = s.world().pitchHalfX().toDouble();
                auto endPass = [&](double ex, double ey) {   // the pending release lands (next owner, or out)
                    if (ca_rel.p < 0 || ca_rel.set || ca_rel.shot) { ca_rel = Rel{}; return; }
                    const double sg = ca_rel.team == 0 ? 1.0 : -1.0;
                    ++g_ca_pass;
                    if (std::fabs(ey - ca_rel.y) >= 34) ++g_ca_switch;
                    if (ca_rel.cross) ++g_ca_cross;
                    const double stl = hx - ca_rel.x * sg, etl = hx - ex * sg;
                    if (stl < 9 && etl > stl + 1 && etl < 16.5 && std::fabs(ey) < 20.16) ++g_ca_cutback;
                    ca_rel = Rel{};
                };
                if (own != ca_owner) {
                    if (ca_owner >= 0) {   // ca_owner let it go (or lost it)
                        const double sg = ca_team == 0 ? 1.0 : -1.0;
                        if ((ca_px - ca_sx) * sg >= 10) ++g_ca_carry10;
                        if (ca_face[ca_owner] > 0) { ++g_ca_drib; ca_face[ca_owner] = 0; }   // taking him on when it went
                        if (own < 0) {     // a release
                            ca_rel = Rel{}; ca_rel.p = ca_owner; ca_rel.team = ca_team; ca_rel.x = ca_px; ca_rel.y = ca_py; ca_rel.tick = k;
                            ca_rel.set = ca_set; ca_rel.cross = ca_why == static_cast<int>(ai::Why::Cross); ca_rel.shot = ca_why == static_cast<int>(ai::Why::Shoot);
                            ca_rel.other = ca_oth;
                            if (!ca_set && !ca_rel.shot && ca_from[ca_owner] >= 0 && ca_got - ca_from_t[ca_owner] <= 1 && k - ca_got <= 150) {
                                ++g_ca_rtp; if (ca_oth == ca_from[ca_owner]) ++g_ca_ret;
                            }
                        }
                    }
                    if (own >= 0) {        // a new owner
                        const auto& q = s.world().player(static_cast<std::uint8_t>(own));
                        if (ca_rel.p >= 0) {
                            const bool mate = ca_rel.team == q.team && ca_rel.p != own;
                            const int pp = ca_rel.p, pt = ca_rel.team; const bool st = ca_rel.set;
                            endPass(q.pos.x.toDouble(), q.pos.y.toDouble());
                            ca_from[own] = (mate && !st) ? pp : -1; ca_from_t[own] = k;
                            (void)pt;
                        } else ca_from[own] = -1;
                        if (ca_team >= 0 && q.team != ca_team) ca_loss[ca_team] = k;   // they lost it
                        ca_owner = own; ca_team = q.team; ca_got = k; ca_sx = q.pos.x.toDouble(); ca_sy = q.pos.y.toDouble();
                        for (int j = 0; j < 32; ++j) { ca_in[j] = -1; ca_face[j] = 0; }
                    } else ca_owner = -1;
                }
                if (ca_rel.p >= 0 && s.world().outStage() != 0) endPass(b.pos.x.toDouble(), b.pos.y.toDouble());
                if (own >= 0) {
                    const auto& c = s.world().player(static_cast<std::uint8_t>(own));
                    const double sg = c.team == 0 ? 1.0 : -1.0;
                    ca_px = c.pos.x.toDouble(); ca_py = c.pos.y.toDouble();
                    ca_why = static_cast<int>(s.lastOrders()[own].why); ca_oth = s.lastOrders()[own].other; ca_set = s.world().restartTeam() != 0xFF;
                    if (!ca_set) for (std::uint8_t j = 0; j < s.world().playerCount() && j < 32; ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == c.team) continue;
                        const double dx = c.pos.x.toDouble() - d.pos.x.toDouble(), dy = c.pos.y.toDouble() - d.pos.y.toDouble(), dd = std::hypot(dx, dy);
                        // pressure: within 4.5 m and closing at 1 m/s+, once per man per spell (StatsBomb: one per pressing act)
                        if (dd < 4.5 && dd > 0.01 && (d.vel.x.toDouble() * dx + d.vel.y.toDouble() * dy) / dd >= 1.0 && ca_in[j] < 0) {
                            ca_in[j] = k; ++g_ca_press; if (k - ca_loss[d.team] <= 150) ++g_ca_cpress;
                        }
                        // take-on: a man goal-side within 1.5 m in his 45-degree cone; done when he's 1 m past him with it
                        const double ahead = -dx * sg;   // d's x beyond the carrier, toward goal
                        if (!ca_face[own] && dd < 1.5 && ahead > 0 && std::fabs(dy) <= ahead) ca_face[own] = j + 1;
                    }
                    if (ca_face[own] > 0) {
                        const auto& d = s.world().player(static_cast<std::uint8_t>(ca_face[own] - 1));
                        if ((c.pos.x.toDouble() - d.pos.x.toDouble()) * sg >= 1) { ++g_ca_drib; ++g_ca_dribok; ca_face[own] = 0; }
                    }
                }
            }
            if (std::getenv("GAME_DEAD_TRACE") && k % 300 == 0)   // G5.15: where a stalled match is stuck
                std::fprintf(stderr, "dead-trace m%d k%ld out %d restart %d kind %d owner %d lt %d ball %.1f,%.1f\n", m, k, s.world().outStage(), s.world().restartTeam(),
                             static_cast<int>(s.world().restartKind()), b.owner ? *b.owner : -1, s.world().lastTouchTeam(), b.pos.x.toDouble(), b.pos.y.toDouble());
            if (std::getenv("GAME_DEAD_TRACE") && k % 3000 == 0 && s.world().restartTeam() != 0xFF)
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                    const auto& q = s.world().player(j); const auto& od = s.lastOrders()[j];
                    std::fprintf(stderr, "   p%d t%d #%d at %.1f,%.1f why %s tgt %.1f,%.1f move %.2f,%.2f\n", j, q.team, s.brain().numberOf(j), q.pos.x.toDouble(), q.pos.y.toDouble(),
                                 ai::kWhyNames[static_cast<int>(od.why) & 127], od.target.x.toDouble(), od.target.y.toDouble(), od.move.move.x.toDouble(), od.move.move.y.toDouble());
                }
            if (k % 6 == 0 && s.world().outStage() == 0 && s.world().restartTeam() == 0xFF && s.world().lastTouchTeam() < 2) {
                // G5.12: possession as DFL flags it — the last team on the ball, in play.
                const int a = s.world().lastTouchTeam();
                const double sg = a == 0 ? 1.0 : -1.0, hx = s.world().pitchHalfX().toDouble();
                const double tl = hx - b.pos.x.toDouble() * sg, ay = std::fabs(b.pos.y.toDouble());
                ++g_zl[tl < 18 ? 0 : tl < 35 ? 1 : tl < 70 ? 2 : 3][ay >= 14 ? 1 : 0];
                // G5.15 (§8.112): a 5 Hz ring of in-play frames (ball x, every man's x, the side on it) for three seconds back
                static long h3_k[16], h3_m[16]; static int h3_a[16]; static double h3_bx[16], h3_px[16][24];
                const int h3_i = static_cast<int>((k / 6) % 16), h3_j = static_cast<int>(((k / 6) + 16 - 15) % 16);
                const bool h3_ok = h3_k[h3_j] == k - 90 && h3_m[h3_j] == m;
                const double h3_bx_then = h3_bx[h3_j]; double h3_px_then[24]; for (int j = 0; j < 24; ++j) h3_px_then[j] = h3_px[h3_j][j];
                const bool h3_same = h3_ok && h3_a[h3_j] == a;
                h3_k[h3_i] = k; h3_m[h3_i] = m; h3_a[h3_i] = a; h3_bx[h3_i] = b.pos.x.toDouble();
                for (std::uint8_t j = 0; j < s.world().playerCount() && j < 24; ++j) h3_px[h3_i][j] = s.world().player(j).pos.x.toDouble();
                {   // G5.14: possession age (s since this side's last-touch spell began) — benchmarks: possession (DFL)
                    static int ag_team = -1; static long ag_t0 = 0; static long ag_last = -100;
                    if (a != ag_team || k - ag_last > 6 || k < ag_last) { ag_team = a; ag_t0 = k; }
                    ag_last = k;
                    const int ab = std::min(6, static_cast<int>((k - ag_t0) / 30));
                    double ms = 0, vf = 0, f5 = 0, f5f = 0; int nm2 = 0;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        if (s.world().isKeeper(j) || s.world().player(j).team != a) continue;
                        const auto& q = s.world().player(j);
                        ms += hx - q.pos.x.toDouble() * sg; ++nm2;
                        const double vx = q.vel.x.toDouble() * sg, sp = std::hypot(q.vel.x.toDouble(), q.vel.y.toDouble());
                        vf += vx; if (sp >= 5) f5 += 1; if (vx >= 5) f5f += 1;
                    }
                    if (nm2 >= 9) { ++g_ag_n[ab]; g_ag_b[ab] += 2 * hx - tl; g_ag_m[ab] += ms / nm2; g_ag_v[ab] += vf / nm2; g_ag_5[ab] += f5 / nm2; g_ag_5f[ab] += f5f / nm2; }
                    if (nm2 >= 9) {   // G5.15 (§8.112): the front men (AM/WIDE/ST) by age; holders' spot ahead of them and their forward speed
                        const double mid = ms / nm2;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            if (s.world().isKeeper(j) || s.world().player(j).team != a) continue;
                            const int num = s.brain().numberOf(j);
                            if (!(num == 7 || num == 9 || num == 10 || num == 11)) continue;
                            const auto& q = s.world().player(j);
                            const double vx = q.vel.x.toDouble() * sg, sp = std::hypot(q.vel.x.toDouble(), q.vel.y.toDouble());
                            ++g_fa_n[ab]; g_fa_a[ab] += mid - (hx - q.pos.x.toDouble() * sg); g_fa_v[ab] += vx; g_fa_5[ab] += sp >= 5; g_fa_5f[ab] += vx >= 5;
                            const auto& od = s.lastOrders()[j];
                            if (od.why == ai::Why::Hold && (od.target.x.raw || od.target.y.raw)) { ++g_fa_hn[ab]; g_fa_h[ab] += (od.target.x.toDouble() - q.pos.x.toDouble()) * sg; g_fa_hv[ab] += vx; }
                        }
                    }
                }
                {   // G5.14 (§8.111): the side in possession, where its men stand by the ball's band — benchmarks: possession (DFL)
                    const int k = std::min(9, std::max(0, static_cast<int>(tl / 10)));
                    {   // G5.15 (§8.112): the side without it, same band, metres from its own line — benchmarks: possession (DFL)
                        double dm = 0; int dn = 0;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            if (s.world().isKeeper(j) || s.world().player(j).team == a) continue;
                            const double ptl = hx - s.world().player(j).pos.x.toDouble() * sg;
                            const int num = s.brain().numberOf(j);
                            const int r = (num == 4 || num == 5) ? 0 : (num == 2 || num == 3) ? 1 : (num == 6 || num == 8) ? 2 : num == 10 ? 3 : (num == 7 || num == 11) ? 4 : num == 9 ? 5 : 6;
                            ++g_dsh_n[k][r]; g_dsh_s[k][r] += ptl; dm += ptl; ++dn;
                            g_dsh_an[k][r] += hx - s.brain().shapeAnchor(j, s.world()).x.toDouble() * sg;
                            g_dsh_da[k][r] += hx - s.brain().debugAnchor(j).x.toDouble() * sg;
                            const auto& od = s.lastOrders()[j];
                            g_dsh_ot[k][r] += (od.target.x.raw || od.target.y.raw) ? hx - od.target.x.toDouble() * sg : ptl;
                            if (k >= 4 && k < 7) { ++g_dsh_wn[r]; ++g_dsh_why[r][static_cast<int>(od.why) & 127]; }
                            if (od.why == ai::Why::Hold && (od.target.x.raw || od.target.y.raw)) {
                                ++g_dsh_hn[k][r]; g_dsh_ht[k][r] += hx - od.target.x.toDouble() * sg; g_dsh_hp[k][r] += ptl;
                                g_dsh_hv[k][r] += -s.world().player(j).vel.x.toDouble() * sg;   // toward its own line
                            }
                        }
                        if (dn >= 9) { ++g_dsh_f[k]; g_dsh_m[k] += dm / dn; }
                    }
                    double tls[11]; int nt = 0;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        if (s.world().isKeeper(j) || s.world().player(j).team != a) continue;
                        const double ptl = hx - s.world().player(j).pos.x.toDouble() * sg;
                        const int num = s.brain().numberOf(j);
                        const int r = (num == 4 || num == 5) ? 0 : (num == 2 || num == 3) ? 1 : (num == 6 || num == 8) ? 2 : num == 10 ? 3 : (num == 7 || num == 11) ? 4 : num == 9 ? 5 : 6;
                        ++g_ps_n[k][r]; g_ps_s[k][r] += ptl;
                        {   // holders in possession: how far off the spot, how fast toward it
                            const auto& od = s.lastOrders()[j];
                            const auto& q = s.world().player(j);
                            if (od.why == ai::Why::Hold && (od.target.x.raw || od.target.y.raw)) {
                                const double dx = od.target.x.toDouble() - q.pos.x.toDouble(), dy = od.target.y.toDouble() - q.pos.y.toDouble();
                                const double dd = std::hypot(dx, dy);
                                const int bi = dd < 2 ? 0 : dd < 5 ? 1 : dd < 10 ? 2 : 3;
                                const double vx = q.vel.x.toDouble(), vy = q.vel.y.toDouble();
                                ++g_hl_n[bi]; g_hl_d[bi] += dd; g_hl_v[bi] += std::hypot(vx, vy);
                                if (dd > 0.01) g_hl_vt[bi] += (vx * dx + vy * dy) / dd;
                                g_hl_want[bi] += std::hypot(od.move.move.x.toDouble(), od.move.move.y.toDouble());
                                ++g_hf_n[r]; g_hf_d[r] += dd; g_hf_fx[r] += dx * sg; g_hf_ay[r] += std::fabs(dy);
                            }
                        }
                        if (nt < 11) tls[nt++] = ptl;
                    }
                    if (nt >= 9) {
                        double mx = -1e9, mn = 1e9, sm = 0;
                        for (int i = 0; i < nt; ++i) { mx = std::max(mx, tls[i]); mn = std::min(mn, tls[i]); sm += tls[i]; }
                        const double mid = sm / nt;
                        ++g_ps_f[k]; g_ps_back[k] += mx; g_ps_mid[k] += mid; g_ps_front[k] += mn;
                        const double B = 2 * hx - tl, M = 2 * hx - mid;
                        g_ps_N += 1; g_ps_B += B; g_ps_M += M; g_ps_BB += B * B; g_ps_BM += B * M;
                        if (tl >= 25 && tl < 75)
                            for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                                if (s.world().isKeeper(j) || s.world().player(j).team != a) continue;
                                const int num = s.brain().numberOf(j);
                                const int r = (num == 4 || num == 5) ? 0 : (num == 2 || num == 3) ? 1 : (num == 6 || num == 8) ? 2 : num == 10 ? 3 : (num == 7 || num == 11) ? 4 : num == 9 ? 5 : 6;
                                ++g_ps_gn[r]; g_ps_g[r] += mid - (hx - s.world().player(j).pos.x.toDouble() * sg);
                            }
                    }
                }
                if (tl >= 18 && tl < 35 && ay >= 14) {   // G5.13 (§8.110): who is ahead of it on its side — benchmarks: chan (DFL)
                    ++g_ch_n;
                    if (h3_ok) {   // G5.15: three seconds before — how far the ball came, how far each man came, where he stood then
                        const double bad = (b.pos.x.toDouble() - h3_bx_then) * sg;
                        ++g_h3_bn; g_h3_ball += bad; if (bad >= 15) g_h3_b15 += 1;
                        ++g_h3_age[!h3_same ? 0 : bad < 5 ? 1 : bad < 15 ? 2 : 3];
                        for (std::uint8_t j = 0; j < s.world().playerCount() && j < 24; ++j) {
                            const auto& q = s.world().player(j);
                            if (s.world().isKeeper(j) || q.team != a) continue;
                            const int num = s.brain().numberOf(j);
                            const int r = (num == 4 || num == 5) ? 0 : (num == 2 || num == 3) ? 1 : (num == 6 || num == 8) ? 2 : num == 10 ? 3 : (num == 7 || num == 11) ? 4 : num == 9 ? 5 : 6;
                            const int f = ((q.pos.y.toDouble() > 0) == (b.pos.y.toDouble() > 0)) ? 0 : 1;
                            ++g_h3_n[r][f]; g_h3_adv[r][f] += (q.pos.x.toDouble() - h3_px_then[j]) * sg;
                            g_h3_was[r][f] += (h3_px_then[j] - h3_bx_then) * sg;   // ahead of the ball, then
                        }
                    }
                    const double by = b.pos.y.toDouble();
                    double nd = 1e9;
                    {   // the offside line: their second-last man (keeper counts), metres ahead of the ball
                        double d1 = -1e9, d2 = -1e9;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            if (s.world().player(j).team == a) continue;
                            const double x = s.world().player(j).pos.x.toDouble() * sg;
                            if (x > d1) { d2 = d1; d1 = x; } else if (x > d2) d2 = x;
                        }
                        g_line_sum += std::max(d2, b.pos.x.toDouble() * sg) - b.pos.x.toDouble() * sg;
                    }
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        if (s.world().isKeeper(j)) continue;
                        const auto& q = s.world().player(j);
                        const double ptl = hx - q.pos.x.toDouble() * sg, qy = q.pos.y.toDouble();
                        const bool same = (qy > 0) == (by > 0), att = q.team == a;
                        {   // G5.14 (§8.111): where they stand, by role and side — benchmarks: chan (DFL)
                            const int num = s.brain().numberOf(j);
                            const int r = (num == 4 || num == 5) ? 0 : (num == 2 || num == 3) ? 1 : (num == 6 || num == 8) ? 2 : num == 10 ? 3 : (num == 7 || num == 11) ? 4 : num == 9 ? 5 : 6;
                            const int sd = att ? 0 : 1, f = same ? 0 : 1;
                            ++g_wt_n[sd][r][f]; g_wt_a[sd][r][f] += tl - ptl; g_wt_y[sd][r][f] += by > 0 ? qy : -qy;
                            ++g_wt_why[sd][r][f][static_cast<int>(s.lastOrders()[j].why) & 127];
                            if (att) {   // the order's target, every job / hold shape only (and where the holder stands)
                                const auto& od = s.lastOrders()[j];
                                if (od.target.x.raw != 0 || od.target.y.raw != 0) {
                                    const double ta = tl - (hx - od.target.x.toDouble() * sg);
                                    ++g_wt_tn[r][f]; g_wt_t[r][f] += ta;
                                    if (od.why == ai::Why::Hold) { ++g_wt_hn[r][f]; g_wt_h[r][f] += ta; g_wt_hp[r][f] += tl - ptl; }
                                }
                            }
                            if (att && b.owner && s.world().player(*b.owner).team == a) { ++g_wt_ancn[r][f]; const auto an = s.brain().shapeAnchor(j, s.world()); g_wt_anc[r][f] += tl - (hx - an.x.toDouble() * sg); g_wt_ancy[r][f] += by > 0 ? an.y.toDouble() : -an.y.toDouble(); }
                            if (!att) nd = std::min(nd, std::hypot(q.pos.x.toDouble() - b.pos.x.toDouble(), qy - by));
                        }
                        if (ptl < 18 && std::fabs(qy) >= 14 && same) ++g_ch_chan[att ? 0 : 1];
                        if (ptl < 16.5 && std::fabs(qy) < 20.16) ++g_ch_box[att ? 0 : 1];
                        if (att && ptl < tl && same && std::fabs(qy) >= 10 && !(b.owner && *b.owner == j)) {
                            const int num = s.brain().numberOf(j);
                            const int r = (num == 4 || num == 5) ? 0 : (num == 2 || num == 3) ? 1 : (num == 6 || num == 8) ? 2 : num == 10 ? 3 : (num == 7 || num == 11) ? 4 : num == 9 ? 5 : 6;
                            ++g_ch_ahead[r];
                            if (q.vel.x.toDouble() * sg >= 4) ++g_ch_run[r];
                            ++g_ch_why[static_cast<int>(s.lastOrders()[j].why) & 127];
                        }
                    }
                    { static const double lim[5] = {1, 2, 3, 5, 8}; for (int i = 0; i < 5; ++i) if (nd < lim[i]) ++g_nd_lim[i]; g_nd_sum += std::min(nd, 30.0); }
                }
            }
            {   // G5.13 (§8.110): the man on the ball wide 18-35 m off their line — benchmarks: wide (StatsBomb)
                static int ws_who = -1; static long ws_t0 = 0; static double ws_px = 0, ws_py = 0;
                const auto& W = s.world();
                const double hx = W.pitchHalfX().toDouble();
                auto zof = [&](int team, double x, double y) {   // 0-18 / 18-35 / 35+ off their line, x2 + wide
                    const double tl = hx - x * (team == 0 ? 1.0 : -1.0);
                    return (tl < 18 ? 0 : tl < 35 ? 1 : 2) * 2 + (std::fabs(y) >= 14 ? 1 : 0);
                };
                const bool live = W.restartTeam() == 0xFF && W.outStage() == 0;
                if (ws_who >= 0) {
                    const auto& q = W.player(static_cast<std::uint8_t>(ws_who));
                    int end = -1;   // 0 shot, 1 cross, 2 clearance, 3 pass, 4 lost, 5 stopped
                    if (before && *before == ws_who && !b.owner && b.last_kicker == ws_who) {
                        const ai::Orders& o = s.lastOrders()[ws_who];
                        end = o.why == ai::Why::Shoot ? 0 : o.why == ai::Why::Cross ? 1 : o.why == ai::Why::Clear ? 2 : 3;
                        ++g_ws_from[zof(q.team, q.pos.x.toDouble(), q.pos.y.toDouble())];
                        if (end == 3) {
                            ++g_ws_to[zof(q.team, o.target.x.toDouble(), o.target.y.toDouble())];
                            ++g_ws_pwhy[static_cast<int>(o.why) & 127];
                        }
                    } else if (!live) {
                        end = 5;
                    } else if (!b.owner || *b.owner != ws_who) {
                        end = 4;
                        ++g_ws_from[zof(q.team, q.pos.x.toDouble(), q.pos.y.toDouble())];
                    } else {
                        g_ws_carry_m += std::hypot(q.pos.x.toDouble() - ws_px, q.pos.y.toDouble() - ws_py);
                        ws_px = q.pos.x.toDouble(); ws_py = q.pos.y.toDouble();
                        ++g_ws_why[static_cast<int>(s.lastOrders()[ws_who].why) & 127];
                    }
                    if (end >= 0) {
                        ++g_ws_end[end];
                        g_ws_ticks += k - ws_t0;
                        ws_who = -1;
                    }
                }
                if (ws_who < 0 && b.owner && live && (!before || *before != *b.owner) && !W.isKeeper(*b.owner)) {
                    const auto& q = W.player(*b.owner);
                    if (zof(q.team, q.pos.x.toDouble(), q.pos.y.toDouble()) == 3) {
                        ws_who = *b.owner; ws_t0 = k; ws_px = q.pos.x.toDouble(); ws_py = q.pos.y.toDouble();
                        ++g_ws_n;
                    }
                }
            }
            if (b.owner && s.world().restartTeam() == 0xFF) {
                const int ot = s.world().player(*b.owner).team;
                if (ot != spell_team) {
                    if (spell_team >= 0) {
                        int behind = 0;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            const auto& d = s.world().player(j);
                            if (d.team != spell_team || s.world().isKeeper(j)) continue;
                            if (spell_team == 0 ? d.pos.x < b.pos.x : d.pos.x > b.pos.x) ++behind;
                        }
                        ++rest_hist[spell_team][behind]; ++rest_n[spell_team];
                        const int lt = spell_team;
                        const double own_d = lt == 0 ? 52.5 + b.pos.x.toDouble() : 52.5 - b.pos.x.toDouble();
                        {
                            int c = 4;
                            if (lk_tick[lt] >= spell_start) {
                                const auto w = static_cast<ai::Why>(lk_why[lt]);
                                c = w == ai::Why::Shoot ? 2 : (w == ai::Why::Clear || w == ai::Why::KeeperPunt) ? 1 : 0;
                            } else if (s.world().badTouchSlot() < s.world().playerCount() &&
                                       s.world().player(s.world().badTouchSlot()).team == lt &&
                                       static_cast<long>(s.world().badTouchTick()) >= spell_start) {
                                c = 3;
                            }
                            ++end_cause[lt][c]; ++ends[lt];
                        }
                        o3_team = -1;
                        if (own_d < 35) {
                            o3_team = lt ^ 1; o3_tick = k; o3_10 = o3_any = false;
                            ++own3_n[lt];
                            const bool kicked = lk_tick[lt] >= spell_start;
                            ++own3_lost[lt][kicked ? lk_why[lt] : ai::kWhyCount];
                            if (!kicked && before && s.world().player(*before).team == lt && *before < 64) {
                                ++dp_n;
                                const double h = (k - got_tick[*before]) / 30.0;
                                ++dp_held[h < 0.5 ? 0 : h < 1 ? 1 : h < 3 ? 2 : 3];
                                dp_in_touch += static_cast<std::uint64_t>(k) < prev_ctrl_until;
                                ++dp_carrier[prev_why[*before]];
                                ++dp_taker[static_cast<int>(s.lastOrders()[*b.owner].why)];
                            }
                            const double age = (k - spell_start) / 30.0;
                            ++own3_age[lt][age < 1 ? 0 : age < 3 ? 1 : age < 8 ? 2 : 3];
                            if (kicked) {
                                const double dx = b.pos.x.toDouble() - lk_x[lt], dy = b.pos.y.toDouble() - lk_y[lt];
                                own3_kick_m[lt] += std::sqrt(dx * dx + dy * dy); ++own3_kicks[lt];
                                if (trace_lost && m == 0 && traced < trace_lost && !lk_snap[lt].empty()) {
                                    ++traced;
                                    const int ic = *b.owner;
                                    const double ax = lk_tx[lt] - lk_x[lt], ay = lk_ty[lt] - lk_y[lt];
                                    const double aim = std::atan2(ay, ax) * 57.3, went = std::atan2(lk_vy[lt], lk_vx[lt]) * 57.3;
                                    auto P = [&](int j) { return std::to_string(int(lk_snap[lt][j].x.toDouble())) + "," + std::to_string(int(lk_snap[lt][j].y.toDouble())); };
                                    std::printf("LOST t=%.1fs team%d %s from %d,%d aim %d,%d (%.0f m) | aimed %.0f° went %.0f° at %.1f m/s | taken after %.1f s at %d,%d | for #%d was at %s now %s (+0.3 s: %s) | taker #%d was at %s (%s)\n",
                                        k / 30.0, lt, ai::kWhyNames[lk_why[lt]], int(lk_x[lt]), int(lk_y[lt]), int(lk_tx[lt]), int(lk_ty[lt]), std::sqrt(ax * ax + ay * ay),
                                        aim, went, std::sqrt(lk_vx[lt] * lk_vx[lt] + lk_vy[lt] * lk_vy[lt]), (k - lk_tick[lt]) / 30.0,
                                        int(b.pos.x.toDouble()), int(b.pos.y.toDouble()),
                                        lk_to[lt], lk_to[lt] >= 0 ? P(lk_to[lt]).c_str() : "-",
                                        lk_to[lt] >= 0 ? (std::to_string(int(s.world().player(lk_to[lt]).pos.x.toDouble())) + "," + std::to_string(int(s.world().player(lk_to[lt]).pos.y.toDouble()))).c_str() : "-",
                                        lk_rwhy10[lt] >= 0 ? ai::kWhyNames[lk_rwhy10[lt]] : "-",
                                        ic, P(ic).c_str(), ai::kWhyNames[static_cast<int>(s.lastOrders()[ic].why)]);
                                }
                                if (lk_to[lt] >= 0 && lk_to[lt] < s.world().playerCount()) {
                                    const auto& rv = s.world().player(lk_to[lt]);
                                    if (rv.team == lt) {
                                        if (lk_rwhy10[lt] >= 0) { ++own3_rwhy[lt][lk_rwhy10[lt]]; ++own3_rn[lt]; ++own3_first[lt][lk_first10[lt]]; }
                                        const double rx = rv.pos.x.toDouble() - b.pos.x.toDouble(), ry = rv.pos.y.toDouble() - b.pos.y.toDouble();
                                        own3_rgap[lt] += std::sqrt(rx * rx + ry * ry);
                                        const double ix = rv.pos.x.toDouble() - lk_x[lt], iy = rv.pos.y.toDouble() - lk_y[lt];
                                        own3_igap[lt] += std::sqrt(ix * ix + iy * iy);
                                    }
                                }
                            }
                        }
                    }
                    if (spell_team >= 0) { ++spells; spell_ticks += k - spell_start; }
                    spell_team = ot;
                    spell_start = k;
                    won_x = ot == 0 ? 52.5 - b.pos.x.toDouble() : 52.5 + b.pos.x.toDouble();
                }
                // G5.6 (§8.104): the block without the ball over 1 s, as
                // benchmarks_tracking_shift.py reads DFL: its middle's speed
                // and slope on the ball, its back line's slope.
                if (g_cr_on) {
                    const auto& bb = s.world().ball();
                    const double z = bb.pos.z.toDouble();
                    auto nearest = [&](int team) {
                        double best = 1e9;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            const auto& q = s.world().player(j);
                            if (q.team != team) continue;
                            best = std::min(best, std::hypot(q.pos.x.toDouble() - bb.pos.x.toDouble(), q.pos.y.toDouble() - bb.pos.y.toDouble()));
                        }
                        return best;
                    };
                    if ((g_cr_pz > 2.4 && z <= 2.4) || (g_cr_pz > 0.3 && z <= 0.3))
                        std::printf("   +%.1fs ball (%.1f,%.1f) z %.1f: nearest mate %.1f m, opp %.1f m\n", (k - g_cr_tick) / 30.0, bb.pos.x.toDouble(), bb.pos.y.toDouble(), z,
                                    nearest(g_cr_team), nearest(1 - g_cr_team));
                    g_cr_pz = z;
                    if (bb.owner || s.world().outStage() != 0 || k - g_cr_tick > 150) {
                        std::printf("   +%.1fs end: %s\n", (k - g_cr_tick) / 30.0,
                                    bb.owner ? (s.world().player(*bb.owner).team == g_cr_team ? "ours" : "theirs") : s.world().outStage() ? "out" : "loose 5s");
                        g_cr_on = 0;
                    } else if (bb.last_kicker != 0xFF && k - g_cr_tick > 2 && bb.kick_alive == core::kKickAliveTicks) {
                        std::printf("   +%.1fs touched by %d (t%d)%s\n", (k - g_cr_tick) / 30.0, bb.last_kicker, s.world().player(bb.last_kicker).team, z > 1.5 ? " in the air" : "");
                        g_cr_on = 0;
                    }
                }
                if (g_cr_on) {
                    const auto& bb = s.world().ball();
                    const double z = bb.pos.z.toDouble();
                    auto nearest = [&](int team) {
                        double best = 1e9;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            const auto& q = s.world().player(j);
                            if (q.team != team) continue;
                            best = std::min(best, std::hypot(q.pos.x.toDouble() - bb.pos.x.toDouble(), q.pos.y.toDouble() - bb.pos.y.toDouble()));
                        }
                        return best;
                    };
                    if ((g_cr_pz > 2.4 && z <= 2.4) || (g_cr_pz > 0.3 && z <= 0.3))
                        std::printf("   +%.1fs ball (%.1f,%.1f) z %.1f: nearest mate %.1f m, opp %.1f m\n", (k - g_cr_tick) / 30.0, bb.pos.x.toDouble(), bb.pos.y.toDouble(), z,
                                    nearest(g_cr_team), nearest(1 - g_cr_team));
                    g_cr_pz = z;
                    if (bb.owner || s.world().outStage() != 0 || k - g_cr_tick > 150) {
                        std::printf("   +%.1fs end: %s\n", (k - g_cr_tick) / 30.0,
                                    bb.owner ? (s.world().player(*bb.owner).team == g_cr_team ? "ours" : "theirs") : s.world().outStage() ? "out" : "loose 5s");
                        g_cr_on = 0;
                    } else if (bb.last_kicker != 0xFF && k - g_cr_tick > 2 && bb.kick_alive == core::kKickAliveTicks) {
                        std::printf("   +%.1fs touched by %d (t%d)%s\n", (k - g_cr_tick) / 30.0, bb.last_kicker, s.world().player(bb.last_kicker).team, z > 1.5 ? " in the air" : "");
                        g_cr_on = 0;
                    }
                }
                {   // G5.9: how the ball reaches the crossing zone (benchmarks: arrive)
                    static int po = -1; static bool pin = false; static double pfy = 0;
                    const auto& bb = s.world().ball();
                    if (bb.owner) {
                        const int ow = *bb.owner;
                        const auto& q = s.world().player(static_cast<std::uint8_t>(ow));
                        const double sg = q.team == 0 ? 1.0 : -1.0, hx = s.world().pitchHalfX().toDouble();
                        const bool in = hx - q.pos.x.toDouble() * sg < 18 && std::fabs(q.pos.y.toDouble()) >= 14 && !s.world().isKeeper(static_cast<std::uint8_t>(ow));
                        if (ow == po && in && !pin) ++g_xin_carry;
                        if (ow != po && in && po >= 0 && s.world().player(static_cast<std::uint8_t>(po)).team == q.team && !pin) {
                            ++g_xin_pass;
                            if (pfy >= 14) ++g_xin_pass_wide;
                        }
                        po = ow; pin = in; pfy = std::fabs(q.pos.y.toDouble());
                    }
                }
                if (k % 6 == 0 && spell_team >= 0) {
                    const int a = spell_team;
                    const double sg = a == 0 ? 1.0 : -1.0, hx = s.world().pitchHalfX().toDouble();
                    const double tl = hx - b.pos.x.toDouble() * sg, ay = std::fabs(b.pos.y.toDouble());
                    ++g_zn[tl < 18 ? 0 : tl < 35 ? 1 : tl < 70 ? 2 : 3][ay >= 14 ? 1 : 0];
                    if (ay >= 14 && tl < 30) {
                        const int kk = tl < 18 ? 0 : 1;
                        int box = 0, tgt = 0, dbox = 0;
                        double l1 = 1e9, l2 = 1e9;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            if (s.world().isKeeper(j)) continue;
                            const auto& q = s.world().player(j);
                            const double ptl = hx - q.pos.x.toDouble() * sg, py = std::fabs(q.pos.y.toDouble());
                            const bool inbox = ptl < 16.5 && py < 20.16;
                            if (q.team == a) { box += inbox; tgt += ptl >= 3 && ptl <= 13 && py < 10; }
                            else {
                                dbox += inbox;
                                if (ptl < l1) { l2 = l1; l1 = ptl; } else if (ptl < l2) l2 = ptl;
                            }
                        }
                        if (kk == 1)
                            for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                                if (s.world().isKeeper(j)) continue;
                                const auto& q = s.world().player(j);
                                if (q.team == a) continue;
                                const double ptl = hx - q.pos.x.toDouble() * sg;
                                int deeper = 0;
                                for (std::uint8_t m = 0; m < s.world().playerCount(); ++m)
                                    if (s.world().player(m).team == q.team && !s.world().isKeeper(m) &&
                                        hx - s.world().player(m).pos.x.toDouble() * sg > ptl) ++deeper;
                                if (deeper < 6) continue;
                                const ai::Orders& o = s.lastOrders()[j];
                                const int w = std::min(127, (int)o.why);
                                ++g_dw_n[w]; g_dw_tl[w] += ptl; g_dw_ttl[w] += hx - o.target.x.toDouble() * sg;
                            }
                        if (kk == 0)
                            for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                                if (s.world().isKeeper(j)) continue;
                                const auto& q = s.world().player(j);
                                const ai::Orders& o = s.lastOrders()[j];
                                const double gx = o.target.x.toDouble() - q.pos.x.toDouble(), gy = o.target.y.toDouble() - q.pos.y.toDouble();
                                const double gap = std::hypot(gx, gy), v = std::hypot(q.vel.x.toDouble(), q.vel.y.toDouble());
                                const double ptl = hx - q.pos.x.toDouble() * sg, ttl = hx - o.target.x.toDouble() * sg;
                                if (q.team == a && o.why == ai::Why::AttackBox) { ++g_ab_n; g_ab_gap += gap; g_ab_v += v; g_ab_tl += ptl; g_ab_ttl += ttl; }
                                if (q.team != a) {
                                    // the defenders' four deepest by position stand in for the back line
                                    int deeper = 0;
                                    for (std::uint8_t m = 0; m < s.world().playerCount(); ++m)
                                        if (s.world().player(m).team == q.team && !s.world().isKeeper(m) &&
                                            hx - s.world().player(m).pos.x.toDouble() * sg > ptl) ++deeper;
                                    if (deeper >= 6) { ++g_dl_n; g_dl_gap += gap; g_dl_v += v; g_dl_tl += ptl; g_dl_ttl += ttl; }
                                }
                            }
                        if (kk == 0) {
                            std::vector<std::pair<double, int>> adv;
                            for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                                const auto& q = s.world().player(j);
                                if (q.team != a || s.world().isKeeper(j) || (b.owner && *b.owner == j)) continue;
                                adv.push_back({-q.pos.x.toDouble() * sg, j});
                            }
                            std::sort(adv.begin(), adv.end());
                            for (int r = 0; r < 3 && r < (int)adv.size(); ++r) ++g_bpw[std::min(127, (int)s.lastOrders()[adv[r].second].why)];
                            static int dbg = 0;
                            if (std::getenv("GAME_DBG_BOX") && dbg < 6 && adv.size() && s.lastOrders()[adv[0].second].why == ai::Why::HurryKeeper) {
                                ++dbg;
                                std::printf("DBG spell %d ball (%.1f,%.1f) owner %d ownerteam %d lasttouch %d; adv0 slot %d team %d at (%.1f,%.1f)\n", a, b.pos.x.toDouble(), b.pos.y.toDouble(),
                                            b.owner ? (int)*b.owner : -1, b.owner ? (int)s.world().player(*b.owner).team : -1, (int)s.world().lastTouchTeam(), adv[0].second,
                                            (int)s.world().player(adv[0].second).team, s.world().player(adv[0].second).pos.x.toDouble(), s.world().player(adv[0].second).pos.y.toDouble());
                            }
                        }
                        if (kk == 0)
                            for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                                if (s.world().isKeeper(j)) continue;
                                const auto& q = s.world().player(j);
                                const int num = s.brain().numberOf(j);
                                const double qy = q.pos.y.toDouble();
                                const bool ballside = (qy > 0) == (b.pos.y.toDouble() > 0);
                                const int role = (num == 4 || num == 5) ? 0 : (num == 2 || num == 3) ? (ballside ? 1 : 2) : (num == 6 || num == 8) ? 3
                                               : num == 10 ? 4 : (num == 7 || num == 11) ? (ballside ? 5 : 6) : num == 9 ? 7 : -1;
                                if (role < 0) continue;
                                const int sd = q.team == a ? 0 : 1;
                                const double ptl = hx - q.pos.x.toDouble() * sg;
                                const bool inbox = ptl < 16.5 && std::fabs(qy) < 20.16;
                                ++g_br_n[sd][role]; g_br_box[sd][role] += inbox;
                                if (!inbox) {
                                    ++g_br_why[sd][role][std::min(127, (int)s.lastOrders()[j].why)];
                                    const auto& tg = s.lastOrders()[j].target;
                                    const double ttl = hx - tg.x.toDouble() * sg;
                                    if (ttl < 16.5 && std::fabs(tg.y.toDouble()) < 20.16) {
                                        ++g_br_tin[sd][role];
                                        g_br_late[sd][role] += std::hypot(tg.x.toDouble() - q.pos.x.toDouble(), tg.y.toDouble() - qy);
                                    }
                                }
                            }
                        g_bp_l1[kk] += l1; g_bp_l2[kk] += l2;
                        ++g_bp_n[kk]; g_bp_box[kk] += box; g_bp_tgt[kk] += tgt; g_bp_dbox[kk] += dbox; g_bp_tgt0[kk] += tgt == 0;
                    }
                }
                if (k % 6 == 0 && spell_team >= 0) {
                    const int d = 1 - spell_team;
                    const double sg = d == 0 ? 1.0 : -1.0, hx = s.world().pitchHalfX().toDouble();
                    double mid = 0, my = 0, line = 1e9, top = -1e9; int n = 0, na = 0;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& q = s.world().player(j);
                        if (s.world().isKeeper(j)) continue;
                        if (q.team != d) { ++na; continue; }
                        const double x = q.pos.x.toDouble() * sg;
                        mid += x; my += q.pos.y.toDouble(); ++n;
                        line = std::min(line, x); top = std::max(top, x);
                    }
                    if (n >= 9 && na >= 9) {
                        const double bd = b.pos.x.toDouble() * sg + hx, by = b.pos.y.toDouble();
                        const int kb = std::max(0, std::min(6, int(bd / 15)));
                        ++g_lv_n[kb]; g_lv_line[kb] += line + hx; g_lv_mid[kb] += mid / n + hx; g_lv_top[kb] += top + hx;
                        const double ay = std::fabs(by), sy = by >= 0 ? 1.0 : -1.0;
                        const int ky = std::min(3, int(ay / 10));
                        ++g_ly_n[ky]; g_ly_mid[ky] += sy * my / n; g_ly_ball[ky] += ay;
                        if (ay >= 24 && n == 10) {
                            double ys[10], as[11]; int r = 0, ra = 0; double far = 1e9;
                            for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                                const auto& q = s.world().player(j);
                                if (s.world().isKeeper(j)) continue;
                                if (q.team == d) ys[r++] = sy * q.pos.y.toDouble();
                                else { far = std::min(far, sy * q.pos.y.toDouble()); if (ra < 11) as[ra++] = sy * q.pos.y.toDouble(); }
                            }
                            if (ra == 10) {
                                std::sort(as, as + 10);
                                for (int i = 0; i < 10; ++i) g_ra[i] += as[i];
                                ++g_ra_n;
                            }
                            std::sort(ys, ys + 10);
                            for (int i = 0; i < 10; ++i) g_rk[i] += ys[i];
                            ++g_rk_n; g_rk_far += far;
                        }
                        if (ay >= 24)
                            for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                                const auto& q = s.world().player(j);
                                if (s.world().isKeeper(j)) continue;
                                const ai::Orders& o = s.lastOrders()[j];
                                if (q.team != d) {
                                    if (sy * q.pos.y.toDouble() < -10) {
                                        const int w = std::min(127, static_cast<int>(o.why));
                                        ++g_aw_n[w]; g_aw_y[w] += sy * q.pos.y.toDouble(); g_aw_t[w] += sy * o.target.y.toDouble();
                                    }
                                    continue;
                                }
                                const int w = std::min(127, static_cast<int>(o.why));
                                ++g_lw_n[w]; g_lw_y[w] += sy * q.pos.y.toDouble(); g_lw_t[w] += sy * o.target.y.toDouble();
                            }
                    }
                }
                if (k % 30 == 0 && spell_team >= 0) {
                    static long sk = -999; static double sbx, sby, scx, scy, sl; static int st = -1;
                    const int d = 1 - spell_team;
                    const double sg = d == 0 ? 1.0 : -1.0;
                    double cx = 0, cy = 0, line = 1e9; int n = 0;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& q = s.world().player(j);
                        if (q.team != d || s.world().isKeeper(j)) continue;
                        cx += q.pos.x.toDouble(); cy += q.pos.y.toDouble(); ++n;
                        line = std::min(line, q.pos.x.toDouble() * sg);
                    }
                    cx /= n; cy /= n;
                    const double bx = b.pos.x.toDouble(), by = b.pos.y.toDouble();
                    if (sk == k - 30 && st == spell_team && spell_start <= k - 30) {
                        const double mx = cx - scx, my = cy - scy, bdx = bx - sbx, bdy = by - sby;
                        const double v = std::sqrt(mx * mx + my * my);
                        ++g_blk_sp[v < 0.5 ? 0 : v < 1 ? 1 : v < 2 ? 2 : v < 4 ? 3 : 4]; ++g_blk_n; g_blk_v += v;
                        g_blk_xx += bdx * bdx; g_blk_yy += bdy * bdy; g_blk_mx += mx * bdx; g_blk_my += my * bdy;
                        g_blk_lx += (line - sl) * sg * bdx;
                    }
                    sk = k; sbx = bx; sby = by; scx = cx; scy = cy; sl = line; st = spell_team;
                }
                for (int team = 0; team < 2; ++team) {
                    int near = 0;
                    double y0 = 1e9, y1 = -1e9, x0 = 1e9, x1 = -1e9;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team != team || s.world().isKeeper(j)) continue;
                        const double x = d.pos.x.toDouble(), y = d.pos.y.toDouble();
                        y0 = std::min(y0, y); y1 = std::max(y1, y); x0 = std::min(x0, x); x1 = std::max(x1, x);
                        if (j == *b.owner) continue;
                        const double dx = x - b.pos.x.toDouble(), dy = y - b.pos.y.toDouble();
                        if (dx * dx + dy * dy < 100.0) ++near;
                    }
                    const int w = team == ot ? 0 : 1;
                    if (w == 0 && (b.pos.x.toDouble() * (team == 0 ? 1.0 : -1.0)) > 0) {
                        const double sg = team == 0 ? 1.0 : -1.0;
                        int up = 0, behind = 0, marks = 0;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            const auto& d = s.world().player(j);
                            if (s.world().isKeeper(j)) continue;
                            const bool goal_side = (b.pos.x.toDouble() - d.pos.x.toDouble()) * sg > 0;
                            if (d.team != team) { if (goal_side) ++up; continue; }
                            if (goal_side && j != *b.owner) ++behind;
                            const int nn = s.brain().numberOf(j);
                            if (nn >= 0 && nn < 12 && j != *b.owner) { ++num_n[team][nn]; if (!goal_side) ++num_ahead[team][nn]; }
                            if (s.lastOrders()[j].why == ai::Why::PreventiveMark) ++marks;
                        }
                        // Pro zones in yards: 60-80, 80-100, 100-120 of 120.
                        const double from_goal = s.world().pitchHalfX().toDouble() - b.pos.x.toDouble() * sg;
                        const int zn = from_goal > 35 ? 0 : from_goal > 17.5 ? 1 : 2;
                        ++zn_ticks[team][zn]; zn_ahead[team][zn] += 9 - behind;
                        const double age_s = (k - spell_start) / 30.0;
                        const int ag = age_s < 5 ? 0 : age_s < 15 ? 1 : age_s < 30 ? 2 : 3;
                        ++age_ticks[team][zn][ag]; age_ahead[team][zn][ag] += 9 - behind;
                        double deepest = 1e9;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            const auto& d = s.world().player(j);
                            if (s.world().isKeeper(j)) continue;
                            const double rel = (d.pos.x.toDouble() - b.pos.x.toDouble()) * sg;
                            if (d.team != team) { deepest = std::min(deepest, -rel); continue; }
                            if (j == *b.owner) continue;
                            const int nn = s.brain().numberOf(j);
                            if (nn < 0 || nn >= 12) continue;
                            zn_x[team][zn][nn] += rel; ++zn_xn[team][zn][nn];
                            zn_tx[team][zn][nn] += (s.lastOrders()[j].target.x.toDouble() - b.pos.x.toDouble()) * sg;
                        }
                        zn_line[team][zn] += -deepest;
                        const int u = std::min(up, 7);
                        ++up_ticks[team][u]; up_behind[team][u] += behind; up_marks[team][u] += marks;
                        if (behind <= up) ++up_short[team][u];
                    }
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team != team || s.world().isKeeper(j) || j == *b.owner) continue;
                        // A man holding shape is measured against the spot he
                        // holds (width and balance included); the rest
                        // against the ball-shifted formation spot.
                        const ai::Orders& oj = s.lastOrders()[j];
                        const math::Vec2 an = oj.why == ai::Why::Hold ? oj.target : s.brain().shapeAnchor(j, s.world());
                        const double ax = an.x.toDouble() - d.pos.x.toDouble(), ay = an.y.toDouble() - d.pos.y.toDouble();
                        const double dd = std::sqrt(ax * ax + ay * ay);
                        off_sum[team][w] += dd; ++off_n[team][w];
                        // G5.6 (§8.104): how fast the spot a man holds slides, over 1 s.
                        if (k % 30 == 0) {
                            static double px[32], py[32]; static long pk[32];
                            if (oj.why == ai::Why::Hold) {
                                if (pk[j] == static_cast<long>(k) - 30) {
                                    const double mx = oj.target.x.toDouble() - px[j], my = oj.target.y.toDouble() - py[j];
                                    const double v = std::sqrt(mx * mx + my * my);
                                    const int bin = v < 0.5 ? 0 : v < 1 ? 1 : v < 2 ? 2 : v < 4 ? 3 : 4;
                                    ++g_hold_tv[w][bin]; g_hold_tv_sum[w] += v; ++g_hold_tv_n[w];
                                    int nb = 0;   // depth rank among his outfielders, 0 = deepest
                                    { const double sgj = d.team == 0 ? 1.0 : -1.0;
                                      for (std::uint8_t q = 0; q < s.world().playerCount(); ++q)
                                          if (q != j && s.world().player(q).team == d.team && !s.world().isKeeper(q) &&
                                              s.world().player(q).pos.x.toDouble() * sgj < d.pos.x.toDouble() * sgj) ++nb; }
                                    if (w == 1 && nb >= 0 && nb < 12) { g_hold_num[nb] += v; ++g_hold_num_n[nb]; if (v >= 4) ++g_hold_num_fast[nb]; }
                                }
                                px[j] = oj.target.x.toDouble(); py[j] = oj.target.y.toDouble(); pk[j] = static_cast<long>(k);
                            } else pk[j] = -999;
                        }
                        if (w == 0) { ++ip_why[team][static_cast<int>(oj.why)]; ++ip_n[team]; }
                        const int jn = s.brain().numberOf(j);
                        const std::uint8_t man = s.brain().directOpponentOf(j, s.world());
                        if (w == 0 && man != 255 && (jn == 2 || jn == 3 || jn == 4 || jn == 5 || jn == 6)) {
                            const auto& mp = s.world().player(man).pos;
                            const double sg = team == 0 ? 1.0 : -1.0;
                            if (jn <= 3) {
                                ++fb_n[team];
                                if (std::fabs(d.pos.y.toDouble()) > std::fabs(mp.y.toDouble())) {
                                    ++fb_wide[team];
                                    if (std::fabs(d.pos.y.toDouble()) > std::fabs(mp.y.toDouble()) + 3.0) ++fb_wide3[team];
                                    ++fb_wide_why[team][static_cast<int>(oj.why)];
                                }
                            }
                            if ((b.pos.x.toDouble() - mp.x.toDouble()) * sg >= 0) {
                                ++back_n[team];
                                if ((mp.x.toDouble() - d.pos.x.toDouble()) * sg > 0) ++back_goal_side[team];
                            }
                        }
                        if (oj.why == ai::Why::Hold) {
                            const int settled = k - spell_start >= 5 * 30 ? 1 : 0;
                            hold_gap[settled] += dd; ++hold_n[settled];
                        }
                        if (dd > 10.0) { ++off_ticks[team][w]; ++off_why[team][w][static_cast<int>(oj.why)]; }
                    }
                    crowd_sum[team][w] += near; wide_sum[team][w] += y1 - y0; long_sum[team][w] += x1 - x0;
                    ++crowd_ticks[team][w];
                }
            }
            for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                const auto& d = s.world().player(j);
                const ai::Orders& o = s.lastOrders()[j];
                const double tx = o.target.x.toDouble() - d.pos.x.toDouble(), ty = o.target.y.toDouble() - d.pos.y.toDouble();
                const double vx = d.vel.x.toDouble(), vy = d.vel.y.toDouble();
                if ((o.target.x.raw != 0 || o.target.y.raw != 0) && tx * tx + ty * ty < 6.25 &&
                    vx * vx + vy * vy > 6.25 && tx * vx + ty * vy < 0)
                    { ++overrun[d.team]; ++overrun_why[d.team][static_cast<int>(o.why)]; }
            }
            if (b.owner) {
                const auto& c = s.world().player(*b.owner);
                const int ct = c.team;
                const bool third = (ct == 0 ? c.pos.x.toDouble() : -c.pos.x.toDouble()) > 17.5;
                // G5.4: as the benchmark counts it: the same team kept it
                // across the line by a carry or a completed pass. A ball won
                // inside the third is not an entry (it counted as one, which
                // inflated this number in a game full of turnovers).
                {   // G5.4 (mig 923 rows): the carrier's nearest opponent, every 5th tick.
                    if (k % 5 == 0) {
                        double nn = 1e9;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            const auto& q = s.world().player(j);
                            if (q.team == ct) continue;
                            const double dx = q.pos.x.toDouble() - c.pos.x.toDouble(), dy = q.pos.y.toDouble() - c.pos.y.toDouble();
                            nn = std::min(nn, std::sqrt(dx * dx + dy * dy));
                        }
                        carrier_near[nn < 2 ? 0 : nn < 5 ? 1 : nn < 10 ? 2 : 3] += 1;
                        carrier_near[4] += nn;
                        carrier_near[5] += 1;
                    }
                }
                {   // G5.4: a spell as StatsBomb counts one: the other side has it
                    // only once it keeps it 1 s or completes a pass.
                    if (ct == st_team) st_cand = -1;
                    else if (st_cand != ct) { st_cand = ct; st_cand_tick = k; st_cand_slot = *b.owner; st_cand_x = c.pos.x.toDouble(); }
                    else if (k - st_cand_tick >= 30 || *b.owner != st_cand_slot) {
                        if (st_team >= 0 && st_cand_tick >= st_start) { ++st_spells; st_ticks += st_cand_tick - st_start; }
                        if ((ct == 0 ? 52.5 - st_cand_x : 52.5 + st_cand_x) < 35) ++st_high[ct];
                        st_team = ct; st_start = st_cand_tick; st_cand = -1;
                    }
                }
                static int ent_team = -1;
                static bool ent_third = false;
                if (third && ent_team == ct && !ent_third) ++entries[ct];
                ent_team = ct;
                ent_third = third;
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
            for (const auto& e : s.lastEvents())
                if (e.type == core::MatchEventType::Offside) ++off_called[e.team ^ 1];
            {   // G5.2: the restart ledger
                ++rs_tick;
                // G5.5: all outfielders off the ball, by speed; why he's moving at 5+.
                for (std::uint8_t j = 0; j < s.world().playerCount() && j < 64; ++j) {
                    const int wy = static_cast<int>(s.lastOrders()[j].why);
                    oc_prev_why[j] = wy;
                    if (s.world().isKeeper(j) || (s.world().ball().owner && *s.world().ball().owner == j)) continue;
                    const double v = std::hypot(s.world().player(j).vel.x.toDouble(), s.world().player(j).vel.y.toDouble());
                    ++oc_sp_t[v < 2 ? 0 : v < 5 ? 1 : 2];
                    oc_sp_v += v;
                    if (v >= 5) {
                        ++oc_sp_why[wy];
                        const auto& so = s.lastOrders()[j];
                        const auto& sp = s.world().player(j);
                        const double gap = std::hypot(so.target.x.toDouble() - sp.pos.x.toDouble(), so.target.y.toDouble() - sp.pos.y.toDouble());
                        const bool ours = (s.world().ball().owner && s.world().player(*s.world().ball().owner).team == sp.team) || (!s.world().ball().owner && s.world().lastTouchTeam() == sp.team);
                        ++oc_sp_gap[wy][gap < 3 ? 0 : gap < 8 ? 1 : gap < 15 ? 2 : 3];
                        ++oc_sp_side[ours ? 0 : 1];
                    }
                }
                if (s.world().ball().owner) oc_owned_tick = static_cast<long>(s.world().tickCount());
                else if (oc_other >= 0 && oc_other < s.world().playerCount() && s.world().outStage() == 0) {
                    const auto& rc = s.world().player(static_cast<std::uint8_t>(oc_other));
                    const auto& bb = s.world().ball();
                    const double dd = std::hypot(rc.pos.x.toDouble() - bb.pos.x.toDouble(), rc.pos.y.toDouble() - bb.pos.y.toDouble());
                    if (std::getenv("GAME_TRACE_OUT") && oc_log.size() < 400) {
                        char ln[220];
                        const auto& ro = s.lastOrders()[oc_other];
                        std::snprintf(ln, sizeof ln, "      t%3zu ball (%.2f,%.2f) v %.1f | he (%.2f,%.2f) v (%.1f,%.1f) d %.2f %s -> (%.1f,%.1f)", oc_log.size(),
                                      bb.pos.x.toDouble(), bb.pos.y.toDouble(), std::hypot(bb.vel.x.toDouble(), bb.vel.y.toDouble()),
                                      rc.pos.x.toDouble(), rc.pos.y.toDouble(), rc.vel.x.toDouble(), rc.vel.y.toDouble(), dd,
                                      ai::kWhyNames[static_cast<int>(ro.why)], ro.target.x.toDouble(), ro.target.y.toDouble());
                        oc_log.emplace_back(ln);
                    }
                    if (dd < oc_near) {
                        oc_near = dd; oc_near_v = std::hypot(bb.vel.x.toDouble(), bb.vel.y.toDouble()); oc_near_z = bb.pos.z.toDouble();
                        oc_near_why = static_cast<int>(s.lastOrders()[oc_other].why);
                        oc_near_run = std::hypot(rc.vel.x.toDouble(), rc.vel.y.toDouble());
                    }
                }
                for (int t = 0; t < 2; ++t) {   // G5.3: a header at goal, and whether it goes in
                    const int h = s.world().headersAtGoal(t);
                    if (h > air_seen[t]) {
                        air_tick[t] = rs_tick;
                        const auto& w = s.world();
                        const auto& bb = w.ball();
                        static const int trace_h = std::atoi(envOr("GAME_TRACE_HEADER", "0"));
                        static int traced = 0;
                        if (traced < trace_h) {
                            ++traced;
                            for (std::uint8_t j = 0; j < w.playerCount(); ++j)
                                if (w.isKeeper(j) && w.player(j).team != t)
                                    std::printf("header t%d from (%.1f,%.1f,%.1f) v (%.1f,%.1f,%.1f) keeper (%.1f,%.1f) dive %d\n", t, bb.pos.x.toDouble(), bb.pos.y.toDouble(), bb.pos.z.toDouble(),
                                                bb.vel.x.toDouble(), bb.vel.y.toDouble(), bb.vel.z.toDouble(), w.player(j).pos.x.toDouble(), w.player(j).pos.y.toDouble(), (int)w.player(j).dive_ticks);
                        }
                    }
                    air_seen[t] = h;
                }
                ++rs_ticks;
                if (s.world().outStage() != 0 || s.world().restartTeam() != 0xFF) ++rs_dead_ticks;
                for (const auto& e : s.lastEvents()) {
                    const int k = e.type == core::MatchEventType::ThrowIn ? 0 : e.type == core::MatchEventType::GoalKick ? 1
                                  : e.type == core::MatchEventType::Corner ? 2 : -1;
                    if (k < 0) continue;
                    ++rs_n[k][e.team];
                    {   // G5.5: the last thing that touched it
                        const auto& bl = s.world().ball();
                        const int lk = bl.last_kicker;
                        const int cat = s.world().outTick() - oc_owned_tick <= 2 ? 7
                                        : lk == oc_kicker && oc_cat >= 0 ? oc_cat
                                        : lk < s.world().playerCount() && s.world().isKeeper(static_cast<std::uint8_t>(lk)) ? 5 : 6;
                        ++oc_n[k][cat];
                        if (lk == oc_kicker && oc_cat >= 0) ++oc_dead_cat[oc_cat];
                        if (cat == 2 && oc_cz >= 0) {
                            if (k == 0) ++oc_cz_throw[oc_cz / 3][oc_cz % 3];
                            if (k == 2) ++oc_cz_corner[oc_cz / 3][oc_cz % 3];
                        }
                        if (k == 0 && cat == 0 && oc_rx_bin >= 0) ++oc_rx_out[oc_rx_bin];
                        if (k == 0 && cat == 0) {
                            const int nb = oc_near < 0.5 ? 0 : oc_near < 1 ? 1 : oc_near < 2 ? 2 : oc_near < 4 ? 3 : oc_near < 8 ? 4 : 5;
                            ++oc_near_hist[nb];
                        }
                        // GAME_TRACE_OUT=n: the first n balls out by a kick.
                        static const int trace_out = [] { const char* v = std::getenv("GAME_TRACE_OUT"); return v ? std::atoi(v) : 0; }();
                        static int trace_out_n = 0;
                        if (lk == oc_kicker && trace_out_n < trace_out && lk < s.world().playerCount()) {
                            ++trace_out_n;
                            const auto& ko = s.lastOrders()[lk];
                            const auto& kp = s.world().player(static_cast<std::uint8_t>(lk));
                            std::printf("OUT k=%d cat=%d why(now)=%s kicked t-%.1fs from (%.1f,%.1f) to (%.1f,%.1f) other=%d out at (%.1f,%.1f) out-lag %.1fs\n", k, cat,
                                        ai::kWhyNames[static_cast<int>(ko.why)], (static_cast<long>(s.world().outTick()) - oc_kick_tick) / 30.0,
                                        oc_from[0], oc_from[1], oc_to[0], oc_to[1], oc_other, bl.pos.x.toDouble(), bl.pos.y.toDouble(),
                                        (static_cast<long>(s.world().tickCount()) - static_cast<long>(s.world().outTick())) / 30.0);
                            if (oc_other >= 0 && oc_other < s.world().playerCount())
                                for (std::size_t q = 0; cat == 0 && q < oc_log.size(); q += (q + 12 < oc_log.size() ? 3 : 1)) std::printf("%s\n", oc_log[q].c_str());
                            if (oc_other >= 0 && oc_other < s.world().playerCount())
                                std::printf("    NEAR %.2f m, ball %.1f m/s z %.2f, he %s at %.1f m/s\n", oc_near, oc_near_v, oc_near_z,
                                            oc_near_why >= 0 ? ai::kWhyNames[oc_near_why] : "-", oc_near_run);
                            if (oc_other >= 0 && oc_other < s.world().playerCount())
                                std::printf("    receiver now at (%.1f,%.1f); kick speed %.1f\n", s.world().player(static_cast<std::uint8_t>(oc_other)).pos.x.toDouble(),
                                            s.world().player(static_cast<std::uint8_t>(oc_other)).pos.y.toDouble(), oc_speed);
                        }
                    }
                    rs_open = k;
                    rs_team = e.team;
                    rs_dead_s = (s.world().tickCount() - s.world().outTick()) / static_cast<double>(core::kTickRate);
                    const auto& c = s.world().lastOutCall();
                    if (c.official == 0) ++rs_called_by[0]; else ++rs_called_by[1];
                    if (c.deflection) ++rs_deflect;
                }
                if (rs_open >= 0 && s.world().restartTeam() == 0xFF) {
                    rs_dead[rs_open].push_back((s.world().tickCount() - s.world().outTick()) / static_cast<double>(core::kTickRate));
                    rs_start_x = s.world().ball().pos.x.toDouble();
                    rs_start_y = s.world().ball().pos.y.toDouble();
                    rs_watch = rs_open;
                    rs_watch_team = rs_team;
                    rs_played_tick = rs_tick;
                    rs_keep_check = 1;
                    rs_open = -1;
                    rs_last = rs_watch; rs_last_team = rs_team; rs_last_tick = rs_tick;
                    if (rs_last == 2 && rs_trace_n < trace_corner) {   // GAME_TRACE_CORNER=n
                        rs_trace = 1; ++rs_trace_n;
                        const auto& w = s.world();
                        const auto& o = s.lastOrders();
                        std::printf("corner %d team %d kick from (%.0f,%.0f) aim (%.1f,%.1f) to %d\n", rs_trace_n, rs_team,
                                    rs_start_x, rs_start_y, w.ball().last_kicker < w.playerCount() ? o[w.ball().last_kicker].target.x.toDouble() : 0.0,
                                    w.ball().last_kicker < w.playerCount() ? o[w.ball().last_kicker].target.y.toDouble() : 0.0, (int)w.ball().pass_to);
                        for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
                            const auto& q = w.player(j);
                            if (std::fabs(q.pos.x.toDouble()) < 25 || w.isKeeper(j))
                                std::printf("   %s%d t%d (%.1f,%.1f)\n", w.isKeeper(j) ? "GK " : "", j, q.team, q.pos.x.toDouble(), q.pos.y.toDouble());
                        }
                    }
                }
                if (rs_trace && rs_tick != rs_last_tick) {
                    const auto& w = s.world();
                    const auto& bb = w.ball();
                    const long age = rs_tick - rs_last_tick;
                    if (age % 15 == 0 || (bb.owner && !rs_traced_owner)) {
                        double near = 99; int nearj = -1;
                        for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
                            if (w.player(j).team == rs_last_team) continue;
                            const double dx = w.player(j).pos.x.toDouble() - bb.pos.x.toDouble(), dy = w.player(j).pos.y.toDouble() - bb.pos.y.toDouble();
                            const double d = std::sqrt(dx * dx + dy * dy);
                            if (d < near) { near = d; nearj = j; }
                        }
                        std::printf("   +%.1fs ball (%.1f,%.1f,%.1f) v %.1f owner %d t%d nearest-opp %d %.1f m\n", age / 30.0, bb.pos.x.toDouble(), bb.pos.y.toDouble(),
                                    bb.pos.z.toDouble(), std::sqrt(bb.vel.x.toDouble() * bb.vel.x.toDouble() + bb.vel.y.toDouble() * bb.vel.y.toDouble()),
                                    bb.owner ? (int)*bb.owner : -1, bb.owner ? (int)w.player(*bb.owner).team : -1, nearj, near);
                        rs_traced_owner = bb.owner.has_value();
                    }
                    if (bb.owner) { if (s.lastOrders()[*bb.owner].action == core::Action::Shot) std::printf("   SHOT by %d\n", (int)*bb.owner); }
                    for (const auto& e : s.lastEvents()) if (e.type == core::MatchEventType::Goal) std::printf("   GOAL team %d\n", (int)e.team);
                    if (age > 8 * core::kTickRate) { rs_trace = 0; rs_traced_owner = false; }
                }
                if (rs_watch >= 0) {
                    const long age = rs_tick - rs_played_tick;
                    const auto& bb = s.world().ball();
                    if (rs_keep_check == 1 && bb.owner) {
                        const bool mine = s.world().player(*bb.owner).team == rs_watch_team;
                        if (mine) ++rs_kept[rs_watch];
                        const double dx = bb.pos.x.toDouble() - rs_start_x, dy = bb.pos.y.toDouble() - rs_start_y;
                        rs_len[rs_watch].push_back(std::sqrt(dx * dx + dy * dy));
                        rs_keep_check = 0;
                    }
                    const int headed = s.world().headersAtGoal(rs_watch_team);   // G5.3: a header is a shot
                    if (age == 0) rs_headers_at_kick = headed;
                    if (headed > rs_headers_at_kick ||
                        (bb.owner && s.world().player(*bb.owner).team == rs_watch_team &&
                         s.lastOrders()[*bb.owner].action == core::Action::Shot)) {
                        ++rs_shot[rs_watch];
                        rs_watch = -1;
                    } else if (age > 10 * core::kTickRate) {
                        rs_watch = -1;
                    }
                }
            }
            for (const auto& e : s.lastEvents()) {
                if (e.type != core::MatchEventType::Goal) continue;
                if (k - conv_k[e.team] < 120) ++conv_goals[conv_bin[e.team]];   // G5.4
                if (std::getenv("GAME_TRACE_GOAL")) {   // G5.4
                    double kx = 0, ky = 0;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j)
                        if (s.world().isKeeper(j) && s.world().player(j).team != e.team) { kx = s.world().player(j).pos.x.toDouble(); ky = s.world().player(j).pos.y.toDouble(); }
                    std::printf("goal t%d min %.1f; last shot %ld ticks ago from bin %d; last kick why %s at (%.0f,%.0f); keeper (%.1f,%.1f); ball (%.1f,%.1f,%.1f)\n",
                                (int)e.team, k / 1800.0, k - conv_k[e.team], conv_bin[e.team], ai::kWhyNames[lk_why[e.team]], lk_x[e.team], lk_y[e.team], kx, ky,
                                s.world().ball().pos.x.toDouble(), s.world().ball().pos.y.toDouble(), s.world().ball().pos.z.toDouble());
                }
                ++assist[e.team][last_assist[e.team]];
                // G5.2: by the kick's own clock; the shot closes rs_watch before its goal lands.
                if (rs_last >= 0 && e.team == rs_last_team && rs_tick - rs_last_tick <= 10 * core::kTickRate) ++rs_goal[rs_last];
                if (air_tick[e.team] >= 0 && rs_tick - air_tick[e.team] <= 2 * core::kTickRate) ++air_scored[e.team];   // G5.3
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
                    tf_tick = -1;
                    for (const auto& e : s.lastEvents()) {
                        if (e.type != core::MatchEventType::Offside) continue;
                        ++t.offside;
                        if (kick_at.size() != s.world().playerCount() || kick_job.size() != kick_at.size()) continue;
                        int who = -1; double bd = 1e9;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            if (s.world().player(j).team != pend_team) continue;
                            const double dx = s.world().player(j).pos.x.toDouble() - b.pos.x.toDouble(), dy = s.world().player(j).pos.y.toDouble() - b.pos.y.toDouble();
                            if (dx * dx + dy * dy < bd) { bd = dx * dx + dy * dy; who = j; }
                        }
                        if (who < 0) continue;
                        // Their second-last man at the kick (keeper counts), in our attack direction.
                        const double sg = pend_team == 0 ? 1.0 : -1.0;
                        double l1 = -1e9, l2 = -1e9;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            if (s.world().player(j).team == pend_team) continue;
                            const double x = kick_at[j].x.toDouble() * sg;
                            if (x > l1) { l2 = l1; l1 = x; } else if (x > l2) l2 = x;
                        }
                        const double past = kick_at[who].x.toDouble() * sg - l2;
                        ++ow_n; ++ow_why[pend_why]; ow_intended += who == pend_other; ++ow_job[kick_job[who]];
                        ++ow_depth[past < 0 ? 0 : past < 1 ? 1 : past < 3 ? 2 : 3];
                    }
                    pend_team = -1;
                } else if (b.owner) {
                    if (s.world().player(*b.owner).team == pend_team) {
                        if (pend_why != static_cast<int>(ai::Why::Shoot)) last_assist[pend_team] = pend_why;
                        ++t.mate;
                        if (pend_bl) ++bl_mate[pend_team];
                        if (*b.owner == pend_other) ++t.intended;
                        if (pf_bucket >= 0 && *b.owner == pend_other) ++fr_got[pend_team][pf_bucket];
                        if (tf_tick >= 0 && *b.owner != pend_other) {
                            const auto& rv = s.world().player(tf_to);
                            const double gx = rv.pos.x.toDouble() - b.pos.x.toDouble(), gy = rv.pos.y.toDouble() - b.pos.y.toDouble();
                            std::printf("%s || MATE #%d took it after %.1f s; #%d %.1f m from it, doing %s\n", tf_line.c_str(), *b.owner, (k - tf_tick) / 30.0,
                                        tf_to, std::sqrt(gx * gx + gy * gy), ai::kWhyNames[static_cast<int>(s.lastOrders()[tf_to].why)]);
                            for (const auto& l : tf_ticks) std::printf("%s\n", l.c_str());
                            ++tf_done;
                        }
                        tf_tick = -1;
                    } else {
                        ++t.lost;
                        // StatsBomb's Interception (G4.85): an OUTFIELDER cutting
                        // out a pass — a blocked or saved shot is a Block /
                        // Goal Keeper event, a keeper's claim a Goal Keeper one.
                        // Counted with them, 23% of the "interceptions" were
                        // shots and a quarter keepers'.
                        const bool sb_int = pend_why != static_cast<int>(ai::Why::Shoot) && !s.world().isKeeper(*b.owner);
                        if (sb_int) ++(prev_ball_v >= 3.0 ? cut : picked)[pend_team ^ 1];
                        if (sb_int && prev_ball_v >= 3.0 && kick_at.size() == s.world().playerCount()) {
                            const int j = *b.owner;
                            {
                                const auto& d = s.world().player(j);
                                const double v = std::sqrt(prev_ov[j][0] * prev_ov[j][0] + prev_ov[j][1] * prev_ov[j][1]);
                                const double rx = prev_bvx - prev_ov[j][0], ry = prev_bvy - prev_ov[j][1], rel = std::sqrt(rx * rx + ry * ry);
                                (void)d;
                                ++rt_n[0][static_cast<int>(s.lastOrders()[j].why)];
                                ++rt_sp[0][v < 2 ? 0 : v < 4 ? 1 : v < 6 ? 2 : 3];
                                ++rt_rel[0][rel < 6 ? 0 : rel < 9 ? 1 : rel < 12 ? 2 : 3];
                            }
                            const double mx = s.world().player(j).pos.x.toDouble() - kick_at[j].x.toDouble(),
                                         my = s.world().player(j).pos.y.toDouble() - kick_at[j].y.toDouble();
                            const double mv = std::sqrt(mx * mx + my * my), ft = (k - kick_tick) / 30.0;
                            ++cut_moved[mv < 1 ? 0 : mv < 3 ? 1 : mv < 6 ? 2 : 3];
                            ++cut_time[ft < 0.5 ? 0 : ft < 1 ? 1 : ft < 2 ? 2 : 3];
                            if (kick_pred >= 0) ++pred_cut[kick_pred];
                            if (kick_pred == 0 && trace_flip && m == 0 && flips < trace_flip) {
                                ++flips;
                                std::printf("FLIP t=%.1fs team%d %s, predicted ours #%d by %.1f s; cut by #%d (their predicted #%d) after %.1f s\n",
                                            k / 30.0, pend_team, pend_why == ai::kWhyCount ? "in behind" : ai::kWhyNames[pend_why], pred_us,
                                            pred_margin / 30.0, j, pred_them, (k - kick_tick) / 30.0);
                                for (const auto& l : flip_lines) std::printf("%s\n", l.c_str());
                            }
                            if (kick_pred == 0) {
                                ++po_n;
                                po_cutter_pred += j == pred_them;
                                if (pred_us_why >= 0) ++po_us_why[pred_us_why];
                                ++po_margin[pred_margin < 6 ? 0 : pred_margin < 15 ? 1 : pred_margin < 30 ? 2 : 3];
                            }
                            ++cut_by_why[pend_why]; ++cut_why_taker[static_cast<int>(s.lastOrders()[j].why)]; ++cut_n;
                        }
                        if (pf_bucket >= 0) ++fr_lost[pend_team][pf_bucket];
                        if (tf_tick >= 0) {
                            const auto& rv = s.world().player(tf_to);
                            const double gx = rv.pos.x.toDouble() - b.pos.x.toDouble(), gy = rv.pos.y.toDouble() - b.pos.y.toDouble();
                            std::printf("%s || LOST to #%d after %.1f s; #%d %.1f m from it, doing %s\n", tf_line.c_str(), *b.owner, (k - tf_tick) / 30.0,
                                        tf_to, std::sqrt(gx * gx + gy * gy), ai::kWhyNames[static_cast<int>(s.lastOrders()[tf_to].why)]);
                            for (const auto& l : tf_ticks) std::printf("%s\n", l.c_str());
                            ++tf_done;
                        }
                        tf_tick = -1;
                    }
                    pend_team = -1;
                }
            }
            if (s.world().badTouchTick() != prev_bad && s.world().badTouchSlot() < s.world().playerCount()) {
                prev_bad = s.world().badTouchTick();
                ++bobbles[s.world().player(s.world().badTouchSlot()).team];
                const int bs = s.world().badTouchSlot();
                const int kind = prev_ltt != s.world().player(bs).team ? 2 : (prev_pass_to == bs ? 0 : 1);
                ++bt_kind[kind][prev_ball_v < 9 ? 0 : prev_ball_v < 12 ? 1 : prev_ball_v < 15 ? 2 : 3];
                if (kind == 2 && prev_ball_v >= 3.0) {
                    const auto& d = s.world().player(bs);
                    const double v = std::sqrt(d.vel.x.toDouble() * d.vel.x.toDouble() + d.vel.y.toDouble() * d.vel.y.toDouble());
                    const double rx = prev_bvx - d.vel.x.toDouble(), ry = prev_bvy - d.vel.y.toDouble(), rel = std::sqrt(rx * rx + ry * ry);
                    ++rt_n[1][static_cast<int>(s.lastOrders()[bs].why)];
                    ++rt_sp[1][v < 2 ? 0 : v < 4 ? 1 : v < 6 ? 2 : 3];
                    ++rt_rel[1][rel < 6 ? 0 : rel < 9 ? 1 : rel < 12 ? 2 : 3];
                }
            }
            if (pend_team >= 0 && k == kick_tick + 1) {
                const auto& fr = s.brain().flightRead(s.world());
                const int us = fr.first[pend_team], them = fr.first[pend_team ^ 1];
                kick_pred = !fr.live ? 2 : (them >= 0 && (us < 0 || fr.tick[them] < fr.tick[us])) ? 1 : (us >= 0 ? 0 : 2);
                pred_us = us; pred_them = them; pred_us_why = -1;
                pred_margin = (us >= 0 && them >= 0) ? fr.tick[them] - fr.tick[us] : 999;
                ++pred_all[kick_pred];
                ++pred_why[pend_why][kick_pred];
                if (pend_why == ai::kWhyCount && pend_other >= 0 && pend_other < s.world().playerCount()) {
                    const auto& rv = s.world().player(static_cast<std::uint8_t>(pend_other));
                    const double sg = pend_team == 0 ? 1.0 : -1.0;
                    int dj = -1; double dd = 1e9;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == pend_team || s.world().isKeeper(j)) continue;
                        const double dx = d.pos.x.toDouble() - rv.pos.x.toDouble(), dy = d.pos.y.toDouble() - rv.pos.y.toDouble();
                        if (dx * dx + dy * dy < dd) { dd = dx * dx + dy * dy; dj = j; }
                    }
                    if (dj >= 0) {
                        const auto& d = s.world().player(static_cast<std::uint8_t>(dj));
                        ++bh_n;
                        const double g = std::sqrt(dd);
                        ++bh_gap[g < 2 ? 0 : g < 4 ? 1 : g < 8 ? 2 : 3];
                        const double dv = (rv.vel.x.toDouble() - d.vel.x.toDouble()) * sg;   // runner faster toward goal by
                        ++bh_dv[dv < 2 ? 0 : dv < 4 ? 1 : dv < 6 ? 2 : 3];
                        ++bh_job[static_cast<int>(s.lastOrders()[dj].why)];
                        bh_face_back += d.face.x.toDouble() * sg > 0.3;   // facing his own goal (the way the runner goes)
                    }
                }
                if (pend_why == ai::kWhyCount) {
                    ++ib_all_read[kick_read];
                    if (kick_pred == 1) ++ib_theirs_read[kick_read];
                    if (kick_read) {
                        const bool loft = s.world().ball().pos.z.raw > 0 || s.world().ball().vel.z.raw != 0;
                        ++ib_loft_all[loft];
                        if (kick_pred == 1) ++ib_loft_theirs[loft];
                    }
                    if (kick_pred == 1 && kick_read && them >= 0 && kick_passer >= 0) {
                        ++ib_seen[s.brain().inView(static_cast<core::SlotIndex>(kick_passer), s.world(), static_cast<core::SlotIndex>(them)) ? 1 : 0];
                        const int a = s.brain().lookAge(static_cast<core::SlotIndex>(kick_passer), s.world());
                        ++ib_age[a <= 0 ? 0 : a < 15 ? 1 : a < 45 ? 2 : 3];
                    }
                }
                if (pend_why == ai::kWhyCount && kick_pred == 1 && fr.live) {
                    const double ax = kick_aim.x.toDouble() - kick_from.x.toDouble(), ay = kick_aim.y.toDouble() - kick_from.y.toDouble();
                    const double bvx = s.world().ball().vel.x.toDouble(), bvy = s.world().ball().vel.y.toDouble();
                    const double al = std::sqrt(ax * ax + ay * ay), bl = std::sqrt(bvx * bvx + bvy * bvy);
                    if (al > 1 && bl > 0.1) {
                        double c = (ax * bvx + ay * bvy) / (al * bl);
                        c = c > 1 ? 1 : (c < -1 ? -1 : c);
                        const double deg = std::acos(c) * 57.2958;
                        ++ib_n;
                        ++ib_err[deg < 2 ? 0 : deg < 5 ? 1 : deg < 10 ? 2 : 3];
                        const double mx = fr.at[them].x.toDouble() - kick_from.x.toDouble(), my = fr.at[them].y.toDouble() - kick_from.y.toDouble();
                        const double along = std::sqrt(mx * mx + my * my);
                        ++ib_where[along < al - 3 ? 0 : along <= al + 3 ? 1 : 2];
                    }
                }
            }
            if (trace_flip && m == 0 && flips < trace_flip && pend_team >= 0 && kick_pred == 0 && k > kick_tick && (k - kick_tick) % 6 == 1) {
                const auto& fr = s.brain().flightRead(s.world());
                const auto& w = s.world();
                auto who = [&](int j) {
                    if (j < 0) return std::string("-");
                    const auto& d = w.player(j);
                    const double bx = d.pos.x.toDouble() - b.pos.x.toDouble(), by = d.pos.y.toDouble() - b.pos.y.toDouble();
                    char t[200];
                    const ai::Orders& oj = s.lastOrders()[j];
                    const double tx = oj.target.x.toDouble() - d.pos.x.toDouble(), ty = oj.target.y.toDouble() - d.pos.y.toDouble();
                    const double ax = fr.live && fr.tick[j] >= 0 ? fr.at[j].x.toDouble() - b.pos.x.toDouble() : 0,
                                 ay = fr.live && fr.tick[j] >= 0 ? fr.at[j].y.toDouble() - b.pos.y.toDouble() : 0;
                    std::snprintf(t, sizeof t, "#%d %.1fm v%.1f [vel %.1f,%.1f wish %.2f,%.2f face %.2f,%.2f to target %.1f,%.1f] %s, read +%.1fs (target %.1fm off him, meet point %.1fm up the ball's path, wish %.2f)", j, std::sqrt(bx * bx + by * by),
                                  std::sqrt(d.vel.x.toDouble() * d.vel.x.toDouble() + d.vel.y.toDouble() * d.vel.y.toDouble()),
                                  d.vel.x.toDouble(), d.vel.y.toDouble(), oj.move.move.x.toDouble(), oj.move.move.y.toDouble(),
                                  d.face.x.toDouble(), d.face.y.toDouble(), tx, ty,
                                  ai::kWhyNames[static_cast<int>(oj.why)],
                                  fr.live && fr.tick[j] >= 0 ? fr.tick[j] / 30.0 : -1.0, std::sqrt(tx * tx + ty * ty), std::sqrt(ax * ax + ay * ay),
                                  std::sqrt(oj.move.move.x.toDouble() * oj.move.move.x.toDouble() + oj.move.move.y.toDouble() * oj.move.move.y.toDouble()));
                    return std::string(t);
                };
                char t[600];
                std::snprintf(t, sizeof t, "   +%.1fs ball %.1f m/s z%.1f | ours %s | their first %s", (k - kick_tick) / 30.0,
                              std::sqrt(b.vel.x.toDouble() * b.vel.x.toDouble() + b.vel.y.toDouble() * b.vel.y.toDouble()), b.pos.z.toDouble(),
                              who(pred_us).c_str(), who(fr.live ? fr.first[pend_team ^ 1] : -1).c_str());
                flip_lines.push_back(t);
            }
            if (pend_team >= 0 && k == kick_tick + 1) flip_lines.clear();
            if (pend_team >= 0 && k == kick_tick + 10 && pred_us >= 0)
                pred_us_why = static_cast<int>(s.lastOrders()[pred_us].why);
            prev_ball_v = std::sqrt(b.vel.x.toDouble() * b.vel.x.toDouble() + b.vel.y.toDouble() * b.vel.y.toDouble());
            prev_ltt = s.world().lastTouchTeam();
            prev_bvx = b.vel.x.toDouble(); prev_bvy = b.vel.y.toDouble();
            prev_ctrl_until = s.world().controlUntilTick();
            if (b.owner && s.world().player(*b.owner).team == 1 && s.world().restartTeam() == 0xFF) {
                const int cn = s.brain().numberOf(*b.owner);
                if (cn == 4 || cn == 5) {
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        if (s.world().player(j).team != 0 || s.brain().numberOf(j) != 9) continue;
                        const auto& cbp = s.world().player(*b.owner);
                        const int drive = cbp.vel.x.toDouble() < -2.0 ? 1 : 0;   // team 1 attacks -x
                        ++n9_n[drive];
                        ++n9_job[drive][static_cast<int>(s.lastOrders()[j].why)];
                        const double dx = s.world().player(j).pos.x.toDouble() - cbp.pos.x.toDouble(), dy = s.world().player(j).pos.y.toDouble() - cbp.pos.y.toDouble();
                        n9_near[drive] += dx * dx + dy * dy < 9.0;
                    }
                }
            }
            for (std::uint8_t j = 0; j < s.world().playerCount() && j < 64; ++j) prev_why[j] = static_cast<int>(s.lastOrders()[j].why);
            for (std::uint8_t tm = 0; tm < 2; ++tm) {   // who stands offside right now, each side
                const double sg = tm == 0 ? 1.0 : -1.0;
                double l1 = -1e9, l2 = -1e9;
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                    if (s.world().player(j).team == tm) continue;
                    const double x = s.world().player(j).pos.x.toDouble() * sg;
                    if (x > l1) { l2 = l1; l1 = x; } else if (x > l2) l2 = x;
                }
                const double bx = b.pos.x.toDouble() * sg;
                for (std::uint8_t j = 0; j < s.world().playerCount() && j < 64; ++j) {
                    if (s.world().player(j).team != tm) continue;
                    const double x = s.world().player(j).pos.x.toDouble() * sg;
                    if (!(x > l2 && x > bx && x > 0)) off_since[j] = k;
                }
            }
            for (std::uint8_t j = 0; j < s.world().playerCount() && j < 64; ++j)
                prev_ov[j] = {s.world().player(j).vel.x.toDouble(), s.world().player(j).vel.y.toDouble()};
            prev_pass_to = b.owner ? -1 : static_cast<int>(b.pass_to);
            if (before && !b.owner && b.last_kicker == *before &&
                s.world().restartTeam() == 0xFF) {
                const ai::Orders& o = s.lastOrders()[*before];
                pend_team = s.world().player(*before).team;
                lk_why[pend_team] = static_cast<int>(o.why); lk_tick[pend_team] = k; lk_to[pend_team] = o.other; lk_rwhy10[pend_team] = -1;
                lk_x[pend_team] = s.world().player(*before).pos.x.toDouble(); lk_y[pend_team] = s.world().player(*before).pos.y.toDouble();
                oc_kicker = *before;
                if (o.why == ai::Why::Cross) {
                    g_cf_on = 1; g_cf_team = s.world().player(*before).team; g_cf_kicker = *before;
                    g_cf_high = o.action == core::Action::LoftedKick ? 1 : 0; ++g_cf_n[g_cf_high];
                    if (g_cf_high) {
                        g_cx_until = k + 120; g_cx_tx = o.target.x.toDouble(); g_cx_ty = o.target.y.toDouble();
                        g_cx_kx = s.world().player(*before).pos.x.toDouble(); g_cx_ky = s.world().player(*before).pos.y.toDouble();
                    }
                }
                {
                    static const int trace_cr = std::atoi(envOr("GAME_TRACE_CROSS", "0"));
                    if (o.why == ai::Why::Cross && g_cr_traced < trace_cr) {
                        ++g_cr_traced; g_cr_on = 1; g_cr_team = s.world().player(*before).team; g_cr_tick = k; g_cr_pz = 0;
                        const auto& kp = s.world().player(*before);
                        std::printf("CROSS t%d from (%.1f,%.1f) to (%.1f,%.1f) for %d carry %d act %d ball v (%.1f,%.1f,%.1f)\n", g_cr_team, kp.pos.x.toDouble(), kp.pos.y.toDouble(),
                                    o.target.x.toDouble(), o.target.y.toDouble(), o.other, (int)o.carry_m, (int)o.action, b.vel.x.toDouble(), b.vel.y.toDouble(), b.vel.z.toDouble());
                    }
                }
                oc_kick_tick = static_cast<long>(s.world().tickCount());
                oc_from[0] = s.world().player(*before).pos.x.toDouble(); oc_from[1] = s.world().player(*before).pos.y.toDouble();
                oc_to[0] = o.target.x.toDouble(); oc_to[1] = o.target.y.toDouble();
                oc_other = o.other;
                oc_near = 1e9; oc_near_why = -1; oc_log.clear();
                oc_rx_bin = -1;
                if (oc_cat == 0 && oc_other >= 0 && oc_other < s.world().playerCount()) {
                    // G5.5: the receiver at the kick. 0 under 2 m/s, 1 2-5 m/s, then
                    // 5+: 2 toward the passer, 3 across the ball's path, 4 away.
                    const auto& rk = s.world().player(static_cast<std::uint8_t>(oc_other));
                    const double vx = rk.vel.x.toDouble(), vy = rk.vel.y.toDouble(), v = std::hypot(vx, vy);
                    const double dx = oc_to[0] - oc_from[0], dy = oc_to[1] - oc_from[1], dl = std::max(0.1, std::hypot(dx, dy));
                    const double along = v > 0.01 ? (vx * dx + vy * dy) / (v * dl) : 0;
                    oc_rx_bin = v < 2 ? 0 : v < 5 ? 1 : along < -0.5 ? 2 : along > 0.5 ? 4 : 3;
                    ++oc_rx_n[oc_rx_bin];
                    if (std::hypot(vx, vy) >= 5) ++oc_rx_why[static_cast<int>(oc_prev_why[oc_other])];
                    oc_rx_lead += std::hypot(oc_to[0] - rk.pos.x.toDouble(), oc_to[1] - rk.pos.y.toDouble());
                    ++oc_rx_lead_n;
                }
                oc_speed = std::hypot(b.vel.x.toDouble(), b.vel.y.toDouble());
                oc_cat = o.why == ai::Why::Shoot ? 3 : s.world().isKeeper(*before) ? 4 : o.why == ai::Why::Clear ? 2
                       : o.action == core::Action::LoftedKick ? 1 : 0;
                if (o.why != ai::Why::Shoot && !s.world().isKeeper(*before)) {
                    const auto& rp = s.world().player(*before);
                    const double sg = rp.team == 0 ? 1.0 : -1.0, hx = s.world().pitchHalfX().toDouble();
                    const double x0 = rp.pos.x.toDouble() * sg + hx, y0 = std::fabs(rp.pos.y.toDouble());
                    const int z = (x0 < 16.5 && y0 < 20.16) ? 0 : x0 < 35 ? 1 : x0 < 70 ? 2 : 3;
                    ++rel_n[z];
                    if (oc_cat == 2) ++rel_clear[z];
                    {
                        const double tl = hx - rp.pos.x.toDouble() * sg;
                        const int xd = tl < 6 ? 0 : tl < 18 ? 1 : tl < 30 ? 2 : 3;
                        const int xw = y0 >= 24 ? 0 : y0 >= 14 ? 1 : 2;
                        ++xz_n[xd][xw];
                        if (o.why == ai::Why::Cross) ++xz_cross[xd][xw];
                    }
                }
                if (oc_cat == 2) {
                    ++oc_clear_kicks;
                    const auto& ck = s.world().player(*before);
                    const double sg = ck.team == 0 ? 1.0 : -1.0, hx = s.world().pitchHalfX().toDouble();
                    const double x0 = ck.pos.x.toDouble() * sg + hx, y0 = std::fabs(ck.pos.y.toDouble());
                    const int zx = (x0 < 16.5 && y0 < 20.16) ? 0 : x0 < 35 ? 1 : 2;
                    const int zy = y0 >= 24 ? 2 : y0 >= 12 ? 1 : 0;
                    oc_cz = zx * 3 + zy;
                    ++oc_cz_n[zx][zy];
                } else {
                    oc_cz = -1;
                }
                // G5.4 (§8.102): passes by third and pressure, as
                // benchmarks_statsbomb_direction.py measures them.
                if (o.why != ai::Why::Shoot && o.why != ai::Why::Clear && o.why != ai::Why::KeeperPunt &&
                    !s.world().isKeeper(*before) && (o.target.x.raw != 0 || o.target.y.raw != 0)) {
                    const auto& pk = s.world().player(*before);
                    const double sg2 = pk.team == 0 ? 1.0 : -1.0;
                    const double x0 = pk.pos.x.toDouble() * sg2, y0 = pk.pos.y.toDouble();
                    const double x1 = o.target.x.toDouble() * sg2, y1 = o.target.y.toDouble();
                    const int z = x0 + 52.5 < 35 ? 0 : x0 + 52.5 < 70 ? 1 : 2;
                    bool pr = false;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& q = s.world().player(j);
                        if (q.team == pk.team) continue;
                        const double dx = q.pos.x.toDouble() - pk.pos.x.toDouble(), dy = q.pos.y.toDouble() - pk.pos.y.toDouble();
                        if (dx * dx + dy * dy < 6.25) pr = true;
                    }
                    const double g = x1 - x0;
                    double* t = pass_dir[z][pr ? 1 : 0];
                    t[0] += 1; t[g >= 3 ? 1 : g <= -3 ? 3 : 2] += 1; t[4] += g;
                    t[5] += std::sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0));
                }
                if (trace_lost && m == 0) {
                    lk_snap[pend_team].clear();
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j)
                        lk_snap[pend_team].push_back(math::Vec2{s.world().player(j).pos.x, s.world().player(j).pos.y});
                    lk_tx[pend_team] = o.target.x.toDouble(); lk_ty[pend_team] = o.target.y.toDouble();
                    lk_vx[pend_team] = b.vel.x.toDouble(); lk_vy[pend_team] = b.vel.y.toDouble();
                }
                if (o.why == ai::Why::Shoot) {
                    const auto& sh = s.world().player(*before);
                    {   // G5.4: goals per shot by distance, like with like.
                        const double gx = (sh.team == 0 ? 52.5 : -52.5) - sh.pos.x.toDouble(), gy = sh.pos.y.toDouble();
                        const double sd = std::sqrt(gx * gx + gy * gy);
                        conv_bin[sh.team] = sd < 11 ? 0 : sd < 16 ? 1 : sd < 22 ? 2 : sd < 30 ? 3 : 4;
                        conv_k[sh.team] = k;
                        ++conv_shots[conv_bin[sh.team]];
                    }
                    bool alone = true;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == sh.team || s.world().isKeeper(j)) continue;
                        if (sh.team == 0 ? d.pos.x > sh.pos.x : d.pos.x < sh.pos.x) alone = false;
                    }
                    shot_breakaway[pend_team] = alone;
                    const int st = sh.team;
                    if (o3_team == st && spell_team == st) {
                        if (!o3_10 && k - o3_tick <= 300) { ++own3_shot10[st ^ 1]; o3_10 = true; }
                        if (!o3_any) { ++own3_shot_spell[st ^ 1]; o3_any = true; }
                    }
                    const double age = st == spell_team ? (k - spell_start) / 30.0 : 0.0;
                    int behind = 0;
                    double near = 1e9;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == st || s.world().isKeeper(j)) continue;
                        if (st == 0 ? d.pos.x > sh.pos.x : d.pos.x < sh.pos.x) ++behind;
                        const double dx = d.pos.x.toDouble() - sh.pos.x.toDouble(), dy = d.pos.y.toDouble() - sh.pos.y.toDouble();
                        near = std::min(near, std::sqrt(dx * dx + dy * dy));
                    }
                    const double gx = (st == 0 ? 52.5 : -52.5) - sh.pos.x.toDouble(), gy = sh.pos.y.toDouble();
                    const double dist = std::sqrt(gx * gx + gy * gy);
                    ++shot_n[st];
                    ++shot_age[st][age < 5 ? 0 : age < 10 ? 1 : age < 20 ? 2 : 3];
                    ++shot_behind[st][behind <= 2 ? 0 : behind <= 4 ? 1 : behind <= 6 ? 2 : 3];
                    ++shot_dist[st][dist < 11 ? 0 : dist < 18 ? 1 : dist < 25 ? 2 : 3];
                    ++shot_near[st][near < 1.5 ? 0 : near < 3 ? 1 : near < 6 ? 2 : 3];
                    if (rx_slot == *before) {
                        const double cx = sh.pos.x.toDouble() - rx_x, cy = sh.pos.y.toDouble() - rx_y;
                        const double cm = std::sqrt(cx * cx + cy * cy);
                        ++recv_behind[st][rx_behind <= 2 ? 0 : rx_behind <= 4 ? 1 : rx_behind <= 6 ? 2 : 3];
                        ++carry_m[st][cm < 3 ? 0 : cm < 10 ? 1 : cm < 25 ? 2 : 3];
                    }
                    if (st == spell_team) ++won_at[st][won_x < 35 ? 0 : won_x < 52.5 ? 1 : won_x < 70 ? 2 : 3];
                }
                pend_why = o.rung >= 1 && o.rung <= 2 ? ai::kWhyCount : static_cast<int>(o.why);
                pend_bl = false;
                if (o.why != ai::Why::Shoot && o.why != ai::Why::Clear && o.why != ai::Why::KeeperPunt &&
                    o.other >= 0 && o.other < s.world().playerCount() &&
                    s.world().player(static_cast<std::uint8_t>(o.other)).team == pend_team) {
                    const auto& ps = s.world().player(*before);
                    const double sg = ps.team == 0 ? 1.0 : -1.0;
                    double near = 1e9, back = -1e9;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == ps.team) continue;
                        const double dx = d.pos.x.toDouble() - ps.pos.x.toDouble(), dy = d.pos.y.toDouble() - ps.pos.y.toDouble();
                        near = std::min(near, std::sqrt(dx * dx + dy * dy));
                        if (!s.world().isKeeper(j)) back = std::max(back, d.pos.x.toDouble() * sg);
                    }
                    const double tx = o.target.x.toDouble() * sg, px = ps.pos.x.toDouble() * sg;
                    if (tx - px >= 3 && tx > back) {
                        pend_bl = true;
                        ++bl_n[pend_team];
                        ++bl_why[pend_team][pend_why];
                        bl_loft += o.action == core::Action::LoftedKick;
                        bl_own += px < 0;
                        bl_pressed += near < 2.5;
                        ++bl_depth[tx - back < 2 ? 0 : tx - back < 5 ? 1 : tx - back < 10 ? 2 : 3];
                    }
                }
                if (pend_why == ai::kWhyCount && *before < 64) {
                    const auto& ps = s.world().player(*before);
                    const double sg = ps.team == 0 ? 1.0 : -1.0;
                    double near = 1e9, back = -1e9;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == ps.team) continue;
                        const double dx = d.pos.x.toDouble() - ps.pos.x.toDouble(), dy = d.pos.y.toDouble() - ps.pos.y.toDouble();
                        near = std::min(near, std::sqrt(dx * dx + dy * dy));
                        if (!s.world().isKeeper(j)) back = std::max(back, d.pos.x.toDouble() * sg);
                    }
                    const double held = (k - got_tick[*before]) / 30.0, px = ps.pos.x.toDouble() * sg + 52.5;
                    const double depth = o.target.x.toDouble() * sg - back;
                    ++pb_n;
                    ++pb_near[near < 2.5 ? 0 : near < 5 ? 1 : 2];
                    ++pb_held[held < 0.5 ? 0 : held < 1 ? 1 : held < 2 ? 2 : 3];
                    ++pb_zone[px < 52.5 ? 0 : px < 70 ? 1 : 2];
                    ++pb_depth[depth < 2 ? 0 : depth < 5 ? 1 : depth < 10 ? 2 : 3];
                    pb_fire += o.why == ai::Why::PassLadder;
                    pb_loft += o.action == core::Action::LoftedKick;
                }
                if (o.other >= 0 && o.why != ai::Why::Shoot && o.other < s.world().playerCount() &&
                    s.world().player(static_cast<std::uint8_t>(o.other)).team == pend_team && *before < 64) {
                    const double d = (k - got_tick[*before]) / 30.0;
                    ++tob_n; tob_s += d; ++tob_b[d < 1 ? 0 : d < 2 ? 1 : d < 4 ? 2 : 3];
                }
                kick_passer = *before; kick_read = o.read; kick_aim = o.target; kick_from = math::Vec2{s.world().ball().pos.x, s.world().ball().pos.y};
                kick_at.clear(); kick_tick = k;
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j)
                    kick_at.push_back(math::Vec2{s.world().player(j).pos.x, s.world().player(j).pos.y});
                kick_job.assign(s.world().playerCount(), 0);
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) kick_job[j] = static_cast<int>(s.lastOrders()[j].why);
                pend_other = o.other;
                pf_bucket = -1;
                if (o.other >= 0 && o.other < s.world().playerCount() && o.why != ai::Why::Shoot &&
                    s.world().player(o.other).team == pend_team) {
                    const auto& rv = s.world().player(o.other);
                    double nd = 1e9;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == pend_team) continue;
                        const double dx = d.pos.x.toDouble() - rv.pos.x.toDouble(), dy = d.pos.y.toDouble() - rv.pos.y.toDouble();
                        nd = std::min(nd, std::sqrt(dx * dx + dy * dy));
                    }
                    pf_bucket = nd < 2 ? 0 : nd < 5 ? 1 : nd < 10 ? 2 : 3;
                    ++fr_n[pend_team][pf_bucket];
                    if (trace_free && m == 0 && pf_bucket == 3 && tf_done < trace_free) {
                        const auto& ps = s.world().player(*before);
                        const double ax = rv.pos.x.toDouble() - ps.pos.x.toDouble(), ay = rv.pos.y.toDouble() - ps.pos.y.toDouble();
                        const double tx = o.target.x.toDouble() - ps.pos.x.toDouble(), ty = o.target.y.toDouble() - ps.pos.y.toDouble();
                        char buf[400];
                        std::snprintf(buf, sizeof buf, "FREE t=%.1fs team%d %s #%d->#%d | man %.0f m away, aimed %.0f m, ball %.1f m/s z-vel %.1f | man moving %.1f,%.1f",
                                      k / 30.0, pend_team, ai::kWhyNames[static_cast<int>(o.why)], *before, o.other, std::sqrt(ax * ax + ay * ay),
                                      std::sqrt(tx * tx + ty * ty), std::sqrt(b.vel.x.toDouble() * b.vel.x.toDouble() + b.vel.y.toDouble() * b.vel.y.toDouble()),
                                      b.vel.z.toDouble(), rv.vel.x.toDouble(), rv.vel.y.toDouble());
                        tf_line = buf; tf_tick = k; tf_to = o.other; tf_team = pend_team; tf_len = std::sqrt(ax * ax + ay * ay);
                        tf_ticks.clear();
                    }
                }
                ++tally[pend_team][pend_why].kicks;
                const core::OffsideCall& oc = s.world().lastOffsideCall();
                ++op_all_kicks;
                if (pend_other >= 0 && pend_other < s.world().playerCount() && pend_why != static_cast<int>(ai::Why::Shoot) &&
                    s.world().player(static_cast<std::uint8_t>(pend_other)).team == pend_team) {
                    const double sg = pend_team == 0 ? 1.0 : -1.0;
                    double l1 = -1e9, l2 = -1e9;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        if (s.world().player(j).team == pend_team) continue;
                        const double x = s.world().player(j).pos.x.toDouble() * sg;
                        if (x > l1) { l2 = l1; l1 = x; } else if (x > l2) l2 = x;
                    }
                    double line = std::max(l2, std::max(b.pos.x.toDouble() * sg, 0.0));
                    const double gap = s.world().player(static_cast<std::uint8_t>(pend_other)).pos.x.toDouble() * sg - line;
                    const int q = gap < -3 ? 0 : gap < -1 ? 1 : gap <= 0 ? 2 : gap <= 1 ? 3 : 4;
                    ++tg_all; ++tg_n[q];
                    if (pend_other < 32 && ((oc.called >> pend_other) & 1u)) ++tg_flag[q];
                }
                if (oc.truth) {
                    ++op_kicks;
                    const double sg = pend_team == 0 ? 1.0 : -1.0;
                    double l1 = -1e9, l2 = -1e9;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        if (s.world().player(j).team == pend_team) continue;
                        const double x = s.world().player(j).pos.x.toDouble() * sg;
                        if (x > l1) { l2 = l1; l1 = x; } else if (x > l2) l2 = x;
                    }
                    for (std::uint8_t j = 0; j < s.world().playerCount() && j < 32; ++j) {
                        if (!((oc.truth >> j) & 1u)) continue;
                        ++op_men;
                        ++op_job[static_cast<int>(s.lastOrders()[j].why)];
                        const double past = s.world().player(j).pos.x.toDouble() * sg - l2;
                        static int dbg = std::atoi(envOr("GAME_TRACE_OFFSIDE_MEN", "0"));
                        if (dbg > 0 && m == 0 && past >= 8) {
                            --dbg;
                            const auto& pj = s.world().player(j);
                            const auto& oj = s.lastOrders()[j];
                            std::printf("OFFMAN t=%.1fs team%d #%d %s past %.1f m | x %.1f line %.1f ball %.1f (owner %d) | target x %.1f | vel x %.1f | since onside %.1f s\n",
                                        k / 30.0, pend_team, j, ai::kWhyNames[static_cast<int>(oj.why)], past, pj.pos.x.toDouble() * sg, l2,
                                        b.pos.x.toDouble() * sg, b.owner ? static_cast<int>(*b.owner) : -1, oj.target.x.toDouble() * sg,
                                        pj.vel.x.toDouble() * sg, (k - off_since[j]) / 30.0);
                        }
                        ++op_depth[past < 1 ? 0 : past < 3 ? 1 : past < 8 ? 2 : 3];
                        const double age = (k - off_since[j]) / 30.0;
                        ++op_age[age < 1 ? 0 : age < 3 ? 1 : age < 8 ? 2 : 3];
                    }
                }
                if (oc.assistant >= 0 && (oc.called | oc.truth)) {
                    ++flag_kicks;
                    flag_wrong += __builtin_popcount(oc.called & ~oc.truth);
                    flag_missed += __builtin_popcount(oc.truth & ~oc.called);
                    const double off = oc.off_line_m.toDouble();
                    ar_off_sum += off;
                    ++ar_off[off < -3 ? 0 : off < -1 ? 1 : off <= 1 ? 2 : off <= 3 ? 3 : 4];
                }
            }
        }
        off_wrong += s.world().wrongOffsideWhistles();
        rs_wrong_total += s.world().wrongOutCalls();
        air_seen[0] = air_seen[1] = 0;
        for (int t = 0; t < 2; ++t) g_blocks[t] += s.world().bodyBlocks(t);
        air_duels += s.world().aerialDuels(); air_lone += s.world().aerialLone();
        for (int t = 0; t < 2; ++t) { air_goal[t] += s.world().headersAtGoal(t); air_clear[t] += s.world().headersClear(t); }
        off_missed += s.world().missedOffsides();
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
    for (int w = 0; w < 2; ++w)
        if (g_hold_tv_n[w])
            std::printf("HOLD SPOT SLIDES %s: mean %.2f m/s; under 0.5 %.0f%%, 0.5-1 %.0f%%, 1-2 %.0f%%, 2-4 %.0f%%, 4+ %.0f%%\n",
                        w == 0 ? "with the ball" : "without it", g_hold_tv_sum[w] / g_hold_tv_n[w],
                        100.0 * g_hold_tv[w][0] / g_hold_tv_n[w], 100.0 * g_hold_tv[w][1] / g_hold_tv_n[w],
                        100.0 * g_hold_tv[w][2] / g_hold_tv_n[w], 100.0 * g_hold_tv[w][3] / g_hold_tv_n[w],
                        100.0 * g_hold_tv[w][4] / g_hold_tv_n[w]);
    if (g_blk_n)
        std::printf("BLOCK WITHOUT THE BALL over 1 s: middle mean %.2f m/s; under 0.5 %.0f%%, 0.5-1 %.0f%%, 1-2 %.0f%%, 2-4 %.0f%%, 4+ %.0f%%; slope on the ball: middle x %.2f, y %.2f; back line x %.2f\n",
                    g_blk_v / g_blk_n, 100.0 * g_blk_sp[0] / g_blk_n, 100.0 * g_blk_sp[1] / g_blk_n, 100.0 * g_blk_sp[2] / g_blk_n,
                    100.0 * g_blk_sp[3] / g_blk_n, 100.0 * g_blk_sp[4] / g_blk_n, g_blk_mx / g_blk_xx, g_blk_my / g_blk_yy, g_blk_lx / g_blk_xx);
    {
        long tot = 0;
        for (long v : g_lv_n) tot += v;
        if (tot) {
            std::printf("BLOCK STANDS, ball m from its own goal: back line / middle / top man, m from the same line\n");
            for (int kb = 0; kb < 7; ++kb)
                if (g_lv_n[kb])
                    std::printf("  ball %3d-%3d: %5.1f / %5.1f / %5.1f  (%.0f%%)\n", 15 * kb, 15 * kb + 15, g_lv_line[kb] / g_lv_n[kb],
                                g_lv_mid[kb] / g_lv_n[kb], g_lv_top[kb] / g_lv_n[kb], 100.0 * g_lv_n[kb] / tot);
            long wn = 0;
            for (long v : g_lw_n) wn += v;
            std::printf("BLOCK STANDS across, ball |y| 24+, by job (share, man y, target y toward the ball):");
            for (int w = 0; w < 128 && w < ai::kWhyCount; ++w)
                if (g_lw_n[w] * 100 >= wn)
                    std::printf(" %s %.0f%% %.1f %.1f;", ai::kWhyNames[w], 100.0 * g_lw_n[w] / wn, g_lw_y[w] / g_lw_n[w], g_lw_t[w] / g_lw_n[w]);
            std::printf("\n");
            if (g_rk_n) {
                std::printf("BLOCK STANDS across, ball |y| 24+, 10 defenders' y toward the ball, far to near:");
                for (int i = 0; i < 10; ++i) std::printf(" %.1f", g_rk[i] / g_rk_n);
                std::printf("; far-most attacker %.1f\n", g_rk_far / g_rk_n);
                if (g_ra_n) {
                    std::printf("BLOCK STANDS across, ball |y| 24+, 10 attackers' y toward the ball, far to near:");
                    for (int i = 0; i < 10; ++i) std::printf(" %.1f", g_ra[i] / g_ra_n);
                    std::printf("\n");
                }
            }
            long an = 0;
            for (long v : g_aw_n) an += v;
            std::printf("ATTACK far side (y < -10), ball |y| 24+, by job (share, man y, target y):");
            for (int w = 0; w < 128 && w < ai::kWhyCount; ++w)
                if (g_aw_n[w] * 50 >= an)
                    std::printf(" %s %.0f%% %.1f %.1f;", ai::kWhyNames[w], 100.0 * g_aw_n[w] / an, g_aw_y[w] / g_aw_n[w], g_aw_t[w] / g_aw_n[w]);
            std::printf("\n");
            std::printf("BLOCK STANDS across, by the ball's |y|:");
            for (int ky = 0; ky < 4; ++ky)
                if (g_ly_n[ky]) std::printf(" ball %.1f middle %.1f;", g_ly_ball[ky] / g_ly_n[ky], g_ly_mid[ky] / g_ly_n[ky]);
            std::printf("\n");
        }
    }
    std::printf("HOLD SPOT SLIDES without it by depth rank, 0 = deepest (m/s, share 4+):");
    for (int nb = 0; nb < 12; ++nb)
        if (g_hold_num_n[nb]) std::printf(" #%d %.1f %.0f%%", nb, g_hold_num[nb] / g_hold_num_n[nb], 100.0 * g_hold_num_fast[nb] / g_hold_num_n[nb]);
    std::printf("\n");
    if (spells)
        std::printf("Possession spells: %.0f a match, %.1f s long on average; a man holding shape is %.1f m from his spot in a spell's first 5 s, %.1f m after (%.0f%% of holding ticks are in the first 5 s)\n",
                    double(spells) / matches, spell_ticks / 30.0 / spells,
                    hold_n[0] ? hold_gap[0] / hold_n[0] : 0.0, hold_n[1] ? hold_gap[1] / hold_n[1] : 0.0,
                    100.0 * hold_n[0] / std::max(1L, hold_n[0] + hold_n[1]));
    for (int team = 0; team < 2; ++team) {
        const char* tn = team == 0 ? names.team_home.c_str() : names.team_away.c_str();
        for (int w = 0; w < 2; ++w)
            if (crowd_ticks[team][w])
                std::printf("%s %s: %.2f outfielders within 10 m of the ball, outfield %.1f m wide x %.1f m long\n", tn,
                            w == 0 ? "with the ball" : "without it", crowd_sum[team][w] / crowd_ticks[team][w],
                            wide_sum[team][w] / crowd_ticks[team][w], long_sum[team][w] / crowd_ticks[team][w]);
        for (int w = 0; w < 2; ++w) {
            if (!off_n[team][w]) continue;
            std::printf("%s %s: %.1f m from his position on average, > 10 m off it %.0f%% of the time:", tn,
                        w == 0 ? "with the ball" : "without it", off_sum[team][w] / off_n[team][w],
                        100.0 * off_ticks[team][w] / off_n[team][w]);
            for (int k = 0; k < ai::kWhyCount; ++k)
                if (off_why[team][w][k] * 20 >= off_ticks[team][w] && off_ticks[team][w])
                    std::printf(" %s %.0f%%", ai::kWhyNames[k], 100.0 * off_why[team][w][k] / off_ticks[team][w]);
            std::printf("\n");
        }
        if (fb_n[team] && back_n[team])
            std::printf("%s rest defence: full-backs wider than their man %.0f%% of the time (3 m+ wider %.0f%%); back five goal-side of him with the ball past him %.0f%%\n",
                        tn, 100.0 * fb_wide[team] / fb_n[team], 100.0 * fb_wide3[team] / fb_n[team], 100.0 * back_goal_side[team] / back_n[team]);
        {
            long all = 0;
            for (int u = 0; u < 8; ++u) all += up_ticks[team][u];
            if (all) {
                std::printf("%s rest defence by men they leave up (ball in their half):", tn);
                for (int u = 0; u < 8; ++u)
                    if (up_ticks[team][u] * 50 >= all)
                        std::printf(" [%d up %.0f%%: %.1f behind, %.1f marking, no spare %.0f%%]", u,
                                    100.0 * up_ticks[team][u] / all, double(up_behind[team][u]) / up_ticks[team][u],
                                    double(up_marks[team][u]) / up_ticks[team][u], 100.0 * up_short[team][u] / up_ticks[team][u]);
                std::printf("\n");
                std::printf("%s mates ahead of the ball, by zone:", tn);
                for (int z = 0; z < 3; ++z)
                    if (zn_ticks[team][z])
                        std::printf(" %.2f (%.0f%%)", double(zn_ahead[team][z]) / zn_ticks[team][z], 100.0 * zn_ticks[team][z] / all);
                for (int z = 0; z < 3; ++z) {
                    if (!zn_ticks[team][z]) continue;
                    std::printf("\n  %s zone %d, metres ahead of the ball (their last man %+.1f), at / wants:", tn, z, zn_line[team][z] / zn_ticks[team][z]);
                    for (int k = 2; k < 12; ++k)
                        if (zn_xn[team][z][k]) std::printf(" %d:%+.0f/%+.0f", k, zn_x[team][z][k] / zn_xn[team][z][k], zn_tx[team][z][k] / zn_xn[team][z][k]);
                }
                std::printf("\n");
                for (int z = 0; z < 3; ++z) {
                    std::printf("  %s zone %d, mates ahead by spell age <5 / 5-15 / 15-30 / 30+ s:", tn, z);
                    for (int g = 0; g < 4; ++g)
                        if (age_ticks[team][z][g]) std::printf(" %.2f (%.0f%%)", double(age_ahead[team][z][g]) / age_ticks[team][z][g], 100.0 * age_ticks[team][z][g] / zn_ticks[team][z]);
                    std::printf("\n");
                }
                std::printf("; by number, ahead of it:");
                for (int k = 2; k < 12; ++k)
                    if (num_n[team][k]) std::printf(" %d:%.0f%%", k, 100.0 * num_ahead[team][k] / num_n[team][k]);
                std::printf("\n");
            }
        }
        if (fb_wide[team]) {
            std::printf("%s full-backs wider than their man are doing:", tn);
            for (int k = 0; k < ai::kWhyCount; ++k)
                if (fb_wide_why[team][k] * 50 >= fb_wide[team])
                    std::printf(" %s %.0f%%", ai::kWhyNames[k], 100.0 * fb_wide_why[team][k] / fb_wide[team]);
            std::printf("\n");
        }
        if (ip_n[team]) {
            std::printf("%s outfielders off the ball in possession are doing:", tn);
            for (int k = 0; k < ai::kWhyCount; ++k)
                if (ip_why[team][k] * 1000 >= ip_n[team])
                    std::printf(" %s %.1f%%", ai::kWhyNames[k], 100.0 * ip_why[team][k] / ip_n[team]);
            std::printf("\n");
        }
        std::printf("%s ran past his own target %.0f player-seconds a match:", tn, overrun[team] / 30.0 / matches);
        for (int w = 0; w < ai::kWhyCount; ++w)
            if (overrun_why[team][w] * 20 >= overrun[team] && overrun[team])
                std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * overrun_why[team][w] / overrun[team]);
        std::printf("\n");
    }
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
        if (!shot_n[team]) continue;
        const char* tn = team == 0 ? names.team_home.c_str() : names.team_away.c_str();
        auto pc = [&](const long* h, int i) { return 100.0 * h[i] / shot_n[team]; };
        std::printf("\n%s shots %.1f/match — spell age <5 s %.0f%% · 5-10 %.0f%% · 10-20 %.0f%% · 20+ %.0f%%\n", tn,
                    double(shot_n[team]) / matches, pc(shot_age[team], 0), pc(shot_age[team], 1), pc(shot_age[team], 2), pc(shot_age[team], 3));
        std::printf("  defenders goal-side of the shooter 0-2 %.0f%% · 3-4 %.0f%% · 5-6 %.0f%% · 7+ %.0f%%\n",
                    pc(shot_behind[team], 0), pc(shot_behind[team], 1), pc(shot_behind[team], 2), pc(shot_behind[team], 3));
        std::printf("  distance <11 m %.0f%% · 11-18 %.0f%% · 18-25 %.0f%% · 25+ %.0f%%; nearest defender <1.5 m %.0f%% · 1.5-3 %.0f%% · 3-6 %.0f%% · 6+ %.0f%%\n",
                    pc(shot_dist[team], 0), pc(shot_dist[team], 1), pc(shot_dist[team], 2), pc(shot_dist[team], 3),
                    pc(shot_near[team], 0), pc(shot_near[team], 1), pc(shot_near[team], 2), pc(shot_near[team], 3));
        std::printf("  defenders goal-side when the shooter GOT it 0-2 %.0f%% · 3-4 %.0f%% · 5-6 %.0f%% · 7+ %.0f%%; he carried <3 m %.0f%% · 3-10 %.0f%% · 10-25 %.0f%% · 25+ %.0f%%\n",
                    pc(recv_behind[team], 0), pc(recv_behind[team], 1), pc(recv_behind[team], 2), pc(recv_behind[team], 3),
                    pc(carry_m[team], 0), pc(carry_m[team], 1), pc(carry_m[team], 2), pc(carry_m[team], 3));
        std::printf("  the spell began <35 m from the goal it attacks %.0f%% · 35-52 %.0f%% · 52-70 %.0f%% · 70+ %.0f%%\n",
                    pc(won_at[team], 0), pc(won_at[team], 1), pc(won_at[team], 2), pc(won_at[team], 3));
        std::printf("  passes to a picked man by his nearest opponent at the kick — played/match, to him, lost:");
        { const char* bn[4] = {"<2 m", "2-5 m", "5-10 m", "10+ m"};
          for (int i = 0; i < 4; ++i) if (fr_n[team][i])
              std::printf(" | %s %.0f, %.0f%%, %.0f%%", bn[i], double(fr_n[team][i]) / matches, 100.0 * fr_got[team][i] / fr_n[team][i], 100.0 * fr_lost[team][i] / fr_n[team][i]); }
        std::printf("\n");
        if (own3_n[team]) {
            std::printf("  loses it within 35 m of its OWN goal %.1f/match (held <1 s %.0f%% · 1-3 %.0f%% · 3-8 %.0f%% · 8+ %.0f%%), kicks travel %.1f m before they take it:",
                        double(own3_n[team]) / matches, 100.0 * own3_age[team][0] / own3_n[team], 100.0 * own3_age[team][1] / own3_n[team],
                        100.0 * own3_age[team][2] / own3_n[team], 100.0 * own3_age[team][3] / own3_n[team],
                        own3_kicks[team] ? own3_kick_m[team] / own3_kicks[team] : 0.0);
            for (int w = 0; w <= ai::kWhyCount; ++w)
                if (own3_lost[team][w] * 25 >= own3_n[team])
                    std::printf(" %s %.0f%%", w == ai::kWhyCount ? "(on the ball: dispossessed)" : ai::kWhyNames[w], 100.0 * own3_lost[team][w] / own3_n[team]);
            std::printf("\n");
            if (own3_rn[team]) {
                std::printf("    the man it was for: %.1f m from where they took it (%.1f m from the passer); 0.3 s after the kick he was doing:", own3_rgap[team] / own3_rn[team], own3_igap[team] / own3_rn[team]);
                for (int w = 0; w < ai::kWhyCount; ++w)
                    if (own3_rwhy[team][w] * 20 >= own3_rn[team])
                        std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * own3_rwhy[team][w] / own3_rn[team]);
                std::printf("\n      our first man to it (flight read, +0.3 s): the receiver %.0f%% · nobody %.0f%% · the passer %.0f%% · another mate %.0f%% · (not live) %.0f%%\n",
                    100.0 * own3_first[team][0] / own3_rn[team], 100.0 * own3_first[team][1] / own3_rn[team], 100.0 * own3_first[team][2] / own3_rn[team],
                    100.0 * own3_first[team][3] / own3_rn[team], 100.0 * own3_first[team][4] / own3_rn[team]);
            }
        }
        if (rest_n[team]) {
            std::printf("  when it LOSES the ball, outfielders goal-side of it:");
            for (int i = 0; i <= 10; ++i) std::printf(" %d:%.0f%%", i, 100.0 * rest_hist[team][i] / rest_n[team]);
            std::printf("\n");
        }
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
    // G4.81b: the pro reference (mig 782 — game_benchmarks, level 'pro') beside
    // the same measures here. Semi-pro sits on the worse side of pro.
    const auto bench = persistence::loadBenchmarks(db, "pro");
    if (!bench.empty()) {
        std::map<std::string, std::pair<double, double>> sim;   // per team (home, away); NaN = no line here
        const double nm = matches, nan = std::nan("");
        const bool dump_sim = std::getenv("GAME_DUMP_SIM") != nullptr;   // one line per measure, for scripts
        auto both = [&](const std::string& k, double h, double a) { sim[k] = {h, a}; if (dump_sim) std::printf("SIM %s %.3f %.3f\n", k.c_str(), h, a); };
        auto one = [&](const std::string& k, double v) { sim[k] = {v, nan}; if (dump_sim) std::printf("SIM %s %.3f %.3f\n", k.c_str(), v, v); };
        double pk[2] = {0, 0}, pm[2] = {0, 0};
        for (int team = 0; team < 2; ++team)
            for (int w = 0; w <= ai::kWhyCount; ++w) {
                if (w == static_cast<int>(ai::Why::Shoot) || w == static_cast<int>(ai::Why::Clear) ||
                    w == static_cast<int>(ai::Why::KeeperPunt)) continue;
                pk[team] += tally[team][w].kicks; pm[team] += tally[team][w].mate;
            }
        both("shots_per_team_match", (shot_n[0] + air_goal[0]) / nm, (shot_n[1] + air_goal[1]) / nm);   // a header at goal is a shot (G5.3)
        both("behind_line_passes_per_team_match", bl_n[0] / nm, bl_n[1] / nm);   // G4.98
        both("behind_line_completion_pct", 100.0 * bl_mate[0] / std::max(1L, bl_n[0]), 100.0 * bl_mate[1] / std::max(1L, bl_n[1]));
        if (const long bt = bl_n[0] + bl_n[1]) {
            one("behind_line_lofted_pct", 100.0 * bl_loft / bt);
            one("behind_line_own_half_pct", 100.0 * bl_own / bt);
            one("behind_line_pressed_pct", 100.0 * bl_pressed / bt);
            const char* dk[4] = {"behind_line_depth_lt2m_pct", "behind_line_depth_2_5m_pct", "behind_line_depth_5_10m_pct", "behind_line_depth_10m_plus_pct"};
            for (int q = 0; q < 4; ++q) one(dk[q], 100.0 * bl_depth[q] / bt);
        }
        both("offsides_per_team_match", off_called[0] / nm, off_called[1] / nm);   // G4.88
        {   // G5.5 (§8.103): how it went out, per team-match
            const char* rk[3] = {"throw", "goal_kick", "corner"};
            const char* ck[8] = {"pass_ground", "pass_air", "clearance", "shot", "keeper_kick", "keeper_touch", "touch", "carried"};
            for (int q = 0; q < 3; ++q) {
                for (int c = 0; c < 8; ++c) one(std::string("out_") + rk[q] + "_" + ck[c], oc_n[q][c] / (2.0 * nm));
                if (q == 0) {
                const char* zxn[3] = {"box", "own3", "mid+"}; const char* zyn[3] = {"centre", "mid", "wide"};
                const char* rz[4] = {"box", "own3", "mid", "fin3"};
                std::printf("RELEASES BY ZONE (a team, clearance share):");
                for (int a = 0; a < 4; ++a)
                    if (rel_n[a]) std::printf(" %s %.1f %.1f%%;", rz[a], rel_n[a] / (2.0 * nm), 100.0 * rel_clear[a] / rel_n[a]);
                std::printf("\n");
                {
                    const char* dn[4] = {"0-6", "6-18", "18-30", "30+"}; const char* wn[3] = {"wide", "half", "centre"};
                    std::printf("RELEASES BY CROSS ZONE (m off their line, a team, cross share):");
                    for (int a = 0; a < 4; ++a)
                        for (int c = 0; c < 3; ++c)
                            if (xz_n[a][c]) std::printf(" %s %s %.1f %.0f%%;", dn[a], wn[c], xz_n[a][c] / (2.0 * nm), 100.0 * xz_cross[a][c] / xz_n[a][c]);
                    std::printf("\n");
                }
                std::printf("CLEARANCES BY ZONE (a team, throw %%, corner %%):");
                for (int a = 0; a < 3; ++a)
                    for (int c = 0; c < 3; ++c)
                        if (oc_cz_n[a][c])
                            std::printf(" %s %s %.1f %.0f%% %.0f%%;", zxn[a], zyn[c], oc_cz_n[a][c] / (2.0 * nm),
                                        100.0 * oc_cz_throw[a][c] / oc_cz_n[a][c], 100.0 * oc_cz_corner[a][c] / oc_cz_n[a][c]);
                std::printf("\n");
            }
            if (q == 0) std::printf("BODY BLOCKS a team: %.1f\n", (g_blocks[0] + g_blocks[1]) / (2.0 * nm));
            if (q == 0)
                for (int kk = 0; kk < 2; ++kk)
                    if (g_bp_n[kk])
                        std::printf("BOX PRESENCE, ball %s m off their line |y| 14+: attackers in the box %.2f, in 3-13 m x |y|<10 %.2f (none %.0f%%), defenders in the box %.2f; deepest defender %.1f m, next %.1f m off the line\n",
                                    kk ? "18-30" : "0-18", g_bp_box[kk] / g_bp_n[kk], g_bp_tgt[kk] / g_bp_n[kk], 100.0 * g_bp_tgt0[kk] / g_bp_n[kk], g_bp_dbox[kk] / g_bp_n[kk],
                                    g_bp_l1[kk] / g_bp_n[kk], g_bp_l2[kk] / g_bp_n[kk]);
            if (q == 0) {
                long tn = 0; for (long v : g_bpw) tn += v;
                std::printf("BOX PRESENCE jobs of the 3 most advanced, ball wide 0-18:");
                for (int w = 0; w < 128 && w < ai::kWhyCount; ++w) if (g_bpw[w] * 50 >= tn) std::printf(" %s %.0f%%;", ai::kWhyNames[w], 100.0 * g_bpw[w] / std::max(1L, tn));
                std::printf("\n");
            }
            if (q == 0) {
                long tn = 0; for (long v : g_dw_n) tn += v;
                std::printf("BOX DIAG ball wide 18-30: four deepest defenders by job (share, at m, target m off the line):");
                for (int w = 0; w < 128 && w < ai::kWhyCount; ++w)
                    if (g_dw_n[w] * 50 >= tn && tn) std::printf(" %s %.0f%% %.1f %.1f;", ai::kWhyNames[w], 100.0 * g_dw_n[w] / tn, g_dw_tl[w] / g_dw_n[w], g_dw_ttl[w] / g_dw_n[w]);
                std::printf("\n");
            }
            if (q == 0 && g_ab_n && g_dl_n)
                std::printf("BOX DIAG ball wide 0-18: attack-the-box men %.2f a frame, %.1f m from target, %.1f m/s, at %.1f m off the line, target %.1f; four deepest defenders %.1f m from target, %.1f m/s, at %.1f m, target %.1f\n",
                            double(g_ab_n) / std::max(1L, g_bp_n[0]), g_ab_gap / g_ab_n, g_ab_v / g_ab_n, g_ab_tl / g_ab_n, g_ab_ttl / g_ab_n,
                            g_dl_gap / g_dl_n, g_dl_v / g_dl_n, g_dl_tl / g_dl_n, g_dl_ttl / g_dl_n);
            if (q == 0)
                for (int h = 1; h >= 0; --h)
                    if (g_cf_n[h])
                        std::printf("CROSS FIRST TOUCH %s (%.1f a team): ours foot %.0f%%, ours head %.0f%%, theirs foot %.0f%%, theirs head %.0f%%, keeper %.0f%%, out %.0f%%\n",
                                    h ? "high" : "low", g_cf_n[h] / (2.0 * nm), 100.0 * g_cf[h][0] / g_cf_n[h], 100.0 * g_cf[h][1] / g_cf_n[h], 100.0 * g_cf[h][2] / g_cf_n[h],
                                    100.0 * g_cf[h][3] / g_cf_n[h], 100.0 * g_cf[h][4] / g_cf_n[h], 100.0 * g_cf[h][5] / g_cf_n[h]);
            if (q == 0)
                for (int h = 1; h >= 0; --h)
                    for (int c = 0; c < 6; ++c)
                        if (g_cf[h][c])
                            std::printf("  CF DIAG %s cat %d: nearest opp under 1.5 m high <0.5 %ld, 0.5-1 %ld, 1-1.5 %ld, 1.5-2.5 %ld, 2.5-5 %ld, 5+ %ld\n", h ? "high" : "low", c,
                                        g_cf_md[h][c][0], g_cf_md[h][c][1], g_cf_md[h][c][2], g_cf_md[h][c][3], g_cf_md[h][c][4], g_cf_md[h][c][5]);
            if (q == 0 && g_dr_n) {
                std::printf("  DROP DIAG nearest defender's job:");
                for (int w = 0; w < 128; ++w) if (g_dr_why[w] * 25 >= g_dr_n) std::printf(" %s %.0f%%;", ai::kWhyNames[w], 100.0 * g_dr_why[w] / g_dr_n);
                std::printf("\n  DROP DIAG a defender going for the ball: <1 %.0f%% 1-2 %.0f%% 2-4 %.0f%% 4+ %.0f%% nobody %.0f%%\n", 100.0 * g_dr_go[0] / g_dr_n, 100.0 * g_dr_go[1] / g_dr_n,
                            100.0 * g_dr_go[2] / g_dr_n, 100.0 * g_dr_go[3] / g_dr_n, 100.0 * g_dr_go[4] / g_dr_n);
                {
                    const long gn = std::max(1L, g_dr_tg[0] + g_dr_tg[1] + g_dr_tg[2] + g_dr_tg[3]);
                    std::printf("  DROP DIAG his target from the ball: <1 %.0f%% 1-2 %.0f%% 2-4 %.0f%% 4+ %.0f%%; his speed <2 %.0f%% 2-5 %.0f%% 5+ %.0f%%\n", 100.0 * g_dr_tg[0] / gn, 100.0 * g_dr_tg[1] / gn,
                                100.0 * g_dr_tg[2] / gn, 100.0 * g_dr_tg[3] / gn, 100.0 * g_dr_sp[0] / gn, 100.0 * g_dr_sp[1] / gn, 100.0 * g_dr_sp[2] / gn);
                }
                if (g_cx_n) {
                    std::printf("HIGH CROSS FIRST DROP THROUGH 2.4 M IN THE BOX (%.1f a team):", g_cx_n / (2.0 * nm));
                    for (int r = 0; r < 2; ++r) {
                        auto v = g_cx_d[r]; std::sort(v.begin(), v.end());
                        std::printf(" %s median %.1f m <1 %.0f%% 1-2 %.0f%% 2-4 %.0f%% 4+ %.0f%%%s", r ? "attacker" : "defender", v[v.size() / 2],
                                    100.0 * g_cx_bin[r][0] / g_cx_n, 100.0 * g_cx_bin[r][1] / g_cx_n, 100.0 * g_cx_bin[r][2] / g_cx_n, 100.0 * g_cx_bin[r][3] / g_cx_n, r ? "\n" : ";");
                    }
                }
                std::printf("DROP THROUGH 2.4 M IN A BOX (%.1f a team):", g_dr_n / (2.0 * nm));
                for (int r = 0; r < 2; ++r) {
                    auto v = g_dr_d[r]; std::sort(v.begin(), v.end());
                    std::printf(" %s median %.1f m <1 %.0f%% 1-2 %.0f%% 2-4 %.0f%% 4+ %.0f%%%s", r ? "attacker" : "defender", v[v.size() / 2],
                                100.0 * g_dr_bin[r][0] / g_dr_n, 100.0 * g_dr_bin[r][1] / g_dr_n, 100.0 * g_dr_bin[r][2] / g_dr_n, 100.0 * g_dr_bin[r][3] / g_dr_n, r ? "\n" : ";");
                }
            }
            if (q == 0) {
                long tot = 0;
                for (int z = 0; z < 4; ++z) tot += g_zn[z][0] + g_zn[z][1];
                std::printf("POSSESSION BY ZONE (%.0f s a team-match, 5 Hz spells):", tot / 5.0 / (2.0 * nm));
                static const char* zn[4] = {"0-18", "18-35", "35-70", "70+"};
                for (int z = 0; z < 4; ++z) std::printf(" %s centre %.0f s wide %.0f s;", zn[z], g_zn[z][0] / 5.0 / (2.0 * nm), g_zn[z][1] / 5.0 / (2.0 * nm));
                std::printf("\n");
                tot = 0;
                for (int z = 0; z < 4; ++z) tot += g_zl[z][0] + g_zl[z][1];
                std::printf("POSSESSION BY ZONE, last touch in play (%.0f s a team-match):", tot / 5.0 / (2.0 * nm));
                for (int z = 0; z < 4; ++z) std::printf(" %s centre %.0f s wide %.0f s;", zn[z], g_zl[z][0] / 5.0 / (2.0 * nm), g_zl[z][1] / 5.0 / (2.0 * nm));
                std::printf("\n");
            }
            if (q == 0 && g_bp_n[0]) {
                static const char* rn[8] = {"CB", "FB-ball", "FB-far", "DM/CM", "AM", "WIDE-ball", "WIDE-far", "ST"};
                for (int sd = 0; sd < 2; ++sd) {
                    double tot = 0;
                    for (int r = 0; r < 8; ++r) tot += g_br_box[sd][r];
                    std::printf("BOX BY ROLE %s (ball wide 0-18, %.0f s a team-match, %.2f in the box):\n", sd ? "defending" : "attacking", g_bp_n[0] / 5.0 / (2.0 * nm), tot / g_bp_n[0]);
                    for (int r = 0; r < 8; ++r) {
                        if (!g_br_n[sd][r]) continue;
                        std::printf("   %-9s in the box %3.0f%%, %.2f a frame; out of it:", rn[r], 100.0 * g_br_box[sd][r] / g_br_n[sd][r], double(g_br_box[sd][r]) / g_bp_n[0]);
                        const long out = g_br_n[sd][r] - g_br_box[sd][r];
                        if (out) std::printf(" target in the box %.0f%% (%.1f m off it);", 100.0 * g_br_tin[sd][r] / out, g_br_tin[sd][r] ? g_br_late[sd][r] / g_br_tin[sd][r] : 0.0);
                        for (int w = 0; w < 128; ++w) if (out && g_br_why[sd][r][w] * 10 >= out) std::printf(" %s %.0f%%;", ai::kWhyNames[w], 100.0 * g_br_why[sd][r][w] / out);
                        std::printf("\n");
                    }
                }
            }
            if (q == 0 && g_ps_N > 0) {
                static const char* rp[6] = {"CB", "FB", "DM/CM", "AM", "WIDE", "ST"};
                {   const double tm = 2.0 * nm;
                    std::printf("CONCEPT ACTS a team-match (StatsBomb cuts; real PL 15/16 in brackets): pressures %.1f (151.8), counter-press %.1f = %.1f%% (21.0%%); passes %.1f (433.8): switches %.2f (10.69), crosses %.2f (11.47), cut-backs %.2f (1.03); take-ons %.2f tried (18.05), %.2f completed (10.59); return passes %.2f (42.11) = %.1f%% of passes after a receipt (15.7%%); carries 10 m+ %.2f (34.64)\n",
                                g_ca_press / tm, g_ca_cpress / tm, 100.0 * g_ca_cpress / std::max(1L, g_ca_press), g_ca_pass / tm, g_ca_switch / tm, g_ca_cross / tm, g_ca_cutback / tm,
                                g_ca_drib / tm, g_ca_dribok / tm, g_ca_ret / tm, 100.0 * g_ca_ret / std::max(1L, g_ca_rtp), g_ca_carry10 / tm);
                }
                std::printf("DEFENDING SHAPE (the side without it; metres from its own line, ball band = ball m from that line):\n   band    frames  middle      CB      FB   DM/CM      AM    WIDE      ST\n");
                for (int k = 0; k < 10; ++k) if (const long f = g_dsh_f[k]) {
                    std::printf("   %2d-%-3d %7ld  %5.1f  ", 10 * k, 10 * k + 10, f, g_dsh_m[k] / f);
                    for (int r = 0; r < 6; ++r) std::printf("  %6.1f", g_dsh_s[k][r] / std::max(1L, g_dsh_n[k][r]));
                    std::printf("   shape anchor");
                    for (int r = 0; r < 6; ++r) std::printf(" %5.1f", g_dsh_an[k][r] / std::max(1L, g_dsh_n[k][r]));
                    std::printf("   after the block rules");
                    for (int r = 0; r < 6; ++r) std::printf(" %5.1f", g_dsh_da[k][r] / std::max(1L, g_dsh_n[k][r]));
                    std::printf("   holding: target/stands/back m/s");
                    for (int r = 0; r < 6; ++r) { const long hn = std::max(1L, g_dsh_hn[k][r]); std::printf(" %.1f/%.1f/%+.1f", g_dsh_ht[k][r] / hn, g_dsh_hp[k][r] / hn, g_dsh_hv[k][r] / hn); }
                    std::printf("   order target");
                    for (int r = 0; r < 6; ++r) std::printf(" %5.1f", g_dsh_ot[k][r] / std::max(1L, g_dsh_n[k][r]));
                    std::printf("\n");
                }
                {   static const char* rq[6] = {"CB", "FB", "DM/CM", "AM", "WIDE", "ST"};
                    std::printf("   their jobs, ball 40-70:");
                    for (int r = 0; r < 6; ++r) { if (!g_dsh_wn[r]) continue; std::printf(" %s:", rq[r]);
                        for (int w = 0; w < ai::kWhyCount; ++w) if (g_dsh_why[r][w] * 10 >= g_dsh_wn[r]) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * g_dsh_why[r][w] / g_dsh_wn[r]);
                        std::printf(";"); }
                    std::printf("\n");
                }
                std::printf("POSSESSION SHAPE (last touch, in play; metres from THEIR line by the ball's band):\n   band    frames  back/middle/front  ");
                for (int r = 0; r < 6; ++r) std::printf("  %6s", rp[r]);
                std::printf("\n");
                for (int k = 0; k < 10; ++k) {
                    if (!g_ps_f[k]) continue;
                    const double f = g_ps_f[k];
                    std::printf("   %2d-%-3d %7ld  %5.1f/%5.1f/%5.1f   ", 10 * k, 10 * k + 10, g_ps_f[k], g_ps_back[k] / f, g_ps_mid[k] / f, g_ps_front[k] / f);
                    for (int r = 0; r < 6; ++r) { if (g_ps_n[k][r]) std::printf("  %6.1f", g_ps_s[k][r] / g_ps_n[k][r]); else std::printf("       -"); }
                    std::printf("\n");
                }
                const double N = g_ps_N, sl = (g_ps_BM - g_ps_B * g_ps_M / N) / (g_ps_BB - g_ps_B * g_ps_B / N), off = g_ps_M / N - sl * g_ps_B / N;
                std::printf("   by possession age: frames / ball m from OUR goal / middle m from THEIR line / middle's forward speed / men 5+ m/s / 5+ forward\n");
                for (int i = 0; i < 7; ++i) if (g_ag_n[i]) {
                    const double m = g_ag_n[i];
                    std::printf("     %d%s s %7ld  ball %5.1f  middle %5.1f  fwd %+.2f m/s  5+ %4.1f%%  5+ fwd %4.1f%%\n", i, i == 6 ? "+" : (std::string("-") + std::to_string(i + 1)).c_str(), g_ag_n[i],
                                g_ag_b[i] / m, g_ag_m[i] / m, g_ag_v[i] / m, 100 * g_ag_5[i] / m, 100 * g_ag_5f[i] / m);
                    if (const long f = g_fa_n[i]) std::printf("            front men (AM/WIDE/ST): ahead of the middle %+5.1f m  fwd %+.2f m/s  5+ %4.1f%%  5+ fwd %4.1f%%; holding %.0f%%, spot %+.1f m ahead, fwd %+.2f m/s\n",
                                g_fa_a[i] / f, g_fa_v[i] / f, 100 * g_fa_5[i] / f, 100 * g_fa_5f[i] / f, 100.0 * g_fa_hn[i] / f, g_fa_h[i] / std::max(1L, g_fa_hn[i]), g_fa_hv[i] / std::max(1L, g_fa_hn[i]));
                }
                {
                    long hn = 0; for (long v : g_hl_n) hn += v;
                    std::printf("   holding shape in possession, by distance off the spot (share / mean m / speed / toward it / move wish):");
                    static const char* hb[4] = {"<2", "2-5", "5-10", "10+"};
                    for (int i = 0; i < 4; ++i) if (g_hl_n[i]) std::printf(" %s m %.0f%% %.1f %.2f %.2f %.2f;", hb[i], 100.0 * g_hl_n[i] / hn, g_hl_d[i] / g_hl_n[i], g_hl_v[i] / g_hl_n[i], g_hl_vt[i] / g_hl_n[i], g_hl_want[i] / g_hl_n[i]);
                    std::printf("\n   holding shape in possession, spot off him by role (mean m / ahead of him / across):");
                    static const char* rq[7] = {"CB", "FB", "DM/CM", "AM", "WIDE", "ST", "?"};
                    for (int i = 0; i < 7; ++i) if (g_hf_n[i]) std::printf(" %s %.1f / %+.1f / %.1f;", rq[i], g_hf_d[i] / g_hf_n[i], g_hf_fx[i] / g_hf_n[i], g_hf_ay[i] / g_hf_n[i]);
                    std::printf("\n");
                }
                std::printf("   middle on the ball, from our goal: slope %.2f, offset %.1f m\n   each role ahead of the middle, ball 25-75 m off their line:", sl, off);
                for (int r = 0; r < 6; ++r) if (g_ps_gn[r]) std::printf(" %s %+.1f;", rp[r], g_ps_g[r] / g_ps_gn[r]);
                std::printf("\n");
            }
            if (q == 0 && g_ch_n) {
                const double n = g_ch_n;
                static const char* rn7[7] = {"CB", "FB", "DM/CM", "AM", "WIDE", "ST", "?"};
                std::printf("BALL WIDE 18-35 (%.0f s a team-match): in the channel (0-18, |y| 14+, ball side) attackers %.2f, defenders %.2f; in the box attackers %.2f, defenders %.2f\n",
                            n / 5.0 / (2.0 * nm), g_ch_chan[0] / n, g_ch_chan[1] / n, g_ch_box[0] / n, g_ch_box[1] / n);
                double ta = 0, tr = 0;
                std::printf("   attackers ahead of it on its side (|y| 10+), a frame / running 4 m/s+ at the line:");
                for (int r = 0; r < 7; ++r) { ta += g_ch_ahead[r]; tr += g_ch_run[r]; if (g_ch_ahead[r]) std::printf(" %s %.2f/%.2f;", rn7[r], g_ch_ahead[r] / n, g_ch_run[r] / n); }
                std::printf(" all %.2f/%.2f\n   their jobs:", ta / n, tr / n);
                long wn = 0; for (long v : g_ch_why) wn += v;
                for (int w = 0; w < ai::kWhyCount; ++w) if (g_ch_why[w] * 25 >= wn && wn) std::printf(" %s %.0f%%;", ai::kWhyNames[w], 100.0 * g_ch_why[w] / wn);
                std::printf("\n");
                std::printf("   WHERE THEY STAND (a frame; metres ahead of the ball toward their line, metres across toward its touchline):\n");
                for (int sd = 0; sd < 2; ++sd) {
                    std::printf("     %s:", sd ? "defending" : "attacking");
                    for (int r = 0; r < 7; ++r) for (int f = 0; f < 2; ++f) {
                        const long m = g_wt_n[sd][r][f];
                        if (m) std::printf(" %s-%s %.2f @ %+.1f/%+.1f;", rn7[r], f ? "far" : "ball", m / n, g_wt_a[sd][r][f] / m, g_wt_y[sd][r][f] / m);
                    }
                    std::printf("\n");
                }
                for (int r = 0; r < 7; ++r) for (int f = 0; f < 2; ++f) {
                    const long m = g_wt_n[0][r][f];
                    if (!m) continue;
                    std::printf("     attacking %s-%s shape target (owned) %+.1f/%+.1f; order target %+.1f; holding shape: target %+.1f, stands %+.1f; jobs:", rn7[r], f ? "far" : "ball", g_wt_anc[r][f] / std::max(1L, g_wt_ancn[r][f]), g_wt_ancy[r][f] / std::max(1L, g_wt_ancn[r][f]),
                                g_wt_t[r][f] / std::max(1L, g_wt_tn[r][f]), g_wt_h[r][f] / std::max(1L, g_wt_hn[r][f]), g_wt_hp[r][f] / std::max(1L, g_wt_hn[r][f]));
                    for (int w = 0; w < ai::kWhyCount; ++w) if (g_wt_why[0][r][f][w] * 10 >= m) std::printf(" %s %.0f%%;", ai::kWhyNames[w], 100.0 * g_wt_why[0][r][f][w] / m);
                    std::printf("\n");
                }
                if (g_h3_bn) {
                    const double hn = g_h3_bn;
                    std::printf("   THREE SECONDS BEFORE: the ball came %.1f m toward their line (15 m+ %.0f%%); other side had it %.0f%%, came <5 m %.0f%%, 5-15 %.0f%%, 15+ %.0f%%\n     attacking, came / stood ahead of the ball then:",
                                g_h3_ball / hn, 100.0 * g_h3_b15 / hn, 100.0 * g_h3_age[0] / hn, 100.0 * g_h3_age[1] / hn, 100.0 * g_h3_age[2] / hn, 100.0 * g_h3_age[3] / hn);
                    for (int r = 0; r < 7; ++r) for (int f = 0; f < 2; ++f) if (g_h3_n[r][f]) std::printf(" %s-%s %+.1f / %+.1f;", rn7[r], f ? "far" : "ball", g_h3_adv[r][f] / g_h3_n[r][f], g_h3_was[r][f] / g_h3_n[r][f]);
                    std::printf("\n");
                }
                std::printf("   offside line %.1f m ahead of the ball\n", g_line_sum / n);
                std::printf("   nearest defender to the ball: mean %.1f m; <1 m %.0f%%; <2 m %.0f%%; <3 m %.0f%%; <5 m %.0f%%; <8 m %.0f%%\n", g_nd_sum / n,
                            100.0 * g_nd_lim[0] / n, 100.0 * g_nd_lim[1] / n, 100.0 * g_nd_lim[2] / n, 100.0 * g_nd_lim[3] / n, 100.0 * g_nd_lim[4] / n);
            }
            if (q == 0 && g_ws_n) {
                const double n = g_ws_n, tm = 2.0 * nm;
                static const char* zn6[6] = {"0-18 centre", "0-18 wide", "18-35 centre", "18-35 wide", "35+ centre", "35+ wide"};
                std::printf("WIDE 18-35 ON THE BALL: %.1f spells a team-match, %.2f s and %.1f m a spell; let go from:", n / tm, g_ws_ticks / 30.0 / n, g_ws_carry_m / n);
                for (int z = 0; z < 6; ++z) if (g_ws_from[z]) std::printf(" %s %.0f%%;", zn6[z], 100.0 * g_ws_from[z] / n);
                std::printf("\n   let go as: shot %.1f%%, cross %.1f%%, clearance %.1f%%, lost %.1f%%, stopped %.1f%%;", 100.0 * g_ws_end[0] / n, 100.0 * g_ws_end[1] / n,
                            100.0 * g_ws_end[2] / n, 100.0 * g_ws_end[4] / n, 100.0 * g_ws_end[5] / n);
                for (int z = 0; z < 6; ++z) if (g_ws_to[z]) std::printf(" pass to %s %.1f%% (%.2f a team);", zn6[z], 100.0 * g_ws_to[z] / n, g_ws_to[z] / tm);
                long wn = 0; for (long v : g_ws_why) wn += v;
                std::printf("\n   on it, his job:");
                for (int w = 0; w < ai::kWhyCount; ++w) if (g_ws_why[w] * 50 >= wn && wn) std::printf(" %s %.0f%%;", ai::kWhyNames[w], 100.0 * g_ws_why[w] / wn);
                long pn = 0; for (long v : g_ws_pwhy) pn += v;
                std::printf("\n   passes, why:");
                for (int w = 0; w < ai::kWhyCount; ++w) if (g_ws_pwhy[w] * 50 >= pn && pn) std::printf(" %s %.0f%%;", ai::kWhyNames[w], 100.0 * g_ws_pwhy[w] / pn);
                std::printf("\n");
            }
            if (q == 0) std::printf("INTO THE CROSSING ZONE a team: carried %.2f, passed %.2f (from wide %.2f)\n", g_xin_carry / (2.0 * nm), g_xin_pass / (2.0 * nm), g_xin_pass_wide / (2.0 * nm));
            std::printf("OUT BY %s:", rk[q]);
                for (int c = 0; c < 8; ++c) std::printf(" %s %.2f", ck[c], oc_n[q][c] / (2.0 * nm));
                std::printf("\n");
            }
            std::printf("GROUND PASS OUT, nearest the receiver got m: <0.5 %ld, 0.5-1 %ld, 1-2 %ld, 2-4 %ld, 4-8 %ld, 8+ %ld\n", oc_near_hist[0], oc_near_hist[1], oc_near_hist[2], oc_near_hist[3], oc_near_hist[4], oc_near_hist[5]);
            {
                const char* rn[5] = {"under 2 m/s", "2-5 m/s", "5+ toward the passer", "5+ across", "5+ away"};
                long tot = 0;
                for (int q = 0; q < 5; ++q) tot += oc_rx_n[q];
                for (int q = 0; q < 5; ++q)
                    std::printf("RECEIVER AT THE KICK %s: %.1f%% of ground passes, %.2f%% into touch\n", rn[q], 100.0 * oc_rx_n[q] / std::max(1L, tot), 100.0 * oc_rx_out[q] / std::max(1L, oc_rx_n[q]));
                std::printf("AIM: target %.2f m from the man at the kick; balls dead last kicked as clearance %ld\n", oc_rx_lead / std::max(1L, oc_rx_lead_n), oc_dead_cat[2]);
            }
            {
                const long st = std::max(1L, oc_sp_t[0] + oc_sp_t[1] + oc_sp_t[2]);
                std::printf("OFF THE BALL SPEED under 2 %.1f%%, 2-5 %.1f%%, 5+ %.1f%%; mean %.2f m/s = %.1f km in 96 min\n", 100.0 * oc_sp_t[0] / st, 100.0 * oc_sp_t[1] / st, 100.0 * oc_sp_t[2] / st,
                            oc_sp_v / st, oc_sp_v / st * 96 * 60 / 1000);
                std::vector<std::pair<long, int>> rw, sw;
                long rt = 0;
                for (int q = 0; q < ai::kWhyCount; ++q) { rt += oc_rx_why[q]; if (oc_rx_why[q]) rw.push_back({oc_rx_why[q], q}); if (oc_sp_why[q]) sw.push_back({oc_sp_why[q], q}); }
                std::sort(rw.rbegin(), rw.rend()); std::sort(sw.rbegin(), sw.rend());
                std::printf("RECEIVER 5+ WAS:");
                for (std::size_t q = 0; q < rw.size() && q < 9; ++q) std::printf(" %s %.0f%%,", ai::kWhyNames[rw[q].second], 100.0 * rw[q].first / std::max(1L, rt));
                std::printf("\nALL 5+ WERE:");
                for (std::size_t q = 0; q < sw.size() && q < 9; ++q) std::printf(" %s %.0f%%,", ai::kWhyNames[sw[q].second], 100.0 * sw[q].first / std::max(1L, oc_sp_t[2]));
                std::printf("\n5+ IN POSSESSION %.0f%%, OUT %.0f%%\n", 100.0 * oc_sp_side[0] / std::max(1L, oc_sp_side[0] + oc_sp_side[1]), 100.0 * oc_sp_side[1] / std::max(1L, oc_sp_side[0] + oc_sp_side[1]));
                for (std::size_t q = 0; q < sw.size() && q < 7; ++q) {
                    const long* g = oc_sp_gap[sw[q].second];
                    const long t = std::max(1L, g[0] + g[1] + g[2] + g[3]);
                    std::printf("GAP %s: under 3 m %.0f%%, 3-8 %.0f%%, 8-15 %.0f%%, 15+ %.0f%%\n", ai::kWhyNames[sw[q].second], 100.0 * g[0] / t, 100.0 * g[1] / t, 100.0 * g[2] / t, 100.0 * g[3] / t);
                }
            }
            std::printf("CLEARANCES %.1f a team, to a throw-in %.1f%%, to a corner %.1f%%\n", oc_clear_kicks / (2.0 * nm),
                        100.0 * oc_n[0][2] / std::max(1L, oc_clear_kicks), 100.0 * oc_n[2][2] / std::max(1L, oc_clear_kicks));
            one("clearances_per_team_match", oc_clear_kicks / (2.0 * nm));
            if (oc_clear_kicks) {
                one("clearance_to_throw_pct", 100.0 * oc_n[0][2] / oc_clear_kicks);
                one("clearance_to_corner_pct", 100.0 * oc_n[2][2] / oc_clear_kicks);
            }
        }
        // G5.2: the restarts.
        {
            const char* key[3] = {"throw_ins", "goal_kicks", "corners"};
            for (int q = 0; q < 3; ++q) {
                const std::string kk = key[q];
                const long tn = rs_n[q][0] + rs_n[q][1];
                both(kk + "_per_team_match", rs_n[q][0] / nm, rs_n[q][1] / nm);
                if (!rs_dead[q].empty()) one(kk + "_dead_median_s", median(rs_dead[q]));
                if (!rs_len[q].empty()) one(kk + "_length_median_m", median(rs_len[q]));
                if (tn) {
                    one(kk + "_completion_pct", 100.0 * rs_kept[q] / tn);
                    one(kk + "_shot_10s_pct", 100.0 * rs_shot[q] / tn);
                }
            }
        }
        if (tob_n) {   // G4.92: time on the ball (one number for both sides)
            one("time_on_ball_s", tob_s / tob_n);
            const char* tk[4] = {"time_on_ball_lt1s_pct", "time_on_ball_1_2s_pct", "time_on_ball_2_4s_pct", "time_on_ball_4s_plus_pct"};
            for (int q = 0; q < 4; ++q) one(tk[q], 100.0 * tob_b[q] / tob_n);
        }
        both("shots_open_play_per_team_match", (shot_n[0] + air_goal[0]) / nm, (shot_n[1] + air_goal[1]) / nm);
        one("goals_per_match", (gh + ga) / nm);
        one("goals_open_play_per_match", (gh + ga) / nm);
        both("open_play_passes_per_team_match", pk[0] / nm, pk[1] / nm);
        both("open_play_pass_completion_pct", 100 * pm[0] / std::max(1.0, pk[0]), 100 * pm[1] / std::max(1.0, pk[1]));
        one("spells_per_match", spells / nm);
        one("spell_length_s", spells ? spell_ticks / 30.0 / spells : nan);
        both("final_third_entries_per_team_match", entries[0] / nm, entries[1] / nm);
        both("own_third_losses_per_team_match", own3_n[0] / nm, own3_n[1] / nm);
        both("own_third_loss_shot_10s_pct", 100.0 * own3_shot10[0] / std::max(1L, own3_n[0]), 100.0 * own3_shot10[1] / std::max(1L, own3_n[1]));
        both("own_third_loss_shot_spell_pct", 100.0 * own3_shot_spell[0] / std::max(1L, own3_n[0]), 100.0 * own3_shot_spell[1] / std::max(1L, own3_n[1]));
        const char* sfx[4][4] = {{"lt5s", "5_10s", "10_20s", "20s_plus"}, {"0_2", "3_4", "5_6", "7_plus"},
                                 {"lt11m", "11_18m", "18_25m", "25m_plus"}, {"lt1_5m", "1_5_3m", "3_6m", "6m_plus"}};
        const char* pre[4] = {"op_shot_age_", "op_shot_goalside_", "op_shot_dist_", "op_shot_near_"};
        const long (*hist[4])[4] = {shot_age, shot_behind, shot_dist, shot_near};
        for (int h = 0; h < 4; ++h)
            for (int i = 0; i < 4; ++i)
                both(std::string(pre[h]) + sfx[h][i] + "_pct", 100.0 * hist[h][0][i] / std::max(1L, shot_n[0]),
                     100.0 * hist[h][1][i] / std::max(1L, shot_n[1]));
        both("interceptions_kept_per_team_match", cut[0] / nm, cut[1] / nm);
        both("bad_touches_per_team_match", bobbles[0] / nm, bobbles[1] / nm);
        const char* endc[5] = {"pass", "clear", "shot", "bad_touch", "on_ball"};
        for (int i = 0; i < 5; ++i)
            both(std::string("spell_end_") + endc[i] + "_pct", 100.0 * end_cause[0][i] / std::max(1L, ends[0]),
                 100.0 * end_cause[1][i] / std::max(1L, ends[1]));
        const char* began[4] = {"lt35m", "35_52m", "52_70m", "70m_plus"};
        for (int i = 0; i < 4; ++i)
            both(std::string("op_shot_began_") + began[i] + "_pct", 100.0 * won_at[0][i] / std::max(1L, shot_n[0]),
                 100.0 * won_at[1][i] / std::max(1L, shot_n[1]));
        std::printf("\nPasses the other side took — cut out while travelling (interceptions) %.1f / %.1f, picked up slower %.1f / %.1f; bad touches %.1f / %.1f a team a match\n",
                    cut[0] / nm, cut[1] / nm, picked[0] / nm, picked[1] / nm, bobbles[0] / nm, bobbles[1] / nm);
        {
            const char* kn[3] = {"the pass meant for him", "another of ours", "theirs (a reaction touch)"};
            std::printf("  bad touches a match by whose ball, at <9 / 9-12 / 12-15 / 15+ m/s:");
            for (int q = 0; q < 3; ++q)
                std::printf(" %s %.1f / %.1f / %.1f / %.1f%s", kn[q], bt_kind[q][0] / nm, bt_kind[q][1] / nm,
                            bt_kind[q][2] / nm, bt_kind[q][3] / nm, q < 2 ? " ·" : "\n");
        }
        {
            const long calls = off_called[0] + off_called[1];
            std::printf("\nOfficials (the assistant's call stands): offsides %.1f / %.1f a team a match; whistles for an onside man %.1f a match (%.0f%% of the calls), offside touches nobody flagged %.1f a match\n",
                        off_called[0] / nm, off_called[1] / nm, off_wrong / nm, 100.0 * off_wrong / std::max(1L, calls), off_missed / nm);
            if (flag_kicks)
                std::printf("  kicks with a flag or a man offside: %.1f a match — men flagged wrongly %.1f, offside men missed %.1f a match; the assistant stood (vs level with the line) 3+ m short %.0f%% · 1-3 short %.0f%% · within 1 m %.0f%% · 1-3 beyond %.0f%% · 3+ beyond %.0f%%, mean %+.1f m\n",
                            flag_kicks / nm, flag_wrong / nm, flag_missed / nm,
                            100.0 * ar_off[0] / flag_kicks, 100.0 * ar_off[1] / flag_kicks, 100.0 * ar_off[2] / flag_kicks,
                            100.0 * ar_off[3] / flag_kicks, 100.0 * ar_off[4] / flag_kicks, ar_off_sum / flag_kicks);
        }
        if (ib_all_read[0] + ib_all_read[1])
            std::printf("  balls in behind by the passer's read: READ %.1f a match, theirs at the kick %.0f%% · NOT read %.1f, theirs %.0f%%\n",
                        ib_all_read[1] / nm, 100.0 * ib_theirs_read[1] / std::max(1L, ib_all_read[1]),
                        ib_all_read[0] / nm, 100.0 * ib_theirs_read[0] / std::max(1L, ib_all_read[0]));
        for (int dv = 0; dv < 2; ++dv) {
            if (!n9_n[dv]) continue;
            std::printf("  home 9 while their centre-back has it %s (%.0f s a match): within 3 m of him %.0f%%; doing:",
                        dv ? "DRIVING forward" : "not driving", n9_n[dv] / 30.0 / nm, 100.0 * n9_near[dv] / n9_n[dv]);
            for (int w = 0; w < ai::kWhyCount; ++w)
                if (n9_job[dv][w] * 25 >= n9_n[dv]) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * n9_job[dv][w] / n9_n[dv]);
            std::printf("\n");
        }
        if (bl_n[0] + bl_n[1]) {
            const long bt = bl_n[0] + bl_n[1];
            std::printf("  passes aimed past their last outfielder, 3 m+ forward (%.1f / %.1f a team a match, to a mate %.0f / %.0f%%): lofted %.0f%% · from his own half %.0f%% · nearest opponent <2.5 m %.0f%% · past the line <2 / 2-5 / 5-10 / 10+ m %.0f / %.0f / %.0f / %.0f%%\n",
                        bl_n[0] / nm, bl_n[1] / nm, 100.0 * bl_mate[0] / std::max(1L, bl_n[0]), 100.0 * bl_mate[1] / std::max(1L, bl_n[1]),
                        100.0 * bl_loft / bt, 100.0 * bl_own / bt, 100.0 * bl_pressed / bt,
                        100.0 * bl_depth[0] / bt, 100.0 * bl_depth[1] / bt, 100.0 * bl_depth[2] / bt, 100.0 * bl_depth[3] / bt);
            for (int tm = 0; tm < 2; ++tm) {
                std::printf("    %s by kind, a match:", tm == 0 ? "home" : "away");
                for (int w = 0; w <= ai::kWhyCount; ++w)
                    if (bl_why[tm][w] * 25 >= bl_n[tm]) std::printf(" %s %.1f", w == ai::kWhyCount ? "in behind (ladder 1-2)" : ai::kWhyNames[w], bl_why[tm][w] / nm);
                std::printf("\n");
            }
        }
        if (pb_n) {
            std::printf("  balls in behind (%.1f a match), the passer at the kick: nearest opponent <2.5 / 2.5-5 / 5+ m %.0f / %.0f / %.0f%%; had it <0.5 / 0.5-1 / 1-2 / 2+ s %.0f / %.0f / %.0f / %.0f%%; from his own half / to 70 m / the final third %.0f / %.0f / %.0f%%; aimed past their last outfielder <2 / 2-5 / 5-10 / 10+ m %.0f / %.0f / %.0f / %.0f%%; ladder fire %.0f%% · lofted %.0f%%\n",
                        pb_n / nm, 100.0 * pb_near[0] / pb_n, 100.0 * pb_near[1] / pb_n, 100.0 * pb_near[2] / pb_n,
                        100.0 * pb_held[0] / pb_n, 100.0 * pb_held[1] / pb_n, 100.0 * pb_held[2] / pb_n, 100.0 * pb_held[3] / pb_n,
                        100.0 * pb_zone[0] / pb_n, 100.0 * pb_zone[1] / pb_n, 100.0 * pb_zone[2] / pb_n,
                        100.0 * pb_depth[0] / pb_n, 100.0 * pb_depth[1] / pb_n, 100.0 * pb_depth[2] / pb_n, 100.0 * pb_depth[3] / pb_n,
                        100.0 * pb_fire / pb_n, 100.0 * pb_loft / pb_n);
        }
        if (bh_n) {
            std::printf("  balls in behind (%.1f a match), at the kick: runner to his nearest defender <2 / 2-4 / 4-8 / 8+ m %.0f / %.0f / %.0f / %.0f%%; runner faster toward goal by <2 / 2-4 / 4-6 / 6+ m/s %.0f / %.0f / %.0f / %.0f%%; defender already turned %.0f%%\n    the defender was doing:",
                        bh_n / nm, 100.0 * bh_gap[0] / bh_n, 100.0 * bh_gap[1] / bh_n, 100.0 * bh_gap[2] / bh_n, 100.0 * bh_gap[3] / bh_n,
                        100.0 * bh_dv[0] / bh_n, 100.0 * bh_dv[1] / bh_n, 100.0 * bh_dv[2] / bh_n, 100.0 * bh_dv[3] / bh_n, 100.0 * bh_face_back / bh_n);
            for (int w = 0; w < ai::kWhyCount; ++w)
                if (bh_job[w] * 25 >= bh_n) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * bh_job[w] / bh_n);
            std::printf("\n");
        }
        if (dp_n) {
            std::printf("  dispossessed in his own third (%.1f a match): had it <0.5 / 0.5-1 / 1-3 / 3+ s %.0f / %.0f / %.0f / %.0f%%; still in his control touch %.0f%%\n    he was doing:",
                        dp_n / nm, 100.0 * dp_held[0] / dp_n, 100.0 * dp_held[1] / dp_n, 100.0 * dp_held[2] / dp_n, 100.0 * dp_held[3] / dp_n, 100.0 * dp_in_touch / dp_n);
            for (int w = 0; w < ai::kWhyCount; ++w)
                if (dp_carrier[w] * 25 >= dp_n) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * dp_carrier[w] / dp_n);
            std::printf("\n    the man who took it:");
            for (int w = 0; w < ai::kWhyCount; ++w)
                if (dp_taker[w] * 25 >= dp_n) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * dp_taker[w] / dp_n);
            std::printf("\n");
        }
        if (tob_n)
            std::printf("  time on the ball before a pass: %.2f s; <1 / 1-2 / 2-4 / 4+ s %.0f / %.0f / %.0f / %.0f%% (pro: the PRO REFERENCE table)\n",
                        tob_s / tob_n, 100.0 * tob_b[0] / tob_n, 100.0 * tob_b[1] / tob_n, 100.0 * tob_b[2] / tob_n, 100.0 * tob_b[3] / tob_n);
        if (tg_all) {
            const char* nm5[5] = {"3 m+ onside", "1-3 m onside", "within 1 m onside", "within 1 m offside", "1 m+ offside"};
            std::printf("  passes to a mate by his gap to the line at the kick (%.1f a match):", tg_all / nm);
            for (int q = 0; q < 5; ++q)
                std::printf(" %s %.1f (flagged %.0f%%)%s", nm5[q], tg_n[q] / nm, 100.0 * tg_flag[q] / std::max(1L, tg_n[q]), q < 4 ? " ·" : "\n");
        }
        if (op_men) {
            std::printf("  men standing offside at a kick: %.1f a match on %.0f%% of kicks; past the line <1 / 1-3 / 3-8 / 8+ m %.0f / %.0f / %.0f / %.0f%%; there for <1 / 1-3 / 3-8 / 8+ s %.0f / %.0f / %.0f / %.0f%%\n    doing:",
                        op_men / nm, 100.0 * op_kicks / std::max(1L, op_all_kicks),
                        100.0 * op_depth[0] / op_men, 100.0 * op_depth[1] / op_men, 100.0 * op_depth[2] / op_men, 100.0 * op_depth[3] / op_men,
                        100.0 * op_age[0] / op_men, 100.0 * op_age[1] / op_men, 100.0 * op_age[2] / op_men, 100.0 * op_age[3] / op_men);
            for (int w = 0; w < ai::kWhyCount; ++w)
                if (op_job[w] * 25 >= op_men) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * op_job[w] / op_men);
            std::printf("\n");
        }
        if (ow_n) {
            std::printf("  each offside whistle (%.1f a match): the man it was played to %.0f%%; past their second-last man at the kick: not (onside) %.0f%% · <1 m %.0f%% · 1-3 m %.0f%% · 3+ m %.0f%%\n    off the kick:",
                        ow_n / nm, 100.0 * ow_intended / ow_n, 100.0 * ow_depth[0] / ow_n, 100.0 * ow_depth[1] / ow_n, 100.0 * ow_depth[2] / ow_n, 100.0 * ow_depth[3] / ow_n);
            for (int w = 0; w <= ai::kWhyCount; ++w)
                if (ow_why[w] * 25 >= ow_n) std::printf(" %s %.0f%%", w == ai::kWhyCount ? "in behind" : ai::kWhyNames[w], 100.0 * ow_why[w] / ow_n);
            std::printf("\n    he was doing at the kick:");
            for (int w = 0; w < ai::kWhyCount; ++w)
                if (ow_job[w] * 25 >= ow_n) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * ow_job[w] / ow_n);
            std::printf("\n");
        }
        if (ib_loft_all[0] + ib_loft_all[1])
            std::printf("  read balls in behind: on the ground %.1f a match, theirs %.0f%% · lofted %.1f, theirs %.0f%%\n",
                        ib_loft_all[0] / nm, 100.0 * ib_loft_theirs[0] / std::max(1L, ib_loft_all[0]),
                        ib_loft_all[1] / nm, 100.0 * ib_loft_theirs[1] / std::max(1L, ib_loft_all[1]));
        if (ib_seen[0] + ib_seen[1]) {
            const double t = ib_seen[0] + ib_seen[1];
            std::printf("  read balls in behind theirs: their man IN the passer's view %.0f%% · behind him %.0f%%; passer's last look 0 / <0.5 / 0.5-1.5 / 1.5+ s ago %.0f / %.0f / %.0f / %.0f%%\n",
                        100 * ib_seen[1] / t, 100 * ib_seen[0] / t, 100 * ib_age[0] / t, 100 * ib_age[1] / t, 100 * ib_age[2] / t, 100 * ib_age[3] / t);
        }
        if (ib_n)
            std::printf("  balls in behind theirs at the kick: %.1f a match; strike off his aim <2 / 2-5 / 5-10 / 10+ deg %.0f / %.0f / %.0f / %.0f%%; their man meets it before the spot %.0f%% · at it (±3 m) %.0f%% · after it ran on %.0f%%\n",
                        ib_n / nm, 100.0 * ib_err[0] / ib_n, 100.0 * ib_err[1] / ib_n, 100.0 * ib_err[2] / ib_n, 100.0 * ib_err[3] / ib_n,
                        100.0 * ib_where[0] / ib_n, 100.0 * ib_where[1] / ib_n, 100.0 * ib_where[2] / ib_n);
        for (int q = 0; q < 2; ++q) {
            long tot = 0;
            for (int w = 0; w < ai::kWhyCount; ++w) tot += rt_n[q][w];
            if (!tot) continue;
            std::printf("  their moving ball %s: %.1f a match; his speed <2 / 2-4 / 4-6 / 6+ m/s %.0f / %.0f / %.0f / %.0f%%; ball speed relative to him <6 / 6-9 / 9-12 / 12+ %.0f / %.0f / %.0f / %.0f%%; doing:",
                        q ? "came off him" : "kept (clean)", tot / nm,
                        100.0 * rt_sp[q][0] / tot, 100.0 * rt_sp[q][1] / tot, 100.0 * rt_sp[q][2] / tot, 100.0 * rt_sp[q][3] / tot,
                        100.0 * rt_rel[q][0] / tot, 100.0 * rt_rel[q][1] / tot, 100.0 * rt_rel[q][2] / tot, 100.0 * rt_rel[q][3] / tot);
            for (int w = 0; w < ai::kWhyCount; ++w)
                if (rt_n[q][w] * 25 >= tot) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * rt_n[q][w] / tot);
            std::printf("\n");
        }
        if (cut_n) {
            std::printf("  each interception: the man had moved <1 m %.0f%% · 1-3 %.0f%% · 3-6 %.0f%% · 6+ %.0f%% since the kick; the ball had flown <0.5 s %.0f%% · 0.5-1 %.0f%% · 1-2 %.0f%% · 2+ %.0f%%\n  the pass:",
                        100.0 * cut_moved[0] / cut_n, 100.0 * cut_moved[1] / cut_n, 100.0 * cut_moved[2] / cut_n, 100.0 * cut_moved[3] / cut_n,
                        100.0 * cut_time[0] / cut_n, 100.0 * cut_time[1] / cut_n, 100.0 * cut_time[2] / cut_n, 100.0 * cut_time[3] / cut_n);
            for (int w = 0; w <= ai::kWhyCount; ++w)
                if (cut_by_why[w] * 25 >= cut_n)
                    std::printf(" %s %.0f%%", w == ai::kWhyCount ? "in behind" : ai::kWhyNames[w], 100.0 * cut_by_why[w] / cut_n);
            std::printf("\n  the flight read one tick after the kick said: ours first %.0f%% · THEIRS first %.0f%% · nobody %.0f%% (all kicks: %.0f / %.0f / %.0f%%)",
                        100.0 * pred_cut[0] / cut_n, 100.0 * pred_cut[1] / cut_n, 100.0 * pred_cut[2] / cut_n,
                        100.0 * pred_all[0] / std::max(1L, pred_all[0] + pred_all[1] + pred_all[2]),
                        100.0 * pred_all[1] / std::max(1L, pred_all[0] + pred_all[1] + pred_all[2]),
                        100.0 * pred_all[2] / std::max(1L, pred_all[0] + pred_all[1] + pred_all[2]));
            if (po_n) {
                std::printf("\n  cut passes the read gave to US (%ld): the cutter was their predicted man %.0f%%; we were ahead by <0.2 s %.0f%% · 0.2-0.5 %.0f%% · 0.5-1 %.0f%% · 1+ / unchallenged %.0f%%; our man 0.3 s in:",
                            po_n, 100.0 * po_cutter_pred / po_n, 100.0 * po_margin[0] / po_n, 100.0 * po_margin[1] / po_n,
                            100.0 * po_margin[2] / po_n, 100.0 * po_margin[3] / po_n);
                for (int w = 0; w < ai::kWhyCount; ++w)
                    if (po_us_why[w] * 20 >= po_n) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * po_us_why[w] / po_n);
            }
            std::printf("\n  kicks the flight read gave to THEM at the kick, by kind (share of that kind, a team a match):");
            for (int w = 0; w <= ai::kWhyCount; ++w) {
                const long n = pred_why[w][0] + pred_why[w][1] + pred_why[w][2];
                if (n < 5 * matches || w == static_cast<int>(ai::Why::Shoot)) continue;
                std::printf("\n    %-28s %3.0f%%  %5.1f", w == ai::kWhyCount ? "in behind (rungs 1-2)" : ai::kWhyNames[w], 100.0 * pred_why[w][1] / n,
                            pred_why[w][1] / 2.0 / matches);
            }
            std::printf("\n  the man who took it was doing:");
            for (int w = 0; w < ai::kWhyCount; ++w)
                if (cut_why_taker[w] * 25 >= cut_n) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * cut_why_taker[w] / cut_n);
            std::printf("\n");
        }
        {
            const long tn = rs_n[0][0] + rs_n[0][1] + rs_n[1][0] + rs_n[1][1] + rs_n[2][0] + rs_n[2][1];
            if (carrier_near[5] > 0)
                std::printf("\nCARRIER'S NEAREST OPPONENT (G5.4): mean %.1f m; <2 m %.0f%% · 2-5 %.0f%% · 5-10 %.0f%% · 10+ %.0f%% (pro tracking 4.4-5.3 m; 18-22 / 31-33 / 27-31 / 17-24)\n",
                            carrier_near[4] / carrier_near[5], 100 * carrier_near[0] / carrier_near[5], 100 * carrier_near[1] / carrier_near[5],
                            100 * carrier_near[2] / carrier_near[5], 100 * carrier_near[3] / carrier_near[5]);
            if (st_spells)
                std::printf("\nSPELLS AS STATSBOMB COUNTS THEM (G5.4): %.1f a match (pro 120.7), %.1f s long (pro 46.7, dead time included in both); won within 35 m of the goal attacked %.1f / %.1f a team (pro 2.1)\n",
                            static_cast<double>(st_spells) / matches, st_ticks / 30.0 / st_spells, static_cast<double>(st_high[0]) / matches, static_cast<double>(st_high[1]) / matches);
            std::printf("\nCONVERSION BY DISTANCE (G5.4), goals per shot: ");
            { static const char* nm[5] = {"<11 m", "11-16", "16-22", "22-30", "30+"};
              for (int i = 0; i < 5; ++i) if (conv_shots[i]) std::printf("%s %.1f%% of %ld · ", nm[i], 100.0 * conv_goals[i] / conv_shots[i], conv_shots[i]); }
            std::printf("\n");
            std::printf("\nPASSES BY THIRD (G5.4), a team a match: third pressed n fwd%% square%% back%% gain dist\n");
            for (int z = 0; z < 3; ++z)
                for (int pr = 0; pr < 2; ++pr) {
                    const double* t = pass_dir[z][pr];
                    if (t[0] > 0)
                        std::printf("  %s %s %6.1f %5.1f %5.1f %5.1f %5.1f %5.1f\n", z == 0 ? "own  " : z == 1 ? "mid  " : "final", pr ? "yes" : "no ",
                                    t[0] / matches / 2, 100 * t[1] / t[0], 100 * t[2] / t[0], 100 * t[3] / t[0], t[4] / t[0], t[5] / t[0]);
                }
            std::printf("\nIN THE AIR (G5.3) a match: duels %.1f, alone %.1f; headers at goal %.1f / %.1f, in %.2f / %.2f, away %.1f / %.1f\n",
                        air_duels / static_cast<double>(matches), air_lone / static_cast<double>(matches),
                        air_goal[0] / static_cast<double>(matches), air_goal[1] / static_cast<double>(matches),
                        air_scored[0] / static_cast<double>(matches), air_scored[1] / static_cast<double>(matches),
                        air_clear[0] / static_cast<double>(matches), air_clear[1] / static_cast<double>(matches));
            std::printf("\nRESTARTS (G5.2) a match: throw-ins %.1f, goal kicks %.1f, corners %.1f; called by assistants %.0f%%, referee %.0f%%; off a man %.1f; given the wrong way %.2f; ball dead %.0f%% of the time; longest wait %.0f s; goals within 10 s of one: throw %.2f, goal kick %.2f, corner %.2f\n",
                        (rs_n[0][0] + rs_n[0][1]) / static_cast<double>(matches), (rs_n[1][0] + rs_n[1][1]) / static_cast<double>(matches),
                        (rs_n[2][0] + rs_n[2][1]) / static_cast<double>(matches), 100.0 * rs_called_by[1] / std::max(1L, tn),
                        100.0 * rs_called_by[0] / std::max(1L, tn), rs_deflect / static_cast<double>(matches),
                        rs_wrong_total / static_cast<double>(matches), 100.0 * rs_dead_ticks / std::max(1L, rs_ticks),
                        std::max({rs_dead[0].empty() ? 0.0 : *std::max_element(rs_dead[0].begin(), rs_dead[0].end()), rs_dead[1].empty() ? 0.0 : *std::max_element(rs_dead[1].begin(), rs_dead[1].end()), rs_dead[2].empty() ? 0.0 : *std::max_element(rs_dead[2].begin(), rs_dead[2].end())}),
                        rs_goal[0] / static_cast<double>(matches), rs_goal[1] / static_cast<double>(matches), rs_goal[2] / static_cast<double>(matches));
        }
        std::printf("\nPRO REFERENCE — %s, %s %s, %d matches (semi-pro sits on the worse side of it)\n",
                    bench[0].source.c_str(), bench[0].competition.c_str(), bench[0].season.c_str(), bench[0].matches);
        std::printf("  %-76s %9s %9s %9s\n", "", names.team_home.substr(0, 9).c_str(), names.team_away.substr(0, 9).c_str(), "pro");
        for (const auto& b : bench) {
            const auto it = sim.find(b.metric);
            if (it == sim.end()) continue;
            std::string lab = b.label + " (" + b.unit + ")";
            if (b.competition != bench[0].competition)   // G4.98: a second source's row says whose
                lab = b.label + ", " + b.competition + " " + b.season + " (" + b.unit + ")";
            if (std::isnan(it->second.second))
                std::printf("  %-76s %9.1f %9s %9.1f\n", lab.c_str(), it->second.first, "", b.value);
            else
                std::printf("  %-76s %9.1f %9.1f %9.1f\n", lab.c_str(), it->second.first, it->second.second, b.value);
        }
    }
    return 0;
}
