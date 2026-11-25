// game/src/server/Kits.cpp — see Kits.hpp.

#include "server/Kits.hpp"

#include <cmath>

namespace fh::game::server {

int colourGap(std::int32_t a, std::int32_t b) {
    const int ra = (a >> 16) & 0xff, ga = (a >> 8) & 0xff, ba = a & 0xff;
    const int rb = (b >> 16) & 0xff, gb = (b >> 8) & 0xff, bb = b & 0xff;
    const int rm = (ra + rb) / 2, dr = ra - rb, dg = ga - gb, db = ba - bb;
    const long d2 = (((512L + rm) * dr * dr) >> 8) + 4L * dg * dg + (((767L - rm) * db * db) >> 8);
    return static_cast<int>(std::lround(std::sqrt(static_cast<double>(d2))));
}

namespace {
struct Hsl { double h, s, l; };   // h 0-360, s and l 0-1
Hsl hslOf(std::int32_t rgb) {
    const double r = ((rgb >> 16) & 0xff) / 255.0, g = ((rgb >> 8) & 0xff) / 255.0, b = (rgb & 0xff) / 255.0;
    const double mx = std::fmax(r, std::fmax(g, b)), mn = std::fmin(r, std::fmin(g, b)), d = mx - mn;
    Hsl o{0, 0, (mx + mn) / 2};
    if (d <= 0) return o;
    o.s = d / (1 - std::fabs(2 * o.l - 1));
    o.h = mx == r ? 60 * std::fmod((g - b) / d + 6, 6) : mx == g ? 60 * ((b - r) / d + 2) : 60 * ((r - g) / d + 4);
    return o;
}
constexpr double kDark = 0.25;   // [FH] HSL lightness under this: "very dark" — navy, black, deep claret
}  // namespace

Family familyOf(std::int32_t rgb) {
    const Hsl c = hslOf(rgb);
    if (c.l >= 0.9 || (c.l >= 0.8 && c.s < 0.3)) return Family::White;
    if (c.l <= 0.15 || (c.l < kDark && c.s < 0.35)) return Family::Black;
    if (c.s < 0.2) return Family::Grey;
    if (c.h < 15 || c.h >= 300) return Family::Red;    // claret, maroon and pink are red to the eye here
    if (c.h < 40) return Family::Orange;
    if (c.h < 70) return Family::Yellow;
    if (c.h < 170) return Family::Green;
    if (c.h < 260) return (c.h < 215 && c.l >= 0.5) || c.l >= 0.7 ? Family::Sky : Family::Blue;
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
    int bh = 0, ba = 0, best = -1;
    for (int h = 0; h < static_cast<int>(H.size()); ++h)
        for (int a = 0; a < static_cast<int>(A.size()); ++a) {
            const int g = colourGap(H[h].shirt, A[a].shirt);
            if (g > best) { best = g; bh = h; ba = a; }
        }
    return wear(bh, ba);
}

}  // namespace fh::game::server
