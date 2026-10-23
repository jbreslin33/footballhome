// game/tests/test_concepts.cpp — G4.33: concepts and skills as classes,
// numbers from game_model_params.

#include "test_harness.hpp"
#include "ai/Brain.hpp"
#include "ai/Concept.hpp"
#include "core/ModelParams.hpp"
#include "core/Skill.hpp"
#include "core/World.hpp"

using namespace fh::game;
using fh::game::math::Fixed64;
using fh::game::math::Vec2;
using fh::game::math::Vec3;

namespace {
// Slots 0-1 team 0 (attacks +x), slots 2-3 team 1.
core::World pitch() {
    core::World w{4, Fixed64::fromInt(6), Fixed64::fromFraction(105, 2), Fixed64::fromInt(34)};
    for (core::SlotIndex i = 0; i < 4; ++i) w.setTeam(i, i < 2 ? 0 : 1);
    return w;
}
Vec3 at(int x, int y) { return Vec3{Fixed64::fromInt(x), Fixed64::fromInt(y), Fixed64::zero()}; }
const Vec2 kFacePlus{Fixed64::one(), Fixed64::zero()};
const Vec2 kFaceMinus{-Fixed64::one(), Fixed64::zero()};
ai::ConceptContext ctx(const core::World& w, core::SlotIndex slot, int sign, Vec2 ball, int pct) {
    return ai::ConceptContext{w, slot, sign, ball, Fixed64::fromFraction(105, 2), Fixed64::fromFraction(pct, 100)};
}
}  // namespace

FH_TEST(model_params_are_milli_exact) {
    core::ModelParams p;
    p.setMilli("concept.libero.depth_min_m", 2500);
    FH_EXPECT(p.fixed("concept.libero.depth_min_m", 9000) == Fixed64::fromFraction(5, 2));
    FH_EXPECT(p.fixed("missing", 3000) == Fixed64::fromInt(3));
    p.setMilli("x", 2500);
    FH_EXPECT(p.integer("x", 0) == 3);
    FH_EXPECT(p.integer("missing", 7) == 7);
}

FH_TEST(skill_set_defaults_equal_the_old_formulas_and_db_rows_change_them) {
    const auto band = core::levelParams("amateur");
    core::PlayerAttributes a;
    a.passing = 100;
    a.first_touch = 0;
    core::SkillSet defaults;
    const auto d = defaults.apply(band, a);
    FH_EXPECT(d.kick_angle_err_deg == 3 && d.control_speed_mps == 8);
    core::ModelParams p;
    p.setMilli("skill.passing.at100_pct", 25000);     // a passing ace errs a quarter as much
    p.setMilli("skill.pace.base_cms", 500000);
    core::SkillSet tuned(p);
    FH_EXPECT(tuned.apply(band, a).kick_angle_err_deg == 2);   // (6*50+100)/200
    FH_EXPECT(tuned.speedCms(50) == 600 && defaults.speedCms(50) == 640);
    FH_EXPECT(tuned.skills().size() == core::kAttributeCount);
    FH_EXPECT(tuned.skills()[0]->code() == "pace" && tuned.skills()[7]->code() == "goalkeeping");
}

FH_TEST(concepts_carry_their_registry_identity) {
    ai::ConceptBook b;
    FH_EXPECT(b.libero.name() == core::kConceptNames[b.libero.bit()]);
    FH_EXPECT(b.cover_shadow.name() == core::kConceptNames[b.cover_shadow.bit()]);
    FH_EXPECT(b.line_step.name() == core::kConceptNames[b.line_step.bit()]);
    FH_EXPECT(b.pass_ladder.name() == core::kConceptNames[b.pass_ladder.bit()]);
}

FH_TEST(libero_sits_behind_the_deepest_teammate_on_the_ball_side) {
    auto w = pitch();
    w.placePlayer(0, at(-30, 0), kFacePlus);   // libero
    w.placePlayer(1, at(-20, 5), kFacePlus);   // deepest teammate
    w.placePlayer(2, at(0, 10), kFaceMinus);
    w.placePlayer(3, at(10, 0), kFaceMinus);
    ai::Libero lib;
    lib.configure(core::ModelParams{});
    // rating 100: 2 + 3 = 5 m behind -20; ball at y=20 → 0.6 x 20 = 12.
    const Vec2 t = lib.target(ctx(w, 0, +1, Vec2{Fixed64::zero(), Fixed64::fromInt(20)}, 100));
    FH_EXPECT(t.x == Fixed64::fromInt(-25));
    // 0.6 is not exact in binary fixed point: within a millimetre.
    FH_EXPECT(math::fx_abs(t.y - Fixed64::fromInt(12)) < Fixed64::fromFraction(1, 1000));
}

