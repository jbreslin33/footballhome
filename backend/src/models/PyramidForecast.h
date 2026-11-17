#pragma once
#include <string>
#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// PyramidForecast — #apsl 📈 Forecast (migration 1448).
//
// Owner 2026-11-17: "tell me chances of lighthouse getting relegated … 8th
// place in del river a and b get auto relegated. 7th place in a and b play
// off and loser gets relegated. winner has to play a casa team to stay up"
// + "top 2 spots in a and b go to playoffs … an analysis for league and all
// teams so i can click on any of them" + "predict scores etc. like a betting
// app".
//
// build(conferenceId): one conference (pyramid_competitions kind conference)
// and its tables (pyramid_divisions; Delaware River = Group A + Group B).
//
//   The goals model   every played game in pyramid_games: each side's goals
//                     for and against, adjusted for who they played (an
//                     attack and a defence rating, 1.00 = average, shrunk
//                     toward average by prior_games), the league's goals a
//                     side a game, and a home edge from home v away goals.
//                     A game's expected goals = average × home edge ×
//                     attack × the other side's defence (Maher 1982; Dixon &
//                     Coles 1997 without the low-score correction).
//   One game          independent Poisson goals each side → win / draw /
//                     loss, the most likely scores, over 2.5, both score;
//                     fair decimal odds = 1 / chance (no margin).
//   The season        every remaining game drawn at random, `sims` times;
//                     each table sorted by the feed's own tie-breaks
//                     (pyramid_sources.tiebreak: points → head-to-head
//                     points → head-to-head goal difference → goal
//                     difference → goals; a last tie by lot); the
//                     effective zones (pyramid_zones_effective) read off;
//                     the relegation-playoff places of two groups meet at a
//                     neutral ground (draw = 50/50 on penalties), the loser
//                     relegated, the winner then facing the feeder side
//                     (pyramid_forecast_policies: feeder_stay_up_pct).
//
// Cached per conference until its games change, at most 10 minutes.
// ────────────────────────────────────────────────────────────────────────────
class PyramidForecast {
public:
    // What if (owner 11/17 "add a slider to set our strength on the page"):
    // teamId > 0 plays the season with that team's strength (attack ÷
    // defence) set to `rating`, the split between attack and defence kept;
    // never cached.
    static nlohmann::json build(int conferenceId, int teamId = 0, double rating = 0);
};
