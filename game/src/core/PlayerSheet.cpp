// core/PlayerSheet.cpp — see PlayerSheet.hpp (G4.83, mig 793).
#include "core/PlayerSheet.hpp"

#include "math/FixedMath.hpp"

#include <algorithm>

namespace fh::game::core {

using math::Fixed64;

namespace {

// game_attributes codes in attributeAt (wire) order.
constexpr const char* kAttributeCodes[kAttributeCount] = {
    "pace", "passing", "shooting", "first_touch", "tackling", "anticipation", "decisions",
    "goalkeeping", "acceleration", "deceleration", "agility", "dribbling", "communication",
    "concentration"};
constexpr int kGoalkeeping = 7;

// Roll channels (detNoise): one per question asked of the dice.
enum : std::uint8_t {
    kChStart = 1, kChYouth = 2, kChHighSchool = 3, kChCollege = 4, kChAdult = 5,
    kChYearsOff = 6, kChAgeBand = 7, kChAgeWithin = 8, kChAttribute = 20,
};

int roundToInt(Fixed64 v) {
    const Fixed64 h = v.raw >= 0 ? Fixed64::halfConst() : -Fixed64::halfConst();
    return static_cast<int>((v + h).raw >> Fixed64::FRAC_BITS);
}
int clamp100(int v) { return v < 0 ? 0 : (v > 100 ? 100 : v); }

}  // namespace

const char* tierName(LineupTier t) {
    switch (t) {
        case LineupTier::Starter: return "starter";
        case LineupTier::Bench: return "bench";
        case LineupTier::Deep: return "deep";
    }
    return "bench";
}

int positionGroupOf(const std::string& a) {
    if (a == "GK") return 0;
    if (a == "CB" || a == "SW" || a == "LCB" || a == "RCB") return 1;
    if (a == "RB" || a == "LB" || a == "WB" || a == "LWB" || a == "RWB") return 2;
    if (a == "CDM" || a == "DM" || a == "LDM" || a == "RDM") return 3;
    if (a == "CM" || a == "LCM" || a == "RCM") return 4;
    if (a == "CAM" || a == "AM") return 5;
    if (a == "RM" || a == "LM" || a == "RW" || a == "LW" || a == "W") return 6;
    if (a == "ST" || a == "FW" || a == "CF" || a == "LS" || a == "RS") return 7;
    return -1;
}

bool learnedAttribute(int i) {
    // pace, acceleration, deceleration, agility: the body.
    return !(i == 0 || i == 8 || i == 9 || i == 10);
}

SheetRules::SheetRules() {
    lean_on.fill(-1);
    lean_on[8] = 0;  lean[8] = Fixed64::fromFraction(6, 10);    // acceleration on pace
    lean_on[9] = 8;  lean[9] = Fixed64::fromFraction(5, 10);    // deceleration on acceleration
    lean_on[10] = 8; lean[10] = Fixed64::fromFraction(4, 10);   // agility on acceleration
    lean_on[11] = 3; lean[11] = Fixed64::fromFraction(5, 10);   // dribbling on first touch
}

SheetRules SheetRules::fromParams(const ModelParams& p) {
    SheetRules r;
    r.spread = p.integer("sheet.range.spread_pts", r.spread);
    r.physical_base = p.integer("sheet.range.physical_base", r.physical_base);
    r.tier_pts = {p.integer("sheet.tier.starter_pts", r.tier_pts[0]),
                  p.integer("sheet.tier.bench_pts", r.tier_pts[1]),
                  p.integer("sheet.tier.deep_pts", r.tier_pts[2])};
    r.per_year = p.fixed("sheet.experience.per_year_pts", 300);
    r.experience_cap = p.integer("sheet.experience.cap_pts", r.experience_cap);
    r.halving_years = std::max(1, p.integer("sheet.mastery.halving_years", r.halving_years));
    r.start_base = p.integer("sheet.start_age.base", r.start_base);
    r.start_die = std::max(1, p.integer("sheet.start_age.die", r.start_die));
    const char* ranks[] = {"", "u10", "u14", "amateur", "semipro", "pro", "world"};
    for (int k = 1; k < 7; ++k)
        r.taught_age[k] = p.integer(std::string("sheet.taught_age.") + ranks[k], r.taught_age[k]);
    r.pace_from = p.integer("sheet.age.pace_from", r.pace_from);
    r.pace_per_year = p.fixed("sheet.age.pace_per_year_pts", 1500);
    r.non_keeper_gk = p.integer("sheet.goalkeeping.non_keeper", r.non_keeper_gk);
    for (int i = 0; i < kAttributeCount; ++i)
        if (r.lean_on[i] >= 0)
            r.lean[i] = p.fixed(std::string("sheet.lean.") + kAttributeCodes[i],
                                (r.lean[i] * Fixed64::fromInt(1000)).raw >> Fixed64::FRAC_BITS);
    return r;
}

const SheetTableRow* SheetRules::row(const std::string& stage, int d100) const {
    const auto it = tables.find(stage);
    if (it == tables.end()) return nullptr;
    for (const auto& r : it->second)
        if (d100 >= r.lo && d100 <= r.hi) return &r;
    return nullptr;
}

PlayerSheet PlayerSheet::restore(int age, int start_age, int years_off, int quality) {
    PlayerSheet s;
    s.age_ = age;
    s.start_age_ = start_age;
    s.years_off_ = years_off < 0 ? 0 : years_off;
    s.quality_ = clamp100(quality);
    return s;
}

int PlayerSheet::playingYears() const {
    const int y = age_ - start_age_ - years_off_;
    return y < 0 ? 0 : y;
}

Fixed64 PlayerSheet::experienceYears() const {
    Fixed64 y{};
    for (const auto& h : history_) y += h.weight * Fixed64::fromInt(h.to_age - h.from_age);
    y -= Fixed64::fromInt(years_off_);
    return y.raw < 0 ? Fixed64{} : y;
}

PlayerAttributes PlayerSheet::attributes() const {
    PlayerAttributes a;
    for (int i = 0; i < kAttributeCount; ++i) *attributeAt(a, i) = static_cast<std::int16_t>(attrs_[i]);
    return a;
}

int PlayerSheet::conceptAbility(int taught_rank, const SheetRules& r) const {
    if (taught_rank <= 0 || taught_rank >= static_cast<int>(r.taught_age.size())) return quality_;
    int years = age_ - std::max(start_age_, r.taught_age[taught_rank]) - years_off_;
    if (years < 0) years = 0;
    // ½^(years / halving) = e^(−ln2 · years / halving).
    const Fixed64 ln2 = Fixed64::fromFraction(693147, 1000000);
    const Fixed64 keep = math::fx_exp_neg(ln2 * Fixed64::fromInt(years) / Fixed64::fromInt(r.halving_years));
    const Fixed64 miss = Fixed64::fromInt(100 - quality_) * keep;
    return clamp100(100 - roundToInt(miss));
}

int PlayerGenerator::d100(const SheetFacts& f, std::uint8_t channel) const {
    const Fixed64 n = detNoise(f.seed, 0, 0, channel);   // [-1, 1)
    const int v = 1 + static_cast<int>(((n + Fixed64::one()) * Fixed64::fromInt(50)).raw >> Fixed64::FRAC_BITS);
    return v < 1 ? 1 : (v > 100 ? 100 : v);
}

void PlayerGenerator::rollLife(const SheetFacts& f, PlayerSheet& s) const {
    const SheetRules& R = rules_;
    // Age: real when the club has a birth date, else the age table.
    if (f.age > 0) {
        s.age_ = f.age;
    } else {
        const int band = d100(f, kChAgeBand), within = d100(f, kChAgeWithin);
        const SheetTableRow* r = R.row("age", band);
        const int lo = r ? r->years : 22, hi = r ? r->years_hi : 28;
        s.age_ = lo + (within - 1) * (hi - lo + 1) / 100;
        s.age_rolled_ = true;
        s.rolls_.emplace_back("age band", band);
        s.rolls_.emplace_back("age within band", within);
    }
    const int start = d100(f, kChStart);
    s.start_age_ = R.start_base + 1 + (start - 1) * R.start_die / 100;
    if (s.start_age_ > s.age_) s.start_age_ = s.age_;
    s.rolls_.emplace_back("start age", start);
    // The stages, each capped by when he started and how old he is.
    struct Stage { const char* name; int from, to; std::uint8_t ch; };
    const Stage stages[] = {{"youth", 0, 14, kChYouth}, {"high_school", 14, 18, kChHighSchool},
                            {"college", 18, 22, kChCollege}, {"adult", 22, 200, kChAdult}};
    for (const Stage& st : stages) {
        const int from = std::max(st.from, s.start_age_), to = std::min(st.to, s.age_);
        if (to <= from) continue;
        const int roll = d100(f, st.ch);
        const SheetTableRow* r = R.row(st.name, roll);
        HistoryStage h;
        h.stage = st.name;
        h.outcome = r ? r->outcome : "";
        h.from_age = from;
        h.to_age = to;
        h.weight = r ? r->weight : Fixed64::one();
        h.roll = roll;
        s.history_.push_back(h);
        s.rolls_.emplace_back(st.name, roll);
    }
    const int off = d100(f, kChYearsOff);
    const SheetTableRow* r = R.row("years_off", off);
    s.years_off_ = std::min(r ? r->years : 0, std::max(0, s.age_ - s.start_age_ - 1));
    s.rolls_.emplace_back("years off", off);
}

void PlayerGenerator::rollAttributes(const SheetFacts& f, Fixed64 team_mean_years, PlayerSheet& s) const {
    const SheetRules& R = rules_;
    const int tier = R.tier_pts[static_cast<int>(f.tier)];
    s.tier_ = f.tier;
    s.quality_ = clamp100(f.team_quality + tier);
    Fixed64 exp = (s.experienceYears() - team_mean_years) * R.per_year;
    const Fixed64 cap = Fixed64::fromInt(R.experience_cap);
    if (exp > cap) exp = cap;
    if (exp < -cap) exp = -cap;
    int total = 0;
    for (int g = 0; g < kPositionGroups; ++g) total += f.positions[g];
    const bool keeper = total > 0 && f.positions[0] * 2 >= total;
    std::array<Fixed64, kAttributeCount> eff{};   // the roll each attribute is placed by
    for (int i = 0; i < kAttributeCount; ++i) {
        const int own = d100(f, static_cast<std::uint8_t>(kChAttribute + i));
        s.rolls_.emplace_back(kAttributeCodes[i], own);
        eff[i] = Fixed64::fromInt(own);
        if (R.lean_on[i] >= 0 && R.lean_on[i] < i)
            eff[i] = R.lean[i] * eff[R.lean_on[i]] + (Fixed64::one() - R.lean[i]) * eff[i];
        const bool learned = learnedAttribute(i);
        const int centre = learned ? f.team_quality : R.physical_base;
        // His rank at his level: 1 = the floor (centre − spread), 100 = the ceiling.
        Fixed64 v = Fixed64::fromInt(centre - R.spread) +
                    Fixed64::fromInt(2 * R.spread) * eff[i] / Fixed64::fromInt(100);
        v += Fixed64::fromInt(tier);
        if (learned) v += exp;
        if (total > 0)
            for (int g = 0; g < kPositionGroups; ++g)
                if (f.positions[g])
                    v += Fixed64::fromInt(R.profile[g][i] * f.positions[g]) / Fixed64::fromInt(total);
        if ((i == 0 || i == 8) && s.age_ > R.pace_from)
            v -= R.pace_per_year * Fixed64::fromInt(s.age_ - R.pace_from);
        int out = roundToInt(v);
        if (i == kGoalkeeping && !keeper) out = R.non_keeper_gk;
        if (f.edited[i] >= 0) out = f.edited[i];   // a hand edit wins
        s.attrs_[i] = clamp100(out);
    }
}

PlayerSheet PlayerGenerator::generate(const SheetFacts& f, Fixed64 team_mean_years) const {
    PlayerSheet s;
    rollLife(f, s);
    rollAttributes(f, team_mean_years, s);
    return s;
}

std::vector<PlayerSheet> PlayerGenerator::generateTeam(const std::vector<SheetFacts>& team) const {
    std::vector<PlayerSheet> out(team.size());
    Fixed64 sum{};
    for (std::size_t k = 0; k < team.size(); ++k) {
        rollLife(team[k], out[k]);
        sum += out[k].experienceYears();
    }
    const Fixed64 mean = team.empty() ? Fixed64{} : sum / Fixed64::fromInt(static_cast<int>(team.size()));
    for (std::size_t k = 0; k < team.size(); ++k) rollAttributes(team[k], mean, out[k]);
    return out;
}

}  // namespace fh::game::core
