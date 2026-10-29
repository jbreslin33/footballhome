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
#include "core/Levels.hpp"
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
// Re-locked G4.65 (2026-10-26): a marker never tucks or chains more than
// max_off_man_m off his own man (mark-position cap, jump-the-pass chain).
// Re-locked G4.67 (2026-10-26): near-tight-far-zone — tight near the ball,
// off toward the middle far from it.
// Re-locked G4.80 (2026-10-27): brake to arrive, braking on its own τ,
// semi-pro shape pull 0, the block moves up with its own ball; the
// shape keeps its phase while our own pass is in the air (G4.80b).
// Re-locked G4.81 (2026-10-28): a pass names the man it's for (the rest
// let it run, half a second through the passer's mates), ground passes are
// weighted to arrive at 6 m/s and led into a moving man's path, and a
// receiver who misses the read steps onto its line instead of holding shape.
// Re-locked G4.82 (2026-10-28): the led pass is re-read before it's
// struck (unsafe led = the ball he checked).
// Re-locked G4.84 (2026-10-28): firm passes (arrive 9 m/s) and a race to a
// moving ball brakes to arrive ON TIME.
// Re-locked G4.85 (2026-10-29): reaction is each player's own (hashed in his
// body), charged once from the kick; our ball is met at a pace he can hold.
// Re-locked G4.86 (2026-10-29): passSafe runs the flight read's own race;
// a ball he reads as ground is one he won't loft; G4.86b a loft is raced too.
// Re-locked G4.87 (2026-10-29): air drag on the ball in flight (BallFlight).
// Re-locked G4.88 (2026-10-29): the officials are bodies on the pitch
// (hashed) and the assistant's offside call stands.
// G4.87 + G4.88 together:
// G4.90: the assistant shadows the line, aiming level (no slack beyond).
constexpr std::uint64_t kGolden3v3   = 0x50ebed164208f04dULL;
// G4.89: Law 11 on every pass (no ball to a man read offside).
constexpr std::uint64_t kGolden11v11 = 0xdd1114faa77546a2ULL;

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
            world.setKeeper(i, ai::builtinFormation(per).positions[k].keeper);
        }
    }

    int run(int ticks) {
        int goals = 0;
        for (int t = 0; t < ticks; ++t) {
            for (std::uint8_t s = 0; s < world.playerCount(); ++s) {
                const ai::Orders o = brain.ordersFor(s, world);
                world.setIntent(s, o.move);
                if (o.action != core::Action::None)
                    world.setAction(s, o.action, o.carry_m);
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
    r.run(30 * 60 * 3 - 30);  // 3 sim-minutes, the last second checked tick by tick
    // Somebody must be with the ball — within 10 m at some tick of the last
    // second (one instant can catch a pass rolling between two men: G4.65's
    // marking left the nearest man 10.0 m from a 9.6 m/s ball).
    bool someone_near_ball = false;
    for (int t = 0; t < 30; ++t) {
        r.run(1);
        for (std::uint8_t i = 0; i < 22; ++i) {
            const auto& p = r.world.player(i);
            FH_EXPECT(math::fx_abs(p.pos.x) <= kHX + Fixed64::fromInt(2));
            FH_EXPECT(math::fx_abs(p.pos.y) <= kHY + Fixed64::fromInt(2));
            const Vec2 d{p.pos.x - r.world.ball().pos.x,
                         p.pos.y - r.world.ball().pos.y};
            if (math::lengthSquared(d) < Fixed64::fromInt(100))
                someone_near_ball = true;
        }
    }
    FH_EXPECT(someone_near_ball);
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
