#pragma once
#include <string>
#include "../core/Controller.h"

// PyramidController — #apsl (mig 819): the APSL pyramid, its conferences
// and Tier 2 affiliates, each with its live tables and club/team counts.
// Owner 2026-10-29: "we want to show how big the apsl and feeder system
// is. show keep club/team totals too."
//
//   GET /api/pyramid[?root=apsl][&refresh=1]
//     { root_id, totals: {leagues, clubs, teams, states},
//       nodes: [{ id, parent_id, kind, tier, name, short_name, region,
//                 website_url, standings_url, states: [..],
//                 source: {system, ok, read_at, ok_at, note} | null,
//                 clubs, teams,
//                 divisions: [{ id, name, counts,
//                               teams: [{pos, name, club, ours, gp, w, d, l, gf, ga, gd, pts}] }] }] }
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
};
