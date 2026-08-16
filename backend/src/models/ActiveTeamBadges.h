#pragma once
#include <unordered_map>
#include <vector>
#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// ActiveTeamBadges — batch lookup of every active team_persons membership
// for a set of person ids, across every gender_category (boys/girls/mens/
// womens all live in the same team_persons/teams tables — see
// ClubController::handleGetClubDetail and MensTeamAssignments, which both
// read the same rows scoped by t.gender_category).
//
// Used to badge a player card with every active team they're on, so a
// player rostered on more than one team (e.g. a boy called up to a mens
// team, or someone on two mens squads) is visually obvious without
// cross-referencing every board by hand.
// ────────────────────────────────────────────────────────────────────────────
namespace ActiveTeamBadges {

// Returns personId -> JSON array of {teamId, name, genderCategory}, sorted
// by genderCategory then name. A person id with zero active memberships is
// simply absent from the map — callers should default to an empty array.
// Non-positive ids are ignored. Never throws — a DB error yields an empty
// map (caller degrades to "no badge" rather than failing the whole board).
std::unordered_map<long long, nlohmann::json> loadForPersons(
    const std::vector<long long>& personIds);

}  // namespace ActiveTeamBadges
