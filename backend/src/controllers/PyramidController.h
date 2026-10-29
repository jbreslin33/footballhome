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
//                        website_url, standings_url, logo_url, lat, lon, states: [..],
//                        source: {system, ok, read_at, ok_at, note} | null }],
//       divisions: [{ id, competition_id, name, counts,
//                     zones: [{kind, from, to, label, color, moves: up|down|null,
//                              origin: default|override|source,
//                     overrides: {up, down, stay} — null = defaults, [] = none,
//                                [{kind, from, to, until}] = this table's own
//                                (until = its expiry, mig 836),
//                              targets: "where its teams go" | null}],
//                     teams: [{id, pos, name, club, club_id, gp, w, d, l, gf, ga, gd, pts}] }],
//       links: [{ lower: division id, upper_division: id | null,
//                 upper_competition: id | null, promotes, relegates }],
//       zone_kinds: [{code, label, moves, color}],
//       clubs: [{id, name, divisions: [ids]}],
//       places: [{team_id, club_id, division_id, name, venue_name, venue, lat, lon}],  (mig 855: a team's ground)
//       seasons: [{league_id, name, current, games, clubs, teams,
//                  by_competition: [{competition_id, teams, kind, active, name}]}] }  (mig 847)
//
// Mig 827: zone meaning and colour are pyramid_zone_kinds rows; where a
// zone's teams go is the pyramid_zone_moves view over pyramid_links.
//
//   GET /api/pyramid/territory?conf=<id> → { population, counties, geojson,
//     travel: {max_minutes, from, to, avg_minutes, median_minutes, min_minutes, min_from,
//              min_to, pairs} | null,
//     city: {name, geometry, collar_fips, rings: {city, collar, further}} | null }  (mig 860)
//   GET /api/pyramid/club?id= → the club card: {id, name, founded, logo_url,
//     teams: [{league, division, pos, record, zone, venue, staff, roster}]}  (mig 856)
//   POST /api/pyramid/club {club_id, founded} — club admins
//   GET /api/pyramid/roots → { roots: [{slug, name, short_name, logo_url}] }
//     the picker tile's crest; reads only.
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
    Response handleRoots(const Request& request);
    Response handleTerritory(const Request& request);
    Response handleClub(const Request& request);
    Response handleClubSave(const Request& request);
};
