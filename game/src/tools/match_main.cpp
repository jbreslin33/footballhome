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
// GAME_MATCH_SEED (base; match m plays seed base+m — a fixed sample); fixtures rotate
// over every team (round-robin, §8.133) unless GAME_TEAM_HOME / GAME_TEAM_AWAY pin one,
// GAME_PARAMS="key=value,..." (game_model_params numbers for the run; the DB
// is never written), GAME_DEAD_TRACE=1 (a stalled dead ball, every 10 s),
// GAME_HOLD_TRACE=1 (full-backs and wide men holding shape at 5 Hz: spot, velocity, intent; §8.128;
// =all: every role), GAME_SHOT_TRACE=1 (every shot: the opponents where they stand; §8.186),
// GAME_GS_TRACE=1 (the defending side at 5 Hz with the ball inside 12 m of its goal: each man
// pos>target@speed/toward target/asked and his order; =all: out to 30 m; §8.186).

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
    std::vector<double> near_band[5]; long near_n[5] = {}, near_gs[5] = {};
    long near_why[2][ai::kWhyCount] = {}, near_cvn[2] = {}; double near_cv[2] = {}, near_held[2] = {};
    long pz_n[10] = {}, pz_to[10][10] = {};
    long zm_f[15] = {}, zm_n[15][15] = {}, zm_0[15][15] = {}; long zm_r[15][15][ai::kRoleCount] = {}, zm_c[15][ai::kRoleCount] = {}; double zm_tl[15][15][ai::kRoleCount] = {}, zm_ay[15][15][ai::kRoleCount] = {};   // §8.190: where they stand   // §8.189: by role, and who has it   // §8.160: mates by zone, by the ball's zone
    long bx_gf[2][2] = {}, bx_g[2][2][5] = {}; long bx_lf[6][2] = {}, bx_li[6][2] = {}, bx_lst[6][2] = {}; double bx_lsd[6][2] = {}; long bx_sf[6][3] = {}, bx_si[6][3] = {}; long bx_ch[6] = {}, bx_i2[6] = {}, bx_was[6] = {}; double bx_mv[6] = {};   // §8.162: in the box now, there 2 s before, moved
     long bx_f[6] = {}, bx_in[6] = {}, bx_run[6] = {}; double bx_run_tl[6] = {}, bx_ln[6] = {}, bx_lead[6] = {}, bx_deep[6] = {}, bx_cbm[6] = {}, bx_gap2[6] = {}; long bx_drole[6][ai::kRoleCount] = {};   // ours in the box zone (0-18 m, |y| < 20.16) by the ball's zone (DFL box)   // passes as played: origin zone → end zone (the pass policy's grid)   // the nearest defender to the man on the ball, by band (DFL press)   // each goal by the last kick's why (+ none), own goals   // balls let go in open play by distance (<12, 12-18, 18-25, 25-35, 35+), and shots
    // Concept acts, StatsBomb's cuts (G5.17).
    long pass_ok = 0;
    // In behind (G5.27, benchmarks_tracking_behind.py): passes met past their line as it stood at the kick.
    long tkl[2][3] = {};
    long tick_n = 0, tick_live = 0, dead_n[14] = {}, out_by[2][ai::kWhyCount + 1] = {}; std::vector<double> dead_s[14]; long fouls = 0, pens = 0, pen_goals = 0, tkl_area = 0, area_rec = 0, area_ticks = 0;
    long tk_spells = 0, tk_frames = 0, tk_press = 0, tk_takeon = 0, tk_press_z[5] = {};
    long press_why[ai::kWhyCount] = {}, press_d[5] = {}, gap_h[10] = {}, led = 0, bh_pass = 0, bh_n = 0, bh_ok = 0, bh_air = 0, bh_fwd = 0, bh_frun = 0, bh_z[10] = {};
    long sx_gs[5] = {}, sx_gs_g[5] = {}, sx_tb[4] = {}, sx_tb_g[4] = {}; std::vector<int> sx_tb_gs[4], sx_bd_gs[4];   // §8.186 SHOT CONTEXT
    long gsd_n[4] = {}, gsd_k[4][4] = {}; std::vector<int> gsd_g[4]; std::vector<double> gsd_deep[4];   // §8.186 GOAL-SIDE
    double sl_xy[ai::kRoleCount] = {}, sl_xx[ai::kRoleCount] = {}; long sl_n[ai::kRoleCount] = {}; std::vector<double> sl_w[ai::kRoleCount][2];   // §8.189 SLIDE BY ROLE
    long xz_n[4][3] = {}, xz_c[4][3] = {}; long ar_carry = 0, ar_pass = 0, ar_pass_wide = 0, ar_within = 0; long rce_n[4] = {}, rce_ok[4] = {}, rce_role[ai::kRoleCount] = {}, rce_won_by[ai::kRoleCount + 1] = {}; std::vector<double> rce_me, rce_def, rce_gk, rce_vt; long dwl_n[ai::kWhyCount] = {}, dwl_ok[ai::kWhyCount] = {}, dwl_out[ai::kWhyCount] = {}, dwl_gk[ai::kWhyCount] = {}; std::vector<double> dwl_len[ai::kWhyCount];   // §8.191 DOWN THE LINE by kind   // §8.191 ARRIVE in the crossing zone (their line 0-18 m, |y| 14+)   // §8.188 RELEASES BY ZONE: open-play passes by origin (their line 0-6/6-18/18-30/30+ x |y| 24+/14-24/centre), crosses
    double iw_n[2][3] = {}, iw_dy[2][3] = {}, iw_dx[2][3] = {}; long iw_e[2][3] = {};   // §8.188 INWARD [carried / passed][centre / mid / wide]
    std::vector<int> gsd_dl[4], gsd_box[4]; std::vector<double> gsd_ay[4], gsd_by[4];   // §8.187: deeper than the ball, in the box, across from the ball
    long bt_n[2][2] = {}, bt_shot[2][2] = {}, bt_goal[2][2] = {};   // §8.186 IN BEHIND THEN [high][completed]
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
    long rc_gap[4] = {}, rc_gapb[4] = {};
    // §8.187 HOLD SPOT: the side without it, holders, 5 Hz — his spot's speed (target moved over 0.2 s, same
    // order both ends) v his own, by the ball [0 carried by them / 1 free]; lag added by the spot / closed by him.
    std::vector<double> hs_rl[2][ai::kRoleCount];
    long hs_n[2] = {}, hs_sp[2][4] = {}, hs_mv[2][4] = {}; double hs_lag[2] = {}, hs_add[2] = {}, hs_close[2] = {}, hs_jump_add[2] = {};
    long pc_n[13] = {}, pc_g[13] = {}, pc_k[13] = {}, pc_p[13] = {};
    long sc_n[4][7] = {}, sc_s[4][7] = {};
    long ln_n[4] = {}, ln_b[4] = {}; std::vector<double> ln_near;
    long lo_f = 0, lo_1 = 0, lo_k[4] = {}, cb_n = 0; double cb_gap = 0, cb_mid = 0;
    long wg_n[4][10] = {}; double wg[4][10] = {};   // settled CB / FB pair gaps by band   // §8.138: the lane in open play, the CB pair
    std::vector<double> sh_near, sh_held; long sh_gs = 0;   // at the strike: nearest opponent to the shooter, s on the ball   // §8.138: bodies in the ±1 m lane at the strike; blocked by count   // the save curve: aimed on target, saved (held/parried) or scored, by band x keeper gap   // §8.135: shots by aimed cell ([0] = aimed off): n, goals, keeper holds, keeper parries
    long sh_n[5][ai::kRoleCount][3] = {}; double sh_at[5][ai::kRoleCount][3] = {}, sh_tg[5][ai::kRoleCount][3] = {};   // §8.143: possession side, ball still: holders / box runners / other, at v target
    std::vector<double> st_short[10];   // §8.144: every ST's metres short of their line
    long gb_f[4] = {}, gb_k[4][11] = {}; double gb_v[4][11] = {};   // §8.145: men by gap short of their line (2 m bins from -4), speed at goal
    long rn_n[4] = {}, rn_r[ai::kRoleCount] = {}, rn_past = 0; std::vector<double> rn_g0, rn_min, rn_len;   // §8.145: runs
    std::vector<float> rq[4][ai::kRoleCount];   // §8.145: each role's gap short of their line
    long lg_n[2][5] = {}, lg_m[2][5][ai::kRoleCount + 1] = {}; double lg_dA[2][5][ai::kRoleCount + 1] = {}, lg_dg[2][5][ai::kRoleCount + 1] = {};   // §8.146: their line moves
    double lg_xy[2][ai::kRoleCount + 1] = {}, lg_xx[2][ai::kRoleCount + 1] = {}, lg_sx[2][ai::kRoleCount + 1] = {}, lg_sy[2][ai::kRoleCount + 1] = {}; long lg_s1[2][ai::kRoleCount + 1] = {};
    std::vector<float> lg_g[2][5][ai::kRoleCount + 1], lg_f[2][5];
    long ro_n[ai::kRoleCount] = {}, ro_sides = 0;
    long is_n = 0, is_bn = 0, is_got[5] = {}; double is_best = 0, is_t = 0, is_spot = 0, is_rd0 = 0, is_od0 = 0;   // §8.156: balls into space: got by him / a mate / them / out / nobody
    long ws_n = 0, ws_from[6] = {}, ws_as[9] = {}, ws_ok[9] = {};   // §8.155: spells starting wide (|y| 14+) 18-35 m out: let go from / as
    long lq_h[6][61] = {};   // §8.152b: their line (min with the ball) by whole metres, by the ball's zone
    long ft_c[9] = {}; double ft_g[9] = {}; double ft_tg = 0, ft_v = 0, ft_lv = 0, ft_cmd = 0; std::vector<float> ft_age;   // §8.151: the front man 4+ m short (ball 20-50 out): what he is
    int rn_wh[32] = {}; long rn_whn[ai::kWhyCount + 2] = {}; std::vector<double> rn_wm[ai::kWhyCount + 2], rn_wt[ai::kWhyCount + 2]; double rn_tg[32] = {};   // §8.193: every run by his order at its start: where it got to, and his target's gap then   // §8.150: a ball-still run by his order at its start (+ front man, second man)   // §8.148: outfield starters by role
    long sp_id = 0, sp_last_k = -100, sp_of[32] = {}; int sp_att = -1; double sp_s[32] = {}, sp_ss[32] = {}; long sp_k[32] = {};   // §8.146: each man's spell
    std::vector<double> sp_mean[ai::kRoleCount]; double sp_w[ai::kRoleCount] = {}; long sp_wn[ai::kRoleCount] = {};
    long rn_k[32] = {}, rn_last[32] = {}; double rn_s0[32] = {}, rn_sm[32] = {}; int rn_z[32] = {}, rn_b[32] = {}; long rn_nb[2] = {}; std::vector<double> rn_minb[2]; long run_why = 0, run_el[ai::kRoleCount] = {}, run_st[ai::kRoleCount] = {}, run_was[32] = {}, run_c[4] = {};
    double tn_as[25] = {}; long tn_an[25] = {}, tn_n[4] = {}, tn_z[4] = {}; std::vector<double> tn_L[4], tn_b[4], tn_f[4], tn_d[4]; std::vector<std::pair<int, double>> tn_g[4], tn_gk[4]; long tn_nk[4] = {}; std::vector<double> tn_dk[4]; long hb_n[3] = {}, hb_both[3] = {}, hb_o2[3] = {}, hb_none[3] = {}, hb_lost[3] = {}; std::vector<double> hb_a[3], hb_d[3], hb_cd[3], hb_ct[3], hb_rd[3], hb_cv[3]; long hb_c[3] = {}, hb_why[3][ai::kWhyCount + 1] = {}; std::vector<double> hb_from[3]; long aer_d = 0, aer_l = 0, aer_c = 0, aer_g = 0, wsp_n[4] = {}, wsp_l[4][3] = {}, lk_n[3][3] = {}, lk_k[3][3] = {}; std::vector<double> wsp_f[4][2]; long mk_n[2][3] = {}, mk_2[2][3] = {}, mk_35[2][3] = {}, mk_5[2][3] = {}; std::vector<double> mk_r[2][3], mk_pa[2][3], mk_len[2][3], mk_al[2][3]; std::vector<double> mf_d[2][4][2]; long mf_n[2][4][2] = {}, mf_2[2][4][2] = {}, mf_gs[2][4][2] = {}; std::vector<double> mf_cb[3][5]; long mf_cn[3][5] = {}, mf_c3[3][5] = {}, mf_mk[4] = {}, mf_mgs[4] = {}, mf_all[4] = {}; std::vector<double> mf_md[4]; long hn_why[3][ai::kWhyCount] = {}; long hp_n[3] = {}, hp_ok[3] = {}, hp_du[3] = {}, hp_duc[3] = {}; std::vector<double> hp_len[3]; long hl_n[3][6] = {}, hl_h[3][6] = {}, hl_hc[3][6] = {}, hl_gc[3][6] = {}; std::vector<double> hn_d[3][ai::kWhyCount]; long hm_n[3] = {}, hm_on[3] = {}; std::vector<double> hm_d[3]; long pk_n[3] = {}, pk_k[3] = {}, pk_near[3] = {}, pk_w2[3] = {}, pk_same[3] = {}; double pk_even[3] = {}, pk_drc[3] = {}, pk_dm[3] = {}; long hd_n[3][3][6] = {}, hd_h[3][3][6] = {}, gp_n[10] = {}, gp_k[10] = {}, gp_h[10] = {}, gp_ok[10] = {}; std::vector<double> gp_len[10]; std::vector<double> ev_acc[9], ev_brk[9], ev_lat[9], ev_rad[9]; long ev_n[9] = {}; std::vector<double> cr_ah[7], cr_sd[7], cr_iv[7], cr_pk[7]; long cr_t[7] = {}, cr_f[7] = {}; long cr_lost = 0, cr_steal = 0; long kf_n[2][3] = {}, kf_ok[2][3] = {}, kw_n[4] = {}, kw_ok[4] = {}, kf_wait = 0, kf_wt = 0, kf_cancel = 0; std::vector<double> ft_r, ft_g5, ft_g10; long ft_n = 0, ft_kept = 0; long pt_n = 0, pt_rel[4] = {}, pt_near = 0; std::vector<double> pt_q5; long hp_oc[3][7] = {}; std::vector<double> lf_ang[5], lf_pk[5], lf_dn[5], lf_ld[5], lf_v[5]; long lf_n[5] = {}; std::vector<double> hf_d[3][8], hf_t[3][8], hf_v[3][8]; long hf_n[3][8] = {}, hf_w[3][8][ai::kWhyCount + 1] = {}; std::vector<double> hf_cd[3][8], hf_cv[3][8], hf_c0[3]; long hf_never[3] = {}, hf_all[3] = {}; std::vector<double> hl_d[3], hl_a[3], hl_da[3], hl_t[3], hl_v[3]; long mp_av[2][3][5] = {}, mp_pk[2][3][5] = {}, mp_n[2][3] = {}; std::vector<double> rs_t[2], rs_r[2], rs_c[2], rs_dt[2]; long rs_in3[2] = {}, rs_far[2] = {}, rs_why[2][ai::kWhyCount] = {}, rs_kind[2][2] = {}, rs_kin3[2][2] = {}, rs_zn[3] = {}, rs_z3[3] = {}, rs_ln[2][4] = {}, rs_lt3[2][4] = {}, rs_lr3[2][4] = {}, rs_sn[2][4] = {}, rs_s3[2][4] = {}; std::vector<double> rs_sc[2][4];   // §8.184 MARKED PICK [all, completed]   // §8.183 RECEIVER SPACE   // §8.182 PRESSED TOUCH   // §8.181 FIRST TOUCH   // §8.180 KICK FOOT   // §8.179 CARRY   // §8.178 BODY ENVELOPE   // §8.177 TO OUR KEEPER   // §8.176 HIGH BY DIRECTION   // §8.175 PASS PICK   // §8.174 the nearest defender's job at the drop   // §8.173 MARKING, EVERY FRAME   // §8.173: the receiver's marker at the kick
    // §8.172: the side in possession's own line, all frames and as it loses the ball
    std::vector<double> fs_1[5], fs_2[5], ft_L[4], ft_A[4], bk_top[10];   // bk_top §8.171: the block's most advanced man   // §8.171: the front two by seconds since the spell began
    long fj_t = 0, fj_why[5] = {}, fe_why[6] = {}; std::vector<double> fj_ten, fj_end, fj_new, fj_old, fj_mv, fe_ten, fe_new, fe_mv;   // §8.164: the front man's tenure (benchmarks_tracking_frontjob.py)
    long fm_n[10] = {}, fm_w1[10] = {}, fm_w2[10] = {}, fm_w4[10] = {}, fm_past[10] = {}, fm_r[10][ai::kRoleCount] = {}; double fm_gap[10] = {}, fm_gap2[10] = {}, fm_dy[10] = {};   // §8.144: the front man v their line
    long pl_n[5][4] = {}; long pl_k[5][4][ai::kRoleCount] = {}; double pl_s[5][4][ai::kRoleCount] = {}, pl_line[5][4] = {}, pl_front[5][4] = {};   // §8.143: the side in possession, the same split
    long dl_n[5][4] = {}; long dl_k[5][4][ai::kRoleCount] = {}; double dl_s[5][4][ai::kRoleCount] = {};   // §8.142: settled shape by band x the ball's speed at them over 1 s
    long dp_n[2][10][ai::kRoleCount] = {}; double dp_s[2][10][ai::kRoleCount] = {};   // §8.131: shape settled (6 s+ since lost) / transition   // holders in danger by metres off their spot: steps, 5+ back   // the ball inside 40 m of their goal / further: steps, 5+ back / up / across   // 5+ m/s: by why × back / up / across, by role
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
    // G5.35: rotating fixtures — James: "so you test with various matchups". Unless
    // GAME_TEAM_HOME / GAME_TEAM_AWAY pin one pairing, match m plays game m of a
    // round-robin over every team (circle method: round m/10, game m%10; home and
    // away swap by round), so 8 matches are 8 fixtures, 16 different sides.
    struct Side { persistence::DemoTeam team; ai::FormationSpec spec; };
    std::vector<Side> sides;
    const bool rotate = !std::getenv("GAME_TEAM_HOME") && !std::getenv("GAME_TEAM_AWAY") && base.team_names.size() >= 2;
    if (rotate) {
        for (const auto& n : base.team_names) {
            auto t = persistence::loadDemoTeam(db, n);
            if (!t) continue;
            Side sd{std::move(*t), base.formation_home};
            if (!sd.team.formation_code.empty())
                if (auto f = persistence::loadFormation(db, sd.team.formation_code)) sd.spec = std::move(*f);
            sides.push_back(std::move(sd));
        }
        if (sides.size() % 2) sides.pop_back();   // the circle wants an even count
    }
    std::vector<std::string> fixtures;

    for (int m = 0; m < matches; ++m) {
        server::GameServer::Config cfg = base;
        cfg.match_seed = seed0 + static_cast<std::uint64_t>(m);
        if (sides.size() >= 2) {
            const int n = static_cast<int>(sides.size()), rounds = n - 1, per = n / 2;
            const int r = (m / per) % rounds, g = m % per;
            auto at = [&](int k) { return k == 0 ? 0 : 1 + (k - 1 + r) % (n - 1); };   // 0 fixed, the rest turn
            int a = at(g), b = at(n - 1 - g);
            if (r % 2) std::swap(a, b);
            cfg.roster_home = sides[a].team; cfg.formation_home = sides[a].spec;
            cfg.roster_away = sides[b].team; cfg.formation_away = sides[b].spec;
            fixtures.push_back(sides[a].team.name + " v " + sides[b].team.name);
        }
        NullTransport t;
        server::GameServer s{cfg, t};
        const auto& W = s.world();
        const double hx = W.pitchHalfX().toDouble();
        const std::uint8_t N = W.playerCount();
        // §8.143: the brain's role (formation role name, then number) — by number a "ten" in an 8 shirt was a DM here
        auto role = [&](std::uint8_t j) { return static_cast<int>(s.brain().roleOf(j)); };
        int rc_team = -1; long rc_k = 0;   // the last touch's side, and since when
        bool hb_rose = false; double hb_pz = 0; struct HbP { long k; int po, z; }; std::vector<HbP> hb_p;   // §8.172: high balls coming down
        long hl_k = -1; double hl_x[32] = {}, hl_y[32] = {};   // §8.185: every man at the launch
        struct Lf { bool on = false; long k0 = 0; int kicker = -1; double x0 = 0, y0 = 0, pk = 0, down = -1, ang = 0, v = 0, lz = 0, lx = 0, ly = 0; } lf;   // §8.185 LOFT FLIGHT
        struct HlF { long k; float x[32], y[32], tx[32], ty[32], v[32]; std::uint8_t why[32]; }; std::vector<HlF> hl_f;   // §8.185 the flight, 5 Hz
        long tn_k = -1; int tn_a = -1; double tn_bb = 0, tn_L = 0, tn_fw = 1e9, tn_du = 0; long tp_k = -1; int tp_w = -1, tp_z = 0, tp_b5 = 0; double tp_L = 0, tp_du = 0; long ws_k = -1, ws_last = -1; int ws_a = -1, ws_z = 0; double ws_b = 0, ws_f3 = 1e9, ws_f6 = 1e9; double pb_x[2] = {}, pb_y[2] = {}, pb_z = 0; long pb_k = -1; int tp_kind = 0, tp_ab = 0;   // §8.172 (tp_: a loss pending its winner keeping it 2 s): the last 5 Hz frame's possession side, ball, line
        struct Mk { bool on = false; int p = -1, team = -1; double peak = 0, x[32] = {}, y[32] = {}; } mk;   // §8.173: every man where he stood at the release
        struct Bt { int team; long k0; bool high, ok; }; std::vector<Bt> bt_rec; std::vector<long> bt_shotk[2], bt_goalk[2];   // §8.186
        bool pen_on = false; long pen_k = -1;   // §8.140: a penalty awarded / kicked at
        double sl_b[32] = {}, sl_y[32] = {}, sl_bb[32] = {}, sl_by[32] = {}; long sl_c[32] = {};   // §8.189 per man this match
        long iw_k = -1; int iw_a = -1; double iw_x = 0, iw_y = 0;   // §8.188
        int ar_own = -1; bool ar_in = false;   // §8.191: the carrier, and whether he was in the crossing zone
        long hs_k[32]; double hs_tx[32] = {}, hs_ty[32] = {}, hs_px[32] = {}, hs_py[32] = {}; for (long& x : hs_k) x = -1;   // §8.187
        // Per-match state.
        struct Shot { bool on = false; int team = 0, band = 0; long tick = 0; int cell = -1; int gap = -1; int lane = 0; int gsk = 0, tb = 0; } shot;
        int last_kick_why = ai::kWhyCount, last_kick_team = -1; long last_kick_k = -1000; double last_kick_own = 0;
        const bool bh_trace = std::getenv("GAME_BEHIND_TRACE") != nullptr;
        struct Bh { bool led = false, space = false; double rd0 = 0, od0 = 0; double tx = 0, ty = 0; bool on = false, geo = false, behind = false, air = false; int team = -1, r = -1, runners = 0, z = 0; long k0 = 0, bk = 0;
                    double line = 0, gap = 0, spd = 0, vx = 0, bx = 0, by = 0, rx = 0, ry = 0, best = 1e9, mrx = 0, mry = 0; } bh;
        int owner = -1, owner_team = -1; long owner_got = 0; double own_sx = 0, own_px = 0, own_py = 0;
        bool own_set = false;
        struct Hp { bool on = false; double pz = 0; int kicker = -1, team = -1, z = 0; long k0 = 0; int duels0 = 0; bool duel = false, high = false; int oz = 0, lb = 0, gk = -1; double tx = 0, ty = 0; } hp;   // §8.174 HIGH PASSES
        struct Rel { int p = -1, team = -1; double x = 0, y = 0; bool set = false, cross = false, shot = false, ws = false, weak = false; int wait = 0; int why = -1; double rc_tx = 0, rc_ty = 0, rc_me = -1, rc_def = -1, rc_gk = -1, rc_vt = 0; int rc_who = -1, rc_role = -1; int mp_rb = -1, mp_pb = -1; int mp_av[5] = {}; } rel;   // mp_: §8.184 MARKED PICK
        bool ws_on = false;   // §8.155: this spell began wide 18-35 m out
        int from[32]; long from_t[32], pressed_in[32]; int facing[32];
        for (int j = 0; j < 32; ++j) { from[j] = -1; from_t[j] = -1000; pressed_in[j] = -1; facing[j] = 0; }
        long loss_tick[2] = {-1000, -1000};
        // 5 Hz ring for "3 s before" (ball x, every man's x).
        int fj_hold = -1, fe_hold = -1; long fj_since = 0, fe_since = 0, fj_pk = -100; int fj_pa = -1; bool fe_was[32] = {};
        long dead_last = 0; long rk[16]; double rbx[16], rpx[16][32], rpy[16][32]; int rat[16] = {}; for (long& v : rk) v = -1;
        bool en_arm[2] = {false, false}; double en_prev[2] = {0, 0}; long en_pk[2] = {-100, -100};
        long dead_k0 = -1; int dead_kind = 0, dead_why = 0; char out_note[256] = "";
        struct Tk { int car = -1; long last = -100000; bool faced = false; std::uint32_t pressed = 0; double prev[32]; bool has[32]; } tk{};
        struct Carry { bool on = false, done = false; int pid = -1, att = -1, miss = 0, fr = 0, eng = 0, first = -1; long k0 = 0, last = 0;
                       double btl0 = 0, near0 = 0, close = 0, w5 = 0; bool gs[32] = {}; int r[32] = {}; double rd[32] = {}; } cy;

        struct Env { double x[32][29], y[32][29]; bool live[29]; } env{};   // §8.178: the last 29 ticks of every man
        struct Cr { std::uint32_t touches = 0; long last_k = -1000; int last_o = -1; double peak = 0; } cr{};   // §8.179
        struct Ft { long k0; int who; double vin, r = -1; int q = -1; double qd = 99, qx = 0, qy = 0; int rel = -1; } ;   // q: his nearest opponent inside 3 m at the touch (§8.182)
        std::vector<Ft> fts; int ft_prev_owner = -1; double ft_pbx = 0, ft_pby = 0, ft_bvx = 0, ft_bvy = 0;   // §8.181
        // §8.183 RECEIVER SPACE, as benchmarks_tracking_firsttouch.py: the ball free (nobody within 1.5 m, on the
        // ground, in play) 0.4 s+, then a man within 1.5 m; his closest tick over the next 0.32 s within 1 m = the
        // touch; his nearest opponent there and at the release (the first free tick); controlled = the ball's
        // speed 0.13-0.33 s after the touch < 0.7 x the incoming (over the 0.2 s before it)
        struct Rs { long k0, km; int who; double dm, vin, opp, opp0; long kf = 0; int oj = -1, ow = -1, pass = 0; double rx = 0, fx = 0, fy = 0, len = 0, same0 = 99; double px0[32], py0[32]; double bx[12], by[12]; int nb = 0; };
        std::vector<Rs> rss; long rs_free = -1, rs_last = -1000; int rs_lt = -1; double rs_bx0 = 0, rs_by0 = 0; double rs_px[32] = {}, rs_py[32] = {}; double rs_hx[8] = {}, rs_hy[8] = {};
        auto rs_nearOpp = [&](int who) { double best = 99; const auto& rp = W.player(static_cast<std::uint8_t>(who));
            for (std::uint8_t j = 0; j < W.playerCount(); ++j) if (W.player(j).team != rp.team) best = std::min(best, std::hypot(W.player(j).pos.x.toDouble() - rp.pos.x.toDouble(), W.player(j).pos.y.toDouble() - rp.pos.y.toDouble()));
            return best; };
        for (long k = 0; k < ticks; ++k) {
            const auto before = W.ball().owner;
            s.tickOnce();
            {   // §8.181 FIRST TOUCH, as benchmarks_tracking_firsttouch.py: a free ground ball 3 m/s+ becomes
                // his (not a keeper's): off-touch speed / incoming 0.13-0.33 s on, his gap at 0.5 s and 1 s,
                // kept 1 s (still his, within 1.5 m); controlled = off-touch < 0.7 x incoming
                const auto& bb = W.ball();
                const double bx = bb.pos.x.toDouble(), by = bb.pos.y.toDouble();
                const int ow = bb.owner ? static_cast<int>(*bb.owner) : -1;
                const bool live = W.outStage() == 0 && W.restartTeam() == 0xFF;
                if (ow >= 0 && ft_prev_owner < 0 && live && !W.isKeeper(static_cast<std::uint8_t>(ow)) && bb.pos.z.toDouble() < 0.5) {
                    const double vin = std::hypot(ft_bvx, ft_bvy);
                    if (vin >= 3) {
                        Ft f{k, ow, vin};
                        const auto& rp = W.player(static_cast<std::uint8_t>(ow));
                        for (std::uint8_t j = 0; j < W.playerCount(); ++j) {
                            if (W.player(j).team == rp.team) continue;
                            const double ex = W.player(j).pos.x.toDouble() - rp.pos.x.toDouble(), ey = W.player(j).pos.y.toDouble() - rp.pos.y.toDouble();
                            const double e = std::hypot(ex, ey);
                            if (e < 3 && e < f.qd) { f.qd = e; f.q = j; f.qx = ex / std::max(e, 1e-6); f.qy = ey / std::max(e, 1e-6); }
                        }
                        fts.push_back(f);
                    }
                }
                for (std::size_t i = 0; i < fts.size();) {
                    Ft& f = fts[i]; const long dk = k - f.k0;
                    const auto& pp = W.player(static_cast<std::uint8_t>(f.who));
                    const double gap = std::hypot(bx - pp.pos.x.toDouble(), by - pp.pos.y.toDouble());
                    if (dk == 7) {
                        f.r = std::hypot(ft_bvx, ft_bvy) / f.vin;
                        const double vo = std::hypot(ft_bvx, ft_bvy);
                        if (f.q >= 0) f.rel = vo < 0.5 ? 3 : [&] { const double cq = (ft_bvx * f.qx + ft_bvy * f.qy) / vo; return cq > 0.5 ? 0 : cq < -0.5 ? 2 : 1; }();
                    }
                    if (dk == 15 && f.r >= 0 && f.r < 0.7) {
                        S.ft_g5.push_back(gap);
                        if (f.q >= 0 && f.rel >= 0) {   // §8.182 PRESSED TOUCH
                            const auto& qp = W.player(static_cast<std::uint8_t>(f.q));
                            const double q5 = std::hypot(bx - qp.pos.x.toDouble(), by - qp.pos.y.toDouble());
                            ++S.pt_n; ++S.pt_rel[f.rel]; if (q5 < gap) ++S.pt_near; S.pt_q5.push_back(q5);
                        }
                    }
                    if (dk == 30) {
                        if (f.r >= 0 && f.r < 0.7) { ++S.ft_n; S.ft_r.push_back(f.r); S.ft_g10.push_back(gap); if (ow == f.who && gap < 1.5) ++S.ft_kept; }
                        fts.erase(fts.begin() + static_cast<long>(i)); continue;
                    }
                    ++i;
                }
                ft_bvx = (bx - ft_pbx) * 30; ft_bvy = (by - ft_pby) * 30; ft_pbx = bx; ft_pby = by;
                ft_prev_owner = live ? ow : -1;
                {   // §8.183 RECEIVER SPACE
                    for (int h = 7; h > 0; --h) { rs_hx[h] = rs_hx[h - 1]; rs_hy[h] = rs_hy[h - 1]; }
                    rs_hx[0] = bx; rs_hy[0] = by;
                    int nw = -1; double nd = 1.5;
                    for (std::uint8_t j = 0; j < W.playerCount(); ++j) {
                        const double e = std::hypot(W.player(j).pos.x.toDouble() - bx, W.player(j).pos.y.toDouble() - by);
                        if (e < nd) { nd = e; nw = j; }
                    }
                    for (std::size_t i = 0; i < rss.size();) {
                        Rs& r = rss[i];
                        if (k <= r.k0 + 9) {
                            const auto& pp = W.player(static_cast<std::uint8_t>(r.who));
                            const double e = std::hypot(bx - pp.pos.x.toDouble(), by - pp.pos.y.toDouble());
                            if (e < r.dm) { r.dm = e; r.km = k; r.opp = rs_nearOpp(r.who); r.nb = 0;
                                r.oj = -1; for (std::uint8_t j = 0; j < W.playerCount(); ++j) if (W.player(j).team != pp.team && std::hypot(W.player(j).pos.x.toDouble() - pp.pos.x.toDouble(), W.player(j).pos.y.toDouble() - pp.pos.y.toDouble()) <= r.opp + 1e-9) r.oj = j;
                                r.ow = r.oj >= 0 ? static_cast<int>(s.lastOrders()[r.oj].why) : -1;
                                const double ox = pp.pos.x.toDouble(); r.rx = pp.team == 0 ? ox + hx : hx - ox; r.len = std::hypot(bx - r.fx, by - r.fy);
                                if (r.oj >= 0) r.same0 = std::hypot(r.px0[r.oj] - r.px0[r.who], r.py0[r.oj] - r.py0[r.who]); }
                        }
                        if (k > r.km && r.nb < 12) { r.bx[r.nb] = bx; r.by[r.nb] = by; ++r.nb; }
                        if (k >= r.k0 + 9 && r.nb >= 10) {
                            if (r.dm <= 1.0 && !W.isKeeper(static_cast<std::uint8_t>(r.who))) {
                                const double vo = std::hypot(r.bx[9] - r.bx[3], r.by[9] - r.by[3]) * 5;   // ticks +4..+10
                                const int c = vo / r.vin < 0.7 ? 1 : 0;
                                for (int g = 0; g <= c; ++g) {
                                    S.rs_t[g].push_back(r.opp); S.rs_r[g].push_back(r.opp0); S.rs_c[g].push_back(r.opp0 - r.opp); S.rs_dt[g].push_back((r.km - r.kf) / 30.0);
                                    ++S.rs_kind[g][r.pass];
                                    if (r.pass && r.oj >= 0) { const int sb = r.same0 < 5 ? 0 : r.same0 < 10 ? 1 : r.same0 < 15 ? 2 : 3; ++S.rs_sn[g][sb]; S.rs_sc[g][sb].push_back(r.same0 - r.opp); if (r.opp < 3) ++S.rs_s3[g][sb]; }
                                    if (r.pass) { const int lb = r.len < 10 ? 0 : r.len < 20 ? 1 : r.len < 30 ? 2 : 3; ++S.rs_ln[g][lb]; if (r.opp < 3) ++S.rs_lt3[g][lb]; if (r.opp0 < 3) ++S.rs_lr3[g][lb]; }
                                    if (r.opp < 3) { ++S.rs_in3[g]; ++S.rs_kin3[g][r.pass]; if (r.opp0 >= 5) ++S.rs_far[g]; if (r.ow >= 0 && r.ow < ai::kWhyCount) ++S.rs_why[g][r.ow]; }
                                    if (g == 1) { const int z = r.rx < 35 ? 0 : r.rx < 70 ? 1 : 2; ++S.rs_zn[z]; if (r.opp < 3) ++S.rs_z3[z]; }
                                }
                            }
                            rss.erase(rss.begin() + static_cast<long>(i)); continue;
                        }
                        ++i;
                    }
                    if (bb.owner) rs_lt = static_cast<int>(W.player(*bb.owner).team);
                    if (!live || bb.pos.z.toDouble() >= 0.5) rs_free = -1;
                    else if (nw >= 0) {
                        const double vin = std::hypot(rs_hx[1] - rs_hx[7], rs_hy[1] - rs_hy[7]) * 5;
                        if (rs_free >= 0 && k - rs_free >= 12 && k - rs_last > 30 && vin >= 3) {
                            Rs r{k, k, nw, 99, vin, 99, 99}; r.kf = rs_free; for (int j = 0; j < 32; ++j) { r.px0[j] = rs_px[j]; r.py0[j] = rs_py[j]; } r.fx = rs_bx0; r.fy = rs_by0; r.pass = rs_lt == static_cast<int>(W.player(static_cast<std::uint8_t>(nw)).team) ? 1 : 0;
                            const auto& rp = W.player(static_cast<std::uint8_t>(nw));
                            for (std::uint8_t j = 0; j < W.playerCount(); ++j) if (W.player(j).team != rp.team) r.opp0 = std::min(r.opp0, std::hypot(rs_px[j] - rs_px[nw], rs_py[j] - rs_py[nw]));
                            rss.push_back(r);
                        }
                        if (rs_free >= 0 && k - rs_free >= 12) rs_last = k;
                        rs_free = -1;
                    } else if (rs_free < 0) {
                        rs_free = k; rs_bx0 = bx; rs_by0 = by;
                        for (std::uint8_t j = 0; j < W.playerCount(); ++j) { rs_px[j] = W.player(j).pos.x.toDouble(); rs_py[j] = W.player(j).pos.y.toDouble(); }
                    }
                }
            }
            {   // §8.179 CARRY, as benchmarks_tracking_carry.py: the carrier 1 m/s+, ball on the ground, in
                // play — the ball's gap ahead along his travel and across it, by his speed; the engine's touches
                const auto& bb = W.ball();
                const bool live = W.outStage() == 0 && W.restartTeam() == 0xFF;
                if (bb.owner && live && !W.isKeeper(*bb.owner) && bb.pos.z.toDouble() < 0.5) {
                    const auto& o = W.player(*bb.owner);
                    const double vx = o.vel.x.toDouble(), vy = o.vel.y.toDouble(), sp = std::hypot(vx, vy);
                    const double bx = bb.pos.x.toDouble() - o.pos.x.toDouble(), by = bb.pos.y.toDouble() - o.pos.y.toDouble();
                    if (sp >= 1.0) {
                        const int bi = std::min(6, static_cast<int>(sp) - 1);
                        const double ux = vx / sp, uy = vy / sp, ah = bx * ux + by * uy;
                        S.cr_ah[bi].push_back(ah); S.cr_sd[bi].push_back(std::fabs(-bx * uy + by * ux)); ++S.cr_f[bi];
                        if (static_cast<int>(*bb.owner) == cr.last_o) cr.peak = std::max(cr.peak, ah);
                        if (W.dribbleTouches() != cr.touches) {
                            ++S.cr_t[bi];
                            if (static_cast<int>(*bb.owner) == cr.last_o && k - cr.last_k < 90) { S.cr_iv[bi].push_back((k - cr.last_k) / 30.0); S.cr_pk[bi].push_back(cr.peak); }
                            cr.last_k = k; cr.last_o = static_cast<int>(*bb.owner); cr.peak = ah;
                        }
                    }
                } else cr.last_o = -1;
                cr.touches = W.dribbleTouches();
                if (k == ticks - 1) { S.cr_lost += W.dribbleLost(); S.cr_steal += W.steals(); S.kf_wait += W.kicksWaited(); S.kf_wt += W.kickWaitTicks(); S.kf_cancel += W.kicksCancelled(); }
            }
            {   // §8.178 BODY ENVELOPE, as benchmarks_tracking_envelope.py: v = central difference over +-7 ticks
                // (0.233 s ~ DFL's +-3 frames at 25 Hz), a = the same of v, outfielders, ball in play
                const int r = static_cast<int>(k % 29);
                const int np = std::min<int>(32, W.playerCount());
                for (int i = 0; i < np; ++i) { env.x[i][r] = W.player(static_cast<std::uint8_t>(i)).pos.x.toDouble(); env.y[i][r] = W.player(static_cast<std::uint8_t>(i)).pos.y.toDouble(); }
                env.live[r] = W.outStage() == 0 && W.restartTeam() == 0xFF;
                if (k >= 28 && k % 2 == 0) {
                    auto at = [&](long kk) { return static_cast<int>(((kk % 29) + 29) % 29); };
                    const long c = k - 14;
                    if (env.live[at(c)]) {
                        const double h = 14.0 / 30.0;
                        for (int i = 0; i < np; ++i) {
                            if (W.isKeeper(static_cast<std::uint8_t>(i))) continue;
                            auto vel = [&](long m) { return std::pair<double, double>{(env.x[i][at(m + 7)] - env.x[i][at(m - 7)]) / h, (env.y[i][at(m + 7)] - env.y[i][at(m - 7)]) / h}; };
                            const auto v = vel(c), v0 = vel(c - 7), v1 = vel(c + 7);
                            const double sp = std::hypot(v.first, v.second);
                            const int bnd = std::min(8, static_cast<int>(sp));
                            ++S.ev_n[bnd];
                            if (sp < 0.5) continue;
                            const double ax = (v1.first - v0.first) / h, ay = (v1.second - v0.second) / h;
                            const double ux = v.first / sp, uy = v.second / sp, al = ax * ux + ay * uy, la = std::fabs(-ax * uy + ay * ux);
                            (al > 0 ? S.ev_acc : S.ev_brk)[bnd].push_back(std::fabs(al));
                            S.ev_lat[bnd].push_back(la);
                            if (la > 0.3) S.ev_rad[bnd].push_back(sp * sp / la);
                        }
                    }
                }
            }
            const auto& b = W.ball();
            for (const auto& e : s.lastEvents()) {
                if (e.type == core::MatchEventType::Foul) ++S.fouls;
                if (e.type == core::MatchEventType::Penalty) { ++S.pens; pen_k = -1; pen_on = true; }   // §8.140
                if (e.type == core::MatchEventType::TackleWon || e.type == core::MatchEventType::TackleLost) {
                    const double tx = b.pos.x.toDouble() * (e.team == 0 ? 1.0 : -1.0) + hx;   // metres from the tackler's own goal
                    ++S.tkl[e.type == core::MatchEventType::TackleWon ? 0 : 1][tx < 35 ? 0 : tx < 70 ? 1 : 2];
                    if (tx < 16.5 && std::fabs(b.pos.y.toDouble()) < 20.16) ++S.tkl_area;   // §8.140: in his own penalty area
                }
            }
            if (b.owner && W.restartTeam() == 0xFF) {   // §8.141: their man on the ball in our area
                const std::uint8_t at = W.player(*b.owner).team;
                const double ax = b.pos.x.toDouble() * (at == 0 ? 1.0 : -1.0);
                if (ax > hx - 16.5 && std::fabs(b.pos.y.toDouble()) < 20.16) {
                    ++S.area_ticks;
                    if (!before || W.player(*before).team != at) ++S.area_rec;
                }
            }
            if (pen_on && pen_k < 0 && W.restartTeam() == 0xFF) {   // the penalty is kicked
                pen_k = static_cast<long>(k);
                if (std::getenv("GAME_PEN_TRACE")) {
                    const double gx = b.pos.x.toDouble() > 0 ? hx : -hx;
                    std::fprintf(stderr, "pen kicked: ball %.1f,%.1f;", b.pos.x.toDouble(), b.pos.y.toDouble());
                    for (std::uint8_t j = 0; j < N; ++j)
                        std::fprintf(stderr, " %s%d:%.1f,%.1f", W.isKeeper(j) ? "GK" : "", j, std::fabs(gx - W.player(j).pos.x.toDouble()), W.player(j).pos.y.toDouble());
                    std::fprintf(stderr, "\n");
                }
            }
            if (pen_on && pen_k >= 0 && static_cast<long>(k) - pen_k > 150) pen_on = false;
            for (const auto& e : s.lastEvents())
                if (e.type == core::MatchEventType::Goal) {
                    if (pen_on && pen_k >= 0) { ++S.pen_goals; pen_on = false; }
                    ++S.goals[e.team]; bt_goalk[e.team].push_back(static_cast<long>(k));
                    if (last_kick_team >= 0 && last_kick_team != e.team) ++S.goal_own;
                    ++S.goal_by[last_kick_why];
                    if (shot.on && shot.team == e.team) {
                        ++S.shot_out[0]; ++S.band_goal[shot.band]; ++S.pc_g[shot.cell + 1];
                        ++S.sx_gs_g[shot.gsk]; ++S.sx_tb_g[shot.tb];
                        if (shot.gap >= 0) ++S.sc_n[shot.band][shot.gap];
                        shot.on = false;
                    }
                }
            if (std::getenv("GAME_PLAY_TRACE") && k % 300 == 0)
                std::fprintf(stderr, "play m%d %lds ball %.1f,%.1f,%.1f v %.1f,%.1f owner %d last %d restart %d out %d lastTouch %d pass_to %d\n", m, k / 30, b.pos.x.toDouble(), b.pos.y.toDouble(), b.pos.z.toDouble(),
                             b.vel.x.toDouble(), b.vel.y.toDouble(), b.owner ? *b.owner : -1, b.last_kicker, W.restartTeam(), W.outStage(), W.lastTouchTeam(), b.pass_to);
            {   // in play, and each dead spell by the restart that ends it (benchmarks_tracking_dead.py)
                const bool dead = W.restartTeam() != 0xFF || W.outStage() != 0;
                ++S.tick_n; if (!dead) ++S.tick_live;
                if (dead) { if (dead_k0 < 0) { dead_k0 = k; dead_why = before ? ai::kWhyCount : last_kick_why; } if (W.restartTeam() != 0xFF) dead_kind = static_cast<int>(W.restartKind()); }
                else if (dead_k0 >= 0) {
                    const int kd = std::min(13, std::max(0, dead_kind));
                    ++S.dead_n[kd]; S.dead_s[kd].push_back((k - dead_k0) / 30.0); if (kd == 3 || kd == 4) { ++S.out_by[kd - 3][dead_why]; if (std::getenv("GAME_OUT_TRACE") && dead_why != ai::kWhyCount) std::fprintf(stderr, "out kind %d %s\n", kd, out_note); } dead_k0 = -1; dead_kind = 0;
                }
            }
            if (dead_trace && k % 300 == 0 && W.restartTeam() != 0xFF)
                std::fprintf(stderr, "dead-trace m%d k%ld restart %d kind %d owner %d ball %.1f,%.1f\n", m, k, W.restartTeam(),
                             static_cast<int>(W.restartKind()), b.owner ? *b.owner : -1, b.pos.x.toDouble(), b.pos.y.toDouble());

            if (hp.on) {   // §8.174: the first touch after a high pass — a mate's = completed; an aerial duel near the aim within 5 s
                const long dk = static_cast<long>(k) - hp.k0;
                if (W.aerialDuels() > hp.duels0) { hp.duels0 = W.aerialDuels(); if (std::hypot(b.pos.x.toDouble() - hp.tx, b.pos.y.toDouble() - hp.ty) <= 6) hp.duel = true; }
                int toucher = -1;
                if (dk > 0 && b.owner && *b.owner != hp.kicker) toucher = *b.owner;
                else if (dk > 0 && b.last_kicker != hp.kicker && b.last_kicker < N) toucher = b.last_kicker;
                const bool dead = W.outStage() != 0 || W.restartTeam() != 0xFF;
                if (toucher >= 0 || dead || dk > 150) {
                    const bool ok = toucher >= 0 && W.player(static_cast<std::uint8_t>(toucher)).team == hp.team;
                    if (hp.gk >= 0 && ok) ++S.gp_ok[hp.gk];
                    if (hp.high) {
                        {   // §8.185 HIGH OUTCOME: completed / out / offside / lost in the air / on the ground / their keeper / no touch
                            int oc = 6;
                            if (ok) oc = 0;
                            else if (toucher >= 0) oc = W.isKeeper(static_cast<std::uint8_t>(toucher)) ? 5 : hp.pz >= 1.0 ? 3 : 4;
                            else if (dead) { const auto rk = W.restartKind(); oc = (rk == core::MatchEventType::ThrowIn || rk == core::MatchEventType::GoalKick || rk == core::MatchEventType::Corner || W.outStage() != 0) ? 1 : 2; }
                            ++S.hp_oc[hp.z][oc];
                        }
                        if (ok) { ++S.hp_ok[hp.z]; if (hp.duel) ++S.hp_duc[hp.z]; }
                        if (hp.duel) ++S.hp_du[hp.z];
                        if (ok) ++S.hl_hc[hp.oz][hp.lb];
                    } else if (ok) ++S.hl_gc[hp.oz][hp.lb];
                    hp.on = false;
                }
                hp.pz = b.pos.z.toDouble();
            }
            if (before && !b.owner && b.last_kicker == *before) {   // a kick
                last_kick_why = static_cast<int>(s.lastOrders()[*before].why);
                last_kick_team = W.player(*before).team; last_kick_k = static_cast<long>(k);
                last_kick_own = hx + W.player(*before).pos.x.toDouble() * (last_kick_team == 0 ? 1.0 : -1.0);
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
                if (!own_set && (lo.why == ai::Why::Pass || lo.why == ai::Why::InBehind || lo.why == ai::Why::IntoSpace)) {
                    hp = Hp{}; hp.on = true; hp.kicker = *before; hp.team = W.player(*before).team; hp.k0 = static_cast<long>(k); hp.duels0 = W.aerialDuels();
                    hp.high = lo.action == core::Action::LoftedKick;
                    hp.tx = lo.target.x.toDouble(); hp.ty = lo.target.y.toDouble();
                    const double sgk = hp.team == 0 ? 1.0 : -1.0, own_t = hx + hp.tx * sgk, own_k = hx + W.player(*before).pos.x.toDouble() * sgk;
                    const double len = std::hypot(hp.tx - W.player(*before).pos.x.toDouble(), hp.ty - W.player(*before).pos.y.toDouble());
                    hp.z = own_t < 35 ? 0 : own_t < 70 ? 1 : 2;
                    hp.oz = own_k < 35 ? 0 : own_k < 70 ? 1 : 2; hp.lb = len < 10 ? 0 : len < 20 ? 1 : len < 30 ? 2 : len < 40 ? 3 : len < 50 ? 4 : 5;
                    ++S.hl_n[hp.oz][hp.lb]; if (hp.high) ++S.hl_h[hp.oz][hp.lb];
                    {   // §8.176: forward within 60° of straight at their goal / lateral / back
                        const double fw = (hp.tx - W.player(*before).pos.x.toDouble()) * sgk;
                        const int hd = 2 * fw > len ? 0 : 2 * fw < -len ? 2 : 1;
                        ++S.hd_n[hp.oz][hd][hp.lb]; if (hp.high) ++S.hd_h[hp.oz][hd][hp.lb];
                    }
                    {   // §8.177: passes to our own keeper by the passer's 10 m off his own goal
                        const int gb = std::min(9, std::max(0, static_cast<int>(own_k / 10)));
                        ++S.gp_n[gb];
                        if (lo.other >= 0 && lo.other < N && W.isKeeper(static_cast<std::uint8_t>(lo.other))) {
                            ++S.gp_k[gb]; if (hp.high) ++S.gp_h[gb]; S.gp_len[gb].push_back(len); hp.gk = gb;
                        }
                    }
                    if (hp.high) { ++S.hp_n[hp.z]; S.hp_len[hp.z].push_back(len); }
                }
                if (!own_set && (lo.why == ai::Why::Pass || lo.why == ai::Why::Cross || lo.why == ai::Why::InBehind || lo.why == ai::Why::IntoSpace) && lo.other >= 0 && lo.other < N) {
                    const int tm0 = W.player(*before).team;
                    const double sg = tm0 == 0 ? 1.0 : -1.0;
                    std::vector<double> dx;
                    for (std::uint8_t j = 0; j < N; ++j) if (W.player(j).team != tm0) dx.push_back(W.player(j).pos.x.toDouble() * sg);
                    std::sort(dx.rbegin(), dx.rend());
                    const double bx0 = b.pos.x.toDouble(), by0 = b.pos.y.toDouble();
                    if (lo.why == ai::Why::InBehind) ++S.led;
                    bh = Bh{}; bh.on = true; bh.team = tm0; bh.r = lo.other; bh.k0 = k; bh.bx = bx0; bh.by = by0;
                    bh.air = lo.action == core::Action::LoftedKick;
                    bh.led = lo.why == ai::Why::InBehind || lo.why == ai::Why::IntoSpace; bh.space = lo.why == ai::Why::IntoSpace; bh.tx = lo.target.x.toDouble(); bh.ty = lo.target.y.toDouble();
                    bh.line = std::max({dx.size() > 1 ? dx[1] : hx, 0.0, bx0 * sg});
                    const auto& rp = W.player(static_cast<std::uint8_t>(lo.other));
                    bh.rx = rp.pos.x.toDouble(); bh.ry = rp.pos.y.toDouble(); bh.gap = bh.line - bh.rx * sg;
                    bh.spd = std::hypot(rp.vel.x.toDouble(), rp.vel.y.toDouble()); bh.vx = rp.vel.x.toDouble() * sg;
                    if (bh.space) {   // §8.156: at the kick, him and their nearest to the spot
                        bh.rd0 = std::hypot(bh.tx - bh.rx, bh.ty - bh.ry); bh.od0 = 1e9;
                        for (std::uint8_t j = 0; j < N; ++j) if (W.player(j).team != tm0) bh.od0 = std::min(bh.od0, std::hypot(bh.tx - W.player(j).pos.x.toDouble(), bh.ty - W.player(j).pos.y.toDouble()));
                    }
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
                if (bh_trace && bh.led && (!bh.geo ? (k - bh.k0) % 6 == 0 : bh.space && k - bh.k0 <= 150)) {   // a ball into space: every tick after he is near it (§8.159)
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
                    if (bh.space) {   // §8.156
                        ++S.is_n; if (bh.best < 1e8) { ++S.is_bn; S.is_best += bh.best; S.is_t += (bh.bk - bh.k0) / 30.0; S.is_spot += std::hypot(bh.mrx - bh.tx, bh.mry - bh.ty); } S.is_rd0 += bh.rd0; S.is_od0 += bh.od0;
                        const int g = W.outStage() != 0 ? 3 : !b.owner ? 4 : *b.owner == bh.r ? 0 : W.player(*b.owner).team == bh.team ? 1 : 2;
                        ++S.is_got[g];
                    }
                    if (bh.behind) {
                        const bool ok = b.owner && W.player(*b.owner).team == bh.team;
                        ++S.bh_n; S.bh_ok += ok; S.bh_air += bh.air; ++S.bh_z[bh.z];
                        bt_rec.push_back(Bt{bh.team, bh.k0, bh.air, ok});
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
                bt_shotk[p.team].push_back(static_cast<long>(k));
                {   // §8.186 SHOT CONTEXT: outfield opponents nearer their goal centre than him; s since his side's possession began
                    const double gx2 = p.team == 0 ? hx : -hx, ds = std::hypot(gx2 - p.pos.x.toDouble(), p.pos.y.toDouble());
                    int g = 0;
                    for (std::uint8_t j = 0; j < N; ++j)
                        if (!W.isKeeper(j) && W.player(j).team != p.team &&
                            std::hypot(gx2 - W.player(j).pos.x.toDouble(), W.player(j).pos.y.toDouble()) < ds) ++g;
                    const double t = rc_team == p.team ? (static_cast<long>(k) - rc_k) / 30.0 : 0.0;
                    shot.gsk = std::min(g, 4); shot.tb = t < 5 ? 0 : t < 10 ? 1 : t < 20 ? 2 : 3;
                    if (std::getenv("GAME_SHOT_TRACE")) {   // §8.186: every opponent at the strike (x = metres off their goal line)
                        const double sg3 = p.team == 0 ? 1.0 : -1.0;
                        std::fprintf(stderr, "shot m%d k%ld t%.0fs from %.1f,%.1f d %.1f gs %d |", m, static_cast<long>(k), t, hx - p.pos.x.toDouble() * sg3, p.pos.y.toDouble(), ds, g);
                        for (std::uint8_t j = 0; j < N; ++j) {
                            if (W.player(j).team == p.team) continue;
                            std::fprintf(stderr, " %s%d:%.1f,%.1f %s", W.isKeeper(j) ? "GK" : "", role(j), hx - W.player(j).pos.x.toDouble() * sg3, W.player(j).pos.y.toDouble(),
                                         ai::kWhyNames[static_cast<int>(s.lastOrders()[j].why)]);
                        }
                        std::fprintf(stderr, "\n");
                    }
                    ++S.sx_gs[shot.gsk]; ++S.sx_tb[shot.tb]; S.sx_tb_gs[shot.tb].push_back(g); S.sx_bd_gs[shot.band].push_back(g);
                }
                {   // §8.135: the cell it was aimed at — on target 4 across x 3 up, else -1
                    const auto& lo = s.lastOrders()[*before];
                    const double lat = std::fabs(lo.target.y.toDouble()), z = lo.aim_z.toDouble();
                    if (lat < 3.66 && z < 2.44) shot.cell = (lat < 1 ? 0 : lat < 2 ? 1 : lat < 3 ? 2 : 3) + 4 * (z < 0.5 ? 0 : z < 1.5 ? 1 : 2);
                    ++S.pc_n[shot.cell + 1];
                    // §8.138: outfield opponents in the lane (±1 m of the ball → goal-centre line, between)
                    {
                        const double gx2 = p.team == 0 ? hx : -hx, bx0 = b.pos.x.toDouble(), by0 = b.pos.y.toDouble();
                        const double L = std::hypot(gx2 - bx0, -by0), ux = (gx2 - bx0) / L, uy = -by0 / L;
                        int n1 = 0; double dmin = 99;
                        for (std::uint8_t j = 0; j < N; ++j) {
                            if (W.isKeeper(j) || W.player(j).team == p.team) continue;
                            const double px = W.player(j).pos.x.toDouble() - bx0, py = W.player(j).pos.y.toDouble() - by0;
                            const double along = px * ux + py * uy, perp = std::fabs(-px * uy + py * ux);
                            if (along > 0 && along < L) { if (perp < 1) ++n1; dmin = std::min(dmin, perp); }
                        }
                        shot.lane = std::min(n1, 3);
                        ++S.ln_n[shot.lane]; S.ln_near.push_back(dmin);
                        double bd = 99; bool gs = false;   // the nearest outfield opponent to the shooter
                        for (std::uint8_t j = 0; j < N; ++j) {
                            if (W.isKeeper(j) || W.player(j).team == p.team) continue;
                            const double dd = std::hypot(W.player(j).pos.x.toDouble() - p.pos.x.toDouble(), W.player(j).pos.y.toDouble() - p.pos.y.toDouble());
                            if (dd < bd) { bd = dd; gs = (W.player(j).pos.x.toDouble() - p.pos.x.toDouble()) * (p.team == 0 ? 1 : -1) > 0; }
                        }
                        S.sh_near.push_back(bd); S.sh_gs += gs;
                        const long since = static_cast<long>(W.tickCount() - W.ownedAtTick());
                        S.sh_held.push_back(since / 30.0);
                    }
                    // the save curve: his keeper's gap along the line to the aim
                    for (std::uint8_t j = 0; j < N; ++j)
                        if (W.isKeeper(j) && W.player(j).team != p.team && shot.cell >= 0) {
                            const double g = std::fabs(lo.target.y.toDouble() - W.player(j).pos.y.toDouble());
                            shot.gap = g < 0.5 ? 0 : g < 1 ? 1 : g < 1.5 ? 2 : g < 2 ? 3 : g < 2.5 ? 4 : g < 3 ? 5 : 6;
                        }
                }
                ++S.shots[p.team]; ++S.shot_band[shot.band];
            } else if (shot.on && k > shot.tick) {
                const int def = shot.team ^ 1;
                if (b.owner) {
                    const auto o = *b.owner;
                    ++S.shot_out[W.isKeeper(o) && W.player(o).team == def ? 1 : W.player(o).team == def ? 2 : 4];
                    if (W.isKeeper(o) && W.player(o).team == def) {
                        ++S.pc_k[shot.cell + 1];
                        if (shot.gap >= 0) { ++S.sc_n[shot.band][shot.gap]; ++S.sc_s[shot.band][shot.gap]; }
                    }
                    shot.on = false;
                } else if (W.lastTouchTeam() == def) {
                    ++S.shot_out[2]; shot.on = false;   // a defender's touch (a keeper's parry counts here too)
                    if (!(b.last_kicker < N && W.isKeeper(b.last_kicker))) ++S.ln_b[shot.lane];
                    if (b.last_kicker < N && W.isKeeper(b.last_kicker)) {
                        ++S.pc_p[shot.cell + 1];
                        if (shot.gap >= 0) { ++S.sc_n[shot.band][shot.gap]; ++S.sc_s[shot.band][shot.gap]; }
                    }
                } else if (W.outStage() != 0 || W.restartTeam() != 0xFF) {
                    ++S.shot_out[3]; shot.on = false;
                } else if (k - shot.tick > 150) {
                    ++S.shot_out[4]; shot.on = false;
                }
            }

            // ── concept acts by ownership (StatsBomb's cuts) ──────────────
            const int own = b.owner ? static_cast<int>(*b.owner) : -1;
            auto wsz = [](double tl, double y) { const bool w = std::fabs(y) >= 14; return tl < 18 ? (w ? 1 : 4) : tl < 35 ? (w ? 0 : 2) : (w ? 3 : 5); };
            auto endPass = [&](double ex, double ey, bool ok = false) {
                if (rel.ws && !rel.set && !rel.shot && !rel.cross) {   // §8.155: pass to 18-35w / 35+ / 0-18w / 18-35c / 0-18c
                    const double sgw = rel.team == 0 ? 1.0 : -1.0; const int ez = wsz(hx - ex * sgw, ey);
                    const int cat = ez == 0 ? 0 : (ez == 3 || ez == 5) ? 1 : ez == 1 ? 2 : ez == 2 ? 4 : 6;
                    ++S.ws_as[cat]; if (ok) ++S.ws_ok[cat];
                    if (cat == 2 && rel.why == static_cast<int>(ai::Why::InBehind) && rel.rc_me >= 0) {   // §8.192 RACE
                        const int adv = rel.rc_me - rel.rc_def < -3 ? 0 : rel.rc_me - rel.rc_def < 0 ? 1 : rel.rc_me - rel.rc_def < 3 ? 2 : 3;
                        ++S.rce_n[adv]; if (ok) ++S.rce_ok[adv];
                        S.rce_me.push_back(rel.rc_me); S.rce_def.push_back(rel.rc_def); S.rce_gk.push_back(rel.rc_gk); S.rce_vt.push_back(rel.rc_vt);
                        if (rel.rc_role >= 0) ++S.rce_role[rel.rc_role];
                        if (!ok && b.owner && W.player(*b.owner).team != rel.team) ++S.rce_won_by[W.isKeeper(*b.owner) ? ai::kRoleCount : role(*b.owner)];
                    }
                    if (cat == 2 && rel.why >= 0 && rel.why < ai::kWhyCount) { ++S.dwl_n[rel.why]; if (ok) ++S.dwl_ok[rel.why]; else if (W.outStage() != 0 || W.restartTeam() != 0xFF) ++S.dwl_out[rel.why]; else if (b.owner && W.isKeeper(*b.owner)) ++S.dwl_gk[rel.why]; S.dwl_len[rel.why].push_back(std::hypot(ex - rel.x, ey - rel.y)); }
                }
                if (rel.p < 0 || rel.set || rel.shot) { rel = Rel{}; return; }
                const double sg = rel.team == 0 ? 1.0 : -1.0;
                ++S.passes;
                if (rel.mp_rb >= 0 && rel.mp_pb >= 0)   // §8.184 MARKED PICK
                    for (int g = 0; g <= (ok ? 1 : 0); ++g) { ++S.mp_n[g][rel.mp_rb]; ++S.mp_pk[g][rel.mp_rb][rel.mp_pb]; for (int q = 0; q < 5; ++q) S.mp_av[g][rel.mp_rb][q] += rel.mp_av[q]; }
                {   // §8.180 KICK FOOT: strong v weak by length
                    const double L = std::hypot(ex - rel.x, ey - rel.y);
                    const int lb = L < 15 ? 0 : L < 30 ? 1 : 2, wk = rel.weak ? 1 : 0;
                    ++S.kf_n[wk][lb]; if (ok) ++S.kf_ok[wk][lb];
                    if (lb == 0) { const int wb = rel.wait == 0 ? 0 : rel.wait <= 3 ? 1 : rel.wait <= 8 ? 2 : 3; ++S.kw_n[wb]; if (ok) ++S.kw_ok[wb]; }
                }
                if (std::fabs(ey - rel.y) >= 34) ++S.switches;
                if (rel.cross) ++S.crosses;
                const double stl = hx - rel.x * sg, etl = hx - ex * sg;
                if (ok) {   // §8.191 ARRIVE (benchmarks_statsbomb_cross.py arrive: completed passes ending there)
                    const bool e_in = etl < 18 && std::fabs(ey) >= 14, s_in = stl < 18 && std::fabs(rel.y) >= 14;
                    if (e_in && !s_in) { ++S.ar_pass; if (std::fabs(rel.y) >= 14) ++S.ar_pass_wide; }
                    if (e_in && s_in) ++S.ar_within;
                }
                {   // §8.188 RELEASES BY ZONE (benchmarks_statsbomb_cross.py crosses)
                    const int zx = stl < 6 ? 0 : stl < 18 ? 1 : stl < 30 ? 2 : 3, ay = std::fabs(rel.y) >= 24 ? 0 : std::fabs(rel.y) >= 14 ? 1 : 2;
                    ++S.xz_n[zx][ay]; S.xz_c[zx][ay] += rel.cross;
                }
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
                        rel.weak = W.lastKickWeak(); rel.wait = static_cast<int>(W.lastKickWait());   // §8.180
                        rel.why = static_cast<int>(why);   // §8.191
                        if (why == ai::Why::InBehind || why == ai::Why::IntoSpace || why == ai::Why::Pass) {   // §8.192 RACE: the spot, and who is nearest it at the kick
                            const auto& lo = s.lastOrders()[owner];
                            rel.rc_tx = lo.target.x.toDouble(); rel.rc_ty = lo.target.y.toDouble();
                            const int pt = lo.pass_to < N ? lo.pass_to : -1;
                            if (pt >= 0) {
                                const auto& q = W.player(static_cast<std::uint8_t>(pt));
                                const double dx = rel.rc_tx - q.pos.x.toDouble(), dy = rel.rc_ty - q.pos.y.toDouble();
                                rel.rc_me = std::hypot(dx, dy);
                                rel.rc_vt = rel.rc_me > 0.1 ? (q.vel.x.toDouble() * dx + q.vel.y.toDouble() * dy) / rel.rc_me : 0;
                            }
                            double bd = 1e9; int bj = -1;
                            for (std::uint8_t j = 0; j < N; ++j) {
                                if (W.player(j).team == owner_team) continue;
                                const double d = std::hypot(rel.rc_tx - W.player(j).pos.x.toDouble(), rel.rc_ty - W.player(j).pos.y.toDouble());
                                if (W.isKeeper(j)) { rel.rc_gk = d; continue; }
                                if (d < bd) { bd = d; bj = j; }
                            }
                            rel.rc_def = bd; rel.rc_role = bj >= 0 ? role(bj) : -1;
                        }
                        {   // §8.175 PASS PICK: the man the pass is for v the other mates standing in his zone at the kick
                            const std::uint8_t pt = s.lastOrders()[owner].pass_to;
                            if (!own_set && why != ai::Why::Cross && why != ai::Why::Shoot && pt < N && W.player(pt).team == owner_team) {
                                const double sgp = owner_team == 0 ? 1.0 : -1.0;
                                auto zq = [&](double x, double y) { const double tl = hx - x * sgp; const int b = tl < 18 ? 0 : tl < 35 ? 1 : tl < 52 ? 2 : tl < 70 ? 3 : 4; return b * 2 + (std::fabs(y) < 20.16 ? 0 : 1); };
                                const double px = W.player(owner).pos.x.toDouble(), py = W.player(owner).pos.y.toDouble(), od = hx + px * sgp;
                                const int ob = od < 35 ? 0 : od < 70 ? 1 : 2, oz = zq(px, py);
                                const int ez = zq(W.player(pt).pos.x.toDouble(), W.player(pt).pos.y.toDouble());
                                ++S.pk_n[ob];
                                int kz = 0, near = -1; double nd = 1e9, sum = 0; bool fl[2] = {false, false};
                                for (std::uint8_t j = 0; j < N; ++j) {
                                    if (j == owner || W.player(j).team != owner_team) continue;
                                    const double jx = W.player(j).pos.x.toDouble(), jy = W.player(j).pos.y.toDouble();
                                    if (zq(jx, jy) != ez) continue;
                                    const double d = std::hypot(jx - px, jy - py);
                                    ++kz; sum += d; if (d < nd) { nd = d; near = j; }
                                    fl[jy * py > 0 ? 1 : 0] = true;
                                }
                                if (kz >= 2) {   // §8.184 MARKED PICK: each mate in his zone by his nearest opponent's metres
                                    auto mbin = [](double m) { return m < 2 ? 0 : m < 3.5 ? 1 : m < 5 ? 2 : m < 8 ? 3 : 4; };
                                    auto nopp = [&](std::uint8_t q) { double b = 99; for (std::uint8_t o = 0; o < N; ++o) if (W.player(o).team != owner_team) b = std::min(b, std::hypot(W.player(o).pos.x.toDouble() - W.player(q).pos.x.toDouble(), W.player(o).pos.y.toDouble() - W.player(q).pos.y.toDouble())); return b; };
                                    const double ro = hx + W.player(pt).pos.x.toDouble() * sgp;
                                    rel.mp_rb = ro < 35 ? 0 : ro < 70 ? 1 : 2;
                                    for (std::uint8_t j = 0; j < N; ++j) {
                                        if (j == owner || W.player(j).team != owner_team) continue;
                                        if (zq(W.player(j).pos.x.toDouble(), W.player(j).pos.y.toDouble()) != ez) continue;
                                        const int bq = mbin(nopp(j)); ++rel.mp_av[bq]; if (j == pt) rel.mp_pb = bq;
                                    }
                                }
                                if (kz >= 2) {
                                    ++S.pk_k[ob]; S.pk_even[ob] += 1.0 / kz; if (near == pt) ++S.pk_near[ob];
                                    S.pk_drc[ob] += std::hypot(W.player(pt).pos.x.toDouble() - px, W.player(pt).pos.y.toDouble() - py); S.pk_dm[ob] += sum / kz;
                                    if (oz % 2 == 1 && ez % 2 == 1 && fl[0] && fl[1]) { ++S.pk_w2[ob]; if (W.player(pt).pos.y.toDouble() * py > 0) ++S.pk_same[ob]; }
                                }
                            }
                        }
                        mk.on = !own_set && why != ai::Why::Cross && why != ai::Why::Shoot; mk.p = owner; mk.team = owner_team; mk.peak = 0;
                        if (mk.on) for (std::uint8_t j = 0; j < N && j < 32; ++j) { mk.x[j] = W.player(j).pos.x.toDouble(); mk.y[j] = W.player(j).pos.y.toDouble(); }
                        if (ws_on && !own_set) {   // §8.155
                            const double sgw = owner_team == 0 ? 1.0 : -1.0;
                            ++S.ws_from[wsz(hx - own_px * sgw, own_py)];
                            if (why == ai::Why::Cross) ++S.ws_as[5]; else if (why == ai::Why::Shoot) ++S.ws_as[7]; else rel.ws = true;
                        }
                        ws_on = false;
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
                        if (mate && mk.on && mk.p == rel.p) {   // §8.173: completed — the receiver's and the passer's nearest opponent outfielder where they stood at the kick
                            auto near = [&](int i) { double m = 99; for (std::uint8_t j = 0; j < N && j < 32; ++j) if (W.player(j).team != mk.team && !W.isKeeper(j)) m = std::min(m, std::hypot(mk.x[j] - mk.x[i], mk.y[j] - mk.y[i])); return m; };
                            const double r = near(own), own_d = hx + mk.x[own] * (mk.team == 0 ? 1.0 : -1.0);
                            const int hi = mk.peak >= 1.5 ? 1 : 0, z = own_d < 35 ? 0 : own_d < 70 ? 1 : 2;
                            ++S.mk_n[hi][z]; S.mk_r[hi][z].push_back(r); S.mk_pa[hi][z].push_back(near(mk.p)); S.mk_len[hi][z].push_back(std::hypot(mk.x[own] - mk.x[mk.p], mk.y[own] - mk.y[mk.p]));
                            for (std::uint8_t i = 0; i < N && i < 32; ++i) if (W.player(i).team == mk.team && !W.isKeeper(i) && i != mk.p) {   // every man he could have picked in that zone
                                const double o = hx + mk.x[i] * (mk.team == 0 ? 1.0 : -1.0);
                                if ((o < 35 ? 0 : o < 70 ? 1 : 2) == z) S.mk_al[hi][z].push_back(near(i));
                            }
                            S.mk_2[hi][z] += r < 2; S.mk_35[hi][z] += r < 3.5; S.mk_5[hi][z] += r >= 5;
                        }
                        mk.on = false;
                        from[own] = (mate && !rel.set) ? rel.p : -1; from_t[own] = k;
                        endPass(q.pos.x.toDouble(), q.pos.y.toDouble(), mate && !rel.set && !rel.shot);
                    } else from[own] = -1;
                    if (owner_team >= 0 && q.team != owner_team) loss_tick[owner_team] = k;
                    if (ws_on && owner >= 0 && q.team != owner_team) {   // §8.155: taken off him
                        const double sgw = owner_team == 0 ? 1.0 : -1.0; ++S.ws_from[wsz(hx - own_px * sgw, own_py)]; ++S.ws_as[3];
                    }
                    {   const double sgw = q.team == 0 ? 1.0 : -1.0;
                        ws_on = W.restartTeam() == 0xFF && wsz(hx - q.pos.x.toDouble() * sgw, q.pos.y.toDouble()) == 0;
                        if (ws_on) ++S.ws_n; }
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
            {   // §8.172: a high ball (rose past 4 m since last under 0.5 m) coming down through 2.4 m, in play (benchmarks_tracking_aerial.py)
                const double bz = b.pos.z.toDouble();
                const bool live = W.outStage() == 0 && W.restartTeam() == 0xFF;
                if (mk.on) { mk.peak = std::max(mk.peak, bz); if (!live) mk.on = false; }
                const long kk = static_cast<long>(k);
                for (std::size_t i = 0; i < hb_p.size();) {
                    const bool lost = W.lastTouchTeam() == (hb_p[i].po ^ 1);
                    if (lost || kk - hb_p[i].k >= 90) { if (lost) ++S.hb_lost[hb_p[i].z]; hb_p.erase(hb_p.begin() + static_cast<long>(i)); } else ++i;
                }
                if (!live || bz < 0.5) hb_rose = false;
                if (live && bz < 0.5) { hl_k = kk; for (std::uint8_t j = 0; j < N && j < 32; ++j) { hl_x[j] = W.player(j).pos.x.toDouble(); hl_y[j] = W.player(j).pos.y.toDouble(); } }   // §8.185 the launch
                if (!live) { hl_k = -1; hl_f.clear(); }   // a dead ball: no launch (a throw-in is never launched from the ground)
                {   // §8.185 LOFT FLIGHT v benchmarks_tracking_loft.py: off the ground, past 4 m, to its landing or a touch
                    const double bx3 = b.pos.x.toDouble(), by3 = b.pos.y.toDouble();
                    auto close = [&](bool touched) {
                        if (lf.pk >= 4.0) {
                            const double c = std::hypot(lf.lx - lf.x0, lf.ly - lf.y0);
                            int bi = c < 10 ? -1 : c < 20 ? 0 : c < 30 ? 1 : c < 40 ? 2 : c < 50 ? 3 : c < 70 ? 4 : -1;
                            if (bi >= 0) { ++S.lf_n[bi]; S.lf_ang[bi].push_back(lf.ang); S.lf_pk[bi].push_back(lf.pk); S.lf_v[bi].push_back(lf.v);
                                if (lf.down >= 0) S.lf_dn[bi].push_back(lf.down); if (!touched) S.lf_ld[bi].push_back((kk - lf.k0) / 30.0); }
                        }
                        lf.on = false;
                    };
                    if (!live) lf.on = false;
                    else if (!lf.on) {
                        if (lf.lz < 0.5 && bz >= 0.5 && !b.owner && W.restartTeam() == 0xFF) {
                            lf.on = true; lf.k0 = kk - 1; lf.x0 = lf.lx; lf.y0 = lf.ly; lf.pk = bz; lf.down = -1; lf.kicker = b.last_kicker;
                            const double vx = b.vel.x.toDouble(), vy = b.vel.y.toDouble(), vz = b.vel.z.toDouble(), vh = std::hypot(vx, vy);
                            lf.ang = std::atan2(vz, std::max(0.1, vh)) * 57.29578; lf.v = std::hypot(vh, vz);
                        }
                    } else if (b.owner || b.last_kicker != lf.kicker) close(true);
                    else {
                        lf.pk = std::max(lf.pk, bz);
                        if (lf.down < 0 && b.vel.z.raw < 0 && bz <= 2.4) lf.down = (kk - lf.k0) / 30.0;
                        if (bz < 0.5) { lf.lx = bx3; lf.ly = by3; close(false); }
                    }
                    if (lf.on) { lf.lx = bx3; lf.ly = by3; }
                    lf.lz = bz; if (!lf.on) { lf.lx = bx3; lf.ly = by3; }
                }
                if (live && bz < 0.5) hl_f.clear();
                else if (live && hl_k >= 0 && (kk - hl_k) % 6 == 0 && hl_f.size() < 40) {
                    HlF f{}; f.k = kk;
                    for (std::uint8_t j = 0; j < N && j < 32; ++j) {
                        const auto& pj = W.player(j); f.x[j] = static_cast<float>(pj.pos.x.toDouble()); f.y[j] = static_cast<float>(pj.pos.y.toDouble());
                        f.tx[j] = static_cast<float>(s.lastOrders()[j].target.x.toDouble()); f.ty[j] = static_cast<float>(s.lastOrders()[j].target.y.toDouble());
                        f.v[j] = static_cast<float>(std::hypot(pj.vel.x.toDouble(), pj.vel.y.toDouble()));
                        const int w = static_cast<int>(s.lastOrders()[j].why); f.why[j] = static_cast<std::uint8_t>(w < ai::kWhyCount ? w : ai::kWhyCount);
                    }
                    hl_f.push_back(f);
                }
                if (live && bz > 4.0) hb_rose = true;
                if (live && hb_rose && hb_pz > 2.4 && bz <= 2.4 && W.lastTouchTeam() <= 1) {
                    hb_rose = false;
                    const int po = W.lastTouchTeam();
                    const double bx2 = b.pos.x.toDouble(), by2 = b.pos.y.toDouble();
                    double na = 99, nd = 99;
                    for (std::uint8_t j = 0; j < N; ++j) {
                        if (W.isKeeper(j)) continue;
                        const double dd = std::hypot(W.player(j).pos.x.toDouble() - bx2, W.player(j).pos.y.toDouble() - by2);
                        if (W.player(j).team == po) na = std::min(na, dd); else nd = std::min(nd, dd);
                    }
                    const double own = hx + bx2 * (po == 0 ? 1.0 : -1.0);   // m off the kicker's own goal
                    const int z = own < 35 ? 0 : own < 70 ? 1 : 2;
                    ++S.hb_n[z]; S.hb_a[z].push_back(na); S.hb_d[z].push_back(nd);
                    {   // what it was: the kicker's order if his side's last kick was within 4 s, else a header / deflection
                        const bool kicked = last_kick_team == po && static_cast<long>(k) - last_kick_k < 120;
                        ++S.hb_why[z][kicked ? last_kick_why : ai::kWhyCount];
                        if (kicked) S.hb_from[z].push_back(last_kick_own);
                    }
                    {   // the other side's chaser then: his metres off the ball and his target's; and his metres off it at the kick
                        for (std::uint8_t j = 0; j < N; ++j) if (W.player(j).team != po && !W.isKeeper(j) && s.lastOrders()[j].why == ai::Why::Chase) {
                            ++S.hb_c[z];
                            S.hb_cd[z].push_back(std::hypot(W.player(j).pos.x.toDouble() - bx2, W.player(j).pos.y.toDouble() - by2));
                            S.hb_ct[z].push_back(std::hypot(s.lastOrders()[j].target.x.toDouble() - bx2, s.lastOrders()[j].target.y.toDouble() - by2));
                            S.hb_cv[z].push_back(std::hypot(W.player(j).vel.x.toDouble(), W.player(j).vel.y.toDouble()));
                            break;
                        }
                    }
                    {   // §8.174: the other side's nearest outfielder at the drop — his job and metres off it; and the man of the
                        // kicker's side nearest the ball: is he marked, and how far is his marker
                        int jn = -1, ja = -1; double dn = 1e9, da = 1e9;
                        for (std::uint8_t j = 0; j < N; ++j) {
                            if (W.isKeeper(j)) continue;
                            const double dd = std::hypot(W.player(j).pos.x.toDouble() - bx2, W.player(j).pos.y.toDouble() - by2);
                            if (W.player(j).team != po && dd < dn) { dn = dd; jn = j; }
                            if (W.player(j).team == po && dd < da) { da = dd; ja = j; }
                        }
                        if (jn >= 0 && ja >= 0 && hl_k >= 0 && jn < 32 && ja < 32) {   // §8.185 AT THE LAUNCH
                            const double d0 = std::hypot(hl_x[jn] - bx2, hl_y[jn] - by2), t0 = (kk - hl_k) / 30.0;
                            S.hl_d[z].push_back(d0); S.hl_a[z].push_back(std::hypot(hl_x[ja] - bx2, hl_y[ja] - by2));
                            S.hl_da[z].push_back(std::hypot(hl_x[jn] - hl_x[ja], hl_y[jn] - hl_y[ja])); S.hl_t[z].push_back(t0);
                            S.hl_v[z].push_back((d0 - dn) / std::max(0.2, t0));
                            for (const auto& f : hl_f) {   // §8.185 the defender through the flight, 0.5 s bins since the launch
                                const int bi = std::min(7, static_cast<int>((f.k - hl_k) / 15));
                                ++S.hf_n[z][bi]; ++S.hf_w[z][bi][f.why[jn]];
                                S.hf_d[z][bi].push_back(std::hypot(f.x[jn] - bx2, f.y[jn] - by2)); S.hf_t[z][bi].push_back(std::hypot(f.tx[jn] - bx2, f.ty[jn] - by2)); S.hf_v[z][bi].push_back(f.v[jn]);
                                if (f.why[jn] == static_cast<int>(ai::Why::Chase)) { S.hf_cd[z][bi].push_back(std::hypot(f.x[jn] - bx2, f.y[jn] - by2)); S.hf_cv[z][bi].push_back(f.v[jn]); }
                            }
                            if (!hl_f.empty()) {
                                ++S.hf_all[z]; double c0 = -1;
                                for (const auto& f : hl_f) if (f.why[jn] == static_cast<int>(ai::Why::Chase)) { c0 = (f.k - hl_k) / 30.0; break; }
                                if (c0 < 0) ++S.hf_never[z]; else S.hf_c0[z].push_back(c0);
                            }
                        }
                        if (jn >= 0) { const int w = static_cast<int>(s.lastOrders()[jn].why); if (w < ai::kWhyCount) { ++S.hn_why[z][w]; S.hn_d[z][w].push_back(dn); } }
                        if (ja >= 0) {
                            ++S.hm_n[z];
                            for (std::uint8_t j = 0; j < N; ++j) if (W.player(j).team != po && s.lastOrders()[j].why == ai::Why::Mark && s.lastOrders()[j].other == ja) {
                                ++S.hm_on[z]; S.hm_d[z].push_back(std::hypot(W.player(j).pos.x.toDouble() - W.player(ja).pos.x.toDouble(), W.player(j).pos.y.toDouble() - W.player(ja).pos.y.toDouble()));
                            }
                        }
                    }
                    if (na < 2 && nd < 2) ++S.hb_both[z];
                    if (nd < 2) ++S.hb_o2[z];
                    if (na >= 3 && nd >= 3) ++S.hb_none[z];
                    hb_p.push_back(HbP{kk, po, z});
                }
                hb_pz = bz;
            }
            if (W.lastTouchTeam() <= 1 && W.lastTouchTeam() != rc_team) { rc_team = W.lastTouchTeam(); rc_k = static_cast<long>(k); }
            if (W.outStage() != 0 || W.restartTeam() != 0xFF) dead_last = static_cast<long>(k);   // §8.162
            // ── 5 Hz, in play, the last team on the ball (as DFL flags it) ──
            if (k % 6 != 0 || W.outStage() != 0 || W.restartTeam() != 0xFF || W.lastTouchTeam() > 1) continue;
            const int a = W.lastTouchTeam(), dteam = a ^ 1;
            {   // §8.186 GOAL-SIDE (benchmarks_tracking_goalside.py): ball under 7 m/s within 30 m of their goal centre
                const double gx = dteam == 0 ? -hx : hx, bx = b.pos.x.toDouble(), by = b.pos.y.toDouble();
                const double db = std::hypot(gx - bx, by);
                if (db < 30 && std::hypot(b.vel.x.toDouble(), b.vel.y.toDouble()) < 7) {
                    const int bb = db < 12 ? 0 : db < 18 ? 1 : db < 25 ? 2 : 3;
                    int g = 0, dl = 0, bxn = 0; double deep = 1e9;
                    for (std::uint8_t j = 0; j < N; ++j) {
                        if (W.player(j).team != dteam || W.isKeeper(j)) continue;
                        const double px = W.player(j).pos.x.toDouble(), py = W.player(j).pos.y.toDouble();
                        if (std::hypot(gx - px, py) < db) ++g;
                        if (std::fabs(gx - px) < std::fabs(gx - bx)) { ++dl; S.gsd_ay[bb].push_back(std::fabs(py - by)); }
                        if (std::fabs(gx - px) < 16.5 && std::fabs(py) < 20.16) ++bxn;
                        deep = std::min(deep, std::fabs(gx - px));
                    }
                    if (std::getenv("GAME_GS_TRACE") && (bb == 0 || std::getenv("GAME_GS_TRACE")[0] == 'a')) {   // §8.186: who is where (=all: every band)
                        const double sg3 = dteam == 0 ? -1.0 : 1.0;   // + toward their (dteam's) goal line
                        std::fprintf(stderr, "gs m%d k%ld ball %.1f,%.1f v %.1f owner %d since %.1fs g %d |", m, static_cast<long>(k), hx - bx * sg3, by,
                                     std::hypot(b.vel.x.toDouble(), b.vel.y.toDouble()), b.owner ? static_cast<int>(*b.owner) : -1, (static_cast<long>(k) - rc_k) / 30.0, g);
                        for (std::uint8_t j = 0; j < N; ++j) {
                            if (W.player(j).team != dteam) continue;
                            const auto& lo = s.lastOrders()[j];
                            const double tx = lo.target.x.toDouble() - W.player(j).pos.x.toDouble(), ty = lo.target.y.toDouble() - W.player(j).pos.y.toDouble(), tl = std::max(1e-6, std::hypot(tx, ty));
                            const double vx = W.player(j).vel.x.toDouble(), vy = W.player(j).vel.y.toDouble();
                            std::fprintf(stderr, " %s%d:%.1f,%.1f>%.1f,%.1f@%.1f/%.1f/%.1f %s", W.isKeeper(j) ? "GK" : "", role(j), hx - W.player(j).pos.x.toDouble() * sg3, W.player(j).pos.y.toDouble(),
                                         hx - lo.target.x.toDouble() * sg3, lo.target.y.toDouble(), std::hypot(vx, vy), (vx * tx + vy * ty) / tl,
                                         std::hypot(lo.move.move.x.toDouble(), lo.move.move.y.toDouble()) * W.player(j).max_speed.toDouble(), ai::kWhyNames[static_cast<int>(lo.why)]);
                        }
                        std::fprintf(stderr, "\n");
                    }
                    ++S.gsd_n[bb]; S.gsd_g[bb].push_back(g); S.gsd_deep[bb].push_back(std::fabs(gx - bx) - deep); S.gsd_dl[bb].push_back(dl); S.gsd_box[bb].push_back(bxn); S.gsd_by[bb].push_back(std::fabs(by));
                    ++S.gsd_k[bb][g == 0 ? 0 : g <= 2 ? 1 : g <= 4 ? 2 : 3];
                }
            }
            {   // §8.173 MARKING, EVERY FRAME (benchmarks_tracking_markers.py): each attacker's nearest defender; each CB/FB/DM's nearest attacker
                const int st = (static_cast<long>(k) - rc_k) >= 180 ? 1 : 0;
                const double ds = dteam == 0 ? 1.0 : -1.0, gx = -ds * hx, bx3 = b.pos.x.toDouble(), by3 = b.pos.y.toDouble();
                for (std::uint8_t j = 0; j < N; ++j) {
                    if (W.isKeeper(j)) continue;
                    const auto& p = W.player(j); const double px = p.pos.x.toDouble(), py = p.pos.y.toDouble();
                    double dd = 99, qx = 0, qy = 0;
                    for (std::uint8_t i = 0; i < N; ++i) if (!W.isKeeper(i) && W.player(i).team != p.team) {
                        const double e = std::hypot(W.player(i).pos.x.toDouble() - px, W.player(i).pos.y.toDouble() - py);
                        if (e < dd) { dd = e; qx = W.player(i).pos.x.toDouble(); qy = W.player(i).pos.y.toDouble(); }
                    }
                    if (p.team == a) {
                        const double o = hx + px * ds; const int z = o < 18 ? 0 : o < 35 ? 1 : o < 52 ? 2 : 3, nb = std::hypot(bx3 - px, by3 - py) < 20 ? 0 : 1;
                        auto add = [&](int s2) { ++S.mf_n[s2][z][nb]; S.mf_d[s2][z][nb].push_back(dd); S.mf_2[s2][z][nb] += dd < 2; S.mf_gs[s2][z][nb] += std::hypot(qx - gx, qy) < std::hypot(px - gx, py); };
                        add(0); if (st) add(1);
                        ++S.mf_all[z];
                        for (std::uint8_t i = 0; i < N; ++i) if (W.player(i).team != p.team && s.lastOrders()[i].why == ai::Why::Mark && s.lastOrders()[i].other == j) {
                            const double mx = W.player(i).pos.x.toDouble(), my = W.player(i).pos.y.toDouble();
                            ++S.mf_mk[z]; S.mf_md[z].push_back(std::hypot(mx - px, my - py)); S.mf_mgs[z] += std::hypot(mx - gx, my) < std::hypot(px - gx, py); break;
                        }
                    } else {
                        const int r = role(j); if (r > 2) continue;
                        const int bb = std::min(4, std::max(0, static_cast<int>((hx + bx3 * ds) / 18)));
                        ++S.mf_cn[r][bb]; S.mf_cb[r][bb].push_back(dd); S.mf_c3[r][bb] += dd < 3;
                    }
                }
            }
            if (b.owner && W.player(*b.owner).team == a) {   // §8.189 SLIDE BY ROLE (benchmarks_tracking_slide.py): ball 25-60 m off their line
                const double tl2 = hx - b.pos.x.toDouble() * (a == 0 ? 1.0 : -1.0), by2 = b.pos.y.toDouble();
                if (tl2 >= 25 && tl2 < 60)
                    for (std::uint8_t j = 0; j < N && j < 32; ++j) {
                        if (W.isKeeper(j) || W.player(j).team != a || j == *b.owner) continue;
                        const double y = W.player(j).pos.y.toDouble();
                        sl_b[j] += by2; sl_y[j] += y; sl_bb[j] += by2 * by2; sl_by[j] += by2 * y; ++sl_c[j];
                        if (std::fabs(by2) >= 14) S.sl_w[role(j)][(y > 0) == (by2 > 0) ? 0 : 1].push_back(std::fabs(y));
                    }
            }
            {   // §8.191 ARRIVE: a carrier who goes into their crossing zone with it at his feet
                const int ow = b.owner ? static_cast<int>(*b.owner) : -1;
                bool in = false;
                if (ow >= 0) {
                    const double sgo = W.player(ow).team == 0 ? 1.0 : -1.0, px = W.player(ow).pos.x.toDouble(), py = W.player(ow).pos.y.toDouble();
                    in = hx - px * sgo < 18 && std::fabs(py) >= 14;
                    if (ow == ar_own && in && !ar_in) ++S.ar_carry;
                }
                ar_own = ow; ar_in = in;
            }
            {   // §8.188 INWARD (benchmarks_tracking_inward.py): the attack's ball within 35 m of the goal line it attacks
                const double bx = b.pos.x.toDouble(), by = b.pos.y.toDouble();
                if (iw_k == static_cast<long>(k) - 6 && iw_a == a) {
                    const double gx = a == 0 ? hx : -hx, v = std::hypot(bx - iw_x, by - iw_y) / 0.2;
                    if (std::fabs(gx - iw_x) >= 35 && std::fabs(gx - bx) < 35 && v <= 40)
                        ++S.iw_e[v >= 7 ? 1 : 0][std::fabs(by) < 9 ? 0 : std::fabs(by) < 20 ? 1 : 2];
                    if (std::fabs(gx - iw_x) < 35 && v <= 40) {
                        const int yb = std::fabs(iw_y) < 9 ? 0 : std::fabs(iw_y) < 20 ? 1 : 2, kk = v >= 7 ? 1 : 0;
                        S.iw_n[kk][yb] += 1; S.iw_dy[kk][yb] += std::fabs(by) - std::fabs(iw_y); S.iw_dx[kk][yb] += std::fabs(gx - iw_x) - std::fabs(gx - bx);
                    }
                }
                iw_k = static_cast<long>(k); iw_a = a; iw_x = bx; iw_y = by;
            }
            {   // §8.187 HOLD SPOT
                const int fs = b.owner ? (W.player(*b.owner).team == a ? 0 : -1) : 1;
                for (std::uint8_t j = 0; j < N && j < 32; ++j) {
                    const auto& lo = s.lastOrders()[j];
                    const bool on = fs >= 0 && !W.isKeeper(j) && W.player(j).team == dteam && lo.why == ai::Why::Hold;
                    const double tx = lo.target.x.toDouble(), ty = lo.target.y.toDouble();
                    const double px = W.player(j).pos.x.toDouble(), py = W.player(j).pos.y.toDouble();
                    if (on && hs_k[j] == static_cast<long>(k) - 6) {
                        const double sp = std::hypot(tx - hs_tx[j], ty - hs_ty[j]) / 0.2, mv = std::hypot(px - hs_px[j], py - hs_py[j]) / 0.2;
                        const double lag0 = std::hypot(hs_tx[j] - hs_px[j], hs_ty[j] - hs_py[j]);
                        const double mid = std::hypot(tx - hs_px[j], ty - hs_py[j]), lag1 = std::hypot(tx - px, ty - py);
                        auto bin = [](double v) { return v < 2 ? 0 : v < 5 ? 1 : v < 10 ? 2 : 3; };
                        ++S.hs_n[fs]; ++S.hs_sp[fs][bin(sp)]; ++S.hs_mv[fs][bin(mv)];
                        S.hs_rl[fs][role(j)].push_back(lag1);
                        S.hs_lag[fs] += lag1; S.hs_add[fs] += mid - lag0; S.hs_close[fs] += mid - lag1;
                        if (sp >= 10) S.hs_jump_add[fs] += mid - lag0;
                    }
                    if (on) { hs_k[j] = static_cast<long>(k); hs_tx[j] = tx; hs_ty[j] = ty; hs_px[j] = px; hs_py[j] = py; } else hs_k[j] = -1;
                }
            }
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
            {   // §8.171: the defending side's most advanced outfielder, m off its own line, by the ball's band
                double top = -1e9; const double ds = dteam == 0 ? 1.0 : -1.0;
                for (std::uint8_t j = 0; j < N; ++j) if (W.player(j).team == dteam && !W.isKeeper(j)) top = std::max(top, hx + W.player(j).pos.x.toDouble() * ds);
                S.bk_top[std::min(9, std::max(0, static_cast<int>(tl / 10)))].push_back(top);
            }
            {   // §8.172: the side in possession's own line (second-last, keeper in), m off its goal (benchmarks_tracking_turnline.py)
                double l1 = 1e9, l2 = 1e9;
                for (std::uint8_t j = 0; j < N; ++j) if (W.player(j).team == a) {
                    const double d = hx + W.player(j).pos.x.toDouble() * sg; if (d < l1) { l2 = l1; l1 = d; } else if (d < l2) l2 = d; }
                const double bb = hx + bx * sg;   // ball m off its own goal
                if (tp_k >= 0 && (tn_k != static_cast<long>(k) - 6 || a != tp_w || static_cast<long>(k) - tp_k >= 60)) {   // resolve: kept 2 s+ (or dead after 2 s+)
                    const long kept_to = (tn_k == static_cast<long>(k) - 6 && a == tp_w) ? static_cast<long>(k) : tn_k;
                    if (kept_to - tp_k >= 60) { ++S.lk_k[tp_ab][tp_kind]; ++S.tn_nk[tp_z]; S.tn_gk[tp_z].emplace_back(tp_b5, tp_L); S.tn_dk[tp_z].push_back(tp_du); }
                    tp_k = -1;
                }
                {   // a spell won in play: resolve the old one when it ends, open the new one on a win
                    const long kk = static_cast<long>(k);
                    const bool cont = ws_k >= 0 && ws_last == kk - 6;
                    if (ws_k >= 0 && (!cont || a != ws_a)) {
                        const double du = (ws_last - ws_k) / 30.0; const bool lost = cont && a != ws_a;
                        if (du >= 2) {
                            ++S.wsp_n[ws_z]; const double Ts[3] = {3, 6, 10};
                            for (int t = 0; t < 3; ++t) if (lost && du < Ts[t]) ++S.wsp_l[ws_z][t];
                            if (ws_f3 < 1e8) S.wsp_f[ws_z][0].push_back(ws_f3);
                            if (ws_f6 < 1e8) S.wsp_f[ws_z][1].push_back(ws_f6);
                        }
                        ws_k = -1;
                    }
                    if (ws_k < 0 && tn_k == kk - 6 && tn_a == (a ^ 1)) { ws_k = kk; ws_a = a; ws_b = bb; ws_z = bb < 35 ? 0 : bb < 52 ? 1 : bb < 70 ? 2 : 3; ws_f3 = ws_f6 = 1e9; }
                    if (ws_k >= 0 && a == ws_a) { ws_last = kk; if (kk - ws_k == 90) ws_f3 = bb - ws_b; if (kk - ws_k == 180) ws_f6 = bb - ws_b; }
                }
                if (tn_k == static_cast<long>(k) - 6 && tn_a == (a ^ 1)) {   // it lost it, unbroken in play: the frame before
                    const int z = tn_bb < 35 ? 0 : tn_bb < 52 ? 1 : tn_bb < 70 ? 2 : 3;
                    ++S.tn_n[z]; S.tn_L[z].push_back(tn_L); S.tn_b[z].push_back(tn_bb); S.tn_d[z].push_back(tn_du);
                    if (tn_fw < 1e8) S.tn_f[z].push_back(tn_fw);
                    S.tn_g[z].emplace_back(std::min(24, std::max(0, static_cast<int>(tn_bb / 5))), tn_L);
                    {   // the ball at the change: kicked (8+ m/s over the last 0.2 s) on the ground / in the air (1.5 m+, then or now) / at feet
                        const double spd = pb_k == static_cast<long>(k) - 12 ? 5 * std::hypot(pb_x[1] - pb_x[0], pb_y[1] - pb_y[0]) : 0.0;
                        tp_kind = spd >= 8 ? (std::max(pb_z, b.pos.z.toDouble()) >= 1.5 ? 1 : 0) : 2;
                        tp_ab = tn_du < 3 ? 0 : tn_du < 6 ? 1 : 2;
                        ++S.lk_n[tp_ab][tp_kind];
                    }
                    tp_k = static_cast<long>(k); tp_w = a; tp_z = z; tp_b5 = std::min(24, std::max(0, static_cast<int>(tn_bb / 5))); tp_L = tn_L; tp_du = tn_du;
                }
                pb_x[0] = pb_x[1]; pb_y[0] = pb_y[1]; pb_x[1] = bx; pb_y[1] = by; pb_z = b.pos.z.toDouble(); pb_k = static_cast<long>(k) - 6;
                if (l2 < 1e8) {
                    const int b5 = std::min(24, std::max(0, static_cast<int>(bb / 5)));
                    S.tn_as[b5] += l2; ++S.tn_an[b5]; ++S.tn_z[bb < 35 ? 0 : bb < 52 ? 1 : bb < 70 ? 2 : 3];
                    tn_k = static_cast<long>(k); tn_a = a; tn_bb = bb; tn_L = l2; tn_du = (static_cast<long>(k) - rc_k) / 30.0;
                    tn_fw = (then_ok && rat[rj] == a && static_cast<long>(k) - rc_k >= 90) ? bb - (hx + rbx[rj] * sg) : 1e9;
                }
            }
            {   // shapes
                const int bd = std::min(9, std::max(0, static_cast<int>(tl / 10)));   // ball metres off the defenders' own line
                const int bp = std::min(9, std::max(0, static_cast<int>(tl / 10)));
                double dm = 0, pm = 0, back = -1e9, front = 1e9; int dn = 0, pn = 0;
                // §8.142: the ball's speed at the defenders' line over the last second (5 ring entries back)
                const int r1 = static_cast<int>(((k / 6) + 11) % 16);
                const bool lag_ok = bd < 5 && rk[r1] == static_cast<long>(k) - 30 && (static_cast<long>(k) - rc_k) >= 180;
                const double vcome = lag_ok ? (hx - rbx[r1] * sg) - tl : 0.0;
                const int lvb = vcome < -2 ? 0 : vcome < 2 ? 1 : vcome < 5 ? 2 : 3;
                if (lag_ok) ++S.dl_n[bd][lvb];
                const bool plag_ok = bd < 5 && rk[r1] == static_cast<long>(k) - 30 && (static_cast<long>(k) - rc_k) >= 30;
                const double pv = plag_ok ? (hx - rbx[r1] * sg) - tl : 0.0;
                const int pvb = pv < -2 ? 0 : pv < 2 ? 1 : pv < 5 ? 2 : 3;
                double cbs_y[4] = {}, fbs_y[4] = {}, wds_y[4] = {}, dms_y[4] = {}; int cbs_n = 0, fbs_n = 0, wds_n = 0, dms_n = 0;
                for (std::uint8_t j = 0; j < N; ++j) {
                    if (W.isKeeper(j)) continue;
                    const auto& q = W.player(j);
                    const int r = role(j);
                    if (q.team == dteam) {
                        const double v = hx + q.pos.x.toDouble() * (dteam == 0 ? 1.0 : -1.0);   // off his own line
                        S.ds_s[bd][r] += v; ++S.ds_n[bd][r]; dm += v; ++dn;
                        { const int ph = (static_cast<long>(k) - rc_k) >= 180 ? 0 : 1; S.dp_s[ph][bd][r] += v; ++S.dp_n[ph][bd][r]; }
                        if (lag_ok) { S.dl_s[bd][lvb][r] += v; ++S.dl_k[bd][lvb][r]; }
                        if (r == 0) { cbs_y[cbs_n < 4 ? cbs_n : 3] = q.pos.y.toDouble(); ++cbs_n; }
                        if (r == 1) { fbs_y[fbs_n < 4 ? fbs_n : 3] = q.pos.y.toDouble(); ++fbs_n; }
                        if (r == 4) { wds_y[wds_n < 4 ? wds_n : 3] = q.pos.y.toDouble(); ++wds_n; }
                        if (r == 2) { dms_y[dms_n < 4 ? dms_n : 3] = q.pos.y.toDouble(); ++dms_n; }
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
                        if (plag_ok) { S.pl_s[bd][pvb][r] += v; ++S.pl_k[bd][pvb][r]; }
                        if (plag_ok && pvb == 1) {
                            const auto& lo = s.lastOrders()[j];
                            const int wk = lo.why == ai::Why::Hold ? 0 : lo.why == ai::Why::AttackBox ? 1 : 2;
                            ++S.sh_n[bd][r][wk]; S.sh_at[bd][r][wk] += v; S.sh_tg[bd][r][wk] += hx - lo.target.x.toDouble() * sg;
                        }
                        back = std::max(back, v); front = std::min(front, v);
                    }
                }
                if (dn) { ++S.ds_f[bd]; S.ds_mid[bd] += dm / dn; }
                {   // §8.144: our most advanced outfielder v their offside line (second-last, keeper in, or the ball)
                    double l1 = 1e9, l2 = 1e9, f1 = 1e9, f2 = 1e9, fy = 0; int fj = -1;
                    for (std::uint8_t j = 0; j < N; ++j) {
                        const double ptl = hx - W.player(j).pos.x.toDouble() * sg;
                        if (W.player(j).team == dteam) { if (ptl < l1) { l2 = l1; l1 = ptl; } else if (ptl < l2) l2 = ptl; }
                        else if (!W.isKeeper(j)) { if (ptl < f1) { f2 = f1; f1 = ptl; fj = j; fy = W.player(j).pos.y.toDouble(); } else if (ptl < f2) f2 = ptl; }
                    }
                    if (fj >= 0 && f2 < 1e8 && l2 < 1e8) {
                        const double line = std::min(l2, tl), sh = f1 - line;
                        {   // §8.145: every man of ours by gap, and runs (0-12 m short or past, 4+ m/s at goal, 0.6 s+)
                            const int zq = tl < 18 ? 0 : tl < 35 ? 1 : tl < 52 ? 2 : 3;
                            ++S.gb_f[zq];
                            auto closeRun = [&](int j) {
                                if (S.rn_k[j] >= 3) {
                                    ++S.rn_n[S.rn_z[j]]; ++S.rn_r[role(static_cast<std::uint8_t>(j))];
                                    S.rn_g0.push_back(S.rn_s0[j]); S.rn_min.push_back(S.rn_sm[j]); S.rn_len.push_back(0.2 * S.rn_k[j]);
                                    if (S.rn_sm[j] < 0) ++S.rn_past;
                                    ++S.rn_nb[S.rn_b[j]]; S.rn_minb[S.rn_b[j]].push_back(S.rn_sm[j]);
                                    if (S.rn_b[j] == 0) ++S.rn_whn[S.rn_wh[j]];
                                    S.rn_wm[S.rn_wh[j]].push_back(S.rn_sm[j]); S.rn_wt[S.rn_wh[j]].push_back(S.rn_tg[j]);
                                }
                                S.rn_k[j] = 0;
                            };
                            {   // §8.146: each man's spell (one live possession; frames with the ball 18-52 m out, gap under 70)
                                auto flush = [&](int j) {
                                    if (S.sp_k[j] >= 25) {
                                        const double m = S.sp_s[j] / S.sp_k[j]; const int r = role(static_cast<std::uint8_t>(j));
                                        S.sp_mean[r].push_back(m); S.sp_w[r] += S.sp_ss[j] - S.sp_k[j] * m * m; S.sp_wn[r] += S.sp_k[j];
                                    }
                                    S.sp_s[j] = S.sp_ss[j] = 0; S.sp_k[j] = 0;
                                };
                                if (a != S.sp_att || S.sp_last_k != static_cast<long>(k) - 6) {
                                    for (int j = 0; j < 32; ++j) flush(j);
                                    S.sp_att = a; ++S.sp_id;
                                }
                                S.sp_last_k = static_cast<long>(k);
                                if (tl >= 18 && tl < 52)
                                    for (std::uint8_t j = 0; j < N && j < 32; ++j) {
                                        if (W.player(j).team == dteam || W.isKeeper(j)) continue;
                                        const double gp = hx - W.player(j).pos.x.toDouble() * sg - line;
                                        if (gp > 70) continue;
                                        S.sp_s[j] += gp; S.sp_ss[j] += gp * gp; ++S.sp_k[j];
                                    }
                            }
                            for (std::uint8_t j = 0; j < N && j < 32; ++j) {
                                if (W.player(j).team == dteam || W.isKeeper(j)) continue;
                                const double gp = hx - W.player(j).pos.x.toDouble() * sg - line;
                                const double vg = W.player(j).vel.x.toDouble() * sg;
                                const int gq = static_cast<int>(std::floor((gp + 4) / 2));
                                if (gq >= 0 && gq < 11) { ++S.gb_k[zq][gq]; S.gb_v[zq][gq] += vg; }
                                const bool onrun = s.lastOrders()[j].why == ai::Why::RunLine;
                                if (onrun) ++S.run_why;
                                if (onrun && !S.run_was[j]) ++S.run_st[role(j)];
                                S.run_was[j] = onrun;
                                if (!onrun && gp >= 0 && gp < 12) {
                                    ++S.run_c[0];
                                    if (b.owner) ++S.run_c[1];
                                    if (b.vel.x.toDouble() * sg < 2) { ++S.run_c[2]; ++S.run_el[role(j)]; }
                                }
                                S.rq[zq][role(j)].push_back(static_cast<float>(gp));
                                const bool cont = S.rn_k[j] > 0 && S.rn_last[j] == static_cast<long>(k) - 6;
                                if (S.rn_k[j] > 0 && !cont) closeRun(j);
                                if (gp < 12 && vg >= 4) {
                                    if (S.rn_k[j] == 0) {
                                        S.rn_s0[j] = gp; S.rn_sm[j] = gp; S.rn_z[j] = zq;
                                        const int rb1 = static_cast<int>(((k / 6) + 11) % 16);   // the ball 1 s ago
                                        S.rn_b[j] = (rk[rb1] == static_cast<long>(k) - 30 && (hx - rbx[rb1] * sg) - tl >= 2) ? 1 : 0;
                                        const auto& PO = s.brain().possession();
                                        const std::uint8_t tm_ = W.player(j).team;
                                        S.rn_wh[j] = PO.front(tm_, 0) == j ? ai::kWhyCount : PO.front(tm_, 1) == j ? ai::kWhyCount + 1
                                                   : static_cast<int>(s.lastOrders()[j].why);
                                    }
                                    ++S.rn_k[j]; if (gp < S.rn_sm[j]) S.rn_sm[j] = gp; S.rn_last[j] = static_cast<long>(k);
                                    S.rn_tg[j] = hx - s.lastOrders()[j].target.x.toDouble() * sg - line;   // §8.193: his target's gap, last frame of the run
                                } else if (S.rn_k[j] > 0) closeRun(j);
                            }
                        }
                        {   // §8.146: their line moves over 1 s (benchmarks_tracking_linegap.py): our men 0-15 m short 1 s ago, dA v dL
                            const int rb1 = static_cast<int>(((k / 6) + 11) % 16);
                            if (rk[rb1] == static_cast<long>(k) - 30 && rat[rb1] == a && tl >= 18 && tl < 52) {
                                double m1 = 1e9, m2 = 1e9;
                                for (std::uint8_t j = 0; j < N && j < 32; ++j) if (W.player(j).team == dteam) {
                                    const double ptl = hx - rpx[rb1][j] * sg;
                                    if (ptl < m1) { m2 = m1; m1 = ptl; } else if (ptl < m2) m2 = ptl;
                                }
                                const double L0 = std::min(m2, hx - rbx[rb1] * sg), dL = line - L0;
                                const int bm = (hx - rbx[rb1] * sg) - tl >= 2 ? 1 : 0;
                                const int kq = dL < -2 ? 0 : dL < -0.5 ? 1 : dL <= 0.5 ? 2 : dL <= 2 ? 3 : 4;
                                ++S.lg_n[bm][kq]; S.lg_f[bm][kq].push_back(static_cast<float>(sh));
                                for (std::uint8_t j = 0; j < N && j < 32; ++j) {
                                    if (W.player(j).team == dteam || W.isKeeper(j)) continue;
                                    const double A1 = hx - W.player(j).pos.x.toDouble() * sg, A0 = hx - rpx[rb1][j] * sg;
                                    if (A0 - L0 > 15) continue;
                                    const double dA = A1 - A0;
                                    for (int rr : {role(j), ai::kRoleCount}) {
                                        ++S.lg_m[bm][kq][rr]; S.lg_dA[bm][kq][rr] += dA; S.lg_dg[bm][kq][rr] += (A1 - line) - (A0 - L0);
                                        S.lg_xy[bm][rr] += dA * dL; S.lg_xx[bm][rr] += dL * dL; S.lg_sx[bm][rr] += dL; S.lg_sy[bm][rr] += dA; ++S.lg_s1[bm][rr];
                                        S.lg_g[bm][kq][rr].push_back(static_cast<float>(A1 - line));
                                    }
                                }
                            }
                        }
                        for (std::uint8_t j = 0; j < N; ++j)
                            if (W.player(j).team != dteam && !W.isKeeper(j) && role(j) == 5)
                                S.st_short[bd].push_back(hx - W.player(j).pos.x.toDouble() * sg - line);
                        ++S.fm_n[bd]; S.fm_gap[bd] += sh; S.fm_gap2[bd] += f2 - f1; S.fm_dy[bd] += std::fabs(fy - by);
                        if (sh >= 0 && sh < 1) ++S.fm_w1[bd];
                        if (sh >= 0 && sh < 2) ++S.fm_w2[bd];
                        if (sh >= 4) ++S.fm_w4[bd];
                        if (sh >= 4 && bd >= 2 && bd <= 4) {   // §8.151
                            const auto& PO = s.brain().possession();
                            const std::uint8_t fu = static_cast<std::uint8_t>(fj), tm_ = W.player(fu).team;
                            const ai::Why wy = s.lastOrders()[fu].why;
                            int cat = 8;
                            if (b.owner && *b.owner == fu) cat = 0;
                            else if (b.pass_to == fu) cat = 1;
                            else if (PO.front(tm_, 0) == fu) cat = 2;
                            else if (PO.front(tm_, 1) == fu) cat = 3;
                            else if (wy == ai::Why::AttackBox) cat = 4;
                            else if (wy == ai::Why::RunLine) cat = 5;
                            else if (PO.front(tm_, 0) == 0xFF) cat = 6;
                            else if (wy == ai::Why::Hold) cat = 7;
                            ++S.ft_c[cat]; S.ft_g[cat] += sh;
                            if (cat == 2) {
                                S.ft_tg += hx - s.lastOrders()[fu].target.x.toDouble() * sg - line;
                                S.ft_v += W.player(fu).vel.x.toDouble() * sg;
                                S.ft_cmd += s.lastOrders()[fu].move.move.x.toDouble() * W.player(fu).max_speed.toDouble() * sg;
                                S.ft_lv += ai::Possession::offsideLineVelX(tm_, W, s.brain().teamOfSlot()).toDouble() * sg;
                                S.ft_age.push_back(static_cast<float>((W.tickCount() - PO.frontSince(tm_, 0)) * core::kTickDt.toDouble()));
                            }
                        }
                        if (sh < 0) ++S.fm_past[bd];
                        ++S.fm_r[bd][role(static_cast<std::uint8_t>(fj))];
                    }
                }
                if (plag_ok && pn) {   // §8.143: their offside line (second-last, keeper in) and our front man
                    double l1 = 1e9, l2 = 1e9;
                    for (std::uint8_t j = 0; j < N; ++j) if (W.player(j).team == dteam) {
                        const double ptl = hx - W.player(j).pos.x.toDouble() * sg;
                        if (ptl < l1) { l2 = l1; l1 = ptl; } else if (ptl < l2) l2 = ptl;
                    }
                    ++S.pl_n[bd][pvb]; S.pl_line[bd][pvb] += l2; S.pl_front[bd][pvb] += front;
                }
                if ((static_cast<long>(k) - rc_k) >= 180) {   // §8.138: settled widths by band
                    if (cbs_n == 2) { ++S.wg_n[0][bd]; S.wg[0][bd] += std::fabs(cbs_y[0] - cbs_y[1]); }
                    if (fbs_n == 2) { ++S.wg_n[1][bd]; S.wg[1][bd] += std::fabs(fbs_y[0] - fbs_y[1]); }
                    if (wds_n == 2) { ++S.wg_n[2][bd]; S.wg[2][bd] += std::fabs(wds_y[0] - wds_y[1]); }
                    if (dms_n == 2) { ++S.wg_n[3][bd]; S.wg[3][bd] += std::fabs(dms_y[0] - dms_y[1]); }
                }
                // §8.138: the lane in open play — settled (6 s+), ball 10-35 m off the defenders' line, |y| < 12
                const double bdl = hx + bx * (dteam == 0 ? 1.0 : -1.0);
                if ((static_cast<long>(k) - rc_k) >= 180 && bdl >= 10 && bdl < 35 && std::fabs(by) < 12) {
                    const double gxw = dteam == 0 ? -hx : hx, L = std::hypot(gxw - bx, -by), ux = (gxw - bx) / L, uy = -by / L;
                    int n1 = 0;
                    for (std::uint8_t j = 0; j < N; ++j) {
                        if (W.isKeeper(j) || W.player(j).team != dteam) continue;
                        const double px = W.player(j).pos.x.toDouble() - bx, py = W.player(j).pos.y.toDouble() - by;
                        const double al = px * ux + py * uy, pe = std::fabs(-px * uy + py * ux);
                        if (al > 0 && al < L && pe < 1) ++n1;
                    }
                    ++S.lo_f; S.lo_1 += n1 >= 1; ++S.lo_k[std::min(n1, 3)];
                    if (cbs_n == 2) { ++S.cb_n; S.cb_gap += std::fabs(cbs_y[0] - cbs_y[1]); S.cb_mid += std::fabs((cbs_y[0] + cbs_y[1]) / 2 - by); }
                }
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
            if (b.owner && k % 6 == 0) {   // §8.160: mates by zone, by the ball's zone (benchmarks_tracking_zonemates.py)
                auto zm = [&](double t, double y) { const int bb = t < 18 ? 0 : t < 35 ? 1 : t < 52 ? 2 : t < 70 ? 3 : 4;
                                                    return std::fabs(y) < 20.16 ? bb * 3 : bb * 3 + ((y > 0) == (by > 0) ? 1 : 2); };
                const int bz = zm(tl, by);
                int cnt[15] = {};
                for (std::uint8_t j = 0; j < N; ++j) {
                    if (W.isKeeper(j) || W.player(j).team != a || j == *b.owner) continue;
                    const int zj = zm(hx - W.player(j).pos.x.toDouble() * sg, W.player(j).pos.y.toDouble());
                    ++cnt[zj]; ++S.zm_r[bz][zj][role(j)]; S.zm_tl[bz][zj][role(j)] += hx - W.player(j).pos.x.toDouble() * sg; S.zm_ay[bz][zj][role(j)] += std::fabs(W.player(j).pos.y.toDouble());
                }
                ++S.zm_c[bz][role(*b.owner)];
                ++S.zm_f[bz];
                for (int z = 0; z < 15; ++z) { S.zm_n[bz][z] += cnt[z]; S.zm_0[bz][z] += cnt[z] == 0; }
            }
            if (tl < 52) {   // in the box, by the ball's zone (benchmarks_tracking_box.py)
                const int bz = (tl < 18 ? 0 : tl < 35 ? 1 : 2) * 2 + (std::fabs(by) < 20.16 ? 0 : 1);
                ++S.bx_f[bz];
                const double since = (static_cast<long>(k) - dead_last) / 30.0; const int sb = since < 3 ? 0 : since < 6 ? 1 : 2;   // §8.162
                ++S.bx_sf[bz][sb];
                int dpi = 0;   // §8.162: their line (second-last, keeper in, or the ball) inside 16 m
                {   double d1 = 1e9, d2 = 1e9;
                    for (std::uint8_t j = 0; j < N; ++j) if (W.player(j).team != a) { const double ptl = hx - W.player(j).pos.x.toDouble() * sg; if (ptl < d1) { d2 = d1; d1 = ptl; } else if (ptl < d2) d2 = ptl; }
                    dpi = std::min(d2, tl) < 16 ? 1 : 0; }
                ++S.bx_lf[bz][dpi];
                if (bz == 2 || bz == 3) {   // §8.163: ours by metres short of their line (benchmarks_tracking_linegaps.py)
                    double d1 = 1e9, d2 = 1e9;
                    for (std::uint8_t j = 0; j < N; ++j) if (W.player(j).team != a) { const double ptl = hx - W.player(j).pos.x.toDouble() * sg; if (ptl < d1) { d2 = d1; d1 = ptl; } else if (ptl < d2) d2 = ptl; }
                    const double L = std::min(d2, tl);
                    ++S.bx_gf[bz - 2][dpi];
                    for (std::uint8_t j = 0; j < N; ++j) {
                        if (W.isKeeper(j) || W.player(j).team != a) continue;
                        const double gp = hx - W.player(j).pos.x.toDouble() * sg - L;
                        ++S.bx_g[bz - 2][dpi][gp < 0 ? 0 : gp < 2 ? 1 : gp < 5 ? 2 : gp < 10 ? 3 : 4];
                    }
                }
                for (std::uint8_t j = 0; j < N; ++j) {
                    if (W.isKeeper(j) || W.player(j).team != a) continue;
                    const double ptl = hx - W.player(j).pos.x.toDouble() * sg;
                    if (ptl < 18 && std::fabs(W.player(j).pos.y.toDouble()) < 20.16) {
                        ++S.bx_in[bz]; ++S.bx_si[bz][sb]; ++S.bx_li[bz][dpi]; ++S.bx_lst[bz][dpi]; S.bx_lsd[bz][dpi] += ptl;
                        const int r2 = static_cast<int>(((k / 6) + 6) % 16);   // §8.162: 10 frames (2 s) back
                        if (rk[r2] == static_cast<long>(k) - 60 && j < 32) {
                            ++S.bx_i2[bz];
                            const bool was = hx - rpx[r2][j] * sg < 18 && std::fabs(rpy[r2][j]) < 20.16;
                            if (was) ++S.bx_was[bz];
                            S.bx_mv[bz] += std::hypot(W.player(j).pos.x.toDouble() - rpx[r2][j], W.player(j).pos.y.toDouble() - rpy[r2][j]);
                        }
                    }
                    else if (ptl < 18) ++S.bx_ch[bz];   // §8.157: in their wide channels (0-18 m, |y| 20.16+)
                    if (s.lastOrders()[j].why == ai::Why::AttackBox) { ++S.bx_run[bz]; S.bx_run_tl[bz] += hx - s.lastOrders()[j].target.x.toDouble() * sg; }
                }
                {   // §8.141: their offside line (second-last, keeper in) and our most advanced outfielder, off their line
                    double d1 = 1e9, d2 = 1e9, lead = 1e9;
                    for (std::uint8_t j = 0; j < N; ++j) {
                        const double ptl = hx - W.player(j).pos.x.toDouble() * sg;
                        if (W.player(j).team != a) { if (ptl < d1) { d2 = d1; d1 = ptl; } else if (ptl < d2) d2 = ptl; }
                        else if (!W.isKeeper(j) && ptl < lead) lead = ptl;
                    }
                    S.bx_ln[bz] += d2; S.bx_lead[bz] += lead;
                    ++S.lq_h[bz][std::max(0, std::min(60, static_cast<int>(std::min(d2, tl))))];
                    double o1 = 1e9, o2 = 1e9, cbs = 0; int o1j = -1, ncb = 0;   // cover: their deepest outfielder v their CBs' mean
                    for (std::uint8_t j = 0; j < N; ++j) {
                        if (W.player(j).team == a || W.isKeeper(j)) continue;
                        const double ptl = hx - W.player(j).pos.x.toDouble() * sg;
                        if (ptl < o1) { o2 = o1; o1 = ptl; o1j = j; } else if (ptl < o2) o2 = ptl;
                        if (role(j) == 0) { cbs += ptl; ++ncb; }
                    }
                    if (o1j >= 0 && ncb) { S.bx_deep[bz] += o1; S.bx_cbm[bz] += cbs / ncb; S.bx_gap2[bz] += o2 - o1; ++S.bx_drole[bz][role(static_cast<std::uint8_t>(o1j))]; }
                    if (std::getenv("GAME_LINE_TRACE") && bz < 4 && k % 15 == 0) {   // the defending side, off its own line
                        std::fprintf(stderr, "line bz %d ball %.1f %s:", bz, tl, b.owner ? "owned" : "loose");
                        for (std::uint8_t j = 0; j < N; ++j) if (W.player(j).team != a)
                            std::fprintf(stderr, " %s%d %.1f/%.1f", W.isKeeper(j) ? "K" : ai::kWhyNames[static_cast<int>(s.lastOrders()[j].why)], role(j),
                                         hx - W.player(j).pos.x.toDouble() * sg, hx - s.lastOrders()[j].target.x.toDouble() * sg);
                        std::fprintf(stderr, "\n");
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
                    double nd2 = 1e9; bool ngs = false; int nj = -1;
                    const auto& cp = W.player(static_cast<std::uint8_t>(cr));
                    for (std::uint8_t j = 0; j < N; ++j)
                        if (!W.isKeeper(j) && W.player(j).team != a) {
                            const double dd = std::hypot(W.player(j).pos.x.toDouble() - cp.pos.x.toDouble(), W.player(j).pos.y.toDouble() - cp.pos.y.toDouble());
                            // goal-side: nearer the defenders' goal line than the carrier (§8.139)
                            if (dd < nd2) { nd2 = dd; nj = j; ngs = (W.player(j).pos.x.toDouble() - cp.pos.x.toDouble()) * sg > 0; }
                        }
                    const int nb = tl < 18 ? 0 : tl < 35 ? 1 : tl < 52 ? 2 : tl < 70 ? 3 : 4;
                    if (nd2 < 1e8) { S.near_band[nb].push_back(nd2); ++S.near_n[nb]; S.near_gs[nb] += ngs; }
                    if (nj >= 0 && nb <= 1 && !ngs && std::getenv("GAME_PRESS_TRACE") && s.lastOrders()[nj].why == ai::Why::Press) {
                        const auto& q = W.player(static_cast<std::uint8_t>(nj));
                        const auto& lo = s.lastOrders()[nj];
                        std::fprintf(stderr, "press k %ld tl %.1f | car %.1f,%.1f v %.1f,%.1f | def %.1f,%.1f v %.1f,%.1f tgt %.1f,%.1f mv %.2f,%.2f rec %d | d %.1f\n", k, tl,
                                     cp.pos.x.toDouble() * sg, cp.pos.y.toDouble(), cp.vel.x.toDouble() * sg, cp.vel.y.toDouble(),
                                     q.pos.x.toDouble() * sg, q.pos.y.toDouble(), q.vel.x.toDouble() * sg, q.vel.y.toDouble(),
                                     lo.target.x.toDouble() * sg, lo.target.y.toDouble(), lo.move.move.x.toDouble() * sg, lo.move.move.y.toDouble(),
                                     q.recovery_ticks, nd2);
                    }
                    if (nj >= 0 && nb <= 1) {   // §8.139: who the nearest is, ball within 35 m of their goal
                        ++S.near_why[ngs ? 1 : 0][static_cast<int>(s.lastOrders()[nj].why)];
                        const double cvx = cp.vel.x.toDouble() * sg;   // the carrier's speed toward their goal
                        S.near_cv[ngs ? 1 : 0] += cvx; ++S.near_cvn[ngs ? 1 : 0];
                        const double held = (static_cast<long>(k) - static_cast<long>(W.ownedAtTick())) / 30.0;
                        S.near_held[ngs ? 1 : 0] += held;
                    }
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
            {   // §8.164: the front man (benchmarks_tracking_frontjob.py): ours nearest their goal, not on the ball (nearest within 2 m), 1 m hysteresis
                const auto& PO = s.brain().possession();
                const bool cont = fj_pk == static_cast<long>(k) - 6 && fj_pa == a;
                if (!cont) { if (fj_hold >= 0) S.fj_end.push_back((fj_pk - fj_since) / 30.0); fj_hold = -1; fe_hold = -1; }
                fj_pk = static_cast<long>(k); fj_pa = a;
                double d1 = 1e9, d2 = 1e9; int onb = -1; double bd = 4.0;
                for (std::uint8_t j = 0; j < N; ++j) {
                    const auto& q = W.player(j);
                    if (q.team != a) { const double ptl = hx - q.pos.x.toDouble() * sg; if (ptl < d1) { d2 = d1; d1 = ptl; } else if (ptl < d2) d2 = ptl; }
                    else { const double dd = std::pow(q.pos.x.toDouble() - bx, 2) + std::pow(q.pos.y.toDouble() - by, 2); if (dd < bd) { bd = dd; onb = j; } }
                }
                const double L = std::min(d2, tl);
                auto A = [&](int j) { return hx - W.player(static_cast<std::uint8_t>(j)).pos.x.toDouble() * sg; };
                const int r1 = static_cast<int>(((k / 6) + 11) % 16), r2 = static_cast<int>(((k / 6) + 6) % 16);
                const bool ok1 = rk[r1] == static_cast<long>(k) - 30, ok2 = rk[r2] == static_cast<long>(k) - 60;
                int best = -1;
                for (std::uint8_t j = 0; j < N && j < 32; ++j) if (W.player(j).team == a && !W.isKeeper(j) && j != onb && (best < 0 || A(j) < A(best))) best = j;
                {   // §8.171: the front two v their line by seconds since the spell began (benchmarks_tracking_frontjob.py)
                    double a1 = 1e9, a2 = 1e9;
                    for (std::uint8_t j = 0; j < N && j < 32; ++j) if (W.player(j).team == a && !W.isKeeper(j) && j != onb) {
                        const double g = A(j) - L; if (g < a1) { a2 = a1; a1 = g; } else if (g < a2) a2 = g; }
                    if (a2 < 1e8) {
                        const double since = (static_cast<long>(k) - rc_k) / 30.0;
                        const int sb = since < 3 ? 0 : since < 6 ? 1 : since < 10 ? 2 : since < 20 ? 3 : 4;
                        S.fs_1[sb].push_back(a1); S.fs_2[sb].push_back(a2 - a1);
                        if (since < 1) { const int zb = tl < 35 ? 0 : tl < 52 ? 1 : tl < 70 ? 2 : 3; S.ft_L[zb].push_back(L); S.ft_A[zb].push_back(L + a1); }
                    }
                }
                if (best >= 0) {
                    ++S.fj_t;
                    const bool held = fj_hold >= 0 && fj_hold != onb;
                    if (!held || A(best) + 1.0 < A(fj_hold)) {
                        if (fj_hold >= 0 && best != fj_hold) {
                            int why = 0;
                            if (fj_hold == onb) why = 0;
                            else {
                                const double dold = ok1 ? A(fj_hold) - (hx - rpx[r1][fj_hold] * sg) : 0, dnew = ok1 ? (hx - rpx[r1][best] * sg) - A(best) : 0;
                                why = dold >= 1 ? 2 : dnew >= 1 ? 3 : 4;
                                S.fj_old.push_back(A(fj_hold) - L);
                            }
                            ++S.fj_why[why]; S.fj_ten.push_back((static_cast<long>(k) - fj_since) / 30.0);
                            S.fj_new.push_back(A(best) - L);
                            if (ok2) S.fj_mv.push_back((hx - rpx[r2][best] * sg) - A(best));
                        }
                        if (best != fj_hold) { fj_hold = best; fj_since = static_cast<long>(k); }
                    }
                }
                const int f0 = PO.front(static_cast<std::uint8_t>(a), 0);   // the engine's front job
                if (f0 != 0xFF && f0 != fe_hold) {
                    if (fe_hold >= 0) {
                        const auto o = static_cast<std::uint8_t>(fe_hold);
                        int why = b.owner && *b.owner == o ? 0 : b.pass_to == o ? 1 : PO.runner(o) ? 2 : PO.running(o) ? 3 : fe_was[f0] ? 4 : 5;
                        ++S.fe_why[why]; S.fe_ten.push_back((static_cast<long>(k) - fe_since) / 30.0);
                        S.fe_new.push_back(A(f0) - L);
                        if (ok2) S.fe_mv.push_back((hx - rpx[r2][f0] * sg) - A(f0));
                    }
                    fe_hold = f0; fe_since = static_cast<long>(k);
                }
                for (std::uint8_t j = 0; j < N && j < 32; ++j) fe_was[j] = (b.owner && *b.owner == j) || b.pass_to == j || PO.runner(j) || PO.running(j);
            }
            rk[ri] = k; rbx[ri] = bx; rat[ri] = a;
            for (std::uint8_t j = 0; j < N && j < 32; ++j) { rpx[ri][j] = W.player(j).pos.x.toDouble(); rpy[ri][j] = W.player(j).pos.y.toDouble(); }
        }
        for (std::uint8_t j = 0; j < N && j < 32; ++j) {   // §8.189: within-man slope, pooled by role
            if (sl_c[j] < 50) continue;
            const double n = static_cast<double>(sl_c[j]);
            S.sl_xy[role(j)] += sl_by[j] - sl_b[j] * sl_y[j] / n; S.sl_xx[role(j)] += sl_bb[j] - sl_b[j] * sl_b[j] / n; S.sl_n[role(j)] += sl_c[j];
        }
        for (const auto& r : bt_rec) {   // §8.186: a shot / goal by the passer's side within 10 s of the kick
            bool sh = false, gl = false;
            for (long t : bt_shotk[r.team]) if (t > r.k0 && t <= r.k0 + 300) sh = true;
            for (long t : bt_goalk[r.team]) if (sh && t > r.k0 && t <= r.k0 + 330) gl = true;
            ++S.bt_n[r.high][r.ok]; S.bt_shot[r.high][r.ok] += sh; S.bt_goal[r.high][r.ok] += gl;
        }
        for (std::uint8_t j = 0; j < N; ++j) if (!W.isKeeper(j)) ++S.ro_n[role(j)];
        S.ro_sides += 2;
        S.aer_d += W.aerialDuels(); S.aer_l += W.aerialLone(); S.aer_c += W.headersClear(0) + W.headersClear(1); S.aer_g += W.headersAtGoal(0) + W.headersAtGoal(1);   // §8.172
        const int hg = W.score(0), ag = W.score(1);
        if (hg > ag) ++S.w; else if (hg == ag) ++S.d; else ++S.l;
    }

    // ── the report ──────────────────────────────────────────────────────
    const double nm = matches, tm = 2.0 * matches;
    if (!fixtures.empty()) {
        std::printf("FIXTURES (rotating, %d): ", matches);
        for (std::size_t i = 0; i < fixtures.size(); ++i) std::printf("%s%s", i ? "; " : "", fixtures[i].c_str());
        std::printf("\nhome sides over %d matches: W%ld D%ld L%ld | goals %.2f - %.2f\n", matches, S.w, S.d, S.l, S.goals[0] / nm, S.goals[1] / nm);
        std::printf("home shots %.1f/match\naway shots %.1f/match\n", S.shots[0] / nm, S.shots[1] / nm);
    } else {
        std::printf("%s vs %s over %d matches: W%ld D%ld L%ld | goals %.2f - %.2f\n", names.team_home.c_str(), names.team_away.c_str(),
                    matches, S.w, S.d, S.l, S.goals[0] / nm, S.goals[1] / nm);
        std::printf("%s shots %.1f/match\n%s shots %.1f/match\n", names.team_home.c_str(), S.shots[0] / nm, names.team_away.c_str(), S.shots[1] / nm);
    }
    {
        const double sh = std::max(1L, S.shots[0] + S.shots[1]);
        std::printf("SHOTS a team-match %.1f, goals %.2f, %.1f%% scored; by distance:", (S.shots[0] + S.shots[1]) / tm, (S.goals[0] + S.goals[1]) / tm,
                    100.0 * (S.goals[0] + S.goals[1]) / sh);
        for (int i = 0; i < 4; ++i) std::printf(" %s %.0f%% (scored %.1f%%);", kDistName[i], 100.0 * S.shot_band[i] / sh, 100.0 * S.band_goal[i] / std::max(1L, S.shot_band[i]));
        {   // §8.135: by where it was aimed (StatsBomb PL 15/16 goal % of on-target shots in brackets)
            static const double kReal[12] = {23.6, 22.5, 46.8, 44.4, 15.5, 22.8, 41.2, 41.7, 16.7, 28.2, 47.0, 51.8};
            std::printf("\n   BY AIMED CELL (from centre 0-1/1-2/2-3/3-3.66 m x height 0-0.5/0.5-1.5/1.5-2.44): n, goal %% (real of on target) / held %% / parried %%; aimed off target %ld\n", S.pc_n[0]);
            for (int h = 0; h < 3; ++h) {
                std::printf("     ");
                for (int l = 0; l < 4; ++l) {
                    const int c = 1 + l + 4 * h; const long n = S.pc_n[c];
                    std::printf(" %4ld %4.1f (%4.1f) /%4.1f /%4.1f |", n, n ? 100.0 * S.pc_g[c] / n : 0.0, kReal[c - 1], n ? 100.0 * S.pc_k[c] / n : 0.0, n ? 100.0 * S.pc_p[c] / n : 0.0);
                }
                std::printf("\n");
            }
        }
        {
            static const int kRealSave[4][7] = {{88, 73, 50, 41, 24, 19, 7}, {97, 94, 88, 66, 48, 30, 5}, {100, 95, 97, 90, 78, 71, 23}, {100, 100, 100, 93, 78, 100, 30}};
            std::printf("   SAVE CURVE (aimed on target, saved or scored): save %% by the keeper's gap along the line 0-0.5 … 3+ m, n; real StatsBomb in brackets\n");
            for (int bnd = 0; bnd < 4; ++bnd) {
                std::printf("     %s", kDistName[bnd]);
                for (int g = 0; g < 7; ++g)
                    std::printf("  %3.0f(%3d) n%-3ld", S.sc_n[bnd][g] ? 100.0 * S.sc_s[bnd][g] / S.sc_n[bnd][g] : -1.0, kRealSave[bnd][g], S.sc_n[bnd][g]);
                std::printf("\n");
            }
        }
        {   // §8.138: bodies in the lane (StatsBomb PL 15/16 freeze frames in brackets)
            static const double kShare[4] = {28.6, 50.7, 17.0, 3.8}, kBlk[4] = {7.6, 34.4, 44.9, 51.8};
            long t = 0; for (long x : S.ln_n) t += x;
            std::printf("\n   LANE ±1 m at the strike (outfield opponents between ball and goal centre): share / blocked by an outfielder —");
            for (int i = 0; i < 4; ++i) std::printf(" %d%s %.1f%% (%.1f) / %.1f%% (%.1f);", i, i == 3 ? "+" : "", t ? 100.0 * S.ln_n[i] / t : 0.0, kShare[i],
                                                    S.ln_n[i] ? 100.0 * S.ln_b[i] / S.ln_n[i] : 0.0, kBlk[i]);
            if (!S.ln_near.empty()) {
                std::vector<double> v = S.ln_near; std::sort(v.begin(), v.end());
                std::printf("\n   nearest outfield opponent to the lane p25 / median / p75 %.2f / %.2f / %.2f m (real 0.23 / 0.56 / 1.12)", v[v.size() / 4], v[v.size() / 2], v[v.size() * 3 / 4]);
                std::vector<double> w = S.sh_near; std::sort(w.begin(), w.end());
                std::vector<double> h = S.sh_held; std::sort(h.begin(), h.end());
                std::printf("\n   nearest outfield opponent to the SHOOTER p25 / median / p75 %.2f / %.2f / %.2f m, goal-side %.0f%%; on the ball before the shot median %.2f s (p75 %.2f)",
                            w[w.size() / 4], w[w.size() / 2], w[w.size() * 3 / 4], 100.0 * S.sh_gs / w.size(), h[h.size() / 2], h[h.size() * 3 / 4]);
                {   // §8.186 SHOT CONTEXT — benchmarks_statsbomb_shotcontext.py
                    static const double rgs[5] = {4.8, 9.1, 10.6, 13.2, 62.3}, rgg[5] = {39.4, 21.5, 14.9, 9.3, 4.5};
                    static const double rtb[4] = {19.6, 16.0, 26.7, 37.7}, rtg[4] = {8.7, 9.0, 10.4, 9.3}; static const int rtm[4] = {5, 4, 4, 5};
                    static const char* tl[4] = {"0-5", "5-10", "10-20", "20+"};
                    long ns = 0; for (long v : S.sx_gs) ns += v; ns = std::max(1L, ns);
                    std::printf("\n   SHOT CONTEXT (real StatsBomb PL 15/16 in brackets): GOAL-SIDE outfield opponents 0/1/2/3/4+, share %% [goal %%]:");
                    for (int g = 0; g < 5; ++g) std::printf(" %d%s %.1f (%.1f) [%.1f (%.1f)];", g, g == 4 ? "+" : "", 100.0 * S.sx_gs[g] / ns, rgs[g], 100.0 * S.sx_gs_g[g] / std::max(1L, S.sx_gs[g]), rgg[g]);
                    std::printf("\n     since the possession began, s: share %% [goal %%] {goal-side median}:");
                    for (int t = 0; t < 4; ++t) {
                        auto v = S.sx_tb_gs[t]; std::sort(v.begin(), v.end());
                        std::printf(" %s %.1f (%.1f) [%.1f (%.1f)] {%d (%d)};", tl[t], 100.0 * S.sx_tb[t] / ns, rtb[t], 100.0 * S.sx_tb_g[t] / std::max(1L, S.sx_tb[t]), rtg[t], v.empty() ? 0 : v[v.size() / 2], rtm[t]);
                    }
                    static const char* bl[4] = {"<12", "12-18", "18-25", "25+"}; static const int rb[4][3] = {{1, 2, 4}, {3, 4, 5}, {5, 6, 7}, {5, 7, 8}};
                    std::printf("\n     goal-side by the shot's distance p25 / median / p75:");
                    for (int d = 0; d < 4; ++d) {
                        auto v = S.sx_bd_gs[d]; std::sort(v.begin(), v.end());
                        if (v.empty()) continue;
                        std::printf(" %s %d / %d / %d (%d / %d / %d);", bl[d], v[v.size() / 4], v[v.size() / 2], v[v.size() * 3 / 4], rb[d][0], rb[d][1], rb[d][2]);
                    }
                }
            }
        }
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
        static const char* kn[14] = {"?", "goal", "throw-in", "goal kick", "corner", "kick-off", "", "", "", "", "offside FK", "", "free kick", "penalty"};
        static const char* rl[14] = {"", "", "19.9 / 13.8", "7.1 / 23.2", "3.2 / 32.8", "1.0 / 64.2", "", "", "", "", "offsides ~1.1", "", "10.5 / 32.5", "0.12 / -"};
        for (int i = 0; i < 14; ++i) {
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
    std::printf("   PENALTIES (Law 14) %.3f a team-match (StatsBomb PL 15/16 0.120), scored %ld of %ld (81.3%%); tackles in his own area %.2f a team-match (tackle duels there 1.61)\n", S.pens / tm, S.pen_goals, S.pens, S.tkl_area / tm);
    std::printf("   THEIR MAN ON THE BALL IN OUR AREA a team-match (StatsBomb PL 15/16, benchmarks_statsbomb_area_duels.py): spells begun there %.2f (receipts 12.83), on the ball %.1f s (carries 10.7 s); tackles per second on it %.3f (0.151)\n", S.area_rec / tm, S.area_ticks / 30.0 / tm, S.tkl_area / std::max(1e-9, S.area_ticks / 30.0));
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
        std::printf("\n   ...goal-side of him (nearer the defenders' goal line), by band:");
        for (int i = 0; i < 5; ++i) if (S.near_n[i]) std::printf(" %s %.1f%%;", nbn[i], 100.0 * S.near_gs[i] / S.near_n[i]);
        std::printf("\n");
        for (int g = 0; g < 2; ++g) {
            long t = 0; for (int w = 0; w < ai::kWhyCount; ++w) t += S.near_why[g][w];
            if (!t) continue;
            std::printf("   ...ball 0-35 m out, nearest %s: carrier toward goal %.2f m/s, on it %.2f s; his order:", g ? "goal-side" : "NOT goal-side",
                        S.near_cv[g] / S.near_cvn[g], S.near_held[g] / S.near_cvn[g]);
            for (int w = 0; w < ai::kWhyCount; ++w) if (S.near_why[g][w] * 50 >= t) std::printf(" %s %.0f%%;", ai::kWhyNames[w], 100.0 * S.near_why[g][w] / t);
            std::printf("\n");
        }
    }
    {
        static const char* bzn[6] = {"0-18 centre", "0-18 wide", "18-35 centre", "18-35 wide", "35-52 centre", "35-52 wide"};
        static const double real_in[6] = {3.45, 2.29, 1.04, 0.79, 0.13, 0.09};
        std::printf("   IN THE BOX (ours, 0-18 m |y| < 20.16) by the ball's zone (real DFL):");
        for (int z = 0; z < 6; ++z) if (S.bx_f[z]) std::printf(" %s %.2f (%.2f) [runners %.2f, target %.1f m];", bzn[z], static_cast<double>(S.bx_in[z]) / S.bx_f[z], real_in[z],
                                                             static_cast<double>(S.bx_run[z]) / S.bx_f[z], S.bx_run_tl[z] / std::max(1L, S.bx_run[z]));
        {   // §8.157: real DFL benchmarks_tracking_box.py "in the wide channels"
            static const double real_ch[6] = {0.51, 1.35, 0.12, 0.20, 0.01, 0.02};
            std::printf("\n     ours in their WIDE CHANNELS (0-18 m, |y| 20.16+) by the ball's zone (real DFL):");
            for (int z = 0; z < 6; ++z) if (S.bx_f[z]) std::printf(" %s %.2f (%.2f);", bzn[z], static_cast<double>(S.bx_ch[z]) / S.bx_f[z], real_ch[z]);
        }
        {   // §8.162: real DFL benchmarks_tracking_boxprior.py: of the men in the box, in it 2 s before / moved m
            static const double real_was[6] = {68, 74, 70, 71, 91, 91}, real_mv[6] = {5.8, 4.1, 4.4, 3.6, 4.1, 3.7};
            std::printf("\n     of ours in the box, there 2 s before / moved m in those 2 s (real DFL):");
            for (int z = 0; z < 6; ++z) if (S.bx_i2[z]) std::printf(" %s %.0f%% (%.0f%%) / %.1f (%.1f);", bzn[z], 100.0 * S.bx_was[z] / S.bx_i2[z], real_was[z], S.bx_mv[z] / S.bx_i2[z], real_mv[z]);
        }
        {   // §8.162: real DFL benchmarks_tracking_boxsince.py: by seconds since the ball was last dead, share of frames / in the box
            static const double rf[6][3] = {{16, 10, 73}, {18, 8, 74}, {5, 8, 86}, {10, 7, 82}, {5, 9, 86}, {10, 8, 83}};
            static const double ri[6][3] = {{5.24, 4.06, 2.97}, {3.21, 2.65, 2.03}, {2.52, 2.05, 0.86}, {1.46, 0.92, 0.70}, {0.25, 0.29, 0.11}, {0.16, 0.15, 0.07}};
            std::printf("\n     in the box by seconds since the ball was dead <3 / 3-6 / 6+, %% of frames (real) in box (real):");
            for (int z = 0; z < 6; ++z) if (S.bx_f[z]) { std::printf(" %s", bzn[z]); for (int q = 0; q < 3; ++q) std::printf(" %.0f%% (%.0f) %.2f (%.2f)%s", 100.0 * S.bx_sf[z][q] / S.bx_f[z], rf[z][q], static_cast<double>(S.bx_si[z][q]) / std::max(1L, S.bx_sf[z][q]), ri[z][q], q < 2 ? " /" : ";"); }
        }
        {   // §8.163: real DFL benchmarks_tracking_box.py (G5.53 lines): by their line inside 16 m / 16+, % of frames and in the box
            static const double rf[6] = {97, 97, 35, 38, 3, 3}, ri[6][2] = {{0.40, 3.54}, {0.15, 2.37}, {0.15, 2.71}, {0.09, 1.97}, {0.05, 2.39}, {0.03, 1.62}};
            std::printf("\n     in the box by their line inside 16 m: %% of frames (real), in the box (real), they stand m off the line | 16+: in the box (real):");
            for (int z = 0; z < 6; ++z) if (S.bx_f[z]) std::printf(" %s %.0f%% (%.0f) %.2f (%.2f) %.1f m | %.2f (%.2f);", bzn[z], 100.0 * S.bx_lf[z][1] / S.bx_f[z], rf[z],
                static_cast<double>(S.bx_li[z][1]) / std::max(1L, S.bx_lf[z][1]), ri[z][1], S.bx_lsd[z][1] / std::max(1L, S.bx_lst[z][1]), static_cast<double>(S.bx_li[z][0]) / std::max(1L, S.bx_lf[z][0]), ri[z][0]);
        }
        {   // §8.163: real DFL benchmarks_tracking_linegaps.py
            static const double rg[2][2][5] = {{{0.15, 0.60, 1.06, 1.38, 6.72}, {0.35, 1.14, 1.50, 1.61, 5.25}}, {{0.09, 0.52, 1.09, 1.43, 6.79}, {0.18, 0.94, 1.41, 1.61, 5.75}}};
            std::printf("\n     ours by metres short of their line, past / 0-2 / 2-5 / 5-10 / 10+ (real):");
            for (int z = 0; z < 2; ++z) for (int d = 1; d >= 0; --d) if (S.bx_gf[z][d]) {
                std::printf(" ball 18-35 %s line %s:", z ? "wide" : "centre", d ? "<16" : "16+");
                for (int q = 0; q < 5; ++q) std::printf(" %.2f (%.2f)", static_cast<double>(S.bx_g[z][d][q]) / S.bx_gf[z][d], rg[z][d][q]);
                std::printf(";");
            }
        }
        std::printf("\n     their offside line / our most advanced outfielder, m off their line (real DFL):");
        static const double real_ln[6] = {8.7, 9.0, 18.8, 18.5, 28.2, 27.8}, real_lead[6] = {9.1, 10.1, 20.2, 20.2, 30.1, 29.8};
        for (int z = 0; z < 6; ++z) if (S.bx_f[z]) std::printf(" %s %.1f (%.1f) / %.1f (%.1f);", bzn[z], S.bx_ln[z] / S.bx_f[z], real_ln[z], S.bx_lead[z] / S.bx_f[z], real_lead[z]);
        if (!S.fj_ten.empty()) {   // §8.164: real DFL benchmarks_tracking_frontjob.py, 1 m hysteresis
            auto q3 = [](std::vector<double> v, char* o) { if (v.empty()) { std::snprintf(o, 40, "-"); return; } std::sort(v.begin(), v.end());
                                                             std::snprintf(o, 40, "%.1f/%.1f/%.1f", v[v.size() / 4], v[v.size() / 2], v[v.size() * 3 / 4]); };
            char a1[40], a2[40], a3[40], a4[40], a5[40], a6[40], a7[40], a8[40];
            q3(S.fj_ten, a1); q3(S.fj_end, a2); q3(S.fj_new, a3); q3(S.fj_old, a4); q3(S.fj_mv, a5); q3(S.fe_ten, a6); q3(S.fe_new, a7); q3(S.fe_mv, a8);
            const double n = static_cast<double>(S.fj_ten.size());
            std::printf("\n   THE FRONT MAN (ours nearest their goal, not on the ball, 1 m hysteresis; real DFL benchmarks_tracking_frontjob.py): handovers %.1f a team-match (192.5), one per %.1f s (8.2); tenure p25/med/p75 %s s (1.4/3.0/5.8), to the spell's end %s (0.8/1.6/3.4)",
                        n / tm, S.fj_t / 5.0 / std::max(1.0, n), a1, a2);
            std::printf("\n     why: on ball %.0f%% (22.8), old dropped %.0f%% (22.8), new on %.0f%% (42.5), drift %.0f%% (11.9); gap to their line new man %s (1.2/2.7/5.2), old %s (2.4/3.8/5.9); new man moved on over 2 s %s m (0.0/3.2/7.8)",
                        100 * S.fj_why[0] / n, 100 * S.fj_why[2] / n, 100 * S.fj_why[3] / n, 100 * S.fj_why[4] / n, a3, a4, a5);
            {   // §8.171: real DFL benchmarks_tracking_frontjob.py
                static const char* sbn[5] = {"<3 s", "3-6", "6-10", "10-20", "20+"};
                static const double r_med[5] = {2.1, 2.1, 1.7, 1.3, 1.2}, r_4[5] = {29.4, 25.6, 18.7, 10.6, 7.0}, r_2[5] = {3.6, 3.1, 2.5, 2.1, 2.0};
                std::printf("\n     by seconds since the spell began, front man m short (real) / 4+ m short %% (real) / the second man behind him (real):");
                for (int b = 0; b < 5; ++b) {
                    if (S.fs_1[b].empty()) continue;
                    std::vector<double> v = S.fs_1[b], w = S.fs_2[b];
                    std::sort(v.begin(), v.end()); std::sort(w.begin(), w.end());
                    long f4 = 0; for (double x : v) f4 += x >= 4;
                    std::printf(" %s %.1f (%.1f) / %.0f%% (%.0f) / %.1f (%.1f);", sbn[b], v[v.size() / 2], r_med[b], 100.0 * f4 / v.size(), r_4[b], w[w.size() / 2], r_2[b]);
                }
                static const double r_top[10] = {42.0, 45.7, 49.8, 53.6, 57.7, 63.2, 67.6, 74.5, 82.5, 91.6};   // benchmarks_tracking_blockspread.py
                std::printf("\n     the block's most advanced outfielder, m off its own line, median by the ball's band (real):");
                for (int b2 = 0; b2 < 10; ++b2) {
                    if (S.bk_top[b2].empty()) continue;
                    std::vector<double> v = S.bk_top[b2]; std::sort(v.begin(), v.end());
                    std::printf(" %d-%d %.1f (%.1f);", b2 * 10, b2 * 10 + 10, v[v.size() / 2], r_top[b2]);
                }
                {   // §8.172: real DFL benchmarks_tracking_turnline.py
                    static const double rLn[4] = {12.9, 24.8, 37.0, 51.8}, rB[4] = {23.9, 45.2, 61.8, 87.2}, rG[4] = {-6.3, -7.4, -4.6, -2.2}, rF[4] = {4.3, 12.8, 17.2, 15.1}, rD[4] = {2.0, 3.2, 3.6, 5.4}, rN[4] = {26.4, 29.8, 37.4, 71.8};
                    auto md = [](std::vector<double> v) { if (v.empty()) return 0.0; std::sort(v.begin(), v.end()); return v[v.size() / 2]; };
                    const double tmn = 2.0 * matches;
                    std::printf("\n     §8.172 the side in possession's own line as it loses the ball (last frame before, in play), m off its goal, by the ball's band: losses a team-match (real) / line med (real) / ball med (real) / line minus its usual there (real) / ball forward over 3 s (real) / spell s (real)");
                    for (int z = 0; z < 4; ++z) {
                        if (S.tn_L[z].empty()) continue;
                        std::vector<double> gp; for (const auto& [b5, L] : S.tn_g[z]) if (S.tn_an[b5]) gp.push_back(L - S.tn_as[b5] / S.tn_an[b5]);
                        static const char* tzn[4] = {"ball 0-35", "35-52", "52-70", "70+"};
                        std::printf("\n        %s %5.1f (%4.1f) / %4.1f (%4.1f) / %4.1f (%4.1f) / %+4.1f (%+4.1f) / %4.1f (%4.1f) / %3.1f (%3.1f)", tzn[z], S.tn_n[z] / tmn, rN[z],
                                    md(S.tn_L[z]), rLn[z], md(S.tn_b[z]), rB[z], md(gp), rG[z], md(S.tn_f[z]), rF[z], md(S.tn_d[z]), rD[z]);
                        static const double rNk[4] = {14.9, 20.3, 24.3, 48.1}, rGk[4] = {-7.2, -9.2, -5.9, -2.9}, rDk[4] = {2.2, 3.4, 3.6, 5.6};
                        std::vector<double> gk; for (const auto& [b5, L] : S.tn_gk[z]) if (S.tn_an[b5]) gk.push_back(L - S.tn_as[b5] / S.tn_an[b5]);
                        std::printf(" | kept 2 s+ by the winner %4.1f (%4.1f), line minus usual %+4.1f (%+4.1f), spell s %3.1f (%3.1f)", S.tn_nk[z] / tmn, rNk[z], md(gk), rGk[z], md(S.tn_dk[z]), rDk[z]);
                    }
                    {
                        static const double rW[4] = {48.3, 23.6, 21.1, 14.5}, rL3[4][3] = {{15.1, 40.4, 54.6}, {13.3, 42.1, 55.5}, {16.9, 42.2, 57.1}, {20.2, 49.8, 62.1}}, rF3[4] = {8.1, 6.5, 8.3, 0.5}, rF6[4] = {14.9, 6.2, 10.2, -1.0};
                        static const char* wzn[4] = {"ball 0-35", "35-52", "52-70", "70+"};
                        std::printf("\n        spells won in play and kept 2 s+, by the ball's band (m off the winner's goal) at the win: a team-match (real) | lost again by 3 / 6 / 10 s %% (real) | ball forward at +3 s / +6 s med (real)");
                        for (int z = 0; z < 4; ++z) if (S.wsp_n[z]) {
                            const double n = S.wsp_n[z];
                            std::printf("\n          %s %5.1f (%4.1f) | %4.1f / %4.1f / %4.1f (%4.1f / %4.1f / %4.1f) | %5.1f / %5.1f (%4.1f / %4.1f)", wzn[z], n / tmn, rW[z],
                                        100 * S.wsp_l[z][0] / n, 100 * S.wsp_l[z][1] / n, 100 * S.wsp_l[z][2] / n, rL3[z][0], rL3[z][1], rL3[z][2], md(S.wsp_f[z][0]), md(S.wsp_f[z][1]), rF3[z], rF6[z]);
                        }
                    }
                    {
                        static const double rK[3] = {68.4, 38.9, 58.1}, rKk[3] = {43.4, 25.3, 38.8}, rKs[3][3] = {{13.4, 22.0, 64.6}, {11.4, 20.9, 67.7}, {19.1, 24.4, 56.6}}, rKks[3][3] = {{15.3, 22.9, 61.8}, {12.7, 20.3, 66.9}, {20.3, 26.0, 53.8}};
                        static const char* an[3] = {"<3 s", "3-6", "6+"};
                        std::printf("\n        losses by the spell's age: a team-match (real) | ball at the change ground / air / feet %% (real) || kept 2 s+ by the winner: a team-match (real) | ground / air / feet %% (real)");
                        for (int ab = 0; ab < 3; ++ab) {
                            const double n = S.lk_n[ab][0] + S.lk_n[ab][1] + S.lk_n[ab][2], nk = S.lk_k[ab][0] + S.lk_k[ab][1] + S.lk_k[ab][2];
                            if (n <= 0) continue;
                            std::printf("\n          %-4s %5.1f (%4.1f) | %4.1f / %4.1f / %4.1f (%4.1f / %4.1f / %4.1f) || %5.1f (%4.1f) | %4.1f / %4.1f / %4.1f (%4.1f / %4.1f / %4.1f)", an[ab], n / tmn, rK[ab],
                                        100 * S.lk_n[ab][0] / n, 100 * S.lk_n[ab][1] / n, 100 * S.lk_n[ab][2] / n, rKs[ab][0], rKs[ab][1], rKs[ab][2],
                                        nk / tmn, rKk[ab], 100 * S.lk_k[ab][0] / std::max(1.0, nk), 100 * S.lk_k[ab][1] / std::max(1.0, nk), 100 * S.lk_k[ab][2] / std::max(1.0, nk), rKks[ab][0], rKks[ab][1], rKks[ab][2]);
                        }
                    }
                    {   // §8.174
                        auto mdh = [](std::vector<double> v) { if (v.empty()) return 0.0; std::sort(v.begin(), v.end()); return v[v.size() / 2]; };
                        static const char* zn3[3] = {"0-35", "35-70", "70+"}; static const double rn[3] = {3.3, 26.3, 29.3}, rc[3] = {57.0, 46.0, 36.0}, rl[3] = {22.7, 36.2, 37.8}, rd[3] = {4.2, 16.2, 11.7};
                        std::printf("\n        HIGH PASSES, open play, crosses out (benchmarks_statsbomb_highpass.py, real PL 15/16 in brackets), by the aim's m off the passer's own goal: a team-match | completed %% | length med | aerial duel at it within 5 s %% (on completed %%)");
                        for (int z = 0; z < 3; ++z) if (S.hp_n[z]) std::printf("\n          %-5s %5.1f (%4.1f) | %4.1f (%4.1f) | %4.1f (%4.1f) | %4.1f (%4.1f) (%4.1f)", zn3[z], S.hp_n[z] / tmn, rn[z], 100.0 * S.hp_ok[z] / S.hp_n[z], rc[z], mdh(S.hp_len[z]), rl[z], 100.0 * S.hp_du[z] / S.hp_n[z], rd[z], 100.0 * S.hp_duc[z] / std::max(1L, S.hp_ok[z]));
                        {   // §8.185 LOFT FLIGHT v benchmarks_tracking_loft.py
                            static const char* rf[5] = {"5.9 | 5.6 | 2.52 | 2.88", "8.9 | 5.9 | 2.24 | 2.48", "16.7 | 5.8 | 2.20 | 2.48", "11.1 | 7.3 | 2.64 | 2.92", "12.6 | 9.9 | 3.28 | 3.60"};
                            static const char* bn[5] = {"10-20", "20-30", "30-40", "40-50", "50-70"};
                            std::printf("\n        LOFT FLIGHT (rose past 4 m, in play; benchmarks_tracking_loft.py, real DFL in brackets), by carry m: a team-match | launch deg med | peak m med | down through 2.4 m s med | landing s med | launch m/s med  (real: a team-match | peak | down | landing)");
                            for (int q = 0; q < 5; ++q) if (S.lf_n[q]) std::printf("\n          %s %5.1f | %4.1f | %4.1f | %4.2f | %4.2f | %4.1f  (%s)", bn[q], S.lf_n[q] / tmn, mdh(S.lf_ang[q]), mdh(S.lf_pk[q]), mdh(S.lf_dn[q]), mdh(S.lf_ld[q]), mdh(S.lf_v[q]), rf[q]);
                        }
                        {   // §8.185 HIGH OUTCOME v benchmarks_statsbomb_highpass.py
                            static const char* ro[3] = {"57.0 / 17.6 / 0.0 / 6.4 / 19.0 / 0.0 / 0.0", "46.0 / 5.1 / 0.7 / 26.8 / 21.5 / 0.0 / 0.0", "36.0 / 7.3 / 2.0 / 26.5 / 26.8 / 1.4 / 0.0"};
                            std::printf("\n        HIGH OUTCOME (%% of the zone's high passes; real StatsBomb PL 15/16 in brackets): completed / out / offside / lost: in the air / on the ground / their keeper / no touch in 5 s");
                            for (int z = 0; z < 3; ++z) { long t = 0; for (int q = 0; q < 7; ++q) t += S.hp_oc[z][q]; const double n = static_cast<double>(std::max(1L, t));
                                std::printf("\n          %-5s", zn3[z]); for (int q = 0; q < 7; ++q) std::printf(" %4.1f", 100 * S.hp_oc[z][q] / n); std::printf("  (%s)", ro[z]); }
                        }
                        static const double rh[3][6] = {{5.5, 5.2, 14.3, 53.9, 90.2, 97.9}, {5.3, 5.4, 12.3, 41.9, 77.5, 92.7}, {5.5, 7.4, 21.4, 46.2, 74.4, 87.4}};
                        static const double rhc[3][6] = {{35, 49, 45, 42, 35, 28}, {50, 51, 46, 47, 49, 40}, {33, 38, 39, 55, 67, 64}};
                        std::printf("\n        PASS PICK (benchmarks_tracking_passpick.py, DFL): passer m off own goal | the man it is for, his zone at the kick holding 2+ mates: share of passes, he is the nearest %% (even), his m v the zone's mean, wide to wide with both flanks held own flank %%");
                        {   static const double rk[3] = {81, 71, 69}, rn[3] = {49.5, 61.8, 62.4}, rf[3] = {94.6, 96.7, 100.0};
                            static const char* nm[3] = {"0-35", "35-70", "70+"};
                            for (int ob = 0; ob < 3; ++ob) { const long kk = std::max(1L, S.pk_k[ob]);
                                std::printf("\n          %-5s 2+ %3.0f%% (%2.0f), nearest %4.1f%% (%4.1f) even %4.1f, %4.1f m v %4.1f, own flank %4.1f%% of %ld (%5.1f)", nm[ob], 100.0 * S.pk_k[ob] / std::max(1L, S.pk_n[ob]), rk[ob],
                                            100.0 * S.pk_near[ob] / kk, rn[ob], 100.0 * S.pk_even[ob] / kk, S.pk_drc[ob] / kk, S.pk_dm[ob] / kk, 100.0 * S.pk_same[ob] / std::max(1L, S.pk_w2[ob]), S.pk_w2[ob], rf[ob]); } }
                        {   // §8.184 MARKED PICK v benchmarks_tracking_passpick.py (DFL, completed passes naming a Recipient)
                            static const char* real[3] = {"5 / 10 / 10 / 18 / 56 | 3 / 5 / 5 / 12 / 75", "9 / 15 / 16 / 25 / 35 | 7 / 12 / 13 / 25 / 43", "20 / 26 / 18 / 20 / 17 | 16 / 24 / 18 / 22 / 19"};
                            static const char* nm[3] = {"0-35", "35-70", "70+"};
                            std::printf("\n        MARKED PICK (his zone holding 2+ mates; each mate by his nearest opponent 0-2 / 2-3.5 / 3.5-5 / 5-8 / 8+ m; real DFL completed passes in brackets), by the receiver's m off own goal: mates %% | receivers %%, completed passes || all passes");
                            for (int rb = 0; rb < 3; ++rb) {
                                std::printf("\n          %-5s", nm[rb]);
                                for (int g = 1; g >= 0; --g) {
                                    long ta = 0; for (int q = 0; q < 5; ++q) ta += S.mp_av[g][rb][q];
                                    const double n = static_cast<double>(std::max(1L, S.mp_n[g][rb])), a = static_cast<double>(std::max(1L, ta));
                                    std::printf(" %s", g ? "" : "||");
                                    for (int q = 0; q < 5; ++q) std::printf(" %.0f", 100 * S.mp_av[g][rb][q] / a);
                                    std::printf(" |"); for (int q = 0; q < 5; ++q) std::printf(" %.0f", 100 * S.mp_pk[g][rb][q] / n);
                                }
                                std::printf("  (%s)", real[rb]);
                            }
                        }
                        std::printf("\n        HIGH BY LENGTH (benchmarks_statsbomb_highpass.py --length): origin m off own goal | by the pass's length 0-10/10-20/20-30/30-40/40-50/50+: a team-match, high %% (real), high completed %% (real) / ground completed %%");
                        for (int oz = 0; oz < 3; ++oz) {
                            std::printf("\n          %-5s", zn3[oz]);
                            for (int lb = 0; lb < 6; ++lb) { const long nn = S.hl_n[oz][lb], hh = S.hl_h[oz][lb]; std::printf(" [%4.1f %4.1f%% (%4.1f) %3.0f (%2.0f)/%3.0f]", nn / tmn, 100.0 * hh / std::max(1L, nn), rh[oz][lb], 100.0 * S.hl_hc[oz][lb] / std::max(1L, hh), rhc[oz][lb], 100.0 * S.hl_gc[oz][lb] / std::max(1L, nn - hh)); }
                        }
                    }
                    {   // §8.176
                        std::printf("\n        HIGH BY DIRECTION (benchmarks_statsbomb_highpass.py --dir): origin m off own goal, forward (within 60 deg) / lateral / back | by length 0-10/10-20/20-30/30-40/40-50/50+: a team-match (real), high %% (real)");
                        static const double rn[3][3][6] = {{{6.4, 14.6, 8.3, 5.6, 6.0, 9.4}, {3.3, 8.8, 6.9, 2.0, 0.4, 0.1}, {2.5, 4.0, 2.8, 0.5, 0.0, 0.0}},
                                                           {{18.5, 35.5, 14.1, 7.6, 4.9, 2.8}, {16.1, 31.8, 16.2, 5.2, 1.7, 0.6}, {15.0, 20.6, 5.3, 1.7, 0.3, 0.0}},
                                                           {{11.8, 13.4, 4.2, 0.9, 0.2, 0.0}, {13.8, 13.5, 3.5, 1.0, 0.4, 0.1}, {11.9, 10.5, 1.4, 0.2, 0.0, 0.0}}};
                        static const double rp[3][3][6] = {{{7.8, 7.8, 27.6, 72.9, 93.1, 98.2}, {3.6, 2.4, 3.6, 12.2, 47.3, 78.6}, {2.1, 1.9, 1.1, 4.4, 4.4, 4.4}},
                                                           {{8.5, 9.2, 24.9, 64.3, 84.0, 93.7}, {3.6, 3.0, 4.0, 20.6, 69.2, 89.6}, {3.2, 2.4, 4.0, 7.8, 21.0, 21.0}},
                                                           {{7.6, 10.7, 31.3, 62.5, 88.1, 88.1}, {6.2, 8.1, 16.3, 38.6, 73.7, 89.2}, {2.5, 2.4, 4.9, 14.3, 36.1, 36.1}}};
                        static const char* zd[3] = {"0-35", "35-70", "70+"}; static const char* dn[3] = {"fwd", "lat", "back"};
                        for (int oz = 0; oz < 3; ++oz) for (int d = 0; d < 3; ++d) {
                            std::printf("\n          %-5s %-4s", zd[oz], dn[d]);
                            for (int lb = 0; lb < 6; ++lb) { const long nn = S.hd_n[oz][d][lb];
                                std::printf(" [%4.1f (%4.1f) %4.1f%% (%4.1f)]", nn / tmn, rn[oz][d][lb], 100.0 * S.hd_h[oz][d][lb] / std::max(1L, nn), rp[oz][d][lb]); }
                        }
                    }
                    {   // §8.177
                        static const double rk[10] = {0.25, 1.43, 2.63, 2.20, 0.94, 0.23, 0.07, 0.01, 0.01, 0.00}, rl[10] = {16.1, 17.9, 22.2, 28.3, 34.0, 38.5, 41.1, 22.3, 17.8, 11.0};
                        std::printf("\n        TO OUR KEEPER (open-play passes, crosses out; real StatsBomb PL 15/16 in brackets), passer 10 m bins off his own goal: a team-match | share of the bin's passes %% | length med | high %% | completed %%");
                        static const double rs[10] = {5.42, 12.07, 9.83, 4.81, 1.54, 0.42, 0.12, 0.03, 0.02, 0.02};
                        for (int b = 0; b < 8; ++b) std::printf("\n          %2d-%-3d %5.2f (%4.2f) | %5.2f (%5.2f) | %4.1f (%4.1f) | %4.1f | %5.1f", b * 10, b * 10 + 10, S.gp_k[b] / tmn, rk[b], 100.0 * S.gp_k[b] / std::max(1L, S.gp_n[b]), rs[b], [](std::vector<double> v) { if (v.empty()) return 0.0; std::sort(v.begin(), v.end()); return v[v.size() / 2]; }(S.gp_len[b]), rl[b], 100.0 * S.gp_h[b] / std::max(1L, S.gp_k[b]), 100.0 * S.gp_ok[b] / std::max(1L, S.gp_k[b]));
                    }
                    {   // §8.181 FIRST TOUCH v benchmarks_tracking_firsttouch.py (DFL controlled first touches)
                        auto qf = [](std::vector<double> v, double p) { if (v.empty()) return 0.0; std::sort(v.begin(), v.end()); return v[std::min(v.size() - 1, static_cast<std::size_t>(v.size() * p))]; };
                        std::printf("\n        FIRST TOUCH (controlled: a free ground ball 3 m/s+ made his, off the touch < 0.7 x; real DFL in brackets): %.1f a team-match (146.8) | off-touch / incoming p25 %.2f med %.2f p75 %.2f (0.20 / 0.33 / 0.48) | gap 0.5 s p25 %.2f med %.2f p90 %.2f (0.59 / 0.81 / 1.51) | gap 1 s med %.2f (0.94) | kept 1 s %.1f%% (72.3)",
                                    S.ft_n / tmn, qf(S.ft_r, .25), qf(S.ft_r, .5), qf(S.ft_r, .75), qf(S.ft_g5, .25), qf(S.ft_g5, .5), qf(S.ft_g5, .9), qf(S.ft_g10, .5), 100.0 * S.ft_kept / std::max(1L, S.ft_n));
                        const double pn = static_cast<double>(std::max(1L, S.pt_n));
                        std::printf("\n        PRESSED TOUCH (controlled, an opponent inside 3 m at the touch; real DFL in brackets): %.1f a team-match (10.0) | touch toward / across / away / still %.0f / %.0f / %.0f / %.0f%% (14 / 27 / 56 / 2) | 0.5 s on: ball nearer him than the receiver %.0f%% (19) | his gap to it med %.2f (2.16)",
                                    S.pt_n / tmn, 100 * S.pt_rel[0] / pn, 100 * S.pt_rel[1] / pn, 100 * S.pt_rel[2] / pn, 100 * S.pt_rel[3] / pn, 100 * S.pt_near / pn, qf(S.pt_q5, .5));
                        // §8.183 RECEIVER SPACE v benchmarks_tracking_firsttouch.py (DFL): his nearest opponent at the touch / release
                        static const char* rs_rl[2] = {"6 / 11 / 15 / 22 / 46 med 7.42 | release 3 / 6 / 9 / 19 / 64 med 10.20 | closed 2.21 m over 1.28 s | 27", "2 / 4 / 10 / 23 / 60 med 9.25 | release 1 / 2 / 5 / 15 / 77 med 11.94 | closed 2.32 m over 1.28 s | 26"};
                        static const double rs_rn[2] = {251.3, 146.8};
                        for (int g = 0; g < 2; ++g) {
                            const auto& T = S.rs_t[g]; const auto& R = S.rs_r[g]; const double n = static_cast<double>(std::max<std::size_t>(1, T.size()));
                            auto bins = [&](const std::vector<double>& v) { static char b[64]; double c[5] = {}; for (double x : v) ++c[x < 1.5 ? 0 : x < 3 ? 1 : x < 5 ? 2 : x < 8 ? 3 : 4]; std::snprintf(b, sizeof b, "%.0f / %.0f / %.0f / %.0f / %.0f", 100 * c[0] / n, 100 * c[1] / n, 100 * c[2] / n, 100 * c[3] / n, 100 * c[4] / n); return std::string(b); };
                            std::printf("\n        RECEIVER SPACE %s (a free ground ball 0.4 s+, 3 m/s+, reaching a man; real DFL in brackets): %.1f a team-match (%.1f) | nearest opp at the touch %% 0-1.5/1.5-3/3-5/5-8/8+ %s med %.2f | release %s med %.2f | closed %.2f m over %.2f s | of those inside 3 m at the touch, 5 m+ at the release %.0f%%  (%s)",
                                        g ? "controlled" : "all", T.size() / tmn, rs_rn[g], bins(T).c_str(), qf(T, .5), bins(R).c_str(), qf(R, .5), qf(S.rs_c[g], .5), qf(S.rs_dt[g], .5), 100.0 * S.rs_far[g] / std::max(1L, S.rs_in3[g]), rs_rl[g]);
                            std::printf("\n          from a mate's pass %.1f a team-match, inside 3 m %.1f%% | other (theirs / loose) %.1f, inside 3 m %.1f%% | the man inside 3 m doing:", S.rs_kind[g][1] / tmn, 100.0 * S.rs_kin3[g][1] / std::max(1L, S.rs_kind[g][1]), S.rs_kind[g][0] / tmn, 100.0 * S.rs_kin3[g][0] / std::max(1L, S.rs_kind[g][0]));
                            for (int w = 0; w < ai::kWhyCount; ++w) if (S.rs_why[g][w] * 25 >= S.rs_in3[g]) std::printf(" %s %.0f%%;", ai::kWhyNames[w], 100.0 * S.rs_why[g][w] / std::max(1L, S.rs_in3[g]));
                            std::printf("\n          mate's pass by the ball's travel release->touch 0-10/10-20/20-30/30+ m: n %.1f / %.1f / %.1f / %.1f | inside 3 m at the touch %.0f / %.0f / %.0f / %.0f%% | at the release %.0f / %.0f / %.0f / %.0f%%  (%s)",
                                        S.rs_ln[g][0] / tmn, S.rs_ln[g][1] / tmn, S.rs_ln[g][2] / tmn, S.rs_ln[g][3] / tmn,
                                        100.0 * S.rs_lt3[g][0] / std::max(1L, S.rs_ln[g][0]), 100.0 * S.rs_lt3[g][1] / std::max(1L, S.rs_ln[g][1]), 100.0 * S.rs_lt3[g][2] / std::max(1L, S.rs_ln[g][2]), 100.0 * S.rs_lt3[g][3] / std::max(1L, S.rs_ln[g][3]),
                                        100.0 * S.rs_lr3[g][0] / std::max(1L, S.rs_ln[g][0]), 100.0 * S.rs_lr3[g][1] / std::max(1L, S.rs_ln[g][1]), 100.0 * S.rs_lr3[g][2] / std::max(1L, S.rs_ln[g][2]), 100.0 * S.rs_lr3[g][3] / std::max(1L, S.rs_ln[g][3]),
                                        g ? "32.9 / 70.6 / 28.4 / 2.2 | 10 / 5 / 2 / 0 | 4 / 1 / 1 / 0" : "69.9 / 103.0 / 41.1 / 4.9 | 24 / 10 / 5 / 1 | 12 / 4 / 2 / 3");
                            {
                                long tn = 0; for (int b = 0; b < 4; ++b) tn += S.rs_sn[g][b];
                                std::printf("\n          mate's pass, the man nearest at the touch by his m at the release 0-5/5-10/10-15/15+: share");
                                for (int b = 0; b < 4; ++b) std::printf(" %.0f", 100.0 * S.rs_sn[g][b] / std::max(1L, tn));
                                std::printf("%% | closed med"); for (int b = 0; b < 4; ++b) std::printf(" %.2f", qf(S.rs_sc[g][b], .5));
                                std::printf(" m | inside 3 m at the touch"); for (int b = 0; b < 4; ++b) std::printf(" %.0f", 100.0 * S.rs_s3[g][b] / std::max(1L, S.rs_sn[g][b]));
                                std::printf("%%  (%s)", g ? "5 / 25 / 36 / 33 | 1.07 / 1.68 / 2.99 / 4.58 | 66 / 7 / 1 / 0" : "12 / 28 / 31 / 29 | 0.83 / 2.17 / 3.29 / 4.90 | 71 / 13 / 3 / 0");
                            }
                            if (g == 1) std::printf(" | by the receiver's m off own goal 0-35/35-70/70+: n %.1f / %.1f / %.1f, inside 3 m %.0f / %.0f / %.0f%%", S.rs_zn[0] / tmn, S.rs_zn[1] / tmn, S.rs_zn[2] / tmn, 100.0 * S.rs_z3[0] / std::max(1L, S.rs_zn[0]), 100.0 * S.rs_z3[1] / std::max(1L, S.rs_zn[1]), 100.0 * S.rs_z3[2] / std::max(1L, S.rs_zn[2]));
                        }
                    }
                    {   // §8.180 KICK FOOT v benchmarks_statsbomb_foot.py (StatsBomb PL 15/16)
                        long nw = 0, ns = 0; for (int lb = 0; lb < 3; ++lb) { ns += S.kf_n[0][lb]; nw += S.kf_n[1][lb]; }
                        static const double rS[3] = {87.6, 86.3, 58.8}, rW[3] = {85.4, 85.2, 54.2};
                        std::printf("\n        KICK FOOT (open-play passes; real StatsBomb PL 15/16 in brackets): weak foot %.1f%% (13.8) | completed strong / weak by length 0-15 / 15-30 / 30+ m:", 100.0 * nw / std::max(1L, nw + ns));
                        for (int lb = 0; lb < 3; ++lb) std::printf(" %.1f / %.1f (%.1f / %.1f)", 100.0 * S.kf_ok[0][lb] / std::max(1L, S.kf_n[0][lb]), 100.0 * S.kf_ok[1][lb] / std::max(1L, S.kf_n[1][lb]), rS[lb], rW[lb]);
                        std::printf(" | short passes by set-up wait 0 / 1-3 / 4-8 / 9+ ticks: n %ld %ld %ld %ld completed %.1f %.1f %.1f %.1f", S.kw_n[0], S.kw_n[1], S.kw_n[2], S.kw_n[3],
                                    100.0 * S.kw_ok[0] / std::max(1L, S.kw_n[0]), 100.0 * S.kw_ok[1] / std::max(1L, S.kw_n[1]), 100.0 * S.kw_ok[2] / std::max(1L, S.kw_n[2]), 100.0 * S.kw_ok[3] / std::max(1L, S.kw_n[3]));
                        std::printf(" | waited for a plant %.0f a team-match, %.0f ms on average; given up (never in reach) %.1f", S.kf_wait / tmn, 1000.0 * S.kf_wt / std::max(1L, S.kf_wait) / 30.0, S.kf_cancel / tmn);
                    }
                    {   // §8.179 CARRY v benchmarks_tracking_carry.py (DFL 7 matches)
                        static const double rM[7] = {0.44, 0.52, 0.59, 0.63, 0.69, 0.76, 0.79}, rQ[7] = {0.03, 0.23, 0.35, 0.41, 0.49, 0.55, 0.60}, rN[7] = {0.93, 1.02, 1.06, 1.07, 1.13, 1.19, 1.24},
                                            rS[7] = {0.28, 0.27, 0.25, 0.24, 0.23, 0.20, 0.18}, rT[7] = {0.88, 0.96, 0.94, 0.90, 0.88, 0.93, 0.99}, rI[7] = {0.68, 0.76, 0.88, 0.88, 0.88, 0.88, 0.88}, rP[7] = {0.57, 0.62, 0.72, 0.79, 0.82, 0.88, 0.95};
                        auto qc = [](std::vector<double> v, double p) { if (v.empty()) return 0.0; std::sort(v.begin(), v.end()); return v[std::min(v.size() - 1, static_cast<std::size_t>(v.size() * p))]; };
                        std::printf("\n        CARRY: lost to a heavy touch %.2f a team-match (StatsBomb PL 15/16 open-play losses by miscontrol 4.1), stolen off his feet %.2f (by a duel / dispossessed 8.0)", S.cr_lost / tmn, S.cr_steal / tmn);
                        std::printf("\n        CARRY (carrier 1 m/s+, ball on the ground; real DFL carries in brackets), by his speed m/s: ball ahead p25 / med / p90 m | side med m | touches/s | interval med s | farthest ahead between touches med m");
                        for (int bi = 0; bi < 7; ++bi) {
                            const double secs = S.cr_f[bi] / 30.0;
                            std::printf("\n          %d-%s  %5.2f / %5.2f / %5.2f (%4.2f / %4.2f / %4.2f) | %4.2f (%4.2f) | %4.2f (%4.2f) | %4.2f (%4.2f) | %4.2f (%4.2f)", bi + 1, bi == 6 ? "+ " : std::to_string(bi + 2).c_str(),
                                        qc(S.cr_ah[bi], .25), qc(S.cr_ah[bi], .5), qc(S.cr_ah[bi], .9), rQ[bi], rM[bi], rN[bi], qc(S.cr_sd[bi], .5), rS[bi],
                                        S.cr_t[bi] / std::max(1e-9, secs), rT[bi], qc(S.cr_iv[bi], .5), rI[bi], qc(S.cr_pk[bi], .5), rP[bi]);
                        }
                    }
                    {   // §8.178 BODY ENVELOPE v benchmarks_tracking_envelope.py (DFL 7 matches)
                        static const double rA[9][2] = {{2.6, 4.4}, {2.5, 4.2}, {3.0, 4.6}, {2.8, 4.1}, {2.7, 3.7}, {2.5, 3.2}, {2.1, 2.7}, {1.7, 2.4}, {0, 0}};
                        static const double rB[9][2] = {{2.9, 4.8}, {2.7, 4.7}, {3.2, 5.3}, {3.0, 5.1}, {3.2, 5.2}, {3.3, 5.1}, {3.2, 4.8}, {3.0, 4.7}, {0, 0}};
                        static const double rL[9][2] = {{2.5, 4.3}, {2.5, 4.2}, {3.3, 5.2}, {3.5, 5.4}, {3.9, 5.8}, {4.2, 5.9}, {4.3, 6.1}, {4.1, 5.8}, {0, 0}};
                        static const double rR[9] = {0.10, 0.39, 1.04, 2.04, 3.20, 4.71, 6.40, 9.05, 0}, rT[9] = {12.9, 32.0, 21.1, 17.9, 9.3, 4.2, 1.8, 0.6, 0.2};
                        auto qv = [](std::vector<double> v, double p) { if (v.empty()) return 0.0; std::sort(v.begin(), v.end()); return v[std::min(v.size() - 1, static_cast<std::size_t>(v.size() * p))]; };
                        long tot = 0; for (long x : S.ev_n) tot += x;
                        std::printf("\n        BODY ENVELOPE (outfielders, in play; real DFL in brackets), by speed m/s: share of time %% | speeding up p95 / p99 | braking p95 / p99 | lateral p95 / p99 m/s2 | tightest turn radius p1 m");
                        for (int bnd = 0; bnd < 8; ++bnd)
                            std::printf("\n          %d-%d %5.1f (%4.1f) | %4.1f / %4.1f (%3.1f / %3.1f) | %4.1f / %4.1f (%3.1f / %3.1f) | %4.1f / %4.1f (%3.1f / %3.1f) | %5.2f (%5.2f)", bnd, bnd + 1,
                                        100.0 * S.ev_n[bnd] / std::max(1L, tot), rT[bnd], qv(S.ev_acc[bnd], .95), qv(S.ev_acc[bnd], .99), rA[bnd][0], rA[bnd][1],
                                        qv(S.ev_brk[bnd], .95), qv(S.ev_brk[bnd], .99), rB[bnd][0], rB[bnd][1], qv(S.ev_lat[bnd], .95), qv(S.ev_lat[bnd], .99), rL[bnd][0], rL[bnd][1], qv(S.ev_rad[bnd], .01), rR[bnd]);
                    }
                    std::printf("\n        HEADERS (benchmarks_statsbomb_aerial.py, real PL 15/16 in brackets): aerial duels a match %.1f (44.1), lone headers a match %.1f, headed clearances a team %.1f (16.1), headers at goal a team %.1f", S.aer_d / static_cast<double>(matches), S.aer_l / static_cast<double>(matches), S.aer_c / tmn, S.aer_g / tmn);
                    {
                        static const double rN[3] = {15.5, 41.8, 27.6}, rA[3] = {1.7, 1.8, 1.8}, rD[3] = {2.0, 1.6, 1.2}, rB[3] = {36.4, 39.3, 43.0}, rO[3] = {49.8, 56.8, 65.3}, rX[3] = {24.0, 19.3, 18.7}, rL[3] = {61.8, 71.6, 74.4};
                        static const char* hzn[3] = {"0-35", "35-70", "70+"};
                        auto md2 = [](std::vector<double> v) { if (v.empty()) return 0.0; std::sort(v.begin(), v.end()); return v[v.size() / 2]; };
                        {   // §8.173 (benchmarks_tracking_marking.py)
                            static const double rM[2][3] = {{81.4, 125.9, 41.5}, {9.4, 30.7, 9.5}}, rR[2][3] = {{13.8, 8.3, 5.0}, {8.7, 4.7, 3.4}}, r2[2][3] = {{2.2, 4.5, 12.7}, {7.6, 15.1, 24.1}}, r35[2][3] = {{5.9, 13.6, 32.7}, {16.7, 35.3, 51.1}}, r5[2][3] = {{89.7, 75.6, 50.3}, {72.0, 47.2, 26.3}}, rP[2][3] = {{7.9, 5.7, 4.0}, {4.3, 4.4, 3.5}}, rLn[2][3] = {{18.4, 16.2, 12.9}, {17.3, 19.2, 15.0}},
                                                rAm[2][3] = {{7.9, 6.3, 4.1}, {5.3, 5.3, 3.6}}, rA2[2][3] = {{5.5, 6.7, 18.8}, {11.9, 10.2, 21.6}}, rA5[2][3] = {{72.3, 63.0, 39.0}, {51.8, 54.5, 32.5}};
                            std::printf("\n        RECEIVER'S MARKER AT THE KICK, completed open-play passes (benchmarks_tracking_marking.py, real DFL in brackets; high = peak 1.5 m+), by the receiver's m off the passer's own goal: a team-match | receiver's nearest opponent med | within 2 m %% | within 3.5 m %% | 5 m+ free %% | passer's nearest opponent med | length med");
                            for (int hi = 0; hi < 2; ++hi) for (int z = 0; z < 3; ++z) if (S.mk_n[hi][z]) {
                                const double n = S.mk_n[hi][z];
                                std::printf("\n          %s %-5s %5.1f (%4.1f) | %4.1f (%4.1f) | %4.1f (%4.1f) | %4.1f (%4.1f) | %4.1f (%4.1f) | %4.1f (%3.1f) | %4.1f (%4.1f)", hi ? "high" : "flat", hzn[z], n / tmn, rM[hi][z], md2(S.mk_r[hi][z]), rR[hi][z],
                                            100 * S.mk_2[hi][z] / n, r2[hi][z], 100 * S.mk_35[hi][z] / n, r35[hi][z], 100 * S.mk_5[hi][z] / n, r5[hi][z], md2(S.mk_pa[hi][z]), rP[hi][z], md2(S.mk_len[hi][z]), rLn[hi][z]);
                                long a2 = 0, a5 = 0; for (double d : S.mk_al[hi][z]) { a2 += d < 2; a5 += d >= 5; }
                                const double na = std::max<std::size_t>(1, S.mk_al[hi][z].size());
                                std::printf(" || every mate in that zone then: med %4.1f (%3.1f), within 2 m %4.1f%% (%4.1f), 5 m+ %4.1f%% (%4.1f)", md2(S.mk_al[hi][z]), rAm[hi][z], 100 * a2 / na, rA2[hi][z], 100 * a5 / na, rA5[hi][z]);
                            }
                        }
                        {   // §8.173 (benchmarks_tracking_markers.py)
                            static const double rMd[2][4][2] = {{{2.5, 2.6}, {3.8, 4.6}, {4.4, 5.6}, {5.2, 7.4}}, {{2.6, 2.6}, {3.8, 4.5}, {4.7, 5.7}, {6.7, 8.7}}},
                                                rM2[2][4][2] = {{{39.0, 36.7}, {18.4, 13.3}, {14.1, 9.4}, {12.4, 5.9}}, {{34.1, 35.1}, {17.1, 13.7}, {11.4, 8.6}, {7.1, 4.0}}},
                                                rMg[2][4][2] = {{{72.7, 72.5}, {73.9, 71.0}, {70.6, 74.4}, {72.2, 75.7}}, {{74.7, 77.3}, {75.3, 71.6}, {73.3, 75.4}, {80.0, 78.7}}},
                                                rCd[3][5] = {{3.2, 3.9, 4.6, 5.0, 5.0}, {3.7, 4.3, 5.4, 5.8, 6.3}, {4.1, 4.5, 4.9, 5.2, 5.7}}, rC3[3][5] = {{46.7, 36.2, 28.7, 23.7, 25.5}, {40.0, 32.3, 21.7, 19.8, 18.5}, {33.9, 27.6, 23.4, 20.9, 19.3}};
                            static const char* mzn[4] = {"0-18", "18-35", "35-52", "52+"};
                            for (int s2 = 0; s2 < 2; ++s2) {
                                std::printf("\n        MARKING, EVERY FRAME %s (benchmarks_tracking_markers.py, real DFL in brackets): each attacker by his m off their goal, ball within 20 m of him || further: nearest defender med | within 2 m %% | goal-side %%", s2 ? "settled 6 s+" : "all");
                                for (int z = 0; z < 4; ++z) {
                                    std::printf("\n          %-5s", mzn[z]);
                                    for (int nb = 0; nb < 2; ++nb) { const double n = std::max(1L, S.mf_n[s2][z][nb]);
                                        std::printf("%s%4.1f (%3.1f) | %4.1f (%4.1f) | %4.1f (%4.1f)", nb ? "  ||  " : " ", md2(S.mf_d[s2][z][nb]), rMd[s2][z][nb], 100 * S.mf_2[s2][z][nb] / n, rM2[s2][z][nb], 100 * S.mf_gs[s2][z][nb] / n, rMg[s2][z][nb]); }
                                }
                            }
                            std::printf("\n        marked (G5.72): each attacker by his m off their goal: share with a marker %% | marker off him med | marker goal-side %%");
                            for (int z = 0; z < 4; ++z) std::printf(" || %s %4.1f%% %4.1f %4.1f%%", mzn[z], 100.0 * S.mf_mk[z] / std::max(1L, S.mf_all[z]), md2(S.mf_md[z]), 100.0 * S.mf_mgs[z] / std::max(1L, S.mf_mk[z]));
                            std::printf("\n        each CB / FB / DM by the ball's 18 m band off his own line: nearest attacker med | within 3 m %%");
                            static const char* rn3[3] = {"CB", "FB", "DM/CM"};
                            for (int r = 0; r < 3; ++r) { std::printf("\n          %-5s", rn3[r]);
                                for (int bb = 0; bb < 5; ++bb) { const double n = std::max(1L, S.mf_cn[r][bb]); std::printf(" %4.1f (%3.1f) %4.1f%% (%4.1f) |", md2(S.mf_cb[r][bb]), rCd[r][bb], 100 * S.mf_c3[r][bb] / n, rC3[r][bb]); } }
                        }
                        std::printf("\n        HIGH BALLS COMING DOWN through 2.4 m in open play (benchmarks_tracking_aerial.py, real DFL in brackets), by m off the kicker's own goal: a team-match | nearest of the kicker's side med | of the other side med | both within 2 m %% | other side within 2 m %% | nobody within 3 m %% | other side touches it within 3 s %%");
                        for (int z = 0; z < 3; ++z) if (S.hb_n[z]) {
                            const double n = S.hb_n[z];
                            std::printf("\n          %-5s %5.1f (%4.1f) | %4.1f (%3.1f) | %4.1f (%3.1f) | %4.1f (%4.1f) | %4.1f (%4.1f) | %4.1f (%4.1f) | %4.1f (%4.1f)", hzn[z], n / tmn, rN[z], md2(S.hb_a[z]), rA[z], md2(S.hb_d[z]), rD[z],
                                        100 * S.hb_both[z] / n, rB[z], 100 * S.hb_o2[z] / n, rO[z], 100 * S.hb_none[z] / n, rX[z], 100 * S.hb_lost[z] / n, rL[z]);
                            std::printf(" || what:"); for (int w = 0; w <= ai::kWhyCount; ++w) if (S.hb_why[z][w] * 100 >= 5 * n) std::printf(" %s %.0f%%", w < ai::kWhyCount ? ai::kWhyNames[w] : "header/deflection", 100 * S.hb_why[z][w] / n);
                            std::printf(", kicked from %.1f m off his goal", md2(S.hb_from[z]));
                            std::printf(" || their chaser then %4.1f%%, off the ball %4.1f m, his target off it %4.1f m, at %3.1f m/s", 100 * S.hb_c[z] / n, md2(S.hb_cd[z]), md2(S.hb_ct[z]), md2(S.hb_cv[z]));
                            std::printf("\n                 §8.174 the other side's nearest at the drop, by job: ");
                            for (int w = 0; w < ai::kWhyCount; ++w) if (S.hn_why[z][w] * 100 >= 3 * n) std::printf(" %s %.0f%% (%.1f m)", ai::kWhyNames[w], 100 * S.hn_why[z][w] / n, md2(S.hn_d[z][w]));
                            if (S.hm_n[z]) std::printf(" || the kicker's side's nearest marked %.0f%%, marker off him %.1f m", 100.0 * S.hm_on[z] / S.hm_n[z], md2(S.hm_d[z]));
                            {   // §8.185 AT THE LAUNCH v benchmarks_tracking_aerial.py
                                static const char* rl[3] = {"9.4 | 8.8 | 6.9 | 2.76 | 2.21", "8.4 | 8.3 | 7.1 | 3.04 | 1.92", "9.7 | 10.9 | 5.1 | 2.52 | 2.72"};
                                std::printf("\n                 §8.185 at the launch, the men nearest at the drop: defender off the drop med %.1f | attacker off it %.1f | defender off the attacker %.1f | flight %.2f s | defender closing %.2f m/s  (%s)",
                                            md2(S.hl_d[z]), md2(S.hl_a[z]), md2(S.hl_da[z]), md2(S.hl_t[z]), md2(S.hl_v[z]), rl[z]);
                                std::printf("\n                 §8.185 that defender through the flight, s since the launch: off the drop m / his target off it m / speed m/s / jobs");
                                if (S.hf_all[z]) std::printf(" — never chased it %.0f%%, began chasing at med %.2f s", 100.0 * S.hf_never[z] / S.hf_all[z], md2(S.hf_c0[z]));
                                for (int bi = 0; bi < 8; ++bi) if (S.hf_n[z][bi]) {
                                    std::printf("\n                   %.1f-%s %5.1f / %5.1f / %4.1f |", bi * 0.5, bi == 7 ? "   " : (std::to_string(bi * 0.5 + 0.5).substr(0, 3)).c_str(), md2(S.hf_d[z][bi]), md2(S.hf_t[z][bi]), md2(S.hf_v[z][bi]));
                                    for (int w = 0; w <= ai::kWhyCount; ++w) if (S.hf_w[z][bi][w] * 100 >= 5 * S.hf_n[z][bi]) std::printf(" %s %.0f%%", w < ai::kWhyCount ? ai::kWhyNames[w] : "-", 100.0 * S.hf_w[z][bi][w] / S.hf_n[z][bi]);
                                    if (!S.hf_cv[z][bi].empty()) std::printf(" || chasing: off the drop %.1f, speed %.1f", md2(S.hf_cd[z][bi]), md2(S.hf_cv[z][bi]));
                                }
                            }
                        }
                    }
                    static const double rU[21] = {6.6, 9.6, 14.2, 16.8, 19.8, 22.9, 25.6, 28.9, 31.3, 34.0, 37.4, 40.4, 42.7, 45.1, 48.0, 49.9, 52.3, 54.2, 56.5, 57.8, 60.5};
                    std::printf("\n        its line in all possession frames, ball 5 m bins off its goal (real):");
                    for (int b5 = 0; b5 < 21; ++b5) if (S.tn_an[b5]) std::printf(" %d %.1f (%.1f);", b5 * 5, S.tn_as[b5] / S.tn_an[b5], rU[b5]);
                }
                static const char* zbn[4] = {"ball 0-35", "35-52", "52-70", "70+"};
                static const double rL[4] = {11.5, 25.2, 36.9, 50.5}, rA[4] = {12.1, 27.7, 41.0, 53.0};
                std::printf("\n     in the spell's first second, m off their goal, their line (real) / our front man (real):");
                for (int z = 0; z < 4; ++z) {
                    if (S.ft_L[z].empty()) continue;
                    std::vector<double> v = S.ft_L[z], w = S.ft_A[z];
                    std::sort(v.begin(), v.end()); std::sort(w.begin(), w.end());
                    std::printf(" %s %.1f (%.1f) / %.1f (%.1f);", zbn[z], v[v.size() / 2], rL[z], w[w.size() / 2], rA[z]);
                }
            }
            const double e = static_cast<double>(std::max<std::size_t>(1, S.fe_ten.size()));
            std::printf("\n     the engine's front JOB: changes %.1f a team-match, tenure %s s; old man on the ball %.0f%% / the pass's man %.0f%% / box runner %.0f%% / channel run %.0f%% / overtaken by a freed man %.0f%% / overtaken %.0f%%; new man's gap %s, moved on over 2 s %s m",
                        e / tm, a6, 100 * S.fe_why[0] / e, 100 * S.fe_why[1] / e, 100 * S.fe_why[2] / e, 100 * S.fe_why[3] / e, 100 * S.fe_why[4] / e, 100 * S.fe_why[5] / e, a7, a8);
        }
        if (S.is_n) {   // §8.156: the ball into space (G5.54), how it ends
            const double n = static_cast<double>(S.is_n);
            std::printf("\n   BALLS INTO SPACE (G5.54): %.1f a team-match; got by him %.0f%% / a mate %.0f%% / them %.0f%% / out %.0f%% / nobody %.0f%%; at the kick him %.1f m from the spot, their nearest %.1f m; his closest to the ball %.1f m after %.1f s, then %.1f m from the spot",
                        n / tm, 100 * S.is_got[0] / n, 100 * S.is_got[1] / n, 100 * S.is_got[2] / n, 100 * S.is_got[3] / n, 100 * S.is_got[4] / n, S.is_rd0 / n, S.is_od0 / n, S.is_best / std::max(1L, S.is_bn), S.is_t / std::max(1L, S.is_bn), S.is_spot / std::max(1L, S.is_bn));
        }
        {   // §8.160: mates by zone (not the man on the ball), by the ball's zone; real DFL benchmarks_tracking_zonemates.py
            static const char* bn[5] = {"0-18", "18-35", "35-52", "52-70", "70+"}; static const char* sd[3] = {"centre", "wide", "far wide"};
            std::printf("\n   MATES BY ZONE, by the ball's zone (mean, none %%):");
            for (int bz : {1, 3, 4, 6, 7}) if (S.zm_f[bz]) {
                std::printf("\n     ball %s %s:", bn[bz / 3], sd[bz % 3]);
                for (int z = 0; z < 15; ++z) if (S.zm_n[bz][z]) std::printf(" %s %s %.2f (%.0f%%);", bn[z / 3], sd[z % 3], static_cast<double>(S.zm_n[bz][z]) / S.zm_f[bz], 100.0 * S.zm_0[bz][z] / S.zm_f[bz]);
                static const char* rn[ai::kRoleCount] = {"CB", "FB", "DM/CM", "AM", "WIDE", "ST"};
                const double f = static_cast<double>(S.zm_f[bz]);
                std::printf("\n       on the ball:"); for (int r = 0; r < ai::kRoleCount; ++r) std::printf(" %s %.0f%%", rn[r], 100 * S.zm_c[bz][r] / f);
                for (int z = 1; z < 15; z += 3)   // §8.190: ST / AM / WIDE share of their frames in each ball-side wide zone, and where
                    for (int r : {5, 3, 4}) {
                        const long n = S.zm_r[bz][z][r]; if (n < 0.02 * f) continue;
                        long tot = S.zm_c[bz][r]; for (int zz = 0; zz < 15; ++zz) tot += S.zm_r[bz][zz][r];
                        std::printf("\n       %s in %s %s: %.1f%% of his frames, m off their line %.1f, |y| %.1f", rn[r], bn[z / 3], sd[z % 3],
                                    100.0 * n / std::max(1L, tot), S.zm_tl[bz][z][r] / n, S.zm_ay[bz][z][r] / n);
                    }
                for (int z = 0; z < 15; ++z) if (S.zm_n[bz][z] >= 0.3 * f) {   // §8.189: who stands there
                    std::printf("\n       in %s %s by role:", bn[z / 3], sd[z % 3]);
                    for (int r = 0; r < ai::kRoleCount; ++r) std::printf(" %s %.2f", rn[r], S.zm_r[bz][z][r] / f);
                }
            }
        }
        {   // §8.155: real StatsBomb benchmarks_statsbomb_wide.py
            static const double kF[6] = {78, 11, 5, 4, 2, 0};
            static const char* kFn[6] = {"18-35 wide", "0-18 wide", "18-35 centre", "35+ wide", "0-18 centre", "35+ centre"};
            static const double kA[9] = {30.2, 16.9, 14.5, 13.3, 9.7, 7.0, 5.9, 2.2, 0}, kAo[9] = {24.7, 16.3, 10.2, 0, 8.0, 0, 2.4, 0, 0};
            static const char* kAn[9] = {"pass to 18-35 wide", "pass to 35+", "pass to 0-18 wide", "lost", "pass to 18-35 centre", "cross", "pass to 0-18 centre", "shot", "other"};
            long t = 0; for (long v : S.ws_from) t += v;
            std::printf("\n   SPELLS STARTING WIDE (|y| 14+) 18-35 m out: %.1f a team-match (57.8 real StatsBomb); let go from:", S.ws_n / tm);
            for (int i = 0; i < 6; ++i) std::printf(" %s %.0f%% (%.0f);", kFn[i], 100.0 * S.ws_from[i] / std::max(1L, t), kF[i]);
            std::printf("\n     let go as, %% of spells (real) [completed]:");
            for (int i = 0; i < 8; ++i) std::printf(" %s %.1f (%.1f) [%.1f (%.1f)];", kAn[i], 100.0 * S.ws_as[i] / std::max(1L, t), kA[i], 100.0 * S.ws_ok[i] / std::max(1L, t), kAo[i]);
        }
        {   // §8.152b: their line's spread, real DFL benchmarks_tracking_box.py
            static const int kLq[6][5] = {{2, 4, 7, 10, 13}, {2, 5, 8, 11, 13}, {11, 14, 18, 22, 26}, {11, 14, 17, 22, 26}, {19, 22, 27, 33, 37}, {19, 23, 27, 32, 36}};
            static const int kL16[6] = {97, 97, 35, 38, 3, 3};
            std::printf("\n     their line (min with the ball) p10/p25/p50/p75/p90 m, inside 16 m %% (real DFL):");
            for (int z = 0; z < 6; ++z) {
                long t = 0; for (long v : S.lq_h[z]) t += v;
                if (!t) continue;
                auto q = [&](double f) { long acc = 0; for (int m = 0; m <= 60; ++m) { acc += S.lq_h[z][m]; if (acc >= f * t) return m; } return 60; };
                long in16 = 0; for (int m = 0; m < 16; ++m) in16 += S.lq_h[z][m];
                std::printf(" %s %d/%d/%d/%d/%d (%d/%d/%d/%d/%d) %.0f%% (%d);", bzn[z], q(.1), q(.25), q(.5), q(.75), q(.9), kLq[z][0], kLq[z][1], kLq[z][2], kLq[z][3], kLq[z][4], 100.0 * in16 / t, kL16[z]);
            }
        }
        std::printf("\n     their deepest outfielder / their CBs' mean / the next man higher, m (real DFL); deepest by role CB FB DM AM WIDE ST %%:");
        static const double real_deep[6] = {8.7, 9.0, 18.8, 18.5, 28.2, 27.8}, real_cbm[6] = {11.2, 11.5, 21.1, 20.3, 30.4, 29.8}, real_gap2[6] = {1.6, 1.9, 1.4, 1.5, 1.6, 1.6};
        for (int z = 0; z < 4; ++z) if (S.bx_f[z]) {
            long dn = 0; for (int r = 0; r < ai::kRoleCount; ++r) dn += S.bx_drole[z][r];
            std::printf(" %s %.1f (%.1f) / %.1f (%.1f) / %.1f (%.1f) [", bzn[z], S.bx_deep[z] / std::max(1L, dn), real_deep[z], S.bx_cbm[z] / std::max(1L, dn), real_cbm[z], S.bx_gap2[z] / std::max(1L, dn), real_gap2[z]);
            for (int r = 0; r < ai::kRoleCount; ++r) std::printf("%s%.0f", r ? " " : "", 100.0 * S.bx_drole[z][r] / std::max(1L, dn));
            std::printf("];");
        }
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
        {   // §8.186 GOAL-SIDE — benchmarks_tracking_goalside.py
            static const char* bl[4] = {"<12", "12-18", "18-25", "25-30"};
            static const double rs[4] = {3.6, 10.4, 24.4, 30.4}; static const int rq[4][3] = {{0, 2, 3}, {2, 3, 5}, {3, 5, 6}, {4, 6, 8}};
            static const double rk[4][4] = {{25.3, 39.0, 26.1, 9.6}, {10.8, 25.6, 32.2, 31.4}, {6.7, 17.3, 24.8, 51.1}, {2.6, 9.8, 23.8, 63.8}};
            static const double rd[4][3] = {{-0.7, 0.4, 2.2}, {-1.0, 1.4, 5.0}, {-0.6, 2.7, 6.3}, {1.2, 5.3, 8.8}};
            std::printf("   GOAL-SIDE (5 Hz, ball under 7 m/s; their outfielders nearer their goal centre than the ball; real DFL in brackets):\n");
            for (int d = 0; d < 4; ++d) {
                auto v = S.gsd_g[d]; auto w = S.gsd_deep[d]; if (v.empty()) continue;
                std::sort(v.begin(), v.end()); std::sort(w.begin(), w.end()); const double n = static_cast<double>(v.size());
                std::printf("     ball %-5s m: %.1f s a team-match (%.1f) | goal-side p25/med/p75 %d / %d / %d (%d / %d / %d) | 0 %.1f%% (%.1f) 1-2 %.1f (%.1f) 3-4 %.1f (%.1f) 5+ %.1f (%.1f) | deepest above the ball %.1f / %.1f / %.1f (%.1f / %.1f / %.1f)\n",
                            bl[d], n * 0.2 / tm, rs[d], v[v.size() / 4], v[v.size() / 2], v[v.size() * 3 / 4], rq[d][0], rq[d][1], rq[d][2],
                            100 * S.gsd_k[d][0] / n, rk[d][0], 100 * S.gsd_k[d][1] / n, rk[d][1], 100 * S.gsd_k[d][2] / n, rk[d][2], 100 * S.gsd_k[d][3] / n, rk[d][3],
                            w[w.size() / 4], w[w.size() / 2], w[w.size() * 3 / 4], rd[d][0], rd[d][1], rd[d][2]);
                {   // §8.187 — benchmarks_tracking_goalside.py
                    static const int rdl[4][3] = {{0, 1, 3}, {0, 2, 5}, {0, 3, 5}, {1, 4, 6}}, rbx[4][3] = {{4, 6, 8}, {3, 5, 7}, {1, 4, 5}, {0, 2, 5}};
                    static const double ray[4][3] = {{1.6, 4.1, 7.9}, {1.7, 4.8, 9.9}, {3.0, 7.8, 14.2}, {3.2, 9.0, 17.4}}, rby[4] = {5.2, 10.1, 15.4, 18.7};
                    auto q = [](std::vector<int> x, double f) { std::sort(x.begin(), x.end()); return x.empty() ? 0 : x[static_cast<std::size_t>(x.size() * f)]; };
                    auto qd = [](std::vector<double> x, double f) { std::sort(x.begin(), x.end()); return x.empty() ? 0.0 : x[static_cast<std::size_t>(x.size() * f)]; };
                    std::printf("            deeper than the ball %d / %d / %d (%d / %d / %d) | in their box %d / %d / %d (%d / %d / %d) | those deeper, m across from the ball %.1f / %.1f / %.1f (%.1f / %.1f / %.1f) | ball |y| med %.1f (%.1f)\n",
                                q(S.gsd_dl[d], .25), q(S.gsd_dl[d], .5), q(S.gsd_dl[d], .75), rdl[d][0], rdl[d][1], rdl[d][2],
                                q(S.gsd_box[d], .25), q(S.gsd_box[d], .5), q(S.gsd_box[d], .75), rbx[d][0], rbx[d][1], rbx[d][2],
                                qd(S.gsd_ay[d], .25), qd(S.gsd_ay[d], .5), qd(S.gsd_ay[d], .75), ray[d][0], ray[d][1], ray[d][2], qd(S.gsd_by[d], .5), rby[d]);
                }
            }
        }
        {   // §8.186 IN BEHIND THEN — benchmarks_tracking_behind.py
            static const double rs[2] = {18.6, 6.8}, rg[2] = {3.6, 1.3}, rn[2] = {15.7, 22.0};
            std::printf("     IN BEHIND THEN (a shot / goal by the passer's side within 10 s; real DFL in brackets):");
            for (int h = 1; h >= 0; --h) {
                const long n = S.bt_n[h][0] + S.bt_n[h][1], sh = S.bt_shot[h][0] + S.bt_shot[h][1], gl = S.bt_goal[h][0] + S.bt_goal[h][1];
                std::printf(" %s %.1f a team-match (%.1f): shot %.1f%% (%.1f) goal %.1f%% (%.1f) [%ld goals];", h ? "high" : "flat", n / tm, rn[h],
                            100.0 * sh / std::max(1L, n), rs[h], 100.0 * gl / std::max(1L, n), rg[h], gl);
            }
            for (int o = 1; o >= 0; --o) {
                const long n = S.bt_n[0][o] + S.bt_n[1][o], sh = S.bt_shot[0][o] + S.bt_shot[1][o], gl = S.bt_goal[0][o] + S.bt_goal[1][o];
                std::printf(" %s shot %.1f%% (%s) goal %.1f%% (%s);", o ? "completed" : "not completed", 100.0 * sh / std::max(1L, n), o ? "21.5" : "2.9",
                            100.0 * gl / std::max(1L, n), o ? "4.4" : "0.4");
            }
            std::printf("\n");
        }
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
        {   // §8.189 SLIDE BY ROLE — benchmarks_tracking_slide.py (DFL)
            static const char* rn[ai::kRoleCount] = {"CB", "FB", "DM/CM", "AM", "WIDE", "ST"};
            static const double rs[ai::kRoleCount] = {0.33, 0.24, 0.40, 0.34, 0.32, 0.30}, rnr[ai::kRoleCount] = {14.2, 27.2, 14.3, 13.4, 20.0, 10.8}, rfr[ai::kRoleCount] = {6.9, 15.9, 7.9, 5.8, 10.8, 4.5};
            std::printf("SLIDE BY ROLE (§8.189; in possession, ball 25-60 m off their line, the man on the ball out; real DFL in brackets): slope of his y on the ball's y | |y| med, ball wide (14+) his side / far side\n  ");
            for (int r = 0; r < ai::kRoleCount; ++r) {
                if (S.sl_xx[r] <= 0) continue;
                auto med = [](std::vector<double> v) { if (v.empty()) return 0.0; std::sort(v.begin(), v.end()); return v[v.size() / 2]; };
                std::printf(" %s %.2f (%.2f) | %.1f (%.1f) / %.1f (%.1f);", rn[r], S.sl_xy[r] / S.sl_xx[r], rs[r], med(S.sl_w[r][0]), rnr[r], med(S.sl_w[r][1]), rfr[r]);
            }
            std::printf("\n");
        }
        {   // §8.188 INWARD — benchmarks_tracking_inward.py (DFL)
            static const double rn[2][3] = {{25.9, 46.7, 108.2}, {32.8, 47.8, 59.3}}, ry[2][3] = {{2.3, -8.7, 10.0}, {-25.1, -180.5, -188.9}},
                                rx[2][3] = {{41.6, 91.2, 172.2}, {208.0, 270.3, 234.9}};
            static const char* yl[3] = {"centre 0-9", "mid 9-20", "wide 20+"};
            std::printf("INWARD (§8.188; 5 Hz, the attack's ball within 35 m of the goal line it attacks, a team-match; real DFL in brackets):\n");
            for (int kk = 0; kk < 2; ++kk) {
                std::printf("   %s:", kk ? "passed (7+ m/s)" : "carried (under 7 m/s)");
                for (int yb = 0; yb < 3; ++yb)
                    std::printf(" from %s %.1f s (%.1f), |y| %+.1f m (%+.1f), toward the line %+.1f m (%+.1f);", yl[yb], S.iw_n[kk][yb] * 0.2 / tm, rn[kk][yb],
                                S.iw_dy[kk][yb] / tm, ry[kk][yb], S.iw_dx[kk][yb] / tm, rx[kk][yb]);
                std::printf("\n");
            }
            {   // §8.188 RELEASES BY ZONE — benchmarks_statsbomb_cross.py crosses (StatsBomb PL 15/16)
                static const double rn[3][3] = {{2.5, 3.0, 1.1}, {12.0, 7.6, 4.6}, {18.2, 15.3, 14.3}}, rc[3][3] = {{32, 54, 51}, {25, 31, 1}, {10, 6, 0}};
                static const char* zl[3] = {"0-6", "6-18", "18-30"}; static const char* yl2[3] = {"wide 24+", "half-space 14-24", "centre"};
                std::printf("   RELEASES BY ZONE (open-play passes, m off their line x |y|; a team-match, cross %%; real StatsBomb PL 15/16 in brackets):");
                for (int zx = 0; zx < 3; ++zx) {
                    std::printf("\n      %-5s:", zl[zx]);
                    for (int ay = 0; ay < 3; ++ay)
                        std::printf(" %s %.1f (%.1f) cross %.0f%% (%.0f);", yl2[ay], S.xz_n[zx][ay] / tm, rn[zx][ay], 100.0 * S.xz_c[zx][ay] / std::max(1L, S.xz_n[zx][ay]), rc[zx][ay]);
                }
                std::printf("\n");
            }
            {   // §8.191 DOWN THE LINE by kind
                long n = 0; for (long v : S.dwl_n) n += v;
                std::printf("   DOWN THE LINE (spells starting wide 18-35 m: passes to 0-18 wide; real StatsBomb completed 70%% of 14.5%% of spells) %.2f a team-match, by kind: completed %% / median length m:", n / tm);
                for (int w = 0; w < ai::kWhyCount; ++w) if (S.dwl_n[w]) {
                    auto v = S.dwl_len[w]; std::sort(v.begin(), v.end());
                    std::printf(" %s %.2f %.0f%% %.1f m (failed: out %.0f%%, their keeper %.0f%%, an outfielder %.0f%%);", ai::kWhyNames[w], S.dwl_n[w] / tm, 100.0 * S.dwl_ok[w] / S.dwl_n[w], v[v.size() / 2],
                                100.0 * S.dwl_out[w] / S.dwl_n[w], 100.0 * S.dwl_gk[w] / S.dwl_n[w], 100.0 * (S.dwl_n[w] - S.dwl_ok[w] - S.dwl_out[w] - S.dwl_gk[w]) / S.dwl_n[w]);
                }
                std::printf("\n");
            }
            {   // §8.192 RACE for the channel ball in behind (down the line)
                auto med = [](std::vector<double> v) { if (v.empty()) return 0.0; std::sort(v.begin(), v.end()); return v[v.size() / 2]; };
                long n = 0; for (long v : S.rce_n) n += v;
                std::printf("   RACE for the ball in behind down the line (%ld): at the kick, m to the spot median ours %.1f / their nearest outfielder %.1f / their keeper %.1f; our runner toward it %.1f m/s | ours minus theirs < -3 / -3..0 / 0..3 / 3+ m: share %% (completed %%)",
                            n, med(S.rce_me), med(S.rce_def), med(S.rce_gk), med(S.rce_vt));
                for (int a2 = 0; a2 < 4; ++a2) std::printf(" %.0f (%.0f)", 100.0 * S.rce_n[a2] / std::max(1L, n), 100.0 * S.rce_ok[a2] / std::max(1L, S.rce_n[a2]));
                static const char* rn2[ai::kRoleCount + 1] = {"CB", "FB", "DM/CM", "AM", "WIDE", "ST", "GK"};
                std::printf(" | their nearest:"); for (int r = 0; r < ai::kRoleCount; ++r) std::printf(" %s %ld", rn2[r], S.rce_role[r]);
                std::printf(" | lost to:"); for (int r = 0; r <= ai::kRoleCount; ++r) std::printf(" %s %ld", rn2[r], S.rce_won_by[r]);
                std::printf("\n");
            }
            std::printf("   ARRIVE in their crossing zone (0-18 m, |y| 14+), a team-match (real StatsBomb PL 15/16, benchmarks_statsbomb_cross.py arrive): carried in %.2f (8.76); completed passes in %.2f (12.89), from wide %.2f (8.53); within it %.2f (5.79)\n",
                        S.ar_carry / tm, S.ar_pass / tm, S.ar_pass_wide / tm, S.ar_within / tm);
            static const double re[2][3] = {{2.6, 4.5, 9.8}, {9.4, 15.1, 22.1}};
            std::printf("   ENTRIES into the last 35 m by |y| there, centre / mid / wide:");
            for (int kk = 0; kk < 2; ++kk)
                std::printf(" %s %.1f / %.1f / %.1f (%.1f / %.1f / %.1f);", kk ? "passed" : "carried", S.iw_e[kk][0] / tm, S.iw_e[kk][1] / tm, S.iw_e[kk][2] / tm, re[kk][0], re[kk][1], re[kk][2]);
            std::printf("\n");
        }
        for (int f = 0; f < 2; ++f) {   // §8.187 HOLD SPOT
            const double n = std::max(1L, S.hs_n[f]);
            std::printf("HOLD SPOT (§8.187; the side without it, holders, 5 Hz, ball %s): %.0f a team-match | spot moves under 2 / 2-5 / 5-10 / 10+ m/s %.1f / %.1f / %.1f / %.1f%%; "
                        "he moves %.1f / %.1f / %.1f / %.1f%% | lag mean %.2f m; per 0.2 s the spot adds %.3f m (jumps 10+ m/s %.3f), he closes %.3f\n",
                        f ? "free (their pass / loose)" : "carried by them", S.hs_n[f] / tm, 100 * S.hs_sp[f][0] / n, 100 * S.hs_sp[f][1] / n, 100 * S.hs_sp[f][2] / n, 100 * S.hs_sp[f][3] / n,
                        100 * S.hs_mv[f][0] / n, 100 * S.hs_mv[f][1] / n, 100 * S.hs_mv[f][2] / n, 100 * S.hs_mv[f][3] / n, S.hs_lag[f] / n, S.hs_add[f] / n, S.hs_jump_add[f] / n, S.hs_close[f] / n);
            static const char* rn[ai::kRoleCount] = {"CB", "FB", "DM/CM", "AM", "WIDE", "ST"};
            std::printf("   his lag p25 / median / p75 m by role:");
            for (int r = 0; r < ai::kRoleCount; ++r) {
                auto v = S.hs_rl[f][r]; if (v.empty()) continue; std::sort(v.begin(), v.end());
                std::printf(" %s %.1f / %.1f / %.1f (%zu);", rn[r], v[v.size() / 4], v[v.size() / 2], v[v.size() * 3 / 4], v.size());
            }
            std::printf("\n");
        }
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
    for (int ph = 0; ph < 2; ++ph) {
        long tot = 0, tt = 0;
        for (int bd = 0; bd < 10; ++bd) for (int r = 0; r < ai::kRoleCount; ++r) { tot += S.dp_n[ph][bd][r]; tt += S.dp_n[0][bd][r] + S.dp_n[1][bd][r]; }
        std::printf("DEFENDING SHAPE, %s (benchmarks_tracking_possession.py the same; %.1f%% of frames): band, by role\n",
                    ph ? "TRANSITION (0-6 s since it lost it)" : "SETTLED (6 s+ since it lost it)", tt ? 100.0 * tot / tt : 0.0);
        for (int bd = 0; bd < 10; ++bd) {
            std::printf("  %3d-%-3d", bd * 10, bd * 10 + 10);
            for (int r = 0; r < ai::kRoleCount; ++r) std::printf(" %6.1f", S.dp_n[ph][bd][r] ? S.dp_s[ph][bd][r] / S.dp_n[ph][bd][r] : 0.0);
            std::printf("\n");
        }
    }
    {   // §8.142: real DFL, benchmarks_tracking_lag.py (CB FB DM/CM AM WIDE ST)
        static const double kReal[5][4][6] = {
            {{6.3, 8.7, 12.0, 26.2, 17.1, 38.0}, {7.7, 10.4, 13.8, 27.4, 19.3, 39.0}, {9.9, 13.7, 18.2, 32.5, 24.7, 40.6}, {11.8, 14.9, 20.4, 32.6, 26.1, 43.7}},
            {{9.3, 12.1, 15.1, 23.9, 19.0, 35.5}, {11.6, 14.5, 17.6, 28.5, 23.8, 37.4}, {14.7, 18.5, 22.0, 35.8, 28.3, 43.1}, {17.2, 20.8, 25.8, 37.2, 31.9, 46.7}},
            {{14.0, 16.1, 19.5, 26.1, 23.3, 37.3}, {17.0, 18.9, 23.0, 30.7, 26.6, 40.2}, {19.8, 22.3, 27.3, 37.7, 32.1, 47.4}, {23.5, 26.5, 33.0, 43.8, 38.3, 52.4}},
            {{19.3, 21.5, 26.0, 33.6, 30.0, 41.3}, {22.8, 25.3, 30.8, 39.1, 35.2, 47.1}, {25.4, 28.6, 34.7, 42.9, 38.6, 51.5}, {29.8, 32.7, 40.0, 49.8, 45.2, 57.8}},
            {{25.7, 26.9, 32.5, 41.1, 36.4, 47.8}, {27.5, 29.0, 35.8, 44.4, 39.2, 50.2}, {30.8, 32.8, 39.0, 48.2, 43.9, 55.1}, {35.1, 38.5, 45.7, 56.0, 51.0, 62.7}}};
        static const char* kVb[4] = {"away", "still", "coming 2-5", "coming 5+"};
        std::printf("SETTLED SHAPE BY THE BALL'S SPEED AT THEM over 1 s (benchmarks_tracking_lag.py; real DFL in brackets): band, ball, frames | CB FB DM/CM AM WIDE ST\n");
        for (int bd = 0; bd < 5; ++bd)
            for (int vb = 0; vb < 4; ++vb) {
                if (S.dl_n[bd][vb] < 20) continue;
                std::printf("  %3d-%-3d %-11s %6ld |", bd * 10, bd * 10 + 10, kVb[vb], S.dl_n[bd][vb]);
                for (int r = 0; r < ai::kRoleCount; ++r)
                    std::printf(" %5.1f (%4.1f)", S.dl_k[bd][vb][r] ? S.dl_s[bd][vb][r] / S.dl_k[bd][vb][r] : 0.0, kReal[bd][vb][r]);
                std::printf("\n");
            }
    }
    {   // §8.143: real DFL, benchmarks_tracking_lag.py, the side in possession (CB FB DM/CM AM WIDE ST | line / front)
        static const double kReal[5][4][8] = {
            {{25.0, 22.6, 17.9, 10.5, 13.6, 8.5, 3.5, 2.2}, {36.9, 25.7, 23.2, 14.4, 14.4, 9.6, 4.8, 5.0}, {42.7, 31.3, 28.0, 18.6, 17.2, 13.3, 6.5, 7.5}, {44.0, 34.1, 30.1, 19.6, 19.2, 15.2, 8.5, 9.2}},
            {{36.1, 25.5, 23.2, 16.4, 15.7, 11.0, 7.3, 7.7}, {39.7, 28.7, 26.7, 18.4, 18.0, 13.1, 9.6, 10.8}, {44.3, 34.2, 31.0, 22.1, 21.4, 16.6, 11.9, 13.6}, {47.7, 38.0, 34.8, 25.7, 24.4, 19.8, 14.4, 15.6}},
            {{40.0, 30.2, 27.8, 21.6, 20.6, 15.2, 12.0, 12.8}, {44.8, 33.6, 31.6, 23.6, 23.8, 19.5, 15.3, 16.5}, {50.0, 38.6, 36.4, 27.0, 27.3, 22.8, 17.8, 19.6}, {55.1, 43.9, 42.0, 32.5, 31.7, 26.3, 21.1, 23.0}},
            {{45.1, 35.4, 33.6, 26.4, 25.8, 20.8, 17.1, 18.0}, {50.6, 40.0, 37.8, 30.9, 30.3, 25.6, 20.8, 22.2}, {55.5, 44.7, 42.6, 34.7, 33.9, 28.9, 23.8, 26.0}, {60.8, 50.5, 48.3, 39.2, 38.3, 33.1, 27.5, 29.7}},
            {{52.5, 41.9, 39.7, 31.5, 31.2, 27.1, 22.6, 23.7}, {56.5, 45.3, 43.9, 35.7, 35.3, 30.4, 26.0, 27.6}, {61.1, 50.4, 48.4, 40.3, 40.2, 34.5, 29.6, 31.7}, {66.5, 56.9, 54.4, 46.0, 44.3, 38.8, 33.4, 35.9}}};
        static const char* kVb[4] = {"back", "still", "forward 2-5", "forward 5+"};
        {   // §8.145: real DFL, benchmarks_tracking_runs.py
            static const double kG[4][11] = {{0.03, 0.19, 0.82, 0.86, 0.73, 0.58, 0.55, 0.47, 0.42, 0.37, 0.37}, {0.02, 0.14, 0.73, 0.87, 0.66, 0.60, 0.57, 0.54, 0.48, 0.45, 0.44},
                                             {0.03, 0.16, 0.58, 0.68, 0.60, 0.53, 0.51, 0.50, 0.52, 0.50, 0.51}, {0.05, 0.18, 0.54, 0.59, 0.47, 0.42, 0.41, 0.39, 0.39, 0.40, 0.41}};
            static const char* kZ[4] = {"0-18", "18-35", "35-52", "52+"};
            std::printf("MEN BY GAP short of their line a frame (2 m bins from -4, - = past it; benchmarks_tracking_runs.py, real DFL count in brackets) count / speed at goal:\n");
            for (int z = 0; z < 4; ++z) {
                if (!S.gb_f[z]) continue;
                std::printf("   ball %-5s", kZ[z]);
                for (int g = 0; g < 11; ++g) std::printf(" %.2f (%.2f) /%4.1f;", static_cast<double>(S.gb_k[z][g]) / S.gb_f[z], kG[z][g], S.gb_v[z][g] / std::max(1L, S.gb_k[z][g]));
                std::printf("\n");
            }
            static const double kQ[4][ai::kRoleCount][5] = {
                {{4.2, 25.6, 37.0, 43.3, 48.1}, {4.5, 11.8, 23.5, 33.4, 40.5}, {4.3, 10.8, 19.9, 27.6, 35.2}, {1.7, 4.5, 9.7, 16.2, 21.6}, {1.1, 3.6, 8.7, 15.9, 22.9}, {0.6, 1.9, 4.1, 8.4, 14.4}},
                {{14.7, 28.7, 33.9, 38.0, 41.7}, {6.9, 13.6, 21.6, 29.4, 35.4}, {6.2, 11.9, 18.7, 24.7, 30.4}, {2.1, 4.5, 9.4, 14.9, 19.8}, {1.9, 4.2, 8.2, 13.4, 20.2}, {0.5, 1.5, 3.2, 6.9, 11.8}},
                {{23.5, 28.6, 32.5, 35.9, 39.2}, {8.9, 15.6, 22.1, 28.3, 33.4}, {8.1, 14.1, 19.5, 24.2, 28.9}, {2.7, 5.6, 10.5, 15.0, 19.6}, {1.9, 4.6, 9.2, 14.7, 20.2}, {0.3, 1.5, 3.7, 7.6, 12.7}},
                {{26.7, 31.1, 35.4, 40.0, 44.6}, {11.5, 18.6, 25.9, 32.2, 37.8}, {11.9, 17.6, 23.2, 29.1, 34.2}, {3.4, 7.0, 11.4, 16.6, 22.4}, {2.0, 5.0, 10.6, 18.4, 25.9}, {-0.3, 1.2, 3.1, 7.0, 14.7}}};
            static const char* kRn[ai::kRoleCount] = {"CB", "FB", "DM", "AM", "WIDE", "ST"};
            std::printf("EACH ROLE's gap short of their line, p10/p25/median/p75/p90 (benchmarks_tracking_runs.py, real DFL in brackets):\n");
            for (int z = 0; z < 4; ++z) {
                std::printf("   ball %-5s", kZ[z]);
                for (int r = 0; r < ai::kRoleCount; ++r) {
                    auto& v = S.rq[z][r];
                    if (v.empty()) continue;
                    std::sort(v.begin(), v.end());
                    auto at = [&](double f) { return static_cast<double>(v[std::min(v.size() - 1, static_cast<std::size_t>(f * v.size()))]); };
                    std::printf(" %s %.1f/%.1f/%.1f/%.1f/%.1f (%.1f/%.1f/%.1f/%.1f/%.1f);", kRn[r], at(.1), at(.25), at(.5), at(.75), at(.9),
                                kQ[z][r][0], kQ[z][r][1], kQ[z][r][2], kQ[z][r][3], kQ[z][r][4]);
                }
                std::printf("\n");
            }
            {   // §8.148: a MAN of each role — % of his frames -2..0 / 0..2 / 2..4 m short (benchmarks_tracking_runs.py EACH MAN)
                static const double kM[4][ai::kRoleCount][3] = {
                    {{0.8, 4.6, 4.0}, {1.1, 3.6, 3.7}, {1.0, 3.9, 3.9}, {2.2, 8.7, 10.8}, {2.7, 11.1, 11.8}, {3.9, 20.5, 23.1}},
                    {{0.6, 2.6, 2.1}, {0.6, 1.7, 3.2}, {0.4, 1.9, 3.4}, {1.1, 7.9, 11.8}, {1.6, 8.6, 13.1}, {4.4, 26.3, 25.7}},
                    {{0.2, 0.6, 0.6}, {0.4, 1.2, 2.0}, {0.4, 1.1, 1.9}, {1.5, 5.4, 8.3}, {2.0, 7.8, 11.3}, {5.8, 22.9, 22.5}},
                    {{0.1, 0.1, 0.1}, {0.2, 0.8, 1.3}, {0.2, 0.5, 1.0}, {1.6, 3.3, 6.3}, {2.1, 7.0, 10.0}, {7.9, 24.7, 21.9}}};
                std::printf("EACH MAN by role, %% of his frames -2..0 / 0..2 / 2..4 m short of their line (real DFL in brackets):\n");
                for (int z = 0; z < 4; ++z) {
                    std::printf("   ball %-5s", kZ[z]);
                    for (int r = 0; r < ai::kRoleCount; ++r) {
                        const auto& v = S.rq[z][r];
                        if (v.empty()) continue;
                        double k[3] = {};
                        for (float x : v) { if (x >= -2 && x < 0) ++k[0]; else if (x >= 0 && x < 2) ++k[1]; else if (x >= 2 && x < 4) ++k[2]; }
                        std::printf(" %s %.1f/%.1f/%.1f (%.1f/%.1f/%.1f);", kRn[r], 100 * k[0] / v.size(), 100 * k[1] / v.size(), 100 * k[2] / v.size(), kM[z][r][0], kM[z][r][1], kM[z][r][2]);
                    }
                    std::printf("\n");
                }
            }
            auto med = [](std::vector<double> v) { if (v.empty()) return 0.0; std::sort(v.begin(), v.end()); return v[v.size() / 2]; };
            long rt = 0; for (int z = 0; z < 4; ++z) rt += S.rn_n[z];
            std::printf("RUNS (0-12 m short or past, 4+ m/s at goal, 0.6 s+; real DFL in brackets): %.1f a team-match (209.1); by the ball's zone 0-18 %.1f (22.9) 18-35 %.1f (61.7) 35-52 %.1f (64.5) 52+ %.1f (60.0)\n",
                        rt / tm, S.rn_n[0] / tm, S.rn_n[1] / tm, S.rn_n[2] / tm, S.rn_n[3] / tm);
            std::printf("   by role CB %.1f (7.9) FB %.1f (17.4) DM %.1f (24.9) AM %.1f (22.7) WIDE %.1f (73.9) ST %.1f (62.4); medians: starts %.1f m short (8.4), gets to %.1f (3.9), lasts %.1f s (1.8); past the line %.0f%% (7%%)\n",
                        S.rn_r[0] / tm, S.rn_r[1] / tm, S.rn_r[2] / tm, S.rn_r[3] / tm, S.rn_r[4] / tm, S.rn_r[5] / tm, med(S.rn_g0), med(S.rn_min), med(S.rn_len), 100.0 * S.rn_past / std::max(1L, rt));
            {   // §8.193 every run by his order at its start
                std::printf("   RUNS by his order at the start: a team-match | gets to m short median | his target's gap at the end median:");
                for (int w = 0; w < ai::kWhyCount + 2; ++w) {
                    if (S.rn_wm[w].size() < 8) continue;
                    const char* nm = w == ai::kWhyCount ? "FRONT MAN" : w == ai::kWhyCount + 1 ? "SECOND MAN" : ai::kWhyNames[w];
                    std::printf(" %s %.1f | %.1f | %.1f;", nm, S.rn_wm[w].size() / tm, med(S.rn_wm[w]), med(S.rn_wt[w]));
                }
                std::printf("\n");
            }
            std::printf("   the ball not going forward: %.1f a team-match (41.7), gets to %.1f m short (4.3); going forward 2+: %.1f (167.4), gets to %.1f (3.9); men on a RunLine job %.2f a frame\n",
                        S.rn_nb[0] / tm, med(S.rn_minb[0]), S.rn_nb[1] / tm, med(S.rn_minb[1]), static_cast<double>(S.run_why) / std::max(1L, S.gb_f[0] + S.gb_f[1] + S.gb_f[2] + S.gb_f[3]));
            std::printf("   RunLine: eligible man-seconds (0-12 m short, ball under 2 m/s on) / starts a team-match:");
            for (int r = 0; r < ai::kRoleCount; ++r) std::printf(" %s %.0f / %.1f;", kRn[r], S.run_el[r] / 5.0 / tm, S.run_st[r] / tm);
            std::printf(" (0-12 m man-s %.0f, carried %.0f, slow %.0f)\n", S.run_c[0] / 5.0 / tm, S.run_c[1] / 5.0 / tm, S.run_c[2] / 5.0 / tm);
        }
        {   // §8.151: the front man 4+ m short with the ball 20-50 m out — what he is
            static const char* kC[9] = {"on the ball", "the pass's man", "FRONT job", "SECOND job", "box runner", "RunLine", "no front job (not ours/live)", "hold, no line job", "other"};
            long t = 0; for (long v : S.ft_c) t += v;
            std::printf("FRONT MAN 4+ m SHORT (ball 20-50 m out), what he is: share %% / mean gap:");
            for (int i = 0; i < 9; ++i) if (S.ft_c[i]) std::printf(" %s %.0f%% / %.1f;", kC[i], 100.0 * S.ft_c[i] / std::max(1L, t), S.ft_g[i] / S.ft_c[i]);
            if (S.ft_c[2]) {
                std::sort(S.ft_age.begin(), S.ft_age.end());
                std::printf("\n   the FRONT job man then: his target %.1f m short, his speed at goal %.2f m/s (ordered %.2f), the line's %.2f m/s, in the job p25/median/p75 %.1f / %.1f / %.1f s",
                            S.ft_tg / S.ft_c[2], S.ft_v / S.ft_c[2], S.ft_cmd / S.ft_c[2], S.ft_lv / S.ft_c[2], S.ft_age[S.ft_age.size() / 4], S.ft_age[S.ft_age.size() / 2], S.ft_age[3 * S.ft_age.size() / 4]);
            }
            std::printf("\n");
        }
        {   // §8.150: ball-still runs by the runner's order at the run's start
            std::printf("BALL-STILL RUNS by his order at the start (a team-match):");
            for (int w = 0; w < ai::kWhyCount + 2; ++w)
                if (S.rn_whn[w]) std::printf(" %s %.1f;", w < ai::kWhyCount ? ai::kWhyNames[w] : w == ai::kWhyCount ? "FRONT MAN" : "SECOND MAN", S.rn_whn[w] / tm);
            std::printf("\n");
        }
        {   // §8.148: the sides' role mix (real: the 7 DFL matches' starters, 14 sides) — the strip by their line is 58% STs (DFL)
            static const double kRo[ai::kRoleCount] = {2.21, 1.57, 2.07, 0.79, 2.00, 1.36};
            static const char* kRn3[ai::kRoleCount] = {"CB", "FB", "DM", "AM", "WIDE", "ST"};
            std::printf("ROLES ON a side (outfield at full time, real DFL starters in brackets):");
            for (int r = 0; r < ai::kRoleCount; ++r) std::printf(" %s %.2f (%.2f);", kRn3[r], S.ro_n[r] / static_cast<double>(std::max(1L, S.ro_sides)), kRo[r]);
            std::printf("\n");
        }
        {   // §8.146: real DFL, benchmarks_tracking_linegap.py — [bm][band]: share %, front man median, men dA, d(gap), gap median; slope by role
            static const double kL[2][5][5] = {{{11.9, 2.4, -2.43, 0.44, 7.2}, {24.7, 1.7, -1.04, 0.10, 6.4}, {24.2, 1.2, -0.03, -0.03, 5.8}, {29.1, 0.5, 0.83, -0.37, 5.0}, {10.1, -0.1, 1.85, -0.81, 4.2}},
                                               {{57.5, 2.3, -3.34, 0.49, 6.9}, {22.8, 1.9, -1.15, 0.12, 6.6}, {10.3, 1.4, -0.13, -0.08, 5.9}, {6.4, 0.8, 0.78, -0.32, 5.4}, {3.0, 0.5, 2.18, -0.66, 4.6}}};
            static const double kS[2][ai::kRoleCount] = {{0.77, 0.79, 0.79, 0.78, 0.78, 0.77}, {0.92, 0.85, 0.77, 0.74, 0.76, 0.77}};
            static const double kGm[2][ai::kRoleCount][5] = {{{4.5, 3.6, 4.0, 3.2, 3.5}, {9.9, 9.1, 8.8, 8.8, 7.5}, {10.5, 9.8, 9.7, 8.9, 8.3}, {8.6, 7.2, 7.2, 5.7, 5.2}, {7.8, 7.0, 6.1, 5.1, 4.6}, {4.0, 3.1, 2.6, 1.9, 1.6}},
                                                             {{6.6, 7.2, 6.0, 7.7, 6.6}, {9.4, 10.1, 9.4, 9.6, 9.2}, {10.8, 9.9, 9.3, 9.5, 9.1}, {9.1, 7.9, 7.0, 6.4, 6.0}, {7.3, 6.8, 6.4, 5.9, 5.2}, {4.1, 3.4, 3.0, 2.1, 2.3}}};
            static const char* kD[5] = {"drop 2+", "drop .5-2", "still", "up .5-2", "up 2+"};
            static const char* kRn2[ai::kRoleCount] = {"CB", "FB", "DM", "AM", "WIDE", "ST"};
            auto medf = [](std::vector<float>& v) { if (v.empty()) return 0.0; std::sort(v.begin(), v.end()); return static_cast<double>(v[v.size() / 2]); };
            {
                static const double kB[ai::kRoleCount][2] = {{8.0, 3.7}, {8.6, 4.5}, {7.8, 3.7}, {5.9, 3.3}, {6.3, 3.8}, {4.2, 2.8}};
                std::printf("EACH MAN's SPELL (5 s+ with the ball 18-52 m out; benchmarks_tracking_gapspread.py, real DFL in brackets): between-spell sd / within-spell sd of his gap:");
                for (int r = 0; r < ai::kRoleCount; ++r) {
                    auto& v = S.sp_mean[r];
                    if (v.size() < 10) continue;
                    double mu = 0; for (double x : v) mu += x; mu /= v.size();
                    double bv = 0; for (double x : v) bv += (x - mu) * (x - mu);
                    std::printf(" %s %.1f (%.1f) / %.1f (%.1f);", kRn2[r], std::sqrt(bv / v.size()), kB[r][0], std::sqrt(std::max(0.0, S.sp_w[r]) / std::max(1L, S.sp_wn[r])), kB[r][1]);
                }
                std::printf("\n");
            }
            std::printf("THEIR LINE MOVES over 1 s, our men 0-15 m short 1 s ago (ball ours 1 s, 18-52 m out; benchmarks_tracking_linegap.py, real DFL in brackets):\n");
            for (int bm = 0; bm < 2; ++bm) {
                long tot = 0; for (int kq = 0; kq < 5; ++kq) tot += S.lg_n[bm][kq];
                if (!tot) continue;
                std::printf("   %s: band | share %% | front man gap med | men dA | d(gap) | gap med\n", bm ? "ball going forward 2+" : "ball NOT going forward");
                for (int kq = 0; kq < 5; ++kq) {
                    const double m = static_cast<double>(std::max(1L, S.lg_m[bm][kq][ai::kRoleCount]));
                    std::printf("     %-10s | %4.1f (%4.1f) | %4.1f (%4.1f) | %5.2f (%5.2f) | %5.2f (%5.2f) | %4.1f (%4.1f)\n", kD[kq], 100.0 * S.lg_n[bm][kq] / tot, kL[bm][kq][0],
                                medf(S.lg_f[bm][kq]), kL[bm][kq][1], S.lg_dA[bm][kq][ai::kRoleCount] / m, kL[bm][kq][2], S.lg_dg[bm][kq][ai::kRoleCount] / m, kL[bm][kq][3],
                                medf(S.lg_g[bm][kq][ai::kRoleCount]), kL[bm][kq][4]);
                }
                std::printf("     slope dA/dL by role (1 = keeps his gap, 0 = holds his ground), gap med drop 2+ .. up 2+:\n");
                for (int r = 0; r < ai::kRoleCount; ++r) {
                    const double n1 = static_cast<double>(S.lg_s1[bm][r]);
                    if (n1 < 50) continue;
                    const double sl = (S.lg_xy[bm][r] - S.lg_sx[bm][r] * S.lg_sy[bm][r] / n1) / std::max(1e-9, S.lg_xx[bm][r] - S.lg_sx[bm][r] * S.lg_sx[bm][r] / n1);
                    std::printf("       %-4s %4.2f (%4.2f) |", kRn2[r], sl, kS[bm][r]);
                    for (int kq = 0; kq < 5; ++kq) std::printf(" %4.1f (%4.1f)", medf(S.lg_g[bm][kq][r]), kGm[bm][r][kq]);
                    std::printf("\n");
                }
            }
        }
        {   // §8.144: real DFL, benchmarks_tracking_shoulder.py: short of line, 0-1 %, 0-2 %, 4+ %, past %, 2nd behind, ST %, WIDE %
            static const double kR[10][8] = {{1.8, 30, 45, 16, 28.6, 4.1, 29, 36}, {1.6, 28, 54, 8, 16.3, 2.7, 46, 27}, {1.7, 22, 49, 10, 14.9, 2.8, 53, 25},
                                             {1.9, 18, 40, 15, 15.6, 3.1, 58, 26}, {2.0, 18, 38, 18, 17.1, 3.2, 61, 25}, {2.1, 15, 35, 20, 18.6, 3.4, 66, 22},
                                             {2.1, 16, 35, 21, 20.8, 3.7, 68, 21}, {2.1, 16, 34, 20, 23.5, 4.2, 71, 20}, {2.2, 17, 36, 18, 23.2, 4.5, 70, 20},
                                             {3.1, 17, 36, 25, 19.1, 5.6, 73, 18}};
            std::printf("FRONT MAN v THEIR LINE (our most advanced outfielder; benchmarks_tracking_shoulder.py, real DFL in brackets): band | m short | 0-1 m %% | 0-2 m %% | 4+ m %% | past %% | 2nd man behind m | ST %% | WIDE %%\n");
            for (int bd = 0; bd < 10; ++bd) {
                const double n = static_cast<double>(S.fm_n[bd]);
                if (n < 20) continue;
                std::printf("  %3d-%-3d | %4.1f (%3.1f) | %3.0f (%2.0f) | %3.0f (%2.0f) | %3.0f (%2.0f) | %4.1f (%4.1f) | %4.1f (%3.1f) | %3.0f (%2.0f) | %3.0f (%2.0f)\n", bd * 10, bd * 10 + 10,
                            S.fm_gap[bd] / n, kR[bd][0], 100 * S.fm_w1[bd] / n, kR[bd][1], 100 * S.fm_w2[bd] / n, kR[bd][2], 100 * S.fm_w4[bd] / n, kR[bd][3],
                            100 * S.fm_past[bd] / n, kR[bd][4], S.fm_gap2[bd] / n, kR[bd][5], 100 * S.fm_r[bd][5] / n, kR[bd][6], 100 * S.fm_r[bd][4] / n, kR[bd][7]);
            }
        }
        {
            static const double kQ[10][5] = {{0.8, 2.5, 5.5, 10.4, 16.7}, {0.6, 1.6, 3.3, 6.6, 12.3}, {0.5, 1.5, 3.2, 6.7, 11.6}, {0.5, 1.6, 3.5, 7.7, 12.5},
                                             {0.3, 1.5, 3.6, 7.5, 12.6}, {0.1, 1.5, 3.5, 7.0, 12.4}, {-0.3, 1.2, 3.1, 6.7, 13.0}, {-0.6, 1.1, 3.0, 6.5, 13.5},
                                             {-0.5, 1.0, 2.7, 6.3, 15.6}, {-0.2, 1.1, 3.1, 9.2, 21.1}};
            std::printf("   every ST, m short of their line p10 / p25 / p50 / p75 / p90 (real DFL in brackets):\n");
            for (int bd = 0; bd < 10; ++bd) {
                auto& w = S.st_short[bd];
                if (w.size() < 50) continue;
                std::sort(w.begin(), w.end());
                std::printf("  %3d-%-3d", bd * 10, bd * 10 + 10);
                const double at[5] = {0.1, 0.25, 0.5, 0.75, 0.9};
                for (int q = 0; q < 5; ++q) std::printf(" %5.1f (%5.1f)", w[static_cast<std::size_t>(at[q] * (w.size() - 1))], kQ[bd][q]);
                std::printf("\n");
            }
        }
        std::printf("POSSESSION SIDE, BALL STILL: by role, share / at / target (m off their line) for hold shape | attack the box | anything else\n");
        for (int bd = 0; bd < 5; ++bd) {
            std::printf("  %3d-%-3d", bd * 10, bd * 10 + 10);
            for (int r = 0; r < ai::kRoleCount; ++r) {
                const long t = S.sh_n[bd][r][0] + S.sh_n[bd][r][1] + S.sh_n[bd][r][2];
                std::printf(" |");
                for (int w = 0; w < 3; ++w)
                    if (S.sh_n[bd][r][w]) std::printf(" %2.0f%% %4.1f/%4.1f", 100.0 * S.sh_n[bd][r][w] / t, S.sh_at[bd][r][w] / S.sh_n[bd][r][w], S.sh_tg[bd][r][w] / S.sh_n[bd][r][w]);
                    else std::printf("  -");
            }
            std::printf("\n");
        }
        std::printf("POSSESSION SHAPE BY THE BALL'S SPEED FORWARD over 1 s (m off THEIR line; benchmarks_tracking_lag.py, real DFL in brackets): band, ball, frames | CB FB DM/CM AM WIDE ST | their line / our front man\n");
        for (int bd = 0; bd < 5; ++bd)
            for (int vb = 0; vb < 4; ++vb) {
                if (S.pl_n[bd][vb] < 20) continue;
                std::printf("  %3d-%-3d %-11s %6ld |", bd * 10, bd * 10 + 10, kVb[vb], S.pl_n[bd][vb]);
                for (int r = 0; r < ai::kRoleCount; ++r)
                    std::printf(" %5.1f (%4.1f)", S.pl_k[bd][vb][r] ? S.pl_s[bd][vb][r] / S.pl_k[bd][vb][r] : 0.0, kReal[bd][vb][r]);
                std::printf(" | %5.1f (%4.1f) / %5.1f (%4.1f)\n", S.pl_line[bd][vb] / S.pl_n[bd][vb], kReal[bd][vb][6], S.pl_front[bd][vb] / S.pl_n[bd][vb], kReal[bd][vb][7]);
            }
    }
    if (S.lo_f)
        std::printf("LANE in open play (settled 6 s+, ball 10-35 m out, |y| < 12; real DFL in brackets): a man within 1 m %.1f%% (43.6); 0/1/2/3+ %.1f / %.1f / %.1f / %.1f%% (56.4 / 36.9 / 6.3 / 0.4)\n",
                    100.0 * S.lo_1 / S.lo_f, 100.0 * S.lo_k[0] / S.lo_f, 100.0 * S.lo_k[1] / S.lo_f, 100.0 * S.lo_k[2] / S.lo_f, 100.0 * S.lo_k[3] / S.lo_f);
    if (S.cb_n)
        std::printf("   CENTRE-BACK PAIR there: gap %.1f m (7.1), their middle %.1f m off the ball's y (5.1)\n", S.cb_gap / S.cb_n, S.cb_mid / S.cb_n);
    std::printf("SETTLED WIDTH by band (ball m off the defenders' line), the pair's gap in m:\n");
    {
        static const char* wr[4] = {"CB", "FB", "WIDE", "DM/CM"};
        for (int r = 0; r < 4; ++r) {
            std::printf("    %-6s", wr[r]);
            long n = 0;
            for (int bd = 0; bd < 10; ++bd) { std::printf(" %5.1f", S.wg[r][bd] / std::max(1L, S.wg_n[r][bd])); n += S.wg_n[r][bd]; }
            std::printf("   (n %ld)\n", n);
        }
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
