// game/tests/test_ai_match.cpp
//
// G2 AI + formations: anchors stay on the pitch, brains are deterministic
// and pure, an AI-vs-AI match flows (possession happens, nobody leaves the
// pitch, the sim completes), and the standing 3v3 + 11v11 goldens enforce
// slot-count agnosticism forever (DESIGN.md §3).

#include "test_harness.hpp"
#include "ai/Brain.hpp"
#include "ai/Formation.hpp"
#include "core/CanonicalHash.hpp"
#include "core/World.hpp"

#include <cstdio>

using namespace fh::game;
using core::World;
using math::Fixed64;
using math::Vec2;
using math::Vec3;

namespace {

const Fixed64 kHX = Fixed64::fromFraction(105, 2);
const Fixed64 kHY = Fixed64::fromInt(34);

// Locked after the first green run (G2.6); placeholder 0 fails loudly.
constexpr std::uint64_t kGolden3v3   = 0xf1af6ad95fa07ec9ULL;
constexpr std::uint64_t kGolden11v11 = 0x3dadd51b2298e24fULL;

struct Rig {
    World world;
    ai::Brain brain;
    ai::TeamSetup setup;

    explicit Rig(std::uint8_t n)
        : world{n, Fixed64::fromInt(6), kHX, kHY},
          brain{ai::TeamSetup::splitHalves(n), kHX, kHY},
          setup{ai::TeamSetup::splitHalves(n)} {
        const std::uint8_t per = n / 2;
        for (std::uint8_t i = 0; i < n; ++i) {
            const bool home = i < per;
            const std::uint8_t k = home ? i : i - per;
            const Fixed64 y = per > 1
                ? Fixed64::fromInt(-25) + Fixed64::fromInt(50) *
                      Fixed64::fromFraction(k, per - 1)
                : Fixed64::zero();
            world.placePlayer(i, Vec3{Fixed64::fromInt(home ? -15 : 15), y,
                                      Fixed64::zero()},
                              Vec2{home ? Fixed64::one() : -Fixed64::one(),
                                   Fixed64::zero()});
            world.setTeam(i, home ? 0 : 1);
        }
    }

    int run(int ticks) {
        int goals = 0;
        for (int t = 0; t < ticks; ++t) {
            for (std::uint8_t s = 0; s < world.playerCount(); ++s) {
                const ai::Orders o = brain.ordersFor(s, world);
                world.setIntent(s, o.move);
                if (o.action != core::Action::None)
                    world.setAction(s, o.action);
            }
            for (const core::MatchEvent& e : world.tick())
                if (e.type == core::MatchEventType::Goal) ++goals;
        }
        return goals;
    }
};

}  // namespace

FH_TEST(formation_anchors_stay_on_pitch) {
    for (std::uint8_t n : {3, 5, 8, 11}) {
        const auto bases = ai::formationBases(n);
        FH_EXPECT_EQ(bases.size(), n);
        // Worst-case ball positions must never push an anchor off-pitch.
        for (const Vec3 ball : {Vec3{kHX, kHY, Fixed64::zero()},
                                Vec3{-kHX, -kHY, Fixed64::zero()}}) {
            for (std::size_t i = 0; i < bases.size(); ++i) {
                for (int sign : {+1, -1}) {
                    const Vec2 a = ai::anchorFor(bases[i], sign, ball, kHX,
                                                 kHY, n >= 5 && i == 0);
                    FH_EXPECT(math::fx_abs(a.x) <= kHX);
                    FH_EXPECT(math::fx_abs(a.y) <= kHY);
                }
            }
        }
    }
}

FH_TEST(brain_is_pure_same_world_same_orders) {
    Rig r{11 * 2};
    r.run(50);
    const auto a = r.brain.ordersFor(7, r.world);
    const auto b = r.brain.ordersFor(7, r.world);
    FH_EXPECT_EQ(a.move.move.x.raw, b.move.move.x.raw);
    FH_EXPECT_EQ(a.move.move.y.raw, b.move.move.y.raw);
    FH_EXPECT(a.action == b.action);
}

FH_TEST(players_clamped_to_pitch_apron) {
    // Drive one player hard at a corner for 30 seconds.
    World w{1, Fixed64::fromInt(6), kHX, kHY};
    core::MoveIntent m;
    m.move = Vec2{Fixed64::one(), Fixed64::one()};
    for (int i = 0; i < 900; ++i) {
        w.setIntent(0, m);
        w.tick();
    }
    FH_EXPECT(w.player(0).pos.x <= kHX + Fixed64::fromInt(2));
    FH_EXPECT(w.player(0).pos.y <= kHY + Fixed64::fromInt(2));
}

