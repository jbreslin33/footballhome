#pragma once
#include <optional>
#include <string>
#include <unordered_map>
#include <vector>

class Database;

// ────────────────────────────────────────────────────────────────────────────
// MensTeamAssignments — read + write model over `team_persons` (⨯ `teams`
// filtered to this domain's gender_category) that backs the Boys/Girls/Mens
// roster boards.
//
// loadAll() returns every assignment grouped by user (key = stringified
// LeagueApps user id, matching how PersonBilling keys its map so the two
// can be composed without coercing types).
//
// Writes:
//   • addAssignment(user, team, mutexGroup)  → purely additive upsert
//     (2026-08-16: multi-assign — see addAssignmentForPerson doc); every
//     other active row this person holds is left untouched.
//   • removeAssignment(user, team)           → soft-close (removed_at set,
//     row kept for history), scoped to exactly this one team_id.
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
        // Coach-set Roster Role for this team_persons row — 'starter' |
        // 'bench' | 'reserve' | nullopt (unset). See lineup_roles
        // (migration 283/293). Independent per team, so the same person
        // can carry a different role on APSL vs Liga 1.
        std::optional<std::string> lineupRole;
        // Official league roster submission status code for this
        // team_persons row — 'not_on_roster' | 'awaiting_approval' |
        // 'on_roster' | 'suspended' | nullopt (unset). See roster_statuses
        // (migration 294/295).
        std::optional<std::string> rosterStatus;
    };

    using ByUser = std::unordered_map<std::string, std::vector<Cell>>;

    MensTeamAssignments();
    // domain param scopes every SQL statement.  Default 'mens' keeps
    // existing call-sites working; boys/girls pass their own domain.
    explicit MensTeamAssignments(std::string domain);

    ByUser loadAll();

    // Fallback lookup keyed by the stable internal person id rather than
    // the (occasionally LA-drifting) la_user_id — see LaProgramSync::
    // Result::personIdByUserId for why callers need this. Same shape/
    // filters as loadAll()'s per-row query, just scoped to one person.
    std::vector<Cell> cellsForPerson(long long personId);

    // Add an assignment. Purely additive (2026-08-16: multi-assign —
    // see addAssignmentForPerson doc) — every other active row this
    // person holds, in this domain or any other, is left untouched.
    // Returns the person's full set of team_ids after. `userId` is
    // resolved to a person via persons.la_user_id — prefer
    // addAssignmentForPerson when the caller already has a trustworthy
    // person id (see doc there for why: LA's live userId can drift out
    // from under this lookup).
    std::vector<int> addAssignment(long long userId,
                                   int teamId,
                                   const std::string& mutexGroup);

    // Plain close; returns the person's remaining team_ids. Prefer
    // removeAssignmentForPerson — see addAssignmentForPerson doc.
    std::vector<int> removeAssignment(long long userId, int teamId);

    // UPDATE on_roster.  Returns the new value, or nullopt when no row
    // exists (i.e. the assignment was never created — UI is stale).
    // Prefer setRosterStatusForPerson — see addAssignmentForPerson doc.
    std::optional<bool> setRosterStatus(long long userId,
                                        int teamId,
                                        bool onRoster);

    // Helper: the user's full set of team_ids in ascending order.
    std::vector<int> teamIdsForUser(long long userId);

    // ── person_id-keyed write path (2026-08-03) ──────────────────────
    //
    // The userId-keyed methods above resolve the person via
    // `persons.la_user_id = $1`, matched against whatever LA userId
    // the FRONTEND last saw for this player. LA has been observed
    // reporting a drifting userId for the same registration across
    // syncs (see LaProgramSync.h) — when persons.la_user_id has since
    // moved on by the time a move is clicked, that lookup silently
    // matches zero rows: no error, no-op, board looks stuck ("I can't
    // move players"). Controllers that already have a resolved,
    // request-scoped person id (LaProgramSync::Result::
    // personIdByUserId, captured fresh on the same GET that rendered
    // the button) should call these directly instead — immune to the
    // race because it never re-derives identity from the live userId.
    std::vector<int> addAssignmentForPerson(long long personId,
                                             int teamId,
                                             const std::string& mutexGroup);
    std::vector<int> removeAssignmentForPerson(long long personId, int teamId);
    std::optional<bool> setRosterStatusForPerson(long long personId,
                                                 int teamId,
                                                 bool onRoster);
    std::vector<int> teamIdsForPerson(long long personId);

    // ── Delinquency soft-delete (2026-07-04, sweep disabled) ─────────
    //
    // The auto dues-owed sweep would remove a delinquent player from
    // every roster while preserving history in the same table.  Rows get
    // `removed_at=now()`, `removed_reason='delinquent'`, and a JSONB
    // blob describing the state at the moment of removal (daysOverdue,
    // nextBillDate, outstanding).  The sweep is currently DISABLED (see
    // MensRoster.cpp); these methods remain callable for admin tools.
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
    // Every LA member in good standing (delinquencyState != 'dues_owed')
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

    // person_id-keyed twin of reorderTeam() — see the person_id-keyed
    // write path doc above (addAssignmentForPerson) for why. Prefer this
    // when the caller has a request-scoped person id for every card
    // being reordered (drag-and-drop payloads carry `personId` on each
    // row — see BoysRoster.cpp / MensRoster.cpp shapePlayer output).
    long long reorderTeamForPersons(int teamId, const std::vector<long long>& personIdsInOrder);

    const std::string& domain() const { return domain_; }

private:
    Database*   db_;
    std::string domain_;
};
