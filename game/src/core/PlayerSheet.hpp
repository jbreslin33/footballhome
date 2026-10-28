// core/PlayerSheet.hpp — a player's character sheet, and the generator that
// rolls it (G4.83, mig 793; game/DESIGN.md §8.81).
//
// James 10/28: "use dungeons and dragons type rolls to assign experience to
// current players and playing history and ability scores" / "why not 1d100
// lol? then mod it based on experienmce level adn level they are at now" /
// "apply to all and diff between starters, bench and deep bench should be
// significant at this level" / "we beasically have a generate player
// function right but with paramenters?" / "do we have a 'player class' in
// c++ to handle all this?" — "yes build it that way".
//
// PlayerGenerator::generate(facts) → PlayerSheet. Facts are what the club
// DB KNOWS about him (team quality from records, his lineup tier and
// positions, a real age, attributes edited by hand); everything else is a
// d100 on the game_sheet_tables (REAL DATA WINS — the dice only fill
// gaps). Rules are the numbers (game_model_params owner 'sheet') and the
// tables. Deterministic: his seed + a channel per roll → detNoise, so the
// same player always gets the same sheet [FH; D&D 5e character creation,
// "ability scores" + "background", re-expressed on a percentile].
//
// FH original throughout. No floats (core).
#pragma once

#include "core/Levels.hpp"
#include "core/ModelParams.hpp"
#include "math/Fixed64.hpp"

#include <array>
#include <cstdint>
#include <map>
#include <string>
#include <utility>
#include <vector>

namespace fh::game::core {

enum class LineupTier : std::uint8_t { Starter = 0, Bench = 1, Deep = 2 };
const char* tierName(LineupTier t);

// The position groups a lineup spot folds into (game_sheet_position_profile).
inline constexpr int kPositionGroups = 8;   // GK CB FB DM CM AM W ST
inline constexpr const char* kPositionGroupNames[kPositionGroups] = {"GK", "CB", "FB", "DM", "CM", "AM", "W", "ST"};
int positionGroupOf(const std::string& abbreviation);   // a lineup / slot label → group, -1 = none

// What the club DB knows about him.
struct SheetFacts {
    std::uint64_t seed = 0;            // who he is (person id, or team/shirt) — stable across runs
    int team_quality = 50;             // his level: game_team_strength (records)
    LineupTier tier = LineupTier::Bench;
    int age = -1;                      // real (persons.birth_date); -1 = roll it
    std::array<int, kPositionGroups> positions{};   // lineup appearances by group
    std::array<std::int16_t, kAttributeCount> edited;   // hand-edited ratings (-1 = none): kept
    SheetFacts() { edited.fill(-1); }
};

struct SheetTableRow {
    int lo = 1, hi = 100;
    std::string outcome;
    math::Fixed64 weight = math::Fixed64::one();
    int years = 0, years_hi = 0;
};

// The numbers and the tables (mig 793).
struct SheetRules {
    int spread = 20;                         // team quality ± spread
    int physical_base = 60;                  // the body's centre at every level (pace is not a record)
    std::array<int, 3> tier_pts{{10, 0, -10}};
    math::Fixed64 per_year = math::Fixed64::fromFraction(3, 10);
    int experience_cap = 6;
    int halving_years = 5;
    int start_base = 3, start_die = 6;
    std::array<int, 8> taught_age{{0, 8, 12, 18, 20, 22, 24, 0}};   // by level rank (ConceptRegistry::taughtFrom)
    int pace_from = 30;
    math::Fixed64 pace_per_year = math::Fixed64::fromFraction(3, 2);
    int non_keeper_gk = 25;
    // A roll that leans on another's (bodies hang together): lean_on[i] = the
    // attribute index, -1 = his own roll alone; lean[i] = the share.
    std::array<int, kAttributeCount> lean_on;
    std::array<math::Fixed64, kAttributeCount> lean{};
    std::array<std::array<int, kAttributeCount>, kPositionGroups> profile{};
    std::map<std::string, std::vector<SheetTableRow>> tables;   // stage → rows

    SheetRules();
    // The 'sheet.*' rows over the defaults above (tables/profile loaded apart).
    static SheetRules fromParams(const ModelParams& p);
    const SheetTableRow* row(const std::string& stage, int d100) const;
};

struct HistoryStage {
    std::string stage, outcome;
    int from_age = 0, to_age = 0;   // [from, to)
    math::Fixed64 weight = math::Fixed64::one();
    int roll = 0;
};

// Attribute indices (attributeAt order) that come from LEARNING — the
// experience mod applies; the body (pace, acceleration, deceleration,
// agility) is born and aged, not learned.
bool learnedAttribute(int i);

class PlayerSheet {
public:
    // What the server keeps of a stored sheet: enough to answer
    // conceptAbility (age, start age, years off) over his quality.
    static PlayerSheet restore(int age, int start_age, int years_off, int quality);

    int age() const { return age_; }
    bool ageRolled() const { return age_rolled_; }
    int startAge() const { return start_age_; }
    int yearsOff() const { return years_off_; }
    LineupTier tier() const { return tier_; }
    int quality() const { return quality_; }   // his concept dial: team quality + tier
    const std::vector<HistoryStage>& history() const { return history_; }
    int playingYears() const;                   // since he started, less years off
    math::Fixed64 experienceYears() const;      // weighted by the level of each stage
    int attribute(int i) const { return i >= 0 && i < kAttributeCount ? attrs_[i] : -1; }
    PlayerAttributes attributes() const;
    const std::vector<std::pair<std::string, int>>& rolls() const { return rolls_; }
    // How automatic a concept taught at level rank `taught_rank` is for him
    // (0-100): 100 − (100 − quality) × ½^(years on it / halving_years), years
    // on it = his playing years since the age it's taught. Mastery: a u10
    // concept after 17 years almost never lapses; last season's often does.
    int conceptAbility(int taught_rank, const SheetRules& r) const;

private:
    friend class PlayerGenerator;
    int age_ = 25, start_age_ = 6, years_off_ = 0, quality_ = 50;
    bool age_rolled_ = false;
    LineupTier tier_ = LineupTier::Bench;
    std::vector<HistoryStage> history_;
    std::array<int, kAttributeCount> attrs_{};
    std::vector<std::pair<std::string, int>> rolls_;
};

class PlayerGenerator {
public:
    explicit PlayerGenerator(SheetRules rules) : rules_(std::move(rules)) {}
    // A whole team: his experience mod is against his TEAM's mean, so a
    // team's level stays its records' (the dice spread men around it).
    std::vector<PlayerSheet> generateTeam(const std::vector<SheetFacts>& team) const;
    // One man against a given team mean of weighted experience years.
    PlayerSheet generate(const SheetFacts& f, math::Fixed64 team_mean_years) const;
    const SheetRules& rules() const { return rules_; }

private:
    void rollLife(const SheetFacts& f, PlayerSheet& s) const;
    void rollAttributes(const SheetFacts& f, math::Fixed64 team_mean_years, PlayerSheet& s) const;
    int d100(const SheetFacts& f, std::uint8_t channel) const;
    SheetRules rules_;
};

}  // namespace fh::game::core
