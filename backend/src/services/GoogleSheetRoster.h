#pragma once
#include <string>
#include <vector>
#include "RosterFile.h"

// GoogleSheetRoster — pulls one team's tab of a league's public roster
// workbook on Google Sheets as a PDF.  CASA keeps its official rosters this
// way: one workbook per division, linked from the league site's Captains &
// Coaches Corner, one tab per team (owner 2026-09-30: "now lets do casa
// roster print").
//
//   1. GET /spreadsheets/d/<id>/htmlview          the tab list → the tab's gid
//   2. GET /spreadsheets/d/<id>/export?format=pdf&gid=<gid>   the PDF
//
// The workbooks are shared by link, so there is no sign-in and no proxy.
// They are uploaded .xlsx files: Google ignores the export's layout
// options for those, and the PDF carries every headshot at full size
// (~30 MB for a 30-player tab).
class GoogleSheetRoster {
public:
    using Result = RosterFile;

    // spreadsheetId "1qGcNV7z-…", tabName "Lighthouse Boys Club".
    static Result fetch(const std::string& spreadsheetId, const std::string& tabName);

    // #dual-rostering (mig 1774, RosterWatchSync): a workbook's tabs in
    // sheet order, and one tab as CSV.  On failure: empty, `error` says why.
    struct Tab { std::string name, gid; };
    static std::vector<Tab> tabs(const std::string& spreadsheetId, std::string& error);
    static std::string csv(const std::string& spreadsheetId, const std::string& gid, std::string& error);
};
