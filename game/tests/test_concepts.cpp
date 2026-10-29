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
    FH_EXPECT(b.libero.name() == core::concepts().name(b.libero.bit()));
    FH_EXPECT(b.cover_shadow.name() == core::concepts().name(b.cover_shadow.bit()));
    FH_EXPECT(b.line_step.name() == core::concepts().name(b.line_step.bit()));
    FH_EXPECT(b.pass_ladder.name() == core::concepts().name(b.pass_ladder.bit()));
    FH_EXPECT(b.blind_side_run.name() == core::concepts().name(b.blind_side_run.bit()));
}

FH_TEST(libero_sits_behind_the_deepest_teammate_on_the_ball_side) {
    auto w = pitch();
    w.placePlayer(0, at(-30, 0), kFacePlus);   // libero
    w.placePlayer(1, at(-20, 5), kFacePlus);   // deepest teammate
    w.placePlayer(2, at(0, 10), kFaceMinus);
    w.placePlayer(3, at(10, 0), kFaceMinus);
    ai::Libero lib;
    lib.configure(core::ModelParams{});
    // Their carrier can play long: sweeping depth, 2 + 3 = 5 m behind -20;
    // the ball out wide at y=25 (channel 5): he stops at channel 4's edge, 19.
    const Vec2 t = lib.target(ctx(w, 0, +1, Vec2{Fixed64::zero(), Fixed64::fromInt(25)}, 100), true);
    FH_EXPECT(t.x == Fixed64::fromInt(-25));
    FH_EXPECT(t.y == Fixed64::fromInt(19));
    // The ball in the half-space (y=12, channel 4): he's in its channel.
    FH_EXPECT(lib.target(ctx(w, 0, +1, Vec2{Fixed64::zero(), Fixed64::fromInt(12)}, 100), true).y == Fixed64::fromInt(12));
    // Covered ball: he's part of the line, 0.5 m goal-side of it.
    const Vec2 on_line = lib.target(ctx(w, 0, +1, Vec2{Fixed64::zero(), Fixed64::fromInt(25)}, 100), false);
    FH_EXPECT(on_line.x == -Fixed64::fromFraction(41, 2));
}

FH_TEST(libero_lapses_too_deep_or_too_high) {
    auto w = pitch();
    w.placePlayer(0, at(-30, 0), kFacePlus);   // the free man
    w.placePlayer(1, at(-20, 5), kFacePlus);   // deepest teammate: the line
    w.placePlayer(2, at(-8, 3), kFaceMinus);   // their 10, between the lines
    w.placePlayer(3, at(10, 0), kFaceMinus);
    const auto c = ctx(w, 0, +1, Vec2{Fixed64::zero(), Fixed64::zero()}, 100);
    // Too deep: 4 m behind the line whatever the ball.
    ai::DeepSweeper deep;
    deep.configure(core::ModelParams{});
    FH_EXPECT(deep.target(c).x == Fixed64::fromInt(-24));
    // Too high: out to their 10, 1.5 m goal-side of him.
    ai::StepOut out;
    out.configure(core::ModelParams{});
    const Vec2 t = out.target(c);
    FH_EXPECT(t.x == -Fixed64::fromFraction(19, 2) && t.y == Fixed64::fromInt(3));
    // Nobody between the lines: he still steps 6 m off the line.
    w.placePlayer(2, at(10, 20), kFaceMinus);
    FH_EXPECT(out.target(ctx(w, 0, +1, Vec2{Fixed64::zero(), Fixed64::zero()}, 100)).x == Fixed64::fromInt(-14));
}

