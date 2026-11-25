// game/src/server/Kits.cpp — see Kits.hpp.

#include "server/Kits.hpp"

#include <algorithm>
#include <cstdlib>

namespace fh::game::server {

long colourGap2(std::int32_t a, std::int32_t b) {
    const int ra = (a >> 16) & 0xff, ga = (a >> 8) & 0xff, ba = a & 0xff;
    const int rb = (b >> 16) & 0xff, gb = (b >> 8) & 0xff, bb = b & 0xff;
    const int rm = (ra + rb) / 2, dr = ra - rb, dg = ga - gb, db = ba - bb;
    return (((512L + rm) * dr * dr) >> 8) + 4L * dg * dg + (((767L - rm) * db * db) >> 8);
}

namespace {
// HSL in integers (the server lints out floating point): hue 0-359 degrees, saturation and
// lightness in thousandths.
struct Hsl { int h, s, l; };
Hsl hslOf(std::int32_t rgb) {
    const int r = (rgb >> 16) & 0xff, g = (rgb >> 8) & 0xff, b = rgb & 0xff;
    const int mx = std::max(r, std::max(g, b)), mn = std::min(r, std::min(g, b)), d = mx - mn;
    Hsl o{0, 0, (mx + mn) * 1000 / 510};
    if (d <= 0) return o;
    const int den = 255 - std::abs(mx + mn - 255);
    o.s = den > 0 ? d * 1000 / den : 0;
    const int h = mx == r ? 60 * (g - b) / d : mx == g ? 60 * (b - r) / d + 120 : 60 * (r - g) / d + 240;
    o.h = (h + 360) % 360;
    return o;
}
constexpr int kDark = 250;   // [FH] lightness (thousandths) under this: "very dark" — navy, black, deep claret
}  // namespace

Family familyOf(std::int32_t rgb) {
    const Hsl c = hslOf(rgb);
    if (c.l >= 900 || (c.l >= 800 && c.s < 300)) return Family::White;
    if (c.l <= 150 || (c.l < kDark && c.s < 350)) return Family::Black;
    if (c.s < 200) return Family::Grey;
    if (c.h < 15 || c.h >= 300) return Family::Red;    // claret, maroon and pink are red to the eye here
    if (c.h < 40) return Family::Orange;
    if (c.h < 70) return Family::Yellow;
    if (c.h < 170) return Family::Green;
    if (c.h < 260) return (c.h < 215 && c.l >= 500) || c.l >= 700 ? Family::Sky : Family::Blue;
    return Family::Purple;
}

bool shirtsApart(const persistence::Kit& a, const persistence::Kit& b) {
    if (a.shirt < 0 || b.shirt < 0) return true;
    if (hslOf(a.shirt).l < kDark && hslOf(b.shirt).l < kDark) return false;
    return familyOf(a.shirt) != familyOf(b.shirt);
}

WornKits chooseKits(const std::vector<persistence::Kit>& home, const std::vector<persistence::Kit>& away) {
    static const std::vector<persistence::Kit> kNone{persistence::Kit{}};
    const auto& H = home.empty() ? kNone : home;
    const auto& A = away.empty() ? kNone : away;
    const auto wear = [&](int h, int a) { return WornKits{H[h], A[a], h, a}; };
    // Home in its home kit, the away side's first kit apart from it; then the home side changes too.
    for (int h = 0; h < static_cast<int>(H.size()); ++h)
        for (int a = 0; a < static_cast<int>(A.size()); ++a)
            if (shirtsApart(H[h], A[a])) return wear(h, a);
    // Nothing clears the bar: the most apart pair (home kit first on a tie).
    int bh = 0, ba = 0;
    long best = -1;
    for (int h = 0; h < static_cast<int>(H.size()); ++h)
        for (int a = 0; a < static_cast<int>(A.size()); ++a) {
            const long g = colourGap2(H[h].shirt, A[a].shirt);
            if (g > best) { best = g; bh = h; ba = a; }
        }
    return wear(bh, ba);
}

}  // namespace fh::game::server
