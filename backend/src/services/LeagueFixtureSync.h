#pragma once
#include <string>
#include "../third_party/json.hpp"

// LeagueFixtureSync — a league season's fixture list, pulled from the
// league's public SportsEngine feed and kept in league_fixtures (mig 488).
//
// Owner 2026-09-28: "we need it in db and refreshed on every access to casa
// section of fh".  So OpponentsController calls refreshLeague("CASA") on
// every GET of the hub and the schedule page, then reads the table.  A pull
// that fails leaves the previous rows in place and records why on the
// source row (last_fetch_ok / last_fetch_note) so the page can say "showing
// the list from <when>".
//
// Where to pull from is data: league_fixture_sources holds the SportsEngine
// season program id per league label + season.  Nothing here knows CASA.
class LeagueFixtureSync {
public:
    struct Result { bool ok = false; int games = 0; int pages = 0; std::string note; };

    // Refresh every active source of one league label.  Never throws; the
    // returned array has one {source_id, ok, games, note} per source.
    static nlohmann::json refreshLeague(const std::string& leagueLabel);

    // One source.  Pulls every page, upserts, marks rows the full pull no
    // longer lists (removed_at), and stamps the source row.
    static Result refreshSource(long long sourceId, const std::string& programId);
};
