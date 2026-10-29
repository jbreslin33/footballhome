#pragma once
#include <string>
#include "../core/Controller.h"

// PyramidController — #apsl (mig 819, flow chart mig 823): the APSL, its
// conferences and the Tier 2 leagues that feed them, as tables joined by
// links (promotion up, relegation down).  Owner 2026-10-29: "i want the
// conference shown in a container with relegation and playoff spots in red and green. then under it are the
// feeder leagues connected by arrows like a flow chart."
//
//   GET /api/pyramid[?root=apsl][&refresh=1]
//     { root_id, totals: {leagues, clubs, teams, states},
//       competitions: [{ id, parent_id, kind, tier, name, short_name, region,
//                        website_url, standings_url, states: [..],
//                        source: {system, ok, read_at, ok_at, note} | null }],
//       divisions: [{ id, competition_id, name, counts,
//                     zones: [{kind, from, to, label, color, moves: up|down|null,
//                              origin: default|override|source,
//                     overrides: {up, down} — null = defaults, [] = none,
//                                [{kind, from, to}] = this table's own,
//                              targets: "where its teams go" | null}],
//                     teams: [{pos, name, club, ours, gp, w, d, l, gf, ga, gd, pts}] }],
//       links: [{ lower: division id, upper_division: id | null,
//                 upper_competition: id | null, promotes, relegates }],
//       zone_kinds: [{code, label, moves, color}] }
//
// Mig 827: zone meaning and colour are pyramid_zone_kinds rows; where a
// zone's teams go is the pyramid_zone_moves view over pyramid_links.
//
//   POST /api/pyramid/zone-rules {division_id, direction, mode: default|none|custom,
//                                 zones: [{kind, from, to}]}   — club admins
//     replaces that table's override rows for that direction (mig 828).
//
// Every GET first re-reads sources older than their max age (PyramidSync);
// refresh=1 re-reads them all.  `counts` false = a table shown but left out
// of the totals (cups under the APSL root; a feeder's copy of APSL teams).
class PyramidController : public Controller {
public:
    PyramidController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    Response handleGet(const Request& request);
    Response handleZoneRules(const Request& request);
};
