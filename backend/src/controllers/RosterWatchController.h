#pragma once
#include <string>
#include "../core/Controller.h"

// RosterWatchController — /api/roster-watch, the #dual-rostering page
// (mig 1774; owner 2026-11-23: "a page to report dual or even tri
// rostering").  Club admins only.
//
//   GET /api/roster-watch
//     → { sweep: {running, done, total},
//         totals: {players, teams},
//         sources: [{label, teams, read, players, at, ok, note}],
//         matches: [{key, teams, clubs, dobs, dob_same,
//                    rows: [{name, league, team, division, club, dob, added,
//                            group, sub, go, so}]}] }   group/sub = the league and
//                            conference pills (mig 1778), go/so their order
//     Every name (fh_name_key) rostered on two or more teams in
//     roster_watch_entries, most clubs first.  Starts a sweep
//     (RosterWatchSync) when the rosters are stale.
//
//   POST /api/roster-watch/refresh   read every roster again, now
//     → { started, sweep }
//
//   POST /api/roster-watch/paste {source_id, team, division?, names: [name | {name, apps}]}   (migs 1777, 1780)
//     → { saved }   one team's roster picked out of a pasted league page
//     (UPSL: the server cannot read upsl.com); replaces that team.
//   POST /api/roster-watch/paste/remove {team_id}
//   GET adds  paste: {sources: [{id, label}], teams: [{id, league, team, n, when}]}
class RosterWatchController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGet(const Request& request);
    Response handleRefresh(const Request& request);
    Response handlePaste(const Request& request);         // mig 1777: a roster by paste (UPSL)
    Response handlePasteRemove(const Request& request);
};
