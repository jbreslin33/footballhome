#pragma once
#include <optional>
#include <string>
#include <unordered_map>
#include <vector>

class Database;

// ────────────────────────────────────────────────────────────────────────────
// MensTeamAssignments — read + write model for the join table that backs
// the mens dashboard (`mens_team_assignments`: leagueapps_user_id ⨯
// team_id, with a per-row `on_roster` flag).
//
// loadAll() returns every assignment grouped by user (key = stringified
// LeagueApps user id, matching how PersonBilling keys its map so the two
// can be composed without coercing types).
//
// Writes:
//   • addAssignment(user, team, mutexGroup)  → upsert + (if mutexGroup
//     non-empty) delete any sibling-column assignments for that user
//     atomically via a single pqxx::work transaction.
//   • removeAssignment(user, team)           → single DELETE.
//   • setRosterStatus(user, team, onRoster)  → UPDATE; returns nullopt
//     when no assignment exists (caller maps to 404).
//
// Every write returns the user's current list of teamIds so the controller
// can echo it back to the client and the UI can refresh without an extra
// GET.
// ────────────────────────────────────────────────────────────────────────────
class MensTeamAssignments {
public:
    struct Cell {
        int  teamId   = 0;
        bool onRoster = false;
    };

    using ByUser = std::unordered_map<std::string, std::vector<Cell>>;

    MensTeamAssignments();

    ByUser loadAll();

    // Add an assignment.  When mutexGroup is non-empty, drops every other
    // assignment for the user that lives in the same mutex group BEFORE
    // inserting (one DELETE … USING + one INSERT … ON CONFLICT inside a
    // single transaction).  Returns the user's full set of team_ids after.
    std::vector<int> addAssignment(long long userId,
                                   int teamId,
                                   const std::string& mutexGroup);

    // Plain DELETE; returns the user's remaining team_ids.
    std::vector<int> removeAssignment(long long userId, int teamId);

    // UPDATE on_roster.  Returns the new value, or nullopt when no row
    // exists (i.e. the assignment was never created — UI is stale).
    std::optional<bool> setRosterStatus(long long userId,
                                        int teamId,
                                        bool onRoster);

    // Helper: the user's full set of team_ids in ascending order.
    std::vector<int> teamIdsForUser(long long userId);

private:
    Database* db_;
};
