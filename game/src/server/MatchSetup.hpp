// game/src/server/MatchSetup.hpp
//
// One place that turns the club DB into a match (G4.43; G5.23 slimmed):
// formations, the physics params, both teams (names, positions, kits,
// top speeds) and the officials. The live daemon
// (main.cpp) and the match harness (tools/match_main.cpp) both call it, so
// what the harness measures is exactly what the game plays.

#pragma once

#include "persistence/FormationStore.hpp"
#include "server/GameServer.hpp"

#include <string>

namespace fh::game::server {

struct MatchNames {
    std::string team_home = "Leicester City";   // mig 1042: pro only, the 2015/16 Premier League
    std::string team_away = "Arsenal";
    std::string formation_home = "4-4-2";   // used only when a team names none
    std::string formation_away = "4-3-3";
};

void loadMatchFromDb(GameServer::Config& cfg, const persistence::DbConfig& db,
                     const MatchNames& names, bool log);

}  // namespace fh::game::server
