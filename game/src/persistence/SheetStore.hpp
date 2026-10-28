// persistence/SheetStore.hpp — player sheets ↔ the club DB (G4.83, mig 793).
//
// loadSheetRules: the 'sheet.*' numbers, the d100 tables, the position
// profile. loadSheetFacts: what the club knows about each player of a game
// team — a real age (persons.birth_date), his lineup tier and positions
// (match_lineups of the club team it mirrors), hand-edited attributes.
// saveSheets: the rolled sheet back — age / start age / years off / tier /
// quality on the player, his history and rolls, every attribute that isn't
// 'edited' (source 'derived'). All-or-nothing (one transaction).
#pragma once

#include "core/PlayerSheet.hpp"
#include "persistence/FormationStore.hpp"

#include <optional>
#include <string>
#include <vector>

namespace fh::game::persistence {

struct SheetPlayer {
    int shirt = 0;
    std::string name;
    core::SheetFacts facts;
    std::string tier_basis;   // how his tier was read (the tool prints it)
};

struct SheetTeam {
    int team_id = 0;
    std::string name;
    std::vector<SheetPlayer> players;
};

std::optional<core::SheetRules> loadSheetRules(const DbConfig& cfg);
std::optional<SheetTeam> loadSheetFacts(const DbConfig& cfg, const std::string& team_name,
                                        const core::ModelParams& params);
bool saveSheets(const DbConfig& cfg, const SheetTeam& team,
                const std::vector<core::PlayerSheet>& sheets);

}  // namespace fh::game::persistence
