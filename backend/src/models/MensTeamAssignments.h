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
        // Coach-defined ability rank within the team (1..N).  nullopt =
        // "no rank yet" — sort falls back to alphabetical (see
        // MensRoster.cpp comparator).  Written by
        // `reorderTeam()` as a dense sequence so we never have to deal
        // with gaps.  Added migration 089 (2026-07-04 pm).
        std::optional<int> coachSortOrder;
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

    // ── Delinquency soft-delete (2026-07-04) ─────────────────────────
    //
    // Auto-purgatory removes a delinquent player from every roster while
    // preserving history in the same table.  Rows get `removed_at=now()`,
    // `removed_reason='delinquent'`, and a JSONB blob describing the state
    // at the moment of removal (daysOverdue, nextBillDate, outstanding).
    //
    // bulkSoftDeleteForDelinquent(userIds, details):
    //   For every uid in `userIds`, marks every ACTIVE (removed_at IS
    //   NULL) row with removed_reason='delinquent' and stores
    //   details[uid] on each row.  Idempotent — already-removed rows are
    //   skipped by the WHERE clause.  Returns the number of rows touched
    //   for logging.
    //
    // bulkRestoreForDelinquent(userIds):
    //   For every uid, un-removes rows that were removed_reason='delinquent'
    //   (leaves other removal reasons intact).  Sets removed_at/reason/
    //   details back to NULL.  If restoring would collide with an already-
    //   active row on the same (user, team), skips that row (partial
    //   unique index would reject).  Returns count restored.
    struct DelinquencyDetail {
        int  daysOverdue     = 0;
        std::string nextBillDate;   // "YYYY-MM-DD" or empty
        double outstandingBalance = 0.0;
        bool   hasBalance    = false;
    };

    long long bulkSoftDeleteForDelinquent(
        const std::unordered_map<long long, DelinquencyDetail>& details);

    long long bulkRestoreForDelinquent(const std::vector<long long>& userIds);

    // ── Practice / Pickup auto-membership (2026-07-04) ───────────────
    //
    // Every LA member in good standing (delinquencyState != 'purgatory')
    // is automatically on the Practice (908) + Pickup (909) teams — the
    // Mens Roster Board doesn't render those as selection columns any
    // more; instead, `/api/mens-roster` calls `bulkEnsureActive()` after
    // the delinquency sweep so downstream consumers (lineups.js Practice
    // + Pickup team columns) see everyone.
    //
    // Semantics: for each uid in `userIds`, insert an active row for
    // `teamId` if none exists.  Respects the partial unique index
    // (leagueapps_user_id, team_id) WHERE removed_at IS NULL — duplicate
    // active rows are impossible.  Rows that are currently soft-deleted
    // for delinquency should be restored via `bulkRestoreForDelinquent()`
    // *first* so we preserve audit history; this method then no-ops for
    // those uids on conflict.
    //
    // Returns count inserted (for logging).
    long long bulkEnsureActive(const std::vector<long long>& userIds, int teamId);

    // ── Coach-defined ordering (2026-07-04 pm) ───────────────────────
    //
    // Rewrites the `coach_sort_order` column for every active row on
    // `teamId` whose user appears in `userIdsInOrder`.  Users get
    // 1..N in the order supplied; users on the team but missing from
    // the list are left alone (coach_sort_order NULL == alpha fallback).
    //
    // Idempotent — safe to call after every drag-and-drop.  Returns the
    // number of rows touched for logging.
    long long reorderTeam(int teamId, const std::vector<long long>& userIdsInOrder);

private:
    Database* db_;
};
