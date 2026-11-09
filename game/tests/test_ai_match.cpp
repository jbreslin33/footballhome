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

#include <cstdlib>
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
// G5.2: the ball out is the officials' call; restarts held until played.
// G4.89: Law 11 on every pass (no ball to a man read offside).
// Re-locked G5.21 (2026-11-05): the G4 defending chain deleted; out of
// possession = the phase + player state machines, the block at real spots.
// Re-locked G5.22 (2026-11-05): the whole old brain purged; in possession and
// the keeper rebuilt as player states (support at real spots, on-ball by data).
// Re-locked G5.23 (2026-11-05): levels, skill bands, sheets deleted; the hash
// mixes every player's skill.
// Re-locked G5.25 (2026-11-05): the pass policy and the press stand-off from
// real data; a keeper takes the ball played back to him.
// Re-locked G5.27 (2026-11-05): the ball in behind (DFL), the runner keeps his run, a ball at rest
// nobody can reach in the race horizon is our nearest man's.
// Re-locked G5.28 (2026-11-05): detNoise finalized (splitmix64 — channels were correlated);
// fouls and free kicks (Law 12); the kick-off after a goal waits a real roll.
// Re-locked G5.29 (2026-11-05): he carries the ball through the hold; the brain's kick goes at its aim.
// Re-locked G5.30 (2026-11-06): the block shifts on where the ball is going and runs with its moving spot.
// Re-locked G5.33 (2026-11-06): the block spot is the real SETTLED table (6 s+ since it lost it).
// Re-locked G5.38 (2026-11-06): the block narrows toward its goal (real settled widths by role and band).
// Re-locked G5.39 (2026-11-06): the presser arrives at his spot at the carrier's speed.
// Re-locked G5.42 (2026-11-06): the block spot is where real men stand with the ball STILL (lag not baked in).
// Re-locked G5.43 (2026-11-06): the support spot too (the side in possession, ball still).
// Re-locked G5.45 (2026-11-07): runs onto their line at the real rate (the ball not going forward).
// Re-locked G5.46 (2026-11-07): each man's depth for the possession (spell offset, DFL).
// Re-locked G5.47 (2026-11-07): the front man on their line, tracking it.
// Re-locked G5.49 (2026-11-07): the second man on their line too.
// Re-locked G5.50 (2026-11-07): line jobs close at 1 m/s with the ball not going forward.
// Re-locked G5.51 (2026-11-07): a ball in behind is played whatever the race read says.
// Re-locked G5.52 (2026-11-07): the block's depth for their possession.
// Re-locked G5.53 (2026-11-07): how many go into the box goes by their line's depth.
// Re-locked G5.54 (2026-11-07): the ball into an empty zone ahead (space, crosses).
// Re-locked G5.55 (2026-11-07): a ground ball into space only if ours gets there first.
// Re-locked G5.56 (2026-11-07): a man in their wide channel by their line's depth.
// Re-locked G5.57 (2026-11-07): the ball into space forward only, a die-at kick never softer than dying past its spot.
// Re-locked G5.60 (2026-11-08): box runners kept on a redraw, nearest spots, drawn from our pass's man.
// Re-locked G5.61 (2026-11-09): box count one roll per 3 s of the spell, deep hysteresis, runners in the box stay, held through our restarts.
// Re-locked G5.62 (2026-11-09): support men follow their line in as it drops below its usual depth.
// Re-locked G5.63 (2026-11-09): a busy front man (the pass's man, a runner) keeps the front job.
constexpr std::uint64_t kGolden3v3   = 0x6a6d3cff70ac8099ULL;
// Re-locked G5.26 (2026-11-05, 11v11 only): runs into the box (DFL box occupancy).
// Re-locked G5.27 (2026-11-05): as the 3v3.
// Re-locked G5.28 (2026-11-05): as the 3v3.
// Re-locked G5.29 (2026-11-05): as the 3v3.
// Re-locked G5.30 (2026-11-06): as the 3v3.
// Re-locked G5.33 (2026-11-06): as the 3v3.
// Re-locked G5.37 (2026-11-06): shots go where real ones went; the keeper reacts to the strike.
// Re-locked G5.38 (2026-11-06): as the 3v3.
// Re-locked G5.39 (2026-11-06): as the 3v3.
// Re-locked G5.42 (2026-11-06): as the 3v3.
// Re-locked G5.43 (2026-11-06): as the 3v3.
// Re-locked G5.45 (2026-11-07): as the 3v3.
// Re-locked G5.46 (2026-11-07): as the 3v3.
// Re-locked G5.47 (2026-11-07): as the 3v3.
// Re-locked G5.49 (2026-11-07): as the 3v3.
// Re-locked G5.50 (2026-11-07): as the 3v3.
// Re-locked G5.51 (2026-11-07): as the 3v3.
// Re-locked G5.52 (2026-11-07): as the 3v3.
// Re-locked G5.53 (2026-11-07): as the 3v3.
// Re-locked G5.54 (2026-11-07): as the 3v3.
// Re-locked G5.55 (2026-11-07): as the 3v3.
// Re-locked G5.56 (2026-11-07): as the 3v3.
// Re-locked G5.57 (2026-11-07): as the 3v3.
// Re-locked G5.59 (2026-11-08, 11v11 only): the pass shares × the chooser's when-occupied kappa (DFL).
// Re-locked G5.60 (2026-11-08): as the 3v3.
// Re-locked G5.61 (2026-11-09): as the 3v3.
// Re-locked G5.62 (2026-11-09): as the 3v3.
// Re-locked G5.63 (2026-11-09): as the 3v3.
constexpr std::uint64_t kGolden11v11 = 0x686a704ac1faff7dULL;

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
    r.run(30 * 60 * 3 - 90);  // 3 sim-minutes, the last 3 seconds checked tick by tick
    // Somebody must be with the ball — within 10 m at some tick of the last
    // 3 seconds (one instant can catch a pass rolling between two men, or a
    // long ball landing in space with the keeper still 10 m off it, G5.25).
    bool someone_near_ball = false;
    for (int t = 0; t < 90; ++t) {
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

// Tactics trainer step 1: a man carries a label only while his side's phase is a
// defending one (block, transition to defend, their set piece) and never in goal; the
// label follows the engine, so a side that has just won it keeps it until its phase
// flips. At most one presser a side.
FH_TEST(trainer_labels_out_of_possession) {
    Rig r{22};
    int labelled = 0, press_frames = 0;
    for (int t = 0; t < 1500; ++t) {
        r.run(1);
        int press[2] = {0, 0};
        for (std::uint8_t s = 0; s < r.world.playerCount(); ++s) {
            const ai::Act a = r.brain.actOf(s, r.world, r.brain.ordersFor(s, r.world));
            if (a == ai::Act::None) continue;
            const std::uint8_t tm = r.world.player(s).team;
            const ai::Phase ph = r.brain.phaseOf(tm);
            FH_EXPECT(!r.world.isKeeper(s));
            FH_EXPECT(ph == ai::Phase::DefendingBlock || ph == ai::Phase::DefensiveTransition || ph == ai::Phase::TheirSetPiece);
            ++labelled;
            if (a == ai::Act::PressBall) ++press[tm & 1];
        }
        FH_EXPECT(press[0] <= 1 && press[1] <= 1);
        press_frames += press[0] + press[1];
    }
    FH_EXPECT(labelled > 0);
    FH_EXPECT(press_frames > 0);
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
