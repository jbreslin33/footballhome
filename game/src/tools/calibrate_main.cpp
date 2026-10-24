// game/src/tools/calibrate_main.cpp — fh-game-calibrate
//
// Calibration harness v0 [FH] (DESIGN.md pillar 5): run N headless AI-vs-AI
// matches at free-run speed and print the realism statistics. v0 drives the
// World+Brain directly; the protocol-speaking headless client replaces it
// when per-match orchestration lands. Usage:
//
//   fh-game-calibrate [matches=5] [players=22] [minutes=90] [lvl_home] [lvl_away]
//                     [keeper_rx] [swarm] [angle] [home_concepts "name:r,..."]
//
// Output (one line per match + aggregate):
//   match 1: home 2 — 1 away | possession 51% / 34% (15% loose)
//   ...
//   AGGREGATE over 5: 3.2 goals/game | anchor: real-world ~2.7
//
// Determinism note: everything here is fixed point and pure, so N matches
// of the same config produce identical output forever — any drift IS a
// behavior change and should have arrived with a slice that re-locked
// goldens.

#include "ai/Brain.hpp"
#include "core/Levels.hpp"
#include "core/World.hpp"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <cmath>

using namespace fh::game;
using math::Fixed64;

int main(int argc, char** argv) {
    const int matches = argc > 1 ? std::atoi(argv[1]) : 5;
    const int players = argc > 2 ? std::atoi(argv[2]) : 22;
    const int minutes = argc > 3 ? std::atoi(argv[3]) : 90;
    const char* lvl_home = argc > 4 ? argv[4] : "perfect";
    const char* lvl_away = argc > 5 ? argv[5] : "perfect";
    // Sweep overrides (G4.14): argv[6]/argv[7] override BOTH teams'
    // keeper_reaction_ticks / swarm_pct (-1 = keep the band's value), so
    // a dial grid runs without recompiling. Dev tool, not wire surface.
    const int kr_override = argc > 6 ? std::atoi(argv[6]) : -1;
    const int swarm_override = argc > 7 ? std::atoi(argv[7]) : -1;
    const int angle_override = argc > 8 ? std::atoi(argv[8]) : -1;
    // argv[9] (G4.18): HOME-team concept overrides "name:rating,..." on
    // top of the band defaults — measures an identity head-to-head
    // (e.g. counter-attack:90 vs a plain mirror). "-" = none.
    const char* home_concepts = argc > 9 ? argv[9] : "-";
    const long ticks = static_cast<long>(minutes) * 60 * core::kTickRate;

    long total_goals = 0;

    for (int m = 1; m <= matches; ++m) {
        core::World world{static_cast<std::uint8_t>(players),
                          Fixed64::fromInt(6), Fixed64::fromFraction(105, 2),
                          Fixed64::fromInt(34)};
        ai::Brain brain{ai::TeamSetup::splitHalves(
                            static_cast<std::uint8_t>(players)),
                        Fixed64::fromFraction(105, 2), Fixed64::fromInt(34)};
        core::LevelParams lp_home = core::levelParams(lvl_home);
        core::LevelParams lp_away = core::levelParams(lvl_away);
        if (kr_override >= 0) {
            lp_home.keeper_reaction_ticks = kr_override;
            lp_away.keeper_reaction_ticks = kr_override;
        }
        if (swarm_override >= 0) {
            lp_home.swarm_pct = swarm_override;
            lp_away.swarm_pct = swarm_override;
        }
        if (angle_override >= 0) {
            lp_home.kick_angle_err_deg = angle_override;
            lp_away.kick_angle_err_deg = angle_override;
        }
        world.setLevel(0, lp_home);
        world.setLevel(1, lp_away);
        world.setMatchSeed(static_cast<std::uint64_t>(m));  // vary per match
        brain.setLevels(lp_home, lp_away, static_cast<std::uint64_t>(m));
        if (std::strcmp(home_concepts, "-") != 0) {
            core::PresetOverlay ov;
            ov.fill(-1);
            std::string spec = home_concepts;
            std::size_t at = 0;
            while (at < spec.size()) {
                std::size_t end = spec.find(',', at);
                if (end == std::string::npos) end = spec.size();
                const std::string item = spec.substr(at, end - at);
                const std::size_t colon = item.find(':');
                if (colon != std::string::npos) {
                    const std::string name = item.substr(0, colon);
                    const int c = core::concepts().find(name);
                    if (c >= 0)
                        ov[c] = static_cast<std::int16_t>(
                            std::atoi(item.c_str() + colon + 1));
                }
                at = end + 1;
            }
            const std::uint8_t half = static_cast<std::uint8_t>(players / 2);
            for (std::uint8_t s = 0; s < half; ++s) {
                core::ConceptRatings r = brain.ratings(s);
                core::applyPresetOverlay(r, ov);
                brain.setRatings(s, r);
            }
        }
        const auto setup = ai::TeamSetup::splitHalves(
            static_cast<std::uint8_t>(players));

        // Spawn in two facing lines, same as the live server.
        const std::uint8_t per_team = players / 2;
        for (std::uint8_t i = 0; i < players; ++i) {
            const bool home = i < per_team;
            const std::uint8_t k = home ? i : i - per_team;
            const Fixed64 y = per_team > 1
                ? Fixed64::fromInt(-25) + Fixed64::fromInt(50) *
                      Fixed64::fromFraction(k, per_team - 1)
                : Fixed64::zero();
            world.placePlayer(i, math::Vec3{Fixed64::fromInt(home ? -15 : 15),
                                            y, Fixed64::zero()},
                              math::Vec2{home ? Fixed64::one()
                                              : -Fixed64::one(),
                                         Fixed64::zero()});
            world.setTeam(i, home ? 0 : 1);
            world.setKeeper(i, ai::builtinFormation(per_team).positions[k].keeper);
        }

        int score[2] = {0, 0};
        long tk_won = 0, tk_lost = 0, offsides = 0;
        long owned_ticks[2] = {0, 0};
        long contested_ticks = 0;
        long shots[2] = {0, 0};
        // Shot outcome (G4.23): follow each shot to its first resolution.
        int shot_live = -1;  // shooting team while tracking
        int shot_pending = -1;  // shooter slot, armed until the ball leaves
        std::uint8_t shot_kicker = 0xFF;
        long so[5] = {0, 0, 0, 0, 0};  // goal/off-target/keeper/blocked/other
        long shot_depth[3] = {0, 0, 0};  // <8 m / 8-16.5 / 16.5+
        // Duel anatomy (G4.23): every CARRY (one owner, continuous) that
        // an opponent engaged (came inside tackle reach), by how it
        // ended: kicked (pass/shot/clear), stolen (touch contest), poked
        // (tackle), other. Plus engaged-ticks per engaged carry.
        int carry_owner = -1;
        bool carry_engaged = false;
        long carry_eng_ticks = 0, eng_ticks_sum = 0;
        long duel_end[4] = {0, 0, 0, 0};  // kicked/stolen/poked/other
        long carries = 0;
        // Final-third ENTRIES (G4.24 → next): an episode opens when a
        // team's ball (carried, or its kick in flight) crosses into the
        // attacking third (> 17.5 m past halfway); closes on that team's
        // shot, a turnover, or the ball retreating out of the third.
        // Split by how it entered: carried or passed.
        int ent_team = -1;
        bool ent_carried = false;
        long ent_n[2] = {0, 0}, ent_shot[2] = {0, 0}, ent_lost[2] = {0, 0},
             ent_back[2] = {0, 0};  // index: 0 carried, 1 passed
        double prev_bx = 0;
        int prev_poss = -1;
        long shot_press[3] = {0, 0, 0};  // nearest opp <2 m / 2-5 / 5+
        // Goal anatomy (G4.14): what KIND of goals is each level scoring?
        // Per team: last shot's distance and whether the shooter was past
        // every outfield defender (a breakaway). A goal is attributed to
        // its team's most recent shot.
        long breakaway_goals = 0, open_play_goals = 0;
        // Goal origin (G4.18). A COUNTER = ball won in the scorer's own
        // half, scored within 15 s. A SCRAMBLE = ball "won" under 3 s
        // before the goal (a rebound off the keeper/a block recovered by
        // the attack). Measured at slice start: 35 of 37 world goals sat
        // a mean 0.6 s after a "win" — the engine scores on second balls.
        long counter_goals = 0, scramble_goals = 0;
        // Scramble cause: the DEFENDING team's most recent loose-ball
        // touch before the goal — keeper parry, outfield deflection
        // (failed control/block), or tackle poke.
        long sc_parry = 0, sc_deflect = 0, sc_poke = 0;
        long last_parry[2] = {-100000, -100000};
        long last_deflect[2] = {-100000, -100000};
        long last_poke[2] = {-100000, -100000};
        std::uint8_t prev_lk = 0xFF;
        // Jitter (G4.20, James: "players jitter"): per outfield player,
        // ORDERED-heading reversals (consecutive move intents > 90° apart)
        // and go/stop flicker (moving → still → moving inside 3 ticks).
        // Split by role: the carrier, his nearest teammate, everyone else.
        long jit_rev[3] = {0, 0, 0}, jit_flick[3] = {0, 0, 0};
        math::Vec2 prev_mv[32];
        int still_run[32];
        bool was_moving[32];
        for (int k = 0; k < 32; ++k) {
            prev_mv[k] = math::Vec2{};
            still_run[k] = 0;
            was_moving[k] = false;
        }
        // Counter funnel (G4.18), per team: own-half wins → reached the
        // final third within 10 s with no turnover between → shot in 15 s.
        long fn_wins[2] = {0, 0}, fn_third[2] = {0, 0}, fn_shot[2] = {0, 0};
        int fn_team = -1;          // team whose break is live (-1 none)
        long fn_start = 0;
        bool fn_reached = false, fn_shot_done = false;
        std::uint64_t fn_tt = 0xFFFFFFFFFFFFFFFFULL;
        // Churn anatomy: every possession change by cause, read from the
        // PRE-tick state — touch-contest steal, tackle poke, a loser's
        // outfield kick (pass/clear/shot) collected by the other side, a
        // keeper's punt/throw lost, or other (bobbles, restarts).
        long ch_steal = 0, ch_poke = 0, ch_kick = 0, ch_keeper = 0,
             ch_other = 0;
        bool pre_owned = false;
        std::uint8_t pre_lk_slot = 0xFF;
        long last_poke_any = -100000;
        // Kick-lost by the kind of kick the loser last made.
        int last_kick_kind[32];
        for (int& k : last_kick_kind) k = 0;
        long kl_kind[5] = {0, 0, 0, 0, 0};  // short/ground/loft/shot/other
        double scoring_dist_sum = 0, keeper_dist_sum = 0;
        double keeper_ball_sum = 0, ball_speed_sum = 0;
        bool last_shot_breakaway[2] = {false, false};
        double last_shot_dist[2] = {0, 0};

        for (long t = 0; t < ticks; ++t) {
            for (std::uint8_t s = 0; s < players; ++s) {
                const ai::Orders o = brain.ordersFor(s, world);
                if (!world.isKeeper(s)) {
                    int role = 2;
                    if (world.ball().owner) {
                        const std::uint8_t c = *world.ball().owner;
                        if (c == s) role = 0;
                        else if (setup.team_of_slot[c] == setup.team_of_slot[s]) {
                            Fixed64 md = math::lengthSquared(math::Vec2{
                                world.player(s).pos.x - world.player(c).pos.x,
                                world.player(s).pos.y - world.player(c).pos.y});
                            bool nearest = true;
                            for (std::uint8_t q = 0; q < players && nearest; ++q) {
                                if (q == s || q == c || setup.team_of_slot[q] != setup.team_of_slot[s]) continue;
                                const Fixed64 d = math::lengthSquared(math::Vec2{
                                    world.player(q).pos.x - world.player(c).pos.x,
                                    world.player(q).pos.y - world.player(c).pos.y});
                                if (d < md) nearest = false;
                            }
                            if (nearest) role = 1;
                        }
                    }
                    const math::Vec2 mv = o.move.move;
                    const bool moving = mv.x.raw != 0 || mv.y.raw != 0;
                    if (moving && (prev_mv[s].x.raw != 0 || prev_mv[s].y.raw != 0) &&
                        math::dot(mv, prev_mv[s]).raw < 0)
                        ++jit_rev[role];
                    if (moving && !was_moving[s] && still_run[s] > 0 &&
                        still_run[s] < 3)
                        ++jit_flick[role];
                    if (moving) { prev_mv[s] = mv; still_run[s] = 0; }
                    else ++still_run[s];
                    was_moving[s] = moving;
                }
                world.setIntent(s, o.move);
                if (o.action != core::Action::None) world.setAction(s, o.action, o.carry_m);
                if (o.action != core::Action::None && world.ball().owner &&
                    *world.ball().owner == s) {
                    last_kick_kind[s & 31] =
                        o.action == core::Action::ShortPass   ? 0
                        : o.action == core::Action::GroundKick ? 1
                        : o.action == core::Action::LoftedKick ? 2
                        : o.action == core::Action::Shot       ? 3
                                                               : 4;
                }
                // A shot ORDER only fires if this slot carries the ball.
                if (o.action == core::Action::Shot && world.ball().owner &&
                    *world.ball().owner == s) {
                    const int team = setup.team_of_slot[s];
                    ++shots[team];
                    if (ent_team == team) { ++ent_shot[ent_carried ? 0 : 1]; ent_team = -1; }
                    shot_pending = s;
                    if (fn_team == team && !fn_shot_done) {
                        fn_shot_done = true;
                        ++fn_shot[team];
                    }
                    const auto& p = world.player(s);
                    const double gx = team == 0 ? 52.5 : -52.5;
                    const double dx = gx - p.pos.x.toDouble();
                    const double dy = -p.pos.y.toDouble();
                    last_shot_dist[team] =
                        dx < 0 ? -dx : dx;  // depth to goal line
                    (void)dy;
                    // Breakaway: no outfield opponent goal-side of me.
                    bool past_all = true;
                    for (std::uint8_t j = 0; j < players && past_all; ++j) {
                        if (setup.team_of_slot[j] == team) continue;
                        if (world.isKeeper(j)) continue;
                        const double ox = world.player(j).pos.x.toDouble();
                        if (team == 0 ? ox > p.pos.x.toDouble()
                                      : ox < p.pos.x.toDouble())
                            past_all = false;
                    }
                    last_shot_breakaway[team] = past_all;
                    // Shot anatomy (G4.22): depth bucket + nearest
                    // defender distance at the moment of the strike.
                    const double depth = last_shot_dist[team];
                    ++shot_depth[depth < 8 ? 0 : depth < 16.5 ? 1 : 2];
                    double nd = 1e9;
                    for (std::uint8_t j = 0; j < players; ++j) {
                        if (setup.team_of_slot[j] == team) continue;
                        const double ox = world.player(j).pos.x.toDouble() - p.pos.x.toDouble();
                        const double oy = world.player(j).pos.y.toDouble() - p.pos.y.toDouble();
                        const double dd = std::sqrt(ox * ox + oy * oy);
                        if (dd < nd) nd = dd;
                    }
                    ++shot_press[nd < 2 ? 0 : nd < 5 ? 1 : 2];
                }
            }
            // Pre-tick state: the Goal event is emitted AFTER the
            // kickoff reset, so goal anatomy must read the state captured
            // BEFORE the tick that scored.
            double pre_bx = world.ball().pos.x.toDouble();
            double pre_by = world.ball().pos.y.toDouble();
            double pre_bvx = world.ball().vel.x.toDouble();
            double pre_bvy = world.ball().vel.y.toDouble();
            const int pre_owner_slot =
                world.ball().owner ? static_cast<int>(*world.ball().owner) : -1;
            if (pre_owner_slot >= 0) {
                const auto& c = world.player(static_cast<std::uint8_t>(pre_owner_slot));
                bool eng = false;
                for (std::uint8_t j = 0; j < players && !eng; ++j) {
                    if (setup.team_of_slot[j] == setup.team_of_slot[pre_owner_slot]) continue;
                    const double dx = world.player(j).pos.x.toDouble() - c.pos.x.toDouble();
                    const double dy = world.player(j).pos.y.toDouble() - c.pos.y.toDouble();
                    eng = dx * dx + dy * dy < 1.8 * 1.8;
                }
                if (pre_owner_slot != carry_owner) {
                    carry_owner = pre_owner_slot;
                    carry_engaged = false;
                    carry_eng_ticks = 0;
                    ++carries;
                }
                if (eng) { carry_engaged = true; ++carry_eng_ticks; }
            }
            pre_owned = world.ball().owner.has_value();
            pre_lk_slot = world.ball().last_kicker;
            const std::uint8_t pre_lost = world.lastLosingTeam();
            const std::uint64_t pre_tt = world.turnoverTick();
            const double pre_tx = world.turnoverBallX().toDouble();
            double pre_k[2][2];
            for (std::uint8_t j = 0; j < players; ++j) {
                if (!world.isKeeper(j)) continue;
                const int tm = setup.team_of_slot[j];
                pre_k[tm][0] = world.player(j).pos.x.toDouble();
                pre_k[tm][1] = world.player(j).pos.y.toDouble();
            }
            const std::uint8_t pre_lk_so = world.ball().last_kicker;
            const auto evs_so = world.tick();
            if (shot_pending >= 0) {
                // The strike itself: start tracking only once the ball has
                // left the shooter's foot (last_kicker == shooter, free).
                if (!world.ball().owner &&
                    world.ball().last_kicker == shot_pending) {
                    shot_live = setup.team_of_slot[shot_pending];
                    shot_kicker = static_cast<std::uint8_t>(shot_pending);
                }
                shot_pending = -1;
            } else if (shot_live >= 0) {
                bool goal = false, out = false;
                for (const auto& e : evs_so) {
                    if (e.type == core::MatchEventType::Goal) goal = true;
                    if (e.type == core::MatchEventType::GoalKick ||
                        e.type == core::MatchEventType::Corner ||
                        e.type == core::MatchEventType::ThrowIn) out = true;
                }
                const std::uint8_t lk = world.ball().last_kicker;
                if (goal) { ++so[0]; shot_live = -1; }
                else if (out) { ++so[1]; shot_live = -1; }
                else if (world.ball().owner || lk != shot_kicker) {
                    const std::uint8_t who = world.ball().owner ? *world.ball().owner : lk;
                    if (who < players && setup.team_of_slot[who] != shot_live)
                        ++so[world.isKeeper(who) ? 2 : 3];
                    else
                        ++so[4];
                    shot_live = -1;
                }
            }
            for (const core::MatchEvent& e : evs_so) {
                if (e.type == core::MatchEventType::Goal) {
                    ++score[e.team];
                    if (last_shot_breakaway[e.team]) ++breakaway_goals;
                    else ++open_play_goals;
                    if (pre_lost == (e.team ^ 1)) {
                        const std::uint64_t since =
                            static_cast<std::uint64_t>(t) - pre_tt;
                        const bool own_half = e.team == 0 ? pre_tx < 0
                                                          : pre_tx > 0;
                        if (since < 3 * core::kTickRate) {
                            ++scramble_goals;
                            const int d = e.team ^ 1;
                            const long lp = last_parry[d], ld = last_deflect[d],
                                       lk = last_poke[d];
                            if (lp >= ld && lp >= lk) ++sc_parry;
                            else if (ld >= lk) ++sc_deflect;
                            else ++sc_poke;
                        }
                        else if (own_half && since < 15 * core::kTickRate)
                            ++counter_goals;
                    }
                    scoring_dist_sum += last_shot_dist[e.team];
                    // Beaten keeper's geometry at the PRE-TICK moment.
                    {
                        const int kt = e.team == 0 ? 1 : 0;
                        const double gx = e.team == 0 ? 52.5 : -52.5;
                        const double dx = pre_k[kt][0] - gx;
                        const double dy = pre_k[kt][1];
                        keeper_dist_sum += std::sqrt(dx * dx + dy * dy);
                        const double bdx = pre_k[kt][0] - pre_bx;
                        const double bdy = pre_k[kt][1] - pre_by;
                        keeper_ball_sum += std::sqrt(bdx * bdx + bdy * bdy);
                        ball_speed_sum += std::sqrt(pre_bvx * pre_bvx +
                                                    pre_bvy * pre_bvy);
                    }
                }
                if (e.type == core::MatchEventType::TackleWon) {
                    ++tk_won;
                    last_poke[e.team] = t;
                    last_poke_any = t;
                }
                if (e.type == core::MatchEventType::TackleLost) ++tk_lost;
                if (e.type == core::MatchEventType::Offside) ++offsides;
            }
            if (world.turnoverTick() != fn_tt) {  // a new possession win
                fn_tt = world.turnoverTick();
                const std::uint8_t lost_by = world.lastLosingTeam();
                if (pre_owned) ++ch_steal;
                else if (t - last_poke_any < core::kTickRate) ++ch_poke;
                else if (pre_lk_slot < players &&
                         setup.team_of_slot[pre_lk_slot] == lost_by) {
                    if (world.isKeeper(pre_lk_slot)) ++ch_keeper;
                    else {
                        ++ch_kick;
                        ++kl_kind[last_kick_kind[pre_lk_slot & 31]];
                    }
                } else ++ch_other;
                fn_team = -1;
                const std::uint8_t lost = world.lastLosingTeam();
                if (lost <= 1) {
                    const int w = lost ^ 1;
                    const double x = world.turnoverBallX().toDouble();
                    if (w == 0 ? x < 0 : x > 0) {
                        ++fn_wins[w];
                        fn_team = w;
                        fn_start = t;
                        fn_reached = fn_shot_done = false;
                    }
                }
            }
            if (fn_team >= 0) {
                const double bx = world.ball().pos.x.toDouble();
                if (!fn_reached && t - fn_start < 10 * core::kTickRate &&
                    (fn_team == 0 ? bx > 17.5 : bx < -17.5)) {
                    fn_reached = true;
                    ++fn_third[fn_team];
                }
                if (t - fn_start >= 15 * core::kTickRate) fn_team = -1;
            }
            if (carry_owner >= 0) {
                const bool still = world.ball().owner &&
                    static_cast<int>(*world.ball().owner) == carry_owner;
                if (!still) {
                    if (carry_engaged) {
                        eng_ticks_sum += carry_eng_ticks;
                        int why = 3;
                        if (!world.ball().owner &&
                            world.ball().last_kicker == carry_owner) why = 0;
                        else if (world.ball().owner &&
                                 setup.team_of_slot[*world.ball().owner] !=
                                     setup.team_of_slot[carry_owner]) why = 1;
                        else if (t == last_poke_any) why = 2;
                        ++duel_end[why];
                    }
                    carry_owner = world.ball().owner
                        ? -2 : -1;  // -2: new owner picked up next tick
                    if (world.ball().owner) carry_owner = -1;
                }
            }
            {
                const std::uint8_t lk = world.ball().last_kicker;
                if (lk != prev_lk && lk < players && !world.ball().owner) {
                    const int tm = setup.team_of_slot[lk];
                    if (world.isKeeper(lk)) last_parry[tm] = t;
                    else last_deflect[tm] = t;
                }
                prev_lk = lk;
            }
            {
                const int poss = world.ball().owner
                    ? (int)setup.team_of_slot[*world.ball().owner]
                    : (world.lastTouchTeam() <= 1 ? (int)world.lastTouchTeam() : -1);
                const double bx = world.ball().pos.x.toDouble();
                if (ent_team >= 0) {
                    const double d = ent_team == 0 ? bx : -bx;
                    if (poss != ent_team && poss >= 0) { ++ent_lost[ent_carried ? 0 : 1]; ent_team = -1; }
                    else if (d < 17.5) { ++ent_back[ent_carried ? 0 : 1]; ent_team = -1; }
                }
                if (ent_team < 0 && poss >= 0 && poss == prev_poss) {
                    const double d0 = poss == 0 ? prev_bx : -prev_bx;
                    const double d1 = poss == 0 ? bx : -bx;
                    if (d0 < 17.5 && d1 >= 17.5) {
                        ent_team = poss;
                        ent_carried = world.ball().owner.has_value();
                        ++ent_n[ent_carried ? 0 : 1];
                    }
                }
                prev_bx = bx;
                prev_poss = poss;
            }
            // Possession: a ball in flight belongs to its last-touch team
            // (the G4.1 metric gap, closed). Contested = untouched yet.
            if (world.ball().owner)
                ++owned_ticks[setup.team_of_slot[*world.ball().owner]];
            else if (world.lastTouchTeam() <= 1)
                ++owned_ticks[world.lastTouchTeam()];
            else
                ++contested_ticks;
        }

        total_goals += score[0] + score[1];
        const int goals = score[0] + score[1];
        std::printf(
            "match %d: home %d - %d away | possession %ld%% / %ld%% (%ld%% contested) | shots %ld / %ld | tackles %ld won / %ld beaten | %ld offsides | breakaway %ld/%d | counters %ld/%d, scrambles %ld/%d (parry %ld, deflect %ld, poke %ld) | funnel H %ld>%ld>%ld A %ld>%ld>%ld | churn steal %ld poke %ld kick %ld keeper %ld other %ld | lost-kick short %ld ground %ld loft %ld shot %ld other %ld | jitter rev %ld/%ld/%ld flick %ld/%ld/%ld | shot depth %ld/%ld/%ld press %ld/%ld/%ld | shot-out goal %ld off %ld keeper %ld blocked %ld other %ld | entries carried %ld>shot %ld lost %ld back %ld passed %ld>shot %ld lost %ld back %ld | duels %ld engaged of %ld carries: kicked %ld stolen %ld poked %ld other %ld, %.1f s engaged | scoring dist %.1f m | gk off goal %.1f m, off ball %.1f m, ball %.1f m/s\n",
            m, score[0], score[1], owned_ticks[0] * 100 / ticks,
            owned_ticks[1] * 100 / ticks, contested_ticks * 100 / ticks,
            shots[0], shots[1], tk_won, tk_lost, offsides,
            breakaway_goals, goals, counter_goals, goals,
            scramble_goals, goals, sc_parry, sc_deflect, sc_poke,
            fn_wins[0], fn_third[0], fn_shot[0],
            fn_wins[1], fn_third[1], fn_shot[1],
            ch_steal, ch_poke, ch_kick, ch_keeper, ch_other,
            kl_kind[0], kl_kind[1], kl_kind[2], kl_kind[3], kl_kind[4],
            jit_rev[0], jit_rev[1], jit_rev[2],
            jit_flick[0], jit_flick[1], jit_flick[2],
            shot_depth[0], shot_depth[1], shot_depth[2],
            shot_press[0], shot_press[1], shot_press[2],
            so[0], so[1], so[2], so[3], so[4],
            ent_n[0], ent_shot[0], ent_lost[0], ent_back[0],
            ent_n[1], ent_shot[1], ent_lost[1], ent_back[1],
            duel_end[0] + duel_end[1] + duel_end[2] + duel_end[3], carries,
            duel_end[0], duel_end[1], duel_end[2], duel_end[3],
            (duel_end[0] + duel_end[1] + duel_end[2] + duel_end[3])
                ? static_cast<double>(eng_ticks_sum) / core::kTickRate /
                      (duel_end[0] + duel_end[1] + duel_end[2] + duel_end[3])
                : 0.0,
            goals ? scoring_dist_sum / goals : 0.0,
            goals ? keeper_dist_sum / goals : 0.0,
            goals ? keeper_ball_sum / goals : 0.0,
            goals ? ball_speed_sum / goals : 0.0);
        (void)open_play_goals;
    }

    std::printf("AGGREGATE over %d: %.1f goals/game | anchor: real-world ~2.7\n",
                matches, static_cast<double>(total_goals) / matches);
    return 0;
}