FH_TEST(pass_habits_pick_short_and_simple_or_long) {
    auto w = pitch();
    w.placePlayer(0, at(0, 0), kFacePlus);     // on the ball
    w.placePlayer(1, at(-4, 6), kFacePlus);    // short, slightly back
    w.placePlayer(2, at(14, 0), kFaceMinus);
    w.placePlayer(3, at(30, 0), kFaceMinus);
    ai::ShortSimple shortp;
    shortp.configure(core::ModelParams{});
    // The nearest open man; back is fine.
    FH_EXPECT(shortp.pick(ctx(w, 0, +1, Vec2{}, 100), [](const Vec2&, const Vec2&) { return true; }) == core::SlotIndex{1});
    // His lane shut: nobody.
    FH_EXPECT(!shortp.pick(ctx(w, 0, +1, Vec2{}, 100), [](const Vec2&, const Vec2&) { return false; }));
    // Route one: a forward man 25 m away, lofted over their man.
    ai::DirectBall direct;
    direct.configure(core::ModelParams{});
    FH_EXPECT(!direct.pick(ctx(w, 0, +1, Vec2{}, 100)));   // nobody 10 m+ ahead
    w.placePlayer(1, at(24, 7), kFacePlus);
    FH_EXPECT(direct.pick(ctx(w, 0, +1, Vec2{}, 100)) == core::SlotIndex{1});
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
    const ai::PassLadder::Lines l{Fixed64::fromInt(20), Fixed64::fromInt(0), Fixed64::fromInt(20)};
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
    // Offside position: beyond the second-last opponent AND the ball AND
    // halfway; level is onside.
    FH_EXPECT(ai::PassLadder::offsidePosition(Fixed64::fromInt(21), Fixed64::zero(), l));
    FH_EXPECT(!ai::PassLadder::offsidePosition(Fixed64::fromInt(20), Fixed64::zero(), l));
    FH_EXPECT(!ai::PassLadder::offsidePosition(Fixed64::fromInt(21), Fixed64::fromInt(22), l));
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

FH_TEST(laddered_passer_skips_offside_and_leads_the_central_runner) {
    LadderRig g;
    g.carry(5, 10);
    // Two onside runners at x 19, one stride short of their line (x 20),
    // led by reaction 0.3 s + flight (distance / 12 m/s):
    g.w.placePlayer(1, at(19, 10), kFacePlus);    // central, 7 m/s → lead x ≈ 29.3: rung 1
    g.w.placeVelocity(1, at(7, 0));
    g.w.placePlayer(2, at(19, 22), kFacePlus);    // wide, 6 m/s → lead x ≈ 30.0: rung 2, more progress
    g.w.placeVelocity(2, at(6, 0));
    g.w.placePlayer(3, at(24, 4), kFacePlus);     // standing BEYOND their line: offside
    g.w.placePlayer(4, at(20, 0), kFaceMinus);    // their line x 20
    g.w.placePlayer(5, at(20, -15), kFaceMinus);
    g.w.placePlayer(6, at(5, -25), kFaceMinus);
    g.w.placePlayer(7, at(5, -10), kFaceMinus);
    // Without the ladder: most progress — but never the man standing
    // offside (G4.89: Law 11 on every pass, not only the ladder's).
    const ai::Orders plain = g.orders(0);
    FH_EXPECT(plain.action == core::Action::GroundKick && plain.other != 3 &&
              plain.move.move.y >= Fixed64::zero());
    // With it: the ball into the space ahead of the central runner
    // (straight up the pitch), not the offside man, not the wide run.
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

FH_TEST(blind_side_run_waits_onside_then_goes_behind_a_ball_watcher) {
    auto w = pitch();
    ai::BlindSideRun bs;
    bs.configure(core::ModelParams{});
    const Vec2 ball{Fixed64::zero(), Fixed64::zero()};
    core::BallState b;
    b.pos = at(0, 0);
    b.owner = 0;
    w.placeBall(b);
    w.placePlayer(1, at(19, 11), kFacePlus);   // our runner, up at their line
    const Vec2 watching = math::normalized(Vec2{Fixed64::fromInt(-20), Fixed64::fromInt(-8)});
    w.placePlayer(2, at(20, 8), watching);     // their defender, eyes on the ball
    w.placePlayer(0, at(0, 0), kFacePlus);
    // Carrier pressed (a man 2 m off him): no time to pass — wait onside
    // (2 m) on the defender's far shoulder (8 + 1.5).
    w.placePlayer(3, at(2, 0), kFaceMinus);
    auto t = bs.target(ctx(w, 1, +1, ball, 90));
    FH_EXPECT(t.has_value() && t->x == Fixed64::fromInt(18) && t->y == Fixed64::fromFraction(19, 2));
    // Carrier free and the defender watches the ball: GO — 10 m behind
    // the line, across his back toward the channel (9.5 x 0.6).
    w.placePlayer(3, at(20, -10), kFaceMinus);
    t = bs.target(ctx(w, 1, +1, ball, 90));
    FH_EXPECT(t.has_value() && t->x == Fixed64::fromInt(30));
    FH_EXPECT(math::fx_abs(t->y - Fixed64::fromFraction(57, 10)) < Fixed64::fromFraction(1, 1000));
    // He turns to face the runner: seen — back to waiting.
    w.placePlayer(2, at(20, 8), math::normalized(Vec2{Fixed64::fromInt(-1), Fixed64::fromInt(3)}));
    t = bs.target(ctx(w, 1, +1, ball, 90));
    FH_EXPECT(t.has_value() && t->x == Fixed64::fromInt(18));
    // A run the pass didn't find: he's offside (beyond both defenders)
    // while we still have the ball — back to the waiting spot to re-time.
    w.placePlayer(2, at(20, 8), watching);
    w.placePlayer(1, at(23, 11), kFacePlus);
    t = bs.target(ctx(w, 1, +1, ball, 90));
    FH_EXPECT(t.has_value() && t->x == Fixed64::fromInt(18));
    w.placePlayer(1, at(19, 11), kFacePlus);
    // Not up at their line (more than 18 m short of it): not this concept's job.
    w.placePlayer(1, at(1, 11), kFacePlus);
    FH_EXPECT(!bs.target(ctx(w, 1, +1, ball, 90)).has_value());
}

FH_TEST(a_db_curriculum_fills_the_builtin_holes) {
    // Hotfix: the boot check compares only ids the builtin names. A DB that
    // fills its holes (31-152) is compatible; one that renames a wired id
    // is not. (Comparing the holes refused every real DB for G4.53-G4.54.)
    const core::ConceptRegistry wired = core::ConceptRegistry::builtin();
    core::ConceptRegistry db = core::ConceptRegistry::builtin();
    db.add(71, "offside-trap", 0);
    db.add(150, "step-out", 0);
    FH_EXPECT_EQ(db.firstRenumbered(wired), -1);
    db.add(153, "not-meet-the-pass", 0);
    FH_EXPECT_EQ(db.firstRenumbered(wired), 153);
}

FH_TEST(the_curriculum_grows_by_rows_past_32_concepts) {
    // Built in: the 31 wired concepts, ids = the old bits, plus the later
    // core lessons the harness must play (G4.53: 153 meet-the-pass, 154
    // face-the-play; G4.54: 155-157 1v1 defending; G4.57: 158-160 marking; G4.60: 161 keep it under pressure; G4.63: 162-164 the one-spot defender; G4.66: 33 scan-before-receive, 171 scan-defending) — the ids between are holes.
    const core::ConceptRegistry b = core::ConceptRegistry::builtin();
    FH_EXPECT(b.size() == 172 && b.find("pass-ladder") == 29 && b.name(30) == "blind-side-run");
    FH_EXPECT(b.find("meet-the-pass") == 153 && b.find("face-the-play") == 154 && b.name(60).empty());
    FH_EXPECT(b.find("rotation") == -1);
    FH_EXPECT(b.find("scan-before-receive") == 33 && b.find("scan-defending") == 171);
    // A DB curriculum: the wired 31 plus lessons far past the old 32-bit cap,
    // with a hole — taught or not, every one has a rating slot.
    core::ConceptRegistry db = core::ConceptRegistry::builtin();
    db.add(40, "rotation", 0);                                  // style lesson, no class yet
    db.add(120, "first-touch-direction", core::levelRank("u14"));  // taught from U-14
    FH_EXPECT(db.size() == 172 && db.find("first-touch-direction") == 120 && db.name(60).empty());
    core::setConcepts(db);
    const auto u14 = core::defaultRatings(core::levelParams("u14"));
    const auto u10 = core::defaultRatings(core::levelParams("u10"));
    FH_EXPECT(u14[120] == 30 && u10[120] == 0);   // the U-14 band knows it at its quality
    FH_EXPECT(u14[40] == 0);                       // style: never a band default
    FH_EXPECT(u14[2] == 30 && u14[0] == 0);        // cover from u10; delay from amateur
    core::setConcepts(core::ConceptRegistry::builtin());
}

FH_TEST(release_timing_holds_for_the_runner_then_lets_it_go) {
    LadderRig g;
    g.carry(5, 0);
    g.w.placePlayer(1, at(15, -6), kFacePlus);    // a pocket pass, 10 m on (rung 3)
    g.w.placePlayer(2, at(12, 12), kFacePlus);    // the runner, 8 m short of their line,
    g.w.placeVelocity(2, at(5, 0));               // attacking it at 5 m/s
    g.w.placePlayer(3, at(-20, 0), kFacePlus);
    g.w.placePlayer(4, at(20, -8), kFaceMinus);   // their line x 20
    g.w.placePlayer(5, at(20, 2), kFaceMinus);
    g.w.placePlayer(6, at(-5, -25), kFaceMinus);
    g.w.placePlayer(7, at(-5, 25), kFaceMinus);
    auto orders = [&](int release) {
        core::ConceptRatings r{};
        r[29] = 100;                               // pass ladder
        r[60] = static_cast<std::uint8_t>(release);
        g.brain.setRatings(0, r);
        return g.brain.ordersFor(0, g.w);
    };
    // Without it: the ladder plays the pocket pass now.
    FH_EXPECT(orders(0).action == core::Action::ShortPass);
    // With it: hold — his ball in behind isn't on yet (lead x ~19.3).
    const auto held = orders(100);
    FH_EXPECT(held.action == core::Action::None && held.why == ai::Why::WaitForRunner);
    // Closer and faster: his lead is beyond the line — the ball in behind goes to him.
    g.w.placePlayer(2, at(16, 12), kFacePlus);
    g.w.placeVelocity(2, at(7, 0));
    const auto go = orders(100);
    FH_EXPECT(go.action != core::Action::None && go.other == 2 && go.rung >= 1 && go.rung <= 2);
    // A runner who stops ends the hold: the passer plays on.
    g.w.placeVelocity(2, at(0, 0));
    const auto on = orders(100);
    FH_EXPECT(on.action != core::Action::None && on.why != ai::Why::WaitForRunner);
}

// G4.66 what a player can see: the men in front of him (his field of view)
// and within feel_m are as they are; the men behind him are as of his last
// look over the shoulder — how often he looks is his scanning rating.
FH_TEST(a_player_sees_in_front_and_only_remembers_behind) {
    core::World w = pitch();
    ai::Brain brain{ai::TeamSetup::splitHalves(4), Fixed64::fromFraction(105, 2), Fixed64::fromInt(34)};
    w.placePlayer(0, at(0, 0), kFacePlus);      // our man, facing +x
    w.placePlayer(1, at(10, 0), kFacePlus);     // in front
    w.placePlayer(2, at(-10, 0), kFaceMinus);   // straight behind
    w.placePlayer(3, at(-1, 1), kFaceMinus);    // at his back, close enough to feel
    FH_EXPECT(brain.inView(0, w, 1));
    FH_EXPECT(!brain.inView(0, w, 2));
    FH_EXPECT(brain.inView(0, w, 3));
    w.placePlayer(2, at(-1, 10), kFaceMinus);   // ~96° off his face: the edge of the eye
    FH_EXPECT(brain.inView(0, w, 2));
    w.placePlayer(2, at(-10, 0), kFaceMinus);

    core::BallState b;
    b.pos = at(20, 0);
    b.owner = 1;                                 // our ball
    w.placeBall(b);
    // Perfect play sees everything.
    FH_EXPECT_EQ(brain.ordersFor(0, w).look_ds, 255);
    // A real band: a player who never looks knows nothing fresh behind him.
    const core::LevelParams pro = core::levelParams("pro");
    brain.setLevels(pro, pro, 7);
    core::ConceptRatings r{};
    brain.setRatings(0, r);
    const ai::Orders blind = brain.ordersFor(0, w);
    FH_EXPECT_EQ(blind.look_ds, 254);            // never: as old as the HUD shows
    FH_EXPECT_EQ(blind.unseen, 1);               // the man straight behind him
    FH_EXPECT_EQ(brain.lookAge(0, w), 1800);
    // A 1 barely looks: every 20 s; a 50 about every 2.4 s.
    ai::ScanBeforeReceive scan;
    scan.configure(core::ModelParams{});
    FH_EXPECT_EQ(scan.everyTicks(1), 600);
    FH_EXPECT(scan.everyTicks(50) > 60 && scan.everyTicks(50) < 80);
    FH_EXPECT_EQ(scan.everyTicks(100), 37);
    // Scanning at 100: a look at least every 1.25 s (37 ticks), on his own rhythm.
    r[33] = 100;
    brain.setRatings(0, r);
    for (int k = 0; k < 40; ++k) {
        FH_EXPECT(brain.lookAge(0, w) < 38);
        w.tick();
    }
}

// G4.66: on the ball he doesn't play a mate he can't see — unless he
// looked just now. Same picture, the only open man straight behind him.
FH_TEST(a_carrier_never_passes_blind_to_a_mate_behind_him) {
    LadderRig g;
    g.carry(0, 0);                                  // facing +x
    g.w.placePlayer(1, at(-14, 0), kFacePlus);      // the only free mate, behind him
    g.w.placePlayer(2, at(30, 30), kFacePlus);
    g.w.placePlayer(3, at(30, -30), kFacePlus);
    g.w.placePlayer(4, at(2, 1), kFaceMinus);       // pressed: a man on him
    g.w.placePlayer(5, at(40, 0), kFaceMinus);
    g.w.placePlayer(6, at(40, 20), kFaceMinus);
    g.w.placePlayer(7, at(40, -20), kFaceMinus);
    core::ConceptRatings r{};
    r[24] = 100;                                   // he reads the pass
    g.brain.setRatings(0, r);
    auto passesBack = [&] {
        const ai::Orders o = g.brain.ordersFor(0, g.w);
        return o.action != core::Action::None && o.other == 1;
    };
    // Perfect play sees him and plays it back.
    const bool sees = passesBack();
    // A pro who never looks (scan rating 0): his picture is 3 s old — no pass.
    const core::LevelParams pro = core::levelParams("pro");
    g.brain.setLevels(pro, pro, 7);
    g.brain.setRatings(0, r);
    FH_EXPECT(g.brain.lookAge(0, g.w) > 15);
    FH_EXPECT(!passesBack());
    FH_EXPECT(sees);
}

// G4.67 near-tight-far-zone (122): the gap to his man grows with the
// ball's distance from him — 1 m next to the ball, 6 m from 35 m away.
FH_TEST(marking_is_tight_near_the_ball_and_off_toward_the_middle_far_from_it) {
    ai::NearTightFarZone n;
    n.configure(core::ModelParams{});
    FH_EXPECT_EQ(n.bit(), 122);
    FH_EXPECT(n.farShare(Fixed64::fromInt(5)).raw == 0);
    FH_EXPECT(n.gap(n.farShare(Fixed64::fromInt(5))) == Fixed64::one());
    FH_EXPECT(n.farShare(Fixed64::fromInt(50)) == Fixed64::one());
    FH_EXPECT(n.gap(Fixed64::one()) == Fixed64::fromInt(6));
    const Fixed64 mid = n.gap(n.farShare(Fixed64::fromFraction(45, 2)));   // halfway: 3.5 m
    FH_EXPECT(mid > Fixed64::fromFraction(34, 10) && mid < Fixed64::fromFraction(36, 10));
}

FH_TEST_MAIN()
