#pragma once
#include <string>
#include <vector>
#include <pqxx/pqxx>
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

    // ── Lineups (migration 641) ──
    // shirts[i] starts in formation slot i+1 (11 distinct shirts of this
    // team). Throws std::invalid_argument on a bad list.
    void saveLineup(const std::string& team, const std::vector<int>& shirts);

    // The linked club team's Game Center games that have a starting XI:
    // [{ match_id, date, title, starters }] newest first (upcoming too).
    nlohmann::json gameCenterLineups(const std::string& team);

    // Seat the team from one Game Center lineup: starters mapped to the
    // formation's slots by position, players new to the game added (the
    // mig-636 random draw). Returns { slots: [names…], added: n }.
    nlohmann::json importGameCenterLineup(const std::string& team, long long matchId);

private:
    // After any lineup change: position = slot label, and a team playing
    // the +1 man-marking scheme (mig 639) re-picks its free centre back
    // from the CBs now starting.
    void afterLineup(pqxx::work& tx, int teamId);
};
