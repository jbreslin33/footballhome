#pragma once
#include "../third_party/json.hpp"

// RosterWatchSync — reads every league roster we can for #dual-rostering
// (mig 1774; owner 2026-11-23: "scrape all apsl, casa … a page to report
// dual or even tri rostering").
//
//   Google Sheets workbooks (roster_sheet_sources — CASA): every tab, or the
//     one named tab, as CSV → fh_roster_sheet_load().  No sign-in, no proxy.
//   TeamPass team pages (pyramid_sources.team_page — APSL, CSL, ADASL):
//     PyramidSync::teamPeople() per team, through the scraper-VPN proxy.
//
// One sweep at a time, on a background thread, one request after another
// with roster_watch_policy.pause_ms between them; the page polls state().
// A failed read keeps the roster that was there.
class RosterWatchSync {
public:
    // Start a sweep unless one is running.  force = every roster; otherwise
    // only those older than roster_watch_policy.stale_hours.
    static bool start(bool force);
    // start(false) when the last sweep is stale_hours old (or never ran).
    static void startIfStale();
    // {running, done, total}
    static nlohmann::json state();
};
