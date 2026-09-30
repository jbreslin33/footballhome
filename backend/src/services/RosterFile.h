#pragma once
#include <string>

// What a league-site roster fetcher hands back (TeamPassRoster,
// GoogleSheetRoster): the sheet's bytes exactly as the site sent them, or
// why not, in words a coach can act on.
struct RosterFile {
    bool ok = false;
    std::string pdf;
    std::string error;
};
