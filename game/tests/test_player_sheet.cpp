// game/tests/test_player_sheet.cpp — G4.83: PlayerGenerator rolls a
// character sheet; real data wins, the dice fill the rest.

#include "test_harness.hpp"
#include "core/PlayerSheet.hpp"

using namespace fh::game;
using fh::game::math::Fixed64;

namespace {
core::SheetRules rules() {
    core::SheetRules r;
    auto row = [](int lo, int hi, const char* o, int w_milli, int years = 0, int years_hi = 0) {
        core::SheetTableRow t;
        t.lo = lo; t.hi = hi; t.outcome = o; t.weight = Fixed64::fromFraction(w_milli, 1000);
        t.years = years; t.years_hi = years_hi;
        return t;
    };
    r.tables["youth"] = {row(1, 50, "rec", 600), row(51, 100, "travel", 1000)};
    r.tables["high_school"] = {row(1, 100, "varsity", 1000)};
    r.tables["college"] = {row(1, 100, "none", 800)};
    r.tables["adult"] = {row(1, 100, "semi-pro", 1000)};
    r.tables["years_off"] = {row(1, 90, "none", 0), row(91, 100, "a year", 0, 1)};
    r.tables["age"] = {row(1, 100, "24-27", 0, 24, 27)};
    return r;
}
core::SheetFacts man(std::uint64_t seed, core::LineupTier tier, int age = 25) {
    core::SheetFacts f;
    f.seed = seed;
    f.team_quality = 60;
    f.tier = tier;
    f.age = age;
    f.positions[4] = 5;   // a CM
    return f;
}
}  // namespace

FH_TEST(same_facts_roll_the_same_man) {
    const core::PlayerGenerator g{rules()};
    const auto a = g.generate(man(42, core::LineupTier::Bench), Fixed64::fromInt(15));
    const auto b = g.generate(man(42, core::LineupTier::Bench), Fixed64::fromInt(15));
    for (int i = 0; i < core::kAttributeCount; ++i) FH_EXPECT_EQ(a.attribute(i), b.attribute(i));
    FH_EXPECT_EQ(a.startAge(), b.startAge());
    FH_EXPECT(a.rolls() == b.rolls());
    const auto c = g.generate(man(43, core::LineupTier::Bench), Fixed64::fromInt(15));
    int same = 0;
    for (int i = 0; i < core::kAttributeCount; ++i) same += a.attribute(i) == c.attribute(i);
    FH_EXPECT(same < core::kAttributeCount);   // another man is another sheet
}

FH_TEST(a_real_age_stands_and_a_missing_one_is_rolled_from_the_table) {
    const core::PlayerGenerator g{rules()};
    const auto real = g.generate(man(7, core::LineupTier::Bench, 31), Fixed64{});
    FH_EXPECT_EQ(real.age(), 31);
    FH_EXPECT(!real.ageRolled());
    const auto rolled = g.generate(man(7, core::LineupTier::Bench, -1), Fixed64{});
    FH_EXPECT(rolled.ageRolled());
    FH_EXPECT(rolled.age() >= 24 && rolled.age() <= 27);
}

FH_TEST(a_hand_edit_wins_over_the_dice) {
    const core::PlayerGenerator g{rules()};
    auto f = man(9, core::LineupTier::Starter);
    f.edited[1] = 33;   // passing
    const auto s = g.generate(f, Fixed64{});
    FH_EXPECT_EQ(s.attribute(1), 33);
}

FH_TEST(starters_are_well_above_deep_bench_on_every_attribute) {
    // James: "diff between starters, bench and deep bench should be
    // significant at this level" — 20 points (10 / 0 / -10) between the ends.
    const core::PlayerGenerator g{rules()};
    long sum[3] = {0, 0, 0};
    const int n = 200;
    for (int k = 0; k < n; ++k)
        for (int t = 0; t < 3; ++t) {
            const auto s = g.generate(man(1000 + k, static_cast<core::LineupTier>(t)), Fixed64::fromInt(15));
            for (int i : {0, 1, 4, 6}) sum[t] += s.attribute(i);   // pace, passing, tackling, decisions
        }
    const double starter = double(sum[0]) / (n * 4), bench = double(sum[1]) / (n * 4), deep = double(sum[2]) / (n * 4);
    FH_EXPECT(starter - bench > 8 && starter - bench < 12);
    FH_EXPECT(bench - deep > 8 && bench - deep < 12);
}

FH_TEST(history_is_capped_by_his_age) {
    const core::PlayerGenerator g{rules()};
    const auto kid = g.generate(man(5, core::LineupTier::Bench, 17), Fixed64{});
    for (const auto& h : kid.history()) {
        FH_EXPECT(h.to_age <= 17);
        FH_EXPECT(h.stage != "college" && h.stage != "adult");
    }
    FH_EXPECT(kid.playingYears() <= 17 - kid.startAge());
}

FH_TEST(fundamentals_are_more_automatic_than_last_seasons_ideas) {
    // A 25-year-old started at 6, quality 60: u10 (taught 8) 17 years on it,
    // amateur (18) 7 years, semipro (20) 5 years.
    const core::SheetRules r = rules();
    const auto s = core::PlayerSheet::restore(25, 6, 0, 60);
    const int u10 = s.conceptAbility(1, r), amateur = s.conceptAbility(3, r), semipro = s.conceptAbility(4, r);
    FH_EXPECT(u10 > amateur && amateur > semipro);
    FH_EXPECT(u10 >= 95 && u10 <= 97);       // 100 - 40 x 0.5^(17/5) = 96.2
    FH_EXPECT_EQ(semipro, 80);               // one halving: 100 - 20
    const auto kid = core::PlayerSheet::restore(17, 6, 0, 60);
    FH_EXPECT(kid.conceptAbility(3, r) == 60);   // not a year on an amateur idea yet
}

FH_TEST_MAIN()
