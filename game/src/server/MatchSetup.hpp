// game/src/server/MatchSetup.hpp
//
// One place that turns the club DB into a match (G4.43): curriculum,
// formations, settings, both rosters (with their game models, qualities,
// attributes and ability rows) and the game models. The live daemon
// (main.cpp) and the match harness (tools/match_main.cpp) both call it, so
// what the harness measures is exactly what the game plays.

#pragma once

#include "persistence/FormationStore.hpp"
#include "server/GameServer.hpp"

#include <string>

namespace fh::game::server {

struct MatchNames {
    std::string team_home = "Lighthouse APSL";
    std::string team_away = "Ukrainian Nationals";
    std::string formation_home = "4-4-2";   // used only when a team names none
    std::string formation_away = "4-3-3";
};

void loadMatchFromDb(GameServer::Config& cfg, const persistence::DbConfig& db,
                     const MatchNames& names, bool log);

}  // namespace fh::game::server