FH_TEST(cover_shadow_stands_on_the_lane_to_the_receiver) {
    auto w = pitch();
    w.placePlayer(0, at(10, 10), kFacePlus);    // our 9
    w.placePlayer(2, at(40, 0), kFaceMinus);    // their CB, carrying
    w.placePlayer(3, at(30, 0), kFaceMinus);    // their 6, ahead of him
    core::BallState b;
    b.pos = at(40, 0);
    b.owner = 2;
    w.placeBall(b);
    ai::CoverShadow cs;
    cs.configure(core::ModelParams{});
    auto t = cs.target(ctx(w, 0, +1, Vec2{Fixed64::fromInt(40), Fixed64::zero()}, 90));
    FH_EXPECT(t.has_value());
    FH_EXPECT(t->x == Fixed64::fromFraction(75, 2) && t->y == Fixed64::zero());   // 2.5 m toward the 6
    // In their half but not deep (x 10): no cover-shadow run.
    w.placePlayer(2, at(10, 0), kFaceMinus);
    b.pos = at(10, 0);
    w.placeBall(b);
    FH_EXPECT(!cs.target(ctx(w, 0, +1, Vec2{Fixed64::fromInt(10), Fixed64::zero()}, 90)).has_value());
}

FH_TEST(line_steps_on_a_covered_ball_and_holds_on_an_open_one) {
    auto w = pitch();
    ai::LineStep ls;
    ls.configure(core::ModelParams{});
    w.placePlayer(0, at(-30, 0), kFacePlus);          // our CB
    w.placePlayer(1, at(-40, 20), kFacePlus);
    core::BallState b;
    b.pos = at(10, 0);
    b.owner = 2;
    // Carrier turned to HIS own goal (+x, away from ours): covered → step.
    w.placePlayer(2, at(10, 0), kFacePlus);
    w.placePlayer(3, at(0, 15), kFaceMinus);
    w.placeBall(b);
    auto line = ls.stepLine(ctx(w, 0, +1, Vec2{Fixed64::fromInt(10), Fixed64::zero()}, 68));
    FH_EXPECT(line.has_value() && *line == Fixed64::fromInt(-2));   // 10 - 12
    // Carrier facing forward, free: uncovered → hold.
    w.placePlayer(2, at(10, 0), kFaceMinus);
    FH_EXPECT(!ls.stepLine(ctx(w, 0, +1, Vec2{Fixed64::fromInt(10), Fixed64::zero()}, 68)).has_value());
    // Same, but pressed by our man within 3 m: covered again.
    w.placePlayer(1, at(12, 0), kFacePlus);
    FH_EXPECT(ls.covered(ctx(w, 0, +1, Vec2{Fixed64::fromInt(10), Fixed64::zero()}, 68)));
    // Ball travelling, nobody near it: covered (step while it moves) …
    w.placePlayer(1, at(-40, 20), kFacePlus);
    core::BallState mv;
    mv.pos = at(-5, 0);
    mv.vel = Vec3{Fixed64::fromInt(-10), Fixed64::zero(), Fixed64::zero()};
    w.placeBall(mv);
    FH_EXPECT(ls.covered(ctx(w, 0, +1, Vec2{Fixed64::fromInt(-5), Fixed64::zero()}, 68)));
    // … but a free opponent about to receive it facing forward: hold.
    w.placePlayer(3, at(-8, 2), kFaceMinus);
    FH_EXPECT(!ls.covered(ctx(w, 0, +1, Vec2{Fixed64::fromInt(-5), Fixed64::zero()}, 68)));
}

