// game/src/tools/calibrate_main.cpp — fh-game-calibrate
//
// Calibration harness v0 [FH] (DESIGN.md pillar 5): run N headless AI-vs-AI
// matches at free-run speed and print the realism statistics. v0 drives the
// World+Brain directly; the protocol-speaking headless client replaces it
// when per-match orchestration lands. Usage:
//
//   fh-game-calibrate [matches=5] [players=22] [minutes=90]
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
#include "core/World.hpp"

#include <cstdio>
#include <cstdlib>

using namespace fh::game;
using math::Fixed64;

int main(int argc, char** argv) {
    const int matches = argc > 1 ? std::atoi(argv[1]) : 5;
    const int players = argc > 2 ? std::atoi(argv[2]) : 22;
    const int minutes = argc > 3 ? std::atoi(argv[3]) : 90;
    const long ticks = static_cast<long>(minutes) * 60 * core::kTickRate;

    long total_goals = 0;

    for (int m = 1; m <= matches; ++m) {
        core::World world{static_cast<std::uint8_t>(players),
                          Fixed64::fromInt(6), Fixed64::fromFraction(105, 2),
                          Fixed64::fromInt(34)};
        ai::Brain brain{ai::TeamSetup::splitHalves(
                            static_cast<std::uint8_t>(players)),
                        Fixed64::fromFraction(105, 2), Fixed64::fromInt(34)};
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
        }

        int score[2] = {0, 0};
        long owned_ticks[2] = {0, 0};
        long loose_ticks = 0;

        for (long t = 0; t < ticks; ++t) {
            for (std::uint8_t s = 0; s < players; ++s) {
                const ai::Orders o = brain.ordersFor(s, world);
                world.setIntent(s, o.move);
                if (o.action != core::Action::None) world.setAction(s, o.action);
            }
            for (const core::MatchEvent& e : world.tick())
                if (e.type == core::MatchEventType::Goal) ++score[e.team];
            if (world.ball().owner)
                ++owned_ticks[setup.team_of_slot[*world.ball().owner]];
            else
                ++loose_ticks;
        }

        total_goals += score[0] + score[1];
        std::printf(
            "match %d: home %d - %d away | possession %ld%% / %ld%% (%ld%% loose)\n",
            m, score[0], score[1], owned_ticks[0] * 100 / ticks,
            owned_ticks[1] * 100 / ticks, loose_ticks * 100 / ticks);
    }

    std::printf("AGGREGATE over %d: %.1f goals/game | anchor: real-world ~2.7\n",
                matches, static_cast<double>(total_goals) / matches);
    return 0;
}
