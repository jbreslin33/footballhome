#pragma once
#include <string>
#include <vector>

// What a league-site roster fetcher hands back (TeamPassRoster,
// GoogleSheetRoster): the sheet's bytes exactly as the site sent them, or
// why not, in words a coach can act on.  `names` (mig 620) carries the
// player names parsed from the same pull — the league's own spelling —
// for the #teams board's 🌐 Roster mirror; empty when parsing found none
// (the PDF is still good).
struct RosterFile {
    bool ok = false;
    std::string pdf;
    std::string error;
    std::vector<std::string> names;
};
