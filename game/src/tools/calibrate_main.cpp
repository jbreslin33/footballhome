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
                    for (int c = 0; c < core::kConceptCount; ++c)
                        if (name == core::kConceptNames[c])
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
        double scoring_dist_sum = 0, keeper_dist_sum = 0;
        double keeper_ball_sum = 0, ball_speed_sum = 0;
        bool last_shot_breakaway[2] = {false, false};
        double last_shot_dist[2] = {0, 0};

        for (long t = 0; t < ticks; ++t) {
            for (std::uint8_t s = 0; s < players; ++s) {
                const ai::Orders o = brain.ordersFor(s, world);
                world.setIntent(s, o.move);
                if (o.action != core::Action::None) world.setAction(s, o.action);
                // A shot ORDER only fires if this slot carries the ball.
                if (o.action == core::Action::Shot && world.ball().owner &&
                    *world.ball().owner == s) {
                    const int team = setup.team_of_slot[s];
                    ++shots[team];
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
                }
            }
            // Pre-tick state: the Goal event is emitted AFTER the
            // kickoff reset, so goal anatomy must read the state captured
            // BEFORE the tick that scored.
            double pre_bx = world.ball().pos.x.toDouble();
            double pre_by = world.ball().pos.y.toDouble();
            double pre_bvx = world.ball().vel.x.toDouble();
            double pre_bvy = world.ball().vel.y.toDouble();
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
            for (const core::MatchEvent& e : world.tick()) {
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
                    else ++ch_kick;
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
            {
                const std::uint8_t lk = world.ball().last_kicker;
                if (lk != prev_lk && lk < players && !world.ball().owner) {
                    const int tm = setup.team_of_slot[lk];
                    if (world.isKeeper(lk)) last_parry[tm] = t;
                    else last_deflect[tm] = t;
                }
                prev_lk = lk;
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
            "match %d: home %d - %d away | possession %ld%% / %ld%% (%ld%% contested) | shots %ld / %ld | tackles %ld won / %ld beaten | %ld offsides | breakaway %ld/%d | counters %ld/%d, scrambles %ld/%d (parry %ld, deflect %ld, poke %ld) | funnel H %ld>%ld>%ld A %ld>%ld>%ld | churn steal %ld poke %ld kick %ld keeper %ld other %ld | scoring dist %.1f m | gk off goal %.1f m, off ball %.1f m, ball %.1f m/s\n",
            m, score[0], score[1], owned_ticks[0] * 100 / ticks,
            owned_ticks[1] * 100 / ticks, contested_ticks * 100 / ticks,
            shots[0], shots[1], tk_won, tk_lost, offsides,
            breakaway_goals, goals, counter_goals, goals,
            scramble_goals, goals, sc_parry, sc_deflect, sc_poke,
            fn_wins[0], fn_third[0], fn_shot[0],
            fn_wins[1], fn_third[1], fn_shot[1],
            ch_steal, ch_poke, ch_kick, ch_keeper, ch_other,
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
