// game/src/server/Kits.hpp — which kit each side wears: the two are always told apart.
//
// Owner 11/25: "the colors of the teams in sim always need to be distinct no red and diff red etc".
// As in a real match: the home side wears its home kit and the AWAY side changes. It wears the
// first of its kits (home, then its change kits in order, game_demo_team_change_kits mig 1923)
// whose SHIRT is clearly apart from the home shirt. Only when none of the away side's kits is
// apart does the home side change too, the first pair that works. When no pair works the most
// apart pair is worn.
//
// "Clearly apart" = the shirts are in different colour FAMILIES (owner: "no red and diff red"):
// red (claret, maroon, pink with it), orange, yellow, green, sky, blue (royal, navy), purple, white,
// grey, black — read from the shirt's hue, saturation and lightness (HSL). Two very dark shirts
// (navy against black) always clash: from above they are the same. [FH] the band edges are picked
// by eye for a top-down pitch, not fitted. Shirts only: from above, a man is his shirt. A colour
// of -1 (the client's default) is never called a clash. When no pair is apart, the pair furthest
// apart by the redmean distance [Riemersma, "Colour metric", compuphase.com] is worn.
//
// Cosmetic, never the sim: no Fixed64 here, and nothing the World reads.

#pragma once

#include "persistence/FormationStore.hpp"

#include <vector>

namespace fh::game::server {

enum class Family { Red, Orange, Yellow, Green, Sky, Blue, Purple, White, Grey, Black };
Family familyOf(std::int32_t rgb);
// Redmean distance between two 0xRRGGBB colours (0 = the same; max ≈ 765): the fallback's tie-break.
int colourGap(std::int32_t a, std::int32_t b);
// The two shirts can be told apart (either unknown = yes).
bool shirtsApart(const persistence::Kit& a, const persistence::Kit& b);

struct WornKits {
    persistence::Kit home, away;
    int home_index = 0, away_index = 0;   // into each side's kits (0 = its home kit)
};
WornKits chooseKits(const std::vector<persistence::Kit>& home, const std::vector<persistence::Kit>& away);

}  // namespace fh::game::server