FH_TEST(pass_ladder_rungs_follow_the_book_order) {
    ai::PassLadder pl;
    pl.configure(core::ModelParams{});
    const ai::PassLadder::Lines l{Fixed64::fromInt(20), Fixed64::fromInt(0)};
    auto r = [&](int x, int y) { return pl.rung(Fixed64::fromInt(x), Fixed64::fromInt(y), l); };
    FH_EXPECT(r(25, 0) == 1 && r(25, -25) == 2);    // behind the line: central, wide
    FH_EXPECT(r(15, 5) == 3 && r(15, 22) == 4);     // pocket (within 10 m in front)
    FH_EXPECT(r(5, 0) == 5 && r(5, 30) == 6);       // past their first line
    FH_EXPECT(r(-3, 0) == 0);                       // not past anyone: off the ladder
    // Lower rung wins; on the same rung more progress wins; 0 is last.
    FH_EXPECT(ai::PassLadder::better(1, Fixed64::fromInt(21), 2, Fixed64::fromInt(30)));
    FH_EXPECT(ai::PassLadder::better(3, Fixed64::fromInt(18), 3, Fixed64::fromInt(12)));
    FH_EXPECT(ai::PassLadder::better(6, Fixed64::fromInt(1), 0, Fixed64::fromInt(9)));
    // Rungs played at once: 2 at rating 0, 3 at 50, 4 at 90 and 100.
    FH_EXPECT(pl.fireRung(Fixed64::zero()) == 2);
    FH_EXPECT(pl.fireRung(Fixed64::fromFraction(1, 2)) == 3);
    FH_EXPECT(pl.fireRung(Fixed64::fromFraction(9, 10)) == 4);
    FH_EXPECT(pl.fireRung(Fixed64::one()) == 4);
    // A DB row moves the line between central and wide.
    core::ModelParams p;
    p.setMilli("concept.pass-ladder.central_half_width_m", 30000);
    pl.configure(p);
    FH_EXPECT(r(25, -25) == 1);
}

namespace {
// 4v4, nobody a keeper: team 0 (slots 0-3) attacks +x; slot 0 carries.
struct LadderRig {
    core::World w{8, Fixed64::fromInt(6), Fixed64::fromFraction(105, 2), Fixed64::fromInt(34)};
    ai::Brain brain{ai::TeamSetup::splitHalves(8), Fixed64::fromFraction(105, 2), Fixed64::fromInt(34)};
    LadderRig() {
        for (core::SlotIndex i = 0; i < 8; ++i) w.setTeam(i, i < 4 ? 0 : 1);
    }
    void carry(int x, int y) {
        w.placePlayer(0, at(x, y), kFacePlus);
        core::BallState b;
        b.pos = at(x, y);
        b.owner = 0;
        w.placeBall(b);
    }
    ai::Orders orders(int ladder_rating) {
        core::ConceptRatings r{};
        r[29] = static_cast<std::uint8_t>(ladder_rating);
        brain.setRatings(0, r);
        return brain.ordersFor(0, w);
    }
};
}  // namespace

FH_TEST(laddered_passer_prefers_central_in_behind_over_more_progress_wide) {
    LadderRig g;
    g.carry(0, 10);
    g.w.placePlayer(1, at(24, 10), kFacePlus);    // behind their line, central (rung 1)
    g.w.placePlayer(2, at(26, 24), kFacePlus);    // behind it, wide, 2 m further (rung 2)
    g.w.placePlayer(3, at(-20, 0), kFacePlus);
    g.w.placePlayer(4, at(20, 0), kFaceMinus);    // their back line x 20
    g.w.placePlayer(5, at(20, -15), kFaceMinus);
    g.w.placePlayer(6, at(5, -25), kFaceMinus);   // their first line x 5
    g.w.placePlayer(7, at(5, -10), kFaceMinus);
    // Without the ladder: most progress — the wide man.
    const ai::Orders plain = g.orders(0);
    FH_EXPECT(plain.action == core::Action::GroundKick && plain.move.move.y > Fixed64::zero());
    // With it: the central ball in behind (straight up the pitch).
    const ai::Orders lad = g.orders(100);
    FH_EXPECT(lad.action == core::Action::GroundKick && lad.move.move.y == Fixed64::zero());
}

FH_TEST(laddered_passer_plays_the_pocket_without_the_gain_threshold) {
    LadderRig g;
    g.carry(8, 0);
    g.w.placePlayer(1, at(14, 0), kFacePlus);     // 6 m on, in the pocket (rung 3)
    g.w.placePlayer(2, at(-20, 20), kFacePlus);
    g.w.placePlayer(3, at(-20, -20), kFacePlus);
    g.w.placePlayer(4, at(20, -8), kFaceMinus);   // their back line x 20
    g.w.placePlayer(5, at(20, 8), kFaceMinus);
    g.w.placePlayer(6, at(0, -25), kFaceMinus);
    g.w.placePlayer(7, at(0, 25), kFaceMinus);
    // 6 m of gain is under the 8 m "worth it" threshold: plain carries on.
    FH_EXPECT(g.orders(0).action == core::Action::None);
    // The ladder plays it: rung 3 is within fireRung(1.0) = 4.
    FH_EXPECT(g.orders(100).action == core::Action::ShortPass);
}

FH_TEST_MAIN()
