#pragma once
#include <string>
#include <vector>

class Database;

// ────────────────────────────────────────────────────────────────────────────
// YouthAgeGroups — read-side model + helpers for the `youth_age_groups`
// table, the single source of truth for youth bucket windows (Aug 1 → Jul 31
// US-Soccer seasonal year), club-splits, roster caps, sort order, and chip
// colours.
//
// loadFor(seasonEndYear) returns the configured buckets ordered by
// sort_order; matchBucket() picks the first bucket whose date window
// contains the birth date AND whose clubFilter accepts the player's club.
//
// defaultSeasonEndYear() implements the same June-1 cutover the Node helper
// uses: Jan-May → current year, Jun-Dec → next year.
// ────────────────────────────────────────────────────────────────────────────
class YouthAgeGroups {
public:
    struct Bucket {
        std::string label;
        std::string clubFilter;   // "" (=null, any club) | "boys" | "girls"
        std::string minBirthIso;  // "YYYY-MM-DD"
        std::string maxBirthIso;  // "YYYY-MM-DD"
        int         sortOrder    = 0;
        int         maxRoster    = 0;     // 0 + hasMaxRoster=false → unlimited
        bool        hasMaxRoster = false;
        std::string color;
    };

    YouthAgeGroups();

    // SELECT … WHERE season_end_year=$1 ORDER BY sort_order
    std::vector<Bucket> loadFor(int seasonEndYear);

    // Pick the first bucket whose [minBirthIso, maxBirthIso] contains
    // birthDateIso AND whose clubFilter matches (or is empty).  Returns
    // nullptr when no bucket applies.  birthDateIso must be "YYYY-MM-DD".
    static const Bucket* matchBucket(const std::string& birthDateIso,
                                     const std::string& club,
                                     const std::vector<Bucket>& buckets);

    // June 1 cutover: Jan-May → current year, Jun-Dec → next year.
    // Uses local time (matches Node's `new Date()`).
    static int defaultSeasonEndYear();

    // US-Soccer school-year age group from a "YYYY-MM-DD" DOB. Aug 1
    // cutover: month >= 8 → cohort = yy+1, else cohort = yy. Result is
    // "U" + (seasonEndYear - cohort) — e.g. "U10" for youth, "U23"/"U30"
    // for adults (the formula is birth-year-generic, so mens/womens
    // rosters can surface it too, ahead of any actual U19/U23/Over-30
    // bracketing). Returns "" when birthDateIso can't be parsed.
    static std::string ageGroupFromDob(const std::string& birthDateIso, int seasonEndYear);

private:
    Database* db_;
};