FH_TEST(ai_match_flows_possession_and_stays_on_pitch) {
    Rig r{22};
    r.run(30 * 60 * 3);  // 3 sim-minutes
    // Somebody must have had the ball by now.
    bool someone_near_ball = false;
    for (std::uint8_t i = 0; i < 22; ++i) {
        const auto& p = r.world.player(i);
        FH_EXPECT(math::fx_abs(p.pos.x) <= kHX + Fixed64::fromInt(2));
        FH_EXPECT(math::fx_abs(p.pos.y) <= kHY + Fixed64::fromInt(2));
        const Vec2 d{p.pos.x - r.world.ball().pos.x,
                     p.pos.y - r.world.ball().pos.y};
        if (math::lengthSquared(d) < Fixed64::fromInt(100))
            someone_near_ball = true;
    }
    FH_EXPECT(someone_near_ball);
}

FH_TEST(calibration_sanity_goals_in_band) {
    // The realism gate's v0: an 11v11 AI match must produce SOME goals
    // (play flows end to end) and not thousands (mechanics intact).
    // Current measured level: ~203/90min — grinding this toward ~2.7 is
    // G4's whole job; this band only catches mechanical breakage.
    Rig r{22};
    const int goals = r.run(30 * 60 * 10);  // 10 sim-minutes
    std::printf("10-min AI match: %d goals\n", goals);
    FH_EXPECT(goals >= 1);
    FH_EXPECT(goals <= 80);
}

FH_TEST(steal_contest_transfers_carried_ball) {
    World w{2, Fixed64::fromInt(6), kHX, kHY};
    w.setTeam(0, 0);
    w.setTeam(1, 1);
    // Slot 0 captures at centre; slot 1 parks touch-tight on the carry spot.
    w.placePlayer(0, Vec3{Fixed64::fromFraction(-3, 10), Fixed64::zero(),
                          Fixed64::zero()}, Vec2{Fixed64::one(), {}});
    w.placePlayer(1, Vec3{Fixed64::fromFraction(5, 10), Fixed64::zero(),
                          Fixed64::zero()}, Vec2{-Fixed64::one(), {}});
    w.tick();  // slot 0 captures (nearer)
    FH_EXPECT(w.ball().owner.has_value());
    FH_EXPECT_EQ(*w.ball().owner, 0);
    // Stand still: the carried ball sits 0.4 ahead of slot 0 — inside
    // slot 1's steal radius. kStealTicks later it changes hands.
    for (int i = 0; i <= core::kStealTicks + 1; ++i) w.tick();
    FH_EXPECT(w.ball().owner.has_value());
    FH_EXPECT_EQ(*w.ball().owner, 1);
}

FH_TEST(teammate_never_steals) {
    World w{2, Fixed64::fromInt(6), kHX, kHY};
    w.setTeam(0, 0);
    w.setTeam(1, 0);  // same team
    w.placePlayer(0, Vec3{Fixed64::fromFraction(-3, 10), Fixed64::zero(),
                          Fixed64::zero()}, Vec2{Fixed64::one(), {}});
    w.placePlayer(1, Vec3{Fixed64::fromFraction(5, 10), Fixed64::zero(),
                          Fixed64::zero()}, Vec2{-Fixed64::one(), {}});
    for (int i = 0; i < core::kStealTicks * 3; ++i) w.tick();
    FH_EXPECT(w.ball().owner.has_value());
    FH_EXPECT_EQ(*w.ball().owner, 0);
}

FH_TEST(ai_goldens_3v3_and_11v11) {
    // Standing slot-count-agnosticism goldens: 2000 ticks of pure AI play.
    // Re-lock ONLY with a slice that deliberately changes behavior.
    auto hash_for = [](std::uint8_t n) {
        Rig r{n};
        r.run(2000);
        return core::canonicalHash(r.world);
    };
    const auto h3 = hash_for(6);    // 3v3
    const auto h11 = hash_for(22);  // 11v11
    FH_EXPECT_EQ(h3, hash_for(6));
    FH_EXPECT_EQ(h11, hash_for(22));
    std::printf("3v3 golden:  0x%016llx\n11v11 golden: 0x%016llx\n",
                static_cast<unsigned long long>(h3),
                static_cast<unsigned long long>(h11));
    // Locked 2026-10-21 with slice G2.6:
    FH_EXPECT_EQ(h3, kGolden3v3);
    FH_EXPECT_EQ(h11, kGolden11v11);
}

FH_TEST_MAIN()
