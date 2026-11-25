// game/tests/test_kits.cpp — server/Kits: the two sides are always told apart (mig 1923).

#include "test_harness.hpp"
#include "server/Kits.hpp"

using fh::game::persistence::Kit;
using namespace fh::game::server;

namespace {
Kit k(std::int32_t shirt) { Kit x; x.shirt = shirt; x.shorts = 0xffffff; return x; }
const std::int32_t kLiverpool = 0xc8102e, kSouthampton = 0xd71920, kVilla = 0x670e36, kArsenal = 0xef0107,
                   kWhite = 0xffffff, kRoyal = 0x4169e1, kNavy = 0x122f67, kYellow = 0xfbee23;
}  // namespace

FH_TEST(red_on_red_is_a_clash) {
    FH_EXPECT(!shirtsApart(k(kLiverpool), k(kSouthampton)));
    FH_EXPECT(!shirtsApart(k(kArsenal), k(kVilla)));       // red v claret: still "red and diff red"
    FH_EXPECT(!shirtsApart(k(kRoyal), k(kNavy)));         // blue and diff blue
    FH_EXPECT(!shirtsApart(k(kNavy), k(0x111111)));       // navy v black: both very dark
    FH_EXPECT(shirtsApart(k(0x6cabdd), k(0x034694)));     // sky v royal (Man City v Chelsea)
    FH_EXPECT(shirtsApart(k(kYellow), k(kWhite)));
    FH_EXPECT(shirtsApart(k(kLiverpool), k(kWhite)));
    FH_EXPECT(colourGap(kWhite, kWhite) == 0);
}

FH_TEST(apart_already_both_wear_home) {
    const auto w = chooseKits({k(kLiverpool), k(kWhite)}, {k(kNavy), k(kYellow)});
    FH_EXPECT(w.home_index == 0 && w.away_index == 0);
}

FH_TEST(the_away_side_changes) {
    const auto w = chooseKits({k(kLiverpool), k(kWhite)}, {k(kSouthampton), k(kVilla), k(kYellow)});
    FH_EXPECT(w.home_index == 0);
    FH_EXPECT(w.away_index == 2);           // claret is skipped too: the first kit that is APART
    FH_EXPECT(w.away.shirt == kYellow);
}

FH_TEST(home_changes_only_when_the_away_side_cannot) {
    const auto w = chooseKits({k(kLiverpool), k(kWhite)}, {k(kSouthampton)});
    FH_EXPECT(w.home_index == 1 && w.away_index == 0);
}

FH_TEST(no_pair_works_the_most_apart_is_worn) {
    const auto w = chooseKits({k(kLiverpool), k(kVilla)}, {k(kSouthampton)});
    FH_EXPECT(w.home_index == 1);          // claret is further from Southampton's red than Liverpool's
}

FH_TEST(unknown_colours_never_clash) {
    const auto w = chooseKits({}, {k(kLiverpool)});
    FH_EXPECT(w.away_index == 0 && w.home.shirt == -1);
}

FH_TEST_MAIN()
