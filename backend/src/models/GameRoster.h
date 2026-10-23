#pragma once
#include <string>
#include "../third_party/json.hpp"

// GameRoster — the game's teams for the attribute editor (migration 636):
// game_demo_teams / game_demo_players / game_demo_player_attributes plus
// the game_attributes registry. The game daemon reads the same rows at
// boot; the editor also sends each change to the running match over the
// game's own wire (PLAYER_ATTRIBUTES), so a save is live AND persistent.
class GameRoster {
public:
    // { team, formation, level_band, attributes: [registry rows],
    //   players: [{ shirt, name, position, description, attrs: {code: n} }] }
    // null when no such team.
    nlohmann::json team(const std::string& name);

    // attrs: { code: 0-100 | null (null = unrated, row removed) }.
    // False when the team / shirt doesn't exist.
    bool savePlayer(const std::string& team, int shirt, const nlohmann::json& attrs,
                    const nlohmann::json& description);
};
