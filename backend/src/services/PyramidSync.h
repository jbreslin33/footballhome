#pragma once
#include <string>
#include "../third_party/json.hpp"

// PyramidSync — the #apsl pyramid's live tables (mig 819).
//
// Owner 2026-10-29: "i want to build an apsl pyramid … with its feeder
// leagues and standings live."  Every league publishes its tables its own
// way; pyramid_sources says where and in what shape.  One reader per shape
// turns the page into the same division/team list, and the DB function
// fh_pyramid_load() does every write (upsert, retire, club matching) — the
// host Chrome reader (scripts/pyramid-chrome-sync.js) calls the same one.
//
//   teampass_json    TeamPass Jumbotron feed (scraper proxy): whole league
//   teampass_tables  a TeamPass /<site>/Tables/ page (scraper proxy)
//   demosphere       Demosphere standings page; data rides in it as JSON
//   sportsengine     a SportsEngine season; the table computed from its games
//   root_soccer      browser-only — skipped here, read on the host
//
// Mig 823: a TeamPass conference played in groups becomes one table per
// group, and each table carries the league office's zones (playoff /
// relegation spots) from the same feed.
//
// refreshIfStale() runs from PyramidController on page load, the same
// on-open pattern as the CASA fixtures and #film.  A failed read leaves the
// previous tables and stamps last_fetch_ok / last_fetch_note on the source.
class PyramidSync {
public:
    // Every active, server-readable source older than its max_age_minutes
    // (force = all of them).  One refresh at a time; a second caller skips.
    static void refreshIfStale(bool force = false);

    // Geocode clubs' home grounds and league region points not tried yet,
    // on a background thread (one at a time; Nominatim's 1 request/second).
    static void geocodePending();

    // One source.  Returns {source_id, ok, teams, note}.  Never throws.
    static nlohmann::json refreshSource(int sourceId);
};
