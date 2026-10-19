#pragma once
#include <string>

// FilmSync — mirrors the league's shared game-film sheet (mig 599) into
// film_links.  The sheet is a Google Sheet the league fills by hand: a
// MATCHDAY window row, then one row per uploaded film (home team + link).
// Players never touch the sheet; Football Home reads its CSV export.
//
// refreshIfStale(maxAgeMinutes) re-fetches every active film_sources row
// whose fetched_at is older — called from FilmController on page load, the
// same on-open pattern as the CASA fixture refresh.
class FilmSync {
public:
    static void refreshIfStale(int maxAgeMinutes = 60);
    static void run(int sourceId, const std::string& csvUrl);
};
